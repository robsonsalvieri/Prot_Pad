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

	If totvs.protheus.backoffice.ba.insights.util.pinsCheckEnv()	// Valida ambiente Produção ou Engenharia Protheus Insights

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

	Else

		Help(Nil, Nil, "PINSA030", "Protheus Insights", STR0019, 1	;					// "Identificamos que você está usando o Protheus Insights em ambiente de homologação e isto afeta a qualidade e atualização de novas recomendações."
		,Nil ,Nil, Nil, Nil, Nil, Nil, {STR0020 + CRLF + CRLF +	;					// "Sugerimos que leia a documentação e siga o passo a passo descrito para ter acesso a insights mais assertivos."
		I18N( STR0021, {"https://tdn.totvs.com/display/PROT/Central+de+IA"} )})		// "Para mais informações acesse: #1"

		grvMetrDemo( "ENVIRONMENT", __cSessionID, "INSIGHT_ENVIRONMENT_OPEN", "HPI" )	// homologação protheus insight

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

	Local nSelectedFeature := 0    	As Numeric
	Local nTotLinha := 0			As Numeric
	Local oFeatureTempTable := Nil	As Object
	Local oInsightConfig 			As Object
	Local oInsightDefinition		As Object

	Local aFields := {} 			As Array
	Local aUseMock := {.F.,""}		As Array
	Local aParamDTAReq := {}		As Array
	Local cInsightName := ""		As Character
	Local cModule := ""				As Character
	Local cQryBranch := ""			As Character
	Local cIdentifier := ""			As Character
	Local cResponse := ""			As Character
	Local cMessage := ""			As Character
	Local cMotDisable := ""			As Character

	Local lInsightIA := .F.			As Logical
	Local lExistMock := .F.			As Logical
	Local lInsight := .F.			As Logical

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
		jStorage[ "isCentral" ] := .T.
		jStorage[ "contextType" ] := 4	// Define o contexto do chat do DTA, onde: 0=Protheus Insights,1=RH,2=Fiscal,3=Varejo e 4=Faturamento
		jStorage[ "enableDTA" ] := PINSA030DTA()
		jStorage[ "moduleAccess" ] := cModulo
		jStorage[ "env2510" ] := GetRPORelease() >= "12.1.2510"

		jStorage[ "permissions" ] := JsonObject():new()
		jStorage[ "permissions" ][ "salesOpportunities" ]	:= (cModulo=='FAT')
		jStorage[ "permissions" ][ "stockOut" ] 		  	:= (cModulo=='EST')
		jStorage[ "permissions" ][ "demands" ] 		  		:= (cModulo=='COM')
		jStorage[ "permissions" ][ "cashProjections" ] 	  	:= (cModulo=='FIN')
		jStorage[ "permissions" ][ "administrator" ] 	  	:= FwIsAdmin()

		// propriedades de pre-load do insight financeiro
		FinPermInsight(@jStorage,__cSessionID)

		oWebChannel:AdvPLToJS( 'setStorage', jStorage:toJSON() )
      	/*
			if __lIACTB
				SendMetricFin({"INSIGHT_ACCESS_CTBA940",__cSessionID})
			EndIf
     	*/
	Case cType == "SelectedFeature"

		If Len( __aTempTables ) > 0
			nSelectedFeature := aScan( __aTempTables, {|x| x[1] == cContent } )
			If nSelectedFeature > 0
				oFeatureTempTable := __aTempTables[ nSelectedFeature ][ 2 ]    // Referencia do objeto da tebela temporaria ja criada
			EndIf
		EndIf

		If oFeatureTempTable == Nil

			If totvs.protheus.backoffice.ba.insights.util.validDictionary()			// valida se último pacote de dicionário aplicado

				// Cria temp e recebe referencia do objeto
				If cContent == "salesOpportunities"
					oFeatureTempTable := PINSC010()
					nTotLinha := RegCntI21("sales_recommendation")
					If nTotLinha > 0
						cModule := "FAT"
						cQryBranch := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, {'SA1', 'SB1'} )
						lInsight := SeekI21("sales_recommendation",cModule,cQryBranch )
						If !lInsight
							lInsightIA := .T.
							cMotDisable := STR0003 //"Não foram encontrados insights para as filiais acessíveis para este usuário."
						Endif
					Else
						lInsightIA := .T.
						cMotDisable := STR0002 //"Não foi possivel gerar modelo por falta de dados."

						grvMetrDemo( "SALES", __cSessionID, "INSIGHT_SALES_DEMO_OPEN", "CPI" )
					Endif
				ElseIf Alltrim( cContent ) $ "stock_out|demand_forecast"
					cInsightName := Alltrim( cContent )
					If cInsightName == "stock_out"
						lExistMock := .T.
						cModule := "EST"
						cIdentifier := "rupture"
						cQryBranch := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SD1', 'SD2', 'SD3' } )
					ElseIf cInsightName == "demand_forecast"
						lExistMock := .T.
						cModule := "COM"
						cIdentifier := "demand"
						cQryBranch := totvs.protheus.backoffice.ba.insights.pinsBranchUser( __cUserID, { 'SD1', 'SD2', 'SD3' } )
					EndIf

					aFields	 := pinsFieldsStruct( cInsightName )
					oFeatureTempTable := totvs.protheus.backoffice.ba.insights.util.createTempTable( cInsightName, cModule, aFields, cQryBranch )

					If lExistMock
						aUseMock := totvs.protheus.backoffice.ba.insights.util.validUseMock( oFeatureTempTable, { cInsightName, cIdentifier }, cModule, aFields )

						If aUseMock[1]
							If cInsightName == "demand_forecast"
								grvMetrDemo( "PURCHASE", __cSessionID, "INSIGHT_PURCHASE_DEMO_OPEN", "CPI" )
							ElseIf cInsightName == "stock_out"
								grvMetrDemo( "STOCK", __cSessionID, "INSIGHT_STOCK_DEMO_OPEN", "CPI" )
							EndIf
						EndIf
					EndIf
				EndIF

				aAdd( __aTempTables, { cContent, oFeatureTempTable } )

			Else

				SetMessage( "SPI", Alltrim( cContent ), @jResponse, @jDisable, @oWebChannel )	// sem protheus insight

			EndIf

		EndIf

		If oFeatureTempTable != Nil
			jResponse[ "iaIsMock" ]      := aUseMock[1]
			jResponse[ "featureName" ] 	 := cContent
			jResponse[ "tempTableName" ] := oFeatureTempTable:getRealName()
			jResponse[ "iaMockMessage" ] := aUseMock[2]

			oWebChannel:AdvPLToJS( 'SelectedFeatureResponse', jResponse:toJSON() )

			If cContent == "salesOpportunities"
				jDisable[ "salesOpportunities" ] := lInsightIA		//Propriedade criada para desabilitar o insight quando nao houver dados
				jDisable[ "disableReason" ] := cMotDisable			//Propriedade criada para mensagens (Faturamento)

				oWebChannel:AdvPLToJS( 'disableFeature', jDisable:toJSON() )
			Endif
		EndIf

	Case cType == "CreateSalesOrder"

		jSalesOrderData:FromJson( cContent )

		jSalesOrderResponse := PINSA040( jSalesOrderData[ "tabTmpName" ], jSalesOrderData[ "orderItens" ], jSalesOrderData[ "comment" ] )

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

		SendMetricFin( { jMetric[ "metricName" ], jMetric[ "payload" ][ "sessionId" ] } )

	Case cType $ "FinancialForecastRequest|FinancialForecastResponse|InsightAlerts|InsightAlertsUpdate"
		
		IAFinancial(oWebChannel, cType, cContent, @jStorage, __cSessionID)

	Case cType == 'openApp'
		
		if cContent == 'FINA710'
			FINA710()
		EndIf 

	EndCase

	FWFreeArray( aFields )
	FWFreeArray( aUseMock )
	FWFreeArray( aParamDTAReq )
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
função que retorna a configuração da picture de valores do sistema.

@Return String, Retorna a picture padrão do sistema.
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

	cLanguage := Iif( Empty( cADVPRLanguage ), FwRetIdiom(), cADVPRLanguage )
	cFormat := "DEFAULT"

	cPictFormat := Iif( Empty( cADVPRPictFormat ), GetPvProfString( GetEnvServer(), "PictFormat", "NOEXISTS", GetSrvIniName() ), cADVPRPictFormat )

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
/*/{Protheus.doc} SeekI21
Função responsavel por verificar se tem algum registro referente ao insight 
informado na tabela I21.

@param cinsight character, Insight
@param cModulo character, modulo do sistema
@param cBranchUsr, branchs que o usuario tem acesso

@return boolean, Indica se existe registros de insight na tabela I21.
@author  Danilo Santos
@since   30/07/2025
/*/
//--------------------------------------------------------------------

Static Function SeekI21( cinsight, cModulo , cBranchUsr )
	Local aArea := GetArea()
	Local cQuery := ''
	Local cNextAlias := ''
	Local lHasRecords := .F.
	Local aTemp := {}
	Local aFilUser := {}
	Local nI := 0
	Local oQuery

	Default cinsight := ""
	Default cModulo := ""
	Default cBranchUsr := ""

	aTemp := StrTokArr( cBranchUsr , ',' )

	For nI := 1 To Len(aTemp)
		// Remove aspas simples e espaços extras
		aAdd(aFilUser, AllTrim(StrTran(aTemp[nI], "'", "")))
	Next

	// Verifica se tem algum dado do Sales na tabela I21 filtrado pela filial que o usuario tem acesso
	cQuery := " SELECT COUNT(I21_INSIGT) RECORD_NUMBER "
	cQuery += " FROM ? I21 "
	cQuery += " WHERE I21.I21_FILIAL = ? "
	cQuery += " AND I21.I21_INSIGT = ? "
	cQuery += " AND I21_MODULO = ? "
	cQuery += " AND I21.D_E_L_E_T_ = ? "
	If ( __cUserID <> '000000')
		cQuery += " AND I21.I21_BRANCH IN (?) "
	Endif

	cQuery := ChangeQuery( cQuery )
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName( "I21" ))
	oQuery:SetString( 2, SPACE( FWSizeFilial() ) )
	oQuery:SetString( 3, cinsight  )
	oQuery:SetString( 4, cModulo )
	oQuery:SetString( 5, " " )
	If ( __cUserID <> '000000')
		oQuery:SetIn( 6, aFilUser)
	Endif
	cNextAlias := oQuery:OpenAlias()

	If ( cNextAlias )->( !Eof() )
		lHasRecords := ( ( cNextAlias )->RECORD_NUMBER > 0 )
	EndIf
	( cNextAlias )->( DbCloseArea() )

	RestArea( aArea )

	aSize( aArea, 0 )
	aArea := NIL
	FreeObj( oQuery )
Return lHasRecords

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

	Local nRet       as Numeric
	Local cQuery     as Character
	Local cNextAlias as Character
	Local aArea		 as Array

	aArea  := GetArea()

	//Conta a quantidade de registros por insight na tabela I21
	cQuery := " SELECT COUNT(R_E_C_N_O_) QTD_REC "+;
		" FROM ?  I21 " +;
		" WHERE I21_INSIGT = ? " +;
		" AND D_E_L_E_T_ = ? "

	cQuery := ChangeQuery( cQuery )
	oQuery := FWExecStatement():New( cQuery )
	oQuery:SetUnsafe( 1, RetSqlName( "I21" ) )
	oQuery:SetString( 2, Alltrim( cTpInsight ) )
	oQuery:SetString( 3, '')

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
	ElseIf cInsightName == "salesOpportunities"
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
