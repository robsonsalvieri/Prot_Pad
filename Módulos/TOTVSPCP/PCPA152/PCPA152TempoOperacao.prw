#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

Static _cSeqPrinc  := Nil
Static _oMapFields := Nil

#DEFINE ALTERNATIVOS_CODIGO     1
#DEFINE ALTERNATIVOS_CTRAB      2
#DEFINE ALTERNATIVOS_EFICIENCIA 3
#DEFINE ALTERNATIVOS_MAOOBRA    4
#DEFINE ALTERNATIVOS_TAMANHO    4

/*/{Protheus.doc} PCPA152TempoOperacao
Classe responsável por calcular os tempos das operações, calcular a prioridade e realizar a distribuição das ordens.

@author Lucas Fagundes
@since 17/03/2023
@version P12
/*/
Class PCPA152TempoOperacao From PCPA152Process
	Private Data aAlocados      as Array
	Private Data aIntervalo     as Array
	Private Data aOpersAnt      as Array
	Private Data aOperacao      as Array
	Private Data aFerramentas   as Array
	Private Data cBanco         as Caracter
	Private Data cEtapaLog      as Caracter
	Private Data cFilialSMF     as Caracter
	Private Data cFilialSVM     as Caracter
	Private Data cIdOperac      as Caracter
	Private Data cProg          as Caracter
	Private Data lBkpDisp       as Logical
	Private Data lCriaDisp      as Logical
	Private Data lDecresce      as Logical
	Private Data lRedSetup      as Logical
	Private Data lCRP           as Logical
	Private Data lDispAdc       as Logical
	Private Data nTamVMSEQ      as Number
	Private Data nTempoOper     as Number
	Private Data nUltOperDi     as Number
	Private Data oBkpDisRec     as Object
	Private Data oDispRecur     as Object
	Private Data oDistrib       as Object
	Private Data oIndcRecur     as Object
	Private Data oInfoOper      as Object
	Private Data oOpersFina     as Object
	Private Data oOPsParc       as Object
	Private Data oParTempo      as Object
	Private Data oQryBlock      as Object
	Private Data oRecsAloc      as Object
	Private Data oTempOperacoes as Object
	Private Data oTempOrdens    as Object
	Private Data oAlternativos  as Object
	Private Data oCacheOper     as Object
	Private Data oIndcCAloc     as Object
	Private Data oBulkTemp      as Object
	Private Data oFerramentas   as Object
	Private Data oSeqSVM        as Object

	// Construtor e destrutor
	Public Method new(cProg) Constructor
	Public Method destroy()

	// Métodos para a etapa de calculo do tempo das operações
	Private Method calculaDuracaoOperacao()
	Private Method calculaSaldo()
	Private Method calculaTotal()
	Private Method carregaApontamentos()
	Private Method processaFilhas()
	Private Method processaPais()
	Private Method getAlternativos()
	Private Method getRecursosOperacao(aOperacao)
	Private Method tempoRecursos(aOperacao)
	Private Method aplicaMaoDeObra(aOperacao, nTempo, nMaoObra)
	Public Method tempoSobreposicao(cTipoSobre, nTempoSob, aOperAnt, cRecAnt)
	Public Method calculaOperacao(cJson)
	Public Method processaTempoOperacao()
	Public Method ocorrenciaOperacoes()
	Public Method geraOcoOperacoesOrdem(cOrdem)

	// Métodos para a etapa de priorização de ordens
	Public Method calculaPrioridade()

	// Métodos para a etapa de distribuição das ordens
	Private Method distribuiDataDaProgramacao(aOperacoes)
	Public Method efetivaOperacoesAlocadas()
	Private Method getDataInicioOperacao(aOperacao, dData, cHora)
	Private Method limpaOperacoesAlocadas()
	Private Method reprocessaDistribuicao()
	Public Method distribuiOperacoes(aOrdem)
	Public Method processaDistribuicao()
	Private Method getDisponibilidadeDistribuicao()
	Private Method removeOcorrenciasDistribuicao(cChaveArv, cOrdem)

	// Métodos para a etapa de gravação
	Private Method converteArrayProcessamentoParaGravacao(cTabela, aProc)
	Public Method gravaDados()
	Public Method gravaTabela(cTabela, aDados)

	// Métodos auxiliares
	Private Method alocaOperacao(aOperacao, lEntrega, aGetData, lOperDist, lDispAdc, lAlocPost, lRetCria)
	Private Method calculaTempo(nHora)
	Private Method carregaRecursosOperacao(aOperacao)
	Private Method insereTempTable(aDados)
	Public Method adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecurso, nTempoSob)
	Public Method alocaComSobreposicao(aOperacao, lEntrega, cRecurso)
	Public Method avaliaSobreposicao(aOperacao, aDatas, lEntrega, aPeriodos, dData, nHora, lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, lAlocPost, lRetCria, lSimula, lEntJunto, aFerramenta, cJsFerram)
	Public Method carregaOperacoes()
	Public Method chaveListaDadosSVM(aOperacao)
	Public Method finalizaCargaTemp()
	Private Method geraOcorrenciaSobreposicao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto)
	Public Method getCentroTrabalhoOperacao(aOperacao, cRecurso)
	Public Method getChaveArvore(aOperacao)
	Public Method getDataSobreposicao(aOperacao, aAloAnt, lEntrega, cRecurso, aRet)
	Public Method getOperacao(cOrdem, cId)
	Public Method getOperacoesOrdem(cOrdem, lOrdena)
	Public Method getUltimaOperacaoAlocada(cRecurso, aPeriodos)
	Public Method limpaDisponibilidade(lRecria)
	Public Method posAlocacaoAtualizaSobreposicao(aOperAnt, cRecAnt, lEntrega)
	Public Method preAlocacaoAtualizaSobreposicao(aOperSob, lEntrega)
	Public Method preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, cEtapa, cJsFerram)
	Public Method unePeriodosDisponiveis(aDisp)
	Public Method validaDatasOp(aOperacao, dNovaDtIni, dNovaDtEnt)
	Private Method verificaSobreposicao(aOperacao, lEntrega, cRecAloc, aPeriodos, lEntJunto, lRemoveGlb)
	Private Method validaTempoSobreposicao(aOperSob, aOperAnt, cRecAnt, lEntrega, lRetRemo)
	Private Method verificaValidadeOperacao(aOperacao, aPeriodos, cRecurso, lRemoveGlb)
	Public Method validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto, lRemoveGlb, dDataIni, nHoraIni)
	Private Method verificaDataOperacao(aOperacao, aPeriodos, dDataIni, nHoraIni, lEntrega, cRecurso, lRemoveGlb)

	// Métodos de alocação
	Private Method addIndiceAlocado(cRecurso, nIndice)
	Private Method ajustaArrayDeTempos(aTempos)
	Private Method ajustaFinalizacao(aOperacao, aPeriodos)
	Private Method ajustaSetup(aOperacao, aPeriodos)
	Private Method alocaFerramentas(aPeriodos)
	Private Method atualizaOperacao(aOperacao, cRecurso, nTempoSob)
	Private Method buscaIndiceDisponibilidade(cRecurso, dData, nHora, lDispAdc, lCriouDisp)
	Private Method carregaIntervaloAlocacao(cRecurso, nIndDisp, nIndTempos, dDataIni, nHoraIni, aOperacao)
	Private Method consomeDisponibilidade(aOperacao, nIndDisp, nTempo, nHora, aPeriodos, dDataStart, nHoraStart, lSetup, cRecurso)
	Private Method criaDisponibilidadeRecurso(cRecurso, nTempoNec, dData)
	Private Method criaPeriodoDisponibilidade(dData, nHoraIni, nHoraFim, cRecurso, nIndDisp, cIdOper, cOperOP)
	Private Method disponibilidadeDisponivel(aDisp, nIndDisp)
	Private Method getAlocAnterior(cRecurso, nIndDisp, nIndTempos, dDataIni, nHoraIni)
	Private Method getAlocPosterior(cRecurso, nIndDisp, nIndTempos, dDataIni, nHoraIni)
	Private Method getChaveOperacao(aOperacao)
	Private Method getTempoAlocavel(dDataIni, nHoraIni, dDataVld, nHrIniVld, nHrFimVld)
	Private Method ordenaArrayPeriodos(aPeriodos)
	Private Method ordenaTempos(aTempos)
	Private Method quebraTempoDeAcordoComDisponibilidadeDaFerramenta(aTempo, aInsere, lQuebrou)
	Private Method setaSetupPeriodos(aOperacao, aPeriodos, dDataIni, nHoraIni)
	Private Method tempoAlocavelPeriodo(aTempo, dDataIni, nHoraIni, aDispRec, lFerramDisp)
	Private Method validaFimIntervalo(cRecurso)
	Private Method validaFinalizacao(aOperacao, nTempo)
	Private Method validaOperacaoPosterior(aOperacao, nTempo, aTempo, cRecurso)
	Private Method validaQuebras(nTempo)
	Private Method validaSetup(aOperacao, nIndDisp, nIndTempos, nTempo, nHora, cRecurso)
	Public Method adicionaTempoRemocao(aOperacao, aPeriodos)
	Public Method atualizaIndiceDisponibilidade(cRecurso, dData)
	Public Method buscaAlocAnterior(aAlocAnt, cRecurso, nIndDisp, nIndTempos)
	Public Method buscaAlocPosterior(aAlocPost, cRecurso, nIndDisp, nIndTempos)
	Public Method calcTempoAlocacao(aOperacao, cRecurso)
	Public Method carregaDisponibilidadeRecurso(cRecurso)
	Public Method criaBackupFerramentas()
	Public Method descartaBkpDisponibilidades()
	Public Method efetivaDisponibilidadeAdicional()
	Public Method excluiBackupFerramentas()
	Public Method excluiDisponibilidadeAdicional()
	Public Method geraPeriodosOperacao(aOperacao, aPeriodos, dUltAloc)
	Public Method getIndicesComAlocacao(cRecurso)
	Public Method getJsonIndicesRecurso(cRecurso)
	Public Method getPeriodosOperacao(aOperacao, lDecresce, dDataStart, nHoraStart, lOperDist, lDispAdc, lAlocPost, lRetCria, cRecurso, lSimula, aFerramenta)
	Public Method gravaBackupDisponibilidades(cRecurso, nIndDisp)
	Public Method gravaPeriodosOperacao(aOperacao, aPeriodos, cRecurso, nTempoSob)
	Public Method removeIndiceAlocado(cRecurso, nIndice)
	Public Method restauraBackupDisponibilidades()
	Public Method rollbackBackupFerramentas()
	Public Method setIndicesComAlocacao(cRecurso, oJson)
	Public Method setJsonIndicesRecurso(cRecurso, oJson)
	Private Method validaInicioAlocacao(aOperacao, cRecurso, nSetup, nProducao, nFinaliza, nIndDisp, nIndTempos, dIniAtu, nIniAtu)
	Private Method getHoraFerramenta(cRecurso, nTempoAnt, nIndDisp, nIndTempos, dIniAtu, nIniAtu, dDataFerr, nHoraFerr, nRetIndex, nRetIndxTp)
	Private Method getNovaDataInicial(cRecurso, nTempoAnt, nIndDisp, dDataFerr, nHoraFerr, dNovaData, nNovaHora, nIndcFer, nTempFer)
	Private Method validaFerramentas(aOperacao, nTempoAloc, cRecurso, nIndDisp, nIndTempos, dDataStart, nHoraStart)
	Private Method tempoValido(aTempo, nHora)
	Private Method getTempoFinalizacao(aOperacao, cRecurso)

	// Controle de processamento
	Private Method aguardaFimProcessamento(cEtapa)
	Private Method atualizaPercentual(cEtapa)
	Private Method getQuantidades(cEtapa, nProcs, nTotal)

	// Montagem de query
	Private Method criaTempOperacoesOrdens()
	Private Method criaTempOrdens()
	Private Method queryFiltroOp()
	Private Method queryJoinProduto(cAlias)
	Private Method queryOrder(lOpPai)
	Private Method queryOpPrincipal(lFieldsSG2)
	Private Method queryJoinOperacoes(cAliasSC2, lUsaExists)
	Private Method queryRecursivaWith()

	// Método para uso externo
	Public Method getTempoOperacao(oInfoOper)
	Public Method setParam(cParam, xValor)

	// Métodos estaticos
	Static Method arredondaHora(nHora)
	Static Method horasCentesimaisParaNormais(nHora, lArredonda)
	Static Method horasNormaisParaCentesimais(nHora)
	Static Method getSequenciaRecursoPrincipal()
EndClass

/*/{Protheus.doc} new
Metodo construtor da classe PCPA152TempoOperacao.
@author Lucas Fagundes
@since 17/03/2023
@version P12
@param cProg, Caracter, Código da programação que está processando.
@return Self
/*/
Method new(cProg) Class PCPA152TempoOperacao

	Self:lCRP      := !Empty(cProg)
	Self:oParTempo := JsonObject():New()

	// Se não informou a programação, esta instanciando a classe fora do CRP. Neste caso, deve ser usado o método setParam() para definir os parâmetros da classe.
	If Self:lCRP
		_Super:new(cProg)

		Self:cProg := _Super:retornaProgramacao()

		Self:oParTempo["tipoOP"                ] := _Super:retornaParametro("tipoOP"         )
		Self:oParTempo["priorizacao"           ] := _Super:retornaParametro("priorizacao"    )
		Self:oParTempo["centroTrabalho"        ] := _Super:retornaParametro("centroTrabalho" )
		Self:oParTempo["recursos"              ] := _Super:retornaParametro("recursos"       )
		Self:oParTempo["ordemProducao"         ] := _Super:retornaParametro("ordemProducao"  )
		Self:oParTempo["produto"               ] := _Super:retornaParametro("produto"        )
		Self:oParTempo["grupoProduto"          ] := _Super:retornaParametro("grupoProduto"   )
		Self:oParTempo["tipoProduto"           ] := _Super:retornaParametro("tipoProduto"    )
		Self:oParTempo["MV_PERDINF"            ] := _Super:retornaParametro("MV_PERDINF"     )
		Self:oParTempo["MV_TPHR"               ] := _Super:retornaParametro("MV_TPHR"        )
		Self:oParTempo["dataInicial"           ] := CtoD(PCPConvDat((_Super:retornaParametro("dataInicial")),3))
		Self:oParTempo["dataFinal"             ] := CtoD(PCPConvDat((_Super:retornaParametro("dataFinal")),3))
		Self:oParTempo["replanejaSacramentadas"] := _Super:retornaParametro("replanejaSacramentadas")
		Self:oParTempo["MV_DISPADC"            ] := _Super:retornaParametro("MV_DISPADC"            )
		Self:oParTempo["utiliza_shy"           ] := _Super:retornaParametro("utiliza_shy"           )
		Self:oParTempo["horaInicial"           ] := _Super:retornaParametro("horaInicial"           )
		Self:oParTempo["ticketMRP"             ] := _Super:retornaParametro("ticketMRP"             )
		Self:oParTempo["quebraOperacoes"       ] := _Super:retornaParametro("quebraOperacoes"       )
		Self:oParTempo["ordensAtrasadas"       ] := _Super:retornaParametro("ordensAtrasadas")
		Self:oParTempo["utilizaFerramentas"    ] := _Super:retornaParametro("utilizaFerramentas") .And. GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0

		PCPA152Process():processamentoFactory(Self:cProg, FACTORY_OPC_FERRAMENTA, @Self:oFerramentas)

		iniFields()
	Else
		Self:oLogs := PCPA152Log():new()
		Self:oLogs:destroy()
	EndIf

	Self:oParTempo["dicionarioAlternativo" ] := AliasInDic("HZ7")
	Self:oParTempo["dicionarioSobreposicao"] := GetSx3Cache("MF_TPSOBRE", "X3_TAMANHO") > 0
	Self:oParTempo["dicionarioValidade"    ] := GetSx3Cache("MF_VLDINI" , "X3_TAMANHO") > 0
	Self:oParTempo["dicionarioTempoRemocao"] := GetSx3Cache("G2_REMOCAO", "X3_TAMANHO") > 0
	Self:oParTempo["dicionarioFerramenta"  ] := GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0

	Self:aAlocados  := {}
	Self:aIntervalo := {}
	Self:cBanco     := TCGetDb()
	Self:cFilialSMF := xFilial("SMF")
	Self:cFilialSVM := xFilial("SVM")
	Self:cIdOperac  := "0000000000"
	Self:nTamVMSEQ  := GetSX3Cache("VM_SEQ" , "X3_TAMANHO")
	Self:lRedSetup  := .F.
	Self:lBkpDisp   := .F.
	Self:nUltOperDi := 0
	Self:oInfoOper  := Nil
	Self:oQryBlock  := Nil
	Self:oDispRecur := JsonObject():New()
	Self:oOPsParc   := JsonObject():New()
	Self:oIndcRecur := JsonObject():New()
	Self:oDistrib   := JsonObject():New()
	Self:oOpersFina := JsonObject():New()
	Self:oBkpDisRec := JsonObject():New()
	Self:oRecsAloc  := JsonObject():New()
	Self:oCacheOper := JsonObject():New()
	Self:oIndcCAloc := JsonObject():New()

Return Self

/*/{Protheus.doc} destroy
Metodo destrutor da classe PCPA152TempoOperacao.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152TempoOperacao

	If Self:lCRP
		_Super:destroy()

		Self:oFerramentas:destroy()
	EndIf

	Self:cProg      := Nil
	Self:cFilialSMF := Nil
	Self:nTamVMSEQ  := Nil
	Self:nUltOperDi := Nil

	Self:limpaDisponibilidade(.F.)

	FreeObj(Self:oParTempo)
	FwFreeObj(Self:oInfoOper)
	FwFreeObj(Self:oQryBlock)
	FwFreeObj(Self:oOPsParc)
	FwFreeObj(Self:oDistrib)
	FwFreeObj(Self:oBkpDisRec)
	FreeObj(Self:oOpersFina)
	FreeObj(Self:oRecsAloc)
	FreeObj(Self:oCacheOper)
	FreeObj(Self:oIndcCAloc)

	FwFreeArray(Self:aAlocados)

	aSize(Self:aIntervalo, 0)

Return Nil

/*/{Protheus.doc} processaTempoOperacao
Executa o processamento da classe.
@author Lucas Fagundes
@since 17/03/2023
@version P12
@return lSucesso, Logico, Indica se concluiu o processamento com sucesso.
/*/
Method processaTempoOperacao() Class PCPA152TempoOperacao
	Local lSucesso := .T.
	Local nTotal   := 0

	lSucesso := Self:criaTempOperacoesOrdens() .And. Self:criaTempOrdens()

	If lSucesso
		nTotal := Self:calculaTotal()
	EndIf

	If nTotal > 0
		_Super:gravaValorGlobal("TOTAL_OPERACOES", nTotal)
		_Super:gravaValorGlobal("OPERACOES_FINALIZADAS", 0)

		lSucesso := Self:processaPais()
		If lSucesso
			lSucesso := Self:processaFilhas()
			Self:aguardaFimProcessamento(CHAR_ETAPAS_CALC_TEMP)
		EndIf

		If lSucesso
			_Super:gravaValorGlobal("JSON_RECURSOS_ALOCACAO", Self:oRecsAloc:toJson())
			Self:oRecsAloc := JsonObject():New()
		EndIf

		If lSucesso
			_Super:delegar("P152AftTpO", Self:cProg, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T., .T.)
			Self:oFerramentas:finalizaCargaFerramentas(.F.)
		EndIf
	EndIf

	If Self:oTempOperacoes != Nil
		Self:oTempOperacoes:Delete()
		FreeObj(Self:oTempOperacoes)
	EndIf
	If Self:oTempOrdens != Nil
		Self:oTempOrdens:Delete()
		FreeObj(Self:oTempOrdens)
	EndIf

	lSucesso := _Super:permiteProsseguir()

Return lSucesso


/*/{Protheus.doc} P152AftTpO
Finaliza a carga da tabela temporaria com as operações do processamento.
(Função executada em todas as threads abertar pelo CRP após o processamento do calculo de tempo das operações)

@type  Function
@author Lucas Fagundes
@since 07/10/2024
@version P12
@param 01 cProg, Caracter, Código da programação que está executando.
@return Nil
/*/
Function P152AftTpO(cProg)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:finalizaCargaTemp()
	EndIf

Return Nil

/*/{Protheus.doc} criaTempOrdens
Cria a temp table com as OPs que serão processadas pelo CRP.
A carga das OPs é realizada com base na tabela temporária
de operações das ordens, que já possui os filtros necessários para o processo.

@author lucas.franca
@since 21/03/2024
@version P12
@return lSucesso, Logic, Identifica se criou a temporária.
/*/
Method criaTempOrdens() Class PCPA152TempoOperacao
	Local aFields   := {}
	Local cSqlSaldo := " SC2.C2_QUANT - SC2.C2_QUJE "
	Local cInsert   := ""
	Local lSucesso  := .T.
	Local nTempoIni := MicroSeconds()

	If Self:oParTempo["MV_PERDINF"] == .F.
		cSqlSaldo += " - SC2.C2_PERDA "
	EndIf

	Self:oTempOrdens := FwTemporaryTable():New(GetNextAlias())

	aAdd(aFields, {"C2_NUM"    , "C", GetSX3Cache("C2_NUM"    , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_ITEM"   , "C", GetSX3Cache("C2_ITEM"   , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_SEQUEN" , "C", GetSX3Cache("C2_SEQUEN" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_ITEMGRD", "C", GetSX3Cache("C2_ITEMGRD", "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_OP"     , "C", GetSX3Cache("C2_OP"     , "X3_TAMANHO"), 0})
	aAdd(aFields, {"ROTEIRO"   , "C", GetSX3Cache("C2_ROTEIRO", "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_SEQPAI" , "C", GetSX3Cache("C2_SEQPAI" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_TPOP"   , "C", GetSX3Cache("C2_TPOP"   , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_PRIOR"  , "C", GetSX3Cache("C2_PRIOR"  , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_PRODUTO", "C", GetSX3Cache("C2_PRODUTO", "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_STATUS" , "C", GetSX3Cache("C2_STATUS" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_DATPRI" , "D", 8                                      , 0})
	aAdd(aFields, {"C2_DATPRF" , "D", 8                                      , 0})
	aAdd(aFields, {"SALDO"     , "N", GetSX3Cache("C2_QUANT"  , "X3_TAMANHO"), GetSX3Cache("C2_QUANT"  , "X3_DECIMAL")})
	aAdd(aFields, {"C2_QUANT"  , "N", GetSX3Cache("C2_QUANT"  , "X3_TAMANHO"), GetSX3Cache("C2_QUANT"  , "X3_DECIMAL")})
	aAdd(aFields, {"C2_QUJE"   , "N", GetSX3Cache("C2_QUJE"   , "X3_TAMANHO"), GetSX3Cache("C2_QUJE"   , "X3_DECIMAL")})
	aAdd(aFields, {"C2_PERDA"  , "N", GetSX3Cache("C2_PERDA"  , "X3_TAMANHO"), GetSX3Cache("C2_PERDA"  , "X3_DECIMAL")})
	aAdd(aFields, {"RECNO_OP"  , "N", 12                                     , 0})

	Self:oTempOrdens:setFields(aFields)
	Self:oTempOrdens:AddIndex("01", {"C2_NUM", "C2_ITEM", "C2_SEQUEN", "C2_ITEMGRD"})
	Self:oTempOrdens:AddIndex("02", {"C2_OP"})
	Self:oTempOrdens:AddIndex("03", {"C2_NUM", "C2_ITEM", "C2_ITEMGRD", "C2_SEQPAI"})

	Self:oTempOrdens:Create()
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo CREATE oTempOrdens: " + cValToChar(MicroSeconds() - nTempoIni)})
	aSize(aFields, 0)

	cInsert := " INSERT INTO " + Self:oTempOrdens:GetTableNameForQuery()
	cInsert +=       " (C2_NUM,"
	cInsert +=        " C2_ITEM,"
	cInsert +=        " C2_SEQUEN,"
	cInsert +=        " C2_ITEMGRD,"
	cInsert +=        " C2_OP,"
	cInsert +=        " ROTEIRO,"
	cInsert +=        " C2_SEQPAI,"
	cInsert +=        " C2_TPOP,"
	cInsert +=        " C2_PRIOR,"
	cInsert +=        " C2_PRODUTO,"
	cInsert +=        " C2_STATUS,"
	cInsert +=        " C2_DATPRI,"
	cInsert +=        " C2_DATPRF,"
	cInsert +=        " SALDO,"
	cInsert +=        " C2_QUANT,"
	cInsert +=        " C2_QUJE,"
	cInsert +=        " C2_PERDA,"
	cInsert +=        " RECNO_OP)"

	cInsert += "SELECT DISTINCT"
	cInsert +=       " SC2.C2_NUM,"
	cInsert +=       " SC2.C2_ITEM,"
	cInsert +=       " SC2.C2_SEQUEN,"
	cInsert +=       " SC2.C2_ITEMGRD,"
	cInsert +=       " OPER_OP.C2_OP,"
	cInsert +=       " OPER_OP.ROTEIRO,"
	cInsert +=       " SC2.C2_SEQPAI,"
	cInsert +=       " SC2.C2_TPOP,"
	cInsert +=       " SC2.C2_PRIOR,"
	cInsert +=       " SC2.C2_PRODUTO,"
	cInsert +=       " SC2.C2_STATUS,"
	cInsert +=       " SC2.C2_DATPRI,"
	cInsert +=       " SC2.C2_DATPRF,"
	cInsert +=       cSqlSaldo + ","
	cInsert +=       " SC2.C2_QUANT,"
	cInsert +=       " SC2.C2_QUJE,"
	cInsert +=       " SC2.C2_PERDA,"
	cInsert +=       " SC2.R_E_C_N_O_"
	cInsert +=  " FROM " + Self:oTempOperacoes:GetTableNameForQuery() + " OPER_OP"
	cInsert += " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cInsert +=    " ON SC2.C2_FILIAL = '" + xFilial("SC2") + "'"
	cInsert +=   " AND SC2.C2_NUM = OPER_OP.C2_NUM"
	cInsert +=   " AND SC2.C2_ITEM = OPER_OP.C2_ITEM"
	cInsert +=   " AND SC2.C2_SEQUEN = OPER_OP.C2_SEQUEN"
	cInsert +=   " AND SC2.C2_ITEMGRD = OPER_OP.C2_ITEMGRD"
	cInsert +=   " AND SC2.D_E_L_E_T_ = ' '"

	If "MSSQL" $ Self:cBanco
		cInsert := StrTran(cInsert, "||", "+")
	EndIf

	nTempoIni := MicroSeconds()
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Query INSERT oTempOrdens: " + cInsert})
	If TcSqlExec(cInsert) < 0
		_Super:gravaErro(CHAR_ETAPAS_CALC_TEMP, STR0434, AllTrim(TCSQLError())) //"Erro ao identificar as ordens de produção para processamento."
		lSucesso := .F.
	EndIf
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo INSERT oTempOrdens: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} criaTempOperacoesOrdens
Cria a temp table com as operações das ordens que serão consideradas no processo do CRP.

@author lucas.franca
@since 21/03/2024
@version P12
@return lSucesso, Logic, Identifica se criou a temporária.
/*/
Method criaTempOperacoesOrdens() Class PCPA152TempoOperacao
	Local aFields   := {}
	Local cInsert   := ""
	Local lSucesso  := .T.
	Local nTempoIni := MicroSeconds()
	Local lRemocao  := Self:oParTempo["dicionarioTempoRemocao"]

	Self:oTempOperacoes := totvs.framework.database.temporary.SharedTable():New(GetNextAlias())

	aAdd(aFields, {"C2_NUM"    , "C", GetSX3Cache("C2_NUM"    , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_ITEM"   , "C", GetSX3Cache("C2_ITEM"   , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_SEQUEN" , "C", GetSX3Cache("C2_SEQUEN" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_ITEMGRD", "C", GetSX3Cache("C2_ITEMGRD", "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_OP"     , "C", GetSX3Cache("C2_OP"     , "X3_TAMANHO"), 0})
	aAdd(aFields, {"C2_PRODUTO", "C", GetSX3Cache("C2_PRODUTO", "X3_TAMANHO"), 0})
	aAdd(aFields, {"ROTEIRO"   , "C", GetSX3Cache("C2_ROTEIRO", "X3_TAMANHO"), 0})
	aAdd(aFields, {"OPERACAO"  , "C", GetSX3Cache("G2_OPERAC" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"TIPO"      , "C", GetSX3Cache("G2_TPOPER" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"RECURSO"   , "C", GetSX3Cache("G2_RECURSO", "X3_TAMANHO"), 0})
	aAdd(aFields, {"CTRAB"     , "C", GetSX3Cache("G2_CTRAB"  , "X3_TAMANHO"), 0})
	aAdd(aFields, {"TEMPAD"    , "N", GetSX3Cache("G2_TEMPAD" , "X3_TAMANHO"), GetSX3Cache("G2_TEMPAD" , "X3_DECIMAL")})
	aAdd(aFields, {"LOTEPAD"   , "N", GetSX3Cache("G2_LOTEPAD", "X3_TAMANHO"), GetSX3Cache("G2_LOTEPAD", "X3_DECIMAL")})
	aAdd(aFields, {"DATAINI"   , "D", 8                                      , 0})
	aAdd(aFields, {"DATAFIM"   , "D", 8                                      , 0})
	aAdd(aFields, {"SETUP"     , "N", GetSX3Cache("G2_SETUP"  , "X3_TAMANHO"), GetSX3Cache("G2_SETUP"  , "X3_DECIMAL")})
	aAdd(aFields, {"FINALIZA"  , "N", GetSX3Cache("G2_TEMPEND", "X3_TAMANHO"), GetSX3Cache("G2_TEMPEND", "X3_DECIMAL")})
	aAdd(aFields, {"USA_ALT"   , "C", 1, 0})
	aAdd(aFields, {"MAOOBRA"   , "N", GetSX3Cache("H1_MAOOBRA", "X3_TAMANHO"), GetSX3Cache("H1_MAOOBRA", "X3_DECIMAL")})
	aAdd(aFields, {"TIPOSOBRE" , "C", GetSX3Cache("G2_TPSOBRE", "X3_TAMANHO"), 0})
	aAdd(aFields, {"TEMPOSOBRE", "N", GetSX3Cache("G2_TEMPSOB", "X3_TAMANHO"), GetSX3Cache("G2_TEMPSOB", "X3_DECIMAL")})
	aAdd(aFields, {"FERRAMENTA", "C", GetSX3Cache("G2_FERRAM" , "X3_TAMANHO"), 0})
	aAdd(aFields, {"TIPOALOFER", "C", GetSX3Cache("G2_TPALOCF", "X3_TAMANHO"), 0})
	aAdd(aFields, {"REMOCAO"   , "N", Iif(lRemocao, GetSX3Cache("G2_REMOCAO", "X3_TAMANHO"), 1), Iif(lRemocao, GetSX3Cache("G2_REMOCAO", "X3_DECIMAL"), 0)})
	aAdd(aFields, {"VLDINI"    , "D", 8                                      , 0})
	aAdd(aFields, {"VLDFIM"    , "D", 8                                      , 0})

	Self:oTempOperacoes:setFields(aFields)
	Self:oTempOperacoes:AddIndex("01", {"C2_NUM", "C2_ITEM", "C2_SEQUEN", "C2_ITEMGRD"})
	Self:oTempOperacoes:AddIndex("02", {"C2_OP"})

	Self:oTempOperacoes:Create()
	_Super:gravaValorGlobal("TEMP_OPERACOES", Self:oTempOperacoes:getTableNameForQuery())

	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo CREATE oTempOperacoes: " + cValToChar(MicroSeconds() - nTempoIni)})
	aSize(aFields, 0)

	cInsert := " INSERT INTO " + Self:oTempOperacoes:GetTableNameForQuery()
	cInsert +=       " (C2_NUM,"
	cInsert +=        " C2_ITEM,"
	cInsert +=        " C2_SEQUEN,"
	cInsert +=        " C2_ITEMGRD,"
	cInsert +=        " C2_OP,"
	cInsert +=        " C2_PRODUTO,"
	cInsert +=        " OPERACAO,"
	cInsert +=        " TIPO,"
	cInsert +=        " RECURSO,"
	cInsert +=        " CTRAB,"
	cInsert +=        " TEMPAD,"
	cInsert +=        " LOTEPAD,"
	cInsert +=        " SETUP,"
	cInsert +=        " FINALIZA,"
	cInsert +=        " USA_ALT, "
	cInsert +=        " MAOOBRA,"
	cInsert +=        " TIPOSOBRE,"
	cInsert +=        " TEMPOSOBRE,"
	cInsert +=        " REMOCAO,"
	cInsert +=        " VLDINI,"
	cInsert +=        " VLDFIM,"
	cInsert +=        " FERRAMENTA,"
	cInsert +=        " TIPOALOFER,"
	cInsert +=        " ROTEIRO)"
	cInsert += " SELECT SC2.C2_NUM,"
	cInsert +=        " SC2.C2_ITEM,"
	cInsert +=        " SC2.C2_SEQUEN,"
	cInsert +=        " SC2.C2_ITEMGRD,"
	cInsert +=        " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD,"
	cInsert +=        " SC2.C2_PRODUTO,"
	If Self:oParTempo["utiliza_shy"]
		cInsert +=    " COALESCE(SHY.HY_OPERAC, SG2.G2_OPERAC),"
		cInsert +=    " COALESCE(SHY.HY_TPOPER, SG2.G2_TPOPER),"
		cInsert +=    " COALESCE(SHY.HY_RECURSO, SG2.G2_RECURSO),"
		cInsert +=    " COALESCE(SHY.HY_CTRAB, SG2.G2_CTRAB),"
		cInsert +=    " COALESCE(SHY.HY_TEMPAD, SG2.G2_TEMPAD),"
		cInsert +=    " CASE"
		cInsert +=       " WHEN COALESCE(SHY.HY_LOTEPAD, SG2.G2_LOTEPAD) = 0 THEN 1"
		cInsert +=       " ELSE COALESCE(SHY.HY_LOTEPAD, SG2.G2_LOTEPAD)"
		cInsert +=    " END,"
		cInsert +=    " COALESCE(SHY.HY_SETUP, SG2.G2_SETUP),"
		cInsert +=    " COALESCE(SHY.HY_TEMPEND, SG2.G2_TEMPEND),"
		If Self:oParTempo["dicionarioAlternativo"]
			cInsert += " COALESCE(SHY.HY_USAALT, SG2.G2_USAALT), "
		Else
			cInsert += " '" + NAO_USA_ALTERNATIVO + "', "
		EndIf
		cInsert +=    " CASE "
		cInsert +=       " WHEN COALESCE(SHY.HY_MAOOBRA, SG2.G2_MAOOBRA) <> 0 THEN COALESCE(SHY.HY_MAOOBRA, SG2.G2_MAOOBRA) "
		cInsert +=       " ELSE SH1.H1_MAOOBRA "
		cInsert +=    " END, "
		cInsert +=    " COALESCE(SHY.HY_TPSOBRE, SG2.G2_TPSOBRE),"
		cInsert +=    " COALESCE(SHY.HY_TEMPSOB, SG2.G2_TEMPSOB),"
		If lRemocao
			cInsert += " COALESCE(SHY.HY_REMOCAO, SG2.G2_REMOCAO),"
		Else
			cInsert += " 0,"
		EndIf
		cInsert +=    " COALESCE(SHY.HY_DTINI, SG2.G2_DTINI),"
		cInsert +=    " COALESCE(SHY.HY_DTFIM, SG2.G2_DTFIM),"
		cInsert +=    " COALESCE(SHY.HY_FERRAM, SG2.G2_FERRAM),"
		cInsert +=    " COALESCE(SHY.HY_TPALOCF, SG2.G2_TPALOCF),"
	Else
		cInsert +=    " SG2.G2_OPERAC,"
		cInsert +=    " SG2.G2_TPOPER,"
		cInsert +=    " SG2.G2_RECURSO,"
		cInsert +=    " SG2.G2_CTRAB,"
		cInsert +=    " SG2.G2_TEMPAD,"
		cInsert +=    " CASE"
		cInsert +=       " WHEN SG2.G2_LOTEPAD = 0 THEN 1"
		cInsert +=       " ELSE SG2.G2_LOTEPAD"
		cInsert +=    " END,"
		cInsert +=    " SG2.G2_SETUP,"
		cInsert +=    " SG2.G2_TEMPEND,"
		If Self:oParTempo["dicionarioAlternativo"]
			cInsert += " SG2.G2_USAALT, "
		Else
			cInsert += " '" + NAO_USA_ALTERNATIVO + "', "
		EndIf
		cInsert +=    " CASE "
		cInsert +=       " WHEN SG2.G2_MAOOBRA <> 0 THEN SG2.G2_MAOOBRA "
		cInsert +=       " ELSE SH1.H1_MAOOBRA "
		cInsert +=    " END, "
		cInsert +=    " SG2.G2_TPSOBRE,"
		cInsert +=    " SG2.G2_TEMPSOB,"
		If lRemocao
			cInsert += " SG2.G2_REMOCAO,"
		Else
			cInsert += " 0,"
		EndIf
		cInsert +=    " SG2.G2_DTINI,"
		cInsert +=    " SG2.G2_DTFIM,"
		cInsert +=    " SG2.G2_FERRAM,"
		cInsert +=    " SG2.G2_TPALOCF,"
	EndIf
	cInsert +=        " CASE"
	cInsert +=           " WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO"
	cInsert +=           " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD"
	cInsert +=           " ELSE '01'"
	cInsert +=        " END"
	cInsert +=   " FROM " + RetSqlName("SC2") + " SC2"
	cInsert +=  /*INNER JOIN*/ + Self:queryJoinProduto("SC2")

	If Self:oParTempo["utiliza_shy"]
		cInsert +=" LEFT JOIN " + RetSqlName("SHY") + " SHY"
		cInsert +=  " ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "'"
		cInsert += " AND " + PCPQrySC2("SC2", "SHY.HY_OP") //Compara C2_NUM... com SHY.HY_OP
		cInsert += " AND SHY.HY_ROTEIRO = CASE"
		cInsert +=                          " WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO"
		cInsert +=                          " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD"
		cInsert +=                          " ELSE '01' "
		cInsert +=                      " END"
		cInsert += " AND ((SHY.HY_DTINI <= '" + DtoS(Self:oParTempo["dataFinal"  ]) + "') OR (SHY.HY_DTINI  = ' '))"
		cInsert += " AND ((SHY.HY_DTFIM >= '" + DtoS(Self:oParTempo["dataInicial"]) + "') OR (SHY.HY_DTFIM  = ' '))"
		cInsert += " AND SHY.D_E_L_E_T_ = ' '"
		cInsert += " AND SHY.HY_TEMPAD <> 0"

		If !Empty(Self:oParTempo["recursos"])
			cInsert +=" AND SHY.HY_RECURSO IN " + inFilt(Self:oParTempo["recursos"])
		EndIf

		cInsert +=" LEFT JOIN " + RetSqlName("SG2") + " SG2"
	Else
		cInsert +=" INNER JOIN " + RetSqlName("SG2") + " SG2"
	EndIf

	cInsert +=     " ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "'"
	cInsert +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO"
	cInsert +=    " AND SG2.G2_CODIGO  = CASE"
	cInsert +=                             " WHEN SC2.C2_ROTEIRO <> ' ' THEN SC2.C2_ROTEIRO"
	cInsert +=                             " WHEN SB1.B1_OPERPAD <> ' ' THEN SB1.B1_OPERPAD"
	cInsert +=                             " ELSE '01' "
	cInsert +=                         " END"
	cInsert +=    " AND ((SG2.G2_DTINI <= '" + DtoS(Self:oParTempo["dataFinal"  ]) + "') OR (SG2.G2_DTINI  = ' '))"
	cInsert +=    " AND ((SG2.G2_DTFIM >= '" + DtoS(Self:oParTempo["dataInicial"]) + "') OR (SG2.G2_DTFIM  = ' '))"
	cInsert +=    " AND SG2.D_E_L_E_T_ = ' '"

	If !Empty(Self:oParTempo["recursos"])
		cInsert +=" AND SG2.G2_RECURSO IN " + inFilt(Self:oParTempo["recursos"])
	EndIf

	If Self:oParTempo["utiliza_shy"]
		cInsert +=" AND SHY.HY_OP IS NULL"
	EndIf

	cInsert +=  " INNER JOIN " + RetSqlName("SH1") + " SH1"
	cInsert +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "'"

	If Self:oParTempo["utiliza_shy"]
		cInsert +=" AND ((SG2.G2_RECURSO IS NOT NULL AND SG2.G2_RECURSO = SH1.H1_CODIGO)"
		cInsert +=  " OR (SHY.HY_RECURSO IS NOT NULL AND SHY.HY_RECURSO = SH1.H1_CODIGO))"
	Else
		cInsert +=" AND SG2.G2_RECURSO = SH1.H1_CODIGO "
	EndIf
	cInsert += " AND SH1.D_E_L_E_T_ = ' '"

	cInsert +=   " LEFT JOIN " + RetSqlName("SH4") + " SH4 "
	cInsert +=     " ON SH4.H4_FILIAL = '" + xFilial("SH4") + "' "
	If Self:oParTempo["utiliza_shy"]
		cInsert +=" AND SH4.H4_CODIGO = COALESCE(SHY.HY_FERRAM, SG2.G2_FERRAM) "
	Else
		cInsert +=" AND SH4.H4_CODIGO = SG2.G2_FERRAM "
	EndIf
	cInsert +=    " AND SH4.D_E_L_E_T_ = ' ' "

	cInsert += /* WHERE */ + Self:queryFiltroOp()

	If Self:oParTempo["utiliza_shy"]
		cInsert +=" AND (SHY.HY_OP IS NOT NULL OR SG2.G2_CODIGO IS NOT NULL)"
	EndIf

	If !Empty(Self:oParTempo["centroTrabalho"])
		If Self:oParTempo["utiliza_shy"]
			cInsert +=" AND ( (SG2.G2_CODIGO  IS NOT NULL "
			cInsert +=       " AND ((SG2.G2_CTRAB != ' ' AND SG2.G2_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + ")"
			cInsert +=         " OR (SG2.G2_CTRAB = ' ' AND SH1.H1_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + ")))"
			cInsert +=   " OR (SHY.HY_CTRAB IS NOT NULL "
			cInsert +=       " AND ((SHY.HY_CTRAB != ' ' AND SHY.HY_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + " )"
			cInsert +=         " OR (SHY.HY_CTRAB = ' ' AND SH1.H1_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + ") )))"
		Else
			cInsert += " AND ( (SG2.G2_CTRAB != ' ' AND SG2.G2_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + " )"
			cInsert +=    " OR (SG2.G2_CTRAB  = ' ' AND SH1.H1_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + ") )"
		EndIf
	EndIf

	If "MSSQL" $ Self:cBanco
		cInsert := StrTran(cInsert, "||", "+")
	EndIf

	nTempoIni := MicroSeconds()
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Query INSERT oTempOperacoes: " + cInsert})
	If TcSqlExec(cInsert) < 0
		_Super:gravaErro(CHAR_ETAPAS_CALC_TEMP, STR0435, AllTrim(TCSQLError())) //"Erro ao identificar as operações para processamento."
		lSucesso := .F.
	EndIf
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo INSERT oTempOperacoes: " + cValToChar(MicroSeconds() - nTempoIni)})

Return lSucesso

/*/{Protheus.doc} calculaTotal
Calcula a quantidade de registros que serão processados
@author Marcelo Neumann
@since 21/07/2023
@version P12
@return nTotal, Numerico, Quantidade de registros que serão processados
/*/
Method calculaTotal() Class PCPA152TempoOperacao
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local nTotal := 0

	cQuery := " SELECT COUNT(*) TOTAL FROM " + Self:oTempOperacoes:GetTableNameForQuery()

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
	If (cAlias)->(!EoF())
		nTotal := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

Return nTotal

/*/{Protheus.doc} processaPais
Processa as ordens principais (ordens que não possuem SEQPAI)
@author Marcelo Neumann
@since 21/07/2023
@version P12
@return lSucesso, Logico, Indica se concluiu o processamento com sucesso.
/*/
Method processaPais() Class PCPA152TempoOperacao
	Local cAlias     := GetNextAlias()
	Local cItemGrd   := ""
	Local cItemOP    := ""
	Local cNumOP     := ""
	Local cOp        := ""
	Local cQuery     := ""
	Local cSeqOP     := ""
	Local lSucesso   := .T.
	Local nDelegados := 0
	Local nPriOperac := 1
	Local nTempoIni  := 0
	Local oInfo      := JsonObject():New()
	Local oOPsPais   := JsonObject():New()

	cQuery := Self:queryOpPrincipal(.T.) + Self:queryOrder(.T.)
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Query processaPais: " + cQuery})

	nTempoIni := MicroSeconds()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo query processaPais: " + cValToChar(MicroSeconds() - nTempoIni)})

	While (cAlias)->(!EoF()) .And. lSucesso
		cNumOP   := (cAlias)->C2_NUM
		cItemOP  := (cAlias)->C2_ITEM
		cSeqOP   := (cAlias)->C2_SEQUEN
		cItemGrd := (cAlias)->C2_ITEMGRD
		cOp      := (cAlias)->C2_OP

		//Verifica se mudou a OP
		If oInfo["ordemProducao"] <> cOp
			nPriOperac := 1
			oInfo["ordemProducao"] := cOp
			oInfo["quantidade"   ] := (cAlias)->C2_QUANT
			oInfo["qtdProduzida" ] := (cAlias)->C2_QUJE
			oInfo["perda"        ] := (cAlias)->C2_PERDA
			oInfo["dataInicio"   ] := (cAlias)->C2_DATPRI
			oInfo["dataEntrega"  ] := (cAlias)->C2_DATPRF
			oInfo["arvoreId"     ] := cValToChar((cAlias)->Arvore)
			oInfo["seqPai"       ] := ""
			oInfo["status"       ] := (cAlias)->status
			oInfo["op_pai"       ] := ""
			oInfo["produto"      ] := (cAlias)->C2_PRODUTO

			//Grava a OP principal (pai) que será usada na priorização
			oOPsPais[oInfo["ordemProducao"]] := .T.
		EndIf

		Self:cIdOperac := Soma1(Self:cIdOperac)
		oInfo["idOperacao"        ] := Self:cIdOperac
		oInfo["roteiro"           ] := (cAlias)->ROTEIRO
		oInfo["operacao"          ] := (cAlias)->G2_OPERAC
		oInfo["recurso"           ] := (cAlias)->G2_RECURSO
		oInfo["tempoPadrao"       ] := (cAlias)->G2_TEMPAD
		oInfo["lotePadrao"        ] := (cAlias)->LotePadrao
		oInfo["centroTrabalho"    ] := (cAlias)->CentroTrabalho
		oInfo["prioridade"        ] := nPriOperac
		oInfo["tempoSetup"        ] := (cAlias)->G2_SETUP
		oInfo["tempoFim"          ] := (cAlias)->G2_TEMPEND
		oInfo["usaAlternativo"    ] := Empty((cAlias)->G2_USAALT) .Or. (cAlias)->G2_USAALT == USA_ALTERNATIVO
		oInfo["tipoOperacao"      ] := Iif(Empty((cAlias)->G2_TPOPER), TIPO_OPERACAO_NORMAL, (cAlias)->G2_TPOPER)
		oInfo["maoDeObra"         ] := (cAlias)->MAOOBRA
		oInfo["tipoSobreposicao"  ] := (cAlias)->TIPOSOBRE
		oInfo["tempoSobreposicao" ] := (cAlias)->TEMPOSOBRE
		oInfo["tempoRemocao"      ] := (cAlias)->REMOCAO
		oInfo["validadeInicial"   ] := (cAlias)->VLDINI
		oInfo["validadeFinal"     ] := (cAlias)->VLDFIM
		oInfo["ferramenta"        ] := (cAlias)->FERRAMENTA
		oInfo["alocacaoFerramenta"] := (cAlias)->TIPOALOFER

		Self:oRecsAloc[(cAlias)->G2_RECURSO] := .T.

		(cAlias)->(dbSkip())

		If Self:oParTempo["priorizacao"] == PARAM_PRIORIZACAO_DATA_INICIO
			oInfo["primeiraOper"] := nPriOperac == 1
			oInfo["ultimaOper"  ] := (cAlias)->C2_OP <> cOp
		Else
			oInfo["ultimaOper"  ] := nPriOperac == 1
			oInfo["primeiraOper"] := (cAlias)->C2_OP <> cOp
		EndIf

		_Super:delegar("P152CalTem", oInfo:toJson(), Self:cProg)

		nPriOperac++
		nDelegados++

		If nDelegados == 50
			Self:atualizaPercentual(CHAR_ETAPAS_CALC_TEMP)
			nDelegados := 0
		EndIf

		lSucesso := _Super:permiteProsseguir()
	End
	(cAlias)->(dbCloseArea())

	_Super:gravaValorGlobal("JSON_OPS_PAIS", oOPsPais:toJson())

	FreeObj(oInfo)
	FreeObj(oOPsPais)
Return lSucesso

/*/{Protheus.doc} processaFilhas
Processa as ordens filhas (ordens que possuem SEQPAI)
@author Marcelo Neumann
@since 21/07/2023
@version P12
@return lSucesso, Logico, Indica se concluiu o processamento com sucesso.
/*/
Method processaFilhas() Class PCPA152TempoOperacao
	Local cAlias     := GetNextAlias()
	Local cItemGrd   := ""
	Local cItemOP    := ""
	Local cNumOP     := ""
	Local cOp        := ""
	Local cQuery     := ""
	Local cSeqOP     := ""
	Local lSucesso   := .T.
	Local nDelegados := 0
	Local nPriOperac := 1
	Local nTempoIni  := 0
	Local oInfo      := JsonObject():New()
	Local oOPsFilhas := JsonObject():New()

	cQuery := /* WITH opsEmArvore(*/ Self:queryRecursivaWith()
	cQuery +=  " SELECT opsEmArvore.C2_NUM,"
	cQuery +=         " opsEmArvore.C2_ITEM,"
	cQuery +=         " opsEmArvore.C2_SEQUEN,"
	cQuery +=         " opsEmArvore.C2_ITEMGRD,"
	cQuery +=         " opsEmArvore.C2_QUANT,"
	cQuery +=         " opsEmArvore.C2_QUJE,"
	cQuery +=         " opsEmArvore.C2_PERDA,"
	cQuery +=         " opsEmArvore.C2_DATPRI,"
	cQuery +=         " opsEmArvore.C2_DATPRF,"
	cQuery +=         " opsEmArvore.C2_SEQPAI,"
	cQuery +=         " opsEmArvore.Arvore,"
	cQuery +=         " opsEmArvore.status,"
	cQuery +=         " opsEmArvore.ROTEIRO,"
	cQuery +=         " OPER_OP.OPERACAO AS G2_OPERAC,"
	cQuery +=         " OPER_OP.RECURSO  AS G2_RECURSO,"
	cQuery +=         " OPER_OP.TEMPAD   AS G2_TEMPAD,"
	cQuery +=         " OPER_OP.LOTEPAD  AS LotePadrao,"
	cQuery +=         " CASE"
	cQuery +=            " WHEN OPER_OP.CTRAB = ' ' THEN SH1.H1_CTRAB"
	cQuery +=            " ELSE OPER_OP.CTRAB"
	cQuery +=         " END CentroTrabalho,"
	cQuery +=	      " opsEmArvore.SALDO,"
	cQuery +=         " opsEmArvore.C2_PRODUTO,"
	cQuery +=         " OPER_OP.SETUP      AS G2_SETUP,"
	cQuery +=         " OPER_OP.FINALIZA   AS G2_TEMPEND,"
	cQuery +=         " OPER_OP.TIPO       AS G2_TPOPER,"
	cQuery +=         " OPER_OP.MAOOBRA    AS MAOOBRA,"
	cQuery +=         " OPER_OP.USA_ALT    AS G2_USAALT,"
	cQuery +=         " OPER_OP.TIPOSOBRE  AS TIPOSOBRE,"
	cQuery +=         " OPER_OP.TEMPOSOBRE AS TEMPOSOBRE,"
	cQuery +=         " OPER_OP.REMOCAO    AS REMOCAO,"
	cQuery +=         " OPER_OP.VLDINI     AS VLDINI,"
	cQuery +=         " OPER_OP.VLDFIM     AS VLDFIM,"
	cQuery +=         " OPER_OP.FERRAMENTA AS FERRAMENTA,"
	cQuery +=         " OPER_OP.TIPOALOFER AS TIPOALOFER"
	cQuery +=    " FROM opsEmArvore"
	cQuery +=   /*INNER JOIN*/ Self:queryJoinOperacoes("opsEmArvore", .F.)
	cQuery +=   " WHERE opsEmArvore.OP_Principal = 2" //Considerar somente as OPs filhas
	cQuery +=   /*ORDER BY */ Self:queryOrder(.F.)

	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Query processaFilhas: " + cQuery})
	nTempoIni := MicroSeconds()
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)
	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Tempo query processaFilhas: " + cValToChar(MicroSeconds() - nTempoIni)})

	While (cAlias)->(!EoF()) .And. lSucesso
		cNumOP   := (cAlias)->C2_NUM
		cItemOP  := (cAlias)->C2_ITEM
		cSeqOP   := (cAlias)->C2_SEQUEN
		cItemGrd := (cAlias)->C2_ITEMGRD
		cOp      := cNumOP + cItemOP + cSeqOP + cItemGrd

		//Verifica se mudou a OP
		If oInfo["ordemProducao"] <> cOp
			nPriOperac := 1
			oInfo["ordemProducao"] := cOp
			oInfo["quantidade"   ] := (cAlias)->C2_QUANT
			oInfo["qtdProduzida" ] := (cAlias)->C2_QUJE
			oInfo["perda"        ] := (cAlias)->C2_PERDA
			oInfo["dataInicio"   ] := (cAlias)->C2_DATPRI
			oInfo["dataEntrega"  ] := (cAlias)->C2_DATPRF
			oInfo["arvoreId"     ] := cValToChar((cAlias)->Arvore)
			oInfo["seqPai"       ] := (cAlias)->C2_SEQPAI
			oInfo["status"       ] := (cAlias)->status
			oInfo["op_pai"       ] := cNumOP + cItemOP + (cAlias)->C2_SEQPAI + cItemGrd
			oInfo["produto"      ] := (cAlias)->C2_PRODUTO

			//Grava a OP filha que será usada na explosão das OPs Pai na priorização
			If !oOPsFilhas:hasProperty(oInfo["arvoreId"])
				oOPsFilhas[oInfo["arvoreId"]] := {}
			EndIf
			aAdd(oOPsFilhas[oInfo["arvoreId"]], oInfo["ordemProducao"])
		EndIf

		Self:cIdOperac := Soma1(Self:cIdOperac)
		oInfo["idOperacao"        ] := Self:cIdOperac
		oInfo["roteiro"           ] := (cAlias)->ROTEIRO
		oInfo["operacao"          ] := (cAlias)->G2_OPERAC
		oInfo["recurso"           ] := (cAlias)->G2_RECURSO
		oInfo["tempoPadrao"       ] := (cAlias)->G2_TEMPAD
		oInfo["lotePadrao"        ] := (cAlias)->LotePadrao
		oInfo["centroTrabalho"    ] := (cAlias)->CentroTrabalho
		oInfo["prioridade"        ] := nPriOperac
		oInfo["tempoSetup"        ] := (cAlias)->G2_SETUP
		oInfo["tempoFim"          ] := (cAlias)->G2_TEMPEND
		oInfo["ultimaOper"        ] := nPriOperac == 1
		oInfo["usaAlternativo"    ] := Empty((cAlias)->G2_USAALT) .Or. (cAlias)->G2_USAALT == USA_ALTERNATIVO
		oInfo["tipoOperacao"      ] := Iif(Empty((cAlias)->G2_TPOPER), TIPO_OPERACAO_NORMAL, (cAlias)->G2_TPOPER)
		oInfo["maoDeObra"         ] := (cAlias)->MAOOBRA
		oInfo["tipoSobreposicao"  ] := (cAlias)->TIPOSOBRE
		oInfo["tempoSobreposicao" ] := (cAlias)->TEMPOSOBRE
		oInfo["tempoRemocao"      ] := (cAlias)->REMOCAO
		oInfo["validadeInicial"   ] := (cAlias)->VLDINI
		oInfo["validadeFinal"     ] := (cAlias)->VLDFIM
		oInfo["ferramenta"        ] := (cAlias)->FERRAMENTA
		oInfo["alocacaoFerramenta"] := (cAlias)->TIPOALOFER

		Self:oRecsAloc[(cAlias)->G2_RECURSO] := .T.

		(cAlias)->(dbSkip())

		oInfo["primeiraOper"] := (cAlias)->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) <> cOp

		_Super:delegar("P152CalTem", oInfo:toJson(), Self:cProg)

		nPriOperac++
		nDelegados++

		If nDelegados == 50
			Self:atualizaPercentual(CHAR_ETAPAS_CALC_TEMP)
			nDelegados := 0
		EndIf

		lSucesso := _Super:permiteProsseguir()
	End
	(cAlias)->(dbCloseArea())

	_Super:gravaValorGlobal("JSON_OPS_FILHAS", oOPsFilhas:toJson())

	FreeObj(oInfo)
	FwFreeObj(oOPsFilhas)
Return lSucesso

/*/{Protheus.doc} queryOpPrincipal
Retorna a query que busca as OPs principais (query base - âncora da recursividade)
@author Marcelo Neumann
@since 21/07/2023
@version P12
@param lFieldsSG2, Logico  , Indica se deve usar no SELECT os campos da tabela SG2
@return cQuery   , Caracter, Sql da query principal
/*/
Method queryOpPrincipal(lFieldsSG2) Class PCPA152TempoOperacao
	Local cQuery := ""

	cQuery := " SELECT DISTINCT SC2_Base.C2_NUM,"
	cQuery +=                 " SC2_Base.C2_ITEM,"
	cQuery +=                 " SC2_Base.C2_SEQUEN,"
	cQuery +=                 " SC2_Base.C2_ITEMGRD,"
	cQuery +=                 " SC2_Base.C2_OP,"
	cQuery +=                 " SC2_Base.C2_QUANT,"
	cQuery +=                 " SC2_Base.C2_QUJE,"
	cQuery +=                 " SC2_Base.C2_PERDA,"
	cQuery +=                 " SC2_Base.C2_DATPRI,"
	cQuery +=                 " SC2_Base.C2_DATPRF,"
	cQuery +=                 " SC2_Base.C2_SEQPAI,"
	cQuery +=                 " SC2_Base.C2_TPOP,"
	cQuery +=                 " SC2_Base.C2_PRIOR,"
	cQuery +=                 " SC2_Base.C2_PRODUTO,"
	cQuery +=                 " SC2_Base.ROTEIRO,"
	cQuery +=                 " SC2_Base.RECNO_OP Arvore,"
	cQuery +=                 " SC2_Base.C2_STATUS status,"
	cQuery +=                 " 1 OP_Principal,"

	If lFieldsSG2
		cQuery +=    " OPER_OP.OPERACAO AS G2_OPERAC,"
		cQuery +=    " OPER_OP.RECURSO  AS G2_RECURSO,"
		cQuery +=    " OPER_OP.TEMPAD   AS G2_TEMPAD,"
		cQuery +=    " OPER_OP.LOTEPAD  AS LotePadrao,"
		cQuery +=    " CASE"
		cQuery +=       " WHEN OPER_OP.CTRAB = ' ' THEN SH1.H1_CTRAB"
		cQuery +=       " ELSE OPER_OP.CTRAB"
		cQuery +=    " END CentroTrabalho,"
		cQuery +=    " OPER_OP.SETUP      AS G2_SETUP, "
		cQuery +=    " OPER_OP.FINALIZA   AS G2_TEMPEND, "
		cQuery +=    " OPER_OP.USA_ALT    AS G2_USAALT, "
		cQuery +=    " OPER_OP.TIPO       AS G2_TPOPER, "
		cQuery +=    " OPER_OP.MAOOBRA    AS MAOOBRA, "
		cQuery +=    " OPER_OP.TIPOSOBRE  AS TIPOSOBRE, "
		cQuery +=    " OPER_OP.TEMPOSOBRE AS TEMPOSOBRE, "
		cQuery +=    " OPER_OP.REMOCAO    AS REMOCAO, "
		cQuery +=    " OPER_OP.FERRAMENTA AS FERRAMENTA, "
		cQuery +=    " OPER_OP.TIPOALOFER AS TIPOALOFER, "
		cQuery +=    " OPER_OP.VLDINI     AS VLDINI,"
		cQuery +=    " OPER_OP.VLDFIM     AS VLDFIM,"
	EndIf
	cQuery +=        " SC2_Base.SALDO "
	cQuery +=   " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " SC2_Base"
	cQuery +=  /*INNER JOIN */ Self:queryJoinOperacoes("SC2_Base", .F.)
	cQuery +=  " WHERE NOT EXISTS (SELECT 1"
	cQuery +=                     " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " a"
	cQuery +=                   /* INNER JOIN */ Self:queryJoinOperacoes("a", .F.)
	cQuery +=                    " WHERE a.C2_NUM     = SC2_Base.C2_NUM"
	cQuery +=                      " AND a.C2_ITEM    = SC2_Base.C2_ITEM"
	cQuery +=                      " AND a.C2_ITEMGRD = SC2_Base.C2_ITEMGRD"
	cQuery +=                      " AND a.C2_SEQUEN  = SC2_Base.C2_SEQPAI)"

Return cQuery

/*/{Protheus.doc} queryRecursivaWith
Retorna a query recursiva para busca das operações (somente a WITH)
@author Marcelo Neumann
@since 21/07/2023
@version P12
@return cWith, Caracter, Sql da query recursiva
/*/
Method queryRecursivaWith() Class PCPA152TempoOperacao
	Local cWith := ""

	cWith := "WITH opsEmArvore(C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, C2_OP, C2_QUANT,C2_QUJE," + ;
	                         " C2_PERDA, C2_DATPRI, C2_DATPRF, C2_SEQPAI, C2_TPOP, C2_PRIOR,"    + ;
	                         " C2_PRODUTO, ROTEIRO, Arvore, status, OP_Principal, SALDO)"    + ;
	        " AS ("                                                                          + ;
	        /*SELECT */ Self:queryOpPrincipal(.F.)                                           + ;
	         " UNION ALL"                                                                    + ;
	        " SELECT SC2.C2_NUM,"                                                            + ;
	               " SC2.C2_ITEM,"                                                           + ;
	               " SC2.C2_SEQUEN,"                                                         + ;
	               " SC2.C2_ITEMGRD,"                                                        + ;
	               " SC2.C2_OP,"                                                             + ;
	               " SC2.C2_QUANT,"                                                          + ;
	               " SC2.C2_QUJE,"                                                           + ;
	               " SC2.C2_PERDA,"                                                          + ;
	               " SC2.C2_DATPRI,"                                                         + ;
	               " SC2.C2_DATPRF,"                                                         + ;
	               " SC2.C2_SEQPAI,"                                                         + ;
	               " SC2.C2_TPOP,"                                                           + ;
	               " SC2.C2_PRIOR,"                                                          + ;
	               " SC2.C2_PRODUTO,"                                                        + ;
	               " SC2.ROTEIRO,"                                                           + ;
	               " Qry_Recurs.Arvore Arvore,"                                              + ;
	               " SC2.C2_STATUS status,"                                                  + ;
	               " 2 OP_Principal,"                                                        + ;
	               " SC2.SALDO "                                                             + ;
	          " FROM " + Self:oTempOrdens:GetTableNameForQuery() + " SC2"                    + ;
	         " INNER JOIN opsEmArvore Qry_Recurs"                                            + ;
	            " ON Qry_Recurs.C2_NUM     = SC2.C2_NUM"                                     + ;
	           " AND Qry_Recurs.C2_ITEM    = SC2.C2_ITEM"                                    + ;
	           " AND Qry_Recurs.C2_SEQUEN  = SC2.C2_SEQPAI"                                  + ;
	           " AND Qry_Recurs.C2_ITEMGRD = SC2.C2_ITEMGRD"                                 + ;
	         ")"

	If Self:cBanco == "POSTGRES"
		cWith := StrTran(cWith, 'WITH ', 'WITH recursive ')
	EndIf

Return cWith

/*/{Protheus.doc} queryJoinProduto
Retorna o INNER JOIN com a tabela de produto
@author Marcelo Neumann
@since 21/07/2023
@version P12
@param cAlias, Caracter, Alias da SC2 a ser utilizado no relacionamento
@return cJoin, Caracter, Sql do INNER JOIN com a tabela SB1
/*/
Method queryJoinProduto(cAlias) Class PCPA152TempoOperacao
	Local cJoin := " INNER JOIN " + RetSqlName("SB1") + " SB1"         + ;
	                  " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"  + ;
	                 " AND SB1.B1_COD     = " + cAlias + ".C2_PRODUTO" + ;
	                 " AND SB1.D_E_L_E_T_ = ' '"

	If !Empty(Self:oParTempo["produto"])
		cJoin += " AND SB1.B1_COD IN " + inFilt(Self:oParTempo["produto"])
	EndIf

	If !Empty(Self:oParTempo["grupoProduto"])
		cJoin += " AND SB1.B1_GRUPO IN " + inFilt(Self:oParTempo["grupoProduto"])
	EndIf

	If !Empty(Self:oParTempo["tipoProduto"])
		cJoin += " AND SB1.B1_TIPO IN " + inFilt(Self:oParTempo["tipoProduto"])
	EndIf

Return cJoin

/*/{Protheus.doc} queryJoinOperacoes
Monta o JOIN da tabela temporária de Operações
com a tabela temporária de ordens

@author lucas.franca
@since 21/03/2024
@version P12
@param 01 cAliasSC2 , Caracter, Alias da SC2 temporária para relacionamento com a temp de operações
@return cJoinOper, Caracter, Query com o relacionamento entre as tabelas.
/*/
Method queryJoinOperacoes(cAliasSC2) Class PCPA152TempoOperacao
	Local cJoin := ""

	cJoin := " INNER JOIN " + Self:oTempOperacoes:GetTableNameForQuery() + " OPER_OP "
	cJoin +=    " ON OPER_OP.C2_OP = " + cAliasSC2 + ".C2_OP "
	cJoin += " INNER JOIN " + RetSqlName("SH1") + " SH1"
	cJoin +=    " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "'"
	cJoin +=   " AND SH1.H1_CODIGO  = OPER_OP.RECURSO"
	cJoin +=   " AND SH1.D_E_L_E_T_ = ' '"

	If !Empty(Self:oParTempo["centroTrabalho"])
		cJoin += " AND ( (OPER_OP.CTRAB != ' ' AND OPER_OP.CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + " )"
		cJoin +=    " OR (OPER_OP.CTRAB  = ' ' AND SH1.H1_CTRAB IN " + inFilt(Self:oParTempo["centroTrabalho"]) + ") )"
	EndIf
Return cJoin

/*/{Protheus.doc} queryFiltroOp
Retorna o filtro (WHERE) das ordens de produção
@author Marcelo Neumann
@since 21/07/2023
@version P12
@return cFiltro, Caracter, Sql com o filtro na SC2
/*/
Method queryFiltroOp() Class PCPA152TempoOperacao
	Local cFiltro := ""

	cFiltro := " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
	cFiltro +=   " AND SC2.C2_DATRF   = ' '"
	cFiltro +=   " AND SC2.D_E_L_E_T_ = ' '"
	cFiltro +=   " AND SC2.C2_DATPRF <= '" + DtoS(Self:oParTempo["dataFinal"  ]) + "'"

	If !Self:oParTempo["ordensAtrasadas"]
		cFiltro += " AND SC2.C2_DATPRF >= '" + DtoS(Self:oParTempo["dataInicial"]) + "'"
	EndIf

	If Self:oParTempo["tipoOP"] == PARAM_TIPO_OP_FIRMES
		cFiltro += " AND SC2.C2_TPOP = 'F'"
	ElseIf Self:oParTempo["tipoOP"] == PARAM_TIPO_OP_PREVISTAS
		cFiltro += " AND SC2.C2_TPOP = 'P'"
	EndIf

	If !Self:oParTempo["replanejaSacramentadas"]
		cFiltro += " AND NOT EXISTS (SELECT 1"
		cFiltro +=                   " FROM " + RetSqlName("HWF") + " HWF"
		cFiltro +=                  " WHERE HWF.HWF_FILIAL    = '" + xFilial("HWF") + "'"
		cFiltro +=                    " AND HWF.HWF_STATUS    = '" + STATUS_ATIVO + "' "
		cFiltro +=                    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP") //Compara C2_NUM... com HWF.HWF_OP
		cFiltro +=                    " AND SC2.C2_STATUS = 'S'"
		cFiltro +=                    " AND HWF.D_E_L_E_T_    = ' ')"
	EndIf

	If !Empty(Self:oParTempo["ordemProducao"])
		If Self:cBanco == "POSTGRES"
			cFiltro += " AND CONCAT(SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN, SC2.C2_ITEMGRD) IN " + inFilt(Self:oParTempo["ordemProducao"])
		Else
			cFiltro += " AND SC2.C2_NUM || SC2.C2_ITEM || SC2.C2_SEQUEN || SC2.C2_ITEMGRD IN " + inFilt(Self:oParTempo["ordemProducao"])
		EndIf
	EndIf

	If !Empty(Self:oParTempo["ticketMRP"])
		cFiltro += " AND SC2.C2_SEQMRP IN " + inFilt(Self:oParTempo["ticketMRP"])
		cFiltro += " AND SC2.C2_BATROT = 'PCPA144' "
	EndIf

	If "MSSQL" $ Self:cBanco
		cFiltro := StrTran(cFiltro, "||", "+")
	EndIf

Return cFiltro

/*/{Protheus.doc} queryOrder
Retorna a ordenação das ordens de produção e suas operações conforme as regras de priorização
@author Marcelo Neumann
@since 21/07/2023
@version P12
@param lOpPai , Logico  , Indica se está buscando as ordens principais ou as filhas
@return cOrder, Caracter, Sql do ORDER BY conforme as priorizações
/*/
Method queryOrder(lOpPai) Class PCPA152TempoOperacao
	Local cOrder := ""

	If lOpPai
		If Self:oParTempo["priorizacao"] == PARAM_PRIORIZACAO_DATA_INICIO
			cOrder := " ORDER BY C2_DATPRI, C2_PRIOR, C2_PRODUTO, SALDO DESC, C2_DATPRF, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, G2_OPERAC"
		Else
			cOrder := " ORDER BY C2_DATPRF, C2_PRIOR, C2_PRODUTO, SALDO DESC, C2_DATPRI, C2_NUM, C2_ITEM, C2_SEQUEN, C2_ITEMGRD, G2_OPERAC DESC"
		EndIf
	Else
		If Self:oParTempo["priorizacao"] == PARAM_PRIORIZACAO_DATA_INICIO
			cOrder := " ORDER BY opsEmArvore.C2_SEQPAI, opsEmArvore.C2_DATPRI, opsEmArvore.C2_PRIOR,"
			cOrder +=          " opsEmArvore.C2_PRODUTO, opsEmArvore.SALDO DESC, opsEmArvore.C2_DATPRF, "
			cOrder +=          " opsEmArvore.C2_NUM, opsEmArvore.C2_ITEM, opsEmArvore.C2_SEQUEN,"
			cOrder +=          " opsEmArvore.C2_ITEMGRD, OPER_OP.OPERACAO DESC"
		Else
			cOrder := " ORDER BY opsEmArvore.C2_SEQPAI, opsEmArvore.C2_DATPRF DESC, opsEmArvore.C2_PRIOR,"
			cOrder +=          " opsEmArvore.C2_PRODUTO, opsEmArvore.SALDO DESC, opsEmArvore.C2_DATPRI,"
			cOrder +=          " opsEmArvore.C2_NUM, opsEmArvore.C2_ITEM, opsEmArvore.C2_SEQUEN,"
			cOrder +=          " opsEmArvore.C2_ITEMGRD, OPER_OP.OPERACAO DESC"
		EndIf
	EndIf

Return cOrder

/*/{Protheus.doc} atualizaPercentual
Atualiza a porcentagem atual da etapa de cálculo das operações.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cEtapa, Caracter, Etapa que irá atualizar o percentual.
@return Nil
/*/
Method atualizaPercentual(cEtapa) Class PCPA152TempoOperacao
	Local nAtuPerct := 0
	Local nQtdProc  := 0
	Local nTotal    := 0

	Self:getQuantidades(cEtapa, @nQtdProc, @nTotal)

	nAtuPerct := (nQtdProc * 100) / nTotal
	_Super:gravaPercentual(cEtapa, nAtuPerct)

Return Nil

/*/{Protheus.doc} getQuantidades
Retorna a quantidade total de registros e a quantidade processada de uma etapa.
@author Lucas Fagundes
@since 05/04/2023
@version P21
@param 01 cEtapa, Caracter, Etapa que irá buscar as quantidades.
@param 02 nProcs, Numerico, Retorna por referencia a quantidade de registros processados.
@param 03 nTotal, Numerico, Retorna por referencia a quantidade total de registros.
@return Nil
/*/
Method getQuantidades(cEtapa, nProcs, nTotal) Class PCPA152TempoOperacao

	If cEtapa == CHAR_ETAPAS_CALC_TEMP
		nProcs := _Super:retornaValorGlobal("OPERACOES_FINALIZADAS")
		nTotal := _Super:retornaValorGlobal("TOTAL_OPERACOES")

	ElseIf cEtapa == CHAR_ETAPAS_PRIO_ORDEM
		nProcs := _Super:retornaValorGlobal("OPERS_PRIORIZADAS")
		nTotal := _Super:retornaValorGlobal("TOTAL_PRIORIZACAO")

	ElseIf cEtapa == CHAR_ETAPAS_DIST_ORD
		nProcs := _Super:retornaValorGlobal("OPERS_DISTRIBUIDAS")
		nTotal := _Super:retornaValorGlobal("TOTAL_DISTRIBUICAO")

	EndIf

Return Nil

/*/{Protheus.doc} aguardaFimProcessamento
Aguarda o fim do processamento das operações delegadas.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cEtapa, Caracter, Etapa que irá aguardar o processamento.
@return Nil
/*/
Method aguardaFimProcessamento(cEtapa) Class PCPA152TempoOperacao
	Local nIndex   := 0
	Local nQtdProc := 0
	Local nTotal   := 0

	Self:getQuantidades(cEtapa, @nQtdProc, @nTotal)

	While nQtdProc != nTotal .And. _Super:permiteProsseguir()
		Sleep(500)

		nIndex++
		If nIndex == 5
			Self:atualizaPercentual(cEtapa)
			nIndex := 0
		EndIf

		Self:getQuantidades(cEtapa, @nQtdProc)
	End

Return Nil

/*/{Protheus.doc} P152CalTem
Inicia o cálculo de uma operação.
@type  Function
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param 01 cJson, Caracter, Json com as informações da op que vai calcular o tempo das operações.
@param 02 cProg, Caracter, Código da programação que está sendo executada.
@return Nil
/*/
Function P152CalTem(cJson, cProg)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:calculaOperacao(cJson)
	EndIf

Return Nil

/*/{Protheus.doc} calculaOperacao
Realiza o cálculo da operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param cJson, Caracter, Json com as informações da operação.
@return Nil
/*/
Method calculaOperacao(cJson) Class PCPA152TempoOperacao
	Local aDadosSMF := Array(TAMANHO_ARRAY_PROC_MF)
	Local cChave    := ""

	Self:oInfoOper := JsonObject():New()
	Self:oInfoOper:fromJson(cJson)

	aDadosSMF[ARRAY_MF_FILIAL             ] := Self:cFilialSMF
	aDadosSMF[ARRAY_MF_PROG               ] := Self:cProg
	aDadosSMF[ARRAY_MF_ID                 ] := Self:oInfoOper["idOperacao"   ]
	aDadosSMF[ARRAY_MF_PRIOR              ] := Self:oInfoOper["prioridade"   ]
	aDadosSMF[ARRAY_MF_OP                 ] := Self:oInfoOper["ordemProducao"]
	aDadosSMF[ARRAY_MF_ROTEIRO            ] := Self:oInfoOper["roteiro"      ]
	aDadosSMF[ARRAY_MF_OPER               ] := Self:oInfoOper["operacao"     ]
	aDadosSMF[ARRAY_MF_RECURSO            ] := Self:oInfoOper["recurso"      ]
	aDadosSMF[ARRAY_MF_DTINI              ] := StoD(Self:oInfoOper["dataInicio" ])
	aDadosSMF[ARRAY_MF_DTENT              ] := StoD(Self:oInfoOper["dataEntrega"])
	aDadosSMF[ARRAY_MF_CTRAB              ] := Self:oInfoOper["centroTrabalho"]
	aDadosSMF[ARRAY_MF_ARVORE             ] := Self:oInfoOper["arvoreId"]
	aDadosSMF[ARRAY_MF_SEQPAI             ] := Self:oInfoOper["seqPai"]
	aDadosSMF[ARRAY_PROC_STATUS_OP        ] := Self:oInfoOper["status"]
	aDadosSMF[ARRAY_PROC_OP_PAI           ] := Self:oInfoOper["op_pai"]
	aDadosSMF[ARRAY_MF_SETUP              ] := Self:calculaTempo(Self:oInfoOper["tempoSetup"])
	aDadosSMF[ARRAY_MF_TMPFINA            ] := Self:calculaTempo(Self:oInfoOper["tempoFim"  ])
	aDadosSMF[ARRAY_PROC_PRODUTO          ] := Self:oInfoOper["produto"]
	aDadosSMF[ARRAY_PROC_PRIMEIRA_OPERACAO] := Self:oInfoOper["primeiraOper"]
	aDadosSMF[ARRAY_PROC_ULTIMA_OPERACAO  ] := Self:oInfoOper["ultimaOper"  ]
	aDadosSMF[ARRAY_PROC_CHAVE_ARVORE     ] := Self:getChaveArvore(aDadosSMF)
	aDadosSMF[ARRAY_PROC_RECURSOS         ] := Self:getRecursosOperacao(aDadosSMF)
	aDadosSMF[ARRAY_PROC_USA_ALTERNATIVOS ] := Self:oInfoOper["usaAlternativo"] .And. Len(aDadosSMF[ARRAY_PROC_RECURSOS]) > 1
	aDadosSMF[ARRAY_MF_TPOPER             ] := Self:oInfoOper["tipoOperacao"]
	aDadosSMF[ARRAY_MF_REMOCAO            ] := Self:calculaTempo(Self:oInfoOper["tempoRemocao"])
	aDadosSMF[ARRAY_MF_VLDINI             ] := SToD(Self:oInfoOper["validadeInicial"])
	aDadosSMF[ARRAY_MF_VLDFIM             ] := SToD(Self:oInfoOper["validadeFinal"  ])
	aDadosSMF[ARRAY_MF_TPALOFE            ] := Self:oInfoOper["alocacaoFerramenta"]

	If Self:oParTempo["dicionarioSobreposicao"] .And. !Empty(Self:oInfoOper["tipoSobreposicao"])
		aDadosSMF[ARRAY_MF_TPSOBRE] := Self:oInfoOper["tipoSobreposicao" ]
		aDadosSMF[ARRAY_MF_TEMPSOB] := Self:oInfoOper["tempoSobreposicao"]
		aDadosSMF[ARRAY_MF_SOBREPO] := 0

		If Self:oInfoOper["tipoSobreposicao"] == SOBREPOSICAO_POR_TEMPO
			aDadosSMF[ARRAY_MF_SOBREPO] := Self:tempoSobreposicao(Self:oInfoOper["tipoSobreposicao"], Self:oInfoOper["tempoSobreposicao"])

		ElseIf aDadosSMF[ARRAY_MF_TPSOBRE] == SOBREPOSICAO_POR_QUANTIDADE .And. aDadosSMF[ARRAY_MF_TEMPSOB] == 0
			aDadosSMF[ARRAY_MF_TEMPSOB] := 1

		EndIf
	Else
		aDadosSMF[ARRAY_MF_TPSOBRE] := Nil
		aDadosSMF[ARRAY_MF_TEMPSOB] := 0
		aDadosSMF[ARRAY_MF_SOBREPO] := 0
	EndIf

	Self:calculaSaldo()
	aDadosSMF[ARRAY_MF_SALDO] := Self:oInfoOper["saldo"]

	If aDadosSMF[ARRAY_MF_SALDO] > 0

		Self:calculaDuracaoOperacao()
		Self:tempoRecursos(aDadosSMF)

		aDadosSMF[ARRAY_MF_TEMPO] := __Hrs2Min(Self:arredondaHora(Self:oInfoOper["tempoOperacao"]))
	Else
		aDadosSMF[ARRAY_MF_TEMPO] := 0
	EndIf

	aDadosSMF[ARRAY_PROC_FERRAMENTAS] := Self:oFerramentas:getFerramentasOperacao(Self:oInfoOper)
	If !Empty(aDadosSMF[ARRAY_PROC_FERRAMENTAS]) .And. Empty(aDadosSMF[ARRAY_MF_TPALOFE])
		aDadosSMF[ARRAY_MF_TPALOFE] := TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO
	EndIf

	cChave := Self:oInfoOper["ordemProducao"]
	_Super:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aDadosSMF, .T.)
	_Super:adicionaListaGlobal(LISTA_DADOS_HZ7, aDadosSMF[ARRAY_MF_ID], aDadosSMF[ARRAY_PROC_RECURSOS], .F.)

	_Super:gravaValorGlobal("OPERACOES_FINALIZADAS", 1, .T., .T.)

	Self:insereTempTable(aDadosSMF)

	aSize(aDadosSMF, 0)
	FwFreeObj(Self:oInfoOper)
Return Nil

/*/{Protheus.doc} calculaSaldo
Calcula o saldo de uma operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method calculaSaldo() Class PCPA152TempoOperacao
	Local aApont := Self:carregaApontamentos()
	Local nPerda := 0
	Local nProd  := 0
	Local nQtdOP := 0
	Local nSaldo := 0

	If Empty(aApont)
		nQtdOP := Self:oInfoOper["quantidade"  ]
		nProd  := Self:oInfoOper["qtdProduzida"]
		nPerda := Self:oInfoOper["perda"       ]
	ElseIf !aApont[3]
		nQtdOP := Self:oInfoOper["quantidade"]
		nProd  := aApont[1]
		nPerda := aApont[2]
	EndIf

	If !Self:oParTempo["MV_PERDINF"]
		nProd += nPerda
	EndIf

	nSaldo := nQtdOP - nProd
	Self:oInfoOper["saldo"] := nSaldo

	aSize(aApont, 0)
Return Nil

/*/{Protheus.doc} carregaApontamentos
Carrega os apontamentos da operação que está em Self:oInfoOper
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return aAponts, Array, Array com os apontamentos no seguinte formato: aAponts[1] - Quantidade produziada.
                                                                       aAponts[2] - Quantidade perdida.
                                                                       aAponts[3] - .T. se houve apontamento total.
/*/
Method carregaApontamentos() Class PCPA152TempoOperacao
	Local aAponts := {}
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""

	Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Buscando os apontamentos da operacao " + Self:oInfoOper["ordemProducao"] + "-" + Self:oInfoOper["operacao"]},;
	                    Self:oInfoOper["ordemProducao"], Self:oInfoOper["operacao"])

	If Self:oQryBlock == Nil
		cQuery := " SELECT SUM(H6_QTDPROD) qtdProduzida,"
		cQuery +=        " SUM(H6_QTDPERD) qtdPerda,"
		cQuery +=        " H6_PT"
		cQuery +=   " FROM " + RetSqlName("SH6")
		cQuery +=  " WHERE H6_FILIAL  = '" + xFilial("SH6") + "'"
		cQuery +=    " AND H6_OP      = ?"
		cQuery +=    " AND H6_OPERAC  = ?"
		cQuery +=    " AND D_E_L_E_T_ = ' '"
		cQuery +=  " GROUP BY H6_PT"
		cQuery +=  " ORDER BY H6_PT DESC"

		Self:oQryBlock := FwExecStatement():New(cQuery)
	EndIf

	Self:oQryBlock:setString(1, Self:oInfoOper["ordemProducao"]) // H6_OP
	Self:oQryBlock:setString(2, Self:oInfoOper["operacao"     ]) // H6_OPERAC

	cAlias := Self:oQryBlock:OpenAlias()

	If (cAlias)->(!EoF())
		If AllTrim((cAlias)->H6_PT) == "T"
			aAponts := {0, 0, .T.}
		Else
			aAponts := {0, 0, .F.}
			While (cAlias)->(!EoF())
				aAponts[1] += (cAlias)->qtdProduzida
				aAponts[2] += (cAlias)->qtdPerda

				(cAlias)->(dbSkip())
			End
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, {"Apontamentos da operacao " + Self:oInfoOper["ordemProducao"] + "-" + Self:oInfoOper["operacao"] + ":", ;
		                                            "qtdProduzida: " + cValToChar(aAponts[1]) + " qtdPerda: " + cValToChar(aAponts[2]) + " H6_PT: " + cValToChar(aAponts[3])},;
		                    Self:oInfoOper["ordemProducao"], Self:oInfoOper["operacao"])
	EndIf
	(cAlias)->(dbCloseArea())

Return aAponts

/*/{Protheus.doc} calculaDuracaoOperacao
Calcula o tempo de uma operação.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return Nil
/*/
Method calculaDuracaoOperacao() Class PCPA152TempoOperacao
	Local nLotePad  := Self:oInfoOper["lotePadrao"]
	Local nSaldo    := Self:oInfoOper["saldo"     ]
	Local nTempo    := 0
	Local nTempoPad := Self:oInfoOper["tempoPadrao"]

	If Self:oParTempo["MV_TPHR"] == "N"
		nTempoPad := Self:horasNormaisParaCentesimais(nTempoPad)
	EndIf

	If Self:oInfoOper["tipoOperacao"] == TIPO_OPERACAO_TEMPO_MINIMO
		nTempo := Ceiling((nSaldo / nLotePad)) * nTempoPad

	ElseIf Self:oInfoOper["tipoOperacao"] == TIPO_OPERACAO_TEMPO_FIXO .Or. Self:oInfoOper["tipoOperacao"] == TIPO_OPERACAO_ILIMITADA
		nTempo := nTempoPad

	Else
		nTempo := nSaldo * (nTempoPad / nLotePad)

	EndIf

	Self:oInfoOper["tempoOperacao"] := Self:horasCentesimaisParaNormais(nTempo, .F.)

Return Nil

/*/{Protheus.doc} gravaDados
Delega a gravação das tabelas para as threads.
@author Lucas Fagundes
@since 11/04/2023
@version P12
@return Nil
/*/
Method gravaDados() Class PCPA152TempoOperacao
	Local lNovaProg := .F.
	Local nRegsHZ7  := 0
	Local oInicio   := _Super:getStatusInicioProgramacao()

	lNovaProg := !oInicio["reprocessando"] .And. !oInicio["continuando"]

	If lNovaProg .And. Self:oParTempo["dicionarioAlternativo"]
		_Super:delegar("P152CalGrv", Self:cProg, "HZ7")
	Else
		nRegsHZ7 := Len(_Super:retornaListaGlobal(LISTA_DADOS_HZ7))

		_Super:gravaValorGlobal("REGISTROS_GRAVADOS", nRegsHZ7, .T., .T.)
		_Super:gravaValorGlobal("GRAVACAO_HZ7", "END")
	EndIf

	_Super:delegar("P152CalGrv", Self:cProg, "SMF")
	_Super:delegar("P152CalGrv", Self:cProg, "SVM")

	FreeObj(oInicio)
Return Nil

/*/{Protheus.doc} P152CalGrv
Realiza a gravação de uma tabela em outra thread.
@type  Function
@author Lucas Fagundes
@since 11/04/2023
@version P12
@param 01 cProg  , Caracter, Código da programação que está em execução.
@param 02 cTabela, Caracter, Alias da tabela que irá gravar.
@param 03 aDados , Arrray  , Array com os dados para gravar na tabela.
@return Nil
/*/
Function P152CalGrv(cProg, cTabela)
	Local aDados := {}
	Local cLista := ""
	Local oTempoOper := Nil
	Local oProcesso  := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper) .And. PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)
		If cTabela == "SMF"
			cLista := LISTA_DADOS_SMF
		ElseIf cTabela == "SVM"
			cLista := LISTA_DADOS_SVM
		ElseIf cTabela == "HZ7"
			cLista := LISTA_DADOS_HZ7
		EndIf
		aDados := oProcesso:retornaListaGlobal(cLista)

		oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "PROC")

		If oTempoOper:gravaTabela(cTabela, aDados)
			oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "END")
		Else
			oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "ERRO")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} gravaTabela
Realiza a gravação dos dados em uma tabela.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param 01 cTabela, Caracter, Alias da tabela que irá gravar os dados.
@param 02 aDados , Array   , Dados que irá gravar na tabela.
@return lSucesso, Logico, Retorna se a gravação foi realizada com sucesso.
/*/
Method gravaTabela(cTabela, aDados) Class PCPA152TempoOperacao
	Local aAux      := {}
	Local cDetErro  := ""
	Local cErro     := ""
	Local cUpdSMF   := ""
	Local lSucesso  := .T.
	Local nIndChave := 1
	Local nIndDados := 1
	Local nTempoIni := MicroSeconds()
	Local nTotChave := Len(aDados)
	Local nTotDados := 0
	Local oBulk     := FwBulk():New()

	oBulk:setTable(RetSqlName(cTabela))
	oBulk:setFields(estrutTab(cTabela))

	BEGIN TRANSACTION

	While nIndChave <= nTotChave .And. lSucesso
		aAux      := aDados[nIndChave][2]
		nTotDados := Len(aAux)
		nIndDados := 1

		While nIndDados <= nTotDados .And. lSucesso
			lSucesso := oBulk:addData(Self:converteArrayProcessamentoParaGravacao(cTabela, aAux[nIndDados]))
			aSize(aAux[nIndDados], 0)

			If lSucesso
				nIndDados++
				lSucesso := _Super:permiteProsseguir()
			EndIf
		End

		aSize(aAux, 0)
		aSize(aDados[nIndChave], 0)

		_Super:gravaValorGlobal("REGISTROS_GRAVADOS", 1, .T., .T.)

		If lSucesso
			nIndChave++
			lSucesso := _Super:permiteProsseguir()
		EndIf
	End

	If lSucesso
		lSucesso := oBulk:close()
	EndIf

	If !lSucesso
		lSucesso := .F.
		cErro    := i18n(STR0182, {cTabela}) //"Erro na gravação da tabela #1[tabela]#."
		cDetErro := oBulk:getError()
	EndIf

	If lSucesso .And. cTabela == "SMF"
		cUpdSMF := "UPDATE " + RetSqlName("SMF")
		cUpdSMF +=   " SET MF_PROGEF = COALESCE((SELECT Max(HWF.HWF_PROG)"
		cUpdSMF +=                               " FROM " + RetSqlName("HWF") + " HWF"
		cUpdSMF +=                              " WHERE HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
		cUpdSMF +=                                " AND HWF.HWF_OP     = MF_OP"
		cUpdSMF +=                                " AND HWF.HWF_STATUS = '" + STATUS_ATIVO + "' "
		cUpdSMF +=                                " AND HWF.D_E_L_E_T_ = ' '), ' ')"
		cUpdSMF += " WHERE MF_FILIAL  = '" + xFilial("SMF") + "'"
		cUpdSMF +=   " AND MF_PROG    = '" + Self:cProg + "'"
		cUpdSMF +=   " AND D_E_L_E_T_ = ' '"

		If TcSqlExec(cUpdSMF) < 0
			lSucesso := .F.
			cErro    := STR0383 //"Erro ao atualizar o número da programação efetivada na tabela SMF."
			cDetErro := TCSqlError() + cUpdSMF
		EndIf
	EndIf

	If !lSucesso
		DisarmTransaction()

		If !Empty(cErro)
			_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, cErro, cDetErro)
		EndIf
	EndIf

	END TRANSACTION

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo gravacao da tabela " + cTabela + ": " + cValToChar(MicroSeconds() - nTempoIni)})

	oBulk:destroy()
	aSize(aDados, 0)
Return lSucesso

/*/{Protheus.doc} estrutTab
Carrega o array com a estrutura da tabela SMF para a gravação dos dados.
@type  Static Function
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return aEstrut, Array, Array com a estrutura da tabela SMF.
/*/
Static Function estrutTab(cTabela)
	Local aEstrut := {}
	Local aFields := _oMapFields[cTabela]
	Local cCampo  := ""
	Local nIndex  := 0
	Local nTotal  := Len(aFields)

	For nIndex := 1 To nTotal
		cCampo := aFields[nIndex][1]

		If PCPA152Process():existeCampo(cCampo)
			aAdd(aEstrut, {cCampo})
		EndIf
	Next

Return aEstrut

/*/{Protheus.doc} inFilt
Monta a condição IN da query para os centros de trabalho e recursos.
@type  Static Function
@author Lucas Fagundes
@since 20/03/2023
@version P12
@param aFiltro, Array, Array com os dados para o filtro.
@return cInQuery, Caracter, Condição IN para filtrar a query.
/*/
Static Function inFilt(aFiltro)
	Local cInQuery := ""
	Local nIndex   := 0
	Local nTotal   := Len(aFiltro)

	cInQuery += "("
	For nIndex := 1 To nTotal
		cInQuery += "'" + aFiltro[nIndex] + "'"

		If nIndex != nTotal
			cInQuery += ", "
		EndIf
	Next
	cInQuery += ")"

Return cInQuery

/*/{Protheus.doc} horasNormaisParaCentesimais
Converte horas normais para horas centesimais.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param nHora, Numerico, Hora normal que será convertida.
@return nHoraConv, Numerico, Hora normal convertida para hora centesimal.
/*/
Method horasNormaisParaCentesimais(nHora) Class PCPA152TempoOperacao
	Local nHoraConv := 0

	nHoraConv := Int(nHora) + (((nHora - Int(nHora)) / 60) * 100)

Return nHoraConv

/*/{Protheus.doc} horasCentesimaisParaNormais
Converte horas centesimais para horas normais.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@param 01 nHora     , Numerico, Hora centesimal que será convertida.
@Param 02 lArredonda, Logico  , Indica se deve arredondar o tempo.
@return nHoraConv, Numerico, Hora centesimal convertida para hora normal.
/*/
Method horasCentesimaisParaNormais(nHora, lArredonda) Class PCPA152TempoOperacao
	Local nHoraAux  := 0
	Local nMinutos  := 0
	Local nHoraConv := 0
	Default lArredonda := .T.

	nHoraAux := Int(nHora)
	nMinutos := (nHora - nHoraAux) * 0.6

	nHoraConv := nHoraAux + nMinutos

	If lArredonda
		nHoraConv := PCPA152TempoOperacao():arredondaHora(nHoraConv)
	EndIf

Return nHoraConv

/*/{Protheus.doc} arredondaHora
Arredonda a hora para cima (7:323 para 7:33).
@author lucas.franca
@since 14/11/2023
@version P12
@param nHora, Numerico, Hora a ser arredondada.
@return nHora, Numerico, Hora arredondada para cima (duas casas decimais).
/*/
Method arredondaHora(nHora) Class PCPA152TempoOperacao
	Local nDecimal := nHora - Int(nHora)
	Local nDif     := 0

	//Arredonda o tempo com 2 casas decimais, sempre arredondando para cima.
	nHora    := Int(nHora)
	nDif     := nDecimal - NoRound(nDecimal, 2)
	nDecimal := NoRound(nDecimal, 2)
	If nDif <> 0
		nDecimal += 0.01
	EndIf
	nHora += nDecimal

Return nHora

/*/{Protheus.doc} processaDistribuicao()
Processa a distribuição das operações.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@return lSucesso, Logico, Indica se teve sucesso na distribuição das operações.
/*/
Method processaDistribuicao() Class PCPA152TempoOperacao
	Local aOrdens    := {}
	Local lSucesso   := .T.
	Local nDelegados := 0
	Local nIndex     := 1
	Local nTotal     := 0

	aOrdens := _Super:retornaListaGlobal(LISTA_DADOS_SMF)
	nTotal  := Len(aOrdens)

	_Super:gravaValorGlobal("TOTAL_DISTRIBUICAO", nTotal)
	_Super:gravaValorGlobal("OPERS_DISTRIBUIDAS", 0     )

	While nIndex <= nTotal .And. lSucesso
		_Super:delegar("P152Dist", Self:cProg, aOrdens[nIndex])
		aSize(aOrdens[nIndex], 0)

		nDelegados++
		If nDelegados == 10
			Self:atualizaPercentual(CHAR_ETAPAS_DIST_ORD)
			nDelegados := 0
		EndIf

		nIndex++
		lSucesso := _Super:permiteProsseguir()
	End

	Self:aguardaFimProcessamento(CHAR_ETAPAS_DIST_ORD)

	If _Super:permiteProsseguir()

		_Super:delegar("P152AftDis", Self:cProg, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T., .T.)

		Self:reprocessaDistribuicao()
	EndIf

	aSize(aOrdens, 0)
Return lSucesso

/*/{Protheus.doc} P152Dist
Realiza a distribuição das operações de uma ordem.
@type  Function
@author Lucas Fagundes
@since 04/04/2023
@version P12
@param 01 cProg , Caracter, Código da programação que está executando.
@param 02 aOrdem, Array   , Array com as informações da ordem que irá distribuir as operações.
@return Nil
/*/
Function P152Dist(cProg, aOrdem)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:distribuiOperacoes(aOrdem)
	EndIf

Return Nil

/*/{Protheus.doc} P152AftDis
Envia para a global e limpa informações que ficaram na memória local das threads após o processamento da distribuição.
(Função executada em todas as threads abertar pelo CRP após o processamento da distribuição)

@type  Function
@author Lucas Fagundes
@since 08/07/2024
@version P12
@param 01 cProg, Caracter, Código da programação que está executando.
@return Nil
/*/
Function P152AftDis(cProg)
	Local oTempoOper := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oTempoOper)
		oTempoOper:oOcorrens:localToGlobal()
		oTempoOper:limpaDisponibilidade(.T.)
	EndIf

Return Nil

/*/{Protheus.doc} distribuiOperacoes
Realiza a distribuição do tempo das operações de uma ordem.
@author Lucas Fagundes
@since 04/04/2023
@version P12
@param aOrdem, Array, Array com as informações da ordem de produção que irá distribuir as operações.
@return Nil
/*/
Method distribuiOperacoes(aOrdem) Class PCPA152TempoOperacao
	Local aDados     := aOrdem[2]
	Local aGetData  := {}
	Local aOperacao := {}
	Local aPeriodos := {}
	Local aVldData  := {}
	Local cOrdem     := aOrdem[1]
	Local cRecurso   := ""
	Local dDataFim   := Nil
	Local dDataIni   := Nil
	Local lEntrega   := Self:oParTempo["priorizacao"] == PARAM_PRIORIZACAO_DATA_ENTREGA
	Local lOperDist  := .T.
	Local nIndOper   := 1
	Local nSeq       := 1
	Local nTotOper   := 0
	Local nTotPer    := 0

	Self:lBkpDisp := .T.

	If lEntrega .Or. Empty(aDados[1][ARRAY_MF_SEQPAI])
		aSort(aDados,,,{|x,y| x[ARRAY_MF_PRIOR] < y[ARRAY_MF_PRIOR]})
	Else
		aSort(aDados,,,{|x,y| x[ARRAY_MF_PRIOR] > y[ARRAY_MF_PRIOR]})
	EndIf

	Self:cEtapaLog := CHAR_ETAPAS_DIST_ORD

	aVldData := aClone(aDados[1])

	Self:oFerramentas:setJsonUtilizacao("{}")

	nTotOper := Len(aDados)
	While nIndOper <= nTotOper .And. _Super:permiteProsseguir() .And. lOperDist
		If aDados[nIndOper][ARRAY_MF_SALDO] <= 0
			nIndOper++
			Loop
		EndIf

		aOperacao := aDados[nIndOper]
		nSeq      := 0
		cRecurso  := aOperacao[ARRAY_MF_RECURSO]

		If !Self:oDispRecur:hasProperty(cRecurso)
			Self:getDisponibilidadeDistribuicao()
		EndIf

		Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Processando a distribuicao da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP]},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

		Self:preAlocacaoAtualizaSobreposicao(aOperacao, lEntrega)

		aGetData := Self:getDataInicioOperacao(aOperacao, lEntrega, cRecurso)
		aPeriodos := Self:alocaOperacao(aOperacao, lEntrega, aGetData, @lOperDist, .F.)

		If lOperDist
			nTotPer := Len(aPeriodos)

			Self:adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecurso, aOperacao[ARRAY_MF_SOBREPO])

			If nTotPer > 0
				If dDataIni == Nil .Or. dDataIni > aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
					dDataIni := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
				EndIf

				If dDataFim == Nil .Or. dDataFim < aPeriodos[nTotPer][ARRAY_DISPONIBILIDADE_DATA]
					dDataFim := aPeriodos[nTotPer][ARRAY_DISPONIBILIDADE_DATA]
				EndIf
			EndIf

			Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Finalizada a distribuicao da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP]},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		Else
			Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Operacao nao distribuida.", "Limpando as operacoes distribuidas da ordem " + aOperacao[ARRAY_MF_OP]},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

			Self:adicionaListaGlobal("REPROCESSA_DISTRIBUICAO", cOrdem, aDados)
			Self:limpaOperacoesAlocadas()
			Self:removeOcorrenciasDistribuicao(aOperacao[ARRAY_PROC_CHAVE_ARVORE], cOrdem)
		EndIf

		aPeriodos := {}

		nIndOper++
	End

	If lOperDist
		Self:efetivaOperacoesAlocadas()

		Self:validaDatasOp(aVldData, dDataIni, dDataFim)
	EndIf

	Self:restauraBackupDisponibilidades()
	Self:lBkpDisp := .F.

	_Super:gravaValorGlobal("OPERS_DISTRIBUIDAS", 1, .T., .T.)

	aSize(aOperacao, 0)
	aSize(aDados   , 0)
	aSize(aVldData , 0)
Return Nil

/*/{Protheus.doc} getPeriodosOperacao
Percorre a disponibilidade do recurso consumindo o tempo para a alocação.
@author Lucas Fagundes
@since 05/04/2023
@version P12
@param 01 aOperacao  , Array   , Array com as informações da operação.
@param 02 lDecresce  , Lógico  , Indica que deve fazer a alocação de forma decrescente (da maior data para menor).
@param 03 dDataStart , Date    , Indica a data inicial da alocação.
@param 04 nHoraStart , Numerico, Indica a hora inicial da alocação.
@param 05 lOperDist  , Lógico  , Retorna por referência se conseguiu alocar toda a operação.
@param 06 lDispAdc   , Lógico  , Indica se deve utilizar/criar disponibilidade adicional para o recurso se faltar.
@param 07 lAlocPost  , Lógico  , Retorna por referência se realizou alocação em data posterior a data limite do CRP.
@param 08 lRetCria   , Lógico  , Retorna por referência se criou disponibilidade adicional.
@param 08 cRecurso   , Caracter, Recurso que vai alocar a operação.
@param 09 lSimula    , Caracter, Indica que está simulando a alocação da operação.
@param 10 aFerramenta, Array   , Array com as ferramentas que serão utilizadas na alocação da operação.
@return aPeriodos, Array, Array com os periodos que a operação será alocada.
/*/
Method getPeriodosOperacao(aOperacao, lDecresce, dDataStart, nHoraStart, lOperDist, lDispAdc, lAlocPost, lRetCria, cRecurso, lSimula, aFerramenta) Class PCPA152TempoOperacao
	Local aDisp      := {}
	Local aLogPer    := {}
	Local aOpParc    := Nil
	Local aPeriodos  := {}
	Local cTipoPer   := ""
	Local dDataAnt   := dDataStart
	Local dLastDate  := dDataStart
	Local lAddSetup  := .F.
	Local lAloca     := .T.
	Local lContinua  := .T.
	Local lCriaDisp  := .F.
	Local lCriouDisp := .F.
	Local lSetup     := .F.
	Local nHora      := nHoraStart
	Local nIndDisp   := 0
	Local nIndex     := 0
	Local nTamDisp   := 0
	Local nTamInterv := 0
	Local nTotPer    := 0
	Local oDisp      := Nil
	Default cRecurso := aOperacao[ARRAY_MF_RECURSO]
	Default lDispAdc := .F.
	Default lSimula  := .F.

	aOperacao := aClone(aOperacao)

	Self:lDispAdc     := lDispAdc
	Self:lCriaDisp    := Self:lDispAdc .And. !lDecresce
	Self:lDecresce    := lDecresce
	Self:aIntervalo   := {}
	Self:aOpersAnt    := {}
	Self:aOperacao    := aOperacao
	Self:aFerramentas := aFerramenta

	Self:nTempoOper := Self:calcTempoAlocacao(aOperacao, cRecurso)

	If lSimula .And. Self:lCriaDisp
		_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

		oDisp:lSimula := .T.
	EndIf

	lOperDist := .T.
	lRetCria  := .F.

	Self:oLogs:gravaLog(Self:cEtapaLog, {"Ordem: " + aOperacao[ARRAY_MF_OP] + ", Recurso: " + cRecurso + ", Operacao: " + aOperacao[ARRAY_MF_OPER] + ". " + Iif(lSimula, "Simulando", "Buscando") + " periodos para alocacao com " + IIf(lDecresce ,"entrega ate ", "inicio em ") + DtoC(dDataStart) + " as " + __Min2Hrs(nHoraStart, .T.)},;
	                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

	nIndDisp := Self:buscaIndiceDisponibilidade(cRecurso, dDataStart, nHoraStart, Self:lDispAdc, @lRetCria)
	nTamDisp := Len(Self:oDispRecur[cRecurso])

	lContinua := Self:nTempoOper > 0 .And. nIndDisp > 0 .And. nIndDisp <= nTamDisp
	While lContinua
		aDisp     := Self:oDispRecur[cRecurso][nIndDisp]
		dLastDate := aDisp[ARRAY_DISP_RECURSO_DATA]
		lAloca    := Self:disponibilidadeDisponivel(aDisp, nIndDisp)

		If lAloca .And. aDisp[ARRAY_DISP_RECURSO_DATA] > Self:oParTempo["dataFinal"] .And. !Self:lCriaDisp
			Exit
		EndIf

		If lAloca
			If aDisp[ARRAY_DISP_RECURSO_DATA] > Self:oParTempo["dataFinal"]
				lAlocPost := .T.
			EndIf

			If aDisp[ARRAY_DISP_RECURSO_DATA] != dDataAnt
				nHora := __Hrs2Min(Iif(Self:lDecresce, "24:00", "00:00"))
			EndIf
			dDataAnt := aDisp[ARRAY_DISP_RECURSO_DATA]

			If Self:lBkpDisp
				Self:gravaBackupDisponibilidades(cRecurso, nIndDisp)
			EndIf

			Self:consomeDisponibilidade(aOperacao, nIndDisp, @Self:nTempoOper, @nHora, @aPeriodos, dDataStart, nHoraStart, @lSetup, cRecurso)
		EndIf

		If Self:lDecresce
			nIndDisp--
		Else
			nIndDisp++
		EndIf

		lContinua  := Self:nTempoOper > 0 .And. nIndDisp > 0 .And. nIndDisp <= nTamDisp
		nTamInterv := Len(Self:aIntervalo)

		// Cria disponibilidade adicional se ...
		If Self:lCriaDisp
			// ... já verificou todas disponibilidades do recurso e a operação ainda não foi alocada por completo.
			lCriaDisp := !lContinua .And. Self:nTempoOper > 0

			// ... não pode alocar no intervalo de alocacão e o intervalo vai até o final da disponibilidade do recurso.
			If !lCriaDisp .And. nTamInterv > 0 .And. !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
				lCriaDisp := Self:validaFimIntervalo(cRecurso)
			EndIf
		EndIf

		If lCriaDisp
			lAddSetup := nTamInterv > 0 .And. !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR] .And. Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]

			If lAddSetup
				Self:nTempoOper += aOperacao[ARRAY_MF_SETUP]
			EndIf

			lContinua := Self:criaDisponibilidadeRecurso(cRecurso, Self:nTempoOper, dDataAnt)
			If lContinua
				nIndDisp  := Self:buscaIndiceDisponibilidade(cRecurso, dDataAnt, nHora, Self:lDispAdc, @lCriouDisp)
				lRetCria  := .T.
				nTamDisp  := Len(Self:oDispRecur[cRecurso])
				lContinua := nIndDisp > 0 .And. nIndDisp <= nTamDisp

				Self:aIntervalo := {}
			EndIf

			If lAddSetup
				Self:nTempoOper -= aOperacao[ARRAY_MF_SETUP]
			EndIf
		EndIf
	End

	If Self:nTempoOper > 0
		lOperDist  := .F.

		aOpParc := Array(ARRAY_OPS_PARC_TAMANHO)
		aOpParc[ARRAY_OPS_PARC_TEMPO_OPER       ] := aOperacao[ARRAY_MF_TEMPO] + Self:getTempoFinalizacao(aOperacao, cRecurso)
		aOpParc[ARRAY_OPS_PARC_TEMPO_FALTANTE   ] := Self:nTempoOper
		aOpParc[ARRAY_OPS_PARC_TEMPO_ULTIMA_DATA] := dLastDate

		If lSetup .Or. (nTamInterv > 0 .And. !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR] .And. Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP])
			aOpParc[ARRAY_OPS_PARC_TEMPO_OPER] += aOperacao[ARRAY_MF_SETUP]
			If !lSetup
				aOpParc[ARRAY_OPS_PARC_TEMPO_FALTANTE] += aOperacao[ARRAY_MF_SETUP]
			EndIf
		EndIf

		If !Self:oParTempo["quebraOperacoes"] .And.;
		   nTamInterv > 0                     .And.;
		   aOpParc[ARRAY_OPS_PARC_TEMPO_OPER] == aOpParc[ARRAY_OPS_PARC_TEMPO_FALTANTE]
			//Quando não permite quebrar as operações
			//só vai diminuir de nTempoOper se puder fazer a alocação
			//Por conta disso o tempo que falta para alocar não vai estar correto na nTempoOper.
			//Busca no aIntervalo quanto é o tempo alocável e diminui do tempo que falta alocar.
			//Tbm busca a última data de disponibilidade do recurso.
			aOpParc[ARRAY_OPS_PARC_TEMPO_FALTANTE   ] -= Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL]
			aOpParc[ARRAY_OPS_PARC_TEMPO_ULTIMA_DATA] := aTail(Self:oDispRecur[cRecurso])[ARRAY_DISP_RECURSO_DATA]
		EndIf

		Self:oOPsParc[aOperacao[ARRAY_MF_OP]] := aOpParc
	EndIf

	Self:ordenaArrayPeriodos(@aPeriodos)

	If lSetup
		aPeriodos := Self:ajustaSetup(aOperacao, aPeriodos)
	EndIf

	If Self:getTempoFinalizacao(aOperacao, cRecurso) > 0
		aPeriodos := Self:ajustaFinalizacao(aOperacao, aPeriodos)
	EndIf

	If aOperacao[ARRAY_MF_REMOCAO] > 0
		aPeriodos := Self:adicionaTempoRemocao(aOperacao, aPeriodos)
	EndIf

	Self:alocaFerramentas(aPeriodos)

	Self:oOpersFina:delName(Self:getChaveOperacao(aOperacao))

	If Self:oLogs:logAtivo()
		nTotPer    := Len(aPeriodos)
		aLogPer    := Array(nTotPer+2)
		aLogPer[1] := "--- Periodos encontrados - Ordem " + aOperacao[ARRAY_MF_OP] + ", Recurso: " + cRecurso + ", Operacao: " + aOperacao[ARRAY_MF_OPER] +;
		              ", Alocacao completa: " + Iif(lOperDist, "sim", "nao, Tempo faltante: " + __Min2Hrs(aOpParc[ARRAY_OPS_PARC_TEMPO_FALTANTE], .T.)) + " ---"
		For nIndex := 1 To nTotPer
			If aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_SETUP
				cTipoPer := "setup"
			ElseIf aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_PRODUCAO
				cTipoPer := "producao"
			ElseIf aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_FINALIZACAO
				cTipoPer := "finalizacao"
			ElseIf aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_REMOCAO
				cTipoPer := "remocao"
			EndIf
			aLogPer[nIndex+1] := DToC(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_DATA])                               + ;
			                     " inicio " + __Min2Hrs(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + ;
			                     " fim "    + __Min2Hrs(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM]   , .T.) + ;
			                     " tipo "   + cTipoPer + ;
			                     " tempo total " + cValToChar(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TEMPO]) + " minutos"
		Next nIndex
		aLogPer[nTotPer+2] := "---------------------------------------------------------------"

		Self:oLogs:gravaLog(Self:cEtapaLog, aLogPer, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		aSize(aLogPer, 0)
	EndIf

	If lSimula .And. Self:lCriaDisp
		oDisp:lSimula := .F.

		If lRetCria
			oDisp:limpaUltimaDataSimulada(cRecurso)
		EndIf
	EndIf

	If lRetCria .And. lOperDist
		Self:oFerramentas:geraIndisponibilidadesAdicionais()
	EndIf

	Self:aOperacao    := {}
	Self:aFerramentas := {}
	Self:aIntervalo   := {}
	aOpParc := Nil
Return aPeriodos

/*/{Protheus.doc} buscaIndiceDisponibilidade
Retorna o indice com disponibilidade para alocação a partir da data recebida.
@author Lucas Fagundes
@since 21/12/2023
@version P12
@param 01 cRecurso  , Caracter, Código do recurso que irá buscar o indice.
@param 02 dData     , Date    , Data que irá buscar.
@param 03 nHora     , Numerico, Hora que irá buscar.
@param 04 lDispAdc  , Logico  , Indica se deve utilizar disponibilidade adicional para o recurso se faltar.
@param 05 lCriouDisp, Logico  , Retorna por referência se criou disponibilidade adicional.
@return nIndDisp, Numerico, Indice do array Self:oDispRecur com disponiblidade para alocação.
/*/
Method buscaIndiceDisponibilidade(cRecurso, dData, nHora, lDispAdc, lCriouDisp) Class PCPA152TempoOperacao
	Local aDispRec   := {}
	Local dFim       := Nil
	Local cData      := DToS(dData)
	Local lDataExist := .T.
	Local nFim       := 0
	Local nIndDisp   := 0
	Local nInicio    := 1
	Local nStep      := 1
	Local nTamDisp   := Len(Self:oDispRecur[cRecurso])
	Local oIndices   := Nil
	Local oDisp      := Nil

	If Self:lCriaDisp .And. (nTamDisp == 0 .Or. ((dData >  Self:oDispRecur[cRecurso][nTamDisp][ARRAY_DISP_RECURSO_DATA]) .Or. ;
	                                             (dData == Self:oDispRecur[cRecurso][nTamDisp][ARRAY_DISP_RECURSO_DATA]  .And.;
	                                              nHora >= Self:oDispRecur[cRecurso][nTamDisp][ARRAY_DISP_RECURSO_HORA_FIM]) ))

		If Self:criaDisponibilidadeRecurso(cRecurso, Self:nTempoOper, dData)
			lCriouDisp := .T.
			nTamDisp   := Len(Self:oDispRecur[cRecurso])
		EndIf
	EndIf

	oIndices   := Self:getJsonIndicesRecurso(cRecurso)
	lDataExist := oIndices:hasProperty(cData) .And. oIndices[cData][ARRAY_INDICE_DISP_DISPONIVEL] .And.;
	              ((Self:lDecresce .And. nHora > oIndices[cData][ARRAY_INDICE_DISP_HORA_INICIAL]) .Or.;
	              (!Self:lDecresce .And. nHora < oIndices[cData][ARRAY_INDICE_DISP_HORA_FINAL  ]))

	If !lDataExist

		If Self:lDecresce
			dFim := Self:oParTempo["dataInicial"]

		Else
			dFim := Self:oParTempo["dataFinal"]

			If lDispAdc
				_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

				dFim := oDisp:buscaDataUltimaDisponibilidadeRecurso(cRecurso)
			EndIf
		EndIf

		While !lDataExist .And. ((!Self:lDecresce .And. dData <= dFim) .Or. (Self:lDecresce .And. dData >= dFim))
			If Self:lDecresce
				dData--
				nHora := __Hrs2Min("24:00")
			Else
				dData++
				nHora := __Hrs2Min("00:00")
			EndIf

			cData      := DToS(dData)
			lDataExist := oIndices:hasProperty(cData) .And. oIndices[cData][ARRAY_INDICE_DISP_DISPONIVEL] .And.;
			              ((Self:lDecresce .And. nHora > oIndices[cData][ARRAY_INDICE_DISP_HORA_INICIAL]) .Or.;
			              (!Self:lDecresce .And. nHora < oIndices[cData][ARRAY_INDICE_DISP_HORA_FINAL  ]))
		End

		If !lDataExist .And. Self:lCriaDisp

			If Self:criaDisponibilidadeRecurso(cRecurso, Self:nTempoOper, dData)
				lCriouDisp := .T.

				Return Self:buscaIndiceDisponibilidade(cRecurso, dData, nHora, .T., @lCriouDisp)
			EndIf
		EndIf

		If !lDataExist
			Return nIndDisp
		EndIf
	EndIf

	If Self:lDecresce
		nInicio := oIndices[cData][ARRAY_INDICE_DISP_FINISH]
		nFim    := 1
		nStep   := -1
	Else
		nInicio := oIndices[cData][ARRAY_INDICE_DISP_START]
		nFim    := nTamDisp
		nStep   := 1
	EndIf

	For nIndDisp := nInicio To nFim Step nStep
		aDispRec := Self:oDispRecur[cRecurso][nIndDisp]

		If !Self:disponibilidadeDisponivel(aDispRec)
			Loop
		EndIf

		If Self:lDecresce
			If aDispRec[ARRAY_DISP_RECURSO_DATA] == dData .And. aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO] >= nHora
				Loop
			EndIf
		Else
			If aDispRec[ARRAY_DISP_RECURSO_DATA] == dData .And. aDispRec[ARRAY_DISP_RECURSO_HORA_FIM] <= nHora
				Loop
			EndIf
		EndIf

		Exit
	Next

Return nIndDisp

/*/{Protheus.doc} disponibilidadeDisponivel
Verifica se uma disponibilidade está disponivel para alocação.
@author Lucas Fagundes
@since 23/04/2024
@version P12
@param aDisp   , Array   , Array com as informações da disponibilidade.
@param nIndDisp, Numérico, Posição do array com a disponibilidade do recurso.
@return lDispon, Lógico, Indica se a disponibilidade está disponivel para alocação.
/*/
Method disponibilidadeDisponivel(aDisp, nIndDisp) Class PCPA152TempoOperacao
	Local lDispon := .T.

	If aDisp[ARRAY_DISP_RECURSO_TEMPO] == 0
		lDispon := .F.
	EndIf

	If aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA
		lDispon := .F.
	EndIf

	If lDispon .And. nIndDisp != Nil .And. !Empty(Self:aIntervalo)
		If nIndDisp > Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP] .And. nIndDisp < Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP]
			lDispon := Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
		EndIf
	EndIf

	If aDisp[ARRAY_DISP_RECURSO_ILIMITADO]
		lDispon := .T.
	EndIf

Return lDispon

/*/{Protheus.doc} consomeDisponibilidade
Consome a disponibilidade de um recurso gerando os periodos de alocação de uma operação.
@author Lucas Fagundes
@since 09/01/2024
@version P12
@param 01 aOperacao , Array   , Array com as informações da operação.
@param 02 nIndDisp  , Numérico, Posição do array com a disponibilidade do recurso.
@param 03 nTempo    , Numerico, Tempo que irá consumir do recurso. Retorna por referência o tempo após o consumo.
@param 04 nHora     , Numerico, Hora inicial do consumo.
@param 06 aPeriodos , Array   , Array que irá adicionar os periodos criados no consumo.
@parma 05 dDataStart, Date    , Data inicial da alocação atual.
@parma 06 nHoraStart, Numérico, Hora inicial da alocação atual.
@param 07 lSetup    , Lógico  , Retorna por referência se deve adicionar o setup no fim das alocações.
@param 08 cRecurso  , Caracter, Recurso que está alocando a operação.
@return Nil
/*/
Method consomeDisponibilidade(aOperacao, nIndDisp, nTempo, nHora, aPeriodos, dDataStart, nHoraStart, lSetup, cRecurso) Class PCPA152TempoOperacao
	Local aBkpTempo := {}
	Local aDisp     := {}
	Local aInsere   := {}
	Local aPeriodo  := {}
	Local aTempo    := {}
	Local aTempos   := 0
	Local lAlocou   := .F.
	Local lQuebrou  := .F.
	Local nFim      := 0
	Local nHoraAux  := 0
	Local nHoraFim  := 0
	Local nHoraIni  := 0
	Local nIndex    := 0
	Local nInicio   := 1
	Local nStep     := 1
	Local nTempoAux := 0

	aDisp   := Self:oDispRecur[cRecurso][nIndDisp]
	aTempos := aDisp[ARRAY_DISP_RECURSO_DISPONIBILIDADE]

	If aDisp[ARRAY_DISP_RECURSO_ILIMITADO]
		aBkpTempo := aClone(aDisp[ARRAY_DISP_RECURSO_DISPONIBILIDADE])
		aSize(aTempos, 1)
	EndIf

	If Self:ajustaArrayDeTempos(@aTempos)
		lQuebrou        := .T.
		Self:aIntervalo := {}
	EndIf
	nFim := Len(aTempos)

	If Self:lDecresce
		nInicio := nFim
		nFim    := 1
		nStep   := -1
	EndIf

	For nIndex := nInicio To nFim Step nStep
		aTempo    := aTempos[nIndex]
		nTempoAux := nTempo
		nHoraAux  := nHora

		If !Self:tempoValido(aTempo, nHora)
			Loop
		EndIf

		Self:carregaIntervaloAlocacao(cRecurso, nIndDisp, nIndex, nHoraAux, aOperacao)

		Self:validaSetup(aOperacao, nIndDisp, nIndex, nTempoAux, nHora, cRecurso)
		If !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " nao foi alocada no periodo de " + ;
				                                     __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.) + ;
				                                     " do dia " + DToC(aTempos[nIndex][ARRAY_DISPONIBILIDADE_DATA]) + ", pois nao e possivel alocar completamente o tempo de setup."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf

			Loop
		EndIf

		If Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]
			nTempoAux += aOperacao[ARRAY_MF_SETUP]
		EndIf

		Self:validaFinalizacao(aOperacao, nTempoAux, cRecurso)
		If !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " nao foi alocada no periodo de " + ;
				                                     __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.) + ;
				                                     " do dia " + DToC(aTempos[nIndex][ARRAY_DISPONIBILIDADE_DATA]) + ", pois nao e possivel alocar completamente o tempo de finalizacao."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf

			Loop
		EndIf

		Self:validaQuebras(nTempoAux)
		If !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " nao foi alocada no periodo de " + ;
				                                     __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.) + ;
				                                     " do dia " + DToC(aTempos[nIndex][ARRAY_DISPONIBILIDADE_DATA]) + ", pois nao e possivel alocar completamente a operacao."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf

			Loop
		EndIf

		Self:validaFerramentas(aOperacao, nTempoAux, cRecurso, nIndDisp, nIndex, aTempo[ARRAY_DISPONIBILIDADE_DATA], @nHoraAux)
		If !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			If Self:oLogs:logAtivo()
				Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " nao foi alocada no periodo de " + ;
				                                     __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aTempos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM], .T.) + ;
				                                     " do dia " + DToC(aTempos[nIndex][ARRAY_DISPONIBILIDADE_DATA]) + ", devido a disponibilidade das ferramentas."},;
				                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			EndIf

			Loop
		EndIf

		Self:validaOperacaoPosterior(aOperacao, nTempoAux, aTempo, cRecurso)
		If !Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			Loop
		EndIf

		nTempo := nTempoAux
		lSetup := Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] .Or. lSetup

		If nHora != nHoraAux
			nHora := nHoraAux

			If !Self:tempoValido(aTempo, nHora)
				Loop
			EndIf
		EndIf

		If Self:lDecresce

			// Periodo termina após a hora de consumo.
			If aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] > nHora
				nHoraFim := nHora

				aAdd(aInsere, Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA]    ,;
				                                              nHoraFim                              ,;
				                                              aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM],;
				                                              cRecurso                              ,;
				                                              nIndDisp                              ))

				// Tempo de consumo maior ou igual ao intervalo de consumo. Realiza o consumo do inicio do periodo.
				//        |  PERIODO    |
				//     <- CONSUMO |
				If nTempo >= (nHoraFim - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO])
					nHoraIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

					aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM        ] := nHoraFim
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO           ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
					aTempo[ARRAY_DISPONIBILIDADE_TIPO            ] := VM_TIPO_PRODUCAO
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := aOperacao[ARRAY_MF_ID]
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := aOperacao[ARRAY_MF_OP]
					aPeriodo := aTempo

				// Tempo de consumo dentro do periodo. Consome apenas o tempo necessario.
				//      |     PERIODO     |
				//         | CONSUMO |
				Else
					nHoraIni := nHoraFim - nTempo

					aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM        ] := nHoraIni
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO           ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
					aTempo[ARRAY_DISPONIBILIDADE_TIPO            ] := VM_TIPO_DISPONIVEL
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := ""
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := ""

					aPeriodo := Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA],;
					                                            nHoraIni                          ,;
					                                            nHoraFim                          ,;
					                                            cRecurso                          ,;
					                                            nIndDisp                          ,;
					                                            aOperacao[ARRAY_MF_ID]            ,;
					                                            aOperacao[ARRAY_MF_OP]            )

					aAdd(aInsere, aPeriodo)
				EndIf

			// Periodo acaba antes ou na hora de inicio do consumo. Consome o tempo necessário.
			//       |    PERIODO    |
			//                       <- CONSUMO   |
			Else
				nHoraFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM]

				// Tempo de consumo abrange todo o periodo. Consome o periodo inteiro.
				If nTempo >= aTempo[ARRAY_DISPONIBILIDADE_TEMPO]
					nHoraIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

					aTempo[ARRAY_DISPONIBILIDADE_TIPO            ] := VM_TIPO_PRODUCAO
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := aOperacao[ARRAY_MF_ID]
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := aOperacao[ARRAY_MF_OP]

					aPeriodo := aTempo
				// Periodo maior que o tempo de consumo. Consome apenas o tempo necessario.
				Else
					nHoraIni := nHoraFim - nTempo

					aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] := nHoraIni
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO   ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

					aPeriodo := Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA],;
					                                            nHoraIni                          ,;
					                                            nHoraFim                          ,;
					                                            cRecurso                          ,;
					                                            nIndDisp                          ,;
					                                            aOperacao[ARRAY_MF_ID]            ,;
					                                            aOperacao[ARRAY_MF_OP]            )

					aAdd(aInsere, aPeriodo)
				EndIf
			EndIf

		Else

			// Periodo inicia antes da hora de consumo e termina após. Consome a partir da hora de consumo.
			If aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO] < nHora
				nHoraIni := nHora

				// Tempo de consumo maior ou igual ao intervalo de consumo. Realiza o consumo até o fim do periodo.
				//   |  PERIODO  |
				//          | CONSUMO ->
				If nTempo >= (aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - nHoraIni)
					nHoraFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM]

					aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] := nHoraIni
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO   ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

				// Tempo de consumo dentro do periodo. Consome apenas o tempo necessario.
				//      |    PERIODO    |
				//         | CONSUMO |
				Else
					nHoraFim := nHoraIni + nTempo

					aAdd(aInsere, Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA]    ,;
					                                              nHoraFim                              ,;
					                                              aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM],;
					                                              cRecurso                              ,;
					                                              nIndDisp                              ))

					aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] := nHoraIni
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO   ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				EndIf

				aPeriodo := Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA],;
				                                            nHoraIni                          ,;
				                                            nHoraFim                          ,;
				                                            cRecurso                          ,;
				                                            nIndDisp                          ,;
				                                            aOperacao[ARRAY_MF_ID]            ,;
				                                            aOperacao[ARRAY_MF_OP]            )

				aAdd(aInsere, aPeriodo)
			// Periodo inicia depois ou na hora de inicio do consumo. Consome o tempo necessário a partir do inicio do periodo.
			//       |    PERIODO    |
			//    | CONSUMO ->
			Else
				nHoraIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

				// Tempo de consumo abrange todo o periodo. Consome o periodo inteiro.
				If nTempo >= aTempo[ARRAY_DISPONIBILIDADE_TEMPO]
					nHoraFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM]

					aTempo[ARRAY_DISPONIBILIDADE_TIPO            ] := VM_TIPO_PRODUCAO
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := aOperacao[ARRAY_MF_ID]
					aTempo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := aOperacao[ARRAY_MF_OP]

					aPeriodo := aTempo
				// Periodo maior que o tempo de consumo. Consome apenas o tempo necessario.
				Else
					nHoraFim := nHoraIni + nTempo

					aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO] := nHoraFim
					aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ] := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

					aPeriodo := Self:criaPeriodoDisponibilidade(aTempo[ARRAY_DISPONIBILIDADE_DATA],;
					                                            nHoraIni                          ,;
					                                            nHoraFim                          ,;
					                                            cRecurso                          ,;
					                                            nIndDisp                          ,;
					                                            aOperacao[ARRAY_MF_ID]            ,;
					                                            aOperacao[ARRAY_MF_OP]            )

					aAdd(aInsere, aPeriodo)
				EndIf

			EndIf

		EndIf

		lAlocou := .T.
		nHora   := Iif(Self:lDecresce, aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO], aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM])
		nTempo  -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]

		If !aDisp[ARRAY_DISP_RECURSO_ILIMITADO]
			aDisp[ARRAY_DISP_RECURSO_TEMPO] -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]
		EndIf

		aAdd(aPeriodos, aPeriodo)
		aAdd(aBkpTempo, aPeriodo)

		If nTempo == 0
			Exit
		EndIf
	Next

	If aDisp[ARRAY_DISP_RECURSO_ILIMITADO]
		aDisp[ARRAY_DISP_RECURSO_DISPONIBILIDADE] := aBkpTempo

	Else
		nFim := Len(aInsere)

		If nFim > 0
			For nIndex := 1 To nFim
				aAdd(aTempos, aInsere[nIndex])
			Next

			Self:ordenaTempos(@aTempos)

			aSize(aInsere, 0)
		EndIf

		If lQuebrou
			Self:unePeriodosDisponiveis(aTempos)
		EndIf
	EndIf

	If lAlocou
		Self:addIndiceAlocado(cRecurso, nIndDisp)
	EndIf

	Self:atualizaIndiceDisponibilidade(cRecurso, aDisp[ARRAY_DISP_RECURSO_DATA])

Return Nil

/*/{Protheus.doc} ordenaTempos
Ordena o array de tempos.
@author Lucas Fagundes
@since 18/03/2024
@version P12
@param aTempos, Array, Array que será ordenado.
@return Nil (retorna o array ordenado por referência).
/*/
Method ordenaTempos(aTempos) Class PCPA152TempoOperacao

	aSort(aTempos,,,{|x, y| x[ARRAY_DISPONIBILIDADE_HORA_INICIO] < y[ARRAY_DISPONIBILIDADE_HORA_INICIO]})

Return Nil

/*/{Protheus.doc} atualizaIndiceDisponibilidade
Percorre os periodos de uma data para verificar se ainda tem disponibilidade no dia.
@author Lucas Fagundes
@since 10/01/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que irá atualizar o indice.
@param 02 dData   , Date    , Data que irá atualizar o indice.
@return Nil
/*/
Method atualizaIndiceDisponibilidade(cRecurso, dData) Class PCPA152TempoOperacao
	Local cData     := DToS(dData)
	Local nFinish   := 0
	Local nIndice   := 0
	Local nStart    := 0
	Local nUltimo   := 0
	Local nPrimeiro := 0
	Local nHoraIni  := 0
	Local nHoraFim  := 0
	Local oIndices  := Self:getJsonIndicesRecurso(cRecurso)

	nStart  := oIndices[cData][ARRAY_INDICE_DISP_START ]
	nFinish := oIndices[cData][ARRAY_INDICE_DISP_FINISH]

	oIndices[cData][ARRAY_INDICE_DISP_DISPONIVEL] := .F.

	For nIndice := nStart To nFinish
		If Self:oDispRecur[cRecurso][nIndice][ARRAY_DISP_RECURSO_TEMPO] == 0
			Loop
		EndIf
		oIndices[cData][ARRAY_INDICE_DISP_DISPONIVEL] := .T.

		If nPrimeiro == 0
			nPrimeiro := nIndice
		EndIf

		nUltimo := nIndice
	Next

	If oIndices[cData][ARRAY_INDICE_DISP_DISPONIVEL]
		nHoraIni := Self:oDispRecur[cRecurso][nPrimeiro][ARRAY_DISP_RECURSO_HORA_INICIO]
		nHoraFim := Self:oDispRecur[cRecurso][nUltimo][ARRAY_DISP_RECURSO_HORA_FIM]

		If !Empty(Self:oDispRecur[cRecurso][nPrimeiro][ARRAY_DISP_RECURSO_DISPONIBILIDADE]) .And. !Self:oDispRecur[cRecurso][nPrimeiro][ARRAY_DISP_RECURSO_ILIMITADO]
			nHoraIni := Self:oDispRecur[cRecurso][nPrimeiro][ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_HORA_INICIO]
		EndIf

		If !Empty(Self:oDispRecur[cRecurso][nUltimo][ARRAY_DISP_RECURSO_DISPONIBILIDADE]) .And. !Self:oDispRecur[cRecurso][nUltimo][ARRAY_DISP_RECURSO_ILIMITADO]
			nHoraFim := aTail(Self:oDispRecur[cRecurso][nUltimo][ARRAY_DISP_RECURSO_DISPONIBILIDADE])[ARRAY_DISPONIBILIDADE_HORA_FIM]
		EndIf

		oIndices[cData][ARRAY_INDICE_DISP_START       ] := nPrimeiro
		oIndices[cData][ARRAY_INDICE_DISP_FINISH      ] := nUltimo
		oIndices[cData][ARRAY_INDICE_DISP_HORA_INICIAL] := nHoraIni
		oIndices[cData][ARRAY_INDICE_DISP_HORA_FINAL  ] := nHoraFim
	Else
		oIndices[cData][ARRAY_INDICE_DISP_START ] := 0
		oIndices[cData][ARRAY_INDICE_DISP_FINISH] := 0
	EndIf

Return Nil

/*/{Protheus.doc} getDataInicioOperacao
Retorna a data e hora de inicio de uma operação.
@author Lucas Fagundes
@since 17/04/2023
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 dData    , Date    , Retorna por referencia a data de inicio da operação.
@param 03 nHora    , Numerico, Retorna por referencia a hora de inicio da operação.
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
Method getDataInicioOperacao(aOperacao, lEntrega, cRecurso) Class PCPA152TempoOperacao
	Local aPerUltOpe := {}
	Local aRet       := Array(RET_GET_DATA_TAMANHO)
	Local dData      := Nil
	Local dIniProg   := Self:oParTempo["dataInicial"]
	Local nHora      := 0

	If Self:oParTempo["priorizacao"] == PARAM_PRIORIZACAO_DATA_INICIO
		If Self:nUltOperDi > 0
			aPerUltOpe := Self:aAlocados[Self:nUltOperDi][ALOCADOS_POS_PERIODOS]

			dData := aTail(aPerUltOpe)[ARRAY_DISPONIBILIDADE_DATA]
			nHora := aTail(aPerUltOpe)[ARRAY_DISPONIBILIDADE_HORA_FIM]
		Else
			dData := aOperacao[ARRAY_MF_DTINI]
			nHora := __Hrs2Min("00:00")

			If Self:oParTempo["ordensAtrasadas"] .And. dData < dIniProg
				dData := dIniProg
			EndIf
		EndIf

	Else
		If Self:nUltOperDi > 0
			aPerUltOpe := Self:aAlocados[Self:nUltOperDi][ALOCADOS_POS_PERIODOS]

			dData := aPerUltOpe[1][ARRAY_DISPONIBILIDADE_DATA]
			nHora := aPerUltOpe[1][ARRAY_DISPONIBILIDADE_HORA_INICIO]
		Else
			dData := aOperacao[ARRAY_MF_DTENT]
			nHora := __Hrs2Min("24:00")

			If Self:oParTempo["ordensAtrasadas"] .And. dData < dIniProg
				dData := dIniProg
			EndIf
		EndIf
	EndIf

	aRet[RET_GET_DATA_DATA] := dData
	aRet[RET_GET_DATA_HORA] := nHora

	aRet[RET_GET_DATA_SOBREPOE] := .F.
	If Self:alocaComSobreposicao(aOperacao, lEntrega, cRecurso)
		Self:getDataSobreposicao(aOperacao, Self:aAlocados[Self:nUltOperDi], lEntrega, cRecurso, @aRet)
	EndIf

Return aRet

/*/{Protheus.doc} criaPeriodoDisponibilidade
Realiza a criação de um array com o periodo de uma operação.
@author Lucas Fagundes
@since 04/05/2023
@version P12
@param 01 dData    , Date    , Data do periodo.
@param 02 nHoraIni , Numerico, Hora inicial do periodo.
@param 03 nHoraFim , Numerico, Hora final do periodo.
@param 04 cRecurso , Caracter, Código do recurso.
@param 05 nIndDisp , Numérico, Indice da disponibilidade.
@param 06 cIdOper  , Caracter, Id da operação que aloca no periodo.
@param 07 cOperOP  , Caracter, Ordem da operação que aloca no periodo.
@return aPeriodo, Array, Array de periodo de uma operação.
/*/
Method criaPeriodoDisponibilidade(dData, nHoraIni, nHoraFim, cRecurso, nIndDisp, cIdOper, cOperOP) Class PCPA152TempoOperacao
	Local aPeriodo := Array(ARRAY_DISPONIBILIDADE_TAMANHO)
	Default cIdOper := ""
	Default cOperOP := ""

	aPeriodo[ARRAY_DISPONIBILIDADE_RECURSO               ] := cRecurso
	aPeriodo[ARRAY_DISPONIBILIDADE_DATA                  ] := dData
	aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO           ] := nHoraIni
	aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM              ] := nHoraFim
	aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO                 ] := nHoraFim - nHoraIni
	aPeriodo[ARRAY_DISPONIBILIDADE_TIPO                  ] := VM_TIPO_DISPONIVEL
	aPeriodo[ARRAY_DISPONIBILIDADE_INDICE_DISP           ] := nIndDisp
	aPeriodo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := cIdOper
	aPeriodo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := cOperOP
	aPeriodo[ARRAY_DISPONIBILIDADE_INFOSMK               ] := Array(ARRAY_INFOSMK_TAMANHO)
	aPeriodo[ARRAY_DISPONIBILIDADE_FERRAMENTA_DISPONIVEL ] := .T.

	If nIndDisp > 0
		aPeriodo[ARRAY_DISPONIBILIDADE_INFOSMK] := Self:oDispRecur[cRecurso][nIndDisp][ARRAY_DISP_RECURSO_INFOSMK]
	EndIf

	If !Empty(cIdOper)
		aPeriodo[ARRAY_DISPONIBILIDADE_TIPO] := VM_TIPO_PRODUCAO
	EndIf

Return aPeriodo

/*/{Protheus.doc} calculaPrioridade
Faz a priorização de todas as Ordens de produção
@author Marcelo Neumann
@since 27/06/2023
@version P12
@return lSucesso, Logico, Indica se concluiu o processamento com sucesso.
/*/
Method calculaPrioridade() Class PCPA152TempoOperacao
	Local aOperacoes := {}
	Local aOPsPais   := {}
	Local cArvoreId  := ""
	Local cChave     := ""
	Local lSucesso   := .T.
	Local lTemFilhos := .F.
	Local nIndex     := 1
	Local nIndOper   := 1
	Local nIndOrdem  := 1
	Local nPrioridad := 0
	Local nTamCampo  := GetSx3Cache("MF_PRIOR", "X3_TAMANHO")
	Local nTotal     := 0
	Local nTotOper   := 0
	Local nTotOps    := 0
	Local oOPsPais   := JsonObject():New()
	Local oOPsFilhas := JsonObject():New()

	oOPsPais:fromJson(_Super:retornaValorGlobal("JSON_OPS_PAIS"))
	oOPsFilhas:fromJson(_Super:retornaValorGlobal("JSON_OPS_FILHAS"))

	aOPsPais := oOPsPais:getNames()
	nTotal   := Len(aOPsPais)

	_Super:gravaValorGlobal("TOTAL_PRIORIZACAO", nTotal)
	_Super:gravaValorGlobal("OPERS_PRIORIZADAS", 0     )

	While nIndex <= nTotal .And. lSucesso
		cChave     := aOPsPais[nIndex]
		aOperacoes := Self:getOperacoesOrdem(cChave, .F.)
		cArvoreId  := aOperacoes[1][ARRAY_MF_ARVORE]
		lTemFilhos := oOPsFilhas:HasProperty(cArvoreId)
		nTotOper   := Len(aOperacoes)

		//Grava a prioridade nas operações
		For nIndOper := 1 To nTotOper
			aOperacoes[nIndOper][ARRAY_MF_PRIOR] := PadL((nPrioridad + aOperacoes[nIndOper][ARRAY_MF_PRIOR]), nTamCampo, "0")

			If !lTemFilhos
				aOperacoes[nIndOper][ARRAY_MF_ARVORE] := ""
			EndIf
		Next nIndOper
		nPrioridad += nTotOper

		_Super:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aOperacoes, .F.)
		aSize(aOperacoes, 0)

		//Grava a prioridade nas ordens filhas
		If lTemFilhos
			nTotOps := Len(oOPsFilhas[cArvoreId])

			For nIndOrdem := 1 To nTotOps
				cChave     := oOPsFilhas[cArvoreId][nIndOrdem]
				aOperacoes := Self:getOperacoesOrdem(cChave, .F.)
				nTotOper   := Len(aOperacoes)

				For nIndOper := 1 To nTotOper
					aOperacoes[nIndOper][ARRAY_MF_PRIOR] := PadL((nPrioridad + aOperacoes[nIndOper][ARRAY_MF_PRIOR]), 10, "0")
				Next nIndOper
				nPrioridad += nTotOper

				_Super:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aOperacoes, .F.)
				aSize(aOperacoes, 0)

				If !_Super:permiteProsseguir()
					lSucesso := .F.
					Exit
				EndIf
			Next nIndOrdem
		EndIf

		If lSucesso
			_Super:gravaValorGlobal("OPERS_PRIORIZADAS", 1, .T., .T.)
			Self:atualizaPercentual(CHAR_ETAPAS_PRIO_ORDEM)

			nIndex++
			lSucesso := _Super:permiteProsseguir()
		EndIf
	End

	aSize(aOPsPais, 0)
	FwFreeObj(oOPsFilhas)
	FreeObj(oOPsPais)
Return lSucesso

/*/{Protheus.doc} carregaDisponibilidadeRecurso
Carrega a disponibilidade de um recurso.
@author Lucas Fagundes
@since 11/08/2023
@version P12
@param cRecurso, Caracter, Código do recurso que irá carregar a disponibilidade
@return Nil
/*/
Method carregaDisponibilidadeRecurso(cRecurso) Class PCPA152TempoOperacao
	Local oDisp := Nil

	If !Self:oDispRecur:hasProperty(cRecurso)
		_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
		Self:oDispRecur[cRecurso] := oDisp:getDisponibilidadeRecurso(cRecurso, .F.)
	EndIf

Return Nil

/*/{Protheus.doc} gravaPeriodosOperacao
Efetiva as alocações dos períodos gerados pelo método getPeriodosOperacao(), salvando os dados em memória global.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 aPeriodos, Array   , Array com os tempos da operação.
@param 03 cRecurso , Caracter, Recurso que será alocado a operação.
@param 04 nTempoSob, Numerico, Tempo de sobreposição da operação.
@return Nil
/*/
Method gravaPeriodosOperacao(aOperacao, aPeriodos, cRecurso, nTempoSob) Class PCPA152TempoOperacao
	Local aGlobal  := {}
	Local cChave   := ""
	Local dUltAloc := _Super:retornaValorGlobal("ULTIMA_DATA_ALOCADA")
	Default cRecurso := aOperacao[ARRAY_MF_RECURSO]

	Self:atualizaOperacao(aOperacao, cRecurso, nTempoSob)

	cChave := Self:chaveListaDadosSVM(aOperacao)

	aGlobal := Self:geraPeriodosOperacao(aOperacao, aPeriodos, @dUltAloc)

	_Super:adicionaListaGlobal(LISTA_DADOS_SVM, cChave, aGlobal, .T., 2)
	_Super:gravaValorGlobal("ULTIMA_DATA_ALOCADA", dUltAloc)

	aSize(aGlobal, 0)
Return

/*/{Protheus.doc} atualizaOperacao
Atualiza a operação com as informações da alocação.

@author Lucas Fagundes
@since 19/09/2024
@version P12
@param aOperacao, Array   , Array com as informações da operação
@param cRecurso , Caracter, Recurso que alocou a operação.
@param nTempoSob, Numerico, Tempo de sobreposição da operação.
@return Nil
/*/
Method atualizaOperacao(aOperacao, cRecurso, nTempoSob) Class PCPA152TempoOperacao
	Local aGlobal := {}
	Local nPosRec  := 0
	Local nPosOper := 0
	Local cChave   := aOperacao[ARRAY_MF_OP]

	nPosRec := aScan(aOperacao[ARRAY_PROC_RECURSOS], {|rec| rec[ARRAY_HZ7_RECURS] == cRecurso})

	aOperacao[ARRAY_MF_RECURSO] := aOperacao[ARRAY_PROC_RECURSOS][nPosRec][ARRAY_HZ7_RECURS]
	aOperacao[ARRAY_MF_CTRAB  ] := aOperacao[ARRAY_PROC_RECURSOS][nPosRec][ARRAY_HZ7_CTRAB ]
	aOperacao[ARRAY_MF_TEMPO  ] := aOperacao[ARRAY_PROC_RECURSOS][nPosRec][ARRAY_HZ7_TEMPRE]
	aOperacao[ARRAY_MF_SOBREPO] := nTempoSob

	aGlobal  := _Super:retornaListaGlobal(LISTA_DADOS_SMF, cChave)
	nPosOper := aScan(aGlobal, {|aOperac| aOperac[ARRAY_MF_OPER] == aOperacao[ARRAY_MF_OPER]})

	aGlobal[nPosOper] := aOperacao

	_Super:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aGlobal, .F.)

	aSize(aGlobal, 0)
Return Nil

/*/{Protheus.doc} geraPeriodosOperacao
Cria o array de períodos da operação

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aOperacao, Array, Array com as informações da operação (SMF).
@param 02 aPeriodos, Array, Array com os tempos da operação.
@param 03 dUltAloc , Date , Retorna por referência a maior data de alocação.
@return aPerOper, Array, Array de períodos da operação
/*/
Method geraPeriodosOperacao(aOperacao, aPeriodos, dUltAloc) Class PCPA152TempoOperacao
	Local aItem    := {}
	Local aPerOper := {}
	Local cChaveId := ""
	Local cHoraFim := 0
	Local cHoraIni := 0
	Local dData    := Nil
	Local nIndex   := 0
	Local nTotal   := Len(aPeriodos)

	For nIndex := 1 To nTotal
		aItem    := Array(TAMANHO_ARRAY_VM)
		dData    := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_DATA]
		cHoraIni := __Min2Hrs(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.)
		cHoraFim := __Min2Hrs(aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM   ], .T.)
		cChaveId := aOperacao[ARRAY_MF_ID] + DToS(dData) + cHoraIni + cHoraFim

		aItem[ARRAY_VM_FILIAL ] := Self:cFilialSVM
		aItem[ARRAY_VM_PROG   ] := Self:cProg
		aItem[ARRAY_VM_ID     ] := aOperacao[ARRAY_MF_ID]
		aItem[ARRAY_VM_SEQ    ] := StrZero(nIndex, Self:nTamVMSEQ)
		aItem[ARRAY_VM_DATA   ] := dData
		aItem[ARRAY_VM_INICIO ] := cHoraIni
		aItem[ARRAY_VM_FIM    ] := cHoraFim
		aItem[ARRAY_VM_TEMPO  ] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TEMPO]
		aItem[ARRAY_VM_DISP   ] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_INFOSMK][ARRAY_INFOSMK_MK_ID ]
		aItem[ARRAY_VM_SEQDISP] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_INFOSMK][ARRAY_INFOSMK_MK_SEQ]
		aItem[ARRAY_VM_TIPO   ] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO]

		If dUltAloc == Nil .Or. aItem[ARRAY_VM_DATA] > dUltAloc
			dUltAloc := aItem[ARRAY_VM_DATA]
		EndIf

		Self:oSeqSVM[cChaveId] := aItem[ARRAY_VM_SEQ]

		aAdd(aPerOper, aItem)
	Next

Return aPerOper

/*/{Protheus.doc} carregaOperacoes
Carrega as operações em disco para memória global.
@author Lucas Fagundes
@since 17/08/2023
@version P12
@return Nil
/*/
Method carregaOperacoes() Class PCPA152TempoOperacao
	Local aDados    := {}
	Local aItem     := {}
	Local cAlias    := ""
	Local cQuery    := ""
	Local cChave    := ""
	Local nTamOPItm := GetSX3Cache("C2_NUM", "X3_TAMANHO") + GetSX3Cache("C2_ITEM", "X3_TAMANHO") + 1
	Local nTamOpSeq := GetSX3Cache("C2_SEQUEN", "X3_TAMANHO")
	Local nTempoIni := 0
	Local oCargaSMF := Nil

	cQuery := " SELECT SMF.MF_FILIAL,"
	cQuery +=        " SMF.MF_PROG,"
	cQuery +=        " SMF.MF_ID,"
	cQuery +=        " SMF.MF_PRIOR,"
	cQuery +=        " SMF.MF_OP,"
	cQuery +=        " SMF.MF_SALDO,"
	cQuery +=        " SMF.MF_ROTEIRO,"
	cQuery +=        " SMF.MF_OPER,"
	cQuery +=        " SMF.MF_RECURSO,"
	cQuery +=        " SMF.MF_TEMPO,"
	cQuery +=        " SMF.MF_CTRAB,"
	cQuery +=        " SMF.MF_ARVORE,"
	cQuery +=        " SMF.MF_SEQPAI,"
	cQuery +=        " SMF.MF_DTINI,"
	cQuery +=        " SMF.MF_DTENT,"
	cQuery +=        " SC2.C2_STATUS,"
	cQuery +=        " SC2.C2_PRODUTO,"
	cQuery +=        " SMF.MF_SETUP,"
	cQuery +=        " SMF.MF_TMPFINA"
	If Self:oParTempo["dicionarioAlternativo"]
		cQuery +=    " , SMF.MF_TPOPER"
	EndIf
	If Self:oParTempo["dicionarioSobreposicao"]
		cQuery +=    " , SMF.MF_TPSOBRE,"
		cQuery +=      " SMF.MF_TEMPSOB,"
		cQuery +=      " SMF.MF_SOBREPO"
	EndIf
	If Self:oParTempo["dicionarioTempoRemocao"]
		cQuery +=    " , SMF.MF_REMOCAO"
	EndIf
	If Self:oParTempo["dicionarioValidade"]
		cQuery +=    " , SMF.MF_VLDINI,"
		cQuery +=      " SMF.MF_VLDFIM"
	EndIf
	If Self:oParTempo["dicionarioFerramenta"]
		cQuery +=    " , SMF.MF_TPALOFE "
	EndIf
	cQuery +=  " FROM " + RetSqlName("SMF") + " SMF"
	cQuery += " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=    " ON SC2.C2_FILIAL  = ?"
	cQuery +=   " AND " + PCPQrySC2("SC2", "SMF.MF_OP") //Compara C2_NUM... com SMF.MF_OP
	cQuery +=   " AND SC2.D_E_L_E_T_ = ' '"
	cQuery += " WHERE SMF.MF_PROG    = ?"
	cQuery +=   " AND SMF.MF_FILIAL  = ?"
	cQuery +=   " AND SMF.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SMF.MF_OP, SMF.MF_OPER"

	If "MSSQL" $ Self:cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	oCargaSMF := FwExecStatement():New()
	oCargaSMF:setQuery(cQuery)

	oCargaSMF:setFields({"MF_FILIAL", "MF_PROG", "MF_ID", "MF_PRIOR", "MF_OP", "MF_SALDO",;
	                     "MF_ROTEIRO", "MF_OPER", "MF_RECURSO", "MF_TEMPO", "MF_CTRAB", "MF_ARVORE", "MF_SEQPAI",;
	                    {"MF_DTINI", "D", 8, 0}, {"MF_DTENT", "D", 8, 0}, "C2_STATUS" })

	oCargaSMF:setString(1, xFilial("SC2") ) // C2_FILIAL
	oCargaSMF:setString(2, Self:cProg     ) // MF_PROG
	oCargaSMF:setString(3, Self:cFilialSMF) // MF_FILIAL

	Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Query carregaOperacoes: " + cQuery, ;
	                                       " Parametros: " + xFilial("SC2") + " " + Self:cProg + " " + Self:cFilialSMF})
	nTempoIni := MicroSeconds()
	cAlias    := oCargaSMF:OpenAlias()
	Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Tempo query carregaOperacoes: " + cValToChar(MicroSeconds() - nTempoIni)})

	While (cAlias)->(!EoF())
		aItem  := Array(TAMANHO_ARRAY_PROC_MF)
		cChave := (cAlias)->MF_OP

		aItem[ARRAY_MF_FILIAL     ] := (cAlias)->MF_FILIAL
		aItem[ARRAY_MF_PROG       ] := (cAlias)->MF_PROG
		aItem[ARRAY_MF_ID         ] := (cAlias)->MF_ID
		aItem[ARRAY_MF_PRIOR      ] := (cAlias)->MF_PRIOR
		aItem[ARRAY_MF_OP         ] := (cAlias)->MF_OP
		aItem[ARRAY_MF_SALDO      ] := (cAlias)->MF_SALDO
		aItem[ARRAY_MF_ROTEIRO    ] := (cAlias)->MF_ROTEIRO
		aItem[ARRAY_MF_OPER       ] := (cAlias)->MF_OPER
		aItem[ARRAY_MF_RECURSO    ] := (cAlias)->MF_RECURSO
		aItem[ARRAY_MF_TEMPO      ] := (cAlias)->MF_TEMPO
		aItem[ARRAY_MF_DTINI      ] := (cAlias)->MF_DTINI
		aItem[ARRAY_MF_DTENT      ] := (cAlias)->MF_DTENT
		aItem[ARRAY_MF_CTRAB      ] := (cAlias)->MF_CTRAB
		aItem[ARRAY_MF_ARVORE     ] := Iif(Empty((cAlias)->MF_ARVORE), "", RTrim((cAlias)->MF_ARVORE))
		aItem[ARRAY_MF_SEQPAI     ] := (cAlias)->MF_SEQPAI
		aItem[ARRAY_PROC_STATUS_OP] := (cAlias)->C2_STATUS
		If Empty(aItem[ARRAY_MF_SEQPAI])
			aItem[ARRAY_PROC_OP_PAI] := ""
		Else
			aItem[ARRAY_PROC_OP_PAI] := Stuff(aItem[ARRAY_MF_OP], nTamOPItm, nTamOpSeq, aItem[ARRAY_MF_SEQPAI])
		EndIf
		aItem[ARRAY_MF_SETUP      ] := (cAlias)->MF_SETUP
		aItem[ARRAY_MF_TMPFINA    ] := (cAlias)->MF_TMPFINA
		aItem[ARRAY_PROC_PRODUTO  ] := (cAlias)->C2_PRODUTO
		If Self:oParTempo["dicionarioAlternativo"]
			aItem[ARRAY_MF_TPOPER] := (cAlias)->MF_TPOPER
		EndIf
		aItem[ARRAY_PROC_PRIMEIRA_OPERACAO] := .F.
		aItem[ARRAY_PROC_ULTIMA_OPERACAO  ] := .F.
		aItem[ARRAY_PROC_CHAVE_ARVORE     ] := Self:getChaveArvore(aItem)

		aItem[ARRAY_MF_TPSOBRE] := Nil
		aItem[ARRAY_MF_TEMPSOB] := 0
		aItem[ARRAY_MF_SOBREPO] := 0
		If Self:oParTempo["dicionarioSobreposicao"]
			aItem[ARRAY_MF_TPSOBRE] := (cAlias)->MF_TPSOBRE
			aItem[ARRAY_MF_TEMPSOB] := (cAlias)->MF_TEMPSOB

			If aItem[ARRAY_MF_TPSOBRE] == SOBREPOSICAO_POR_TEMPO
				aItem[ARRAY_MF_SOBREPO] := (cAlias)->MF_SOBREPO
			EndIf
		EndIf

		aItem[ARRAY_MF_REMOCAO] := 0
		If Self:oParTempo["dicionarioTempoRemocao"]
			aItem[ARRAY_MF_REMOCAO] := (cAlias)->MF_REMOCAO
		EndIf

		If Self:oParTempo["dicionarioValidade"]
			aItem[ARRAY_MF_VLDINI] := SToD((cAlias)->MF_VLDINI)
			aItem[ARRAY_MF_VLDFIM] := SToD((cAlias)->MF_VLDFIM)
		EndIf

		aItem[ARRAY_PROC_USA_ALTERNATIVOS ] := .F.
		aItem[ARRAY_PROC_RECURSOS         ] := {}
		Self:carregaRecursosOperacao(@aItem)

		aItem[ARRAY_PROC_FERRAMENTAS] := {}
		If Self:oParTempo["dicionarioFerramenta"]
			aItem[ARRAY_PROC_FERRAMENTAS] := Self:oFerramentas:carregaFerramentasOperacao(aItem[ARRAY_MF_ID])
			aItem[ARRAY_MF_TPALOFE      ] := (cAlias)->MF_TPALOFE
		EndIf

		Self:insereTempTable(aItem)

		aAdd(aDados, aItem)

		Self:oRecsAloc[(cAlias)->MF_RECURSO] := .T.

		(cAlias)->(dbSkip())

		If (cAlias)->MF_OP != cChave
			aDados[1][ARRAY_PROC_PRIMEIRA_OPERACAO  ] := .T.
			aTail(aDados)[ARRAY_PROC_ULTIMA_OPERACAO] := .T.

			_Super:adicionaListaGlobal(LISTA_DADOS_SMF, cChave, aDados, .T., 2)
			aSize(aDados, 0)
		EndIf
	End
	(cAlias)->(dbCloseArea())

	Self:oFerramentas:finalizaCargaFerramentas(.T.)
	Self:finalizaCargaTemp()

	_Super:gravaValorGlobal("JSON_RECURSOS_ALOCACAO", Self:oRecsAloc:toJson())
	Self:oRecsAloc := JsonObject():New()

	FwFreeArray(aDados)
	oCargaSMF:destroy()
Return Nil

/*/{Protheus.doc} getOperacoesOrdem
Retorna as operações de uma ordem de produção.
@author Lucas Fagundes
@since 18/08/2023
@version P12
@param 01 cOrdem , Caracter, Número da ordem de produção
@param 02 lOrdena, Logic   , Indica se deve ordenar o array por código da operação
@return aOperacoes, Array, Operações da ordem de produção
/*/
Method getOperacoesOrdem(cOrdem, lOrdena) Class PCPA152TempoOperacao
	Local aOperacoes := _Super:retornaListaGlobal(LISTA_DADOS_SMF, cOrdem)

	If lOrdena .And. !Empty(cOrdem)
		aSort(aOperacoes,,,{|x, y| x[ARRAY_MF_OPER] < y[ARRAY_MF_OPER]})
	EndIf
Return aOperacoes

/*/{Protheus.doc} getChaveArvore
Retorna a chave de uma árvore.
@author Lucas Fagundes
@since 05/10/2023
@version P12
@param aOperacao, Array, Array com as informações da árvore.
@return cChave, Caracter, Chave da árvore para busca
/*/
Method getChaveArvore(aOperacao) Class PCPA152TempoOperacao
	Local cChave := ""

	If Empty(aOperacao[ARRAY_MF_ARVORE])
		cChave += "_" + aOperacao[ARRAY_MF_OP]
	Else
		cChave += aOperacao[ARRAY_MF_ARVORE] + "_"
	EndIf

Return cChave

/*/{Protheus.doc} validaDatasOp
Verifica se a data de início e/ou a data de entrega da OP foram alteradas.
@author Marcelo Neumann
@since 12/10/2023
@version P12
@param 01 aOperacao , Array, Array com as informações da operação.
@param 02 dNovaDtIni, Date , Data de início da Ordem de Produção após o nivelamento.
@param 03 dNovaDtEnt, Date , Data de entrega da Ordem de Produção após o nivelamento.
@return Nil
/*/
Method validaDatasOp(aOperacao, dNovaDtIni, dNovaDtEnt) Class PCPA152TempoOperacao

	If dNovaDtIni != Nil .And. aOperacao[ARRAY_MF_DTINI] <> dNovaDtIni
		Self:oOcorrens:adicionaOcorrencia(LOG_DATA_INICIO_ALTERADA              ,;
		                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE]    ,;
		                                  aOperacao[ARRAY_MF_ID]                ,;
		                                  aOperacao[ARRAY_MF_OP]                ,;
		                                  "", "", "", ""                        ,;
		                                  {aOperacao[ARRAY_MF_DTINI], dNovaDtIni})
	EndIf

	If dNovaDtEnt != Nil .And. aOperacao[ARRAY_MF_DTENT] <> dNovaDtEnt
		Self:oOcorrens:adicionaOcorrencia(LOG_DATA_ENTREGA_ALTERADA             ,;
		                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE]    ,;
		                                  aOperacao[ARRAY_MF_ID]                ,;
		                                  aOperacao[ARRAY_MF_OP]                ,;
		                                  "", "", "", ""                        ,;
		                                  {aOperacao[ARRAY_MF_DTENT], dNovaDtEnt})
	EndIf

Return Nil

/*/{Protheus.doc} criaDisponibilidadeRecurso
Cria disponibilidade adicional para o recurso atender a operação que esta sendo alocada.
@author Lucas Fagundes
@since 18/12/2023
@version P12
@param 01 cRecurso , Caracter, Código do recurso que irá gerar a disponibilidade.
@param 02 nTempoNec, Numerico, Tempo necessario para finalizar a operação (em minutos).
@param 03 dData    , Date    , Data que irá iniciar a alocação.
@return lCriou, Logico, Indica se conseguiu criar a disponibilidade para o recurso.
/*/
Method criaDisponibilidadeRecurso(cRecurso, nTempoNec, dData) Class PCPA152TempoOperacao
	Local lCriou   := .F.
	Local oDisp    := Nil
	Local oInfoAdc := JsonObject():New()
	Local oInfoRec := Nil

	If Self:lBkpDisp
		//Caso não tenha criado ainda BKP da disponibilidade do recurso,
		//faz a criação agora para evitar lixo no array de disponibilidade
		//caso a alocação não seja realizada
		Self:gravaBackupDisponibilidades(cRecurso, 0)
	EndIf

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
	oInfoRec := oDisp:getInfoRecurso(cRecurso)

	oInfoAdc["dataAlocacao"   ] := dData
	oInfoAdc["tempoAlocacao"  ] := nTempoNec
	oInfoAdc["criouDisp"      ] := .F.
	oInfoAdc["indices"        ] := Self:getJsonIndicesRecurso(cRecurso)
	oInfoAdc["disponibilidade"] := Self:oDispRecur[cRecurso]
	oInfoAdc["alocacoes"      ] := Self:getIndicesComAlocacao(cRecurso)

	oDisp:calculaDispRecurso(cRecurso, oInfoRec["H1_CALEND"], oInfoRec["H1_CCUSTO"], oInfoRec["H1_ILIMITA"], .T., @oInfoAdc)

	lCriou := oInfoAdc["criouDisp"]
	If lCriou
		Self:oDispRecur[cRecurso] := oInfoAdc["disponibilidade"]
		Self:setJsonIndicesRecurso(cRecurso, oInfoAdc["indices"  ])

		aSort(oInfoAdc["alocacoes"]["indices"],,,{|x, y| x < y})
		Self:setIndicesComAlocacao(cRecurso, oInfoAdc["alocacoes"])

		Self:oFerramentas:geraUtilizacaoAdicional(Self:aFerramentas, oInfoAdc["dataInicial"], oInfoAdc["dataFinal"])
	EndIf

Return lCriou

/*/{Protheus.doc} getJsonIndicesRecurso
Retorna o json com os indices da disponibilidade de um recurso.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param cRecurso, Caracter, Recurso que irá retornar o json.
@return oJson, Object, Json com os indices da disponibilidade do recurso.
/*/
Method getJsonIndicesRecurso(cRecurso) Class PCPA152TempoOperacao
	Local oJson := Nil
	Local oDisp := Nil

	If !Self:oIndcRecur:hasProperty(cRecurso) .And. _Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
		Self:oIndcRecur[cRecurso] := oDisp:getJsonIndicesDisponibilidadeAlocacao(cRecurso, .F.)
	EndIf
	oJson := Self:oIndcRecur[cRecurso]

Return oJson

/*/{Protheus.doc} setJsonIndicesRecurso
Atualiza o json de controle da disponibilidade de um recurso.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que irá atualizar o json.
@param 02 oJson   , Object  , Json atualizado.
@return Nil
/*/
Method setJsonIndicesRecurso(cRecurso, oJson) Class PCPA152TempoOperacao

	Self:oIndcRecur[cRecurso] := oJson

Return Nil

/*/{Protheus.doc} converteArrayProcessamentoParaGravacao
Retorna o array com os dados que serão gravados na tabela a partir do array de processamento.
@author Lucas Fagundes
@since 05/02/2024
@version P12
@param 01 cTabela, Caracter, Tabela que será gravada o array.
@param 02 aProc  , Array   , Array de processamento que será convertido.
@return aGrava, Array, Array no formato da tabela.
/*/
Method converteArrayProcessamentoParaGravacao(cTabela, aProc) Class PCPA152TempoOperacao
	Local aFields  := _oMapFields[cTabela]
	Local aGrava   := {}
	Local cCampo   := ""
	Local nIndex   := 0
	Local nPosProc := 0
	Local nTotal   := Len(aFields)

	For nIndex := 1 To nTotal
		cCampo   := aFields[nIndex][1]
		nPosProc := aFields[nIndex][2]

		If PCPA152Process():existeCampo(cCampo)
			aAdd(aGrava, aProc[nPosProc])
		EndIf
	Next

Return aGrava

/*/{Protheus.doc} iniFields
Inicia o map dos campos das tabelas e sua posição no array de processamento.
@type  Static Function
@author Lucas Fagundes
@since 02/04/2024
@version P12
@return Nil
/*/
Static Function iniFields()

	If _oMapFields == Nil
		_oMapFields := JsonObject():New()

		_oMapFields["SMF"] := {;
			{"MF_FILIAL" , ARRAY_MF_FILIAL  },;
			{"MF_PROG"   , ARRAY_MF_PROG    },;
			{"MF_ID"     , ARRAY_MF_ID      },;
			{"MF_PRIOR"  , ARRAY_MF_PRIOR   },;
			{"MF_OP"     , ARRAY_MF_OP      },;
			{"MF_SALDO"  , ARRAY_MF_SALDO   },;
			{"MF_ROTEIRO", ARRAY_MF_ROTEIRO },;
			{"MF_OPER"   , ARRAY_MF_OPER    },;
			{"MF_RECURSO", ARRAY_MF_RECURSO },;
			{"MF_TEMPO"  , ARRAY_MF_TEMPO   },;
			{"MF_DTINI"  , ARRAY_MF_DTINI   },;
			{"MF_DTENT"  , ARRAY_MF_DTENT   },;
			{"MF_CTRAB"  , ARRAY_MF_CTRAB   },;
			{"MF_ARVORE" , ARRAY_MF_ARVORE  },;
			{"MF_SEQPAI" , ARRAY_MF_SEQPAI  },;
			{"MF_SETUP"  , ARRAY_MF_SETUP   },;
			{"MF_TMPFINA", ARRAY_MF_TMPFINA },;
			{"MF_TPOPER" , ARRAY_MF_TPOPER  },;
			{"MF_TPSOBRE", ARRAY_MF_TPSOBRE },;
			{"MF_TEMPSOB", ARRAY_MF_TEMPSOB },;
			{"MF_SOBREPO", ARRAY_MF_SOBREPO },;
			{"MF_REMOCAO", ARRAY_MF_REMOCAO },;
			{"MF_VLDINI" , ARRAY_MF_VLDINI  },;
			{"MF_VLDFIM" , ARRAY_MF_VLDFIM  },;
			{"MF_TPALOFE", ARRAY_MF_TPALOFE };
		}

		_oMapFields["SVM"] := {;
			{"VM_FILIAL" , ARRAY_VM_FILIAL },;
			{"VM_PROG"   , ARRAY_VM_PROG   },;
			{"VM_ID"     , ARRAY_VM_ID     },;
			{"VM_SEQ"    , ARRAY_VM_SEQ    },;
			{"VM_DATA"   , ARRAY_VM_DATA   },;
			{"VM_INICIO" , ARRAY_VM_INICIO },;
			{"VM_FIM"    , ARRAY_VM_FIM    },;
			{"VM_TEMPO"  , ARRAY_VM_TEMPO  },;
			{"VM_DISP"   , ARRAY_VM_DISP   },;
			{"VM_SEQDISP", ARRAY_VM_SEQDISP},;
			{"VM_TIPO"   , ARRAY_VM_TIPO   };
		}

		_oMapFields["HZ7"] := {;
			{ "HZ7_FILIAL", ARRAY_HZ7_FILIAL },;
			{ "HZ7_PROG"  , ARRAY_HZ7_PROG   },;
			{ "HZ7_ID"    , ARRAY_HZ7_ID     },;
			{ "HZ7_SEQ"   , ARRAY_HZ7_SEQ    },;
			{ "HZ7_RECURS", ARRAY_HZ7_RECURS },;
			{ "HZ7_CTRAB" , ARRAY_HZ7_CTRAB  },;
			{ "HZ7_EFICIE", ARRAY_HZ7_EFICIE },;
			{ "HZ7_MAOOBR", ARRAY_HZ7_MAOOBR },;
			{ "HZ7_TEMPOR", ARRAY_HZ7_TEMPOR },;
			{ "HZ7_TEMPRE", ARRAY_HZ7_TEMPRE };
		}

	EndIf

Return Nil

/*/{Protheus.doc} reprocessaDistribuicao
Realiza o reprocessamento das operações que não conseguiram ser distribuidas.
@author Lucas Fagundes
@since 29/01/2024
@version P12
@return Nil
/*/
Method reprocessaDistribuicao() Class PCPA152TempoOperacao
	Local aOperacoes := {}
	Local aOrdens    := _Super:retornaListaGlobal("REPROCESSA_DISTRIBUICAO")
	Local nIndex     := 1
	Local nTotal     := Len(aOrdens)

	If nTotal > 0
		Self:oLogs:gravaLog(CHAR_ETAPAS_DIST_ORD, {"Reprocessando a distribuição de " + cValToChar(nTotal) + " ordens de produção"})
	EndIf

	While nIndex <= nTotal .And. _Super:permiteProsseguir()
		aOperacoes := aOrdens[nIndex][2]

		Self:oOcorrens:adicionaOcorrencia(LOG_ALOCADA_PELA_DATA_PROG, aOperacoes[1][ARRAY_PROC_CHAVE_ARVORE], aOperacoes[1][ARRAY_MF_ID], aOperacoes[1][ARRAY_MF_OP])

		aSort(aOperacoes,,,{|x, y| x[ARRAY_MF_OPER] < y[ARRAY_MF_OPER]})

		Self:distribuiDataDaProgramacao(aOperacoes)

		nIndex++
	End

	aSize(aOrdens, 0)

Return Nil

/*/{Protheus.doc} distribuiDataDaProgramacao
Realiza a distribuição das operações pela data de inicio da programação.
@author Lucas Fagundes
@since 29/01/2024
@version P12
@param aOperacoes, Array, Array com as operações que irá distribuir pela data da programação.
@return Nil
/*/
Method distribuiDataDaProgramacao(aOperacoes) Class PCPA152TempoOperacao
	Local aGetData   := Array(RET_GET_DATA_TAMANHO)
	Local aOperacao  := {}
	Local aPeriodos  := {}
	Local cChaveArv  := aOperacoes[1][ARRAY_PROC_CHAVE_ARVORE]
	Local dDataFim   := Nil
	Local dDataIni   := Nil
	Local lCriouDisp := .F.
	Local lDispAdc   := .F.
	Local lEfetDisp  := .F.
	Local lOperDist  := .T.
	Local lEntrega   := .F.
	Local nIndex     := 0
	Local nTotal     := Len(aOperacoes)

	aGetData[RET_GET_DATA_DATA] := Self:oParTempo["dataInicial"]
	aGetData[RET_GET_DATA_HORA] := __Hrs2Min(Self:oParTempo["horaInicial"])

	Self:cEtapaLog := CHAR_ETAPAS_DIST_ORD

	Self:oFerramentas:setJsonUtilizacao("{}")

	For nIndex := 1 To nTotal
		aOperacao := aOperacoes[nIndex]

		If aOperacao[ARRAY_MF_TEMPO] <= 0
			Loop
		EndIf

		Self:carregaDisponibilidadeRecurso(aOperacao[ARRAY_MF_RECURSO])

		Self:preAlocacaoAtualizaSobreposicao(aOperacao, lEntrega)

		aGetData[RET_GET_DATA_SOBREPOE] := .F.
		If Self:alocaComSobreposicao(aOperacao, lEntrega, aOperacao[ARRAY_MF_RECURSO])
			Self:getDataSobreposicao(aOperacao, aTail(Self:aAlocados), lEntrega, aOperacao[ARRAY_MF_RECURSO], @aGetData)
		EndIf

		aPeriodos := Self:alocaOperacao(aOperacao, lEntrega, aGetData, @lOperDist, .T., @lDispAdc, @lCriouDisp)

		lEfetDisp := lEfetDisp .Or. lCriouDisp
		If Len(aPeriodos) > 0
			If dDataIni == Nil .Or. dDataIni > aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
				dDataIni := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
			EndIf

			If dDataFim == Nil .Or. dDataFim < aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
				dDataFim := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
			EndIf
		EndIf

		If lOperDist
			aGetData[RET_GET_DATA_DATA] := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
			aGetData[RET_GET_DATA_HORA] := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]

			Self:adicionaOperacaoAlocada(aOperacao, aPeriodos, aOperacao[ARRAY_MF_RECURSO], aOperacao[ARRAY_MF_SOBREPO])
			aPeriodos := {}
		Else
			Self:removeOcorrenciasDistribuicao(aOperacao[ARRAY_PROC_CHAVE_ARVORE], aOperacao[ARRAY_MF_OP])

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
			aPeriodos := {}
			Exit
		EndIf
	Next

	Self:validaDatasOp(aOperacao, dDataIni, dDataFim)

	If lOperDist
		Self:efetivaOperacoesAlocadas()
	Else
		Self:limpaOperacoesAlocadas()
		Self:oOcorrens:removeOcorrencia(cChaveArv, aOperacao[ARRAY_MF_OP], LOG_DATA_ENTREGA_ALTERADA)
	EndIf

	If lDispAdc
		Self:oOcorrens:adicionaOcorrencia(LOG_USOU_DISPONIBILIDADE_ADICIONAL,;
		                                  cChaveArv                         ,;
		                                  aOperacao[ARRAY_MF_ID]            ,;
		                                  aOperacao[ARRAY_MF_OP]            ,;
		                                  "", "", "", "", {}                 )

		If lOperDist .And. lEfetDisp
			Self:efetivaDisponibilidadeAdicional()
		ElseIf lEfetDisp
			Self:excluiDisponibilidadeAdicional()
		EndIf
	EndIf

	Self:oOcorrens:localToGlobal()

	aSize(aOperacao, 0)
	FwFreeArray(aOperacoes)

	Self:limpaDisponibilidade(.T.)
Return Nil

/*/{Protheus.doc} limpaDisponibilidade
Limpa e inicializa as propriedades de controle da disponibilidade utilizada.

@author lucas.franca
@since 26/03/2024
@version P12
@param 01 lRecria, Logic, Recria as propriedades como json sem nenhum dado.
@return Nil
/*/
Method limpaDisponibilidade(lRecria) Class PCPA152TempoOperacao
	FwFreeObj(Self:oDispRecur)
	FreeObj(Self:oIndcRecur)
	FreeObj(Self:oIndcCAloc)

	If lRecria
		Self:oDispRecur := JsonObject():New()
		Self:oIndcRecur := JsonObject():New()
		Self:oIndcCAloc := JsonObject():New()
	EndIf

Return

/*/{Protheus.doc} adicionaOperacaoAlocada
Adiciona uma operação no json com os periodos das operações alocadas.
@author Lucas Fagundes
@since 29/01/2024
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 aPeriodos, Array   , Array com os periodos da operação.
@param 03 cRecurso , Caracter, Recurso que a operação foi alocada.
@param 04 nTempoSob, Numerico, Tempo de sobreposição da alocação.
@return Nil
/*/
Method adicionaOperacaoAlocada(aOperacao, aPeriodos, cRecurso, nTempoSob) Class PCPA152TempoOperacao

	If !Empty(aPeriodos)
		aAdd(Self:aAlocados, {aClone(aOperacao), aPeriodos, cRecurso, nTempoSob})

		Self:nUltOperDi := Len(Self:aAlocados)
	EndIf

Return Nil

/*/{Protheus.doc} efetivaOperacoesAlocadas
Efetiva os periodos das operações que foram alocadas.
@author Lucas Fagundes
@since 29/01/2024
@version P12
@return Nil
/*/
Method efetivaOperacoesAlocadas() Class PCPA152TempoOperacao
	Local aOperacao := {}
	Local aPeriodos := {}
	Local cRecurso  := ""
	Local nIndex    := 1
	Local nTotal    := Len(Self:aAlocados)
	Local nTempoSob := 0

	Self:oSeqSVM := JsonObject():New()

	For nIndex := 1 To nTotal
		aOperacao := Self:aAlocados[nIndex][ALOCADOS_POS_OPERACAO]
		aPeriodos := Self:aAlocados[nIndex][ALOCADOS_POS_PERIODOS]
		cRecurso  := Self:aAlocados[nIndex][ALOCADOS_POS_RECURSO ]
		nTempoSob := Self:aAlocados[nIndex][ALOCADOS_POS_TEMPO_SOBREPOSICAO]

		Self:gravaPeriodosOperacao(aOperacao, aPeriodos, cRecurso, nTempoSob)

		aSize(aOperacao, 0)
		aSize(aPeriodos, 0)
		aSize(Self:aAlocados[nIndex], 0)
	Next

	Self:oFerramentas:efetivaFerramentas(Self:oSeqSVM)

	Self:limpaOperacoesAlocadas()

Return Nil

/*/{Protheus.doc} limpaOperacoesAlocadas
Limpa os periodos das operações alocadas.
@author Lucas Fagundes
@since 29/01/2024
@version P12
@return Nil
/*/
Method limpaOperacoesAlocadas() Class PCPA152TempoOperacao

	Self:aAlocados  := {}
	Self:nUltOperDi := 0
	Self:oFerramentas:descartaReservaFerramentas()

Return Nil

/*/{Protheus.doc} insereTempTable
Insere os dados de uma operação na tabela temporaria de OPs.
@author Lucas Fagundes
@since 07/03/2024
@version P12
@param aDados, Array, Array com os dados da tabela SMF.
@return Nil
/*/
Method insereTempTable(aDados) Class PCPA152TempoOperacao
	Local nPosRePrin := 0

	If Self:oBulkTemp == Nil
		Self:oBulkTemp := FwBulk():New()

		Self:oBulkTemp:setTable(_Super:getNomeTempTable())
		Self:oBulkTemp:setFields(_Super:getFieldsTempTable())
	EndIf

	nPosRePrin := aScan(aDados[ARRAY_PROC_RECURSOS], {|aRec| aRec[ARRAY_HZ7_SEQ] == Self:getSequenciaRecursoPrincipal()})

	Self:oBulkTemp:addData({aDados[ARRAY_MF_FILIAL   ],; // TEMP.MF_FILIAL
	                        aDados[ARRAY_MF_PROG     ],; // TEMP.MF_PROG
	                        aDados[ARRAY_MF_OP       ],; // TEMP.MF_OP
	                        aDados[ARRAY_MF_OPER     ],; // TEMP.MF_OPER
	                        aDados[ARRAY_MF_ROTEIRO  ],; // TEMP.MF_ROTEIRO
	                        aDados[ARRAY_PROC_RECURSOS][nPosRePrin][ARRAY_HZ7_RECURS],; // TEMP.MF_RECURSO
	                        aDados[ARRAY_PROC_RECURSOS][nPosRePrin][ARRAY_HZ7_CTRAB ],; // TEMP.MF_CTRAB
	                        aDados[ARRAY_PROC_PRODUTO]}) // TEMP.PRODUTO

Return Nil

/*/{Protheus.doc} finalizaCargaTemp
Finaliza a carga da tabela temporaria, fazendo o close do bulk.
@author Lucas Fagundes
@since 07/10/2024
@version P12
@return Nil
/*/
Method finalizaCargaTemp() Class PCPA152TempoOperacao
	Local lSucesso := .T.
	Local cError   := ""

	If Self:oBulkTemp != Nil
		cError   := Self:oBulkTemp:getError()
		lSucesso := Empty(cError)

		If lSucesso
			lSucesso := Self:oBulkTemp:close()
		EndIf

		If !lSucesso
			_Super:gravaErro(CHAR_ETAPAS_CALC_TEMP, STR0431, AllTrim(Self:oBulkTemp:getError())) // "Erro ao gravar tabela temporaria de ordens de produção."
		EndIf

		Self:oBulkTemp:destroy()
		Self:oBulkTemp := Nil
	EndIf

Return Nil

/*/{Protheus.doc} calculaTempo
Retorna o tempo de um cadastro de horas.
@author Lucas Fagundes
@since 11/03/2024
@version P12
@param nTempo, Numérico, Hora que será calculada.
@return nTempo, Numérico, Tempo calculado.
/*/
Method calculaTempo(nHora) Class PCPA152TempoOperacao
	Local nTempo := 0

	If Self:oParTempo["MV_TPHR"] == "C"
		nHora := Self:horasCentesimaisParaNormais(nHora)
	EndIf

	nTempo := __Hrs2Min(nHora)

Return nTempo

/*/{Protheus.doc} ajustaFinalizacao
Ajusta os tipos do array de periodos da operação para aplicar o tempo de finalização.
@author Lucas Fagundes
@since 12/03/2024
@version P12
@param 01 aOperacao, Array, Array com as informações da operação.
@param 02 aPeriodos, Array, Array com os periodos da operação.
@return aPeriodos, Array, Array de periodos com os tempos de finalização.
/*/
Method ajustaFinalizacao(aOperacao, aPeriodos) Class PCPA152TempoOperacao
	Local aNewPer    := {}
	Local aPeriodo   := {}
	Local aTemposDis := {}
	Local nHoraIni   := 0
	Local nIndex     := Len(aPeriodos)
	Local nTempoFina := aOperacao[ARRAY_MF_TMPFINA]

	While nIndex >= 1 .And. nTempoFina > 0
		aPeriodo := aPeriodos[nIndex]

		If aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO] > nTempoFina
			nHoraIni := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

			aPeriodo[ARRAY_DISPONIBILIDADE_TIPO       ] := VM_TIPO_FINALIZACAO
			aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO] := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM] - nTempoFina
			aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO      ] := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM] - aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

			aNewPer := Self:criaPeriodoDisponibilidade(aPeriodo[ARRAY_DISPONIBILIDADE_DATA]                  ,;
			                                           nHoraIni                                              ,;
			                                           aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO           ],;
			                                           aPeriodo[ARRAY_DISPONIBILIDADE_RECURSO               ],;
			                                           aPeriodo[ARRAY_DISPONIBILIDADE_INDICE_DISP           ],;
			                                           aPeriodo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ],;
			                                           aPeriodo[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM])
			aAdd(aPeriodos, aNewPer)

			aTemposDis := Self:oDispRecur[aNewPer[ARRAY_DISPONIBILIDADE_RECURSO]][aNewPer[ARRAY_DISPONIBILIDADE_INDICE_DISP]][ARRAY_DISP_RECURSO_DISPONIBILIDADE]

			aAdd(aTemposDis, aNewPer)
			Self:ordenaTempos(@aTemposDis)


			Self:ordenaArrayPeriodos(@aPeriodos)
			Exit
		Else
			nTempoFina -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]

			aPeriodo[ARRAY_DISPONIBILIDADE_TIPO] := VM_TIPO_FINALIZACAO
		EndIf

		nIndex--
	End

Return aPeriodos

/*/{Protheus.doc} ordenaArrayPeriodos
Ordena o array com os periodos de uma operação.
@author Lucas Fagundes
@since 12/03/2024
@version P12
@param aPeriodos, Array, Array de periodos da operação.
@return Nil (retorna o array ordenado por referência).
/*/
Method ordenaArrayPeriodos(aPeriodos) Class PCPA152TempoOperacao

	aSort(aPeriodos,,,{|x,y| x[ARRAY_DISPONIBILIDADE_DATA       ] <  y[ARRAY_DISPONIBILIDADE_DATA       ]  .Or.;
	                        (x[ARRAY_DISPONIBILIDADE_DATA       ] == y[ARRAY_DISPONIBILIDADE_DATA       ] .And.;
	                         x[ARRAY_DISPONIBILIDADE_HORA_INICIO] <  y[ARRAY_DISPONIBILIDADE_HORA_INICIO])})

Return Nil

/*/{Protheus.doc} validaFinalizacao
Valida o tempo de finalização da operação na hora da alocação.
@author Lucas Fagundes
@since 13/03/2024
@version P12
@param 01 aOperacao, Array   , Operação que está sendo alocada.
@param 02 nTempo   , Numérico, Tempo que irá alocar a operação.
@param 03 cRecurso , Caracter, Recurso que está alocando a operação.
@return lPodeAloc, Lógico, Indica se pode realizar a alocação ou não.
/*/
Method validaFinalizacao(aOperacao, nTempo, cRecurso) Class PCPA152TempoOperacao
	Local cChaveOper := Self:getChaveOperacao(aOperacao)
	Local lPodeAloc  := .F.
	Local nTempoFina := Self:getTempoFinalizacao(aOperacao, cRecurso)
	Local nTempoProd := nTempo - nTempoFina

	If !Self:oOpersFina:hasProperty(cChaveOper)
		Self:oOpersFina[cChaveOper] := .F.
	EndIf

	If Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FINALIZACAO] .Or. Self:oOpersFina[cChaveOper]
		Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FINALIZACAO] := .T.

		Return
	EndIf

	If Self:lDecresce
		lPodeAloc := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] > nTempoFina +;
		             Iif(Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP], aOperacao[ARRAY_MF_SETUP], 0)
	Else
		lPodeAloc := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] >= nTempo

		If !lPodeAloc
			lPodeAloc := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] < nTempoProd .And.;
			             Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] > Iif(Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP], aOperacao[ARRAY_MF_SETUP], 0)
		EndIf
	EndIf

	If lPodeAloc .And. (Self:lDecresce .Or. (!Self:lDecresce .And. Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] > nTempo))
		Self:oOpersFina[cChaveOper] := .T.
		Self:aIntervalo[ARRAY_INTERVALO_REALIZA_FINALIZACAO] := aOperacao[ARRAY_MF_TMPFINA] > 0
	EndIf

	Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR        ] := lPodeAloc
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FINALIZACAO] := .T.

Return lPodeAloc

/*/{Protheus.doc} validaSetup
Valida o tempo de setup na hora da alocação.
@author Lucas Fagundes
@since 14/03/2024
@version P12
@param 01 aOperacao , Array   , Operação que está sendo alocada.
@param 02 nIndDisp  , Numérico, Indice da disponibilidade que está realizando a alocação.
@param 03 nIndTempos, Numérico, Indice dos tempos da disponibilidade que está realizando a alocação.
@param 04 nTempo    , Numérico, Tempo de alocação da operação.
@param 05 nHora     , Numérico, Hora de inicio da alocação da operação no período da disponibilidade (nIndDisp e nIndTempos).
@param 06 cRecurso  , Caracter, Recurso que está alocando a operação.
@return Nil
/*/
Method validaSetup(aOperacao, nIndDisp, nIndTempos, nTempo, nHora, cRecurso) Class PCPA152TempoOperacao
	Local aAlocAnt  := {}
	Local aDispRec  := {}
	Local lOpersSeq := .F.
	Local nIndAnt   := 0
	Local nTempoAnt := 0
	Local nIndProd  := 0
	Local nTotal    := 0

	If Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_SETUP]
		Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := .F.

		Return
	EndIf
	aDispRec := Self:oDispRecur[cRecurso]

	// Verifica aplicação de setup se o recurso não é ilimitado.
	If aOperacao[ARRAY_MF_SETUP] > 0 .And. !aDispRec[nIndDisp][ARRAY_DISP_RECURSO_ILIMITADO]

		// Não possui alocação anterior
		Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := !Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR]

		// Possui alocação anterior. Verifica se o produto é diferente.
		If !Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]
			nIndAnt   := Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_INDICE_DISP]
			nTempoAnt := Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_INDICE_TEMPOS]
			aAlocAnt  := aDispRec[nIndAnt][ARRAY_DISP_RECURSO_DISPONIBILIDADE][nTempoAnt]

			// Se for um periodo efetivado, verifica todos os produtos em busca de um diferente do que está sendo alocado.
			If Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO]
				nTotal := Len(aDispRec[nIndAnt][ARRAY_DISP_RECURSO_PRODUTOS_EFETIVADOS])

				For nIndProd := 1 To nTotal
					Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := aDispRec[nIndAnt][ARRAY_DISP_RECURSO_PRODUTOS_EFETIVADOS][nIndProd] != aOperacao[ARRAY_PROC_PRODUTO]

					If Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]
						Exit
					EndIf
				Next
			Else
			 	Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := Self:getOperacao(aAlocAnt[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM], aAlocAnt[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID])[ARRAY_PROC_PRODUTO] != aOperacao[ARRAY_PROC_PRODUTO]
			EndIf
		EndIf

		// Produto é igual. Verifica se a alocação atual vai começar quando terminar a anterior.
		If !Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] .And. !Self:lRedSetup

			If Self:lDecresce
				Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] > nTempo
			Else

				// Verifica se a alocação atual está começando quando termina a anterior no mesmo indice da disponibilidade.
				// Ex: |DISPONIBILIDADE                 |
				//       |ANTERIOR          |NOVA    |
				If Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_INDICE_DISP] == nIndDisp
					lOpersSeq := aAlocAnt[ARRAY_DISPONIBILIDADE_HORA_FIM] >= nHora

				// Verifica se a alocação atual está começando quando termina a anterior em indices de disponibilidade diferentes
				// Ex: |DISPONIBILIDADE       |        |DISPONIBILIDADE         |
				//                 |ANTERIOR  |        |NOVA       |
				Else
					lOpersSeq := nIndDisp == (Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_INDICE_DISP] + 1) .And.; // Verifica se os indices são sequencias
					             aDispRec[nIndAnt][ARRAY_DISP_RECURSO_HORA_FIM] == aAlocAnt[ARRAY_DISPONIBILIDADE_HORA_FIM] .And.; // Verifica se a operação anterior está terminando na hora final do indice.
					             aDispRec[nIndDisp][ARRAY_DISP_RECURSO_HORA_INICIO] >= nHora // Verifica se essa alocação vai ser feita na hora inicial do indice

				EndIf

				Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] := !lOpersSeq
			EndIf
		EndIf

		If Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]
			aAdd(Self:aOpersAnt, aAlocAnt)
		EndIf
	EndIf

	Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR] := !Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP] .Or.;
	                                                Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] >= aOperacao[ARRAY_MF_SETUP]
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_SETUP] := .T.

Return Nil

/*/{Protheus.doc} validaOperacaoPosterior
Quando está reduzindo setup, verifica se a alocação da operação
atual irá impactar a alocação da próxima operação que já está alocada
no recurso.
Se impactar em uma operação de menor prioridade, não pode utilizar
este período para alocar a operação atual.

@author lucas.franca
@since 13/06/2024
@version P12
@param 01 aOperacao, Array   , Operação que está sendo alocada.
@param 02 nTempo   , Numeric , Tempo que a operação vai ocupar.
@param 03 aTempo   , Array   , Dados do tempo atual de alocação da operação
@param 04 cRecurso , Caracter, Recurso que está alocando a operação.
@return Nil
/*/
Method validaOperacaoPosterior(aOperacao, nTempo, aTempo, cRecurso) Class PCPA152TempoOperacao
	Local aIntPoster := Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_POSTERIOR]
	Local aAlocPost  := Nil
	Local aOperPost  := Nil
	Local nIndPost   := Nil
	Local nTempoPost := Nil

	If Self:lRedSetup                                             .And.; //Se está reduzindo SETUP
	   Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]               .And.; //E pode alocar neste período
	   aIntPoster[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] .And.; //E existe alocação posterior
	   aIntPoster[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO] == .F.       //E a alocação posterior não é efetivada

		nIndPost   := aIntPoster[ARRAY_OPER_ANTERIOR_INDICE_DISP]
		nTempoPost := aIntPoster[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS]
		aAlocPost  := Self:oDispRecur[cRecurso][nIndPost][ARRAY_DISP_RECURSO_DISPONIBILIDADE][nTempoPost]
		aOperPost  := Self:getOperacao(aAlocPost[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM], aAlocPost[ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID])

		If aOperPost[ARRAY_MF_SETUP    ] > 0                              .And.; //Se a próxima operação exige SETUP
		   aOperPost[ARRAY_PROC_PRODUTO] <> aOperacao[ARRAY_PROC_PRODUTO] .And.; //E a próxima operação é produto diferente da operação atual
		   aOperPost[ARRAY_MF_PRIOR    ] <  aOperacao[ARRAY_MF_PRIOR    ] .And.; //E a próxima operação tem prioridade menor que a operação atual
		   aAlocPost[ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_SETUP         .And.; //E a alocação posterior NÃO é o SETUP da próxima operação
		   nTempo + aOperPost[ARRAY_MF_SETUP] > Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] //E o tempo da operação atual + setup da operação posterior não cabem no tempo disponível
			//Não permite alocar, pois irá causar que uma operação de prioridade
			//menor seja desalocada, pois não será possível adicionar o setup na próxima operação.
			Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR] := .F.

			Self:oLogs:gravaLog(Self:cEtapaLog, {"Operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " nao foi alocada no periodo de " + ;
			                                     __Min2Hrs(aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM], .T.) + ;
			                                     " do dia " + DToC(aTempo[ARRAY_DISPONIBILIDADE_DATA]) + ", pois ira invalidar a operacao posterior que possui menor prioridade.",;
			                                     "Operacao posterior: " + aOperPost[ARRAY_MF_OPER] + " da ordem " + aOperPost[ARRAY_MF_OP] + ;
			                                     " no dia " + DToC(aAlocPost[ARRAY_DISPONIBILIDADE_DATA]) + " e horario " +;
			                                     __Min2Hrs(aAlocPost[ARRAY_DISPONIBILIDADE_HORA_INICIO], .T.) + " - " + __Min2Hrs(aAlocPost[ARRAY_DISPONIBILIDADE_HORA_FIM], .T.)},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf
		aAlocPost := Nil
		aOperPost := Nil
	EndIf
	aIntPoster := Nil

Return

/*/{Protheus.doc} ajustaSetup
Atribui o setup aos periodos de alocação.
@author Lucas Fagundes
@since 14/03/2024
@version P12
@param 01 aOperacao, Array, Operação sendo alocada.
@param 02 aPeriodos, Array, Array com os periodos de alocação.
@return aPeriodos, Array, Array com os tempos de setup atribuidos.
/*/
Method ajustaSetup(aOperacao, aPeriodos) Class PCPA152TempoOperacao
	Local dDataIni := Nil
	Local nHoraIni := 0
	Local nIndex   := 0
	Local nTotal   := Len(Self:aOpersAnt)

	For nIndex := 1 To nTotal
		dDataIni := Nil
		nHoraIni := Nil

		If !Empty(Self:aOpersAnt[nIndex])
			dDataIni := Self:aOpersAnt[nIndex][ARRAY_DISPONIBILIDADE_DATA]
			nHoraIni := Self:aOpersAnt[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO]
		EndIf

		aPeriodos := Self:setaSetupPeriodos(aOperacao, aPeriodos, dDataIni, nHoraIni)
	Next

Return aPeriodos

/*/{Protheus.doc} setaSetupPeriodos
Percorre os periodos de alocação atribuindo o setup.
@author Lucas Fagundes
@since 14/03/2024
@version P12
@param 01 aOperacao, Array   , Operação sendo alocada.
@param 02 aPeriodos, Array   , Array com os periodos de alocação.
@param 03 dDataIni , Date    , Data de inicio do setup (Se estiver Nil, vai considerar o primeiro periodo).
@param 04 nHoraIni , Numérico, Hora de inicio do setup (Se estiver Nil, vai considerar o primeiro periodo).
@return aPeriodos, Array, Array com os periodos de alocação com o setup atribuido.
/*/
Method setaSetupPeriodos(aOperacao, aPeriodos, dDataIni, nHoraIni) Class PCPA152TempoOperacao
	Local aPeriodo   := {}
	Local aTemposDis := {}
	Local nHoraPer   := 0
	Local nIndPer    := 0
	Local nSetup     := aOperacao[ARRAY_MF_SETUP]
	Local nTotPer    := Len(aPeriodos)

	For nIndPer := 1 To nTotPer
		If (dDataIni == Nil .And. nHoraIni == Nil) .Or. ((aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_DATA       ] >  dDataIni)  .Or.;
		                                                 (aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_DATA       ] == dDataIni   .And.;
		                                                  aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_INICIO] >= nHoraIni))

			aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TIPO] := VM_TIPO_SETUP

			If aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO] > nSetup
				nHoraPer := aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_INICIO] + nSetup

				aPeriodo := Self:criaPeriodoDisponibilidade(aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_DATA]                  ,;
				                                            nHoraPer                                                        ,;
				                                            aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_FIM              ],;
				                                            aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_RECURSO               ],;
				                                            aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_INDICE_DISP           ],;
				                                            aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ],;
				                                            aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM])

				aAdd(aPeriodos, aPeriodo)

				aTemposDis := Self:oDispRecur[aPeriodo[ARRAY_DISPONIBILIDADE_RECURSO]][aPeriodo[ARRAY_DISPONIBILIDADE_INDICE_DISP]][ARRAY_DISP_RECURSO_DISPONIBILIDADE]

				aAdd(aTemposDis, aPeriodo)
				Self:ordenaTempos(@aTemposDis)

				aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_FIM] := nHoraPer
				aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO   ] := aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_FIM] - aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_HORA_INICIO]

				nSetup -= aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO]
				Self:ordenaArrayPeriodos(@aPeriodos)
			Else
				nSetup -= aPeriodos[nIndPer][ARRAY_DISPONIBILIDADE_TEMPO]
			EndIf

			If nSetup <= 0
				Exit
			EndIf
		EndIf
	Next

Return aPeriodos

/*/{Protheus.doc} getChaveOperacao
Retorna chave de uma operação.
@author Lucas Fagundes
@since 15/03/2024
@version P12
@param aOperacao, Array, Operação que irá retornar a chave.
@return Caracter, Chave da operação.
/*/
Method getChaveOperacao(aOperacao) Class PCPA152TempoOperacao

Return aOperacao[ARRAY_MF_OP] + aOperacao[ARRAY_MF_OPER]

/*/{Protheus.doc} carregaIntervaloAlocacao
Busca as informações do intervalo disponivel a partir de um ponto na disponibilidade de um recurso.
@author Lucas Fagundes
@since 01/04/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar a disponibilidade.
@param 02 nIndDisp  , Numérico, Indice inicial da disponibilidade do recurso.
@param 03 nIndTempos, Numérico, Indice inicial do array de tempos no indice inicial da disponibilidade do recurso.
@param 04 nHoraIniAl, Numérico, Hora inicial da alocação da operação.
@param 06 aOperacao , Array   , Array com as informações da operação.
@return Nil
/*/
Method carregaIntervaloAlocacao(cRecurso, nIndDisp, nIndTempos, nHoraIniAl, aOperacao) Class PCPA152TempoOperacao
	Local aTempo     := Self:oDispRecur[cRecurso][nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE][nIndTempos]
	Local dDataIniAl := aTempo[ARRAY_DISPONIBILIDADE_DATA]
	Local nTamInterv := Len(Self:aIntervalo)
	Local nTmpPerAtu := 0

	If nTamInterv > 0 .And.;
	   (nIndDisp >  Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP] .Or.;
	    nIndDisp == Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP] .And. nIndTempos > Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO]) .And.;
	   (nIndDisp <  Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP] .Or.;
	    nIndDisp == Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP] .And. nIndTempos < Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO])

		If Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR]
			Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR  ] := Self:getAlocAnterior(cRecurso, nIndDisp, nIndTempos, dDataIniAl, nHoraIniAl)
			Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_POSTERIOR ] := Self:getAlocPosterior(cRecurso, nIndDisp, nIndTempos, dDataIniAl, nHoraIniAl)
		EndIf

		Return
	EndIf
	Self:aIntervalo := Array(ARRAY_INTERVALO_TAMANHO)

	Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP  ] := nIndDisp
	Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO ] := nIndTempos
	Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP     ] := nIndDisp
	Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO    ] := nIndTempos
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_SETUP      ] := .F.
	Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP      ] := .F.
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FINALIZACAO] := .F.
	Self:aIntervalo[ARRAY_INTERVALO_REALIZA_FINALIZACAO] := .F.
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA ] := .F.

	nTmpPerAtu := Self:getTempoAlocavel(dDataIniAl, nHoraIniAl, aTempo[ARRAY_DISPONIBILIDADE_DATA], aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO], aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM])
	Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR        ] := .T.
	Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR  ] := Self:getAlocAnterior(cRecurso, nIndDisp, nIndTempos, dDataIniAl, nHoraIniAl)
	Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_POSTERIOR ] := Self:getAlocPosterior(cRecurso, nIndDisp, nIndTempos, dDataIniAl, nHoraIniAl)
	Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL     ] := Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_ANTERIOR][ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL] +;
	                                                        Self:aIntervalo[ARRAY_INTERVALO_OPERACAO_POSTERIOR][ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL] +;
	                                                        nTmpPerAtu

Return Nil

/*/{Protheus.doc} getAlocAnterior
Busca a alocação anterior a partir de um ponto da disponibilidade de um recurso.
@author Lucas Fagundes
@since 01/04/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar a disponibilidade.
@param 02 nIndDisp  , Numérico, Indice inicial da disponibilidade do recurso.
@param 03 nIndTempos, Numérico, Indice inicial do array de tempos no indice inicial da disponibilidade do recurso.
@param 04 dDataIni  , Date    , Data inicial da operação que está sendo alocada atualmente.
@param 05 nHoraIni  , Numérico, Hora inicial da operação que está sendo alocada atualmente.
@return aAlocAnt, Array, informações da alocação anterior.
/*/
Method getAlocAnterior(cRecurso, nIndDisp, nIndTempos, dDataIni, nHoraIni) Class PCPA152TempoOperacao
	Local aAlocAnt   := Array(ARRAY_OPER_ANTERIOR_TAMANHO)
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aTempos    := {}
	Local lRecIlimi  := aDispRec[nIndDisp][ARRAY_DISP_RECURSO_ILIMITADO]
	Local lVldTempo  := .T.
	Local nIndex     := 0
	Local nIndexAux  := 0
	Local nTempoAloc := 0
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	lVldTempo := Empty(Self:aFerramentas) .Or. !Self:oParTempo["utilizaFerramentas"]
	If lVldTempo .And. Self:lDecresce
		nTempoAloc := Self:nTempoOper + Self:aOperacao[ARRAY_MF_SETUP]
	EndIf

	aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .F.
	aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .F.
	aAlocAnt[ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL          ] := 0

	For nIndex := nIndDisp To 1 Step -1
		aTempos := aDispRec[nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]

		If aDispRec[nIndex][ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA .And. !lRecIlimi
			aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .T.
			aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .T.
			nIndexAux := Len(aTempos)

		ElseIf (!oAlocacoes:hasProperty(cValToChar(nIndex)) .Or. lRecIlimi) .And. nIndex != nIndDisp
			aAlocAnt[ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL] += Self:tempoAlocavelPeriodo(Nil, dDataIni, nHoraIni, aDispRec[nIndex])
			nIndexAux := Len(aTempos)

		Else
			nIndexAux := Iif(nIndex == nIndDisp, (nIndTempos-1), Len(aTempos))

			For nIndexAux := nIndexAux To 1 Step -1

				If aTempos[nIndexAux][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL .And. !lRecIlimi

					aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .T.

					Exit
				Else
					aAlocAnt[ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL] += Self:tempoAlocavelPeriodo(aTempos[nIndexAux], dDataIni, nHoraIni, Nil)

					If lVldTempo .And. aAlocAnt[ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL] >= nTempoAloc
						Exit
					EndIf
				EndIf
			Next
		EndIf

		If aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] .Or. (lVldTempo .And. aAlocAnt[ARRAY_OPER_ANTERIOR_TEMPO_ALOCAVEL] >= nTempoAloc)
			Exit
		EndIf
	Next

	Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP ] := Iif(nIndex < 1, 1, nIndex)
	Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO] := Iif(nIndexAux < 1, 1, nIndexAux)

	If aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR]
		aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_DISP  ] := nIndex
		aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS] := Iif(aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO], 1, nIndexAux)

	ElseIf Len(oAlocacoes["indices"]) > 0
		Self:buscaAlocAnterior(@aAlocAnt, cRecurso, nIndDisp, nIndTempos)

	EndIf

	oAlocacoes := Nil
Return aAlocAnt

/*/{Protheus.doc} buscaAlocAnterior
Busca a alocação anterior a um ponto da disponibilidade de um recurso.
@author Lucas Fagundes
@since 24/04/2025
@version P12
@param 01 aAlocAnt  , Array   , Array que ira retornar as informações da alocação anterior.
@param 02 cRecurso  , Caracter, Recurso que irá buscar a alocação.
@param 03 nIndDisp  , Numerico, Indice inicial da busca na disponibilidade do recurso.
@param 04 nIndTempos, Numerico, Indice inicial do array de tempos da posição nIndDisp.
@return Nil
/*/
Method buscaAlocAnterior(aAlocAnt, cRecurso, nIndDisp, nIndTempos) Class PCPA152TempoOperacao
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aIndcCAloc := {}
	Local aTempos    := {}
	Local nIndex     := 0
	Local nIndexAux  := 0
	Local nPos       := 0
	Local nTotal     := 0
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	aIndcCAloc := aClone(oAlocacoes["indices"])
	aSort(aIndcCAloc,,,{|x,y| x > y})

	aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .F.
	aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .F.

	nPos := aScan(aIndcCAloc, {|x| x == nIndDisp})
	If nPos > 0 .And. aIndcCAloc[nPos] == nIndDisp
		aTempos   := aDispRec[nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		nIndexAux := nIndTempos - 1

		For nIndex := nIndexAux To 1 Step -1
			If aTempos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
				aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .T.
				aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .F.
				aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_DISP             ] := nIndDisp
				aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS           ] := nIndex

				Exit
			EndIf
		Next
	EndIf

	If !aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR]
		nPos := aScan(aIndcCAloc, {|x| x < nIndDisp})

		If nPos > 0 .And. aIndcCAloc[nPos] < nIndDisp
			nIndexAux := aIndcCAloc[nPos]

			If aDispRec[nIndexAux][ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA
				aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .T.
				aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .T.
				aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_DISP             ] := nIndexAux
				aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS           ] := 1

			Else
				aTempos := aDispRec[nIndexAux][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
				nTotal  := Len(aTempos)

				For nIndex := nTotal To 1 Step -1
					If aTempos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
						aAlocAnt[ARRAY_OPER_ANTERIOR_EXISTE_ALOCACAO_ANTERIOR] := .T.
						aAlocAnt[ARRAY_OPER_ANTERIOR_ANTERIOR_EFETIVADO      ] := .F.
						aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_DISP             ] := nIndexAux
						aAlocAnt[ARRAY_OPER_ANTERIOR_INDICE_TEMPOS           ] := nIndex

						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf

	aSize(aIndcCAloc, 0)
Return Nil

/*/{Protheus.doc} getAlocPosterior
Busca a alocação posterior a partir de um ponto da disponibilidade de um recurso.
@author Lucas Fagundes
@since 01/04/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar a disponibilidade.
@param 02 nIndDisp  , Numérico, Indice inicial da disponibilidade do recurso.
@param 03 nIndTempos, Numérico, Indice inicial do array de tempos no indice inicial da disponibilidade do recurso.
@param 04 dDataIni  , Date    , Data inicial da operação que está sendo alocada atualmente.
@param 05 nHoraIni  , Numérico, Hora inicial da operação que está sendo alocada atualmente.
@return aAlocPost, Array, informações da alocação posterior.
/*/
Method getAlocPosterior(cRecurso, nIndDisp, nIndTempos, dDataIni, nHoraIni) Class PCPA152TempoOperacao
	Local aAlocPost  := Array(ARRAY_OPER_POSTERIOR_TAMANHO)
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aTempos    := {}
	Local lRecIlimi  := aDispRec[nIndDisp][ARRAY_DISP_RECURSO_ILIMITADO]
	Local lVldTempo  := .T.
	Local nIndex     := 0
	Local nIndexAux  := 0
	Local nTempoAloc := 0
	Local nTotal     := Len(aDispRec)
	Local nTotalAux  := 0
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	lVldTempo := Empty(Self:aFerramentas) .Or. !Self:oParTempo["utilizaFerramentas"]
	If lVldTempo .And. !Self:lDecresce
		nTempoAloc := Self:nTempoOper + Self:aOperacao[ARRAY_MF_SETUP]
	EndIf

	aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .F.
	aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .F.
	aAlocPost[ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL           ] := 0

	For nIndex := nIndDisp To nTotal
		aTempos   := aDispRec[nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		nTotalAux := Len(aTempos)

		If aDispRec[nIndex][ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA .And. !lRecIlimi
			aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .T.
			aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .T.
			nIndexAux := 1

		ElseIf (!oAlocacoes:hasProperty(cValToChar(nIndex)) .Or. lRecIlimi) .And. nIndex != nIndDisp
			aAlocPost[ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL] += Self:tempoAlocavelPeriodo(Nil, dDataIni, nHoraIni, aDispRec[nIndex])
			nIndexAux := 1

		Else
			nIndexAux := Iif(nIndex == nIndDisp, (nIndTempos+1), 1)

			For nIndexAux := nIndexAux To nTotalAux

				If aTempos[nIndexAux][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL .And. !lRecIlimi
					aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .T.

					Exit
				Else
					aAlocPost[ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL] += Self:tempoAlocavelPeriodo(aTempos[nIndexAux], dDataIni, nHoraIni, Nil)

					If lVldTempo .And. aAlocPost[ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL] >= nTempoAloc
						Exit
					EndIf
				EndIf
			Next
		EndIf

		If aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] .Or. (lVldTempo .And. aAlocPost[ARRAY_OPER_POSTERIOR_TEMPO_ALOCAVEL] >= nTempoAloc)
			Exit
		EndIf
	Next

	Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP ] := Iif(nIndex > nTotal, nTotal, nIndex)
	Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO] := Iif(nIndexAux > nTotalAux, nTotalAux, nIndexAux)

	If aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR]
		aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_DISP  ] := nIndex
		aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_TEMPOS] := Iif(aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO], 1, nIndexAux)

	ElseIf Len(oAlocacoes["indices"]) > 0
		Self:buscaAlocPosterior(@aAlocPost, cRecurso, nIndDisp, nIndTempos)

	EndIf

	oAlocacoes := Nil
Return aAlocPost

/*/{Protheus.doc} buscaAlocPosterior
Busca a alocação posterior a um ponto da disponibilidade de um recurso.
@author Lucas Fagundes
@since 24/04/2025
@version P12
@param 01 aAlocPost , Array   , Array que ira retornar as informações da alocação posterior.
@param 02 cRecurso  , Caracter, Recurso que irá buscar a alocação.
@param 03 nIndDisp  , Numerico, Indice inicial da busca na disponibilidade do recurso.
@param 04 nIndTempos, Numerico, Indice inicial do array de tempos da posição nIndDisp.
@return Nil
/*/
Method buscaAlocPosterior(aAlocPost, cRecurso, nIndDisp, nIndTempos) Class PCPA152TempoOperacao
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aIndcCAloc := {}
	Local aTempos    := {}
	Local nIndex     := 0
	Local nIndexAux  := 0
	Local nPos       := 0
	Local nTotal     := 0
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	aIndcCAloc := oAlocacoes["indices"]
	aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .F.
	aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .F.

	nPos := aScan(aIndcCAloc, {|x| x == nIndDisp})
	If nPos > 0 .And. aIndcCAloc[nPos] == nIndDisp
		aTempos   := aDispRec[nIndDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		nIndexAux := nIndTempos + 1
		nTotal    := Len(aTempos)

		For nIndex := nIndexAux To nTotal
			If aTempos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
				aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .T.
				aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .F.
				aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_DISP              ] := nIndDisp
				aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_TEMPOS            ] := nIndex

				Exit
			EndIf
		Next
	EndIf

	If !aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR]
		nPos := aScan(aIndcCAloc, {|x| x > nIndDisp})

		If nPos > 0 .And. aIndcCAloc[nPos] > nIndDisp
			nIndexAux := aIndcCAloc[nPos]

			If aDispRec[nIndexAux][ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA
				aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .T.
				aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .T.
				aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_DISP              ] := nIndexAux
				aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_TEMPOS            ] := 1

			Else
				aTempos := aDispRec[nIndexAux][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
				nTotal  := Len(aTempos)

				For nIndex := 1 To nTotal
					If aTempos[nIndex][ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
						aAlocPost[ARRAY_OPER_POSTERIOR_EXISTE_ALOCACAO_POSTERIOR] := .T.
						aAlocPost[ARRAY_OPER_POSTERIOR_POSTERIOR_EFETIVADO      ] := .F.
						aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_DISP              ] := nIndexAux
						aAlocPost[ARRAY_OPER_POSTERIOR_INDICE_TEMPOS            ] := nIndex

						Exit
					EndIf
				Next
			EndIf
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} tempoAlocavelPeriodo
Verifica o tempo disponivel para alocação da operação dentro de um periodo de disponibilidade
@author Lucas Fagundes
@since 23/04/2025
@version P12
@param 01 aTempo     , Array   , Quebra da disponibilidade que irá buscar o tempo alocavel.
@param 02 dDataIni   , Date    , Data inicial da operação que está sendo alocada atualmente.
@param 03 nHoraIni   , Numérico, Hora inicial da operação que está sendo alocada atualmente.
@param 04 aDispRec   , Array   , Disponibilidade do recurso que irá buscar o tempo alocavel.
@param 05 lFerramDisp, Logico, Retorna por referencia se a ferramenta vai estar disponivel.
@return nTempo, Numérico, Tempo disponivel para alocação dentro do periodo.
/*/
Method tempoAlocavelPeriodo(aTempo, dDataIni, nHoraIni, aDispRec, lFerramDisp) Class PCPA152TempoOperacao
	Local dDataVld    := Nil
	Local nHrFimVld   := 0
	Local nHrIniVld   := 0
	Local nTempo      := 0
	Local nTempoVld   := 0

	If aDispRec != Nil
		dDataVld  := aDispRec[ARRAY_DISP_RECURSO_DATA]
		nHrIniVld := aDispRec[ARRAY_DISP_RECURSO_HORA_INICIO]
		nHrFimVld := aDispRec[ARRAY_DISP_RECURSO_HORA_FIM]
		nTempoVld := aDispRec[ARRAY_DISP_RECURSO_TEMPO]
	Else
		dDataVld  := aTempo[ARRAY_DISPONIBILIDADE_DATA]
		nHrIniVld := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]

		nHrFimVld := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM]
		nTempoVld := aTempo[ARRAY_DISPONIBILIDADE_TEMPO]
	EndIf

	nTempo := Self:getTempoAlocavel(dDataIni, nHoraIni, dDataVld, nHrIniVld, nHrFimVld)

Return nTempo

/*/{Protheus.doc} getTempoAlocavel
Retorna o tempo que uma operação pode ser alocada dentro de um periodo de tempo.
@author Lucas Fagundes
@since 01/04/2024
@version P12
@param 01 dDataIni , Date    , Data inicial da alocação da operação.
@param 02 nHoraIni , Numérico, Hora inicial da alocação da operação.
@param 03 dDataVld , Date    , Data do periodo de tempo.
@param 04 nHrIniVld, Numerico, Hora inicial do periodo de tempo.
@param 05 nHrFimVld, Numerico, Hora final do periodo de tempo.
@return nTempo, Numérico, Tempo disponivel para alocação dentro do periodo.
/*/
Method getTempoAlocavel(dDataIni, nHoraIni, dDataVld, nHrIniVld, nHrFimVld) Class PCPA152TempoOperacao
	Local nTempo := 0
	Local nTempoVld := nHrFimVld - nHrIniVld

	If Self:lDecresce
		If dDataVld <  dDataIni .Or.;
		  (dDataVld == dDataIni .And. nHrFimVld <= nHoraIni)

			nTempo := nTempoVld

		ElseIf dDataVld == dDataIni .And. nHrIniVld < nHoraIni

			nTempo := nHoraIni - nHrIniVld
		EndIf
	Else
		If dDataVld >  dDataIni .Or.;
		  (dDataVld == dDataIni .And. nHrIniVld >= nHoraIni)

			nTempo := nTempoVld

		ElseIf dDataVld == dDataIni .And. nHrFimVld > nHoraIni

			nTempo := nHrFimVld - nHoraIni
		EndIf
	EndIf

Return nTempo

/*/{Protheus.doc} validaQuebras
Valida se irá alocar a operação por completo.
@author Lucas Fagundes
@since 16/04/2024
@version P12
@param nTempo, Numerico, Tempo de alocação da operação (já considerando finalização e setup).
@return Nil
/*/
Method validaQuebras(nTempo) Class PCPA152TempoOperacao

	If !Self:oParTempo["quebraOperacoes"]
		Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR] := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] >= nTempo
	EndIf

Return Nil

/*/{Protheus.doc} chaveListaDadosSVM
Monta a chave para acesso da global de dados da SVM.

@author lucas.franca
@since 21/05/2024
@version P12
@param 01 aOperacao, Array, Array com os dados da operação
@return cChave, Caracter, Chave de acesso para a global da SVM
/*/
Method chaveListaDadosSVM(aOperacao) Class PCPA152TempoOperacao
	Local cChave := aOperacao[ARRAY_MF_OP] + CHR(13) + aOperacao[ARRAY_MF_RECURSO]
Return cChave

/*/{Protheus.doc} unePeriodosDisponiveis
identifica e une períodos de disponibilidade que são iguais e que estão divididos (quebrados)

@author lucas.franca
@since 23/05/2024
@version P12
@param 01 aDisp, Array, Array com os dados de disponibilidade do recurso
@return Nil
/*/
Method unePeriodosDisponiveis(aDisp) Class PCPA152TempoOperacao
	Local lUltimoDis := .F.
	Local nPosAnt    := 0
	Local nIndex     := 1
	Local nTotal     := Len(aDisp)

	While nIndex <= nTotal
		nPosAnt := nIndex-1

		If !aDisp[nIndex][ARRAY_DISPONIBILIDADE_FERRAMENTA_DISPONIVEL]
			aDisp[nIndex][ARRAY_DISPONIBILIDADE_FERRAMENTA_DISPONIVEL] := .T.
		EndIf

		//Verifica se pode juntar o índice atual com o índice anterior.
		If lUltimoDis                                                             .And.;
		   aDisp[nIndex][ARRAY_DISPONIBILIDADE_TIPO       ] == VM_TIPO_DISPONIVEL .And.;
		   aDisp[nIndex][ARRAY_DISPONIBILIDADE_INDICE_DISP] == aDisp[nPosAnt][ARRAY_DISPONIBILIDADE_INDICE_DISP]

			//Ajusta o tempo dos índices, e remove o atual.
			aDisp[nPosAnt][ARRAY_DISPONIBILIDADE_HORA_FIM] := aDisp[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM]
			aDisp[nPosAnt][ARRAY_DISPONIBILIDADE_TEMPO   ] += aDisp[nIndex][ARRAY_DISPONIBILIDADE_TEMPO   ]

			aDel(aDisp, nIndex)
			nTotal--
			Loop

		EndIf

		lUltimoDis := aDisp[nIndex][ARRAY_DISPONIBILIDADE_TIPO] == VM_TIPO_DISPONIVEL

		nIndex++
	End
	aSize(aDisp, nTotal)
Return

/*/{Protheus.doc} gravaBackupDisponibilidades
Cria backup da disponibilidade dos recursos.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@param 01 cRecurso, Caracter, Código do recurso para criar o backup
@param 02 nIndDisp, Numeric , índice da disponibilidade do recurso para criar o bkp
@return Nil
/*/
Method gravaBackupDisponibilidades(cRecurso, nIndDisp) Class PCPA152TempoOperacao
	Local cDataAdic := ""
	Local cIndice   := cValToChar(nIndDisp)
	Local lError    := .F.

	//Somente cria o backup 1x para o recurso
	If Self:oBkpDisRec:hasProperty(cRecurso) == .F.

		Self:oBkpDisRec[cRecurso] := JsonObject():New()
		Self:oBkpDisRec[cRecurso]["disponibilidade"] := JsonObject():New()
		Self:oBkpDisRec[cRecurso]["tamanhoOriginal"] := Len(Self:oDispRecur[cRecurso])

		If Self:oIndcRecur:HasProperty(cRecurso)
			Self:oBkpDisRec[cRecurso]["indices"] := Self:oIndcRecur[cRecurso]:ToJson()
		EndIf

		If Self:oIndcCAloc:hasProperty(cRecurso)
			Self:oBkpDisRec[cRecurso]["indicesComAlocacao"] := Self:oIndcCAloc[cRecurso]:toJson()
		EndIf

		If Self:oBkpDisRec:hasProperty("_RECURSOS_EXISTENTES_DISP_") == .F.
			Self:oBkpDisRec["_RECURSOS_EXISTENTES_DISP_"] := Self:oDispRecur:getNames()

			Self:oBkpDisRec["_DATA_FIM_ADICIONAL_"] := ""
			cDataAdic := Self:retornaValorGlobal("DATA_FIM_DISP_ADICIONAL", @lError)
			If !lError
				Self:oBkpDisRec["_DATA_FIM_ADICIONAL_"] := cDataAdic
			EndIf
		EndIf

	EndIf

	If nIndDisp > 0 .And. ;
	   Self:oBkpDisRec[cRecurso]["tamanhoOriginal"] >= nIndDisp .And.;
	   !Self:oBkpDisRec[cRecurso]["disponibilidade"]:hasProperty(cIndice)

		Self:oBkpDisRec[cRecurso]["disponibilidade"][cIndice] := {nIndDisp, aClone(Self:oDispRecur[cRecurso][nIndDisp])}
	EndIf

	If !Self:oBkpDisRec:hasProperty("jsonFinalizacao")
		Self:oBkpDisRec["jsonFinalizacao"] := Self:oOpersFina:toJson()
	EndIf

Return

/*/{Protheus.doc} restauraBackupDisponibilidades
Restaura backup da disponibilidade dos recursos.
@author Lucas Fagundes
@since 14/08/2023
@version P12
@return Nil
/*/
Method restauraBackupDisponibilidades() Class PCPA152TempoOperacao
	Local aNames   := Nil
	Local aIndices := Nil
	Local cRecurso := ""
	Local nPos     := 0
	Local nTotIndc := 0
	Local nIndIdc  := 0
	Local nTotal   := 0
	Local nIndex   := 0
	Local oPreRecs := JsonObject():New()

	If Self:oBkpDisRec:hasProperty("_RECURSOS_EXISTENTES_DISP_") == .F.
		Return
	EndIf

	If !Empty(Self:oBkpDisRec["_DATA_FIM_ADICIONAL_"])
		Self:gravaValorGlobal("DATA_FIM_DISP_ADICIONAL", Self:oBkpDisRec["_DATA_FIM_ADICIONAL_"])
	EndIf
	Self:oBkpDisRec:delName("_DATA_FIM_ADICIONAL_")

	//Remove do objeto de disponibilidade os recursos que foram criados após o backup.
	aNames := Self:oBkpDisRec["_RECURSOS_EXISTENTES_DISP_"]
	nTotal := Len(aNames)
	For nIndex := 1 To nTotal
		//Cria o objeto oPreRecs apenas para facilitar a verificação dos recursos que já existiam antes do backup.
		oPreRecs[aNames[nIndex]] := Nil
	Next nIndex

	aNames := Self:oDispRecur:getNames()
	nTotal := Len(aNames)

	For nIndex := 1 To nTotal
		If oPreRecs:hasProperty(aNames[nIndex]) == .F.
			Self:oDispRecur:delName(aNames[nIndex])
			Self:oIndcRecur:delName(aNames[nIndex])
		EndIf
	Next nIndex
	FreeObj(oPreRecs)

	//Remove controle das disponibilidades existentes antes da criação do backup
	Self:oBkpDisRec:delName("_RECURSOS_EXISTENTES_DISP_")

	Self:oOpersFina := JsonObject():New()
	Self:oOpersFina:fromJson(Self:oBkpDisRec["jsonFinalizacao"])
	Self:oBkpDisRec:delName("jsonFinalizacao")

	aNames := Self:oBkpDisRec:getNames()
	nTotal := Len(aNames)

	//Percorre JSON de backup que está separado por RECURSOS.
	For nIndex := 1 To nTotal
		cRecurso := aNames[nIndex]

		If Self:oDispRecur:hasProperty(cRecurso)
			//Sobrescreve valor de oDispRecur com o valor que está no objeto de backup e limpa a referência do backup
			aIndices := Self:oBkpDisRec[cRecurso]["disponibilidade"]:getNames()
			nTotIndc := Len(aIndices)

			aSize(Self:oDispRecur[cRecurso], Self:oBkpDisRec[cRecurso]["tamanhoOriginal"])

			For nIndIdc := 1 To nTotIndc
				nPos := Self:oBkpDisRec[cRecurso]["disponibilidade"][aIndices[nIndIdc]][1]
				Self:oDispRecur[cRecurso][nPos] := Self:oBkpDisRec[cRecurso]["disponibilidade"][aIndices[nIndIdc]][2]

				Self:oBkpDisRec[cRecurso]["disponibilidade"][aIndices[nIndIdc]][2] := Nil
				Self:oBkpDisRec[cRecurso]["disponibilidade"][aIndices[nIndIdc]]    := Nil
				Self:oBkpDisRec[cRecurso]["disponibilidade"]:delName(aIndices[nIndIdc])
			Next nIndIdc

			Self:oBkpDisRec[cRecurso]["disponibilidade"] := Nil
		EndIf

		//Remove do objeto de índices este recurso, e somente recria caso existia no momento da criação do backup
		Self:oIndcRecur:delName(cRecurso)
		If Self:oBkpDisRec[cRecurso]:hasProperty("indices")
			Self:oIndcRecur[cRecurso] := JsonObject():New()
			Self:oIndcRecur[cRecurso]:fromJson(Self:oBkpDisRec[cRecurso]["indices"])
		EndIf

		//Remove do objeto de índices com alocação este recurso, e somente recria caso existia no momento da criação do backup
		Self:oIndcCAloc:delName(cRecurso)
		If Self:oBkpDisRec[cRecurso]:hasProperty("indicesComAlocacao")
			Self:oIndcCAloc[cRecurso] := JsonObject():New()
			Self:oIndcCAloc[cRecurso]:fromJson(Self:oBkpDisRec[cRecurso]["indicesComAlocacao"])
		EndIf

		//Limpa backup
		Self:oBkpDisRec:delName(cRecurso)
	Next nIndex

Return

/*/{Protheus.doc} descartaBkpDisponibilidades
Descarta o backup da disponibilidade dos recursos.

@author lucas.franca
@since 26/03/2024
@version P12
@return Nil
/*/
Method descartaBkpDisponibilidades() Class PCPA152TempoOperacao

	FreeObj(Self:oBkpDisRec)
	Self:oBkpDisRec := JsonObject():New()

Return

/*/{Protheus.doc} getDisponibilidadeDistribuicao
Carrega a disponibilidade dos recursos que possuem ordens para alocação.
@author Lucas Fagundes
@since 09/07/2024
@version P12
@return Nil
/*/
Method getDisponibilidadeDistribuicao() Class PCPA152TempoOperacao
	Local aRecursos := {}
	Local cJson     := ""
	Local nIndRec   := 0
	Local nTotRec   := 0

	cJson := _Super:retornaValorGlobal("JSON_RECURSOS_ALOCACAO")
	Self:oRecsAloc:fromJson(cJson)

	aRecursos := Self:oRecsAloc:getNames()
	nTotRec   := Len(aRecursos)

	If nTotRec > 0
		For nIndRec := 1 To nTotRec
			Self:carregaDisponibilidadeRecurso(aRecursos[nIndRec])
		Next

		Self:gravaBackupDisponibilidades(aRecursos[1], 0)
	EndIf

	Self:oRecsAloc := JsonObject():New()
	aSize(aRecursos, 0)
Return Nil

/*/{Protheus.doc} getAlternativos
Busca os recursos alternativos de uma operação.
@author Lucas Fagundes
@since 02/09/2024
@version P12
@return Nil
/*/
Method getAlternativos() Class PCPA152TempoOperacao
	Local aAlternat  := {}
	Local aAlternats := {}
	Local cQuery     := ""
	Local cTempOper  := ""
	Local cAlias     := ""
	Local cChave     := ""
	Local lError     := .F.

	cChave := Self:oInfoOper["roteiro"] + Self:oInfoOper["produto"] + Self:oInfoOper["operacao"] + Self:oInfoOper["recurso"]

	aAlternats := _Super:retornaListaGlobal("ALTERNATIVOS", cChave, @lError)

	If lError
		If Self:oAlternativos == Nil
			cTempOper := _Super:retornaValorGlobal("TEMP_OPERACOES")

			cQuery := " SELECT SH3.H3_ORDEM ordem, "
			cQuery +=        " SH3.H3_RECALTE recurso, "
			cQuery +=        " SH3.H3_EFICIEN eficiencia, "
			cQuery +=        " CASE "
			cQuery +=            " WHEN TEMP.CTRAB = ' ' THEN SH1.H1_CTRAB "
			cQuery +=            " ELSE TEMP.CTRAB "
			cQuery +=        " END ctrab, "
			cQuery +=        " SH1.H1_MAOOBRA maoObra"
			cQuery +=   " FROM " + RetSqlName("SH3") + " SH3 "
			cQuery +=  " INNER JOIN " + cTempOper + " TEMP "
			cQuery +=     " ON TEMP.C2_OP    = ? "
			cQuery +=    " AND TEMP.OPERACAO = ? "
			cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
			cQuery +=     " ON SH1.H1_CODIGO  = SH3.H3_RECALTE "
			cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
			cQuery +=  " WHERE SH3.H3_FILIAL  = '" + xFilial("SH3") + "' "
			cQuery +=    " AND SH3.H3_CODIGO  =  ?  "
			cQuery +=    " AND SH3.H3_OPERAC  =  ?  "
			cQuery +=    " AND SH3.H3_PRODUTO =  ?  "
			cQuery +=    " AND (SH3.H3_USAALT = '" + USA_ALTERNATIVO + "' OR SH3.H3_USAALT = ' ') "
			If !Empty(Self:oParTempo["recursos"])
				cQuery += " AND SH3.H3_RECALTE IN " + inFilt(Self:oParTempo["recursos"])
			EndIf
			If !Empty(Self:oParTempo["centroTrabalho"])
				cQuery += " AND CASE "
				cQuery +=         " WHEN TEMP.CTRAB = ' ' THEN SH1.H1_CTRAB "
				cQuery +=         " ELSE TEMP.CTRAB "
				cQuery +=     " END IN " + inFilt(Self:oParTempo["centroTrabalho"])
			EndIf
			cQuery +=    " AND SH3.D_E_L_E_T_ = ' ' "
			cQuery +=  " UNION "
			cQuery += " SELECT SH2.H2_ORDEM ordem, "
			cQuery +=        " SH2.H2_RECALTE recurso, "
			cQuery +=        " 100 eficiencia, "
			cQuery +=        " CASE "
			cQuery +=            " WHEN TEMP.CTRAB = ' ' THEN SH1.H1_CTRAB "
			cQuery +=            " ELSE TEMP.CTRAB "
			cQuery +=        " END ctrab, "
			cQuery +=        " SH1.H1_MAOOBRA maoObra"
			cQuery +=   " FROM " + RetSqlName("SH2") + " SH2 "
			cQuery +=  " INNER JOIN " + cTempOper + " TEMP "
			cQuery +=     " ON TEMP.C2_OP    = ? "
			cQuery +=    " AND TEMP.OPERACAO = ? "
			cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
			cQuery +=     " ON SH1.H1_CODIGO  = SH2.H2_RECALTE "
			cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
			cQuery +=  " WHERE SH2.H2_FILIAL  = '" + xFilial("SH2") + "' "
			cQuery +=    " AND SH2.H2_RECPRIN = ? "
			cQuery +=    " AND NOT EXISTS (SELECT 1 "
			cQuery +=                      " FROM " + RetSqlName("SH3") + " SH3 "
			cQuery +=                     " WHERE SH3.H3_FILIAL  = '" + xFilial("SH3") + "' "
			cQuery +=                       " AND SH3.H3_CODIGO  =  ?   "
			cQuery +=                       " AND SH3.H3_OPERAC  =  ?   "
			cQuery +=                       " AND SH3.H3_PRODUTO =  ?   "
			cQuery +=                       " AND SH3.H3_FERRAM  = ' '  "
			cQuery +=                       " AND SH3.D_E_L_E_T_ = ' ') "
			If !Empty(Self:oParTempo["recursos"])
				cQuery += " AND SH2.H2_RECALTE IN " + inFilt(Self:oParTempo["recursos"])
			EndIf
			If !Empty(Self:oParTempo["centroTrabalho"])
				cQuery += " AND CASE "
				cQuery +=         " WHEN TEMP.CTRAB = ' ' THEN SH1.H1_CTRAB "
				cQuery +=         " ELSE TEMP.CTRAB "
				cQuery +=     " END IN " + inFilt(Self:oParTempo["centroTrabalho"])
			EndIf
			cQuery +=    " AND SH2.D_E_L_E_T_ = ' ' "
			cQuery +=  " ORDER BY ordem "

			Self:oAlternativos := FwExecStatement():New(cQuery)
		EndIf

		Self:oAlternativos:setString( 1, Self:oInfoOper["ordemProducao"]) // TEMP.C2_OP
		Self:oAlternativos:setString( 2, Self:oInfoOper["operacao"     ]) // TEMP.OPERACAO
		Self:oAlternativos:setString( 3, Self:oInfoOper["roteiro"      ]) // SH3.H3_CODIGO
		Self:oAlternativos:setString( 4, Self:oInfoOper["operacao"     ]) // SH3.H3_OPERAC
		Self:oAlternativos:setString( 5, Self:oInfoOper["produto"      ]) // SH3.H3_PRODUTO
		Self:oAlternativos:setString( 6, Self:oInfoOper["ordemProducao"]) // TEMP.C2_OP
		Self:oAlternativos:setString( 7, Self:oInfoOper["operacao"     ]) // TEMP.OPERACAO
		Self:oAlternativos:setString( 8, Self:oInfoOper["recurso"      ]) // SH2.H2_RECPRIN
		Self:oAlternativos:setString( 9, Self:oInfoOper["roteiro"      ]) // SH3.H3_CODIGO
		Self:oAlternativos:setString(10, Self:oInfoOper["operacao"     ]) // SH3.H3_OPERAC
		Self:oAlternativos:setString(11, Self:oInfoOper["produto"      ]) // SH3.H3_PRODUTO

		cAlias := Self:oAlternativos:openAlias()

		While (cAlias)->(!EoF())
			aAlternat := Array(ALTERNATIVOS_TAMANHO)

			aAlternat[ALTERNATIVOS_CODIGO    ] := (cAlias)->recurso
			aAlternat[ALTERNATIVOS_CTRAB     ] := (cAlias)->ctrab
			aAlternat[ALTERNATIVOS_EFICIENCIA] := (cAlias)->eficiencia
			aAlternat[ALTERNATIVOS_MAOOBRA   ] := (cAlias)->maoObra

			aAdd(aAlternats, aAlternat)

			(cAlias)->(dbSkip())
		End
		(cAlias)->(dbCloseArea())

		_Super:adicionaListaGlobal("ALTERNATIVOS", cChave, aAlternats, .F.)
	EndIf

Return aAlternats

/*/{Protheus.doc} getRecursosOperacao
Adiciona os dados de recursos principal/alternativos na global.
@author Lucas Fagundes
@since 05/09/2024
@version P12
@param aOperacao, Array, Operação que ira buscar os recursos.
@return aDadosHZ7, Array, Array com os recursos da operação.
/*/
Method getRecursosOperacao(aOperacao) Class PCPA152TempoOperacao
	Local aAlternats := {}
	Local aDadosHZ7  := {}
	Local aInfoHZ7   := Array(ARRAY_HZ7_TAMANHO)
	Local aLog       := {}
	Local cFilHZ7    := xFilial("HZ7")
	Local cSeq       := Self:getSequenciaRecursoPrincipal()
	Local lLog       := Self:oLogs:logAtivo()
	Local nIndex     := 0
	Local nTotal     := 0

	If lLog
		aAdd(aLog, "------- Carregando recursos da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " -------")
	EndIf

	aInfoHZ7[ARRAY_HZ7_FILIAL] := cFilHZ7
	aInfoHZ7[ARRAY_HZ7_PROG  ] := Self:cProg
	aInfoHZ7[ARRAY_HZ7_ID    ] := aOperacao[ARRAY_MF_ID]
	aInfoHZ7[ARRAY_HZ7_SEQ   ] := cSeq
	aInfoHZ7[ARRAY_HZ7_RECURS] := aOperacao[ARRAY_MF_RECURSO]
	aInfoHZ7[ARRAY_HZ7_CTRAB ] := aOperacao[ARRAY_MF_CTRAB]
	aInfoHZ7[ARRAY_HZ7_EFICIE] := 100
	aInfoHZ7[ARRAY_HZ7_MAOOBR] := Self:oInfoOper["maoDeObra"]
	aInfoHZ7[ARRAY_HZ7_TEMPOR] := 0
	aInfoHZ7[ARRAY_HZ7_TEMPRE] := 0

	If lLog
		aAdd(aLog, "Recurso: " + aInfoHZ7[ARRAY_HZ7_RECURS] + " - Centro de trabalho: " + aInfoHZ7[ARRAY_HZ7_CTRAB] + " - Alternativo: Nao")
	EndIf

	aAdd(aDadosHZ7, aInfoHZ7)

	If Self:oInfoOper["usaAlternativo"]
		aAlternats := Self:getAlternativos()
		nTotal     := Len(aAlternats)

		For nIndex := 1 To nTotal
			aInfoHZ7 := Array(ARRAY_HZ7_TAMANHO)
			cSeq := Soma1(cSeq)

			aInfoHZ7[ARRAY_HZ7_FILIAL] := cFilHZ7
			aInfoHZ7[ARRAY_HZ7_PROG  ] := Self:cProg
			aInfoHZ7[ARRAY_HZ7_ID    ] := aOperacao[ARRAY_MF_ID]
			aInfoHZ7[ARRAY_HZ7_SEQ   ] := cSeq
			aInfoHZ7[ARRAY_HZ7_RECURS] := aAlternats[nIndex][ALTERNATIVOS_CODIGO    ]
			aInfoHZ7[ARRAY_HZ7_CTRAB ] := aAlternats[nIndex][ALTERNATIVOS_CTRAB     ]
			aInfoHZ7[ARRAY_HZ7_EFICIE] := aAlternats[nIndex][ALTERNATIVOS_EFICIENCIA]
			aInfoHZ7[ARRAY_HZ7_MAOOBR] := aAlternats[nIndex][ALTERNATIVOS_MAOOBRA   ]
			aInfoHZ7[ARRAY_HZ7_TEMPOR] := 0
			aInfoHZ7[ARRAY_HZ7_TEMPRE] := 0

			aAdd(aDadosHZ7, aInfoHZ7)

			If lLog
				aAdd(aLog, "Recurso: " + aInfoHZ7[ARRAY_HZ7_RECURS] + " - Centro de trabalho: " + aInfoHZ7[ARRAY_HZ7_CTRAB] + " - Alternativo: Sim")
			EndIf
		Next
	EndIf

	If lLog
		aAdd(aLog, Replicate("-", 70))
		Self:oLogs:gravaLog(CHAR_ETAPAS_CALC_TEMP, aLog, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], Nil, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
	EndIf

Return aDadosHZ7

/*/{Protheus.doc} carregaRecursosOperacao
Carrega os recursos de uma operação.
@author Lucas Fagundes
@since 06/09/2024
@version P12
@param aOperacao, Array, Array com as informações da operação
@return Nil
/*/
Method carregaRecursosOperacao(aOperacao) Class PCPA152TempoOperacao
	Local aRecurso  := {}
	Local aRecursos := {}
	Local cAlias    := ""
	Local cQuery    := ""

	If !Self:oParTempo["dicionarioAlternativo"]
		aRecurso := Array(ARRAY_HZ7_TAMANHO)

		aRecurso[ARRAY_HZ7_FILIAL] := Nil
		aRecurso[ARRAY_HZ7_PROG  ] := aOperacao[ARRAY_MF_PROG]
		aRecurso[ARRAY_HZ7_ID    ] := aOperacao[ARRAY_MF_ID]
		aRecurso[ARRAY_HZ7_SEQ   ] := Self:getSequenciaRecursoPrincipal()
		aRecurso[ARRAY_HZ7_RECURS] := aOperacao[ARRAY_MF_RECURSO]
		aRecurso[ARRAY_HZ7_CTRAB ] := aOperacao[ARRAY_MF_CTRAB]
		aRecurso[ARRAY_HZ7_EFICIE] := 100
		aRecurso[ARRAY_HZ7_TEMPOR] := aOperacao[ARRAY_MF_TEMPO]
		aRecurso[ARRAY_HZ7_TEMPRE] := aOperacao[ARRAY_MF_TEMPO]

		SH1->(dbSetOrder(1))
		SH1->(dbSeek(xFilial("SH1")+aOperacao[ARRAY_MF_RECURSO]))
		aRecurso[ARRAY_HZ7_MAOOBR] := SH1->H1_MAOOBRA

		aAdd(aRecursos, aRecurso)

		aOperacao[ARRAY_PROC_USA_ALTERNATIVOS] := .F.
		aOperacao[ARRAY_PROC_RECURSOS        ] := aRecursos

		Return
	EndIf

	If Self:oAlternativos == Nil
		cQuery := " SELECT HZ7.HZ7_FILIAL, "
		cQuery +=        " HZ7.HZ7_PROG,   "
		cQuery +=        " HZ7.HZ7_ID,     "
		cQuery +=        " HZ7.HZ7_SEQ,    "
		cQuery +=        " HZ7.HZ7_RECURS, "
		cQuery +=        " HZ7.HZ7_CTRAB,  "
		cQuery +=        " HZ7.HZ7_EFICIE, "
		cQuery +=        " HZ7.HZ7_MAOOBR, "
		cQuery +=        " HZ7.HZ7_TEMPOR, "
		cQuery +=        " HZ7.HZ7_TEMPRE  "
		cQuery +=   " FROM " + RetSqlName("HZ7") + " HZ7 "
		cQuery +=  " WHERE HZ7.HZ7_FILIAL = '" + xFilial("HZ7") + "' "
		cQuery +=    " AND HZ7.HZ7_PROG   = '" + Self:cProg     + "' "
		cQuery +=    " AND HZ7.HZ7_ID     =  ?  "
		cQuery +=    " AND HZ7.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY HZ7.HZ7_SEQ "

		Self:oAlternativos := FwExecStatement():New(cQuery)
	EndIf

	Self:oAlternativos:setString(1, aOperacao[ARRAY_MF_ID])

	cAlias := Self:oAlternativos:openAlias()

	While (cAlias)->(!EoF())
		aRecurso := Array(ARRAY_HZ7_TAMANHO)

		aRecurso[ARRAY_HZ7_FILIAL] := (cAlias)->HZ7_FILIAL
		aRecurso[ARRAY_HZ7_PROG  ] := (cAlias)->HZ7_PROG
		aRecurso[ARRAY_HZ7_ID    ] := (cAlias)->HZ7_ID
		aRecurso[ARRAY_HZ7_SEQ   ] := (cAlias)->HZ7_SEQ
		aRecurso[ARRAY_HZ7_RECURS] := (cAlias)->HZ7_RECURS
		aRecurso[ARRAY_HZ7_CTRAB ] := (cAlias)->HZ7_CTRAB
		aRecurso[ARRAY_HZ7_EFICIE] := (cAlias)->HZ7_EFICIE
		aRecurso[ARRAY_HZ7_MAOOBR] := (cAlias)->HZ7_MAOOBR
		aRecurso[ARRAY_HZ7_TEMPOR] := (cAlias)->HZ7_TEMPOR
		aRecurso[ARRAY_HZ7_TEMPRE] := (cAlias)->HZ7_TEMPRE

		aAdd(aRecursos, aRecurso)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	aOperacao[ARRAY_PROC_USA_ALTERNATIVOS] := Len(aRecursos) > 1
	aOperacao[ARRAY_PROC_RECURSOS        ] := aRecursos

	aRecurso  := {}
	aRecursos := {}
Return Nil

/*/{Protheus.doc} getOperacao
Retorna as informações de uma operação.
@author Lucas Fagundes
@since 13/09/2024
@version P12
@param 01 cOrdem, Caracter, Ordem de produção da operação.
@param 02 cId   , Caracter, Id da operação.
@return aOperacao, Array, Array com as informações da operação.
/*/
Method getOperacao(cOrdem, cId) Class PCPA152TempoOperacao
	Local aOperacao  := {}
	Local aOperacoes := {}
	Local nPos       := 0

	If !Self:oCacheOper:hasProperty(cId)
		aOperacoes := Self:getOperacoesOrdem(cOrdem, .F.)

		nPos := aScan(aOperacoes, {|x| x[ARRAY_MF_ID] == cId})

		If nPos > 0
			Self:oCacheOper[cId] := aOperacoes[nPos]
		EndIf

		aSize(aOperacoes, 0)
	EndIf

	aOperacao := Self:oCacheOper[cId]

Return aOperacao

/*/{Protheus.doc} getIndicesComAlocacao
Retorna o json com os indices que possuem alocação.
@author Lucas Fagundes
@since 16/09/2024
@version P12
@param cRecurso, Caracter, Código do recurso
@return oJson, Object, Json com os indices alocados.
/*/
Method getIndicesComAlocacao(cRecurso) Class PCPA152TempoOperacao
	Local oJson := Nil
	Local oDisp := Nil

	If !Self:oIndcCAloc:hasProperty(cRecurso) .And. _Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
		Self:oIndcCAloc[cRecurso] := oDisp:getJsonEfetivados(cRecurso, .F.)
	EndIf
	oJson := Self:oIndcCAloc[cRecurso]

Return oJson

/*/{Protheus.doc} setIndicesComAlocacao
Atualiza o json com os indices que possuem alocação.
@author Lucas Fagundes
@since 16/09/2024
@version P12
@param 01 cRecurso, Caracter, Código do recurso
@param 02 oJson   , Object  , Json com os novos indices com alocação.
@return Nil
/*/
Method setIndicesComAlocacao(cRecurso, oJson) Class PCPA152TempoOperacao

	Self:oIndcCAloc[cRecurso] := oJson

Return Nil

/*/{Protheus.doc} tempoRecursos
Calcula o tempo da operação em cada recurso.
@author Lucas Fagundes
@since 19/09/2024
@version P12
@param aOperacao, Array, Array com as informações da operação.
@return Nil
/*/
Method tempoRecursos(aOperacao) Class PCPA152TempoOperacao
	Local aRecursos  := aOperacao[ARRAY_PROC_RECURSOS]
	Local nIndex     := 0
	Local nTempoOper := 0
	Local nTotal     := Len(aRecursos)
	Local nTpOpeCalc := 0

	nTpOpeCalc := __Hrs2Min(Self:oInfoOper["tempoOperacao"])
	nTempoOper := __Hrs2Min(Self:arredondaHora(Self:oInfoOper["tempoOperacao"]))

	For nIndex := 1 To nTotal
		nTempo := Self:aplicaMaoDeObra(aOperacao, nTpOpeCalc, aRecursos[nIndex][ARRAY_HZ7_MAOOBR])

		If (nTempo - Int(nTempo)) > 0
			nTempo := Int(nTempo) + 1
		EndIf

		aRecursos[nIndex][ARRAY_HZ7_TEMPOR] := nTempoOper
		aRecursos[nIndex][ARRAY_HZ7_TEMPRE] := nTempo
	Next

Return Nil

/*/{Protheus.doc} aplicaMaoDeObra
Aplica o valor da mão de obra no tempo da operação.
@author Lucas Fagundes
@since 19/09/2024
@version P12
@param 01 aOperacao, Array   , Operação que está aplicando a mão de obra.
@param 02 nTempo   , Numerico, Tempo da operação.
@param 03 nMaoObra , Numerico, Mão de obra do recurso.
@return nTempo, Numerico, Tempo da operação com a mão de obra aplicada.
/*/
Method aplicaMaoDeObra(aOperacao, nTempo, nMaoObra) Class PCPA152TempoOperacao

	If Empty(nMaoObra) .Or. !Self:oParTempo["dicionarioAlternativo"]
		Return nTempo
	EndIf

	If aOperacao[ARRAY_MF_TPOPER] == TIPO_OPERACAO_NORMAL .Or.;
	   aOperacao[ARRAY_MF_TPOPER] == TIPO_OPERACAO_TEMPO_MINIMO
		nTempo := nTempo / nMaoObra
	EndIf

Return nTempo

/*/{Protheus.doc} calcTempoAlocacao
Calcula o tempo que a operação deve alocar no recurso.
@author Lucas Fagundes
@since 19/09/2024
@version P12
@param 01 aOperacao, Array, Array com as informações da operação.
@param 02 cRecurso , Array, Recurso que a operação será alocada.
@return nTempo, Numerico, Tempo da operação no recurso.
/*/
Method calcTempoAlocacao(aOperacao, cRecurso) Class PCPA152TempoOperacao
	Local nTempo  := 0
	Local nPosRec := 0
	Local aRecursos := aOperacao[ARRAY_PROC_RECURSOS]

	nPosRec := aScan(aRecursos, {|rec| rec[ARRAY_HZ7_RECURS] == cRecurso})
	If nPosRec > 0
		nTempo := aRecursos[nPosRec][ARRAY_HZ7_TEMPRE]
		nTempo += Self:getTempoFinalizacao(aOperacao, cRecurso)
	EndIf

Return nTempo

/*/{Protheus.doc} addIndiceAlocado
Adiciona um indice no json de indices alocados.
@author Lucas Fagundes
@since 23/09/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que está sendo feita a alocação.
@param 02 nIndice , Numerico, Indice que está sendo feita a alocação.
@return Nil
/*/
Method addIndiceAlocado(cRecurso, nIndice) Class PCPA152TempoOperacao
	Local cIndice    := cValToChar(nIndice)
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	If !oAlocacoes:hasProperty(cIndice)
		oAlocacoes[cIndice] := .T.

		aAdd(oAlocacoes["indices"], nIndice)

		aSort(oAlocacoes["indices"],,,{|x, y| x < y})
	EndIf

	oAlocacoes := Nil
Return Nil

/*/{Protheus.doc} removeIndiceAlocado
Remove um indice do json de indices com alocação.
@author Lucas Fagundes
@since 23/09/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que está removendo a alocação.
@param 02 nIndice , Numerico, Indice que está sendo removido a alocação.
@return Nil
/*/
Method removeIndiceAlocado(cRecurso, nIndice) Class PCPA152TempoOperacao
	Local aTempos    := Self:oDispRecur[cRecurso][nIndice][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
	Local cIndice    := cValToChar(nIndice)
	Local nPos       := 0
	Local oAlocacoes := Self:getIndicesComAlocacao(cRecurso)

	nPos := aScan(aTempos, {|aTmp| aTmp[ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL})
	If nPos == 0 .And. oAlocacoes:hasProperty(cIndice)
		nPos := aScan(oAlocacoes["indices"], {|nIndc| nIndc == nIndice})

		oAlocacoes:delName(cIndice)

		aDel(oAlocacoes["indices"], nPos)
		aSize(oAlocacoes["indices"], Len(oAlocacoes["indices"])-1)
	EndIf

	oAlocacoes := Nil
Return Nil

/*/{Protheus.doc} getSequenciaRecursoPrincipal
Retorna a sequência da HZ7 utilizada para o recurso principal (0000)
@author Lucas Fagundes
@since 07/10/2024
@version P12
@return cSeq, Caracter, Sequencia do recurso principal
/*/
Method getSequenciaRecursoPrincipal() Class PCPA152TempoOperacao
	Local cSeq := ""
	Local nTam := 4

	If _cSeqPrinc == Nil
		If AliasInDic("HZ7")
			nTam := GetSx3Cache("HZ7_SEQ", "X3_TAMANHO")
		EndIf

		_cSeqPrinc := PadL(0, nTam, "0")
	EndIf

	cSeq := _cSeqPrinc

Return cSeq

/*/{Protheus.doc} tempoSobreposicao
Calcula o tempo de sobreposição de uma operação.
@author Lucas Fagundes
@since 22/10/2024
@version P12
@param 01 cTipoSobre, Caracter, Tipo de sobreposição (SOBREPOSICAO_POR_TEMPO, SOBREPOSICAO_POR_QUANTIDADE, SOBREPOSICAO_POR_PERCENTUAL).
@param 02 nTempoSob , Numerico, Valor definido para sobreposição, sendo: Sobreposição por tempo - Tempo de produção da operação anterior para inicio com sobreposição.
                                                                         Sobreposição por quantidade - Desconsidera. Quando for sobreposição por quantidade irá iniciar após finalizar a primeira unidade da operação anterior.
                                                                         Sobreposição por percentual - Percentual da operação anterior que deve ser produzido para inicio com sobreposição.
@param 03 aOperAnt  , Array   , Array com as informações da operação anterior.
@param 04 cRecAnt   , Caracter, Recurso que a operação anterior foi alocada.
@return nSobrepos, Numerico, Tempo de sobreposição da operação em minutos.
/*/
Method tempoSobreposicao(cTipoSobre, nTempoSob, aOperAnt, cRecAnt) Class PCPA152TempoOperacao
	Local nSobrepos := 0
	Local nPosRec   := 0
	Local nTempoAnt := 0

	If cTipoSobre != SOBREPOSICAO_POR_TEMPO
		nPosRec   := aScan(aOperAnt[ARRAY_PROC_RECURSOS], {|x| x[ARRAY_HZ7_RECURS] == cRecAnt})
		nTempoAnt := aOperAnt[ARRAY_PROC_RECURSOS][nPosRec][ARRAY_HZ7_TEMPRE]
	EndIf

	If cTipoSobre == SOBREPOSICAO_POR_TEMPO
		nSobrepos := nTempoSob

		If Self:oParTempo["MV_TPHR"] == "C"
			nSobrepos := Self:horasCentesimaisParaNormais(nSobrepos, .F.)
		EndIf

		nSobrepos := __Hrs2Min(nSobrepos)
	ElseIf cTipoSobre == SOBREPOSICAO_POR_QUANTIDADE
		nSobrepos  := (nTempoAnt / aOperAnt[ARRAY_MF_SALDO])

	ElseIf cTipoSobre == SOBREPOSICAO_POR_PERCENTUAL
		nSobrepos := (nTempoSob / 100) * nTempoAnt

	EndIf

	If (nSobrepos - Int(nSobrepos)) > 0
		nSobrepos := Int(nSobrepos) + 1
	EndIf

Return nSobrepos

/*/{Protheus.doc} alocaComSobreposicao
Verifica se uma operação aloca com sobreposição em relação a ultima operação alocada.

@author Lucas Fagundes
@since 23/10/2024
@version P12
@param 01 aOperacao, Array   , Operação que será verificada.
@param 02 lEntrega , Lógico  , Indica se a operação aloca por data de entrega.
@param 03 cRecurso , Caracter, Recurso que a operação será alocada.
@return lAlocSob, Logico, Indica se a operação pode ser alocada com sobreposição.
/*/
Method alocaComSobreposicao(aOperacao, lEntrega, cRecurso) Class PCPA152TempoOperacao
	Local aOperSob := {}
	Local aOperAnt := {}
	Local lAlocSob := .F.
	Local cRecAnt  := ""
	Local cRecSob  := ""

	If Len(Self:aAlocados) > 0

		If lEntrega
			aOperAnt := aOperacao
			cRecAnt  := cRecurso
			aOperSob := Self:getUltimaOperacaoAlocada(@cRecSob)
		Else
			aOperAnt := Self:getUltimaOperacaoAlocada(@cRecAnt)
			aOperSob := aOperacao
			cRecSob  := cRecurso
		EndIf

		// Não aloca com sobreposição se:
		// 1- O oparâmetro quebraOperacoes estiver ativado;
		// 2- For a primeira operação da ordem;
		// 3- A operação com sobreposição for alocada no mesmo recurso que a operação anterior.
		If Self:oParTempo["quebraOperacoes"] .Or. aOperAnt[ARRAY_MF_OP] != aOperSob[ARRAY_MF_OP] .Or. cRecAnt == cRecSob
			Return lAlocSob
		EndIf

		lAlocSob := aOperSob[ARRAY_MF_TEMPSOB] > 0

		If lAlocSob
			lAlocSob := Self:validaTempoSobreposicao(aOperSob, aOperAnt, cRecAnt, lEntrega)
		EndIf

		aOperSob := {}
		aOperAnt := {}
	EndIf

Return lAlocSob

/*/{Protheus.doc} getDataSobreposicao
Calcula a data e hora de inicio de uma operacao com base no tempo de sobreposicao com a ultima operação alocada.

@author Lucas Fagundes
@since 22/10/2024
@version P12
@param 01 aOperacao, Array   , Operação que esta sendo alocada.
@param 02 aAloAnt  , Array   , Array com as informações da operação que nivelou antes da operação atual.
@param 03 lEntrega , Lógico  , Indica se a operação será alocada por data de entrega.
@param 04 cRecurso , Caracter, Recurso que a operação será alocada.
@param 05 aRet     , Lógico  , Array que irá retornar as informações de hora e data da alocação com sobreposição.
/*/
Method getDataSobreposicao(aOperacao, aAloAnt, lEntrega, cRecurso, aRet) Class PCPA152TempoOperacao
	Local aAlocAux   := aAloAnt[ALOCADOS_POS_PERIODOS]
	Local aOperAux   := aAloAnt[ALOCADOS_POS_OPERACAO]
	Local aPeriodo   := {}
	Local dData      := Nil
	Local nHora      := 0
	Local nIndAloc   := 0
	Local nTempoAloc := 0
	Local nTotAloc   := Len(aAlocAux)
	Local nTpParalel := 0
	Local nTpToStart := 0
	Local nTempoSob  := 0

	If lEntrega
		If aOperAux[ARRAY_MF_TPSOBRE] != SOBREPOSICAO_POR_TEMPO
			nTempoSob := Self:tempoSobreposicao(aOperAux[ARRAY_MF_TPSOBRE], aOperAux[ARRAY_MF_TEMPSOB], aOperacao, cRecurso)
		Else
			nTempoSob := aOperAux[ARRAY_MF_SOBREPO]
		EndIf

		If aOperacao[ARRAY_MF_REMOCAO] > nTempoSob
			Self:oLogs:gravaLog(Self:cEtapaLog, {"Tempo de remocao da operacao " + aOperacao[ARRAY_MF_OPER] + " (" + __Min2Hrs(aOperacao[ARRAY_MF_REMOCAO], .T.) +;
			                                     ") e maior que o tempo de sobreposicao da operacao " + aOperAux[ARRAY_MF_OPER] + "(" + __Min2Hrs(nTempoSob, .T.) + "). Sera considerado o tempo de remocao como tempo de sobreposicao." },;
			                                     aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			nTempoSob := aOperacao[ARRAY_MF_REMOCAO]
		EndIf

		nTempoAloc := Self:calcTempoAlocacao(aOperacao, cRecurso)
		nTpParalel := nTempoAloc - nTempoSob

		For nIndAloc := 1 To nTotAloc
			aPeriodo := aAlocAux[nIndAloc]

			If aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO] < nTpParalel
				nTpParalel -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]

			ElseIf aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO] > nTpParalel
				nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO] + nTpParalel
				dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
				nTpParalel := 0

			Else
				nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM]
				dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
				nTpParalel := 0

			EndIf

			If nTpParalel == 0
				Exit
			EndIf
		Next
	Else
		nTpToStart := aOperacao[ARRAY_MF_SOBREPO]

		If aOperAux[ARRAY_MF_REMOCAO] > nTpToStart
			Self:oLogs:gravaLog(Self:cEtapaLog, {"Tempo de remocao da operacao " + aOperAux[ARRAY_MF_OPER] + " (" + __Min2Hrs(aOperAux[ARRAY_MF_REMOCAO], .T.) +;
			                                     ") e maior que o tempo de sobreposicao da operacao " + aOperacao[ARRAY_MF_OPER] + "(" + __Min2Hrs(nTpToStart, .T.) + "). Sera considerado o tempo de remocao como tempo de sobreposicao." },;
			                                     aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
			nTpToStart := aOperAux[ARRAY_MF_REMOCAO]
		EndIf

		For nIndAloc := 1 To nTotAloc
			aPeriodo := aAlocAux[nIndAloc]

			If aPeriodo[ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_SETUP
				If nTpToStart > aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]
					nTpToStart -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]

				ElseIf nTpToStart < aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]
					nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_INICIO] + nTpToStart
					dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
					nTpToStart := 0

				ElseIf nTpToStart == aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]
					nHora := aPeriodo[ARRAY_DISPONIBILIDADE_HORA_FIM]
					dData := aPeriodo[ARRAY_DISPONIBILIDADE_DATA]
					nTpToStart := 0

				EndIf
			EndIf

			If nTpToStart == 0
				Exit
			EndIf
		Next
	EndIf

	aRet[RET_GET_DATA_JUNTO] := .F.
	If nTpParalel > 0
		aRet[RET_GET_DATA_JUNTO] := .T.

		Self:oLogs:gravaLog(Self:cEtapaLog, {"Calculo do inicio da sobreposicao: Tempo de producao da operacao com sobreposicao menor que o tempo da operacao que sera alocada." +;
		                                     " Alocando operacao para finalizar junto da operacao com sobreposicao"},;
		                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

		dData := aTail(aAlocAux)[ARRAY_DISPONIBILIDADE_DATA]
		nHora := aTail(aAlocAux)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	EndIf

	aRet[RET_GET_DATA_SOBREPOE   ] := .T.
	aRet[RET_GET_DATA_DATA_SOBRE ] := dData
	aRet[RET_GET_DATA_HORA_SOBRE ] := nHora
	aRet[RET_GET_DATA_FIM_AUX_DATA] := aTail(aAlocAux)[ARRAY_DISPONIBILIDADE_DATA]
	aRet[RET_GET_DATA_FIM_AUX_HORA] := aTail(aAlocAux)[ARRAY_DISPONIBILIDADE_HORA_FIM]

Return

/*/{Protheus.doc} alocaOperacao
Realiza a alocação de uma operação durante a etapa de distribuição.

@author Lucas Fagundes
@since 29/10/2024
@version P12
@param 01 aOperacao, Array , Operação que está sendo alocada
@param 02 lEntrega , Lógico, Indica se a alocação será pela data de entrega.
@param 03 aGetData , Array , Array com as informações de inicio da alocação.
@param 04 lOperDist, Lógico, Retorna por referência se a operação foi totalmente alocada.
@param 05 lDispAdc , Lógico, Indica se pode gerar disponibilidade adicional durante a alocação.
@param 06 lAlocPost, Lógico, Retorna por referência se alocou em data posterior a data final do CRP.
@param 07 lRetCria , Lógico, Retorna por referência se gerou disponibilidade adicional.
@return aPeriodos, Array, Array com os periodos que a operação foi alocada.
/*/
Method alocaOperacao(aOperacao, lEntrega, aGetData, lOperDist, lDispAdc, lAlocPost, lRetCria) Class PCPA152TempoOperacao
	Local aFerramenta := {}
	Local cRecurso    := aOperacao[ARRAY_MF_RECURSO]
	Local dData       := Nil
	Local lEntJunto   := .F.
	Local nHora       := 0
	Local oBackup     := Nil

	If Len(aOperacao[ARRAY_PROC_FERRAMENTAS]) > 0
		aFerramenta := aOperacao[ARRAY_PROC_FERRAMENTAS][1][ARRAY_FERRAM_FERRAMENTAS] // Ainda não considera ferramentas alternativas.
	EndIf

	If aGetData[RET_GET_DATA_SOBREPOE]
		dData := aGetData[RET_GET_DATA_DATA_SOBRE]
		nHora := aGetData[RET_GET_DATA_HORA_SOBRE]
		oBackup := JsonObject():New()

		oBackup["dispRecur"] := aClone(Self:oDispRecur[cRecurso])
		oBackup["indices"  ] := Self:getJsonIndicesRecurso(cRecurso):toJson()
		oBackup["indcAloc" ] := Self:getIndicesComAlocacao(cRecurso):toJson()

		aPeriodos := Self:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lOperDist, lDispAdc, @lAlocPost, @lRetCria, cRecurso, .F., aFerramenta)

		Self:avaliaSobreposicao(aOperacao, aGetData, lEntrega, @aPeriodos, dData, nHora, @lOperDist, lDispAdc, cRecurso, oBackup["dispRecur"], oBackup["indices"], oBackup["indcAloc"], @lAlocPost, @lRetCria, .F., @lEntJunto, aFerramenta)
	Else
		dData := aGetData[RET_GET_DATA_DATA]
		nHora := aGetData[RET_GET_DATA_HORA]

		aPeriodos := Self:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lOperDist, lDispAdc, @lAlocPost, @lRetCria, cRecurso, .F., aFerramenta)
	EndIf

	Self:posAlocacaoAtualizaSobreposicao(aOperacao, cRecurso, lEntrega)

	If lOperDist
		Self:validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto, .F., dData, nHora)
	EndIf

Return aPeriodos

/*/{Protheus.doc} preparaParaAlocacao
Prepara a classe para simular as alocações.
@author Lucas Fagundes
@since 16/09/2024
@version P12
@param 01 cRecurso   , Caracter, Recurso que irá simular a alocação da operação.
@param 02 aDispRecur , Array   , Disponibilidade do recurso que irá simular a alocação.
@param 03 cIndices   , Caracter, Indices da disponibilidade do recurso que irá simular a alocação.
@param 04 cIndcAloc  , Caracter, Indices que possuem alocações na disponibilidade do recurso.
@param 05 cEtapa     , Caracter, Etapa que está sendo executada a alocação.
@param 06 cJsFerram  , Caracter, Json com as utilizações das ferramentas.
@return Nil
/*/
Method preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, cEtapa, cJsFerram) Class PCPA152TempoOperacao
	Local oJsonAux := Nil

	If cEtapa != Nil
		Self:cEtapaLog := cEtapa
		Self:lRedSetup := cEtapa == CHAR_ETAPAS_REDUZ_SETUP
	EndIf
	Self:lBkpDisp  := .F.
	Self:oDispRecur[cRecurso] := aClone(aDispRecur)

	oJsonAux := JsonObject():New()
	oJsonAux:fromJson(cIndices)
	Self:setJsonIndicesRecurso(cRecurso, oJsonAux)

	oJsonAux := JsonObject():New()
	oJsonAux:fromJson(cIndcAloc)
	Self:setIndicesComAlocacao(cRecurso, oJsonAux)

	Self:oFerramentas:setJsonUtilizacao(cJsFerram)

	oJsonAux := Nil
Return

/*/{Protheus.doc} avaliaSobreposicao
Avalia a sobreposição na alocação da operação e realoca se for necessario.
Realocações: 1- Se a operação finalizou antes da operação anterior, realoca finalizando junto da operação anterior.
             2- Se não conseguiu finalizar as operações juntas, devido a falta de disponibilidade ou o recurso já estar alocada, realoca a operação após a operação anterior.
			 3- Se estiver reduzindo setup e a operação e alocou com entrega depois da planeja no nivelamento, realoca encerrando na data planejada no nivelamento.

@author Lucas Fagundes
@since 23/10/2024
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
@param 13 lAlocPost  , Lógico  , Indica se realizou alocação em data posterior a data limite do CRP (retorna por referencia valor atualizado, caso realocou a operação).
@param 14 lRetCria   , Lógico  , Indica se criou disponibilidade adicional (retorna por referencia valor atualizado, caso realocou a operação).
@param 15 lSimula    , Lógico  , Indica que está simulando a alocação da operação.
@param 16 lEntJunto  , Lógico  , Retorna por referência se precisou realocar a operação para entregar junto da operação anterior.
@param 17 aFerramenta, Array   , Ferramentas utilizadas na alocação da operação.
@param 18 cJsFerram  , Caracter, Json com a utilização das ferramentas.
@return Nil
/*/
Method avaliaSobreposicao(aOperacao, aDatas, lEntrega, aPeriodos, dData, nHora, lDistTudo, lGeraAdc, cRecurso, aDispRecur, cIndices, cIndcAloc, lAlocPost, lRetCria, lSimula, lEntJunto, aFerramenta, cJsFerram) Class PCPA152TempoOperacao
	Local dFimMaior := Nil
	Local dFimMenor := Nil
	Local lBkpEnt   := lEntrega
	Local lRealoca  := .F.
	Local nFimMaior := 0
	Local nFimMenor := 0
	Local nTamPer   := 0

	Self:oLogs:gravaLog(Self:cEtapaLog, {" ---- Avaliando a sobreposicao na alocacao da operacao " + aOperacao[ARRAY_MF_OPER] + " da ordem " + aOperacao[ARRAY_MF_OP] + " ---- "},;
	                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

	nTamPer  := Len(aPeriodos)
	If nTamPer == 0
		lRealoca := .T.
	Else
		If lEntrega
			dFimMaior := aDatas[RET_GET_DATA_FIM_AUX_DATA]
			nFimMaior := aDatas[RET_GET_DATA_FIM_AUX_HORA]

			dFimMenor := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
			nFimMenor := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]
		Else
			dFimMenor := aDatas[RET_GET_DATA_FIM_AUX_DATA]
			nFimMenor := aDatas[RET_GET_DATA_FIM_AUX_HORA]

			dFimMaior := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
			nFimMaior := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]
		EndIf

		lRealoca := dFimMenor > dFimMaior .Or. (dFimMenor == dFimMaior .And. nFimMenor > nFimMaior)
	EndIf

	lEntJunto := aDatas[RET_GET_DATA_JUNTO]
	If lRealoca
		If Self:oLogs:logAtivo()
			Self:oLogs:gravaLog(Self:cEtapaLog, {Iif(nTamPer == 0, "Operacao nao foi alocada.", "Operacao terminou antes da operacao anterior." +;
			                                     " Finalizacao operacao anterior: "  + DToC(dFimMenor) + ", " + __Min2Hrs(nFimMenor, .T.)       +;
			                                     " Finalizacao operacao posterior: " + DToC(dFimMaior) + ", " + __Min2Hrs(nFimMaior, .T.)        ;
			                                     ) + " Operacao sera realocada finalizando junto da operacao anterior."},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf

		dData := aDatas[RET_GET_DATA_FIM_AUX_DATA]
		nHora := aDatas[RET_GET_DATA_FIM_AUX_HORA]
		lEntrega  := .T.
		lEntJunto := .T.

		Self:preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, cJsFerram)
		aPeriodos := Self:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lDistTudo, lGeraAdc, @lAlocPost, @lRetCria, cRecurso, lSimula, aFerramenta)

		nTamPer := Len(aPeriodos)
		lRealoca := nTamPer == 0 .Or. (aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA] != dData .Or. (aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA] == dData .And. aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM] != nHora))

		If lRealoca
			lEntrega  := lBkpEnt
			lEntJunto := .F.
		EndIf
	EndIf

	If lRealoca
		If Self:oLogs:logAtivo()
			Self:oLogs:gravaLog(Self:cEtapaLog, {Iif(nTamPer == 0, "Operacao nao foi alocada.", "Nao foi possivel finalizar a operacao junto da operacao anterior." +;
			                                     " Finalizacao operacao anterior: " + DToC(dData) + ", " + __Min2Hrs(nHora, .T.)                                    +;
			                                     " Finalizacao operacao posterior: " + DToC(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]) + ", " + __Min2Hrs(aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM], .T.);
			                                     ) + " Operacao sera realocada sem sobreposicao."},;
			                    aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])
		EndIf

		dData := aDatas[RET_GET_DATA_DATA]
		nHora := aDatas[RET_GET_DATA_HORA]

		Self:preparaParaAlocacao(cRecurso, aDispRecur, cIndices, cIndcAloc, cJsFerram)
		aPeriodos := Self:getPeriodosOperacao(aOperacao, lEntrega, dData, nHora, @lDistTudo, lGeraAdc, @lAlocPost, @lRetCria, cRecurso, lSimula, aFerramenta)
	EndIf

	Self:oLogs:gravaLog(Self:cEtapaLog, {" ---- Fim da avaliacao de sobreposicao ---- "}, aOperacao[ARRAY_MF_OP], aOperacao[ARRAY_MF_OPER], cRecurso, aOperacao[ARRAY_PROC_CHAVE_ARVORE])

Return Nil

/*/{Protheus.doc} geraOcorrenciaSobreposicao
Verifica o periodo que a ordem foi alocada e gera log de sobreposição caso necessario.

@author Lucas Fagundes
@since 25/10/2024
@version P12
@param 01 aOperacao , Array   , Operação que foi alocada.
@param 02 aPeriodos , Array   , Periodos da operação que foi alocada.
@param 03 cRecurso  , Caracter, Recurso que alocou a ordem.
@param 04 lEntJunto , Lógico  , Indica se realocou a operação para finalizar junto da operação anterior.
@return Nil
/*/
Method geraOcorrenciaSobreposicao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto) Class PCPA152TempoOperacao
	Local aAnterior := aTail(Self:aAlocados)
	Local aOperAnt  := {}
	Local aOperLog  := {}
	Local aPerAnt   := aAnterior[ALOCADOS_POS_PERIODOS]
	Local cCTrab    := ""
	Local dFimAnt   := Nil
	Local dFimSobre := Nil
	Local dIniSobre := Nil
	Local nFimAnt   := 0
	Local nFimSobre := 0
	Local nIniSobre := 0

	If lEntrega
		aOperLog := aAnterior[ALOCADOS_POS_OPERACAO]
		cRecurso := aAnterior[ALOCADOS_POS_RECURSO ]
		aOperAnt := aOperacao

		dFimAnt := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA    ]
		nFimAnt := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]

		dIniSobre := aPerAnt[1][ARRAY_DISPONIBILIDADE_DATA        ]
		nIniSobre := aPerAnt[1][ARRAY_DISPONIBILIDADE_HORA_INICIO ]
		dFimSobre := aTail(aPerAnt)[ARRAY_DISPONIBILIDADE_DATA    ]
		nFimSobre := aTail(aPerAnt)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	Else
		aOperLog := aOperacao
		aOperAnt := aAnterior[ALOCADOS_POS_OPERACAO]

		dFimAnt := aTail(aPerAnt)[ARRAY_DISPONIBILIDADE_DATA    ]
		nFimAnt := aTail(aPerAnt)[ARRAY_DISPONIBILIDADE_HORA_FIM]

		dIniSobre := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA        ]
		nIniSobre := aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_INICIO ]
		dFimSobre := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA    ]
		nFimSobre := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	EndIf
	cCTrab := Self:getCentroTrabalhoOperacao(aOperLog, cRecurso)

	If dIniSobre < dFimAnt .Or. (dIniSobre == dFimAnt .And. nIniSobre < nFimAnt)

		Self:oOcorrens:adicionaOcorrencia(LOG_ALOCOU_COM_SOBREPOSICAO      ,;
		                                  aOperLog[ARRAY_PROC_CHAVE_ARVORE],;
		                                  aOperLog[ARRAY_MF_ID            ],;
		                                  aOperLog[ARRAY_MF_OP            ],;
		                                  aOperLog[ARRAY_MF_OPER          ],;
		                                  cRecurso, "", cCTrab             ,;
		                                  {aOperAnt[ARRAY_MF_OPER         ]})

		If lEntJunto .And. 	dFimAnt == dFimSobre .And. nFimAnt == nFimSobre
			Self:oOcorrens:adicionaOcorrencia(LOG_ENTREGOU_JUNTO               ,;
			                                  aOperLog[ARRAY_PROC_CHAVE_ARVORE],;
			                                  aOperLog[ARRAY_MF_ID            ],;
			                                  aOperLog[ARRAY_MF_OP            ],;
			                                  aOperLog[ARRAY_MF_OPER          ],;
			                                  cRecurso, "", cCTrab             ,;
			                                  {aOperAnt[ARRAY_MF_OPER         ]})
		EndIf
	Else
		Self:oOcorrens:adicionaOcorrencia(LOG_SEM_SOBREPOSICAO             ,;
		                                  aOperLog[ARRAY_PROC_CHAVE_ARVORE],;
		                                  aOperLog[ARRAY_MF_ID            ],;
		                                  aOperLog[ARRAY_MF_OP            ],;
		                                  aOperLog[ARRAY_MF_OPER          ],;
		                                  cRecurso, "", cCTrab             ,;
		                                  {SEM_DISPONIBILIDADE})
	EndIf

	aOperAnt := {}
	aOperLog := {}
Return Nil

/*/{Protheus.doc} ocorrenciaOperacoes
Delega a geração de ocorrências das ordens
@author Lucas Fagundes
@since 18/11/2024
@version P12
@return Nil
/*/
Method ocorrenciaOperacoes() Class PCPA152TempoOperacao
	Local aOrdens := _Super:retornaListaGlobal(LISTA_DADOS_SMF)
	Local cOrdem  := ""
	Local nIndex  := 0
	Local nTotal  := Len(aOrdens)

	_Super:gravaValorGlobal("PROCESSADAS", 0)

	For nIndex := 1 To nTotal
		cOrdem := aOrdens[nIndex][1]

		_Super:delegar("P152GerOco", Self:cProg, cOrdem)
	Next

	While _Super:permiteProsseguir() .And. _Super:retornaValorGlobal("PROCESSADAS") < nTotal
		Sleep(50)
	End

	_Super:limpaValorGlobal("PROCESSADAS")

Return Nil

/*/{Protheus.doc} P152GerOco
Gera as ocorrências de uma ordem em outra thread
@type  Function
@author Lucas Fagundes
@since 18/11/2024
@version P12
@param cProg , Caracter, Código da programação que está sendo executada
@param cOrdem, Caracter, Código da ordem que irá gerar as ocorrências
@return Nil
/*/
Function P152GerOco(cProg, cOrdem)
	Local oSelf := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_TEMPOPER, @oSelf)
		oSelf:geraOcoOperacoesOrdem(cOrdem)
	EndIf

Return Nil

/*/{Protheus.doc} geraOcoOperacoesOrdem
Gera ocorrência para as operações de uma ordem.
@author Lucas Fagundes
@since 18/11/2024
@version P12
@param cOrdem, Caracter, Ordem que irá gerar as ocorrências
@return Nil
/*/
Method geraOcoOperacoesOrdem(cOrdem) Class PCPA152TempoOperacao
	Local aOperacao  := {}
	Local aOperacoes := Self:getOperacoesOrdem(cOrdem, .T.)
	Local nIndex     := 0
	Local nTotal     := Len(aOperacoes)

	For nIndex := 1 To nTotal
		aOperacao := aOperacoes[nIndex]

		If aOperacao[ARRAY_MF_TEMPSOB] > 0
			If Self:oParTempo["quebraOperacoes"]
				Self:oOcorrens:adicionaOcorrencia(LOG_SEM_SOBREPOSICAO              ,;
				                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperacao[ARRAY_MF_ID            ],;
				                                  aOperacao[ARRAY_MF_OP            ],;
				                                  aOperacao[ARRAY_MF_OPER          ],;
				                                  "", "", "", {QUEBRA_OPERACAO})
			ElseIf nIndex == 1
				Self:oOcorrens:adicionaOcorrencia(LOG_SEM_SOBREPOSICAO              ,;
				                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperacao[ARRAY_MF_ID            ],;
				                                  aOperacao[ARRAY_MF_OP            ],;
				                                  aOperacao[ARRAY_MF_OPER          ],;
				                                  "", "", "", {PRIMEIRA_OPERACAO})
			EndIf
		EndIf
	Next

	Self:oOcorrens:localToGlobal()

	_Super:gravaValorGlobal("PROCESSADAS", 1, .T., .T.)

	aSize(aOperacoes, 0)
Return Nil

/*/{Protheus.doc} validaTempoSobreposicao
Valida se o tempo de sobreposição é menor que o tempo da operação anterior.
@author Lucas Fagundes
@since 26/11/2024
@version P12
@param 01 aOperSob, Logico, Operação que aloca com sobreposição.
@param 02 aOperAnt, Logico, Operação que aloca antes da operação com sobreposição.
@param 03 cRecAnt , Logico, Recurso da operação que aloca antes da operação com sobreposição.
@param 04 lEntrega, Logico, Indica se a alocação é feita por data de entrega.
@param 05 lRetRemo, Logico, Retorna por referencia se considerou o tempo de remocao no lugar do tempo de sobreposicao.
@return lOk, Logico, Retorna true se o tempo de sobreposição for menor que o tempo da operação que antecede a operação com tempo de sobreposição.
/*/
Method validaTempoSobreposicao(aOperSob, aOperAnt, cRecAnt, lEntrega, lRetRemo) Class PCPA152TempoOperacao
	Local lOk       := .F.
	Local nTempoSob := 0

	lRetRemo := .F.

	If lEntrega .And. aOperSob[ARRAY_MF_TPSOBRE] != SOBREPOSICAO_POR_TEMPO
		nTempoSob := Self:tempoSobreposicao(aOperSob[ARRAY_MF_TPSOBRE], aOperSob[ARRAY_MF_TEMPSOB], aOperAnt, cRecAnt)
	Else
		nTempoSob := aOperSob[ARRAY_MF_SOBREPO]
	EndIf

	If aOperAnt[ARRAY_MF_REMOCAO] > nTempoSob
		lRetRemo  := .T.
		nTempoSob := aOperAnt[ARRAY_MF_REMOCAO]
	EndIf

	nTempoAloc := Self:calcTempoAlocacao(aOperAnt, cRecAnt)
	lOk        := nTempoSob < nTempoAloc

Return lOk

/*/{Protheus.doc} getCentroTrabalhoOperacao
Retorna o centro de trabalho de um dos recurso da operação.
@author Lucas Fagundes
@since 26/11/2024
@version P12
@param aOperacao, Array   , Operação que irá buscar o centro de trabalho.
@param cRecurso , Caracter, Recurso que irá buscar o centro de trabalho.
@return cCTrab, Caracter, Centro de trabalho do recurso informado.
/*/
Method getCentroTrabalhoOperacao(aOperacao, cRecurso) Class PCPA152TempoOperacao
	Local nPosRec := 0
	Local cCTrab := ""

	nPosRec  := aScan(aOperacao[ARRAY_PROC_RECURSOS], {|x| x[ARRAY_HZ7_RECURS] == cRecurso})
	If nPosRec > 0
		cCTrab := aOperacao[ARRAY_PROC_RECURSOS][nPosRec][ARRAY_HZ7_CTRAB]
	EndIf

Return cCTrab

/*/{Protheus.doc} preAlocacaoAtualizaSobreposicao
Se processa por data de inicio, atualiza o tempo de sobreposição da operação (alocação em andamento) com base no recurso que foi alocado a operação anterior (já alocada).
@author Lucas Fagundes
@since 26/11/2024
@version P12
@param 01 aOperSob, Array   , Operação que terá o tempo de sobreposição calculado.
@param 02 lEntrega, Logico  , Indica se a operação será alocada por data de entrega.
@return Nil
/*/
Method preAlocacaoAtualizaSobreposicao(aOperSob, lEntrega) Class PCPA152TempoOperacao
	Local aOperAnt := {}
	Local cRecAnt  := ""

	If !lEntrega .And. Len(Self:aAlocados) > 0 .And. aOperSob[ARRAY_MF_TEMPSOB] > 0 .And. aOperSob[ARRAY_MF_TPSOBRE] != SOBREPOSICAO_POR_TEMPO
		aOperAnt := Self:getUltimaOperacaoAlocada(@cRecAnt)
		aOperSob[ARRAY_MF_SOBREPO] := Self:tempoSobreposicao(aOperSob[ARRAY_MF_TPSOBRE], aOperSob[ARRAY_MF_TEMPSOB], aOperAnt, cRecAnt)
	EndIf

Return Nil

/*/{Protheus.doc} posAlocacaoAtualizaSobreposicao
Se processa por data de entrega, atualiza o tempo de sobreposição da operação (já alocada) com base no recurso que foi alocado a operação anterior (alocação em andamento).
@author Lucas Fagundes
@since 26/11/2024
@version P12
@param 01 aOperAnt, Array   , Operação que antecede a operação com sobreposição que será atualizada.
@param 02 cRecAnt , Caracter, Recurso que a operação que antecede a operação com sobreposição foi alocada.
@param 03 lEntrega, Logico  , Indica se a operação foi alocada por data de entrega.
@return Nil
/*/
Method posAlocacaoAtualizaSobreposicao(aOperAnt, cRecAnt, lEntrega) Class PCPA152TempoOperacao
	Local aOperSob  := {}
	Local nTempoSob := 0

	If lEntrega .And. Len(Self:aAlocados) > 0
		aOperSob := Self:getUltimaOperacaoAlocada()

		If aOperSob[ARRAY_MF_TEMPSOB] > 0 .And. aOperSob[ARRAY_MF_TPSOBRE] != SOBREPOSICAO_POR_TEMPO
			nTempoSob := Self:tempoSobreposicao(aOperSob[ARRAY_MF_TPSOBRE], aOperSob[ARRAY_MF_TEMPSOB], aOperAnt, cRecAnt)

			aTail(Self:aAlocados)[ALOCADOS_POS_OPERACAO][ARRAY_MF_SOBREPO] := nTempoSob
			aTail(Self:aAlocados)[ALOCADOS_POS_TEMPO_SOBREPOSICAO        ] := nTempoSob
		EndIf

		aOperSob := {}
	EndIf

Return Nil

/*/{Protheus.doc} verificaSobreposicao
Valida a alocação da operação e gera ocorrência de sobreposição alocada ou não alocada.

@author Lucas Fagundes
@since 27/11/2024
@version version
@param 01 aOperacao, Array   , Array com as informações da operação que está sendo alocada.
@param 02 lEntrega , Lógico  , Indica se a operação alocou por data de entrega.
@param 03 cRecAloc , Caracter, Recurso que a operação foi alocada.
@param 04 aPeriodos, Array   , Periodo de alocação da operação.
@param 05 lEntJunto, Lógico  , Indica se a operação alocou junto da operação anterior.
@param 06 lRemoveGlb, Lógico, Indica se deve remover ocorrências da memória global.
@return Nil
/*/
Method verificaSobreposicao(aOperacao, lEntrega, cRecAloc, aPeriodos, lEntJunto, lRemoveGlb) Class PCPA152TempoOperacao
	Local aAnterior  := {}
	Local aOperLog   := {}
	Local cCTrab     := ""
	Local cRecAnt    := ""
	Local cRecAux    := ""
	Local cRecLog    := ""
	Local lRemocao   := .F.
	Local nTempoAloc := 0
	Local oRemove    := Nil

	aAnterior  := Self:getUltimaOperacaoAlocada(@cRecAux)

	If (!lEntrega .And. aOperacao[ARRAY_MF_SOBREPO] > 0) .Or. (lEntrega .And. aAnterior[ARRAY_MF_SOBREPO] > 0)

		If lEntrega
			aOperLog  := aAnterior
			aAnterior := aOperacao
			cRecLog   := cRecAux
			cRecAnt   := cRecAloc
		Else
			aOperLog := aOperacao
			cRecLog  := cRecAloc
			cRecAnt  := cRecAux
		EndIf
		cCTrab := Self:getCentroTrabalhoOperacao(aOperLog, cRecLog)

		If lRemoveGlb
			oRemove := JsonObject():New()
			oRemove[LOG_ALOCOU_COM_SOBREPOSICAO] := .T.
			oRemove[LOG_ENTREGOU_JUNTO         ] := .T.
			oRemove[LOG_SEM_SOBREPOSICAO+SEM_DISPONIBILIDADE] := .T.
			oRemove[LOG_SEM_SOBREPOSICAO+TEMPO_SOBREPOSICAO ] := .T.
			oRemove[LOG_SEM_SOBREPOSICAO+MESMO_RECURSO      ] := .T.

			Self:oOcorrens:removeOcorrenciaGlobal(aOperLog[ARRAY_PROC_CHAVE_ARVORE], aOperLog[ARRAY_MF_OP], Nil, oRemove, aOperLog[ARRAY_MF_OPER])

			FreeObj(oRemove)
		EndIf

		If Self:alocaComSobreposicao(aOperacao, lEntrega, cRecAloc)
			Self:geraOcorrenciaSobreposicao(aOperacao, aPeriodos, cRecAloc, lEntrega, lEntJunto)

		ElseIf !Self:oParTempo["quebraOperacoes"] .And. aOperacao[ARRAY_MF_OP] == aAnterior[ARRAY_MF_OP]

			If !Self:validaTempoSobreposicao(aOperLog, aAnterior, cRecAnt, lEntrega, @lRemocao)
				nTempoAloc := Self:calcTempoAlocacao(aAnterior, cRecAnt)

				If lRemocao
					Self:oLogs:gravaLog(Self:cEtapaLog, {"Foi considerado o tempo de remocao ("      + __Min2Hrs(aAnterior[ARRAY_MF_REMOCAO], .T.) + ") da operacao " + aAnterior[ARRAY_MF_OPER] +;
					                                     ", na validacao de tempo de sobreposicao (" + __Min2Hrs(aOperLog[ARRAY_MF_SOBREPO], .T.)  + ") da operacao " + aOperLog[ARRAY_MF_OPER]},;
					                    aOperLog[ARRAY_MF_OP], aOperLog[ARRAY_MF_OPER], cRecLog, aOperLog[ARRAY_PROC_CHAVE_ARVORE])
				EndIf

				Self:oOcorrens:adicionaOcorrencia(LOG_SEM_SOBREPOSICAO             ,;
				                                  aOperLog[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperLog[ARRAY_MF_ID            ],;
				                                  aOperLog[ARRAY_MF_OP            ],;
				                                  aOperLog[ARRAY_MF_OPER          ],;
				                                  cRecLog, "", cCTrab              ,;
				                                  {TEMPO_SOBREPOSICAO              ,;
				                                  __Min2Hrs(aOperLog[ARRAY_MF_SOBREPO], .T.),;
				                                  __Min2Hrs(nTempoAloc, .T.),;
				                                  __Min2Hrs(aAnterior[ARRAY_MF_REMOCAO], .T.)})
			ElseIf cRecAnt == cRecLog
				Self:oOcorrens:adicionaOcorrencia(LOG_SEM_SOBREPOSICAO             ,;
				                                  aOperLog[ARRAY_PROC_CHAVE_ARVORE],;
				                                  aOperLog[ARRAY_MF_ID            ],;
				                                  aOperLog[ARRAY_MF_OP            ],;
				                                  aOperLog[ARRAY_MF_OPER          ],;
				                                  cRecLog, "", cCTrab              ,;
				                                  {MESMO_RECURSO})
			EndIf

			aOperLog := {}
		EndIf
	EndIf

	aAnterior := {}
Return Nil

/*/{Protheus.doc} getUltimaOperacaoAlocada
Retorna a ultima operação pendente de efetivação que esta no array de operações alocadas (Self:aAlocados).
@author Lucas Fagundes
@since 27/11/2024
@version P12
@param 01 cRecurso , Array   , Retorna por referência o recurso que a operação foi alocada.
@param 02 aPeriodos, Caracter, Retorna por referência os periodos de alocação da operação.
@return aUltima, Array, Ultima operação nivelada.
/*/
Method getUltimaOperacaoAlocada(cRecurso, aPeriodos) Class PCPA152TempoOperacao
	Local aUltima  := Array(TAMANHO_ARRAY_PROC_MF)
	Local nTamAloc := Len(Self:aAlocados)

	aPeriodos := {}
	cRecurso  := ""

	If nTamAloc > 0
		aUltima   := Self:aAlocados[nTamAloc][ALOCADOS_POS_OPERACAO]
		cRecurso  := Self:aAlocados[nTamAloc][ALOCADOS_POS_RECURSO ]
		aPeriodos := Self:aAlocados[nTamAloc][ALOCADOS_POS_PERIODOS]
	EndIf

Return aUltima

/*/{Protheus.doc} getTempoOperacao
Calcula o tempo de uma operação.
(Metodo para uso da classe fora do CRP. Utilizar em conjunto do método setParam)

@author Lucas Fagundes
@since 17/02/2025
@version P12
@param oInfoOper, Object, Json com as informações da operação.
@return Self:oInfoOper, Object, Retorna as informações da operação com o tempo calculado.
/*/
Method getTempoOperacao(oInfoOper) Class PCPA152TempoOperacao
	Local aOperacao  := Array(TAMANHO_ARRAY_PROC_MF)
	Local nMaoObra   := 0
	Local nTempoOper := 0

	Self:oInfoOper := oInfoOper

	Self:calculaSaldo()
	Self:calculaDuracaoOperacao()

	aOperacao[ARRAY_MF_TPOPER] := oInfoOper["tipoOperacao"]
	nTempoOper := __Hrs2Min(Self:oInfoOper["tempoOperacao"])
	nMaoObra   := oInfoOper["maoDeObra"]

	nTempo := Self:aplicaMaoDeObra(aOperacao, nTempoOper, nMaoObra)

	If (nTempo - Int(nTempo)) > 0
		nTempo := Int(nTempo) + 1
	EndIf

	Self:oInfoOper["tempoOperacao"] := nTempo

Return Self:oInfoOper

/*/{Protheus.doc} setParam
Seta um parametro para uso da classe fora do CRP.
@author Lucas Fagundes
@since 17/02/2025
@version P12
@param cParam, Caracter, Parâmetro que será setado.
@param xValor, Undefine, Valor que será atribuido para o parâmetro.
@return Nil
/*/
Method setParam(cParam, xValor) Class PCPA152TempoOperacao

	Self:oParTempo[cParam] := xValor

Return Nil

/*/{Protheus.doc} adicionaTempoRemocao
Adiciona o tempo de remoção nos periodos da operação.
@author Lucas Fagundes
@since 26/02/2025
@version P12
@param aOperacao, Array, Array com as informações da operação.
@param aPeriodos, Array, Array com os periodos da operação.
@return aPeriodos, Array, Retorna os periodos com o tempo de remoção adicionado.
/*/
Method adicionaTempoRemocao(aOperacao, aPeriodos) Class PCPA152TempoOperacao
	Local aPeriodo := {}
	Local aUltPer  := {}
	Local cRecurso := ""
	Local dData    := Nil
	Local nHoraFim := 0
	Local nHoraIni := 0
	Local nRemocao := aOperacao[ARRAY_MF_REMOCAO]

	If Len(aPeriodos) > 0
		cRecurso := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_RECURSO]

		While nRemocao > 0
			aUltPer  := aTail(aPeriodos)
			dData    := aUltPer[ARRAY_DISPONIBILIDADE_DATA    ]
			nHoraIni := aUltPer[ARRAY_DISPONIBILIDADE_HORA_FIM]

			If nHoraIni == __Hrs2Min("24:00")
				dData++
				nHoraIni := __Hrs2Min("00:00")
			EndIf

			nHoraFim := nHoraIni + nRemocao
			If nHoraFim > __Hrs2Min("24:00")
				nHoraFim := __Hrs2Min("24:00")
			EndIf

			aPeriodo := Self:criaPeriodoDisponibilidade(dData, nHoraIni, nHoraFim, cRecurso, 0, aOperacao[ARRAY_MF_ID], aOperacao[ARRAY_MF_OP])
			aPeriodo[ARRAY_DISPONIBILIDADE_TIPO] := VM_TIPO_REMOCAO

			nRemocao -= aPeriodo[ARRAY_DISPONIBILIDADE_TEMPO]

			aAdd(aPeriodos, aPeriodo)
			aPeriodo := {}
		End
	EndIf

Return aPeriodos

/*/{Protheus.doc} validaOcorrenciasAlocacao
Avalia as alocações de uma operação e gera as ocorrências necessárias.
@author Lucas Fagundes
@since 28/05/2025
@version P12
@param aOperacao , Array   , Operação que foi alocada.
@param aPeriodos , Array   , Periodos da operação que foi alocada.
@param cRecurso  , Caracter, Recurso que alocou a operação.
@param lEntrega  , Logico  , Indica se a operação foi alocada por data de entrega.
@param lEntJunto , Logico  , Indica se a operação foi alocada junto da operação anterior.
@param lRemoveGlb, Lógico  , Indica que deve remover ocorrências da memória global.
@param dDataIni  , Date    , Data de inicio da alocação.
@param nHoraIni  , Numerico, Hora de inicio da alocação.
@return Nil
/*/
Method validaOcorrenciasAlocacao(aOperacao, aPeriodos, cRecurso, lEntrega, lEntJunto, lRemoveGlb, dDataIni, nHoraIni) Class PCPA152TempoOperacao

	Self:verificaSobreposicao(aOperacao, lEntrega, cRecurso, aPeriodos, lEntJunto, lRemoveGlb)
	Self:verificaValidadeOperacao(aOperacao, aPeriodos, cRecurso, lRemoveGlb)
	Self:verificaDataOperacao(aOperacao, aPeriodos, dDataIni, nHoraIni, lEntrega, cRecurso, lRemoveGlb)

Return Nil

/*/{Protheus.doc} verificaValidadeOperacao
Valida as datas de alocação da operação e gera ocorrerência caso a operação não esteja dentro do período de validade.

@author Breno Soares
@since 28/03/2025
@version P12
@param 01 aOperacao, Array   , Operação que esta sendo alocada.
@param 02 aPeriodos, Array   , Periodos encontrados para a operação.
@param 03 cRecurso , Caracter, Recurso que esta sendo alocado.
@param 04 lRemoveGlb, Lógico  , Indica que deve remover ocorrências da memória global.
@return Nil
/*/
Method verificaValidadeOperacao(aOperacao, aPeriodos, cRecurso, lRemoveGlb) Class PCPA152TempoOperacao
	Local dAlocFim   := Nil
	Local dAlocIni   := Nil
	Local dVldFim    := Nil
	Local dVldIni    := Nil
	Local lFimValido := .F.
	Local lIniValido := .F.
	Local lValidade  := .T.

	If !Empty(aPeriodos) .And. Self:oParTempo["dicionarioValidade"]
		dVldIni  := aOperacao[ARRAY_MF_VLDINI]
		dVldFim  := aOperacao[ARRAY_MF_VLDFIM]
		dAlocIni := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
		dAlocFim := aPeriodos[Len(aPeriodos)][ARRAY_DISPONIBILIDADE_DATA]

		lIniValido := (Empty(dVldIni) .Or. dVldIni <= dAlocIni)
		lFimValido := (Empty(dVldFim) .Or. dVldFim >= dAlocFim)

		lValidade := lIniValido .And. lFimValido
	EndIf

	If lRemoveGlb
		Self:oOcorrens:removeOcorrenciaGlobal(aOperacao[ARRAY_PROC_CHAVE_ARVORE], aOperacao[ARRAY_MF_OP], LOG_OPERACAO_NAO_VALIDADE, Nil, aOperacao[ARRAY_MF_OPER])
	EndIf

	If !lValidade
		Self:oOcorrens:adicionaOcorrencia(LOG_OPERACAO_NAO_VALIDADE,;
		                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE],;
		                                  aOperacao[ARRAY_MF_ID  ],;
		                                  aOperacao[ARRAY_MF_OP  ],;
		                                  aOperacao[ARRAY_MF_OPER],;
		                                  cRecurso,;
		                                  "", "",;
		                                  {dAlocIni, dAlocFim, dVldIni, dVldFim})
	EndIf

Return Nil

/*/{Protheus.doc} removeOcorrenciasDistribuicao
Remove as ocorrencias que podem ter sido geradas durante a distribuição de uma ordem.
@author Lucas Fagundes
@since 28/05/2025
@version P12
@param cChaveArv, Caracter, Chave da árvore.
@param cOrdem   , Caracter, Numero da ordem de produção.
@return Nil
/*/
Method removeOcorrenciasDistribuicao(cChaveArv, cOrdem) Class PCPA152TempoOperacao
	Local oRemove := JsonObject():New()

	oRemove[LOG_ALOCOU_COM_SOBREPOSICAO] := .T.
	oRemove[LOG_ENTREGOU_JUNTO         ] := .T.
	oRemove[LOG_OPERACAO_NAO_VALIDADE  ] := .T.
	oRemove[LOG_OPERACAO_FORA_PREVISTO ] := .T.
	oRemove[LOG_SEM_SOBREPOSICAO+SEM_DISPONIBILIDADE] := .T.
	oRemove[LOG_SEM_SOBREPOSICAO+TEMPO_SOBREPOSICAO ] := .T.
	oRemove[LOG_SEM_SOBREPOSICAO+MESMO_RECURSO      ] := .T.

	Self:oOcorrens:removeOcorrenciaGlobal(cChaveArv, cOrdem, Nil, oRemove)

	FreeObj(oRemove)
Return Nil

/*/{Protheus.doc} criaBackupFerramentas
Cria backup da alocação das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method criaBackupFerramentas() Class PCPA152TempoOperacao

	If Self:oParTempo["utilizaFerramentas"]
		Self:oFerramentas:criaBackupFerramentas()
	EndIf

Return Nil

/*/{Protheus.doc} rollbackBackupFerramentas
Restaura o backup de alocação das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method rollbackBackupFerramentas() Class PCPA152TempoOperacao

	If Self:oParTempo["utilizaFerramentas"]
		Self:oFerramentas:restauraBackupFerramentas()
	EndIf

Return Nil

/*/{Protheus.doc} excluiBackupFerramentas
Exclui o backup de alocação das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method excluiBackupFerramentas() Class PCPA152TempoOperacao

	If Self:oParTempo["utilizaFerramentas"]
		Self:oFerramentas:descartaBackupFerramentas()
	EndIf

Return Nil

/*/{Protheus.doc} alocaFerramentas
Realiza a alocação das ferramentas nos periodos do recurso de acordo com o tipo de alocação.
@author Lucas Fagundes
@since 28/03/2025
@version P12
@param aPeriodos, Array, Array com os periodos que a operação foi alocada no recurso.
@return Nil
/*/
Method alocaFerramentas(aPeriodos) Class PCPA152TempoOperacao
	Local aReservas := {}
	Local cTipoAlo  := ""
	Local nIndex    := 0
	Local nTipoPer  := 0
	Local nTotal    := 0
	Local oPeriodo  := Nil

	If Len(Self:aFerramentas) == 0 .Or. !Self:oParTempo["utilizaFerramentas"]
		Return Nil
	EndIf

	cTipoAlo := Self:aOperacao[ARRAY_MF_TPALOFE]
	nTotal   := Len(aPeriodos)

	For nIndex := 1 To nTotal
		nTipoPer := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_TIPO]

		If (nTipoPer == VM_TIPO_SETUP    .And. (cTipoAlo == TIPO_ALOCACAO_FERRAMENTA_SETUP    .Or. cTipoAlo == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO)) .Or.;
		   (nTipoPer == VM_TIPO_PRODUCAO .And. (cTipoAlo == TIPO_ALOCACAO_FERRAMENTA_PRODUCAO .Or. cTipoAlo == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO))
			oPeriodo := JsonObject():New()
			oPeriodo["data"      ] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_DATA       ]
			oPeriodo["horaInicio"] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_INICIO]
			oPeriodo["horaFim"   ] := aPeriodos[nIndex][ARRAY_DISPONIBILIDADE_HORA_FIM   ]

			aAdd(aReservas, oPeriodo)

			oPeriodo := Nil
		EndIf
	Next

	If Len(aReservas) > 0
		Self:oFerramentas:reservaFerramentas(Self:aFerramentas, aReservas)
	EndIf

	aSize(aReservas, 0)
Return Nil

/*/{Protheus.doc} validaFimIntervalo
Valida o range do ultimo intervalo de alocacão, verifica se atingiu o fim da disponibilidade do recurso.
@author Lucas Fagundes
@since 23/04/2025
@version P12
@param cRecurso, Caracter, Recurso que a operação atual esta sendo alocada.
@return lFimDisp, Logico, Retorna se o intervalo de alocação atingiu o fim da disponibilidade do recurso.
/*/
Method validaFimIntervalo(cRecurso) Class PCPA152TempoOperacao
	Local aDispRec   := Self:oDispRecur[cRecurso]
	Local aTempos    := {}
	Local lFimDisp   := .F.
	Local nFimDisp   := Len(aDispRec)
	Local nFimInterv := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP]

	lFimDisp := nFimInterv >= nFimDisp

	// Se parou no ultimo indice da disponibilidade, verifica o array de tempos.
	If nFimInterv == nFimDisp
		aTempos    := aDispRec[nFimDisp][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
		nFimDisp   := Len(aTempos)
		nFimInterv := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO]

		lFimDisp := nFimInterv >= nFimDisp

	EndIf

Return lFimDisp

/*/{Protheus.doc} ajustaArrayDeTempos
Percorre o array de tempos de um indice da disponibilidade e realiza as quebras de acordo com a disponibilidade das ferramentas da operação que esta sendo alocada.
@author Lucas Fagundes
@since 25/04/2025
@version P12
@param aTempos, Array, Array de tempos que será ajustado.
@return lQuebrou, Logico, Retorna se o array de tempos foi quebrado.
/*/
Method ajustaArrayDeTempos(aTempos) Class PCPA152TempoOperacao
	Local aNewTempos := {}
	Local aTempo     := {}
	Local lQuebrou   := .F.
	Local lQuebrouTe := .F.
	Local nIndex     := 0
	Local nTotal     := Len(aTempos)

	If Len(Self:aFerramentas) == 0 .Or. !Self:oParTempo["utilizaFerramentas"]
		Return lQuebrou
	EndIf

	For nIndex := 1 To nTotal
		aTempo := aTempos[nIndex]

		If aTempo[ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
			aAdd(aNewTempos, aTempo)
			Loop
		EndIf

		Self:quebraTempoDeAcordoComDisponibilidadeDaFerramenta(aTempo, @aNewTempos, @lQuebrouTe)

		lQuebrou := lQuebrou .Or. lQuebrouTe
	Next

	If lQuebrou
		nTotal := Len(aNewTempos)

		aSize(aTempos, 0)
		For nIndex := 1 To nTotal
			aAdd(aTempos, aNewTempos[nIndex])
		Next

		Self:ordenaTempos(@aTempos)
	EndIf

Return lQuebrou

/*/{Protheus.doc} quebraTempoDeAcordoComDisponibilidadeDaFerramenta
Quebra um tempo de disponibilidade de acordo com a disponiblidade das ferramentas.
@author Lucas Fagundes
@since 01/04/2025
@version P12
@param aTempo  , Array , Periodo de tempo de um recurso que será quebrado (retorna o periodo em que a ferramenta esta disponivel).
@param aInsere , Array , Array que irá inserir as quebras.
@param lQuebrou, Logico, Retorna por referência se realizou alguma quebra.
@return Nil
/*/
Method quebraTempoDeAcordoComDisponibilidadeDaFerramenta(aTempo, aInsere, lQuebrou) Class PCPA152TempoOperacao
	Local aPersDisp := {}
	Local aPersInd  := {}
	Local aTempoAux := {}
	Local cRecurso  := aTempo[ARRAY_DISPONIBILIDADE_RECURSO    ]
	Local dData     := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
	Local nHoraFim  := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
	Local nHoraIni  := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
	Local nIndDisp  := aTempo[ARRAY_DISPONIBILIDADE_INDICE_DISP]
	Local nIndex    := 0
	Local nTotal    := 0

	Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dData, nHoraIni, nHoraFim, @aPersDisp, @aPersInd)

	lQuebrou := (Len(aPersDisp) + Len(aPersInd)) > 1

	If lQuebrou
		nTotal := Len(aPersDisp)
		For nIndex := 1 To nTotal
			dData    := aPersDisp[nIndex]["data"      ]
			nHoraIni := aPersDisp[nIndex]["horaInicio"]
			nHoraFim := aPersDisp[nIndex]["horaFim"   ]

			aAdd(aInsere, Self:criaPeriodoDisponibilidade(dData, nHoraIni, nHoraFim, cRecurso, nIndDisp))
		Next

		nTotal := Len(aPersInd)
		For nIndex := 1 To nTotal
			dData    := aPersInd[nIndex]["data"      ]
			nHoraIni := aPersInd[nIndex]["horaInicio"]
			nHoraFim := aPersInd[nIndex]["horaFim"   ]

			aTempoAux := Self:criaPeriodoDisponibilidade(dData, nHoraIni, nHoraFim, cRecurso, nIndDisp)
			aTempoAux[ARRAY_DISPONIBILIDADE_FERRAMENTA_DISPONIVEL] := .F.

			aAdd(aInsere, aTempoAux)

			aTempoAux := {}
		Next
	Else
		aAdd(aInsere, aTempo)
	EndIf

	aSize(aPersDisp, 0)
	aSize(aPersInd, 0)
Return Nil

/*/{Protheus.doc} efetivaDisponibilidadeAdicional
Efetiva a disponibilidade adicional gerada para os recursos e as ferramentas.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@return Nil
/*/
Method efetivaDisponibilidadeAdicional() Class PCPA152TempoOperacao
	Local oDisp := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	oDisp:efetivaDisponibilidadeAdicional()
	Self:oFerramentas:efetivaUtilizacaoAdicional()

	oDisp := Nil
Return Nil

/*/{Protheus.doc} excluiDisponibilidadeAdicional
Limpa a disponibilidade adicional gerada para os recursos e as ferramentas.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@return Nil
/*/
Method excluiDisponibilidadeAdicional() Class PCPA152TempoOperacao
	Local oDisp := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	oDisp:limpaDisponibilidadeAdicional(.T.)
	Self:oFerramentas:excluiUtilizacaoAdicional()

	oDisp := Nil
Return Nil

/*/{Protheus.doc} verificaDataOperacao
Verifica a data da alocação e gera ocorrencias caso necessario.
@author Lucas Fagundes
@since 01/07/2025
@version P12
@param aOperacao , Array   , Array com as informações da operação que foi alocada.
@param aPeriodos , Array   , Array com os periodos da operação que foi alocada.
@param dDataIni  , Date    , Data inicial da alocação (enviada para o método getPeriodosOperacao())
@param nHoraIni  , Numerico, Hora inicial da alocação (enviada para o método getPeriodosOperacao())
@param lEntrega  , Lógico  , Indica se a operação foi alocada por data de entrega.
@param cRecurso  , Caracter, Recurso que alocou a operação.
@param lRemoveGlb, Lógico  , Indica que deve remover ocorrências da memória global.
@return Nil
/*/
Method verificaDataOperacao(aOperacao, aPeriodos, dDataIni, nHoraIni, lEntrega, cRecurso, lRemoveGlb) Class PCPA152TempoOperacao
	Local dDataAlo := Nil
	Local lGeraOco := .F.
	Local nHoraAlo := 0

	If lRemoveGlb
		Self:oOcorrens:removeOcorrenciaGlobal(aOperacao[ARRAY_PROC_CHAVE_ARVORE], aOperacao[ARRAY_MF_OP], LOG_OPERACAO_FORA_PREVISTO, Nil, aOperacao[ARRAY_MF_OPER])
	EndIf

	If lEntrega
		dDataAlo := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_DATA]
		nHoraAlo := aTail(aPeriodos)[ARRAY_DISPONIBILIDADE_HORA_FIM]
	Else
		dDataAlo := aPeriodos[1][ARRAY_DISPONIBILIDADE_DATA]
		nHoraAlo := aPeriodos[1][ARRAY_DISPONIBILIDADE_HORA_INICIO]
	EndIf

	lGeraOco := dDataIni != dDataAlo .Or. nHoraIni != nHoraAlo

	If lGeraOco
		Self:oOcorrens:adicionaOcorrencia(LOG_OPERACAO_FORA_PREVISTO          ,;
		                                  aOperacao[ARRAY_PROC_CHAVE_ARVORE]  ,;
		                                  aOperacao[ARRAY_MF_ID  ]            ,;
		                                  aOperacao[ARRAY_MF_OP  ]            ,;
		                                  aOperacao[ARRAY_MF_OPER]            ,;
		                                  cRecurso                            ,;
		                                  ""                                  ,;
		                                  Self:getCentroTrabalhoOperacao(aOperacao, cRecurso),;
		                                  {lEntrega, dDataIni, nHoraIni, dDataAlo, nHoraAlo})
	EndIf

Return Nil

/*/{Protheus.doc} validaFerramentas
Identifica os periodos do intervalo que será alocado ferramenta e valida se as ferramentas estarão disponiveis.
@author Lucas Fagundes
@since 16/07/2025
@version P12
@param aOperacao , Array   , Array com as informações da operação que será alocada.
@param nTempoAloc, Numerico, Tempo de alocação da operação que será alocada.
@param cRecurso  , Caracter, Recurso que a operação será alocada.
@param nIndDisp  , Numerico, Indice da disponibilidade do recurso que a operação será alocada.
@param nIndTempos, Numerico, Indice do array de tempos que a operação será alocada.
@Param dDataStart, Date    , Data de inicio da alocação.
@Param nHoraStart, Numerico, Hora de inicio da alocação.
@return Nil
/*/
Method validaFerramentas(aOperacao, nTempoAloc, cRecurso, nIndDisp, nIndTempos, dDataStart, nHoraStart) Class PCPA152TempoOperacao
	Local aTempo      := {}
	Local aTempos     := {}
	Local dDataTempo  := Nil
	Local lDisponivel := .T.
	Local lValida     := .F.
	Local nFimAux     := 0
	Local nFimTempo   := 0
	Local nFimValid   := 0
	Local nIndex      := 0
	Local nIndexTemp  := 0
	Local nIndFim     := 0
	Local nIniTempo   := 0
	Local nIniValid   := 0
	Local nTempo      := 0
	Local nTempoFina  := 0
	Local nTempoProd  := 0
	Local nTempoSetup := 0

	If Len(Self:aFerramentas) == 0 .Or. !Self:oParTempo["utilizaFerramentas"] .Or. Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA]
		Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA] := .T.
	Else
		nTempoProd := nTempoAloc

		nTempoSetup := aOperacao[ARRAY_MF_SETUP]
		If Self:aIntervalo[ARRAY_INTERVALO_REALIZA_SETUP]
			nTempoProd -= nTempoSetup
		Else
			nTempoSetup := 0
		EndIf

		nTempoFina := Self:getTempoFinalizacao(aOperacao, cRecurso)
		If Self:aIntervalo[ARRAY_INTERVALO_REALIZA_FINALIZACAO]
			nTempoProd -= nTempoFina
		Else
			nTempoFina := 0
		EndIf

		If Self:oParTempo["quebraOperacoes"] .And. (nTempoSetup + nTempoProd + nTempoFina) > Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL]
			nTempoProd := Self:aIntervalo[ARRAY_INTERVALO_TEMPO_ALOCAVEL] - (nTempoSetup + nTempoFina)
		EndIf

		Self:validaInicioAlocacao(aOperacao, cRecurso, nTempoSetup, nTempoProd, nTempoFina, nIndDisp, nIndTempos, dDataStart, @nHoraStart)
	EndIf

	If Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA]
		Return Nil
	EndIf

	If Self:lDecresce
		nIndFim   := Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP]

		For nIndex := nIndDisp To nIndFim Step -1
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nFimAux := 1

			If nIndex == nIndFim
				nFimAux := Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO]
			EndIf

			For nIndexTemp := Iif(nIndex == nIndDisp, nIndTempos, Len(aTempos)) To nFimAux Step -1
				aTempo  := aTempos[nIndexTemp]
				lValida := .F.
				dDataTempo := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nIniTempo  := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nFimTempo  := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo     := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dDataTempo == dDataStart
					If nIniTempo >= nHoraStart
						Loop
					EndIf

					If nFimTempo > nHoraStart
						nFimTempo := nHoraStart
						nTempo    := nFimTempo - nIniTempo
					EndIf
				EndIf

				If nTempoFina > 0
					If nTempo <= nTempoFina
						nTempoFina -= nTempo
						nFimTempo  := nFimTempo - nTempo
					Else
						nFimTempo  := nFimTempo - nTempoFina
						nTempoFina := 0
					EndIf
					nTempo := nFimTempo - nIniTempo
				EndIf

				If nTempo > 0 .And. nTempoFina == 0 .And. nTempoProd > 0
					lValida := aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_PRODUCAO .Or.;
					           aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO
					nIniValid := nIniTempo
					nFimValid := nFimTempo

					If nTempo <= nTempoProd
						nTempoProd -= nTempo
						nFimTempo  := nFimTempo - nTempo
					Else
						nFimTempo  := nFimTempo - nTempoProd
						nIniValid  := nFimTempo
						nTempoProd := 0
					EndIf
					nTempo := nFimTempo - nIniTempo

					If lValida
						lDisponivel := Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dDataTempo, nIniValid, nFimValid)
					EndIf
				EndIf

				If lDisponivel .And. nTempo > 0 .And. nTempoFina == 0 .And. nTempoProd == 0 .And. nTempoSetup > 0
					lValida := aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP .Or.;
					           aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO

					If lValida
						nIniValid := nIniTempo
						nFimValid := nFimTempo

						If nTempo <= nTempoSetup
							nTempoSetup -= nTempo
							nFimTempo   := nFimTempo - nTempo
						Else
							nFimTempo   := nFimTempo - nTempoSetup
							nIniValid   := nFimTempo
							nTempoSetup := 0
						EndIf
						nTempo := nFimTempo - nIniTempo

						lDisponivel := Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dDataTempo, nIniValid, nFimValid)
					Else
						nTempoSetup := 0
					EndIf
				EndIf

				If !lDisponivel .Or. (nTempoSetup == 0 .And. nTempoProd == 0 .And. nTempoFina == 0)
					Exit
				EndIf
			Next

			If !lDisponivel .Or. (nTempoSetup == 0 .And. nTempoProd == 0 .And. nTempoFina == 0)
				Exit
			EndIf
		Next

		If !lDisponivel
			Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP ] := nIndex
			Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO] := nIndexTemp
		EndIf
	Else
		nIndFim := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP]

		For nIndex := nIndDisp to nIndFim
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nFimAux := Len(aTempos)

			If nIndex == nIndFim
				nFimAux := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO]
			EndIf

			For nIndexTemp := Iif(nIndex == nIndDisp, nIndTempos, 1) To nFimAux
				aTempo     := aTempos[nIndexTemp]
				dDataTempo := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nIniTempo  := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nFimTempo  := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo     := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dDataTempo == dDataStart
					If nFimTempo <= nHoraStart
						Loop
					EndIf

					If nIniTempo < nHoraStart
						nIniTempo := nHoraStart
						nTempo    := nFimTempo - nIniTempo
					EndIf
				EndIf

				If nTempoSetup > 0
					lValida := aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP .Or.;
					           aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO
					nIniValid := nIniTempo
					nFimValid := nFimTempo

					If nTempo <= nTempoSetup
						nTempoSetup -= nTempo
						nIniTempo   := nIniTempo + nTempo
					Else
						nIniTempo   := nIniTempo + nTempoSetup
						nFimValid   := nIniTempo
						nTempoSetup := 0
					EndIf
					nTempo := nFimTempo - nIniTempo

					If lValida
						lDisponivel := Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dDataTempo, nIniValid, nFimValid)
					EndIf
				EndIf

				If lDisponivel .And. nTempo > 0 .And. nTempoSetup == 0 .And. nTempoProd > 0
					lValida := aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_PRODUCAO .Or.;
					           aOperacao[ARRAY_MF_TPALOFE] == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO

					If lValida
						nIniValid := nIniTempo
						nFimValid := nFimTempo

						If nTempo <= nTempoProd
							nTempoProd -= nTempo
							nIniTempo  := nIniTempo + nTempo
						Else
							nIniTempo  := nIniTempo + nTempoProd
							nFimValid  := nIniTempo
							nTempoProd := 0
						EndIf
						nTempo := nFimTempo - nIniTempo

						lDisponivel := Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dDataTempo, nIniValid, nFimValid)
					Else
						nTempoProd := 0
					EndIf
				EndIf

				If !lDisponivel .Or. (nTempoSetup == 0 .And. nTempoProd == 0)
					Exit
				EndIf
			Next

			If !lDisponivel .Or. (nTempoSetup == 0 .And. nTempoProd == 0)
				Exit
			EndIf
		Next

		If !lDisponivel
			Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP ] := nIndex
			Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO] := nIndexTemp
		EndIf
	EndIf

	Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR       ] := lDisponivel
	Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA] := .T.

Return Nil

/*/{Protheus.doc} validaInicioAlocacao
Valida se altera a hora inicial da alocação da operação devido a disponibilidade das ferramentas.
@author Lucas Fagundes
@since 23/07/2025
@version P12
@param aOperacao , Array   , Array com as informações da operação que será alocada.
@param cRecurso  , Caracter, Recurso que a operação será alocada.
@param nSetup    , Numerico, Tempo de setup da operação que será alocada.
@param nProducao , Numerico, Tempo de produção da operação que será alocada.
@param nFinaliza , Numerico, Tempo de finalização da operação que será alocada.
@param nIndDisp  , Numerico, Indice da disponibilidade do recurso que a operação será alocada.
@param nIndTempos, Numerico, Indice do array de tempos que a operação será alocada.
@param dIniAtu   , Date    , Data de inicio atual da alocação.
@param nIniAtu   , Numerico, Hora de inicio atual da alocação (retorna por referencia o valor atualizado, caso a nova data seja na mesma posição do array de disponibilidade).
@return Nil
/*/
Method validaInicioAlocacao(aOperacao, cRecurso, nSetup, nProducao, nFinaliza, nIndDisp, nIndTempos, dIniAtu, nIniAtu) Class PCPA152TempoOperacao
	Local cTipoAloc  := aOperacao[ARRAY_MF_TPALOFE]
	Local dDataFerr  := Nil
	Local dNovaData  := Nil
	Local lBkpCriaDi := .F.
	Local lProducao  := .F.
	Local lSetup     := .F.
	Local nHoraFerr  := 0
	Local nIndcFer   := 0
	Local nIndex     := 0
	Local nNovaHora  := 0
	Local nTempFer   := 0
	Local nTempoAnt  := 0

	lSetup := cTipoAloc == TIPO_ALOCACAO_FERRAMENTA_SETUP .Or.;
	          cTipoAloc == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO

	lProducao := cTipoAloc == TIPO_ALOCACAO_FERRAMENTA_PRODUCAO .Or.;
	             cTipoAloc == TIPO_ALOCACAO_FERRAMENTA_SETUP_E_PRODUCAO

	If Self:lDecresce
		nTempoAnt := nFinaliza

		If !lProducao
			nTempoAnt += nProducao
		EndIf
	Else
		If !lSetup
			nTempoAnt := nSetup
		EndIf
	EndIf

	Self:getHoraFerramenta(cRecurso, nTempoAnt, nIndDisp, nIndTempos, dIniAtu, nIniAtu, @dDataFerr, @nHoraFerr, @nIndcFer, @nTempFer)

	If dDataFerr != Nil
		Self:getNovaDataInicial(cRecurso, nTempoAnt, nIndDisp, dDataFerr, nHoraFerr, @dNovaData, @nNovaHora, nIndcFer, nTempFer)
	EndIf

	If dNovaData == Nil
		dNovaData := dIniAtu
		nNovaHora := nIniAtu
	EndIf

	If dNovaData != dIniAtu .Or. nNovaHora != nIniAtu
		lBkpCriaDi := Self:lCriaDisp
		Self:lCriaDisp := .F.

		nIndex := Self:buscaIndiceDisponibilidade(cRecurso, dNovaData, nNovaHora, Self:lDispAdc)
		If nIndex == nIndDisp
			nIniAtu := nNovaHora

		Else
			If Self:lDecresce
				Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP ] := nIndex
				Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO] := Len(Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE])
			Else
				Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP ] := nIndex
				Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO] := 1
			EndIf

			Self:aIntervalo[ARRAY_INTERVALO_PODE_ALOCAR       ] := .F.
			Self:aIntervalo[ARRAY_INTERVALO_VALIDOU_FERRAMENTA] := .T.
		EndIf

		Self:lCriaDisp := lBkpCriaDi
	EndIf

Return Nil

/*/{Protheus.doc} getHoraFerramenta
Identifica a hora que irá alocar as ferramentas dentro do intervalo de alocação.
@author Lucas Fagundes
@since 24/07/2025
@version P12
@param cRecurso  , Caracter, Recurso que a operação esta sendo alocada.
@param nTempoAnt , Numerico, Tempo de alocação antes do uso da ferramenta.
@param nIndDisp  , Numerico, Indice da disponibilidade do recurso que inicia a alocaçaão da operação que esta sendo alocada.
@param nIndTempos, Numerico, Indice do array de tempos que inicia a alocaçaão da operação que esta sendo alocada.
@param dIniAtu   , Date    , Data de inicio atual da alocação.
@param nIniAtu   , Numerico, Hora de inicio atual da alocação.
@param dDataFerr , Date    , Data que as ferramentas serão alocadas (retorna por referência).
@param nHoraFerr , Numerico, Hora que as ferramentas serão alocadas (retorna por referência).
@param nRetIndex , Numerico, Indice do array de disponibilidade que as ferramentas serão alocadas (retorna por referência).
@param nRetIndxTp, Numerico, Indice do array de tempos que as ferramenta serão alocadas (retorna por referência).
@return Nil
/*/
Method getHoraFerramenta(cRecurso, nTempoAnt, nIndDisp, nIndTempos, dIniAtu, nIniAtu, dDataFerr, nHoraFerr, nRetIndex, nRetIndxTp) Class PCPA152TempoOperacao
	Local aFerraDisp := {}
	Local aTempos    := {}
	Local dData      := 0
	Local nFimAux    := 0
	Local nHrFim     := 0
	Local nHrIni     := 0
	Local nIndex     := 0
	Local nIndexTemp := 0
	Local nIndFim    := 0
	Local nTamDisp   := 0
	Local nTempo     := 0
	Local nTempoAux  := 0

	dDataFerr := Nil
	nHoraFerr := 0
	nTempoAux := nTempoAnt

	If Self:lDecresce
		nIndFim := Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_DISP]

		For nIndex := nIndDisp To nIndFim Step -1
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nFimAux := 1

			If nIndex == nIndFim
				nFimAux := Self:aIntervalo[ARRAY_INTERVALO_RANGE_INICIO_TEMPO]
			EndIf

			For nIndexTemp := Iif(nIndex == nIndDisp, nIndTempos, Len(aTempos)) To nFimAux Step -1
				aTempo := aTempos[nIndexTemp]
				dData  := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nHrIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nHrFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dData == dIniAtu .And. nHrFim > nIniAtu
					nHrFim := nIniAtu
					nTempo := nHrFim - nHrIni
				EndIf

				If nTempoAux > 0
					If nTempo <= nTempoAux
						nTempoAux -= nTempo
						Loop
					Else
						nHrFim    := nHrFim - nTempoAux
						nTempo    := nHrFim - nHrIni
						nTempoAux := 0
					EndIf
				EndIf

				If nTempoAux == 0
					Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dData, nHrIni, nHrFim, @aFerraDisp)
					nTamDisp := Len(aFerraDisp)

					If nTamDisp > 0
						dDataFerr := aFerraDisp[nTamDisp]["data"   ]
						nHoraFerr := aFerraDisp[nTamDisp]["horaFim"]
					EndIf

					aSize(aFerraDisp, 0)
				EndIf

				If dDataFerr != Nil
					Exit
				EndIf
			Next

			If dDataFerr != Nil
				Exit
			EndIf
		Next
	Else
		nIndFim := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_DISP]

		For nIndex := nIndDisp To nIndFim
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nFimAux := Len(aTempos)

			If nIndex == nIndFim
				nFimAux := Self:aIntervalo[ARRAY_INTERVALO_RANGE_FIM_TEMPO]
			EndIf

			For nIndexTemp := Iif(nIndex == nIndDisp, nIndTempos, 1) To nFimAux
				aTempo := aTempos[nIndexTemp]
				dData  := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nHrIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nHrFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dData == dIniAtu .And. nHrIni < nIniAtu
					nHrIni := nIniAtu
					nTempo := nHrFim - nHrIni
				EndIf

				If nTempoAux > 0
					If nTempo <= nTempoAux
						nTempoAux -= nTempo
						Loop
					Else
						nHrIni    := nHrIni + nTempoAux
						nTempo    := nHrFim - nHrIni
						nTempoAux := 0
					EndIf
				EndIf

				If nTempoAux == 0
					Self:oFerramentas:verificaDisponibilidadeFerramentas(Self:aFerramentas, dData, nHrIni, nHrFim, @aFerraDisp)
					nTamDisp := Len(aFerraDisp)

					If nTamDisp > 0
						dDataFerr := aFerraDisp[1]["data"      ]
						nHoraFerr := aFerraDisp[1]["horaInicio"]
					EndIf

					aSize(aFerraDisp, 0)
				EndIf

				If dDataFerr != Nil
					Exit
				EndIf
			Next

			If dDataFerr != Nil
				Exit
			EndIf
		Next
	EndIf

	nRetIndex  := nIndex
	nRetIndxTp := nIndexTemp

Return Nil

/*/{Protheus.doc} getNovaDataInicial
Identifica a nova data de inicio/entrega da alocação a partir da data que irá alocar as ferramentas.
@author Lucas Fagundes
@since 24/07/2025
@version P12
@param cRecurso , Caracter, Recurso que a operação esta sendo alocada.
@param nTempoAnt, Numerico, Tempo de alocação antes do uso da ferramenta.
@param nIndDisp , Numerico, Indice da disponibilidade do recurso que inicia a alocaçaão da operação que esta sendo alocada.
@param dDataFerr, Date    , Data que as ferramentas serão alocadas.
@param nHoraFerr, Numerico, Hora que as ferramentas serão alocadas.
@param dNovaData, Date    , Retorna por referência nova data de inicio/entrega da alocação.
@param nNovaHora, Numerico, Retorna por referência nova hora de inicio/entrega da alocação.
@param nIndcFer , Numerico, Indice do array de disponibilidade que as ferramentas serão alocadas.
@param nTempFer , Numerico, Indice do array de tempos que as ferramenta serão alocadas.
@return Nil
/*/
Method getNovaDataInicial(cRecurso, nTempoAnt, nIndDisp, dDataFerr, nHoraFerr, dNovaData, nNovaHora, nIndcFer, nTempFer) Class PCPA152TempoOperacao
	Local aTempos    := {}
	Local dData      := 0
	Local nFimAux    := 0
	Local nHrFim     := 0
	Local nHrIni     := 0
	Local nIndex     := 0
	Local nIndexAux  := 0
	Local nIndexTemp := 0
	Local nIndTemAux := 0
	Local nTempo     := 0
	Local nTempoAux  := 0

	If nTempoAnt == 0
		dNovaData := dDataFerr
		nNovaHora := nHoraFerr

		Return Nil
	EndIf
	dNovaData  := Nil
	nNovaHora  := 0
	nTempoAux  := nTempoAnt
	nIndexAux  := nIndcFer
	nIndTemAux := nTempFer

	If Self:lDecresce
		For nIndex := nIndexAux To nIndDisp
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]
			nFimAux := Len(aTempos)

			For nIndexTemp := Iif(nIndex == nIndexAux, nIndTemAux, 1) To nFimAux
				aTempo := aTempos[nIndexTemp]
				dData  := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nHrIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nHrFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dData == dDataFerr
					If nHrFim <= nHoraFerr
						Loop
					EndIf

					If nHrIni < nHoraFerr
						nHrIni := nHoraFerr
						nTempo := nHrFim - nHrIni
					EndIf
				EndIf

				If nTempo <= nTempoAux
					nTempoAux -= nTempo
				Else
					nHrFim    := nHrIni + nTempoAux
					nTempo    := nHrFim - nHrIni
					nTempoAux := 0
				EndIf

				If nTempoAux == 0
					dNovaData := dData
					nNovaHora := nHrFim
				EndIf

				If dNovaData != Nil
					Exit
				EndIf
			Next

			If dNovaData != Nil
				Exit
			EndIf
		Next
	Else
		For nIndex := nIndexAux To nIndDisp Step -1
			aTempos := Self:oDispRecur[cRecurso][nIndex][ARRAY_DISP_RECURSO_DISPONIBILIDADE]

			For nIndexTemp := Iif(nIndex == nIndexAux, nIndTemAux, Len(aTempos)) To 1 Step -1
				aTempo := aTempos[nIndexTemp]
				dData  := aTempo[ARRAY_DISPONIBILIDADE_DATA       ]
				nHrIni := aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO]
				nHrFim := aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM   ]
				nTempo := aTempo[ARRAY_DISPONIBILIDADE_TEMPO      ]

				If dData == dDataFerr
					If nHrIni >= nHoraFerr
						Loop
					EndIf

					If nHrFim > nHoraFerr
						nHrFim := nHoraFerr
						nTempo := nHrFim - nHrIni
					EndIf
				EndIf

				If nTempo <= nTempoAux
					nTempoAux -= nTempo
				Else
					nHrFim    := nHrFim - nTempoAux
					nTempo    := nHrFim - nHrIni
					nTempoAux := 0
				EndIf

				If nTempoAux == 0
					dNovaData := dData
					nNovaHora := nHrFim
				EndIf

				If dNovaData != Nil
					Exit
				EndIf
			Next

			If dNovaData != Nil
				Exit
			EndIf
		Next
	EndIf

Return Nil

/*/{Protheus.doc} tempoValido
Verifica se o intervalo de tempo é valido para alocação da operação.
@author Lucas Fagundes
@since 06/08/2025
@version P12
@param aTempo, Array   , Intervalo de tempo a ser validado.
@param nHora , Numerico, Hora inicial da alocação.
@return lValido, Logico, Indica se o intervalo de tempo é valido para alocação da operação.
/*/
Method tempoValido(aTempo, nHora) Class PCPA152TempoOperacao
	Local lValido := .T.

	If aTempo[ARRAY_DISPONIBILIDADE_TIPO] != VM_TIPO_DISPONIVEL
		lValido := .F.
	EndIf

	If lValido
		If Self:lDecresce
			// Periodo após a hora de consumo.
			//               | PERIODO |
			// <- CONSUMO |
			If aTempo[ARRAY_DISPONIBILIDADE_HORA_INICIO] >= nHora
				lValido := .F.
			EndIf
		Else
			// Periodo antes da hora de consumo.
			//    | PERIODO |
			//                  | CONSUMO ->
			If aTempo[ARRAY_DISPONIBILIDADE_HORA_FIM] <= nHora
				lValido := .F.
			EndIf
		EndIf
	EndIf

Return lValido

/*/{Protheus.doc} getTempoFinalizacao
Retorna o tempo de finalização da operação.
@author Lucas Fagundes
@since 24/06/2025
@version P12
@param 01 aOperacao, Array   , Array com as informações da operação.
@param 02 cRecurso , Caracter, Recurso que a operação será alocada.
@return nTempoFina, Numerico, Tempo de finalização da operação no recurso.
/*/
Method getTempoFinalizacao(aOperacao, cRecurso) Class PCPA152TempoOperacao
	Local nTempoFina := aOperacao[ARRAY_MF_TMPFINA]
	Local oDisp      := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)

	// Não aplica tempo de finalização se o recurso for ilimitado.
	If oDisp:recursoIlimitado(cRecurso)
		nTempoFina := 0
	EndIf

Return nTempoFina
