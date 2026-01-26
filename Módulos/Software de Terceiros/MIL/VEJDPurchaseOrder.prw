#INCLUDE "TOTVS.CH"
#INCLUDE "VEJDPURCHASEORDER.CH"

/*/{Protheus.doc} VEJDPurchaseOrder
	Classe Purchase Order para fazer integração com API JDQuote2 John Deere

	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Class VEJDPurchaseOrder
	Data cToken
	
	Data oCfgAuth AS OBJECT

	Data cFABUSR
	Data cErro

	Method New()
	Method Authenticate()

	Method _GetBaseUrl()
	Method _SetHeader()

	Method GetPODetailByQuoteID()
	Method GetPOPdf()

	Method _GetPurchaseOrderResponse()
	Method _GetRevisions()
	Method _GetPOEquipments()

	Method _GetPOPdfResponse()

EndClass

/*/{Protheus.doc} New
	Construtor Simples

	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Method New() Class VEJDPurchaseOrder
	self:cErro := ""

	// Pega Usuário X
	VAI->(DBSetOrder(4))
	VAI->(MSSeek(xFilial('VAI')+ __cUserID))
	VAI->(DBSetOrder(1))
	self:cFABUSR := Upper(AllTrim(VAI->VAI_FABUSR)) //:= self:_getFabUser
	
	self:oCfgAuth := VEJDQuoteRestAuth():New()
	self:oCfgAuth:GetConfig()
	self:oCfgAuth:SetPurchaseOrderRest()
Return

/*/{Protheus.doc} Authenticate
	Faz a autenticação do usuário

	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Method Authenticate() Class VEJDPurchaseOrder
	self:cToken := self:oCfgAuth:getToken()
	
	If Empty(self:cToken)
		self:cErro := self:oCfgAuth:cErro
		Return .f.
	EndIf
Return .t.

/*/{Protheus.doc} _GetBaseUrl
	Pega a Base URL do Webservice para fazer o request

	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Method _GetBaseUrl() class VEJDPurchaseOrder
Return self:oCfgAuth:GetURL("QTP")

/*/{Protheus.doc} _SetHeader
	Define o Header da requisição

	@author  Daniel
	@since   29/07/2024
	@param	 lContentType, lógico, define se adiciona o content_type
	@version version
/*/
Method _SetHeader(lContentType) class VEJDPurchaseOrder
	Local aHeadStr := {}
	
	If lContentType
		aAdd(aHeadStr, "Content-Type: application/json")
	EndIf

	// Adiciona token de autenticação no header
	aAdd(aHeadStr, "Authorization: Bearer " + self:cToken)
		
Return aHeadStr

/*/{Protheus.doc} GetPODetailByQuoteID
	description
	
	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Method GetPODetailByQuoteID(nQuoteId) Class VEJDPurchaseOrder
	Local lContentType := .f.
	Local aPODetail := {}
	Local cHeadGet  := ""
	Local cBaseURL  := ""
	Local cResponse := ""
	Local jJsonManager := JsonObject():New()

	If self:Authenticate()

		cBaseURL := self:_GetBaseUrl()
		aHeadStr := self:_SetHeader(lContentType)

		cResponse := HttpGet(cBaseURL + "/quotes/" + cValToChar(nQuoteId) + "/dealers/" + self:cFABUSR, , 60, aHeadStr, @cHeadGet)
		jJsonManager:FromJson(cResponse)
		
		aPODetail := self:_GetPurchaseOrderResponse(jJsonManager)
	EndIf
Return aPODetail

/*/{Protheus.doc} GetPOPdf
	Metodo executado para pegar o POPDF

	@author  Daniel
	@since   29/07/2024
	@version version
/*/
Method GetPOPdf(nQuoteId) Class VEJDPurchaseOrder
	Local lContentType := .f.
	Local aPOPdf := {}
	Local jAuxPOPdf
	Local cHeadGet  := ""
	Local cBaseURL  := ""
	Local cResponse := ""
	Local jJsonManager := JsonObject():New()

	If self:Authenticate()

		cBaseURL := self:_GetBaseUrl()
		aHeadStr := self:_SetHeader(lContentType)

		cResponse := HttpGet(cBaseURL + "/quotes/" + cValToChar(nQuoteId) + "/po-pdf", , 60, aHeadStr, @cHeadGet)
		jJsonManager:FromJson(cResponse)
		
		jAuxPOPdf := self:_GetPOPdfResponse(jJsonManager)

		AADD(aPOPdf, jAuxPOPdf)
	EndIf
Return aPOPdf

/*/{Protheus.doc} _GetPurchaseOrderResponse
	Processa resposta da requisição PO Detail by ID
	
	@author  Daniel
	@since   08/08/2024
	@param 	 jJsonManager
	@version version
/*/
Method _GetPurchaseOrderResponse(jJsonManager) Class VEJDPurchaseOrder
	Local aPODetailResponse := {}
	Local aResponse := {}
	Local aRevisions := {}
	Local jAuxResponse
	Local cStatusErro
	Local cMsgErro

	self:cErro := ""

	If jJsonManager:hasProperty("statusCode") .and. jJsonManager["statusCode"] > 299
		cStatusErro := cValToChar(jJsonManager["statusCode"])
		cMsgErro   := jJsonManager["message"]
		self:cErro += STR0001 + cStatusErro + ". " + cMsgErro + chr(13) + chr(10) // "Erro: "
		return NIL
	endif
	
	If jJsonManager["type"] <> "ERROR"
		aResponse := jJsonManager["body"]

		jAuxResponse := JsonObject():New()
		jAuxResponse["poNumber"] := aResponse["poNumber"]

		aRevisions := self:_GetRevisions(aResponse["revisions"])
		jAuxResponse["revisions"] := aRevisions

		aAdd(aPODetailResponse, jAuxResponse)
	
		Return aPODetailResponse
	Endif

	//Comunicação OK, retorna erro podendo ser relacionado a dealer, criterio de pesquisa...
	cMsgErro   := jJsonManager["errorMessage"][1]
	self:cErro += STR0001 + cMsgErro + chr(13) + chr(10) //"Erro: "

Return aPODetailResponse

/*/{Protheus.doc} _GetRevisions
	Processa revisions do Purchase Order Detail
	
	@author  Daniel
	@since   07/08/2024
	@version version
/*/
Method _GetRevisions(aRevisions) Class VEJDPurchaseOrder
	Local aRetRevisions  := {}
	Local aAuxRevision := {}
	Local aEquipments := {}

	Local jAuxRevisions
	Local jErrorMessage
	Local nRevision
	Local cPdfData

	For nRevision := 1 to len(aRevisions)

		jAuxRevisions := JsonObject():New()
		
		
		cPdfData := aRevisions[nRevision]["pdfData"]
		If !Empty(cPdfData)
			cPdfData := Decode64( cPdfData)
			jAuxRevisions["pdfData"] := cPdfData
		EndIf
		
		aAuxRevision := aRevisions[nRevision]

		jAuxRevisions["orderDate"]     := TimestampDate(aAuxRevision["orderDate"])
		jAuxRevisions["internalNotes"] := aAuxRevision["internalNotes"]
		jAuxRevisions["signedOnDate"]  := aAuxRevision["signedOnDate"]
		jAuxRevisions["status"]        := aAuxRevision["status"]

		Do Case
			Case aAuxRevision["errorMessage"] == NIL
				aEquipments := self:_GetPOEquipments(aAuxRevision["equipments"])
				jAuxRevisions["equipments"] := aEquipments
			OtherWise
				jErrorMessage := JsonObject():New()

				jErrorMessage["errorMessage"] := aAuxRevision["errorMessage"]["errorId"]
				jErrorMessage["errorMessage"] := aAuxRevision["errorMessage"]["errorMessage"]
				
				jAuxRevisions["errorMessage"] := jErrorMessage
		EndCase
		aAdd(aRetRevisions, jAuxRevisions)		
	Next nI
Return aRetRevisions

/*/{Protheus.doc} _GetPOEquipments
	Processa equipments do Purchase Order Detail

	@author  Daniel
	@since   07/08/2024
	@version version
/*/
Method _GetPOEquipments(aEquipments) Class VEJDPurchaseOrder
	Local aRetEquipments := {}
	Local aStandardOptions := {}
	Local jEquipments
	Local jStdOptions
	Local nEquipment
	Local nStdOptions

	For nEquipment := 1 to len(aEquipments)
		
		aAuxEquipment := aEquipments[nEquipment]

		jEquipments := JsonObject():New()
		jEquipments["finalSellingPrice"] := aAuxEquipment["finalSellingPrice"]
		jEquipments["serialNumber"]      := aAuxEquipment["serialNumber"]
		jEquipments["prodDescription"]   := aAuxEquipment["prodDescription"]
		jEquipments["status"]            := aAuxEquipment["status"]
		jEquipments["makeName"]          := aAuxEquipment["makeName"]
		jEquipments["modelName"]         := aAuxEquipment["modelName"]
		jEquipments["hourMeterReading"]  := aAuxEquipment["hourMeterReading"]

		For nStdOptions := 1 to len(aAuxEquipment["standardOptions"])

			aAuxStdOptions := aAuxEquipment["standardOptions"][nStdOptions]
			
			jStdOptions := JsonObject():New()
			jStdOptions["code"]                  := aAuxStdOptions["code"]
			jStdOptions["description"]           := aAuxStdOptions["description"]
			jStdOptions["quantity"]              := aAuxStdOptions["quantity"]
			jStdOptions["extendedDiscountPrice"] := aAuxStdOptions["extendedDiscountPrice"]

			aAdd(aStandardOptions, jStdOptions)
		Next nStdOptions	

		jEquipments["standardOptions"] := aStandardOptions

		aAdd(aRetEquipments, jEquipments)
	Next nEquipment
Return aRetEquipments

/*/{Protheus.doc} _GetPOPdfResponse()
	Processa resposta do Purchase Order PDF

	@author  Daniel
	@since   07/08/2024
	@param   jJsonManager
	@version version
/*/
Method _GetPOPdfResponse(jJsonManager) Class VEJDPurchaseOrder
	Local jPdfResponse := NIL
	Local jAuxResponse
	Local cPdfData
	Local cStatusErro
	Local cMsgErro
	
	self:cErro := ""

	If jJsonManager:hasProperty("statusCode") .and. jJsonManager["statusCode"] > 299
		cStatusErro := cValToChar(jJsonManager["statusCode"])
		cMsgErro   := jJsonManager["message"]
		self:cErro += STR0001 + cStatusErro + ". " + cMsgErro + chr(13) + chr(10) // "Erro: "
		Return nil
	Endif	

	
	If jJsonManager["type"] <> "ERROR"
		jAuxResponse := jJsonManager["body"]["pdf"]
		
		jPdfResponse := JsonObject():New()

		cPdfData := jAuxResponse["value"]
		If !Empty(cPdfData)
			cPdfData := Decode64( cPdfData)
			jPdfResponse["pdf"] := cPdfData
		EndIf
		
		Return jPdfResponse
	Endif

	cMsgErro := jJsonManager["errorMessage"][1]
	self:cErro += STR0001 + cMsgErro + chr(13) + chr(10) //"Erro: "

Return jPdfResponse

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