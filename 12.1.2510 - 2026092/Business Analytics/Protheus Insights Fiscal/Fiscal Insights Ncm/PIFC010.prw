#INCLUDE 'PROTHEUS.CH'
#include "InsightDefs.ch"

//------------------------------------------------------------------------------
/* {Protheus.doc} PIFC010
    Função inicial do Insight Ncm Suggestion
	  Gera a tabela temporária contendo as linhas do Json de alerts
  
    @type  Function 
    @author Squad PIF
    @return oTmpTab, object, retona o objeto totvs.framework.database.temporary.SharedTable
*/
//------------------------------------------------------------------------------
Function PIFC010()

	Local cInsTyp    as Character
	Local cModulo    as Character
	Local cInsAlias  as Character
	Local aFieldsTab as Array
	Local oTmpTab    as Object

	//Instancia o objeto da tabela temporária
	cInsAlias	  := GetNextAlias()
	oTmpTab       := Nil
	cInsTyp		  := "ncm_suggestion"
	cModulo		  := "FIS"
	aFieldsTab	  := PIFC010Fld()

	//Cria tabela temporária
	If AliasInDic("I21")
		oTmpTab := PINSMakeTemp(cInsAlias, cInsTyp, cModulo, aFieldsTab, NEW_ARCHITECTURE)
	EndIf

Return oTmpTab

//------------------------------------------------------------------------------
/*{Protheus.doc} PIFC010Fld
    Função responsavel por montar um array com os campos da tabela temporária

    @type  Function 
    @author Squad PIF
    @return array contendo a estrutura de campos para gerar a tabela temporária
*/
//------------------------------------------------------------------------------
Function PIFC010Fld()

	Local aStruct  as Array

	aStruct := {}

	aAdd(aStruct, {"currentNcmGroup"             , { "curNcmGrp"  , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }   , .F. , '', 1, .T. })
	aAdd(aStruct, {"currentNcmGroupDescription"  , { "curNcmGrpD" , "M", 255, 0}                 					          , .F. })
	aAdd(aStruct, {"currentNcm"                  , { "curNcm"     , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }   , .F. , '', 1, .T. })
	aAdd(aStruct, {"currentNcmDescription"       , { "curNcmDesc" , "M", 255, 0}                   				          , .F. })
	aAdd(aStruct, {"proposedNcmCode"             , { "propNcmCd"  , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }   , .F. , '', 1, .T. })
	aAdd(aStruct, {"proposedNcmDescription"      , { "propNcmCdD" , "M", 255, 0}                   		     	          , .F. })
	aAdd(aStruct, {"productCode"                 , { "prodcode"   , "C", TamSX3("B1_COD")[1] , TamSX3("B1_COD")[2] }         , .F. , '', 2, .T. })
	aAdd(aStruct, {"productDescription"          , { "prodDesc"   , "M", 255, 0}                   					      , .F. })
	aAdd(aStruct, {"proposedProductDescription"  , { "propPrdD"   , "M", 255, 0}                   					      , .F. })

	// Campos diretos I21
	aAdd(aStruct, {"status"                      , { "status" , "C", 15, 0}                   						          , .F. })
	aAdd(aStruct, {"branch"                      , pinsTempSizeDefault( "branch" )                   					      , .F. })
	aAdd(aStruct, {"id"                          , pinsTempSizeDefault( "guid", "id" )               					      , .F. })
	aAdd(aStruct, {"recnoI21"                    , {"recnoI21" , "N", 9, 0}                                                   , .F. })

	//Campos referentes as propriedades do JSON, campo I21_RESULT
	aAdd(aStruct, {""                            , pinsTempSizeDefault( "code", "ajuPrdcode" )                                , .F. })
	aAdd(aStruct, {""                            , pinsTempSizeDefault( "description", "ajuPrdDesc" )                         , .F. })
	aAdd(aStruct, {""                            , { "ajuNcm"     , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }    , .F. })
	aAdd(aStruct, {""                            , { "ajuNcmProp" , "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }    , .F. })
	aAdd(aStruct, {""                            , { "userId"     , "C", 6, 0}                                                , .F. })
	aAdd(aStruct, {""                            , { "userName"   , "C", 50, 0}                                               , .F. })
	aAdd(aStruct, {""                            , { "date"       , "C", 10, 0}                                               , .F. })
	aAdd(aStruct, {""                            , { "hour"       , "C", 8, 0}                                                , .F. })

Return aStruct

//------------------------------------------------------------------------------
/*{Protheus.doc} PINSMakeTemp
    Função responsavel por criar uma tabela temporária para guardar os alerts separados fora do JSON

    @type Function 
    @author Squad PIF
    @param cAliasTabTmp, Caracter, Nome da tabela temporaria
    @param cInsTyp, Caracter, Tipo de insight
    @param cModulo, Caracter, Módulo do insight
    @param aCampos, array, array com strutura de campos da tabela temporária
    @return Object, retona o objeto totvs.framework.database.temporary.SharedTable
*/
//------------------------------------------------------------------------------
Static Function PINSMakeTemp(cAliasTabTmp, cInsTyp, cModulo, aCampos, nNewService)

	Local aStruBulk    as Array
	Local aLinTab      as Array
	Local aCpoTab      as Array
	Local aStruCPO     as Array
	Local aAux         as Array
	Local aArea 	   as Array
	Local cQryBranch   as Character
	Local cNextAlias   as Character
	Local cJsonIns     as Character
	Local cResult	   as Character
	Local oTempTable   as Object
	Local jPlaylod        as Object
	Local oBulk        as Object
	Local jAux		   as Object
	Local nX           as Numeric

	cNextAlias    := ""
	nX            := 0
	aStruBulk	  := {}
	aLinTab		  := {}
	aStruCPO      := {}
	aAux          := {}
	aArea    	  := GetArea()
	cQryBranch 	  := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SB1' } )
	cResult  	  := ""
	aCpoTab		  := aCampos
	oTempTable    := totvs.framework.database.temporary.SharedTable():New(cAliasTabTmp)

	//Alimenta o array da estrutura da tabela temporária
	For nX:=1 To Len(aCpoTab)
		aAdd(aStruCPO, {aCpoTab[nX][2][1], aCpoTab[nX][2][2], aCpoTab[nX][2][3], aCpoTab[nX][2][4]})
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

	// Itera sobre todos os registros com o mesmo I21_UIDMSG
	While (cNextAlias)->(!Eof())

		jPlaylod  := JsonObject():New()
		jAux      := JsonObject():New()

		DbSelectArea("I21")
		DbGoTo((cNextAlias)->RECI21)

		cJsonIns := Trim( I21->I21_PAYLOD )
		cResult  := Trim( I21->I21_RESULT )

		jPlaylod:FromJson( cJsonIns )
		jAux:FromJson( cResult )

		aLinTab := {}
		aLinTab := PINSAlertLine(jPlaylod, aCpoTab)

		//Alimentando campos específicos
		aAdd(aLinTab, I21->I21_STATUS )
		aAdd(aLinTab, I21->I21_BRANCH )
		aAdd(aLinTab, I21->I21_UIDINS )
		aAdd(aLinTab, I21->( Recno() ) )

		// //Alimenta código do produto
		SetResultInfo( @aLinTab, "productCode", jAux )

		//Alimenta descrição do produto
		SetResultInfo( @aLinTab, "productDescription", jAux )

		//Alimenta ncm atual
		SetResultInfo( @aLinTab, "ncm", jAux )

		//Alimenta ncm proposto
		SetResultInfo( @aLinTab, "ncmProposed", jAux )

		//Alimenta código do usuário
		SetResultInfo( @aLinTab, "userId", jAux )

		//Alimenta nome do usuário
		SetResultInfo( @aLinTab, "userName", jAux )

		//Alimenta data da alteração
		SetResultInfo( @aLinTab, "date", jAux )

		//Alimenta hora da alteração
		SetResultInfo( @aLinTab, "hour", jAux )

		oBulk:AddData( aLinTab )

		FreeObj( jPlaylod )
		FreeObj( jAux )

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

//------------------------------------------------------------------------------
/*/{Protheus.doc} PINSGetAlerts
    Função que faz o select na tabela I21 retornando todos registros referente ao último
	alert enviado pelo smartlink
    
    @type  Function 
    @author Squad PIF
	@param cInsTyp, Caractere, contém a string referente ao tipo de insight será filtrado na query
	@param cModulo, Caractere, contém a string referente ao módulo que será filtrado na query
	@param cQryBranch, Caracter, String com as filiais onde o usuário tem acesso.
	@return cNextAlias, String contendo a área aberta na execução da query
/*/
//------------------------------------------------------------------------------
Static Function PINSGetAlerts(cInsTyp, cModulo, cQryBranch)

	Local cQuery     as Character
	Local cNextAlias as Character
	Local oPrepare   as Object
	Local aAux 		 as Array
	Local lUseBranch as Logical
	Local nParam     as Numeric

	cNextAlias := ""
	nParam     := 1

	lUseBranch := !Empty( cQryBranch )

	IIF(lUseBranch, eVal({|| cQryBranch := StrTran( cQryBranch, ", ", "," ),;
		cQryBranch := StrTran( cQryBranch, "'", "" ),;
		aAux := StrTokArr( cQryBranch, ',' )}) , .T.)

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

	IIF(lUseBranch, cQuery += " AND I21.I21_BRANCH IN ( ? ) ", .T.)

	cQuery += " AND I21.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)

	oPrepare := FWPreparedStatement():New(cQuery)

	oPrepare:setString( nParam++, ' ' )
	oPrepare:setString( nParam++, cInsTyp )
	oPrepare:setString( nParam++, ' ' )
	oPrepare:setString( nParam++, cModulo )
	oPrepare:setString( nParam++, cInsTyp )

	IIF(lUseBranch, eVal({|| oPrepare:setIn( nParam++, aAux ),;
		oPrepare:setString( nParam++, ' ' )}),;
		oPrepare:setString( nParam++, ' ' ))

	cNextAlias := MPSysOpenQuery( oPrepare:GetFixQuery() )

	FreeObj(oPrepare)

Return cNextAlias

//------------------------------------------------------------------------------
/*{Protheus.doc} PINSAlertLine
    Retorna um array com os dados da linha do Json de alert enviada por parâmetro
	  alert enviado pelo smartlink

    @type  Function 
    @author Squad PIF
    @param jPlaylod, objeto, contém a linha posicionada no array de Json de alerts
    @param aCpoTab, array, contém um array com os dados de campos referente a tabela temporária e propriedades do json de alert
    @return array, array contendo os dados que serão inseridos na tabela temporária ordenado por coluna
*/
//------------------------------------------------------------------------------
Static Function PINSAlertLine(jPlaylod, aCpoTab)

	Local nI           as Numeric
	Local aRet         as Array
	Local cGraphPoints as Character

	nI           := 0
	aRet         := {}
	cGraphPoints := ""

	For nI := 1 To Len(aCpoTab)

		If !( aCpoTab[nI][2][1] $ 'status/branch/recnoI21/id/productCode/productDescription/reason/ncm/ncmProposed/userId/userName/date/hour') .and. !Empty( aCpoTab[nI][1] )

			IIF(ValType(jPlaylod[aCpoTab[nI][1]]) == "C",;
				eVal({|| xDecode := DecodeUTF8( AllTrim( jPlaylod[ aCpoTab[ nI ][ 1 ] ] ) ),;
				 IIF(Type("xDecode") == "C", aAdd(aRet, xDecode), aAdd(aRet, jPlaylod[aCpoTab[nI][1]])) }),;
				aAdd(aRet, jPlaylod[aCpoTab[nI][1]]))

		EndIf
	Next nI

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} SetResultInfo
  Função que alimenta as posições da tabela temporária de acordo a propriedade passada.

  @type  Function 
  @author Squad PIF
  @param @aLinTab, array, vetor com as informações que serão gravadas na tabela temporária, onde cada posição representa uma coluna.
  @param cPropertie, character, nome da propriedade do objeto JSON a ser pesquisado.
  @param jResult, json, objeto com o conteúdo do campo I21_RESULT.
*/
//-------------------------------------------------------------------
Static Function SetResultInfo( aLinTab, cPropertie, jResult )

	aAdd( aLinTab, "" )

	nLinTab := len(aLinTab)

	IIF(jResult:HasProperty( cPropertie ) .And. !Empty( jResult[ cPropertie ] ),;
	 aLinTab[nLinTab] := jResult[ cPropertie ],.T.)
Return
