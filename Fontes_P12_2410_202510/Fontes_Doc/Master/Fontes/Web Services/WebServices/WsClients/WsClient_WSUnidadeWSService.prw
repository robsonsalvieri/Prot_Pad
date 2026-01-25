#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/UnidadeWS?wsdl
Gerado em        07/05/11 17:58:09
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _LQPQIJK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUnidadeWSService
------------------------------------------------------------------------------- */

WSCLIENT WSUnidadeWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD deleteUnidade
	WSMETHOD insertUnidade

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCodigo                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSUnidade                AS UnidadeWSService_UnidadeWSHolder

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUnidadeWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUnidadeWSService
	::oWSUnidade         := UnidadeWSService_UNIDADEWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSUnidadeWSService
	::cCodigo            := NIL 
	::creturn            := NIL 
	::oWSUnidade         := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUnidadeWSService
Local oClone := WSUnidadeWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cCodigo       := ::cCodigo
	oClone:creturn       := ::creturn
	oClone:oWSUnidade    :=  IIF(::oWSUnidade = NIL , NIL ,::oWSUnidade:Clone() )
Return oClone

// WSDL Method deleteUnidade of Service WSUnidadeWSService

WSMETHOD deleteUnidade WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSUnidadeWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteUnidade xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteUnidade>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/UnidadeWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEUNIDADERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertUnidade of Service WSUnidadeWSService

WSMETHOD insertUnidade WSSEND oWSUnidade WSRECEIVE creturn WSCLIENT WSUnidadeWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertUnidade xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Unidade", ::oWSUnidade, oWSUnidade , "UnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertUnidade>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/UnidadeWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTUNIDADERESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure UnidadeWSHolder

WSSTRUCT UnidadeWSService_UnidadeWSHolder
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cCdFilhoExterno           AS string OPTIONAL
	WSDATA   cCdPaiExterno             AS string OPTIONAL
	WSDATA   nTipoUnidade              AS integer OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UnidadeWSService_UnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UnidadeWSService_UnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT UnidadeWSService_UnidadeWSHolder
	Local oClone := UnidadeWSService_UnidadeWSHolder():NEW()
	oClone:cDescricao           := ::cDescricao
	oClone:cTitulo              := ::cTitulo
	oClone:cCdFilhoExterno      := ::cCdFilhoExterno
	oClone:cCdPaiExterno        := ::cCdPaiExterno
	oClone:nTipoUnidade         := ::nTipoUnidade
Return oClone

WSMETHOD SOAPSEND WSCLIENT UnidadeWSService_UnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Titulo", ::cTitulo, ::cTitulo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdFilhoExterno", ::cCdFilhoExterno, ::cCdFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdPaiExterno", ::cCdPaiExterno, ::cCdPaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoUnidade", ::nTipoUnidade, ::nTipoUnidade , "integer", .F. , .F., 0 , NIL, .T.) 
Return cSoap


