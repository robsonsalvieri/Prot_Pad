#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±       
±±∫Programa. ≥wsclient_MsEcoSystem                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±       
±±∫Autor     ≥Marcelo Custodio      ≥Data   10/05/05                          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Fonte gerada por ADVPL WSDL Cliente                             ∫±±
±±∫          ≥Inclusao manual da Function "_WSMSEDU" para                     ∫±±
±±∫          ≥controle sobre geracao de patches                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                             ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

/* ===============================================================================
WSDL Location    http://webservices.microsiga.com.br/MSECOSYSTEM.apw?WSDL
Gerado em        06/14/04 14:59:55
ObservaÁıes      CÛdigo-Fonte gerado por ADVPL WSDL Client 1.040504
                 AlteraÁıes neste arquivo podem causar funcionamento incorreto
                 e ser„o perdidas caso o cÛdigo-fonte seja gerado novamente.
=============================================================================== */
 

Function _WSMSEDU() ; Return // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSCLIENT WSMSECOSYSTEM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD DELMEMBERECOSYSTEM
	WSMETHOD GETECOWEB
	WSMETHOD GETMEMBERECOSYSTEM
	WSMETHOD GETPARTNERS
	WSMETHOD HANDSHAKE
	WSMETHOD PUTMEMBERECOSYSTEM
	WSMETHOD PUTPOSTAGE

	WSDATA   _URL                      AS String
	WSDATA   cHARDLOCK                 AS string
	WSDATA   oWSCOMPANY                AS MSECOSYSTEM_COMPANYVIEW
	WSDATA   cDELMEMBERECOSYSTEMRESULT AS string
	WSDATA   oWSCONTACT                AS MSECOSYSTEM_COMPANYUSERVIEW
	WSDATA   cGETECOWEBRESULT          AS string
	WSDATA   oWSGETMEMBERECOSYSTEMRESULT AS MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	WSDATA   cPARTNERID                AS string
	WSDATA   oWSGETPARTNERSRESULT      AS MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	WSDATA   cFEDERALID                AS string
	WSDATA   lHANDSHAKERESULT          AS boolean
	WSDATA   cPUTMEMBERECOSYSTEMRESULT AS string
	WSDATA   cSERVICEID                AS string
	WSDATA   cPUTPOSTAGERESULT         AS string

	// Estruturas mantidas por compatibilidade - N√O USAR
	WSDATA   oWSCOMPANYVIEW            AS MSECOSYSTEM_COMPANYVIEW
	WSDATA   oWSCOMPANYUSERVIEW        AS MSECOSYSTEM_COMPANYUSERVIEW

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSMSECOSYSTEM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O CÛdigo-Fonte Client atual requer os execut·veis do Protheus Build [7.00.040506P] ou superior. Atualize o Protheus ou gere o CÛdigo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSMSECOSYSTEM
	::oWSCOMPANY         := MSECOSYSTEM_COMPANYVIEW():New()
	::oWSCONTACT         := MSECOSYSTEM_COMPANYUSERVIEW():New()
	::oWSGETMEMBERECOSYSTEMRESULT := MSECOSYSTEM_ARRAYOFCOMPANYVIEW():New()
	::oWSGETPARTNERSRESULT := MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW():New()

	// Estruturas mantidas por compatibilidade - N√O USAR
	::oWSCOMPANYVIEW     := ::oWSCOMPANY
	::oWSCOMPANYUSERVIEW := ::oWSCONTACT
Return

WSMETHOD RESET WSCLIENT WSMSECOSYSTEM
	::cHARDLOCK          := NIL 
	::oWSCOMPANY         := NIL 
	::cDELMEMBERECOSYSTEMRESULT := NIL 
	::oWSCONTACT         := NIL 
	::cGETECOWEBRESULT   := NIL 
	::oWSGETMEMBERECOSYSTEMRESULT := NIL 
	::cPARTNERID         := NIL 
	::oWSGETPARTNERSRESULT := NIL 
	::cFEDERALID         := NIL 
	::lHANDSHAKERESULT   := NIL 
	::cPUTMEMBERECOSYSTEMRESULT := NIL 
	::cSERVICEID         := NIL 
	::cPUTPOSTAGERESULT  := NIL 

	// Estruturas mantidas por compatibilidade - N√O USAR
	::oWSCOMPANYVIEW     := NIL
	::oWSCOMPANYUSERVIEW := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSMSECOSYSTEM
Local oClone := WSMSECOSYSTEM():New()
	oClone:_URL          := ::_URL 
	oClone:cHARDLOCK     := ::cHARDLOCK
	oClone:oWSCOMPANY    :=  IIF(::oWSCOMPANY = NIL , NIL ,::oWSCOMPANY:Clone() )
	oClone:cDELMEMBERECOSYSTEMRESULT := ::cDELMEMBERECOSYSTEMRESULT
	oClone:oWSCONTACT    :=  IIF(::oWSCONTACT = NIL , NIL ,::oWSCONTACT:Clone() )
	oClone:cGETECOWEBRESULT := ::cGETECOWEBRESULT
	oClone:oWSGETMEMBERECOSYSTEMRESULT :=  IIF(::oWSGETMEMBERECOSYSTEMRESULT = NIL , NIL ,::oWSGETMEMBERECOSYSTEMRESULT:Clone() )
	oClone:cPARTNERID    := ::cPARTNERID
	oClone:oWSGETPARTNERSRESULT :=  IIF(::oWSGETPARTNERSRESULT = NIL , NIL ,::oWSGETPARTNERSRESULT:Clone() )
	oClone:cFEDERALID    := ::cFEDERALID
	oClone:lHANDSHAKERESULT := ::lHANDSHAKERESULT
	oClone:cPUTMEMBERECOSYSTEMRESULT := ::cPUTMEMBERECOSYSTEMRESULT
	oClone:cSERVICEID    := ::cSERVICEID
	oClone:cPUTPOSTAGERESULT := ::cPUTPOSTAGERESULT

	// Estruturas mantidas por compatibilidade - N√O USAR
	oClone:oWSCOMPANYVIEW := oClone:oWSCOMPANY
	oClone:oWSCOMPANYUSERVIEW := oClone:oWSCONTACT
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method DELMEMBERECOSYSTEM of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD DELMEMBERECOSYSTEM WSSEND cHARDLOCK,oWSCOMPANY WSRECEIVE cDELMEMBERECOSYSTEMRESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DELMEMBERECOSYSTEM xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COMPANY", ::oWSCOMPANY, oWSCOMPANY , "COMPANYVIEW", .T. , .F., 0 ) 
cSoap += "</DELMEMBERECOSYSTEM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/DELMEMBERECOSYSTEM",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::cDELMEMBERECOSYSTEMRESULT :=  WSAdvValue( oXmlRet,"_DELMEMBERECOSYSTEMRESPONSE:_DELMEMBERECOSYSTEMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETECOWEB of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD GETECOWEB WSSEND cHARDLOCK,oWSCOMPANY,oWSCONTACT WSRECEIVE cGETECOWEBRESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETECOWEB xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COMPANY", ::oWSCOMPANY, oWSCOMPANY , "COMPANYVIEW", .T. , .F., 0 ) 
cSoap += WSSoapValue("CONTACT", ::oWSCONTACT, oWSCONTACT , "COMPANYUSERVIEW", .T. , .F., 0 ) 
cSoap += "</GETECOWEB>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETECOWEB",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::cGETECOWEBRESULT   :=  WSAdvValue( oXmlRet,"_GETECOWEBRESPONSE:_GETECOWEBRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETMEMBERECOSYSTEM of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD GETMEMBERECOSYSTEM WSSEND cHARDLOCK WSRECEIVE oWSGETMEMBERECOSYSTEMRESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETMEMBERECOSYSTEM xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += "</GETMEMBERECOSYSTEM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETMEMBERECOSYSTEM",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::oWSGETMEMBERECOSYSTEMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETMEMBERECOSYSTEMRESPONSE:_GETMEMBERECOSYSTEMRESULT","ARRAYOFCOMPANYVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETPARTNERS of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD GETPARTNERS WSSEND cPARTNERID WSRECEIVE oWSGETPARTNERSRESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPARTNERS xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("PARTNERID", ::cPARTNERID, cPARTNERID , "string", .T. , .F., 0 ) 
cSoap += "</GETPARTNERS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/GETPARTNERS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::oWSGETPARTNERSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPARTNERSRESPONSE:_GETPARTNERSRESULT","ARRAYOFECOPARTNERSVIEW",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method HANDSHAKE of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD HANDSHAKE WSSEND cHARDLOCK,cFEDERALID WSRECEIVE lHANDSHAKERESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<HANDSHAKE xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("FEDERALID", ::cFEDERALID, cFEDERALID , "string", .T. , .F., 0 ) 
cSoap += "</HANDSHAKE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/HANDSHAKE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::lHANDSHAKERESULT   :=  WSAdvValue( oXmlRet,"_HANDSHAKERESPONSE:_HANDSHAKERESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method PUTMEMBERECOSYSTEM of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD PUTMEMBERECOSYSTEM WSSEND cHARDLOCK,oWSCOMPANY WSRECEIVE cPUTMEMBERECOSYSTEMRESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTMEMBERECOSYSTEM xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COMPANY", ::oWSCOMPANY, oWSCOMPANY , "COMPANYVIEW", .T. , .F., 0 ) 
cSoap += "</PUTMEMBERECOSYSTEM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/PUTMEMBERECOSYSTEM",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::cPUTMEMBERECOSYSTEMRESULT :=  WSAdvValue( oXmlRet,"_PUTMEMBERECOSYSTEMRESPONSE:_PUTMEMBERECOSYSTEMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method PUTPOSTAGE of Service WSMSECOSYSTEM
------------------------------------------------------------------------------- */

WSMETHOD PUTPOSTAGE WSSEND cHARDLOCK,oWSCOMPANY,cPARTNERID,cSERVICEID WSRECEIVE cPUTPOSTAGERESULT WSCLIENT WSMSECOSYSTEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTPOSTAGE xmlns="http://webservices.microsiga.com.br/">'
cSoap += WSSoapValue("HARDLOCK", ::cHARDLOCK, cHARDLOCK , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COMPANY", ::oWSCOMPANY, oWSCOMPANY , "COMPANYVIEW", .T. , .F., 0 ) 
cSoap += WSSoapValue("PARTNERID", ::cPARTNERID, cPARTNERID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("SERVICEID", ::cSERVICEID, cSERVICEID , "string", .T. , .F., 0 ) 
cSoap += "</PUTPOSTAGE>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/PUTPOSTAGE",; 
	"DOCUMENT","http://webservices.microsiga.com.br/",,"1.031217",; 
	"http://webservices.microsiga.com.br/MSECOSYSTEM.apw")

::Init()
::cPUTPOSTAGERESULT  :=  WSAdvValue( oXmlRet,"_PUTPOSTAGERESPONSE:_PUTPOSTAGERESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure COMPANYUSERVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_COMPANYUSERVIEW
	WSDATA   oWSADDRESSES              AS MSECOSYSTEM_ARRAYOFADDRESSVIEW OPTIONAL
	WSDATA   cDEPARTMENTDESCRIPTION    AS string OPTIONAL
	WSDATA   cEMAIL                    AS string OPTIONAL
	WSDATA   cFEDERALID                AS string OPTIONAL
	WSDATA   cGROUPDESCRIPTION         AS string OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   oWSPHONES                 AS MSECOSYSTEM_ARRAYOFPHONEVIEW OPTIONAL
	WSDATA   cPOSITIONDESCRIPTION      AS string OPTIONAL
	WSDATA   cUSERID                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_COMPANYUSERVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_COMPANYUSERVIEW
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_COMPANYUSERVIEW
	Local oClone := MSECOSYSTEM_COMPANYUSERVIEW():NEW()
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

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_COMPANYUSERVIEW
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
WSDL Data Structure ARRAYOFCOMPANYVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	WSDATA   oWSCOMPANYVIEW            AS MSECOSYSTEM_COMPANYVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	::oWSCOMPANYVIEW       := {} // Array Of  MSECOSYSTEM_COMPANYVIEW():New()
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	Local oClone := MSECOSYSTEM_ARRAYOFCOMPANYVIEW():NEW()
	oClone:oWSCOMPANYVIEW := NIL
	If ::oWSCOMPANYVIEW <> NIL 
		oClone:oWSCOMPANYVIEW := {}
		aEval( ::oWSCOMPANYVIEW , { |x| aadd( oClone:oWSCOMPANYVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ARRAYOFCOMPANYVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_COMPANYVIEW","COMPANYVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSCOMPANYVIEW , MSECOSYSTEM_COMPANYVIEW():New() )
			::oWSCOMPANYVIEW[len(::oWSCOMPANYVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFECOPARTNERSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	WSDATA   oWSECOPARTNERSVIEW        AS MSECOSYSTEM_ECOPARTNERSVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	::oWSECOPARTNERSVIEW   := {} // Array Of  MSECOSYSTEM_ECOPARTNERSVIEW():New()
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	Local oClone := MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW():NEW()
	oClone:oWSECOPARTNERSVIEW := NIL
	If ::oWSECOPARTNERSVIEW <> NIL 
		oClone:oWSECOPARTNERSVIEW := {}
		aEval( ::oWSECOPARTNERSVIEW , { |x| aadd( oClone:oWSECOPARTNERSVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ARRAYOFECOPARTNERSVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ECOPARTNERSVIEW","ECOPARTNERSVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSECOPARTNERSVIEW , MSECOSYSTEM_ECOPARTNERSVIEW():New() )
			::oWSECOPARTNERSVIEW[len(::oWSECOPARTNERSVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure COMPANYVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_COMPANYVIEW
	WSDATA   oWSADDRESSES              AS MSECOSYSTEM_ARRAYOFADDRESSVIEW OPTIONAL
	WSDATA   cBRANCH                   AS string
	WSDATA   cCODE                     AS string
	WSDATA   cFEDERALID                AS string OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   cNICKNAME                 AS string
	WSDATA   oWSPHONES                 AS MSECOSYSTEM_ARRAYOFPHONEVIEW OPTIONAL
	WSDATA   cSTATEID                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_COMPANYVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_COMPANYVIEW
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_COMPANYVIEW
	Local oClone := MSECOSYSTEM_COMPANYVIEW():NEW()
	oClone:oWSADDRESSES         := IIF(::oWSADDRESSES = NIL , NIL , ::oWSADDRESSES:Clone() )
	oClone:cBRANCH              := ::cBRANCH
	oClone:cCODE                := ::cCODE
	oClone:cFEDERALID           := ::cFEDERALID
	oClone:cNAME                := ::cNAME
	oClone:cNICKNAME            := ::cNICKNAME
	oClone:oWSPHONES            := IIF(::oWSPHONES = NIL , NIL , ::oWSPHONES:Clone() )
	oClone:cSTATEID             := ::cSTATEID
Return oClone

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_COMPANYVIEW
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

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_COMPANYVIEW
	Local oNode1
	Local oNode7
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ADDRESSES","ARRAYOFADDRESSVIEW",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSADDRESSES := MSECOSYSTEM_ARRAYOFADDRESSVIEW():New()
		::oWSADDRESSES:SoapRecv(oNode1)
	EndIf
	::cBRANCH            :=  WSAdvValue( oResponse,"_BRANCH","string",NIL,"Property cBRANCH as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCODE              :=  WSAdvValue( oResponse,"_CODE","string",NIL,"Property cCODE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cFEDERALID         :=  WSAdvValue( oResponse,"_FEDERALID","string",NIL,NIL,NIL,"S",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNICKNAME          :=  WSAdvValue( oResponse,"_NICKNAME","string",NIL,"Property cNICKNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	oNode7 :=  WSAdvValue( oResponse,"_PHONES","ARRAYOFPHONEVIEW",NIL,NIL,NIL,"O",NIL) 
	If oNode7 != NIL
		::oWSPHONES := MSECOSYSTEM_ARRAYOFPHONEVIEW():New()
		::oWSPHONES:SoapRecv(oNode7)
	EndIf
	::cSTATEID           :=  WSAdvValue( oResponse,"_STATEID","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ECOPARTNERSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ECOPARTNERSVIEW
	WSDATA   cGROUP                    AS string
	WSDATA   cHOMEPAGE                 AS string
	WSDATA   cLOGO                     AS base64binary OPTIONAL
	WSDATA   cNAME                     AS string
	WSDATA   cNOTE                     AS string
	WSDATA   cPARTNERID                AS string
	WSDATA   cPASSWORD                 AS string OPTIONAL
	WSDATA   cURLLOCATION              AS string
	WSDATA   cURLSOAPACTION            AS string OPTIONAL
	WSDATA   cUSERID                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ECOPARTNERSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ECOPARTNERSVIEW
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ECOPARTNERSVIEW
	Local oClone := MSECOSYSTEM_ECOPARTNERSVIEW():NEW()
	oClone:cGROUP               := ::cGROUP
	oClone:cHOMEPAGE            := ::cHOMEPAGE
	oClone:cLOGO                := ::cLOGO
	oClone:cNAME                := ::cNAME
	oClone:cNOTE                := ::cNOTE
	oClone:cPARTNERID           := ::cPARTNERID
	oClone:cPASSWORD            := ::cPASSWORD
	oClone:cURLLOCATION         := ::cURLLOCATION
	oClone:cURLSOAPACTION       := ::cURLSOAPACTION
	oClone:cUSERID              := ::cUSERID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ECOPARTNERSVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cGROUP             :=  WSAdvValue( oResponse,"_GROUP","string",NIL,"Property cGROUP as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cHOMEPAGE          :=  WSAdvValue( oResponse,"_HOMEPAGE","string",NIL,"Property cHOMEPAGE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cLOGO              :=  WSAdvValue( oResponse,"_LOGO","base64binary",NIL,NIL,NIL,"SB",NIL) 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNOTE              :=  WSAdvValue( oResponse,"_NOTE","string",NIL,"Property cNOTE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPARTNERID         :=  WSAdvValue( oResponse,"_PARTNERID","string",NIL,"Property cPARTNERID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPASSWORD          :=  WSAdvValue( oResponse,"_PASSWORD","string",NIL,NIL,NIL,"S",NIL) 
	::cURLLOCATION       :=  WSAdvValue( oResponse,"_URLLOCATION","string",NIL,"Property cURLLOCATION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cURLSOAPACTION     :=  WSAdvValue( oResponse,"_URLSOAPACTION","string",NIL,NIL,NIL,"S",NIL) 
	::cUSERID            :=  WSAdvValue( oResponse,"_USERID","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFADDRESSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	WSDATA   oWSADDRESSVIEW            AS MSECOSYSTEM_ADDRESSVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	::oWSADDRESSVIEW       := {} // Array Of  MSECOSYSTEM_ADDRESSVIEW():New()
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	Local oClone := MSECOSYSTEM_ARRAYOFADDRESSVIEW():NEW()
	oClone:oWSADDRESSVIEW := NIL
	If ::oWSADDRESSVIEW <> NIL 
		oClone:oWSADDRESSVIEW := {}
		aEval( ::oWSADDRESSVIEW , { |x| aadd( oClone:oWSADDRESSVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	Local cSoap := ""
	aEval( ::oWSADDRESSVIEW , {|x| cSoap := cSoap  +  WSSoapValue("ADDRESSVIEW", x , x , "ADDRESSVIEW", .F. , .F., 0 )  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ARRAYOFADDRESSVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ADDRESSVIEW","ADDRESSVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSADDRESSVIEW , MSECOSYSTEM_ADDRESSVIEW():New() )
			::oWSADDRESSVIEW[len(::oWSADDRESSVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFPHONEVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ARRAYOFPHONEVIEW
	WSDATA   oWSPHONEVIEW              AS MSECOSYSTEM_PHONEVIEW OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ARRAYOFPHONEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ARRAYOFPHONEVIEW
	::oWSPHONEVIEW         := {} // Array Of  MSECOSYSTEM_PHONEVIEW():New()
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ARRAYOFPHONEVIEW
	Local oClone := MSECOSYSTEM_ARRAYOFPHONEVIEW():NEW()
	oClone:oWSPHONEVIEW := NIL
	If ::oWSPHONEVIEW <> NIL 
		oClone:oWSPHONEVIEW := {}
		aEval( ::oWSPHONEVIEW , { |x| aadd( oClone:oWSPHONEVIEW , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_ARRAYOFPHONEVIEW
	Local cSoap := ""
	aEval( ::oWSPHONEVIEW , {|x| cSoap := cSoap  +  WSSoapValue("PHONEVIEW", x , x , "PHONEVIEW", .F. , .F., 0 )  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ARRAYOFPHONEVIEW
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_PHONEVIEW","PHONEVIEW",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSPHONEVIEW , MSECOSYSTEM_PHONEVIEW():New() )
			::oWSPHONEVIEW[len(::oWSPHONEVIEW)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ADDRESSVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_ADDRESSVIEW
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
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_ADDRESSVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_ADDRESSVIEW
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_ADDRESSVIEW
	Local oClone := MSECOSYSTEM_ADDRESSVIEW():NEW()
	oClone:cADDRESS             := ::cADDRESS
	oClone:cADDRESSNUMBER       := ::cADDRESSNUMBER
	oClone:cDISTRICT            := ::cDISTRICT
	oClone:cSTATE               := ::cSTATE
	oClone:cTYPEOFADDRESS       := ::cTYPEOFADDRESS
	oClone:cZIPCODE             := ::cZIPCODE
	oClone:cZONE                := ::cZONE
Return oClone

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_ADDRESSVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("ADDRESS", ::cADDRESS, ::cADDRESS , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ADDRESSNUMBER", ::cADDRESSNUMBER, ::cADDRESSNUMBER , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("DISTRICT", ::cDISTRICT, ::cDISTRICT , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("STATE", ::cSTATE, ::cSTATE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("TYPEOFADDRESS", ::cTYPEOFADDRESS, ::cTYPEOFADDRESS , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ZIPCODE", ::cZIPCODE, ::cZIPCODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("ZONE", ::cZONE, ::cZONE , "string", .T. , .F., 0 ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_ADDRESSVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cADDRESS           :=  WSAdvValue( oResponse,"_ADDRESS","string",NIL,"Property cADDRESS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cADDRESSNUMBER     :=  WSAdvValue( oResponse,"_ADDRESSNUMBER","string",NIL,"Property cADDRESSNUMBER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cDISTRICT          :=  WSAdvValue( oResponse,"_DISTRICT","string",NIL,"Property cDISTRICT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSTATE             :=  WSAdvValue( oResponse,"_STATE","string",NIL,"Property cSTATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPEOFADDRESS     :=  WSAdvValue( oResponse,"_TYPEOFADDRESS","string",NIL,"Property cTYPEOFADDRESS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cZIPCODE           :=  WSAdvValue( oResponse,"_ZIPCODE","string",NIL,"Property cZIPCODE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cZONE              :=  WSAdvValue( oResponse,"_ZONE","string",NIL,"Property cZONE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure PHONEVIEW
------------------------------------------------------------------------------- */

WSSTRUCT MSECOSYSTEM_PHONEVIEW
	WSDATA   cCOUNTRYAREACODE          AS string
	WSDATA   cLOCALAREACODE            AS string
	WSDATA   cPHONENUMBER              AS string
	WSDATA   cTYPEOFPHONE              AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MSECOSYSTEM_PHONEVIEW
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MSECOSYSTEM_PHONEVIEW
Return

WSMETHOD CLONE WSCLIENT MSECOSYSTEM_PHONEVIEW
	Local oClone := MSECOSYSTEM_PHONEVIEW():NEW()
	oClone:cCOUNTRYAREACODE     := ::cCOUNTRYAREACODE
	oClone:cLOCALAREACODE       := ::cLOCALAREACODE
	oClone:cPHONENUMBER         := ::cPHONENUMBER
	oClone:cTYPEOFPHONE         := ::cTYPEOFPHONE
Return oClone

WSMETHOD SOAPSEND WSCLIENT MSECOSYSTEM_PHONEVIEW
	Local cSoap := ""
	cSoap += WSSoapValue("COUNTRYAREACODE", ::cCOUNTRYAREACODE, ::cCOUNTRYAREACODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("LOCALAREACODE", ::cLOCALAREACODE, ::cLOCALAREACODE , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("PHONENUMBER", ::cPHONENUMBER, ::cPHONENUMBER , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("TYPEOFPHONE", ::cTYPEOFPHONE, ::cTYPEOFPHONE , "string", .T. , .F., 0 ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT MSECOSYSTEM_PHONEVIEW
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCOUNTRYAREACODE   :=  WSAdvValue( oResponse,"_COUNTRYAREACODE","string",NIL,"Property cCOUNTRYAREACODE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cLOCALAREACODE     :=  WSAdvValue( oResponse,"_LOCALAREACODE","string",NIL,"Property cLOCALAREACODE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPHONENUMBER       :=  WSAdvValue( oResponse,"_PHONENUMBER","string",NIL,"Property cPHONENUMBER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPEOFPHONE       :=  WSAdvValue( oResponse,"_TYPEOFPHONE","string",NIL,"Property cTYPEOFPHONE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return
