#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8081/TSSAUTHENTICATION.apw?WSDL
Gerado em        09/16/21 10:41:24
Observarcoes     Codigo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alteracoes neste arquivo podem causar funcionamento incorreto
                 e serao perdidas caso o codigo-fonte seja gerado novamente.
=============================================================================== */

User Function WSCLITSSAUTH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSSAUTHENTICATION
------------------------------------------------------------------------------- */

WSCLIENT WSTSSAUTHENTICATION

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD TOKEN

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSTOKEN                  AS TSSAUTHENTICATION_TOKEN
	WSDATA   oWSTOKENRESULT            AS TSSAUTHENTICATION_TOKENOUT

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSSAUTHENTICATION
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Codigo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSSAUTHENTICATION
	::oWSTOKENRESULT     := TSSAUTHENTICATION_TOKENOUT():New()
	::oWSTOKEN 			 := TSSAUTHENTICATION_TOKEN():New()
Return

WSMETHOD RESET WSCLIENT WSTSSAUTHENTICATION
	::oWSTOKEN        	 := NIL 
	::oWSTOKENRESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSSAUTHENTICATION
Local oClone := WSTSSAUTHENTICATION():New()
	oClone:_URL           := ::_URL 
	oClone:oWSTOKEN   	  := IIF(::oWSTOKEN  = NIL , NIL ,::oWSTOKEN :Clone() )
	oClone:oWSTOKENRESULT := IIF(::oWSTOKEN  = NIL , NIL ,::oWSTOKEN :Clone() )
Return oClone


WSSTRUCT TSSAUTHENTICATION_TOKEN
	WSDATA   cGRANT_TYPE                   AS string
	WSDATA   cCLIENT_ID                    AS string OPTIONAL
	WSDATA   cCLIENT_SECRET                AS string OPTIONAL
	WSDATA   cREFRESH_TOKEN                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSAUTHENTICATION_TOKEN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSAUTHENTICATION_TOKEN
Return

WSMETHOD CLONE WSCLIENT TSSAUTHENTICATION_TOKEN
	Local oClone := TSSAUTHENTICATION_TOKEN():NEW()
	oClone:cGRANT_TYPE              := ::cGRANT_TYPE
	oClone:cCLIENT_ID               := ::cCLIENT_ID
	oClone:cCLIENT_SECRET           := ::cCLIENT_SECRET
	oClone:cREFRESH_TOKEN           := ::cREFRESH_TOKEN
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSAUTHENTICATION_TOKEN
	Local cSoap := ""
	cSoap += WSSoapValue("GRANT_TYPE "		, ::cGRANT_TYPE 	, ::cGRANT_TYPE 	, "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CLIENT_ID "		, ::cCLIENT_ID  	, ::cCLIENT_ID   	, "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CLIENT_SECRET "	, ::cCLIENT_SECRET	, ::cCLIENT_SECRET 	, "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REFRESH_TOKEN  "	, ::cREFRESH_TOKEN	, ::cREFRESH_TOKEN 	, "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Method TOKEN of Service WSTSSAUTHENTICATION

WSMETHOD TOKEN WSSEND oWSTOKEN WSRECEIVE oWSTOKENRESULT WSCLIENT WSTSSAUTHENTICATION
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TOKEN xmlns="http://webservices.totvs.com.br/TSSAUTHENTICATION.apw">'
cSoap += WSSoapValue("", ::oWSTOKEN, oWSTOKEN , "", .T. , .F. , 0 , NIL, .F.,.F.) 
cSoap += "</TOKEN>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://webservices.totvs.com.br/TSSAUTHENTICATION.apw/TOKEN",; 
	"DOCUMENT","http://webservices.totvs.com.br/TSSAUTHENTICATION.apw",,"1.031217",; 
	"http://localhost:8081/TSSAUTHENTICATION.apw")

::Init()
::oWSTOKENRESULT:SoapRecv( WSAdvValue( oXmlRet,"_TOKENRESPONSE:_TOKENRESULT","TOKENOUT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TOKENOUT

WSSTRUCT TSSAUTHENTICATION_TOKENOUT
	WSDATA   cACCESS_TOKEN             AS string
	WSDATA   nEXPIRES_IN               AS integer
	WSDATA   cREFRESH_TOKEN            AS string
	WSDATA   cTOKEN_TYPE               AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSAUTHENTICATION_TOKENOUT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSAUTHENTICATION_TOKENOUT
Return

WSMETHOD CLONE WSCLIENT TSSAUTHENTICATION_TOKENOUT
	Local oClone := TSSAUTHENTICATION_TOKENOUT():NEW()
	oClone:cACCESS_TOKEN        := ::cACCESS_TOKEN
	oClone:nEXPIRES_IN          := ::nEXPIRES_IN
	oClone:cREFRESH_TOKEN       := ::cREFRESH_TOKEN
	oClone:cTOKEN_TYPE          := ::cTOKEN_TYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSAUTHENTICATION_TOKENOUT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cACCESS_TOKEN      :=  WSAdvValue( oResponse,"_ACCESS_TOKEN","string",NIL,"Property cACCESS_TOKEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nEXPIRES_IN        :=  WSAdvValue( oResponse,"_EXPIRES_IN","integer",NIL,"Property nEXPIRES_IN as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cREFRESH_TOKEN     :=  WSAdvValue( oResponse,"_REFRESH_TOKEN","string",NIL,"Property cREFRESH_TOKEN as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTOKEN_TYPE        :=  WSAdvValue( oResponse,"_TOKEN_TYPE","string",NIL,"Property cTOKEN_TYPE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


