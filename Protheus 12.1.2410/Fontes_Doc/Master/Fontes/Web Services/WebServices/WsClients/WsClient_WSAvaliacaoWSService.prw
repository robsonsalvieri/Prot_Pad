#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/ams1110/webservice/AvaliacaoWS?wsdl
Gerado em        07/05/11 17:54:16
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _UFYIKKQ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSAvaliacaoWSService
------------------------------------------------------------------------------- */

WSCLIENT WSAvaliacaoWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD listAvaliacoes
	WSMETHOD insertAvaliacao
	WSMETHOD deleteAvaliacao
	WSMETHOD getAvaliacaoByCodigo

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   cTopico                   AS string
	WSDATA   oWSAvaliacaoWSHolder      AS AvaliacaoWSService_AvaliacaoWSHolder
	WSDATA   oWSAvaliacao              AS AvaliacaoWSService_AvaliacaoWSHolder
	WSDATA   creturn                   AS string
	WSDATA   ccodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSAvaliacaoWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSAvaliacaoWSService
	::oWSAvaliacaoWSHolder := {} // Array Of  AvaliacaoWSService_AVALIACAOWSHOLDER():New()
	::oWSAvaliacao       := AvaliacaoWSService_AVALIACAOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSAvaliacaoWSService
	::cTopico            := NIL 
	::oWSAvaliacaoWSHolder := NIL 
	::oWSAvaliacao       := NIL 
	::creturn            := NIL 
	::ccodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSAvaliacaoWSService
Local oClone := WSAvaliacaoWSService():New()
	oClone:_URL          := ::_URL 
	oClone:cTopico       := ::cTopico
	oClone:oWSAvaliacaoWSHolder :=  IIF(::oWSAvaliacaoWSHolder = NIL , NIL ,::oWSAvaliacaoWSHolder:Clone() )
	oClone:oWSAvaliacao  :=  IIF(::oWSAvaliacao = NIL , NIL ,::oWSAvaliacao:Clone() )
	oClone:creturn       := ::creturn
	oClone:ccodigo       := ::ccodigo
Return oClone

// WSDL Method listAvaliacoes of Service WSAvaliacaoWSService

WSMETHOD listAvaliacoes WSSEND cTopico WSRECEIVE oWSAvaliacaoWSHolder WSCLIENT WSAvaliacaoWSService
Local cSoap := "" , oXmlRet
Local oATmp01
BEGIN WSMETHOD

cSoap += '<listAvaliacoes xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Topico", ::cTopico, cTopico , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</listAvaliacoes>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/AvaliacaoWS")

::Init()
oATmp01 :=           WSAdvValue( oXmlRet,"_LISTAVALIACOESRESPONSE:_RETURN","AvaliacaoWSHolder",NIL,NIL,NIL,NIL,NIL,"soap") 
If valtype(oATmp01)="A"
	aEval(oATmp01,{|x,y| ( aadd(::oWSAvaliacaoWSHolder,AvaliacaoWSService_AvaliacaoWSHolder():New()) , ::oWSAvaliacaoWSHolder[y]:SoapRecv(x) ) })
Endif

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method insertAvaliacao of Service WSAvaliacaoWSService

WSMETHOD insertAvaliacao WSSEND oWSAvaliacao WSRECEIVE creturn WSCLIENT WSAvaliacaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertAvaliacao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Avaliacao", ::oWSAvaliacao, oWSAvaliacao , "AvaliacaoWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertAvaliacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/AvaliacaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTAVALIACAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteAvaliacao of Service WSAvaliacaoWSService

WSMETHOD deleteAvaliacao WSSEND ccodigo WSRECEIVE creturn WSCLIENT WSAvaliacaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteAvaliacao xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("codigo", ::ccodigo, ccodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteAvaliacao>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/AvaliacaoWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEAVALIACAORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getAvaliacaoByCodigo of Service WSAvaliacaoWSService

WSMETHOD getAvaliacaoByCodigo WSSEND cCodigo WSRECEIVE oWSAvaliacaoWSHolder WSCLIENT WSAvaliacaoWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<getAvaliacaoByCodigo xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</getAvaliacaoByCodigo>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/ams1110/webservice/AvaliacaoWS")

::Init()
::oWSAvaliacaoWSHolder:SoapRecv( WSAdvValue( oXmlRet,"_GETAVALIACAOBYCODIGORESPONSE:_RETURN","AvaliacaoWSHolder",NIL,NIL,NIL,NIL,NIL,"soap") )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AvaliacaoWSHolder

WSSTRUCT AvaliacaoWSService_AvaliacaoWSHolder
	WSDATA   cCodigo                   AS string OPTIONAL
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cDescricao                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cDuracao                  AS string OPTIONAL
	WSDATA   cPesquisa                 AS string OPTIONAL
	WSDATA   oWSListaQuestao           AS AvaliacaoWSService_ListaQuestaoWSHolder OPTIONAL
	WSDATA   oWSListaUnidade           AS AvaliacaoWSService_ListaUnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoWSService_AvaliacaoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoWSService_AvaliacaoWSHolder
Return

WSMETHOD CLONE WSCLIENT AvaliacaoWSService_AvaliacaoWSHolder
	Local oClone := AvaliacaoWSService_AvaliacaoWSHolder():NEW()
	oClone:cCodigo              := ::cCodigo
	oClone:cCdExterno           := ::cCdExterno
	oClone:cDescricao           := ::cDescricao
	oClone:cNome                := ::cNome
	oClone:cDuracao             := ::cDuracao
	oClone:cPesquisa            := ::cPesquisa
	oClone:oWSListaQuestao      := IIF(::oWSListaQuestao = NIL , NIL , ::oWSListaQuestao:Clone() )
	oClone:oWSListaUnidade      := IIF(::oWSListaUnidade = NIL , NIL , ::oWSListaUnidade:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoWSService_AvaliacaoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("Codigo", ::cCodigo, ::cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Descricao", ::cDescricao, ::cDescricao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Duracao", ::cDuracao, ::cDuracao , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Pesquisa", ::cPesquisa, ::cPesquisa , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaQuestao", ::oWSListaQuestao, ::oWSListaQuestao , "ListaQuestaoWSHolder", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaUnidade", ::oWSListaUnidade, ::oWSListaUnidade , "ListaUnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AvaliacaoWSService_AvaliacaoWSHolder
	Local oNode7
	Local oNode8
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCodigo            :=  WSAdvValue( oResponse,"_CODIGO","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cCdExterno         :=  WSAdvValue( oResponse,"_CDEXTERNO","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cDescricao         :=  WSAdvValue( oResponse,"_DESCRICAO","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cNome              :=  WSAdvValue( oResponse,"_NOME","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cDuracao           :=  WSAdvValue( oResponse,"_DURACAO","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cPesquisa          :=  WSAdvValue( oResponse,"_PESQUISA","string",NIL,NIL,NIL,"S",NIL,"soap") 
	oNode7 :=  WSAdvValue( oResponse,"_LISTAQUESTAO","ListaQuestaoWSHolder",NIL,NIL,NIL,"O",NIL,"soap") 
	If oNode7 != NIL
		::oWSListaQuestao := AvaliacaoWSService_ListaQuestaoWSHolder():New()
		::oWSListaQuestao:SoapRecv(oNode7)
	EndIf
	oNode8 :=  WSAdvValue( oResponse,"_LISTAUNIDADE","ListaUnidadeWSHolder",NIL,NIL,NIL,"O",NIL,"soap") 
	If oNode8 != NIL
		::oWSListaUnidade := AvaliacaoWSService_ListaUnidadeWSHolder():New()
		::oWSListaUnidade:SoapRecv(oNode8)
	EndIf
Return

// WSDL Data Structure ListaQuestaoWSHolder

WSSTRUCT AvaliacaoWSService_ListaQuestaoWSHolder
	WSDATA   oWSQuestao                AS AvaliacaoWSService_QuestaoWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoWSService_ListaQuestaoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoWSService_ListaQuestaoWSHolder
	::oWSQuestao           := {} // Array Of  AvaliacaoWSService_QUESTAOWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT AvaliacaoWSService_ListaQuestaoWSHolder
	Local oClone := AvaliacaoWSService_ListaQuestaoWSHolder():NEW()
	oClone:oWSQuestao := NIL
	If ::oWSQuestao <> NIL 
		oClone:oWSQuestao := {}
		aEval( ::oWSQuestao , { |x| aadd( oClone:oWSQuestao , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoWSService_ListaQuestaoWSHolder
	Local cSoap := ""
	aEval( ::oWSQuestao , {|x| cSoap := cSoap  +  WSSoapValue("Questao", x , x , "QuestaoWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AvaliacaoWSService_ListaQuestaoWSHolder
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_QUESTAO","QuestaoWSHolder",{},NIL,.T.,"O",NIL,"soap") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSQuestao , AvaliacaoWSService_QuestaoWSHolder():New() )
			::oWSQuestao[len(::oWSQuestao)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ListaUnidadeWSHolder

WSSTRUCT AvaliacaoWSService_ListaUnidadeWSHolder
	WSDATA   oWSUnidade                AS AvaliacaoWSService_UnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoWSService_ListaUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoWSService_ListaUnidadeWSHolder
	::oWSUnidade           := {} // Array Of  AvaliacaoWSService_UNIDADEWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT AvaliacaoWSService_ListaUnidadeWSHolder
	Local oClone := AvaliacaoWSService_ListaUnidadeWSHolder():NEW()
	oClone:oWSUnidade := NIL
	If ::oWSUnidade <> NIL 
		oClone:oWSUnidade := {}
		aEval( ::oWSUnidade , { |x| aadd( oClone:oWSUnidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoWSService_ListaUnidadeWSHolder
	Local cSoap := ""
	aEval( ::oWSUnidade , {|x| cSoap := cSoap  +  WSSoapValue("Unidade", x , x , "UnidadeWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AvaliacaoWSService_ListaUnidadeWSHolder
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_UNIDADE","UnidadeWSHolder",{},NIL,.T.,"O",NIL,"soap") 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSUnidade , AvaliacaoWSService_UnidadeWSHolder():New() )
			::oWSUnidade[len(::oWSUnidade)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure QuestaoWSHolder

WSSTRUCT AvaliacaoWSService_QuestaoWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoWSService_QuestaoWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoWSService_QuestaoWSHolder
Return

WSMETHOD CLONE WSCLIENT AvaliacaoWSService_QuestaoWSHolder
	Local oClone := AvaliacaoWSService_QuestaoWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoWSService_QuestaoWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AvaliacaoWSService_QuestaoWSHolder
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCdExterno         :=  WSAdvValue( oResponse,"_CDEXTERNO","string",NIL,NIL,NIL,"S",NIL,"soap") 
Return

// WSDL Data Structure UnidadeWSHolder

WSSTRUCT AvaliacaoWSService_UnidadeWSHolder
	WSDATA   cCdUnidadePaiExterno      AS string OPTIONAL
	WSDATA   cCdUnidadeFilhoExterno    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT AvaliacaoWSService_UnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT AvaliacaoWSService_UnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT AvaliacaoWSService_UnidadeWSHolder
	Local oClone := AvaliacaoWSService_UnidadeWSHolder():NEW()
	oClone:cCdUnidadePaiExterno := ::cCdUnidadePaiExterno
	oClone:cCdUnidadeFilhoExterno := ::cCdUnidadeFilhoExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT AvaliacaoWSService_UnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdUnidadePaiExterno", ::cCdUnidadePaiExterno, ::cCdUnidadePaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadeFilhoExterno", ::cCdUnidadeFilhoExterno, ::cCdUnidadeFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT AvaliacaoWSService_UnidadeWSHolder
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCdUnidadePaiExterno :=  WSAdvValue( oResponse,"_CDUNIDADEPAIEXTERNO","string",NIL,NIL,NIL,"S",NIL,"soap") 
	::cCdUnidadeFilhoExterno :=  WSAdvValue( oResponse,"_CDUNIDADEFILHOEXTERNO","string",NIL,NIL,NIL,"S",NIL,"soap") 
Return


