#include 'totvs.ch'
#include 'OFCNHPrimWs.ch'

Function OFCNH0017();Return

/*/{Protheus.doc} OFCNHPrimWs
	Classe para encapsulamento de funcionalidades de webservice
	
	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/ 
Class OFCNHPrimWs
	Data cEnd
	Data cEndWsdl
	Data aRets
	Data oWsdl
	Data cLastResponse
	Data cLastToken
	Data cError
	Data cCertification
	Data cApplication
	Data cCodeRet
	Data oLogger

	Method New() CONSTRUCTOR
	Method Enviar()
	Method Envelopa()
EndClass 

/*/{Protheus.doc} New
	Construtor Simples

	@type function
	@author Vinicius Gati
	@since 05/03/2018
/*/
Method New() Class OFCNHPrimWs
	::aRets := {;
		{ 0, 'Ok'                },;
		{-1, STR0001 },;	//#'Usuário bloqueado'
		{-2, STR0002 },;	//#'Senha expirada'
		{72, STR0003} ;		//#'Arquivo já enviado'
	}
	::cLastToken        := ''
	::cCertification    := 'CNH'
	::cApplication      := 'PRIM'
	::oLogger           := DMS_Logger():New("WSCOMM_"+DTOS(dDatabase)+".LOG")
Return SELF 

/*/{Protheus.doc} Envelopa
	Evnelopa o conteudo de acordo com o soap server
	
	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method Envelopa(cContent) Class OFCNHPrimWs
local cEnvelope := ''

	cEnvelope += "<soapenv:Envelope"
	cEnvelope += " xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'"
	cEnvelope += " xmlns:xsd='http://www.w3.org/2001/XMLSchema'"
	cEnvelope += " xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'"
	cEnvelope += " xmlns:urn='urn:ccon'>"

	cEnvelope += "<soapenv:Header />"
	cEnvelope += "<soapenv:Body>"
	cEnvelope += cContent
	cEnvelope += "</soapenv:Body>"
	cEnvelope += "</soapenv:Envelope>"
Return cEnvelope

/*/{Protheus.doc} Enviar
	Envia o pacote e transforma o retorno de acordo

	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method Enviar(cOperation, cContent) Class OFCNHPrimWs
local cMsg := self:Envelopa(cContent)

	conout(" . " + cOperation)

	if type("lDebug") == "L" .and. lDebug
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += "     "+STR0004 + cOperation + CRLF		//#Enviar - Operação: "
		cMsgLog += "------------------------------------------" + CRLF
		cMsgLog += STR0005 + CRLF	//#"Request:"
		cMsgLog += OA060006C_prettyXML(cContent) + CRLF + CRLF
	endif

	self:oWsdl := TWsdlManager():New()
	self:oWsdl:lSSLInsecure := .T.
	self:oWsdl:nTimeout     := 60
	self:oWsdl:lVerbose := .F.
	self:cLastResponse := ""

	lRet := self:oWsdl:ParseURL(self:cEndWsdl)
	lRet := self:oWsdl:SetOperation(cOperation)
	If lRet == .F.
		self:cError := STR0006+self:oWsdl:cError	//#"Falha set operação. Erro: "
		self:oLogger:Log({'TIMESTAMP', STR0007, STR0006+self:oWsdl:cError})	//#Falha	#"Falha set operação. Erro: "
		if type("lDebug") == "L" .and. lDebug
			cMsgLog += STR0008 + CRLF	//#"Retorno: ERRO"
			cMsgLog += OA060006C_prettyXML(self:cError) + CRLF + CRLF
		endif
		return .f.
	EndIf
	lRet := self:oWsdl:SendSoapMsg( cMsg )
	If lRet == .F.
		self:cError := STR0009 + self:oWsdl:cFaultCode		//#'Falha ao comunicar: '
		conout(self:cError)
		if type("lDebug") == "L" .and. lDebug
			cMsgLog += STR0008 + CRLF	//#"Retorno: ERRO"
			cMsgLog += OA060006C_prettyXML(self:cError) + CRLF + CRLF
		endif
		if '<html' $ lower(self:cError) .OR. "couldn't connect to server" $ lower(self:cError)
			return .f.
		endif
	EndIf

	self:cLastResponse := self:oWsdl:GetSoapResponse()
	if type("lDebug") == "L" .and. lDebug
		cMsgLog += STR0010 + CRLF	//#"Retorno:"
		cMsgLog += OA060006C_prettyXML(self:cLastResponse) + CRLF + CRLF
	endif
Return .t.
