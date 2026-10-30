#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±       
±±∫Programa. ≥WSCLIENT_PARTNERECOSYSTEM                                       ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±       
±±∫Autor     ≥Marcelo Custodio      ≥Data   10/05/05                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Fonte gerada por ADVPL WSDL Cliente                             ∫±±
±±∫          ≥Inclusao manual da Function "_WSPESDU" para                     ∫±±
±±∫          ≥controle sobre geracao de patches                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/* ===============================================================================
WSDL Location    http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw?WSDL
Gerado em        06/14/04 14:59:33
ObservaÁıes      CÛdigo-Fonte gerado por ADVPL WSDL Client 1.040504
                 AlteraÁıes neste arquivo podem causar funcionamento incorreto
                 e ser„o perdidas caso o cÛdigo-fonte seja gerado novamente.
=============================================================================== */
           
Function _WSPESDU() ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSCLIENT WSPARTNERECOSYSTEM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DELPARTNERRECORD
	WSMETHOD GETPARTNERRECORD
	WSMETHOD GETPARTNERWEB
	WSMETHOD HANDSHAKE
	WSMETHOD PUTPARTNERRECORD

	WSDATA   _URL                      AS String
	WSDATA   oWSPARTNERRECORD          AS PARTNERECOSYSTEM_PARTNERRECORDVIEW
	WSDATA   cDELPARTNERRECORDRESULT   AS string
	WSDATA   cPARTNERID                AS string
	WSDATA   cSERVICEID                AS string
	WSDATA   oWSGETPARTNERRECORDRESULT AS PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	WSDATA   cHARDLOCK                 AS string
	WSDATA   oWSCOMPANY                AS PARTNERECOSYSTEM_COMPANYVIEW
	WSDATA   oWSCONTACT                AS PARTNERECOSYSTEM_COMPANYUSERVIEW
	WSDATA   cUSERID                   AS string
	WSDATA   cPASSWORD                 AS string
	WSDATA   cGETPARTNERWEBRESULT      AS string
	WSDATA   cFEDERALID                AS string
	WSDATA   oWSHANDSHAKERESULT        AS PARTNERECOSYSTEM_HANDSHAKEVIEW
	WSDATA   cPUTPARTNERRECORDRESULT   AS string

	// Estruturas mantidas por compatibilidade - N√O USAR
	WSDATA   oWSPARTNERRECORDVIEW      AS PARTNERECOSYSTEM_PARTNERRECORDVIEW
	WSDATA   oWSCOMPANYVIEW            AS PARTNERECOSYSTEM_COMPANYVIEW
	WSDATA   oWSCOMPANYUSERVIEW        AS PARTNERECOSYSTEM_COMPANYUSERVIEW

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSPARTNERECOSYSTEM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O CÛdigo-Fonte Client atual requer os execut·veis do Protheus Build [7.00.040506P] ou superior. Atualize o Protheus ou gere o CÛdigo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSPARTNERECOSYSTEM
	::oWSPARTNERRECORD   := PARTNERECOSYSTEM_PARTNERRECORDVIEW():New()
	::oWSGETPARTNERRECORDRESULT := PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW():New()
	::oWSCOMPANY         := PARTNERECOSYSTEM_COMPANYVIEW():New()
	::oWSCONTACT         := PARTNERECOSYSTEM_COMPANYUSERVIEW():New()
	::oWSHANDSHAKERESULT := PARTNERECOSYSTEM_HANDSHAKEVIEW():New()

	// Estruturas mantidas por compatibilidade - N√O USAR
	::oWSPARTNERRECORDVIEW := ::oWSPARTNERRECORD
	::oWSCOMPANYVIEW     := ::oWSCOMPANY
	::oWSCOMPANYUSERVIEW := ::oWSCONTACT
Return

WSMETHOD RESET WSCLIENT WSPARTNERECOSYSTEM
	::oWSPARTNERRECORD   := NIL 
	::cDELPARTNERRECORDRESULT := NIL 
	::cPARTNERID         := NIL 
	::cSERVICEID         := NIL 
	::oWSGETPARTNERRECORDRESULT := NIL 
	::cHARDLOCK          := NIL 
	::oWSCOMPANY         := NIL 
	::oWSCONTACT         := NIL 
	::cUSERID            := NIL 
	::cPASSWORD          := NIL 
	::cGETPARTNERWEBRESULT := NIL 
	::cFEDERALID         := NIL 
	::oWSHANDSHAKERESULT := NIL 
	::cPUTPARTNERRECORDRESULT := NIL 

	// Estruturas mantidas por compatibilidade - N√O USAR
	::oWSPARTNERRECORDVIEW := NIL
	::oWSCOMPANYVIEW     := NIL
	::oWSCOMPANYUSERVIEW := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSPARTNERECOSYSTEM
Local oClone := WSPARTNERECOSYSTEM():New()
	oClone:_URL          := ::_URL 
	oClone:oWSPARTNERRECORD :=  IIF(::oWSPARTNERRECORD = NIL , NIL ,::oWSPARTNERRECORD:Clone() )
	oClone:cDELPARTNERRECORDRESULT := ::cDELPARTNERRECORDRESULT
	oClone:cPARTNERID    := ::cPARTNERID
	oClone:cSERVICEID    := ::cSERVICEID
	oClone:oWSGETPARTNERRECORDRESULT :=  IIF(::oWSGETPARTNERRECORDRESULT = NIL , NIL ,::oWSGETPARTNERRECORDRESULT:Clone() )
	oClone:cHARDLOCK     := ::cHARDLOCK
	oClone:oWSCOMPANY    :=  IIF(::oWSCOMPANY = NIL , NIL ,::oWSCOMPANY:Clone() )
	oClone:oWSCONTACT    :=  IIF(::oWSCONTACT = NIL , NIL ,::oWSCONTACT:Clone() )
	oClone:cUSERID       := ::cUSERID
	oClone:cPASSWORD     := ::cPASSWORD
	oClone:cGETPARTNERWEBRESULT := ::cGETPARTNERWEBRESULT
	oClone:cFEDERALID    := ::cFEDERALID
	oClone:oWSHANDSHAKERESULT :=  IIF(::oWSHANDSHAKERESULT = NIL , NIL ,::oWSHANDSHAKERESULT:Clone() )
	oClone:cPUTPARTNERRECORDRESULT := ::cPUTPARTNERRECORDRESULT

	// Estruturas mantidas por compatibilidade - N√O USAR
	oClone:oWSPARTNERRECORDVIEW := oClone:oWSPARTNERRECORD
	oClone:oWSCOMPANYVIEW := oClone:oWSCOMPANY
	oClone:oWSCOMPANYUSERVIEW := oClone:oWSCONTACT
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method DELPARTNERRECORD of Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD DELPARTNERRECORD WSSEND oWSPARTNERRECORD WSRECEIVE cDELPARTNERRECORDRESULT WSCLIENT WSPARTNERECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DELPARTNERRECORD xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("PARTNERRECORD", ::oWSPARTNERRECORD, oWSPARTNERRECORD , "PARTNERRECORDVIEW", .T. , .F., 0 ) 
cSoap += "</DELPARTNERRECORD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/DELPARTNERRECORD",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw")

::Init()
::cDELPARTNERRECORDRESULT :=  WSAdvValue( oXmlRet,"_DELPARTNERRECORDRESPONSE:_DELPARTNERRECORDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETPARTNERRECORD of Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD GETPARTNERRECORD WSSEND cPARTNERID,cSERVICEID WSRECEIVE oWSGETPARTNERRECORDRESULT WSCLIENT WSPARTNERECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPARTNERRECORD xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("PARTNERID", ::cPARTNERID, cPARTNERID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("SERVICEID", ::cSERVICEID, cSERVICEID , "string", .T. , .F., 0 ) 
cSoap += "</GETPARTNERRECORD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETPARTNERRECORD",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw")

::Init()
::oWSGETPARTNERRECORDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPARTNERRECORDRESPONSE:_GETPARTNERRECORDRESULT","ARRAYOFPARTNERRECORDVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETPARTNERWEB of Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD GETPARTNERWEB WSSEND cHARDLOCK,oWSCOMPANY,oWSCONTACT,cUSERID,cPASSWORD,cSERVICEID WSRECEIVE cGETPARTNERWEBRESULT WSCLIENT WSPARTNERECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPARTNERWEB xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COMPANY", ::oWSCOMPANY, oWSCOMPANY , "COMPANYVIEW", .T. , .F., 0 ) 
cSoap += WSSoapValue("CONTACT", ::oWSCONTACT, oWSCONTACT , "COMPANYUSERVIEW", .T. , .F., 0 ) 
cSoap += WSSoapValue("USERID", ::cUSERID, cUSERID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, cPASSWORD , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("SERVICEID", ::cSERVICEID, cSERVICEID , "string", .T. , .F., 0 ) 
cSoap += "</GETPARTNERWEB>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETPARTNERWEB",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw")

::Init()
::cGETPARTNERWEBRESULT :=  WSAdvValue( oXmlRet,"_GETPARTNERWEBRESPONSE:_GETPARTNERWEBRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method HANDSHAKE of Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD HANDSHAKE WSSEND cHARDLOCK,cFEDERALID,cUSERID,cPASSWORD,cSERVICEID WSRECEIVE oWSHANDSHAKERESULT WSCLIENT WSPARTNERECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HANDSHAKE xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FEDERALID", ::cFEDERALID, cFEDERALID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("USERID", ::cUSERID, cUSERID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, cPASSWORD , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("SERVICEID", ::cSERVICEID, cSERVICEID , "string", .T. , .F., 0 ) 
cSoap += "</HANDSHAKE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/HANDSHAKE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw")

::Init()
::oWSHANDSHAKERESULT:SoapRecv( WSAdvValue( oXmlRet,"_HANDSHAKERESPONSE:_HANDSHAKERESULT","HANDSHAKEVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method PUTPARTNERRECORD of Service WSPARTNERECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD PUTPARTNERRECORD WSSEND oWSPARTNERRECORD WSRECEIVE cPUTPARTNERRECORDRESULT WSCLIENT WSPARTNERECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTPARTNERRECORD xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("PARTNERRECORD", ::oWSPARTNERRECORD, oWSPARTNERRECORD , "PARTNERRECORDVIEW", .T. , .F., 0 ) 
cSoap += "</PUTPARTNERRECORD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/PUTPARTNERRECORD",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/PARTNERECOSYSTEM.apw")

::Init()
::cPUTPARTNERRECORDRESULT :=  WSAdvValue( oXmlRet,"_PUTPARTNERRECORDRESPONSE:_PUTPARTNERRECORDRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFPARTNERRECORDVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	WSDATA   oWSPARTNERRECORDVIEW      AS PARTNERECOSYSTEM_PARTNERRECORDVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	::oWSPARTNERRECORDVIEW := {} // Array Of  PARTNERECOSYSTEM_PARTNERRECORDVIEW():New()
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	Local oClone := PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW():NEW()
	oClone:oWSPARTNERRECORDVIEW := NIL
	If ::oWSPARTNERRECORDVIEW <> NIL 
		oClone:oWSPARTNERRECORDVIEW := {}
		aEval( ::oWSPARTNERRECORDVIEW , { |x| aadd( oClone:oWSPARTNERRECORDVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PARTNERECOSYSTEM_ARRAYOFPARTNERRECORDVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PARTNERRECORDVIEW","PARTNERRECORDVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPARTNERRECORDVIEW , PARTNERECOSYSTEM_PARTNERRECORDVIEW():New() )
			::oWSPARTNERRECORDVIEW[len(::oWSPARTNERRECORDVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure COMPANYVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_COMPANYVIEW
	WSDATA   oWSADDRESSES              AS PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW OPTIONAL
	WSDATA   cBRANCH                   AS string
	WSDATA   cCODE                     AS string
	WSDATA   cFEDERALID                AS string OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   cNICKNAME                 AS string
	WSDATA   oWSPHONES                 AS PARTNERECOSYSTEM_ARRAYOFPHONEVIEW OPTIONAL
	WSDATA   cSTATEID                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_COMPANYVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_COMPANYVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_COMPANYVIEW
	Local oClone := PARTNERECOSYSTEM_COMPANYVIEW():NEW()
	oClone:oWSADDRESSES         := IIF(::oWSADDRESSES = NIL , NIL , ::oWSADDRESSES:Clone() )
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCODE                := ::cCODE
	oClone:cFEDERALID           := ::cFEDERALID
	oClone:cNAME                := ::cNAME
	oClone:cNICKNAME            := ::cNICKNAME
	oClone:oWSPHONES            := IIF(::oWSPHONES = NIL , NIL , ::oWSPHONES:Clone() )
	oClone:cSTATEID             := ::cSTATEID
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_COMPANYVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("ADDRESSES", ::oWSADDRESSES, ::oWSADDRESSES , "ARRAYOFADDRESSVIEW", .F. , .F., 0 ) 
	cSoap += WSSoapValue("BRANCH", ::cBRANCH, ::cBRANCH , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("CODE", ::cCODE, ::cCODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("FEDERALID", ::cFEDERALID, ::cFEDERALID , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("NAME", ::cNAME, ::cNAME , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("NICKNAME", ::cNICKNAME, ::cNICKNAME , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PHONES", ::oWSPHONES, ::oWSPHONES , "ARRAYOFPHONEVIEW", .F. , .F., 0 ) 
	cSoap += WSSoapValue("STATEID", ::cSTATEID, ::cSTATEID , "string", .F. , .F., 0 ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure COMPANYUSERVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_COMPANYUSERVIEW
	WSDATA   oWSADDRESSES              AS PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW OPTIONAL
	WSDATA   cDEPARTMENTDESCRIPTION    AS string OPTIONAL
	WSDATA   cEMAIL                    AS string OPTIONAL
	WSDATA   cFEDERALID                AS string OPTIONAL
	WSDATA   cGROUPDESCRIPTION         AS string OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   oWSPHONES                 AS PARTNERECOSYSTEM_ARRAYOFPHONEVIEW OPTIONAL
	WSDATA   cPOSITIONDESCRIPTION      AS string OPTIONAL
	WSDATA   cUSERID                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_COMPANYUSERVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_COMPANYUSERVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_COMPANYUSERVIEW
	Local oClone := PARTNERECOSYSTEM_COMPANYUSERVIEW():NEW()
	oClone:oWSADDRESSES         := IIF(::oWSADDRESSES = NIL , NIL , ::oWSADDRESSES:Clone() )
	oClone:cDEPARTMENTDESCRIPTION := ::cDEPARTMENTDESCRIPTION
	oClone:cEMAIL               := ::cEMAIL
	oClone:cFEDERALID           := ::cFEDERALID
	oClone:cGROUPDESCRIPTION    := ::cGROUPDESCRIPTION
	oClone:cNAME                := ::cNAME
	oClone:oWSPHONES            := IIF(::oWSPHONES = NIL , NIL , ::oWSPHONES:Clone() )
	oClone:cPOSITIONDESCRIPTION := ::cPOSITIONDESCRIPTION
	oClone:cUSERID              := ::cUSERID
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_COMPANYUSERVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("ADDRESSES", ::oWSADDRESSES, ::oWSADDRESSES , "ARRAYOFADDRESSVIEW", .F. , .F., 0 ) 
	cSoap += WSSoapValue("DEPARTMENTDESCRIPTION", ::cDEPARTMENTDESCRIPTION, ::cDEPARTMENTDESCRIPTION , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("EMAIL", ::cEMAIL, ::cEMAIL , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("FEDERALID", ::cFEDERALID, ::cFEDERALID , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("GROUPDESCRIPTION", ::cGROUPDESCRIPTION, ::cGROUPDESCRIPTION , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("NAME", ::cNAME, ::cNAME , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PHONES", ::oWSPHONES, ::oWSPHONES , "ARRAYOFPHONEVIEW", .F. , .F., 0 ) 
	cSoap += WSSoapValue("POSITIONDESCRIPTION", ::cPOSITIONDESCRIPTION, ::cPOSITIONDESCRIPTION , "string", .F. , .F., 0 ) 
	cSoap += WSSoapValue("USERID", ::cUSERID, ::cUSERID , "string", .F. , .F., 0 ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure HANDSHAKEVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_HANDSHAKEVIEW
	WSDATA   cPASSWORD                 AS string
	WSDATA   cURL                      AS string OPTIONAL
	WSDATA   cUSERID                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_HANDSHAKEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_HANDSHAKEVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_HANDSHAKEVIEW
	Local oClone := PARTNERECOSYSTEM_HANDSHAKEVIEW():NEW()
	oClone:cPASSWORD            := ::cPASSWORD
	oClone:cURL                 := ::cURL
	oClone:cUSERID              := ::cUSERID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PARTNERECOSYSTEM_HANDSHAKEVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cPASSWORD          :=  WSAdvValue( oResponse,"_PASSWORD","string",NIL,"Property cPASSWORD as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cURL               :=  WSAdvValue( oResponse,"_URL","string",NIL,NIL,NIL,"S",NIL) 
	::cUSERID            :=  WSAdvValue( oResponse,"_USERID","string",NIL,"Property cUSERID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure PARTNERRECORDVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_PARTNERRECORDVIEW
	WSDATA   cFEDERALID                AS string
	WSDATA   cHARDLOCK                 AS string
	WSDATA   cPARTNERID                AS string
	WSDATA   cPASSWORD                 AS string
	WSDATA   cSERVICEID                AS string
	WSDATA   cURL                      AS string
	WSDATA   cUSERID                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_PARTNERRECORDVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_PARTNERRECORDVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_PARTNERRECORDVIEW
	Local oClone := PARTNERECOSYSTEM_PARTNERRECORDVIEW():NEW()
	oClone:cFEDERALID           := ::cFEDERALID
	oClone:cHARDLOCK            := ::cHARDLOCK
	oClone:cPARTNERID           := ::cPARTNERID
	oClone:cPASSWORD            := ::cPASSWORD
	oClone:cSERVICEID           := ::cSERVICEID
	oClone:cURL                 := ::cURL
	oClone:cUSERID              := ::cUSERID
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_PARTNERRECORDVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("FEDERALID", ::cFEDERALID, ::cFEDERALID , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, ::cHARDLOCK , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PARTNERID", ::cPARTNERID, ::cPARTNERID , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PASSWORD", ::cPASSWORD, ::cPASSWORD , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("SERVICEID", ::cSERVICEID, ::cSERVICEID , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("URL", ::cURL, ::cURL , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("USERID", ::cUSERID, ::cUSERID , "string", .T. , .F., 0 ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT PARTNERECOSYSTEM_PARTNERRECORDVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cFEDERALID         :=  WSAdvValue( oResponse,"_FEDERALID","string",NIL,"Property cFEDERALID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cHARDLOCK          :=  WSAdvValue( oResponse,"_HARDLOCK","string",NIL,"Property cHARDLOCK as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPARTNERID         :=  WSAdvValue( oResponse,"_PARTNERID","string",NIL,"Property cPARTNERID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPASSWORD          :=  WSAdvValue( oResponse,"_PASSWORD","string",NIL,"Property cPASSWORD as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSERVICEID         :=  WSAdvValue( oResponse,"_SERVICEID","string",NIL,"Property cSERVICEID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cURL               :=  WSAdvValue( oResponse,"_URL","string",NIL,"Property cURL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cUSERID            :=  WSAdvValue( oResponse,"_USERID","string",NIL,"Property cUSERID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFADDRESSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW
	WSDATA   oWSADDRESSVIEW            AS PARTNERECOSYSTEM_ADDRESSVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW
	::oWSADDRESSVIEW       := {} // Array Of  PARTNERECOSYSTEM_ADDRESSVIEW():New()
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW
	Local oClone := PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW():NEW()
	oClone:oWSADDRESSVIEW := NIL
	If ::oWSADDRESSVIEW <> NIL 
		oClone:oWSADDRESSVIEW := {}
		aEval( ::oWSADDRESSVIEW , { |x| aadd( oClone:oWSADDRESSVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_ARRAYOFADDRESSVIEW
	Local cSoap := ""
	aEval( ::oWSADDRESSVIEW , {|x| cSoap := cSoap  +  WSSoapValue("ADDRESSVIEW", x , x , "ADDRESSVIEW", .F. , .F., 0 )  } ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFPHONEVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_ARRAYOFPHONEVIEW
	WSDATA   oWSPHONEVIEW              AS PARTNERECOSYSTEM_PHONEVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_ARRAYOFPHONEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_ARRAYOFPHONEVIEW
	::oWSPHONEVIEW         := {} // Array Of  PARTNERECOSYSTEM_PHONEVIEW():New()
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_ARRAYOFPHONEVIEW
	Local oClone := PARTNERECOSYSTEM_ARRAYOFPHONEVIEW():NEW()
	oClone:oWSPHONEVIEW := NIL
	If ::oWSPHONEVIEW <> NIL 
		oClone:oWSPHONEVIEW := {}
		aEval( ::oWSPHONEVIEW , { |x| aadd( oClone:oWSPHONEVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_ARRAYOFPHONEVIEW
	Local cSoap := ""
	aEval( ::oWSPHONEVIEW , {|x| cSoap := cSoap  +  WSSoapValue("PHONEVIEW", x , x , "PHONEVIEW", .F. , .F., 0 )  } ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure ADDRESSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_ADDRESSVIEW
	WSDATA   cADDRESS                  AS string
	WSDATA   cADDRESSNUMBER            AS string
	WSDATA   cDISTRICT                 AS string
	WSDATA   cSTATE                    AS string
	WSDATA   cTYPEOFADDRESS            AS string
	WSDATA   cZIPCODE                  AS string
	WSDATA   cZONE                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_ADDRESSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_ADDRESSVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_ADDRESSVIEW
	Local oClone := PARTNERECOSYSTEM_ADDRESSVIEW():NEW()
	oClone:cADDRESS             := ::cADDRESS
	oClone:cADDRESSNUMBER       := ::cADDRESSNUMBER
	oClone:cDISTRICT            := ::cDISTRICT
	oClone:cSTATE               := ::cSTATE
	oClone:cTYPEOFADDRESS       := ::cTYPEOFADDRESS
	oClone:cZIPCODE             := ::cZIPCODE
	oClone:cZONE                := ::cZONE
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_ADDRESSVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("ADDRESS", ::cADDRESS, ::cADDRESS , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ADDRESSNUMBER", ::cADDRESSNUMBER, ::cADDRESSNUMBER , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("DISTRICT", ::cDISTRICT, ::cDISTRICT , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("STATE", ::cSTATE, ::cSTATE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("TYPEOFADDRESS", ::cTYPEOFADDRESS, ::cTYPEOFADDRESS , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ZIPCODE", ::cZIPCODE, ::cZIPCODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ZONE", ::cZONE, ::cZONE , "string", .T. , .F., 0 ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure PHONEVIEW
------------------------------------------------------------------------------- */

WSSTRUCT PARTNERECOSYSTEM_PHONEVIEW
	WSDATA   cCOUNTRYAREACODE          AS string
	WSDATA   cLOCALAREACODE            AS string
	WSDATA   cPHONENUMBER              AS string
	WSDATA   cTYPEOFPHONE              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT PARTNERECOSYSTEM_PHONEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT PARTNERECOSYSTEM_PHONEVIEW
Return

WSMETHOD CLONE WSCLIENT PARTNERECOSYSTEM_PHONEVIEW
	Local oClone := PARTNERECOSYSTEM_PHONEVIEW():NEW()
	oClone:cCOUNTRYAREACODE     := ::cCOUNTRYAREACODE
	oClone:cLOCALAREACODE       := ::cLOCALAREACODE
	oClone:cPHONENUMBER         := ::cPHONENUMBER
	oClone:cTYPEOFPHONE         := ::cTYPEOFPHONE
Return oClone

WSMETHOD SOAPSEND WSCLIENT PARTNERECOSYSTEM_PHONEVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("COUNTRYAREACODE", ::cCOUNTRYAREACODE, ::cCOUNTRYAREACODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("LOCALAREACODE", ::cLOCALAREACODE, ::cLOCALAREACODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PHONENUMBER", ::cPHONENUMBER, ::cPHONENUMBER , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("TYPEOFPHONE", ::cTYPEOFPHONE, ::cTYPEOFPHONE , "string", .T. , .F., 0 ) 
Return cSoap