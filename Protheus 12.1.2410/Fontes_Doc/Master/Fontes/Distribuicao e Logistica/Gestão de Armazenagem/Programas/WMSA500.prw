#INCLUDE "WMSA500.CH"  
#INCLUDE "PROTHEUS.CH"

#DEFINE WMSA50001 "WMSA50001"
#DEFINE WMSA50002 "WMSA50002"
#DEFINE WMSA50003 "WMSA50003"
#DEFINE WMSA50004 "WMSA50004"
#DEFINE WMSA50005 "WMSA50005"
#DEFINE WMSA50006 "WMSA50006"
#DEFINE WMSA50007 "WMSA50007"
#DEFINE WMSA50008 "WMSA50008"
#DEFINE WMSA50009 "WMSA50009"
#DEFINE WMSA50010 "WMSA50010"
#DEFINE WMSA50011 "WMSA50011"
#DEFINE WMSA50012 "WMSA50012"
#DEFINE WMSA50013 "WMSA50013"

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} WMSA500
Separação de Requisições para o WMS

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA500()
Local aCoors := FWGetDialogSize(oMainWnd)
Local oFWLayerMAS
Local oPnlCapa , oPnlDetail
Local aColsSX3   := {}
Local lMarcar    := .F.
Local aColsSD4   := {}
Local aColsPRD   := {}
Local cAliasSD4  := 'WMSSD4'
Local cAliasProd := 'WMSPROD'

Private aCamposSD4  := {}
Private aCamposProd := {}
Private oDlgPrinc
Private oBrwSD4, oBrwPRD

	If SuperGetMV("MV_WMSNEW", .F., .F.)
		Return WMSA505()
	EndIf

	// Cria tabela temporária dos produtos acumulados e das requisições
	createTemp()

	// Pergunte
	If Pergunte('WMSA500',.T.)

		// Carrega os dados na tabela temporária de requisições
		CargaTemp()

		// Trata a altura da janela de acordo com a resolução
		DEFINE MSDIALOG oDlgPrinc TITLE STR0001 FROM aCoors[1], aCoors [2] To aCoors[3], aCoors[4] PIXEL STYLE NOr(WS_VISIBLE,WS_POPUP) // Requisições Empenhadas

		// Cria conteiner para os browses
		oFWLayerMAS := FWLayer():New()
		oFWLayerMAS:Init(oDlgPrinc, .F., .T.)

		// Define painel Master
		oFWLayerMAS:AddLine('UP',50, .T.)
		oPnlCapa := oFWLayerMAS:GetLinePanel('UP')

		// Campos adicionais
		aColsSD4:= {;
				{BuscarSX3('D4_OP',,aColsSX3)      ,{|| (cAliasSD4)->D4_OP}     ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Ordem de Producao
				{BuscarSX3('DCF_DOCTO',,aColsSX3)  ,{|| (cAliasSD4)->D4_DOCTO}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Documento WMS
				{BuscarSX3('D4_LOCAL',,aColsSX3)   ,{|| (cAliasSD4)->D4_LOCAL}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Armazem
				{BuscarSX3('D4_COD',,aColsSX3)     ,{|| (cAliasSD4)->D4_COD}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Produto
				{BuscarSX3('B1_DESC',,aColsSX3)    ,{|| (cAliasSD4)->D4_DESC}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Descricao Produto
				{BuscarSX3('D4_LOTECTL',,aColsSX3) ,{|| (cAliasSD4)->D4_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Lote
				{BuscarSX3('D4_NUMLOTE',,aColsSX3) ,{|| (cAliasSD4)->D4_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Sub-Lote
				{BuscarSX3('D4_DATA',,aColsSX3)    ,{|| (cAliasSD4)->D4_DATA}   ,'D',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Data Empenho
				{BuscarSX3('D4_QUANT',,aColsSX3)   ,{|| (cAliasSD4)->D4_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Quantidade Empenho
				{BuscarSX3('D4_QTSEGUM',,aColsSX3) ,{|| (cAliasSD4)->D4_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Quantidade 2 unidade Empenho
				{BuscarSX3('D4_TRT',,aColsSX3)     ,{|| (cAliasSD4)->D4_TRT}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Sequencia Estrutura
				{buscarSX3('D4_OPORIG',,aColsSX3)  ,{|| (cAliasSD4)->D4_OPORIG}	,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};  // Op Origem
				}		
		oBrwSD4 := FWMarkBrowse():New()
		oBrwSD4:SetDescription(STR0001) // Requisições Empenhadas
		oBrwSD4:SetAlias('WMSSD4') // Alias da tabela utilizada
		oBrwSD4:SetFields(aColsSD4)
		oBrwSD4:SetOwner(oPnlCapa)
		oBrwSD4:SetFieldMark('D4_MARK')
		oBrwSD4:SetAmbiente(.F.)
		oBrwSD4:SetWalkThru(.F.)
		oBrwSD4:SetAfterMark({|| AfterMark() }) // Função para o Check
		oBrwSD4:bAllMark := {|| SetMarkAll(oBrwSD4:Mark(),lMarcar := !lMarcar),oBrwSD4:Refresh(.T.)}
		oBrwSD4:SetMenuDef('WMSA500')
		oBrwSD4:ForceQuitButton(.T.)
		oBrwSD4:AddLegend("('WMSSD4')->D4_SITU == '1'",'RED'    ,STR0002) // Não Solicitadas
		oBrwSD4:AddLegend("('WMSSD4')->D4_SITU == '2'",'BLUE'   ,STR0003) // Não iniciadas
		oBrwSD4:AddLegend("('WMSSD4')->D4_SITU == '3'",'YELLOW' ,STR0004) // Em Andamento
		oBrwSD4:AddLegend("('WMSSD4')->D4_SITU == '4'",'GREEN'  ,STR0005) // Finalizadas
		oBrwSD4:DisableDetails()
		oBrwSD4:DisableFilter()
		oBrwSD4:oBrowse:SetFixedBrowse(.T.)
		oBrwSD4:AddButton(STR0006,{|| WMSA500MNU("1") },,5,0) // Estornar
		oBrwSD4:AddButton(STR0025,{|| Selecao() },,3,0) // Selecionar
		oBrwSD4:SetProfileID('1')

		// Define painel Detail
		oFWLayerMAS:AddLine('DOWN', 50, .T.)
		oPnlDetail := oFWLayerMAS:GetLinePanel('DOWN')

		// Campos adicionais
		aColsPRD:= {;
				{BuscarSX3('D4_COD',,aColsSX3)            ,{|| (cAliasProd)->D4_COD}    ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Codigo Produto
				{BuscarSX3('B1_DESC',,aColsSX3)           ,{|| (cAliasProd)->D4_DESC}   ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Descrição Produto
				{BuscarSX3('D4_LOTECTL',,aColsSX3)        ,{|| (cAliasProd)->D4_LOTECTL},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Lote
				{BuscarSX3('D4_NUMLOTE',,aColsSX3)        ,{|| (cAliasProd)->D4_NUMLOTE},'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Sub-lote
				{BuscarSX3('D4_QUANT',,aColsSX3)          ,{|| (cAliasProd)->D4_QUANT}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Qtdade sumarizada das requisições
				{BuscarSX3('D4_QTSEGUM',,aColsSX3)        ,{|| (cAliasProd)->D4_QTSEGUM},'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Qtdade da segunda unidade sumarizada
				{BuscarSX3('D4_QTDEORI',STR0007,aColsSX3) ,{|| (cAliasProd)->D4_SALDO}  ,'N',aColsSX3[2],2,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Saldo
				{BuscarSX3('B5_SERVREQ',,aColsSX3)        ,{|| (cAliasProd)->D4_SERVIC} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Servico
				{BuscarSX3('B5_ENDREQ',,aColsSX3)         ,{|| (cAliasProd)->D4_ENDREQ} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Endereço destino
				{BuscarSX3('BE_ESTFIS',,aColsSX3)         ,{|| (cAliasProd)->D4_ESTFIS} ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1},; // Estrutura Fisica
				{BuscarSX3('DCF_REGRA',,aColsSX3)         ,{|| (cAliasProd)->D4_REGRA}  ,'C',aColsSX3[2],1,aColsSX3[3],aColsSX3[4],.F.,,,,,,,,1};  // Regra WMS
		}

		oBrwPRD := FWMarkBrowse():New()
		oBrwPRD:SetAlias('WMSPROD')
		oBrwPRD:SetOwner(oPnlDetail)
		oBrwPRD:SetFields(aColsPRD)
		oBrwPRD:SetFieldMark('D4_MARK')
		oBrwPRD:bAllMark := {|| MarkAllPro(oBrwPRD:Mark(),lMarcar := !lMarcar), oBrwPRD:Refresh(.T.)}
		oBrwPRD:SetMenuDef('')
		oBrwPRD:SetWalkThru(.F.)
		oBrwPRD:SetAmbiente(.F.)
		oBrwPRD:oBrowse:SetFixedBrowse(.T.)
		oBrwPRD:SetDescription(STR0008) // Produtos Requisição
		oBrwPRD:AddButton(STR0015,{|| Alterar() },,4,0) // Alterar
		oBrwPRD:AddButton(STR0009,{|| WMSA500MNU("2") },,4,0) // Solicitar

		oBrwPRD:AddLegend("('WMSPROD')->D4_SALDO < ('WMSPROD')->D4_QUANT",'RED'   ,STR0010) // Sem Saldo
		oBrwPRD:AddLegend("('WMSPROD')->D4_SALDO >= ('WMSPROD')->D4_QUANT",'GREEN',STR0011) // Com Saldo

		oBrwSD4:Activate()
		oBrwPRD:Activate()

		Activate MsDialog oDlgPrinc Center

		delTabTmp('WMSSD4')
		delTabTmp('WMSPROD')
	EndIf
Return(Nil)
//-----------------------------------------------------------
// Menu
/*/{Protheus.doc} WMSA500MNU
Menu das requisições

@author  Felipe Machado de Oliveira
@version P12
@Since	23/05/14
@version 1.0
/*/
//-----------------------------------------------------------
Function WMSA500MNU(cAcao)
	If cAcao == "1" // Estornar
		Processa( {|| ProcRegua(100), IncProc(STR0031), Estornar() ,IncProc(STR0031) } , STR0032, "..." + '...', .F.)
	ElseIf cAcao == "2" // Solicitar
		Processa( {|| ProcRegua(100), IncProc(STR0031), RequestReq() ,IncProc(STR0031) } , STR0032, "..." + '...', .F.)
	EndIf
Return

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} createTemp
Cria a tabela temporaria para as requisições empenhadas

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function createTemp()
Local aColsSX3    := {}
	// Check da SD4
	AAdd(aCamposSD4,{'D4_MARK' ,'C',2,0})

	// Situação da SD4
	AAdd(aCamposSD4,{'D4_SITU' ,'C',1,0})

	// Ordem de Producao
	BuscarSX3('D4_OP',,aColsSX3)
	AAdd(aCamposSD4,{'D4_OP' ,'C',aColsSX3[3],aColsSX3[4]})

	// Armazem
	BuscarSX3('D4_LOCAL',,aColsSX3)
	AAdd(aCamposSD4,{'D4_LOCAL' ,'C',aColsSX3[3],aColsSX3[4]})

	// Produto
	BuscarSX3('D4_COD',,aColsSX3)
	AAdd(aCamposSD4,{'D4_COD' ,'C',aColsSX3[3],aColsSX3[4]})

	// Descricao Produto
	BuscarSX3('B1_DESC',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DESC' ,'C',aColsSX3[3],aColsSX3[4]})

	// Lote
	BuscarSX3('D4_LOTECTL',,aColsSX3)
	AAdd(aCamposSD4,{'D4_LOTECTL' ,'C',aColsSX3[3],aColsSX3[4]})

	// Sub-Lote
	BuscarSX3('D4_NUMLOTE',,aColsSX3)
	AAdd(aCamposSD4,{'D4_NUMLOTE' ,'C',aColsSX3[3],aColsSX3[4]})

	// Data Empenho
	BuscarSX3('D4_DATA',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DATA' ,'D',aColsSX3[3],aColsSX3[4]})

	// Quantidade Empenho
	BuscarSX3('D4_QUANT',,aColsSX3)
	AAdd(aCamposSD4,{'D4_QUANT' ,'N',aColsSX3[3],aColsSX3[4]})

	// Quantidade Segunda UM
	BuscarSX3('D4_QTSEGUM',,aColsSX3)
	AAdd(aCamposSD4,{'D4_QTSEGUM' ,'N',aColsSX3[3],aColsSX3[4]})

	// Sequencia Estrutura
	BuscarSX3('D4_TRT',,aColsSX3)
	AAdd(aCamposSD4,{'D4_TRT' ,'C',aColsSX3[3],aColsSX3[4]})

	// Documento
	BuscarSX3('DCF_DOCTO',,aColsSX3)
	AAdd(aCamposSD4,{'D4_DOCTO' ,'C',aColsSX3[3],aColsSX3[4]})

	// OP filha
	buscarSX3('D4_OPORIG',,aColsSX3)
	AAdd(aCamposSD4,{'D4_OPORIG' ,'C',aColsSX3[3],aColsSX3[4]})

	// Indice: Ordem de Produção, Local, Produto, Lote, Sub-Lote, Data Empenho, Codigo Lancamento
	criaTabTmp(aCamposSD4,{'D4_OP+D4_TRT+D4_LOCAL+D4_COD+D4_LOTECTL+D4_NUMLOTE+DTOS(D4_DATA)'},'WMSSD4')
	//----------------
	// Check do Resumo
	AAdd(aCamposProd,{'D4_MARK' ,'C',2,0})

	// Situação do Produto
	AAdd(aCamposProd,{'D4_SITU' ,'C',1,0})

	// Codigo Produto
	BuscarSX3('D4_COD',,aColsSX3)
	AAdd(aCamposProd,{'D4_COD'  ,'C',aColsSX3[3],aColsSX3[4]})

	// Descrição Produto
	BuscarSX3('B1_DESC',,aColsSX3)
	AAdd(aCamposProd,{'D4_DESC' ,'C',aColsSX3[3],aColsSX3[4]})

	// Lote
	BuscarSX3('D4_LOTECTL',,aColsSX3)
	AAdd(aCamposProd,{'D4_LOTECTL' ,'C',aColsSX3[3],aColsSX3[4]})

	// Sub-lote
	BuscarSX3('D4_NUMLOTE',,aColsSX3)
	AAdd(aCamposProd,{'D4_NUMLOTE' ,'C',aColsSX3[3],aColsSX3[4]})

	// Qtdade sumarizada das requisições
	BuscarSX3('D4_QUANT',,aColsSX3)
	AAdd(aCamposProd,{'D4_QUANT' ,'N',aColsSX3[3],aColsSX3[4]})

	// Qtdade da segunda unidade sumarizada
	BuscarSX3('D4_QTSEGUM',,aColsSX3)
	AAdd(aCamposProd,{'D4_QTSEGUM' ,'N',aColsSX3[3],aColsSX3[4]})

	// Saldo do Produto
	BuscarSX3('D4_QUANT',"Saldo",aColsSX3)
	AAdd(aCamposProd,{'D4_SALDO' ,'N',aColsSX3[3],aColsSX3[4]})

	// Endereço destino
	BuscarSX3('B5_ENDREQ',,aColsSX3)
	AAdd(aCamposProd,{'D4_ENDREQ' ,'C',aColsSX3[3],aColsSX3[4]})

	// Servico de requisicao
	BuscarSX3('B5_SERVREQ',,aColsSX3)
	AAdd(aCamposProd,{'D4_SERVIC' ,'C',aColsSX3[3],aColsSX3[4]})

	// Estrutura Fisica
	BuscarSX3('BE_ESTFIS',,aColsSX3)
	AAdd(aCamposProd,{'D4_ESTFIS' ,'C',aColsSX3[3],aColsSX3[4]})

	// Regra WMS
	BuscarSX3('DCF_REGRA',,aColsSX3)
	AAdd(aCamposProd,{'D4_REGRA' ,'C',aColsSX3[3],aColsSX3[4]})

	// Local
	BuscarSX3('D4_LOCAL',,aColsSX3)
	AAdd(aCamposProd,{'D4_LOCAL' ,'C',aColsSX3[3],aColsSX3[4]})

	// Indice: Produto, Lote, Sub-Lote
	criaTabTmp(aCamposProd,{'D4_COD+D4_LOTECTL+D4_NUMLOTE'},'WMSPROD')
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} CargaTemp
Carrega a tabela temporaria conforme o parametro e
determina a situação das requisições

@author  Tiago Filipe da Silva
@version P12
@Since	02/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function CargaTemp()
Local aAreaSD4   := SD4->(GetArea())
Local aArraySD4  := {}
Local cAliasSD4  := GetNextAlias()
Local cDocto     := ""
Local nSituSD4   := 0
Local nPos       := 0
Local lOk        := .T.

	cQuery := "SELECT SD4.R_E_C_N_O_ RECNOSD4,"
	cQuery +=       " SB1.B1_DESC"
	cQuery +=  " FROM " +RetSqlName("SD4")+ " SD4"
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1"
	cQuery +=    " ON SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	cQuery +=   " AND SB1.B1_COD = SD4.D4_COD"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=   " AND SD4.D4_OP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQuery +=   " AND SD4.D4_DATA BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+ "'"
	cQuery +=   " AND SD4.D4_COD BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cQuery +=   " AND NOT EXISTS( SELECT 1""
	cQuery +=                     " FROM "+RetSqlName("SDC")+" SDC"
	cQuery +=                    " WHERE SDC.DC_FILIAL = '"+xFilial("SDC")+"'"
	cQuery +=                      " AND SD4.D4_FILIAL = '"+xFilial("SD4")+"'"
	cQuery +=                      " AND SDC.DC_PRODUTO = SD4.D4_COD"
	cQuery +=                      " AND SDC.DC_LOCAL = SD4.D4_LOCAL"
	cQuery +=                      " AND SDC.DC_OP = SD4.D4_OP"
	cQuery +=                      " AND SDC.DC_TRT = SD4.D4_TRT"
	cQuery +=                      " AND SDC.DC_IDDCF = ' '""
	cQuery +=                      " AND SDC.D_E_L_E_T_ = ' ')"
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSD4,.F.,.T.)

	While(cAliasSD4)->(!Eof())
		SD4->(dbGoTo((cAliasSD4)->RECNOSD4))

		cDocto := ""

		// Retorna a situação conforme o status na DCF e SDB e o documento correspondente
		Situacao(@nSituSD4,@cDocto)
		
		// Verifica a se o parametro passado é 5 (Todos) ou se a situação da requisição é a mesma do parametro
		If MV_PAR07 == 5 .OR. nSituSD4 == MV_PAR07
			// Procura se a Ordem de Prod./Local/Produto/Lote/Sub-lote já existe no array
			nPos := aScan(aArraySD4, {|x| x[3]+x[13]+x[4]+x[5]+x[7]+x[8] == SD4->D4_OP+SD4->D4_TRT+SD4->D4_LOCAL+SD4->D4_COD+SD4->D4_LOTECTL+SD4->D4_NUMLOTE})
			
			If nPos == 0
				// Grava os dados na matriz para posteriormente gravar na tabela temporária
				aAdd(aArraySD4,;
					{'',;
					NtoC(nSituSD4,10),;
					SD4->D4_OP,;
					SD4->D4_LOCAL,;
					SD4->D4_COD,;
					(cAliasSD4)->B1_DESC,;
					SD4->D4_LOTECTL,;
					SD4->D4_NUMLOTE,;
					SD4->D4_DATA,;
					SD4->D4_QUANT,;
					SD4->D4_QTSEGUM,;
					SD4->D4_TRT,;
					cDocto,;
					SD4->D4_OPORIG})	
			Else
				// Atualiza a situacao da requisicao
				aArraySD4[nPos][2] :=  NtoC(nSituSD4,10)
			EndIf
		EndIf
		(cAliasSD4)->(dbSkip())
	EndDo
	// Ordena as informações de acordo com o indice
	aSort(aArraySD4,,, { |x,y| y[3]+y[4]+y[5]+y[7]+y[8]+DTOS(y[9]) > x[3]+x[4]+x[5]+x[7]+x[8]+DTOS(x[9])})

	(cAliasSD4)->(dbCloseArea())

	aArrayProd := {}
	MntCargDad('WMSSD4',aArraySD4,aCamposSD4)
	MntCargDad('WMSPROD',aArrayProd,aCamposProd)
	RestArea(aAreaSD4)
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} AfterMark
Função para carga das informações para o segundo browse

@author  Tiago Filipe da Silva
@version P12
@Since	07/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function AfterMark()
Local aArea := WMSSD4->(GetArea())
Local aArrayProd := {}
Local nSituSD4    := 0
Local cDocto     := ""
Local cEndReq    := ""
Local cServReq   := ""
Local cEstFis    := ""
Local nPos       := 0
Local nSaldo     := 0
Local cAliasQry	 := ""
Local nPosEnd	 := 0
Local aArrayEnd	 := {}

	dbSelectArea("WMSSD4")

	WMSSD4->(dbSetOrder(1))
	WMSSD4->(dbGoTop())

	// Varre a tabela temporaria de requisições
	While WMSSD4->(!Eof())
		nSaldo	:=	0
		// Considera se o registro estiver marcado (check)
		If AllTrim(WMSSD4->D4_MARK) != ''

			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT SD4.R_E_C_N_O_ RECNOSD4
				FROM %Table:SD4% SD4
				WHERE SD4.D4_FILIAL = %xFilial:SD4%
				AND SD4.D4_LOCAL = %Exp:WMSSD4->D4_LOCAL%
				AND SD4.D4_OP = %Exp:WMSSD4->D4_OP%
				AND SD4.D4_TRT =  %Exp:WMSSD4->D4_TRT%
				AND SD4.D4_COD =  %Exp:WMSSD4->D4_COD%
				AND SD4.D4_LOTECTL = %Exp:WMSSD4->D4_LOTECTL%
				AND SD4.D4_NUMLOTE =  %Exp:WMSSD4->D4_NUMLOTE%
				AND SD4.D4_OPORIG =  %Exp:WMSSD4->D4_OPORIG%
				AND SD4.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				SD4->(dbGoTo((cAliasQry)->RECNOSD4))
			EndIf
			(cAliasQry)->( DbCloseArea() )

			// Retorna a situação conforme o status na DCF e SDB e o documento correspondente
			Situacao(@nSituSD4,@cDocto)

			// Não há Empenho e não há solicitação no WMS,  1 - Nao solicitada
			If nSituSD4 == 1
				// Acessa a SB5 para buscar o endereco e o servico de requisicao
				dbSelectArea("SB5")
				SB5->(dbSetOrder(1))
				If SB5->(dbSeek(xFilial("SB5")+SD4->D4_COD))
					cEndReq := SB5->B5_ENDREQ
					cEstFis := ""

					// Se o endereco nao estiver vazio, busca a estrutura fisica
					If !Empty(cEndReq)
						dbSelectArea("SBE")
						SBE->(dbSetOrder(1))
						If SBE->(dbSeek(xFilial("SBE")+SD4->D4_LOCAL+cEndReq))
							cEstFis := SBE->BE_ESTFIS
						EndIf
					EndIf

					cServReq := SB5->B5_SERVREQ
				EndIf

				// Verifica se já existe o produto/lote/sublote no array, se existir, soma, caso contrario cria uma nova posicao
				nPos := aScan(aArrayProd, {|x| x[3]+x[5]+x[6] == SD4->D4_COD+SD4->D4_LOTECTL+SD4->D4_NUMLOTE})

				SBF->(DbSetOrder(2)) //--BF_FILIAL + BF_PRODUTO + BF_LOCAL + BF_LOTECTL + BF_NUMLOTE + BF_PRIOR + BF_LOCALIZ + BF_NUMSERI
				SBF->(dbSeek(xFilial("SBF")+SD4->D4_COD+SD4->D4_LOCAL))
				While SBF->( !EOF() ) .And. SBF->BF_PRODUTO+SBF->BF_LOCAL == SD4->D4_COD+SD4->D4_LOCAL
					
					// Verifica se já existe o produto/lote/sublote no array por endereço, se existir, 
					nPosEnd := aScan(aArrayEnd, {|y| y[1]+y[2]+y[3]+y[4]+y[5] == SBF->(BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_LOCALIZ)})

					If nPosEnd == 0
						nSaldo += SBF->BF_QUANT - SBF->BF_EMPENHO

						aAdd(aArrayEnd,	{ SBF->BF_PRODUTO, SBF->BF_LOCAL, SBF->BF_LOTECTL, SBF->BF_NUMLOTE, SBF->BF_LOCALIZ })
					EndIf
					SBF->( DbSkip() )
				EndDo

				// Cria uma nova posição com os valores
				If nPos == 0
					// Busca o saldo do Produto/Local/Lote/Sub-lote
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					SB1->(dbSeek(xFilial("SB1")+SD4->D4_COD))

					aAdd(aArrayProd,;
						 {'',;
							 NtoC(nSituSD4,10),;
							 SD4->D4_COD,;
							 SB1->B1_DESC,;
							 SD4->D4_LOTECTL,;
							 SD4->D4_NUMLOTE,;
							 SD4->D4_QUANT,;
							 SD4->D4_QTSEGUM,;
							 nSaldo,;
							 cEndReq,;
							 cServReq,;
							 cEstFis,;
							 '',;
							 SD4->D4_LOCAL})
				Else
					// Soma a quantidade do produto
					aArrayProd[nPos][7] += SD4->D4_QUANT   // Qtdade sumarizada das requisições
					aArrayProd[nPos][8] += SD4->D4_QTSEGUM // Qtdade da segunda unidade sumarizada
					aArrayProd[nPos][9] += nSaldo          // Saldo
				EndIf
			EndIf
		EndIf

		WMSSD4->(dbSkip())
	EndDo

	// Ordena as informações de acordo com o indice
	aSort(aArrayProd,,, { |x,y| y[3]+y[5]+y[6] > x[3]+x[5]+x[6] } )

	MntCargDad('WMSPROD',aArrayProd,aCamposProd)

	oBrwPRD:Refresh(.T.)

	RestArea(aArea)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} SetMarkAll
Função para marcar todas as requisições

@author Tiago Filipe da Silva
@since 08/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function SetMarkAll(cMarca,lMarcar)
	Local cAliasSD4 := 'WMSSD4'
	Local aAreaSD4  := (cAliasSD4)->(GetArea())

	dbSelectArea(cAliasSD4)
	(cAliasSD4)->(dbGoTop())
	While (cAliasSD4)->(!Eof())
		RecLock((cAliasSD4), .F.)
		(cAliasSD4)->D4_MARK := IIf(lMarcar,cMarca,'')
		MsUnLock()
		(cAliasSD4)->(dbSkip())
	EndDo

	AfterMark()

	RestArea(aAreaSD4)
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} MarkAllPro
Função para marcar todas as requisições no segundo browse

@author Tiago Filipe da Silva
@since 08/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarkAllPro(cMarca,lMarcar)
	Local aAreaAnt := GetArea()
	Local cAliasProd := 'WMSPROD'

	dbSelectArea(cAliasProd)
	(cAliasProd)->(dbGoTop())

	While (cAliasProd)->(!Eof())
		RecLock((cAliasProd), .F.)
		(cAliasProd)->D4_MARK := IIf(lMarcar,cMarca,'')
		MsUnLock()
		(cAliasProd)->(dbSkip())
	EndDo

	RestArea(aAreaAnt)
Return .T.

//-----------------------------------------------------------
// Embarques
/*/{Protheus.doc} Situacao
Função para definição da situação das requisições

@author  Tiago Filipe da Silva
@version P12
@Since	07/04/14
@version 1.0
/*/
//-----------------------------------------------------------
Static Function Situacao(nSituSD4,cDocto)
Local cAliasDCF := GetNextAlias()
Local cAliasTMP := GetNextAlias()
Local cAliasSDC := ""
Local cQuery    := ""
Local lEmpenho  := .F.

Default cDocto := ""
	cQuery := " SELECT SDC.DC_PRODUTO"
	cQuery +=   " FROM "+RetSqlName('SDC')+" SDC"
	cQuery +=  " WHERE SDC.DC_FILIAL = '"+xFilial("SDC")+"'"
	cQuery +=    " AND SDC.DC_PRODUTO = '"+SD4->D4_COD+"'"
	cQuery +=    " AND SDC.DC_LOCAL = '"+SD4->D4_LOCAL+"'"
	cQuery +=    " AND SDC.DC_OP = '"+SD4->D4_OP+"'"
	cQuery +=    " AND SDC.DC_TRT = '"+SD4->D4_TRT+"'"
	cQuery +=    " AND SDC.DC_LOTECTL = '"+SD4->D4_LOTECTL+"'"
	cQuery +=    " AND SDC.DC_NUMLOTE = '"+SD4->D4_NUMLOTE+"'"
	cQuery +=    " AND SDC.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSDC := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSDC,.F.,.T.)
	If (cAliasSDC)->(!EoF())
		lEmpenho := .T.
	EndIf
	(cAliasSDC)->(dbCloseArea())

	If Empty(SD4->D4_IDDCF)
		If lEmpenho
			// Ha Empenho de endereço não será considerado
			nSituSD4 := 0
		Else
			// Não há Empenho e não há solicitação no WMS,  1 - Nao solicitada
			nSituSD4 := 1
		EndIf
	Else
		cQuery := "SELECT DCF.DCF_STSERV,"
		cQuery +=       " DCF.DCF_ID,"
		cQuery +=       " DCF.DCF_DOCTO"
		cQuery +=  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery += " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=   " AND DCF.DCF_ID = '"+SD4->D4_IDDCF+"'"
		cQuery +=   " AND DCF.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDCF,.F.,.T.)
		If (cAliasDCF)->(!Eof())
			cDocto := (cAliasDCF)->DCF_DOCTO

			If (cAliasDCF)->DCF_STSERV <> '3'
				// Solicitado no WMS mas não foi executado, 2 - Nao iniciado
				nSituSD4 := 2
			Else
				cAliasTMP := GetNextAlias()
				cQuery := " SELECT SDB.DB_STATUS"
				cQuery +=   " FROM "+RetSqlName("SDB")+" SDB"
				cQuery +=  " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+" '"
				cQuery +=    " AND SDB.DB_IDDCF IN (SELECT DCR.DCR_IDORI "
				cQuery +=                           " FROM "+RetSqlName("DCR")+" DCR"
				cQuery +=                          " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
				cQuery +=                            " AND DCR.DCR_IDDCF = '"+(cAliasDCF)->DCF_ID+"'"
				cQuery +=                            " AND DCR.D_E_L_E_T_ = ' ')"
				cQuery +=    " AND SDB.DB_ESTORNO <> 'S'"
				cQuery +=    " AND SDB.DB_STATUS NOT IN('1','M','A')" // Se é diferente de 'Executada'
				cQuery +=    " AND SDB.DB_ATUEST = 'N'"
				cQuery +=    " AND SDB.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)

				If (cAliasTMP)->(!Eof()) // Se algum ainda estiver diferente de 'Executada'
					nSituSD4 := 3        // 3-Em Andamento
				Else                     // Se todas já foram executadas
					nSituSD4 := 4        // 4-Finalizadas
				EndIf
				(cAliasTMP)->(dbCloseArea())
			EndIf
		EndIf
		(cAliasDCF)->(dbCloseArea())
	EndIf
Return .T.

//--------------------------------------------------------------------
/*/{Protheus.doc} RequestReq
Função de solicitacao das requisicoes

@author Tiago Filipe da Silva
@since 09/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RequestReq()
Local aAreaAnt   := GetArea()
Local aAreaDCF   := DCF->(GetArea())
Local cAliasSD4  := 'WMSSD4'
Local cAliasProd := 'WMSPROD'
Local aColsSX3   := {}
Local cDoctoDCF  := ""
Local cResumo    := ""
Local lRet       := .T.
Local lSB5       := .T.
Local lOk        := .F.
Local nSituSD4   := 0
Local nPosDCF    := 0
Local aLibDCF    := WmsLibDCF() // Busca referencia do array WMS
Local cAliasQry	 := ""

Private aParam150 := {}
	dbSelectArea(cAliasProd)
	(cAliasProd)->(dbGoTop())

	// Verifica se há alguma requisição selecionada
	While (cAliasProd)->(!Eof())
		If AllTrim((cAliasProd)->D4_MARK) != ''
			lOk := .T.

			// Verifica se há alguma requisição que não tenha Serviço/Endereço informado
			If (AllTrim((cAliasProd)->D4_SERVIC) == '' .OR. AllTrim((cAliasProd)->D4_ENDREQ) == '')
				lSB5 := .F.
			EndIf

			If (cAliasProd)->D4_QUANT > (cAliasProd)->D4_SALDO
				
				WmsMessage(WmsFmtMsg(STR0033,{{"[VAR01]",AllTrim((cAliasProd)->D4_COD )},{"[VAR02]",AllTrim((cAliasProd)->D4_LOCAL)}}),WMSA50013,5/*MSG_HELP*/) // Não há saldo de lote para o produto [VAR01] no armazém [VAR02] para atender a requisição!

				RestArea(aAreaDCF)
				RestArea(aAreaAnt)
				Return lRet
			EndIf

		EndIf

		(cAliasProd)->(dbSkip())
	EndDo

	// Se houver alguma requisição selecionada prossegue
	If lOk
		If !lSB5
			WmsMessage(STR0012,WMSA50001,5/*MSG_HELP*/) // Há itens selecionados que não possuem Código Serviço e/ou Endereço destino informado. Favor verificar.
		Else
			cDoctoDCF := ""
			// Cabecalho do resumo
			cResumo   :=  AllTrim(BuscarSX3('D4_OP',,aColsSX3))+ '|' + AllTrim(BuscarSX3('D4_COD',,aColsSX3)) + "|" +;
							  AllTrim(BuscarSX3('D4_LOTECTL',,aColsSX3)) +  "|" + AllTrim(BuscarSX3('D4_NUMLOTE',,aColsSX3)) + "|" + AllTrim(BuscarSX3('D4_QUANT',,aColsSX3)) + ":" + chr(10)

			(cAliasProd)->(dbGoTop())

			While (cAliasProd)->(!Eof())
				If AllTrim((cAliasProd)->D4_MARK) != ''
					(cAliasProd)->D4_QUANT   := 0
					(cAliasProd)->D4_QTSEGUM := 0

					dbSelectArea(cAliasSD4)
					(cAliasSD4)->(dbGoTop())

					// Atualiza a situacao e os saldos, caso houve concorrencia de processos
					While (cAliasSD4)->(!Eof())
						If (cAliasSD4)->D4_COD == (cAliasProd)->D4_COD .And.;
							(cAliasSD4)->D4_LOTECTL == (cAliasProd)->D4_LOTECTL .AND.;
							(cAliasSD4)->D4_NUMLOTE == (cAliasProd)->D4_NUMLOTE .AND.;
							 AllTrim((cAliasSD4)->D4_MARK) != ''

							cAliasQry := GetNextAlias()
							BeginSql Alias cAliasQry
								SELECT SD4.R_E_C_N_O_ RECNOSD4
								FROM %Table:SD4% SD4
								WHERE SD4.D4_FILIAL = %xFilial:SD4%
								AND SD4.D4_LOCAL = %Exp:(cAliasSD4)->D4_LOCAL%
								AND SD4.D4_OP = %Exp:(cAliasSD4)->D4_OP%
								AND SD4.D4_TRT =  %Exp:(cAliasSD4)->D4_TRT%
								AND SD4.D4_COD =  %Exp:(cAliasSD4)->D4_COD%
								AND SD4.D4_LOTECTL = %Exp:(cAliasSD4)->D4_LOTECTL%
								AND SD4.D4_NUMLOTE =  %Exp:(cAliasSD4)->D4_NUMLOTE%
								AND SD4.D4_OPORIG =  %Exp:(cAliasSD4)->D4_OPORIG%
								AND SD4.%NotDel%
							EndSql
							If (cAliasQry)->(!Eof())
								SD4->(dbGoTo((cAliasQry)->RECNOSD4))
							EndIf
							(cAliasQry)->( DbCloseArea() )

							// Retorna a situação conforme o status na DCF e SDB e o documento correspondente
							Situacao(@nSituSD4)

							If nSituSD4 == 1
								(cAliasProd)->D4_QUANT   += (cAliasSD4)->D4_QUANT
								(cAliasProd)->D4_QTSEGUM += (cAliasSD4)->D4_QTSEGUM
								// Dados do resumo
								cResumo += SD4->D4_OP + "|" + SD4->D4_COD + "|" + SD4->D4_LOTECTL + "|" + SD4->D4_NUMLOTE + "|" + NToC(SD4->D4_QUANT,10) + chr(10)
							EndIf
						EndIf
						(cAliasSD4)->(dbSkip())
					EndDo
					// Se ainda houver quantidade do produto requisitado, é criado a DCF
					If (cAliasProd)->D4_QUANT > 0
						// Criacao da DCF
						If (Empty(cDoctoDCF))
							cDoctoDCF := GetSX8Num('DCF','DCF_DOCTO')
							If (__lSX8)
								ConfirmSX8()
							EndIf
						EndIf
						// Matriz para criacao da DCF
						aParam150     := Array(32)
						aParam150[01] := (cAliasProd)->D4_COD
						aParam150[02] := (cAliasProd)->D4_LOCAL
						aParam150[03] := cDoctoDCF
						aParam150[05] := ""
						aParam150[06] := (cAliasProd)->D4_QUANT
						aParam150[07] := dDatabase
						aParam150[09] := (cAliasProd)->D4_SERVIC
						aParam150[17] := "SD4"
						aParam150[18] := (cAliasProd)->D4_LOTECTL
						aParam150[19] := (cAliasProd)->D4_NUMLOTE
						aParam150[22] := (cAliasProd)->D4_REGRA
						aParam150[26] := (cAliasProd)->D4_ENDREQ
						aParam150[27] := (cAliasProd)->D4_ESTFIS
						WmsCriaDCF('SD4',,,aParam150,@nPosDCF)
						dbSelectArea('DCF')
						DCF->(DbGoTo(nPosDCF))
						If !Empty(nPosDCF) .And. WmsVldSrv('4',DCF->DCF_SERVIC)
							AAdd(aLibDCF,nPosDCF)
						EndIf

						(cAliasSD4)->(dbGoTop())

						// Atualiza a IDDCF da SD4 com o ID criado
						While (cAliasSD4)->(!Eof())
							If (cAliasSD4)->D4_COD     == (cAliasProd)->D4_COD .And.;
								(cAliasSD4)->D4_LOTECTL == (cAliasProd)->D4_LOTECTL .AND.;
								(cAliasSD4)->D4_NUMLOTE == (cAliasProd)->D4_NUMLOTE .AND.;
								 AllTrim((cAliasSD4)->D4_MARK) != ''

								cAliasQry := GetNextAlias()
								BeginSql Alias cAliasQry
									SELECT SD4.R_E_C_N_O_ RECNOSD4
									FROM %Table:SD4% SD4
									WHERE SD4.D4_FILIAL = %xFilial:SD4%
									AND SD4.D4_LOCAL = %Exp:(cAliasSD4)->D4_LOCAL%
									AND SD4.D4_OP = %Exp:(cAliasSD4)->D4_OP%
									AND SD4.D4_TRT =  %Exp:(cAliasSD4)->D4_TRT%
									AND SD4.D4_COD =  %Exp:(cAliasSD4)->D4_COD%
									AND SD4.D4_LOTECTL = %Exp:(cAliasSD4)->D4_LOTECTL%
									AND SD4.D4_NUMLOTE =  %Exp:(cAliasSD4)->D4_NUMLOTE%
									AND SD4.D4_OPORIG =  %Exp:(cAliasSD4)->D4_OPORIG%
									AND SD4.%NotDel%
								EndSql
								If (cAliasQry)->(!Eof())
									SD4->(dbGoTo((cAliasQry)->RECNOSD4))
								EndIf
								(cAliasQry)->( DbCloseArea() )

								RecLock('SD4',.F.)
								SD4->D4_IDDCF := DCF->DCF_ID
								SD4->(MsUnLock())
							EndIf
							(cAliasSD4)->(dbSkip())
						EndDo
					EndIf
				EndIf

				(cAliasProd)->(dbSkip())
			EndDo
			// Verifica as Ordens de servico geradas para execução automatica
			WmsExeServ()
			
			If WmsMessage(cResumo,WMSA50003,10,,{STR0020}) == 1 // Ok
				// Carrega os dados na tabela temporária de requisições
				CargaTemp()
				AtualBrw()
			EndIf
		EndIf
	Else
		WmsMessage(STR0013,WMSA50004,5/*MSG_HELP*/) // Não há itens selecionados. Favor verificar.
	EndIf
	RestArea(aAreaDCF)
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Alterar
Funcao para alteracao do Servico/End. Destino

@author Tiago Filipe da Silva
@since 10/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function Alterar()
	Local aAreaSBE   := SBE->(GetArea())
	Local aColsSX3   := {}
	Local cServ      := ""
	Local cEnd       := ""
	Local cRegra     := ""
	Local cServDes   := ""
	Local cEndDes    := ""
	Local cRegDes    := ""
	Local cEstrut    := ""
	Local nOpc       := 0
	Local nPos       := 0
	Local lRet       := .T.
	Local lOk        := .F.
	Local oDlg
	Local aRegra     := {STR0026,STR0027,STR0028,STR0029,STR0030}

	cServDes := BuscarSX3('DCF_SERVIC',,aColsSX3)
	cEndDes  := BuscarSX3('BE_LOCALIZ',,aColsSX3)
	cRegDes  := BuscarSX3('DCF_REGRA',,aColsSX3)

	// Busca o servico da tabela temporaria para mostrar em tela
	cServ  := WMSPROD->D4_SERVIC
	cEnd   := WMSPROD->D4_ENDREQ

	// Retorna a posição da opcao em tela
	cRegra := aScan(aRegra, {|x| WMSPROD->D4_REGRA $ x})

	DEFINE MSDIALOG oDlg TITLE STR0014 From 50,50 to 195,270 PIXEL  // Alterar Servico/End. Destino

	@ 06,05 SAY cServDes+':' SIZE 50,8 OF oDlg PIXEL  // Cod. Servico:
	@ 05,50 MSGET oGet VAR cServ F3 "DC5" SIZE 50,06 WHEN .T. PICTURE "@!" OF oDlg PIXEL VALID WMSA500SER(cServ)

	@ 24,05 SAY AllTrim(cEndDes)+':' SIZE 50,8 OF oDlg PIXEL  // Endereco Destino:
	@ 23,50 MSGET oGet VAR cEnd F3 "SBE" SIZE 50,06 WHEN .T. PICTURE "@!" OF oDlg PIXEL VALID WMSA500END(cEnd)

	@ 42,05 SAY AllTrim(cRegDes)+':' SIZE 50,8 OF oDlg PIXEL  // Regra WMS:
	@ 41,50 COMBOBOX cRegra ITEMS aRegra SIZE 50,06 PIXEL OF oDlg

	DEFINE SBUTTON FROM 58,040 TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE Of oDlg  // OK
	DEFINE SBUTTON FROM 58,073 TYPE 2 ACTION (nOpc := 2,oDlg:End()) ENABLE Of oDlg  // Cancela

	ACTIVATE DIALOG oDlg CENTERED

	If nOpc == 1 .And. !Empty(cServ) .And. !Empty(cEnd)
		dbSelectArea("SBE")
		SBE->(dbSetOrder(1))

		// Retorna a estrutura fisica
		If SBE->(dbSeek(xFilial("SBE")+WMSPROD->D4_LOCAL+cEnd))
			cEstrut := SBE->BE_ESTFIS
		EndIf

		// Retorna o conteudo da regra no array para gravação no banco
		If ValType(cRegra) != "C"
			cRegra := aRegra[cRegra]
		EndIf

		RecLock("WMSPROD", .F.)
		WMSPROD->D4_SERVIC := cServ
		WMSPROD->D4_ENDREQ := cEnd
		WMSPROD->D4_ESTFIS := cEstrut
		WMSPROD->D4_REGRA  := SubStr(cRegra,1,1)
		MsUnLock()
	EndIf

	RestArea(aAreaSBE)
	oBrwPRD:oBrowse:LineRefresh()
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Servico
Validacao do campo Servico

@author Tiago Filipe da Silva
@since 14/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function WMSA500SER(cServ)
	Local aAreaDC5 := DC5->(GetArea())
	Local lRet    := .F.
	Default cServ := ""

	dbSelectArea("DC5")
	DC5->(dbSetOrder(1))

	If DC5->(dbSeek(xFilial("DC5")+cServ))
		If DC5->DC5_TIPO == '2'
			lRet := .T.
		Else
			WmsMessage(STR0017,WMSA50005,5/**/) // Tipo do serviço deve ser '2-Saida'. Favor verificar.
			lRet := .F.
		EndIf
	Else
		WmsMessage(STR0016,WMSA50006,5/**/) // Serviço inválido. Favor verificar.
		lRet := .F.
	EndIf
	RestArea(aAreaDC5)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Endereco
Validacao do campo Endereco

@author Tiago Filipe da Silva
@since 14/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function WMSA500END(cEnd)
	Local aAreaAnt := GetArea()
	Local lRet   := .F.
	Default cEnd := ""

	dbSelectArea("SBE")
	SBE->(dbSetOrder(1))

	If dbSeek(xFilial("SBE")+WMSPROD->D4_LOCAL+cEnd)
		lRet := .T.
	Else
		WmsMessage(STR0019,WMSA50007,5/**/) // Endereco invalido. Favor verificar.
		lRet := .F.
	EndIf
	RestArea(aAreaAnt)
Return lRet
//--------------------------------------------------------------------
/*/{Protheus.doc} Estornar
Estorno das requisições selecionadas

@author Tiago Filipe da Silva
@since 15/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function Estornar()
Local aAreaDCF  := DCF->(GetArea())
Local cAliasSD4 := 'WMSSD4'
Local nSituSD4  := 0
Local aColsSX3  := {}
Local cDocto    := ""
Local cResumo   := ""
Local lSit      := .F.
Local lOk       := .F.
Local lRet      := .T.
Local lEstorno  := .F.
	dbSelectArea((cAliasSD4))
	(cAliasSD4)->(dbSetOrder(1))
	(cAliasSD4)->(dbGoTop())
	
	Begin Transaction
	
		// Varre a tabela temporaria de requisições
		While (cAliasSD4)->(!Eof())
			// Considera se o registro estiver marcado (check)
			If AllTrim((cAliasSD4)->D4_MARK) != ''
				lOk := .T.
	
				dbSelectArea("SD4")
				SD4->(dbSetOrder(1))
				SD4->(dbSeek(xFilial('SD4')+(cAliasSD4)->D4_COD+(cAliasSD4)->D4_OP+(cAliasSD4)->D4_TRT+(cAliasSD4)->D4_LOTECTL+(cAliasSD4)->D4_NUMLOTE))
	
				// Retorna a situação conforme o status na DCF e SDB e o documento correspondente
				Situacao(@nSituSD4,@cDocto)
	
				If nSituSD4 == 2
					lSit := .T.
					Exit
				EndIf
			EndIf
			(cAliasSD4)->(dbSkip())
		EndDo
	
		If lOk
			If lSit
				(cAliasSD4)->(dbGoTop())
	
				cResumo := AllTrim(BuscarSX3('D4_OP',,aColsSX3))+ '|' + AllTrim(BuscarSX3('D4_COD',,aColsSX3)) + "|" +;
							  AllTrim(BuscarSX3('D4_LOTECTL',,aColsSX3)) +  "|" + AllTrim(BuscarSX3('D4_NUMLOTE',,aColsSX3)) + "|" +;
							  AllTrim(BuscarSX3('D4_QUANT',,aColsSX3)) + ":" + chr(10)
	
				While (cAliasSD4)->(!Eof())
					If AllTrim((cAliasSD4)->D4_MARK) != ''
						dbSelectArea('SD4')
						SD4->(dbSetOrder(1))
						If SD4->(dbSeek(xFilial('SD4')+(cAliasSD4)->D4_COD+(cAliasSD4)->D4_OP+(cAliasSD4)->D4_TRT+(cAliasSD4)->D4_LOTECTL+(cAliasSD4)->D4_NUMLOTE))
							cResumo += SD4->D4_OP + "|" + SD4->D4_COD + "|" + SD4->D4_LOTECTL + "|" + SD4->D4_NUMLOTE + "|" + NToC(SD4->D4_QUANT,10) + chr(10)
							dbSelectArea("DCF")
							DCF->(dbSetOrder(9))
							If DCF->(dbSeek(xFilial("DCF")+SD4->D4_IDDCF))
								// Se a quantidade a ser estornada zera a quantidade da DCF, o registro da DCF é excluido
								RecLock('DCF',.F.)
								If DCF->DCF_QUANT - SD4->D4_QUANT == 0
									DCF->(dbDelete())
								Else
									DCF->DCF_QUANT  -= SD4->D4_QUANT
									DCF->DCF_QTSEUM -= SD4->D4_QTSEGUM
								EndIf
								DCF->(MsUnLock())
							EndIf
							If lRet
								// Apaga a IDDCF da SD4
								RecLock('SD4',.F.)
								SD4->D4_IDDCF := ''
								SD4->(MsUnLock())
								lEstorno := .T.
							EndIf
						EndIf
					EndIf
					(cAliasSD4)->(dbSkip())
				EndDo
				If lEstorno 
					WmsMessage(cResumo,WMSA50010,10,,{STR0020}) // Ok
				EndIf
			Else
				WmsMessage(STR0021,WMSA50011,5/*MSG_HELP*/) // Status não permite o estorno. Favor verificar
			EndIf
		Else
			WmsMessage(STR0013,WMSA50012,5/*MSG_HELP*/) // Não há itens selecionados. Favor verificar.
		EndIf
	
	End Transaction
	MsUnLockAll() 
	// Carrega os dados na tabela temporária de requisições
	CargaTemp()
	AtualBrw()
	RestArea(aAreaDCF)
Return Nil
//--------------------------------------------------------------------
/*/{Protheus.doc} Selecao
Função para chamada do Pergunte e atualização dos dados

@author Tiago Filipe da Silva
@since 16/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function Selecao()
	If Pergunte('WMSA500',.T.)
		CargaTemp()
		AtualBrw()
	EndIf
Return .T.
//--------------------------------------------------------------------
/*/{Protheus.doc} AtualBrw
Atualiza browses

@author Tiago Filipe da Silva
@since 16/04/14
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtualBrw()
	oBrwPRD:Refresh(.T.)
	oBrwSD4:Refresh(.T.)
Return .T.