#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "SHELL.CH"
#Include 'TJurAnxImng.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} Classe de anexos do IManage V2 (WorkSite)

@author Rebeca Facchinato Asunção
@since  26/07/2023
/*/
//-------------------------------------------------------------------
Class TJurAnxIMng From TJurAnexo

	DATA cCustomer
	DATA cClienteLj
	DATA cCaso
	DATA cEntidade
	DATA aRespUpld
	DATA dLastUse
	DATA cJImnToken
	DATA cJImnRfrsh
	DATA oTree
	DATA cGetClie
	DATA cGetLoja
	DATA cAppKey
	DATA cAppSecret
	DATA cServerImg
	DATA cLibrarie
	DATA oModal
	DATA cHost
	DATA lClearCliCaso

	Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, lEntPFS, cAltQry, aExtraEntida) Constructor
	Method Abrir()
	Method Anexar()
	Method Importar(cEntidade)
	Method Download(aDocsSel, lOpen, cTmpDir)
	Method BuscaPastas(lCallPesq)
	Method BuscaDocs()
	Method JIMngAut(lDownload, lLogin)
	Method JIMngGtWrk(lCallPesq)
	Method JIMngGtFldr(cCodDoc, lSetDocs)
	Method JIMngExtDc( cExtensao )
	Method JWksUpload(aPastas, lHtml, cEntidade)
	Method JUploadImn( cTypeDoc, cPathArq, cIdPasta, cNomeArq, cExtensao )
	Method JIMngSendDc(cContent, cTypeDoc, cIdPasta, cNomeArq, cExtensao)
	Method JAnxImngBx(cIdDoc, cNomeArq, lHtml, cDirDestin, cArqZip, cTemp, cSO)
	Method SetCliCaso(cCodCli, cLojaCli, cCasoCli, lLojaAuto)
	Method MostraDocs()
	Method TJAnxClose(lOk)
	Method JIMngoAuth2()
	Method JIMngRcMtt()
	Method JImgnGtDoc(cIdPasta, aResponse)
	Method JImngTipos(cPai, aResponse, lMostraDocs)
	Method JIMngFav(lMostraDocs)
	Method JIMngCateg(cIdCategoria, lMostraDocs)
	Method GetCodDoc(cDoc)
	Method GetTypeDoc(cDoc)
	Method Decode(cText)
	Method GetPrefixDoc(cDoc)
	Method ClearItem(cItem)
	Method GetChildren(cItem, lDoc)
	Method JWImgnVNum(cItem, cDesc)
	Method JIMngRcDoc()
	Method JPrepImng(oDataImgn, cVerbo, cEndPoint, cQueryParams, oBody)
	Method JIMngLogin(cUsuario, cSenha)
	Method JIMngCstmr(lComprDesp)
	Method JReqCstmr()
	Method PesquisaDoc(cPesquisa, cTipo, oGetClie, oGetLoja, oGetCaso)
	Method GetDocsByNameID(cTipo, cPesquisa)
	Method JImngResult(aResponse, cTipo, cPesquisa)
	Method GetDocByName(cTipo, cPesquisa)
	Method GetDocByID(cTipo, cPesquisa)
	Method JImngClCas(cEntidade, cFilEnt, cCodEnt, nIndice)
	Method JImngGroup(oTipo, oPesquisa, lCallPesq)
	Method JWrkChldrn(cIdItem, lSetDocs)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Inicializador / Construtor da Classe

@param  cTitulo      - Título da tela
@param  cEntidade    - Entidade utilizada no anexo
@param  cFilEnt      - Filial da entidade
@param  cCodEnt      - Código da entidade
@param  nIndice      - Índice da entidade utilizado para buscar o XXX_CAJURI
@param  lInterface   - Indica se demonstra a Interface
@param  lEntPFS      - Indica se é uma entidade do SIGAPFS
@param  cAltQry      - Query alternativa a ser utilizada para montar a tela
@param  aExtraEntida - Entidades extra de anexos

@author Rebeca Facchinato Asunção
@since  26/07/2023
/*/
//-------------------------------------------------------------------
Method New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, lEntPFS, cAltQry, aExtraEntida, lComprDesp) Class TJurAnxImng
Local aButtons  := {}
Local aDadosCli := {}

Private cGetClie := ""
Private cGetLoja := ""

Default lInterface := .T.
Default lComprDesp := .F.

	::cEntidade     := cEntidade
	::cClienteLj    := ""
	::cCaso         := ""
	::aRespUpld     := {}
	::dLastUse      := CTOD("  /  /    ")
	::cJImnToken    := ""
	::cJImnRfrsh    := ""
	::cAppKey       := AllTrim(SuperGetMV('MV_JIMNGKY',,''))
	::cAppSecret    := AllTrim(SuperGetMV('MV_JIMNGSC',,''))
	::cServerImg    := AllTrim(SuperGetMV('MV_JGEDSER',,'')) // Server do worksite
	::cLibrarie     := AllTrim(SuperGetMV('MV_JGEDDAN',,'')) // Database (Library)
	::cHost         := "https://" + ::cServerImg
	If Empty(::cCustomer)
		::cCustomer     := ::JIMngCstmr(lComprDesp)
	EndIf
	::lClearCliCaso := .T.

	_Super:New(cTitulo, cEntidade, cFilEnt, cCodEnt, nIndice, lInterface, lEntPFS, cAltQry, aExtraEntida)

	Aadd(aButtons, {STR0001, {|| Processa({|| Self:Abrir()} , STR0002, STR0003, .F.)}, 2}) // "Abrir" // "Aguarde" // "Abrindo arquivos"

	// Busca cliente, loja e caso da entidade
	aDadosCli := ::JImngClCas(cEntidade, cFilEnt, cCodEnt, nIndice)

	If Len(aDadosCli) > 0
		::cClienteLj    := aDadosCli[1] + aDadosCli[2]
		::lClearCliCaso := .F.

		If !(::cEntidade == "NT0")
			::cCaso := aDadosCli[3]
		EndIf
	EndIf

	Aadd(aButtons, {STR0030, {|| Processa({|| Self:Importar(cEntidade)}, STR0002, STR0031, .F.)}, 3}) // "Importar" // "Aguarde" // "Importando arquivo(s) no iManage"
	Aadd(aButtons, {STR0004, {|| Processa({|| Self:Anexar(cEntidade)}  , STR0002, STR0005, .F.)}, 3}) // "Anexar"   // "Aguarde" // "Operação anexar"   
	Aadd(aButtons, {STR0020, {|| Processa({|| Self:Download()}         , STR0002, STR0021, .F.)}, 3}) // "Download" // "Aguarde" // "Fazendo download de arquivo(s)"
	Aadd(aButtons, {STR0028, {|| Processa({|| Self:Excluir()}          , STR0002, STR0029, .F.)}, 5}) // "Excluir"  // "Aguarde" // "Excluindo o(s) arquivo(s)"

	Self:SetButton(aButtons)
	Self:SetShowUrl(.T.)

	If lInterface
		Self:Activate()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Abrir
Abre um documento no iManage (Worksite)

@author Rebeca Facchinato Asunção
@since  26/07/2023
/*/
//-------------------------------------------------------------------
Method Abrir() Class TJurAnxImng
Local cIdDocument := ""
Local cFile       := ""
Local cDataBase   := ""
Local cFullUrl    := ""
Local cUrl        := "https://" + ::cServerImg + "/work/link/d/"
Local nDocs       := 0
Local nI          := 0
Local aDocsSel    := {}
Local aCommand    := {}

	aDocsSel := Self:GetRegSelecionado()
	If Len(aDocsSel) > 0

		For nDocs := 1 to Len(aDocsSel)
			cFile    := AllTrim(aDocsSel[nDocs][4])
			aCommand := StrToKArr(cFile, "!")

			For nI := 1 to Len(aCommand)
				If (At("database:", aCommand[nI] ) > 0) // Nome da database para o documento
					cDatabase := StrToKArr(aCommand[nI], ':')[2]
				ElseIf (At("document:", aCommand[nI] )) // Id do documento
					cIdDocument := StrTran(StrToKArr(aCommand[nI], ':')[2],",",".")
				EndIf
			Next nI

			cFullUrl := cUrl + cDatabase + '!' + cIdDocument

			Self:SetDocumento(cFullUrl)
			_Super:Abrir()
		Next
	Else
		JurMsgErro(STR0006) // "Selecione um arquivo para abrir."
	EndIf

	aSize(aDocsSel, 0)
	aSize(aCommand, 0)
	aDocsSel := Nil
	aCommand := Nil

Return cFullUrl

//-------------------------------------------------------------------
/*/{Protheus.doc} Importar
Importa um documento no IManage (Worksite)

@param cEntidade - Indica a entidade para o anexo
@return .T.
@author Rebeca Facchinato Asunção
@since  26/07/2023
/*/
//-------------------------------------------------------------------
Method Importar(cEntidade) Class TJurAnxImng
Local oDlgTree   := Nil
Local oTela      := Nil
Local oGetClie   := Nil
Local oGetLoja   := Nil
Local oGetCaso   := Nil
Local oMain      := Nil
Local lOk        := .T.
Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cNumCaso   := SuperGetMV('MV_JCASO1',, '1') // 1 = Depende do Cliente; 2 = Independente de Cliente
Local cNVE       := SPACE(GetSX3Cache("NVE_NUMCAS", "X3_TAMANHO"))
Local nLocCas    := 100

	::cGetClie := Criavar('NVE_CCLIEN', .F.)
	::cGetLoja := Criavar('NVE_LCLIEN', .F.)

	If !Empty(::cAppKey) .AND. !Empty(::cAppSecret)
		If Empty(::cJImnToken)
			::JIMngAut() // Autenticação
		EndIf

		If !Empty(::cJImnToken)

			// Criar a tela para seleção de pasta onde irá fazer o upload do arquivo
			oTela  := FWFormContainer():New( oDlgTree )
			::oModal := FWDialogModal():New()
			::oModal:SetFreeArea(420,180)
			::oModal:SetEscClose(.T.)
			::oModal:SetTitle(STR0030 + " - " + STR0009 ) // "Importar" / "Selecione onde o arquivo deverá ser salvo"
			::oModal:createDialog()
			::oModal:addOkButton({|| lOk := ::JWksUpload(::oTree:CurrentNodeID, GetRemoteType() == 5, cEntidade), ::TJAnxClose(lOk) })
			::oModal:addCloseButton({|| ::TJAnxClose(.T.) })

			oMain := ::oModal:GetPanelMain()
			oPSearch := TPanel():Create(oMain,02,,,,,,,/*CLR_RED*/,,40)
			oPSearch:Align := CONTROL_ALIGN_TOP
			oPGrid := TPanel():Create(oMain,02,,,,,,,/*CLR_BLUE*/)
			oPGrid:Align := CONTROL_ALIGN_ALLCLIENT

			If !(::cEntidade == "NT0") .AND. Empty(::cClienteLj)

				oGetClie := TJurPnlCampo():New(008, 020, 050, 022, oPSearch, ,'NUE_CCLIEN', {|| }, {|| }, ::cGetClie, Nil, Nil, 'SA1NUH') // "Cliente"
				oGetClie:SetValid( {|| setDadosCliente(oGetClie:GetValue(), oGetLoja:GetValue(), lLojaAuto), JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "CLI") })

				oGetLoja := TJurPnlCampo():New(008, 070, 030, 022, oPSearch, ,'NVE_LCLIEN', {|| }, {|| }, ::cGetLoja) // "Loja"
				oGetLoja:SetValid( {|| setDadosCliente(oGetClie:GetValue(), oGetLoja:GetValue(), lLojaAuto), JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "LOJ") })
				oGetLoja:Visible(!lLojaAuto)

				If lLojaAuto
					nLocCas := 70
				EndIf

				oGetCaso := TJurPnlCampo():New(008, nLocCas, 040, 022, oPSearch, ,'NUE_CCASO', {|| }, {|| }, cNVE, Nil, Nil, 'NVENX0') // "Caso"
				oGetCaso:SetValid({|| JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "CAS") })
				oGetCaso:SetWhen( {|| (cNumCaso == '2') .Or. (!Empty(oGetLoja:GetValue()) .And. !Empty(oGetClie:GetValue())) } )

				@ 017,150 Button oBtnPesq Prompt STR0057 Size 065, 012 PIXEL OF oPSearch  Action ( ) // "Pesquisar caso/assunto"
				oBtnPesq:bAction  := {|| Processa({|| lOk := ::SetCliCaso(oGetClie:GetValue(), oGetLoja:GetValue(), oGetCaso:GetValue(), lLojaAuto) },;
										STR0002, STR0023, .F.), ::BuscaPastas(.T.)} // "Aguarde ..." / "Buscando pastas ..."
			EndIf

			::oTree := TTree():New( 0, 0, 0, 0, oPGrid,,)
			::oTree:Align      := CONTROL_ALIGN_ALLCLIENT
			::oTree:BCHANGE    := {||}
			::oTree:BLDBLCLICK := {|| ::GetChildren(::oTree:CurrentNodeID,.F.)}

			If !Empty(::cJImnToken)
				Self:BuscaPastas()
				::oTree:SetFocus()
				::oModal:activate()

				If ::lClearCliCaso
					::cClienteLj := ""
				EndIf
				::oModal:DeActivate()
			EndIf

		Else
			JurMsgErro(STR0038) // "Não foi possível realizar a autenticação no iManage!"
		EndIf
	Else
		JurMsgErro(STR0007) // "Necessário preencher os parâmetros MV_JIMNGKY e MV_JIMNGSC para realizar a operação. Verifique!"
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaPastas
Busca a estrutura de pastas e workspaces para o usuário selecionar
onde será realizado o upload

@param  lCallPesq - Indica se a chamada á da pesquisa
@return .T.
@author Rebeca Facchinato Asunção
@since  21/08/2023
/*/
//-------------------------------------------------------------------
Method BuscaPastas(lCallPesq) Class TJurAnxImng

Default lCallPesq := .F.

	::oTree:BeginUpdate()
	::oTree:PTReset()

	If !Empty(::cClienteLj)
		::JIMngGtWrk(lCallPesq) // Casos/Assuntos filtrados por cliente/caso
	EndIf

	::JIMngFav(.F.) // Favoritos

	::oTree:PTSendNodes()
	::oTree:EndUpdate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngGtWrk
Responsável por realizar a busca de workspaces (Matters)

@param  lCallPesq - Indica se a chamada é feita a partir da pesquisa
@return Nil
@author Rebeca Facchinato Asunção
@since  22/08/2023
/*/
//-------------------------------------------------------------------
Method JIMngGtWrk(lCallPesq) Class TJurAnxImng
Local cCampoCli  := AllTrim(SuperGetMV('MV_JNRCCLI',,'')) // Campo para filtro de cliente
Local cCampoCaso := AllTrim(SuperGetMV('MV_JNRCCAS',,'')) // Campo para filtro de caso
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/workspaces?"
Local aHeader    := {"X-Auth-Token: " + ::cJImnToken}
Local aResponse  := {}
Local oResponse  := Nil
Local oRequest   := FWRest():New(::cHost + "/api")
Local nI         := 0

Default lCallPesq := .F.

	// Remove item antes de fazer a busca
	::ClearItem(StrZero(3,7), STR0037) // "Casos/Assuntos"

	If !Empty(cCampoCli)
		cEndPoint += cCampoCli + "=" + Alltrim(::cClienteLj)
	Else
		cEndPoint += "custom1=" + Alltrim(::cClienteLj)
	EndIf

	If !(::cEntidade == "NT0")
		// Envia o caso com e sem zeros a esquerda para filtrar
		If !Empty(cCampoCaso)
			cEndPoint += "&" + cCampoCaso + "=" + ::cCaso + "," + CVALTOCHAR(VAL(::cCaso))
		Else
			cEndPoint += "&custom2=" + ::cCaso + "," + CVALTOCHAR(VAL(::cCaso))
		EndIf
	EndIf

	oRequest:SetPath(cEndPoint)

	If oRequest:Get(aHeader)
		oResponse := JsonObject():New()
		oResponse:fromJson(oRequest:GetResult())

		If VALTYPE(oResponse) <> "U" .And. Len(oResponse['data']['results']) > 0
			aResponse := aClone(oResponse['data']['results'])

			If Len(aResponse) > 0
				// Agrupamento de assuntos
				::oTree:PTAddNodes( StrZero(0,7), StrZero(3,7), "", STR0037, "HISTORIC", "HISTORIC" ) // Casos/Assuntos
			EndIf

			For nI := 1 to Len(aResponse)
				::oTree:PTAddNodes( StrZero(3,7), "AW:" + aResponse[nI]['wstype'] + "|" + aResponse[nI]['id'], "",;
										::Decode(aResponse[nI]['name']), "HISTORIC", "HISTORIC" )
			Next nI
		Else
			If lCallPesq
				::oTree:PTAddNodes( StrZero(0,7), StrZero(3,7), "", STR0037 + " - " + STR0050, "HISTORIC", "HISTORIC" ) //  "Casos/Assuntos" / "A pesquisa não retornou dados"
			Else
				::oTree:PTAddNodes( StrZero(0,7), StrZero(3,7), "", STR0037 + " - " + STR0058, "HISTORIC", "HISTORIC" ) // "Casos/Assuntos" - "Não foram encontrados itens para o cliente/caso"
			EndIf
		EndIf

	Else
		// Verifica se o token de acesso expirou
		If "UNAUTHORIZED" $ UPPER(oRequest:GetLastError())
			::JIMngoAuth2(.T.) // Faz o refresh token
			::JIMngGtWrk(lCallPesq) // Busca as pastas novamente
		EndIf
	EndIf

	aSize(aResponse, 0)
	aSize(aHeader, 0)
	aResponse := Nil
	aHeader   := Nil
	oRequest  := Nil
	oResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngGtFldr
Obtem as folders (pastas)

@param  cCodDoc    - ID da pasta no IManage
@param  lSetDocs   - Indica se deverá buscar e mostrar os documentos na árvore
@return Nil
@author Rebeca Facchinato Asunção
@since  22/08/2023
/*/
//-------------------------------------------------------------------
Method JIMngGtFldr(cCodDoc, lSetDocs) Class TJurAnxImng
Local cEndPoint  := ""
Local aResponse  := {}
Local nX         := 0
Local nI         := 0

Default lSetDocs   := .F.

	If Left(::oTree:PTGetPrompt(), 1) == ">" // Verifica se já clicou 2 x no item
		Return Nil
	EndIf

	cEndPoint := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/folders/" + ::GetCodDoc(cCodDoc) + "/children"
	aResponse := ::JPrepImng("GET", cEndPoint)

	If Len(aResponse) > 0
		::oTree:PTChangePrompt(">" + ::oTree:PTGetPrompt(),cCodDoc)
	EndIf

	For nI := 1 To Len(aResponse)

		If VALTYPE(aResponse[nI]) <> "O"
			If aScan(aResponse[nI]['data'], {|x| x['wstype'] == "folder" }) == 0
				::oTree:PTChangeBmp("FOLDER7","FOLDER7",cCodDoc) // Troca o icone para pasta vermelha quando não tem pastas filhas
			EndIf
			// Segundo nível - Folders (Pastas da workspace)
			For nX := 1 To Len(aResponse[nI]['data'])
				If aResponse[nI]['data'][nX]['wstype'] == "folder"
					::oTree:PTAddNodes( cCodDoc, ::GetPrefixDoc(cCodDoc) + ":" + aResponse[nI]['data'][nX]['wstype'] +;
								"|" + aResponse[nI]['data'][nX]['id'],"", ::Decode(aResponse[nI]['data'][nX]['name']),;
								"FOLDER5", "FOLDER6" )
				EndIf
			Next nX
			// Seta os documentos
			If lSetDocs
				::JImgnGtDoc(cCodDoc, aResponse[nI]['data'])
			EndIf

		Else
			// Verifica se o token de acesso expirou
			If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()
				::JIMngoAuth2(.T.) // Faz o refresh token
				::JIMngGtFldr(cCodDoc, lSetDocs)
			EndIf
		EndIf
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JWksUpload
Seleção de arquivo para fazer upload

@param  cPasta    - Id do item selecionado pelo usuário
@param  lHtml     - Indica se está executando via webApp
@param  cEntidade - Entidade do anexo
@return lRet      - Indica se o upload foi realizado com sucesso
@author Rebeca Facchinato Asunção
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Method JWksUpload(cPasta, lHtml, cEntidade) Class TJurAnxIMng
local aListArq    := {}
Local cPath       := "C:\"
Local cArquivos   := ""
Local cExtensao   := ""
Local cTypeDoc    := ""
Local cNomeArq    := ""
Local nI          := 0
Local lRet        := .F.

	If !Empty(cPasta) .AND. Substr(cPasta, 2, 1) == "F" .AND. !("workspace" $ cPasta) // Verifica se foi selecionado um item do tipo pasta

		cArquivos := cGetFile(STR0012 + "|*.*", STR0013, , cPath, .F., nOr(GETF_LOCALHARD, GETF_NETWORKDRIVE), ,.F.) // "Todos os arquivos" // "Seleção de arquivo"

		If lHtml
			cArquivos := StrTran(cArquivos, "servidor\", "")
		EndIf

		aListArq := StrTokArr2(cArquivos, " | ")

		For nI := 1 to Len(aListArq)
			cExtensao := SubStr(aListArq[nI], Rat(".", aListArq[nI]) + 1 , Rat(".", aListArq[nI]) )

			// Faz o get para encontrar alias do tipo do arquivo (de acordo com a extensão do arquivo selecionado)
			cTypeDoc := ::JIMngExtDc(cExtensao)
			cNomeArq := SubStr(aListArq[nI], Rat("\", aListArq[nI]) + 1) // Extrai nome do arquivo
			cNomeArq := SubStr(cNomeArq, 1, Rat(".", cNomeArq ) - 1)    // Remove extensão

			// Prepara requisição POST para upload 
			lRet := ::JUploadImn(cTypeDoc, aListArq[nI], ::GetCodDoc(cPasta), cNomeArq, cExtensao)
		Next nI
	Else
		lRet := JurMsgErro(STR0027, , , .F.) // "Selecione uma pasta para prosseguir com a operação."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngExtDc
Busca o alias do tipo do arquivo cadastrado previamente no IManage

@param  cExtensao - Extensão do arquivo selecionado
@return cType     - Alias do tipo do arquivo
@author Rebeca Facchinato Asunção
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Method JIMngExtDc( cExtensao ) Class TJurAnxImng
Local cType      := ""
Local cEndPoint  := ""
Local aResponse  := {}
Local nX         := 0
Local nI         := 0

Default cExtensao := ""

	If !Empty(cExtensao)
		cEndPoint := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/types"

		aResponse := ::JPrepImng("GET", cEndPoint,,,,,,,"&app_extension=" + cExtensao)

		For nI := 1 To Len(aResponse)

			If VALTYPE(aResponse[nI]) <> "O"
				For nX := 1 To Len(aResponse[nI]['data'])
					cType := aResponse[nI]['data'][nX]['id']
					Exit
				Next nX
			Else
				// Verifica se o token de acesso expirou
				If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()
					::JIMngoAuth2(.T.) // Faz o refresh token
					cType := ::JIMngExtDc( cExtensao )
				EndIf
			EndIf
		Next nI

		aSize(aResponse, 0)
		aResponse := Nil
	EndIf

Return cType

//-------------------------------------------------------------------
/*/{Protheus.doc} JUploadImn
Obtem o conteudo do arquivo e chama o upload

@param  cTypeDoc  - Alias to tipo de arquivo selecionado
@param  cPathArq  - Caminho do arquivo selecionado
@param  cIdPasta  - ID da pasta selecionada
@param  cNomeArq  - Nome do arquivo selecionado
@param  cExtensao - Extensão do arquivo selecionado
@return lRet      - Indica se o upload foi realizado
@author Rebeca Facchinato Asunção
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Method JUploadImn( cTypeDoc, cPathArq, cIdPasta, cNomeArq, cExtensao ) Class TJurAnxIMng
Local cContent := ""
Local lRet     := .F.

	// Obtem o conteúdo do arquivo
	cContent := JContentDocImn( cTypeDoc, cPathArq )

	// Realiza a requisição POST de Upload
	::JIMngSendDc(cContent, cTypeDoc, cIdPasta, cNomeArq, cExtensao)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JContentDocImn
Obtem o conteúdo do arquivo

@param  cTypeDoc - Alias to tipo de arquivo selecionado
@param  cPathArq - Caminho do arquivo selecionado
@return cResult  - Conteúdo extraído do arquivo
@author Rebeca Facchinato Asunção
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Static Function JContentDocImn( cTypeDoc, cPathArq )
Local cBuffer := ""
Local cResult := ""
Local nHandle := 0
Local nBytes  := 0

	nHandle := FOPEN(cPathArq)  // Grava o ID do arquivo
	If nHandle > -1
		While (nBytes := FREAD(nHandle, @cBuffer, 524288)) > 0  // Lê os bytes
			cResult += cBuffer
		EndDo

		FCLOSE(nHandle)
	EndIf

Return cResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngSendDc
Realiza a requisição de upload

@param  cContent  - Conteúdo do arquivo
@param  cTypeDoc  - Alias to tipo de arquivo
@param  cIdPasta  - ID da pasta
@param  cNomeArq  - Nome do arquivo
@param  cExtensao - Extensão do arquivo
@return Nil
@author Rebeca Facchinato Asunção
@since  01/09/2023
/*/
//-------------------------------------------------------------------
Method JIMngSendDc(cContent, cTypeDoc, cIdPasta, cNomeArq, cExtensao) Class TJurAnxIMng
Local cEndPoint  := ""
Local cBody      := ""
Local cBoundary  := "----WebKitFormBoundaryFbmu0bODj7UvfQEV"
Local cNumero    := ""
Local cDoc       := ""
Local cDescFile  := ""
Local aHeader    := {}
Local lRet       := .T.

Default cExtensao := ""

	If !Empty(cTypeDoc)

		If !Empty(cExtensao)

			If VALTYPE( EncodeUTF8(cNomeArq) ) <> "U"
				cNomeArq := EncodeUTF8(cNomeArq)
			EndIf

			cEndPoint := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/folders/" + cIdPasta + "/documents"
			aHeader   := {"X-Auth-Token: " + ::cJImnToken,; 
							"User-Agent: Mozilla/4.0 (compatible; Protheus " + GetBuild() + ")",;
							"Content-Type: multipart/form-data; boundary=" + cBoundary}

			// O Key precisa sempre ter duas quebras de linhas e o value uma quebra
			cBody += '--' + cBoundary + CRLF
			cBody += 'Content-Type: application/json; name="profile"; ' + CRLF + CRLF
			cBody += ' { '
			cBody +=     ' "doc_profile": { '
			cBody +=         ' "name": "' + cNomeArq + '", '
			cBody +=         ' "type": "' + cTypeDoc + '" '
			cBody +=     ' }, '
			cBody +=     ' "warnings_for_required_and_disabled_fields": true '
			cBody += ' }' + CRLF
			cBody += '--' + cBoundary + CRLF
			cBody += 'Content-Disposition: form-data; name="file"; filename="\' + cNomeArq + "."  + cExtensao + '" ' + CRLF
			cBody += 'Content-Type: text/plain' + CRLF + CRLF
			cBody += cContent + CRLF
			cBody += '--' + cBoundary + '--'

			aResponse := ::JPrepImng("POST", cEndPoint,,,,,,aHeader,,cBody)

			If ValType(aResponse[1]) <> "O"
				cNumero   := cValToChar(aResponse[1]['data']['document_number'])
				cDoc      := "!nrtdms:0:!session:" + ::cServerImg + ":!database:" + ::cLibrarie + ":!document:" +;
									cValToChar(aResponse[1]['data']['document_number']) + "," + cValToChar(aResponse[1]['data']['version']) + ":"
				cDescFile := cNomeArq
				cExtensao := cExtensao
				cDesc := ::Decode(cDescFile)
				lRet := Self:GravaNUM(cNumero, cDoc, cDesc, cExtensao)
				If Self:lInterface
					Self:AtualizaGrid()
					If lRet
						ApMsgInfo(STR0032) // "Documento importado com sucesso!"
					EndIf
					Self:TJAnxClose(.T.)
				EndIf

			Else
				// Verifica se o token de acesso expirou
				If "UNAUTHORIZED" $ aResponse[1]:GetLastError()
					::JIMngoAuth2(.T.) // Faz o refresh token
					::JIMngSendDc(cContent, cTypeDoc, cIdPasta, cNomeArq, cExtensao)
				ElseIf !Empty(aResponse[1]['cresult'])
					JurMsgErro(STR0040 + aResponse[1]['cresult']) // "Erro de importação de arquivo: "
				EndIf
			EndIf
		EndIf
	Else
		JurMsgErro(STR0014) // "O tipo de arquivo selecionado não possui configuração para upload. Verifique os tipos configurados no Control center do IManage."
	EndIf

	aSize(aHeader, 0)
	aHeader  := Nil
	cContent := ""

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Download
Permite que o usuário baixe o arquivo na máquina local

@param  aDocsSel - Array com dados do doc selecionado
@param  lOpen    - Abertura da tela para selecação dos arquivos
@param  cTmpDir  - Diretório temporário
@return .T.
@author Rebeca Facchinato Asunção
@since  20/10/2023
/*/
//-------------------------------------------------------------------
Method Download(aDocsSel, lOpen, cTmpDir) Class TJurAnxImng
Local cIdDocument := ""
Local cNomeArq    := ""
Local cFile       := ""
Local cLib        := ""
Local cArqZip     := ""
Local nI          := 0
Local nDocs       := 0
Local lHtml       := (GetRemoteType(@cLib) == 5 .OR. "HTML" $ cLib) .or. !lOpen
Local cSO         := GetSrvInfo()[2]
Local cTemp       := JRepDirSO(GetTempPath(), cSO)

Default aDocsSel := Self:GetRegSelecionado()
Default lOpen    := .T.
Default cTmpDir  := ""

	If Empty(::cJImnToken)
		::JIMngAut(.T., lOpen) // Autenticação
	EndIf

	If Len(aDocsSel) > 0
		For nDocs := 1 to Len(aDocsSel)
			cFile    := AllTrim(aDocsSel[nDocs][4])
			aCommand := StrToKArr(cFile, "!")
			cNomeArq := AllTrim(aDocsSel[nDocs][3]) // NUM_NUMERO

			For nI := 1 to Len(aCommand)
				If (At("document:", aCommand[nI] )) // Id do documento
					cIdDocument := StrTran(StrToKArr(aCommand[nI], ':')[2],",",".")

					// Baixa arquivo no iManage
					::JAnxImngBx(cIdDocument, cNomeArq + "." + AllTrim(aDocsSel[nDocs][5]), lHtml, cTmpDir, @cArqZip, cTemp, cSO)
					If lOpen
						_Super:SetDocumento(cTemp + cNomeArq + "." + AllTrim(aDocsSel[nDocs][5]))
						_Super:Abrir()

						If !Empty(cArqZip) .AND. Upper("spool") $ Upper(cArqZip)
							FErase(cArqZip) // Apaga o arquivo
						EndIf
					Endif

				EndIf
			Next nI
		Next nDocs
	Else
		JurMsgErro(STR0024) // "Selecione um arquivo para realizar o download."
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnxImngBx
Permite que o usuário baixe o arquivo na máquina local

@param cIdDoc     - ID do documento
@param cNomeArq   - Nome do arquivo
@param lHtml      - Indica se esta usando smirtclient html
@param cDirDestin - Diretório de destino
@param cArqZip    - Diretório onde gravou o arquivo + nome do arquivo
@param cTemp      - Caminho da pasta temporária do usuário
@param cSO        - Sistema Operacional utilizado pelo usuário
@return .T.
@author Rebeca Facchinato Asunção
@since  20/10/2023
/*/
//-------------------------------------------------------------------
Method JAnxImngBx(cIdDoc, cNomeArq, lHtml, cDirDestin, cArqZip, cTemp, cSO) Class TJurAnxIMng
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/documents/" + ::cLibrarie + "!" + cIdDoc + "/download?activity=export&latest=true"
Local cSpool     := JRepDirSO("\spool\", cSO)
Local cArquivo   := ""
Local nHandle    := -1
Local lRet       := .F.
Local aResponse  := {}

Default cIdDoc     := ""
Default cNomeArq   := ""
Default lHtml      := .F.
Default cDirDestin := ""
Default cArqZip    := ""
Default cTemp      := ""
Default cSO        := GetSrvInfo()[2]

	If !Empty(cIdDoc) .AND. !Empty(cNomeArq)
		cNomeArq := JRepDirSO(cNomeArq, cSO)

			aResponse := ::JPrepImng("GET", cEndPoint,,,,,.F.)

			If ValType(aResponse[1]) <> "O"
				cArquivo := aResponse[1]

				If Empty(cDirDestin)
					If lHtml
						cDirDestin  := cSpool
					Else
						cDirDestin := cGetFile(STR0012 + "|*.*", STR0025, 0, ; // "Todos os arquivos" // "Selecione uma pasta"
												JRepDirSO("C:\", cSO), .F., nOr(GETF_LOCALHARD,GETF_RETDIRECTORY), .F.)
					EndIf
				EndIf

				// Grava arquivo no servidor
				If !Empty(cArquivo) .AND. (nHandle := FCreate(cDirDestin + cNomeArq, FC_NORMAL)) >= 0
					If lRet := FWrite(nHandle, cArquivo) >= Len(cArquivo)
						Fclose(nHandle)

						// Copia para pasta selecionada pelo usuário ou caminho definido
						If lRet := __copyfile(cDirDestin + cNomeArq, cTemp + cNomeArq)
							cArqZip := cDirDestin + cNomeArq
						EndIf
					EndIf
				EndIf

			Else
				// Verifica se o token de acesso expirou
				If "UNAUTHORIZED" $ aResponse[1]:GetLastError()
					::JIMngoAuth2(.T.) // Faz o refresh token
					::JAnxImngBx(cIdDoc, cNomeArq, lHtml, cDirDestin, cArqZip, cTemp, cSO)
				EndIf
			EndIf
	EndIf

	cArquivo := ""
	aSize(aResponse, 0)
	aResponse := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} SetCliCaso
Seta cliente e caso

@param  cCodCli   - Código do cliente
@param  cLojaCli  - Loja do cliente
@param  cCasoCli  - Caso
@param  lLojaAuto - Indica se o ambiente usa loja automática
@return .T.
@author Rebeca Facchinato Asunção
@since  01/11/2023
/*/
//-------------------------------------------------------------------
Method SetCliCaso(cCodCli, cLojaCli, cCasoCli, lLojaAuto) class TJurAnxIMng
	::cClienteLj := cCodCli
	::cCaso      := cCasoCli

	If !lLojaAuto
		::cClienteLj += cLojaCli
	EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TJAnxClose()
Fecha a tela de seleção

@param lOk  - Indica se irá fechar a tela de seleção
@return .F.
@author Rebeca Facchinato Asunção
@since  07/11/2023
/*/
//-------------------------------------------------------------------
Method TJAnxClose(lOk) Class TJurAnxImng

	If lOk
		::oTree:PtReset()
		::oModal:oOwner:End()
	EndIf

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngoAuth2
Realiza autenticação com oAuth 2.0

@param lRefresh - Indica se foi chamada para realizar refresh do token
@return .T.
@author Rebeca Facchinato Asunção
@since  14/11/2023
/*/
//-------------------------------------------------------------------
Method JIMngoAuth2(lRefresh) Class TJurAnxImng
Local oAuth      := Nil

Default lRefresh := .F.

	oAuth := JoAuth2IManage():New(::cAppKey, ::cAppSecret)
	oAuth:SetScopes({"user"})

	If Empty(::cJImnToken) .OR. lRefresh
		oAuth:Access("") // Chamada para autenticar e obter o token

		::cJImnToken := oAuth:GetToken()
		::cJImnRfrsh := oAuth:cTokenRefresh
	EndIf

	oAuth:Destroy()
	FreeObj(oAuth)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngAut
Verifica se a autenticação serão via oAuth 2.0 ou sem se será via 
password

@param lDownload - Indica se a chamada é da operação de Download
@param lLogin    - Indica se o se o login já foi autenticado
@return .T.
@author Rebeca Facchinato Asunção
@since  14/11/2023
/*/
//-------------------------------------------------------------------
Method JIMngAut(lDownload, lLogin)  Class TJurAnxImng
Local cUsuario := AllTrim(SuperGetMV('MV_JUSREXT',,''))  // Login do Imanage - Usuário externo
Local cSenha   := AllTrim(SuperGetMV('MV_JPWDEXT',,''))  // Senha do Imanage - Usuário externo

Default lDownload := .F.
Default lLogin    := .T.

	If lDownload .AND. !lLogin .AND. !Empty(cUsuario) .AND. !Empty(cSenha)
		::JIMngLogin(cUsuario, cSenha) // Realiza login via password
	Else
		::JIMngoAuth2() // Realiza login via oAuth 2.0
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Anexar
Vincula um anexo do iManage a um registro do Protheus (NUM)

@return .T.
@author Rebeca Facchinato Asunção
@since  26/07/2023
/*/
//-------------------------------------------------------------------
Method Anexar() Class TJurAnxImng

	If !Empty(::cAppKey) .AND. !Empty(::cAppSecret)

		If Empty(::cJImnToken)
			::JIMngAut() // Autenticação
		EndIf

		If !Empty(::cJImnToken)
			Self:BuscaDocs()
		Else
			JurMsgErro(STR0038) // "Não foi possível realizar a autenticação no iManage!"
		EndIf
	Else
		JurMsgErro(STR0007) // "Necessário preencher os parâmetros MV_JIMNGKY e MV_JIMNGSC para realizar a operação. Verifique!"
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaDocs
Busca assuntos (Matters), pastas (Folders) e documentos, recentes e 
favoritos

@return .T.
@author Rebeca Facchinato Asunção
@since  14/02/2024
/*/
//-------------------------------------------------------------------
Method BuscaDocs() Class TJurAnxImng
Local oMain     := Nil
Local oPesquisa := Nil
Local oBtnPesq  := Nil
Local oTipo     := Nil
Local oGetClie  := Nil
Local oGetLoja  := Nil
Local oGetCaso  := Nil
Local oPSearch  := Nil
Local lOk       := .T.
Local lLojaAuto := SuperGetMv("MV_JLOJAUT", .F., "2",) == '1' // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cNumCaso  := SuperGetMV('MV_JCASO1',, '1') // 1 = Depende do Cliente; 2 = Independente de Cliente
Local cNVE      := SPACE(GetSX3Cache("NVE_NUMCAS", "X3_TAMANHO"))
Local cPesquisa := SPACE(GetSX3Cache("NUM_DESC  ", "X3_TAMANHO"))
Local nLocCas   := 100
Local nAltFiltr := 60

	::cGetClie := Criavar('NVE_CCLIEN', .F.)
	::cGetLoja := Criavar('NVE_LCLIEN', .F.)

	::oModal := FWDialogModal():New()
	::oModal:SetFreeArea(450,180)
	::oModal:SetEscClose(.T.)
	::oModal:SetTitle(STR0004 + " - " + STR0035) // "Anexar" / "Selecione um arquivo para anexar ao registro"
	::oModal:createDialog()
	::oModal:addOkButton({|| lOk := ::JWImgnVNum(::oTree:CurrentNodeID, ::oTree:PTGetPrompt()), ::TJAnxClose(lOk) })
	::oModal:addCloseButton({|| ::TJAnxClose(.T.)})

	If !Empty(::cClienteLj)
		nAltFiltr := 30
	EndIf

	oMain := ::oModal:GetPanelMain()
	oPSearch := TPanel():Create(oMain,10,,,,,,,/*CLR_RED*/,,nAltFiltr)
	oPSearch:Align := CONTROL_ALIGN_TOP
	oPGrid := TPanel():Create(oMain,30,,,,,,,/*CLR_BLUE*/)
	oPGrid:Align := CONTROL_ALIGN_ALLCLIENT

	// Campo de pesquisa
	oPesquisa := TJurPnlCampo():New(005,010,130,022,oPSearch,STR0041,,{|| },{|| },cPesquisa) // "Pesquisar documento: "
	oTipo     := TJurPnlCampo():New(005,150,060,025, oPSearch, STR0043,"", {|| },,,,,,, (STR0044 + ";" + STR0045) ) // "Tipo de filtro: " / "Nome" / "Número"
	oTipo:SetValue(STR0044) // Inicializa o campo com o tipo de filtro // Nome

	@ 015,220 Button oBtnPesq Prompt STR0042 Size 060, 012 PIXEL OF oPSearch  Action ( ) // "Pesquisar documento"
		oBtnPesq:bAction := {|| Processa({|| lOk := ::PesquisaDoc(oPesquisa:GetValue(), oTipo:GetValue(), @oGetClie, @oGetLoja, @oGetCaso)},;
									STR0002, STR0046, .F.)} // "Aguarde ..." / "Buscando documentos ..."

	If !(::cEntidade == "NT0") .AND. Empty(::cClienteLj)
		oGetClie := TJurPnlCampo():New(030, 010, 050, 022, oPSearch, ,'NUE_CCLIEN', {|| }, {|| }, ::cGetClie, Nil, Nil, 'SA1NUH') // "Cliente"
		oGetClie:SetValid( {|| setDadosCliente(oGetClie:GetValue(), oGetLoja:GetValue(), lLojaAuto),;
								JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "CLI") })

		oGetLoja := TJurPnlCampo():New(030, 060, 030, 022, oPSearch, ,'NVE_LCLIEN', {|| }, {|| }, ::cGetLoja) // "Loja"
		oGetLoja:SetValid( {|| setDadosCliente(oGetClie:GetValue(), oGetLoja:GetValue(), lLojaAuto), ;
								JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "LOJ") })
		oGetLoja:Visible(!lLojaAuto)

		If lLojaAuto
			nLocCas := 60
		EndIf

		oGetCaso := TJurPnlCampo():New(030, nLocCas, 040, 022, oPSearch, ,'NUE_CCASO', {|| }, {|| }, cNVE, Nil, Nil, 'NVENX0') // "Caso"
		oGetCaso:SetValid({|| JurTrgGCLC( , , @oGetClie, @::cGetClie, @oGetLoja, @::cGetLoja, @oGetCaso, , "CAS") })
		oGetCaso:SetWhen( {|| (cNumCaso == '2') .Or. (!Empty(oGetLoja:GetValue()) .And. !Empty(oGetClie:GetValue())) } )

		@ 040,150 Button oBtnPesq Prompt STR0057 Size 065, 012 PIXEL OF oPSearch  Action ( ) // "Pesquisar assunto"
		oBtnPesq:bAction  := {|| Processa({|| lOk := ::SetCliCaso(oGetClie:GetValue(), oGetLoja:GetValue(), oGetCaso:GetValue(), lLojaAuto) },;
								STR0002, STR0023, .F.), ::JImngGroup(oTipo, @oPesquisa, .T.)} // "Aguarde ..." / "Buscando pastas ..."
	EndIf

	::oTree := TTree():New( 0, 0, 0, 0, oPGrid,,)
	::oTree:Align      := CONTROL_ALIGN_ALLCLIENT
	::oTree:BCHANGE    := {||}
	::oTree:BLDBLCLICK := {|| ::GetChildren(::oTree:CurrentNodeID,.T.)}
	::oTree:BLCLICKED  := {||}
 
	If !Empty(::cJImnToken)
		::JImngGroup(oTipo, @oPesquisa, .F.)
		::oTree:SetFocus()
		::oModal:activate()

		If ::lClearCliCaso
			::cClienteLj := ""
		EndIf
		::oModal:DeActivate()
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngRcMtt
Retorna uma lista de workspaces em que houve alguma atividade recente.
Considera os últimos 30 dias.

@return Nil
@author Rebeca Facchinato Asunção
@since  14/02/2024
/*/
//-------------------------------------------------------------------
Method JIMngRcMtt() Class TJurAnxImng
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/recent-workspaces"
Local aResponse  := {}
Local oBody      := JsonObject():New()
Local nI         := 0
Local nX         := 0
Local aHeader    := {"X-Auth-Token: " + ::cJImnToken, "Content-Type: application/json"}

	oBody["profile_fields"] := JsonObject():New()
	oBody["profile_fields"]["workspace"] := {"custom1", "custom1_description",;
												"custom2", "custom2_description",;
												"database", "id", "name", "wstype",;
												"activity_date"}


	aResponse := ::JPrepImng("POST", cEndPoint, Nil, Nil, Nil, oBody, Nil, aHeader )

	If Len(aResponse) > 0
		// Agrupamento de Assutos/Casos recentes (30 dias)
		::oTree:PTAddNodes( StrZero(0,7), StrZero(4,7), "", STR0033, "CLOCK01", "CLOCK01" ) // "Assuntos/Casos recentes (30 dias)"
	EndIf

	For nI := 1 to Len(aResponse)
		If VALTYPE(aResponse[nI]) <> "O"
			For nX := 1 To Len(aResponse[nI]['data']['results'])
				::oTree:PTAddNodes( StrZero(4,7), "AW:" + aResponse[nI]['data']['results'][nX]['wstype'] + "|" + aResponse[nI]['data']['results'][nX]['id'],;
									"", ::Decode(aResponse[nI]['data']['results'][nX]['name']), "HISTORIC", "HISTORIC" ) // Agrupamento de Recentes (30 dias)
			Next nX
		Else
			// Verifica se o token de acesso expirou
			If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()
				::JIMngoAuth2(.T.) // Faz o refresh token
				::JIMngRcMtt() // Busca novamente
			EndIf
		EndIf
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngRcDoc
Retorna uma lista de documentos em que houve alguma atividade recente.
Considera os últimos 30 dias.

@return Nil
@author Rebeca Facchinato Asunção
@since  15/04/2024
/*/
//-------------------------------------------------------------------
Method JIMngRcDoc() Class TJurAnxImng
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/recent-documents"
Local nI         := 0
Local aResponse  := {}

	aResponse := ::JPrepImng("GET", cEndPoint)

	If Len(aResponse) > 0
		// Remove item antes de fazer a busca
		::oTree:PTAddNodes( StrZero(0,7), StrZero(5,7), "", STR0039, "CLOCK01", "CLOCK01" ) // "Documentos recentes (30 dias)"
	EndIf

	For nI := 1 To Len(aResponse)
		If ValType(aResponse[nI]) <> "O"
			::JImgnGtDoc(StrZero(5,7), aClone(aResponse[nI]['data']['results']))
		Else
			If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()  // Verifica se o token de acesso expirou
				::JIMngoAuth2(.T.) // Faz o refresh token
				::JIMngRcDoc() // Busca novamente
			EndIf 
		EndIf
		FWFreeObj(aResponse[nI])
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MostraDocs
Constrói a tela para apresentar documentos recentes

@return Nil
@author Rebeca Facchinato Asunção
@since  21/08/2023
/*/
//-------------------------------------------------------------------
Method MostraDocs() class TJurAnxImng
	::oTree:BeginUpdate()
	::JIMngRcMtt()  // Casos/Assuntos Recentes
	::JIMngRcDoc()  // Documentos recentes
	::JIMngFav(.T.) // Favoritos
	::oTree:PTSendNodes()
	::oTree:EndUpdate()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImgnGtDoc
Busca documentos de uma pasta

@param  cPai       - Id do item pai (do nível acima)
@param  aResponse  - Lista de objetos de pastas e arquivos
@return Nil
@author Rebeca Facchinato Asunção
@since  14/02/2024
/*/
//-------------------------------------------------------------------
Method JImgnGtDoc(cPai, aResponse) class TJurAnxImng
Local nX          := 0
Local lDocStruct  := .F.
Local cIcone      := ""

	// Seta os documentos
	For nX := 1 To Len(aResponse)
		// Verifica se o item retornou uma estrutura de documento
		lDocStruct := aResponse[nX]:hasProperty('document_number') .AND. Valtype(aResponse[nX]['document_number']) <> "U";
						.AND. aResponse[nX]:hasProperty('version') .AND. Valtype(aResponse[nX]['version']) <> "U";
						.AND. aResponse[nX]:hasProperty('name') .AND. Valtype(aResponse[nX]['name']) == "C";
						.AND. aResponse[nX]:hasProperty('extension') .AND. Valtype(aResponse[nX]['extension']) == "C"

		If lDocStruct
			cIcone := JTipoIcone(aResponse[nX]['wstype'])
			::oTree:PTAddNodes( cPai, "AD:" + aResponse[nX]['wstype'] + "|" + aResponse[nX]['id'], "", ::Decode(aResponse[nX]['name']);
				+ "." + aResponse[nX]['extension'], cIcone, cIcone )
		EndIf
	Next nX

	aSize(aResponse, 0)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JWImgnVNum
Vincula um documento a um registro, gravando na NUM

@param  cItem  - Id do item selecionado
@param  cDesc  - Titulo do item
@return lRet   - Indica se o documento foi anexado com sucesso
@author Rebeca Facchinato Asunção
@since  14/02/2024
/*/
//-------------------------------------------------------------------
Method JWImgnVNum(cItem, cDesc) class TJurAnxImng
Local lRet       := .T.
Local cExtensao  := ""
Local cDocNumber := ""
Local cVersion   := ""

	If Substr(cItem, 2, 1) == "D" // Verifica se foi selecionado um item do tipo documento

		cExtensao  := Alltrim(SUBSTR(cDesc, Rat(".",cDesc) +1))
		cDocNumber := ALLtrim(Substr(cItem, At("!", cItem) +1))
		cVersion   := AllTrim(Substr(cDocNumber, Rat(".", cDocNumber) +1))
		cDocNumber := AllTrim(Substr(cDocNumber, 0, At(".", cDocNumber) -1))

		cDoc := "!nrtdms:0:!session:" + ::cServerImg + ":!database:" + ::cLibrarie +;
					":!document:" + cDocNumber + "," + cVersion + ":"

		cDesc := Alltrim(SUBSTR(cDesc, 0, Rat(".",cDesc) -1)) // Nome do arquivo sem extensão

		lRet := Self:GravaNUM(cDocNumber, cDoc, cDesc, cExtensao)
		If Self:lInterface
			Self:AtualizaGrid()
		EndIf

		If lRet
			ApMsgInfo(STR0019) // "Documento anexado com sucesso!"
		EndIf
	Else
		lRet := JurMsgErro(STR0036, , , .F.) // "É necessário selecionar um documento para realizar a operação. Verifique!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngFav
Retorna os itens favoritos do usuário logado

@param  lMostraDocs - Indica se deverá buscar e mostrar os documentos na árvore
@return Nil
@author Rebeca Facchinato Asunção
@since  14/02/2024
/*/
//-------------------------------------------------------------------
Method JIMngFav(lMostraDocs) class TJurAnxIMng
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/my-favorites/children"
Local aResponse  := {}
Local nI         := 0

Default lMostraDocs := .T.

	// Remove item antes de fazer a busca
	::ClearItem(StrZero(6,7), STR0034) // "Meus favoritos"

	aResponse := ::JPrepImng("GET", cEndPoint)

	If Len(aResponse) > 0
		// Agrupamento favoritos
		::oTree:PTAddNodes( StrZero(0,7), StrZero(6,7), "", STR0034, "PIN", "PIN" ) // "Meus favoritos"
	EndIf

	For nI := 1 To Len(aResponse)
		If ValType(aResponse[nI]) <> "O"
			::JImngTipos(StrZero(6,7), aResponse[nI]['data'], lMostraDocs)
		Else
			// Verifica se o token de acesso expirou
			If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()
				::JIMngoAuth2(.T.) // Faz o refresh token
				::JIMngFav(lMostraDocs)  // Busca novamente
			EndIf
		EndIf
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngCateg
Retorna uma lista com os itens de uma categoria dos favoritos

@param  cIdCategoria - Id da categoria no iManage
@param  lMostraDocs  - Indica se deverá buscar e mostrar os documentos na árvore
@return Nil
@author Rebeca Facchinato Asunção
@since  16/02/2024
/*/
//-------------------------------------------------------------------
Method JIMngCateg(cIdCategoria, lMostraDocs) class TJurAnxImng
Local cEndPoint  := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/my-favorites/categories/" + ::GetCodDoc(cIdCategoria) + "/children"
Local aResponse  := {}
Local nI         := 0

	aResponse := ::JPrepImng("GET", cEndPoint)
	
	For nI := 1 To Len(aResponse)
		If VALTYPE(aResponse[nI]) <> "O"
			::JImngTipos(cIdCategoria, aResponse[nI]['data'], lMostraDocs)
		Else
			// Verifica se o token de acesso expirou
			If "UNAUTHORIZED" $ aResponse[nI]:GetLastError()
				::JIMngoAuth2(.T.)  // Faz o refresh token
				::JIMngCateg(cIdCategoria, lMostraDocs)  // Busca novamente
			EndIf
		EndIf
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JImngTipos
Trata os itens de acordo com o tipo, para listar itens filhos

@param  cPai        - Id do item pai (nível acima)
@param  aResponse   - Array de intens a ser tratado
@param  lMostraDocs - Indica se deverá buscar e mostrar os documentos na árvore
@return Nil
@author Rebeca Facchinato Asunção
@since  16/02/2024
/*/
//-------------------------------------------------------------------
Method JImngTipos(cPai, aResponse, lMostraDocs) Class TJurAnxImng
Local nI         := 0
Local cIcone     := ""

Default lMostraDocs := .T.

	For nI := 1 To Len(aResponse)

		If ValType(aResponse[nI]["target"]) <> "U"
			Do Case
				// Se é Assunto (Matter)
				Case (aResponse[nI]["target"]["wstype"] == "workspace")
					::oTree:PTAddNodes( cPai, "FW:" + aResponse[nI]["target"]["wstype"] + "|" + aResponse[nI]["target"]['id'], "",;
											::Decode(aResponse[nI]['name']), "HISTORIC", "HISTORIC" )

				// Se é Pasta (Folder)
				Case (aResponse[nI]["target"]["wstype"] == "folder") 
					::oTree:PTAddNodes( cPai,  "FF:" + aResponse[nI]["target"]['wstype'] + "|" + aResponse[nI]["target"]['id'], "", ::Decode(aResponse[nI]['name']), "FOLDER5", "FOLDER6" )

				// Se é documento ou e-mail
				Case (aResponse[nI]["target"]["wstype"] == "document") .OR. (aResponse[nI]["target"]["wstype"] == "email")
					If lMostraDocs
						cIcone := JTipoIcone(aResponse[nI]["target"]["wstype"])

						If aResponse[nI]["wstype"] == "document_shortcut"
							::oTree:PTAddNodes( cPai, "FD:" + aResponse[nI]['wstype'] + "|" + aResponse[nI]["target"]['id'], "", ::Decode(aResponse[nI]["target"]['name']), cIcone, cIcone )
						Else
							::oTree:PTAddNodes( cPai, "FD:" + aResponse[nI]['wstype'] + "|" + aResponse[nI]['id'], "", ::Decode(aResponse[nI]["target"]['name']), cIcone, cIcone )
						EndIf
					EndIf
			End Case

		// Se é categoria
		ElseIf ValType(aResponse[nI]["category_type"]) <> "U" .AND. aResponse[nI]["category_type"] == "my_favorites"
			::oTree:PTAddNodes( cPai, "FC:" + aResponse[nI]['wstype'] + "|" + aResponse[nI]['id'], "", ::Decode(aResponse[nI]['name']), "CONTAINR", "CONTAINR" )
		EndIf
	Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCodDoc
Obtem o código interno do iManage, no id item

@param  cItem - Id do item
@return Código interno do iManage no item
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method GetCodDoc(cItem) class TJurAnxImng
Return Alltrim(Substr(cItem,At('|',cItem)+1))

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTypeDoc
Obtem o tipo de item a partir do id

@param  cItem - Id do item
@return Tipo do item
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method GetTypeDoc(cItem) class TJurAnxImng
Return Alltrim(Substr(cItem, At(':',cItem) + 1, At('|',cItem) -1))

//-------------------------------------------------------------------
/*/{Protheus.doc} Decode
Realiza o decode UT8 para o texto, verificando se é diferente de undefined

@param  cText - Texto a ser tratado
@return cText - Conteúdo do texto decodado
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method Decode(cText) class TJurAnxImng
	If valType(DecodeUTF8(cText)) <> "U"
		cText := DecodeUTF8(cText)
	EndIf
Return cText

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrefixDoc
Obtem o prefixo no id do documento

@param  cDoc - Id do documento
@return Prefixo do documento
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method GetPrefixDoc(cDoc) class TJurAnxImng
Return Alltrim(Left(cDoc, 2))

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearItem
Limpa o item na árvore

@param  cItem - Id do item na árvore
@param  cDesc - Descrição do item na árvore
@return cItem - Id do item na árvore
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method ClearItem(cItem, cDesc) class TJurAnxImng
	::oTree:PTGotoToNode(cItem)
	If ::oTree:CurrentNodeID == cItem .AND. ::oTree:PTGetPrompt() == cDesc
		::oTree:PTDeleteCurrentNode()
	EndIf
Return cItem

//-------------------------------------------------------------------
/*/{Protheus.doc} GetChildren
Obtem o id do item filho (nível abaixo)

@param  cItem - Id do item na árvore
@param  lDoc  - Indica se deverá buscar e mostrar os documentos na árvore
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Method GetChildren(cItem, lDoc) class TJurAnxImng
Local lOk := .T.

	::oTree:BeginUpdate()
	Do case
		Case Right(::GetPrefixDoc(cItem), 1) == "W"  // Workspace (Assunto)
			::JWrkChldrn(cItem, lDoc)
		Case Right(::GetPrefixDoc(cItem), 1) == "F"  // Pasta
			::JIMngGtFldr(cItem, lDoc)
		Case Right(::GetPrefixDoc(cItem), 1) == "C"  // Categoria
			::JIMngCateg(cItem, lDoc)
		Case Right(::GetPrefixDoc(cItem), 1) == "D"  // Documento / E-mail
			lOk := ::JWImgnVNum(::oTree:CurrentNodeID, ::oTree:PTGetPrompt())
			::TJAnxClose(lOk)
	End Case
	::oTree:PTSendNodes()
	::oTree:EndUpdate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setDadosCliente
Seta os dados de cliente e loja para utilizar no filtro da consulta
padrão do campo de caso

@param  cCliente - Código do cliente
@param  cLoja    - loja do cliente
@param lLojaAuto - Indica se o cliente usa loja automática
@return Nil
@author Rebeca Facchinato Asunção
@since  11/03/2024
/*/
//-------------------------------------------------------------------
Static function setDadosCliente(cCliente, cLoja, lLojaAuto)

	cGetClie := cCliente

	If lLojaAuto .AND. !Empty(cCliente)
		cGetLoja := StrZero(0, TamSx3("A1_LOJA")[1])
	Else
		cGetLoja := cLoja
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPrepImng
Responsável por preparar e enviar as requisições de acordo com a necessidade

@param  cVerbo    - Operação a ser realização (GET/POST)
@param  cEndPoint - url para a requisição
@param  nOffset   - Quantidade que deve ser ignorada no conjunto total de resultados
@param  nLimit    - Quantidade de registros que devem ser retornados
@param  lTotal    - Indica se deve retornar a quantidade total de registros
@param  oBody     - Body com o tipo objeto
@param  lFromJson - Indica ser irá converter o json em objeto
@param  aHeader   - Header a ser enviadona requisição
@param  cParams   - Query params que serão enviados na requisição
@param  cBody     - Body com o tipo string

@return oResponse/oRequest - Objeto com a resposta da API
								- aResponse - Se a requisição foi realizada com sucesso
								- oRequest  - Se a requisição falhou (contém o erro)
@author Rebeca Facchinato Asunção
@since  15/04/2024
/*/
//-------------------------------------------------------------------
Method JPrepImng(cVerbo, cEndPoint, nOffset, nLimit, lTotal, oBody, lFromJson, aHeader, cParams, cBody) Class TJurAnxImng
Local oRequest   := FWRest():New(::cHost + "/api")
Local oResponse  := Nil
Local lRet       := .F.
Local lCont      := .T.
Local cQryParams := ""
Local aResponse  := {}
Local nQtdItems  := 0
Local nTotal     := 1

Default nOffset   := 0
Default nLimit    := 50
Default lTotal    := .T.
Default oBody     := Nil
Default lFromJson := .T.
Default aHeader   := {"X-Auth-Token: " + ::cJImnToken}
Default cParams   := ""
Default cBody     := ""

	While (nTotal > nQtdItems) .AND. lCont
		cQryParams := "?total=true&offset=" + cValTochar(nOffset) + "&limit=" + cValToChar(nLimit)

		// Params adicionais
		If !Empty(cParams)
			cQryParams := cQryParams + cParams
		EndIf

		oRequest:SetPath(cEndPoint + cQryParams)

		Do Case
			Case cVerbo == "GET"
				lRet := oRequest:Get(aHeader)

			Case cVerbo == "POST"

				If ValType(oBody) <> "U"
					oRequest:SetPostParams(oBody:toJson())
				Else
					oRequest:SetPostParams(cBody)
				EndIf
				lRet := oRequest:Post(aHeader)
		EndCase

		If lRet
			oResponse := JsonObject():New()

			If lFromJson
				oResponse:fromJson(oRequest:GetResult())
				aAdd(aResponse, oResponse)
			Else
				aAdd(aResponse, oRequest:GetResult())
			EndIf
			
			nTotal    := oResponse['total_count']
			nQtdItems := nQtdItems + nLimit
			nOffset   := nOffset + nLimit
			lCont     := lTotal
		Else
			Exit
		EndIf
	EndDo

	If !lRet
		Return {oRequest}
	EndIf

Return aResponse
//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngLogin
Realiza a requisição de autenticação com grant do tipo password

@param  cUsuario   - Usuário de login
@param  cSenha     - Senha de login
@return cJImnToken - Token de acesso
@author Rebeca Facchinato Asunção
@since  15/09/2023
/*/
//-------------------------------------------------------------------
Method JIMngLogin(cUsuario, cSenha) Class TJurAnxIMng
Local oResponse  := Nil
Local oRequest   := Nil
Local aHeader    := {}
Local cAppKey    := AllTrim(SuperGetMV('MV_JIMNGKY',,'')) // App key
Local cAppSecret := AllTrim(SuperGetMV('MV_JIMNGSC',,'')) // App secret
Local cServerImg := AllTrim(SuperGetMV('MV_JGEDSER',,'')) // Server do worksite
Local cHost      := "https://" + cServerImg
Local cEndPoint  := "/auth/oauth2/token"
Local cBody      := ""

	aHeader := {"Content-Type: application/x-www-form-urlencoded", "Accept-Encoding: gzip, deflate, br", "Accept: */*"}

	cBody += 'username=' + cUsuario + '&'
	cBody += 'password=' + cSenha + '&'
	cBody += 'grant_type=password' + '&'
	cBody += 'client_id=' + cAppKey + '&'
	cBody += 'client_secret=' + cAppSecret

	oResponse := Nil
	oRequest  := Nil
	oRequest  := FWRest():New(cHost)
	oRequest:SetPath(cEndPoint)
	oRequest:SetPostParams(cBody)

	If oRequest:Post(aHeader)
		oResponse := JsonObject():New()
		oResponse:fromJson(oRequest:GetResult())

		If ValType(oResponse) <> "U" .And. ValType(oResponse['access_token']) <> "U"
			::cJImnToken := Escape(Replace(oResponse['access_token'], "/", "%2F"))
			::cJImnRfrsh := Escape(Replace(oResponse['refresh_token'], "/", "%2F"))
			::dLastUse   := Date()
		EndIf
	Else
		oResponse := JsonObject():New()
		oResponse:fromJson(oRequest:GetResult())

		If Valtype(oResponse['error']) <> "U" .AND. "User ID or Password is incorrect" $ oResponse['error']['message']
			JurMsgErro(STR0018) // "Usuário ou senha incorretos, verifique!"
		Else
			JurMsgErro(STR0008 + oRequest:GetLastError()) // "Retorno da requisição"
		EndIf
	EndIf

	aSize(aHeader, 0)
	aHeader := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngCstmr
Realizar as validações para buscar o customer

@author Rebeca Facchinato Asunção
@since  19/06/2024
/*/
//-------------------------------------------------------------------
Method JIMngCstmr(lComprDesp) Class TJurAnxImng
Local cCustomer := ""

Default lComprDesp := .F.

	If !Empty(::cAppKey) .AND. !Empty(::cAppSecret)
		// Autenticação
		If Empty(::cJImnToken)
			If lComprDesp
				::JIMngAut(.T., .F.)
			Else
				::JIMngAut()
			EndIf
		EndIf

		If !Empty(::cJImnToken)
			cCustomer := ::JReqCstmr()
		EndIf

	Else
		JurMsgErro(STR0007) // "Necessário preencher os parâmetros MV_JIMNGKY e MV_JIMNGSC para realizar a operação. Verifique!"
	EndIf

Return cCustomer

//-------------------------------------------------------------------
/*/{Protheus.doc} JReqCstmr
Realizar a requisição para buscar o customer

@author Rebeca Facchinato Asunção
@since  19/06/2024
/*/
//-------------------------------------------------------------------
Method JReqCstmr() Class TJurAnxImng
Local cCustomer  := ""
Local oResponse  := Nil
Local oRequest   := FWRest():New(::cHost)
Local aHeader    := {"X-Auth-Token: " + ::cJImnToken}

	oRequest:SetPath("/api")

	If oRequest:Get(aHeader)
		oResponse := JsonObject():New()
		oResponse:fromJson(oRequest:GetResult())

		If !Empty(oResponse['data']['user']["customer_id"])
			cCustomer := cValToChar(oResponse['data']['user']["customer_id"])
		EndIf
	EndIf

	aSize(aHeader, 0)
	aHeader   := Nil
	oRequest  := Nil
	oResponse := Nil

Return cCustomer

//-------------------------------------------------------------------
/*/{Protheus.doc} PesquisaDoc
Faz a chamada da API para pesquisar os documentos

@param  cPesquisa - Termo digitado
@param  cTipo     - Tipo de pesquisa (Nome/Número)
@param  oGetClie - Indica cliente
@param  oGetLoja - Indica loja
@param  oGetCaso - Indica caso
@return .T.
@author Rebeca Facchinato Asunção
@since  26/08/2024
/*/
//-------------------------------------------------------------------
Method PesquisaDoc(cPesquisa, cTipo, oGetClie, oGetLoja, oGetCaso) Class TJurAnxImng

	cPesquisa := AllTrim(cPesquisa)

	If !Empty(cTipo) .AND. !Empty(cPesquisa)

		If Valtype(oGetClie) <> "U"
			oGetClie:SetValue(SPACE(GetSX3Cache("A1_COD", "X3_TAMANHO")))
		EndIf

		If Valtype(oGetLoja) <> "U"
			oGetLoja:SetValue(SPACE(GetSX3Cache("A1_LOJA", "X3_TAMANHO")))
		EndIf

		If Valtype(oGetCaso) <> "U"
			oGetCaso:SetValue(SPACE(GetSX3Cache("NVE_NUMCAS", "X3_TAMANHO")))
		EndIf

		If cTipo == STR0044  // Nome
			cPesquisa := STRTRAN(cPesquisa,'"', "") // Remove aspas duplas
			cPesquisa := JurLmpCpo(cPesquisa, .F., .T. )
			cPesquisa := Escape(cPesquisa) // Trata caracteres especiais
			::GetDocByName(cTipo, cPesquisa)
		Else
			::GetDocByID(cTipo, cPesquisa)
		EndIf

	Else
		JurMsgErro(STR0048) // "É necessário selecionar o tipo de pesquisa e preencher o termo para busca. Verifique!"
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocsByNameID
Chama API para pesquisar documentos de acordo com o tipo de pesquisa.

@param  cTipo     - Tipo de pesquisa (Nome/Número)
@param  cPesquisa - Termo digitado
@return .T.
@author Rebeca Facchinato Asunção
@since  27/08/2024
/*/
//-------------------------------------------------------------------
Method GetDocsByNameID(cTipo, cPesquisa) Class TJurAnxImng
Local cEndPoint   := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/documents"
Local cParams     := "&"
Local aResponse   := {}

	If cTipo == STR0045  // "Número"
		cParams += "document_number=" + cPesquisa
	Else
		cParams += "name=" + cPesquisa
	EndIf

	aResponse := ::JPrepImng("GET", cEndPoint,0,9999,,,,,AllTrim(cParams))

	::JImngResult(aResponse, cTipo, cPesquisa)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JImngResult
Trata o resultado da API de pesquisa documentos

@param  aResponse - Estrutura com resultado da pesquisa
@param  cTipo     - Tipo de pesquisa (Nome/Número)
@param  cPesquisa - Termo digitado
@return .T.
@author Rebeca Facchinato Asunção
@since  28/08/2024
/*/
//-------------------------------------------------------------------
Method JImngResult(aResponse, cTipo, cPesquisa) Class TJurAnxIMng
Local nI          := 0
Local nPosData    := 0
Local nTotal      := 0
Local aPropert    := {}
	::oTree:BeginUpdate()
	::oTree:PTReset()
	If Len(aResponse) > 0 .AND. ValType(aResponse[1]) <> "O"

		aPropert := ClassDataArr(aResponse[1])
		nPosData := aScan(aPropert,{|x| x[1] == "data"})

		If nPosData > 0
			For nI := 1 To Len(aResponse)
				If ValType(aResponse[nI]) <> "O"
					nTotal := Len(aResponse[nI]['data']['results'])

					If nTotal > 0
						::oTree:PTAddNodes( StrZero(0,7), StrZero(2,7), "", STR0051 + " (" + cValToChar(nTotal) + ")", "PESQUISA", "PESQUISA" ) // "Resultado da pesquisa"
						::JImgnGtDoc(StrZero(2,7), aClone(aResponse[nI]['data']['results']))
					Else
						::oTree:PTAddNodes( StrZero(0,7), StrZero(2,7), "", STR0050, "PESQUISA", "PESQUISA" ) // "A pesquisa não retornou dados"
					EndIf
				EndIf
				FWFreeObj(aResponse[nI])
			Next nI

		Else
			::oTree:PTAddNodes( StrZero(0,7), StrZero(2,7), "", STR0050, "PESQUISA", "PESQUISA" ) // "A pesquisa não retornou dados"
		EndIf

	Else
		If "UNAUTHORIZED" $ aResponse[1]:GetLastError() // Verifica se o token de acesso expirou
			::JIMngoAuth2(.T.) // Faz o refresh do token
			::GetDocsByNameID(cTipo, cPesquisa)  // Busca novamente
		Else
			JIMngError(aResponse[1])
		EndIf
	EndIf
	::oTree:PTSendNodes()
	::oTree:EndUpdate()
	::MostraDocs()

	aSize(aResponse, 0)
	aSize(aPropert, 0)
	aResponse := Nil
	aPropert  := Nil

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JIMngError
Trata mensagens de erro da API do iManage

@param  oError - Estrutura com mensagens de erro
@return Nil
@author Rebeca Facchinato Asunção
@since  28/08/2024
/*/
//-------------------------------------------------------------------
Function JIMngError(oError)
Local oRetorno   := Nil
Local cCodErro   := ""
Local cMsgErro   := ""
Local cSolucao   := ""
Local lMsgPadrao := .F.

	If aScan(ClassDataArr(oError),{|x| x[1] == "CRESULT"}) > 0
		If !("<!DOCTYPE HTML PUBLIC " $ oError:CRESULT)
			oRetorno := JSonObject():New()
			oRetorno:fromJson(oError:CRESULT)

			If aScan(ClassDataArr(oError),{|x| x[1] == "error"}) > 0
				cCodErro := oRetorno["error"]["code"]
				cSolucao := STR0053 // "Por favor, entre em contato com o administrador do sistema."

				If cCodErro == "NRC_INDEX_UNAVAILABLE"
					cMsgErro := cCodErro + CRLF + STR0054 // "Para realizar buscas é necessário possuir os serviços de pesquisa 'index' previamente instalados para o iManage/Worksite."
				Else
					cMsgErro := oRetorno["error"]["code_message"]
				EndIf

				JurMsgErro(cMsgErro,,cSolucao)
			Else
				lMsgPadrao := .T.
			EndIf
		Else
			lMsgPadrao := .T.
		EndIf
	Else
		lMsgPadrao := .T.
	EndIf

	If lMsgPadrao
		JurMsgErro(STR0055) // "Não foi possível realizar a operação. Verifique o log do sistema."
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocByName
Valida o termo digitado, quando o tipo de pesquisa é pelo nome

@param  cTipo     - Tipo de pesquisa (Nome/Número)
@param  cPesquisa - Termo digitado
@return .T.
@author Rebeca Facchinato Asunção
@since  03/09/2024
/*/
//-------------------------------------------------------------------
Method GetDocByName(cTipo, cPesquisa) Class TJurAnxIMng

	If Len(cPesquisa) >= 3
		::GetDocsByNameID(cTipo, cPesquisa)
	Else
		JurMsgErro(STR0047) // "É necessário digitar ao menos 3 caracteres para realizar a busca."
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDocByID
Valida o termo digitado, quando o tipo de pesquisa é pelo número

@param  cTipo     - Tipo de pesquisa (Nome/Número)
@param  cPesquisa - Termo digitado
@return .T.
@author Rebeca Facchinato Asunção
@since  03/09/2024
/*/
//-------------------------------------------------------------------
Method GetDocByID(cTipo, cPesquisa) Class TJurAnxIMng

	If IsNumeric(cPesquisa)  // Valida se há somente números para a busca
		::GetDocsByNameID(cTipo, cPesquisa)
	Else
		JurMsgErro(STR0056) // "Digite apenas números para realizar a busca pelo tipo selecionado. Verifique!"
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JImngClCas
Identifica o cliente e caso da entidade

@param  cEntidade - Entidade
@param  cFilEnt   - Filial da entidade
@param  cCodEnt   - Código da entidade
@param  nIndice   - Índice de busca da entidade
@return aCliCaso  - Dados do cliente e caso da entidade
@author Rebeca Facchinato Asunção
@since  16/09/2024
/*/
//-------------------------------------------------------------------
Method JImngClCas(cEntidade, cFilEnt, cCodEnt, nIndice) Class TJurAnxImng
Local aCliCaso := {}

	Do case
		Case cEntidade == "NVY" // Despesas
			aCliCaso := JurGetDados("NVY", 1, cFilEnt + cCodEnt, {"NVY_CCLIEN", "NVY_CLOJA ", "NVY_CCASO "}) // NVY_FILIAL+NVY_COD

		Case cEntidade == "NVE" // Caso
			aCliCaso := JurGetDados("NVE", 1, cFilEnt + cCodEnt, {"NVE_CCLIEN", "NVE_LCLIEN ", "NVE_NUMCAS"}) // NVE_FILIAL+NVE_CCLIEN+NVE_LCLIEN+NVE_NUMCAS+NVE_SITUAC

		Case cEntidade == "NT0" // Contratos
			aCliCaso := JurGetDados("NT0", 1, cFilEnt + cCodEnt, {"NT0_CCLIEN", "NT0_CLOJA "}) // NT0_FILIAL+NT0_COD

		Case cEntidade == "NSZ" // Processos
			aCliCaso := JurGetDados(cEntidade, 1, cFilEnt + cCodEnt, {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"}) // NSZ_FILIAL+NSZ_COD

		Case &(cEntidade + "->(ColumnPos('" + cEntidade + "_CAJURI'))") > 0 // Entidades filhas de processos
			Self:cCajuri := JurGetDados(cEntidade, nIndice, cFilEnt + cCodEnt, cEntidade + "_CAJURI")
			aCliCaso := JurGetDados("NSZ", 1, cFilEnt + Self:cCajuri, {"NSZ_CCLIEN", "NSZ_LCLIEN", "NSZ_NUMCAS"})
	End Case

Return aCliCaso

//-------------------------------------------------------------------
/*/{Protheus.doc} JImngGroup
Refaz a árvore com todos os grupos

@param  oTipo     - Tipo de pesquisa
@param  oPesquisa - Valo de pesquisa
@param  lCallPesq - Indica se a chamada é feita pela tela de pesquisa
@return .T.
@author Rebeca Facchinato Asunção
@since  17/09/2024
/*/
//-------------------------------------------------------------------
Method JImngGroup(oTipo, oPesquisa, lCallPesq) Class TJurAnxImng

Default lCallPesq := .F.

	::oTree:BeginUpdate()
	::oTree:PTReset()
	If !Empty(::cClienteLj)
		::JIMngGtWrk(lCallPesq)  // Casos/Assuntos filtrados por cliente/caso
		oTipo:SetValue(STR0044)
		oPesquisa:SetValue(SPACE(GetSX3Cache("NUM_DESC  ", "X3_TAMANHO")))
	EndIf
	::oTree:PTSendNodes()
	::oTree:EndUpdate()
	::MostraDocs()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JWrkChldrn
Busca filhos de uma workspace (assunto)

@param  cIdItem  - Id da workspace
@param  lSetDocs - Indica se irá buscar documentos (usado no Anexar)
@return Nil
@author Rebeca Facchinato Asunção
@since  17/09/2024
/*/
//-------------------------------------------------------------------
Method JWrkChldrn(cIdItem, lSetDocs) Class TJurAnxImng
Local cEndPoint  := ""
Local aResponse  := {}
Local nX         := 0
Local nI         := 0

Default lSetDocs   := .F.

	If Left(::oTree:PTGetPrompt(), 1) == ">" // Verifica se já clicou 2 x no item
		Return Nil
	EndIf

	cEndPoint := "/v2/customers/" + ::cCustomer + "/libraries/" + ::cLibrarie + "/workspaces/" + ::GetCodDoc(cIdItem) + "/children"
	aResponse := ::JPrepImng("GET", cEndPoint)

	If Len(aResponse) > 0
		::oTree:PTChangePrompt(">" + ::oTree:PTGetPrompt(), cIdItem)
	EndIf

	For nI := 1 To Len(aResponse)

		If VALTYPE(aResponse[nI]) <> "O"
			If aScan(aResponse[nI]['data'], {|x| x['wstype'] == "folder" }) == 0
				::oTree:PTChangeBmp("FOLDER7","FOLDER7", cIdItem) // Troca o icone para pasta vermelha quando não tem pastas filhas
			EndIf

			For nX := 1 To Len(aResponse[nI]['data'])
				If aResponse[nI]['data'][nX]['wstype'] == "folder"
					::oTree:PTAddNodes( cIdItem, "FF:" + aResponse[nI]['data'][nX]['wstype'] +;
								"|" + aResponse[nI]['data'][nX]['id'],"", ::Decode(aResponse[nI]['data'][nX]['name']),;
								"FOLDER5", "FOLDER6" )
				EndIf
			Next nX
			// Seta os documentos
			If lSetDocs
				::JImgnGtDoc(cIdItem, aResponse[nI]['data'])
			EndIf

		Else
			// Verifica se o token de acesso expirou
			If "UNAUTHORIZED" $ UPPER(aResponse[nI]:GetLastError())
				::JIMngoAuth2(.T.) // Faz o refresh token
				::JWrkChldrn(cIdItem, lSetDocs)
			EndIf
		EndIf
	Next nI

	aSize(aResponse, 0)
	aResponse := Nil

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JTipoIcone
Define o ícone do item de acordo com o tipo 

@param  cTipo  - Tipo do item documento ou e-mail.
@return cIcone - Id da imagem
@author Rebeca Facchinato Asunção
@since  03/10/2024
/*/
//-------------------------------------------------------------------
Function JTipoIcone(cTipo)
Local cIcone := "PAPEL_ESCRITO"

	If cTipo == "email"
		cIcone := "BMPPOST"
	EndIf

Return cIcone
