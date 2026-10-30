#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8059/ws//PmsInfoUSER.apw?WSDL
Gerado em        12/14/20 11:22:13
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _WMJMYLU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPMSINFOUSER
------------------------------------------------------------------------------- */

WSCLIENT WSPMSINFOUSER

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETRESOURCECODE
	WSMETHOD GETRESOURCETYPE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cUSERCODEPORTAL           AS string
	WSDATA   cGETRESOURCECODERESULT    AS string
	WSDATA   cGETRESOURCETYPERESULT    AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPMSINFOUSER
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.191205P-20201009] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPMSINFOUSER
Return

WSMETHOD RESET WSCLIENT WSPMSINFOUSER
	::cUSERCODEPORTAL    := NIL 
	::cGETRESOURCECODERESULT := NIL 
	::cGETRESOURCETYPERESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPMSINFOUSER
Local oClone := WSPMSINFOUSER():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERCODEPORTAL := ::cUSERCODEPORTAL
	oClone:cGETRESOURCECODERESULT := ::cGETRESOURCECODERESULT
	oClone:cGETRESOURCETYPERESULT := ::cGETRESOURCETYPERESULT
Return oClone

// WSDL Method GETRESOURCECODE of Service WSPMSINFOUSER

WSMETHOD GETRESOURCECODE WSSEND cUSERCODEPORTAL WSRECEIVE cGETRESOURCECODERESULT WSCLIENT WSPMSINFOUSER
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETRESOURCECODE xmlns="http://localhost:8059/">'
cSoap += WSSoapValue("USERCODEPORTAL", ::cUSERCODEPORTAL, cUSERCODEPORTAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETRESOURCECODE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8059/GETRESOURCECODE",; 
	"DOCUMENT","http://localhost:8059/",,"1.031217",; 
	"http://localhost:8059/ws/PMSINFOUSER.apw")

::Init()
::cGETRESOURCECODERESULT :=  WSAdvValue( oXmlRet,"_GETRESOURCECODERESPONSE:_GETRESOURCECODERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETRESOURCETYPE of Service WSPMSINFOUSER

WSMETHOD GETRESOURCETYPE WSSEND cUSERCODEPORTAL WSRECEIVE cGETRESOURCETYPERESULT WSCLIENT WSPMSINFOUSER
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETRESOURCETYPE xmlns="http://localhost:8059/">'
cSoap += WSSoapValue("USERCODEPORTAL", ::cUSERCODEPORTAL, cUSERCODEPORTAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETRESOURCETYPE>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8059/GETRESOURCETYPE",; 
	"DOCUMENT","http://localhost:8059/",,"1.031217",; 
	"http://localhost:8059/ws/PMSINFOUSER.apw")

::Init()
::cGETRESOURCETYPERESULT :=  WSAdvValue( oXmlRet,"_GETRESOURCETYPERESPONSE:_GETRESOURCETYPERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



