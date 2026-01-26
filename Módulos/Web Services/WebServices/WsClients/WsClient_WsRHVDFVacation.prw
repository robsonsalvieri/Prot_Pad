#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8083/ws/RHVDFVACATION.apw?WSDL
Gerado em        12/04/18 15:00:29
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LQPFMKL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHVDFVACATION
------------------------------------------------------------------------------- */

WSCLIENT WSRHVDFVACATION

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ADDVDFVACATIONREQUEST
	WSMETHOD EVALSUBSTITUTE
	WSMETHOD GETSUBSTITUTEDAYS
	WSMETHOD GETTABLE

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSREQUEST                AS RHVDFVACATION_TREQUEST
	WSDATA   oWSVDFVACATIONREQUEST     AS RHVDFVACATION_TVDFVACATION
	WSDATA   cADDVDFVACATIONREQUESTRESULT AS string
	WSDATA   cVACEMPLOYEEFIL           AS string
	WSDATA   cVACREGISTRATION          AS string
	WSDATA   cSTARTDATE                AS string
	WSDATA   cFINALDATE                AS string
	WSDATA   cEVALSUBSTITUTERESULT     AS string
	WSDATA   cIDBASE                   AS string
	WSDATA   nGETSUBSTITUTEDAYSRESULT  AS integer
	WSDATA   cRETTABLE                 AS string
	WSDATA   cTYPEPROG                 AS string
	WSDATA   cCODETABLE                AS string
	WSDATA   oWSGETTABLERESULT         AS RHVDFVACATION_TVDFTABLE

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTREQUEST               AS RHVDFVACATION_TREQUEST
	WSDATA   oWSTVDFVACATION           AS RHVDFVACATION_TVDFVACATION

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHVDFVACATION
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180425 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHVDFVACATION
	::oWSREQUEST         := RHVDFVACATION_TREQUEST():New()
	::oWSVDFVACATIONREQUEST := RHVDFVACATION_TVDFVACATION():New()
	::oWSGETTABLERESULT  := RHVDFVACATION_TVDFTABLE():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := ::oWSREQUEST
	::oWSTVDFVACATION    := ::oWSVDFVACATIONREQUEST
Return

WSMETHOD RESET WSCLIENT WSRHVDFVACATION
	::oWSREQUEST         := NIL 
	::oWSVDFVACATIONREQUEST := NIL 
	::cADDVDFVACATIONREQUESTRESULT := NIL 
	::cVACEMPLOYEEFIL    := NIL 
	::cVACREGISTRATION   := NIL 
	::cSTARTDATE         := NIL 
	::cFINALDATE         := NIL 
	::cEVALSUBSTITUTERESULT := NIL 
	::cIDBASE            := NIL 
	::nGETSUBSTITUTEDAYSRESULT := NIL 
	::cRETTABLE          := NIL 
	::cTYPEPROG          := NIL 
	::cCODETABLE         := NIL 
	::oWSGETTABLERESULT  := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := NIL
	::oWSTVDFVACATION    := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHVDFVACATION
Local oClone := WSRHVDFVACATION():New()
	oClone:_URL          := ::_URL 
	oClone:oWSREQUEST    :=  IIF(::oWSREQUEST = NIL , NIL ,::oWSREQUEST:Clone() )
	oClone:oWSVDFVACATIONREQUEST :=  IIF(::oWSVDFVACATIONREQUEST = NIL , NIL ,::oWSVDFVACATIONREQUEST:Clone() )
	oClone:cADDVDFVACATIONREQUESTRESULT := ::cADDVDFVACATIONREQUESTRESULT
	oClone:cVACEMPLOYEEFIL := ::cVACEMPLOYEEFIL
	oClone:cVACREGISTRATION := ::cVACREGISTRATION
	oClone:cSTARTDATE    := ::cSTARTDATE
	oClone:cFINALDATE    := ::cFINALDATE
	oClone:cEVALSUBSTITUTERESULT := ::cEVALSUBSTITUTERESULT
	oClone:cIDBASE       := ::cIDBASE
	oClone:nGETSUBSTITUTEDAYSRESULT := ::nGETSUBSTITUTEDAYSRESULT
	oClone:cRETTABLE     := ::cRETTABLE
	oClone:cTYPEPROG     := ::cTYPEPROG
	oClone:cCODETABLE    := ::cCODETABLE
	oClone:oWSGETTABLERESULT :=  IIF(::oWSGETTABLERESULT = NIL , NIL ,::oWSGETTABLERESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTREQUEST   := oClone:oWSREQUEST
	oClone:oWSTVDFVACATION := oClone:oWSVDFVACATIONREQUEST
Return oClone

// WSDL Method ADDVDFVACATIONREQUEST of Service WSRHVDFVACATION

WSMETHOD ADDVDFVACATIONREQUEST WSSEND oWSREQUEST,oWSVDFVACATIONREQUEST WSRECEIVE cADDVDFVACATIONREQUESTRESULT WSCLIENT WSRHVDFVACATION
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADDVDFVACATIONREQUEST xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("REQUEST", ::oWSREQUEST, oWSREQUEST , "TREQUEST", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VDFVACATIONREQUEST", ::oWSVDFVACATIONREQUEST, oWSVDFVACATIONREQUEST , "TVDFVACATION", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADDVDFVACATIONREQUEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/ADDVDFVACATIONREQUEST",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFVACATION.apw")

::Init()
::cADDVDFVACATIONREQUESTRESULT :=  WSAdvValue( oXmlRet,"_ADDVDFVACATIONREQUESTRESPONSE:_ADDVDFVACATIONREQUESTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EVALSUBSTITUTE of Service WSRHVDFVACATION

WSMETHOD EVALSUBSTITUTE WSSEND cVACEMPLOYEEFIL,cVACREGISTRATION,cSTARTDATE,cFINALDATE WSRECEIVE cEVALSUBSTITUTERESULT WSCLIENT WSRHVDFVACATION
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EVALSUBSTITUTE xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("VACEMPLOYEEFIL", ::cVACEMPLOYEEFIL, cVACEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VACREGISTRATION", ::cVACREGISTRATION, cVACREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("STARTDATE", ::cSTARTDATE, cSTARTDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("FINALDATE", ::cFINALDATE, cFINALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EVALSUBSTITUTE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/EVALSUBSTITUTE",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFVACATION.apw")

::Init()
::cEVALSUBSTITUTERESULT :=  WSAdvValue( oXmlRet,"_EVALSUBSTITUTERESPONSE:_EVALSUBSTITUTERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSUBSTITUTEDAYS of Service WSRHVDFVACATION

WSMETHOD GETSUBSTITUTEDAYS WSSEND cIDBASE WSRECEIVE nGETSUBSTITUTEDAYSRESULT WSCLIENT WSRHVDFVACATION
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSUBSTITUTEDAYS xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("IDBASE", ::cIDBASE, cIDBASE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETSUBSTITUTEDAYS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/GETSUBSTITUTEDAYS",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFVACATION.apw")

::Init()
::nGETSUBSTITUTEDAYSRESULT :=  WSAdvValue( oXmlRet,"_GETSUBSTITUTEDAYSRESPONSE:_GETSUBSTITUTEDAYSRESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETTABLE of Service WSRHVDFVACATION

WSMETHOD GETTABLE WSSEND cRETTABLE,cTYPEPROG,cCODETABLE WSRECEIVE oWSGETTABLERESULT WSCLIENT WSRHVDFVACATION
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETTABLE xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("RETTABLE", ::cRETTABLE, cRETTABLE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("TYPEPROG", ::cTYPEPROG, cTYPEPROG , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("CODETABLE", ::cCODETABLE, cCODETABLE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</GETTABLE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/GETTABLE",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFVACATION.apw")

::Init()
::oWSGETTABLERESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETTABLERESPONSE:_GETTABLERESULT","TVDFTABLE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TREQUEST

WSSTRUCT RHVDFVACATION_TREQUEST
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
	WSDATA   oWSITEMS                  AS RHVDFVACATION_ARRAYOFTREQUESTITEM OPTIONAL
	WSDATA   nNROFLUIG                 AS integer OPTIONAL
	WSDATA   cOBSERVATION              AS string
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   cPARTICIPANTRH            AS string OPTIONAL
	WSDATA   cREGISTRATION             AS string
	WSDATA   dREQUESTDATE              AS date OPTIONAL
	WSDATA   oWSREQUESTTYPE            AS RHVDFVACATION_TREQUESTTYPE OPTIONAL
	WSDATA   dRESPONSEDATE             AS date OPTIONAL
	WSDATA   cSOURCE                   AS string OPTIONAL
	WSDATA   cSTARTERBRANCH            AS string OPTIONAL
	WSDATA   cSTARTERKEY               AS string OPTIONAL
	WSDATA   nSTARTERLEVEL             AS integer OPTIONAL
	WSDATA   cSTARTERREGISTRATION      AS string OPTIONAL
	WSDATA   oWSSTATUS                 AS RHVDFVACATION_TREQUESTSTATUS OPTIONAL
	WSDATA   cVISION                   AS string OPTIONAL
	WSDATA   cWFAPROV                  AS string OPTIONAL
	WSDATA   cWFID                     AS string OPTIONAL
	WSDATA   cWFSTAGE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TREQUEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TREQUEST
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TREQUEST
	Local oClone := RHVDFVACATION_TREQUEST():NEW()
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

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_TREQUEST
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

// WSDL Data Structure TVDFVACATION

WSSTRUCT RHVDFVACATION_TVDFVACATION
	WSDATA   cALLOWANCEID              AS string OPTIONAL
	WSDATA   cBONUSDAYS                AS string OPTIONAL
	WSDATA   cCODE                     AS string OPTIONAL
	WSDATA   cDAYSOFFIRSTPERIOD        AS string OPTIONAL
	WSDATA   cDAYSOFSECONDPERIOD       AS string OPTIONAL
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSDATA   cFINALBASEDATE            AS string OPTIONAL
	WSDATA   cFIRSTFINALDATE           AS string OPTIONAL
	WSDATA   cFIRSTINITIALDATE         AS string OPTIONAL
	WSDATA   cFIRSTSUBSEMPLOYEEFIL     AS string OPTIONAL
	WSDATA   cFIRSTSUBSNAME            AS string OPTIONAL
	WSDATA   cFIRSTSUBSREGISTRATION    AS string OPTIONAL
	WSDATA   cIDPUBLICATION            AS string OPTIONAL
	WSDATA   cINITIALBASEDATE          AS string OPTIONAL
	WSDATA   cOPPORTUNEDAYS            AS string OPTIONAL
	WSDATA   cPROGRAMER                AS string OPTIONAL
	WSDATA   nREGID                    AS integer OPTIONAL
	WSDATA   cRI6KEY                   AS string OPTIONAL
	WSDATA   cSECONDFINALDATE          AS string OPTIONAL
	WSDATA   cSECONDINITIALDATE        AS string OPTIONAL
	WSDATA   cSECONDSUBSEMPLOYEEFIL    AS string OPTIONAL
	WSDATA   cSECONDSUBSNAME           AS string OPTIONAL
	WSDATA   cSECONDSUBSREGISTRATION   AS string OPTIONAL
	WSDATA   cSEQUENCE                 AS string OPTIONAL
	WSDATA   cTABLE                    AS string OPTIONAL
	WSDATA   cTYPEDESCSOLIC            AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TVDFVACATION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TVDFVACATION
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TVDFVACATION
	Local oClone := RHVDFVACATION_TVDFVACATION():NEW()
	oClone:cALLOWANCEID         := ::cALLOWANCEID
	oClone:cBONUSDAYS           := ::cBONUSDAYS
	oClone:cCODE                := ::cCODE
	oClone:cDAYSOFFIRSTPERIOD   := ::cDAYSOFFIRSTPERIOD
	oClone:cDAYSOFSECONDPERIOD  := ::cDAYSOFSECONDPERIOD
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cFINALBASEDATE       := ::cFINALBASEDATE
	oClone:cFIRSTFINALDATE      := ::cFIRSTFINALDATE
	oClone:cFIRSTINITIALDATE    := ::cFIRSTINITIALDATE
	oClone:cFIRSTSUBSEMPLOYEEFIL := ::cFIRSTSUBSEMPLOYEEFIL
	oClone:cFIRSTSUBSNAME       := ::cFIRSTSUBSNAME
	oClone:cFIRSTSUBSREGISTRATION := ::cFIRSTSUBSREGISTRATION
	oClone:cIDPUBLICATION       := ::cIDPUBLICATION
	oClone:cINITIALBASEDATE     := ::cINITIALBASEDATE
	oClone:cOPPORTUNEDAYS       := ::cOPPORTUNEDAYS
	oClone:cPROGRAMER           := ::cPROGRAMER
	oClone:nREGID               := ::nREGID
	oClone:cRI6KEY              := ::cRI6KEY
	oClone:cSECONDFINALDATE     := ::cSECONDFINALDATE
	oClone:cSECONDINITIALDATE   := ::cSECONDINITIALDATE
	oClone:cSECONDSUBSEMPLOYEEFIL := ::cSECONDSUBSEMPLOYEEFIL
	oClone:cSECONDSUBSNAME      := ::cSECONDSUBSNAME
	oClone:cSECONDSUBSREGISTRATION := ::cSECONDSUBSREGISTRATION
	oClone:cSEQUENCE            := ::cSEQUENCE
	oClone:cTABLE               := ::cTABLE
	oClone:cTYPEDESCSOLIC       := ::cTYPEDESCSOLIC
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_TVDFVACATION
	Local cSoap := ""
	cSoap += WSSoapValue("ALLOWANCEID", ::cALLOWANCEID, ::cALLOWANCEID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("BONUSDAYS", ::cBONUSDAYS, ::cBONUSDAYS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DAYSOFFIRSTPERIOD", ::cDAYSOFFIRSTPERIOD, ::cDAYSOFFIRSTPERIOD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DAYSOFSECONDPERIOD", ::cDAYSOFSECONDPERIOD, ::cDAYSOFSECONDPERIOD , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FINALBASEDATE", ::cFINALBASEDATE, ::cFINALBASEDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIRSTFINALDATE", ::cFIRSTFINALDATE, ::cFIRSTFINALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIRSTINITIALDATE", ::cFIRSTINITIALDATE, ::cFIRSTINITIALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIRSTSUBSEMPLOYEEFIL", ::cFIRSTSUBSEMPLOYEEFIL, ::cFIRSTSUBSEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIRSTSUBSNAME", ::cFIRSTSUBSNAME, ::cFIRSTSUBSNAME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIRSTSUBSREGISTRATION", ::cFIRSTSUBSREGISTRATION, ::cFIRSTSUBSREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IDPUBLICATION", ::cIDPUBLICATION, ::cIDPUBLICATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("INITIALBASEDATE", ::cINITIALBASEDATE, ::cINITIALBASEDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("OPPORTUNEDAYS", ::cOPPORTUNEDAYS, ::cOPPORTUNEDAYS , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PROGRAMER", ::cPROGRAMER, ::cPROGRAMER , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REGID", ::nREGID, ::nREGID , "integer", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RI6KEY", ::cRI6KEY, ::cRI6KEY , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SECONDFINALDATE", ::cSECONDFINALDATE, ::cSECONDFINALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SECONDINITIALDATE", ::cSECONDINITIALDATE, ::cSECONDINITIALDATE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SECONDSUBSEMPLOYEEFIL", ::cSECONDSUBSEMPLOYEEFIL, ::cSECONDSUBSEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SECONDSUBSNAME", ::cSECONDSUBSNAME, ::cSECONDSUBSNAME , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SECONDSUBSREGISTRATION", ::cSECONDSUBSREGISTRATION, ::cSECONDSUBSREGISTRATION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCE", ::cSEQUENCE, ::cSEQUENCE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TABLE", ::cTABLE, ::cTABLE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("TYPEDESCSOLIC", ::cTYPEDESCSOLIC, ::cTYPEDESCSOLIC , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TVDFTABLE

WSSTRUCT RHVDFVACATION_TVDFTABLE
	WSDATA   oWSLISTOFS106             AS RHVDFVACATION_ARRAYOFTABS106 OPTIONAL
	WSDATA   oWSLISTOFS107             AS RHVDFVACATION_ARRAYOFTABS107 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TVDFTABLE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TVDFTABLE
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TVDFTABLE
	Local oClone := RHVDFVACATION_TVDFTABLE():NEW()
	oClone:oWSLISTOFS106        := IIF(::oWSLISTOFS106 = NIL , NIL , ::oWSLISTOFS106:Clone() )
	oClone:oWSLISTOFS107        := IIF(::oWSLISTOFS107 = NIL , NIL , ::oWSLISTOFS107:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFVACATION_TVDFTABLE
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFS106","ARRAYOFTABS106",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFS106 := RHVDFVACATION_ARRAYOFTABS106():New()
		::oWSLISTOFS106:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_LISTOFS107","ARRAYOFTABS107",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSLISTOFS107 := RHVDFVACATION_ARRAYOFTABS107():New()
		::oWSLISTOFS107:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure ARRAYOFTREQUESTITEM

WSSTRUCT RHVDFVACATION_ARRAYOFTREQUESTITEM
	WSDATA   oWSTREQUESTITEM           AS RHVDFVACATION_TREQUESTITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_ARRAYOFTREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_ARRAYOFTREQUESTITEM
	::oWSTREQUESTITEM      := {} // Array Of  RHVDFVACATION_TREQUESTITEM():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_ARRAYOFTREQUESTITEM
	Local oClone := RHVDFVACATION_ARRAYOFTREQUESTITEM():NEW()
	oClone:oWSTREQUESTITEM := NIL
	If ::oWSTREQUESTITEM <> NIL 
		oClone:oWSTREQUESTITEM := {}
		aEval( ::oWSTREQUESTITEM , { |x| aadd( oClone:oWSTREQUESTITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_ARRAYOFTREQUESTITEM
	Local cSoap := ""
	aEval( ::oWSTREQUESTITEM , {|x| cSoap := cSoap  +  WSSoapValue("TREQUESTITEM", x , x , "TREQUESTITEM", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure TREQUESTTYPE

WSSTRUCT RHVDFVACATION_TREQUESTTYPE
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cLINK                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TREQUESTTYPE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TREQUESTTYPE
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TREQUESTTYPE
	Local oClone := RHVDFVACATION_TREQUESTTYPE():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cLINK                := ::cLINK
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_TREQUESTTYPE
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LINK", ::cLINK, ::cLINK , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TREQUESTSTATUS

WSSTRUCT RHVDFVACATION_TREQUESTSTATUS
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TREQUESTSTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TREQUESTSTATUS
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TREQUESTSTATUS
	Local oClone := RHVDFVACATION_TREQUESTSTATUS():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_TREQUESTSTATUS
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFTABS106

WSSTRUCT RHVDFVACATION_ARRAYOFTABS106
	WSDATA   oWSTABS106                AS RHVDFVACATION_TABS106 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_ARRAYOFTABS106
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_ARRAYOFTABS106
	::oWSTABS106           := {} // Array Of  RHVDFVACATION_TABS106():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_ARRAYOFTABS106
	Local oClone := RHVDFVACATION_ARRAYOFTABS106():NEW()
	oClone:oWSTABS106 := NIL
	If ::oWSTABS106 <> NIL 
		oClone:oWSTABS106 := {}
		aEval( ::oWSTABS106 , { |x| aadd( oClone:oWSTABS106 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFVACATION_ARRAYOFTABS106
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TABS106","TABS106",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTABS106 , RHVDFVACATION_TABS106():New() )
			::oWSTABS106[len(::oWSTABS106)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTABS107

WSSTRUCT RHVDFVACATION_ARRAYOFTABS107
	WSDATA   oWSTABS107                AS RHVDFVACATION_TABS107 OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_ARRAYOFTABS107
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_ARRAYOFTABS107
	::oWSTABS107           := {} // Array Of  RHVDFVACATION_TABS107():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_ARRAYOFTABS107
	Local oClone := RHVDFVACATION_ARRAYOFTABS107():NEW()
	oClone:oWSTABS107 := NIL
	If ::oWSTABS107 <> NIL 
		oClone:oWSTABS107 := {}
		aEval( ::oWSTABS107 , { |x| aadd( oClone:oWSTABS107 , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFVACATION_ARRAYOFTABS107
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TABS107","TABS107",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTABS107 , RHVDFVACATION_TABS107():New() )
			::oWSTABS107[len(::oWSTABS107)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TREQUESTITEM

WSSTRUCT RHVDFVACATION_TREQUESTITEM
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

WSMETHOD NEW WSCLIENT RHVDFVACATION_TREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TREQUESTITEM
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TREQUESTITEM
	Local oClone := RHVDFVACATION_TREQUESTITEM():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cFIELDDESCRIPTION    := ::cFIELDDESCRIPTION
	oClone:cFIELDNAME           := ::cFIELDNAME
	oClone:cNEWVALUE            := ::cNEWVALUE
	oClone:cPREVIOUSVALUE       := ::cPREVIOUSVALUE
	oClone:cREQUESTCODE         := ::cREQUESTCODE
	oClone:nSEQUENCE            := ::nSEQUENCE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFVACATION_TREQUESTITEM
	Local cSoap := ""
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDDESCRIPTION", ::cFIELDDESCRIPTION, ::cFIELDDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDNAME", ::cFIELDNAME, ::cFIELDNAME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NEWVALUE", ::cNEWVALUE, ::cNEWVALUE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PREVIOUSVALUE", ::cPREVIOUSVALUE, ::cPREVIOUSVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REQUESTCODE", ::cREQUESTCODE, ::cREQUESTCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCE", ::nSEQUENCE, ::nSEQUENCE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TABS106

WSSTRUCT RHVDFVACATION_TABS106
	WSDATA   cTABLE                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TABS106
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TABS106
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TABS106
	Local oClone := RHVDFVACATION_TABS106():NEW()
	oClone:cTABLE               := ::cTABLE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFVACATION_TABS106
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cTABLE             :=  WSAdvValue( oResponse,"_TABLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TABS107

WSSTRUCT RHVDFVACATION_TABS107
	WSDATA   cBRANCH                   AS string OPTIONAL
	WSDATA   cCOMBINATION              AS string OPTIONAL
	WSDATA   nDAYS01                   AS integer OPTIONAL
	WSDATA   nDAYS02                   AS integer OPTIONAL
	WSDATA   nDAYS03                   AS integer OPTIONAL
	WSDATA   nDAYS05                   AS integer OPTIONAL
	WSDATA   nDAYS06                   AS integer OPTIONAL
	WSDATA   cKEY                      AS string OPTIONAL
	WSDATA   cOPTIONCODE               AS string OPTIONAL
	WSDATA   cOPTIONDESC               AS string OPTIONAL
	WSDATA   cSEQUENCE                 AS string OPTIONAL
	WSDATA   cTABLE                    AS string OPTIONAL
	WSDATA   cTYPEOFPROGRAMER          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFVACATION_TABS107
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFVACATION_TABS107
Return

WSMETHOD CLONE WSCLIENT RHVDFVACATION_TABS107
	Local oClone := RHVDFVACATION_TABS107():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCOMBINATION         := ::cCOMBINATION
	oClone:nDAYS01              := ::nDAYS01
	oClone:nDAYS02              := ::nDAYS02
	oClone:nDAYS03              := ::nDAYS03
	oClone:nDAYS05              := ::nDAYS05
	oClone:nDAYS06              := ::nDAYS06
	oClone:cKEY                 := ::cKEY
	oClone:cOPTIONCODE          := ::cOPTIONCODE
	oClone:cOPTIONDESC          := ::cOPTIONDESC
	oClone:cSEQUENCE            := ::cSEQUENCE
	oClone:cTABLE               := ::cTABLE
	oClone:cTYPEOFPROGRAMER     := ::cTYPEOFPROGRAMER
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHVDFVACATION_TABS107
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOMBINATION       :=  WSAdvValue( oResponse,"_COMBINATION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nDAYS01            :=  WSAdvValue( oResponse,"_DAYS01","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDAYS02            :=  WSAdvValue( oResponse,"_DAYS02","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDAYS03            :=  WSAdvValue( oResponse,"_DAYS03","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDAYS05            :=  WSAdvValue( oResponse,"_DAYS05","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::nDAYS06            :=  WSAdvValue( oResponse,"_DAYS06","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cKEY               :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOPTIONCODE        :=  WSAdvValue( oResponse,"_OPTIONCODE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cOPTIONDESC        :=  WSAdvValue( oResponse,"_OPTIONDESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cSEQUENCE          :=  WSAdvValue( oResponse,"_SEQUENCE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTABLE             :=  WSAdvValue( oResponse,"_TABLE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTYPEOFPROGRAMER   :=  WSAdvValue( oResponse,"_TYPEOFPROGRAMER","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


