#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

/* ===============================================================================
WSDL Location    http://localhost:8083/ws/RHVDFDAYSOFF.apw?WSDL
Gerado em        12/04/18 15:49:38
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QYTELNK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHVDFDAYSOFF
------------------------------------------------------------------------------- */

WSCLIENT WSRHVDFDAYSOFF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ADDVDFDAYSOFFREQUEST

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSREQUEST                AS RHVDFDAYSOFF_TREQUEST
	WSDATA   oWSVDFVACATIONREQUEST     AS RHVDFDAYSOFF_TVDFVACATION
	WSDATA   cADDVDFDAYSOFFREQUESTRESULT AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSTREQUEST               AS RHVDFDAYSOFF_TREQUEST
	WSDATA   oWSTVDFVACATION           AS RHVDFDAYSOFF_TVDFVACATION

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHVDFDAYSOFF
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180425 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHVDFDAYSOFF
	::oWSREQUEST         := RHVDFDAYSOFF_TREQUEST():New()
	::oWSVDFVACATIONREQUEST := RHVDFDAYSOFF_TVDFVACATION():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := ::oWSREQUEST
	::oWSTVDFVACATION    := ::oWSVDFVACATIONREQUEST
Return

WSMETHOD RESET WSCLIENT WSRHVDFDAYSOFF
	::oWSREQUEST         := NIL 
	::oWSVDFVACATIONREQUEST := NIL 
	::cADDVDFDAYSOFFREQUESTRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSTREQUEST        := NIL
	::oWSTVDFVACATION    := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHVDFDAYSOFF
Local oClone := WSRHVDFDAYSOFF():New()
	oClone:_URL          := ::_URL 
	oClone:oWSREQUEST    :=  IIF(::oWSREQUEST = NIL , NIL ,::oWSREQUEST:Clone() )
	oClone:oWSVDFVACATIONREQUEST :=  IIF(::oWSVDFVACATIONREQUEST = NIL , NIL ,::oWSVDFVACATIONREQUEST:Clone() )
	oClone:cADDVDFDAYSOFFREQUESTRESULT := ::cADDVDFDAYSOFFREQUESTRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSTREQUEST   := oClone:oWSREQUEST
	oClone:oWSTVDFVACATION := oClone:oWSVDFVACATIONREQUEST
Return oClone

// WSDL Method ADDVDFDAYSOFFREQUEST of Service WSRHVDFDAYSOFF

WSMETHOD ADDVDFDAYSOFFREQUEST WSSEND oWSREQUEST,oWSVDFVACATIONREQUEST WSRECEIVE cADDVDFDAYSOFFREQUESTRESULT WSCLIENT WSRHVDFDAYSOFF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ADDVDFDAYSOFFREQUEST xmlns="http://localhost:8083/">'
cSoap += WSSoapValue("REQUEST", ::oWSREQUEST, oWSREQUEST , "TREQUEST", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("VDFVACATIONREQUEST", ::oWSVDFVACATIONREQUEST, oWSVDFVACATIONREQUEST , "TVDFVACATION", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ADDVDFDAYSOFFREQUEST>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8083/ADDVDFDAYSOFFREQUEST",; 
	"DOCUMENT","http://localhost:8083/",,"1.031217",; 
	"http://localhost:8083/ws/RHVDFDAYSOFF.apw")

::Init()
::cADDVDFDAYSOFFREQUESTRESULT :=  WSAdvValue( oXmlRet,"_ADDVDFDAYSOFFREQUESTRESPONSE:_ADDVDFDAYSOFFREQUESTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TREQUEST

WSSTRUCT RHVDFDAYSOFF_TREQUEST
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
	WSDATA   oWSITEMS                  AS RHVDFDAYSOFF_ARRAYOFTREQUESTITEM OPTIONAL
	WSDATA   nNROFLUIG                 AS integer OPTIONAL
	WSDATA   cOBSERVATION              AS string
	WSDATA   cORIGEM                   AS string OPTIONAL
	WSDATA   cPARTICIPANTRH            AS string OPTIONAL
	WSDATA   cREGISTRATION             AS string
	WSDATA   dREQUESTDATE              AS date OPTIONAL
	WSDATA   oWSREQUESTTYPE            AS RHVDFDAYSOFF_TREQUESTTYPE OPTIONAL
	WSDATA   dRESPONSEDATE             AS date OPTIONAL
	WSDATA   cSOURCE                   AS string OPTIONAL
	WSDATA   cSTARTERBRANCH            AS string OPTIONAL
	WSDATA   cSTARTERKEY               AS string OPTIONAL
	WSDATA   nSTARTERLEVEL             AS integer OPTIONAL
	WSDATA   cSTARTERREGISTRATION      AS string OPTIONAL
	WSDATA   oWSSTATUS                 AS RHVDFDAYSOFF_TREQUESTSTATUS OPTIONAL
	WSDATA   cVISION                   AS string OPTIONAL
	WSDATA   cWFAPROV                  AS string OPTIONAL
	WSDATA   cWFID                     AS string OPTIONAL
	WSDATA   cWFSTAGE                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_TREQUEST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_TREQUEST
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_TREQUEST
	Local oClone := RHVDFDAYSOFF_TREQUEST():NEW()
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

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_TREQUEST
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

WSSTRUCT RHVDFDAYSOFF_TVDFVACATION
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

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_TVDFVACATION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_TVDFVACATION
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_TVDFVACATION
	Local oClone := RHVDFDAYSOFF_TVDFVACATION():NEW()
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

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_TVDFVACATION
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

// WSDL Data Structure ARRAYOFTREQUESTITEM

WSSTRUCT RHVDFDAYSOFF_ARRAYOFTREQUESTITEM
	WSDATA   oWSTREQUESTITEM           AS RHVDFDAYSOFF_TREQUESTITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_ARRAYOFTREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_ARRAYOFTREQUESTITEM
	::oWSTREQUESTITEM      := {} // Array Of  RHVDFDAYSOFF_TREQUESTITEM():New()
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_ARRAYOFTREQUESTITEM
	Local oClone := RHVDFDAYSOFF_ARRAYOFTREQUESTITEM():NEW()
	oClone:oWSTREQUESTITEM := NIL
	If ::oWSTREQUESTITEM <> NIL 
		oClone:oWSTREQUESTITEM := {}
		aEval( ::oWSTREQUESTITEM , { |x| aadd( oClone:oWSTREQUESTITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_ARRAYOFTREQUESTITEM
	Local cSoap := ""
	aEval( ::oWSTREQUESTITEM , {|x| cSoap := cSoap  +  WSSoapValue("TREQUESTITEM", x , x , "TREQUESTITEM", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure TREQUESTTYPE

WSSTRUCT RHVDFDAYSOFF_TREQUESTTYPE
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cLINK                     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_TREQUESTTYPE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_TREQUESTTYPE
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_TREQUESTTYPE
	Local oClone := RHVDFDAYSOFF_TREQUESTTYPE():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cLINK                := ::cLINK
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_TREQUESTTYPE
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("LINK", ::cLINK, ::cLINK , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TREQUESTSTATUS

WSSTRUCT RHVDFDAYSOFF_TREQUESTSTATUS
	WSDATA   cCODE                     AS string
	WSDATA   cDESCRIPTION              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_TREQUESTSTATUS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_TREQUESTSTATUS
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_TREQUESTSTATUS
	Local oClone := RHVDFDAYSOFF_TREQUESTSTATUS():NEW()
	oClone:cCODE                := ::cCODE
	oClone:cDESCRIPTION         := ::cDESCRIPTION
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_TREQUESTSTATUS
	Local cSoap := ""
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("DESCRIPTION", ::cDESCRIPTION, ::cDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure TREQUESTITEM

WSSTRUCT RHVDFDAYSOFF_TREQUESTITEM
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

WSMETHOD NEW WSCLIENT RHVDFDAYSOFF_TREQUESTITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHVDFDAYSOFF_TREQUESTITEM
Return

WSMETHOD CLONE WSCLIENT RHVDFDAYSOFF_TREQUESTITEM
	Local oClone := RHVDFDAYSOFF_TREQUESTITEM():NEW()
	oClone:cBRANCH              := ::cBRANCH
	oClone:cFIELDDESCRIPTION    := ::cFIELDDESCRIPTION
	oClone:cFIELDNAME           := ::cFIELDNAME
	oClone:cNEWVALUE            := ::cNEWVALUE
	oClone:cPREVIOUSVALUE       := ::cPREVIOUSVALUE
	oClone:cREQUESTCODE         := ::cREQUESTCODE
	oClone:nSEQUENCE            := ::nSEQUENCE
Return oClone

WSMETHOD SOAPSEND WSCLIENT RHVDFDAYSOFF_TREQUESTITEM
	Local cSoap := ""
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDDESCRIPTION", ::cFIELDDESCRIPTION, ::cFIELDDESCRIPTION , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("FIELDNAME", ::cFIELDNAME, ::cFIELDNAME , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("NEWVALUE", ::cNEWVALUE, ::cNEWVALUE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("PREVIOUSVALUE", ::cPREVIOUSVALUE, ::cPREVIOUSVALUE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("REQUESTCODE", ::cREQUESTCODE, ::cREQUESTCODE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("SEQUENCE", ::nSEQUENCE, ::nSEQUENCE , "integer", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


