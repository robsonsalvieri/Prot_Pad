#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://qaclic.pta.com.br/Externo_Services/Externo/Cotacao.svc?wsdl
Gerado em        04/02/14 17:48:04
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function _FRWIRTH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSCotacaoServico
------------------------------------------------------------------------------- */
WSCLIENT WSCotacaoServico

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD Registrar
	WSMETHOD Encerrar
	WSMETHOD Remover

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSobjEmpresaLicenciada   AS CotacaoServico_EmpresaLicenciadaDTO
	WSDATA   csIdUsuario               AS string
	WSDATA   oWSlstCotacao             AS CotacaoServico_ArrayOfCotacaoDTO
	WSDATA   oWSlstCotacaoR            AS CotacaoServico_ArrayOfCotacaoRDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSCotacaoServico
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.121227P-20131106] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSCotacaoServico
	::oWSobjEmpresaLicenciada := CotacaoServico_EMPRESALICENCIADADTO():New()
	::oWSlstCotacao      := CotacaoServico_ARRAYOFCOTACAODTO():New()
	::oWSlstCotacaoR     := CotacaoServico_ARRAYOFCOTACAORDTO():New()
Return

WSMETHOD RESET WSCLIENT WSCotacaoServico
	::oWSobjEmpresaLicenciada := NIL 
	::csIdUsuario        := NIL 
	::oWSlstCotacao      := NIL 
	::oWSlstCotacaoR     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSCotacaoServico
Local oClone := WSCotacaoServico():New()
	oClone:_URL          := ::_URL 
	oClone:oWSobjEmpresaLicenciada :=  IIF(::oWSobjEmpresaLicenciada = NIL , NIL ,::oWSobjEmpresaLicenciada:Clone() )
	oClone:csIdUsuario   := ::csIdUsuario
	oClone:oWSlstCotacao :=  IIF(::oWSlstCotacao = NIL , NIL ,::oWSlstCotacao:Clone() )
	oClone:oWSlstCotacaoR :=  IIF(::oWSlstCotacaoR = NIL , NIL ,::oWSlstCotacaoR:Clone() )
Return oClone

// WSDL Method Registrar of Service WSCotacaoServico

WSMETHOD Registrar WSSEND oWSobjEmpresaLicenciada,csIdUsuario,oWSlstCotacao WSRECEIVE NULLPARAM WSCLIENT WSCotacaoServico
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Registrar xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("objEmpresaLicenciada", ::oWSobjEmpresaLicenciada, oWSobjEmpresaLicenciada , "EmpresaLicenciadaDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += WSSoapValue("sIdUsuario", ::csIdUsuario, csIdUsuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("lstCotacao", ::oWSlstCotacao, oWSlstCotacao , "ArrayOfCotacaoDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</Registrar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ICotacao/Registrar",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://qaclic.pta.com.br/Externo_Services/Externo/Cotacao.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Encerrar of Service WSCotacaoServico

WSMETHOD Encerrar WSSEND oWSobjEmpresaLicenciada,oWSlstCotacaoR WSRECEIVE NULLPARAM WSCLIENT WSCotacaoServico
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Encerrar xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("objEmpresaLicenciada", ::oWSobjEmpresaLicenciada, oWSobjEmpresaLicenciada , "EmpresaLicenciadaDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += WSSoapValue("lstCotacao", ::oWSlstCotacaoR, oWSlstCotacaoR , "ArrayOfIdentificacaoCotacaoDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</Encerrar>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ICotacao/Encerrar",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://qaclic.pta.com.br/Externo_Services/Externo/Cotacao.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Remover of Service WSCotacaoServico

WSMETHOD Remover WSSEND oWSobjEmpresaLicenciada,oWSlstCotacaoR WSRECEIVE NULLPARAM WSCLIENT WSCotacaoServico
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Remover xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("objEmpresaLicenciada", ::oWSobjEmpresaLicenciada, oWSobjEmpresaLicenciada , "EmpresaLicenciadaDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += WSSoapValue("lstCotacao", ::oWSlstCotacaoR, oWSlstCotacaoR , "ArrayOfIdentificacaoCotacaoDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</Remover>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/ICotacao/Remover",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://qaclic.pta.com.br/Externo_Services/Externo/Cotacao.svc")

::Init()

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure EmpresaLicenciadaDTO

WSSTRUCT CotacaoServico_EmpresaLicenciadaDTO
	WSDATA   csDsEmailContato          AS string OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSDATA   csNrTelefoneContato       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_EmpresaLicenciadaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_EmpresaLicenciadaDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_EmpresaLicenciadaDTO
	Local oClone := CotacaoServico_EmpresaLicenciadaDTO():NEW()
	oClone:csDsEmailContato     := ::csDsEmailContato
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
	oClone:csNrTelefoneContato  := ::csNrTelefoneContato
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_EmpresaLicenciadaDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sDsEmailContato", ::csDsEmailContato, ::csDsEmailContato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmRazaoSocial", ::csNmRazaoSocial, ::csNmRazaoSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrCnpj", ::csNrCnpj, ::csNrCnpj , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrTelefoneContato", ::csNrTelefoneContato, ::csNrTelefoneContato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ArrayOfCotacaoDTO

WSSTRUCT CotacaoServico_ArrayOfCotacaoDTO
	WSDATA   oWSCotacaoDTO             AS CotacaoServico_CotacaoDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfCotacaoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfCotacaoDTO
	::oWSCotacaoDTO        := {} // Array Of  CotacaoServico_COTACAODTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfCotacaoDTO
	Local oClone := CotacaoServico_ArrayOfCotacaoDTO():NEW()
	oClone:oWSCotacaoDTO := NIL
	If ::oWSCotacaoDTO <> NIL 
		oClone:oWSCotacaoDTO := {}
		aEval( ::oWSCotacaoDTO , { |x| aadd( oClone:oWSCotacaoDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfCotacaoDTO
	Local cSoap := ""
	aEval( ::oWSCotacaoDTO , {|x| cSoap := cSoap  +  WSSoapValue("CotacaoDTO", x , x , "CotacaoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure CotacaoDTO

WSSTRUCT CotacaoServico_CotacaoDTO
	WSDATA   oWSComprador              AS CotacaoServico_CompradorDTO OPTIONAL
	WSDATA   oWSLstConvidados          AS CotacaoServico_ArrayOfConvidadoDTO OPTIONAL
	WSDATA   oWSLstItens               AS CotacaoServico_ArrayOfItemDTO OPTIONAL
	WSDATA   oWSLstParticipantes       AS CotacaoServico_ArrayOfParticipanteDTO OPTIONAL
	WSDATA   lbFlVisivel               AS boolean OPTIONAL
	WSDATA   csDsProcesso              AS string OPTIONAL
	WSDATA   csIdCotacao               AS string OPTIONAL
	WSDATA   csNrProcesso              AS string OPTIONAL
	WSDATA   ctDtInicio                AS dateTime OPTIONAL
	WSDATA   ctDtTermino               AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_CotacaoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_CotacaoDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_CotacaoDTO
	Local oClone := CotacaoServico_CotacaoDTO():NEW()
	oClone:oWSComprador         := IIF(::oWSComprador = NIL , NIL , ::oWSComprador:Clone() )
	oClone:oWSLstConvidados     := IIF(::oWSLstConvidados = NIL , NIL , ::oWSLstConvidados:Clone() )
	oClone:oWSLstItens          := IIF(::oWSLstItens = NIL , NIL , ::oWSLstItens:Clone() )
	oClone:oWSLstParticipantes  := IIF(::oWSLstParticipantes = NIL , NIL , ::oWSLstParticipantes:Clone() )
	oClone:lbFlVisivel          := ::lbFlVisivel
	oClone:csDsProcesso         := ::csDsProcesso
	oClone:csIdCotacao          := ::csIdCotacao
	oClone:csNrProcesso         := ::csNrProcesso
	oClone:ctDtInicio           := ::ctDtInicio
	oClone:ctDtTermino          := ::ctDtTermino
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_CotacaoDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Comprador", ::oWSComprador, ::oWSComprador , "CompradorDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("LstConvidados", ::oWSLstConvidados, ::oWSLstConvidados , "ArrayOfConvidadoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("LstItens", ::oWSLstItens, ::oWSLstItens , "ArrayOfItemDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("LstParticipantes", ::oWSLstParticipantes, ::oWSLstParticipantes , "ArrayOfParticipanteDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("bFlVisivel", ::lbFlVisivel, ::lbFlVisivel , "boolean", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sDsProcesso", ::csDsProcesso, ::csDsProcesso , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdCotacao", ::csIdCotacao, ::csIdCotacao , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrProcesso", ::csNrProcesso, ::csNrProcesso , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("tDtInicio", ::ctDtInicio, ::ctDtInicio , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("tDtTermino", ::ctDtTermino, ::ctDtTermino , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

//------------------------------------------------------------------

// WSDL Data Structure CompradorDTO

WSSTRUCT CotacaoServico_CompradorDTO
	WSDATA   oWSContato                AS CotacaoServico_ContatoDTO OPTIONAL
	WSDATA   oWSEndereco               AS CotacaoServico_EnderecoDTO OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_CompradorDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_CompradorDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_CompradorDTO
	Local oClone := CotacaoServico_CompradorDTO():NEW()
	oClone:oWSContato           := IIF(::oWSContato = NIL , NIL , ::oWSContato:Clone() )
	oClone:oWSEndereco          := IIF(::oWSEndereco = NIL , NIL , ::oWSEndereco:Clone() )
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_CompradorDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Contato", ::oWSContato, ::oWSContato , "ContatoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("Endereco", ::oWSEndereco, ::oWSEndereco , "EnderecoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmRazaoSocial", ::csNmRazaoSocial, ::csNmRazaoSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrCnpj", ::csNrCnpj, ::csNrCnpj , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ArrayOfConvidadoDTO

WSSTRUCT CotacaoServico_ArrayOfConvidadoDTO
	WSDATA   oWSConvidadoDTO           AS CotacaoServico_ConvidadoDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfConvidadoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfConvidadoDTO
	::oWSConvidadoDTO      := {} // Array Of  CotacaoServico_CONVIDADODTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfConvidadoDTO
	Local oClone := CotacaoServico_ArrayOfConvidadoDTO():NEW()
	oClone:oWSConvidadoDTO := NIL
	If ::oWSConvidadoDTO <> NIL 
		oClone:oWSConvidadoDTO := {}
		aEval( ::oWSConvidadoDTO , { |x| aadd( oClone:oWSConvidadoDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfConvidadoDTO
	Local cSoap := ""
	aEval( ::oWSConvidadoDTO , {|x| cSoap := cSoap  +  WSSoapValue("ConvidadoDTO", x , x , "ConvidadoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfItemDTO

WSSTRUCT CotacaoServico_ArrayOfItemDTO
	WSDATA   oWSItemDTO                AS CotacaoServico_ItemDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfItemDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfItemDTO
	::oWSItemDTO           := {} // Array Of  CotacaoServico_ITEMDTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfItemDTO
	Local oClone := CotacaoServico_ArrayOfItemDTO():NEW()
	oClone:oWSItemDTO := NIL
	If ::oWSItemDTO <> NIL 
		oClone:oWSItemDTO := {}
		aEval( ::oWSItemDTO , { |x| aadd( oClone:oWSItemDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfItemDTO
	Local cSoap := ""
	aEval( ::oWSItemDTO , {|x| cSoap := cSoap  +  WSSoapValue("ItemDTO", x , x , "ItemDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfParticipanteDTO

WSSTRUCT CotacaoServico_ArrayOfParticipanteDTO
	WSDATA   oWSParticipanteDTO        AS CotacaoServico_ParticipanteDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfParticipanteDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfParticipanteDTO
	::oWSParticipanteDTO   := {} // Array Of  CotacaoServico_PARTICIPANTEDTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfParticipanteDTO
	Local oClone := CotacaoServico_ArrayOfParticipanteDTO():NEW()
	oClone:oWSParticipanteDTO := NIL
	If ::oWSParticipanteDTO <> NIL 
		oClone:oWSParticipanteDTO := {}
		aEval( ::oWSParticipanteDTO , { |x| aadd( oClone:oWSParticipanteDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfParticipanteDTO
	Local cSoap := ""
	aEval( ::oWSParticipanteDTO , {|x| cSoap := cSoap  +  WSSoapValue("ParticipanteDTO", x , x , "ParticipanteDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure ContatoDTO

WSSTRUCT CotacaoServico_ContatoDTO
	WSDATA   csDsEmail                 AS string OPTIONAL
	WSDATA   csNmContato               AS string OPTIONAL
	WSDATA   csNrTelefone              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ContatoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ContatoDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ContatoDTO
	Local oClone := CotacaoServico_ContatoDTO():NEW()
	oClone:csDsEmail            := ::csDsEmail
	oClone:csNmContato          := ::csNmContato
	oClone:csNrTelefone         := ::csNrTelefone
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ContatoDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sDsEmail", ::csDsEmail, ::csDsEmail , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmContato", ::csNmContato, ::csNmContato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrTelefone", ::csNrTelefone, ::csNrTelefone , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure EnderecoDTO

WSSTRUCT CotacaoServico_EnderecoDTO
	WSDATA   csDsComplemento           AS string OPTIONAL
	WSDATA   csDsLogradouro            AS string OPTIONAL
	WSDATA   csIdCidade                AS string OPTIONAL
	WSDATA   csIdEstado                AS string OPTIONAL
	WSDATA   csIdPais                  AS string OPTIONAL
	WSDATA   csNmCidade                AS string OPTIONAL
	WSDATA   csSgEstado                AS string OPTIONAL
	WSDATA   csSgPais                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_EnderecoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_EnderecoDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_EnderecoDTO
	Local oClone := CotacaoServico_EnderecoDTO():NEW()
	oClone:csDsComplemento      := ::csDsComplemento
	oClone:csDsLogradouro       := ::csDsLogradouro
	oClone:csIdCidade           := ::csIdCidade
	oClone:csIdEstado           := ::csIdEstado
	oClone:csIdPais             := ::csIdPais
	oClone:csNmCidade           := ::csNmCidade
	oClone:csSgEstado           := ::csSgEstado
	oClone:csSgPais             := ::csSgPais
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_EnderecoDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sDsComplemento", ::csDsComplemento, ::csDsComplemento , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sDsLogradouro", ::csDsLogradouro, ::csDsLogradouro , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdCidade", ::csIdCidade, ::csIdCidade , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdEstado", ::csIdEstado, ::csIdEstado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdPais", ::csIdPais, ::csIdPais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmCidade", ::csNmCidade, ::csNmCidade , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sSgEstado", ::csSgEstado, ::csSgEstado , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sSgPais", ::csSgPais, ::csSgPais , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ConvidadoDTO

WSSTRUCT CotacaoServico_ConvidadoDTO
	WSDATA   oWSContato                AS CotacaoServico_ContatoDTO OPTIONAL
	WSDATA   oWSEndereco               AS CotacaoServico_EnderecoDTO OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ConvidadoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ConvidadoDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ConvidadoDTO
	Local oClone := CotacaoServico_ConvidadoDTO():NEW()
	oClone:oWSContato           := IIF(::oWSContato = NIL , NIL , ::oWSContato:Clone() )
	oClone:oWSEndereco          := IIF(::oWSEndereco = NIL , NIL , ::oWSEndereco:Clone() )
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ConvidadoDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Contato", ::oWSContato, ::oWSContato , "ContatoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("Endereco", ::oWSEndereco, ::oWSEndereco , "EnderecoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmRazaoSocial", ::csNmRazaoSocial, ::csNmRazaoSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrCnpj", ::csNrCnpj, ::csNrCnpj , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ItemDTO

WSSTRUCT CotacaoServico_ItemDTO
	WSDATA   oWSComprador              AS CotacaoServico_CompradorDTO OPTIONAL
	WSDATA   oWSLstEntregas            AS CotacaoServico_ArrayOfEntregaDTO OPTIONAL
	WSDATA   ndQtSolicitada            AS decimal OPTIONAL
	WSDATA   csDsCategoria             AS string OPTIONAL
	WSDATA   csDsItem                  AS string OPTIONAL
	WSDATA   csIdCategoria             AS string OPTIONAL
	WSDATA   csIdItem                  AS string OPTIONAL
	WSDATA   csSgUnidadeMedida         AS string OPTIONAL
	WSDATA   ctDtEntrega               AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ItemDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ItemDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ItemDTO
	Local oClone := CotacaoServico_ItemDTO():NEW()
	oClone:oWSComprador         := IIF(::oWSComprador = NIL , NIL , ::oWSComprador:Clone() )
	oClone:oWSLstEntregas       := IIF(::oWSLstEntregas = NIL , NIL , ::oWSLstEntregas:Clone() )
	oClone:ndQtSolicitada       := ::ndQtSolicitada
	oClone:csDsCategoria        := ::csDsCategoria
	oClone:csDsItem             := ::csDsItem
	oClone:csIdCategoria        := ::csIdCategoria
	oClone:csIdItem             := ::csIdItem
	oClone:csSgUnidadeMedida    := ::csSgUnidadeMedida
	oClone:ctDtEntrega          := ::ctDtEntrega
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ItemDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Comprador", ::oWSComprador, ::oWSComprador , "CompradorDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("LstEntregas", ::oWSLstEntregas, ::oWSLstEntregas , "ArrayOfEntregaDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("dQtSolicitada", ::ndQtSolicitada, ::ndQtSolicitada , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sDsCategoria", ::csDsCategoria, ::csDsCategoria , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sDsItem", ::csDsItem, ::csDsItem , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdCategoria", ::csIdCategoria, ::csIdCategoria , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdItem", ::csIdItem, ::csIdItem , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sSgUnidadeMedida", ::csSgUnidadeMedida, ::csSgUnidadeMedida , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("tDtEntrega", ::ctDtEntrega, ::ctDtEntrega , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ParticipanteDTO

WSSTRUCT CotacaoServico_ParticipanteDTO
	WSDATA   oWSContato                AS CotacaoServico_ContatoDTO OPTIONAL
	WSDATA   oWSEndereco               AS CotacaoServico_EnderecoDTO OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ParticipanteDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ParticipanteDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ParticipanteDTO
	Local oClone := CotacaoServico_ParticipanteDTO():NEW()
	oClone:oWSContato           := IIF(::oWSContato = NIL , NIL , ::oWSContato:Clone() )
	oClone:oWSEndereco          := IIF(::oWSEndereco = NIL , NIL , ::oWSEndereco:Clone() )
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ParticipanteDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Contato", ::oWSContato, ::oWSContato , "ContatoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("Endereco", ::oWSEndereco, ::oWSEndereco , "EnderecoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmRazaoSocial", ::csNmRazaoSocial, ::csNmRazaoSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrCnpj", ::csNrCnpj, ::csNrCnpj , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ArrayOfEntregaDTO

WSSTRUCT CotacaoServico_ArrayOfEntregaDTO
	WSDATA   oWSEntregaDTO             AS CotacaoServico_EntregaDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfEntregaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfEntregaDTO
	::oWSEntregaDTO        := {} // Array Of  CotacaoServico_ENTREGADTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfEntregaDTO
	Local oClone := CotacaoServico_ArrayOfEntregaDTO():NEW()
	oClone:oWSEntregaDTO := NIL
	If ::oWSEntregaDTO <> NIL 
		oClone:oWSEntregaDTO := {}
		aEval( ::oWSEntregaDTO , { |x| aadd( oClone:oWSEntregaDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfEntregaDTO
	Local cSoap := ""
	aEval( ::oWSEntregaDTO , {|x| cSoap := cSoap  +  WSSoapValue("EntregaDTO", x , x , "EntregaDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure EntregaDTO

WSSTRUCT CotacaoServico_EntregaDTO
	WSDATA   oWSComprador              AS CotacaoServico_CompradorDTO OPTIONAL
	WSDATA   oWSEndereco               AS CotacaoServico_EnderecoDTO OPTIONAL
	WSDATA   ndQtEntrega               AS decimal OPTIONAL
	WSDATA   csIdEntrega               AS string OPTIONAL
	WSDATA   ctDtEntrega               AS dateTime OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_EntregaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_EntregaDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_EntregaDTO
	Local oClone := CotacaoServico_EntregaDTO():NEW()
	oClone:oWSComprador         := IIF(::oWSComprador = NIL , NIL , ::oWSComprador:Clone() )
	oClone:oWSEndereco          := IIF(::oWSEndereco = NIL , NIL , ::oWSEndereco:Clone() )
	oClone:ndQtEntrega          := ::ndQtEntrega
	oClone:csIdEntrega          := ::csIdEntrega
	oClone:ctDtEntrega          := ::ctDtEntrega
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_EntregaDTO
	Local cSoap := ""
	cSoap += WSSoapValue("Comprador", ::oWSComprador, ::oWSComprador , "CompradorDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("Endereco", ::oWSEndereco, ::oWSEndereco , "EnderecoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("dQtEntrega", ::ndQtEntrega, ::ndQtEntrega , "decimal", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdEntrega", ::csIdEntrega, ::csIdEntrega , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("tDtEntrega", ::ctDtEntrega, ::ctDtEntrega , "dateTime", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

//-----------------------------------------------------------
// Manualmente
//-----------------------------------------------------------

WSSTRUCT CotacaoServico_ArrayOfCotacaoRDTO
	WSDATA   oWSIdentificacaoCotacaoDTO  AS CotacaoServico_IdentificacaoCotacaoDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfCotacaoRDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfCotacaoRDTO
	::oWSIdentificacaoCotacaoDTO        := {} // Array Of  CotacaoServico_COTACAODTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfCotacaoRDTO
	Local oClone := CotacaoServico_ArrayOfCotacaoRDTO():NEW()
	oClone:oWSIdentificacaoCotacaoDTO := NIL
	If ::oWSIdentificacaoCotacaoDTO <> NIL 
		oClone:oWSIdentificacaoCotacaoDTO := {}
		aEval( ::oWSIdentificacaoCotacaoDTO , { |x| aadd( oClone:oWSIdentificacaoCotacaoDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfCotacaoRDTO
	Local cSoap := ""
	aEval( ::oWSIdentificacaoCotacaoDTO , {|x| cSoap := cSoap  +  WSSoapValue("IdentificacaoCotacaoDTO", x , x , "IdentificacaoCotacaoDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap


WSSTRUCT CotacaoServico_IdentificacaoCotacaoDTO
	WSDATA   oWSLstItens               AS CotacaoServico_ArrayOfItemDTO OPTIONAL
	WSDATA   cSIdCotacao               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_IdentificacaoCotacaoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_IdentificacaoCotacaoDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_IdentificacaoCotacaoDTO
	Local oClone := CotacaoServico_IdentificacaoCotacaoDTO():NEW()
	oClone:oWSLstItens          := IIF(::oWSLstItens = NIL , NIL , ::oWSLstItens:Clone() )
	oClone:csIdCotacao          := ::csIdCotacao
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_IdentificacaoCotacaoDTO
	Local cSoap := ""
	cSoap += WSSoapValue("LstItens", ::oWSLstItens, ::oWSLstItens , "ArrayOfItemDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdCotacao", ::csIdCotacao, ::csIdCotacao , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap


WSSTRUCT CotacaoServico_ArrayOfIdentificacaoItemDTO
	WSDATA   oWSIdentificacaoItemDTO  AS CotacaoServico_IdentificacaoItemDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_ArrayOfIdentificacaoItemDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_ArrayOfIdentificacaoItemDTO
	::oWSIdentificacaoItemDTO       := {} // Array Of  CotacaoServico_COTACAODTO():New()
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_ArrayOfIdentificacaoItemDTO
	Local oClone := CotacaoServico_ArrayOfIdentificacaoItemDTO():NEW()
	oClone:oWSIdentificacaoItemDTO := NIL
	If ::oWSIdentificacaoItemDTO <> NIL 
		oClone:oWSIdentificacaoItemDTO := {}
		aEval( ::oWSIdentificacaoItemDTO , { |x| aadd( oClone:oWSIdentificacaoItemDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_ArrayOfIdentificacaoItemDTO
	Local cSoap := ""
	aEval( ::oWSIdentificacaoItemDTO , {|x| cSoap := cSoap  +  WSSoapValue("IdentificacaoItemDTO", x , x , "IdentificacaoItemDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap


WSSTRUCT CotacaoServico_IdentificacaoItemDTO
	WSDATA   cSIdItem               AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT CotacaoServico_IdentificacaoItemDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT CotacaoServico_IdentificacaoItemDTO
Return

WSMETHOD CLONE WSCLIENT CotacaoServico_IdentificacaoItemDTO
	Local oClone := CotacaoServico_IdentificacaoItemDTO():NEW()
	oClone:csIdItem         := ::csIdItem
Return oClone

WSMETHOD SOAPSEND WSCLIENT CotacaoServico_IdentificacaoItemDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sIdItem", ::csIdItem, ::csIdItem , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap






