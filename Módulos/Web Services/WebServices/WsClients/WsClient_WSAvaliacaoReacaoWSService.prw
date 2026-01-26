#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/AvaliacaoReacaoWS?wsdl
Gerado em        07/05/11 17:47:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SRKLXHT ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAvaliacaoReacaoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSAvaliacaoReacaoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD deleteAvaliacaoReacao
	WSMETHOD insertAvaliacaoReacao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCodigo                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSAvaliacaoReacao        AS AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAvaliacaoReacaoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAvaliacaoReacaoWSService
	::oWSAvaliacaoReacao := AvaliacaoReacaoWSService_AVALIACAOREACAOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSAvaliacaoReacaoWSService
	::cCodigo            := NIL 
	::creturn            := NIL 
	::oWSAvaliacaoReacao := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAvaliacaoReacaoWSService
Local oClone := WSAvaliacaoReacaoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cCodigo       := ::cCodigo
	oClone:creturn       := ::creturn
	oClone:oWSAvaliacaoReacao :=  IIF(::oWSAvaliacaoReacao = NIL , NIL ,::oWSAvaliacaoReacao:Clone() )
Return oClone

// WSDL Method deleteAvaliacaoReacao of Service WSAvaliacaoReacaoWSService

WSMETHOD deleteAvaliacaoReacao WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSAvaliacaoReacaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteAvaliacaoReacao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteAvaliacaoReacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/AvaliacaoReacaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEAVALIACAOREACAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertAvaliacaoReacao of Service WSAvaliacaoReacaoWSService

WSMETHOD insertAvaliacaoReacao WSSEND oWSAvaliacaoReacao WSRECEIVE creturn WSCLIENT WSAvaliacaoReacaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertAvaliacaoReacao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("AvaliacaoReacao", ::oWSAvaliacaoReacao, oWSAvaliacaoReacao , "AvaliacaoReacaoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertAvaliacaoReacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/AvaliacaoReacaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTAVALIACAOREACAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AvaliacaoReacaoWSHolder

WSSTRUCT AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cUrl                      AS string OPTIONAL
	WSDATA   cTipoPesquisa             AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   cCdServidorConteudoExterno AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder
Return

WSMETHOD CLONE WSCLIENT AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder
	Local oClone := AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cUrl                 := ::cUrl
	oClone:cTipoPesquisa        := ::cTipoPesquisa
	oClone:cTitulo              := ::cTitulo
	oClone:cCdServidorConteudoExterno := ::cCdServidorConteudoExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoReacaoWSService_AvaliacaoReacaoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Url", ::cUrl, ::cUrl , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoPesquisa", ::cTipoPesquisa, ::cTipoPesquisa , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Titulo", ::cTitulo, ::cTitulo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdServidorConteudoExterno", ::cCdServidorConteudoExterno, ::cCdServidorConteudoExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


