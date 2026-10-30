#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/ServidorConteudoWS?wsdl
Gerado em        07/05/11 17:50:46
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QEQKRPZ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSServidorConteudoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSServidorConteudoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertServidorConteudo
	WSMETHOD deleteServidorConteudo

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSServidorConteudo       AS ServidorConteudoWSService_ServidorConteudoWSHolder
	WSDATA   creturn                   AS string
	WSDATA   ccodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSServidorConteudoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSServidorConteudoWSService
	::oWSServidorConteudo := ServidorConteudoWSService_SERVIDORCONTEUDOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSServidorConteudoWSService
	::oWSServidorConteudo := NIL 
	::creturn            := NIL 
	::ccodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSServidorConteudoWSService
Local oClone := WSServidorConteudoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSServidorConteudo :=  IIF(::oWSServidorConteudo = NIL , NIL ,::oWSServidorConteudo:Clone() )
	oClone:creturn       := ::creturn
	oClone:ccodigo       := ::ccodigo
Return oClone

// WSDL Method insertServidorConteudo of Service WSServidorConteudoWSService

WSMETHOD insertServidorConteudo WSSEND oWSServidorConteudo WSRECEIVE creturn WSCLIENT WSServidorConteudoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertServidorConteudo xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("ServidorConteudo", ::oWSServidorConteudo, oWSServidorConteudo , "ServidorConteudoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertServidorConteudo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/ServidorConteudoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTSERVIDORCONTEUDORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteServidorConteudo of Service WSServidorConteudoWSService

WSMETHOD deleteServidorConteudo WSSEND ccodigo WSRECEIVE creturn WSCLIENT WSServidorConteudoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteServidorConteudo xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteServidorConteudo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/ServidorConteudoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETESERVIDORCONTEUDORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ServidorConteudoWSHolder

WSSTRUCT ServidorConteudoWSService_ServidorConteudoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cServidorPreTeste         AS string OPTIONAL
	WSDATA   cServidorPosTeste         AS string OPTIONAL
	WSDATA   cServidorGravacao         AS string OPTIONAL
	WSDATA   cServidorConteudo         AS string OPTIONAL
	WSDATA   cServidorRts              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT ServidorConteudoWSService_ServidorConteudoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT ServidorConteudoWSService_ServidorConteudoWSHolder
Return

WSMETHOD CLONE WSCLIENT ServidorConteudoWSService_ServidorConteudoWSHolder
	Local oClone := ServidorConteudoWSService_ServidorConteudoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:cServidorPreTeste    := ::cServidorPreTeste
	oClone:cServidorPosTeste    := ::cServidorPosTeste
	oClone:cServidorGravacao    := ::cServidorGravacao
	oClone:cServidorConteudo    := ::cServidorConteudo
	oClone:cServidorRts         := ::cServidorRts
Return oClone

WSMETHOD SOAPSEND WSCLIENT ServidorConteudoWSService_ServidorConteudoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ServidorPreTeste", ::cServidorPreTeste, ::cServidorPreTeste , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ServidorPosTeste", ::cServidorPosTeste, ::cServidorPosTeste , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ServidorGravacao", ::cServidorGravacao, ::cServidorGravacao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ServidorConteudo", ::cServidorConteudo, ::cServidorConteudo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ServidorRts", ::cServidorRts, ::cServidorRts , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


