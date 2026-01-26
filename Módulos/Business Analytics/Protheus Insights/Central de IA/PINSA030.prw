#INCLUDE "TOTVS.CH"
#INCLUDE "PINSA030.CH"

Static __cSessionID := FWUUIDV4()
Static __aTempTables := {}

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

		Help(Nil, Nil, "PINSA030", "Protheus Insights", STR0019, 1	;					// "Identificamos que você está usando o Protheus Insights em ambiente de homologação e isto afeta a qualidade e atualização de novas recomendações."
			,Nil ,Nil, Nil, Nil, Nil, Nil, {STR0020 + CRLF + CRLF +	;					// "Sugerimos que leia a documentação e siga o passo a passo descrito para ter acesso a insights mais assertivos."
			I18N( STR0021, {"https://tdn.totvs.com/display/PROT/Protheus+Insights"} )})	// "Para informações acesse: #1"

		grvMetrDemo( "ENVIRONMENT", "", "INSIGHT_ENVIRONMENT_OPEN", "HPI" )	// homologação protheus insight

	EndIf

Return

/*/{Protheus.doc} JsToAdvpl
    configura o preLoad do sistema

    @param oWebChannel, object
    @param cType, character
    @param cContent, character

    @author Raphael Santana Ferreira
    @since 10/10/2024
/*/
Static Function JsToAdvpl( oWebChannel As Object, cType As Character, cContent As Character )

	Local jStorage            := JsonObject():New()   As Json
	Local jDisable            := JsonObject():New()   As Json
	Local jSalesOrderData     := JsonObject():New()   As Json
	Local jSalesOrderResponse := JsonObject():New()   As Json
	Local jResponse           := JsonObject():New()   As Json

	Local nSelectedFeature := 0    	As Numeric
	Local nTotLinha := 0			As Numeric
	Local oFeatureTempTable			As Object
	Local oInsightConfig 			As Object
	Local oInsightDefinition		As Object

	Local aFields := {} 			As Array
	Local aUseMock := {.F.,""}		As Array
	Local aAreaI19 := {}			As Array

	Local cInsightName := ""		As Character
	Local cModule := ""				As Character
	Local cQryBranch := ""			As Character
	Local cIdentifier := ""			As Character
	Local cMessage := ""			As Character
	Local cMotDisable := ""			As Character

	Local lInsightIA := .F.			As Logical
	Local lExistMock := .F.			As Logical
	Local lInsight := .F.			As Logical

	oFeatureTempTable := Nil

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
		jStorage[ "contextType" ] := 0	// Define o contexto do chat do DTA, onde: 0=Protheus Insights e 1=RH
		jStorage[ "enableDTA" ] := .F.
		jStorage[ "isUserAdmin" ] := FwIsAdmin()
		jStorage[ "moduleAccess" ] := cModulo

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

			DbSelectArea("I19")
			aAreaI19 := I19->( GetArea() )

			// valida se dicionário aplicado
			If AliasInDic("I21") .And. FieldPos( "I19_MESSID" ) > 0

				nTotLinha := RegCntI21( "Permission" )

				If nTotLinha == 0	// tem dicionário mas não possui opt-in

					SetMessage( "CPI", Alltrim( cContent ), @jResponse, @jDisable, @oWebChannel )		// com protheus insight

				Else

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
						EndIf
					EndIF

					aAdd( __aTempTables, { cContent, oFeatureTempTable } )
				EndIf
			Else

				SetMessage( "SPI", Alltrim( cContent ), @jResponse, @jDisable, @oWebChannel )	// sem protheus insight

			EndIf

			I19->( RestArea( aAreaI19 ) )
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

	Case cType == "StorageConfig"

		If !AliasInDic("I1A")
			aMessageDisable := AlertEnvOutdated( cType )

			jDisable[ "storageConfig" ] := .T.
			jDisable[ "disableTitle" ] := aMessageDisable[ 1 ]
			jDisable[ "disableReason" ] := aMessageDisable[ 2 ]
			jDisable[ "disableSolution" ] := aMessageDisable[ 3 ]
			jDisable[ "disableLink" ] := aMessageDisable[ 4 ]

		EndIf
		
		oWebChannel:AdvPLToJS( 'StorageConfigResponse', jDisable:toJSON() )

	EndCase

	FWFreeArray( aFields )
	FWFreeArray( aUseMock )
	FWFreeArray( aAreaI19 )
	FreeObj( jStorage )
	FreeObj( jSalesOrderData )
	FreeObj( jSalesOrderResponse )
	FreeObj( jResponse )
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
	oQuery:SetString( 2, cTpInsight )
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

	aMessageDisable := AlertEnvOutdated( cSessionControl )

	jDisable[ cInsightName ] := .T.
	jDisable[ "disableTitle" ] := aMessageDisable[ 1 ]
	jDisable[ "disableProblem" ] := aMessageDisable[ 2 ]
	jDisable[ "disableSolution" ] := aMessageDisable[ 3 ]
	jDisable[ "disableLink" ] := aMessageDisable[ 4 ]

	oWebChannel:AdvPLToJS( 'disableFeature', jDisable:toJSON() )

	FWFreeArray( aMessageDisable )
Return 

/*/{Protheus.doc} AlertEnvOutdated
Aviso de rotina desatualizada ou não configurada (opt-in).

@param cAlert, character, Tipo de mensagem

@author lucas.manoel
@since 08/09/2025
/*/
Static Function AlertEnvOutdated( cTypeAlert )
	Local cProblem	:= ""
	Local cSolution	:= ""
	Local cTitle	:= STR0009			// "PROTHEUS INSIGHTS"
	Local cLink		:= STR0015			// "https://tdn.totvs.com/display/PROT/Protheus+Insights"

	If cTypeAlert == "SPI"	// sem protheus insights
		cProblem	:= STR0012			// "Ative o Protheus Insights e eleve sua gestão para outro nível! "
		cSolution	:= STR0013 + ;		// "Transforme dados em decisões com o Protheus Insights, a Inteligência Artificial integrada ao ERP. "
					   STR0014			// "Simples de ativar, poderosa para o seu negócio."
	Else	// com protheus insights
		cProblem	:= STR0016			// "Atualize e aproveite o melhor do Protheus Insights! "
		cSolution	:= STR0017 + ;		// "Identificamos que o seu ambiente está com uma versão desatualizada. "
					   STR0018			// "Para garantir o pleno funcionamento e o aproveitamento dos recursos do Protheus Insights, recomendamos a atualização conforme orientações disponíveis em nossa documentação oficial."
	EndIf

Return {cTitle, cProblem, cSolution, cLink}
