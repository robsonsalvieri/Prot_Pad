#INCLUDE "TOTVS.CH"
#INCLUDE "QEPXFUN.CH"

/*/{Protheus.doc} QEPXFUN
Rotinas comuns aos modulos de Qualidade
@author Equipe Quality
@since 06/03/2003
/*/


/*/{Protheus.doc} QEPXFUNAuxClass
Classe geral do QEPXFUN
@author willian.ramalho
@since 17/03/2026
/*/
CLASS QEPXFUNAuxClass FROM LongNameClass
    
	METHOD new() CONSTRUCTOR
	METHOD converteStringEmNumero(cValor)
	METHOD truncaValorCampoNumerico(cAlias, cCampoDest, nVlrOrigem)
	METHOD validaTamanhoDoCampoQuantidadeEPreco(aCamposDst, cCampoRef)
	METHOD validaTamanhoDoConteudoDosCampos(aDestinos, nValorRef, cCampoRef, nOpc)

	Static Method copiaArquivoParaServidor(cArqAnexo, cQPathTrm, cPath, cHelpId, cProblema, cSolucao, nCobertura)
	Static Method estagiaEAbrePreSave(cArquivo, cQPathTrm, cAlias, nOpc)
	Static Method garanteDir(cDiretorio, nCobertura)
	Static Method garanteSeparadorFinal(cDiretorio, cSeparador)
	Static Method nomeFisicoAnexo(cMsUid, cNomeOriginal)
	Static Method normalizaSeparador(cPath, cSeparador)
	Static Method renomeiaArquivoPorCaixa(cArquivo)
	Static Method resolveDiretorioServidorPorCaixa(cDiretorio)
	Static Method resolveMVDiretorioServidor(cParamMV, cDefault)
	Static Method visualizaAnexoComFallback(cMsUid, cNomeOriginal, cPath, cQPathTrm, nOpc, cAlias)
	
ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe
@author willian.ramalho
@since 17/03/2026
@return Self
/*/
METHOD new() CLASS QEPXFUNAuxClass 
Return Self

/*/{Protheus.doc} garanteSeparadorFinal
Garante que o diretorio informado termine com o separador recebido.
@author brunno.costa
@since 04/06/2026
@version P12
@param 01 - cDiretorio , caracter, diretorio a ser tratado
@param 02 - cSeparador , caracter, separador esperado para o ambiente
@return cDiretorio, caracter, diretorio com separador final
/*/
METHOD garanteSeparadorFinal(cDiretorio, cSeparador) CLASS QEPXFUNAuxClass

    If Right(cDiretorio, 1) != cSeparador
        cDiretorio += cSeparador
    EndIf

Return cDiretorio

/*/{Protheus.doc} normalizaSeparador
Normaliza os separadores de diretorio da string recebida para o separador informado.
@author brunno.costa
@since  04/06/2026
@param 01 - cPath, caracter, caminho com separadores mistos
@param 02 - cSeparador, caracter, separador destino (\ ou /)
@return cPath, caracter, caminho com separadores normalizados
/*/
METHOD normalizaSeparador(cPath, cSeparador) CLASS QEPXFUNAuxClass
Return StrTran(StrTran(cPath, "\", cSeparador), "/", cSeparador)

/*/{Protheus.doc} resolveDiretorioServidorPorCaixa
Resolve um diretório em servidor com filesystem case-sensitive (Linux), avaliando nível a nível.
Para cada segmento: usa a caixa exata se existir; senão procura no diretório pai uma entrada equivalente
ignorando caixa (Directory) e adota a caixa real; se o nível não existir em nenhuma caixa, cria-o conforme
a configuração original e segue. Retorna o caminho real existente (ou recém-criado).
@author brunno.costa
@since  03/06/2026
@param 01 - cDiretorio, caracter, diretório conforme configurado (ex.: MV_DIRCQ, MV_QLDINSP)
@return cReal, caracter, caminho resolvido para a caixa real do servidor
/*/
METHOD resolveDiretorioServidorPorCaixa(cDiretorio) CLASS QEPXFUNAuxClass

    Local aSegmentos := {}
    Local aEntradas  := {}
    Local cSep       := IIF(ISSRVUNIX(),"/","\")  //Separador conforme SO do Servidor (Linux x Windows)
    Local cOrig      := AllTrim(cDiretorio)
    Local cBase      := ""
    Local cReal      := ""
    Local cSegmento  := ""
    Local lTrailing  := .F. // Preserva se o parametro original terminava com separador
    Local lAchou     := .F.
    Local nSeg       := 0
    Local nEnt       := 0

    If Empty(cOrig)
        Return cOrig
    EndIf

    cOrig     := QEPXFUNAuxClass():normalizaSeparador(cOrig, cSep)
    // O processamento abaixo sempre monta cBase com separador ao final de cada segmento.
    // lTrailing indica se esse separador final fazia parte da entrada original.
    lTrailing := Right(cOrig, 1) == cSep

    If Left(cOrig, 1) == cSep
        cBase := cSep
        cOrig := Substr(cOrig, 2)
    EndIf

    aSegmentos := StrTokArr(cOrig, cSep)

    For nSeg := 1 To Len(aSegmentos)
	
        cSegmento := AllTrim(aSegmentos[nSeg])
        If Empty(cSegmento)
            Loop
        EndIf

        If ExistDir(cBase + cSegmento, , .F.)

            cBase += cSegmento + cSep

        Else

            lAchou    := .F.

			//Analisa diretório com outro Case Sensitive apenas em servidores Unix
			If ISSRVUNIX()
				aEntradas := Directory(cBase + "*", "D", ,.F.)
				For nEnt := 1 To Len(aEntradas)
					If "D" $ aEntradas[nEnt][5] ;
					.And. aEntradas[nEnt][1] != "." .And. aEntradas[nEnt][1] != ".." ;
					.And. Upper(aEntradas[nEnt][1]) == Upper(cSegmento)
						cBase  += aEntradas[nEnt][1] + cSep
						lAchou := .T.
						Exit
					EndIf
				Next nEnt
			EndIf

            If !lAchou
                cBase += cSegmento + cSep
                QEPXFUNAuxClass():garanteDir(cBase)
            EndIf

        EndIf

    Next nSeg

    cReal := cBase

    // Se a entrada original nao tinha separador final, remove o separador adicionado
    // durante a montagem de cBase para manter o contrato do metodo.
    If !lTrailing .And. Right(cReal, 1) == cSep
        cReal := Left(cReal, Len(cReal) - 1)
    EndIf

Return cReal

/*/{Protheus.doc} renomeiaArquivoPorCaixa
Localiza e renomeia arquivo resolvendo sua caixa real (case-insensitive) no servidor.
Util para casos onde um arquivo foi criado/listado com caixa diferente do esperado, especialmente
em servidores Unix (case-sensitive). Busca o arquivo no mesmo diretorio com Directory (ignorando caixa),
e se encontrar diferente da caixa esperada, renomeia para a caixa configurada via FRename.
@author brunno.costa
@since  11/06/2026
@param 01 - cArquivo, caracter, caminho completo do arquivo esperado (ex.: /path/to/MyFile.txt)
@param 02 - lServer , lógico  , indica se usa caminho no servidor ou no cliente
@return lSucesso, logico, .T. se renomeou ou arquivo ja existe com caixa correta
/*/
METHOD renomeiaArquivoPorCaixa(cArquivo, lServer) CLASS QEPXFUNAuxClass

    Local aArquivos     := {}
    Local cBase         := ""
    Local cNomeEsperado := ""
    Local cSep          := ""
    Local lSucesso      := .F.
    Local nArq          := 0

	Default lServer := .T.
    Default cArquivo := ""

    If Empty(cArquivo)
        Return .F.
    EndIf

    // Normaliza o caminho para o separador do servidor
	cSep := IIF(Iif(lServer, ISSRVUNIX(), GetRemoteType() == 2), "/", "\")
    cArquivo := QEPXFUNAuxClass():normalizaSeparador(cArquivo, cSep)

    // Extrai diretorio e nome do arquivo esperado
    nArq := RAt(cSep, cArquivo)
    If nArq > 0
        cBase := Left(cArquivo, nArq)
        cNomeEsperado := SubStr(cArquivo, nArq + 1)
    Else
        cNomeEsperado := cArquivo
        cBase := ""
    EndIf

    If Empty(cNomeEsperado)
        Return .F.
    EndIf

    // Resolve o diretorio para a caixa real (suporta Linux case-sensitive)
    cBase := QEPXFUNAuxClass():resolveDiretorioServidorPorCaixa(cBase)
    cBase := QEPXFUNAuxClass():garanteSeparadorFinal(cBase, cSep)

    // Se o arquivo ja existe com a caixa esperada, sucesso
	cNomeEsperado := Lower(cNomeEsperado)
    If File(cBase + cNomeEsperado,,.F.)
        Return .T.
    EndIf

	// Lista arquivos no diretorio com 2o parametro explicito para evitar ambiguidade posicional
	aArquivos := Directory(cBase + "*", "", , .F.)

    // Busca arquivo case-insensitive
    For nArq := 1 To Len(aArquivos)

        // Directory retorna array: [1]=nome, [2]=tamanho, [3]=data, [4]=hora, [5]=atributos
        // Filtra apenas arquivos (nao diretorio - "D" deve estar ausente em aAtributos)
        If "D" $ aArquivos[nArq][5] .Or. ;
           aArquivos[nArq][1] == "." .Or. aArquivos[nArq][1] == ".."
            Loop
        EndIf

        // Compara nome case-insensitive
        If Upper(aArquivos[nArq][1]) == Upper(cNomeEsperado)

            // Se encontrou com caixa diferente, renomeia usando FRename
            If aArquivos[nArq][1] != cNomeEsperado
                lSucesso := (FRename(cBase + aArquivos[nArq][1], cBase + cNomeEsperado, , .F.) == 0)
            Else
                lSucesso := .T.
            EndIf

            EXIT

        EndIf

    Next nArq

Return lSucesso

/*/{Protheus.doc} resolveMVDiretorioServidor
Lê o parâmetro cParamMV via SuperGetMV, resolve a caixa do diretório no servidor
(delegando para resolveDiretorioServidorPorCaixa) e, se estiver em servidor Unix e o
caminho resolvido diferir do valor original, atualiza o parâmetro via PutMV.
@author brunno.costa
@since  04/06/2026
@param 01 - cParamMV, caracter, nome do parâmetro MV que contém o diretório
@param 02 - cDefault , caracter, valor padrão caso o parâmetro não esteja configurado (opcional)
@return cReal, caracter, caminho resolvido para a caixa real do servidor
/*/

METHOD resolveMVDiretorioServidor(cParamMV, cDefault) CLASS QEPXFUNAuxClass

    Local cDefaultDir := ""
    Local cDir        := ""
    Local cReal       := ""

    If ValType(cDefault) == "C"
        cDefaultDir := AllTrim(cDefault)
    EndIf

    cDir := AllTrim(SuperGetMV(cParamMV, .F., cDefaultDir))

    If (Empty(cDir) .Or. cDir == "/" .Or. cDir == "\") .And. !Empty(cDefaultDir)
        cDir := cDefaultDir
    EndIf

    cReal := QEPXFUNAuxClass():resolveDiretorioServidorPorCaixa(cDir)

    If ISSRVUNIX() .And. cReal != cDir
        PutMV(cParamMV, cReal)
    EndIf

Return cReal

/*/{Protheus.doc} nomeFisicoAnexo
Retorna nome fisico do arquivo de anexo com UUID hifenizado.
Serve tanto para QQM quanto para QQN.
@author brunno.costa
@since 04/06/2026
@version P12
@param 01 - cMsUid      , caracter, valor do campo MSUID
@param 02 - cNomeOriginal, caracter, valor do campo NOMEOR
@return cArquivo, caracter, nome fisico do anexo
/*/
METHOD nomeFisicoAnexo(cMsUid, cNomeOriginal) CLASS QEPXFUNAuxClass
    Local cUID      := ""
    Local cExtensao := ""
    Local cArquivo  := ""

    Default cMsUid        := ""
    Default cNomeOriginal := ""

    cUID := Lower(AllTrim(cMsUid))

    If !("-" $ cUID) .And. Len(cUID) == 32
        cUID := SubStr(cUID, 1, 8) + "-" + SubStr(cUID, 9, 4) + "-" + SubStr(cUID, 13, 4) + "-" + SubStr(cUID, 17, 4) + "-" + SubStr(cUID, 21, 12)
    EndIf

    If !Empty(cNomeOriginal) .And. RAT(".", cNomeOriginal) > 0
        cExtensao := aTail(StrTokArr(cNomeOriginal, "."))
        cArquivo  := cUID + "." + cExtensao
    Else
        cArquivo := cUID
    EndIf

Return cArquivo


/*/{Protheus.doc} visualizaAnexoComFallback
Visualiza anexo tentando nome fisico hifenizado e legado (alguns fluxos DB oracle) nos paths informados.
@author brunno.costa
@since 04/06/2026
@version P12
@param 01 - cMsUid       , caracter, valor do campo MSUID
@param 02 - cNomeOriginal, caracter, valor do campo NOMEOR
@param 03 - cPath        , caracter, path definitivo do anexo - Prioridade
@param 04 - cQPathTrm    , caracter, path fallback para abertura
@param 05 - nOpc         , numerico, operacao do QVRFANEXO
@param 06 - cAlias       , caracter, alias do anexo
@return cArquivo, caracter, nome fisico selecionado
/*/
METHOD visualizaAnexoComFallback(cMsUid, cNomeOriginal, cPath, cQPathTrm, nOpc, cAlias) CLASS QEPXFUNAuxClass

    Local cArquivo       := ""
    Local cArquivoFisico := QEPXFUNAuxClass():nomeFisicoAnexo(cMsUid, cNomeOriginal)
    Local cArquivoLegado := ""
    Local cBarSrv        := "/"
    Local cExtensao      := ""
    Local cUID           := Lower(AllTrim(cMsUid))

    If !ISSRVUNIX()
        cBarSrv := "\"
    EndIf

    cPath     := QEPXFUNAuxClass():normalizaSeparador(AllTrim(cPath), cBarSrv)
    cQPathTrm := AllTrim(cQPathTrm)

    cPath := QEPXFUNAuxClass():garanteSeparadorFinal(cPath, cBarSrv)


    If !Empty(cNomeOriginal) .And. RAT(".", cNomeOriginal) > 0
        cExtensao      := aTail(StrTokArr(cNomeOriginal, "."))
        cArquivoLegado := Lower(AllTrim(StrTran(cUID, "-", ""))) + "." + cExtensao
    Else
        cArquivoLegado := Lower(AllTrim(StrTran(cUID, "-", "")))
    EndIf

    If File(cPath + cArquivoFisico)
        cArquivo := cArquivoFisico
        QVRFANEXO(nOpc, cArquivo, cAlias, cPath)
    ElseIf File(cPath + cArquivoLegado)
        cArquivo := cArquivoLegado
        QVRFANEXO(nOpc, cArquivo, cAlias, cPath)
    ElseIf File(cQPathTrm + cArquivoFisico)
        cArquivo := cArquivoFisico
        QEPXFUNAuxClass():estagiaEAbrePreSave(cArquivo, cQPathTrm, cAlias, nOpc)
    ElseIf File(cQPathTrm + cArquivoLegado)
        cArquivo := cArquivoLegado
        QEPXFUNAuxClass():estagiaEAbrePreSave(cArquivo, cQPathTrm, cAlias, nOpc)
    Else
        cArquivo := cArquivoFisico
        QVRFANEXO(nOpc, cArquivo, cAlias, cPath)
    EndIf

Return cArquivo

/*/{Protheus.doc} estagiaEAbrePreSave
Reabre anexo ainda nao persistido (em web-temp) garantindo o registro no WebAgent (WebApp HTML).
A inclusao server-to-server deposita o arquivo no web-temp sem registra-lo para o WebAgent, entao
o QA_OPENARQ nao consegue entregar ao browser. Aqui o arquivo e reestagiado via CpyT2S/CpyS2T
(mesmo ciclo do fluxo ja persistido, que funciona) antes de delegar ao QVRFANEXO.
Em SmartClient desktop, ou quando o reestagio falha, mantem o comportamento atual sem efeito colateral.
@author brunno.costa
@since 04/06/2026
@version P12
@param 01 - cArquivo , caracter, nome fisico do anexo
@param 02 - cQPathTrm, caracter, path temporario do terminal (web-temp)
@param 03 - cAlias   , caracter, alias do anexo
@param 04 - nOpc     , numerico, operacao do QVRFANEXO
@return Nil
/*/
METHOD estagiaEAbrePreSave(cArquivo, cQPathTrm, cAlias, nOpc) CLASS QEPXFUNAuxClass

    Local cBarSrv  := IIf(ISSRVUNIX(), "/", "\")
    Local cScratch := ""

    //Apenas WebApp HTML (GetRemoteType 5) precisa do reestagio para o WebAgent registrar o arquivo.
    //Demais terminais mantem o fluxo atual, sem efeito colateral.
    If GetRemoteType() == 5 .And. File(cQPathTrm + cArquivo)

        //Scratch relativo ao RootPath (server-only, NAO servido pelo WebAgent).
        //resolveDiretorioServidorPorCaixa resolve a caixa real (Unix) e cria os niveis ausentes.
        cScratch := QEPXFUNAuxClass():resolveDiretorioServidorPorCaixa("system" + cBarSrv + "qdo_anexo_tmp" + cBarSrv)
        cScratch := QEPXFUNAuxClass():garanteSeparadorFinal(cScratch, cBarSrv)

        //web-temp -> scratch (servidor) -> web-temp registrado. Sobrescreve a copia nao-registrada.
        //So o scratch e removido; o web-temp nunca fica sem copia (evita perda no persist posterior).
        //Guarda ExistDir evita o popup "Directory does not exist" se o scratch nao puder ser criado.
        If ExistDir(cScratch) .And. CpyT2S(cQPathTrm + cArquivo, cScratch, .T.) .And. File(cScratch + cArquivo)
            CpyS2T(cScratch + cArquivo, cQPathTrm, .T.)
            FErase(cScratch + cArquivo)
        EndIf

    EndIf

    QVRFANEXO(nOpc, cArquivo, cAlias, cQPathTrm)

Return

/*/{Protheus.doc} copiaArquivoParaServidor
Copia arquivo de anexo do path temporario do servidor para o destino final.
Usa QDODocumentControl:copiaProtegidaArquivo para copia Server-to-Server.
@author brunno.costa
@since 04/06/2026
@version P12
@param 01 - cArqAnexo, caracter, nome fisico do arquivo
@param 02 - cQPathTrm, caracter, path temporario no servidor
@param 03 - cPath    , caracter, path destino no servidor
@param 04 - cHelpId   , caracter, identificador do help a exibir em falha (default: "QEPNAOCOP")
@param 05 - cProblema , caracter, descricao do problema a exibir no help (default: "", exibe help generico)
@param 06 - cSolucao  , caracter, descricao da solucao a exibir no help (default: "")
@param 07 - nCobertura, numerico, forca caminho de falha para cobertura (0=normal, 1=QIEA217EVDEF, 2=QIPA217EVDEF)
@return lSucesso, logico, indica se copiou o arquivo
/*/
METHOD copiaArquivoParaServidor(cArqAnexo, cQPathTrm, cPath, cHelpId, cProblema, cSolucao, nCobertura) CLASS QEPXFUNAuxClass

    Local cBarSrv     := "/"
    Local cDestino    := ""
    Local cOrigem     := ""
    Local lSucesso    := .F.
	Local oDocControl := QDODocumentControl():New()

    Default cHelpId    := "QEPNAOCOP"
    Default cProblema  := ""
    Default cSolucao   := ""
    Default nCobertura := 0

    If !ISSRVUNIX()
        cBarSrv := "\"
    EndIf

    cQPathTrm := AllTrim(cQPathTrm)
    cPath     := QEPXFUNAuxClass():normalizaSeparador(AllTrim(cPath), cBarSrv)
    cPath     := QEPXFUNAuxClass():garanteSeparadorFinal(cPath, cBarSrv)

    cPath := QEPXFUNAuxClass():resolveDiretorioServidorPorCaixa(cPath)

    cOrigem  := cQPathTrm + cArqAnexo
    cDestino := cPath + cArqAnexo

    lSucesso := oDocControl:copiaProtegidaArquivo(cOrigem, cDestino)
    lSucesso := lSucesso .And. File(cDestino)

    // nCobertura > 0: simula falha para cobertura de linhas (1=QIEA217EVDEF, 2=QIPA217EVDEF)
    If nCobertura > 0
        lSucesso := .F.
    EndIf

    If lSucesso
        FErase(cOrigem)
    Else
        If Empty(cProblema)
            Help(" ", 1, "QEPNAOCOP")
        Else
            Help(NIL, NIL, cHelpId, NIL, cProblema, 1, 0, NIL, NIL, NIL, NIL, NIL, {cSolucao})
        EndIf
    EndIf

Return lSucesso




/*/{Protheus.doc} garanteDir
Cria o diretorio informado via MakeDir e registra falha em log se a criacao falhar.
@author brunno.costa
@since  08/06/2026
@param 01 - cDiretorio , caracter, caminho do diretorio a ser criado
@param 02 - nCobertura , numerico, forca retorno de falha para cobertura de testes (0=normal, <>0=simula falha com o valor informado)
@return lSucesso, logico, .T. se o diretorio foi criado com sucesso
/*/
METHOD garanteDir(cDiretorio, nCobertura) CLASS QEPXFUNAuxClass

    Local nRetMkDir := 0
    Local lSucesso  := .F.

    Default nCobertura := 0

    nRetMkDir := MakeDir(cDiretorio)

    lSucesso := (nRetMkDir == 0)

    If !lSucesso .Or. nCobertura != 0
        FWLogMsg("ERROR", "", "QEPXFUN", FunName(), "", "01", STR0030 + AllTrim(cDiretorio) + STR0031 + cValToChar(nRetMkDir), 0, 0, {}) //"Falha ao criar diretorio. Diretorio: " + " | Retorno MakeDir: "
    EndIf

Return lSucesso
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³ QepAdmAne³ Autor ³ Cleber Souza          ³ Data ³ 07/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Administra os arquivos anexos.               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ QepAdmAne(EXPC1,EXPN1)									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Nome do Arquivo Anexo.   				 	      ³±±
±±³			 ³ EXPN2 = 1 - Inclui										  ³±±
±±³			 ³ 		   2 - Exclui										  ³±±
±±³			 ³ EXPC3 = Nome do Alias do Programa.   					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ EXPC1 - Arquivo Anexo									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAQIE													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function QepAdmAne(cArqTMP,nOpc,cAlias)

	Local cArqAnexo := " "
	Local cBarRmt   := "\" //Separador do terminal: definido por sniff do path (apos QDOPATH); ver bloco abaixo
	Local cBarSrv   := IIF(ISSRVUNIX(),"/","\") //Separador conforme SO do Servidor (ex.: Linux)
	Local cDelAnexo := Alltrim(GetMv("MV_QDELFNC")) // "Apagar Documentos Anexos no Diretorio Temporario"
	Local cQPathDoc := IIF(cAlias == "QIE",Alltrim(GetMv("MV_QIEDOC")),Alltrim(GetMv("MV_QIPDOC")))
	Local cQPathTrm := Alltrim(Alltrim(QDOPATH()[3]))
	Local nPos      := 0

	//Separador do terminal deriva do proprio path resolvido por QDOPATH (robusto p/ Windows SC, Linux SC e WebApp tipo 5).
	//GetRemoteType()==2 NAO cobre WebApp, que roda em appserver Linux e exige "/".
	cBarRmt := Iif("/" $ cQPathTrm, "/", "\")

	//Normaliza os separadores conforme o SO de cada destino: temporario (estacao) x diretorio (servidor)
	cQPathTrm := QEPXFUNAuxClass():normalizaSeparador(cQPathTrm, cBarRmt)
	cQPathDoc := QEPXFUNAuxClass():normalizaSeparador(cQPathDoc, cBarSrv)

	cQPathTrm := QEPXFUNAuxClass():garanteSeparadorFinal(cQPathTrm, cBarRmt)
	cQPathDoc := QEPXFUNAuxClass():garanteSeparadorFinal(cQPathDoc, cBarSrv)

	If nOpc == 1 //Inclui
		cArqAnexo:= Substr(cAlias,2,2)+StrZero(Val(QA_SEQU(Substr(cAlias,2,2),10,"N","")),10)

		nPos  := RAT(".",cArqTmp)
		cArqAnexo := cArqAnexo + Substr(cArqTmp,nPos,(Len(Alltrim(cArqTmp))+1)-nPos)

		//Copia TMP para o nome correto.
		If File(cQPathTrm+cArqTmp)
			__CopyFile(cQPathTrm + cArqTmp,cQPathTrm + cArqAnexo)
			If !File(cQPathTrm + cArqAnexo)
				Help(" ",1,"QEPNAOCOP")
				Return(cArqAnexo)
			Endif
		EndIf

		If cDelAnexo == "1"
			FErase(cQPathTrm+cArqTmp)
		EndIf

		//Copia para o Server
		If !CpyT2S(cQPathTrm + cArqAnexo,cQPathDoc,.T.)
			Help(" ",1,"QEPNAOCOP")
			Return(cArqAnexo)
		Endif

	ElseIf nOpc == 2  //Exclui

		//Apaga o arquivo no servidor
		If File(cQPathDoc+Alltrim(cArqTmp))
			FErase(cQPathDoc+Alltrim(cArqTmp))
		EndIf

		//Verifica se existe local e apaga.
		If File(cQPathTrm+Alltrim(cArqTmp))
			FErase(cQPathTrm+Alltrim(cArqTmp))
		EndIf
	EndIf

Return(cArqAnexo)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CalcHora  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 06.10.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Retorna o numero de horas.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³QIPA010()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CalcHora(nHrIni,nHrFim,cLimite,lVrfHrNeg)
Local nVar		:= 0
Local nInt		:= 0
Local nDec		:= 0
Local cResult	:= 0
Local nPosTmpI	:= At(":",nHrIni)
Local nPosTmpF	:= At(":",nHrFim)

Default lVrfHrNeg := .F.

nIni := (Val(Left(nHrIni,nPosTmpI-1)) * 60) + Val(Right(AllTrim(nHrIni),2))
nFim := (Val(Left(nHrFim,nPosTmpF-1)) * 60) + Val(Right(AllTrim(nHrFim),2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limite Inferior ou Carregando Ensaio da Especificacao Inferior/Superior.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cLimite == "I"
	nFim := Val(StrTran(Str(nFim),"-",""))
	nVar := nIni - nFim
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso o hora final seja menor que a Incial, o sinal devera ser negativo.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lVrfHrNeg
		If nFim < nIni
			If At("-",Str(nVar)) == 0
				nVar:= -nVar
			EndIf
		EndIf
	EndIf
Else
	nVar := nIni + nFim
EndIf

nInt := Int(nVar / 60)
nDec := Mod(nVar , 60)

cResult := StrZero(nInt,Iif(Len(Alltrim(Str(nInt)))==1,2,Len(Alltrim(Str(nInt)))))+":"+StrZero(nDec,2)

Return(cResult)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³QA_Def5429³ Autor ³ Marcos Cesar          ³ Data ³05.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula o Indice de Defeitos baseado na Norma NBR-5429.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpN1 := QA_Def5429(ExpA1,ExpN1,ExpN2,ExpN3)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 == Array com as medicoes.                             ³±±
±±³          ³ExpN1 == Limite inferior com tolerancia.                    ³±±
±±³          ³ExpN2 == Limite superior com tolerancia.                    ³±±
±±³          ³ExpC1 == Codigo da Norma (Plano).                           ³±±
±±³          ³ExpN3 == Tamanho da Amostra.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA1[1] = Media											  ³±±
±±³			 ³     [2] = Desvio Padrao									  ³±±
±±³			 ³     [3] = PI												  ³±±
±±³			 ³     [4] = PS												  ³±±
±±³			 ³     [5] = PI+PS											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function QA_Def5429(aMedicao,nLimInf,nLimSup,cPlano,nTamAmostra)
Local aMediaDV := {}
Local nIndQS   := 0
Local nIndQI   := 0
Local nIndDef  := 0                   
Local nPI      := 0
Local nPS      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula a Media e o Desvio Padrao. Retorno :                            ³
//³                                                                         ³
//³ aMediaDV[1] : Media                                                     ³
//³ aMediaDV[2] : Desvio Padrao                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMediaDV := QA_CalcDV(aMedicao)

If nLimInf > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o QI.                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIndQI := (aMediaDV[1] - nLimInf) / aMediaDV[2]
	nIndQI := Round(nIndQI,2)
	
	If nIndQI > 3.89
		nPI := 0
	ElseIf nIndQI < (3.89*-1)
		nPI := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQI), "@E 99.99"), .T.))
		If nIndQI < 0
			nPI := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPI := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIF

If nLimSup > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula o QS.                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nIndQS := (nLimSup - aMediaDV[1]) / aMediaDV[2]
	nIndQS := Round(nIndQS,2)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa o Arquivo QA1 com o valor do QI.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nIndQS > 3.89
		nPS := 0
	ElseIf nIndQS < (3.89*-1)
		nPS := 100
	Else
		QA1->(dbSetOrder(1))
		QA1->(dbSeek(xFilial("QA1") + cPlano + Str(nTamAmostra,4) + Transform(Abs(nIndQS), "@E 99.99"), .T.))
		If nIndQS < 0
			nPS := Round(100-QA1->QA1_VLREPD,2)
		Else
			nPS := QA1->QA1_VLREPD
		EndIf
	EndIf
EndIf

nTamAmostra := If(nTamAmostra>140,140,nTamAmostra)
	
nIndDef  := (nPI+nPS)
aRetorno := {aMediaDV[1],aMediaDV[2],nPI,nPS,nIndDef}  
Return(aRetorno) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³QEP_RetAmostra³ Autor ³ Paulo Emidio de Barros³ Data ³22/08/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Define a amostragem a ser aplicada de acordo com a selecao do  ³±±
±±³		     ³ Plano de Amostragem                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,;   ³±±
±±³			 ³ 				  lSeparaPlano)	  								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ EXPC1 = Tipo do Plano de Amostragem							  ³±±
±±³			 ³ EXPC2 = Plano de Amostragem									  ³±±
±±³			 ³ EXPC3 = Nivel do Plano de Amostragem						      ³±±
±±³			 ³ EXPC4 = NQA													  ³±±
±±³			 ³ EXPC5 = Tamanho da Amostra									  ³±±
±±³			 ³ EXPC6 = Campo que define o Tamanho da Amostra				  ³±±
±±³			 ³ EXPL1 = Indica se as Amostragens definidas no Plano Interno se-³±±
±±³			 ³         rao separadas.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ EXPA1 = Amostragens definidas no Plano						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                              
Function QEP_RetAmostra(cTipAmo,cPlaAmo,cNivel,cNQA,cTamAmo,cCpoAmo,lSeparaPlano)
Local aAreaAnt   := GetArea()
Local aRetorno   := {}
Local cNorma     := ' '
Local cSequencia := ' '
Local cTipo      := ' '                     
Local cCodAmo    := ' '
Local nAmostra1  := 0
Local nAceite1   := 0
Local nRejeite1  := 0
Local nAmostra2  := 0
Local nAceite2   := 0
Local nRejeite2  := 0
Local cAmostra   := " "
Local aPlaInt1   := {} //Amostragem Simples
Local aPlaInt2   := {} //Amostragem Dupla
Local cTamFor    := " "  
Local nTamAmo    := 0
                
cNorma := QA_Plano(cTipAmo)

lSeparaPlano := If(lSeparaPlano==NIL,.F.,lSeparaPlano)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica tipo de Inspecao a ser aplicada de acordo c/ o Plano ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipAmo == '1') .Or. (cTipAmo == 'N') .Or. ; //NBR5426 
   (cTipAmo == '3') .Or. (cTipAmo == 'I')        //Plano Interno
	cTipo := If(Right(cPlaAmo,1)=="A","AT",If(Right(cPlaAmo,1)=="N","NO","SE"))
ElseIf (cTipAmo == '2') .Or. (cTipAmo == 'Z') .Or.; //Zero Defeito (QS9000)
	   (cTipAmo == '4') .Or. (cTipAmo == 'T')       //Plano Texto	
	cTipo := "QS"
ElseIf (cTipAmo == '5') .Or. (cTipAmo == 'B') //NBR5429
	cTipo := If(AllTrim(cPlaAmo)=="A","AT",If(AllTrim(cPlaAmo)=="N","NO","SE"))
EndIf
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Codigo das Amostras de acordo com o Plano        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAmostra := Str(SuperVal(cTamAmo),8)
cNivel   := If(cPlaAmo=="QS",cPlaAmo,cNivel) //Verifica se o Plano e Zero Defeito

dbSelectArea("QA6")
dbSetOrder(2)
dbSeek(xFilial("QA6")+cNorma+cNivel+cAmostra,.T.)
If !Eof()
	cCodAmo := QA6_CODAMO
EndIf
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define a sequencia para que na amostragem dupla, seja retorna-³
//³das as sequencias 1 e 2.										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSequencia := If(Left(cPlaAmo,1)<>'D','0','1')

dbSelectArea("QA7") 
dbSetOrder(3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza o tratamento para a Amostragem definida no Plano In- ³
//³ terno.														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cTipAmo == "3") .Or. (cTipAmo == "I") //Plano Interno

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ aRetorno [x,1] = ACEITE 1                                    ³
	//³          [x,2] = REJEITE 1                                   ³
	//³ 		 [x,3] = AMOSTRA 1 									 ³
	//³          [x,4] = ACEITE 2 									 ³
	//³ 		 [x,5] = REJEITE 2									 ³
	//³ 		 [x,6] = AMOSTRA 2									 ³
	//³          [x,7] = SEQUENCIA									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetorno := {}

	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo)
	While !Eof() .And. QA7_FILIAL==xFilial("QA7") .And. QA7_PLANO==cNorma .And. QA7_NQA==cNQA .And. QA7_CODAMO==cCodAmo

        Aadd(aRetorno,Array(7))
        
		If Empty(QA7_NO_FOR)
			nTamAmo := If(QA7_NO_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_NO_AMO) 
		Else       
			cTamFor := QA7->QA7_NO_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)                                    
			Else	
				nTamAmo := 0
			EndIf          
		EndIf	               
		
		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Simples 
		aRetorno[Len(aRetorno),1] := QA7_NO_ACE //Aceite 1
		aRetorno[Len(aRetorno),2] := QA7_NO_REJ //Rejeite 1
		aRetorno[Len(aRetorno),3] := nTamAmo    //Tamanho da Amostra 1	
		
		If Empty(QA7_SE_FOR)        
			nTamAmo := If(QA7_SE_AMO>SuperVal(cTamAmo),SuperVal(cTamAmo),QA7_SE_AMO)
	    Else         
			cTamFor := QA7->QA7_SE_FOR
			If !Empty(cTamFor) .And. !Empty(cTamAmo)
				cTamFor := AllTrim(StrTran(cTamFor,"#Tam.Lote#",cTamAmo))
				nTamAmo := &(cTamFor)
			Else          
				nTamAmo := 0
			EndIf	
	    EndIf    

		//Armazena por sequencia, o Aceite e o Rejeite das Amostragens Duplas
		aRetorno[Len(aRetorno),4] := QA7_SE_ACE //Aceite 2
		aRetorno[Len(aRetorno),5] := QA7_SE_REJ //Rejeite 2
		aRetorno[Len(aRetorno),6] := nTamAmo    //Tamanho da Amostra 2	
		aRetorno[Len(aRetorno),7] := QA7_SEQUE  //Sequencia
		
		dbSelectArea("QA7")
		dbSkip()
		
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formata o retorno do vetor para os Planos de Amostragens do  ³
	//³ Tipo Interno, devolvendo os mesmos em dois vetores, sendo:	 ³
	//³ x[1] = Sequencia											 ³
	//³      = Aceite 1												 ³
	//³      = Rejeite 1											 ³
	//³      = Tamanho da Amostra 1									 ³
	//³ x[2] = Sequencia											 ³
	//³      = Aceite 2												 ³
	//³      = Rejeite 2											 ³
	//³      = Tamanho a Amostra 2									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Len(aRetorno) == 0  //Verifica se o vetor nao esta definido com as Amostragens
    	Aadd(aRetorno,Afill(Array(7),0))
	    aRetorno[Len(aRetorno),7]:= " "
	EndIf        
	
	If lSeparaPlano
		Aeval(aRetorno,{|x,y|Aadd(aPlaInt1,{x[7],x[1],x[2],x[3]}),Aadd(aPlaInt2,{x[7],x[4],x[5],x[6]})})
		aRetorno := {aClone(aPlaInt1),aClone(aPlaInt2)}
	EndIf
		                                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona o Tamanho das Amostras de acordo com o Codigo      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else                               
	aRetorno := Afill(Array(6),0)
	
	dbseek(xFilial("QA7")+cNorma+cNQA+cCodAmo+cSequencia)
	If !Eof()
	
	    //Verifica se o Plano e QS-9000
	 	If cTipo == "QS"
			nAceite1  := 0
			nRejeite1 := 1
		Else		
			nAceite1  := &("QA7_"+cTipo+"_ACE")
			nRejeite1 := &("QA7_"+cTipo+"_REJ")
		EndIf                           
		nAmostra1 := &("QA7_"+cTipo+"_AMO")
		nAmostra1 := If(nAmostra1>SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra1)
		    
		//Caso a Amostragem seja dupla, considera a segunda Sequencia
		If cSequencia == '1'      
			dbSkip() //Considera a sequencia 2
		
			nAceite2  := &("QA7_"+cTipo+"_ACE")
		   	nRejeite2 := &("QA7_"+cTipo+"_REJ")
			nAmostra2 := &("QA7_"+cTipo+"_AMO")
			nAmostra2 := If(nAmostra2> SuperVal(cTamAmo),SuperVal(cTamAmo),nAmostra2)
		
		EndIf
		aRetorno[1] := nAmostra1 //Amostra 1
		aRetorno[2] := nAceite1  //Aceite  1
		aRetorno[3] := nRejeite1 //Rejeite 1
		aRetorno[4] := nAmostra2 //Amostra 2
		aRetorno[5] := nAceite2  //Aceite  2
		aRetorno[6] := nRejeite2 //Rejeite 2
	EndIf
EndIf

RestArea(aAreaAnt)
Return(aRetorno)      


/* {Protheus.doc} validaTamanhoDoCampoQuantidadeEPreco
Method responsavel por validar se os campos Caractere de Quantidade e Preco
sao compativeis com o campo numerico de referencia informado.
@author willian.ramalho
@since 10/03/2026
@version 1.0
@param aCamposDst, array    , array de campos do tipo caractere a serem validados com o campo de referencia
@param cCampoRef , caractere, campo de referencia do tipo numerico para comparacao de tamanho dos campos do array
@return lOk	     , logico   , .T. = Indica que os campos do array são compatíveis com o campo de referência
							  .F. = Indica que existe incompatibilidade de tamanho entre os campos destino e o campo de referencia
*/
Method validaTamanhoDoCampoQuantidadeEPreco(aCamposDst, cCampoRef) CLASS QEPXFUNAuxClass

	Local aCmpInco   := {} //Campos incompatíveis para detalhamento da mensagem de erro
	Local cCampoDst  := ""
	Local cDetalhe   := ""
	Local cHelp      := "QEPCAMPOSINCO"
	Local cMsg       := ""
	Local cTipoField := ""
	Local lOk        := .T.
	Local nIndice    := 0
	Local nTamDst    := 0
	Local nTamRef    := GetSx3Cache(cCampoRef, "X3_TAMANHO")

	For nIndice := 1 To Len(aCamposDst)

		cCampoDst  := AllTrim(aCamposDst[nIndice])
		cTipoField := GetSx3Cache(cCampoDst, "X3_TIPO")
		nTamDst    := GetSx3Cache(cCampoDst, "X3_TAMANHO")

		If cTipoField == "C"
			If (nTamDst < nTamRef) .Or. (nTamDst > nTamRef)
				lOk := .F.
				AAdd(aCmpInco, cCampoDst + " (" + AllTrim(Str(nTamDst))+ ")")
			EndIf
		EndIf

	Next nIndice

	If !lOk
		AEval(aCmpInco, {|cItem| cDetalhe += cItem + Chr(13)+Chr(10)})
		// STR0021 - Divergência de tamanho de campos detectada com o campo de referência:
		// STR0016 - Está configurado com tamanho:
		// STR0022 - Essa diferença pode causar inconsistencia de dados.
		// STR0023 - Campos com tamanho incompatível:
		cMsg := STR0021 + " '" + cCampoRef + "' " + STR0016 + "(" + AllTrim(Str(nTamRef)) + ")." +Chr(13)+Chr(10)+ STR0022 + STR0023 + Chr(13)+Chr(10) + cDetalhe			
		
		cHelp := IIF(cModulo $ "QIP", "QIPCAMPOSINCO", IIF(cModulo $ "QIE", "QIECAMPOSINCO", cHelp))

		// STR0024 - Realize o ajuste de tamanho do campo no Configurador (SIGACFG). 
		// STR0025 - Para ficar compativel com o tamanho do campo de referencia
		// STR0020 - Tamanho sugerido para compatibilidade: 		
		LogMsg(cHelp, 0, 0, 1, '', '', "[" + cHelp + "] " + cMsg + ": " + STR0024 +  STR0025 + Chr(13)+Chr(10) + STR0020 + "(" +cValToChar(nTamRef+1) + ").")

	EndIf

Return lOk


/* {Protheus.doc} validaTamanhoDoConteudoDosCampos
Method responsavel por validar se havera truncamento de dados no momento de gravacao do valor do campo de referencia para os campos destino, 
caso o tamanho do conteudo do campo de referencia seja maior que o tamanho dos campos destino.
@author willian.ramalho / henrique.adelino
@since 18/03/2026
@version 1.0
@param01 aDestinos , array   , campos de destino para comparacao de tamanho com o campo de referencia/origem
@param02 nValorRef , numerico, valor do conteudo do campo de referencia/origem para comparacao
@param03 cCampoRef , caracter, campo de referencia/origem para comparacao de tamanho do conteudo
@param04 nOpc      , numerico, operação selecionada
@return lValido    , logico  , .T. = Indica que o valor do campo referencia/origem cabe no campo de destino sem truncamento de dados.
							   .F. = Indica que havera truncamento do valor do campo origem para o campo destino. 
							 
*/
Method validaTamanhoDoConteudoDosCampos(aDestinos, nValorRef, cCampoRef, nOpc) CLASS QEPXFUNAuxClass

	Local aIncompati := {} //Campos incompatíveis para detalhamento da mensagem de erro
	Local cAlias     := ""
	Local cCamposInc := "" //Campos incompatíveis para detalhamento da mensagem de erro
	Local cDestino   := ""
	Local cHelp      := "QEPTRUNCADADOS"
	Local cMsg       := ""
	Local cPicture   := ""
	Local cTipoDesti := ""
	Local cTipoOrig  := ""
	Local cUsaMaisUm := ""
	Local cValorDest := ""
	Local lValido    := .T.
	Local nIndCampo  := 0
	Local nTamanho   := ""
	Local nTamDest   := 0
	Local nTamRef    := GetSx3Cache(cCampoRef, "X3_TAMANHO")
	Local nValDest   := 0
	
	For nIndCampo := 1 To Len(aDestinos)

		cDestino   := aDestinos[nIndCampo]
		cAlias     := Left(cDestino, 3)
		cPicture   := PesqPict(cAlias, cDestino)
		cPicture   := Iif(Empty(cPicture), "@E ", cPicture)
		cTipoDesti := GetSx3Cache(cDestino , "X3_TIPO")
		cTipoOrig  := GetSx3Cache(cCampoRef, "X3_TIPO")
		nTamanho   := GetSx3Cache(cDestino , "X3_TAMANHO")

		If cTipoDesti == "C"
			cValorDest := SubString(Transform(nValorRef, cPicture),1, nTamanho)
			nValDest  := self:converteStringEmNumero(cValorDest)
		Else
			nValDest  := Self:truncaValorCampoNumerico(cAlias, cDestino, nValorRef)
		EndIf
		
		
		If nValDest <> nValorRef
			lValido  := .F.
			AAdd(aIncompati, cDestino + " (" + AllTrim(Str(nTamanho))+ ")")
		EndIf


	Next nIndCampo

	If nOpc == 1 //Inclusão

		cHelp := cModulo + "NOINC" // QIPNOINC / QIENOINC
		// STR0027 - A inclusão da inspeção foi bloqueada devido a incompatibilidade de tamanho dos campos: 
		cMsg += STR0027 + Chr(13)+Chr(10)

	Elseif nOpc == 3 // Alteração

		cHelp := cModulo + "NOALT" // QIPNOALT / QIENOALT
		// STR0028 - A alteração da inspeção foi bloqueada devido a incompatibilidade de tamanho dos campos:
		cMsg += STR0028 + Chr(13)+Chr(10)

	Endif

	If !lValido

		AEval(aIncompati, {|cItem| cCamposInc += " - " + cItem + Chr(13)+Chr(10)})
		cUsaMaisUm := IIF(cTipoOrig == "N" .And. cTipoDesti == "C", "+1", "")
	
		// STR0016 - Estão configurados com tamanho divergente do tamanho do campo de referencia 
		cMsg += cCamposInc + STR0016 + cUsaMaisUm + " : " + cCampoRef + IIF(cTipoOrig == "N" .And. cTipoDesti == "C", " (" + cValToChar(nTamRef) + " +1 = " + cValToChar(nTamRef+1) + ")", " (" + cValToChar(nTamRef) + ").")
		nTamDest := IIF(cTipoOrig == "N" .And. cTipoDesti == "C", nTamRef+1, nTamRef) //Considera o byte de final de campo para campos do tipo caractere

		// STR0029 - Corrija o tamanho dos campos citados na mensagem acima para o Tamanho: 
		Help(NIL, NIL, cHelp, NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0029 + cValToChar(nTamDest)+"."})

	EndIf
	
Return lValido


/* {Protheus.doc} truncaValorCampoNumerico
Method responsavel por formatar e truncar o valor de referencia de acordo com
a mascara (picture) e o tamanho maximo definidos para o campo destino, evitando
erros de gravacao por excesso de tamanho.
@author willian.ramalho
@since 26/03/2026
@version 1.0
@param cAlias     , caracter, alias da tabela que contem o campo destino
@param cCampoDest , caracter, nome do campo destino utilizado para obter a mascara e o tamanho maximo permitido - exclusivo campo numérico
@param nVlrOrigem , numerico, valor do campo de referencia/origem a ser formatado e truncado
@return nVlrCampo , numerico, valor formatado e truncado
*/
Method truncaValorCampoNumerico(cAlias, cCampoDest, nVlrOrigem) CLASS QEPXFUNAuxClass
    
    Local nTamCampo := GetSx3Cache(cCampoDest, "X3_TAMANHO")
	Local nVlrCampo := Val(Padr(nVlrOrigem, nTamCampo))

Return nVlrCampo

/* {Protheus.doc} converteStringEmNumero
Method responsavel por converter uma string numerica em valor numerico,
tratando automaticamente o separador decimal conforme o locale do ambiente (ponto ou virgula).
@author willian.ramalho
@since 01/04/2026
@version 1.0
@param cValor , caracter, string contendo o valor numerico a ser convertido, podendo conter separador de milhar e decimal conforme o locale (ex.: "1.250,99" ou "1250.99").
@return nValor, numerico, valor convertido para numerico.
*/
Method converteStringEmNumero(cValor) CLASS QEPXFUNAuxClass

	Local cDecimal  := IIF("." $ AllTrim(Transform(1.5, "@E 9.9")), ".", ",")
	Local cVlrLimpo := ""
	Local nValor    := Val(cValor)

	If cDecimal == ","

		cVlrLimpo := AllTrim(cValor)
		cVlrLimpo := STRTRAN(cVlrLimpo, ".", "")
		cVlrLimpo := STRTRAN(cVlrLimpo, ",", ".")
		nValor 	  := Val(cVlrLimpo)

	EndIf

Return nValor
