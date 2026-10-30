#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    https://preproducao.roadcard.com.br/sistemapamcardwsdl/WSTransacional-wsdl.xml?wsdl
Gerado em        04/12/18 13:51:05
Observaùùes      Cùdigo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alteraùùes neste arquivo podem causar funcionamento incorreto
                 e serùo perdidas caso o cùdigo-fonte seja gerado novamente.
=============================================================================== */

User Function _MMVKSTT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSTransacional
------------------------------------------------------------------------------- */

WSCLIENT WSWSTransacional

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD execute

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSarg0                   AS WSTransacional_requestTO
	WSDATA   oWSresponseTO             AS WSTransacional_responseTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSTransacional
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Cùdigo-Fonte Client atual requer os executùveis do Protheus Build [7.00.131227A-20170624 NG] ou superior. Atualize o Protheus ou gere o Cùdigo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSTransacional
	::oWSarg0            := WSTransacional_REQUESTTO():New()
	::oWSresponseTO      := WSTransacional_RESPONSETO():New()
Return

WSMETHOD RESET WSCLIENT WSWSTransacional
	::oWSarg0            := NIL 
	::oWSresponseTO      := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSTransacional
Local oClone := WSWSTransacional():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSresponseTO :=  IIF(::oWSresponseTO = NIL , NIL ,::oWSresponseTO:Clone() )
Return oClone

// WSDL Method execute of Service WSWSTransacional

WSMETHOD execute WSSEND oWSarg0 WSRECEIVE oWSresponseTO WSCLIENT WSWSTransacional
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

//cSoap += '<execute xmlns="http://webservice.pamcard.jee.pamcary.com.br">'
cSoap += '<tns:execute>'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "requestTO", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</tns:execute>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://webservice.pamcard.jee.pamcary.com.br",,,; 
	"https://preproducao.roadcard.com.br/sistemapamcard/services/WSTransacional")

/*
oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://webservice.pamcard.jee.pamcary.com.br",,,; 
	"https://preproducao.roadcard.com.br/sistemapamcard/services/WSTransacional")
*/
::Init()
::oWSresponseTO:SoapRecv( WSAdvValue( oXmlRet,"_RETURN","responseTO",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

//oXmlRet := NIL
Return .T.


// WSDL Data Structure requestTO

WSSTRUCT WSTransacional_requestTO
	WSDATA   ccontext                  AS string OPTIONAL
	WSDATA   oWSfields                 AS WSTransacional_fieldTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSTransacional_requestTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSTransacional_requestTO
	::oWSfields            := {} // Array Of  WSTransacional_FIELDTO():New()
Return

WSMETHOD CLONE WSCLIENT WSTransacional_requestTO
	Local oClone := WSTransacional_requestTO():NEW()
	oClone:ccontext             := ::ccontext
	oClone:oWSfields := NIL
	If ::oWSfields <> NIL 
		oClone:oWSfields := {}
		aEval( ::oWSfields , { |x| aadd( oClone:oWSfields , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSTransacional_requestTO
	Local cSoap := ""
	cSoap += WSSoapValue("context", ::ccontext, ::ccontext , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	aEval( ::oWSfields , {|x| cSoap := cSoap  +  WSSoapValue("fields", x , x , "fieldTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure responseTO

WSSTRUCT WSTransacional_responseTO
	WSDATA   oWSfields                 AS WSTransacional_fieldTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSTransacional_responseTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSTransacional_responseTO
	::oWSfields            := {} //WSTransacional_FIELDTO():New()
Return

WSMETHOD CLONE WSCLIENT WSTransacional_responseTO
	Local oClone := WSTransacional_responseTO():NEW()
	oClone:oWSfields := NIL
	If ::oWSfields <> NIL 
		oClone:oWSfields := {}
		aEval( ::oWSfields , { |x| aadd( oClone:oWSfields , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSTransacional_responseTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 	
	oNodes1 :=  WSAdvValue( oResponse,"_FIELDS","fieldTO",{},NIL,.T.,"O",NIL,"tns") 
	ValType( oNodes1)
	nTElem1 := len(oNodes1)	
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSfields , WSTransacional_fieldTO():New() )
			::oWSfields[len(::oWSfields)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure fieldTO

WSSTRUCT WSTransacional_fieldTO
	WSDATA   ckey                      AS string OPTIONAL
	WSDATA   cvalue                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSTransacional_fieldTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSTransacional_fieldTO
Return

WSMETHOD CLONE WSCLIENT WSTransacional_fieldTO
	Local oClone := WSTransacional_fieldTO():NEW()
	oClone:ckey                 := ::ckey
	oClone:cvalue               := ::cvalue
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSTransacional_fieldTO
	Local cSoap := ""
	cSoap += WSSoapValue("key", ::ckey, ::ckey , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("value", ::cvalue, ::cvalue , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSTransacional_fieldTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ckey               :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,"tns") 
	::cvalue             :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,"tns") 
Return


