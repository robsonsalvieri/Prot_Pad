#INCLUDE 'PROTHEUS.CH'
#INCLUDE "PINSC010.CH"
#INCLUDE 'InsightDefs.ch'

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ResultMockSales
Retorna um JsonObject contendo o mock de resposta de sales recommendation.

@return JsonObject

@author Victor Vieira
@since 03/06/2026
/*/
//---------------------------------------------------------------------------------------------
Function ResultMockSales()

	Local cAliasQuery      as Character
	Local oData            as Object
	Local oItem            as Object
	Local aSales  		   as Array
	Local aArea            as Array

	aSales := {}
	aArea := GetArea()
	oData := JsonObject():New()

	cAliasQuery := GetMockSalesQuery()

	If !Empty( cAliasQuery )
		While (cAliasQuery)->(!Eof())
			oItem := JsonObject():New()
			oItem["rating"] := 0.1961
			oItem["branch"] := AllTrim( (cAliasQuery)->BRANCH )
			oItem["product"] := AllTrim( (cAliasQuery)->product_code )
			oItem["mock_order"] := AllTrim( (cAliasQuery)->mock_order )
			oItem["customer"] := AllTrim( (cAliasQuery)->CUSTOMER )
			oItem["quantity"] :=  (cAliasQuery)->quantity 
			oItem["federal_id"] := AllTrim( (cAliasQuery)->FEDERALID )
			oItem["product_type"] := AllTrim( (cAliasQuery)->product_type )
			oItem["sales_person"] := AllTrim( (cAliasQuery)->sales_person )
			oItem["customer_name"] := AllTrim( (cAliasQuery)->customer_name )
			oItem["product_group"] := AllTrim( (cAliasQuery)->product_group )
			oItem["potential_value"] := (cAliasQuery)->pot_vl 
			oItem["sales_person_name"] := AllTrim( (cAliasQuery)->pers_name )
			oItem["product_description"] := AllTrim( (cAliasQuery)->product_description )
			oItem["recommendation_type"] := "001"
			oItem["product_type_description"] := AllTrim( (cAliasQuery)->product_type_description )
			oItem["product_group_description"] := AllTrim( (cAliasQuery)->product_group_description )

			Aadd( aSales, oItem )

			(cAliasQuery)->(DbSkip())
		EndDo

		(cAliasQuery)->(DbCloseArea())
	EndIf

	oData["salesMock"] := aSales

	RestArea(aArea)

Return oData:toJson()

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMockSalesQuery
Executa o select de exemplo de pedidos de venda e retorna o alias da área aberta.
A query usa ChangeQuery para ser compatível com SQL Server, Oracle e PostgreSQL.

@return cAlias, Caracter, alias da query aberta
@since 03/06/2026
/*/
//---------------------------------------------------------------------------------------------
Static Function GetMockSalesQuery()

	Local cQuery      as Character
	Local cInner      as Character
	Local oPrepare    as Object
	Local cAliasMock  as Character
	Local nRowIni     as Numeric
	Local nRowFim     as Numeric

	// ------------------------------------------------------------------
	// Parametros de paginacao
	// ------------------------------------------------------------------
	Local nPage    := 1
	Local nPageSize := 30

	nRowIni := ( ( nPage - 1 ) * nPageSize ) + 1   // ex: pagina 1 -> 1
	nRowFim :=     nPage       * nPageSize          // ex: pagina 1 -> 30

	cInner := " SELECT"
	cInner += " ROW_NUMBER() OVER (ORDER BY SC5.R_E_C_N_O_ DESC, SC5.C5_NUM) AS RN"
	cInner += " ,SC5.C5_FILIAL AS BRANCH"
	cInner += " ,LTRIM(RTRIM(SC5.C5_NUM)) AS MOCK_ORDER"
	cInner += " ,LTRIM(RTRIM(SC6.C6_FILIAL)) || '|' || LTRIM(RTRIM(SC6.C6_PRODUTO)) AS PRODUCT_CODE"
	cInner += " ,LTRIM(RTRIM(SC5.C5_FILIAL)) || '|' || LTRIM(RTRIM(SC5.C5_CLIENTE))"
	cInner += " || '|' || LTRIM(RTRIM(SC5.C5_LOJACLI)) AS CUSTOMER"
	cInner += " ,SC6.C6_QTDVEN AS QUANTITY"
	cInner += " ,LTRIM(RTRIM(SA1.A1_CGC))  AS FEDERALID"
	cInner += " ,LTRIM(RTRIM(SB1.B1_TIPO)) AS PRODUCT_TYPE"
	cInner += " ,LTRIM(RTRIM(SA3.A3_FILIAL)) || '|' || LTRIM(RTRIM(SA3.A3_COD)) AS SALES_PERSON"
	cInner += " ,LTRIM(RTRIM(SA1.A1_NOME)) AS CUSTOMER_NAME"
	cInner += " ,COALESCE(LTRIM(RTRIM(SBM.BM_GRUPO)), '') AS PRODUCT_GROUP"
	cInner += " ,COALESCE(LTRIM(RTRIM(SBM.BM_DESC)), '') AS PRODUCT_GROUP_DESCRIPTION"
	cInner += " ,SUM(CASE"
	cInner += " WHEN SB1.B1_PRV1 > 0 THEN SB1.B1_PRV1"
	cInner += " ELSE SC6.C6_PRCVEN"
	cInner += " END) AS POT_VL"
	cInner += " ,COALESCE(LTRIM(RTRIM(SA3.A3_NOME)), '') AS PERS_NAME"
	cInner += " ,SB1.B1_DESC AS PRODUCT_DESCRIPTION"
	cInner += " ,COALESCE(LTRIM(RTRIM(SX5.X5_DESCRI)), '') AS PRODUCT_TYPE_DESCRIPTION"
	cInner += " ,SC5.R_E_C_N_O_ AS ID "
	cInner += " FROM " + RetSqlName("SC5") + " SC5"
	cInner += " INNER JOIN " + RetSqlName("SC6") + " SC6"
	cInner += " ON SC6.C6_FILIAL = SC5.C5_FILIAL"
	cInner += " AND SC6.C6_NUM = SC5.C5_NUM"
	cInner += " AND SC6.C6_SERIE = SC5.C5_SERIE"
	cInner += " AND SC6.D_E_L_E_T_ = ?"                   //  1
	cInner += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cInner += " ON SA1.A1_FILIAL = ?"                   //  2
	cInner += " AND SA1.A1_COD = SC5.C5_CLIENTE"
	cInner += " AND SA1.A1_LOJA = SC5.C5_LOJACLI"
	cInner += " AND  SA1.D_E_L_E_T_ = ?"                  //  3
	cInner += " LEFT JOIN " + RetSqlName("SA3") + " SA3"
	cInner += " ON SA3.A3_FILIAL = ?"                   //  4
	cInner += " AND SA3.A3_COD = SC5.C5_VEND1"
	cInner += " AND  SA3.D_E_L_E_T_ = ? "                  //  5
	cInner += " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cInner += " ON SB1.B1_FILIAL = ?"                  //  6
	cInner += " AND SB1.B1_COD = SC6.C6_PRODUTO"
	cInner += " AND  SB1.D_E_L_E_T_ = ?"                  //  7
	cInner += " LEFT JOIN " + RetSqlName("SX5") + " SX5"
	cInner += " ON SX5.X5_FILIAL = ?"					// 8
	cInner += " AND SX5.X5_TABELA = ?"					// 9
	cInner += " AND SX5.X5_CHAVE = SB1.B1_TIPO"
	cInner += " AND SX5.D_E_L_E_T_ = ?"					// 10
	cInner += " LEFT JOIN " + RetSqlName("SBM") + " SBM"
	cInner += " ON SBM.BM_FILIAL = ?"					// 11
	cInner += " AND SBM.BM_GRUPO = SB1.B1_GRUPO"
	cInner += " AND  SBM.D_E_L_E_T_ = ?"                  //  12
	cInner += " WHERE SC5.C5_FILIAL = ?"                  //  13
	cInner += " AND SC5.D_E_L_E_T_ = ?"                    //  14
	cInner += " GROUP BY"
	cInner += " SC5.R_E_C_N_O_, SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_SERIE"
	cInner += " ,SC5.C5_EMISSAO, SC5.C5_CLIENTE, SC5.C5_LOJACLI"
	cInner += " ,SC6.C6_FILIAL, SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_TPPROD"
	cInner += " ,SC6.C6_ITEM, SC6.C6_VALOR"
	cInner += " ,SA1.A1_FILIAL,SA1.A1_COD, SA1.A1_LOJA, SA1.A1_CGC, SA1.A1_NOME"
	cInner += " ,SA3.A3_FILIAL, SA3.A3_COD, SA3.A3_NOME"
	cInner += " ,SB1.B1_TIPO, SB1.B1_DESC"
	cInner += " ,SBM.BM_GRUPO, SBM.BM_DESC, SX5.X5_DESCRI"

	// ------------------------------------------------------------------
	// Query externa: aplica o filtro de pagina sobre RN
	// BETWEEN e identico nos tres bancos sem nenhum condicional.
	// ------------------------------------------------------------------
	cQuery := "SELECT * FROM (" + cInner + ") PAGED"
	cQuery += " WHERE RN BETWEEN ? AND ? "		// 15 e 16

	cQuery := ChangeQuery( cQuery )

	oPrepare := FwExecStatement():New( cQuery )

	oPrepare:setString( 1, ' ' )             // SC6.D_E_L_E_T_
	oPrepare:setString( 2, FWxFilial("SA1")) // SA1.A1_FILIAL
	oPrepare:setString( 3, ' ' )             // SA1.D_E_L_E_T_
	oPrepare:setString( 4, FWxFilial("SA3")) // SA3.A3_FILIAL
	oPrepare:setString( 5, ' ' )             // SA3.D_E_L_E_T_
	oPrepare:setString( 6, FWxFilial('SB1')) // SB1.B1_FILIAL
	oPrepare:setString( 7, ' ' )             // SB1.D_E_L_E_T_
	oPrepare:setString( 8, FWxFilial("SX5")) // SX5.X5_FILIAL
	oPrepare:setString( 9, '02')			 // SX5.X5_TABELA
	oPrepare:setString( 10, ' ' )             // SX5.D_E_L_E_T_
	oPrepare:setString( 11, FWxFilial("SBM")) // SBM.BM_FILIAL
	oPrepare:setString( 12, ' ' )             // SBM.D_E_L_E_T_
	oPrepare:setString( 13, FWxFilial("SC5")) // SC5.C5_FILIAL
	oPrepare:setString( 14, ' ' )             // SC5.D_E_L_E_T_
	oPrepare:SetNumeric( 15, nRowIni) 
	oPrepare:SetNumeric( 16, nRowFim) 

	cAliasMock := oPrepare:OpenAlias()

    If oPrepare <> NIL
        oPrepare:Destroy()
        oPrepare := NIL
    EndIf

Return cAliasMock
