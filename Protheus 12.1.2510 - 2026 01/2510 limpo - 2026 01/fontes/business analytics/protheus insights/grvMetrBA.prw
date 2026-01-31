#include 'fwlibversion.ch'
#include "protheus.ch"
#include "GRVMETRBA.CH"
#INCLUDE "InsightDefs.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} grvMetrBA
Monta o paylod de metrica do SmartWizardBA.

@return lRes, logical, true se a API de métricas for executada com sucesso.

@author valter.carvalho@totvspartners.com.br
@since 04/01/2024
/*/
//------------------------------------------------------------------------------
function grvMetrBA()
	local oEmp      as json
	local oData     as json
	local aFil      as array
	local nI        as numeric
	local lRes      as logical
	local cType     as character
	Local oMetric   as json

	aFil   := fWLoadSM0( .F., .F.)
	cType  := "WizardMetric"

	oData  := JsonObject():new()
	oData[ 'versaoProtheus' ] 		 := GetVersao()
	oData[ 'versaoRpo' ]      		 := GetRpoRelease()
	oData[ 'versaoLib' ]      		 := FwLibVersion()
	oData[ 'versaoDBAccess' ] 		 := TCVersion()
	oData[ 'versaoSmartlink' ]		 := FwtechfinVersion()
	oData[ 'metricWizardCompanyes' ] := {}

	for nI := 1 to len( aFil )
		if Empty( aFil[ nI ][ 17 ] ) .or. len( Alltrim( aFil[ nI ][ 18 ] ) ) <> 14 .or. Empty( aFil[ nI ][ 22 ] )
			loop
		endif
		oEmp	:= JsonObject():new()
		oEmp[ 'cnpj' ]              := aFil[ nI ][ 18 ]
		oEmp[ 'razao' ]             := aFil[ nI ][ 17 ]
		oEmp[ 'idIdentityManager' ] := aFil[ nI ][ 22 ]
		aadd( oData[ 'metricWizardCompanyes' ], oEmp )
	next

	oData[ 'fonte' ] := PINSFontInfo( )

	oMetric := JsonObject():new()
	oMetric[ "metricType" ]	   := cType
	oMetric[ "data" ]		   := oData
	oMetric[ "versionArch" ]   := "v2"

	lRes := sndData( oMetric )

	FWFreeArray( aFil )
	FreeObj( oEmp )
	FreeObj( oData )
	FreeObj( oMetric )
return lRes

//------------------------------------------------------------------------------
/*/{Protheus.doc} grvMetrDemo
Monta o paylod de metrica do modo Demo dos Insights.

@param module, character, tipo de insight enviando a métrica.
@param sessionId, character, sessão atual do usuário logado.
@param path, character, identificador da métrica.
@param cSessionControl, character, identificador da mensagem apresentada ao usuário de restrição de acesso.

@return lRes, logical, true se a API de métricas for executada com sucesso.

@author rafael.silvestrim@totvs.com.br
@since 19/04/2024
/*/
//------------------------------------------------------------------------------
function grvMetrDemo(module, sessionId, path, cSessionControl)
	local oEmp      	as json
	local oData     	as json
	Local oMetric   	as json
	local aFil      	as array
	local aSigaMatJson	as array
	local nI			as numeric
	local lRes      	as logical
	local cType			as character

	Default cSessionControl := ''

	aFil	:= fWLoadSM0( .F., .F.)
	cType	:= "DemoMetric"

	oData	:= JsonObject():new()
	oData[ 'TransactionId' ]  := sessionId
	oData[ 'Module' ]         := module
	oData[ 'Path' ]           := path
	oData[ 'User' ]           := cUserName
	oData[ 'UserId' ]         := __cUserID
	oData[ 'UserEmail' ]      := TRIM( UsrRetMail( __cUserID ) )
	oData[ 'DataEvent' ]      := FWTimeStamp( 5 )
	oData[ 'SessionControl' ] := cSessionControl
	oData[ 'Sigamat' ]        := ""

	aSigaMatJson := {}
	for nI := 1 to len( aFil )
		if Empty( aFil[ nI ][ 17 ] ) .or. len( Alltrim( aFil[ nI ][ 18 ] ) ) <> 14 .or. Empty( aFil[ nI ][ 22 ] )
			loop
		endif
		oEmp	:= JsonObject():new()
		oEmp[ 'cnpj' ]              := aFil[ nI ][ 18 ]
		oEmp[ 'razao' ]             := aFil[ nI ][ 17 ]
		oEmp[ 'idIdentityManager' ]	:= aFil[ nI ][ 22 ]
		aadd( aSigaMatJson, oEmp )
	next

	for nI := 1 to Len( aSigaMatJson )
		oData[ 'Sigamat' ] := oData[ 'Sigamat' ] + aSigaMatJson[ nI ]:tojson() + ", "
	next

	oMetric := JsonObject():new()
	oMetric[ "metricType" ]		:= cType
	oMetric[ "data" ]			:= oData
	oMetric[ "transactionId" ]	:= sessionId
	oMetric[ "versionArch" ]	:= "v2"

	lRes := sndData( oMetric )

	FWFreeArray( aFil )
	FWFreeArray( aSigaMatJson )
	FreeObj( oEmp )
	FreeObj( oData )
	FreeObj( oMetric )
return lRes

//------------------------------------------------------------------------------
/*/{Protheus.doc} sndData
Envia o post no endpoint de Metricas do Insights.

@param oData, object, Payload a ser enviado como parametro no POST da API de métricas.
@param aHeader, array, Utilizado no ADVPR para forçar erro de cabeçalho na API de métricas.
@param lADVPR, logical, Utilizado no ADVPR para forçar token inválido.

@return lRes, logical, true se o POST for realizado com sucesso.

@author valter.carvalho@totvspartners.com.br
@since 04/01/2024
/*/
//------------------------------------------------------------------------------
static function sndData(oData, aHeader, lADVPR)
	local oRest     := nil	as object
	local lRes      := .F.  as logical
	local cMsgRes   := ""	as character
	local cMsgErr   := ""	as character
	local cUrl      := ""	as character
	local cEndPoint := ""	as character
    local cToken    := ""	as character

	Default aHeader	:= {}
	Default lADVPR	:= .F.

    cToken    := GetTokenMetricBA( lADVPR )

	If !Empty( cToken )
		cUrl	  := "https://painel-backoffice.totvs.app"
		cEndPoint := "/protheusinsightsmetrics/api/v1/metrics"

		If Empty( aHeader )
			aAdd( aHeader, "Content-Type: application/json" )
			AAdd( aHeader, "Charset: UTF-8" )
			aAdd( aHeader, "User-Agent: Protheus " + GetBuild() )
			AAdd( aHeader, "Authorization: Bearer " + cToken )
		EndIf

		oRest   := FwRest():New( cUrl )
		oRest:SetPath( cEndPoint )
		oRest:SetPostParams( EncodeUtf8( oData:toJson() ) )
		oRest:nTimeOut := 10

		lRes	:= oRest:Post( aHeader )

		If lRes
			cMsgRes := STR0001    //"Sucesso"
		Else
			cMsgErr := oRest:getLastError()
			cMsgRes := STR0002   //"Falha"
		EndIf
	Else
		cMsgErr := STR0004  	//"Falha ao obter token de acesso API metricas."
		cMsgRes := STR0002  	//"Falha"
	EndIf

	FwLogMsg( "INFO",, "ProtheusInsights", "grvMetrBA", "", "",I18N( STR0003, { cMsgRes, cMsgErr } ) )   //"[Status de Envio de Metricas] : [ #1 ]. #2
	FWFreeArray( aHeader )
	FreeObj( oRest )
return lRes
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetTokenMetricBA
Busca Token para acesso ao serviço de métricas insights.

@param lADVPR, logical, Utilizado no ADVPR para forçar token inválido.

@return cToken, character, retorna o token de acesso a API.

@author Lucas Lima
@since  03/10/2025
/*/
//------------------------------------------------------------------------------
Static Function GetTokenMetricBA( lADVPR )
    Local cToken	:= ""	as Character
    Local cUrl		:= ""	as Character
    Local cEndPoint := ""	as Character
	local oRest     := nil	as object
    Local oJson     := nil	as object
	Local aHeader   := {}	as Array

	If !lADVPR
		cUrl := "https://painel-backoffice.totvs.app"
		cEndPoint := "/protheusinsightservices/api/v1/insights/generateTokenService"
		cEndPoint += "?user=protheus.metrics"
		cEndPoint += "&password=9ho6)zmV"

		AAdd( aHeader, "Content-Type: application/x-www-form-urlencoded")
		AAdd( aHeader, "Charset: UTF-8")
		AAdd( aHeader, "User-Agent: Protheus " + GetBuild() )

		oRest := FwRest():New( cUrl )
		oRest:SetPath( cEndPoint )
		oRest:SetPostParams( "" )
		oRest:nTimeOut := 10

		If oRest:Post( aHeader )
			oJson	:= JsonObject():New()
			oJson:FromJson( oRest:cResult )

			If oJson:HasProperty( "access_token" )
				cToken := oJson[ "access_token" ]
			EndIf
		EndIf
	EndIf

	FWFreeArray( aHeader )
    FreeObj( oRest )
    FreeObj( oJson )
Return cToken


//------------------------------------------------------------------------------
/*/{Protheus.doc} PINSFontInfo
Monta a lista de fontes e versões que fazem parte do Protheus Insights.

@return array, lista com os fontes
@author Marcia Junko
@since  26/12/2025
/*/
//------------------------------------------------------------------------------
Function PINSFontInfo( )
	Local aReturn := {}
	Local aFiles := {}
	Local aAux   := {}
	Local aNewFiles := {}
	Local nI := 0
	Local oFont

	aFiles  := {"ARMZIA.PRW", "CONSUMMER_RABBIT.PRW", "DEMANDALERT.PRW", "GRVI14.PRW", "IA_DEMANDS.APP", "IA_STOCK.APP", "OPTOUT.PRW", "GRVMETRBA.PRW",;
				"MOCKINSIGHT.PRW","RUPTUREALERT.PRW", "SENDSMARTLINK.PRW", "VALIDTENANT.PRW", "WIZOPOT.PRW", "WIZSMARTBA.PRW", "PINSALERT.PRW",;
				"PINSA010.PRW","PINSA020.PRW", "PINSA030.PRW", "PINSA040.PRW", "PINSC010.PRW", "TENANTINSIGHTMESSAGEREADER.PRW", "PINSA030.APP", "PINSA050.TLPP",;   //fontes nova arquitetura
				"MATA010.PRX", "MATA030.PRX", "MATA110.PRX", "CRMA980.PRW", "FINA710.PRW", "FATXFUN.PRX", "CTBA940.PRW" }  //fontes de outros módulos

	aNewFiles := GetSrcArray( "backoffice.ba.insi*" )
	aEval( aNewFiles, {|x| aAdd( aFiles, x ) } )

	aNewFiles := GetSrcArray( "backoffice.ba.dta*" )
	aEval( aNewFiles, {|x| aAdd( aFiles, x ) } )

	for nI := 1 to Len( aFiles )
		aAux := getApoInfo( aFiles[ nI ] )
		if Len( aAux ) > 0
			oFont	:= JsonObject():new()
			oFont[ 'fonteNome' ]      := aAux[ 1 ]
			oFont[ 'fonteDataHora' ]  := dToc( aAux[ 4 ] ) +' '+ aAux[ 5 ]
			aadd( aReturn, oFont )
		endIf
	next

	// Envia a versão do pacote de expedição contínua do Protheus Insights
	oFont	:= JsonObject():new()
	oFont[ 'fonteNome' ]      := 'INSIGHT_VERSION'
	oFont[ 'fonteDataHora' ]  := INSIGHT_VERSION
	aadd( aReturn, oFont )

	FWFreeArray( aFiles )
	FWFreeArray( aAux )
	FWFreeArray( aNewFiles )	
	FreeObj( oFont )
Return aReturn

