#include 'totvs.ch'
#include 'OFCNHPrimWsConnect.ch'

Function OFCNH0015();Return

/*/{Protheus.doc} OFCNHPrimWsConnect 
	Classe quev ai servir de comunicador com o servidor webservice soap da cnh
	responsável por enviar, receber, consultar arquivos na fábrica.
	
	@type function 
	@author Vinicius Gati 
	@since 28/02/2018
/*/ 
Class OFCNHPrimWsConnect from OFCNHPrimWs
	Data cEnd
	Data cEndWsdl
	Data cActCon
	Data cActDescon
	Data cActRenew
	Data oUsuario
	Data oConfig

	Data cTicket
	Data cServiceId
	Data cCurrentPass
	Data lConectado


	Method New() CONSTRUCTOR
	Method Connect()
	Method Renew()
	Method ColetaDadosRetorno()
	Method setUser()
	Method setEnvironment()
EndClass 

/*/{Protheus.doc} New
		Construtor Simples

	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method New(oUsu) Class OFCNHPrimWsConnect
	_Super:New()
	::cEnd           := 'https://stg-ccon.cnh.com/ccon/cconWsConnect.php'
	::cActCon        := 'cconConnect'
	::cActDescon     := 'cconConnectPwd'
	::cActRenew      := 'cconDisconnect'
	::oUsuario       := oUsu
	::lConectado     := .F.
	::oConfig        := OFCNHPrimConfig():New(.T.)

	self:setEnvironment( ::oConfig:oConfig["AMBIENTE"] )

Return SELF

/*/{Protheus.doc} Connect
	Metodo Connect que faz a coneccao e retorna um token
	
	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method Connect() Class OFCNHPrimWsConnect
local cXml    := ''
local cMsg

	cXml += "<urn:cconConnect soapenv:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
	cXml += 	"<User xsi:type='xsd:string'>"+::oConfig:cUser+"</User>"
	cXml += 	"<Password xsi:type='xsd:string'>"+::oConfig:cPass+"</Password>"
	cXml += 	"<CertificationSystem xsi:type='xsd:string'>CNH</CertificationSystem>"
	cXml += "</urn:cconConnect>"
	if self:Enviar(self:cActCon, cXml)
		self:ColetaDadosRetorno()
		if self:cCodeRet == '0'
			self:lConectado := .T.
			return .T.
		elseif self:cCodeRet == "-1"	// usuário bloqueado
			cMsg := STR0001+::oConfig:cUser+"]" + CRLF	//#"Usuário bloqueado ["
			cMsg += STR0002		//#"favor contatar suporte PRIM e solicitar o desbloqueio"
			OA060004C_log( "PRIM" /*cAgroup*/, "CONNECT" /*cTipo*/, cMsg /*cDados*/, .T. )
		elseif self:cCodeRet == "-2"
			return ::Renew()
		endif
	else
		return .F.
	endif
Return .F.

/*/{Protheus.doc} Renew
	Metodo Renew 

	@type function
	@author Vinicius Gati
	@since 28/02/2018
/*/
Method Renew() Class OFCNHPrimWsConnect
local cXml    := ''
local lChange := .F.
local nI
local cMsg    := STR0003	//#"Renew Password - "

	cXml += "<urn:cconConnectPwd soapenv:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>"
	cXml += 	"<User xsi:type='xsd:string'>"+::oConfig:cUSER+"</User>"
	cXml += 	"<Password xsi:type='xsd:string'>"+::oConfig:cPASS+"</Password>"
	cXml += 	"<CertificationSystem xsi:type='xsd:string'>CNH</CertificationSystem>"
	cXml += "</urn:cconConnectPwd>"
	if self:Enviar(self:cActRenew, cXml)
		self:ColetaDadosRetorno()
		if self:cCodeRet == '0'
			cMsg += STR0004 + CRLF + STR0005 +": ["+ self:cCurrentPass + "]" + CRLF	//#"SUCESSO"	#Nova Senha
			lChange         := .T.
			self:lConectado := .T.
			::oConfig:cPASS := self:cCurrentPass

			for nI := 1 to len( ::oConfig:oConfig["SENHAS"] )
				if alltrim(::oConfig:oConfig["SENHAS"][nI]["DEALERCODE"]) == alltrim(::oConfig:cDealerCode)
					::oConfig:oConfig["SENHAS"][nI]["SENHA"] := self:cCurrentPass
					exit
				endif
			next

			::oConfig:saveConfig(::oConfig:oConfig)
		endif
	endif

	OA060004C_log( "PRIM" /*cAgroup*/, STR0006 /*cTipo*/, cMsg /*cDados*/, .T. )	//#"RENEW PASSWORD"

Return lChange


/*/{Protheus.doc} ColetaDadosRetorno
	vai pegar os dados do xml retornado

	@type function
	@author Vinicius Gati
	@since 06/03/2018
/*/
Method ColetaDadosRetorno(oXml) Class OFCNHPrimWsConnect
	oXml := TXmlManager():New()
	xRet := oXml:Parse( self:cLastResponse )
	if xRet == .F.
		self:cError := oXML:Error()
		return .f.
	endif
	oXml:DOMChildNode()
	oXml:DOMChildNode()
	oXml:DOMChildNode()
	if lower(oXml:cName) == "ticket"
		self:cTicket := oXml:cText
	endif
	do while oXml:DomNextNode()
		if lower(oXml:cName) == "serviceid"
			self:cServiceId := oXml:cText
		elseif lower(oXml:cName) == "return"
			self:cCodeRet := oXml:cText
		elseif lower(oXml:cName) == 'currentpassword'
			self:cCurrentPass := oXml:cText
		endif
	end do
Return


/*/{Protheus.doc} setUser
Atualiza usuário e senha de conexão
@type function
@author Cristiam Rossi
@since 11/02/2025
/*/
Method setUser( cUser, cPassword ) class OFCNHPrimWsConnect
	if ! empty( cUser ) .and. ! empty( cPassword )
		::oConfig:cUSER := alltrim( cUser )
		::oConfig:cPASS := alltrim( cPassword )
	endif
return nil


/*/{Protheus.doc} setEnvironment
Atualiza URL de conexão do ambiente
@type function
@author Cristiam Rossi
@since 21/02/2025
/*/
Method setEnvironment( cEnvironment ) class OFCNHPrimWsConnect
	if cEnvironment == "TEST"
		::cEndWsdl   := 'http://itmil.com.br/stg_cnh_connect.wsdl'
	else
		::cEndWsdl   := 'http://itmil.com.br/cnh_connect.wsdl'
	endif
return nil
