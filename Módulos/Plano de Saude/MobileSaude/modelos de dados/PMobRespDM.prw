#INCLUDE 'totvs.ch'

Class PMobRespDM 
	Data StatusCode
	Data Status
	Data Message
	Data Alert
	Data ReceivedData
	Data ResponseData
	Data lDisableReason

	Method New() CONSTRUCTOR

	Method SetStatusCode(nCode)
	Method SetStatusResponse(lStatus)	
	Method SetMessageResponse(cMessage)
	Method SetAlertResponse(cAlert)		
	Method SetDataResponse(oData)		
	Method SetResponse() 
	Method DisableReason()

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method New() Class PMobRespDM

	self:StatusCode	:= 0
	self:Status	:= ""
	self:Message := ""
	self:Alert := ""
	self:ReceivedData := JsonObject():New()
	self:ResponseData := JsonObject():New() 
	self:lDisableReason := .F.

	// Inicializa o objeto que irá receber o modelo de dados de retorno do EndPoint
	self:ReceivedData['receivedData'] := {}

Return self


//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatusCode

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetStatusCode(nCode) Class PMobRespDM
	self:StatusCode := nCode
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatusResponse

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetStatusResponse(lStatus) Class PMobRespDM
	self:Status := lStatus
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetMessageResponse

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetMessageResponse(cMessage) Class PMobRespDM
	self:Message := cMessage
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetAlertResponse

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetAlertResponse(cAlert) Class PMobRespDM
	self:Alert := cAlert
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetDataResponse

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetDataResponse(oData) Class PMobRespDM
	Local nLen := 0
	// Prepara a lista pra receber o modelo de dados enviado pelo EndPoint
	Aadd(self:ReceivedData['receivedData'], jSonObject():New())
	nLen := Len(self:ReceivedData['receivedData'])

	// Registra o dado enviado pelo EndPoint
	self:ReceivedData['receivedData'][nLen] := oData	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SetResponse

@author  Geraldo (Mobile Saude) / Sakai
@version P12
@since   03/06/2020
/*/
//------------------------------------------------------------------- 
Method SetResponse() Class PMobRespDM
	Local nCnt 	:= 0
	Local nI	:= 0
	Local aModel := {}

	// DEFINE o modelo de dados 
	self:ResponseData["status"] 			:= self:Status
	//self:ResponseData["timestamp"]			:= StrTran(FWTimeStamp(5), 'T', ' ') // YYYY-MM-DD HH:MM:SS-03:00

	If (!Empty(self:Message) .or. !self:Status) .And. !Self:lDisableReason
		self:ResponseData["motivoCritica"] 		:= self:Message
	Endif

	// A estrutura de alerta não existe em todos os modelos. 
	If !Empty(self:Alert)
		self:ResponseData["alerta"] 			:= self:Alert
	Endif

	// A definição do código de retorno não é obrigatória. 
	If self:StatusCode > 0
		self:oSuperClass:SetStatus( self:StatusCode )
	Endif

	// Adiciona o modelo de dados do EndPoint ao retorno da requisição
	If ValType(self:ReceivedData) != "U"
		For nCnt := 1 to len(self:ReceivedData['receivedData'])
			aModel := self:ReceivedData['receivedData'][nCnt]:GetNames()
			If Len(aModel) > 0
				For nI := 1 to Len(aModel)
					self:ResponseData[aModel[nI]] := self:ReceivedData['receivedData'][nCnt]:GetJsonObject(aModel[nI])
				Next
			Endif
		Next
	Endif

Return FWJsonSerialize( self:ResponseData )


//-------------------------------------------------------------------
/*/{Protheus.doc} DisableReason
Desabilita tag de motivoCritica do retorno de error do JSON

@author Vinicius Queiros Teixeira
@version Protheus 12
@since 10/03/2022
/*/
//------------------------------------------------------------------- 
Method DisableReason() Class PMobRespDM
	Self:lDisableReason := .T.
Return
