#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ipt-rogerio/ws/RHPROJECTEVALUATE.apw?WSDL
Gerado em        09/24/07 16:09:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.060117
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KLSSPCD ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSRHPROJECTEVALUATE
------------------------------------------------------------------------------- */

WSCLIENT WSRHPROJECTEVALUATE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETEVALUATED
	WSMETHOD GETEVALUATIONITEMS
	WSMETHOD GETEVALUATIONS

	WSDATA   _URL                      AS String
	WSDATA   cEVALUATIONID             AS string
	WSDATA   cEVALUATORID              AS string
	WSDATA   oWSGETEVALUATEDRESULT     AS RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	WSDATA   cEVALUATEDID              AS string
	WSDATA   oWSGETEVALUATIONITEMSRESULT AS RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	WSDATA   cTYPE                     AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   oWSGETEVALUATIONSRESULT   AS RHPROJECTEVALUATE_ARRAYOFTEVALUATION

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSRHPROJECTEVALUATE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.070518A] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSRHPROJECTEVALUATE
	::oWSGETEVALUATEDRESULT := RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT():New()
	::oWSGETEVALUATIONITEMSRESULT := RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM():New()
	::oWSGETEVALUATIONSRESULT := RHPROJECTEVALUATE_ARRAYOFTEVALUATION():New()
Return

WSMETHOD RESET WSCLIENT WSRHPROJECTEVALUATE
	::cEVALUATIONID      := NIL 
	::cEVALUATORID       := NIL 
	::oWSGETEVALUATEDRESULT := NIL 
	::cEVALUATEDID       := NIL 
	::oWSGETEVALUATIONITEMSRESULT := NIL 
	::cTYPE              := NIL 
	::cSTATUS            := NIL 
	::oWSGETEVALUATIONSRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSRHPROJECTEVALUATE
Local oClone := WSRHPROJECTEVALUATE():New()
	oClone:_URL          := ::_URL 
	oClone:cEVALUATIONID := ::cEVALUATIONID
	oClone:cEVALUATORID  := ::cEVALUATORID
	oClone:oWSGETEVALUATEDRESULT :=  IIF(::oWSGETEVALUATEDRESULT = NIL , NIL ,::oWSGETEVALUATEDRESULT:Clone() )
	oClone:cEVALUATEDID  := ::cEVALUATEDID
	oClone:oWSGETEVALUATIONITEMSRESULT :=  IIF(::oWSGETEVALUATIONITEMSRESULT = NIL , NIL ,::oWSGETEVALUATIONITEMSRESULT:Clone() )
	oClone:cTYPE         := ::cTYPE
	oClone:cSTATUS       := ::cSTATUS
	oClone:oWSGETEVALUATIONSRESULT :=  IIF(::oWSGETEVALUATIONSRESULT = NIL , NIL ,::oWSGETEVALUATIONSRESULT:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method GETEVALUATED of Service WSRHPROJECTEVALUATE
------------------------------------------------------------------------------- */

WSMETHOD GETEVALUATED WSSEND cEVALUATIONID,cEVALUATORID WSRECEIVE oWSGETEVALUATEDRESULT WSCLIENT WSRHPROJECTEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETEVALUATED xmlns="http://ipt-rogerio/">'
cSoap += WSSoapValue("EVALUATIONID", ::cEVALUATIONID, cEVALUATIONID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("EVALUATORID", ::cEVALUATORID, cEVALUATORID , "string", .F. , .F., 0 ) 
cSoap += "</GETEVALUATED>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-rogerio/GETEVALUATED",; 
	"DOCUMENT","http://ipt-rogerio/",,"1.031217",; 
	"http://ipt-rogerio/ws/RHPROJECTEVALUATE.apw")

::Init()
::oWSGETEVALUATEDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETEVALUATEDRESPONSE:_GETEVALUATEDRESULT","ARRAYOFTPARTICIPANT",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETEVALUATIONITEMS of Service WSRHPROJECTEVALUATE
------------------------------------------------------------------------------- */

WSMETHOD GETEVALUATIONITEMS WSSEND cEVALUATIONID,cEVALUATORID,cEVALUATEDID WSRECEIVE oWSGETEVALUATIONITEMSRESULT WSCLIENT WSRHPROJECTEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETEVALUATIONITEMS xmlns="http://ipt-rogerio/">'
cSoap += WSSoapValue("EVALUATIONID", ::cEVALUATIONID, cEVALUATIONID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("EVALUATORID", ::cEVALUATORID, cEVALUATORID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("EVALUATEDID", ::cEVALUATEDID, cEVALUATEDID , "string", .F. , .F., 0 ) 
cSoap += "</GETEVALUATIONITEMS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-rogerio/GETEVALUATIONITEMS",; 
	"DOCUMENT","http://ipt-rogerio/",,"1.031217",; 
	"http://ipt-rogerio/ws/RHPROJECTEVALUATE.apw")

::Init()
::oWSGETEVALUATIONITEMSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETEVALUATIONITEMSRESPONSE:_GETEVALUATIONITEMSRESULT","ARRAYOFTEVALUATIONITEM",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETEVALUATIONS of Service WSRHPROJECTEVALUATE
------------------------------------------------------------------------------- */

WSMETHOD GETEVALUATIONS WSSEND cEVALUATORID,cTYPE,cSTATUS WSRECEIVE oWSGETEVALUATIONSRESULT WSCLIENT WSRHPROJECTEVALUATE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETEVALUATIONS xmlns="http://ipt-rogerio/">'
cSoap += WSSoapValue("EVALUATORID", ::cEVALUATORID, cEVALUATORID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("TYPE", ::cTYPE, cTYPE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("STATUS", ::cSTATUS, cSTATUS , "string", .F. , .F., 0 ) 
cSoap += "</GETEVALUATIONS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://ipt-rogerio/GETEVALUATIONS",; 
	"DOCUMENT","http://ipt-rogerio/",,"1.031217",; 
	"http://ipt-rogerio/ws/RHPROJECTEVALUATE.apw")

::Init()
::oWSGETEVALUATIONSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETEVALUATIONSRESPONSE:_GETEVALUATIONSRESULT","ARRAYOFTEVALUATION",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFTPARTICIPANT
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	WSDATA   oWSTPARTICIPANT           AS RHPROJECTEVALUATE_TPARTICIPANT OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	::oWSTPARTICIPANT      := {} // Array Of  RHPROJECTEVALUATE_TPARTICIPANT():New()
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	Local oClone := RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT():NEW()
	oClone:oWSTPARTICIPANT := NIL
	If ::oWSTPARTICIPANT <> NIL 
		oClone:oWSTPARTICIPANT := {}
		aEval( ::oWSTPARTICIPANT , { |x| aadd( oClone:oWSTPARTICIPANT , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_ARRAYOFTPARTICIPANT
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TPARTICIPANT","TPARTICIPANT",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTPARTICIPANT , RHPROJECTEVALUATE_TPARTICIPANT():New() )
			::oWSTPARTICIPANT[len(::oWSTPARTICIPANT)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFTEVALUATIONITEM
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	WSDATA   oWSTEVALUATIONITEM        AS RHPROJECTEVALUATE_TEVALUATIONITEM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	::oWSTEVALUATIONITEM   := {} // Array Of  RHPROJECTEVALUATE_TEVALUATIONITEM():New()
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	Local oClone := RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM():NEW()
	oClone:oWSTEVALUATIONITEM := NIL
	If ::oWSTEVALUATIONITEM <> NIL 
		oClone:oWSTEVALUATIONITEM := {}
		aEval( ::oWSTEVALUATIONITEM , { |x| aadd( oClone:oWSTEVALUATIONITEM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATIONITEM
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TEVALUATIONITEM","TEVALUATIONITEM",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTEVALUATIONITEM , RHPROJECTEVALUATE_TEVALUATIONITEM():New() )
			::oWSTEVALUATIONITEM[len(::oWSTEVALUATIONITEM)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFTEVALUATION
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_ARRAYOFTEVALUATION
	WSDATA   oWSTEVALUATION            AS RHPROJECTEVALUATE_TEVALUATION OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATION
	::oWSTEVALUATION       := {} // Array Of  RHPROJECTEVALUATE_TEVALUATION():New()
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATION
	Local oClone := RHPROJECTEVALUATE_ARRAYOFTEVALUATION():NEW()
	oClone:oWSTEVALUATION := NIL
	If ::oWSTEVALUATION <> NIL 
		oClone:oWSTEVALUATION := {}
		aEval( ::oWSTEVALUATION , { |x| aadd( oClone:oWSTEVALUATION , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_ARRAYOFTEVALUATION
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_TEVALUATION","TEVALUATION",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSTEVALUATION , RHPROJECTEVALUATE_TEVALUATION():New() )
			::oWSTEVALUATION[len(::oWSTEVALUATION)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TPARTICIPANT
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TPARTICIPANT
	WSDATA   cID                       AS string
	WSDATA   cNAME                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TPARTICIPANT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TPARTICIPANT
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TPARTICIPANT
	Local oClone := RHPROJECTEVALUATE_TPARTICIPANT():NEW()
	oClone:cID                  := ::cID
	oClone:cNAME                := ::cNAME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TPARTICIPANT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TEVALUATIONITEM
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TEVALUATIONITEM
	WSDATA   oWSEVALUATED              AS RHPROJECTEVALUATE_TPARTICIPANT OPTIONAL
	WSDATA   oWSEVALUATION             AS RHPROJECTEVALUATE_TEVALUATION OPTIONAL
	WSDATA   oWSEVALUATOR              AS RHPROJECTEVALUATE_TPARTICIPANT OPTIONAL
	WSDATA   cEVALUATORTYPE            AS string
	WSDATA   oWSPERIOD                 AS RHPROJECTEVALUATE_TCALENDAR
	WSDATA   oWSPROJECT                AS RHPROJECTEVALUATE_TPROJECT
	WSDATA   cSTATUS                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TEVALUATIONITEM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TEVALUATIONITEM
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TEVALUATIONITEM
	Local oClone := RHPROJECTEVALUATE_TEVALUATIONITEM():NEW()
	oClone:oWSEVALUATED         := IIF(::oWSEVALUATED = NIL , NIL , ::oWSEVALUATED:Clone() )
	oClone:oWSEVALUATION        := IIF(::oWSEVALUATION = NIL , NIL , ::oWSEVALUATION:Clone() )
	oClone:oWSEVALUATOR         := IIF(::oWSEVALUATOR = NIL , NIL , ::oWSEVALUATOR:Clone() )
	oClone:cEVALUATORTYPE       := ::cEVALUATORTYPE
	oClone:oWSPERIOD            := IIF(::oWSPERIOD = NIL , NIL , ::oWSPERIOD:Clone() )
	oClone:oWSPROJECT           := IIF(::oWSPROJECT = NIL , NIL , ::oWSPROJECT:Clone() )
	oClone:cSTATUS              := ::cSTATUS
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TEVALUATIONITEM
	Local oNode1
	Local oNode2
	Local oNode3
	Local oNode5
	Local oNode6
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_EVALUATED","TPARTICIPANT",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSEVALUATED := RHPROJECTEVALUATE_TPARTICIPANT():New()
		::oWSEVALUATED:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_EVALUATION","TEVALUATION",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSEVALUATION := RHPROJECTEVALUATE_TEVALUATION():New()
		::oWSEVALUATION:SoapRecv(oNode2)
	EndIf
	oNode3 :=  WSAdvValue( oResponse,"_EVALUATOR","TPARTICIPANT",NIL,NIL,NIL,"O",NIL) 
	If oNode3 != NIL
		::oWSEVALUATOR := RHPROJECTEVALUATE_TPARTICIPANT():New()
		::oWSEVALUATOR:SoapRecv(oNode3)
	EndIf
	::cEVALUATORTYPE     :=  WSAdvValue( oResponse,"_EVALUATORTYPE","string",NIL,"Property cEVALUATORTYPE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode5 :=  WSAdvValue( oResponse,"_PERIOD","TCALENDAR",NIL,"Property oWSPERIOD as s0:TCALENDAR on SOAP Response not found.",NIL,"O",NIL) 
	If oNode5 != NIL
		::oWSPERIOD := RHPROJECTEVALUATE_TCALENDAR():New()
		::oWSPERIOD:SoapRecv(oNode5)
	EndIf
	oNode6 :=  WSAdvValue( oResponse,"_PROJECT","TPROJECT",NIL,"Property oWSPROJECT as s0:TPROJECT on SOAP Response not found.",NIL,"O",NIL) 
	If oNode6 != NIL
		::oWSPROJECT := RHPROJECTEVALUATE_TPROJECT():New()
		::oWSPROJECT:SoapRecv(oNode6)
	EndIf
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TEVALUATION
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TEVALUATION
	WSDATA   cDESCRIPTION              AS string
	WSDATA   oWSEVALUATIONTYPE         AS RHPROJECTEVALUATE_TEVALUATIONTYPE OPTIONAL
	WSDATA   cID                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TEVALUATION
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TEVALUATION
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TEVALUATION
	Local oClone := RHPROJECTEVALUATE_TEVALUATION():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:oWSEVALUATIONTYPE    := IIF(::oWSEVALUATIONTYPE = NIL , NIL , ::oWSEVALUATIONTYPE:Clone() )
	oClone:cID                  := ::cID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TEVALUATION
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode2 :=  WSAdvValue( oResponse,"_EVALUATIONTYPE","TEVALUATIONTYPE",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSEVALUATIONTYPE := RHPROJECTEVALUATE_TEVALUATIONTYPE():New()
		::oWSEVALUATIONTYPE:SoapRecv(oNode2)
	EndIf
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TCALENDAR
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TCALENDAR
	WSDATA   dFINALDATE                AS date
	WSDATA   dINITIALDATE              AS date
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TCALENDAR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TCALENDAR
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TCALENDAR
	Local oClone := RHPROJECTEVALUATE_TCALENDAR():NEW()
	oClone:dFINALDATE           := ::dFINALDATE
	oClone:dINITIALDATE         := ::dINITIALDATE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TCALENDAR
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::dFINALDATE         :=  WSAdvValue( oResponse,"_FINALDATE","date",NIL,"Property dFINALDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
	::dINITIALDATE       :=  WSAdvValue( oResponse,"_INITIALDATE","date",NIL,"Property dINITIALDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TPROJECT
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TPROJECT
	WSDATA   oWSCLIENT                 AS RHPROJECTEVALUATE_TCLIENT
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cID                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TPROJECT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TPROJECT
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TPROJECT
	Local oClone := RHPROJECTEVALUATE_TPROJECT():NEW()
	oClone:oWSCLIENT            := IIF(::oWSCLIENT = NIL , NIL , ::oWSCLIENT:Clone() )
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cID                  := ::cID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TPROJECT
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CLIENT","TCLIENT",NIL,"Property oWSCLIENT as s0:TCLIENT on SOAP Response not found.",NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSCLIENT := RHPROJECTEVALUATE_TCLIENT():New()
		::oWSCLIENT:SoapRecv(oNode1)
	EndIf
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TEVALUATIONTYPE
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TEVALUATIONTYPE
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cID                       AS string
	WSDATA   cTYPE                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TEVALUATIONTYPE
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TEVALUATIONTYPE
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TEVALUATIONTYPE
	Local oClone := RHPROJECTEVALUATE_TEVALUATIONTYPE():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cID                  := ::cID
	oClone:cTYPE                := ::cTYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TEVALUATIONTYPE
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,"Property cTYPE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure TCLIENT
------------------------------------------------------------------------------- */

WSSTRUCT RHPROJECTEVALUATE_TCLIENT
	WSDATA   cDESCRIPTION              AS string
	WSDATA   cID                       AS string
	WSDATA   cUNITID                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT RHPROJECTEVALUATE_TCLIENT
	::Init()
Return Self

WSMETHOD INIT WSCLIENT RHPROJECTEVALUATE_TCLIENT
Return

WSMETHOD CLONE WSCLIENT RHPROJECTEVALUATE_TCLIENT
	Local oClone := RHPROJECTEVALUATE_TCLIENT():NEW()
	oClone:cDESCRIPTION         := ::cDESCRIPTION
	oClone:cID                  := ::cID
	oClone:cUNITID              := ::cUNITID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT RHPROJECTEVALUATE_TCLIENT
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cDESCRIPTION       :=  WSAdvValue( oResponse,"_DESCRIPTION","string",NIL,"Property cDESCRIPTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cUNITID            :=  WSAdvValue( oResponse,"_UNITID","string",NIL,"Property cUNITID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return


