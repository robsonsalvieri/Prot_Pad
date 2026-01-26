#include 'protheus.ch'

/*/{Protheus.doc} OFJDOktaConfig
	Classe de Configuracao do Okta
	
	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Class OFJDOktaConfig from LongNameClass
	Data cCodigo
	Data oConfig

	Method New() CONSTRUCTOR

	Method saveConfig()
	Method getConfig()
	Method isProperlyConfigured()
	Method oauth2Habilitado()

	Method warranty()
	Method pmLinkJDPoint()
	Method orderStatusJDPoint()
	Method maintainQuoteJDQuote()
	Method poDataJDQuote()
	Method notaFiscalCompra()
	Method DTFGETAPI()
	Method DTFPUTAPI()
	Method CIFT()

	Method getClientID()
	Method getClientSecret()
	Method getRedirURI()

	Method getURLOktaWarranty()
	Method getAuthSrvWarranty()
	Method getPathAuthWarranty()
	Method getScopeWarranty()
	Method getUrlWSWarranty()

	Method getURLOktaCIFT()
	Method getAuthSrvCIFT()
	Method getPathAuthCIFT()
	Method getScopeCIFT()
	Method getUrlWSCIFT()

	Method getURLOktaPmLinkJdPoint()
	Method getAuthSrvPmLinkJdPoint()
	Method getPathAuthPmLinkJdPoint()
	Method getScopePmLinkJdPoint()
	Method getUrlWSPmLinkJDPoint()

	Method getURLOktaOrderStatusJdPoint()
	Method getAuthSrvOrderStatusJdPoint()
	Method getPathAuthOrderStatusJdPoint()
	Method getScopeOrderStatusJdPoint()
	Method getUrlWSOrderStatusJDPoint()

	Method getURLOktaMaintainQuoteJDQuote()
	Method getAuthSrvMaintainQuoteJDQuote()
	Method getPathAuthMaintainQuoteJDQuote()
	Method getScopeMaintainQuoteJDQuote()
	Method getUrlWSMaintainQuoteJDQuote()

	Method getURLOktaPoDataJDQuote()
	Method getAuthSrvPoDataJDQuote()
	Method getPathAuthPoDataJDQuote()
	Method getScopePoDataJDQuote()
	Method getUrlWSPoDataJDQuote()

	Method getURLOktaNotaFiscalCompra()
	Method getAuthSrvNotaFiscalCompra()
	Method getPathAuthNotaFiscalCompra()
	Method getScopeNotaFiscalCompra()
	Method getUrlWSNotaFiscalCompra()

	Method getURLOktaDTFGETAPI()
	Method getAuthSrvDTFGETAPI()
	Method getPathAuthDTFGETAPI()
	Method getScopeDTFGETAPI()
	Method getUrlWSDTFGETAPI()

	Method getURLOktaDTFPUTAPI()
	Method getAuthSrvDTFPUTAPI()
	Method getPathAuthDTFPUTAPI()
	Method getScopeDTFPUTAPI()
	Method getUrlWSDTFPUTAPI()

	Method _getURLOkta()
	Method _getAuthSrv()
	Method _getPathAuth()
	Method _getScope()
	Method _getURLWS()

EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method New() Class OFJDOktaConfig
	::cCodigo := "OFIOA280"
Return SELF

/*/{Protheus.doc} saveConfig
	Salva a configuracao no lugar da atual

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method saveConfig(oConfig) Class OFJDOktaConfig
	local cJson := oConfig:toJson()
	VRN->(dbSetOrder(1))
	if ExistBlock("OKTACTMCF") // PE criado para terraverde pois a configuração deles teve que ficar customizada devido a setup de filiais erroneo
		if ExecBlock("OKTACTMCF",.f.,.f.) // PE deve posicionar no VRN de acordo com o cFilAnt
			reclock("VRN", .F.)
			VRN->VRN_CONFIG := cJson
			VRN->(MsUnlock())
		endif
	else
		if VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
			reclock("VRN", .F.)
			VRN->VRN_CONFIG := cJson
			VRN->(MsUnlock())
		else
			return .f.
		endif
	endif
return .t.

/*/{Protheus.doc} isProperlyConfigured
	Verifica se o usuário configurou antes de user e causar erros

	@type method
	@author Vinicius Gati
	@since 18/11/2024
/*/
Method isProperlyConfigured() Class OFJDOktaConfig
	local oConfig := self:getConfig()
Return ! empty(oConfig["OKTA_ID"]) .and. ! empty(oConfig["OKTA_SEC"])

/*/{Protheus.doc} oauth2Habilitado
	Verifica se o usuario configurou o oauth2 para a aplicacao

	@type method
	@author Vinicius Gati
	@since 10/04/2025
/*/
Method oauth2Habilitado() Class OFJDOktaConfig
	if ValType(self:oConfig['OKTA_OAUTH2']) == "U"
		return .f.
	endif
Return self:oConfig['OKTA_OAUTH2'] == '1'

/*/{Protheus.doc} getConfig
	Pega a configuracao em formato de data container

	@type function
	@author Rubens Takahashi
	@since 27/03/2020
/*/
Method getConfig() Class OFJDOktaConfig
	local oConfig := JsonObject():New()
	local lVRN := FWAliasInDic("VRN")
	local lExistCfg := .f.

	If lVRN
		if ExistBlock("OKTACTMCF") // PE criado para terraverde pois a configuração deles teve que ficar customizada devido a setup de filiais erroneo
			lExistCfg := ExecBlock("OKTACTMCF",.f.,.f.) // PE deve posicionar no VRN de acordo com o cFilAnt
			oConfig:FromJson(VRN->VRN_CONFIG)
		else
			VRN->(dbSetOrder(1))
			lExistCfg := VRN->(dbSeek(xFilial("VRN") + self:cCodigo))
			if lExistCfg
				oConfig:FromJson(VRN->VRN_CONFIG)
			endif
		endif
	endif

	if ! lVRN .or. ! lExistCfg
		oCOnfig["OKTA_OAUTH2"] := '0'
		oConfig["OKTA_ID"]  := Space(50)
		oConfig["OKTA_SEC"] := Space(50)
		oConfig["OKTA_REDURI"] := Space(50)

		oConfig['WAROKTA'] := '0'
		oConfig['WARURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['WARAUTHSRV'] := PadR("aus9ddz3lqJc5gDhH1t7",50)
		oConfig['WARURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['WARSCOPE'] := PadR("openid",50)
		oConfig['WARURLWS'] := PadR("https://servicesext.deere.com:443/PIAbstractProxyOAuth/PIAbstractProxyService", 150)

		oConfig['PMLOKTA'] := '0'
		oConfig['PMLURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['PMLAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['PMLURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['PMLSCOPE'] := PadR("openid offline_access",50)
		oConfig['PMLURLWS'] := PadR("https://jdpo-apis.deere.com/parts/prod/pmlink_sap_2_3",150)

		oConfig['JDPOKTA'] := '0'
		oConfig['JDPURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['JDPAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['JDPURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['JDPSCOPE'] := PadR("openid offline_access",50)
		oConfig['JDPURLWS'] := PadR("https://jdpo-apis.deere.com/parts/prod/orderstatus_sap_2_4",150)

		oConfig['QTMOKTA'] := '0'
		oConfig['QTMURL'] := PadR("https://signin.johndeere.com/",50)
		oConfig['QTMAUTHSRV'] := PadR("aus78tnlaysMraFhC1t7",50)
		oConfig['QTMURLAUTH'] := PadR("v1/token",50)
		oConfig['QTMSCOPE'] := PadR("axiom",50)
		oConfig['QTMURLWS'] := PadR("https://jdquote2-api.deere.com/om/maintainquote/api/v1",150)

		oConfig['QTPOKTA'] := '0'
		oConfig['QTPURL'] := PadR("https://signin.johndeere.com/",50)
		oConfig['QTPAUTHSRV'] := PadR("aus78tnlaysMraFhC1t7",50)
		oConfig['QTPURLAUTH'] := PadR("/v1/token",50)
		oConfig['QTPSCOPE'] := PadR("axiom",50)
		oConfig['QTPURLWS'] := PadR("https://jdquote2-api.deere.com/om/podata/api/v1",150)

		oConfig['NFSOKTA'] := '0'
		oConfig['NFSURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['NFSAUTHSRV'] := PadR("aus9mir6too6AdwSD1t7",50)
		oConfig['NFSURLAUTH'] := PadR("/api/v1/authn",50)
		oConfig['NFSSCOPE'] := PadR("openid",50)
		oConfig['NFSURLWS'] := PadR("https://servicesext.deere.com/FDSWeb/services/AdvanceShipNoticeWS_1_1",150)

		oConfig['DTFGOKTA'] := '0'
		oConfig['DTFGURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['DTFGAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['DTFGURLAUTH'] := PadR("/v1/token",50)
		oConfig['DTFGSCOPE'] := PadR("dtf:dbs:file:read",50)
		oConfig['DTFGURLWS'] := PadR("https://dtfapi.deere.com/",150)

		oConfig['DTFPOKTA'] := '0'
		oConfig['DTFPURL'] := PadR("https://sso.johndeere.com",50)
		oConfig['DTFPAUTHSRV'] := PadR("aus9k0fb8kUjG8S5Z1t7",50)
		oConfig['DTFPURLAUTH'] := PadR("/v1/token",50)
		oConfig['DTFPSCOPE'] := PadR("dtf:dbs:file:write",50)
		oConfig['DTFPURLWS'] := PadR("https://dtfapi.deere.com/",150)

		oConfig['CIFTOKTA'] := '0'
		oConfig['CIFTURL'] := PadR(" ",50)
		oConfig['CIFTAUTHSRV'] := PadR(" ",50)
		oConfig['CIFTURLAUTH'] := PadR(" ",50)
		oConfig['CIFTSCOPE'] := PadR(" ",50)
		oConfig['CIFTURLWS'] := PadR(" ", 150)

		if lVRN
			reclock("VRN", .T.)
			VRN->VRN_FILIAL := xFilial("VRN")
			VRN->VRN_CODIGO := self:cCodigo
			VRN->VRN_CONFIG := oConfig:toJson()
			VRN->(MsUnlock())
		endif
	endif
	self:oConfig := oConfig
Return oConfig

Method warranty() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method pmLinkJDPoint() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method orderStatusJDPoint() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method maintainQuoteJDQuote() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method poDataJDQuote() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method notaFiscalCompra() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method DTFGETAPI() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method DTFPUTAPI() Class OFJDOktaConfig
return .T. // fixo true pois agora todos estao usando okta

Method CIFT() Class OFJDOktaConfig
return (self:oConfig['CIFTOKTA'] == '1')

Method getClientID(cApi) Class OFJDOktaConfig
	default cApi := ''

	if !empty(cApi) .AND. empty(AllTrim(self:oConfig[cApi + 'OKTA_ID']))
		return self:oConfig['OKTA_ID']
	endif

return self:oConfig[cApi + 'OKTA_ID']

Method getClientSecret(cApi) Class OFJDOktaConfig
	default cApi := ''

	if !empty(cApi) .AND. empty(AllTrim(self:oConfig[cApi + 'OKTA_SEC']))
		return self:oConfig['OKTA_SEC']
	endif

return self:oConfig[cApi + 'OKTA_SEC']

Method getRedirURI(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ 'OKTA_REDURI']


Method getURLOktaWarranty() Class OFJDOktaConfig
return self:_getURLOkta('WAR')

Method getAuthSrvWarranty() Class OFJDOktaConfig
return self:_getAuthSrv('WAR')

Method getPathAuthWarranty() Class OFJDOktaConfig
return self:_getPathAuth('WAR')

Method getScopeWarranty() Class OFJDOktaConfig
return self:_getScope('WAR')

Method getUrlWSWarranty() Class OFJDOktaConfig
return self:_getUrlWs('WAR')


Method getURLOktaCIFT() Class OFJDOktaConfig
return self:_getURLOkta('CIFT')

Method getAuthSrvCIFT() Class OFJDOktaConfig
return self:_getAuthSrv('CIFT')

Method getPathAuthCIFT() Class OFJDOktaConfig
return self:_getPathAuth('CIFT')

Method getScopeCIFT() Class OFJDOktaConfig
return self:_getScope('CIFT')

Method getUrlWSCIFT() Class OFJDOktaConfig
return self:_getUrlWs('CIFT')


Method getURLOktaPmLinkJdPoint() Class OFJDOktaConfig
return self:_getURLOkta('PML')

Method getAuthSrvPmLinkJdPoint() Class OFJDOktaConfig
return self:_getAuthSrv('PML')

Method getPathAuthPmLinkJdPoint() Class OFJDOktaConfig
return self:_getPathAuth('PML')

Method getScopePmLinkJdPoint() Class OFJDOktaConfig
return self:_getScope('PML')

Method getUrlWSPmLinkJDPoint() Class OFJDOktaConfig
return self:_getUrlWs('PML')


Method getURLOktaOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getURLOkta('JDP')

Method getAuthSrvOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getAuthSrv('JDP')

Method getPathAuthOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getPathAuth('JDP')

Method getScopeOrderStatusJdPoint() Class OFJDOktaConfig
return self:_getScope('JDP')

Method getUrlWSOrderStatusJDPoint() Class OFJDOktaConfig
return self:_getUrlWs('JDP')


Method getURLOktaMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getURLOkta('QTM')

Method getAuthSrvMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getAuthSrv('QTM')

Method getPathAuthMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getPathAuth('QTM')

Method getScopeMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getScope('QTM')

Method getUrlWSMaintainQuoteJDQuote() Class OFJDOktaConfig
return self:_getUrlWs('QTM')


Method getURLOktaPoDataJDQuote() Class OFJDOktaConfig
return self:_getURLOkta('QTP')

Method getAuthSrvPoDataJDQuote() Class OFJDOktaConfig
return self:_getAuthSrv('QTP')

Method getPathAuthPoDataJDQuote() Class OFJDOktaConfig
return self:_getPathAuth('QTP')

Method getScopePoDataJDQuote() Class OFJDOktaConfig
return self:_getScope('QTP')

Method getUrlWSPoDataJDQuote() Class OFJDOktaConfig
return self:_getUrlWs('QTP')


Method getURLOktaNotaFiscalCompra() Class OFJDOktaConfig
return self:_getURLOkta('NFS')

Method getAuthSrvNotaFiscalCompra() Class OFJDOktaConfig
return self:_getAuthSrv('NFS')

Method getPathAuthNotaFiscalCompra() Class OFJDOktaConfig
return self:_getPathAuth('NFS')

Method getScopeNotaFiscalCompra() Class OFJDOktaConfig
return self:_getScope('NFS')

Method getUrlWSNotaFiscalCompra() Class OFJDOktaConfig
return self:_getUrlWs('NFS')


Method getURLOktaDTFGETAPI() Class OFJDOktaConfig
return self:_getURLOkta('DTFG')

Method getAuthSrvDTFGETAPI() Class OFJDOktaConfig
return self:_getAuthSrv('DTFG')

Method getPathAuthDTFGETAPI() Class OFJDOktaConfig
return self:_getPathAuth('DTFG')

Method getScopeDTFGETAPI() Class OFJDOktaConfig
return self:_getScope('DTFG')

Method getUrlWSDTFGETAPI() Class OFJDOktaConfig
return self:_getURLWS('DTFG')


Method getURLOktaDTFPUTAPI() Class OFJDOktaConfig
return self:_getURLOkta('DTFP')

Method getAuthSrvDTFPUTAPI() Class OFJDOktaConfig
return self:_getAuthSrv('DTFP')

Method getPathAuthDTFPUTAPI() Class OFJDOktaConfig
return self:_getPathAuth('DTFP')

Method getScopeDTFPUTAPI() Class OFJDOktaConfig
return self:_getScope('DTFP')

Method getUrlWSDTFPUTAPI() Class OFJDOktaConfig
return self:_getURLWS('DTFP')


Method _getURLOkta(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URL']

Method _getAuthSrv(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'AUTHSRV']

Method _getPathAuth(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URLAUTH']

Method _getScope(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'SCOPE']

Method _getUrlWs(cPrefixo) Class OFJDOktaConfig
return self:oConfig[ cPrefixo + 'URLWS']
