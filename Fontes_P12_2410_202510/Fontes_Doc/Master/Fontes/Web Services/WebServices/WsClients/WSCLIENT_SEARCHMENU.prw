#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://10.172.68.102:8080/ws/WSSEARCHMENU.apw?WSDL
Gerado em        11/28/18 16:31:55
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NDQLVLH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSSEARCHMENU
------------------------------------------------------------------------------- */

WSCLIENT WSWSSEARCHMENU

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD SEARCHMENU

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cSFILIAL                  AS string
	WSDATA   lLGSP                     AS boolean
	WSDATA   oWSSEARCHMENURESULT       AS WSSEARCHMENU_CMENU

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSSEARCHMENU
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180920 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSSEARCHMENU
	::oWSSEARCHMENURESULT := WSSEARCHMENU_CMENU():New()
Return

WSMETHOD RESET WSCLIENT WSWSSEARCHMENU
	::cSFILIAL           := NIL 
	::lLGSP              := NIL 
	::oWSSEARCHMENURESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSSEARCHMENU
Local oClone := WSWSSEARCHMENU():New()
	oClone:_URL          := ::_URL 
	oClone:cSFILIAL      := ::cSFILIAL
	oClone:lLGSP         := ::lLGSP
	oClone:oWSSEARCHMENURESULT :=  IIF(::oWSSEARCHMENURESULT = NIL , NIL ,::oWSSEARCHMENURESULT:Clone() )
Return oClone

// WSDL Method SEARCHMENU of Service WSWSSEARCHMENU

WSMETHOD SEARCHMENU WSSEND cSFILIAL,lLGSP WSRECEIVE oWSSEARCHMENURESULT WSCLIENT WSWSSEARCHMENU
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SEARCHMENU xmlns="http://10.172.68.102:8080/">'
cSoap += WSSoapValue("SFILIAL", ::cSFILIAL, cSFILIAL , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("LGSP", ::lLGSP, lLGSP , "boolean", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</SEARCHMENU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.172.68.102:8080/SEARCHMENU",; 
	"DOCUMENT","http://10.172.68.102:8080/",,"1.031217",; 
	"http://10.172.68.102:8080/ws/WSSEARCHMENU.apw")

::Init()
::oWSSEARCHMENURESULT:SoapRecv( WSAdvValue( oXmlRet,"_SEARCHMENURESPONSE:_SEARCHMENURESULT","CMENU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CMENU

WSSTRUCT WSSEARCHMENU_CMENU
	WSDATA   oWSAROTINAS               AS WSSEARCHMENU_ARRAYOFCAI8
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSEARCHMENU_CMENU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSEARCHMENU_CMENU
Return

WSMETHOD CLONE WSCLIENT WSSEARCHMENU_CMENU
	Local oClone := WSSEARCHMENU_CMENU():NEW()
	oClone:oWSAROTINAS          := IIF(::oWSAROTINAS = NIL , NIL , ::oWSAROTINAS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSSEARCHMENU_CMENU
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AROTINAS","ARRAYOFCAI8",NIL,"Property oWSAROTINAS as s0:ARRAYOFCAI8 on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSAROTINAS := WSSEARCHMENU_ARRAYOFCAI8():New()
		::oWSAROTINAS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFCAI8

WSSTRUCT WSSEARCHMENU_ARRAYOFCAI8
	WSDATA   oWSCAI8                   AS WSSEARCHMENU_CAI8 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSEARCHMENU_ARRAYOFCAI8
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSEARCHMENU_ARRAYOFCAI8
	::oWSCAI8              := {} // Array Of  WSSEARCHMENU_CAI8():New()
Return

WSMETHOD CLONE WSCLIENT WSSEARCHMENU_ARRAYOFCAI8
	Local oClone := WSSEARCHMENU_ARRAYOFCAI8():NEW()
	oClone:oWSCAI8 := NIL
	If ::oWSCAI8 <> NIL 
		oClone:oWSCAI8 := {}
		aEval( ::oWSCAI8 , { |x| aadd( oClone:oWSCAI8 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSSEARCHMENU_ARRAYOFCAI8
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CAI8","CAI8",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCAI8 , WSSEARCHMENU_CAI8():New() )
			::oWSCAI8[len(::oWSCAI8)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure CAI8

WSSTRUCT WSSEARCHMENU_CAI8
	WSDATA   cSROTINAS                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSSEARCHMENU_CAI8
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSSEARCHMENU_CAI8
Return

WSMETHOD CLONE WSCLIENT WSSEARCHMENU_CAI8
	Local oClone := WSSEARCHMENU_CAI8():NEW()
	oClone:cSROTINAS            := ::cSROTINAS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSSEARCHMENU_CAI8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cSROTINAS          :=  WSAdvValue( oResponse,"_SROTINAS","string",NIL,"Property cSROTINAS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


