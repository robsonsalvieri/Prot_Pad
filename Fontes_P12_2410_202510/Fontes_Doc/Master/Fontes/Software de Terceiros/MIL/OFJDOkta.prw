
#include "Totvs.ch"
#include "ofjdokta.CH"

#define PROF_TIMETOKEN   1
#define PROF_EXPIREIN    2
#define PROF_ACCESSTOKEN 3
#define PROF_IDTOKEN     4
#define PROF_REFRESHTOKEN     5
#define PROF_DATETOKEN   6
   
#define SRVC_PMLINK  1
#define SRVC_ORDERSTATUS 2 
#define SRVC_JDQUOTE_MAINTAINQUOTE 3 
#define SRVC_JDQUOTE_PODATA 4
#define SRVC_WARRANTY 5
#define SRVC_NFCOMPRA 6
#define SRVC_DTFGETAPI 7
#define SRVC_DTFPUTAPI 8
#define SRVC_CIFT 9

/*/{Protheus.doc} OFJDOkta
	Classe de controle do Okta
	
	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Class OFJDOkta from LongNameClass

	Data oProfile as OBJECT

	Data cLastState as String
	Data loAuth2 as Logical

	Data _profProg as String
	Data _profTask as String
	Data _profType as String

	Data _AccessToken as String
	Data _DateCreate as String // Data no Formato YYYYMMDD
	Data _TimeCreate as String
	Data _ExpiresInSeconds as Number
	Data _RefreshToken as String
	Data _IDToken as String

	Data _sessionToken
	Data _codeAuthn
	Data _scope
	Data _scopeParam

	Data _userName as String
	Data _userPasswd as String
	Data _cURL as String
	Data _cRedirect_URI as String
	Data _client_ID as String
	Data _client_Secret as String
	Data _urlAuthN as String
	Data _cAuthServer as String

	Data _auxProfile

	Data _service as Number

	Data oJsonResult as Object
	Data oXMLManager as Object
	Data oRest as OBJECT

	Data oConfig as OBJECT

	Data oLogger as OBJECT
	Data oJdConfig as OBJECT

	Method NEW() Constructor
	Method DESTROY()

	Method GetAuthUrl()



	Method isProperlyConfigured()

	Method getToken()
	Method setToken()
	Method RefreshTheToken()
	Method anyValidToken()
	Method UseLastToken()
	Method oauth2Habilitado()
	Method GetAuth()

	Method GetLastStatus()
	Method cleanProfile()

	Method SetUserPasswd()

	Method SetPMLinkJDPoint()
	Method SetOrderStatusJDPoint()
	Method SetMaintainQuoteJDQuote()
	Method SetPODataJDQuote()
	Method SetWarranty()
	Method SetNFCompra()
	Method SetDTFGETAPI()
	Method SetDTFPUTAPI()
	Method SetCIFT()

	Method IsPMLinkJDPoint()
	Method IsOrderStatusJDPoint()
	Method IsMaintainQuoteJDQuote()
	Method IsPODataJDQuote()
	Method IsWarranty()
	Method IsNFCompra()
	Method IsDTFGETAPI()
	Method IsDTFPUTAPI()
	Method IsCIFT()

	Method _loadProfile()
	Method _saveProfile()

	Method _getNewToken()
	Method _getSessionToken()
	Method _getCode()
	Method _getAccessToken()

	Method _getDTFAccessToken()

	Method _getTokenRefresh()

	Method _postToken()

	Method _POSTTOKENDTF()

	Method _setTask()

	Method _getError()

EndClass

Method New() Class OFJDOkta

	Private lSchedule := FWGetRunSchedule()

	self:_AccessToken := ""
	self:_DateCreate := ""
	self:_TimeCreate := ""
	self:_ExpiresInSeconds := 0
	self:_RefreshToken := ""
	self:_IDToken := ""

	self:_profProg := "OFJDOKTA"
	self:_profType := ""

	self:_auxProfile := Array(5)
	
	self:_scope := ""
	self:_scopeParam := ""
	
	self:_userName := ""
	self:_userPasswd := ""
	self:loAuth2 := .T.

	self:oLogger   := DMS_Logger():New("OFJDOkta_"+dtos(ddatabase)+".log")
	self:oJdConfig := OFJDConfig():New()

	self:oJsonResult := JsonObject():New()
	self:oXMLManager := TXMLManager():New()

	self:oRest := FWRest():New(self:_cURL)

	self:oProfile := FWProfile():New()

	self:oConfig := OFJDOktaConfig():New()
	self:oConfig:getConfig()

	self:loAuth2 := self:oConfig:oauth2Habilitado()

	self:_cRedirect_URI := self:oConfig:getRedirURI()
	If .f.
		fsConout("")
	EndIf

Return SELF

/*/{Protheus.doc} GetLastStatus
	Retorna ultimo status gerado para login

	@type method
	@author Vinicius Gati
	@since 27/01/2025
/*/
Method GetLastStatus() Class OFJDOkta
Return self:cLastState

/*/{Protheus.doc} GetAuthUrl
	Retorna a URL de autenticação do OKTA

	@type method
	@author Vinicius Gati
	@since 27/01/2025
/*/
Method GetAuthUrl() Class OFJDOkta
	local cUrl := ""

	self:cLastState := FwUUIDV4(.t.) // codigo aleatorio pra identificar token recebido e direcionar corretamente

	oAuth2 := OFOAUTH2():New()
	oAuth2:AddQueue(__cUserId, self:cLastState, self:_service, self:_client_ID)

	cUrl := self:_cURL + '/oauth2/'+ self:_cAuthServer +'/v1/authorize' + "?"
	cUrl += "client_id=" + alltrim(cValToChar(self:_client_ID)) + "&"
	cUrl += "redirect_uri=" + alltrim(cValToChar(self:_cRedirect_URI)) + "&"
	cUrl += "response_type=code&"
	cUrl += "state=State " + self:cLastState + "&"
	cUrl += "scope=" + alltrim(cValToChar(self:_scope))
Return cUrl

/*/{Protheus.doc} anyValidToken
	Verifica se existe token valido para o serviço e o usuário

	@type method
	@author Vinicius Gati
	@since 07/04/2025
/*/
Method anyValidToken() Class OFJDOkta
	oAuth2 := OFOAUTH2():New()
Return oAuth2:AnyValidToken(__cUserId, self:_service, self:_client_ID)

/*/{Protheus.doc} GetAuth
	Busca ultimo auth feito se ainda estiver valido OU abre ofia510 para logar

	@type method
	@author Vinicius Gati
	@since 14/04/2025
/*/
Method GetAuth() Class OFJDOkta
	Local oEmail
	if self:AnyValidToken()
		self:UseLastToken()
	elseif ! FWGetRunSchedule()
		return OFIA510(self)
	else
		oRpm := OFJDRpmConfig():New()
		oEmail := DMS_EmailHelper():New()
		oEmail:SendTemplate({;
			{'template'           , 'mil_sys_err' },;
			{'origem'             , oRpm:EmailOrigem() },;
			{'destino'            , oRpm:EmailsDestino() },;
			{'assunto'            , "[OKTA] " + STR0017 + dtoc(DATE()) + " " + TIME() + chr(13) + chr(10) + " client_id: " + self:_client_ID },; // "Token expirado detectado"
			{':titulo'            , "[OKTA] " + STR0017 + dtoc(DATE()) + " " + TIME() },;
			{':cabecalho1'        , STR0018 },; // "Não foi possível autenticar no okta usando token existente"
			{':dados_cabecalho1'  , STR0019 } ; // "Por favor, renove os tokens do okta para usuário do scheduler no programa OFIA280"
		})
	endif
Return self

/*/{Protheus.doc} UseLastToken
	Busca e utiliza o ultimo token ainda valido

	@type method
	@author Vinicius Gati
	@since 08/04/2025
/*/
Method UseLastToken() Class OFJDOkta
	oAuth2 := OFOAUTH2():New()
	jTokenData := oAuth2:GetValidToken(__cUserId, self:_service, self:_client_ID)
	if ValType(jTokenData) == "U"
		return .f.
	endif
	self:_AccessToken := ""
	self:_RefreshToken := jTokenData["REFRESH"]
	if empty(self:_RefreshToken) .or. upper(self:_RefreshToken) == "NULL"
		self:_codeAuthn := jTokenData["CODE"]
		self:_getAccessToken()
	endif
	lRefreshOk := self:_getTokenRefresh()
	if ! lRefreshOk
		oAuth2:RemoveExpRefreshToken(self:_service, jTokenData["REFRESH"])
	endif
Return lRefreshOk

/*/{Protheus.doc} setToken
	Seta o token internamente

	@type method
	@author Vinicius Gati
	@since 29/01/2025
/*/
Method setToken(cToken) Class OFJDOkta
	self:_codeAuthn := alltrim(cToken)
	self:_getAccessToken()
Return self

/*/{Protheus.doc} isProperlyConfigured
	Verifica a configuração está minimamente viável	

	@type method
	@author Vinicius Gati
	@since 18/11/2024
/*/
Method isProperlyConfigured() Class OFJDOkta
return self:oConfig:isProperlyConfigured()

/*/{Protheus.doc} oauth2Habilitado
	Retorna se o oauth2 está habilitado na configuração do okta ofia280

	@type method
	@author Vinicius Gati
	@since 11/04/2025
/*/
Method oauth2Habilitado() Class OFJDOkta
Return self:loAuth2

Method DESTROY() Class OFJDOkta

	fwFreeObj(@self:oJsonResult)
	fwFreeObj(@self:oXMLManager)
	fwFreeObj(@self:oRest)

	aSize(self:_auxProfile,0)

Return

Method _loadProfile() Class OFJDOkta

	Local useProfile := .t.
	Local cElapTime := 0
	Local nTotSec := 0

	if ! self:isProperlyConfigured()
		return
	endif

	if empty(self:_profProg) .or. empty(self:_profTask) .or. empty(self:_profType)
		return
	endif

	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)

	self:_AccessToken := ""
	self:_RefreshToken := ""

	self:_auxProfile := self:oProfile:Load()
	If Len(self:_auxProfile) == 0
	Else

		If Len(self:_auxProfile) == 5
			Return
		EndIf

		self:_RefreshToken := self:_auxProfile[PROF_REFRESHTOKEN]
		Do Case
		Case self:_auxProfile[PROF_DATETOKEN] <> DtoS(Date())
			useProfile := .f.
		Case self:_auxProfile[PROF_TIMETOKEN] > Time()
			useProfile := .f.
		Otherwise
			cElapTime := ElapTime(self:_auxProfile[PROF_TIMETOKEN], Time())

			nTotSec += Val(Left(cElapTime,2)) * 60 * 60
			nTotSec += Val(SubStr(cElapTime,4,2)) * 60
			nTotSec += Val(Right(cElapTime,2))

			If nTotSec > self:_auxProfile[PROF_EXPIREIN] - 60
				useProfile := .f.
			EndIf
		EndCase

		If useProfile
			self:_AccessToken := self:_auxProfile[PROF_ACCESSTOKEN]

		EndIf
	EndIf

Return

Method _saveProfile() Class OFJDOkta
	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)
	self:oProfile:SetProfile( self:_auxProfile )
	self:oProfile:Save()
Return

Method cleanProfile() Class OFJDOkta
	self:oProfile:SetProgram(self:_profProg)
	self:oProfile:SetTask(self:_profTask)
	self:oProfile:SetType(self:_profType)
	self:oProfile:SetProfile( {} )
	self:oProfile:Save()
Return

Method SetUserPasswd(cUser, cPasswd) Class OFJDOkta
	self:_userName := cUser
	self:_userPasswd := cPasswd
Return

Method SetPMLinkJDPoint() Class OFJDOkta
	
	If ::IsPMLinkJDPoint()
		return
	endif
	
	self:_service := SRVC_PMLINK

	self:_cURL := self:oConfig:getURLOktaPmLinkJdPoint()
	self:_cAuthServer := self:oConfig:getAuthSrvPmLinkJdPoint()
	self:_urlAuthN := self:oConfig:getPathAuthPmLinkJdPoint()
	self:_scope := Escape(self:oConfig:getScopePmLinkJdPoint())
	self:_scopeParam := self:oConfig:getScopePmLinkJdPoint()
	self:_client_ID := self:oConfig:getClientID('PML')
	self:_client_Secret := self:oConfig:getClientSecret('PML')

	self:_setTask()

Return

Method SetOrderStatusJDPoint() Class OFJDOkta

	If ::IsOrderStatusJDPoint()
		return
	endif

	self:_service := SRVC_ORDERSTATUS

	self:_cURL := self:oConfig:getURLOktaOrderStatusJdPoint()
	self:_cAuthServer := self:oConfig:getAuthSrvOrderStatusJdPoint()
	self:_urlAuthN := self:oConfig:getPathAuthOrderStatusJdPoint()
	self:_scope := Escape(self:oConfig:getScopeOrderStatusJdPoint())
	self:_scopeParam := self:oConfig:getScopeOrderStatusJdPoint()
	self:_client_ID := self:oConfig:getClientID('JDP')
	self:_client_Secret := self:oConfig:getClientSecret('JDP')

	self:_setTask()

Return

Method SetMaintainQuoteJDQuote() Class OFJDOkta

	if ::IsMaintainQuoteJDQuote()
		return
	endif

	self:_service := SRVC_JDQUOTE_MAINTAINQUOTE

	self:_cURL := self:oConfig:getURLOktaMaintainQuoteJDQuote()
	self:_cAuthServer := self:oConfig:getAuthSrvMaintainQuoteJDQuote()
	self:_urlAuthN := self:oConfig:getPathAuthMaintainQuoteJDQuote()
	self:_scope := Escape(self:oConfig:getScopeMaintainQuoteJDQuote())
	self:_scopeParam := self:oConfig:getScopeMaintainQuoteJDQuote()
	self:_client_ID := self:oConfig:getClientID('QTM')
	self:_client_Secret := self:oConfig:getClientSecret('QTM')

	self:_setTask()

Return

Method SetPODataJDQuote() Class OFJDOkta

	if ::IsPODataJDQuote()
		return
	endif

	self:_service := SRVC_JDQUOTE_PODATA

	self:_cURL := self:oConfig:getURLOktaPoDataJDQuote()
	self:_cAuthServer := self:oConfig:getAuthSrvPoDataJDQuote()
	self:_urlAuthN := self:oConfig:getPathAuthPoDataJDQuote()
	self:_scope := Escape(self:oConfig:getScopePoDataJDQuote())
	self:_scopeParam := self:oConfig:getScopePoDataJDQuote()
	self:_client_ID := self:oConfig:getClientID('QTP')
	self:_client_Secret := self:oConfig:getClientSecret('QTP')

	self:_setTask()

Return

Method SetWarranty() Class OFJDOkta

	if ::IsWarranty()
		return
	endif

	self:_service := SRVC_WARRANTY

	self:_cURL := self:oConfig:getURLOktaWarranty()
	self:_cAuthServer := self:oConfig:getAuthSrvWarranty()
	self:_urlAuthN := self:oConfig:getPathAuthWarranty()
	self:_scope := Escape(self:oConfig:getScopeWarranty())
	self:_scopeParam := self:oConfig:getScopeWarranty()
	self:_client_ID := self:oConfig:getClientID('WAR')
	self:_client_Secret := self:oConfig:getClientSecret('WAR')

	self:_setTask()

Return

Method SetNFCompra() Class OFJDOkta

	if ::IsNFCompra()
		return
	endif

	self:_service := SRVC_NFCOMPRA

	self:_cURL := self:oConfig:getURLOktaNotaFiscalCompra()
	self:_cAuthServer := self:oConfig:getAuthSrvNotaFiscalCompra()
	self:_urlAuthN := self:oConfig:getPathAuthNotaFiscalCompra()
	self:_scope := Escape(self:oConfig:getScopeNotaFiscalCompra())
	self:_scopeParam := self:oConfig:getScopeNotaFiscalCompra()
	self:_client_ID := self:oConfig:getClientID('NFS')
	self:_client_Secret := self:oConfig:getClientSecret('NFS')

	self:_setTask()

Return

Method SetDTFGETAPI() Class OFJDOkta

	if ::IsDTFGETAPI()
		return
	endif

	self:_service := SRVC_DTFGETAPI

	self:_cURL := self:oConfig:getURLOktaDTFGETAPI()
	self:_cAuthServer := self:oConfig:getAuthSrvDTFGETAPI()
	self:_urlAuthN := self:oConfig:getPathAuthDTFGETAPI()
	self:_scope := Escape(self:oConfig:getScopeDTFGETAPI())
	self:_scopeParam := self:oConfig:getScopeDTFGETAPI()
	self:_client_ID := self:oConfig:getClientID('DTFG')
	self:_client_Secret := self:oConfig:getClientSecret('DTFG')

	self:_setTask()

Return

Method SetDTFPUTAPI() Class OFJDOkta

	if ::IsDTFPUTAPI()
		return
	endif

	self:_service := SRVC_DTFPUTAPI

	self:_cURL := self:oConfig:getURLOktaDTFPUTAPI()
	self:_cAuthServer := self:oConfig:getAuthSrvDTFPUTAPI()
	self:_urlAuthN := self:oConfig:getPathAuthDTFPUTAPI()
	self:_scope := Escape(self:oConfig:getScopeDTFPUTAPI())
	self:_scopeParam := self:oConfig:getScopeDTFPUTAPI()
	self:_client_ID := self:oConfig:getClientID('DTFP')
	self:_client_Secret := self:oConfig:getClientSecret('DTFP')

	self:_setTask()

Return


Method SetCIFT() Class OFJDOkta

	if ::IsCIFT()
		return
	endif

	self:_service := SRVC_CIFT

	self:_cURL := self:oConfig:getURLOktaCIFT()
	self:_cAuthServer := self:oConfig:getAuthSrvCIFT()
	self:_urlAuthN := self:oConfig:getPathAuthCIFT()
	self:_scope := Escape(self:oConfig:getScopeCIFT())
	self:_scopeParam := self:oConfig:getScopeCIFT()
	self:_client_ID := self:oConfig:getClientID('CIFT')
	self:_client_Secret := self:oConfig:getClientSecret('CIFT')

self:_setTask()




Method IsPMLinkJDPoint() Class OFJDOkta
Return self:_service == SRVC_PMLINK

Method IsOrderStatusJDPoint() Class OFJDOkta
Return self:_service == SRVC_ORDERSTATUS

Method IsMaintainQuoteJDQuote() Class OFJDOkta
Return self:_service == SRVC_JDQUOTE_MAINTAINQUOTE

Method IsPODataJDQuote() Class OFJDOkta
Return self:_service == SRVC_JDQUOTE_PODATA

Method IsWarranty() Class OFJDOkta
Return self:_service == SRVC_WARRANTY

Method IsCIFT() Class OFJDOkta
Return self:_service == SRVC_CIFT

Method IsNFCompra() Class OFJDOkta
Return self:_service == SRVC_NFCOMPRA

Method IsDTFGETAPI() Class OFJDOkta
Return self:_service == SRVC_DTFGETAPI

Method IsDTFPUTAPI() Class OFJDOkta
Return self:_service == SRVC_DTFPUTAPI


Method _setTask() Class OFJDOkta
	cTaskType := Left(self:_cAuthServer,20)
	self:_profTask := Left(self:_cAuthServer,10)
	self:_profType := Right(self:_cAuthServer,10)
Return

Method getToken() Class OFJDOkta

	if ! empty(self:_AccessToken) // embora pareça duplicado não remova, é tratamento do oauth2 quando tem access ele retorna sem verificar mais nada
		Return self:_AccessToken
	endif

	if self:IsDTFGETAPI() .or. self:IsDTFPUTAPI()
		if self:_getDTFAccessToken()
			return self:_AccessToken
		endif
	endif

	self:_loadProfile()
	If ! Empty(self:_AccessToken)
		Return self:_AccessToken
	EndIf

	if ! self:loAuth2
		If self:_getSessionToken() .and. ! self:_getCode()
			Return .f.
		EndIf
	endif

	if ! Empty(self:_RefreshToken)
		if self:_getTokenRefresh()
			return self:_AccessToken
		endif
	endif

	if self:_getNewToken()
		return self:_AccessToken
	endif

Return ""

Method _getNewToken() Class OFJDOkta

	If ! self:_getSessionToken() 
		Return .f.
	EndIf

	If ! self:_getCode() 
		Return .f.
	EndIf

	If ! self:_getAccessToken()
		Return .f.
	EndIf

	self:_saveProfile()

Return .t.

Method _getSessionToken() Class OFJDOkta

	Local aHeader := {}
	Local lRetorno := .t.
	Local cError := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local cAuxMsg := ""
	Local lSchedule := FWGetRunSchedule()

	Local jsonParam := '{ "username": "' + self:_userName + '", "password": "' + self:_userPasswd + '"}'

	if ! self:isProperlyConfigured()
		return .f.
	endif

	if empty(self:_cURL) .or. empty(self:_urlAuthN)
		return .t.
	endif

	AADD( aHeader , "Accept: application/json" )
	AADD( aHeader , "Content-Type: application/json" )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath(self:_urlAuthN)
	self:oRest:setPostParams(jsonParam)
	
	lRetorno := self:oRest:Post(aHeader)

	if self:oJdConfig:DebugMode()
		cReq := "POST   -> " + self:oRest:cHost + self:oRest:cPath + chr(13) + chr(10)
		cReq += "PARAMS -> " + chr(13) + chr(10)
		cReq += "REQ BODY: " + cValToChar(jsonParam)
		cReq += "RESPONSE CODE: " + cValtoChar(self:oRest:GetHTTPCode()) + chr(13) + chr(10)
		cReq += "RESPONSE BODY: " + cValToChar(self:oRest:GetResult()) + chr(13) + chr(10)
		cReq += "---------------------------------------_getSessionToken()-------------------------------------------------------------" + chr(13) + chr(10)
		self:oLogger:Log({ 'TIMESTAMP', cReq })
	endif

	//conout(" ")
	//fsConout("[        __   ___  __   __     __          ___  __        ___            ]", "[42m")
	//fsConout("[       /__` |__  /__` /__` | /  \ |\ |     |  /  \ |__/ |__  |\ |       ]", "[42m")
	//fsConout("[       .__/ |___ .__/ .__/ | \__/ | \|     |  \__/ |  \ |___ | \|       ]", "[42m")
	//fsConout("[                                                                        ]", "[42m")
	//conout(" ")
	//fsConout(self:oRest:cHost)
	//fsConout(self:oRest:cPath)
	//conout(" ")
	//fsConout(jsonParam, )
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno) ,)
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()),)
	//conout(" ")
	//fsConout("Result " + cValToChar(self:oRest:GetResult()),)
	//conout(" ")

	If lRetorno
		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_sessionToken := self:oJsonResult['sessionToken']
		Else
			cAuxMsg := STR0008 + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token da sessão"
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"

			self:_sessionToken := ""
			lRetorno := .f.
		EndIf

	Else

		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			cAuxMsg += STR0002 + ": " + self:oJsonResult:GetJsonText("errorCode") + chr(13) + chr(10) +; // "Código do Erro"
				STR0003 + ": " + IIf( self:oJsonResult:GetJsonText("errorSummary") == "Authentication failed" , STR0004, self:oJsonResult:GetJsonText("errorSummary") ) // Resumo do Erro // "Falha de autenticação"

			MsgStop(STR0001 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cAuxMsg , STR0005) // "Erro na obtenção do token de sessão (sessionToken)"
			cAuxMsg := ""

		Else
			cError := cValToChar(self:oRest:getLastError())
			
			cAuxMsg += STR0008 + CHR(13) + CHR(10) + ; // "Não foi possível processar o retorno da chamada para obter o token da sessão"
				IIf( ! Empty(cError) , "GetLastError: " + cValToChar(cError) + chr(13) + chr(10) , "" ) +;
				STR0009 + "(fromJson): " + cRetFromJson

			cAuxMsg += chr(13) + chr(10) + "HTTP Code: " + cValToChar(self:oRest:GetHTTPCode())
		EndIf

		self:_sessionToken := ""
		lRetorno := .f.
	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[42m")

	If ! lRetorno .and. ! Empty(cAuxMsg) .and. !lSchedule
		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "getSessionToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	aSize(aHeader,0)

Return lRetorno

Method _getCode() Class OFJDOkta
	
	Local aHeader := {}
	Local aAuxINPUT := {}
	Local cGetParam
	Local lRetorno
	Local nPos
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local lSchedule := FWGetRunSchedule()

	Local lAprError := .f.

	if empty(self:_cURL)
		return .f.
	endif

	AADD(aHeader, "Accept: */*")
	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/authorize')
	self:oRest:setPostParams("")

	cGetParam := ;
		"client_id=" + cValToChar(self:_client_ID) + "&" + ;
		"response_type=code" + "&" + ;
		"response_mode=form_post" + "&" + ;
		"scope=" + cValToChar(self:_scope) + "&" + ;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" + ;
		"state=State" + "&" + ;
		"sessionToken=" + cValToChar(self:_sessionToken)

	lRetorno := self:oRest:Get(aHeader, cGetParam)

	if self:oJdConfig:DebugMode()
		cReq := "GET    -> " + self:oRest:cHost + self:oRest:cPath + chr(13) + chr(10)
		cReq += "PARAMS -> " + cGetParam + chr(13) + chr(10)
		cReq += "RESPONSE CODE: " + cValtoChar(self:oRest:GetHTTPCode()) + chr(13) + chr(10)
		cReq += "RESPONSE BODY: " + cValToChar(self:oRest:GetResult()) + chr(13) + chr(10)
		cReq += "------------------------------------------------_getCode--------------------------------------------------------" + chr(13) + chr(10)
		self:oLogger:Log({ 'TIMESTAMP', cReq })
	endif

	self:_codeAuthn := ""
	If lRetorno
		cAuxResult := self:oRest:GetResult()

		If self:oXMLManager:Parse(cAuxResult)
			aAuxINPUT := self:oXMLManager:XPathGetChildArray( "/html/body/form" )
			For nPos := 1 to Len(aAuxINPUT)

				aAuxAttr := self:oXMLManager:XPathGetAttArray( aAuxINPUT[nPos,2] )
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "code" }) > 0
					self:_codeAuthn := aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ]
				EndIf
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "error" }) > 0
					lRetorno := .f.
					//fsConout("[            __   ___  __   __   __           ___  __        __   __        ]","[101m]")
					//fsConout("[       /\  /  ` |__  /__` /__` /  \    |\ | |__  / _`  /\  |  \ /  \       ]","[101m]")
					//fsConout("[      /~~\ \__, |___ .__/ .__/ \__/    | \| |___ \__> /~~\ |__/ \__/       ]","[101m]")
					//fsConout("[                                                                           ]","[101m]")
					cAuxMsg += STR0002 + ": " + aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ] + chr(13) + chr(10)
				EndIf
				If aScan( aAuxAttr , { |x| x[1] == "name" .and. x[2] == "error_description" }) > 0
					cAuxMsg += STR0003 + ": " + aAuxAttr[aScan( aAuxAttr , { |x| x[1] == "value" } ), 2 ] + chr(13) + chr(10)
				EndIf
			Next nPos
		Else
			cAuxMsg := STR0010 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + ; 
				"Error (TXMLManager): " + self:oXMLManager:Error()

			lRetorno := .f.

		EndIf
	Else
		//fsConout(cValToChar(self:oRest:GETLASTERROR()))
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GETLASTERROR()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())
	EndIf

	If Empty(self:_codeAuthn) .and. lRetorno
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __      __   __   __     __   __  ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \    /  ` /  \ |  \ | / _` /  \ ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    \__, \__/ |__/ | \__> \__/ ")
		//Conout("                                                                                                                      ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If ! lRetorno .and. !lSchedule

		cAuxMsg += chr(13) + chr(10) + chr(13) + chr(10) + STR0006 + chr(13) + chr(10) +; // Parâmetros de conexão:
			"URL: " + cValtoChar(self:_cURL) + chr(13) + chr(10) +;
			"Path: " + '/oauth2/' + cValtoChar(self:_cAuthServer) + '/v1/authorize' + chr(13) + chr(10) +;
			"Auth. Server: " + cValtoChar(self:_cAuthServer) + chr(13) + chr(10) +;
			"Scope:" + cValToChar(self:_scopeParam) + CHR(13) + CHR(10) + ;
			"Redirect:" + cValToChar(self:_cRedirect_URI) + CHR(13) + CHR(10) + ;
			"State: State" + CHR(13) + CHR(10) // Parâmetros de conexão:

		lAprError := self:_getError(self:oRest:GetHTTPCode(),self:oRest:GetResult())

		if !lAprError
			If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "getCode") == 1 // "Copiar retorno para Area de Transferência."
				CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
			EndIf
		EndIf

	EndIf

	aSize(aHeader,0)
	aSize(aAuxINPUT,0)

	//conout(" ")
	//fsConout("[                                                                   ]", "[105m")


Return lRetorno

Method _getAccessToken() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=authorization_code" + "&" + ;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" + ;
		"scope=" + cValToChar(self:_scope) + "&" + ;
		"code=" + cValtoChar(self:_codeAuthn)

	lRetorno := self:_postToken(cGetParam)

Return lRetorno

Method _getDTFAccessToken() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=client_credentials" + "&" + ;// JOSE LUIS VERIFICAR QUAL O GRANT_TYPE
		"scope=" + cValToChar(self:_scope) + "&" +;
		"client_id=" + cValToChar(self:_client_ID) + "&" +;
		"client_secret=" + cValToChar(self:_client_Secret)
	
	lRetorno := self:_postTokenDTF(cGetParam)

Return lRetorno

Method _getTokenRefresh() Class OFJDOkta
	Local cGetParam
	Local lRetorno

	cGetParam := ;
		"grant_type=refresh_token" + "&" +;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" +;
		"scope=" + cValToChar(self:_scope) + "&" +;
		"refresh_token=" + cValToChar(self:_RefreshToken)

	lRetorno := self:_postToken(cGetParam)

Return lRetorno

/*/{Protheus.doc} RefreshTheToken
	Atualiza o token de acesso utilizando o refresh token.
	
	@type function
	@author Vinicius Gati
	@since 03/04/2025
/*/
Method refreshTheToken(cUsrId, cState, nService, cRefresh) Class OFJDOKTA
	Local cGetParam
	Local lRetorno

	if nService == SRVC_PMLINK
		self:SetPMLinkJDPoint()
	elseif nService == SRVC_ORDERSTATUS
		self:SetOrderStatusJDPoint()
	elseif nService == SRVC_JDQUOTE_MAINTAINQUOTE
		self:SetMaintainQuoteJDQuote()
	elseif nService == SRVC_JDQUOTE_PODATA
		self:SetPODataJDQuote()
	elseif nService == SRVC_WARRANTY
		self:SetWarranty()
	elseif nService == SRVC_NFCOMPRA
		self:SetNFCompra()
	elseif nService == SRVC_DTFGETAPI
		self:SetDTFGETAPI()
	elseif nService == SRVC_DTFPUTAPI
		self:SetDTFPUTAPI()
	else
		return .f.
	endif

	cGetParam := ;
		"grant_type=refresh_token" + "&" +;
		"redirect_uri=" + cValToChar(self:_cRedirect_URI) + "&" +;
		"scope=" + cValToChar(self:_scope) + "&" +;
		"refresh_token=" + cValToChar(cRefresh)
	self:cLastState := cState // setando o last ele vai gravar no ja existente renovando o token com sucesso
	lRetorno := self:_postToken(cGetParam)
	//todo: remover o token
return .t.

Method _postToken(cGetParam) Class OFJDOkta

	local oAuth := OFOAUTH2():New()
	Local lRetorno := .t.
	Local aHeader := {}
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local lSchedule := FWGetRunSchedule()

	AADD( aHeader , "Accept: application/json" )
	AADD( aHeader , "Content-Type: application/x-www-form-urlencoded" )
	AADD( aHeader , "Authorization: Basic " + Encode64(self:_client_ID + ":" + self:_client_Secret) )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/token')

	self:_AccessToken := ""
	self:oRest:SetPostParams(cGetParam)

	lRetorno := self:oRest:Post(aHeader)

	if self:oJdConfig:DebugMode()
		cReq := "POST   -> " + self:oRest:cHost + self:oRest:cPath + chr(13) + chr(10)
		cReq += "PARAMS -> " + chr(13) + chr(10)
		cReq += "REQ BODY: " + cValToChar(cGetParam)
		cReq += "RESPONSE CODE: " + cValtoChar(self:oRest:GetHTTPCode()) + chr(13) + chr(10)
		cReq += "RESPONSE BODY: " + cValToChar(self:oRest:GetResult()) + chr(13) + chr(10)
		cReq += "----------------------------------------------_postToken-----------------------------------------------------" + chr(13) + chr(10)
		self:oLogger:Log({ 'TIMESTAMP', cReq })
	endif


	//conout(" ")
	//fsConout("[       __   __   __  ___    ___  __        ___            ]","[46m")
	//fsConout("[      |__) /  \ /__`  |      |  /  \ |__/ |__  |\ |       ]","[46m")
	//fsConout("[      |    \__/ .__/  |      |  \__/ |  \ |___ | \|       ]","[46m")
	//fsConout("[                                                          ]","[46m")
	//conout(" ")
	//fsConout(cGetParam)
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno))
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()))
	//conout(" ")

	If lRetorno

		cAuxResult := self:oRest:GetResult()

		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_DateCreate := DtoS(Date())
			self:_TimeCreate := Time()

			self:_AccessToken := self:oJsonResult:GetJsonText("access_token")
			self:_ExpiresInSeconds := Val(self:oJsonResult:GetJsonText("expires_in"))
			self:_IDToken := self:oJsonResult:GetJsonText("id_token")

			if self:oJsonResult:hasProperty("refresh_token")
				self:_RefreshToken := cValToChar(self:oJsonResult:GetJsonText("refresh_token"))
				oAuth:SaveRefresh(self:_RefreshToken, self:cLastState)
			endif

			self:_auxProfile := Array(6)
			self:_auxProfile[PROF_TIMETOKEN]    := self:_TimeCreate
			self:_auxProfile[PROF_EXPIREIN]     := self:_ExpiresInSeconds
			self:_auxProfile[PROF_ACCESSTOKEN]  := self:_AccessToken
			self:_auxProfile[PROF_REFRESHTOKEN] := IIf( self:_RefreshToken <> "null" , self:_RefreshToken , "" )
			self:_auxProfile[PROF_IDTOKEN]      := self:_IDToken
			self:_auxProfile[PROF_DATETOKEN]    := self:_DateCreate
		Else
			cAuxMsg := STR0011 + "(_postToken)" + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token."
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"
			lRetorno := .f.
		EndIf

	Else
		//Conout(" ")
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                   ")
		//Conout(chr(27) + "[0m")
		//Conout(" ")
		//Conout( self:oRest:GetLastError() )
		//Conout("")
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GetLastError()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())

		lRetorno := .f.
	EndIf

	If Empty(self:_AccessToken)
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __           __   __   ___  __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     /\  /  ` /  ` |__  /__` /__`     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    /~~\ \__, \__, |___ .__/ .__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                                                    ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If !lRetorno .and. !lSchedule
		cAuxMsg := STR0012 + chr(13) + chr(10) + chr(13) + chr(10) + cAuxMsg // "Erro na obtenção do token."

		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "postToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[46m")

Return lRetorno


Method _postTokenDTF(cGetParam) Class OFJDOkta

	Local lRetorno := .t.
	Local aHeader := {}
	Local cAuxMsg := ""
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local lSchedule := FWGetRunSchedule()

	AADD( aHeader , "Content-Type: application/x-www-form-urlencoded" )

	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + '/v1/token')

	self:_AccessToken := ""
	self:oRest:SetPostParams(cGetParam)

	lRetorno := self:oRest:Post(aHeader)

	if self:oJdConfig:DebugMode()
		cReq := "POST   -> " + self:oRest:cHost + self:oRest:cPath + chr(13) + chr(10)
		cReq += "PARAMS -> " + chr(13) + chr(10)
		cReq += "REQ BODY: " + cValToChar(cGetParam)
		cReq += "RESPONSE CODE: " + cValtoChar(self:oRest:GetHTTPCode()) + chr(13) + chr(10)
		cReq += "RESPONSE BODY: " + cValToChar(self:oRest:GetResult()) + chr(13) + chr(10)
		cReq += "--------------------------------------_postTokenDTF---------------------------------------------------" + chr(13) + chr(10)
		self:oLogger:Log({ 'TIMESTAMP', cReq })
	endif

	//conout(" ")
	//fsConout("[       __   __   __  ___    ___  __        ___            ]","[46m")
	//fsConout("[      |__) /  \ /__`  |      |  /  \ |__/ |__  |\ |       ]","[46m")
	//fsConout("[      |    \__/ .__/  |      |  \__/ |  \ |___ | \|       ]","[46m")
	//fsConout("[                                                          ]","[46m")
	//conout(" ")
	//fsConout(cGetParam)
	//conout(" ")
	//fsConout("Retorno   " + cValToChar(lRetorno))
	//conout(" ")
	//fsConout("HTTP Code " + cValToChar(self:oRest:GetHTTPCode()))
	//conout(" ")

	If lRetorno
		
		//fsConout(self:oRest:GetResult())
		//conout(" ")

		cAuxResult := self:oRest:GetResult()

		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		If ValType(cRetFromJson) == "U" 
			self:_DateCreate := DtoS(Date())
			self:_TimeCreate := Time()

			self:_AccessToken := self:oJsonResult:GetJsonText("access_token")
			self:_ExpiresInSeconds := Val(self:oJsonResult:GetJsonText("expires_in"))
			self:_IDToken := self:oJsonResult:GetJsonText("id_token")
			self:_RefreshToken := ""
			
		Else
			cAuxMsg := STR0011 + "(_postTokenDTF)" + CHR(13) + CHR(10) +; // "Não foi possível processar o retorno da chamada para obter o token."
				STR0009 + "(fromJson): " + cRetFromJson // "Retorno"

			lRetorno := .f.
		EndIf

	Else
		//Conout(" ")
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                   ")
		//Conout(chr(27) + "[0m")
		//Conout(" ")
		//Conout( self:oRest:GetLastError() )
		//Conout("")
		cAuxMsg += "Last error: " + cValToChar(self:oRest:GetLastError()) + chr(13) + chr(10) +;
			"HTTP Code " + cValToChar(self:oRest:GetHTTPCode())

		lRetorno := .f.
	EndIf

	If Empty(self:_AccessToken)
		//Conout(chr(27) + "[101m")
		//Conout(" ___  __   __   __                   __   __  ___  ___       __        __      __   __           __   __   ___  __   __     ___  __        ___      ")
		//Conout("|__  |__) |__) /  \    |\ |  /\     /  \ |__)  |  |__  |\ | /  `  /\  /  \    |  \ /  \     /\  /  ` /  ` |__  /__` /__`     |  /  \ |__/ |__  |\ | ")
		//Conout("|___ |  \ |  \ \__/    | \| /~~\    \__/ |__)  |  |___ | \| \__, /~~\ \__/    |__/ \__/    /~~\ \__, \__, |___ .__/ .__/     |  \__/ |  \ |___ | \| ")
		//Conout("                                                                                                                                                    ")
		//Conout(chr(27) + "[0m")
		lRetorno := .f.
	EndIf

	If ! lRetorno .and. !lSchedule
		cAuxMsg := STR0012 + chr(13) + chr(10) + chr(13) + chr(10) + cAuxMsg // "Erro na obtenção do token."

		If Aviso(STR0005, cAuxMsg, { STR0013 ,"Ok"}, 3, "postToken") == 1 // "Copiar retorno para Area de Transferência."
			CopytoClipboard(cAuxMsg + IIf( ! Empty( cAuxResult ) , CHR(13) + CHR(10) + CHR(13) + CHR(10) + STR0009 + ": " + CHR(13) + CHR(10) + cAuxResult , "" ) )
		EndIf

	EndIf

	//conout(" ")
	//fsConout("[                                                                   ]", "[46m")

Return lRetorno



Static Function fsConout(cTexto, cCor)
	Default cCor := ""

	If ! Empty(cCor)
		cCor := chr(27) + cCor
	EndIf

	Conout(cCor + cTexto + chr(27) + "[0m")

Return

Method _getError(cHttpCode, cHtml) Class OFJDOkta

	Default cHttpCode := "200"

	DEFINE DIALOG oDlg TITLE "Error 400" FROM 180,180 TO 550,1124 PIXEL
		// Prepara o conector WebSocket
		PRIVATE oWebChannel := TWebChannel():New()
		// Cria componente
		PRIVATE oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100,, oWebChannel:connect())
		//oWebEngine:bLoadFinished := {|self,url|  }
		oWebEngine:SetHtml( cHTML )
		oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE DIALOG oDlg CENTERED

Return val(cHttpCode) > 399
