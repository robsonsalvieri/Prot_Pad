#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERS.CH"

Static _aMapOrd   := MapFields()
Static _aTamQtd   := TamSX3("C2_QUANT")

Function PrdOrds()
Return

/*/{Protheus.doc} ProductionOrders
API de integração de Ordens de Produção
@type  WSCLASS
@author parffit.silva
@since 26/10/2020
@version P12.1.27
/*/
WSRESTFUL productionorders DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordem de Produção"
	WSDATA Fields              AS STRING  OPTIONAL
	WSDATA Order               AS STRING  OPTIONAL
	WSDATA Page                AS INTEGER OPTIONAL
	WSDATA PageSize            AS INTEGER OPTIONAL
	WSDATA recno               AS INTEGER OPTIONAL
	WSDATA branchId            AS STRING  OPTIONAL
	WSDATA productionOrder     AS STRING  OPTIONAL
	WSDATA documentOrigin      AS STRING  OPTIONAL
	WSDATA documentId          AS STRING  OPTIONAL
	WSDATA finalDeliveryDate   AS STRING  OPTIONAL
	WSDATA finalUseDate        AS STRING  OPTIONAL
	WSDATA initialDeliveryDate AS STRING  OPTIONAL
	WSDATA initialUseDate      AS STRING  OPTIONAL
	WSDATA product             AS STRING  OPTIONAL
	WSDATA productDescription  AS STRING  OPTIONAL
	WSDATA SystemDate          AS STRING  OPTIONAL
	WSDATA orderFilter         AS STRING  OPTIONAL

	WSMETHOD GET ALLPORDERS;
		DESCRIPTION STR0002;//"Retorna todas as Ordens de Produção"
		WSSYNTAX "api/pcp/v1/productionorders" ;
		PATH "/api/pcp/v1/productionorders" ;
		TTALK "v1"

	WSMETHOD GET PORDER;
		DESCRIPTION STR0003;//"Retorna uma Ordem de Produção"
		WSSYNTAX "api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		PATH "/api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		TTALK "v1"

	WSMETHOD GET PEGGING;
		DESCRIPTION STR0006;//"Retorna uma ou mais Ordens de Produção para rastreabilidade"
		WSSYNTAX "api/pcp/v1/productionorders/pegging" ;
		PATH "/api/pcp/v1/productionorders/pegging" ;
		TTALK "v1"

	WSMETHOD GET ALLOCATION;
		DESCRIPTION STR0017; // "Retorna o empenhos para a tela de rastreabilidade"
		WSSYNTAX "api/pcp/v1/productionorders/allocation" ;
		PATH "/api/pcp/v1/productionorders/allocation" ;
		TTALK "v1"

	WSMETHOD GET OPCOP;
		DESCRIPTION STR0018; // "Retorna os opcionais de uma ordem de produção"
		WSSYNTAX "api/pcp/v1/productionorders/pegging/optional/{recno}" ;
		PATH "/api/pcp/v1/productionorders/pegging/optional/{recno}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLPORDERS /api/pcp/v1/productionorders
Retorna todas as Ordens de produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Order   , caracter, Ordenação da tabela principal
@param	Page    , numérico, Número da página inicial da consulta
@param	PageSize, numérico, Número de registro por páginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLPORDERS QUERYPARAM Order, Page, PageSize, Fields WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := GetAllPOrd(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PORDER /api/pcp/v1/productionorders
Retorna um registro de Ordem de Produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PORDER PATHPARAM branchId, productionOrder QUERYPARAM Fields WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPOrd(Self:branchId, Self:productionOrder, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PEGGING /api/pcp/v1/productionorders/pegging
Retorna as Ordens de Produção para rastreabilidade
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Page      , numérico, Número da página inicial da consulta
@param	PageSize  , numérico, Número de registro por páginas
@param  SystemDate , character , database do protheus enviada pelo front
@return lRet      , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PEGGING WSRECEIVE branchId, productionOrder, documentOrigin, documentId, product, productDescription, initialDeliveryDate, finalDeliveryDate, initialUseDate, finalUseDate QUERYPARAM Page, PageSize, SystemDate WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPOrdPeg(Self:branchId, Self:productionOrder, Self:documentOrigin, Self:documentId, Self:product, Self:productDescription, Self:Page, Self:PageSize, Self:SystemDate, Self:initialDeliveryDate, Self:finalDeliveryDate, Self:initialUseDate, Self:finalUseDate)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET ALLOCATION api/pcp/v1/productionorders/allocation
Retorna os empenhos para exibição na tela de rastreabilidade

@type WSMETHOD
@author Lucas Fagundes
@since 15/03/2023
@version P12
@param 01 productionOrder, Caracter, Filtro das ordens de produções para consulta.
@param 02 pageSize       , Numerico, Tamanho da página a ser buscada.
@param 03 page           , Numerico, Numero da página a ser buscada.
@param 04 documentId     , Caracter, Filtro dos documentos para a consulta.
@param 05 orderFilter    , Object  , Json com os dados para filtro dos empenhos.
                                     [
										{'branchId':cod_filial,'productionOrder':num_op,'documentId':id_documento},
										{'branchId':cod_filial,'productionOrder':num_op,'documentId':id_documento}
									 ]
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLOCATION PATHPARAM productionOrder, pageSize, page, documentId, orderFilter WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := PCPEmpPegg(Self:productionOrder, Self:pageSize, Self:page, Self:documentId, Self:orderFilter)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)

	aSize(aReturn, 0)
Return lRet

/*/{Protheus.doc} GET OPCOP api/pcp/v1/productionorders/pegging/optional/{recno}
Retorna os dados de opcionais de uma ordem de produção

@type WSMETHOD
@author lucas.franca
@since 21/03/2023
@version P12
@param 01 recno, Integer, RECNO da ordem de produção
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET OPCOP PATHPARAM recno WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := GetOPCPeg(Self:recno)

	MRPApi():restReturn(Self, aReturn, "GET", @lRet)

	aSize(aReturn, 0)
Return lRet

/*/{Protheus.doc} GetOPCPeg
Faz a busca dos opcionais de uma ordem de produção

@type  Static Function
@author lucas.franca
@since 21/03/2023
@version P12
@param nRecnoOP, Number, RECNO da ordem de produção
@return aReturn, Array, Array com os dados para retorno
/*/
Function GetOPCPeg(nRecnoOP)
	Local aReturn   := {.F., STR0010, 400} //"Nenhum registro foi encontrado."
	Local aOpcional := {}
	Local nIndex    := 0
	Local nTotal    := 0
	Local oJsRet    := Nil

	If Empty(nRecnoOP)
		Return aReturn
	EndIf

	SC2->(dbGoTo(nRecnoOP))
	If SC2->(Recno()) == nRecnoOP
		aOpcional := ListOpc(SC2->C2_PRODUTO, SC2->C2_MOPC, SC2->C2_OPC, 2)
		If !Empty(aOpcional)

			nTotal          := Len(aOpcional)
			oJsRet          := JsonObject():New()
			oJsRet["items"] := {}

			For nIndex := 1 To nTotal
				aAdd(oJsRet["items"], JsonObject():New())
				oJsRet["items"][nIndex]["product"          ] := RTrim(aOpcional[nIndex][1])
				oJsRet["items"][nIndex]["description"      ] := RTrim(aOpcional[nIndex][2])
				oJsRet["items"][nIndex]["groupOptional"    ] := RTrim(aOpcional[nIndex][3])
				oJsRet["items"][nIndex]["descGroupOptional"] := RTrim(aOpcional[nIndex][4])
				oJsRet["items"][nIndex]["itemOptional"     ] := RTrim(aOpcional[nIndex][5])
				oJsRet["items"][nIndex]["descItemOptional" ] := RTrim(aOpcional[nIndex][6])

				aSize(aOpcional[nIndex], 0)
			Next nIndex

			aReturn[1] := .T.
			aReturn[2] := EncodeUTF8(oJsRet:toJson())
			aReturn[3] := 200

			FreeObj(oJsRet)
			aSize(aOpcional, 0)
		EndIf

	EndIf

Return aReturn

/*/{Protheus.doc} GetPOrdPeg
Busca as ordens de produção para rastreabilidade
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param   cBranch , Caracter, Código da filial
@param   cPOrder , Caracter, Número da ordem de produção
@param   cOrigin , Caracter, Tipo do documento
@param    cDocto , Caracter, Número do documento
@param  cProduto , Caracter, Código do produto
@param cProdDesc , Caracter, Descrição do produto
@param     nPage , Numeric , Página dos dados. Se não enviado, considera página 1.
@param nPageSize , Numeric , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cSystDate , Caracter, Database do protheus enviada pelo front
@param cDatEntIni, Caracter, Data de entrega inicial
@param cDatEntFim, Caracter, Data de entrega final
@param cDatUsoIni, Caracter, Data de uso inicial
@param cDatUsoFim, Caracter, Data de uso final
@param cDemanda, Caracter, Demanda
/*/
Function GetPOrdPeg(cBranch, cPOrder, cOrigin, cDocto, cProduto, cProdDesc, nPage, nPageSize, ;
                    cSystDate, cDatEntIni, cDatEntFim, cDatUsoIni, cDatUsoFim, cDemanda)
	Local aResult 	 := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cBanco     := Upper(TcGetDb())
	Local cFieldOP   := ""
	Local cQuery     := ""
	Local cTxtES     := MrpDGetSTR("ES")
	Local cTxtPP     := MrpDGetSTR("PP")
	Local lFieldsLt  := .F.
	Local lFilDest   := .F.
	Local lPerdInf   := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local lUsaSBZ    := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
	Local nDelay     := 0
	Local nPos       := 0
	Local nStart     := 1
	Local nStatus    := 0
	Local nStatusPO  := 0
	Local mOpcOP     := Nil
	Local oDados     := JsonObject():New()

	DEFAULT nPage     := 1
	DEFAULT nPageSize := 20
	DEFAULT cSystDate := DtoS(dDataBase)

	dbSelectArea("SMH")
	lFieldsLt := FieldPos("MH_LOTE") > 0 .And. FieldPos("MH_SLOTE") > 0
	lFilDest  := FieldPos("MH_FILDES") > 0

	If !Empty(cBranch)
		cBranch := PadR(cBranch, FWSizeFilial())
	EndIf

	If "MSSQL" $ cBanco
		cFieldOP += " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD "

	ElseIf cBanco == "POSTGRES"
		cFieldOP += " TRIM(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) "

	Else
		cFieldOP += " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	EndIf

	cQuery := "SELECT SC2.C2_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " (CASE WHEN SMH.MH_DEMDOC = '" + cTxtPP + "' AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' ELSE SMH.MH_DEMDOC END) AS documentId,"
	cQuery +=         cFieldOP + " AS productionOrder,"
	cQuery +=       " SC2.C2_PRODUTO AS product,"
	cQuery +=       " SC2.C2_QUANT AS quantity,"

	If lPerdInf
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE - SC2.C2_PERDA) AS balance,"
	Else
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE) AS balance,"
	EndIf

	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " (CASE WHEN SMH.MH_TPDCSAI LIKE '%OP%' THEN SMH.MH_NMDCSAI ELSE SMH2.MH_NMDCSAI END) AS sourceDocument,"
	cQuery +=       " SUM(SMH.MH_QUANT) AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '1' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH3.MH_NMDCENT AS sourceEstSeg,"
	cQuery +=       " SMH.MH_IDREG AS idReg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	If lFilDest
		cQuery += " , SMH.MH_FILDES AS filDes"
	EndIf

	cQuery +=  " FROM " + RetSqlName("SC2") + " SC2"             // Ordem de Produção
	cQuery +=  " JOIN " + RetSqlName("SMH") + " SMH"  // Rastreabilidade das Demandas
	cQuery +=    " ON " + FwJoinFilial("SC2", "SMH", "SC2", "SMH", .T.)
	cQuery +=   " AND SMH.MH_TPDCENT = '1'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"

	If cBanco == "POSTGRES"
		cQuery += " AND Trim(SMH.MH_NMDCENT) = Trim(" + cFieldOP + ")"

	Else
		cQuery += " AND SMH.MH_NMDCENT = " + cFieldOP
	EndIf

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL  = SMH.MH_FILIAL"
	cQuery +=              " AND SMH2.MH_TPDCENT = 'P'"
	cQuery +=              " AND SMH2.MH_NMDCENT = SMH.MH_NMDCSAI"
	cQuery +=              " AND SMH2.MH_TPDCSAI LIKE '%OP%'"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH3"
	cQuery +=               " ON SMH3.MH_FILIAL = SMH.MH_FILIAL"
	cQuery +=              " AND SMH3.MH_IDREG = SMH.MH_IDPAI"
	cQuery +=              " AND SMH3.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	If lFilDest
		cQuery +=           " ON SVR.VR_FILIAL = SMH.MH_DEMFIL "
	Else
		cQuery +=           " ON " + FwJoinFilial("SMH", "SVR", "SMH", "SVR", .T.)
	EndIf
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE " + PCPRasFili("SC2.C2_FILIAL", "SC2", cBranch)
	cQuery +=   " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, cFieldOP) + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SC2.C2_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	If !Empty(cDatEntIni)
		cDatEntIni := StrTran(cDatEntIni, "-", "")
		cQuery     += " SC2.C2_DATPRF >= '" + cDatEntIni + "' AND"
	EndIf
	If !Empty(cDatEntFim)
		cDatEntFim := StrTran(cDatEntFim, "-", "")
		cQuery     += " SC2.C2_DATPRF <= '" + cDatEntFim + "' AND"
	EndIf

	If !Empty(cDatUsoIni)
		cDatUsoIni := StrTran(cDatUsoIni, "-", "")
		cQuery     += " SMH.MH_DATA >= '" + cDatUsoIni + "' AND"
	EndIf
	If !Empty(cDatUsoFim)
		cDatUsoFim := StrTran(cDatUsoFim, "-", "")
		cQuery     += " SMH.MH_DATA <= '" + cDatUsoFim + "' AND"
	EndIf

	If !Empty(cDemanda)
		cQuery += " SMH.MH_DEMANDA = '" + cDemanda + "' AND"
	EndIf

	cQuery +=       " SB1.B1_COD = SC2.C2_PRODUTO"
	cQuery +=   " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	//clausula group by com todos os campos menos o SUM do usedQuantity
	cQuery += " GROUP BY SC2.C2_FILIAL , "
	cQuery +=          " SVR.VR_TIPO, "
	cQuery +=          " SVR.VR_QUANT, "
	cQuery +=          " (CASE "
	cQuery +=          "      WHEN SMH.MH_DEMDOC = '" + cTxtPP + "' "
	cQuery +=          "           AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' "
	cQuery +=          "      ELSE SMH.MH_DEMDOC "
	cQuery +=          "  END), "
	cQuery +=            cFieldOP + ", "
	cQuery +=          " SC2.C2_PRODUTO, "
	cQuery +=          " SC2.C2_QUANT, "
	cQuery +=          " (SC2.C2_QUANT - SC2.C2_QUJE), "
	cQuery +=          " SC2.C2_DATPRI, "
	cQuery +=          " SC2.C2_DATPRF, "
	cQuery +=          " SC2.C2_PERDA, "
	cQuery +=          " SB1.B1_DESC, "
	cQuery +=          " (CASE "
	cQuery +=          "      WHEN SMH.MH_TPDCSAI LIKE '%OP%' THEN SMH.MH_NMDCSAI "
	cQuery +=          "      ELSE SMH2.MH_NMDCSAI "
	cQuery +=          "  END), "
	cQuery +=          " SMH.MH_DATA, "
	cQuery +=          " SC2.C2_OPC, "
	cQuery +=          " SC2.R_E_C_N_O_, "
	cQuery +=          " SMH.MH_DEMANDA, "
	cQuery +=          " SMH.MH_DEMSEQ, "
	cQuery +=          " SMH3.MH_NMDCENT, "
	cQuery +=          " SMH.MH_IDREG"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE "
		cQuery += " , SMH.MH_SLOTE "
	EndIf

	If lFilDest
		cQuery += " , SMH.MH_FILDES "
	EndIf

	// Registros de Saldo Inicial
	cQuery += " UNION ALL"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " 'SaldoInicial' AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " 0 AS quantity,"
	cQuery +=       " 0 AS balance,"
	cQuery +=       " ' ' AS startDate,"
	cQuery +=       " ' ' AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"

	If lUsaSBZ
		cQuery +=   " COALESCE(SBZ.BZ_OPC, SB1.B1_OPC, ' ') AS optional,"
	Else
		cQuery +=   " COALESCE(SB1.B1_OPC, ' ') AS optional,"
	EndIf

	cQuery +=       " 0 AS recno,"
	cQuery +=       " '0' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH2.MH_NMDCENT AS sourceEstSeg,"
	cQuery +=       " SMH.MH_IDREG AS idReg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	If lFilDest
		cQuery += " , SMH.MH_FILDES AS filDes"
	EndIf

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	If lFilDest
		cQuery +=      " ON SVR.VR_FILIAL = SMH.MH_DEMFIL "
	Else
		cQuery +=      " ON " + FwJoinFilial("SMH", "SVR", "SMH", "SVR", .T.)
	EndIf
	cQuery +=   " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=   " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=   " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"
	cQuery +=               " ON SMH2.MH_FILIAL = SMH.MH_FILIAL "
	cQuery +=              " AND SMH2.MH_IDREG  = SMH.MH_IDPAI"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	If lUsaSBZ
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ"
		cQuery +=   " ON " + FwJoinFilial("SBZ", "SMH", "SBZ", "SMH", .T.)
		cQuery +=  " AND SBZ.BZ_COD = SMH.MH_PRODUTO"
		cQuery +=  " AND SBZ.D_E_L_E_T_ = ' '"
	EndIf

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE " + PCPRasFili("SMH.MH_FILIAL", "SMH", cBranch)
	cQuery +=   " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, "SMH.MH_NMDCSAI") + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SMH.MH_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	If !Empty(cDatUsoIni)
		cQuery += " SMH.MH_DATA >= '" + cDatUsoIni + "' AND"
	EndIf
	If !Empty(cDatUsoFim)
		cQuery += " SMH.MH_DATA <= '" + cDatUsoFim + "' AND"
	EndIf

	If !Empty(cDemanda)
		cQuery += " SMH.MH_DEMANDA = '" + cDemanda + "' AND"
	EndIf

	cQuery +=       " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = '0'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	// Registros de Demandas atendidas pelo Ponto de Pedido
	cQuery += " UNION ALL"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SVR.VR_QUANT AS demandQuantity,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " SMH2.MH_NMDCENT AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " SMH.MH_QUANT AS quantity,"
	cQuery +=       " SMH.MH_QUANT AS balance,"
	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '0.5' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand,"
	cQuery +=       " SMH3.MH_NMDCENT AS sourceEstSeg,"
	cQuery +=       " SMH.MH_IDREG AS idReg"

	If lFieldsLt
		cQuery += " , SMH.MH_LOTE  AS lote "
		cQuery += " , SMH.MH_SLOTE AS subLote "
	EndIf

	If lFilDest
		cQuery += " , SMH.MH_FILDES AS filDes"
	EndIf

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	If lFilDest
		cQuery +=           " ON SVR.VR_FILIAL = SMH.MH_DEMFIL"
	Else
		cQuery +=           " ON " + FwJoinFilial("SMH", "SVR", "SMH", "SVR", .T.)
	EndIf
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL  = SMH.MH_FILIAL"
	cQuery +=              " AND SMH2.MH_TPDCENT = '1'"
	cQuery +=              " AND SMH2.MH_NMDCSAI = SMH.MH_NMDCENT"
	cQuery +=              " AND SMH2.MH_TPDCSAI = '" + cTxtPP + "'
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH3"
	cQuery +=               " ON SMH3.MH_FILIAL  = SMH.MH_FILIAL "
	cQuery +=              " AND SMH3.MH_IDREG   = SMH.MH_IDPAI"
	cQuery +=              " AND SMH3.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SC2") + " SC2"  // Ordens de Produção
	cQuery +=               " ON " + FwJoinFilial("SMH", "SC2", "SMH2", "SC2", .T.)
	If "MSSQL" $ cBanco
		cQuery +=           " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	ElseIf cBanco == "POSTGRES"
		cQuery +=           " AND Trim(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) = Trim(SMH2.MH_NMDCENT)"
	Else
		cQuery +=           " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	EndIf
	cQuery +=              " AND SC2.C2_PRODUTO = SMH.MH_PRODUTO"
	cQuery +=              " AND SC2.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE " + PCPRasFili("SMH.MH_FILIAL", "SMH", cBranch)
	cQuery +=   " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND"

	If !Empty(cPOrder)
		cQuery += pcpPegFilt(cPOrder, "SMH2.MH_NMDCENT") + " AND"
	EndIf

	If !Empty(cProduto)
		cQuery += pcpPegFilt(cProduto, "SMH.MH_PRODUTO") + " AND"
	EndIf

	If !Empty(cOrigin)
		cQuery += pcpPegFilt(cOrigin, "SVR.VR_TIPO") + " AND"
	EndIf

	If !Empty(cDocto)
		cQuery += pcpPegFilt(cDocto, "SMH.MH_DEMDOC") + " AND"
	EndIf

	If !Empty(cProdDesc)
		cQuery += pcpPegFilt(cProdDesc, "SB1.B1_DESC") + " AND"
	EndIf

	If !Empty(cDatEntIni)
		cQuery += " SC2.C2_DATPRF >= '" + cDatEntIni + "' AND"
	EndIf
	If !Empty(cDatEntFim)
		cQuery += " SC2.C2_DATPRF <= '" + cDatEntFim + "' AND"
	EndIf

	If !Empty(cDatUsoIni)
		cQuery += " SMH.MH_DATA >= '" + cDatUsoIni + "' AND"
	EndIf
	If !Empty(cDatUsoFim)
		cQuery += " SMH.MH_DATA <= '" + cDatUsoFim + "' AND"
	EndIf

	If !Empty(cDemanda)
		cQuery += " SMH.MH_DEMANDA = '" + cDemanda + "' AND"
	EndIf

	cQuery +=   " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = 'P'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.MH_TPDCSAI = '9'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	cQuery += " ORDER BY 14, 6, 17, 1, 5"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	// nStart -> primeiro registro da pagina
	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	//Ajusta o tipo dos campos na query.
	TcSetField(cAliasQry,       'quantity', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry,        'balance', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry,   'usedQuantity', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'demandQuantity', 'N', _aTamQtd[1], _aTamQtd[2])

	oDados["items"] := {}

	nPos := 0
	While (cAliasQry)->(!Eof())
		mOpcOP := Nil
		If AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial'
			nStatus   := 3
			nDelay    := 0
			nStatusPO := "0"
		Else
			nStatusPO := getStatusPO((cAliasQry)->recno, @mOpcOP)

			If nStatusPO == '5' .Or. nStatusPO == '6'
				nStatus := 0
				nDelay  := 0
			Else
				nDelay := DateDiffDay(STOD(cSystDate), STOD((cAliasQry)->ENDDATE))
				If STOD(cSystDate) < STOD((cAliasQry)->ENDDATE)
					nDelay := nDelay*-1
				EndIf

				nStatus := IIF(nDelay > 0, 2, 1)
			EndIf
		EndIf

		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'          ] := RTrim((cAliasQry)->branchId)
		oDados["items"][nPos]['documentOrigin'    ] := RTrim((cAliasQry)->documentOrigin)
		oDados["items"][nPos]['documentId'        ] := RTrim((cAliasQry)->documentId)
		oDados["items"][nPos]['productionOrder'   ] := IIf(AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial','',RTrim((cAliasQry)->productionOrder))
		oDados["items"][nPos]['product'           ] := RTrim((cAliasQry)->product)
		oDados["items"][nPos]['productDescription'] := (cAliasQry)->productDescription
		oDados["items"][nPos]['quantity'          ] := (cAliasQry)->quantity
		oDados["items"][nPos]['balance'           ] := (cAliasQry)->balance
		oDados["items"][nPos]['PORecno'           ] := (cAliasQry)->recno
		oDados["items"][nPos]['endDate'           ] := getDate((cAliasQry)->ENDDATE)
		oDados["items"][nPos]['status'            ] := nStatus
		oDados["items"][nPos]['delay'             ] := nDelay
		oDados["items"][nPos]['usedQuantity'      ] := (cAliasQry)->usedQuantity
		oDados["items"][nPos]['usedDate'          ] := getDate((cAliasQry)->usedDate)
		oDados["items"][nPos]['optional'          ] := (cAliasQry)->optional
		oDados["items"][nPos]['idReg'             ] := RTrim((cAliasQry)->idReg)
		oDados["items"][nPos]['demand'            ] := (cAliasQry)->demand + Iif(!Empty((cAliasQry)->seqDemand), " / " + cValToChar((cAliasQry)->seqDemand), "")

		If !Empty(mOpcOP)
			oDados["items"][nPos]["viewOptional"] := {'viewOptional'}
		Else
			oDados["items"][nPos]["viewOptional"] := {''}
		EndIf

		oDados["items"][nPos]['productDetail'] := Array(1)
		oDados["items"][nPos]['productDetail'][1] :=JsonObject():New()
		oDados["items"][nPos]['productDetail'][1]['productDescription'] := RTrim((cAliasQry)->productDescription)
		oDados["items"][nPos]['productDetail'][1]['startDate'         ] := getDate((cAliasQry)->startDate)
		oDados["items"][nPos]['productDetail'][1]['lot'               ] := Iif(lFieldsLt, RTrim((cAliasQry)->lote)   , '')
		oDados["items"][nPos]['productDetail'][1]['sublot'            ] := Iif(lFieldsLt, RTrim((cAliasQry)->subLote), '')
		oDados["items"][nPos]['productDetail'][1]['sourceDocument'    ] := Iif(SubStr((cAliasQry)->documentId, 1, Len(cTxtES)) == cTxtES, (cAliasQry)->sourceEstSeg, (cAliasQry)->sourceDocument)
		oDados["items"][nPos]['productDetail'][1]['statusPO'          ] := lblStatusPO(nStatusPO)
		oDados["items"][nPos]['productDetail'][1]['demandQuantity'    ] := (cAliasQry)->demandQuantity
		oDados["items"][nPos]['productDetail'][1]['destinyBranch'     ] := Iif(lFilDest, RTrim((cAliasQry)->filDes), '')

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oDados["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	aResult[2] := EncodeUTF8(oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0010
		aResult[3] := 204
	EndIf

    aSize(oDados["items"],0)
	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} getStatusPO
Função para retornar o status da OP.
@type    Function
@author parffit.silva
@since 25/05/2021
@version P12.1.27
@param 01 nPORecno, number, Recno da ordem de produção na SC2
@param 02 mOpcOP  , Memo  , Retorna por referência o MOPC da OP
@return  cStatus -> Status da ordem
/*/
Static Function getStatusPO(nPORecno, mOpcOP)
	Local cAliasTemp := ""
	Local aAreaSC2    := SC2->(GetArea())
	Local cQuery     := ""
	Local cStatus    := ""
	Local dEmissao   := dDataBase
	Local nRegSD3    := 0
	Local nRegSH6    := 0

	SC2->(dbGoTo(nPORecno))
	mOpcOP := SC2->C2_MOPC
	If SC2->C2_TPOP == "P"
		cStatus := "1" //Prevista
	Else
		If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE < C2_QUANT)  /*Enc.Parcialmente*/
			cStatus := "5" //Encerrada Parcialmente
		Else
			If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE >= C2_QUANT)  /*Enc.Totalmente*/
				cStatus := "6" //Encerrada Totalmente
			Else
				cAliasTemp:= "SD3TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
				cQuery     += "   FROM " + RetSqlName('SD3')
				cQuery     += "   WHERE D3_FILIAL   = '" + xFilial('SD3', SC2->C2_FILIAL)+ "'"
				cQuery     += "     AND D3_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D3_ESTORNO <> 'S' "
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    += "       GROUP BY D3_EMISSAO "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SD3TMP->(Eof())
					dEmissao := STOD(SD3TMP->EMISSAO)
					nRegSD3 := SD3TMP->RegSD3
				EndIf
				(cAliasTemp)->(dbCloseArea())
				cAliasTemp:= "SH6TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSH6 "
				cQuery     += "   FROM " + RetSqlName('SH6')
				cQuery     += "   WHERE H6_FILIAL   = '" + xFilial('SH6', SC2->C2_FILIAL)+ "'"
				cQuery     += "     AND H6_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    := ChangeQuery(cQuery)
				dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SH6TMP->(Eof())
					nRegSH6 := SH6TMP->RegSH6
				EndIf
				(cAliasTemp)->(dbCloseArea())

				If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI == 0,1,SC2->C2_DIASOCI)) //Em aberto
					cStatus := "2" //Em aberto
				Else
					If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((dDatabase - dEmissao),0) > If(SC2->C2_DIASOCI >= 0,-1,SC2->C2_DIASOCI)) //Iniciada
						cStatus := "3" //Iniciada
					Else
						If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max((dDatabase - dEmissao),0) > SC2->C2_DIASOCI .Or. Max((dDatabase - SC2->C2_DATPRI),0) >= SC2->C2_DIASOCI)   //Ociosa
							cStatus := "4" //Ociosa
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC2)
Return cStatus

/*/{Protheus.doc} GetAllPOrd
Função para disparar as ações da API para o método GET (Consulta) de uma lista de ordens de produção
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
*/
Function GetAllPOrd(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := PORDERGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} GetPOrd
Função para disparar as ações da API para o método GET (Consulta) de uma ordem de produção específica
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cBranch , Caracter, Código da filial
@param cPOrder, Caracter, Número da ordem de produção
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function GetPOrd(cBranch, cPOrder, cFields)
	Local aReturn   := {}
	Local aQryParam := {}
    Local nTamNumOp := GetSx3Cache("C2_NUM","X3_TAMANHO")
    Local nTamItmOp := GetSx3Cache("C2_ITEM","X3_TAMANHO")
    Local nTamSeqOp := GetSx3Cache("C2_SEQUEN","X3_TAMANHO")
    Local nTamGrdOp := GetSx3Cache("C2_ITEMGRD","X3_TAMANHO")

    cPOrder := PadR(cPOrder,GetSx3Cache("D4_OP", "X3_TAMANHO"))

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"NUMBER"  , Left(cPOrder,nTamNumOp)})
	aAdd(aQryParam, {"ITEM"    , SubStr(cPOrder,nTamNumOP + 1,nTamItmOP)})
	aAdd(aQryParam, {"SEQUENCE", SubStr(cPOrder,nTamNumOP + nTamItmOP + 1,nTamSeqOP)})
	aAdd(aQryParam, {"GRID"    , SubStr(cPOrder,nTamNumOP + nTamItmOP + nTamSeqOP + 1,nTamGrdOP)})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a função para retornar os dados.
	aReturn := PORDERGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} PORDERGet
Executa o processamento do método GET de acordo com os parâmetros recebidos.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Static Function PORDERGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instância da classe MRPApi para o método GET

	//Seta os parâmetros de paginação, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")
	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()
	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Libera o objeto MRPApi da memória.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} defMRPApi
Faz a instância da classe MRPAPI e seta as propriedades básicas.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cMethod  , Character, Método que será executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenação para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definições já executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapOrd , "SC2", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields", {"C2_FILIAL","C2_NUM","C2_ITEM","C2_SEQUEN","C2_ITEMGRD"})

	//If cMethod == "POST"
	//	//Seta as funções de validação de cada mapeamento.
	//	oMRPApi:setValidData("fields", "PORDVLD")
	//EndIf

Return oMRPApi

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da tabela SC2
@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()

	Local aFields := {}
    aFields := {;
                {"branchId"         , "C2_FILIAL" , "C", FWSizeFilial()                        , 0 },;
                {"number"           , "C2_NUM"    , "C", GetSx3Cache("C2_NUM","X3_TAMANHO")    , 0 },;
                {"item"             , "C2_ITEM"   , "C", GetSx3Cache("C2_ITEM","X3_TAMANHO")   , 0 },;
                {"sequence"         , "C2_SEQUEN" , "C", GetSx3Cache("C2_SEQUEN","X3_TAMANHO") , 0 },;
                {"grid"             , "C2_ITEMGRD", "C", GetSx3Cache("C2_ITEMGRD","X3_TAMANHO"), 0 },;
                {"productionOrder"  , "C2_OP"     , "C", GetSx3Cache("C2_OP","X3_TAMANHO")     , 0 },;
				{"itemCode"         , "C2_PRODUTO", "C", GetSx3Cache("C2_PRODUTO","X3_TAMANHO"), 0 },;
                {"quantity"         , "C2_QUANT"  , "N", GetSx3Cache("C2_QUANT","X3_TAMANHO")  , GetSx3Cache("C2_QUANT","X3_DECIMAL") },;
                {"reportQuantity"   , "C2_QUJE"   , "N", GetSx3Cache("C2_QUJE","X3_TAMANHO")   , GetSx3Cache("C2_QUJE","X3_DECIMAL") } ,;
				{"unitOfMeasureCode", "C2_UM"     , "C", GetSx3Cache("C2_UM","X3_TAMANHO")     , 0 },;
				{"requestOrderCode" , "C2_PEDIDO" , "C", GetSx3Cache("C2_PEDIDO","X3_TAMANHO") , 0 },;
				{"warehouseCode"    , "C2_LOCAL"  , "C", GetSx3Cache("C2_LOCAL","X3_TAMANHO")  , 0 },;
                {"startOrderDate"   , "C2_DATPRI" , "D", 8                                     , 0 },;
                {"endOrderDate"     , "C2_DATPRF" , "D", 8                                     , 0 },;
                {"scriptCode"       , "C2_ROTEIRO", "C", GetSx3Cache("C2_ROTEIRO","X3_TAMANHO"), 0 };
			   }
Return aFields

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type  Static Function
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function getDate(dData)
	Local cData := ""
	If !Empty(dData)
		cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
	EndIf
Return cData

/*/{Protheus.doc} POrdMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  parffit.silva
@since   26/10/2020
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function POrdMap()
Return {_aMapOrd}

/*/{Protheus.doc} lblStatusPO
Retorna uma string com o nome do status da OP de acordo com o número do status.
@type  Static Function
@author Lucas Fagundes
@since 28/02/2023
@version P12
@param cNumStatus, Caracter, Número do status para converção.
@return cStatus, Caracter, Status da OP convertido.
/*/
Static Function lblStatusPO(cNumStatus)
	Local cStatus := ""

	Do Case
		Case cNumStatus == "1"
			cStatus := STR0011 // "Prevista"
		Case cNumStatus == "2"
			cStatus := STR0012 //"Em aberto"
		Case cNumStatus == "3"
			cStatus := STR0013 // "Iniciada"
		Case cNumStatus == "4"
			cStatus := STR0014 //"Ociosa"
		Case cNumStatus == "5"
			cStatus := STR0015 //"Encerrada parcialmente"
		Case cNumStatus == "6"
			cStatus := STR0016 //"Encerrada totalmente"
	EndCase

Return cStatus

/*/{Protheus.doc} pcpPegFilt
Monta o filtro LIKE para os filtros da tela de rastreabilidade.
@type  Function
@author Lucas Fagundes
@since 14/03/2023
@version P12
@param 01 cFiltro, Caracter, Conteudo do filtro que será filtrado.
@param 02 cCampo , Caracter, Campo que será filtrado na query.
@return cFilQry, Caracter, Query para filtrar o campo com o conteudo do filtro.
/*/
Function pcpPegFilt(cFiltro, cCampo)
	Local aFiltros := {}
	Local cFilQry  := ""
	Local nIndex   := 0
	Local nTotal   := 0

	aFiltros := StrToKArr2(cFiltro, ",", .T.)
	nTotal := Len(aFiltros)

	If nTotal > 1
		cFilQry += " ( "

		For nIndex := 1 To nTotal

			cFilQry += "(" + cCampo + " LIKE '%" + AllTrim(aFiltros[nIndex]) + "%' )"

			If nIndex < nTotal
				cFilQry += " OR "
			EndIf
		Next

		cFilQry += " ) "
	Else
		cFilQry += " (" + cCampo + " LIKE '%" + AllTrim(aFiltros[nTotal]) + "%') "
	EndIf

	aSize(aFiltros, 0)
Return cFilQry

/*/{Protheus.doc} PCPEmpPegg
Busca os empenhos para exibir na tela de rastreabilidade da demandas do MRP.
@type  Function
@author Lucas Fagundes
@since 15/03/2023
@version P12
@param 01 cProdOrd , Caracter, Filtro das ordens de produções para consulta.
@param 02 nPageSize, Numerico, Tamanho da página a ser buscada.
@param 03 nPage    , Numerico, Numero da página a ser buscada.
@param 04 cDocument, Caracter, Filtro dos documentos para a consulta.
@param 05 cFiltro  , Caracter, Objeto com os filtros selecionados em tela (filial, OP e documento)
@return aReturn, Array, Array com os dados para retorno da API.
/*/
Function PCPEmpPegg(cProdOrd, nPageSize, nPage, cDocument, cFiltro)
	Local aReturn  := {.T., "", 200}
	Local aFiltros := {}
	Local cAlias   := GetNextAlias()
	Local cQuery   := ""
	Local nCount   := 0
	Local nStart   := 0
	Local oDados   := JsonObject():New()
	Local oJsAux   := Nil
	Local oFiltro  := Nil

	Default nPage     := 1
	Default nPageSize := 20

	If !Empty(cFiltro)
		oFiltro := JsonObject():New()
		oFiltro:FromJson('{"filter":' + cFiltro + '}')
		If oFiltro:hasProperty("filter") .And. !Empty(oFiltro["filter"])
			aFiltros := oFiltro["filter"]
			FreeObj(oFiltro)
		EndIf
	EndIf

	cQuery +=  " SELECT DISTINCT SD4.D4_FILIAL  branchId, "
	cQuery +=         " SD4.D4_OP      productionOrder, "
	cQuery +=         " SD4.D4_COD     product, "
	cQuery +=         " SD4.D4_LOCAL   warehouse, "
	cQuery +=         " SD4.D4_DATA    allocationDate, "
	cQuery +=         " SD4.D4_QUANT   quantity, "
	cQuery +=         " SD4.D4_TRT     sequence, "
	cQuery +=         " SD4.D4_LOTECTL lot, "
	cQuery +=         " SD4.D4_NUMLOTE sublot, "
	cQuery +=         " SD4.D4_DTVALID expirationDate, "
	cQuery +=         " SD4.D4_OPERAC  operation, "
	cQuery +=         " SD4.D4_OPORIG  originalProductionOrder "
	cQuery +=    " FROM " + RetSqlName("SD4") + " SD4 "
	cQuery +=   " INNER JOIN " + RetSqlName("SMH") + " SMH "
	cQuery +=           " ON " + FwJoinFilial("SMH", "SD4", "SMH", "SD4", .T.)
	cQuery +=          " AND SMH.MH_TPDCENT = '1' "
	cQuery +=          " AND SMH.MH_NMDCENT = SD4.D4_OP "
	cQuery +=          " AND SMH.D_E_L_E_T_ = ' ' "
	If !Empty(cDocument)
		cQuery +=      " AND " + pcpPegFilt(cDocument, "SMH.MH_DEMDOC")
	EndIf
	cQuery +=   " WHERE " + PCPRasFili("SD4.D4_FILIAL", "SD4", "")
	cQuery +=     " AND SD4.D_E_L_E_T_ = ' ' "
	If !Empty(cProdOrd)
		cQuery += " AND " + pcpPegFilt(cProdOrd, "SD4.D4_OP")
	EndIf
	cQuery += filtroSD4(aFiltros)
	cQuery +=   " ORDER BY SD4.D4_FILIAL, "
	cQuery +=            " SD4.D4_OP, "
	cQuery +=            " SD4.D4_DATA "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.F.)

	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAlias)->(DbSkip(nStart))
		EndIf
	EndIf

	oDados["items"] := {}

	while (cAlias)->(!EoF())
		oJsAux := JsonObject():New()

		oJsAux["branchId"               ] := (cAlias)->branchId
		oJsAux["productionOrder"        ] := (cAlias)->productionOrder
		oJsAux["product"                ] := (cAlias)->product
		oJsAux["warehouse"              ] := (cAlias)->warehouse
		oJsAux["allocationDate"         ] := getDate((cAlias)->allocationDate)
		oJsAux["quantity"               ] := (cAlias)->quantity
		oJsAux["sequence"               ] := (cAlias)->sequence
		oJsAux["lot"                    ] := (cAlias)->lot
		oJsAux["sublot"                 ] := (cAlias)->sublot
		oJsAux["expirationDate"         ] := getDate((cAlias)->expirationDate)
		oJsAux["operation"              ] := (cAlias)->operation
		oJsAux["originalProductionOrder"] := (cAlias)->originalProductionOrder

		aAdd(oDados["items"], oJsAux)

		(cAlias)->(dbSkip())
		nCount++

		If nCount == nPageSize
			Exit
		EndIf
	End
	oDados["hasNext"] := (cAlias)->(!EoF())

	(cAlias)->(dbCloseArea())

	If Len(oDados["items"]) > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oDados:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
		aReturn[2] := STR0010 // "Nenhum registro foi encontrado."
		aReturn[3] := 400
	EndIf

	FwFreeObj(oDados)
	aSize(aFiltros, 0)
Return aReturn

/*/{Protheus.doc} filtroSD4
Adiciona os filtros na query da SD4

@type  Static Function
@author lucas.franca
@since 12/09/2023
@version P12
@param aFiltros, Array, Array com os filtros para aplicar na SD4
@return cFilter, Caracter, Condição SQL com os filtros.
/*/
Static Function filtroSD4(aFiltros)
	Local cFilter := ""
	Local nIndex  := 0
	Local nTotal  := Len(aFiltros)

	For nIndex := 1 To nTotal
		If nIndex == 1
			cFilter += " AND ("
		Else
			cFilter += " OR "
		EndIf

		cFilter += " ("
		cFilter +=      "SD4.D4_FILIAL = '" + xFilial("SD4", aFiltros[nIndex]["branchId"]) + "'"
		cFilter += " AND SD4.D4_OP = '" + aFiltros[nIndex]["productionOrder"] + "'"
		If !Empty(aFiltros[nIndex]["documentId"])
			cFilter += " AND SMH.MH_DEMDOC = '" + aFiltros[nIndex]["documentId"] + "'"
		EndIf
		cFilter += ")"

	Next nIndex

	If nTotal > 0
		cFilter += ")"
	EndIf
Return cFilter

