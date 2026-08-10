#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA146.CH"
#INCLUDE "FWMVCDEF.CH"

//DEFINES do subarray de SALDOS do produto, com as posições de cada tipo de quantidade.
#DEFINE SALDOS_QTD_POS_ENTRADA_PREV  1
#DEFINE SALDOS_QTD_POS_SAIDA_PREV    2
#DEFINE SALDOS_QTD_TAMANHO           2

#DEFINE GLB_CHAVE_FILIAIS            "PCPA146_CHAVE_FILIAIS"

Static oExcPrevistos := Nil
Static _lNewMRP      := Nil
Static snTamCod      := 90

Static _lCrpOk       := AliasInDic("HWF") .And. FindFunction('PCPA152')

/*/{Protheus.doc} PCPA146
Exclusão dos Documentos Previstos

@type  Function
@author renan.roeder
@since 29/11/2019
@version P12.1.27
@param 01 - cTicket   , character, Ticket do processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@param 04 - cErrorUID , character, codigo identificador do controle de erros multi-thread
@param 05 - cFiliais  , character, filiais para fazer a exclusão (parâmetro "centralizedBranches")
@return Nil
/*/
Function PCPA146(cTicket, lHoriFirme, dDataIni, cErrorUID, cFiliais)
	Local nQtdDoc  := 0
	Local oLogs    := MrpDados_Logs():New()
	Local oPCPLock := PCPLockControl():New()
	Local oStatus  := MrpDados_Status():New(cTicket)

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera    := 2
	Local nEsperaMax := 3600 //3600 segundos = 1 hora

	Default lHoriFirme := .F.

	If oPCPLock:lock("MRP_MEMORIA", "PCPA146",  cTicket, .F., {"PCPA145", "PCPA151", "PCPA146"}, nEspera, nEsperaMax)
		If PCPLock("PCPA146", .T.)
			oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Realizado o bloqueio para a exclusão de documentos."}, .F., .F., .T.)

			oStatus:setStatus("tempo_exlusao_previstos_ini", MicroSeconds())

			oExcPrevistos := ExclusaoPrevistos():New(cTicket, .T., lHoriFirme, dDataIni, cErrorUID, cFiliais)
			oExcPrevistos:AtualizaStatus()
			oExcPrevistos:Processar()

			lExcTudo := validExc(cTicket, @nQtdDoc)

			oExcPrevistos:Destroy()
			oExcPrevistos := FreeObj(oExcPrevistos)

			If !lExcTudo
				oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Foi encontrado " + cValToChar(nQtdDoc) + " documentos previstos após o processamento. A exclusão de documentos será executada novamente."}, .F., .F., .T.)
				reprocessa(cTicket, lHoriFirme, dDataIni, cErrorUID, cFiliais)
			Else
				finishProc(cTicket)
			EndIf

			PCPUnlock("PCPA146")
			oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Liberado o bloqueio de exclusão de documentos."}, .T., .T., .T.)

			//Libera proteção de execução paralela
			oPCPLock:unlock("MRP_MEMORIA", "PCPA146", cTicket)
		EndIf
	EndIf

	oStatus := FreeObj(oStatus)

Return Nil


/*/{Protheus.doc} ExclusaoPrevistos
Classe com as regras para exclusão dos Documentos Previstos.

@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
CLASS ExclusaoPrevistos FROM LongClassName

	DATA cErrorUID  AS CHARACTER
	DATA cNameTabOP AS CHARACTER
	DATA cThrJobs   AS CHARACTER
	DATA cTicket    AS CHARACTER
	DATA cUIDSld    AS CHARACTER
	DATA cUIDSldLte AS CHARACTER
	DATA cUIDSldLcz AS CHARACTER
	DATA cUIDStatus AS CHARACTER
	DATA cUIDOrdens AS CHARACTER
	DATA cUIDSB1Cnv AS CHARACTER
	DATA cUIDFils   AS CHARACTER
	DATA dDataIni   AS DATE
	DATA lExistDHN1 AS LOGICAL
	DATA lExistDHN3 AS LOGICAL
	DATA lExistAE   AS LOGICAL
	DATA lHoriFirme AS LOGICAL
	DATA lUsaSBZ    AS LOGICAL
	DATA lUsaTemp   AS LOGICAL
	DATA lReproc    AS LOGICAL
	DATA nDecimal   AS NUMERIC
	DATA nThrJobs   AS NUMERIC
	DATA oLogs      AS OBJECT

	METHOD New(cTicket, lCriaVar, lHoriFirme, dDataIni, cErrorUID, cFiliais) CONSTRUCTOR
	METHOD Destroy()

	METHOD aguardaInclusaoTabOP(lCalTmpIni)
	METHOD AguardaInicioCalculoMRP(lCalTmpIni)
	METHOD AtualizaContratoParceria(cFilProc, cNumSc,cItemSc,nQuant)
	METHOD AtualizaStatus()
	METHOD CargaFiliaisProcessamento(cFiliais)
	METHOD CargaSB1Conversao()
	METHOD criarSecaoGlobal()
	METHOD ConverteUM(cFilProc, cProduto, nQtd)
	METHOD ExisteAutorizacaoEntrega()
	METHOD ExisteDHNValido(cTipo)
	METHOD ExcluiOrdensProducao()
	METHOD ExcluiPedidosCompra()
	METHOD ExcluiSolicitacoesCompra()
	METHOD GetLocalizaSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, cLocaliz, cNumSeri, lRet)
	METHOD GetLoteSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumlote, lRet)
	METHOD GetSaldo(cFilTab, cProduto, cLocal, lRet)
	METHOD GetStatus(lError)
	METHOD LimpaVarStatus()
	METHOD PersisteSaldos()
	METHOD Processar()
	METHOD RetornaFiliais()
	METHOD scriptInHorizonteFirme(cScript, cFilProc, cTabela, cCpoProd, cCpoData, cWhereComp, dDataIni)
	METHOD SetSaldos(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, cLocaliz, cNumseri, nQtd, nTipo)
	METHOD setError()

ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe de exclusão dos documentos previstos

@type  Method
@author renan.roeder
@since 29/11/2019
@version P12.1.27
@param 01 - cTicket  , Character, Número do ticket do processamento do MRP
@param 02 - lCriavar , Logical  , Define se inicializará as threads e variáveis globais.
@param 03 - dDataIni , data     , data de processamento do MRP utilizada como referência (database)
@param 04 - cErrorUID, character, codigo identificador do controle de erros multi-thread
@param 05 - cFiliais , character, filiais para fazer a exclusão (parâmetro "centralizedBranches")
@param 06 - lReproc  , Logico   , Indica que esta reprocessando a exclusão de documentos.
@return Self
/*/
METHOD New(cTicket, lCriavar, lHoriFirme, dDataIni, cErrorUID, cFiliais, lReproc) CLASS ExclusaoPrevistos
	Default lReproc := .F.

	Self:cTicket    := cTicket
	Self:cThrJobs   := Self:cTicket + "PROC"
	Self:cUIDSld    := "PREVSALDO_" + Self:cTicket
	Self:cUIDSldLte := "PREVLOTESALDO_" + Self:cTicket
	Self:cUIDSldLcz := "PREVLOCALIZSALDO_" + Self:cTicket
	Self:cUIDStatus := "PREVSTATUS_" + Self:cTicket
	Self:cUIDOrdens := "OPSINTEGRA_" + Self:cTicket
	Self:cUIDSB1Cnv := "SB1_CONV_" + Self:cTicket
	Self:cUIDFils   := "FILIAIS_PROC_" + Self:cTicket
	Self:nThrJobs   := 4
	Self:nDecimal   := GetSx3Cache("C7_QUANT","X3_DECIMAL")
	Self:lUsaSBZ    := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
	Self:oLogs      := MrpDados_Logs():New()

	If FwAliasInDic("SMD", .F.)
		Self:cNameTabOP := RetSqlName("SMD")
		Self:lUsaTemp   := .F.
	Else
		Self:cNameTabOP := "NUMOP" + Self:cTicket
		Self:lUsaTemp   := .T.
	EndIf

	If cErrorUID == Nil
		cErrorUID := Self:cUIDStatus
	EndIf
	Self:cErrorUID := cErrorUID

	If lCriavar
		PCPIPCStart(Self:cThrJobs, Self:nThrJobs, 0, cEmpAnt, cFilAnt, cErrorUID) //Inicializa as Threads

		//Abre novas threads para executar os processos de forma paralela
		PCPIPCStart(Self:cThrJobs + "OP", Self:nThrJobs, 0, cEmpAnt, cFilAnt, cErrorUID) //Inicializa as Threads

		::criarSecaoGlobal()
		Self:lHoriFirme := lHoriFirme
		Self:dDataIni   := dDataIni
		Self:lReproc    := lReproc

		VarSetXD(Self:cUIDStatus, "lHoriFirme", lHoriFirme)
		VarSetXD(Self:cUIDStatus, "dDataIni", dDataIni)
		VarSetXD(Self:cUIDStatus, "lReproc", lReproc)

		::CargaFiliaisProcessamento(cFiliais)

		::cargaSB1Conversao()
	Else
		VarGetXD(Self:cUIDStatus, "lHoriFirme", @Self:lHoriFirme)
		VarGetXD(Self:cUIDStatus, "dDataIni", @Self:dDataIni)
		VarGetXD(Self:cUIDStatus, "lReproc", @Self:lReproc)
	EndIf

	Self:lExistDHN1 := Self:ExisteDHNValido("1")
	Self:lExistDHN3 := Self:ExisteDHNValido("3")
	Self:lExistAE   := Self:ExisteAutorizacaoEntrega()

Return Self

/*/{Protheus.doc} Destroy
Método destrutor da classe de geração de exlusão dos documentos previstos

@type  Method
@author renan.roeder
@since 29/11/2019
@version P12.1.27
@return Nil
/*/
METHOD Destroy() CLASS ExclusaoPrevistos

	PCPIPCFinish(Self:cThrJobs, 300, Self:nThrJobs)
	PCPIPCFinish(Self:cThrJobs + "OP", 300, Self:nThrJobs)

	//Limpa da memória as variáveis globais
	VarClean(Self:cUIDSld)
	VarClean(Self:cUIDSldLte)
	VarClean(Self:cUIDSldLcz)
	VarClean(Self:cUIDOrdens)
	VarClean(Self:cUIDSB1Cnv)
	VarClean(Self:cUIDFils)

	ClearGlbValue(Self:cTicket + "STATUS_MES_EXCLUSAO")

Return Nil

/*/{Protheus.doc} Processar
Método que gerencia a exlusão dos documentos previstos.

@type  Method
@author renan.roeder
@since 29/11/2019
@version P12.1.27
@return Nil
/*/
METHOD Processar() CLASS ExclusaoPrevistos
	Default lAutoMacao := .F.

	//Inicia thread para criar tabela de controle com a numeração das ordens que serão excluídas
	VarSetXD(Self:cUIDStatus, "statusTabOP", 0)
	PCPIPCGO(Self:cThrJobs, .F., "A146TabOP", "CREATE", Self:cNameTabOP, Self:lUsaTemp, Self:cUIDStatus, Self:lHoriFirme, Self:dDataIni, Self:cTicket)

	//Inicia as threads de exclusão.
	PCPIPCGO(Self:cThrJobs, .F., "A146ExcOPs", Self:cTicket)
	PCPIPCGO(Self:cThrJobs, .F., "A146ExcSCs", Self:cTicket)
	PCPIPCGO(Self:cThrJobs, .F., "A146ExcPCs", Self:cTicket)

	If !lAutoMacao
		While IPCCount(Self:cThrJobs) < Self:nThrJobs
			Sleep(500)
		EndDo
	EndIf

	//Inicia thread para excluir a tabela de controle criada.
	PCPIPCGO(Self:cThrJobs, .F., "A146TabOP", "DELETE", Self:cNameTabOP, Self:lUsaTemp, Self:cUIDStatus, Self:lHoriFirme, Self:dDataIni, Self:cTicket)

	::PersisteSaldos()

Return

/*/{Protheus.doc} criarSecaoGlobal
Cria a seção de variáveis globais que será utilizada no processamento

@type  Method
@author renan.roeder
@since 04/12/2019
@version P12.1.27
@return Nil
/*/
METHOD criarSecaoGlobal() CLASS ExclusaoPrevistos

	If !VarSetUID(Self:cUIDSld)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0001) //"Erro na criação da seção de variáveis globais de saldo."
	EndIf
	If !VarSetUID(Self:cUIDSldLte)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0002) //"Erro na criação da seção de variáveis globais de saldo/lote."
	EndIf
	If !VarSetUID(Self:cUIDSldLcz)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0003) //"Erro na criação da seção de variáveis globais de saldo/localização."
	EndIf
	If !VarSetUID(Self:cUIDStatus)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0004) //"Erro na criação da seção de variáveis globais de status."
	EndIf
	If !VarSetUID(Self:cUIDOrdens)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0005) //"Erro na criação da seção de variáveis globais de Ordens."
	EndIf
	If !VarSetUID(Self:cUIDSB1Cnv)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0006) //"Erro na criação da seção de variáveis globais de conversão de UM."
	EndIf
	If !VarSetUID(Self:cUIDFils)
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0007) //"Erro na criação da seção de variáveis globais de filiais."
	EndIf

Return Nil

/*/{Protheus.doc} AguardaInicioCalculoMRP
Aguarda Início dos Cálculos do MRP

@type  Method
@author brunno.costa
@since 20/05/2020
@version P12.1.27
@param 01 - lCalTmpIni, lógico, indica se deve realizar o calculo de tempo inicial
@return lReturn, lógico, indica se iniciou o cálculo do MRP e deve prosseguir na exclusão dos documentos
/*/
METHOD AguardaInicioCalculoMRP(lCalTmpIni) CLASS ExclusaoPrevistos

	Local lReturn    := .T.
	Local lFlagOk    := .T.
	Local oProcesso  := JsonObject():New()
	Local oStatus
	Local nSecTotal  := 0
	Local nLiberaSC2 := 0

	Default lCalTmpIni   := .F.
	Default lAutoMacao   := .F.

	If lCalTmpIni
		oStatus := MrpDados_Status():New(Self:cTicket)
		VarGetXD(Self:cUIDStatus, "nLiberaSC2", @nLiberaSC2)

		If !lAutoMacao
			While nLiberaSC2 < 3
				Sleep(3000)
				VarGetXD(Self:cUIDStatus, "nLiberaSC2", @nLiberaSC2)
			EndDo

			nSecTotal := oStatus:getStatus("tempo_exlusao_previstos_ini", @lFlagOk)
			If !lFlagOk
				nSecTotal := 0
			EndIf
			nSecTotal := IIF(!lAutoMacao, MicroSeconds(), 0) - nSecTotal
		EndIf
		oStatus:setStatus("tempo_exlusao_previstos_ini", nSecTotal)
	EndIf

	//Aguarda Início do Cálculo do MRP
	aReturn := MrpGet(cFilAnt, Self:cTicket)
	oProcesso:fromJson(aReturn[2])
	If !lAutoMacao
		While (oProcesso["mrpCalculationStatus"] == Nil .OR. ;
			(!(oProcesso["mrpCalculationStatus"] $ "|2|3|4|9|");
			.AND. !(oProcesso["status"] $ "|4|9|")) )
			Sleep(3000)
			aReturn := MrpGet(cFilAnt, Self:cTicket)
			oProcesso:fromJson(aReturn[2])
		EndDo
	EndIf

	If lCalTmpIni
		oStatus:setStatus("tempo_exlusao_previstos_fim", MicroSeconds())
		oStatus := FreeObj(oStatus)
	EndIf

	//Não executa em caso de Cancelamento ou Falha
	IF !lAutoMacao
		lReturn := !(oProcesso["mrpCalculationStatus"] $ "|4|9|")
	EndIf

	oProcesso := FreeObj(oProcesso)

Return lReturn

/*/{Protheus.doc} aguardaInclusaoTabOP
Aguarda o término da inclusão de registros na tabela de controle para exclusão das ordens.

@type  Method
@author lucas.franca
@since 03/09/2020
@version P12
@return lOk, lógico, indica se a temporária foi criada (caso use temporária) e os registros foram inseridos.
/*/
METHOD aguardaInclusaoTabOP() CLASS ExclusaoPrevistos
	Local lOk     := .T.
	Local nStatus := 0

	VarGetXD(Self:cUIDStatus, "statusTabOP", @nStatus)

	While nStatus <> 1
		//Status -1 indica erro na criação/inclusão da tabela.
		If nStatus == -1
			lOk := .F.
			Exit
		EndIf
		Sleep(500)
		VarGetXD(Self:cUIDStatus, "statusTabOP", @nStatus)
	EndDo

Return lOk

/*/{Protheus.doc} ExcluiOrdensProducao
Exclui os registros da tabela SC2.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD ExcluiOrdensProducao() CLASS ExclusaoPrevistos
	Local cThrID     := Self:cThrJobs + "OP"
	Local cUpdDel    := ""
	Local nTotalThr  := 4
	Local nQtd       := 0
	Local nIniTime      := 0

	VarSetXD(Self:cUIDStatus, "nLiberaSC2", 0)

	PCPIPCGO(cThrID, .F., "A146SldSC2", Self:cTicket, Self:lHoriFirme, Self:dDataIni)
	PCPIPCGO(cThrID, .F., "A146SldSD4", Self:cTicket, Self:lHoriFirme, Self:dDataIni)
	PCPIPCGO(cThrID, .F., "A146SldSDC", Self:cTicket, Self:lHoriFirme, Self:dDataIni)

	nIniTime := MicroSeconds()
	Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de ordens de produção - Aguardando o inicio do calculo do MRP e inclusão da tabela de OPs."}, .F., .F., .T.)
	If Self:AguardaInicioCalculoMRP(.T.) .And. Self:aguardaInclusaoTabOP()
		Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de ordens de produção - Fim do aguardo do inicio do calculo do MRP e inclusão da tabela de OPs. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

		PCPIPCGO(cThrID, .F., "A146AtuPMP", Self:cTicket, Self:lHoriFirme, Self:dDataIni)

		//Aguarda o término das consultas no banco
		VarGetXD(Self:cUIDStatus, "nLiberaSC2", @nQtd)
		While nQtd < 4
			VarGetXD(Self:cUIDStatus, "nLiberaSC2", @nQtd)
			Sleep(50)
		EndDo

		IntegraOP(Self)


		PCPIPCGO(cThrID, .F., "A146ExVen",  Self:cNameTabOP)

		//Apaga as ordens de produção
		cUpdDel := " UPDATE " + RetSqlName("SC2")
		cUpdDel +=    " SET D_E_L_E_T_   = '*' "
		If !Empty(FWX2Unico( 'SC2'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_ "
		EndIf
		cUpdDel +=  " WHERE EXISTS( SELECT 1 "
		cUpdDel +=                  " FROM " + Self:cNameTabOP + " TAB_OP "
		cUpdDel +=                 " WHERE TAB_OP.MD_REC = " + RetSqlName("SC2") + ".R_E_C_N_O_ ) "

		If TcSqlExec(cUpdDel) < 0
			Final("Erro ao excluir os registros de Ordens de Produção.", TcSqlError())
		EndIf

		//Elimina os registros das demais tabelas.
		PCPIPCGO(cThrID, .F., "A146DelSD4",  Self:cNameTabOP, Self:cTicket)
		PCPIPCGO(cThrID, .F., "A146DelSDC",  Self:cNameTabOP, Self:cTicket)
		PCPIPCGO(cThrID, .F., "A146DelOS" ,  Self:cNameTabOP, Self:cTicket)
		PCPIPCGO(cThrID, .F., "A146DelSHY",  Self:cNameTabOP, Self:cTicket)
		PCPIPCGO(cThrID, .F., "A146DelSH8",  Self:cNameTabOP, Self:cTicket)
		If _lCrpOk
			PCPIPCGO(cThrID, .F., "A146DelHWF",  Self:cNameTabOP, Self:cTicket)
		Endif
		PCPIPCGO(cThrID, .F., "A146DelSMH",  Self:cNameTabOP, Self:cTicket, Self:cUIDStatus)
		PCPIPCGO(cThrID, .F., "A146DelTr" ,  Self:cTicket                 )

		//Aguarda o término - liberação das Threads
		While IPCCount(cThrID) < nTotalThr
			Sleep(50)
		EndDo

	EndIf

Return

/*/{Protheus.doc} A146SldSD4
Percorre os empenhos alimentando as variáveis globais de saldo.

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param 01 - cTicket   , Character, Número do ticket do MRP em processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@return Nil
/*/
Function A146SldSD4(cTicket, lHoriFirme, dDataIni)
	Local aFiliais  := {}
	Local cAliasSD4 := GetNextAlias()
	Local cFilProc  := ""
	Local cWhereIN  := ""
	Local cQuerySD4 := ""
	Local nInd      := 1
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local nSizeQtd  := GetSx3Cache("D4_QUANT","X3_TAMANHO")
	Local nDecQtd   := GetSx3Cache("D4_QUANT","X3_DECIMAL")

	Default lHoriFirme := .F.
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)

	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		If nIndFil > 1
			cQuerySD4 += " UNION ALL"
		EndIf

		cQuerySD4 += " SELECT '" + cFilProc + "' AS D4_FILIAL,"
		cQuerySD4 +=        " SD4.D4_COD,"
		cQuerySD4 +=        " SD4.D4_LOCAL,"
		cQuerySD4 +=        " SD4.D4_QUANT,"
		cQuerySD4 +=        " SD4.D4_LOTECTL,"
		cQuerySD4 +=        " SD4.D4_NUMLOTE"
		cQuerySD4 +=   " FROM " + RetSqlName("SD4") + " SD4"
		cQuerySD4 +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 ON " + getWhereC2(.F., " ", cFilProc)
		cQuerySD4 +=    " AND " + PCPQrySC2("SC2", "SD4.D4_OP")
		cQuerySD4 +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4", cFilProc) + "'
		cQuerySD4 +=    " AND SD4.D_E_L_E_T_ = ' '"

		If lHoriFirme
			cWhereIN := ""
			oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), dDataIni)
			cQuerySD4 += " AND SC2.R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
		EndIf
	Next nIndFil

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySD4),cAliasSD4,.F.,.F.)

	VarSetX(oExcPrevistos:cUIDStatus, "nLiberaSC2", @nInd, 1, 1)

	TcSetField(cAliasSD4, 'D4_QUANT', 'N', nSizeQtd, nDecQtd)
	If !lAutoMacao
		While !(cAliasSD4)->(Eof())
			oExcPrevistos:SetSaldos((cAliasSD4)->D4_FILIAL, (cAliasSD4)->D4_COD,(cAliasSD4)->D4_LOCAL, (cAliasSD4)->D4_LOTECTL, (cAliasSD4)->D4_NUMLOTE,,, (cAliasSD4)->D4_QUANT, 2)
			(cAliasSD4)->(dbSkip())
		EndDo
	EndIf
	(cAliasSD4)->(dbCloseArea())

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146SldSC2
Percorre as ordens de produção alimentando as variáveis globais de saldo.

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param 01 - cTicket   , Character, Número do ticket do MRP em processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@return Nil
/*/
Function A146SldSC2(cTicket, lHoriFirme, dDataIni)
	Local aDadosDel  := {}
	Local aFiliais   := {}
	Local cAliasSC2  := GetNextAlias()
	Local cFilProc   := ""
	Local cWhere     := ""
	Local cWhereIN   := ""
	Local lIntNewMRP := Ma650MrpOn(@_lNewMRP)
	Local nInd       := 1
	Local nIndFil    := 1
	Local nLenAFils  := 0
	Local nSizeQtd   := GetSx3Cache("C2_QUANT", "X3_TAMANHO")
	Local nDecQtd    := GetSx3Cache("C2_QUANT", "X3_DECIMAL")

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		cWhere := "%" + getWhereC2(.F., " ", cFilProc)
		If lHoriFirme
			cWhereIN := ""
			oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), dDataIni)
			cWhere += " AND SC2.R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
		EndIf
		cWhere += "%"

		BeginSql Alias cAliasSC2
			COLUMN C2_DATPRI AS DATE
			COLUMN C2_DATPRF AS DATE
			COLUMN C2_DATRF  AS DATE
			COLUMN C2_QUANT  AS Numeric(nSizeQtd, nDecQtd)
			COLUMN C2_QUJE   AS Numeric(nSizeQtd, nDecQtd)
			SELECT SC2.C2_FILIAL,
				   SC2.C2_NUM,
				   SC2.C2_ITEM,
				   SC2.C2_SEQUEN,
				   SC2.C2_ITEMGRD,
				   SC2.C2_SEQPAI,
				   SC2.C2_PRODUTO,
				   SC2.C2_LOCAL,
				   SC2.C2_QUANT,
				   SC2.C2_QUJE,
				   SC2.C2_PERDA,
				   SC2.C2_DATPRI,
				   SC2.C2_DATPRF,
				   SC2.C2_DATRF,
				   SC2.C2_TPOP,
				   SC2.C2_STATUS,
				   SC2.R_E_C_N_O_ AS RECNO,
				   SC2.C2_OPC,
				   SC2.C2_MOPC
			FROM %Table:SC2% SC2
			WHERE %Exp:cWhere%
		EndSql

		While !(cAliasSC2)->(Eof())
			oExcPrevistos:SetSaldos(cFilProc, (cAliasSC2)->C2_PRODUTO, (cAliasSC2)->C2_LOCAL, , , , , (cAliasSC2)->C2_QUANT, 1)

			If lIntNewMRP
				If (cAliasSC2)->(FieldPos("C2_MOPC")) == 0
					SC2->(DbGoTo((cAliasSC2)->RECNO))
					A650AddInt(@aDadosDel, 0, "DELETE", "SC2")
				Else
					A650AddInt(@aDadosDel, 0, "DELETE", cAliasSC2, cValToChar((cAliasSC2)->RECNO))
				EndIf
			EndIf

			(cAliasSC2)->(dbSkip())
		EndDo
		(cAliasSC2)->(dbCloseArea())
	Next nIndFil

	VarSetX(oExcPrevistos:cUIDStatus, "nLiberaSC2", @nInd, 1, 1)

	If lIntNewMRP .And. Len(aDadosDel) > 0
		//A integração das ordens é iniciada no pool de threads principal
		//para que não seja necessário aguardar o fim neste processo
		//da exclusão das ordens.
		PCPIPCGO(oExcPrevistos:cThrJobs, .F., "A146IntOp" , oExcPrevistos:cTicket, aDadosDel)

		aDadosDel := aSize(aDadosDel, 0)

	EndIf

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146IntOp
Executa a integração das ordens de produção com o MRP.

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param cTicket  , Character, Número do ticket do MRP em processamento
@param aDadosDel, Array    , array de dados formatados para MATA650INT
@return Nil
/*/
Function A146IntOp(cTicket, aDadosDel)
	Local lIntNewMRP   := .F.
	Default lAutoMacao := .F.

	lIntNewMRP := Ma650MrpOn(@_lNewMRP)

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	If lIntNewMRP .AND. oExcPrevistos:AguardaInicioCalculoMRP()
		MATA650INT("DELETE", @aDadosDel)
	EndIf

	aDadosDel := aSize(aDadosDel, 0)

Return Nil

/*/{Protheus.doc} A146SldSDC
Percorre as composições dos empenhos alimentando as variáveis globais de saldo.

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param 01 - cTicket   , Character, Número do ticket do MRP em processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@return Nil
/*/
Function A146SldSDC(cTicket, lHoriFirme, dDataIni)
	Local aFiliais  := {}
	Local cAliasSDC := GetNextAlias()
	Local cFilProc  := ""
	Local cWhereIN  := ""
	Local cQuerySDC := ""
	Local nInd      := 1
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local nSizeQtd  := GetSx3Cache("DC_QUANT","X3_TAMANHO")
	Local nDecQtd   := GetSx3Cache("DC_QUANT","X3_DECIMAL")

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		If nIndFil > 1
			cQuerySDC += " UNION"
		EndIf

		cQuerySDC += " SELECT '" + cFilProc + "' AS DC_FILIAL,"
		cQuerySDC +=        " SDC.DC_PRODUTO,"
		cQuerySDC +=        " SDC.DC_LOCAL,"
		cQuerySDC +=        " SDC.DC_LOCALIZ,"
		cQuerySDC +=        " SDC.DC_NUMSERI,"
		cQuerySDC +=        " SDC.DC_LOTECTL,"
		cQuerySDC +=        " SDC.DC_NUMLOTE,"
		cQuerySDC +=        " SDC.DC_QUANT,"
		cQuerySDC +=        " SDC.R_E_C_N_O_"
		cQuerySDC +=   " FROM " + RetSqlName("SDC") + " SDC"
		cQuerySDC +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 ON " + getWhereC2(.F., " ", cFilProc)
		cQuerySDC +=    " AND " + PCPQrySC2("SC2", "SDC.DC_OP")
		cQuerySDC +=  " WHERE SDC.DC_FILIAL  = '" + xFilial("SDC", cFilProc) + "'"
		cQuerySDC +=    " AND SDC.D_E_L_E_T_ = ' '"

		If lHoriFirme
			cWhereIN := ""
			oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), dDataIni)
			cQuerySDC += " AND SC2.R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
		EndIf
	Next nIndFil

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySDC),cAliasSDC,.F.,.F.)

	VarSetX(oExcPrevistos:cUIDStatus, "nLiberaSC2", @nInd, 1, 1)

	TcSetField(cAliasSDC, 'DC_QUANT', 'N', nSizeQtd, nDecQtd)

	Do While !(cAliasSDC)->(Eof())
		oExcPrevistos:SetSaldos( (cAliasSDC)->DC_FILIAL ,;
		                         (cAliasSDC)->DC_PRODUTO,;
		                         (cAliasSDC)->DC_LOCAL  ,;
		                         (cAliasSDC)->DC_LOTECTL,;
		                         (cAliasSDC)->DC_NUMLOTE,;
		                         (cAliasSDC)->DC_LOCALIZ,;
		                         (cAliasSDC)->DC_NUMSERI,;
		                         (cAliasSDC)->DC_QUANT  ,;
		                         2)

		(cAliasSDC)->(dbSkip())
	EndDo
	(cAliasSDC)->(dbCloseArea())

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146AtuPMP
Atualiza os campos HC_OP e HC_STATUS das ordens que serão excluídas.

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param 01 - cTicket   , Character, Número do ticket do MRP em processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@return Nil
/*/
Function A146AtuPMP(cTicket, lHoriFirme, dDataIni)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdate  := ""
	Local cWhereIN := ""
	Local nInd      := 1
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]
		cUpdate := "UPDATE " + RetSqlName("SHC")
		cUpdate +=   " SET HC_OP     = '" + Criavar("HC_OP",    .F.) + "',"
		cUpdate +=       " HC_STATUS = '" + Criavar("HC_STATUS",.F.) + "'"
		cUpdate += " WHERE HC_FILIAL = '" + xFilial("SHC", cFilProc) + "'"
		cUpdate +=   " AND HC_OP IN (SELECT " + getC2OP()
		cUpdate +=                   " FROM " + RetSqlName("SC2") + " SC2"
		cUpdate +=                  " WHERE " + getWhereC2(.F., " ", cFilProc)

		If lHoriFirme
			cWhereIN := ""
			oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), dDataIni)
			cUpdate += " AND R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
		EndIf

		cUpdate +=                    ")"
		cUpdate +=    " AND D_E_L_E_T_ = ' '"

		IF !lAutoMacao
			If TcSqlExec(cUpdate) < 0
				Final(STR0008 + " " + cFilProc + ".", TcSqlError()) //"Erro ao atualizar os registros de Plano Mestre de Produção da filial"
				Exit
			EndIf
		ENDIF
	Next nIndFil

	VarSetX(oExcPrevistos:cUIDStatus, "nLiberaSC2", @nInd, 1, 1)

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} ExistC2Del
Monta Trecho de Query Exists Referente Registro Deletado na SC2 (QUE NÃO EXISTE COMO NÃO DELETADO)
@type  Function
@author brunno.costa
@since 22/07/2020
@version P12.1.27
@param cCampo    , Character, Nome do campo para comparação com o número da OP
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cFilProc  , Character, Filial que está sendo usada
@return cQuery, caracter, query referente trecho Exists C2 deletado
/*/
Static Function ExistC2Del(cCampo, cNameTabOP, cFilProc)
	Local cQuery := ""

	cQuery := " EXISTS(SELECT 1"
	cQuery +=          " FROM " + cNameTabOP + " TAB_OP"
	cQuery +=         " WHERE TAB_OP.MD_OP = " + cCampo
	cQuery +=           " AND TAB_OP.MD_FILIAL = '" + xFilial("SC2", cFilProc) + "')"

Return cQuery

/*/{Protheus.doc} A146FilSC2
Monta Trecho de Query com registros a serem deletados
@type  Function
@author Jefferson.Possidonio
@since 14/05/2024
@version P12
@param 01 cFilProc  , Character, Filial que está sendo usada
@param 02 dDataIni  , Date     , Data de processamento do MRP utilizada como referência (database)
@param 03 lHoriFirme, Logic    , Indica se considera horizonte firme.
@param 04 cTicket   , Character, Ticket do processamento
@return cQuery, caracter, where referente as OPs que serão deletadas
/*/
Function A146FilSC2(cFilProc, dDataIni, lHoriFirme, cTicket)
	Local cQuery   := ""
	Local cWhereIN := ""

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	cQuery += getWhereC2(.F., " ", cFilProc)

	If lHoriFirme
		cWhereIN := ""
		oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), dDataIni)
		cQuery += " AND SC2.R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
	EndIf

Return cQuery

/*/{Protheus.doc} A146DelSD4
Apaga os registros de Empenhos Previstos

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelSD4(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]
		cUpdDel  := " UPDATE " + RetSqlName("SD4")
		cUpdDel  +=    " SET D_E_L_E_T_   = '*'"
		If !Empty(FWX2Unico( 'SD4'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
		EndIf
		cUpdDel  +=  " WHERE D4_FILIAL  = '" + xFilial("SD4", cFilProc) + "'"
		cUpdDel  +=    " AND D_E_L_E_T_ = ' '"
		cUpdDel  +=    " AND " + ExistC2Del("D4_OP", cNameTabOP, cFilProc)

		IF !lAutoMacao
			If TcSqlExec(cUpdDel) < 0
				Final(STR0009 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Empenhos da filial"
				Exit
			EndIf
		ENDIF
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return

/*/{Protheus.doc} A146DelSDC
Apaga os registros de Composições de Empenhos Previstos

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelSDC(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		cUpdDel := " UPDATE " + RetSqlName("SDC")
		cUpdDel +=    " SET D_E_L_E_T_   = '*'"
		If !Empty(FWX2Unico( 'SDC'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
		EndIf
		cUpdDel +=  " WHERE DC_FILIAL  = '" + xFilial("SDC", cFilProc) + "'"
		cUpdDel +=    " AND D_E_L_E_T_ = ' '"
		cUpdDel +=    " AND " + ExistC2Del("DC_OP", cNameTabOP, cFilProc)

		IF !lAutoMacao
			If TcSqlExec(cUpdDel) < 0
				Final(STR0010 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Composição de Empenhos da filial"
				Exit
			EndIf
		ENDIF
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return

/*/{Protheus.doc} A146DelOS
Apaga os registros de Ordens de Substituição

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelOS(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If SuperGetMV("MV_PCPOS",.F.,.F.)
		If oExcPrevistos == Nil
			oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
		EndIf

		aFiliais  := oExcPrevistos:RetornaFiliais()
		nLenAFils := Len(aFiliais)
		For nIndFil := 1 To nLenAFils
			cFilProc := aFiliais[nIndFil]

			cUpdDel  := " UPDATE " + RetSqlName("SVJ")
			cUpdDel  +=    " SET D_E_L_E_T_   = '*'"
			If !Empty(FWX2Unico( 'SVJ'))
				cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
			EndIf
			cUpdDel  +=  " WHERE VJ_FILIAL  = '" + xFilial("SVJ", cFilProc) + "'"
			cUpdDel  +=    " AND D_E_L_E_T_ = ' '"
			cUpdDel  +=    " AND VJ_NUM    IN (SELECT SVF.VF_NUM"
			cUpdDel  +=                        " FROM " + RetSqlName("SVF") + " SVF"
			cUpdDel  +=                       " WHERE SVF.VF_FILIAL  = '" + xFilial("SVF", cFilProc) + "'"
			cUpdDel  +=                         " AND SVF.D_E_L_E_T_ = ' '"
			cUpdDel  +=                         " AND " + ExistC2Del("SVF.VF_OP", cNameTabOP, cFilProc) + ")"

			IF !lAutoMacao
				If TcSqlExec(cUpdDel) < 0
					Final(STR0011 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Ordens de substituição (Detalhe) da filial"
					Exit
				EndIf
			ENDIF

			cUpdDel := " UPDATE " + RetSqlName("T4I")
			cUpdDel +=    " SET D_E_L_E_T_   = '*'"
			If !Empty(FWX2Unico( 'T4I'))
				cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
			EndIf
			cUpdDel +=  " WHERE T4I_FILIAL  = '" + xFilial("T4I", cFilProc) + "'"
			cUpdDel +=    " AND D_E_L_E_T_  = ' '"
			cUpdDel +=    " AND T4I_NUM    IN (SELECT SVF.VF_NUM"
			cUpdDel +=                         " FROM " + RetSqlName("SVF") + " SVF"
			cUpdDel +=                        " WHERE SVF.VF_FILIAL  = '" + xFilial("SVF", cFilProc) + "'"
			cUpdDel +=                          " AND SVF.D_E_L_E_T_ = ' '"
			cUpdDel +=                          " AND " + ExistC2Del("SVF.VF_OP", cNameTabOP, cFilProc) + ")"

			IF !lAutoMacao
				If TcSqlExec(cUpdDel) < 0
					Final(STR0012 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Ordens de substituição (Endereços) da filial"
					Exit
				EndIf
			ENDIF

			cUpdDel := " UPDATE " + RetSqlName("SVF")
			cUpdDel +=    " SET D_E_L_E_T_   = '*'"
			If !Empty(FWX2Unico( 'SVF'))
				cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
			EndIf
			cUpdDel +=  " WHERE VF_FILIAL  = '" + xFilial("SVF", cFilProc) + "'"
			cUpdDel +=    " AND D_E_L_E_T_ = ' '"
			cUpdDel +=    " AND " + ExistC2Del("VF_OP", cNameTabOP, cFilProc)

			IF !lAutoMacao
				If TcSqlExec(cUpdDel) < 0
					Final(STR0013 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Ordens de substituição (Mestre) da filial"
					Exit
				EndIf
			ENDIF
		Next nIndFil
	EndIf

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146DelSHY
Apaga os registros de Operações da Ordem

@type  Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelSHY(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]
		cUpdDel  := " UPDATE " + RetSqlName("SHY")
		cUpdDel  +=    " SET D_E_L_E_T_   = '*'"
		If !Empty(FWX2Unico( 'SHY'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
		EndIf
		cUpdDel  +=  " WHERE HY_FILIAL  = '" + xFilial("SHY", cFilProc) + "'"
		cUpdDel  +=    " AND D_E_L_E_T_ = ' '"
		cUpdDel  +=    " AND " + ExistC2Del("HY_OP", cNameTabOP, cFilProc)

		If !lAutoMacao
			If TcSqlExec(cUpdDel) < 0
				Final(STR0014 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Operações da Ordem de Produção da filial"
				Exit
			EndIf
		EndIf
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146DelSH8
Apaga os registros de Operações Alocadas

@type  Function
@author juliana.oliveira
@since 29/05/2024
@version P12.1.2410
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelSH8(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]
		cUpdDel  := " UPDATE " + RetSqlName("SH8")
		cUpdDel  +=    " SET D_E_L_E_T_   = '*'"
		If !Empty(FWX2Unico( 'SH8'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
		EndIf
		cUpdDel  +=  " WHERE H8_FILIAL  = '" + xFilial("SH8", cFilProc) + "'"
		cUpdDel  +=    " AND D_E_L_E_T_ = ' '"
		cUpdDel  +=    " AND " + ExistC2Del("H8_OP", cNameTabOP, cFilProc)

		If !lAutoMacao
			If TcSqlExec(cUpdDel) < 0
				Final(STR0031 + " " + cFilProc + ".", TcSqlError()) //"Erro ao excluir os registros de Operações Alocadas da Ordem de Produção da filial"
				Exit
			EndIf
		EndIf
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146DelHWF
Apaga os registros de ordens efetivadas
@type  Function
@author Jefferson Possidonio
@since 13/05/2024
@version P12
@param cNameTabOP, caracter, Nome da tabela de controle de OPs excluídas
@param cTicket   , caracter, Ticket do processamento
@return Nil
/*/
Function A146DelHWF(cNameTabOP, cTicket)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cUpdDel   := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]
		cUpdDel  := " UPDATE " + RetSqlName("HWF")
		cUpdDel  +=    " SET D_E_L_E_T_   = '*'"
		If !Empty(FWX2Unico( 'HWF'))
			cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
		EndIf
		cUpdDel  +=  " WHERE HWF_FILIAL  = '" + xFilial("HWF", cFilProc) + "'"
		cUpdDel  +=    " AND D_E_L_E_T_ = ' '"
		cUpdDel  +=    " AND " + ExistC2Del("HWF_OP", cNameTabOP, cFilProc)

		If !lAutoMacao
			If TcSqlExec(cUpdDel) < 0
				Final(STR0032, TcSqlError()) //"Ocorreu um erro ao remover a ordem de produção da tabela (HWF)."
				Exit
			EndIf
		EndIf
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} A146DelSMH
Apaga os registros de Rastreabilidade das demandas

@type  Function
@author marcelo.neumann
@since 04/12/2020
@version P12.1.31
@param cNameTabOP, Character, Nome da tabela de controle de OPs excluídas
@param cTicket   , character, Ticket do processamento
@return Nil
/*/
Function A146DelSMH(cNameTabOP, cTicket, cUIDStatus)
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local nIndFil   := 1
	Local nLenAFils := 0

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	aFiliais  := oExcPrevistos:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		excluiSMH(xFilial("SMH", cFilProc), "OP", ExistC2Del("MH_NMDCENT", cNameTabOP, cFilProc), cUIDStatus)
	Next nIndFil

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} ExcluiSolicitacoesCompra
Exclui os registros da tabela SC1

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD ExcluiSolicitacoesCompra() CLASS ExclusaoPrevistos
	Local aFiliais  := {}
	Local cAliasSC1 := GetNextAlias()
	Local cFilBkp   := cFilAnt
	Local cFilProc  := ""
	Local cQuerySC1 := ""
	Local cUpdDel   := ""
	Local cWhere    := ""
	Local lAprovEt  := .F.
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local nIniTime  := 0
	Local nDecQtd   := GetSx3Cache("C1_QUANT","X3_DECIMAL")
	Local nSizeQtd  := GetSx3Cache("C1_QUANT","X3_TAMANHO")
	Local oJsonAlc  := JsonObject():New()
	Local oJsonDhn  := JsonObject():New()

	aFiliais  := self:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc  := aFiliais[nIndFil]

		If nIndFil > 1
			cQuerySC1 += " UNION"
		EndIf

		cQuerySC1 += " SELECT '" + cFilProc + "' AS C1_FILIAL," + ;
							" SC1.C1_PRODUTO,"                  + ;
							" SC1.C1_LOCAL,"                    + ;
							" SC1.C1_NUM,"                      + ;
							" SC1.C1_QUANT,"                    + ;
							" SC1.R_E_C_N_O_ AS RECNO,"         + ;
							" SC1.C1_OP"                        + ;
					   " FROM " + RetSqlName("SC1") + " SC1"    + ;
					  " WHERE " + whereSC1(cFilProc, Self:cTicket)
	Next nIndFil

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySC1),cAliasSC1,.T.,.T.)

	TcSetField(cAliasSC1, 'C1_QUANT', 'N', nSizeQtd, nDecQtd)

	Do While !(cAliasSC1)->(Eof())
		::SetSaldos((cAliasSC1)->C1_FILIAL, (cAliasSC1)->C1_PRODUTO, (cAliasSC1)->C1_LOCAL,,,,, (cAliasSC1)->C1_QUANT, 1)
		(cAliasSC1)->(dbSkip())
	EndDo

	nIniTime := MicroSeconds()
	Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de solicitações de compra - Aguardando o inicio do calculo do MRP."}, .F., .F., .T.)
	If Self:AguardaInicioCalculoMRP()
		Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de solicitações de compra - Fim do aguardo do inicio do calculo do MRP. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

		For nIndFil := 1 To nLenAFils
			cFilAnt  := aFiliais[nIndFil]
			lAprovEt := SuperGetMV("MV_APRSCEC",.F.,.T.) // Alcada por Entidade Contabil

			If lAprovEt .OR. Self:lExistDHN1
				(cAliasSC1)->(DbGoTop())

				Do While !(cAliasSC1)->(Eof())
					If xFilial("SC1", cFilAnt) == (cAliasSC1)->(C1_FILIAL)
						If lAprovEt
							If oJsonAlc[(cAliasSC1)->(C1_FILIAL) + (cAliasSC1)->(C1_NUM)] == Nil
								oJsonAlc[(cAliasSC1)->(C1_FILIAL) + (cAliasSC1)->(C1_NUM)] := .T.
								A650ALCCTB((cAliasSC1)->(C1_OP), (cAliasSC1)->(RECNO))
							EndIf
						EndIf

						If Self:lExistDHN1
							If oJsonDhn[(cAliasSC1)->(C1_FILIAL) + (cAliasSC1)->(C1_NUM)] == Nil
								oJsonDhn[(cAliasSC1)->(C1_FILIAL) + (cAliasSC1)->(C1_NUM)] := .T.
								COMEXCDHN("1", xFilial("SC1"), (cAliasSC1)->(C1_NUM))
							EndIf
						EndIf
					EndIf

					(cAliasSC1)->(dbSkip())
				EndDo
			EndIf

			cUpdDel := "UPDATE " + RetSqlName("SC1")
			cUpdDel +=   " SET D_E_L_E_T_   = '*' "
			If !Empty(FWX2Unico('SC1'))
				cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
			EndIf

			cWhere := whereSC1(cFilAnt, Self:cTicket)

			cUpdDel += " WHERE " + StrTran(cWhere, "SC1.", " ")

			//Exclui a rastreabilidade
			excluiSMH(xFilial("SMH"), "SC", cWhere, Self:cUIDStatus)

			If TcSqlExec(cUpdDel) < 0
				Final(STR0015 + " " + cFilAnt + ".", TcSqlError()) //"Erro ao excluir os registros de Solicitação de compras da filial"
				Exit
			EndIf
		Next nIndFil

		cFilAnt := cFilBkp
	EndIf
	(cAliasSC1)->(dbCloseArea())

	aFiliais := FwFreeArray(aFiliais)

Return

/*/{Protheus.doc} whereSC1
Retorna a clausa WHERE para buscar as compras na tabela SC1.
@type  Static Function
@author Lucas Fagundes
@since 27/01/2025
@version P12
@param 01 cFilBusca, Caracter, Filial que ira filtrar a busca.
@param 02 cTicket  , Caracter, Ticket do MRP.
@return cWhere, Caracter, Clausula WHERE para buscar as compras na SC1.
/*/
Static Function whereSC1(cFilBusca, cTicket)
	Local cWhere        := ""
	Local cWhereIN      := ""
	Local oExcPrevistos := ExclusaoPrevistos():New(cTicket, .F.)

	cWhere :=      "SC1.D_E_L_E_T_ = ' '"
	cWhere += " AND SC1.C1_FILIAL  = '" + xFilial("SC1", cFilBusca) + "'"
	cWhere += " AND SC1.C1_TPOP    = 'P'"

	If SuperGetMV("MV_MRPDEL",.F.,.F.)
		cWhere += " AND SC1.C1_SEQMRP <> '" + CriaVar("C1_SEQMRP") + "'"
	EndIf

	If oExcPrevistos:lHoriFirme
		oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilBusca, "SC1", "C1_PRODUTO", "C1_DATPRF", cWhere, oExcPrevistos:dDataIni)
		cWhere += " AND SC1.R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
	EndIf

Return cWhere

/*/{Protheus.doc} ExisteDHNValido
Verifica se existem registros na DHN para exclusão

@type  Method
@author brunno.costa
@since 18/05/2020
@version P12.1.27
@param 01 - cTipo  , caracter, tipo do documento
@lReturn, lógico, indica se existem registros da DHN para exclusão
/*/

METHOD ExisteDHNValido(cTipo) CLASS ExclusaoPrevistos

	Local aFiliais  := {}
	Local cAliasDHN := GetNextAlias()
	Local cFilProc  := ""
	Local cQueryDHN := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local lReturn   := .F.
	Local lRetAux   := VarGetXD(Self:cUIDSB1Cnv, "ExisteDHNValido" + cTipo, @lReturn)

	If !lRetAux
		aFiliais  := Self:RetornaFiliais()
		nLenAFils := Len(aFiliais)
		If nLenAFils > 0
			For nIndFil := 1 To nLenAFils
				cFilProc := aFiliais[nIndFil]

				If nIndFil > 1
					cQueryDHN += " UNION"
				EndIf

				If cTipo == "1"
					cQueryDHN += " SELECT 1 QTD"                                                  + ;
								   " FROM " + RetSqlName("DHN") + " DHN"                          + ;
								   " JOIN " + RetSqlName("SC1") + " SC1"                          + ;
								 	 " ON DHN.DHN_DOCDES = SC1.C1_NUM"                            + ;
								  " WHERE DHN.D_E_L_E_T_ = ' '"                                   + ;
									" AND SC1.D_E_L_E_T_ = ' '"                                   + ;
									" AND SC1.C1_TPOP    = 'P'"                                   + ;
									" AND SC1.C1_RESIDUO = ' '"                                   + ;
									" AND (SC1.C1_QUANT  - SC1.C1_QUJE) > 0"                      + ;
									" AND (DHN_FILDES    = '" + xFilial("DHN", cFilProc) + "' OR" + ;
										 " DHN_FILDES    = ' ')"                                  + ;
									" AND DHN_FILIAL     = '" + xFilial("DHN", cFilProc) + "'"    + ;
									" AND DHN_TIPO       = '" + cTipo + "'"
				ElseIf cTipo == "3"
					cQueryDHN += " SELECT 1 QTD "                                                 + ;
								   " FROM " + RetSqlName("DHN") + " DHN"                          + ;
								   " JOIN " + RetSqlName("SC7") + " SC7"                          + ;
									 " ON DHN.DHN_DOCDES = SC7.C7_NUM"                            + ;
								  " WHERE DHN.D_E_L_E_T_ = ' '"                                   + ;
									" AND SC7.D_E_L_E_T_ = ' '"                                   + ;
									" AND SC7.C7_TPOP    = 'P'"                                   + ;
									" AND SC7.C7_RESIDUO = ' '"                                   + ;
									" AND (SC7.C7_QUANT  - SC7.C7_QUJE) > 0"                      + ;
									" AND (DHN_FILDES    = '" + xFilial("DHN", cFilProc) + "' OR" + ;
										 " DHN_FILDES    = ' ')"                                  + ;
									" AND DHN_FILIAL     = '" + xFilial("DHN", cFilProc) + "'"    + ;
									" AND DHN_TIPO       = '" + cTipo + "'"
				EndIf
			Next nIndFil

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryDHN),cAliasDHN,.T.,.T.)
			If !(cAliasDHN)->(Eof())
				lReturn := ((cAliasDHN)->QTD > 0)
			EndIf
			(cAliasDHN)->(dbCloseArea())

			VarSetXD(Self:cUIDSB1Cnv, "ExisteDHNValido" + cTipo, lReturn)
		EndIf
	EndIf

	aFiliais := FwFreeArray(aFiliais)

Return lReturn

/*/{Protheus.doc} ExisteAutorizacaoEntrega
Verifica se existem registros de autorização de entrega

@type  Method
@author brunno.costa
@since 18/05/2020
@version P12.1.27
@lReturn, lógico, indica se existem registros da SC3 para exclusão
/*/

METHOD ExisteAutorizacaoEntrega() CLASS ExclusaoPrevistos

	Local aFiliais  := {}
	Local cAliasSC3 := GetNextAlias()
	Local cFilProc  := ""
	Local cQuerySC3 := ""
	Local lReturn   := .F.
	Local lRetAux   := VarGetXD(Self:cUIDSB1Cnv, "ExisteAutorizacaoEntrega", @lReturn)
	Local nIndFil   := 1
	Local nLenAFils := 0

	If !lRetAux
		aFiliais  := self:RetornaFiliais()
		nLenAFils := Len(aFiliais)
		If nLenAFils > 0
			For nIndFil := 1 To nLenAFils
				cFilProc := aFiliais[nIndFil]

				If nIndFil > 1
					cQuerySC3 += " UNION"
				EndIf

				cQuerySC3 += " SELECT 1 QTD "                                              + ;
							   " FROM " + RetSqlName("SC3") + " SC3"                       + ;
							   " JOIN " + RetSqlName("SC7") + " SC7"                       + ;
								 " ON SC3.C3_NUM     = SC7.C7_NUMSC"                       + ;
								" AND SC3.C3_ITEM    = SC7.C7_ITEMSC"                      + ;
							  " WHERE SC3.D_E_L_E_T_ = ' '"                                + ;
								" AND SC3.C3_FILIAL  = '" + xFilial("SC3", cFilProc) + "'" + ;
								" AND SC7.D_E_L_E_T_ = ' '"                                + ;
								" AND SC7.C7_TIPO    = 2"                                  + ;
								" AND SC7.C7_TPOP    = 'P'"                                + ;
								" AND SC7.C7_RESIDUO = ' '"                                + ;
								" AND SC7.C7_FILIAL  = '" + xFilial("SC7", cFilProc) + "'" + ;
								" AND (SC7.C7_QUANT - SC7.C7_QUJE) > 0"

			Next nIndFil

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySC3),cAliasSC3,.T.,.T.)
			If !(cAliasSC3)->(Eof())
				lReturn := ((cAliasSC3)->QTD > 0)
			EndIf
			(cAliasSC3)->(dbCloseArea())

			VarSetXD(Self:cUIDSB1Cnv, "ExisteAutorizacaoEntrega", lReturn)
		EndIf
	EndIf

	aFiliais := FwFreeArray(aFiliais)

Return lReturn

/*/{Protheus.doc} cargaSB1Conversao
Carrega Fator Multiplicativo de Conversão da Quantidade

@type  Function
@author brunno.costa
@since 19/05/2020
@version P12.1.30
@return Nil
/*/
METHOD cargaSB1Conversao() CLASS ExclusaoPrevistos
	Local aFiliais  := {}
	Local cAliasSB1 := GetNextAlias()
	Local cChave    := ""
	Local cFilProc  := ""
	Local cQuerySB1 := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Default lAutoMacao := .F.

	aFiliais  := Self:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		If nIndFil > 1
			cQuerySB1 += " UNION"
		EndIf

		cQuerySB1 += " SELECT B1_FILIAL,"                     + ;
		                    " B1_COD,"                        + ;
		                    " (CASE B1_TIPCONV WHEN 'D' THEN" + ;
		                        " ROUND(1 / B1_CONV, 8)"      + ;
		                     " ELSE"                          + ;
		                        " B1_CONV"                    + ;
		                     " END) AS B1_CONV"               + ;
		               " FROM " + RetSqlName("SB1")           + ;
		              " WHERE D_E_L_E_T_ = ' '"               + ;
		                " AND B1_CONV   <> 0"                 + ;
		                " AND B1_FILIAL  = '" + xFilial("SB1", cFilProc) + "'"
	Next nIndFil

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySB1),cAliasSB1,.F.,.F.)
	If !lAutoMacao
		Do While !(cAliasSB1)->(Eof())
			cChave := (cAliasSB1)->B1_FILIAL + PadR((cAliasSB1)->B1_COD, snTamCod)
			VarSetXD(Self:cUIDSB1Cnv, cChave, (cAliasSB1)->B1_CONV)
			(cAliasSB1)->(dbSkip())
		EndDo
		(cAliasSB1)->(dbCloseArea())
	EndIf

	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} ConverteUM
Converte Na Segunda Unidade de Medida

@type  Function
@author brunno.costa
@since 19/05/2020
@version P12.1.30
@param 01 - cFilProc, caracter, código da filial
@param 02 - cProduto, caracter, código do produto
@param 03 - nQtd    , número  , quantidade na primeira unidade de medida
@return nQtd2aUM, número, quantidade na segunda unidade de medida
/*/
METHOD converteUM(cFilProc, cProduto, nQtd) CLASS ExclusaoPrevistos
	Local lRet      := .F.
	Local nQtd2aUM  := 0
	Local nFator    := 0

	lRet := VarGetXD(Self:cUIDSB1Cnv, cProduto, @nFator)
	If lRet
		nQtd2aUM := Round(nQtd * nFator, Seld:nDecimal)
	EndIf

Return nQtd2aUM

/*/{Protheus.doc} ExcluiPedidosCompra
Exclui os registros da tabela SC7

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD ExcluiPedidosCompra() CLASS ExclusaoPrevistos
	Local aFiliais  := {}
	Local cAliasSC7 := GetNextAlias()
	Local cFilBkp   := cFilAnt
	Local cFilProc  := ""
	Local cQuerySC7 := ""
	Local cUpdDel   := ""
	Local cWhere    := ""
	Local nDecQtd   := GetSx3Cache("C7_QUANT","X3_DECIMAL")
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local nIniTime  := 0
	Local nSizeQtd  := GetSx3Cache("C7_QUANT","X3_TAMANHO")

	aFiliais  := Self:RetornaFiliais()
	nLenAFils := Len(aFiliais)
	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		If nIndFil > 1
			cQuerySC7 += " UNION"
		EndIf

		cQuerySC7 += " SELECT '" + cFilProc + "' AS C7_FILIAL,"
		cQuerySC7 +=        " SC7.C7_PRODUTO,"
		cQuerySC7 +=        " SC7.C7_LOCAL,"
		cQuerySC7 +=        " SC7.C7_NUM,"
		cQuerySC7 +=        " SC7.C7_NUMSC,"
		cQuerySC7 +=        " SC7.C7_ITEMSC,"
		cQuerySC7 +=        " SC7.C7_QUANT,"
		cQuerySC7 +=        " SC7.R_E_C_N_O_ AS RECNO"
		cQuerySC7 +=   " FROM " + RetSqlName("SC7") + " SC7"
		cQuerySC7 +=  " WHERE " + whereSC7(cFilProc, Self:cTicket)
	Next nIndFil

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerySC7),cAliasSC7,.T.,.T.)

	TcSetField(cAliasSC7, 'C7_QUANT', 'N', nSizeQtd, nDecQtd)

	While !(cAliasSC7)->(Eof())
		::SetSaldos((cAliasSC7)->C7_FILIAL, (cAliasSC7)->C7_PRODUTO, (cAliasSC7)->C7_LOCAL,,,,, (cAliasSC7)->C7_QUANT, 1)
		(cAliasSC7)->(dbSkip())
	EndDo

	nIniTime := MicroSeconds()
	Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de pedidos de compra - Aguardando o inicio do calculo do MRP."}, .F., .F., .T.)
	If Self:AguardaInicioCalculoMRP()
		Self:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Exclusão de pedidos de compra - Fim do aguardo do inicio do calculo do MRP. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

		For nIndFil := 1 To nLenAFils
			cFilProc := aFiliais[nIndFil]

			If Self:lExistAE .OR. Self:lExistDHN3
				(cAliasSC7)->(DbGoTop())
				While !(cAliasSC7)->(Eof())

					If Self:lExistAE
						::AtualizaContratoParceria((cAliasSC7)->C7_FILIAL, (cAliasSC7)->C7_NUMSC, (cAliasSC7)->C7_ITEMSC, (cAliasSC7)->C7_QUANT	)
					EndIf

					If Self:lExistDHN3
						cFilAnt := cFilProc
						COMEXCDHN("3", xFilial("SC7", cFilProc), (cAliasSC7)->C7_NUM)
						cFilAnt := cFilBkp
					EndIf

					(cAliasSC7)->(dbSkip())
				EndDo
			EndIf

			cUpdDel := "UPDATE " + RetSqlName("SC7")
			cUpdDel +=   " SET D_E_L_E_T_   = '*'"
			If !Empty(FWX2Unico( 'SC7'))
				cUpdDel +=  " , R_E_C_D_E_L_ = R_E_C_N_O_"
			EndIf

			cWhere := whereSC7(cFilProc, Self:cTicket)

			cUpdDel += " WHERE " + StrTran(cWhere, "SC7.", " ")

			//Exclui a rastreabilidade
			excluiSMH(xFilial("SMH", cFilProc), "PC", cWhere, Self:cUIDStatus)

			If TcSqlExec(cUpdDel) < 0
				Final(STR0016 + " " + cFilAnt + ".", TcSqlError()) //"Erro ao excluir os registros de Pedidos de compras da filial"
				Exit
			EndIf
		Next nIndFil
	EndIf

	(cAliasSC7)->(dbCloseArea())

	aFiliais := FwFreeArray(aFiliais)

Return

/*/{Protheus.doc} whereSC7
Retorna a clausa WHERE para buscar as compras na tabela SC7.
@type  Static Function
@author Lucas Fagundes
@since 27/01/2025
@version P12
@param 01 cFilBusca, Caracter, Filial que ira filtrar a busca.
@param 02 cTicket  , Caracter, Ticket do MRP.
@return cWhere, Caracter, Clausula WHERE para buscar as compras na SC7.
/*/
Static Function whereSC7(cFilBusca, cTicket)
	Local cWhere        := ""
	Local cWhereIN      := ""
	Local lMrpDel       := SuperGetMV("MV_MRPDEL",.F.,.F.)
	Local oExcPrevistos := ExclusaoPrevistos():New(cTicket, .F.)

	cWhere :=            "SC7.D_E_L_E_T_ = ' '"
	cWhere +=       " AND SC7.C7_FILIAL  = '" + xFilial("SC7", cFilBusca) + "'"
	cWhere +=       " AND SC7.C7_TPOP    = 'P'"
	cWhere +=       " AND SC7.C7_TIPO    = 2 "

	If lMrpDel
		cWhere +=   " AND SC7.C7_SEQMRP <> '" + CriaVar("C7_SEQMRP") + "'"
	EndIf

	If oExcPrevistos:lHoriFirme
		oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilBusca, "SC7", "C7_PRODUTO", "C7_DATPRF", cWhere, oExcPrevistos:dDataIni)
		cWhere += " AND R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
	EndIf

Return cWhere

/*/{Protheus.doc} AtualizaContratoParceria
Subtrai a quantidade da SC da quantidade produzida do contrato de parceria.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param 01 cFilProc, Character, Código da filial da SC
@param 02 cNumSc  , Character, Número da solicitação de compra.
@param 03 cItemSc , Character, Item da solicitação de compra.
@param 04 nQuant  , Character, Quantidade. da solicitação de compra.
/*/
METHOD AtualizaContratoParceria(cFilProc, cNumSc, cItemSc, nQuant) CLASS ExclusaoPrevistos
	dbSelectArea("SC3")
	SC3->(dbSetOrder(1))
	If SC3->(dbSeek(xFilial("SC3", cFilProc) + cNumSc + cItemSc))
		RecLock("SC3",.F.)
		Replace C3_QUJE	With SC3->C3_QUJE - nQuant
		SC3->(MsUnlock())
	EndIf
Return

/*/{Protheus.doc} SetSaldos
Atualiza a tabela de memória para controle dos saldos, adicionando a quantidade recebida em nQtd.
Será atualizada a quantidade da tabela de memória de acordo com o parâmetro nTipo.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param cFilTab , Character, Filial que será atualizada
@param cProduto, Character, Código do produto que será atualizado.
@param cLocal  , Character, Código do local de estoque.
@param cLoteCtl, Character, Código do lote.
@param cNumLote, Character, Código do sublote.
@param cLocaliz, Character, Código do endereço.
@param cNumseri, Character, Código do número de série.
@param nQtd    , Numeric  , Quantidade.
@param nTipo   , Numeric  , Identifica qual é a quantidade que será atualizada.
                            1 - Entrada (B2_SALPPRE);
                            2 - Saída   (B2_QEMPPRE)
/*/
METHOD SetSaldos(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, cLocaliz, cNumseri, nQtd, nTipo) CLASS ExclusaoPrevistos
	Local aDados    := {}
	Local cChaveSld := ""
	Local cChaveLte := ""
	Local cChaveLcz := ""
	Local lRet      := .T.

	Default cLoteCtl := ""
	Default cNumLote := ""
	Default cLocaliz := ""
	Default cNumSeri := ""

	cChaveSld := cFilTab + cProduto + cLocal + CHR(13) + "SLD"
	cChaveLte := cFilTab + cProduto + cLocal + cLoteCtl + cNumLote + CHR(13) + "LTE"
	cChaveLcz := cFilTab + cProduto + cLocal + cLoteCtl + cNumLote + cLocaliz + cNumseri + CHR(13) + "LCZ"

	If Empty(cLocaliz)
		//Inicia transação saldo simples
		VarBeginT(Self:cUIDSld, cChaveSld)

		//Recupera os estoques deste produto
		aDados := Self:GetSaldo(cFilTab, cProduto, cLocal, @lRet)

		If !lRet
			aDados := Array(SALDOS_QTD_TAMANHO)
			aDados[SALDOS_QTD_POS_ENTRADA_PREV ] := 0
			aDados[SALDOS_QTD_POS_SAIDA_PREV   ] := 0
		EndIf

		If nTipo == 1
			aDados[SALDOS_QTD_POS_ENTRADA_PREV ] += nQtd
		ElseIf nTipo == 2
			aDados[SALDOS_QTD_POS_SAIDA_PREV   ] += nQtd
		EndIf

		//Seta os dados na tabela de memória
		lRet := VarSetAD(Self:cUIDSld, cChaveSld, aDados )
		If !lRet
			LogMsg("PCPA146", 0, 0, 1, "", "", STR0017 + " " + cFilTab + ". " + STR0018 + " " + AllTrim(cProduto) + ". " + STR0019 + " " + AllTrim(cLocal) + ".") //"Erro ao atualizar a tabela de saldos do produto. Filial:" XX "Produto:" XXX "Local:"
		EndIf

		//Finaliza a transação saldo simples
		VarEndT(Self:cUIDSld, cChaveSld)

		If !Empty(cLoteCtl)

			//Inicia transação saldo com lote/sublote
			VarBeginT(Self:cUIDSldLte, cChaveLte)

			//Recupera os estoques deste produto
			aDados := aSize(aDados,0)
			aDados := Self:GetLoteSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, @lRet)

			If !lRet
				aDados := Array(SALDOS_QTD_TAMANHO)
				aDados[SALDOS_QTD_POS_ENTRADA_PREV ] := 0
				aDados[SALDOS_QTD_POS_SAIDA_PREV   ] := 0
			EndIf

			If nTipo == 1
				aDados[SALDOS_QTD_POS_ENTRADA_PREV ] += nQtd
			ElseIf nTipo == 2
				aDados[SALDOS_QTD_POS_SAIDA_PREV   ] += nQtd
			EndIf

			//Seta os dados na tabela de memória
			lRet := VarSetAD(Self:cUIDSldLte, cChaveLte, aDados )
			If !lRet
				LogMsg("PCPA146", 0, 0, 1, "", "", STR0020 + " " + cFilTab + ". " + STR0018 + " " + AllTrim(cProduto) + ". " + STR0019 + " " + AllTrim(cLocal) + ".") //"Erro ao atualizar a tabela de saldos/lote do produto. Filial: XX. Produto: XX. Local: XX.
			EndIf

			//Finaliza a transação saldo com lote/sublote
			VarEndT(Self:cUIDSldLte, cChaveLte)
		EndIf

	Else
		//Inicia transação saldo com endereço
		VarBeginT(Self:cUIDSldLcz, cChaveLcz)

		//Recupera os estoques deste produto
		aDados := Self:GetLocalizaSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, cLocaliz, cNumseri, @lRet)

		If !lRet
			aDados := Array(SALDOS_QTD_TAMANHO)
			aDados[SALDOS_QTD_POS_ENTRADA_PREV ] := 0
			aDados[SALDOS_QTD_POS_SAIDA_PREV   ] := 0
		EndIf

		If nTipo == 1
			aDados[SALDOS_QTD_POS_ENTRADA_PREV ] += nQtd
		ElseIf nTipo == 2
			aDados[SALDOS_QTD_POS_SAIDA_PREV   ] += nQtd
		EndIf

		//Seta os dados na tabela de memória
		lRet := VarSetAD(Self:cUIDSldLcz, cChaveLcz, aDados )
		If !lRet
			LogMsg("PCPA146", 0, 0, 1, "", "", STR0021 + " " + cFilTab + ". " + STR0018 + " " + AllTrim(cProduto) + ". " + STR0019 + " " + AllTrim(cLocal) + ".") //"Erro ao atualizar a tabela de saldos/localização do produto. Filial: XX. Produto: XX. Local: XX.
		EndIf

		//Finaliza a transação saldo com endereço
		VarEndT(Self:cUIDSldLcz, cChaveLcz)
	EndIf

	aDados := FwFreeArray(aDados)

Return

/*/{Protheus.doc} GetSaldo
Recupera os saldos de determinado produto e local

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param cFilTab , Character, Código da filial.
@param cProduto, Character, Código do produto.
@param cLocal  , Character, Código do local.
@param lRet    , Logico   , Retorna por referência se houve erro ao recuperar os dados.
@return aSaldos, Array  , Array com os saldos dos produtos - [1] Saldo Previsto [2] Empenho Previsto.
/*/
METHOD GetSaldo(cFilTab, cProduto, cLocal, lRet) CLASS ExclusaoPrevistos
	Local aSaldos   := {}
	Local cChaveSld := cFilTab + cProduto + cLocal + CHR(13) + "SLD"

	//Recupera a tabela de saldos do produto
	lRet := VarGetAD(Self:cUIDSld, cChaveSld, @aSaldos )
Return aSaldos

/*/{Protheus.doc} GetLoteSaldo
Recupera os saldos de determinado produto,local,lote e sublote.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param cFilTab , Character, Código da filial.
@param cProduto, Character, Código do produto.
@param cLocal  , Character, Código do local.
@param cLoteCtl, Character, Código do lote.
@param cNumlote, Character, Código do sublote.
@param lRet    , Logico   , Retorna por referência se houve erro ao recuperar os dados.
@return aSaldos, Array  , Array com os saldos dos produtos - [1] Saldo Previsto [2] Empenho Previsto.
/*/
METHOD GetLoteSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, lRet) CLASS ExclusaoPrevistos
	Local aSaldos   := {}
	Local cChaveLte := cFilTab + cProduto + cLocal + cLoteCtl + cNumLote + CHR(13) + "LTE"

	//Recupera a tabela de saldos do produto
	lRet := VarGetAD(Self:cUIDSldLte, cChaveLte, @aSaldos )
Return aSaldos

/*/{Protheus.doc} GetLocalizaSaldo
Recupera os saldos de determinado produto,local,lote,sublote e localização.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param cFilTab , Character, Código da filial.
@param cProduto, Character, Código do produto.
@param cLocal  , Character, Código do local.
@param cLoteCtl, Character, Código do lote.
@param cNumlote, Character, Código do sublote.
@param cLocaliz, Character, Código do endereço.
@param cNumSeri, Character, Código do número de série.
@param lRet    , Logico   , Retorna por referência se houve erro ao recuperar os dados.
@return aSaldos, Array  , Array com os saldos dos produtos - [1] Saldo Previsto [2] Empenho Previsto.
/*/
METHOD GetLocalizaSaldo(cFilTab, cProduto, cLocal, cLoteCtl, cNumLote, cLocaliz, cNumSeri, lRet) CLASS ExclusaoPrevistos
	Local aSaldos   := {}
	Local cChaveLcz := cFilTab + cProduto + cLocal + cLoteCtl + cNumLote + cLocaliz + cNumSeri + CHR(13) + "LCZ"

	//Recupera a tabela de saldos do produto
	lRet := VarGetAD(Self:cUIDSldLcz, cChaveLcz, @aSaldos )
Return aSaldos

/*/{Protheus.doc} PersisteSaldos
Grava os dados em memória nas tabelas SB2,SB8,SBF.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD PersisteSaldos() CLASS ExclusaoPrevistos
	Local lError    := .F.
	Local aDados    := {}
	Local nX        := 0
	Local cFilBkp   := cFilAnt
	Local cFilProc  := ""
	Local cProduto  := ""
	Local cLocal    := ""
	Local cLoteCtl  := ""
	Local cNumLote  := ""
	Local cLocaliz  := ""
	Local cNumSeri  := ""
	Local nTamFil   := GetSx3Cache("B1_FILIAL","X3_TAMANHO")
	Local nTamPrd   := GetSx3Cache("B1_COD","X3_TAMANHO")
	Local nTamLoc   := GetSx3Cache("B1_LOCPAD","X3_TAMANHO")
	Local nTamLot   := GetSx3Cache("D4_LOTECTL","X3_TAMANHO")
	Local nTamNLt   := GetSx3Cache("D4_NUMLOTE","X3_TAMANHO")
	Local nTamLcz   := GetSx3Cache("DC_LOCALIZ","X3_TAMANHO")
	Local nTamNSr   := GetSx3Cache("DC_NUMSERI","X3_TAMANHO")
	Local nQtEmp    := 0
	Local nQtSal    := 0
	Local nQtdSegUM := 0
	Local nTotDados := 0

	lError  := !VarGetAA( Self:cUIDSld, @aDados)
	If !lError
		nTotDados := Len(aDados)
	Else
		nTotDados := 0
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0022) //"Erro ao persistir saldo na tabela SB2"
	EndIf

	For nX := 1 To nTotDados
		cFilProc := SubStr(aDados[nX][1],1,nTamFil)
		cProduto := SubStr(aDados[nX][1],nTamFil+1,nTamPrd)
		cLocal   := SubStr(aDados[nX][1],nTamFil+nTamPrd+1,nTamLoc)
		nQtSal   := aDados[nX][2][1]
		nQtEmp   := aDados[nX][2][2]

		cFilAnt := cFilProc

		dbSelectArea("SB2")
		dbSetOrder(1)
		If !dbSeek(xFilial("SB2")+cProduto+cLocal)
			CriaSB2(cProduto,cLocal)
			SB2->(MsUnlock())
		EndIf

		If nQtSal > 0
			nQtdSegUM := Self:ConverteUM(cFilProc, cProduto, nQtSal)
			GravaB2Pre("-", nQtSal, "P", nQtdSegUM, .T.)
		EndIf

		If nQtEmp > 0
			nQtdSegUM := Self:ConverteUM(cFilProc, cProduto, nQtEmp)
			GravaB2Emp("-", nQtEmp, "P", .F., nQtdSegUM)
		EndIf
	Next nX

	aDados := aSize(aDados,0)
	lError := !VarGetAA( Self:cUIDSldLte, @aDados)
	If !lError
		nTotDados := Len(aDados)
	Else
		nTotDados := 0
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0023) //"Erro ao persistir saldo na tabela SB8"
	EndIf

	For nX := 1 To nTotDados
		cFilProc := SubStr(aDados[nX][1],1,nTamFil)
		cProduto := SubStr(aDados[nX][1],nTamFil+1,nTamPrd)
		cLocal   := SubStr(aDados[nX][1],nTamFil+nTamPrd+1,nTamLoc)
		cLoteCtl := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+1,nTamLot)
		cNumLote := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+nTamLot+1,nTamNLt)
		nQtEmp   := aDados[nX][2][2]

		cFilAnt := cFilProc

		dbSelectArea("SB8")
		dbSetOrder(2)
		If dbSeek(xFilial("SB8")+cNumLote+cLoteCtl+cProduto+cLocal)
			nQtdSegUM := Self:ConverteUM(cFilProc, cProduto, nQtEmp)
			GravaB8Emp("-",nQtEmp,"P",.F.,nQtdSegUM)
		EndIf
	Next nX

	aDados := aSize(aDados,0)
	lError := !VarGetAA( Self:cUIDSldLcz, @aDados)
	If !lError
		nTotDados := Len(aDados)
	Else
		nTotDados := 0
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0024) //"Erro ao persistir saldo na tabela SBF"
	EndIf

	For nX := 1 To Len(aDados)
		cFilProc := SubStr(aDados[nX][1],1,nTamFil)
		cProduto := SubStr(aDados[nX][1],nTamFil+1,nTamPrd)
		cLocal   := SubStr(aDados[nX][1],nTamFil+nTamPrd+1,nTamLoc)
		cLoteCtl := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+1,nTamLot)
		cNumLote := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+nTamLot+1,nTamNLt)
		cLocaliz := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+nTamLot+nTamNLt+1,nTamLcz)
		cNumSeri := SubStr(aDados[nX][1],nTamFil+nTamPrd+nTamLoc+nTamLot+nTamNLt+nTamLcz+1,nTamNSr)
		nQtEmp   := aDados[nX][2][2]

		cFilAnt := cFilProc

		dbSelectArea("SBF")
		dbSetOrder(1)
		If dbSeek(xFilial("SBF")+cLocal+cLocaliz+cProduto+cNumSeri+cLoteCtl+cNumLote)
			nQtdSegUM := Self:ConverteUM(cFilProc, cProduto, nQtEmp)
			GravaBFEmp("-",nQtEmp,"P",.F.,nQtdSegUM)
		EndIf
	Next nX

	cFilAnt := cFilBkp

	aDados := FwFreeArray(aDados)

Return

/*/{Protheus.doc} AtualizaStatus
Atualiza a variável de memória com o progresso do processamento.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD AtualizaStatus() CLASS ExclusaoPrevistos
	Local cStatus   := "PREVSTATUS"
	Local nProgress := 0
	Local lRet      := .T.
	VarBeginT(Self:cUIDStatus,cStatus)
	lRet := VarGetXD(Self:cUIDStatus,cStatus,@nProgress)
	If lRet
		nProgress += Iif(Self:lReproc, 5, 20)
	Else
		nProgress := 20
	EndIf
	lRet := VarSetXD(Self:cUIDStatus,cStatus,nProgress)
	IF !lRet
		LogMsg("PCPA146", 0, 0, 1, "", "", STR0025) //"Erro ao atualizar a variável global de status da exclusão de documentos previstos."
	EndIf
	VarEndT(Self:cUIDStatus,cStatus)
Return

/*/{Protheus.doc} GetStatus
Busca o progresso do processamento.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
@param lError, Logico, Retorna por referência se houve erro no processamento.
@return nProgress, Numeric, Progresso do processamento.
/*/
METHOD GetStatus(lError) CLASS ExclusaoPrevistos
	Local cStatus   := "PREVSTATUS"
	Local lRet      := .T.
	Local nProgress := 0
	Local cAux      := Nil

	lRet := VarGetXD(Self:cUIDStatus,cStatus,@nProgress)
	If !lRet
		nProgress := 0
	EndIf

	lError := .F.
	lRet   := VarGetXD(Self:cUIDStatus, "PREVERROR", @cAux)
	If lRet
		lError := cAux == "E"
	EndIf

Return nProgress

/*/{Protheus.doc} LimpaVarStatus
Limpa variável de memória que guarda o progresso do processamento.

@type  Method
@author renan.roeder
@since 02/12/2019
@version P12.1.27
/*/
METHOD LimpaVarStatus() CLASS ExclusaoPrevistos
	VarClean(Self:cUIDStatus)
Return

/*/{Protheus.doc} A146ExcOPs
Função para chamada do método de exclusão de OPs
@author renan.roeder
@since 02/12/2019
@version P12
@param 01 - cTicket, character, Ticket do processamento
/*/
Function A146ExcOPs(cTicket)
	Local nIniTime := MicroSeconds()

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Inicio da exclusão das ordens de produção."}, .F., .F., .T.)

	oExcPrevistos:ExcluiOrdensProducao()
	oExcPrevistos:AtualizaStatus()

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Fim da exclusão das ordens de produção. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

Return

/*/{Protheus.doc} A146ExcSCs
Função para chamada do método de exclusão de SCs
@author renan.roeder
@since 02/12/2019
@version P12
@param 01 - cTicket, character, Ticket do processamento
/*/
Function A146ExcSCs(cTicket)
	Local nIniTime := MicroSeconds()

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Inicio da exclusão das solicitações de compra."}, .F., .F., .T.)

	oExcPrevistos:ExcluiSolicitacoesCompra()
	oExcPrevistos:AtualizaStatus()

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Fim da exclusão das solicitações de compra. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

Return

/*/{Protheus.doc} A146ExcPCs
Função para chamada do método de exclusão de PCs
@author renan.roeder
@since 02/12/2019
@version P12
@param 01 - cTicket, character, Ticket do processamento
/*/
Function A146ExcPCs(cTicket)
	Local nIniTime := MicroSeconds()

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
	EndIf

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Inicio da exclusão dos pedidos de compra."}, .F., .F., .T.)

	oExcPrevistos:ExcluiPedidosCompra()
	oExcPrevistos:AtualizaStatus()

	oExcPrevistos:oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Fim da exclusão dos pedidos de compra. Tempo total: " + cValToChar(MicroSeconds() - nIniTime)}, .F., .F., .T.)

Return

/*/{Protheus.doc} A146TabOP
Cria tabela com as numerações das ordens de produção que serão excluídas.

@type  Function
@author lucas.franca
@since 03/09/2020
@version P12
@param 01 cAcao     , Character, Ação que será executada (CREATE/DELETE)
@param 02 cTableName, Character, Nome da tabela que será criada.
@prama 03 lUsaTemp  , Logic    , Indica se usa a tabela Temporária ou Física
@param 04 cUIDStatus, Character, UID da seção de variáveis globais.
@param 05 lHoriFirme, Logic    , Indica se considera horizonte firme.
@param 06 dDataIni  , Date     , Data de processamento do MRP utilizada como referência (database)
@param 07 cTicket   , Character, Ticket do processamento
@return Nil
/*/
Function A146TabOP(cAcao, cTableName, lUsaTemp, cUIDStatus, lHoriFirme, dDataIni, cTicket)
	Local aEstru    := {}
	Local aFiliais  := {}
	Local cFilProc  := ""
	Local cQuery    := ""
	Local cSelect   := ""
	Local cWhereIN  := ""
	Local cAlias    := ""
	Local nIndFil   := 1
	Local nLenAFils := 0
	Local nQtdInsert := 0
	Local nIniQry   := 0
	Local oLogs     := MrpDados_Logs():New()
	Default lAutoMacao := .F.

	If lUsaTemp
		If TcCanOpen(cTableName)
			TcDelFile(cTableName)
		EndIf
	Else
		If Empty(xFilial("SMD"))
			cWhereIN := "' '"
		Else
			If oExcPrevistos == Nil
				oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
			EndIf

			aFiliais  := oExcPrevistos:RetornaFiliais()
			nLenAFils := Len(aFiliais)
			cWhereIN  := "'" + xFilial("SMD", aFiliais[1]) + "'"
			For nIndFil := 2 To nLenAFils
				cWhereIN += ",'" + xFilial("SMD", aFiliais[nIndFil]) + "'"
			Next nIndFil
		EndIf

		//Limpa os registros da tabela auxiliar
		cQuery := "DELETE FROM " + cTableName
		cQuery += " WHERE MD_FILIAL IN (" + cWhereIN + ")"

		If cAcao == "CREATE"
			cQuery += " AND EXISTS (SELECT 1"
			cQuery +=               " FROM " + RetSqlName("SC2") + " SC2"
			cQuery +=              " WHERE " + PCPQrySC2("SC2", "MD_OP") 
			cQuery +=                " AND SC2.D_E_L_E_T_ = ' ')"
		EndIf

		If !lAutoMacao
			If TcSqlExec(cQuery) < 0
				Final(STR0026 + " '" + cTableName + "'" , TcSqlError()) //"Erro ao apagar os dados na tabela de ordens de produção.
				VarSetXD(cUIDStatus, "statusTabOP", -1)
			EndIf
		EndIf

		cWhereIN := ""
	EndIf

	If cAcao == "CREATE"
		//Cria a tabela
		If lUsaTemp
			aAdd(aEstru, {"MD_FILIAL", "C", GetSx3Cache("D4_FILIAL", "X3_TAMANHO"), 0})
			aAdd(aEstru, {"MD_OP"    , "C", GetSx3Cache("D4_OP", "X3_TAMANHO"), 0})
			aAdd(aEstru, {"MD_REC"   , "N", 12, 0})
			FwdbCreate(cTableName, aEstru, "TOPCONN", .T.)

			//Cria índice
			dbUseArea(.T., "TOPCONN",cTableName,cTableName, .T., .F.)
			DBCreateIndex(cTableName+"1","MD_FILIAL+MD_OP")
			DBCreateIndex(cTableName+"2","STR(MD_REC)")
			DBClearIndex()
			DBCloseArea()
		EndIf

		If oExcPrevistos == Nil
			oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
			aFiliais  := oExcPrevistos:RetornaFiliais()
		EndIf

		nLenAFils := Len(aFiliais)
		For nIndFil := 1 To nLenAFils
			cFilProc := aFiliais[nIndFil]

			cSelect := " SELECT SC2.C2_FILIAL, " + getC2OP() + ", SC2.R_E_C_N_O_ "
			cSelect +=   " FROM " + RetSqlName("SC2") + " SC2 "
			cSelect +=  " WHERE " + A146FilSC2(cFilProc, dDataIni, lHoriFirme, cTicket)

			If oLogs:logAtivado()
				cAlias := GetNextAlias()

				cQuery := " SELECT COUNT(1) total "
				cQuery +=   " FROM (" + cSelect + ") dadosInsert "

				dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .T., .T.)

				If (cAlias)->(!Eof())
					nQtdInsert := (cAlias)->total
				EndIf
				(cAlias)->(dbCloseArea())
			EndIf

			//Monta o comando de inclusão na tabela
			cQuery := " INSERT INTO " + cTableName + " (MD_FILIAL, MD_OP, MD_REC) "
			cQuery += cSelect

			oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Query insert tabela SMD (Filial " + cFilProc + " ): " + cQuery}, .F., .F., .T.)
			oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Quantidade de registros inseridos na tabela SMD (Filial " + cFilProc + " ): " + cValToChar(nQtdInsert) + " registros."}, .F., .F., .T.)

			If !lAutoMacao
				nIniQry := MicroSeconds()

				If TcSqlExec(cQuery) < 0
					Final(STR0027 + " " + cFilProc + ". '" + cTableName + "'" , TcSqlError()) //"Erro ao criar os dados na tabela de ordens de produção da filial"
					VarSetXD(cUIDStatus, "statusTabOP", -1)
					Exit
				Else
					VarSetXD(cUIDStatus, "statusTabOP", 1)
				EndIf

				oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Tempo insert tabela SMD (Filial " + cFilProc + " ): " + cValToChar(MicroSeconds() - nIniQry)}, .F., .F., .T.)
			EndIf
		Next nIndFil
	EndIf

	aEstru := FwFreeArray(aEstru)
	aFiliais := FwFreeArray(aFiliais)

Return Nil

/*/{Protheus.doc} getWhereC2
Monta a condição WHERE padrão da tabela SC2

@type  Static Function
@author lucas.franca
@since 18/02/2020
@version P12.1.30
@param 01 lNoAlias, Logic    , Identifica que não deve adicionar o alias "SC2" antes das colunas
@param 02 cDeleted, Character, Filtro de registros deletados
@param 03 cFilProc, Character, Filial de processamento
@return cWhere , Character, Retorna o where padrão da SC2
/*/
Static Function getWhereC2(lNoAlias, cDeleted, cFilProc)
	Local cWhere := ""

	cWhere :=     " SC2.C2_FILIAL = '" + xFilial("SC2", cFilProc) + "'"
	cWhere += " AND SC2.C2_TPOP   = 'P' "
	cWhere += " AND SC2.D_E_L_E_T_ = '" + cDeleted + "' "

	If SuperGetMV("MV_MRPDEL",.F.,.F.)
		cWhere += " AND SC2.C2_SEQMRP <> '" + CriaVar("C2_SEQMRP") + "'"
	EndIf

	If lNoAlias
		cWhere := StrTran(cWhere, "SC2.", " ")
	EndIf

Return cWhere

/*/{Protheus.doc} getC2OP
Monta o SQL retornando o código da OP, podendo ser
C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD ou o C2_OP.

@type  Static Function
@author lucas.franca
@since 20/02/2020
@version P12.1.30
@return cQryC2OP, Character, Query montando o retorno do campo C2_OP
/*/
Static Function getC2OP()
	Local cQryC2OP := ""

	cQryC2OP := " CASE SC2.C2_OP "
	cQryC2OP +=      " WHEN ' ' THEN "
	If "MSSQL" $ TCGetDB()
		cQryC2OP +=       " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD "
	Else
		cQryC2OP +=       " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	EndIf
	cQryC2OP +=      " ELSE "
	cQryC2OP +=           " SC2.C2_OP "
	cQryC2OP +=      " END as C2_OP"

Return cQryC2OP

/*/{Protheus.doc} CargaFiliaisProcessamento
Carrega a variável global com as filiais a serem processadas

@type Method
@author marcelo.neumann
@since 03/11/2020
@version P12.1.27
@param cFiliais, Character, Filiais centralizadas a serem consideradas na exclusão (parâmetro "centralizedBranches")
/*/
METHOD CargaFiliaisProcessamento(cFiliais) CLASS ExclusaoPrevistos

	Local aFiliais := {}
	Local lRet     := .T.

	If !Empty(cFiliais)
		aFiliais := StrTokArr(cFiliais, "|")
	EndIf

	aAdd(aFiliais, cFilAnt)

	lRet := VarSetAD(Self:cUIDFils, GLB_CHAVE_FILIAIS, aFiliais)

	aFiliais := FwFreeArray(aFiliais)

Return lRet

/*/{Protheus.doc} RetornaFiliais
Retorna as filiais do processamento

@type Method
@author marcelo.neumann
@since 03/11/2020
@version P12.1.27
@return aFiliais, Array, Filiais do processamento do MRP
/*/
METHOD RetornaFiliais() CLASS ExclusaoPrevistos

	Local aFiliais := {}
	Local lRet     := .T.

	lRet := VarGetAD(Self:cUIDFils, GLB_CHAVE_FILIAIS, @aFiliais)
	If !lRet
		aSize(aFiliais, 0)
	EndIf

Return aFiliais

/*/{Protheus.doc} scriptInHorizonteFirme
Monta a condição SQL para filtro dos documentos que estão dentro do horizonte firme do produto

@type Method
@author lucas.franca
@since 13/10/2021
@version P12
@param 01 cScript   , Character, Script para comando SQL IN com a condição de filtro (referência)
@param 02 cFilProc  , Character, Código da filial em processamento
@param 03 cTabela   , Character, Tabela de documento a ser avaliada
@param 04 cCpoProd  , Character, Campo que define o código do produto na tabela de documento
@param 05 cCpoData  , Character, Campo que define a data do documento
@param 06 cWhereComp, Character, Condição where complementar que será adicionado no comando IN
@param 07 dDataIni  , Date     , Data inicial considerada pelo MRP
@return cScript, Character, Condição SQL para filtro de documentos dentro do horizonte firme do produto
/*/
METHOD scriptInHorizonteFirme(cScript, cFilProc, cTabela, cCpoProd, cCpoData, cWhereComp, dDataIni) CLASS ExclusaoPrevistos
	Local cAlias     := cTabela + "_1"
	Local cBanco     := TCGetDB()
	Local cDataIni   := DtoS(dDataIni)

	Default cScript := ""

	cScript += " SELECT " + cAlias + ".R_E_C_N_O_ RECNO "
	cScript +=   " FROM " + RetSqlName(cTabela) + " " + cAlias
	If Self:lUsaSBZ
		cScript += " LEFT OUTER JOIN " + RetSqlName("SVK") + " SVK "
	Else
		cScript += " INNER JOIN " + RetSqlName("SVK") + " SVK "
	EndIf
	cScript +=     " ON SVK.VK_FILIAL  = '" + xFilial("SVK", cFilProc) + "' "
	cScript +=    " AND SVK.VK_COD     = " + cAlias + "." + cCpoProd
	cScript +=    " AND SVK.D_E_L_E_T_ = ' ' "

	If Self:lUsaSBZ //Adiciona JOIN com a tabela SBZ se necessário
		cScript += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ "
		cScript +=   " ON SBZ.BZ_FILIAL  = '"+ xFilial("SBZ", cFilProc) + "'"
		cScript +=  " AND SBZ.BZ_COD     = " + cAlias + "." + cCpoProd
		cScript +=  " AND SBZ.D_E_L_E_T_ = ' '"
		cScript +=" WHERE ( (SBZ.BZ_COD IS NOT NULL "
		cScript +=      " AND COALESCE(SBZ.BZ_TPHOFIX, ' ') <> ' ' "
		cScript +=      " AND COALESCE(SBZ.BZ_HORFIX, 0) > 0) "
		cScript +=       " OR (SBZ.BZ_COD IS NULL "
		cScript +=      " AND SVK.VK_COD IS NOT NULL "
		cScript +=      " AND COALESCE(SVK.VK_TPHOFIX, ' ') <> ' ' "
		cScript +=      " AND COALESCE(SVK.VK_HORFIX, 0) > 0) "
		cScript +=        " ) AND " //Somente produtos que possuem o parâmetro de horizonte firme configurado
	Else
		cScript += " WHERE COALESCE(SVK.VK_TPHOFIX, ' ') <> ' ' "
		cScript +=    " AND COALESCE(SVK.VK_HORFIX, 0) > 0 AND "
	EndIf

	If !Empty(cWhereComp)
		cWhereComp := StrTran(cWhereComp, " D_E_L_E_T_", " " + cAlias + ".D_E_L_E_T_") + " AND "
		cScript    += StrTran(cWhereComp, cTabela + ".", cAlias + ".")
	EndIf

	If cBanco == "ORACLE"
		cScript += "("
		cScript += "TO_DATE(" + cAlias + "." + cCpoData + ", 'YYYYMMDD') <= "
		cScript += "(CASE WHEN [SVK.VK_TPHOFIX] = '1' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [SVK.VK_HORFIX]) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '2' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([SVK.VK_HORFIX] * 7 ) ) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '3' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([SVK.VK_HORFIX] * 30) ) "
		cScript +=      " ELSE (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + ([SVK.VK_HORFIX] * 365) ) "
		cScript += " END) "
		cScript += ")"

	ElseIf cBanco == "POSTGRES"
		cScript += "("
		cScript += "TO_DATE(" + cAlias + "." + cCpoData + ", 'YYYYMMDD') <= "
		cScript += "(CASE WHEN [SVK.VK_TPHOFIX] = '1' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [SVK.VK_HORFIX] * interval'1 days' ) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '2' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [SVK.VK_HORFIX] * interval'1 weeks' ) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '3' THEN (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [SVK.VK_HORFIX] * interval'1 months' ) "
		cScript +=      " ELSE (TO_DATE('" + cDataIni + "', 'YYYYMMDD') + [SVK.VK_HORFIX] * interval'1 years' ) "
		cScript += " END) "
		cScript += ")"

	Else
		cScript += "("
		cScript += "CONVERT(DATETIME, " + cAlias + "." + cCpoData + ") <= "
		cScript += "(CASE WHEN [SVK.VK_TPHOFIX] = '1' THEN (CONVERT(DATETIME, '" + cDataIni + "') + [SVK.VK_HORFIX]) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '2' THEN (CONVERT(DATETIME, '" + cDataIni + "') + ([SVK.VK_HORFIX] * 7 ) ) "
		cScript +=      " WHEN [SVK.VK_TPHOFIX] = '3' THEN (CONVERT(DATETIME, '" + cDataIni + "') + ([SVK.VK_HORFIX] * 30) ) "
		cScript +=      " ELSE (CONVERT(DATETIME, '" + cDataIni + "') + ([SVK.VK_HORFIX] * 365) ) "
		cScript += " END) "
		cScript += ")"

	EndIf

	//Ajusta os comandos [SVK.VK_TPHOFIX] e [SVK.VK_HORFIX] de acordo com o parâmetro da tabela SBZ
	If Self:lUsaSBZ
		//Substitui [SVK.VK_HORFIX]  por COALESCE(SBZ.BZ_HORFIX,SVK.VK_HORFIX)
		//Substitui [SVK.VK_TPHOFIX] por COALESCE(SBZ.BZ_TPHOFIX,SVK.VK_TPHOFIX)
		cScript := StrTran(cScript, "[SVK.VK_HORFIX]" , "COALESCE(SBZ.BZ_HORFIX,SVK.VK_HORFIX)"  )
		cScript := StrTran(cScript, "[SVK.VK_TPHOFIX]", "COALESCE(SBZ.BZ_TPHOFIX,SVK.VK_TPHOFIX)")
	Else
		//Substitui [SVK.VK_HORFIX]  por SVK.VK_HORFIX
		//Substitui [SVK.VK_TPHOFIX] por SVK.VK_TPHOFIX
		cScript := StrTran(cScript, "[SVK.VK_HORFIX]" , "SVK.VK_HORFIX" )
		cScript := StrTran(cScript, "[SVK.VK_TPHOFIX]", "SVK.VK_TPHOFIX")
	EndIf

Return cScript

/*/{Protheus.doc} excluiSMH
Executa a exclusão da tabela SMH

@type Method
@author marcelo.neumann
@since 07/12/2020
@version P12.1.27
@param cFilAux   , Character, Código da filial
@param cTipo     , Character, Identifica a origem dos dados
@param cWherExist, Character, Where Clause que será utilizado na cláusula EXISTS.
@param cUIDStatus, Character, ID status.
@return lOk, Logical, Indica se efetuou a exclusão
/*/
Static Function excluiSMH(cFilAux, cTipo, cWherExist, cUIDStatus)
	Local cBanco  := TCGetDB()
	Local cUpdDel := ""
	Local lOk     := .T.

	If !FwAliasInDic("SMH", .F.)
		Return lOk
	EndIf

	cUpdDel := "UPDATE " + RetSqlName("SMH")                             + ;
	             " SET D_E_L_E_T_   = '*',"                              + ;
	                 " R_E_C_D_E_L_ = R_E_C_N_O_"                        + ;
	           " WHERE MH_FILIAL    = '" + xFilial("SMH", cFilAux) + "'" + ;
	             " AND D_E_L_E_T_   = ' '"

	If cTipo == "SC"
		cUpdDel += " AND MH_TPDCENT = '2'"                             + ;
		           " AND EXISTS (SELECT 1"                             + ;
		                         " FROM " + RetSqlName("SC1") + " SC1" + ;
		                        " WHERE SC1.C1_NUM || SC1.C1_ITEM = MH_NMDCENT "

		If !Empty(cWherExist)
			cUpdDel += " AND " + cWherExist
		EndIf
		cUpdDel += ")"

	ElseIf cTipo == "PC"
		cUpdDel += " AND MH_TPDCENT = '3'"                             + ;
		           " AND EXISTS (SELECT 1"                             + ;
		                         " FROM " + RetSqlName("SC7") + " SC7" + ;
		                        " WHERE SC7.C7_NUM || SC7.C7_ITEM = MH_NMDCENT "

		If !Empty(cWherExist)
			cUpdDel += " AND " + cWherExist
		EndIf
		cUpdDel += ")"

	ElseIf cTipo == "OP"
		cUpdDel += " AND MH_TPDCENT = '1'" + ;
		           " AND " + cWherExist
	EndIf

	//Realiza ajustes da Query para cada banco
	If "MSSQL" $ cBanco
		cUpdDel := StrTran(cUpdDel, "||", "+")
	EndIf

	VarBeginT(cUIDStatus, 'EXCL_SMH_LOCK')
	If TcSqlExec(cUpdDel) < 0
		Final(STR0028 + " " + cFilAux + ".", TcSqlError()) //"Erro ao excluir os registros de Rastreabilidade da filial
		lOk := .F.
	EndIf

	//Elimina o lixo que possa ter ficado
	cUpdDel := "UPDATE " + RetSqlName("SMH")                                 + ;
	             " SET D_E_L_E_T_   = '*',"                                  + ;
	                 " R_E_C_D_E_L_ = R_E_C_N_O_"                            + ;
	           " WHERE MH_FILIAL    = '" + xFilial("SMH", cFilAux) + "'"     + ;
	             " AND D_E_L_E_T_   = ' '"                                   + ;
	             " AND MH_TPDCENT   IN ('0','P','E')"                        + ;
	             " AND NOT EXISTS (SELECT 1"                                 + ;
	                               " FROM " + RetSqlName("SMH") + " SMH_EXC" + ;
	                              " WHERE SMH_EXC.MH_FILIAL  = MH_FILIAL"    + ;
	                                " AND SMH_EXC.D_E_L_E_T_ = ' '"          + ;
	                                " AND SMH_EXC.MH_NMDCSAI = MH_NMDCENT)"

	If TcSqlExec(cUpdDel) < 0
		Final(STR0029 + " " + cFilAux + ".", TcSqlError()) //"Erro ao excluir os registros de Rastreabilidade (Ponto de Pedido/Estoque de segurança) da filial"
		lOk := .F.
	EndIf
	VarEndT(cUIDStatus, 'EXCL_SMH_LOCK')

Return lOk

/*{Protheus.doc} A146DelTr
Apaga registros de transferencias com origem no MRP e que não foram efetivados

@type  Function
@author douglas.heydt
@since 03/02/2021
@version P12.1.31
@param 01 cTicket, Character, Número do ticket do MRP.
@return Nil
/*/
Function A146DelTr(cTicket)
	Local aArea      := GetArea()
	Local aFiliais   := {}
	Local cAliasQry  := GetNextAlias()
	Local cDbType    := TCGetDB()
	Local cUpdDel    := ""
	Local nIndFil    := 0
	Local oModelNNS  := Nil

	//MATA311 usa essas variáveis
	Private INCLUI := .F.
	Private ALTERA := .F.

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket,.F.)
    EndIf
	aFiliais  := oExcPrevistos:RetornaFiliais()

	nLenAFils := Len(aFiliais)

	dbSelectArea("NNS")
	dbSelectArea("NNT")

	For nIndFil := 1 To nLenAFils
		cFilProc := aFiliais[nIndFil]

		If nIndFil > 1
			cUpdDel += " UNION "
		EndIf

		cUpdDel += "SELECT NNS.R_E_C_N_O_ RECNNS,"
		cUpdDel +=       " NNT.R_E_C_N_O_ RECNNT"
		cUpdDel +=  " FROM " + RetSqlName("NNS") + " NNS, "
		cUpdDel +=             RetSqlName("NNT") + " NNT"
		cUpdDel += " WHERE NNS.NNS_FILIAL = '" + xFilial("NNS", cFilProc) + "'"
		cUpdDel +=   " AND NNS.NNS_STATUS = '1'"
		cUpdDel +=   " AND NNS.D_E_L_E_T_ = ' '"
		cUpdDel +=   " AND NNT.NNT_FILIAL = '" + xFilial("NNT", cFilProc) + "'"
		cUpdDel +=   " AND NNT.NNT_COD    = NNS.NNS_COD"
		cUpdDel +=   " AND NNT.D_E_L_E_T_ = ' '"

		If cDbType $ "DB2|POSTGRES|ORACLE|INFORMIX"
			cUpdDel += " AND SUBSTR(NNT.NNT_OBS, 1, 3) = 'MRP'"
     	Else
			cUpdDel += " AND SUBSTRING(NNT.NNT_OBS, 1, 3) = 'MRP'"
		EndIf
	Next nIndFil

	cUpdDel := ChangeQuery(cUpdDel)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cUpdDel),cAliasQry,.T.,.T.)

	While !(cAliasQry)->(Eof())
		NNS->(dbGoTo((cAliasQry)->(RECNNS)))
		NNT->(dbGoTo((cAliasQry)->(RECNNT)))

		cFilAnt := NNT->NNT_FILORI

		oModelNNS := FWLoadModel('MATA311')
		updIniPad(oModelNNS)
		oModelNNS:SetOperation(5)
		oModelNNS:Activate()

		If oModelNNS:VldData()
			oModelNNS:CommitData()
		Else
			LogMsg("PCPA146", 0, 0, 1, "", "", oModelNNS:GetErrorMsgText())
		Endif
		oModelNNS:DeActivate()

		(cAliasQry)->(dbSkip())
	EndDo

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)
	FwFreeArray(aFiliais)
	aSize(aArea, 0)

Return Nil

/*/{Protheus.doc} updIniPad
Atualiza o inicializador padrão do campo virtual "V_EXEC_MRP" para considerar a execução do processo pelo MRP.

@type  Static Function
@author lucas.franca
@since 28/04/2023
@version P12
@param oModel, Object, Objeto do modelo de dados do MATA311
@return Nil, return_type, return_description
/*/
Static Function updIniPad(oModel)
	Local aStruct := oModel:GetModelStruct("NNTDETAIL")

	If !Empty(aStruct) .And. !Empty(aStruct[3]) .And. aStruct[3]:oFormModelStruct != Nil
		aStruct[3]:oFormModelStruct:SetProperty("V_EXEC_MRP", MODEL_FIELD_INIT, FWBuildFeature(STRUCT_FEATURE_INIPAD, "1"))
		aStruct := Nil
	EndIf
Return Nil

/*{Protheus.doc} IntegraOP
Integra a OP antes de excluir

@type Static Function
@author marcelo.neumann
@since 07/06/2021
@version P12
@param oSelf, Object, Instância da classe ExclusaoPrevistos
@return Nil
/*/
Static Function IntegraOP(oSelf)
	Local cAliasQry  := GetNextAlias()
	Local cQuery     := ""
	Private cIntgPPI := "1"

	//Integração com o MES (PPI)
	If PCPIntgPPI()
		SetFunName("PCPA146")
		cIntgPPI := PCPIntgMRP()
		If cIntgPPI <> "1"
			PutGlbValue(oSelf:cTicket + "STATUS_MES_EXCLUSAO", "INI")

			cQuery := "SELECT MD_REC FROM " + oSelf:cNameTabOP

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
			While !(cAliasQry)->(Eof())
				SC2->(dbGoTo((cAliasQry)->MD_REC))

				PCPa650PPI(/*cXml*/, /*cOp*/, .T., .T., .T., /*lFiltra*/)

				(cAliasQry)->(dbSkip())
			EndDo
			(cAliasQry)->(dbCloseArea())

			PutGlbValue(oSelf:cTicket + "STATUS_MES_EXCLUSAO", "FIM")
		EndIf
	EndIf
Return

/*/{Protheus.doc} A146ExVen
Atualiza as informações das OPs Previstas geradas por Vendas
@type Function
@author Michele Girardi
@since 22/11/2024
@param cNameTabOP, char, Nome da tabela de controle de OPs excluídas
/*/
Function A146ExVen(cNameTabOP)
	Local aRegsSC6    := {}
	Local cAlias      := GetNextAlias()
	Local cQuery      := ""
	Local lOpQuebrada := .F.
	Local nQtdAtuEmp  := 0
	Local nx          := 0

	cQuery := " SELECT TAB_OP.MD_FILIAL FILIAL,"
	cQuery +=        " TAB_OP.MD_OP     ORDEM,"
	cQuery +=        " SC2.C2_NUM       NUM_OP,"
	cQuery +=        " SC2.C2_ITEM      ITEM_OP, "
	cQuery +=        " SC2.C2_PRODUTO   PRODUTO, "
	cQuery +=        " SC2.R_E_C_N_O_   REC_SC2, "
	cQuery +=        " SC6.R_E_C_N_O_   REC_SC6 "
	cQuery +=   " FROM " + cNameTabOP + " TAB_OP, " + RetSqlName("SC2")+" SC2, " + RetSqlName("SC6")+" SC6 "
	cQuery +=  " WHERE SC2.C2_FILIAL  = '" + xFilial('SC2') + "' "
	cQuery +=    " AND SC2.R_E_C_N_O_ = TAB_OP.MD_REC "
	cQuery +=  "   AND SC6.C6_FILIAL  = '" + xFilial('SC6') + "' "
	cQuery +=  "   AND SC6.C6_NUMOP   = SC2.C2_NUM "
	cQuery +=  "   AND SC6.C6_ITEMOP  = SC2.C2_ITEM "
	cQuery += "    AND SC6.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	While !(cAlias)->(Eof())

		dbSelectArea("SC6")
		SC6->(MsGoto((cAlias)->REC_SC6))

		dbSelectArea("SC2")
		SC2->(MsGoto((cAlias)->REC_SC2))

		//Verifica se a ordem de produção foi quebrada para atender lote econômico
		lOpQuebrada := A146LtEcon((cAlias)->NUM_OP,(cAlias)->ITEM_OP,(cAlias)->PRODUTO)

		nQtdAtuEmp := 0
		If SC6->C6_OP $ "01#03#08"

			//Verifica se existe quebra da OP
			If !lOpQuebrada
				//Verifica se esse pedido já foi atualizado
				//Se existir é porque existe OP quebrada e todas OPs são previstas.
				//Neste caso as quantidades já foram atualizadas na primeira sequencia da OP
				If aScan(aRegsSC6, {|x| (cAlias)->REC_SC6 == x}) == 0
					AADD(aRegsSC6,(cAlias)->REC_SC6)
					nQtdAtuEmp += SC6->C6_QTDVEN
				EndIf
			Else
				nQtdAtuEmp += SC2->C2_QUANT
			EndIf
		EndIf

		//Atualiza a SB2
		If nQtdAtuEmp > 0
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			SB2->(dbSeek(xFilial("SB2")+SC2->C2_PRODUTO+SC2->C2_LOCAL))
			A650AtEmpn(nQtdAtuEmp,"-",SC2->C2_TPOP)
		EndIf

		(cAlias)->(dbSkip())
	End

	//Limpa número das OPs dos Pedidos de Venda
	For nx := 1 to Len(aRegsSC6)
		MAT650CDEL(aRegsSC6[nx])
	Next nx
Return

/*/{Protheus.doc} A146LtEcon
Valida se existe quebra da OP PAI por lote econômico
Mesmo numero de OP, mesmo produto com sequencias diferentes.
@author Michele Girardi
@since 25/11/2024
@param cNumOp, char, numero da op
@param cItemOp, char, item da op
@param cProduto, char, produto da op
@return lExiste, logical, se existe a quebra da op pai.
/*/
Static Function A146LtEcon(cNumOp, cItemOp, cProduto)
	Local aAliasSC2 := SC2->(GetArea())
	Local cQuery := GetNextAlias()
	Local lExiste := .F.

	BeginSql alias cQuery
    	SELECT
        	COUNT(SC2.C2_NUM) TOTAL
    	FROM
        	%table:SC2% SC2
    	WHERE
        	SC2.C2_FILIAL= %xfilial:SC2% AND
        	SC2.C2_NUM = %exp:cNumOp% AND
        	SC2.C2_ITEM = %exp:cItemOp% AND
			SC2.C2_PRODUTO = %exp:cProduto% AND
			SC2.C2_TPOP = 'F' AND
        	SC2.%notDel%
	EndSql

	//Se existir pelo menos uma op não deletada com o mesmo número, existe quebra.
	//É verificado se existe OP firme pq se todas forem previstas por mais que exista quebra serão excluídas todas OPs e atualizada a quantidade total.
	lExiste := .F.
	If (cQuery)->TOTAL > 0
		lExiste := .T.
	EndIf

	(cQuery)->(DbCloseArea())

	RestArea(aAliasSC2)

Return lExiste

/*/{Protheus.doc} validExc
Valida se realizou a exclusão de todos os documentos previstos.

@type  Static Function
@author Lucas Fagundes
@since 27/01/2025
@version P12
@param 01 cTicket , Caracter, Número do ticket do MRP.
@param 02 nQtdFalt, Caracter, Retorna por referencia a quantidade de documentos que faltam ser excluídos.
@return lExcluiu, Lógico, Indica se realizou a exclusão de todos os documentos previstos.
/*/
Static Function validExc(cTicket, nQtdFalt)
	Local aFiliais := {}
	Local cAlias   := GetNextAlias()
	Local cFilProc := ""
	Local cQuery   := ""
	Local cWhereIN := ""
	Local lExcluiu := .T.
	Local nIndFil  := 0
	Local nTotFil  := 0

	If oExcPrevistos == Nil
		oExcPrevistos := ExclusaoPrevistos():New(cTicket, .F.)
	EndIf
	aFiliais := oExcPrevistos:RetornaFiliais()
	nTotFil  := Len(aFiliais)

	For nIndFil := 1 To nTotFil
		cFilProc := aFiliais[nIndFil]

		cQuery := " SELECT COUNT(1) cont "
		cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
		cQuery +=  " WHERE " + A146FilSC2(cFilProc, oExcPrevistos:dDataIni, oExcPrevistos:lHoriFirme, cTicket)
		cQuery +=  " UNION ALL "
		cQuery += " SELECT COUNT(1) cont "
		cQuery +=   " FROM " + RetSqlName("SC1") + " SC1 "
		cQuery +=  " WHERE " + whereSC1(cFilProc, cTicket)
		cQuery +=  " UNION ALL "
		cQuery += " SELECT COUNT(1) cont "
		cQuery +=   " FROM " + RetSqlName("SC7") + " SC7 "
		cQuery +=  " WHERE " + whereSC7(cFilProc, cTicket)
		cQuery +=  " UNION ALL "
		cQuery += " SELECT COUNT(1) cont "
		cQuery +=   " FROM " + RetSqlName("SHC") + " SHC "
		cQuery +=  " WHERE SHC.HC_FILIAL = '" + xFilial("SHC", cFilProc) + "'"
		cQuery +=    " AND SHC.HC_OP IN (SELECT " + getC2OP()
		cQuery +=                        " FROM " + RetSqlName("SC2") + " SC2"
		cQuery +=                       " WHERE " + getWhereC2(.F., " ", cFilProc)
		If oExcPrevistos:lHoriFirme
			cWhereIN := ""
			oExcPrevistos:scriptInHorizonteFirme(@cWhereIN, cFilProc, "SC2", "C2_PRODUTO", "C2_DATPRF", getWhereC2(.T., " ", cFilProc), oExcPrevistos:dDataIni)
			cQuery += " AND R_E_C_N_O_ NOT IN (" + cWhereIN + ")"
		EndIf
		cQuery +=                    ")"
		cQuery +=    " AND D_E_L_E_T_ = ' ' "
		cQuery +=  " UNION ALL "
		cQuery += " SELECT COUNT(1) cont "
		cQuery +=   " FROM (SELECT NNS.R_E_C_N_O_ RECNNS,"
		cQuery +=                " NNT.R_E_C_N_O_ RECNNT"
		cQuery +=           " FROM " + RetSqlName("NNS") + " NNS, "
		cQuery +=                      RetSqlName("NNT") + " NNT"
		cQuery +=          " WHERE NNS.NNS_FILIAL = '" + xFilial("NNS", cFilProc) + "'"
		cQuery +=            " AND NNS.NNS_STATUS = '1'"
		cQuery +=            " AND NNS.D_E_L_E_T_ = ' '"
		cQuery +=            " AND NNT.NNT_FILIAL = '" + xFilial("NNT", cFilProc) + "'"
		cQuery +=            " AND NNT.NNT_COD    = NNS.NNS_COD"
		If TCGetDB() $ "DB2|POSTGRES|ORACLE|INFORMIX"
			cQuery +=        " AND SUBSTR(NNT.NNT_OBS, 1, 3) = 'MRP'"
     	Else
			cQuery +=        " AND SUBSTRING(NNT.NNT_OBS, 1, 3) = 'MRP'"
		EndIf
		cQuery +=            " AND NNT.D_E_L_E_T_ = ' ') conTransf "

		cQuery := " SELECT SUM(aux.cont) total FROM (" + cQuery + ") aux "

		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .F.)

		If (cAlias)->(!EoF())
			nQtdFalt += (cAlias)->total
		EndIf
		(cAlias)->(dbCloseArea())
	Next

	lExcluiu := nQtdFalt == 0

Return lExcluiu

/*/{Protheus.doc} finishProc
Finaliza o processo de exclusão de documentos previstos.

@type  Static Function
@author Lucas Fagundes
@since 27/01/2025
@version P12
@param cTicket, Caracter, Ticket do MRP.
@return Nil
/*/
Static Function finishProc(cTicket)
	Local cStatus    := "PREVSTATUS"
	Local cUIDStatus := "PREVSTATUS_" + cTicket
	Local lOkGet     := .T.
	Local nSecAux    := 0
	Local nSecTotal  := 0
	Local oStatus    := MrpDados_Status():New(cTicket)

	VarBeginT(cUIDStatus, cStatus)

	nSecAux := oStatus:getStatus("tempo_exlusao_previstos_fim", @lOkGet)
	If lOkGet
		nSecTotal := MicroSeconds() - nSecAux
	EndIf
	oStatus:setStatus("tempo_exlusao_previstos_fim", nSecTotal)

	lOkGet  := .T.
	nSecAux := oStatus:getStatus("tempo_exlusao_previstos_ini", @lOkGet)
	If lOkGet
		oStatus:setStatus("tempo_exlusao_previstos", nSecTotal + nSecAux)
	Else
		oStatus:setStatus("tempo_exlusao_previstos", nSecTotal)
	EndIf

	VarSetXD(cUIDStatus, cStatus, 100)

	VarEndT(cUIDStatus, cStatus)

	oStatus := FreeObj(oStatus)
	oStatus := Nil
Return Nil

/*/{Protheus.doc} reprocessa
Reprocessa o processo de exclusão de documentos previstos.

@type  Static Function
@author Lucas Fagundes
@since 27/01/2025
@version P12
@param 01 - cTicket   , character, Ticket do processamento
@param 02 - lHoriFirme, lógico   , indica se considera o horizonte firme do produto
@param 03 - dDataIni  , data     , data de processamento do MRP utilizada como referência (database)
@param 04 - cErrorUID , character, codigo identificador do controle de erros multi-thread
@param 05 - cFiliais  , character, filiais para fazer a exclusão (parâmetro "centralizedBranches")
@return Nil
/*/
Static Function reprocessa(cTicket, lHoriFirme, dDataIni, cErrorUID, cFiliais)
	Local nQtdDoc       := 0
	Local oExcPrevistos := Nil
	Local oLogs         := MrpDados_Logs():New()

	oExcPrevistos := ExclusaoPrevistos():New(cTicket, .T., lHoriFirme, dDataIni, cErrorUID, cFiliais, .T.)

	oExcPrevistos:Processar()

	lExcTudo := validExc(cTicket, @nQtdDoc)

	If !lExcTudo
		oLogs:gravaLog("exclusao_previstos", "PCPA146", {"Foi encontrado " + cValToChar(nQtdDoc) + " documentos previstos após o reprocessamento. Será cancelado o ticket do MRP."}, .F., .F., .T.)
		oExcPrevistos:setError()
	EndIf

	oExcPrevistos:Destroy()
	oExcPrevistos := FreeObj(oExcPrevistos)

	finishProc(cTicket)

Return Nil

/*/{Protheus.doc} setError
Seta variavel de controle de erro e cancela o ticket do MRP caso tenha finalizado.

@author Lucas Fagundes
@since 28/01/2025
@version P12
@return Nil
/*/
Method setError() Class ExclusaoPrevistos
	Local aReturn := {}
	Local oStatus := JsonObject():New()

	VarSetXD(Self:cUIDStatus, "PREVERROR", "E")

	aReturn := MrpGet(cFilAnt, Self:cTicket)
	oStatus:fromJson(aReturn[2])

	// Se já finalizou o ticket, atualiza para o status de cancelado
	If oStatus["status"] == "3"
		HW3->(dbSetOrder(1))
		If HW3->(dbSeek(xFilial("HW3")+Self:cTicket))
			RecLock("HW3", .F.)
				HW3->HW3_STATUS := "5"
			HW3->(MsUnlock())
		EndIf
	EndIf

Return Nil
