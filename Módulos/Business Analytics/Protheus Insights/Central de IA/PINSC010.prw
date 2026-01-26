#INCLUDE 'PROTHEUS.CH'
#INCLUDE "PINSC010.CH"

/*/{Protheus.doc} PINSC010
    @type  Function 
    Função inicial do Insight Sales Recommendation
	Gera a tabela temporária contendo as linhas do Json de alerts e faz a chamada do APP POUI
    @author Raphael Santana Ferreira
    @since 05/09/2024
    @return oTmpTab, object, retona o objeto totvs.framework.database.temporary.SharedTable 
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
    @type  Function 
    Função responsavel por montar um array com os campos da tabela temporária
    @author Raphael Santana Ferreira
    @since 04/09/2024
    @version version
    @param 
    @return array contendo a estrutura de campos para gerar a tabela temporária
/*/
Function PINC010Fld()

	Local aStruCPO  as Array

	aStruCPO := {}

	//Campos Contrato
	aadd(aStruCPO, {"customer"                 , {"customer", "C", 50, 0}   , .F.})
	aadd(aStruCPO, {"customer_name"            , {"cust_nam", "C", 254, 0}  , .F., STR0004 })	// "Cliente"
	aadd(aStruCPO, {"federal_id"               , {"federal_id", "C", 20, 0} , .F., STR0005 })	// "CNPJ"
	aadd(aStruCPO, {"sales_person"             , {"sales_per", "C", 50, 0}  , .F.})
	aadd(aStruCPO, {"sales_person_name"        , {"pers_name", "C", 254, 0} , .F., STR0011 }) // "Vendedor"
	aadd(aStruCPO, {"product"                  , {"product" , "C", 50, 0}   , .F.}) // "Produto"
	aadd(aStruCPO, {"product_description"      , {"descrip" , "C", 254, 0}  , .F., STR0007 }) // "Produto"
	aadd(aStruCPO, {"product_group"            , {"prod_grp" , "C", 50, 0}  , .F.})
	aadd(aStruCPO, {"product_group_description", {"grp_desc" , "C", 254, 0} , .F.})
	aadd(aStruCPO, {"product_type"             , {"tpe", "C", 50, 0}        , .F.})
	aadd(aStruCPO, {"product_type_description" , {"tp_desc", "C", 254, 0}   , .F.})
	aadd(aStruCPO, {"quantity"                 , {"quantity" , "N", 17, 2}  , .F., STR0009 })	// "Qtd. Sugerida"
	aadd(aStruCPO, {"potential_value"          , {"pot_vl" , "N", 17, 2}    , .F., STR0008 })	// "Valor"
	aadd(aStruCPO, {"rating"                   , {"rating" , "N", 8, 4}     , .F.})
	aadd(aStruCPO, {"recommendation_type"      , {"type_rec" , "C", 3, 0}   , .F., STR0019 })	//"Tipo de Recomendação"

	//Campos Específicos FATURAMENTO
	aadd(aStruCPO, {"branch"                   , {"branch", "C", 20 , 0 }   , .F., STR0001 })		//  "Filial"
	aadd(aStruCPO, {"control_number"           , {"ctrl_numb" , "C", 36, 0} , .F.})
	aadd(aStruCPO, {"recnoI21"                 , {"recnoI21" , "N", 9, 0}   , .F.})
	aadd(aStruCPO, {"stock_quantity"           , {"stck_qtt" , "N", 17,2}   , .F., STR0010 })	// "Qtd. em Estoque"
	aadd(aStruCPO, {"msg_status"               , {"msg_status" , "C", 3, 0} , .F.})
	aadd(aStruCPO, {"msg_result"               , {"msg_result" , "M", 10, 0}, .F. })	


	// //Campos específicos da tabela temporária
	aadd(aStruCPO, {""                 , {"cust_code", "C", 50, 0}   , .F., STR0002 })	// "Código do Cliente"
	aadd(aStruCPO, {""                 , {"cust_store", "C", 50, 0}   , .F., STR0003 })	// "Loja do Cliente"
	aadd(aStruCPO, {""                 , {"prod_code", "C", 50, 0}   , .F., STR0006 }) // "Código do Produto"
	aadd(aStruCPO, {""                 , {"sales_code", "C", 50, 0}   , .F. }) 
	aadd(aStruCPO, {""                 , {"order_numb", "C", 50, 0}   , .F., STR0013 }) // "Nº. do Pedido"
	aadd(aStruCPO, {""                 , {"dt_create", "C", 50, 0}   , .F., STR0014 }) //  "Data da Geração"
	aadd(aStruCPO, {""                 , {"user_gen", "C", 50, 0}   , .F., STR0015 }) //  "Gerado por"
	aadd(aStruCPO, {""                 , {"dt_discard", "C", 50, 0}   , .F., STR0016 }) //   "Data do Descarte"
	aadd(aStruCPO, {""                 , {"user_dsc", "C", 50, 0}   , .F., STR0017 }) //   "Descartado por"
	aadd(aStruCPO, {""                 , {"reason", "C", 254, 0}   , .F., STR0018 }) //   "Motivo"


Return aStruCPO

/*/{Protheus.doc} PINSMakeTemp
    @type  Function 
    Função responsavel por criar uma tabela temporária para guardar os alerts separados fora do JSON
    @author Raphael Santana Ferreira
    @since 25/07/2024

	@param cAliasTabTmp, Caracter, Nome da tabela temporaria
	@param cInsTyp, Caracter, Tipo de insight
	@param cModulo, Caracter, Módulo do insight
	@param aCampos, array, array com strutura de campos da tabela temporária

    @version version
    @param 
    @return Object, retona o objeto totvs.framework.database.temporary.SharedTable
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
    @type  Function 
    Função que faz o select na tabela I21 retornando todos registros referente ao último
	alert enviado pelo smartlink
    @author Raphael Santana Ferreira
    
	@param cInsTyp, Caractere, contém a string referente ao tipo de insight será filtrado na query
	@param cModulo, Caractere, contém a string referente ao módulo que será filtrado na query
	@param cQryBranch, Caracter, String com as filiais onde o usuário tem acesso.
    
	@since 25/07/2024
    @version version
	@return cNextAlias, String contendo a área aberta na execução da query
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
    @type  Function 
    Retorna um array com os dados da linha do Json de alert enviada por parâmetro
	alert enviado pelo smartlink
    @author Raphael Santana Ferreira
    @since 25/07/2024

	@param oJson, objeto, contém a linha posicionada no array de Json de alerts
	@param aCpoTab, array, contém um array com os dados de campos referente a tabela temporária e propriedades do json de alert

    @version version
    @return array, array contendo os dados que serão inseridos na tabela temporária ordenado por coluna
/*/
Static Function PINSAlertLine(oJson, aCpoTab)

	Local nI           as Numeric
	Local aRet         as Array
	Local cGraphPoints as Character

	nI           := 0
	aRet         := {}
	cGraphPoints := ""

	For nI:=1 To Len(aCpoTab)

		If !( aCpoTab[nI][2][1] $ 'branch/ctrl_numb/recnoI21/stck_qtt/msg_status/msg_result') .and. !Empty( aCpoTab[nI][1] )

			If ValType(oJson[aCpoTab[nI][1]]) == "C"
				Aadd(aRet, DecodeUTF8( Upper( AllTrim( oJson[ aCpoTab[ nI ][ 1 ] ] ) ) ) )
			Else
				Aadd(aRet, oJson[aCpoTab[nI][1]])
			EndIf
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
