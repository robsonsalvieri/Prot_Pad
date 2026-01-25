#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/MatriculaWS?wsdl
Gerado em        07/05/11 17:49:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _SFAPZNR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSMatriculaWSService
------------------------------------------------------------------------------- */

WSCLIENT WSMatriculaWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertMatricula
	WSMETHOD deleteMatricula

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSMatricula              AS MatriculaWSService_MatriculaWSHolder
	WSDATA   creturn                   AS string
	WSDATA   cCodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSMatriculaWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.101202A-20110919] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSMatriculaWSService
	::oWSMatricula       := MatriculaWSService_MATRICULAWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSMatriculaWSService
	::oWSMatricula       := NIL 
	::creturn            := NIL 
	::cCodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSMatriculaWSService
Local oClone := WSMatriculaWSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSMatricula  :=  IIF(::oWSMatricula = NIL , NIL ,::oWSMatricula:Clone() )
	oClone:creturn       := ::creturn
	oClone:cCodigo       := ::cCodigo
Return oClone

// WSDL Method insertMatricula of Service WSMatriculaWSService

WSMETHOD insertMatricula WSSEND oWSMatricula WSRECEIVE creturn WSCLIENT WSMatriculaWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertMatricula xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Matricula", ::oWSMatricula, oWSMatricula , "MatriculaWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertMatricula>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://eadhomo.total.local:8380/total/webservice/MatriculaWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTMATRICULARESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteMatricula of Service WSMatriculaWSService

WSMETHOD deleteMatricula WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSMatriculaWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteMatricula xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteMatricula>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://eadhomo.total.local:8380/total/webservice/MatriculaWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEMATRICULARESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure MatriculaWSHolder

WSSTRUCT MatriculaWSService_MatriculaWSHolder
	WSDATA   nSituacao                 AS integer OPTIONAL
	WSDATA   nStatusAprovacao          AS integer OPTIONAL
	WSDATA   cDataMatricula            AS dateTime OPTIONAL
	WSDATA   cDataFim                  AS dateTime OPTIONAL
	WSDATA   cDataInicio               AS dateTime OPTIONAL
	WSDATA   cTipoMatricula            AS string OPTIONAL
	WSDATA   cCdTreinamentoExterno     AS string OPTIONAL
	WSDATA   cCdUsuarioExterno         AS string OPTIONAL
	WSDATA   cCdUnidadeExterno         AS string OPTIONAL
	WSDATA   cCdUnidadePaiExterno      AS string OPTIONAL
	WSDATA   nScorePreTeste            AS decimal OPTIONAL
	WSDATA   nScorePosTeste            AS decimal OPTIONAL
	WSDATA   nScoreAvaliacaoReacao     AS decimal OPTIONAL
	WSDATA   cCodigoPreTeste           AS string OPTIONAL
	WSDATA   cCodigoPosTeste           AS string OPTIONAL
	WSDATA   cCodigoAvaliacaoReacao    AS string OPTIONAL
	WSDATA   cCdExterno                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT MatriculaWSService_MatriculaWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT MatriculaWSService_MatriculaWSHolder
Return

WSMETHOD CLONE WSCLIENT MatriculaWSService_MatriculaWSHolder
	Local oClone := MatriculaWSService_MatriculaWSHolder():NEW()
	oClone:nSituacao            := ::nSituacao
	oClone:nStatusAprovacao     := ::nStatusAprovacao
	oClone:cDataMatricula       := ::cDataMatricula
	oClone:cDataFim             := ::cDataFim
	oClone:cDataInicio          := ::cDataInicio
	oClone:cTipoMatricula       := ::cTipoMatricula
	oClone:cCdTreinamentoExterno := ::cCdTreinamentoExterno
	oClone:cCdUsuarioExterno    := ::cCdUsuarioExterno
	oClone:cCdUnidadeExterno    := ::cCdUnidadeExterno
	oClone:cCdUnidadePaiExterno := ::cCdUnidadePaiExterno
	oClone:nScorePreTeste       := ::nScorePreTeste
	oClone:nScorePosTeste       := ::nScorePosTeste
	oClone:nScoreAvaliacaoReacao := ::nScoreAvaliacaoReacao
	oClone:cCodigoPreTeste      := ::cCodigoPreTeste
	oClone:cCodigoPosTeste      := ::cCodigoPosTeste
	oClone:cCodigoAvaliacaoReacao := ::cCodigoAvaliacaoReacao
	oClone:cCdExterno           := ::cCdExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT MatriculaWSService_MatriculaWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("Situacao", ::nSituacao, ::nSituacao , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("StatusAprovacao", ::nStatusAprovacao, ::nStatusAprovacao , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("DataMatricula", ::cDataMatricula, ::cDataMatricula , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("DataFim", ::cDataFim, ::cDataFim , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("DataInicio", ::cDataInicio, ::cDataInicio , "dateTime", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoMatricula", ::cTipoMatricula, ::cTipoMatricula , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdTreinamentoExterno", ::cCdTreinamentoExterno, ::cCdTreinamentoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUsuarioExterno", ::cCdUsuarioExterno, ::cCdUsuarioExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadeExterno", ::cCdUnidadeExterno, ::cCdUnidadeExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadePaiExterno", ::cCdUnidadePaiExterno, ::cCdUnidadePaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ScorePreTeste", ::nScorePreTeste, ::nScorePreTeste , "decimal", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ScorePosTeste", ::nScorePosTeste, ::nScorePosTeste , "decimal", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ScoreAvaliacaoReacao", ::nScoreAvaliacaoReacao, ::nScoreAvaliacaoReacao , "decimal", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CodigoPreTeste", ::cCodigoPreTeste, ::cCodigoPreTeste , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CodigoPosTeste", ::cCodigoPosTeste, ::cCodigoPosTeste , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CodigoAvaliacaoReacao", ::cCodigoAvaliacaoReacao, ::cCodigoAvaliacaoReacao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap