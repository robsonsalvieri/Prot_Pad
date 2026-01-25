#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPPURCHASES.CH"

Static _lIniCom   := Nil
Static _lFieldsLt := Nil
Static _cTxtES    := MrpDGetSTR("ES")
Static _cTxtPP    := MrpDGetSTR("PP")

Function PCPPurch()
Return

/*/{Protheus.doc} pcppurchases
API para consulta de solicitações e pedidos de compra

Function PCPPurch()
Return

@type  API
@author douglas.heydt
@since 09/11/2020
@version P12.1.30
/*/
WSRESTFUL pcppurchases DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Solicitações/Pedidos de compras"

	WSDATA branchId        as STRING OPTIONAL
	WSDATA Page            as INTEGER OPTIONAL
	WSDATA PageSize        as INTEGER OPTIONAL
	WSDATA productionOrder as STRING OPTIONAL
	WSDATA documentId      as STRING OPTIONAL
	WSDATA orderFilter     as STRING OPTIONAL
	WSDATA systemdate      as STRING OPTIONAL

	WSMETHOD GET purchases;
	    DESCRIPTION STR0002; //"Busca todos os registros de solicitações e pedidos de compra"
		WSSYNTAX "api/pcp/v1/pcppurchases" ;
		PATH "/api/pcp/v1/pcppurchases" ;
		TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET purchases WSRECEIVE branchId, productionOrder, Page, PageSize, documentId, orderFilter, systemdate WSSERVICE pcppurchases
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPurchs(Self:branchId, Self:productionOrder, Self:Page, Self:PageSize, Self:documentId, Self:orderFilter, Self:systemdate )
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GetPurchs
Busca todos os registros de solicitações e pedidos de compra

@type  Static Function
@author douglas.heydt
@since 09/11/2020
@version P12.1.30
@param 01 branchId       , Caracter, Código da filial.
@param 02 productionOrder, Caracter, Ordens de produção para filtrar a query.
@param 03 page           , Numerico, Paginação da busca.
@param 04 pageSize       , Numerico, Tamanho da paginação.
@param 05 cDocsId        , Caracter, Código dos documentos para filtrar a query.
@param 06 cFiltro        , Caracter, Objeto com os filtros selecionados em tela (filial, OP e documento)
@param 07 cSystDate      , Caracter, Database do protheus enviada pelo front
@return aReturn, Array, Array com o retorno da api.
/*/
Function GetPurchs(branchId, productionOrder, page, pageSize, cDocsId, cFiltro, cSystDate)
	Local aResult   := {.T., "", 200}
	Local aFiltros  := {}
	Local cAliasQry := GetNextAlias()
	Local cBanco    := Upper(TcGetDb())
	Local cQuery    := ""
	Local cTxtES    := MrpDGetSTR("ES")
	Local cTxtPP    := MrpDGetSTR("PP")
	Local nDelay    := 0
	Local nPos      := 0
	Local nStart    := 0
	Local nStatus   := 0
	Local oDados    := JsonObject():New()
	Local oFiltro   := Nil

	Default page := 0
	Default pageSize := -1
	Default cSystDate := DtoS(dDataBase)

	If _lIniCom == Nil
		dbSelectArea("SC1")
		_lIniCom := FieldPos("C1_DINICOM") > 0

		dbSelectArea("SMH")
		_lFieldsLt := FieldPos("MH_LOTE") > 0 .And. FieldPos("MH_SLOTE") > 0
	EndIf

	If !Empty(branchId)
		branchId := PadR(branchId, FWSizeFilial())
	EndIf

	If !Empty(cFiltro)
		oFiltro := JsonObject():New()
		oFiltro:FromJson('{"filter":' + cFiltro + '}')
		If oFiltro:hasProperty("filter") .And. !Empty(oFiltro["filter"])
			aFiltros := oFiltro["filter"]
			FreeObj(oFiltro)
		EndIf
	EndIf

	cQuery := " SELECT SC1.C1_FILIAL   AS branchId, "
	If "ORACLE" $ cBanco
		cQuery +=    " CONCAT (CONCAT(SC1.C1_NUM, SC1.C1_ITEM),  SC1.C1_ITEMGRD) AS purchaseId, "
	Else
		If "MSSQL" $ cBanco
			cQuery += " (SC1.C1_NUM + SC1.C1_ITEM + SC1.C1_ITEMGRD) AS purchaseId, "
		Else
			cQuery += " CONCAT (SC1.C1_NUM, SC1.C1_ITEM,  SC1.C1_ITEMGRD) AS purchaseId, "
		EndIf
	EndIf

	cQuery +=        " (CASE WHEN (SMH.MH_DEMDOC = '" + cTxtES + "' OR SMH.MH_DEMDOC = '" + cTxtPP + "') AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' ELSE SMH.MH_DEMDOC END) AS documentId,"
	cQuery +=        " 'sc'            AS purchaseType, "
	cQuery +=        " SC1.C1_PRODUTO  AS product, "
	cQuery +=        " SC1.C1_QUANT    AS quantity, "
	cQuery +=        " (SC1.C1_QUANT - SC1.C1_QUJE) AS balance, "
	cQuery +=        " SC1.C1_DATPRF   AS deliveryDate, "
	cQuery +=        " SC1.C1_LOCAL    AS warehouse, "
	cQuery +=        " (CASE WHEN SMH.MH_TPDCSAI LIKE '%OP%' OR SMH.MH_TPDCSAI = 'TRANF_ES' THEN SMH.MH_NMDCSAI ELSE SMH2.MH_NMDCSAI END) AS productionOrder, "
	cQuery +=        " 0               AS status, "
	cQuery +=        " SC1.C1_FORNECE  AS supplier, "
	cQuery +=        " SB1.B1_DESC     AS productDescription, "
	cQuery +=        " SMH.MH_QUANT    AS usedQuantity, "
	cQuery +=        " '1'             AS orderSaldo, "
	cQuery +=        " SC1.C1_DINICOM  AS dateStart,"
	cQuery +=        " ''              AS lote, "
	cQuery +=        " ''              AS subLote, "
	cQuery +=        " SMH.MH_IDPAI    AS idPai "

	cQuery +=  " FROM " + RetSqlName("SC1") + " SC1 " // Solicitações de Compra
	cQuery +=  " JOIN " + RetSqlName("SMH") + " SMH " // Rastreabilidade das Demandas
	cQuery +=    " ON " + FwJoinFilial("SMH", "SC1", "SMH", "SC1", .T.)
	cQuery +=   " AND SMH.MH_TPDCENT = '2' "
	If "MSSQL" $ cBanco
		cQuery += " AND SMH.MH_NMDCENT = SC1.C1_NUM+SC1.C1_ITEM+SC1.C1_ITEMGRD "
	ElseIf cBanco == "POSTGRES"
		cQuery += " AND Trim(SMH.MH_NMDCENT) = Trim(CONCAT(SC1.C1_NUM,SC1.C1_ITEM,SC1.C1_ITEMGRD)) "
	Else
		cQuery += " AND SMH.MH_NMDCENT = SC1.C1_NUM||SC1.C1_ITEM||SC1.C1_ITEMGRD "
	EndIf
	cQuery +=     " AND SMH.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2 "  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = SMH.MH_FILIAL"
	cQuery +=              " AND SMH2.MH_TPDCENT = 'P' "
	cQuery +=              " AND SMH2.MH_NMDCENT = SMH.MH_NMDCSAI "
	cQuery +=              " AND SMH2.MH_TPDCSAI LIKE '%OP%'"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR "  // Itens das Demandas
	cQuery +=               " ON " + FwJoinFilial("SVR", "SMH", "SVR", "SMH", .T.)
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA "
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ "
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' ' "

	cQuery +=   " JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=     " ON SC1.C1_PRODUTO = SB1.B1_COD "
	cQuery +=  " WHERE SC1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND " + PCPRasFili("SC1.C1_FILIAL", "SC1", branchId)
	cQuery +=    " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += filtroCom(aFiltros, "SC1", "SC1.C1_FILIAL", {"SC1.C1_OP", "SMH.MH_NMDCSAI", "SMH2.MH_NMDCSAI"}, {"SMH.MH_DEMDOC", "SMH2.MH_DEMDOC"}, {"SMH.MH_IDPAI", "SMH2.MH_IDPAI"}, branchId)

	If !Empty(productionOrder)
		cQuery += " AND (   " + pcpPegFilt(productionOrder, "SC1.C1_OP")
		cQuery +=      " OR " + pcpPegFilt(productionOrder, "SMH.MH_NMDCSAI")
		cQuery +=      " OR " + pcpPegFilt(productionOrder, "SMH2.MH_NMDCSAI") + " ) "
	EndIf

	If !Empty(cDocsId)
		cQuery += " AND (   " + pcpPegFilt(cDocsId, "SMH.MH_DEMDOC")
		cQuery +=      " OR " + pcpPegFilt(cDocsId, "SMH2.MH_DEMDOC") + " )"
	EndIf

	cQuery +=  " UNION "

	cQuery += " SELECT SC7.C7_FILIAL   AS branchId, "

	If "ORACLE" $ cBanco
		cQuery +=    " CONCAT(CONCAT(CONCAT(SC7.C7_NUM, SC7.C7_ITEM), SC7.C7_SEQUEN), SC7.C7_ITEMGRD) AS purchaseId, "
	Else
		If "MSSQL" $ cBanco
			cQuery += " (SC7.C7_NUM + SC7.C7_ITEM + SC7.C7_SEQUEN + SC7.C7_ITEMGRD) AS purchaseId, "
		Else
			cQuery += " CONCAT (SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_SEQUEN, SC7.C7_ITEMGRD) AS purchaseId, "
		EndIf
	EndIf

	cQuery +=        " (CASE WHEN (SMH.MH_DEMDOC = '" + cTxtES + "' OR SMH.MH_DEMDOC = '" + cTxtPP + "') AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' ELSE SMH.MH_DEMDOC END) AS documentId,"
	cQuery +=        " 'pc'            AS purchaseType, "
	cQuery +=        " SC7.C7_PRODUTO  AS product, "
	cQuery +=        " SC7.C7_QUANT    AS quantity, "
	cQuery +=        " (SC7.C7_QUANT - SC7.C7_QUJE) AS balance, "
	cQuery +=        " SC7.C7_DATPRF   AS deliveryDate, "
	cQuery +=        " SC7.C7_LOCAL    AS warehouse, "
	cQuery +=        " (CASE WHEN SMH.MH_TPDCSAI LIKE '%OP%' OR SMH.MH_TPDCSAI = 'TRANF_ES' THEN SMH.MH_NMDCSAI ELSE SMH2.MH_NMDCSAI END) AS productionOrder, "
	cQuery +=        " 0               AS status, "
	cQuery +=        " SC7.C7_FORNECE  AS supplier, "
	cQuery +=        " SB1.B1_DESC     AS productDescription, "
	cQuery +=        " SMH.MH_QUANT    AS usedQuantity, "
	cQuery +=        " '1'             AS orderSaldo, "
	cQuery +=        " SC7.C7_DINICOM  AS dateStart, "
	cQuery +=        " ''              AS lote, "
	cQuery +=        " ''              AS subLote, "
	cQuery +=        " SMH.MH_IDPAI    AS idPai "

	cQuery +=  " FROM " + RetSqlName("SC7") + " SC7 "             // Pedidos de Compra

	cQuery +=  " JOIN " + RetSqlName("SMH") + " SMH "  // Rastreabilidade das Demandas
	cQuery +=    " ON " + FwJoinFilial("SC7", "SMH", "SC7", "SMH", .T.)
	cQuery +=   " AND SMH.MH_TPDCENT = '3' "
	If "MSSQL" $ cBanco
		cQuery += " AND SMH.MH_NMDCENT = SC7.C7_NUM+SC7.C7_ITEM+SC7.C7_SEQUEN+SC7.C7_ITEMGRD "
	ElseIf cBanco == "POSTGRES"
		cQuery += " AND Trim(SMH.MH_NMDCENT) = Trim(CONCAT(SC7.C7_NUM,SC7.C7_ITEM,SC7.C7_SEQUEN,SC7.C7_ITEMGRD)) "
	Else
		cQuery += " AND SMH.MH_NMDCENT = SC7.C7_NUM||SC7.C7_ITEM||SC7.C7_SEQUEN||SC7.C7_ITEMGRD "
	EndIf
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2 "  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = SMH.MH_FILIAL "
	cQuery +=              " AND SMH2.MH_TPDCENT = 'P' "
	cQuery +=              " AND SMH2.MH_NMDCENT = SMH.MH_NMDCSAI "
	cQuery +=              " AND SMH2.MH_TPDCSAI LIKE '%OP%'"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' ' "

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR "  // Itens das Demandas
	cQuery +=               " ON " + FwJoinFilial("SVR", "SMH", "SVR", "SMH", .T.)
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA "
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ "
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' ' "

	cQuery +=   " JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=     " ON SC7.C7_PRODUTO = SB1.B1_COD "
	cQuery +=  " WHERE SC7.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND " + PCPRasFili("SC7.C7_FILIAL", "SC7", branchId)
	cQuery +=    " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
	cQuery += filtroCom(aFiltros, "SC7", "SC7.C7_FILIAL", {"SC7.C7_OP", "SMH.MH_NMDCSAI", "SMH2.MH_NMDCSAI"}, {"SMH.MH_DEMDOC", "SMH2.MH_DEMDOC"}, {"SMH.MH_IDPAI", "SMH2.MH_IDPAI"}, branchId)

	If !Empty(productionOrder)
		cQuery += " AND (   " + pcpPegFilt(productionOrder, "SC7.C7_OP")
		cQuery +=      " OR " + pcpPegFilt(productionOrder, "SMH.MH_NMDCSAI")
		cQuery +=      " OR " + pcpPegFilt(productionOrder, "SMH2.MH_NMDCSAI") + " ) "
	EndIf

	If !Empty(cDocsId)
		cQuery += " AND (   " + pcpPegFilt(cDocsId, "SMH.MH_DEMDOC")
		cQuery +=      " OR " + pcpPegFilt(cDocsId, "SMH2.MH_DEMDOC") + " )"
	EndIf

	// Registros de Saldo Inicial
	cQuery += " UNION"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " 'SaldoInicial' AS purchaseId,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " ' ' AS purchaseType,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " 0 AS quantity,"
	cQuery +=       " 0 AS balance,"
	cQuery +=       " SMH.MH_DATA AS deliveryDate,"
	cQuery +=       " ' ' AS warehouse,"
	cQuery +=       " SMH.MH_NMDCSAI AS productionOrder,"
	cQuery +=       " 0 AS status, "
	cQuery +=       " ' ' AS supplier, "
	cQuery +=       " SB1.B1_DESC AS productDescription, "
	cQuery +=       " SMH.MH_QUANT AS usedQuantity, "
	cQuery +=       " '0' AS orderSaldo, "
	cQuery +=       " ' ' AS dateStart,"
	cQuery +=       " SMH.MH_LOTE  AS lote, "
	cQuery +=       " SMH.MH_SLOTE AS subLote, "
	cQuery +=        " SMH.MH_IDPAI AS idPai "

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=               " ON " + FwJoinFilial("SVR", "SMH", "SVR", "SMH", .T.)
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE " + PCPRasFili("SMH.MH_FILIAL", "SMH", branchId)
	cQuery +=   " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery +=   " AND SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = '0'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'MP%'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += filtroCom(aFiltros, "SMH", "SMH.MH_FILIAL", {"SMH.MH_NMDCSAI"}, {"SMH.MH_DEMDOC"}, {"SMH.MH_IDPAI"}, branchId)

	If !Empty(productionOrder)
		cQuery += " AND " + pcpPegFilt(productionOrder, "SMH.MH_NMDCSAI")
	EndIf

	If !Empty(cDocsId)
		cQuery += " AND " + pcpPegFilt(cDocsId, "SMH.MH_DEMDOC")
	EndIf

	cQuery += " ORDER BY 1, 10, 8, 5, 3, 15, 2 " // branchId, productionOrder, deliveryDate, product, documentId, orderSaldo, purchaseId

	If _lIniCom == .F.
		//Remove da query o SC1.C1_DINICOM e carrega como ' ' caso não exista o campo.
		cQuery := StrTran(cQuery, "SC1.C1_DINICOM", "' '" )
	EndIf

	If _lFieldsLt == .F.
		//Remove da query os campos de lote referente a tabela SMG caso as colunas não existam.
		cQuery := StrTran(cQuery, "SMH.MH_LOTE" , "''" )
		cQuery := StrTran(cQuery, "SMH.MH_SLOTE", "''" )
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	oDados["items"] := {}
	nPos            := 0

	//Controle de paginação.
	If page > 1
		nStart := ( (page-1) * pageSize)
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	While (cAliasQry)->(!Eof())

		If AllTrim((cAliasQry)->purchaseId) == 'SaldoInicial'
			nStatus   := 3
			nDelay    := 0
		Else

			nDelay := DateDiffDay(STOD(cSystDate), STOD((cAliasQry)->deliveryDate))
			If STOD(cSystDate) < STOD((cAliasQry)->deliveryDate)
				nDelay := nDelay*-1
			EndIf

			nStatus := IIF(nDelay > 0, 2, 1)
		EndIf

		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'       ] := (cAliasQry)->branchId
		oDados["items"][nPos]['purchaseId'     ] := IIF(AllTrim((cAliasQry)->purchaseId) == 'SaldoInicial','',(cAliasQry)->purchaseId)
		oDados["items"][nPos]['documentId'     ] := (cAliasQry)->documentId
		oDados["items"][nPos]['purchaseType'   ] := (cAliasQry)->purchaseType
		oDados["items"][nPos]['product'        ] := (cAliasQry)->product
		oDados["items"][nPos]['quantity'       ] := (cAliasQry)->quantity
		oDados["items"][nPos]['balance'        ] := (cAliasQry)->balance
		oDados["items"][nPos]['deliveryDate'   ] := getDate((cAliasQry)->deliveryDate)
		oDados["items"][nPos]['status'         ] := nStatus
		oDados["items"][nPos]['delay'          ] := nDelay
		oDados["items"][nPos]['warehouse'      ] := (cAliasQry)->warehouse
		oDados["items"][nPos]['productionOrder'] := (cAliasQry)->productionOrder
		oDados["items"][nPos]['usedQuantity'   ] := (cAliasQry)->usedQuantity
		oDados["items"][nPos]['idPai'          ] := (cAliasQry)->idPai

		oDados["items"][nPos]['productDetail'  ] := Array(1)
		oDados["items"][nPos]['productDetail'  ][1] :=JsonObject():New()
		oDados["items"][nPos]['productDetail'  ][1]['product'           ] := (cAliasQry)->product
		oDados["items"][nPos]['productDetail'  ][1]['productDescription'] := (cAliasQry)->productDescription
		oDados["items"][nPos]['productDetail'  ][1]['supplier'          ] := (cAliasQry)->supplier
		oDados["items"][nPos]['productDetail'  ][1]['lote'              ] := (cAliasQry)->lote
		oDados["items"][nPos]['productDetail'  ][1]['subLote'           ] := (cAliasQry)->subLote
		oDados["items"][nPos]['productDetail'  ][1]['dateStart'         ] := getDate((cAliasQry)->dateStart)

		(cAliasQry)->(dbSkip())

		If nPos == pageSize
			//chegou no limite da pagina.
			Exit
		EndIf
	End

	If nPos == pageSize .And. (cAliasQry)->(!Eof())
		oDados["hasNext"] := .T.
	EndIf

	(cAliasQry)->(dbCloseArea())

	aResult[2] := EncodeUTF8(oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0003 //"Nenhum registro encontrado"
		aResult[3] := 400
	EndIf

	aSize(oDados["items"],0)
	aSize(aFiltros, 0)
	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type  Static Function
@author douglas.heydt
@since 09/11/2020
@version P12.1.30
@param cData, Character, Data no formato AAAAMMDD
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function getDate(dData)
	Local cData := ""
	If !Empty(dData)
		cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
	EndIf
Return cData

/*/{Protheus.doc} filtroCom
Adiciona os filtros na query das compras (SC1/SC7/SMH)

@type  Static Function
@author lucas.franca
@since 12/09/2023
@version P12
@param 01 aFiltros  , Array   , Array com os filtros para aplicar na query
@param 02 cTabFil   , Caracter, Tabela que será utilizado o filtro de filial
@param 03 cCampoFil , Caracter, Nome do campo de filial para uso no filtro
@param 04 aCamposOP , Array   , Array com os campos para aplicar o filtro de OP
@param 05 aCamposDoc, Array   , Array com os campos para aplicar o filtro de Documento
@param 06 aCamposId , Array   , Array com os campos para aplicar o filtro de ID Pai
@param 07 cBranchId , Caracter, Código da(s) filial(ais)
@return cFilter, Caracter, Condição SQL com os filtros
/*/
Static Function filtroCom(aFiltros, cTabFil, cCampoFil, aCamposOP, aCamposDoc, aCamposId, cBranchId)
	Local cFilter  := ""
	Local lUsaLike := .F.
	Local nIndex   := 0
	Local nTotal   := Len(aFiltros)

	For nIndex := 1 To nTotal
		lUsaLike := .F.
		If nIndex == 1
			cFilter += " AND ("
		Else
			cFilter += " OR "
		EndIf

		cFilter += " ("
		cFilter += "(" + PCPRasFili(cCampoFil, cTabFil, cBranchId) + " OR SMH.MH_TPDCSAI = 'TRANF_ES')"
		cFilter += " AND " + addFilCmp(aCamposOP, aFiltros[nIndex]["productionOrder"])
		If !Empty(aFiltros[nIndex]["documentId"])
			If _cTxtES $ aFiltros[nIndex]["documentId"] .Or. _cTxtPP $ aFiltros[nIndex]["documentId"]
				lUsaLike := .T.
			EndIf
			cFilter += " AND " + addFilCmp(aCamposDoc, aFiltros[nIndex]["documentId"], lUsaLike)
		EndIf
		If !Empty(aFiltros[nIndex]["idReg"])
			cFilter += " AND " + addFilCmp(aCamposId, aFiltros[nIndex]["idReg"])
		EndIf
		cFilter += ")"

	Next nIndex

	If nTotal > 0
		cFilter += ")"
	EndIf
Return cFilter

/*/{Protheus.doc} addFilCmp
Adiciona filtro em vários campos com a condição OR

@type  Static Function
@author lucas.franca
@since 13/09/2023
@version P12
@param 01 aCampos , Array   , Array com o nome dos campos para adicionar o filtro
@param 02 cValue  , Caracter, Valor para adicionar como filtro dos campos
@param 03 lUsaLike, Logic   , Identifica se utiliza like no lugar de = na comparação
@return cFilter, Caracter, Filtro SQL com os campos e valores
/*/
Static Function addFilCmp(aCampos, cValue, lUsaLike)
	Local cFilter := ""
	Local nIndex  := 0
	Local nTotal  := Len(aCampos)

	Default lUsaLike := .F.

	cFilter := "("
	For nIndex := 1 To nTotal
		If nIndex > 1
			cFilter += " OR "
		EndIf

		If lUsaLike
			cFilter += aCampos[nIndex] + " LIKE '" + cValue + "%' "
		Else
			cFilter += aCampos[nIndex] + " = '" + cValue + "' "
		EndIf
	Next nIndex
	cFilter += ")"
Return cFilter
