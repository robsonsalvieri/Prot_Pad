#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://172.16.31.46:82/ws/RHEXTRACT.apw?WSDL
Gerado em        04/12/12 09:41:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.111215
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _MZQVUAX ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHEXTRACT
------------------------------------------------------------------------------- */

WSCLIENT WSRHEXTRACT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BROWSEEXTRACT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cBRANCH                   AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   nCURRENTPAGE              AS integer
	WSDATA   cFILTERFIELD              AS string
	WSDATA   cFILTERVALUE              AS string
	WSDATA   oWSBROWSEEXTRACTRESULT    AS RHEXTRACT_TEXTRACTBROWSE

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHEXTRACT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHEXTRACT
	::oWSBROWSEEXTRACTRESULT := RHEXTRACT_TEXTRACTBROWSE():New()
Return

WSMETHOD RESET WSCLIENT WSRHEXTRACT
	::cBRANCH            := NIL 
	::cREGISTRATION      := NIL 
	::nCURRENTPAGE       := NIL 
	::cFILTERFIELD       := NIL 
	::cFILTERVALUE       := NIL 
	::oWSBROWSEEXTRACTRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHEXTRACT
Local oClone := WSRHEXTRACT():New()
	oClone:_URL          := ::_URL 
	oClone:cBRANCH       := ::cBRANCH
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:nCURRENTPAGE  := ::nCURRENTPAGE
	oClone:cFILTERFIELD  := ::cFILTERFIELD
	oClone:cFILTERVALUE  := ::cFILTERVALUE
	oClone:oWSBROWSEEXTRACTRESULT :=  IIF(::oWSBROWSEEXTRACTRESULT = NIL , NIL ,::oWSBROWSEEXTRACTRESULT:Clone() )
Return oClone

// WSDL Method BROWSEEXTRACT of Service WSRHEXTRACT

WSMETHOD BROWSEEXTRACT WSSEND cBRANCH,cREGISTRATION,nCURRENTPAGE,cFILTERFIELD,cFILTERVALUE WSRECEIVE oWSBROWSEEXTRACTRESULT WSCLIENT WSRHEXTRACT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BROWSEEXTRACT xmlns="http://172.16.31.46:82/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CURRENTPAGE", ::nCURRENTPAGE, nCURRENTPAGE , "integer", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILTERFIELD", ::cFILTERFIELD, cFILTERFIELD , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILTERVALUE", ::cFILTERVALUE, cFILTERVALUE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</BROWSEEXTRACT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://172.16.31.46:82/BROWSEEXTRACT",; 
	"DOCUMENT","http://172.16.31.46:82/",,"1.031217",; 
	"http://172.16.31.46:82/ws/RHEXTRACT.apw")

::Init()
::oWSBROWSEEXTRACTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BROWSEEXTRACTRESPONSE:_BROWSEEXTRACTRESULT","TEXTRACTBROWSE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TEXTRACTBROWSE

WSSTRUCT RHEXTRACT_TEXTRACTBROWSE
	WSDATA   oWSITENS                  AS RHEXTRACT_ARRAYOFTEXTRACTLIST OPTIONAL
	WSDATA   nPAGESTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEXTRACT_TEXTRACTBROWSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEXTRACT_TEXTRACTBROWSE
Return

WSMETHOD CLONE WSCLIENT RHEXTRACT_TEXTRACTBROWSE
	Local oClone := RHEXTRACT_TEXTRACTBROWSE():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEXTRACT_TEXTRACTBROWSE
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTEXTRACTLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHEXTRACT_ARRAYOFTEXTRACTLIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFTEXTRACTLIST

WSSTRUCT RHEXTRACT_ARRAYOFTEXTRACTLIST
	WSDATA   oWSTEXTRACTLIST           AS RHEXTRACT_TEXTRACTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEXTRACT_ARRAYOFTEXTRACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEXTRACT_ARRAYOFTEXTRACTLIST
	::oWSTEXTRACTLIST      := {} // Array Of  RHEXTRACT_TEXTRACTLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHEXTRACT_ARRAYOFTEXTRACTLIST
	Local oClone := RHEXTRACT_ARRAYOFTEXTRACTLIST():NEW()
	oClone:oWSTEXTRACTLIST := NIL
	If ::oWSTEXTRACTLIST <> NIL 
		oClone:oWSTEXTRACTLIST := {}
		aEval( ::oWSTEXTRACTLIST , { |x| aadd( oClone:oWSTEXTRACTLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEXTRACT_ARRAYOFTEXTRACTLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TEXTRACTLIST","TEXTRACTLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTEXTRACTLIST , RHEXTRACT_TEXTRACTLIST():New() )
			::oWSTEXTRACTLIST[len(::oWSTEXTRACTLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TEXTRACTLIST

WSSTRUCT RHEXTRACT_TEXTRACTLIST
	WSDATA   nACTBALANCE               AS float
	WSDATA   cBRANCH                   AS string
	WSDATA   nCURRBALANCE              AS float
	WSDATA   nDEPAMOUNT                AS float
	WSDATA   nINTAMOUNT                AS float
	WSDATA   nINTEREST                 AS float
	WSDATA   cMONTH                    AS string
	WSDATA   nPREVBALANCE              AS float
	WSDATA   nWITHAMOUNT               AS float
	WSDATA   cYEAR                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEXTRACT_TEXTRACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEXTRACT_TEXTRACTLIST
Return

WSMETHOD CLONE WSCLIENT RHEXTRACT_TEXTRACTLIST
	Local oClone := RHEXTRACT_TEXTRACTLIST():NEW()
	oClone:nACTBALANCE          := ::nACTBALANCE
	oClone:cBRANCH              := ::cBRANCH
	oClone:nCURRBALANCE         := ::nCURRBALANCE
	oClone:nDEPAMOUNT           := ::nDEPAMOUNT
	oClone:nINTAMOUNT           := ::nINTAMOUNT
	oClone:nINTEREST            := ::nINTEREST
	oClone:cMONTH               := ::cMONTH
	oClone:nPREVBALANCE         := ::nPREVBALANCE
	oClone:nWITHAMOUNT          := ::nWITHAMOUNT
	oClone:cYEAR                := ::cYEAR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEXTRACT_TEXTRACTLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nACTBALANCE        :=  WSAdvValue( oResponse,"_ACTBALANCE","float",NIL,"Property nACTBALANCE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,"Property cBRANCH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nCURRBALANCE       :=  WSAdvValue( oResponse,"_CURRBALANCE","float",NIL,"Property nCURRBALANCE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nDEPAMOUNT         :=  WSAdvValue( oResponse,"_DEPAMOUNT","float",NIL,"Property nDEPAMOUNT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nINTAMOUNT         :=  WSAdvValue( oResponse,"_INTAMOUNT","float",NIL,"Property nINTAMOUNT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nINTEREST          :=  WSAdvValue( oResponse,"_INTEREST","float",NIL,"Property nINTEREST as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMONTH             :=  WSAdvValue( oResponse,"_MONTH","string",NIL,"Property cMONTH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPREVBALANCE       :=  WSAdvValue( oResponse,"_PREVBALANCE","float",NIL,"Property nPREVBALANCE as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nWITHAMOUNT        :=  WSAdvValue( oResponse,"_WITHAMOUNT","float",NIL,"Property nWITHAMOUNT as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cYEAR              :=  WSAdvValue( oResponse,"_YEAR","string",NIL,"Property cYEAR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return