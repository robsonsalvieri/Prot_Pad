#INCLUDE "TOTVS.ch"
#INCLUDE "VEJDQUOTERESTAUTH.CH"

/*/{Protheus.doc} VEJDQuoteRestAuth
	Classe para comfigurar autenticação JDQuoteRest
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Class VEJDQuoteRestAuth

	Data cCodigo
	Data oConfig

	Data oJsonResult
	Data cErro

	Data _ClientId
	Data _ClientSecret

	Data _cURL
	Data _cAuthServer
	Data _urlAuth
	Data _scope
	Data _cURLWS

	Data oRest AS OBJECT

	Data cAccessToken

	Method New() CONSTRUCTOR
	
	Method getConfig()
	Method getToken()
	Method setMaintainQuoteRest()
	Method setPurchaseOrderRest()
	
	Method _postToken()
	Method _getClientCredentials()
	Method _SetHeader()
	Method GetURL()
	

EndClass

/*/{Protheus.doc} New
	Construtor SImples
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Method New() Class VEJDQuoteRestAuth
	self:cCodigo := "OFIOA280"
	self:cErro   := ""
	self:oRest   := FWRest():New(self:_cURL)

	self:oJsonResult := JsonObject():New()
	self:oConfig     := JsonObject():New()

Return self

/*/{Protheus.doc} GetConfig
	Pega a configuração em formato de container
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Method GetConfig() Class VEJDQuoteRestAuth
	Local lVrn := FWAliasInDic("VRN")

	If lVrn
		VRN->(dBSetOrder(1))
		lExistCfg := VRN->(dBSeek(xFilial("VRN") + self:cCodigo))
		if lExistCfg
			self:oConfig:FromJson(VRN->VRN_CONFIG)
		EndIf
	EndIf

return

/*/{Protheus.doc} SetMaintainQuoteRest
	Configura como MaintainQuote
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Method SetMaintainQuoteRest() Class VEJDQuoteRestAuth
	
	self:_cURL 		  := self:oConfig["QTMURL"]
	self:_cAuthServer := self:oConfig["QTMAUTHSRV"]
	self:_urlAuth 	  := self:oConfig["QTMURLAUTH"]
	self:_scope 	  := Escape(self:oConfig["QTMSCOPE"])
	self:_cURLWS  	  := self:oConfig["QTMURLWS"]

Return

/*/{Protheus.doc} SetPurchaseOrderRest
	Configura como PO Data Service
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Method SetPurchaseOrderRest() Class VEJDQuoteRestAuth

	self:_cURL 		  := self:oConfig["QTPURL"]
	self:_cAuthServer := self:oConfig["QTPAUTHSRV"]
	self:_urlAuth 	  := self:oConfig["QTPURLAUTH"]
	self:_scope 	  := Escape(self:oConfig["QTPSCOPE"])
	self:_cURLWS   	  := self:oConfig["QTPURLWS"]

Return

/*/{Protheus.doc} GetToken
	Configura parametros e chama o metodo _postToken para fazer o post e obter o token
	
	@author  Daniel
	@since   24/07/2024
	@version version
/*/
Method GetToken() Class VEJDQuoteRestAuth
	Local cGetParam

	if Empty(self:_scope) .or. Empty(self:_cAuthServer) .or. Empty(self:_cURL) .or. Empty(self:_urlAuth) .or. Empty(self:_cURLWS)
		self:cErro += STR0001 + CRLF // "Parâmetros não preenchidos."
	EndIf

	cGetParam := ;
		"grant_type=client_credentials" + "&" + ;
		"cache-control=no-cache" + "&" + ;
		"scope=" + cValToChar(self:_scope)

	self:_postToken(cGetParam)

Return self:cAccessToken

/*/{Protheus.doc} _postToken
	Faz o post para obter o token
	
	@params  cGetParam
	@author  Daniel
	@since   25/07/2024
	@version version
/*/
Method _postToken(cGetParam) Class VEJDQuoteRestAuth
	Local lRet := .t.
	Local lRetorno := .t.
	Local aHeader := {}
	Local cAuxResult := ""
	Local cRetFromJson := ""
	Local lSchedule := FWGetRunSchedule()
	Local cAuxMsg := ""

	self:cAccessToken := ""
	
	//usa o client credentials (cadastrado na VRN)
	If ! self:_getClientCredentials()
		Return
	Endif
	
	aHeader := self:_SetHeader()

	//seta o url e path do post
	self:oRest:SetHost(self:_cURL)
	self:oRest:setPath('/oauth2/' + self:_cAuthServer + self:_urlAuth)
	self:oRest:SetPostParams(cGetParam)

	//faz o post 
	lRet := self:oRest:Post(aHeader)

	//se retornar .t. pega o resultado, se não, pega o erro
	if lRet
		
		cAuxResult := self:oRest:GetResult()
		cRetFromJson := self:oJsonResult:FromJson(cAuxResult)
		
		If ValType(cRetFromJson) == "U" 
			self:cAccessToken := self:oJsonResult:GetJsonText("access_token")
		 
			
			 
			
		EndIf
	Else 
		cAuxMsg += STR0004 + cValToChar(self:oRest:GetLastError()) + chr(13) + chr(10) +; // "Last error: "
			STR0005 + cValToChar(self:oRest:GetHTTPCode()) // "HTTP Code "
		lRetorno := .f.
	EndIf
	
	If Empty(self:cAccessToken)
		lRetorno := .f.
	EndIf

	If !lRetorno .and. !lSchedule
		cAuxMsg := STR0006 + chr(13) + chr(10) + chr(13) + chr(10) + cAuxMsg // "Erro na obtenção do token."

		self:cErro += cAuxMsg
	EndIf

return lRetorno

/*/{Protheus.doc} _getClientCredentials
	Configura credenciais do usuário para obter o token
	
	@author  Daniel
	@since   25/07/2024
	@version version
/*/
Method _getClientCredentials() Class VEJDQuoteRestAuth
	if empty(self:oConfig["QTPOKTA_ID"])
		self:_ClientId  := self:oConfig["OKTA_ID"]
	else
		self:_ClientId  := self:oConfig["QTPOKTA_ID"] 
	endif

	if empty(self:oConfig["QTPOKTA_SEC"])
		self:_ClientSecret  := self:oConfig["OKTA_SEC"]
	else
		self:_ClientSecret  := self:oConfig["QTPOKTA_SEC"] 
	endif

	if Empty(self:_ClientId) .or. Empty(self:_ClientSecret)
		self:cErro += STR0007 + CRLF // "Credenciais não preenchidas." 
		Return .f.
	EndIf

Return .t.

/*/{Protheus.doc} function
	description

	@author  Daniel
	@since   09/08/2024
	@version version
/*/
Method _SetHeader() Class VEJDQuoteRestAuth
	Local aHeader := {}
	
	//Seta header com Client Id e Secret
	AADD( aHeader , "Accept: application/json" )
	AADD( aHeader , "Content-Type: application/x-www-form-urlencoded" )
	AADD( aHeader , "Authorization: Basic " + Encode64(self:_ClientId + ":" + self:_ClientSecret) )

Return aHeader 

/*/{Protheus.doc} GetURL
	Pega o URL do WebService que será feita a requisição
	
	@params  cPrefixo
	@author  Daniel
	@since   25/07/2024
	@version version
/*/
Method GetURL(cPrefixo) Class VEJDQuoteRestAuth
	_cURLWS := self:oConfig[cPrefixo + "URLWS"]
return self:_cURLWS
