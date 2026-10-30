#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/wsemp/RHARTIFACT.apw?WSDL
Gerado em        09/28/16 11:15:00
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RWTKBTJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHARTIFACT
------------------------------------------------------------------------------- */

WSCLIENT WSRHARTIFACT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD BROWSEARTIFACT
	WSMETHOD GETCONFIGARTIFACT
	WSMETHOD GETCRITERARTIFACT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cBRANCH                   AS string
	WSDATA   cREGISTRATION             AS string
	WSDATA   oWSBROWSEARTIFACTRESULT   AS RHARTIFACT_TARTIFACTBROWSE
	WSDATA   oWSGETCONFIGARTIFACTRESULT AS RHARTIFACT_TCONFIGARTIFACT
	WSDATA   cCODECRITER               AS string
	WSDATA   cALIAS                    AS string
	WSDATA   lGETCRITERARTIFACTRESULT  AS boolean

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHARTIFACT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160713 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHARTIFACT
	::oWSBROWSEARTIFACTRESULT := RHARTIFACT_TARTIFACTBROWSE():New()
	::oWSGETCONFIGARTIFACTRESULT := RHARTIFACT_TCONFIGARTIFACT():New()
Return

WSMETHOD RESET WSCLIENT WSRHARTIFACT
	::cBRANCH            := NIL 
	::cREGISTRATION      := NIL 
	::oWSBROWSEARTIFACTRESULT := NIL 
	::oWSGETCONFIGARTIFACTRESULT := NIL 
	::cCODECRITER        := NIL 
	::cALIAS             := NIL 
	::lGETCRITERARTIFACTRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHARTIFACT
Local oClone := WSRHARTIFACT():New()
	oClone:_URL          := ::_URL 
	oClone:cBRANCH       := ::cBRANCH
	oClone:cREGISTRATION := ::cREGISTRATION
	oClone:oWSBROWSEARTIFACTRESULT :=  IIF(::oWSBROWSEARTIFACTRESULT = NIL , NIL ,::oWSBROWSEARTIFACTRESULT:Clone() )
	oClone:oWSGETCONFIGARTIFACTRESULT :=  IIF(::oWSGETCONFIGARTIFACTRESULT = NIL , NIL ,::oWSGETCONFIGARTIFACTRESULT:Clone() )
	oClone:cCODECRITER   := ::cCODECRITER
	oClone:cALIAS        := ::cALIAS
	oClone:lGETCRITERARTIFACTRESULT := ::lGETCRITERARTIFACTRESULT
Return oClone

// WSDL Method BROWSEARTIFACT of Service WSRHARTIFACT

WSMETHOD BROWSEARTIFACT WSSEND cBRANCH,cREGISTRATION WSRECEIVE oWSBROWSEARTIFACTRESULT WSCLIENT WSRHARTIFACT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BROWSEARTIFACT xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</BROWSEARTIFACT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/BROWSEARTIFACT",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/wsemp/RHARTIFACT.apw")

::Init()
::oWSBROWSEARTIFACTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_BROWSEARTIFACTRESPONSE:_BROWSEARTIFACTRESULT","TARTIFACTBROWSE",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCONFIGARTIFACT of Service WSRHARTIFACT

WSMETHOD GETCONFIGARTIFACT WSSEND cBRANCH,cREGISTRATION WSRECEIVE oWSGETCONFIGARTIFACTRESULT WSCLIENT WSRHARTIFACT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCONFIGARTIFACT xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETCONFIGARTIFACT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETCONFIGARTIFACT",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/wsemp/RHARTIFACT.apw")

::Init()
::oWSGETCONFIGARTIFACTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCONFIGARTIFACTRESPONSE:_GETCONFIGARTIFACTRESULT","TCONFIGARTIFACT",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCRITERARTIFACT of Service WSRHARTIFACT

WSMETHOD GETCRITERARTIFACT WSSEND cBRANCH,cREGISTRATION,cCODECRITER,cALIAS WSRECEIVE lGETCRITERARTIFACTRESULT WSCLIENT WSRHARTIFACT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCRITERARTIFACT xmlns="http://localhost:8080/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REGISTRATION", ::cREGISTRATION, cREGISTRATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODECRITER", ::cCODECRITER, cCODECRITER , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("ALIAS", ::cALIAS, cALIAS , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETCRITERARTIFACT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8080/GETCRITERARTIFACT",; 
	"DOCUMENT","http://localhost:8080/",,"1.031217",; 
	"http://localhost:8080/wsemp/RHARTIFACT.apw")

::Init()
::lGETCRITERARTIFACTRESULT :=  WSAdvValue( oXmlRet,"_GETCRITERARTIFACTRESPONSE:_GETCRITERARTIFACTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TARTIFACTBROWSE

WSSTRUCT RHARTIFACT_TARTIFACTBROWSE
	WSDATA   oWSITENS                  AS RHARTIFACT_ARRAYOFTARTIFACTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_TARTIFACTBROWSE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_TARTIFACTBROWSE
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_TARTIFACTBROWSE
	Local oClone := RHARTIFACT_TARTIFACTBROWSE():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_TARTIFACTBROWSE
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTARTIFACTLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHARTIFACT_ARRAYOFTARTIFACTLIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure TCONFIGARTIFACT

WSSTRUCT RHARTIFACT_TCONFIGARTIFACT
	WSDATA   oWSITENS                  AS RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_TCONFIGARTIFACT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_TCONFIGARTIFACT
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_TCONFIGARTIFACT
	Local oClone := RHARTIFACT_TCONFIGARTIFACT():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_TCONFIGARTIFACT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTCONFIGARTIFACTLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFTARTIFACTLIST

WSSTRUCT RHARTIFACT_ARRAYOFTARTIFACTLIST
	WSDATA   oWSTARTIFACTLIST          AS RHARTIFACT_TARTIFACTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_ARRAYOFTARTIFACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_ARRAYOFTARTIFACTLIST
	::oWSTARTIFACTLIST     := {} // Array Of  RHARTIFACT_TARTIFACTLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_ARRAYOFTARTIFACTLIST
	Local oClone := RHARTIFACT_ARRAYOFTARTIFACTLIST():NEW()
	oClone:oWSTARTIFACTLIST := NIL
	If ::oWSTARTIFACTLIST <> NIL 
		oClone:oWSTARTIFACTLIST := {}
		aEval( ::oWSTARTIFACTLIST , { |x| aadd( oClone:oWSTARTIFACTLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_ARRAYOFTARTIFACTLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TARTIFACTLIST","TARTIFACTLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTARTIFACTLIST , RHARTIFACT_TARTIFACTLIST():New() )
			::oWSTARTIFACTLIST[len(::oWSTARTIFACTLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTCONFIGARTIFACTLIST

WSSTRUCT RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST
	WSDATA   oWSTCONFIGARTIFACTLIST    AS RHARTIFACT_TCONFIGARTIFACTLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST
	::oWSTCONFIGARTIFACTLIST := {} // Array Of  RHARTIFACT_TCONFIGARTIFACTLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST
	Local oClone := RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST():NEW()
	oClone:oWSTCONFIGARTIFACTLIST := NIL
	If ::oWSTCONFIGARTIFACTLIST <> NIL 
		oClone:oWSTCONFIGARTIFACTLIST := {}
		aEval( ::oWSTCONFIGARTIFACTLIST , { |x| aadd( oClone:oWSTCONFIGARTIFACTLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_ARRAYOFTCONFIGARTIFACTLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TCONFIGARTIFACTLIST","TCONFIGARTIFACTLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTCONFIGARTIFACTLIST , RHARTIFACT_TCONFIGARTIFACTLIST():New() )
			::oWSTCONFIGARTIFACTLIST[len(::oWSTCONFIGARTIFACTLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TARTIFACTLIST

WSSTRUCT RHARTIFACT_TARTIFACTLIST
	WSDATA   cACTIONLINK               AS string
	WSDATA   cALIAS                    AS string
	WSDATA   cBRANCH                   AS string
	WSDATA   cCATEGORY                 AS string
	WSDATA   cCODE                     AS string
	WSDATA   cCODECRITER               AS string
	WSDATA   cCOMPANY                  AS string
	WSDATA   cMESSAGE                  AS string
	WSDATA   cPROTOCOL                 AS string
	WSDATA   cTITLELINK                AS string
	WSDATA   cTYPEARTEF                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_TARTIFACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_TARTIFACTLIST
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_TARTIFACTLIST
	Local oClone := RHARTIFACT_TARTIFACTLIST():NEW()
	oClone:cACTIONLINK          := ::cACTIONLINK
	oClone:cALIAS               := ::cALIAS
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCATEGORY            := ::cCATEGORY
	oClone:cCODE                := ::cCODE
	oClone:cCODECRITER          := ::cCODECRITER
	oClone:cCOMPANY             := ::cCOMPANY
	oClone:cMESSAGE             := ::cMESSAGE
	oClone:cPROTOCOL            := ::cPROTOCOL
	oClone:cTITLELINK           := ::cTITLELINK
	oClone:cTYPEARTEF           := ::cTYPEARTEF
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_TARTIFACTLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cACTIONLINK        :=  WSAdvValue( oResponse,"_ACTIONLINK","string",NIL,"Property cACTIONLINK as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cALIAS             :=  WSAdvValue( oResponse,"_ALIAS","string",NIL,"Property cALIAS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,"Property cBRANCH as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCATEGORY          :=  WSAdvValue( oResponse,"_CATEGORY","string",NIL,"Property cCATEGORY as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODE              :=  WSAdvValue( oResponse,"_CODE","string",NIL,"Property cCODE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODECRITER        :=  WSAdvValue( oResponse,"_CODECRITER","string",NIL,"Property cCODECRITER as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCOMPANY           :=  WSAdvValue( oResponse,"_COMPANY","string",NIL,"Property cCOMPANY as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cMESSAGE           :=  WSAdvValue( oResponse,"_MESSAGE","string",NIL,"Property cMESSAGE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPROTOCOL          :=  WSAdvValue( oResponse,"_PROTOCOL","string",NIL,"Property cPROTOCOL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTITLELINK         :=  WSAdvValue( oResponse,"_TITLELINK","string",NIL,"Property cTITLELINK as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTYPEARTEF         :=  WSAdvValue( oResponse,"_TYPEARTEF","string",NIL,"Property cTYPEARTEF as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TCONFIGARTIFACTLIST

WSSTRUCT RHARTIFACT_TCONFIGARTIFACTLIST
	WSDATA   cFILETO                   AS string
	WSDATA   cINSTANAME                AS string
	WSDATA   cKEYINI                   AS string
	WSDATA   cPORTWEB                  AS string
	WSDATA   cSERV                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHARTIFACT_TCONFIGARTIFACTLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHARTIFACT_TCONFIGARTIFACTLIST
Return

WSMETHOD CLONE WSCLIENT RHARTIFACT_TCONFIGARTIFACTLIST
	Local oClone := RHARTIFACT_TCONFIGARTIFACTLIST():NEW()
	oClone:cFILETO              := ::cFILETO
	oClone:cINSTANAME           := ::cINSTANAME
	oClone:cKEYINI              := ::cKEYINI
	oClone:cPORTWEB             := ::cPORTWEB
	oClone:cSERV                := ::cSERV
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHARTIFACT_TCONFIGARTIFACTLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFILETO            :=  WSAdvValue( oResponse,"_FILETO","string",NIL,"Property cFILETO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cINSTANAME         :=  WSAdvValue( oResponse,"_INSTANAME","string",NIL,"Property cINSTANAME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cKEYINI            :=  WSAdvValue( oResponse,"_KEYINI","string",NIL,"Property cKEYINI as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPORTWEB           :=  WSAdvValue( oResponse,"_PORTWEB","string",NIL,"Property cPORTWEB as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSERV              :=  WSAdvValue( oResponse,"_SERV","string",NIL,"Property cSERV as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


