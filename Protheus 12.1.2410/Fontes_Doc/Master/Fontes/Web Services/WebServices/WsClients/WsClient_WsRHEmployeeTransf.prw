#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:81/ws/RHEMPLOYEETRANSF.apw?WSDL
Gerado em        05/07/13 16:14:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _XKMLBPQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHEMPLOYEETRANSF
------------------------------------------------------------------------------- */

WSCLIENT WSRHEMPLOYEETRANSF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETEMPLOYEETRANSF

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCOMPANY                  AS string
	WSDATA   cEMPLOYEEFIL              AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   cTYPETRANSF               AS string
	WSDATA   oWSGETEMPLOYEETRANSFRESULT AS RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHEMPLOYEETRANSF
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20130118] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHEMPLOYEETRANSF
	::oWSGETEMPLOYEETRANSFRESULT := RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF():New()
Return

WSMETHOD RESET WSCLIENT WSRHEMPLOYEETRANSF
	::cCOMPANY           := NIL 
	::cEMPLOYEEFIL       := NIL 
	::cREGISTRATION      := NIL 
	::cTYPETRANSF        := NIL 
	::oWSGETEMPLOYEETRANSFRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHEMPLOYEETRANSF
Local oClone := WSRHEMPLOYEETRANSF():New()
	oClone:_URL          := ::_URL 
	oClone:cCOMPANY      := ::cCOMPANY
	oClone:cEMPLOYEEFIL  := ::cEMPLOYEEFIL
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:cTYPETRANSF   := ::cTYPETRANSF
	oClone:oWSGETEMPLOYEETRANSFRESULT :=  IIF(::oWSGETEMPLOYEETRANSFRESULT = NIL , NIL ,::oWSGETEMPLOYEETRANSFRESULT:Clone() )
Return oClone

// WSDL Method GETEMPLOYEETRANSF of Service WSRHEMPLOYEETRANSF

WSMETHOD GETEMPLOYEETRANSF WSSEND cCOMPANY,cEMPLOYEEFIL,cREGISTRATION,cTYPETRANSF WSRECEIVE oWSGETEMPLOYEETRANSFRESULT WSCLIENT WSRHEMPLOYEETRANSF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETEMPLOYEETRANSF xmlns="http://localhost:81/">'
cSoap += WSSoapValue("COMPANY", ::cCOMPANY, cCOMPANY , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPLOYEEFIL", ::cEMPLOYEEFIL, cEMPLOYEEFIL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("TYPETRANSF", ::cTYPETRANSF, cTYPETRANSF , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETEMPLOYEETRANSF>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:81/GETEMPLOYEETRANSF",; 
	"DOCUMENT","http://localhost:81/",,"1.031217",; 
	"http://localhost:81/ws/RHEMPLOYEETRANSF.apw")

::Init()
::oWSGETEMPLOYEETRANSFRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETEMPLOYEETRANSFRESPONSE:_GETEMPLOYEETRANSFRESULT","TEMPLOYEEDATATRANSF",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TEMPLOYEEDATATRANSF

WSSTRUCT RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF
	WSDATA   oWSLISTOFTRANSFERS        AS RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF OPTIONAL
	WSDATA   nPAGESTOTAL               AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF
Return

WSMETHOD CLONE WSCLIENT RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF
	Local oClone := RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF():NEW()
	oClone:oWSLISTOFTRANSFERS   := IIF(::oWSLISTOFTRANSFERS = NIL , NIL , ::oWSLISTOFTRANSFERS:Clone() )
	oClone:nPAGESTOTAL          := ::nPAGESTOTAL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEMPLOYEETRANSF_TEMPLOYEEDATATRANSF
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_LISTOFTRANSFERS","ARRAYOFDATAEMPLOYEETRANSF",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSLISTOFTRANSFERS := RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF():New()
		::oWSLISTOFTRANSFERS:SoapRecv(oNode1)
	EndIf
	::nPAGESTOTAL        :=  WSAdvValue( oResponse,"_PAGESTOTAL","integer",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ARRAYOFDATAEMPLOYEETRANSF

WSSTRUCT RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF
	WSDATA   oWSDATAEMPLOYEETRANSF     AS RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF
	::oWSDATAEMPLOYEETRANSF := {} // Array Of  RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF():New()
Return

WSMETHOD CLONE WSCLIENT RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF
	Local oClone := RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF():NEW()
	oClone:oWSDATAEMPLOYEETRANSF := NIL
	If ::oWSDATAEMPLOYEETRANSF <> NIL 
		oClone:oWSDATAEMPLOYEETRANSF := {}
		aEval( ::oWSDATAEMPLOYEETRANSF , { |x| aadd( oClone:oWSDATAEMPLOYEETRANSF , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEMPLOYEETRANSF_ARRAYOFDATAEMPLOYEETRANSF
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DATAEMPLOYEETRANSF","DATAEMPLOYEETRANSF",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDATAEMPLOYEETRANSF , RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF():New() )
			::oWSDATAEMPLOYEETRANSF[len(::oWSDATAEMPLOYEETRANSF)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure DATAEMPLOYEETRANSF

WSSTRUCT RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF
	WSDATA   cADMISSIONDATE            AS string
	WSDATA   cCATFUNC                  AS string OPTIONAL
	WSDATA   cCATFUNCDESC              AS string OPTIONAL
	WSDATA   cCCTRANSFFROM             AS string OPTIONAL
	WSDATA   cCCTRANSFTO               AS string OPTIONAL
	WSDATA   cCOMPANYFROM              AS string OPTIONAL
	WSDATA   cCOMPANYTO                AS string OPTIONAL
	WSDATA   cCOST                     AS string OPTIONAL
	WSDATA   cCOSTID                   AS string OPTIONAL
	WSDATA   cDEPARTMENT               AS string OPTIONAL
	WSDATA   cDESCRDEPARTMENT          AS string OPTIONAL
	WSDATA   cDESCSITUACAO             AS string OPTIONAL
	WSDATA   cEMAIL                    AS string OPTIONAL
	WSDATA   cFILIALDESCR              AS string OPTIONAL
	WSDATA   cFILTRANSFFROM            AS string OPTIONAL
	WSDATA   cFILTRANSFTO              AS string OPTIONAL
	WSDATA   cFUNCTIONDESC             AS string OPTIONAL
	WSDATA   cFUNCTIONID               AS string OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   cPOSITION                 AS string OPTIONAL
	WSDATA   cPOSITIONID               AS string OPTIONAL
	WSDATA   nRECNUMBER                AS integer OPTIONAL
	WSDATA   cREGTRANSFFROM            AS string OPTIONAL
	WSDATA   cREGTRANSFTO              AS string OPTIONAL
	WSDATA   nSALARY                   AS float OPTIONAL
	WSDATA   cSITUACAO                 AS string OPTIONAL
	WSDATA   cTRANSFDATE               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF
Return

WSMETHOD CLONE WSCLIENT RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF
	Local oClone := RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF():NEW()
	oClone:cADMISSIONDATE       := ::cADMISSIONDATE
	oClone:cCATFUNC             := ::cCATFUNC
	oClone:cCATFUNCDESC         := ::cCATFUNCDESC
	oClone:cCCTRANSFFROM        := ::cCCTRANSFFROM
	oClone:cCCTRANSFTO          := ::cCCTRANSFTO
	oClone:cCOMPANYFROM         := ::cCOMPANYFROM
	oClone:cCOMPANYTO           := ::cCOMPANYTO
	oClone:cCOST                := ::cCOST
	oClone:cCOSTID              := ::cCOSTID
	oClone:cDEPARTMENT          := ::cDEPARTMENT
	oClone:cDESCRDEPARTMENT     := ::cDESCRDEPARTMENT
	oClone:cDESCSITUACAO        := ::cDESCSITUACAO
	oClone:cEMAIL               := ::cEMAIL
	oClone:cFILIALDESCR         := ::cFILIALDESCR
	oClone:cFILTRANSFFROM       := ::cFILTRANSFFROM
	oClone:cFILTRANSFTO         := ::cFILTRANSFTO
	oClone:cFUNCTIONDESC        := ::cFUNCTIONDESC
	oClone:cFUNCTIONID          := ::cFUNCTIONID
	oClone:cNAME                := ::cNAME
	oClone:cPOSITION            := ::cPOSITION
	oClone:cPOSITIONID          := ::cPOSITIONID
	oClone:nRECNUMBER           := ::nRECNUMBER
	oClone:cREGTRANSFFROM       := ::cREGTRANSFFROM
	oClone:cREGTRANSFTO         := ::cREGTRANSFTO
	oClone:nSALARY              := ::nSALARY
	oClone:cSITUACAO            := ::cSITUACAO
	oClone:cTRANSFDATE          := ::cTRANSFDATE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEMPLOYEETRANSF_DATAEMPLOYEETRANSF
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADMISSIONDATE     :=  WSAdvValue( oResponse,"_ADMISSIONDATE","string",NIL,"Property cADMISSIONDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCATFUNC           :=  WSAdvValue( oResponse,"_CATFUNC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCATFUNCDESC       :=  WSAdvValue( oResponse,"_CATFUNCDESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCCTRANSFFROM      :=  WSAdvValue( oResponse,"_CCTRANSFFROM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCCTRANSFTO        :=  WSAdvValue( oResponse,"_CCTRANSFTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOMPANYFROM       :=  WSAdvValue( oResponse,"_COMPANYFROM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOMPANYTO         :=  WSAdvValue( oResponse,"_COMPANYTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOST              :=  WSAdvValue( oResponse,"_COST","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCOSTID            :=  WSAdvValue( oResponse,"_COSTID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDEPARTMENT        :=  WSAdvValue( oResponse,"_DEPARTMENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCRDEPARTMENT   :=  WSAdvValue( oResponse,"_DESCRDEPARTMENT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCSITUACAO      :=  WSAdvValue( oResponse,"_DESCSITUACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILIALDESCR       :=  WSAdvValue( oResponse,"_FILIALDESCR","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILTRANSFFROM     :=  WSAdvValue( oResponse,"_FILTRANSFFROM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFILTRANSFTO       :=  WSAdvValue( oResponse,"_FILTRANSFTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFUNCTIONDESC      :=  WSAdvValue( oResponse,"_FUNCTIONDESC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFUNCTIONID        :=  WSAdvValue( oResponse,"_FUNCTIONID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPOSITION          :=  WSAdvValue( oResponse,"_POSITION","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPOSITIONID        :=  WSAdvValue( oResponse,"_POSITIONID","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nRECNUMBER         :=  WSAdvValue( oResponse,"_RECNUMBER","integer",NIL,NIL,NIL,"N",NIL,NIL) 
	::cREGTRANSFFROM     :=  WSAdvValue( oResponse,"_REGTRANSFFROM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cREGTRANSFTO       :=  WSAdvValue( oResponse,"_REGTRANSFTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nSALARY            :=  WSAdvValue( oResponse,"_SALARY","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cSITUACAO          :=  WSAdvValue( oResponse,"_SITUACAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTRANSFDATE        :=  WSAdvValue( oResponse,"_TRANSFDATE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


