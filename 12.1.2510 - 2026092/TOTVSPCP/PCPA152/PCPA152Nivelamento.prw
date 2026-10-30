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
	Private Method getOperacsOrdenadas(cChave, lLogaRepro, cOpPai, lOrdena)
	Private Method gravaParamAlocOper(aOperacao, lDeleta, lDataProg, lEntrega, lDataDaOP, oSeqFerr)
	Private Method ordemPaiNivelouPeloInicio(aOperacao)
	Private Method recuperaParamAlocOper(aOperacao, lDataProg, lEntrega, lDataDaOP, lInicio, oSeqFerr)
	Private Method validaDatasOp()
	Public Method executaSimulacao(cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet)
	Private Method getChaveAlocacao(aOperacao, cRecurso, cSeqFerr)
	Private Method simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig, cSeqFerr)
	Private Method avaliaSimulacao(aOperacao, lEntrega, cFerrEfet, cFiltRec)
	Private Method getParametrosAlocacao(aOperacao, cRecurso, lEntrega, dData, nHora, lEntJunto, cSeqFerr, aFerramenta)
	Private Method avaliaSobreposicao(aOperacao, aDatas, lEntrega, aPeriodos, dData, nHora, lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, lEntJunto, aAlocOrig, aFerramenta, cJsFerram)
	Private Method getFerramentaBySeq(aOperacao, cSeqFerr)

	// Métodos para o Nivelamento
	Private Method adicionaOrdemNiveladaPeloInicio(cOrdem)
	Private Method atualizaPercentual(nQtdProc, nTotProc)
	Private Method desfazArvore(lLog, aOperacao)
	Private Method efetivaOperacoesAlocadas()
	Private Method iniciaArvores()
	Private Method ordemNivelaPelaDataDeInicio(aOperacao)
	Private Method preparaOperacoes()
	Private Method removeOrdemNiveladaPeloInicio(cOrdem)
	Private Method alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, lDistTudo, lDispAdc, cRecurso, lAlocPost, lRetCria, aAlocOrig, lEntJunto, dDataAlo, nHoraAlo, cSeqFerr, oSeqFerr)
	Private Method validaPeriodosAlternativo(aPeriodos1, aPeriodos2, lEntrega, nTmpRec1, nTmpRec2)

	// Métodos para a Redução de Setup
	Private Method ajustaOcorrencias()
	Private Method alterouAlocacao(aAlocado, aNovaAloc)
	Private Method avaliaOperacao(aOperacao, oRecursos, oArvores, oAlterados, lInicio, oFerrament, oSeqFerr)
	Private Method getAlocacaoSVM(aOperacao)
	Private Method buscaHoraRecurso(aOperacao, dData, nHora, lFinal, lEncontrou, cRecurso)
	Private Method carregaArvoresParaReprocessar(oArvores, oRecursos, oFerrament)
	Private Method carregaJaNivelados(aOperacao, lInicio)
	Private Method existeDisponibilidade(aOperacao, lEntrega, dDataDisp, nHoraDisp, dIniOper, nHrIniOper, dFimOper, nHrFimOper, cRecurso)
	Private Method existeTempoDisponivel(aOperacao, aIndices, cRecurso)
	Private Method gravaArvoreSetupDuplicado(cRecurso, oArvores, oFerrame)
	Private Method produtoAlocacaoAnteriorIgual(aAlocAnt, aDispRecur, cProduto)
	Private Method realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP, oSeqFerr, aRecsAlt, aFersAlt)
	Private Method recuperaIndicesTemposOperacao(aOperacao, oAlocado, cRecurso)
	Private Method registraRealocado(aOperacao)
	Private Method removeAlocacaoDisponibilidade(aDispRecur, nIndDisp, nRemove, oIndices)
	Private Method removeOperacao(oAlocado, aOperacao, cRecurso)
	Private Method substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc, cRecurso)
	Private Method verificaMudancaOperacao(oAlocado, lInicio, aOperacao, lDataDaOP, lDataProg)

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
	Self:oParamNiv["utilizaFerramentas"] := _Super:retornaParametro("utilizaFerramentas")

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
	Local aRecursos  := {}
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
	Local nIndRec    := 0
	Local nIniArvore := 1
	Local nTotal     := 0
	Local nTotRec    := 0
	Local oPeriodos  := Nil
	Local oSeqFerr   := Nil

	Self:cEtapaLog := CHAR_ETAPAS_NIVELAMENTO
	nTotal := Len(Self:aOperacoes)

	While nIndex <= nTotal .And. _Super:permiteProsseguir()
		aOperacao := Self:aOperacoes[nIndex]
		cArvore   := aOperacao[ARRAY_MF_ARVORE]
		cOrdem    := aOperacao[ARRAY_MF_OP]
		oSeqFerr  := JsonObject():New()

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

			oPeriodos := Self:alocaOperacao(aOperacao, lEntrega, lTrocouAr, .F., @lDistTudo, .F., @cRecAloc, Nil, Nil, Nil, @lEntJunto, @dDataAlo, @nHoraAlo, Nil, @oSeqFerr)

			If lDistTudo
				aRecursos := oPeriodos:getNames()
				nTotRec   := Len(aRecursos)

				For nIndRec := 1 To nTotRec
					cRecurso  := aRecursos[nIndRec]
					aPeriodos := oPeriodos[cRecurso]

					_Super:validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto, .F., dDataAlo, nHoraAlo)
					_Super:adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecurso, aOperacao[ARRAY_MF_SOBREPO])
				Next
				Self:gravaParamAlocOper(aOperacao, .F., .F., lEntrega, lTrocouAr, oSeqFerr)
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
	Local nIndex := 1
	Local nTotal := Len(aOperacoes)

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
	Local aRecursos  := {}
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
	Local nIndRec    := 0
	Local nTotal     := Len(aOperacoes)
	Local nTotRec    := 0
	Local oAlocacoes := Nil
	Local oSeqFerr   := Nil

	Self:cEtapaLog := CHAR_ETAPAS_NIVELAMENTO

	While nIndOper <= nTotal .And. _Super:permiteProsseguir() .And. lSucesso
		aOperacao  := aOperacoes[nIndOper]
		cOrdem     := aOperacao[ARRAY_MF_OP]
		oSeqFerr   := JsonObject():New()

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

		oAlocacoes := Self:alocaOperacao(aOperacao, .F., .F., .T., @lDistTudo, .T., @cRecAloc, @lDispAdc, @lCriouDisp, Nil, @lEntJunto, @dDataAlo, @nHoraAlo, Nil, @oSeqFerr)

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
			aRecursos := oAlocacoes:getNames()
			nTotRec   := Len(aRecursos)

			For nIndRec := 1 To nTotRec
				cRecurso  := aRecursos[nIndRec]
				aPeriodos := oAlocacoes[cRecurso]

				_Super:validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecurso, .F., lEntJunto, .F., dDataAlo, nHoraAlo)
				_Super:adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecurso, aOperacao[ARRAY_MF_SOBREPO])
			Next

			Self:gravaParamAlocOper(aOperacao, .F., .T., .F., .F., oSeqFerr)
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
	Local cRecAux  := ""
	Local dData    := Nil
	Local dIniProg := PCPConvDat((Self:oParamNiv["dataInicial"]), 1)
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
					cRecAux  := _Super:getRecByAloc(Self:aAlocados[nIndNive][ALOCADOS_POS_ALOCACOES], .T.)
					aPeriodo := Self:aAlocados[nIndNive][ALOCADOS_POS_ALOCACOES][cRecAux][1]
					Exit
				Else
					cRecAux := _Super:getRecByAloc(Self:aAlocados[nIndNive][ALOCADOS_POS_ALOCACOES], .F.)
					aPerAux := aTail(Self:aAlocados[nIndNive][ALOCADOS_POS_ALOCACOES][cRecAux])

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
				nHora := Self:buscaHoraRecurso(aOperacao, dData, nHora, .T., Nil, cRecurso)
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
				nHora := Self:buscaHoraRecurso(aOperacao, dData, nHora, .F., Nil, cRecurso)
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
	Local aRecursos  := {}
	Local cChaveArv  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local cOrdem     := ""
	Local cRecurso   := ""
	Local cUltimaOP  := ""
	Local nIndex     := 1
	Local nIndPer    := 1
	Local nIndRec    := 0
	Local nTotal     := Len(Self:aAlocados)
	Local nTotPer    := 0
	Local nTotRec    := 0
	Local oAlocacoes := Nil
	Local oLogsRmv   := JsonObject():New()
	Local oOPsLog    := Nil
	Local oOPsRemv   := JsonObject():New()

	oLogsRmv[LOG_ALOCOU_ALTERNATIVO     ] := .T.
	oLogsRmv[LOG_ALOCOU_COM_SOBREPOSICAO] := .T.
	oLogsRmv[LOG_ENTREGOU_JUNTO         ] := .T.
	oLogsRmv[LOG_OPERACAO_NAO_VALIDADE  ] := .T.
	oLogsRmv[LOG_OPERACAO_FORA_PREVISTO ] := .T.
	oLogsRmv[LOG_OPERACAO_DESDOBRADA    ] := .T.
	oLogsRmv[LOG_ALOCOU_FERRAMENTA_ALTERNATIVA] := .T.
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
			oAlocacoes := Self:aAlocados[nIndex][ALOCADOS_POS_ALOCACOES]
			aRecursos  := oAlocacoes:getNames()
			nTotRec    := Len(aRecursos)

			For nIndRec := 1 To nTotRec
				cRecurso   := aRecursos[nIndRec]
				aPeriodos  := oAlocacoes[cRecurso]
				nTotPer    := Len(aPeriodos)
				aLogPer    := Array(nTotPer+2)

				aLogPer[1] := "--- Liberados os seguintes periodos - ordem " + aOperacao[ARRAY_MF_OP] + " operacao " + aOperacao[ARRAY_MF_OPER] + " recurso " + cRecurso + " ---"
				For nIndPer := 1 To nTotPer
					aLogPer[nIndPer+1] := DToC(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_DATA])                             + ;
										" inicio " + __Min2Hrs(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + ;
										" fim "    + __Min2Hrs(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_FIM]   , .T.) + ;
										" tempo total " + cValToChar(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO]) + " minutos"
				Next nIndPer
				aLogPer[nTotPer+2] := "--------------------------------------------------------------------------"

				Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, aLogPer, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, cChaveArv)

				aSize(aLogPer  , 0)
				aSize(aPeriodos, 0)
			Next

			oAlocacoes := Nil
			aSize(aRecursos, 0)
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
	Local cOpPai   := ""
	Local lNivelou := .F.

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
	Local cRecAux    := ""
	Local dDatFimPer := Nil
	Local dDatIniPer := Nil
	Local nIndex     := 0
	Local nTotal     := Len(Self:aAlocados)
	Local oAlocacoes := Nil

	For nIndex := 1 To nTotal
		aOperacao  := Self:aAlocados[nIndex][ALOCADOS_POS_OPERACAO ]
		oAlocacoes := Self:aAlocados[nIndex][ALOCADOS_POS_ALOCACOES]

		cRecAux   := _Super:getRecByAloc(oAlocacoes, .T.)
		aPeriodos := oAlocacoes[cRecAux]

		If dDatIniPer == Nil .Or. dDatIniPer > aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
			dDatIniPer := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
		EndIf

		cRecAux   := _Super:getRecByAloc(oAlocacoes, .F.)
		aPeriodos := oAlocacoes[cRecAux]

		If dDatFimPer == Nil .Or. dDatFimPer < aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
			dDatFimPer := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
		EndIf

		If nIndex == nTotal .Or. aOperacao[ARRAY_MF_OP] != Self:aAlocados[nIndex+1][ALOCADOS_POS_OPERACAO][ARRAY_MF_OP]
			_Super:validaDatasOp(aOperacao, dDatIniPer, dDatFimPer)

			dDatIniPer := Nil
			dDatFimPer := Nil
		EndIf
	Next

	aOperacao  := {}
	aPeriodos  := {}
	oAlocacoes := Nil
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
	Local aFerrAlt   := Nil
	Local aFerrams   := {}
	Local aOperacao  := Nil
	Local aRecsAlt   := Nil
	Local cArvore    := ""
	Local lDataDaOP  := .F.
	Local lDataProg  := .F.
	Local lEntrega   := .F.
	Local lInicio    := .F.
	Local lMoveuOper := .T.
	Local nIndex     := 0
	Local nIndFerra  := 0
	Local nIndRec    := 0
	Local nLoop      := 0
	Local nTotal     := Len(Self:aOperacoes)
	Local nTotFerra  := 0
	Local nTotRec    := 0
	Local oAlterados := JsonObject():New()
	Local oArvores   := JsonObject():New()
	Local oFerrament := JsonObject():New()
	Local oRecursos  := JsonObject():New()
	Local oSeqFerr   := Nil

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
			Self:recuperaParamAlocOper(aOperacao, @lDataProg, @lEntrega, @lDataDaOP, @lInicio, @oSeqFerr)

			If Self:avaliaOperacao(aOperacao, @oRecursos, @oArvores, @oAlterados, lInicio, @oFerrament, oSeqFerr)

				If Self:realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP, oSeqFerr, @aRecsAlt, @aFerrAlt)
					lMoveuOper := .T.

					//Atualiza JSON de controle para adicionar, caso não exista, o recurso/arvore.
					oArvores[cArvore] := .T.

					nTotRec := Len(aRecsAlt)
					For nIndRec := 1 To nTotRec
						oRecursos[aRecsAlt[nIndRec]] := .T.
						oAlterados["recursos"][aRecsAlt[nIndRec]] := .T.
					Next

					oAlterados["ordens"][aOperacao[ARRAY_MF_OP]] := .T.
					If !lDataProg
						oAlterados["arvores"][cArvore] := .T.
					EndIf

					If lInicio //Se aloca por início já adiciona a OP PAI para reprocessar.
						oAlterados["ordens"][aOperacao[ARRAY_PROC_OP_PAI]] := .T.
					EndIf

					If !Empty(aFerrAlt)
						nTotRec := Len(aFerrAlt)

						For nIndRec := 1 To nTotRec
							aFerrams  := Self:getFerramentaBySeq(aOperacao, aFerrAlt[nIndRec])
							nTotFerra := Len(aFerrams)

							For nIndFerra := 1 To nTotFerra
								oAlterados["ferramentas"][aFerrams[nIndFerra][ARRAY_HZJ_FERRAM]] := .T.
							Next

							aFerrams := {}
						Next
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
@param 01 aOperacao , Array   , informações da operação (SMF).
@param 02 oRecursos , Object  , json com os recursos em reprocessamento
@param 03 oArvores  , Object  , json com as árvores em reprocessamento
@param 04 oAlterados, Object  , json com as OPS alteradas
@param 05 lInicio   , Logic   , Indica que a operação aloca pelo início
@param 06 oFerrament, Object  , json com as ferramentas em reprocessamento
@param 07 oSeqFerr  , Object  , Sequência das ferramentas da operação
@return lAvalia, Logic, Retorna se houve alteração na alocação do recurso.
/*/
Method avaliaOperacao(aOperacao, oRecursos, oArvores, oAlterados, lInicio, oFerrament, oSeqFerr) Class PCPA152Nivelamento
	Local aChaves  := {}
	Local aFerrams := {}
	Local cArvore  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local lAvalia  := .F.
	Local nIndeFer := 0
	Local nIndRec  := 0
	Local nTotFerr := 0
	Local nTotRec  := 0

	lAvalia := oArvores:hasProperty(cArvore) .And. oAlterados["ordens"]:hasProperty(aOperacao[ARRAY_MF_OP])

	If !lAvalia
		If _Super:desdobraOperacao(aOperacao)
			nTotRec := Len(aOperacao[ARRAY_PROC_RECURSOS])
			For nIndRec := 1 To nTotRec
				If oRecursos:hasProperty(aOperacao[ARRAY_PROC_RECURSOS][nIndRec][ARRAY_HZ7_RECURS])
					lAvalia := .T.
					Exit
				EndIf
			Next
		Else
			lAvalia := oRecursos:hasProperty(aOperacao[ARRAY_MF_RECURSO])
		EndIf
	EndIf

	If !lAvalia
		aChaves := oSeqFerr:getNames()
		nTotRec := Len(aChaves)

		For nIndRec := 1 To nTotRec
			aFerrams := Self:getFerramentaBySeq(aOperacao, oSeqFerr[aChaves[nIndRec]])
			nTotFerr := Len(aFerrams)

			For nIndeFer := 1 To nTotFerr
				If oFerrament:hasProperty(aFerrams[nIndeFer][ARRAY_HZJ_FERRAM])
					lAvalia := .T.
					Exit
				EndIf
			Next

			aFerrams := {}

			If lAvalia
				Exit
			EndIf
		Next
	EndIf

	If !lAvalia .And. oArvores:hasProperty(cArvore)

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
@param 01 aOperacao, Array , informações da operação (SMF) para realocação.
@param 02 lInicio  , Logic , indica se a operação aloca por início
@param 03 lDataProg, Logic , Indica se aloca por data da programação
@param 04 lEntrega , Logic , Indica se aloca por data de entrega
@param 05 lDataDaOP, Logic , Indica se usa a data da OP
@param 06 oSeqFerr , Object, Sequência das ferramentas da operação
@param 07 aRecsAlt , Array , Retorna por referencia os recursos alterados.
@param 08 aFersAlt , Array , Retorna por referencia as ferramentas alteradas.
@return lRetAlt, Logic, Retorna se houve alteração na alocação do recurso.
/*/
Method realocaOperacao(aOperacao, lInicio, lDataProg, lEntrega, lDataDaOP, oSeqFerr, aRecsAlt, aFersAlt) Class PCPA152Nivelamento
	Local aAlocado  := Nil
	Local aAlocOrig := Nil
	Local aNovaAloc := Nil
	Local aPeriodos := Nil
	Local aRecursos := {}
	Local cRecurso  := ""
	Local cSeqFerr  := ""
	Local dDataAloc := Nil
	Local lAlterou  := .F.
	Local lContinua := .T.
	Local lDistTudo := .F.
	Local lEntJunto := .F.
	Local lRetAlt   := .F.
	Local nHoraAloc := 0
	Local nIndRec   := 0
	Local nTotRec   := 0
	Local oAlocado  := Nil
	Local oNovaAloc := Nil
	Local oRecsAlt  := Nil

	aRecsAlt := {}
	aFersAlt := {}

	If Self:oLogs:logAtivo()
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
		                    {"Avaliando realocacao. Ordem: "            + aOperacao[ARRAY_MF_OP     ] +;
		                                         ", Operacao: "         + aOperacao[ARRAY_MF_OPER   ] +;
		                                         ", Recurso: "          + aOperacao[ARRAY_MF_RECURSO]},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	//Cria BKP das alocações atuais desta operação
	oAlocado := Self:getAlocacaoSVM(aOperacao)

	If Empty(oAlocado:getNames())
		//Não tenta alocar operações que não foram alocadas inicialmente.
		lContinua := .F.
	EndIf

	If lContinua
		//Recupera os parâmetros que devem ser utilizados para executar a alocação da operação
		Self:carregaJaNivelados(aOperacao, lInicio)

		//Verifica se a operação terá alguma mudança.
		oRecsAlt  := Self:verificaMudancaOperacao(oAlocado, lInicio, aOperacao, lDataDaOP, lDataProg)
		lContinua := oRecsAlt["mudou"]
	EndIf

	If lContinua
		aRecursos := oAlocado:getNames()
		nTotRec   := Len(aRecursos)

		For nIndRec := 1 To nTotRec
			cRecurso := aRecursos[nIndRec]
			aAlocado := oAlocado[cRecurso]
			cSeqFerr := ""

			If !oRecsAlt[cRecurso]
				Loop
			EndIf

			If oSeqFerr:hasProperty(cRecurso)
				cSeqFerr := oSeqFerr[cRecurso]
			EndIf

			aAlocOrig := Array(ALOCACAO_ORIGINAL_TAMANHO)
			aAlocOrig[ALOCACAO_ORIGINAL_INI_DATA] := aAlocado[1][ARRAY_VM_DATA]
			aAlocOrig[ALOCACAO_ORIGINAL_INI_HORA] := __Hrs2Min(aAlocado[1][ARRAY_VM_INICIO])
			aAlocOrig[ALOCACAO_ORIGINAL_FIM_DATA] := aTail(aAlocado)[ARRAY_VM_DATA]
			aAlocOrig[ALOCACAO_ORIGINAL_FIM_HORA] := __Hrs2Min(aTail(aAlocado)[ARRAY_VM_FIM])

			//Remove a alocação desta operação
			Self:removeOperacao(oAlocado, aOperacao, cRecurso)

			//Aloca novamente a operação e verifica se houve mudança na alocação.
			Self:cEtapaLog := CHAR_ETAPAS_REDUZ_SETUP
			oNovaAloc := Self:alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, @lDistTudo, .T., cRecurso, Nil, Nil, aAlocOrig, @lEntJunto, @dDataAloc, @nHoraAloc, cSeqFerr)
			aPeriodos := oNovaAloc[cRecurso]
			aNovaAloc := _Super:geraPeriodosOperacao(aOperacao, aPeriodos)
			lAlterou  := Self:alterouAlocacao(aAlocado, aNovaAloc)

			//Se alterou a alocação substitui os dados da SVM e oDispRecur. Caso contrário recupera o BKP com a alocação original.
			If lAlterou
				lRetAlt := lRetAlt .Or. lAlterou

				Self:substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc, cRecurso)

				//Registra esta árvore como alterada para avaliar as ocorrências ao término do processo.
				Self:registraRealocado(aOperacao)

				aAdd(aRecsAlt, cRecurso)
				If !Empty(cSeqFerr)
					aAdd(aFersAlt, cSeqFerr)
				EndIf
			EndIf

			aSize(aNovaAloc, 0)
			aSize(aPeriodos, 0)
			aSize(aAlocOrig, 0)
		Next

		aSize(aRecursos, 0)
	Else
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, {"Operacao nao sera realocada"}, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	FreeObj(oAlocado)
Return lRetAlt

/*/{Protheus.doc} verificaMudancaOperacao
Verifica se a operação possui alguma alteração que faça necessário realocar.

@author lucas.franca
@since 28/06/2024
@version P12
@param 01 oAlocado , Object, JSON com as alocações da operação agrupadas por recurso
@param 02 lInicio  , Logic, Indica se a operação aloca pelo início
@param 03 aOperacao, Array, Dados da operação
@param 04 lDataDaOP, Logic, Indica se usa a data da OP
@param 05 lDataProg, Logic, Indica se aloca por data da programação
@return oRecsRealo, Object, JSON com os recursos que precisam ser realocados.
/*/
Method verificaMudancaOperacao(oAlocado, lInicio, aOperacao, lDataDaOP, lDataProg) Class PCPA152Nivelamento
	Local aAlocAnt   := {}
	Local aDataLog   := Nil
	Local aDatas     := {}
	Local aIndices   := {}
	Local aRecursos  := oAlocado:getNames()
	Local cRecurso   := ""
	Local dData      := Nil
	Local dFimOper   := Nil
	Local dIniOper   := Nil
	Local lEntrega   := !lInicio
	Local lIgual     := .F.
	Local lMudou     := .F.
	Local lRecIlimi  := .F.
	Local lSetupAloc := .F.
	Local nHora      := 0
	Local nHrFimOper := 0
	Local nHrIniOper := 0
	Local nIndRecur  := 1
	Local nTotRecur  := Len(aRecursos)
	Local oDisp      := Nil
	Local oRecsRealo := JsonObject():New()

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	oRecsRealo["mudou"] := .F.

	For nIndRecur := 1 To nTotRecur
		cRecurso  := aRecursos[nIndRecur]
		lMudou    := .F.
		lRecIlimi := oDisp:recursoIlimitado(cRecurso)
		aIndices  := Self:recuperaIndicesTemposOperacao(aOperacao, oAlocado, cRecurso)

		oRecsRealo[cRecurso] := .F.

		If _Super:alocaComSobreposicao(aOperacao, lEntrega, cRecurso)
			lMudou := .T.

		Else
			aDatas := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecurso)

			dData := aDatas[RET_GET_DATA_DATA]
			nHora := aDatas[RET_GET_DATA_HORA]

			dIniOper   := oAlocado[cRecurso][1][ARRAY_VM_DATA]
			nHrIniOper := __Hrs2Min(oAlocado[cRecurso][1][ARRAY_VM_INICIO])

			dFimOper   := aTail(oAlocado[cRecurso])[ARRAY_VM_DATA]
			nHrFimOper := __Hrs2Min(aTail(oAlocado[cRecurso])[ARRAY_VM_FIM])

		EndIf

		If !lMudou .And. ((lInicio  .And. (dData <> dIniOper .Or. nHora <> nHrIniOper )) .Or. ; //Aloca por início e irá alocar no mesmo horário anterior
		                  (lEntrega .And. (dData <> dFimOper .Or. nHora <> nHrFimOper )))        //Aloca por entrega e irá entregar no mesmo horário anterior

			//Verifica se entre a nova data/hora, e a data/hora original da operação
			//existe alguma disponibilidade que possa ser utilizada.
			lMudou := lRecIlimi .Or. Self:existeDisponibilidade(aOperacao, lEntrega, dData, nHora, dIniOper, nHrIniOper, dFimOper, nHrFimOper, cRecurso)

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
									", Recurso: "  + cRecurso,;
									" Alocando por " + aDataLog[1] +;
									". Data/hora original da operacao " + aDataLog[2] + " - " + aDataLog[3] +;
									". Nova data/hora da operacao " + DtoC(dData) + " - " + __Min2Hrs(nHora, .T.),;
									Replicate("-",70)  },;
									aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

				aSize(aDataLog, 0)
			EndIf
		EndIf

		//Se não mudou a hora início ou fim, mas a operação possui setup, verifica se vai precisar fazer alguma mudança no setup já alocado.
		If !lMudou .And. aOperacao[ARRAY_MF_SETUP] > 0 .And. !lRecIlimi
			lSetupAloc := oAlocado[cRecurso][1][ARRAY_VM_TIPO] == VM_TIPO_SETUP

			//Ver alocação anterior se é do mesmo produto.
			aAlocAnt := Array(ARRAY_OPER_ANTERIOR_TAMANHO)
			_Super:buscaAlocAnterior(@aAlocAnt, cRecurso, aIndices[1][INDICE_TEMPOS_POS_DISPONIBILIDADE], aIndices[1][INDICE_TEMPOS_POS_TEMPOS])

			lIgual := Self:produtoAlocacaoAnteriorIgual(aAlocAnt, Self:oDispRecur[cRecurso], aOperacao[ARRAY_PROC_PRODUTO])
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
								" Ordem: "     + aOperacao[ARRAY_MF_OP     ] +;
								", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
								", Recurso: "  + cRecurso,;
								" Alocacao anterior possui produto " + aDataLog[1] +;
								" e esta operacao" + aDataLog[2] + "possui setup alocado ",;
								Replicate("-",70)},;
								aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

					aSize(aDataLog, 0)
				EndIf
			EndIf
		EndIf

		//Se não mudou mas está programando permitindo quebra da alocação e o recurso não for ilimitado,
		//verifica se existe algum período livre entre o início e o término dessa operação.
		If !lMudou .And. Self:oParamNiv["quebraOperacoes"] .And. !lRecIlimi
			If Self:existeTempoDisponivel(aOperacao, aIndices, cRecurso)
				lMudou := .T.

				Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP,;
				                   {"Existe periodo disponivel entre o inicio/fim da alocacao da operacao." +;
				                   " Ordem: "     + aOperacao[ARRAY_MF_OP     ] +;
				                   ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
				                   ", Recurso: "  + cRecurso},;
				                   aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf
		EndIf

		aSize(aIndices, 0)

		If lMudou
			oRecsRealo["mudou" ] := .T.
			oRecsRealo[cRecurso] := .T.
		EndIf
	Next

Return oRecsRealo

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
@param 09 cRecurso  , Caracter, Recurso que irá verificar a disponibilidade
@return lMudou, Logic, indica se haverá mudança entre a hora já alocada e a hora disponível para alocar
/*/
Method existeDisponibilidade(aOperacao, lEntrega, dDataDisp, nHoraDisp, dIniOper, nHrIniOper, dFimOper, nHrFimOper, cRecurso) Class PCPA152Nivelamento
	Local dData      := Nil
	Local dFimBusca  := dIniOper
	Local dIniBusca  := dDataDisp
	Local lEncontrou := .F.
	Local lMudou     := .F.
	Local nHoraOper  := nHrIniOper
	Local nNewHora   := nHoraDisp
	Local nStep      := 1

	If lEntrega
		dFimBusca := dFimOper
		nHoraOper := nHrFimOper
		nStep     := -1
	EndIf

	For dData := dIniBusca To dFimBusca Step nStep
		nNewHora := Self:buscaHoraRecurso(aOperacao, dData, nNewHora, lEntrega, @lEncontrou, cRecurso)
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
Method substituiAlocacao(aOperacao, aNovaAloc, aAlocado, lEntrega, aPeriodos, lEntJunto, dDataAloc, nHoraAloc, cRecurso) Class PCPA152Nivelamento
	Local aDetRec    := _Super:getInfoRecurso(aOperacao, cRecurso)
	Local aSVM       := Nil
	Local cChaveSVM  := _Super:chaveListaDadosSVM(aOperacao)
	Local nIndex     := 0
	Local nRemovidos := 0
	Local nTotal     := 0

	If Self:oLogs:logAtivo()
		Self:oLogs:gravaLog(CHAR_ETAPAS_REDUZ_SETUP, logAlter(aOperacao, aAlocado, aNovaAloc, lEntrega, cRecurso), aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	//Remove da global os dados da operação alocada
	aSVM   := _Super:retornaListaGlobal(LISTA_DADOS_SVM, cChaveSVM)
	nTotal := Len(aSVM)

	For nIndex := nTotal To 1 Step -1
		If aSVM[nIndex][ARRAY_VM_ID] == aOperacao[ARRAY_MF_ID] .And. aSVM[nIndex][ARRAY_VM_PROC_RECURSO] == cRecurso
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
		nTotal := Len(aSVM)
		For nIndex := 1 To nTotal
			Self:oFerramentas:setSeqSVM(aOperacao[ARRAY_MF_ID], DToS(aSVM[nIndex][ARRAY_VM_DATA]), aSVM[nIndex][ARRAY_VM_INICIO], aSVM[nIndex][ARRAY_VM_FIM], aSVM[nIndex][ARRAY_VM_SEQ])
		Next

		Self:oFerramentas:removePeriodosEfetivados(aOperacao[ARRAY_MF_ID], aDetRec[ARRAY_HZ7_SEQ])
		Self:oFerramentas:efetivaFerramentas()
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
@param 01 oAlocado , Object, alocações da operação (SVM)
@param 02 aOperacao, Array, informações da operação (SMF).
@param 03 cRecurso , Caracter, Recurso que irá remover a alocação
@return Nil
/*/
Method removeOperacao(oAlocado, aOperacao, cRecurso) Class PCPA152Nivelamento
	Local aDetRecur  := {}
	Local aDispRecur := Nil
	Local aIndices   := Nil
	Local cIndice    := ""
	Local dData      := Nil
	Local nIndDisp   := 0
	Local nIndex     := 0
	Local nTotal     := 0
	Local oDatas     := JsonObject():New()
	Local oIndDisp   := JsonObject():New()
	Local oIndice    := _Super:getJsonIndicesRecurso(cRecurso)

	aDispRecur  := Self:oDispRecur[cRecurso]
	aIndices    := Self:recuperaIndicesTemposOperacao(aOperacao, oAlocado, cRecurso)
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

	aDetRecur := _Super:getInfoRecurso(aOperacao, cRecurso)
	Self:oFerramentas:removeUtilizacaoLocal(aOperacao[ARRAY_MF_ID], aDetRecur[ARRAY_HZ7_SEQ])

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
Method recuperaIndicesTemposOperacao(aOperacao, oAlocado, cRecurso) Class PCPA152Nivelamento
	Local aAlocado   := {}
	Local aIndices   := {}
	Local aTempos    := Nil
	Local cData      := ""
	Local nHrFim     := 0
	Local nHrIni     := 0
	Local nIndAloc   := 0
	Local nIndDisp   := 0
	Local nIndTempos := 0
	Local nPos       := 0
	Local nTotAloc   := 0
	Local nTotTempos := 0
	Local oIndice    := Nil
	Default oAlocado := Self:getAlocacaoSVM(aOperacao)
	Default cRecurso := aOperacao[ARRAY_MF_RECURSO]

	aAlocado := oAlocado[cRecurso]
	nTotAloc := Len(aAlocado)
	oIndice  := _Super:getJsonIndicesRecurso(cRecurso)

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
@return oAlocado, Object, JSON com as alocações da operação agrupadas por recurso.
/*/
Method getAlocacaoSVM(aOperacao) Class PCPA152Nivelamento
	Local aSVM      := Nil
	Local cChaveSVM := _Super:chaveListaDadosSVM(aOperacao)
	Local cRecurso  := ""
	Local nIndex    := 0
	Local nTotal    := 0
	Local oAlocado  := JsonObject():New()

	aSVM   := _Super:retornaListaGlobal(LISTA_DADOS_SVM, cChaveSVM)
	nTotal := Len(aSVM)

	For nIndex := 1 To nTotal
		If aSVM[nIndex][ARRAY_VM_ID] == aOperacao[ARRAY_MF_ID]
			cRecurso := aSVM[nIndex][ARRAY_VM_PROC_RECURSO]

			If !oAlocado:hasProperty(cRecurso)
				oAlocado[cRecurso] := {}
			EndIf

			aAdd(oAlocado[cRecurso], aSVM[nIndex])
		EndIf
		aSVM[nIndex] := Nil
	Next nIndex

	aSize(aSVM, 0)

Return oAlocado

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
	Local lExiste := .F.
	Local nIndex  := 0
	Local nTotal  := 0

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
	Local aDisp      := Nil
	Local aIndices   := Nil
	Local aOperacoes := {}
	Local aOperAux   := {}
	Local aPeriodos  := {}
	Local aPosicoes  := {}
	Local aRecursos  := {}
	Local cChaveArv  := aOperacao[ARRAY_PROC_CHAVE_ARVORE]
	Local cRecurso   := ""
	Local nIndex     := 0
	Local nIndRec    := 0
	Local nIndTempos := 0
	Local nPosicao   := 0
	Local nTotal     := 0
	Local nTotRec    := 0
	Local nTotTempos := 0
	Local oAlocacoes := Nil

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
		aOperAux   := aOperacoes[nPosicao]
		oAlocacoes := Self:getAlocacaoSVM(aOperAux)
		aRecursos  := oAlocacoes:GetNames()
		nTotRec    := Len(aRecursos)

		For nIndRec := 1 To nTotRec
			cRecurso := aRecursos[nIndRec]
			aIndices   := Self:recuperaIndicesTemposOperacao(aOperAux, oAlocacoes, cRecurso)
			nTotTempos := Len(aIndices)

			For nIndTempos := 1 To nTotTempos
				aDisp := Self:oDispRecur[aIndices[nIndTempos][INDICE_TEMPOS_POS_RECURSO]][aIndices[nIndTempos][INDICE_TEMPOS_POS_DISPONIBILIDADE]]

				aAdd(aPeriodos, aDisp[ARRAY_DISP_RECURSO_DISPONIBILIDADE][aIndices[nIndTempos][INDICE_TEMPOS_POS_TEMPOS]])
			Next nIndTempos
			aDisp := Nil

			aPeriodos := _Super:adicionaTempoRemocao(aOperAux, aPeriodos)
			_Super:adicionaOperacaoAlocada(aOperAux, aPeriodos, cRecurso)

			aSize(aIndices, 0)
			aPeriodos := {}
		Next

		oAlocacoes := Nil
		aOperAux   := {}
		aSize(aRecursos, 0)
	Next nIndex

	aSize(aPosicoes, 0)
	aSize(aOperacoes, 0)

Return

/*/{Protheus.doc} gravaParamAlocOper
Grava os parâmetros utilizados durante a alocação da operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array , dados da operação (SMF).
@param 02 lDeleta  , Logic , Identifica se deve limpar o registro de parâmetros da operação.
@param 03 lDataProg, Logic , parâmetro se aloca por data da programação
@param 04 lEntrega , Logic , parâmetro se aloca por data de entrega
@param 05 lDataDaOP, Logic , parâmetro se usa a data da OP
@param 06 oSeqFerr , Object, Json com a sequência das ferramenta que foram utilizadas na operação.
@return Nil
/*/
Method gravaParamAlocOper(aOperacao, lDeleta, lDataProg, lEntrega, lDataDaOP, oSeqFerr) Class PCPA152Nivelamento

	If lDeleta
		Self:oAlocOper:delName(aOperacao[ARRAY_MF_ID])
	Else
		Self:oAlocOper[aOperacao[ARRAY_MF_ID]] := {lDataProg, lEntrega, lDataDaOP, oSeqFerr}
	EndIf

Return

/*/{Protheus.doc} recuperaParamAlocOper
Recupera os parâmetros utilizados durante a alocação da operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array , dados da operação (SMF).
@param 02 lDataProg, Logic , Retorna por referência parâmetro se aloca por data da programação
@param 03 lEntrega , Logic , Retorna por referência parâmetro se aloca por data de entrega
@param 04 lDataDaOP, Logic , Retorna por referência parâmetro se usa a data da OP
@param 05 lInicio  , Logic , Retorna por referência se a operação aloca por início
@param 06 oSeqFerr , Object, Retorna por referência a sequência das ferramentas que foram utilizadas na operação.
@return Nil
/*/
Method recuperaParamAlocOper(aOperacao, lDataProg, lEntrega, lDataDaOP, lInicio, oSeqFerr) Class PCPA152Nivelamento

	lDataProg := .F.
	lEntrega  := .F.
	lDataDaOP := .F.
	lInicio   := .F.
	oSeqFerr  := JsonObject():New()

	If Self:oAlocOper:hasProperty(aOperacao[ARRAY_MF_ID])
		lDataProg := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][1]
		lEntrega  := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][2]
		lDataDaOP := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][3]
		oSeqFerr  := Self:oAlocOper[aOperacao[ARRAY_MF_ID]][4]
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
	Local aOperacao  := Nil
	Local aOperacoes := Nil
	Local aOrdens    := Nil
	Local cChaveArv  := ""
	Local cRecurso   := ""
	Local dDataFim   := Nil
	Local dDataIni   := Nil
	Local nIndArv    := 0
	Local nIndOp     := 0
	Local nPosicao   := 0
	Local nTotArv    := Len(aChavesArv)
	Local nTotOp     := 0
	Local oAlocacao  := Nil
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

			//busca a data de início da primeira operação.
			nPosicao  := aScan(aOperacoes, {|x| x[ARRAY_MF_SALDO] > 0})
			aOperacao := aOperacoes[nPosicao]
			oAlocacao := Self:getAlocacaoSVM(aOperacao)
			cRecurso   := _Super:getRecByAloc(oAlocacao, .T., .T.)
			If !Empty(cRecurso)
				dDataIni  := oAlocacao[cRecurso][1][ARRAY_VM_DATA]
			EndIf
			oAlocacao := Nil

			//busca a data de término da última operação
			aOperacao := aTail(aOperacoes)
			oAlocacao := Self:getAlocacaoSVM(aOperacao)
			cRecurso   := _Super:getRecByAloc(oAlocacao, .F., .T.)
			If !Empty(cRecurso)
				dDataFim  := aTail(oAlocacao[cRecurso])[ARRAY_VM_DATA]
			EndIf
			oAlocacao := Nil

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
@param 06 cRecurso  , Caracter, Recurso que irá buscar o horario disponível.
@return nHora, Numeric, Hora disponível para uso do recurso
/*/
Method buscaHoraRecurso(aOperacao, dData, nHora, lFinal, lEncontrou, cRecurso) Class PCPA152Nivelamento
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aTempos    := Nil
	Local cData      := DtoS(dData)
	Local nFim       := 0
	Local nFimTempo  := 0
	Local nIndex     := 0
	Local nIndTempos := 0
	Local nInicio    := 0
	Local nIniTempo  := 0
	Local nStep      := 1
	Local oIndices   := Self:getJsonIndicesRecurso(cRecurso)

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
@param 01 aOperacao, Array   , Dados da operação que está sendo processada.
@param 02 aIndices , Array   , Indices das alocações da operação.
@param 03 cRecurso , Caracter, Recurso que irá verificar se existe tempo disponível.
@return lExiste, Logic, Indica se existe tempo disponível entre as alocações.
/*/
Method existeTempoDisponivel(aOperacao, aIndices, cRecurso) Class PCPA152Nivelamento
	Local aDispRec  := Self:oDispRecur[cRecurso]
	Local aTempos   := Nil
	Local lExiste   := .F.
	Local nFimDisp  := aTail(aIndices)[INDICE_TEMPOS_POS_DISPONIBILIDADE]
	Local nFimTempo := 0
	Local nIdxDisp  := 0
	Local nIdxTemp  := 0
	Local nIniDisp  := aIndices[1][INDICE_TEMPOS_POS_DISPONIBILIDADE]
	Local nIniTemp  := aIndices[1][INDICE_TEMPOS_POS_TEMPOS ]

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
@param 05 cRecurso , Caracter, Recurso que foi alocado
@return cMsg, Caracter, Mensagem de log com a alteração de alocação
/*/
Static Function logAlter(aOperacao, aAlocado, aNovaAloc, lEntrega, cRecurso)
	Local aMsg := {}
	Local nFim := Len(aAlocado)

	aAdd(aMsg, "ALTEROU ALOCACAO. Ordem: "    + aOperacao[ARRAY_MF_OP     ] +;
	                           ", Operacao: " + aOperacao[ARRAY_MF_OPER   ] +;
	                           ", Recurso: "  + cRecurso +;
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
@param 14 cSeqFerr , Caracter, Indica a sequencia das ferramentas que devem ser utilizadas na alocação.
@param 15 oSeqFerr , Object  , Retorna por referência as sequências das ferramenta alocadas por recurso (Ex: oSeqFerr[<recurso>] = <sequencia>).
@return aPeriodos, Array, Array com os periodos encontrados para a operação.
/*/
Method alocaOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, lDistTudo, lDispAdc, cRecurso, lAlocPost, lRetCria, aAlocOrig, lEntJunto, dDataAlo, nHoraAlo, cSeqFerr, oSeqFerr) Class PCPA152Nivelamento
	Local aDatas      := {}
	Local aFerramenta := {}
	Local aRecursos   := aOperacao[ARRAY_PROC_RECURSOS]
	Local cFerAux     := ""
	Local cRecPrin    := ""
	Local lCriaAux    := .F.
	Local lDesdobra   := .F.
	Local lJuntoAux   := .F.
	Local lPostAux    := .F.
	Local lSimulaMT   := .F.
	Local lSimulouMT  := .F.
	Local lTudoAux    := .F.
	Local lValidaFerr := .F.
	Local lValidAlt   := .F.
	Local nIndex      := 0
	Local nQtdFerram  := Len(aOperacao[ARRAY_PROC_FERRAMENTAS])
	Local nStart      := 1
	Local nTotal      := Len(aRecursos)
	Local oAlocacoes  := JsonObject():New()

	lDistTudo := .T.
	lAlocPost := .F.
	lRetCria  := .F.
	lEntJunto := .F.
	dDataAlo  := PCPConvDat((Self:oParamNiv["dataInicial"]), 1)
	nHoraAlo  := __Hrs2Min(Self:oParamNiv["horaInicial"])
	lDesdobra := _Super:desdobraOperacao(aOperacao)
	oSeqFerr  := JsonObject():New()

	cRecPrin := aOperacao[ARRAY_PROC_RECURSOS][1][ARRAY_HZ7_RECURS]
	If Self:lRedSetup
		lValidAlt := .F.
	Else
		cRecurso  := cRecPrin
		lValidAlt := aOperacao[ARRAY_PROC_USA_ALTERNATIVOS]

		If lValidAlt .Or. lDesdobra
			cRecurso := ""
		EndIf
	EndIf

	_Super:preAlocacaoAtualizaSobreposicao(aOperacao, lEntrega)

	// Simula alocação com multi-thread se....

	// ... se a operação possui recursos alternativos e não estiver executando a redução de setup
	lSimulaMT := lValidAlt

	// ... a operação aloca com sobreposição
	If !lSimulaMT
		If lDesdobra
			For nIndex := 1 To nTotal
				If _Super:alocaComSobreposicao(aOperacao, lEntrega, aRecursos[nIndex][ARRAY_HZ7_RECURS])
					lSimulaMT := .T.
					Exit
				EndIf
			Next
		Else
			lSimulaMT := _Super:alocaComSobreposicao(aOperacao, lEntrega, cRecurso)
		EndIf
	EndIf

	// ... se a operação possui ferramentas e não estiver executando a redução de setup
	If nQtdFerram > 0 .And. !Self:lRedSetup
		// Se possui mais de uma ferramenta, simula as alocações em multi-thread e pega a sequencia da ferramenta pela melhor alocação.
		If nQtdFerram > 1
			lValidaFerr := .T.
			lSimulaMT   := .T.

		// Se tiver apenas uma ferramenta, pega a sequencia da primeira ferramenta para buscar corretamente os parametros de alocação em multi-thread.
		ElseIf lSimulaMT
			cSeqFerr := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_SEQUENCIA]

		EndIf
	EndIf

	// Simula as alocações em multi-thread para identificar o melhor recurso/ferramenta.
	// Caso a operação realize desdobramento, executa a simulação para cada recurso no momento de alocar na thread principal.
	If lSimulaMT .And. !lDesdobra

		If Self:simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig, cSeqFerr)
			cRecurso   := Self:avaliaSimulacao(aOperacao, lEntrega, @cSeqFerr)
			lSimulouMT := .T.

			Self:getParametrosAlocacao(aOperacao, cRecurso, @lEntrega, @dDataAlo, @nHoraAlo, @lEntJunto, cSeqFerr, @aFerramenta)
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

	// Se não simula em multi-thread, busca a data de alocação com base no recurso principal.
	ElseIf !lSimulaMT
		If !Self:lRedSetup
			cRecurso := aOperacao[ARRAY_MF_RECURSO]
		EndIf

		aDatas   := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecurso)
		dDataAlo := aDatas[RET_GET_DATA_DATA]
		nHoraAlo := aDatas[RET_GET_DATA_HORA]

		If nQtdFerram > 0
			If Empty(cSeqFerr)
				aFerramenta := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS]
				cSeqFerr    := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_SEQUENCIA  ]
			Else
				aFerramenta := Self:getFerramentaBySeq(aOperacao, cSeqFerr)
			EndIf
		EndIf
	EndIf

	If !lDesdobra .Or. Self:lRedSetup
		nStart := aScan(aRecursos, {|aRec| aRec[ARRAY_HZ7_RECURS] == cRecurso})
		nTotal := nStart
	EndIf
	cFerAux := cSeqFerr

	For nIndex := nStart To nTotal
		cRecurso := aRecursos[nIndex][ARRAY_HZ7_RECURS]

		If _Super:permiteProsseguir()
			_Super:carregaDisponibilidadeRecurso(cRecurso)

			If lDesdobra .And. lSimulaMT
				cSeqFerr := Iif(Empty(cFerAux), "", cFerAux)

				If Self:simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig, cSeqFerr)
					lSimulouMT := .T.
					Self:avaliaSimulacao(aOperacao, lEntrega, @cSeqFerr, cRecurso)
					Self:getParametrosAlocacao(aOperacao, cRecurso, @lEntrega, @dDataAlo, @nHoraAlo, @lJuntoAux, cSeqFerr, @aFerramenta)
					lEntJunto := lEntJunto .Or. lJuntoAux
				EndIf
			EndIf

			If !Empty(aFerramenta) .And. aFerramenta[1][ARRAY_HZJ_ALTERN] == EH_ALTERNATIVA
				Self:oOcorrens:adicionaOcorrencia(LOG_ALOCOU_FERRAMENTA_ALTERNATIVA,;
				                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperacao[ARRAY_MF_ID            ],;
				                                  aOperacao[ARRAY_MF_OP            ],;
				                                  aOperacao[ARRAY_MF_OPER          ],;
				                                  cRecurso, "", "", {})
			EndIf

			oAlocacoes[cRecurso] := _Super:getPeriodosOperacao(aOperacao, lEntrega, dDataAlo, nHoraAlo, @lTudoAux, lDispAdc, @lPostAux, @lCriaAux, cRecurso, .F., aFerramenta)

			lDistTudo := Iif(lDistTudo , lTudoAux, .F.)
			lAlocPost := Iif(!lAlocPost, lPostAux, .F.)
			lRetCria  := Iif(!lRetCria , lCriaAux, .F.)
			oSeqFerr[cRecurso] := cSeqFerr

			_Super:posAlocacaoAtualizaSobreposicao(aOperacao, cRecurso, lEntrega)
		EndIf
	Next

	If lSimulouMT
		_Super:limpaListaGlobal("ALOCACOES_NIVELAMENTO")
	EndIf

Return oAlocacoes

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
@param 08 cSeqFerr , Caracter, Sequência da ferramenta que deverá ser alocada (redução de setup).
@return Nil
/*/
Method simulaAlocacoes(aOperacao, lEntrega, lDataDaOP, lDataProg, lDispAdc, cRecurso, aAlocOrig, cSeqFerr) Class PCPA152Nivelamento
	Local aDispRec  := {}
	Local aRecursos := aOperacao[ARRAY_PROC_RECURSOS]
	Local aRetData  := {}
	Local aSeqFerr  := {}
	Local cEtapa    := CHAR_ETAPAS_NIVELAMENTO
	Local cIndcAloc := ""
	Local cIndice   := ""
	Local cJsFerram := ""
	Local cRecAloc  := ""
	Local nIndAloc  := 0
	Local nIndFer   := 0
	Local nQtdSim   := 0
	Local nTotAloc  := Len(aRecursos)
	Local nTotFer   := Len(aOperacao[ARRAY_PROC_FERRAMENTAS])

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

	If !Empty(cSeqFerr)
		aSeqFerr := {cSeqFerr}
	ElseIf nTotFer > 0
		For nIndFer := 1 To nTotFer
			aAdd(aSeqFerr, aOperacao[ARRAY_PROC_FERRAMENTAS][nIndFer][ARRAY_FERRAM_SEQUENCIA])
		Next
	Else
		aSeqFerr := {""}
	EndIf
	nTotFer := Len(aSeqFerr)

	For nIndAloc := nIndAloc To nTotAloc
		cRecAloc := aRecursos[nIndAloc][ARRAY_HZ7_RECURS]

		_Super:carregaDisponibilidadeRecurso(cRecAloc)

		aDispRec  := Self:oDispRecur[cRecAloc]
		cIndice   := _Super:getJsonIndicesRecurso(cRecAloc):toJson()
		cIndcAloc := _Super:getIndicesComAlocacao(cRecAloc):toJson()

		aRetData := Self:getDataOperacao(aOperacao, lEntrega, lDataDaOP, lDataProg, cRecAloc)

		For nIndFer := 1 To nTotFer
			nQtdSim++
			cSeqFerr := aSeqFerr[nIndFer]
			_Super:delegar("P152DelAlo", Self:cProg, aOperacao[ARRAY_MF_ID], aOperacao[ARRAY_MF_OP], cRecAloc, aDispRec, cIndice, cIndcAloc, {lEntrega, lDispAdc, aRetData, cEtapa, aAlocOrig, cJsFerram, cSeqFerr})
		Next

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
                                                                                               aParGet[7], Caracter, Sequencia da ferramenta que deverá ser alocada.
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
                                                                                               aParGet[7], Caracter, Sequencia da ferramenta que deverá ser alocada.
@return Nil
/*/
Method executaSimulacao(cIdOper, cOPOper, cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet) Class PCPA152Nivelamento
	Local aAlocOrig   := aParGet[5]
	Local aFerramenta := {}
	Local aGetData    := aParGet[3]
	Local aOperacao   := _Super:getOperacao(cOPOper, cIdOper)
	Local aPeriodos   := {}
	Local aSave       := Array(INFO_ALOCACOES_TAMANHO)
	Local cChave      := ""
	Local cJsFerram   := aParGet[6]
	Local cSeqFerr    := aParGet[7]
	Local dData       := Nil
	Local lDistTudo   := .F.
	Local lEntJunto   := .F.
	Local lEntrega    := aParGet[1]
	Local lGeraAdc    := aParGet[2]
	Local nHora       := 0

	cChave := Self:getChaveAlocacao(aOperacao, cRecurso, cSeqFerr)
	_Super:preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, aParGet[4], cJsFerram)

	If !Empty(cSeqFerr)
		aFerramenta := Self:getFerramentaBySeq(aOperacao, cSeqFerr)
	EndIf

	If aGetData[RET_GET_DATA_SOBREPOE]
		dData := aGetData[RET_GET_DATA_DATA_SOBRE]
		nHora := aGetData[RET_GET_DATA_HORA_SOBRE]
	Else
		dData := aGetData[RET_GET_DATA_DATA]
		nHora := aGetData[RET_GET_DATA_HORA]
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
@param 03 cSeqFerr , Caracter, Sequência da ferramenta que foi alocada.
@return cChave, Caracter, Chave de alocação da operação.
/*/
Method getChaveAlocacao(aOperacao, cRecurso, cSeqFerr) Class PCPA152Nivelamento
	Local cChave := aOperacao[ARRAY_PROC_CHAVE_ARVORE] + "_" + cRecurso + "_" + cSeqFerr

Return cChave

/*/{Protheus.doc} avaliaSimulacao
Avalia a simulação de alocação dos recursos para identificar o recurso que tem os melhores tempos para alocação da operação.
@author Lucas Fagundes
@since 10/09/2024
@version P12
@param 01 aOperacao , Array   , Array com as informações da operação.
@param 02 lEntrega  , Logico  , Indica se as alocações foram feitas por data de entrega.
@param 03 cFerrEfet , Caracter, Retorna por referência a sequência da ferramenta com os melhores tempos para alocação da operação.
@param 04 cFiltRec  , Caracter, Filtra o recurso que irá verificar as alocações.
@return cRecEfet  , Caracter, Recurso com os melhores tempos para alocação da operação.
/*/
Method avaliaSimulacao(aOperacao, lEntrega, cFerrEfet, cFiltRec) Class PCPA152Nivelamento
	Local aChavesFer := {}
	Local aGlobal    := {}
	Local aPeriodos  := {}
	Local aPerRecEfe := {}
	Local aRecursos  := aOperacao[ARRAY_PROC_RECURSOS]
	Local cChaveAloc := ""
	Local cChaveFerr := ""
	Local cRecEfet   := ""
	Local cRecurso   := ""
	Local lEfetDisTd := .F.
	Local lLog       := Self:oLogs:logAtivo()
	Local lSubstitui := .F.
	Local nIndFer    := 0
	Local nIndRec    := 0
	Local nStart     := 1
	Local nStartFer  := 1
	Local nTempoEfet := 0
	Local nTotFer    := Len(aOperacao[ARRAY_PROC_FERRAMENTAS])
	Local nTotRec    := Len(aRecursos)

	If nTotFer > 0
		For nIndFer := 1 To nTotFer
			aAdd(aChavesFer, aOperacao[ARRAY_PROC_FERRAMENTAS][nIndFer][ARRAY_FERRAM_SEQUENCIA])
		Next
	Else
		aChavesFer := {""}
	EndIf
	nTotFer := Len(aChavesFer)

	If lLog
		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Identificando melhor recurso/ferramenta para alocar a operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP]},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

	If !Empty(cFiltRec)
		nStart  := aScan(aRecursos, {|x| x[ARRAY_HZ7_RECURS] == cFiltRec})
		nTotRec := nStart
	EndIf

	If !Empty(cFerrEfet)
		nStartFer := aScan(aOperacao[ARRAY_PROC_FERRAMENTAS], {|x| x[ARRAY_FERRAM_SEQUENCIA] == cFerrEfet})
		nTotFer   := nStartFer
	EndIf

	For nIndRec := nStart To nTotRec
		cRecurso   := aRecursos[nIndRec][ARRAY_HZ7_RECURS]

		For nIndFer := nStartFer To nTotFer
			cChaveFerr := aChavesFer[nIndFer]
			cChaveAloc := Self:getChaveAlocacao(aOperacao, cRecurso, cChaveFerr)
			aGlobal    := _Super:retornaListaGlobal("ALOCACOES_NIVELAMENTO", cChaveAloc)
			aPeriodos  := aGlobal[INFO_ALOCACOES_PERIODOS]
			lSubstitui := .F.

			If Empty(cRecEfet)
				lSubstitui := .T.

				If lLog
					Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Recurso " + cRecurso + " e ferramentas " + cChaveFerr + " selecionados para a alocacao, pois outros recursos ainda nao foram avaliados."},;
										aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
				EndIf
			EndIf

			If !lSubstitui .And. aGlobal[INFO_ALOCACOES_DISTTUDO] .And. !lEfetDisTd
				lSubstitui := .T.

				If lLog
					Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Recurso " + cRecurso + " e ferramentas " + cChaveFerr + " selecionados para a alocacao, pois o recurso anterior nao tinha alocacao completa."},;
										aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
				EndIf
			EndIf

			If !lSubstitui .And. aGlobal[INFO_ALOCACOES_DISTTUDO] .And. Self:validaPeriodosAlternativo(aPerRecEfe, aPeriodos, lEntrega, nTempoEfet, aRecursos[nIndRec][ARRAY_HZ7_TEMPRE])
				lSubstitui := .T.

				If lLog
					Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"-- Recurso " + cRecurso + " e ferramentas " + cChaveFerr + " selecionados para a alocacao, pois possui tempos melhores que o recurso anterior --",;
																"Tempo recurso anterior (" + cRecEfet + "/" + cFerrEfet  + "): Inicio: " + DToC(aPerRecEfe[1][ARRAY_DISPONIBILIDADE_DATA]) + " - " + __Min2Hrs(aPerRecEfe[1][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + "; Fim: " + DToC(aTail(aPerRecEfe)[ARRAY_DISPONIBILIDADE_DATA]) + " - " + __Min2Hrs(aTail(aPerRecEfe)[ARRAY_DISPONIBILIDADE_HORA_FIM], .T.),;
																"Tempo novo recurso ("     + cRecurso + "/" + cChaveFerr + "): Inicio: " + DToC(aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA ]) + " - " + __Min2Hrs(aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_INICIO ], .T.) + "; Fim: " + DToC(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA ]) + " - " + __Min2Hrs(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM ], .T.),;
																"---------------------------------------------------------------------------------------------------------------"},;
										aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
				EndIf
			EndIf

			If lSubstitui
				cRecEfet   := cRecurso
				cFerrEfet  := cChaveFerr
				aPerRecEfe := aPeriodos
				lEfetDisTd := aGlobal[INFO_ALOCACOES_DISTTUDO]
				nTempoEfet := aRecursos[nIndRec][ARRAY_HZ7_TEMPRE]
			EndIf

			aSize(aGlobal, 0)
		Next
	Next

	If lLog
		Self:oLogs:gravaLog(CHAR_ETAPAS_NIVELAMENTO, {"Melhor recurso e ferramenta para alocar a operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + ": recurso " + cRecEfet + " ferramenta " + cFerrEfet},;
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
@param 01 aOperacao  , Array   , Operação que irá recuperar os parâmetros.
@param 02 cRecurso   , Caracter, Recurso que simulou a alocação.
@param 03 lEntrega   , Lógico  , Retorna por referência se a operação foi alocada pela data de entrega.
@param 04 dData      , Date    , Retorna por referência a data que iniciou a alocação da operação na simulação.
@param 05 nHora      , Numerico, Retorna por referência a hora que iniciou a alocação da operação na simulação.
@param 06 lEntJunto  , Logico  , Retorna por referência se a operação entrega junto da anterior.
@param 06 cSeqFerr   , Caracter, Sequencia da ferramenta que que simulou a alocação.
@param 06 aFerramenta, Array   , Retorna por referencia as ferramentas para alocação.
@return Nil
/*/
Method getParametrosAlocacao(aOperacao, cRecurso, lEntrega, dData, nHora, lEntJunto, cSeqFerr, aFerramenta) Class PCPA152Nivelamento
	Local aGlobal := {}
	Local cChave  := Self:getChaveAlocacao(aOperacao, cRecurso, cSeqFerr)

	aGlobal := _Super:retornaListaGlobal("ALOCACOES_NIVELAMENTO", cChave)

	lEntrega    := aGlobal[INFO_ALOCACOES_ENTREGA      ]
	dData       := aGlobal[INFO_ALOCACOES_DATA         ]
	nHora       := aGlobal[INFO_ALOCACOES_HORA         ]
	lEntJunto   := aGlobal[INFO_ALOCACOES_ENTREGA_JUNTO]
	aFerramenta := Self:getFerramentaBySeq(aOperacao, cSeqFerr)

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
	Local lRealoca := .F.
	Local nTamPer  := 0

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

/*/{Protheus.doc} getFerramentaBySeq
Retorna as ferramentas de uma sequência informada.
@author Lucas Fagundes
@since 13/10/2025
@version P12
@param aOperacao, Array   , Array com as informações da operação.
@param cSeqFerr , Caracter, Sequência que deseja recuperar as ferramentas.
@return aFerrams, Array, Array com as ferramentas da sequência informada.
/*/
Method getFerramentaBySeq(aOperacao, cSeqFerr) Class PCPA152Nivelamento
	Local aFerrams := {}
	Local nIndFer  := 0
	Local nTotFer  := Len(aOperacao[ARRAY_PROC_FERRAMENTAS])

	For nIndFer := 1 To nTotFer
		If aOperacao[ARRAY_PROC_FERRAMENTAS][nIndFer][ARRAY_FERRAM_SEQUENCIA] == cSeqFerr
			aFerrams := aOperacao[ARRAY_PROC_FERRAMENTAS][nIndFer][ARRAY_FERRAM_FERRAMENTAS]
			Exit
		EndIf
	Next

Return aFerrams
