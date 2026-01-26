#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "mrpdetails.CH"

#DEFINE ARRAY_POS_CHAVE	            1
#DEFINE ARRAY_POS_EMPRESA           2
#DEFINE ARRAY_POS_TICKET            3
#DEFINE ARRAY_POS_PRODUTO           4
#DEFINE ARRAY_POS_ID_OPCIONAL       5
#DEFINE ARRAY_POS_PERIODO           6
#DEFINE ARRAY_POS_TIPO_DOCUMENTO    7
#DEFINE ARRAY_POS_CODIGO_DOCUMENTO  8
#DEFINE ARRAY_POS_PRODUTO_PAI       9
#DEFINE ARRAY_POS_TIPO_REGISTRO     10
#DEFINE ARRAY_POS_QUANTIDADE        11
#DEFINE ARRAY_POS_DOC_MRP           12
#DEFINE ARRAY_POS_QTD_TOTAL         13
#DEFINE ARRAY_POS_STATUS_DOCUMENTO  14
#DEFINE ARRAY_POS_LOCAL             15
#DEFINE ARRAY_POS_EVENT             16
#DEFINE ARRAY_POS_DOCUMENTO_FILTRO  17
#DEFINE ARRAY_POS_DETALHA_SALDO     18
#DEFINE ARRAY_POS_SIZE              18

Static _oMrpDet   := Nil

/*/{Protheus.doc} mrpdetails
API de detalhes dos resultados do MRP

@type  WSCLASS
@author renan.roeder
@since 31/01/2022
@version P12.1.37
/*/
WSRESTFUL mrpdetails DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Detalhes dos resultados do MRP"
	WSDATA branchId   AS STRING OPTIONAL
	WSDATA document   AS STRING OPTIONAL
	WSDATA ticket     AS STRING
	WSDATA product    AS STRING
	WSDATA idOpc      AS STRING OPTIONAL
	WSDATA periodFrom AS STRING OPTIONAL
	WSDATA periodTo   AS STRING OPTIONAL
	WSDATA type       AS STRING OPTIONAL
	WSDATA Page       AS INTEGER OPTIONAL
	WSDATA PageSize   AS INTEGER OPTIONAL

	WSMETHOD GET DETAILS;
		DESCRIPTION STR0002; //"Retorna os resultados do cálculo do MRP para o ticket e produto especificados"
		WSSYNTAX "api/pcp/v1/mrpdetails/{ticket}/{product}" ;
		PATH "api/pcp/v1/mrpdetails/{ticket}/{product}" ;
		TTALK "v1"

	WSMETHOD GET TRANSFER;
		DESCRIPTION STR0006; //"Retorna todas as transferências de um produto para um ticket (SMA)"
		WSSYNTAX "api/pcp/v1/mrpdetails/transferences/{ticket}/{product}" ;
		PATH "api/pcp/v1/mrpdetails/transferences/{ticket}/{product}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} MrpDetails
Classe com as regras para consulta dos detalhes do MRP.

@author lucas.franca
@since 26/04/2024
@version P12
/*/
CLASS MrpDetails FROM LongNameClass

	DATA aFiliaisTicket    AS Array
	DATA cTicket           AS String
	DATA cFiliaisFiltro    AS String
	DATA cTipoEstSeguranca AS String
	DATA cTipoPontoPedido  AS String
	DATA cBanco            AS String
	DATA lDoTransfersMrp   AS Logical
	DATA lPossuiTabelaSMV  AS Logical
	DATA lPossuiHWC_AGLUT  AS Logical
	DATA lUsaMultiEmpresa  AS Logical
	DATA lMRPAPIDET        AS Logical
	DATA nTamQtd           AS Numeric
	DATA nDecQtd           AS Numeric
	DATA oQryAGL           AS Object
	DATA oQryHWG           AS Object

	METHOD new() CONSTRUCTOR

	METHOD carregaParametroTicket(cTicket)
	METHOD executaQuerySMV(cBranchId, cProduto, cIdOpc, cDataAte)
	METHOD executaQueryHWC(cBranchId, cProduto, cIdOpc, cDataAte)
	METHOD executaQueryAglutinadosHWC(cBranchId, cProduto, cIdOpc, cDataAte)
	METHOD getFiliaisFiltro(cTabela)

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe MrpDetails

@author lucas.franca
@since 26/04/2024
@version P12
@return Self, objeto, instância do objeto MrpDetails criado
/*/
METHOD new() CLASS MrpDetails

	Self:cTicket           := ""
	Self:cFiliaisFiltro    := ""
	Self:cTipoEstSeguranca := MrpDGetSTR("ES")
	Self:cTipoPontoPedido  := MrpDGetSTR("PP")
	Self:lPossuiTabelaSMV  := AliasInDic("SMV")
	Self:cBanco            := TCGetDB()
	Self:lUsaMultiEmpresa  := .F.
	Self:lDoTransfersMrp   := .T.
	Self:lMRPAPIDET        := ExistBlock("MRPAPIDET")
	Self:nTamQtd           := GetSx3Cache("MV_QUANT", "X3_TAMANHO")
	Self:nDecQtd           := GetSx3Cache("MV_QUANT", "X3_DECIMAL")

	DbSelectArea("HWC")
	Self:lPossuiHWC_AGLUT := FieldPos("HWC_AGLUT") > 0

Return Self

/*/{Protheus.doc} carregaParametroTicket
Carrega os parâmetros do ticket para usar durante as consultas.

@author lucas.franca
@since 26/04/2024
@version P12
@param cTicket, Caracter, Código do ticket para carregar os parâmetros
@return Nil
/*/
Method carregaParametroTicket(cTicket) Class MrpDetails
	Local aFiliais := Nil
	Local nIndex   := 0
	Local nTotal   := 0

	If cTicket != Self:cTicket

		Self:aFiliaisTicket   := {}
		Self:cFiliaisFiltro   := ""
		Self:cTicket          := cTicket
		Self:lUsaMultiEmpresa := MrpTiktME(cTicket, .T., @aFiliais)[2]["useMultiBranches"]

		If Self:lUsaMultiEmpresa
			Self:cFiliaisFiltro := "'"

			nTotal := Len(aFiliais)
			For nIndex := 1 To nTotal
				If nIndex > 1
					Self:cFiliaisFiltro += "','"
				EndIf
				Self:cFiliaisFiltro += aFiliais[nIndex][1]
				aAdd(Self:aFiliaisTicket, aFiliais[nIndex][1])
			Next nIndex
			Self:cFiliaisFiltro += "'"
		Else
			aAdd(Self:aFiliaisTicket, xFilial("HWC"))
		EndIf

		Self:lDoTransfersMrp := paramTkt(cTicket,"doTransfersMrp") == "1"

	EndIf

Return Nil

/*/{Protheus.doc} executaQuerySMV
Executa a query na tabela SMV para buscar os registros de detalhes

@author lucas.franca
@since 26/04/2024
@version P12
@param 01 cBranchId, Caracter, Código da filial para filtro
@param 02 cProduto , Caracter, Código do produto da pesquisa
@param 03 cIdOpc   , Caracter, ID de Opcionais da pesquisa
@param 04 cDataAte , Caracter, Data que será utilizada para filtro dos dados
@return cAlias, Caracter, Alias da query
/*/
Method executaQuerySMV(cBranchId, cProduto, cIdOpc, cDataAte) Class MrpDetails
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cFiltroFil := ""

	If !Empty(cBranchId)
		cFiltroFil := " SMV.MV_FILIAL = '"+cBranchId+"'"
	Else
		cFiltroFil := " SMV.MV_FILIAL IN (" + Self:getFiliaisFiltro("SMV") + ")"
	EndIf

	cQuery += "SELECT MV_FILIAL, "
	cQuery +=       " MV_TICKET, "
	cQuery +=       " MV_PRODUT, "
	cQuery +=       " MV_IDOPC, "
	cQuery +=       " MV_DATAMRP, "
	cQuery +=       " MV_TIPDOC, "
	cQuery +=       " MV_DOCUM, "
	cQuery +=       " MV_TIPREG, "
	cQuery +=       " MV_TABELA, "
	cQuery +=       " MV_QUANT, "
	cQuery +=       " CASE "
	cQuery +=        " WHEN MV_TABELA = 'T4Q' THEN "
	cQuery +=            " (SELECT PAI.T4Q_PROD "
	cQuery +=               " FROM "+RetSqlName("T4Q")+" FILHO "
	cQuery +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuery +=                 " ON " + FwJoinFilial("T4Q", "T4Q", "FILHO", "PAI", .T.)
	cQuery +=                " AND FILHO.T4Q_OPPAI  = PAI.T4Q_OP "
	cQuery +=              " WHERE FILHO.T4Q_OP = MV_DOCUM ) "

	cQuery +=        " WHEN MV_TABELA = 'T4T' THEN "
	cQuery +=            " (SELECT PAI.T4Q_PROD "
	cQuery +=               " FROM "+RetSqlName("T4T")+" FILHO  "
	cQuery +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuery +=                 " ON " + FwJoinFilial("T4T", "T4Q", "FILHO", "PAI", .T.)
	cQuery +=                " AND FILHO.T4T_OP = PAI.T4Q_OP  "
	If mrpGrdT4T()
		cQuery +=              " WHERE FILHO.T4T_DOCUM = MV_DOCUM ) "
	Else
		cQuery +=              " WHERE FILHO.T4T_NUM || FILHO.T4T_SEQ = MV_DOCUM ) "
	EndIf

	cQuery +=        " WHEN MV_TABELA = 'T4U' THEN "
	cQuery +=            " (SELECT PAI.T4Q_PROD "
	cQuery +=               " FROM "+RetSqlName("T4U")+" FILHO  "
	cQuery +=              " INNER JOIN "+RetSqlName("T4Q")+" PAI  "
	cQuery +=                 " ON " + FwJoinFilial("T4U", "T4Q", "FILHO", "PAI", .T.)
	cQuery +=                " AND FILHO.T4U_OP     = PAI.T4Q_OP  "
	If mrpGrdT4T()
		cQuery +=              " WHERE FILHO.T4U_DOCUM = MV_DOCUM ) "
	Else
		cQuery +=              " WHERE FILHO.T4U_NUM || FILHO.T4U_SEQ = MV_DOCUM ) "
	EndIf

	cQuery +=        " ELSE ' ' "
	cQuery +=       " END PRODPAI, "
	cQuery +=       " CASE "
	cQuery +=        " WHEN MV_TABELA = 'T4Q' THEN "
	cQuery +=            " (SELECT T4Q.T4Q_LOCAL "
	cQuery +=               " FROM "+RetSqlName("T4Q")+" T4Q "
	cQuery +=              " WHERE T4Q.T4Q_OP = MV_DOCUM "
	cQuery +=                " AND " + FwJoinFilial("T4Q", "SMV", Nil, Nil, .F.) + ") "

	cQuery +=        " WHEN MV_TABELA = 'T4T' THEN "
	cQuery +=            " (SELECT T4T.T4T_LOCAL "
	cQuery +=               " FROM "+RetSqlName("T4T")+" T4T  "
	If mrpGrdT4T()
		cQuery +=              " WHERE T4T.T4T_DOCUM = MV_DOCUM "
	Else
		cQuery +=              " WHERE T4T.T4T_NUM || T4T.T4T_SEQ = MV_DOCUM "
	EndIf
	cQuery +=                " AND " + FwJoinFilial("T4T", "SMV", Nil, Nil, .F.) + ") "

	cQuery +=        " WHEN MV_TABELA = 'T4U' THEN "
	cQuery +=            " (SELECT T4U.T4U_LOCAL "
	cQuery +=               " FROM "+RetSqlName("T4U")+" T4U  "
	If mrpGrdT4T()
		cQuery +=       " WHERE T4U.T4U_DOCUM = MV_DOCUM "
	Else
		cQuery +=       " WHERE T4U.T4U_NUM || T4U.T4U_SEQ = MV_DOCUM "
	EndIf
	cQuery +=                " AND " + FwJoinFilial("T4U", "SMV", Nil, Nil, .F.) + ") "

	cQuery +=        " WHEN MV_TABELA = 'T4J' THEN "
	cQuery +=            " (SELECT T4J.T4J_LOCAL "
	cQuery +=               " FROM "+RetSqlName("T4J")+" T4J "
	cQuery +=              " WHERE T4J.T4J_IDREG = MV_DOCUM "
	cQuery +=                " AND " + FwJoinFilial("T4J", "SMV", Nil, Nil, .F.) + " ) "

	cQuery +=        " ELSE ' ' "
	cQuery +=       " END ARMAZEM, "
	cQuery +=       " HWM_EVENTO AS EVENT, "
	cQuery +=       " T4J_DOC, "
	cQuery +=       " T4J_REV "
	cQuery += " FROM ( SELECT SMV.MV_FILIAL,"
	cQuery +=               " SMV.MV_TICKET,"
	cQuery +=               " SMV.MV_PRODUT,"
	cQuery +=               " SMV.MV_IDOPC,"
	cQuery +=               " SMV.MV_DATAMRP,"
	cQuery +=               " SMV.MV_TIPDOC,"
	cQuery +=               " SMV.MV_DOCUM,"
	cQuery +=               " SMV.MV_TIPREG,"
	cQuery +=               " SMV.MV_TABELA,"
	cQuery +=               " SUM(SMV.MV_QUANT) AS MV_QUANT,"
	cQuery +=               " HWM.HWM_EVENTO,"
	cQuery +=               " T4J.T4J_DOC,"
	cQuery +=               " T4J.T4J_REV"
	cQuery +=          " FROM " + RetSqlName("SMV") + " SMV"

	cQuery +=          " LEFT JOIN " + RetSqlName("HWM") + " HWM"
	cQuery +=            " ON HWM.HWM_TICKET = SMV.MV_TICKET"
	cQuery +=           " AND " + FwJoinFilial("HWM", "SMV", "HWM", "SMV", .T.)
	cQuery +=           " AND RTRIM(HWM.HWM_DOC) = RTRIM(SMV.MV_DOCUM)"
	cQuery +=           " AND HWM.HWM_PRODUT = SMV.MV_PRODUT"
	cQuery +=           " AND HWM.HWM_ALIAS  = SMV.MV_TABELA"
	cQuery +=		   " AND HWM.HWM_EVENTO IN ('002','003','007')"
	cQuery +=           " AND HWM.D_E_L_E_T_ = ' '"
	//LEFT JOIN HWC_PMP/HWG_PMP/HWC_AGL para remover dos resultados as demandas consideradas como PMP
	cQuery +=          " LEFT JOIN " + RetSqlName("HWC") + " HWC_PMP"
	cQuery +=            " ON HWC_PMP.HWC_FILIAL = SMV.MV_FILIAL"
	cQuery +=           " AND HWC_PMP.HWC_TICKET = SMV.MV_TICKET"
	cQuery +=           " AND HWC_PMP.HWC_TPDCPA = '1'"
	cQuery +=           " AND HWC_PMP.HWC_DOCPAI = SMV.MV_DOCUM"
	cQuery +=           " AND HWC_PMP.D_E_L_E_T_ = ' '"
	cQuery +=           " AND SMV.MV_TABELA = 'T4J'"

	cQuery +=          " LEFT JOIN " + RetSqlName("HWG") + " HWG_PMP"
	cQuery +=            " ON HWG_PMP.HWG_FILIAL = SMV.MV_FILIAL"
	cQuery +=           " AND HWG_PMP.HWG_TICKET = SMV.MV_TICKET"
	cQuery +=           " AND HWG_PMP.HWG_DOCORI = SMV.MV_DOCUM"
	cQuery +=           " AND HWG_PMP.HWG_PROD   = SMV.MV_PRODUT"
	cQuery +=           " AND HWG_PMP.D_E_L_E_T_ = ' '"
	cQuery +=           " AND SMV.MV_TABELA = 'T4J'"

	cQuery +=          " LEFT JOIN " + RetSqlName("HWC") + " HWC_AGL"
	cQuery +=            " ON HWC_AGL.HWC_FILIAL = HWG_PMP.HWG_FILIAL"
	cQuery +=           " AND HWC_AGL.HWC_TICKET = HWG_PMP.HWG_TICKET"
	cQuery +=           " AND HWC_AGL.HWC_TPDCPA = '1'"
	cQuery +=           " AND HWC_AGL.HWC_DOCPAI = HWG_PMP.HWG_DOCAGL"
	cQuery +=           " AND HWC_AGL.D_E_L_E_T_ = ' '"

	cQuery +=          " LEFT JOIN " + RetSqlName("T4J") + " T4J "
	cQuery +=           " ON T4J.T4J_FILIAL = MV_FILIAL "
	cQuery +=          " AND T4J.T4J_PROD   = MV_PRODUT "
	cQuery +=          " AND T4J.T4J_IDREG  = MV_DOCUM "
	cQuery +=          " AND T4J.D_E_L_E_T_ = ' ' "

	cQuery +=         " WHERE " + cFiltroFil
	cQuery +=           " AND SMV.MV_TICKET  = '" + Self:cTicket  + "'"
	cQuery +=           " AND SMV.MV_PRODUT  = '" + cProduto      + "'"
	cQuery +=           " AND SMV.MV_IDOPC   = '" + cIdOpc        + "'"
	cQuery +=           " AND SMV.D_E_L_E_T_ = ' '"
	cQuery +=           " AND HWC_PMP.HWC_TICKET IS NULL"
	cQuery +=           " AND HWC_AGL.HWC_TICKET IS NULL"

	If !Empty(cDataAte)
		cQuery +=       " AND SMV.MV_DATAMRP <= '" + PCPConvDat(cDataAte, 6) + "'"
	EndIf

	cQuery +=      " GROUP BY SMV.MV_FILIAL,"
	cQuery +=               " SMV.MV_TICKET,"
	cQuery +=               " SMV.MV_PRODUT,"
	cQuery +=               " SMV.MV_IDOPC,"
	cQuery +=               " SMV.MV_DATAMRP,"
	cQuery +=               " SMV.MV_TIPDOC,"
	cQuery +=               " SMV.MV_DOCUM,"
	cQuery +=               " SMV.MV_TIPREG,"
	cQuery +=               " SMV.MV_TABELA,"
	cQuery +=               " HWM.HWM_EVENTO,"
	cQuery +=               " T4J.T4J_DOC,"
	cQuery +=               " T4J.T4J_REV ) INTERNO"

	If "MSSQL" $ Self:cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)
	TcSetField(cAlias, "MV_QUANT", "N", Self:nTamQtd, Self:nDecQtd)

Return cAlias

/*/{Protheus.doc} executaQueryHWC
Executa a query na tabela HWC para buscar os registros de detalhes

@author lucas.franca
@since 26/04/2024
@version P12
@param 01 cBranchId, Caracter, Código da filial para filtro
@param 02 cProduto , Caracter, Código do produto da pesquisa
@param 03 cIdOpc   , Caracter, ID de Opcionais da pesquisa
@param 04 cDataAte , Caracter, Data que será utilizada para filtro dos dados
@return cAlias, Caracter, Alias da query
/*/
Method executaQueryHWC(cBranchId, cProduto, cIdOpc, cDataAte) Class MrpDetails
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cFiltroFil := ""

	If !Empty(cBranchId)
		cFiltroFil := " HWC.HWC_FILIAL = '"+cBranchId+"'"
	Else
		cFiltroFil := " HWC.HWC_FILIAL IN (" + Self:getFiliaisFiltro("HWC") + ")"
	EndIf

	cQuery := "SELECT HWC.HWC_FILIAL,"
	cQuery +=       " HWC.HWC_TICKET,"
	cQuery +=       " HWC.HWC_PRODUT,"
	cQuery +=       " HWC.HWC_IDOPC,"
	cQuery +=       " HWC.HWC_DATA,"
	cQuery +=       " HWC.HWC_TPDCPA,"
	cQuery +=       " HWC.HWC_DOCPAI,"
	cQuery +=       " HWC.HWC_DOCERP,"
	cQuery +=       " HWC.HWC_TDCERP,"
	cQuery +=       " HWC.HWC_QTNEOR,"
	cQuery +=       " HWC.HWC_QTNECE,"
	cQuery +=       " HWC.HWC_QTRSAI,"
	cQuery +=       " HWC.HWC_QTRENT,"
	cQuery +=       " HWC.HWC_DOCFIL,"
	cQuery +=       " HWB.HWB_NIVEL,"
	cQuery +=       " PAI.HWC_PRODUT PROD_PAI,"
	cQuery +=       " HWC.R_E_C_N_O_,"
	cQuery +=       " HWC.HWC_LOCAL,"
	cQuery +=       " PAI.HWC_DOCERP DOCERP_PAI"

	If Self:lPossuiHWC_AGLUT
		cQuery +=   " ,HWC.HWC_AGLUT "
	Else
		cQuery +=   " ,' ' HWC_AGLUT "
	EndIf

	cQuery +=  " FROM " + RetSqlName("HWC") + " HWC "
	cQuery += " INNER JOIN " + RetSqlName("HWB") + " HWB "
	cQuery +=    " ON HWC.HWC_FILIAL = HWB.HWB_FILIAL"
	cQuery +=   " AND HWC.HWC_TICKET = HWB.HWB_TICKET"
	cQuery +=   " AND HWC.HWC_DATA   = HWB.HWB_DATA"
	cQuery +=   " AND HWC.HWC_PRODUT = HWB.HWB_PRODUT"
	cQuery +=   " AND HWC.HWC_IDOPC  = HWB.HWB_IDOPC"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("HWC") + " PAI"
	cQuery +=    " ON PAI.HWC_FILIAL = HWC.HWC_FILIAL"
	cQuery +=   " AND PAI.HWC_TICKET = HWC.HWC_TICKET"
	cQuery +=   " AND RTRIM(PAI.HWC_DOCFIL) = RTRIM(HWC.HWC_DOCPAI)"
	cQuery +=   " AND PAI.D_E_L_E_T_ = ' '"

	cQuery += " WHERE " + cFiltroFil
	cQuery +=   " AND HWC.HWC_TICKET = '" + Self:cTicket + "'"
	cQuery +=   " AND HWC.HWC_PRODUT = '" + cProduto     + "'"
	cQuery +=   " AND HWC.HWC_IDOPC  = '" + cIdOpc       + "'"
	cQuery +=   " AND HWC.D_E_L_E_T_ = ' '"

	If !Empty(cDataAte)
		cQuery += " AND HWC.HWC_DATA <= '" + PCPConvDat(cDataAte, 6) + "'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	TcSetField(cAlias, "HWC_QTNEOR", "N", Self:nTamQtd, Self:nDecQtd)
	TcSetField(cAlias, "HWC_QTNECE", "N", Self:nTamQtd, Self:nDecQtd)
	TcSetField(cAlias, "HWC_QTRSAI", "N", Self:nTamQtd, Self:nDecQtd)
	TcSetField(cAlias, "HWC_QTRENT", "N", Self:nTamQtd, Self:nDecQtd)

Return cAlias

/*/{Protheus.doc} executaQueryAglutinadosHWC
Executa a query na tabela HWC para buscar os registros aglutinados de detalhes

@author lucas.franca
@since 26/04/2024
@version P12
@param 01 cBranchId, Caracter, Código da filial para filtro
@param 02 cProduto , Caracter, Código do produto da pesquisa
@param 03 cIdOpc   , Caracter, ID de Opcionais da pesquisa
@param 04 cDataAte , Caracter, Data que será utilizada para filtro dos dados
@return cAlias, Caracter, Alias da query
/*/
Method executaQueryAglutinadosHWC(cBranchId, cProduto, cIdOpc, cDataAte) Class MrpDetails
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cFiltroFil := ""

	If !Empty(cBranchId)
		cFiltroFil := " OP.HWC_FILIAL = '"+cBranchId+"'"
	Else
		cFiltroFil := " OP.HWC_FILIAL IN (" + Self:getFiliaisFiltro("HWC") + ")"
	EndIf

	cQuery := "SELECT OP.HWC_FILIAL,"
	cQuery +=       " OP.HWC_TICKET,"
	cQuery +=       " OP.HWC_PRODUT,"
	cQuery +=       " OP.HWC_IDOPC,"
	cQuery +=       " OP.HWC_DATA,"
	cQuery +=       " OP.HWC_TPDCPA,"
	cQuery +=       " OP.HWC_DOCPAI,"
	cQuery +=       " OP.HWC_DOCERP,"
	cQuery +=       " OP.HWC_TDCERP,"
	cQuery +=       " OP.HWC_QTEMPE,"
	cQuery +=       " OP.HWC_QTNECE,"
	cQuery +=       " PAI.HWC_PRODUT PROD_PAI,"
	cQuery +=       " HWB.HWB_NIVEL,"
 	cQuery +=       " OP.R_E_C_N_O_,"
	cQuery +=       " OP.HWC_QTNEOR,"
	cQuery +=       " OP.HWC_LOCAL,"

	If vldAglut(cProduto, Self:cTicket)
		cQuery +=   " ' ' opEmpenhada "
	Else
		cQuery += " PAI.HWC_DOCERP opEmpenhada "
	EndIf

	cQuery +=  " FROM " + RetSqlName("HWC") + " OP"
	cQuery += " INNER JOIN " + RetSqlName("HWB") + " HWB"
	cQuery +=    " ON HWB.HWB_FILIAL = OP.HWC_FILIAL"
	cQuery +=   " AND HWB.HWB_TICKET = OP.HWC_TICKET"
	cQuery +=   " AND HWB.HWB_DATA   = OP.HWC_DATA"
	cQuery +=   " AND HWB.HWB_PRODUT = OP.HWC_PRODUT"
	cQuery +=   " AND HWB.HWB_IDOPC  = OP.HWC_IDOPC"
	cQuery +=   " AND HWB.D_E_L_E_T_ = ' ' "
	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("HWC") + " PAI"
	cQuery +=    " ON PAI.HWC_FILIAL = OP.HWC_FILIAL"
	cQuery +=   " AND PAI.HWC_TICKET = OP.HWC_TICKET"
	cQuery +=   " AND RTRIM(PAI.HWC_DOCFIL) = RTRIM(OP.HWC_DOCPAI)"
	cQuery +=   " AND PAI.D_E_L_E_T_ = ' '"
	cQuery += " WHERE " + cFiltroFil
	cQuery +=   " AND OP.HWC_TICKET = '" + Self:cTicket  + "'"
	cQuery +=   " AND OP.HWC_PRODUT = '" + cProduto      + "'"
	cQuery +=   " AND OP.HWC_TPDCPA IN ('OP','AGL')"
	cQuery +=   " AND OP.HWC_IDOPC = '" + cIdOpc + "'"
	cQuery +=   " AND OP.D_E_L_E_T_ = ' '"

	If !Empty(cDataAte)
		cQuery += " AND OP.HWC_DATA <= '" + PCPConvDat(cDataAte, 6) + "'"
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	TcSetField(cAlias, "HWC_QTEMPE", "N", Self:nTamQtd, Self:nDecQtd)
	TcSetField(cAlias, "HWC_QTNECE", "N", Self:nTamQtd, Self:nDecQtd)

Return cAlias

/*/{Protheus.doc} getFiliaisFiltro
Retorna os códigos de filial para filtrar nas querys.

@author lucas.franca
@since 26/04/2024
@version P12
@param cTabela, Caracter, Tabela para aplicar o filtro
@return cFiltro, Caracter, Filtro com o código das filiais
/*/
Method getFiliaisFiltro(cTabela) Class MrpDetails
	Local cFiltro := ""

	If Self:lUsaMultiEmpresa
		cFiltro := Self:cFiliaisFiltro
	Else
		cFiltro := "'" + xFilial(cTabela) + "'"
	EndIf

Return cFiltro


/*/{Protheus.doc} GET DETAILS api/pcp/v1/mrpdetails/{ticket}/{product}
Retorna os detalhes dos resultados do mrp

@type WSMETHOD
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 ticket     , Caracter, código único do processo para fazer a pesquisa
@param 02 product    , Caracter, código do produto
@param 03 branchId   , Caracter, filial considerada no filtro
@param 04 periodFrom , Caracter, periodo inicial do calculo a ser considerado
@param 05 periodTo   , Caracter, periodo final do calculo a ser considerado
@param 06 idOpc      , Caracter, identificador do opcional
@param 07 document   , Caracter, identificador do documento considerado no filtro
@param 08 type       , Caracter, tipo de registro considerado no filtro
@return   lRet       , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET DETAILS PATHPARAM ticket, product WSRECEIVE branchId, periodFrom, periodTo, idOpc, document, type WSSERVICE mrpdetails
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getResDet(Self:ticket, decodeUTF8(Self:product), Self:branchId, Self:periodFrom, Self:periodTo, Self:idOpc, Self:document, Self:type)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} getResDet
Retorna os detalhes dos resultados do mrp

@type Function
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 cTicket   , Caracter, código único do processo
@param 02 cProduct  , Caracter, código do produto
@param 03 cBranchId , Caracter, código da filial
@param 04 cPerFrom  , Caracter, código inicial do filtro de periodo
@param 05 cPerTo    , Caracter, código final do filtro de periodo
@param 06 cIdOpc    , Caracter, identificador do opcional
@param 07 cDocument , Caracter, documento considerado no filtro
@param 08 cTypeReg  , Caracter, tipo de registro
@return   aReturn   , Array   , Array com as informacoes da requisicao
/*/
Function getResDet(cTicket, cProduct, cBranchId, cPerFrom, cPerTo, cIdOpc, cDocument, cTypeReg)
	Local aDadosSP   := {}
	Local aResult    := {}
	Local aCalculo   := {}
	Local aReturn    := {}
	Local aFilsSaldo := {}
	Local cTipos     := ""
	Local cTiposFil  := ""
	Local cAliasHWC  := ""
	Local cAliasSMV  := ""
	Local cContrData := ""
	Local cDocStatus := ""
	Local cDocType   := ""
	Local cDocumento := ""
	Local cHWCDocPai := ""
	Local cHWCDocFil := ""
	Local cOpEmp     := ""
	Local cProdPai   := ""
	Local cRecno     := ""
	Local cRegOrder  := ""
	Local cType      := ""
	Local lGerouDoc  := gerouDoc(cTicket)
	Local nIndCalc   := 0
	Local nIndSaldo  := 0
	Local nIndResult := 0
	Local nPosDivPai := 0
	Local nQtCalc    := 0
	Local nQuant     := 0
	Local nPos       := 0
	Local nTotal     := 0
	Local nTotSaldo  := 0
	Local oJsonRet   := JsonObject():New()
	Local oJsonAGL   := JsonObject():New()
	Local oJsDocTran := JsonObject():New()
	Local oJsDocDem  := JsonObject():New()
	Local oTranfAgl  := JsonObject():New()
	Local oSaldoFil  := JsonObject():New()
	Local oQtdSaiTra := JsonObject():New()

	Default cIdOpc   := ""

	If _oMrpDet == Nil
		_oMrpDet := MrpDetails():New()
	EndIf

	If !_oMrpDet:lPossuiTabelaSMV
		aAdd(aReturn, .F.)
		aAdd(aReturn, STR0005) //"Tabela SMV não existe no dicionário de dados"
		aAdd(aReturn, 400)
		FreeObj(oJsonRet)
		Return aReturn
	EndIf

	cTipos    := "|"+_oMrpDet:cTipoEstSeguranca+"|"+_oMrpDet:cTipoPontoPedido+"|Pré-OP|SUBPRD|ESTNEG|TRANF_PR|LTVENC|0|1|2|3|4|5|9|"
	cTiposFil := "|"+_oMrpDet:cTipoEstSeguranca+"|"+_oMrpDet:cTipoPontoPedido+"|SUBPRD|ESTNEG|"
	// Se cIdOpc estiver vazio, seta com um espaço em branco para buscar corretamente em banco de dados ORACLE.
	If Empty(cIdOpc)
		cIdOpc := " "
	EndIf

	_oMrpDet:carregaParametroTicket(cTicket)

	nPos      := 0
	cAliasSMV := _oMrpDet:executaQuerySMV(cBranchId, cProduct, cIdOpc, cPerTo)
	While (cAliasSMV)->(!Eof())
		nPos++
		cRecno     := StrZero(nPos, 10)
		cDocumento := (cAliasSMV)->MV_DOCUM
		cProdPai   := (cAliasSMV)->PRODPAI
		cDocStatus := ""
		Do Case
			Case (cAliasSMV)->MV_TABELA == "T4V" // Saldo Inicial
				cRegOrder := "|00|"
				cDocType  := "SI"

			Case Trim((cAliasSMV)->MV_TABELA) == "ET" // Em Terceiro
				cRegOrder := "|01|"
				cDocType  := "ET"

			Case Trim((cAliasSMV)->MV_TABELA) == "DT" //De Terceiro
				cRegOrder := "|02|"
				cDocType  := "DT"

			Case Trim((cAliasSMV)->MV_TABELA) == "SB" //Saldo Bloqueado
				cRegOrder := "|03|"
				cDocType  := "SB"

			Case (cAliasSMV)->MV_TABELA == "HWX" //Saldo Rejeitado
				cRegOrder := "|04|"
				cDocType  := "SR"

			Case (cAliasSMV)->MV_TABELA == "T4S" //Empenho
				cRegOrder  := "|11|"
				cDocType   := "EM"
				nPosDivPai := At("|", cDocumento)
				cProdPai   := Left(cDocumento, (nPosDivPai-1))
				cDocumento := opEmp(AllTrim((cAliasSMV)->MV_DOCUM))
				cDocStatus := IIf((cAliasSMV)->MV_TIPDOC == "4", "F", "P")

			Case (cAliasSMV)->MV_TABELA == "T4J" //"Demanda
				cRegOrder := "|12|"
				cDocType  := "DM"
				oJsDocDem[RTrim((cAliasSMV)->MV_DOCUM)] := trataDcDem(RTrim((cAliasSMV)->MV_DOCUM), _oMrpDet:lUsaMultiEmpresa, (cAliasSMV)->T4J_DOC, (cAliasSMV)->T4J_REV)

			Case (cAliasSMV)->MV_TABELA == "T4Q" //Ordem de Produção
				cRegOrder  := "|13|"
				cDocType   := "OP"
				cDocStatus := IIf((cAliasSMV)->MV_TIPDOC == "1", "F", "P")

			Case (cAliasSMV)->MV_TABELA == "T4T" //Solicitação de Compra
				cRegOrder  := "|14|"
				cDocType   := "SC"
				cDocStatus := IIf((cAliasSMV)->MV_TIPDOC == "2", "F", "P")

			Case (cAliasSMV)->MV_TABELA == "T4U" //Pedido de Compra ou Autorização de Entrega
				cRegOrder  := "|15|"
				cDocType   := IIf((cAliasSMV)->MV_TIPDOC $ "3|C","PC","AU")
				cDocStatus := IIf((cAliasSMV)->MV_TIPDOC $ "3|E", "F", "P")

			Otherwise
				cRegOrder := "|16|"
				cDocType  := (cAliasSMV)->MV_TIPDOC
		EndCase

		addToCalc(@aCalculo                               , ;
		          (cAliasSMV)->MV_DATAMRP+cRegOrder+cRecno, ;
		          (cAliasSMV)->MV_FILIAL                  , ;
		          (cAliasSMV)->MV_TICKET                  , ;
		          (cAliasSMV)->MV_PRODUT                  , ;
		          (cAliasSMV)->MV_IDOPC                   , ;
		          (cAliasSMV)->MV_DATAMRP                 , ;
		          cDocType                                , ;
		          cDocumento                              , ;
		          cProdPai                                , ;
		          (cAliasSMV)->MV_TIPREG                  , ;
		          (cAliasSMV)->MV_QUANT                   , ;
		          ""                                      , ;
		          cDocStatus                              , ;
		          (cAliasSMV)->ARMAZEM                    , ;
		          (cAliasSMV)->EVENT                      , ;
				  cDocumento)
		(cAliasSMV)->(dbSkip())
	End
	(cAliasSMV)->(dbCloseArea())

	nPos      := 0
	cAliasHWC := _oMrpDet:executaQueryHWC(cBranchId, cProduct, cIdOpc, cPerTo)
	While (cAliasHWC)->(!Eof())
		cRecno     := cValToChar((cAliasHWC)->R_E_C_N_O_)
		cProdPai   := (cAliasHWC)->PROD_PAI
		cDocType   := getDocType((cAliasHWC)->HWB_NIVEL, (cAliasHWC)->HWC_TDCERP)
		cDocStatus := getDocStat((cAliasHWC)->HWC_TDCERP)
		cHWCDocPai := RTrim((cAliasHWC)->HWC_DOCPAI)
		cHWCDocFil := RTrim((cAliasHWC)->HWC_DOCFIL)

		If docTranf(cHWCDocFil)
			oJsDocTran[cHWCDocFil] := {cHWCDocPai, "", RTrim((cAliasHWC)->DOCERP_PAI), (cAliasHWC)->HWC_FILIAL, Iif(oQtdSaiTra:HasProperty(cHWCDocFil), oQtdSaiTra[cHWCDocFil], (cAliasHWC)->HWC_QTNECE)}
			If Trim((cAliasHWC)->HWC_TPDCPA) $ cTiposFil
				oJsDocTran[cHWCDocFil][2] := RTrim((cAliasHWC)->HWC_FILIAL)
			EndIf
		EndIf

		If !oSaldoFil:HasProperty((cAliasHWC)->HWC_FILIAL)
			oSaldoFil[(cAliasHWC)->HWC_FILIAL] := 0
		EndIf
		oSaldoFil[(cAliasHWC)->HWC_FILIAL] -= (cAliasHWC)->HWC_QTRSAI
		oSaldoFil[(cAliasHWC)->HWC_FILIAL] += (cAliasHWC)->HWC_QTRENT

		/*
			Valida se o registro deve ser exibido na lista conforme o tipo de documento pai.
			A validação está aqui e não na query, pois todos os tipos devem gerar o json
			de controle "oJsDocTran".
		*/
		If ("|" + Trim((cAliasHWC)->HWC_TPDCPA) + "|" $ cTipos) == .F.
		    (cAliasHWC)->(dbSkip())
		    Loop
		EndIf

		Do Case
			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == _oMrpDet:cTipoEstSeguranca //"Est.Seg."
				cType    := "|10|"
				cDocType := "ES"

				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,STR0004, cProdPai, "2", (cAliasHWC)->HWC_QTNEOR, cHWCDocPai, (cAliasHWC)->HWC_LOCAL) //"Segurança"

				cType    := "|20|"
				cDocType := getDocType((cAliasHWC)->HWB_NIVEL, (cAliasHWC)->HWC_TDCERP)
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai ,"1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "Pré-OP"
				cType    := "|21|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "1"//Plano mestre
				cType    := "|19|"
				cDocType := "PM"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) $ "0|2|3|4|5|9"
				cType    := "|22|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "SUBPRD"
				cType    := "|17|"
				cDocType := "SU"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType,IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "ESTNEG"
				cType    := "|18|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == _oMrpDet:cTipoPontoPedido //"Ponto Ped."
				cType    := "|30|"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "TRANF_PR"
				If Empty((cAliasHWC)->HWC_AGLUT)
					cType    := "|24|"
					If _oMrpDet:lDoTransfersMrp
						cDocType := "TR"
					EndIf
					addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP) , cProdPai, "1", (cAliasHWC)->HWC_QTNECE, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

					If oJsDocTran:HasProperty(cHWCDocPai)
						oJsDocTran[cHWCDocPai][5] += (cAliasHWC)->HWC_QTRSAI

					ElseIf docTranf(cHWCDocPai)
						oQtdSaiTra[cHWCDocPai] := (cAliasHWC)->HWC_QTRSAI

					EndIf
				Else
					oTranfAgl[Trim((cAliasHWC)->HWC_AGLUT)] := .T.
				EndIf

			Case AllTrim((cAliasHWC)->HWC_TPDCPA) == "LTVENC"
				cType    := "|01|"
				cDocType := "LV"
				addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA,cDocType, fmtLtVenc(cHWCDocPai), "", "2", (cAliasHWC)->HWC_QTNEOR, cHWCDocPai, "", (cAliasHWC)->HWC_LOCAL)
		EndCase

		(cAliasHWC)->(dbSkip())
	End
	(cAliasHWC)->(dbCloseArea())

	cAliasHWC := _oMrpDet:executaQueryAglutinadosHWC(cBranchId, cProduct, cIdOpc, cPerTo)
	While (cAliasHWC)->(!Eof())
		cOpEmp     := (cAliasHWC)->(opEmpenhada)
		cRecno     := cValToChar((cAliasHWC)->R_E_C_N_O_)
		cProdPai   := (cAliasHWC)->PROD_PAI
		cDocStatus := getDocStat((cAliasHWC)->HWC_TDCERP)
		cHWCDocPai := RTrim((cAliasHWC)->HWC_DOCPAI)

		If Empty(cOpEmp)
			cOpEmp := " "
		EndIf

		nQuant   := (cAliasHWC)->HWC_QTEMPE
		cType    := "|11|"
		cDocType := "EM"
		addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA, cDocType,Iif( lGerouDoc, cOpEmp, cHWCDocPai), cProdPai, "2", nQuant, cHWCDocPai, cDocStatus, (cAliasHWC)->HWC_LOCAL)

		nQuant   := (cAliasHWC)->HWC_QTNECE
		cType    := "|23|"
		cDocType := getDocType((cAliasHWC)->HWB_NIVEL, (cAliasHWC)->HWC_TDCERP)

		If oTranfAgl:HasProperty(cHWCDocPai)
			cDocType := "OT"
		EndIf

		addToCalc(@aCalculo, (cAliasHWC)->HWC_DATA+cType+cRecno, (cAliasHWC)->HWC_FILIAL, (cAliasHWC)->HWC_TICKET, (cAliasHWC)->HWC_PRODUT, (cAliasHWC)->HWC_IDOPC, (cAliasHWC)->HWC_DATA, cDocType, IIF(Empty((cAliasHWC)->HWC_DOCERP), cHWCDocPai, (cAliasHWC)->HWC_DOCERP), cProdPai, "1", nQuant, Iif(lGerouDoc .And. !Empty(cOpEmp), cOpEmp, cHWCDocPai), cDocStatus, (cAliasHWC)->HWC_LOCAL)

		(cAliasHWC)->(dbSkip())
	End
	(cAliasHWC)->(dbCloseArea())

	//Ordena resultados pela chave
	If Len(aCalculo) > 0
		aCalculo := aSort( aCalculo,,, { | x,y | x[1] < y[1] })

		cContrData := aCalculo[1][6]//inicializa controle de datas
	EndIf

	For nIndCalc := 1 To Len(aCalculo)
		If cContrData != aCalculo[nIndCalc][ARRAY_POS_PERIODO]
			//A cada mudança de data incluir saldo do período no array
			aDadosSP := Array(ARRAY_POS_SIZE)

			aDadosSP[ARRAY_POS_CHAVE           ] := aCalculo[nIndCalc][ARRAY_POS_CHAVE]
			aDadosSP[ARRAY_POS_EMPRESA         ] := " "
			aDadosSP[ARRAY_POS_TICKET          ] := aCalculo[nIndCalc][ARRAY_POS_TICKET]
			aDadosSP[ARRAY_POS_PRODUTO         ] := aCalculo[nIndCalc][ARRAY_POS_PRODUTO]
			aDadosSP[ARRAY_POS_ID_OPCIONAL     ] := aCalculo[nIndCalc][ARRAY_POS_ID_OPCIONAL]
			aDadosSP[ARRAY_POS_PERIODO         ] := aCalculo[nIndCalc][ARRAY_POS_PERIODO]
			aDadosSP[ARRAY_POS_TIPO_DOCUMENTO  ] := "SP"
			aDadosSP[ARRAY_POS_CODIGO_DOCUMENTO] := " "
			aDadosSP[ARRAY_POS_PRODUTO_PAI     ] := " "
			aDadosSP[ARRAY_POS_TIPO_REGISTRO   ] := "4"
			aDadosSP[ARRAY_POS_QUANTIDADE      ] := Nil
			aDadosSP[ARRAY_POS_DOC_MRP         ] := " "
			aDadosSP[ARRAY_POS_STATUS_DOCUMENTO] := ""
			aDadosSP[ARRAY_POS_QTD_TOTAL       ] := nQtCalc
			aDadosSP[ARRAY_POS_EVENT           ] := ""
			aDadosSP[ARRAY_POS_DOCUMENTO_FILTRO] := ""
			aDadosSP[ARRAY_POS_DETALHA_SALDO   ] := {''}

			aAdd(aResult, aDadosSP)

			cContrData := aCalculo[nIndCalc][ARRAY_POS_PERIODO]
		EndIf

		If !oSaldoFil:HasProperty(aCalculo[nIndCalc][ARRAY_POS_EMPRESA])
			oSaldoFil[aCalculo[nIndCalc][ARRAY_POS_EMPRESA]] := 0
		EndIf

		If aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "1" .Or. aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "3"
			nQtCalc += aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]
			oSaldoFil[aCalculo[nIndCalc][ARRAY_POS_EMPRESA]] += aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]

		ElseIf aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] == "2"
			nQtCalc -= aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]
			oSaldoFil[aCalculo[nIndCalc][ARRAY_POS_EMPRESA]] -= aCalculo[nIndCalc][ARRAY_POS_QUANTIDADE]
		EndIf

		nQtCalc := Round(nQtCalc, _oMrpDet:nDecQtd)

		//Filtros
		If !Empty(cPerFrom) .And. aCalculo[nIndCalc][ARRAY_POS_PERIODO] < cPerFrom
			Loop
		EndIf
		If !Empty(cTypeReg) .And. aCalculo[nIndCalc][ARRAY_POS_TIPO_REGISTRO] != cTypeReg
			Loop
		EndIf
		If !Empty(cDocument) .And. aCalculo[nIndCalc][ARRAY_POS_CODIGO_DOCUMENTO] != cDocument
			Loop
		EndIf

		aCalculo[nIndCalc][ARRAY_POS_QTD_TOTAL] := nQtCalc
		aAdd(aResult, aCalculo[nIndCalc])

		//Limpa array aCalculo
		aCalculo[nIndCalc] := Nil

	Next nIndCalc

	//Ao final, inclui o saldo restante
	aDadosSP := Array(ARRAY_POS_SIZE)
	aDadosSP[ARRAY_POS_CHAVE           ] := "SALDO_FINAL"
	aDadosSP[ARRAY_POS_EMPRESA         ] := " "
	aDadosSP[ARRAY_POS_TICKET          ] := cTicket
	aDadosSP[ARRAY_POS_PRODUTO         ] := cProduct
	aDadosSP[ARRAY_POS_ID_OPCIONAL     ] := cIdOpc
	aDadosSP[ARRAY_POS_PERIODO         ] := cPerTo
	aDadosSP[ARRAY_POS_TIPO_DOCUMENTO  ] := "SF"
	aDadosSP[ARRAY_POS_CODIGO_DOCUMENTO] := " "
	aDadosSP[ARRAY_POS_PRODUTO_PAI     ] := " "
	aDadosSP[ARRAY_POS_TIPO_REGISTRO   ] := "4"
	aDadosSP[ARRAY_POS_QUANTIDADE      ] := Nil
	aDadosSP[ARRAY_POS_DOC_MRP         ] := " "
	aDadosSP[ARRAY_POS_STATUS_DOCUMENTO] := ""
	aDadosSP[ARRAY_POS_QTD_TOTAL       ] := nQtCalc
	aDadosSP[ARRAY_POS_EVENT           ] := ""
	aDadosSP[ARRAY_POS_DOCUMENTO_FILTRO] := ""
	aDadosSP[ARRAY_POS_DETALHA_SALDO   ] := {"detailBalance"}

	aAdd(aResult, aDadosSP)

	getHWG(cTicket, cProduct, @oJsonAGL, _oMrpDet:lUsaMultiEmpresa)

	oJsonRet["items"  ] := {}
	oJsonRet["hasNext"] := .F.
	nTotal              := Len(aResult)

	//preenche json de resultados
	For nIndResult := 1 To nTotal

		aAdd(oJsonRet["items"], JsonObject():New())
		nPos++

		oJsonRet["items"][nPos]["branchId"      ] := aResult[nIndResult][ARRAY_POS_EMPRESA]
		oJsonRet["items"][nPos]["ticket"        ] := aResult[nIndResult][ARRAY_POS_TICKET]
		oJsonRet["items"][nPos]["product"       ] := aResult[nIndResult][ARRAY_POS_PRODUTO]
		oJsonRet["items"][nPos]["optionalId"    ] := aResult[nIndResult][ARRAY_POS_ID_OPCIONAL]
		oJsonRet["items"][nPos]["periodDate"    ] := aResult[nIndResult][ARRAY_POS_PERIODO]
		oJsonRet["items"][nPos]["documentType"  ] := aResult[nIndResult][ARRAY_POS_TIPO_DOCUMENTO]
		oJsonRet["items"][nPos]["documentCode"  ] := aResult[nIndResult][ARRAY_POS_CODIGO_DOCUMENTO]
		oJsonRet["items"][nPos]["fatherProduct" ] := aResult[nIndResult][ARRAY_POS_PRODUTO_PAI]
		oJsonRet["items"][nPos]["registerType"  ] := aResult[nIndResult][ARRAY_POS_TIPO_REGISTRO]
		oJsonRet["items"][nPos]["quantity"      ] := aResult[nIndResult][ARRAY_POS_QUANTIDADE]
		oJsonRet["items"][nPos]["balance"       ] := aResult[nIndResult][ARRAY_POS_QTD_TOTAL]
		oJsonRet["items"][nPos]["documentStatus"] := aResult[nIndResult][ARRAY_POS_STATUS_DOCUMENTO]
		oJsonRet["items"][nPos]["warehouse"     ] := aResult[nIndResult][ARRAY_POS_LOCAL]
		oJsonRet["items"][nPos]["iconEvent"     ] := aResult[nIndResult][ARRAY_POS_EVENT]
		oJsonRet["items"][nPos]["documentFilter"] := aResult[nIndResult][ARRAY_POS_DOCUMENTO_FILTRO]
		oJsonRet["items"][nPos]["detailBalance" ] := aResult[nIndResult][ARRAY_POS_DETALHA_SALDO]

		If oJsDocDem:HasProperty(oJsonRet["items"][nPos]["documentCode"])
			oJsonRet["items"][nPos]["documentCode"] := oJsDocDem[oJsonRet["items"][nPos]["documentCode"]]
		EndIf

		cDocumento := aResult[nIndResult][ARRAY_POS_DOC_MRP]

		If docTranf(cDocumento) .And. oJsDocTran:HasProperty(cDocumento)
			//Se for um documento de transferência, altera para buscar os detalhes do
			//documento que originou a transferência na filial de origem
			cDocumento := oJsDocTran[cDocumento][1]
		EndIf

		If oJsonAGL:HasProperty(cDocumento)
			If docTranf(cDocumento)
				//Caso o documento de transferência tenha sido aglutinado, busca as origens existentes a partir de oJsonAGL
				oJsonRet["items"][nPos]["detail"] := detTrfAgl(cTicket, cDocumento, @oJsonAGL)
			Else
				oJsonRet["items"][nPos]["detail"] := oJsonAGL[cDocumento]
			EndIf

			If !Empty(oJsonAGL[cDocumento][1]["tipoOrigem"])
				oJsonRet["items"][nPos]["documentStatus"] := getDocStat(oJsonAGL[cDocumento][1]["tipoOrigem"])
			EndIf

			If Len(oJsonAGL[cDocumento]) == 1
				oJsonRet["items"][nPos]["fatherProduct"] := oJsonAGL[cDocumento][1]["prodOrigem"]
			EndIf

		ElseIf SUBSTR(cDocumento, 0, 3) == 'AGL'
			oJsonRet["items"][nPos]["detail"] := buscaAgl(cDocumento, cTicket, oJsonAGL)

		ElseIf aResult[nIndResult][ARRAY_POS_TIPO_DOCUMENTO] == "TR" .Or. "|24|" $ aResult[nIndResult][ARRAY_POS_CHAVE]
			oJsonRet["items"][nPos]["detail"] := {JsonObject():New()}
			oJsonRet["items"][nPos]["detail"][1]["prodOrigem"] := RTrim(aResult[nIndResult][ARRAY_POS_PRODUTO])
			oJsonRet["items"][nPos]["detail"][1]["quantidade"] := aResult[nIndResult][ARRAY_POS_QUANTIDADE]
			oJsonRet["items"][nPos]["detail"][1]["docOrigem" ] := cDocumento

			If oJsDocTran:HasProperty(aResult[nIndResult][ARRAY_POS_DOC_MRP])
				If !Empty(oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][3])
					oJsonRet["items"][nPos]["detail"][1]["docOrigem"] := oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][3]
				EndIf

				oJsonRet["items"][nPos]["detail"][1]["quantidade"] := oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][5]

				If !Empty(oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][2])
					oJsonRet["items"][nPos]["detail"][1]["docOrigem"] := STR0010 + ": " + ; //Filial
					                                                     oJsDocTran[aResult[nIndResult][ARRAY_POS_DOC_MRP]][2] + ;
					                                                     "| " + RTrim(oJsonRet["items"][nPos]["detail"][1]["docOrigem"])
				EndIf
			EndIf

		ElseIf aResult[nIndResult][ARRAY_POS_TIPO_REGISTRO] == "1" .And.;
		       !Empty(aResult[nIndResult][ARRAY_POS_DOC_MRP])      .And.;
		       RTrim(aResult[nIndResult][ARRAY_POS_DOC_MRP]) <> RTrim(aResult[nIndResult][ARRAY_POS_CODIGO_DOCUMENTO])
			//Caso não aglutine, verifica se o doc entrada é uma OP real, e adiciona como detalhe a demanda que originou a necessidade
			oJsonRet["items"][nPos]["detail"] := {JsonObject():New()}
			oJsonRet["items"][nPos]["detail"][1]["prodOrigem"] := RTrim(aResult[nIndResult][ARRAY_POS_PRODUTO])
			oJsonRet["items"][nPos]["detail"][1]["quantidade"] := aResult[nIndResult][ARRAY_POS_QUANTIDADE]
			oJsonRet["items"][nPos]["detail"][1]["docOrigem" ] := aResult[nIndResult][ARRAY_POS_DOC_MRP]

		ElseIf aResult[nIndResult][ARRAY_POS_TIPO_DOCUMENTO] == "SF"
			aFilsSaldo := oSaldoFil:GetNames()
			nTotSaldo  := Len(aFilsSaldo)
			aFilsSaldo := aSort(aFilsSaldo, 1)

			oJsonRet["items"][nPos]["detailsBalance"] := Array(nTotSaldo)

			For nIndSaldo := 1 To nTotSaldo
				oJsonRet["items"][nPos]["detailsBalance"][nIndSaldo]             := JsonObject():New()
				oJsonRet["items"][nPos]["detailsBalance"][nIndSaldo]["branchId"] := aFilsSaldo[nIndSaldo]
				oJsonRet["items"][nPos]["detailsBalance"][nIndSaldo]["balance" ] := oSaldoFil[aFilsSaldo[nIndSaldo]]
			Next nIndSaldo
		EndIf

		If oJsonRet["items"][nPos]:HasProperty("detail")
			ajustaDcDm(oJsonRet["items"][nPos]["detail"], oJsDocDem)
		EndIf

		//Limpa o array de resultados
		aSize(aResult[nIndResult], 0)

	Next nIndResult

	If _oMrpDet:lMRPAPIDET
		oJsonRet["items"] := ExecBlock("MRPAPIDET", .F., .F., {cTicket, cProduct, cIdOpc, oJsonRet["items"]})
	EndIf

	If nTotal > 0
		aAdd(aReturn, .T.)
		aAdd(aReturn, EncodeUTF8(oJsonRet:toJSON()))
		aAdd(aReturn, 200)
	Else
		aAdd(aReturn, .F.)
		aAdd(aReturn, EncodeUTF8(STR0003)) //"Não foram encontrados registros com os parâmetros passados."
		aAdd(aReturn, 204)
	EndIf

	aSize(aResult, 0)
	aSize(aCalculo, 0)
	aSize(aDadosSP, 0)
	aSize(oJsonRet["items"], 0)
	FreeObj(oJsonRet)
	FreeObj(oJsDocTran)
	FreeObj(oJsDocDem)
	FreeObj(oTranfAgl)
	FreeObj(oQtdSaiTra)
Return aReturn

/*/{Protheus.doc} addToCalc
Adiciona um registro no JSON que está armazenando as informações que serão retornadas

@type Function
@author renan.roeder
@since 31/01/2022
@version P12.1.37
@param 01 aCalculo  , Array  , Array com os dados do período
@param 02 cChave    , Caracter, chave do json
@param 03 cFilCalc  , Caracter, filial
@param 04 cTicket   , Caracter, ticket
@param 05 cProduct  , Caracter, produto
@param 06 cIdOPC    , Caracter, ID do Opcional do produto
@param 07 cPeriod   , Caracter, período do MRP
@param 08 cDocType  , Caracter, tipo do documento
@param 09 cDocument , Caracter, descrição do documento
@param 10 cProdPai  , Caracter, código do produto pai (usado para empenhos)
@param 11 cRegType  , Caracter, tipo do registro (saldo,entrada,saída)
@param 12 nQuant    , Numeric , quantidade do documento
@param 13 cDocMrp   , Caracter, Número do documento interno no MRP
@param 14 cDocStatus, Caracter, Status do documento (Previsto, Firme, MRP)
@param 15 cLocal    , Caracter, Código do armazém.
@param 16 cEvent    , Caracter, Código do evento.
@param 17 cDocFil   , Caracter, Código do documento utilizado para filtro de eventos.
@return Nil
/*/
Static Function addToCalc(aCalculo, cChave, cFilCalc, cTicket, cProduct, cIdOPC, cPeriod, cDocType, cDocument, cProdPai, cRegType, nQuant, cDocMrp, cDocStatus, cLocal, cEvent, cDocFil)
	Local aAux := {}
	Default cDocStatus := ""

	//Se a quantidade for zero, não precisa listar
	If nQuant == 0
		Return
	EndIf

	cIdOPC := getOpciona(cFilCalc, cTicket, cIdOPC)

	aAux := Array(ARRAY_POS_SIZE)

	aAux[ARRAY_POS_CHAVE           ] := RTrim(cChave)
	aAux[ARRAY_POS_EMPRESA         ] := RTrim(cFilCalc)
	aAux[ARRAY_POS_TICKET          ] := RTrim(cTicket)
	aAux[ARRAY_POS_PRODUTO         ] := RTrim(cProduct)
	aAux[ARRAY_POS_ID_OPCIONAL     ] := RTrim(cIdOPC)
	aAux[ARRAY_POS_PERIODO         ] := PCPConvDat(RTrim(cPeriod), 5)
	aAux[ARRAY_POS_TIPO_DOCUMENTO  ] := RTrim(cDocType)
	aAux[ARRAY_POS_CODIGO_DOCUMENTO] := RTrim(cDocument)
	aAux[ARRAY_POS_PRODUTO_PAI     ] := RTrim(cProdPai)
	aAux[ARRAY_POS_TIPO_REGISTRO   ] := RTrim(cRegType)
	aAux[ARRAY_POS_QUANTIDADE      ] := nQuant
	aAux[ARRAY_POS_DOC_MRP         ] := RTrim(cDocMrp)
	aAux[ARRAY_POS_QTD_TOTAL       ] := 0 // Inicia com 0. Será definido na montagem dos dados que vão para a tela.
	aAux[ARRAY_POS_STATUS_DOCUMENTO] := cDocStatus
	aAux[ARRAY_POS_LOCAL           ] := cLocal
	aAux[ARRAY_POS_EVENT           ] := cEvent
	aAux[ARRAY_POS_DOCUMENTO_FILTRO] := cDocFil
	aAux[ARRAY_POS_DETALHA_SALDO   ] := {''}

	aAdd(aCalculo, aAux)

Return

/*/{Protheus.doc} getOpciona
Retorna a string do opcional a ser exibida

@type Function
@author marcelo.neumann
@since 07/02/2022
@version P12.1.37
@param 01 cFilCalc, Caracter, filial
@param 02 cTicket , Caracter, ticket do MRP
@param 03 cIdOPC  , Caracter, ID do opcional a ser pesquisado
@return cOpcional , Caracter, string opcional referente ao ID passado
/*/
Static Function getOpciona(cFilCalc, cTicket, cIdOPC)
	Local aRetOpc   := {}
	Local cOpcional := ""
	Local oJsonOpc  := Nil

	If !Empty(cIdOPC)
		aRetOpc := MrpGetOPC(cFilCalc, cTicket, cIdOPC)
		If aRetOpc[1]
			oJsonOpc := JsonObject():New()
			oJsonOpc:fromJson(aRetOpc[2])
			cOpcional := oJsonOpc["optionalString"]
			FreeObj(oJsonOpc)
		EndIf
		aSize(aRetOpc, 0)
	EndIf

Return cOpcional

/*/{Protheus.doc} getHWG
Busca detalhamento de registros aglutinados

@type  Static Function
@author douglas.heydt
@since 01/06/2022
@version P12.1.27
@param 01 cTicket , Character, Codigo único do processo para fazer a busca.
@param 02 cProduto, Character, Código do produto.
@param 03 oJsonAgl, Object   , Objeto Json que vai conter os registros.
@param 04 lUsaMe  , Logic    , Identifica se utiliza multi-empresa
/*/
Static Function getHWG(cTicket, cProduto, oJsonAgl, lUsaME)
	Local cAliasQry := ""
	Local cQuery    := ""
	Local cDocAnt   := ""
	Local cDocAgl   := ""
	Local cDocOri   := ""
	Local nPos      := 1

	If _oMrpDet:oQryHWG == Nil
		cQuery := " SELECT (CASE WHEN HWG.HWG_DOCAGL LIKE 'EMP%' AND HWG.HWG_PRODOR = ' ' "
		cQuery +=        " THEN (SELECT SMV.MV_DOCUM "
		cQuery +=                " FROM " + RetSqlName("SMV") + " SMV "
		cQuery +=               " WHERE SMV.MV_FILIAL = HWG.HWG_FILIAL "
		cQuery +=                 " AND SMV.MV_TICKET = HWG.HWG_TICKET "
		cQuery +=                 " AND SMV.MV_PRODUT = HWG.HWG_PROD "
		cQuery +=                 " AND SMV.MV_TABELA = 'T4S' "
		cQuery +=                 " AND SMV.MV_DOCUM LIKE '%|' + HWG.HWG_DOCORI "
		cQuery +=                 " AND SMV.D_E_L_E_T_ = ' ') "
		cQuery +=        " ELSE HWG.HWG_PRODOR END) HWG_PRODOR, "
		cQuery +=        " HWG.HWG_DOCORI,"
		cQuery +=        " HWG.HWG_NECESS,"
		cQuery +=        " HWG.HWG_QTEMPE,"
		cQuery +=        " HWG.HWG_DOCAGL,"
		cQuery +=        " HWC.HWC_DOCERP,"
		cQuery +=        " HWC.HWC_TDCERP,"
		cQuery +=        " HWG.HWG_PROD,"
		cQuery +=        " HWG.HWG_QTRSAI,"
		cQuery +=        " T4J.T4J_DOC,"
		cQuery +=        " T4J.T4J_REV"
		cQuery +=    " FROM " + RetSqlName("HWG") + " HWG "
		cQuery +=    " LEFT OUTER JOIN " + RetSqlName("HWC") + " HWC "
		cQuery +=     " ON HWC.HWC_FILIAL = HWG.HWG_FILIAL "
		cQuery +=    " AND HWC.HWC_TICKET = HWG.HWG_TICKET "
		cQuery +=    " AND HWC.HWC_DOCPAI = HWG.HWG_DOCORI "
		cQuery +=    " AND HWC.HWC_PRODUT = HWG.HWG_PRODOR "
		cQuery +=    " AND HWC.HWC_SEQUEN = HWG.HWG_SEQORI "
		DbSelectArea("HWG")
		If FieldPos("HWG_DOCFIL") > 0
			cQuery += " AND HWC.HWC_DOCFIL = HWG.HWG_DOCFIL "
		EndIf
		cQuery +=    " LEFT OUTER JOIN " + RetSqlName("T4J") + " T4J "
		cQuery +=     " ON T4J.T4J_FILIAL = HWG.HWG_FILIAL "
		cQuery +=    " AND T4J.T4J_PROD   = HWG.HWG_PROD   "
		cQuery +=    " AND T4J.T4J_IDREG  = HWG.HWG_DOCORI "
		cQuery +=    " AND T4J.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE HWG.HWG_FILIAL IN (?)"
		cQuery +=    " AND HWG.HWG_TICKET = ?"
		cQuery +=    " AND HWG.HWG_PROD   = ?"
		cQuery +=    " AND HWG.HWG_TPDCOR <> 'TRANF_ES'"
		cQuery +=    " AND HWG.D_E_L_E_T_ = ' '"
		cQuery +=  " ORDER BY HWG.HWG_DOCAGL "

		If _oMrpDet:cBanco $ "POSTGRES|ORACLE"
			cQuery := StrTran(cQuery, '+', '||')
		EndIf
		_oMrpDet:oQryHWG := FwExecStatement():New(cQuery)
	EndIf

	_oMrpDet:oQryHWG:SetIn(1, _oMrpDet:aFiliaisTicket )
	_oMrpDet:oQryHWG:SetString(2, cTicket)
	_oMrpDet:oQryHWG:SetString(3, cProduto)

	cAliasQry := _oMrpDet:oQryHWG:OpenAlias()

	While (cAliasQry)->(!Eof())
		cDocAgl := AllTrim((cAliasQry)->HWG_DOCAGL)
		If cDocAgl <> cDocAnt
			nPos := 0
			oJsonAgl[cDocAgl] := {}
		EndIf

		If Left(cDocAgl, 3) == "DEM"
			cDocOri := RTrim((cAliasQry)->HWG_DOCORI)
		EndIf

		nPos++
		aAdd(oJsonAgl[cDocAgl], JsonObject():New() )
		If SUBSTR(cDocAgl, 0, 3) == 'EMP'
			oJsonAgl[cDocAgl][nPos]['prodOrigem'] := Strtokarr2((cAliasQry)->HWG_PRODOR, "|", .T.)[1]
			oJsonAgl[cDocAgl][nPos]['docOrigem' ] := opEmp((cAliasQry)->HWG_DOCORI)
		Else
			oJsonAgl[cDocAgl][nPos]['prodOrigem'] := Iif(!Empty((cAliasQry)->HWG_PRODOR), (cAliasQry)->HWG_PRODOR, (cAliasQry)->HWG_PROD)
			oJsonAgl[cDocAgl][nPos]['docOrigem' ] := Iif(!Empty((cAliasQry)->HWC_DOCERP), (cAliasQry)->HWC_DOCERP, (cAliasQry)->HWG_DOCORI)
		EndIf

		If !Empty((cAliasQry)->HWC_TDCERP)
			oJsonAgl[cDocAgl][nPos]['tipoOrigem'] := (cAliasQry)->HWC_TDCERP
		EndIf

		oJsonAgl[cDocAgl][nPos]['quantidade'] := 0
		If(cAliasQry)->HWG_NECESS > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_NECESS
		ElseIf (cAliasQry)->HWG_QTEMPE > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_QTEMPE
		ElseIf (cAliasQry)->HWG_QTRSAI > 0
			oJsonAgl[cDocAgl][nPos]['quantidade'] := (cAliasQry)->HWG_QTRSAI
		EndIf

		cDocAnt   := cDocAgl
		(cAliasQry)->(dbSkip())
	End
	(cAliasQry)->(dbCloseArea())

Return

/*/{Protheus.doc} GET TRANSFER api/pcp/v1/mrpdetails/transferences/{ticket}
Busca os registros de transferências que devem ser processados

@type  WSMETHOD
@author douglas.Heydt
@since 01/06/2022
@version P12
@param 01 ticket     , Character, Codigo único do processo para fazer a pesquisa.
@param 02 product    , Character, Código do produto para filtrar a consulta. Se vazio, não será realizado filtro.
@param 03 periodFrom , Caracter, periodo inicial do calculo a ser considerado
@param 04 periodTo   , Caracter, periodo final do calculo a ser considerado
@param 05 nPage      , Number  , Página de busca
@param 06 nPageSize  , Number  , tamanho da página

/*/
WSMETHOD GET TRANSFER PATHPARAM ticket, product QUERYPARAM periodFrom, periodTo, Page,PageSize  WSSERVICE mrpdetails
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a funcao para retornar os dados.
	aReturn := getTrf(Self:ticket, decodeUTF8(Self:product), Self:periodFrom, Self:periodTo, Self:Page, Self:PageSize )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil

Return lRet

/*/{Protheus.doc} getTrf
Busca os registros de transferencias de um produto (SMA)

@type  Function
@author douglas.heydt
@since 03/06/2022
@version P12
@param 01 cTicket   , Character, Codigo único do processo para fazer a pesquisa.
@param 02 cProduto  , Character, Código do produto para filtrar a consulta. Se vazio, não será realizado filtro.
@param 03 cPerFrom  , Caracter , periodo inicial do calculo a ser considerado
@param 04 cPerTo    , Caracter , periodo final do calculo a ser considerado
@param 05 nPage     , Number   , Página de busca
@param 06 nPageSize , Number   , tamanho da página

@return   aResult , Array    , Resultado da consulta.
                               [1] - Lógico. Indica se encontrou ou não registros
                               [2] - Dados retornados. Se lRetJSON = .T., os dados serão JsonObject.
                                                       Se lRetJson = .F., os dados serão uma string JSON.
                               [3] - Numeric. Código HTTP de resposta.
/*/
Static Function getTrf(cTicket, cProduto, cPerFrom, cPerTo, nPage, nPageSize )
	Local aResult 	:= {.T.,"",200}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nStart    := 0
	Local oDados    := JsonObject():New()

	Default nPage    := 1
	Default nPageSize:= 20

	aResult[1] := .F.
	aResult[3] := 400

	If FWAliasInDic("SMA", .F.)
		cQuery := " SELECT SMA.MA_FILIAL, "
		cQuery +=        " SMA.MA_FILORIG, "
		cQuery +=        " SMA.MA_FILDEST, "
		cQuery +=        " SMA.MA_PROD, "
		cQuery +=        " SMA.MA_TICKET, "
		cQuery +=        " SMA.MA_DTTRANS, "
		cQuery +=        " SMA.MA_DTRECEB, "
		cQuery +=        " SMA.MA_QTDTRAN, "
		cQuery +=        " SMA.MA_ARMORIG, "
		cQuery +=        " SMA.MA_ARMDEST, "
		cQuery +=        " SMA.MA_DOCUM, "
		cQuery +=        " SMA.MA_STATUS, "
		cQuery +=        " SMA.MA_MSG, "
		cQuery +=        " SMA.R_E_C_N_O_ "
		cQuery +=   " FROM " + RetSqlName("SMA") + " SMA "
		cQuery +=  " WHERE SMA.MA_TICKET  = '" + cTicket + "' "
		cQuery +=    " AND SMA.MA_FILIAL  = '" + xFilial("SMA") + "' "
		cQuery +=    " AND SMA.D_E_L_E_T_ = ' ' "
		cQuery += " AND SMA.MA_PROD = '" + cProduto + "' "

		If !Empty(cPerFrom)
			cQuery += "	AND SMA.MA_DTTRANS >= '"+PCPConvDat(cPerFrom, 6)+"' "
		EndIf

		If !Empty(cPerTo)
			cQuery += " AND SMA.MA_DTTRANS <= '"+PCPConvDat(cPerTo, 6)+"' "
		EndIf

		cQuery +=  " ORDER BY SMA.MA_DTTRANS, SMA.MA_FILORIG, SMA.MA_PROD"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

		oDados["items"] := {}

		If nPage > 1
			nStart := ( (nPage-1) * nPageSize )
			If nStart > 0
				(cAliasQry)->(DbSkip(nStart))
			EndIf
		EndIf

		nPos := 0
		While (cAliasQry)->(!Eof())

			aAdd(oDados["items"], JsonObject():New())
			nPos++

			oDados["items"][nPos]['branchId'            ] := (cAliasQry)->MA_FILIAL
			oDados["items"][nPos]['originBranchId'      ] := (cAliasQry)->MA_FILORIG
			oDados["items"][nPos]['destinyBranchId'     ] := (cAliasQry)->MA_FILDEST
			oDados["items"][nPos]['product'             ] := (cAliasQry)->MA_PROD
			oDados["items"][nPos]['transferenceDate'    ] := PCPConvDat((cAliasQry)->MA_DTTRANS, 5)
			oDados["items"][nPos]['receiptDate'         ] := PCPConvDat((cAliasQry)->MA_DTRECEB, 5)
			oDados["items"][nPos]['transferenceQuantity'] := (cAliasQry)->MA_QTDTRAN
			oDados["items"][nPos]['originWarehouse'     ] := (cAliasQry)->MA_ARMORIG
			oDados["items"][nPos]['destinyWarehouse'    ] := (cAliasQry)->MA_ARMDEST
			IF (cAliasQry)->MA_STATUS == '1'
				oDados["items"][nPos]['document'        ] := (cAliasQry)->MA_MSG
			ELSE
				oDados["items"][nPos]['document'        ] := (cAliasQry)->MA_DOCUM
			ENDIF

			oDados["items"][nPos]['status'              ] := (cAliasQry)->MA_STATUS

			If Empty((cAliasQry)->MA_MSG) .Or. (cAliasQry)->MA_STATUS != '2'
				oDados["items"][nPos]["message" ] := {''}
			Else
				oDados["items"][nPos]["message" ] := {'message', EncodeUTF8((cAliasQry)->MA_MSG)}
			EndIf

			oDados["items"][nPos]['ticket'              ] := (cAliasQry)->MA_TICKET
			oDados["items"][nPos]['recordNumber'        ] := (cAliasQry)->R_E_C_N_O_

			(cAliasQry)->(dbSkip())

			//Verifica tamanho da página
			If nPos >= nPageSize
				Exit
			EndIf
		End
		oDados["hasNext"] := (cAliasQry)->(!Eof())

		(cAliasQry)->(dbCloseArea())

		aResult[2] := oDados:toJson()

		If nPos > 0
			aResult[1] := .T.
			aResult[3] := 200
		Else
			aResult[1] := .F.
			aResult[3] := 204
		EndIf

		aSize(oDados["items"],0)
	EndIf

	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} fmtLtVenc
Formata o documento de lote vencido.
@type  Static Function
@author Lucas Fagundes
@since 11/08/2022
@version P12
@param cDocPai, Caracter, Informações do lote/sub-lote/validade.
@return cDocFmt, Caracter, Documento formatado.
/*/
Static Function fmtLtVenc(cDocPai)
	Local cDocFmt := ""

	cDocFmt := STR0007 + cDocPai // "Armazém: "

Return cDocFmt

/*/{Protheus.doc} vldAglut
Retorna se aglutinou OP/SC de acordo com o nível do produto na tabela HWA.
@type  Static Function
@author Lucas Fagundes
@since 06/10/2022
@version P12
@param 01 cProduto, Caracter, Produto para buscar o nível.
@param 02 cTicket , Caracter, Ticket que irá verificar se aglutinou.
@return lAglut, Logico, Retorna se aglutinou dependendo do nível do produto.
/*/
Static Function vldAglut(cProduto, cTicket)
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local lAglut := .F.

	cQuery := " SELECT CASE "
	cQuery +=        " WHEN HWA.HWA_NIVEL = '99' THEN (SELECT HW1.HW1_VAL "
	cQuery +=                                          " FROM " + RetSqlName("HW1") + " HW1 "
	cQuery +=                                         " WHERE HW1.HW1_TICKET = '" + cTicket + "' "
	cQuery +=                                           " AND HW1.HW1_PARAM  = 'consolidatePurchaseRequest') "
	cQuery +=        " ELSE (SELECT HW1.HW1_VAL "
	cQuery +=                " FROM " + RetSqlName("HW1") + " HW1 "
	cQuery +=               " WHERE HW1.HW1_TICKET = '" + cTicket + "' "
	cQuery +=                 " AND HW1.HW1_PARAM  = 'consolidateProductionOrder') "
	cQuery +=        " END aglutina "
	cQuery +=   " FROM " + RetSqlName("HWA") + " HWA "
	cQuery +=  " WHERE HWA.HWA_PROD = '" + cProduto + "' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If (cAlias)->(!EoF())
		lAglut := (cAlias)->(aglutina) == "1"
	EndIf
	(cAlias)->(dbCloseArea())

Return lAglut

/*/{Protheus.doc} opEmp
Quebra a chave do empenho montada no cálculo e retorna a ordem de produção para exibir na tela.
@type  Static Function
@author Lucas Fagundes
@since 10/10/2022
@version P12
@param cChaveEmp, Caracter, Chave do empenho que irá buscar a op.
@return cOp, Caracter, Ordem de produção que será exibida na tela.
/*/
Static Function opEmp(cChaveEmp)
	Local aChave := Strtokarr2(cChaveEmp, ";", .T.)
	Local cOP    := cChaveEmp

	/*
	* aChave[1] == T4S_FILIAL
	* aChave[2] == T4S_PROD
	* aChave[3] == T4S_SEQ
	* aChave[4] == T4S_LOCAL
	* aChave[5] == T4S_OP
	* aChave[6] == T4S_OPORIG
	* aChave[7] == T4S_DT
	*/
	If Len(aChave) >= 5
		cOP := aChave[5]
	EndIf

	aSize(aChave, 0)
Return cOP

/*/{Protheus.doc} gerouDoc
Consulta o status do ticket e retorna se gerou documento ou não.
@type  Static Function
@author Lucas Fagundes
@since 10/10/2022
@version P12
@param cTicket, Caracter, Ticket que irá consultar o status
@return lGerou, lGerou, Retorna .T. se gerou os documentos
/*/
Static Function gerouDoc(cTicket)
	Local lGerou := .F.

	HW3->(DbSetOrder(1)) // HW3_FILIAL+HW3_TICKET
	If HW3->(DbSeek(xFilial('HW3')+PadR(AllTrim(cTicket), GetSx3Cache("HW3_TICKET", "X3_TAMANHO"))))
		lGerou := HW3->HW3_STATUS == "6" .Or. HW3->HW3_STATUS == "7" .Or. HW3->HW3_STATUS == "9"
	EndIf

Return lGerou

/*/{Protheus.doc} buscaAgl
Busca os documentos aglutinados a partir do código do documento aglutinador
@type  Static Function
@author Lucas Fagundes
@since 11/10/2022
@version P12
@param 01 cCodAgl , Caracter  , Documento aglutinador que irá buscar os aglutinados.
@param 02 cTicket , Caracter  , Ticket do MRP que irá buscar os doumentos.
@param 03 oJsonAGL, JsonObject, JSON com os dados dos documentos aglutinados
@return aAgl, Array, Array com os documentos aglutinados (já formatado para exibir nos detalhes da tela).
/*/
Static Function buscaAgl(cCodAgl, cTicket, oJsonAGL)
	Local aAgl     := {}
	Local aRetAux  := {}
	Local cAlias   := ""
	Local cDoc     := ""
	Local cQuery   := ""
	Local lAddAgl  := .T.
	Local nLenAgl  := 0
	Local oJsonAux := Nil

	If !_oMrpDet:lPossuiHWC_AGLUT
		Return aAgl
	EndIf

	If _oMrpDet:oQryAGL == Nil
		cQuery += " SELECT HWC.HWC_FILIAL, "
		cQuery +=        " HWC.HWC_DOCPAI, "
		cQuery +=        " HWC.HWC_DOCERP, "
		cQuery +=        " HWC.HWC_QTNEOR, "
		cQuery +=        " HWC.HWC_PRODUT, "
		cQuery +=        " HWC.HWC_TPDCPA, "
		cQuery +=        " HWG.HWG_DOCORI, "
		cQuery +=        " HWG.HWG_TPDCOR, "
		cQuery +=        " HWG.HWG_NECESS, "
		cQuery +=        " HWG.HWG_PRODOR, "
		cQuery +=        " HWG.HWG_QTRSAI, "
		cQuery +=        " erpHWC.HWC_DOCERP documentoErpHWC "
		cQuery +=   " FROM " + RetSqlName("HWC") + " HWC "
		cQuery +=   " LEFT OUTER JOIN " + RetSqlName("HWG") + " HWG "
		cQuery +=     " ON HWG.HWG_FILIAL = HWC.HWC_FILIAL"
		cQuery +=    " AND HWG.HWG_TICKET = HWC.HWC_TICKET"
		cQuery +=    " AND HWG.HWG_DOCAGL = HWC.HWC_DOCPAI"
		cQuery +=    " AND HWG.D_E_L_E_T_ = ' '"
		cQuery +=   " LEFT OUTER JOIN " + RetSqlName("HWC") + " erpHWC "
		cQuery +=     " ON erpHWC.HWC_FILIAL = HWG.HWG_FILIAL "
		cQuery +=    " AND erpHWC.HWC_TICKET = HWG.HWG_TICKET "
		cQuery +=    " AND erpHWC.HWC_DOCPAI = HWG.HWG_DOCORI "
		cQuery +=    " AND erpHWC.HWC_DOCFIL = HWG.HWG_DOCFIL"
		cQuery +=    " AND erpHWC.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE HWC.HWC_FILIAL IN (?)"
		cQuery +=    " AND HWC.HWC_TICKET = ?"
		cQuery +=    " AND HWC.HWC_AGLUT  = ?"
		cQuery +=    " AND HWC.D_E_L_E_T_ = ' '"

		_oMrpDet:oQryAGL := FwExecStatement():New(cQuery)
	EndIf

	_oMrpDet:oQryAGL:SetIn(1, _oMrpDet:aFiliaisTicket)
	_oMrpDet:oQryAGL:SetString(2, cTicket)
	_oMrpDet:oQryAGL:SetString(3, cCodAgl)

	cAlias := _oMrpDet:oQryAGL:OpenAlias()
	While (cAlias)->(!Eof())
		lAddAgl  := .T.
		oJsonAux := JsonObject():New()

		If    !Empty((cAlias)->HWG_DOCORI) ;
		.And. Left((cAlias)->HWG_DOCORI, 3) == "AGL" ;
		.And. RTrim((cAlias)->HWG_PRODOR)   == RTrim((cAlias)->HWC_PRODUT)

			lAddAgl := .F.
			aRetAux := buscaAgl((cAlias)->HWG_DOCORI, cTicket, @oJsonAGL)
			nLenAgl := Len(aAgl)
			aSize(aAgl, nLenAgl + Len( aRetAux ))
			aCopy(aRetAux, aAgl, /*nInicio*/, /*nFim*/, nLenAgl+1)
			aRetAux := {}

		ElseIf !Empty((cAlias)->HWG_DOCORI)
			If !Empty((cAlias)->(documentoErpHWC))
				oJsonAux["docOrigem"] := (cAlias)->(documentoErpHWC)
			ElseIf AllTrim((cAlias)->HWG_TPDCOR) == "Pré-OP"
				oJsonAux["docOrigem"] := opEmp((cAlias)->HWG_DOCORI)
			Else
				oJsonAux["docOrigem"] := (cAlias)->HWG_DOCORI
			EndIf

			oJsonAux["prodOrigem"] := Iif(!Empty((cAlias)->HWG_PRODOR), (cAlias)->HWG_PRODOR, (cAlias)->HWC_PRODUT)
			oJsonAux["quantidade"] := (cAlias)->HWG_NECESS

		Else
			If !Empty((cAlias)->HWC_DOCERP)
				oJsonAux["docOrigem"] := (cAlias)->HWC_DOCERP
			ElseIf AllTrim((cAlias)->HWC_TPDCPA) == "Pré-OP"
				oJsonAux["docOrigem"] := opEmp((cAlias)->HWC_DOCPAI)
			Else
				oJsonAux["docOrigem"] := (cAlias)->HWC_DOCPAI
			EndIf

			If AllTrim((cAlias)->HWC_TPDCPA) $ "|" + _oMrpDet:cTipoEstSeguranca + "|" + _oMrpDet:cTipoPontoPedido + "|"
				oJsonAux["docOrigem"] := STR0010 + ": " + (cAlias)->(HWC_FILIAL) + "|" + RTrim(oJsonAux["docOrigem"]) //"Filial"
			EndIf

			oJsonAux["prodOrigem"] := (cAlias)->HWC_PRODUT
			oJsonAux["quantidade"] := (cAlias)->HWC_QTNEOR
		EndIf

		If lAddAgl .And. AllTrim((cAlias)->HWC_TPDCPA) == "TRANF_PR"
			cDoc                   := RTrim(oJsonAux["docOrigem"])
			oJsonAux["quantidade"] := (cAlias)->HWG_QTRSAI
			If oJsonAGL:HasProperty(cDoc)
				nLenAgl := Len(aAgl)
				aSize(aAgl, nLenAgl + Len( oJsonAGL[cDoc] ))
				aCopy(oJsonAGL[cDoc], aAgl, /*nInicio*/, /*nFim*/, nLenAgl+1)
				lAddAgl := .F.
			EndIf
		EndIf

		If lAddAgl
			aAdd(aAgl, oJsonAux)
		EndIf
		oJsonAux := Nil
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return aAgl

/*/{Protheus.doc} docTranf
Verifica se um número de documento é referente a uma transferência

@type  Static Function
@author lucas.franca
@since 10/05/2023
@version P12
@param cDocumento, Caracter, Número do documento para avaliação
@return lTranf, Logic, .T. se o documento for uma transferência
/*/
Static Function docTranf(cDocumento)
	Local lTranf := .F.

	If Left(cDocumento, 5) == "TRANF"
		lTranf := .T.
	EndIf

Return lTranf

/*/{Protheus.doc} detTrfAgl
Monta o retorno de detalhes para uma linha do tipo Transferência quando existe aglutinação.

@type  Static Function
@author lucas.franca
@since 10/05/2023
@version P12
@param 01 cTicket   , Caracter  , Número do ticket do MRP
@param 02 cDocumento, Caracter  , Número do documento que está sendo retornado
@param 03 oJsonAGL  , JsonObject, JSON com os dados de aglutinação carregados
@return aDet, Array, Array com os dados de detalhe da transferência
/*/
Static Function detTrfAgl(cTicket, cDocumento, oJsonAGL)
	Local aAgl    := Nil
	Local aDet    := {}
	Local cDoc    := ""
	Local nLenDet := 0
	Local nIndex  := 0
	Local nTotal  := Len(oJsonAGL[cDocumento])

	For nIndex := 1 To nTotal
		cDoc    := RTrim(oJsonAGL[cDocumento][nIndex]["docOrigem"])
		nLenDet := Len(aDet)
		If oJsonAGL:HasProperty( cDoc )
			aSize(aDet, nLenDet + Len( oJsonAGL[ cDoc ] ))
			aCopy(oJsonAGL[ cDoc ], aDet, /*nInicio*/, /*nFim*/, nLenDet+1)
		Else
			aAgl := buscaAgl(cDoc, cTicket, oJsonAGL)
			If !Empty(aAgl)
				aSize(aDet, nLenDet + Len( aAgl ))
				aCopy(aAgl, aDet, /*nInicio*/, /*nFim*/, nLenDet+1)
				aAgl := Nil
			EndIf
		EndIf
	Next nIndex
Return aDet

/*/{Protheus.doc} trataDcDem
Trata a exibição para os documentos que são relacionados a alguma demanda.

@type  Static Function
@author lucas.franca
@since 11/05/2023
@version P12
@param 01 cDoc    , Caracter, Documento para conversão
@param 02 lUsaME  , Logic, Identifica se utiliza multi-empresas
@param 03 cDocum  , Caracter, documento vindo do campo T4J_DOC para concatenação
@param 04 cRevisao, Caracter, revisão vinda do campo T4J_REV para concatenação
@return cDocRet, Caracter, Documento formatado
/*/
Static Function trataDcDem(cDoc, lUsaME, cDocum, cRevisao)
	Local cDocRet := ""
	Local cVrFil  := P136GetInf(cDoc, "VR_FILIAL")
	Local cVrCod  := P136GetInf(cDoc, "VR_CODIGO")
	Local nVrSeq  := P136GetInf(cDoc, "VR_SEQUEN")

	If lUsaME
		cDocRet := STR0010 + ": " + RTrim(cVrFil) + "| " //"Filial"
	EndIf

	cDocRet += I18N(STR0011, {RTrim(cVrCod), nVrSeq}) //"Demanda: #1[ID]# | Sequência: #2[SEQ]#"

	If !Empty(cDocum)
		cDocRet += I18N(STR0015, {RTrim(cDocum)}) //" | Documento: #1[DOC]#"
	EndIf

	If !Empty(cRevisao)
		cDocRet += " | " + STR0016 + " " + RTrim(cRevisao) //"Revisão:"
	EndIf

Return cDocRet

/*/{Protheus.doc} ajustaDcDm
Verifica a necessidade de substituir o documento para exibição

@type  Static Function
@author lucas.franca
@since 11/05/2023
@version P12
@param 01 aDetail  , Array     , Array com os detalhes de retorno
@param 02 oJsDocDem, JsonObject, Json com o de-para dos documentos para transformar
@return Nil
/*/
Static Function ajustaDcDm(aDetail, oJsDocDem)
	Local cDoc   := ""
	Local nIndex := 0
	Local nTotal := Len(aDetail)

	For nIndex := 1 To nTotal
		cDoc := RTrim(aDetail[nIndex]["docOrigem"])
		If oJsDocDem:HasProperty(cDoc)
			aDetail[nIndex]["docOrigem"] := oJsDocDem[cDoc]
		EndIf
	Next nIndex
Return Nil

/*/{Protheus.doc} getDocType
Retorna o Tipo do documento (OP, SC ou PC)

@type Static Function
@author marcelo.neumann
@since 07/07/2023
@version P12
@param 01 cNivel    , Caracter, Nível do produto na estrutura
@param 02 cTipDocERP, Caracter, Tipo do documento gerado no ERP
@return cDocType, Caracter, Tipo do documento: OP - Ordem de Produção
                                               SC - Solicitação de Compra
											   AU - Autorização de Entrega
/*/
Static Function getDocType(cNivel, cTipDocERP)
	Local cDocType := ""

	If cNivel == "99"
		If cTipDocERP == "3" .Or. cTipDocERP == "6"
			cDocType := "AU"
		Else
			cDocType := "SC"
		EndIf
	Else
		cDocType := "OP"
	EndIf

Return cDocType

/*/{Protheus.doc} getDocStat
Retorna o Status do documento (MRP, Previsto, Firme)

@type Static Function
@author marcelo.neumann
@since 07/07/2023
@version P12
@param cTipDocERP , Caracter, Tipo do documento gerado no ERP
@return cDocStatus, Caracter, Status do documento: M - MRP
                                                   P - Previsto
                                                   F - Firme
/*/
Static Function getDocStat(cTipDocERP)
	Local cDocStatus := ""

	If Empty(cTipDocERP)
		cDocStatus := "M"
		//cDocStatus := STR0012 //"MRP"
	ElseIf cTipDocERP $ "1|2|3"
		cDocStatus := "P"
		//cDocStatus := STR0014 //"Previsto"
	Else
		cDocStatus := "F"
		//cDocStatus := STR0013 //"Firme"
	EndIf

Return cDocStatus

/*/{Protheus.doc} paramTkt
Recupera o conteúdo de um parâmetro utilizado em uma execução do MRP.
@type  Static Function
@author Ana Paula dos Santos
@since 03/07/2025
@version P12
@param cTicket, Caracter, Ticket de execução do MRP
@param cParam, Caracter, Parâmetro
@return cValor, Caracter, Conteudo do parâmetro no ticket verificado
/*/
Static Function paramTkt(cTicket,cParam)
	Local cValor := ""

	HW1->(DbSetOrder(1)) // HW1_FILIAL+HW1_TICKET+HW1_PARAM
	If HW1->(DbSeek(xFilial("HW1")+cTicket+cParam))
		cValor := AllTrim(HW1->HW1_VAL)
	EndIf

Return cValor
