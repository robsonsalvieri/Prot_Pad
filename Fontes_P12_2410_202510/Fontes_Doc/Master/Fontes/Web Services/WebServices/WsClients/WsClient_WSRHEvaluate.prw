#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8888/ws/RHEVALUATE.apw?WSDL
Gerado em        06/19/16 17:13:49
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _AZORMAW ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHEVALUATE
------------------------------------------------------------------------------- */

WSCLIENT WSRHEVALUATE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ALLEVALUATE
	WSMETHOD VIEWEVALUATE
	WSMETHOD VIEWEVALUATOR

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cBRANCH                   AS string
	WSDATA   cPARTICIPANT              AS string
	WSDATA   cEVALUATOR                AS string
	WSDATA   cEVALUATION               AS string
	WSDATA   oWSALLEVALUATERESULT      AS RHEVALUATE_TEVALUATEALL
	WSDATA   oWSVIEWEVALUATERESULT     AS RHEVALUATE_TEVALUATEVIEW
	WSDATA   oWSVIEWEVALUATORRESULT    AS RHEVALUATE_TEVALUATORVIEW

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHEVALUATE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160525 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHEVALUATE
	::oWSALLEVALUATERESULT := RHEVALUATE_TEVALUATEALL():New()
	::oWSVIEWEVALUATERESULT := RHEVALUATE_TEVALUATEVIEW():New()
	::oWSVIEWEVALUATORRESULT := RHEVALUATE_TEVALUATORVIEW():New()
Return

WSMETHOD RESET WSCLIENT WSRHEVALUATE
	::cBRANCH            := NIL 
	::cPARTICIPANT       := NIL 
	::cEVALUATOR         := NIL 
	::cEVALUATION        := NIL 
	::oWSALLEVALUATERESULT := NIL 
	::oWSVIEWEVALUATERESULT := NIL 
	::oWSVIEWEVALUATORRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHEVALUATE
Local oClone := WSRHEVALUATE():New()
	oClone:_URL          := ::_URL 
	oClone:cBRANCH       := ::cBRANCH
	oClone:cPARTICIPANT  := ::cPARTICIPANT
	oClone:cEVALUATOR    := ::cEVALUATOR
	oClone:cEVALUATION   := ::cEVALUATION
	oClone:oWSALLEVALUATERESULT :=  IIF(::oWSALLEVALUATERESULT = NIL , NIL ,::oWSALLEVALUATERESULT:Clone() )
	oClone:oWSVIEWEVALUATERESULT :=  IIF(::oWSVIEWEVALUATERESULT = NIL , NIL ,::oWSVIEWEVALUATERESULT:Clone() )
	oClone:oWSVIEWEVALUATORRESULT :=  IIF(::oWSVIEWEVALUATORRESULT = NIL , NIL ,::oWSVIEWEVALUATORRESULT:Clone() )
Return oClone

// WSDL Method ALLEVALUATE of Service WSRHEVALUATE

WSMETHOD ALLEVALUATE WSSEND cBRANCH,cPARTICIPANT,cEVALUATOR,cEVALUATION WSRECEIVE oWSALLEVALUATERESULT WSCLIENT WSRHEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ALLEVALUATE xmlns="http://localhost:8888/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PARTICIPANT", ::cPARTICIPANT, cPARTICIPANT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EVALUATOR", ::cEVALUATOR, cEVALUATOR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EVALUATION", ::cEVALUATION, cEVALUATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</ALLEVALUATE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8888/ALLEVALUATE",; 
	"DOCUMENT","http://localhost:8888/",,"1.031217",; 
	"http://localhost:8888/ws/RHEVALUATE.apw")

::Init()
::oWSALLEVALUATERESULT:SoapRecv( WSAdvValue( oXmlRet,"_ALLEVALUATERESPONSE:_ALLEVALUATERESULT","TEVALUATEALL",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VIEWEVALUATE of Service WSRHEVALUATE

WSMETHOD VIEWEVALUATE WSSEND cBRANCH,cPARTICIPANT,cEVALUATOR WSRECEIVE oWSVIEWEVALUATERESULT WSCLIENT WSRHEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VIEWEVALUATE xmlns="http://localhost:8888/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PARTICIPANT", ::cPARTICIPANT, cPARTICIPANT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EVALUATOR", ::cEVALUATOR, cEVALUATOR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</VIEWEVALUATE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8888/VIEWEVALUATE",; 
	"DOCUMENT","http://localhost:8888/",,"1.031217",; 
	"http://localhost:8888/ws/RHEVALUATE.apw")

::Init()
::oWSVIEWEVALUATERESULT:SoapRecv( WSAdvValue( oXmlRet,"_VIEWEVALUATERESPONSE:_VIEWEVALUATERESULT","TEVALUATEVIEW",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VIEWEVALUATOR of Service WSRHEVALUATE

WSMETHOD VIEWEVALUATOR WSSEND cBRANCH,cPARTICIPANT,cEVALUATION WSRECEIVE oWSVIEWEVALUATORRESULT WSCLIENT WSRHEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VIEWEVALUATOR xmlns="http://localhost:8888/">'
cSoap += WSSoapValue("BRANCH", ::cBRANCH, cBRANCH , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PARTICIPANT", ::cPARTICIPANT, cPARTICIPANT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EVALUATION", ::cEVALUATION, cEVALUATION , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</VIEWEVALUATOR>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://localhost:8888/VIEWEVALUATOR",; 
	"DOCUMENT","http://localhost:8888/",,"1.031217",; 
	"http://localhost:8888/ws/RHEVALUATE.apw")

::Init()
::oWSVIEWEVALUATORRESULT:SoapRecv( WSAdvValue( oXmlRet,"_VIEWEVALUATORRESPONSE:_VIEWEVALUATORRESULT","TEVALUATORVIEW",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TEVALUATEALL

WSSTRUCT RHEVALUATE_TEVALUATEALL
	WSDATA   oWSITENS                  AS RHEVALUATE_ARRAYOFTEVALUATEALLLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_TEVALUATEALL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_TEVALUATEALL
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_TEVALUATEALL
	Local oClone := RHEVALUATE_TEVALUATEALL():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_TEVALUATEALL
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTEVALUATEALLLIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHEVALUATE_ARRAYOFTEVALUATEALLLIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure TEVALUATEVIEW

WSSTRUCT RHEVALUATE_TEVALUATEVIEW
	WSDATA   oWSITENS                  AS RHEVALUATE_ARRAYOFTEVALUATELIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_TEVALUATEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_TEVALUATEVIEW
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_TEVALUATEVIEW
	Local oClone := RHEVALUATE_TEVALUATEVIEW():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_TEVALUATEVIEW
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTEVALUATELIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHEVALUATE_ARRAYOFTEVALUATELIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure TEVALUATORVIEW

WSSTRUCT RHEVALUATE_TEVALUATORVIEW
	WSDATA   oWSITENS                  AS RHEVALUATE_ARRAYOFTEVALUATELIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_TEVALUATORVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_TEVALUATORVIEW
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_TEVALUATORVIEW
	Local oClone := RHEVALUATE_TEVALUATORVIEW():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_TEVALUATORVIEW
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFTEVALUATELIST",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := RHEVALUATE_ARRAYOFTEVALUATELIST():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFTEVALUATEALLLIST

WSSTRUCT RHEVALUATE_ARRAYOFTEVALUATEALLLIST
	WSDATA   oWSTEVALUATEALLLIST       AS RHEVALUATE_TEVALUATEALLLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_ARRAYOFTEVALUATEALLLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_ARRAYOFTEVALUATEALLLIST
	::oWSTEVALUATEALLLIST  := {} // Array Of  RHEVALUATE_TEVALUATEALLLIST():New()
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_ARRAYOFTEVALUATEALLLIST
	Local oClone := RHEVALUATE_ARRAYOFTEVALUATEALLLIST():NEW()
	oClone:oWSTEVALUATEALLLIST := NIL
	If ::oWSTEVALUATEALLLIST <> NIL 
		oClone:oWSTEVALUATEALLLIST := {}
		aEval( ::oWSTEVALUATEALLLIST , { |x| aadd( oClone:oWSTEVALUATEALLLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_ARRAYOFTEVALUATEALLLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TEVALUATEALLLIST","TEVALUATEALLLIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTEVALUATEALLLIST , RHEVALUATE_TEVALUATEALLLIST():New() )
			::oWSTEVALUATEALLLIST[len(::oWSTEVALUATEALLLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFTEVALUATELIST

WSSTRUCT RHEVALUATE_ARRAYOFTEVALUATELIST
	WSDATA   oWSTEVALUATELIST          AS RHEVALUATE_TEVALUATELIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_ARRAYOFTEVALUATELIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_ARRAYOFTEVALUATELIST
	::oWSTEVALUATELIST     := {} // Array Of  RHEVALUATE_TEVALUATELIST():New()
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_ARRAYOFTEVALUATELIST
	Local oClone := RHEVALUATE_ARRAYOFTEVALUATELIST():NEW()
	oClone:oWSTEVALUATELIST := NIL
	If ::oWSTEVALUATELIST <> NIL 
		oClone:oWSTEVALUATELIST := {}
		aEval( ::oWSTEVALUATELIST , { |x| aadd( oClone:oWSTEVALUATELIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_ARRAYOFTEVALUATELIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TEVALUATELIST","TEVALUATELIST",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTEVALUATELIST , RHEVALUATE_TEVALUATELIST():New() )
			::oWSTEVALUATELIST[len(::oWSTEVALUATELIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure TEVALUATEALLLIST

WSSTRUCT RHEVALUATE_TEVALUATEALLLIST
	WSDATA   cCODADO                   AS string
	WSDATA   cCODAVA                   AS string
	WSDATA   cCODDOR                   AS string
	WSDATA   cCODTYPE                  AS string
	WSDATA   cDATE                     AS string
	WSDATA   cLINK                     AS string
	WSDATA   cNIVEL                    AS string
	WSDATA   cNOME                     AS string
	WSDATA   cPROJECT                  AS string
	WSDATA   cTIPO                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_TEVALUATEALLLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_TEVALUATEALLLIST
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_TEVALUATEALLLIST
	Local oClone := RHEVALUATE_TEVALUATEALLLIST():NEW()
	oClone:cCODADO              := ::cCODADO
	oClone:cCODAVA              := ::cCODAVA
	oClone:cCODDOR              := ::cCODDOR
	oClone:cCODTYPE             := ::cCODTYPE
	oClone:cDATE                := ::cDATE
	oClone:cLINK                := ::cLINK
	oClone:cNIVEL               := ::cNIVEL
	oClone:cNOME                := ::cNOME
	oClone:cPROJECT             := ::cPROJECT
	oClone:cTIPO                := ::cTIPO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_TEVALUATEALLLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODADO            :=  WSAdvValue( oResponse,"_CODADO","string",NIL,"Property cCODADO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODAVA            :=  WSAdvValue( oResponse,"_CODAVA","string",NIL,"Property cCODAVA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODDOR            :=  WSAdvValue( oResponse,"_CODDOR","string",NIL,"Property cCODDOR as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODTYPE           :=  WSAdvValue( oResponse,"_CODTYPE","string",NIL,"Property cCODTYPE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDATE              :=  WSAdvValue( oResponse,"_DATE","string",NIL,"Property cDATE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLINK              :=  WSAdvValue( oResponse,"_LINK","string",NIL,"Property cLINK as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNIVEL             :=  WSAdvValue( oResponse,"_NIVEL","string",NIL,"Property cNIVEL as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cNOME              :=  WSAdvValue( oResponse,"_NOME","string",NIL,"Property cNOME as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPROJECT           :=  WSAdvValue( oResponse,"_PROJECT","string",NIL,"Property cPROJECT as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cTIPO              :=  WSAdvValue( oResponse,"_TIPO","string",NIL,"Property cTIPO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure TEVALUATELIST

WSSTRUCT RHEVALUATE_TEVALUATELIST
	WSDATA   cCOD                      AS string
	WSDATA   cDESC                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHEVALUATE_TEVALUATELIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHEVALUATE_TEVALUATELIST
Return

WSMETHOD CLONE WSCLIENT RHEVALUATE_TEVALUATELIST
	Local oClone := RHEVALUATE_TEVALUATELIST():NEW()
	oClone:cCOD                 := ::cCOD
	oClone:cDESC                := ::cDESC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHEVALUATE_TEVALUATELIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCOD               :=  WSAdvValue( oResponse,"_COD","string",NIL,"Property cCOD as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESC              :=  WSAdvValue( oResponse,"_DESC","string",NIL,"Property cDESC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return


