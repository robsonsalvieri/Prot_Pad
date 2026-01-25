#INCLUDE "TOTVS.CH"
#INCLUDE "VEJDQUOTEREST.CH"

/*/{Protheus.doc} VEJDQuoteRest
	Classe para integração com API REST do JDQuote.

	@author  Daniel
	@since   22/07/2024
	@version version
/*/
Class VEJDQuoteRest

	Data aHeadStr
	Data cJsonResponse

	data oJdquoteAuth
	data cErro

	Data cToken
	Data cPassword
	Data cFABUSR
	Data cDealerAccount

	Data oCfgAuth as OBJECT

	Method New() CONSTRUCTOR
	Method Authenticate()

	Method _GetBaseUrl()
	Method _SetHeader()

	Method GetQuoteById()
	Method GetQuotes()

	Method GetMasterById()
	Method GetMasters()

	Method GetQuoteDetails()

	Method _GetMasterQuotesResponse()
	Method _GetQuotesResponse()
	Method _GetQuoteDetailResponse()
	Method _GetCustomer()
	Method _getEquipmentsFromQuote()
	Method _getTradeInsFromQuote()

EndClass

/*/{Protheus.doc} Method New
	Construtor Simples

	@author  Daniel
	@since   22/07/2024
	@version version
/*/
Method New() Class VEJDQuoteRest
	self:cErro  := ""

	// Pega Usuário X
	VAI->(DBSetOrder(4))
	VAI->(MSSeek(xFilial('VAI')+ __cUserID))
	VAI->(DBSetOrder(1))
	self:cFABUSR := Upper(AllTrim(VAI->VAI_FABUSR)) //:= self:_getFabUser

	// Pega Dealer 
	self:cDealerAccount := AllTrim(GetMV("MV_MIL0133")) // := self:_getDealerAccount
	
	//classe de autenticação
	self:oCfgAuth := VEJDQuoteRestAuth():New()
	self:oCfgAuth:getConfig()
	self:oCfgAuth:setMaintainQuoteRest()
Return self

/*/{Protheus.doc} Method Authenticate
	Checa autenticação OKTA

	@author  Daniel
	@since   22/04/2024
	@version version
/*/
Method Authenticate() class VEJDQuoteRest
	self:cToken := self:oCfgAuth:getToken()
	
	If Empty(self:cToken)
		self:cErro := self:oCfgAuth:cErro
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} _GetBaseUrl
	Pega a Base URL do Webservice para fazer o request

	@author  Daniel
	@since   25/07/2024
	@version version
/*/
method _GetBaseUrl() class VEJDQuoteRest
Return self:oCfgAuth:GetURL("QTM")

/*/{Protheus.doc} _SetHeader
	Define o Header da requisição

	@author  Daniel
	@since   29/07/2024
	@param	 lContentType, define se adicionará ao header o content_type
	@version version
/*/
method _SetHeader(lContentType) class VEJDQuoteRest
	Local aHeadStr := {}
	
	If lContentType
		aAdd(aHeadStr, "Content-Type: application/json")
	EndIf

	// Adiciona token de autenticação no header
	aAdd(aHeadStr, "Authorization: Bearer " + self:cToken)
		
Return aHeadStr

/*/{Protheus.doc} GetQuotes
	Executa metodo getQuote para retornar uma lista de cotacoes filtradas pelo parametro da consulta

	@author  Daniel
	@since   22/07/2024
	@param   dDataIni
	@param   dDataFim
	@param   nQuoteId
	@param   lSchedule
	@version version
/*/
Method GetQuotes(dDataIni, dDataFim, nQuoteId,lSchedule) class VEJDQuoteRest
	Local lContentType := .t.
	Local cHeadRet  := ""
	Local cBaseURL  := ""
	Local cResponse := ""
	Local jBody := JsonObject():New()
	Local jJsonManager := JsonObject():New()

	If self:Authenticate()

		cBaseURL := self:_GetBaseUrl()
		aHeadStr := self:_SetHeader(lContentType)

		if nQuoteId <> 0
			jBody["quoteId"]:= cValToChar(nQuoteId)
		Endif
		
		jBody["dealerRacfID"]:= self:cFABUSR
		jBody["startModifiedDate"] := dDataIni
		jBody["endModifiedDate"]   := dDataFim

		cResponse := HttpPost(cBaseURL + "/dealers/" + self:cFABUSR + "/maintain-quotes",, jBody:ToJson(), 60, aHeadStr, @cHeadRet)

		If At('{', cResponse) == 0 //Provavelmente não é um json
			If ValType(cResponse) == "C" // me certificando que a resposta é uma string
				self:cErro += chr(13) + chr(10) + STR0001 + "GETQUOTESERR001" + chr(13) + chr(10) + chr(13) + chr(10) +; //"Erro"
				 "URL: " + cBaseURL + chr(13) + chr(10) + chr(13) + chr(10) +;
				 STR0002 + AllTrim(cResponse) // "Retorno: "
				return NIL
			EndIf
		EndIf

		jJsonManager:FromJson(cResponse)

		Return self:_GetQuotesResponse(jJsonManager)
	EndIf

Return NIL

/*/{Protheus.doc} GetMasters
	Metodo que realiza a consulta getMasterQuote e retorna uma lista das cotacoes master
	
	@author  Daniel
	@since   24/07/2024
	@param   dDataIni
	@param   dDataFim
	@param   nQuoteId
	@param   cMasterIndicator
	@version version
/*/
Method GetMasters(dDataIni, dDataFim, nQuoteId, cMasterIndicator) class VEJDQuoteRest
	Local lContentType := .t.
	Local cHeadRet := ""
	Local cBaseURL := ""
	Local jBody := JsonObject():New()
	Local cResponse := ""
	Local jJsonManager := JsonObject():New()


	If self:Authenticate()

		cBaseURL := self:_GetBaseUrl()
		aHeadStr := self:_SetHeader(lContentType)

		if nQuoteId <> 0
			jBody["quoteId"] := cValToChar(nQuoteId)
		Endif	

		jBody["dealerCompanyMasterIndicator"] := cMasterIndicator
		jBody["dealerRacfID"]      := self:cFABUSR 
		jBody["startModifiedDate"] := dDataIni
		jBody["endModifiedDate"]   := dDataFim

		cResponse := HttpPost(cBaseURL + "/dealers/" + self:cFABUSR + "/quotes",, jBody:ToJson(), 60, aHeadStr, @cHeadRet)
		
		If At('{', cResponse) == 0 //Provavelmente não é um json
			If ValType(cResponse) == "C" // me certificando que a resposta é uma string
				self:cErro += chr(13) + chr(10) + STR0001 + "GETQUOTESERR002" + chr(13) + chr(10) + chr(13) + chr(10) +; //"Erro"
				 "URL: " + cBaseURL + chr(13) + chr(10) + chr(13) + chr(10) +;
				 STR0002 + AllTrim(cResponse) // "Retorno: "
				return NIL
			EndIf
		EndIf

		jJsonManager:FromJson(cResponse)

		Return self:_GetMasterQuotesResponse(jJsonManager)
	EndIf
Return NIL

/*/{Protheus.doc} GetQuoteDetail()
	Consulta os detalhes da cotacao filtrado pelo id

	@author  Daniel
	@since   26/07/2024
	@version version
/*/
Method GetQuoteDetails(nQuoteId) Class VEJDQuoteRest
	Local lContentType := .f.
	Local cHeadGet  := ""
	Local cBaseURL  := ""
	Local cResponse := ""
	Local jJsonManager := JsonObject():New()

	self:cErro := ""

	If self:Authenticate()

		cBaseURL := self:_GetBaseUrl()
		aHeadStr := self:_SetHeader(lContentType)

		cResponse := HttpGet(cBaseURL + "/quotes/" + cValToChar(nQuoteId) + "/maintain-quote-details?dealerAccountNo=" + self:cDealerAccount , , 60, aHeadStr, @cHeadGet)
		jJsonManager:FromJson(cResponse)
		
		Return self:_GetQuoteDetailResponse(jJsonManager)
	EndIf
Return NIL

/*/{Protheus.doc} _GetMasterQuotesResponse
	description

	@author  Daniel
	@since   30/07/2024
	@param	 jJsonManager, JSON resposta da requisição
	@version version
/*/

Method _GetMasterQuotesResponse(jJsonManager) Class VEJDQuoteRest
	Local aResponse := {}
	Local aMasterResponse := {}
	Local jAuxResponse // Objeto json auxiliar
	Local nI 
	Local cMsgErro 
	Local cStatusErro
	
	self:cErro := ""

	If jJsonManager:hasProperty("statusCode") .and. jJsonManager["statusCode"] > 299
		cStatusErro := cValToChar(jJsonManager["statusCode"])
		cMsgErro   := jJsonManager["message"]
		self:cErro += STR0001 + cStatusErro + ". " + cMsgErro + chr(13) + chr(10) // "Erro: "
		return NIL
	endif

	If jJsonManager["type"] <> "ERROR"
		aResponse := jJsonManager["body"]//pega o array com as cotções

		For nI := 1 to len(aResponse)
			// popula objeto auxiliar com os valores da cotação master na posição nI do array aResponse
			jAuxResponse := JsonObject():New()
			jAuxResponse["quoteId"]		    := cValToChar(aResponse[nI]["quoteId"])
			jAuxResponse["quoteName"]		:= DecodeUtf8(aResponse[nI]["quoteName"], "cp1252")
			jAuxResponse["creationDate"]	:= QuoteFormataData(aResponse[nI]["creationDate"])
			jAuxResponse["expirationDate"]  := QuoteFormataData(aResponse[nI]["expirationDate"])
			jAuxResponse["quoteType"]		:= aResponse[nI]["quoteType"]
			jAuxResponse["deleteIndicator"] := aResponse[nI]["deleteIndicator"]
			
			AAdd(aMasterResponse, jAuxResponse)//Adiciona 1 objeto com apenas as informações necessárias da master quote
		Next

		Return aMasterResponse
	EndIf
	
	cMsgErro   := jJsonManager["errorMessage"][1]
	self:cErro += STR0001 + cMsgErro + chr(13) + chr(10) //"Erro: "

Return aMasterResponse

/*/{Protheus.doc} _GetQuotesResponse
	Processa a resposta das requisições de cotação
	
	@author  Daniel
	@since   dat30/07/2024
	@param	 jJsonManager, JSON resposta da requisição
	@version version
/*/
Method _GetQuotesResponse(jJsonManager) Class VEJDQuoteRest
	Local aResponse := {}
	Local aQuotesResponse := {}
	Local jAuxResponse
	Local nI
	Local cStatusErro
	Local cMsgErro

	If jJsonManager:hasProperty("statusCode") .and. jJsonManager["statusCode"] > 299
		cStatusErro := cValToChar(jJsonManager["statusCode"])
		cMsgErro   := jJsonManager["message"]
		self:cErro += STR0001 + cStatusErro + ". " + cMsgErro + chr(13) + chr(10) //"Erro: "
		return NIL
	endif

	if jJsonManager["type"] <> "ERROR"
		aResponse := jJsonManager["body"]
		
		For nI := 1 to len(aResponse)
			jAuxResponse := JsonObject():New()
			jAuxResponse["quoteId"] 		:= aResponse[nI]["quoteId"]
			jAuxResponse["quoteName"] 		:= DecodeUTF8(aResponse[nI]["quoteName"], "cp1252")
			jAuxResponse["quoteStatus"] 	:= aResponse[nI]["quoteStatus"]
			jAuxResponse["customerName"] 	:= aResponse[nI]["customerName"]
			jAuxResponse["quoteTotal"]	 	:= aResponse[nI]["quoteTotal"]
			jAuxResponse["expirationDate"]	:= QuoteFormataData(aResponse[nI]["expirationDate"])
			jAuxResponse["creationDate"] 	:= QuoteFormataData(aResponse[nI]["creationDate"])
			jAuxResponse["modelName"] 		:= aResponse[nI]["modelName"]
			jAuxResponse["quoteType"] 		:= aResponse[nI]["quoteType"]
			jAuxResponse["deleteIndicator"]	:= aResponse[nI]["deleteIndicator"]

			aAdd(aQuotesResponse, jAuxResponse)
		Next
		Return aQuotesResponse
	
	Endif

	cMsgErro   := jJsonManager["errorMessage"][1]
	self:cErro += STR0001 + cMsgErro + chr(13) + chr(10) //"Erro: "

Return aQuotesResponse

/*/{Protheus.doc} _GetQuoteDetailResponse()
	Processa resposta do metodo GetQuoteDetail
	
	@author  Daniel
	@since   30/07/2024
	@param	 jJsonManager, JSON resposta da requisição
	@version version
/*/
Method _GetQuoteDetailResponse(jJsonManager) Class VEJDQuoteRest
	Local jDetResponse := NIL
	Local jResponse 

	Local jCustomer
	Local aEquipments
	Local aTradeIns

	//Requisição ok, 
	If jJsonManager["type"] <> "ERROR"
		jResponse := jJsonManager["body"]

		jDetResponse := JsonObject():New()

		//detalhes gerais
		jDetResponse["quoteId"]				:=  jResponse["quoteId"]
		jDetResponse["quoteName"]			:=  DecodeUTF8(jResponse["quoteName"], "cp1252")
		jDetResponse["creationDate"]		:=  SToD(StrTran(jResponse["creationDate"], "-",""))
		jDetResponse["expirationDate"]		:=  SToD(StrTran(jResponse["expirationDate"], "-",""))
		jDetResponse["lastModifiedDate"]	:=  TimestampDate(jResponse["lastModifiedDate"])
		jDetResponse["lastModifiedHour"]	:=  TimestampHour(jResponse["lastModifiedDate"]) 
		jDetResponse["dealerAccountNumber"]	:=  jResponse["dealerAccountNumber"]
		jDetResponse["customerNote"]		:=  jResponse["customerNote"]
		jDetResponse["totalNetTradeValue"]	:=  jResponse["totalNetTradeValue"]
		jDetResponse["balanceDue"]			:=  jResponse["balanceDue"]
		jDetResponse["netProceeds"]			:=  jResponse["netProceeds"]
		
		//error message
		jerrorMessage := JsonObject():New()
		
		if ValType(jResponse["errorMessage"]) == "J" 
			jerrorMessage["errorId"]      := jResponse["errorMessage"]["errorId"]
			jerrorMessage["errorMessage"] := jResponse["errorMessage"]["errorMessage"]
		EndIf
		
		jDetResponse["errorMessage"] := jErrorMessage
		
		//quote status
		jQuoteStatus := JsonObject():New()
		jQuoteStatus["id"]		    := jResponse["quoteStatus"]["id"]
		jQuoteStatus["description"] := jResponse["quoteStatus"]["description"]
		jDetResponse["quoteStatus"] := jQuoteStatus
		
		//quote type
		jQuoteType := JsonObject():New()
		jQuoteType["quoteType"] := jResponse["quoteType"]["description"]
		jQuoteType["id"] := jResponse["quoteType"]["id"]
		jDetResponse["quoteType"] := jQuoteType
		
		//Purchase Order Details
		jPODetails := JsonObject():New()
		jPODetails["deliveredOn"]	  := jResponse["podetails"]["deliveredOn"]
		jPODetails["poStatus"]		  := jResponse["podetails"]["poStatus"]
		jPODetails["purchaserType"]	  := jResponse["podetails"]["purchaserType"]
		jPODetails["signedOnDate"]	  := jResponse["podetails"]["signedOnDate"]
		jPODetails["transactionType"] := jResponse["podetails"]["transactionType"]
		jPODetails["warrantyBegins"]  := jResponse["podetails"]["warrantyBegins"]
		
		if ! Empty(jResponse["podetails"]["poNumber"])
			jPODetails["poNumber"]		  := val(jResponse["podetails"]["poNumber"])
		Else
			jPODetails["poNumber"]		  := 0
		Endif
		
		jDetResponse["podetails"] := jPODetails
		
		//Sales Person Details
		jSalesPerson := JsonObject():New()
		jSalesPerson["deereUserId"]	 := jResponse["salesPerson"]["deereUserId"]
		jSalesPerson["emailAddress"] := jResponse["salesPerson"]["emailAddress"]
		jSalesPerson["firstName"]	 := jResponse["salesPerson"]["firstName"]
		jSalesPerson["middleName"]	 := jResponse["salesPerson"]["middleName"]
		jSalesPerson["lastName"]	 := jResponse["salesPerson"]["lastName"]
		jSalesPerson["fullName"]	 := DecodeUTF8(AllTrim(jSalesPerson["firstName"]) + " " + AllTrim(jSalesPerson["middleName"]) + " " + AllTrim(jSalesPerson["lastName"]), "cp1252" )
		jDetResponse["salesPerson"] := jSalesPerson

		//Parte de customer
		jCustomer := self:_getCustomer(jResponse) 
		jDetResponse["customer"] := JCustomer//Objet

		//Parte de equipments
		aEquipments := self:_getEquipmentsFromQuote(jResponse) //Lista
		jDetResponse["equipments"] := aEquipment

		//Parte de trade ins
		aTradeIns := self:_getTradeInsFromQuote(jResponse)	//Lista
		jDetResponse["tradeIns"] := aTradeIns

		Return jDetResponse
	EndIf
	
	//Pega mensagem de erro se der errado
	cMsgErro   := jJsonManager["errorMessage"][1]
	self:cErro += STR0001 + cMsgErro + chr(13) + chr(10) //"Erro: "

Return jDetResponse

/*/{Protheus.doc} _getCustomer()
	Extrai os dados do customer da cotação

	@author  Daniel
	@since   31/07/2024
	@param 	 jResponse, JSON com a resposta da requisição para extrair os dados
	@version version
/*/
Method _getCustomer(jResponse) Class VEJDQuoteRest
	Local jCustomer := JsonObject():New()

	Local jResponseCustomer := jResponse["customer"]

	jCustomer["entityId"]		   := jResponseCustomer["entityId"]
	jCustomer["firstName"]		   := DecodeUTF8(AllTrim(jResponseCustomer["firstName"]), "cp1252")
	jCustomer["lastName"]		   := DecodeUTF8(AllTrim(jResponseCustomer["lastName"]), "cp1252")
	jCustomer["phoneNumber"]	   := AllTrim(jResponseCustomer["phoneNumber"])
	jCustomer["businessName"]	   := AllTrim(jResponseCustomer["businessName"])
	jCustomer["taxID"]			   := AllTrim(jResponseCustomer["taxID"])
	jCustomer["dbsCustomerNumber"] := AllTrim(jResponseCustomer["dbsCustomerNumber"])

	//address
	jAddress := JsonObject():New()
	
	if valtype(jResponseCustomer["address"]) == "J"
		jAddress["addressLine1"] := Upper(AllTrim(jResponseCustomer["address"]["addressLine1"]))
		jAddress["addressLine2"] := Upper(AllTrim(jResponseCustomer["address"]["addressLine2"]))
		jAddress["city"]		 := AllTrim(jResponseCustomer["address"]["city"])
		jAddress["country"]		 := AllTrim(jResponseCustomer["address"]["country"])
		jAddress["county"]		 := AllTrim(jResponseCustomer["address"]["county"])
		jAddress["zip"]		 	 := AllTrim(jResponseCustomer["address"]["zip"])
		jAddress["state"]		 := AllTrim(jResponseCustomer["address"]["state"])
	EndIf

	jCustomer["address"] := jAddress

Return jCustomer

/*/{Protheus.doc} _getEquipmentsFromQuote()
	Extrai os dados do customer da cotação

	@author  Daniel
	@since   31/07/2024
	@param 	 jResponse, JSON com a resposta da requisição para extrair os dados
	@version version
/*/
Method _getEquipmentsFromQuote(jResponse) Class VEJDQuoteRest
	Local jAuxEquipments
	Local aEquipments := {}
	local nEquipment
	local nAdjustment

	Local aRespEqui := jResponse["equipments"]

	For nEquipment := 1 TO len(aRespEqui)	
		jAuxEquipments := JsonObject():New()
		jAuxEquipments["id"] 						 := aRespEqui[nEquipment]["id"]
		jAuxEquipments["listPrice"] 				 := aRespEqui[nEquipment]["listPrice"]
		jAuxEquipments["costPrice"] 				 := aRespEqui[nEquipment]["costPrice"]
		jAuxEquipments["totalEquipmentSellingPrice"] := aRespEqui[nEquipment]["totalEquipmentSellingPrice"]
		jAuxEquipments["dealerOrderNumber"] 		 := aRespEqui[nEquipment]["dealerOrderNumber"]
		jAuxEquipments["equipmentOrderNumber"] 		 := aRespEqui[nEquipment]["equipmentOrderNumber"]
		jAuxEquipments["dealerStockNumber"] 		 := aRespEqui[nEquipment]["dealerStockNumber"]
		jAuxEquipments["invoiceNumber"] 			 := aRespEqui[nEquipment]["invoiceNumber"]
		jAuxEquipments["machineHours"] 				 := aRespEqui[nEquipment]["machineHours"]
		jAuxEquipments["makeName"] 					 := aRespEqui[nEquipment]["makeName"]
		jAuxEquipments["modelName"] 				 := aRespEqui[nEquipment]["modelName"]
		jAuxEquipments["status"] 					 := aRespEqui[nEquipment]["status"]
		jAuxEquipments["categoryId"] 				 := aRespEqui[nEquipment]["categoryId"]
		jAuxEquipments["categoryDescription"] 		 := aRespEqui[nEquipment]["categoryDescription"]
		jAuxEquipments["subCategoryId"] 			 := aRespEqui[nEquipment]["subCategoryId"]
		jAuxEquipments["subCategoryDescription"]	 := aRespEqui[nEquipment]["subCategoryDescription"]
		jAuxEquipments["serialNumber"] 				 := aRespEqui[nEquipment]["serialNumber"]

		If ValType(aRespEqui[nEquipment]["adjustments"]) == "A"
			For nAdjustment := 1 to len(aRespEqui[nEquipment]["adjustments"])
				
				//adjustments
				jAdjustments := JsonObject():New()
				jAdjustments["costPrice"]	:= AllTrim(aRespEqui[nEquipment]["adjustments"][nAdjustment]["costPrice"])
				jAdjustments["description"]	:= AllTrim(aRespEqui[nEquipment]["adjustments"][nAdjustment]["description"])
				jAdjustments["listPrice"]	:= AllTrim(aRespEqui[nEquipment]["adjustments"][nAdjustment]["listPrice"])
				jAdjustments["id"]			:= AllTrim(aRespEqui[nEquipment]["adjustments"][nAdjustment]["id"])
				
				aAdd(aRespEqui[nEquipment]["adjustments"], jAdjustments)
			Next nAdjustment
		Endif

		aAdd(aEquipments, jAuxEquipments)	

	Next nEquipment

Return aEquipments

/*/{Protheus.doc} _getTradeInsFromQuote
	Pega Trade Ins da cotacao

	@author  Daniel
	@since   01/08/2024
	@param 	 jResponse, JSON com a resposta da requisição para extrair os dados
	@version version
/*/
Method _getTradeInsFromQuote(jResponse) Class VEJDQuoteRest
	Local jAuxTradeIns
	Local aTradeIns := {}
	Local nNumTradeIns

	aResponseTradeIns := jResponse["tradeIns"]

	For nNumTradeIns := 1 to len(aResponseTradeIns)
		jAuxTradeIns := JsonObject():New()
		jAuxTradeIns["id"]				    := aResponseTradeIns[nNumTradeIns]["id"]
		jAuxTradeIns["makeName"]			:= aResponseTradeIns[nNumTradeIns]["makeName"]
		jAuxTradeIns["modelName"]			:= aResponseTradeIns[nNumTradeIns]["modelName"]
		jAuxTradeIns["serialNumber"]		:= aResponseTradeIns[nNumTradeIns]["serialNumber"]
		jAuxTradeIns["description"]		    := aResponseTradeIns[nNumTradeIns]["description"]
		jAuxTradeIns["hourMeterReading"]	:= aResponseTradeIns[nNumTradeIns]["hourMeterReading"]
		jAuxTradeIns["tagNumber"]			:= aResponseTradeIns[nNumTradeIns]["tagNumber"]
		jAuxTradeIns["year"]				:= aResponseTradeIns[nNumTradeIns]["year"]
		jAuxTradeIns["netTradeValue"]		:= aResponseTradeIns[nNumTradeIns]["netTradeValue"]

		aAdd(aTradeIns, jAuxTradeIns)

	Next nNumTradeIns

Return aTradeIns

/*/{Protheus.doc} QuoteFormataData
	Formata retorna a data do formato MM-mes-AAAA (ex. 01-Aug-2024) para o formato MM/DD/AAAA
	
	@author  Daniel
	@since   01/08/2024
	@version version
/*/
Static Function QuoteFormataData(cData) 
	Local cMes := substr(cData,4,3)
	Do Case
		Case cMes == "Jan" ; cMes := "01"
		Case cMes == "Feb" ; cMes := "02"
		Case cMes == "Mar" ; cMes := "03"
		Case cMes == "Apr" ; cMes := "04"
		Case cMes == "May" ; cMes := "05"
		Case cMes == "Jun" ; cMes := "06"
		Case cMes == "Jul" ; cMes := "07"
		Case cMes == "Aug" ; cMes := "08"
		Case cMes == "Sep" ; cMes := "09"
		Case cMes == "Oct" ; cMes := "10"
		Case cMes == "Nov" ; cMes := "11"
		Otherwise ; cMes := "12"
	End Case
	cDia := substr(cData,1,2)
	cAno := substr(cData,8,4)
Return ctod(cDia+"/"+cMes+"/"+cAno)

/*/{Protheus.doc} TimestampDate
	Função que transforma timespamp milisegundos em data no formato MM/DD/AAAA

	@author  Daniel
	@since   02/08/2024
	@param   nTimestamp
	@version version
/*/
Static Function TimestampDate(nTimestamp)
    Local nSeconds
	Local dDate
    Local dEpoch

    // Define a época Unix como 01/01/1970
    dEpoch := StoD("19700101")

    // Converte timestamp de milissegundos para segundos
    nSeconds := nTimestamp / 1000

    // Calcula a data adicionando o número de segundos desde a época Unix
    dDate := dEpoch + (nSeconds / 86400)  // 86400 segundos em um dia

	dDataFormatada := StoD(StrZero(Year(dDate),4) + StrZero(Month(dDate),2) + StrZero(Day(dDate),2))

Return dDataFormatada

/*/{Protheus.doc} TimestampHour
	Pega a hora do dia do timestamp
	@author  Daniel
	@since   02/08/2024
	@param   nTimestamp
	@version version
/*/
Static Function TimestampHour(nTimestamp)
	Local aData := {}
	Local cHoraFormatada
    Local nSeconds
	Local dDate
    Local dEpoch

    // Define a época Unix como 01/01/1970
    dEpoch := StoD("19700101")

    // Converte timestamp de milissegundos para segundos
    nSeconds := nTimestamp / 1000

    // Calcula a data adicionando o número de segundos desde a época Unix
    dDate := dEpoch + (nSeconds / 86400)  // 86400 segundos em um dia	
	
	GetTimeStamp(dDate, aData)

	cHoraFormatada := Transform(aData[2]/*hora*/, "@R 999999")
Return cHoraFormatada
