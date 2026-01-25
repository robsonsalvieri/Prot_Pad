#include 'fwlibversion.ch'
#include "protheus.ch"
#include "GRVMETRBA.CH"
#INCLUDE "InsightDefs.ch"

/*/{Protheus.doc} gravaMetrica
    Monta o paylod de metrica
    @return lResultPost
    @author valter.carvalho@totvspartners.com.br 
        https://jiraproducao.totvs.com.br/browse/DSERBA1-10922
    @since 04/01/2024
/*/
function grvMetrBA()

	local oEmp      as json
	local oFonte    as json
	local oData     as json
	local cRes      as character
	local aFil      as array
	local aFiles    as array
	local aAux      as array
	Local aNewFiles as array
	local i         as numeric
	local lRes      as logical
	local cType     as character
	Local oMetric   as json
	aFil   := fWLoadSM0( .F., .F.)
	oData  := JsonObject():new()
	cRes   := ""
	i      := 1
	cType  := "WizardMetric"	
	oData['versaoProtheus'] := GetVersao()
	oData['versaoRpo']      := GetRpoRelease()
	oData['versaoLib']      := FwLibVersion()
	oData['versaoDBAccess'] := TCVersion()
	oData['versaoSmartlink']:= FwtechfinVersion()											  
	oData['metricWizardCompanyes'] := {}
	for i:=1 to len(aFil)
		if vazio(aFil[i][17]) .or. len(Alltrim(aFil[i][18])) <> 14 .or. vazio(aFil[i][22])
			loop
		endif
		oEmp                        := JsonObject():new()
		oEmp['cnpj']                := aFil[i][18]
		oEmp['razao']               := aFil[i][17]
		oEmp['idIdentityManager']   := aFil[i][22]
		aadd(oData['metricWizardCompanyes'], oEmp)
	next
		
	oData['fonte'] := {}
	aFiles  := { "ARMZIA.PRW", "CONSUMMER_RABBIT.PRW", "DEMANDALERT.PRW", "GRVI14.PRW", "IA_DEMANDS.APP", "IA_STOCK.APP", "OPTOUT.PRW", "GRVMETRBA.PRW",;
		"MOCKINSIGHT.PRW","RUPTUREALERT.PRW", "SENDSMARTLINK.PRW", "VALIDTENANT.PRW", "WIZOPOT.PRW", "WIZSMARTBA.PRW", "PINSALERT.PRW",;
		"PINSA010.PRW","PINSA020.PRW", "PINSA030.PRW", "PINSA040.PRW", "PINSC010.PRW", "TENANTINSIGHTMESSAGEREADER.PRW", "PINSA030.APP",;   //fontes nova arquitetura
	"MATA010.PRX", "MATA030.PRX", "MATA110.PRX", "CRMA980.PRW", "FINA710.PRW", "FATXFUN.PRX", "CTBA940.PRW" }  //fontes de outros módulos
		
	aNewFiles := GetSrcArray( "backoffice.ba.insi*" )
	aEval( aNewFiles, {|x| aAdd( aFiles, x ) } )
		
	for i:=1 to len(aFiles)
		aAux := getApoInfo(aFiles[i])
		if len(aAux) > 0
			oFonte := JsonObject():new()
			oFonte['fonteNome']      := aAux[1]
			oFonte['fonteDataHora']  := dToc(aAux[4]) + ' ' + aAux[5]
			aadd(oData['fonte'], oFonte)
		endIf
	next
	//-------------------------------------------------------------------
	// Envia a versão do pacote de expedição contínua do Protheus Insights
	//-------------------------------------------------------------------
	oFonte := JsonObject():new()
	oFonte['fonteNome']      := 'INSIGHT_VERSION'
	oFonte['fonteDataHora']  := INSIGHT_VERSION
	aadd( oData['fonte'], oFonte)
	
	oMetric  := JsonObject():new()
	oMetric[ "metricType" ] := "MetricUsage"
	oMetric[ "data" ] := oData

	lRes := sndData(oMetric, cType)

	FWFreeArray( aFil )
	FWFreeArray( aFiles )
	FWFreeArray( aAux )
	FWFreeArray( aNewFiles )
	FreeObj( oEmp )
	FreeObj( oFonte )
	FreeObj( oData )
	FreeObj( oMetric )
return lRes


/*/{Protheus.doc} gravaMetrica de Demonstração
    Monta o paylod de metrica
    @return lResultPost
    @author rafael.silvestrim@totvs.com.br
        https://jiraproducao.totvs.com.br/browse/DSERBA1-11464
    @since 19/04/2024
/*/
function grvMetrDemo(module, sessionId, path, cSessionControl)
	local oEmp      as json
	local oData     as json
	local cRes      as character
	local aFil      as array 
	local i         as numeric
	local lRes      as logical
	local cType     as character
	Local oMetric   as json

	Default cSessionControl := ''

	aFil := fWLoadSM0( .F., .F.)

	oData:= JsonObject():new()
	cRes := ""
	i    := 1
	cType:= "DemoMetric"

	oData['TransactionId']  := sessionId
	oData['Module']         := module
	oData['Path']           := path
	oData['User']           := cUserName
	oData['UserId']         := __cUserID
	oData['UserEmail']      := TRIM(UsrRetMail(__cUserID))
	oData['DataEvent']      := FWTimeStamp(5)
	oData['SessionControl'] := cSessionControl
	oData['Sigamat']        := ""

	aSigaMatJson := {}
	for i:=1 to len(aFil)
		if vazio(aFil[i][17]) .or. len(Alltrim(aFil[i][18])) <> 14 .or. vazio(aFil[i][22])
			loop
		endif
		oEmp                        := JsonObject():new()
		oEmp['cnpj']                := aFil[i][18]
		oEmp['razao']               := aFil[i][17]
		oEmp['idIdentityManager']   := aFil[i][22]
		aadd(aSigaMatJson, oEmp)
	next

	for i := 1 to len(aSigaMatJson)
		oData['Sigamat'] := oData['Sigamat'] + aSigaMatJson[i]:tojson() + ", "
	next

	oMetric  := JsonObject():new()
	oMetric[ "metricType" ] := cType
	oMetric[ "data" ] := oData

	lRes := sndData(oMetric, cType)

	FWFreeArray( aFil )
	FreeObj( oEmp )
	FreeObj( oData )
	FreeObj( oMetric )
return lRes

/*/{Protheus.doc} sndData
    Envia o payload para envia para um endpoint
    @return lResultPost
    @author valter.carvalho@totvspartners.com.br 
        https://jiraproducao.totvs.com.br/browse/DSERBA1-10922
    @since 04/01/2024
/*/
static function sndData(oData, cType)
	local oRest     as object
	local aHeader   as array
	local lRes      as logical
	local cMsgRes   as character
	local cMsgErr   as character
	local cUrl as character
	local cEndPoint as character
	local lIsBlind := IsBLind()

	cUrl     := ""
	cEndPoint:= ""
	cMsgRes := ""
	cMsgErr := ""
	lRes := .F.
	aHeader := {}

	if cType == "WizardMetric"
		cEndPoint:= "/api/Metrics/WizardStarted"
		cUrl := iif( lIsBlind, "https://painel-backoffice.dev.totvs.app/provisioning" ,;
			"https://painel-backoffice.totvs.app/provisioning")
	elseif cType == "DemoMetric"
		cEndPoint:= "/api/Metrics/SendMetricUsage"
		cUrl := "https://painel-backoffice.totvs.app/datalake"
	endif

	aAdd(aHeader, "Content-Type: application/json")
	aAdd(aHeader, "x-access-token: D9A58469-7B5E-477B-83A8-B7FD463CB241")
	aAdd(aHeader, "User-Agent: Protheus " + GetBuild())

	oRest   := FwRest():New( cUrl )
	oRest:SetPath(cEndPoint)
	oRest:SetPostParams(EncodeUtf8(oData:toJson()))
	oRest:nTimeOut := 10
	lRes := oRest:Post(aHeader)

	cMsgRes := iif(lRes, STR0001, STR0002 )    //"Sucesso"###"Falha"
	cMsgErr := iif(lRes, "", oRest:getLastError() )

	FwLogMsg( "INFO",, "ProtheusInsights", "grvMetrBA", "", "",I18N( STR0003, { cMsgRes, cMsgErr } ) )   //"[Status de Envio de Metricas] : [ #1 ]. #2
	FWFreeArray( aHeader )
	FreeObj(oRest)
return lRes
