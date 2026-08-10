#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"
#INCLUDE "FILEIO.CH"

// Tempo de espera para aguardar a abertura das threads.
// Cada unidade representa um sleep de 100ms
#DEFINE TEMPO_AGUARDA_ABERTURA 600
#DEFINE MINIMO_THREADS_ABERTAS 2
#DEFINE MAXIMO_THREADS_ABERTAS 4

#DEFINE ID_GRAV_TEMPOS      "TEMPOS"
#DEFINE ID_GRAV_OCORRENCIAS "OCORRENCIAS"
#DEFINE ID_GRAV_DISP        "DISPONIBILIDADE"
#DEFINE ID_GRAV_FERRAMENTAS "FERRAMENTAS"

#DEFINE ID_RECURSO_ADC "REC"

// Geração de Log (MV_LOGCRP)
#DEFINE QUEBRA_LINHA CHR(13) + CHR(10)
#DEFINE CABECALHO_ARQUIVO "Data Hora;Thread;Etapa;OP;Operacao;Recurso;Arvore;Mensagem"

Static _oDisp     := Nil
Static _oProcesso := Nil
Static _oTempOper := Nil
Static _oNivela   := Nil
Static _oGrava    := Nil
Static _oCampos   := Nil
Static _oDataApon := Nil
Static _oLogs     := Nil
Static _oFerramen := Nil

/*/{Protheus.doc} PCPA152
Chamada da tela de Programação (PO-UI)

@type Function
@author Marcelo Neumann
@since 02/03/2023
@version P12
@return Nil
/*/
Function PCPA152()
	Local lHWF  := AliasInDic("HWF")

	If !lHWF
		Help(' ', 1,"Help" ,, STR0438, 1, 1, , , , , , {STR0439}) // "Não é permitido a execução desta rotina com dicionário de dados desatualizado." "Atualize o dicionário de dados para habilitar o uso desta rotina."
		Return Nil
	Endif

	//Verifica se está sendo aberto pelo módulo SIGAPCP
	If PCPVldModu("PCPA152", {10}) .And. PCPVldApp()
		FwCallApp('pcpa152')
	EndIf

Return Nil

/*/{Protheus.doc} JsToAdvpl
Bloco de código que receberá as chamadas da tela.

@type  Static Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 oWebChannel, Object  , Instancia da classe TWebEngine.
@param 02 cType      , Caracter, Parametro de tipo.
@param 03 cContent   , Caracter, Conteudo enviado pela tela.
@return .T.
/*/
Static Function JsToAdvpl(oWebChannel, cType, cContent)
	Local oJsRet := JsonObject():New()

	Do Case
		Case cType == "loadData"
			oJsRet["dataBase"  ] := DTOC(dDatabase)
			oJsRet["dicionario"] := JsonObject():New()

			oJsRet["dicionario"]["T4X_DESCRI"] := JsonObject():New()
			oJsRet["dicionario"]["T4X_DESCRI"]["tamanho"] := GetSX3Cache("T4X_DESCRI", "X3_TAMANHO")
			oJsRet["dicionario"]["T4X_DESCRI"]["exists" ] := oJsRet["dicionario"]["T4X_DESCRI"]["tamanho"] > 0

			oJsRet["dicionario"]["MS_DESC"] := JsonObject():New()
			oJsRet["dicionario"]["MS_DESC"]["tamanho"] := GetSX3Cache("MS_DESC", "X3_TAMANHO")
			oJsRet["dicionario"]["MS_DESC"]["exists" ] := oJsRet["dicionario"]["MS_DESC"]["tamanho"] > 0

			oJsRet["dicionario"]["MF_PRIOR"] := JsonObject():New()
			oJsRet["dicionario"]["MF_PRIOR"]["tamanho"] := GetSX3Cache("MF_PRIOR", "X3_TAMANHO")
			oJsRet["dicionario"]["MF_PRIOR"]["exists" ] := oJsRet["dicionario"]["MF_PRIOR"]["tamanho"] > 0

			oJsRet["dicionario"]["MF_SOBREPO"] := JsonObject():New()
			oJsRet["dicionario"]["MF_SOBREPO"]["tamanho"] := GetSX3Cache("MF_SOBREPO", "X3_TAMANHO")
			oJsRet["dicionario"]["MF_SOBREPO"]["exists" ] := oJsRet["dicionario"]["MF_SOBREPO"]["tamanho"] > 0

			oJsRet["dicionario"]["MF_REMOCAO"] := JsonObject():New()
			oJsRet["dicionario"]["MF_REMOCAO"]["tamanho"] := GetSX3Cache("MF_REMOCAO", "X3_TAMANHO")
			oJsRet["dicionario"]["MF_REMOCAO"]["exists" ] := oJsRet["dicionario"]["MF_REMOCAO"]["tamanho"] > 0

			oJsRet["dicionario"]["MF_TPALOFE"] := JsonObject():New()
			oJsRet["dicionario"]["MF_TPALOFE"]["tamanho"] := GetSX3Cache("MF_TPALOFE", "X3_TAMANHO")
			oJsRet["dicionario"]["MF_TPALOFE"]["exists" ] := oJsRet["dicionario"]["MF_TPALOFE"]["tamanho"] > 0

			oJsRet["dicionario"]["HZ7"] := AliasInDic("HZ7")

			oJsRet["habilitaApontamento"] := "0"
			If MPUserHasAccess("MATA681")
				oJsRet["habilitaApontamento"] := "1"
			EndIf

			oWebChannel:AdvPLToJS("loadData", oJsRet:toJson())

		Case cType == "callPCPSmartView"
			//Chama função para realizar a execucao do smartview
			PCPSmartView(oWebChannel, cContent)

		Case cType == "executaApontamento"
			execApont(oWebChannel, cContent)

	End

Return .T.

/*/{Protheus.doc} execApont
Executa um apontamento a partir da visão de OPs efetivadas

@type  Static Function
@author lucas.franca
@since 06/09/2024
@version P12
@param 01 oWebChannel, Object, Objeto de comunicação com o Front-end (tWebEngine)
@param 02 cContent   , Caracter, JSON com a chave OP/Operação para realizar o apontamento
@return Nil
/*/
Static Function execApont(oWebChannel, cContent)
	Local nOper := -1
	Local oData := JsonObject():New()

	oData:FromJson(cContent)

	//Seta os dados da chave do apontamento para o MATA681
	If oData["operacao"] != "browse"
		A681AptCRP(oData["chave"])
		nOper := 3
	EndIf

	If _oDataApon == Nil
		_oDataApon  := CockpitDaProducao():new("MATA681", oWebChannel)
	EndIf

	_oDataApon:abrirTela(, nOper)

	FreeObj(oData)

Return Nil

/*/{Protheus.doc} P152Start
Função responsavel por iniciar o processamento do programa.
@type  Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cProg , Caracter, Código da programação para instanciar a classe de processamento.
@param 02 lStart, Logico  , Indica que está iniciando a programação.
@return Nil
/*/
Function P152Start(cProg, lStart)
	Local oProcesso := Nil

	If !PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
		Return Nil
	EndIf

	oProcesso:gravaValorGlobal("THREAD_MASTER", "ABERTA")

	If oProcesso:aguardaPermissaoParaIniciar()
		If lStart
			oProcesso:gravaPercentual(CHAR_ETAPAS_ABERTURA, 50)
		EndIf

		If oProcesso:processaAbertura()
			oProcesso:processar()
		EndIf

		If oProcesso:processamentoCancelado()
			oProcesso:efetivaCancelamento()
		EndIf

		oProcesso:gravaValorGlobal("EXECUTANDO", .F.)
		If oProcesso:oProcError:possuiErro()
			P152Error(oProcesso:retornaProgramacao(), .T.)
		Else
			oProcesso:limpaSecaoGlobal(.T.)
		EndIf
	EndIf

	P152ClnStc()
Return Nil

/*/{Protheus.doc} P152VldPar
Função responsavel por validar os parâmetros MV do pcpa152
@type  Function
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 cParam   , Caracter, Nome do parâmetro que chamou a função.
@param 02 cValor   , Caracter, Valor atribuido ao parâmetro que chamou a função.
@param 03 cValorSpa, Caracter, Valor espanhol atribuido ao parâmetro que chamou a função.
@param 04 cValorEng, Caracter, Valor inglês atribuido ao parâmetro que chamou a função.
@return lOk, Logico, Indica se valor atribuido pode ser usado.
/*/
Function P152VldPar(cParam, cValor, cValorSpa, cValorEng)
	Local lOk := .T.

	If cParam == "MV_A152THR"
		lOk := Val(cValor) <= MAXIMO_THREADS_ABERTAS .And. Val(cValorSpa) <= MAXIMO_THREADS_ABERTAS .And. Val(cValorEng) <= MAXIMO_THREADS_ABERTAS .And.;
		       Val(cValor) >= MINIMO_THREADS_ABERTAS .And. Val(cValorSpa) >= MINIMO_THREADS_ABERTAS .And. Val(cValorEng) >= MINIMO_THREADS_ABERTAS

		If !lOk
			Help(' ', 1,"Help" ,,STR0008, 1, 1, , , , , , {i18n(STR0009, {cValToChar(MINIMO_THREADS_ABERTAS), cValToChar(MAXIMO_THREADS_ABERTAS)})}) // "Quantidade inválida!"  "Quantidade de threads para o processamento deve ser um valor entre #1[quantidade minima]# e #2[quantidade maxima]#."
		EndIf

	ElseIf cParam == "MV_DISPADC"
		lOk := Val(cValor) >= 0 .And. Val(cValorSpa) >= 0 .And. Val(cValorEng) >= 0

		If !lOk
			Help(' ', 1,"Help" ,, STR0411, 1, 1, , , , , , {STR0412}) // "Valor inválido!" "Deve ser informado um valor maior ou igual a 0 (zero)."
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} PCPA152Process
Classe para processamento do pcpa152

@author Lucas Fagundes
@since 01/02/2023
@version P12
/*/
Class PCPA152Process FROM LongNameClass
	Private Data cEtapaIni  as Character
	Private Data cProg      as Character
	Private Data cSemaforo  as Character
	Private Data cUIdError  as Character
	Private Data cUIDGlb    as Character
	Private Data lContinua  as Logical
	Private Data lReproc    as Logical
	Private Data oParametro as Object
	Private Data oTempTable as Object
	Public Data oOcorrens   as Object
	Public Data oProcError  as Object
	Public Data oLogs       as Object

	// Construtor/Destrutor da classe
	Public Method new(cProg) Constructor
	Public Method destroy(lLimpaErro)

	// Métodos de processamento
	Private Method geraDisponibilidadeEPrioriza()
	Private Method processaDistribuicao()
	Private Method processaNivelamento()
	Private Method processaReducaoSetup()
	Private Method processaOperacao()
	Public Method cancelaExecucao()
	Public Method priorizaOrdens()
	Public Method processaAbertura()
	Public Method processaDisponibilidade()
	Public Method processaGravacao()
	Public Method processamentoCancelado()
	Public Method processar()
	Private Method geraDisponibilidadeAdicional()

	// Métodos de manipulação do atributos da classe
	Public Method gravaAtributosGlobais()
	Private Method recuperaAtributosGlobais()
	Public Method retornaProgramacao()
	Public Method retornaParametro(cNome)

	// Métodos de inicialização
	Private Method gravaSetup()
	Private Method iniciaListas()
	Private Method iniciaParametros(oStart)
	Private Method iniciaTabelas(oStart)
	Private Method novaProgramacao()
	Public Method iniciaProgramacao(oStart)

	// Métodos para continuar/reprocessar a programação
	Public Method carregaParametros(aAdicional)
	Public Method atualizaParametros(aParams)
	Private Method preparaEtapasReprocessamento()
	Private Method atualizaTabelaProgramacao(oStart)
	Public Method preparaProgramacao(cProg, oStart, lReproc)

	// Métodos para manipulação das etapas
	Private Method posicionaT4Z(cEtapa)
	Public Method atualizaEtapa(cEtapa, cStatus)
	Public Method criaNovaEtapa(cEtapa, cStatus)
	Public Method gravaPercentual(cEtapa, nPerctge)
	Public Method gravaErro(cEtapa, cMsg, cMsgDet)
	Public Method atualizaStatusProgramacao(cStatus)
	Public Method permiteProsseguir()
	Public Method reiniciaEtapa(cEtapa)

	// Métodos para manipulação de variaveis globais
	Public Method iniciaUIdGlobal(lCriaSecao)
	Private Method criaListaGlobal(cIdLista)
	Public Method gravaValorGlobal(cChave, xValor, lLock, lInc)
	Public Method retornaValorGlobal(cChave, lError, lLock)
	Public Method limpaValorGlobal(cChave)
	Public Method adicionaListaGlobal(cIdLista, cChave, aValor, lInc, nTipoInc)
	Public Method deletaChaveListaGlobal(cIdLista, cChave)
	Public Method retornaListaGlobal(cIdLista, cChave, lError)
	Public Method limpaListaGlobal(cIdLista)
	Public Method limpaSecaoGlobal(lLimpaErro)

	// Métodos para manipulação das threads
	Private Method abreThreads()
	Private Method fechaThreads()
	Public Method utilizaThreads()
	Public Method getSemaforoThreads()
	Public Method delegar(cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait, lAllThd)

	// Métodos de controle da thread master
	Private Method abreThreadMaster(lStart)
	Private Method aguardaThreadMasterIniciar()
	Public Method aguardaPermissaoParaIniciar()

	// Métodos auxiliares
	Private Method abreTempTableOPs()
	Private Method aguardaFimPreparo()
	Private Method posAlocacoes()
	Private Method preparaParaAlocacao()
	Private Method setStatusProgramacao(cStatus)
	Private Method criaBackupCancelamento()
	Private Method geraOcorrenciasOperacoes()
	Public Method criaParametro(cParam, cValor)
	Public Method getMsgErro(cErroMsg, cErroDet)
	Public Method getNomeTempTable()
	Public Method getStatusInicioProgramacao()
	Public Method getStatusProgramacao()
	Public Method getUIDGlobal()
	Public Method getExecucaoReducaoSetup()
	Public Method setExecucaoReducaoSetup(nExecucao)
	Public Method possuiTabelaTemporaria()
	Public Method efetivaCancelamento()
	Public Method getFieldsTempTable()

	// Métodos estaticos
	Static Method executaProgramacao(cProg, oBody, lReproc)
	Static Method getDescricaoEtapa(cEtapa, cProg)
	Static Method getDescricaoStatus(cIdStatus, cEtapa)
	Static Method processamentoFactory(cProg, nOpcao, oReturn, lNoVldErro)
	Static Method trataTipoParametro(aInsere, xValor, lInsere)
	Static Method atualizaPendenciaDeReprocessamento(cProg, nPend)
	Static Method existeCampo(cCampo)
EndClass

/*/{Protheus.doc} new
Metodo construtor da classe PCPA152Process

@author Lucas Fagundes
@since 01/02/2023
@version P12
@param cProg, Caracter, Código da programação caso já esteja em processamento (em branco inicia uma nova programação)
@return Self
/*/
Method new(cProg) Class PCPA152Process

	If Empty(cProg)
		Self:cUIdError  := UUIDRandomSeq()
		Self:oProcError := PCPMultiThreadError():New(Self:cUIdError, .T.)
	Else
		Self:cProg := cProg
		Self:iniciaUIdGlobal(.F.)

		If VarIsUID(Self:cUIdGlb)
			Self:recuperaAtributosGlobais()
		EndIf
	EndIf

	Self:oOcorrens := PCPA152Ocorrencia():new(Self)

	If _oLogs == Nil
		_oLogs := PCPA152Log():new()
	EndIf
	Self:oLogs := _oLogs

Return Self

/*/{Protheus.doc} iniciaProgramacao
Inicia uma nova programação.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param oStart, Object, Json com os parâmetros para inicialização.
@return Nil
/*/
Method iniciaProgramacao(oStart) Class PCPA152Process
	Local lLock      := .T.
	Local nTentativa := 0

	While !lockByName("PCPA152_RESERVA_PROG", .T., .F.)
		If nTentativa > 500
			lLock := .F.
			Self:oProcError:setError("PCPA152Process():iniciaProgramacao()", STR0011, "", "") // "Não foi possivel obter o lock para reservar a programação"
			Exit
		EndIf
		nTentativa++
		Sleep(50)
	End

	If lLock
		Self:cProg := Self:novaProgramacao()

		If Self:iniciaUIdGlobal(.T.)
			Self:lReproc   := .F.
			Self:lContinua := .F.
			Self:cEtapaIni := ""
			Self:iniciaParametros(oStart)

			Self:oLogs:criaArquivo()
			Self:oLogs:gravaLog( , {"Inicio da programacao " + Self:cProg})
			Self:oLogs:gravaParametros(Self:oParametro)

			Self:gravaAtributosGlobais()

			Self:abreThreadMaster(.T.)

			Self:iniciaTabelas(oStart)

			Self:setStatusProgramacao(STATUS_EXECUCAO)

			unlockByName("PCPA152_RESERVA_PROG", .T., .F.)

			Self:aguardaThreadMasterIniciar()
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} novaProgramacao
Retorna o código de uma nova programação.
@author Lucas Fagundes
@since 13/02/2023
@version P12
@return cProg, Caracter, Código de uma nova programação.
/*/
Method novaProgramacao() Class PCPA152Process
	Local cAlias := GetNextAlias()
	Local cProg  := "0000000001"
	Local cQuery := ""

	cQuery := " SELECT MAX(T4X_PROG) ultimaProg "
	cQuery +=   " FROM " + RetSqlName("T4X")
	cQuery +=  " WHERE D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.T.,.T.)
	If !Empty((cAlias)->ultimaProg)
		cProg := (cAlias)->ultimaProg
		cProg := Soma1(cProg)
	EndIf
	(cAlias)->(dbCloseArea())

Return cProg

/*/{Protheus.doc} iniciaUIdGlobal
Cria os UId para as seções global
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param 01 lCriaSecao, Logico, Indica que deve iniciar a seção em memória.
@return lCriou, Logico, Indica se conseguiu criar a seção global.
/*/
Method iniciaUIdGlobal(lCriaSecao) Class PCPA152Process
	Local lCriou     := .F.
	Local nTentativa := 0

	Self:cUIDGlb   := "PCPA152_" + ::cProg
	Self:cSemaforo := "SEM_PCPA152_" + ::cProg

	If lCriaSecao
		While !lCriou
			lCriou := VarSetUID(::cUIDGlb)
			If lCriou
				Self:iniciaListas()
			Else
				nTentativa++
				If nTentativa > 500
					Self:oProcError:setError("PCPA152Process():iniciaUIdGlobal()", STR0197, "") // "Erro ao criar a seção de memória global!"
					Exit
				EndIf
				Sleep(50)
			EndIf
		End
	EndIf

Return lCriou

/*/{Protheus.doc} iniciaParametros
Inicia os parâmetros de processamento através do json de inicialização da programação.
@author Lucas Fagundes
@since 13/02/2023
@version P12
@param oStart, Object, Json com os parâmetros para inicialização.
@return Nil
/*/
Method iniciaParametros(oStart) Class PCPA152Process
	Local aParams := {}
	Local cParam  := ""
	Local nIndex  := 0
	Local nTotPar := 0
	Local oJsAux  := Nil

	aParams := getParMV()

	oJsAux := JsonObject():New()
	oJsAux["codigo"] := "existesfc"
	oJsAux["valor" ] := ExisteSFC('SC2')
	aAdd(oStart["listaParametros"], oJsAux)

	nTotPar := Len(aParams)
	For nIndex := 1 To nTotPar
		oJsAux := JsonObject():New()
		oJsAux["codigo"] := aParams[nIndex][1]
		oJsAux["valor" ] := GetMV(aParams[nIndex][1], .F., aParams[nIndex][2])

		If oJsAux["codigo"] == "MV_A152THR" .And. oJsAux["valor"] < MINIMO_THREADS_ABERTAS
			oJsAux["valor"] := MINIMO_THREADS_ABERTAS
		EndIf

		aAdd(oStart["listaParametros"], oJsAux)
	Next
	FwFreeArray(aParams)

	Self:oParametro := JsonObject():New()

	aParams := oStart["listaParametros"]
	nTotPar := Len(aParams)
	For nIndex := 1 To nTotPar
		cParam := aParams[nIndex]["codigo"]

		If vldTipoPar(cParam, aParams[nIndex]["valor"], .F.)
			Self:oParametro[cParam] := aParams[nIndex]["valor"]
		EndIf
	Next

	Self:oParametro["utiliza_shy"] := Self:retornaParametro("MV_APS") == "TOTVS" .Or. Self:retornaParametro("existesfc") .Or. Self:retornaParametro("MV_PCPATOR")

	oJsAux := JsonObject():New()
	oJsAux["codigo"] := "utiliza_shy"
	oJsAux["valor" ] := Self:oParametro["utiliza_shy"]
	aAdd(oStart["listaParametros"], oJsAux)

	aParams := Nil
	oJsAux  := Nil
Return

/*/{Protheus.doc} getParMV
Retorna os parâmetros MVs utilizados no processamento.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version version
@return aParams, Array, Array com os parametros no seguinte formato: aParams[x][1] - Nome do parâmetro
                                                                     aParams[x][2] - Valor default
/*/
Static Function getParMV()
	Local aParams := {}

	aAdd(aParams, {"MV_A152THR", 4  })
	aAdd(aParams, {"MV_PRECISA", 4  })
	aAdd(aParams, {"MV_PERDINF", .F.})
	aAdd(aParams, {"MV_TPHR"   , "C"})
	aAdd(aParams, {"MV_DISPADC", 365})
	aAdd(aParams, {"MV_APS"    , "" })
	aAdd(aParams, {"MV_PCPATOR", .F.})
	aAdd(aParams, {"MV_LOGCRP" , .F.})
	aAdd(aParams, {"MV_GRAVPCP", .F.})

Return aParams

/*/{Protheus.doc} iniciaTabelas
Inicia as tabelas da programação (T4X, T4Y, T4Z).
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param oStart, Object, Json com os parâmetros para inicialização.
@return lSuccess, Logico, Indica se teve sucesso na inicialização das tabelas.
/*/
Method iniciaTabelas(oStart) Class PCPA152Process
	Local aData    := {}
	Local aParams  := {}
	Local cError   := ""
	Local cFilAux  := ""
	Local cParam   := ""
	Local lSuccess := .T.
	Local nIndex   := 0
	Local nTamPar  := 0
	Local nSeq     := 0
	Local nSeqAux  := 0
	Local oBulk    := FwBulk():New()

	BEGIN TRANSACTION

	RecLock('T4X',.T.)
		T4X_FILIAL := xFilial("T4X")
		T4X_PROG   := Self:cProg
		T4X_STATUS := STATUS_EXECUCAO
		T4X_USER   := oStart["userId"]
		T4X_DTINI  := Date()
		T4X_HRINI  := Time()
		T4X_REPROC := REPROCESSAMENTO_NAO_PENDENTE
		T4X_DESCRI := oStart["descricao"]
	T4X->(MsUnlock())

	cFilAux := xFilial("T4Y")

	oBulk:setTable(RetSqlName("T4Y"))
	oBulk:setFields(structT4Y())

	aParams := oStart["listaParametros"]
	nTamPar := Len(aParams)
	For nIndex := 1 To nTamPar
		cParam := aParams[nIndex]["codigo"]

		If "|" + cParam + "|" $ PAR_MVS .Or. cParam == "existesfc" .Or. cParam == "utiliza_shy"
			nSeq := 99
		Else
			nSeqAux++
			nSeq := nSeqAux
		EndIf

		aData := {cFilAux, Self:cProg, nSeq, cParam}
		Self:trataTipoParametro(@aData, aParams[nIndex]["valor"], .T.)

		oBulk:addData(aData)
	Next

	If !oBulk:close()
		cError	:= oBulk:getError()
	EndIf

	If Empty(cError)
		oBulk:reset()

		oBulk:setTable(RetSqlName("T4Z"))
		oBulk:setFields(structT4Z())

		addEtapas(Self:cProg, @oBulk)

		If !oBulk:close()
			cError := oBulk:getError()
		EndIf
	EndIf

	If !Empty(cError)
		lSuccess := .F.
		DisarmTransaction()
		Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0004, cError) // "Erro na inicialização das tabelas!"
	EndIf

	END TRANSACTION

	oBulk:destroy()

	aSize(aData , 0)
	FwFreeArray(aParams)
Return lSuccess

/*/{Protheus.doc} trataTipoParametro
Trata o tipo dos parâmetros para salvar na tabela T4Z.
@author Lucas Fagundes
@since 08/02/2023
@version P12
@param aInsere, Array , Retorna por referencia o array com o parametro inseridos
@param xValor , Any   , Valor do parâmetro para tratar e inserir no array que salva os dados na tabela T4Z
@param lReturn, Logico, Indica que deve inserir o valor no array.
@return cReturn, Caracter, Valor do parametro convertido para string.
/*/
Method trataTipoParametro(aInsere, xValor, lInsere) Class PCPA152Process
	Local cListaT4Y := Nil
	Local cTipo     := ""
	Local cValorT4Y := ""
	Local cReturn   := ""

	cTipo := ValType(xValor)
	If cTipo == "C"
		cValorT4Y := xValor
		cReturn   := cValorT4Y
	ElseIf cTipo == "N"
		cValorT4Y := cValToChar(xValor)
		cReturn   := cValorT4Y
	ElseIf cTipo == "L" .And. xValor
		cValorT4Y := "true"
		cReturn   := cValorT4Y
	ElseIf cTipo == "L" .And. !xValor
		cValorT4Y := "false"
		cReturn   := cValorT4Y
	ElseIf cTipo == "A"
		cListaT4Y := ArrTokStr(xValor, CHR(10))
		cReturn   := cListaT4Y
	EndIf

	If lInsere
		aAdd(aInsere, cValorT4Y)
		aAdd(aInsere, cListaT4Y)
	EndIf

Return cReturn

/*/{Protheus.doc} structT4Y
Retorna os campos para iniciar os dados da tabela T4Y.
@type  Static Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@return aStruct, Array, Array com os campos que serão usados na inicialização da tabela T4Y.
/*/
Static Function structT4Y()
	Local aStruct := {}

	aAdd(aStruct, {"T4Y_FILIAL"})
	aAdd(aStruct, {"T4Y_PROG"  })
	aAdd(aStruct, {"T4Y_SEQ"   })
	aAdd(aStruct, {"T4Y_PARAM" })
	aAdd(aStruct, {"T4Y_VALOR" })
	aAdd(aStruct, {"T4Y_LISTA" })

Return aStruct

/*/{Protheus.doc} structT4Z
Retorna os campos para iniciar os dados da tabela T4Z.
@type  Static Function
@author Lucas Fagundes
@since 02/02/2023
@version P12
@return aStruct, Array, Array com os campos que serão usados na inicialização da tabela T4Z.
/*/
Static Function structT4Z()
	Local aStruct := {}

	aAdd(aStruct, {"T4Z_FILIAL"})
	aAdd(aStruct, {"T4Z_PROG"  })
	aAdd(aStruct, {"T4Z_SEQ"   })
	aAdd(aStruct, {"T4Z_ETAPA" })
	aAdd(aStruct, {"T4Z_STATUS"})
	aAdd(aStruct, {"T4Z_PERCT" })
	aAdd(aStruct, {"T4Z_DTINI" })
	aAdd(aStruct, {"T4Z_HRINI" })

Return aStruct

/*/{Protheus.doc} addEtapas
Adiciona as etapas no bulk para gravar na tabela T4Z.
@type  Static Function
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param cProg, Caracter, Código da programação.
@param oBulk, Object   , Objeto bulk para adicionar as etapas.
@return Nil
/*/
Static Function addEtapas(cProg, oBulk)
	Local cFilAux   := xFilial("T4Z")
	Local nSeqEtapa := 0

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_ABERTURA      ,;  // T4Z_ETAPA
	               STATUS_EXECUCAO           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               date()                    ,;  // T4Z_DTINI
	               time()                    })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_CALC_DISP     ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_CALC_TEMP     ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_PRIO_ORDEM    ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_DIST_ORD      ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_NIVELAMENTO   ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_REDUZ_SETUP   ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_DISP_ADICIONAL,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI

	nSeqEtapa++
	oBulk:addData({cFilAux                   ,;  // T4Z_FILIAL
	               cProg                     ,;  // T4Z_PROG
	               nSeqEtapa                 ,;  // T4Z_SEQ
	               CHAR_ETAPAS_GRAVACAO      ,;  // T4Z_ETAPA
	               STATUS_PENDENTE           ,;  // T4Z_STATUS
	               0                         ,;  // T4Z_PERCT
	               ""                        ,;  // T4Z_DTINI
	               ""                        })  // T4Z_HRINI
Return Nil

/*/{Protheus.doc} gravaAtributosGlobais
Grava os atributos locais na seção global para ser recuperado quando instanciar a classe em outras threads
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method gravaAtributosGlobais() Class PCPA152Process
	Local cJson := ""

	Self:gravaValorGlobal("ERROR_UID", Self:cUIdError)

	cJson := Self:oParametro:toJson()
	Self:gravaValorGlobal("PCPA152_PARAMETROS", cJson)

	Self:gravaValorGlobal("ETAPA_INICIADA"           , Self:cEtapaIni)
	Self:gravaValorGlobal("REPROCESSANDO_PROGRAMACAO", Self:lReproc  )
	Self:gravaValorGlobal("CONTINUANDO_PROGRAMACAO"  , Self:lContinua)

	Self:gravaValorGlobal("EXECUTANDO", .T.)
Return Nil

/*/{Protheus.doc} recuperaAtributosGlobais
Recupera os atributos da seção de variaveis globais
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method recuperaAtributosGlobais() Class PCPA152Process
	Local cJson := ""

	Self:cUIdError  := Self:retornaValorGlobal("ERROR_UID")
	Self:oProcError := PCPMultiThreadError():New(Self:cUIdError, .F.)

	cJson := Self:retornaValorGlobal("PCPA152_PARAMETROS")
	Self:oParametro := JsonObject():New()
	Self:oParametro:fromJson(cJson)

	Self:cEtapaIni := Self:retornaValorGlobal("ETAPA_INICIADA")
	Self:lReproc   := Self:retornaValorGlobal("REPROCESSANDO_PROGRAMACAO")
	Self:lContinua := Self:retornaValorGlobal("CONTINUANDO_PROGRAMACAO"  )

Return Nil

/*/{Protheus.doc} processar
Metodo responsavel por controlar o processamento do programa.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@return Nil
/*/
Method processar() Class PCPA152Process
	Local lNivela := .F.
	Local oInicio := Self:getStatusInicioProgramacao()

	Self:abreTempTableOPs()

	If !oInicio["continuando"] .And. !oInicio["reprocessando"]

		//ETAPA - CHAR_ETAPAS_CALC_TEMP
		If !Self:processaOperacao()
			Return
		EndIf
		Self:atualizaStatusProgramacao(STATUS_TEMPOS_CALCULADO)

		If !Self:geraDisponibilidadeEPrioriza()
			Return
		EndIf
		Self:atualizaStatusProgramacao(STATUS_DISP_GERADA)
	Else
		Self:preparaParaAlocacao()
	EndIf

	Self:geraOcorrenciasOperacoes()

	lNivela := Self:oParametro["nivelamentoAutomatico"] .Or. Self:getStatusProgramacao() == STATUS_DISTRIBUIDA
	If oInicio["reprocessando"]
		lNivela := Self:cEtapaIni == STATUS_NIVELADO
	EndIf

	If lNivela
		If Self:oParametro["nivelamentoAutomatico"]
			Self:atualizaEtapa(CHAR_ETAPAS_DIST_ORD, STATUS_CONCLUIDO)
		EndIf

		If !Self:processaNivelamento()
			Return
		EndIf
	Else
		Self:atualizaEtapa(CHAR_ETAPAS_NIVELAMENTO, STATUS_CONCLUIDO)
		Self:atualizaEtapa(CHAR_ETAPAS_REDUZ_SETUP, STATUS_CONCLUIDO)

		//ETAPA CHAR_ETAPAS_DIST_ORD
		If !Self:processaDistribuicao()
			Return
		EndIf
	EndIf

	//ETAPA CHAR_ETAPAS_DISP_ADICIONAL
	Self:posAlocacoes()

	//ETAPA CHAR_ETAPAS_REDUZ_SETUP
	If lNivela .And. !Self:processaReducaoSetup()
		Return
	EndIf

	//ETAPA - CHAR_ETAPAS_GRAVACAO
	Self:processaGravacao()

	If lNivela
		Self:atualizaStatusProgramacao(STATUS_NIVELADO)
	Else
		Self:atualizaStatusProgramacao(STATUS_DISTRIBUIDA)
	EndIf

	FreeObj(oInicio)
Return Nil

/*/{Protheus.doc} geraDisponibilidadeEPrioriza
Inicia a geração da disponibilidade e a priorização em paralelo.
@author Lucas Fagundes
@since 06/03/2024
@version P12
@return Nil
/*/
Method geraDisponibilidadeEPrioriza() Class PCPA152Process
	Local cChvDisp := "PROC_ETAPA_" + CHAR_ETAPAS_CALC_DISP
	Local cChvPrio := "PROC_ETAPA_" + CHAR_ETAPAS_PRIO_ORDEM
	Local lSucesso := .T.

	Self:gravaValorGlobal(cChvPrio, "INI")
	Self:gravaValorGlobal(cChvDisp, "INI")

	Self:delegar("P152IniEtp", Self:cProg, CHAR_ETAPAS_PRIO_ORDEM)
	Self:delegar("P152IniEtp", Self:cProg, CHAR_ETAPAS_CALC_DISP)

	While Self:retornaValorGlobal(cChvPrio) == "INI" .Or. Self:retornaValorGlobal(cChvDisp) == "INI"
		Sleep(500)
	End

	lSucesso := Self:retornaValorGlobal(cChvPrio) != "ERRO" .And. Self:retornaValorGlobal(cChvDisp) != "ERRO"

Return lSucesso

/*/{Protheus.doc} P152IniEtp
Inicia uma etapa em uma nova thread.
@type  Function
@author Lucas Fagundes
@since 06/03/2024
@version P12
@param cProg , Caracter, Código da programação.
@param cEtapa, Caracter, Etapa que será iniciada.
@return Nil
/*/
Function P152IniEtp(cProg, cEtapa)
	Local oSelf    := Nil
	Local lSucesso := .F.

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oSelf)
		If cEtapa == CHAR_ETAPAS_PRIO_ORDEM
			lSucesso := oSelf:priorizaOrdens()
		ElseIf cEtapa == CHAR_ETAPAS_CALC_DISP
			lSucesso := oSelf:processaDisponibilidade()
		EndIf

		If lSucesso
			oSelf:gravaValorGlobal("PROC_ETAPA_" + cEtapa, "END")
		Else
			oSelf:gravaValorGlobal("PROC_ETAPA_" + cEtapa, "ERRO")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} destroy
Limpa os atributos locais da classe.
(Não limpa a seção global)

@author Lucas Fagundes
@since 02/02/2023
@version P12
@param lLimpaErro, Logico, Indica se deve ou não realizar o destroy da classe de erro.
@return Nil
/*/
Method destroy(lLimpaErro) Class PCPA152Process
	Default lLimpaErro := .T.

	Self:cProg      := Nil
	Self:cSemaforo  := Nil
	Self:cUIDGlb    := Nil
	Self:cUIdError  := Nil
	If lLimpaErro
		Self:oProcError := Nil
	EndIf
	Self:oParametro := Nil

	If Self:oOcorrens != Nil
		Self:oOcorrens:destroy()
		Self:oOcorrens := Nil
	EndIf

	If _oLogs != Nil
		_oLogs:destroy()
		_oLogs := Nil
	EndIf
	Self:oLogs := Nil

	If Self:oTempTable != Nil
		Self:oTempTable:delete()
		Self:oTempTable := Nil
	EndIf

Return Nil

/*/{Protheus.doc} Method limpaSecaoGlobal()
Limpa a seção de variaveis globais e fecha as threads.
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 lLimpaErro, Logico, Indica se deve ou não realizar o destroy da classe de erro.
@return Nil
/*/
Method limpaSecaoGlobal(lLimpaErro) Class PCPA152Process
	Local aSecoes := {}
	Local nIndex  := 0
	Local nTotal  := 0

	Self:fechaThreads()
	Self:oLogs:gravaLog( , {"Termino do processamento da programacao " + Self:cProg})

	VarGetAD(Self:cUIDGlb, "IDS_LISTA_MEMORIA", @aSecoes)

	If !Empty(aSecoes)
		nTotal := Len(aSecoes)

		For nIndex := 1 To nTotal
			VarClean(Self:cUIDGlb + aSecoes[nIndex])
		Next nIndex

		aSize(aSecoes, 0)
	EndIf

	VarClean(Self:cUIDGlb)
	If lLimpaErro
		Self:oProcError:destroy()
	EndIf
Return Nil

/*/{Protheus.doc} gravaValorGlobal
Seta um conteudo na seção de variavel global.
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cChave, Caracter , Chave identificadora do valor na seção global.
@param 02 xValor, Any      , Valor da flag que será setada.
@param 03 lLock , Logico   , Indica se deve ou não realizar o lock na chave.
@param 04 lInc  , Logico   , Indica que deve gravar flag de incremento.
@param 05 nQtdInc, Numerico, Quantidade que será incrementada, quando lInc estiver .T.
@return lSuccess, Logico, Indica se teve sucesso ao setar a flag.
/*/
Method gravaValorGlobal(cChave, xValor, lLock, lInc, nQtdInc) Class PCPA152Process
	Local lSuccess  := .F.
	Default lLock   := .F.
	Default lInc    := .F.
	Default nQtdInc := 1

	If lInc
		lSuccess := VarSetX(::cUIDGlb, cChave, @xValor, 1, nQtdInc)
	Else
		If lLock
			lSuccess := VarSetX(::cUIDGlb, cChave, xValor)
		Else
			lSuccess := VarSetXD(::cUIDGlb, cChave, xValor)
		EndIf
	EndIf

Return lSuccess

/*/{Protheus.doc} retornaValorGlobal
Recupera o conteudo de uma flag da seção de variavel global.
@author Lucas Fagundes
@since 02/02/2023
@version P12
@param 01 cChave, Caracter, Chave identificadora do valor na seção global.
@param 02 lError, Logico  , Retorna por referência a ocorrencia de erros.
@param 03 lLock , Logico  , Indica se deve realizar o lock na chave ao recuperar o valor.
@return xValor, Undefined, Conteudo da chave na seção de varivel global.
/*/
Method retornaValorGlobal(cChave, lError, lLock) Class PCPA152Process
	Local xValor := Nil
	Default lLock := .F.

	If lLock
		lError := !VarGetX(::cUIDGlb, cChave, @xValor)
	Else
		lError := !VarGetXD(::cUIDGlb, cChave, @xValor)
	EndIf

Return xValor

/*/{Protheus.doc} atualizaEtapa
Atualiza o status de uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 03/02/2023
@version P12
@param 01 cEtapa , Caracter, Etapa que será atualizada.
@param 02 cStatus, Caracter, Status que será gravado.
@return Nil
/*/
Method atualizaEtapa(cEtapa, cStatus) Class PCPA152Process

	If Self:posicionaT4Z(cEtapa)
		RecLock('T4Z',.F.)
			T4Z->T4Z_STATUS := cStatus

			If cStatus == STATUS_CONCLUIDO
				If Empty(T4Z->T4Z_DTINI)
					T4Z->T4Z_DTINI := date()
				EndIf

				If Empty(T4Z->T4Z_HRINI)
					T4Z->T4Z_HRINI := time()
				EndIf

				T4Z->T4Z_DTFIM := date()
				T4Z->T4Z_HRFIM := time()
				T4Z->T4Z_PERCT := 100

			ElseIf cStatus == STATUS_EXECUCAO
				T4Z->T4Z_DTINI := date()
				T4Z->T4Z_HRINI := time()

			ElseIf cStatus == STATUS_CANCELADO
				T4Z->T4Z_DTINI := Iif(Empty(T4Z->T4Z_DTINI), date(), T4Z->T4Z_DTINI)
				T4Z->T4Z_HRINI := Iif(Empty(T4Z->T4Z_HRINI), time(), T4Z->T4Z_HRINI)
				T4Z->T4Z_DTFIM := Iif(Empty(T4Z->T4Z_DTFIM), date(), T4Z->T4Z_DTFIM)
				T4Z->T4Z_HRFIM := Iif(Empty(T4Z->T4Z_HRFIM), time(), T4Z->T4Z_HRFIM)
				T4Z->T4Z_PERCT := 100

			EndIf
		T4Z->(MsUnlock())
	EndIf

Return Nil

/*/{Protheus.doc} gravaPercentual
Atualiza a porcentagem de uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cEtapa  , Caracter, Etapa que será atualizada.
@param 02 nPerctge, Numerico , Porcentagem que será salva para na etapa.
@return Nil
/*/
Method gravaPercentual(cEtapa, nPerctge) Class PCPA152Process

	If Self:posicionaT4Z(cEtapa)
		If T4Z->T4Z_PERCT <> nPerctge
			RecLock('T4Z',.F.)
				T4Z->T4Z_PERCT := nPerctge
			T4Z->(MsUnlock())
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} gravaErro
Grava erro em uma etapa na tabela T4Z.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param 01 cEtapa    , Caracter, Etapa que irá gravar o erro.
@param 02 cMsg      , Caracter, Mensagem de erro.
@param 03 cMsgDet   , Caracter, Mensage detalhada do erro.
@return Nil
/*/
Method gravaErro(cEtapa, cMsg, cMsgDet) Class PCPA152Process
	Local cChave       := ""
	Local cStack       := getStack(2)
	Local cStatusAtu   := ""
	Local cStatusSet   := ""
	Local lError       := .F.
	Local lPos         := .F.

	If cMsgDet == Nil
		cMsgDet := cStack
	EndIf

	If cEtapa == CHAR_ETAPAS_EFETIVACAO
		nSeq := Self:retornaValorGlobal("SEQ_ETAPA_EETIVA", @lError)

		If !lError
			// T4Z_FILIAL+T4Z_PROG+STR(T4Z_SEQ)
			T4Z->(DbSetOrder(1))
			cChave := xFilial("T4Z")+Self:cProg+cValToChar(nSeq)
			lPos   := T4Z->(DbSeek(cChave))
		EndIf
	Else
		lPos := Self:posicionaT4Z(cEtapa)
	EndIf

	If lPos
		cStatusAtu := T4Z->T4Z_STATUS

		If cStatusAtu == STATUS_EXECUCAO .Or. cStatusAtu == STATUS_PENDENTE

			If cStatusAtu == STATUS_EXECUCAO
				cStatusSet := STATUS_ERRO
			ElseIf cStatusAtu == STATUS_PENDENTE
				cStatusSet := STATUS_CANCELADO
			EndIf

			RecLock('T4Z',.F.)
				T4Z->T4Z_STATUS := cStatusSet
				T4Z->T4Z_MSG    := cMsg
				T4Z->T4Z_MSGDET := cMsgDet
				T4Z->T4Z_DTFIM  := date()
				T4Z->T4Z_HRFIM  := time()
			T4Z->(MsUnlock())
		EndIf
	EndIf

	cMsg := cMsg + Chr(13)+Chr(10) + cStack
	Self:oProcError:setError(procName(1), cMsg, cMsgDet, "")

Return Nil
/*/{Protheus.doc} posicionaT4Z
Realiza o posicionamento na etapa da tabela T4Z.
@author Lucas Fagundes
@since 18/12/2023
@version P12
@param cEtapa, Caracter, Etapa que irá posicionar na T4Z.
@return lPos, Logico, Indica se conseguiu posicionar com sucesso.
/*/
Method posicionaT4Z(cEtapa) Class PCPA152Process
	Local lPos   := .F.
	Local nRecno := 0

	If Self:lReproc .And. cEtapa == Self:retornaValorGlobal("ETAPA_REPROC")
		nRecno := Self:retornaValorGlobal("RECNO_ETAPA_REPROC")

		T4Z->(dbGoTo(nRecno))
		lPos := T4Z->(Recno()) == nRecno
	Else
		// T4Z_FILIAL+T4Z_PROG+T4Z_ETAPA
		T4Z->(DbSetOrder(2))
		lPos := T4Z->(DbSeek(xFilial("T4Z")+Self:cProg+cEtapa))
	EndIf

Return lPos

/*/{Protheus.doc} getStack
Retorna a pilha de chamadas.
@type  Static Function
@author Lucas Fagundes
@since 06/02/2023
@version P12
@param nStart, Numerico, Indica uma posição especifica para iniciar a montagem da stack.
@return cStack, Caracter, String com a pilha de chamadas.
/*/
Static Function getStack(nStart)
	Local cProc    := ""
	Local cStack   := ""
	Local nIndex   := 0
	Local nLength  := 5
	Default nStart := 1

	For nIndex := nStart To nLength
		cProc := ProcName(nIndex)

		If Empty(cProc)
			Exit
		EndIf

		cProc  := cProc + " (" + ProcSource(nIndex) + ") line: " + cValToChar(ProcLine(nIndex)) + Chr(13)+Chr(10)
		cStack += cProc
	Next

Return cStack

/*/{Protheus.doc} utilizaThreads
Identifica se utiliza várias threads no processamento.

@author lucas.franca
@since 14/06/2024
@version P12
@return lUtiliza, Logico, Retorna se utiliza várias threads.
/*/
Method utilizaThreads() Class PCPA152Process
	Local lUtiliza := Self:oParametro["MV_A152THR"] > 1
Return lUtiliza

/*/{Protheus.doc} abreThreads
Abre as threads para execução do processamento.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@return lAbriu, Logico, Retorna se conseguiu abrir com sucesso as threads.
/*/
Method abreThreads() Class PCPA152Process
	Local cRecover := ""
	Local lAbriu   := .T.

	If Self:utilizaThreads()
		cRecover := 'P152Error("'+ Self:cProg +'", .F.)'
		PCPIPCStart(Self:cSemaforo, Self:oParametro["MV_A152THR"], Nil, cEmpAnt, cFilAnt, Self:cUIdError, cRecover)

		lAbriu := PCPIPCWIni(Self:cSemaforo, TEMPO_AGUARDA_ABERTURA)

		If !lAbriu
			Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0013, "") // "Não foi possivel abrir as threads de processamento."
		EndIf
	EndIf

Return lAbriu

/*/{Protheus.doc} fechaThreads
Fecha as threads que foram abertas para o processamento.
@author Lucas Fagundes
@since 06/02/2023
@version P12
@return Nil
/*/
Method fechaThreads() Class PCPA152Process

	If Self:oParametro <> Nil .And. Self:utilizaThreads()
		PCPIPCFinish(Self:cSemaforo, 10, Self:oParametro["MV_A152THR"])
	EndIf

Return

/*/{Protheus.doc} getSemaforoThreads
Retorna o identificador do semáforo criado.
@author Marcelo Neumann
@since 05/12/2023
@version P12
@return Self:cSemaforo, Caracter, Identificador do semáforo.
/*/
Method getSemaforoThreads() Class PCPA152Process

Return Self:cSemaforo

/*/{Protheus.doc} delegar
Delega uma função para processamento.
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01    cFuncao, Caracter, Função que será executada.
@param 02-09 xVar   , Any     , Parâmetro para a funcação que será executada
@param 10    lWait  , Logico  , Indica que irá esperar uma thread ser liberada caso todas estejam em uso.
@param 11    lAllThd, Logico  , Indica que deve executar a função em todas as threads que estão rodando.
@return Nil
/*/
Method delegar(cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait, lAllThd) Class PCPA152Process
	Default lWait   := .T.
	Default lAllThd := .F.

	If Self:utilizaThreads()
		PCPIPCGO(Self:cSemaforo, .F., cFuncao, xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9, lWait, lAllThd)
	Else
		&cFuncao.(xVar1, xVar2, xVar3, xVar4, xVar5, xVar6, xVar7, xVar8, xVar9)
	EndIf

Return Nil

/*/{Protheus.doc} P152Error
Grava nas tabelas erros de processamento.
@type  Function
@author Lucas Fagundes
@since 07/02/2023
@version P12
@param 01 cProg     , Caracter, Código da programação que teve erro.
@param 02 lLimpaErro, Logico  , Indica se deve ou não realizar o destroy da classe de erro.
@return Nil
/*/
Function P152Error(cProg, lLimpaErro)
	Local aEtapas    := {}
	Local aError     := {}
	Local cEtapa     := ""
	Local cMsg       := ""
	Local cMsgDet    := ""
	Local nIndex     := 0
	Local nTotEtapas := 0
	Local oEtapa     := Nil
	Local oInfo      := Nil
	Local oProcesso  := Nil

	If !PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso, .T.) .Or. oProcesso:getUIDGlobal() == Nil
		Return Nil
	EndIf

	If InTransact()
		DisarmTransaction()
	EndIf

	If !oProcesso:processamentoCancelado()
		oInfo := P152GetSta(cProg, .F.)

		If oInfo <> Nil
			aEtapas    := oInfo["etapas"]
			nTotEtapas := Len(aEtapas)

			oProcesso:getMsgErro(@cMsg, @cMsgDet)

			For nIndex := 1 To nTotEtapas
				oEtapa  := aEtapas[nIndex]
				cEtapa  := oEtapa["etapa"]

				oProcesso:gravaErro(cEtapa, cMsg, cMsgDet)
			Next

			oProcesso:atualizaStatusProgramacao(STATUS_ERRO)
		EndIf
	EndIf

	If lLimpaErro .And. oProcesso:ologs:logAtivo()
		aError := oProcesso:oProcError:getaError()

		oProcesso:oLogs:gravaLog("error_log", {aError[1][1]})
		oProcesso:oLogs:gravaLog("error_log", {aError[1][2]})
		oProcesso:oLogs:gravaLog("error_log", {aError[1][3]})
		oProcesso:oLogs:gravaLog("error_log", {aError[1][4]})

		aSize(aError, 0)
	EndIf

	oProcesso:limpaSecaoGlobal(lLimpaErro)
	oProcesso:destroy(lLimpaErro)

	If lLimpaErro
		FreeObj(oProcesso)
	EndIf
	FreeObj(oInfo)
Return Nil

/*/{Protheus.doc} getUIDGlobal
Retorna o id da seção global.
@author Lucas Fagundes
@since 18/12/2023
@version P12
@return Self:cUIDGlb, Caracter, ID da seção global.
/*/
Method getUIDGlobal() Class PCPA152Process

Return Self:cUIDGlb

/*/{Protheus.doc} aguardaPermissaoParaIniciar
Aguarda o fim da inicialização da programação.
@author Lucas Fagundes
@since 07/02/2023
@version P12
@return lIniciar, Logico, Retorna se pode ou não iniciar o processamento.
/*/
Method aguardaPermissaoParaIniciar() Class PCPA152Process
	Local cValor   := Self:retornaValorGlobal("THREAD_MASTER")
	Local lIniciar := .T.

	While cValor != "PROCESSAR" .And. !Self:oProcError:possuiErro()
		Sleep(100)
		cValor := Self:retornaValorGlobal("THREAD_MASTER")
	End

	If Self:oProcError:possuiErro()
		lIniciar := .F.
	EndIf

Return lIniciar

/*/{Protheus.doc} aguardaThreadMasterIniciar
Aguarda a inicialização da thread master de processamento.
@author Lucas Fagundes
@since 14/02/2023
@version P12
@return Nil
/*/
Method aguardaThreadMasterIniciar() Class PCPA152Process
	Local cValorAux  := Self:retornaValorGlobal("THREAD_MASTER")
	Local nTentativa := 0

	While cValorAux == "PENDENTE" .And. !Self:oProcError:possuiErro()
		nTentativa++
		If nTentativa > TEMPO_AGUARDA_ABERTURA
			Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0014, "") // "Não foi possivel abrir a thread master para o processamento."
			Exit
		EndIf

		Sleep(100)
		cValorAux := Self:retornaValorGlobal("THREAD_MASTER")
	End

Return Nil

/*/{Protheus.doc} atualizaStatusProgramacao
Atualiza o status da programação na tabela T4X.
@author Lucas Fagundes
@since 08/02/2023
@version P12
@param cStatus, Caracter, Código do status que vai setar na TX4.
@return Nil
/*/
Method atualizaStatusProgramacao(cStatus) Class PCPA152Process

	// T4X_FILIAL+T4X_PROG
	T4X->(DbSetOrder(1))
	If T4X->(DbSeek(xFilial("T4X")+Self:cProg))
		RecLock('T4X',.F.)
			T4X->T4X_STATUS := cStatus

			If cStatus == STATUS_NIVELADO .Or. cStatus == STATUS_ERRO
				T4X->T4X_DTFIM := date()
				T4X->T4X_HRFIM := time()
			EndIf
		T4X->(MsUnlock())
	EndIf
	Self:setStatusProgramacao(cStatus)

Return Nil

/*/{Protheus.doc} criaListaGlobal
Cria uma nova lista de dados
@author lucas.franca
@since 08/02/2023
@version P12
@param cIdLista, Caracter, Identificador da lista
@return Nil
/*/
Method criaListaGlobal(cIdLista) Class PCPA152Process
    //Cria seção para a lista
    If VarSetUID(Self:cUIDGlb + cIdLista)
        //Se criou, armazena ID da seção para limpeza de memória
        VarSetA(Self:cUIDGlb, "IDS_LISTA_MEMORIA", {}, 1, cIdLista)
    EndIf
Return

/*/{Protheus.doc} adicionaListaGlobal
Adiciona dados em uma lista

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 cIdLista, Caracter, Identificador da lista
@param 02 cChave  , Caracter, Chave do registro da lista
@param 03 aValor  , Array   , Array com os valores para adicionar na lista
@param 04 lInc    , Logic   , .T. = Incrementa valor na global. .F. = Substitui valor na global
@param 05 nTipoInc, Numerico, Indica o tipo de soma incremento usado (lInc).
                              1 = Apenas adiciona o valor de oFlag na global. Ex: aAdd(global, oFlag)
                              2 = Adiciona na global os elementos de oFlag de forma separada. Ex: aAdd(global, oFlag[1]), aAdd(global, oFlag[2])
@return Nil
/*/
Method adicionaListaGlobal(cIdLista, cChave, aValor, lInc, nTipoInc) Class PCPA152Process
	Local cUUID := Self:cUIDGlb + cIdLista
	Default nTipoInc := 1

	If lInc
		VarSetA(cUUID, cChave, {}, nTipoInc, @aValor)
	Else
		VarSetAD(cUUID, cChave, @aValor)
	EndIf
Return Nil

/*/{Protheus.doc} retornaListaGlobal
Retorna os dados de uma lista.

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 cIdLista, Caracter, Identificador da lista
@param 02 cChave  , Caracter, Chave do registro da lista. Se vazio, retorna todas as chaves da lista.
@param 03 lError  , Logico  , Retorna por referencia se ocorreu erro.
@return aLista, Array, Array com os dados da lista
/*/
Method retornaListaGlobal(cIdLista, cChave, lError) Class PCPA152Process
	Local aLista := {}
	Local cUUID  := Self:cUIDGlb + cIdLista

	If Empty(cChave)
		lError := !VarGetAA(cUUID, @aLista)
	Else
		lError := !VarGetAD(cUUID, cChave, @aLista)
	EndIf

Return aLista

/*/{Protheus.doc} iniciaListas
Inicia as listas que serão utilizadas durante o processamento.
@author Lucas Fagundes
@since 09/02/2023
@version P12
@return Nil
/*/
Method iniciaListas() Class PCPA152Process
	Self:criaListaGlobal("DADOS_SMR")
	Self:criaListaGlobal("DADOS_SMK")
	Self:criaListaGlobal("DADOS_SMR_ADICIONAL")
	Self:criaListaGlobal("DADOS_SMK_ADICIONAL")
	Self:criaListaGlobal("DISPONIBILIDADE_RECURSOS_ADICIONAL")
	Self:criaListaGlobal(LISTA_DADOS_SMF)
	Self:criaListaGlobal(LISTA_DADOS_SVM)
	Self:criaListaGlobal(LISTA_DADOS_SVY)
	Self:criaListaGlobal("DISPONIBILIDADE_RECURSOS")
	Self:criaListaGlobal("REPROCESSA_DISTRIBUICAO")
	Self:criaListaGlobal("SETUP_ALTERADOS")
	Self:criaListaGlobal(LISTA_DADOS_HZ7)
	Self:criaListaGlobal("ALTERNATIVOS")
	Self:criaListaGlobal("ALOCACOES_NIVELAMENTO")
	Self:criaListaGlobal(LISTA_DADOS_HZJ)
	Self:criaListaGlobal(LISTA_DADOS_HZK)
	Self:criaListaGlobal(LISTA_FERRAMENTAS)
	Self:criaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL)
Return

/*/{Protheus.doc} retornaProgramacao
Retonar a programação da instancia atual da classe.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@return Self:cProg, Caracter, Código da programação
/*/
Method retornaProgramacao() Class PCPA152Process

Return Self:cProg

/*/{Protheus.doc} retornaParametro
Retorna um parâmetro de execução.
@author Lucas Fagundes
@since 10/02/2023
@version P12
@param cNome, Caracter, Nome do parâmetro que irá busca
@return xValor, Any, Valor do parâmetro, se não existir retorna Nil
/*/
Method retornaParametro(cNome) Class PCPA152Process
	Local xValor := Nil

	If Self:oParametro:hasProperty(cNome)
		xValor := Self:oParametro[cNome]
	EndIf

Return xValor

/*/{Protheus.doc} processaAbertura
Abertura do processamento - Etapa CHAR_ETAPAS_ABERTURA
@author Marcelo Neumann
@since 14/03/2023
@version P12
@return lOk, Lógico, Inidica se processou com sucesso a etapa
/*/
Method processaAbertura() Class PCPA152Process
	Local lOk := .F.

	If Self:permiteProsseguir() .And. Self:gravaSetup() .And. Self:abreThreads()
		Self:atualizaEtapa(CHAR_ETAPAS_ABERTURA, STATUS_CONCLUIDO)
		lOk := .T.
	EndIf

Return lOk

/*/{Protheus.doc} processaDisponibilidade
Processa a disponibilidade dos recursos - Etapa CHAR_ETAPAS_CALC_DISP
@author Marcelo Neumann
@since 14/03/2023
@version P12
@return lOk, Lógico, Inidica se processou com sucesso a etapa
/*/
Method processaDisponibilidade() Class PCPA152Process
	Local lOk   := .F.
	Local oDisp := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
		Self:atualizaEtapa(CHAR_ETAPAS_CALC_DISP, STATUS_EXECUCAO)

		If oDisp:processaRecursos(.F.)
			Self:atualizaEtapa(CHAR_ETAPAS_CALC_DISP, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} permiteProsseguir
Indica se deve prosseguir com o processamento ou se precisa ser parado.

@author Marcelo Neumann
@since 14/03/2023
@version P12
@return Lógico, indica se o processamento está ativo ou se foi abortado
/*/
Method permiteProsseguir() Class PCPA152Process

	If Self:processamentoCancelado()
		Return .F.
	EndIf

	If Self:oProcError:possuiErro()
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} getDescricaoStatus
Retorna a descrição de um determinado status

@author Marcelo Neumann
@since 14/02/2023
@version P12
@param  01 cIdStatus, Caracter, Código do status
@param  02 cEtapa   , Caracter, Código da etapa (caso seja para resgatar o status da etapa)
@return cDesStatus  , Caracter, Descrição do status
/*/
Method getDescricaoStatus(cIdStatus, cEtapa) Class PCPA152Process
	Local cDesStatus := ""
	Default cEtapa   := ""

	If cIdStatus == STATUS_PENDENTE
		cDesStatus := STR0019 //"Pendente"

	ElseIf cIdStatus == STATUS_EXECUCAO
		If cEtapa == CHAR_ETAPAS_CALC_DISP
			cDesStatus := STR0021 //"Gerando disponibilidade"
		ElseIf cEtapa == CHAR_ETAPAS_CALC_TEMP
			cDesStatus := STR0132 // "Calculando tempo das operações"
		ElseIf cEtapa == CHAR_ETAPAS_PRIO_ORDEM
			cDesStatus := STR0244 //"Priorizando ordens de produção"
		ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
			cDesStatus := STR0177 // "Distribuindo ordens de produção"
		ElseIf cEtapa == CHAR_ETAPAS_NIVELAMENTO
			cDesStatus := STR0296 // "Nivelando ordens de produção"
		ElseIf cEtapa == CHAR_ETAPAS_DISP_ADICIONAL
			cDesStatus := STR0416 //"Criando disponibilidade adicional"
		ElseIf cEtapa == CHAR_ETAPAS_GRAVACAO
			cDesStatus := STR0143 // "Gravando dados"
		Else
			cDesStatus := STR0020 //"Em execução"
		EndIf

	ElseIf cIdStatus == STATUS_DISTRIBUIDA
		cDesStatus := STR0022 //"Distribuído"

	ElseIf cIdStatus == STATUS_CANCELADO
		cDesStatus := STR0023 //"Cancelado"

	ElseIf cIdStatus == STATUS_DISP_GERADA
		cDesStatus := STR0024 //"Disponibilidade gerada"

	ElseIf cIdStatus == STATUS_TEMPOS_CALCULADO
		cDesStatus := STR0133 // "Tempo das operações calculado"

	ElseIf cIdStatus == STATUS_NIVELADO
		cDesStatus := STR0295 // "Nivelado"

	ElseIf cIdStatus == STATUS_ERRO
		cDesStatus := STR0025 //"Erro"

	ElseIf cIdStatus == STATUS_EFETIVADO
		cDesStatus := STR0385 //"Efetivado"

	ElseIf cIdStatus == STATUS_REPROCESSANDO
		cDesStatus := STR0408 // "Reprocessando"

	EndIf

Return cDesStatus

/*/{Protheus.doc} getDescricaoEtapa
Retorna a descrição da etapa

@author Marcelo Neumann
@since 14/02/2023
@version P12
@param  cEtapa    , Caracter, Código da etapa
@param  cProg     , Caracter, Código da programação (opcional)
@return cDescEtapa, Caracter, Descrição da etapa
/*/
Method getDescricaoEtapa(cEtapa, cProg) Class PCPA152Process
	Local cDescEtapa := cEtapa
	Local cEtapaRep  := ""
	Local nPosEtapa  := 0
	Local nExecucao  := 0
	Local oProcesso  := Nil

	If cEtapa == CHAR_ETAPAS_ABERTURA
		cDescEtapa := STR0015 //"Preparando o processamento..."

	ElseIf cEtapa == CHAR_ETAPAS_CALC_DISP
		cDescEtapa := STR0016 //"Calculando a disponibilidade..."

	ElseIf cEtapa == CHAR_ETAPAS_CALC_TEMP
		cDescEtapa := STR0017 //"Calculando o tempo de operação..."

	ElseIf cEtapa == CHAR_ETAPAS_PRIO_ORDEM
		cDescEtapa := STR0245 //"Priorizando ordens..."

	ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
		cDescEtapa := STR0178 // "Distribuindo ordens..."

	ElseIf cEtapa == CHAR_ETAPAS_DISP_ADICIONAL
		cDescEtapa := STR0416 + "..." //"Criando disponibilidade adicional"...

	ElseIf cEtapa == CHAR_ETAPAS_GRAVACAO
		cDescEtapa := STR0018 //"Gravando resultados..."

	ElseIf cEtapa == CHAR_ETAPAS_NIVELAMENTO
		cDescEtapa := STR0297 // "Nivelando ordens..."

	ElseIf Left(cEtapa, Len(CHAR_ETAPAS_REPROCESSAMENTO)) == CHAR_ETAPAS_REPROCESSAMENTO
		nPosEtapa := At("_", cEtapa)
		cEtapaRep := SubStr(cEtapa, (nPosEtapa+1), (Len(cEtapa)-nPosEtapa))

		If cEtapaRep == CHAR_ETAPAS_DIST_ORD
			cDescEtapa := STR0371 // "distribuição"
		ElseIf cEtapaRep == CHAR_ETAPAS_NIVELAMENTO
			cDescEtapa := STR0372 // "nivelamento"
		EndIf

		cDescEtapa := i18n(STR0370, {cDescEtapa}) // "Reprocessando #1[etapa]#..."

	ElseIf cEtapa == CHAR_ETAPAS_REDUZ_SETUP

		If !Empty(cProg) .And. PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
			nExecucao := oProcesso:getExecucaoReducaoSetup()
		EndIf

		cDescEtapa := i18n(STR0508, {nExecucao}) //"Aplicando redução de Setup... Execução #1[execucao]#"
		oProcesso  := Nil
	EndIf

Return cDescEtapa

/*/{Protheus.doc} cancelaExecucao
Cancela o processamento de uma programação

@author Marcelo Neumann
@since 07/03/2023
@version P12
@param cProg, Caracter, Código da programação a ser cancelada
@return Nil
/*/
Method cancelaExecucao() Class PCPA152Process
	Local lExecutando := .T.
	Local lError      := .F.

	Self:gravaValorGlobal("CANCELADO", .T.)

	lExecutando := Self:retornaValorGlobal("EXECUTANDO", @lError)
	While lExecutando .And. !lError
		Sleep(50)
		lExecutando := Self:retornaValorGlobal("EXECUTANDO", @lError)
	End

Return

/*/{Protheus.doc} processamentoCancelado
Retorna se a programação foi cancelada

@author Marcelo Neumann
@since 07/03/2023
@version P12
@return lCancelado, Lógico, Indica se o processamento foi cancelado
/*/
Method processamentoCancelado() Class PCPA152Process
	Local lCancelado := .F.
	Local lError     := .F.

	If Self:retornaValorGlobal("CANCELADO", @lError) .And. !lError
		lCancelado := .T.
	EndIf

Return lCancelado

/*/{Protheus.doc} processaOperacao
Processa o cálcuo dos tempos das operações
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return lSucesso, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method processaOperacao() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_CALC_TEMP, STATUS_EXECUCAO)

		If oTempoOper:processaTempoOperacao()
			Self:atualizaEtapa(CHAR_ETAPAS_CALC_TEMP, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf

	EndIf

Return lOk

/*/{Protheus.doc} preparaProgramacao
Prepara a programação para continuar o processamento ou reprocessar uma etapa.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param 01 cProg  , Caracter, Código da programação que irá continuar.
@param 02 oStart , Object  , Json com os parâmetros para continuar/reprocessar.
@param 03 lReproc, Logico  , Indica que irá preparar para reprocessamento.
@return Nil
/*/
Method preparaProgramacao(cProg, oStart, lReproc) Class PCPA152Process
	Local cStatus := ""
	Local aParams := oStart["listaParametros"]

	Self:cProg := cProg

	T4X->(DbSetOrder(1))
	If T4X->(DbSeek(xFilial("T4X")+Self:cProg))
		cStatus := T4X->T4X_STATUS
	Else
		Self:oProcError:setError("PCPA152Process():preparaProgramacao()", STR0134, "") // "Programação não encontrada!"
	EndIf

	If (!lReproc .And. (cStatus == STATUS_DISP_GERADA .Or. cStatus == STATUS_DISTRIBUIDA)) .Or.;
	   ( lReproc .And. (cStatus == STATUS_DISTRIBUIDA .Or. cStatus == STATUS_NIVELADO   ))
		If Self:iniciaUIdGlobal(.T.)
			Self:lReproc   := lReproc
			Self:lContinua := !lReproc
			Self:cEtapaIni := cStatus
			Self:carregaParametros(aParams)

			Self:gravaAtributosGlobais()

			Self:abreThreadMaster(.F.)

			Self:criaBackupCancelamento()

			Self:atualizaTabelaProgramacao(oStart)
			Self:atualizaParametros(aParams)

			If lReproc
				Self:oLogs:gravaLog( , {"Reprocessando a programacao " + cProg})
				Self:oLogs:gravaParametros(Self:oParametro)
				Self:preparaEtapasReprocessamento()
			Else
				Self:oLogs:gravaLog( , {"Continuando a programacao " + cProg})
				Self:oLogs:gravaParametros(Self:oParametro)
				Self:reiniciaEtapa(CHAR_ETAPAS_NIVELAMENTO)
				Self:setStatusProgramacao(cStatus)
			EndIf

			Self:reiniciaEtapa(CHAR_ETAPAS_REDUZ_SETUP)
			Self:reiniciaEtapa(CHAR_ETAPAS_GRAVACAO)
			Self:reiniciaEtapa(CHAR_ETAPAS_DISP_ADICIONAL)

			Self:aguardaThreadMasterIniciar()
		EndIf
	Else
		Self:oProcError:setError("PCPA152Process():preparaProgramacao()", STR0135, Iif(lReproc, STR0373, STR0136))  // "Status da programação inválido!" "Somente programações com status distribuida ou nivelada podem ser reprocessadas." "Somente é possivel continuar programações com status disponibilidade gerada ou distribuida."
	EndIf

Return Nil

/*/{Protheus.doc} carregaParametros
Carrega os parametros para continuar o processamento da programação.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param aAdicional, Array, Parâmetros adicionais recebidos para continuar a programação.
@return Nil
/*/
Method carregaParametros(aAdicional) Class PCPA152Process
	Local cParam := ""
	Local nIndex := 0
	Local nTotal := Len(aAdicional)
	Local xValor := Nil

	Self:oParametro := P152GetPar(Self:cProg)

	For nIndex := 1 To nTotal
		cParam := aAdicional[nIndex]["codigo"]
		xValor := aAdicional[nIndex]["valor" ]

		If vldTipoPar(cParam, xValor, .F.)
			Self:oParametro[cParam] := xValor
		EndIf
	Next

Return Nil

/*/{Protheus.doc} atualizaParametros
Grava os parâmetros recebidos para continuar a programação na tabela de parâmetros.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param aParams, Array, Parametros recebidos na continuação da programação.
@return Nil
/*/
Method atualizaParametros(aParams) Class PCPA152Process
	Local cParam := ""
	Local nIndex := 1
	Local nTotal := Len(aParams)
	Local xValor := Nil

	For nIndex := 1 To nTotal
		cParam := aParams[nIndex]["codigo"]
		xValor := Self:trataTipoParametro(Nil, aParams[nIndex]["valor"], .F.)

		T4Y->(DbSetOrder(2))
		If T4Y->(DbSeek(xFilial("T4Y")+Self:cProg+cParam))
			RecLock('T4Y',.F.)
				If "|" + cParam + "|" $ PAR_TIPO_LIST
					T4Y->T4Y_LISTA := xValor
				Else
					T4Y->T4Y_VALOR := xValor
				EndIf
			T4Y->(MsUnlock())
		Else
			Self:criaParametro(cParam, xValor)
		EndIf
	Next

Return Nil

/*/{Protheus.doc} vldTipoPar
Valida os tipo dos parâmetros e faz a conversão do que está salvo na tabela para o tipo correto.
@type  Static Function
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param 01 cNome    , Caracter, Nome do parâmetro que irá validar.
@param 02 xValor   , Any     , Valor do parâmetro que irá validar, retorna por referencia o valor convertido se lConverte == .T.
@param 03 lConverte, Logico  , Indica que deve converter para o tipo correto do parâmetro.
@return lOk, Logico, Retorna se o parâmetro está correto.
/*/
Static Function vldTipoPar(cNome, xValor, lConverte)
	Local lOk := .T.

	cNome := "|" + cNome + "|"

	If cNome $ PAR_TIPO_CHAR
		lOk := ValType(xValor) == "C"
	ElseIf cNome $ PAR_TIPO_NUM
		If lConverte
			xValor := Val(xValor)
		EndIf

		lOk := ValType(xValor) == "N"
	ElseIf cNome $ PAR_TIPO_BOOL
		If lConverte .And. xValor == "true"
			xValor := .T.
		ElseIf lConverte .And. xValor == "false"
			xValor := .F.
		EndIf

		lOk := ValType(xValor) == "L"
	ElseIf cNome $ PAR_TIPO_LIST
		If lConverte
			xValor := StrTokArr(xValor, CHR(10))
		EndIf

		lOk := ValType(xValor) == "A"
	EndIf

Return lOk

/*/{Protheus.doc} abreThreadMaster
Inicia a thread master para o processamento.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@param lStart, Logico, Indica que está iniciando uma nova programação.
@return Nil
/*/
Method abreThreadMaster(lStart) Class PCPA152Process
	Local cRecover := 'P152Error("' + Self:cProg + '", .T.)'

	Self:gravaValorGlobal("THREAD_MASTER", "PENDENTE")

	Self:oProcError:startJob("P152Start", getEnvServer(), .F., cEmpAnt, cFilAnt, Self:cProg, lStart, /*oVar03*/, /*oVar04*/, ;
							/*oVar05*/, /*oVar06*/, /*oVar07*/, /*oVar08*/, /*oVar09*/, /*oVar10*/, /*bRecover*/, cRecover)

Return Nil

/*/{Protheus.doc} P152GetPar
Retorna os parâmetros de uma programação.
@type  Function
@author Lucas Fagundes
@since 23/03/2023
@version P12
@param cProg, Caracter, Código da programaçao que irá buscar os parametros
@return oParams, Object, Json com os parametros da programação
/*/
Function P152GetPar(cProg)
	Local cParam    := ""
	Local lConverte := .T.
	Local oParams   := JsonObject():New()
	Local xValor    := Nil

	T4Y->(DbSetOrder(1))
	If T4Y->(DbSeek(xFilial('T4Y')+cProg))
		While T4Y->(!EoF()) .And. T4Y->T4Y_PROG == cProg
			cParam := RTrim(T4Y->T4Y_PARAM)
			lConverte := .T.

			If "|" + cParam + "|" $ PAR_TIPO_LIST
				If Empty(T4Y->T4Y_LISTA) .And. T4Y->T4Y_LISTA != " "
					xValor    := {}
					lConverte := .F.
				Else
					xValor := T4Y->T4Y_LISTA
				EndIf
			Else
				xValor := RTrim(T4Y->T4Y_VALOR)
			EndIf

			If vldTipoPar(cParam, @xValor, lConverte)
				oParams[cParam] := xValor
			EndIf

			T4Y->(dbSkip())
		End
	EndIf

Return oParams

/*/{Protheus.doc} processamentoFactory
Metodo de fabricação das classes de processamento.

@author Lucas Fagundes
@since 27/03/2023
@version P12
@param 01 cProg     , Caracter, Código da programação que será instanciada a classe de controle.
@param 02 nOpcao    , Numerico, Opção de retorno com base nos defines iniciados em FACTORY_OPC.
@param 03 oReturn   , Object  , Retorna por referencia a instancia da classe.
@param 04 lNoVldErro, Logico  , Indica que não deve realizar a validação de erro/cancelamento se a classe de processamento for instanciada.
@return lSucesso, Logico, Indica se teve sucesso ao instanciar a classe ou não.
/*/
Method processamentoFactory(cProg, nOpcao, oReturn, lNoVldErro) Class PCPA152Process
	Local lSucesso     := .T.
	Default lNoVldErro := .F.

	If Empty(_oProcesso)
		_oProcesso := PCPA152Process():New(cProg)
	EndIf

	lSucesso := _oProcesso:oProcError != Nil .And. (lNoVldErro .Or. !_oProcesso:oProcError:possuiErro())
	If lSucesso
		If nOpcao == FACTORY_OPC_BASE
			oReturn := _oProcesso
		ElseIf nOpcao == FACTORY_OPC_DISP
			If Empty(_oDisp)
				_oDisp := PCPA152Disponibilidade():New(_oProcesso)
			EndIf

			oReturn := _oDisp
		ElseIf nOpcao == FACTORY_OPC_TEMPOPER
			If Empty(_oTempOper)
				_oTempOper := PCPA152TempoOperacao():New(cProg)
			EndIf

			oReturn := _oTempOper
		ElseIf nOpcao == FACTORY_OPC_NIVELA
			If Empty(_oNivela)
				_oNivela := PCPA152Nivelamento():New(cProg)
			EndIf

			oReturn := _oNivela
		ElseIf nOpcao == FACTORY_OPC_GRAVA
			If Empty(_oGrava)
				_oGrava := PCPA152Gravacao():New(cProg)
			EndIf

			oReturn := _oGrava
		ElseIf nOpcao == FACTORY_OPC_FERRAMENTA
			If Empty(_oFerramen)
				_oFerramen := PCPA152Ferramenta():new(cProg)
			EndIf

			oReturn := _oFerramen
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} executaProgramacao
Inicia ou continua uma programação
@author Lucas Fagundes
@since 27/03/2023
@version P12
@param 01 cProg  , Caracter, Código da programação que irá continuar.
@param 02 oBody  , Object  , Parâmetros para iniciar/continuar a programação.
@param 03 lReproc, Logico  , Indica que está reprocessando a programação.
@return oSelf, Object, Nova instancia da classe de processamento.
/*/
Method executaProgramacao(cProg, oBody, lReproc) Class PCPA152Process
	Local oSelf := Nil
	Local cBody := oBody:toJson()

	PCPA152Process():processamentoFactory(Nil, FACTORY_OPC_BASE, @oSelf, .T.)

	If Empty(cProg)
		oSelf:iniciaProgramacao(oBody)
	Else
		oSelf:preparaProgramacao(cProg, oBody, lReproc)
	EndIf

	If oSelf:oProcError:possuiErro()
		P152Error(oSelf:retornaProgramacao(), .F.)
	Else
		oSelf:gravaValorGlobal("JSON_INI", cBody)
		oSelf:gravaValorGlobal("THREAD_MASTER", "PROCESSAR")
	EndIf

Return oSelf

/*/{Protheus.doc} P152ClnStc
Limpa o cache das classes de processamento nas variaveis estaticas.
@type  Function
@author Lucas Fagundes
@since 30/03/2023
@version P12
@return Nil
/*/
Function P152ClnStc()

	If !Empty(_oDisp)
		_oDisp:destroy()
		_oDisp := Nil
	EndIf

	If !Empty(_oProcesso)
		_oProcesso:destroy()
		_oProcesso := Nil
	EndIf

	If !Empty(_oTempOper)
		_oTempOper:destroy()
		_oTempOper := Nil
	EndIf

	If !Empty(_oNivela)
		_oNivela:destroy()
		_oNivela := Nil
	EndIf

	If !Empty(_oGrava)
		_oGrava:destroy()
		_oGrava := Nil
	EndIf

	If !Empty(_oFerramen)
		_oFerramen:destroy()
		_oFerramen := Nil
	EndIf

Return Nil

/*/{Protheus.doc} priorizaOrdens
Faz a priorização das ordens de produção
@author Marcelo Neumann
@since 28/06/2023
@version P12
@return lOk, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method priorizaOrdens() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_PRIO_ORDEM, STATUS_EXECUCAO)

		If oTempoOper:calculaPrioridade()
			Self:atualizaEtapa(CHAR_ETAPAS_PRIO_ORDEM, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} processaDistribuicao
Inicia a distribuição das operações.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@return lOk, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method processaDistribuicao() Class PCPA152Process
	Local lOk        := .F.
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		Self:atualizaEtapa(CHAR_ETAPAS_DIST_ORD, STATUS_EXECUCAO)

		If oTempoOper:processaDistribuicao()
			Self:atualizaEtapa(CHAR_ETAPAS_DIST_ORD, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} deletaChaveListaGlobal
Elimina uma chave de uma lista da seção global.
@author Marcelo Neumann
@since 12/10/2023
@version P12
@param 01 cIdLista, Caracter, Código identificador da lista.
@param 02 cChave  , Caracter, Chave que terá seu valor limpo.
@return Logico    , Indica se conseguiu limpar a chave da lista com sucesso.
/*/
Method deletaChaveListaGlobal(cIdLista, cChave) Class PCPA152Process
	Local cUUID := Self:cUIDGlb + cIdLista

Return VarDelA(cUUID, cChave)

/*/{Protheus.doc} limpaListaGlobal
Realiza a limpeza das chaves em uma lista da seção global.
@author Lucas Fagundes
@since 27/04/2023
@version P12
@param cIdLista, Caracter, Código identificador da lista.
@return lOk, Logico, Indica se conseguiu limpar a lista com sucesso.
/*/
Method limpaListaGlobal(cIdLista) Class PCPA152Process

Return VarCleanA(Self:cUIDGlb+cIdLista)

/*/{Protheus.doc} gravaSetup
Salva o setup com os parâmetros de execução da programação.
@author Lucas Fagundes
@since 07/06/2023
@version P12
@return lSucesso, Logico, Indica que gravou com sucesso o setup.
/*/
Method gravaSetup() Class PCPA152Process
	Local cCodSetup  := Self:oParametro["setup"]
	Local cDescSetup := Self:oParametro["descricaoSetup"]
	Local cErro      := ""
	Local cJsIni     := Self:retornaValorGlobal("JSON_INI")
	Local lExistStp  := .F.
	Local lSucesso   := .T.
	Local nTamSetup  := GetSX3Cache("MS_ID", "X3_TAMANHO")
	Local oJson      := JsonObject():New()
	Local oParams    := JsonObject():New()

	cErro := oJson:fromJson(cJsIni)
	If !Empty(cCodSetup) .And. Empty(cErro)
		oParams["listaParametros"] := oJson["listaParametros"]

		nPos := aScan(oParams["listaParametros"], {|x| x["codigo"] == "dataRealFim" })
		aDel(oParams["listaParametros"], nPos)
		aSize(oParams["listaParametros"], Len(oParams["listaParametros"]) - 1)

		nPos := aScan(oParams["listaParametros"], {|x| x["codigo"] == "dataFimDisponibilidade" })
		aDel(oParams["listaParametros"], nPos)
		aSize(oParams["listaParametros"], Len(oParams["listaParametros"]) - 1)

		aAdd(oParams["listaParametros"], JsonObject():New())
		aTail(oParams["listaParametros"])["codigo"] := "descricao"
		aTail(oParams["listaParametros"])["valor" ] := oJson["descricao"]

		SMS->(DbSetOrder(1))
		lExistStp := SMS->(DbSeek(xFilial("SMS")+PadR(cCodSetup, nTamSetup)))

		RecLock('SMS',!lExistStp)
			SMS->MS_FILIAL := xFilial("SMS")
			SMS->MS_ID     := cCodSetup
			SMS->MS_DESC   := cDescSetup
			SMS->MS_PARAM  := oParams:toJson()
		SMS->(MsUnlock())

	ElseIf !Empty(cErro)
		lSucesso := .F.
		Self:gravaErro(CHAR_ETAPAS_ABERTURA, STR0203, cErro) // "Ocorreu um erro ao gravar o setup da programação."
	EndIf

	Self:limpaValorGlobal("JSON_INI")

	FwFreeObj(oJson)
	FwFreeObj(oParams)
Return lSucesso

/*/{Protheus.doc} limpaValorGlobal
Limpa um valor das variaveis globais deletando o valor da chave.
@author Lucas Fagundes
@since 07/06/2023
@version P12
@param cChave, Caracter, Chave que terá seu valor limpo.
@return lSucesso, Logico, Indica se teve sucesso na limpeza da chave.
/*/
Method limpaValorGlobal(cChave) Class PCPA152Process

Return VarDelX(::cUIDGlb, cChave)

/*/{Protheus.doc} processaNivelamento
Inicia o nivelamento das ordens.
@author Lucas Fagundes
@since 10/08/2023
@version P12
@return lOk, Logico, Indica que teve sucesso na execução do nivelamento.
/*/
Method processaNivelamento() Class PCPA152Process
	Local lOk    := .F.
	Local oNivela := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_NIVELA, @oNivela)
		Self:atualizaEtapa(CHAR_ETAPAS_NIVELAMENTO, STATUS_EXECUCAO)

		If oNivela:executaNivelamento()
			Self:atualizaEtapa(CHAR_ETAPAS_NIVELAMENTO, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} processaReducaoSetup
Inicia o processamento da redução de Setup

@author lucas.franca
@since 17/05/2024
@version P12
@return lOk, Logico, Indica que teve sucesso na execução do nivelamento.
/*/
Method processaReducaoSetup() Class PCPA152Process
	Local lOk     := .F.
	Local oNivela := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_NIVELA, @oNivela)
		Self:atualizaEtapa(CHAR_ETAPAS_REDUZ_SETUP, STATUS_EXECUCAO)

		If oNivela:executaReducaoSetup()
			Self:atualizaEtapa(CHAR_ETAPAS_REDUZ_SETUP, STATUS_CONCLUIDO)
			lOk := .T.
		EndIf
	EndIf

Return lOk

/*/{Protheus.doc} setStatusProgramacao
Seta o status da programação em uma flag global.
@author Lucas Fagundes
@since 16/08/2023
@version P12
@param cStatus, Caracter, Status da programação.
@return Nil
/*/
Method setStatusProgramacao(cStatus) Class PCPA152Process
	Self:gravaValorGlobal("STATUS_PROGRAMACAO", cStatus, .T.)
Return Nil

/*/{Protheus.doc} getStatusProgramacao
Retorna o status da programação.
@author Lucas Fagundes
@since 16/08/2023
@version P12
@return cStatus, Caracter, Status da programação.
/*/
Method getStatusProgramacao() Class PCPA152Process
	Local cRetGlb := ""
	Local cStatus := STATUS_ERRO
	Local lError  := .F.

	cRetGlb := Self:retornaValorGlobal("STATUS_PROGRAMACAO", @lError, .T.)
	If !lError
		cStatus := cRetGlb
	EndIf

Return cStatus

/*/{Protheus.doc} getStatusInicioProgramacao
Retorna se a programação esta sendo continuada ou reprocessada e a etapa que foi iniciada.
@author Lucas Fagundes
@since 17/08/2023
@version P12
@return oReturn, Object, Json com as informações de inicio da programação.
/*/
Method getStatusInicioProgramacao() Class PCPA152Process
	Local cJson      := ""
	Local oBkpCancel := JsonObject():New()
	Local oReturn    := JsonObject():New()

	cJson := Self:retornaValorGlobal("BACKUP_CANCELAMENTO")
	oBkpCancel:fromJson(cJson)

	oReturn["continuando"  ] := Self:lContinua
	oReturn["reprocessando"] := Self:lReproc
	oReturn["etapaIniciada"] := Self:cEtapaIni
	oReturn["backupCancel" ] := oBkpCancel

	oBkpCancel := Nil
Return oReturn

/*/{Protheus.doc} P152DelCln
Chama a limpeza das tabelas em uma nova thread.
@type  Function
@author Lucas Fagundes
@since 26/10/2023
@version P12
@param 01 cProg  , Caracter, Código da programação.
@param 02 cTabela, Caracter, Tabela que irá executar a limpeza.
@return Nil
/*/
Function P152DelCln(cProg, cTabela)
	Local oAux := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_GRAVA, @oAux)
		oAux:executaLimpeza(cTabela)
	EndIf

	oAux := Nil
Return Nil

/*/{Protheus.doc} aguardaFimPreparo
Aguarda o fim do preparo para realizar as alocações.
@author Lucas Fagundes
@since 26/10/2023
@version P12
@return lSucesso, Logico, Retorna se o preparo foi finalizada com sucesso.
/*/
Method aguardaFimPreparo() Class PCPA152Process
	Local cStatsOper := Self:retornaValorGlobal("CARGA_OPERACOES")
	Local cStatsDisp := Self:retornaValorGlobal("CARGA_DISPONIBILIDADE")

	While Self:permiteProsseguir() .And. (cStatsOper != "END" .Or. cStatsDisp != "END")

		Sleep(50)

		cStatsOper := Self:retornaValorGlobal("CARGA_OPERACOES")
		cStatsDisp := Self:retornaValorGlobal("CARGA_DISPONIBILIDADE")
	End

Return Self:permiteProsseguir()

/*/{Protheus.doc} preparaParaAlocacao
Prepara para realizar a alocação das ordens, subindo as operações para memória e limpando as tabelas.
@author Lucas Fagundes
@since 31/10/2023
@version P12
@return lSucesso, Logico, Retorna se o preparo foi finalizada com sucesso.
/*/
Method preparaParaAlocacao() Class PCPA152Process

	Self:gravaValorGlobal("CARGA_OPERACOES", "INI")
	Self:gravaValorGlobal("CARGA_DISPONIBILIDADE", "INI")

	Self:delegar("P152DelCar", Self:cProg, "OPERACOES")
	Self:delegar("P152DelCar", Self:cProg, "DISPONIBILIDADE")

	lSucesso := Self:aguardaFimPreparo()

Return lSucesso

/*/{Protheus.doc} P152DelCar
Executa a carga das operações/disponibilidade em uma nova thread.
@type  Function
@author Lucas Fagundes
@since 31/10/2023
@version P12
@param 01 cProg , Caracter, Código da programação.
@param 02 cCarga, Caracter, Indica qual carga iniciar.
@return Nil
/*/
Function P152DelCar(cProg, cCarga)
	Local oDisp      := Nil
	Local oProcesso  := Nil
	Local oTempoOper := Nil
	Local cFlag      := "CARGA_" + cCarga

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
		oProcesso:gravaValorGlobal(cFlag, "PROC")

		If cCarga == "OPERACOES"

			PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
			oTempoOper:carregaOperacoes()

		ElseIf cCarga == "DISPONIBILIDADE"
			oDisp := PCPA152Disponibilidade():New(oProcesso)

			oDisp:carregaDisponibilidade()

			oDisp:destroy()
			oDisp := Nil
		EndIf

		oProcesso:gravaValorGlobal(cFlag, "END")
	EndIf

Return Nil

/*/{Protheus.doc} criaNovaEtapa
Cria uma etapa na tabela T4Z
@author Marcelo Neumann
@since 31/10/2023
@version P12
@param 01 cEtapa , Caracter, Etapa que será inserida.
@param 02 cStatus, Caracter, Status da etapa a ser inserida.
@return lSucesso , Logico  , Indica se a etapa foi inserida com sucesso.
/*/
Method criaNovaEtapa(cEtapa, cStatus) Class PCPA152Process
	Local cAlias   := GetNextAlias()
	Local cFilT4Z  := xFilial("T4Z")
	Local cProg    := Self:cProg
	Local lSucesso := .T.
	Local nSeq     := 0

	BeginSql Alias cAlias
	  SELECT Max(T4Z_SEQ) MAXSEQ
	    FROM %Table:T4Z%
	   WHERE T4Z_FILIAL = %Exp:cFilT4Z%
	     AND T4Z_PROG   = %Exp:cProg%
	     AND %NotDel%
	EndSql
	nSeq := (cAlias)->MAXSEQ
	(cAlias)->(dbCloseArea())

	If nSeq == 0
		Self:oProcError:setError("PCPA152Process():criaNovaEtapa()", STR0374, "") // "Não foi possivel encontrar a sequência da tabela T4Z."
		lSucesso := .F.
	EndIf

	If lSucesso
		nSeq++

		RecLock('T4Z',.T.)
			T4Z_FILIAL := cFilT4Z
			T4Z_PROG   := cProg
			T4Z_SEQ    := nSeq
			T4Z_ETAPA  := cEtapa
			T4Z_STATUS := cStatus
			T4Z_PERCT  := 0
			T4Z_MSG    := ""
			T4Z_MSGDET := ""
			If cStatus == STATUS_EXECUCAO
				T4Z_DTINI  := Date()
				T4Z_HRINI  := Time()
			EndIf
		T4Z->(MsUnlock())

		If cEtapa == CHAR_ETAPAS_EFETIVACAO
			Self:gravaValorGlobal("SEQ_ETAPA_EETIVA", nSeq)

		ElseIf Left(cEtapa, Len(CHAR_ETAPAS_REPROCESSAMENTO)) == CHAR_ETAPAS_REPROCESSAMENTO
			Self:gravaValorGlobal("RECNO_ETAPA_REPROC", T4Z->(Recno()))

		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} getMsgErro
Retorna por referência as mensagens de erro e erro detalhado que foram gravadas na classe PCPMultiThreadError

@author Marcelo Neumann
@since 30/11/2023
@version P12
@param 01 cErroMsg, Caracter, Retorna por referência a mensagem de erro
@param 02 cErroDet, Caracter, Retorna por referência a mensagem de erro detalhada
@return Nil
/*/
Method getMsgErro(cErroMsg, cErroDet) Class PCPA152Process
	Local aError := Self:oProcError:getaError()

	If Self:processamentoCancelado()
		cErroMsg := aError[1][2]
		cErroDet := aError[1][3]
	Else
		cErroMsg := STR0006 // "Ocorreu um erro durante a execução, consulte o campo de detalhes para mais informações."
		cErroDet := aError[1][2] + aError[1][3] + aError[1][4]
	EndIf

	FwFreeArray(aError)

Return Nil

/*/{Protheus.doc} preparaEtapasReprocessamento
Ajusta as etapas na tabela T4Z para o reprocessamento
@author Lucas Fagundes
@since 08/11/2023
@version P12
@return Nil
/*/
Method preparaEtapasReprocessamento() Class PCPA152Process
	Local cEtapaRep := ""

	If Self:cEtapaIni == STATUS_DISTRIBUIDA
		cEtapaRep := CHAR_ETAPAS_DIST_ORD
	ElseIf Self:cEtapaIni == STATUS_NIVELADO
		cEtapaRep := CHAR_ETAPAS_NIVELAMENTO
	EndIf

	If Self:criaNovaEtapa(CHAR_ETAPAS_REPROCESSAMENTO + cEtapaRep, STATUS_EXECUCAO)

		Self:gravaValorGlobal("ETAPA_REPROC", cEtapaRep)
		Self:atualizaStatusProgramacao(STATUS_REPROCESSANDO)

	EndIf

Return Nil

/*/{Protheus.doc} atualizaPendenciaDeReprocessamento
Atualiza o campo T4X_REPROC indicando pendencia de reprocessamento da programação.
@author Lucas Fagundes
@since 08/11/2023
@version P12
@param 01 cProg, Caracter, Código da programação que irá atualizar.
@param 02 nPend, Numerico, Valor que será atribuido ao campo T4X_REPROC.
@return Nil
/*/
Method atualizaPendenciaDeReprocessamento(cProg, nPend) Class PCPA152Process

	T4X->(dbSetOrder(1))
	If T4X->(dbSeek(xFilial("T4X")+cProg))
		If T4X->T4X_STATUS != STATUS_EFETIVADO
			RecLock("T4X", .F.)
				T4X_REPROC := nPend
			T4X->(MsUnLock())
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} criaParametro
Salva um novo parâmetro na tabela T4Y.
@author Lucas Fagundes
@since 15/01/2024
@version P12
@param 01 cParam, Caracter, Nome do parâmetro que será salvo.
@param 02 cValor, Caracter, Valor do parâmetro que será salvo.
@return Nil
/*/
Method criaParametro(cParam, cValor) Class PCPA152Process
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nSeqT4Y := 0

	cQuery := " SELECT MAX(T4Y_SEQ) seqT4Y "
	cQuery += "   FROM " + RetSqlName("T4Y")
	cQuery += "  WHERE T4Y_FILIAL = '" + xFilial("T4Y") + "' "
	cQuery += "    AND T4Y_PROG   = '" + Self:cProg     + "' "
	cQuery += "    AND T4Y_SEQ   != 99  "
	cQuery += "    AND D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If (cAlias)->(!EoF())
		nSeqT4Y := ((cAlias)->seqT4Y + 1)
	EndIf
	(cAlias)->(dbCloseArea())

	RecLock("T4Y", .T.)
		T4Y->T4Y_FILIAL := xFilial("T4Y")
		T4Y->T4Y_PROG   := Self:cProg
		T4Y->T4Y_SEQ    := nSeqT4Y
		T4Y->T4Y_PARAM  := cParam
		T4Y->T4Y_VALOR  := cValor
	T4Y->(MsUnLock())

Return Nil

/*/{Protheus.doc} posAlocacoes
Método executado após as alocações (distribuição ou nivelamento) para geração de parâmetro e disponibilidade atrelados as alocações.
@author Lucas Fagundes
@since 15/01/2024
@version P12
@return Nil
/*/
Method posAlocacoes() Class PCPA152Process
	Local dDtRealFim := Nil
	Local lError     := .F.
	Local oParam     := Nil

	Self:atualizaEtapa(CHAR_ETAPAS_DISP_ADICIONAL, STATUS_EXECUCAO)
	dDtRealFim := Self:retornaValorGlobal("ULTIMA_DATA_ALOCADA", @lError)
	If !lError
		oParam := JsonObject():New()
		oParam["codigo"] := "dataRealFim"
		oParam["valor" ] := PCPConvDat(dDtRealFim, 2)

		Self:atualizaParametros({oParam})

		FreeObj(oParam)
	EndIf

	Self:geraDisponibilidadeAdicional()

	Self:atualizaEtapa(CHAR_ETAPAS_DISP_ADICIONAL, STATUS_CONCLUIDO)

Return Nil

/*/{Protheus.doc} reiniciaEtapa
Reinicializa uma etapa na tabela T4Z

@author lucas.franca
@since 13/02/2024
@version P12
@param cEtapa, Caracter, Código da etapa para reiniciar
@return lAchou, Caracter, Retorna se encontrou e conseguiu atualizar a etapa
/*/
Method reiniciaEtapa(cEtapa) Class PCPA152Process
	Local lAchou := Self:posicionaT4Z(cEtapa)

	If lAchou
		RecLock("T4Z", .F.)
			T4Z->T4Z_STATUS := STATUS_PENDENTE
			T4Z->T4Z_PERCT  := 0
			T4Z->T4Z_DTINI  := CToD("")
			T4Z->T4Z_DTFIM  := CToD("")
			T4Z->T4Z_HRINI  := ""
			T4Z->T4Z_HRFIM  := ""
		T4Z->(MsUnLock())
	EndIf

Return lAchou

/*/{Protheus.doc} abreTempTableOPs
Abre a tabela temporária para armazenar as ordens de produção que serão processadas.
@author Lucas Fagundes
@since 07/03/2024
@version P12
@return Nil
/*/
Method abreTempTableOPs() Class PCPA152Process
	Local aCampos := {}
	Local cAlias  := GetNextAlias()

	aCampos := Self:getFieldsTempTable()

	Self:oTempTable := totvs.framework.database.temporary.SharedTable():New(cAlias, aCampos)

	Self:oTempTable:addIndex("01", {"MF_FILIAL", "MF_PROG", "MF_OP", "MF_OPER"})

	Self:oTempTable:create()

	Self:gravaValorGlobal("TEMP_TABLE_OP", Self:oTempTable:getTableNameForQuery())

Return Nil

/*/{Protheus.doc} possuiTabelaTemporaria
Retorna se a tabela temporaria das OPs esta criada.
@author Lucas Fagundes
@since 07/03/2024
@version P12
@return lRet, Lógico, Indica se a tabela temporaria está criada.
/*/
Method possuiTabelaTemporaria() Class PCPA152Process
	Local lRet := .F.

	Self:retornaValorGlobal("TEMP_TABLE_OP", @lRet)

Return !lRet

/*/{Protheus.doc} getNomeTempTable
Retorna o nome da tabela temporaria de OPs no banco de dados.
@author Lucas Fagundes
@since 07/03/2024
@version P12
@return cNome, Lógico, Nome da tabela temporária no banco de dados.
/*/
Method getNomeTempTable() Class PCPA152Process

Return Self:retornaValorGlobal("TEMP_TABLE_OP")

/*/{Protheus.doc} getFieldsTempTable
Retorna os campos da tabela temporaria.
@author Lucas Fagundes
@since 07/10/2024
@version P12
@return aCampos, Array, Array com a definição dos campos da tabela temporaria.
/*/
Method getFieldsTempTable() Class PCPA152Process
	Local aCampos := {}

	aAdd(aCampos, {"MF_FILIAL" , "C", GetSX3Cache("MF_FILIAL" , "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_PROG"   , "C", GetSX3Cache("MF_PROG"   , "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_OP"     , "C", GetSX3Cache("MF_OP"     , "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_OPER"   , "C", GetSX3Cache("MF_OPER"   , "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_ROTEIRO", "C", GetSX3Cache("MF_ROTEIRO", "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_RECURSO", "C", GetSX3Cache("MF_RECURSO", "X3_TAMANHO"), 0})
	aAdd(aCampos, {"MF_CTRAB"  , "C", GetSX3Cache("MF_CTRAB"  , "X3_TAMANHO"), 0})
	aAdd(aCampos, {"PRODUTO"   , "C", GetSX3Cache("B1_COD"    , "X3_TAMANHO"), 0})

Return aCampos

/*/{Protheus.doc} atualizaTabelaProgramacao
Realiza a atualização da tabela T4X quando continua/reprocessa uma programação.
@author Lucas Fagundes
@since 20/03/2024
@version P12
@param oStart, Object, Json com os parâmetros continuação/reprocessamento.
@return Nil
/*/
Method atualizaTabelaProgramacao(oStart) Class PCPA152Process

	T4X->(DbSetOrder(1))
	If T4X->(DbSeek(xFilial("T4X")+Self:cProg))
		RecLock("T4X", .F.)
			T4X->T4X_DESCRI := oStart["descricao"]
		T4X->(MsUnLock())
	EndIf

	Self:atualizaPendenciaDeReprocessamento(Self:cProg, REPROCESSAMENTO_NAO_PENDENTE)

Return Nil

/*/{Protheus.doc} existeCampo
Verifica se existe um campo.
@author Lucas Fagundes
@since 21/03/2024
@version P12
@param cCampo, Caracter, Campo que irá verificar se existe.
@return lExiste, Lógico, Retorna se existe o campo.
/*/
Method existeCampo(cCampo) Class PCPA152Process
	Local lExiste := .F.

	If _oCampos == Nil
		_oCampos := JsonObject():New()
	EndIf

	If !_oCampos:hasProperty(cCampo)
		_oCampos[cCampo] := GetSx3Cache(cCampo, "X3_TAMANHO") > 0
	EndIf

	lExiste := _oCampos[cCampo]

Return lExiste

/*/{Protheus.doc} getExecucaoReducaoSetup
Retorna o número de execução da redução de setup

@author lucas.franca
@since 13/06/2024
@version P12
@return nExecucao, Numeric, Número da execução da redução de setup
/*/
Method getExecucaoReducaoSetup() Class PCPA152Process
	Local nExecucao := Self:retornaValorGlobal("EXECUCAO_REDUZ_SETUP")

Return Iif(Empty(nExecucao), 1, nExecucao)

/*/{Protheus.doc} setExecucaoReducaoSetup
Grava o número de execução da redução de setup

@author lucas.franca
@since 13/06/2024
@version P12
@param 01 nExecucao, Numeric, Número da execução da redução de setup
@return Nil
/*/
Method setExecucaoReducaoSetup(nExecucao) Class PCPA152Process
	Self:gravaValorGlobal("EXECUCAO_REDUZ_SETUP", nExecucao)
Return

/*/{Protheus.doc} getPrefixo
Retorna o prefixo para o log, com data, hora, thread e etapa formatados

@type Static Function
@author marcelo.neumann
@since 05/03/2024
@version P12
@param cEtapa   , Caracter, Etapa que gerou o log
@return Caracter, Retorna o prefixo do log
/*/
Static Function getPrefixo(cEtapa, cOrdem, cOperacao, cRecurso, cChave)
	Default cEtapa    := ""
	Default cOperacao := ""
	Default cOrdem    := ""
	Default cRecurso  := ""
	Default cChave    := ""

Return QUEBRA_LINHA + DToC(Date()) + " " + Time() + "; [Thread " + cValToChar(ThreadID()) + "]; " + cEtapa + "; " + cOrdem + "; " + cOperacao + "; " + cRecurso + "; " + cChave + "; "

//---------------------------------------------------------------------
/*/{Protheus.doc} PCPSmartView
@type		 static function
@description Chama callSmartView para selecionar as opções presentes no objeto de negocio
			 (visao, tabela dinâmica ou relatorio)

@param	oWebChannel - Clase WebChannel
@param	cContent - Tipo do objeto de negocio em tlpp

@retur	lSuccess -	Retorna se foi possivel executar o smartview
@autho	Breno Soares
@since	24/04/2024
@versi	1.0
/*/
//---------------------------------------------------------------------
Static function PCPSmartView(oWebChannel, cContent)
	Local cReport    := ""
	Local cTipo      := ""
	Local lSuccess   := .T.
	Local oSmartView := Nil

	If cContent == "relatorio_recurso"
		cReport := "manufacturing.sv.pcp.crp.alocacaorecurso.rep"
		cTipo   := "report"

	ElseIf cContent == "visao_dados_recurso"
		cReport := "manufacturing.sv.pcp.crp.alocacaorecurso.dg"
		cTipo   := "data-grid"

	ElseIf cContent == "relatorio_centro_trabalho"
		cReport := "manufacturing.sv.pcp.crp.alocacaocentrodetrabalho.rep"
		cTipo   := "report"

	ElseIf cContent == "visao_dados_centro_trabalho"
		cReport := "manufacturing.sv.pcp.crp.alocacaocentrodetrabalho.dg"
		cTipo   := "data-grid"

	ElseIf cContent == "relatorio_listagem_ordens"
		cReport := "manufacturing.pcp.crp.listagemordensalteradas.rep"
		cTipo   := "report"

	ElseIf cContent == "visao_dados_listagem_ordens"
		cReport := "manufacturing.pcp.crp.listagemordensalteradas.dg"
		cTipo   := "data-grid"

	EndIf

	oSmartView := totvs.framework.smartview.callSmartView():new( cReport, cTipo )
	lSuccess := oSmartView:executeSmartView()

	If !lSuccess
		LogMsg("PCPA152", 1, 6, 1, "", "", oSmartView:getError())
	EndIf

	oSmartView:destroy()
	oWebChannel:AdvplToJs("retPCPSmartView", "")
return

/*/{Protheus.doc} criaBackupCancelamento
Salva informações de parâmetros e status para restaurar em caso de cancelamento.
@author Lucas Fagundes
@since 07/08/2024
@version P12
@return Nil
/*/
Method criaBackupCancelamento() Class PCPA152Process
	Local oJsAux := JsonObject():New()

	oJsAux["reprocessamento"] := T4X->T4X_REPROC
	oJsAux["parametros"     ] := JsonObject():New()

	T4Y->(dbSetOrder(1))
	T4Y->(dbSeek(xFilial("T4Y")+Self:cProg))

	While (T4Y->T4Y_FILIAL + T4Y->T4Y_PROG) == (xFilial("T4Y") + Self:cProg)

		oJsAux["parametros"][T4Y->T4Y_PARAM] := JsonObject():New()
		oJsAux["parametros"][T4Y->T4Y_PARAM]["valor"] := T4Y->T4Y_VALOR
		oJsAux["parametros"][T4Y->T4Y_PARAM]["lista"] := T4Y->T4Y_LISTA

		T4Y->(dbSkip())
	End

	Self:gravaValorGlobal("BACKUP_CANCELAMENTO", oJsAux:toJson())

	FreeObj(oJsAux)
Return Nil

/*/{Protheus.doc} efetivaCancelamento
Efetiva o cancelamento da programação. Voltando para o status inicial ou de cancelado.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@return Nil
/*/
Method efetivaCancelamento() Class PCPA152Process
	Local aEtapas    := {}
	Local aParams    := {}
	Local cEtapa     := ""
	Local cParam     := ""
	Local cStatEtps  := ""
	Local cStatProg  := STATUS_CANCELADO
	Local nIndex     := 0
	Local nTotal     := 0
	Local oBkpCancel := Nil
	Local oInfo      := Nil
	Local oInicio    := Self:getStatusInicioProgramacao()
	Local oParams    := Nil

	If oInicio["continuando"] .Or. oInicio["reprocessando"]
		cStatProg  := oInicio["etapaIniciada"]
		oBkpCancel := oInicio["backupCancel" ]
		oParams    := oBkpCancel["parametros"]
		aParams    := oParams:getNames()
		nTotal     := Len(aParams)

		Self:atualizaPendenciaDeReprocessamento(Self:cProg, oBkpCancel["reprocessamento"])

		T4Y->(dbSetOrder(2))
		For nIndex := 1 To nTotal
			cParam := aParams[nIndex]

			T4Y->(dbSeek(xFilial("T4Y")+Self:cProg+cParam))

			If T4Y->T4Y_VALOR != oParams[cParam]["valor"] .Or.;
			   T4Y->T4Y_LISTA != oParams[cParam]["lista"]

				RecLock("T4Y")
					T4Y->T4Y_VALOR := oParams[cParam]["valor"]
					T4Y->T4Y_LISTA := oParams[cParam]["lista"]
				T4Y->(MsUnLock())
			EndIf
		Next

		If oInicio["reprocessando"]
			cEtapa := Self:retornaValorGlobal("ETAPA_REPROC")

			Self:atualizaEtapa(cEtapa, STATUS_CANCELADO)
		EndIf

		oBkpCancel := Nil
		oParams    := Nil
		aSize(aParams, 0)
	EndIf

	Self:atualizaStatusProgramacao(cStatProg)

	cStatEtps := Iif(cStatProg == STATUS_CANCELADO, STATUS_CANCELADO, STATUS_CONCLUIDO)

	oInfo := P152GetSta(Self:cProg, .F.)
	If oInfo != Nil
		aEtapas := oInfo["etapas"]
		nTotal  := Len(aEtapas)

		For nIndex := 1 To nTotal
			cEtapa := aEtapas[nIndex]["etapa"]

			If aEtapas[nIndex]["idStatus"] != STATUS_CONCLUIDO
				Self:atualizaEtapa(cEtapa, cStatEtps)
			EndIf
		Next

		oInfo := Nil
	EndIf

	oInicio := Nil
Return Nil

/*/{Protheus.doc} processaGravacao
Inicia a gravação dos dados.
@author Lucas Fagundes
@since 07/08/2024
@version P12
@return lSucesso, Logico, Indica que concluiu com sucesso a gravação.
/*/
Method processaGravacao() Class PCPA152Process
	Local lSucesso := .F.
	Local oGrava   := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_GRAVA, @oGrava)
		Self:atualizaEtapa(CHAR_ETAPAS_GRAVACAO, STATUS_EXECUCAO)

		If oGrava:executaGravacao()
			Self:atualizaEtapa(CHAR_ETAPAS_GRAVACAO, STATUS_CONCLUIDO)
			lSucesso := .T.
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} PCPA152Gravacao
Classe responsavel por realizar a gravação dos dados.
@author Lucas Fagundes
@since 07/08/2024
@version P12
/*/
Class PCPA152Gravacao From PCPA152Process

	Private Data lFerram as Logical
	Private Data oTemps  as Object

	Public Method new(cProg) Constructor
	Public Method destroy()
	Public Method executaGravacao()
	Public Method executaLimpeza(cTabela)
	Private Method aguardaFimGravacao()
	Private Method aguardaLimpezaTabelas()
	Private Method calculaTotalGravacao()
	Private Method carregaTempsGravacao()
	Private Method criaTempsGravacao()
	Private Method desfazGravacao()
	Private Method finalizaTempsGravacao()
	Private Method getCamposTempToQuery(cAlias)
	Private Method getIndicesAlias(cAlias)
	Private Method iniciaGravacoes()
	Private Method limpaTabelasParaGravacao()
EndClass

/*/{Protheus.doc} new
Método construtor da classe.
@author Lucas Fagundes
@since 07/08/2024
@version P12
@param cProg, Caracter, Código da programação.
@return Self
/*/
Method new(cProg) Class PCPA152Gravacao

	_Super:new(cProg)

	Self:oTemps  := JsonObject():New()
	Self:lFerram := _Super:retornaParametro("utilizaFerramentas") .And. GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe.
@author Lucas Fagundes
@since 07/08/2024
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Gravacao

	_Super:destroy()

	Self:oTemps := Nil

Return Nil

/*/{Protheus.doc} executaGravacao
Inicia a gravação dos dados.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return lOk, Logico, Indica que o processamento encerrou com sucesso.
/*/
Method executaGravacao() Class PCPA152Gravacao
	Local lOk     := .T.
	Local lTemps  := .F.
	Local oInicio := Nil

	oInicio := _Super:getStatusInicioProgramacao()
	lTemps  := oInicio["continuando"] .Or. oInicio["reprocessando"]

	If lTemps
		Self:criaTempsGravacao()

		lOk := Self:carregaTempsGravacao()

		If lOk
			lOk := Self:limpaTabelasParaGravacao()
		EndIf
	EndIf

	If lOk
		_Super:gravaValorGlobal("REGISTROS_GRAVADOS", 0)
		Self:calculaTotalGravacao()

		Self:iniciaGravacoes()

		lOk := Self:aguardaFimGravacao()
	EndIf

	If lTemps
		If !lOk
			Self:desfazGravacao()
		EndIf

		Self:finalizaTempsGravacao()
	EndIf

Return lOk


/*/{Protheus.doc} calculaTotalGravacao
Cálcula o total de registros que serão gravados e salva na global para controle do percentual da etapa de gravação.
@author Lucas Fagundes
@since 06/03/2024
@version P12
@return Nil
/*/
Method calculaTotalGravacao() Class PCPA152Gravacao
	Local nQtd := 0
	Local oDisp := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_SMF))
	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_SVM))
	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_SVY))
	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_HZ7))
	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_HZJ))
	nQtd += Len(_Super:retornaListaGlobal(LISTA_DADOS_HZK))

	nQtd += Len(oDisp:getDispSMR(Nil, .F.))
	nQtd += Len(oDisp:getDispSMK(Nil, .F.))
	nQtd += 1 // Tabela SMT será sempre 1.

	_Super:gravaValorGlobal("TOTAL_GRAVACAO", nQtd)

Return Nil

/*/{Protheus.doc} iniciaGravacoes
Delega a gravação das tabelas.
@author Lucas Fagundes
@since 05/08/2024
@version P12
@return Nil
/*/
Method iniciaGravacoes() Class PCPA152Gravacao

	_Super:gravaValorGlobal("GRAVACAO_SMF", "INI")
	_Super:gravaValorGlobal("GRAVACAO_SVM", "INI")
	_Super:gravaValorGlobal("GRAVACAO_HZ7", "INI")
	_Super:delegar("P152IniGrv", Self:cProg, ID_GRAV_TEMPOS)

	_Super:gravaValorGlobal("GRAVACAO_SVY", "INI")
	_Super:delegar("P152IniGrv", Self:cProg, ID_GRAV_OCORRENCIAS)

	_Super:gravaValorGlobal("GRAVACAO_SMK", "INI")
	_Super:gravaValorGlobal("GRAVACAO_SMR", "INI")
	_Super:gravaValorGlobal("GRAVACAO_SMT", "INI")
	_Super:delegar("P152IniGrv", Self:cProg, ID_GRAV_DISP)

	_Super:gravaValorGlobal("GRAVACAO_HZJ", "INI")
	_Super:gravaValorGlobal("GRAVACAO_HZK", "INI")
	_Super:delegar("P152IniGrv", Self:cProg, ID_GRAV_FERRAMENTAS)

Return Nil

/*/{Protheus.doc} P152IniGrv
Inicia a gravação de uma tabela em uma nova thread.
@type  Function
@author Lucas Fagundes
@since 17/10/2023
@version P12
@param cProg , Caracter, Código da programação.
@param cID   , Caracter, Identificador da tabela que será gravada.
@return Nil
/*/
Function P152IniGrv(cProg, cID)
	Local oProcesso  := Nil

	If cID == ID_GRAV_OCORRENCIAS
		If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
			If !oProcesso:oOcorrens:gravaOcorrencias()
				oProcesso:gravaValorGlobal("GRAVACAO_SVY", "ERRO")
			EndIf
		EndIf
	Else
		If cID == ID_GRAV_TEMPOS
			PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oProcesso)
		ElseIf cID == ID_GRAV_DISP
			PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_DISP, @oProcesso)
		ElseIf cID == ID_GRAV_FERRAMENTAS
			PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_FERRAMENTA, @oProcesso)
		EndIf

		oProcesso:gravaDados()
	EndIf

Return Nil

/*/{Protheus.doc} aguardaFimGravacao
Aguarda o fim do processo de gravação.
@author Lucas Fagundes
@since 17/10/2023
@version P12
@return lSucesso, Logico, Indica se houve erros na gravação.
/*/
Method aguardaFimGravacao() Class PCPA152Gravacao
	Local nIndex    := 0
	Local nQtdProc  := 0
	Local nTotProc  := 0
	Local nPercent  := 0

	nTotProc := _Super:retornaValorGlobal("TOTAL_GRAVACAO")

	While _Super:permiteProsseguir() .And. (_Super:retornaValorGlobal("GRAVACAO_SMF") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_SVM") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_SVY") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_SMK") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_SMR") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_SMT") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_HZ7") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_HZJ") != "END" .Or.;
	                                        _Super:retornaValorGlobal("GRAVACAO_HZK") != "END")
		nIndex++

		If nIndex == 5
			nIndex   := 0
			nQtdProc := _Super:retornaValorGlobal("REGISTROS_GRAVADOS")
			nPercent := (nQtdProc * 100) / nTotProc

			_Super:gravaPercentual(CHAR_ETAPAS_GRAVACAO, nPercent)
		EndIf

		Sleep(500)
	End

Return _Super:permiteProsseguir()

/*/{Protheus.doc} limpaTabelasParaGravacao
Limpa as tabelas para realiza a gravação dos dados.
@author Lucas Fagundes
@since 05/08/2024
@version P12
@return lSucesso, Logico, Indica se teve sucesso.
/*/
Method limpaTabelasParaGravacao() Class PCPA152Gravacao
	Local lSucesso := .T.

	_Super:gravaValorGlobal("LIMPEZA_SVM", "INI")
	_Super:gravaValorGlobal("LIMPEZA_SVY", "INI")
	_Super:gravaValorGlobal("LIMPEZA_SMF", "INI")
	_Super:gravaValorGlobal("LIMPEZA_HZK", "INI")

	_Super:delegar("P152DelCln", Self:cProg, "SVM")
	_Super:delegar("P152DelCln", Self:cProg, "SVY")
	_Super:delegar("P152DelCln", Self:cProg, "SMF")

	If Self:lFerram
		_Super:delegar("P152DelCln", Self:cProg, "HZK")
	Else
		_Super:gravaValorGlobal("LIMPEZA_HZK", "END")
	EndIf

	lSucesso := Self:aguardaLimpezaTabelas()

Return lSucesso

/*/{Protheus.doc} aguardaLimpezaTabelas
Aguarda o fim da limpeza das tabelas.
@author Lucas Fagundes
@since 05/08/2024
@version P12
@return Nil
/*/
Method aguardaLimpezaTabelas() Class PCPA152Gravacao

	While _Super:permiteProsseguir() .And. (_Super:retornaValorGlobal("LIMPEZA_SVM") != "END" .Or.;
	                                        _Super:retornaValorGlobal("LIMPEZA_SVY") != "END" .Or.;
	                                        _Super:retornaValorGlobal("LIMPEZA_SMF") != "END" .Or.;
	                                        _Super:retornaValorGlobal("LIMPEZA_HZK") != "END")
		Sleep(50)
	End

Return _Super:permiteProsseguir()

/*/{Protheus.doc} criaTempsGravacao
Cria as tabelas temporaria para armazenar o backup dos dados anteriores durante a etapa de gravação.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@return Nil
/*/
Method criaTempsGravacao() Class PCPA152Gravacao
	Local aIndices  := {}
	Local aStruct   := {}
	Local aTables   := {}
	Local cAlias    := ""
	Local nIndex    := 0
	Local nIndice   := 0
	Local nTempoIni := 0
	Local nTempoTot := 0
	Local nTotIndc  := 0
	Local nTotTable := 0
	Local oTable    := Nil

	aTables   := {{"SVM", "VM_FILIAL", "VM_PROG"},;
	              {"SVY", "VY_FILIAL", "VY_PROG"},;
	              {"SMR", "MR_FILIAL", "MR_PROG"},;
	              {"SMK", "MK_FILIAL", "MK_PROG"},;
	              {"SMF", "MF_FILIAL", "MF_PROG"}}

	If Self:lFerram
		aAdd(aTables, {"HZK", "HZK_FILIAL", "HZK_PROG"})
	EndIf

	nTotTable := Len(aTables)
	nTempoTot := MicroSeconds()

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Inicio da criacao das tabelas temporarias para gravacao dos dados"})

	For nIndex := 1 To nTotTable
		cAlias := aTables[nIndex][1]

		nTempoIni := MicroSeconds()
		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Inicio da criacao da tabela temporaria para gravar o backup da tabela " + cAlias})

		oTable   := FwTemporaryTable():New()
		aStruct  := (cAlias)->(dbStruct())
		aIndices := Self:getIndicesAlias(cAlias)

		oTable:setFields(aStruct)

		nTotIndc := Len(aIndices)
		For nIndice := 1 To nTotIndc
			oTable:addIndex(cValToChar(nIndice), aIndices[nIndice])
		Next

		oTable:create()

		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Fim da criacao da tabela temporaria para gravar o backup da tabela " + cAlias + ", tempo total: " + cValToChar(MicroSeconds() - nTempoIni)})

		Self:oTemps[cAlias] := JsonObject():New()
		Self:oTemps[cAlias]["tableObject"] := oTable
		Self:oTemps[cAlias]["struct"     ] := aStruct
		Self:oTemps[cAlias]["indices"    ] := aIndices
		Self:oTemps[cAlias]["campoFilial"] := aTables[nIndex][2]
		Self:oTemps[cAlias]["campoProg"  ] := aTables[nIndex][3]

		aIndices := {}
		aStruct  := {}
		oTable   := Nil
	Next

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Fim da criacao das tabelas temporarias para gravacao dos dados, tempo total: " + cValToChar(MicroSeconds() - nTempoTot)})

	aSize(aTables, 0)
Return Nil

/*/{Protheus.doc} getIndicesAlias
Retorna os indices de uma tabela com os campos tratados para a tabela temporaria.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@param cAlias, Caracter, Alias que ira retornar os indices.
@return aIndices, Array, Indices para utilizar na tabela temporaria
/*/
Method getIndicesAlias(cAlias) Class PCPA152Gravacao
	Local aIndices := FWSIXUtil():GetAliasIndexes(cAlias)
	Local nInd     := 0
	Local nIndAux  := 0
	Local nTot     := 0
	Local nTotAux  := 0

	nTot := Len(aIndices)
	For nInd := 1 To nTot
		nTotAux := Len(aIndices[nInd])

		For nIndAux := 1 To nTotAux
			aIndices[nInd][nIndAux] := StrTran(aIndices[nInd][nIndAux], "STR(", "")
			aIndices[nInd][nIndAux] := StrTran(aIndices[nInd][nIndAux], "DTOS(", "")
			aIndices[nInd][nIndAux] := StrTran(aIndices[nInd][nIndAux], ")", "")
		Next
	Next

Return aIndices

/*/{Protheus.doc} carregaTempsGravacao
Carrega os dados de backup nas tabelas temporarias.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@return lSucesso, Logico, Indica se conseguiu gravar as informações com sucesso.
/*/
Method carregaTempsGravacao() Class PCPA152Gravacao
	Local aTables  := Self:oTemps:getNames()
	Local cAlias   := ""
	Local cFields  := ""
	Local cInsert  := ""
	Local nInd     := 0
	Local nTime    := 0
	Local nTimeTot := MicroSeconds()
	Local nTot     := Len(aTables)
	Local oInfo    := Nil
	Local oTemp    := Nil
	Local lSucesso := .T.

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Inicio do backup dos dados para gravacao"})

	For nInd := 1 To nTot
		cAlias    := aTables[nInd]
		oInfo     := Self:oTemps[cAlias]
		oTemp     := oInfo["tableObject"]
		cFields   := Self:getCamposTempToQuery(cAlias)

		cInsert := " INSERT INTO " + oTemp:getTableNameForQuery() + " (" + cFields + ") "
		cInsert += " SELECT " + cFields
		cInsert +=   " FROM " + RetSqlName(cAlias)
		cInsert +=  " WHERE " + oInfo["campoFilial"] + " = '" + xFilial(cAlias) + "' "
		cInsert +=    " AND " + oInfo["campoProg"  ] + " = '" + Self:cProg      + "' "
		cInsert +=    " AND D_E_L_E_T_ = ' ' "

		nTime := MicroSeconds()
		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Query insert temporaria " + cAlias + ": " + cInsert})

		If TcSqlExec(cInsert) < 0
			lSucesso := .F.
			_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, STR0524 + cAlias, AllTrim(TcSqlError())) // "Ocorreu erro ao realizar backup dos dados da tabela "
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo insert temporaria " + cAlias + ": " + cValToChar(MicroSeconds() - nTime)})

		oInfo := Nil
		oTemp := Nil
	Next

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Fim do backup dos dados para gravacao, tempo total: " + cValToChar(MicroSeconds() - nTimeTot)})

	aSize(aTables, 0)
Return lSucesso

/*/{Protheus.doc} desfazGravacao
Desfaz a gravação dos dados, restaurando os dados das tabelas temporarias.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@return lSucesso, Logico, Indica se conseguiu restaurar com sucesso as informações.
/*/
Method desfazGravacao() Class PCPA152Gravacao
	Local aTables   := Self:oTemps:getNames()
	Local cAlias    := ""
	Local cFields   := ""
	Local cSql      := ""
	Local lSucesso  := .T.
	Local nIndex    := 0
	Local nTempoQry := 0
	Local nTempoTot := MicroSeconds()
	Local nTotal    := Len(aTables)
	Local oInfo     := Nil
	Local oTemp     := Nil

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Inicio restauracao do backup das tabelas"})

	For nIndex := 1 To nTotal
		cAlias := aTables[nIndex]
		oInfo  := Self:oTemps[cAlias]

		cSql := " DELETE FROM " + RetSqlName(cAlias)
		cSql +=  " WHERE " + oInfo["campoFilial"] + " = '" + xFilial(cAlias) + "' "
  		cSql +=    " AND " + oInfo["campoProg"  ] + " = '" + Self:cProg      + "' "
  		cSql +=    " AND D_E_L_E_T_ = ' ' "

		nTempoQry := MicroSeconds()
		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Query delete tabela " + cAlias + ": " + cSql})

		If TcSqlExec(cSql) < 0
			lSucesso := .F.
			_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, STR0525 + cAlias, AllTrim(TCSQLError())) // "Erro ao deletar os dados para restaurar a tabela "
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo query delete tabela " + cAlias + ": " + cValToChar(MicroSeconds() - nTempoQry)})

		If lSucesso
			cFields := Self:getCamposTempToQuery(cAlias)
			oTemp   := oInfo["tableObject"]

			cSql := " INSERT INTO " + RetSqlName(cAlias) + " (" + cFields + ") "
			cSql += " SELECT " + cFields
			cSql +=   " FROM " + oTemp:getTableNameForQuery()
			cSql +=  " WHERE " + oInfo["campoFilial"] + " = '" + xFilial(cAlias) + "' "
			cSql +=    " AND " + oInfo["campoProg"  ] + " = '" + Self:cProg      + "' "
			cSql +=    " AND D_E_L_E_T_ = ' ' "

			nTempoQry := MicroSeconds()
			Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Query insert tabela " + cAlias + ": " + cSql})

			If TcSqlExec(cSql) < 0
				lSucesso := .F.
				_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, STR0526 + cAlias, AllTrim(TCSQLError())) // "Erro ao restaurar os dados da tabela "
			EndIf

			Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo query insert tabela " + cAlias + ": " + cValToChar(MicroSeconds() - nTempoQry)})
		EndIf

		oInfo := Nil
		oTemp := Nil

		If !lSucesso
			Exit
		EndIf
	Next

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Fim restauracao do backup das tabelas, tempo total: " + cValToChar(MicroSeconds() - nTempoTot)})

	aSize(aTables, 0)
Return lSucesso

/*/{Protheus.doc} getCamposTempToQuery
Converte os campos da estrutura de uma tabela para string que será utilizada na montagem da query.
@author Lucas Fagundes
@since 06/08/2024
@version version
@param cAlias, Caracter, Alias que irá retornar os campos para consulta.
@return cFields, Caracter, Campos formatados para consulta.
/*/
Method getCamposTempToQuery(cAlias) Class PCPA152Gravacao
	Local aFields   := Self:oTemps[cAlias]["struct"]
	Local cFields   := ""
	Local nIndField := 0
	Local nTotField := Len(aFields)

	For nIndField := 1 To nTotField
		cFields += aFields[nIndField][1]

		If nIndField < nTotField
			cFields += ", "
		EndIf
	Next

Return cFields

/*/{Protheus.doc} finalizaTempsGravacao
Deleta as tabelas temporarias criadas para etapa de gravação.
@author Lucas Fagundes
@since 06/08/2024
@version P12
@return Nil
/*/
Method finalizaTempsGravacao() Class PCPA152Gravacao
	Local aTables := Self:oTemps:getNames()
	Local cAlias  := ""
	Local nIndex  := 0
	Local nTotal  := Len(aTables)
	Local oTemp   := Nil

	For nIndex := 1 To nTotal
		cAlias := aTables[nIndex]

		oTemp := Self:oTemps[cAlias]["tableObject"]

		oTemp:zap()
		oTemp:delete()

		Self:oTemps[cAlias]["tableObject"] := Nil

		aSize(Self:oTemps[cAlias]["struct" ], 0)
		aSize(Self:oTemps[cAlias]["indices"], 0)

		Self:oTemps[cAlias]["campoFilial"] := ""
		Self:oTemps[cAlias]["campoProg"  ] := ""

		Self:oTemps[cAlias] := Nil

		oTemp := Nil
	Next

	Self:oTemps := Nil

	aSize(aTables, 0)
Return Nil

/*/{Protheus.doc} geraOcorrenciasOperacoes
Inicia a geração de ocorrencias relacionadas as operação carregadas.
@author Lucas Fagundes
@since 18/11/2024
@version P12
@return Nil
/*/
Method geraOcorrenciasOperacoes() Class PCPA152Process
	Local oTempoOper := Nil

	If Self:processamentoFactory(Self:cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:ocorrenciaOperacoes()
	EndIf

Return Nil

/*/{Protheus.doc} PCPA152Log
Classe para controle dos logs do CRP.
@author Lucas Fagundes
@since 03/03/2025
@version P12
/*/
Class PCPA152Log From LongNameClass
	Private Data cFilePath as Character
	Private Data cGlbValue as Character
	Private Data lAtivo    as Logical
	Private Data lError    as Logical
	Private Data oArquivo  as Object

	Public Method new() Constructor
	Public Method destroy()
	Public Method criaArquivo()
	Public Method logAtivo()
	Public Method gravaLog(cEtapa, aMensagem)
	Public Method gravaParametros(oParams)

	Private Method lockFile()
	Private Method unlockFile()
	Private Method setError()
	Private Method hasError()

EndClass

/*/{Protheus.doc} new
Método construtor da classe PCPA152Log.
@author Lucas Fagundes
@since 03/03/2025
@version P12
@return Self, Object, Retorna nova instancia da classe.
/*/
Method new() Class PCPA152Log
	Local cFilAux := RTrim(cFilAnt)

	Self:lAtivo    := GetMV("MV_LOGCRP", .F., .F.)
	Self:cFilePath := GetSrvProfString("STARTPATH","") + "logCRP_" + cFilAux + ".csv"
	Self:cGlbValue := "CRP_LOG_" + cFilAux
	Self:oArquivo  := FWFileWriter():New(Self:cFilePath, .F.)
	Self:lError    := .F.

	If Self:lAtivo .And. Trim(GetGlbValue(Self:cGlbValue)) == ""
		PutGlbValue(Self:cGlbValue, "OK")
	EndIf

Return Self

/*/{Protheus.doc} destroy
Limpa as propriedades da classe.
@author Lucas Fagundes
@since 04/03/2025
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Log
	Local cMsg := ""

	If Self:hasError()
		cMsg := "ATENCAO - O arquivo de logs pode apresentar inconsistencias, pois uma ou mais threads apresentaram erro de gravacao."

		Self:lAtivo := .T.
		Self:lError := .F.
		PutGlbValue(Self:cGlbValue, "OK")

		LogMsg("PCPA152", 0, 0, 1, "", "", cMsg)
		Self:gravaLog("error", {cMsg})
	EndIf

	ClearGlbValue(Self:cGlbValue)

	Self:lAtivo    := .F.
	Self:lError	   := .F.
	Self:cFilePath := ""
	Self:cGlbValue := ""
	Self:oArquivo  := Nil

Return Nil

/*/{Protheus.doc} criaArquivo
Cria o arquivo de logs do CRP (em disco).
@author Lucas Fagundes
@since 03/03/2025
@version P12
@return Nil
/*/
Method criaArquivo() Class PCPA152Log
	Local lSucesso := .T.

	If Self:logAtivo()

		If Self:oArquivo:exists()
			lSucesso := Self:oArquivo:clear(.T.)
		Else
			lSucesso := Self:oArquivo:create()
		EndIf

		If lSucesso
			Self:oArquivo:write(CABECALHO_ARQUIVO)
		Else
			LogMsg("PCPA152", 0, 0, 1, "", "", "Nao foi possivel criar o arquivo " + Self:cFilePath + IIf(Empty(Self:oArquivo:error():Message), "", ". Erro: "+ AllTrim(Self:oArquivo:error():Message)))
			Self:setError()
		EndIf

		Self:oArquivo:close()
	EndIf

Return Nil

/*/{Protheus.doc} logAtivo
Retorna se a gravação de logs esta ativa.
@author Lucas Fagundes
@since 03/03/2025
@version P12
@return Self:lAtivo, Logico, Indica se a gravação de logs esta ativa.
/*/
Method logAtivo() Class PCPA152Log

	If Self:lAtivo .And. Self:hasError()
		Self:lAtivo := .F.
	EndIf

Return Self:lAtivo

/*/{Protheus.doc} gravaLog
Grava uma mensagem no arquivo de log do CRP (em disco).
@author Lucas Fagundes
@since 03/03/2025
@version P12
@param 01 cEtapa   , Caracter, Etapa que esta gravando a mensagem.
@param 02 aMensagem, Caracter, Mensagem que será gravada no log.
@return Nil
/*/
Method gravaLog(cEtapa, aMensagem, cOrdem, cOperacao, cRecurso, cChave) Class PCPA152Log
	Local cPrefixo := ""
	Local lAbriu   := .F.
	Local nIndex   := 0
	Local nQtdMsg  := 0

	If !Self:logAtivo()
		Return
	EndIf

	// Realiza o lock para duas threads não abrirem o arquivo ao mesmo tempo.
	If Self:lockFile()

		lAbriu := Self:oArquivo:open(FO_WRITE)
		If lAbriu
			cPrefixo := getPrefixo(cEtapa, cOrdem, cOperacao, cRecurso, cChave)

			Self:oArquivo:goBottom()

			nQtdMsg := Len(aMensagem)
			For nIndex := 1 To nQtdMsg
				Self:oArquivo:write(cPrefixo + aMensagem[nIndex])
			Next nIndex

			Self:oArquivo:close()
		Else
			LogMsg("PCPA152", 0, 0, 1, "", "", "Nao foi possivel abrir o arquivo " + Self:cFilePath + IIf(Empty(Self:oArquivo:error():Message), "", ". Erro: " + AllTrim(Self:oArquivo:error():Message)))
			Self:setError()
		EndIf

		Self:unlockFile()
	Else
		LogMsg("PCPA152", 0, 0, 1, "", "", "Nao foi possivel realizar o lock para abrir o arquivo de log.")
		Self:setError()
	EndIf

Return Nil

/*/{Protheus.doc} lockFile
Realiza o lock para gravação do arquivo de log.
Caso o arquivo esteja em uso, aguarda até que seja liberado para gravação.

@author Lucas Fagundes
@since 03/03/2025
@version P12
@return lSucesso, Logico, Indica se conseguiu realizar o lock.
/*/
Method lockFile() Class PCPA152Log
	Local nTentativas := 0
	Local lSucesso	  := .F.

	While !lSucesso .And. nTentativas < 50
		lSucesso := LockByName(Self:cFilePath)

		If !lSucesso
			nTentativas++
			Sleep(500)
		End
	End

Return lSucesso

/*/{Protheus.doc} unlockFile
Realiza o unlock da gravação do arquivo de log do CRP.
@author Lucas Fagundes
@since 03/03/2025
@version P12
@return lOk, Logico, Indica se conseguiu realizar o unlock.
/*/
Method unlockFile() Class PCPA152Log
	Local lOk := UnlockByName(Self:cFilePath)

Return lOk

/*/{Protheus.doc} gravaParametros
Grava log dos parâmetros usados na execução do CRP.
@author Lucas Fagundes
@since 03/03/2025
@version P12
@param oParams, Object, Json com os parâmetros de execução do CRP.
@return Nil
/*/
Method gravaParametros(oParams) Class PCPA152Log
	Local aMessages := {}
	Local aNames    := {}
	Local cMessage  := ""
	Local cParam    := ""
	Local cParType  := ""
	Local nIndex    := 0
	Local nTotal    := 0

	If !Self:logAtivo()
		Return
	EndIf

	aNames := oParams:getNames()
	nTotal := Len(aNames)

	For nIndex := 1 To nTotal
		cParam   := aNames[nIndex]
		cParType := ValType(oParams[cParam])

		cMessage := cParam + " = "

		If cParType == "C"
			cMessage += '"' + oParams[cParam] + '"'

		ElseIf cParType == "N"
			cMessage += cValToChar(oParams[cParam])

		ElseIf cParType == "A"
			cMessage += '"' + ArrToKStr(oParams[cParam], '", "') + '"'

		ElseIf cParType == "L"
			If oParams[cParam]
				cMessage += ".T."
			Else
				cMessage += ".F."
			EndIf

		EndIf

		aAdd(aMessages, cMessage)
	Next

	Self:gravaLog("parametros", aMessages)

	aSize(aNames, 0)
	aSize(aMessages, 0)
Return Nil

/*/{Protheus.doc} setError
Seta a propriedade de erro e desativa a gravação de logs.
@author Lucas Fagundes
@since 22/04/2025
@version P12
@return Nil
/*/
Method setError() Class PCPA152Log
	Local cMsg := "ATENCAO - O arquivo de logs pode apresentar inconsistencias, pois a thread " + cValToChar(ThreadID()) + " apresentou erro na gravacao dos logs."

	LogMsg("PCPA152", 0, 0, 1, "", "", cMsg)

	Self:lError := .T.
	Self:lAtivo := .F.

	PutGlbValue(Self:cGlbValue, "ERRO")

Return Nil

/*/{Protheus.doc} hasError
Verifica se ocorreu erro na gravação dos logs.
@author Lucas Fagundes
@since 23/04/2025
@version P12
@return Self:lError, Logico, Indica se houve erro na gravação dos logs.
/*/
Method hasError() Class PCPA152Log

	If !Self:lError
		Self:lError := GetGlbValue(Self:cGlbValue) == "ERRO"
	EndIf

Return Self:lError

/*/{Protheus.doc} executaLimpeza
Executa a limpeza dos dados da programação em uma tabela.
@author Lucas Fagundes
@since 22/04/2025
@version P12
@param cTabela, Caracter, Alias da tabela que terá os dados da programação apagados.
@return Nil
/*/
Method executaLimpeza(cTabela) Class PCPA152Gravacao
	Local cQuery     := ""
	Local lSucesso   := .T.
	Local cChave     := "LIMPEZA_" + cTabela
	Local cCampoFil  := ""
	Local cCampoProg := ""

	If cTabela == "SMF"
		cCampoFil  := "MF_FILIAL"
		cCampoProg := "MF_PROG"

	ElseIf cTabela == "SVM"
		cCampoFil  := "VM_FILIAL"
		cCampoProg := "VM_PROG"

	ElseIf cTabela == "SVY"
		cCampoFil  := "VY_FILIAL"
		cCampoProg := "VY_PROG"

	ElseIf cTabela == "HZK"
		cCampoFil  := "HZK_FILIAL"
		cCampoProg := "HZK_PROG"

	EndIf

	cQuery := " DELETE FROM " + RetSqlName(cTabela)
	cQuery += "  WHERE " + cCampoFil  + " = '" + xFilial(cTabela) + "' "
	cQuery += "    AND " + cCampoProg + " = '" + Self:cProg       + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "

	If TCSQLExec(cQuery) < 0
		lSucesso := .F.

		_Super:gravaValorGlobal(cChave, "ERRO")
		_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, i18n(STR0298, {cTabela}), AllTrim(TCSQLError())) // "Erro na limpeza da tabela #1[tabela]#"
	EndIf

	If lSucesso
		_Super:gravaValorGlobal(cChave, "END")
	EndIf

Return Nil

/*/{Protheus.doc} geraDisponibilidadeAdicional
Método responsavel por gerar disponibilidade adicional para os recursos/ferramentas.
@author Lucas Fagundes
@since 07/05/2025
@version P12
@return Nil
/*/
Method geraDisponibilidadeAdicional() Class PCPA152Process

	If Self:retornaValorGlobal("GEROU_DISPONIBILIDADE_ADICIONAL")
		Self:gravaValorGlobal(ID_RECURSO_ADC, "INI")

		Self:delegar("P152DAdc", Self:cProg, ID_RECURSO_ADC)

		While Self:permiteProsseguir() .And. (Self:retornaValorGlobal(ID_RECURSO_ADC) == "INI")
			Sleep(100)
		End
	EndIf

Return Nil

/*/{Protheus.doc} P152DAdc
Processa em uma nova thread a geração de disponibilidade adicional dos recursos/ferramentas.
@type  Function
@author Lucas Fagundes
@since 07/05/2025
@version P12
@param cProg , Caracter, Código da programação.
@param cIdIni, Caracter, Id do processo de disponibilidade adicional a ser executado.
@return Nil
/*/
Function P152DAdc(cProg, cIdIni)
	Local oProcesso := Nil
	Local oProcAux  := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)

		If cIdIni == ID_RECURSO_ADC
			If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_DISP, @oProcAux)
				oProcAux:processaRecursos(.T.)
			EndIf
		EndIf

		oProcesso:gravaValorGlobal(cIdIni, "FIM")
	EndIf

Return Nil
