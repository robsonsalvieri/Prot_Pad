#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE INFO_ALOCACOES_DISTTUDO      1
#DEFINE INFO_ALOCACOES_PERIODOS      2
#DEFINE INFO_ALOCACOES_ENTREGA       3
#DEFINE INFO_ALOCACOES_DATA          4
#DEFINE INFO_ALOCACOES_HORA          5
#DEFINE INFO_ALOCACOES_ENTREGA_JUNTO 6
#DEFINE INFO_ALOCACOES_TAMANHO       6

#DEFINE ALOCACAO_ORIGINAL_INI_DATA 1
#DEFINE ALOCACAO_ORIGINAL_INI_HORA 2
#DEFINE ALOCACAO_ORIGINAL_FIM_DATA 3
#DEFINE ALOCACAO_ORIGINAL_FIM_HORA 4
#DEFINE ALOCACAO_ORIGINAL_TAMANHO  4


Static _nTamC2Num := Nil
Static _nTamC2Ite := Nil
Static _nTamC2Seq := Nil

/*/{Protheus.doc} PCPA152Nivelamento
Classe responsavel por realizar o nivelamento no processamento do CRP.

@author Lucas Fagundes
@since 10/08/2023
@version P12
/*/
Class PCPA152Nivelamento From PCPA152TempoOperacao
	Private Data aChvArvs   as Array
	Private Data aOperacoes as Array
	Private Data cProg      as Caracter
	Private Data oJsInicio  as Object
	Private Data oOPsArv    as Object
	Private Data oParamNiv  as Object
	Private Data oAlocOper  as Object
	Private Data oRealocado as Object

	Public Method new(cProg) Constructor
	Public Method destroy()

	// Métodos de processamento
	Public Method executaNivelamento()
	Public Method executaReducaoSetup()
	Public Method identificaSetupDuplicado(cRecurso, aDispRecur, cAlocRec)
	Private Method nivelarOperacoes()
	Private Method nivelaPelaDataDaProgramacao()
	Private Method reprocessaArvore(aOperRepro, nIndex, nIniArvore)
	Private Method alocaDataProgramacao(aOperacoes)
	Private Method ajustaAlocacoesRecursos()

	// Métodos auxiliares
	Private Method atualizaOrdemOperacoes(nPosInic, aOperacoes)
	Private Method getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecurso)
	Private Method getOperacsOrdenadas(aOperacao, lLogaRepro, cOpPai, lOrdena)
	Private Method gravaParamAlocOper(aOperacao, lDeleta, lDataProg, lEntrega, lDataDaOP)
	Private Method ordemPaiNivelouPeloInicio(aOperacao)
	Private Method recuperaParamAlocOper(aOperacao, lDataProg, lEntrega, lDataDaOP, lInicio)
	Private Method validaDatasOp()
	Public Method executaSimulacao(cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet)
	Private Method getChaveAlocacao(aOperacao, cRecurso)
	Private Method simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig)
	Private Method avaliaSimulacao(aOperacao, lEntrega)
	Private Method getParametrosAlocacao(aOperacao, cRecurso, lEntrega, dData, nHora, lEntJunto)
	Private Method avaliaSobreposicao(aOperacao, aDatas, lEntrega, aPeriodos, dData, nHora, lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, lEntJunto, aAlocOrig, aFerramenta, cJsFerram)

	// Métodos para o Nivelamento
	Private Method adicionaOrdemNiveladaPeloInicio(cOrdem)
	Private Method atualizaPercentual(nQtdProc, nTotProc)
	Private Method desfazArvore(lLog, aOperacao)
	Private Method efetivaOperacoesAlocadas()
	Private Method iniciaArvores()
	Private Method ordemNivelaPelaDataDeInicio(aOperacao)
	Private Method preparaOperacoes()
	Private Method removeOrdemNiveladaPeloInicio(cOrdem)
	Private Method alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, lDistTudo, lDispAdc, cRecurso, lAlocPost, lRetCria, aAlocOrig, lEntJunto, dDataAlo, nHoraAlo)
	Private Method validaPeriodosAlternativo(aPeriodos1, aPeriodos2, lEntrega, nTmpRec1, nTmpRec2)

	// Métodos para a Redução de Setup
	Private Method ajustaOcorrencias()
	Private Method alterouAlocacao(aAlocado, aNovaAloc)
	Private Method avaliaOperacao(aOperacao, oRecursos, oArvores, oAlterados, lInicio)
	Private Method getAlocacaoSVM(aOperacao)
	Private Method buscaHoraRecurso(aOperacao, dData, nHora, lFinal, lEncontrou)
	Private Method carregaArvoresParaReprocessar(oArvores, oRecursos)
	Private Method carregaJaNivelados(aOperacao, lInicio)
	Private Method existeDisponibilidade(aOperacao, lEntrega, dDataDisp, nHoraDisp, dIniOper, nHrIniOper, dFimOper, nHrFimOper)
	Private Method existeTempoDisponivel(aOperacao, aIndices)
	Private Method gravaArvoreSetupDuplicado(cRecurso, oArvores)
	Private Method produtoAlocacaoAnteriorIgual(aAlocAnt, aDispRecur, cProduto)
	Private Method realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP)
	Private Method recuperaIndicesTemposOperacao(aOperacao, aAlocado)
	Private Method registraRealocado(aOperacao)
	Private Method removeAlocacaoDisponibilidade(aDispRecur, nIndDisp, nRemove, oIndices)
	Private Method removeOperacao(aAlocado, aOperacao)
	Private Method substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc)
	Private Method verificaMudancaOperacao(aAlocado, lInicio, aOperacao, lDataDaOP, lDataProg)

EndClass

/*/{Protheus.doc} new
Método construtor da classe.
@author Lucas Fagundes
@since 10/08/2023
@version P12
@param cProg, Caracter, Código da programação que está sendo executada.
@return Self, Object, Instancia da classe de nivelamento do CRP.
/*/
Method new(cProg) Class PCPA152Nivelamento
	Self:aOperacoes := {}
	Self:aChvArvs   := {}
	Self:cProg      := cProg
	Self:oJsInicio  := JsonObject():New()
	Self:oOPsArv    := JsonObject():New()
	Self:oParamNiv  := JsonObject():New()
	Self:oAlocOper  := JsonObject():New()
	Self:oRealocado := JsonObject():New()

	_Super:new(Self:cProg)

	Self:oParamNiv["priorizacao"       ] := _Super:retornaParametro("priorizacao")
	Self:oParamNiv["dataNivelamento"   ] := _Super:retornaParametro("dataNivelamento")
	Self:oParamNiv["dataInicial"       ] := _Super:retornaParametro("dataInicial")
	Self:oParamNiv["horaInicial"       ] := _Super:retornaParametro("horaInicial")
	Self:oParamNiv["quebraOperacoes"   ] := _Super:retornaParametro("quebraOperacoes")
	Self:oParamNiv["MV_LOGCRP"         ] := _Super:retornaParametro("MV_LOGCRP")
	Self:oParamNiv["tipoAlternativo"   ] := _Super:retornaParametro("tipoAlternativo")
	Self:oParamNiv["ordensAtrasadas"   ] := _Super:retornaParametro("ordensAtrasadas")
	Self:oParamNiv["utilizaFerramentas"] := _Super:retornaParametro("utilizaFerramentas") .And. GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0

	iniStatic()

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe
@author Lucas Fagundes
@since 17/08/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Nivelamento

	_Super:destroy()

	Self:cProg := Nil

	FreeObj(Self:oRealocado)
	FreeObj(Self:oAlocOper)
	FwFreeObj(Self:oJsInicio)
	FwFreeObj(Self:oOPsArv)
	FwFreeObj(Self:oParamNiv)

	aSize(Self:aChvArvs, 0)
	Self:aChvArvs := Nil
	aSize(Self:aOperacoes, 0)
	Self:aOperacoes := Nil
Return Nil

/*/{Protheus.doc} executaNivelamento
Processa o nivelamento da operações.
@author Lucas Fagundes
@since 10/08/2023
@version P12
@return lSucesso, Logico, Indica se finalizou o processamento com sucesso
/*/
Method executaNivelamento() Class PCPA152Nivelamento
	Local lSucesso  := .T.

	Self:preparaOperacoes()

	Self:lBkpDisp := .T.

	If Self:oParamNiv["dataNivelamento"] == PARAM_DATA_NIV_DAT_OP
		lSucesso := Self:nivelarOperacoes()
	Else
		lSucesso := Self:nivelaPelaDataDaProgramacao()
	EndIf

	Self:lBkpDisp := .F.

	Self:oOcorrens:localToGlobal()

Return lSucesso

/*/{Protheus.doc} preparaOperacoes
Prepara as operações para o nivelamento.
@author Lucas Fagundes
@since 11/08/2023
@version P12
@return Nil
/*/
Method preparaOperacoes() Class PCPA152Nivelamento
	Local aOrdens := {}
	Local nIndex  := 0
	Local nTotal  := 0

	Self:aOperacoes := {}

	aOrdens := _Super:retornaListaGlobal(LISTA_DADOS_SMF)
	nTotal  := Len(aOrdens)

	For nIndex := 1 To nTotal
		appendArr(Self:aOperacoes, aOrdens[nIndex][2])

		aOrdens[nIndex][2] := Nil
		aOrdens[nIndex]    := Nil
	Next
	aSort(Self:aOperacoes,,,{|x,y| x[ARRAY_MF_PRIOR] < y[ARRAY_MF_PRIOR]})

	Self:iniciaArvores()

	aSize(aOrdens, 0)
Return Nil

/*/{Protheus.doc} iniciaArvores
Inicia as propriedades responsaveis pelo controle das árvores.
@author Lucas Fagundes
@since 05/10/2023
@version P12
@return Nil
/*/
Method iniciaArvores() Class PCPA152Nivelamento
	Local aOPsArv   := {}
	Local cChave    := ""
	Local cOrdem    := ""
	Local cUltimaOP := ""
	Local nIndex    := 1
	Local nTotal    := Len(Self:aOperacoes)

	Self:aChvArvs := {}

	For nIndex := 1 To nTotal
		cOrdem := Self:aOperacoes[nIndex][ARRAY_MF_OP]

		If cUltimaOP != cOrdem
			aAdd(aOPsArv, Self:aOperacoes[nIndex])
		EndIf

		If nIndex == nTotal .Or. !mesmaArv(Self:aOperacoes[nIndex], Self:aOperacoes[nIndex+1])
			cChave := Self:aOperacoes[nIndex][ARRAY_PROC_CHAVE_ARVORE]

			Self:oOPsArv[cChave] := aOPsArv
			aAdd(Self:aChvArvs, cChave)

			aOPsArv := {}
		EndIf

		cUltimaOP := cOrdem
	Next

Return Nil

/*/{Protheus.doc} appendArr
Adiciona os dados de um array no final de outro.
@type  Static Function
@author Lucas Fagundes
@since 11/08/2023
@version P12
@param 01 aDestino, Array, Array que será adicionado os dados (retorna por refêrencia os dados adicionados).
@param 02 aOrigem , Array, Array que terá os dados adicionados.
@return Nil
/*/
Static Function appendArr(aDestino, aOrigem)
	Local nIndex  := 0
	Local nTamOri := Len(aOrigem)

	For nIndex := 1 To nTamOri
		aAdd(aDestino, aOrigem[nIndex])
	Next nIndex

Return Nil

/*/{Protheus.doc} nivelarOperacoes
Realiza o nivelamento das operações.
@author Lucas Fagundes
@since 11/08/2023
@version P12
@return lSucesso, Logico, Indica se realizou o nivelamneto com sucesso.
/*/
Method nivelarOperacoes() Class PCPA152Nivelamento
	Local aOperacao  := {}
	Local aPeriodos  := {}
	Local cArvore    := ""
	Local cOrdem     := ""
	Local cRecAloc   := ""
	Local cRecurso   := ""
	Local cUltimaAr  := ""
	Local dDataAlo   := Nil
	Local lDistTudo  := .T.
	Local lEfetiva   := .T.
	Local lEntJunto  := .F.
	Local lEntrega   := .T.
	Local lSucesso   := .T.
	Local lTrocouAr  := .T.
	Local nHoraAlo   := 0
	Local nIndex     := 1
	Local nIniArvore := 1
	Local nTotal     := 0

	Self:cEtapaLog := CHAR_ETAPAS_NIVELAMENTO
	nTotal := Len(Self:aOperacoes)

	While nIndex <= nTotal .And. _Super:permiteProsseguir()
		aOperacao := Self:aOperacoes[nIndex]
		cArvore   := aOperacao[ARRAY_MF_ARVORE]
		cOrdem    := aOperacao[ARRAY_MF_OP]
		cRecurso  := aOperacao[ARRAY_MF_RECURSO]

		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"---- Inicio do nivelamento da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + "----"},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

		If nIndex > 1
			lTrocouAr := !mesmaArv(aOperacao, Self:aOperacoes[nIndex-1])
			If lTrocouAr
				nIniArvore := nIndex
			EndIf
		EndIf

		If lTrocouAr
			_Super:descartaBkpDisponibilidades()
			_Super:criaBackupFerramentas()
		EndIf

		If aOperacao[ARRAY_MF_SALDO] > 0

			If Self:ordemNivelaPelaDataDeInicio(aOperacao)
				Self:adicionaOrdemNiveladaPeloInicio(cOrdem)
				lEntrega := .F.
			Else
				lEntrega := .T.
			EndIf

			aPeriodos := Self:alocaOperacao(aOperacao, lEntrega, lTrocouAr, .F., @lDistTudo, .F., @cRecAloc, Nil, Nil, Nil, @lEntJunto, @dDataAlo, @nHoraAlo)

			If lDistTudo
				_Super:validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecAloc, lEntrega, lEntJunto, .F., dDataAlo, nHoraAlo)
				_Super:adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecAloc, aOperacao[ARRAY_MF_SOBREPO])
				Self:gravaParamAlocOper(aOperacao, .F., .F., lEntrega, lTrocouAr)
			Else
				Self:desfazArvore(.F., aOperacao)
				_Super:restauraBackupDisponibilidades()
				_Super:rollbackBackupFerramentas()
				Self:oOPsParc:delName(aOperacao[ARRAY_MF_OP])

				lEfetiva := Self:reprocessaArvore(aOperacao, @nIndex, nIniArvore)
			EndIf
		Else
			Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OPER] + " foi ignorada pois nao possui saldo"},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"---- Fim do nivelamento da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + "----"},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

		lEfetiva := (lDistTudo .And. (nIndex == nTotal .Or. !mesmaArv(aOperacao, Self:aOperacoes[nIndex+1]))) .Or. (!lDistTudo .And. lEfetiva)
		If lEfetiva
			lEfetiva := .F.

			Self:efetivaOperacoesAlocadas()
			Self:atualizaPercentual(nIndex, nTotal)
		EndIf

		cUltimaAr := cArvore
		nIndex++
	End
	lSucesso := _Super:permiteProsseguir()

Return lSucesso

/*/{Protheus.doc} nivelaPelaDataDaProgramacao
Realiza o nivelamento pela data da programação.
@author Lucas Fagundes
@since 05/10/2023
@version P12
@return lSucesso, Logico, Retorna se teve sucesso no nivelamento
/*/
Method nivelaPelaDataDaProgramacao() Class PCPA152Nivelamento
	Local aOperacoes := {}
	Local lSucesso   := .T.
	Local nIndChave  := 1
	Local nIndOperac := 1
	Local nOpersProc := 0
	Local nTotChave  := Len(Self:aChvArvs)
	Local nTotOpers  := Len(Self:aOperacoes)

	While nIndChave <= nTotChave .And. _Super:permiteProsseguir()
		aOperacoes := Self:getOperacsOrdenadas(Self:aChvArvs[nIndChave])

		If Self:alocaDataProgramacao(aOperacoes)
			Self:efetivaOperacoesAlocadas()

			//atualiza Self:aOperacoes com a ordem das operacoes niveladas pela data de programação
			Self:atualizaOrdemOperacoes(@nIndOperac, aOperacoes)
		EndIf

		nOpersProc += Len(aOperacoes)
		Self:atualizaPercentual(nOpersProc, nTotOpers)

		aSize(aOperacoes, 0)

		nIndChave++
	End

	lSucesso := _Super:permiteProsseguir()

Return lSucesso

/*/{Protheus.doc} atualizaOrdemOperacoes
Atualiza a ordem de Self:aOperacoes conforme a ordenação feita para realizar a alocação pela data de programação

@author lucas.franca
@since 12/07/2024
@version P12
@param 01 nPosInic  , Numerico, Posição inicial da árvore em Self:aOperacoes
@param 02 aOperacoes, Numerico, Array com as operações da árvore ordenadas
@return Nil
/*/
Method atualizaOrdemOperacoes(nPosInic, aOperacoes) Class PCPA152Nivelamento
	Local nTotal := Len(aOperacoes)
	Local nIndex := 1

	For nIndex := 1 To nTotal
		Self:aOperacoes[nPosInic] := aOperacoes[nIndex]
		nPosInic++
	Next nIndex
Return

/*/{Protheus.doc} reprocessaArvore
Reprocessa uma arvore a partir da data de inicio da programação.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@param 01 aOperRepro, Array   , Array com as informações da operação que deu origem ao reprocessamento.
@param 02 nIndex    , Numerico, Retorna por referencia a posição que deve continuar o processamento das operações.
@param 03 nIniArvore, Numerico, Posição do aOperacoes onde iniciam os dados desta árvore
@return lEfetiva, Logico, Indica se pode ou não efetivar o reprocessamento.
/*/
Method reprocessaArvore(aOperRepro, nIndex, nIniArvore) Class PCPA152Nivelamento
	Local aOperacoes := {}
	Local cChaveArv  := ""
	Local lEfetiva   := .T.

	cChaveArv  := aOperRepro[ARRAY_PROC_CHAVE_ARVORE]
	aOperacoes := Self:getOperacsOrdenadas(cChaveArv, .T.)

	Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Reprocessamento da arvore " + cChaveArv, ;
	                                              "Origem do reprocessamento: Ordem " + aOperRepro[ARRAY_MF_OP] + ", Recurso " + ;
	                                              aOperRepro[ARRAY_MF_RECURSO] + " Operacao " + aOperRepro[ARRAY_MF_OPER]},;
	                    aOperRepro[ARRAY_MF_OP], aOperRepro[ARRAY_MF_OPER], aOperRepro[ARRAY_MF_RECURSO], cChaveArv)

	lEfetiva := Self:alocaDataProgramacao(aOperacoes)
	If lEfetiva
		//atualiza Self:aOperacoes com a ordem das operacoes niveladas pela data de programação
		Self:atualizaOrdemOperacoes(nIniArvore, aOperacoes)
	EndIf
	nIndex := aScan(Self:aOperacoes, {|aOper| !mesmaArv(aOperRepro, aOper)}, nIndex) - 1

	If nIndex == -1
		nIndex := Len(Self:aOperacoes)
	EndIf

	aSize(aOperacoes, 0)
Return lEfetiva

/*/{Protheus.doc} alocaDataProgramacao
Realiza a alocação das operações pela data da programação.
@author Lucas Fagundes
@since 18/10/2023
@version P12
@param aOperacoes, Array, Array com as operações que serão alocadas pela data da programação.
@return lSucesso, Logico, Indica se conseguiu alocar com sucesso todas as operações.
/*/
Method alocaDataProgramacao(aOperacoes) Class PCPA152Nivelamento
	Local aOperacao  := {}
	Local aPeriodos  := {}
	Local cOrdem     := ""
	Local cRecAloc   := ""
	Local cRecurso   := ""
	Local cUltimaOP  := ""
	Local dDataAlo   := Nil
	Local lCriouDisp := .F.
	Local lDispAdc   := .F.
	Local lDistTudo  := .F.
	Local lEfetiDisp := .F.
	Local lEntJunto  := .F.
	Local lPrimeira  := .T.
	Local lSucesso   := .T.
	Local lTrocouAr  := .T.
	Local nHoraAlo   := 0
	Local nIndOper   := 1
	Local nTotal     := Len(aOperacoes)

	Self:cEtapaLog := CHAR_ETAPAS_NIVELAMENTO

	While nIndOper <= nTotal .And. _Super:permiteProsseguir() .And. lSucesso
		aOperacao  := aOperacoes[nIndOper]
		cOrdem     := aOperacao[ARRAY_MF_OP]
		cRecurso   := aOperacao[ARRAY_MF_RECURSO]

		If nIndOper > 1
			lTrocouAr := !mesmaArv(aOperacao, aOperacoes[nIndOper-1])
		EndIf

		If lTrocouAr
			_Super:descartaBkpDisponibilidades()
			_Super:criaBackupFerramentas()
		EndIf

		If aOperacao[ARRAY_MF_SALDO] <= 0
			Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OPER] + " foi ignorada pois nao possui saldo"},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			nIndOper++
			Loop
		EndIf

		aPeriodos := Self:alocaOperacao(aOperacao, .F., .F., .T., @lDistTudo, .T., @cRecAloc, @lDispAdc, @lCriouDisp, Nil, @lEntJunto, @dDataAlo, @nHoraAlo)

		lEfetiDisp := lEfetiDisp .Or. lCriouDisp
		If lDispAdc
			If cOrdem != cUltimaOP
				cUltimaOP := cOrdem

				Self:oOcorrens:adicionaOcorrencia(LOG_USOU_DISPONIBILIDADE_ADICIONAL,;
				                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperacao[ARRAY_MF_ID]            ,;
				                                  aOperacao[ARRAY_MF_OP]            ,;
				                                  "", "", "", "", {}                 )
			EndIf

			lDispAdc := .F.
		EndIf

		If lDistTudo
			_Super:validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecAloc, .F., lEntJunto, .F., dDataAlo, nHoraAlo)
			_Super:adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecAloc, aOperacao[ARRAY_MF_SOBREPO])
			Self:gravaParamAlocOper(aOperacao, .F., .T., .F., .F.)
		Else
			lSucesso := .F.

			Self:desfazArvore(.T., aOperacao)
			_Super:restauraBackupDisponibilidades()
			_Super:rollbackBackupFerramentas()
		EndIf

		lPrimeira := .F.
		nIndOper++
	End

	_Super:descartaBkpDisponibilidades()
	_Super:excluiBackupFerramentas()

	If lEfetiDisp
		If lSucesso
			_Super:efetivaDisponibilidadeAdicional()
		Else
			_Super:excluiDisponibilidadeAdicional()
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} mesmaArv
Retorna se duas operações estão na mesma árvore.
@type  Static Function
@author Lucas Fagundes
@since 17/08/2023
@version P12
@param 01 aOper1, Array, Array com as informações da operação 1
@param 02 aOper2, Array, Array com as informações da operação 2
@return lArvIguais, Logico, Indica se as operações estão na mesma árvore.
/*/
Static Function mesmaArv(aOper1, aOper2)
	Local cArv1      := aOper1[ARRAY_MF_ARVORE]
	Local cArv2      := aOper2[ARRAY_MF_ARVORE]
	Local lArvIguais := .F.

	lArvIguais := cArv1 == cArv2

	If lArvIguais .And. cArv1 == "" .And. cArv2 == ""
		lArvIguais := aOper1[ARRAY_MF_OP] == aOper2[ARRAY_MF_OP]
	EndIf

Return lArvIguais

/*/{Protheus.doc} getDataOperacao
Retorna a data e a hora que uma operação deve iniciar.
@author Lucas Fagundes
@since 11/08/2023
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 lEntrega , Logico  , Indica que está processando a partir da data de entrega
@param 03 lDataDaOP, Logico  , Indica que deve utilizar a data da OP.
@param 04 lDataProg, Logico  , Se não encontrar a ordem pai/filha, retorna a data da programação.
@param 05 cRecurso , Caracter, Recurso que a operação será alocada.
@return aRet, Array, Array com as datas para alocação da operação com base na operação anterior/posterior (dependendo de lEntrega):
        aRet[RET_GET_DATA_DATA        ] = Date     - Data de inicio/entrega da alocação;
        aRet[RET_GET_DATA_HORA        ] = Numerico - Hora de inicio/entrega da alocação;
        aRet[RET_GET_DATA_SOBREPOE    ] = Logico   - Indica se a operação aloca com sobreposição da operação anterior/posterior;
        aRet[RET_GET_DATA_JUNTO       ] = Logico   - Indica que a data de inicio/entrega da alocação foi calculada de forma que a operação entregue junto da anterior.
        aRet[RET_GET_DATA_DATA_SOBRE  ] = Date     - Se sobrepõe, indica a data de inicio/entrega da alocação considerando o tempo de alocação da operação/operação posterior;
        aRet[RET_GET_DATA_HORA_SOBRE  ] = Numerico - Se sobrepõe, indica a hora de inicio/entrega da alocação considerando o tempo de alocação da operação/operação posterior;
        aRet[RET_GET_DATA_FIM_AUX_DATA] = Date     - Se sobrepõe, indica a data que finaliza a operação anterior/posterior;
        aRet[RET_GET_DATA_FIM_AUX_HORA] = Numerico - Se sobrepõe, indica a hora que finaliza a operação anterior/posterior;
/*/
Method getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecurso) Class PCPA152Nivelamento
	Local aPerAux  := {}
	Local aPeriodo := {}
	Local aRet     := Array(RET_GET_DATA_TAMANHO)
	Local dData    := Nil
	Local dIniProg := CtoD(PCPConvDat((Self:oParamNiv["dataInicial"]), 3))
	Local nHora    := 0
	Local nIndNive := 0
	Local nRemocao := 0
	Local nStart   := 0
	Local nStep    := 0
	Local nTamNive := Len(Self:aAlocados)
	Local nTo      := 0

	If lEntrega .And. Self:ordemPaiNivelouPeloInicio(aOperacao) .And. _Super:getUltimaOperacaoAlocada()[ARRAY_MF_OP] != aOperacao[ARRAY_MF_OP]
		nStart := 1
		nTo    := nTamNive
		nStep  := 1

	Else
		nStart := nTamNive
		nTo    := 1
		nStep  := -1

	EndIf

	If !lDataDaOP
		For nIndNive := nStart To nTo Step nStep
			If Self:aAlocados[nIndNive][ALOCADOS_POS_OPERACAO][ARRAY_MF_OP] == aOperacao[ARRAY_MF_OP] .Or.;
			   (lEntrega  .And. ehOPPai(Self:aAlocados[nIndNive][ALOCADOS_POS_OPERACAO], aOperacao))  .Or.;
			   (!lEntrega .And. ehOPFilha(Self:aAlocados[nIndNive][ALOCADOS_POS_OPERACAO], aOperacao))

				If lEntrega
					aPeriodo := Self:aAlocados[nIndNive][ALOCADOS_POS_PERIODOS][1]
					Exit
				Else
					aPerAux := Self:aAlocados[nIndNive][ALOCADOS_POS_PERIODOS][Len(Self:aAlocados[nIndNive][ALOCADOS_POS_PERIODOS])]

					If Empty(aPeriodo) .Or. aPerAux[ARRAY_DISPONIBILIDADE_DATA] > aPeriodo[ARRAY_DISPONIBILIDADE_DATA] .Or. (aPerAux[ARRAY_DISPONIBILIDADE_DATA] == aPeriodo[ARRAY_DISPONIBILIDADE_DATA] .And. aPerAux[ARRAY_DISPONIBILIDADE_HORA_FIM] > aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM])
						aPeriodo := aPerAux
					EndIf

					//Se encontrou o período da operação anterior da mesma OP, interrompe o loop.
					If !Empty(aPeriodo) .And. Self:aAlocados[nIndNive][ALOCADOS_POS_OPERACAO][ARRAY_MF_OP] == aOperacao[ARRAY_MF_OP]
						Exit
					EndIf
				EndIf
			EndIf
		Next
	EndIf

	lDataDaOP := lDataDaOP .Or. (!lDataDaOP .And. Empty(aPeriodo))
	If lEntrega

		If lDataDaOP
			dData := aOperacao[ARRAY_MF_DTENT]
			nHora := __Hrs2Min("24:00")

			If Self:lRedSetup
				nHora := Self:buscaHoraRecurso(aOperacao, dData, nHora, .T.)
			EndIf
		Else
			dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
			nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

			If aOperacao[ARRAY_MF_REMOCAO] > 0
				nRemocao := aOperacao[ARRAY_MF_REMOCAO]

				While nRemocao > 0
					If nHora >= nRemocao
						nHora  -= nRemocao
						nRemocao := 0
					Else
						nRemocao -= nHora
						nHora  := __Hrs2Min("24:00")
						dData--
					EndIf
				End
			EndIf
		EndIf
	Else

		If lDataDaOP
			If lDataProg
				dData := dIniProg
				nHora := __Hrs2Min(Self:oParamNiv["horaInicial"])
			Else
				dData := aOperacao[ARRAY_MF_DTINI]
				nHora := __Hrs2Min("00:00")
			EndIf

			If Self:lRedSetup
				nHora := Self:buscaHoraRecurso(aOperacao, dData, nHora, .F.)
			EndIf
		Else
			dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
			nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM]
		EndIf
	EndIf

	aRet[RET_GET_DATA_SOBREPOE] := .F.
	If _Super:alocaComSobreposicao(aOperacao, lEntrega, cRecurso)
		_Super:getDataSobreposicao(aOperacao, Self:aAlocados[nIndNive], lEntrega, cRecurso, @aRet)
	EndIf

	If Self:oParamNiv["ordensAtrasadas"] .And. lDataDaOP .And. !lDataProg .And. dData < dIniProg
		dData := dIniProg
	EndIf

	aRet[RET_GET_DATA_DATA] := dData
	aRet[RET_GET_DATA_HORA] := nHora

Return aRet

/*/{Protheus.doc} desfazArvore
Desfaz as operações pendentes de efetivação.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@param 01 lLog     , Logico, Indica que deve gerar log das ordens que tiverem o nivelamento desfeito.
@param 02 aOperacao, Array , Operação que deu origem a exclusão da árvore.
@return Nil
/*/
Method desfazArvore(lLog, aOperacao) Class PCPA152Nivelamento
	Local aLogPer    := {}
	Local aOperacoes := {}
	Local aPeriodos  := {}
	Local cChaveArv  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local cOrdem     := ""
	Local cUltimaOP  := ""
	Local nIndex     := 1
	Local nIndPer    := 1
	Local nTotal     := Len(Self:aAlocados)
	Local nTotPer    := 0
	Local oOPsRemv   := JsonObject():New()
	Local oOPsLog    := Nil
	Local oLogsRmv   := JsonObject():New()

	oLogsRmv[LOG_ALOCOU_ALTERNATIVO     ] := .T.
	oLogsRmv[LOG_ALOCOU_COM_SOBREPOSICAO] := .T.
	oLogsRmv[LOG_ENTREGOU_JUNTO         ] := .T.
	oLogsRmv[LOG_OPERACAO_NAO_VALIDADE  ] := .T.
	oLogsRmv[LOG_OPERACAO_FORA_PREVISTO ] := .T.
	oLogsRmv[LOG_SEM_SOBREPOSICAO+MESMO_RECURSO      ] := .T.
	oLogsRmv[LOG_SEM_SOBREPOSICAO+TEMPO_SOBREPOSICAO ] := .T.
	oLogsRmv[LOG_SEM_SOBREPOSICAO+SEM_DISPONIBILIDADE] := .T.

	Self:oOcorrens:removeOcorrencia(cChaveArv, Nil, Nil, oLogsRmv)

	If lLog
		Self:validaDatasOp()
		Self:oOcorrens:removeOcorrencia(cChaveArv, aOperacao[ARRAY_MF_OP], LOG_DATA_ENTREGA_ALTERADA)
	EndIf

	While nIndex <= nTotal
		cOrdem    := Self:aAlocados[nIndex][ALOCADOS_POS_OPERACAO][ARRAY_MF_OP]
		nTotal--

		If cUltimaOP != cOrdem
			Self:removeOrdemNiveladaPeloInicio(cOrdem)
		EndIf
		cUltimaOP := cOrdem

		If !oOPsRemv:hasProperty(cOrdem)
			oOPsRemv[cOrdem] := .T.
		EndIf

		If Self:oLogs:logAtivo()
			aPeriodos  := Self:aAlocados[nIndex][ALOCADOS_POS_PERIODOS]
			nTotPer    := Len(aPeriodos)
			aLogPer    := Array(nTotPer+2)
			aLogPer[1] := "--- Liberados os seguintes periodos - ordem " + aOperacao[ARRAY_MF_OP] + " operacao " + aOperacao[ARRAY_MF_OPER] + " ---"
			For nIndPer := 1 To nTotPer
				aLogPer[nIndPer+1] := DToC(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_DATA])                             + ;
									" inicio " + __Min2Hrs(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + ;
									" fim "    + __Min2Hrs(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_FIM]   , .T.) + ;
									" tempo total " + cValToChar(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO]) + " minutos"
			Next nIndPer
			aLogPer[nTotPer+2] := "--------------------------------------------------------------------------"

			Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, aLogPer, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Self:aAlocados[nIndex][ALOCADOS_POS_RECURSO], cChaveArv)
			aSize(aLogPer  , 0)
			aSize(aPeriodos, 0)
		EndIf

		Self:gravaParamAlocOper(Self:aAlocados[nIndex][ALOCADOS_POS_OPERACAO], .T.)

		aDel(Self:aAlocados, nIndex)
		aSize(Self:aAlocados, nTotal)
	End

	Self:oFerramentas:descartaReservaFerramentas()

	If lLog
		aOperacoes := Self:getOperacsOrdenadas(cChaveArv, .F.)
		nTotal     := Len(aOperacoes)
		oOPsLog    := JsonObject():New()

		For nIndex := 1 To nTotal
			cOrdem := aOperacoes[nIndex][ARRAY_MF_OP]

			If cOrdem == aOperacao[ARRAY_MF_OP]

				If aOperacoes[nIndex][ARRAY_MF_OPER] == aOperacao[ARRAY_MF_OPER]
					Self:oOcorrens:adicionaOcorrencia(LOG_OPERACAO_NAO_ALOCADA            ,;
					                                  cChaveArv                           ,;
					                                  aOperacao[ARRAY_MF_ID]              ,;
					                                  aOperacao[ARRAY_MF_OP]              ,;
					                                  aOperacao[ARRAY_MF_OPER]            ,;
					                                  aOperacao[ARRAY_MF_RECURSO]         ,;
					                                  aOperacao[ARRAY_MF_ID]              ,;
					                                  aOperacao[ARRAY_MF_CTRAB]           ,;
					                                  Self:oOPsParc[aOperacao[ARRAY_MF_OP]])

					Self:oOcorrens:adicionaOcorrencia(LOG_ORDEM_REMOVIDA       ,;
					                                  cChaveArv                ,;
					                                  aOperacao[ARRAY_MF_ID]   ,;
					                                  aOperacao[ARRAY_MF_OP]   ,;
					                                  "", ""                   ,;
					                                  aOperacao[ARRAY_MF_ID]   ,;
					                                  ""                       ,;
					                                  {aOperacao[ARRAY_MF_OPER]})
				EndIf

			ElseIf oOPsRemv:hasProperty(cOrdem) .And. !oOPsLog:hasProperty(cOrdem)
				Self:oOcorrens:adicionaOcorrencia(LOG_ORDEM_REMOVIDA             ,;
				                                  cChaveArv                      ,;
				                                  aOperacoes[nIndex][ARRAY_MF_ID],;
				                                  aOperacoes[nIndex][ARRAY_MF_OP],;
				                                  "", ""                         ,;
				                                  aOperacao[ARRAY_MF_ID]         ,;
				                                  ""                             ,;
				                                  {aOperacao[ARRAY_MF_OP]}        )

			ElseIf !oOPsLog:hasProperty(cOrdem)
				Self:oOcorrens:adicionaOcorrencia(LOG_ORDEM_NAO_ALOCADA          ,;
				                                  cChaveArv                      ,;
				                                  aOperacoes[nIndex][ARRAY_MF_ID],;
				                                  aOperacoes[nIndex][ARRAY_MF_OP],;
				                                  "", ""                         ,;
				                                  aOperacao[ARRAY_MF_ID]         ,;
				                                  ""                             ,;
				                                  {aOperacao[ARRAY_MF_OP]}        )

			EndIf

			If aOperacoes[nIndex][ARRAY_PROC_STATUS_OP] == STATUS_ORDEM_EFETIVADA .And. !oOPsLog:hasProperty(cOrdem)
				Self:oOcorrens:adicionaOcorrencia(LOG_DESEFETIVA_ORDEM           ,;
				                                  cChaveArv                      ,;
				                                  aOperacoes[nIndex][ARRAY_MF_ID],;
				                                  aOperacoes[nIndex][ARRAY_MF_OP],;
				                                  "", ""                         ,;
				                                  aOperacoes[nIndex][ARRAY_MF_ID],;
				                                  "", {}                          )

			EndIf

			oOPsLog[cOrdem] := .T.
		Next

		aSize(aOperacoes, 0)
		FreeObj(oOPsLog)
	EndIf

	FreeObj(oOPsRemv)
Return Nil

/*/{Protheus.doc} efetivaOperacoesAlocadas
Efetiva o nivelamento das operações gravando os periodos em memória global.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@return Nil
/*/
Method efetivaOperacoesAlocadas() Class PCPA152Nivelamento

	Self:validaDatasOp()

	_Super:efetivaOperacoesAlocadas()

Return Nil

/*/{Protheus.doc} getOperacsOrdenadas
Retorna as operações de uma árvore de forma ordenada para processar a partir da data da programação.
@author Lucas Fagundes
@since 18/08/2023
@version P12
@param 01 cChave    , Caracter, Chave da árvore que irá buscar as operações.
@param 02 lLogaRepro, Logico  , Indica que esta buscando as operações para reprocessamento e deve gravar log de reprocessamento da ordem.
@param 03 cOpPai    , Caracter, Código da OP PAI para filtrar o retorno (somente retorna as OPs filhas)
@param 04 lOrdena   , Logico  , Indica se deve ser ordenado o array de ordens
@return aOperacoes, Array, Array com as operações para reprocessamento.
/*/
Method getOperacsOrdenadas(cChave, lLogaRepro, cOpPai, lOrdena) Class PCPA152Nivelamento
	Local aOperacoes := {}
	Local aOpersOP   := {}
	Local aOPsArv    := Self:oOPsArv[cChave]
	Local lFiltraOP  := !Empty(cOpPai)
	Local nIndex     := 1
	Local nTotal     := Len(aOPsArv)

	Default lOrdena := .T.

	/*
		Ordena as ordens do último nível para o prímeiro considerando a prioridade quando houver mais de uma ordem em um nível.
		Exemplo:
		PA - Prioridade: 01
			PI1 - Prioridade: 02
				PI2 - Prioridade: 04
					PI3 - Prioridade: 06
					PI4 - Prioridade: 07
				PI5 - Prioridade: 05
			PI6 - Prioridade: 03
		Ordena: PI3, PI4, PI2, PI5, PI1, PI6, PA
	*/
	If lOrdena
		aSort(aOPsArv,,,{|x, y| (x[ARRAY_MF_SEQPAI] == y[ARRAY_MF_SEQPAI] .And. x[ARRAY_MF_PRIOR] < y[ARRAY_MF_PRIOR]) .Or.;
	                            (x[ARRAY_MF_SEQPAI] != y[ARRAY_MF_SEQPAI] .And. x[ARRAY_MF_PRIOR] > y[ARRAY_MF_PRIOR]) })
	EndIf

	For nIndex := 1 To nTotal
		If lFiltraOP .And. aOPsArv[nIndex][ARRAY_PROC_OP_PAI] != cOpPai
			Loop
		EndIf

		aOpersOP := _Super:getOperacoesOrdem(aOPsArv[nIndex][ARRAY_MF_OP], .T.)

		If lLogaRepro
			Self:oOcorrens:adicionaOcorrencia(LOG_ALOCADA_PELA_DATA_PROG, cChave, aOPsArv[nIndex][ARRAY_MF_ID], aOPsArv[nIndex][ARRAY_MF_OP])
		EndIf

		appendArr(aOperacoes, aOpersOP)
	Next

Return aOperacoes

/*/{Protheus.doc} atualizaPercentual
Atualiza o percentual da etapa de nivelamento.
@author Lucas Fagundes
@since 18/08/2023
@version P12
@param 01 nQtdProc, Numerico, Quantidade de registros processados
@param 02 nTotProc, Numerico, Quantidade total de registros para processar
@return Nil
/*/
Method atualizaPercentual(nQtdProc, nTotProc) Class PCPA152Nivelamento
	Local nAtuPerct := 0

	nAtuPerct := (nQtdProc * 100) / nTotProc
	_Super:gravaPercentual(CHAR_ETAPAS_NIVELAMENTO, nAtuPerct)

Return Nil

/*/{Protheus.doc} ehOPPai
Retorna se uma ordem é pai de outra a partir de duas operações.
@type  Static Function
@author Lucas Fagundes
@since 04/09/2023
@version P12
@param 01 aOper1, Array, Array com as informações da operação 1.
@param 02 aOper2, Array, Array com as informações da operação 2.
@return lEhPai, Logico, Indica se a ordem da operação 1 é pai da ordem da operação 2.
/*/
Static Function ehOPPai(aOper1, aOper2)
	Local lEhPai := .F.

	If !Empty(aOper2[ARRAY_MF_SEQPAI])
		lEhPai := SubStr(aOper1[ARRAY_MF_OP], _nTamC2Num+_nTamC2Ite+1, _nTamC2Seq) == aOper2[ARRAY_MF_SEQPAI]
	EndIf

Return lEhPai

/*/{Protheus.doc} ordemPaiNivelouPeloInicio
Retorna se a ordem pai foi nivelada pela data de inicio.
Quando executa com priorização por data de inicio a primeira ordem da árvore será nivelada pela data de inicio e as intermediarios pela data de entrega.
@author Lucas Fagundes
@since 15/09/2023
@version P12
@param aOperacao, Array, Ordem que irá verificar se a ordem pai nivelou pelo inicio
@return lNivelou, Logico, Indica se a ordem pai foi nivelada pela data de inicio.
/*/
Method ordemPaiNivelouPeloInicio(aOperacao) Class PCPA152Nivelamento
	Local lNivelou := .F.
	Local cOpPai   := ""

	If !Empty(aOperacao[ARRAY_MF_SEQPAI])
		cOpPai := Stuff(aOperacao[ARRAY_MF_OP], _nTamC2Num+_nTamC2Ite+1, _nTamC2Seq, aOperacao[ARRAY_MF_SEQPAI])

		lNivelou := Self:oJsInicio:hasProperty(cOpPai)
	EndIf

Return lNivelou

/*/{Protheus.doc} iniStatic
Inicia as váriaveis estáticas.
@type  Static Function
@author Lucas Fagundes
@since 20/09/2023
@version P12
@return Nil
/*/
Static Function iniStatic()

	If _nTamC2Num == Nil
		_nTamC2Num := GetSx3Cache("C2_NUM", "X3_TAMANHO")
		_nTamC2Ite := GetSx3Cache("C2_ITEM", "X3_TAMANHO")
		_nTamC2Seq := GetSx3Cache("C2_SEQUEN", "X3_TAMANHO")
	EndIf

Return Nil

/*/{Protheus.doc} adicionaOrdemNiveladaPeloInicio
Adiciona uma ordem no json que controla as ordens pais que foram niveladas pela data de início.
@author Lucas Fagundes
@since 20/09/2023
@version P12
@param cOrdem, Caracter, Numero da ordem que será adicionada.
@return Nil
/*/
Method adicionaOrdemNiveladaPeloInicio(cOrdem) Class PCPA152Nivelamento

	Self:oJsInicio[cOrdem] := .T.

Return Nil

/*/{Protheus.doc} removeOrdemNiveladaPeloInicio
Remove uma ordem do json que controla as ordens pais que nivelaram pela data de início.
@author Lucas Fagundes
@since 20/09/2023
@version P12
@param cOrdem, Caracter, Numero da ordem que será removida.
@return Nil
/*/
Method removeOrdemNiveladaPeloInicio(cOrdem) Class PCPA152Nivelamento

	If Self:oJsInicio:hasProperty(cOrdem)
		Self:oJsInicio:delName(cOrdem)
	EndIf

Return Nil

/*/{Protheus.doc} ordemNivelaPelaDataDeInicio
Verifica se a operação da ordem deve ser nivelada pela data de inicio ou entrega.
Quando executa com priorização por data de inicio a primeira ordem da árvore será nivelada pela data de inicio e as intermediarios pela data de entrega.
@author Lucas Fagundes
@since 20/09/2023
@version P12
@param aOperacao, Array, Array com as informações da ordem
@return lNivela, Logico, Retorna se a ordem será nivelada ou foi nivelada pela da de inicio.
/*/
Method ordemNivelaPelaDataDeInicio(aOperacao) Class PCPA152Nivelamento

Return Self:oParamNiv["priorizacao"] == PARAM_PRIORIZACAO_DATA_INICIO .And. Empty(aOperacao[ARRAY_MF_SEQPAI])

/*/{Protheus.doc} ehOPFilha
Retorna se uma OP é filha de outra a partir de duas operações.
@type  Static Function
@author Lucas Fagundes
@since 26/09/2023
@version P12
@param 01 aOper1, Array, Array com as informações da ordem 1.
@param 02 aOper2, Array, Array com as informações da ordem 2.
@return lFilha, Logico, Indica se a op do parametro oper1 é filha da op do parametro oper2.
/*/
Static Function ehOPFilha(aOper1, aOper2)

Return aOper1[ARRAY_PROC_OP_PAI] == aOper2[ARRAY_MF_OP]

/*/{Protheus.doc} validaDatasOp
Percorre as operações niveladas gerando log de data alterada.
@author Lucas Fagundes
@since 30/01/2024
@version P12
@return Nil
/*/
Method validaDatasOp() Class PCPA152Nivelamento
	Local aOperacao  := {}
	Local aPeriodos  := {}
	Local dDatFimPer := Nil
	Local dDatIniPer := Nil
	Local nIndex     := 0
	Local nTotal     := Len(Self:aAlocados)

	For nIndex := 1 To nTotal
		aOperacao := Self:aAlocados[nIndex][ALOCADOS_POS_OPERACAO]
		aPeriodos := Self:aAlocados[nIndex][ALOCADOS_POS_PERIODOS]

		If dDatIniPer == Nil .Or. dDatIniPer > aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
			dDatIniPer := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
		EndIf

		If dDatFimPer == Nil .Or. dDatFimPer < aPeriodos[Len(aPeriodos)][ARRAY_DISPONIBILIDADE_DATA]
			dDatFimPer := aPeriodos[Len(aPeriodos)][ARRAY_DISPONIBILIDADE_DATA]
		EndIf

		If nIndex == nTotal .Or. aOperacao[ARRAY_MF_OP] != Self:aAlocados[nIndex+1][ALOCADOS_POS_OPERACAO][ARRAY_MF_OP]
			_Super:validaDatasOp(aOperacao, dDatIniPer, dDatFimPer)

			dDatIniPer := Nil
			dDatFimPer := Nil
		EndIf
	Next

Return Nil

/*/{Protheus.doc} executaReducaoSetup
Inicia o processamento da redução de SETUP das operações.

@author lucas.franca
@since 17/05/2024
@version P12
@return lSucesso, Logic, retorna se completou o processamento com sucesso
/*/
Method executaReducaoSetup() Class PCPA152Nivelamento
	Local aRecursos  := Self:oDispRecur:GetNames()
	Local cJsIndcAlo := ""
	Local lSucesso   := .T.
	Local nIndRec    := 1
	Local nTotRec    := Len(aRecursos)

	Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, {"Iniciando processo de reducao de setup."})

	Self:preparaOperacoes()

	_Super:gravaValorGlobal("REDUZ_SETUP_PROCESSADOS", 0)

	//Identifica os recursos e árvores que possuem setup duplicado
	While _Super:permiteProsseguir() .And. nIndRec <= nTotRec
		cJsIndcAlo := _Super:getIndicesComAlocacao(aRecursos[nIndRec]):toJson()
		_Super:delegar("P152ISetup", Self:cProg, aRecursos[nIndRec], Self:oDispRecur[aRecursos[nIndRec]], cJsIndcAlo)
		nIndRec++
	End

	//Aguarda término das threads
	While _Super:permiteProsseguir() .And. nTotRec > _Super:retornaValorGlobal("REDUZ_SETUP_PROCESSADOS")
		Sleep(100)
	End

	//Percorre e realoca as operações
	If _Super:permiteProsseguir()
		Self:ajustaAlocacoesRecursos()

		//Verifica necessidade de ajustar ocorrências
		Self:ajustaOcorrencias()
	EndIf

	_Super:gravaPercentual(CHAR_ETAPAS_REDUZ_SETUP, 100)

	Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, {"Termino do processo de reducao de setup."})

	lSucesso := _Super:permiteProsseguir()
	aSize(aRecursos, 0)
Return lSucesso

/*/{Protheus.doc} identificaSetupDuplicado
Faz a busca por setups duplicados em um recurso

@author lucas.franca
@since 17/05/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso para remover o SETUP.
@param 02 aDispRecur, Array   , disponibilidades do recurso.
@param 03 cAlocRec  , Caracter, Json com os indices alocados.
@return Nil
/*/
Method identificaSetupDuplicado(cRecurso, aDispRecur, cAlocRec) Class PCPA152Nivelamento
	Local aAlocAnt   := Nil
	Local aDisp      := Nil
	Local aFerrams   := Nil
	Local aOperacao  := Nil
	Local nIndDisp   := 0
	Local nIndFerra  := 0
	Local nIndTempos := 0
	Local nTotAloc   := 0
	Local nTotDisp   := Len(aDispRecur)
	Local nTotFerra  := 0
	Local oArvores   := JsonObject():New()
	Local oFerrame   := JsonObject():New()
	Local oIndAloc   := JsonObject():New()

	oIndAloc:fromJson(cAlocRec)

	Self:lDecresce := .T. //Propriedade da classe TempoOperacao, utilizado internamente ao chamar o método getAlocAnterior
	Self:oDispRecur[cRecurso] := aDispRecur
	_Super:setIndicesComAlocacao(cRecurso, oIndAloc)

	For nIndDisp := 1 To nTotDisp
		aDisp    := aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		nTotAloc := Len(aDisp)

		For nIndTempos := 1 To nTotAloc

			If aDisp[nIndTempos][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_SETUP
				Loop
			EndIf

			aOperacao := _Super:getOperacao(aDisp[nIndTempos][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM], aDisp[nIndTempos][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID])
			aAlocAnt  := Array(ARRAY_OPER_ANTERIOR_TAMANHO)
			_Super:buscaAlocAnterior(@aAlocAnt, cRecurso, nIndDisp, nIndTempos)

			//Produto anterior é igual ao produto atual, posso remover este setup.
			If Self:produtoAlocacaoAnteriorIgual(aAlocAnt, aDispRecur, aOperacao[ARRAY_PROC_PRODUTO])

				oArvores[aOperacao[ARRAY_PROC_CHAVE_ARVORE]] := .T.

				If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
					aFerrams  := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
					nTotFerra := Len(aFerrams)

					For nIndFerra := 1 To nTotFerra
						oFerrame[aFerrams[nIndFerra][ARRAY_HZJ_FERRAM]] := .T.
					Next
				EndIf
			EndIf

			aAlocAnt := Nil
		Next nIndTempos

		aOperacao := Nil
		aDisp     := Nil
		aFerrams  := Nil
	Next nIndDisp

	Self:gravaArvoreSetupDuplicado(cRecurso, oArvores, oFerrame)

	_Super:gravaValorGlobal("REDUZ_SETUP_PROCESSADOS", 1, .T., .T.)

	FreeObj(oArvores)

	Self:oDispRecur:delName(cRecurso)
	aSize(aDispRecur, 0)

	Self:oIndcCAloc:delName(cRecurso)
	FreeObj(oIndAloc)
Return

/*/{Protheus.doc} gravaArvoreSetupDuplicado
Grava as globais para identificar recursos e árvores que precisam realocar as operações devido ao setup duplicado.

@author lucas.franca
@since 21/05/2024
@version P12
@param 01 cRecurso, Caracter, Código do recurso
@param 02 oArvores, Object  , Objeto com os IDs de árvores que tiveram setup removido.
@param 03 oFerrame, Object  , Objeto com os IDs de ferramentas que tiveram setup removido.
@return Nil
/*/
Method gravaArvoreSetupDuplicado(cRecurso, oArvores, oFerrame) Class PCPA152Nivelamento
	Local aArvores := oArvores:getNames()
	Local aFerrame := oFerrame:getNames()

	If Len(aArvores) > 0
		_Super:adicionaListaGlobal("SETUP_ALTERADOS", "RECURSOS",    cRecurso, .T., 1)
		_Super:adicionaListaGlobal("SETUP_ALTERADOS", "ARVORES",     aArvores, .T., 2)
		_Super:adicionaListaGlobal("SETUP_ALTERADOS", "FERRAMENTAS", aFerrame, .T., 2)
	EndIf

	aSize(aArvores, 0)
Return Nil

/*/{Protheus.doc} removeAlocacaoDisponibilidade
Faz a remoção das alocações de setup do array de disponibilidade do recurso.

@author lucas.franca
@since 20/05/2024
@version P12
@param 01 aDispRecur, Array   , disponibilidades do recurso
@param 02 nIndDisp  , Numeric , Índice do array de disponibilidades
@param 03 nRemove   , Numeric , Índice de tempos para remoção
@param 04 oIndices  , Object  , Objeto com os índices de disponibilidades do recurso
@return Nil
/*/
Method removeAlocacaoDisponibilidade(aDispRecur, nIndDisp, nRemove, oIndices) Class PCPA152Nivelamento
	Local aDisp    := aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
	Local cData    := DtoS(aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_DATA])

	If aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_ILIMITADO]
		aDel(aDisp, nRemove)
		aSize(aDisp, Len(aDisp) - 1)

	Else
		aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_TEMPO] += aDisp[nRemove][ARRAY_DISPONIBILIDADE_TEMPO]

		aDisp[nRemove][ARRAY_DISPONIBILIDADE_TIPO] := VM_TIPO_DISPONIVEL
		aDisp[nRemove][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := ""
		aDisp[nRemove][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := ""

		//Ajusta as posições disponíveis dos índices deste recurso.
		If oIndices[cData][ARRAY_INDICE_DISP_FINISH] < nIndDisp
			oIndices[cData][ARRAY_INDICE_DISP_FINISH] := nIndDisp
		EndIf

		If oIndices[cData][ARRAY_INDICE_DISP_START] == 0 .Or. oIndices[cData][ARRAY_INDICE_DISP_START] > nIndDisp
			oIndices[cData][ARRAY_INDICE_DISP_START] := nIndDisp
		EndIf
	EndIf

	aDisp := Nil

Return Nil

/*/{Protheus.doc} produtoAlocacaoAnteriorIgual
Verifica se o produto da alocação anterior é igual
ao produto da alocação atual.

@author lucas.franca
@since 17/05/2024
@version P12
@param 01 aAlocAnt  , Array   , informações da alocação anterior
@param 02 aDispRecur, Array   , dados de alocação do recurso
@param 03 cProduto  , Caracter, Código do produto da alocação atual
@return lIgual, Logic, Identifica se o produto da alocação anterior é igual ao produto da alocação atual
/*/
Method produtoAlocacaoAnteriorIgual(aAlocAnt, aDispRecur, cProduto) Class PCPA152Nivelamento
	Local aAloc     := Nil
	Local aOperAloc := Nil
	Local lIgual    := .F.
	Local nIndAnt   := 0
	Local nTempoAnt := 0

	If aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR]
		nIndAnt   := aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_DISP  ]
		nTempoAnt := aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS]
		aAloc     := aDispRecur[nIndAnt][ARRAY_DISP_RECURSO_DISPONIBILIDADE][nTempoAnt]

		If aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO]
			lIgual := aScan(aDispRecur[nIndAnt][ARRAY_DISP_RECURSO_PRODUTOS_EFETIVADOS], {|x| x != cProduto}) == 0
		Else
			aOperAloc := _Super:getOperacao(aAloc[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM], aAloc[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID])

			lIgual := aOperAloc[ARRAY_PROC_PRODUTO] == cProduto
		EndIf
	EndIf

Return lIgual

/*/{Protheus.doc} ajustaAlocacoesRecursos
Ajusta as operações, árvores e recursos que possuem setups duplicados

@author lucas.franca
@since 23/05/2024
@version P12
@return Nil
/*/
Method ajustaAlocacoesRecursos() Class PCPA152Nivelamento
	Local aFerrams   := {}
	Local aOperacao  := Nil
	Local cArvore    := ""
	Local lDataDaOP  := .F.
	Local lDataProg  := .F.
	Local lEntrega   := .F.
	Local lInicio    := .F.
	Local lMoveuOper := .T.
	Local nIndex     := 0
	Local nIndFerra  := 0
	Local nLoop      := 0
	Local nTotal     := Len(Self:aOperacoes)
	Local nTotFerra  := 0
	Local oAlterados := JsonObject():New()
	Local oArvores   := JsonObject():New()
	Local oFerrament := JsonObject():New()
	Local oRecursos  := JsonObject():New()

	Self:lRedSetup := .T.
	lMoveuOper     := Self:carregaArvoresParaReprocessar(@oArvores, @oRecursos, @oFerrament)

	oAlterados["arvores"    ] := JsonObject():New()
	oAlterados["recursos"   ] := JsonObject():New()
	oAlterados["ordens"     ] := JsonObject():New()
	oAlterados["ferramentas"] := JsonObject():New()

	While lMoveuOper .And. _Super:permiteProsseguir()
		lMoveuOper := .F.
		nIndex     := 1
		nLoop++

		_Super:setExecucaoReducaoSetup(nLoop)
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
		                    {"Loop reducao setup: " + cValToChar(nLoop) ,;
		                     "Processando arvores: " + ArrTokStr(oArvores:getNames(), ","),;
		                     "Processando recursos: " + ArrTokStr(oRecursos:getNames(), ","),;
		                     "Processando ferramentas: " + ArrTokStr(oFerrament:getNames(), ",")})

		While nIndex <= nTotal .And. _Super:permiteProsseguir()

			aOperacao := Self:aOperacoes[nIndex]
			cArvore   := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
			Self:recuperaParamAlocOper(aOperacao, @lDataProg, @lEntrega, @lDataDaOP, @lInicio)

			If Self:avaliaOperacao(aOperacao, @oRecursos, @oArvores, @oAlterados, lInicio, @oFerrament)

				If Self:realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP)
					lMoveuOper := .T.

					//Atualiza JSON de controle para adicionar, caso não exista, o recurso/arvore.
					oArvores[cArvore] := .T.
					oRecursos[aOperacao[ARRAY_MF_RECURSO]] := .T.

					oAlterados["recursos"][aOperacao[ARRAY_MF_RECURSO ]] := .T.
					oAlterados["ordens"  ][aOperacao[ARRAY_MF_OP      ]] := .T.
					If !lDataProg
						oAlterados["arvores"][cArvore] := .T.
					EndIf

					If lInicio //Se aloca por início já adiciona a OP PAI para reprocessar.
						oAlterados["ordens"][aOperacao[ARRAY_PROC_OP_PAI]] := .T.
					EndIf

					If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
						aFerrams  := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
						nTotFerra := Len(aFerrams)

						For nIndFerra := 1 To nTotFerra
							oAlterados["ferramentas"][aFerrams[nIndFerra][ARRAY_HZJ_FERRAM]] := .T.
						Next

						aFerrams := {}
					EndIf
				EndIf

			EndIf

			nIndex++
		End

		//Atualiza objetos de controle para validar árvores/recursos que precisam ser reprocessados
		//para reprocessar somente o que teve alteração no último loop.
		oArvores:set(oAlterados["arvores"])
		oRecursos:set(oAlterados["recursos"])
		oFerrament:set(oAlterados["ferramentas"])

		oAlterados["arvores"    ]:fromJson('{}')
		oAlterados["recursos"   ]:fromJson('{}')
		oAlterados["ordens"     ]:fromJson('{}')
		oAlterados["ferramentas"]:fromJson('{}')
	End

	Self:lRedSetup := .F.

Return Nil

/*/{Protheus.doc} avaliaOperacao
Verifica se uma operação deve ter o seu reprocessamento avaliado

@author lucas.franca
@since 10/06/2024
@version P12
@param 01 aOperacao , Array , informações da operação (SMF).
@param 02 oRecursos , Object, json com os recursos em reprocessamento
@param 03 oArvores  , Object, json com as árvores em reprocessamento
@param 04 oAlterados, Object, json com as OPS alteradas
@param 05 lInicio   , Logic , Indica que a operação aloca pelo início
@param 06 oFerrament, Object, json com as ferramentas em reprocessamento
@return lAvalia, Logic, Retorna se houve alteração na alocação do recurso.
/*/
Method avaliaOperacao(aOperacao, oRecursos, oArvores, oAlterados, lInicio, oFerrament) Class PCPA152Nivelamento
	Local aFerrams  := {}
	Local cArvore   := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local lAvalia   := oRecursos:hasProperty( aOperacao[ARRAY_MF_RECURSO] )
	Local nIndeFer  := 0
	Local nTotFerr  := 0

	If !lAvalia .And. Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
		aFerrams := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
		nTotFerr := Len(aFerrams)

		For nIndeFer := 1 To nTotFerr
			If oFerrament:hasProperty(aFerrams[nIndeFer][ARRAY_HZJ_FERRAM])
				lAvalia := .T.
				Exit
			EndIf
		Next

		aFerrams := {}
	EndIf

	lAvalia := lAvalia .Or. (oArvores:hasProperty( cArvore ) .And. oAlterados["ordens"]:hasProperty(aOperacao[ARRAY_MF_OP]))

	If !lAvalia .And. oArvores:hasProperty( cArvore )

		If lInicio == .F.
			lAvalia := oAlterados["ordens"]:hasProperty(aOperacao[ARRAY_PROC_OP_PAI])
		EndIf
	EndIf

Return lAvalia

/*/{Protheus.doc} realocaOperacao
Aloca novamente a operação considerando as novas disponibilidades após remover algum setup.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, informações da operação (SMF) para realocação.
@param 02 lInicio  , Logic, indica se a operação aloca por início
@param 03 lDataProg, Logic, Indica se aloca por data da programação
@param 04 lEntrega , Logic, Indica se aloca por data de entrega
@param 05 lDataDaOP, Logic, Indica se usa a data da OP
@return lAlterou, Logic, Retorna se houve alteração na alocação do recurso.
/*/
Method realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP) Class PCPA152Nivelamento
	Local aAlocado  := Nil
	Local aAlocOrig := Nil
	Local aNovaAloc := Nil
	Local aPeriodos := Nil
	Local dDataAloc := Nil
	Local lAlterou  := .F.
	Local lContinua := .T.
	Local lDistTudo := .F.
	Local lEntJunto := .F.
	Local nHoraAloc := 0

	If Self:oLogs:logAtivo()
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
		                    {"Avaliando realocacao. Ordem: "     + aOperacao[ARRAY_MF_OP    ] +;
		                                         ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
		                                         ", Recurso: "  + aOperacao[ARRAY_MF_RECURSO]},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	//Cria BKP das alocações atuais desta operação
	aAlocado := Self:getAlocacaoSVM(aOperacao)

	If Empty(aAlocado)
		//Não tenta alocar operações que não foram alocadas inicialmente.
		lContinua := .F.
	EndIf

	If lContinua
		//Recupera os parâmetros que devem ser utilizados para executar a alocação da operação
		Self:carregaJaNivelados(aOperacao, lInicio)

		//Verifica se a operação terá alguma mudança.
		lContinua := Self:verificaMudancaOperacao(aAlocado, lInicio, aOperacao, lDataDaOP, lDataProg)

		If lContinua
			aAlocOrig := Array(ALOCACAO_ORIGINAL_TAMANHO)
			aAlocOrig[ALOCACAO_ORIGINAL_INI_DATA] := aAlocado[1][ARRAY_VM_DATA]
			aAlocOrig[ALOCACAO_ORIGINAL_INI_HORA] := __Hrs2Min(aAlocado[1][ARRAY_VM_INICIO])
			aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA] := aTail(aAlocado)[ARRAY_VM_DATA]
			aAlocOrig[ALOCACAO_ORIGINAL_FIM_HORA] := __Hrs2Min(aTail(aAlocado)[ARRAY_VM_FIM])

			//Remove a alocação desta operação
			Self:removeOperacao(aAlocado, aOperacao)
		Else
			Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, {"Operacao nao sera realocada"}, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf
	EndIf

	If lContinua
		//Aloca novamente a operação e verifica se houve mudança na alocação.
		Self:cEtapaLog := CHAR_ETAPAS_REDUZ_SETUP
		aPeriodos := Self:alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, @lDistTudo, .T., Nil, Nil, Nil, aAlocOrig, @lEntJunto, @dDataAloc, @nHoraAloc)
		aNovaAloc := _Super:geraPeriodosOperacao(aOperacao, aPeriodos)
		lAlterou  := Self:alterouAlocacao(aAlocado, aNovaAloc)

		//Se alterou a alocação substitui os dados da SVM e oDispRecur. Caso contrário recupera o BKP com a alocação original.
		If lAlterou
			Self:substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc)

			//Registra esta árvore como alterada para avaliar as ocorrências ao término do processo.
			Self:registraRealocado(aOperacao)
		EndIf

		aSize(aNovaAloc, 0)
		aSize(aPeriodos, 0)
		aSize(aAlocOrig, 0)
	EndIf

	aSize(aAlocado , 0)
Return lAlterou

/*/{Protheus.doc} verificaMudancaOperacao
Verifica se a operação possui alguma alteração que faça necessário realocar.

@author lucas.franca
@since 28/06/2024
@version P12
@param 01 aAlocado , Array, Dados da alocação original da operação
@param 02 lInicio  , Logic, Indica se a operação aloca pelo início
@param 03 aOperacao, Array, Dados da operação
@param 04 lDataDaOP, Logic, Indica se usa a data da OP
@param 05 lDataProg, Logic, Indica se aloca por data da programação
@return lMudou, Logic, Indica se houve alguma mudança na operação
/*/
Method verificaMudancaOperacao(aAlocado, lInicio, aOperacao, lDataDaOP, lDataProg) Class PCPA152Nivelamento
	Local aAlocAnt   := {}
	Local aDataLog   := Nil
	Local aDatas     := {}
	Local aIndices   := {}
	Local dData      := Nil
	Local dFimOper   := aTail(aAlocado)[ARRAY_VM_DATA]
	Local dIniOper   := aAlocado[1][ARRAY_VM_DATA]
	Local lEntrega   := !lInicio
	Local lIgual     := .F.
	Local lMudou     := .F.
	Local lRecIlimi  := .F.
	Local lSetupAloc := aAlocado[1][ARRAY_VM_TIPO] == VM_TIPO_SETUP
	Local nHora      := 0
	Local nHrFimOper := __Hrs2Min(aTail(aAlocado)[ARRAY_VM_FIM])
	Local nHrIniOper := __Hrs2Min(aAlocado[1][ARRAY_VM_INICIO])
	Local oDisp      := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
	lRecIlimi := oDisp:recursoIlimitado(aOperacao[ARRAY_MF_RECURSO])

	If _Super:alocaComSobreposicao(aOperacao, lEntrega, aOperacao[ARRAY_MF_RECURSO])
		lMudou := .T.
	Else
		aDatas := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, aOperacao[ARRAY_MF_RECURSO])

		dData := aDatas[RET_GET_DATA_DATA]
		nHora := aDatas[RET_GET_DATA_HORA]
	EndIf

	If !lMudou .And. ((lInicio  .And. (dData <> dIniOper .Or. nHora <> nHrIniOper )) .Or. ; //Aloca por início e irá alocar no mesmo horário anterior
	                  (lEntrega .And. (dData <> dFimOper .Or. nHora <> nHrFimOper )))        //Aloca por entrega e irá entregar no mesmo horário anterior

		//Verifica se entre a nova data/hora, e a data/hora original da operação
		//existe alguma disponibilidade que possa ser utilizada.
		lMudou := lRecIlimi .Or. Self:existeDisponibilidade(aOperacao, lEntrega, dData, nHora, dIniOper, nHrIniOper, dFimOper, nHrFimOper)

		If Self:oLogs:logAtivo() .And. lMudou
			If lInicio
				aDataLog := {"inicio", DtoC(dIniOper), __Min2Hrs(nHrIniOper, .T.)}
			Else
				aDataLog := {"entrega", DtoC(dFimOper), __Min2Hrs(nHrFimOper, .T.)}
			EndIf

			Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
			                    {Replicate("-",70),;
			                     "Data/hora " + aDataLog[1] + " diferente." +;
			                     " Ordem: "    + aOperacao[ARRAY_MF_OP     ] +;
			                    ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
			                    ", Recurso: "  + aOperacao[ARRAY_MF_RECURSO],;
			                    " Alocando por " + aDataLog[1] +;
			                    ". Data/hora original da operacao " + aDataLog[2] + " - " + aDataLog[3] +;
			                    ". Nova data/hora da operacao " + DtoC(dData) + " - " + __Min2Hrs(nHora, .T.),;
			                    Replicate("-",70)  },;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])

			aSize(aDataLog, 0)
		EndIf
	EndIf

	//Se não mudou a hora início ou fim, mas a operação possui setup, verifica se vai precisar fazer alguma mudança no setup já alocado.
	If !lMudou .And. aOperacao[ARRAY_MF_SETUP] > 0 .And. !lRecIlimi

		//Ver alocação anterior se é do mesmo produto.
		aIndices := Self:recuperaIndicesTemposOperacao(aOperacao)
		aAlocAnt := Array(ARRAY_OPER_ANTERIOR_TAMANHO)
		_Super:buscaAlocAnterior(@aAlocAnt, aOperacao[ARRAY_MF_RECURSO], aIndices[1][INDICE_TEMPOS_POS_DISPONIBILIDADE], aIndices[1][INDICE_TEMPOS_POS_TEMPOS])

		lIgual := Self:produtoAlocacaoAnteriorIgual(aAlocAnt, Self:oDispRecur[aOperacao[ARRAY_MF_RECURSO]], aOperacao[ARRAY_PROC_PRODUTO])
		aSize(aAlocAnt, 0)

		If (lIgual  .And. lSetupAloc ) .Or.; //(Produto da alocação anterior é igual E operação atual está com setup alocado) OU
		   (!lIgual .And. !lSetupAloc)       //(Produto da alocação anterior é diferente E operação atual NÃO está com setup alocado)

			lMudou := .T.

			If Self:oLogs:logAtivo()

				If lIgual
					aDataLog := {"igual", " "}
				Else
					aDataLog := {"diferente", " NAO "}
				EndIf

				Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
				               {Replicate("-",70),;
				               "Necessario alteracao da alocacao do SETUP." +;
				                " Ordem: "    + aOperacao[ARRAY_MF_OP     ] +;
				               ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
				               ", Recurso: "  + aOperacao[ARRAY_MF_RECURSO],;
				               " Alocacao anterior possui produto " + aDataLog[1] +;
				               " e esta operacao" + aDataLog[2] + "possui setup alocado ",;
				               Replicate("-",70)},;
				               aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])

				aSize(aDataLog, 0)
			EndIf
		EndIf
	EndIf

	//Se não mudou mas está programando permitindo quebra da alocação e o recurso não for ilimitado,
	//verifica se existe algum período livre entre o início e o término dessa operação.
	If !lMudou .And. Self:oParamNiv["quebraOperacoes"] .And. !lRecIlimi
		If Empty(aIndices)
			aIndices := Self:recuperaIndicesTemposOperacao(aOperacao)
		EndIf
		If Self:existeTempoDisponivel(aOperacao, aIndices)
			lMudou := .T.

			Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
			               {"Existe periodo disponivel entre o inicio/fim da alocacao da operacao." +;
			                 " Ordem: "    + aOperacao[ARRAY_MF_OP     ] +;
			                ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
			                ", Recurso: "  + aOperacao[ARRAY_MF_RECURSO]},;
			                aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf
	EndIf

	aSize(aIndices, 0)

Return lMudou

/*/{Protheus.doc} existeDisponibilidade
Verifica se existe disponibilidade entre a data/hora onde a operação pode iniciar e
a data/hora onde a operação já está alocada.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao , Array  , informações da operação (SMF).
@param 02 lEntrega  , Logic  , indica se a operação é alocada por início ou por entrega
@param 03 dDataDisp , Date   , data disponível para iniciar a alocação da operação
@param 04 nHoraDisp , Numeric, hora disponível para iniciar a alocação da operação
@param 05 dIniOper  , Date   , data de início (já alocado) da operação
@param 06 nHrIniOper, Numeric, hora de início (já alocado) da operação
@param 07 dFimOper  , Date   , data de término (já alocado) da operação
@param 08 nHrFimOper, Numeric, hora de término (já alocado) da operação
@return lMudou, Logic, indica se haverá mudança entre a hora já alocada e a hora disponível para alocar
/*/
Method existeDisponibilidade(aOperacao, lEntrega, dDataDisp, nHoraDisp, dIniOper, nHrIniOper, dFimOper, nHrFimOper) Class PCPA152Nivelamento
	Local dData      := Nil
	Local dIniBusca  := dDataDisp
	Local dFimBusca  := dIniOper
	Local lEncontrou := .F.
	Local lMudou     := .F.
	Local nNewHora   := nHoraDisp
	Local nHoraOper  := nHrIniOper
	Local nStep      := 1

	If lEntrega
		dFimBusca := dFimOper
		nHoraOper := nHrFimOper
		nStep     := -1
	EndIf

	For dData := dIniBusca To dFimBusca Step nStep
		nNewHora := Self:buscaHoraRecurso(aOperacao, dData, nNewHora, lEntrega, @lEncontrou)
		If lEncontrou
			lMudou := dData <> dFimBusca .Or. nNewHora <> nHoraOper
			Exit
		EndIf

		If lEntrega
			nNewHora := __Hrs2Min("24:00")
		Else
			nNewHora := __Hrs2Min("00:00")
		EndIf

	Next dData

Return lMudou

/*/{Protheus.doc} substituiAlocacao
Faz a substituição da alocação do recurso.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array  , informações da operação (SMF).
@param 02 aNovaAloc, Array  , nova alocação da operação (SVM).
@param 03 aAlocado , Array  , alocação anterior da operação (SVM).
@param 04 lEntJunto, Lógico , Indica se a sobreposição da operação alocou junto da anterior.
@param 05 dDataAloc, Date   , Data de alocação da operação.
@param 06 nHoraAloc, Numeric, Hora de alocação da operação.
@return Nil
/*/
Method substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc) Class PCPA152Nivelamento
	Local aSVM       := Nil
	Local cChave     := ""
	Local cChaveSVM  := _Super:chaveListaDadosSVM(aOperacao)
	Local nIndex     := 0
	Local nRemovidos := 0
	Local nTotal     := 0
	Local oSeqSVM    := Nil

	If Self:oLogs:logAtivo()
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, logAlter(aOperacao, aAlocado, aNovaAloc, lEntrega), aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	//Remove da global os dados da operação alocada
	aSVM   := _Super:retornaListaGlobal(LISTA_DADOS_SVM, cChaveSVM)
	nTotal := Len(aSVM)

	For nIndex := nTotal To 1 Step -1
		If aSVM[nIndex][ARRAY_VM_ID] == aOperacao[ARRAY_MF_ID]
			aDel(aSVM, nIndex)
			nRemovidos++
		EndIf
	Next nIndex

	aSize(aSVM, nTotal-nRemovidos)

	//Adiciona os dados da nova alocação, e salva na global.
	appendArr(aSVM, aNovaAloc)

	_Super:adicionaListaGlobal(LISTA_DADOS_SVM, cChaveSVM, aSVM, .F.)

	Self:validaOcorrenciasAlocacao(aOperacao, aPeriodos, aOperacao[ARRAY_MF_RECURSO], lEntrega, lEntJunto, .T., dDataAloc, nHoraAloc)
	Self:oOcorrens:localToGlobal(.T.)

	If Self:oParamNiv["utilizaFerramentas"]
		oSeqSVM := JsonObject():New()
		nTotal  := Len(aSVM)

		For nIndex := 1 To nTotal
			cChave := aOperacao[ARRAY_MF_ID] + DToS(aSVM[nIndex][ARRAY_VM_DATA]) + aSVM[nIndex][ARRAY_VM_INICIO] + aSVM[nIndex][ARRAY_VM_FIM]
			oSeqSVM[cChave] := aSVM[nIndex][ARRAY_VM_SEQ]
		Next

		Self:oFerramentas:removePeriodosEfetivados(aOperacao[ARRAY_MF_ID])
		Self:oFerramentas:efetivaFerramentas(oSeqSVM)

		oSeqSVM := Nil
	EndIf

	aSize(aSVM, 0)
Return

/*/{Protheus.doc} alterouAlocacao
Compara a alocação anterior com a nova alocação para identificar se houve mudança na alocação.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aAlocado , Array, alocações originais da operação (SVM)
@param 02 aNovaAloc, Array, novas alocações da operação (SVM)
@return lAlterou, Logic, Retorna se houve alteração na alocação do recurso.
/*/
Method alterouAlocacao(aAlocado, aNovaAloc) Class PCPA152Nivelamento
	Local lAlterou := .F.
	Local nIndex   := 0
	Local nTotAloc := Len(aAlocado)
	Local nTotNovo := Len(aNovaAloc)

	lAlterou := nTotAloc != nTotNovo

	If !lAlterou
		For nIndex := 1 To nTotAloc
			If aAlocado[nIndex][ARRAY_VM_DATA  ] != aNovaAloc[nIndex][ARRAY_VM_DATA  ] .Or.;
			   aAlocado[nIndex][ARRAY_VM_INICIO] != aNovaAloc[nIndex][ARRAY_VM_INICIO] .Or.;
			   aAlocado[nIndex][ARRAY_VM_FIM   ] != aNovaAloc[nIndex][ARRAY_VM_FIM   ]

				lAlterou := .T.
				Exit
			EndIf
		Next nIndex
	EndIf
Return lAlterou

/*/{Protheus.doc} removeOperacao
Remove a alocação de uma operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aAlocado , Array, alocações da operação (SVM)
@param 02 aOperacao, Array, informações da operação (SMF).
@return Nil
/*/
Method removeOperacao(aAlocado, aOperacao) Class PCPA152Nivelamento
	Local aDispRecur := Nil
	Local aIndices   := Nil
	Local cRecurso   := aOperacao[ARRAY_MF_RECURSO]
	Local cIndice    := ""
	Local dData      := Nil
	Local nIndex     := 0
	Local nTotal     := 0
	Local nIndDisp   := 0
	Local oIndice    := _Super:getJsonIndicesRecurso(cRecurso)
	Local oIndDisp   := JsonObject():New()
	Local oDatas     := JsonObject():New()

	aDispRecur  := Self:oDispRecur[cRecurso]
	aIndices    := Self:recuperaIndicesTemposOperacao(aOperacao, aAlocado)
	nTotal      := Len(aIndices)

	//Remove as alocações do aDispRecur, deixando o período disponível
	For nIndex := 1 To nTotal
		nIndDisp := aIndices[nIndex][INDICE_TEMPOS_POS_DISPONIBILIDADE]
		cIndice  := cValToChar(nIndDisp)

		//Salva índice para ajustar períodos livres
		If oIndDisp:hasProperty(cIndice) == .F.
			oIndDisp[ cIndice ] := nIndDisp
		EndIf

		Self:removeAlocacaoDisponibilidade(@aDispRecur                               ,;
		                                   nIndDisp                                  ,;
		                                   aIndices[nIndex][INDICE_TEMPOS_POS_TEMPOS],;
		                                   @oIndice                                   )
	Next nIndex

	aSize(aIndices, 0)

	aIndices := oIndDisp:GetNames()
	nTotal   := Len(aIndices)
	//Verifica se existem períodos iguais e disponíveis que estão separados, e faz a união
	For nIndex := 1 To nTotal
		nIndDisp := oIndDisp[aIndices[nIndex]]
		dData    := aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_DATA]

		_Super:unePeriodosDisponiveis(aDispRecur[nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE])
		_Super:removeIndiceAlocado(cRecurso, nIndDisp)

		oDatas[DtoS(dData)] := dData
	Next nIndex
	aSize(aIndices, 0)

	aIndices := oDatas:GetNames()
	nTotal   := Len(aIndices)
	//Atualiza os índices de períodos disponíveis
	For nIndex := 1 To nTotal
		dData := oDatas[aIndices[nIndex]]
		_Super:atualizaIndiceDisponibilidade(cRecurso, dData)
	Next nIndex

	Self:oFerramentas:removeUtilizacaoLocal(aOperacao[ARRAY_MF_ID])

	aDispRecur := Nil
	oIndice    := Nil

	FreeObj(oDatas)
	FreeObj(oIndDisp)
	aSize(aIndices, 0)
Return Nil

/*/{Protheus.doc} recuperaIndicesTemposOperacao
Recupera os índices do array de tempos para a operação alocada.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, informações da operação (SMF).
@param 02 aAlocado , Array, alocações da operação (SVM)
@return aIndices, Array, índices de alocação.
/*/
Method recuperaIndicesTemposOperacao(aOperacao, aAlocado) Class PCPA152Nivelamento
	Local aIndices   := {}
	Local aTempos    := Nil
	Local cData      := ""
	Local cRecurso   := aOperacao[ARRAY_MF_RECURSO]
	Local nHrIni     := 0
	Local nHrFim     := 0
	Local nIndDisp   := 0
	Local nIndAloc   := 0
	Local nIndTempos := 0
	Local nTotTempos := 0
	Local nTotAloc   := 0
	Local nPos       := 0
	Local oIndice    := _Super:getJsonIndicesRecurso(cRecurso)

	Default aAlocado := Self:getAlocacaoSVM(aOperacao)

	nTotAloc := Len(aAlocado)

	For nIndAloc := 1 To nTotAloc

		If aAlocado[nIndAloc][ARRAY_VM_TIPO] == VM_TIPO_REMOCAO
			Loop
		EndIf

		cData  := DtoS(aAlocado[nIndAloc][ARRAY_VM_DATA])
		nHrIni := __Hrs2Min(aAlocado[nIndAloc][ARRAY_VM_INICIO])
		nHrFim := __Hrs2Min(aAlocado[nIndAloc][ARRAY_VM_FIM   ])

		For nIndDisp := oIndice[cData][ARRAY_INDICE_DISP_INICIO_DATA] To oIndice[cData][ARRAY_INDICE_DISP_FIM_DATA]

			aTempos    := Self:oDispRecur[cRecurso][nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nTotTempos := Len(aTempos)

			For nIndTempos := 1 To nTotTempos

				If aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_DISPONIVEL
					Loop
				EndIf

				If aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_INICIO]         == nHrIni .And.;
				   aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_FIM   ]         == nHrFim .And.;
				   aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID] == aAlocado[nIndAloc][ARRAY_VM_ID]

					nPos++
					aAdd(aIndices, Array(INDICE_TEMPOS_TAMANHO))
					aIndices[nPos][INDICE_TEMPOS_POS_RECURSO        ] := cRecurso
					aIndices[nPos][INDICE_TEMPOS_POS_DISPONIBILIDADE] := nIndDisp
					aIndices[nPos][INDICE_TEMPOS_POS_TEMPOS         ] := nIndTempos

					Exit
				EndIf
			Next nIndTempos

			aTempos := Nil
		Next nIndDisp

	Next nIndAloc

	oIndice := Nil
Return aIndices

/*/{Protheus.doc} getAlocacaoSVM
Busca as alocações (SVM) de uma operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, Array com as informações da operação (SMF) para busca.
@return aAlocado, Array, Array com os registros da SVM da operação
/*/
Method getAlocacaoSVM(aOperacao) Class PCPA152Nivelamento
	Local aAlocado  := {}
	Local aSVM      := Nil
	Local cChaveSVM := _Super:chaveListaDadosSVM(aOperacao)
	Local nIndex    := 0
	Local nTotal    := 0

	aSVM   := _Super:retornaListaGlobal(LISTA_DADOS_SVM, cChaveSVM)
	nTotal := Len(aSVM)

	For nIndex := 1 To nTotal
		If aSVM[nIndex][ARRAY_VM_ID] == aOperacao[ARRAY_MF_ID]
			aAdd(aAlocado, aSVM[nIndex])
		EndIf
		aSVM[nIndex] := Nil
	Next nIndex

	aSize(aSVM, 0)

Return aAlocado

/*/{Protheus.doc} carregaArvoresParaReprocessar
Retorna as árvores e os recursos que precisam ser reprocessadas
para realizar a redução do setup

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 oArvores  , Object, Retorna por referência JSON com as árvores que devem ser realocadas
@param 02 oRecursos , Object, Retorna por referência JSON com os recursos que devem ser reprocessados
@param 03 oFerrament, Object, Retorna por referência JSON com as ferramentas que devem ser reprocessadas
@return lExiste, Logic, Retorna se existe algo que precise ser reprocessado
/*/
Method carregaArvoresParaReprocessar(oArvores, oRecursos, oFerrament) Class PCPA152Nivelamento
	Local aDados  := Nil
	Local nTotal  := 0
	Local nIndex  := 0
	Local lExiste := .F.

	aDados := _Super:retornaListaGlobal("SETUP_ALTERADOS", "ARVORES")
	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		oArvores[aDados[nIndex]] := .T.
	Next nIndex
	aSize(aDados, 0)

	aDados := _Super:retornaListaGlobal("SETUP_ALTERADOS", "FERRAMENTAS")
	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		oFerrament[aDados[nIndex]] := .T.
	Next nIndex
	aSize(aDados, 0)

	aDados := _Super:retornaListaGlobal("SETUP_ALTERADOS", "RECURSOS")
	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		oRecursos[aDados[nIndex]] := .T.
	Next nIndex
	aSize(aDados, 0)

	lExiste := nTotal > 0

Return lExiste

/*/{Protheus.doc} carregaJaNivelados
Carrega operações já niveladas da OP/Árvore, para que seja possível identificar
o início/término da operação e realocar os tempos.

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, dados da operação (SMF)
@param 02 lInicio  , Logic, indica se aloca por início
@return Nil
/*/
Method carregaJaNivelados(aOperacao, lInicio) Class PCPA152Nivelamento
	Local aPosicoes  := {}
	Local aDisp      := Nil
	Local aIndices   := Nil
	Local aOperacoes := {}
	Local aPeriodos  := {}
	Local cChaveArv  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local nIndex     := 0
	Local nPosicao   := 0
	Local nTotal     := 0
	Local nIndTempos := 0
	Local nTotTempos := 0

	aSize(Self:aAlocados, 0)

	If lInicio
		If aOperacao[ARRAY_PROC_PRIMEIRA_OPERACAO]
			//Aloca por início e é a primeira operação.
			//Carrega no aAlocados a última operação de todas as OPS FILHAS para identificar o horário que esta operação pode iniciar.
			aOperacoes := Self:getOperacsOrdenadas(cChaveArv, .F., aOperacao[ARRAY_MF_OP], .F.)
			nTotal     := Len(aOperacoes)
			For nIndex := 1 To nTotal
				If aOperacoes[nIndex][ARRAY_PROC_ULTIMA_OPERACAO] .And. aOperacoes[nIndex][ARRAY_PROC_OP_PAI] == aOperacao[ARRAY_MF_OP]
					aAdd(aPosicoes, nIndex)
				EndIf
			Next nIndex
			nIndex := 0
		Else
			//Aloca por início e não é a primeira operação, carrega apenas a operação anterior no aAlocados.
			aOperacoes := _Super:getOperacoesOrdem(aOperacao[ARRAY_MF_OP], .T.)
			nIndex     := aScan(aOperacoes, {|x| x[ARRAY_MF_OPER] == aOperacao[ARRAY_MF_OPER]}) //Busca a operação atual
			nIndex-- //decrementa 1 no nIndex para ter a posição da operação anterior
		EndIf
	Else
		If aOperacao[ARRAY_PROC_ULTIMA_OPERACAO]
			//Aloca por entrega e é a última operação.
			//Carrega no aAlocados a primeira operação da OP PAI, para identificar o horário que esta operação deve terminar.
			If !Empty(aOperacao[ARRAY_PROC_OP_PAI])
				aOperacoes := _Super:getOperacoesOrdem(aOperacao[ARRAY_PROC_OP_PAI], .T.)
				nIndex     := aScan(aOperacoes, {|x| x[ARRAY_PROC_PRIMEIRA_OPERACAO] })
			EndIf
		Else
			//Aloca por entrega e não é última operação.
			//Carrega no aAlocados a próxima operação desta OP, para identificar o horário que esta operação deve terminar.
			aOperacoes := _Super:getOperacoesOrdem(aOperacao[ARRAY_MF_OP], .T.)
			nIndex     := aScan(aOperacoes, {|x| x[ARRAY_MF_OPER] == aOperacao[ARRAY_MF_OPER]}) //Busca a operação atual
			nIndex++ //incrementa 1 no nIndex para ter a posição da próxima operação
		EndIf
	EndIf

	If nIndex > 0
		aAdd(aPosicoes, nIndex)
	EndIf

	//Percorre aPosicoes e adiciona no aAlocados
	nTotal := Len(aPosicoes)
	For nIndex := 1 To nTotal

		nPosicao   := aPosicoes[nIndex]
		aIndices   := Self:recuperaIndicesTemposOperacao(aOperacoes[nPosicao])
		nTotTempos := Len(aIndices)

		For nIndTempos := 1 To nTotTempos
			aDisp := Self:oDispRecur[ aIndices[nIndTempos][INDICE_TEMPOS_POS_RECURSO] ][ aIndices[nIndTempos][INDICE_TEMPOS_POS_DISPONIBILIDADE] ]

			aAdd(aPeriodos, aDisp[ARRAY_DISP_RECURSO_DISPONIBILIDADE][aIndices[nIndTempos][INDICE_TEMPOS_POS_TEMPOS]] )
		Next nIndTempos
		aDisp := Nil

		aPeriodos := _Super:adicionaTempoRemocao(aOperacoes[nPosicao], aPeriodos)
		_Super:adicionaOperacaoAlocada(aOperacoes[nPosicao], aPeriodos, aOperacoes[nPosicao][ARRAY_MF_RECURSO])

		aSize(aIndices, 0)
		aPeriodos := {}
	Next nIndex

	aSize(aPosicoes, 0)
	aSize(aOperacoes, 0)

Return

/*/{Protheus.doc} gravaParamAlocOper
Grava os parâmetros utilizados durante a alocação da operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, dados da operação (SMF).
@param 02 lDeleta  , Logic, Identifica se deve limpar o registro de parâmetros da operação.
@param 03 lDataProg, Logic, parâmetro se aloca por data da programação
@param 04 lEntrega , Logic, parâmetro se aloca por data de entrega
@param 05 lDataDaOP, Logic, parâmetro se usa a data da OP
@return Nil
/*/
Method gravaParamAlocOper(aOperacao, lDeleta, lDataProg, lEntrega, lDataDaOP) Class PCPA152Nivelamento

	If lDeleta
		Self:oAlocOper:delName(aOperacao[ARRAY_MF_ID])
	Else
		Self:oAlocOper[aOperacao[ARRAY_MF_ID]] := {lDataProg, lEntrega, lDataDaOP}
	EndIf

Return

/*/{Protheus.doc} recuperaParamAlocOper
Recupera os parâmetros utilizados durante a alocação da operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, dados da operação (SMF).
@param 02 lDataProg, Logic, Retorna por referência parâmetro se aloca por data da programação
@param 03 lEntrega , Logic, Retorna por referência parâmetro se aloca por data de entrega
@param 04 lDataDaOP, Logic, Retorna por referência parâmetro se usa a data da OP
@param 05 lInicio  , Logic, Retorna por referência se a operação aloca por início
@return Nil
/*/
Method recuperaParamAlocOper(aOperacao, lDataProg, lEntrega, lDataDaOP, lInicio) Class PCPA152Nivelamento

	lDataProg := .F.
	lEntrega  := .F.
	lDataDaOP := .F.
	lInicio   := .F.

	If Self:oAlocOper:hasProperty(aOperacao[ARRAY_MF_ID])
		lDataProg := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][1]
		lEntrega  := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][2]
		lDataDaOP := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][3]
		lInicio := lDataProg .Or. !lEntrega
	EndIf
Return

/*/{Protheus.doc} registraRealocado
Registra dados da operação realocada para análise de ocorrências

@author lucas.franca
@since 06/06/2024
@version P12
@param 01 aOperacao, Array, dados da operação (SMF).
@return Nil
/*/
Method registraRealocado(aOperacao) Class PCPA152Nivelamento
	Local cChaveArv  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]

	If !Self:oRealocado:HasProperty(cChaveArv)
		Self:oRealocado[cChaveArv] := JsonObject():New()
	EndIf
	Self:oRealocado[cChaveArv][aOperacao[ARRAY_MF_OP]] := .T.

Return

/*/{Protheus.doc} ajustaOcorrencias
Avalia as ocorrências as ordens conforme as novas alocações realizadas
durante a redução de setup.

@author lucas.franca
@since 23/05/2024
@version P12
@return Nil
/*/
Method ajustaOcorrencias() Class PCPA152Nivelamento
	Local aChavesArv := Self:oRealocado:getNames()
	Local aAlocacao  := {}
	Local aIndice    := Nil
	Local aOperacoes := Nil
	Local aOrdens    := Nil
	Local aOperacao  := Nil
	Local cChaveArv  := ""
	Local cRecurso   := ""
	Local dDataIni   := Nil
	Local dDataFim   := Nil
	Local nIndArv    := 0
	Local nIndDisp   := 0
	Local nTotArv    := Len(aChavesArv)
	Local nIndOp     := 0
	Local nTotOp     := 0
	Local nPosicao   := 0
	Local oTipos     := JsonObject():New()

	/*
		Remove ocorrências dos tipos:
			02 (alteração data início)
			03 (alteração data entrega)
			04 (usou disponibilidade adicional)
	*/
	oTipos[LOG_DATA_INICIO_ALTERADA          ] := .T.
	oTipos[LOG_DATA_ENTREGA_ALTERADA         ] := .T.
	oTipos[LOG_USOU_DISPONIBILIDADE_ADICIONAL] := .T.

	//Percorre as árvores que tiveram alteração
	For nIndArv := 1 To nTotArv
		cChaveArv := aChavesArv[nIndArv]
		aOrdens   := Self:oRealocado[cChaveArv]:getNames()
		nTotOp    := Len(aOrdens)

		//Carrega as ocorrências da árvore para memória local
		Self:oOcorrens:globalToLocal(cChaveArv)

		//Percorre as OPS da árvore que tiveram alteração
		For nIndOp := 1 To nTotOp
			//Busca as operações da OP
			aOperacoes := _Super:getOperacoesOrdem(aOrdens[nIndOp], .T.)
			dDataIni   := Nil
			dDataFim   := Nil
			nPosicao   := aScan(aOperacoes, {|x| x[ARRAY_MF_SALDO] > 0})
			//busca a data de início da primeira operação.
			aIndice := Self:recuperaIndicesTemposOperacao(aOperacoes[nPosicao])
			If Len(aIndice) > 0
				cRecurso   := aIndice[1][INDICE_TEMPOS_POS_RECURSO        ]
				nIndDisp   := aIndice[1][INDICE_TEMPOS_POS_DISPONIBILIDADE]
				dDataIni   := Self:oDispRecur[cRecurso][nIndDisp][ARRAY_DISP_RECURSO_DATA]
			EndIf

			//busca a data de término da última operação
			aOperacao := aTail(aOperacoes)
			aAlocacao := Self:getAlocacaoSVM(aOperacao)
			dDataFim  := aTail(aAlocacao)[ARRAY_VM_DATA]

			If dDataIni != Nil .And. dDataFim != Nil

				//remove as ocorrências dos tipos 02, 03 e 04 desta OP.
				Self:oOcorrens:removeOcorrencia(cChaveArv, aOrdens[nIndOp], Nil, oTipos)

				//avalia novamente a necessidade de criar as ocorrências 02 e 03
				_Super:validaDatasOp(aOperacao, dDataIni, dDataFim)

				//avalia a necessidade de criar a ocorrência 04
				If dDataFim > Self:oParTempo["dataFinal"]
					Self:oOcorrens:adicionaOcorrencia(LOG_USOU_DISPONIBILIDADE_ADICIONAL,;
					                                  cChaveArv                         ,;
					                                  aOperacao[ARRAY_MF_ID]            ,;
					                                  aOperacao[ARRAY_MF_OP]            ,;
					                                  "", "", "", "", {}                 )
				EndIf
			EndIf

			aOperacao := Nil
			aIndice   := Nil
			aAlocacao := Nil
			aSize(aOperacoes, 0)
			Self:oRealocado[cChaveArv]:delName(aOrdens[nIndOp])
		Next nIndOper

		//grava as ocorrências da árvore na global novamente
		Self:oOcorrens:localToGlobal(.F.)
		Self:oRealocado:delName(cChaveArv)
		aSize(aOrdens, 0)
	Next nIndArv

	aSize(aChavesArv, 0)
	FreeObj(oTipos)
Return


/*/{Protheus.doc} buscaHoraRecurso
Busca o horário disponível para o uso do recurso

@author lucas.franca
@since 28/06/2024
@version P12
@param 01 aOperacao , Array  , Dados da operação que está sendo processada.
@param 02 dData     , Date   , Data para realizar a alocação da operação.
@param 03 nHora     , Numeric, Hora em minutos padrão para uso.
@param 04 lFinal    , Logic  , Indica que aloca do final para o início
@param 05 lEncontrou, Logic  , Retorna por referência se encontrou alguma data disponível.
@return nHora, Numeric, Hora disponível para uso do recurso
/*/
Method buscaHoraRecurso(aOperacao, dData, nHora, lFinal, lEncontrou) Class PCPA152Nivelamento
	Local aDispRec   := Self:oDispRecur[aOperacao[ARRAY_MF_RECURSO]]
	Local aTempos    := Nil
	Local cData      := DtoS(dData)
	Local nFim       := 0
	Local nFimTempo  := 0
	Local nIndex     := 0
	Local nIndTempos := 0
	Local nInicio    := 0
	Local nIniTempo  := 0
	Local nStep      := 1
	Local oIndices   := Self:getJsonIndicesRecurso(aOperacao[ARRAY_MF_RECURSO])

	lEncontrou := .F.

	If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
		Self:aFerramentas := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
	EndIf

	If oIndices:hasProperty(cData)
		If lFinal
			nInicio := oIndices[cData][ARRAY_INDICE_DISP_FIM_DATA]
			nFim    := oIndices[cData][ARRAY_INDICE_DISP_INICIO_DATA]
			nStep   := -1
		Else
			nInicio := oIndices[cData][ARRAY_INDICE_DISP_INICIO_DATA]
			nFim    := oIndices[cData][ARRAY_INDICE_DISP_FIM_DATA]
			nStep   := 1
		EndIf

		For nIndex := nInicio To nFim Step nStep
			aTempos := aDispRec[nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]

			If lFinal
				nIniTempo := Len(aTempos)
				nFimTempo := 1
			Else
				nIniTempo := 1
				nFimTempo := Len(aTempos)
			EndIf

			For nIndTempos := nIniTempo To nFimTempo Step nStep
				If (lFinal  .And. aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_INICIO] >= nHora) .Or.;
				   (!lFinal .And. aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_FIM   ] <= nHora)
					Loop
				EndIf

				If aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID] == aOperacao[ARRAY_MF_ID] .Or.;
				   aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_DISPONIVEL

					If lFinal
						nHora := aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_FIM]
					Else
						nHora := aTempos[nIndTempos][ARRAY_DISPONIBILIDADE_HORA_INICIO]
					EndIf
					nIndex     := nFim
					lEncontrou := .T.
					Exit
				EndIf
			Next nIndTempos
			aTempos := Nil
		Next nIndex
	EndIf

	Self:aFerramentas := {}
	oIndices := Nil
	aDispRec := Nil
Return nHora

/*/{Protheus.doc} existeTempoDisponivel
Verifica se existe algum tempo disponível entre as alocações de uma operação.
Utilizado quando parametrizado para permitir a quebra das alocações (quebraOperacoes)

@author lucas.franca
@since 01/07/2024
@version P12
@param 01 aOperacao, Array, Dados da operação que está sendo processada.
@param 02 aIndices , Array, Indices das alocações da operação.
@return lExiste, Logic, Indica se existe tempo disponível entre as alocações.
/*/
Method existeTempoDisponivel(aOperacao, aIndices) Class PCPA152Nivelamento
	Local aDispRec  := Self:oDispRecur[aOperacao[ARRAY_MF_RECURSO]]
	Local aTempos   := Nil
	Local lExiste   := .F.
	Local nIniDisp  := aIndices[1][INDICE_TEMPOS_POS_DISPONIBILIDADE]
	Local nIniTemp  := aIndices[1][INDICE_TEMPOS_POS_TEMPOS         ]
	Local nFimDisp  := aTail(aIndices)[INDICE_TEMPOS_POS_DISPONIBILIDADE]
	Local nFimTempo := 0
	Local nIdxDisp  := 0
	Local nIdxTemp  := 0

	For nIdxDisp := nIniDisp To nFimDisp
		aTempos := aDispRec[nIdxDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		If nIdxDisp == nFimDisp
			nFimTempo := aTail(aIndices)[INDICE_TEMPOS_POS_TEMPOS]
		Else
			nFimTempo := Len(aTempos)
		EndIf

		For nIdxTemp := nIniTemp To nFimTempo
			If aTempos[nIdxTemp][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_DISPONIVEL
				lExiste  := .T.
				nIdxDisp := nFimDisp
				Exit
			EndIf
		Next nIdxTemp

		aTempos  := Nil
		nIniTemp := 1
	Next nIdxDisp

	aDispRec := Nil
Return lExiste


/*/{Protheus.doc} P152ISetup
Identifica recursos/árvores que possuem setup duplicado na alocação.

@type  Function
@author lucas.franca
@since 17/05/2024
@version P12
@param 01 cProg     , Caracter, Programação em execução
@param 02 cRecurso  , Caracter, Código do recurso para remover o SETUP
@param 03 aDispRecur, Array   , Array com as disponibilidades do recurso
@param 03 cAlocRec  , Caracter, Json com os indices alocados.
@return Nil
/*/
Function P152ISetup(cProg, cRecurso, aDispRecur, cAlocRec)

	Local oNivela := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_NIVELA, @oNivela)
		oNivela:identificaSetupDuplicado(cRecurso, aDispRecur, cAlocRec)
	EndIf

Return

/*/{Protheus.doc} logAlter
Cria mensagem de log da alteração de alocação de uma operação.

@type  Static Function
@author lucas.franca
@since 05/06/2024
@version P12
@param 01 aOperacao, Array, informações da operação processada
@param 02 aAlocado , Array, alocações originais da operação
@param 03 aNovaAloc, Array, nova alocação da operação
@param 04 lEntrega , Logico, Indica se a alocação é pela data de entrega
@return cMsg, Caracter, Mensagem de log com a alteração de alocação
/*/
Static Function logAlter(aOperacao, aAlocado, aNovaAloc, lEntrega)
	Local aMsg := {}
	Local nFim := Len(aAlocado)

	aAdd(aMsg, "ALTEROU ALOCACAO. Ordem: "    + aOperacao[ARRAY_MF_OP     ] +;
	                           ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
	                           ", Recurso: "  + aOperacao[ARRAY_MF_RECURSO] +;
	                           ", Tipo alocacao: " + Iif(lEntrega, "Entrega", "Inicio"))

	aAdd(aMsg, "  Alocacao anterior: ")
	If nFim > 0
		aAdd(aMsg, "    Inicio " + DtoC(aAlocado[1][ARRAY_VM_DATA]) + " - " + aAlocado[1][ARRAY_VM_INICIO])
		aAdd(aMsg, "    Fim    " + DtoC(aAlocado[nFim][ARRAY_VM_DATA]) + " - " + aAlocado[nFim][ARRAY_VM_FIM])
	EndIf

	nFim := Len(aNovaAloc)
	aAdd(aMsg, "  Nova alocacao: ")
	If nFim > 0
		aAdd(aMsg, "    Inicio " + DtoC(aNovaAloc[1][ARRAY_VM_DATA]) + " - " + aNovaAloc[1][ARRAY_VM_INICIO])
		aAdd(aMsg, "    Fim    " + DtoC(aNovaAloc[nFim][ARRAY_VM_DATA]) + " - " + aNovaAloc[nFim][ARRAY_VM_FIM])
	EndIf

Return aMsg

/*/{Protheus.doc} alocaOperacao
Busca os periodos de alocação de uma operação.
@author Lucas Fagundes
@since 02/09/2024
@version P12
@param 01 aOperacao, Array   , Operação que está sendo alocada.
@param 02 lEntrega , Logico  , Indica se aloca pela data de entrega.
@param 03 lDataDaOP, Lógico  , Indica se aloca pela data da op.
@param 04 lDataProg, Lógico  , Indica se aloca pela data da programação.
@param 05 lDistTudo, Logico  , Retorna por referência se conseguiu alocar toda a operação.
@param 06 lDispAdc , Logico  , Indica se pode usar disponibilidade adicional.
@param 07 cRecurso , Caracter, Retorna por referência o recurso alocado.
@param 08 lAlocPost, Lógico  , Retorna por referência se realizou alocação em data posterior a data limite do CRP.
@param 09 lRetCria , Lógico  , Retorna por referência se criou disponibilidade adicional.
@param 10 aAlocOrig, Array   , Array com as data de alocação original da operação (redução de setup).
@param 11 lEntJunto, Lógico  , Retorna por referência se precisou realocar a operação para entregar junto da operação anterior.
@param 12 dDataAlo , Date    , Retorna por referência a data de referência da alocação.
@param 13 nHoraAlo , Numerico, Retorna por referência a hora de referência da alocação.
@return aPeriodos, Array, Array com os periodos encontrados para a operação.
/*/
Method alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, lDistTudo, lDispAdc, cRecurso, lAlocPost, lRetCria, aAlocOrig, lEntJunto, dDataAlo, nHoraAlo) Class PCPA152Nivelamento
	Local aDatas      := {}
	Local aFerramenta := {}
	Local aPeriodos   := {}
	Local cRecPrin    := ""
	Local dData       := CtoD(PCPConvDat((Self:oParamNiv["dataInicial"]), 3))
	Local lValidAlt   := .F.
	Local nHora       := __Hrs2Min(Self:oParamNiv["horaInicial"])

	cRecPrin := aOperacao[ARRAY_PROC_RECURSOS][1][ARRAY_HZ7_RECURS]
	If Self:lRedSetup
		cRecurso  := aOperacao[ARRAY_MF_RECURSO]
		lValidAlt := .F.
	Else
		cRecurso  := cRecPrin
		lValidAlt := aOperacao[ARRAY_PROC_USA_ALTERNATIVOS]

		If lValidAlt
			cRecurso := ""
		EndIf
	EndIf

	_Super:preAlocacaoAtualizaSobreposicao(aOperacao, lEntrega)

	If lValidAlt .Or. _Super:alocaComSobreposicao(aOperacao, lEntrega, cRecurso)

		If Self:simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig)
			If lValidAlt
				cRecurso := Self:avaliaSimulacao(aOperacao, lEntrega)
			EndIf

			Self:getParametrosAlocacao(aOperacao, cRecurso, @lEntrega, @dData, @nHora, @lEntJunto)

			_Super:limpaListaGlobal("ALOCACOES_NIVELAMENTO")
		EndIf

		If cRecurso != cRecPrin .And. lValidAlt
			Self:oOcorrens:adicionaOcorrencia(LOG_ALOCOU_ALTERNATIVO            ,;
			                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
			                                  aOperacao[ARRAY_MF_ID            ],;
			                                  aOperacao[ARRAY_MF_OP            ],;
			                                  aOperacao[ARRAY_MF_OPER          ],;
			                                  "", "", ""                        ,;
			                                  {RTrim(cRecPrin), RTrim(cRecurso)})
		EndIf
	Else
		cRecurso := aOperacao[ARRAY_MF_RECURSO]

		aDatas := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecurso)

		dData := aDatas[RET_GET_DATA_DATA]
		nHora := aDatas[RET_GET_DATA_HORA]
	EndIf

	If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
		aFerramenta := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
	EndIf

	If _Super:permiteProsseguir()
		_Super:carregaDisponibilidadeRecurso(cRecurso)

		aPeriodos := _Super:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lDistTudo, lDispAdc, @lAlocPost, @lRetCria, cRecurso, .F., aFerramenta)
		dDataAlo  := dData
		nHoraAlo  := nHora

		_Super:posAlocacaoAtualizaSobreposicao(aOperacao, cRecurso, lEntrega)
	EndIf

Return aPeriodos

/*/{Protheus.doc} simulaAlocacoes
Simula a alocação da operação em todos os recursos para encontrar o recurso com os melhores tempos.
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 lEntrega , Lógico  , Indica se as alocações devem ser feitas por data de entrega.
@param 03 lDataDaOP, Lógico  , Indica se aloca pela data da op.
@param 04 lDataProg, Lógico  , Indica se aloca pela data da programação.
@param 05 lDispAdc , Lógico  , Indica se pode gerar disponibilidade adicional.
@param 06 cRecurso , Caracter, Indica um recurso especifico que deve simular a alocação.
@param 07 aAlocOrig, Array   , Array com as data de alocação original da operação (redução de setup).
@return Nil
/*/
Method simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig) Class PCPA152Nivelamento
	Local aDispRec  := {}
	Local aRecursos := aOperacao[ARRAY_PROC_RECURSOS]
	Local aRetData  := {}
	Local cEtapa    := CHAR_ETAPAS_NIVELAMENTO
	Local cIndcAloc := ""
	Local cIndice   := ""
	Local cJsFerram := ""
	Local cRecAloc  := ""
	Local nIndAloc  := 0
	Local nQtdSim   := 0
	Local nTotAloc  := Len(aRecursos)

	If Self:lRedSetup
		cEtapa := CHAR_ETAPAS_REDUZ_SETUP
	EndIf
	cJsFerram := Self:oFerramentas:getJsonUtilizacao()

	_Super:gravaValorGlobal("ALOCACOES_PROCESSADAS", 0)

	If Empty(cRecurso)
		nIndAloc := 1
		nTotAloc := Len(aRecursos)
	Else
		nIndAloc := aScan(aRecursos, {|x| x[ARRAY_HZ7_RECURS] == cRecurso})
		nTotAloc := nIndAloc
	EndIf

	For nIndAloc := nIndAloc To nTotAloc
		cRecAloc := aRecursos[nIndAloc][ARRAY_HZ7_RECURS]
		nQtdSim++

		_Super:carregaDisponibilidadeRecurso(cRecAloc)

		aDispRec  := Self:oDispRecur[cRecAloc]
		cIndice   := _Super:getJsonIndicesRecurso(cRecAloc):toJson()
		cIndcAloc := _Super:getIndicesComAlocacao(cRecAloc):toJson()

		aRetData := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecAloc)

		_Super:delegar("P152DelAlo", Self:cProg, aOperacao[ARRAY_MF_ID], aOperacao[ARRAY_MF_OP], cRecAloc, aDispRec, cIndice, cIndcAloc, {lEntrega, lDispAdc, aRetData, cEtapa, aAlocOrig, cJsFerram})

		aSize(aRetData, 0)
	Next

	While _Super:permiteProsseguir() .And. nQtdSim > _Super:retornaValorGlobal("ALOCACOES_PROCESSADAS")

	End

	aDispRec  := {}
	aRecursos := {}
Return _Super:permiteProsseguir()

/*/{Protheus.doc} P152DelAlo
Executa a simulação da alocação de uma operação em outra thread.
@type  Function
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 cProg      , Caracter, Código da programação.
@param 02 aOperacao  , Array   , Array com as informações da programação.
@param 03 cRecurso   , Caracter, Recurso que irá simular a alocação da operação.
@param 04 aDispRecur , Array   , Disponibilidade do recurso que irá simular a alocação.
@param 05 cIndices   , Caracter, Indices da disponibilidade do recurso que irá simular a alocação.
@param 06 cIndcAloc  , Caracter, Indices que possuem alocações na disponibilidade do recurso.
@param 07 aParGet    , Array   , Array com as informações para simular a alocação. No formato: aParGet[1], Logico  , Indica se a operação será alocada por data de entrega.
                                                                                               aParGet[2], Logico  , Indica se pode gerar disponibilidade adicional durante as alocações.
                                                                                               aParGet[3], Array   , Array com as informações de data para a alocação (retorno do método getDataOperacao).
                                                                                               aParGet[4], Caracter, Etapa que está processando a alocação.
                                                                                               aParGet[5], Array   , Array com as datas de alocação original da operação (redução de setup).
                                                                                               aParGet[6], Caracter, Json com a utilização das ferramentas.
@return Nil
/*/
Function P152DelAlo(cProg, cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet)
	Local oNive := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_NIVELA, @oNive)
		oNive:executaSimulacao(cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet)
	EndIf

Return Nil

/*/{Protheus.doc} executaSimulacao
Executa a simulação da alocação de uma operação em outra thread.
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 aOperacao  , Array   , Array com as informações da programação.
@param 02 cRecurso   , Caracter, Recurso que irá simular a alocação da operação.
@param 03 aDispRecur , Array   , Disponibilidade do recurso que irá simular a alocação.
@param 04 cIndices   , Caracter, Indices da disponibilidade do recurso que irá simular a alocação.
@param 05 cIndcAloc  , Caracter, Indices que possuem alocações na disponibilidade do recurso.
@param 06 aParGet    , Array   , Array com as informações para simular a alocação. No formato: aParGet[1], Logico  , Indica se a operação será alocada por data de entrega.
                                                                                               aParGet[2], Logico  , Indica se pode gerar disponibilidade adicional durante as alocações.
                                                                                               aParGet[3], Array   , Array com as informações de data para a alocação (retorno do método getDataOperacao).
                                                                                               aParGet[4], Caracter, Etapa que está processando a alocação.
                                                                                               aParGet[5], Array   , Array com as datas de alocação original da operação (redução de setup).
                                                                                               aParGet[6], Caracter, Json com a utilização das ferramentas.
@return Nil
/*/
Method executaSimulacao(cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet) Class PCPA152Nivelamento
	Local aAlocOrig   := aParGet[5]
	Local aFerramenta := {}
	Local aGetData    := aParGet[3]
	Local aOperacao   := _Super:getOperacao(cOPOper, cIdOper)
	Local aPeriodos   := {}
	Local aSave       := Array(INFO_ALOCACOES_TAMANHO)
	Local cChave      := Self:getChaveAlocacao(aOperacao, cRecurso)
	Local cJsFerram   := aParGet[6]
	Local dData       := Nil
	Local lDistTudo   := .F.
	Local lEntJunto   := .F.
	Local lEntrega    := aParGet[1]
	Local lGeraAdc    := aParGet[2]
	Local nHora       := 0

	_Super:preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet[4], cJsFerram)

	If aGetData[RET_GET_DATA_SOBREPOE]
		dData := aGetData[RET_GET_DATA_DATA_SOBRE]
		nHora := aGetData[RET_GET_DATA_HORA_SOBRE]
	Else
		dData := aGetData[RET_GET_DATA_DATA]
		nHora := aGetData[RET_GET_DATA_HORA]
	EndIf

	If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
		aFerramenta := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
	EndIf

	aPeriodos := _Super:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lDistTudo, lGeraAdc, .F., .F., cRecurso, .T., aFerramenta)

	If aGetData[RET_GET_DATA_SOBREPOE]
		Self:avaliaSobreposicao(aOperacao, aGetData, @lEntrega, @aPeriodos, @dData, @nHora, @lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, @lEntJunto, aAlocOrig, aFerramenta)
	EndIf

	aSave[INFO_ALOCACOES_DISTTUDO     ] := lDistTudo
	aSave[INFO_ALOCACOES_PERIODOS     ] := aPeriodos
	aSave[INFO_ALOCACOES_ENTREGA      ] := lEntrega
	aSave[INFO_ALOCACOES_DATA         ] := dData
	aSave[INFO_ALOCACOES_HORA         ] := nHora
	aSave[INFO_ALOCACOES_ENTREGA_JUNTO] := lEntJunto

	_Super:adicionaListaGlobal("ALOCACOES_NIVELAMENTO", cChave, aSave, .F.)

	_Super:gravaValorGlobal("ALOCACOES_PROCESSADAS", 1, .T., .T.)

	Self:oDispRecur:delName(cRecurso)
	Self:oIndcRecur:delName(cRecurso)
	Self:oIndcCAloc:delName(cRecurso)
	Self:lRedSetup := .F.

	aSize(aSave, 0)
	aSize(aPeriodos, 0)
Return Nil

/*/{Protheus.doc} getChaveAlocacao
Retorna chave de alocação da operação.
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 cRecurso , Caracter, Recurso que a operação foi alocada.
@return cChave, Caracter, Chave de alocação da operação.
/*/
Method getChaveAlocacao(aOperacao, cRecurso) Class PCPA152Nivelamento
	Local cChave := aOperacao[ARRAY_PROC_CHAVE_ARVORE] + "_" + cRecurso

Return cChave

/*/{Protheus.doc} avaliaSimulacao
Avalia a simulação de alocação dos recursos para identificar o recurso que tem os melhores tempos para alocação da operação.
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 aOperacao , Array   , Array com as informações da operação.
@param 02 lEntrega  , Logico  , Indica se as alocações foram feitas por data de entrega.
@return cRecEfet  , Caracter, Recurso com os melhores tempos para alocação da operação.
/*/
Method avaliaSimulacao(aOperacao, lEntrega) Class PCPA152Nivelamento
	Local aGlobal    := {}
	Local aPeriodos  := {}
	Local aPerRecEfe := {}
	Local aRecursos  := aOperacao[ARRAY_PROC_RECURSOS]
	Local cChaveAloc := ""
	Local cRecEfet   := ""
	Local cRecurso   := ""
	Local lEfetDisTd := .F.
	Local lLog       := Self:oLogs:logAtivo()
	Local lSubstitui := .F.
	Local nIndRec    := 0
	Local nTempoEfet := 0
	Local nTotRec    := Len(aRecursos)

	If lLog
		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Identificando melhor recurso para alocar a operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP]},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	For nIndRec := 1 To nTotRec
		cRecurso   := aRecursos[nIndRec][ARRAY_HZ7_RECURS]
		cChaveAloc := Self:getChaveAlocacao(aOperacao, cRecurso)
		aGlobal    := _Super:retornaListaGlobal("ALOCACOES_NIVELAMENTO", cChaveAloc)
		aPeriodos  := aGlobal[INFO_ALOCACOES_PERIODOS]
		lSubstitui := .F.

		If Empty(cRecEfet)
			lSubstitui := .T.

			If lLog
				Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Recurso " + cRecurso + " selecionado para a alocacao, pois outros recursos ainda nao foram avaliados."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		EndIf

		If !lSubstitui .And. aGlobal[INFO_ALOCACOES_DISTTUDO] .And. !lEfetDisTd
			lSubstitui := .T.

			If lLog
				Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Recurso " + cRecurso + " selecionado para a alocacao, pois o recurso anterior nao tinha alocacao completa."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		EndIf

		If !lSubstitui .And. aGlobal[INFO_ALOCACOES_DISTTUDO] .And. Self:validaPeriodosAlternativo(aPerRecEfe, aPeriodos, lEntrega, nTempoEfet, aRecursos[nIndRec][ARRAY_HZ7_TEMPRE])
			lSubstitui := .T.

			If lLog
				Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"-- Recurso " + cRecurso + " selecionado para a alocacao, pois possui tempos melhores que o recurso anterior --",;
				                                              "Tempo recurso anterior (" + cRecEfet + "): Inicio: " + DToC(aPerRecEfe[1][ARRAY_DISPONIBILIDADE_DATA]) + " - " + __Min2Hrs(aPerRecEfe[1][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + "; Fim: " + DToC(aTail(aPerRecEfe)[ARRAY_DISPONIBILIDADE_DATA]) + " - " + __Min2Hrs(aTail(aPerRecEfe)[ARRAY_DISPONIBILIDADE_HORA_FIM], .T.),;
				                                              "Tempo novo recurso ("    + cRecurso  + "): Inicio: " + DToC(aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA ]) + " - " + __Min2Hrs(aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_INICIO ], .T.) + "; Fim: " + DToC(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA ]) + " - " + __Min2Hrs(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM ], .T.),;
				                                              "---------------------------------------------------------------------------------------------------------------"},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		EndIf

		If lSubstitui
			cRecEfet   := cRecurso
			aPerRecEfe := aPeriodos
			lEfetDisTd := aGlobal[INFO_ALOCACOES_DISTTUDO]
			nTempoEfet := aRecursos[nIndRec][ARRAY_HZ7_TEMPRE]
		EndIf

		aSize(aGlobal, 0)
	Next

	If lLog
		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Melhor recurso para alocar a operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + ": " + cRecEfet},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecEfet, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	aSize(aPeriodos, 0)
	aSize(aPerRecEfe, 0)
Return cRecEfet

/*/{Protheus.doc} validaPeriodosAlternativo
Recebe as alocações do recurso que será efetivado atualmente e as alocações do recurso alternativo e retorna se as alocações do recurso alternativo pode ser utilizada no lugar das alocações do recurso que será efetivado atualmente.
@author Lucas Fagundes
@since 05/09/2024
@version P12
@param 01 aPeriodos1, Array   , Array com os periodos de alocação do recurso que será efetivado.
@param 02 aPeriodos2, Array   , Array com os periodos de alocação do recurso alternativo.
@param 03 lEntrega  , Logico  , Indica se a alocação foi realizada por data de entrega.
@param 04 nTmpRec1  , Numerico, Tempo de alocação da operação no recurso do periodo 1.
@param 05 nTmpRec2  , Numerico, Tempo de alocação da operação no recurso do periodo 2.
@return lSubstitui, Logico, Retorna se as alocações do recurso alternativo (aPeriodos2) pode ser utilizada no lugar das alocações do recurso que será efetivado atualmente (aPeriodos1).
/*/
Method validaPeriodosAlternativo(aPeriodos1, aPeriodos2, lEntrega, nTmpRec1, nTmpRec2) Class PCPA152Nivelamento
	Local dDtIniPer1 := aPeriodos1[1][ARRAY_DISPONIBILIDADE_DATA]
	Local dDtIniPer2 := aPeriodos2[1][ARRAY_DISPONIBILIDADE_DATA]
	Local nHrIniPer1 := aPeriodos1[1][ARRAY_DISPONIBILIDADE_HORA_INICIO]
	Local nHrIniPer2 := aPeriodos2[1][ARRAY_DISPONIBILIDADE_HORA_INICIO]
	Local dDtFimPer1 := aTail(aPeriodos1)[ARRAY_DISPONIBILIDADE_DATA]
	Local dDtFimPer2 := aTail(aPeriodos2)[ARRAY_DISPONIBILIDADE_DATA]
	Local nHrFimPer1 := aTail(aPeriodos1)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	Local nHrFimPer2 := aTail(aPeriodos2)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	Local lSubstitui := .F.

	If Self:oParamNiv["tipoAlternativo"] == TIPO_ALTERNATIVO_POR_ALOCACAO
		If lEntrega
			lSubstitui := dDtFimPer2 > dDtFimPer1 .Or. (dDtFimPer2 == dDtFimPer1 .And. nHrFimPer2 > nHrFimPer1)

			If !lSubstitui .And. dDtFimPer2 == dDtFimPer1 .And. nHrFimPer2 == nHrFimPer1
				lSubstitui := dDtIniPer2 > dDtIniPer1 .Or. (dDtIniPer2 == dDtIniPer1 .And. nHrIniPer2 > nHrIniPer1)
			EndIf
		Else
			lSubstitui := dDtIniPer2 < dDtIniPer1 .Or. (dDtIniPer2 == dDtIniPer1 .And. nHrIniPer2 < nHrIniPer1)

			If !lSubstitui .And. dDtIniPer2 == dDtIniPer1 .And. nHrIniPer2 == nHrIniPer1
				lSubstitui := dDtFimPer2 < dDtFimPer1 .Or. (dDtFimPer2 == dDtFimPer1 .And. nHrFimPer2 < nHrFimPer1)
			EndIf
		EndIf
	Else
		lSubstitui := ( lEntrega .And. (dDtIniPer2 > dDtIniPer1 .Or. (dDtIniPer2 == dDtIniPer1 .And. nHrIniPer2 > nHrIniPer1))) .Or.;
		              (!lEntrega .And. (dDtFimPer2 < dDtFimPer1 .Or. (dDtFimPer2 == dDtFimPer1 .And. nHrFimPer2 < nHrFimPer1)))

		If !lSubstitui
			lSubstitui := nTmpRec2 < nTmpRec1
		EndIf
	EndIf

Return lSubstitui

/*/{Protheus.doc} getParametrosAlocacao
Retorna os parâmetros utilizados para simular a alocação da operação em um recurso.

@author Lucas fagundes
@since 23/10/2024
@version P12
@param 01 aOperacao, Array   , Operação que irá recuperar os parâmetros.
@param 02 cRecurso , Caracter, Recurso que simulou a alocação.
@param 03 lEntrega , Lógico  , Retorna por referência se a operação foi alocada pela data de entrega.
@param 04 dData    , Date    , Retorna por referência a data que iniciou a alocação da operação na simulação.
@param 05 nHora    , Numerico, Retorna por referência a hora que iniciou a alocação da operação na simulação.
@param 06 lEntJunto, Logico  , Retorna por referência se a operação entrega junto da anterior.
@return Nil
/*/
Method getParametrosAlocacao(aOperacao, cRecurso, lEntrega, dData, nHora, lEntJunto) Class PCPA152Nivelamento
	Local aGlobal := {}
	Local cChave  := Self:getChaveAlocacao(aOperacao, cRecurso)

	aGlobal := _Super:retornaListaGlobal("ALOCACOES_NIVELAMENTO", cChave)

	lEntrega  := aGlobal[INFO_ALOCACOES_ENTREGA      ]
	dData     := aGlobal[INFO_ALOCACOES_DATA         ]
	nHora     := aGlobal[INFO_ALOCACOES_HORA         ]
	lEntJunto := aGlobal[INFO_ALOCACOES_ENTREGA_JUNTO]

Return

/*/{Protheus.doc} avaliaSobreposicao
Sobreescreve o método da classe pai, adicionando a validação de redução de setup.

@author Lucas Fagundes
@since 19/11/2024
@version P12
@param 01 aOperacao  , Array   , Operação que esta sendo alocada.
@param 02 aDatas     , Array   , Array com as informações de data para a alocação (retorno do método getDataOperacao).
@param 03 lEntrega   , Lógico  , Indica se a operação alocou por data de entrega (retorna por referencia valor atualizado, caso realocou a operação).
@param 04 aPeriodos  , Array   , Periodos encontrados para a operação (retorna por referencia valor atualizado, caso realocou a operação).
@param 05 dData      , Date    , Data que realizou a alocação da operação (retorna por referencia valor atualizado, caso realocou a operação).
@param 06 nHora      , Numerico, Hora que realizou a alocação da operação (retorna por referencia valor atualizado, caso realocou a operação).
@param 07 lDistTudo  , Lógico  , Indica se alocou completamente a operação (retorna por referencia valor atualizado, caso realocou a operação).
@param 08 lGeraAdc   , Lógico  , Indica se pode gerar disponibilidade adicional na alocação da operação.
@param 09 cRecurso   , Caracter, Recurso que a operação está sendo alocada.
@param 10 aDispRecur , Array   , Disponibilidade do recurso que a operação está sendo alocada.
@param 11 cIndices   , Caracter, Indices da disponibilidade do recurso que a operação está sendo alocada.
@param 12 cIndcAloc  , Caracter, Indices com alocação na disponibilidade do recurso que a operação está sendo alocada.
@param 13 lEntJunto  , Lógico  , Retorna por referência se precisou realocar a operação para entregar junto da operação anterior.
@param 14 aAlocOrig  , Array   , Array com as informações de alocação original da operação (redução de setup).
@param 15 aFerramenta, Array   , Ferramentas utilizadas na alocação.
@param 16 cJsFerram  , Caracter, Backup da utilização das ferramentas, usado na alocação.
@return Nil
/*/
Method avaliaSobreposicao(aOperacao, aDatas, lEntrega, aPeriodos, dData, nHora, lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, lEntJunto, aAlocOrig, aFerramenta, cJsFerram) Class PCPA152Nivelamento
	Local nTamPer  := 0
	Local lRealoca := .F.

	_Super:avaliaSobreposicao(aOperacao, aDatas, @lEntrega, @aPeriodos, @dData, @nHora, @lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, .F., .F., .T., @lEntJunto, aFerramenta, cJsFerram)

	If !Self:lRedSetup
		Return Nil
	EndIf

	nTamPer  := Len(aPeriodos)
	lRealoca := nTamPer == 0

	// Evita mover a árvore para fora do periodo da programação durante a redução de setup:
	// Se a operação foi alocada por data de entrega, a nova alocação não pode ser iniciada antes do inicio do nivelamento original
	// Se a operação NÃO foi alocada por data de entrega, a nova alocação não pode ser terminar após a entrega do nivelamento original.
	If !lRealoca
		If lEntrega
			lRealoca := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA] <  aAlocOrig[ALOCACAO_ORIGINAL_INI_DATA] .Or.;
			           (aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA] == aAlocOrig[ALOCACAO_ORIGINAL_INI_DATA] .And. aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_INICIO] < aAlocOrig[ALOCACAO_ORIGINAL_INI_HORA])

			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao alocou antes da data de inicio calculada no nivelamento.",;
				                                     "Inicio calculado no nivelamento: "      + DToC(aAlocOrig[ALOCACAO_ORIGINAL_INI_DATA])    + ", " + __Min2Hrs(aAlocOrig[ALOCACAO_ORIGINAL_INI_HORA], .T.),;
				                                     "Inicio calculado na reducao do setup: " + DToC(aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]) + ", " + __Min2Hrs(aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.),;
				                                     "Realoca encerrando na data planejada no nivelamento."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		Else
			lRealoca := aPeriodos[nTamPer][ARRAY_DISPONIBILIDADE_DATA] >  aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA] .Or.;
			           (aPeriodos[nTamPer][ARRAY_DISPONIBILIDADE_DATA] == aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA] .And. aPeriodos[nTamPer][ARRAY_DISPONIBILIDADE_HORA_FIM] > aAlocOrig[ALOCACAO_ORIGINAL_FIM_HORA])

			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao alocou apos a data de entrega calculada no nivelamento.",;
				                                     "Entrega calculada no nivelamento: "      + DToC(aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA])          + ", " + __Min2Hrs(aAlocOrig[ALOCACAO_ORIGINAL_FIM_HORA], .T.),;
				                                     "Entrega calculada na reducao do setup: " + DToC(aPeriodos[nTamPer][ARRAY_DISPONIBILIDADE_DATA]) + ", " + __Min2Hrs(aPeriodos[nTamPer][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.),;
				                                     "Realoca encerrando na data planejada no nivelamento."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		EndIf
	EndIf

	If lRealoca
		dData := aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA]
		nHora := aAlocOrig[ALOCACAO_ORIGINAL_FIM_HORA]
		lEntrega := .T.

		_Super:preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, cJsFerram)
		aPeriodos := _Super:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lDistTudo, lGeraAdc, .F., .F., cRecurso, .T., aFerramenta)
	EndIf

Return Nil
