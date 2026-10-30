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
	oData[ 'environment' ]			 := GetEnvServer()
	oData[ 'insigthVersion' ]		 := totvs.protheus.backoffice.ba.insights.util.insightVersion()
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
	oData[ 'erpVersion' ]	  := GetRpoRelease()
	oData[ 'environment' ]	  := GetEnvServer()
	oData[ 'insigthVersion' ] := totvs.protheus.backoffice.ba.insights.util.insightVersion()
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

	// Envia a versão do pacote de expedição contínua do Backoffice unificado ao Protheus Insights
	oFont	:= JsonObject():new()
	oFont[ 'fonteNome' ]      := 'INSIGHT_VERSION'
	oFont[ 'fonteDataHora' ]  := totvs.protheus.backoffice.ba.insights.util.insightVersion()
	aadd( aReturn, oFont )

	FWFreeArray( aFiles )
	FWFreeArray( aAux )
	FWFreeArray( aNewFiles )	
	FreeObj( oFont )
Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} sndRowsMetric
Função de métrica para envio da quantidade de registros nas tabelas 
utilizadas no Protheus Insights, os envios são às segundas-feiras.

@Return lResult, logical, retorna se metrica foi enviada.

@author Lucas Lima
@since 02/07/2026
/*/
//--------------------------------------------------------------------
Function sndRowsMetric()
	Local oSmartLink as Object
    Local oData as json
    Local oTable as json
    Local oMetric as json
    Local lResult := .F. as logical
    Local nI := 0 as numeric
    Local aTables := {} as array

	oSmartLink := FwTotvsLinkClient():New()

	oData  := JsonObject():new()
	oData[ 'versaoProtheus' ]   := GetVersao()
	oData[ 'versaoRpo' ]        := GetRpoRelease()
	oData[ 'versaoLib' ]        := FwLibVersion()
	oData[ 'versaoDBAccess' ]   := TCVersion()
	oData[ 'versaoSmartlink' ]  := FwtechfinVersion()
	oData[ 'environment' ]	    := GetEnvServer()
	oData[ 'insigthVersion' ]   := totvs.protheus.backoffice.ba.insights.util.insightVersion()
	oData[ 'companyGroup' ]		:= cEmpAnt
    oData[ 'tables' ]			:= {}

    aTables := getTables()
    For nI := 1 to Len( aTables )
		oTable	:= JsonObject():new()
		oTable[ 'tableName' ] := aTables[ nI, 1]
		oTable[ 'records' ] := counterRows( aTables[ nI, 1 ], aTables[ nI, 2 ] )
		
        AAdd( oData[ 'tables' ], oTable )
	Next nI

	oMetric := JsonObject():new()
	oMetric[ "metricType" ]	   := "RowsTableMetric"
	oMetric[ "tenantId" ]	   := oSmartLink:GetTenantClient()
	oMetric[ "data" ]		   := oData
	oMetric[ "versionArch" ]   := "v1"

	lResult := sndData( oMetric )

	FWFreeArray( aTables )
	FreeObj( oData )
	FreeObj( oTable )
	FreeObj( oMetric )
	FreeObj( oSmartLink )

return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} counterRows
Conta registros na tabela recebida como parâmetro.

@param cTable, character, tabela a ser consultada.
@param cField, character, campo de data inicial.

@Return nRet, numeric, retorna quantidade de registros da tabela consultada.

@author Lucas Lima
@since 02/07/2026
/*/
//--------------------------------------------------------------------
Static function counterRows( cTable, cField ) as numeric
    Local oQuery as object    
    Local cQuery := "" as character
	Local cNextAlias := "" as character
	Local cInitDate := "" as character
    Local nRet := 0 as numeric
	Local nI := 0 as numeric

    Default cTable := ""
	Default cField := ""

	// contagem de registros sem filtro de filial
	cQuery := " SELECT COUNT(R_E_C_N_O_) QTD_REC FROM ? WHERE "
	If !Empty( cField )
		cQuery += " ? >= ? AND "
	EndIf
	cQuery += " D_E_L_E_T_ = ? "
    
	oQuery := FWExecStatement():New( ChangeQuery( cQuery ) )
	oQuery:SetUnsafe( ++nI, RetSqlName( cTable ) )	// tabela
	If !Empty( cField )
		cInitDate := Str( Year( Date() ) - 2, 4 ) + "0101"		// 01/01/ano atual menos 2 anos

		oQuery:SetUnsafe( ++nI, cField )	// campo de data inicial
		oQuery:SetString( ++nI, cInitDate )	// data inicial
	EndIf	
	oQuery:SetString( ++nI, " " )	// D_E_L_E_T_

	cNextAlias := oQuery:OpenAlias()
	If (cNextAlias)->(!Eof())
		nRet := (cNextAlias)->QTD_REC
	EndIf
	(cNextAlias)->( DbCloseArea() )

	// fecha objeto
	If oQuery <> Nil
		oQuery:Destroy()
		oQuery := NIL
	EndIf

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getTables
Tabelas consultadas para contar quantidade de registros.

@Return aTables, array, retorna tabelas que serão consultadas.
		[1] tabela 
		[2] campo de data inicial
 
@author Lucas Lima
@since 02/07/2026
/*/
//--------------------------------------------------------------------
Static function getTables()
    Local aTables := {} as array

    AAdd( aTables, { "SD1", "D1_EMISSAO" } )
    AAdd( aTables, { "SD2", "D2_EMISSAO" } )
    AAdd( aTables, { "SD3", "D3_EMISSAO" } )
    AAdd( aTables, { "FK1", "FK1_DATA" } )
    AAdd( aTables, { "FK2", "FK2_DATA" } )
    AAdd( aTables, { "FK5", "FK5_DATA" } )
    AAdd( aTables, { "FK6", "" } )
    AAdd( aTables, { "SC6", "" } )
    AAdd( aTables, { "SB1", "" } )
    AAdd( aTables, { "SB2", "" } )
    AAdd( aTables, { "SA1", "" } )

Return aTables

//------------------------------------------------------------------------------
/*/{Protheus.doc} grvMetrActv
Monta o payload de métrica de ativação (SETUP_REQUEST) do convite de implantação.

@param aADVPRInfo, array, Executado na esteira de testes.
		[01] - empresa 99

@return lRes, logical, true se a API de métricas for executada com sucesso.

@author Victor Vieira 
@since 29/06/2026
/*/
//------------------------------------------------------------------------------
function grvMetrActv( aADVPRInfo )
	local lRes := .F. as logical
	local cCGC        as character
	local cNome       as character
	local aSM0CGC     as array
	Local oMetric     as json

	Default aADVPRInfo := {}

	aSM0CGC := FWSM0Util():GetSM0Data( , , { "M0_CGC" } )
	cCGC    := AllTrim( aSM0CGC[ 1 ][ 2 ] )
	cNome   := AllTrim( FWSM0Util():getSM0FullName() )

	If ChkActvGrd( cCGC, cNome, aADVPRInfo )

		oMetric := BldActvJs( cCGC, cNome )
		lRes    := sndData( oMetric )

		FreeObj( oMetric )
		
	EndIf

	FWFreeArray( aSM0CGC )

return lRes

//------------------------------------------------------------------------------
/*/{Protheus.doc} ChkActvGrd
Valida se a métrica SETUP_REQUEST pode ser enviada para o contexto atual.

@param cCGC, character, CNPJ da empresa/filial logada.
@param cNome, character, Razão Social/Nome Comercial da empresa/filial logada.
@param aADVPRInfo, array, Executado via esteira de testes.
		[1] - empresa teste 99.
		[2] - validação a executar.

@return lOk, logical, .T. libera o envio da métrica, .F. bloqueia.

@author Lucas Manoel de Lima
@since 26/08/2026
/*/
//------------------------------------------------------------------------------
Static Function ChkActvGrd( cCGC, cNome, aADVPRInfo )
	Local lOk := .T. as Logical

	Default cCGC  := ""
	Default cNome := ""
	Default aADVPRInfo := {}

	If AllTrim( cEmpAnt ) == "99" .Or. ( !Empty( aADVPRInfo ) .And. aADVPRInfo[ 2 ] == "99" )
		lOk := .F.
		FWLogMsg( "WARN",, "ProtheusInsights", "grvMetrActv", "", "SETUP01", "Metrica SETUP_REQUEST bloqueada: empresa de teste (99)." )

	ElseIf Empty( cCGC ) .Or. Len( AllTrim( cCGC ) ) <> 14
		lOk := .F.
		FWLogMsg( "WARN",, "ProtheusInsights", "grvMetrActv", "", "SETUP02", "Metrica SETUP_REQUEST bloqueada: CNPJ da empresa vazio ou invalido." )

	ElseIf Empty( cNome )
		lOk := .F.
		FWLogMsg( "WARN",, "ProtheusInsights", "grvMetrActv", "", "SETUP03", "Metrica SETUP_REQUEST bloqueada: razao social da empresa vazia." )

	ElseIf !totvs.protheus.backoffice.ba.insights.util.pinsCheckEnv() .Or. ( !Empty( aADVPRInfo ) .And. aADVPRInfo[ 2 ] == "pinsCheckEnv" )
		lOk := .F.
		FWLogMsg( "WARN",, "ProtheusInsights", "grvMetrActv", "", "SETUP04", "Metrica SETUP_REQUEST bloqueada: ambiente nao e producao nem base congelada." )

	EndIf
Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} BldActvJs
Monta o payload da métrica SETUP_REQUEST (sem enviar).

@param cCGC, character, CNPJ da empresa/filial logada, já validado.
@param cNome, character, Razão Social/Nome Comercial, já validado.

@return oMetric, json, objeto raiz completo do payload SETUP_REQUEST v2.

@author Lucas Manoel de Lima
@since 26/08/2026
/*/
//------------------------------------------------------------------------------
Static Function BldActvJs( cCGC, cNome )
	local oActv     as json
	local oData     as json
	local oComp     as json
	local oUser     as json
	Local oMetric   as json

	If FindClass( "FWEngineeringUtils" ) .And. FWEngineeringUtils():isAlphaEnvironment()
		cNome := "[INTERNO] - " + cNome
	EndIf

	oComp := JsonObject():new()
	oComp[ 'name' ] := cNome
	oComp[ 'cnpj' ] := cCGC

	oUser := JsonObject():new()
	oUser[ 'id' ]    := __cUserId
	oUser[ 'code' ]  := cUserName
	oUser[ 'name' ]  := FwGetUserName( __cUserId )
	oUser[ 'email' ] := AllTrim( UsrRetMail( __cUserId ) )

	oActv := JsonObject():new()
	oActv[ 'loggedUser' ] := oUser
	oActv[ 'adminEmail' ] := AllTrim( UsrRetMail( "000000" ) )

	oData := JsonObject():new()
	oData[ 'environment' ]    := GetEnvServer()
	oData[ 'release' ]        := GetRpoRelease()
	oData[ 'insigthVersion' ] := totvs.protheus.backoffice.ba.insights.util.insightVersion()
	oData[ 'company' ]        := oComp
	oData[ 'activation' ]     := oActv

	oMetric := JsonObject():new()
	oMetric[ "metricType" ]	 := "SETUP_REQUEST"
	oMetric[ "data" ]		 := oData
	oMetric[ "versionArch" ] := "v2"

Return oMetric
