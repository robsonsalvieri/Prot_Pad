#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost/webservices/SIGADW.apw?WSDL
Gerado em        12/27/06 13:52:38
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.041104
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

/* -------------------------------------------------------------------------------
WSDL Service WSSIGADW
------------------------------------------------------------------------------- */

WSCLIENT WSSIGADW

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD INICGRAPH
	WSMETHOD INICTABLE
	WSMETHOD LISTCONSULTAS
	WSMETHOD LOGIN
	WSMETHOD LOGINDW
	WSMETHOD LOGOUT
	WSMETHOD LOGOUTDW
	WSMETHOD PROCCONS
	WSMETHOD RETCONSULTA
	WSMETHOD RETCUBE
	WSMETHOD RETCUBES
	WSMETHOD RETDW

	WSDATA   _URL                      AS String
	WSDATA   cWSSESSION                AS string
	WSDATA   cCONSULTA                 AS string
	WSDATA   cINICGRAPHRESULT          AS string
	WSDATA   cINICTABLERESULT          AS string
	WSDATA   oWSLISTCONSULTASRESULT    AS SIGADW_ARRAYOFQUERYLIST
	WSDATA   cHOST                     AS string
	WSDATA   cDW                       AS string
	WSDATA   cDWID                       AS string
	WSDATA   cUSERLOGIN                AS string
	WSDATA   cUSERPASSWORD             AS string
	WSDATA   cLOGINRESULT              AS string
	WSDATA   cSESSIONID                AS string
	WSDATA   cDWNAME                   AS string
	WSDATA   lLOGINDWRESULT            AS boolean
	WSDATA   lLOGOUTRESULT             AS boolean
	WSDATA   cLOGOUTDWRESULT           AS string
	WSDATA   cPROCCONSRESULT           AS string
	WSDATA   nCONSULTAID               AS integer
	WSDATA   lRETVALUE                 AS boolean
	WSDATA   oWSRETCONSULTARESULT      AS SIGADW_ARRAYOFCONSULTASTRU
	WSDATA   nCUBEID                   AS integer
	WSDATA   oWSRETCUBERESULT          AS SIGADW_ARRAYOFCUBEDETAIL
	WSDATA   oWSRETCUBESRESULT         AS SIGADW_ARRAYOFCUBELIST
	WSDATA   oWSRETDWRESULT            AS SIGADW_ARRAYOFDWLIST

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSIGADW
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.060906P] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSIGADW
	::oWSLISTCONSULTASRESULT := SIGADW_ARRAYOFQUERYLIST():New()
	::oWSRETCONSULTARESULT := SIGADW_ARRAYOFCONSULTASTRU():New()
	::oWSRETCUBERESULT   := SIGADW_ARRAYOFCUBEDETAIL():New()
	::oWSRETCUBESRESULT  := SIGADW_ARRAYOFCUBELIST():New()
	::oWSRETDWRESULT     := SIGADW_ARRAYOFDWLIST():New()
Return

WSMETHOD RESET WSCLIENT WSSIGADW
	::cWSSESSION         := NIL 
	::cCONSULTA          := NIL 
	::cINICGRAPHRESULT   := NIL 
	::cINICTABLERESULT   := NIL 
	::oWSLISTCONSULTASRESULT := NIL 
	::cHOST              := NIL 
	::cDW                := NIL 
	::cUSERLOGIN         := NIL 
	::cUSERPASSWORD      := NIL 
	::cLOGINRESULT       := NIL 
	::cSESSIONID         := NIL 
	::cDWNAME            := NIL 
	::lLOGINDWRESULT     := NIL 
	::lLOGOUTRESULT      := NIL 
	::cLOGOUTDWRESULT    := NIL 
	::cPROCCONSRESULT    := NIL 
	::nCONSULTAID        := NIL 
	::lRETVALUE          := NIL 
	::oWSRETCONSULTARESULT := NIL 
	::nCUBEID            := NIL 
	::oWSRETCUBERESULT   := NIL 
	::oWSRETCUBESRESULT  := NIL 
	::oWSRETDWRESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSIGADW
Local oClone := WSSIGADW():New()
	oClone:_URL          := ::_URL 
	oClone:cWSSESSION    := ::cWSSESSION
	oClone:cCONSULTA     := ::cCONSULTA
	oClone:cINICGRAPHRESULT := ::cINICGRAPHRESULT
	oClone:cINICTABLERESULT := ::cINICTABLERESULT
	oClone:oWSLISTCONSULTASRESULT :=  IIF(::oWSLISTCONSULTASRESULT = NIL , NIL ,::oWSLISTCONSULTASRESULT:Clone() )
	oClone:cHOST         := ::cHOST
	oClone:cDW           := ::cDW
	oClone:cUSERLOGIN    := ::cUSERLOGIN
	oClone:cUSERPASSWORD := ::cUSERPASSWORD
	oClone:cLOGINRESULT  := ::cLOGINRESULT
	oClone:cSESSIONID    := ::cSESSIONID
	oClone:cDWNAME       := ::cDWNAME
	oClone:lLOGINDWRESULT := ::lLOGINDWRESULT
	oClone:lLOGOUTRESULT := ::lLOGOUTRESULT
	oClone:cLOGOUTDWRESULT := ::cLOGOUTDWRESULT
	oClone:cPROCCONSRESULT := ::cPROCCONSRESULT
	oClone:nCONSULTAID   := ::nCONSULTAID
	oClone:lRETVALUE     := ::lRETVALUE
	oClone:oWSRETCONSULTARESULT :=  IIF(::oWSRETCONSULTARESULT = NIL , NIL ,::oWSRETCONSULTARESULT:Clone() )
	oClone:nCUBEID       := ::nCUBEID
	oClone:oWSRETCUBERESULT :=  IIF(::oWSRETCUBERESULT = NIL , NIL ,::oWSRETCUBERESULT:Clone() )
	oClone:oWSRETCUBESRESULT :=  IIF(::oWSRETCUBESRESULT = NIL , NIL ,::oWSRETCUBESRESULT:Clone() )
	oClone:oWSRETDWRESULT :=  IIF(::oWSRETDWRESULT = NIL , NIL ,::oWSRETDWRESULT:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method INICGRAPH of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD INICGRAPH WSSEND cWSSESSION,cCONSULTA WSRECEIVE cINICGRAPHRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INICGRAPH xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CONSULTA", ::cCONSULTA, cCONSULTA , "string", .T. , .F., 0 ) 
cSoap += "</INICGRAPH>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/INICGRAPH",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::cINICGRAPHRESULT   :=  WSAdvValue( oXmlRet,"_INICGRAPHRESPONSE:_INICGRAPHRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method INICTABLE of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD INICTABLE WSSEND cWSSESSION,cCONSULTA WSRECEIVE cINICTABLERESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<INICTABLE xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CONSULTA", ::cCONSULTA, cCONSULTA , "string", .T. , .F., 0 ) 
cSoap += "</INICTABLE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/INICTABLE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::cINICTABLERESULT   :=  WSAdvValue( oXmlRet,"_INICTABLERESPONSE:_INICTABLERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method LISTCONSULTAS of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD LISTCONSULTAS WSSEND cWSSESSION,cDWID WSRECEIVE oWSLISTCONSULTASRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LISTCONSULTAS xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("DWID", ::cDWID, cDWID , "string", .T. , .F., 0 ) 
cSoap += "</LISTCONSULTAS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/LISTCONSULTAS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::oWSLISTCONSULTASRESULT:SoapRecv( WSAdvValue( oXmlRet,"_LISTCONSULTASRESPONSE:_LISTCONSULTASRESULT","ARRAYOFQUERYLIST",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.   

/* -------------------------------------------------------------------------------
WSDL Method LOGIN of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD LOGIN WSSEND cHOST,cDW,cUSERLOGIN,cUSERPASSWORD WSRECEIVE cLOGINRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGIN xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("HOST", ::cHOST, cHOST , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("DW", ::cDW, cDW , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("USERLOGIN", ::cUSERLOGIN, cUSERLOGIN , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("USERPASSWORD", ::cUSERPASSWORD, cUSERPASSWORD , "string", .T. , .F., 0 ) 
cSoap += "</LOGIN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/LOGIN",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::cLOGINRESULT       :=  WSAdvValue( oXmlRet,"_LOGINRESPONSE:_LOGINRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method LOGINDW of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD LOGINDW WSSEND cSESSIONID,cDWNAME WSRECEIVE lLOGINDWRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGINDW xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("DWNAME", ::cDWNAME, cDWNAME , "string", .T. , .F., 0 ) 
cSoap += "</LOGINDW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/LOGINDW",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::lLOGINDWRESULT     :=  WSAdvValue( oXmlRet,"_LOGINDWRESPONSE:_LOGINDWRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method LOGOUT of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD LOGOUT WSSEND cSESSIONID WSRECEIVE lLOGOUTRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGOUT xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("SESSIONID", ::cSESSIONID, cSESSIONID , "string", .T. , .F., 0 ) 
cSoap += "</LOGOUT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/LOGOUT",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::lLOGOUTRESULT      :=  WSAdvValue( oXmlRet,"_LOGOUTRESPONSE:_LOGOUTRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method LOGOUTDW of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD LOGOUTDW WSSEND cWSSESSION WSRECEIVE cLOGOUTDWRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LOGOUTDW xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += "</LOGOUTDW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/LOGOUTDW",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::cLOGOUTDWRESULT    :=  WSAdvValue( oXmlRet,"_LOGOUTDWRESPONSE:_LOGOUTDWRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method PROCCONS of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD PROCCONS WSSEND cWSSESSION WSRECEIVE cPROCCONSRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PROCCONS xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += "</PROCCONS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/PROCCONS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::cPROCCONSRESULT    :=  WSAdvValue( oXmlRet,"_PROCCONSRESPONSE:_PROCCONSRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETCONSULTA of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD RETCONSULTA WSSEND cWSSESSION,nCONSULTAID,lRETVALUE WSRECEIVE oWSRETCONSULTARESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETCONSULTA xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CONSULTAID", ::nCONSULTAID, nCONSULTAID , "integer", .T. , .F., 0 ) 
cSoap += WSSoapValue("RETVALUE", ::lRETVALUE, lRETVALUE , "boolean", .F. , .F., 0 ) 
cSoap += "</RETCONSULTA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/RETCONSULTA",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::oWSRETCONSULTARESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETCONSULTARESPONSE:_RETCONSULTARESULT","ARRAYOFCONSULTASTRU",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETCUBE of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD RETCUBE WSSEND cWSSESSION,nCUBEID WSRECEIVE oWSRETCUBERESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETCUBE xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CUBEID", ::nCUBEID, nCUBEID , "integer", .T. , .F., 0 ) 
cSoap += "</RETCUBE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/RETCUBE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::oWSRETCUBERESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETCUBERESPONSE:_RETCUBERESULT","ARRAYOFCUBEDETAIL",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETCUBES of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD RETCUBES WSSEND cWSSESSION WSRECEIVE oWSRETCUBESRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETCUBES xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += "</RETCUBES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/RETCUBES",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::oWSRETCUBESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETCUBESRESPONSE:_RETCUBESRESULT","ARRAYOFCUBELIST",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETDW of Service WSSIGADW
------------------------------------------------------------------------------- */

WSMETHOD RETDW WSSEND cWSSESSION WSRECEIVE oWSRETDWRESULT WSCLIENT WSSIGADW
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETDW xmlns="http://webservices.microsiga.com.br/sigadw.apw">'
cSoap += WSSoapValue("WSSESSION", ::cWSSESSION, cWSSESSION , "string", .T. , .F., 0 ) 
cSoap += "</RETDW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigadw.apw/RETDW",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigadw.apw",,"1.031217",; 
	"http://localhost/webservices/SIGADW.apw")

::Init()
::oWSRETDWRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETDWRESPONSE:_RETDWRESULT","ARRAYOFDWLIST",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFQUERYLIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFQUERYLIST
	WSDATA   oWSQUERYLIST              AS SIGADW_QUERYLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFQUERYLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFQUERYLIST
	::oWSQUERYLIST         := {} // Array Of  SIGADW_QUERYLIST():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFQUERYLIST
	Local oClone := SIGADW_ARRAYOFQUERYLIST():NEW()
	oClone:oWSQUERYLIST := NIL
	If ::oWSQUERYLIST <> NIL 
		oClone:oWSQUERYLIST := {}
		aEval( ::oWSQUERYLIST , { |x| aadd( oClone:oWSQUERYLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFQUERYLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_QUERYLIST","QUERYLIST",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSQUERYLIST , SIGADW_QUERYLIST():New() )
			::oWSQUERYLIST[len(::oWSQUERYLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFCONSULTASTRU
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFCONSULTASTRU
	WSDATA   oWSCONSULTASTRU           AS SIGADW_CONSULTASTRU OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFCONSULTASTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFCONSULTASTRU
	::oWSCONSULTASTRU      := {} // Array Of  SIGADW_CONSULTASTRU():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFCONSULTASTRU
	Local oClone := SIGADW_ARRAYOFCONSULTASTRU():NEW()
	oClone:oWSCONSULTASTRU := NIL
	If ::oWSCONSULTASTRU <> NIL 
		oClone:oWSCONSULTASTRU := {}
		aEval( ::oWSCONSULTASTRU , { |x| aadd( oClone:oWSCONSULTASTRU , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFCONSULTASTRU
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CONSULTASTRU","CONSULTASTRU",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCONSULTASTRU , SIGADW_CONSULTASTRU():New() )
			::oWSCONSULTASTRU[len(::oWSCONSULTASTRU)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFCUBEDETAIL
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFCUBEDETAIL
	WSDATA   oWSCUBEDETAIL             AS SIGADW_CUBEDETAIL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFCUBEDETAIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFCUBEDETAIL
	::oWSCUBEDETAIL        := {} // Array Of  SIGADW_CUBEDETAIL():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFCUBEDETAIL
	Local oClone := SIGADW_ARRAYOFCUBEDETAIL():NEW()
	oClone:oWSCUBEDETAIL := NIL
	If ::oWSCUBEDETAIL <> NIL 
		oClone:oWSCUBEDETAIL := {}
		aEval( ::oWSCUBEDETAIL , { |x| aadd( oClone:oWSCUBEDETAIL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFCUBEDETAIL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CUBEDETAIL","CUBEDETAIL",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCUBEDETAIL , SIGADW_CUBEDETAIL():New() )
			::oWSCUBEDETAIL[len(::oWSCUBEDETAIL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFCUBELIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFCUBELIST
	WSDATA   oWSCUBELIST               AS SIGADW_CUBELIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFCUBELIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFCUBELIST
	::oWSCUBELIST          := {} // Array Of  SIGADW_CUBELIST():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFCUBELIST
	Local oClone := SIGADW_ARRAYOFCUBELIST():NEW()
	oClone:oWSCUBELIST := NIL
	If ::oWSCUBELIST <> NIL 
		oClone:oWSCUBELIST := {}
		aEval( ::oWSCUBELIST , { |x| aadd( oClone:oWSCUBELIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFCUBELIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_CUBELIST","CUBELIST",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCUBELIST , SIGADW_CUBELIST():New() )
			::oWSCUBELIST[len(::oWSCUBELIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFDWLIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFDWLIST
	WSDATA   oWSDWLIST                 AS SIGADW_DWLIST OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFDWLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFDWLIST
	::oWSDWLIST            := {} // Array Of  SIGADW_DWLIST():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFDWLIST
	Local oClone := SIGADW_ARRAYOFDWLIST():NEW()
	oClone:oWSDWLIST := NIL
	If ::oWSDWLIST <> NIL 
		oClone:oWSDWLIST := {}
		aEval( ::oWSDWLIST , { |x| aadd( oClone:oWSDWLIST , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFDWLIST
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_DWLIST","DWLIST",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSDWLIST , SIGADW_DWLIST():New() )
			::oWSDWLIST[len(::oWSDWLIST)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure QUERYLIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_QUERYLIST
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cID                       AS string
	WSDATA   cLOGIN                    AS string
	WSDATA   cNAME                     AS string
	WSDATA   cQUERYTYPE                AS string
	WSDATA   cUSERNAME                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_QUERYLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_QUERYLIST
Return

WSMETHOD CLONE WSCLIENT SIGADW_QUERYLIST
	Local oClone := SIGADW_QUERYLIST():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cID                  := ::cID
	oClone:cLOGIN               := ::cLOGIN
	oClone:cNAME                := ::cNAME
	oClone:cQUERYTYPE           := ::cQUERYTYPE
	oClone:cUSERNAME            := ::cUSERNAME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_QUERYLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cLOGIN             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,"Property cLOGIN as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cQUERYTYPE         :=  WSAdvValue( oResponse,"_QUERYTYPE","string",NIL,"Property cQUERYTYPE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cUSERNAME          :=  WSAdvValue( oResponse,"_USERNAME","string",NIL,"Property cUSERNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure CONSULTASTRU
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_CONSULTASTRU
	WSDATA   cALIAS                    AS string
	WSDATA   cDESCRIPTION              AS string
	WSDATA   oWSFIELDSX                AS SIGADW_ARRAYOFFIELDSDET OPTIONAL
	WSDATA   oWSFIELDSY                AS SIGADW_ARRAYOFFIELDSDET OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   oWSMEASURES               AS SIGADW_ARRAYOFFIELDSDET OPTIONAL
	WSDATA   cNAME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_CONSULTASTRU
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_CONSULTASTRU
Return

WSMETHOD CLONE WSCLIENT SIGADW_CONSULTASTRU
	Local oClone := SIGADW_CONSULTASTRU():NEW()
	oClone:cALIAS               := ::cALIAS
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:oWSFIELDSX           := IIF(::oWSFIELDSX = NIL , NIL , ::oWSFIELDSX:Clone() )
	oClone:oWSFIELDSY           := IIF(::oWSFIELDSY = NIL , NIL , ::oWSFIELDSY:Clone() )
	oClone:cID                  := ::cID
	oClone:oWSMEASURES          := IIF(::oWSMEASURES = NIL , NIL , ::oWSMEASURES:Clone() )
	oClone:cNAME                := ::cNAME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_CONSULTASTRU
	Local oNode3
	Local oNode4
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cALIAS             :=  WSAdvValue( oResponse,"_ALIAS","string",NIL,"Property cALIAS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode3 :=  WSAdvValue( oResponse,"_FIELDSX","ARRAYOFFIELDSDET",NIL,NIL,NIL,"O",NIL) 
	If oNode3 != NIL
		::oWSFIELDSX := SIGADW_ARRAYOFFIELDSDET():New()
		::oWSFIELDSX:SoapRecv(oNode3)
	EndIf
	oNode4 :=  WSAdvValue( oResponse,"_FIELDSY","ARRAYOFFIELDSDET",NIL,NIL,NIL,"O",NIL) 
	If oNode4 != NIL
		::oWSFIELDSY := SIGADW_ARRAYOFFIELDSDET():New()
		::oWSFIELDSY:SoapRecv(oNode4)
	EndIf
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode6 :=  WSAdvValue( oResponse,"_MEASURES","ARRAYOFFIELDSDET",NIL,NIL,NIL,"O",NIL) 
	If oNode6 != NIL
		::oWSMEASURES := SIGADW_ARRAYOFFIELDSDET():New()
		::oWSMEASURES:SoapRecv(oNode6)
	EndIf
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure CUBEDETAIL
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_CUBEDETAIL
	WSDATA   cID                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_CUBEDETAIL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_CUBEDETAIL
Return

WSMETHOD CLONE WSCLIENT SIGADW_CUBEDETAIL
	Local oClone := SIGADW_CUBEDETAIL():NEW()
	oClone:cID                  := ::cID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_CUBEDETAIL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure CUBELIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_CUBELIST
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cID                       AS string
	WSDATA   cIMPORTATIONDATE          AS string
	WSDATA   cIMPORTATIONHOUR          AS string
	WSDATA   lINUSE                    AS boolean
	WSDATA   cNAME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_CUBELIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_CUBELIST
Return

WSMETHOD CLONE WSCLIENT SIGADW_CUBELIST
	Local oClone := SIGADW_CUBELIST():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cID                  := ::cID
	oClone:cIMPORTATIONDATE     := ::cIMPORTATIONDATE
	oClone:cIMPORTATIONHOUR     := ::cIMPORTATIONHOUR
	oClone:lINUSE               := ::lINUSE
	oClone:cNAME                := ::cNAME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_CUBELIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cIMPORTATIONDATE   :=  WSAdvValue( oResponse,"_IMPORTATIONDATE","string",NIL,"Property cIMPORTATIONDATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cIMPORTATIONHOUR   :=  WSAdvValue( oResponse,"_IMPORTATIONHOUR","string",NIL,"Property cIMPORTATIONHOUR as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lINUSE             :=  WSAdvValue( oResponse,"_INUSE","boolean",NIL,"Property lINUSE as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure DWLIST
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_DWLIST
	WSDATA   cNAME                     AS string
	WSDATA   nID                       AS integer
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_DWLIST
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_DWLIST
Return

WSMETHOD CLONE WSCLIENT SIGADW_DWLIST
	Local oClone := SIGADW_DWLIST():NEW()
	oClone:cNAME                := ::cNAME
	oClone:nID                  := ::nID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_DWLIST
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nID              :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property nID s:string on SOAP Response not found.",NIL,"S",NIL)
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFFIELDSDET
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFFIELDSDET
	WSDATA   oWSFIELDSDET              AS SIGADW_FIELDSDET OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFFIELDSDET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFFIELDSDET
	::oWSFIELDSDET         := {} // Array Of  SIGADW_FIELDSDET():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFFIELDSDET
	Local oClone := SIGADW_ARRAYOFFIELDSDET():NEW()
	oClone:oWSFIELDSDET := NIL
	If ::oWSFIELDSDET <> NIL 
		oClone:oWSFIELDSDET := {}
		aEval( ::oWSFIELDSDET , { |x| aadd( oClone:oWSFIELDSDET , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFFIELDSDET
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FIELDSDET","FIELDSDET",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFIELDSDET , SIGADW_FIELDSDET():New() )
			::oWSFIELDSDET[len(::oWSFIELDSDET)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure FIELDSDET
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_FIELDSDET
	WSDATA   cDECIMAL                  AS string
	WSDATA   cDESC                     AS string
	WSDATA   cID                       AS string
	WSDATA   cNAME                     AS string
	WSDATA   cSIZE                     AS string
	WSDATA   cTEMPORAL                 AS string
	WSDATA   cTYPE                     AS string
	WSDATA   oWSVALUES                 AS SIGADW_ARRAYOFFIELDSVALUE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_FIELDSDET
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_FIELDSDET
Return

WSMETHOD CLONE WSCLIENT SIGADW_FIELDSDET
	Local oClone := SIGADW_FIELDSDET():NEW()
	oClone:cDECIMAL             := ::cDECIMAL
	oClone:cDESC                := ::cDESC
	oClone:cID                  := ::cID
	oClone:cNAME                := ::cNAME
	oClone:cSIZE                := ::cSIZE
	oClone:cTEMPORAL            := ::cTEMPORAL
	oClone:cTYPE                := ::cTYPE
	oClone:oWSVALUES            := IIF(::oWSVALUES = NIL , NIL , ::oWSVALUES:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_FIELDSDET
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDECIMAL           :=  WSAdvValue( oResponse,"_DECIMAL","string",NIL,"Property cDECIMAL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cDESC              :=  WSAdvValue( oResponse,"_DESC","string",NIL,"Property cDESC as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSIZE              :=  WSAdvValue( oResponse,"_SIZE","string",NIL,"Property cSIZE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTEMPORAL          :=  WSAdvValue( oResponse,"_TEMPORAL","string",NIL,"Property cTEMPORAL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,"Property cTYPE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode8 :=  WSAdvValue( oResponse,"_VALUES","ARRAYOFFIELDSVALUE",NIL,NIL,NIL,"O",NIL) 
	If oNode8 != NIL
		::oWSVALUES := SIGADW_ARRAYOFFIELDSVALUE():New()
		::oWSVALUES:SoapRecv(oNode8)
	EndIf
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFFIELDSVALUE
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_ARRAYOFFIELDSVALUE
	WSDATA   oWSFIELDSVALUE            AS SIGADW_FIELDSVALUE OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_ARRAYOFFIELDSVALUE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_ARRAYOFFIELDSVALUE
	::oWSFIELDSVALUE       := {} // Array Of  SIGADW_FIELDSVALUE():New()
Return

WSMETHOD CLONE WSCLIENT SIGADW_ARRAYOFFIELDSVALUE
	Local oClone := SIGADW_ARRAYOFFIELDSVALUE():NEW()
	oClone:oWSFIELDSVALUE := NIL
	If ::oWSFIELDSVALUE <> NIL 
		oClone:oWSFIELDSVALUE := {}
		aEval( ::oWSFIELDSVALUE , { |x| aadd( oClone:oWSFIELDSVALUE , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_ARRAYOFFIELDSVALUE
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FIELDSVALUE","FIELDSVALUE",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFIELDSVALUE , SIGADW_FIELDSVALUE():New() )
			::oWSFIELDSVALUE[len(::oWSFIELDSVALUE)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure FIELDSVALUE
------------------------------------------------------------------------------- */

WSSTRUCT SIGADW_FIELDSVALUE
	WSDATA   cVALOR                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGADW_FIELDSVALUE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGADW_FIELDSVALUE
Return

WSMETHOD CLONE WSCLIENT SIGADW_FIELDSVALUE
	Local oClone := SIGADW_FIELDSVALUE():NEW()
	oClone:cVALOR               := ::cVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGADW_FIELDSVALUE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cVALOR             :=  WSAdvValue( oResponse,"_VALOR","string",NIL,"Property cVALOR as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return


