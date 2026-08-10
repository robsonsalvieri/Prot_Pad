#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://200.247.221.35/EAIService/EAIService.asmx?WSDL
Gerado em        02/27/13 10:12:36
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JYOJUHQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSOpenTech
------------------------------------------------------------------------------- */

WSCLIENT WSOpenTech

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD RECEIVEMESSAGE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cINMSG                    AS string
	WSDATA   cRECEIVEMESSAGEResult     AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSOpenTech
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSOpenTech
Return

WSMETHOD RESET WSCLIENT WSOpenTech
	::cINMSG             := NIL 
	::cRECEIVEMESSAGEResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSOpenTech
Local oClone := WSOpenTech():New()
	oClone:_URL          := ::_URL 
	oClone:cINMSG        := ::cINMSG
	oClone:cRECEIVEMESSAGEResult := ::cRECEIVEMESSAGEResult
Return oClone

// WSDL Method RECEIVEMESSAGE of Service WSOpenTech

WSMETHOD RECEIVEMESSAGE WSSEND cINMSG WSRECEIVE cRECEIVEMESSAGEResult WSCLIENT WSOpenTech
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RECEIVEMESSAGE xmlns="http://www.totvs.com/">'
cSoap += WSSoapValue("INMSG", ::cINMSG, cINMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</RECEIVEMESSAGE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://www.totvs.com/RECEIVEMESSAGE",; 
	"DOCUMENT","http://www.totvs.com/",,,; 
	"http://200.247.221.35/EAIService/EAIService.asmx")

::Init()
::cRECEIVEMESSAGEResult :=  WSAdvValue( oXmlRet,"_RECEIVEMESSAGERESPONSE:_RECEIVEMESSAGERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



