#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8083/ws/RHVDFLICENCE.apw?WSDL
Gerado em        12/04/18 16:05:20
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _OJZQEJA ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHVDFLICENCE
------------------------------------------------------------------------------- */

WSCLIENT WSRHVDFLICENCE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ADDVDFLICENCEREQUEST
	WSMETHOD GETLICENCES

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSREQUEST                AS RHVDFLICENCE_TREQUEST
	WSDATA   oWSVDFLICENCEREQUEST      AS RHVDFLICENCE_TVDFLICENCE
	WSDATA   cADDVDFLICENCEREQUESTRESULT AS string
	WSDATA   cPORTALLICENCE            AS string
	WSDATA   oWSGETLICENCESRESULT      AS RHVDFLICENCE_TLICENCEDATA

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTREQUEST               AS RHVDFLICENCE_TREQUEST
	WSDATA   oWSTVDFLICENCE            AS RHVDFLICENCE_TVDFLICENCE

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHVDFLICENCE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180425 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHVDFLICENCE
	::oWSREQUEST         := RHVDFLICENCE_TREQUEST():New()
	::oWSVDFLICENCEREQUEST := RHVDFLICENCE_TVDFLICENCE():New()
	::oWSGETLICENCESRESULT := RHVDFLICENCE_TLICENCEDATA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := ::oWSREQUEST
	::oWSTVDFLICENCE     := ::oWSVDFLICENCEREQUEST
Return

WSMETHOD RESET WSCLIENT WSRHVDFLICENCE
	::oWSREQUEST         := NIL 
	::oWSVDFLICENCEREQUEST := NIL 
	::cADDVDFLICENCEREQUESTRESULT := NIL 
	::cPORTALLICENCE     := NIL 
	::oWSGETLICENCESRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := NIL
	::oWSTVDFLICENCE     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHVDFLICENCE
Local oClone := WSRHVDFLICENCE():New()
	oClone:_URL          := ::_URL 
	oClone:oWSREQUEST    :=  IIF(::oWSREQUEST = NIL , NIL ,::oWSREQUEST:Clone() )
	oClone:oWSVDFLICENCEREQUEST :=  IIF(::oWSVDFLICENCEREQUEST = NIL , NIL ,::oWSVDFLICENCEREQUEST:Clone() )
	oClone:cADDVDFLICENCEREQUESTRESULT := ::cADDVDFLICENCEREQUESTRESULT
	oClone:cPORTALLICENCE := ::cPORTALLICENCE
	oClone:oWSGETLICENCESRESULT :=  IIF(::oWSGETLICENCESRESULT = NIL , NIL ,::oWSGETLICENCESRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTREQUEST   := oClone:oWSREQUEST
	oClone:oWSTVDFLICENCE := oClone:oWSVDFLICENCEREQUEST
Return oClone

// WSDL Method ADDVDFLICENCEREQUEST of Service WSRHVDFLICENCE

WSMETHOD ADDVDFLICENCEREQUEST WSSEND oWSREQUEST,oWSVDFLICENCEREQUEST WSRECEIVE cADDVDFLICENCEREQUESTRESULT WSCLIENT WSRHVDFLICENCE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADDVDFLICENCEREQUEST xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("REQUEST", ::oWSREQUEST, oWSREQUEST , "TREQUEST", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VDFLICENCEREQUEST", ::oWSVDFLICENCEREQUEST, oWSVDFLICENCEREQUEST , "TVDFLICENCE", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADDVDFLICENCEREQUEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/ADDVDFLICENCEREQUEST",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFLICENCE.apw")

::Init()
::cADDVDFLICENCEREQUESTRESULT :=  WSAdvValue( oXmlRet,"_ADDVDFLICENCEREQUESTRESPONSE:_ADDVDFLICENCEREQUESTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETLICENCES of Service WSRHVDFLICENCE

WSMETHOD GETLICENCES WSSEND cPORTALLICENCE WSRECEIVE oWSGETLICENCESRESULT WSCLIENT WSRHVDFLICENCE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLICENCES xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("PORTALLICENCE", ::cPORTALLICENCE, cPORTALLICENCE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETLICENCES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/GETLICENCES",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFLICENCE.apw")

::Init()
::oWSGETLICENCESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETLICENCESRESPONSE:_GETLICENCESRESULT","TLICENCEDATA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TREQUEST

WSSTRUCT RHVDFLICENCE_TREQUEST
	WSDATA   cAPPROVERBRANCH           AS string OPTIONAL
	WSDATA   nAPPROVERLEVEL            AS integer OPTIONAL
	WSDATA   cAPPROVERNAME             AS string OPTIONAL
	WSDATA   cAPPROVERREGISTRATION     AS string OPTIONAL
	WSDATA   cBRANCH                   AS string OPTIONAL
	WSDATA   cCODE                     AS string OPTIONAL
	WSDATA   cDEPARTAPR                AS string OPTIONAL
	WSDATA   cEMPRESA                  AS string OPTIONAL
	WSDATA   cEMPRESAAPR               AS string OPTIONAL
	WSDATA   cEMPRESAINI               AS string OPTIONAL
	WSDATA   oWSITEMS                  AS RHVDFLICENCE_ARRAYOFTREQUESTITEM OPTIONAL
	WSDATA   nNROFLUIG                 AS integer OPTIONAL
	WSDATA   cOBSERVATION              AS string
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   cPARTICIPANTRH            AS string OPTIONAL
	WSDATA   cREGISTRATION             AS string
	WSDATA   dREQUESTDATE              AS date OPTIONAL
	WSDATA   oWSREQUESTTYPE            AS RHVDFLICENCE_TREQUESTTYPE OPTIONAL
	WSDATA   dRESPONSEDATE             AS date OPTIONAL
	WSDATA   cSOURCE                   AS string OPTIONAL
	WSDATA   cSTARTERBRANCH            AS string OPTIONAL
	WSDATA   cSTARTERKEY               AS string OPTIONAL
	WSDATA   nSTARTERLEVEL             AS integer OPTIONAL
	WSDATA   cSTARTERREGISTRATION      AS string OPTIONAL
	WSDATA   oWSSTATUS                 AS RHVDFLICENCE_TREQUESTSTATUS OPTIONAL
	WSDATA   cVISION                   AS string OPTIONAL
	WSDATA   cWFAPROV                  AS string OPTIONAL
	WSDATA   cWFID                     AS string OPTIONAL
	WSDATA   cWFSTAGE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TREQUEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TREQUEST
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TREQUEST
	Local oClone := RHVDFLICENCE_TREQUEST():NEW()
	oClone:cAPPROVERBRANCH      := ::cAPPROVERBRANCH
	oClone:nAPPROVERLEVEL       := ::nAPPROVERLEVEL
	oClone:cAPPROVERNAME        := ::cAPPROVERNAME
	oClone:cAPPROVERREGISTRATION := ::cAPPROVERREGISTRATION
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCODE                := ::cCODE
	oClone:cDEPARTAPR           := ::cDEPARTAPR
	oClone:cEMPRESA             := ::cEMPRESA
	oClone:cEMPRESAAPR          := ::cEMPRESAAPR
	oClone:cEMPRESAINI          := ::cEMPRESAINI
	oClone:oWSITEMS             := IIF(::oWSITEMS = NIL , NIL , ::oWSITEMS:Clone() )
	oClone:nNROFLUIG            := ::nNROFLUIG
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cORIGEM              := ::cORIGEM
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

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_TREQUEST
	Local cSoap := ""
	cSoap += WSSoapValue("APPROVERBRANCH", ::cAPPROVERBRANCH, ::cAPPROVERBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APPROVERLEVEL", ::nAPPROVERLEVEL, ::nAPPROVERLEVEL , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APPROVERNAME", ::cAPPROVERNAME, ::cAPPROVERNAME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("APPROVERREGISTRATION", ::cAPPROVERREGISTRATION, ::cAPPROVERREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DEPARTAPR", ::cDEPARTAPR, ::cDEPARTAPR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, ::cEMPRESA , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESAAPR", ::cEMPRESAAPR, ::cEMPRESAAPR , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EMPRESAINI", ::cEMPRESAINI, ::cEMPRESAINI , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ITEMS", ::oWSITEMS, ::oWSITEMS , "ARRAYOFTREQUESTITEM", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NROFLUIG", ::nNROFLUIG, ::nNROFLUIG , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OBSERVATION", ::cOBSERVATION, ::cOBSERVATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ORIGEM", ::cORIGEM, ::cORIGEM , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PARTICIPANTRH", ::cPARTICIPANTRH, ::cPARTICIPANTRH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, ::cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REQUESTDATE", ::dREQUESTDATE, ::dREQUESTDATE , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REQUESTTYPE", ::oWSREQUESTTYPE, ::oWSREQUESTTYPE , "TREQUESTTYPE", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RESPONSEDATE", ::dRESPONSEDATE, ::dRESPONSEDATE , "date", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SOURCE", ::cSOURCE, ::cSOURCE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STARTERBRANCH", ::cSTARTERBRANCH, ::cSTARTERBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STARTERKEY", ::cSTARTERKEY, ::cSTARTERKEY , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STARTERLEVEL", ::nSTARTERLEVEL, ::nSTARTERLEVEL , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STARTERREGISTRATION", ::cSTARTERREGISTRATION, ::cSTARTERREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("STATUS", ::oWSSTATUS, ::oWSSTATUS , "TREQUESTSTATUS", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VISION", ::cVISION, ::cVISION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("WFAPROV", ::cWFAPROV, ::cWFAPROV , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("WFID", ::cWFID, ::cWFID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("WFSTAGE", ::cWFSTAGE, ::cWFSTAGE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TVDFLICENCE

WSSTRUCT RHVDFLICENCE_TVDFLICENCE
	WSDATA   cDAYSREQUEST              AS string OPTIONAL
	WSDATA   cDAYSTYPE                 AS string OPTIONAL
	WSDATA   cDAYSTYPEDESC             AS string OPTIONAL
	WSDATA   cFINALDATE                AS string OPTIONAL
	WSDATA   cINITIALDATE              AS string OPTIONAL
	WSDATA   cLICENCE                  AS string OPTIONAL
	WSDATA   cLICENCEDESC              AS string OPTIONAL
	WSDATA   cSUBSEMPLOYEEFIL          AS string OPTIONAL
	WSDATA   cSUBSNAME                 AS string OPTIONAL
	WSDATA   cSUBSREGISTRATION         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TVDFLICENCE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TVDFLICENCE
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TVDFLICENCE
	Local oClone := RHVDFLICENCE_TVDFLICENCE():NEW()
	oClone:cDAYSREQUEST         := ::cDAYSREQUEST
	oClone:cDAYSTYPE            := ::cDAYSTYPE
	oClone:cDAYSTYPEDESC        := ::cDAYSTYPEDESC
	oClone:cFINALDATE           := ::cFINALDATE
	oClone:cINITIALDATE         := ::cINITIALDATE
	oClone:cLICENCE             := ::cLICENCE
	oClone:cLICENCEDESC         := ::cLICENCEDESC
	oClone:cSUBSEMPLOYEEFIL     := ::cSUBSEMPLOYEEFIL
	oClone:cSUBSNAME            := ::cSUBSNAME
	oClone:cSUBSREGISTRATION    := ::cSUBSREGISTRATION
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_TVDFLICENCE
	Local cSoap := ""
	cSoap += WSSoapValue("DAYSREQUEST", ::cDAYSREQUEST, ::cDAYSREQUEST , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DAYSTYPE", ::cDAYSTYPE, ::cDAYSTYPE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DAYSTYPEDESC", ::cDAYSTYPEDESC, ::cDAYSTYPEDESC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FINALDATE", ::cFINALDATE, ::cFINALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INITIALDATE", ::cINITIALDATE, ::cINITIALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LICENCE", ::cLICENCE, ::cLICENCE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LICENCEDESC", ::cLICENCEDESC, ::cLICENCEDESC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBSEMPLOYEEFIL", ::cSUBSEMPLOYEEFIL, ::cSUBSEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBSNAME", ::cSUBSNAME, ::cSUBSNAME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SUBSREGISTRATION", ::cSUBSREGISTRATION, ::cSUBSREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TLICENCEDATA

WSSTRUCT RHVDFLICENCE_TLICENCEDATA
	WSDATA   oWSITEMSOFLICENCE         AS RHVDFLICENCE_ARRAYOFDATALICENCE OPTIONAL
	WSDATA   nITEMSTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TLICENCEDATA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TLICENCEDATA
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TLICENCEDATA
	Local oClone := RHVDFLICENCE_TLICENCEDATA():NEW()
	oClone:oWSITEMSOFLICENCE    := IIF(::oWSITEMSOFLICENCE = NIL , NIL , ::oWSITEMSOFLICENCE:Clone() )
	oClone:nITEMSTOTAL          := ::nITEMSTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFLICENCE_TLICENCEDATA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITEMSOFLICENCE","ARRAYOFDATALICENCE",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITEMSOFLICENCE := RHVDFLICENCE_ARRAYOFDATALICENCE():New()
		::oWSITEMSOFLICENCE:SoapRecv(oNode1)
	EndIf
	::nITEMSTOTAL        :=  WSAdvValue( oResponse,"_ITEMSTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFTREQUESTITEM

WSSTRUCT RHVDFLICENCE_ARRAYOFTREQUESTITEM
	WSDATA   oWSTREQUESTITEM           AS RHVDFLICENCE_TREQUESTITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_ARRAYOFTREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_ARRAYOFTREQUESTITEM
	::oWSTREQUESTITEM      := {} // Array Of  RHVDFLICENCE_TREQUESTITEM():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_ARRAYOFTREQUESTITEM
	Local oClone := RHVDFLICENCE_ARRAYOFTREQUESTITEM():NEW()
	oClone:oWSTREQUESTITEM := NIL
	If ::oWSTREQUESTITEM <> NIL 
		oClone:oWSTREQUESTITEM := {}
		aEval( ::oWSTREQUESTITEM , { |x| aadd( oClone:oWSTREQUESTITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_ARRAYOFTREQUESTITEM
	Local cSoap := ""
	aEval( ::oWSTREQUESTITEM , {|x| cSoap := cSoap  +  WSSoapValue("TREQUESTITEM", x , x , "TREQUESTITEM", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure TREQUESTTYPE

WSSTRUCT RHVDFLICENCE_TREQUESTTYPE
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cLINK                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TREQUESTTYPE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TREQUESTTYPE
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TREQUESTTYPE
	Local oClone := RHVDFLICENCE_TREQUESTTYPE():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cLINK                := ::cLINK
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_TREQUESTTYPE
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LINK", ::cLINK, ::cLINK , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TREQUESTSTATUS

WSSTRUCT RHVDFLICENCE_TREQUESTSTATUS
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TREQUESTSTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TREQUESTSTATUS
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TREQUESTSTATUS
	Local oClone := RHVDFLICENCE_TREQUESTSTATUS():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_TREQUESTSTATUS
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFDATALICENCE

WSSTRUCT RHVDFLICENCE_ARRAYOFDATALICENCE
	WSDATA   oWSDATALICENCE            AS RHVDFLICENCE_DATALICENCE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_ARRAYOFDATALICENCE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_ARRAYOFDATALICENCE
	::oWSDATALICENCE       := {} // Array Of  RHVDFLICENCE_DATALICENCE():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_ARRAYOFDATALICENCE
	Local oClone := RHVDFLICENCE_ARRAYOFDATALICENCE():NEW()
	oClone:oWSDATALICENCE := NIL
	If ::oWSDATALICENCE <> NIL 
		oClone:oWSDATALICENCE := {}
		aEval( ::oWSDATALICENCE , { |x| aadd( oClone:oWSDATALICENCE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFLICENCE_ARRAYOFDATALICENCE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DATALICENCE","DATALICENCE",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDATALICENCE , RHVDFLICENCE_DATALICENCE():New() )
			::oWSDATALICENCE[len(::oWSDATALICENCE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TREQUESTITEM

WSSTRUCT RHVDFLICENCE_TREQUESTITEM
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

WSMETHOD NEW WSCLIENT RHVDFLICENCE_TREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_TREQUESTITEM
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_TREQUESTITEM
	Local oClone := RHVDFLICENCE_TREQUESTITEM():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cFIELDDESCRIPTION    := ::cFIELDDESCRIPTION
	oClone:cFIELDNAME           := ::cFIELDNAME
	oClone:cNEWVALUE            := ::cNEWVALUE
	oClone:cPREVIOUSVALUE       := ::cPREVIOUSVALUE
	oClone:cREQUESTCODE         := ::cREQUESTCODE
	oClone:nSEQUENCE            := ::nSEQUENCE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFLICENCE_TREQUESTITEM
	Local cSoap := ""
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDDESCRIPTION", ::cFIELDDESCRIPTION, ::cFIELDDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDNAME", ::cFIELDNAME, ::cFIELDNAME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NEWVALUE", ::cNEWVALUE, ::cNEWVALUE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PREVIOUSVALUE", ::cPREVIOUSVALUE, ::cPREVIOUSVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REQUESTCODE", ::cREQUESTCODE, ::cREQUESTCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCE", ::nSEQUENCE, ::nSEQUENCE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure DATALICENCE

WSSTRUCT RHVDFLICENCE_DATALICENCE
	WSDATA   nABSENSEDAYS              AS integer OPTIONAL
	WSDATA   cBRANCH                   AS string OPTIONAL
	WSDATA   cDAYSTYPE                 AS string OPTIONAL
	WSDATA   cDAYSTYPEDESC             AS string OPTIONAL
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSDATA   nDIASAFAST                AS integer OPTIONAL
	WSDATA   cIDBASE                   AS string OPTIONAL
	WSDATA   cLICENCE                  AS string OPTIONAL
	WSDATA   cPORTAL                   AS string OPTIONAL
	WSDATA   nREGID                    AS integer OPTIONAL
	WSDATA   nSUBSTDAYS                AS integer OPTIONAL
	WSDATA   cSUBSTTYPE                AS string OPTIONAL
	WSDATA   cSUBSTTYPEDESC            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFLICENCE_DATALICENCE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFLICENCE_DATALICENCE
Return

WSMETHOD CLONE WSCLIENT RHVDFLICENCE_DATALICENCE
	Local oClone := RHVDFLICENCE_DATALICENCE():NEW()
	oClone:nABSENSEDAYS         := ::nABSENSEDAYS
	oClone:cBRANCH              := ::cBRANCH
	oClone:cDAYSTYPE            := ::cDAYSTYPE
	oClone:cDAYSTYPEDESC        := ::cDAYSTYPEDESC
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:nDIASAFAST           := ::nDIASAFAST
	oClone:cIDBASE              := ::cIDBASE
	oClone:cLICENCE             := ::cLICENCE
	oClone:cPORTAL              := ::cPORTAL
	oClone:nREGID               := ::nREGID
	oClone:nSUBSTDAYS           := ::nSUBSTDAYS
	oClone:cSUBSTTYPE           := ::cSUBSTTYPE
	oClone:cSUBSTTYPEDESC       := ::cSUBSTTYPEDESC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFLICENCE_DATALICENCE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nABSENSEDAYS       :=  WSAdvValue( oResponse,"_ABSENSEDAYS","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDAYSTYPE          :=  WSAdvValue( oResponse,"_DAYSTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDAYSTYPEDESC      :=  WSAdvValue( oResponse,"_DAYSTYPEDESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDIASAFAST         :=  WSAdvValue( oResponse,"_DIASAFAST","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cIDBASE            :=  WSAdvValue( oResponse,"_IDBASE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cLICENCE           :=  WSAdvValue( oResponse,"_LICENCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPORTAL            :=  WSAdvValue( oResponse,"_PORTAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nREGID             :=  WSAdvValue( oResponse,"_REGID","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nSUBSTDAYS         :=  WSAdvValue( oResponse,"_SUBSTDAYS","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cSUBSTTYPE         :=  WSAdvValue( oResponse,"_SUBSTTYPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSUBSTTYPEDESC     :=  WSAdvValue( oResponse,"_SUBSTTYPEDESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return