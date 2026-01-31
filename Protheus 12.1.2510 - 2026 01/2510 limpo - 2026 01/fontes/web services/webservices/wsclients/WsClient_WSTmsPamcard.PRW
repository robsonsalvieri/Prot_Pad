#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    https://qualidade.gps-pamcary.com.br/pamcardbrvisa/services/WSPamcardDocument?wsdl
Gerado em        12/23/11 17:06:48
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.080707
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CKUWDLN ; Return  // "dummy" function - Internal Use

/* -------------------------------------------------------------------------------
WSDL Service WSWSPamcardDocumentService
------------------------------------------------------------------------------- */

WSCLIENT WSWSPamcardDocumentService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD execute

	WSDATA   _URL                      AS String
	WSDATA   oWSarg0                   AS WSPamcardDocumentService_requestTO
	WSDATA   oWSresponseTO             AS WSPamcardDocumentService_responseTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSPamcardDocumentService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do TOTVSTEC Build [7.00.101223P-20110608] ou superior. Atualize o TOTVSTEC ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSPamcardDocumentService
	::oWSarg0            := WSPamcardDocumentService_REQUESTTO():New()
	::oWSresponseTO      := WSPamcardDocumentService_RESPONSETO():New()
Return

WSMETHOD RESET WSCLIENT WSWSPamcardDocumentService
	::oWSarg0            := NIL
	::oWSresponseTO      := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSPamcardDocumentService
Local oClone := WSWSPamcardDocumentService():New()
	oClone:_URL          := ::_URL
	oClone:oWSarg0       :=  IIF(::oWSarg0 = NIL , NIL ,::oWSarg0:Clone() )
	oClone:oWSresponseTO :=  IIF(::oWSresponseTO = NIL , NIL ,::oWSresponseTO:Clone() )
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method execute of Service WSWSPamcardDocumentService
------------------------------------------------------------------------------- */

WSMETHOD execute WSSEND oWSarg0 WSRECEIVE oWSresponseTO WSCLIENT WSWSPamcardDocumentService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<doc:execute xmlns:doc="http://document.webservice.pamcard.jee.pamcary.com.br">'
cSoap += WSSoapValue("arg0", ::oWSarg0, oWSarg0 , "requestTO", .F. , .F., 0 , NIL, .F.) 
cSoap += "</doc:execute>"
cSoap := StrTran (cSoap, 'certificate xsi:type="xsd:string"', 'certificate xsi:type="xsd:base64Binary"')

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"execute",; 
	"DOCUMENT","http://document.webservice.pamcard.jee.pamcary.com.br",,,; 
	"'+Alltrim(DEG->DEG_URLWS)+'")
//	"'https://qualidade.gps-pamcary.com.br/pamcardbrvisa/services/WSPamcardDocument'")

::Init()
::oWSresponseTO:SoapRecv( WSAdvValue( oXmlRet,"_NS2_EXECUTERESPONSE:_RETURN","responseTO",NIL,NIL,NIL,NIL,NIL,"tns") )

END WSMETHOD

oXmlRet := NIL
Return .T.



/* -------------------------------------------------------------------------------
WSDL Data Structure RequestTO
------------------------------------------------------------------------------- */

WSSTRUCT WSPamcardDocumentService_RequestTO
	WSDATA   ccertificate              AS string OPTIONAL
	WSDATA   ccontext                  AS string OPTIONAL
	WSDATA   oFieldTOs                 AS WSPamcardDocumentService_ArrayOf_tns1_FieldTO OPTIONAL
	WSDATA   ctoken                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPamcardDocumentService_RequestTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPamcardDocumentService_RequestTO
Return

WSMETHOD CLONE WSCLIENT WSPamcardDocumentService_RequestTO
	Local oClone := WSPamcardDocumentService_RequestTO():NEW()
	oClone:ccertificate            := ::ccertificate
	oClone:ccontext                := ::ccontext
	oClone:oFieldTOs               := IIF(::oFieldTOs = NIL , NIL , ::oFieldTOs:Clone() )
	oClone:ctoken                  := ::ctoken
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPamcardDocumentService_RequestTO
	Local cSoap := ""
	cSoap += WSSoapValue("certificate", ::ccertificate, ::ccertificate , "string", .F. , .T., 0 , NIL, .F.)
	cSoap += WSSoapValue("context", ::ccontext, ::ccontext , "string", .F. , .T., 0 , NIL, .F.)
	// cSoap += WSSoapValue("fields", ::oFieldTOs, ::oFieldTOs , "ArrayOf_tns1_FieldTO", .F. , .T., 3 , NIL, .F.)
	If ::oFieldTOs != NIL 
		cSoap += ::oFieldTOs:SoapSend()
	Endif
	cSoap += WSSoapValue("token", ::ctoken, ::ctoken , "string", .F. , .T., 0 , NIL, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPamcardDocumentService_RequestTO
	Local oNode3
	::Init()
	If oResponse = NIL ; Return ; Endif
	::ccertificate        :=  WSAdvValue( oResponse,"_CERTIFICATE","string",NIL,NIL,NIL,"S",NIL,NIL)
	::ccontext            :=  WSAdvValue( oResponse,"_CONTEXT","string",NIL,NIL,NIL,"S",NIL,NIL)
	oNode3 :=  WSAdvValue( oResponse,"_FIELDS","ArrayOf_tns1_FieldTO",NIL,NIL,NIL,"O",NIL,NIL)
	If oNode3 != NIL
		::oFieldTO := WSPamcardDocumentService_FieldTO():New()
		::oFieldTO:SoapRecv(oNode3)
	EndIf
	::ctoken              :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ResponseTO
------------------------------------------------------------------------------- */

WSSTRUCT WSPamcardDocumentService_ResponseTO
	WSDATA   oReturn             AS WSPamcardDocumentService_Return
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPamcardDocumentService_ResponseTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPamcardDocumentService_ResponseTO
 ::oReturn      := WSPamcardDocumentService_Return():New()
Return

WSMETHOD CLONE WSCLIENT WSPamcardDocumentService_ResponseTO
	Local oClone := WSPamcardDocumentService_ResponseTO():NEW()
 oClone:oReturn := IIF(::oReturn = NIL , NIL , ::oReturn:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPamcardDocumentService_ResponseTO
	Local cSoap := ""
	cSoap += WSSoapValue("return", ::oReturn, ::oReturn , "Return", .F. , .T., 0 , NIL, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPamcardDocumentService_ResponseTO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif
	//oNode1 :=  WSAdvValue( oResponse,"_RETURN","Return",NIL,NIL,NIL,"O",NIL,NIL)
	oNode1 := oResponse
	If oNode1 != NIL
		::oReturn := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New() //WSPamcardDocumentService_Return():New()
		::oReturn:SoapRecv(oNode1)
	EndIf
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure Return
------------------------------------------------------------------------------- */

WSSTRUCT WSPamcardDocumentService_Return
	WSDATA   ccertificate              AS string OPTIONAL
	WSDATA   ccontext                  AS string OPTIONAL
	WSDATA   oFieldTOs                 AS WSPamcardDocumentService_ArrayOf_tns1_FieldTO OPTIONAL
	WSDATA   ctoken                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV                                                      
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPamcardDocumentService_Return
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPamcardDocumentService_Return
Return

WSMETHOD CLONE WSCLIENT WSPamcardDocumentService_Return
	Local oClone := WSPamcardDocumentService_Return():NEW()
	oClone:ccertificate            := ::ccertificate
	oClone:ccontext                := ::ccontext
	oClone:oFieldTOs               := IIF(::oFieldTOs = NIL , NIL , ::oFieldTOs:Clone() )
	oClone:ctoken                  := ::ctoken
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPamcardDocumentService_Return
	Local cSoap := ""
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPamcardDocumentService_Return
	Local oNode3
	::Init()

	If oResponse = NIL ; Return ; Endif
	::ccertificate        :=  WSAdvValue( oResponse,"_CERTIFICATE","string",NIL,NIL,NIL,"S",NIL,"")
	::ccontext            :=  WSAdvValue( oResponse,"_CONTEXT","string",NIL,NIL,NIL,"S",NIL,"")

	oNode3 :=  WSAdvValue( oResponse,"_FIELDSARRAY","ArrayOf_tns1_FieldTO",NIL,NIL,NIL,"A",NIL,"")
	If oNode3 != NIL
		::oFieldTOs := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
		::oFieldTOs:SoapRecv(oNode3)
	EndIf

	::ctoken              :=  WSAdvValue( oResponse,"_TOKEN","string",NIL,NIL,NIL,"S",NIL,NIL)
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ArrayOf_tns1_FieldTO
------------------------------------------------------------------------------- */

WSSTRUCT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	WSDATA   oFieldTO    AS WSPamcardDocumentService_FieldTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	::oFieldTO := {} // Array Of  WSPamcardDocumentService_ArrayOf_tns1_FieldTO():New()
Return

WSMETHOD CLONE WSCLIENT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	Local oClone := WSPamcardDocumentService_ArrayOf_tns1_FieldTO():NEW()
	oClone:oFieldTO := NIL
	If ::oFieldTO <> NIL
		oClone:oFieldTO := {}
		aEval( ::oFieldTO , { |x| aadd( oClone:oFieldTO , x:Clone() ) } )
	Endif
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	Local cSoap := ""
	aEval( ::oFieldTO , {|x| cSoap := cSoap  +  WSSoapValue("fields", x , x , "FieldTO", .F. , .T., 0 , NIL, .F.)  } )
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPamcardDocumentService_ArrayOf_tns1_FieldTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif
	oNodes1 :=  WSAdvValue( oResponse,"_FIELDS","FieldTO",{},NIL,.T.,"O",NIL,NIL)
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oFieldTO , WSPamcardDocumentService_FieldTO():New() )
			::oFieldTO[len(::oFieldTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure FieldTO
------------------------------------------------------------------------------- */

WSSTRUCT WSPamcardDocumentService_FieldTO
	WSDATA   ckey             AS string OPTIONAL
	WSDATA   cvalue           AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WSPamcardDocumentService_FieldTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WSPamcardDocumentService_FieldTO
Return

WSMETHOD CLONE WSCLIENT WSPamcardDocumentService_FieldTO
	Local oClone := WSPamcardDocumentService_FieldTO():NEW()
	oClone:ckey        := ::ckey
	oClone:cvalue      := ::cvalue
Return oClone

WSMETHOD SOAPSEND WSCLIENT WSPamcardDocumentService_FieldTO
	Local cSoap := ""
	cSoap += WSSoapValue("key", ::ckey, ::ckey , "string", .F. , .T., 0 , NIL, .F.)
	cSoap += WSSoapValue("value", ::cvalue, ::cvalue , "string", .F. , .T., 0 , NIL, .F.)
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT WSPamcardDocumentService_FieldTO
	::Init()
	If oResponse = NIL ; Return ; Endif
	::ckey      :=  WSAdvValue( oResponse,"_KEY","string",NIL,NIL,NIL,"S",NIL,NIL)
	::cvalue    :=  WSAdvValue( oResponse,"_VALUE","string",NIL,NIL,NIL,"S",NIL,NIL)
Return
