#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://webservices.microsiga.com.br/SIGAGAC.apw?WSDL
Gerado em        03/09/06 16:05:48
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.060117
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _APRLRCM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSCLIENT WSSIGAGAC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ANALYTICSEARCH
	WSMETHOD ANALYTICSEARCHBOOKS
	WSMETHOD ANALYTICSEARCHPERIODICALS
	WSMETHOD ANALYTICSEARCHTHESIS
	WSMETHOD ASYNTHETICSEARCH
	WSMETHOD GETPHOTO
	WSMETHOD GETSUBJECT
	WSMETHOD RESERVATION
	WSMETHOD RETCAMPOSPESQ
	WSMETHOD RETTIPOPUBLIC
	WSMETHOD SEARCHNEW
	WSMETHOD SYNTHETICSEARCHBOOKS
	WSMETHOD SYNTHETICSEARCHPERIODICALS
	WSMETHOD SYNTHETICSEARCHTHESIS

	WSDATA   _URL                      AS String
	WSDATA   cUSERCODE                 AS string
	WSDATA   cPUBLICATIONID            AS string
	WSDATA   cPLACEID                  AS string
	WSDATA   cTYPEPUBLIC               AS string
	WSDATA   oWSANALYTICSEARCHRESULT   AS SIGAGAC_WSDETAILS
	WSDATA   cCOPYID                   AS string
	WSDATA   oWSANALYTICSEARCHBOOKSRESULT AS SIGAGAC_WSDETAILSBOOKS
	WSDATA   oWSANALYTICSEARCHPERIODICALSRESULT AS SIGAGAC_WSDETAILSPERIODICALS
	WSDATA   oWSANALYTICSEARCHTHESISRESULT AS SIGAGAC_WSDETAILSTHESIS
	WSDATA   oWSSTSEARCH               AS SIGAGAC_WSVALUESSEARCH
	WSDATA   oWSASYNTHETICSEARCHRESULT AS SIGAGAC_ARRAYOFWSPUBLICATIONS
	WSDATA   cGETPHOTORESULT           AS base64binary
	WSDATA   oWSGETSUBJECTRESULT       AS SIGAGAC_ARRAYOFWSSUBJECTS
	WSDATA   cCUSTOMERID               AS string
	WSDATA   cCUSTOMERUNIT             AS string
	WSDATA   oWSRESERVATIONRESULT      AS SIGAGAC_WSOKRESERVED
	WSDATA   cCALIASPESQ               AS string
	WSDATA   oWSRETCAMPOSPESQRESULT    AS SIGAGAC_ARRAYOFWSCPPESQ
	WSDATA   oWSRETTIPOPUBLICRESULT    AS SIGAGAC_ARRAYOFWSTPPUBL
	WSDATA   lSEARCHNEWRESULT          AS boolean
	WSDATA   cTITLE                    AS string
	WSDATA   cORIGINALTITLE            AS string
	WSDATA   cSUBTITLE                 AS string
	WSDATA   cAUTHOR                   AS string
	WSDATA   cPUBLISHINGHOUSE          AS string
	WSDATA   nPUBLISHYEAR              AS integer
	WSDATA   cISBN                     AS string
	WSDATA   cSUBJECTID                AS string
	WSDATA   lEXACTSEARCH              AS boolean
	WSDATA   nTOPSEARCH                AS integer
	WSDATA   oWSSYNTHETICSEARCHBOOKSRESULT AS SIGAGAC_ARRAYOFWSPUBLICATIONS
	WSDATA   cISSN                     AS string
	WSDATA   oWSSYNTHETICSEARCHPERIODICALSRESULT AS SIGAGAC_ARRAYOFWSPUBLICATIONS
	WSDATA   cLEADER                   AS string
	WSDATA   oWSSYNTHETICSEARCHTHESISRESULT AS SIGAGAC_ARRAYOFWSPUBLICATIONS

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSWSVALUESSEARCH         AS SIGAGAC_WSVALUESSEARCH

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSIGAGAC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.051130P] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSIGAGAC
	::oWSANALYTICSEARCHRESULT := SIGAGAC_WSDETAILS():New()
	::oWSANALYTICSEARCHBOOKSRESULT := SIGAGAC_WSDETAILSBOOKS():New()
	::oWSANALYTICSEARCHPERIODICALSRESULT := SIGAGAC_WSDETAILSPERIODICALS():New()
	::oWSANALYTICSEARCHTHESISRESULT := SIGAGAC_WSDETAILSTHESIS():New()
	::oWSSTSEARCH        := SIGAGAC_WSVALUESSEARCH():New()
	::oWSASYNTHETICSEARCHRESULT := SIGAGAC_ARRAYOFWSPUBLICATIONS():New()
	::oWSGETSUBJECTRESULT := SIGAGAC_ARRAYOFWSSUBJECTS():New()
	::oWSRESERVATIONRESULT := SIGAGAC_WSOKRESERVED():New()
	::oWSRETCAMPOSPESQRESULT := SIGAGAC_ARRAYOFWSCPPESQ():New()
	::oWSRETTIPOPUBLICRESULT := SIGAGAC_ARRAYOFWSTPPUBL():New()
	::oWSSYNTHETICSEARCHBOOKSRESULT := SIGAGAC_ARRAYOFWSPUBLICATIONS():New()
	::oWSSYNTHETICSEARCHPERIODICALSRESULT := SIGAGAC_ARRAYOFWSPUBLICATIONS():New()
	::oWSSYNTHETICSEARCHTHESISRESULT := SIGAGAC_ARRAYOFWSPUBLICATIONS():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSVALUESSEARCH  := ::oWSSTSEARCH
Return

WSMETHOD RESET WSCLIENT WSSIGAGAC
	::cUSERCODE          := NIL 
	::cPUBLICATIONID     := NIL 
	::cPLACEID           := NIL 
	::cTYPEPUBLIC        := NIL 
	::oWSANALYTICSEARCHRESULT := NIL 
	::cCOPYID            := NIL 
	::oWSANALYTICSEARCHBOOKSRESULT := NIL 
	::oWSANALYTICSEARCHPERIODICALSRESULT := NIL 
	::oWSANALYTICSEARCHTHESISRESULT := NIL 
	::oWSSTSEARCH        := NIL 
	::oWSASYNTHETICSEARCHRESULT := NIL 
	::cGETPHOTORESULT    := NIL 
	::oWSGETSUBJECTRESULT := NIL 
	::cCUSTOMERID        := NIL 
	::cCUSTOMERUNIT      := NIL 
	::oWSRESERVATIONRESULT := NIL 
	::cCALIASPESQ        := NIL 
	::oWSRETCAMPOSPESQRESULT := NIL 
	::oWSRETTIPOPUBLICRESULT := NIL 
	::lSEARCHNEWRESULT   := NIL 
	::cTITLE             := NIL 
	::cORIGINALTITLE     := NIL 
	::cSUBTITLE          := NIL 
	::cAUTHOR            := NIL 
	::cPUBLISHINGHOUSE   := NIL 
	::nPUBLISHYEAR       := NIL 
	::cISBN              := NIL 
	::cSUBJECTID         := NIL 
	::lEXACTSEARCH       := NIL 
	::nTOPSEARCH         := NIL 
	::oWSSYNTHETICSEARCHBOOKSRESULT := NIL 
	::cISSN              := NIL 
	::oWSSYNTHETICSEARCHPERIODICALSRESULT := NIL 
	::cLEADER            := NIL 
	::oWSSYNTHETICSEARCHTHESISRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSWSVALUESSEARCH  := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSIGAGAC
Local oClone := WSSIGAGAC():New()
	oClone:_URL          := ::_URL 
	oClone:cUSERCODE     := ::cUSERCODE
	oClone:cPUBLICATIONID := ::cPUBLICATIONID
	oClone:cPLACEID      := ::cPLACEID
	oClone:cTYPEPUBLIC   := ::cTYPEPUBLIC
	oClone:oWSANALYTICSEARCHRESULT :=  IIF(::oWSANALYTICSEARCHRESULT = NIL , NIL ,::oWSANALYTICSEARCHRESULT:Clone() )
	oClone:cCOPYID       := ::cCOPYID
	oClone:oWSANALYTICSEARCHBOOKSRESULT :=  IIF(::oWSANALYTICSEARCHBOOKSRESULT = NIL , NIL ,::oWSANALYTICSEARCHBOOKSRESULT:Clone() )
	oClone:oWSANALYTICSEARCHPERIODICALSRESULT :=  IIF(::oWSANALYTICSEARCHPERIODICALSRESULT = NIL , NIL ,::oWSANALYTICSEARCHPERIODICALSRESULT:Clone() )
	oClone:oWSANALYTICSEARCHTHESISRESULT :=  IIF(::oWSANALYTICSEARCHTHESISRESULT = NIL , NIL ,::oWSANALYTICSEARCHTHESISRESULT:Clone() )
	oClone:oWSSTSEARCH   :=  IIF(::oWSSTSEARCH = NIL , NIL ,::oWSSTSEARCH:Clone() )
	oClone:oWSASYNTHETICSEARCHRESULT :=  IIF(::oWSASYNTHETICSEARCHRESULT = NIL , NIL ,::oWSASYNTHETICSEARCHRESULT:Clone() )
	oClone:cGETPHOTORESULT := ::cGETPHOTORESULT
	oClone:oWSGETSUBJECTRESULT :=  IIF(::oWSGETSUBJECTRESULT = NIL , NIL ,::oWSGETSUBJECTRESULT:Clone() )
	oClone:cCUSTOMERID   := ::cCUSTOMERID
	oClone:cCUSTOMERUNIT := ::cCUSTOMERUNIT
	oClone:oWSRESERVATIONRESULT :=  IIF(::oWSRESERVATIONRESULT = NIL , NIL ,::oWSRESERVATIONRESULT:Clone() )
	oClone:cCALIASPESQ   := ::cCALIASPESQ
	oClone:oWSRETCAMPOSPESQRESULT :=  IIF(::oWSRETCAMPOSPESQRESULT = NIL , NIL ,::oWSRETCAMPOSPESQRESULT:Clone() )
	oClone:oWSRETTIPOPUBLICRESULT :=  IIF(::oWSRETTIPOPUBLICRESULT = NIL , NIL ,::oWSRETTIPOPUBLICRESULT:Clone() )
	oClone:lSEARCHNEWRESULT := ::lSEARCHNEWRESULT
	oClone:cTITLE        := ::cTITLE
	oClone:cORIGINALTITLE := ::cORIGINALTITLE
	oClone:cSUBTITLE     := ::cSUBTITLE
	oClone:cAUTHOR       := ::cAUTHOR
	oClone:cPUBLISHINGHOUSE := ::cPUBLISHINGHOUSE
	oClone:nPUBLISHYEAR  := ::nPUBLISHYEAR
	oClone:cISBN         := ::cISBN
	oClone:cSUBJECTID    := ::cSUBJECTID
	oClone:lEXACTSEARCH  := ::lEXACTSEARCH
	oClone:nTOPSEARCH    := ::nTOPSEARCH
	oClone:oWSSYNTHETICSEARCHBOOKSRESULT :=  IIF(::oWSSYNTHETICSEARCHBOOKSRESULT = NIL , NIL ,::oWSSYNTHETICSEARCHBOOKSRESULT:Clone() )
	oClone:cISSN         := ::cISSN
	oClone:oWSSYNTHETICSEARCHPERIODICALSRESULT :=  IIF(::oWSSYNTHETICSEARCHPERIODICALSRESULT = NIL , NIL ,::oWSSYNTHETICSEARCHPERIODICALSRESULT:Clone() )
	oClone:cLEADER       := ::cLEADER
	oClone:oWSSYNTHETICSEARCHTHESISRESULT :=  IIF(::oWSSYNTHETICSEARCHTHESISRESULT = NIL , NIL ,::oWSSYNTHETICSEARCHTHESISRESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSWSVALUESSEARCH := oClone:oWSSTSEARCH
Return oClone

/* -------------------------------------------------------------------------------
WSDL Method ANALYTICSEARCH of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD ANALYTICSEARCH WSSEND cUSERCODE,cPUBLICATIONID,cPLACEID,cTYPEPUBLIC WSRECEIVE oWSANALYTICSEARCHRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ANALYTICSEARCH xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PLACEID", ::cPLACEID, cPLACEID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("TYPEPUBLIC", ::cTYPEPUBLIC, cTYPEPUBLIC , "string", .T. , .F., 0 ) 
cSoap += "</ANALYTICSEARCH>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/ANALYTICSEARCH",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSANALYTICSEARCHRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ANALYTICSEARCHRESPONSE:_ANALYTICSEARCHRESULT","WSDETAILS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method ANALYTICSEARCHBOOKS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD ANALYTICSEARCHBOOKS WSSEND cUSERCODE,cPUBLICATIONID,cCOPYID WSRECEIVE oWSANALYTICSEARCHBOOKSRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ANALYTICSEARCHBOOKS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COPYID", ::cCOPYID, cCOPYID , "string", .F. , .F., 0 ) 
cSoap += "</ANALYTICSEARCHBOOKS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/ANALYTICSEARCHBOOKS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSANALYTICSEARCHBOOKSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ANALYTICSEARCHBOOKSRESPONSE:_ANALYTICSEARCHBOOKSRESULT","WSDETAILSBOOKS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method ANALYTICSEARCHPERIODICALS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD ANALYTICSEARCHPERIODICALS WSSEND cUSERCODE,cPUBLICATIONID,cCOPYID WSRECEIVE oWSANALYTICSEARCHPERIODICALSRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ANALYTICSEARCHPERIODICALS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COPYID", ::cCOPYID, cCOPYID , "string", .F. , .F., 0 ) 
cSoap += "</ANALYTICSEARCHPERIODICALS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/ANALYTICSEARCHPERIODICALS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSANALYTICSEARCHPERIODICALSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ANALYTICSEARCHPERIODICALSRESPONSE:_ANALYTICSEARCHPERIODICALSRESULT","WSDETAILSPERIODICALS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method ANALYTICSEARCHTHESIS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD ANALYTICSEARCHTHESIS WSSEND cUSERCODE,cPUBLICATIONID,cCOPYID WSRECEIVE oWSANALYTICSEARCHTHESISRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ANALYTICSEARCHTHESIS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COPYID", ::cCOPYID, cCOPYID , "string", .F. , .F., 0 ) 
cSoap += "</ANALYTICSEARCHTHESIS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/ANALYTICSEARCHTHESIS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSANALYTICSEARCHTHESISRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ANALYTICSEARCHTHESISRESPONSE:_ANALYTICSEARCHTHESISRESULT","WSDETAILSTHESIS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method ASYNTHETICSEARCH of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD ASYNTHETICSEARCH WSSEND oWSSTSEARCH WSRECEIVE oWSASYNTHETICSEARCHRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ASYNTHETICSEARCH xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("STSEARCH", ::oWSSTSEARCH, oWSSTSEARCH , "WSVALUESSEARCH", .T. , .F., 0 ) 
cSoap += "</ASYNTHETICSEARCH>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/ASYNTHETICSEARCH",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSASYNTHETICSEARCHRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ASYNTHETICSEARCHRESPONSE:_ASYNTHETICSEARCHRESULT","ARRAYOFWSPUBLICATIONS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETPHOTO of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD GETPHOTO WSSEND cUSERCODE,cPUBLICATIONID WSRECEIVE cGETPHOTORESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPHOTO xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += "</GETPHOTO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/GETPHOTO",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::cGETPHOTORESULT    :=  WSAdvValue( oXmlRet,"_GETPHOTORESPONSE:_GETPHOTORESULT:TEXT","base64binary",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method GETSUBJECT of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD GETSUBJECT WSSEND cUSERCODE WSRECEIVE oWSGETSUBJECTRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSUBJECT xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += "</GETSUBJECT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/GETSUBJECT",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSGETSUBJECTRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSUBJECTRESPONSE:_GETSUBJECTRESULT","ARRAYOFWSSUBJECTS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RESERVATION of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD RESERVATION WSSEND cUSERCODE,cPUBLICATIONID,cCOPYID,cCUSTOMERID,cCUSTOMERUNIT,cTYPEPUBLIC WSRECEIVE oWSRESERVATIONRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RESERVATION xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("PUBLICATIONID", ::cPUBLICATIONID, cPUBLICATIONID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("COPYID", ::cCOPYID, cCOPYID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("CUSTOMERID", ::cCUSTOMERID, cCUSTOMERID , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CUSTOMERUNIT", ::cCUSTOMERUNIT, cCUSTOMERUNIT , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("TYPEPUBLIC", ::cTYPEPUBLIC, cTYPEPUBLIC , "string", .T. , .F., 0 ) 
cSoap += "</RESERVATION>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/RESERVATION",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSRESERVATIONRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RESERVATIONRESPONSE:_RESERVATIONRESULT","WSOKRESERVED",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETCAMPOSPESQ of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD RETCAMPOSPESQ WSSEND cUSERCODE,cCALIASPESQ WSRECEIVE oWSRETCAMPOSPESQRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETCAMPOSPESQ xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("CALIASPESQ", ::cCALIASPESQ, cCALIASPESQ , "string", .T. , .F., 0 ) 
cSoap += "</RETCAMPOSPESQ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/RETCAMPOSPESQ",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSRETCAMPOSPESQRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETCAMPOSPESQRESPONSE:_RETCAMPOSPESQRESULT","ARRAYOFWSCPPESQ",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method RETTIPOPUBLIC of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD RETTIPOPUBLIC WSSEND cUSERCODE WSRECEIVE oWSRETTIPOPUBLICRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<RETTIPOPUBLIC xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += "</RETTIPOPUBLIC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/RETTIPOPUBLIC",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSRETTIPOPUBLICRESULT:SoapRecv( WSAdvValue( oXmlRet,"_RETTIPOPUBLICRESPONSE:_RETTIPOPUBLICRESULT","ARRAYOFWSTPPUBL",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method SEARCHNEW of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD SEARCHNEW WSSEND cUSERCODE WSRECEIVE lSEARCHNEWRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SEARCHNEW xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += "</SEARCHNEW>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/SEARCHNEW",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::lSEARCHNEWRESULT   :=  WSAdvValue( oXmlRet,"_SEARCHNEWRESPONSE:_SEARCHNEWRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method SYNTHETICSEARCHBOOKS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD SYNTHETICSEARCHBOOKS WSSEND cUSERCODE,cTITLE,cORIGINALTITLE,cSUBTITLE,cAUTHOR,cPUBLISHINGHOUSE,nPUBLISHYEAR,cISBN,cSUBJECTID,lEXACTSEARCH,nTOPSEARCH WSRECEIVE oWSSYNTHETICSEARCHBOOKSRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SYNTHETICSEARCHBOOKS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("TITLE", ::cTITLE, cTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("ORIGINALTITLE", ::cORIGINALTITLE, cORIGINALTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("SUBTITLE", ::cSUBTITLE, cSUBTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("AUTHOR", ::cAUTHOR, cAUTHOR , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("PUBLISHINGHOUSE", ::cPUBLISHINGHOUSE, cPUBLISHINGHOUSE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("PUBLISHYEAR", ::nPUBLISHYEAR, nPUBLISHYEAR , "integer", .F. , .F., 0 ) 
cSoap += WSSoapValue("ISBN", ::cISBN, cISBN , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("SUBJECTID", ::cSUBJECTID, cSUBJECTID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("EXACTSEARCH", ::lEXACTSEARCH, lEXACTSEARCH , "boolean", .F. , .F., 0 ) 
cSoap += WSSoapValue("TOPSEARCH", ::nTOPSEARCH, nTOPSEARCH , "integer", .F. , .F., 0 ) 
cSoap += "</SYNTHETICSEARCHBOOKS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/SYNTHETICSEARCHBOOKS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSSYNTHETICSEARCHBOOKSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SYNTHETICSEARCHBOOKSRESPONSE:_SYNTHETICSEARCHBOOKSRESULT","ARRAYOFWSPUBLICATIONS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method SYNTHETICSEARCHPERIODICALS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD SYNTHETICSEARCHPERIODICALS WSSEND cUSERCODE,cTITLE,cORIGINALTITLE,cSUBTITLE,cPUBLISHINGHOUSE,nPUBLISHYEAR,cISSN,cSUBJECTID,lEXACTSEARCH,nTOPSEARCH WSRECEIVE oWSSYNTHETICSEARCHPERIODICALSRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SYNTHETICSEARCHPERIODICALS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("TITLE", ::cTITLE, cTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("ORIGINALTITLE", ::cORIGINALTITLE, cORIGINALTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("SUBTITLE", ::cSUBTITLE, cSUBTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("PUBLISHINGHOUSE", ::cPUBLISHINGHOUSE, cPUBLISHINGHOUSE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("PUBLISHYEAR", ::nPUBLISHYEAR, nPUBLISHYEAR , "integer", .F. , .F., 0 ) 
cSoap += WSSoapValue("ISSN", ::cISSN, cISSN , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("SUBJECTID", ::cSUBJECTID, cSUBJECTID , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("EXACTSEARCH", ::lEXACTSEARCH, lEXACTSEARCH , "boolean", .F. , .F., 0 ) 
cSoap += WSSoapValue("TOPSEARCH", ::nTOPSEARCH, nTOPSEARCH , "integer", .F. , .F., 0 ) 
cSoap += "</SYNTHETICSEARCHPERIODICALS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/SYNTHETICSEARCHPERIODICALS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSSYNTHETICSEARCHPERIODICALSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SYNTHETICSEARCHPERIODICALSRESPONSE:_SYNTHETICSEARCHPERIODICALSRESULT","ARRAYOFWSPUBLICATIONS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

/* -------------------------------------------------------------------------------
WSDL Method SYNTHETICSEARCHTHESIS of Service WSSIGAGAC
------------------------------------------------------------------------------- */

WSMETHOD SYNTHETICSEARCHTHESIS WSSEND cUSERCODE,cTITLE,cORIGINALTITLE,cSUBTITLE,cAUTHOR,cLEADER,nPUBLISHYEAR,lEXACTSEARCH,nTOPSEARCH WSRECEIVE oWSSYNTHETICSEARCHTHESISRESULT WSCLIENT WSSIGAGAC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SYNTHETICSEARCHTHESIS xmlns="http://webservices.microsiga.com.br/sigagac.apw">'
cSoap += WSSoapValue("USERCODE", ::cUSERCODE, cUSERCODE , "string", .T. , .F., 0 ) 
cSoap += WSSoapValue("TITLE", ::cTITLE, cTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("ORIGINALTITLE", ::cORIGINALTITLE, cORIGINALTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("SUBTITLE", ::cSUBTITLE, cSUBTITLE , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("AUTHOR", ::cAUTHOR, cAUTHOR , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("LEADER", ::cLEADER, cLEADER , "string", .F. , .F., 0 ) 
cSoap += WSSoapValue("PUBLISHYEAR", ::nPUBLISHYEAR, nPUBLISHYEAR , "integer", .F. , .F., 0 ) 
cSoap += WSSoapValue("EXACTSEARCH", ::lEXACTSEARCH, lEXACTSEARCH , "boolean", .F. , .F., 0 ) 
cSoap += WSSoapValue("TOPSEARCH", ::nTOPSEARCH, nTOPSEARCH , "integer", .F. , .F., 0 ) 
cSoap += "</SYNTHETICSEARCHTHESIS>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://webservices.microsiga.com.br/sigagac.apw/SYNTHETICSEARCHTHESIS",; 
	"DOCUMENT","http://webservices.microsiga.com.br/sigagac.apw",,"1.031217",; 
	"http://webservices.microsiga.com.br/SIGAGAC.apw")

::Init()
::oWSSYNTHETICSEARCHTHESISRESULT:SoapRecv( WSAdvValue( oXmlRet,"_SYNTHETICSEARCHTHESISRESPONSE:_SYNTHETICSEARCHTHESISRESULT","ARRAYOFWSPUBLICATIONS",NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILS
	WSDATA   oWSAAUTHORS               AS SIGAGAC_ARRAYOFWSDETAILSAUTHORS OPTIONAL
	WSDATA   oWSACOPIES                AS SIGAGAC_ARRAYOFWSDETAILSCOPY OPTIONAL
	WSDATA   cAREA                     AS string
	WSDATA   cCOLECTION                AS string
	WSDATA   cCOUNTRY                  AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cGROUP                    AS string
	WSDATA   lHAVEPHOTO                AS boolean
	WSDATA   cIDIOM                    AS string
	WSDATA   lILLUSTRATED              AS boolean
	WSDATA   cINSTRUCTIONLEVEL         AS string
	WSDATA   cISBN                     AS string
	WSDATA   cORIGINALTITLE            AS string
	WSDATA   nPAGES                    AS integer
	WSDATA   cPLACEID                  AS string
	WSDATA   cPUBLISHINGHOUSE          AS string
	WSDATA   cPUBLISHPLACE             AS string
	WSDATA   nPUBLISHYEAR              AS integer
	WSDATA   cREMARK                   AS string
	WSDATA   cSITE                     AS string
	WSDATA   cSTATE                    AS string
	WSDATA   cSUBJECT                  AS string
	WSDATA   cSUBTITLE                 AS string
	WSDATA   cSUMMARY                  AS string
	WSDATA   cSYNTHESIS                AS string
	WSDATA   cTITLE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILS
	Local oClone := SIGAGAC_WSDETAILS():NEW()
	oClone:oWSAAUTHORS          := IIF(::oWSAAUTHORS = NIL , NIL , ::oWSAAUTHORS:Clone() )
	oClone:oWSACOPIES           := IIF(::oWSACOPIES = NIL , NIL , ::oWSACOPIES:Clone() )
	oClone:cAREA                := ::cAREA
	oClone:cCOLECTION           := ::cCOLECTION
	oClone:cCOUNTRY             := ::cCOUNTRY
	oClone:cEMAIL               := ::cEMAIL
	oClone:cGROUP               := ::cGROUP
	oClone:lHAVEPHOTO           := ::lHAVEPHOTO
	oClone:cIDIOM               := ::cIDIOM
	oClone:lILLUSTRATED         := ::lILLUSTRATED
	oClone:cINSTRUCTIONLEVEL    := ::cINSTRUCTIONLEVEL
	oClone:cISBN                := ::cISBN
	oClone:cORIGINALTITLE       := ::cORIGINALTITLE
	oClone:nPAGES               := ::nPAGES
	oClone:cPLACEID             := ::cPLACEID
	oClone:cPUBLISHINGHOUSE     := ::cPUBLISHINGHOUSE
	oClone:cPUBLISHPLACE        := ::cPUBLISHPLACE
	oClone:nPUBLISHYEAR         := ::nPUBLISHYEAR
	oClone:cREMARK              := ::cREMARK
	oClone:cSITE                := ::cSITE
	oClone:cSTATE               := ::cSTATE
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cSUBTITLE            := ::cSUBTITLE
	oClone:cSUMMARY             := ::cSUMMARY
	oClone:cSYNTHESIS           := ::cSYNTHESIS
	oClone:cTITLE               := ::cTITLE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILS
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AAUTHORS","ARRAYOFWSDETAILSAUTHORS",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSAAUTHORS := SIGAGAC_ARRAYOFWSDETAILSAUTHORS():New()
		::oWSAAUTHORS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_ACOPIES","ARRAYOFWSDETAILSCOPY",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSACOPIES := SIGAGAC_ARRAYOFWSDETAILSCOPY():New()
		::oWSACOPIES:SoapRecv(oNode2)
	EndIf
	::cAREA              :=  WSAdvValue( oResponse,"_AREA","string",NIL,"Property cAREA as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOLECTION         :=  WSAdvValue( oResponse,"_COLECTION","string",NIL,"Property cCOLECTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOUNTRY           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,"Property cCOUNTRY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,"Property cEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cGROUP             :=  WSAdvValue( oResponse,"_GROUP","string",NIL,"Property cGROUP as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lHAVEPHOTO         :=  WSAdvValue( oResponse,"_HAVEPHOTO","boolean",NIL,"Property lHAVEPHOTO as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cIDIOM             :=  WSAdvValue( oResponse,"_IDIOM","string",NIL,"Property cIDIOM as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lILLUSTRATED       :=  WSAdvValue( oResponse,"_ILLUSTRATED","boolean",NIL,"Property lILLUSTRATED as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cINSTRUCTIONLEVEL  :=  WSAdvValue( oResponse,"_INSTRUCTIONLEVEL","string",NIL,"Property cINSTRUCTIONLEVEL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cISBN              :=  WSAdvValue( oResponse,"_ISBN","string",NIL,"Property cISBN as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cORIGINALTITLE     :=  WSAdvValue( oResponse,"_ORIGINALTITLE","string",NIL,"Property cORIGINALTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPAGES             :=  WSAdvValue( oResponse,"_PAGES","integer",NIL,"Property nPAGES as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cPLACEID           :=  WSAdvValue( oResponse,"_PLACEID","string",NIL,"Property cPLACEID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHINGHOUSE   :=  WSAdvValue( oResponse,"_PUBLISHINGHOUSE","string",NIL,"Property cPUBLISHINGHOUSE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHPLACE      :=  WSAdvValue( oResponse,"_PUBLISHPLACE","string",NIL,"Property cPUBLISHPLACE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPUBLISHYEAR       :=  WSAdvValue( oResponse,"_PUBLISHYEAR","integer",NIL,"Property nPUBLISHYEAR as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cREMARK            :=  WSAdvValue( oResponse,"_REMARK","string",NIL,"Property cREMARK as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSITE              :=  WSAdvValue( oResponse,"_SITE","string",NIL,"Property cSITE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSTATE             :=  WSAdvValue( oResponse,"_STATE","string",NIL,"Property cSTATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,"Property cSUBJECT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBTITLE          :=  WSAdvValue( oResponse,"_SUBTITLE","string",NIL,"Property cSUBTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUMMARY           :=  WSAdvValue( oResponse,"_SUMMARY","string",NIL,"Property cSUMMARY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSYNTHESIS         :=  WSAdvValue( oResponse,"_SYNTHESIS","string",NIL,"Property cSYNTHESIS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTITLE             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,"Property cTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSBOOKS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSBOOKS
	WSDATA   oWSAAUTHORS               AS SIGAGAC_ARRAYOFWSDETAILSAUTHORS OPTIONAL
	WSDATA   oWSACOPIES                AS SIGAGAC_ARRAYOFWSDETAILSCOPY OPTIONAL
	WSDATA   cAREA                     AS string
	WSDATA   cCOLECTION                AS string
	WSDATA   cCOUNTRY                  AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cGROUP                    AS string
	WSDATA   lHAVEPHOTO                AS boolean
	WSDATA   cIDIOM                    AS string
	WSDATA   lILLUSTRATED              AS boolean
	WSDATA   cINSTRUCTIONLEVEL         AS string
	WSDATA   cISBN                     AS string
	WSDATA   cORIGINALTITLE            AS string
	WSDATA   nPAGES                    AS integer
	WSDATA   cPUBLISHINGHOUSE          AS string
	WSDATA   cPUBLISHPLACE             AS string
	WSDATA   nPUBLISHYEAR              AS integer
	WSDATA   cREMARK                   AS string
	WSDATA   cSITE                     AS string
	WSDATA   cSTATE                    AS string
	WSDATA   cSUBJECT                  AS string
	WSDATA   cSUBTITLE                 AS string
	WSDATA   cSUMMARY                  AS string
	WSDATA   cSYNTHESIS                AS string
	WSDATA   cTITLE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSBOOKS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSBOOKS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSBOOKS
	Local oClone := SIGAGAC_WSDETAILSBOOKS():NEW()
	oClone:oWSAAUTHORS          := IIF(::oWSAAUTHORS = NIL , NIL , ::oWSAAUTHORS:Clone() )
	oClone:oWSACOPIES           := IIF(::oWSACOPIES = NIL , NIL , ::oWSACOPIES:Clone() )
	oClone:cAREA                := ::cAREA
	oClone:cCOLECTION           := ::cCOLECTION
	oClone:cCOUNTRY             := ::cCOUNTRY
	oClone:cEMAIL               := ::cEMAIL
	oClone:cGROUP               := ::cGROUP
	oClone:lHAVEPHOTO           := ::lHAVEPHOTO
	oClone:cIDIOM               := ::cIDIOM
	oClone:lILLUSTRATED         := ::lILLUSTRATED
	oClone:cINSTRUCTIONLEVEL    := ::cINSTRUCTIONLEVEL
	oClone:cISBN                := ::cISBN
	oClone:cORIGINALTITLE       := ::cORIGINALTITLE
	oClone:nPAGES               := ::nPAGES
	oClone:cPUBLISHINGHOUSE     := ::cPUBLISHINGHOUSE
	oClone:cPUBLISHPLACE        := ::cPUBLISHPLACE
	oClone:nPUBLISHYEAR         := ::nPUBLISHYEAR
	oClone:cREMARK              := ::cREMARK
	oClone:cSITE                := ::cSITE
	oClone:cSTATE               := ::cSTATE
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cSUBTITLE            := ::cSUBTITLE
	oClone:cSUMMARY             := ::cSUMMARY
	oClone:cSYNTHESIS           := ::cSYNTHESIS
	oClone:cTITLE               := ::cTITLE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSBOOKS
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AAUTHORS","ARRAYOFWSDETAILSAUTHORS",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSAAUTHORS := SIGAGAC_ARRAYOFWSDETAILSAUTHORS():New()
		::oWSAAUTHORS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_ACOPIES","ARRAYOFWSDETAILSCOPY",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSACOPIES := SIGAGAC_ARRAYOFWSDETAILSCOPY():New()
		::oWSACOPIES:SoapRecv(oNode2)
	EndIf
	::cAREA              :=  WSAdvValue( oResponse,"_AREA","string",NIL,"Property cAREA as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOLECTION         :=  WSAdvValue( oResponse,"_COLECTION","string",NIL,"Property cCOLECTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOUNTRY           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,"Property cCOUNTRY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,"Property cEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cGROUP             :=  WSAdvValue( oResponse,"_GROUP","string",NIL,"Property cGROUP as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lHAVEPHOTO         :=  WSAdvValue( oResponse,"_HAVEPHOTO","boolean",NIL,"Property lHAVEPHOTO as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cIDIOM             :=  WSAdvValue( oResponse,"_IDIOM","string",NIL,"Property cIDIOM as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lILLUSTRATED       :=  WSAdvValue( oResponse,"_ILLUSTRATED","boolean",NIL,"Property lILLUSTRATED as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cINSTRUCTIONLEVEL  :=  WSAdvValue( oResponse,"_INSTRUCTIONLEVEL","string",NIL,"Property cINSTRUCTIONLEVEL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cISBN              :=  WSAdvValue( oResponse,"_ISBN","string",NIL,"Property cISBN as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cORIGINALTITLE     :=  WSAdvValue( oResponse,"_ORIGINALTITLE","string",NIL,"Property cORIGINALTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPAGES             :=  WSAdvValue( oResponse,"_PAGES","integer",NIL,"Property nPAGES as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cPUBLISHINGHOUSE   :=  WSAdvValue( oResponse,"_PUBLISHINGHOUSE","string",NIL,"Property cPUBLISHINGHOUSE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHPLACE      :=  WSAdvValue( oResponse,"_PUBLISHPLACE","string",NIL,"Property cPUBLISHPLACE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPUBLISHYEAR       :=  WSAdvValue( oResponse,"_PUBLISHYEAR","integer",NIL,"Property nPUBLISHYEAR as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cREMARK            :=  WSAdvValue( oResponse,"_REMARK","string",NIL,"Property cREMARK as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSITE              :=  WSAdvValue( oResponse,"_SITE","string",NIL,"Property cSITE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSTATE             :=  WSAdvValue( oResponse,"_STATE","string",NIL,"Property cSTATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,"Property cSUBJECT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBTITLE          :=  WSAdvValue( oResponse,"_SUBTITLE","string",NIL,"Property cSUBTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUMMARY           :=  WSAdvValue( oResponse,"_SUMMARY","string",NIL,"Property cSUMMARY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSYNTHESIS         :=  WSAdvValue( oResponse,"_SYNTHESIS","string",NIL,"Property cSYNTHESIS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTITLE             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,"Property cTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSPERIODICALS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSPERIODICALS
	WSDATA   oWSACOPIES                AS SIGAGAC_ARRAYOFWSDETAILSCOPY OPTIONAL
	WSDATA   cAREA                     AS string
	WSDATA   cCOLECTION                AS string
	WSDATA   cCOUNTRY                  AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cFOLDER                   AS string
	WSDATA   cGROUP                    AS string
	WSDATA   lHAVEPHOTO                AS boolean
	WSDATA   cIDIOM                    AS string
	WSDATA   cINSTRUCTIONLEVEL         AS string
	WSDATA   cISSN                     AS string
	WSDATA   cNUMBER                   AS string
	WSDATA   cORIGINALTITLE            AS string
	WSDATA   cPERIODICITY              AS string
	WSDATA   cPUBLISHINGHOUSE          AS string
	WSDATA   cPUBLISHPLACE             AS string
	WSDATA   nPUBLISHYEAR              AS integer
	WSDATA   cREMARK                   AS string
	WSDATA   cSITE                     AS string
	WSDATA   cSTATE                    AS string
	WSDATA   cSUBJECT                  AS string
	WSDATA   cSUBTITLE                 AS string
	WSDATA   cSUMMARY                  AS string
	WSDATA   cSYNTHESIS                AS string
	WSDATA   cTITLE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSPERIODICALS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSPERIODICALS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSPERIODICALS
	Local oClone := SIGAGAC_WSDETAILSPERIODICALS():NEW()
	oClone:oWSACOPIES           := IIF(::oWSACOPIES = NIL , NIL , ::oWSACOPIES:Clone() )
	oClone:cAREA                := ::cAREA
	oClone:cCOLECTION           := ::cCOLECTION
	oClone:cCOUNTRY             := ::cCOUNTRY
	oClone:cEMAIL               := ::cEMAIL
	oClone:cFOLDER              := ::cFOLDER
	oClone:cGROUP               := ::cGROUP
	oClone:lHAVEPHOTO           := ::lHAVEPHOTO
	oClone:cIDIOM               := ::cIDIOM
	oClone:cINSTRUCTIONLEVEL    := ::cINSTRUCTIONLEVEL
	oClone:cISSN                := ::cISSN
	oClone:cNUMBER              := ::cNUMBER
	oClone:cORIGINALTITLE       := ::cORIGINALTITLE
	oClone:cPERIODICITY         := ::cPERIODICITY
	oClone:cPUBLISHINGHOUSE     := ::cPUBLISHINGHOUSE
	oClone:cPUBLISHPLACE        := ::cPUBLISHPLACE
	oClone:nPUBLISHYEAR         := ::nPUBLISHYEAR
	oClone:cREMARK              := ::cREMARK
	oClone:cSITE                := ::cSITE
	oClone:cSTATE               := ::cSTATE
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cSUBTITLE            := ::cSUBTITLE
	oClone:cSUMMARY             := ::cSUMMARY
	oClone:cSYNTHESIS           := ::cSYNTHESIS
	oClone:cTITLE               := ::cTITLE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSPERIODICALS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ACOPIES","ARRAYOFWSDETAILSCOPY",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSACOPIES := SIGAGAC_ARRAYOFWSDETAILSCOPY():New()
		::oWSACOPIES:SoapRecv(oNode1)
	EndIf
	::cAREA              :=  WSAdvValue( oResponse,"_AREA","string",NIL,"Property cAREA as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOLECTION         :=  WSAdvValue( oResponse,"_COLECTION","string",NIL,"Property cCOLECTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOUNTRY           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,"Property cCOUNTRY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,"Property cEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cFOLDER            :=  WSAdvValue( oResponse,"_FOLDER","string",NIL,"Property cFOLDER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cGROUP             :=  WSAdvValue( oResponse,"_GROUP","string",NIL,"Property cGROUP as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lHAVEPHOTO         :=  WSAdvValue( oResponse,"_HAVEPHOTO","boolean",NIL,"Property lHAVEPHOTO as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cIDIOM             :=  WSAdvValue( oResponse,"_IDIOM","string",NIL,"Property cIDIOM as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cINSTRUCTIONLEVEL  :=  WSAdvValue( oResponse,"_INSTRUCTIONLEVEL","string",NIL,"Property cINSTRUCTIONLEVEL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cISSN              :=  WSAdvValue( oResponse,"_ISSN","string",NIL,"Property cISSN as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNUMBER            :=  WSAdvValue( oResponse,"_NUMBER","string",NIL,"Property cNUMBER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cORIGINALTITLE     :=  WSAdvValue( oResponse,"_ORIGINALTITLE","string",NIL,"Property cORIGINALTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPERIODICITY       :=  WSAdvValue( oResponse,"_PERIODICITY","string",NIL,"Property cPERIODICITY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHINGHOUSE   :=  WSAdvValue( oResponse,"_PUBLISHINGHOUSE","string",NIL,"Property cPUBLISHINGHOUSE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHPLACE      :=  WSAdvValue( oResponse,"_PUBLISHPLACE","string",NIL,"Property cPUBLISHPLACE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPUBLISHYEAR       :=  WSAdvValue( oResponse,"_PUBLISHYEAR","integer",NIL,"Property nPUBLISHYEAR as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cREMARK            :=  WSAdvValue( oResponse,"_REMARK","string",NIL,"Property cREMARK as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSITE              :=  WSAdvValue( oResponse,"_SITE","string",NIL,"Property cSITE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSTATE             :=  WSAdvValue( oResponse,"_STATE","string",NIL,"Property cSTATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,"Property cSUBJECT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBTITLE          :=  WSAdvValue( oResponse,"_SUBTITLE","string",NIL,"Property cSUBTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUMMARY           :=  WSAdvValue( oResponse,"_SUMMARY","string",NIL,"Property cSUMMARY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSYNTHESIS         :=  WSAdvValue( oResponse,"_SYNTHESIS","string",NIL,"Property cSYNTHESIS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTITLE             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,"Property cTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSTHESIS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSTHESIS
	WSDATA   oWSAAUTHORS               AS SIGAGAC_ARRAYOFWSDETAILSAUTHORS OPTIONAL
	WSDATA   oWSACOPIES                AS SIGAGAC_ARRAYOFWSDETAILSCOPY OPTIONAL
	WSDATA   dACTUALIZATIONDATE        AS date
	WSDATA   cACTUALIZATIONS           AS string
	WSDATA   cAREA                     AS string
	WSDATA   cCOLECTION                AS string
	WSDATA   dCONCESSIONDATE           AS date
	WSDATA   cCOUNTRY                  AS string
	WSDATA   cEMAIL                    AS string
	WSDATA   cGROUP                    AS string
	WSDATA   lHAVEPHOTO                AS boolean
	WSDATA   cIDIOM                    AS string
	WSDATA   cINSTRUCTIONLEVEL         AS string
	WSDATA   cLEADER                   AS string
	WSDATA   cORIGINALTITLE            AS string
	WSDATA   nPAGES                    AS integer
	WSDATA   cPATENTNUMBER             AS string
	WSDATA   dPRIVILEGEDATE            AS date
	WSDATA   cPUBLISHPLACE             AS string
	WSDATA   nPUBLISHYEAR              AS integer
	WSDATA   cREMARK                   AS string
	WSDATA   cSITE                     AS string
	WSDATA   cSTATE                    AS string
	WSDATA   cSUBJECT                  AS string
	WSDATA   cSUBTITLE                 AS string
	WSDATA   cSUMMARY                  AS string
	WSDATA   cSYNTHESIS                AS string
	WSDATA   cTITLE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSTHESIS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSTHESIS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSTHESIS
	Local oClone := SIGAGAC_WSDETAILSTHESIS():NEW()
	oClone:oWSAAUTHORS          := IIF(::oWSAAUTHORS = NIL , NIL , ::oWSAAUTHORS:Clone() )
	oClone:oWSACOPIES           := IIF(::oWSACOPIES = NIL , NIL , ::oWSACOPIES:Clone() )
	oClone:dACTUALIZATIONDATE   := ::dACTUALIZATIONDATE
	oClone:cACTUALIZATIONS      := ::cACTUALIZATIONS
	oClone:cAREA                := ::cAREA
	oClone:cCOLECTION           := ::cCOLECTION
	oClone:dCONCESSIONDATE      := ::dCONCESSIONDATE
	oClone:cCOUNTRY             := ::cCOUNTRY
	oClone:cEMAIL               := ::cEMAIL
	oClone:cGROUP               := ::cGROUP
	oClone:lHAVEPHOTO           := ::lHAVEPHOTO
	oClone:cIDIOM               := ::cIDIOM
	oClone:cINSTRUCTIONLEVEL    := ::cINSTRUCTIONLEVEL
	oClone:cLEADER              := ::cLEADER
	oClone:cORIGINALTITLE       := ::cORIGINALTITLE
	oClone:nPAGES               := ::nPAGES
	oClone:cPATENTNUMBER        := ::cPATENTNUMBER
	oClone:dPRIVILEGEDATE       := ::dPRIVILEGEDATE
	oClone:cPUBLISHPLACE        := ::cPUBLISHPLACE
	oClone:nPUBLISHYEAR         := ::nPUBLISHYEAR
	oClone:cREMARK              := ::cREMARK
	oClone:cSITE                := ::cSITE
	oClone:cSTATE               := ::cSTATE
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cSUBTITLE            := ::cSUBTITLE
	oClone:cSUMMARY             := ::cSUMMARY
	oClone:cSYNTHESIS           := ::cSYNTHESIS
	oClone:cTITLE               := ::cTITLE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSTHESIS
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AAUTHORS","ARRAYOFWSDETAILSAUTHORS",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSAAUTHORS := SIGAGAC_ARRAYOFWSDETAILSAUTHORS():New()
		::oWSAAUTHORS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_ACOPIES","ARRAYOFWSDETAILSCOPY",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSACOPIES := SIGAGAC_ARRAYOFWSDETAILSCOPY():New()
		::oWSACOPIES:SoapRecv(oNode2)
	EndIf
	::dACTUALIZATIONDATE :=  WSAdvValue( oResponse,"_ACTUALIZATIONDATE","date",NIL,"Property dACTUALIZATIONDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
	::cACTUALIZATIONS    :=  WSAdvValue( oResponse,"_ACTUALIZATIONS","string",NIL,"Property cACTUALIZATIONS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cAREA              :=  WSAdvValue( oResponse,"_AREA","string",NIL,"Property cAREA as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCOLECTION         :=  WSAdvValue( oResponse,"_COLECTION","string",NIL,"Property cCOLECTION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::dCONCESSIONDATE    :=  WSAdvValue( oResponse,"_CONCESSIONDATE","date",NIL,"Property dCONCESSIONDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
	::cCOUNTRY           :=  WSAdvValue( oResponse,"_COUNTRY","string",NIL,"Property cCOUNTRY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cEMAIL             :=  WSAdvValue( oResponse,"_EMAIL","string",NIL,"Property cEMAIL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cGROUP             :=  WSAdvValue( oResponse,"_GROUP","string",NIL,"Property cGROUP as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::lHAVEPHOTO         :=  WSAdvValue( oResponse,"_HAVEPHOTO","boolean",NIL,"Property lHAVEPHOTO as s:boolean on SOAP Response not found.",NIL,"L",NIL) 
	::cIDIOM             :=  WSAdvValue( oResponse,"_IDIOM","string",NIL,"Property cIDIOM as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cINSTRUCTIONLEVEL  :=  WSAdvValue( oResponse,"_INSTRUCTIONLEVEL","string",NIL,"Property cINSTRUCTIONLEVEL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cLEADER            :=  WSAdvValue( oResponse,"_LEADER","string",NIL,"Property cLEADER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cORIGINALTITLE     :=  WSAdvValue( oResponse,"_ORIGINALTITLE","string",NIL,"Property cORIGINALTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPAGES             :=  WSAdvValue( oResponse,"_PAGES","integer",NIL,"Property nPAGES as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cPATENTNUMBER      :=  WSAdvValue( oResponse,"_PATENTNUMBER","string",NIL,"Property cPATENTNUMBER as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::dPRIVILEGEDATE     :=  WSAdvValue( oResponse,"_PRIVILEGEDATE","date",NIL,"Property dPRIVILEGEDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
	::cPUBLISHPLACE      :=  WSAdvValue( oResponse,"_PUBLISHPLACE","string",NIL,"Property cPUBLISHPLACE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nPUBLISHYEAR       :=  WSAdvValue( oResponse,"_PUBLISHYEAR","integer",NIL,"Property nPUBLISHYEAR as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cREMARK            :=  WSAdvValue( oResponse,"_REMARK","string",NIL,"Property cREMARK as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSITE              :=  WSAdvValue( oResponse,"_SITE","string",NIL,"Property cSITE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSTATE             :=  WSAdvValue( oResponse,"_STATE","string",NIL,"Property cSTATE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,"Property cSUBJECT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBTITLE          :=  WSAdvValue( oResponse,"_SUBTITLE","string",NIL,"Property cSUBTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUMMARY           :=  WSAdvValue( oResponse,"_SUMMARY","string",NIL,"Property cSUMMARY as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSYNTHESIS         :=  WSAdvValue( oResponse,"_SYNTHESIS","string",NIL,"Property cSYNTHESIS as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTITLE             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,"Property cTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSVALUESSEARCH
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSVALUESSEARCH
	WSDATA   oWSAVALUES                AS SIGAGAC_ARRAYOFAVALUESSEARCH OPTIONAL
	WSDATA   cTOPSEARCH                AS string
	WSDATA   cTYPESEARCH               AS string
	WSDATA   cUSERCODE                 AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSVALUESSEARCH
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSVALUESSEARCH
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSVALUESSEARCH
	Local oClone := SIGAGAC_WSVALUESSEARCH():NEW()
	oClone:oWSAVALUES           := IIF(::oWSAVALUES = NIL , NIL , ::oWSAVALUES:Clone() )
	oClone:cTOPSEARCH           := ::cTOPSEARCH
	oClone:cTYPESEARCH          := ::cTYPESEARCH
	oClone:cUSERCODE            := ::cUSERCODE
Return oClone

WSMETHOD SOAPSEND WSCLIENT SIGAGAC_WSVALUESSEARCH
	Local cSoap := ""
	cSoap += WSSoapValue("AVALUES", ::oWSAVALUES, ::oWSAVALUES , "ARRAYOFAVALUESSEARCH", .F. , .F., 0 ) 
	cSoap += WSSoapValue("TOPSEARCH", ::cTOPSEARCH, ::cTOPSEARCH , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("TYPESEARCH", ::cTYPESEARCH, ::cTYPESEARCH , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("USERCODE", ::cUSERCODE, ::cUSERCODE , "string", .T. , .F., 0 ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSPUBLICATIONS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSPUBLICATIONS
	WSDATA   oWSWSPUBLICATIONS         AS SIGAGAC_WSPUBLICATIONS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSPUBLICATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSPUBLICATIONS
	::oWSWSPUBLICATIONS    := {} // Array Of  SIGAGAC_WSPUBLICATIONS():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSPUBLICATIONS
	Local oClone := SIGAGAC_ARRAYOFWSPUBLICATIONS():NEW()
	oClone:oWSWSPUBLICATIONS := NIL
	If ::oWSWSPUBLICATIONS <> NIL 
		oClone:oWSWSPUBLICATIONS := {}
		aEval( ::oWSWSPUBLICATIONS , { |x| aadd( oClone:oWSWSPUBLICATIONS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSPUBLICATIONS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSPUBLICATIONS","WSPUBLICATIONS",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSPUBLICATIONS , SIGAGAC_WSPUBLICATIONS():New() )
			::oWSWSPUBLICATIONS[len(::oWSWSPUBLICATIONS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSSUBJECTS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSSUBJECTS
	WSDATA   oWSWSSUBJECTS             AS SIGAGAC_WSSUBJECTS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSSUBJECTS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSSUBJECTS
	::oWSWSSUBJECTS        := {} // Array Of  SIGAGAC_WSSUBJECTS():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSSUBJECTS
	Local oClone := SIGAGAC_ARRAYOFWSSUBJECTS():NEW()
	oClone:oWSWSSUBJECTS := NIL
	If ::oWSWSSUBJECTS <> NIL 
		oClone:oWSWSSUBJECTS := {}
		aEval( ::oWSWSSUBJECTS , { |x| aadd( oClone:oWSWSSUBJECTS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSSUBJECTS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSSUBJECTS","WSSUBJECTS",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSSUBJECTS , SIGAGAC_WSSUBJECTS():New() )
			::oWSWSSUBJECTS[len(::oWSWSSUBJECTS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSOKRESERVED
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSOKRESERVED
	WSDATA   cCOPYID                   AS string
	WSDATA   dLIMITDATE                AS date
	WSDATA   cNAMEPUBLIC               AS string
	WSDATA   cPUBLICATIONID            AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSOKRESERVED
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSOKRESERVED
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSOKRESERVED
	Local oClone := SIGAGAC_WSOKRESERVED():NEW()
	oClone:cCOPYID              := ::cCOPYID
	oClone:dLIMITDATE           := ::dLIMITDATE
	oClone:cNAMEPUBLIC          := ::cNAMEPUBLIC
	oClone:cPUBLICATIONID       := ::cPUBLICATIONID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSOKRESERVED
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCOPYID            :=  WSAdvValue( oResponse,"_COPYID","string",NIL,"Property cCOPYID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::dLIMITDATE         :=  WSAdvValue( oResponse,"_LIMITDATE","date",NIL,"Property dLIMITDATE as s:date on SOAP Response not found.",NIL,"D",NIL) 
	::cNAMEPUBLIC        :=  WSAdvValue( oResponse,"_NAMEPUBLIC","string",NIL,"Property cNAMEPUBLIC as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLICATIONID     :=  WSAdvValue( oResponse,"_PUBLICATIONID","string",NIL,"Property cPUBLICATIONID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSCPPESQ
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSCPPESQ
	WSDATA   oWSWSCPPESQ               AS SIGAGAC_WSCPPESQ OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSCPPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSCPPESQ
	::oWSWSCPPESQ          := {} // Array Of  SIGAGAC_WSCPPESQ():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSCPPESQ
	Local oClone := SIGAGAC_ARRAYOFWSCPPESQ():NEW()
	oClone:oWSWSCPPESQ := NIL
	If ::oWSWSCPPESQ <> NIL 
		oClone:oWSWSCPPESQ := {}
		aEval( ::oWSWSCPPESQ , { |x| aadd( oClone:oWSWSCPPESQ , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSCPPESQ
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSCPPESQ","WSCPPESQ",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSCPPESQ , SIGAGAC_WSCPPESQ():New() )
			::oWSWSCPPESQ[len(::oWSWSCPPESQ)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSTPPUBL
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSTPPUBL
	WSDATA   oWSWSTPPUBL               AS SIGAGAC_WSTPPUBL OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSTPPUBL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSTPPUBL
	::oWSWSTPPUBL          := {} // Array Of  SIGAGAC_WSTPPUBL():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSTPPUBL
	Local oClone := SIGAGAC_ARRAYOFWSTPPUBL():NEW()
	oClone:oWSWSTPPUBL := NIL
	If ::oWSWSTPPUBL <> NIL 
		oClone:oWSWSTPPUBL := {}
		aEval( ::oWSWSTPPUBL , { |x| aadd( oClone:oWSWSTPPUBL , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSTPPUBL
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSTPPUBL","WSTPPUBL",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSTPPUBL , SIGAGAC_WSTPPUBL():New() )
			::oWSWSTPPUBL[len(::oWSWSTPPUBL)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSDETAILSAUTHORS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSDETAILSAUTHORS
	WSDATA   oWSWSDETAILSAUTHORS       AS SIGAGAC_WSDETAILSAUTHORS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSDETAILSAUTHORS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSDETAILSAUTHORS
	::oWSWSDETAILSAUTHORS  := {} // Array Of  SIGAGAC_WSDETAILSAUTHORS():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSDETAILSAUTHORS
	Local oClone := SIGAGAC_ARRAYOFWSDETAILSAUTHORS():NEW()
	oClone:oWSWSDETAILSAUTHORS := NIL
	If ::oWSWSDETAILSAUTHORS <> NIL 
		oClone:oWSWSDETAILSAUTHORS := {}
		aEval( ::oWSWSDETAILSAUTHORS , { |x| aadd( oClone:oWSWSDETAILSAUTHORS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSDETAILSAUTHORS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSDETAILSAUTHORS","WSDETAILSAUTHORS",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSDETAILSAUTHORS , SIGAGAC_WSDETAILSAUTHORS():New() )
			::oWSWSDETAILSAUTHORS[len(::oWSWSDETAILSAUTHORS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSDETAILSCOPY
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSDETAILSCOPY
	WSDATA   oWSWSDETAILSCOPY          AS SIGAGAC_WSDETAILSCOPY OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSDETAILSCOPY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSDETAILSCOPY
	::oWSWSDETAILSCOPY     := {} // Array Of  SIGAGAC_WSDETAILSCOPY():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSDETAILSCOPY
	Local oClone := SIGAGAC_ARRAYOFWSDETAILSCOPY():NEW()
	oClone:oWSWSDETAILSCOPY := NIL
	If ::oWSWSDETAILSCOPY <> NIL 
		oClone:oWSWSDETAILSCOPY := {}
		aEval( ::oWSWSDETAILSCOPY , { |x| aadd( oClone:oWSWSDETAILSCOPY , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSDETAILSCOPY
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSDETAILSCOPY","WSDETAILSCOPY",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSDETAILSCOPY , SIGAGAC_WSDETAILSCOPY():New() )
			::oWSWSDETAILSCOPY[len(::oWSWSDETAILSCOPY)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFAVALUESSEARCH
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFAVALUESSEARCH
	WSDATA   oWSAVALUESSEARCH          AS SIGAGAC_AVALUESSEARCH OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFAVALUESSEARCH
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFAVALUESSEARCH
	::oWSAVALUESSEARCH     := {} // Array Of  SIGAGAC_AVALUESSEARCH():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFAVALUESSEARCH
	Local oClone := SIGAGAC_ARRAYOFAVALUESSEARCH():NEW()
	oClone:oWSAVALUESSEARCH := NIL
	If ::oWSAVALUESSEARCH <> NIL 
		oClone:oWSAVALUESSEARCH := {}
		aEval( ::oWSAVALUESSEARCH , { |x| aadd( oClone:oWSAVALUESSEARCH , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT SIGAGAC_ARRAYOFAVALUESSEARCH
	Local cSoap := ""
	aEval( ::oWSAVALUESSEARCH , {|x| cSoap := cSoap  +  WSSoapValue("AVALUESSEARCH", x , x , "AVALUESSEARCH", .F. , .F., 0 )  } ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure WSPUBLICATIONS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSPUBLICATIONS
	WSDATA   oWSAAUTHORS               AS SIGAGAC_ARRAYOFWSDETAILSAUTHORS OPTIONAL
	WSDATA   oWSALOCALIZATIONS         AS SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS OPTIONAL
	WSDATA   nAVAILABILITY             AS integer
	WSDATA   cPLACEPREFERED            AS string OPTIONAL
	WSDATA   cPUBLICATIONID            AS string
	WSDATA   cPUBLISHINGHOUSE          AS string
	WSDATA   cTITLE                    AS string
	WSDATA   cTYPEPUBLICATION          AS string OPTIONAL
	WSDATA   cTYPESEARCH               AS string OPTIONAL
	WSDATA   cYEARPUBLICATION          AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSPUBLICATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSPUBLICATIONS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSPUBLICATIONS
	Local oClone := SIGAGAC_WSPUBLICATIONS():NEW()
	oClone:oWSAAUTHORS          := IIF(::oWSAAUTHORS = NIL , NIL , ::oWSAAUTHORS:Clone() )
	oClone:oWSALOCALIZATIONS    := IIF(::oWSALOCALIZATIONS = NIL , NIL , ::oWSALOCALIZATIONS:Clone() )
	oClone:nAVAILABILITY        := ::nAVAILABILITY
	oClone:cPLACEPREFERED       := ::cPLACEPREFERED
	oClone:cPUBLICATIONID       := ::cPUBLICATIONID
	oClone:cPUBLISHINGHOUSE     := ::cPUBLISHINGHOUSE
	oClone:cTITLE               := ::cTITLE
	oClone:cTYPEPUBLICATION     := ::cTYPEPUBLICATION
	oClone:cTYPESEARCH          := ::cTYPESEARCH
	oClone:cYEARPUBLICATION     := ::cYEARPUBLICATION
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSPUBLICATIONS
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_AAUTHORS","ARRAYOFWSDETAILSAUTHORS",NIL,NIL,NIL,"O",NIL) 
	If oNode1 != NIL
		::oWSAAUTHORS := SIGAGAC_ARRAYOFWSDETAILSAUTHORS():New()
		::oWSAAUTHORS:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_ALOCALIZATIONS","ARRAYOFWSDETAILSLOCALIZATIONS",NIL,NIL,NIL,"O",NIL) 
	If oNode2 != NIL
		::oWSALOCALIZATIONS := SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS():New()
		::oWSALOCALIZATIONS:SoapRecv(oNode2)
	EndIf
	::nAVAILABILITY      :=  WSAdvValue( oResponse,"_AVAILABILITY","integer",NIL,"Property nAVAILABILITY as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cPLACEPREFERED     :=  WSAdvValue( oResponse,"_PLACEPREFERED","string",NIL,NIL,NIL,"S",NIL) 
	::cPUBLICATIONID     :=  WSAdvValue( oResponse,"_PUBLICATIONID","string",NIL,"Property cPUBLICATIONID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cPUBLISHINGHOUSE   :=  WSAdvValue( oResponse,"_PUBLISHINGHOUSE","string",NIL,"Property cPUBLISHINGHOUSE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTITLE             :=  WSAdvValue( oResponse,"_TITLE","string",NIL,"Property cTITLE as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPEPUBLICATION   :=  WSAdvValue( oResponse,"_TYPEPUBLICATION","string",NIL,NIL,NIL,"S",NIL) 
	::cTYPESEARCH        :=  WSAdvValue( oResponse,"_TYPESEARCH","string",NIL,NIL,NIL,"S",NIL) 
	::cYEARPUBLICATION   :=  WSAdvValue( oResponse,"_YEARPUBLICATION","string",NIL,NIL,NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSSUBJECTS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSSUBJECTS
	WSDATA   cCLASSIFICATION           AS string
	WSDATA   cSUBJECT                  AS string
	WSDATA   cSUBJECTID                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSSUBJECTS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSSUBJECTS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSSUBJECTS
	Local oClone := SIGAGAC_WSSUBJECTS():NEW()
	oClone:cCLASSIFICATION      := ::cCLASSIFICATION
	oClone:cSUBJECT             := ::cSUBJECT
	oClone:cSUBJECTID           := ::cSUBJECTID
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSSUBJECTS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCLASSIFICATION    :=  WSAdvValue( oResponse,"_CLASSIFICATION","string",NIL,"Property cCLASSIFICATION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECT           :=  WSAdvValue( oResponse,"_SUBJECT","string",NIL,"Property cSUBJECT as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cSUBJECTID         :=  WSAdvValue( oResponse,"_SUBJECTID","string",NIL,"Property cSUBJECTID as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSCPPESQ
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSCPPESQ
	WSDATA   cCCPPESQ                  AS string
	WSDATA   cCLBPESQ                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSCPPESQ
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSCPPESQ
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSCPPESQ
	Local oClone := SIGAGAC_WSCPPESQ():NEW()
	oClone:cCCPPESQ             := ::cCCPPESQ
	oClone:cCLBPESQ             := ::cCLBPESQ
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSCPPESQ
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCCPPESQ           :=  WSAdvValue( oResponse,"_CCPPESQ","string",NIL,"Property cCCPPESQ as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCLBPESQ           :=  WSAdvValue( oResponse,"_CLBPESQ","string",NIL,"Property cCLBPESQ as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSTPPUBL
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSTPPUBL
	WSDATA   cCLBPUBL                  AS string
	WSDATA   cCTPPUBL                  AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSTPPUBL
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSTPPUBL
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSTPPUBL
	Local oClone := SIGAGAC_WSTPPUBL():NEW()
	oClone:cCLBPUBL             := ::cCLBPUBL
	oClone:cCTPPUBL             := ::cCTPPUBL
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSTPPUBL
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCLBPUBL           :=  WSAdvValue( oResponse,"_CLBPUBL","string",NIL,"Property cCLBPUBL as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cCTPPUBL           :=  WSAdvValue( oResponse,"_CTPPUBL","string",NIL,"Property cCTPPUBL as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSAUTHORS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSAUTHORS
	WSDATA   cNAME                     AS string
	WSDATA   cTYPE                     AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSAUTHORS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSAUTHORS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSAUTHORS
	Local oClone := SIGAGAC_WSDETAILSAUTHORS():NEW()
	oClone:cNAME                := ::cNAME
	oClone:cTYPE                := ::cTYPE
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSAUTHORS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cNAME              :=  WSAdvValue( oResponse,"_NAME","string",NIL,"Property cNAME as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cTYPE              :=  WSAdvValue( oResponse,"_TYPE","string",NIL,"Property cTYPE as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSCOPY
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSCOPY
	WSDATA   cARCHIVES                 AS string
	WSDATA   nAVAILABLE                AS integer
	WSDATA   cCOPYID                   AS string
	WSDATA   cDATALIB                  AS string OPTIONAL
	WSDATA   cEDITION                  AS string
	WSDATA   cNOTEID                   AS string
	WSDATA   cVOLUME                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSCOPY
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSCOPY
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSCOPY
	Local oClone := SIGAGAC_WSDETAILSCOPY():NEW()
	oClone:cARCHIVES            := ::cARCHIVES
	oClone:nAVAILABLE           := ::nAVAILABLE
	oClone:cCOPYID              := ::cCOPYID
	oClone:cDATALIB             := ::cDATALIB
	oClone:cEDITION             := ::cEDITION
	oClone:cNOTEID              := ::cNOTEID
	oClone:cVOLUME              := ::cVOLUME
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSCOPY
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cARCHIVES          :=  WSAdvValue( oResponse,"_ARCHIVES","string",NIL,"Property cARCHIVES as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::nAVAILABLE         :=  WSAdvValue( oResponse,"_AVAILABLE","integer",NIL,"Property nAVAILABLE as s:integer on SOAP Response not found.",NIL,"N",NIL) 
	::cCOPYID            :=  WSAdvValue( oResponse,"_COPYID","string",NIL,"Property cCOPYID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cDATALIB           :=  WSAdvValue( oResponse,"_DATALIB","string",NIL,NIL,NIL,"S",NIL) 
	::cEDITION           :=  WSAdvValue( oResponse,"_EDITION","string",NIL,"Property cEDITION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cNOTEID            :=  WSAdvValue( oResponse,"_NOTEID","string",NIL,"Property cNOTEID as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cVOLUME            :=  WSAdvValue( oResponse,"_VOLUME","string",NIL,"Property cVOLUME as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure AVALUESSEARCH
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_AVALUESSEARCH
	WSDATA   cFIELD                    AS string
	WSDATA   lSEARCHEXAC               AS boolean
	WSDATA   cVALUE                    AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_AVALUESSEARCH
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_AVALUESSEARCH
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_AVALUESSEARCH
	Local oClone := SIGAGAC_AVALUESSEARCH():NEW()
	oClone:cFIELD               := ::cFIELD
	oClone:lSEARCHEXAC          := ::lSEARCHEXAC
	oClone:cVALUE               := ::cVALUE
Return oClone

WSMETHOD SOAPSEND WSCLIENT SIGAGAC_AVALUESSEARCH
	Local cSoap := ""
	cSoap += WSSoapValue("FIELD", ::cFIELD, ::cFIELD , "string", .T. , .F., 0 ) 
	cSoap += WSSoapValue("SEARCHEXAC", ::lSEARCHEXAC, ::lSEARCHEXAC , "boolean", .T. , .F., 0 ) 
	cSoap += WSSoapValue("VALUE", ::cVALUE, ::cVALUE , "string", .T. , .F., 0 ) 
Return cSoap

/* -------------------------------------------------------------------------------
WSDL Data Structure ARRAYOFWSDETAILSLOCALIZATIONS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS
	WSDATA   oWSWSDETAILSLOCALIZATIONS AS SIGAGAC_WSDETAILSLOCALIZATIONS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS
	::oWSWSDETAILSLOCALIZATIONS := {} // Array Of  SIGAGAC_WSDETAILSLOCALIZATIONS():New()
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS
	Local oClone := SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS():NEW()
	oClone:oWSWSDETAILSLOCALIZATIONS := NIL
	If ::oWSWSDETAILSLOCALIZATIONS <> NIL 
		oClone:oWSWSDETAILSLOCALIZATIONS := {}
		aEval( ::oWSWSDETAILSLOCALIZATIONS , { |x| aadd( oClone:oWSWSDETAILSLOCALIZATIONS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_ARRAYOFWSDETAILSLOCALIZATIONS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_WSDETAILSLOCALIZATIONS","WSDETAILSLOCALIZATIONS",{},NIL,.T.,"O",NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSWSDETAILSLOCALIZATIONS , SIGAGAC_WSDETAILSLOCALIZATIONS():New() )
			::oWSWSDETAILSLOCALIZATIONS[len(::oWSWSDETAILSLOCALIZATIONS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

/* -------------------------------------------------------------------------------
WSDL Data Structure WSDETAILSLOCALIZATIONS
------------------------------------------------------------------------------- */

WSSTRUCT SIGAGAC_WSDETAILSLOCALIZATIONS
	WSDATA   cIDLOCALIZATION           AS string
	WSDATA   cLOCALIZATION             AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT SIGAGAC_WSDETAILSLOCALIZATIONS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT SIGAGAC_WSDETAILSLOCALIZATIONS
Return

WSMETHOD CLONE WSCLIENT SIGAGAC_WSDETAILSLOCALIZATIONS
	Local oClone := SIGAGAC_WSDETAILSLOCALIZATIONS():NEW()
	oClone:cIDLOCALIZATION      := ::cIDLOCALIZATION
	oClone:cLOCALIZATION        := ::cLOCALIZATION
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT SIGAGAC_WSDETAILSLOCALIZATIONS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cIDLOCALIZATION    :=  WSAdvValue( oResponse,"_IDLOCALIZATION","string",NIL,"Property cIDLOCALIZATION as s:string on SOAP Response not found.",NIL,"S",NIL) 
	::cLOCALIZATION      :=  WSAdvValue( oResponse,"_LOCALIZATION","string",NIL,"Property cLOCALIZATION as s:string on SOAP Response not found.",NIL,"S",NIL) 
Return


