#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ipt-rogerio/ws/RHMENU.apw?WSDL
Gerado em        02/11/09 11:20:58
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.080707
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XELNMPB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHMENU
------------------------------------------------------------------------------- */

WSCLIENT WSRHMENU

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PRTHEADER
	WSMETHOD PRTLISTMENU

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS String
	WSDATA   cHEADERTYPE               AS string
	WSDATA   oWSPRTHEADERRESULT        AS RHMENU_ARRAYOFBRWHEADER
	WSDATA   cPORTALCODE               AS string
	WSDATA   oWSPRTLISTMENURESULT      AS RHMENU_ARRAYOFLOGINMENU

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHMENU
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.080307A-20080627] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHMENU
	::oWSPRTHEADERRESULT := RHMENU_ARRAYOFBRWHEADER():New()
	::oWSPRTLISTMENURESULT := RHMENU_ARRAYOFLOGINMENU():New()
Return

WSMETHOD RESET WSCLIENT WSRHMENU
	::cHEADERTYPE        := NIL 
	::oWSPRTHEADERRESULT := NIL 
	::cPORTALCODE        := NIL 
	::oWSPRTLISTMENURESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHMENU
Local oClone := WSRHMENU():New()
	oClone:_URL          := ::_URL 
	oClone:cHEADERTYPE   := ::cHEADERTYPE
	oClone:oWSPRTHEADERRESULT :=  IIF(::oWSPRTHEADERRESULT = NIL , NIL ,::oWSPRTHEADERRESULT:Clone() )
	oClone:cPORTALCODE   := ::cPORTALCODE
	oClone:oWSPRTLISTMENURESULT :=  IIF(::oWSPRTLISTMENURESULT = NIL , NIL ,::oWSPRTLISTMENURESULT:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method PRTHEADER of Service WSRHMENU
------------------------------------------------------------------------------- */

WSMETHOD PRTHEADER WSSEND cHEADERTYPE WSRECEIVE oWSPRTHEADERRESULT WSCLIENT WSRHMENU
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PRTHEADER xmlns="http://ipt-rogerio/">'
cSoap += WSSoapValue("HEADERTYPE", ::cHEADERTYPE, cHEADERTYPE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</PRTHEADER>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-rogerio/PRTHEADER",; 
	"DOCUMENT","http://ipt-rogerio/",,"1.031217",; 
	"http://ipt-rogerio/ws/RHMENU.apw")

::Init()
::oWSPRTHEADERRESULT:SoapRecv( WSAdvValue( oXmlRet,"_PRTHEADERRESPONSE:_PRTHEADERRESULT","ARRAYOFBRWHEADER",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method PRTLISTMENU of Service WSRHMENU
------------------------------------------------------------------------------- */

WSMETHOD PRTLISTMENU WSSEND cPORTALCODE WSRECEIVE oWSPRTLISTMENURESULT WSCLIENT WSRHMENU
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PRTLISTMENU xmlns="http://ipt-rogerio/">'
cSoap += WSSoapValue("PORTALCODE", ::cPORTALCODE, cPORTALCODE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</PRTLISTMENU>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-rogerio/PRTLISTMENU",; 
	"DOCUMENT","http://ipt-rogerio/",,"1.031217",; 
	"http://ipt-rogerio/ws/RHMENU.apw")

::Init()
::oWSPRTLISTMENURESULT:SoapRecv( WSAdvValue( oXmlRet,"_PRTLISTMENURESPONSE:_PRTLISTMENURESULT","ARRAYOFLOGINMENU",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFBRWHEADER
------------------------------------------------------------------------------- */

WSSTRUCT RHMENU_ARRAYOFBRWHEADER
	WSDATA   oWSBRWHEADER              AS RHMENU_BRWHEADER OPTIONAL
	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS String

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHMENU_ARRAYOFBRWHEADER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHMENU_ARRAYOFBRWHEADER
	::oWSBRWHEADER         := {} // Array Of  RHMENU_BRWHEADER():New()
Return

WSMETHOD CLONE WSCLIENT RHMENU_ARRAYOFBRWHEADER
	Local oClone := RHMENU_ARRAYOFBRWHEADER():NEW()
	oClone:oWSBRWHEADER := NIL
	If ::oWSBRWHEADER <> NIL 
		oClone:oWSBRWHEADER := {}
		aEval( ::oWSBRWHEADER , { |x| aadd( oClone:oWSBRWHEADER , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHMENU_ARRAYOFBRWHEADER
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_BRWHEADER","BRWHEADER",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSBRWHEADER , RHMENU_BRWHEADER():New() )
			::oWSBRWHEADER[len(::oWSBRWHEADER)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFLOGINMENU
------------------------------------------------------------------------------- */

WSSTRUCT RHMENU_ARRAYOFLOGINMENU
	WSDATA   oWSLOGINMENU              AS RHMENU_LOGINMENU OPTIONAL
	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS String
	
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHMENU_ARRAYOFLOGINMENU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHMENU_ARRAYOFLOGINMENU
	::oWSLOGINMENU         := {} // Array Of  RHMENU_LOGINMENU():New()
Return

WSMETHOD CLONE WSCLIENT RHMENU_ARRAYOFLOGINMENU
	Local oClone := RHMENU_ARRAYOFLOGINMENU():NEW()
	oClone:oWSLOGINMENU := NIL
	If ::oWSLOGINMENU <> NIL 
		oClone:oWSLOGINMENU := {}
		aEval( ::oWSLOGINMENU , { |x| aadd( oClone:oWSLOGINMENU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHMENU_ARRAYOFLOGINMENU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_LOGINMENU","LOGINMENU",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSLOGINMENU , RHMENU_LOGINMENU():New() )
			::oWSLOGINMENU[len(::oWSLOGINMENU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure BRWHEADER
------------------------------------------------------------------------------- */

WSSTRUCT RHMENU_BRWHEADER
	WSDATA   cHEADERCOMBOBOX           AS string OPTIONAL
	WSDATA   nHEADERDEC                AS integer
	WSDATA   cHEADERF3                 AS string OPTIONAL
	WSDATA   cHEADERFIELD              AS string
	WSDATA   lHEADEROBLIG              AS boolean OPTIONAL
	WSDATA   cHEADERPICTURE            AS string
	WSDATA   nHEADERSIZE               AS integer
	WSDATA   cHEADERTITLE              AS string
	WSDATA   cHEADERTYPE               AS string
	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS String
	
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHMENU_BRWHEADER
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHMENU_BRWHEADER
Return

WSMETHOD CLONE WSCLIENT RHMENU_BRWHEADER
	Local oClone := RHMENU_BRWHEADER():NEW()
	oClone:cHEADERCOMBOBOX      := ::cHEADERCOMBOBOX
	oClone:nHEADERDEC           := ::nHEADERDEC
	oClone:cHEADERF3            := ::cHEADERF3
	oClone:cHEADERFIELD         := ::cHEADERFIELD
	oClone:lHEADEROBLIG         := ::lHEADEROBLIG
	oClone:cHEADERPICTURE       := ::cHEADERPICTURE
	oClone:nHEADERSIZE          := ::nHEADERSIZE
	oClone:cHEADERTITLE         := ::cHEADERTITLE
	oClone:cHEADERTYPE          := ::cHEADERTYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHMENU_BRWHEADER
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cHEADERCOMBOBOX    :=  WSAdvValue( oResponse,"_HEADERCOMBOBOX","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nHEADERDEC         :=  WSAdvValue( oResponse,"_HEADERDEC","integer",NIL,"Property nHEADERDEC as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cHEADERF3          :=  WSAdvValue( oResponse,"_HEADERF3","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHEADERFIELD       :=  WSAdvValue( oResponse,"_HEADERFIELD","string",NIL,"Property cHEADERFIELD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lHEADEROBLIG       :=  WSAdvValue( oResponse,"_HEADEROBLIG","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::cHEADERPICTURE     :=  WSAdvValue( oResponse,"_HEADERPICTURE","string",NIL,"Property cHEADERPICTURE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nHEADERSIZE        :=  WSAdvValue( oResponse,"_HEADERSIZE","integer",NIL,"Property nHEADERSIZE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cHEADERTITLE       :=  WSAdvValue( oResponse,"_HEADERTITLE","string",NIL,"Property cHEADERTITLE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHEADERTYPE        :=  WSAdvValue( oResponse,"_HEADERTYPE","string",NIL,"Property cHEADERTYPE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure LOGINMENU
------------------------------------------------------------------------------- */

WSSTRUCT RHMENU_LOGINMENU
	WSDATA   nAPVLINITLEVEL            AS integer OPTIONAL
	WSDATA   nAPVLLEVELS               AS integer OPTIONAL
	WSDATA   cAPVLVISION               AS string OPTIONAL
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   lMENUISBLOCKED            AS boolean OPTIONAL
	WSDATA   nORDER                    AS integer
	WSDATA   cPROCEDURECALL            AS string
	WSDATA   cSUPERIORCODE             AS string
	WSDATA   cWEBSERVICE               AS string
	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS String
	
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHMENU_LOGINMENU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHMENU_LOGINMENU
Return

WSMETHOD CLONE WSCLIENT RHMENU_LOGINMENU
	Local oClone := RHMENU_LOGINMENU():NEW()
	oClone:nAPVLINITLEVEL       := ::nAPVLINITLEVEL
	oClone:nAPVLLEVELS          := ::nAPVLLEVELS
	oClone:cAPVLVISION          := ::cAPVLVISION
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:lMENUISBLOCKED       := ::lMENUISBLOCKED
	oClone:nORDER               := ::nORDER
	oClone:cPROCEDURECALL       := ::cPROCEDURECALL
	oClone:cSUPERIORCODE        := ::cSUPERIORCODE
	oClone:cWEBSERVICE          := ::cWEBSERVICE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHMENU_LOGINMENU
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nAPVLINITLEVEL     :=  WSAdvValue( oResponse,"_APVLINITLEVEL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nAPVLLEVELS        :=  WSAdvValue( oResponse,"_APVLLEVELS","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cAPVLVISION        :=  WSAdvValue( oResponse,"_APVLVISION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODE              :=  WSAdvValue( oResponse,"_CODE","string",NIL,"Property cCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lMENUISBLOCKED     :=  WSAdvValue( oResponse,"_MENUISBLOCKED","boolean",NIL,NIL,NIL,"L",NIL,NIL) 
	::nORDER             :=  WSAdvValue( oResponse,"_ORDER","integer",NIL,"Property nORDER as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cPROCEDURECALL     :=  WSAdvValue( oResponse,"_PROCEDURECALL","string",NIL,"Property cPROCEDURECALL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSUPERIORCODE      :=  WSAdvValue( oResponse,"_SUPERIORCODE","string",NIL,"Property cSUPERIORCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cWEBSERVICE        :=  WSAdvValue( oResponse,"_WEBSERVICE","string",NIL,"Property cWEBSERVICE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


