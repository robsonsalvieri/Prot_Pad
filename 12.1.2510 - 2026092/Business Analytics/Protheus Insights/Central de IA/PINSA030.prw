#INCLUDE "TOTVS.CH"
#INCLUDE "PINSA030.CH"

Static __cSessionID := FWUUIDV4( .T. )
Static __aTempTables := {}
Static __cTenantID := GetTenantClient()

//-------------------------------------------------------------------
/*/{Protheus.doc} PINSA030
Função responsável pela chamada da Central de IA.

@param cAlias, caracter, Alias do arquivo
@param nReg, number, Numero do registro
@param nOpc, number, Numero da opcao selecionada

@author  Marcia Junko
@since   18/10/2024
/*/
//-------------------------------------------------------------------
Function PINSA030( cAlias, nReg, nOpc )

	Local nI  as Numeric

	If totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights( 0 )	//Valida requisitos de LIB e Smartlink
		nI := 0

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

		//--------------------------------------------------------------
		// Avaliação do agendamento de Jobs do Protheus Insights
		//--------------------------------------------------------------
		If FindFunction("totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights",.T.)
			totvs.protheus.backoffice.ba.insights.util.validateUseOfInsights(1) // 1 - Execução da activeJobs
		Endif

		FWCallApp( "pinsa030" )

		// deleta temporarias
		For nI := 1 To Len( __aTempTables )
			If __aTempTables[ nI ][ 2 ] <> NIL
				__aTempTables[ nI ][ 2 ]:delete()
			EndIf
		Next
	Else

		grvMetrDemo( "ENVIRONMENT", __cSessionID, "INSIGHT_ENVIRONMENT_OPEN", "LIB" )	// Lib ou Smartlink desatualizado

	EndIf

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} JsToAdvpl
Configura o preLoad do sistema na Central IA.

@param oWebChannel, object
@param cType, character
@param cContent, character

@author Raphael Santana Ferreira
@since 10/10/2024
/*/
//-------------------------------------------------------------------------------------
Static Function JsToAdvpl( oWebChannel As Object, cType As Character, cContent As Character, lADVPRSession As Logical )

	Local jStorage            := JsonObject():New()   As Json
	Local jDisable            := JsonObject():New()   As Json
	Local jSalesOrderData     := JsonObject():New()   As Json
	Local jSalesOrderResponse := JsonObject():New()   As Json
	Local jResponse           := JsonObject():New()   As Json
	Local jMetric			  := JsonObject():New()   As Json
	Local jDTAFlowReq         := JsonObject():New()   As Json
	Local jActivation 		  := JsonObject():New()   As Json

	Local oFeatureTempTable := Nil	As Object
	Local oInsightConfig 			As Object
	Local oInsightDefinition		As Object
	Local nSelectedFeature := 0    	As Numeric
	Local aFields := {} 			As Array
	Local aUseMock := {.F.,"",.F.}	As Array
	Local aParamDTAReq := {}		As Array
	Local aMessageDisable := {}		As Array
	Local cInsightName := ""		As Character
	Local cModule := ""				As Character
	Local cQryBranch := ""			As Character
	Local cResponse := ""			As Character
	Local cMessage := ""			As Character
	Local cMvTfcjobT := ""			As Character
	Local cMetricType := ""			As Character
	Local cMetricName := ""			As Character
	Local lShowInfo  := .F.         As Logical
	Local lOk := .T.				As Logical

	Default lADVPRSession := .F.

	Do Case
	Case cType == "preLoad"

		jStorage[ "sessionId" ] := __cSessionID
		jStorage[ "codUser" ] := __cUserId
		jStorage[ "branch" ] := cFilAnt

		// Informa a formatação de valores.
		jStorage[ "currencyTitle" ] := Upper( allTrim( SuperGetMv( "MV_MOEDA1" ) ) )
		jStorage[ "currencySymbol" ] := allTrim( SuperGetMv( "MV_SIMB1" ) )
		jStorage[ "currencyDecimals" ] := SuperGetMv( "MV_CENT" )
		jStorage[ "currencyFormat" ] := getValFmt()
		jStorage[ "dateFormat" ] := getDateFmt()
		jStorage[ "isCentral" ] := .T.
		jStorage[ "contextType" ] := 4	// Define o contexto do chat do DTA, onde: 0=Protheus Insights,1=RH,2=Fiscal,3=Varejo e 4=Faturamento
		jStorage[ "enableDTA" ] := PINSA030DTA()
		jStorage[ "moduleAccess" ] := cModulo
		jStorage[ "env2510" ] := GetRPORelease() >= "12.1.2510"

		jStorage[ "permissions" ] := JsonObject():new()
		jStorage[ "permissions" ][ "salesOpportunities" ]	:= MPUserHasAccess( "MATA410", 3 /*nOpc*/, __cUserID )
		jStorage[ "permissions" ][ "stockOut" ] 		  	:= MPUserHasAccess( "MATA010", 2 /*nOpc*/, __cUserID )
		jStorage[ "permissions" ][ "demands" ] 		  		:= MPUserHasAccess( "MATA110", 2 /*nOpc*/, __cUserID )
		jStorage[ "permissions" ][ "cashProjections" ] 	  	:= MPUserHasAccess( "FINA710", 2 /*nOpc*/, __cUserID )
		jStorage[ "permissions" ][ "administrator" ] 	  	:= FwIsAdmin()

		// propriedades de pre-load do insight financeiro
		FinPermInsight(@jStorage,__cSessionID)

		jStorage[ "activation" ] := JsonObject():new()
		jStorage[ "activation" ][ "disableTitle" ] 	 	:= STR0029	// "Ativação do Protheus Insights"
		jStorage[ "activation" ][ "disableProblem" ] 	:= STR0030	// "Você ainda não configurou o Protheus Insights. Se deseja utilizar todo o potencial da inteligência artificial em sua análise de dados para melhores tomadas de decisão no seu negócio, solicite a ativação agora mesmo."
		jStorage[ "activation" ][ "disableSolution" ]	:= ""
		jStorage[ "activation" ][ "disableReason" ]  	:= STR0029	// "Ativação do Protheus Insights"
		jStorage[ "activation" ][ "disableLink" ] 		:= "https://tdn.totvs.com/pages/releaseview.action?pageId=849098819"
		jStorage[ "activation" ][ "showInformation" ]  	:= LoadActvProfile()

		oWebChannel:AdvPLToJS( 'setStorage', jStorage:toJSON() )
      	/*
			if __lIACTB
				SendMetricFin({"INSIGHT_ACCESS_CTBA940",__cSessionID})
			EndIf
     	*/

	Case cType == "ActivationProcess"

		jActivation:FromJson( cContent )
		If jActivation:HasProperty( "deactivate" ) .And. jActivation[ "deactivate" ]
			lShowInfo := jActivation[ "deactivate" ]
		EndIf

		If jActivation:HasProperty( "activate" ) .And. jActivation[ "activate" ]
			lShowInfo := jActivation[ "activate" ]
			grvMetrActv()
		EndIf

		SaveActvProfile( lShowInfo )

		FreeObj( jActivation )

	Case cType == "SelectedFeature"

		cInsightName := Alltrim( cContent )

		If Len( __aTempTables ) > 0
			nSelectedFeature := aScan( __aTempTables, {|x| x[1] == cInsightName } )
			If nSelectedFeature > 0
				oFeatureTempTable := __aTempTables[ nSelectedFeature ][ 2 ]    // Referencia do objeto da tebela temporaria ja criada
			EndIf
		EndIf

		If oFeatureTempTable == Nil

			If totvs.protheus.backoffice.ba.insights.util.validDictionary()			// valida se último pacote de dicionário aplicado

				If cInsightName == "sales_recommendation"

					cModule		:= "FAT"
					cMetricName := "SALES"
					cMetricType	:= "INSIGHT_SALES_DEMO_OPEN"
					cQryBranch	:= totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, {'SA1', 'SB1'} )

				ElseIf cInsightName == "stock_out"

					cModule		:= "EST"
					cMetricName := "STOCK"
					cMetricType	:= "INSIGHT_STOCK_DEMO_OPEN"
					cQryBranch	:= totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SD1', 'SD2', 'SD3' } )

				ElseIf cInsightName == "demand_forecast"

					cModule		:= "COM"
					cMetricName := "PURCHASE"
					cMetricType	:= "INSIGHT_PURCHASE_DEMO_OPEN"
					cQryBranch	:= totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SD1', 'SD2', 'SD3' } )

				EndIf

				aFields			  := pinsFieldsStruct( cInsightName )
				oFeatureTempTable := totvs.protheus.backoffice.ba.insights.util.createTempTable( cInsightName, cModule, aFields, cQryBranch )
				aUseMock		  := totvs.protheus.backoffice.ba.insights.util.validUseMock( oFeatureTempTable, cInsightName, cModule, aFields )

				If aUseMock[1]

					If cInsightName == "sales_recommendation"

						// Valida se tabela temporaria do modo demo do sales possui registros,
						// é necessário possuir registros de pedidos de vendas na base do cliente
						If PINSRegCnt( oFeatureTempTable:getRealName() ) == 0
							aUseMock[2] := STR0028	// "Não foi possível iniciar o modo demonstração. Para utilizá-lo, é necessário ter pedidos de venda cadastrados para esta filial."
							aUseMock[3] := .T. 		// iaNoContent
						Else
							// valida se existem registros antigos na I21 de sales
							If SeekI21Old( cInsightName, cModule, cQryBranch )
								aUseMock[2] := STR0027 // "Foram encontrados insights para as filiais acessíveis para este usuário, porém os dados estão desatualizados. Por favor, aguarde a atualização dos dados ou entre em contato com o administrador do sistema."
							Endif					
						EndIf

					EndIf

					grvMetrDemo( cMetricName, __cSessionID, cMetricType, "CPI" )

				EndIf
							
				aAdd( __aTempTables, { cInsightName, oFeatureTempTable } )

			Else

				SetMessage( "SPI", cInsightName, @jResponse, @jDisable, @oWebChannel )	// sem protheus insight

			EndIf

		EndIf

		If oFeatureTempTable != Nil
			jResponse[ "iaIsMock" ]      := aUseMock[1]
			jResponse[ "featureName" ] 	 := cInsightName
			jResponse[ "tempTableName" ] := oFeatureTempTable:getRealName()
			jResponse[ "iaMockMessage" ] := aUseMock[2]
			jResponse[ "iaNoContent" ]   := aUseMock[3]

			oWebChannel:AdvPLToJS( 'SelectedFeatureResponse', jResponse:toJSON() )
		EndIf

	Case cType == "CreateSalesOrder"

		jSalesOrderData:FromJson( cContent )

		jSalesOrderResponse := PINSA040( jSalesOrderData[ "tabTmpName" ], jSalesOrderData[ "orderItens" ], jSalesOrderData[ "comment" ] , ,jSalesOrderData[ "isMock" ] )
		
		oWebChannel:AdvPLToJS( 'CreateSalesOrderResponse', jSalesOrderResponse:toJSON() )

	Case cType == "DtaFlowRequest"
		If !Empty(cContent)

			jDTAFlowReq:FromJson( cContent )

			aadd( aParamDTAReq, jDTAFlowReq[ 'userId' ] )						// userId
			aadd( aParamDTAReq, jDTAFlowReq[ 'sessionId' ] )					// sessionId
			aadd( aParamDTAReq, jDTAFlowReq[ 'type' ] )							// type
			aadd( aParamDTAReq, jDTAFlowReq[ 'appCode' ] )						// appCode
			aadd( aParamDTAReq, __cTenantID )									// tenantId
			aadd( aParamDTAReq, jDTAFlowReq[ 'correlationId' ] )				// correlationId
			aadd( aParamDTAReq, jDTAFlowReq[ 'content' ] )						// content
			aadd( aParamDTAReq, cValToChar( jDTAFlowReq[ 'contextType' ] ) )	// contextType

			cMessage	:= '{"message":"'+ STR0007 +'"}'	//"Não foi possível processar sua pergunta no momento. Tente novamente em instantes!"
			If dtaFlowRequest( aParamDTAReq ) .Or. lADVPRSession
				// busca mensagem gravada na I19
				cResponse := dtaFlowResponse( aParamDTAReq[ 5 ], aParamDTAReq[ 6 ] )	// tenantID e correlationID
				cResponse := EscapeJson( cResponse )

				If !Empty(cResponse) .Or. lADVPRSession
					cMessage	:= '{"message":"'+ cResponse +'"}'
				EndIf
			EndIf

			oWebChannel:AdvPLToJS( 'DtaFlowResponse', cMessage )

		EndIf

	Case cType == "StorageConfig"

		// valida se último pacote de dicionário aplicado
		If !totvs.protheus.backoffice.ba.insights.util.validDictionary()
			aMessageDisable := AlertEnvOutdated()

			jDisable[ "storageConfig" ] := .T.
			jDisable[ "disableTitle" ] := aMessageDisable[ 1 ]
			jDisable[ "disableReason" ] := aMessageDisable[ 2 ]
			jDisable[ "disableSolution" ] := aMessageDisable[ 3 ]
			jDisable[ "disableLink" ] := aMessageDisable[ 4 ]

		EndIf

		oWebChannel:AdvPLToJS( 'StorageConfigResponse', jDisable:toJSON() )

	Case cType == "InsightMetric"

		jMetric:fromJson( cContent )

		SendMetricFin( { jMetric[ "metricName" ], jMetric[ "payload" ][ "sessionId" ], jMetric[ "insightName" ] } )

	//Case cType $ "FinancialForecastRequest|FinancialForecastResponse|InsightAlerts|InsightAlertsUpdate"
		
		//IAFinancial(oWebChannel, cType, cContent, @jStorage, __cSessionID)
	Case cType == 'validApp'

		If cContent == 'FINA710'
			cMessage := '{"success":false,"message":"'+ STR0025 +'"}'	// "Novo Gestor Financeiro ainda não configurado. Por favor, solicitar ao administrador do sistema verificar a configuração do Novo Gestor Financeiro para acesso ao insight de Projeção de Caixa."

			// Verifica se o ambiente está com os campos necessário para a execução do Novo Gestor Financeiro
			If ( F710VDic() .And. F710VJob() ) .Or. lADVPRSession

				cMvTfcjobT := SuperGetMV("MV_TFCJOBT",,'')

				// Job ainda não foi executado, necessário aguardar para o uso do Novo Gestor Financeiro
				If Empty(cMvTfcjobT) .Or. lADVPRSession
					lOk := .F.
					cMessage := '{"success":false,"message":"'+ STR0026 +'"}'		// "A carga de dados não foi concluída/realizada. Por favor, solicitar ao administrador do sistema verificar a execução do Job FINA711 no módulo configurador."
				EndIf

				If lOk .Or. lADVPRSession
					cMessage := '{"success":true,"message":""}'	
				endIf
			EndIf
			
			oWebChannel:AdvPLToJS( 'FINA710Response', cMessage )
		endIf
		
	Case cType == 'openApp'
		
		if cContent == 'FINA710'
			FINA710()
		EndIf

	EndCase

	FWFreeArray( aFields )
	FWFreeArray( aUseMock )
	FWFreeArray( aParamDTAReq )
	FWFreeArray( aMessageDisable )
	FreeObj( jStorage )
	FreeObj( jDisable )
	FreeObj( jSalesOrderData )
	FreeObj( jSalesOrderResponse )
	FreeObj( jResponse )
	FreeObj( jMetric )
	FreeObj( jDTAFlowReq )
	FreeObj( oFeatureTempTable )
	FreeObj( oInsightConfig )
	FreeObj( oInsightDefinition	)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getValFmt
Função que retorna a configuração da picture de valores do sistema.

@param cADVPRLanguage, character, idioma do sistema para caso de teste.
@param cADVPRPictFormat, character, formato de valor do sistema para caso de teste

@Return cFormat, character, Retorna a picture padrão do sistema.
@author Marcia Junko
@since 21/01/2025
/*/
//--------------------------------------------------------------------
Static Function getValFmt( cADVPRLanguage, cADVPRPictFormat )
	Local cFormat As Character
	Local cLanguage As Character
	Local cPictFormat As Character

	Default cADVPRLanguage := ''
	Default cADVPRPictFormat := ''

	cLanguage := cADVPRLanguage
	If Empty( cADVPRLanguage )
		cLanguage := FwRetIdiom()
	EndIf

	cPictFormat := cADVPRPictFormat
	If Empty( cADVPRPictFormat )
		cPictFormat := GetPvProfString( GetEnvServer(), "PictFormat", "NOEXISTS", GetSrvIniName() )
	EndIf

	cFormat := "DEFAULT"

	If ( cPictFormat != "NOEXISTS" )
		If ( Upper( cPictFormat )  == "AMERICAN" )
			cFormat := "AMERICAN"
		EndIf
	Else
		If ( Upper( cLanguage ) == 'EN' )
			cFormat := "AMERICAN"
		EndIf
	EndIf
Return cFormat

//-------------------------------------------------------------------
/*/{Protheus.doc} getDateFmt
Função que retorna a configuração da picture de datas do sistema.

@param cADVPRLanguage, character, idioma do sistema para caso de teste.
@param cADVPRDateFormat, character, formato de data do sistema para caso de teste.

@Return cFormat, character, Retorna a picture padrão de datas do sistema.
@author Lucas Lima
@since 01/06/2026
/*/
//--------------------------------------------------------------------
Static Function getDateFmt( cADVPRLanguage, cADVPRDateFormat )
	Local cFormat As Character
	Local cLanguage As Character
	Local cDateFormat As Character

	Default cADVPRLanguage := ''
	Default cADVPRDateFormat := ''

	cLanguage := cADVPRLanguage
	If Empty( cADVPRLanguage )
		cLanguage := FwRetIdiom()
	EndIf

	cDateFormat := cADVPRDateFormat
	If Empty( cADVPRDateFormat )
		cDateFormat := GetPvProfString( GetEnvServer(), "DateFormat", "NOEXISTS", GetSrvIniName() )
	EndIf

	cFormat := "DEFAULT"

	If ( cDateFormat != "NOEXISTS" )
		If ( Upper( cDateFormat )  == "AMERICAN" )
			cFormat := "AMERICAN"
		EndIf
	Else
		If ( Upper( cLanguage ) == 'EN' )
			cFormat := "AMERICAN"
		EndIf
	EndIf
Return cFormat

//-------------------------------------------------------------------
/*/{Protheus.doc} EscapeJson
Função para tratar caracteres especiais na resposta do DTA.

@param cText character, mensagem recebida no DTA e gravada na I19.

@return cText, mensagem tratada sem caracteres especiais.
@author  Danilo Santos
@since   30/07/2025
/*/
//--------------------------------------------------------------------
Static Function EscapeJson(cText)
	// Escapa caracteres especiais para uso em JSON
	cText := StrTran(cText, "\", "\\")    // Primeiro: escape de barras
	cText := StrTran(cText, '"', '\"')    // Aspas duplas
	cText := StrTran(cText, CHR(13), "")  // Remove CR (opcional)
	cText := StrTran(cText, CHR(10), "\n") // Quebra de linha
Return cText

//-------------------------------------------------------------------
/*/{Protheus.doc} SeekI21Old
Função responsavel por verificar se tem algum registros antigos referente ao insight 
informado na tabela I21.

@param cInsight, character, Insight
@param cModule, character, modulo do sistema
@param cQryBranch, branchs que o usuario tem acesso

@return lHasOldRecords, logical, retorno lógico se existem registros vencidos na I21.
@author Lucas Lima
@since  20/08/2026
/*/
//--------------------------------------------------------------------
Static Function SeekI21Old( cInsight, cModule, cQryBranch )
	Local cQuery := ''
	Local cNextAlias := ''
	Local lHasOldRecords := .F.
	Local lUseBranch := .F.
	Local aFilUser := {}
	Local oQuery

	Default cInsight := ""
	Default cModule := ""
	Default cQryBranch := ""

	If ( lUseBranch := !Empty( cQryBranch ) )
		// Trata as branchs para passar o conteúdo correto no método SetIn da FWExecStatement
		cQryBranch := StrTran( cQryBranch, ", ", "," )
		cQryBranch := StrTran( cQryBranch, "'", "" )
		aFilUser := StrTokArr( cQryBranch, ',' )
	EndIf

	// Query única para obter total de registros antigos
	cQuery := " SELECT COUNT(I21_INSIGT) RECORDS FROM "+ RetSqlName("I21") +" I21 "
	cQuery += " WHERE I21.I21_FILIAL = ? "
	cQuery += " AND I21.I21_INSIGT = ? "
	cQuery += " AND I21_MODULO = ? "
	cQuery += " AND I21.D_E_L_E_T_ = ? "
	cQuery += " AND I21.I21_DTATE < ? "
	If lUseBranch
		cQuery += " AND I21.I21_BRANCH IN (?) "
	Endif

	oQuery := FWExecStatement():New( ChangeQuery( cQuery ) )
	oQuery:SetString( 1, SPACE( FWSizeFilial() ) )
	oQuery:SetString( 2, cInsight  )
	oQuery:SetString( 3, cModule )
	oQuery:SetString( 4, " " )
	oQuery:SetDate( 5, Date() )  // Para registros válidos
	If lUseBranch
		oQuery:SetIn( 6, aFilUser)
	Endif

	cNextAlias := oQuery:OpenAlias()
	If ( cNextAlias )->( !Eof() )
		If ( cNextAlias )->RECORDS > 0
			lHasOldRecords := .T.
		EndIf
	EndIf
	( cNextAlias )->( DbCloseArea() )

	FreeObj( oQuery )
Return lHasOldRecords

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RegCntI21
Função responsavel por retornar a quantidade de registro do insight informado no parametro na tabela I21.

@param cTpInsight character, insight

@return numeric , quantidade de registro do insight na tabela I21 .
@author  Danilo Santos
@since   30/07/2025
/*/
//-------------------------------------------------------------------------------------
Static Function RegCntI21(cTpInsight )
	Local oQuery	 as Object
	Local nRet := 0  as Numeric
	Local cQuery     as Character
	Local cNextAlias as Character
	Local aArea		 as Array

	aArea  := GetArea()

	//Conta a quantidade de registros por insight na tabela I21
	cQuery := " SELECT COUNT(R_E_C_N_O_) QTD_REC "
	cQuery += " FROM ? I21 "
	cQuery += " WHERE I21_INSIGT = ? "
	cQuery += " AND I21_FILIAL = ? "
	cQuery += " AND D_E_L_E_T_ = ? "

	cQuery := ChangeQuery( cQuery )
	oQuery := FWExecStatement():New( cQuery )
	oQuery:SetUnsafe( 1, RetSqlName( "I21" ) )
	oQuery:SetString( 2, Alltrim( cTpInsight ) )
	oQuery:SetString( 3, SPACE(FWSizeFilial()) )
	oQuery:SetString( 4, " " )

	cNextAlias := oQuery:OpenAlias()

	If (cNextAlias)->(!Eof())
		nRet := (cNextAlias)->QTD_REC
	EndIf

	(cNextAlias)->( DbCloseArea() )

	RestArea( aArea )

	aSize( aArea, 0 )
	aArea := NIL
	FreeObj( oQuery )

Return nRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetMessage
Monta mensagem para frontend apresentar ao usuário com restrição de ambiente e dicionário.

@param cSessionControl, character, tipo de Session: CPI e SPI
@param cContent, character, insight
@param jResponse, json, json resposta para front-end
@param jDisable, json, json de problema no ambiente
@param oWebChannel, object, canal de comunicação front/back

@author lucas.manoel
@since 09/09/2025
/*/
//-------------------------------------------------------------------------------------
Static Function SetMessage( cSessionControl, cInsightName, jResponse, jDisable, oWebChannel )
	Local aMessageDisable := {}		As Array

	If cInsightName == "demand_forecast"
		grvMetrDemo( "PURCHASE", __cSessionID, "INSIGHT_PURCHASE_DEMO_OPEN", cSessionControl )
	ElseIf cInsightName == "stock_out"
		grvMetrDemo( "STOCK", __cSessionID, "INSIGHT_STOCK_DEMO_OPEN", cSessionControl )
	ElseIf cInsightName == "sales_recommendation"
		grvMetrDemo( "SALES", __cSessionID, "INSIGHT_SALES_DEMO_OPEN", cSessionControl )
	EndIf

	jResponse[ "iaIsMock" ]      := .F.
	jResponse[ "featureName" ] 	 := cInsightName
	jResponse[ "tempTableName" ] := ''
	jResponse[ "iaMockMessage" ] := ''

	oWebChannel:AdvPLToJS( 'SelectedFeatureResponse', jResponse:toJSON() )

	aMessageDisable := AlertEnvOutdated()

	jDisable[ cInsightName ] := .T.
	jDisable[ "disableTitle" ] := aMessageDisable[ 1 ]
	jDisable[ "disableProblem" ] := aMessageDisable[ 2 ]
	jDisable[ "disableSolution" ] := aMessageDisable[ 3 ]
	jDisable[ "disableLink" ] := aMessageDisable[ 4 ]

	oWebChannel:AdvPLToJS( 'disableFeature', jDisable:toJSON() )

	FWFreeArray( aMessageDisable )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AlertEnvOutdated
Aviso de rotina desatualizada ou não configurada (opt-in).

@return Array, Retorna um array com título, problema, solução e link da documentação.

@author lucas.manoel
@since 08/09/2025
/*/
//-------------------------------------------------------------------------------------
Static Function AlertEnvOutdated()
	Local cTitle	:= STR0009			// "PROTHEUS INSIGHTS"
	Local cProblem	:= ""
	Local cSolution	:= ""
	Local cLink		:= "https://tdn.totvs.com/pages/releaseview.action?pageId=849098819"

	cProblem	:= STR0016			// "Atualize e aproveite o melhor do Protheus Insights! "
	cSolution	:= STR0023			// "Identificamos que o dicionário de dados do Protheus Insights não está atualizado. Por favor, baixe o pacote da Expedição Contínua e execute o UPDDISTR. "
	cSolution	+= STR0024			// "Acesse a documentação no botão abaixo e saiba como atualizar seu ambiente."

Return {cTitle, cProblem, cSolution, cLink}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSA030Count
Avalia a quantidade de registros na tabela I21 de um determinado insight
@param cInsight, character, tipo de insight

@return integer, Retorna a quantidade de registros

@author lucas.manoel
@since 08/09/2025
/*/
//-------------------------------------------------------------------------------------
Function PINSA030Count( cInsight )
Return RegCntI21( cInsight )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PINSA030DTA
Avalia se o cliente pode acessar o chat do DTA.

@return boolean, .T. define se o chat do DTA pode ser habilitado.
@author Marcia Junko
@since 22/12/2025
/*/
//-------------------------------------------------------------------------------------
Function PINSA030DTA()
	Local aMaxInfo := {}
	Local cAuxDate := ''
	Local cInsight := "permission_dta"
	Local nCountDays := 30	// Determina durante quantos dias o cliente poderá acessar o DTA após o recebimento da permission_dta
	Local lReturn := .F.

	aMaxInfo := totvs.protheus.backoffice.ba.insights.util.maxDTProc_I19( cInsight )
	If !Empty( aMaxInfo )
		cAuxDate := Subs( aMaxInfo[ 1 ], 1, 10 )
		cAuxDate := StrTran( cAuxDate, '-', '' )
		lReturn := ( PINSA030Count( cInsight ) > 0 ) .And. ( Stod( cAuxDate ) + nCountDays >= Date() )
	EndIf
Return lReturn

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTenantClient
Retorna o TenantID do cliente.

@return cTenant, character, TenantID do cliente.
@author Lucas Lima
@since 24/10/2025
/*/
//-------------------------------------------------------------------------------------
Static Function GetTenantClient()
	Local oSmartLink

	If __cTenantID == NIL
		oSmartLink := FwTotvsLinkClient():New()
		__cTenantID := oSmartLink:GetTenantClient()
	EndIf

	FreeObj( oSmartLink )
Return __cTenantID

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadActvProfile
Retorna a preferência do usuário para exibição da informação de ativação.
A mensagem de ativação só deve ser apresentada quando o usuário ainda não
decidiu (profile diferente de "1") e o ambiente não possuir tenant
configurado (cliente ainda não implantado).

@return lShowInformation, logical, .T. se deve exibir a informação, .F. caso contrário.
/*/
//-------------------------------------------------------------------------------------
Static Function LoadActvProfile()
	Local oProfile := FWProfile():New() As Object
	Local cShowInformation := ""
	Local lShowInformation := .T. As Logical

	oProfile:SetUser( __cUserId )
	oProfile:SetProgram( "PINSA030" )
	oProfile:SetTask( "ACTIVATION" )

	If oProfile:Exists()
		oProfile:Load()
		cShowInformation := oProfile:GetStringProfile()
	EndIf

	// não apresenta a mensagem
	// se já gravou anteriormente a opção de apresentar ou não o convite ("1")
	// ou se cliente já implantado com tenant no ambiente
	If ( cShowInformation == "1" ) .Or. !Empty( __cTenantID )
		lShowInformation := .F.
	EndIf

Return lShowInformation

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SaveActvProfile
Grava no profile do Protheus a preferência da exibição de informações.
Em ambas opções, "AGORA NÃO" e "ATIVAR" não apresentará mais o convite.

@param lShowInformation, logical, flag de exibição do conteúdo.
/*/
//-------------------------------------------------------------------------------------
Static Function SaveActvProfile( lShowInformation )
	Local oProfile := FWProfile():New() As Object
	Local cShowInformation := "0" 		As Character

	If lShowInformation
		cShowInformation := "1" 
	EndIf

	oProfile:SetUser( __cUserId )
	oProfile:SetProgram( "PINSA030" )
	oProfile:SetTask( "ACTIVATION" )
	oProfile:SetStringProfile( cShowInformation )
	oProfile:Save()
	oProfile:Destroy()

Return
