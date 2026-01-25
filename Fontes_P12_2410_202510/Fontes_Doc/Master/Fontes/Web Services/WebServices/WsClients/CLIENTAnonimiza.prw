#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8081/ws/ANONIMIZA.apw?WSDL
Gerado em        11/13/19 16:47:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OKYSFTU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSANONIMIZA
------------------------------------------------------------------------------- */

WSCLIENT WSANONIMIZA

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PUTSOLIC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCPF                      AS string
	WSDATA   cNOME                     AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cOBSERVACAO               AS string
	WSDATA   cPUTSOLICRESULT           AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSANONIMIZA
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.170117A-20190628] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSANONIMIZA
Return

WSMETHOD RESET WSCLIENT WSANONIMIZA
	::cCPF               := NIL 
	::cNOME              := NIL 
	::cEMAIL             := NIL 
	::cOBSERVACAO        := NIL 
	::cPUTSOLICRESULT    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSANONIMIZA
Local oClone := WSANONIMIZA():New()
	oClone:_URL          := ::_URL 
	oClone:cCPF          := ::cCPF
	oClone:cNOME         := ::cNOME
	oClone:cEMAIL        := ::cEMAIL
	oClone:cOBSERVACAO   := ::cOBSERVACAO
	oClone:cPUTSOLICRESULT := ::cPUTSOLICRESULT
Return oClone

// WSDL Method PUTSOLIC of Service WSANONIMIZA

WSMETHOD PUTSOLIC WSSEND cCPF,cNOME,cEMAIL,cOBSERVACAO WSRECEIVE cPUTSOLICRESULT WSCLIENT WSANONIMIZA
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTSOLIC xmlns="http://localhost:8081/">'
cSoap += WSSoapValue("CPF", ::cCPF, cCPF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("NOME", ::cNOME, cNOME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("EMAIL", ::cEMAIL, cEMAIL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("OBSERVACAO", ::cOBSERVACAO, cOBSERVACAO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</PUTSOLIC>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://localhost:8081/PUTSOLIC",; 
	"DOCUMENT","http://localhost:8081/",,"1.031217",; 
	"http://localhost:8081/ws/ANONIMIZA.apw")

::Init()
::cPUTSOLICRESULT    :=  WSAdvValue( oXmlRet,"_PUTSOLICRESPONSE:_PUTSOLICRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



