#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/CertificadoWS?wsdl
Gerado em        07/05/11 17:48:41
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SNROASM ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCertificadoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSCertificadoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD deleteCertificado
	WSMETHOD insertCertificado

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCodigo                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSCertificado            AS CertificadoWSService_CertificadoWSHolder

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCertificadoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCertificadoWSService
	::oWSCertificado     := CertificadoWSService_CERTIFICADOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSCertificadoWSService
	::cCodigo            := NIL 
	::creturn            := NIL 
	::oWSCertificado     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCertificadoWSService
Local oClone := WSCertificadoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cCodigo       := ::cCodigo
	oClone:creturn       := ::creturn
	oClone:oWSCertificado :=  IIF(::oWSCertificado = NIL , NIL ,::oWSCertificado:Clone() )
Return oClone

// WSDL Method deleteCertificado of Service WSCertificadoWSService

WSMETHOD deleteCertificado WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSCertificadoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteCertificado xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteCertificado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/CertificadoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETECERTIFICADORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertCertificado of Service WSCertificadoWSService

WSMETHOD insertCertificado WSSEND oWSCertificado WSRECEIVE creturn WSCLIENT WSCertificadoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertCertificado xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Certificado", ::oWSCertificado, oWSCertificado , "CertificadoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertCertificado>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/CertificadoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTCERTIFICADORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure CertificadoWSHolder

WSSTRUCT CertificadoWSService_CertificadoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   oWSListaTextoCertificado  AS CertificadoWSService_ListaTextoCertificadoWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CertificadoWSService_CertificadoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CertificadoWSService_CertificadoWSHolder
Return

WSMETHOD CLONE WSCLIENT CertificadoWSService_CertificadoWSHolder
	Local oClone := CertificadoWSService_CertificadoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:oWSListaTextoCertificado := IIF(::oWSListaTextoCertificado = NIL , NIL , ::oWSListaTextoCertificado:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT CertificadoWSService_CertificadoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaTextoCertificado", ::oWSListaTextoCertificado, ::oWSListaTextoCertificado , "ListaTextoCertificadoWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaTextoCertificadoWSHolder

WSSTRUCT CertificadoWSService_ListaTextoCertificadoWSHolder
	WSDATA   oWSTextoCertificado       AS CertificadoWSService_TextoCertificadoWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CertificadoWSService_ListaTextoCertificadoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CertificadoWSService_ListaTextoCertificadoWSHolder
	::oWSTextoCertificado  := {} // Array Of  CertificadoWSService_TEXTOCERTIFICADOWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT CertificadoWSService_ListaTextoCertificadoWSHolder
	Local oClone := CertificadoWSService_ListaTextoCertificadoWSHolder():NEW()
	oClone:oWSTextoCertificado := NIL
	If ::oWSTextoCertificado <> NIL 
		oClone:oWSTextoCertificado := {}
		aEval( ::oWSTextoCertificado , { |x| aadd( oClone:oWSTextoCertificado , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CertificadoWSService_ListaTextoCertificadoWSHolder
	Local cSoap := ""
	aEval( ::oWSTextoCertificado , {|x| cSoap := cSoap  +  WSSoapValue("TextoCertificado", x , x , "TextoCertificadoWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure TextoCertificadoWSHolder

WSSTRUCT CertificadoWSService_TextoCertificadoWSHolder
	WSDATA   cTexto                    AS string OPTIONAL
	WSDATA   nPosicaoX                 AS integer OPTIONAL
	WSDATA   nPosicaoY                 AS integer OPTIONAL
	WSDATA   cAlinhamentoX             AS string OPTIONAL
	WSDATA   cCdCertificadoExterno     AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CertificadoWSService_TextoCertificadoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CertificadoWSService_TextoCertificadoWSHolder
Return

WSMETHOD CLONE WSCLIENT CertificadoWSService_TextoCertificadoWSHolder
	Local oClone := CertificadoWSService_TextoCertificadoWSHolder():NEW()
	oClone:cTexto               := ::cTexto
	oClone:nPosicaoX            := ::nPosicaoX
	oClone:nPosicaoY            := ::nPosicaoY
	oClone:cAlinhamentoX        := ::cAlinhamentoX
	oClone:cCdCertificadoExterno := ::cCdCertificadoExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT CertificadoWSService_TextoCertificadoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("Texto", ::cTexto, ::cTexto , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("PosicaoX", ::nPosicaoX, ::nPosicaoX , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("PosicaoY", ::nPosicaoY, ::nPosicaoY , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AlinhamentoX", ::cAlinhamentoX, ::cAlinhamentoX , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdCertificadoExterno", ::cCdCertificadoExterno, ::cCdCertificadoExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


