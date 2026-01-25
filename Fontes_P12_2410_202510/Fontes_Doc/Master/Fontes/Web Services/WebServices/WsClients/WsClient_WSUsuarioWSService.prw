#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.80.129.223:9090/epm1120/webservice/UsuarioWS?wsdl
Gerado em        07/05/11 17:53:15
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.110425
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _NYQXVUN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSUsuarioWSService
------------------------------------------------------------------------------- */

WSCLIENT WSUsuarioWSService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD insertUsuario
	WSMETHOD deleteUsuario

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   oWSUsuario                AS UsuarioWSService_UsuarioWSHolder
	WSDATA   creturn                   AS string
	WSDATA   cCodigo                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSUsuarioWSService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.100812P-20101130] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSUsuarioWSService
	::oWSUsuario         := UsuarioWSService_USUARIOWSHOLDER():New()
Return

WSMETHOD RESET WSCLIENT WSUsuarioWSService
	::oWSUsuario         := NIL 
	::creturn            := NIL 
	::cCodigo            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSUsuarioWSService
Local oClone := WSUsuarioWSService():New()
	oClone:_URL          := ::_URL 
	oClone:oWSUsuario    :=  IIF(::oWSUsuario = NIL , NIL ,::oWSUsuario:Clone() )
	oClone:creturn       := ::creturn
	oClone:cCodigo       := ::cCodigo
Return oClone

// WSDL Method insertUsuario of Service WSUsuarioWSService

WSMETHOD insertUsuario WSSEND oWSUsuario WSRECEIVE creturn WSCLIENT WSUsuarioWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<insertUsuario xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Usuario", ::oWSUsuario, oWSUsuario , "UsuarioWSHolder", .F. , .F., 0 , NIL, .T.) 
cSoap += "</insertUsuario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/UsuarioWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_INSERTUSUARIORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method deleteUsuario of Service WSUsuarioWSService

WSMETHOD deleteUsuario WSSEND cCodigo WSRECEIVE creturn WSCLIENT WSUsuarioWSService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<deleteUsuario xmlns="http://ws.integracao.elearning.totvs.com.br/">'
cSoap += WSSoapValue("Codigo", ::cCodigo, cCodigo , "string", .F. , .F., 0 , NIL, .T.) 
cSoap += "</deleteUsuario>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"DOCUMENT","http://ws.integracao.elearning.totvs.com.br/",,,; 
	"http://10.80.129.223:9090/epm1120/webservice/UsuarioWS")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_DELETEUSUARIORESPONSE:_RETURN:TEXT","string",NIL,NIL,NIL,NIL,NIL,"soap") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure UsuarioWSHolder

WSSTRUCT UsuarioWSService_UsuarioWSHolder
	WSDATA   cCdExterno                AS string OPTIONAL
	WSDATA   cNome                     AS string OPTIONAL
	WSDATA   cCpf                      AS string OPTIONAL
	WSDATA   cEmail                    AS string OPTIONAL
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   dDataNascimento           AS date OPTIONAL
	WSDATA   cSexo                     AS string OPTIONAL
	WSDATA   cRg                       AS string OPTIONAL
	WSDATA   cNomeMae                  AS string OPTIONAL
	WSDATA   oWSUsuarioExtra           AS UsuarioWSService_UsuarioExtraWSHolder OPTIONAL
	WSDATA   oWSListaUsuarioPerfil     AS UsuarioWSService_ListaUsuarioPerfilWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_UsuarioWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_UsuarioWSHolder
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_UsuarioWSHolder
	Local oClone := UsuarioWSService_UsuarioWSHolder():NEW()
	oClone:cCdExterno           := ::cCdExterno
	oClone:cNome                := ::cNome
	oClone:cCpf                 := ::cCpf
	oClone:cEmail               := ::cEmail
	oClone:cLogin               := ::cLogin
	oClone:dDataNascimento      := ::dDataNascimento
	oClone:cSexo                := ::cSexo
	oClone:cRg                  := ::cRg
	oClone:cNomeMae             := ::cNomeMae
	oClone:oWSUsuarioExtra      := IIF(::oWSUsuarioExtra = NIL , NIL , ::oWSUsuarioExtra:Clone() )
	oClone:oWSListaUsuarioPerfil := IIF(::oWSListaUsuarioPerfil = NIL , NIL , ::oWSListaUsuarioPerfil:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_UsuarioWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdExterno", ::cCdExterno, ::cCdExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Nome", ::cNome, ::cNome , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Cpf", ::cCpf, ::cCpf , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Email", ::cEmail, ::cEmail , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Login", ::cLogin, ::cLogin , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("DataNascimento", ::dDataNascimento, ::dDataNascimento , "date", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Sexo", ::cSexo, ::cSexo , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("Rg", ::cRg, ::cRg , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("NomeMae", ::cNomeMae, ::cNomeMae , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("UsuarioExtra", ::oWSUsuarioExtra, ::oWSUsuarioExtra , "UsuarioExtraWSHolder", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("ListaUsuarioPerfil", ::oWSListaUsuarioPerfil, ::oWSListaUsuarioPerfil , "ListaUsuarioPerfilWSHolder", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure UsuarioExtraWSHolder

WSSTRUCT UsuarioWSService_UsuarioExtraWSHolder
	WSDATA   cCdUsuarioExterno         AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_UsuarioExtraWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_UsuarioExtraWSHolder
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_UsuarioExtraWSHolder
	Local oClone := UsuarioWSService_UsuarioExtraWSHolder():NEW()
	oClone:cCdUsuarioExterno    := ::cCdUsuarioExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_UsuarioExtraWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdUsuarioExterno", ::cCdUsuarioExterno, ::cCdUsuarioExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaUsuarioPerfilWSHolder

WSSTRUCT UsuarioWSService_ListaUsuarioPerfilWSHolder
	WSDATA   oWSUsuarioPerfil          AS UsuarioWSService_UsuarioPerfilWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_ListaUsuarioPerfilWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_ListaUsuarioPerfilWSHolder
	::oWSUsuarioPerfil     := {} // Array Of  UsuarioWSService_USUARIOPERFILWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_ListaUsuarioPerfilWSHolder
	Local oClone := UsuarioWSService_ListaUsuarioPerfilWSHolder():NEW()
	oClone:oWSUsuarioPerfil := NIL
	If ::oWSUsuarioPerfil <> NIL 
		oClone:oWSUsuarioPerfil := {}
		aEval( ::oWSUsuarioPerfil , { |x| aadd( oClone:oWSUsuarioPerfil , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_ListaUsuarioPerfilWSHolder
	Local cSoap := ""
	aEval( ::oWSUsuarioPerfil , {|x| cSoap := cSoap  +  WSSoapValue("UsuarioPerfil", x , x , "UsuarioPerfilWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure UsuarioPerfilWSHolder

WSSTRUCT UsuarioWSService_UsuarioPerfilWSHolder
	WSDATA   oWSListaUsuarioPerfilUnidade AS UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder OPTIONAL
	WSDATA   cCdUsuarioExterno         AS string OPTIONAL
	WSDATA   cCdUsuarioPerfilExterno   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_UsuarioPerfilWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_UsuarioPerfilWSHolder
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_UsuarioPerfilWSHolder
	Local oClone := UsuarioWSService_UsuarioPerfilWSHolder():NEW()
	oClone:oWSListaUsuarioPerfilUnidade := IIF(::oWSListaUsuarioPerfilUnidade = NIL , NIL , ::oWSListaUsuarioPerfilUnidade:Clone() )
	oClone:cCdUsuarioExterno    := ::cCdUsuarioExterno
	oClone:cCdUsuarioPerfilExterno := ::cCdUsuarioPerfilExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_UsuarioPerfilWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("ListaUsuarioPerfilUnidade", ::oWSListaUsuarioPerfilUnidade, ::oWSListaUsuarioPerfilUnidade , "ListaUsuarioPerfilUnidadeWSHolder", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUsuarioExterno", ::cCdUsuarioExterno, ::cCdUsuarioExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUsuarioPerfilExterno", ::cCdUsuarioPerfilExterno, ::cCdUsuarioPerfilExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap

// WSDL Data Structure ListaUsuarioPerfilUnidadeWSHolder

WSSTRUCT UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder
	WSDATA   oWSUsuarioPerfilUnidade   AS UsuarioWSService_UsuarioPerfilUnidadeWSHolder OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder
	::oWSUsuarioPerfilUnidade := {} // Array Of  UsuarioWSService_USUARIOPERFILUNIDADEWSHOLDER():New()
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder
	Local oClone := UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder():NEW()
	oClone:oWSUsuarioPerfilUnidade := NIL
	If ::oWSUsuarioPerfilUnidade <> NIL 
		oClone:oWSUsuarioPerfilUnidade := {}
		aEval( ::oWSUsuarioPerfilUnidade , { |x| aadd( oClone:oWSUsuarioPerfilUnidade , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_ListaUsuarioPerfilUnidadeWSHolder
	Local cSoap := ""
	aEval( ::oWSUsuarioPerfilUnidade , {|x| cSoap := cSoap  +  WSSoapValue("UsuarioPerfilUnidade", x , x , "UsuarioPerfilUnidadeWSHolder", .F. , .F., 0 , NIL, .T.)  } ) 
Return cSoap

// WSDL Data Structure UsuarioPerfilUnidadeWSHolder

WSSTRUCT UsuarioWSService_UsuarioPerfilUnidadeWSHolder
	WSDATA   cCdUnidadePaiExterno      AS string OPTIONAL
	WSDATA   cCdUnidadeFilhoExterno    AS string OPTIONAL
	WSDATA   cCdUsuarioPerfilExterno   AS string OPTIONAL
	WSDATA   cCdUsuarioPerfilUnidadeExterno AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UsuarioWSService_UsuarioPerfilUnidadeWSHolder
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UsuarioWSService_UsuarioPerfilUnidadeWSHolder
Return

WSMETHOD CLONE WSCLIENT UsuarioWSService_UsuarioPerfilUnidadeWSHolder
	Local oClone := UsuarioWSService_UsuarioPerfilUnidadeWSHolder():NEW()
	oClone:cCdUnidadePaiExterno := ::cCdUnidadePaiExterno
	oClone:cCdUnidadeFilhoExterno := ::cCdUnidadeFilhoExterno
	oClone:cCdUsuarioPerfilExterno := ::cCdUsuarioPerfilExterno
	oClone:cCdUsuarioPerfilUnidadeExterno := ::cCdUsuarioPerfilUnidadeExterno
Return oClone

WSMETHOD SOAPSEND WSCLIENT UsuarioWSService_UsuarioPerfilUnidadeWSHolder
	Local cSoap := ""
	cSoap += WSSoapValue("CdUnidadePaiExterno", ::cCdUnidadePaiExterno, ::cCdUnidadePaiExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUnidadeFilhoExterno", ::cCdUnidadeFilhoExterno, ::cCdUnidadeFilhoExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUsuarioPerfilExterno", ::cCdUsuarioPerfilExterno, ::cCdUsuarioPerfilExterno , "string", .F. , .F., 0 , NIL, .T.) 
	cSoap += WSSoapValue("CdUsuarioPerfilUnidadeExterno", ::cCdUsuarioPerfilUnidadeExterno, ::cCdUsuarioPerfilUnidadeExterno , "string", .F. , .F., 0 , NIL, .T.) 
Return cSoap


