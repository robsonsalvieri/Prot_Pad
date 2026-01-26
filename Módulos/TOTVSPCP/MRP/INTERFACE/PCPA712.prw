#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA712.CH"

#DEFINE cCRLF                Chr(13)+Chr(10) + Chr(13)+Chr(10) //Quebra de duas linhas
#DEFINE CAMPOS_CHECK_SIMPLES "|demandsProcessed|lAguardaDescarga|lGeraDoc|eventLog|lUsesProductIndicator|lRastreiaEntradas|"
#DEFINE CAMPOS_CHECK_MULTI   "|demandType|documentType|"
#DEFINE CAMPOS_DATA          "|mrpStartDate|demandStartDate|demandEndDate|"
#DEFINE CAMPOS_NUM             "|firmHorizon|structurePrecision|nThreads|nThreads_RAS|nThreads_MAT|nThreads_AGL|nThreads_EVT|"
#DEFINE PARAM_NA_TELA_1        "|demandStartDate|demandEndDate|demandsProcessed|lGeraDoc|eventLog|lRastreiaEntradas|"
#DEFINE PARAMETROS_ARM         "|armazemDe|armazemAte|"
#DEFINE PARAMETROS_ESPECIFICOS "|usaRevisaoPai|"
#DEFINE PARAMETROS_MV          "|MV_MRPPERD|MV_QLIMITE|MV_LOTVENC|MV_USAQTEM|MV_QUEBROP|MV_QUEBRSC|MV_FORCALM|MV_SUBSLE|MV_ARQPROD|MV_CQ|MV_GRVLOCP|MV_LOCPROC|MV_PRODMOD|MV_TPHR|MV_UNIDMOD|MV_PCPMADI|MV_LOGMRP|MV_MRPCMEM|MV_REVFIL|MV_POLPMP|MV_EMPBN|MV_MRPSBPR|MV_REPGOPC|MV_MRPTRAN|MV_AGLTR"
#DEFINE SEPARADOR              "|"
#DEFINE TAMANHO_DESC           100
#DEFINE IND_EMPTY              '*' + CHR(13) + '*'

//DEFINES para a gestão de procedures
#DEFINE DEF_SPS_FROM_RPO 		"1"
#DEFINE DEF_SPS_UPDATED			"0"

//Definições da Operação
#DEFINE IND_OPERACAO_SELECIONAR 1
#DEFINE IND_OPERACAO_COPIAR     2

#DEFINE DEFAULT_nMSG_LOCK_ALERT    30 //30 segundos
#DEFINE DEFAULT_nMSG_LOCK_ERROR   180 //180 segundos = 3 minutos
#DEFINE INTERVALO_LOG_USO_MEMORIA  60 // Quantidade de passagens pela updStatus antes de imprimir log de uso de memória.

Static saFiliais  := {}
Static scCMPMULTI := "|products|productGroups|productTypes|documents|warehouses|"

//Estáticas para guardar os parâmetros
Static scErrorUID
Static scSetupAnt := ""
Static snTamPar   := GetSx3Cache("HW2_PARAM","X3_TAMANHO")
Static soParam
Static soPCPError
Static soTGetCod  := Nil
Static soTGetDes  := Nil
Static snMrpSinc  := 1
Static scLogMrp   := "2"
Static slIntgMES  := .F.
Static slMESLite  := .F.
Static slIntgSFC  := .F.
Static slIntgQIP  := .F.

//Estáticas de processamento
Static slConcluiu  := .F. //Controle de término do processamento
Static slError     := .F. //Controle de erro no processamento
Static soTimer     := Nil //Objeto Timer para atualização do andamento
Static snAtuDem    := 0   // 0-Não atualizado/1-Atualizado com sucesso/2-Erro na atualização
Static slSincroni  := .F.
Static soGeraDoc   := Nil
Static snProgDoc   := 0
Static snProgRast  := 0
Static snProgSugE  := 0
Static snDocAlca   := 0
Static snRastDoc   := 0
Static slLock      := .F.
Static slshowMsgL  := .F.
Static snIniStat   := Nil
Static snEventLog  := Nil
Static scPicoMemo  := Nil
Static slGDocADes  := .F.
Static snTryGDoc   := 0
Static snMaxTGDoc  := 5
Static slAtuMem    := .T.
Static slExcOpFim  := .F.

//Exibição do processamento
Static saStatus   := {}  //Status do Andamento da Execução
Static __SINCRONI := 0
Static __NIVEIS   := 0
Static __EXCLUSAO := 0
Static __CARGA    := 0
Static __CALCULO  := 0
Static __LOG_EVEN := 0
Static __PERSIST  := 0
Static __GERARAST := 0
Static __GERA_DOC := 0
Static __DOC_ALCA := 0
Static __RAST_DOC := 0
Static __SUG_LOTE := 0
Static __INTG_MES := 0
Static __INTG_SFC := 0
Static __INTG_QIP := 0
Static __MEMORIA  := 0

Static soOK       := LoadBitmap(GetResources(),'BR_VERDE')
Static soAM       := LoadBitmap(GetResources(),'BR_AMARELO')
Static soLA       := LoadBitmap(GetResources(),'BR_LARANJA')
Static soNO       := LoadBitmap(GetResources(),'BR_VERMELHO')
Static soAtual    := LoadBitmap(GetResources(),'REFRESH')

Static _lP712LDTL := ExistBlock("P712LDTL")
Static _lP712VLD  := ExistBlock("P712VLD")
Static _lP712FIM  := ExistBlock("P712FIM")
Static _lP145LOG  := FindFunction("P145VLOGEVE")
Static _lMEFilDes := Nil

Static _lRunP712F := .T.
Static _nMemLimit := 0
Static _nContLogM := 0

Static _lCrpOk    := Nil

/*/{Protheus.doc} PCPA712
Programa de processamento do Novo MRP
@author douglas.heydt
@since 05/07/2019
@param 01 - oParametros, Object, Json com os parâmetros para a execução em modo schedule.
@param 02 - lCancel, Logic, Indica se irá cancelar o ticket reservado (caso esteja executando em modo schedule)
@param 03 - lIntegra, Logic, Indica se irá realizar a integração, caso haja pendencias de integração (caso esteja executando em modo schedule)
@version P12
/*/
Function PCPA712(oParametros, lCancel, lIntegra)
	Local lRet     := .F.
	Local lSchdl   := oParametros <> Nil
	Local oPCPLock := Nil

	Default lCancel     := .F.
	Default lIntegra    := .F.
	Default oParametros := NIL

	//Permite acesso ao MRP somente pelos módulos de PCP, Estoque e Gestão de Projetos
	//Essa validação deve ficar nessa função. As demais deverão ser inseridas na PermitExec()
	If !AMIIn(10,44,4)
		Help( ,  , "A712L" + cValToChar(ProcLine()), , STR0274; //"Rotina indisponível para acesso através deste módulo."
			, 1, 0, , , , , , {STR0275})                      //"Entre em contato com o departamento de TI."
		Return .F.
	EndIf

	If FWAliasInDic("SMQ",.F.) .And. !mrpInSMQ(cFilAnt)
		Help( ,  , "A712NOSMQ", , STR0343; // "A execução do MRP está bloqueada nesta filial."
			, 1, 0, , , , , , {STR0344}) // "Para executar o MRP nesta filial, realize o cadastro nas configurações (PCPA139)."
		Return .F.
	EndIf

	dbSelectArea("SMH")
	_lMEFilDes := FieldPos("MH_FILDES") > 0

	_lRunP712F := .T.
	slAtuMem   := .T.

	If soParam == Nil
		soParam := JsonObject():New()
	EndIf

	scLogMrp := SuperGetMV("MV_LOGMRP", .F., "2")

	If PermitExec(lSchdl)
		atuIndice()
		If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO")) .And. !("|demandCodes|" $ scCMPMULTI)
			scCMPMULTI += "demandCodes|"
		EndIf

		oPCPLock := PCPLockControl():New()
		ErrorBlock({|e| A712Error(e) })

		//Seta parâmetros de ambiente
		If !lSchdl
			soParam['cEmpAnt'] := cEmpAnt
			soParam['cFilAnt'] := cFilAnt
			soParam['user']    := RetCodUsr()
		Else
			soParam['cEmpAnt'] := oParametros['cEmpAnt']
			soParam['cFilAnt'] := oParametros['cFilAnt']
			soParam['user']    := oParametros['user']
		EndIf
		soParam["serverMemoryLimit"] := cValToChar(GetPvProfileInt("GENERAL", "ServerMemoryLimit", 0, GetSrvIniName()))
		soParam["heapLimit"        ] := cValToChar(GetPvProfileInt("GENERAL", "HeapLimit"        , 0, GetSrvIniName()))

		_nMemLimit := Val(soParam["heapLimit"])
		If Empty(_nMemLimit)
			_nMemLimit := Val(soParam["serverMemoryLimit"])
		EndIf

		If !Empty(_nMemLimit)
			LogMsg('PCPA712', 0, 0, 1, '', '', "[PCPA712] [MEMORIA] MRP EM EXECUCAO COM LIMITE DE MEMORIA DEFINIDO EM " + cValToChar(_nMemLimit) + " MB")
		EndIf

		snMrpSinc := SuperGetMV("MV_MRPSINC", .F., 1)
		slIntgMES := (PCPIntgPPI("SC2", @slMESLite) .And. PCPIntgMRP() <> "1")
		slIntgSFC := ExisteSFC("SC2")
		slIntgQIP := IntQIP()

		//Seta defaults dos parâmetros da tela
		SetDefault()

		//Verifica disponibilidade de execução do MRP
		If canStart(oParametros, lCancel, lIntegra)

			If !lSchdl
				//Cria o Wizard dos parâmetros de processamento
				WizCriacao()
			Else
				// Inicia a execução em schedule
				lRet := MrpSchdl(oParametros)
			EndIf

			//Libera proteção de execução paralela
			oPCPLock:unlock("MRP_MEMORIA", "PCPA712", soParam["ticket"])
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

	If lSchdl .and. !lRet
		aHelp := GetHelpPCP(STR0321) // "Execução do MRP não foi concluida com sucesso!"
		LogMsg('MrpSchdl', 0, 0, 1, '', '', aHelp[2])
	EndIf

	//Limpa os parâmetros da memória
	LimpaObj()

Return lRet

/*/{Protheus.doc} A712Error
Função para tratativa de erros de execução

@type  Function
@author brunno.costa
@since 18/08/2020
@version P12.1.27
@param e    , Object  , Objeto com os detalhes do erro ocorrido
/*/
Function A712Error(e)
	Local oPCPLock   := PCPLockControl():New()
	LogMsg('PCPA712', 0, 0, 1, '', '', ;
	       Replicate("-",70) + CHR(10) + AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + Replicate("-",70))
	oPCPLock:unlock("MRP_MEMORIA", "PCPA712", "*")
	oPCPLock:unlock("MRP_MEMORIA", "PCPA141", "*")
	oPCPLock:unlock("MRP_MEMORIA", "PCPA140", "*")
	BREAK
Return

/*/{Protheus.doc} PCPA712JOB
ExecAuto Processamento MRP - JOB para Automação
@author brunno.costa
@since 21/12/2019
@version P12
@param 01 - oParametros, objeto, objeto Json de parâmetros
/*/
Function PCPA712JOB(oParametros)

	Local aReturn     := {}
	Local aUltProc    := {}
	Local aLogMRP     := {}
	Local cTicket     := ""
	Local cUser       := ""
	Local oBody       := JsonObject():New()
	Local oJsonRet    := JsonObject():New()
	Local oJsonAux    := JsonObject():New()
	Local aParams	  := {}

	Default oParametros := P712Param()

	If soParam == Nil
		soParam  := JsonObject():New()
	EndIf
	If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO")) .And. !("|demandCodes|" $ scCMPMULTI)
		scCMPMULTI += "demandCodes|"
	EndIf

	oBody["branchId"] := cFilAnt
	oBody["user"    ] := "000000"

	//Converte soParam em Array para API
	oBody["listOfMRPParameters"] := TOParamAPI(oParametros)

	aReturn := MrpPStart(oBody, oParametros["cAutomacao"])
	oJsonRet:fromJson(aReturn[2])
	cTicket := oJsonRet["ticket"]
	oParametros["ticket"] := cTicket

	aReturn := MrpPLoad(oBody)
	oJsonRet:fromJson(aReturn[2])

	cUser := oBody["user"]

	FreeObj(oBody)
	FreeObj(oJsonRet)
	aSize(aReturn, 0)
	oBody    := Nil
	oJsonRet := Nil
	aReturn  := Nil

	//Dispara Finalização da Carga em Memória + Processamento
	ExecutaMRP(oParametros)

	//Aguarda Término do Processamento
	Sleep(5000)
	While .T.
		Sleep(500)

		//Verifica término ou falha no processamento
		aUltProc := MrpGStatus(cEmpAnt, cTicket)
		If !Empty(aUltProc)
			oJsonAux:fromJson(aUltProc[2])
			If oJsonAux["status"] != Nil .AND. oJsonAux["status"] $ "3,4,9"
				Exit
			EndIf
			FreeObj(oJsonAux)
			oJsonAux := JsonObject():New()
		EndIf
		aSize(aUltProc, 0)
	EndDo

	If !updDemands(cTicket)
		LogMsg('updDemands', 0, 0, 1, '', '', STR0204)
	EndIf
	If oParametros["lGeraDoc"]
		AADD(aParams,{0,{"","","consolidateProductionOrder",oParametros['consolidateProductionOrder']}})
		AADD(aParams,{0,{"","","consolidatePurchaseRequest",oParametros['consolidatePurchaseRequest']}})
		AADD(aParams,{0,{"","","productionOrderNumber"     ,oParametros['productionOrderNumber'     ]}})
		AADD(aParams,{0,{"","","purchaseRequestNumber"     ,oParametros['purchaseRequestNumber'     ]}})
		AADD(aParams,{0,{"","","productionOrderType"       ,oParametros['productionOrderType'       ]}})
		AADD(aParams,{0,{"","","allocationSuggestion"      ,oParametros['allocationSuggestion'      ]}})
		AADD(aParams,{0,{"","","lDocAlcada"                ,oParametros['lDocAlcada'                ]}})
		AADD(aParams,{0,{"","","lRastreiaEntradas"         ,Iif(soParam['lRastreiaEntradas'],"1","2")}})
		PutGlbValue(oParametros["ticket"]+"UIDPRG_PCPA145","INI")
		PutGlbValue(oParametros["ticket"]+"PCPA151_STATUS","INI")
		PCPA145(cTicket, aParams, .T., scErrorUID, cUser)
	EndIf

	IF oParametros["eventLog"] .And. oParametros["cAutomacao"] == "2"
		aLogMRP := MrpGetLog(cTicket,,,"PCP")
		aSize(aLogMRP, 0)
	EndIf

	//Limpa os parâmetros da memória
	LimpaObj()

Return Nil

/*/{Protheus.doc} PCPA712Par
Retorna conteúdo Default de Parâmetros da Tela do MRP para Automação
@author brunno.costa
@since 21/11/2019
@version P12
@param 01 - lNewPar, Logic, Indica que o objeto retornado não irá referenciar o soParam.
@return Nil
/*/
Function P712Param(lNewPar)

	Local oJson := Nil

	Default lNewPar := .F.

	// Criado novo objeto json local, para separar da variavel estatica soParam
	If lNewPar
		oJson := JsonObject():New()
		soParam := oJson
	EndIf

	If soParam == Nil
		soParam  := JsonObject():New()
	EndIf

	SetDefault()

	// Limpa referencia soParam do Json local
	If lNewPar
		soParam := Nil
	EndIf

Return IIF(lNewPar, oJson, soParam)

/*/{Protheus.doc} SetDefault
Seta o default dos parâmetros da tela
@author marcelo.neumann
@since 31/07/2019
@version P12
@return Nil
/*/
Static Function SetDefault()
	Local aChave    := {}
	Local aFields   := {}
	Local aOrder    := {}
	Local aViewBtn  := {}
	Local lMultiEmp := .F.

	//Seta parâmetros chaves da tela principal (tela 1)
	soParam["TELA_1"] := JsonObject():New()
	soParam["TELA_1"]["HW2_CODIGO"   ] := CriaVar("HW2_CODIGO")  //Código do Setup
	soParam["TELA_1"]["HW2_DESCRI"   ] := CriaVar("HW2_DESCRI")  //Descrição do Setup
	soParam["TELA_1"]["TELA_CONSULTA"] := ConsultaSetup():New()  //Consulta padrão do campo Código
	soParam["TELA_1"]["CHECK_PULAR"  ] := .F.                    //Checkbox para pular para o processamento
	soParam["TELA_1"]["CHECK_OBJETO" ] := NIL                    //Checkbox para pular para o processamento
	soParam["TELA_1"]["OPERACAO"     ] := 1 /*SELECIONAR*/       //Indica a operação selecionada na tela de consulta
	soParam["TELA_1"]["VALIDADA"     ] := .F.                    //Indica se a página 1 já foi validada

	//Parâmetros de tela para o processamento do MRP
	soParam["demandStartDate"           ] := dDatabase           //Data início
	soParam["demandEndDate"             ] := (dDatabase + 30)    //Data fim
	soParam["demandsProcessed"          ] := .F.                 //Checkbox para considerar ou não as demandas já processadas
	soParam['lGeraDoc'                  ] := .F.                 //Checkbox para indicar se os documentos serão gerados ao término do cálculo
	soParam['lRastreiaEntradas'         ] := .F.                 //Checkbox para indicar se as entradas serão rastreadas (tabela SME)
	soParam['eventLog'                  ] := .F.                 //Checkbox para indicar se gera o Log de Eventos
	soParam["mrpStartDate"              ] := dDataBase           //Data de início do MRP
	soParam["periodType"                ] := "1" /*Diário*/      //Tipo de periodo
	soParam["numberOfPeriods"           ] := "30 "               //Número de períodos
	soParam["firmHorizon"               ] := 2                   //Horizonte Fixo (1-Sim, 2-Não)
	soParam["leadTime"                  ] := "1" /*Dias Úteis*/  //Tipo de calculo do lead time
	soParam["consignedOut"              ] := "1" /*Soma*/        //Estoque EM Terceiro
	soParam["consignedIn"               ] := "2" /*Subtrai*/     //Estoque DE Terceiro
	soParam["rejectedQuality"           ] := "2" /*Subtrai*/     //Estoque Rejeitado pelo CQ
	soParam["blockedLot"                ] := "2" /*Subtrai*/     //Estoque Bloqueado por Lote
	soParam["safetyStock"               ] := "1" /*Sim*/         //Considera Estoque de Seguranca
	soParam["orderPoint"                ] := "1" /*Sim*/         //Considera Ponto de Pedido
	//soParam["maxStock"                  ] := "1" /*Sim*/         //Considera Estoque Maximo
	soParam["consolidatePurchaseRequest"] := "3" /*Sim*/         //Aglutina Solicitação de Compras
	soParam["consolidateProductionOrder"] := "3" /*Sim*/         //Aglutina Ordem de Produção
	soParam["productionOrderNumber"     ] := "2" /*Por Numero*/  //Incrementa Ordens de Produção
	soParam["purchaseRequestNumber"     ] := "2" /*Por Numero*/  //Incrementa Solicitações de Compra
	soParam["productionOrderType"       ] := "1" /*Previstos*/   //Tipo do documento
	soParam["lDocAlcada"                ] := "2" /*Não*/         //Gerar Documentos com Alçada
	soParam["allocationSuggestion"      ] := "2" /*Não*/         //Sugestao de Lote e Endereco dos Empenhos
	soParam["armazemPad"                ] := "1" /*Sim*/         //Considera Só Armazém Padrão
	soParam["armazemDe"                 ] := CriaVar("NNR_CODIGO")  //Armazém De
	soParam["armazemAte"                ] := CriaVar("NNR_CODIGO")  //Armazém Até

	//Checkbox "Tipo Demanda"
	soParam["demandType" ] := JsonObject():New()
	soParam["demandType" ]["PEDIDO_VENDA"] := .T.
	soParam["demandType" ]["PREV_VENDAS" ] := .T.
	soParam["demandType" ]["PLANO_MESTRE"] := .T.
	soParam["demandType" ]["EMP_PROJETO" ] := .T.
	soParam["demandType" ]["MANUAL"      ] := .T.
	soParam["demandType" ]["VALOR"       ] := "12349"

	//Checkbox "Considera Documentos"
	soParam["documentType"] := JsonObject():New()
	soParam["documentType"]["PREVISTOS"    ] := "1" //Exclui
	soParam["documentType"]["SUSPENSOS"    ] := .T.
	soParam["documentType"]["SACRAMENTADOS"] := .T.
	soParam["documentType"]["REJEITADOS"   ] := .T.
	soParam["documentType"]["VALOR"        ] := "|1.1|2|3|4|"

	//Demais parâmetros
	soParam["structurePrecision"] := TamSX3("G1_QUANT")[2]
	soParam["cAutomacao"        ] := "0"

	//Geração do arquivo de logs
	scLogMrp := IIf(Empty(scLogMrp), "2", scLogMrp)
	soParam["processLogs"] := scLogMrp

	//Campos multivalorados
	addFiliais()
	lMultiEmp := Len(saFiliais) > 1

	aFields := {"B1_COD", "B1_DESC", "B1_TIPO", "B1_GRUPO"}
	aOrder  := {"B1_COD"}

	SetFilter("products", "SB1", aFields, {"B1_COD", "B1_DESC"}, {}, 1, STR0118, .F.,, GetSx3Cache("B1_COD", "X3_TAMANHO"), aOrder) //"Produto"

	aSize(aFields, 0)
	aSize(aOrder , 0)

	aFields := {"BM_GRUPO", "BM_DESC"}
	aOrder  := {"BM_GRUPO"}

	SetFilter("productGroups", "SBM", aFields, aFields, {filtroFil("BM_FILIAL", "SBM")}, 1, STR0119, .T.,, GetSx3Cache("BM_GRUPO","X3_TAMANHO"), aOrder) //"Grupo Material"

	aSize(aFields, 0)
	aSize(aOrder , 0)

	aFields := {"X5_CHAVE", "X5_DESCRI"}
	aOrder  := {"X5_CHAVE"}

	SetFilter("productTypes", "SX5", aFields, aFields, {filtroFil("X5_FILIAL", "SX5"), "X5_TABELA  = '02'"}, 1, STR0120, .F.,, GetSx3Cache("B1_TIPO" ,"X3_TAMANHO"), aOrder) //"Tipo Material"

	aSize(aFields, 0)
	aSize(aOrder , 0)
	If lMultiEmp
		aAdd(aFields, "VR_FILIAL")
		aAdd(aOrder , "VR_FILIAL")

		aChave := {"VR_FILIAL", "VR_DOC"}
	EndIf

	aAdd(aFields, "VR_DOC")
	aAdd(aOrder , "VR_DOC")

	aAdd(aViewBtn, {STR0349, {|oView| consulDoc(oView)}}) // "Consultar Demandas"

	SetFilter("documents", "SVR", aFields, {"VR_DOC"}, {filtroFil("VR_FILIAL", "SVR"), "VR_DOC <> ' '"}, 5, STR0121, .F., aChave, GetSx3Cache("VR_DOC","X3_TAMANHO"), aOrder, aViewBtn) //"Documento"
	aSize(aViewBtn, 0)

	aSize(aFields, 0)
	aSize(aOrder , 0)

	aFields := {"NNR_CODIGO", "NNR_DESCRI"}
	aOrder  := {"NNR_CODIGO"}

	SetFilter("warehouses", "NNR", aFields, aFields, {filtroFil("NNR_FILIAL", "NNR"), "NNR_MRP <> '2'"}, 1, STR0122, .F.,, GetSx3Cache("NNR_CODIGO","X3_TAMANHO"), aOrder) //"Armazém"

	If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
		If !("|demandCodes|" $ scCMPMULTI)
			scCMPMULTI += "demandCodes|"
		EndIf

		aSize(aFields, 0)
		aSize(aChave , 0)
		aSize(aOrder , 0)
		If lMultiEmp
			aAdd(aFields, "VB_FILIAL")
			aAdd(aOrder , "VB_FILIAL")

			aChave := {"VB_FILIAL", "VB_CODIGO"}
		EndIf

		aAdd(aFields, "VB_CODIGO")
		aAdd(aOrder , "VB_CODIGO")

		aAdd(aFields, "VB_DTINI" )
		aAdd(aFields, "VB_DTFIM" )
		SetFilter("demandCodes", "SVB", aFields, {"VB_CODIGO", "VB_DTINI", "VB_DTFIM"}, {filtroFil("VB_FILIAL", "SVB")}, 1, STR0224, .F., aChave, GetSx3Cache("VB_CODIGO","X3_TAMANHO"), aOrder) //"Demandas"
	EndIf

	aSize(aFields, 0)
	aSize(aChave , 0)
	aSize(aOrder , 0)

Return Nil

/*/{Protheus.doc} SetFilter
Cria estrutura para o parâmetro multivalorado
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 cParam    , caracter, indicador do parâmetro
@param 02 cAlias    , caracter, alias referente ao parâmetro
@param 03 aFields   , array   , array com os campos a serem exibidos na consulta
@param 04 aRetField , array   , array com os campos a serem retornados
@param 05 aFilter   , array   , array com os filtros a serem aplicados na consulta
@param 06 nIndice   , numérico, índice a ser utilizado no alias
@param 07 cTitulo   , caracter, título para a janela
@param 08 lPermVazio, lógico  , define se o filtro deve conter um elemento vazio
@param 09 aChave    , array   , array com os dados que devem ser concatenados para formar a chave do registro.
@param 10 nTamCod   , numérico, Tamanho utilizado pelo código único da informação
@param 11 aOrder    , array   , array com os campos para ordenação dos registros
@param 12 aViewBtn  , array   , array com os informações para adicionar botões na view
@return Nil
/*/
Static Function SetFilter(cParam, cAlias, aFields, aRetField, aFilter, nIndice, cTitulo, lPermVazio, aChave, nTamCod, aOrder, aViewBtn)
	Default nTamCod := 0

	soParam[cParam] := JsonObject():New()
	soParam[cParam]["CODIGO"   ] := CriaVar(aRetField[1], .F.)  //Código
	soParam[cParam]["DESCRICAO"] := Space(TAMANHO_DESC)         //Descrição
	soParam[cParam]["LISTA"    ] := ""                          //Lista
	soParam[cParam]["FILTER"   ] := FiltroMultivalorado():New(cAlias, aFields, aRetField, aFilter, nIndice, cParam, cTitulo, lPermVazio, aChave, aOrder, aViewBtn)  //Filtro
	soParam[cParam]["RECNO"    ] := 0
	soParam[cParam]["TAM_COD"  ] := nTamCod

Return Nil

/*/{Protheus.doc} WizCriacao
Abre o Wizard para informar os parâmetros de processamento
@author douglas.heydt
@since 05/07/2019
@version P12
@return Nil
/*/
Static Function WizCriacao()

	Local oStepWiz := FWWizardControl():New(,{545, 720})
	Local oNewPag  := Nil

	//Adiciona os passos no Wizard
	oStepWiz:ActiveUISteps()

	//Página 1
	oNewPag := oStepWiz:AddStep("1", {|oPanel| MontaPag1(oPanel)})
	oNewPag:SetStepDescription(OemToAnsi(STR0066)) //"Setup"
	oNewPag:SetNextAction({|| ValidaPag1(oStepWiz)})
	oNewPag:SetCancelAction({|| CancelExec(1)})

	//Página 2
	oNewPag := oStepWiz:AddStep("2", {|oPanel| MontaPag2(oPanel)})
	oNewPag:SetStepDescription(OemToAnsi(STR0003)) //"Períodos"
	oNewPag:SetNextAction({|| ValidaPag2()})
	oNewPag:SetCancelAction({|| CancelExec(2)})

	//Página 3
	oNewPag := oStepWiz:AddStep("3", {|oPanel| MontaPag3(oPanel)})
	oNewPag:SetStepDescription(OemToAnsi(STR0067)) //"Estoque
	oNewPag:SetNextAction({|| ValidaPag3()})
	oNewPag:SetCancelAction({|| CancelExec(3)})

	//Página 4
	oNewPag := oStepWiz:AddStep("4", {|oPanel| MontaPag4(oPanel)})
	oNewPag:SetStepDescription(OemToAnsi(STR0217)) //"Documentos"
	oNewPag:SetNextAction({|| ValidaPag4(.F.)})
	oNewPag:SetCancelAction({|| CancelExec(4)})

	//Página 5
	oNewPag := oStepWiz:AddStep("5", {|oPanel| MontaPag5(oPanel)})
	oNewPag:SetStepDescription(OemToAnsi(STR0117)) //"Seleção"
	oNewPag:SetNextAction({|| ValidaPag5()})
	oNewPag:SetCancelAction({|| CancelExec(5)})
	oNewPag:SetNextTitle(OemToAnsi(STR0161)) //"Executar"

	//Página 6
	oNewPag := oStepWiz:AddStep("6", {|oPanel| MontaPag6(oPanel, oStepWiz)})
	oNewPag:SetStepDescription(OemToAnsi(STR0068)) //"Execução"
	oNewPag:SetNextAction({|| ValidaPag6()})
	oNewPag:SetCancelAction({|| CancelExec(6)})

	oStepWiz:Activate()
	oStepWiz:Destroy()

Return Nil

/*/{Protheus.doc} MontaPag1
Monta a primeira página do Wizard: "Setup de Configuração"
@author douglas.heydt
@since 05/07/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag1(oPanel)

	Local oGroup1
	Local oSay1
	Local oSay2
	Local oSay3, oTGet3
	Local oSay4, oTGet4
	Local oCheck5, oCheck6, oCheck7, oCheck8
	Local nLinha := 48

	//Configuração das fontes
	Local oFont13B := TFont():New("Arial", , -13, , .T.)
	Local oFont11  := TFont():New("Arial", , -11, , .F.)

	//Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

	//Texto do cabeçalho
	TSay():New(05, 10, {|| STR0011 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Setup de Configuração"
	TSay():New(15, 10, {|| STR0006 }, oPanel, , oFont11 , , , , .T., , , 320, 100, , , , , , , 3) //"Este assistente permite definir cenários de configuração para a execução do MRP."
	TSay():New(25, 10, {|| STR0001 }, oPanel, , oFont11 , , , , .T., , , 320, 100, , , , , , , 3) //"Informe os dados do cenário para registrar ou recuperar os parâmetros de execução."

	oGroup1 := TGroup():New(35, 15, 170, 350, STR0011, oPanel, , , .T.) //"Setup de Configuração"

	oSay1  := TSay():New(nLinha+2, 20, {|| STR0009 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Código:"
	oSay1:SetTextAlign(1, 0)
	soTGetCod := TGet():New(nLinha, 65, {|u| If( PCount() > 0, soParam["TELA_1"]["HW2_CODIGO"] := u, soParam["TELA_1"]["HW2_CODIGO"] ) } ,oPanel,50,10,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| AtDesSetup(oPanel:oWnd, .F.)},.F.,.F.,,soParam["TELA_1"]["HW2_CODIGO"],,,,.F.)
	soTGetCod:bHelp := {|| ShowHelpCpo("HW2_CODIGO", {STR0002}, 2, {""},2)} //"Informe o código do cenário que será utilizada para registrar este Setup de Configuração."
	soTGetCod:cF3   := "AbreConsul()"

	nLinha += 15
	oSay2  := TSay():New(nLinha+2, 20, {|| STR0010 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Descrição:"
	oSay2:SetTextAlign(1, 0)
	soTGetDes := TGet():New(nLinha, 65, {|u| If( PCount() > 0, soParam["TELA_1"]["HW2_DESCRI"] := u, soParam["TELA_1"]["HW2_DESCRI"] ) } ,oPanel,200,10,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["TELA_1"]["HW2_DESCRI"],,,,.F.)
	soTGetDes:bHelp := {|| ShowHelpCpo("HW2_DESCRI", {STR0004}, 2, {""},2)} //"Informe a descrição do cenário que será utilizada para registrar este Setup de Configuração."

	nLinha += 15
	oSay3  := TSay():New(nLinha+2, 20, {|| STR0015 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Demandas de:"
	oSay3:SetTextAlign(1, 0)
	oTGet3 := TGet():New(nLinha, 65, {|u| If(PCount() == 0, soParam["demandStartDate"], soParam["demandStartDate"] := u)}, oGroup1, 60, 10, "@D",, , ,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'soParam["demandStartDate"]',,,,.T.)
	oTGet3:bHelp := {|| ShowHelpCpo("demandStartDate", {STR0107}, 2, {""},2)} //"Define a data inicial para busca das demandas a serem consideradas no cálculo do MRP."

	oSay4  := TSay():New(nLinha+2, 130, {|| STR0016 }, oGroup1, , oFont11, , , , .T., , , 20, 20) //"até
	oTGet4 := TGet():New(nLinha, 145, {|u| If(PCount() == 0, soParam["demandEndDate"], soParam["demandEndDate"] := u)}, oGroup1, 60, 10, "@D",, , ,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,'soParam["demandEndDate"]',,,,.T.)
	oTGet4:bHelp := {|| ShowHelpCpo("demandEndDate", {STR0108}, 2, {""},2)} //"Define a data final para busca das demandas a serem consideradas no cálculo do MRP."

	nLinha += 17
	oCheck5 := TCheckBox():New(nLinha, 65, STR0178, {|u| If(PCount() == 0, soParam["demandsProcessed"], soParam["demandsProcessed"] := u)}, oGroup1, 120, 40, , , , , , , , .T., , , ) //"Considerar demandas já processadas"
	oCheck5:bHelp := {|| ShowHelpCpo("demandsProcessed", {STR0242}, 2, {""},2)}
	//STR0242 - "Indica se devem ser consideradas as demandas que já foram processadas anteriormente (status igual a 1)."

	nLinha += 12
	oCheck6 := TCheckBox():New(nLinha, 65, STR0228, {|u| If(PCount() == 0, soParam["eventLog"], soParam["eventLog"] := u)}, oGroup1, 120, 40, , , , , , , , .T., , , ) //"Gerar Log de Eventos"
	oCheck6:bHelp := {|| ShowHelpCpo("eventLog", {STR0243 + cCRLF + STR0244 + cCRLF + STR0245 + cCRLF + STR0246 + cCRLF + STR0247 + cCRLF + STR0248 + cCRLF + STR0249 + cCRLF + STR0250 + cCRLF + STR0251 + cCRLF + STR0252 + cCRLF + STR0253}, 2, {""},2)}
	//STR0243 - "Determina se deve ou não gerar os logs do planejamento do MRP."
	//STR0244 - "Ao marcar a opção Log de eventos no MRP e confirmar, o sistema exibe uma lista com os produtos e os eventos a eles relacionados."
	//STR0245 - "Os logs de evento do MRP podem ser:"
	//STR0246 - "001, Saldo em estoque inicial menor que zero: Indica produtos que estão com saldo em estoque negativo no início do período de cálculo do MRP. A composição deste saldo em estoque varia de acordo com a parametrização inicial do MRP, podendo considerar saldo de/em terceiros, estoque de segurança etc."
	//STR0247 - "002, Atrasar o documento: Indica documentos que podem ter a data ajustada para atender a uma necessidade em período posterior à data atual do documento, sem causar impactos no planejamento. Este recurso é útil, pois reduz a quantidade de documentos gerados pelo MRP e, conseqüentemente, os saldos em estoque e custos."
	//STR0248 - "003, Adiantar o documento: Indica documentos que podem ter a data ajustada para atender a uma necessidade em período anterior à data atual do documento, sem causar impactos no planejamento. Este recurso é útil, pois reduz a quantidade de documentos gerados pelo MRP e, conseqüentemente, os saldos em estoque e custos."
	//STR0249 - "004, Data de necessidade inválida - Data anterior à database do cálculo: Indica necessidades que se encontram em períodos anteriores ao primeiro período calculado pelo MRP. Para efeito de cálculo, estas necessidades são consideradas no primeiro período do MRP."
	//STR0250 - "005, Data de necessidade inválida - Data posterior à data limite do cálculo: Indica necessidades que se encontram em períodos posteriores ao último período calculado pelo MRP. Para efeito de cálculo, estas necessidades são consideradas no último período do MRP."
	//STR0251 - "006, Documento planejado em atraso: Indica documentos já lançados na base de dados, em que a data de entrega é anterior à database de cálculo do MRP, ou seja, são documentos que estão atrasados, de acordo com a data de entrega informada nestes documentos."
	//STR0252 - "007, Cancelar o documento: Indica documentos lançados na base de dados que não atendem a nenhuma necessidade, dentro do período calculado, e podem ser cancelados para não acumularem estoque."
	//STR0253 - "009, Saldo menor ou igual ao ponto de pedido: Indica produtos que estão com o saldo menor ou igual ao ponto de pedido em cada um dos períodos do cálculo do MRP."

	If !AliasInDic("HWM")
		oCheck6:Disable()
	EndIf

	nLinha += 12
	oCheck7 := TCheckBox():New(nLinha, 65, STR0213, {|u| If(PCount() == 0, soParam["lGeraDoc"], soParam["lGeraDoc"] := u)}, oGroup1, 120, 40, , , , , , , , .T., , , ) //"Gerar documentos ao término do cálculo"
	oCheck7:bHelp := {|| ShowHelpCpo("lGeraDoc", {STR0254 + cCRLF + STR0255 + cCRLF + STR0256}, 2, {""},2)}
	//STR0254 - "Indica se os documentos ( OPs, SCs e empenhos ) serão gerados ao final do cálculo."
	//STR0255 - "Se o processamento ocorrer com o campo marcado irá gerar os documentos ao final do cálculo"
	//STR0256 - "Se o processamento ocorrer com o campo desmarcado os documentos poderão ser gerados pelo PCPA144."

	//Só habilita a opção de rastreabilidade se existir os novos campos (MH_FILDES/ME_FILDES)
	If (_lMEFilDes .And. Len(saFiliais) > 1 ) .Or. Len(saFiliais) < 2
		nLinha += 12
		oCheck8 := TCheckBox():New(nLinha, 65, STR0281, {|u| If(PCount() == 0, soParam["lRastreiaEntradas"], soParam["lRastreiaEntradas"] := u)}, oGroup1, 120, 40, , , , , , , , .T., , , ) //"Gerar Rastreabilidade das Demandas"
		oCheck8:bHelp := {|| ShowHelpCpo("lRastreiaEntradas", {STR0282}, 2, {""}, 2)} //STR0254 - "Indica se os documentos ( OPs, SCs e empenhos ) serão gerados ao final do cálculo."
	EndIf

	//Checkbox para pular para o processamento
	nLinha += 12
	soParam["TELA_1"]["CHECK_OBJETO"] := TCheckBox():New(nLinha, 65, STR0162, {|u| If(PCount() == 0, soParam["TELA_1"]["CHECK_PULAR"], soParam["TELA_1"]["CHECK_PULAR"] := u)}, oGroup1, 90, 40, , , , , , , , .T., , , ) //"Pular para o processamento"
	soParam["TELA_1"]["CHECK_OBJETO"]:bHelp := {|| ShowHelpCpo("CHECK_PULAR", {STR0257 + cCRLF + STR0258}, 2, {""},2)}
	//STR0257 - "Caso esteja marcado, ao clicar em Avançar, o sistema fará o processamento de acordo com os parâmetros cadastrados no setup informado."
	//STR0258 - "Para informar/alterar os parâmetros, basta deixar esse campo desmarcado e clicar em Avançar."
	HabCheck(.F.)

	//Determina foco inicial da tela:
	soTGetCod:SetFocus()

Return Nil

/*/{Protheus.doc} MontaPag2
Monta a segunda página do Wizard: "Períodos"
@author douglas.heydt
@since 05/07/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag2(oPanel)

	Local oTitulo, oDesc
	Local oGroup1
	Local oSay1   , oCombo1, aTpPeriodo
	Local oSay2   , oTGet2
	Local oSay3   , oRadio3, aHorizFirm
	Local oSay4   , oCombo4, aLeadTime
	Local oFont13B, oFont11
	Local nLinha := 40

	//Se foi marcado o check para pular para o processamento, não precisa montar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return
	EndIf

	//Configuração das fontes
	oFont13B := TFont():New("Arial", , -13, , .T.)
	oFont11  := TFont():New("Arial", , -11, , .F.)

	//Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

	aTpPeriodo := {"1=" + STR0026, ; //"Diário"
	               "2=" + STR0027, ; //"Semanal"
	               "3=" + STR0028, ; //"Quinzenal"
	               "4=" + STR0029, ; //"Mensal"
	               "5=" + STR0383  } //"Semestral"

	aHorizFirm := {STR0019, STR0020} //"Sim", "Não"

	aLeadTime  := {"1=" + STR0032, ; //"Sem Calendário"
	               "2=" + STR0031, ; //"Dias Corridos"
				   "3=" + STR0030}   //"Dias Úteis"

	//Texto do cabeçalho
	oTitulo := TSay():New(05, 10, {|| STR0007 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para leitura"
	oDesc 	:= TSay():New(15, 10, {|| STR0008 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados a leitura dos dados."

	oGroup1 := TGroup():New(25, 15, 170, 350, STR0012, oPanel,,, .T.) //"Períodos/Datas"

	oSay1   := TSay():New(nLinha+2, 25, {|| STR0013 }, oGroup1, , oFont11,,,, .T.,,, 40, 20) //"Período:"
	oSay1:SetTextAlign(1, 0)
	oCombo1 := TComboBox():New(nLinha,70,{|u| If(PCount()>0,soParam["periodType"]:=u,soParam["periodType"])}, aTpPeriodo,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["periodType"]')
	oCombo1:bHelp := {|| ShowHelpCpo("periodType", {STR0069 + cCRLF + STR0070 + cCRLF + STR0071 + cCRLF + STR0072 + cCRLF + STR0073 + cCRLF + STR0384}, 2, {""},2)}
	//STR0069 - "Informe o período para cálculo do MRP:"
	//STR0070 - "Diário: realiza o cálculo do MRP diariamente."
	//STR0071 - "Semanal: realiza o cálculo do MRP semanalmente, sempre no primeiro dia válido da semana."
	//STR0072 - "Quinzenal: realiza o cálculo do MRP quinzenalmente, sempre no primeiro dia válido da quinzena."
	//STR0073 - "Mensal: realiza o cálculo do MRP mensalmente, sempre no primeiro dia válido do mês."
	//STR0384 - "Semestral: realiza o cálculo do MRP semestralmente, sempre no primeiro dia válido do semestre."

	nLinha  += 16
	oSay2   := TSay():New(nLinha+2, 25, {|| STR0014 }, oGroup1, , oFont11,,,, .T.,,, 40, 20) //"Nr. de Períodos:"
	oSay2:SetTextAlign(1, 0)
	oTGet2  := TGet():New(nLinha, 70, {|u| If( PCount() > 0, soParam["numberOfPeriods"] := u, soParam["numberOfPeriods"] ) } ,oPanel,50,10,"@ 999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,'soParam["numberOfPeriods"]',,,,.F.,,,,,,,,.T.,.T.)
	oTGet2:bHelp := {|| ShowHelpCpo("numberOfPeriods", {STR0074}, 2, {""},2)}
	//STR0074 - "Informe a quantidade de períodos para considerar no processamento do cálculo do MRP."

	nLinha  += 16
	oSay4   := TSay():New(nLinha+2, 25, {|| STR0018 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Calc. Lead Time:"
	oSay4:SetTextAlign(1, 0)
	oCombo4 := TComboBox():New(nLinha,70,{|u| If(PCount()>0,soParam["leadTime"]:=u,soParam["leadTime"])}, aLeadTime,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["leadTime"]')
	oCombo4:bHelp := {|| ShowHelpCpo("leadTime", {STR0078 + cCRLF + STR0079 + cCRLF + STR0080 + cCRLF + STR0081}, 2, {""},2)}
	//STR0078 - "Informa como deve ser considerado o Lead Time do produto:"
	//STR0079 - "Dias úteis: considera no lead time apenas dias úteis do calendário."
	//STR0080 - "Dias corridos: calculo do lead time considerando dias corridos no calendário."
	//STR0081 - "Sem calendário: desconsidera os calendários do MRP."

	nLinha  += 16
	oSay3   := TSay():New(nLinha+2, 25, {|| STR0017 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Horizonte Firme: "
	oSay3:SetTextAlign(1, 0)
	oRadio3 := TRadMenu():New(nLinha, 70, aHorizFirm , {|u| If(PCount() == 0, soParam["firmHorizon"], soParam["firmHorizon"] := u)}, oGroup1, , , , , , , , 60, 40, , , , .T.)
	oRadio3:bHelp := {|| ShowHelpCpo("firmHorizon", {STR0075 + cCRLF + STR0076 + cCRLF + STR0077 + cCRLF + STR0096}, 2, {""},2)}
	//STR0075 - "Indica se deve realizar bloqueio de necessidades no horizonte firme do produto."
	//STR0076 - "Sim: posterga as necessidades dos produtos dentro do seu horizonte firme para o primeiro período válido posterior ao horizonte firme. Considera os 'Documentos Previstos¹' no cálculo dentro do horizonte firme do produto;"
	//STR0077 - "Não: desconsidera o horizonte firme do produto. Não utiliza os 'Documentos Previstos¹'."
	//STR0096 - 'Documentos Previstos¹: Entradas (Ordem de Produção ou Solicitações de Compras Previstas) e Saídas (Empenhos Previstos)'

	//Determina foco inicial da tela:
	oCombo1:SetFocus()

Return Nil

/*/{Protheus.doc} MontaPag3
Monta a terceira página do Wizard: "Estoque"
@author brunno.costa
@since 15/07/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag3(oPanel)

	Local nLinha := 35
	Local oTitulo, oDesc
	Local oGroup1
	Local oSay1   , oCombo1, aEmTerc
	Local oSay2   , oCombo2, aDeTerc
	Local oSay3   , oCombo3, aRejCQ
	Local oSay4   , oCombo4, aBlqLote
	Local oSay5   , oCombo5, aEstSeg
	Local oSay6   , oCombo6, aPontoPed
	//Local oSay7   , oCombo7, aEstMax
	Local oFont13B, oFont11

	//Se foi marcado o check para pular para o processamento, não precisa montar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return
	EndIf

	//Configuração das fontes
	oFont13B := TFont():New("Arial", , -13, , .T.)
	oFont11  := TFont():New("Arial", , -11, , .F.)

	//Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

	aEmTerc   := {"1=" + STR0036, "2=" + STR0037} //"Soma"   , "Não Soma"
	aDeTerc   := {"1=" + STR0038, "2=" + STR0039} //"Subtrai", "Mantém"
	aRejCQ    := {"1=" + STR0038, "2=" + STR0039} //"Subtrai", "Mantém"
	aBlqLote  := {"1=" + STR0038, "2=" + STR0039} //"Subtrai", "Mantém"
	aEstSeg   := {"1=" + STR0019, "2=" + STR0020} //"Sim"    , "Não"
	aPontoPed := {"1=" + STR0019, "2=" + STR0020} //"Sim"    , "Não"
	//aEstMax   := {"1=" + STR0019, "2=" + STR0020} //"Sim"    , "Não"

	//Texto do cabeçalho
	oTitulo := TSay():New(05, 10, {|| STR0188 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para leitura de estoque e aglutinação"
	oDesc 	:= TSay():New(15, 10, {|| STR0189 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados a leitura de estoque e aglutinação dos resultados."

	oGroup1 := TGroup():New(25, 15, 170, 350, STR0040, oPanel,,, .T.) //"Estoque"

	oSay1   := TSay():New(nLinha+2, 25, {|| STR0041 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Estoque EM Terceiro:"
	oSay1:SetTextAlign(1, 0)
	oCombo1 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["consignedOut"]:=u,soParam["consignedOut"])}, aEmTerc,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["consignedOut"]')
	oCombo1:bHelp := {|| ShowHelpCpo("consignedOut", {STR0048 + cCRLF + STR0049 + cCRLF + STR0050}, 2, {""},2)}
	//STR0048 - "Define se a quantidade nossa EM poder de terceiros será somada ao saldo."
	//STR0049 - "Soma: soma a quantidade nossa EM poder de terceiros ao saldo."
	//STR0050 - "Não Soma: desconsidera a quantidade nossa EM poder de terceiros."

	nLinha := nLinha + 15

	oSay2   := TSay():New(nLinha+2, 25, {|| STR0042 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Estoque DE Terceiro:"
	oSay2:SetTextAlign(1, 0)
	oCombo2 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["consignedIn"]:=u,soParam["consignedIn"])}, aDeTerc,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["consignedIn"]')
	oCombo2:bHelp := {|| ShowHelpCpo("consignedIn", {STR0051 + cCRLF + STR0052 + cCRLF + STR0053}, 2, {""},2)}
	//STR0051 - "Define se a quantidade DE terceiros em nosso poder será subtraída do saldo."
	//STR0052 - "Subtrai: subtrai a quantidade DE terceiros do saldo disponível;"
	//STR0053 - "Mantém: mantém a quantidade DE terceiros em nosso poder no saldo disponível."

	nLinha := nLinha + 15

	oSay3   := TSay():New(nLinha+2, 25, {|| STR0043 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Estoque Rejeitado pelo CQ:"
	oSay3:SetTextAlign(1, 0)
	oCombo3 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["rejectedQuality"]:=u,soParam["rejectedQuality"])}, aRejCQ,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["rejectedQuality"]')
	oCombo3:bHelp := {|| ShowHelpCpo("rejectedQuality", {STR0054 + cCRLF + STR0055 + cCRLF + STR0056}, 2, {""},2)}
	//STR0054 - "Define se a quantidade rejeitada pelo CQ deverá ser subtraída do saldo disponível."
	//STR0055 - "Subtrai: subtrai do saldo disponível;"
	//STR0056 - "Mantém: mantém a quantidade no saldo disponível."

	dbSelectArea("T4V")
	If FieldPos("T4V_SLDBQ") > 0
		nLinha := nLinha + 15

		oSay4   := TSay():New(nLinha+2, 25, {|| STR0044 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Estoque Bloqueado por Lote:"
		oSay4:SetTextAlign(1, 0)
		oCombo4 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["blockedLot"]:=u,soParam["blockedLot"])}, aBlqLote,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["blockedLot"]')
		oCombo4:bHelp := {|| ShowHelpCpo("blockedLot", {STR0057 + cCRLF + STR0055 + cCRLF + STR0056}, 2, {""},2)}
		//STR0057 - "Define se o saldo bloqueado do lote deverá ser subtraído do saldo disponível."
		//STR0055 - "Subtrai: subtrai do saldo disponível;"
		//STR0056 - "Mantém: mantém a quantidade no saldo disponível."
	EndIf

	nLinha := nLinha + 15

	oSay5   := TSay():New(nLinha+2, 25, {|| STR0045 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Considera Estoque de Segurança:"
	oSay5:SetTextAlign(1, 0)
	oCombo5 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["safetyStock"]:=u,soParam["safetyStock"])}, aEstSeg,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["safetyStock"]')
	oCombo5:bHelp := {|| ShowHelpCpo("safetyStock", {STR0058 + cCRLF + STR0059 + cCRLF + STR0060}, 2, {""},2)}
	//STR0058 - "Define se o Estoque de Segurança informado no Cadastro de Produtos, será considerado para o cálculo do MRP."
	//STR0059 - "Sim: Considera o Estoque de Segurança na composição do Saldo em Estoque e na composição das necessidades. "
	//STR0060 - "Não: Não considera o Estoque de Segurança."

	nLinha := nLinha + 15

	oSay6   := TSay():New(nLinha+2, 25, {|| STR0046 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Considera Ponto de Pedido"
	oSay6:SetTextAlign(1, 0)
	oCombo6 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["orderPoint"]:=u,soParam["orderPoint"])}, aPontoPed,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["orderPoint"]')
	oCombo6:bHelp := {|| ShowHelpCpo("orderPoint", {STR0061 + cCRLF + STR0062 + cCRLF + STR0063}, 2, {""},2)}
	//STR0061 - "Define se o Ponto de Pedido informado no Cadastro de Produtos, será considerado para o cálculo do MRP."
	//STR0062 - "Sim: Considera o Ponto de Pedido na composição das necessidades do MRP."
	//STR0063 - "Não: Não considera o Ponto de Pedido."

	//nLinha := nLinha + 15

	//oSay7   := TSay():New(nLinha+2, 25, {|| STR0047 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Considera Estoque Máximo"
	//oSay7:SetTextAlign(1, 0)
	//oCombo7 := TComboBox():New(nLinha,120,{|u| If(PCount()>0,soParam["maxStock"]:=u,soParam["maxStock"])}, aEstMax,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["maxStock"]')
	//oCombo7:bHelp := {|| ShowHelpCpo("maxStock", {STR0064 + cCRLF + STR0065}, 2, {""},2)}
	//STR0064 - "Define se deve ser aplicado o conceito de Estoque Máximo."
	//STR0065 - "Use 'Não' para assumir a necessidade real ou 'Sim' para impedir que o saldo fique acima do Estoque Máximo informado para o produto."

	//Determina foco inicial da tela:
	oCombo1:SetFocus()

Return Nil

/*/{Protheus.doc} MontaPag4
Monta a quarta página do Wizard: "Parâmetros geração de documentos"
@author ricardo.prandi
@since 21/04/2020
@version P12.1.30
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag4(oPanel)

	Local aAglutOP := {}
	Local aAglutSC := {}
	Local aIncOp   := {}
	Local aIncSc   := {}
	Local aTipoOP  := {}
	Local aSugEmp  := {}
	Local aArmPad  := {}

	//Objetos
	Local oDesc
	Local oFont11, oFont13B
	Local oGroup1
	Local oTitulo
	Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay8, oSay9, oSay10
	Local oCombo1, oCombo2, oCombo3, oCombo4, oCombo5, oCombo6, oCombo8
	Local oTGet9, oTGet10

	//Se foi marcado o check para pular para o processamento, não precisa montar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return
	EndIf

	aAglutSC  := {"1=" + STR0185, "2=" + STR0186, "3=" + STR0187} //"Aglutina" , "Não Aglutina*", "Aglutina Somente Demandas"
	aAglutOP  := {"1=" + STR0185, "2=" + STR0186, "3=" + STR0187} //"Aglutina" , "Não Aglutina*", "Aglutina Somente Demandas"
	aIncOp    := {"1=" + STR0218, "2=" + STR0219}                 //"Por item" , "Por número"
	aIncSc    := {"1=" + STR0218, "2=" + STR0219}                 //"Por item" , "Por número"
	aTipoOP   := {"1=" + STR0265, "2=" + STR0266}                 //"Previstos", "Firmes"
	aDocAlc   := {"1=" + STR0019, "2=" + STR0020}                 //"Sim", "Não"
	aSugEmp   := {"1=" + STR0019, "2=" + STR0020}                 //"Sim", "Não"
	aArmPad   := {"1=" + STR0019, "2=" + STR0020}                 //"Sim", "Não"

	//Configuração das fontes
	oFont13B := TFont():New("Arial", , -13, , .T.)
	oFont11  := TFont():New("Arial", , -11, , .F.)

	//Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

	//Texto do cabeçalho
	oTitulo := TSay():New(05, 10, {|| STR0220}, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para geração dos documentos"
	oDesc 	:= TSay():New(15, 10, {|| STR0221}, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados à geração dos documentos ao final do processamento."

	oGroup1 := TGroup():New(25, 15, 170, 350, STR0217, oPanel,,, .T.) //"Seleção"

	oSay1   := TSay():New(37, 25, {|| STR0259}, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Incrementa Solicitação de Compras:"
	oSay1:SetTextAlign(1, 0)
	oCombo1 := TComboBox():New(35, 120,{|u| If(PCount()>0,soParam["purchaseRequestNumber"]:=u,soParam["purchaseRequestNumber"])}, aIncSc,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["purchaseRequestNumber"]')
	oCombo1:bHelp := {|| ShowHelpCpo("purchaseRequestNumber", {STR0260 + cCRLF + STR0261 + cCRLF + STR0262}, 2, {""},2)}
	//STR0260 - "Define como deve ser efetuado o incremento da numeração das solicitações de compras geradas pelo MRP. As opções disponíveis são:"
	//STR0261 - "Por Item, incrementa o item da SC anterior mantendo o mesmo numero de SC."
	//STR0262 - "Por Número, incrementa o número da SC anterior."

	oSay2   := TSay():New(52, 25, {|| STR0222}, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Incrementa Ordem de Produção:"
	oSay2:SetTextAlign(1, 0)
	oCombo2 := TComboBox():New(50, 120,{|u| If(PCount()>0,soParam["productionOrderNumber"]:=u,soParam["productionOrderNumber"])}, aIncOp,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["productionOrderNumber"]')
	oCombo2:bHelp := {|| ShowHelpCpo("productionOrderNumber", {STR0230 + cCRLF + STR0231 + cCRLF + STR0232}, 2, {""},2)}
	//STR0230 - "Define como deve ser efetuado o incremento da numeração das ordens de produção geradas pelo MRP. As opções disponíveis são:"
	//STR0231 - "Por Item, incrementa o item da OP anterior mantendo o mesmo numero de OP."
	//STR0232 - "Por Número, incrementa o número da OP anterior."

	oSay3   := TSay():New(67, 25, {|| STR0191 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Aglutina Solicitação de Compras:"
	oSay3:SetTextAlign(1, 0)
	oCombo3 := TComboBox():New(65,120,{|u| If(PCount()>0,soParam["consolidatePurchaseRequest"]:=u,soParam["consolidatePurchaseRequest"])}, aAglutSC,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["consolidatePurchaseRequest"]')
	oCombo3:bHelp := {|| ShowHelpCpo("consolidatePurchaseRequest", {STR0192 + cCRLF + STR0193 + cCRLF + STR0194 + cCRLF + STR0195}, 2, {""},2)}
	//STR0192 - "Define se as Solicitações de Compras geradas pelo MRP serão aglutinadas por Produto + Período."
	//STR0193 - "Aglutina: Aglutina as solicitações de compras por Produto + Período."
	//STR0194 - "Não Aglutina*: Não aglutina as solicitações de compras. O cálculo desaglutinado exige maior processamento, podendo ocasionar lentidão."
	//STR0195 - "Aglutina Somente Demandas: aglutina somente as solicitações de compras geradas diretamente por de demanda do MRP."

	oSay4   := TSay():New(82, 25, {|| STR0223}, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Aglutina Ordem de Produção:"
	oSay4:SetTextAlign(1, 0)
	oCombo4 := TComboBox():New(80,120,{|u| If(PCount()>0,soParam["consolidateProductionOrder"]:=u,soParam["consolidateProductionOrder"])}, aAglutOP,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["consolidateProductionOrder"]')
	oCombo4:bHelp := {|| ShowHelpCpo("consolidateProductionOrder", {STR0196 + cCRLF + STR0197 + cCRLF + STR0198 + cCRLF + STR0199}, 2, {""},2)}
	//STR0196 - "Define se as Ordens de Produção geradas pelo MRP serão aglutinadas por Produto + Período."
	//STR0197 - "Aglutina: Aglutina as ordens de produção por Produto + Período."
	//STR0198 - "Não Aglutina*: Não aglutina as ordens de produção. O cálculo desaglutinado exige maior processamento, podendo ocasionar lentidão."
	//STR0199 - "Aglutina Somente Demandas: aglutina somente as ordens de produção geradas diretamente por de demanda do MRP."

	oSay5   := TSay():New(97, 25, {|| STR0263}, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Gerar Documentos:"
	oSay5:SetTextAlign(1, 0)
	oCombo5 := TComboBox():New(95,120,{|u| If(PCount()>0,soParam["productionOrderType"]:=u,soParam["productionOrderType"])}, aTipoOP,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["productionOrderType"]')
	oCombo5:bHelp := {|| ShowHelpCpo("productionOrderType", {STR0264}, 2, {""},2)}
	//STR0264 - "Define o tipo dos documentos que serão gerados. As opções disponíveis são: Previstos,Firmes"

	oSay7   := TSay():New(112, 25, {|| STR0370}, oGroup1, , oFont11,,,, .T.,,, 90, 20) //"Gerar Documentos com Alçada:"
	oSay7:SetTextAlign(1, 0)
	oCombo7 := TComboBox():New(110,120,{|u| If(PCount()>0,soParam["lDocAlcada"]:=u,soParam["lDocAlcada"])}, aDocAlc,100,13,oGroup1,,{||.T.},,,,.T.,,,,,,,,,'soParam["lDocAlcada"]')
	oCombo7:bHelp := {|| ShowHelpCpo("lDocAlcada", {STR0371}, 2, {""},2)}
	//STR0XXX - "Define se gerará a alçada de aprovação para as Solicitações de Compras que serão geradas."

	If SuperGetMV("MV_RASTRO",.F.,"N") == "S" .OR. SuperGetMV("MV_LOCALIZ",.F.,"N") == "S"
		oSay6   := TSay():New(127, 15, {|| STR0268 + ":"}, oGroup1, , oFont11,,,, .T.,,, 100, 20) //"Sugere Lote e Endereço a Empenhar:"
		oSay6:SetTextAlign(1, 0)
		oCombo6 := TComboBox():New(125,120,{|u| If(PCount()>0,soParam["allocationSuggestion"]:=u,soParam["allocationSuggestion"])}, aSugEmp,100,13,oGroup1,,{|| HabArm(oPanel:oWnd,oCombo8,oTGet9,oTGet10,.F.)},,,,.T.,,,,,,,,,'soParam["allocationSuggestion"]')
		oCombo6:bHelp := {|| ShowHelpCpo("allocationSuggestion", {STR0267}, 2, {""},2)}
		//STR0267 - "Define se irá sugerir os lotes e endereços dos empenhos."

		oSay8   := TSay():New(142, 25, {|| STR0390 }, oGroup1, , oFont11,,,, .T.,,, 90, 20) //STR0390 - "Considera Só Armazém Padrão:"
		oSay8:SetTextAlign(1, 0)
		oCombo8 := TComboBox():New(140,120,{|u| If(PCount()>0,soParam["armazemPad"]:=u,soParam["armazemPad"])}, aArmPad,100,13,oGroup1,,{|| HabArm(oPanel:oWnd,oCombo8,oTGet9,oTGet10,.F.)},,,,.T.,,,,,,,,,'soParam["armazemPad"]')
		oCombo8:bHelp := {|| ShowHelpCpo("armazemPad", {STR0385 + cCRLF + STR0386 + cCRLF + STR0387}, 2, {""},2)}
		//STR0385 - "Define se o empenho dos Produtos será gerado somente para o Armazém Padrão no cálculo do MRP."
		//STR0386 - "Sim: Considera somente Armazém Padrão."
		//STR0387 - "Não: Considera intervalo de Armazéns."

		oSay9   := TSay():New(157, 75, {|| STR0391 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //STR0391 - "Armazém de:"
		oSay9:SetTextAlign(1, 0)
		oTGet9 := TGet():New(155, 120, {|u| If( PCount() > 0, soParam["armazemDe"] := u, soParam["armazemDe"] ) } ,oPanel,50,10,"@!",{|| vldArm("armazemDe") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["armazemDe"],,,,.F.)
		oTGet9:bHelp := {|| ShowHelpCpo("armazemDe", {STR0388}, 2, {""},2)} //STR0388 - "Define o armazém inicial a ser utilizado no processamento."
		oTGet9:cF3   := "NNR"

		oSay10   := TSay():New(157, 175, {|| STR0392 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //STR0392 - "Armazém até:"
		oSay10:SetTextAlign(1, 0)
		oTGet10 := TGet():New(155, 220, {|u| If( PCount() > 0, soParam["armazemAte"] := u, soParam["armazemAte"] ) } ,oPanel,50,10,"@!",{|| vldArm("armazemAte") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["armazemAte"],,,,.F.)
		oTGet10:bHelp := {|| ShowHelpCpo("armazemAte", {STR0389}, 2, {""},2)} //STR0389 - "Define o armazém final a ser utilizado no processamento."
		oTGet10:cF3   := "NNR"

		HabArm(oPanel:oWnd,oCombo8,oTGet9,oTGet10,.F.)

	EndIf

	//Determina foco inicial da tela:
	oGroup1:SetFocus()

Return Nil

/*/{Protheus.doc} MontaPag5
Monta a quinta página do Wizard: "Seleção"
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag5(oPanel)

	Local oTitulo , oDesc
	Local oGroup1 , oGroup2 , oGroup3
	Local oSay1   , oTGet11 , oTGet12 , oTButton1
	Local oSay2   , oTGet21 , oTGet22 , oTButton2
	Local oSay3   , oTGet31 , oTGet32 , oTButton3
	Local oSay4   , oTGet41 , oTGet42 , oTButton4
	Local oSay5   , oTGet51 , oTGet52 , oTButton5
	Local oSay61  , oTGet61 , oTGet62 , oTButton6
	Local oSay7   , oCombo7, aPrevistos
	Local oCheck71, oCheck72, oCheck73, oCheck74, oCheck75
	Local oCheck82, oCheck83, oCheck84
	Local oFont13B, oFont11
	Local nLinha

	aPrevistos := {"1=" + STR0214,; //Exclui
	               "2=" + STR0215,; //Não Exclui
	               "3=" + STR0216 } //Entra no MRP

	//Se foi marcado o check para pular para o processamento, não precisa montar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return
	EndIf

	//Configuração das fontes
	oFont13B := TFont():New("Arial", , -13, , .T.)
	oFont11  := TFont():New("Arial", , -11, , .F.)

	//Desabilita tecla ESC
	oPanel:oWnd:lEscClose := .F.

	//Texto do cabeçalho
	oTitulo := TSay():New(05, 10, {|| STR0007 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Parâmetros para leitura"
	oDesc 	:= TSay():New(15, 10, {|| STR0008 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Informe os parâmetros relacionados a leitura dos dados."

	oGroup1 := TGroup():New(25, 15, 115, 350, STR0117, oPanel,,, .T.) //"Seleção"

	nLinha  := 34

	oSay1   := TSay():New((nLinha+2),  25, {|| STR0118 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Produto:"
	oSay1:SetTextAlign(1, 0)
	oTGet11 := TGet():New((nLinha  ),  70, {|u| If(PCount() == 0, soParam["products"]["CODIGO"], soParam["products"]["CODIGO"] := u)}, oGroup1, 70, 10, PesqPict("SB1","B1_COD"),{|| vldSeletiv("products") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["products"]["CODIGO"],,,,.T.)
	oTGet11:bHelp := {|| ShowHelpCpo("products", {STR0151 + cCRLF + STR0152}, 2, {""},2)}
	//STR0151 - "Define um filtro com os produtos a serem considerados no processamento do MRP, ou seja, considera documentos, demandas e políticas de estoque para o cálculo das necessidades dos produtos marcados e todos os componentes de níveis inferiores da estrutura."
	//STR0152 - "Para processar sem esse filtro (completo), basta deixar o campo em branco."
	oTGet12 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["products"]["DESCRICAO"], soParam["products"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["products"]["DESCRICAO"]',,,,.F.)
	oTGet12:Disable()
	oTButton1 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("products") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	nLinha  := nLinha + 13

	oSay2   := TSay():New((nLinha+2),  25, {|| STR0119 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Grupo Material:"
	oSay2:SetTextAlign(1, 0)
	oTGet21 := TGet():New((nLinha  ),  70, {|u| If(PCount() == 0, soParam["productGroups"]["CODIGO"], soParam["productGroups"]["CODIGO"] := u)}, oGroup1, 70, 10, PesqPict("SBM","BM_GRUPO"),{|| vldSeletiv("productGroups") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["productGroups"]["CODIGO"],,,,.T.)
	oTGet21:bHelp := {|| ShowHelpCpo("productGroups", {STR0153 + cCRLF + STR0152}, 2, {""},2)}
	//STR0153 - "Define um filtro com os grupos de materiais a serem considerados no processamento do MRP, ou seja, considera para o cálculo das necessidades somente os documentos, demandas e políticas de estoque dos produtos vinculados aos grupos marcados, gerando os devidos empenhos de componentes de outros grupos de produtos."
	//STR0152 - "Para processar sem esse filtro (completo), basta deixar o campo em branco."
	oTGet22 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["productGroups"]["DESCRICAO"], soParam["productGroups"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["productGroups"]["DESCRICAO"]',,,,.F.)
	oTGet22:Disable()
	oTButton2 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("productGroups") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	nLinha  := nLinha + 13
	oSay3   := TSay():New((nLinha+2),  25, {|| STR0120 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Tipo Material:"
	oSay3:SetTextAlign(1, 0)
	oTGet31 := TGet():New((nLinha  ),  70, {|u| If(PCount() == 0, soParam["productTypes"]["CODIGO"], soParam["productTypes"]["CODIGO"] := u)}, oGroup1, 70, 10, "@! XX",{|| vldSeletiv("productTypes") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["productTypes"]["CODIGO"],,,,.T.)
	oTGet31:bHelp := {|| ShowHelpCpo("productTypes", {STR0154 + cCRLF + STR0152}, 2, {""},2)}
	//STR0154 - "Define um filtro com os tipos de materiais a serem considerados no processamento do MRP, ou seja, considera para o cálculo das necessidades somente as demandas e políticas de estoque dos produtos vinculados aos tipos de materiais marcados, gerando os devidos empenhos de componentes de outros tipos de materiais."
	//STR0152 - "Para processar sem esse filtro (completo), basta deixar o campo em branco."
	oTGet32 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["productTypes"]["DESCRICAO"], soParam["productTypes"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["productTypes"]["DESCRICAO"]',,,,.F.)
	oTGet32:Disable()
	oTButton3 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("productTypes") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	nLinha  := nLinha + 13
	oSay4   := TSay():New((nLinha+2),  25, {|| STR0121 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Documento:"
	oSay4:SetTextAlign(1, 0)
	oTGet41 := TGet():New((nLinha  ),  70, {|u| If(PCount() == 0, soParam["documents"]["CODIGO"], soParam["documents"]["CODIGO"] := u)}, oGroup1, 70, 10, PesqPict("SVR","VR_DOC"),{|| vldSeletiv("documents") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["documents"]["CODIGO"],,,,.T.)
 	oTGet41:bHelp := {|| ShowHelpCpo("documents", {STR0155 + cCRLF + STR0152}, 2, {""},2)}
	//STR0155 - "Define um ou mais documentos a serem utilizados no processamento."
	//STR0152 - "Para processar sem esse filtro (completo), basta deixar o campo em branco."
	oTGet42 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["documents"]["DESCRICAO"], soParam["documents"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["documents"]["DESCRICAO"]',,,,.F.)
	oTGet42:Disable()
	oTButton4 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("documents") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	nLinha  := nLinha + 13
	oSay5   := TSay():New((nLinha+2),  25, {|| STR0122 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Armazém:"
	oSay5:SetTextAlign(1, 0)
	oTGet51 := TGet():New((nLinha  ),  70, {|u| If(PCount() == 0, soParam["warehouses"]["CODIGO"], soParam["warehouses"]["CODIGO"] := u)}, oGroup1, 70, 10, PesqPict("NNR","NNR_CODIGO"),{|| vldSeletiv("warehouses") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["warehouses"]["CODIGO"],,,,.T.)
	oTGet51:bHelp := {|| ShowHelpCpo("warehouses", {STR0156 + cCRLF + STR0152}, 2, {""},2)}
	//STR0156 - "Define um ou mais armazéns a serem utilizados no processamento."
	//STR0152 - "Para processar sem esse filtro (completo), basta deixar o campo em branco."
	oTGet52 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["warehouses"]["DESCRICAO"], soParam["warehouses"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["warehouses"]["DESCRICAO"]',,,,.F.)
	oTGet52:Disable()
	oTButton5 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("warehouses") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )

	nLinha  := nLinha + 13
	If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
		oSay61  := TSay():New((nLinha+2), 25, {|| STR0225 }, oGroup1, , oFont11, , , , .T., , , 40, 20) //"Demanda:"
		oSay61:SetTextAlign(1, 0)
		oTGet61 := TGet():New((nLinha  ), 70, {|u| If(PCount() == 0, soParam["demandCodes"]["CODIGO"] , soParam["demandCodes"]["CODIGO"] := u)}, oGroup1, 70, 10, "@!",{|| vldSeletiv("demandCodes") },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,soParam["demandCodes"]["CODIGO"] ,,,,.T.)
		oTGet61:bHelp := {|| ShowHelpCpo("demandCodes", {STR0226}, 2, {""},2)} //"Indica um ou mais códigos de demanda para filtro."
		oTGet62 := TGet():New((nLinha  ), 140, {|u| If(PCount() == 0, soParam["demandCodes"]["DESCRICAO"], soParam["demandCodes"]["DESCRICAO"] := u)}, oGroup1, 130, 10,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T./*ReadOnly*/,.F.,,'soParam["demandCodes"]["DESCRICAO"]',,,,.F.)
		oTGet62:Disable()
		oTButton6 := TButton():New((nLinha), 270, "?", oGroup1, { || AbreFiltro("demandCodes") }, 8,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	EndIf

	//Checboxs referente ao Tipo de Demanda
	oGroup2  := TGroup():New(120, 15, 150, 350, STR0126, oPanel,,, .T.) //"Tipo Demanda"
	nLinha   := nLinha + 30
	oCheck71 := TCheckBox():New((nLinha),  30, STR0127, {|u| If(PCount() == 0, soParam["demandType"]["PEDIDO_VENDA"], soParam["demandType"]["PEDIDO_VENDA"] := u)}, oGroup2, 90, 40, , , , , , , , .T., , , ) //"Pedido de Venda"
	oCheck71:bHelp := {|| ShowHelpCpo("demandType", {STR0241 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0241 - "Define os tipos de demandas a serem considerados no processamento do MRP:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	oCheck72 := TCheckBox():New((nLinha), 135, STR0128, {|u| If(PCount() == 0, soParam["demandType"]["PREV_VENDAS" ], soParam["demandType"]["PREV_VENDAS" ] := u)}, oGroup2, 90, 40, , , , , , , , .T., , , ) //"Previsão de Vendas"
	oCheck72:bHelp := {|| ShowHelpCpo("demandType", {STR0241 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0241 - "Define os tipos de demandas a serem considerados no processamento do MRP:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	oCheck73 := TCheckBox():New((nLinha), 225, STR0129, {|u| If(PCount() == 0, soParam["demandType"]["PLANO_MESTRE"], soParam["demandType"]["PLANO_MESTRE"] := u)}, oGroup2, 90, 40, , , , , , , , .T., , , ) //"Plano Mestre"
	oCheck73:bHelp := {|| ShowHelpCpo("demandType", {STR0241 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0241 - "Define os tipos de demandas a serem considerados no processamento do MRP:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	nLinha   := nLinha + 11
	oCheck74 := TCheckBox():New((nLinha),  30, STR0130, {|u| If(PCount() == 0, soParam["demandType"]["EMP_PROJETO" ], soParam["demandType"]["EMP_PROJETO" ] := u)}, oGroup2, 90, 40, , , , , , , , .T., , , ) //"Empenhos de Projeto"
	oCheck74:bHelp := {|| ShowHelpCpo("demandType", {STR0241 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0241 - "Define os tipos de demandas a serem considerados no processamento do MRP:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	oCheck75 := TCheckBox():New((nLinha), 135, STR0131, {|u| If(PCount() == 0, soParam["demandType"]["MANUAL"      ], soParam["demandType"]["MANUAL"      ] := u)}, oGroup2, 90, 40, , , , , , , , .T., , , ) //"Manual"
	oCheck75:bHelp := {|| ShowHelpCpo("demandType", {STR0241 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0241 - "Define os tipos de demandas a serem considerados no processamento do MRP:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	//Checboxs referente ao Tipo de OP/SC
	oGroup3  := TGroup():New(155, 15, 175, 350, STR0132, oPanel,,, .T.) //"OP/SC"
	nLinha   := nLinha + 20

	oSay7    := TSay():New(nLinha+3, 10, {|| STR0133}, oGroup3, , oFont11,,,, .T.,,, 40, 20) //"Previstos:"
	oSay7:SetTextAlign(1, 0)
	oCombo7  := TComboBox():New(nLinha    , 55,{|u| If(PCount()>0,soParam["documentType"]["PREVISTOS"]:=u,soParam["documentType"]["PREVISTOS"])}, aPrevistos,60,13,oGroup3,,{||.T.},,,,.T.,,,,,,,,,'soParam["documentType"]["PREVISTOS"]')
	oCombo7:bHelp := {|| ShowHelpCpo("documentType", {STR0233 + cCRLF + STR0234 + cCRLF + STR0235 + cCRLF + STR0236 + cCRLF + STR0237 + cCRLF + STR0238}, 2, {""},2)}
	//STR0233 - "Define quais Ordens de Produção e Solicitações de Compra devem ser consideradas no processamento do MRP."
	//STR0234 - "Só serão selecionadas as OPs e SCs que estiverem de acordo com as opções marcadas:"
	//STR0235 - "Previstas: possui as opções de seleção a seguir:"
	//STR0236 - "Exclui: O programa irá excluir os documentos planejados e esses documentos não serão considerados no cálculo do MRP."
	//STR0237 - "Não exclui: O programa não irá excluir as planejadas e esses documentos não serão considerados no cálculo do MRP."
	//STR0238 - "Entra no MRP: O programa não irá excluir as planejadas e esses documentos irão entrar no cálculo do MRP normalmente."

	oCheck82 := TCheckBox():New((nLinha+3), 135, STR0134, {|u| If(PCount() == 0, soParam["documentType"]["SUSPENSOS"], soParam["documentType"]["SUSPENSOS"] := u)}, oGroup3, 90, 40, , , , , , , , .T., , , ) //"Suspensas"
	oCheck82:bHelp := {|| ShowHelpCpo("documentType", {STR0233 + cCRLF + STR0234 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0233 - "Define quais Ordens de Produção e Solicitações de Compra devem ser consideradas no processamento do MRP."
	//STR0234 - "Só serão selecionadas as OPs e SCs que estiverem de acordo com as opções marcadas:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	oCheck83 := TCheckBox():New((nLinha+3), 205, STR0135, {|u| If(PCount() == 0, soParam["documentType"]["SACRAMENTADOS"], soParam["documentType"]["SACRAMENTADOS"] := u)}, oGroup3, 90, 40, , , , , , , , .T., , , ) //"Sacramentadas"
	oCheck83:bHelp := {|| ShowHelpCpo("documentType", {STR0233 + cCRLF + STR0234 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
	//STR0233 - "Define quais Ordens de Produção e Solicitações de Compra devem ser consideradas no processamento do MRP."
	//STR0234 - "Só serão selecionadas as OPs e SCs que estiverem de acordo com as opções marcadas:"
	//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
	//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"

	If !Empty(GetSx3Cache("T4T_APROV","X3_TAMANHO"))
		oCheck84 := TCheckBox():New((nLinha+3), 285, STR0398, {|u| If(PCount() == 0, soParam["documentType"]["REJEITADOS"], soParam["documentType"]["REJEITADOS"] := u)}, oGroup3, 90, 40, , , , , , , , .T., , , ) //"Rejeitadas"
		oCheck84:bHelp := {|| ShowHelpCpo("documentType", {STR0233 + cCRLF + STR0234 + cCRLF + STR0239 + cCRLF + STR0240}, 2, {""},2)}
		//STR0233 - "Define quais Ordens de Produção e Solicitações de Compra devem ser consideradas no processamento do MRP."
		//STR0234 - "Só serão selecionadas as OPs e SCs que estiverem de acordo com as opções marcadas:"
		//STR0239 - "Marcado: O programa irá considerar os documentos no MRP"
		//STR0240 - "Desmarcado: O programa não irá considerar os documentos no MRP"
	EndIf

	//Determina foco inicial da tela:
	oGroup1:SetFocus()

Return Nil

/*/{Protheus.doc} MontaPag6
Monta a sexta página do Wizard: "Execução"
@author brunno.costa
@since 15/07/2019
@version P12
@param 01 oPanel, object, painel a serem adicionados os componentes da página
@return Nil
/*/
Static Function MontaPag6(oPanel, oStepWiz)
	Local cText      := ""
	Local lSchdl     := oPanel == Nil .and. oStepWiz == Nil
	Local nLinha     := 0
	Local nAjustaBrw := 0
	Local nMemoria	 := 0
	Local nSecTela   := 0
	Local oBrwWiz    := Nil
	Local oFont11    := Nil
	Local oFont11B   := Nil
	Local oFont13    := Nil
	Local oFont13B   := Nil
	Local oStatus    := MrpDados_Status():New(soParam["ticket"])
	Local oTitulo    := Nil
	Local oDesc      := Nil
	Local oNumTicket := Nil
	Local oAvisoLog  := Nil

	If !lSchdl
		//Configuração das fontes
		oFont13B := TFont():New("Arial", , -13, , .T.)
		oFont13  := TFont():New("Arial", , -13, , .F.)
		oFont11  := TFont():New("Arial", , -11, , .F.)
		oFont11B := TFont():New("Arial", , -11, , .T.)

		//Seta tempo de seleção de parametros em tela
		nSecTela := oStatus:getStatus("tempo_selecao_parametros_tela")
		oStatus:setStatus("tempo_selecao_parametros_tela", MicroSeconds() - nSecTela)
		oStatus:setStatus("tempo_espera", MicroSeconds())

		//Oculta o botão "Voltar" da tela de processamento
		oStepWiz:oUiStepWizard:SetPrevVisibility(.F.)
	EndIf

	//Trata os parâmetros (checkboxs)
	TrataParam(.F.)

	If ExecutaMRP() //Executa solicitação de cálculo do MRP
		If !lSchdl
			//Desabilita tecla ESC
			oPanel:oWnd:lEscClose := .F.

			//Texto do cabeçalho
			oTitulo    := TSay():New(05,  10, {|| STR0097 }, oPanel, , oFont13B, , , , .T., , , 290, 20) //"Executando... aguarde."
			oDesc      := TSay():New(15,  10, {|| STR0098 }, oPanel, , oFont11 , , , , .T., , , 290, 20) //"Acompanhe o status de cada uma das etapas da execução:"
			oNumTicket := TSay():New(05, 250, {|| STR0181 + soParam["ticket"] + " "}, oPanel, , oFont13 , , , , .T., , , 100, 20) //"Ticket "
			oNumTicket:SetTextAlign(1, 0)

			If scLogMrp == "1"
				oAvisoLog  := TSay():New(25,  10, {|| STR0381 }, oPanel, , oFont11B , , , , .T., CLR_HRED, CLR_WHITE, 350, 20) //"ATENÇÃO! O parâmetro MV_LOGMRP está ativado. O desempenho será prejudicado."
				nAjustaBrw += 6
			EndIf
		EndIf

		//Vetor com elementos do Browse
		If slSincroni
			nLinha++
			__SINCRONI := nLinha
			aAdd(saStatus, {soAtual, STR0205 + ' 0%', STR0091}) //"Sincronização dos Dados:" "Pendente"
		EndIf

		nLinha++
		__NIVEIS := nLinha
		aAdd(saStatus, {soNO, STR0084, STR0091}) //"Recálculo dos Níveis de Estrutura" "Pendente"

		If soParam["documentType"]["PREVISTOS"] == "1"
			nLinha++
			__EXCLUSAO := nLinha
			aAdd(saStatus, {soNO, STR0203 + ' 0%', STR0091}) //"Exclusão de Documentos Previstos:" "Pendente"
		EndIf

		nLinha++
		__CARGA := nLinha
		aAdd(saStatus, {soNO, STR0083 + ' 0%', STR0091}) //"Carga dos Dados em Memória:" "Pendente"

		nLinha++
		__CALCULO := nLinha
		aAdd(saStatus, {soNO, STR0085 + ' 0%', STR0091}) //"Cálculo do MRP:" "Pendente" "Pendente"

		If soParam["eventLog"]
			nLinha++
			__LOG_EVEN := nLinha
			aAdd(saStatus, {soNO, STR0229 + ' 0%', STR0091}) //"Geração do Log de Eventos:" "Pendente"
		EndIf

		nLinha++
		__PERSIST := nLinha
		aAdd(saStatus, {soNO, STR0086, STR0091}) //"Gravação dos Resultados em Disco" "Pendente"

		If soParam["lRastreiaEntradas"]
			nLinha++
			__GERARAST := nLinha
			aAdd(saStatus, {soNO, I18N(STR0342, {"0%"}), STR0091}) //"Geração da Rastreabilidade de Demandas 0%" "Pendente"
		EndIf

		If soParam["lGeraDoc"]
			nLinha++
			__GERA_DOC := nLinha
			aAdd(saStatus, {soNO, STR0212 + ' 0%', STR0091}) //"Geração de Documentos:" "Pendente"

			If AllTrim(soParam["lDocAlcada"]) == "1"
				nLinha++
				__DOC_ALCA := nLinha
				aAdd(saStatus, {soNO, STR0372 + ' 0%', STR0091}) //"Geração das alçadas dos documentos:" "Pendente"
			EndIf

			If soParam["lRastreiaEntradas"] .And. FindFunction("P145DelRas")
				nLinha++
				__RAST_DOC := nLinha
				aAdd(saStatus, {soNO, STR0369 + ": 0%", STR0091}) //"Rastreabilidade documentos: 0%" "Pendente"
			EndIf

			If AllTrim(soParam["allocationSuggestion"]) == "1"
				nLinha++
				__SUG_LOTE := nLinha
				aAdd(saStatus, {soNO, STR0269 + ' 0%', STR0091}) //"Sugestão de Lote e Endereço nos Empenhos:" "Pendente"
			EndIf
		EndIf

		If !soParam["lGeraDoc"]
			If soParam["documentType"]["PREVISTOS"] <> "1"
				slIntgMES := .F.
			EndIf
			slIntgSFC := .F.
		EndIf

		//Se usa MES lite e não está gerando documento firme, desativa a integração.
		If slIntgMES .And. slMESLite .And. ;
		   (!soParam["lGeraDoc"] .Or. (soParam["lGeraDoc"] .And. soParam["productionOrderType"] <> "2"))
			slIntgMES := .F.
		EndIf

		If slIntgMES
			nLinha++
			__INTG_MES := nLinha
			aAdd(saStatus, {soNO, STR0304, STR0091}) //"Integração com o MES" "Pendente"

			If soParam["lGeraDoc"]
				PutGlbValue(soParam["ticket"] + "STATUS_MES_INCLUSAO", "PEN")
			EndIf
		EndIf

		If slIntgSFC
			nLinha++
			__INTG_SFC := nLinha
			aAdd(saStatus, {soNO, STR0309, STR0091}) //"Integração com o SFC" "Pendente"

			If soParam["lGeraDoc"]
				PutGlbValue(soParam["ticket"] + "STATUS_SFC_INCLUSAO", "PEN")
			EndIf
		EndIf

		If slIntgQIP .And. !soParam["lGeraDoc"] .Or. soParam["productionOrderType"] <> "2"
			slIntgQIP := .F.
		EndIf

		If slIntgQIP
			nLinha++
			__INTG_QIP := nLinha
			aAdd(saStatus, {soNO, STR0310, STR0091}) //"Integração com o QIP" "Pendente"
			PutGlbValue(soParam["ticket"] + "STATUS_QIP_INCLUSAO", "PEN")
		EndIf

		nMemoria   := GetMemory()
		scPicoMemo := cValToChar(nMemoria)

		cText := STR0322 // "Memória: "
		cText += i18n(STR0323, {cValToChar(nMemoria)}) // "Em uso: #1[memoriaEmUso]# MB"
		cText += "; " + i18n(STR0373, {scPicoMemo}) // "Pico: #1[picoMemoria]# MB"
		If _nMemLimit > 0
			cText += "; " + i18n(STR0374, {cValToChar(_nMemLimit)}) // "Limite: #1[limiteMemoria]# MB"
		EndIf
		cText += "."

		nLinha++
		__MEMORIA := nLinha
		aAdd(saStatus, {soLA, cText, STR0324}) // "Verificando"

		If !lSchdl
			oBrwWiz := TSBrowse():New(30+nAjustaBrw, 10, 344, 140, oPanel, , 16, , 1)
			oBrwWiz:AddColumn( TCColumn():New(''     ,,,{|| },{|| },,20 , .T.) )
			oBrwWiz:AddColumn( TCColumn():New(STR0092,,,{|| },{|| },,200, .F.) ) //'Processo'
			oBrwWiz:AddColumn( TCColumn():New(STR0093,,,{|| },{|| },,50 , .F.) ) //'Status'
			oBrwWiz:SetArray(saStatus)
		EndIf

		//Se foi informado o código do setup, grava os parâmetros na tabela HW2
		If !Empty(soParam["TELA_1"]["HW2_CODIGO"])
			GravaHW2()
		EndIf

		//Limpa da memória os objetos multivalorados
		LimpaMulti()

		If !lSchdl
			soTimer := TTimer():New(500, {|| UpdStatus(oBrwWiz, oTitulo, oDesc, oAvisoLog) }, oPanel:oWnd ) //Disparo será a cada meio segundo
			soTimer:Activate()
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} ExecutaMRP
Executa solicitação de cálculo do MRP
@author brunno.costa
@since 31/07/2019
@version P12
@param 01 - oParametros, objeto, objeto Json de parâmetros
@return lReturn, lógico, indica se obteve exito na requisição
/*/
Static Function ExecutaMRP(oParametros)

	Local aReturn    := {}
	Local aNoPostFld := {"endDate","endTime","dateEndLoadInitialMemory",;
	                     "endTimeLoadInitialMemory","dateEndLoadMemory","endTimeLoadMemory",;
	                     "cancellationDate","cancellationTime"}
	Local lReturn    := .T.
	Local nIndex     := 0
	Local nTotal     := Len(aNoPostFld)
	Local oBody      := JsonObject():New()
	Local oJsonRet   := JsonObject():New()
	Local oStatus    := Nil
	Local oLogs      := Nil

	Default oParametros := soParam

	scErrorUID  := Iif(scErrorUID == Nil, "PCPA712_MRP_" + soParam["ticket"], scErrorUID)
	soPCPError  := Iif(soPCPError == Nil, PCPMultiThreadError():New(scErrorUID, .T.), soPCPError)

	//Atribui parãmetro de setup para envio ao MRP
	soParam["setupCode"]        := soParam["TELA_1"]["HW2_CODIGO"]
	soParam["setupDescription"] := soParam["TELA_1"]["HW2_DESCRI"]

	//Forca Desabilitar Sugestao de Lote e Endereco Salva em Setup de Configuracao com "1-Sim"
	If AllTrim(soParam["allocationSuggestion"]) == "1" .AND. SuperGetMV("MV_RASTRO",.F.,"N") == "N" .AND. SuperGetMV("MV_LOCALIZ",.F.,"N") == "N"
		soParam["allocationSuggestion"] := "2"
	EndIf

	//Inicia a thread de exclusão dos documentos previstos
	If soParam["documentType"]["PREVISTOS"] == "1"
		oLogs := MrpDados_Logs():New()

		soPCPError:startJob("P712ExcPre", GetEnvServer(), .F., ;
		                    cEmpAnt, cFilAnt                 , ;
		                    soParam["ticket"]                , ;
		                    soParam["firmHorizon"] == 1      , ;
		                    soParam["mrpStartDate"]          , ;
		                    scErrorUID                       , ;
		                    soParam["centralizedBranches"]   , ;
		                    slSincroni)
	Else
		oStatus  := MrpDados_Status():New(soParam["ticket"])
		oStatus:setStatus("tempo_exlusao_previstos_ini", 0)
		oStatus:setStatus("tempo_exlusao_previstos_fim", 0)
		oStatus:setStatus("tempo_exlusao_previstos"    , 0)
	EndIf

	If AllTrim(oParametros["cAutomacao"]) != "1"
		//Retorna status da execução
		aReturn := MrpGStatus(cFilAnt, soParam["ticket"])
		oBody:fromJson(aReturn[2])
	EndIf

	//Converte soParam em Array para API
	oBody["listOfMRPParameters"] := TOParamAPI(oParametros)

	For nIndex := 1 To nTotal
		If oBody[aNoPostFld[nIndex]] != Nil
			oBody[aNoPostFld[nIndex]] := Nil
		EndIf
	Next nIndex

	//Dispara API de Processamento do MRP
	oBody["ticket"] := soParam["ticket"]

	VarSetAD( soParam["ticket"] + "JOB_SYNC", "statusMrpIniCalculo", {.F., ""} )
	soPCPError:startJob("MRPIniCalc", GetEnvServer(), .F., cEmpAnt, cFilAnt, oBody:ToJson(), oParametros["cAutomacao"])

	//Limpa Memória
	FreeObj(oBody)
	FreeObj(oJsonRet)
	aSize(aReturn, 0)
	oBody    := Nil
	oJsonRet := Nil
	aReturn  := Nil

Return lReturn

/*/{Protheus.doc} MRPIniCalc
Dispara API de Processamento do MRP

@type  Function
@author douglas.heydt
@since 26/03/2020
@version P12.1.27
@param 01 - cBody     , caracter, parâmetros da execução
@param 02 - cAutomacao, caracter, Código identificador de execução da automação de testes
@return Nil
/*/
Function MRPIniCalc(cBody, cAutomacao)

	Local aReturn    := {}
	Local cError     := ""
	Local cProblema  := ""
	Local lReturn    := .T.
	Local oBody      := Nil
	Local oJsonRet   := JsonObject():New()
	Local oPCPLock   := PCPLockControl():New()

	oBody := JsonObject():New()
	oBody:fromJson(cBody)

	//Aguarda reserva do processo Mrp Memoria pelo PCPA712
	slLock := oPCPLock:waitCheck("MRP_MEMORIA", {"PCPA712","PCPA141","PCPA140"}, oBody["ticket"],, @cProblema)

	oJsonRet := JsonObject():New()
	If slLock .AND. AguardSinc(oBody["ticket"])
		//Após a sincronização precisa voltar o memoryLoadStatus para "1", pois, durante a sincronização fica "0".
		oBody["memoryLoadStatus"] := "1"
		aReturn  := MrpPCalcul(oBody, cAutomacao)
		oJsonRet:fromJson(aReturn[2])
		lReturn := Iif(oJsonRet["lResult"] == Nil, .T., oJsonRet["lResult"])
		VarSetAD( oBody["ticket"] + "JOB_SYNC", "statusMrpIniCalculo", {lReturn, aReturn[2]} )
		aSize(aReturn, 0)
	Else
		cError := GetGlbValue(oBody["ticket"]+"CERROSSINC")
		If cError == Nil .OR. Empty(cError)
			If Empty(cProblema)
				oJsonRet["detailedMessage"] := STR0280 //"Falha indeterminada impediu a inicialização do cálculo."
			Else
				oJsonRet["detailedMessage"] := cProblema
			EndIf
		Else
			oJsonRet["detailedMessage"] := cError
		EndIf
		VarSetAD( oBody["ticket"] + "JOB_SYNC", "statusMrpIniCalculo", {.T., oJsonRet:toJson()})
	EndIf

	FreeObj(oBody)
	oBody := Nil
	FreeObj(oJsonRet)
	oJsonRet := Nil

Return

/*/{Protheus.doc} TOParamAPI
Converte soParam em Array para API
@author brunno.costa
@since 31/07/2019
@version P12
@param 01 - oParametros, objeto, objeto Json de parâmetros
@return oParametros, objeto, objeto JSON de parâmetros para API
/*/
Static Function TOParamAPI(oParametros, lStart)

	Local aNames
	Local aParMV      := StrTokArr(PARAMETROS_MV, "|")
	Local aParEspec   := StrTokArr(PARAMETROS_ESPECIFICOS, "|")
	Local aParametros := {}
	Local cParametro  := ""
	Local nIndAux     := 0
	Local nIndex      := 0
	Local nTotal      := 0
	Local cPostCarga  := "|cEmpAnt|cFilAnt|user|mrpStartDate|branchCentralizing|centralizedBranches|"
	Local cNoFields   := "|ticket|"

	Default oParametros := soParam
	Default lStart      := .F.

	//Define soParam recebido por parâmetro
	soParam := oParametros
	aNames  := soParam:GetNames()

	//Adiciona os parâmetros (MV) do Protheus
	nTotal := Len(aParMV)
	For nIndex := 1 To nTotal
		aAdd(aNames, aParMV[nIndex])
	Next nIndex

	//Adiciona os parâmetros (MV) do Protheus
	nTotal := Len(aParEspec)
	For nIndex := 1 To nTotal
		aAdd(aNames, aParEspec[nIndex])
	Next nIndex

	nTotal := Len(aNames)
	For nIndex := 1 to nTotal
		cParametro := aNames[nIndex]

		//Envia apenas parâmetros da carga (ou MVs)
		If (lStart .AND. !("|"+AllTrim(cParametro)+"|"$cPostCarga) .AND. !("MV_"$cParametro));
			.OR. ("|"+AllTrim(cParametro)+"|"$cNoFields)
			Loop
		EndIf

		//Pula os que não são enviados
		If cParametro $ scCMPMULTI
			soParam[cParametro]["LISTA"] := TrataLista(cParametro)
			If Empty(soParam[cParametro]["LISTA"])
				Loop
			EndIf

		ElseIf cParametro $ CAMPOS_CHECK_MULTI
			If Empty(soParam[cParametro]["VALOR"])
				Loop
			EndIf

		ElseIf cParametro $ "TELA_1"
			Loop

		Else
			If !(cParametro $ PARAMETROS_MV) .And. ;
			   !(cParametro $ PARAMETROS_ARM) .And. ;
			   !(cParametro $ PARAMETROS_ESPECIFICOS) .And. ;
			    (ValType(soParam[cParametro]) != "L" .And. Empty(soParam[cParametro])) .And.;
                (ValType(soParam[cParametro]) != "N" .OR. soParam[cParametro] != 0)
                Loop
            EndIf
		EndIf

		//Adiciona o parâmetro
		aAdd(aParametros, JsonObject():New())
		nIndAux++

		aParametros[nIndAux]["ticket"]    := soParam["ticket"]
		aParametros[nIndAux]["parameter"] := cParametro
		aParametros[nIndAux]["list"]      := ""

		Do Case
			//Parâmetros do tipo Data
			Case cParametro $ CAMPOS_DATA
				aParametros[nIndAux]["value"]     := ConvDate(soParam[cParametro])

			//Parâmetros do tipo Numérico (Radio)
			Case cParametro $ CAMPOS_NUM
				aParametros[nIndAux]["value"]     := cValToChar(soParam[cParametro])

			//Parâmetros com múltiplos checkboxs
			Case cParametro $ CAMPOS_CHECK_MULTI
				aParametros[nIndAux]["value"]     := soParam[cParametro]["VALOR"]

			//Parâmetros Multi-Valorados enviam "list" ao invés de "value"
			Case cParametro $ scCMPMULTI
				aParametros[nIndAux]["value"]     := ""
				aParametros[nIndAux]["list"]      := soParam[cParametro]["LISTA"]

			//Parâmetros lógicos devem ser enviados como "1" (.T.) ou "2" (.F.)
			Case cParametro $ CAMPOS_CHECK_SIMPLES
				aParametros[nIndAux]["value"]     := IIf(soParam[cParametro], "1", "2")

			//Parâmetros MV
			//Os parâmetros MV sempre devem ser lidos novamente. Nunca pegar o valor já salvo na tabela do setup.
			Case cParametro $ PARAMETROS_MV
				cargaMV(@aParametros[nIndAux], cParametro)

			//Parâmetros Específicos
			Case cParametro $ PARAMETROS_ESPECIFICOS
				cargaEsp(@aParametros[nIndAux], cParametro)

			Case cParametro == "centralizedBranches"
				aParametros[nIndAux]["value"]     := ""
				aParametros[nIndAux]["list"]      := soParam[cParametro]

			Otherwise
				aParametros[nIndAux]["value"]     := soParam[cParametro]
		EndCase
	Next

	aSize(aNames, 0)
	aNames := Nil
	aSize(aParMV, 0)
	aParMV := Nil
	aSize(aParEspec, 0)
	aParEspec := Nil

Return aParametros

/*/{Protheus.doc} cargaMV
Faz a carga do conteúdo de um parâmetro do tipo MV no array de parâmetros que será enviado para a API

@author lucas.franca
@since 22/10/2019
@version P12
@param 01 oParametro, object   , Objeto JSON recebido por referência para fazer a carga do parâmetro.
@param 02 cParametro, Character, Parâmetro que está sendo processado.
@return Nil
/*/
Static Function cargaMV(oParametro, cParametro)
	Do Case
		Case cParametro == "MV_LOTVENC"
			oParametro["parameter"] := "expiredLot"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., "S") == "S", "1", "2")

		Case cParametro == "MV_QLIMITE"
			oParametro["parameter"] := "limiteQuebraLE"
			oParametro["value"]     := SuperGetMv(cParametro, .F., "500")
			If Empty(oParametro["value"])
				oParametro["value"] := "0"
			EndIf

		Case cParametro == "MV_USAQTEM"
			oParametro["parameter"] := "packingQuantityFirst"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., "N") == "S", "1", "2")

		Case cParametro == "MV_QUEBROP"
			oParametro["parameter"] := "productionOrderPerLot"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., "N") == "S", "1", "2")

		Case cParametro == "MV_QUEBRSC"
			oParametro["parameter"] := "purchaseRequestPerLot"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., "N") == "S", "1", "2")

		Case cParametro == "MV_FORCALM"
			oParametro["parameter"] := "breakByMinimunLot"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., .F.), "1", "2")

		Case cParametro == "MV_SUBSLE"
			oParametro["parameter"] := "minimunLotAsEconomicLot"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., .T.), "1", "2")

		Case cParametro == "MV_ARQPROD"
			oParametro["parameter"] := "usesProductIndicator"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., "SB1") == "SBZ", "1", "2")

		Case cParametro == "MV_CQ"
			oParametro["parameter"] := "qualityWarehouse"
			oParametro["value"]     := SuperGetMv(cParametro, .F., "98")
			If Empty(oParametro["value"])
				oParametro["value"] := "98"
			EndIf

		Case cParametro == "MV_GRVLOCP"
			oParametro["parameter"] := "usesInProcessLocation"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., .F.), "1", "2")

		Case cParametro == "MV_LOCPROC"
			oParametro["parameter"] := "inProcessLocation"
			oParametro["value"]     := SuperGetMv(cParametro, .F., "99")

			If Empty(oParametro["value"])
				oParametro["value"] := "99"
			EndIf

		Case cParametro == "MV_PRODMOD"
			oParametro["parameter"] := "usesLaborProduct"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., .F.), "1", "2")

		Case cParametro == "MV_TPHR"
			oParametro["parameter"] := "standardTimeUnit"
			oParametro["value"]     := SuperGetMv(cParametro, .F., 'C')

		Case cParametro == "MV_UNIDMOD"
			oParametro["parameter"] := "unitOfLaborInTheBOM"
			oParametro["value"]     := SuperGetMv(cParametro, .F., 'H')

		Case cParametro == "MV_PCPMADI"
			oParametro["parameter"] := "transportingLanes"
			oParametro["value"]     := IIf(SuperGetMv(cParametro, .F., .F.), "1", "2")

		Case cParametro == "MV_LOGMRP"
			oParametro["parameter"] := "processLogs"
			oParametro["value"]     := scLogMrp

		Case cParametro == "MV_MRPCMEM"
			oParametro["parameter"] := "memoryLoadType" //0=Total;1=Seletiva
			oParametro["value"]     := SuperGetMv(cParametro, .F., "0")

		Case cParametro == "MV_REVFIL"
			oParametro["parameter"] := "revisionInProductIndicator" //1=Sim;2=Não
			oParametro["value"]     := Iif(SuperGetMV(cParametro, .F., .F.), "1", "2") //1=Sim;2=Não

		Case cParametro == "MV_POLPMP"
			oParametro["parameter"] := "stockPolicyPMP"
			oParametro["value"]     := Iif(SuperGetMV(cParametro, .F., .F.), "S", "N")

		Case cParametro == "MV_EMPBN"
			oParametro["parameter"] := "allocationBenefit"
			oParametro["value"]     := Iif(SuperGetMV(cParametro, .F., .F.), "S", "N")

		Case cParametro == "MV_MRPSBPR"
			oParametro["parameter"] := "substituiNoMesmoPeriodo"
			oParametro["value"]     := Iif(SuperGetMV(cParametro, .F., .F.), "1", "2") //1=Sim;2=Não

		Case cParametro == "MV_MRPPERD"
			oParametro["parameter"] := "calculoIndicePerdaMRP"
			oParametro["value"]     := SuperGetMv(cParametro, .F., "1")
			If Empty(oParametro["value"])
				oParametro["value"] := "1"
			EndIf

		Case cParametro == "MV_REPGOPC"
			oParametro["parameter"] := "optionalAllLevels"'
			oParametro["value"] := SuperGetMv(cParametro, .F., "N")

		Case cParametro == "MV_MRPTRAN"
			oParametro["parameter"] := "doTransfersMrp"
			oParametro["value"] := Iif(SuperGetMV(cParametro, .F., .F.), "1", "2") //1=Sim;2=Não

		Case cParametro == "MV_AGLTR"
			oParametro["parameter"] := "aglutinaTransferencia"
			oParametro["value"] := Iif(SuperGetMV(cParametro, .F., .F.), "1", "2") //1=Sim;2=Não

		OtherWise
			oParametro["parameter"] := cParametro
			oParametro["value"]     := SuperGetMv(cParametro, .F.)
	EndCase

	IF oParametro:hasProperty("value")
		oParametro["value"] := AllToChar(oParametro["value"])
		oParametro["value"] := LTRIM(oParametro["value"])
	EndIf

Return

/*/{Protheus.doc} cargaEsp
Faz a carga dos parâmetros específicos

@author marcelo.neumann
@since 20/08/2025
@version P12
@param 01 oParametro, object   , Objeto JSON recebido por referência para fazer a carga do parâmetro
@param 02 cParametro, Character, Parâmetro que está sendo processado
@return Nil
/*/
Static Function cargaEsp(oParametro, cParametro)
	Local cValor := "2"
	Local xRetPE := .F.

	Do Case
		Case cParametro == "usaRevisaoPai"
			cValor := "2"
			If ExistBlock("MRPUSARVPA")
				xRetPE := ExecBlock("MRPUSARVPA", .F., .F.)
				If ValType(xRetPE) == "L"
					cValor := IIf(xRetPE, "1", "2")
				EndIf
			EndIf
			oParametro["parameter"] := "usaRevisaoPai"
			oParametro["value"]     := cValor
	EndCase

Return

/*/{Protheus.doc} UpdStatus
Atualiza os status de execução
@author brunno.costa
@since 31/07/2019
@version P12
@param 01 oBrwWiz  , object, instância do wizard
@param 02 oTitulo  , object, título da página de processamento
@param 03 oDesc    , object, descrição da página de processamento
@param 04 oAvisoLog, object, aviso sobre o log estar ativo
@return Nil
/*/
Static Function UpdStatus(oBrwWiz, oTitulo, oDesc, oAvisoLog)
	Local aError     := {}
	Local aIniCalc   := {}
	Local aIniCarga  := {}
	Local aReturn    := {}
	Local cIntgMES_E := GetGlbValue(soParam["ticket"]+"STATUS_MES_EXCLUSAO")
	Local cIntgMES_I := GetGlbValue(soParam["ticket"]+"STATUS_MES_INCLUSAO")
	Local cIntgQIP_I := GetGlbValue(soParam["ticket"]+"STATUS_QIP_INCLUSAO")
	Local cIntgSFC_I := GetGlbValue(soParam["ticket"]+"STATUS_SFC_INCLUSAO")
	Local cPercent   := GetGlbValue(soParam["ticket"]+"PERCENTUALSINC")
	Local cProblema  := ""
	Local cQIPPercen := GetGlbValue(soParam["ticket"]+"STATUS_QIP_INCLUSAO_PERCENT")
	Local cSolucao   := ""
	Local cStatus_2  := ""
	Local cStatus_3  := ""
	Local cText      := ""
	Local lAtlTela   := oBrwWiz <> Nil .and. oTitulo <> Nil .and. oDesc <> Nil
	Local lLogAtivo  := .F.
	Local lRetCalc   := .T.
	Local lRetCarga  := .T.
	Local lErrorExc  := .F.
	Local lIniGerDoc := .F.
	Local nErroSinc  := Val(GetGlbValue(soParam["ticket"]+"QTDERROSSINC"))
	Local nMemoria   := 0
	Local nProgress  := 100
	Local nProgStat  := 0
	Local nSecAux    := 0
	Local oExcPrevis := Nil
	Local oLogs      := MrpDados_Logs():New()
	Local oJsonAux   := JsonObject():New()
	Local oPCPLock   := PCPLockControl():New()
	Local oProcesso  := JsonObject():New()
	Local oFim       := JsonObject():New()
	Local oStatus    := Nil
	Local oStatus_1  := Nil
	Local oSugEmp    := Nil

	lLogAtivo := oLogs:logAtivado()

	If !slError .AND. !slLock
		slLock := oPCPLock:check("MRP_MEMORIA", "PCPA712",  soParam["ticket"], .T., @cProblema, @cSolucao)
		If snIniStat == Nil
			snIniStat := Seconds()
		EndIf

		If (Seconds() - snIniStat) > DEFAULT_nMSG_LOCK_ALERT //Se mais de DEFAULT_nMSG_LOCK_ALERT segundos esperando
			If !slLock .AND. !slshowMsgL
				cSolucao := STR0276 + cValToChar(DEFAULT_nMSG_LOCK_ERROR/60) + STR0277 //"Aguarde " + " minutos enquanto o sistema tenta realizar a reserva ou tente novamente mais tarde."
				Help( ,  , "A712L" + cValToChar(ProcLine()), ,  cProblema, 1, 0, , , , , , {cSolucao})
			EndIf
			slshowMsgL := .T.

			If (Seconds() - snIniStat) > DEFAULT_nMSG_LOCK_ERROR //Se mais 3 minutos esperando (total 3 minutos e 30 segundos, pelo menos)
				slLock  := oPCPLock:check("MRP_MEMORIA", "PCPA712",  soParam["ticket"], .T., @cProblema, @cSolucao)
				slError := !slLock
				If slError
					Help( ,  , "A712L" + cValToChar(ProcLine()), ,  cProblema, 1, 0, , , , , , {cSolucao})
				EndIf
			EndIf
		EndIf
	EndIf

	If soParam["ticket"] != Nil .AND. !Empty(soParam["ticket"])
		aReturn := MrpGet(cFilAnt, soParam["ticket"])
		oProcesso:fromJson(aReturn[2])

		If !slError
			slError := soPCPError:possuiErro()
			If slError
				aError := soPCPError:getaError()
				CancelExec(0)
				If GetGlbValue(soParam["ticket"] + "P145ERROR") == "ERRO"
					P145GrvLog(soPCPError, soParam["ticket"])
				EndIf
				oPCPLock:unlock("MRP_MEMORIA", "PCPA145", soParam["ticket"])
				soPCPError:final()
			EndIf
		EndIf

		If scLogMrp == "1" .And. lAtlTela .And. oLogs:erroNaGravacao()
			oAvisoLog:SetText(STR0381 + " " + STR0382) //"ATENÇÃO! O parâmetro MV_LOGMRP está ativado. O desempenho será prejudicado."
		EndIf

		lRetCarga := VarGetAD( soParam["ticket"] + "JOB_SYNC", "statusMrpIniCarga"  , aIniCarga)
		lRetCalc  := VarGetAD( soParam["ticket"] + "JOB_SYNC", "statusMrpIniCalculo", aIniCalc )

		If slSincroni .And. nErroSinc != -1 .AND. cPercent != "-1" //-1 = Variavel foi instanciada, ainda pendente de termino da sincronizacao
			//Sincronização
			If nErroSinc > 0
				saStatus[__SINCRONI][1] := soNO
				saStatus[__SINCRONI][3] := STR0179 //"Erro"
				saStatus[__NIVEIS  ][1] := soAM
				saStatus[__NIVEIS  ][3] := STR0103 //"Cancelado"
				saStatus[__CARGA   ][1] := soAM
				saStatus[__CARGA   ][3] := STR0103 //"Cancelado"
				saStatus[__CALCULO ][1] := soAM
				saStatus[__CALCULO ][3] := STR0103 //"Cancelado"
				saStatus[__PERSIST ][1] := soAM
				saStatus[__PERSIST ][3] := STR0103 //"Cancelado"

				If __GERARAST > 0
					saStatus[__GERARAST][1] := soAM
					saStatus[__GERARAST][3] := STR0103 //"Cancelado"
				EndIf

				If __EXCLUSAO > 0
					saStatus[__EXCLUSAO][1] := soAM
					saStatus[__EXCLUSAO][3] := STR0103 //"Cancelado"
				EndIf

				If __LOG_EVEN > 0
					saStatus[__LOG_EVEN][1] := soAM
					saStatus[__LOG_EVEN][3] := STR0103 //"Cancelado"
				EndIf

				If __GERA_DOC > 0
					saStatus[__GERA_DOC][1] := soAM
					saStatus[__GERA_DOC][3] := STR0103 //"Cancelado"
				EndIf

				If __RAST_DOC > 0
					saStatus[__RAST_DOC][1] := soAM
					saStatus[__RAST_DOC][3] := STR0103 //"Cancelado"
				EndIf

				If __SUG_LOTE > 0
					saStatus[__SUG_LOTE][1] := soAM
					saStatus[__SUG_LOTE][3] := STR0103 //"Cancelado"
				EndIf

				If !slError
					CancelExec(0)
					slError := .T.
					cMsgVld := GetGlbValue(soParam["ticket"]+"ERROSINCVALID")

					If !Empty(cMsgVld)
						Aviso(STR0271,STR0279 + CHR(10) + cMsgVld,{"Ok"},3) //"Aviso" "Os dados não puderam ser sincronizados. Devem ser realizados os seguintes ajustes no dicionário/base de dados para prosseguir: "
						ClearGlbValue(soParam["ticket"]+"ERROSINCVALID")
					Else
						Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0206, 1, 0, , , , , , {STR0207}) //"Alguns registros não puderam ser sincronizados"--"Acesse as rotinas de pendências de integração e sincronização para obter detalhes."
					EndIf
				EndIf

			ELseIf Val(cPercent) < 100
				saStatus[__SINCRONI][1] := soAtual
				saStatus[__SINCRONI][2] := STR0205 + " " + cPercent + "%"
				saStatus[__SINCRONI][3] := STR0090

			ElseIf cPercent == "100"
				saStatus[__SINCRONI][1] := soOK
				saStatus[__SINCRONI][2] := STR0205 + " 100%"
				saStatus[__SINCRONI][3] := STR0089 //"Concluído"
			EndIf
		EndIf

		//Recálculo dos Niveis
		If oProcesso["statusLevelsStructure"] == "2"
			saStatus[__NIVEIS][1] := soAtual
			saStatus[__NIVEIS][3] := STR0090 //"Executando"

		ElseIf oProcesso["statusLevelsStructure"] == "3"
			saStatus[__NIVEIS][1] := soOK
			saStatus[__NIVEIS][3] := STR0089 //"Concluído"

		ElseIf oProcesso["statusLevelsStructure"] == "9"
			saStatus[__NIVEIS][1] := soNO
			saStatus[__NIVEIS][3] := STR0179 //"Erro"

			If !slError
				slError := .T.
				Help( ,  , "A712L" + cValToChar(ProcLine()), ,  oProcesso["message"], 1, 0, , , , , , {STR0180} ) //"Corrija o problema e processe novamente."
			EndIf
		EndIf

		//Carga dos Dados em Memória
		If lRetCarga .And. saStatus[__CARGA][3] <> STR0103
			If aIniCarga[1]
				If !(oProcesso["memoryLoadStatus"] $ "1|3|4|9")
					saStatus[__CARGA][1] := soAtual
					If oProcesso["memoryLoadPercentage"] != Nil .AND. !Empty(oProcesso["memoryLoadPercentage"])
						saStatus[__CARGA][2] := STR0083 + " " + oProcesso["memoryLoadPercentage"]
					EndIf
					saStatus[__CARGA][3] := STR0090 //"Executando"

				ElseIf oProcesso["memoryLoadStatus"] == "3"
					saStatus[__CARGA][1] := soLA
					saStatus[__CARGA][2] := STR0083 + " 100%"
					saStatus[__CARGA][3] := STR0101 //"Em Memória"

				ElseIf oProcesso["memoryLoadStatus"] == "4"
					saStatus[__CARGA][1] := soOK
					saStatus[__CARGA][2] := STR0083 + " 100%"
					saStatus[__CARGA][3] := STR0100 //"Descarregada"

				ElseIf oProcesso["memoryLoadStatus"] == "9"
					saStatus[__CARGA][1] := soNO
					saStatus[__CARGA][3] := STR0179 //"Erro"

					If !slError
						slError := .T.
						Help( ,  , "A712L" + cValToChar(ProcLine()), ,  oProcesso["message"], 1, 0, , , , , , {STR0180} ) //"Corrija o problema e processe novamente."
					EndIf
				EndIf

			ElseIf !Empty(aIniCarga[2])
				saStatus[__CARGA][1] := soNO
				saStatus[__CARGA][2] := STR0083
				saStatus[__CARGA][3] := STR0179 //"Erro"

				If !slError
					slError := .T.
					oJsonAux:fromJson(aIniCarga[2])
					Help(' ', 1, "A712L" + cValToChar(ProcLine()), , oJsonAux["detailedMessage"], 2,0, , , , , , {})
				EndIf
			EndIf
		EndIf

		//Cálculo do MRP
		If lRetCalc
			If aIniCalc[1]
				If oProcesso["mrpCalculationStatus"] == "2"
					saStatus[__CALCULO][1] := soAtual
					If oProcesso["calculationPercentage"] != Nil .AND. !Empty(oProcesso["calculationPercentage"])
						saStatus[__CALCULO][2] := STR0085 + " " + oProcesso["calculationPercentage"]
					EndIf
					saStatus[__CALCULO][3] := STR0090 //"Executando"

				ElseIf oProcesso["mrpCalculationStatus"] == "3"
					saStatus[__CALCULO][1] := soOK
					saStatus[__CALCULO][2] := STR0085 + " 100%"
					saStatus[__CALCULO][3] := STR0089 //"Concluído"

				ElseIf oProcesso["mrpCalculationStatus"] == "9"
					saStatus[__CALCULO][1] := soNO
					saStatus[__CALCULO][3] := STR0179 //"Erro"

					If !slError
						slError := .T.
						Help( ,  , "A712L" + cValToChar(ProcLine()), ,  oProcesso["message"], 1, 0, , , , , , {STR0180} ) //"Corrija o problema e processe novamente."
					EndIf

				ElseIf oProcesso["mrpCalculationStatus"] == "4" .OR. slError
					saStatus[__CALCULO][1] := soAM
					saStatus[__CALCULO][3] := STR0103 //"Cancelado"
				EndIf

			ElseIf !Empty(aIniCalc[2])
				saStatus[__CALCULO][1] := soNO
				saStatus[__CALCULO][3] := STR0179 //"Erro"

				If !slError
					slError := .T.
					oJsonAux:fromJson(aIniCalc[2])
					Help(' ',1,"A712L" + cValToChar(ProcLine()) ,, oJsonAux["message"],2,0,,,,,, {})
				EndIf
			EndIf
		EndIf

		//Persistência dos Resultados
		If oProcesso["statusPersistenceResults"] == "2"
			saStatus[__PERSIST][1] := soAtual
			saStatus[__PERSIST][3] := STR0090 //"Executando"

		ElseIf oProcesso["statusPersistenceResults"] == "3"
			If snAtuDem == 0
				If updDemands(soParam["ticket"])
					snAtuDem := 1
				Else
					snAtuDem := 2
					LogMsg('updDemands', 0, 0, 1, '', '', STR0204)
					Help( ,  , "A712L" + cValToChar(ProcLine()), , STR0204, 1, 0, , , , , ,{STR0377}) //Não foi possível atualizar número do MRP na tabela de demandas. // Entre em contato com o Suporte.
				EndIf
			EndIf

			If snAtuDem == 1
				saStatus[__PERSIST][1] := soOK
				saStatus[__PERSIST][3] := STR0089 //"Concluído"

			Else
				saStatus[__PERSIST][1] := soNO
				saStatus[__PERSIST][3] := STR0179 //"Erro"
				slError := .T.
			EndIf

			If slLock
				oPCPLock:unlock("MRP_MEMORIA", "PCPA712", soParam["ticket"])
			EndIf

		ElseIf oProcesso["statusPersistenceResults"] == "9"
			saStatus[__PERSIST][1] := soNO
			saStatus[__PERSIST][3] := STR0179 //"Erro"

			If !slError
				slError := .T.
				Help( ,  , "A712L" + cValToChar(ProcLine()), ,  oProcesso["message"], 1, 0, , , , , , {STR0180}) //"Corrija o problema e processe novamente."
			EndIf

		ElseIf oProcesso["statusPersistenceResults"] == "4" .OR. slError
			saStatus[__PERSIST][1] := soAM
			saStatus[__PERSIST][3] := STR0103 //"Cancelado"
		EndIf

		If __GERARAST > 0
			If slError
				saStatus[__GERARAST][1] := soAM
				saStatus[__GERARAST][3] := STR0103 //"Cancelado"

			ElseIf !oProcesso["rastreiaEntradasStatus"] $ "1|2"
				snProgRast := 100
				saStatus[__GERARAST][1] := soOK
				saStatus[__GERARAST][2] := I18N(STR0342, {"100%"}) //"Geração da Rastreabilidade de Demandas 100%"
				saStatus[__GERARAST][3] := STR0089 //"Concluído"

			ElseIf oProcesso["rastreiaEntradasStatus"] == "2"
				saStatus[__GERARAST][1] := soAtual
				If oProcesso["rastreiaEntradasPercentage"] != Nil .And. !Empty(oProcesso["rastreiaEntradasPercentage"])
					saStatus[__GERARAST][2] := I18N(STR0342, {oProcesso["rastreiaEntradasPercentage"]}) //"Geração da Rastreabilidade de Demandas XX%"
				EndIf
				saStatus[__GERARAST][3] := STR0090 //"Executando"
			EndIf
		EndIf

		If soParam["documentType"]["PREVISTOS"] == "1"
			oExcPrevis := ExclusaoPrevistos():New(soParam["ticket"],.F.)
			nProgStat  := oExcPrevis:GetStatus(@lErrorExc)

			If saStatus[__EXCLUSAO][3] <> STR0103 .And. !lErrorExc
				If nProgStat >= 100
					If !slExcOpFim
						saStatus[__EXCLUSAO][1] := soOK
						saStatus[__EXCLUSAO][2] := STR0203 + " " + cValToChar(nProgStat) + "%" //"Exclusão de Documentos Previstos:"
						saStatus[__EXCLUSAO][3] := STR0089 //"Concluído"
						slExcOpFim := .T.
					EndIf

				ElseIf nProgStat > 0
					saStatus[__EXCLUSAO][1] := soAtual
					saStatus[__EXCLUSAO][2] := STR0203 + " " + cValToChar(nProgStat) + "%" //"Exclusão de Documentos Previstos:"
					saStatus[__EXCLUSAO][3] := STR0090 //"Executando"

				Else
					saStatus[__EXCLUSAO][1] := soAtual
					saStatus[__EXCLUSAO][2] := STR0203 + " 0%" //"Exclusão de Documentos Previstos:"
					saStatus[__EXCLUSAO][3] := STR0090 //"Executando"
				EndIf
			ElseIf lErrorExc
				slExcOpFim := .T.

				saStatus[__EXCLUSAO][1] := soNO
				saStatus[__EXCLUSAO][3] := STR0179 //"Erro"

				saStatus[__NIVEIS  ][1] := soAM
				saStatus[__NIVEIS  ][3] := STR0103 //"Cancelado"

				saStatus[__CARGA   ][1] := soAM
				saStatus[__CARGA   ][3] := STR0103 //"Cancelado"

				saStatus[__CALCULO ][1] := soAM
				saStatus[__CALCULO ][3] := STR0103 //"Cancelado"

				saStatus[__PERSIST ][1] := soAM
				saStatus[__PERSIST ][3] := STR0103 //"Cancelado"

				If __GERARAST > 0
					saStatus[__GERARAST][1] := soAM
					saStatus[__GERARAST][3] := STR0103 //"Cancelado"
				EndIf

				If __LOG_EVEN > 0
					saStatus[__LOG_EVEN][1] := soAM
					saStatus[__LOG_EVEN][3] := STR0103 //"Cancelado"
				EndIf

				If __GERA_DOC > 0
					saStatus[__GERA_DOC][1] := soAM
					saStatus[__GERA_DOC][3] := STR0103 //"Cancelado"
				EndIf

				If __RAST_DOC > 0
					saStatus[__RAST_DOC][1] := soAM
					saStatus[__RAST_DOC][3] := STR0103 //"Cancelado"
				EndIf

				If __SUG_LOTE > 0
					saStatus[__SUG_LOTE][1] := soAM
					saStatus[__SUG_LOTE][3] := STR0103 //"Cancelado"
				EndIf

				If !slError
					slError := .T.
					CancelExec(0)
					Help( ,  , "HELP", ,  STR0396, 1, 0, , , , , , {STR0397}) // "Ocorreu um erro no processamento da exclusão de documentos previstos." "Consulte o log do MRP para mais informações."
				EndIf
			EndIf
		Else
			slExcOpFim := .T.
		EndIf

		If soParam["eventLog"]
			If oProcesso["documentEventLogStatus"] == "2"
				saStatus[__LOG_EVEN][1] := soAtual
				If oProcesso["documentEventLogPercentage"] != Nil .AND. !Empty(oProcesso["documentEventLogPercentage"])
					saStatus[__LOG_EVEN][2] := STR0229 + " " + oProcesso["documentEventLogPercentage"] //"Geração do Log de Eventos:"
				EndIf
				saStatus[__LOG_EVEN][3] := STR0090 //"Executando"

			ElseIf oProcesso["documentEventLogStatus"] == "3"
				snEventLog := 100
				saStatus[__LOG_EVEN][1] := soOK
				saStatus[__LOG_EVEN][2] := STR0229 + " 100%" //"Geração do Log de Eventos:"
				saStatus[__LOG_EVEN][3] := STR0089 //"Concluído"

			ElseIf oProcesso["documentEventLogStatus"] == "9"
				saStatus[__LOG_EVEN][1] := soNO
				saStatus[__LOG_EVEN][3] := STR0179 //"Erro"

				If !slError
					slError := .T.
					Help( ,  , "A712L" + cValToChar(ProcLine()), ,  oProcesso["message"], 1, 0, , , , , , {STR0180} ) //"Corrija o problema e processe novamente."
				EndIf

			ElseIf oProcesso["documentEventLogStatus"] == "4" .OR. slError
				snEventLog := 100
				saStatus[__LOG_EVEN][1] := soAM
				saStatus[__LOG_EVEN][3] := STR0103 //"Cancelado"
			EndIf
		EndIf

		If slIntgMES .And. saStatus[__INTG_MES][1] <> soOK
			oStatus_1 := saStatus[__INTG_MES][1]
			cStatus_2 := saStatus[__INTG_MES][2]
			cStatus_3 := saStatus[__INTG_MES][3]

			If !slMESLite .And. soParam["documentType"]["PREVISTOS"] == "1"
				If cIntgMES_E == "INI"
					oStatus_1 := soAtual
					cStatus_3 := STR0305 //"Excluindo Documentos"

				ElseIf cIntgMES_E == "FIM"
					If soParam['lGeraDoc']
						oStatus_1 := soAM
						cStatus_3 := STR0306 //"Aguardando Documentos"
					Else
						oStatus_1 := soOK
						cStatus_3 := STR0089 //"Concluído"
					EndIf
				EndIF
			EndIf

			If soParam['lGeraDoc']
				If cIntgMES_I == "PEN" .And. saStatus[__GERA_DOC][1] == soOK
					oStatus_1 := soAtual
					cStatus_3 := STR0307 //"Preparando Documentos"

				ElseIf cIntgMES_I == "INI"
					oStatus_1 := soAtual
					cStatus_3 := STR0308 //"Incluindo Documentos"

				ElseIf cIntgMES_I <> "PEN"
					oStatus_1 := soOK
					cStatus_3 := STR0089 //"Concluído"
				EndIf
			EndIf

			saStatus[__INTG_MES][1] := oStatus_1
			saStatus[__INTG_MES][3] := cStatus_3
		EndIf

		If slIntgSFC .And. saStatus[__INTG_SFC][1] <> soOK
			oStatus_1 := saStatus[__INTG_SFC][1]
			cStatus_2 := saStatus[__INTG_SFC][2]
			cStatus_3 := saStatus[__INTG_SFC][3]

			If soParam['lGeraDoc']
				If cIntgSFC_I == "PEN" .And. saStatus[__GERA_DOC][1] == soOK
					oStatus_1 := soAtual
					cStatus_3 := STR0307 //"Preparando Documentos"

				ElseIf cIntgSFC_I == "INI"
					oStatus_1 := soAtual
					cStatus_3 := STR0308 //"Incluindo Documentos"

				ElseIf cIntgSFC_I <> "PEN"
					oStatus_1 := soOK
					cStatus_3 := STR0089 //"Concluído"
				EndIf
			EndIf

			saStatus[__INTG_SFC][1] := oStatus_1
			saStatus[__INTG_SFC][3] := cStatus_3
		EndIf

		If slIntgQIP .And. saStatus[__INTG_QIP][1] <> soOK
			oStatus_1 := saStatus[__INTG_QIP][1]
			cStatus_2 := saStatus[__INTG_QIP][2]
			cStatus_3 := saStatus[__INTG_QIP][3]

			If soParam['lGeraDoc']
				If cIntgQIP_I == "PEN" .And. saStatus[__GERA_DOC][1] == soAtual
					oStatus_1 := soAM
					cStatus_3 := STR0306 //"Aguardando Documentos"

				ElseIf cIntgQIP_I == "INI"
					oStatus_1 := soAtual
					cStatus_3 := STR0311 //"Integrando Documentos"
					If !Empty(cQIPPercen)
						cStatus_2 := STR0310 + ": " + cQIPPercen + "%" //"Integração com o QIP"
					EndIf

				ElseIf cIntgQIP_I <> "PEN"
					oStatus_1 := soOK
					cStatus_2 := STR0310 + ": 100%" //"Integração com o QIP"
					cStatus_3 := STR0089 //"Concluído"
				EndIf
			EndIf

			saStatus[__INTG_QIP][1] := oStatus_1
			saStatus[__INTG_QIP][2] := cStatus_2
			saStatus[__INTG_QIP][3] := cStatus_3
		EndIf

		If oProcesso["statusPersistenceResults"] == "3" .And.; //Gravação de dados concluída
		   snAtuDem == 1                                .And.; //Atualização de demandas finalizada
		   slExcOpFim                                   .And.; //Exclusão de docs previstos finalizada
		   soParam['lGeraDoc']                          .And.; //Gera docs no término do cálculo
		   (__GERARAST == 0                             .Or.;  //Sem gerar rastreabilidade OU
		   (__GERARAST > 0 .And. snProgRast == 100))    .And.; //Gera rastreabilidade e terminou o processo de geração
		   !slError                                            //Sem erro

			If _nMemLimit > 0 .And. !slGDocADes .And. Val(scPicoMemo) >= (_nMemLimit * 0.75) .And. oProcesso["memoryLoadStatus"] != "4"
				slGDocADes := .T.
				LogMsg("PCPA712", 0, 0, 1, "", "", "Uso de memoria ultrapassou limites aceitaveis durante o calculo do MRP. A geracao de documentos ira iniciar apenas quando a memoria for descarregada.")
			EndIf

			If soGeraDoc == Nil .And. (!slGDocADes .Or. (slGDocADes .And. oProcesso["memoryLoadStatus"] == "4"))
				//Valida se existem log de eventos e se deseja continuar o processamento.
				If (_lP145LOG .and. !P145VLOGEVE(soParam["ticket"])) .Or. (snTryGDoc > snMaxTGDoc)
					soParam['lGeraDoc']	:= .F.
					saStatus[__GERA_DOC][1] := soAM
					saStatus[__GERA_DOC][3] := STR0103 //"Cancelado"

					If AllTrim(soParam["allocationSuggestion"]) == "1" .And. __SUG_LOTE > 0
						saStatus[__SUG_LOTE][1] := soAM
						saStatus[__SUG_LOTE][3] := STR0103 //"Cancelado"
					EndIf

					If AllTrim(soParam["lDocAlcada"]) == "1" .And. __DOC_ALCA > 0
						saStatus[__DOC_ALCA][1] := soAM
						saStatus[__DOC_ALCA][3] := STR0103 //"Cancelado"
					EndIf

					If __RAST_DOC > 0
						saStatus[__RAST_DOC][1] := soAM
						saStatus[__RAST_DOC][3] := STR0103 //"Cancelado"
					EndIf

					If snTryGDoc > snMaxTGDoc
						Help(,,'Help',, STR0375, 1,0,,,,,,{STR0376}) // "Ocorreu um erro ao iniciar a geração de documentos no fim do calculo do MRP." "Tente realizar a geração dos documentos através da tela de resultados do MRP (resultadom ou PCPA144)."
					EndIf

					slError := .T.

					FreeObj(oJsonAux)
					FreeObj(oProcesso)
					aSize(aReturn, 0)
					oJsonAux  := Nil
					oProcesso := Nil
					aReturn   := Nil

					Return Nil
				EndIf

				aParams   := {}
				nProgress := 0
				snProgDoc := 0
				AADD(aParams,{0,{"","","consolidateProductionOrder",soParam['consolidateProductionOrder']}})
				AADD(aParams,{0,{"","","consolidatePurchaseRequest",soParam['consolidatePurchaseRequest']}})
				AADD(aParams,{0,{"","","productionOrderNumber"     ,soParam['productionOrderNumber'     ]}})
				AADD(aParams,{0,{"","","purchaseRequestNumber"     ,soParam['purchaseRequestNumber'     ]}})
				AADD(aParams,{0,{"","","productionOrderType"       ,soParam['productionOrderType'       ]}})
				AADD(aParams,{0,{"","","allocationSuggestion"      ,soParam['allocationSuggestion'      ]}})
				AADD(aParams,{0,{"","","lDocAlcada"                ,soParam['lDocAlcada'                ]}})
				AADD(aParams,{0,{"","","lRastreiaEntradas"         ,Iif(soParam['lRastreiaEntradas'],"1","2")}})

				If snTryGDoc == 0
					oStatus  := MrpDados_Status():New(soParam["ticket"])
					oStatus:setStatus("tempo_geracao_documentos", MicroSeconds())
				EndIf

				PutGlbValue(soParam["ticket"]+"PCPA151_STATUS","INI")
				PutGlbValue(soParam["ticket"]+"UIDPRG_PCPA145","INI")
				PutGlbValue(soParam["ticket"]+"P145ERROR", "INI")
				PutGlbValue(soParam["ticket"]+"P145LOCK", "PEND")

				soPCPError:startJob("PCPA145", GetEnvServer(), .F., cEmpAnt, cFilAnt, soParam["ticket"], aParams, Nil, scErrorUID, RetCodUsr(), Nil, , , , , , '{|| PutGlbValue("' + soParam["ticket"] + '" +"P145ERROR", "ERRO"), PCPUnlock("PCPA145") }')

				If soPCPError:abriuUltimaThread()
					lIniGerDoc := iniGerDoc(soParam["ticket"], soPCPError)
				EndIf

				If lIniGerDoc
					soGeraDoc := ProcessaDocumentos():New(soParam["ticket"], .T., aParams, soParam['user'])

					saStatus[__GERA_DOC][1] := soAtual
					saStatus[__GERA_DOC][2] := STR0212 + " 0%" //"Geração de Documentos: "
					saStatus[__GERA_DOC][3] := STR0090 //"Executando"
				Else
					If oProcesso["memoryLoadStatus"] == "4"
						snTryGDoc++

						LogMsg("PCPA712", 0, 0, 1, "", "", "Nao foi possivel abrir a thread para iniciar a geracao de documentos, tentativa " + cValToChar(snTryGDoc))
					Else
						slGDocADes := .T.

						LogMsg("PCPA712", 0, 0, 1, "", "", "Nao foi possivel abrir a thread para iniciar a geracao de documentos. Sera feito uma nova tentativa quando a memoria for descarregada.")
					EndIf
				EndIf
			ElseIf soGeraDoc != Nil
				If snProgDoc < 100
					nProgress := soGeraDoc:getProgress(.F.)
					If snProgDoc > 0 .And. nProgress == 0
						nProgress := 100
					Else
						snProgDoc := nProgress
					EndIf
					If nProgress < 100
						saStatus[__GERA_DOC][1] := soAtual
						saStatus[__GERA_DOC][2] := STR0212 + " " + cValToChar(nProgress) + "%" //"Geração de Documentos:"
						saStatus[__GERA_DOC][3] := STR0090 //"Executando"
					Else
						saStatus[__GERA_DOC][1] := soOK
						saStatus[__GERA_DOC][2] := STR0212 + " " + cValToChar(nProgress) + "%" //"Geração de Documentos:"
						saStatus[__GERA_DOC][3] := STR0089 //"Concluído"

						If AllTrim(soParam["allocationSuggestion"]) == "1" .And. snProgSugE == 0
							saStatus[__SUG_LOTE][1] := soAtual
							saStatus[__SUG_LOTE][3] := STR0090 //"Executando"
						EndIf
					EndIf
				EndIf

				If __DOC_ALCA > 0 .And. snDocAlca < 100 .And. (nProgress == 100 .Or. snProgDoc == 100)
					snDocAlca := soGeraDoc:getAlcProgress()
					saStatus[__DOC_ALCA][2] := STR0372 + " " + cValToChar(snDocAlca) + "%" //"Geração das alçadas dos documentos:"
					If snDocAlca == 100
						saStatus[__DOC_ALCA][1] := soOK
						saStatus[__DOC_ALCA][3] := STR0089 //"Concluído"
					Else
						saStatus[__DOC_ALCA][1] := soAtual
						saStatus[__DOC_ALCA][3] := STR0090 //"Executando"
					EndIf
				EndIf

				If __RAST_DOC > 0 .And. snRastDoc < 100 .And. (nProgress == 100 .Or. snProgDoc == 100)
					snRastDoc := soGeraDoc:getRastProgress()
					saStatus[__RAST_DOC][2] := STR0369 + ": " + cValToChar(snRastDoc) + "%" //"Rastreabilidade documentos"
					If snRastDoc == 100
						saStatus[__RAST_DOC][1] := soOK
						saStatus[__RAST_DOC][3] := STR0089 //"Concluído"
					Else
						saStatus[__RAST_DOC][1] := soAtual
						saStatus[__RAST_DOC][3] := STR0090 //"Executando"
					EndIf
				EndIf
			EndIf

			If AllTrim(soParam["allocationSuggestion"]) == "1" .And. soParam['lGeraDoc']
				oSugEmp := SugestaoLotesEnderecos():New(NIL, NIL, NIL, .T.,, soParam["ticket"])
				If snProgSugE < 100
					nProgress := oSugEmp:getProgress(soParam["ticket"])
					If snProgSugE > 0 .And. nProgress == 0
						nProgress := 100
					Else
						snProgSugE := nProgress
					EndIf

					If nProgress < 100
						saStatus[__SUG_LOTE][2] := STR0269 + " " + cValToChar(nProgress) + "%" //"Sugestão de Lote e Endereço nos Empenhos"
						If nProgress > 0
							saStatus[__SUG_LOTE][1] := soAtual
							saStatus[__SUG_LOTE][3] := STR0090 //"Executando"
						EndIf
					Else
						saStatus[__SUG_LOTE][1] := soOK
						saStatus[__SUG_LOTE][2] := STR0269 + " " + cValToChar(nProgress) + "%" //"Sugestão de Lote e Endereço nos Empenhos"
						saStatus[__SUG_LOTE][3] := STR0089 //"Concluído"
					EndIf
				EndIf
			EndIf

		ElseIf slError .And. soParam['lGeraDoc']
			saStatus[__GERA_DOC][1] := soAM
			saStatus[__GERA_DOC][3]  := STR0103 //"Cancelado"
			oStatus := MrpDados_Status():New(soParam["ticket"])
			nSecAux := oStatus:getStatus("tempo_geracao_documentos")
			If nSecAux != Nil .And. ValType(nSecAux) == "N"
				oStatus:setStatus("tempo_geracao_documentos", MicroSeconds() - nSecAux)
			Else
				oStatus:setStatus("tempo_geracao_documentos", 0)
			EndIf

			If AllTrim(soParam["allocationSuggestion"]) == "1"
				saStatus[__SUG_LOTE][1] := soAM
				saStatus[__SUG_LOTE][3] := STR0103 //"Cancelado"
			EndIf

			If __DOC_ALCA > 0
				saStatus[__DOC_ALCA][1] := soAM
				saStatus[__DOC_ALCA][3] := STR0103 //"Cancelado"
			EndIf

			If __RAST_DOC > 0
				saStatus[__RAST_DOC][1] := soAM
				saStatus[__RAST_DOC][3] := STR0103 //"Cancelado"
			EndIf
		Else
			oStatus  := MrpDados_Status():New(soParam["ticket"])
			oStatus:setStatus("tempo_geracao_documentos", 0)
		EndIf

		If !slError .And. slAtuMem
			nMemoria := GetMemory()

			If Val(scPicoMemo) < nMemoria
				scPicoMemo := cValToChar(nMemoria)
			EndIf

			cText := STR0322 // "Memória: "
			cText += i18n(STR0323, {cValToChar(nMemoria)}) // "Em uso: #1[memoriaEmUso]# MB"
			cText += "; " + i18n(STR0373, {scPicoMemo}) // "Pico: #1[picoMemoria]# MB"
			If _nMemLimit > 0
				cText += "; " + i18n(STR0374, {cValToChar(_nMemLimit)}) // "Limite: #1[limiteMemoria]# MB"
			EndIf
			cText += "."

			saStatus[__MEMORIA][1] := soLA
			saStatus[__MEMORIA][2] := cText
			saStatus[__MEMORIA][3] := STR0324 // "Verificando"

			_nContLogM++
			If _nContLogM > INTERVALO_LOG_USO_MEMORIA
				_nContLogM := 0

				LogMsg("PCPA712", 0, 0, 1, "", "", cText)
			EndIf
		EndIf

		oFim["exclusaoPrevistos"        ] := slExcOpFim
		oFim["geracaoDocumentos"        ] := !soParam['lGeraDoc'] .Or. (snProgDoc  == 100 .And. soParam['lGeraDoc'])
		oFim["sugestaoLote"             ] := !soParam['lGeraDoc'] .Or. AllTrim(soParam["allocationSuggestion"]) != "1" .Or. (snProgSugE == 100 .And. soParam['lGeraDoc'])
		oFim["logEventos"               ] := !soParam["eventLog"] .Or. (snEventLog == 100 .And. soParam["eventLog"])
		oFim["rastreabilidade"          ] := __GERARAST == 0 .Or. (__GERARAST > 0 .And. snProgRast == 100)
		oFim["alcada"                   ] := __DOC_ALCA == 0 .Or. (__DOC_ALCA > 0 .And. snDocAlca  == 100)
		oFim["rastreabilidadeDocumentos"] := __RAST_DOC == 0 .Or. (__RAST_DOC > 0 .And. snRastDoc  == 100)
		oFim["integracaoMES"            ] := !slIntgMES .Or. saStatus[__INTG_MES][1] == soOK
		oFim["integracaoSFC"            ] := !slIntgSFC .Or. saStatus[__INTG_SFC][1] == soOK
		oFim["integracaoQIP"            ] := !slIntgQIP .Or. saStatus[__INTG_QIP][1] == soOK

		If slError .Or. (oFim["exclusaoPrevistos"        ] .And.;
		                 oFim["geracaoDocumentos"        ] .And.;
		                 oFim["sugestaoLote"             ] .And.;
		                 oFim["logEventos"               ] .And.;
		                 oFim["rastreabilidade"          ] .And.;
		                 oFim["alcada"                   ] .And.;
		                 oFim["rastreabilidadeDocumentos"] .And. (nErroSinc > 0                                     .Or.;
		                                                          oProcesso["status"] $ "|4|3|"                     .Or.;
		                                                          oProcesso["statusPersistenceResults"] $ "|3|4|5|" .Or.;
		                                                          oProcesso["memoryLoadStatus"] $ "|4|9|"))

			slConcluiu := .T.
			If lAtlTela
				oTitulo:SetText(STR0200) //"Processamento finalizado."
				If slError
					oDesc:SetText(STR0202) //"Ocorreu algum erro durante o processamento do MRP."
				Else
					oDesc:SetText(STR0201) //"Cálculo do MRP concluído com sucesso."
				EndIf
			EndIf

			If _lRunP712F
				_lRunP712F := .F. //Seta variável para executar o somente uma vez. O TIMER não é desativado no fim do MRP.

				If _lP712FIM
					ExecBlock("P712FIM",.F.,.F.,{slConcluiu,slError,soParam["ticket"]})
				EndIf
			EndIf
		EndIf

		If lAtlTela
			oBrwWiz:SetArray(saStatus)
			oBrwWiz:Refresh()
		EndIf
	EndIf

	If nErroSinc > 0 .Or. (oProcesso["memoryLoadStatus"] $ "|4|9|";
	                       .And. oFim["exclusaoPrevistos"        ];
	                       .And. oFim["geracaoDocumentos"        ];
	                       .And. oFim["alcada"                   ];
	                       .And. oFim["rastreabilidadeDocumentos"];
	                       .And. oFim["sugestaoLote"             ];
	                       .And. oFim["integracaoMES"            ];
	                       .And. oFim["integracaoSFC"            ];
	                       .And. oFim["integracaoQIP"            ])
		If lAtlTela
			If slAtuMem
				slAtuMem := .F.

				cText := STR0322 // "Memória: "
				cText += i18n(STR0373, {scPicoMemo}) // "Pico: #1[picoMemoria]# MB"
				If _nMemLimit > 0
					cText += "; " + i18n(STR0374, {cValToChar(_nMemLimit)}) // "Limite: #1[limiteMemoria]# MB"
				EndIf
				cText += "."

				saStatus[__MEMORIA][1] := soOk
				saStatus[__MEMORIA][2] := cText
				saStatus[__MEMORIA][3] := STR0089 // "Concluido"

				oBrwWiz:SetArray(saStatus)
				oBrwWiz:Refresh()

				MrpAddPar(soParam["ticket"], "picoMemoria", Nil, scPicoMemo)
			EndIf

			soTimer:DeActivate()
		EndIf

		If lLogAtivo
			oLogs:finalizaGravacaoLogs()
		EndIf

		If oExcPrevis != Nil
			oExcPrevis:LimpaVarStatus()
		EndIf

		If snProgDoc >= 100 .And. !Empty(GetGlbValue(soParam["ticket"]+"UIDPRG_PCPA145"))
			ClearGlbValue(soParam["ticket"]+"UIDPRG_PCPA145")
		EndIf

		If snProgSugE >= 100 .And. !Empty(GetGlbValue(soParam["ticket"]+"PCPA151_STATUS"))
			ClearGlbValue(soParam["ticket"]+"PCPA151_STATUS")
		EndIf

		If slLock
			oPCPLock:unlock("MRP_MEMORIA", "PCPA712", soParam["ticket"])
		EndIf
	EndIf

	If oExcPrevis != Nil
		FreeObj(oExcPrevis)
		oExcPrevis := Nil
	EndIf

	FreeObj(oFim)
	FreeObj(oJsonAux)
	FreeObj(oProcesso)
	aSize(aReturn, 0)
	oJsonAux  := Nil
	oProcesso := Nil
	aReturn   := Nil

Return Nil

/*/{Protheus.doc} IsCancel
Indica se o MRP foi cancelado por outra sessão
@author brunno.costa
@since 31/07/2019
@version P12
@return lCancelado, logico, indica se o processamento do MRP foi cancelado
/*/
Static Function IsCancel()

	Local aReturn    := {}
	Local cMsgErro   := ""
	Local cMsgSoluc  := ""
	Local lCancelado := .F.
	Local oProcesso  := JsonObject():New()

	aReturn := MrpGet(cFilAnt, soParam["ticket"])
	oProcesso:fromJson(aReturn[2])

	//Se o processo foi cancelado
	If oProcesso["status"] == "4"

		//Cancelado por erro no reálculo de níveis
		If oProcesso["statusLevelsStructure"] == "9"
			cMsgErro := STR0183 //"Ocorreu um erro durante o recálculo dos níveis."
			If !Empty(oProcesso["message"])
				cMsgErro += CHR(10) + oProcesso["message"]
			EndIf
			cMsgSoluc := STR0102 //"Contate o administrador do sistema ou reabra o MRP e tente novamente."

		//Cancelado por erro na carga em memória
		ElseIf oProcesso["memoryLoadStatus"] == "9"
			cMsgErro := STR0184 //"Ocorreu um erro durante o caregamento dos dados."
			If !Empty(oProcesso["message"])
				cMsgErro += CHR(10) + oProcesso["message"]
			EndIf
			cMsgSoluc := STR0102 //"Contate o administrador do sistema ou reabra o MRP e tente novamente."

		Else
			cMsgErro  := STR0105 //"Execução cancelada a partir de outra conexão."
			cMsgSoluc := STR0106 //"Reabra o MRP e tente novamente."
		EndIf

		Help( ,  , "A712L" + cValToChar(ProcLine()), , cMsgErro, 1, 0, , , , , , {cMsgSoluc})
		lCancelado := .T.
	EndIf

	FreeObj(oProcesso)
	aSize(aReturn, 0)
	oProcesso := Nil
	aReturn   := Nil

Return lCancelado

/*/{Protheus.doc} ValidaPag1
Validação de campos - "Setup de Configuração"
@author douglas.heydt
@since 05/07/2019
@version P12
@param oStepWiz, objeto, instância da classe do wizard
@return lRet, lógico, indica se houveram problemas na tela
/*/
Function ValidaPag1(oStepWiz)
	Local lRet := .T.

	If soParam["TELA_1"]["VALIDADA"]
		Return .T.
	EndIf

	If IsCancel() //Valida cancelamento da execução
		Return .F.
	EndIf

	If Empty(soParam["demandStartDate"]) .Or. Empty(soParam["demandEndDate"])
		Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0023, ; //"Período informado inválido."
			1, 0, , , , , , {STR0138} ) //"Verifique a data de início e fim do período."
		Return .F.
	EndIf

	If soParam["demandStartDate"] > soParam["demandEndDate"]
		Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0023, ; //"Período informado inválido."
			1, 0, , , , , , {STR0024} ) //"Data Inicial deve ser menor que Data final."
		Return .F.
	EndIf

	If _lP712VLD
		lRet := ExecBlock("P712VLD",.F.,.F.,{"TELA_1",soParam:ToJson()})
	EndIf

	//O código não é obrigatório
	If lRet .And. Empty(soParam["TELA_1"]["HW2_CODIGO"])
		soParam["TELA_1"]["HW2_DESCRI"] := CriaVar("HW2_DESCRI")
	ElseIf lRet
		If Empty(soParam["TELA_1"]["HW2_DESCRI"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0034, ; //"Descrição do setup de configuração não informada."
				1, 0, , , , , , {STR0035} ) //"Informe a descrição do setup de configuração do MRP."
			Return .F.
		EndIf

		LoadSetup()

		//Se estiver marcado o check para pular para o processamento, marca a página como validada para não entrar em loop
		If soParam["TELA_1"]["CHECK_PULAR"]
			soParam['TELA_1']['CHECK_PULAR'] := .F.
			If !ValidaPag2() .Or. !ValidaPag3() .Or. !ValidaPag4(.F.) .Or. !ValidaPag5()
				lRet := .F.
			EndIf
			soParam['TELA_1']['CHECK_PULAR'] := .T.

			If lRet
				soParam["TELA_1"]["VALIDADA"] := .T.
				If oStepWiz <> Nil
					oStepWiz:NextPage()
					oStepWiz:NextPage()
					oStepWiz:NextPage()
					oStepWiz:NextPage()
				EndIf
			EndIf
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag2
Validação de campos - "Períodos"
@author douglas.heydt
@since 05/07/2019
@version P12
@return lRet, lógico, indica se houveram problemas na tela
/*/
Static Function ValidaPag2()

	Local lRet := .T.

	//Se foi marcado o check para pular para o processamento, não precisa validar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return .T.
	EndIf

	If IsCancel() //Valida cancelamento da execução
		Return .F.
	EndIf

	If Empty(soParam["numberOfPeriods"])
		Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0137, ; //"Número de períodos não informado."
			1, 0, , , , , , {STR0022} ) //"Por favor informe o número de períodos."
		Return .F.
	Else
		If Val(soParam["numberOfPeriods"]) <= 0
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0136, ; //"Número de períodos inválido."
				1, 0, , , , , , {STR0022} ) //"Por favor informe o número de períodos."
			soParam["numberOfPeriods"] := "0  "
			Return .F.
		EndIf
	EndIf

	If lRet .And. _lP712VLD
		lRet := ExecBlock("P712VLD",.F.,.F.,{"TELA_2",soParam:ToJson()})
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag3
Validação de campos - "Estoque"
@author brunno.costa
@since 15/07/2019
@version P12
@return lRet, lógico, indica se houveram problemas na tela
/*/
Static Function ValidaPag3()

	Local lRet := .T.

	//Se foi marcado o check para pular para o processamento, não precisa validar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return .T.
	EndIf

	If IsCancel() //Valida cancelamento da execução
		lRet := .F.
	EndIf

	If lRet .And. _lP712VLD
		lRet := ExecBlock("P712VLD",.F.,.F.,{"TELA_3",soParam:ToJson()})
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag4
Validação de campos - "Documentos"
@author marcelo.neumann
@since 08/03/2022
@version P12
@param lSemTela, lógico, indica se está executando sem tela
@return lRet, lógico, indica se houveram problemas na tela
/*/
Static Function ValidaPag4(lSemTela)
	Local lRet := .T.

	//Se foi marcado o check para pular para o processamento, não precisa validar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		Return .T.
	EndIf

	If AllTrim(soParam["consolidatePurchaseRequest"]) == "1" .And. ; //Aglutina Solicitação de Compras
	   AllTrim(soParam["consolidateProductionOrder"]) <> "1"         //Não Aglutina Ordem de Produção
		If !ValidaDic(lSemTela)
			Return .F.
		EndIf
	EndIf

	If IsCancel() //Valida cancelamento da execução
		lRet := .F.
	EndIf

	If lRet .And. _lP712VLD
		lRet := ExecBlock("P712VLD",.F.,.F.,{"TELA_4",soParam:ToJson()})
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag5
Validação de campos - "Seleção"
@author marcelo.neumann
@since 31/07/2019
@version P12
@return lRet, lógico, indica se houveram problemas na tela
/*/
Static Function ValidaPag5()

	Local lRet := .T.

	_lCrpOk := Iif(_lCrpOk == Nil, AliasInDic("HWF") .And. FindFunction('PCPA152'),_lCrpOk)

	//Se foi marcado o check para pular para o processamento, não precisa validar a tela
	If soParam["TELA_1"]["CHECK_PULAR"]
		IF soParam["documentType"]["PREVISTOS"] == "1" .And. _lCrpOk
			lRet := P712ExcOp()
		Else
			Return .T.
		Endif
	EndIf

	If IsCancel() //Valida cancelamento da execução
		Return .F.
	EndIf

	If !Empty(soParam["products"]["CODIGO"])
		If Empty(soParam["products"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0139, ; //"O Produto informado não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If !Empty(soParam["productGroups"]["CODIGO"])
		If Empty(soParam["productGroups"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0141, ; //"O Grupo de Materiais informado não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If !Empty(soParam["productTypes"]["CODIGO"])
		If Empty(soParam["productTypes"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0142, ; //"O Tipo de Material informado não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If !Empty(soParam["documents"]["CODIGO"])
		If Empty(soParam["documents"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0143, ; //"O Documento informado não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If !Empty(soParam["warehouses"]["CODIGO"])
		If Empty(soParam["warehouses"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0144, ; //"O Armazém informado não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO")) .AND. !Empty(soParam["demandCodes"]["CODIGO"])
		If Empty(soParam["demandCodes"]["RECNO"])
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0227, ; //"A Demanda informada não existe."
				1, 0, , , , , , {STR0140} ) //"Verifique o conteúdo do campo."
			Return .F.
		EndIf
	EndIf

	If lRet .And. soParam["documentType"]["PREVISTOS"] == "1" .And. _lCrpOk
		lRet := P712ExcOp()
	EndIf

	If lRet .And. _lP712VLD
		lRet := ExecBlock("P712VLD",.F.,.F.,{"TELA_5",soParam:ToJson()})
	EndIf

Return lRet

/*/{Protheus.doc} ValidaPag6
Validação da tela - "Execução"
@author brunno.costa
@since 15/07/2019
@version P12
@return lRet, lógico, indica se houveram problemas na tela
/*/
Static Function ValidaPag6()

	Local lRet := .T.

	If slError
		CancelExec(6)
	Else
		If IsCancel() //Valida cancelamento da execução
			Return .F.
		EndIf

		lRet := slConcluiu

		If !slConcluiu
			Help( ,  , "A712L" + cValToChar(ProcLine()), ,  STR0094, ; //"Execução em andamento."
				1, 0, , , , , , {STR0095} ) //"Aguarde a conclusão da execução ou cancele o processamento."
		Else
			slConcluiu := .F.
		EndIf
	EndIf

	If lRet .And. slAtuMem
		slAtuMem := .F.
		MrpAddPar(soParam['ticket'], "picoMemoria", Nil, scPicoMemo)
	EndIf

Return lRet

/*/{Protheus.doc} CancelExec
Cancela execução do cálculo do MRP
@author brunno.costa
@since 15/07/2019
@version P12
@param nTela, numérico, indica o número da tela que está sendo cancelada
@return lRet, lógico, indica se conseguiu finalizar o processamento
/*/
Static Function CancelExec(nTela)
	Local lRet      := .T.
	Local oParam    := JsonObject():New()
	Local cMsg      := ""

	If nTela == 6
		If saStatus[__PERSIST][3] <> STR0089 .And. ;//Concluído
		   (__GERARAST == 0 .Or. (__GERARAST > 0 .And. snProgRast <> 100))
			If !slError
				lRet := ApMsgYesNo(STR0159, STR0160) //"Você tem certeza que deseja sair?" "Cancelamento de Execução"
			EndIf
		EndIf
	EndIf

	If lRet
		//Seta parâmetros de ambiente
		oParam['cEmpAnt'] := cEmpAnt
		oParam['cFilAnt'] := cFilAnt
		oParam['user']    := RetCodUsr()
		oParam['ticket']  := soParam['ticket']

		//Abre Controle de Cancelamento Em Andamento
		VarSetUID( "A712Cancel_" + soParam["ticket"] )//Inicializa sessão de váriaveis globais
		scErrorUID  := Iif(scErrorUID == Nil, "PCPA712_MRP_" + soParam["ticket"], scErrorUID)
		soPCPError  := Iif(soPCPError == Nil, PCPMultiThreadError():New(scErrorUID, .T.), soPCPError)
		soPCPError:startJob("A712Cancel", GetEnvServer(), .F., cEmpAnt, cFilAnt, .F., .F., oParam:toJson())

		If isBlind()
			waitThCan(oParam)
		Else
			If nTela == 0
				cMsg := STR0379 // "Ocorreu um erro durante o processamento, finalizando a execução do MRP..."
			Else
				cMsg := STR0380 // "Finalizando a execução do MRP..."
			EndIf

			FWMsgRun(Nil, {|| waitThCan(oParam)}, STR0115, cMsg) // "Aguarde..."
		EndIf

		slConcluiu := .F.

		If nTela == 6 .And. slAtuMem
			If __GERA_DOC > 0 .And. saStatus[__GERA_DOC][3] == STR0090 //"Executando"
				lRet := ApMsgYesNo(STR0395, STR0160) //"A geração de documentos não pode ser cancelada. A tela será fechada mas o processamento continuará em segundo plano. Deseja fechar essa tela?" "Cancelamento de Execução"
			EndIf

			If lRet .And. slAtuMem
				slAtuMem := .F.
				MrpAddPar(soParam['ticket'], "picoMemoria", Nil, scPicoMemo)
			EndIf
		EndIf
	EndIf

	FreeObj(oParam)
	oParam := Nil

Return lRet

/*/{Protheus.doc} waitThCan
Aguarda inicialização da thread que executa a função de cancelamento, se a thread não iniciar executa a função.
@type  Static Function
@author Lucas Fagundes
@since 04/06/2024
@version P12
@param oParam, Object, Json com os parâmetros para executar a função de cancelamento em single thread.
@return Nil
/*/
Static Function waitThCan(oParam)
	Local oDominio := Nil

	If !soPCPError:abriuUltimaThread()
		oDominio := MRPPrepDom(soParam["ticket"])

		LogMsg('PCPA712', 0, 0, 1, '', '', i18n("[#1[data]#] - #2[hora]#] - Não foi possível abrir thread para executar a função #3[nomeFunção]#. Executando em thread única.", {DToC(Date()), Time(), "A712Cancel"}))
		A712Cancel(.F., .F., oParam:toJson())

		oDominio := Nil
	EndIf

Return Nil

/*/{Protheus.doc} LoadSetup
Carrega os parâmetros de acordo com o que está cadastrado
@author douglas.heydt
@since 05/07/2019
@version P12
@return Nil
/*/
Static Function LoadSetup()

	Local cAliasQry := GetNextAlias()
	Local cCodBusca := soParam["TELA_1"]["HW2_CODIGO"]

	//Se for uma cópia, busca com o código do setup selecionado na tela de Consulta
	If soParam["TELA_1"]["OPERACAO"] == IND_OPERACAO_COPIAR
		cCodBusca := soParam["TELA_1"]["TELA_CONSULTA"]:GetCodigo()
	EndIf

	//Só recarrega se foi alterado o setup
	If !Empty(scSetupAnt) .And. scSetupAnt == cCodBusca
		Return Nil
	EndIf

	scSetupAnt := cCodBusca

	BeginSql Alias cAliasQry
		SELECT HW2_FILIAL,
			   HW2_CODIGO,
			   HW2_PARAM,
			   HW2_VALOR,
			   HW2_LISTA
		  FROM %Table:HW2%
		 WHERE HW2_FILIAL = %xFilial:HW2%
		   AND HW2_CODIGO = %Exp:cCodBusca%
		   AND %NotDel%
	EndSql

	While !(cAliasQry)->(Eof())
		//Se o parâmetro for da Tela 1, já foi carregado
		If !AllTrim((cAliasQry)->HW2_PARAM) $ PARAM_NA_TELA_1 .and. !AllTrim((cAliasQry)->HW2_PARAM) $ "|user|cEmpAnt|cFilAnt|"
			//Se o parâmetro existe na tela
			If soParam[AllTrim((cAliasQry)->HW2_PARAM)] <> Nil
				//Se o parâmetro é exibido na tela como checkbox
				If AllTrim((cAliasQry)->HW2_PARAM) $ CAMPOS_CHECK_MULTI
					soParam[AllTrim((cAliasQry)->HW2_PARAM)]["VALOR"] := RTrim((cAliasQry)->HW2_VALOR)

				//Se o parâmetro é exibido no formato de multivalorado
				ElseIf AllTrim((cAliasQry)->HW2_PARAM) $ scCMPMULTI
					soParam[AllTrim((cAliasQry)->HW2_PARAM)]["LISTA"]  := AllTrim((cAliasQry)->HW2_LISTA)
					soParam[AllTrim((cAliasQry)->HW2_PARAM)]["CODIGO"] := Lista2Cod(AllTrim((cAliasQry)->HW2_PARAM))

				//Preenche a variável convertendo para o tipo da tela
				Else
					soParam[AllTrim((cAliasQry)->HW2_PARAM)] := ConvertCol(AllTrim((cAliasQry)->HW2_PARAM), (cAliasQry)->HW2_VALOR, .F.)
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

	//Parâmetros que sempre devem ser carregados com valores atualizados (não informados em tela)
	soParam["mrpStartDate"       ] := dDataBase
	soParam["structurePrecision" ] := TamSX3("G1_QUANT")[2]
	soParam["branchCentralizing" ] := Nil
	soParam["centralizedBranches"] := Nil
	addFiliais()

	If _lMEFilDes == .F. .And. Len(saFiliais) > 1
		soParam["lRastreiaEntradas"] := .F.
	EndIf

	//Marca/Desmarca os checkboxs de acordo com a tabela
	TrataParam(.T.)

Return Nil

/*/{Protheus.doc} TrataParam
Trata os checkboxs da tela
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 lLoad, lógico, indica se está sendo feito a carga (true) ou a gravação (false) do parâmetro
@return Nil
/*/
Static Function TrataParam(lLoad)

	If lLoad
		soParam["demandType"   ]["PEDIDO_VENDA" ] := IIf("1" $ soParam["demandType"  ]["VALOR"], .T., .F.)
		soParam["demandType"   ]["PREV_VENDAS"  ] := IIf("2" $ soParam["demandType"  ]["VALOR"], .T., .F.)
		soParam["demandType"   ]["PLANO_MESTRE" ] := IIf("3" $ soParam["demandType"  ]["VALOR"], .T., .F.)
		soParam["demandType"   ]["EMP_PROJETO"  ] := IIf("4" $ soParam["demandType"  ]["VALOR"], .T., .F.)
		soParam["demandType"   ]["MANUAL"       ] := IIf("9" $ soParam["demandType"  ]["VALOR"], .T., .F.)

		If "|1.1|" $ soParam["documentType"]["VALOR"]
			soParam["documentType" ]["PREVISTOS"    ] := "1"
		ElseIf "|1.2|" $ soParam["documentType"]["VALOR"]
			soParam["documentType" ]["PREVISTOS"    ] := "2"
		ElseIf "|1.3|" $ soParam["documentType"]["VALOR"]
			soParam["documentType" ]["PREVISTOS"    ] := "3"
		EndIf
		soParam["documentType" ]["SUSPENSOS"    ] := IIf("|2|" $ soParam["documentType"]["VALOR"], .T., .F.)
		soParam["documentType" ]["SACRAMENTADOS"] := IIf("|3|" $ soParam["documentType"]["VALOR"], .T., .F.)
		soParam["documentType" ]["REJEITADOS"   ] := IIf("|4|" $ soParam["documentType"]["VALOR"], .T., .F.)

		GetDesMul("SB1", "B1_DESC"   , "products"     )
		GetDesMul("SBM", "BM_DESC"   , "productGroups")
		GetDesMul("SX5", "X5_DESCRI" , "productTypes" )
		GetDesMul("SVR", "VR_DOC"    , "documents", 5, , .F.)
		GetDesMul("NNR", "NNR_DESCRI", "warehouses"   )

		If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
			GetDesMul("SVB", "VB_CODIGO"  , "demandCodes",,, .F.)
		EndIf
	Else
		soParam["demandType"  ]["VALOR"] := IIf(soParam["demandType"  ]["PEDIDO_VENDA" ], "1", " ") + ; // 1-Pedido de Venda
										    IIf(soParam["demandType"  ]["PREV_VENDAS"  ], "2", " ") + ; // 2-Previsão de Vendas
										    IIf(soParam["demandType"  ]["PLANO_MESTRE" ], "3", " ") + ; // 3-Plano Mestre
										    IIf(soParam["demandType"  ]["EMP_PROJETO"  ], "4", " ") + ; // 4-Empenhos de Projeto
										    IIf(soParam["demandType"  ]["MANUAL"       ], "9", " ")     // 9-Manual

		soParam["documentType"]["VALOR"] := "|" + IIf(soParam["documentType"]["PREVISTOS"    ] == "1", "1.1",  "") + ;      // 1-Previstos -> 1.1 Exclui
		                                          IIf(soParam["documentType"]["PREVISTOS"    ] == "2", "1.2",  "") + ;      // 2-Previstos -> 1.2 Não Exclui
		                                          IIf(soParam["documentType"]["PREVISTOS"    ] == "3", "1.3",  "") + ;      // 3-Previstos -> 1.3 Entra no MRP
										    "|" + IIf(soParam["documentType"]["SUSPENSOS"    ]       ,   "2", " ") + ;      // 2-Suspensos
										    "|" + IIf(soParam["documentType"]["SACRAMENTADOS"]       ,   "3", " ") + "|" +; // 3-Sacramentados
											"|" + IIf(soParam["documentType"]["REJEITADOS"   ]       ,   "4", " ") + "|"    // 4-Rejeitados
	EndIf

Return Nil

/*/{Protheus.doc} ConvertCol
Converte a coluna de acordo com o tipo de dado
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 cParam   , caracter  , parâmetro a ser convertido
@param 02 xValor   , indefinido, valor a ser convertido
@param 03 lGravacao, lógico    , indica se deve converter para String ou não
@return   xCampo   , indefinido, campo convertido
/*/
Static Function ConvertCol(cParam, xValor, lGravacao)

	Local xCampo := " "

	//Campos data
	If AllTrim(cParam) $ CAMPOS_DATA
		xCampo := IIf(lGravacao, DToS(xValor), SToD(xValor))

	//Campos numéricos
	ElseIf AllTrim(cParam) $ CAMPOS_NUM
		xCampo := IIf(lGravacao, cValToChar(xValor), Val(xValor))

	//Campos multivalorados
	ElseIf cParam $ scCMPMULTI
		xCampo := " "

	//Campos checkbox simples
	ElseIf cParam $ CAMPOS_CHECK_SIMPLES
		If lGravacao
			xCampo := IIf(xValor, "1", "2")
		Else
			xCampo := IIf(AllTrim(xValor) == "1", .T., .F.)
		EndIf

	//Campos checkbox compostos (mais de um check para o mesmo parâmetro)
	ElseIf cParam $ CAMPOS_CHECK_MULTI
		xCampo := xValor["VALOR"]

	//Campos string.
	Else
		xCampo := xValor
	EndIf

Return xCampo

/*/{Protheus.doc} GravaHW2
Realiza a gravação dos dados na tabela
@author douglas.heydt
@since 05/07/2019
@version P12
@return lOk, lógico, indica se gravou os dados com sucesso
/*/
Static Function GravaHW2()

	Local aAreaHW2 := HW2->(GetArea())
	Local aInsert  := {}
	Local aNames   := soParam:GetNames()
	Local lOk      := .T.
	Local nIndex   := 0

	//Caso o cenário já exista, atualiza os parâmetros existentes, caso um parâmetro não exista, ele é inserido
	If HW2->(dbSeek(xFilial("HW2") + soParam["TELA_1"]["HW2_CODIGO"]))
		//Percorre os parâmetros da tela
		For nIndex := 1 To Len(aNames)
			If aNames[nIndex] $ "|user|ticket|TELA_1|branchCentralizing|centralizedBranches|serverMemoryLimit|heapLimit|cEmpAnt|cFilAnt|" .Or. soParam[aNames[nIndex]] == Nil
				Loop
			EndIf

			cValor := ConvertCol(aNames[nIndex], soParam[aNames[nIndex]], .T.)

			//Verifica se o parâmetro existe (altera) ou não (insere)
			If HW2->(dbSeek(xFilial("HW2") + soParam["TELA_1"]["HW2_CODIGO"] + aNames[nIndex]))
				HW2->(RecLock("HW2",.F.))
					HW2->HW2_DESCRI := soParam["TELA_1"]["HW2_DESCRI"]

					If aNames[nIndex] $ scCMPMULTI
						HW2->HW2_LISTA := TrataLista(aNames[nIndex])
					Else
						HW2->HW2_VALOR := cValor
					EndIf
				HW2->(MsUnLock())
			Else
				aAdd(aInsert, {xFilial("HW2")                 , ;
                               soParam["TELA_1"]["HW2_CODIGO"], ;
                               soParam["TELA_1"]["HW2_DESCRI"], ;
							   PadR(aNames[nIndex], snTamPar) , ;
                               cValor                         , ;
							   TrataLista(aNames[nIndex])    })
			EndIf
		Next nIndex
	Else
		For nIndex := 1 To Len(aNames)
			If aNames[nIndex] $ "|user|ticket|TELA_1|branchCentralizing|centralizedBranches|serverMemoryLimit|heapLimit|cEmpAnt|cFilAnt|" .Or. soParam[aNames[nIndex]] == Nil
				Loop
			EndIf

			cValor := ConvertCol(aNames[nIndex], soParam[aNames[nIndex]], .T.)

			aAdd(aInsert, {xFilial("HW2")                 , ;
			               soParam["TELA_1"]["HW2_CODIGO"], ;
						   soParam["TELA_1"]["HW2_DESCRI"], ;
						   PadR(aNames[nIndex], snTamPar) , ;
                           cValor                         , ;
						   TrataLista(aNames[nIndex])     })
		Next nIndex
	EndIf

	If Len(aInsert) > 0
		If TCDBInsert(RetSqlname("HW2"), "HW2_FILIAL,HW2_CODIGO,HW2_DESCRI,HW2_PARAM,HW2_VALOR,HW2_LISTA", aInsert) < 0
			Final("Erro", TCSqlError())
			lOk := .F.
		EndIf
	EndIf

	HW2->(RestArea(aAreaHW2))

Return lOk

/*/{Protheus.doc} Lista2Cod
Retorna o campo Código de acordo com o campo Lista
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 cParam  , caracter, indicador do parâmetro
@return   cConvert, caracter, campo lista convertido
/*/
Static Function Lista2Cod(cParam)

	Local aLista   := {}
	Local cConvert := ""

	If !Empty(soParam[cParam]["LISTA"])
		aLista := StrTokArr(soParam[cParam]["LISTA"], SEPARADOR)

		If Len(aLista) == 1
			If At(";", aLista[1]) == Len(cFilAnt) + 1
				cConvert := SubStr(aLista[1], Len(cFilAnt) + 2)
			Else
				cConvert := aLista[1]
			EndIf
		EndIf
	EndIf
	cConvert := PadR(cConvert, Len(soParam[cParam]["CODIGO"]))

Return cConvert

/*/{Protheus.doc} TrataLista
Trata o campo Lista para inserir no banco
@author marcelo.neumann
@since 31/07/2019
@version P12
@param cParam , caracter, indicador do parâmetro
@return cLista, caracter, campo lista convertido
/*/
Static Function TrataLista(cParam)

	Local cLista := ""

	If cParam $ scCMPMULTI
		If Empty(soParam[cParam]["CODIGO"])
			If !Empty(soParam[cParam]["LISTA"])
				cLista := AllTrim(soParam[cParam]["LISTA"])
			EndIf
		ElseIf Empty(soParam[cParam]["LISTA"]) .Or. Empty(StrTran(soParam[cParam]["LISTA"], SEPARADOR, " "))
			cLista := SEPARADOR + AllTrim(soParam[cParam]["CODIGO"]) + SEPARADOR
		Else
			cLista := AllTrim(soParam[cParam]["LISTA"])
		EndIf
		soParam[cParam]["LISTA"] := cLista
	EndIf

Return cLista

/*/{Protheus.doc} AtDesSetup
Atualiza campo descrição do setup de configuração
@author douglas.heydt
@since 05/07/2019
@version P12
@param oWnd, objeto, objeto de tela para realizar o refresh
@param lSchdl, logic, indica se está executando em schedule (não irá atualizar a tela).
@return .T., lógico, retorna true para permitir sair do campo
/*/
Static Function AtDesSetup(oWnd, lSchdl)

	Local aAreaHW2
	Local lRet := .T.

	dbSelectArea("HW2")
	aAreaHW2 := HW2->(GetArea())

	//Se não tiver Código preenchido, não deve habilitar o check
	If Empty(soParam["TELA_1"]["HW2_CODIGO"])
		soParam["TELA_1"]["CHECK_PULAR"] := .F.
		If !lSchdl
			HabCheck(.F.)
		EndIf
	Else
		If HW2->(dbSeek(xFilial("HW2") + soParam["TELA_1"]["HW2_CODIGO"]))
			//Se o código digitado já existe e estiver sendo feita uma cópia, questiona se deve ser abortada a cópia
			If soParam["TELA_1"]["OPERACAO"] == IND_OPERACAO_COPIAR
				If !lSchdl .and. ApMsgYesNo(STR0163 + cCRLF + ;                                                        //"Já existe um Setup com o código informado.",
								STR0164 + AllTrim(soParam["TELA_1"]["TELA_CONSULTA"]:GetCodigo()) + "?", ; //"Deseja abortar a operação de CÓPIA do setup "
								STR0165)                                                                   //"Setup já cadastrado"
					soParam["TELA_1"]["OPERACAO"   ] := IND_OPERACAO_SELECIONAR
					soParam["TELA_1"]["HW2_DESCRI" ] := HW2->HW2_DESCRI
					soParam["TELA_1"]["CHECK_PULAR"] := .T.
					If !lSchdl
						HabCheck(.T.)
					EndIf
				Else
					soParam["TELA_1"]["HW2_CODIGO"] := CriaVar("HW2_CODIGO")
					lRet := .F.
				EndIf
			Else
				soParam["TELA_1"]["HW2_DESCRI" ] := HW2->HW2_DESCRI
				soParam["TELA_1"]["CHECK_PULAR"] := .T.
				If !lSchdl
					HabCheck(.T.)
				EndIf
			EndIf

			LoadTela1(soParam["TELA_1"]["HW2_CODIGO"])
		Else
			soParam["TELA_1"]["CHECK_PULAR"] := .F.
			If !lSchdl
				HabCheck(.F.)
			EndIf
		EndIf
	EndIf

	If !lSchdl
		oWnd:RefreshConstrols()
	EndIf
	HW2->(RestArea(aAreaHW2))

Return lRet

/*/{Protheus.doc} GetDesMul
Busca e carrega a descrição do campo (multivalorado)
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 cAlias    , caracter, alias a ser pesquisado
@param 02 cCampoDes , caracter, campo do alias referente à descrição
@param 03 cParam    , caracter, indicador do parâmetro (campo multivalorado)
@param 04 nOrdIndex , numérico, número do índice a ser utilizado no dbSeek
@param 05 lSelecao  , logico  , indica que está executando após a seleção do zoom multivalorado.
@param 06 lLimpaList, logico  , indica se deve limpar o conteúdo da lista
@return .T., lógico, retorna true para permitir sair do campo
/*/
Static Function GetDesMul(cAlias, cCampoDes, cParam, nOrdIndex, lSelecao, lLimpaList)

	Local aArea      := {}
	Local aLista     := {}
	Local cChave     := AllTrim(soParam[cParam]["CODIGO"])
	Local cDescricao := ""
	Local cPesquisa  := ""
	Local lAchou     := .F.
	Local lEmBranco  := .F.
	Local nIndex     := 0
	Local nRecno     := 0
	Local nTamFil    := 0
	Local nTotal     := 0

	Default nOrdIndex  := 1
	Default lSelecao   := .F.
	Default lLimpaList := .T.

	//Valida se o código está preenchido
	If Empty(cChave)
		If !Empty(soParam[cParam]["LISTA"])
			aLista := StrTokArr2(SubStr(soParam[cParam]["LISTA"], 2, Len(soParam[cParam]["LISTA"])-2), SEPARADOR, .F.)
			//Para o campo Grupo Material, existe a opção de selecionar grupos em branco
			If cParam == "productGroups"
				If Empty(aLista) .Or. Len(aLista) == 1 .And. Empty(aLista[1])
					cDescricao := STR0182 //"Grupo não informado"
					lEmBranco  := .T.
				ElseIf Empty(aLista) .Or. Len(aLista) == 1
					soParam[cParam]["LISTA"] := ""
				EndIf
				aSize(aLista, 0)
			ElseIf Empty(aLista) .Or. Len(aLista) == 1
				soParam[cParam]["LISTA"] := ""
			EndIf
		EndIf
	Else
		dbSelectArea(cAlias)
		aArea := (cAlias)->(GetArea())

		//Para o campo Tipo Material, deve ser adicionado o indicador '02' da tabela (x5_tabela)
		If cParam == "productTypes"
			cChave    := "02" + Iif(soParam[cParam]["TAM_COD"] > 0, PadR(cChave,soParam[cParam]["TAM_COD"]), cChave)
			cPesquisa := xFilial(cAlias) + cChave
		Else
			cPesquisa := xFilial(cAlias) + Iif(soParam[cParam]["TAM_COD"]>0,PadR(cChave,soParam[cParam]["TAM_COD"]), cChave)
		EndIf

		//Verifica se é uma seleção de registro com multi-empresa.
		If lSelecao                                                  .And. ;
		   !Empty(soParam[cParam]["LISTA"])                          .And. ;
		   !Empty(StrTran(soParam[cParam]["LISTA"], SEPARADOR, " ")) .And. ;
		   At(";", soParam[cParam]["LISTA"]) == Len(cFilAnt) + 2
			//Se a chave da LISTA possui a filial, irá utilizar o conteúdo da LISTA para fazer a pesquisa.
			cPesquisa  := soParam[cParam]["LISTA"]
			cPesquisa  := StrTran(cPesquisa, SEPARADOR, "")
			cPesquisa  := SubStr(cPesquisa, 1, Len(cFilAnt)) + ;
			              Iif(soParam[cParam]["TAM_COD"] > 0, ;
			              PadR(SubStr(cPesquisa, Len(cFilAnt)+2), soParam[cParam]["TAM_COD"]), ;
			              SubStr(cPesquisa, Len(cFilAnt)+2))
			lLimpaList := .F.
		EndIf

		//Pesquisa o conteúdo
		(cAlias)->(dbSetOrder(nOrdIndex))
		lAchou := (cAlias)->(dbSeek(cPesquisa))

		nTotal := Len(saFiliais)
		If !lAchou .And. nTotal > 1
			nIndex  := 2
			nTamFil := FWSizeFilial()

			While !lAchou .And. nIndex <= nTotal
				cPesquisa := xFilial(cAlias, saFiliais[nIndex]) + SubStr(cPesquisa, nTamFil+1)
				lAchou := (cAlias)->(dbSeek(cPesquisa))
				nIndex++
			End
		EndIf

		If lAchou
			//Se encontrou, preenche a descrição e limpa o campo Lista
			cDescricao               := (cAlias)->&(cCampoDes)
			nRecno                   := (cAlias)->(Recno())
			If lLimpaList
				soParam[cParam]["LISTA"] := ""
			EndIf
		Else
			//Se não encontrou mas estava selecionada uma lista, limpa a seleção
			If !Empty(soParam[cParam]["LISTA"]) .And. lLimpaList
				soParam[cParam]["LISTA"] := ""
			EndIf
		EndIf

		(cAlias)->(RestArea(aArea))
	EndIf

	//Preenche o campo de Descrição
	If Empty(soParam[cParam]["LISTA"]) .Or. lEmBranco .Or. (!lLimpaList .And. !Empty(cDescricao))
		If cCampoDes != "Recno()"
			soParam[cParam]["DESCRICAO"] := PadR(cDescricao, TAMANHO_DESC)
		EndIf
		soParam[cParam]["RECNO"    ] := nRecno
	Else
		soParam[cParam]["DESCRICAO"] := PadR(STR0145, TAMANHO_DESC) //"< seleção múltipla >"
		soParam[cParam]["RECNO"    ] := -1
	EndIf

Return .T.

/*/{Protheus.doc} AbreFiltro
Abre a tela de filtro/seleção multivalorado
@author marcelo.neumann
@since 31/07/2019
@version P12
@param 01 cParametro, caracter, indicador do parâmetro (campo multivalorado)
@return Nil
/*/
Static Function AbreFiltro(cParametro)

	Local aPreSelect
	Local aSelected  := {}
	Local cCodigo    := ""
	Local cDescricao := ""
	Local cLista     := ""
	Local nInd       := 0
	Local nQtdSelect := 0
	Local nPosChave  := 0

	//Verifica se exite algum registro selecionado
	If Empty(soParam[cParametro]["CODIGO"])
		If Empty(soParam[cParametro]["LISTA"])
			aPreSelect := {}
		Else
			aPreSelect := StrTokArr2(SubStr(soParam[cParametro]["LISTA"], 2, Len(soParam[cParametro]["LISTA"])-2), SEPARADOR, .F.)
			If Empty(aPreSelect)
				aAdd(aPreSelect, " ")
			EndIf
		EndIf
	ElseIf Empty(soParam[cParametro]["LISTA"]) .Or. Empty(StrTran(soParam[cParametro]["LISTA"], SEPARADOR, " "))
		aPreSelect := {soParam[cParametro]["CODIGO"]}
	Else
		aPreSelect := StrTokArr2(SubStr(soParam[cParametro]["LISTA"], 2, Len(soParam[cParametro]["LISTA"])-2), SEPARADOR, .F.)
	EndIf

	//Seta os registros que devem vir pré-selecionados
	soParam[cParametro]["FILTER"]:SetPreSelected(aPreSelect)

	//Abre a tela de filtro multivalorado
	If soParam[cParametro]["FILTER"]:AbreTela() .And. soParam[cParametro]["FILTER"]:selecaoAlterada()
		//Se a tela foi confirmada, busca os registros selecionados
		aSelected  := soParam[cParametro]["FILTER"]:GetSelected()
		nQtdSelect := Len(aSelected)

		If nQtdSelect > 0
			nPosChave := aScan(aSelected[1], {|x| x[1] == "CHAVE"})
		EndIf
		If nPosChave == 0
			nPosChave := 1
		EndIf

		//Se foi selecionado somente 1 registro
		If nQtdSelect == 1
			If aSelected[1][nPosChave][2] == IND_EMPTY
				cCodigo := " "
				cLista  := SEPARADOR + cCodigo + SEPARADOR
			Else
				cCodigo := aSelected[1][1][2]
				cLista  := SEPARADOR + RTrim(aSelected[1][nPosChave][2]) + SEPARADOR
			EndIf
			If "|" + cParametro + "|" $ "|demandCodes|documents|"
				cDescricao := aSelected[1][1][2]
			Else
				cDescricao := aSelected[1][2][2]
			EndIf

		//Se foram selecionados mais de 1 registro, indica a múltipla seleção na descrição e preenche a lista
		ElseIf nQtdSelect > 1
			cDescricao := PadR(STR0145, TAMANHO_DESC) //"< seleção múltipla >"
			cLista     := SEPARADOR
			cCodigo    := " "
			For nInd := 1 To nQtdSelect
				If aSelected[nInd][nPosChave][2] == IND_EMPTY
					cLista += " " + SEPARADOR
				Else
					cLista += RTrim(aSelected[nInd][nPosChave][2]) + SEPARADOR
				EndIf
			Next nInd
		EndIf

		soParam[cParametro]["CODIGO"   ] := PadR(cCodigo   , Len(soParam[cParametro]["CODIGO"]))
		soParam[cParametro]["DESCRICAO"] := PadR(cDescricao, TAMANHO_DESC)
		soParam[cParametro]["LISTA"    ] := cLista

		If nQtdSelect == 1
			soParam[cParametro]["RECNO"] := GetDesMul(soParam[cParametro]["FILTER"]:cAlias, "Recno()", cParametro, soParam[cParametro]["FILTER"]:nIndice, .T., .F.)
		Else
			soParam[cParametro]["RECNO"] := -1
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} canStart
Chama API de Inicialização da Carga em Memória
e Verifica Disponibilidade do MRP

@type  Function
@author brunno.costa
@since 29/05/2019
@version P12.1.27
@param 01 - oParametros, Object, Json com os parâmetros para a execução em modo schedule.
@param 02 - lCancel, Logic, Indica se irá cancelar o ticket reservado (caso esteja executando em modo schedule)
@param 03 - lIntegra, Logic, Indica se irá realizar a integração, caso haja pendencias de integração (caso esteja executando em modo schedule)
@return Nil
/*/
Static Function canStart(oParametros, lCancel, lIntegra)
	Local aReturn  := {}
	Local cUser    := ""
	Local lReturn  := .T.
	Local lSchdl   := oParametros <> Nil
	Local oBody    := JsonObject():New()
	Local oJsonRet := JsonObject():New()
	Local oLogs    := Nil
	Local oPCPLock := PCPLockControl():New()
	Local oStatus  := Nil

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera  := 3

	Default oParametros := Nil

	If !lSchdl
		oBody["branchId"] := cFilAnt
		oBody["user"    ] := RetCodUsr()
		cUser := AllTrim(RetCodUsr())
	Else
		oBody["branchId"] := oParametros["cFilAnt"]
		oBody["user"] := oParametros["user"]
		cUser := oParametros["user"]
	EndIf

	//Converte soParam em Array para API
	oBody["listOfMRPParameters"] := TOParamAPI(, .T.)

	aReturn := MrpPStart(oBody)
	oJsonRet:fromJson(aReturn[2])
	lReturn := oJsonRet["lResult"]

	If lReturn
		//Atribui ticket atual no controle estático
		soParam["ticket"] := oJsonRet["ticket"]

	Else
		If AllTrim(oJsonRet["user"]) == cUser
			If VarIsUID("A712Cancel_" + oJsonRet["ticket"])
				If !lSchdl
					FWMsgRun(,{|| WaitCancel(oJsonRet["ticket"]) },STR0115, STR0116 + " '" + oJsonRet["ticket"] + "'.")
				Else
					WaitCancel(oJsonRet["ticket"])
				EndIf
				Return canStart(oParametros, lCancel, lIntegra)

			ElseIf !lSchdl .and. ApMsgYesNo(STR0113 + "'" + oJsonRet["ticket"] + "'. " + STR0114)
				//"Você reservou anteriormente o MRP no ticket
				//Deseja cancelar a execução para iniciar um novo processamento?"
				soParam["ticket"] := oJsonRet["ticket"]

				//"Aguarde..." - "Cancelando execução do MRP"
				FWMsgRun(,{|| A712Cancel(@lReturn, .T.) },STR0115, STR0116 + " '" + oJsonRet["ticket"] + "'.")
			ElseIf lSchdl .and. lCancel
				soParam["ticket"] := oJsonRet["ticket"]

				A712Cancel(@lReturn, .T.)
			Else
				If lSchdl
					LogMsg('canStart', 0, 0, 1, '', '', STR0113 + "'" + oJsonRet["ticket"] + "'. ")
					Help(' ',1,"A712L" + cValToChar(ProcLine()) ,,STR0113,2,0,,,,,, {STR0378}) // "Você reservou anteriormente o MRP no ticket"
				EndIf
				lReturn := .F.
			EndIf
		Else
			If !Empty(oJsonRet["ticket"])
				Help(' ',1,"A712L" + cValToChar(ProcLine()) ,,STR0109 + "'" + AllTrim(UsrFullName(oJsonRet["user"])) + STR0110 + "'" + oJsonRet["ticket"] + "'.",2,0,,,,,, {STR0111 + "'" + AllTrim(UsrFullName(oJsonRet["user"])) + STR0112})
				//"O MRP está em execução pelo usuário '" + "' no ticket '"
				//"Aguarde o término da execução ou solicite ao '" + "' o cancelamento."
			Else
				LogMsg('canStart', 0, 0, 1, '', '', oJsonRet:toJson())
				Help(' ',1,"A712L" + cValToChar(ProcLine()) ,,STR0339 + cCRLF + STR0340 + oJsonRet["message"] + cCRLF,2,0,,,,,, {STR0341}) // "Erro ao reservar o ticket do MRP."  "<b>Motivo:</b> " "Consulte 'console.log' para mais informações."
			EndIf
		EndIf
	EndIf

	If lReturn
		oStatus  := MrpDados_Status():New(soParam["ticket"])
		oStatus:setStatus("tempo_selecao_parametros_tela", MicroSeconds())

		VarSetUID( soParam["ticket"] + "JOB_SYNC" )//Inicializa sessão de váriaveis globais

		oLogs := MrpDados_Logs():New()
		oLogs:iniciaGravacaoLogs(soParam["ticket"], scLogMrp)

		If snMrpSinc == 3
			If !PCPLockSinc("VALID", soParam["ticket"])
				//Se existe outra sincronização iniciada, exibe a tela de acompanhamento
				If !mostraSinc(lSchdl)
					lReturn := .F.
				EndIf
			EndIf

			If lReturn
				slSincroni := .T.

				//Registra no controle de locks o início do PCPA712, caso consiga lock no semaforo
				slLock := oPCPLock:lock("MRP_MEMORIA", "PCPA712",  soParam["ticket"], .T., {"PCPA146"},,,DEFAULT_nMSG_LOCK_ERROR)

				PutGlbValue(soParam["ticket"]+"PERCENTUALSINC", "-1") //-1 = Variavel foi instanciada, ainda pendente de termino da sincronizacao

				VarSetAD( soParam["ticket"] + "JOB_SYNC", "statusSync", {.F.} )

				scErrorUID  := Iif(scErrorUID == Nil, "PCPA712_MRP_" + soParam["ticket"], scErrorUID)
				soPCPError  := Iif(soPCPError == Nil, PCPMultiThreadError():New(scErrorUID, .T.), soPCPError)

				soPCPError:startJob("MRPVldJob", GetEnvServer(), .F., cEmpAnt, cFilAnt, soParam["ticket"])
			EndIf
		Else
			//Registra no controle de locks o início do PCPA712 - 3 - Aguarda para fazer lock e exibe tela de aguarde;
			slLock := oPCPLock:lock("MRP_MEMORIA", "PCPA712",  soParam["ticket"], .T., {"PCPA146"}, nEspera,,DEFAULT_nMSG_LOCK_ERROR)
			oPCPLock:lock("MRP_MEMORIA", "PCPA140",  soParam["ticket"], .F.)          //Incluido lock manual sem exclusividade no PCPA140 para impedir abertura deste por outras Threads enquanto houver a transferencia do lock para o PCPA141
			oPCPLock:transfer("MRP_MEMORIA", "PCPA712", "PCPA141", soParam["ticket"]) //Transfere propriedade do lock para rotina PCPA141

			VarSetAD( soParam["ticket"] + "JOB_SYNC", "statusSync", {.F.} )
			MRPVldSync(.T., , ,.F., soParam["ticket"], @lReturn) //Verifica se é necessário executar a sincronização para alguma API, de acordo com o conteúdo do campo T4P_ALTER.

			If lReturn
				MRPVldTrig(.T., , .F., , .T., , , lSchdl, lIntegra, soParam["ticket"], @lReturn)

				slSincroni := PCPStatPrc(soParam["ticket"])
				If slSincroni
					PutGlbValue(soParam["ticket"]+"PERCENTUALSINC", "-1")
					oLogs:gravaLog("sincronizacao", "PCPA141 - Integracao das pendencias", {"Inicio da sincronizacao"})
					oStatus:setStatus("tempo_sincronizacao_inicio", MicroSeconds())
				EndIf
			EndIf

			oPCPLock:transfer("MRP_MEMORIA", "PCPA141", "PCPA712", soParam["ticket"]) //Retorna propriedade do lock para rotina PCPA141
			oPCPLock:unlock("MRP_MEMORIA", "PCPA140",  soParam["ticket"])             //Remocao do lock no PCPA140 quando o lock já retornou para o PCPA712
		EndIf

		//Inicia processamento da carga em memória.
		If lReturn
			oBody["ticket"] := soParam["ticket"]
			scErrorUID      := Iif(scErrorUID == Nil, "PCPA712_MRP_" + soParam["ticket"], scErrorUID)
			soPCPError      := Iif(soPCPError == Nil, PCPMultiThreadError():New(scErrorUID, .T.), soPCPError)
			soPCPError:startJob("MRPIniCarg", GetEnvServer(), .F., cEmpAnt, cFilAnt, oBody:ToJson())
		Else
			A712Cancel(.F., .F.)
		EndIf
	EndIf

	FreeObj(oBody)
	FreeObj(oJsonRet)
	aSize(aReturn, 0)
	oBody    := Nil
	oJsonRet := Nil
	aReturn  := Nil

Return lReturn

/*/{Protheus.doc} WaitCancel
Aguarda Cancelamento Anterior

@type  Function
@author brunno.costa
@since 26/03/2020
@version P12.1.30
@return Nil
/*/
Static Function WaitCancel(cTicket)
	While VarIsUID("A712Cancel_" + cTicket)
		Sleep(200)
	EndDo
Return .T.

/*/{Protheus.doc} MRPIniCarg
Inicia o processamento da carga em memória

@type  Function
@author douglas.heydt
@since 26/03/2020
@version P12.1.27
@param 01 - cBody     , character, parâmetros da execução
@return Nil
/*/
Function MRPIniCarg(cBody)

	Local aReturn  := {}
	Local cError   := ""
	Local lReturn  := .T.
	Local oBody    := Nil
	Local oJsonRet := JsonObject():New()
	Local oPCPLock := PCPLockControl():New()

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera  := 2

	oBody := JsonObject():New()
	oBody:fromJson(cBody)

	//Se ainda não existe o lock Do PCPA712, aguarda liberacao do semaforo e faz, aguarda finalizacao de outras rotinas do processo
	If !oPCPLock:check("MRP_MEMORIA", "*",  oBody["ticket"])
		lReturn := oPCPLock:lock("MRP_MEMORIA", "PCPA712",  oBody["ticket"], .T., {"PCPA146"}, nEspera, @cError, DEFAULT_nMSG_LOCK_ERROR)
	EndIf

	If lReturn
		If AguardSinc(oBody["ticket"])
			aReturn  := MrpPLoad(oBody)
			If aReturn[1] != 201
				oJsonRet:fromJson(aReturn[2])
				lReturn := .F.
			EndIf

			aSize(aReturn, 0)
		Else
			cError := GetGlbValue(oBody["ticket"]+"CERROSSINC")
			If cError == Nil .OR. Empty(cError)
				If Empty(oJsonRet["detailedMessage"])
					oJsonRet["detailedMessage"] := STR0278 //"Falha indeterminada impediu a inicialização da carga em memória."
				EndIf
			Else
				oJsonRet["detailedMessage"] := cError
			EndIf
		EndIf
	Else
		oJsonRet["detailedMessage"] := cError
	EndIf
	VarSetAD( oBody["ticket"] + "JOB_SYNC", "statusMrpIniCarga", {lReturn, oJsonRet:ToJson()} )

	FreeObj(oJsonRet)
	oJsonRet := Nil

Return

/*/{Protheus.doc} MRPVldJob
Chama as funções de validação triggers, pendências e sincronização de tabelas
@type  Function
@author douglas.heydt
@since 17/03/2020
@version P12.1.30
@param 01 - cTicket, character, código do ticket MRP
/*/
Function MRPVldJob(cTicket)
	Local cProblema := ""
	Local nErroSinc := 0
	Local nSetTotal := MicroSeconds()
	Local oLogs     := Nil
	Local oStatus   := MrpDados_Status():New(cTicket)
	Local oPCPLock  := PCPLockControl():New()

	//Aguarda reserva do processo Mrp Memoria pelo PCPA712
	slLock := oPCPLock:waitCheck("MRP_MEMORIA", {"PCPA712","PCPA141","PCPA140"}, cTicket,, @cProblema)

	If slLock
		oPCPLock:lock("MRP_MEMORIA", "PCPA140",  cTicket, .F.) //Incluido lock manual sem exclusividade no PCPA140 para impedir abertura deste por outras Threads enquanto houver a transferencia do lock para o PCPA141
		oPCPLock:transfer("MRP_MEMORIA", "PCPA712", "PCPA141", cTicket) //Transfere propriedade do lock para rotina PCPA141
		VarSetAD( cTicket + "JOB_SYNC", "statusSync", {.F.} )

		oLogs := MrpDados_Logs():New()
		oLogs:gravaLog("sincronizacao", "PCPA140 - Sincronizacao completa", {"Inicio da sincronizacao"})

		MRPVldSync(.T., , ,.T., cTicket) //Verifica se é necessário executar a sincronização para alguma API, de acordo com o conteúdo do campo T4P_ALTER.
		MRPVldTrig(.T., , .F., , .T., , , , , cTicket)
		nErroSinc := Val(GetGlbValue(cTicket+"QTDERROSSINC"))
		oPCPLock:transfer("MRP_MEMORIA", "PCPA141", "PCPA712", cTicket)    //Retorna propriedade do lock para rotina PCPA712
		oPCPLock:unlock("MRP_MEMORIA", "PCPA140",  cTicket)      //Remocao do lock no PCPA140 quando o lock já retornou para o PCPA712

		While nErroSinc == -1 //-1 = Variavel foi instanciada, ainda pendente de termino da sincronizacao
			Sleep(50)
			nErroSinc := Val(GetGlbValue(cTicket+"QTDERROSSINC"))
		EndDo

		If nErroSinc > 0
			VarSetAD( cTicket + "JOB_SYNC", "statusSync", {.F.} )
			oLogs:gravaLog("sincronizacao", "PCPA140 - Sincronizacao completa", {"Sincronizacao finalizada com erro"})
		Else
			VarSetAD( cTicket + "JOB_SYNC", "statusSync", {.T.} )
			oLogs:gravaLog("sincronizacao", "PCPA140 - Sincronizacao completa", {"Sincronizacao finalizada com sucesso"})
		EndIf

		PutGlbValue(cTicket + "PERCENTUALSINC", "100")
		nSetTotal := MicroSeconds() - nSetTotal
		oStatus:setStatus("tempo_sincronizacao", nSetTotal)
	Else
		PutGlbValue(cTicket + "CERROSSINC", cProblema)
		PutGlbValue(cTicket + "QTDERROSSINC", "1")
		PutGlbValue(cTicket + "PERCENTUALSINC", "100")
	EndIf

Return

/*/{Protheus.doc} A712Cancel
Chama API de Cancelamento do MRP

@type  Function
@author brunno.costa
@since 31/07/2019
@version P12.1.27
@param 01 - lReturn , lógico  , retorno da operação passado por referência
@param 02 - lReserva, lógico  , indica se deve realizar a reserva do MRP
@param 03 - cParam  , caracter, string Json com os parâmetros soParam
/*/
Function A712Cancel(lReturn, lReserva, cParam)

	Local aReturn    := {}
	Local oBody      := JsonObject():New()
	Local oJsonRet   := JsonObject():New()

	Default lReturn  := .F.
	Default lReserva := .F.

	If cParam != Nil .AND. !Empty(cParam)
		soParam := JsonObject():New()
		soParam:fromJson(cParam)
		SetDefault()
	EndIf

	//Retorna Status do Processamento
	aReturn := MrpGet(cFilAnt, soParam["ticket"])
	oJsonRet:fromJson(aReturn[2])

	//Se não foi cancelado a partir de outra conexão
	If oJsonRet["status"] != "4"
		FreeObj(oJsonRet)
		aSize(aReturn, 0)
		oJsonRet := JsonObject():New()

		oBody["branchId"] := cFilAnt
		oBody["user" ]    := IIf(soParam['user'] != Nil, soParam['user'], RetCodUsr())

		//Converte soParam em Array para API
		oBody["listOfMRPParameters"] := TOParamAPI()

		//Executa API de cancelamento
		While !lReturn //Aguarda Retorno true
			aReturn := MrpPCancel(oBody)
			oJsonRet:fromJson(aReturn[2])
			lReturn := oJsonRet["lResult"]
			Sleep(250)
		EndDo
	EndIf

	//Fecha Controle de Cancelamento em Andamento
	If !Empty(soParam["ticket"]) .AND. VarIsUID("A712Cancel_" + soParam["ticket"])
		VarClean("A712Cancel_" + soParam["ticket"])
	EndIf

	//Executa API de Reserva
	If lReserva
		lReturn := .F.
		While !lReturn //Aguarda Retorno true
			oBody := JsonObject():New()
			oBody["branchId"] := cFilAnt
			oBody["user" ]    := IIf(soParam['user'] != Nil, soParam['user'], RetCodUsr())

			//Converte soParam em Array para API
			oBody["listOfMRPParameters"] := TOParamAPI()

			aReturn := MrpPStart(oBody)
			oJsonRet:fromJson(aReturn[2])
			lReturn := oJsonRet["lResult"]
			Sleep(250)
		EndDo

		//Atribui ticket atual no controle estático
		soParam["ticket"] := oJsonRet["ticket"]
	EndIf

	FreeObj(oBody)
	FreeObj(oJsonRet)
	aSize(aReturn, 0)
	oBody    := Nil
	oJsonRet := Nil
	aReturn  := Nil

Return

/*/{Protheus.doc} LimpaObj
Limpa da memória os objetos utilizados
@author marcelo.neumann
@since 31/07/2019
@version P12
@return Nil
/*/
Static Function LimpaObj()

	If soParam <> Nil
		//Limpa a Consulta Padrão do campo Código
		If soParam["TELA_1"] <> Nil
			soParam["TELA_1"]["TELA_CONSULTA"]:Destroy()
		EndIf

		//Limpa da memória os objetos multivalorados
		LimpaMulti()

		//Limpa os demais objetos
		FreeObj(soParam["TELA_1"])
		soParam["TELA_1"] := Nil

		FreeObj(soParam["demandType"])
		soParam["demandType"] := Nil

		FreeObj(soParam["documentType"])
		soParam["documentType"] := Nil

		FreeObj(soParam["products"])
		soParam["products"] := Nil

		FreeObj(soParam["productGroups"])
		soParam["productGroups"] := Nil

		FreeObj(soParam["productTypes"])
		soParam["productTypes"] := Nil

		FreeObj(soParam["documents"])
		soParam["documents"] := Nil

		FreeObj(soParam["warehouses"])
		soParam["warehouses"] := Nil

		FreeObj(soParam["demandCodes"])
		soParam["demandCodes"] := Nil

		If soPCPError <> Nil
			soPCPError:destroy()
			soPCPError := Nil
			scErrorUID := Nil
		EndIf

		If soParam["ticket"] <> Nil
			If VarIsUID(soParam["ticket"] + "JOB_SYNC")
				VarClean(soParam["ticket"] + "JOB_SYNC")
			EndIf

			ClearGlbValue(soParam["ticket"]+"PERCENTUALSINC")
			ClearGlbValue(soParam["ticket"]+"QTDERROSSINC")
			ClearGlbValue(soParam["ticket"]+"CERROSSINC")
			If !Empty(GetGlbValue(soParam["ticket"]+"UIDPRG_PCPA145"))
				ClearGlbValue(soParam["ticket"]+"UIDPRG_PCPA145")
			EndIf
			If !Empty(GetGlbValue(soParam["ticket"]+"PCPA151_STATUS"))
				ClearGlbValue(soParam["ticket"]+"PCPA151_STATUS")
			EndIf
		EndIf

		FreeObj(soParam)
		soParam := Nil
	EndIf

	aSize(saFiliais, 0)
	aSize(saStatus, 0)

	//Limpeza de variáveis Static para o seu conteúdo padrão
	scSetupAnt := ""
	soTGetCod  := Nil
	soTGetDes  := Nil
	snMrpSinc  := 1
	scLogMrp   := "2"
	slIntgMES  := .F.
	slMESLite  := .F.
	slIntgSFC  := .F.
	slIntgQIP  := .F.
	slConcluiu := .F.
	slError    := .F.
	slSincroni := .F.
	soTimer    := Nil
	snAtuDem   := 0
	slExcOpFim := .F.
	soGeraDoc  := Nil
	snDocAlca  := 0
	snProgDoc  := 0
	snProgSugE := 0
	snRastDoc  := 0
	slLock     := .F.
	slshowMsgL := .F.
	snIniStat  := Nil
	snEventLog := Nil
	scPicoMemo := Nil
	_nMemLimit := 0
	__SINCRONI := 0
	__NIVEIS   := 0
	__EXCLUSAO := 0
	__CARGA    := 0
	__CALCULO  := 0
	__LOG_EVEN := 0
	__PERSIST  := 0
	__GERARAST := 0
	__GERA_DOC := 0
	__DOC_ALCA := 0
	__RAST_DOC := 0
	__SUG_LOTE := 0
	__INTG_MES := 0
	__INTG_SFC := 0
	__INTG_QIP := 0
	__MEMORIA  := 0

Return Nil

/*/{Protheus.doc} LimpaMulti
Limpa da memória os objetos multivalorados
@author marcelo.neumann
@since 31/07/2019
@version P12
@return Nil
/*/
Static Function LimpaMulti()

	If soParam["products"] <> Nil
		soParam["products"     ]["FILTER"]:Destroy()
		soParam["productGroups"]["FILTER"]:Destroy()
		soParam["productTypes" ]["FILTER"]:Destroy()
		soParam["documents"    ]["FILTER"]:Destroy()
		soParam["warehouses"   ]["FILTER"]:Destroy()
		If !Empty(GetSx3Cache("T4J_CODE" ,"X3_TAMANHO"))
			soParam["demandCodes"  ]["FILTER"]:Destroy()
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} AbreConsul
Abre a tela de consulta do setup que permite escolher a operação
@author marcelo.neumann
@since 09/08/2019
@version P12
@return Nil
/*/
Static Function AbreConsul()

	Local nOpc := 0

	//Abre a tela de consulta do Setup
	nOpc := soParam["TELA_1"]["TELA_CONSULTA"]:AbreTela()

	Do Case
		//SELECIONAR
		Case nOpc == IND_OPERACAO_SELECIONAR
			soParam["TELA_1"]["HW2_CODIGO" ] := soParam["TELA_1"]["TELA_CONSULTA"]:GetCodigo()
			soParam["TELA_1"]["HW2_DESCRI" ] := soParam["TELA_1"]["TELA_CONSULTA"]:GetDescricao()
			soParam["TELA_1"]["OPERACAO"   ] := nOpc
			soParam["TELA_1"]["CHECK_PULAR"] := .T.
			LoadTela1(soParam["TELA_1"]["HW2_CODIGO"])
			HabCheck(.T.)
			soTGetDes:SetFocus()

		//COPIAR
		Case nOpc == IND_OPERACAO_COPIAR
			soParam["TELA_1"]["HW2_CODIGO" ] := CriaVar("HW2_CODIGO")
			soParam["TELA_1"]["HW2_DESCRI" ] := soParam["TELA_1"]["TELA_CONSULTA"]:GetDescricao()
			soParam["TELA_1"]["OPERACAO"   ] := nOpc
			soParam["TELA_1"]["CHECK_PULAR"] := .F.
			LoadTela1(soParam["TELA_1"]["TELA_CONSULTA"]:GetCodigo())
			HabCheck(.F.)
			soTGetDes:SetFocus()
			soTGetCod:SetFocus()

		OtherWise
			If nOpc != 0
				soParam["TELA_1"]["HW2_CODIGO" ] := CriaVar("HW2_CODIGO")
				soTGetDes:SetFocus()
				soParam["TELA_1"]["HW2_CODIGO" ] := soParam["TELA_1"]["TELA_CONSULTA"]:GetCodigo()
				soParam["TELA_1"]["OPERACAO"   ] := nOpc
				soParam["TELA_1"]["CHECK_PULAR"] := .F.
				HabCheck(.F.)
				soTGetCod:SetFocus()
			EndIf
	EndCase

Return Nil

/*/{Protheus.doc} HabCheck
Habilita/Desabilita o checkbox "Pular para o processamento"
@author marcelo.neumann
@since 09/08/2019
@version P12
@param lHabilita, lógico, indica se deve Habilitar (.T.) ou Desabilitar (.F.)
@return Nil
/*/
Static Function HabCheck(lHabilita)

	If lHabilita
		soParam["TELA_1"]["CHECK_OBJETO"]:Enable()
	Else
		soParam["TELA_1"]["CHECK_OBJETO"]:Disable()
	EndIf

Return Nil

/*/{Protheus.doc} ConvDate
Função para conversão de data
@author brunno.costa
@since 10/09/2019
@version P12
@param dData, data, data para conversão
@return cData, string de data YYYY-MM-DD
/*/
Static Function ConvDate(dData)

Return StrZero(Year(dData),4) + "-" + StrZero(Month(dData),2) + "-" + StrZero(Day(dData),2)

/*/{Protheus.doc} LoadTela1
Carrega os parâmetros da Tela 1
@author marcelo.neumann
@since 03/10/2019
@version P12
@param cSetup, caracter, código do setup de configuração a ser carregado
@return Nil
/*/
Static Function LoadTela1(cSetup)
	Local aAreaHW2 := HW2->(GetArea())
	Local aDadosPE := {}
	Local aParam   := StrTokArr(PARAM_NA_TELA_1, "|")
	Local nInd     := 0
	Local nTotal   := Len(aParam)

	HW2->(dbSetOrder(1))
	For nInd := 1 To nTotal
		If HW2->(dbSeek(xFilial('HW2') + cSetup + aParam[nInd]))
			soParam[AllTrim(HW2->HW2_PARAM)] := ConvertCol(AllTrim(HW2->HW2_PARAM), HW2->HW2_VALOR, .F.)
		EndIf
	Next nInd

	If _lP712LDTL
		aAdd(aDadosPE, {"CHECK_PULAR", soParam["TELA_1"]["CHECK_PULAR"]})
		aAdd(aDadosPE, {"HW2_CODIGO" , cSetup})
		aDadosPE := ExecBlock("P712LDTL",.F.,.F., aDadosPE)
		If ValType(aDadosPE) == "A"
			For nInd := 1 To Len(aDadosPE)
				soParam[aDadosPE[nInd][1]] := aDadosPE[nInd][2]
			Next nInd
			nInd := aScan(aDadosPE, {|x| x[1] == "CHECK_PULAR"})
			If nInd > 0
				soParam["TELA_1"]["CHECK_PULAR"] := aDadosPE[nInd][2]
			EndIf
		EndIf
	EndIf

	HW2->(RestArea(aAreaHW2))

Return Nil

/*/{Protheus.doc} AguardSinc
Aguarda a sincronização e retorna se houve erro ou não
@author douglas.heydt
@since 27/03/2020
@version P12
@param cTicket , caracter, número do ticket
@return lSincOk, lógico  , indica se a sincronização finalizou com ou sem erro
/*/
Static Function AguardSinc(cTicket)
	Local aSync      := {}
	Local cQtdErros  := ""
	Local cErro      := ""
	Local lSincOk    := .F.
	Local lErro      := .F.
	Local lOk        := .T.
	Local nPercent   := 0
	Local nPendTotal := 0
	Local nPendProc  := 0
	Local nTempoIni  := 0
	Local oStatus    := Nil

	//Sincronização completa (PCPA140)
	snMrpSinc := SuperGetMV("MV_MRPSINC", .F., 1)
	If snMrpSinc == 3
		VarGetAD(cTicket + "JOB_SYNC", "statusSync", aSync)
		If aSync != Nil .AND. Len(aSync) > 0
			While aSync[1] == .F.
				Sleep(200)
				VarGetAD( cTicket + "JOB_SYNC", "statusSync", aSync)
				cQtdErros := GetGlbValue(cTicket+"QTDERROSSINC")
				If (!Empty(cQtdErros) .And. Val(cQtdErros) >= 0 .OR. (aSync == Nil .OR. Len(aSync) == 0) .AND. Val(cQtdErros) != -1) //-1 = Variavel foi instanciada, ainda pendente de termino da sincronizacao
					Exit
				EndIf
			EndDo
		EndIf

		If Val(GetGlbValue(cTicket+"QTDERROSSINC")) <= 0
			lSincOk := .T.
		EndIf
	Else
		lSincOk   := .T.
		lEmExecuc := .T.
		While lEmExecuc
			lEmExecuc := PCPStatPrc(cTicket, @nPendTotal, @nPendProc, @nPercent, @lErro, @cErro)

			If !lEmExecuc .And. nPendTotal > 0 .And. nPercent < 100
				lErro := .T.
			EndIf

			If Val(GetGlbValue(cTicket + "PERCENTUALSINC")) < nPercent
				PutGlbValue(cTicket + "PERCENTUALSINC", cValToChar(nPercent))
			EndIf

			If lErro
				PutGlbValue(cTicket + "CERROSSINC", cErro)
				PutGlbValue(cTicket + "QTDERROSSINC", "1")
				lSincOk := .F.
				Exit
			EndIf

			Sleep(1000)
		EndDo

		If !lErro
			PutGlbValue(cTicket + "QTDREROSSINC", "0")
			PutGlbValue(cTicket + "PERCENTUALSINC", "100")
		EndIf

		//Grava o tempo da sincronização se ainda não gravou (essa função é chamada por threads diferentes)
		oStatus := MrpDados_Status():New(cTicket)
		oStatus:getStatus("tempo_sincronizacao", @lOk)
		If !lOk
			nTempoIni := oStatus:getStatus("tempo_sincronizacao_inicio", @lOk)
			If lOk
				oStatus:setStatus("tempo_sincronizacao", MicroSeconds() - nTempoIni)
				oLogs := MrpDados_Logs():New()
				oLogs:gravaLog("sincronizacao", "PCPA141 - Integracao das pendencias", {IIf(lSincOk, "Sincronizacao finalizada com sucesso", "Sincronizacao finalizada com erro")})
			EndIf
		EndIf
	EndIf

	aSize(aSync, 0)

Return lSincOk

/*/{Protheus.doc} PCPA712Err
Função para tratar erros de execução do JOB

@author    douglas.heydt
@since     30/03/2020
@version   1
@param 01 - oErro, object, Objeto com as informações do erro ocorrido.
@retorna true para indicar que a operação será repetida
/*/
Function PCPA712Err(oErro)
	LogMsg(ProcName(2), 0, 0, 1, '', '',ProcName(2)+ " - " + cValToChar(ThreadID()) + " - " + AllTrim(oErro:description) + CHR(10) + AllTrim(oErro:ErrorStack) + CHR(10) + oErro:ErrorEnv)
	BREAK
Return

/*/{Protheus.doc} addFiliais
Verifica se o ambiente está configurado para execução multi-empresas,
e adiciona as filiais para execução no objeto de parâmetros do MRP.

@type  Static Function
@author lucas.franca
@since 11/09/2020
@version P12
@return Nil
/*/
Static Function addFiliais()
	Local aFilCent := {}
	Local nIndex   := 0
	Local nTotFils := 0

	If Empty(saFiliais)
		aAdd(saFiliais, cFilAnt)

		aFilCent := A712FilME(.F.)
		nTotFils := Len(aFilCent)

		If nTotFils >= 1
			//Adiciona como filial centralizadora a filial atual
			soParam["branchCentralizing" ] := cFilAnt
			soParam["centralizedBranches"] := ""

			For nIndex := 1 To nTotFils
				soParam["centralizedBranches"] += "|" + aFilCent[nIndex][1]
				aAdd(saFiliais, aFilCent[nIndex][1])
			Next nIndex
			soParam["centralizedBranches"] += "|"

			aSize(aFilCent, 0)
		EndIf
	Else
		nTotFils := Len(saFiliais)
		If nTotFils > 1
			soParam["branchCentralizing" ] := saFiliais[1]
			soParam["centralizedBranches"] := ""
			For nIndex := 2 To nTotFils
				soParam["centralizedBranches"] += "|" + saFiliais[nIndex]
			Next nIndex
			soParam["centralizedBranches"] += "|"
		EndIf
	EndIf

Return

/*/{Protheus.doc} A712FilME
Retorna as filiais que participam do processamento do MRP (centralizadora e centralizadas)

@type  Function
@author lucas.franca
@since 12/09/2023
@version P12
@param 01 lCentzdora, Logic, Determina se retorna no array a filial centralizadora ou somente as centralizadas.
@return aFil, Array, Array com todas as filiais que pertencem ao MRP Multi-empresas
/*/
Function A712FilME(lCentzdora)
	Local aFil       := { }
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local cFilCent   := ""
	Local nTamOOGE   := GetSx3Cache("OO_CDEPCZ", "X3_TAMANHO")
	Local nTamOOEmp  := GetSx3Cache("OO_EMPRCZ", "X3_TAMANHO")
	Local nTamOOUnid := GetSx3Cache("OO_UNIDCZ", "X3_TAMANHO")
	Local nTamOOFil  := GetSx3Cache("OO_CDESCZ", "X3_TAMANHO")
	Local nTamEmp    := Len(FWSM0Layout(cEmpAnt,1))
	Local nTamUNeg   := Len(FWSM0Layout(cEmpAnt,2))
	Local nTamFil    := Len(FWSM0Layout(cEmpAnt,3))

	If lCentzdora
		aAdd(aFil, { cFilAnt, 0 })
	EndIf

	cGrupo := PadR(cGrupo, nTamOOGE)
	cEmp   := PadR(cEmp  , nTamOOEmp)
	cUnid  := PadR(cUnid , nTamOOUnid)
	cFil   := PadR(cFil  , nTamOOFil)

	SOO->(dbSetOrder(2))
	SOP->(dbSetOrder(3))
	//Verifica se a filial atual possui cadastro de empresas centralizadoras
	If SOO->(dbSeek(xFilial("SOO")+cGrupo+cEmp+cUnid+cFil))
		//Encontrou cadastro de empresas centralizadoras, busca quais são as empresas centralizadas
		If SOP->(dbSeek(xFilial("SOP")+cGrupo+cEmp+cUnid+cFil))
			//Adiciona as filials centralizadas
			While SOP->(!Eof()) .And. ;
				xFilial("SOP")+cGrupo+cEmp+cUnid+cFil == SOP->(OP_FILIAL+OP_CDEPCZ+OP_EMPRCZ+OP_UNIDCZ+OP_CDESCZ)

				cFilCent := Padr(SOP->OP_EMPRGR,nTamEmp) + Padr(SOP->OP_UNIDGR,nTamUneg) + Padr(SOP->OP_CDESGR,nTamFil)

				aAdd(aFil, {cFilCent, SOP->OP_NRPYGR})

				SOP->(dbSkip())
			End

			//Ordena o array de filiais por prioridade.
			aSort(aFil,,,{|x,y| x[2] < y[2]})
		EndIf
	EndIf

Return aFil

/*/{Protheus.doc} chkFilExec
Verifica se o MRP pode ser executado na filial atual.
(validação de empresas centralizadas/centralizadoras do MRP Multi-empresas.)

@type  Static Function
@author lucas.franca
@since 06/10/2020
@version P12
@return lRet, Logic, Identifica se é permitido executar o MRP na filial atual
/*/
Static Function chkFilExec()

	Local cAliasQry  := ""
	Local cGrupo     := cEmpAnt
	Local cEmp       := FWCompany()
	Local cUnid      := FWUnitBusiness()
	Local cFil       := FwFilial()
	Local cFilCent   := ""
	Local lRet       := .T.
	Local nTamOPGE   := GetSx3Cache("OP_CDEPGR", "X3_TAMANHO")
	Local nTamOPEmp  := GetSx3Cache("OP_EMPRGR", "X3_TAMANHO")
	Local nTamOPUnid := GetSx3Cache("OP_UNIDGR", "X3_TAMANHO")
	Local nTamOPFil  := GetSx3Cache("OP_CDESGR", "X3_TAMANHO")

	cGrupo := PadR(cGrupo, nTamOPGE)
	cEmp   := PadR(cEmp  , nTamOPEmp)
	cUnid  := PadR(cUnid , nTamOPUnid)
	cFil   := PadR(cFil  , nTamOPFil)

	SOP->(dbSetOrder(4))
	If SOP->(dbSeek(xFilial("SOP")+cGrupo+cEmp+cUnid+cFil))
		lRet := .F.

		cFilCent := PadR(SOP->OP_EMPRCZ, Len(cEmp)) + PadR(SOP->OP_UNIDCZ, Len(cUnid)) + PadR(SOP->OP_CDESCZ, Len(cFil))

		Help(,,'Help',,STR0283 + " '" + AllTrim(cFilAnt) + "' " + STR0284,; //"Filial 'XX' está configurada como Filial Centralizada. Execução não permitida."
			1,0,,,,,,{STR0285 + " '" + AllTrim(cFilCent) + "'."}) //"Para executar o MRP Multi-empresas, a execução deve ser realizada em uma filial centralizadora. Execute o MRP na filial"
	EndIf

	If lRet
		SOO->(dbSetOrder(2))
		If SOO->(dbSeek(xFilial("SOO")+cGrupo+cEmp+cUnid+cFil))
			If Empty(SOO->OO_TE) .Or. Empty(SOO->OO_TS)
				Help(,,'Help',, STR0286,; //"TES Entrada/Saída não encontrado. Parâmetro obrigatório para execução com multi-empresas."
					1, 0,,,,,,{STR0287}) //"Acesse o cadastro de empresas centralizadoras (PCPA106) e informe os parâmetros de TES Entrada/Saída."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	If lRet
		cAliasQry := GetNextAlias()
		BeginSQL Alias cAliasQry
		  SELECT 1
		    FROM %table:SOP%
		   WHERE OP_FILIAL = %xFilial:SOP%
		     AND OP_CDEPCZ = %Exp:cGrupo%
		     AND OP_EMPRCZ = %Exp:cEmp%
		     AND OP_UNIDCZ = %Exp:cUnid%
		     AND OP_CDESCZ = %Exp:cFil%
		     AND OP_CDEPGR <> OP_CDEPCZ
		     AND %NotDel%
		EndSql

		If !(cAliasQry)->(Eof())
			Help( , , "A712L" + cValToChar(ProcLine()), , STR0335, ; //"Existem empresas centralizadas que pertencem a outro Grupo de Empresa."
				 1, 0, , , , , , {STR0336}) //"Corrija o cadastro da Empresa Centralizadora (PCPA106) para executar o MRP Memória."
			lRet := .F.
		EndIf
		(cAliasQry)->(dbCloseArea())
	EndIf

Return lRet

/*/{Protheus.doc} VldMultEmp
Executa as validações feitas no MATA311 para garantir que as transferências possam ser realizadas.

@type Static Function
@author marcelo.neumann
@since 19/03/2021
@version P12
@return lRet, Logic, Indica se o MRP pode ser executado
/*/
Static Function VldMultEmp()
	Local aErros    := {}
	Local cAliasQry := ""
	Local cFilDest  := ""
	Local cFilOrig  := ""
	Local cWhere    := ""
	Local lMVFilTrf := .F.
	Local lRet      := .T.
	Local nIndDest  := 1
	Local nIndOrig  := 1
	Local nTotFils  := 0
	Local oCGCFil   := Nil

	addFiliais()

	nTotFils := Len(saFiliais)
	If nTotFils < 2
		Return .T.
	EndIf

	cAliasQry := GetNextAlias()
	lMVFilTrf := SuperGetMv("MV_FILTRF",.F.,.F.)
	oCGCFil   := JsonObject():New()

	For nIndOrig := 1 To nTotFils
		For nIndDest := 1 To nTotFils
			If nIndOrig == nIndDest
				Loop
			EndIf

			cFilOrig := saFiliais[nIndOrig]
			cFilDest := saFiliais[nIndDest]

			cWhere := "%A1_FILIAL = '" + xFilial("SA1", cFilOrig) + "'"
			If lMVFilTrf
				cWhere += " AND A1_FILTRF = '" + cFilDest + "'"
			Else
				If oCGCFil[cFilDest] == Nil
					oCGCFil[cFilDest] := A311FilCGC(cFilDest)
				EndIf
				cWhere += " AND A1_CGC = '" + oCGCFil[cFilDest] + "'"
			EndIf
			cWhere += " AND D_E_L_E_T_ = ' '%"

			BeginSQL Alias cAliasQry
				%NoParser%
				SELECT A1_COD, A1_COND
				  FROM %Table:SA1%
				 WHERE %Exp:cWhere%
			EndSql

			If (cAliasQry)->(Eof())
				lRet := .F.
				aAdd(aErros, {cFilOrig                                     , ;
				              cFilDest                                     , ;
							  STR0288                                      , ; //"A filial de destino não é cliente da filial de origem."
							  STR0289 + cFilDest + STR0290 + cFilOrig + ".", ; //"Cadastre a filial XX como cliente na filial YY."
							  "MATA030 / CRMA980"})

			ElseIf Empty((cAliasQry)->A1_COND)
				lRet := .F.
				aAdd(aErros, {cFilOrig                                                         , ;
				              cFilDest                                                         , ;
							  STR0291                                                          , ; //"Não existe condição de pagamento cadastrada para a filial destino no cadastro de clientes."
							  STR0292 + AllTrim((cAliasQry)->A1_COD) + STR0300 + cFilDest + ".", ; //"Cadastre a condição de pagamento do cliente A1_COD na filial XX."
							  "MATA030 / CRMA980"})
			EndIf
			(cAliasQry)->(dbCloseArea())

			cWhere := "%A2_FILIAL = '" + xFilial("SA2", cFilDest) + "'"
			If lMVFilTrf
				cWhere += " AND A2_FILTRF = '" + cFilOrig + "'"
			Else
				If oCGCFil[cFilOrig] == Nil
					oCGCFil[cFilOrig] := A311FilCGC(cFilOrig)
				EndIf
				cWhere += " AND A2_CGC = '" + oCGCFil[cFilOrig] + "'"
			EndIf
			cWhere += " AND D_E_L_E_T_ = ' '%"

			BeginSQL Alias cAliasQry
			  %NoParser%
			  SELECT 1
			    FROM %table:SA2% SA2
			   WHERE %Exp:cWhere%
			EndSql

			If (cAliasQry)->(Eof())
				lRet := .F.
				aAdd(aErros, {cFilOrig                                     , ;
				              cFilDest                                     , ;
							  STR0293                                      , ; //"A filial de origem não é fornecedor da filial de destino."
							  STR0289 + cFilOrig + STR0294 + cFilDest + ".", ; //"Cadastre a filial XX como fornecedor na filial YY."
							  "MATA020"})
			EndIf
			(cAliasQry)->(dbCloseArea())
		Next nIndDest
	Next nIndOrig

	FreeObj(oCGCFil)
	oCGCFil := Nil

	If lRet .And. FWAliasInDic("HZ8")
		lRet := chkFiliais(saFiliais, aErros)
	EndIf

	If !lRet
		ExibeErros(aErros)
	EndIf

	aSize(aErros, 0)

Return lRet

/*/{Protheus.doc} chkFiliais
Verifica se as filiais de compra dos produtos pertencem ao grupo de empresas atual.

@type Static Function
@author douglas.heydt
@since 28/11/2024
@version P12
@param aFiliais, Array, contem as filias do grupo de empresas
@param aErros, Array, Erros a serem exibidos: [1] Filial Origem
                                              [2] Filial Destino
											  [3] Problema
											  [4] Solução
											  [5] Rotina
@return Nil
/*/
Static Function chkFiliais(aFiliais, aErros)
	Local cAlias   := GetNextAlias()
	Local cFiliais := ""
	Local cQuery   := ""
	Local nIndex   := 0
	Local lRet     := .T.
	Local nTotFils := Len(aFiliais)

	For nIndex := 1 To nTotFils
		cFiliais += "'"+aFiliais[nIndex]+"'"
		If nIndex <> nTotFils
			cFiliais += ","
		EndIf
	Next nIndex

	cQuery := " SELECT HZ8_FILIAL,HZ8_PROD,HZ8_FILCOM "
	cQuery += " FROM "+RetSqlName("HZ8")+" "
	cQuery += " WHERE HZ8_FILIAL IN ("+cFiliais+") AND HZ8_FILCOM <> '' AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	While (cAlias)->(!Eof())
		nPos := aScan(aFiliais, {|x| x == (cAlias)->(HZ8_FILCOM)})

		If nPos == 0
			lRet := .F.
			aAdd(aErros, {(cAlias)->(HZ8_FILIAL)            ,;
					(cAlias)->(HZ8_FILCOM)                  ,;
					I18N(STR0393, {(cAlias)->(HZ8_PROD)})   ,; //"Filial de compra do produto #1[HZ8_PROD]# não pertence ao grupo de empresas do MRP."
					I18N(STR0394, {(cAlias)->(HZ8_FILCOM)}) ,; //"Corrija a filial de compra do produto na rotina MATA180, ou adicione a filial #1[HZ8_FILCOM]# ao grupo de empresas centralizadoras do MRP na rotina PCPA106."
					"MATA180"})
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} ExibeErros
Abre tela com os erros encontrados na validação do Multi Empresa

@type Static Function
@author marcelo.neumann
@since 19/03/2021
@version P12
@param aErros, Array, Erros a serem exibidos: [1] Filial Origem
                                              [2] Filial Destino
											  [3] Problema
											  [4] Solução
											  [5] Rotina
@return Nil
/*/
Static Function ExibeErros(aErros)

	Local oBrowse := Nil
	Local oDialog := Nil
	Local oFont12 := TFont():New("Arial", , -12, , .F.)

	DEFINE DIALOG oDialog TITLE STR0295 FROM 0, 0 TO 350, 1000 PIXEL //"Inconsistências"

	TSay():New(03, 03, {|| STR0301}, oDialog, , oFont12, , , , .T., , , 490, 20) //"Foram identificadas algumas inconsistências relacionadas à transferência entre as filiais."
	TSay():New(14, 03, {|| STR0302}, oDialog, , oFont12, , , , .T., , , 490, 20) //"O MRP não poderá ser executado."

	oBrowse := TWBrowse():New(26,01,500,135, ,{STR0296, STR0297, STR0298, STR0299, STR0303},{38, 38, 225, 159, 30},oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) //"Filial Origem", "Filial Destino", "Problema", "Solução", "Rotina"
	oBrowse:SetArray(aErros)
	oBrowse:bLine := {|| { aErros[oBrowse:nAt,1], aErros[oBrowse:nAt,2], aErros[oBrowse:nAt,3], aErros[oBrowse:nAt,4], aErros[oBrowse:nAt,5]}}

	DEFINE SBUTTON FROM 163, 475 TYPE 1 ACTION (oDialog:End()) ENABLE OF oDialog

	ACTIVATE MSDIALOG oDialog CENTERED

Return

/*/{Protheus.doc} PermitExec
Realiza todos as validações de execução do programa

@type Static Function
@author marcelo.neumann
@since 19/03/2021
@version P12
@param lSemTela, Logic, Informa se exibe as mensagens em tela ou por meio de log.
@return Nil
/*/
Static Function PermitExec(lSemTela)

	Local lProced := .T.

	If GetRpoRelease() < "12.1.025"
		HELP(' ',1,"Release" ,,STR0270 ,2,0,,,,,,) //"Rotina disponível a partir do release 12.1.25."
		Return .F.
	EndIf

	//Se a tabela T4R não estiver em modo compartilhado, não permite abertura da tela
	If !FWModeAccess("T4R",1) == "C" .Or. !FWModeAccess("T4R",2) == "C" .Or. !FWModeAccess("T4R",3) == "C"
		Help(' ', 1, "A712L" + cValToChar(ProcLine()),, STR0176,; //"A rotina não pode ser inciada pois tabela T4R (pendências do MRP) está com modo de compartilhamento incorreto)."
			2, 0, , , , , , {STR0177})                           //"Altere o modo de compartilhamento da tabela T4R para 'Compartilhado'."
		Return .F.
	EndIf

 	//Se a integração não estiver habilitada, não permite utilizar a tela de sincronização.
	If !IntNewMRP("MRPDEMANDS")
		Help(' ', 1, "A712L" + cValToChar(ProcLine()),, STR0172,; //"Integração com o MRP não está habilitada."
				2, 0, , , , , , {STR0173})                           //"Ative a integração com o MRP para utilizar este programa."
		Return .F.
	EndIf

	//Verifica se a procedure de calculo de níveis existe e se a assinatura está atualizada.
	//Tratamento paliativo para atualização da procedure, até que seja tratado na issue DMANNEWPCP-4082.
	If !lSemTela
		FWMsgRun(, {|| lProced := VldProced()}, STR0271, STR0312)	// "Aviso" "Validando Procedures"
	Else
		lProced := VldProced()
	EndIf
	If !lProced
		Return .F.
	EndIf

	//Verifica se pode executar o MRP nesta filial.
	If !chkFilExec()
		Return .F.
	EndIf

	If !VldMultEmp()
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} VldProced
Função responsável por validar a instalação da procedure do MRP.
Caso esteja desatualizada ou não instalada, realiza a instalação/atualização.

@type  Static Function
@author Lucas Fagundes
@since 17/01/2022
@version P12
@return .T. caso esteja tudo ok;
		.F. caso haja divergencias.
/*/
Static Function VldProced()

	Local cProcNam    := GetSPName("MRP001","24")
	Local cVerProc    := ""
	Local oInstall    := Nil
	Local oProcesso   := Nil
	Local oProcessRPO := Nil

	//Verifica se é possivel utilizar as funções de instalação automatica de procedures.
	If FindFunction("SPSMigrated") .and. SPSMigrated()
		oProcesso := EngSPSStatus("24")

		If oProcesso["status"] <> DEF_SPS_UPDATED
			oProcessRPO := EngSPSGetProcess(DEF_SPS_FROM_RPO, oProcesso["process"], /*empresa*/)

			// Realiza a instalação da procedure
			If oProcessRPO["status"] <> "FALSE"
				oInstall := EngSPSInstall(oProcesso["process"], /*empresa*/, DEF_SPS_FROM_RPO)
				If !Empty(oInstall["error"])
					Help(' ',1,"HELP" ,, STR0313 + CHR(10) + STR0314 + oInstall["idlog"] + STR0317 + oInstall["error"],2,0,,,,,, {STR0318}) // "Falha na instalação da procedure." "IDLog da operação [ " " ] - Erro: " "Verifique os detalhes da transação no configurador por meio do idLog da operação"
					Return .F.
				EndIf
			Else
				Help(' ',1,"HELP" ,, STR0315 + oProcesso["process"] + STR0316 + oProcessRPO["error"],2,0,,,,,, {STR0319}) // "Não foi possivel obter o objeto do processo " " que está no RPO. Motivo: " "Contate o administrador do sistema"
				Return .F.
			EndIf
		EndIf
	Else
		cVerProc := EngSPS24Signature()
		If !ExistProc(cProcNam, cVerProc)
			Help(' ',1,"HELP" ,, STR0272 + AllTrim(cProcNam) + STR0273,2,0,,,,,, {STR0320}) // "Stored Procedure " " não instalada no banco de dados." "Faça a instalação da procedure do MRP via SIGACFG"
			Return .F.
		EndIf
	EndIf

Return .T.

/*/{Protheus.doc} MrpSchdl
Função responsavel pela execução do mrp em modo schedule.
@type  Static Function
@author Lucas Fagundes
@since 31/01/2022
@version P12
@param oParametros, Object, Parâmetros para execução do mrp.
@return lRet, Lógico, Indica se a execução foi bem sucedida.
/*/
Static Function MrpSchdl(oParametros)
	Local aNames := oParametros:GetNames()
	Local nIndex := 1

	// Carrega os parâmetros
	If Empty(oParametros['TELA_1']['HW2_CODIGO'])
		For nIndex := 1 to Len(aNames)
			soParam[aNames[nIndex]] := oParametros[aNames[nIndex]]
		Next
		ValidaPag1(Nil)
	Else
		soParam['TELA_1']['HW2_CODIGO'] := PadR(oParametros['TELA_1']['HW2_CODIGO'], GetSx3Cache("HW2_CODIGO", "X3_TAMANHO"))
		soParam['TELA_1']['HW2_DESCRI'] := PadR(oParametros['TELA_1']['HW2_DESCRI'], GetSx3Cache("HW2_DESCRI", "X3_TAMANHO"))
		// Altera o parâmetro VALIDADA para falso, para poder carregar o setup existente
		soParam['TELA_1']['VALIDADA'] := .F.
		AtDesSetup(Nil, .T.)
		ValidaPag1(Nil)
		For nIndex := 1 to Len(aNames)
			// Pula o carregamento da "TELA_1", pois já foi carregada a partir do código do setup.
			If aNames[nIndex] == "TELA_1"
				Loop
			EndIf
			soParam[aNames[nIndex]] := oParametros[aNames[nIndex]]
		Next
	EndIf

	// Remove o check_pular para realizar as validações.
	soParam['TELA_1']['CHECK_PULAR'] := .F.
	If ValidaPag2() .and. ValidaPag3() .and. ValidaPag4(.T.) .and. ValidaPag5()
		// Executa o MRP
		MontaPag6(Nil, Nil)

		// Espera finalização
		While !slConcluiu .and. !slError
			Sleep(1000)
			UpdStatus(Nil, Nil, Nil, Nil)
		EndDo
	Else
		slError := .T.
	EndIf

	If slConcluiu .and. !slError
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} GetMemory
Retorna a quantidade de memória que está em uso pelo appserver, em MB.
@type  Static Function
@author Lucas Fagundes
@since 03/03/2022
@version P12
@return nMemoria, Numerico, Quantidade de memória que está em uso pelo appserver.
/*/
Static Function GetMemory()
    Local cInfo     := ""
    Local cIntermed := ""
	Local cLocal    := "Service Resident Memory ..."
    Local nMemoria  := 0
    Local nPosFim   := 0
    Local nPosStart := 0

	cInfo := GetSrvGlbInfo()

	nPosStart := At(cLocal, cInfo)
	nPosFim := At("MB.", cInfo, nPosStart)
	cIntermed := AllTrim(SubStr(cInfo, nPosStart+Len(cLocal), nPosFim-nPosStart))
	nMemoria := Round(Val(SubStr(cIntermed, 1, Len(cIntermed) - 3)), 1)

Return nMemoria

/*/{Protheus.doc} ValidaDic
Verifica se o dicionário está atualizado o suficiente para executar o MRP Aglutinando SC e Sem Aglutinar OP
@type Static Function
@author marcelo.neumann
@since 08/03/2022
@version P12
@param lSemTela, lógico, indica se está executando sem tela
@return Lógico, Indica se a base está atualizada
/*/
Static Function ValidaDic(lSemTela)
	Local cMsg1      := ""
	Local cMsg2      := ""
	Local lRet       := .T.
	Local oContainer := Nil
	Local oModal     := Nil
	Local oSay1      := Nil
	Local oSay2      := Nil

	dbSelectArea("HWG")
	If !(FieldPos("HWG_DOCFIL") > 0)
		If lSemTela
			Help( ,  , "A712L" + cValToChar(ProcLine()), , STR0325; //"Necessidade de atualização de dicionário"
				  , 1, 0, , , , , , {STR0330})                      //"Atualize o dicionário para utilizar a parametrização Aglutina SC e Não Aglutina OP."
		Else
			oModal := FWDialogModal():New()
			oModal:SetCloseButton(.F.)
			oModal:SetEscClose(.F.)
			oModal:SetTitle(STR0325) //"Necessidade de atualização de dicionário"
			oModal:setSize(120, 220)
			oModal:createDialog()
			oModal:AddButton(STR0326, {||oModal:DeActivate()}, STR0326, , .T., .F., .T., ) //"Fechar"

			oContainer := TPanel():New( ,,, oModal:getPanelMain() )
			oContainer:Align := CONTROL_ALIGN_ALLCLIENT

			cMsg1 := STR0327 //"Para utilizar a parametrização Aglutina Solicitações de Compra e Não Aglutina Ordens de Produção é necessário atualizar o dicionário de acordo com o link abaixo:"
			cMsg2 := "<b><a target='_blank' href='https://tdn.totvs.com/pages/viewpage.action?pageId=558260064'>
			cMsg2 += STR0328 //"MRP Memória - Atualização"
			cMsg2 += "</a></b>"
			cMsg2 += "<span style='font-family: Verdana; font-size: 12px; color: #565759;'>" + ' ' + "</span>"

			oSay1 := TSay():New( 10,10,{||cMsg1 },oContainer,,,,,,.T.,,,210,20,,,,,,.T.)
			oSay2 := TSay():New( 30,10,{||cMsg2 },oContainer,,,,,,.T.,,,210,20,,,,,,.T.)
			oSay2:bLClicked := {|| MsgRun(STR0329, "URL",{|| ShellExecute("open","https://tdn.totvs.com/pages/viewpage.action?pageId=558260064","","",1) } ) } // "Abrindo o link... Aguarde..."
			oModal:Activate()
		EndIf

		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} atuIndice
Atualiza os indices das tabelas do MRP.
@type  Static Function
@author Lucas Fagundes
@since 16/05/2022
@version P12
@return Nil
/*/
Static Function atuIndice()
	Local aTabelas := {"HWG", "HWM"}
	Local nIndex   := 0

	For nIndex := 1 to Len(aTabelas)
		DbSelectArea(aTabelas[nIndex])
	Next

Return Nil

/*/{Protheus.doc} filtroFil
Cria string filtro com filtro da filial para busca dos campos multivalorados.
@type  Static Function
@author Lucas Fagundes
@since 09/01/2023
@version P12
@param 01 cFieldFil, Caracter, Nome do campo filial para fazer o filtro.
@param 02 cAlias   , Caracter, Alias da tabela para realizar o xFilial.
@return cFiltro, Caracter, Filtro de filial IN ou = para a query.
/*/
Static Function filtroFil(cFieldFil, cAlias)
	Local cFiltro  := ""
	Local nIndex   := 0
	Local nTotFils := 0

	nTotFils := Len(saFiliais)
	If nTotFils > 1
		cFiltro := cFieldFil + " IN ("

		For nIndex := 1 To nTotFils
			If nIndex > 1
				cFiltro += ","
			EndIf
			cFiltro += "'" + xFilial(cAlias, saFiliais[nIndex]) + "'"
		Next nIndex
		cFiltro += ")"

	Else
		cFiltro := cFieldFil + " = '" + xFilial(cAlias) + "' "
	EndIf

Return cFiltro

/*/{Protheus.doc} consulDoc
Chama função para verificar o uso de um documento do mrp.
@type  Static Function
@author Lucas Fagundes
@since 09/01/2023
@version P12
@param oView, Object, View que está exibindo a lista com os documentos.
@return Nil
/*/
Static Function consulDoc(oView)
	Local aConsulta  := {}
	Local cDocumento := ""
	Local cFilAux    := ""
	Local lFilAux    := Len(saFiliais) > 1
	Local nIndex     := 0
	Local nOpc       := 0
	Local nTotal     := 0
	Local oModel     := Nil

	oModel := oView:getModel("documents")

	nOpc := Aviso(STR0349, STR0354, {STR0355, STR0356}, 1)  // STR0349 - "Consultar Demandas"; STR0354 - "Deseja consultar as demandas de todos os documentos selecionados ou apenas do documento posicionado?"; STR0355 - "Selecionados"; STR0356 - "Posicionado"

	If nOpc == 1
		nTotal := oModel:length()

		For nIndex := 1 To nTotal
			If oModel:GetValue("LSELECT", nIndex)
				cDocumento := oModel:getValue("VR_DOC", nIndex)
				cFilAux    := Iif(lFilAux, oModel:getValue("VR_FILIAL", nIndex), "")

				aAdd(aConsulta, {cDocumento, cFilAux})
			EndIf
		Next

		If Empty(aConsulta)
			Help( ,  , "Help", , STR0357, 1, 0, , , , , , {STR0358}) // "Não há documentos para consultar" "Selecione os documentos ou realize a consulta por posicionamento"
		EndIf
	Else
		cDocumento := oModel:getValue("VR_DOC")
		cFilAux    := Iif(lFilAux, oModel:getValue("VR_FILIAL"), "")

		aConsulta := {{cDocumento, cFilAux}}
	EndIf

	If !Empty(aConsulta)
		P712ConDoc(aConsulta, nOpc==1, lFilAux)
	EndIf
Return Nil

/*/{Protheus.doc} vldSeletiv
Válida se o valor do campo de seletivo existe e altera a descrição
@type  Static Function
@author Lucas Fagundes
@since 19/01/2023
@version P12
@param cSeletivo, Caracter, Seletivo que irá validar.
@return lExiste, Logico, Indica se é um valor válido.
/*/
Static Function vldSeletiv(cSeletivo)
	Local cAlias    := GetNextAlias()
	Local cColDesc  := ""
	Local cCondQry  := ""
	Local cMsg      := ""
	Local cQuery    := ""
	Local cSolu     := ""
	Local cTabela   := ""
	Local cTxtSelet := ""
	Local cValor    := ""
	Local lExiste   := .T.
	Local nIndice   := 0

	cValor := soParam[cSeletivo]["CODIGO"]

	If !Empty(cValor)
		lExiste := .F.

		Do Case
			Case cSeletivo == "products"
				cTxtSelet := STR0359 // "Produto"
				cTabela   := "SB1"
				cColDesc  := "B1_DESC"
				nIndice   := 1

				cCondQry += " B1_COD = '" + cValor + "' "
				cCondQry += " AND B1_FILIAL = '" + xFilial("SB1") + "' "

			Case cSeletivo == "productGroups"
				cTxtSelet := STR0360 // "Grupo material"
				cTabela   := "SBM"
				cColDesc  := "BM_DESC"
				nIndice   := 1

				cCondQry += " BM_GRUPO = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("BM_FILIAL", cTabela)

			Case cSeletivo == "productTypes"
				cTxtSelet := STR0361 // "Tipo material"
				cTabela   := "SX5"
				cColDesc  := "X5_DESCRI"
				nIndice   := 1

				cCondQry += " X5_CHAVE = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("X5_FILIAL", cTabela)
				cCondQry += " AND X5_TABELA  = '02' "

			Case cSeletivo == "documents"
				cTxtSelet := STR0362 // "Documento"
				cTabela   := "SVR"
				cColDesc  := "VR_DOC"
				nIndice   := 5

				cCondQry += " VR_DOC = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("VR_FILIAL", cTabela)

			Case cSeletivo == "warehouses"
				cTxtSelet := STR0363 // "Armazém"
				cTabela   := "NNR"
				cColDesc  := "NNR_DESCRI"
				nIndice   := 1

				cCondQry += " NNR_CODIGO = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("NNR_FILIAL", cTabela)

			Case cSeletivo == "demandCodes"
				cTabela   := "SVB"
				cColDesc  := "VB_CODIGO"
				nIndice   := 1

				cCondQry += " VB_CODIGO = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("VB_FILIAL", cTabela)

		EndCase

		cQuery := " SELECT 1 "
		cQuery +=   " FROM " + RetSqlName(cTabela)
		cQuery +=  " WHERE " + cCondQry
		cQuery +=    " AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		lExiste := (cAlias)->(!EoF())
		(cAlias)->(dbCloseArea())
	EndIf

	If lExiste
		GetDesMul(cTabela, cColDesc, cSeletivo, nIndice)
	Else

		If cSeletivo == "demandCodes"
			cMsg  := STR0364 // "Demanda não existe ou não está cadastrada em uma filial válida!"
			cSolu := STR0365 // "Insira uma demanda válida."
		Else
			cMsg  := I18N(STR0366, {cTxtSelet}) // "#1[SELETIVO]# não existe ou não está cadastrado em uma filial válida!"
			cSolu := I18N(STR0367, {lower(cTxtSelet)}) // "Insira um #1[SELETIVO]# válido."
		EndIf

		Help( ,  , "Help", , cMsg, 1, 0, , , , , , {cSolu}) // STR0352 "Documento não existe ou não está cadastrado em uma filial válida!" STR0353 "Insira um documento válido."
	EndIf

Return lExiste

/*/{Protheus.doc} P712ExcOp
Função para apresentar as OPs Efetivadas do CRP que serão excluidas
@type  Static Function
@author Jefferson Possidonio
@since 13/05/2025
@version P12
@return lRet, Logico, Indica se possui itens a serem excluidos.
/*/
Static Function P712ExcOp()
	Local cQueryOp := ""
	Local nIndFil  := 1
	Local nTotFil  := Len(saFiliais)
	Local lRet     := .T.

	If IsBlind()
		Return lRet
	Endif

	For nIndFil := 1 To nTotFil
		cQueryOp += " SELECT DISTINCT RTRIM(SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD) AS NUMOP "
		cQueryOp +=   " FROM " + RetSqlName("SC2") + " SC2"
		cQueryOp +=  " WHERE SC2.C2_FILIAL = HWF.HWF_FILIAL "
		cQueryOp +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
		cQueryOp +=    " AND HWF.D_E_L_E_T_ = ' ' "
		cQueryOp +=    " AND " + A146FilSC2(saFiliais[nIndFil], soParam["mrpStartDate"], soParam["firmHorizon"] == 1, soParam["ticket"])

		If nIndFil <= nTotFil - 1
			cQueryOp += " UNION ALL "
		Endif
	Next nIndFil

	cQueryOp := " AND RTRIM(HWF.HWF_OP) IN (" + cQueryOp + ")"

	lRet := PCPA152Efetivacao():abreTela(cQueryOp, saFiliais)

Return lRet


/*/{Protheus.doc} vldArm
Valida se o armazém existe
@type  Static Function
@author Ana Paula dos Santos
@since 17/09/2024
@version P12
@param cCampo, Caracter, campo que irá validar.
@return lExiste, Logico, Indica se é um valor válido.
/*/
Static Function vldArm(cCampo)
	Local cAlias    := GetNextAlias()
	Local cCondQry  := ""
	Local cMsg      := ""
	Local cQuery    := ""
	Local cSolu     := ""
	Local cTabela   := ""
	Local cTxtSelet := ""
	Local cValor    := ""
	Local lExiste   := .T.

	cValor := soParam[cCampo]

	If !Empty(cValor)
		lExiste := .F.

		Do Case

			Case cCampo == "armazemDe" .Or. cCampo == "armazemAte"
				cTxtSelet := STR0363 // "Armazém"
				cTabela   := "NNR"

				cCondQry += " NNR_CODIGO = '" + cValor + "' "
				cCondQry += " AND " + filtroFil("NNR_FILIAL", cTabela)

		EndCase

		cQuery := " SELECT 1 "
		cQuery +=   " FROM " + RetSqlName(cTabela)
		cQuery +=  " WHERE " + cCondQry
		cQuery +=    " AND D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		lExiste := (cAlias)->(!EoF())
		(cAlias)->(dbCloseArea())
	Else
		If cCampo == "armazemAte"
			soParam["armazemAte"] := Replicate("Z",tamsx3("NNR_CODIGO")[1])
			lExiste := .T.
		EndIf
	EndIf

	If !lExiste

		cMsg  := I18N(STR0366, {cTxtSelet}) // "#1[SELETIVO]# não existe ou não está cadastrado em uma filial válida!"
		cSolu := I18N(STR0367, {lower(cTxtSelet)}) // "Insira um #1[SELETIVO]# válido."

		Help( ,  , "Help", , cMsg, 1, 0, , , , , , {cSolu})
	EndIf

Return lExiste

/*/{Protheus.doc} HabArm
Atualiza combo e range de armazém conforme parametrização
@author Ana Paula dos Santos
@since 17/09/2024
@version P12
@param oWnd, objeto, objeto de tela para realizar o refresh
@param lSchdl, logic, indica se está executando em schedule (não irá atualizar a tela).
@return .T., lógico, retorna true para permitir sair do campo
/*/
Static Function HabArm(oWnd,oCombo8,oTGet9,oTGet10,lSchdl)

	Local lRet := .T.

	If AllTrim(soParam["allocationSuggestion"]) == "1"
		oCombo8:Enable()
		If AllTrim(soParam["armazemPad"]) == "2"
			If Empty(soParam["armazemDe"])
				soParam["armazemDe"] := CriaVar("NNR_CODIGO")
			EndIf
			If Empty(soParam["armazemAte"])
				soParam["armazemAte"] := Replicate("Z",tamsx3("NNR_CODIGO")[1])
			EndIf
			oTGet9:Enable()
			oTGet10:Enable()
			oTGet9:SetFocus()
		Else
			soParam["armazemDe"] := CriaVar("NNR_CODIGO")
			soParam["armazemAte"] := CriaVar("NNR_CODIGO")
			oTGet9:Disable()
			oTGet10:Disable()
			oCombo8:SetFocus()
		EndIf
	Else
		soParam["armazemPad"] := "1"
		oCombo8:Select(1)
		soParam["armazemDe"] := CriaVar("NNR_CODIGO")
		soParam["armazemAte"] := CriaVar("NNR_CODIGO")
		oCombo8:Disable()
		oTGet9:Disable()
		oTGet10:Disable()
	EndIf

	If !lSchdl
		oWnd:RefreshConstrols()
	EndIf

Return lRet

/*/{Protheus.doc} P712ExcPre
Executa a exclusão de documentos previstos em uma nova thread.

@type  Function
@author Lucas Fagundes
@since 22/01/2025
@version P12
@param 01 - cTicket   , character, Ticket do processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@param 04 - cErrorUID , character, codigo identificador do controle de erros multi-thread
@param 05 - cFiliais  , character, filiais para fazer a exclusão (parâmetro "centralizedBranches")
@param 06 - lSincroni , lógico   , Indica se foi iniciado a integração de documentos pendentes na abertura do MRP.
@return Nil
/*/
Function P712ExcPre(cTicket, lHoriFirme, dDataIni, cErrorUID, cFiliais, lSincroni)
	Local cPercent := ""
	Local lError   := .F.

	If lSincroni
		cPercent := GetGlbValue(cTicket + "PERCENTUALSINC")
		lError   := Val(GetGlbValue(cTicket + "QTDERROSSINC")) > 0

		While cPercent != "100" .And. !lError
			Sleep(50)

			cPercent := GetGlbValue(cTicket + "PERCENTUALSINC")
			lError   := Val(GetGlbValue(cTicket + "QTDERROSSINC")) > 0
		End
	EndIf

	If !lError
		PCPA146(cTicket, lHoriFirme, dDataIni, cErrorUID, cFiliais)
	EndIf

Return Nil

/*/{Protheus.doc} iniGerDoc
Verifica se iniciou a geração de documentos e fez o lock do pcpa145.
@type  Static Function
@author Lucas Fagundes
@since 12/06/2025
@version P12
@param cTicket  , Caracter, Ticket que iniciou a geração de documentos.
@param oPCPError, Object  , Instancia da PCPMultiThreadError que iniciou a geração de documentos.
@return lIniciou, Logico, Indica que iniciou a geração de documento.
/*/
Static Function iniGerDoc(cTicket, oPCPError)
	Local cFlag    := "PEND"
	Local lIniciou := .F.

	While cFlag == "PEND" .And. !oPCPError:possuiErro()
		cFlag    := GetGlbValue(cTicket + "P145LOCK")
		lIniciou := cFlag == "S"

		If !lIniciou
			Sleep(100)
		EndIf
	End

Return lIniciou
