#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "InsightDefs.ch"
#INCLUDE "DemandAlert.ch"

Static __cSessionID := ""
Static __cMetricName := ""

/*/{Protheus.doc} DemandAlert
    @type  Function 
    Função inicial do Insight DemandAlert, chamada pela rotina MATA110
	Gera a tabela temporária contendo as linhas do Json de alerts e faz a chamada do APP POUI
	
	@param cAlias, caracter, Alias do arquivo                                   
	@param nReg, number, Numero do registro       
	@param nOpc, number, Numero da opcao selecionada 			    
	@param aADVPRInfo, array, vetor contendo informações necessárias para automação  
    @return
/*/
Function DemandAlert( cAlias, nReg, nOpc, aADVPRInfo )

	Local lHasValidate	:= FindFunction( "totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights", .T. )
	Local lReturn := .T.

	Private oTmpTab     as Object

	Default aADVPRInfo := NIL

	IF lHasValidate .And. totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights( 0, aADVPRInfo )	//Valida requisitos
		__cMetricName := "INSIGHT_ACCESS_MATA110"
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
	Local aFieldsTab    as Array
	Local cInsTyp       as Character
	Local lRetEst       as Logical
	Local jStorage      as Json
	Local oJsFieldsTab  as Object
	Local nTotLinha     as Numeric
	Local oJson			as Object
	Local nX 		    as Numeric
	Local cPropJs 		as Character
	Local cNextAlias 	as Character
	Local lMock			as Logical

	jStorage     := JsonObject():New()
	nTotLinha    := 0
	aFieldsTab   := GetFldDem()
	oJsFieldsTab := JsonObject():New()
	cInsTyp      := "demandAlert"
	aParamMetric := {}
	lRetEst      := .F.
	oJson   	 := JsonObject():New()
	nX 			 := 0
	cPropJs		 := "alerts"
	lMock        := .F.

	oJsFieldsTab[cInsTyp]     := {}
	oJsFieldsTab[ 'tabMock' ] := ""

	aEval(aFieldsTab, {|i| aAdd(oJsFieldsTab[cInsTyp], i)})

	if cType == "preLoad"

		//Alimenta o envio do nome da tabela temporária
		jStorage[ 'iaTabTempName' ] := oTmpTab:GetRealName()
		jStorage[ 'branchs' ]       := FWCodFil()
		jStorage[ 'company' ]       := FWGrpCompany()
		jStorage[ 'coduser' ]       := __cUserID
		jStorage[ 'sessionId' ]     := __cSessionID
		jStorage[ 'iaJsFieldsTab' ] := oJsFieldsTab:ToJson()
		jStorage[ 'iaMockType' ]    := "demand"

		//Verifica se a tabela temporária tem registros
		nTotLinha := PINSRegCnt(oTmpTab:GetRealName())

		If nTotLinha == 0
			// Verifica se tem registros para este insight na tabela I14
			cNextAlias := PINSGetAlerts( 'WAR', 'DemandAlert', 'compras' )
			
			//Chama função do mock
			PinsMakeMock(oTmpTab:GetRealName(), "demand", aFieldsTab, cPropJs)
			lMock := .T.
			
			IF ( cNextAlias )->( !Eof() )
				jStorage[ 'iaMockMessage' ] := STR0010 //"Não foram encontrados insights para as filiais acessíveis para este usuário."
			EndIf
			( cNextAlias )->( DBCloseArea() )
		Endif

		jStorage[ 'iaIsMock' ]      := lMock
		oWebChannel:AdvPLToJS('setStorage', jStorage:toJSON())

		FreeObj(jStorage)
		lRetEst := .T.

	ElseIf cType == "InsightMetric" 
		If !FWJSonDeserialize(cContent, @oParamsMetric)
			FWLogMsg("ERROR",Nil,"ProtheusInsights","DemandAlert",Nil,"",STR0003) //Erro ao deserealizar parametros
			Return
		EndIf
		// cContent é o Id do relatorio (TRANID) enviado pelo front-end
		FWLogMsg("INFO",Nil,"ProtheusInsights","DemandAlert",Nil,"",STR0004 + oParamsMetric:METRICNAME  + STR0005) //Enviando metrica ao Smartlink []
		//Tratar ccontent json {'metrics_name'}
		cIDMetric := oParamsMetric:PAYLOAD:SESSIONID
		aAdd(aParamMetric, oParamsMetric:METRICNAME)
		aAdd(aParamMetric, cIDMetric)
		If oParamsMetric:METRICNAME == "INSIGHT_PURCHASE_DEMO_OPEN"
			grvMetrDemo("PURCHASE",oParamsMetric:PAYLOAD:SESSIONID, oParamsMetric:METRICNAME)
		Else
			If(SendMetricFin(aParamMetric))	// Envio da Metrica para Smartink
				FWLogMsg("INFO",Nil,"ProtheusInsights","DemandAlert",Nil,"",STR0006 ) //Metrica Enviada com sucesso"
			Else
				FWLogMsg("ERROR",Nil,"ProtheusInsights","DemandAlert",Nil,"",STR0007) //Falha ao enviar Metrica para Smartlink (servico retornou Falso)
			EndIf
		Endif
	EndIf

Return lRetEst

/*/{Protheus.doc} GetFldDem
    @type  Function 
    Função responsavel por montar um array com os campos da tabela temporária
    @author Raphael Santana Ferreira
    @since 25/07/2024
    @version version
    @param 
    @return array
/*/
Function GetFldDem()

	Local aStruCPO  as Array

	aStruCPO := {}

	aadd(aStruCPO, {"accuracy"              , {"accuracy", "N", 7 , 2 }                                             , .F.})
	aadd(aStruCPO, {"mdmLastUpdated"        , {"mLstUpd", "C", 36 , 0 }                                             , .F.})
	aadd(aStruCPO, {"tenantid"              , {"tenantid", "C", 36 , 0 }                                            , .F.})
	aadd(aStruCPO, {"branch"                , {"branch", "C", TamSX3("D3_FILIAL")[1] , TamSX3("D3_FILIAL")[2] }     , .T.})
	aadd(aStruCPO, {"code"                  , {"code", "C", TamSX3("B1_COD")[1] , TamSX3("B1_COD")[2] }             , .T.})
	aadd(aStruCPO, {"company_group"         , {"comp_grp", "C", 10 , 0 }                                            , .F.})
	aadd(aStruCPO, {"default_supplier"      , {"dft_sup", "C", TamSX3("B1_PROC")[1] , TamSX3("B1_PROC")[2] }        , .F.})
	aadd(aStruCPO, {"default_supplier_name" , {"dft_name", "C",TamSX3("A2_NOME")[1] , TamSX3("A2_NOME")[2] }        , .F.})
	aadd(aStruCPO, {"default_supplier_unity", {"dft_unity", "C", TamSX3("B1_LOJPROC")[1] , TamSX3("B1_LOJPROC")[2] }, .F.})
	aadd(aStruCPO, {"desc_supplier"         , {"desc_sup", "C", TamSX3("A2_NOME")[1] , TamSX3("A2_NOME")[2] }       , .F.})
	aadd(aStruCPO, {"frequency"             , {"frequency", "C", 1 , 0 }                                            , .F.})
	aadd(aStruCPO, {"id"                    , {"id", "C", 36 , 0 }                                                  , .F.})
	aadd(aStruCPO, {"last_price"            , {"last_prc", "N", TamSX3("B1_UPRC")[1] , TamSX3("B1_UPRC")[2] }       , .F.})
	aadd(aStruCPO, {"last_rev"              , {"last_rev", "C", 26 , 0 }       , .F.})
	aadd(aStruCPO, {"last_sell"             , {"last_sll", "C", 26 , 0 }       , .F.})
	aadd(aStruCPO, {"measurement_unity"     , {"msnt_un", "C", TamSX3("B1_UM")[1] , TamSX3("B1_UM")[2] }            , .F.})
	aadd(aStruCPO, {"origin"                , {"origin", "C", TamSX3("B1_ORIGEM")[1] , TamSX3("B1_ORIGEM")[2] }     , .F.})
	aadd(aStruCPO, {"package_quantity"      , {"pkg_qtd", "N", TamSX3("B1_QE")[1] , TamSX3("B1_QE")[2] }            , .F.})
	aadd(aStruCPO, {"prevision_delivery"    , {"prv_dlv", "N", TamSX3("B1_PE")[1] , TamSX3("B1_PE")[2] }            , .F.})
	aadd(aStruCPO, {"price"                 , {"price", "N", TamSX3("C7_PRECO")[1] , TamSX3("C7_PRECO")[2] }        , .F.})
	aadd(aStruCPO, {"prod_situ"             , {"prd_sit", "C", TamSX3("B1_SITPROD")[1] , TamSX3("B1_SITPROD")[2] }  , .F.})
	aadd(aStruCPO, {"product_group"         , {"prd_group", "C", TamSX3("B1_GRUPO")[1] , TamSX3("B1_GRUPO")[2] }    , .F.})
	aadd(aStruCPO, {"quantity"              , {"quantity", "N", 17 , 2 }                                            , .F.})
	aadd(aStruCPO, {"raw_weight"            , {"raw_wght", "N", TamSX3("B1_PESBRU")[1] , TamSX3("B1_PESBRU")[2] }   , .F.})
	aadd(aStruCPO, {"specific_description"  , {"spc_desc", "C", TamSX3("B1_ESPECIF")[1] , TamSX3("B1_ESPECIF")[2] } , .F.})
	aadd(aStruCPO, {"supplier"              , {"supplier", "C", TamSX3("A2_COD")[1] , TamSX3("A2_COD")[2] }         , .F.})
	aadd(aStruCPO, {"unity"                 , {"unity", "C", TamSX3("A2_LOJA")[1] , TamSX3("A2_LOJA")[2] }          , .F.})
	aadd(aStruCPO, {"type"                  , {"tpe", "C", TamSX3("B1_TIPO")[1] , TamSX3("B1_TIPO")[2] }            , .F.})
	aadd(aStruCPO, {"description"           , {"descrip", "C", TamSX3("B1_DESC")[1] , TamSX3("B1_DESC")[2] }        , .T.})
	aadd(aStruCPO, {"type_description"      , {"tp_desc", "C", TamSX3("X5_DESCRI")[1] , TamSX3("X5_DESCRI")[2] }    , .F.})
	aadd(aStruCPO, {"group_description"     , {"grp_desc", "C", TamSX3("BM_DESC")[1] , TamSX3("BM_DESC")[2] }       , .F.})
	aadd(aStruCPO, {"graphPoints"           , {"grphPt" , "M", 10 , 0}                                              , .F.})
	aadd(aStruCPO, {"maecategory"           , {"mae_categ" , "C", 2 , 0}                                            , .F.})

	aStruCPO := PINSDebugFields(aStruCPO)

Return aStruCPO

