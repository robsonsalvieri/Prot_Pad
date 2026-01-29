#INCLUDE "FILEIO.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "QDODOCUMENTCONTROL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

#DEFINE ENTER CHR(13) + CHR(10)
#DEFINE MB_ICONEXCLAMATION 48
#DEFINE oFont14 TFont():New("Arial", , -14, , .F.) //Texto de detalhes do arquivo

Static lPEEditDoc   := ExistBlock("QDOEDITDOC")
    Static lPeViliPDF   := Nil
Static slQLTMetrics := FindClass("QLTMetrics")

/*/{Protheus.doc} QDODocumentControl
Regras de Negocio - Controle de Arquivos do QDO -> Leitura Interna no ERP
@author brunno.costa
@since  29/11/2021
/*/
CLASS QDODocumentControl FROM LongNameClass

    DATA cDirDocLocal                  as Character
    DATA cDirDocLocalSO                as Character
    DATA cDirDocServer                 as Character
    DATA cErrorMessage                 as Character
    DATA lClientLinux                  as Logical
    DATA lExibeBotaoImpressao          as Logical
    DATA lLogConsole                   as Logical
    DATA lPEAlteraRegraPadraoImpressao as Logical
    DATA lServerLinux                  as Logical
    DATA lValidaUsuario                as Logical
    
	METHOD new() CONSTRUCTOR

    //Métodos Públicos
    METHOD abreDocumentoDoServidorComArquivoTemporario(oWord, cArquivo, lCloseLink)
    METHOD abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
    METHOD abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cArquivo)
    METHOD abreDocumentoExternoDoServidor(cArquivo, cDocumento, cRevisao)
    METHOD copiaProtegidaArquivo(cOrigem, cDestino)
    METHOD forcaRegravacaoDeArquivoNaRede()
    METHOD geraDestinoTemporario(cDestino)
    METHOD OLE_SaveAsFile(hOleLink, cFileName, cPassword, cWritePassword, lReadOnly, cSaveFormat, lPermiteRTF, lImplantacao)
    METHOD removeSenhaDocumentosServidor(lExibePergunta, nCobertura)
    METHOD retornaSenhaPadrao()
    METHOD somenteRemoveSenhaDocumentosServidor()
    METHOD validaInconsistenciaImplantacao(lImplantado, lExibeHelp, nCobertura)


    //Métodos Internos
    METHOD abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    METHOD abrePDFDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
    METHOD abrePDFDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    METHOD apagaArquivo(cArquivo, lServer, lExibeHelp)
    METHOD apagaArquivoLocal(cArquivo, lExibeHelp)
    METHOD apagaArquivoServidor(cArquivo, lExibeHelp)
    METHOD arquivoLiberado(cArquivo, lValida)
    METHOD avaliaPEQdoViLiPDF(cArquivo, cDocumento, cRevisao)
    METHOD callStack(nTotal)
    METHOD comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario(cOrigem, cDestino, lSucesso, nCobertura, cArquivo)
    METHOD conteudoArquivosIguais(cOrigem, cDestino, nCobertura)
    METHOD copiaArquivo(cOrigem, cDestino, nCobertura, lVldConteu)
    METHOD copiaArquivoDoServidor(cArquivoPDF)
    METHOD copiaArquivoDoServidorParaWEBAPP(cArquivoPDF, nErrorAux)
    METHOD copiaArquivoParaLocalEAbreCom_QA_OPENARQ(cArquivo)
    METHOD copiaArquivoParaServidor(cArquivoLocal, cNovoNome)
    METHOD copiaParaDocNoServidor(cArquivo, cArquivoDOC)
    METHOD CorrigeFalhaDoGetTempPathComServidorLinuxEWebAgent()
    METHOD criaAliasArquivos(cAlias, nRegistros)
    METHOD criaBatExisteArquivoQDO(cArquivoBat)
    METHOD criaScriptLibreOfficeCMD(cArquivoBat)
    METHOD criaScriptMSOfficePowerShell(cArquivoPS)
    METHOD enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario, nCobertura)
    METHOD erroCopiaArquivo(cArquivo, cErro, nOperacao, nCobertura)
    METHOD erroCriacaoAlias(cErro)
    METHOD erroExclusaoArquivo(cArquivo, cErro, lServer, lExibeHelp)
    METHOD erroMontagemTela(cErro)
    METHOD erroRemocaoDeSenha(cErro)
    METHOD erroVerificacaoExistenciaForaDoRootPath(cCaminho, cErro, lExibeHelp)
    METHOD excluiArquivo(cCaminho, nExcluiu, nCobertura)
    METHOD existeArquivo(cArquivo, lServer)
    METHOD existeArquivoForaDoRootPath(cCaminho, lExibeHelp, nCobertura)
    METHOD existeArquivoWhereDinamico(cArquivo)
    METHOD existeLibreOffice(lExibeHelp)
    METHOD existeMSOffice(lExibeHelp)
    METHOD extraiArquivoDoCaminho(cCaminho)
    METHOD extraiExtensao(cArquivo)
    METHOD fazBackupArquivo(cOrigem, cDestino, nExcluiu, nRenomeou, nCobertura)
    METHOD geraPDF(cArquivo, cArquivoPDF)
    METHOD geraPDFComLibreOffice(cArquivo, cArquivoPDF, nCobertura)
    METHOD geraPDFComLibreOfficeEmLinux(cArquivo, cArquivoPDF, nCobertura)
    METHOD geraPDFComMSOffice(cArquivo, cArquivoPDF, nCobertura)
    METHOD help(cTitulo, cErro, cSolucao, lSoLog)
    METHOD logMsg(cTitulo, cErro, cSolucao)
    METHOD logMsgNaDocsDoServidor(cTitulo, cMensagem, cMsgCompl, cTipo, cCaminho)
    METHOD montaTelaExibicaoPDFNoSmartClient(cArquivoLocal, cDocumento, cRevisao, cUsuario)
    METHOD montaTelaInformacaoDoDocumento(oPanelInfo, cDocumento, cRevisao)
    METHOD montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, oWebEngine)
    METHOD recuperaBackupOriginalPerdido(cOrigem, nCobertura)
    METHOD registraRemocaoSenhaArquivosServidorNaSX6()
    METHOD removeSenhaWord(cArquivo, nError, oWord, lCloseLink, cSaveFormat)
    METHOD renomeiaArquivo(cOrigem, cDestino, nRenomeou, nCobertura, cArquivo, lVldConteu)
    METHOD renomeiaArquivoComExclusaoDestino(cOrigem, cDestino, nExcluiu, nRenomeou, nCobertura)
    METHOD retornaArquivoLocal(cDocumento, cRevisao)
    METHOD retornaBuild()
    METHOD retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao)
    METHOD retornaPathsPadroesDoQDO()
    METHOD retornaRegistroQDH()
    METHOD retornaStatusdoDocumento(cDocumento, cRevisao)
    METHOD usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario)
    METHOD validaDicionario()
    METHOD validaExecucaoViaWebAgent()
    METHOD validaExecucaoViaWebApp()
    METHOD validaExistenciaDosParametrosSX6()
    METHOD validaExtensaoNaoEhDocEDocX(cArquivo)
    METHOD validaExtensaoParaConversaoEmPDF(cArquivo)
    METHOD validaExtensaoPDF(cArquivo)
    METHOD validaImplantacao(lExibeHelp)
    METHOD validaInstalacaoConversores(lExibeHelp, nCobertura)
    METHOD validaParametroQDOUsaSenha()
    METHOD validaParametroSenhasRemovidas()
    METHOD validaUsoNoUsuario(cUsuario)
    
ENDCLASS

/*/{Protheus.doc} new
Construtor da Classe
@author brunno.costa
@since  29/11/2021
@return Self, objeto, instancia da Classe QDODocumentControl
/*/
METHOD new() CLASS QDODocumentControl
    Local aQPath              := {}
    Self:lExibeBotaoImpressao := .T.
    Self:lLogConsole          := GetSrvProfString("QDODocumentControlLog", "0") == "1"
    Self:lValidaUsuario       := .T.
    Self:lServerLinux         := Iif(Self:lServerLinux == Nil, IsSrvUnix(), Self:lServerLinux)
    Self:lClientLinux         := (GetRemoteType() == 2)
    aQPath                    := Self:retornaPathsPadroesDoQDO()
    Self:cDirDocLocal         := Lower(AllTrim(aQPath[3])) //MV_QPATHWT
    Self:cDirDocServer        := Lower(AllTrim(aQPath[1])) //MV_QPATHW
    
    If !ExistDir(Self:cDirDocServer)
        MakeDir(Self:cDirDocServer)
    EndIf

    Iif(!ExistDir(Self:cDirDocLocal)                                    , MakeDir(Self:cDirDocLocal)  , Nil)
	Iif(!Empty(Self:cDirDocLocalSO) .And. !ExistDir(Self:cDirDocLocalSO), MakeDir(Self:cDirDocLocalSO), Nil)

Return Self

/*/{Protheus.doc} validaExecucaoViaWebAgent
Valida se a execução atual é via WebAPP + WebAgent
@author brunno.costa
@since  16/01/2023
@return lWebAgent, lógico, indica se a execução atual é via WebAPP + WebAgent
/*/
METHOD validaExecucaoViaWebAgent() CLASS QDODocumentControl
    
    Local aRMTInfo    := GetRmtInfo()
    Local cLib        := ""
    Local lWebAgent   := .F.
    Local nRemoteType := GetRemoteType(@cLib)

    If !Empty(aRMTInfo) .And. !Empty(aRMTInfo[9]) .AND.; //Navegador (Quando executado pelo SmartClient HTML) ou Marca (Quando executado por um dispositivo móvel)
        (    ("WIN"   $ cLib .And. nRemoteType == 1);    //Smart Client das verões 8 e 10 em ambiente Windows (*).
        .Or. ("LINUX" $ cLib .And. nRemoteType == 2);    //Smart Client das verões 8 e 10 em ambiente Linux (*).
        .Or. ("MAC"   $ cLib .And. nRemoteType == 2))    //Smart Client das verões 8 e 10 em ambiente MacOS (*).
        lWebAgent := .T.
    EndIf
Return lWebAgent

/*/{Protheus.doc} retornaPathsPadroesDoQDO
Retorna Paths Padrões do QDO similar a QDOPath()
@author brunno.costa
@since  16/01/2023
@return aPatchs, array, {cQPath,cQPathD,cQPathTrm,cTextoD,cQPathHtm,cPathView,cUsaView,cQPathDir}
/*/
METHOD retornaPathsPadroesDoQDO() CLASS QDODocumentControl
    Local aPatchs := QDOPath()
    If Self:validaExecucaoViaWebAgent()
        //aPatchs[3] := GetTempPath(.F., .T.) //Path web por environment temporario - com bug na TEC
        Self:cDirDocLocalSO := aPatchs[3]
        If !IsInCallStack("QDOWIZPDF") .And. !IsInCallStack("QDOWIZREMS")
            aPatchs[3]      := Self:CorrigeFalhaDoGetTempPathComServidorLinuxEWebAgent()
        EndIf
    EndIf
Return aPatchs

/*/{Protheus.doc} QDODocumentControl::CorrigeFalhaDoGetTempPathComServidorLinuxEWebAgent
Valida se o ambiente é linux e utiliza WEBAPP+WebAgent, pois existe um erro na função GetTempPath 
que, para este cenário retorna o diretório iniciando com 'L://' onde deveria ser '//' apenas.
@type method 
@author rafael.hesse, thiago.rover, brunno.costa
@since 02/02/2023
@return cPath, Caracter, retorna o diretório com a correção .
/*/
METHOD CorrigeFalhaDoGetTempPathComServidorLinuxEWebAgent() CLASS QDODocumentControl
Local cPath := GetTempPath(.T., .T.) //Path web por usuario temporaria
    If Self:lServerLinux 
        If Substr(cPath,1,1) <> '/'
            cPath := Substr(cPath,3,Len(cPath))
        EndIf
    EndIf
Return cPath

/*/{Protheus.doc} avaliaPEQdoViLiPDF
Avalia existência do PE QDOVILIPDF e o executa, quando existir.
@author Willian.Ramalho
@since  25/04/2025
@return lSucesso, lógico, retorna TRUE indicando sucesso ou indicativo de retorno da customização do ponto de entrada
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
/*/

METHOD avaliaPEQdoViLiPDF(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl

    Local lRetPE     := .T.
    Local lSucesso   := .T.

    lPeViliPDF := Iif(lPeViliPDF == Nil, ExistBlock("QDOVILIPDF"), lPeViliPDF)

    If lPeViliPDF
        lRetPE := ExecBlock("QDOVILIPDF", .F., .F., {cArquivo, cDocumento, cRevisao})
        If ValType(lRetPE) == "L"
            lSucesso := lRetPE
        EndIf
    EndIf

Return lSucesso

/*/{Protheus.doc} abreDocumentoDoServidorNoSmartClient
Abre o Arquivo PDF no SmartClient em Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local cArquivoDOC := ""
    Local cArquivoPDF := ""
    Local cUsuario    := RetCodUsr()
    Local lCriouDoc   := .F.
    Local lCriouLocal := .F.
    Local lCriouPDF   := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    If Self:validaExecucaoViaWebApp()
        Return Self:abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao)
    EndIf

    cArquivo := Lower(AllTrim(cArquivo))
    lSucesso := Self:avaliaPEQdoViLiPDF(cArquivo, cDocumento, cRevisao)

    If lSucesso .AND. Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf
    
    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

	If lSucesso .AND. lPEEditDoc
        ExecBlock("QDOEDITDOC",,,{Self:cDirDocServer, cArquivo})
    Endif

    If Self:validaExtensaoNaoEhDocEDocX(cArquivo)
        If lSucesso .AND. !Self:copiaParaDocNoServidor(cArquivo, @cArquivoDOC)
            lSucesso  := .F.
        ElseIf lSucesso .AND. cArquivo <> cArquivoDOC
            lCriouDoc := .T.
        EndIf
    Else
        cArquivoDOC := cArquivo
    EndIf

    If lSucesso .AND. !Self:geraPDF(cArquivoDOC, @cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouPDF := .T.
    EndIf

    If lCriouDoc
        Self:apagaArquivoServidor(cArquivoDOC, lExibeHelp)
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidor(cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouLocal := .T.   
    EndIf

    If lCriouPDF .AND. !Self:apagaArquivoServidor(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    If lCriouLocal .AND. !Self:apagaArquivoLocal(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    If slQLTMetrics
        QLTMetrics():enviaMetricaQuantidadeDocumentosLidosQDO(FunName(), "I", Iif(lSucesso,"4",Nil)) //I-Interno / 4-Leitura Interna
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abrePDFDoServidorNoSmartClient
Abre o Arquivo PDF no SmartClient em Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abrePDFDoServidorNoSmartClient(cArquivoPDF, cDocumento, cRevisao) CLASS QDODocumentControl
    
    Local aArea       := GetArea()
    Local lCriouLocal := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    If Self:validaExecucaoViaWebApp()
        Return Self:abrePDFDoServidorNoWebApp(cArquivoPDF)
    EndIf

    cArquivoPDF := Lower(AllTrim(cArquivoPDF))
    lSucesso := Self:avaliaPEQdoViLiPDF(cArquivoPDF, cDocumento, cRevisao)

   If lSucesso .AND. !Self:copiaArquivoDoServidor(cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouLocal := .T.   
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, , , RetCodUsr())
        lSucesso := .F.
    EndIf

    If lCriouLocal .AND. !Self:apagaArquivoLocal(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abreDocumentoExternoDoServidor
Abre Documento Externo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoExternoDoServidor(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    
    Local cUsuario := RetCodUsr()
    Local lSucesso := .F.

    cArquivo := Lower(AllTrim(cArquivo))

    If !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    Else

        If Self:validaExtensaoPDF(cArquivo)
            lSucesso := Self:abrePDFDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
        ElseIf  Self:validaExtensaoParaConversaoEmPDF(cArquivo)
            lSucesso := Self:abreDocumentoDoServidorNoSmartClient(cArquivo, cDocumento, cRevisao)
        EndIf

        If !lSucesso
            lSucesso := Self:copiaArquivoParaLocalEAbreCom_QA_OPENARQ(cArquivo)
        Endif

    EndIf

	If slQLTMetrics
		QLTMetrics():enviaMetricaQuantidadeDocumentosLidosQDO(FunName(), "E", Iif(lSucesso,"4",Nil)) //E-Externo / 4-Leitura Interna
	EndIf

Return lSucesso

/*/{Protheus.doc} copiaArquivoParaLocalEAbreCom_QA_OPENARQ
Abre Documento Externo via QA_OPENARQ - Abertura via sistema operacional do client
@author brunno.costa
@since  22/05/2024
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lCopiou, lógico, indica se a cópia do arquivo para abertura ocorreu com sucesso (não tem como validar se conseguiu abrir os comandos)
/*/
METHOD copiaArquivoParaLocalEAbreCom_QA_OPENARQ(cArquivo) CLASS QDODocumentControl
    
    Local lCopiou := .F.
    Local cBackup := Self:cDirDocLocal

    If Self:validaExecucaoViaWebAgent()
        //Corrige Diretório Local visível pelo sistema operacional e não pelo browser do Protheus para abertura com comandos do Sistema Operacional
        Self:cDirDocLocal := Lower(AllTrim(Self:cDirDocLocalSO)) //MV_QPATHWT
    EndIf

    lCopiou := Self:copiaArquivoDoServidor(cArquivo)

    If lCopiou
        QA_OPENARQ(Self:cDirDocLocal+cArquivo)
    EndIf

    If Self:validaExecucaoViaWebAgent()
        Self:cDirDocLocal := cBackup
    EndIf

Return lCopiou

/*/{Protheus.doc} validaExtensaoNaoEhDocEDocX
Valida se o arquivo possui extensão não é DOC nem DOCX
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se a extensão é diferente de DOC e DOCX
/*/
METHOD validaExtensaoNaoEhDocEDocX(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) != "DOC" .AND. UPPER(Self:extraiExtensao(cArquivo)) != "DOCX"

/*/{Protheus.doc} validaExtensaoPDF
Valida se o arquivo possui extensão PDF
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se a extensão é PDF
/*/
METHOD validaExtensaoPDF(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) == "PDF"

/*/{Protheus.doc} validaExtensaoParaConversaoEmPDF
Valida se o arquivo possui extensão válida para conversão em PDF via MS Office/LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD validaExtensaoParaConversaoEmPDF(cArquivo) CLASS QDODocumentControl
Return UPPER(Self:extraiExtensao(cArquivo)) $ "|DOC|DOCX|DOT|DOTX|"

/*/{Protheus.doc} extraiExtensao
Extrai a Extensão do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD extraiExtensao(cCaminho) CLASS QDODocumentControl
    Local aTrechos  := Nil
    Local cArquivo  := Self:extraiArquivoDoCaminho(cCaminho)
    Local cExtensao := ""
    If At( ".", cArquivo ) > 0
        aTrechos   := StrTokArr( cArquivo, "." )
        cExtensao  := aTrechos[Len(aTrechos)]
    EndIf
Return cExtensao

/*/{Protheus.doc} abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario
Abre o Arquivo PDF no SmartClient em Tela - Sem Impressão e Validação de Usuário
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(cArquivo) CLASS QDODocumentControl
    Self:lValidaUsuario       := .F.
    Self:lExibeBotaoImpressao := .F.
Return Self:abreDocumentoDoServidorNoSmartClient(cArquivo)

/*/{Protheus.doc} abreDocumentoDoServidorComArquivoTemporario
Abre Documento do Servidor em Arquivo Temporário e o Exclui
@author brunno.costa
@since  02/11/2023
@param 01 - oWord     , objeto  , objeto com link para MS Office.
@param 02 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 03 - lCloseLink, lógico  , indica se deve fechar o Link com o WORD
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorComArquivoTemporario(oWord, cArquivo, lCloseLink) CLASS QDODocumentControl
    Local lSucesso       := .F.
    Local cNomeAleatorio := QDX_EMBNOM(Embaralha(cArquivo,0))+".DOC"
    
    Iif(Self:cDirDocLocal == NIl, Self:New(), Nil)

    QDODocumentControl():OLE_SaveAsFile( oWord, ( Self:cDirDocLocal + cNomeAleatorio ), "", Self:retornaSenhaPadrao(), .F., oleWdFormatDocument )
    OLE_CloseFile( oWord )                
    lSucesso := Self:abreDocumentoDoServidorNoSmartClientSemImpressaoEValidacaoUsuario(Self:cDirDocLocal + cNomeAleatorio)
    Self:excluiArquivo(Self:cDirDocLocal + cNomeAleatorio)

    If lCloseLink
        OLE_CloseLink( oWord, .T. )
    EndIf

Return lSucesso

/*/{Protheus.doc} abreDocumentoDoServidorNoWebApp
Abre o Arquivo PDF no SmartClient em Tela via WEBAPP
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivo  , caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abreDocumentoDoServidorNoWebApp(cArquivo, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local cArquivoDOC := ""
    Local cArquivoPDF := ""
    Local cUsuario    := RetCodUsr()
    Local lCriouDoc   := .F.
    Local lCriouPDF   := .F.
    Local lExibeHelp  := .T.
    Local lSucesso    := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV

    cArquivo := Lower(AllTrim(cArquivo))
    lSucesso := Self:avaliaPEQdoViLiPDF(cArquivo, cDocumento, cRevisao)

    If lSucesso .AND. Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

	If lSucesso .AND. lPEEditDoc
        ExecBlock("QDOEDITDOC",,,{Self:cDirDocServer, cArquivo})
    Endif

    If lSucesso .AND. !Self:copiaParaDocNoServidor(cArquivo, @cArquivoDOC)
        lSucesso  := .F.
    ElseIf lSucesso
        lCriouDoc := .T.
    EndIf

    If lSucesso .AND. !Self:geraPDF(cArquivoDOC, @cArquivoPDF)
        lSucesso := .F.
    ElseIf lSucesso
        lCriouPDF := .T.
    EndIf

    If lCriouDoc
        Self:apagaArquivoServidor(cArquivoDOC, lExibeHelp)
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidorParaWEBAPP(cArquivoPDF)
        lSucesso := .F.
    EndIf

    If lCriouPDF .AND. !Self:apagaArquivoServidor(cArquivoPDF, lExibeHelp)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} abrePDFDoServidorNoWebApp
Abre o Arquivo PDF no WebApp em Tela
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivoPDF, caracter, nome do arquivo no diretório padrão de documentos do QDO no servidor
@param 02 - cDocumento , caracter, código do documento relacionado
@param 03 - cRevisao   , caracter, código da revisão do documento relacionada
@return lSucesso, lógico, indica se conseguiu realizar a abertura do documento em tela
/*/
METHOD abrePDFDoServidorNoWebApp(cArquivoPDF, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local cUsuario := RetCodUsr()
    Local lSucesso := .T.

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV

    cArquivo := Lower(AllTrim(cArquivo))
    lSucesso := Self:avaliaPEQdoViLiPDF(cArquivo, cDocumento, cRevisao)

    If lSucesso .AND. Self:lValidaUsuario .AND. !Self:validaUsoNoUsuario(cUsuario)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:validaImplantacao(.T.)
        lSucesso := .F.
    EndIf

    If lSucesso .AND. !Self:copiaArquivoDoServidorParaWEBAPP(cArquivoPDF)
        lSucesso := .F.  
    EndIf

    If lSucesso .AND. !Self:montaTelaExibicaoPDFNoSmartClient(cArquivoPDF, cDocumento, cRevisao, RetCodUsr())
        lSucesso := .F.
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} removeSenhaDocumentosServidor
Processa Implantação - Remove Senha de Todos os Arquivos do QDO
@author brunno.costa
@since  29/11/2021
@param 01 - lExibePergunta, lógico, indica se deve exibir a pergunta ApMsgYesNo a cada falha em arquivo
@param 02 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lSucesso, lógico, indica se conseguiu realizar a remoção de senha dos arquivos do servidor
/*/
METHOD removeSenhaDocumentosServidor(lExibePergunta, nCobertura) CLASS QDODocumentControl
    Local aArea      := GetArea()
    Local cAlias     := ""
    Local cErro      := ""
    Local lSucesso   := .T.
    Local nAtual     := 0
    Local nError     := 0
    Local nRegistros := 0
    Local oWord      := Nil

    Default lExibePergunta := .T.
    Default nCobertura     := 0

    If !Self:validaExistenciaDosParametrosSX6() .Or. nCobertura == 1
        lSucesso := .F.
        //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
        //STR0002 - "Execute o UPDDISTR para release mais recente ou crie os parâmetros no configurador conforme a documentação: MV_QDOMSOD, MV_QDOLOD e MV_QDOCPDF."
        Self:help("QDOEXISTPARAM1", STR0001, STR0002)
    EndIf

    If !Self:validaDicionario() .Or. nCobertura == 2
        lSucesso := .F.
        //STR0003 - "Falha na preparação do dicionário de dados do ambiente para uso da visualização de Documentos 'Internos no ERP'."
        //STR0004 - "Inclua a opção '4=Interna no ERP' no combobox do campo 'QAA_TPWORD' e renomeio o título do campo para 'Tipo Exib.'."
        Self:help("QDOVALIDDIC1", STR0003, STR0004)
    EndIf

    If lSucesso .AND. Self:validaParametroQDOUsaSenha()
        If lSucesso .AND. !Self:criaAliasArquivos(@cAlias, @nRegistros)
            lSucesso := .F.
        EndIf
        PutGlbValue( "QDODocumentControl_nRegistros_"+cEmpAnt+cFilAnt, Str(nRegistros) )

        While lSucesso .AND. !(cAlias)->(Eof())
            
            nAtual++
            PutGlbValue( "QDODocumentControl_nAtual_"+cEmpAnt+cFilAnt, Str(nAtual) )
            PutGlbValue( "QDODocumentControl_cArquivo_"+cEmpAnt+cFilAnt, AllTrim(Lower((cAlias)->QDH_NOMDOC)) )

            nError   := 0
            If !Empty((cAlias)->QDH_NOMDOC)
                lSucesso := Self:removeSenhaWord(AllTrim(Lower((cAlias)->QDH_NOMDOC)), @nError, @oWord)
            EndIf
            
            If !lSucesso
                cAuxVar := ""
                cErro   := Iif(nError == 2, " [" + STR0046 + "]", "["+Str(nError)+"]") //"Não encontrado no Servidor"
                VarBeginT("QDODocumentControl", "aArquivosErros")
                VarSetXD("QDODocumentControl", AllTrim(Lower((cAlias)->QDH_NOMDOC)), cErro)
                VarEndT("QDODocumentControl", "aArquivosErros")

                //STR0005 - "Ocorreu falha na remoção de senha do arquivo"
                //STR0006 - "deseja continuar o processo de remoção para os demais arquivos?"
                //STR0007 - "Deseja continuar?"
                If lExibePergunta .And. ApMsgYesNo(STR0005 - " '" + AllTrim(Lower((cAlias)->QDH_NOMDOC)) + "'" + cErro + ", " + STR0006, STR0007)
                    lSucesso := .T.
                ElseIf !lExibePergunta
                    lSucesso := .T.
                EndIf
            EndIf

            (cAlias)->(DbSkip())
        EndDo
        If oWord != Nil
            OLE_CloseLink( oWord, .T. )
        EndIf
        (cAlias)->(DbCloseArea())
    EndIf

    If lSucesso
        Self:registraRemocaoSenhaArquivosServidorNaSX6()
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} somenteRemoveSenhaDocumentosServidor
Processa Implantação - Remove Senha de Todos os Arquivos do QDO
@author brunno.costa
@since  29/11/2021
@return lSucesso, lógico, indica se conseguiu realizar a remoção de senha dos arquivos do servidor
/*/
METHOD somenteRemoveSenhaDocumentosServidor() CLASS QDODocumentControl
    Local aArea      := GetArea()
    Local cAlias     := ""
    Local cErro      := ""
    Local lCriou     := Nil
    Local lSucesso   := .T.
    Local nAtual     := 0
    Local nError     := 0
    Local nRegistros := 0
    Local oWord      := Nil

    If lSucesso .AND. !(lCriou := Self:criaAliasArquivos(@cAlias, @nRegistros))
        lSucesso := .F.
    EndIf
    PutGlbValue( "QDODocumentControl_nRegistros_"+cEmpAnt+cFilAnt, Str(nRegistros) )

    While lSucesso .AND. !(cAlias)->(Eof())
        
        nAtual++
        PutGlbValue( "QDODocumentControl_nAtual_"+cEmpAnt+cFilAnt, Str(nAtual) )
        PutGlbValue( "QDODocumentControl_cArquivo_"+cEmpAnt+cFilAnt, AllTrim(Lower((cAlias)->QDH_NOMDOC)) )

        nError   := 0
        If !Empty((cAlias)->QDH_NOMDOC)
            lSucesso := Self:removeSenhaWord(AllTrim(Lower((cAlias)->QDH_NOMDOC)), @nError, @oWord)
        EndIf
        
        If !lSucesso
            cAuxVar := ""
            cErro   := Iif(nError == 2, " [" + STR0046 + "]", "["+Str(nError)+"]") //"Não encontrado no Servidor"
            VarBeginT("QDODocumentControl", "aArquivosErros")
            VarSetXD("QDODocumentControl", AllTrim(Lower((cAlias)->QDH_NOMDOC)), cErro)
            VarEndT("QDODocumentControl", "aArquivosErros")

            //STR0005 - "Ocorreu falha na remoção de senha do arquivo"
            //STR0006 - "deseja continuar o processo de remoção para os demais arquivos?"
            //STR0007 - "Deseja continuar?"
            If ApMsgYesNo(STR0005 - " '" + AllTrim(Lower((cAlias)->QDH_NOMDOC)) + "'" + cErro + ", " + STR0006, STR0007)
                lSucesso := .T.
            EndIf
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    If oWord != Nil
        OLE_CloseLink( oWord, .T. )
    EndIf
    If lCriou
        (cAlias)->(DbCloseArea())
    EndIf

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} retornaSenhaPadrao
Retorna Senha Padrão Para Abrir e Salvar Documentos
@author brunno.costa
@since  29/11/2021
@return cSenha, caracter, senha padrão para leitura, edição e gravação de arquivos do QDO
/*/
METHOD retornaSenhaPadrao() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local cSenha   := IIf( Self:validaParametroQDOUsaSenha() .AND. !Self:validaImplantacao(.F.), "CELEWIN400", "" )
    RestArea(aArea)
Return cSenha

/*/{Protheus.doc} validaParametroQDOUsaSenha
Indica se os documentos elaborados pelo Modulo Controle de Documentos foram configurados paragravação com senha (MV_QSAVPSW - Descontinuado após QDODocumentControl)
@author brunno.costa
@since  29/11/2021
@return lReturn, lógico, indica se os documentos elaborados pelo Modulo Controle de Documentos foram configurados paragravação com senha (MV_QSAVPSW)
/*/
METHOD validaParametroQDOUsaSenha() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local lReturn  := AllTrim(SuperGetMV("MV_QSAVPSW",.F.,"1")) == "1" //1=Sim
    RestArea(aArea)
Return lReturn

/*/{Protheus.doc} validaParametroSenhasRemovidas
Indica se Já foi Realizada a Remoção de Senha dos Arquivos do SIGAQDO
@author brunno.costa
@since  29/11/2021
@return lReturn, lógico, Indica se Já foi Realizada a Remoção de Senha dos Arquivos do SIGAQDO
/*/
METHOD validaParametroSenhasRemovidas() CLASS QDODocumentControl
    Local aArea    := GetArea()
    Local lReturn  := SuperGetMV("MV_QDOCPDF",.F.,.F.)
    RestArea(aArea)
Return lReturn

/*/{Protheus.doc} validaInconsistenciaImplantacao
Valida Inconsistência de Implantação e Exibe Help
@author brunno.costa
@since  29/11/2021
@param 01 - lImplantado, lógico, retorna por referência se a exibição de documentos em tela foi implantada
@param 02 - lExibeHelp , lógico, indica se realizará a exibição de helps de erros em tela para os usuários
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lInconsistente, lógico, indica se a base está inconsistente
/*/
METHOD validaInconsistenciaImplantacao(lImplantado, lExibeHelp, nCobertura) CLASS QDODocumentControl
    Local aArea          := GetArea()
    Local lInconsistente := .F.
    
    Default lExibeHelp  := .T.
    Default lImplantado := .F.
    Default nCobertura  := 0

    If self:validaParametroSenhasRemovidas() .Or. nCobertura == 1 .Or. nCobertura == 2
        lImplantado := .T.
        If !Self:validaInstalacaoConversores(lExibeHelp)
            lInconsistente := .T.
            lImplantado    := .F.
        EndIf

        If !Self:validaExistenciaDosParametrosSX6() .Or. nCobertura == 1
            lInconsistente := .T.
            lImplantado    := .F.
            If (lExibeHelp)
                //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
                //STR0002 - "Execute o UPDDISTR para release mais recente ou crie os parâmetros no configurador conforme a documentação: MV_QDOMSOD, MV_QDOLOD e MV_QDOCPDF."
                Self:help("QDOEXISTPARAM2", STR0001, STR0002)
            EndIf
        EndIf

        If !Self:validaDicionario() .Or. nCobertura == 2
            lInconsistente := .T.
            lImplantado    := .F.
            If (lExibeHelp)
                //STR0001 - "Falha na preparação do ambiente para uso da visualização de Documentos 'Internos no ERP'."
                //STR0004 - "Inclua a opção '4=Interna no ERP' no combobox do campo 'QAA_TPWORD' e renomeio o título do campo para 'Tipo Exib.'."
                Self:help("QDOVALIDDIC2", STR0001, STR0004)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return lInconsistente

/*/{Protheus.doc} validaImplantacao
Valida Execução da Implantação para Exibição de Documentos "Interna no ERP" - Wizard: 'QDOWizPDF'
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição dos Helps de Falhas
@return lImplantado, lógico, indica se a exibição de documentos 'Interna no ERP' foi implantada com sucesso
/*/
METHOD validaImplantacao(lExibeHelp) CLASS QDODocumentControl
    Local lImplantado := .F.

    Self:validaInconsistenciaImplantacao(@lImplantado, lExibeHelp)
    If !lImplantado .AND. lExibeHelp
        //STR0008 - "Implantação não executada."
        //STR0009 - "Execute o implantador 'QDOWizPDF' a partir de um computador com o MS Office instalado para remover a senha de todos os documentos do SIGAQDO."
        Self:help("QDOVALIDIMPLANT", STR0008, STR0009)
    EndIf
Return lImplantado

/*/{Protheus.doc} validaInstalacaoConversores
Valida Instalação dos Conversores
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição dos Helps de Falhas
@param 02 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lInstalado, lógico, indica se existe pelo menos um conversor em PDF instalado (MS Office ou LibreOffice)
/*/
METHOD validaInstalacaoConversores(lExibeHelp, nCobertura) CLASS QDODocumentControl
    Local lInstalado := .T.

    Default nCobertura := 0

    If !Self:lServerLinux .AND. !Self:existeLibreOffice(.F.) .AND. !Self:existeMSOffice(.F.) .Or. nCobertura == 1
        lInstalado := .F.
        If lExibeHelp
            //STR0010 - "Falha na Conversão! O conversor de documento em PDF não está instalado no servidor."
            //STR0011 - "Solicite apoio do departamento de TI: é necessário seguir a documentação para instalação de um dos conversores de arquuivos .doc para .pdf no servidor de Aplicação do Protheus (MS Office ou LibreOffice)."
            Self:help("QDOVALIDCONVER", STR0010, STR0011)
        EndIf
    EndIf
Return lInstalado

/*/{Protheus.doc} apagaArquivo
Apaga Arquivo do servidor ou estação de trabalho
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@param 03 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivo(cArquivo, lServer, lExibeHelp) CLASS QDODocumentControl

    Local cCaminho    := ""
    Local lExcluido   := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroExclusaoArquivo(cArquivo, oError:Description, lServer, lExibeHelp), Break(oError) })

    Begin Sequence

        If lServer
            cCaminho  := Self:cDirDocServer + Lower(AllTrim(cArquivo))
        Else
            cCaminho  := Self:cDirDocLocal + Lower(AllTrim(cArquivo))
        EndIf

        If Self:existeArquivoWhereDinamico(cCaminho)
            lExcluido := Self:excluiArquivo(cCaminho)
        Else
            lExcluido := .T.
        EndIf
	
	Recover
        lExcluido := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lExcluido

/*/{Protheus.doc} apagaArquivoLocal
Apaga Arquivo no Computador Local
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivoLocal(cArquivo, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
Return Self:apagaArquivo(cArquivo, .F., lExibeHelp)

/*/{Protheus.doc} apagaArquivoServidor
Apaga Arquivo no Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
@return lExcluido, lógico, indica se o arquivo foi excluido com sucesso
/*/
METHOD apagaArquivoServidor(cArquivo, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
Return Self:apagaArquivo(cArquivo, .T., lExibeHelp)

/*/{Protheus.doc} erroExclusaoArquivo
Tratamento de Erro Durante Exclusão do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - cErro     , caracter, erro durante a exclusão do arquivo
@param 03 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@param 04 - lExibeHelp, lógico  , indica se deve realizar a exibição dos Helps de Falhas
/*/
METHOD erroExclusaoArquivo(cArquivo, cErro, lServer, lExibeHelp) CLASS QDODocumentControl
    Local cProbHelp := Iif(lServer, STR0012, STR0014) + " '" + cArquivo + "' : " + AllTrim(cErro) + "."
    Local cTitHelp  := Iif(lServer, "QDOEXCLARQ1", "QDOEXCLARQ2")
    
    Default lExibeHelp := .T.

    If lExibeHelp
        //STR0012 - "Falha na exclusão de arquivo do servidor"
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        //STR0014 - "Falha na exclusão de arquivo do computador local"
        Self:help(cTitHelp, cProbHelp, STR0013)
    EndIf
Return

/*/{Protheus.doc} validaExecucaoViaWebApp
Valida se a execução é via WEBAPP
@author brunno.costa
@since  10/05/2022
@Return lReturn, lógico, indica se a execução é via WEBAPP
/*/
METHOD validaExecucaoViaWebApp() CLASS QDODocumentControl
Return (GetRemoteType() == 5)

/*/{Protheus.doc} copiaArquivoDoServidor
Copia Arquivo do Servidor para o Computador Local
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoPDF, caracter, nome do Arquivo PDF do Servidor
@param 02 - lProtegida , lógico  , indica se o arquivo é protegido ou não
@param 03 - nCobertura , numérico, variável temporária para auxiliar cobertura
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoDoServidor(cArquivoPDF, lProtegida, nCobertura) CLASS QDODocumentControl

    Local bErrorBlock  := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivoPDF, oError:Description, 0), Break(oError)})
    Local lCopiou      := .F.

    Default lProtegida := .F.
    Default nCobertura := -1

    Begin Sequence

        If lProtegida .Or. nCobertura == 1
            lCopiou := Self:copiaProtegidaArquivo(Self:cDirDocServer + cArquivoPDF, Self:cDirDocLocal + cArquivoPDF)

        Else

            //Verificada falha em cliente ao tentar utilizar a copiaProtegida, processo não conseguiu fazer rename() no diretório tempo do AppServer no ambiente do cliente
            lCopiou := Self:copiaArquivo(Self:cDirDocServer + cArquivoPDF, Self:cDirDocLocal + cArquivoPDF, , , cArquivoPDF)

        EndIf

	Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

    //STR0015 - "Falha na cópia de arquivo do servidor"
    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    Iif(!lCopiou, Self:help("QDONOCOPY1", STR0015 + " '" + cArquivoPDF + "'.", STR0013), Nil)

Return lCopiou

/*/{Protheus.doc} copiaArquivoDoServidorParaWEBAPP
Copia Arquivo do Servidor para o Computador Local para WEBAPP
@author brunno.costa
@since  10/05/2022
@param 01 - cArquivoPDF, caracter, nome do Arquivo PDF do Servidor
@param 02 - nErrorAux  , número  , alternativa para cobertura de trecho de erro
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoDoServidorParaWEBAPP(cArquivoPDF, nErrorAux) CLASS QDODocumentControl

    Local lCopiou     := .F.

    Default nErrorAux  := CpyS2TW(Self:cDirDocServer + cArquivoPDF, .F.)

    //STR0015 - "Falha na cópia de arquivo do servidor"
    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    Iif(nErrorAux == 0, lCopiou := .T., Self:help("QDONOCOPY2", STR0015 + " '" + cArquivoPDF + "'.", STR0013))

Return lCopiou

/*/{Protheus.doc} copiaArquivoParaServidor
Copia Arquivo do Computador Local para o Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoLocal, caracter, nome do Arquivo Local para Copiar
@param 02 - cNovoNome    , caracter, nome do Arquivo Destino no Servidor
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaArquivoParaServidor(cArquivoLocal, cNovoNome) CLASS QDODocumentControl
    Local lCopiou := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivoLocal, oError:Description, 1), Break(oError) })

    Default cNovoNome  := cArquivoLocal

    Begin Sequence

        //STR0016 - "Falha na cópia de arquivo para o servidor"
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        Iif(Self:copiaProtegidaArquivo(Self:cDirDocLocal + cArquivoLocal, Self:cDirDocServer + cNovoNome), lCopiou := .T., Self:help("QDONOCOPY3", STR0016 + " '" + cArquivoLocal + "'.", STR0013))
    	
        Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lCopiou

/*/{Protheus.doc} copiaParaDocNoServidor
Copia Arquivo .CEL para .DOC ou .DOCX No Servidor
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, arquivo original .cel para cópia
@param 02 - cArquivoDOC, caracter, retorna por referência o nome do arquivo destino .doc que será criado
@Return lCopiou, lógico, indica se conseguiu realizar a cópia do arquivo
/*/
METHOD copiaParaDocNoServidor(cArquivo, cArquivoDOC) CLASS QDODocumentControl
    Local lCopiou := .F.
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroCopiaArquivo(cArquivo, oError:Description, 2), Break(oError) })

    Begin Sequence

        cArquivoDOC := StrTran(cArquivo, ".cel", "_random_tmp_" + cValToChar(Randomize( 10000, 11000 )) + ".doc")
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        //STR0017 - "Falha na cópia de arquivo .doc"
        //STR0018 - "para"
        //STR0019 - "no servidor." 
        Iif(Self:copiaProtegidaArquivo(Self:cDirDocServer + cArquivo, Self:cDirDocServer + cArquivoDOC), lCopiou := .T., Self:help("QDONOCOPY4", STR0017 + " '" + cArquivo + "' " + STR0018 + " '" + cArquivoDOC + "' " + STR0019, STR0013))
	
	Recover
        lCopiou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lCopiou

/*/{Protheus.doc} erroCopiaArquivo
Tratamento de Erro Durante Cópia do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, arquivo original .cel para cópia
@param 02 - cErro      , caracter, erro durante a cópia do arquivo
@param 03 - nOperacao  , número  , indica a operação onde ocorreu o erro: 
                        nOperacao == 0 -> Falha na cópia de arquivo do servidor
                        nOperacao == 1 -> Falha na cópia de arquivo para o servidor
                        nOperacao == 2 -> Falha na cópia de arquivo entre diretórios do servidor
@param 04 - nCobertura, numérico, variável temporária para auxiliar cobertura

/*/
METHOD erroCopiaArquivo(cArquivo, cErro, nOperacao, nCobertura) CLASS QDODocumentControl
    Default nCobertura := 0
    Default nOperacao  := 0

    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    If nOperacao == 2 .Or. nCobertura == 1
        //STR0020 = "Falha na cópia de arquivo entre diretórios do servidor"
        Self:help("QDOCOPARQ1", STR0020 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    ElseIf nOperacao == 1 .Or. nCobertura == 2
        //STR0016 - "Falha na cópia de arquivo para o servidor"
            Self:help("QDOCOPARQ2", STR0016 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    ElseIf nOperacao == 0 .Or. nCobertura == 3
        //STR0015 - "Falha na cópia de arquivo do servidor"
        Self:help("QDOCOPARQ3", STR0015 + " '" + cArquivo + "': " + AllTrim(cErro) + ".", STR0013)
    EndIf
Return

/*/{Protheus.doc} criaAliasArquivos
Cria Alias dos Arquivos para Remoção de Senhas
@author brunno.costa
@since  29/11/2021
@param 01 - cAlias    , caracter, retorna por referência o Alias Criado
@param 02 - nRegistros, número  , retorna por referência a quantidade de registros
@return lSucesso, lógico, indica se conseguiu realizar a criação do Alias
/*/
METHOD criaAliasArquivos(cAlias, nRegistros) CLASS QDODocumentControl
    Local aArea        := GetArea()
    Local bErrorBlock  := ErrorBlock({|oError| QDODocumentControl():erroCriacaoAlias(oError:Description), Break(oError)})
    Local lSucesso     := .T.
    Default nRegistros := 0

    cAlias            := GetNextAlias()

    Begin Sequence

        BeginSql Alias cAlias
            SELECT COUNT(QDH_NOMDOC) QUANTIDADE
            FROM (SELECT DISTINCT QDH_NOMDOC 
                    FROM %Table:QDH% 
                   WHERE QDH_DTOIE ='I' 	  
                     AND QDH_FILIAL = %xFilial:QDH%
                     AND %NotDel%) CONTAGEM
        EndSql

        nRegistros := (cAlias)->QUANTIDADE

        (cAlias)->(DbCloseArea())

        BeginSql Alias cAlias
            SELECT DISTINCT QDH_NOMDOC 
              FROM %Table:QDH% 
             WHERE QDH_DTOIE ='I'
               AND QDH_FILIAL = %xFilial:QDH%
               AND %NotDel%
            ORDER BY QDH_NOMDOC
        EndSql

    Recover
        lSucesso := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

    RestArea(aArea)

Return lSucesso

/*/{Protheus.doc} erroCriacaoAlias
Tratamento de Erro durante criação de Alias
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a criação do alias
/*/
METHOD erroCriacaoAlias(cErro) CLASS QDODocumentControl
    //STR0021 - "Falha durante identificação dos arquivos para remoção de senha"
    //STR0013 - "Solicite apoio do departamento de TI informando este erro."
    Self:help("QDONOALIAS", STR0021 + ": " + AllTrim(cErro) + ".", STR0013)
Return

/*/{Protheus.doc} existeArquivo
Valida Existência do Arquivo
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo para exclusão
@param 02 - lServer   , lógico  , indica se o arquivo está no servidor de aplicação do Protheus (.T.) ou no computador local (.F.)
@return lExiste, lógico, indica se existe o cArquivo de acordo com lServer
/*/
METHOD existeArquivo(cArquivo, lServer) CLASS QDODocumentControl
    Local lExiste := .F.
    If lServer
        lExiste := File(Self:cDirDocServer + cArquivo)
    Else
        lExiste := Self:existeArquivoWhereDinamico(Self:cDirDocLocal + cArquivo)
    EndIf
Return lExiste

/*/{Protheus.doc} existeArquivoWhereDinamico
Valida Existência do Arquivo com restes e Where Dinâmico: testa relativo ao caminho, depois no servidor e depois no client
Justificativa: vulnerabilidade quando usado GetTempPath(.T., .T.) retorna caminho absoluto do servidor
@author brunno.costa
@since  08/07/2025
@param 01 - cCaminho, caracter, caminho completo do arquivo
@return lExiste, lógico, indica se existe o cArquivo de acordo com lServer
/*/
METHOD existeArquivoWhereDinamico(cCaminho) CLASS QDODocumentControl
    Local lExiste := .F.
    lExiste := Iif(!lExiste, File(cCaminho, Nil, .T.), lExiste) //lChangeCase .T. - nWhere - Nil - Relativo ao cCaminho
    lExiste := Iif(!lExiste, File(cCaminho, Nil, .F.), lExiste) //lChangeCase .F. - nWhere - Nil - Relativo ao cCaminho
    lExiste := Iif(!lExiste, File(cCaminho,   1, .T.), lExiste) //lChangeCase .T. - nWhere -   1 - Server
    lExiste := Iif(!lExiste, File(cCaminho,   1, .F.), lExiste) //lChangeCase .F. - nWhere -   1 - Server
    lExiste := Iif(!lExiste, File(cCaminho,   2, .T.), lExiste) //lChangeCase .T. - nWhere -   2 - Local
    lExiste := Iif(!lExiste, File(cCaminho,   2, .F.), lExiste) //lChangeCase .F. - nWhere -   2 - Local
Return lExiste

/*/{Protheus.doc} existeArquivoForaDoRootPath
Identifica Se Existe Arquivo Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho  , caracter, caminho do arquivo fora do RootPath para validação
@param 02 - lExibeHelp, lógico  , indica se deve realizar a exibição do Help em caso de Erro
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lExiste, lógico, existe o cCaminho no servidor de aplicação do ERP
/*/
METHOD existeArquivoForaDoRootPath(cCaminho, lExibeHelp, nCobertura) CLASS QDODocumentControl

    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroVerificacaoExistenciaForaDoRootPath(cCaminho, oError:Description, lExibeHelp), Break(oError)})
    Local cArquivoBat := "qdo_existe_arquivo.bat"
    Local cArquivoNao := "qdo_nao_tem_arquivo.tmp"
    Local cArquivoTem := "qdo_tem_arquivo.tmp"
    Local cDiretorio  := ""
    Local cSufixo     := ""
    Local lExiste     := .F.
    Local lWaitRunSr  := .F.

    Default nCobertura := 0

    Begin Sequence

        cSufixo     := StrTran(Self:extraiArquivoDoCaminho(cCaminho), ".", "_") +  "_" + cValToChar(Randomize( 10000, 11000 )) 
        cArquivoBat := StrTran( cArquivoBat, ".bat", "_" + cSufixo + ".bat" )
        cArquivoNao := StrTran( cArquivoNao, ".tmp", "_" + cSufixo + ".tmp" )
        cArquivoTem := StrTran( cArquivoTem, ".tmp", "_" + cSufixo + ".tmp" )
        cDiretorio  := StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer
        If Self:criaBatExisteArquivoQDO(cArquivoBat) .Or. nCobertura == 1 .Or. nCobertura == 2
            lWaitRunSr  := WaitRunSrv('"' + cDiretorio + cArquivoBat + '"';
                                + ' "' + cCaminho   + '"';
                                + ' "' + cDiretorio + cArquivoTem + '" ';
                                + ' "' + cDiretorio + cArquivoNao + '" ', .T., Substr(cDiretorio, 1, RAT("\", cDiretorio) ) )

            If lWaitRunSr .Or. nCobertura == 1
                Self:apagaArquivoServidor(cArquivoBat, .F.)
                If Self:existeArquivo(cArquivoTem, .T.) .AND. !Self:existeArquivo(cArquivoNao, .T.)
                    lExiste := .T.
                ElseIf lExibeHelp
                        //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
                        //STR0023 - "Solicite apoio do departamento de TI informando este erro. Revise travamento nos arquivos do RootPath: qdo_tem_arquivo*.tmp e qdo_nao_tem_arquivo*.tmp."
                        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
                    Iif(Self:existeArquivo(cArquivoTem, .T.) .AND. Self:existeArquivo(cArquivoNao, .T.),;
                        Self:help("QDOEXISTARQ1", STR0022 + ": '" + cCaminho + "'.", STR0023),;
                        Self:help("QDOEXISTARQ2", STR0022 + ": '" + cCaminho + "'.", STR0024))
                EndIf
                Self:apagaArquivoServidor(cArquivoTem, .F.)
                Self:apagaArquivoServidor(cArquivoNao, .F.)
            ElseIf !lWaitRunSr .Or. nCobertura == 2
                //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
                //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
                Self:help("QDOEXISTARQ3", STR0022 + ": '" + cCaminho + "'.", STR0024)
            EndIf
        ElseIf lExibeHelp
            //STR0025 - "Falha na validação da implantação da leitura de documentos 'Internos no ERP'."
            //STR0026 - "Solicite apoio do departamento de TI informando este erro. Revise a permissão de acesso do usuário que executa o AppServere.exe ao diretório"
            Self:help("QDOEXISTARQ4", STR0025, STR0026 + " '" + cDiretorio + "'.")
        EndIf
	
	Recover
        lExiste := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lExiste

/*/{Protheus.doc} extraiArquivoDoCaminho
Extrai o Nome do Arquivo do Caminho
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho, caracter, caminho do arquivo
@return cArquivo, caracter, nome do arquivo
/*/
METHOD extraiArquivoDoCaminho(cCaminho) CLASS QDODocumentControl
    Local cArquivo  := cCaminho
    Local aCaminhos
    If At( "\", cCaminho ) > 0
        aCaminhos := StrTokArr( cCaminho, "\" )
        cArquivo  := aCaminhos[Len(aCaminhos)]
    ElseIf At( "/", cCaminho ) > 0
        aCaminhos := StrTokArr( cCaminho, "/" )
        cArquivo  := aCaminhos[Len(aCaminhos)]
    EndIf
Return cArquivo

/*/{Protheus.doc} erroVerificacaoExistenciaForaDoRootPath
Tratamento de Erro Durante Verificação da Existência de Arquivo no Servidor Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cCaminho  , caracter, caminho do arquivo
@param 02 - cErro     , caracter, erro durante a verificação de existência do arquivo fora do rootpath
@param 03 - lExibeHelp, lógico  , indica se deve realizar a exibição do Help em caso de Erro
/*/
METHOD erroVerificacaoExistenciaForaDoRootPath(cCaminho, cErro, lExibeHelp) CLASS QDODocumentControl
    Default lExibeHelp := .T.
    If lExibeHelp
        //STR0022 - "Não conseguimos confirmar a existência do arquivo no servidor de aplicação do TOTVS Protheus"
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:help("QDOROOTHPATH", STR0022 + " '" + cCaminho + "' : " + AllTrim(cErro) + ".", STR0024)
    EndIf
Return

/*/{Protheus.doc} existeLibreOffice
Valida Existência do LibreOffice no Server do Protheus
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição do Help em caso de Erro
@return lExiste, lógico, existe o LibreOffice instalado no diretório do MV_QDOLOD
/*/
METHOD existeLibreOffice(lExibeHelp) CLASS QDODocumentControl
    Local cCaminho := Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"C:\Program Files\LibreOffice\program\swriter.exe")))
    Local lExiste  := .F.
    If !Empty(cCaminho) .AND. Self:existeArquivoForaDoRootPath(cCaminho, lExibeHelp)
        lExiste := .T.
    EndIf
Return lExiste


/*/{Protheus.doc} existeMSOffice
Valida Existência do Microsoft Office
@author brunno.costa
@since  29/11/2021
@param 01 - lExibeHelp, lógico, indica se deve realizar a exibição do Help em caso de Erro
@return lExiste, lógico, existe o MS Office instalado no diretório do MV_QDOMSOD
/*/
METHOD existeMSOffice(lExibeHelp) CLASS QDODocumentControl
    Local cCaminho := Lower(AllTrim(SuperGetMV("MV_QDOMSOD",.F.,"C:\Program Files\Microsoft Office\Office15\WINWORD.EXE")))
    Local lExiste  := .F.
    If !Empty(cCaminho) .AND. Self:existeArquivoForaDoRootPath(cCaminho, lExibeHelp)
        lExiste := .T.
    EndIf
Return lExiste

/*/{Protheus.doc} criaBatExisteArquivoQDO
Cria Arquivo .bat Que Validará a Existência de Arquivos Fora do RootPath
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoBat, caracter, nome do arquivo para criação do .bat de verificação de existência de arquivos
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaBatExisteArquivoQDO(cArquivoBat) CLASS QDODocumentControl
    Local cTexto  := ""
    Local lCriado := .F.
    Default cArquivoBat := 'qdo_existe_arquivo' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.bat' 
    If Self:existeArquivo(cArquivoBat, .T.)
        lCriado := .T.
    Else
        //cTexto += ENTER + ' :: Desliga o echo dos comandos '
        cTexto += ENTER + ' @echo off '
        
        cTexto += ENTER + ' setlocal '
        
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como primeiro parametro de entrada. Ex:   teste.cmd "arquivo.tmp" '
        cTexto += ENTER + ' set FILE=%1 '
        
        //cTexto += ENTER + ' :: Definicao dos arquivos de reposta. Estes arquivos devem estar no "rootpath" para facilitar a sua leitura '
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como segundo parametro de entrada. '
        cTexto += ENTER + ' set RESP_OK=%2 '
        //cTexto += ENTER + ' :: Recebe o nome do arquivo como terceiro parametro de entrada. '
        cTexto += ENTER + ' set RESP_NOK=%3 '
        
        //cTexto += ENTER + ' :: Remove respostas anteriores '
        cTexto += ENTER + ' del /F %RESP_OK% 2> NUL '
        cTexto += ENTER + ' del /F %RESP_NOK% 2> NUL '
        
        //cTexto += ENTER + ' :: VerIFica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_OK% ( '
        cTexto += ENTER + '   echo Nao deveria existir OK: %RESP_OK% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_NOK% ( '
        cTexto += ENTER + '   echo Nao deveria existir NOK: %RESP_NOK% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo existe '
        cTexto += ENTER + ' IF EXIST %FILE% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Encontrou o arquivo %FILE% '
        cTexto += ENTER + '   echo %FILE% >> %RESP_OK% '
        cTexto += ENTER + ' ) ELSE ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Nao encontrou o arquivo %FILE% '
        cTexto += ENTER + '   echo %FILE% >> %RESP_NOK% '
        cTexto += ENTER + ' ) '
        
        //cTexto += ENTER + ' :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + ' IF EXIST %RESP_OK% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+']Criou o arquivo %RESP_OK% '
        cTexto += ENTER + ' ) ELSE ( '

        //cTexto += ENTER + '   :: Verifica se o arquivo resposta existe '
        cTexto += ENTER + '   IF EXIST %RESP_NOK% ( '
        cTexto += ENTER + '     echo [QDODocumentControl] ['+cArquivoBat+']Criou o arquivo %RESP_NOK% '
        cTexto += ENTER + '   ) ELSE ( '
        cTexto += ENTER + '     echo [QDODocumentControl] ['+cArquivoBat+']Nao criou resposta para o arquivo: %FILE% '
        cTexto += ENTER + '     GOTO END_ERR '
        cTexto += ENTER + '   ) '
        cTexto += ENTER + ' ) '
        
        cTexto += ENTER + ' GOTO END_OK '
        
        //cTexto += ENTER + ' :: Final de execucao ERR '
        cTexto += ENTER + ' :END_ERR '
        cTexto += ENTER + ' echo [QDODocumentControl] ['+cArquivoBat+'] Saindo com ERRO '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 1 '
        cTexto += ENTER + ' GOTO END '
        
        //cTexto += ENTER + ' :: Final de execucao OK '
        cTexto += ENTER + ' :END_OK '
        
        cTexto += ENTER + ' :END '
        
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 0  '

        If !Self:lLogConsole
            cTexto := StrTran(cTexto, " echo ", " REM ")
            cTexto := StrTran(cTexto, " REM %FILE% ", " echo %FILE% ")
        EndIf

        If MemoWrite( Self:cDirDocServer + cArquivoBat, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} criaScriptLibreOfficeCMD
Cria Arquivo .bat Que Converterá o .Cel em PDF via LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoBat, caracter, nome do arquivo para criação do .bat de conversão de arquivos via LibreOffice
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaScriptLibreOfficeCMD(cArquivoBat) CLASS QDODocumentControl

    Local cTexto      := ""
    Local lCriado     := .F.
	Local lDocsNaRede := Left(AllTrim(GetSrvProfString( "RootPath", "\")), 2) == "\\" //Controle de gereção do .PDF na rede com rootpath mapeado

    Default cArquivoBat := 'qdo_libreoffice_to_pdf' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.bat' 

    If Self:existeArquivo(cArquivoBat, .T.)
        lCriado := .T.
    Else
        cTexto += ENTER + ' @echo off '
        cTexto += ENTER + ' setlocal '
        cTexto += ENTER + ' set INPUT=%1 '
        cTexto += ENTER + ' set OUTPUT=%2 '
        cTexto += ENTER + ' set FILENAME=%3 '

        cTexto += ENTER + ' del /F %OUTPUT% 2> NUL '

        If lDocsNaRede
            cTexto += ENTER + ' cd "' + GetTempPath(.F.) + '"'
        Else
            
            //Ajuste para funcionar em execução de Serviço (sem modo console do appserver)
            If !Self:lServerLinux .AND. "C:" <> Left(StrTran(GetSrvProfString( "RootPath", "\"), "/", "\"), 2)
                cTexto += ENTER + Left(StrTran(GetSrvProfString( "RootPath", "\"), "/", "\"), 2)
            EndIf

            cTexto += ENTER + ' cd "' + StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer + '"'
        EndIf

        cTexto += ENTER + '"' + Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"C:\Program Files\LibreOffice\program\swriter.exe"))) + '" --headless --convert-to pdf %INPUT% '

        If lDocsNaRede
            cTexto += ENTER + ' copy %FILENAME% %OUTPUT% /y '
            cTexto += ENTER + ' del %FILENAME% /q '
        EndIf

        cTexto += ENTER + ' IF EXIST %OUTPUT% ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+'] Criou o arquivo %OUTPUT% '
        cTexto += ENTER + ' ) ELSE ( '
        cTexto += ENTER + '   echo [QDODocumentControl] ['+cArquivoBat+'] Nao criou o arquivo %OUTPUT% '
        cTexto += ENTER + '   GOTO END_ERR '
        cTexto += ENTER + ' ) '
        
        cTexto += ENTER + ' GOTO END_OK '
        cTexto += ENTER + ' :END_ERR '
        cTexto += ENTER + ' echo [QDODocumentControl] ['+cArquivoBat+'] Saindo com ERRO '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 1 '
        cTexto += ENTER + ' GOTO END '
        cTexto += ENTER + ' :END_OK '
        cTexto += ENTER + ' :END '
        cTexto += ENTER + ' endlocal '
        cTexto += ENTER + ' exit /B 0  '

        If !Self:lLogConsole
            cTexto := StrTran(cTexto, " echo ", " REM ")
            cTexto := StrTran(cTexto, " REM %FILE% ", " echo %FILE% ")
        EndIf

        If MemoWrite( Self:cDirDocServer + cArquivoBat, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} criaScriptMSOfficePowerShell
Cria Arquivo .ps1 Que Converterá o .Cel em PDF via MS Office / PowerShell
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoPS, caracter, nome do arquivo para criação do .ps1 de conversão de arquivos via MS Office
@return lCriado, lógico, identifica se o arquivo está criado após a execução
/*/
METHOD criaScriptMSOfficePowerShell(cArquivoPS) CLASS QDODocumentControl

    Local cTexto     := ""
    Local lCriado    := .F.

    Default cArquivoPS := 'qdo_msoffice_to_pdf' + "_" + cValToChar(Randomize( 10000, 11000 )) + '.ps1' 

    If Self:existeArquivo(cArquivoPS, .T.)
        lCriado := .T.
    Else

        cTexto += ENTER + ' param($INPUTAUX, $OUTPUT) '
        cTexto += ENTER + ' $word = New-Object -ComObject Word.Application '
        cTexto += ENTER + ' $word.Visible = $false '
        cTexto += ENTER + ' $doc = $word.Documents.Open("$INPUTAUX") '
        cTexto += ENTER + ' #Creates the PDF file '
        cTexto += ENTER + ' $name = $OUTPUT '
        cTexto += ENTER + ' $doc.SaveAs($name, 17) '
        cTexto += ENTER + ' $doc.Close() '
        cTexto += ENTER + ' $word.Quit() '

        If MemoWrite( Self:cDirDocServer + cArquivoPS, cTexto )
            lCriado := .T.
        EndIf
    EndIf
Return lCriado

/*/{Protheus.doc} geraPDF
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDF(cArquivo, cArquivoPDF) CLASS QDODocumentControl
    Local lGerou     := .F.

    If Self:validaImplantacao(.T.) .AND. Self:existeArquivo(cArquivo, .T.)
        cArquivoPDF := StrTran(cArquivo   , '.docx', ".pdf") 
        cArquivoPDF := StrTran(cArquivoPDF, '.doc' , ".pdf")
        If Self:lServerLinux
            lGerou := Self:geraPDFComLibreOfficeEmLinux(Lower(cArquivo), Lower(cArquivoPDF))
        Else
            If Self:existeMSOffice(.F.)
                lGerou := Self:geraPDFComMSOffice(cArquivo, cArquivoPDF)
            EndIf

            If !lGerou .AND. Self:existeLibreOffice(.F.)
                lGerou := Self:geraPDFComLibreOffice(cArquivo, cArquivoPDF)
            EndIf
        Endif
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComLibreOffice
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - LibreOffice
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComLibreOffice(cArquivo, cArquivoPDF, nCobertura) CLASS QDODocumentControl
    Local cArquivoBat               := 'qdo_libreoffice_to_pdf_' + AllTrim(StrTran(cArquivo, ".", "_")) + '.bat'
    Local cDiretorio                :=  StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer
    Local cInput                    := cArquivo
    Local cOutput                   := cArquivoPDF
    Local lCriaScriptLibreOfficeCMD := Self:criaScriptLibreOfficeCMD(cArquivoBat)
    Local lGerou                    := .F.
    Local lLock                     := .F.
    Local lWaitRunSr                := .F.
    Local nMaxTentat                := 10
    Local nTentativa                := 0
    Local nTentLock                 := 0

    Default nCobertura := 0

    If lCriaScriptLibreOfficeCMD .Or. nCobertura == 1 .Or. nCobertura == 2
        //Tenta novamente devido possibilidade de em ambiente CLOUD ocorrer conversão simultânea em mais de um AppServer.EXE
        //O LibreOffice não é consistente neste cenário, ocorrem casos de conversões serem perdidas
        While !(lLock:=LockByName("QDODocumentControl_geraPDFComLibreOffice", .F., .F., .T.)) .AND. nTentLock<(10*nMaxTentat)
            nTentLock++
            Sleep(500)
        EndDo 

		//STR0058 - "Falha na tentativa de LockByName QDODocumentControl_geraPDFComLibreOffice durante geração de arquivo PDF via LibreOffice. Reinicie o AppServer, DbAccess e License Server assim que possível e tente novamente."
        Iif(!lLock .And. nTentLock>=(10*nMaxTentat), Self:logMsg("QDOPDFLIBRE4", STR0058, ""), Nil)

        If lLock .OR. nTentLock>=(10*nMaxTentat) .Or. nCobertura == 1 .Or. nCobertura == 2
            For nTentativa := 1 to nMaxTentat 
                lWaitRunSr := WaitRunSrv('"' + cDiretorio + cArquivoBat + '"';
                                      + ' "' + cDiretorio + cInput  + '"';
                                      + ' "' + cDiretorio + cOutput + '" ';
                                      + ' "' + cArquivoPDF + '" ', .T., Substr(cDiretorio, 1, RAT("\", cDiretorio) ))
                If lWaitRunSr .Or. nCobertura == 1
                    //STR0027 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via LibreOffice."
                    //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                    Iif(Self:existeArquivo(cArquivoPDF, .T.), lGerou := .T., Self:logMsg("QDOPDFLIBRE1", STR0027, STR0028))
                ElseIf !lWaitRunSr .Or. nCobertura == 2
                    //STR0029 - "Falha durante tentativa de conversão do arquivo em PDF via LibreOffice."
                    //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                    Self:logMsg("QDOPDFLIBRE2", STR0029, STR0028)
                EndIf
                If lGerou
                    Exit
                Else
                    Sleep(500)
                EndIf
            Next
            UnLockByName("QDODocumentControl_geraPDFComLibreOffice", .F., .F., .T.)
        EndIf
        Self:apagaArquivoServidor(cArquivoBat, .F.)
    ElseIf !lCriaScriptLibreOfficeCMD .Or. nCobertura == 3
        //STR0030 - "Falha durante criação do script de conversão do arquivo em PDF via LibreOffice."
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:logMsg("QDOPDFLIBRE3", STR0030, STR0024)
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComLibreOfficeEmLinux
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - LibreOffice
@author brunno.costa
@since  20/09/2022
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComLibreOfficeEmLinux(cArquivo, cArquivoPDF, nCobertura) CLASS QDODocumentControl
    Local cDiretorio := StrTran(GetSrvProfString( "RootPath", "/"), "\", "/") + Self:cDirDocServer
    Local cInput     := cArquivo
    Local csWriter   := Lower(AllTrim(SuperGetMV("MV_QDOLOD",.F.,"/usr/lib64/libreoffice/program/swriter")))
    Local lGerou     := .F.
    Local lLock      := .F.
    Local nMaxTentat := 10
    Local nTentativa := 0
    Local nTentLock  := 0
    Local lWaitRunSr := .F.

    Default nCobertura := 0

    //Tenta novamente devido possibilidade de em ambiente CLOUD ocorrer conversão simultânea em mais de um AppServer.EXE
    //O LibreOffice não é consistente neste cenário, ocorrem casos de conversões serem perdidas
    While !(lLock:=LockByName("QDODocumentControl_geraPDFComLibreOfficeEmLinux", .F., .F., .T.)) .AND. nTentLock<(10*nMaxTentat)
        nTentLock++
        Sleep(500)
    EndDo 
    If lLock .Or. nCobertura == 1 .Or. nCobertura == 2
        For nTentativa := 1 to nMaxTentat 
            csWriter   := Iif(nMaxTentat == nTentativa .OR. ".exe"$csWriter .OR. Empty(csWriter), "/usr/lib64/libreoffice/program/swriter", csWriter)
            lWaitRunSr := WaitRunSrv(lower(csWriter + ' --headless --convert-to pdf "' + cDiretorio + cInput  + '"'), .T., cDiretorio)
            If lWaitRunSr .Or. nCobertura == 1
                //STR0027 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via LibreOffice."
                //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                Iif(Self:existeArquivo(cArquivoPDF, .T.),lGerou := .T., Self:logMsg("QDOEXISTARQ5", STR0027, STR0028))
            ElseIf !lWaitRunSr .Or. nCobertura == 2
                //STR0029 - "Falha durante tentativa de conversão do arquivo em PDF via LibreOffice."
                //STR0028 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOLOD' e os direitos de acesso do usuário que executa o AppServer.exe."
                Self:logMsg("QDOEXISTARQ6", STR0029, STR0028)
            EndIf
            If lGerou
                Exit
            Else
                Sleep(500)
            EndIf
        Next
        UnLockByName("QDODocumentControl_geraPDFComLibreOfficeEmLinux", .F., .F., .T.)
    EndIf

Return lGerou

/*/{Protheus.doc} geraPDFComMSOffice
Gera Arquivo PDF a Partir do Arquivo .cel (.doc / .docx) Sem Senha - Microsoft Office
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo   , caracter, nome do arquivo do servidor no diretório padrão de documentos do QDO para geração de PDF
@param 02 - cArquivoPDF, caracter, retorna por referência o nome do arquivo PDF criado
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lGerou, lógico, indica se conseguiu gerar o arquivo PDF
/*/
METHOD geraPDFComMSOffice(cArquivo, cArquivoPDF, nCobertura) CLASS QDODocumentControl

    Local cArquivoPS                    := 'qdo_msoffice_to_pdf_' + AllTrim(StrTran(cArquivo, ".", "_")) + '.ps1'
    Local cDiretorio                    := StrTran(GetSrvProfString( "RootPath", "\"), "/", "\") + Self:cDirDocServer
    Local cDirScript                    := ""
    Local cInput                        := cArquivo
    Local cOutput                       := cArquivoPDF
    Local lCopyUNCPs                    := .F.
    Local lCriaScriptMSOfficePowerShell := Self:criaScriptMSOfficePowerShell(cArquivoPS)
    Local lDirUNC                       := Left(cDiretorio, 2) == "\\"
    Local lGerou                        := .F.
    Local lWaitRunSr                    := .F.

    Default nCobertura := 0

    If lCriaScriptMSOfficePowerShell .Or. nCobertura == 1 .Or. nCobertura == 2
        If  lDirUNC
            cDirScript := GetTempPath(.F.)
            lCopyUNCPs := __CopyFile(cDiretorio + cArquivoPS, cDirScript + cArquivoPS,1,1)
        Else
            cDirScript := cDiretorio
        EndIf
        
        lWaitRunSr := WaitRunSrv("PowerShell -NonInteractive -File ";
                               + '"' + cDirScript + cArquivoPS + '"' ;
                               + " -INPUTAUX "  + '"' + cDiretorio + cInput + '"';
                               + " -OUTPUT " + '"' + cDiretorio + cOutput + '"';
                               , .T., Substr(cDirScript, 1, RAT("\", cDirScript) ))

        If lWaitRunSr .Or. nCobertura == 1
            If  lDirUNC
                fErase(cDirScript + cArquivoPS)
            EndIf

            Self:apagaArquivoServidor(cArquivoPS, .F.)
            
            //STR0031 - "Arquivo PDF inexistente após tentativa de conversão para exibição em tela via MS Office."
            //STR0032 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOMSOD' e os direitos de acesso do usuário que executa o AppServer.exe."
            Iif(Self:existeArquivo(cArquivoPDF, .T.), lGerou := .T., Self:logMsg("QDOEXISTARQ7", STR0031, STR0032))
        ElseIf !lWaitRunSr .Or. nCobertura == 2 
            //STR0033 - "Falha durante tentativa de conversão do arquivo em PDF via MS Office."
            //STR0032 - "Solicite apoio do departamento de TI informando este erro. Revise o parâmetro 'MV_QDOMSOD' e os direitos de acesso do usuário que executa o AppServer.exe."
            Self:logMsg("QDOEXISTARQ8", STR0033, STR0032)
        EndIf
    ElseIf !lCriaScriptMSOfficePowerShell .Or. nCobertura == 3
        //STR0034 - "Falha durante criação do script de conversão do arquivo em PDF via MS Office."
        //STR0024 - "Solicite apoio do departamento de TI informando este erro. Revise os direitos de acesso do usuário que executa o AppServer.exe."
        Self:logMsg("QDOEXISTARQ9", STR0034, STR0024)
    EndIf

Return lGerou

/*/{Protheus.doc} removeSenhaWord
Remove Senha do Arquivo do Word
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivo  , caracter, nome do arquivo do servidor para remoção de senha
@param 02 - nError    , número  , retorna por referência o erro ocorrido
    1 - Arquivo não foi salvo pelo OLE_SaveAsFile
    2 - Arquivo não foi encontrado no servidor
    3 - Error.log no processo de remoção de senhas
@param 03 - oWord     , objeto  , objeto com link para MS Office.
@param 04 - lCloseLink, lógico  , indica se deve fechar o link aberto com o Word
@param 05 - cSaveFormat   , Caracter       , formato para salvar o arquivo
    17  - PDF
    16  - Default MS Office Utilizado
    0   - MS Office 97-2003 (.doc)
	... - HTML
@return lRemoveu, lógico, indica se conseguiu remover a senha do arquivo
/*/

METHOD removeSenhaWord(cArquivo, nError, oWord, lCloseLink, cSaveFormat) CLASS QDODocumentControl
    Local lRemoveu    := .F.
    Local cEditor     := "TMsOleWord97"
    Local lReadOnly   := .F.
    Local cPassword   := IIf( GetMV("MV_QSAVPSW",.F.,"1") == "1","CELEWIN400","" )
    Local cArquivoTMP := ""
    Local nError      := 0
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroRemocaoDeSenha(oError:Description), Break(oError) })

    Default lCloseLink  := .F.
    Default cSaveFormat := oleWdFormatDocument

    Begin Sequence

        cArquivoTMP := StrTran(cArquivo   , ".doc", ".tmp")
        cArquivoTMP := StrTran(cArquivoTMP, ".cel", ".tmp")

        If Self:existeArquivo(cArquivo, .T.)
            Self:copiaArquivoDoServidor(cArquivo, .T.)
            oWord := Iif(oWord==Nil, OLE_CreateLink( cEditor ), oWord)
            OLE_OpenFile( oWord, Self:cDirDocLocal + cArquivo, lReadOnly, cPassword, cPassword )
		    Self:OLE_SaveAsFile( oWord, Self:cDirDocLocal + cArquivoTMP, "", "", .F., cSaveFormat, .F., .T.)

            OLE_CloseFile( oWord )

            If Self:existeArquivo(cArquivoTMP, .F.)
                Self:apagaArquivoServidor(cArquivo, .T.)
                Self:copiaArquivoParaServidor(cArquivoTMP, cArquivo)
                Self:apagaArquivoLocal(cArquivo, .T.)
                Self:apagaArquivoLocal(cArquivoTMP, .T.)
                lRemoveu := .T.
            Else
                nError := 1
            EndIf

            If lCloseLink
                If oWord != Nil
                    OLE_CloseLink( oWord, .T. )
                EndIf
            EndIf
        Else
            nError := 2
        EndIf
        
	Recover
        lRemoveu := .F.
        nError   := 3

	End Sequence
    ErrorBlock(bErrorBlock)

Return lRemoveu

/*/{Protheus.doc} erroRemocaoDeSenha
Erro no Processo de Remoção de Senha
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a montagem do arquivo em tela
/*/
METHOD erroRemocaoDeSenha(cErro) CLASS QDODocumentControl
    //STR0035 - "Falha no processo de remoção de senha"
    //STR0036 - "É necessário instalar o MS Office no computador local."
    Self:help("QDOREMOVESENHA", STR0035 + ": " + AllTrim(cErro) + ".", STR0036)
Return 

/*/{Protheus.doc} retornaBuild
Retorna Build do Ambiente
@author brunno.costa
@since  29/11/2021
@return nRet, número, número identificador da Build do sistema
/*/

METHOD retornaBuild() CLASS QDODocumentControl
	Local cBuild := GetBuild()
	Local nEnd
    Local nRet   := 0
		
	While ( At( ".", cBuild ) > 0 )
		nEnd   := At( ".", cBuild ) + 1
		cBuild := SubStr( cBuild, nEnd )		
	EndDo
	
	cBuild := SubStr( cBuild, 1, 2 )
	nRet   := Val( cBuild )
Return nRet

/*/{Protheus.doc} registraRemocaoSenhaArquivosServidorNaSX6
Registra a Implantação em Parâmetro da SX6
@author brunno.costa
@since  29/11/2021
/*/

METHOD registraRemocaoSenhaArquivosServidorNaSX6() CLASS QDODocumentControl
    Local aArea    := GetArea()
    If FWSX6Util():ExistsParam( "MV_QDOCPDF" )
	    PutMV("MV_QDOCPDF", .T.)
    EndIf
    If FWSX6Util():ExistsParam( "MV_QSAVEDC" ) .And. !Self:existeMSOffice(.F.) .And. Self:existeLibreOffice(.F.)
	    PutMV("MV_QSAVEDC", 3)
    EndIf
    RestArea(aArea)
Return

/*/{Protheus.doc} validaExistenciaDosParametrosSX6
Verifica a Existência de Parâmetros na SX6
@author brunno.costa
@since  29/11/2021
@return lExistem, lógico, indica se existem todos os parâmetros do processo na SX6
/*/

METHOD validaExistenciaDosParametrosSX6() CLASS QDODocumentControl
    Local aArea       := GetArea()
    Local aParametros := {"MV_QDOMSOD","MV_QDOLOD","MV_QDOCPDF"}
    Local lExistem    := .T.
    Local nParametro  := 0
    Local nTotal      := Len(aParametros)
    For nParametro := 1 to nTotal
        If !FWSX6Util():ExistsParam( aParametros[nParametro] )
            lExistem := .F.
            Exit
        EndIf
    Next
    RestArea(aArea)
Return lExistem

/*/{Protheus.doc} validaDicionario
Verifica o Tratamento de Dicionário no Campo QAA_TPWORD, retornando true quando existe a opção 4 = Leitura Interna no ERP...
@author brunno.costa
@since  29/11/2021
@return lExistem, lógico, indica se o dicionário de dados está compatibilizado
/*/

METHOD validaDicionario() CLASS QDODocumentControl
Return ("4="$GetSx3Cache("QAA_TPWORD","X3_CBOX"))

/*/{Protheus.doc} help
Exibe Help em Tela ou Log no Console.Log
@author brunno.costa
@since  29/11/2021
@param 01 - cTitulo , caracter, título do Help/Log pra exibição
@param 02 - cErro   , caracter, mensagem de problema
@param 03 - cSolucao, caracter, mensagem de solução
@param 04 - lSoLog  , lógico  , indica se deve ser exibido só o LogMsg ou o Help
@param 05 - nCobertura, numérico, variável temporária para auxiliar cobertura
/*/
METHOD help(cTitulo, cErro, cSolucao, lSoLog, nCobertura) CLASS QDODocumentControl
    
    Local cMensagem := ""

    Default lSoLog     := .F.
    Default nCobertura := 0

    If GetRemoteType() != -1 .AND. !IsBlind() .and. !lSoLog .And. nCobertura != 2 .And. nCobertura != 3 .OR. nCobertura == 1
        cErro    := OemToAnsi(cErro)
        cSolucao := OemToAnsi(cSolucao)
        Help( " ", 1, cTitulo,,cErro,1, 1, NIL, NIL, NIL, NIL, NIL, {cSolucao})
        
        cMensagem := "[" + cTitulo + "] " + STR0037 + ": " + cErro + ENTER
        If !Empty(cSolucao)
            cMensagem += "[" + cTitulo + "] " + STR0038 + ": " + cSolucao
        EndIf

        Self:logMsgNaDocsDoServidor(cTitulo, cMensagem, "QDODocumentControlLog=" + GetSrvProfString("QDODocumentControlLog", "0"), "help", "log_generico")

    ElseIf !lSoLog .OR. nCobertura == 2
        If !Empty(cSolucao)
            MessageBox( STR0037 + ": " + cErro + ENTER + STR0038 + ": " + cSolucao, cTitulo, MB_ICONEXCLAMATION)
        Else
            MessageBox( STR0037 + ": " + cErro, cTitulo, MB_ICONEXCLAMATION )
        EndIf

        cMensagem := "[" + cTitulo + "] " + STR0037 + ": " + cErro + ENTER
        If !Empty(cSolucao)
            cMensagem += "[" + cTitulo + "] " + STR0038 + ": " + cSolucao
        EndIf

        Self:logMsgNaDocsDoServidor(cTitulo, cMensagem, "QDODocumentControlLog=" + GetSrvProfString("QDODocumentControlLog", "0"), "MessageBox", "log_generico")

    Else
        Self:logMsg(cTitulo, cErro, cSolucao)

    EndIf

    Self:cErrorMessage := cTitulo + ": " + cErro + Iif(!Empty(cSolucao), " - " + cSolucao, "")
    
Return

/*/{Protheus.doc} logMsg
Exibe LOG no Console.log
@author brunno.costa
@since  29/11/2021
@param 01 - cTitulo , caracter, título do Help/Log pra exibição
@param 02 - cErro   , caracter, mensagem de problema
@param 03 - cSolucao, caracter, mensagem de solução
/*/
METHOD logMsg(cTitulo, cErro, cSolucao) CLASS QDODocumentControl
    Local cMensagem := ""
    cErro    := OemToAnsi(cErro)
    cSolucao := OemToAnsi(cSolucao)
    If GetSrvProfString("QDODocumentControlLog", "0") == "1"
        LogMsg(cTitulo, 0, 0, 1, '', '', "[" + cTitulo + "] " + STR0037 + ": " + cErro) //Problema
        If !Empty(cSolucao)
            cMensagem += "[" + cTitulo + "] " + STR0038 + ": " + cSolucao
            LogMsg(cTitulo, 0, 0, 1, '', '', "[" + cTitulo + "] " + STR0038 + ": " + cSolucao) //Solucao
        EndIf
    EndIf

    cMensagem := "[" + cTitulo + "] " + STR0037 + ": " + cErro + ENTER
    If !Empty(cSolucao)
        cMensagem += "[" + cTitulo + "] " + STR0038 + ": " + cSolucao
    EndIf
    Self:logMsgNaDocsDoServidor(cTitulo, cMensagem, "QDODocumentControlLog=" + GetSrvProfString("QDODocumentControlLog", "0"), "logMsg", "log_generico")
Return 

/*/{Protheus.doc} logMsgNaDocsDoServidor
Grava Log na Pasta /Docs (Self:cDirDocServer) do Servidor, com o nome do arquivo baseado no nome do arquivo original - Sufixo _qdoexepction.qlog
@author brunno.costa
@since  01/08/2025
@param 01 - cTitulo  , caracter, título do Help/Log pra exibição
@param 02 - cMensagem, caracter, mensagem exibida para usuário com log
@param 03 - cMsgCompl, caracter, mensagem complementar para o log
@param 04 - cTipo    , caracter, tipo do log, usado para identificar o log
@param 05 - cCaminho , caracter, caminho do arquivo original que está sendo logado
/*/
METHOD logMsgNaDocsDoServidor(cTitulo, cMensagem, cMsgCompl, cTipo, cCaminho) CLASS QDODocumentControl
    
    Local cJson      := ""
    Local cNomeLog   := ""
    Local cOriginal  := Self:extraiArquivoDoCaminho(cCaminho)
    Local oDadosJson := JsonObject():New()
    Local cDataHora  := DtoS(Date()) + " - " + Time() + " - " + cTipo

    cNomeLog := Self:cDirDocServer + AllTrim(StrTran(cOriginal, ".", "_")) + "_qdoexepction.qlog"

    cJson := MemoRead( cNomeLog )
    If !Empty(cJson)
        oDadosJson:FromJson(cJson)
    EndIf

    oDadosJson[cTitulo           ] := Iif(oDadosJson[cTitulo] == Nil, JsonObject():New(), oDadosJson[cTitulo] )
    oDadosJson[cTitulo, cDataHora] := JsonObject():New()
    oDadosJson[cTitulo, cDataHora, 'usuarioProtheus'           ] := RetCodUsr()
    oDadosJson[cTitulo, cDataHora, 'nomeUsuarioProtheus'       ] := UsrRetName(RetCodUsr())
    oDadosJson[cTitulo, cDataHora, 'usuarioSistemaOperacional' ] := LogUserName()
    oDadosJson[cTitulo, cDataHora, 'nomeComputador'            ] := GetComputerName()
    oDadosJson[cTitulo, cDataHora, 'rotinaProtheus'            ] := FunName()
    oDadosJson[cTitulo, cDataHora, 'Mensagem Usuario'          ] := cMensagem
    oDadosJson[cTitulo, cDataHora, 'Mensagem Complementar'     ] := cMsgCompl
    oDadosJson[cTitulo, cDataHora, 'Tipo'                      ] := cTipo
    oDadosJson[cTitulo, cDataHora, 'Registro QDH'              ] := Self:retornaRegistroQDH()
    oDadosJson[cTitulo, cDataHora, 'CallStack'                 ] := Self:callStack(15)

    MemoWrite( cNomeLog, oDadosJson:ToJson() )

Return 

/*/{Protheus.doc} retornaRegistroQDH
Retorna o Registro QDH do Documento
@author brunno.costa
@since  01/08/2025
@return oRetorno, JsonObject, objeto Json com os dados do registro QDH
/*/
METHOD retornaRegistroQDH() CLASS QDODocumentControl

    Local oRetorno := JsonObject():New()
    
    oRetorno["QDH_FILIAL"] := QDH->QDH_FILIAL
    oRetorno["QDH_DOCTO"]  := QDH->QDH_DOCTO
    oRetorno["QDH_RV"]     := QDH->QDH_RV
    oRetorno["QDH_DTOIE"]  := QDH->QDH_DTOIE
    oRetorno["QDH_STATUS"] := QDH->QDH_STATUS
    oRetorno["QDH_NOMDOC"] := QDH->QDH_NOMDOC
    oRetorno["Recno"     ] := QDH->(Recno())
	
Return oRetorno

/*/{Protheus.doc} callStack
Retorna o CallStack da Chamada, com o número de chamadas definido no parâmetro nTotal
@author brunno.costa
@since  01/08/2025
@param 01 - nTotal, número, indica a quantidade de chamadas para CallStack
@return cCallStack, caracter, call stack da chamada
/*/
METHOD callStack(nTotal) CLASS QDODocumentControl
	Local cCallStack := ""
	Local nIndice    := 2
	Local nTotAux    := 0
	Default nTotal   := 15
	nTotAux     := nTotal + nIndice
	For nIndice := 2 to nTotAux
		cCallStack += " [" + ProcName(nIndice)+":"+ cValToChar(ProcLine(nIndice)) + "] <- "
	Next nIndice
Return cCallStack

/*/{Protheus.doc} usuarioValidoParaImpressao
Indica se O Usuário é Válido para Impressão no Documento, são válidos:
-> Demais usuários que fazem parte do processo de digitação à distribuição podem imprimir, 
desde que o documento esteja na sua etapa de responsabilidade.

@author brunno.costa
@since  29/11/2021
@param 01 - cDocumento, caracter, código do documento para consulta
@param 02 - cRevisao  , caracter, código da revisão para consulta
@param 03 - cUsuario  , caracter, código do usuário para consulta
@return lValido, lógico, indica se o usuário é válido para impressão no documento 
/*/
METHOD usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario) CLASS QDODocumentControl
    Local cAlias     := GetNextAlias()
    Local cLogin     := Nil
    Local cQDHStatus := Self:retornaStatusdoDocumento(cDocumento, cRevisao)
    Local lValido    := .F.

    Default cUsuario := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT COUNT(*) QTD
          FROM (SELECT QD1_SIT, QD1_DOCTO, QD1_RV, QD1_FILMAT, QD1_MAT, QD1_TPPEND
                  FROM %Table:QD1%
                 WHERE %NotDel%
                   AND QD1_SIT   <> 'I'
                   AND QD1_DOCTO  = %Exp:cDocumento%
                   AND QD1_RV     = %Exp:cRevisao%
                   AND QD1_FILMAT = %xfilial:QAA%) RESPONSAVEIS
    INNER JOIN (SELECT QDH_DOCTO, QDH_RV, QDH_STATUS
                  FROM %Table:QDH%
                 WHERE %NotDel%
                   AND QDH_DOCTO  = %Exp:cDocumento%
                   AND QDH_RV     = %Exp:cRevisao%
                   AND QDH_STATUS LIKE CONCAT(CONCAT('%', %Exp:cQDHStatus%), '%')
                   AND QDH_FILMAT = %xfilial:QAA%) DOCUMENTO 
            ON RESPONSAVEIS.QD1_DOCTO = DOCUMENTO.QDH_DOCTO
           AND RESPONSAVEIS.QD1_RV    = DOCUMENTO.QDH_RV
           AND (DOCUMENTO.QDH_STATUS LIKE CONCAT(CONCAT('%', RESPONSAVEIS.QD1_TPPEND), '%'))
    INNER JOIN (SELECT QAA_FILIAL, QAA_LOGIN, QAA_MAT, QAA_DISTSN
                  FROM %Table:QAA%
                 WHERE %NotDel%
                   AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) = %Exp:cLogin%) USUARIOS 
            ON RESPONSAVEIS.QD1_FILMAT = USUARIOS.QAA_FILIAL
           AND RESPONSAVEIS.QD1_MAT    = USUARIOS.QAA_MAT
         WHERE (DOCUMENTO.QDH_STATUS LIKE CONCAT(CONCAT('%', RESPONSAVEIS.QD1_TPPEND), '%'))
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lValido := .T.
    EndIf 

    (cAlias)->(DbCloseArea())

Return lValido

/*/{Protheus.doc} validaUsoNoUsuario
Indica se o usuário está cadastrado para uso da exibição do documento dentro do Protheus
@author brunno.costa
@since  29/11/2021
@param 01 - cUsuario, caracter, código do usuário para consulta
@return lUsado, lógico, indica se deve realizar a impressão em tela para o usuário
/*/
METHOD validaUsoNoUsuario(cUsuario) CLASS QDODocumentControl
    Local aArea  := GetArea()
    Local cAlias := GetNextAlias()
    Local cLogin := ""
    Local lUsado := .F.

    Default cUsuario := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    BeginSql Alias cAlias
        SELECT COUNT(*) AS QTD
		FROM %Table:QAA% 
		WHERE %NotDel%
            AND QAA_TPWORD                     =  '4'
            AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) =  %Exp:cLogin%
            AND QAA_LOGIN                      <> ' '
    EndSql

    If !(cAlias)->(Eof()) .AND. (cAlias)->QTD > 0
        lUsado := .T.
        
    Else
        
        (cAlias)->(DbCloseArea())

        BeginSql Alias cAlias
            SELECT COUNT(*) AS QTD
            FROM %Table:QAA% 
            WHERE %NotDel%
                AND LTRIM(RTRIM(UPPER(QAA_LOGIN))) =  %Exp:cLogin%
                AND QAA_LOGIN                      <> ' '
        EndSql

        If (cAlias)->(Eof()) .Or. (cAlias)->QTD == 0
            lUsado := .T.
        EndIf
        
    EndIf 

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return lUsado

/*/{Protheus.doc} enviaImpressao
Envia Impressão para o Sistema Operacional OU Exibe Help de problema caso o Usuário não tenha permissão
@author brunno.costa
@since  29/11/2021
@param 01 - oWebEngine, objeto, objeto da TWebEngine que exibe o documento
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@param 04 - cUsuario  , caracter, código do usuário do sistema relacionado
@param 05 - nCobertura, numérico, variável temporária para auxiliar cobertura
/*/
METHOD enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario, nCobertura) CLASS QDODocumentControl
    Local cLogin   := Nil
    Local cTitHelp := Nil
    Local lImprime := .F.
    Local lLeitura := "L" $ Self:retornaStatusdoDocumento(cDocumento, cRevisao) //Leitura
    Local lRetAux  := Nil

    Default cUsuario   := RetCodUsr()
    Default nCobertura := 0

    cLogin   := Upper(AllTrim(UsrRetName(cUsuario)))
    cTitHelp := Iif(lLeitura, "QDOENVIMPR1", "QDOENVIMPR2")

    Self:lPEAlteraRegraPadraoImpressao := Iif(Self:lPEAlteraRegraPadraoImpressao == Nil, ExistBlock("QDOLPDFIMP"), Self:lPEAlteraRegraPadraoImpressao)

    If !Self:lPEAlteraRegraPadraoImpressao .AND. !lLeitura .AND. Self:usuarioValidoParaImpressao(cDocumento, cRevisao, cUsuario)
        lImprime := .T.
    ElseIf !Self:lPEAlteraRegraPadraoImpressao .Or. nCobertura == 1
            //STR0039 - "Somente os usuários responsáveis pela etapa de "
            //STR0040 - "Solicite apoio dos responsáveis."
            //STR0047 - " podem realizar a impressão deste documento."
            //STR0048 - "Impressão não habilitada na etapa de leitura do documento."
        Iif(lLeitura, Self:help(cTitHelp, STR0048, STR0040),;
            Self:help(cTitHelp, STR0039 + Self:retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao) + STR0047, STR0040))
    Else
        lRetAux := ExecBlock( "QDOLPDFIMP", .F., .F., {cDocumento, cRevisao, cUsuario, cLogin, lImprime})
		If ValType(lRetAux) == "L"
			lImprime := lRetAux
		EndIf
    EndIf

    If lImprime
        oWebEngine:Print()
    EndIf

Return


/*/{Protheus.doc} montaTelaExibicaoPDFNoSmartClient
Monta Tela Para Exibição do PDF Embedded no SmartClient
@author brunno.costa
@since  29/11/2021
@param 01 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 02 - cDocumento, caracter, código do documento relacionado
@param 03 - cRevisao  , caracter, código da revisão do documento relacionada
@param 04 - cUsuario  , caracter, código do usuário do sistema relacionado
@return lMontou, lógico, indica se conseguiu montar a tela
/*/

METHOD montaTelaExibicaoPDFNoSmartClient(cArquivoLocal, cDocumento, cRevisao, cUsuario) CLASS QDODocumentControl
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroMontagemTela(oError:Description), Break(oError)})
    Local cLogin
    Local lMontou     := .T.
    Local nBuild

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    Default cUsuario   := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    Begin Sequence

        nBuild  := Self:retornaBuild()

        oViewExec := FWViewExec():New()
        oViewExec:SetView(ViewDef(Self, cArquivoLocal, cDocumento, cRevisao, cUsuario))
        oViewExec:SetTitle(STR0041) //"Visualização de Documento"
        oViewExec:SetButtons({{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0042},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}) //"Fechar"
        oViewExec:SetCloseOnOk({|oViewPai| .T. })
        oViewExec:SetModal(.F.)
        oViewExec:OpenView(.F.)

	Recover
        lMontou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lMontou

/*/{Protheus.doc} ViewDef
Definição do View Para Criação de Tela MVC
@author brunno.costa
@since 07/12/2021
@param 01 - oSelf        , objeto  , instancia da classe QDODocumentControl
@param 02 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 03 - cDocumento, caracter, código do documento relacionado
@param 04 - cRevisao  , caracter, código da revisão do documento relacionada
@param 05 - cUsuario  , caracter, código do usuário do sistema relacionado
@return oView - View da Tela MVC
/*/
Static Function ViewDef(oSelf, cArquivoLocal, cDocumento, cRevisao, cUsuario)
	Local oModel     := FWLoadModel("QDODocumentControl")
	Local oView      := FWFormView():New()
    Local oWebEngine := Nil

    //Seta modelo padrão na view
	oView:SetModel(oModel)

	//Adiciona a Other Object para Montagem da TWebEngine
	oView:AddOtherObject("VIEW_PDF", {|oPanel| oSelf:montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, @oWebEngine) })
	
    //Adiciona a Other Object para Montagem do painel de informaçãoes do documento
	oView:AddOtherObject("VIEW_INF", {|oPanelInfo| oSelf:montaTelaInformacaoDoDocumento(oPanelInfo, cDocumento, cRevisao) })

    //Cria os BOX e Vincula as Dialogs de PDF e Informação ao Box
	oView:CreateHorizontalBox( 'BOX_PDF', 95 )
	oView:CreateHorizontalBox( 'BOX_INF', 05 )
    oView:SetOwnerView("VIEW_PDF","BOX_PDF")
    oView:SetOwnerView("VIEW_INF","BOX_INF")

    If oSelf:lExibeBotaoImpressao
        oView:AddUserButton(STR0043, "", {|oView| oSelf:enviaImpressao(oWebEngine, cDocumento, cRevisao, cUsuario) } , , , , .T.) //"Imprimir"
    EndIf

Return oView

/*/{Protheus.doc} montaTelaOtherObject
Monta Tela MVC Referente Trecho Other Object - ADVPL Livre para usar TWebEngine
@author brunno.costa
@since  29/11/2021
@param 01 - oPanel       , objeto  , painel do OtherObject na View MVC
@param 02 - cArquivoLocal, caracter, nome do arquivo PDF local para exibição em tela
@param 03 - cUsuario     , caracter, código do usuário do sistema relacionado
@param 04 - oWebEngine   , objeto  , retorna por referência o objeto TWebEngine para permitir impressão no botão MVC
@return lMontou, lógico, indica se conseguiu montar a tela
/*/

METHOD montaTelaOtherObject(oPanel, cArquivoLocal, cUsuario, oWebEngine) CLASS QDODocumentControl
    Local bErrorBlock := ErrorBlock({|oError| QDODocumentControl():erroMontagemTela(oError:Description), Break(oError)})
    Local cLogin
    Local lMontou     := .T.
    Local nBuild
    Local oTIBrowser
    Local oWebChannel

    Default cUsuario   := RetCodUsr()

    cLogin  := Upper(AllTrim(UsrRetName(cUsuario)))

    Begin Sequence

        nBuild  := Self:retornaBuild()

        If ( nBuild >= 17 )
            oWebChannel := TWebChannel():New()
            nPort := oWebChannel::connect()
        
            oWebEngine := TWebEngine():New( oPanel, 0, 0, 395, 265,, nPort )
            If (Self:validaExecucaoViaWebAgent())
                oWebEngine:navigate( Self:cDirDocLocal + cArquivoLocal + "#toolbar=0" ) //#toolbar=0 para remover toolbar com opção de impressão e download do browser
            ElseIf (Self:validaExecucaoViaWebApp())
                oWebEngine:navigate( GetTempPath(.T.) + cArquivoLocal + "#toolbar=0" ) //#toolbar=0 para remover toolbar com opção de impressão e download do browser
            Else
				//SmartCLient QT
                If Self:lClientLinux
                    oWebEngine:navigate( "file:///" + Lower(StrTran(Self:cDirDocLocal + cArquivoLocal + "#toolbar=0", "l:/", "")) )
                Else
                    oWebEngine:navigate( "file:///" + StrTran(Self:cDirDocLocal + cArquivoLocal + "#toolbar=0", "\", "/") )
                EndIf
            EndIf

            oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

        Else
            oTIBrowser := TIBrowser():New( 0, 3, 615, 260, Self:cDirDocLocal + cArquivoLocal, oPanel )
            oTIBrowser:Align := CONTROL_ALIGN_ALLCLIENT
        EndIf
	
	Recover
        lMontou := .F.

	End Sequence
    ErrorBlock(bErrorBlock)

Return lMontou

/*/{Protheus.doc} montaTelaInformacaoDoDocumento
Monta Tela MVC Referente Trecho Other Object - ADVPL Livre para usar TWebEngine
@author rafael.kleestadt
@since  23/01/2024
@version 1.0
@param 01 - oPanelInfo   , objeto  , painel do OtherObject na View MVC
@param cDocumento, caractere, código do documento na QDH
@param cRevisao, caractere, revisão do documento na QDH
@return lMontou, lógico, indica se conseguiu montar a tela
/*/
METHOD montaTelaInformacaoDoDocumento(oPanelInfo, cDocumento, cRevisao) CLASS QDODocumentControl
    Local aInfosDoc   := {} 
    Local bOpeUrlTDN  := {|| MsgRun(STR0049, "URL",{|| ShellExecute("open","https://tdn.totvs.com/x/bW7yM","","",1) } ) } // "Abrindo o link... Aguarde..."
    Local cArquivoDOC := ""
    Local oIcon       := NIL
    Local oSay        := NIL

    cArquivoDOC := Self:retornaArquivoLocal(cDocumento, cRevisao)

    If !Empty(cArquivoDOC)

        aInfosDoc := DIRECTORY(Self:cDirDocServer + cArquivoDOC)

        If aInfosDoc != Nil .And. Len(aInfosDoc[1]) >= 4 .And. (!Empty(aInfosDoc[1,3]) .And. !Empty(aInfosDoc[1,4]))

            oSay := TSay():New(001,020,{|| OemToAnsi(STR0050+cValToChar(aInfosDoc[1,3])+STR0051+ aInfosDoc[1,4])},oPanelInfo,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,oPanelInfo:nClientWidth/2,oPanelInfo:nClientHeight/2) //"Última modificação do arquivo: "### " às "
            oSay:SetTextAlign( 0, 2 )
            oSay:bLClicked := bOpeUrlTDN

            @ 0.7,001 ICON oIcon RESOURCE "UPDINFORMATION" OF oPanelInfo NOBORDER PIXEL
            oIcon:bLClicked := bOpeUrlTDN
    
        EndIf
    EndIf

Return Nil

/*/{Protheus.doc} retornaArquivoLocal
Retorna o nome do arquivo que é editado por meio do QDOA050
@author rafael.kleestadt
@since 23/01/2024
@version 1.0
@param cDocumento, caractere, código do documento na QDH
@param cRevisao, caractere, revisão do documento na QDH
@return QDH_NOMDOC, caractere, nome do arquivo que é editado por meio do QDOA050
/*/
METHOD retornaArquivoLocal(cDocumento, cRevisao) CLASS QDODocumentControl
Return Posicione("QDH", 1, xFilial("QDH")+cDocumento+cRevisao, "QDH_NOMDOC")


/*/{Protheus.doc} ModelDef
Definição do modelo da QDH Para Criação de Tela MVC (fake - não é usado - necessário para instanciar ViewDef)
@author brunno.costa
@since 07/12/2021
@return oModel - Modelo de dados da tabela QDH
/*/
Static Function ModelDef()
	Local oModel
	Local oStruct := FWFormStruct(1,"QDH",{|cCampo| "|"+AllTrim(cCampo)+"|" $ "|QDH_DOCTO|QDH_RV|"})
	oModel := MPFormModel():New("QDODocumentControl")
	oModel:AddFields("MASTER", , oStruct)
Return oModel

/*/{Protheus.doc} erroMontagemTela
Erro na Montagem de Tela
@author brunno.costa
@since  29/11/2021
@param 01 - cErro, caracter, erro durante a montagem do arquivo em tela
/*/
METHOD erroMontagemTela(cErro) CLASS QDODocumentControl
    //STR0044 - "Falha na exibição do documento"
    //STR0045 - "Entre em contato com o suporte da TOTVS informando este erro."
    Self:help("QDOCRIATELA", STR0044 + ": " + AllTrim(cErro) + ".", STR0045)
Return 

/*/{Protheus.doc} retornaDescricaodoStatusdoDocumento
Retorna a descrição do status do documento.
@author rafael.kleestadt
@since 13/09/2022
@version 1.0
@param cDocumento, caracter, código do documento
@param cRevisao, caracter, revisão do documento
@return cDescricao, caracter, descrição do status do documento.
/*/
METHOD retornaDescricaodoStatusdoDocumento(cDocumento, cRevisao) CLASS QDODocumentControl
    Local cDescricao := ""

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    cDescricao := SX5Desc('Q7', Self:retornaStatusdoDocumento(cDocumento, cRevisao))

Return cDescricao

/*/{Protheus.doc} retornaStatusdoDocumento
Retorna o status do documento.
@author rafael.kleestadt
@since 20/09/2022
@version 1.0
@param cDocumento, caracter, código do documento
@param cRevisao, caracter, revisão do documento
@return cStatus, caracter, status do documento.
/*/
METHOD retornaStatusdoDocumento(cDocumento, cRevisao) CLASS QDODocumentControl
    Local aAreaQDH := QDH->(GetArea())
    Local cStatus  := ""

    Default cDocumento := QDH->QDH_DOCTO
    Default cRevisao   := QDH->QDH_RV
    
    cStatus  := Posicione("QDH", 1, xFilial("QDH")+cDocumento+cRevisao, "QDH_STATUS")

    RestArea(aAreaQDH)

Return cStatus

/*/{Protheus.doc} forcaRegravacaoDeArquivoNaRede

Solução paliativa pois foi verificada necessidade de APENAS QUANDO o Rootpath usa caminho UNC (\\IP-de-rede\) 
reprocessar a gravação do arquivo .CEL no servidor chamando o método removeSenhaWord() para salvar o documento SEM o "oleWdFormatDocument"
    OLE_SaveAsFile( oWord, ( cQPathTrm + cTexto ), cMvSave, cMvSave, .f., oleWdFormatDocument )

Efeito colateral identificado quando o .cel é salvo com oleWdFormatDocument:
    A) ao visualizar arquivos salvos pelo módulo pela solução de leitura interna em PDF, 
    o arquivo PDF fica com variáveis ADV_ e não com o conteúdo correto da conversão

	B) quando o servidor é Linux

@author brunno.costa, rafael.hesse
@since 10/01/2023
@param cArquivo, caracter, nome do arquivo no servidor
/*/
METHOD forcaRegravacaoDeArquivoNaRede(cArquivo) CLASS QDODocumentControl
    Local cDiretorio  := Nil
    If SuperGetMV("MV_QSAVEDC",.F.,1) <> 3      //Otimização Performance 01/11/2023 - DMANQUALI-7355

        cDiretorio  := AllTrim(GetSrvProfString( "RootPath", "\\"))
        
        If Left(cDiretorio, 2) == "\\";         //Cenário Original       10/01/2023 - DMANQUALI-5760
        .OR. (Self:lServerLinux := IsSrvUnix()) //Novo cenário           06/02/2023 - DMANQUALI-5818
            Self:New()
            If Self:validaImplantacao(.F.)
                Self:removeSenhaWord(cArquivo,,,.T.,"16")//WdFormatDocumentDefault
            EndIf
        EndIf
    EndIf
Return

/*/{Protheus.doc} forcaRegravacaoDeArquivoNaRede

Controla salvamento de arquivos .DOC ou Default do MSOffice conforme parametrização do parâmetro MV_QSAVEDC

MV_QSAVEDC == 1 -> 
    -> Sem Leitura Interna (MV_QDOCPDF = .F.) -> Salva .CEL equivalente a formato .DOC
    -> Com Leitura Interna (MV_QDOCPDF = .T.) -> Salva .CEL equivalente a formato default do MS Office utilizado pelo cliente
MV_QSAVEDC == 2 -> 
    -> Sem Leitura Interna (MV_QDOCPDF = .F.) -> Salva .CEL equivalente a formato .RTF
    -> Com Leitura Interna (MV_QDOCPDF = .T.) -> Salva .CEL equivalente a formato default do MS Office utilizado pelo cliente
MV_QSAVEDC == 3 ->            Salva .CEL equivalente a formato default do MS Office utilizado pelo cliente

@author brunno.costa
@since 01/11/2023
@param 01 - hOleLink      , Numérico       , Handle da conexão entre o SmartClient e a aplicação MS-Office.						X				
@param 02 - cFileName     , Array of Record, Path + Nome do arquivo a ser salvo.						X				
@param 03 - cPassword     , Array of Record, Password. (Caso seja um arquivo MS-Office de acesso restrito)										
@param 04 - cWritePassword, Array of Record, Password para proteção de edição do arquivo salvo, (Caso seja um arquivo MS-Office de acesso restrito)										
@param 05 - lReadOnly     , Array of Record, Atributo "somente leitura" do arquivo salvo.
@param 06 - cSaveFormat   , Caracter       , formato para salvar o arquivo
	17  - PDF
    16  - Default MS Office Utilizado
    0   - MS Office 97-2003 (.doc)
	... - HTML
@param 07 - lPermiteRTF   , lógico         , indica se o trecho chamador permite análise de MV para salvar no formato RTF
@param 08 - lImplantacao  , lógico         , indica execução durante implantação da Leitura Interna
/*/
METHOD OLE_SaveAsFile(hOleLink, cFileName, cPassword, cWritePassword, lReadOnly, cSaveFormat, lPermiteRTF, lImplantacao) CLASS QDODocumentControl
    Local cFormatDef  := "16" //WdFormatDocumentDefault
    Local cFormatDOC  := oleWdFormatDocument //0
    Local cFormatRTF  := oleWdFormatRTF
    Local cMVQSAVEDC  := SuperGetMV("MV_QSAVEDC",.F.,1)
    Local lInterna    := Nil
    Local lMSODefault := cMVQSAVEDC == 3
    Local lMSORTF     := cMVQSAVEDC == 2
    
    Default cSaveFormat := "16" //WdFormatDocumentDefault
    Default lPermiteRTF := .F.

    Iif(Self:cDirDocLocal == NIl, Self:New(), Nil)

    //Se ponto permite salvar RTF e MV_QSAVEDC == 2 (indica que deve salvar arquivo como RTF), força alteração do formato para cFormatRTF - oleWdFormatRTF
    If lPermiteRTF .And. lMSORTF .And. cSaveFormat == cFormatDOC
        cSaveFormat := cFormatRTF
    EndIf
    
    //Se formado .DOC e MV_QSAVEDC == 3 (indica que deve salvar no formato default do MS Office do cliente), força alteração do formato para cFormatDef - WdFormatDocumentDefault
    If lMSODefault .AND. cSaveFormat == cFormatDOC
        cSaveFormat := cFormatDef         //WdFormatDocumentDefault
    EndIf

    //Se Leitura Interna e formato .DOC, revisa se usa LibreOffice para salvar como Default (possivelmente .DOCX)
    If cSaveFormat == cFormatDOC
        lInterna   := SuperGetMV("MV_QDOCPDF",.F.,.F.)
        If lInterna .OR. lImplantacao
            If Self:lServerLinux .OR. (!Self:existeMSOffice(.F.) .And. Self:existeLibreOffice(.F.))
                cSaveFormat := cFormatDef //WdFormatDocumentDefault
                If FWSX6Util():ExistsParam( "MV_QSAVEDC" )
                    PutMV("MV_QSAVEDC", 3)
                EndIf
            EndIf
        EndIf
    EndIf

Return OLE_SaveAsFile(hOleLink, cFileName, cPassword, cWritePassword, lReadOnly, cSaveFormat)

/*/{Protheus.doc} copiaProtegidaArquivo
Copia arquivo protegido, ou seja, copia o arquivo cOrigem com outro nome temporário e renomeia-o após conclusão da cópia com sucesso para o nome cDestino
@author brunno.costa
@since 03/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser copiado
@param 02 - cDestino  , caracter, nome DESTINO do arquivo a ser copiado
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lSucesso, lógico, indica se conseguiu copiar o arquivo
/*/
METHOD copiaProtegidaArquivo(cOrigem, cDestino, nCobertura) CLASS QDODocumentControl

    Local bErrorBlock := Nil
    Local cBackup     := cDestino + ".bkp.tmp"
    Local cArqTMP     := Self:geraDestinoTemporario(cDestino)
    Local lSucesso    := .F.
    Local nExcluiu0   := -999
    Local nExcluiu1   := -999
    Local nRenomeou0  := -999
    Local nRenomeou1  := -999
    Local nRenomeou2  := -999

    Default nCobertura := 0

    bErrorBlock := ErrorBlock({|oError| lSucesso := .F., QDODocumentControl():erroCopiaArquivo(cOrigem, oError:Description, 0), Break(oError)})

    Iif(Self:cDirDocLocal == NIl, Self:New(), Nil)

    //Proteção para reduzir riscos de processos em cliente travarem quando o fluxo não possui arquivo de origem na cópia
	If Self:existeArquivoWhereDinamico(cOrigem)

        Begin Sequence
            
            If ( !(".CEL" $ Upper(cOrigem)) .And. Type("lAltDoc") == "L" .And. !lAltDoc .And. Self:existeArquivoWhereDinamico(cDestino) .And. (!Self:arquivoLiberado(cOrigem) .or. !Self:arquivoLiberado(cDestino)) .And. Self:conteudoArquivosIguais(cOrigem, cDestino) ) .OR. nCobertura == 4 .OR. nCobertura == 5

                lSucesso := .T.
                
                //STR0059 - "Falha em processo de cópia de arquivo ignorado devido arquivos de conteúdo iguais."
                //STR0060 - "Origem"
                //STR0061 - "Destino"
                //STR0062 - "Lock"

                If !Self:arquivoLiberado(cOrigem) .OR. nCobertura == 4

                    Self:logMsg("QDOFILELOCKI", STR0059 + " " + STR0060 + ": '" + cOrigem + "'. " + STR0061 + ": '" + cDestino + "'. " + STR0062 + ": '" + cOrigem + "'. ", "")
                
                ElseIf !Self:arquivoLiberado(cDestino) .OR. nCobertura == 5

                    Self:logMsg("QDOFILELOCKI", STR0059 + " " + STR0060 + ": '" + cOrigem + "'. " + STR0061 + ": '" + cDestino + "'. " + STR0062 + ": '" + cDestino + "'. ", "")

                EndIf

            Else

                lSucesso := Self:fazBackupArquivo(cDestino, cBackup, @nExcluiu0, @nRenomeou0, nCobertura)

                If lSucesso .And. nRenomeou0 != -1 //nRenomeou0 == -1 -> Arquivo cDestino em uso
                    lSucesso := Self:copiaArquivo(cOrigem, cArqTMP, nCobertura)
                EndIf

                If lSucesso .And. nRenomeou0 != -1 //nRenomeou0 == -1 -> Arquivo cDestino em uso
                    lSucesso := Self:renomeiaArquivo(cArqTMP, cDestino, @nRenomeou1, nCobertura, cDestino)
                EndIf

                If (lSucesso .And. nRenomeou0 == 0) .OR. nCobertura == 2
                    lSucesso := Self:excluiArquivo(cBackup, @nExcluiu1, nCobertura)
                EndIf

            EndIf

        Recover
        End Sequence

        //Em caso de falha, volta o arquivo de backup para o nome original
        Iif ((!lSucesso .And. nRenomeou0 == 0 .AND. nExcluiu1 == -999), Self:renomeiaArquivo(cBackup, cDestino, @nRenomeou2, nCobertura, cDestino), Nil)

        //Força Exceção para que Identifiquemos os casos com falha TRAVANDO O PROCESSO do cliente
        If !lSucesso
            ErrorBlock(bErrorBlock)
            Self:cErrorMessage := Iif(Empty(Self:cErrorMessage), "", Self:cErrorMessage)
            UserException( Self:cErrorMessage )
        EndIf

    EndIf

    ErrorBlock(bErrorBlock)

Return lSucesso

/*/{Protheus.doc} copiaArquivo
Copia arquivo, ou seja, copia o arquivo cOrigem com o nome cDestino
@author brunno.costa
@since 03/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser copiado
@param 02 - cDestino  , caracter, nome DESTINO do arquivo a ser copiado
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@param 04 - lVldConteu, lógico  , indica se deve comparar o conteúdo dos arquivos após a cópia
@param 05 - cArquivo  , caracter, nome do arquivo (usado para tentativas de cópia alternativas)
@return lSucesso, lógico, indica se conseguiu copiar o arquivo
/*/
METHOD copiaArquivo(cOrigem, cDestino, nCobertura, lVldConteu, cArquivo) CLASS QDODocumentControl

    Local lSucesso    := .F.
    Local nOpcao      := 0

    Default lVldConteu := .F.
    Default nCobertura := 0
    Default cDestTent  := ""

    Self:recuperaBackupOriginalPerdido(cOrigem, nCobertura)

    If Self:arquivoLiberado(cDestino) .And. nCobertura != 3 .OR. nCobertura == 1 .OR. nCobertura == 2 .OR. nCobertura == 4 .OR. nCobertura == 5
        lSucesso :=                __CopyFile(cOrigem, cDestino, 0   )
        lSucesso := Iif(!lSucesso, __CopyFile(cOrigem, cDestino, 1   ), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(cOrigem, cDestino, 0, 1), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(cOrigem, cDestino, 1, 0), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(cOrigem, cDestino, 1, 1), lSucesso)

        lSucesso := Iif(!lSucesso, __CopyFile(Lower(cOrigem), Lower(cDestino), 0   ), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(Lower(cOrigem), Lower(cDestino), 1   ), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(Lower(cOrigem), Lower(cDestino), 0, 1), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(Lower(cOrigem), Lower(cDestino), 1, 0), lSucesso)
        lSucesso := Iif(!lSucesso, __CopyFile(Lower(cOrigem), Lower(cDestino), 1, 1), lSucesso)

        //Força tentativa de alocação de outro diretório local temporário caso falhe a cópia anteriormente
        If ( !lSucesso                      .And.;
             !Empty(cArquivo)               .And.;
             (Self:cDirDocLocal $ cDestino) .And.;
             !ExistDir(Self:cDirDocLocal)   .And.;
             AllTrim(Self:cDirDocLocal) != AllTrim(GetTempPath(.F., .T.)); //Local := .F., lWeb := .T.
           ) .Or. nCobertura == 5

            Self:cDirDocLocal := GetTempPath(.F., .T.)
            ExistDir(Self:cDirDocLocal)
            cDestino := Self:cDirDocLocal + cArquivo
            lSucesso := Self:copiaArquivo(cOrigem, cDestino, nCobertura, lVldConteu, cArquivo)

        EndIf

        If !lSucesso .OR. nCobertura == 1 .OR. nCobertura == 2

            If Self:conteudoArquivosIguais(cOrigem, cDestino) .OR. nCobertura == 1
                lSucesso := .T.

            Else
                //STR0054 - "Falha ao copiar o arquivo "
                //STR0055 - "para"
                //STR0013 - "Solicite apoio do departamento de TI informando este erro."
                Self:help("QDONOCOPY", STR0054 + " '" + cOrigem + "' " + STR0055 + " '" + cDestino + "':" + Str(fError()), STR0013)

            EndIf
        
        ElseIf lVldConteu .And. (!Self:conteudoArquivosIguais(cOrigem, cDestino)) .OR. nCobertura == 4
            //STR0054 - "Falha ao copiar o arquivo "
            //STR0055 - "para"
            //STR0013 - "Solicite apoio do departamento de TI informando este erro."
            Self:help("QDONOCOPY2", STR0054 + " '" + cOrigem + "' " + STR0055 + " '" + cDestino + "':" + Str(fError()), STR0013)

        EndIf

    Else
        nOpcao := Self:comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario(cOrigem, cDestino, .F., Nil, cDestino)
        If nOpcao == 2  //Tentar novamente após fechamento pelo usuário
            lSucesso := Self:copiaArquivo(cOrigem, cDestino, nCobertura, lVldConteu)
        EndIf

    EndIf


Return lSucesso

/*/{Protheus.doc} geraDestinoTemporario
Gera caminho de destino temporário para o arquivo a ser copiado
@author brunno.costa
@since 03/06/2025
@param 01 - cDestino, caracter, nome DESTINO do arquivo a ser copiado
@return cRetorno, caracter, caminho completo do arquivo temporário a ser gerado
/*/
METHOD geraDestinoTemporario(cDestino) CLASS QDODocumentControl

    Local aCaminho := StrTokArr(cDestino, IIf(At("\", cDestino) > 0, "\", "/"))
    Local nTamNome := Len(aTail(aCaminho))
    Local cCaminho := Substr(cDestino, 1, Len(cDestino) - nTamNome) //Remove nome do arquivo do caminho
    Local cNomeTMP := Lower(FWUUIDV4() + ".qdo.tmp") //Gera UUID4 para nome temporário
    Local cRetorno := cCaminho + cNomeTMP //Concatena caminho com nome temporário

Return cRetorno

/*/{Protheus.doc} excluiArquivo
Exclui arquivo de cCaminho  
@author brunno.costa
@since 03/06/2025
@param 01 - cCaminho   , caracter, caminho completo do arquivo a ser excluído
@param 02 - nExcluiu   , numérico, retorna por referência retorno da função fErase()
@param 03 - nCobertura , numérico, variável temporária para auxiliar cobertura
@return lSucesso, lógico, indica se conseguiu excluir o arquivo
/*/
METHOD excluiArquivo(cCaminho, nExcluiu, nCobertura) CLASS QDODocumentControl

    Local lSucesso := .T.
    Local nError   := 0

    nExcluiu :=                     fErase(cCaminho, Nil, .T.)            //lChangeCase := .T. - nWhere Nil - Relativo
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    nExcluiu := Iif(nExcluiu == -1, fErase(cCaminho, Nil, .F.), nExcluiu) //lChangeCase := .F. - nWhere Nil - Relativo
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    nExcluiu := Iif(nExcluiu == -1, fErase(cCaminho, 1, .T.), nExcluiu)   //lChangeCase := .T. - nWhere 1 - Server
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    nExcluiu := Iif(nExcluiu == -1, fErase(cCaminho, 1, .F.), nExcluiu)   //lChangeCase := .F. - nWhere 1 - Server
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    nExcluiu := Iif(nExcluiu == -1, fErase(cCaminho, 2, .T.), nExcluiu)   //lChangeCase := .T. - nWhere 2 - Client
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    nExcluiu := Iif(nExcluiu == -1, fErase(cCaminho, 2, .F.), nExcluiu)   //lChangeCase := .F. - nWhere 2 - Client    
    Iif(nExcluiu == -1 .And. nError == 0, fError(), nError)

    If nExcluiu == -1 .OR. nCobertura == 2
        //STR0056 - "Falha na exclusão do arquivo "
        //STR0013 - "Solicite apoio do departamento de TI informando este erro."
        Self:help("QDONODEL", STR0056 + " '" + cCaminho + "':" + Str(fError()), STR0013)
        lSucesso := .F.
    EndIf

Return lSucesso

/*/{Protheus.doc} fazBackupArquivo
Faz backup do arquivo de destino original, renomeando-o para cDestino.bkp.tmp e renomeia o arquivo de cOrigem para cDestino
@author brunno.costa
@since 03/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser renomeado
@param 02 - cDestino  , caracter, nome DESTINO do arquivo a ser renomeado
@param 03 - nExcluiu  , numérico, retorna por referência retorno da função fErase() caso o arquivo de destino exista
@param 04 - nRenomeou , numérico, retorna por referência retorno da função fRename()
@param 05 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lSucesso, lógico, indica se conseguiu renomear o arquivo
/*/
METHOD fazBackupArquivo(cOrigem, cDestino, nExcluiu, nRenomeou, nCobertura) CLASS QDODocumentControl
Return Self:renomeiaArquivoComExclusaoDestino(cOrigem, cDestino, @nExcluiu, @nRenomeou, nCobertura)

/*/{Protheus.doc} renomeiaArquivoComExclusaoDestino
Renomeia arquivo de cOrigem para cDestino, excluindo o destino caso exista
@author brunno.costa
@since 03/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser renomeado
@param 02 - cDestino  , caracter, nome DESTINO do arquivo a ser renomeado
@param 03 - nExcluiu  , numérico, retorna por referência retorno da função fErase() caso o arquivo de destino exista
@param 04 - nRenomeou , numérico, retorna por referência retorno da função fRename()
@param 05 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lSucesso, lógico, indica se conseguiu renomear o arquivo
/*/
METHOD renomeiaArquivoComExclusaoDestino(cOrigem, cDestino, nExcluiu, nRenomeou, nCobertura) CLASS QDODocumentControl

    Local lSucesso := .T.
    Local nOpcao   := 3

    Default nCobertura := 0

    If Self:existeArquivoWhereDinamico(cOrigem) .OR. nCobertura == 2 .OR. nCobertura == 3

        If Self:existeArquivoWhereDinamico(cDestino) .OR. nCobertura == 2
            lSucesso := Self:excluiArquivo(cDestino, @nExcluiu, nCobertura)

            If !lSucesso .OR. nCobertura == 2
                nOpcao := Self:comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario(cOrigem, cDestino, @lSucesso, , cDestino)

                If nOpcao == 2      //Tentar novamente após fechamento pelo usuário
                    lSucesso := Self:renomeiaArquivoComExclusaoDestino(cOrigem, cDestino, @nExcluiu, @nRenomeou, nCobertura)
                EndIf
            EndIf
        EndIf

        If (lSucesso .And. nOpcao <> 1) .OR. nCobertura == 3
            lSucesso := Self:renomeiaArquivo(cOrigem, cDestino, @nRenomeou, nCobertura, cOrigem)
        EndIf

    EndIF

Return lSucesso

/*/{Protheus.doc} renomeiaArquivo
Renomeia arquivo de cOrigem para cDestino
Realiza proteção com nWhere dinâmico para garantir que o arquivo seja renomeado corretamente em diferentes cenários de execução (servidor, cliente, etc.), 
especialmente quando GetTempPath(.T., .T.) retornando caminho absoluto de servidor
@author brunno.costa
@since 03/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser renomeado
@param 02 - cDestino  , caracter, nome DESTINO do arquivo a ser renomeado
@param 03 - nRenomeou , numérico, retorna por referência retorno da função fRename()
@param 04 - nCobertura, numérico, variável temporária para auxiliar cobertura
@param 05 - cArquivo  , caracter, nome do arquivo para exibição em caso de erro
@param 06 - lVldConteu, lógico  , indica se deve comparar os arquivos em caso de falha
@return lSucesso, lógico, indica se conseguiu renomear o arquivo
/*/
METHOD renomeiaArquivo(cOrigem, cDestino, nRenomeou, nCobertura, cArquivo, lVldConteu) CLASS QDODocumentControl

    Local lSucesso := .T.
    Local nError   := 0
    Local nOpcao   := 3

    Default nCobertura := -1
    Default cArquivo   := Iif(".tmp" $ cDestino, cOrigem, cDestino)
    Default lVldConteu   := .T.

    nRenomeou :=                      fRename(cOrigem, cDestino, Nil, .T.)             //lChangeCase := .T. - Default
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    nRenomeou := Iif(nRenomeou == -1, fRename(cOrigem, cDestino, Nil, .F.), nRenomeou) //lChangeCase := .F.
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    nRenomeou := Iif(nRenomeou == -1, fRename(cOrigem, cDestino,   1, .T.), nRenomeou) //lChangeCase := .T. - Default - nWhere = 1 - Server
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    nRenomeou := Iif(nRenomeou == -1, fRename(cOrigem, cDestino,   1, .F.), nRenomeou) //lChangeCase := .F.           - nWhere = 1 - Server
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    nRenomeou := Iif(nRenomeou == -1, fRename(cOrigem, cDestino,   2, .T.), nRenomeou) //lChangeCase := .T. - Default - nWhere = 2 - Client
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    nRenomeou := Iif(nRenomeou == -1, fRename(cOrigem, cDestino,   2, .F.), nRenomeou) //lChangeCase := .F.           - nWhere = 2 - Client
    nError    := Iif(nRenomeou == -1 .And. nError == 0, fError(), nError)

    IF nRenomeou == -1 .OR. nCobertura == 3 .OR. nCobertura == 4

        lSucesso := .F.

        If lVldConteu .OR. nCobertura == 3 .OR. nCobertura == 4
            nOpcao := Self:comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario(cOrigem, cDestino, @lSucesso, , cArquivo)

            If nOpcao == 2      //Tentar novamente após fechamento pelo usuário
                lSucesso := Self:renomeiaArquivo(cOrigem, cDestino, @nRenomeou, nCobertura, cArquivo)
                
            ElseIf nOpcao == 3    //Cancelar, interrompe o processo

                //Se não conseguiu renomear o arquivo, exibe mensagem de erro
                //STR0057 - "Falha ao renomear o arquivo "
                //STR0055 - "para"
                //STR0013 - "Solicite apoio do departamento de TI informando este erro."
                Self:help("QDONORENAME", STR0057 + " '" + cOrigem + "' " + STR0055 + " '" + cDestino + "':" + str(nError,4), STR0013)

            EndIf
        EndIf

    Endif

Return lSucesso

/*/{Protheus.doc} comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario
Compara arquivos de cOrigem e cDestino em caso da Falha Predecessora, alertando o usuário caso sejam diferentes
Se os arquivos forem iguais, não há necessidade de ação.   
Se forem diferentes, apresenta opções de ação ao usuário:
    1 - Ignorar: Usa o arquivo atual (pode causar falha de versionamento).
    2 - Tentar novamente: Tenta novamente após fechamento pelo usuário.
    3 - Cancelar: Interrompe o processo.

@author brunno.costa
@since 31/07/2025
@param 01 - cOrigem   , caracter  , nome ORIGEM do arquivo
@param 02 - cDestino  , caracter  , nome DESTINO do arquivo
@param 03 - lSucesso  , lógico    , indica status atual da operação (retorna por referência)
@param 04 - nCobertura, numérico  , variável temporária para auxiliar cobertura
@param 05 - cArquivo  , caracter  , nome do arquivo para exibição em caso de erro
@return nOpcao, numérico, indica opção de retorno com base em seleção de usuário, quando for o caso:
    0 - Arquivos origem e destino iguais, não há necessidade de ação
    1 - Ignorar: Usa o arquivo atual (pode causar falha de versionamento).
    2 - Tentar novamente: Tenta novamente após fechamento pelo usuário.
    3 - Cancelar: Interrompe o processo.
/*/
METHOD comparaArquivosEmCasoDeFalhaPredecessoraEAlertaUsuario(cOrigem, cDestino, lSucesso, nCobertura, cArquivo) CLASS QDODocumentControl

    Local cMensagem      := ""
    Local cSubtitulo     := ""
    Local cTitulo        := ""
    Local nOpcao         := 3
    Local nRotAutDefault := 3
    Local nTimer         := 0 //120000

    Default nCobertura := 0
    Default cArquivo   := ""

    If (!lSucesso .And. (Self:existeArquivoWhereDinamico(cOrigem) .Or. Self:existeArquivoWhereDinamico(cDestino))) .Or. nCobertura == 1 .Or. nCobertura == 2

        
        If IsInCallStack("QdoDocExt")
            //STR0063 - "Falha: arquivo local diferente do servidor e bloqueado por outro processo."
            cSubtitulo := STR0063
            cTitulo    := "QDOFILELOCKA"
        Else
            //STR0064 - "Falha: arquivo bloqueado por outro processo."
            cSubtitulo := STR0064
            cTitulo    := "QDOFILELOCKB"
        EndIf

        //STR0065 - "O arquivo abaixo está bloqueado, impedindo executar este processo."
        //STR0066 - "Como deseja continuar?"
        //STR0067 - "- Tentar novamente: repete a operação (indicado após liberação pelo usuário)."
        //STR0068 - "- Ignorar: pode causar falhas na exibição, versionamento e salvamento do arquivo."
        //STR0069 - "- Cancelar: interrompe o processo de manutenção da etapa atual."
        cMensagem := STR0065 + ENTER
        cMensagem += AllTrim(cArquivo) + ENTER + ENTER
        cMensagem += STR0066 + ENTER
        cMensagem += STR0067 + ENTER
        cMensagem += STR0068 + ENTER
        cMensagem += STR0069 + ENTER

        //STR0060 - "Origem"
        //STR0061 - "Destino"
        //STR0062 - "Lock"
        Self:logMsgNaDocsDoServidor(cTitulo, cMensagem, STR0060 + ": " + cOrigem  + " - " +;
                                                        STR0061 + ": " + cDestino + " - " +;
                                                        STR0062 + ": " + cArquivo,;
                                                        "Aviso", cArquivo)

        //STR0070 - Ignorar
        //STR0071 - Tentar novamente
        //STR0072 - Cancelar
        nOpcao := Aviso( cTitulo, cMensagem, { STR0070, STR0071, STR0072 }, nRotAutDefault,  cSubtitulo,,'', .F., nTimer )

        Self:logMsgNaDocsDoServidor(cTitulo , cMensagem, STR0060 + ": " + cOrigem  + " - " +;
                                                         STR0061 + ": " + cDestino + " - " +;
                                                         STR0062 + ": " + cArquivo,;
                                                         "nOpcao=" + AllTrim(Str(nOpcao)), cArquivo)

        If nOpcao == 1 .Or. nCobertura == 2
            lSucesso := .T. //Ignorar, usa o arquivo atual
        EndIf

    EndIF

Return nOpcao

/*/{Protheus.doc} conteudoArquivosIguais
Compara o conteúdo dos arquivos de cOrigem e cDestino, retornando se são iguais ou não
@author brunno.costa
@since 31/07/2025
@param 01 - cOrigem , caracter, nome ORIGEM do arquivo
@param 02 - cDestino, caracter, nome DESTINO do arquivo
@param 03 - nCobertura, numérico, variável temporária para auxiliar cobertura
@return lIguais, lógico, indica se os arquivos são iguais ou não

METHOD conteudoArquivosIguais(cOrigem, cDestino, nCobertura) CLASS QDODocumentControl

    Local aDestino    := Nil
    Local aOrigem     := Nil
    Local bErrorBlock := ErrorBlock({|| })
    Local cBase64A    := Nil
    Local cBase64B    := Nil
    Local cMD5A       := Nil
    Local cMD5B       := Nil
    Local lIguais     := .F.
    Local nIndice     := 0

    Default nCobertura := 0

    If Self:existeArquivoWhereDinamico(cOrigem) .AND. Self:existeArquivoWhereDinamico(cDestino)

        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 0), aOrigem) //Obtém informações do arquivo origem - nWhere = 0 (Relativo)
        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 1), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Servidor)
        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 2), aOrigem) //Obtém informações do arquivo origem - nWhere = 2 (cliente)
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 0), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Relativo) - Lower()
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 1), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Servidor) - Lower()
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 2), aOrigem) //Obtém informações do arquivo origem - nWhere = 2 (cliente)  - Lower()

        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 0), aDestino) //Obtém informações do arquivo destino - nWhere = 1 (Relativo)
        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 1), aDestino) //Obtém informações do arquivo destino - nWhere = 1 (Servidor)
        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 2), aDestino) //Obtém informações do arquivo destino - nWhere = 2 (cliente)
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 0), aDestino) //Obtém informações do arquivo origem - nWhere = 1 (Relativo) - Lower()
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 1), aDestino) //Obtém informações do arquivo origem - nWhere = 1 (Servidor) - Lower()
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 2), aDestino) //Obtém informações do arquivo origem - nWhere = 2 (cliente)  - Lower()

        If Len(aOrigem) > 0 .And. Len(aDestino) > 0
            lIguais  := .T.

            For nIndice := 1 To Len(aOrigem[1]) // Verificacao de diferencas entre arquivo temporario e servidor
                If aOrigem[1][nIndice] <> aDestino[1][nIndice]
                    lIguais := .F.
                Endif
            Next
        EndIf

        If lIguais .or. Len(aOrigem) == 0 .Or. Len(aDestino) == 0

            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 0 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 0 (Relativo)
            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 1 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 1 (Servidor)
            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 2 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 2 (cliente)

            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 0 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 0 (Relativo)
            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 1 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 1 (Servidor)
            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 2 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 2 (cliente)

            //Se os conteúdos codificados em MD5 forem iguais, os arquivos são considerados iguais
            lIguais := Iif(!Empty(cMD5A) .And. !Empty(cMD5B), cMD5A == cMD5B, lIguais)

            //Caso algum MD5 esteja vazio, força comparação via Base64
            If Empty(cMD5A) .Or. Empty(cMD5B) .OR. nCobertura == 1
                cBase64A := Iif(Empty(cBase64A), Encode64( , cOrigem , , .F.), cBase64A) //Gera Base64 do arquivo nWhere lChangeCase = False
                cBase64A := Iif(Empty(cBase64A), Encode64( , cOrigem , , .T.), cBase64A) //Gera Base64 do arquivo nWhere lChangeCase = True

                cBase64B := Iif(Empty(cBase64B), Encode64( , cDestino , , .F.), cBase64B) //Gera Base64 do arquivo nWhere lChangeCase = False
                cBase64B := Iif(Empty(cBase64B), Encode64( , cDestino , , .T.), cBase64B) //Gera Base64 do arquivo nWhere lChangeCase = True

                If !(Empty(cBase64A) .Or. Empty(cBase64B)) .OR. nCobertura == 1
                    lIguais := cBase64A == cBase64B
                EndIf

            EndIf
            
        EndIf

    EndIf

    ErrorBlock(bErrorBlock)

Return lIguais

/*/
METHOD conteudoArquivosIguais(cOrigem, cDestino, nCobertura) CLASS QDODocumentControl

    Local aDestino    := Nil
    Local aOrigem     := Nil
    Local bErrorBlock := ErrorBlock({|| })
    Local cBase64A    := Nil
    Local cBase64B    := Nil
    Local cMD5A       := Nil
    Local cMD5B       := Nil
    Local lIguais     := .F.
    
    Default nCobertura := 0

    If !Empty(cOrigem) .And. !Empty(cDestino) .And. Self:existeArquivoWhereDinamico(cOrigem) .AND. Self:existeArquivoWhereDinamico(cDestino)

        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 0), aOrigem) //Obtém informações do arquivo origem - nWhere = 0 (Relativo)
        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 1), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Servidor)
        aOrigem  := Iif(Empty(aOrigem) , Directory(cOrigem        , , 2), aOrigem) //Obtém informações do arquivo origem - nWhere = 2 (cliente)
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 0), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Relativo) - Lower()
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 1), aOrigem) //Obtém informações do arquivo origem - nWhere = 1 (Servidor) - Lower()
        aOrigem  := Iif(Empty(aOrigem) , Directory(Lower(cOrigem) , , 2), aOrigem) //Obtém informações do arquivo origem - nWhere = 2 (cliente)  - Lower()

        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 0), aDestino) //Obtém informações do arquivo destino - nWhere = 1 (Relativo)
        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 1), aDestino) //Obtém informações do arquivo destino - nWhere = 1 (Servidor)
        aDestino := Iif(Empty(aDestino), Directory(cDestino        , , 2), aDestino) //Obtém informações do arquivo destino - nWhere = 2 (cliente)
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 0), aDestino) //Obtém informações do arquivo origem - nWhere = 1 (Relativo) - Lower()
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 1), aDestino) //Obtém informações do arquivo origem - nWhere = 1 (Servidor) - Lower()
        aDestino := Iif(Empty(aDestino), Directory(Lower(cDestino) , , 2), aDestino) //Obtém informações do arquivo origem - nWhere = 2 (cliente)  - Lower()

        If (Len(aOrigem) > 0 .And. Len(aDestino) > 0) .Or. nCobertura == 2

            lIguais  := .T.

            //Tamanho dos arquivos diferentes
            If (aOrigem[1][2] <> aDestino[1][2]) .Or. nCobertura == 2
                lIguais := .F.
            Endif

        EndIf

        If lIguais .Or. Len(aOrigem) == 0 .Or. Len(aDestino) == 0
            
            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 0 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 0 (Relativo)
            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 1 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 1 (Servidor)
            cMD5A := Iif(Empty(cMD5A), MD5File( cOrigem , 1, 2 ), cMD5A) //Gera chave MD5 do arquivo nWhere = 2 (cliente)

            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 0 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 0 (Relativo)
            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 1 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 1 (Servidor)
            cMD5B := Iif(Empty(cMD5B), MD5File( cDestino, 1, 2 ), cMD5B) //Gera chave MD5 do arquivo nWhere = 2 (cliente)

            //Se os conteúdos codificados em MD5 forem iguais, os arquivos são considerados iguais
            lIguais := Iif(!Empty(cMD5A) .And. !Empty(cMD5B), cMD5A == cMD5B, lIguais)

            //Caso algum MD5 esteja vazio, força comparação via Base64
            If Empty(cMD5A) .Or. Empty(cMD5B) .OR. nCobertura == 1
                cBase64A := Iif(Empty(cBase64A), Encode64( , cOrigem , , .F.), cBase64A) //Gera Base64 do arquivo nWhere lChangeCase = False
                cBase64A := Iif(Empty(cBase64A), Encode64( , cOrigem , , .T.), cBase64A) //Gera Base64 do arquivo nWhere lChangeCase = True

                cBase64B := Iif(Empty(cBase64B), Encode64( , cDestino , , .F.), cBase64B) //Gera Base64 do arquivo nWhere lChangeCase = False
                cBase64B := Iif(Empty(cBase64B), Encode64( , cDestino , , .T.), cBase64B) //Gera Base64 do arquivo nWhere lChangeCase = True

                If !(Empty(cBase64A) .Or. Empty(cBase64B)) .OR. nCobertura == 1
                    lIguais := cBase64A == cBase64B
                EndIf

            EndIf

        EndIf

    EndIf

    ErrorBlock(bErrorBlock)

Return lIguais

/*/{Protheus.doc} recuperaBackupOriginalPerdido
Renomeia arquivo original perdido em interrompimento de movimentações anteriores (.xyz ou .bkp.tmp) para o nome original do arquivo
Evita atrito com usuário ao identificar que existe um backup do arquivo original perdido quando não localizado o arquivo original
@author brunno.costa
@since 05/06/2025
@param 01 - cOrigem   , caracter, nome ORIGEM do arquivo a ser renomeado
@param 02 - nCobertura, numérico, variável temporária para auxiliar cobertura
/*/
METHOD recuperaBackupOriginalPerdido(cOrigem, nCobertura) CLASS QDODocumentControl

    Local cExtensao := Right("." + aTail(StrTokArr(cOrigem, ".")), 4)
    Local cFileBPK  := cOrigem + ".bkp.tmp"
    Local cFileXYZ  := StrTran(cOrigem, cExtensao, ".xyz")
    Local nRenomeou := -999

    If !File(cOrigem)  .OR. nCobertura == 4 .OR. nCobertura == 5
        If     Self:existeArquivoWhereDinamico(cFileBPK) .OR. nCobertura == 4
            Self:renomeiaArquivo(cFileBPK, cOrigem, @nRenomeou, nCobertura)

        ElseIf Self:existeArquivoWhereDinamico(cFileXYZ) .OR. nCobertura == 5
            Self:renomeiaArquivo(cFileXYZ, cOrigem, @nRenomeou, nCobertura)

        EndIf
    EndIf

Return 

/*/{Protheus.doc} arquivoLiberado
Verifica se o arquivo cOrigem está liberado ou bloqueado por outro processo
@author brunno.costa
@since 05/06/2025
@param 01 - cArquivo, caracter, nome ORIGEM do arquivo a ser renomeado
@param 02 - lValida , lógico  , indica se valida e exibe mensagem em caso de falha
@return lLiberado, lógico, indica se o arquivo está liberado (.T.) ou bloqueado (.F.)
/*/
METHOD arquivoLiberado(cArquivo, lValida) CLASS QDODocumentControl

    Local cFileBPK  := cArquivo + "_check_lock_.tmp"
    Local lLiberado := .F.
    Local nRenomeou := -999

    Default lValida := .F.

    If Self:existeArquivoWhereDinamico(cArquivo)
        If Self:renomeiaArquivo(cArquivo, cFileBPK, @nRenomeou, , cArquivo, lValida)
            If Self:renomeiaArquivo(cFileBPK, cArquivo, @nRenomeou, , cArquivo, lValida)
                lLiberado := .T.
            EndIf
        EndIf
    Else
        lLiberado := .T. //Arquivo não existe, considerado liberado
    EndIf

    lLibPorRef := lLiberado // Retorna por referência se o arquivo está liberado ou não

Return lLiberado



