#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://172.16.33.125:83/ws/RHACADEMICGRANT.apw?WSDL
Gerado em        04/25/14 10:07:26
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _EKVNEFI ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHACADEMICGRANT
------------------------------------------------------------------------------- */

WSCLIENT WSRHACADEMICGRANT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETLISTACADEMICGRANT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   oWSGETLISTACADEMICGRANTRESULT AS RHACADEMICGRANT_ACADEMICGRANTLIST

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHACADEMICGRANT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHACADEMICGRANT
	::oWSGETLISTACADEMICGRANTRESULT := RHACADEMICGRANT_ACADEMICGRANTLIST():New()
Return

WSMETHOD RESET WSCLIENT WSRHACADEMICGRANT
	::cEMPLOYEEFIL       := NIL 
	::oWSGETLISTACADEMICGRANTRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHACADEMICGRANT
Local oClone := WSRHACADEMICGRANT():New()
	oClone:_URL          := ::_URL 
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:oWSGETLISTACADEMICGRANTRESULT :=  IIF(::oWSGETLISTACADEMICGRANTRESULT = NIL , NIL ,::oWSGETLISTACADEMICGRANTRESULT:Clone() )
Return oClone

// WSDL Method GETLISTACADEMICGRANT of Service WSRHACADEMICGRANT

WSMETHOD GETLISTACADEMICGRANT WSSEND cEMPLOYEEFIL WSRECEIVE oWSGETLISTACADEMICGRANTRESULT WSCLIENT WSRHACADEMICGRANT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLISTACADEMICGRANT xmlns="http://172.16.33.125:83/">'
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETLISTACADEMICGRANT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://172.16.33.125:83/GETLISTACADEMICGRANT",; 
	"DOCUMENT","http://172.16.33.125:83/",,"1.031217",; 
	"http://172.16.33.125:83/ws/RHACADEMICGRANT.apw")

::Init()
::oWSGETLISTACADEMICGRANTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETLISTACADEMICGRANTRESPONSE:_GETLISTACADEMICGRANTRESULT","ACADEMICGRANTLIST",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ACADEMICGRANTLIST

WSSTRUCT RHACADEMICGRANT_ACADEMICGRANTLIST
	WSDATA   cCONTACT                  AS string
	WSDATA   cCURSENAME                AS string
	WSDATA   cENDDATE                  AS string
	WSDATA   cINSTALLMENTAMOUNT        AS string
	WSDATA   cINSTITUTENAME            AS string
	WSDATA   oWSITENS                  AS RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	WSDATA   cMONTHLYPAYMENT           AS string
	WSDATA   cOBSERVATION              AS string
	WSDATA   cPHONE                    AS string
	WSDATA   cSTARTDATE                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHACADEMICGRANT_ACADEMICGRANTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHACADEMICGRANT_ACADEMICGRANTLIST
Return

WSMETHOD CLONE WSCLIENT RHACADEMICGRANT_ACADEMICGRANTLIST
	Local oClone := RHACADEMICGRANT_ACADEMICGRANTLIST():NEW()
	oClone:cCONTACT             := ::cCONTACT
	oClone:cCURSENAME           := ::cCURSENAME
	oClone:cENDDATE             := ::cENDDATE
	oClone:cINSTALLMENTAMOUNT   := ::cINSTALLMENTAMOUNT
	oClone:cINSTITUTENAME       := ::cINSTITUTENAME
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
	oClone:cMONTHLYPAYMENT      := ::cMONTHLYPAYMENT
	oClone:cOBSERVATION         := ::cOBSERVATION
	oClone:cPHONE               := ::cPHONE
	oClone:cSTARTDATE           := ::cSTARTDATE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHACADEMICGRANT_ACADEMICGRANTLIST
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCONTACT           :=  WSAdvValue( oResponse,"_CONTACT","string",NIL,"Property cCONTACT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCURSENAME         :=  WSAdvValue( oResponse,"_CURSENAME","string",NIL,"Property cCURSENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cENDDATE           :=  WSAdvValue( oResponse,"_ENDDATE","string",NIL,"Property cENDDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTALLMENTAMOUNT :=  WSAdvValue( oResponse,"_INSTALLMENTAMOUNT","string",NIL,"Property cINSTALLMENTAMOUNT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTITUTENAME     :=  WSAdvValue( oResponse,"_INSTITUTENAME","string",NIL,"Property cINSTITUTENAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFACADEMICGRANTFIELDS",NIL,"Property oWSITENS as s0:ARRAYOFACADEMICGRANTFIELDS on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode6 != NIL
		::oWSITENS := RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS():New()
		::oWSITENS:SoapRecv(oNode6)
	EndIf
	::cMONTHLYPAYMENT    :=  WSAdvValue( oResponse,"_MONTHLYPAYMENT","string",NIL,"Property cMONTHLYPAYMENT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cOBSERVATION       :=  WSAdvValue( oResponse,"_OBSERVATION","string",NIL,"Property cOBSERVATION as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPHONE             :=  WSAdvValue( oResponse,"_PHONE","string",NIL,"Property cPHONE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTARTDATE         :=  WSAdvValue( oResponse,"_STARTDATE","string",NIL,"Property cSTARTDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFACADEMICGRANTFIELDS

WSSTRUCT RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	WSDATA   oWSACADEMICGRANTFIELDS    AS RHACADEMICGRANT_ACADEMICGRANTFIELDS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	::oWSACADEMICGRANTFIELDS := {} // Array Of  RHACADEMICGRANT_ACADEMICGRANTFIELDS():New()
Return

WSMETHOD CLONE WSCLIENT RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	Local oClone := RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS():NEW()
	oClone:oWSACADEMICGRANTFIELDS := NIL
	If ::oWSACADEMICGRANTFIELDS <> NIL 
		oClone:oWSACADEMICGRANTFIELDS := {}
		aEval( ::oWSACADEMICGRANTFIELDS , { |x| aadd( oClone:oWSACADEMICGRANTFIELDS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHACADEMICGRANT_ARRAYOFACADEMICGRANTFIELDS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ACADEMICGRANTFIELDS","ACADEMICGRANTFIELDS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSACADEMICGRANTFIELDS , RHACADEMICGRANT_ACADEMICGRANTFIELDS():New() )
			::oWSACADEMICGRANTFIELDS[len(::oWSACADEMICGRANTFIELDS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ACADEMICGRANTFIELDS

WSSTRUCT RHACADEMICGRANT_ACADEMICGRANTFIELDS
	WSDATA   cBENEFITCODE              AS string
	WSDATA   cBENEFITNAME              AS string
	WSDATA   nSALARYTO                 AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHACADEMICGRANT_ACADEMICGRANTFIELDS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHACADEMICGRANT_ACADEMICGRANTFIELDS
Return

WSMETHOD CLONE WSCLIENT RHACADEMICGRANT_ACADEMICGRANTFIELDS
	Local oClone := RHACADEMICGRANT_ACADEMICGRANTFIELDS():NEW()
	oClone:cBENEFITCODE         := ::cBENEFITCODE
	oClone:cBENEFITNAME         := ::cBENEFITNAME
	oClone:nSALARYTO            := ::nSALARYTO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHACADEMICGRANT_ACADEMICGRANTFIELDS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cBENEFITCODE       :=  WSAdvValue( oResponse,"_BENEFITCODE","string",NIL,"Property cBENEFITCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBENEFITNAME       :=  WSAdvValue( oResponse,"_BENEFITNAME","string",NIL,"Property cBENEFITNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::nSALARYTO          :=  WSAdvValue( oResponse,"_SALARYTO","float",NIL,"Property nSALARYTO as s:float on SOAP Response not found.",NIL,"N",NIL,NIL) 
Return