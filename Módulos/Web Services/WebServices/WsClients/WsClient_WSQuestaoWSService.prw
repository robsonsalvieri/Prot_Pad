#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/ams1110/webservice/QuestaoWS?wsdl
Gerado em        07/05/11 17:54:52
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TNVUPTQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSQuestaoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSQuestaoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertQuestao
	WSMETHOD deleteQuestao

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSQuestao                AS QuestaoWSService_QuestaoWSHolder
	WSDATA   creturn                   AS string
	WSDATA   ccodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSQuestaoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSQuestaoWSService
	::oWSQuestao         := QuestaoWSService_QUESTAOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSQuestaoWSService
	::oWSQuestao         := NIL 
	::creturn            := NIL 
	::ccodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSQuestaoWSService
Local oClone := WSQuestaoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSQuestao    :=  IIF(::oWSQuestao = NIL , NIL ,::oWSQuestao:Clone() )
	oClone:creturn       := ::creturn
	oClone:ccodigo       := ::ccodigo
Return oClone

// WSDL Method insertQuestao of Service WSQuestaoWSService

WSMETHOD insertQuestao WSSEND oWSQuestao WSRECEIVE creturn WSCLIENT WSQuestaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertQuestao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Questao", ::oWSQuestao, oWSQuestao , "QuestaoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertQuestao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/QuestaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTQUESTAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteQuestao of Service WSQuestaoWSService

WSMETHOD deleteQuestao WSSEND ccodigo WSRECEIVE creturn WSCLIENT WSQuestaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteQuestao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteQuestao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/QuestaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEQUESTAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure QuestaoWSHolder

WSSTRUCT QuestaoWSService_QuestaoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao		           AS string OPTIONAL
	WSDATA   cPergunta                 AS string OPTIONAL
	WSDATA   cTipo                     AS string OPTIONAL
	WSDATA   lAtivo                    AS boolean OPTIONAL
	WSDATA   nScore                    AS int OPTIONAL
	WSDATA   dDataCriacao              AS date OPTIONAL
	WSDATA   cCdTopicoExterno          AS string OPTIONAL
	WSDATA   oWSListaAlternativa       AS QuestaoWSService_ListaAlternativaWSHolder OPTIONAL
	WSDATA   oWSListaUnidade           AS QuestaoWSService_ListaUnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QuestaoWSService_QuestaoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QuestaoWSService_QuestaoWSHolder
Return

WSMETHOD CLONE WSCLIENT QuestaoWSService_QuestaoWSHolder
	Local oClone := QuestaoWSService_QuestaoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:cPergunta            := ::cPergunta
	oClone:cTipo                := ::cTipo
	oClone:lAtivo               := ::lAtivo
	oClone:nScore               := ::nScore
	oClone:dDataCriacao         := ::dDataCriacao
	oClone:cCdTopicoExterno     := ::cCdTopicoExterno
	oClone:oWSListaAlternativa  := IIF(::oWSListaAlternativa = NIL , NIL , ::oWSListaAlternativa:Clone() )
	oClone:oWSListaUnidade      := IIF(::oWSListaUnidade = NIL , NIL , ::oWSListaUnidade:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT QuestaoWSService_QuestaoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Pergunta", ::cPergunta, ::cPergunta , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Tipo", ::cTipo, ::cTipo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Ativo", ::lAtivo, ::lAtivo , "boolean", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Score", ::nScore, ::nScore , "int", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("DataCriacao", ::dDataCriacao, ::dDataCriacao , "date", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdTopicoExterno", ::cCdTopicoExterno, ::cCdTopicoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaAlternativa", ::oWSListaAlternativa, ::oWSListaAlternativa , "ListaAlternativaWSHolder", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaUnidade", ::oWSListaUnidade, ::oWSListaUnidade , "ListaUnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaAlternativaWSHolder

WSSTRUCT QuestaoWSService_ListaAlternativaWSHolder
	WSDATA   oWSAlternativa            AS QuestaoWSService_AlternativaWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QuestaoWSService_ListaAlternativaWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QuestaoWSService_ListaAlternativaWSHolder
	::oWSAlternativa       := {} // Array Of  QuestaoWSService_ALTERNATIVAWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT QuestaoWSService_ListaAlternativaWSHolder
	Local oClone := QuestaoWSService_ListaAlternativaWSHolder():NEW()
	oClone:oWSAlternativa := NIL
	If ::oWSAlternativa <> NIL 
		oClone:oWSAlternativa := {}
		aEval( ::oWSAlternativa , { |x| aadd( oClone:oWSAlternativa , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT QuestaoWSService_ListaAlternativaWSHolder
	Local cSoap := ""
	aEval( ::oWSAlternativa , {|x| cSoap := cSoap  +  WSSoapValue("Alternativa", x , x , "AlternativaWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure ListaUnidadeWSHolder

WSSTRUCT QuestaoWSService_ListaUnidadeWSHolder
	WSDATA   oWSUnidade                AS QuestaoWSService_UnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QuestaoWSService_ListaUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QuestaoWSService_ListaUnidadeWSHolder
	::oWSUnidade           := {} // Array Of  QuestaoWSService_UNIDADEWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT QuestaoWSService_ListaUnidadeWSHolder
	Local oClone := QuestaoWSService_ListaUnidadeWSHolder():NEW()
	oClone:oWSUnidade := NIL
	If ::oWSUnidade <> NIL 
		oClone:oWSUnidade := {}
		aEval( ::oWSUnidade , { |x| aadd( oClone:oWSUnidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT QuestaoWSService_ListaUnidadeWSHolder
	Local cSoap := ""
	aEval( ::oWSUnidade , {|x| cSoap := cSoap  +  WSSoapValue("Unidade", x , x , "UnidadeWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure AlternativaWSHolder

WSSTRUCT QuestaoWSService_AlternativaWSHolder
	WSDATA   cCdQuestaoExterno         AS string OPTIONAL
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cScore                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QuestaoWSService_AlternativaWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QuestaoWSService_AlternativaWSHolder
Return

WSMETHOD CLONE WSCLIENT QuestaoWSService_AlternativaWSHolder
	Local oClone := QuestaoWSService_AlternativaWSHolder():NEW()
	oClone:cCdQuestaoExterno    := ::cCdQuestaoExterno
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:cScore               := ::cScore
Return oClone

WSMETHOD SOAPSEND WSCLIENT QuestaoWSService_AlternativaWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdQuestaoExterno", ::cCdQuestaoExterno, ::cCdQuestaoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Score", ::cScore, ::cScore , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure UnidadeWSHolder

WSSTRUCT QuestaoWSService_UnidadeWSHolder
	WSDATA   cCdUnidadePaiExterno      AS string OPTIONAL
	WSDATA   cCdUnidadeFilhoExterno    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT QuestaoWSService_UnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT QuestaoWSService_UnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT QuestaoWSService_UnidadeWSHolder
	Local oClone := QuestaoWSService_UnidadeWSHolder():NEW()
	oClone:cCdUnidadePaiExterno := ::cCdUnidadePaiExterno
	oClone:cCdUnidadeFilhoExterno := ::cCdUnidadeFilhoExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT QuestaoWSService_UnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdUnidadePaiExterno", ::cCdUnidadePaiExterno, ::cCdUnidadePaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadeFilhoExterno", ::cCdUnidadeFilhoExterno, ::cCdUnidadeFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


