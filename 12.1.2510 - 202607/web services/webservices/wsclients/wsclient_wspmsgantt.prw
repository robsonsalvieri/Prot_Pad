#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/ws/PMSGANTT.apw?WSDL
Gerado em        05/07/09 17:17:40
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.090116
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _DRYVRNE ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPMSGANTT
------------------------------------------------------------------------------- */

WSCLIENT WSPMSGANTT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETTASKLIST

	WSDATA   _URL                      AS String
	WSDATA   cUSERCODE                 AS string
	WSDATA   cPROJECTCODE              AS string
	WSDATA   cWBSCODE                  AS string
	WSDATA   oWSGETTASKLISTRESULT      AS PMSGANTT_ARRAYOFGANTTTASKVIEW

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPMSGANTT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.081215P-20090220] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPMSGANTT
	::oWSGETTASKLISTRESULT := PMSGANTT_ARRAYOFGANTTTASKVIEW():New()
Return

WSMETHOD RESET WSCLIENT WSPMSGANTT
	::cUSERCODE          := NIL 
	::cPROJECTCODE       := NIL 
	::cWBSCODE           := NIL 
	::oWSGETTASKLISTRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPMSGANTT
Local oClone := WSPMSGANTT():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERCODE     := ::cUSERCODE
	oClone:cPROJECTCODE  := ::cPROJECTCODE
	oClone:cWBSCODE      := ::cWBSCODE
	oClone:oWSGETTASKLISTRESULT :=  IIF(::oWSGETTASKLISTRESULT = NIL , NIL ,::oWSGETTASKLISTRESULT:Clone() )
Return oClone

// WSDL Method GETTASKLIST of Service WSPMSGANTT

WSMETHOD GETTASKLIST WSSEND cUSERCODE,cPROJECTCODE,cWBSCODE WSRECEIVE oWSGETTASKLISTRESULT WSCLIENT WSPMSGANTT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTASKLIST xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PROJECTCODE", ::cPROJECTCODE, cPROJECTCODE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("WBSCODE", ::cWBSCODE, cWBSCODE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETTASKLIST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETTASKLIST",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/ws/PMSGANTT.apw")

::Init()
::oWSGETTASKLISTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTASKLISTRESPONSE:_GETTASKLISTRESULT","ARRAYOFGANTTTASKVIEW",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ARRAYOFGANTTTASKVIEW

WSSTRUCT PMSGANTT_ARRAYOFGANTTTASKVIEW
	WSDATA   oWSGANTTTASKVIEW          AS PMSGANTT_GANTTTASKVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PMSGANTT_ARRAYOFGANTTTASKVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PMSGANTT_ARRAYOFGANTTTASKVIEW
	::oWSGANTTTASKVIEW     := {} // Array Of  PMSGANTT_GANTTTASKVIEW():New()
Return

WSMETHOD CLONE WSCLIENT PMSGANTT_ARRAYOFGANTTTASKVIEW
	Local oClone := PMSGANTT_ARRAYOFGANTTTASKVIEW():NEW()
	oClone:oWSGANTTTASKVIEW := NIL
	If ::oWSGANTTTASKVIEW <> NIL 
		oClone:oWSGANTTTASKVIEW := {}
		aEval( ::oWSGANTTTASKVIEW , { |x| aadd( oClone:oWSGANTTTASKVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PMSGANTT_ARRAYOFGANTTTASKVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_GANTTTASKVIEW","GANTTTASKVIEW",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSGANTTTASKVIEW , PMSGANTT_GANTTTASKVIEW():New() )
			::oWSGANTTTASKVIEW[len(::oWSGANTTTASKVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure GANTTTASKVIEW

WSSTRUCT PMSGANTT_GANTTTASKVIEW
	WSDATA   cBITMAP                   AS string OPTIONAL
	WSDATA   nCPM                      AS integer OPTIONAL
	WSDATA   nDBRECORD                 AS integer OPTIONAL
	WSDATA   dESTIMATEDFINALDATE       AS date
	WSDATA   cESTIMATEDFINALHOUR       AS string OPTIONAL
	WSDATA   dESTIMATEDINITIALDATE     AS date
	WSDATA   cESTIMATEDINITIALHOUR     AS string
	WSDATA   dEXECUTIONFINALDATE       AS date OPTIONAL
	WSDATA   dEXECUTIONINITIALDATE     AS date OPTIONAL
	WSDATA   cLEVEL                    AS string
	WSDATA   nPOC                      AS float OPTIONAL
	WSDATA   cPROJECTCODE              AS string
	WSDATA   nQUANTITY                 AS float OPTIONAL
	WSDATA   cRESOURCES                AS string OPTIONAL
	WSDATA   cTASKCODE                 AS string
	WSDATA   cTASKDESCRIPTION          AS string
	WSDATA   nTASKTYPE                 AS integer
	WSDATA   nTIMEDURATION             AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PMSGANTT_GANTTTASKVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PMSGANTT_GANTTTASKVIEW
Return

WSMETHOD CLONE WSCLIENT PMSGANTT_GANTTTASKVIEW
	Local oClone := PMSGANTT_GANTTTASKVIEW():NEW()
	oClone:cBITMAP              := ::cBITMAP
	oClone:nCPM                 := ::nCPM
	oClone:nDBRECORD            := ::nDBRECORD
	oClone:dESTIMATEDFINALDATE  := ::dESTIMATEDFINALDATE
	oClone:cESTIMATEDFINALHOUR  := ::cESTIMATEDFINALHOUR
	oClone:dESTIMATEDINITIALDATE := ::dESTIMATEDINITIALDATE
	oClone:cESTIMATEDINITIALHOUR := ::cESTIMATEDINITIALHOUR
	oClone:dEXECUTIONFINALDATE  := ::dEXECUTIONFINALDATE
	oClone:dEXECUTIONINITIALDATE := ::dEXECUTIONINITIALDATE
	oClone:cLEVEL               := ::cLEVEL
	oClone:nPOC                 := ::nPOC
	oClone:cPROJECTCODE         := ::cPROJECTCODE
	oClone:nQUANTITY            := ::nQUANTITY
	oClone:cRESOURCES           := ::cRESOURCES
	oClone:cTASKCODE            := ::cTASKCODE
	oClone:cTASKDESCRIPTION     := ::cTASKDESCRIPTION
	oClone:nTASKTYPE            := ::nTASKTYPE
	oClone:nTIMEDURATION        := ::nTIMEDURATION
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PMSGANTT_GANTTTASKVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBITMAP            :=  WSAdvValue( oResponse,"_BITMAP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nCPM               :=  WSAdvValue( oResponse,"_CPM","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDBRECORD          :=  WSAdvValue( oResponse,"_DBRECORD","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::dESTIMATEDFINALDATE :=  WSAdvValue( oResponse,"_ESTIMATEDFINALDATE","date",NIL,"Property dESTIMATEDFINALDATE as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cESTIMATEDFINALHOUR :=  WSAdvValue( oResponse,"_ESTIMATEDFINALHOUR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::dESTIMATEDINITIALDATE :=  WSAdvValue( oResponse,"_ESTIMATEDINITIALDATE","date",NIL,"Property dESTIMATEDINITIALDATE as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cESTIMATEDINITIALHOUR :=  WSAdvValue( oResponse,"_ESTIMATEDINITIALHOUR","string",NIL,"Property cESTIMATEDINITIALHOUR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dEXECUTIONFINALDATE :=  WSAdvValue( oResponse,"_EXECUTIONFINALDATE","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::dEXECUTIONINITIALDATE :=  WSAdvValue( oResponse,"_EXECUTIONINITIALDATE","date",NIL,NIL,NIL,"D",NIL,NIL) 
	::cLEVEL             :=  WSAdvValue( oResponse,"_LEVEL","string",NIL,"Property cLEVEL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nPOC               :=  WSAdvValue( oResponse,"_POC","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cPROJECTCODE       :=  WSAdvValue( oResponse,"_PROJECTCODE","string",NIL,"Property cPROJECTCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nQUANTITY          :=  WSAdvValue( oResponse,"_QUANTITY","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cRESOURCES         :=  WSAdvValue( oResponse,"_RESOURCES","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTASKCODE          :=  WSAdvValue( oResponse,"_TASKCODE","string",NIL,"Property cTASKCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTASKDESCRIPTION   :=  WSAdvValue( oResponse,"_TASKDESCRIPTION","string",NIL,"Property cTASKDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nTASKTYPE          :=  WSAdvValue( oResponse,"_TASKTYPE","integer",NIL,"Property nTASKTYPE as s:integer on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::nTIMEDURATION      :=  WSAdvValue( oResponse,"_TIMEDURATION","float",NIL,NIL,NIL,"N",NIL,NIL) 
Return


