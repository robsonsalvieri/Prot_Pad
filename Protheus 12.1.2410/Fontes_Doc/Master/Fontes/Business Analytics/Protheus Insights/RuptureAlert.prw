#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "InsightDefs.ch"
#INCLUDE "RuptureAlert.ch"

Static __cSessionID := ""
Static __cMetricName := ""

/*/{Protheus.doc} RuptureAlert
    @type  Function 
    Função inicial do Insight RuptureAlert, chamada pela rotina MATA010
	Gera a tabela temporária contendo as linhas do Json de alerts e faz a chamada do APP POUI

	@param cAlias, caracter, Alias do arquivo                                   
	@param nReg, number, Numero do registro       
	@param nOpc, number, Numero da opcao selecionada 			    
	@param aADVPRInfo, array, vetor contendo informações necessárias para automação  
    @return
/*/
Function RuptureAlert( cAlias, nReg, nOpc, aADVPRInfo )

	Local lHasValidate := FindFunction( "totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights", .T. )
	Local lReturn := .T.

	Default aADVPRInfo := NIL

	If AliasInDic("I14")
		DbSelectArea("I14")
	EndIf
	If AliasInDic("I19")		
		DbSelectArea("I19")
	EndIf
	If AliasInDic("I20")
		DbSelectArea("I20")
	EndIf
	If AliasInDic("I21")
		DbSelectArea("I21")
	EndIf
	If AliasInDic("I1A")
		DbSelectArea("I1A")
	EndIf

	IF lHasValidate .And. totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights( 0, aADVPRInfo )	//Valida requisitos
		__cMetricName := "INSIGHT_ACCESS_MATA010"
		__cSessionID := FWUUIDV1()
		SendMetricFin ({__cMetricName,__cSessionID})

		PINSA030()	// Central IA
	Else
	 	lReturn := .F.
	EndIf
Return lReturn

/*/{Protheus.doc} JsToAdvpl
    @type  Function 
    Função chamada pelo POUI para fazer requisições via webchanel
    @version version
	@param oWebChannel, object, contém o objeto com os dados do webchanel
    @param cContent, Character, 
	@param cType, Character, tipo de chamada requisitada pelo POUI
    @return lógico
/*/
Static Function JsToAdvpl(oWebChannel As Object, cType As Character, cContent As Character)

	Local aParamMetric  as Array
	Local oParamsMetric as Object
	Local lRetEst       as Logical
	Local jStorage      as Json
	Local aFieldsTab    as Array
	Local cInsTyp       as Character
	Local oJsFieldsTab  as Object
	Local nTotLinha     as Numeric
	Local oJson   	    as Object
	Local nX 		    as Numeric
	Local cPropJs 		as Character
	Local cNextAlias 	as Character
	Local lMock			as Logical

	jStorage     := JsonObject():New()
	nTotLinha    := 0
	aFieldsTab   := GetFldRup()
	oJsFieldsTab := JsonObject():New()
	cInsTyp      := "ruptureAlert"
	aParamMetric := {}
	lRetEst      := .F.
	oJson		 := JsonObject():New()
	nX 	 		 := 0
	cPropJs		 := "alerts"
	lMock        := .F.

	oJsFieldsTab[cInsTyp]     := {}

	aEval(aFieldsTab, {|i| aAdd(oJsFieldsTab[cInsTyp], i)})

	If cType == "preLoad"

		//Alimenta o envio do nome da tabela temporária
		jStorage[ 'iaTabTempName' ] := oTmpTab:GetRealName()
		jStorage[ 'branchs' ]       := FWCodFil()
		jStorage[ 'company' ]       := FWGrpCompany()
		jStorage[ 'coduser' ]       := __cUserID
		jStorage[ 'sessionId' ]     := __cSessionID
		jStorage[ 'iaJsFieldsTab' ] := oJsFieldsTab:ToJson()
		jStorage[ 'iaMockType' ]    := "rupture"

		//Verifica se a tabela temporária tem registros
		nTotLinha := PINSRegCnt(oTmpTab:GetRealName())

		If nTotLinha == 0
			//Verifica se tem registros para este insight na tabela I14
			cNextAlias := PINSGetAlerts( 'WAR', 'RuptureAlert', 'estoque')

			//Chama função do mock
			PinsMakeMock(oTmpTab:GetRealName(), "rupture", aFieldsTab, cPropJs)
			lMock := .T.
			
			IF ( cNextAlias )->( !Eof() )
				jStorage[ 'iaMockMessage' ] := STR0010 	//"Não foram encontrados insights para as filiais acessíveis para este usuário."
			EndIf
			( cNextAlias )->( DBCloseArea() )
		Endif

		jStorage[ 'iaIsMock' ]      := lMock
		jStorage[ 'iaJsFieldsTab' ] := oJsFieldsTab:ToJson()

		oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())

		FreeObj(jStorage)

		lRetEst := .T.

	ElseIf cType == "InsightMetric"
		If !FWJSonDeserialize(cContent, @oParamsMetric)
			FWLogMsg("ERROR",Nil,"ProtheusInsights","RuptureAlert",Nil,"",STR0003)
			Return
		EndIf
		// cContent   o Id do relatorio (TRANID) enviado pelo front-end
		FWLogMsg("INFO",Nil,"ProtheusInsights","RuptureAlert",Nil,"",STR0004 + oParamsMetric:METRICNAME + STR0005) //Enviando metrica ao Smartlink []
		
		//Tratar ccontent json {'metrics_name'}
		cIDMetric := oParamsMetric:PAYLOAD:SESSIONID
		aAdd(aParamMetric, oParamsMetric:METRICNAME)
		aAdd(aParamMetric, cIDMetric)
		If oParamsMetric:METRICNAME == "INSIGHT_STOCK_DEMO_OPEN"
			grvMetrDemo("STOCK", oParamsMetric:PAYLOAD:SESSIONID, oParamsMetric:METRICNAME)
		Else
			If(SendMetricFin(aParamMetric))	// Envio da Metrica para Smartink
				FWLogMsg("INFO",Nil,"ProtheusInsights","RuptureAlert",Nil,"",STR0006) //"Metrica Enviada com sucesso"
			Else
				FWLogMsg("ERROR",Nil,"ProtheusInsights","RuptureAlert",Nil,"",STR0007)
			EndIf
		endif
	EndIf

Return lRetEst

/*/{Protheus.doc} GetFldRup
    @type  Function 
    Função responsavel por montar um array com os campos da tabela temporária
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param 
    @return array
/*/
Function GetFldRup()

	Local aStruCPO  as Array

	aStruCPO := {}

	aadd(aStruCPO, {"branch"               , {"branch", "C", TamSX3("D3_FILIAL")[1] , TamSX3("D3_FILIAL")[2] }    , .T.})
	aadd(aStruCPO, {"company_group"        , {"comp_grp", "C", 10, 0}                                             , .F.})
	aadd(aStruCPO, {"code"                 , {"code", "C", TamSX3("B1_COD")[1] , TamSX3("B1_COD")[2] }            , .T.})
	aadd(aStruCPO, {"id"                   , {"id", "C", 36, 0}                                                   , .F.})
	aadd(aStruCPO, {"stock_out_date"       , {"stckodt", "C", 26, 0}                                              , .F.})
	aadd(aStruCPO, {"forecast_value"       , {"forc_vl", "N", 17, 2}                                              , .F.})
	aadd(aStruCPO, {"stock_quantity"       , {"stckqt", "N", TamSX3("B2_QATU")[1] , TamSX3("B2_QATU")[2] }        , .F.})
	aadd(aStruCPO, {"replenishment"        , {"repmnt", "N", TamSX3("B1_EMIN")[1] , TamSX3("B1_EMIN")[2] }		  , .F.})
	aadd(aStruCPO, {"safety_stock"         , {"sft_stck", "N", TamSX3("B1_ESTSEG")[1] , TamSX3("B1_ESTSEG")[2] }  , .F.})
	aadd(aStruCPO, {"description"          , {"descrip", "C", TamSX3("B1_DESC")[1] , TamSX3("B1_DESC")[2] }       , .T.})
	aadd(aStruCPO, {"type"                 , {"tpe", "C", TamSX3("B1_TIPO")[1] , TamSX3("B1_TIPO")[2] }           , .F.})
	aadd(aStruCPO, {"type_description"     , {"tp_desc", "C", TamSX3("X5_DESCRI")[1] , TamSX3("X5_DESCRI")[2] }   , .F.})
	aadd(aStruCPO, {"group_code"           , {"grp_cod", "C", TamSX3("B1_GRUPO")[1] , TamSX3("B1_GRUPO")[2] }     , .F.})
	aadd(aStruCPO, {"group_description"    , {"grp_desc", "C", TamSX3("BM_DESC")[1] , TamSX3("BM_DESC")[2] }      , .F.})
	aadd(aStruCPO, {"unity"                , {"unity", "C", TamSX3("B1_UM")[1] , TamSX3("B1_UM")[2] }             , .F.})
	aadd(aStruCPO, {"desc_espec"           , {"desc_esp", "C", TamSX3("B1_ESPECIF")[1] , TamSX3("B1_ESPECIF")[2] }, .F.})
	aadd(aStruCPO, {"minimum_lot"          , {"min_lot", "N", TamSX3("B1_LM")[1] , TamSX3("B1_LM")[2] }           , .F.})
	aadd(aStruCPO, {"max_stock"            , {"mas_stck", "N", TamSX3("B1_EMAX")[1] , TamSX3("B1_EMAX")[2] }      , .F.})
	aadd(aStruCPO, {"supplier"             , {"supplier", "C", TamSX3("B1_PROC")[1] , TamSX3("B1_PROC")[2] }      , .F.})
	aadd(aStruCPO, {"store"                , {"store", "C", TamSX3("B1_LOJPROC")[1] , TamSX3("B1_LOJPROC")[2] }   , .F.})
	aadd(aStruCPO, {"suppliername"         , {"sup_name", "C", TamSX3("A2_NREDUZ")[1] , TamSX3("A2_NREDUZ")[2] }  , .F.})
	aadd(aStruCPO, {"storage"              , {"storage", "C", TamSX3("B1_LOCPAD")[1] , TamSX3("B1_LOCPAD")[2] }   , .F.})
	aadd(aStruCPO, {"inventory_periodicity", {"inv_perio", "C", TamSX3("B1_PERINV")[1] , TamSX3("B1_PERINV")[2] } , .F.})
	aadd(aStruCPO, {"last_revision_date"   , {"lst_rev_dt", "C", 26 , 0 }    , .F.})
	aadd(aStruCPO, {"origin"               , {"orign", "C", TamSX3("B1_ORIGEM")[1] , TamSX3("B1_ORIGEM")[2] }     , .F.})
	aadd(aStruCPO, {"frequency"            , {"frequency", "C", 1, 0}                                             , .F.})
	aadd(aStruCPO, {"tenantId"             , {"tenantid", "C", 36, 0}                                             , .F.})
	aadd(aStruCPO, {"accuracy"             , {"accuracy", "N", 7, 2}                                              , .F.})
	aadd(aStruCPO, {"pb_calculate"         , {"pb_calc", "L", 1, 0}                                               , .F.})
	aadd(aStruCPO, {"mdmLastUpdated"       , {"mLstUpd","C", 36, 0}                                               , .F.})
	aadd(aStruCPO, {"graphPoints"          , {"grphPt" , "M", 10 , 0}                                             , .F.})
	aadd(aStruCPO, {"maecategory"          , {"mae_categ" , "C", 2 , 0}                                           , .F.})

	aStruCPO := PINSDebugFields(aStruCPO)

Return aStruCPO

