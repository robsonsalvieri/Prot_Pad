#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://localhost:8080/TSSWSREINF.apw?WSDL
Gerado em        03/16/18 02:55:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KPQLWOU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTSSWSREINF
------------------------------------------------------------------------------- */

WSCLIENT WSTSSWSREINF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONSULTAREVENTOS
	WSMETHOD ENVIAREVENTOS
	WSMETHOD EXPORTAREVENTOS
	WSMETHOD VALIDARSCHEMA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSREINFCONSULTA          AS TSSWSREINF_REINFCONSULTA
	WSDATA   oWSCONSULTAREVENTOSRESULT AS TSSWSREINF_ARRAYOFREINFRETCONSULTA
	WSDATA   oWSREINFENVIO             AS TSSWSREINF_REINFENVIO
	WSDATA   oWSENVIAREVENTOSRESULT    AS TSSWSREINF_ARRAYOFREINFRETENVIO
	WSDATA   oWSREINFEXPORTA           AS TSSWSREINF_REINFEXPORTA
	WSDATA   oWSEXPORTAREVENTOSRESULT  AS TSSWSREINF_ARRAYOFREINFRETEXPORTA
	WSDATA   oWSREINFSCHEMA            AS TSSWSREINF_REINFSCHEMA
	WSDATA   oWSVALIDARSCHEMARESULT    AS TSSWSREINF_REINFRETSCHEMA

	// Estruturas mantidas por compatibilidade - NÃO USAR
/*
	WSDATA   oWSREINFCONSULTA          AS TSSWSREINF_REINFCONSULTA
	WSDATA   oWSREINFENVIO             AS TSSWSREINF_REINFENVIO
	WSDATA   oWSREINFEXPORTA           AS TSSWSREINF_REINFEXPORTA
	WSDATA   oWSREINFSCHEMA            AS TSSWSREINF_REINFSCHEMA
*/
ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTSSWSREINF
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20170624 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTSSWSREINF
	::oWSREINFCONSULTA   := TSSWSREINF_REINFCONSULTA():New()
	::oWSCONSULTAREVENTOSRESULT := TSSWSREINF_ARRAYOFREINFRETCONSULTA():New()
	::oWSREINFENVIO      := TSSWSREINF_REINFENVIO():New()
	::oWSENVIAREVENTOSRESULT := TSSWSREINF_ARRAYOFREINFRETENVIO():New()
	::oWSREINFEXPORTA    := TSSWSREINF_REINFEXPORTA():New()
	::oWSEXPORTAREVENTOSRESULT := TSSWSREINF_ARRAYOFREINFRETEXPORTA():New()
	::oWSREINFSCHEMA     := TSSWSREINF_REINFSCHEMA():New()
	::oWSVALIDARSCHEMARESULT := TSSWSREINF_REINFRETSCHEMA():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSREINFCONSULTA   := ::oWSREINFCONSULTA
	::oWSREINFENVIO      := ::oWSREINFENVIO
	::oWSREINFEXPORTA    := ::oWSREINFEXPORTA
	::oWSREINFSCHEMA     := ::oWSREINFSCHEMA
Return

WSMETHOD RESET WSCLIENT WSTSSWSREINF
	::oWSREINFCONSULTA   := NIL 
	::oWSCONSULTAREVENTOSRESULT := NIL 
	::oWSREINFENVIO      := NIL 
	::oWSENVIAREVENTOSRESULT := NIL 
	::oWSREINFEXPORTA    := NIL 
	::oWSEXPORTAREVENTOSRESULT := NIL 
	::oWSREINFSCHEMA     := NIL 
	::oWSVALIDARSCHEMARESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSREINFCONSULTA   := NIL
	::oWSREINFENVIO      := NIL
	::oWSREINFEXPORTA    := NIL
	::oWSREINFSCHEMA     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTSSWSREINF
Local oClone := WSTSSWSREINF():New()
	oClone:_URL          := ::_URL 
	oClone:oWSREINFCONSULTA :=  IIF(::oWSREINFCONSULTA = NIL , NIL ,::oWSREINFCONSULTA:Clone() )
	oClone:oWSCONSULTAREVENTOSRESULT :=  IIF(::oWSCONSULTAREVENTOSRESULT = NIL , NIL ,::oWSCONSULTAREVENTOSRESULT:Clone() )
	oClone:oWSREINFENVIO :=  IIF(::oWSREINFENVIO = NIL , NIL ,::oWSREINFENVIO:Clone() )
	oClone:oWSENVIAREVENTOSRESULT :=  IIF(::oWSENVIAREVENTOSRESULT = NIL , NIL ,::oWSENVIAREVENTOSRESULT:Clone() )
	oClone:oWSREINFEXPORTA :=  IIF(::oWSREINFEXPORTA = NIL , NIL ,::oWSREINFEXPORTA:Clone() )
	oClone:oWSEXPORTAREVENTOSRESULT :=  IIF(::oWSEXPORTAREVENTOSRESULT = NIL , NIL ,::oWSEXPORTAREVENTOSRESULT:Clone() )
	oClone:oWSREINFSCHEMA :=  IIF(::oWSREINFSCHEMA = NIL , NIL ,::oWSREINFSCHEMA:Clone() )
	oClone:oWSVALIDARSCHEMARESULT :=  IIF(::oWSVALIDARSCHEMARESULT = NIL , NIL ,::oWSVALIDARSCHEMARESULT:Clone() )

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSREINFCONSULTA := oClone:oWSREINFCONSULTA
	oClone:oWSREINFENVIO := oClone:oWSREINFENVIO
	oClone:oWSREINFEXPORTA := oClone:oWSREINFEXPORTA
	oClone:oWSREINFSCHEMA := oClone:oWSREINFSCHEMA
Return oClone

// WSDL Method CONSULTAREVENTOS of Service WSTSSWSREINF

WSMETHOD CONSULTAREVENTOS WSSEND oWSREINFCONSULTA WSRECEIVE oWSCONSULTAREVENTOSRESULT WSCLIENT WSTSSWSREINF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSULTAREVENTOS xmlns="http://webservices.totvs.com.br/tsswsREINF.apw">'
cSoap += WSSoapValue("REINFCONSULTA", ::oWSREINFCONSULTA, oWSREINFCONSULTA , "REINFCONSULTA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CONSULTAREVENTOS>"

oXmlRet := SvcSoapCall(Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/tsswsREINF.apw/CONSULTAREVENTOS",; 
	"DOCUMENT","http://webservices.totvs.com.br/tsswsREINF.apw",,"1.031217",; 
	"http://localhost:8080/TSSWSREINF.apw")

::Init()
::oWSCONSULTAREVENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_CONSULTAREVENTOSRESPONSE:_CONSULTAREVENTOSRESULT","ARRAYOFREINFRETCONSULTA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ENVIAREVENTOS of Service WSTSSWSREINF

WSMETHOD ENVIAREVENTOS WSSEND oWSREINFENVIO WSRECEIVE oWSENVIAREVENTOSRESULT WSCLIENT WSTSSWSREINF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ENVIAREVENTOS xmlns="http://webservices.totvs.com.br/tsswsREINF.apw">'
cSoap += WSSoapValue("REINFENVIO", ::oWSREINFENVIO, oWSREINFENVIO , "REINFENVIO", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ENVIAREVENTOS>"

oXmlRet := SvcSoapCall(Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/tsswsREINF.apw/ENVIAREVENTOS",; 
	"DOCUMENT","http://webservices.totvs.com.br/tsswsREINF.apw",,"1.031217",; 
	"http://localhost:8080/TSSWSREINF.apw")

::Init()
::oWSENVIAREVENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_ENVIAREVENTOSRESPONSE:_ENVIAREVENTOSRESULT","ARRAYOFREINFRETENVIO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EXPORTAREVENTOS of Service WSTSSWSREINF

WSMETHOD EXPORTAREVENTOS WSSEND oWSREINFEXPORTA WSRECEIVE oWSEXPORTAREVENTOSRESULT WSCLIENT WSTSSWSREINF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EXPORTAREVENTOS xmlns="http://webservices.totvs.com.br/tsswsREINF.apw">'
cSoap += WSSoapValue("REINFEXPORTA", ::oWSREINFEXPORTA, oWSREINFEXPORTA , "REINFEXPORTA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EXPORTAREVENTOS>"

oXmlRet := SvcSoapCall(Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/tsswsREINF.apw/EXPORTAREVENTOS",; 
	"DOCUMENT","http://webservices.totvs.com.br/tsswsREINF.apw",,"1.031217",; 
	"http://localhost:8080/TSSWSREINF.apw")

::Init()
::oWSEXPORTAREVENTOSRESULT:SoapRecv( WSAdvValue( oXmlRet,"_EXPORTAREVENTOSRESPONSE:_EXPORTAREVENTOSRESULT","ARRAYOFREINFRETEXPORTA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method VALIDARSCHEMA of Service WSTSSWSREINF

WSMETHOD VALIDARSCHEMA WSSEND oWSREINFSCHEMA WSRECEIVE oWSVALIDARSCHEMARESULT WSCLIENT WSTSSWSREINF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<VALIDARSCHEMA xmlns="http://webservices.totvs.com.br/tsswsREINF.apw">'
cSoap += WSSoapValue("REINFSCHEMA", ::oWSREINFSCHEMA, oWSREINFSCHEMA , "REINFSCHEMA", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</VALIDARSCHEMA>"

oXmlRet := SvcSoapCall(Iif( FindFunction( "ObjSelf" ), ObjSelf(Self), Self ),cSoap,; 
	"http://webservices.totvs.com.br/tsswsREINF.apw/VALIDARSCHEMA",; 
	"DOCUMENT","http://webservices.totvs.com.br/tsswsREINF.apw",,"1.031217",; 
	"http://localhost:8080/TSSWSREINF.apw")

::Init()
::oWSVALIDARSCHEMARESULT:SoapRecv( WSAdvValue( oXmlRet,"_VALIDARSCHEMARESPONSE:_VALIDARSCHEMARESULT","REINFRETSCHEMA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure REINFCONSULTA

WSSTRUCT TSSWSREINF_REINFCONSULTA
	WSDATA   oWSCABEC                  AS TSSWSREINF_REINFCABECCONSULTA
	WSDATA   oWSEVENTOS                AS TSSWSREINF_ARRAYOFREINFID
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFCONSULTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFCONSULTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFCONSULTA
	Local oClone := TSSWSREINF_REINFCONSULTA():NEW()
	oClone:oWSCABEC             := IIF(::oWSCABEC = NIL , NIL , ::oWSCABEC:Clone() )
	oClone:oWSEVENTOS           := IIF(::oWSEVENTOS = NIL , NIL , ::oWSEVENTOS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFCONSULTA
	Local cSoap := ""
	cSoap += WSSoapValue("CABEC", ::oWSCABEC, ::oWSCABEC , "REINFCABECCONSULTA", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EVENTOS", ::oWSEVENTOS, ::oWSEVENTOS , "ARRAYOFREINFID", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFREINFRETCONSULTA

WSSTRUCT TSSWSREINF_ARRAYOFREINFRETCONSULTA
	WSDATA   oWSREINFRETCONSULTA       AS TSSWSREINF_REINFRETCONSULTA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_ARRAYOFREINFRETCONSULTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_ARRAYOFREINFRETCONSULTA
	::oWSREINFRETCONSULTA  := {} // Array Of  TSSWSREINF_REINFRETCONSULTA():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_ARRAYOFREINFRETCONSULTA
	Local oClone := TSSWSREINF_ARRAYOFREINFRETCONSULTA():NEW()
	oClone:oWSREINFRETCONSULTA := NIL
	If ::oWSREINFRETCONSULTA <> NIL 
		oClone:oWSREINFRETCONSULTA := {}
		aEval( ::oWSREINFRETCONSULTA , { |x| aadd( oClone:oWSREINFRETCONSULTA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_ARRAYOFREINFRETCONSULTA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REINFRETCONSULTA","REINFRETCONSULTA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSREINFRETCONSULTA , TSSWSREINF_REINFRETCONSULTA():New() )
			::oWSREINFRETCONSULTA[len(::oWSREINFRETCONSULTA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure REINFENVIO

WSSTRUCT TSSWSREINF_REINFENVIO
	WSDATA   oWSCABEC                  AS TSSWSREINF_REINFCABEC
	WSDATA   oWSEVENTOS                AS TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFENVIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFENVIO
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFENVIO
	Local oClone := TSSWSREINF_REINFENVIO():NEW()
	oClone:oWSCABEC             := IIF(::oWSCABEC = NIL , NIL , ::oWSCABEC:Clone() )
	oClone:oWSEVENTOS           := IIF(::oWSEVENTOS = NIL , NIL , ::oWSEVENTOS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFENVIO
	Local cSoap := ""
	cSoap += WSSoapValue("CABEC", ::oWSCABEC, ::oWSCABEC , "REINFCABEC", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EVENTOS", ::oWSEVENTOS, ::oWSEVENTOS , "ARRAYOFREINFENVIOEVENTO", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFREINFRETENVIO

WSSTRUCT TSSWSREINF_ARRAYOFREINFRETENVIO
	WSDATA   oWSREINFRETENVIO          AS TSSWSREINF_REINFRETENVIO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_ARRAYOFREINFRETENVIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_ARRAYOFREINFRETENVIO
	::oWSREINFRETENVIO     := {} // Array Of  TSSWSREINF_REINFRETENVIO():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_ARRAYOFREINFRETENVIO
	Local oClone := TSSWSREINF_ARRAYOFREINFRETENVIO():NEW()
	oClone:oWSREINFRETENVIO := NIL
	If ::oWSREINFRETENVIO <> NIL 
		oClone:oWSREINFRETENVIO := {}
		aEval( ::oWSREINFRETENVIO , { |x| aadd( oClone:oWSREINFRETENVIO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_ARRAYOFREINFRETENVIO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REINFRETENVIO","REINFRETENVIO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSREINFRETENVIO , TSSWSREINF_REINFRETENVIO():New() )
			::oWSREINFRETENVIO[len(::oWSREINFRETENVIO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure REINFEXPORTA

WSSTRUCT TSSWSREINF_REINFEXPORTA
	WSDATA   oWSCABEC                  AS TSSWSREINF_REINFCABECEXPORTA
	WSDATA   oWSEVENTOS                AS TSSWSREINF_ARRAYOFREINFID
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFEXPORTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFEXPORTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFEXPORTA
	Local oClone := TSSWSREINF_REINFEXPORTA():NEW()
	oClone:oWSCABEC             := IIF(::oWSCABEC = NIL , NIL , ::oWSCABEC:Clone() )
	oClone:oWSEVENTOS           := IIF(::oWSEVENTOS = NIL , NIL , ::oWSEVENTOS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFEXPORTA
	Local cSoap := ""
	cSoap += WSSoapValue("CABEC", ::oWSCABEC, ::oWSCABEC , "REINFCABECEXPORTA", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("EVENTOS", ::oWSEVENTOS, ::oWSEVENTOS , "ARRAYOFREINFID", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFREINFRETEXPORTA

WSSTRUCT TSSWSREINF_ARRAYOFREINFRETEXPORTA
	WSDATA   oWSREINFRETEXPORTA        AS TSSWSREINF_REINFRETEXPORTA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_ARRAYOFREINFRETEXPORTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_ARRAYOFREINFRETEXPORTA
	::oWSREINFRETEXPORTA   := {} // Array Of  TSSWSREINF_REINFRETEXPORTA():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_ARRAYOFREINFRETEXPORTA
	Local oClone := TSSWSREINF_ARRAYOFREINFRETEXPORTA():NEW()
	oClone:oWSREINFRETEXPORTA := NIL
	If ::oWSREINFRETEXPORTA <> NIL 
		oClone:oWSREINFRETEXPORTA := {}
		aEval( ::oWSREINFRETEXPORTA , { |x| aadd( oClone:oWSREINFRETEXPORTA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_ARRAYOFREINFRETEXPORTA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_REINFRETEXPORTA","REINFRETEXPORTA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSREINFRETEXPORTA , TSSWSREINF_REINFRETEXPORTA():New() )
			::oWSREINFRETEXPORTA[len(::oWSREINFRETEXPORTA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure REINFSCHEMA

WSSTRUCT TSSWSREINF_REINFSCHEMA
	WSDATA   cAMBIENTE                 AS string OPTIONAL
	WSDATA   cCODIGO                   AS string
	WSDATA   cENTIDADE                 AS string OPTIONAL
	WSDATA   cID                       AS string OPTIONAL
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cVERSAO                   AS string OPTIONAL
	WSDATA   cXML                      AS base64Binary OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFSCHEMA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFSCHEMA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFSCHEMA
	Local oClone := TSSWSREINF_REINFSCHEMA():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cCODIGO              := ::cCODIGO
	oClone:cENTIDADE            := ::cENTIDADE
	oClone:cID                  := ::cID
	oClone:cUSERTOKEN           := ::cUSERTOKEN
	oClone:cVERSAO              := ::cVERSAO
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFSCHEMA
	Local cSoap := ""
	cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, ::cAMBIENTE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, ::cENTIDADE , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, ::cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VERSAO", ::cVERSAO, ::cVERSAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure REINFRETSCHEMA

WSSTRUCT TSSWSREINF_REINFRETSCHEMA
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cENTIDADE                 AS string
	WSDATA   cERRO                     AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   lSTATUS                   AS boolean
	WSDATA   cVERSAO                   AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFRETSCHEMA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFRETSCHEMA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFRETSCHEMA
	Local oClone := TSSWSREINF_REINFRETSCHEMA():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cENTIDADE            := ::cENTIDADE
	oClone:cERRO                := ::cERRO
	oClone:cID                  := ::cID
	oClone:lSTATUS              := ::lSTATUS
	oClone:cVERSAO              := ::cVERSAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_REINFRETSCHEMA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,"Property cAMBIENTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cENTIDADE          :=  WSAdvValue( oResponse,"_ENTIDADE","string",NIL,"Property cENTIDADE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cERRO              :=  WSAdvValue( oResponse,"_ERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lSTATUS            :=  WSAdvValue( oResponse,"_STATUS","boolean",NIL,"Property lSTATUS as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
	::cVERSAO            :=  WSAdvValue( oResponse,"_VERSAO","string",NIL,"Property cVERSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure REINFCABECCONSULTA

WSSTRUCT TSSWSREINF_REINFCABECCONSULTA
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cENTIDADE                 AS string
	WSDATA   lHISTPROC                 AS boolean OPTIONAL
	WSDATA   lRETORNAXML               AS boolean OPTIONAL
	WSDATA   cUSERTOKEN                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFCABECCONSULTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFCABECCONSULTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFCABECCONSULTA
	Local oClone := TSSWSREINF_REINFCABECCONSULTA():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cENTIDADE            := ::cENTIDADE
	oClone:lHISTPROC            := ::lHISTPROC
	oClone:lRETORNAXML          := ::lRETORNAXML
	oClone:cUSERTOKEN           := ::cUSERTOKEN
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFCABECCONSULTA
	Local cSoap := ""
	cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, ::cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, ::cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("HISTPROC", ::lHISTPROC, ::lHISTPROC , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("RETORNAXML", ::lRETORNAXML, ::lRETORNAXML , "boolean", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, ::cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFREINFID

WSSTRUCT TSSWSREINF_ARRAYOFREINFID
	WSDATA   oWSREINFID                AS TSSWSREINF_REINFID OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_ARRAYOFREINFID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_ARRAYOFREINFID
	::oWSREINFID           := {} // Array Of  TSSWSREINF_REINFID():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_ARRAYOFREINFID
	Local oClone := TSSWSREINF_ARRAYOFREINFID():NEW()
	oClone:oWSREINFID := NIL
	If ::oWSREINFID <> NIL 
		oClone:oWSREINFID := {}
		aEval( ::oWSREINFID , { |x| aadd( oClone:oWSREINFID , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_ARRAYOFREINFID
	Local cSoap := ""
	aEval( ::oWSREINFID , {|x| cSoap := cSoap  +  WSSoapValue("REINFID", x , x , "REINFID", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure REINFRETCONSULTA

WSSTRUCT TSSWSREINF_REINFRETCONSULTA
	WSDATA   cAMBIENTE                 AS string OPTIONAL
	WSDATA   cCHAVE                    AS string
	WSDATA   cCODEVENTO                AS string
	WSDATA   cDETSTATUS                AS string
	WSDATA   dDTENTRADA                AS date
	WSDATA   dDTPROC                   AS date
	WSDATA   dDTTRANS                  AS date
	WSDATA   cHISTPROC                 AS string OPTIONAL
	WSDATA   cHRENTRADA                AS string
	WSDATA   cHRPROC                   AS string
	WSDATA   cHRTRANS                  AS string
	WSDATA   cID                       AS string
	WSDATA   cLOTE                     AS string
	WSDATA   cPROTOCOLO                AS string
	WSDATA   cRECIBO                   AS string
	WSDATA   cSTATUS                   AS string
	WSDATA   cVERSAO                   AS string
	WSDATA   cXMLEVENTO                AS string OPTIONAL
	WSDATA   cXMLRETEVEN               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFRETCONSULTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFRETCONSULTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFRETCONSULTA
	Local oClone := TSSWSREINF_REINFRETCONSULTA():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cCHAVE               := ::cCHAVE
	oClone:cCODEVENTO           := ::cCODEVENTO
	oClone:cDETSTATUS           := ::cDETSTATUS
	oClone:dDTENTRADA           := ::dDTENTRADA
	oClone:dDTPROC              := ::dDTPROC
	oClone:dDTTRANS             := ::dDTTRANS
	oClone:cHISTPROC            := ::cHISTPROC
	oClone:cHRENTRADA           := ::cHRENTRADA
	oClone:cHRPROC              := ::cHRPROC
	oClone:cHRTRANS             := ::cHRTRANS
	oClone:cID                  := ::cID
	oClone:cLOTE                := ::cLOTE
	oClone:cPROTOCOLO           := ::cPROTOCOLO
	oClone:cRECIBO              := ::cRECIBO
	oClone:cSTATUS              := ::cSTATUS
	oClone:cVERSAO              := ::cVERSAO
	oClone:cXMLEVENTO           := ::cXMLEVENTO
	oClone:cXMLRETEVEN          := ::cXMLRETEVEN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_REINFRETCONSULTA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cAMBIENTE          :=  WSAdvValue( oResponse,"_AMBIENTE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCHAVE             :=  WSAdvValue( oResponse,"_CHAVE","string",NIL,"Property cCHAVE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cCODEVENTO         :=  WSAdvValue( oResponse,"_CODEVENTO","string",NIL,"Property cCODEVENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDETSTATUS         :=  WSAdvValue( oResponse,"_DETSTATUS","string",NIL,"Property cDETSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::dDTENTRADA         :=  WSAdvValue( oResponse,"_DTENTRADA","date",NIL,"Property dDTENTRADA as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDTPROC            :=  WSAdvValue( oResponse,"_DTPROC","date",NIL,"Property dDTPROC as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::dDTTRANS           :=  WSAdvValue( oResponse,"_DTTRANS","date",NIL,"Property dDTTRANS as s:date on SOAP Response not found.",NIL,"D",NIL,NIL) 
	::cHISTPROC          :=  WSAdvValue( oResponse,"_HISTPROC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cHRENTRADA         :=  WSAdvValue( oResponse,"_HRENTRADA","string",NIL,"Property cHRENTRADA as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHRPROC            :=  WSAdvValue( oResponse,"_HRPROC","string",NIL,"Property cHRPROC as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cHRTRANS           :=  WSAdvValue( oResponse,"_HRTRANS","string",NIL,"Property cHRTRANS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cLOTE              :=  WSAdvValue( oResponse,"_LOTE","string",NIL,"Property cLOTE as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cPROTOCOLO         :=  WSAdvValue( oResponse,"_PROTOCOLO","string",NIL,"Property cPROTOCOLO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cRECIBO            :=  WSAdvValue( oResponse,"_RECIBO","string",NIL,"Property cRECIBO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cSTATUS            :=  WSAdvValue( oResponse,"_STATUS","string",NIL,"Property cSTATUS as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cVERSAO            :=  WSAdvValue( oResponse,"_VERSAO","string",NIL,"Property cVERSAO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLEVENTO         :=  WSAdvValue( oResponse,"_XMLEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLRETEVEN        :=  WSAdvValue( oResponse,"_XMLRETEVEN","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure REINFCABEC

WSSTRUCT TSSWSREINF_REINFCABEC
	WSDATA   cAMBIENTE                 AS string
	WSDATA   cENTIDADE                 AS string
	WSDATA   cUSERTOKEN                AS string
	WSDATA   cVERSAO                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFCABEC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFCABEC
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFCABEC
	Local oClone := TSSWSREINF_REINFCABEC():NEW()
	oClone:cAMBIENTE            := ::cAMBIENTE
	oClone:cENTIDADE            := ::cENTIDADE
	oClone:cUSERTOKEN           := ::cUSERTOKEN
	oClone:cVERSAO              := ::cVERSAO
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFCABEC
	Local cSoap := ""
	cSoap += WSSoapValue("AMBIENTE", ::cAMBIENTE, ::cAMBIENTE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, ::cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, ::cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("VERSAO", ::cVERSAO, ::cVERSAO , "string", .F. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure ARRAYOFREINFENVIOEVENTO

WSSTRUCT TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	WSDATA   oWSREINFENVIOEVENTO       AS TSSWSREINF_REINFENVIOEVENTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	::oWSREINFENVIOEVENTO  := {} // Array Of  TSSWSREINF_REINFENVIOEVENTO():New()
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	Local oClone := TSSWSREINF_ARRAYOFREINFENVIOEVENTO():NEW()
	oClone:oWSREINFENVIOEVENTO := NIL
	If ::oWSREINFENVIOEVENTO <> NIL 
		oClone:oWSREINFENVIOEVENTO := {}
		aEval( ::oWSREINFENVIOEVENTO , { |x| aadd( oClone:oWSREINFENVIOEVENTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_ARRAYOFREINFENVIOEVENTO
	Local cSoap := ""
	aEval( ::oWSREINFENVIOEVENTO , {|x| cSoap := cSoap  +  WSSoapValue("REINFENVIOEVENTO", x , x , "REINFENVIOEVENTO", .F. , .F., 0 , NIL, .F.,.F.)  } ) 
Return cSoap

// WSDL Data Structure REINFRETENVIO

WSSTRUCT TSSWSREINF_REINFRETENVIO
	WSDATA   cCODIGO                   AS string
	WSDATA   cDESCRICAO                AS string OPTIONAL
	WSDATA   cID                       AS string
	WSDATA   lSUCESSO                  AS boolean
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFRETENVIO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFRETENVIO
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFRETENVIO
	Local oClone := TSSWSREINF_REINFRETENVIO():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cDESCRICAO           := ::cDESCRICAO
	oClone:cID                  := ::cID
	oClone:lSUCESSO             := ::lSUCESSO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_REINFRETENVIO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGO            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,"Property cCODIGO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cDESCRICAO         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::lSUCESSO           :=  WSAdvValue( oResponse,"_SUCESSO","boolean",NIL,"Property lSUCESSO as s:boolean on SOAP Response not found.",NIL,"L",NIL,NIL) 
Return

// WSDL Data Structure REINFCABECEXPORTA

WSSTRUCT TSSWSREINF_REINFCABECEXPORTA
	WSDATA   cENTIDADE                 AS string
	WSDATA   cUSERTOKEN                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFCABECEXPORTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFCABECEXPORTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFCABECEXPORTA
	Local oClone := TSSWSREINF_REINFCABECEXPORTA():NEW()
	oClone:cENTIDADE            := ::cENTIDADE
	oClone:cUSERTOKEN           := ::cUSERTOKEN
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFCABECEXPORTA
	Local cSoap := ""
	cSoap += WSSoapValue("ENTIDADE", ::cENTIDADE, ::cENTIDADE , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("USERTOKEN", ::cUSERTOKEN, ::cUSERTOKEN , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure REINFRETEXPORTA

WSSTRUCT TSSWSREINF_REINFRETEXPORTA
	WSDATA   cCODEVENTO                AS string
	WSDATA   cID                       AS string
	WSDATA   cXMLEVENTO                AS string OPTIONAL
	WSDATA   cXMLRETEVEN               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFRETEXPORTA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFRETEXPORTA
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFRETEXPORTA
	Local oClone := TSSWSREINF_REINFRETEXPORTA():NEW()
	oClone:cCODEVENTO           := ::cCODEVENTO
	oClone:cID                  := ::cID
	oClone:cXMLEVENTO           := ::cXMLEVENTO
	oClone:cXMLRETEVEN          := ::cXMLRETEVEN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT TSSWSREINF_REINFRETEXPORTA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODEVENTO         :=  WSAdvValue( oResponse,"_CODEVENTO","string",NIL,"Property cCODEVENTO as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cID                :=  WSAdvValue( oResponse,"_ID","string",NIL,"Property cID as s:string on SOAP Response not found.",NIL,"S",NIL,NIL) 
	::cXMLEVENTO         :=  WSAdvValue( oResponse,"_XMLEVENTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cXMLRETEVEN        :=  WSAdvValue( oResponse,"_XMLRETEVEN","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure REINFID

WSSTRUCT TSSWSREINF_REINFID
	WSDATA   cID                       AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFID
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFID
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFID
	Local oClone := TSSWSREINF_REINFID():NEW()
	oClone:cID                  := ::cID
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFID
	Local cSoap := ""
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap

// WSDL Data Structure REINFENVIOEVENTO

WSSTRUCT TSSWSREINF_REINFENVIOEVENTO
	WSDATA   cCODIGO                   AS string
	WSDATA   cID                       AS string
	WSDATA   cXML                      AS base64Binary
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TSSWSREINF_REINFENVIOEVENTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TSSWSREINF_REINFENVIOEVENTO
Return

WSMETHOD CLONE WSCLIENT TSSWSREINF_REINFENVIOEVENTO
	Local oClone := TSSWSREINF_REINFENVIOEVENTO():NEW()
	oClone:cCODIGO              := ::cCODIGO
	oClone:cID                  := ::cID
	oClone:cXML                 := ::cXML
Return oClone

WSMETHOD SOAPSEND WSCLIENT TSSWSREINF_REINFENVIOEVENTO
	Local cSoap := ""
	cSoap += WSSoapValue("CODIGO", ::cCODIGO, ::cCODIGO , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ID", ::cID, ::cID , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("XML", ::cXML, ::cXML , "base64Binary", .T. , .F., 0 , NIL, .F.,.F.) 
Return cSoap


