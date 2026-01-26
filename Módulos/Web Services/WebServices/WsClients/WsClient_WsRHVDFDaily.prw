#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:81/webservice/RHVDFDAILY.apw?WSDL
Gerado em        10/03/13 15:33:35
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _EQMMUBR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHVDFDAILY
------------------------------------------------------------------------------- */

WSCLIENT WSRHVDFDAILY

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ADDVDFDAILYREQUEST

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSREQUEST                AS RHVDFDAILY_TREQUEST
	WSDATA   oWSVDFDAILYREQUEST        AS RHVDFDAILY_TVDFDAILY
	WSDATA   cADDVDFDAILYREQUESTRESULT AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTREQUEST               AS RHVDFDAILY_TREQUEST
	WSDATA   oWSTVDFDAILY              AS RHVDFDAILY_TVDFDAILY

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHVDFDAILY
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130625] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHVDFDAILY
	::oWSREQUEST         := RHVDFDAILY_TREQUEST():New()
	::oWSVDFDAILYREQUEST := RHVDFDAILY_TVDFDAILY():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := ::oWSREQUEST
	::oWSTVDFDAILY       := ::oWSVDFDAILYREQUEST
Return

WSMETHOD RESET WSCLIENT WSRHVDFDAILY
	::oWSREQUEST         := NIL 
	::oWSVDFDAILYREQUEST := NIL 
	::cADDVDFDAILYREQUESTRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := NIL
	::oWSTVDFDAILY       := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHVDFDAILY
Local oClone := WSRHVDFDAILY():New()
	oClone:_URL          := ::_URL 
	oClone:oWSREQUEST    :=  IIF(::oWSREQUEST = NIL , NIL ,::oWSREQUEST:Clone() )
	oClone:oWSVDFDAILYREQUEST :=  IIF(::oWSVDFDAILYREQUEST = NIL , NIL ,::oWSVDFDAILYREQUEST:Clone() )
	oClone:cADDVDFDAILYREQUESTRESULT := ::cADDVDFDAILYREQUESTRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTREQUEST   := oClone:oWSREQUEST
	oClone:oWSTVDFDAILY  := oClone:oWSVDFDAILYREQUEST
Return oClone

// WSDL Method ADDVDFDAILYREQUEST of Service WSRHVDFDAILY

WSMETHOD ADDVDFDAILYREQUEST WSSEND oWSREQUEST,oWSVDFDAILYREQUEST WSRECEIVE cADDVDFDAILYREQUESTRESULT WSCLIENT WSRHVDFDAILY
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADDVDFDAILYREQUEST xmlns="http://localhost:81/">'
cSoap += WSSoapValue("REQUEST", ::oWSREQUEST, oWSREQUEST , "TREQUEST", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("VDFDAILYREQUEST", ::oWSVDFDAILYREQUEST, oWSVDFDAILYREQUEST , "TVDFDAILY", .F. , .F., 0 , NIL, .F.) 
cSoap += "</ADDVDFDAILYREQUEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/ADDVDFDAILYREQUEST",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/webservice/RHVDFDAILY.apw")

::Init()
::cADDVDFDAILYREQUESTRESULT :=  WSAdvValue( oXmlRet,"_ADDVDFDAILYREQUESTRESPONSE:_ADDVDFDAILYREQUESTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TREQUEST

WSSTRUCT RHVDFDAILY_TREQUEST
	WSDATA   cAPPROVERBRANCH           AS string OPTIONAL
	WSDATA   nAPPROVERLEVEL            AS integer OPTIONAL
	WSDATA   cAPPROVERREGISTRATION     AS string OPTIONAL
	WSDATA   cBRANCH                   AS string OPTIONAL
	WSDATA   cCODE                     AS string OPTIONAL
	WSDATA   oWSITEMS                  AS RHVDFDAILY_ARRAYOFTREQUESTITEM OPTIONAL
	WSDATA   cOBSERVATION              AS string
	WSDATA   cPARTICIPANTRH            AS string OPTIONAL
	WSDATA   cREGISTRATION             AS string
	WSDATA   dREQUESTDATE              AS date OPTIONAL
	WSDATA   oWSREQUESTTYPE            AS RHVDFDAILY_TREQUESTTYPE OPTIONAL
	WSDATA   dRESPONSEDATE             AS date OPTIONAL
	WSDATA   cSOURCE                   AS string OPTIONAL
	WSDATA   cSTARTERBRANCH            AS string OPTIONAL
	WSDATA   cSTARTERKEY               AS string OPTIONAL
	WSDATA   nSTARTERLEVEL             AS integer OPTIONAL
	WSDATA   cSTARTERREGISTRATION      AS string OPTIONAL
	WSDATA   oWSSTATUS                 AS RHVDFDAILY_TREQUESTSTATUS OPTIONAL
	WSDATA   cVISION                   AS string OPTIONAL
	WSDATA   cWFAPROV                  AS string OPTIONAL
	WSDATA   cWFID                     AS string OPTIONAL
	WSDATA   cWFSTAGE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_TREQUEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_TREQUEST
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_TREQUEST
	Local oClone := RHVDFDAILY_TREQUEST():NEW()
	oClone:cAPPROVERBRANCH      := ::cAPPROVERBRANCH
	oClone:nAPPROVERLEVEL       := ::nAPPROVERLEVEL
	oClone:cAPPROVERREGISTRATION := ::cAPPROVERREGISTRATION
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCODE                := ::cCODE
	oClone:oWSITEMS             := IIF(::oWSITEMS = NIL , NIL , ::oWSITEMS:Clone() )
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cPARTICIPANTRH       := ::cPARTICIPANTRH
	oClone:cREGISTRATION        := ::cREGISTRATION
	oClone:dREQUESTDATE         := ::dREQUESTDATE
	oClone:oWSREQUESTTYPE       := IIF(::oWSREQUESTTYPE = NIL , NIL , ::oWSREQUESTTYPE:Clone() )
	oClone:dRESPONSEDATE        := ::dRESPONSEDATE
	oClone:cSOURCE              := ::cSOURCE
	oClone:cSTARTERBRANCH       := ::cSTARTERBRANCH
	oClone:cSTARTERKEY          := ::cSTARTERKEY
	oClone:nSTARTERLEVEL        := ::nSTARTERLEVEL
	oClone:cSTARTERREGISTRATION := ::cSTARTERREGISTRATION
	oClone:oWSSTATUS            := IIF(::oWSSTATUS = NIL , NIL , ::oWSSTATUS:Clone() )
	oClone:cVISION              := ::cVISION
	oClone:cWFAPROV             := ::cWFAPROV
	oClone:cWFID                := ::cWFID
	oClone:cWFSTAGE             := ::cWFSTAGE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_TREQUEST
	Local cSoap := ""
	cSoap += WSSoapValue("APPROVERBRANCH", ::cAPPROVERBRANCH, ::cAPPROVERBRANCH , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("APPROVERLEVEL", ::nAPPROVERLEVEL, ::nAPPROVERLEVEL , "integer", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("APPROVERREGISTRATION", ::cAPPROVERREGISTRATION, ::cAPPROVERREGISTRATION , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ITEMS", ::oWSITEMS, ::oWSITEMS , "ARRAYOFTREQUESTITEM", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("OBSERVATION", ::cOBSERVATION, ::cOBSERVATION , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PARTICIPANTRH", ::cPARTICIPANTRH, ::cPARTICIPANTRH , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, ::cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REQUESTDATE", ::dREQUESTDATE, ::dREQUESTDATE , "date", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REQUESTTYPE", ::oWSREQUESTTYPE, ::oWSREQUESTTYPE , "TREQUESTTYPE", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("RESPONSEDATE", ::dRESPONSEDATE, ::dRESPONSEDATE , "date", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SOURCE", ::cSOURCE, ::cSOURCE , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("STARTERBRANCH", ::cSTARTERBRANCH, ::cSTARTERBRANCH , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("STARTERKEY", ::cSTARTERKEY, ::cSTARTERKEY , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("STARTERLEVEL", ::nSTARTERLEVEL, ::nSTARTERLEVEL , "integer", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("STARTERREGISTRATION", ::cSTARTERREGISTRATION, ::cSTARTERREGISTRATION , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("STATUS", ::oWSSTATUS, ::oWSSTATUS , "TREQUESTSTATUS", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VISION", ::cVISION, ::cVISION , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("WFAPROV", ::cWFAPROV, ::cWFAPROV , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("WFID", ::cWFID, ::cWFID , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("WFSTAGE", ::cWFSTAGE, ::cWFSTAGE , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure TVDFDAILY

WSSTRUCT RHVDFDAILY_TVDFDAILY
	WSDATA   cFINALDATE                AS string
	WSDATA   cINITIALDATE              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_TVDFDAILY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_TVDFDAILY
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_TVDFDAILY
	Local oClone := RHVDFDAILY_TVDFDAILY():NEW()
	oClone:cFINALDATE           := ::cFINALDATE
	oClone:cINITIALDATE         := ::cINITIALDATE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_TVDFDAILY
	Local cSoap := ""
	cSoap += WSSoapValue("FINALDATE", ::cFINALDATE, ::cFINALDATE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("INITIALDATE", ::cINITIALDATE, ::cINITIALDATE , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFTREQUESTITEM

WSSTRUCT RHVDFDAILY_ARRAYOFTREQUESTITEM
	WSDATA   oWSTREQUESTITEM           AS RHVDFDAILY_TREQUESTITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_ARRAYOFTREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_ARRAYOFTREQUESTITEM
	::oWSTREQUESTITEM      := {} // Array Of  RHVDFDAILY_TREQUESTITEM():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_ARRAYOFTREQUESTITEM
	Local oClone := RHVDFDAILY_ARRAYOFTREQUESTITEM():NEW()
	oClone:oWSTREQUESTITEM := NIL
	If ::oWSTREQUESTITEM <> NIL 
		oClone:oWSTREQUESTITEM := {}
		aEval( ::oWSTREQUESTITEM , { |x| aadd( oClone:oWSTREQUESTITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_ARRAYOFTREQUESTITEM
	Local cSoap := ""
	aEval( ::oWSTREQUESTITEM , {|x| cSoap := cSoap  +  WSSoapValue("TREQUESTITEM", x , x , "TREQUESTITEM", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure TREQUESTTYPE

WSSTRUCT RHVDFDAILY_TREQUESTTYPE
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cLINK                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_TREQUESTTYPE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_TREQUESTTYPE
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_TREQUESTTYPE
	Local oClone := RHVDFDAILY_TREQUESTTYPE():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cLINK                := ::cLINK
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_TREQUESTTYPE
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("LINK", ::cLINK, ::cLINK , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure TREQUESTSTATUS

WSSTRUCT RHVDFDAILY_TREQUESTSTATUS
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_TREQUESTSTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_TREQUESTSTATUS
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_TREQUESTSTATUS
	Local oClone := RHVDFDAILY_TREQUESTSTATUS():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_TREQUESTSTATUS
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure TREQUESTITEM

WSSTRUCT RHVDFDAILY_TREQUESTITEM
	WSDATA   cBRANCH                   AS string OPTIONAL
	WSDATA   cFIELDDESCRIPTION         AS string OPTIONAL
	WSDATA   cFIELDNAME                AS string
	WSDATA   cNEWVALUE                 AS string
	WSDATA   cPREVIOUSVALUE            AS string OPTIONAL
	WSDATA   cREQUESTCODE              AS string
	WSDATA   nSEQUENCE                 AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAILY_TREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAILY_TREQUESTITEM
Return

WSMETHOD CLONE WSCLIENT RHVDFDAILY_TREQUESTITEM
	Local oClone := RHVDFDAILY_TREQUESTITEM():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cFIELDDESCRIPTION    := ::cFIELDDESCRIPTION
	oClone:cFIELDNAME           := ::cFIELDNAME
	oClone:cNEWVALUE            := ::cNEWVALUE
	oClone:cPREVIOUSVALUE       := ::cPREVIOUSVALUE
	oClone:cREQUESTCODE         := ::cREQUESTCODE
	oClone:nSEQUENCE            := ::nSEQUENCE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAILY_TREQUESTITEM
	Local cSoap := ""
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIELDDESCRIPTION", ::cFIELDDESCRIPTION, ::cFIELDDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FIELDNAME", ::cFIELDNAME, ::cFIELDNAME , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NEWVALUE", ::cNEWVALUE, ::cNEWVALUE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PREVIOUSVALUE", ::cPREVIOUSVALUE, ::cPREVIOUSVALUE , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REQUESTCODE", ::cREQUESTCODE, ::cREQUESTCODE , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("SEQUENCE", ::nSEQUENCE, ::nSEQUENCE , "integer", .T. , .F., 0 , NIL, .F.) 
Return cSoap


