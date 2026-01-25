#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/ams1110/webservice/TopicoWS?wsdl
Gerado em        07/05/11 17:56:05
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KRSUKFJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTopicoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSTopicoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertTopico
	WSMETHOD deleteTopico

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSTopico                 AS TopicoWSService_TopicoWSHolder
	WSDATA   creturn                   AS string
	WSDATA   ccodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTopicoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTopicoWSService
	::oWSTopico          := TopicoWSService_TOPICOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSTopicoWSService
	::oWSTopico          := NIL 
	::creturn            := NIL 
	::ccodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTopicoWSService
Local oClone := WSTopicoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSTopico     :=  IIF(::oWSTopico = NIL , NIL ,::oWSTopico:Clone() )
	oClone:creturn       := ::creturn
	oClone:ccodigo       := ::ccodigo
Return oClone

// WSDL Method insertTopico of Service WSTopicoWSService

WSMETHOD insertTopico WSSEND oWSTopico WSRECEIVE creturn WSCLIENT WSTopicoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertTopico xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Topico", ::oWSTopico, oWSTopico , "TopicoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertTopico>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/TopicoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTTOPICORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteTopico of Service WSTopicoWSService

WSMETHOD deleteTopico WSSEND ccodigo WSRECEIVE creturn WSCLIENT WSTopicoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteTopico xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteTopico>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/TopicoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETETOPICORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TopicoWSHolder

WSSTRUCT TopicoWSService_TopicoWSHolder
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cCdPaiExterno             AS string OPTIONAL
	WSDATA   cCdFilhoExterno           AS string OPTIONAL
	WSDATA   nTipoTopico               AS int OPTIONAL
	WSDATA   oWSListaUnidade           AS TopicoWSService_ListaUnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TopicoWSService_TopicoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TopicoWSService_TopicoWSHolder
Return

WSMETHOD CLONE WSCLIENT TopicoWSService_TopicoWSHolder
	Local oClone := TopicoWSService_TopicoWSHolder():NEW()
	oClone:cTitulo              := ::cTitulo
	oClone:cDescricao           := ::cDescricao
	oClone:cCdPaiExterno        := ::cCdPaiExterno
	oClone:cCdFilhoExterno      := ::cCdFilhoExterno
	oClone:nTipoTopico          := ::nTipoTopico
	oClone:oWSListaUnidade      := IIF(::oWSListaUnidade = NIL , NIL , ::oWSListaUnidade:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TopicoWSService_TopicoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("Titulo", ::cTitulo, ::cTitulo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdPaiExterno", ::cCdPaiExterno, ::cCdPaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdFilhoExterno", ::cCdFilhoExterno, ::cCdFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoTopico", ::nTipoTopico, ::nTipoTopico , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaUnidade", ::oWSListaUnidade, ::oWSListaUnidade , "ListaUnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaUnidadeWSHolder

WSSTRUCT TopicoWSService_ListaUnidadeWSHolder
	WSDATA   oWSUnidade                AS TopicoWSService_UnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TopicoWSService_ListaUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TopicoWSService_ListaUnidadeWSHolder
	::oWSUnidade           := {} // Array Of  TopicoWSService_UNIDADEWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT TopicoWSService_ListaUnidadeWSHolder
	Local oClone := TopicoWSService_ListaUnidadeWSHolder():NEW()
	oClone:oWSUnidade := NIL
	If ::oWSUnidade <> NIL 
		oClone:oWSUnidade := {}
		aEval( ::oWSUnidade , { |x| aadd( oClone:oWSUnidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TopicoWSService_ListaUnidadeWSHolder
	Local cSoap := ""
	aEval( ::oWSUnidade , {|x| cSoap := cSoap  +  WSSoapValue("Unidade", x , x , "UnidadeWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure UnidadeWSHolder

WSSTRUCT TopicoWSService_UnidadeWSHolder
	WSDATA   cCdUnidadePaiExterno      AS string OPTIONAL
	WSDATA   cCdUnidadeFilhoExterno    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TopicoWSService_UnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TopicoWSService_UnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT TopicoWSService_UnidadeWSHolder
	Local oClone := TopicoWSService_UnidadeWSHolder():NEW()
	oClone:cCdUnidadePaiExterno := ::cCdUnidadePaiExterno
	oClone:cCdUnidadeFilhoExterno := ::cCdUnidadeFilhoExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT TopicoWSService_UnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdUnidadePaiExterno", ::cCdUnidadePaiExterno, ::cCdUnidadePaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadeFilhoExterno", ::cCdUnidadeFilhoExterno, ::cCdUnidadeFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


