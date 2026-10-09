#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWLIBVERSION.CH'
 
//-----------------------------------------//
/*/{Protheus.doc} PGCXCOT
	Fonte de funções genéricas relacionadas
	a cotação do PGC.
/*/
//----------------------------------------//


/*/{Protheus.doc} setQuoteStatus
	Função para atualizar o status(DHU_STATUS) da cotação.
	1=Pendente;2=Análise pendente;3=Em análise;4=Finalizada;5=Excluída;6=Atendida Parcialmente
@author Leandro Fini
@since 31/01/2023
/*/
Function setQuoteStatus(cQuotationCode,cFilDHU)
Local aAreas        As Array
Local cStatus       As Character
Local lEditedQuote  As Logical
Default cQuotationCode  := ""
Default cFilDHU         := fwxFilial("DHU")

cStatus := "1"
lEditedQuote := .F.

aAreas := {DHU->(GetArea()),GetArea()}

DHU->(dbSetOrder(1)) //-- DHU_FILIAL+DHU_NUM
If DHU->(MsSeek(cFilDHU + cQuotationCode))

	If QuoteIsClosed(cQuotationCode,fwxFilial("DHV",cFilDHU))//Verifica se todos os saldos da DHV estão zerados.
		cStatus := "4"//Finalizada.
	ElseIf QuoteIsPartial(cQuotationCode,fwxFilial("SCE",cFilDHU)) //-- Verifica se a cotação possui pedido gerado
        cStatus := "6" //-- Atendida Parcialmente
    ElseIf !QuoteIsEdited(cQuotationCode,fwxFilial("SC8",cFilDHU)) //-- verifica se a cotação não foi editada
        cStatus := "1" //-- Pendente
    Else
        cStatus := AnalyzeStatus(cQuotationCode,fwxFilial("DHV",cFilDHU)) //-- 2-Análise pendente; 3-Em análise
	EndIf

	Reclock("DHU",.F.)
    DHU->DHU_STATUS := cStatus
	DHU->(MsUnlock())
EndIf

aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return .T.

/*/{Protheus.doc} QuoteIsEdited
	Função para verificar se a cotação já foi editada.
@author Leandro Fini
@since 31/01/2023
/*/
Static Function QuoteIsEdited(cQuotationCode,cFilSC8)

	Local cAliasTemp     := ""
    Local cQuery         := ''
    Local oQuery         := Nil
	Local lEditedQuote	 := .F.

	Default cQuotationCode := ""
    Default cFilSC8        := FWxFilial('SC8')

	cQuery := "SELECT" //-- Query para verificar se o item da cotação está Atendido/Sem estoque/Não vende
    cQuery += "   SC8.C8_FILIAL,"
    cQuery += "   SC8.C8_NUM,"
    cQuery += "   SC8.C8_FORNECE,"
    cQuery += "   SC8.C8_LOJA,"
    cQuery += "   SC8.C8_NUMPRO,"
    cQuery += "   SC8.C8_FORNOME"
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += "     AND SC8.C8_NUM = ?"
	cQuery += "     AND SC8.D_E_L_E_T_ = ' '"
    cQuery += "     AND SC8.C8_NUMPRO = ("
    cQuery += "         SELECT MAX(SC8_2.C8_NUMPRO)" //-- Apenas última proposta
    cQuery += "         FROM "+ RetSQLName("SC8") +" SC8_2"
    cQuery += "         WHERE SC8_2.C8_FILIAL = SC8.C8_FILIAL AND"
    cQuery += "             SC8_2.C8_NUM = SC8.C8_NUM AND"
    cQuery += "             SC8_2.C8_FORNECE = SC8.C8_FORNECE AND"
    cQuery += "             SC8_2.C8_LOJA = SC8.C8_LOJA AND"
    cQuery += "             SC8_2.C8_FORNOME = SC8.C8_FORNOME AND"
    cQuery += "             SC8_2.D_E_L_E_T_ = ' '"
    cQuery += "         )"
    cQuery += " GROUP BY SC8.C8_FILIAL, SC8.C8_NUM, C8_FORNECE, C8_LOJA, C8_NUMPRO, C8_FORNOME"
    cQuery += " HAVING"
    cQuery += "     ( SELECT COUNT(SC8_3.C8_ITEM)" //-- Será considerada como editada quando tiver algum item atendido e que não esteja desclassificado
    cQuery += "          FROM "+ RetSQLName("SC8") +" SC8_3"
    cQuery += "          WHERE SC8_3.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "              AND SC8_3.C8_NUM = SC8.C8_NUM"
    cQuery += "              AND SC8_3.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "              AND SC8_3.C8_LOJA = SC8.C8_LOJA"
    cQuery += "              AND SC8_3.C8_NUMPRO = SC8.C8_NUMPRO"
    cQuery += "              AND SC8_3.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "              AND SC8_3.C8_TOTAL > 0"
    cQuery += "              AND SC8_3.C8_SITUAC NOT IN('4','5')"
    cQuery += "              AND SC8_3.D_E_L_E_T_ = ' '"
    cQuery += "     ) > 0

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cFilSC8)
    oQuery:SetString(2, cQuotationCode)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        lEditedQuote := .T.
    EndIf

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return lEditedQuote

/*/{Protheus.doc} QuoteIsClosed
	Função para verificar se a cotação está fechada.
@author Leandro Fini
@since 31/01/2023
/*/
Static Function QuoteIsClosed(cQuotationCode,cFilDHV)

	Local cAliasTemp     := ""
    Local cQuery         := ''
    Local oQuery         := Nil
	Local lClosedQuote	 := .T.

	Default cQuotationCode  := ""
    Default cFilDHV         := FWxFilial('DHV')

	cQuery := "SELECT "
	cQuery += " DHV_FILIAL, DHV_NUM"
	cQuery += " FROM "+ RetSQLName("DHV") +" DHV"
	cQuery += " WHERE DHV_FILIAL = ?"
	cQuery += " AND DHV_NUM = ?"
	cQuery += " AND D_E_L_E_T_ = ' '"
	cQuery += " AND DHV_SALDO > 0 "
	cQuery += " GROUP BY DHV_FILIAL, DHV_NUM "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cFilDHV)
    oQuery:SetString(2, cQuotationCode)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        lClosedQuote := .F.
    EndIf

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return lClosedQuote

/*/{Protheus.doc} AnalyzeStatus
	Função para retornar o status da análise da cotação.
@author juan.felipe
@since 15/05/2023
/*/
Static Function AnalyzeStatus(cQuotationCode,cFilDHV)
	Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
	Local cStatus As Character
	Default cQuotationCode  := ""
    Default cFilDHV         := FWxFilial('DHV')

	cQuery := "SELECT "
	cQuery += " DHV_FILIAL, DHV_NUM, DHV_ITEM"
	cQuery += " FROM "+ RetSQLName("DHV") +" DHV"
	cQuery += " WHERE DHV_FILIAL = ?"
	cQuery += " AND DHV_NUM = ?"
	cQuery += " AND DHV_SALDO >= 0 AND DHV_SALDO < DHV_QUANT" //-- Verifica se é uma cotação em análise (Status = 3)
	cQuery += " AND D_E_L_E_T_ = ' '"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cFilDHV)
    oQuery:SetString(2, cQuotationCode)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        cStatus := PartialStatus(cQuotationCode, "3") //EM análise ou Atendido Parcialmente
    Else
        cStatus := '2' //-- Pronto para analisar
    EndIf

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)
Return cStatus


/*/{Protheus.doc} QuoteIsPartial
	Função para retornar se a cotaçao ja possui pedido gerado
@author ali.neto
@since 17/11/2024
/*/
Static Function QuoteIsPartial(cQuotationCode,cFilSCE)

    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Local lQuotePartial := .F.

	Default cQuotationCode  := ""
    Default cFilSCE := FWxFilial('SCE')

    cQuery := "SELECT "
	cQuery += " CE_NUMPED, CE_NUMCOT "
	cQuery += " FROM "+ RetSQLName("SCE") +" SCE"
	cQuery += " WHERE CE_FILIAL = ?"
	cQuery += " AND CE_NUMCOT = ?"
	cQuery += " AND D_E_L_E_T_ = ' '"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cFilSCE)
    oQuery:SetString(2, cQuotationCode)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        lQuotePartial := .T.
    EndIf

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return lQuotePartial



/*/{Protheus.doc} getLastProposal
	Retorna o código da última proposta do Fornecedor.
@author rd.santos
@since 23/03/2023
/*/
Function PGCLastProp(cQuotation,cSupplier,cStore,cCorporateName)
    Local cAliasTemp As Character
    Local cQuery As Character
    Local cProposal As Character
    Local nLenNumPro As Numeric
    Default cQuotationCode := ''
    Default cSupplier := ''
    Default cStore := ''
    Default cCorporateName := ''

    dbSelectArea('SC8')
    nLenNumPro := TamSX3('C8_NUMPRO')[1]
    cProposal := ''

    cQuery := "     SELECT MAX(SC8.C8_NUMPRO) PROPOSTA"
    cQuery += "     FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += "     WHERE SC8.C8_FILIAL = ? AND "
    cQuery += "         SC8.C8_NUM 		= ? AND "
    cQuery += "         SC8.C8_FORNECE 	= ? AND "
    cQuery += "         SC8.C8_LOJA 	= ? AND "
    If !Empty(cCorporateName)
        cQuery += "     SC8.C8_FORNOME 	= ? AND "
    EndIf
    cQuery += "         SC8.D_E_L_E_T_ 	= ' '"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuotation)
    oQuery:SetString(3, cSupplier)
    oQuery:SetString(4, cStore)

    If !Empty(cCorporateName)
        oQuery:SetString(5, cCorporateName)
    EndIf

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        cProposal := PadR((cAliasTemp)->PROPOSTA, nLenNumPro, ' ')
    EndIf

    (cAliasTemp)->(dbCloseArea())
    
    oQuery:Destroy()
    FreeObj(oQuery)
Return cProposal

/*/{Protheus.doc} PGCSC8Copy
	Retorna campos que devem ser copiados para a nova proposta da cotação.
@author juan.felipe
@param lAPI, logical, indica se os campos a serem retornados são da API.
@param lClear, logical, indica se retorna os campos a serem copiados independentemente do parâmetro MV_ZERPROP.
@since 30/03/2023
/*/
Function PGCSC8Copy(lAPI, lClear)
    Local cCopy As Character
	Default lAPI := .F.
	Default lClear := .F.
    
    cCopy := ''

	If lClear
		If lAPI
			cCopy := 'branch|deliveryBranch|quotationCode|supplier|store|productCode|item|proposal|'
			cCopy += 'gridItem|productDescription|corporateName|cnpj|supplierType|unity|quantity|email'
			cCopy += 'emissionDate|needDate'
			cCopy := Lower(cCopy)
		Else
			cCopy := 'C8_FILIAL|C8_ITEM|C8_NUMPRO|C8_PRODUTO|C8_QUANT|C8_UM|C8_CODTAB|C8_FORNECE|C8_LOJA|C8_FILENT|C8_EMISSAO|C8_NUM|C8_NUMSC|'
            cCopy += 'C8_ITEMSC|C8_ITSCGRD|C8_DATPRF|C8_IDENT|C8_SEGUM|C8_GRUPCOM|C8_ITEMGRD|C8_GRADE|C8_CODORCA|C8_ORIGEM|C8_FORNOME|C8_FORMAIL|'
			cCopy += 'B1_DESC|A2_NOME|A2_CGC|A2_TIPO|C8_OBS'
		EndIf
	EndIf
Return cCopy

/*/{Protheus.doc} PGCAnsweredAll
	Retorna se o fornecedor respondeu todos os itens da cotação.
@author juan.felipe
@since 16/05/2023
/*/
Function PGCAnsweredAll(cQuotationCode, cSupplier, cStore, cCorporateName)
    Local lRet As Logical
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Default cQuotationCode := ''
    Default cSupplier := ''
    Default cStore := ''
    Default cCorporateName := ''

    cQuery := " SELECT SC8.C8_FILIAL,"
    cQuery += "    SC8.C8_NUM,"
    cQuery += "    SC8.C8_FORNECE,"
    cQuery += "    SC8.C8_LOJA,"
    cQuery += "    SC8.C8_NUMPRO,"
    cQuery += "    SC8.C8_FORNOME"
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += " AND SC8.C8_NUM = ?"
    cQuery += " AND SC8.C8_FORNECE = ?"
    cQuery += " AND SC8.C8_LOJA = ?"
    cQuery += " AND SC8.C8_FORNOME = ?"
    cQuery += " AND SC8.C8_NUMPRO ="
    cQuery += "     (SELECT MAX(SC8_2.C8_NUMPRO)" //-- Apenas última proposta
    cQuery += "         FROM "+ RetSQLName("SC8") +" SC8_2"
    cQuery += "         WHERE SC8_2.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "         AND SC8_2.C8_NUM = SC8.C8_NUM"
    cQuery += "         AND SC8_2.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "         AND SC8_2.C8_LOJA = SC8.C8_LOJA"
    cQuery += "         AND SC8_2.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "         AND SC8_2.D_E_L_E_T_ = ' ' )"
    cQuery += " AND"
    cQuery += "     (SELECT COUNT(SC8_3.C8_ITEM)"
    cQuery += "         FROM "+ RetSQLName("SC8") +" SC8_3"
    cQuery += "         WHERE SC8_3.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "         AND SC8_3.C8_NUM = SC8.C8_NUM"
    cQuery += "         AND SC8_3.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "         AND SC8_3.C8_LOJA = SC8.C8_LOJA"
    cQuery += "         AND SC8_3.C8_NUMPRO = SC8.C8_NUMPRO"
    cQuery += "         AND SC8_3.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "         AND SC8_3.C8_TOTAL > 0 "
    cQuery += "         AND SC8_3.D_E_L_E_T_ = ' ' ) =" //-- Apenas quando a quantidade de itens atendidos seja igual a quantidade de itens da cotação
    cQuery += "     (SELECT COUNT(SC8_4.C8_ITEM)"
    cQuery += "         FROM "+ RetSQLName("SC8") +" SC8_4"
    cQuery += "         WHERE SC8_4.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "         AND SC8_4.C8_NUM = SC8.C8_NUM"
    cQuery += "         AND SC8_4.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "         AND SC8_4.C8_LOJA = SC8.C8_LOJA"
    cQuery += "         AND SC8_4.C8_NUMPRO = SC8.C8_NUMPRO"
    cQuery += "         AND SC8_4.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "         AND SC8_4.D_E_L_E_T_ = ' ' )"
    cQuery += " AND"
    cQuery += "   ( SELECT COUNT(SC8_5.C8_ITEM)" 
    cQuery += "        FROM "+ RetSQLName("SC8") +" SC8_5"
    cQuery += "        WHERE SC8_5.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "            AND SC8_5.C8_NUM = SC8.C8_NUM"
    cQuery += "            AND SC8_5.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "            AND SC8_5.C8_LOJA = SC8.C8_LOJA"
    cQuery += "            AND SC8_5.C8_NUMPRO = SC8.C8_NUMPRO"
    cQuery += "            AND SC8_5.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "            AND SC8_5.D_E_L_E_T_ = ' ' ) = " //-- Apenas quando a quantidade de itens da proposta for igual a quantidade total de itens da cotação (DHV)
    cQuery += "   ( SELECT COUNT(DHV.DHV_ITEM)" 
    cQuery += "        FROM "+ RetSQLName("DHV") +" DHV"
    cQuery += "        WHERE DHV.DHV_FILIAL = ?"
    cQuery += "            AND DHV.DHV_NUM = SC8.C8_NUM"
    cQuery += "            AND DHV.D_E_L_E_T_ = ' ' )"
    cQuery += " GROUP BY SC8.C8_FILIAL,"
    cQuery += "         SC8.C8_NUM,"
    cQuery += "         SC8.C8_FORNECE,"
    cQuery += "         SC8.C8_LOJA,"
    cQuery += "         SC8.C8_NUMPRO,"
    cQuery += "         SC8.C8_FORNOME"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuotationCode)
    oQuery:SetString(3, cSupplier)
    oQuery:SetString(4, cStore)
    oQuery:SetString(5, cCorporateName)
    oQuery:SetString(6, FwxFilial('DHV'))

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    lRet := !(cAliasTemp)->(Eof())

    (cAliasTemp)->(dbCloseArea())

    oQuery:Destroy()
Return lRet

/*/{Protheus.doc} PGCQtProp
	Quantidade de propostas da cotação
@author juan.felipe
@since 17/05/2023
/*/
Function PGCQtProp(cQuotationCode, cSupplier, cStore, cCorporateName)
    Local nRet As Numeric
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Default cQuotationCode := ''
    Default cSupplier := ''
    Default cStore := ''
    Default cCorporateName := ''

    nRet := 1

    cQuery := " SELECT SC8.C8_FILIAL,"
    cQuery += "    SC8.C8_NUM,"
    cQuery += "    SC8.C8_FORNECE,"
    cQuery += "    SC8.C8_LOJA,"
    cQuery += "    SC8.C8_FORNOME,"
    cQuery += "    COUNT(DISTINCT SC8.C8_NUMPRO) QTPROPOSALS"
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += " AND SC8.C8_NUM = ?"
    cQuery += " AND SC8.C8_FORNECE = ?"
    cQuery += " AND SC8.C8_LOJA = ?"
    cQuery += " AND SC8.C8_FORNOME = ?"
    cQuery += " AND SC8.D_E_L_E_T_ = ' '"
    cQuery += " GROUP BY SC8.C8_FILIAL,"
    cQuery += "         SC8.C8_NUM,"
    cQuery += "         SC8.C8_FORNECE,"
    cQuery += "         SC8.C8_LOJA,"
    cQuery += "         SC8.C8_FORNOME"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuotationCode)
    oQuery:SetString(3, cSupplier)
    oQuery:SetString(4, cStore)
    oQuery:SetString(5, cCorporateName)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        nRet := (cAliasTemp)->QTPROPOSALS
    EndIf

    (cAliasTemp)->(dbCloseArea())

    oQuery:Destroy()
Return nRet

/*/{Protheus.doc} PGCQtInOrder
	Retorna quantidade em pedido de compra do produto do fornecedor.
@author juan.felipe
@since 19/06/2023
@param cQuotation, character, código da cotação.
@param cProduct, character, código do produto.
@param cItem, character, código do item.
@param cGridItem, character, código do item grade.
@param cSupplier, character, código do fornecedor.
@param cStore, character, código da loja.
@param cProposal, character, código da proposta.
@return nBalance, numeric, quantidade em pedido de compra.
/*/
Function PGCQtInOrder(cQuotation, cProduct, cItem, cGridItem, cSupplier, cStore, cProposal)
    Local cQuery AS Character
    Local cAliasTemp AS Character
    Local nQuantityOrder As Numeric
    Default cQuotation := ''
    Default cProduct := ''
    Default cItem := ''
    Default cGridItem := ''
    Default cSupplier := ''
    Default cStore := ''
    Default cProposal := ''

    nQuantityOrder := 0

    cQuery := " SELECT" //-- Quantidade em pedido de compra
    cQuery += "    SUM(CE_QUANT) QUANTITYORDER"
    cQuery += "    FROM "+RetSqlName("SC8")+" SC8"
    cQuery += "    INNER JOIN "+RetSqlName("SCE")+" SCE ON"
    cQuery += "        SCE.CE_FILIAL = ?"
    cQuery += "        AND SCE.CE_NUMCOT = SC8.C8_NUM"
    cQuery += "        AND SCE.CE_ITEMCOT = SC8.C8_ITEM"
    cQuery += "        AND SCE.CE_PRODUTO = SC8.C8_PRODUTO"
    cQuery += "        AND SCE.CE_FORNECE = SC8.C8_FORNECE"
    cQuery += "        AND SCE.CE_LOJA = SC8.C8_LOJA"
    cQuery += "        AND SCE.CE_ITEMGRD = SC8.C8_ITEMGRD"
    cQuery += "        AND SCE.CE_NUMPRO = SC8.C8_NUMPRO"
    cQuery += "        AND SCE.D_E_L_E_T_ = ' '"
    cQuery += "    WHERE SC8.C8_FILIAL = ?"
    cQuery += "        AND SC8.C8_NUM = ?"
    cQuery += "        AND SC8.C8_PRODUTO = ?"
    cQuery += "        AND SC8.C8_ITEM = ?"
    cQuery += "        AND SC8.C8_ITEMGRD = ?"
    cQuery += "        AND SC8.C8_FORNECE = ?"
    cQuery += "        AND SC8.C8_LOJA = ?"
    cQuery += "        AND SC8.C8_NUMPRO = ?"
    cQuery += "        AND SC8.D_E_L_E_T_ = ' '"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SCE'))
    oQuery:SetString(2, FWxFilial('SC8'))
    oQuery:SetString(3, cQuotation)
    oQuery:SetString(4, cProduct)
    oQuery:SetString(5, cItem)
    oQuery:SetString(6, cGridItem)
    oQuery:SetString(7, cSupplier)
    oQuery:SetString(8, cStore)
    oQuery:SetString(9, cProposal)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        nQuantityOrder := (cAliasTemp)->QUANTITYORDER
    EndIf

    (cAliasTemp)->(dbCloseArea())

    oQuery:Destroy()
    FreeObj(oQuery)
Return nQuantityOrder

/*/{Protheus.doc} PGCQtAnswers
	Retorna quantidade de cotações respondidas
@author juan.felipe
@since 07/08/2023
@param cQuotationCode, character, código da cotação.
@return oJson, object, Json com a quantidade de propostas respondidas e descartadas
/*/
Function PGCQtAnswers(cQuotationCode)
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Local oJson As Object
    Local cBranch := FWxFilial('SC8')
    
    Default cQuotationCode := ''

    oJson := JsonObject():New()

    oJson['answered'] := 0
    oJson['discarded'] := 0
    
    cQuery := " SELECT  "
    cQuery += "    SC8.C8_FILIAL, "
    cQuery += "    SC8.C8_NUM, "
    cQuery += "    SC8.C8_FORNECE, "
    cQuery += "    SC8.C8_FORNOME, "
    cQuery += "    SC8.C8_LOJA, "
    cQuery += "    SC8.C8_NUMPRO, "

    cQuery += "    COUNT(*) AS QUANTITYITEMS, " //-- Quantidade de itens

    cQuery += "    SUM( "
    cQuery += "        CASE "
    cQuery += "            WHEN SC8.C8_TOTAL > 0 AND SC8.C8_SITUAC IN ('', '1') "  //-- 1=Considera
    cQuery += "            THEN 1 ELSE 0 "
    cQuery += "        END "
    cQuery += "    ) AS ANSWERED, " //-- Propostas respondidas

    cQuery += "    SUM( "
    cQuery += "        CASE "
    cQuery += "            WHEN SC8.C8_SITUAC IN ('4','5')  "
    cQuery += "            THEN 1 ELSE 0  "
    cQuery += "        END "
    cQuery += "    ) AS DISCARDED, "  //-- Propostas descartadas

    cQuery += "    SUM( "
    cQuery += "        CASE "
    cQuery += "            WHEN SC8.C8_SITUAC IN ('2','3') "
    cQuery += "            THEN 1 ELSE 0 "
    cQuery += "        END "
    cQuery += "    ) AS NOTATTEND " //-- Cotações sem estoque/não vende //-- 2=Sem estoque; 3=Não vende

    cQuery += " FROM "+ RetSQLName("SC8") +" SC8 "
    cQuery += " INNER JOIN ( "
    cQuery += "    SELECT "
    cQuery += "        C8_FILIAL, "
    cQuery += "        C8_NUM, "
    cQuery += "        C8_FORNECE, "
    cQuery += "        C8_LOJA, "
    cQuery += "        C8_FORNOME, "
    cQuery += "        MAX(C8_NUMPRO) AS MAX_NUMPRO "
    cQuery += "    FROM "+ RetSQLName("SC8") +" "
    cQuery += "    WHERE "
    cQuery += "        C8_FILIAL = ? "
    cQuery += "        AND C8_NUM = ? "
    cQuery += "        AND D_E_L_E_T_ = ' ' "
    cQuery += "    GROUP BY " 
    cQuery += "        C8_FILIAL, "
    cQuery += "        C8_NUM, "
    cQuery += "        C8_FORNECE, "
    cQuery += "        C8_LOJA, "
    cQuery += "        C8_FORNOME "
    cQuery += " ) MAXT "
    cQuery += "    ON MAXT.C8_FILIAL  = SC8.C8_FILIAL "
    cQuery += "    AND MAXT.C8_NUM     = SC8.C8_NUM "
    cQuery += "    AND MAXT.C8_FORNECE = SC8.C8_FORNECE "
    cQuery += "    AND MAXT.C8_LOJA    = SC8.C8_LOJA "
    cQuery += "    AND MAXT.C8_FORNOME = SC8.C8_FORNOME "
    cQuery += "    AND MAXT.MAX_NUMPRO = SC8.C8_NUMPRO " //-- Apenas a última proposta

    cQuery += " WHERE "
    cQuery += "    SC8.C8_FILIAL = ? "
    cQuery += "    AND SC8.C8_NUM = ? "
    cQuery += "    AND SC8.D_E_L_E_T_ = ' ' "

    cQuery += " GROUP BY  "
    cQuery += "    SC8.C8_FILIAL, "
    cQuery += "    SC8.C8_NUM, "
    cQuery += "    SC8.C8_FORNECE, "
    cQuery += "    SC8.C8_FORNOME, "
    cQuery += "    SC8.C8_LOJA, "
    cQuery += "    SC8.C8_NUMPRO "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, cBranch)
    oQuery:SetString(2, cQuotationCode)
    oQuery:SetString(3, cBranch)
    oQuery:SetString(4, cQuotationCode)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())
    
    While !(cAliasTemp)->(Eof())
        If (cAliasTempo)->ANSWERED > 0
            oJson['answered'] ++
        EndIf

        If (cAliasTempo)->DISCARDED > 0 .Or. ((cAliasTemp)->QUANTITYITEMS == (cAliasTemp)->NOTATTEND)
            oJson['discarded'] ++
        EndIf
        
        (cAliasTemp)->(dbSkip())
    EndDo

    (cAliasTemp)->(dbCloseArea())
    
    oQuery:Destroy()
    FreeObj(oQuery)
Return oJson

/*/{Protheus.doc} PGCRestBlc
	Restaura saldo da DHV de acordo com a SCE posicionada.
@author juan.felipe
@since 11/08/2023
@param cQuotationCode, character, código da cotação.
@param cItem, character, item da cotação.
@return Nil, nulo.
/*/
Function PGCRestBlc(cQuotationCode, cItem)
    Local aAreaDHV As Array

    If FWAliasInDic("DHV")
        aAreaDHV := DHV->(GetArea())
        DHV->(DbSetOrder(1)) //-- DHV_FILIAL + DHV_NUM + DHV_ITEM

        If DHV->(MsSeek(FWxFilial("DHV") + cQuotationCode + cItem))
            Reclock("DHV",.F.)
                DHV->DHV_SALDO := DHV->DHV_SALDO + SCE->CE_QUANT
            DHV->(MsUnlock())
        EndIf

        RestArea(aAreaDHV)
        FWFreeArray(aAreaDHV)
    EndIf
Return Nil

/*/{Protheus.doc} PGCQuotTot
	Retorna os valores totais da cotação
@author juan.felipe
@since 12/12/2023
@param cQuotationCode, character, código da cotação.
@param cSupplierCode, character, código do fornecedor.
@param cStore, character, loja do fornecedor.
@param cCorporateName, character, nome do fornecedor.
@return oJson, object, Json com os totais da cotação
/*/
Function PGCQuotTot(cQuotationCode, cSupplierCode, cStore, cCorporateName)
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Local oJson As Object
    Default cQuotationCode := ''
    Default cSupplierCode := ''
    Default cStore := ''
    Default cCorporateName := ''

    oJson := JsonObject():New()

    oJson['answered'] := 0
    oJson['discarded'] := 0

    cQuery := "SELECT"
    cQuery += "   SC8.C8_FILIAL,"
    cQuery += "   SC8.C8_NUM,"
    cQuery += "   SC8.C8_FORNECE,"
    cQuery += "   SC8.C8_FORNOME,"
    cQuery += "   SC8.C8_LOJA, "
    cQuery += "   SC8.C8_NUMPRO,"
    cQuery += "   SUM(C8_TOTAL+C8_VALFRE+C8_DESPESA+C8_SEGURO-C8_VLDESC) TOTAL,"
    cQuery += "   SUM(C8_VALFRE) TOTALSHIP,"
    cQuery += "   SUM(C8_DESPESA) TOTALEXPENSE,"
    cQuery += "   SUM(C8_SEGURO) TOTALINSURANCE"
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8"
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += "     AND SC8.C8_NUM = ?"
    cQuery += "     AND SC8.C8_FORNECE = ?"
    cQuery += "     AND SC8.C8_LOJA = ?"
    cQuery += "     AND SC8.C8_FORNOME = ?"
    cQuery += "     AND SC8.D_E_L_E_T_ = ' '"
    cQuery += "     AND SC8.C8_NUMPRO = (" //-- Apenas a última proposta
    cQuery += "         SELECT MAX(SC8_2.C8_NUMPRO)"
    cQuery += "             FROM "+ RetSQLName("SC8") +" SC8_2"
    cQuery += "             WHERE SC8_2.C8_FILIAL = SC8.C8_FILIAL"
    cQuery += "                 AND SC8_2.C8_NUM = SC8.C8_NUM"
    cQuery += "                 AND SC8_2.C8_FORNECE = SC8.C8_FORNECE"
    cQuery += "                 AND SC8_2.C8_LOJA = SC8.C8_LOJA"
    cQuery += "                 AND SC8_2.C8_FORNOME = SC8.C8_FORNOME"
    cQuery += "                 AND SC8_2.D_E_L_E_T_ = ' '"
    cQuery += "     )"
    cQuery += " GROUP BY SC8.C8_FILIAL, SC8.C8_NUM, SC8.C8_FORNECE,"
    cQuery += " SC8.C8_LOJA, SC8.C8_NUMPRO, C8_FORNOME"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuotationCode)
    oQuery:SetString(3, cSupplierCode)
    oQuery:SetString(4, cStore)
    oQuery:SetString(5, cCorporateName)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())
    
    oJson['total'         ] := 0
    oJson['totalship'     ] := 0
    oJson['totalexpense'  ] := 0
    oJson['totalinsurance'] := 0

    If !(cAliasTemp)->(Eof())
        oJson['total'         ] := (cAliasTemp)->TOTAL
        oJson['totalship'     ] := (cAliasTemp)->TOTALSHIP
        oJson['totalexpense'  ] := (cAliasTemp)->TOTALEXPENSE
        oJson['totalinsurance'] := (cAliasTemp)->TOTALINSURANCE
    EndIf

    (cAliasTemp)->(dbCloseArea())
    
    oQuery:Destroy()
    FreeObj(oQuery)
Return oJson


/*/{Protheus.doc} PartialStatus
	Função para retornar se existe Pedido de Compra (SC7) ou Contrato (CN9) gerado para a cotação, para identificar 
    o status atendido parcialmente. Se não tiver registro, significa que está em análise.
@param cQuotationCode, character, Número da cotação.
@param cStatusDef, character, status padrão, caso a query não retorne o status parcialmente atendida.
@return cStatus, character, status encontrado.
@author renan.martins
@since 01/2024
/*/
Static Function PartialStatus(cQuotationCode, cStatusDef)
	Local cAliasTemp        As Character
    Local cQuery            As Character
    Local oQuery            As Object
	Local cStatus           As Character
	Default cQuotationCode  := ""
    Default cStatusDef      := "3"

	cQuery := "  SELECT CN9.CN9_NUMCOT CODIGO "
	cQuery += "    FROM " + RetSQLName("CN9") + " CN9 "
	cQuery += "    WHERE CN9.CN9_FILIAL = ? "
	cQuery += "      AND CN9.CN9_NUMCOT = ? "
	cQuery += "      AND CN9.D_E_L_E_T_ = ' ' "
    cQuery += " UNION "
    cQuery += "  SELECT SC7.C7_NUMCOT CODIGO "
    cQuery += "    FROM " + RetSQLName("SC7") + " SC7 "
    cQuery += "    WHERE SC7.C7_FILIAL = ? "
    cQuery += "      AND SC7.C7_NUMCOT = ? "
    cQuery += "      AND SC7.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('CN9'))
    oQuery:SetString(2, cQuotationCode)
    oQuery:SetString(3, FWxFilial('SC7'))
    oQuery:SetString(4, cQuotationCode)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    If !(cAliasTemp)->(Eof())
        cStatus := '6' //-- Atendido Parcialmente
    Else
        cStatus := cStatusDef //-- Em Análise
    endif

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)
Return cStatus

/*/{Protheus.doc} NFCGetFilCom
	Obtém filtros do comprados cadastrados na rotina Compradores (COMA087).
@author juan.felipe
@since 17/05/2024
@return cFilter, character, filtro do comprador.
/*/
Function NFCGetFilCom()
    Local cFilter as character

    cFilter := ""

    // -- Busca filtro do comprador
    DbSelectArea("SY1")
    SY1->(DbSetOrder(3))//Y1_FILIAL + Y1_USER
    if SY1->(FieldPos('Y1_SOLCOM')) > 0 .And. SY1->(DbSeek(fwxFilial("SY1") + RetCodUsr())) .and. SuperGetMv('MV_FILTNFC', .F., .F.)
        cFilter := Alltrim(SY1->Y1_SOLCOM)
    endif
    if Existblock("NFCFILTSC") .and. empty(cFilter)
        cFilter := ExecBlock("NFCFILTSC",.F.,.F.)
    endif

    // -- Adapta o filtro em ADVPL para o padrão oData (queryURL)
    if !empty(cFilter)
        cFilter := StrTran(cFilter, "=="   , " =" ) //Igual
        cFilter := StrTran(cFilter, "!="   , " <>") // Diferente
        cFilter := StrTran(cFilter, ".and.", "AND")
        cFilter := StrTran(cFilter, ".And.", "AND")
        cFilter := StrTran(cFilter, ".AND.", "AND")
        cFilter := StrTran(cFilter, ".Or." , "OR" )
        cFilter := StrTran(cFilter, ".OR." , "OR" )
        cFilter := StrTran(cFilter, "dToS" , ""   )
        cFilter := StrTran(cFilter, '"'    , "'"  )
    endif
Return cFilter

/*/{Protheus.doc} NFCQtSuppliers
	Retorna quantidade de fornecedores da cotação.
@author juan.felipe
@since 01/07/2024
@param cQuotationCode, character, código da cotação.
@param oHashSup, hash, objeto hash de fornecedores.
@return nQuantity, numeric, quantidade de fornecedores.
/*/
Function NFCQtSuppliers(cQuotationCode, oHashSup)
    Local cAliasTemp As Character
    Local cQuery As Character
    Local oQuery As Object
    Local jData As Json
    Local nQuantity As Numeric
    Local lHasSup As Logical
    Local aData As Array
    Local nLenSupplier As Numeric
    Local nLenStore As Numeric
    Default cQuotationCode := ''
    Default oHashSup := Nil

    cQuery := ''
    nQuantity := 0
    aData := {}
    jData := JsonObject():New()
    lHasSup := oHashSup != Nil

    If lHasSup
        nLenSupplier := TamSX3("A2_COD")[1]
        nLenStore := TamSX3("A2_LOJA")[1]
    EndIf

    cQuery += " SELECT SC8.C8_FORNECE,"
    cQuery += "     SC8.C8_LOJA,"
    cQuery += "     SC8.C8_FORNOME"
    cQuery += " FROM " + RetSQLName("SC8") + " SC8 "
    cQuery += " WHERE SC8.C8_FILIAL = ?"
    cQuery += "     AND SC8.C8_NUM = ?"
    cQuery += "     AND SC8.D_E_L_E_T_ = ' '"
    cQuery += " GROUP BY SC8.C8_FORNECE,"
    cQuery += "     SC8.C8_LOJA,"
    cQuery += "     SC8.C8_FORNOME"

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC8'))
    oQuery:SetString(2, cQuotationCode)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())
    
    While !(cAliasTemp)->(Eof())
        nQuantity += 1

        If lHasSup
            cKey := AllTrim((cAliasTemp)->C8_FORNECE+(cAliasTemp)->C8_LOJA+(cAliasTemp)->C8_FORNOME)
            If !oHashSup:Get(cKey, Nil)
                aData := GetAdvFVal("SA2", {"A2_CGC", "A2_TIPO"}, FWxFilial("SA2") + PADR((cAliasTemp)->C8_FORNECE, nLenSupplier) + PADR((cAliasTemp)->C8_LOJA, nLenStore),1)
                
                jData := JsonObject():New()
                jData['c8_fornece'] := (cAliasTemp)->C8_FORNECE
                jData['c8_loja'] := (cAliasTemp)->C8_LOJA
                jData['c8_fornome'] := (cAliasTemp)->C8_FORNOME
                jData['c8_numpro'] := PGCLastProp(cQuotationCode, (cAliasTemp)->C8_FORNECE, (cAliasTemp)->C8_LOJA, (cAliasTemp)->C8_FORNOME)
                jData['answeredall'] := PGCAnsweredAll(cQuotationCode, (cAliasTemp)->C8_FORNECE, (cAliasTemp)->C8_LOJA, (cAliasTemp)->C8_FORNOME)
                jData['a2_cgc'] := aData[1]
                jData['a2_tipo'] := aData[2]
                oHashSup:Set(cKey, jData)
            EndIf
        EndIf

        (cAliasTemp)->(dbSkip())
    EndDo

    (cAliasTemp)->(dbCloseArea())

    oQuery:Destroy()
    FreeObj(oQuery)
    FwFreeArray(aData)
Return nQuantity

/*/{Protheus.doc} NFCEmailSCs
	Obtém e-mails vinculados às solicitações de compra.
@author juan.felipe
@since 13/02/2025
@param cQuotationCode, character, código da cotação.
@param aPurchases, array, códigos dos pedidos de compra.
@return oJsonEmails, object, Json com os e-mails e SCs.
/*/
Function NFCEmailSCs(cQuotationCode, aPurchases)
    Local oJsonEmails       As Object
    Local oQuery            As Object
    Local oUserSCs          As Object
    Local cQuery            As Character
    Local cAliasTemp        As Character
    Local cEmail            As Character
    Local cUser             As Character
    Local cNum              As Character
    Local cSCList           As Character
    Local cConcat           As Character
    Local nX                As Numeric
    Default cQuotationCode  := ''
    Default aPurchases      := {}

    oJsonEmails := JsonObject():New() // Objeto para armazenar usuários e SCs agrupados

    // Monta a query para buscar as SC1s
    cQuery := " SELECT DISTINCT "
    cQuery += "     SC1.C1_NUM, "
    cQuery += "     SC1.C1_USER "
    cQuery += " FROM " + RetSQLName("SC1") + " SC1 "
    cQuery += " WHERE "
    cQuery += "     SC1.C1_FILIAL = ? AND "

    If !Empty(cQuotationCode)
        cQuery += "     SC1.C1_COTACAO = ? AND "
    EndIf
    
    If Len(aPurchases) > 0
        cQuery += " SC1.C1_PEDIDO IN (?) AND "
    EndIf

    If SC1->(FieldPos('C1_NFCWF'))> 0
        cQuery += " SC1.C1_NFCWF = '1' AND "
    EndIf
    
    cQuery += "     SC1.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC1'))

    If !Empty(cQuotationCode)
        oQuery:SetString(2, cQuotationCode)
    EndIf

    If Len(aPurchases) > 0
        For nX := 1 To Len(aPurchases)
            If nX == 1
                cConcat := "'"+aPurchases[nX]+"'"
            Else
                cConcat += ",'"+aPurchases[nX]+"'"
            EndIf
        Next nX
        
        oQuery:SetUnsafe(IIf(Empty(cQuotationCode), 2, 3), cConcat)
    EndIf

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

    // Processamento dentro do While
    While !(cAliasTemp)->(Eof())
        cNum   := Alltrim((cAliasTemp)->C1_NUM)
        cUser  := (cAliasTemp)->C1_USER
        cEmail := Alltrim(UsrRetMail(cUser))

        If !Empty(cEmail) .And. IsEmail(cEmail) // Só processa se o email não for vazio
            oUserSCs := JsonObject():New()

            If !oJsonEmails:HasProperty(cUser) // Se não existe, cria uma nova entrada
                oUserSCs['c1_user'] := cUser
                oUserSCs['email'] := cEmail
                oUserSCs['requests'] := '[' + cNum + ']' 

                oJsonEmails[cUser] := oUserSCs
            Else // Se já existe, apenas adiciona o novo SC1 à string existente
                oUserSCs := oJsonEmails[cUser]
                cSCList := oUserSCs['requests']
                cSCList := StrTran(cSCList, ']', ', ' + cNum + ']')

                oUserSCs['requests'] := cSCList
                oJsonEmails[cUser] := oUserSCs
            EndIf
        EndIf

        (cAliasTemp)->(dbSkip())
    EndDo

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FwFreeObj(oQuery)

    // Retorna diretamente o objeto JSON agrupado
Return oJsonEmails

//-------------------------------------------------------------------
/*/{Protheus.doc} NFCRecSC1()
Retorna o RECNO da SC1 correspondente ao item da cotação

@author juan.felipe
 
@since 03/06/2025
@version 1.0
@param nRecSC8, numeric, RECNO da SC8.
@return lRet
/*/
//-------------------------------------------------------------------
Function NFCRecSC1(nRecSC8)
	Local nRet As Numeric
    Local cQuery As character
    Local oQuery As Object
    Local cAliasTemp As character

	Default nRecSC8 := SC8->(Recno())

    nRet := 0

    cQuery := " SELECT SC1.R_E_C_N_O_ SC1RECNO "
    cQuery += " FROM "+ RetSQLName("SC8") +" SC8 "
    cQuery += " JOIN "+ RetSQLName("SC1") +" SC1 "
	cQuery += "	ON 		SC1.C1_FILIAL     = ? "
	cQuery += "			AND SC1.C1_NUM    = SC8.C8_NUMSC "
	cQuery += "			AND SC1.C1_ITEM   = SC8.C8_ITEMSC "
	cQuery += "			AND SC1.D_E_L_E_T_ = ' ' "
	cQuery += "	WHERE 	SC8.R_E_C_N_O_    = ? "
	cQuery += "			AND SC8.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC1'))
    oQuery:SetNumeric(2, nRecSC8)

    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())

	If (cAliasTemp)->(!Eof())
		nRet := (cAliasTemp)->SC1RECNO
	EndIf

	(cAliasTemp)->(DbCloseArea())
    
    oQuery:Destroy()
    FreeObj(oQuery)
Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} NFCProdDesc()
Obtém descrição do produto conforme configuração do parâmetro MV_NFCDESC.

@author juan.felipe
 
@since 30/09/2025
@version 1.0
@param cProduct, character, códogo do produto.
@param cNumSC, character, número da solicitação de compra.
@param cItemSC, character, item da solicitação de compra.
@param cOption, character, opção de descrição (1=SB1, 2=SB5, 3=SC1).
@return cRet, character, descrição do produto.
/*/
//-------------------------------------------------------------------
Function NFCProdDesc(cProduct, cNumSC, cItemSC, cOption)
    Local cDesc As Character
    Default cProduct := ''
    Default cNumSC := ''
    Default cItemSC := ''
    Default cOption := SuperGetMv("MV_NFCDESC", .F., '')

    cDesc := ''

    If !Empty(cProduct)
        If cOption == '1' // Descrição do produto do cadastro de produtos SB1
            cDesc := GetAdvFVal("SB1", "B1_DESC", FWxFilial("SB1") + cProduct,1)
        ElseIf cOption == '2' // Descrição do produto da tabela de dados adicionais SB5
            cDesc := GetAdvFVal("SB5", "B5_CEME", FWxFilial("SB5") + cProduct,1)
            cDesc := Iif(Empty(cDesc), NFCProdDesc(cProduct, cNumSC, cItemSC,'3'), cDesc)
        ElseIf cOption == '3' .Or. Empty(cOption) // Descrição do produto da solicitação de compra SC1
            cDesc := GetAdvFVal("SC1","C1_DESCRI", FWxFilial("SC1") + cNumSC + cItemSC,1)
        EndIf
    EndIf
Return cDesc

/*/{Protheus.doc} NFCUpdMail
	Salvar o código usuário logado ou passado via parametro no campo DHU_USERWF. Com o 
    objetivo de identificar o último usuário responsavél por enviar o WF para o fornecedor.
@author gustavo.pedroso
@since 11/03/2026
@param código da cotação, código do usuário.
@return Nil, nulo.
/*/
Function NFCUpdMail(cQuote As Character, cUser As Character)
    Local aAreaDHU As Array 
    Default cQuote := ""
    Default cUser  := ""

    DbSelectArea("DHU")
    If DHU->(FieldPos('DHU_USERWF') > 0)
        If empty(cUser)
            cUser := RetCodUsr()
        Endif
        
        aAreaDHU := DHU->(GetArea())
        DHU->(DbSetOrder(1)) 

        If DHU->(MsSeek(FWxFilial("DHU") + cQuote))
            Reclock("DHU",.F.)
                DHU->DHU_USERWF := cUser
            DHU->(MsUnlock())
        EndIf

        RestArea(aAreaDHU)
        FWFreeArray(aAreaDHU)
    EndIf
Return Nil

/*/{Protheus.doc} NFCAdjQuo
	Ajusta cotações importadas incorretamente do legado.
    A função remove os registros da tabela SC8 relacionados à cotação informada e limpa o campo C1_COTACAO
    dos registros da tabela SC1 vinculados à mesma cotação.
@author gustavo.pedroso
@since 23/03/2026
@param cQuote
@return Nil, nulo.
/*/
Function NFCAdjQuo(cQuote As Character)
    Local cQrySc1       As Character
    Local cAliasSc1     As Character
    Local oQrySc1       As object
    Local cQrySc8       As Character
    Local cAliasSc8     As Character
    Local oQrySc8       As object
    Local aAreas        As Array

    cQrySc1         := ""
    cAliasSc1       := ""
    cQrySc8         := ""
    cAliasSc8       := ""
    aAreas          := {SC8->(GetArea()), SC1->(GetArea())}
    
    Default cQuote  := ""

    cQrySc8 := " SELECT R_E_C_N_O_ SC8_RECNO "
    cQrySc8 += " FROM "+RetSqlName("SC8")+" SC8 "
    cQrySc8 += " WHERE SC8.C8_FILIAL= ?  "
    cQrySc8 += " AND SC8.C8_NUM     = ?  "
    cQrySc8 += " AND SC8.D_E_L_E_T_ = ? "

    oQrySc8 := FwExecStatement():New(cQrySc8)
    oQrySc8:SetString(1 ,xFilial("SC8"))
    oQrySc8:SetString(2 ,cQuote)
    oQrySc8:SetString(3 ," ")

    cAliasSc8 := oQrySc8:OpenAlias()

    While !(cAliasSc8)->(Eof())
        If !empty((cAliasSc8)->SC8_RECNO)
            SC8->(DbGoTo((cAliasSc8)->SC8_RECNO))
            If SC8->(RecLock("SC8", .F.))
                SC8->(DbDelete())
                SC8->(MsUnlock())
            EndIf  
        EndIf        
        (cAliasSc8)->(dbSkip())				
    EndDo
    (cAliasSc8)->(dbCloseArea())
    oQrySc8:Destroy()


    cQrySc1 := " SELECT R_E_C_N_O_ SC1_RECNO "
    cQrySc1 += " FROM "+RetSqlName("SC1")+" SC1 "
    cQrySc1 += " WHERE SC1.C1_FILIAL= ?  "
    cQrySc1 += " AND SC1.C1_COTACAO = ?  "
    cQrySc1 += " AND SC1.D_E_L_E_T_ = ? "

    oQrySc1 := FwExecStatement():New(cQrySc1)
    oQrySc1:SetString(1 ,xFilial("SC1"))
    oQrySc1:SetString(2 ,cQuote)
    oQrySc1:SetString(3 ," ")

    cAliasSc1 := oQrySc1:OpenAlias()

    While !(cAliasSc1)->(Eof())
        If !empty((cAliasSc1)->SC1_RECNO)
            SC1->(DbGoTo((cAliasSc1)->SC1_RECNO))
            If SC1->(RecLock("SC1", .F.))
                SC1->C1_COTACAO := ''
                SC1->(MsUnlock())
            EndIf  
        EndIf        
        (cAliasSc1)->(dbSkip())				
    EndDo
    (cAliasSc1)->(dbCloseArea())
    oQrySc1:Destroy()


    FreeObj(oQrySc8)
    FreeObj(oQrySc1)
    aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
return Nil

/*/{Protheus.doc} NFCPrdAdjt
    Tem como objetivo ajustar os valores dos campos b1_grupo, bm_desc e productcodite(b1_codite), com base na filial da SC1,
    por meio do array retornado pela query da api de SC's Centralizadas com o parametro MV_VEICULO ativo
    @type  Function
    @author user gustavo.pedroso
    @since 17/04/2026
    @version version
    @param aItems
    @return aItems
    /*/
Function NFCPrdAdjt(aItems as Array)
    Local cCodeProdGroup    As character
    Local cDescProdGroup    As character
    Local cCodeProdCodite   As character
    Local cKey              As character
    Local lMvVeic           As Logical
    Local nX                As Numeric
    Local oInfoProducts     As Object
    Default aItems          := {}

    cCodeProdGroup  := ""
    cDescProdGroup  := ""
    cCodeProdCodite := ""
    lMvVeic         := SuperGetMV("MV_VEICULO",.F.,"N") == "S" 
    nX              := 0
    oInfoProducts   := JsonObject():New()

    If lMvVeic
        DbSelectArea('SB1')
        lMvVeic := SB1->(FieldPos('B1_CODITE')) > 0
    Endif
    
    For nX := 1 To Len(aItems)
        cKey := aItems[nX]['c1_filial'] + aItems[nX]['c1_produto']
        if !empty(aItems[nX]['c1_produto'])
            If oInfoProducts[cKey] == Nil
                oInfoProducts[cKey] := JsonObject():New()
            EndIf

            // --- B1_GRUPO (SB1) ---
            if oInfoProducts[cKey]['b1_grupo'] != Nil
                aItems[nX]['b1_grupo'] := oInfoProducts[cKey]['b1_grupo']
            else    
                cCodeProdGroup                   := GetAdvFVal("SB1", "B1_GRUPO", cKey, 1)
                aItems[nX]['b1_grupo']           := cCodeProdGroup
                oInfoProducts[cKey]['b1_grupo']  := cCodeProdGroup
            endif

            // --- BM_DESC (SBM) ---
            if !empty(aItems[nX]['b1_grupo'])
                if oInfoProducts[cKey]['bm_desc'] != Nil
                    aItems[nX]['bm_desc'] := oInfoProducts[cKey]['bm_desc']
                else    
                    cDescProdGroup                  := GetAdvFVal("SBM", "BM_DESC", aItems[nX]['c1_filial'] + aItems[nX]['b1_grupo'], 1)
                    aItems[nX]['bm_desc']           := cDescProdGroup
                    oInfoProducts[cKey]['bm_desc']  := cDescProdGroup
                endif
            endif

            // --- B1_CODITE (SB1) ---
            if lMvVeic
                if oInfoProducts[cKey]['b1_codite'] != Nil
                    aItems[nX]['productcodite'] := oInfoProducts[cKey]['b1_codite']
                else
                    cCodeProdCodite                  := GetAdvFVal("SB1", "B1_CODITE", cKey ,1)
                    aItems[nX]['productcodite']      := cCodeProdCodite
                    oInfoProducts[cKey]['b1_codite'] := cCodeProdCodite
                endif
            endif    
        endif
    Next nX 
    FreeObj(oInfoProducts)
Return aItems

/*/{Protheus.doc} NFCCallAdjQtL
    Valida e prepara as variáveis necessárias para a execução das rotinas de ajuste dos itens da cotação, migrada do legado.
    @type  Function
    @author user gustavo.pedroso
    @since  03/06/2026
    @version version
    @param cQuote
    @return Nil
/*/
Function NFCCallAdjQtL(cQuote As Character)
    Local aValFields As Array
    Local oDelItsSc8 As object

    Default cQuote := ""

    cDhuLegacy  := ""
    cQuote      := StrTran(cQuote, "'", "")

    DbSelectArea('DHU')
    If !Empty(cQuote) .AND. DHU->(FieldPos('DHU_LEGACY')) > 0 .AND. DHU->(FieldPos('DHU_AJCOTL')) > 0 .AND. FindFunction("NFCCreatAdjQtL") 
        aValFields := GetAdvFVal('DHU', {'DHU_LEGACY', 'DHU_AJCOTL'}, xFilial('DHU') + cQuote, 1)

        If (Empty(aValFields[2]) .OR. aValFields[2] == "2") .AND. aValFields[1] == "2" 
            oDelItsSc8  := NFCGetDelItsSc8(cQuote) // Retorna itens deletados da SC8

            If Len(oDelItsSc8:GetNames()) > 0
                NFCAdjtemsDhv(cQuote, oDelItsSc8) // Verifica se a numeração de itens deletados(C8_ITEM) estão sendo usados na DHV
            EndIf 

            NFCCreatAdjQtL(cQuote) // Cria array para ajustar numeração de itens da SC8 e SCE com base na DHV_ITEM.
        EndIf
    EndIf

    FwFreeObj(oDelItsSc8)
    FwFreeArray(aValFields) 
Return Nil

/*/{Protheus.doc} NFCGetDelItsSc8
    Retorna o codigo do campo C8_ITEM, do registros deletados da cotação
    @type  Function
    @author user gustavo.pedroso
    @since  12/06/2026
    @version version
    @param cQuote
    @return oDelItsSc8 = Objeto com os itens delatos da SC8
/*/
Function NFCGetDelItsSc8(cQuote As Character)
    Local cQuery        As Character
    Local cAliasQry     As Character
    Local oDelItsSc8    As object
    Local oQuery        As object

    Default cQuote := ""

    cQuery      := ""
    cAliasQry   := ""
    oDelItsSc8  := JsonObject():New()

    cQuery := " SELECT DISTINCT C8_ITEM"
    cQuery += " FROM " + RetSQLName("SC8") 
    cQuery += " WHERE C8_FILIAL   = ?  "
    cQuery += "    AND C8_NUM     = ?  "
    cQuery += "    AND D_E_L_E_T_  = '*' "

    oQuery := FwExecStatement():New(cQuery)
    oQuery:SetString(1 ,xFilial("SC8"))
    oQuery:SetString(2 ,cQuote)

    cAliasQry := oQuery:OpenAlias()

    While !(cAliasQry)->(Eof())
        oDelItsSc8[Alltrim((cAliasQry)->C8_ITEM)] := .T.
        (cAliasQry)->(dbSkip())  
    EndDo
    (cAliasQry)->(dbCloseArea())
    oQuery:Destroy()
    FwFreeObj(oQuery)
Return oDelItsSc8

/*/{Protheus.doc} NFCAdjtemsDhv
    Com o retorno dos itens deletados da função NFCGetDelItsSc8, verifica se estes estão sendo usados na DHV. 
    Caso esteja, recria a numeração de itens da DHV.
    @type  Function
    @author user gustavo.pedroso
    @since  12/06/2026
    @version version
    @param cQuote, oDelItsSc8 = Json com os itens deletados da SC8.
    @return Nil
/*/
Function NFCAdjtemsDhv(cQuote As Character, oDelItsSc8 As Json)
    Local cQuery            As Character
    Local cAliasQry         As Character
    Local cNewItem          As Character
    Local oQuery            As object
    Local aRecnoDhv         As Array
    Local aAreaDHV          As Array
    Local lItemDelUtilDhv   As Logical
    Local nSizeDhv          As Numeric
    Local nX                As Numeric

    Default cQuote      := ""
    Default oDelItsSc8  := JsonObject():New()

    cQuery          := ""
    cAliasQry       := ""
    cNewItem        := ""
    aRecnoDhv       := {}
    aAreaDHV        := DHV->(GetArea())
    lItemDelUtilDhv := .F.
    nSizeDhv        := 0
    nX              := 0

    cQuery := " SELECT DHV_ITEM, R_E_C_N_O_ AS REC"
    cQuery += " FROM " + RetSQLName("DHV")
    cQuery += " WHERE DHV_FILIAL   = ?  "
    cQuery += "    AND DHV_NUM     = ?  "
    cQuery += "    AND D_E_L_E_T_  = ' ' "

    oQuery := FwExecStatement():New(cQuery)
    oQuery:SetString(1 ,xFilial("DHV"))
    oQuery:SetString(2 ,cQuote)

    cAliasQry := oQuery:OpenAlias()

    // Verifico se o item deletado da SC8 está sendo usado na DHV
    While !(cAliasQry)->(Eof())
   
        If oDelItsSc8:HasProperty(Alltrim((cAliasQry)->DHV_ITEM))
            lItemDelUtilDhv := .T.
        EndIf

        AAdd(aRecnoDhv, (cAliasQry)->REC)  
        
        (cAliasQry)->(dbSkip())  
    EndDo
    (cAliasQry)->(dbCloseArea())
    oQuery:Destroy()
    
    // Remonto os itens da DHV
    nSizeDhv := Len(aRecnoDhv)
    If lItemDelUtilDhv
        // "Limpo" os itens para que não ocorra problema de chave única
        cNewItem := "ZZZ1"
        For nX := 1 To nSizeDhv
            DHV->(DbGoTo(aRecnoDhv[nX]))
            If Reclock("DHV", .F.)
                DHV->DHV_ITEM := cNewItem
                cNewItem := Soma1(cNewItem)
                DHV->(MsUnlock())
            EndIf 
        Next nX

        // Crio uma nova numeração na DHV sem usar a numeração dos itens que foram deletados na SC8.
        cNewItem := "0001"
        For nX := 1 To nSizeDhv
            While oDelItsSc8[cNewItem] != Nil
                cNewItem := Soma1(cNewItem)
            EndDo
            DHV->(DbGoTo(aRecnoDhv[nX]))
            If Reclock("DHV", .F.)
                DHV->DHV_ITEM := cNewItem
                cNewItem := Soma1(cNewItem)
                DHV->(MsUnlock())
            EndIf 
        Next nX
    EndIf

    FwFreeObj(oQuery)
    RestArea(aAreaDHV)
    FwFreeArray(aAreaDHV) 
    FwFreeArray(aRecnoDhv)  
Return Nil

/*/{Protheus.doc} NFCCreatAdjQtL
    Com base no objeto retornado da função NFCRelDhvSc8, gera os arrays de ajustes para sincronização de itens entre as tabelas SC8/SCE e a tabela DHV,
    e posteriormente dispara a atualização das tabelas(NFCAdjItsCeC8).  
    ** Função somente para cotaçoes migradas do legado.
    @type  Function
    @author user gustavo.pedroso
    @since  03/06/2026
    @version version
    @param cQuote 
    @return Nil
/*/
Function NFCCreatAdjQtL(cQuote As Character)
    Local cKeyAdjTbs As Character
    Local aUpdSc8    As Array 
    Local aUpdSce    As Array 
    Local aAreas     As Array 
    Local aArrays    As Array 
    Local oAdjTbs    As object

    Default cQuote := ""

    cKeyAdjTbs := "" 
    aUpdSc8    := {}
    aUpdSce    := {}
    aArrays    := {}
    aAreas     := {SC8->(GetArea()), SCE->(GetArea())}

    oAdjTbs  := NFCRelDhvSc8(cQuote)

    // Para cada chave (NUM SC + ITEM SC) onde está relacionado o código do item da DHV,
    // salvo no array o indice da tabela SC8 ou SCE e o código do item DHV para ser alterado posteriomente
    If oAdjTbs <> Nil
        SC8->(dbSetOrder(1))
        If SC8->(Msseek(xFilial("SC8") + cQuote))
            While SC8->(!Eof()) .AND. SC8->C8_FILIAL == xFilial("SC8") .AND. SC8->C8_NUM == cQuote
                cKeyAdjTbs := Alltrim(SC8->C8_NUMSC) + Alltrim(SC8->C8_ITEMSC) 
                If oAdjTbs[cKeyAdjTbs] <> Nil .AND. oAdjTbs[cKeyAdjTbs]:hasproperty('dhvItem')
                    If (!empty(SC8->C8_NUMPED) .OR. !empty(SC8->C8_NUMCON)) .AND. !("XXXX" $ SC8->C8_NUMPED)
                        SCE->(dbSetOrder(1))
                        If SCE->(Msseek(xFilial("SCE") + SC8->(C8_NUM+C8_ITEM+C8_PRODUTO+C8_FORNECE+C8_LOJA)))
                            Aadd(aUpdSce, { SCE->(RecNo()), oAdjTbs[cKeyAdjTbs]['dhvItem'] })
                        EndIf
                    EndIf
                    Aadd(aUpdSc8, { SC8->(RecNo()), oAdjTbs[cKeyAdjTbs]['dhvItem'] })
                EndIf
                SC8->(DbSkip())
            EndDo
        EndIf    
    EndIf

    // Atualização da SCE e SC8
    If Len(aUpdSce) > 0 .OR. Len(aUpdSc8) > 0
        NFCAdjItsCeC8(aUpdSce, aUpdSc8, cQuote)
    Endif

    aArrays := {aUpdSc8, aUpdSce}

    aEval(aArrays, {|x| FwFreeArray(x)})
    FwFreeArray(aArrays)
    aEval(aAreas, {|x| RestArea(x) ,FwFreeArray(x)})
    FwFreeArray(aAreas)
    FwFreeObj(oAdjTbs)
Return Nil

/*/{Protheus.doc} NFCRelDhvSc8
    Busca os itens da cotação e retorna um JSON mapeando as chaves da SC8(Num SC + Item SC) com o item correspondente da DHV.
    ** Função somente para cotaçôes migradas do legado.
    @type  Function
    @author user gustavo.pedroso
    @since  05/06/2026
    @version version
    @param cQuote
    @return oAdjTbs = Objeto com a relação
    /*/
Function NFCRelDhvSc8(cQuote As Character)
    Local cQuery            As Character
    Local cAliasQry         As Character
    Local cKeyAdjTbs        As Character
    Local cKeyProd          As Character
    Local cKeyMap           As Character
    Local cDhvItem          As Character
    Local nPosItem          As Numeric
    Local oAdjTbs           As object
    Local oQuery            As object
    Local oDrawerItsDhv     As object

    Default cQuote   := ""

    cAliasQry       := "" 
    cKeyAdjTbs      := "" 
    cKeyProd        := ""
    cKeyMap         := ""
    cDhvItem        := ""
    nPosItem        := 0
    oAdjTbs         := JsonObject():New()
    oDrawerItsDhv   := NFCDrawerItsDhv(cQuote)
    
    cQuery := " SELECT MIN(DHV_ITEM) AS DHV_ITEM, DHV_CODPRO, DHV_QUANT, C8_NUMSC, C8_ITEMSC "
    cQuery += " FROM " + RetSQLName("DHV") + " DHV "
    cQuery += "    LEFT JOIN " + RetSQLName("SC8") + " SC8 "
    cQuery += "      ON SC8.C8_FILIAL = DHV.DHV_FILIAL " 
    cQuery += "     AND SC8.C8_NUM = DHV.DHV_NUM "
    cQuery += "     AND SC8.C8_PRODUTO = DHV.DHV_CODPRO "
    cQuery += "     AND SC8.C8_QUANT = DHV.DHV_QUANT "
    cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE DHV.DHV_FILIAL   = ?  "
    cQuery += "    AND DHV.DHV_NUM     = ?  "
    cQuery += "    AND DHV.D_E_L_E_T_  = ' ' "
    cQuery += " GROUP BY DHV_CODPRO, DHV_QUANT, C8_NUMSC, C8_ITEMSC "

    oQuery := FwExecStatement():New(cQuery)
    oQuery:SetString(1 ,xFilial("DHV"))
    oQuery:SetString(2 ,cQuote)

    cAliasQry := oQuery:OpenAlias()

    While !(cAliasQry)->(Eof())
        If !Empty((cAliasQry)->C8_NUMSC) .AND. !Empty((cAliasQry)->C8_ITEMSC)
            
            cKeyAdjTbs := Alltrim((cAliasQry)->C8_NUMSC) + Alltrim((cAliasQry)->C8_ITEMSC) 
            
            If oAdjTbs[cKeyAdjTbs] == Nil
                
                cKeyMap := Alltrim((cAliasQry)->DHV_CODPRO) + "_" + Alltrim(Str((cAliasQry)->DHV_QUANT))
                
                // Inicialização Padrão
                cDhvItem := (cAliasQry)->DHV_ITEM
                
                // Se localizamos o mapeamento real para este produto/quantidade
                If oDrawerItsDhv[cKeyMap] != Nil
                    
                    // Avanço o index para pegar o código do item que ainda não foi usado por esse produto
                    oDrawerItsDhv[cKeyMap]['index']++
                    nPosItem := oDrawerItsDhv[cKeyMap]['index']
                    
                    // Se ainda houver numeração de item para esse produto
                    If nPosItem <= Len(oDrawerItsDhv[cKeyMap]['items'])
                        cDhvItem := oDrawerItsDhv[cKeyMap]['items'][nPosItem]
                    EndIf 
                EndIf

                // Grava a relação de Sc/Item x dhv_item
                oAdjTbs[cKeyAdjTbs] := JsonObject():New()
                oAdjTbs[cKeyAdjTbs]['dhvItem'] := cDhvItem
                
            EndIf    
        EndIf
        (cAliasQry)->(dbSkip())             
    EndDo
    (cAliasQry)->(dbCloseArea())
    oQuery:Destroy()

    FwFreeObj(oQuery)
    FwFreeObj(oDrawerItsDhv)
Return oAdjTbs

/*/{Protheus.doc} NFCDrawerItsDhv
    Gera um mapa em JSON dos itens ativos da tabela DHV para a cotação informada. 
    Os itens são agrupados por uma chave composta de Produto e Quantidade, criando 
    uma "gaveta" de numerações para auxiliar no vínculo de produtos repetidos.
    ** Função somente para cotaçôes migradas do legado.
    @type  Function
    @author user gustavo.pedroso
    @since  12/06/2026
    @version version
    @param cQuote
    @return oDrawerItens, JsonObject, Objeto contendo chaves no formato "Produto_Quantidade". 
            Cada chave armazena um array 'items' com os itens físicos da DHV (ex: '0001', '0002') 
            e um 'index' numérico para controle de consumo.
    /*/
Function NFCDrawerItsDhv(cQuote As Character)
    Local cQuery        As Character
    Local cAliasQry     As Character
    Local cItem         As Character
    Local oDrawerItens  As object
    Local oQuery        As object

    Default cQuote      := ""

    cQuery          := ""
    cAliasQry       := ""
    cItem           := ""
    oDrawerItens    := JsonObject():New()

    cQuery := " SELECT DHV_ITEM, DHV_CODPRO, DHV_QUANT, R_E_C_N_O_ AS REC"
    cQuery += " FROM " + RetSQLName("DHV") 
    cQuery += " WHERE DHV_FILIAL   = ?  "
    cQuery += "    AND DHV_NUM     = ?  "
    cQuery += "    AND D_E_L_E_T_  = ' ' "

    oQuery := FwExecStatement():New(cQuery)
    oQuery:SetString(1 ,xFilial("DHV"))
    oQuery:SetString(2 ,cQuote)

    cAliasQry := oQuery:OpenAlias()

    // Criação da lista/Gaveta de itens para cada combinação de Produto + Quantidade
    While !(cAliasQry)->(Eof())
        cItem           := (cAliasQry)->DHV_ITEM
        cKeyMap         := Alltrim((cAliasQry)->DHV_CODPRO) + "_" + Alltrim(Str((cAliasQry)->DHV_QUANT)) 
        
        If oDrawerItens[cKeyMap] == Nil
            oDrawerItens[cKeyMap] := JsonObject():New()
            oDrawerItens[cKeyMap]['items']    := {} // Array com os itens
            oDrawerItens[cKeyMap]['index']    := 0  // indice para identificar qual numeração de item ja foi usado.
        EndIf

        // Adiciona o item (Ex: '0001', '0002', '0004')
        AAdd(oDrawerItens[cKeyMap]['items'], cItem)
    
        (cAliasQry)->(dbSkip())  
    EndDo
    (cAliasQry)->(dbCloseArea())
    oQuery:Destroy()
    FwFreeObj(oQuery)

Return oDrawerItens

/*/{Protheus.doc} NFCAdjItsCeC8
    Ajusta os itens das tabelas SC8 e SCE com base da numeração dos itens da DHV.
    ** Função somente para cotaçôes migradas do legado.
    @type  Function
    @author user gustavo.pedroso
    @since  03/06/2026
    @version version
    @param aUpdSce/aUpdSc8 = Array com o recno e a numeração do item da dhv, cQuote
    @return Nil
    /*/
Function NFCAdjItsCeC8(aUpdSce As Array, aUpdSc8 As Array, cQuote As Character)
    Local nX            As Numeric
    Local nSizeSce      As Numeric
    Local nSizeSc8      As Numeric
    Local aAreas        As Array
    Local cNewItem      As Character 

    Default aUpdSce := {}
    Default aUpdSc8 := {}
    Default cQuote  := ""

    nX          := 0
    aAreas      := {SCE->(GetArea()), SC8->(GetArea()), DHU->(GetArea())}
    nSizeSce    := Len(aUpdSce)
    nSizeSc8    := Len(aUpdSc8)

    // "Limpo" os itens para que não ocorra problema de chave única
    cNewItem := "ZZZ1"
    For nX := 1 To nSizeSce
        SCE->(DbGoTo(aUpdSce[nX][1]))
        If Reclock("SCE", .F.)
            SCE->CE_ITEMCOT := cNewItem
            cNewItem := Soma1(cNewItem)
            SCE->(MsUnlock())
        EndIf 
    Next nX

    cNewItem := "ZZZ1"
    For nX := 1 To nSizeSc8
        SC8->(DbGoTo(aUpdSc8[nX][1]))
        If Reclock("SC8", .F.)
            SC8->C8_ITEM := cNewItem
            cNewItem := Soma1(cNewItem)
            SC8->(MsUnlock())
        EndIf 
    Next nX

    // Ajusto a numeração dos itens equivalente aos itens da DHV
    For nX := 1 To nSizeSce
        SCE->(DbGoTo(aUpdSce[nX][1]))
        If Reclock("SCE", .F.)
            SCE->CE_ITEMCOT := aUpdSce[nX][2]
            SCE->(MsUnlock())
        EndIf 
    Next nX

    For nX := 1 To nSizeSc8
        SC8->(DbGoTo(aUpdSc8[nX][1]))
        If Reclock("SC8", .F.)
            SC8->C8_ITEM := aUpdSc8[nX][2]
            SC8->(MsUnlock())  
        EndIf 
    Next nX

    If DHU->(FieldPos('DHU_AJCOTL')) > 0 
        If DHU->(Dbseek(fwxFilial("DHU") + cQuote))
            If Reclock("DHU", .F.)
                DHU->DHU_AJCOTL := "1"
                DHU->(MsUnlock())
            EndIf     
        EndIf
    EndIf

    aEval(aAreas, {|x| RestArea(x) ,FwFreeArray(x)})
    FwFreeArray(aAreas)
    FWFreeArray(aUpdSce)
    FWFreeArray(aUpdSc8)
Return Nil
