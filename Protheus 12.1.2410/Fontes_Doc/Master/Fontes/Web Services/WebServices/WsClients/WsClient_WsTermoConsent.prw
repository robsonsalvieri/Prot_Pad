#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8090/ws/TERMOCONSENT.apw?WSDL
Gerado em        03/18/20 10:00:54
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _ATJSSKJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTERMOCONSENT
------------------------------------------------------------------------------- */

WSCLIENT WSTERMOCONSENT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETCANDIDATE
	WSMETHOD GETCURRENTACCEPT
	WSMETHOD GETCURRENTTERM
	WSMETHOD GETMINORACCEPT
	WSMETHOD PUTACEITE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCPF                      AS string
	WSDATA   cGETCANDIDATERESULT       AS string
	WSDATA   oWSCURRENTTERM            AS TERMOCONSENT_TCURRENTTERM
	WSDATA   cORIGIN                   AS string
	WSDATA   cUSERID                   AS string
	WSDATA   lGETCURRENTACCEPTRESULT   AS boolean
	WSDATA   oWSGETCURRENTTERMRESULT   AS TERMOCONSENT_TCURRENTTERM
	WSDATA   oWSGETMINORACCEPTRESULT   AS TERMOCONSENT_TACCEPTRESP
	WSDATA   lPUTACEITERESULT          AS boolean

	// Estruturas mantidas por compatibilidade - N�O USAR
	WSDATA   oWSTCURRENTTERM           AS TERMOCONSENT_TCURRENTTERM

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTERMOCONSENT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20200114] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTERMOCONSENT
	::oWSCURRENTTERM     := TERMOCONSENT_TCURRENTTERM():New()
	::oWSGETCURRENTTERMRESULT := TERMOCONSENT_TCURRENTTERM():New()
	::oWSGETMINORACCEPTRESULT := TERMOCONSENT_TACCEPTRESP():New()

	// Estruturas mantidas por compatibilidade - N�O USAR
	::oWSTCURRENTTERM    := ::oWSCURRENTTERM
Return

WSMETHOD RESET WSCLIENT WSTERMOCONSENT
	::cCPF               := NIL 
	::cGETCANDIDATERESULT := NIL 
	::oWSCURRENTTERM     := NIL 
	::cORIGIN            := NIL 
	::cUSERID            := NIL 
	::lGETCURRENTACCEPTRESULT := NIL 
	::oWSGETCURRENTTERMRESULT := NIL 
	::oWSGETMINORACCEPTRESULT := NIL 
	::lPUTACEITERESULT   := NIL 

	// Estruturas mantidas por compatibilidade - N�O USAR
	::oWSTCURRENTTERM    := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTERMOCONSENT
Local oClone := WSTERMOCONSENT():New()
	oClone:_URL          := ::_URL 
	oClone:cCPF          := ::cCPF
	oClone:cGETCANDIDATERESULT := ::cGETCANDIDATERESULT
	oClone:oWSCURRENTTERM :=  IIF(::oWSCURRENTTERM = NIL , NIL ,::oWSCURRENTTERM:Clone() )
	oClone:cORIGIN       := ::cORIGIN
	oClone:cUSERID       := ::cUSERID
	oClone:lGETCURRENTACCEPTRESULT := ::lGETCURRENTACCEPTRESULT
	oClone:oWSGETCURRENTTERMRESULT :=  IIF(::oWSGETCURRENTTERMRESULT = NIL , NIL ,::oWSGETCURRENTTERMRESULT:Clone() )
	oClone:oWSGETMINORACCEPTRESULT :=  IIF(::oWSGETMINORACCEPTRESULT = NIL , NIL ,::oWSGETMINORACCEPTRESULT:Clone() )
	oClone:lPUTACEITERESULT := ::lPUTACEITERESULT

	// Estruturas mantidas por compatibilidade - N�O USAR
	oClone:oWSTCURRENTTERM := oClone:oWSCURRENTTERM
Return oClone

// WSDL Method GETCANDIDATE of Service WSTERMOCONSENT

WSMETHOD GETCANDIDATE WSSEND cCPF WSRECEIVE cGETCANDIDATERESULT WSCLIENT WSTERMOCONSENT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCANDIDATE xmlns="http://localhost:8090/">'
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETCANDIDATE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8090/GETCANDIDATE",; 
	"DOCUMENT","http://localhost:8090/",,"1.031217",; 
	"http://localhost:8090/ws/TERMOCONSENT.apw")

::Init()
::cGETCANDIDATERESULT :=  WSAdvValue( oXmlRet,"_GETCANDIDATERESPONSE:_GETCANDIDATERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCURRENTACCEPT of Service WSTERMOCONSENT

WSMETHOD GETCURRENTACCEPT WSSEND oWSCURRENTTERM,cORIGIN,cUSERID WSRECEIVE lGETCURRENTACCEPTRESULT WSCLIENT WSTERMOCONSENT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCURRENTACCEPT xmlns="http://localhost:8090/">'
cSoap += WSSoapValue("CURRENTTERM", ::oWSCURRENTTERM, oWSCURRENTTERM , "TCURRENTTERM", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ORIGIN", ::cORIGIN, cORIGIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("USERID", ::cUSERID, cUSERID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETCURRENTACCEPT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8090/GETCURRENTACCEPT",; 
	"DOCUMENT","http://localhost:8090/",,"1.031217",; 
	"http://localhost:8090/ws/TERMOCONSENT.apw")

::Init()
::lGETCURRENTACCEPTRESULT :=  WSAdvValue( oXmlRet,"_GETCURRENTACCEPTRESPONSE:_GETCURRENTACCEPTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCURRENTTERM of Service WSTERMOCONSENT

WSMETHOD GETCURRENTTERM WSSEND NULLPARAM WSRECEIVE oWSGETCURRENTTERMRESULT WSCLIENT WSTERMOCONSENT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCURRENTTERM xmlns="http://localhost:8090/">'
cSoap += "</GETCURRENTTERM>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8090/GETCURRENTTERM",; 
	"DOCUMENT","http://localhost:8090/",,"1.031217",; 
	"http://localhost:8090/ws/TERMOCONSENT.apw")

::Init()
::oWSGETCURRENTTERMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCURRENTTERMRESPONSE:_GETCURRENTTERMRESULT","TCURRENTTERM",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETMINORACCEPT of Service WSTERMOCONSENT

WSMETHOD GETMINORACCEPT WSSEND cUSERID WSRECEIVE oWSGETMINORACCEPTRESULT WSCLIENT WSTERMOCONSENT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMINORACCEPT xmlns="http://localhost:8090/">'
cSoap += WSSoapValue("USERID", ::cUSERID, cUSERID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETMINORACCEPT>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8090/GETMINORACCEPT",; 
	"DOCUMENT","http://localhost:8090/",,"1.031217",; 
	"http://localhost:8090/ws/TERMOCONSENT.apw")

::Init()
::oWSGETMINORACCEPTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETMINORACCEPTRESPONSE:_GETMINORACCEPTRESULT","TACCEPTRESP",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTACEITE of Service WSTERMOCONSENT

WSMETHOD PUTACEITE WSSEND oWSCURRENTTERM,cORIGIN,cUSERID WSRECEIVE lPUTACEITERESULT WSCLIENT WSTERMOCONSENT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTACEITE xmlns="http://localhost:8090/">'
cSoap += WSSoapValue("CURRENTTERM", ::oWSCURRENTTERM, oWSCURRENTTERM , "TCURRENTTERM", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("ORIGIN", ::cORIGIN, cORIGIN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("USERID", ::cUSERID, cUSERID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTACEITE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8090/PUTACEITE",; 
	"DOCUMENT","http://localhost:8090/",,"1.031217",; 
	"http://localhost:8090/ws/TERMOCONSENT.apw")

::Init()
::lPUTACEITERESULT   :=  WSAdvValue( oXmlRet,"_PUTACEITERESPONSE:_PUTACEITERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TCURRENTTERM

WSSTRUCT TERMOCONSENT_TCURRENTTERM
	WSDATA   cCODE                     AS string
	WSDATA   cDIRTERMO                 AS string OPTIONAL
	WSDATA   cFILEPATH                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TERMOCONSENT_TCURRENTTERM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TERMOCONSENT_TCURRENTTERM
Return

WSMETHOD CLONE WSCLIENT TERMOCONSENT_TCURRENTTERM
	Local oClone := TERMOCONSENT_TCURRENTTERM():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDIRTERMO            := ::cDIRTERMO
	oClone:cFILEPATH            := ::cFILEPATH
Return oClone

WSMETHOD SOAPSEND WSCLIENT TERMOCONSENT_TCURRENTTERM
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DIRTERMO", ::cDIRTERMO, ::cDIRTERMO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FILEPATH", ::cFILEPATH, ::cFILEPATH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TERMOCONSENT_TCURRENTTERM
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODE              :=  WSAdvValue( oResponse,"_CODE","string",NIL,"Property cCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDIRTERMO          :=  WSAdvValue( oResponse,"_DIRTERMO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILEPATH          :=  WSAdvValue( oResponse,"_FILEPATH","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TACCEPTRESP

WSSTRUCT TERMOCONSENT_TACCEPTRESP
	WSDATA   lACCEPT                   AS boolean
	WSDATA   cCODRDG                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TERMOCONSENT_TACCEPTRESP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TERMOCONSENT_TACCEPTRESP
Return

WSMETHOD CLONE WSCLIENT TERMOCONSENT_TACCEPTRESP
	Local oClone := TERMOCONSENT_TACCEPTRESP():NEW()
	oClone:lACCEPT              := ::lACCEPT
	oClone:cCODRDG              := ::cCODRDG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TERMOCONSENT_TACCEPTRESP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lACCEPT            :=  WSAdvValue( oResponse,"_ACCEPT","boolean",NIL,"Property lACCEPT as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cCODRDG            :=  WSAdvValue( oResponse,"_CODRDG","string",NIL,"Property cCODRDG as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


