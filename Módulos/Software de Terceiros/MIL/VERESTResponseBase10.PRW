#include 'protheus.ch'

/*/{Protheus.doc} VERESTResponseBase10
	Classe representativa de uma resposta para api json versao 1.0

	GET format default response model:

	{
	  hasNext: true,
	  items: [
	    {},
	    {},
	    ...
	  ],
	  _messages: [{
	    code: "INFO",
	    message: "some info message.",
	    detailedMessage: "details about the info message."
	  }]
	}
	
	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Class VERESTResponseBase10
	public data nCode
	public data cMessage
	public data cDetailedMessage

	public data n200
	public data n201
	public data n400
	public data n401
	public data n403
	public data n404
	public data n500
	public data n204
	public data n205

	Method New() CONSTRUCTOR
	Method GetObject()
	Method GetMessage()
	Method ToJson()
	Method _Validate()
EndClass

/*/{Protheus.doc} New
	Construtor que obriga certos dados para evitar que um erro fique fora do padrao no webservice

	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Method New(nCode, cMessage) Class VERESTResponseBase10
	::n200  := 200
	::n201  := 201
	::n204  := 204
	::n205  := 205
	::n400  := 400
	::n401  := 401
	::n403  := 403
	::n404  := 404
	::n500  := 500
	::nCode := nCode
	::cMessage := cMessage
	::cDetailedMessage := ''
Return SELF

/*/{Protheus.doc} GetMessage
	Retorna mensagem padrao para codigo

	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Method GetMessage() Class VERESTResponseBase10
	if ! Empty(self:cMessage)
		return self:cMessage
	endif
	DO CASE
	  CASE self:nCode == self:n200
			return 'success'
		CASE self:nCode == self:n201
			return 'created'
		CASE self:nCode == self:n204
			return 'no content'
		CASE self:nCode == self:n205
			return 'reset content'
		CASE self:nCode == self:n400
			return 'bad request'
		CASE self:nCode == self:n401
			return 'unauthorized'
		CASE self:nCode == self:n403
			return 'forbidden'
		CASE self:nCode == self:n404
			return 'not found'
		CASE self:nCode == self:n500
			return 'internal server error'
	ENDCASE
Return 'VERESTResponseBase10 usada incorretamente, validação falhou no GetMessage'

/*/{Protheus.doc} GetObject
	Retorna o objeto json

	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Method GetObject() Class VERESTResponseBase10
	local oResp := JsonObject():New()
	if self:_Validate()
		oResp['code'] := self:nCode
		oResp['message'] := self:GetMessage()
		oResp['detailedMessage'] := self:cDetailedMessage
	else
		oResp['code'] := self:n500
		oResp['message'] := 'VERESTResponseBase10 usada incorretamente, validação falhou'
		oResp['detailedMessage'] := 'Please call you software provider.'
	endif
Return oResp

/*/{Protheus.doc} ToJson
	Retorna o padrao de erro

	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Method ToJson() Class VERESTResponseBase10
Return self:GetObject():ToJson()

/*/{Protheus.doc} _Validate
	Valida se o erro está nos esperados padroes da versao 1.0

	@type function
	@author Vinicius Gati
	@since 26/08/2019
/*/
Method _Validate() Class VERESTResponseBase10
	DO CASE
	  CASE self:nCode == self:n200
			return .t.
		CASE self:nCode == self:n201
			return .t.
		Case self:nCode == self:n204
			return .t.
		Case self:nCode == self:n205
			return .t.
		CASE self:nCode == self:n400
			return .t.
		CASE self:nCode == self:n401
			return .t.
		CASE self:nCode == self:n403
			return .t.
		CASE self:nCode == self:n404
			return .t.
		CASE self:nCode == self:n500
			return .t.
	ENDCASE
Return .f.
