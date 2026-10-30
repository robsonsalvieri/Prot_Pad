#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ipt-tcarneiro/ws/QDODOCUMENTS.apw?WSDL
Gerado em        06/08/06 11:56:59
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.060117
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _WUZPKUI ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSCLIENT WSQDODOCUMENTS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETAHEADDOC
	WSMETHOD GETDOCUMENT
	WSMETHOD GETQDOBAIXA
	WSMETHOD GETQDOFILES
	WSMETHOD GETQDOLSHTM
	WSMETHOD GETQDOPATHS

	WSDATA   _URL                      AS String
	WSDATA   cUSERCODE                 AS string
	WSDATA   oWSGETAHEADDOCRESULT      AS QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	WSDATA   oWSGETDOCUMENTRESULT      AS QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	WSDATA   cFILCODRV                 AS string
	WSDATA   oWSGETQDOBAIXARESULT      AS QDODOCUMENTS_ARRAYOFABUFFERVIEW
	WSDATA   cNOMDOC                   AS string
	WSDATA   cPATCHDOC                 AS string
	WSDATA   nOFFSET                   AS integer
	WSDATA   oWSGETQDOFILESRESULT      AS QDODOCUMENTS_ARRAYOFABUFFERVIEW
	WSDATA   oWSGETQDOLSHTMRESULT      AS QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	WSDATA   oWSGETQDOPATHSRESULT      AS QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSQDODOCUMENTS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.060322A] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSQDODOCUMENTS
	::oWSGETAHEADDOCRESULT := QDODOCUMENTS_ARRAYOFAHEADQDHVIEW():New()
	::oWSGETDOCUMENTRESULT := QDODOCUMENTS_ARRAYOFACOLSQDHVIEW():New()
	::oWSGETQDOBAIXARESULT := QDODOCUMENTS_ARRAYOFABUFFERVIEW():New()
	::oWSGETQDOFILESRESULT := QDODOCUMENTS_ARRAYOFABUFFERVIEW():New()
	::oWSGETQDOLSHTMRESULT := QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW():New()
	::oWSGETQDOPATHSRESULT := QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW():New()
Return

WSMETHOD RESET WSCLIENT WSQDODOCUMENTS
	::cUSERCODE          := NIL 
	::oWSGETAHEADDOCRESULT := NIL 
	::oWSGETDOCUMENTRESULT := NIL 
	::cFILCODRV          := NIL 
	::oWSGETQDOBAIXARESULT := NIL 
	::cNOMDOC            := NIL 
	::cPATCHDOC          := NIL 
	::nOFFSET            := NIL 
	::oWSGETQDOFILESRESULT := NIL 
	::oWSGETQDOLSHTMRESULT := NIL 
	::oWSGETQDOPATHSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSQDODOCUMENTS
Local oClone := WSQDODOCUMENTS():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERCODE     := ::cUSERCODE
	oClone:oWSGETAHEADDOCRESULT :=  IIF(::oWSGETAHEADDOCRESULT = NIL , NIL ,::oWSGETAHEADDOCRESULT:Clone() )
	oClone:oWSGETDOCUMENTRESULT :=  IIF(::oWSGETDOCUMENTRESULT = NIL , NIL ,::oWSGETDOCUMENTRESULT:Clone() )
	oClone:cFILCODRV     := ::cFILCODRV
	oClone:oWSGETQDOBAIXARESULT :=  IIF(::oWSGETQDOBAIXARESULT = NIL , NIL ,::oWSGETQDOBAIXARESULT:Clone() )
	oClone:cNOMDOC       := ::cNOMDOC
	oClone:cPATCHDOC     := ::cPATCHDOC
	oClone:nOFFSET       := ::nOFFSET
	oClone:oWSGETQDOFILESRESULT :=  IIF(::oWSGETQDOFILESRESULT = NIL , NIL ,::oWSGETQDOFILESRESULT:Clone() )
	oClone:oWSGETQDOLSHTMRESULT :=  IIF(::oWSGETQDOLSHTMRESULT = NIL , NIL ,::oWSGETQDOLSHTMRESULT:Clone() )
	oClone:oWSGETQDOPATHSRESULT :=  IIF(::oWSGETQDOPATHSRESULT = NIL , NIL ,::oWSGETQDOPATHSRESULT:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method GETAHEADDOC of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETAHEADDOC WSSEND cUSERCODE WSRECEIVE oWSGETAHEADDOCRESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETAHEADDOC xmlns="http://ipt-tcarneiro/">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += "</GETAHEADDOC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETAHEADDOC",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETAHEADDOCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETAHEADDOCRESPONSE:_GETAHEADDOCRESULT","ARRAYOFAHEADQDHVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETDOCUMENT of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETDOCUMENT WSSEND cUSERCODE WSRECEIVE oWSGETDOCUMENTRESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETDOCUMENT xmlns="http://ipt-tcarneiro/">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += "</GETDOCUMENT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETDOCUMENT",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETDOCUMENTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETDOCUMENTRESPONSE:_GETDOCUMENTRESULT","ARRAYOFACOLSQDHVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETQDOBAIXA of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETQDOBAIXA WSSEND cUSERCODE,cFILCODRV WSRECEIVE oWSGETQDOBAIXARESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETQDOBAIXA xmlns="http://ipt-tcarneiro/">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FILCODRV", ::cFILCODRV, cFILCODRV , "string", .T. , .F., 0 ) 
cSoap += "</GETQDOBAIXA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETQDOBAIXA",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETQDOBAIXARESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETQDOBAIXARESPONSE:_GETQDOBAIXARESULT","ARRAYOFABUFFERVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETQDOFILES of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETQDOFILES WSSEND cNOMDOC,cPATCHDOC,nOFFSET WSRECEIVE oWSGETQDOFILESRESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETQDOFILES xmlns="http://ipt-tcarneiro/">'
cSoap += WSSoapValue("NOMDOC", ::cNOMDOC, cNOMDOC , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PATCHDOC", ::cPATCHDOC, cPATCHDOC , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("OFFSET", ::nOFFSET, nOFFSET , "integer", .T. , .F., 0 ) 
cSoap += "</GETQDOFILES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETQDOFILES",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETQDOFILESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETQDOFILESRESPONSE:_GETQDOFILESRESULT","ARRAYOFABUFFERVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETQDOLSHTM of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETQDOLSHTM WSSEND cNOMDOC,cPATCHDOC WSRECEIVE oWSGETQDOLSHTMRESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETQDOLSHTM xmlns="http://ipt-tcarneiro/">'
cSoap += WSSoapValue("NOMDOC", ::cNOMDOC, cNOMDOC , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PATCHDOC", ::cPATCHDOC, cPATCHDOC , "string", .T. , .F., 0 ) 
cSoap += "</GETQDOLSHTM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETQDOLSHTM",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETQDOLSHTMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETQDOLSHTMRESPONSE:_GETQDOLSHTMRESULT","ARRAYOFAFILEHTMQVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETQDOPATHS of Service WSQDODOCUMENTS
------------------------------------------------------------------------------- */

WSMETHOD GETQDOPATHS WSSEND NULLPARAM WSRECEIVE oWSGETQDOPATHSRESULT WSCLIENT WSQDODOCUMENTS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETQDOPATHS xmlns="http://ipt-tcarneiro/">'
cSoap += "</GETQDOPATHS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-tcarneiro/GETQDOPATHS",; 
	"DOCUMENT","http://ipt-tcarneiro/",,"1.031217",; 
	"http://ipt-tcarneiro/ws/QDODOCUMENTS.apw")

::Init()
::oWSGETQDOPATHSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETQDOPATHSRESPONSE:_GETQDOPATHSRESULT","ARRAYOFAQDOMVPATHVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFAHEADQDHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	WSDATA   oWSAHEADQDHVIEW           AS QDODOCUMENTS_AHEADQDHVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	::oWSAHEADQDHVIEW      := {} // Array Of  QDODOCUMENTS_AHEADQDHVIEW():New()
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	Local oClone := QDODOCUMENTS_ARRAYOFAHEADQDHVIEW():NEW()
	oClone:oWSAHEADQDHVIEW := NIL
	If ::oWSAHEADQDHVIEW <> NIL 
		oClone:oWSAHEADQDHVIEW := {}
		aEval( ::oWSAHEADQDHVIEW , { |x| aadd( oClone:oWSAHEADQDHVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ARRAYOFAHEADQDHVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_AHEADQDHVIEW","AHEADQDHVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAHEADQDHVIEW , QDODOCUMENTS_AHEADQDHVIEW():New() )
			::oWSAHEADQDHVIEW[len(::oWSAHEADQDHVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFACOLSQDHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	WSDATA   oWSACOLSQDHVIEW           AS QDODOCUMENTS_ACOLSQDHVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	::oWSACOLSQDHVIEW      := {} // Array Of  QDODOCUMENTS_ACOLSQDHVIEW():New()
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	Local oClone := QDODOCUMENTS_ARRAYOFACOLSQDHVIEW():NEW()
	oClone:oWSACOLSQDHVIEW := NIL
	If ::oWSACOLSQDHVIEW <> NIL 
		oClone:oWSACOLSQDHVIEW := {}
		aEval( ::oWSACOLSQDHVIEW , { |x| aadd( oClone:oWSACOLSQDHVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ARRAYOFACOLSQDHVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ACOLSQDHVIEW","ACOLSQDHVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSACOLSQDHVIEW , QDODOCUMENTS_ACOLSQDHVIEW():New() )
			::oWSACOLSQDHVIEW[len(::oWSACOLSQDHVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFABUFFERVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ARRAYOFABUFFERVIEW
	WSDATA   oWSABUFFERVIEW            AS QDODOCUMENTS_ABUFFERVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ARRAYOFABUFFERVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ARRAYOFABUFFERVIEW
	::oWSABUFFERVIEW       := {} // Array Of  QDODOCUMENTS_ABUFFERVIEW():New()
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ARRAYOFABUFFERVIEW
	Local oClone := QDODOCUMENTS_ARRAYOFABUFFERVIEW():NEW()
	oClone:oWSABUFFERVIEW := NIL
	If ::oWSABUFFERVIEW <> NIL 
		oClone:oWSABUFFERVIEW := {}
		aEval( ::oWSABUFFERVIEW , { |x| aadd( oClone:oWSABUFFERVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ARRAYOFABUFFERVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ABUFFERVIEW","ABUFFERVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSABUFFERVIEW , QDODOCUMENTS_ABUFFERVIEW():New() )
			::oWSABUFFERVIEW[len(::oWSABUFFERVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFAFILEHTMQVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	WSDATA   oWSAFILEHTMQVIEW          AS QDODOCUMENTS_AFILEHTMQVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	::oWSAFILEHTMQVIEW     := {} // Array Of  QDODOCUMENTS_AFILEHTMQVIEW():New()
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	Local oClone := QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW():NEW()
	oClone:oWSAFILEHTMQVIEW := NIL
	If ::oWSAFILEHTMQVIEW <> NIL 
		oClone:oWSAFILEHTMQVIEW := {}
		aEval( ::oWSAFILEHTMQVIEW , { |x| aadd( oClone:oWSAFILEHTMQVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ARRAYOFAFILEHTMQVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_AFILEHTMQVIEW","AFILEHTMQVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAFILEHTMQVIEW , QDODOCUMENTS_AFILEHTMQVIEW():New() )
			::oWSAFILEHTMQVIEW[len(::oWSAFILEHTMQVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFAQDOMVPATHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW
	WSDATA   oWSAQDOMVPATHVIEW         AS QDODOCUMENTS_AQDOMVPATHVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW
	::oWSAQDOMVPATHVIEW    := {} // Array Of  QDODOCUMENTS_AQDOMVPATHVIEW():New()
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW
	Local oClone := QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW():NEW()
	oClone:oWSAQDOMVPATHVIEW := NIL
	If ::oWSAQDOMVPATHVIEW <> NIL 
		oClone:oWSAQDOMVPATHVIEW := {}
		aEval( ::oWSAQDOMVPATHVIEW , { |x| aadd( oClone:oWSAQDOMVPATHVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ARRAYOFAQDOMVPATHVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_AQDOMVPATHVIEW","AQDOMVPATHVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSAQDOMVPATHVIEW , QDODOCUMENTS_AQDOMVPATHVIEW():New() )
			::oWSAQDOMVPATHVIEW[len(::oWSAQDOMVPATHVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure AHEADQDHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_AHEADQDHVIEW
	WSDATA   cX3_CAMPO                 AS string OPTIONAL
	WSDATA   cX3_PICTURE               AS string OPTIONAL
	WSDATA   cX3_TITULO                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_AHEADQDHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_AHEADQDHVIEW
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_AHEADQDHVIEW
	Local oClone := QDODOCUMENTS_AHEADQDHVIEW():NEW()
	oClone:cX3_CAMPO            := ::cX3_CAMPO
	oClone:cX3_PICTURE          := ::cX3_PICTURE
	oClone:cX3_TITULO           := ::cX3_TITULO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_AHEADQDHVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cX3_CAMPO          :=  WSAdvValue( oResponse,"_X3_CAMPO","string",NIL,NIL,NIL,"S",NIL) 
	::cX3_PICTURE        :=  WSAdvValue( oResponse,"_X3_PICTURE","string",NIL,NIL,NIL,"S",NIL) 
	::cX3_TITULO         :=  WSAdvValue( oResponse,"_X3_TITULO","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ACOLSQDHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ACOLSQDHVIEW
	WSDATA   cCODIGODOC                AS string OPTIONAL
	WSDATA   cDESCTIPO                 AS string OPTIONAL
	WSDATA   cDTOIE                    AS string OPTIONAL
	WSDATA   cFILIALDOC                AS string OPTIONAL
	WSDATA   cNOMDOC                   AS string OPTIONAL
	WSDATA   cPENDUSR                  AS string OPTIONAL
	WSDATA   cRVDOC                    AS string OPTIONAL
	WSDATA   cTIPODOC                  AS string OPTIONAL
	WSDATA   cTITULODOC                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ACOLSQDHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ACOLSQDHVIEW
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ACOLSQDHVIEW
	Local oClone := QDODOCUMENTS_ACOLSQDHVIEW():NEW()
	oClone:cCODIGODOC           := ::cCODIGODOC
	oClone:cDESCTIPO            := ::cDESCTIPO
	oClone:cDTOIE               := ::cDTOIE
	oClone:cFILIALDOC           := ::cFILIALDOC
	oClone:cNOMDOC              := ::cNOMDOC
	oClone:cPENDUSR             := ::cPENDUSR
	oClone:cRVDOC               := ::cRVDOC
	oClone:cTIPODOC             := ::cTIPODOC
	oClone:cTITULODOC           := ::cTITULODOC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ACOLSQDHVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGODOC         :=  WSAdvValue( oResponse,"_CODIGODOC","string",NIL,NIL,NIL,"S",NIL) 
	::cDESCTIPO          :=  WSAdvValue( oResponse,"_DESCTIPO","string",NIL,NIL,NIL,"S",NIL) 
	::cDTOIE             :=  WSAdvValue( oResponse,"_DTOIE","string",NIL,NIL,NIL,"S",NIL) 
	::cFILIALDOC         :=  WSAdvValue( oResponse,"_FILIALDOC","string",NIL,NIL,NIL,"S",NIL) 
	::cNOMDOC            :=  WSAdvValue( oResponse,"_NOMDOC","string",NIL,NIL,NIL,"S",NIL) 
	::cPENDUSR           :=  WSAdvValue( oResponse,"_PENDUSR","string",NIL,NIL,NIL,"S",NIL) 
	::cRVDOC             :=  WSAdvValue( oResponse,"_RVDOC","string",NIL,NIL,NIL,"S",NIL) 
	::cTIPODOC           :=  WSAdvValue( oResponse,"_TIPODOC","string",NIL,NIL,NIL,"S",NIL) 
	::cTITULODOC         :=  WSAdvValue( oResponse,"_TITULODOC","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ABUFFERVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_ABUFFERVIEW
	WSDATA   cBUFFER                   AS base64binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_ABUFFERVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_ABUFFERVIEW
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_ABUFFERVIEW
	Local oClone := QDODOCUMENTS_ABUFFERVIEW():NEW()
	oClone:cBUFFER              := ::cBUFFER
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_ABUFFERVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBUFFER            :=  WSAdvValue( oResponse,"_BUFFER","base64binary",NIL,NIL,NIL,"SB",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure AFILEHTMQVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_AFILEHTMQVIEW
	WSDATA   cFILEHTM                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_AFILEHTMQVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_AFILEHTMQVIEW
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_AFILEHTMQVIEW
	Local oClone := QDODOCUMENTS_AFILEHTMQVIEW():NEW()
	oClone:cFILEHTM             := ::cFILEHTM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_AFILEHTMQVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFILEHTM           :=  WSAdvValue( oResponse,"_FILEHTM","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure AQDOMVPATHVIEW
------------------------------------------------------------------------------- */

WSSTRUCT QDODOCUMENTS_AQDOMVPATHVIEW
	WSDATA   cPATHVIEW                 AS string OPTIONAL
	WSDATA   cQPATH                    AS string OPTIONAL
	WSDATA   cQPATHD                   AS string OPTIONAL
	WSDATA   cQPATHDIR                 AS string OPTIONAL
	WSDATA   cQPATHHTM                 AS string OPTIONAL
	WSDATA   cQPATHTRM                 AS string OPTIONAL
	WSDATA   cTEXTOD                   AS string OPTIONAL
	WSDATA   cUSAHTML                  AS string OPTIONAL
	WSDATA   cUSAVIEW                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QDODOCUMENTS_AQDOMVPATHVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QDODOCUMENTS_AQDOMVPATHVIEW
Return

WSMETHOD CLONE WSCLIENT QDODOCUMENTS_AQDOMVPATHVIEW
	Local oClone := QDODOCUMENTS_AQDOMVPATHVIEW():NEW()
	oClone:cPATHVIEW            := ::cPATHVIEW
	oClone:cQPATH               := ::cQPATH
	oClone:cQPATHD              := ::cQPATHD
	oClone:cQPATHDIR            := ::cQPATHDIR
	oClone:cQPATHHTM            := ::cQPATHHTM
	oClone:cQPATHTRM            := ::cQPATHTRM
	oClone:cTEXTOD              := ::cTEXTOD
	oClone:cUSAHTML             := ::cUSAHTML
	oClone:cUSAVIEW             := ::cUSAVIEW
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT QDODOCUMENTS_AQDOMVPATHVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPATHVIEW          :=  WSAdvValue( oResponse,"_PATHVIEW","string",NIL,NIL,NIL,"S",NIL) 
	::cQPATH             :=  WSAdvValue( oResponse,"_QPATH","string",NIL,NIL,NIL,"S",NIL) 
	::cQPATHD            :=  WSAdvValue( oResponse,"_QPATHD","string",NIL,NIL,NIL,"S",NIL) 
	::cQPATHDIR          :=  WSAdvValue( oResponse,"_QPATHDIR","string",NIL,NIL,NIL,"S",NIL) 
	::cQPATHHTM          :=  WSAdvValue( oResponse,"_QPATHHTM","string",NIL,NIL,NIL,"S",NIL) 
	::cQPATHTRM          :=  WSAdvValue( oResponse,"_QPATHTRM","string",NIL,NIL,NIL,"S",NIL) 
	::cTEXTOD            :=  WSAdvValue( oResponse,"_TEXTOD","string",NIL,NIL,NIL,"S",NIL) 
	::cUSAHTML           :=  WSAdvValue( oResponse,"_USAHTML","string",NIL,NIL,NIL,"S",NIL) 
	::cUSAVIEW           :=  WSAdvValue( oResponse,"_USAVIEW","string",NIL,NIL,NIL,"S",NIL) 
Return


