#Include "PROTHEUS.CH"
#Include "msobject.ch"
#Include "VEIA380.ch"


/*/{Protheus.doc} OFJDCIFT

	@type Class
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Class OFJDCIFT
	
	Data _oOkta
	Data _cToken
	
	Method New() CONSTRUCTOR
	
	Method EnviaMensagem()
	Method GetToken()
	Method GetURLAuth()
	Method GetScope()
	Method GetClient()
	Method GetSecret()
	Method GetUrlWS()
	
End Class


/*/{Protheus.doc} New

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method New() Class OFJDCIFT

	Self:_oOkta := OFJDOkta():New()

	If Self:_oOkta:oConfig:CIFT()
		Self:_oOkta:SetCIFT()
	Else
		Return .f.	
	Endif

Return Self


/*/{Protheus.doc} EnviaMensagem

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method EnviaMensagem(cBody, cArquivo) Class OFJDCIFT

	Local cResult    := ""
	Local aHeader    := {}
	Local lRet       := .f.
	Local oRest      := FWRest():New(Self:GetUrlWS())
	Local oOFCIFTLog := OFDMSRequest():New()
	Local oRet       := JsonObject():new()
	Local oHeader    := JsonObject():New()

	Default cBody    := ""
	Default cArquivo := ""

	Self:GetToken() 
	If !Empty(Self:_cToken)
		If !Empty(cBody)
			AAdd(aHeader, "Content-Type: application/json")
			AAdd(aHeader, "Authorization: Bearer " + Self:_cToken)  
			AAdd(aHeader, "X-Deere-Cift-FileType: MarkedSoldR3OFS")
			//AAdd(aHeader, 'X-Deere-Cift-Metadata: {"dbsOrderNumber":"'+Self:oOrder['salesOrderCode']+'", "dealerAccount": "'+self:cCodDealer+'"}' )

			oRest:setPath("/files")
			oOFCIFTLog:SetTypeCIFT()
			oOFCIFTLog:SetOriginDBS()

			If oRest:Put(aHeader, cBody)
				cResult := oRet:FromJson(oRest:cResult)
				If ValType(cResult) == "U"   
					If oRet["statusCode"] == "201"       
						lRet := .t.
					EndIf
				EndIf
			EndIf

			oHeader:Set(aHeader)

			oOFCIFTLog:Set("VK5_MESSAG", "06")
			oOFCIFTLog:Set("VK5_ORIKEY", FunName())
			oOFCIFTLog:Set("VK5_REQHEA", oHeader:ToJson())
			oOFCIFTLog:Set("VK5_REQBOD", Alltrim(cBody))            
			oOFCIFTLog:Set("VK5_RESBOD", STR0006) //Arquivo enviado, verificar código do retorno.
			oOFCIFTLog:Set("VK5_RESHEA", Alltrim(cArquivo))
			oOFCIFTLog:Set("VK5_RESCOD", val(SubStr(oRest:GetLastError(),1,3)))
			oOFCIFTLog:Save()
		Endif	
	EndIf
	
Return lRet


/*/{Protheus.doc} GetToken

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetToken() Class OFJDCIFT

	Local cParams      := ""
	Local cResult      := ""
	Local aHeader      := {}                        
	Local oJson        := JsonObject():new()
	Local oRest        := FWRest():New(Self:GetURLAuth())
	Local oOFCIFTLog   := OFDMSRequest():New()

	AAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")
	AAdd(aHeader, "Authorization: Basic " + Encode64(Self:GetClient() + ":" + Self:GetSecret()))

	cParams += "&grant_type=client_credentials"
	cParams += "&scope=" + Self:GetScope()

	::_cToken := ""  

	oRest:setPath("")
	oRest:SetPostParams(cParams)

	If oRest:Post(aHeader)
		cResult := oJson:FromJson(oRest:cResult)
		If ValType(cResult) == "U"                  // -- Nil indica que conseguiu popular o objeto com o Json
			::_cToken := oJson["access_token"]      // -- Chave de acesso
		EndIf
	EndIf

	If Empty(::_cToken)
		oOFCIFTLog:SetTypeCIFT()
		oOFCIFTLog:SetOriginDBS()

		oOFCIFTLog:Set("VK5_MESSAG", "06")
		oOFCIFTLog:Set("VK5_ORIKEY", FunName())
		oOFCIFTLog:Set("VK5_RESHEA", Alltrim(STR0007)) //Erro ao obter o Token do Okta.
		oOFCIFTLog:Set("VK5_RESBOD", Alltrim(STR0008)) //Não foi possível obter o Token do Okta, verifique as configurações.
		oOFCIFTLog:Set("VK5_RESCOD", val(SubStr(oRest:GetLastError(),1,3)))
		oOFCIFTLog:Save()
	Endif

	FreeObj(oRest)
	FreeObj(oJson)    

Return ::_cToken


 /*/{Protheus.doc} GetURLAuth

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetURLAuth() Class OFJDCIFT
Return Self:_oOkta:oConfig:getURLOktaCIFT();
	+ "/oauth2/"; 
	+ Self:_oOkta:oConfig:getAuthSrvCIFT();
	+ Self:_oOkta:oConfig:getPathAuthCIFT()


 /*/{Protheus.doc} GetScope

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetScope() Class OFJDCIFT
Return Self:_oOkta:oConfig:getScopeCIFT()


/*/{Protheus.doc} GetClient

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetClient() Class OFJDCIFT
Return Self:_oOkta:oConfig:getClientID("CIFT")


/*/{Protheus.doc} GetSecret

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetSecret() Class OFJDCIFT
Return Self:_oOkta:oConfig:getClientSecret("CIFT")


/*/{Protheus.doc} GetURLWS

	@type Method
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Method GetURLWS() Class OFJDCIFT
Return Self:_oOkta:oConfig:getUrlWSCIFT()