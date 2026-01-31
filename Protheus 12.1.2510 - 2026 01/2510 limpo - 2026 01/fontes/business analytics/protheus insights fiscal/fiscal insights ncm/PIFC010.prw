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

	// Campos referentes as propriedades do JSON, campo I21_PAYLOD
	aadd(aStruct, {"proposedNcmCode"             , { "propNcmCd", "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] } , .F. , '', 1, .T. })
	aadd(aStruct, {"productCode"                 , pinsTempSizeDefault( "code", "prodcode" )         					 , .F. , '', 2, .T. })
	aadd(aStruct, {"proposedNcmDescription"      , pinsTempSizeDefault( "description", "proddescr" ) 					 , .F. , '', 3 })
	
  	// Campos diretos I21 
	aadd(aStruct, {"status"                      , { "status" , "C", 15, 0}                   						     , .F. })
	aadd(aStruct, {"branch"                      , pinsTempSizeDefault( "branch" )                   					 , .F. })
  	aadd(aStruct, {"id"                          , pinsTempSizeDefault( "guid", "id" )               					 , .F. })
  	aadd(aStruct, {"recnoI21"                    , {"recnoI21" , "N", 9, 0}                                              , .F. })
	
	//Campos referentes as propriedades do JSON, campo I21_RESULT
	aadd(aStruct, {""                            , pinsTempSizeDefault( "code", "ajuPrdcode" )                           , .F. })
	aadd(aStruct, {""                            , pinsTempSizeDefault( "description", "ajuPrdDesc" )                    , .F. })
	aadd(aStruct, {""                            , { "ajuNcm", "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }    , .F. })
	aadd(aStruct, {""                            , { "ajuNcmProp", "C", TamSX3("B1_POSIPI")[1] , TamSX3("B1_POSIPI")[2] }, .F. })
	aadd(aStruct, {""                            , { "userId" , "C", 6, 0}                                               , .F. })
	aadd(aStruct, {""                            , { "userName" , "C", 50, 0}                                            , .F. })
	aadd(aStruct, {""                            , { "date" , "C", 10, 0}                                                , .F. })
	aadd(aStruct, {""                            , { "hour" , "C", 8, 0}                                                 , .F. })

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
	Local oJson        as Object
	Local oBulk        as Object
	Local oAux		   as Object
	Local nX           as Numeric

	cNextAlias    := ""
	nX            := 0
	aStruBulk	  := {}
	aLinTab		  := {}
	aStruCPO      := {}
	aAux          := {}
	aArea    	  := GetArea()
	cQryBranch 	  := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SFT', 'SB1' } )					
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
	cNextAlias := PINSGetAlerts(, cInsTyp, cModulo, nNewService, cQryBranch )

	// Itera sobre todos os registros com o mesmo I21_UIDMSG
	While (cNextAlias)->(!Eof())

		oJson  := JsonObject():New()
		oAux   := JsonObject():New()

		DbSelectArea("I21")
		DbGoTo((cNextAlias)->RECI21)

		cJsonIns := Trim( I21->I21_PAYLOD )
		cResult  := Trim( I21->I21_RESULT )

		oJson:FromJson( cJsonIns )
		oAux:FromJson( cResult )

		aLinTab := {}
		aLinTab := PINSAlertLine(oJson, aCpoTab)

		//Alimentando campos específicos
		Aadd(aLinTab, I21->I21_STATUS )
		Aadd(aLinTab, I21->I21_BRANCH )
		Aadd(aLinTab, I21->I21_UIDINS )
		Aadd(aLinTab, I21->( Recno() ) )

		// //Alimenta código do produto
		SetResultInfo( @aLinTab, "productCode", oAux )

		//Alimenta descrição do produto
		SetResultInfo( @aLinTab, "productDescription", oAux )

		//Alimenta ncm atual
		SetResultInfo( @aLinTab, "ncm", oAux )

		//Alimenta ncm proposto
		SetResultInfo( @aLinTab, "ncmProposed", oAux )

		//Alimenta código do usuário
		SetResultInfo( @aLinTab, "userId", oAux )

		//Alimenta nome do usuário
		SetResultInfo( @aLinTab, "userName", oAux )

		//Alimenta data da alteração
		SetResultInfo( @aLinTab, "date", oAux )

		//Alimenta hora da alteração
		SetResultInfo( @aLinTab, "hour", oAux )
		
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

//------------------------------------------------------------------------------
/*{Protheus.doc} PINSAlertLine
    Retorna um array com os dados da linha do Json de alert enviada por parâmetro
	  alert enviado pelo smartlink

    @type  Function 
    @author Squad PIF
    @param oJson, objeto, contém a linha posicionada no array de Json de alerts
    @param aCpoTab, array, contém um array com os dados de campos referente a tabela temporária e propriedades do json de alert
    @return array, array contendo os dados que serão inseridos na tabela temporária ordenado por coluna
*/
//------------------------------------------------------------------------------
Static Function PINSAlertLine(oJson, aCpoTab)

	Local nI           as Numeric
	Local aRet         as Array
	Local cGraphPoints as Character

	nI           := 0
	aRet         := {}
	cGraphPoints := ""

	For nI:=1 To Len(aCpoTab)

		If !( aCpoTab[nI][2][1] $ 'status/branch/recnoI21/id/productCode/productDescription/reason/ncm/ncmProposed/userId/userName/date/hour') .and. !Empty( aCpoTab[nI][1] )

			IIF( ValType(oJson[aCpoTab[nI][1]]) == "C" ,;
				Aadd(aRet, DecodeUTF8( Upper( AllTrim( oJson[ aCpoTab[ nI ][ 1 ] ] ) ) ) ) ,;
				Aadd(aRet, oJson[aCpoTab[nI][1]]) )
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
  @param oJsonResult, json, objeto com o conteúdo do campo I21_RESULT.
*/
//-------------------------------------------------------------------
Static Function SetResultInfo( aLinTab, cPropertie, oJsonResult )
	
	Aadd( aLinTab, "" )

	nLinTab := len(aLinTab)

	If oJsonResult:HasProperty( cPropertie ) .And. !Empty( oJsonResult[ cPropertie ] )
    	aLinTab[nLinTab] := oJsonResult[ cPropertie ]
	EndIf
Return
