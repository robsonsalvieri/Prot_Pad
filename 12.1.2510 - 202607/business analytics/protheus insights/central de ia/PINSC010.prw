#INCLUDE 'PROTHEUS.CH'
#INCLUDE "PINSC010.CH"
#INCLUDE 'InsightDefs.ch'

#DEFINE LEVEL1 "L1"
#DEFINE LEVEL2 "L2"
#DEFINE ALL_LEVEL "L1|L2"


/*/{Protheus.doc} PINSC010
Função inicial do Insight Sales Recommendation
Gera a tabela temporária contendo as linhas do Json de alerts e faz a chamada do APP POUI

@return oTmpTab, object, retona o objeto totvs.framework.database.temporary.SharedTable 

@author Raphael Santana Ferreira
@since 05/09/2024
/*/
Function PINSC010()

	Local cInsTyp    as Character
	Local cModulo    as Character
	Local cInsAlias  as Character
	Local aFieldsTab as Array
	Local oTmpTab    as Object

	//Instancia o objeto da tabela temporária
	cInsAlias	:= GetNextAlias()
	oTmpTab     := Nil
	cInsTyp		:= "sales_recommendation"
	cModulo		:= "FAT"
	aFieldsTab	:= PINC010Fld()

	//Cria tabela temporária
	If AliasInDic("I21")
		oTmpTab := PINSMakeTemp(cInsAlias, cInsTyp, cModulo, aFieldsTab)
	EndIf

Return oTmpTab

/*/{Protheus.doc} PINC010Fld
Função responsavel por montar um array com os campos da tabela temporária do Sales Recommendation.
	[1] - nome da propriedade na mensagem ( campo memo da tabela I21 )
	[2] - estrutura de campo da tabela temporária
		[1] - nome da propriedade na mensagem
		[2] - tipo
		[3] - tamanho
		[4] - decimal
	[3] - Indica se a coluna pode ser usada no filtro de pesquisa
	[4] - Texto apresentado no header
	[5] - Indica a ordem apresentada no browse
	[6] - Indica que a propriedade da mensagem contém uma chave composta
	[7] - Nível do campo no drilldown (LEVEL1, LEVEL2)

@return array contendo a estrutura de campos para gerar a tabela temporária

@author Raphael Santana Ferreira
@since 04/09/2024
/*/
Function PINC010Fld()	

	Local aStruCPO := {} as Array

	//Campos Contrato
	aadd(aStruCPO, {"customer"                 , {"customer"  , "C",  50, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"customer_name"            , {"cust_nam"  , "C", 254, 0}, .F., STR0004, , , ALL_LEVEL })				// "Cliente"
	aadd(aStruCPO, {"federal_id"               , {"federal_id", "C",  20, 0}, .F., STR0005, , , LEVEL1 })					// "CNPJ"
	aadd(aStruCPO, {"sales_person"             , {"sales_per" , "C",  50, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"sales_person_name"        , {"pers_name" , "C", 254, 0}, .F., STR0011, , , LEVEL2 })					// "Vendedor"
	aadd(aStruCPO, {"product"                  , {"product"	  , "C",  50, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"product_description"      , {"descrip"	  , "C", 254, 0}, .F., STR0007, , , LEVEL2 })					// "Produto"
	aadd(aStruCPO, {"product_group"            , {"prod_grp"  , "C",  50, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"product_group_description", {"grp_desc"  , "C", 254, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"product_type"             , {"tpe"		  , "C",  50, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"product_type_description" , {"tp_desc"	  , "C", 254, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"quantity"                 , {"quantity"  , "N",  17, 2}, .F., STR0009, , , LEVEL2 })					// "Qtd. Sugerida"
	aadd(aStruCPO, {"potential_value"          , {"pot_vl" 	  , "N",  17, 2}, .F., STR0008, , , LEVEL2 })					// "Valor"
	aadd(aStruCPO, {"rating"                   , {"rating"    , "N",   8, 4}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"recommendation_type"      , {"type_rec"  , "C",   3, 0}, .F., STR0019, , , LEVEL2 })					// "Tipo de Recomendação"
	//Campos Específicos FATURAMENTO
	aadd(aStruCPO, {"branch"                   , {"branch"	  , "C",  20, 0}, .F., STR0001, , , ALL_LEVEL })				// "Filial"
	aadd(aStruCPO, {"control_number"           , {"ctrl_numb" , "C",  36, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"recnoI21"                 , {"recnoI21"  , "N",   9, 0}, .F., 		  , , , LEVEL2 })
	aadd(aStruCPO, {"stock_quantity"           , {"stck_qtt"  , "N",  17, 2}, .F., STR0010, , , LEVEL2 })					// "Qtd. em Estoque"
	aadd(aStruCPO, {"msg_status"               , {"msg_status", "C",   3, 0}, .F., 		  , , , ALL_LEVEL })
	aadd(aStruCPO, {"msg_result"               , {"msg_result", "M",  10, 0}, .F., 		  , , , LEVEL2 })	
	// //Campos específicos da tabela temporária
	// aba DISPONIVEIS
	aadd(aStruCPO, { ""						   , {"cust_code" , "C",  50, 0}, .F., STR0002, , , ALL_LEVEL })				// "Código do Cliente"
	aadd(aStruCPO, { ""						   , {"cust_store", "C",  50, 0}, .F., STR0003, , , ALL_LEVEL })				// "Loja do Cliente"
	aadd(aStruCPO, { ""						   , {"key_cust"  , "C", 254, 0}, .F., STR0020, STRUCT_INVISIBLE, , LEVEL1 })	// "Chave"
	aadd(aStruCPO, { ""						   , {"prod_code" , "C",  50, 0}, .F., STR0006, , , LEVEL2 })					// "Código do Produto"
	aadd(aStruCPO, { ""						   , {"sales_code", "C",  50, 0}, .F., STR0006, , , LEVEL2 })
	// aba GERADAS
	aadd(aStruCPO, { ""						   , {"order_numb", "C",  50, 0}, .F., STR0013 }) 			// "Nº. do Pedido"
	aadd(aStruCPO, { ""						   , {"dt_create" , "C",  50, 0}, .F., STR0014 }) 			// "Data da Geração"
	aadd(aStruCPO, { ""						   , {"user_gen"  , "C",  50, 0}, .F., STR0015 }) 			// "Gerado por"
	// aba DESCARTADAS		
	aadd(aStruCPO, { ""						   , {"dt_discard", "C",  50, 0}, .F., STR0016 }) 			// "Data do Descarte"
	aadd(aStruCPO, { ""						   , {"user_dsc"  , "C",  50, 0}, .F., STR0017 }) 			// "Descartado por"
	aadd(aStruCPO, { ""						   , {"reason"    , "C", 254, 0}, .F., STR0018 })			// "Motivo"

	// Campo utilizado para mockar o número do pedido no JSON de resultado
	aadd(aStruCPO, { ""                        , {"mock_order", "C",  50, 0}, .F.,  	   }) 			// "Mock Order"

Return aStruCPO

/*/{Protheus.doc} PINSMakeTemp
Função responsavel por criar uma tabela temporária para guardar os alerts separados fora do JSON

@param cAliasTabTmp, Caracter, Nome da tabela temporaria
@param cInsTyp, Caracter, Tipo de insight
@param cModulo, Caracter, Módulo do insight
@param aCampos, array, array com strutura de campos da tabela temporária

@return Object, retona o objeto totvs.framework.database.temporary.SharedTable

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
Static Function PINSMakeTemp(cAliasTabTmp, cInsTyp, cModulo, aCampos)

	Local aStruBulk    as Array
	Local aLinTab      as Array
	Local aCpoTab      as Array
	Local aStruCPO     as Array
	Local aAux         as Array
	Local aArea 	   as Array
	Local cQryBranch   as Character
	Local cBranchProd  as Character
	Local cProduct     as Character
	Local cNextAlias   as Character
	Local cJsonIns     as Character
	Local cJsonInsAcc  as Character
	Local cMessID      as Character
	Local cGraphPoints as Character
	Local cResult	   as Character
	Local oTempTable   as Object
	Local oJson        as Object
	Local oBulk        as Object
	Local oAux		   as Object
	Local nX           as Numeric
	Local nSaldo       as Numeric

	cNextAlias    := ""
	nX            := 0
	nSaldo        := 0
	aStruBulk	  := {}
	aLinTab		  := {}
	aStruCPO      := {}
	aAux          := {}
	aArea    	  := GetArea()
	cQryBranch 	  := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SA1', 'SB1' } )					
	cBranchProd   := ""
	cProduct      := ""
	cMessID       := ""
	cJsonInsAcc   := ""
	cGraphPoints  := ""
	cResult  	  := ""
	aCpoTab		  := aCampos
	oTempTable    := totvs.framework.database.temporary.SharedTable():New(cAliasTabTmp)

	//Alimenta o array da estrutura da tabela temporária
	For nX:=1 To Len(aCpoTab)
		Aadd(aStruCPO, {aCpoTab[nX][2][1], aCpoTab[nX][2][2], aCpoTab[nX][2][3], aCpoTab[nX][2][4]})
	Next nX

	//Configuração da tabela temporária
	oTempTable:SetFields(aStruCPO)

	//Efetiva a criação da tabela temporária
	oTempTable:Create()

	//Recupera o nome da tabela temporária para ser usada no Bulk
	cTableName := oTempTable:GetTableNameForTCFunctions()

	//Copia a estrutura de campos da tabela temporária
	aStruBulk := (cAliasTabTmp)->( DBStruct() )

	//Instancia o objeto FwBulk e seta as propriedades do objeto
	oBulk := FwBulk():New(cTableName)
	oBulk:SetFields(aStruBulk)

	//Função que faz a query de busca de registros na tabela I21
	//gera os dados no alias passado por parâmetro
	cNextAlias := PINSGetAlerts(cInsTyp, cModulo, cQryBranch)

	//Abre tabelas SB1 e SB2 para verificar o saldo atual
	DbSelectArea("SB1")
	DbSelectArea("SB2")

	// Itera sobre todos os registros com o mesmo I21_UIDMSG
	While (cNextAlias)->(!Eof())

		oJson  := JsonObject():New()
		oAux  := JsonObject():New()
		nSaldo := 0

		DbSelectArea("I21")
		DbGoTo((cNextAlias)->RECI21)

		cJsonIns := Trim( I21->I21_PAYLOD )
		cResult := Trim( I21->I21_RESULT )

		oJson:FromJson( cJsonIns )
		oAux:FromJson( cResult )

		aLinTab := {}
		aLinTab := PINSAlertLine( oJson, aCpoTab )

		//Alimentando campos específicos FATURAMENTO
		Aadd(aLinTab, I21->I21_BRANCH )
		Aadd(aLinTab, I21->I21_UIDINS )
		Aadd(aLinTab, I21->( Recno() ) )

		aAux        := StrTokArr2( oJson[ 'product' ], '|', .T. )
		cBranchProd := PadR( aAux[ 1 ], TamSX3( "B1_FILIAL" )[1] )
		cProduct    := aAux[ 2 ]

		If SB1->(DbSeek(cBranchProd + cProduct))
			If SB2->(DbSeek(FWxFilial('SB2') + SB1->B1_COD + SB1->B1_LOCPAD ))
				nSaldo := SaldoSB2(,.F.)
			EndIf
		EndIf

		Aadd(aLinTab, nSaldo )
		Aadd(aLinTab, I21->I21_STATUS )
		Aadd(aLinTab, I21->I21_RESULT )

		//Trata dados do cliente
		aAux := StrTokArr2( oJson[ 'customer' ], '|', .T. )
		Aadd(aLinTab, aAux[ 2 ])	// código do cliente
		Aadd(aLinTab, aAux[ 3 ])	// loja do cliente
		// chave breadcrumb
		Aadd(aLinTab, aAux[ 1 ] + " | " + aAux[ 2 ] + " | " + aAux[ 3 ] + " - " + AllTrim( oJson[ 'customer_name' ] ) )

		//Trata dados do produto
		Aadd(aLinTab, cProduct )

		//Trata dados do vendedor
		If !Empty( oJson[ 'sales_person' ] )
			aAux := StrTokArr2( oJson[ 'sales_person' ], '|', .T. )
			Aadd(aLinTab, aAux[ 2 ] )
		Else
			Aadd(aLinTab, "" )
		EndIf

		//Alimenta número do pedido de venda
		SetResultInfo( @aLinTab, "orderNumber", oAux )

		//Alimenta data de geração do pedido
		SetResultInfo( @aLinTab, "createdDate", oAux )

		//Alimenta usuário de geração do pedido de venda
		SetResultInfo( @aLinTab, "userName", oAux )

		//Alimenta data do descarte
		SetResultInfo( @aLinTab, "discardDate", oAux )

		//Alimenta usuário de geração do pedido de venda
		SetResultInfo( @aLinTab, "userName", oAux )

		//Alimenta motivo
		SetResultInfo( @aLinTab, "message", oAux )

		//compatibiliza a estrutura com modo mock para evitar erros de estrura
		Aadd(aLinTab, "" )
		
		oBulk:AddData( aLinTab )

		FreeObj( oJson )
		FreeObj( oAux )

		( cNextAlias )->( DbSkip() )
	EndDo

	oBulk:Close()
	oBulk:Destroy()

	FreeObj(oBulk)

	RestArea(aArea)
	FWFreeArray(aLinTab)
	FWFreeArray(aArea)
	FWFreeArray(aAux)
	FWFreeArray(aStruBulk)
	FWFreeArray(aStruCPO)

Return oTempTable

/*/{Protheus.doc} PINSGetAlerts
Função que faz o select na tabela I21 retornando todos registros referente ao último
alert enviado pelo smartlink
    
@param cInsTyp, Caractere, contém a string referente ao tipo de insight será filtrado na query
@param cModulo, Caractere, contém a string referente ao módulo que será filtrado na query
@param cQryBranch, Caracter, String com as filiais onde o usuário tem acesso.

@return cNextAlias, String contendo a área aberta na execução da query

@author Raphael Santana Ferreira    
@since 25/07/2024
/*/
Static Function PINSGetAlerts(cInsTyp, cModulo, cQryBranch)

	Local cQuery     as Character
	Local cNextAlias as Character
	Local oPrepare   as Object
	Local aAux 		 as Array
	Local lUseBranch as Logical

	cNextAlias := ""

	lUseBranch := !Empty( cQryBranch )

	If lUseBranch
		// Trata as branchs para passar o conteúdo correto no método SetIn da FWExecStatement
		cQryBranch := StrTran( cQryBranch, ", ", "," )
		cQryBranch := StrTran( cQryBranch, "'", "" )
		aAux := StrTokArr( cQryBranch, ',' )
	EndIf

	cQuery := " SELECT I21.R_E_C_N_O_ RECI21 "
	cQuery += " FROM " + RetSqlName("I21") + " I21 "
	cQuery += " WHERE I21_UIDMSG IN ( "
	cQuery += " SELECT I19_UIDMSG "
	cQuery += " FROM " + RetSqlName("I19") + " I19 "
	cQuery += " WHERE I19.I19_MESSID = ( "
	cQuery += " SELECT I19_MESSID "
	cQuery += " FROM ( "
	cQuery += " SELECT ROW_NUMBER() OVER( "
	cQuery += " ORDER BY I191.R_E_C_N_O_ DESC "
	cQuery += " ) LINHA, I19_MESSID, R_E_C_N_O_ "
	cQuery += " FROM " + RetSqlName("I19") + " I191 "
	cQuery += " WHERE I191.D_E_L_E_T_ = ? "
	cQuery += " AND I191.I19_INSIGT = ? "
	cQuery += " AND I191.I19_MESSID <> ? "
	cQuery += " ) AUX "
	cQuery += " WHERE LINHA = 1 "
	cQuery += " AND I19.D_E_L_E_T_ = '' ) "
	cQuery += " ) "
	cQuery += " AND I21.I21_MODULO = ? "
	cQuery += " AND I21.I21_INSIGT = ? "
	cQuery += " AND I21.I21_DTATE >= ? "

	If lUseBranch
		cQuery += " AND I21.I21_BRANCH IN ( ? ) "
	EndIf

	cQuery += " AND I21.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)

	oPrepare := FWPreparedStatement():New(cQuery)

	oPrepare:setString( 1, ' ' )
	oPrepare:setString( 2, cInsTyp )
	oPrepare:setString( 3, ' ' )
	oPrepare:setString( 4, cModulo )
	oPrepare:setString( 5, cInsTyp )
	oPrepare:setString( 6, DToS(Date()) )
	If lUseBranch
		oPrepare:setIn( 7, aAux )
		oPrepare:setString( 8, ' ' )
	Else
		oPrepare:setString( 7, ' ' )
	EndIf

	cNextAlias := MPSysOpenQuery( oPrepare:GetFixQuery() )

	FreeObj(oPrepare)

Return cNextAlias

/*/{Protheus.doc} PINSAlertLine
Retorna um array com os dados da linha do Json de alert enviada por parâmetro
alert enviado pelo smartlink

@param oJson, objeto, contém a linha posicionada no array de Json de alerts
@param aCpoTab, array, contém um array com os dados de campos referente a tabela temporária e propriedades do json de alert

@return array, array contendo os dados que serão inseridos na tabela temporária ordenado por coluna

@author Raphael Santana Ferreira
@since 25/07/2024
/*/
Static Function PINSAlertLine(oJson, aCpoTab)

	Local nI           as Numeric
	Local aRet         as Array
	Local cGraphPoints as Character
	Local cPropertie    as Character
	Local cValType 		as Character
	Local cFieldName	as Character
	Local cFieldType	as Character
	Local xAuxValue		as Any

	nI           := 0
	aRet         := {}
	cGraphPoints := ""

	For nI:=1 To Len(aCpoTab)
		cPropertie := aCpoTab[nI][1]
		cValType := ValType( oJson[ cPropertie ] )
		cFieldName := aCpoTab[ nI ][ 2 ][ 1 ]
		cFieldType := aCpoTab[ nI ][ 2 ][ 2 ]
		xAuxValue := NIL	

		If !( cFieldName $ 'branch/ctrl_numb/recnoI21/stck_qtt/msg_status/msg_result') .and. !Empty( cPropertie )

			If cValType == "C"
				xAuxValue := DecodeUTF8( Upper( AllTrim( oJson[ cPropertie ] ) ) )
			ElseIF cValType == "N"
				xAuxValue := oJson[ cPropertie ]
			Else
				If cFieldType == "C"
					xAuxValue := ""
				ElseIf cFieldType == "N"
					xAuxValue := 0
				EndIF
			EndIf
			Aadd( aRet, xAuxValue )
		EndIf

	Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetResultInfo
Função que alimenta as posições da tabela temporária de acordo a 
propriedade passada.

@param @aLinTab, array, vetor com as informações que serão gravadas 
	na tabela temporária, onde cada posição representa uma coluna.
@param cPropertie, character, nome da propriedade do objeto JSON 
	a ser pesquisado.
@param oJsonResult, json, objeto com o conteúdo do campo I21_RESULT.

@author  Marcia Junko
@since   02/06/2025
/*/
//-------------------------------------------------------------------
Static Function SetResultInfo( aLinTab, cPropertie, oJsonResult )
	Local cDate
	Local cAux
	
	If oJsonResult:HasProperty( cPropertie ) .And. !Empty( oJsonResult[ cPropertie ] )
		If cPropertie $ "createdDate|discardDate"
			cAux := oJsonResult[ cPropertie ]
			cAux := StrTran( cAux, "/", "")
			cDate := Dtoc( STod( cAux) )
			Aadd( aLinTab, cDate )
		Else
			Aadd( aLinTab, oJsonResult[ cPropertie ] )
		EndIf
	Else
		Aadd( aLinTab, "" )
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PinsMockSales
	Função que gera os dados de mock para Sales, 
	e popula a tabela temporária com dados de mock baseados na SC6 do ambiente em execução.

	@param oJson, objeto JSON com os dados da linha
	@param aCpoTab, array, estrutura de campos
	
	@return array

	@author Victor Vieira 
	@since 03/06/2024
/*/
Function PinsMockSales( oJson, aCpoTab )

	Local aLinSales 	as Array
	Local aAux      	as Array
	Local aArea 		as Array
	Local oAux	    	as Object
	Local cBranchProd  	as Character
	Local cProduct     	as Character
	Local nSaldo       	as Numeric


	aArea    	  := GetArea()
	cBranchProd   := ""
	cProduct      := ""
	nSaldo        := 0

	SB1->(DbSetOrder(1)) // B1_FILIAL+B1_COD
	SB2->(DbSetOrder(1)) // B2_FILIAL+B2_LOCAL+B2_COD
	
	oAux := JsonObject():New()

	aLinSales := PINSAlertLine( oJson, aCpoTab)


	oAux:FromJson( '{}' )

		//Alimentando campos específicos FATURAMENTO
		Aadd(aLinSales, oJson[ 'branch' ] )//I21->I21_BRANCH
		Aadd(aLinSales, FWUUIDV1( .T. ) )	//I21->I21_UIDMSG
		Aadd(aLinSales, 1 ) //I21->I21_INSIGT

		aAux        := StrTokArr2( oJson[ 'product' ], '|', .T. )
		cBranchProd := PadR( aAux[ 1 ], TamSX3( "B1_FILIAL" )[1] )
		cProduct    := aAux[ 2 ]

		If SB1->(DbSeek(cBranchProd + cProduct))
			If SB2->(DbSeek(FWxFilial('SB2') + SB1->B1_COD + SB1->B1_LOCPAD ))
				nSaldo := SaldoSB2(,.F.)
			EndIf
		EndIf

		Aadd(aLinSales, nSaldo )
		Aadd(aLinSales, '' ) //I21->I21_STATUS
		Aadd(aLinSales, '' ) //I21->I21_RESULT

		//Trata dados do cliente
		aAux := StrTokArr2( oJson[ 'customer' ], '|', .T. )
		Aadd(aLinSales, aAux[ 2 ])	// código do cliente
		Aadd(aLinSales, aAux[ 3 ])	// loja do cliente
		// chave breadcrumb
		Aadd(aLinSales, aAux[ 1 ] + " | " + aAux[ 2 ] + " | " + aAux[ 3 ] + " - " + AllTrim( oJson[ 'customer_name' ] ) )

		//Trata dados do produto
		Aadd(aLinSales, cProduct )

		//Trata dados do vendedor
		If !Empty( oJson[ 'sales_person' ] )
			aAux := StrTokArr2( oJson[ 'sales_person' ], '|', .T. )
			Aadd(aLinSales, aAux[ 2 ] )
		Else
			Aadd(aLinSales, "" )
		EndIf

		//Alimenta número do pedido de venda
		SetResultInfo( @aLinSales, "orderNumber", oAux )

		//Alimenta data de geração do pedido
		SetResultInfo( @aLinSales, "createdDate", oAux )

		//Alimenta usuário de geração do pedido de venda
		SetResultInfo( @aLinSales, "userName", oAux )

		//Alimenta data do descarte
		SetResultInfo( @aLinSales, "discardDate", oAux )

		//Alimenta usuário de geração do pedido de venda
		SetResultInfo( @aLinSales, "userName", oAux )

		//Alimenta motivo
		SetResultInfo( @aLinSales, "message", oAux )

		//Alimenta campo mock_order (apenas a propriedade mock_order)
		If oJson:HasProperty("mock_order") .And. !Empty( oJson[ "mock_order" ] )
			Aadd( aLinSales, AllTrim( oJson[ "mock_order" ] ) )
		Else
			Aadd( aLinSales, "" )
		EndIf

	FWFreeArray(aArea)
	FWFreeArray(aAux)
	FreeObj(oAux)

Return aLinSales

/*/{Protheus.doc} ResultMockSales
	Retorna um JsonObject contendo o mock de resposta de sales recommendation.

	@return JsonObject

	@author Victor Vieira
	@since 03/06/2026
/*/
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

			Aadd( aSales, oItem )

			(cAliasQuery)->(DbSkip())
		EndDo

		(cAliasQuery)->(DbCloseArea())
	EndIf

	oData["salesMock"] := aSales

	RestArea(aArea)

Return oData:toJson()

/*/{Protheus.doc} GetMockSalesQuery
Executa o select de exemplo de pedidos de venda e retorna o alias da área aberta.
A query usa ChangeQuery para ser compatível com SQL Server, Oracle e PostgreSQL.

@return cAlias, Caracter, alias da query aberta
@since 03/06/2026
*/
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
	cInner += "  ROW_NUMBER() OVER (ORDER BY SC5.R_E_C_N_O_ DESC, SC5.C5_NUM) AS RN"
	cInner += " ,SC5.C5_FILIAL                                                 AS BRANCH"
	cInner += " ,LTRIM(RTRIM(SC5.C5_NUM))                                   AS MOCK_ORDER"
	cInner += " ,LTRIM(RTRIM(SC6.C6_FILIAL)) || '|' || LTRIM(RTRIM(SC6.C6_PRODUTO))           AS PRODUCT_CODE"
	cInner += " ,LTRIM(RTRIM(SC5.C5_FILIAL)) || '|' || LTRIM(RTRIM(SC5.C5_CLIENTE))"
	cInner += "       || '|' || LTRIM(RTRIM(SC5.C5_LOJACLI))                          AS CUSTOMER"
	cInner += " ,SC6.C6_QTDVEN                                                 AS QUANTITY"
	cInner += " ,LTRIM(RTRIM(SA1.A1_CGC))                                              AS FEDERALID"
	cInner += " ,LTRIM(RTRIM(SB1.B1_TIPO))                                             AS PRODUCT_TYPE"
	cInner += " ,LTRIM(RTRIM(SA3.A3_FILIAL)) || '|' || LTRIM(RTRIM(SA3.A3_COD))              AS SALES_PERSON"
	cInner += " ,LTRIM(RTRIM(SA1.A1_NOME))                                             AS CUSTOMER_NAME"
	cInner += " ,COALESCE(LTRIM(RTRIM(SBM.BM_GRUPO)), '')                             AS PRODUCT_GROUP"
	cInner += " ,SUM(CASE"
	cInner += "       WHEN SB1.B1_PRV1 > 0 THEN SB1.B1_PRV1"
	cInner += "       ELSE SC6.C6_PRCVEN"
	cInner += "    END)                                                         AS POT_VL"
	cInner += " ,COALESCE(LTRIM(RTRIM(SA3.A3_NOME)), '')                              AS PERS_NAME"
	cInner += " ,SB1.B1_DESC                                                   AS PRODUCT_DESCRIPTION"
	// Subquery correlacionada para descricao do tipo de produto
	cInner += " ,(SELECT SX5.X5_DESCRI"
	cInner += "    FROM " + RetSqlName("SX5") + " SX5"
	cInner += "    WHERE SX5.D_E_L_E_T_ = ' '"
	cInner += "      AND SX5.X5_TABELA  = '02'"
	cInner += "      AND SX5.X5_CHAVE   = SB1.B1_TIPO)                        AS PRODUCT_TYPE_DESCRIPTION"
	cInner += " ,SC5.R_E_C_N_O_                                                AS ID"
	cInner += " FROM " + RetSqlName("SC5") + " SC5"
	cInner += " INNER JOIN " + RetSqlName("SC6") + " SC6"
	cInner += "     ON SC6.C6_FILIAL   = SC5.C5_FILIAL"
	cInner += "     AND SC6.C6_NUM      = SC5.C5_NUM"
	cInner += "     AND SC6.C6_SERIE    = SC5.C5_SERIE"
	cInner += "     AND SC6.D_E_L_E_T_ = ?"                   //  1
	cInner += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cInner += "     ON SA1.A1_FILIAL   = ?"                   //  2
	cInner += "     AND SA1.A1_COD      = SC5.C5_CLIENTE"
	cInner += "     AND SA1.A1_LOJA     = SC5.C5_LOJACLI"
	cInner += "     AND  SA1.D_E_L_E_T_ = ?"                  //  3
	cInner += " LEFT JOIN " + RetSqlName("SA3") + " SA3"
	cInner += "     ON SA3.A3_FILIAL   = ?"                   //  4
	cInner += "     AND SA3.A3_COD      = SC5.C5_VEND1"
	cInner += "     AND  SA3.D_E_L_E_T_ = ?"                  //  5
	cInner += " INNER JOIN " + RetSqlName("SB1") + " SB1"
	cInner += "     ON SB1.B1_FILIAL   = ? "                  //  6
	cInner += "     AND SB1.B1_COD      = SC6.C6_PRODUTO"
	cInner += "     AND  SB1.D_E_L_E_T_ = ?"                  //  7
	cInner += " LEFT JOIN " + RetSqlName("SBM") + " SBM"
	cInner += "     ON SBM.BM_FILIAL   = SB1.B1_FILIAL"
	cInner += "     AND SBM.BM_GRUPO    = SB1.B1_GRUPO"
	cInner += "     AND  SBM.D_E_L_E_T_ = ?"                  //  8
	cInner += " WHERE SC5.C5_FILIAL     = ?"                  //  9
	cInner += " AND SC5.D_E_L_E_T_    = ?"                    //  10
	cInner += " GROUP BY"
	cInner += "  SC5.R_E_C_N_O_,  SC5.C5_FILIAL,  SC5.C5_NUM,   SC5.C5_SERIE"
	cInner += " ,SC5.C5_EMISSAO,  SC5.C5_CLIENTE, SC5.C5_LOJACLI"
	cInner += " ,SC6.C6_FILIAL,   SC6.C6_PRODUTO, SC6.C6_QTDVEN, SC6.C6_TPPROD"
	cInner += " ,SC6.C6_ITEM,     SC6.C6_VALOR"
	cInner += " ,SA1.A1_FILIAL,   SA1.A1_COD,     SA1.A1_LOJA,   SA1.A1_CGC,  SA1.A1_NOME"
	cInner += " ,SA3.A3_FILIAL,   SA3.A3_COD,     SA3.A3_NOME"
	cInner += " ,SB1.B1_TIPO,     SB1.B1_DESC"
	cInner += " ,SBM.BM_GRUPO"

	// ------------------------------------------------------------------
	// Query externa: aplica o filtro de pagina sobre RN
	// BETWEEN e identico nos tres bancos sem nenhum condicional.
	// ------------------------------------------------------------------
	cQuery := "SELECT * FROM (" + cInner + ") PAGED"
	// cQuery += " WHERE RN BETWEEN " + cValToChar(nRowIni) + " AND " + cValToChar(nRowFim)
	cQuery += " WHERE RN BETWEEN ? AND ? "

	cQuery := ChangeQuery( cQuery )

	oPrepare := FwExecStatement():New( cQuery )

	oPrepare:setString( 1, ' ' )             // SC6.D_E_L_E_T_
	oPrepare:setString( 2, FWxFilial("SA1")) // SA1.A1_FILIAL
	oPrepare:setString( 3, ' ' )             // SA1.D_E_L_E_T_
	oPrepare:setString( 4, FWxFilial("SA3")) // SA3.A3_FILIAL
	oPrepare:setString( 5, ' ' )             // SA3.D_E_L_E_T_
	oPrepare:setString( 6, FWxFilial('SB1')) // SB1.B1_FILIAL
	oPrepare:setString( 7, ' ' )             // SB1.D_E_L_E_T_
	oPrepare:setString( 8, ' ' )             // SBM.D_E_L_E_T_
	oPrepare:setString( 9, FWxFilial("SC5")) // SC5.C5_FILIAL
	oPrepare:setString( 10, ' ' )             // SC5.D_E_L_E_T_
	oPrepare:setString( 11, cValToChar(nRowIni)) 
	oPrepare:setString( 12, cValToChar(nRowFim)) 

	cAliasMock := oPrepare:OpenAlias()

	FreeObj( oPrepare )

Return cAliasMock
