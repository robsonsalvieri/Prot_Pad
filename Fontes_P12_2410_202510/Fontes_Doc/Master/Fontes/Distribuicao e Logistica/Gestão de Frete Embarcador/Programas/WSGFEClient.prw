#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://GetNewPar("MV_WSGFE","")/GetNewPar("MV_WSINST","")/WSGFE.apw?WSDL
Gerado em        02/19/13 10:48:13
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KOSZLSE ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWSGFE
------------------------------------------------------------------------------- */

WSCLIENT WSWSGFE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONTTAB
	WSMETHOD DELDATA
	WSMETHOD GETDATA
	WSMETHOD PUTDATA
	WSMETHOD SETDATA
	WSMETHOD UNDOINT
	WSMETHOD CANCELADOCCARGA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCTABELA                  AS string
	WSDATA   cCDADOS                   AS string
	WSDATA 	 cCGW1FILIAL			   AS string
	WSDATA 	 cCGW1CDTPDC			   AS string
	WSDATA 	 cCGW1EMISDC			   AS string
	WSDATA 	 cCGW1SERDC				   AS string
	WSDATA 	 cCGW1NRDC				   AS string
	WSDATA 	 cCOPER	   				   AS string
	WSDATA   nCONTTABRESULT     	   AS integer
	WSDATA   cDELDATARESULT            AS string
	WSDATA   cCCODINT                  AS string
	WSDATA   cCFIL                     AS string
	WSDATA   cGETDATARESULT            AS string
	WSDATA   cPUTDATARESULT            AS string
	WSDATA   cSETDATARESULT            AS string
	WSDATA   cUNDOINTRESULT            AS string
	WSDATA   cCANCELADOCCARGARESULT    AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWSGFE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWSGFE
Return

WSMETHOD RESET WSCLIENT WSWSGFE
	::cCTABELA           := NIL 
	::cCDADOS            := NIL 
	::cCGW1FILIAL		 := Nil
	::cCGW1CDTPDC		 := Nil
	::cCGW1EMISDC		 := Nil
	::cCGW1SERDC	 	 := Nil
	::cCGW1NRDC			 := Nil
	::cCOPER			 := Nil
	::nCONTTABRESULT     := NIL 
	::cDELDATARESULT     := NIL 
	::cCCODINT           := NIL 
	::cCFIL              := NIL 
	::cGETDATARESULT     := NIL 
	::cPUTDATARESULT     := NIL 
	::cSETDATARESULT     := NIL 
	::cUNDOINTRESULT     := NIL 
	::cCANCELADOCCARGARESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWSGFE
Local oClone := WSWSGFE():New()
	oClone:_URL           := ::_URL 
	oClone:cCTABELA       := ::cCTABELA
	oClone:cCDADOS        := ::cCDADOS
	oClone:cCGW1FILIAL	  := ::cCGW1FILIAL		 
	oClone:cCGW1CDTPDC	  := ::cCGW1CDTPDC		 
	oClone:cCGW1EMISDC	  := ::cCGW1EMISDC		 
	oClone:cCGW1SERDC	  := ::cCGW1SERDC		 	 
	oClone:cCGW1NRDC	  := ::cCGW1NRDC		 
	oClone:cCOPER	      := ::cCOPER			 
	oClone:nCONTTABRESULT := ::nCONTTABRESULT
	oClone:cDELDATARESULT := ::cDELDATARESULT
	oClone:cCCODINT       := ::cCCODINT
	oClone:cCFIL          := ::cCFIL
	oClone:cGETDATARESULT := ::cGETDATARESULT
	oClone:cPUTDATARESULT := ::cPUTDATARESULT
	oClone:cSETDATARESULT := ::cSETDATARESULT
	oClone:cUNDOINTRESULT := ::cUNDOINTRESULT
	oClone:cCANCELADOCCARGARESULT := ::cCANCELADOCCARGARESULT
Return oClone

// WSDL Method CONTTAB of Service WSWSGFE

WSMETHOD CONTTAB WSSEND cCTABELA,cCDADOS WSRECEIVE nCONTTABRESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONTTAB xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDADOS", ::cCDADOS, cCDADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONTTAB>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/CONTTAB",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::nCONTTABRESULT     :=  WSAdvValue( oXmlRet,"_CONTTABRESPONSE:_CONTTABRESULT:TEXT","integer",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method DELDATA of Service WSWSGFE

WSMETHOD DELDATA WSSEND cCTABELA,cCDADOS WSRECEIVE cDELDATARESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<DELDATA xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDADOS", ::cCDADOS, cCDADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</DELDATA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/DELDATA",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::cDELDATARESULT     :=  WSAdvValue( oXmlRet,"_DELDATARESPONSE:_DELDATARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETDATA of Service WSWSGFE

WSMETHOD GETDATA WSSEND cCTABELA,cCCODINT,cCFIL WSRECEIVE cGETDATARESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETDATA xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODINT", ::cCCODINT, cCCODINT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CFIL", ::cCFIL, cCFIL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETDATA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/GETDATA",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::cGETDATARESULT     :=  WSAdvValue( oXmlRet,"_GETDATARESPONSE:_GETDATARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method PUTDATA of Service WSWSGFE

WSMETHOD PUTDATA WSSEND cCTABELA,cCDADOS WSRECEIVE cPUTDATARESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PUTDATA xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDADOS", ::cCDADOS, cCDADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</PUTDATA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/PUTDATA",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::cPUTDATARESULT     :=  WSAdvValue( oXmlRet,"_PUTDATARESPONSE:_PUTDATARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETDATA of Service WSWSGFE

WSMETHOD SETDATA WSSEND cCTABELA,cCCODINT,cCDADOS WSRECEIVE cSETDATARESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETDATA xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODINT", ::cCCODINT, cCCODINT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDADOS", ::cCDADOS, cCDADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETDATA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/SETDATA",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::cSETDATARESULT     :=  WSAdvValue( oXmlRet,"_SETDATARESPONSE:_SETDATARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method UNDOINT of Service WSWSGFE

WSMETHOD UNDOINT WSSEND cCTABELA,cCCODINT,cCDADOS WSRECEIVE cUNDOINTRESULT WSCLIENT WSWSGFE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<UNDOINT xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
cSoap += WSSoapValue("CTABELA", ::cCTABELA, cCTABELA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CCODINT", ::cCCODINT, cCCODINT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CDADOS", ::cCDADOS, cCDADOS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</UNDOINT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://"+GetNewPar("MV_WSGFE","")+"/UNDOINT",; 
	"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
	"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

::Init()
::cUNDOINTRESULT     :=  WSAdvValue( oXmlRet,"_UNDOINTRESPONSE:_UNDOINTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CANCELADOCCARGA of Service WSWSGFE
WSMETHOD CANCELADOCCARGA WSRECEIVE cCGW1FILIAL,cCGW1CDTPDC,cCGW1EMISDC,cCGW1SERDC,cCGW1NRDC,cCOPER WSSEND cCANCELADOCCARGARESULT WSSERVICE WSWSGFE
	Local cSoap := "" , oXmlRet

	BEGIN WSMETHOD
	
	cSoap += '<CANCELADOCCARGA xmlns="http://'+GetNewPar("MV_WSGFE","")+'/">'
	cSoap += WSSoapValue("CGW1FILIAL", ::cCGW1FILIAL, cCGW1FILIAL, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CGW1CDTPDC", ::cCGW1CDTPDC, cCGW1CDTPDC, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CGW1EMISDC", ::cCGW1EMISDC, cCGW1EMISDC, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CGW1SERDC", ::cCGW1SERDC, cCGW1SERDC, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CGW1NRDC", ::cCGW1NRDC, cCGW1NRDC, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("COPER", ::cCOPER, cCOPER, "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += "</CANCELADOCCARGA>"


	oXmlRet := SvcSoapCall(	Self,cSoap,; 
		"http://"+GetNewPar("MV_WSGFE","")+"/CANCELADOCCARGA",; 
		"DOCUMENT","http://"+GetNewPar("MV_WSGFE","")+"/",,"1.031217",; 
		"http://"+GetNewPar("MV_WSGFE","")+"/"+GetNewPar("MV_WSINST","")+"/WSGFE.apw")

	::Init()
	::cCANCELADOCCARGARESULT := WSAdvValue( oXmlRet,"_CANCELADOCCARGARESPONSE:_CANCELADOCCARGARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

	END WSMETHOD

	oXmlRet := NIL
Return .T. 