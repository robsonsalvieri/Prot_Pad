#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://qaclic.pta.com.br/Externo_Services/Externo/Fornecedor.svc?wsdl
Gerado em        04/02/14 08:21:28
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

Function _SNPSSKL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSFornecedorServico
------------------------------------------------------------------------------- */
WSCLIENT WSFornecedorServico

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD PesquisarMelhores

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSobjEmpresaLicenciada   AS FornecedorServico_EmpresaLicenciadaDTO
	WSDATA   csIdUsuario               AS string
	WSDATA   oWSlLstCategorias         AS FornecedorServico_ArrayOfCategoriaDTO
	WSDATA   oWSPesquisarMelhoresResult AS FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSFornecedorServico
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.120420A-20120726] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSFornecedorServico
	::oWSobjEmpresaLicenciada := FornecedorServico_EMPRESALICENCIADADTO():New()
	::oWSlLstCategorias  := FornecedorServico_ARRAYOFCATEGORIADTO():New()
	::oWSPesquisarMelhoresResult := FornecedorServico_ARRAYOFRESULTADOPESQUISAFORNECEDORDTO():New()
Return

WSMETHOD RESET WSCLIENT WSFornecedorServico
	::oWSobjEmpresaLicenciada := NIL 
	::csIdUsuario        := NIL 
	::oWSlLstCategorias  := NIL 
	::oWSPesquisarMelhoresResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSFornecedorServico
Local oClone := WSFornecedorServico():New()
	oClone:_URL          := ::_URL 
	oClone:oWSobjEmpresaLicenciada :=  IIF(::oWSobjEmpresaLicenciada = NIL , NIL ,::oWSobjEmpresaLicenciada:Clone() )
	oClone:csIdUsuario   := ::csIdUsuario
	oClone:oWSlLstCategorias :=  IIF(::oWSlLstCategorias = NIL , NIL ,::oWSlLstCategorias:Clone() )
	oClone:oWSPesquisarMelhoresResult :=  IIF(::oWSPesquisarMelhoresResult = NIL , NIL ,::oWSPesquisarMelhoresResult:Clone() )
Return oClone

// WSDL Method PesquisarMelhores of Service WSFornecedorServico

WSMETHOD PesquisarMelhores WSSEND oWSobjEmpresaLicenciada,csIdUsuario,oWSlLstCategorias WSRECEIVE oWSPesquisarMelhoresResult WSCLIENT WSFornecedorServico
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<PesquisarMelhores xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("objEmpresaLicenciada", ::oWSobjEmpresaLicenciada, oWSobjEmpresaLicenciada , "EmpresaLicenciadaDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += WSSoapValue("sIdUsuario", ::csIdUsuario, csIdUsuario , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("lLstCategorias", ::oWSlLstCategorias, oWSlLstCategorias , "ArrayOfCategoriaDTO", .F. , .F., 0 , "http://tempuri.org/", .F.) 
cSoap += "</PesquisarMelhores>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IFornecedor/PesquisarMelhores",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://qaclic.pta.com.br/Externo_Services/Externo/Fornecedor.svc")

::Init()
::oWSPesquisarMelhoresResult:SoapRecv( WSAdvValue( oXmlRet,"_PESQUISARMELHORESRESPONSE:_PESQUISARMELHORESRESULT","ArrayOfResultadoPesquisaFornecedorDTO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure EmpresaLicenciadaDTO

WSSTRUCT FornecedorServico_EmpresaLicenciadaDTO
	WSDATA   csDsEmailContato          AS string OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSDATA   csNrTelefoneContato       AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_EmpresaLicenciadaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_EmpresaLicenciadaDTO
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_EmpresaLicenciadaDTO
	Local oClone := FornecedorServico_EmpresaLicenciadaDTO():NEW()
	oClone:csDsEmailContato     := ::csDsEmailContato
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
	oClone:csNrTelefoneContato  := ::csNrTelefoneContato
Return oClone

WSMETHOD SOAPSEND WSCLIENT FornecedorServico_EmpresaLicenciadaDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sDsEmailContato", ::csDsEmailContato, ::csDsEmailContato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNmRazaoSocial", ::csNmRazaoSocial, ::csNmRazaoSocial , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrCnpj", ::csNrCnpj, ::csNrCnpj , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sNrTelefoneContato", ::csNrTelefoneContato, ::csNrTelefoneContato , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

// WSDL Data Structure ArrayOfCategoriaDTO

WSSTRUCT FornecedorServico_ArrayOfCategoriaDTO
	WSDATA   oWSCategoriaDTO           AS FornecedorServico_CategoriaDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_ArrayOfCategoriaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_ArrayOfCategoriaDTO
	::oWSCategoriaDTO      := {} // Array Of  FornecedorServico_CATEGORIADTO():New()
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_ArrayOfCategoriaDTO
	Local oClone := FornecedorServico_ArrayOfCategoriaDTO():NEW()
	oClone:oWSCategoriaDTO := NIL
	If ::oWSCategoriaDTO <> NIL 
		oClone:oWSCategoriaDTO := {}
		aEval( ::oWSCategoriaDTO , { |x| aadd( oClone:oWSCategoriaDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT FornecedorServico_ArrayOfCategoriaDTO
	Local cSoap := ""
	aEval( ::oWSCategoriaDTO , {|x| cSoap := cSoap  +  WSSoapValue("CategoriaDTO", x , x , "CategoriaDTO", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.)  } ) 
Return cSoap

// WSDL Data Structure ArrayOfResultadoPesquisaFornecedorDTO

WSSTRUCT FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO
	WSDATA   oWSResultadoPesquisaFornecedorDTO AS FornecedorServico_ResultadoPesquisaFornecedorDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO
	::oWSResultadoPesquisaFornecedorDTO := {} // Array Of  FornecedorServico_RESULTADOPESQUISAFORNECEDORDTO():New()
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO
	Local oClone := FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO():NEW()
	oClone:oWSResultadoPesquisaFornecedorDTO := NIL
	If ::oWSResultadoPesquisaFornecedorDTO <> NIL 
		oClone:oWSResultadoPesquisaFornecedorDTO := {}
		aEval( ::oWSResultadoPesquisaFornecedorDTO , { |x| aadd( oClone:oWSResultadoPesquisaFornecedorDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_ArrayOfResultadoPesquisaFornecedorDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_RESULTADOPESQUISAFORNECEDORDTO","ResultadoPesquisaFornecedorDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSResultadoPesquisaFornecedorDTO , FornecedorServico_ResultadoPesquisaFornecedorDTO():New() )
			::oWSResultadoPesquisaFornecedorDTO[len(::oWSResultadoPesquisaFornecedorDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ResultadoPesquisaFornecedorDTO

WSSTRUCT FornecedorServico_ResultadoPesquisaFornecedorDTO
	WSDATA   oWSCategoria              AS FornecedorServico_CategoriaDTO OPTIONAL
	WSDATA   oWSLstFornecedores        AS FornecedorServico_ArrayOfFornecedorDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_ResultadoPesquisaFornecedorDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_ResultadoPesquisaFornecedorDTO
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_ResultadoPesquisaFornecedorDTO
	Local oClone := FornecedorServico_ResultadoPesquisaFornecedorDTO():NEW()
	oClone:oWSCategoria         := IIF(::oWSCategoria = NIL , NIL , ::oWSCategoria:Clone() )
	oClone:oWSLstFornecedores   := IIF(::oWSLstFornecedores = NIL , NIL , ::oWSLstFornecedores:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_ResultadoPesquisaFornecedorDTO
	Local oNode1
	Local oNode2
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CATEGORIA","CategoriaDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSCategoria := FornecedorServico_CategoriaDTO():New()
		::oWSCategoria:SoapRecv(oNode1)
	EndIf
	oNode2 :=  WSAdvValue( oResponse,"_LSTFORNECEDORES","ArrayOfFornecedorDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode2 != NIL
		::oWSLstFornecedores := FornecedorServico_ArrayOfFornecedorDTO():New()
		::oWSLstFornecedores:SoapRecv(oNode2)
	EndIf
Return

// WSDL Data Structure CategoriaDTO

WSSTRUCT FornecedorServico_CategoriaDTO
	WSDATA   csDsCategoria             AS string OPTIONAL
	WSDATA   csIdCategoria             AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_CategoriaDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_CategoriaDTO
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_CategoriaDTO
	Local oClone := FornecedorServico_CategoriaDTO():NEW()
	oClone:csDsCategoria        := ::csDsCategoria
	oClone:csIdCategoria        := ::csIdCategoria
Return oClone

WSMETHOD SOAPSEND WSCLIENT FornecedorServico_CategoriaDTO
	Local cSoap := ""
	cSoap += WSSoapValue("sDsCategoria", ::csDsCategoria, ::csDsCategoria , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
	cSoap += WSSoapValue("sIdCategoria", ::csIdCategoria, ::csIdCategoria , "string", .F. , .F., 0 , "http://schemas.datacontract.org/2004/07/Paradigma.Wbc.Servico.ClicBusiness.DTO.Externo", .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_CategoriaDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::csDsCategoria      :=  WSAdvValue( oResponse,"_SDSCATEGORIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csIdCategoria      :=  WSAdvValue( oResponse,"_SIDCATEGORIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ArrayOfFornecedorDTO

WSSTRUCT FornecedorServico_ArrayOfFornecedorDTO
	WSDATA   oWSFornecedorDTO          AS FornecedorServico_FornecedorDTO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_ArrayOfFornecedorDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_ArrayOfFornecedorDTO
	::oWSFornecedorDTO     := {} // Array Of  FornecedorServico_FORNECEDORDTO():New()
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_ArrayOfFornecedorDTO
	Local oClone := FornecedorServico_ArrayOfFornecedorDTO():NEW()
	oClone:oWSFornecedorDTO := NIL
	If ::oWSFornecedorDTO <> NIL 
		oClone:oWSFornecedorDTO := {}
		aEval( ::oWSFornecedorDTO , { |x| aadd( oClone:oWSFornecedorDTO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_ArrayOfFornecedorDTO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_FORNECEDORDTO","FornecedorDTO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSFornecedorDTO , FornecedorServico_FornecedorDTO():New() )
			::oWSFornecedorDTO[len(::oWSFornecedorDTO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure FornecedorDTO

WSSTRUCT FornecedorServico_FornecedorDTO
	WSDATA   oWSContato                AS FornecedorServico_ContatoDTO OPTIONAL
	WSDATA   ndVlReputacao             AS decimal OPTIONAL
	WSDATA   csNmRazaoSocial           AS string OPTIONAL
	WSDATA   csNrCnpj                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_FornecedorDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_FornecedorDTO
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_FornecedorDTO
	Local oClone := FornecedorServico_FornecedorDTO():NEW()
	oClone:oWSContato           := IIF(::oWSContato = NIL , NIL , ::oWSContato:Clone() )
	oClone:ndVlReputacao        := ::ndVlReputacao
	oClone:csNmRazaoSocial      := ::csNmRazaoSocial
	oClone:csNrCnpj             := ::csNrCnpj
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_FornecedorDTO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_CONTATO","ContatoDTO",NIL,NIL,NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSContato := FornecedorServico_ContatoDTO():New()
		::oWSContato:SoapRecv(oNode1)
	EndIf
	::ndVlReputacao      :=  WSAdvValue( oResponse,"_DVLREPUTACAO","decimal",NIL,NIL,NIL,"N",NIL,NIL) 
	::csNmRazaoSocial    :=  WSAdvValue( oResponse,"_SNMRAZAOSOCIAL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csNrCnpj           :=  WSAdvValue( oResponse,"_SNRCNPJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ContatoDTO

WSSTRUCT FornecedorServico_ContatoDTO
	WSDATA   csDsEmail                 AS string OPTIONAL
	WSDATA   csNmContato               AS string OPTIONAL
	WSDATA   csNrTelefone              AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT FornecedorServico_ContatoDTO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT FornecedorServico_ContatoDTO
Return

WSMETHOD CLONE WSCLIENT FornecedorServico_ContatoDTO
	Local oClone := FornecedorServico_ContatoDTO():NEW()
	oClone:csDsEmail            := ::csDsEmail
	oClone:csNmContato          := ::csNmContato
	oClone:csNrTelefone         := ::csNrTelefone
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT FornecedorServico_ContatoDTO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::csDsEmail          :=  WSAdvValue( oResponse,"_SDSEMAIL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csNmContato        :=  WSAdvValue( oResponse,"_SNMCONTATO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::csNrTelefone       :=  WSAdvValue( oResponse,"_SNRTELEFONE","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


