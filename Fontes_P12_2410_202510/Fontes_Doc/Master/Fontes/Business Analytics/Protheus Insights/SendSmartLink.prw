#include 'PROTHEUS.CH'
#Include "FwSchedule.ch"
#include 'fwlibversion.ch'
#include 'SENDSMARTLINK.ch'

#DEFINE HISTORIC	1	// posição do array para dados históricos
#DEFINE PREDICTION	2	// posição do array para dados de predição
#DEFINE LASTUPD		3	// posição do array com o mdmLastUpdated

/*/{Protheus.doc} SendMetricFin
    Envia requisicao para geracao de Metricas
    @return Boolean
    @author Danilo Santos
    @since 11/05/2023
/*/

Function SendMetricFin(aParams as Array)
	Local oSmartLink 	    As Object
	Local lSucess      := .F.
	Local aParamMetric := {}

	Default aParams := {}

	oSmartLink := FwTotvsLinkClient():New()
	aAdd(aParamMetric,aParams[2]) //transactionID  1
	aAdd(aParamMetric, oSmartLink:GetTenantClient()) // 2
	aAdd(aParamMetric, InsightMod(cModulo)) // modulo 3
	aAdd(aParamMetric, "MetricData") //insight 4
	aAdd(aParamMetric, "") //branch 5
	aAdd(aParamMetric, "") //companyGroup 6
	aAdd(aParamMetric, "") //filter 7
	aAdd(aParamMetric, "") //dataResponse 8
	aAdd(aParamMetric, aParams[1]) //path  ->json content metricname 9
	aAdd(aParamMetric, __cUserID) //user 10
	aAdd(aParamMetric, cusername) //userId 11
	aAdd(aParamMetric, "") //dataEvent 12
	aAdd(aParamMetric, aParams[2]) //sessionControl  -> /payload sessionid 13
	aAdd(aParamMetric, "DataLakePostgres")//from 14
	aAdd(aParamMetric, "MET")//reqType 15
	aAdd(aParamMetric, TRIM(UsrRetMail(__cUserID))) //User e-mail 16

	FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0001 + aParams[1])

	cMessage := '{' +;
		'"tenantId": "'+ aParamMetric[2] + '",' +;
		'"metricType": "'+ aParamMetric[9] + '",' +;
		'"data": { ' +;
		'"transactionID": "'+ aParamMetric[1] + '",' +;
		'"tenantID": "'+ aParamMetric[2] + '",' +;
		'"modulo": "'+ aParamMetric[3] + '",' +;
		'"insight": "'+ aParamMetric[4] + '",' +;
		'"branch": "'+ aParamMetric[5] + '",' +;
		'"companyGroup": "'+ aParamMetric[6] + '",' +;
		'"filter": "'+ aParamMetric[7] + '",' +;
		'"dataResponse": "'+ aParamMetric[8] + '",' +;
		'"info": { '+;
		'"transactionID": "'+ aParamMetric[1] + '",' +;
		'"metrics": [ { ' +;
		'"transactionID": "'+ aParamMetric[1] + '",' +;
		'"module": "'+ aParamMetric[3] + '",' +;
		'"path": "'+ aParamMetric[9] + '",' +;
		'"user": "'+ aParamMetric[11] + '",' +;
		'"userId": "'+ aParamMetric[10] + '",' +;
		'"UserEmail": "'+ aParamMetric[16] + '",' +;
		'"dataEvent": "'+ aParamMetric[8] + '",' +;
		'"sessionControl": "'+ aParamMetric[13] + '"}]},'  +;
		'"cUserid": "'+ aParamMetric[10] + '",' +;
		'"cUserName": "'+ aParamMetric[11] + '",' +;
		'"UserEmail": "'+ aParamMetric[16] + '",' +;
		'"from": "'+ aParamMetric[14] + '",' +;
		'"reqType": "'+ aParamMetric[15] + '"' +;
		'}}'

	lSucess := oSmartLink:Send("MetricsInsights", cMessage)

	If lSucess
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0002 + STR0003)
	Else
		FWLogMsg("ERROR",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0002 + STR0004)
	EndIf

Return lSucess


/*/{Protheus.doc} SendForecastRequest
    Envia requisicao para geracao de relatorio de forecast
    @return Boolean
    @author brfac0037
    @since 11/05/2023
/*/

Function SendForecastRequest(params as Array,lAutomato)

	Local oSmartLink 	As Object
	Local lSucess 	    As Logical
	Local cFrequency  := ""
	Local cRetFil     := ""

	Default lAutomato := .F.

	cRetFil := FilForescat(params[4])
	FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0005 + params[1])
	cFrequency:= '{"frequency":"' + params[3] + '", "branchs": "' +  cRetFil + '",' + '"companyGroup": "'+ params[5] +'"}'

	oSmartLink := FwTotvsLinkClient():New()
	cMessage := '{' +;
		'"tenantId": "'+ params[2] + '",' +;
		'"metricType": "INSIGHT_FINA710_SEND_FORECAST",' +;
		'"data": { ' +;
		'"type": "MetricsInsights",' +;
		'"source": "painelbackoffice",' +;
		'"tenantId": "'+ params[2] + '",' +;
		'"appCode": "painelbackoffice",' +;
		'"specversion":	"1.0",' +;
		'"correlationid": "painelbackoffice",' +;
		'"time": "'+ Time() + '",' +;
		'"TransactionID": ' + '"' + params[1] + '",' +;
		'"Modulo": "Financeiro",'+;
		'"filter": ' +  cFrequency + ',' +;
		'"DataResponse": "' + FWTIMESTAMP(5) + '",' +;
		'"cUserid": ' + '"'+ __cUserID  +'",' +;
		'"cUserName": ' + '"'+ cusername +'",' +;
		'"Insight": ' + '"FinancialForecast",' +;
		'"CompanyGroup": "' + cEmpAnt + '",' +;
		'"Branch": "' + cFilAnt + '",' +;
		'"From": "Protheus"}' +;
		'}'

	If lAutomato
		lSucess := .T.
	Else
		lSucess := oSmartLink:Send("MetricsInsights", cMessage)
	Endif
	If lSucess
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0006 + STR0003)
	Else
		FWLogMsg("ERROR",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0006 + STR0004)
	EndIf

Return lSucess

/*/{Protheus.doc} AcquireForecastById
    Requisita conteudo de forecast utilizando  I14_MSSID 
    @author brfac0037
    @since 22/05/2023
/*/
Function AcquireForecastById(aGetParams As Array)

	Local cQuery 		As Character
	Local cNextAlias 	As Character
	Local cReportData	As Character
	Local jStatus := JsonObject():New()
	Local oQuery

	cMessId := aGetParams[1]
	cDelete := ' '

	cQuery := "SELECT I14_MESSID , R_E_C_N_O_ " + ;
		" FROM ?  I14 " + ;
		" WHERE  I14.I14_FILIAL = ? " +;
		" AND I14.I14_MESSID = ? " + ;
		" AND D_E_L_E_T_ = ? "

	cQuery := ChangeQuery(cQuery)
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName( "I14" ))
	oQuery:SetString( 2, SPACE( FWSizeFilial() ) )
	oQuery:SetString( 3, aGetParams[1] )
	oQuery:SetString( 4, " " )
	cNextAlias := oQuery:OpenAlias()

	cReportData := ""

	If (cNextAlias)->(!Eof())
		nRecI14 := (cNextAlias)->R_E_C_N_O_
		DbSelectArea('I14')
		DbSetOrder(1)
		dbgoto(nRecI14)
		If trim(I14->I14_CSTAT) == '1'
			jStatus['Code'] := '1'
			jStatus['Description'] := STR0013	//'Aguardando processamento da mensagem'
			cReportData := jStatus:toJson()
		Else
			cReportData := I14->I14_MSGRAW
		Endif
		I14->(dbCloseArea())
	EndIf

	(cNextAlias)->(dbCloseArea())
	FreeObj( oQuery )

Return cReportData

/*/{Protheus.doc} InsightAlertsId
    Requisita conteudo de Financial Alert utilizando o ID da requisicao
    @return Boolean
    @author Danilo Santos
    @since 22/05/2023
/*/

Function InsightAlertsId(aGetParams As Array , lCreate As Logical)

	Local cQuery 		As Character
	Local cNextAlias 	As Character
	Local cAlertFin	    As Character
	Local oQuery



	cQuery := "SELECT I14_RACTEN , I14_INSTYP , I14_REQTYP , I14.I14_DTRESP , R_E_C_N_O_  "
	cQuery += " FROM ?  I14 "
	cQuery += " WHERE "
	cQuery += " I14.I14_FILIAL = ? AND"
	cQuery += " I14.I14_RACTEN = ? AND"	// TenantRac
	cQuery += " I14_INSTYP = ? AND"
	cQuery += " I14_REQTYP = ? AND"
	cQuery += " I14.I14_DTRESP >= ? AND "
	cQuery += " I14.D_E_L_E_T_ = ? "
	cQuery += " ORDER BY R_E_C_N_O_ DESC "

	cQuery := ChangeQuery(cQuery)
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName( "I14" ))
	oQuery:SetString( 2, SPACE(TAMSX3('I14_FILIAL')[1]) )
	oQuery:SetString( 3, aGetParams[2] )
	oQuery:SetString( 4, "FinancialAlert" )
	oQuery:SetString( 5, "WAR" )
	oQuery:SetString( 6, Dtos(DATE()) )
	oQuery:SetString( 7, " " )
	cNextAlias := oQuery:OpenAlias()

	cAlertFin := ""

	If (cNextAlias)->(!Eof())
		nRecI14 := (cNextAlias)->R_E_C_N_O_

		DbSelectArea('I14')
		DbSetOrder(1)
		dbgoto(nRecI14)
		cAlertFin := I14->I14_MSGRAW
		I14->(dbCloseArea())
	EndIf

	(cNextAlias)->(dbCloseArea())
	FreeObj( oQuery )

Return cAlertFin

/*{Protheus.doc} InsightMod
    Retorna o modulo utilizado quando o alerta chega pelo consummer
    @return String
    @author DANILO SANTOS
    @since 22/05/2023
*/
Function InsightMod(cModulo)
	Local aMDInsight := {}
	Local nModulo := 0
	Local cRetModulo := ""

	Default cModulo := ""

	aadd(aMdInsight,"FIN")
	aadd(aMdInsight,"COM")
	aadd(aMdInsight,"EST")
	aadd(aMdInsight,"CTB")

	nModulo := aScan( aMdInsight,cmodulo )
	If nModulo == 1
		cRetModulo := "financeiro"
	ElseIf nModulo == 2
		cRetModulo := "compras"
	ElseIf nModulo == 3
		cRetModulo := "estoque"
//ElseIf nModulo == 4
		//cRetModulo := "contabil"
	Endif
Return cRetModulo

/*/{Protheus.doc} FilForescat
    Fun  o que retorna filial que foi selecionada na rotina para enviar ao filtro
	na mensagem postada no broker
    @return json
    @author Danilo Santos
    @since 13/07/2023
/*/
Function FilForescat(cFilFin)
	Local cRetFil := ""
	Local aFilFin := {}
	Local nFilFin := 0

	Default cFilFin := ""

	aFilFin := Strtokarr (cFilFin, ';')

	For nFilFin := 1  To Len(aFilFin)
		cRetFil += Alltrim(xFilial("FK5",aFilFin[nFilFin])) + ";"
	Next

Return cRetFil

/*/{Protheus.doc} FinPermInsight
    Fun  o que carrega que verifica se existe permiss o no tenant e
	carrega as variaveis que ser o enviadas para serem tratadas
	pelo Front End
    @return json
    @author Danilo Santos
    @since 13/07/2023
/*/
Function FinPermInsight(jStorage,cIDSession)
	Local cInsightIA												as Character
	Local cTenantClient												as Character
	Local cPermission												as Character
	Local lInsightIA												as Logical
	Local lVldExp 													as Logical
	Local oSmartLink 												as Object
	Local oPermInsight

	Default cIDSession := ""
	Default jStorage := JsonObject():New()

	If Findfunction('VldTenant') .And. Findfunction('VldTenantI14')
		oSmartLink := FwTotvsLinkClient():New()
		cTenantClient := oSmartLink:GetTenantClient()
		oPermInsight := ValidPermission():New()
		oPermInsight:ReadI14(cTenantClient)

		lVldExp := oPermInsight:VerifyPermissionInsight()
		cPermission := Iif((VldTenant(cTenantClient) .And. lVldExp) , "true", "false")

		lInsightIA := SeekI14Financial( cTenantClient )
		cInsightIA := IIf(lInsightIA,"true", "false")

		jStorage['sessionId'] := cIDSession
		jStorage['PermissionInsight'] := cPermission
		jStorage['InsightIA'] := cInsightIA
	Endif
Return jStorage


/*/{Protheus.doc} IAFinancial
    Fun  o que com as tratativas para envio de metricas, reports, alertas e updates 
    @return Boolean
    @author Danilo Santos
    @since 13/07/2023
/*/
Function IAFinancial(oWebChannel,cType,cContent,jStorage,cIDSession,lAutomato)

	Local cReportData				as Character
	Local cReportAux				as Character
	Local aParamsForecast := {}		as Array
	Local aForecastGetParams := {}	as Array
	Local aParamAlert := {}			as Array
	Local aParamMetric := {}		as Array
	Local aGrvI14 := {}				as Array
	Local aBranches := {}			as Array
	Local cCompany					as Character
	Local cInsightType				as Character
	Local oForecastParams			as Object
	Local oSmartLink				as Object
	Local oParamsMetric				as Object
	Local oResult					as Object

	Default cType := ""
	Default cContent := ""
	Default cIDSession := ""
	Default jStorage := JsonObject():New()
	Default lAutomato := .F.

	Do Case
	Case cType == "FinancialForecastRequest"
		If !Empty(cContent)
			If !FWJSonDeserialize(cContent, @oForecastParams)
				FWLogMsg("ERROR",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0007)
				Return
			EndIf

			aAdd(aForecastGetParams, oForecastParams:requestId)

			// ajusta o nome do insight buscado de acordo com a frequência definida pelo usuário.
			cInsightType := Iif( oForecastParams:period == "monthly", 'FinForecastAlertM', 'FinForecastAlertW' )
			cCompany := Subs( oForecastParams:company, 1, 2 )
			aBranches := StrTokArr( oForecastParams:branches, ';')

			If AttIsMemberOf(oForecastParams, "mock") .And. oForecastParams:mock == "True"
				oWebChannel:AdvPLToJS('FinancialForecastMock', mockInsight('financial'))
				oWebChannel:AdvPLToJS('FinancialInsightAlertsMock', mockInsight('financialAlert'))
			Else
				// Verifica se I14_MESSID ja foi requisitado
				cReportData := AcquireForecastById(aForecastGetParams)

				// Objeto de ForecastFinanceiro mais atualizado
				oResult := TreatFinForecastAlert( cCompany, aBranches, cInsightType )

				If !Empty( cReportData )
					cReportAux := oResult:toJSON()
					// Se os conteúdos forem diferentes, devolve o valor mais atual.
					If cReportAux <> cReportData
						cReportData := cReportAux
					EndIf
					oWebChannel:AdvPLToJS('FinancialForecastResponse', cReportData )
					Return
				EndIf

				If lAutomato
					aAdd(aParamsForecast, cIDSession)
					aAdd(aParamsForecast, cTenantID)
				else
					oSmartLink := FwTotvsLinkClient():New()
					aAdd(aParamsForecast, FWUUIDV4())
					aAdd(aParamsForecast, oSmartLink:GetTenantClient())
				Endif
				aAdd(aParamsForecast, oForecastParams:period)
				aAdd(aParamsForecast, oForecastParams:branches )
				aAdd(aParamsForecast, FWGrpCompany())

				// cria o registro na I14 para manter o fluxo existente.
				aadd(aGrvI14 , aParamsForecast[1])
				aadd(aGrvI14 , aParamsForecast[2])
				aadd(aGrvI14 , "Financeiro")
				aadd(aGrvI14 , "financialForecast")
				aadd(aGrvI14 , FWGrpCompany())
				aadd(aGrvI14 , FWCodFil())
				aadd(aGrvI14 , __cUserID)
				aadd(aGrvI14 , cusername)
				aadd(aGrvI14 , .F.)
				aadd(aGrvI14 , "REQ")
				aadd(aGrvI14 , "1")
				GrvI14Fin("I14",1,aGrvI14,.T., oForecastParams:requestId)	// Grava requisicao na I14

				// atualiza as informações na tabela com o json formatado conforme o modelo esperado pelo front.
				aSize( aGrvI14, 16 )
				aGrvI14[2]	:= aParamsForecast[2]
				aGrvI14[4]	:= 'financeiro'
				aGrvI14[6]	:= oResult:toJson()
				aGrvI14[16]	:= oResult[ "Code" ]
				GrvI14Fin("I14",1,aGrvI14, .F., oForecastParams:requestId)	// Atualiza requisição na I14
			EndIF

		EndIf
	Case cType == "FinancialForecastResponse"
		// cContent   o Id do relatorio (TRANID) enviado pelo front-end
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0005 + cContent)
		aAdd(aForecastGetParams, cContent)
		cReportData := AcquireForecastById(aForecastGetParams)
		If(cReportData != "")
			oWebChannel:AdvPLToJS('FinancialForecastResponse', cReportData)
		EndIf
	Case cType == "InsightAlerts"
		// cContent   o Id do relatorio (TRANID) enviado pelo front-end
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0009 + cContent)

		oSmartLink := FwTotvsLinkClient():New()
		aAdd(aParamAlert, cContent)
		aAdd(aParamAlert, oSmartLink:GetTenantClient())
		//aAdd(aParamAlert, "559e29d7-382f-4cf2-a9ef-dd7b8a44cc59")

		payload := InsightAlertsId(aParamAlert,.T.)

		// Cria payload
		oWebChannel:AdvPLToJS('FinancialInsightAlerts', payload)

	Case cType == "InsightAlertsUpdate"
		// cContent   o Id do relatorio (TRANID) enviado pelo front-end
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0010 + cContent)

		oSmartLink := FwTotvsLinkClient():New()
		aAdd(aParamAlert, cContent)
		aAdd(aParamAlert, oSmartLink:GetTenantClient()) //"559e29d7-382f-4cf2-a9ef-dd7b8a44cc59"
		ReadAlertsId(aParamAlert)
	Case cType == "InsightMetric" // ok
		//oSmartLink := FwTotvsLinkClient():New()
		If !FWJSonDeserialize(cContent, @oParamsMetric)
			FWLogMsg("ERROR",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0007)
			Return
		EndIf

		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0001 + oParamsMetric:METRICNAME)
		cIDMetric := oParamsMetric:PAYLOAD:SESSIONID
		aAdd(aParamMetric, oParamsMetric:METRICNAME)
		aAdd(aParamMetric, cIDMetric)
		If(SendMetricFin(aParamMetric))	// Envio da Metrica para Smartink
			FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0002 + STR0003)
		Else
			FWLogMsg("ERROR",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0008)
		EndIf
	EndCase

	FWFreeArray( aParamsForecast )
	FWFreeArray( aForecastGetParams )
	FWFreeArray( aParamAlert )
	FWFreeArray( aParamMetric )
	FWFreeArray( aGrvI14 )
	FWFreeArray( aBranches )
	FreeObj( oForecastParams )
	FreeObj( oSmartLink )
	FreeObj( oParamsMetric	)
	FreeObj( oResult )
Return


/*/{Protheus.doc} SendMrtTime
    Envia requisicao para geracao de Metricas 
	para medi  o do tempo
    @return Boolean
    @author Danilo Santos
    @since 26/07/2023
/*/

Function SendMrtTime (oJsonA)
	Local oSmartLink 	    As Object
	Local lSucess 			As Logical
	Local aParamMetric:= {}

	Default oJsonA    := JsonObject():new()

	lSucess := .F.
	
	oSmartLink := FwTotvsLinkClient():New()
	aAdd(aParamMetric,oJsonA["transactionid"]) //transactionID
	aAdd(aParamMetric, oSmartLink:GetTenantClient())
	aAdd(aParamMetric, oJsonA["data"]["modulo"]) // modulo
	aAdd(aParamMetric, oJsonA["data"]["insight"]) //insight
	aAdd(aParamMetric, FWCodFil()) //branch
	aAdd(aParamMetric, FWGrpCompany()) //companyGroup
	aAdd(aParamMetric, "") //filter
	aAdd(aParamMetric, FWTIMESTAMP(5)) //dataReceive
	aAdd(aParamMetric, "INSIGHT_TIME_METRIC") //path  ->json content
	aAdd(aParamMetric, "Protheus-Consummer") //user
	aAdd(aParamMetric, "") //userId
	aAdd(aParamMetric, FWTIMESTAMP(5)) //dataEvent
	aAdd(aParamMetric, "") //sessionControl  -
	aAdd(aParamMetric, "DataLakePostgres")//from
	aAdd(aParamMetric, "MET")//reqType
	
	FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0011 + "INSIGHT_TIME_METRIC " + "[" + oJsonA["transactionid"] + "]")
	cMessage := '{' +;
		'"tenantId": "'+ aParamMetric[2] + '",' +;
		'"metricType": "'+ aParamMetric[9] + '",' +;
		'"data": { ' +;
		'"transactionID": '+ aParamMetric[1] + ', ' +;
		'"tenantID": "'+ aParamMetric[2] + '",' +;
		'"modulo": "'+ aParamMetric[3] + '",' +;
		'"insight": "'+ aParamMetric[4] + '",' +;
		'"branch": "'+ aParamMetric[5] + '",' +;
		'"companyGroup": "'+ aParamMetric[6] + '",' +;
		'"filter": "'+ aParamMetric[7] + '",' +;
		'"dataResponse": "'+ aParamMetric[8] + '",' +;
		'"info": {' +;
		'"tenantID": "'+ aParamMetric[2] + '",' +;
		'"transactionID": "'+ aParamMetric[1] + '",' +;
		'"cUserName": "'+ aParamMetric[11] + '",' +;
		'"from": "'+ aParamMetric[14] + '",' +;
		'"reqType": "'+ aParamMetric[15] + '", ' +;
		'"cUserid": "'+ aParamMetric[10] + '" ' +;
		'"metrics": [ {' +;
		'"transactionID": "'+ aParamMetric[1] + '",' +;
		'"module": "'+ aParamMetric[3] + '",' +;
		'"path": "'+ aParamMetric[9] + '",' +;  //INSIGHT_TIME_METRIC
		'"user": "'+ aParamMetric[11] + '",' +;
		'"userId": "'+ aParamMetric[10] + '",' +;
		'"dataEvent": "'+ aParamMetric[8] + '",' +;
		'"sessionControl": "'+ aParamMetric[13] + '" ' +;
		'}'  +;
		']' +;
		'}}}' 

	lSucess := oSmartLink:Send("MetricsInsights", cMessage)

	If lSucess
		FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0012  + aParamMetric[1] + " - INSIGHT_TIME_METRIC "+ STR0003)
	EndIf

Return lSucess

/*/{Protheus.doc} SndMtrPerm
    Cria  o de m trica no Recebimento do Permission DSERBA1-10944
    @return Boolean
    @author valter.carvalho@totvspartners.com.br
    @since 16/01/2024
/*/
Function SndMtrPerm()
	local oSmartLink as object
	local lSucess    as logical
	local cTenantId  as Character
	local jMessage   as Json
	local jData      as json
	local jMetric    as json
	local aInfoComp  as array
	local cResultSnd as character
	Local cTypeEnv   as character
	Local cTypeDesc  as character
	Local jEnvio     as json


	aInfoComp  := GetSrvInfo()
	jMessage   := JsonObject():New()
	jdata      := JsonObject():New()
	jMetric    := JsonObject():New()
	jEnvio     := JsonObject():New()
	oSmartLink := fWTotvsLinkClient():New()
	cTenantId  := oSmartLink:GetTenantClient()
	cTypeEnv   := totvs.framework.environment.type.envAppGet( .T. )

	cTypeDesc := Iif( cTypeEnv == '1', 'PRODUCTION', iif( cTypeEnv == '2', 'TEST', iif( cTypeEnv == '3', 'DEV', 'UNDEFINED' ) ) )

	jMetric["versaoAppserver"] := GetBuild(.F.)
	jMetric["versaoDBAccess"] := TCVersion()
	jMetric["versaoLib"] := FwLibVersion()
	jMetric["versaoProtheus"] := GetVersao()
	jMetric["versaoRpo"] := GetRpoRelease()
	jMetric["processador"] := iif (len(aInfoComp) > 0, aInfoComp[7], "")
	jMetric["qtdMemoria"] := iif (len(aInfoComp) > 0, aInfoComp[4], "")
	jMetric["sistemaOperacional"] := iif (len(aInfoComp) > 0, aInfoComp[2], "")
	jMetric["tipoDatabase"] := TcGetDb()
	jMetric["ambienteCte"] := Iif( SuperGetMV( "MV_AMBCTEC", .F., 2 ) == 1, 'PRODUCTIOM', 'TEST' )
	jMetric["tipoAmbiente"] := cTypeDesc
	jMetric["nomeAmbiente"] := GetEnvServer()
	jMetric["nomeDB"] := totvs.protheus.backoffice.ba.insights.util.getDBInfo( 2 )
	jMetric['versaoSmartlink'] := FwtechfinVersion()

	jData["metric"] := jMetric

	jMessage["branch"] := cFilAnt
	jMessage["companyGroup"] := cEmpAnt
	jMessage["cUserid"] := "000000"
	jMessage["cUserName"] := "admin"
	jMessage["info"] := jData
	jMessage["dataResponse"] := ""
	jMessage["filter"] := ""
	jMessage["from"] := cTenantId
	jMessage["insight"] := "metricpermission"
	jMessage["modulo"] := ""
	jMessage["reqType"] := "MTP"
	jMessage["tenantID"] := cTenantId
	jMessage["transactionID"] := FWUUIDV4(.T.)

	jEnvio["tenantId"]   := cTenantId
	jEnvio["metricType"] := "metricpermission"
	jEnvio["data"]       := jMessage

	lSucess := oSmartLink:Send("MetricsInsights", EncodeUtf8(jEnvio:toJson()))

	cResultSnd := iif(lSucess, STR0003, STR0004)
	FWLogMsg("INFO",Nil,"ProtheusInsights","SendSmartLink",Nil,"",STR0012 + "  [onReceivePermission] " + cResultSnd )

	// envia a métrica de implantação com as informações dos fontes.
	grvMetrBA()

	freeObj(oSmartLink)
	freeObj(jMessage)
	freeObj(jdata)
	freeObj(jMetric)
	freeObj(jEnvio)

return lSucess

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SeekI14Financial
Verifica se tem algum dado do financeiro na tabela I14 para apresentar dados reais ou mockado.

@param cRacTenant, character, Indica o guid do tenant

@return boolean, Indica se existe registros de insight Financeiro na tabela I14.
@author  Marcia Junko
@since   08/10/2024
/*/
//-------------------------------------------------------------------------------------
Static Function SeekI14Financial( cRacTenant )
	Local aArea := GetArea()
	Local cQuery := ''
	Local cNextAlias := ''
	Local lHasRecords := .F.
	Local oQuery

	// Verifica se tem algum dado do financeiro na tabela I14 para apresentar dados reais ou mockado.
	cQuery := "SELECT COUNT(I14_INSTYP) RECORD_NUMBER " + ;
		" FROM ? I14 " + ;
		" WHERE I14.I14_FILIAL = ? " +;
		" AND I14.I14_RACTEN = ? " + ;
		" AND I14.I14_INSTYP IN (?) " + ;
		" AND I14.D_E_L_E_T_ = ? "

	cQuery := ChangeQuery( cQuery )
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName( "I14" ))
	oQuery:SetString( 2, SPACE( FWSizeFilial() ) )
	oQuery:SetString( 3, cRacTenant )
	oQuery:SetIn( 4, { 'FinForecastAlertM', 'FinForecastAlertW', 'FinancialAlert' } )
	oQuery:SetString( 5, " " )

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


//------------------------------------------------------------------------------
/*/{Protheus.doc} TreatFinForecastAlert
Função que monta o retorno para o front das informações do ForecastFinanceiro.

@param  cCompany, caracter, Indica o grupo de empresas da mensagem.
@param  aBranches, array, Indica as branchs para pesquisa.
@param  cInsightType, caracter, Indica o nome do insight a ser validado.

@return object, Indica o objeto com o conteúdo a ser apresentado no front.
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function TreatFinForecastAlert( cCompany, aBranches, cInsightType )
	Local aSvArea := GetArea()
	Local aData := {}
	Local cFinAlias := ""
	Local cFrequency := ""
	Local oData

	cFrequency := Iif( 'AlertM' $ cInsightType, 'm', 'w' )

	// pesquisa os alertas do mesmo messageID ( lote )
	cFinAlias := SearchMessages( 'WAR', cInsightType, cCompany, aBranches )

	// separa as informações de HISTORIC e PREDICTION
	aData := PrepareData( cFinAlias )

	// monta o objeto de retorno
	oData := JsonObject():New()
	If !Empty( aData[ PREDICTION ] )
		oData["current_expenses"] := TreatJsonInfo( cFrequency, aData, HISTORIC, 'p' )
		oData["current_revenues"] := TreatJsonInfo( cFrequency, aData, HISTORIC, 'r' )
		oData["expense"] := TreatJsonInfo( cFrequency, aData, PREDICTION, 'p' )
		oData["revenue"] := TreatJsonInfo( cFrequency, aData, PREDICTION, 'r' )
		oData["mdmLastUpdated"] := aData[ LASTUPD ]
		oData[ "Code" ] := "200"
		oData[ "branches" ] := ArrTokStr( aBranches, ',')
	Else
		If Empty( aData[ HISTORIC ] )
			cDescription := STR0015 	//"Falta de dados: Não foram encontrados dados suficientes para a previsão."
		Else
			cDescription := STR0014 	//"Falta de dados: Não foram encontrados dados suficientes de receita e despesas para a previsão."
		EndIf
		oData[ "Code" ] := "404"
		oData[ "Description" ] := cDescription
		oData[ "branches" ] := ArrTokStr( aBranches, ',')
	EndIf

	( cFinAlias )->( DbCloseArea() )

	RestArea( aSvArea )

	aSize( aSvArea, 0 )
	aSvArea := NIL

	FWFreeArray( aData )
Return oData

//------------------------------------------------------------------------------
/*/{Protheus.doc} SearchMessages
Função que retorna o alias da consulta das mensagens de um determinado insight,
à partir dos parâmetros informados.

@param  cReqType, caracter, Determina o tipo do insight.
@param  cInsightType, caracter, Indica o nome do insight a ser validado.
@param  cCompany, caracter, Indica o grupo de empresas da mensagem.
@param  aBranches, array, Indica as branchs para pesquisa.

@return caracter, Indica o Alias da consulta com as mensagens a serem processadas
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function SearchMessages( cReqType, cInsightType, cCompany, aBranches )
	Local aArea := GetArea()
	Local cQuery := ""
	Local cNextAlias := ""
	Local cRacTenant := ""
	Local cInsightDate := ""
	Local oQuery
	Local oSmartLink
	Local lUseBranch := .F.
	Local nI := 0
	Local cModeAccess := ""
	Local cBranchShared := ""
	Local aAuxBranches := {}

	oSmartLink   := FwTotvsLinkClient():New()
	cRacTenant 	 := oSmartLink:GetTenantClient()
	cInsightDate := DToS( Date() - 10 )
	lUseBranch   := !Empty( xFilial( "FK1" ) )

	// cria array auxiliar de filiais de acordo com o compartilhamento das tabelas do financeiro FK1
	If lUseBranch
		For nI := 1 To 3
			cModeAccess += FWModeAccess( "FK1", nI )
		Next nI

		If cModeAccess == "EEC" .Or. cModeAccess == "ECC"
			For nI := 1 To Len( aBranches )
				cBranchShared := xFilial( "FK1", aBranches[ nI ] )

				If AScan( aAuxBranches, cBranchShared ) == 0
					AAdd( aAuxBranches, cBranchShared )
				EndIf
			Next nI
		Else
			aAuxBranches := aBranches
		EndIf
	EndIf

	cQuery:= " SELECT R_E_C_N_O_ ID "
	cQuery+= " FROM ( "
	cQuery+= " SELECT "
	cQuery+= " ROW_NUMBER() OVER(PARTITION BY I14_BRANCH ORDER BY R_E_C_N_O_ DESC) as LINHA, "
	cQuery+= " I14_MESSID, R_E_C_N_O_, I14_BRANCH "
	cQuery+= " FROM ? I14 "
	cQuery+= " WHERE I14.I14_FILIAL = ? "
	cQuery+= " AND I14.I14_RACTEN = ? "
	cQuery+= " AND I14.I14_INSTYP = ? "
	cQuery+= " AND I14.I14_COMGRP = ? "
	cQuery+= " AND I14.I14_MODULO = ? "
	cQuery+= " AND I14.I14_MESSID <> ? "
	cQuery+= " AND I14.I14_DTRESP >= ? "
	cQuery+= " AND I14.D_E_L_E_T_ = ? "
	If lUseBranch
		cQuery+= " AND I14.I14_BRANCH IN (?) "
	EndIf
	cQuery+= " ) AUX "
	cQuery+= " WHERE LINHA = 1 "

	cQuery := ChangeQuery( cQuery )
	oQuery := FWExecStatement():New(cQuery)
	oQuery:SetUnsafe( 1, RetSqlName( "I14" ))
	oQuery:SetString( 2, SPACE( FWSizeFilial() ) )
	oQuery:SetString( 3, cRacTenant )
	oQuery:SetString( 4, cInsightType )
	oQuery:SetString( 5, cCompany )
	oQuery:SetString( 6, 'financeiro' )
	oQuery:SetString( 7, ' ' )
	oQuery:SetString( 8, cInsightDate ) // ultimos 10 dias baseado na data atual
	oQuery:SetString( 9, " " )
	If lUseBranch
		oQuery:SetIn( 10, aAuxBranches )
	EndIf

	cNextAlias := oQuery:OpenAlias()

	RestArea( aArea )

	aSize( aArea, 0 )
	aSize( aAuxBranches, 0 )
	aArea := NIL
	aAuxBranches := NIL

	FreeObj( oQuery )
	FreeObj( oSmartLink )
Return cNextAlias

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrepareData
Função responsável por preparar, agregar e separar as informações em um array 
por tipo de dado ( histórico ou predição).

@param cFinAlias, caracter, Indica o Alias da consulta com as mensagens a serem processadas

@return array, Vetor com as mensagens segregadas por tipo de dado.
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function PrepareData( cFinAlias )
	Local aArea := GetArea()
	Local aData := Array( 2 )
	Local nI := 1
	Local nArray := 0
	Local cLastUpdated := ""
	Local oJsonAux
	Local oAlert

	aData[ HISTORIC ] := {}
	aData[ PREDICTION ] := {}

	While ( cFinAlias )->( !EOF() )
		I14->( DbGoTo( ( cFinAlias )->ID ) )

		cMessageRaw := Alltrim( I14->I14_MSGRAW )

		oJsonAux := JsonObject():New()
		oJsonAux:FromJson( cMessageRaw )

		cLastUpdated := oJsonAux[ "data" ][ "mdmLastUpdated" ]

		For nI := 1 to len( oJsonAux[ "data" ][ "alerts" ] )
			oAlert := oJsonAux[ "data" ][ "alerts" ][ nI ]

			nArray := Iif( !oAlert[ "prediction" ],  HISTORIC, PREDICTION )

			Aadd( aData[ nArray ], oAlert )
		Next
		( cFinAlias )->( DBSkip() )
	End

	// força a ordenação do objeto por data de referência para facilitar os cálculos
	aSort( aData[ HISTORIC ] , , ,{|x, y| x["initial_reference_date"] < y["initial_reference_date"]})
	aSort( aData[ PREDICTION ] , , ,{|x, y| x["initial_reference_date"] < y["initial_reference_date"]})

	// agrega os valores com as mesmas referências de data, tipo de dado e tipo de movimentação
	SumValuesforType( @aData )

	// Adiciona o LastUpdate na estrutura de validação das informações.
	aAdd( aData, cLastUpdated )

	RestArea( aArea )

	aSize( aArea, 0 )
	aArea := NIL

	FreeObj( oJsonAux )
	FreeObj( oAlert )
Return aData

//------------------------------------------------------------------------------
/*/{Protheus.doc} TreatJsonInfo
Função que trata as informações e retorna o Json com as informações tratadas de 
acordo com a frequência, tipo de dado e tipo de movimentação.

@param  cFrequency, caracter, Indica a frequência da mensagem ( mensal ou semanal).
@param  aData, array, Vetor com os alertas segregados por tipo ( histórico ou predição ).
@param  nType, numeric, Indica o tipo de dado a ser trabalhado. Verifique os DEFINES declarados.
@param  cTypeAlert, caracter, Indica o tipo de movimentação ( p=expenses ( pagar ) e r=revenue ( receber ) )

@return json, Objeto json com as informações a serem paassadas para o front.
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function TreatJsonInfo( cFrequency, aData, nType, cTypeAlert )
	Local cAuxData := ''
	Local cLimitDate := ""
	Local cMapeCategory := ''
	Local cPropertieName := ''
	Local cCompetence := ''
	Local nI := 1
	Local nHistoric := Iif( nType == HISTORIC, 9, 3 ) // quantidade de meses considerados como histórico.
	Local nAccuracy := 0
	Local oJsonAux
	Local oAlert
	Local oJsonInfo

	cLimitDate := MonthSub( Date(), nHistoric )
	cLimitDate := AnoMes( cLimitDate )

	oJsonInfo := JsonObject():New()
	If nType == PREDICTION
		// adiciona as propriedades específicas para esse tipo de dado.
		oJsonInfo[ "accuracy" ] := 0
		oJsonInfo[ "mapecategory" ] := ""
		oJsonInfo[ "interval" ] := {}
		oJsonInfo[ "line" ] := {}
	EndIf

	For nI := 1 to len( aData[ nType ] )
		oAlert := aData[ nType ][ nI ]

		cAuxData := Subs( oAlert[ "initial_reference_date" ], 1, 7 )
		cAuxData := StrTran( cAuxData, '-', '' )

		If oAlert[ "accuracy" ] > nAccuracy
			nAccuracy := oAlert[ "accuracy" ]
		Endif
		cMapeCategory := oAlert[ "mapecategory" ]


		If cAuxData >= cLimitDate .And.  oAlert[ "type" ] == cTypeAlert
			iF cFrequency == 'm'
				cPropertieName := Subs( oAlert[ "initial_reference_date" ], 1, 10 )
				cCompetence := Subs( oAlert[ "initial_reference_date" ], 1, 7 )
			Else
				cPropertieName := Subs( oAlert[ "initial_reference_date" ], 1, 10 ) + '|' + Subs( oAlert[ "final_reference_date" ], 1, 10 )
				cCompetence := cPropertieName
			EndIf

			If nType == HISTORIC
				oJsonInfo[ cPropertieName ] := oAlert[ "sum_pb_value" ]
			else
				Aadd( oJsonInfo[ "interval" ], MakeIntervalJson( oAlert, cCompetence ) )
				Aadd( oJsonInfo[ "line" ], MakeLineJson( oAlert, cCompetence ) )
			EndIf
		Endif
	Next

	If nType == PREDICTION
		oJsonInfo[ "accuracy" ] := nAccuracy
		oJsonInfo[ "mapecategory" ] := cMapeCategory
	EndIf

	FreeObj( oJsonAux )
	FreeObj( oAlert )
Return oJsonInfo

//------------------------------------------------------------------------------
/*/{Protheus.doc} MakeIntervalJson
Função que gera as informações da seção Interval.

@param  oAlert, json, Indica o alerta que está sendo avaliado.
@param  cCompetence, caracter, Indica o label mês de competência.

@return json, Objeto json com as informações da seção Interval dos dados de predição.
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function MakeIntervalJson( oAlert, cCompetence )
	Local oInterval

	oInterval := JsonObject():New()
	oInterval[ "competence" ] := cCompetence
	oInterval[ "high_interval" ] := Round( oAlert[ "sum_upper_bound" ], 2 )
	oInterval[ "low_interval" ] := Round( oAlert[ "sum_lower_bound" ], 2 )
Return oInterval

//------------------------------------------------------------------------------
/*/{Protheus.doc} MakeLineJson
Função que gera as informações da seção Line.

@param  oAlert, json, Indica o alerta que está sendo avaliado.
@param  cCompetence, caracter, Indica o label mês de competência.

@return json, Objeto json com as informações da seção Line dos dados de predição.
@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function MakeLineJson( oAlert, cCompetence )
	Local oLine

	oLine := JsonObject():New()
	oLine[ "competence" ] := cCompetence
	oLine[ "value" ] := Round( oAlert[ "sum_upper_bound" ], 2 )
Return oLine

//------------------------------------------------------------------------------
/*/{Protheus.doc} SumValuesforType
Função responsável por agregar os valores com a mesma competência, tipo de dado 
e tipo de movimentação.

@param  @aData, array, Vetor com os alertas segregados por tipo ( histórico ou predição ).

@author Marcia Junko
@since  15/03/2025
/*/
//------------------------------------------------------------------------------
Static Function SumValuesforType( aData )
	Local nX := 0
	Local nI := 0
	Local nPos := 0

	For nX := 1 to len( aData )
		For nI := 1 to len( aData[ nX ] )
			// tratamento adicional para que não tente ler uma posição que não existe
			IF nI <= len( aData[ nX ] )
				// adiciona no objeto as propriedades que representam os valores de agregação.
				aData[ nX ][ nI ][ "sum_pb_value" ] := aData[ nX ][ nI ][ "pb_value" ]
				aData[ nX ][ nI ][ "sum_upper_bound" ] := aData[ nX ][ nI ][ "upper_bound" ]
				aData[ nX ][ nI ][ "sum_lower_bound" ] := aData[ nX ][ nI ][ "lower_bound" ]

				// varre o array a partir da próxima posição para validar se existem registros idênticos para que os valores sejam agregados.
				While ( nPos := Ascan( aData[ nX ], {|x| x[ "prediction" ] == aData[ nX ][ nI ][ "prediction" ] .And. ;
						x[ "type" ] == aData[ nX ][ nI ][ "type" ] .And. ;
						x[ "initial_reference_date" ] == aData[ nX ][ nI ][ "initial_reference_date" ] }, nI + 1 ) ) > 0
					// soma os valores da posição encontrada
					aData[ nX ][ nI ][ "sum_pb_value" ] += aData[ nX ][ nPos ][ "pb_value" ]
					aData[ nX ][ nI ][ "sum_upper_bound" ] += aData[ nX ][ nPos ][ "upper_bound" ]
					aData[ nX ][ nI ][ "sum_lower_bound" ] += aData[ nX ][ nPos ][ "lower_bound" ]

					// retira a posição encontrada do array para que ela não seja processada novamente
					aDel( aData[ nX ], nPos )
					aSize( aData[ nX ], Len( aData[ nX ] ) - 1 )
				End
			Endif
		Next
	Next
Return
