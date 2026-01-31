#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/TreinamentoWS?wsdl
Gerado em        07/05/11 17:51:26
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _RZOFUXH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSTreinamentoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSTreinamentoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD deleteTreinamento
	WSMETHOD insertTreinamento

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cCodigo                   AS string
	WSDATA   creturn                   AS string
	WSDATA   oWSTreinamento            AS TreinamentoWSService_TreinamentoWSHolder

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSTreinamentoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSTreinamentoWSService
	::oWSTreinamento     := TreinamentoWSService_TREINAMENTOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSTreinamentoWSService
	::cCodigo            := NIL 
	::creturn            := NIL 
	::oWSTreinamento     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSTreinamentoWSService
Local oClone := WSTreinamentoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cCodigo       := ::cCodigo
	oClone:creturn       := ::creturn
	oClone:oWSTreinamento :=  IIF(::oWSTreinamento = NIL , NIL ,::oWSTreinamento:Clone() )
Return oClone

// WSDL Method deleteTreinamento of Service WSTreinamentoWSService

WSMETHOD deleteTreinamento WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSTreinamentoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteTreinamento xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteTreinamento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/TreinamentoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETETREINAMENTORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertTreinamento of Service WSTreinamentoWSService

WSMETHOD insertTreinamento WSSEND oWSTreinamento WSRECEIVE creturn WSCLIENT WSTreinamentoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertTreinamento xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Treinamento", ::oWSTreinamento, oWSTreinamento , "TreinamentoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertTreinamento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/TreinamentoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTTREINAMENTORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure TreinamentoWSHolder

WSSTRUCT TreinamentoWSService_TreinamentoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cSigla                    AS string OPTIONAL
	WSDATA   cTitulo                   AS string OPTIONAL
	WSDATA   nSituacao                 AS integer OPTIONAL
	WSDATA   nPermissao                AS integer OPTIONAL
	WSDATA   cCdAvaliacaoReacaoExterno AS string OPTIONAL
	WSDATA   cCdCertificadoExterno     AS string OPTIONAL
	WSDATA   cCertificacao             AS string OPTIONAL
	WSDATA   cType                     AS string OPTIONAL
	WSDATA   cTexto1                   AS string OPTIONAL
	WSDATA   cTexto2                   AS string OPTIONAL
	WSDATA   cTexto3                   AS string OPTIONAL
	WSDATA   cIdNavegadorScorm         AS string OPTIONAL
	WSDATA   cIdAlterarLessonStatus    AS string OPTIONAL
	WSDATA   cIdTotalTime              AS string OPTIONAL
	WSDATA   cIdLessonStatus           AS string OPTIONAL
	WSDATA   cIdScoreRaw               AS string OPTIONAL
	WSDATA   nScoreAprovacao           AS integer OPTIONAL
	WSDATA   cPeriodo                  AS string OPTIONAL
	WSDATA   nAprovacaoScorm           AS integer OPTIONAL
	WSDATA   nCargaHora                AS integer OPTIONAL
	WSDATA   nCargaMinuto              AS integer OPTIONAL
	WSDATA   cAutor                    AS string OPTIONAL
	WSDATA   cCdAutorExterno           AS string OPTIONAL
	WSDATA   cPreTestePreRequisito     AS string OPTIONAL
	WSDATA   nScoreAprovacaoPre        AS integer OPTIONAL
	WSDATA   cIdFinalizar              AS string OPTIONAL
	WSDATA   oWSListaConteudo          AS TreinamentoWSService_ListaConteudoWSHolder OPTIONAL
	WSDATA   oWSListaUnidade           AS TreinamentoWSService_ListaUnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TreinamentoWSService_TreinamentoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TreinamentoWSService_TreinamentoWSHolder
Return

WSMETHOD CLONE WSCLIENT TreinamentoWSService_TreinamentoWSHolder
	Local oClone := TreinamentoWSService_TreinamentoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cSigla               := ::cSigla
	oClone:cTitulo              := ::cTitulo
	oClone:nSituacao            := ::nSituacao
	oClone:nPermissao           := ::nPermissao
	oClone:cCdAvaliacaoReacaoExterno := ::cCdAvaliacaoReacaoExterno
	oClone:cCdCertificadoExterno := ::cCdCertificadoExterno
	oClone:cCertificacao        := ::cCertificacao
	oClone:cType                := ::cType
	oClone:cTexto1              := ::cTexto1
	oClone:cTexto2              := ::cTexto2
	oClone:cTexto3              := ::cTexto3
	oClone:cIdNavegadorScorm    := ::cIdNavegadorScorm
	oClone:cIdAlterarLessonStatus := ::cIdAlterarLessonStatus
	oClone:cIdTotalTime         := ::cIdTotalTime
	oClone:cIdLessonStatus      := ::cIdLessonStatus
	oClone:cIdScoreRaw          := ::cIdScoreRaw
	oClone:nScoreAprovacao      := ::nScoreAprovacao
	oClone:cPeriodo             := ::cPeriodo
	oClone:nAprovacaoScorm      := ::nAprovacaoScorm
	oClone:nCargaHora           := ::nCargaHora
	oClone:nCargaMinuto         := ::nCargaMinuto
	oClone:cAutor               := ::cAutor
	oClone:cCdAutorExterno      := ::cCdAutorExterno
	oClone:cPreTestePreRequisito := ::cPreTestePreRequisito
	oClone:nScoreAprovacaoPre   := ::nScoreAprovacaoPre
	oClone:cIdFinalizar         := ::cIdFinalizar
	oClone:oWSListaConteudo     := IIF(::oWSListaConteudo = NIL , NIL , ::oWSListaConteudo:Clone() )
	oClone:oWSListaUnidade      := IIF(::oWSListaUnidade = NIL , NIL , ::oWSListaUnidade:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT TreinamentoWSService_TreinamentoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Sigla", ::cSigla, ::cSigla , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Titulo", ::cTitulo, ::cTitulo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Situacao", ::nSituacao, ::nSituacao , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Permissao", ::nPermissao, ::nPermissao , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdAvaliacaoReacaoExterno", ::cCdAvaliacaoReacaoExterno, ::cCdAvaliacaoReacaoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdCertificadoExterno", ::cCdCertificadoExterno, ::cCdCertificadoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Certificacao", ::cCertificacao, ::cCertificacao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Type", ::cType, ::cType , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Texto1", ::cTexto1, ::cTexto1 , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Texto2", ::cTexto2, ::cTexto2 , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Texto3", ::cTexto3, ::cTexto3 , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdNavegadorScorm", ::cIdNavegadorScorm, ::cIdNavegadorScorm , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdAlterarLessonStatus", ::cIdAlterarLessonStatus, ::cIdAlterarLessonStatus , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdTotalTime", ::cIdTotalTime, ::cIdTotalTime , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdLessonStatus", ::cIdLessonStatus, ::cIdLessonStatus , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdScoreRaw", ::cIdScoreRaw, ::cIdScoreRaw , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ScoreAprovacao", ::nScoreAprovacao, ::nScoreAprovacao , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Periodo", ::cPeriodo, ::cPeriodo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("AprovacaoScorm", ::nAprovacaoScorm, ::nAprovacaoScorm , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CargaHora", ::nCargaHora, ::nCargaHora , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CargaMinuto", ::nCargaMinuto, ::nCargaMinuto , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Autor", ::cAutor, ::cAutor , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdAutorExterno", ::cCdAutorExterno, ::cCdAutorExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("PreTestePreRequisito", ::cPreTestePreRequisito, ::cPreTestePreRequisito , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ScoreAprovacaoPre", ::nScoreAprovacaoPre, ::nScoreAprovacaoPre , "integer", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("IdFinalizar", ::cIdFinalizar, ::cIdFinalizar , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaConteudo", ::oWSListaConteudo, ::oWSListaConteudo , "ListaConteudoWSHolder", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaUnidade", ::oWSListaUnidade, ::oWSListaUnidade , "ListaUnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaConteudoWSHolder

WSSTRUCT TreinamentoWSService_ListaConteudoWSHolder
	WSDATA   oWSConteudo               AS TreinamentoWSService_ConteudoWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TreinamentoWSService_ListaConteudoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TreinamentoWSService_ListaConteudoWSHolder
	::oWSConteudo          := {} // Array Of  TreinamentoWSService_CONTEUDOWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT TreinamentoWSService_ListaConteudoWSHolder
	Local oClone := TreinamentoWSService_ListaConteudoWSHolder():NEW()
	oClone:oWSConteudo := NIL
	If ::oWSConteudo <> NIL 
		oClone:oWSConteudo := {}
		aEval( ::oWSConteudo , { |x| aadd( oClone:oWSConteudo , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TreinamentoWSService_ListaConteudoWSHolder
	Local cSoap := ""
	aEval( ::oWSConteudo , {|x| cSoap := cSoap  +  WSSoapValue("Conteudo", x , x , "ConteudoWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure ListaUnidadeWSHolder

WSSTRUCT TreinamentoWSService_ListaUnidadeWSHolder
	WSDATA   oWSUnidade                AS TreinamentoWSService_UnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TreinamentoWSService_ListaUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TreinamentoWSService_ListaUnidadeWSHolder
	::oWSUnidade           := {} // Array Of  TreinamentoWSService_UNIDADEWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT TreinamentoWSService_ListaUnidadeWSHolder
	Local oClone := TreinamentoWSService_ListaUnidadeWSHolder():NEW()
	oClone:oWSUnidade := NIL
	If ::oWSUnidade <> NIL 
		oClone:oWSUnidade := {}
		aEval( ::oWSUnidade , { |x| aadd( oClone:oWSUnidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT TreinamentoWSService_ListaUnidadeWSHolder
	Local cSoap := ""
	aEval( ::oWSUnidade , {|x| cSoap := cSoap  +  WSSoapValue("Unidade", x , x , "UnidadeWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure ConteudoWSHolder

WSSTRUCT TreinamentoWSService_ConteudoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cPosicao                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TreinamentoWSService_ConteudoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TreinamentoWSService_ConteudoWSHolder
Return

WSMETHOD CLONE WSCLIENT TreinamentoWSService_ConteudoWSHolder
	Local oClone := TreinamentoWSService_ConteudoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cPosicao             := ::cPosicao
Return oClone

WSMETHOD SOAPSEND WSCLIENT TreinamentoWSService_ConteudoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Posicao", ::cPosicao, ::cPosicao , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure UnidadeWSHolder

WSSTRUCT TreinamentoWSService_UnidadeWSHolder
	WSDATA   cCdPaiExterno             AS string OPTIONAL
	WSDATA   cCdFilhoExterno           AS string OPTIONAL
	WSDATA   cTipoUnidade              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT TreinamentoWSService_UnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT TreinamentoWSService_UnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT TreinamentoWSService_UnidadeWSHolder
	Local oClone := TreinamentoWSService_UnidadeWSHolder():NEW()
	oClone:cCdPaiExterno        := ::cCdPaiExterno
	oClone:cCdFilhoExterno      := ::cCdFilhoExterno
	oClone:cTipoUnidade         := ::cTipoUnidade
Return oClone

WSMETHOD SOAPSEND WSCLIENT TreinamentoWSService_UnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdPaiExterno", ::cCdPaiExterno, ::cCdPaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdFilhoExterno", ::cCdFilhoExterno, ::cCdFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("TipoUnidade", ::cTipoUnidade, ::cTipoUnidade , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


