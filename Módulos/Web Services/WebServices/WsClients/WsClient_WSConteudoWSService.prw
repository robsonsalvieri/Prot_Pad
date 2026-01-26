#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/ConteudoWS?wsdl
Gerado em        07/05/11 17:49:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _KQWLUQY ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSConteudoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSConteudoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD deleteConteudo
	WSMETHOD insertConteudo

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCodigo                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSConteudo               AS ConteudoWSService_ConteudoWSHolder

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSConteudoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSConteudoWSService
	::oWSConteudo        := ConteudoWSService_CONTEUDOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSConteudoWSService
	::cCodigo            := NIL 
	::creturn            := NIL 
	::oWSConteudo        := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSConteudoWSService
Local oClone := WSConteudoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cCodigo       := ::cCodigo
	oClone:creturn       := ::creturn
	oClone:oWSConteudo   :=  IIF(::oWSConteudo = NIL , NIL ,::oWSConteudo:Clone() )
Return oClone

// WSDL Method deleteConteudo of Service WSConteudoWSService

WSMETHOD deleteConteudo WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSConteudoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteConteudo xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteConteudo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/ConteudoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETECONTEUDORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertConteudo of Service WSConteudoWSService

WSMETHOD insertConteudo WSSEND oWSConteudo WSRECEIVE creturn WSCLIENT WSConteudoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertConteudo xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Conteudo", ::oWSConteudo, oWSConteudo , "ConteudoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertConteudo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/ConteudoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTCONTEUDORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ConteudoWSHolder

WSSTRUCT ConteudoWSService_ConteudoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cSigla                    AS string OPTIONAL
	WSDATA   cUrl                      AS string OPTIONAL
	WSDATA   nTipoOAExterno            AS integer OPTIONAL
	WSDATA   cCdIdiomaExterno          AS string OPTIONAL
	WSDATA   cCdContentServerExterno   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ConteudoWSService_ConteudoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ConteudoWSService_ConteudoWSHolder
Return

WSMETHOD CLONE WSCLIENT ConteudoWSService_ConteudoWSHolder
	Local oClone := ConteudoWSService_ConteudoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:cTitulo              := ::cTitulo
	oClone:cSigla               := ::cSigla
	oClone:cUrl                 := ::cUrl
	oClone:nTipoOAExterno       := ::nTipoOAExterno
	oClone:cCdIdiomaExterno     := ::cCdIdiomaExterno
	oClone:cCdContentServerExterno := ::cCdContentServerExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT ConteudoWSService_ConteudoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Titulo", ::cTitulo, ::cTitulo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Sigla", ::cSigla, ::cSigla , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Url", ::cUrl, ::cUrl , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoOAExterno", ::nTipoOAExterno, ::nTipoOAExterno , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdIdiomaExterno", ::cCdIdiomaExterno, ::cCdIdiomaExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdContentServerExterno", ::cCdContentServerExterno, ::cCdContentServerExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


