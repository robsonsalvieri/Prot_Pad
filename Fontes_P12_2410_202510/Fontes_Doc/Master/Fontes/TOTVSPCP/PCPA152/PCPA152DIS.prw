#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE CALEND_POS_HORAS    1
#DEFINE CALEND_POS_MINUTOS  2
#DEFINE CALEND_POS_HORAINI  1
#DEFINE CALEND_POS_HORAFIM  2
#DEFINE CALEND_POS_TOTAL    3

#DEFINE IDENTIFICADOR_FERRAMENTA "_FERRAM"

/*/{Protheus.doc} PCPA152Disponibilidade
Classe responsável por calcular a disponibilidade dos recursos.

@author lucas.franca
@since 01/02/2023
@version P12
/*/
CLASS PCPA152Disponibilidade FROM LongNameClass

	Private Data aDispAloc  as Array
	Private Data cBanco     as Caracter
	Private Data cFilSMK    as Character
	Private Data cFilSMR    as Character
	Private Data cFilHWF    as Character
	Private Data cFilSC2    as Character
	Private Data cEtapa     as Character
	Private Data lAdicional as Logical
	Private Data lCRP       as Logical
	Public  Data lSimula    as Logical
	Private Data lCampoAlt  as Logical
	Private Data nTamMKSEQ  as Number
	Private Data nTamMRDISP as Number
	Private Data oBlockRec  as Object
	Private Data oCalend    as Object
	Private Data oEfetivas  as Object
	Private Data oExcCalend as Object
	Private Data oIndcAloc  as Object
	Private Data oInfoAdc   as Object
	Private Data oParDisp   as Object
	Private Data oProcesso  as Object
	Private Data oQryBlock  as Object
	Private Data oProdsEfet as Object
	Private Data oIndcEfet  as Object

	//Métodos para uso externo
	Public Method New(oProcesso) CONSTRUCTOR
	Public Method Destroy()
	Public Method calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi, lAdicional, oInfoAdc)
	Public Method carregaDisponibilidade()
	Public Method gravaDados()
	Public Method defineParametro(cParametro, xValor)
	Public Method processaRecursos(lAdicional)
	Public Method getDisponibilidadeRecurso(cRecurso, lAdicional)
	Public Method setDisponibilidadeRecurso(cRecurso, aDisp, lAdicional)
	Public Method efetivaDisponibilidadeAdicional()
	Public Method setJsonIndicesDisponibilidadeAlocacao(cRecurso, oJson, lAdicional)
	Public Method getJsonIndicesDisponibilidadeAlocacao(cRecurso, lAdicional)
	Public Method limpaDisponibilidadeAdicional(lLimpaFlag)
	Public Method buscaDataUltimaDisponibilidadeRecurso(cRecurso)
	Public Method getInfoRecurso(cRecurso)
	Public Method limpaUltimaDataSimulada(cRecurso)
	Public Method setAdicional(lAdicional)
	Public Method recursoIlimitado(cRecurso)

	//Métodos de uso interno
	Private Method aguardaCargaTabelas()
	Private Method ajustaHoraInicial(aCalend)
	Private Method buscaBloqueiosEExecao(oJsData, dData, cRecurso, cCentCusto)
	Private Method buscaCalendario(dData, cCalend)
	Private Method buscaEfetivadas(dData)
	Public Method buscaSequenciaSMR()
	Private Method chaveExcecao(cData, cRecurso, cCentCusto)
	Private Method criaDisponibilidadeParaAlocacao(aDispSMK, cAlias)
	Private Method criaPeriodoDisponibilidade(aDispSMK, cAlias, cRecurso, nIndDisp, cSituacao)
	Public Method geraDetalheDisponibilidade(dData, aCalPad, aCalExc, aBloqueio, aEfetivas, cCodDisp, cRecurso, lFerram, cSituacao)
	Private Method montaParametros()
	Private Method preparaGeracaoAdicional(cRecurso, oInfo)
	Private Method processandoRecursos(nTotRecur, nQtdProc)
	Private Method registraRecursoCT(oRecXCTrb, cRecurso, cCodCT)
	Private Method retornaQueryRecursos()
	Private Method totalDeMinutos(cHoraIni, cHoraFim)
	Private Method uneCalendarioExcecao(aCalExc, aCalPad)
	Private Method validaBloqueios(aHoras, aTotais, aBloqueio)
	Private Method validaEfetivadas(aHoras, aTotais, aEfetivas)
	Public Method setDispSMR(cRecurso, aRegs, lAdicional, lFerram)
	Private Method setDispSMK(cCodDisp, aRegs, lAdicional)
	Private Method setInfoRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi)
	Private Method getUltimaDataRecurso(cRecurso, lAdicional, lError, lSimula)
	Private Method setUltimaDataRecurso(cRecurso, dData, lAdicional, lSimula)
	Private Method limpaFlagDisponibilidadeAdicionalRecurso(cRecurso)
	Private Method setFimDataDispAdicional(dData, lTemp)
	Public Method getFimDataDispAdicional(lTemp, lError)
	Private Method buscaProdutosEfetivados(cRecurso, dData, nHoraIni, nHoraFim)
	Private Method carregaProdutosEfetivados()
	Private Method setJsonEfetivados(cRecurso, oJson, lAdicional)
	Private Method atualizaParametroDataDisponibilidade(lAdicional)
	Private Method converteArrayProcessamentoParaGravacao(aProc, cTabela)
	Public Method carregaSMR()
	Public Method carregaSMK()
	Public Method getDispSMR(cRecurso, lAdicional, lFerram)
	Public Method getDispSMK(cCodDisp, lAdicional)
	Public Method gravaTabela(cTabela, aDados)
	Public Method gravaRecursoCT(oRecXCTrb)
	Public Method getJsonEfetivados(cRecurso, lAdicional)
	Public Method calculaTempoTotal(aDisp)
	Public Method criaArraySMR(cRecurso, lFerram, cCalend, cRecIlimi)

	//Métodos para manipulação do calendário
	Private Method carregaCalendario(cCalend)
	Private Method carregaBloqueioRecurso(cRecurso, cCentCusto)
	Private Method carregaExcecaoCalendario(cRecurso, cCentCusto)
	Private Method carregaEfetivadas(cRecurso)
	Private Method converteHorasCalendario(cAloc)
	Private Method horaPosicionada(nPosicao)

	//Disponibiliza cálculo das horas de calendário sem a necessidade da classe de programação.
	Static Method buscaHorasRecurso(cRecurso, dDataIni, dDataFim)
	Static Method descricaoTipoHora(cTipo)
	Static Method estruturaTabela(cTabela)

EndClass

/*/{Protheus.doc} New
Método construtor da classe.

@author lucas.franca
@since 01/02/2023
@version P12
@param 01 oProcesso, Object, Objeto de controle do processo da programação
@return Self, Object, Instância da classe
/*/
Method New(oProcesso) CLASS PCPA152Disponibilidade
	Local oInicio := Nil

	Self:oCalend    := JsonObject():New()
	Self:oProcesso  := oProcesso
	Self:lCRP       := Self:oProcesso != Nil
	Self:lAdicional := .F.
	Self:lSimula    := .F.
	Self:oInfoAdc   := Nil
	Self:cEtapa     := CHAR_ETAPAS_CALC_DISP
	Self:cBanco     := TCGetDb()
	Self:lCampoAlt  := GetSx3Cache("MR_ALTDISP", "X3_TAMANHO") > 0

	//Parâmetros utilizados por esta classe. Dados são obtidos de oProcesso quando existir,
	//ou serão definidos pelo método defineParametro quando utilizado sem o uso da programação.
	//Se adicionar novos parâmetros, verificar também o novo parâmetro no método montaParametros.

	Self:montaParametros()

	If Self:lCRP
		oInicio := Self:oProcesso:getStatusInicioProgramacao()

		Self:cFilSMR    := xFilial("SMR")
		Self:cFilSMK    := xFilial("SMK")
		Self:cFilHWF    := xFilial("HWF")
		Self:cFilSC2    := xFilial("SC2")
		Self:nTamMRDISP := GetSX3Cache("MR_DISP", "X3_TAMANHO")
		Self:nTamMKSEQ  := GetSX3Cache("MK_SEQ" , "X3_TAMANHO")
		Self:aDispAloc  := {}
		Self:oIndcAloc  := JsonObject():New()
		Self:oIndcEfet  := JsonObject():New()

		FreeObj(oInicio)
	Else
		Self:cFilSMR    := ""
		Self:cFilSMK    := ""
		Self:cFilHWF    := ""
		Self:cFilSC2    := ""
		Self:nTamMRDISP := 10
		Self:nTamMKSEQ  := 3
		Self:aDispAloc  := Nil
		Self:oIndcAloc  := Nil
		Self:oIndcEfet  := Nil
	EndIf

Return Self

/*/{Protheus.doc} Destroy
Limpa as propriedades da classe

@author lucas.franca
@since 09/02/2023
@version P12
@return Nil
/*/
Method Destroy() CLASS PCPA152Disponibilidade

	If Self:oQryBlock <> Nil
		Self:oQryBlock:Destroy()
		Self:oQryBlock := Nil
	EndIf

	Self:oProcesso  := Nil
	Self:cFilSMR    := Nil
	Self:cFilSMK    := Nil
	Self:cFilHWF    := Nil
	Self:cFilSC2    := Nil
	Self:nTamMRDISP := Nil
	Self:nTamMKSEQ  := Nil

	FwFreeArray(Self:aDispAloc)
	FwFreeObj(Self:oCalend)
	FwFreeObj(Self:oParDisp)
	FwFreeObj(Self:oIndcAloc)
	FwFreeObj(Self:oIndcEfet)
Return

/*/{Protheus.doc} calculaDispRecurso
Faz o cálculo da disponibilidade para um recurso

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, Código do recurso
@param 02 cCalend   , Caracter, Código do calendário vinculado ao recurso
@param 03 cCentCusto, Caracter, Código do centro de custo vinculado ao recurso
@param 04 cRecIlimi , Caracter, Indicador se o recurso é ilimitado
@param 05 lAdicional, Logico  , Indica que está gerando disponibilidade adicional para um recurso.
@param 06 oInfoAdc  , Object  , Informações adicionais para geração da disponibilidade adicional.
@return aRegs, Array, Array com os dados da disponibilidade. Somente quando utilizado sem a programação.
/*/
Method calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi, lAdicional, oInfoAdc) CLASS PCPA152Disponibilidade
	Local aBloqueio := Nil
	Local aEfetivas := Nil
	Local aCalExc   := Nil
	Local aCalPad   := Nil
	Local aDisp     := Array(ARRAY_MR_TAMANHO)
	Local aRegs     := {}
	Local aTotais   := {}
	Local dData     := Nil
	Local dDataFim  := Nil
	Local nLenReg   := 0
	Local nSequen   := 0
	Local lHrIni    := .F.

	//Verifica se o calendário do recurso já foi carregado.
	Self:carregaCalendario(cCalend)

	Self:lAdicional := lAdicional .And. oInfoAdc != Nil
	If Self:lAdicional
		Self:oInfoAdc := oInfoAdc
		Self:oInfoAdc["calendario"] := cCalend

		If !Self:preparaGeracaoAdicional(cRecurso, Self:oInfoAdc)
			Return aRegs
		EndIf
	EndIf

	dData    := Self:oParDisp["dataInicial"]
	dDataFim := Self:oParDisp["dataFinal"  ]
	lHrIni   := !lAdicional

	//Carrega exceções e bloqueios do recurso
	Self:carregaExcecaoCalendario(cRecurso, cCentCusto)
	Self:carregaBloqueioRecurso(cRecurso, cCentCusto)

	IF Self:lCRP
		Self:carregaEfetivadas(cRecurso)

		Self:aDispAloc := Self:getDisponibilidadeRecurso(cRecurso, Self:lAdicional)
		Self:oIndcAloc := Self:getJsonIndicesDisponibilidadeAlocacao(cRecurso, Self:lAdicional)
		Self:oIndcEfet := Self:getJsonEfetivados(cRecurso, Self:lAdicional)
	EndIf

	//Carrega valores fixos do array aDisp
	aDisp := Self:criaArraySMR(cRecurso, .F., cCalend, cRecIlimi)

	//Percorre dia por dia para gerar a disponibilidade
	While dData <= dDataFim
		//Busca dados calendário padrão, exceção de calendário e bloqueio de recursos
		aCalPad   := Self:buscaCalendario(dData, cCalend)
		aCalExc   := Self:buscaBloqueiosEExecao(Self:oExcCalend, dData, cRecurso, cCentCusto)
		aBloqueio := Self:buscaBloqueiosEExecao(Self:oBlockRec , dData, cRecurso, cCentCusto)

		If Self:lCRP
			aEfetivas := Self:buscaEfetivadas(dData)
		Endif

		If lHrIni .And. dData == Self:oParDisp["dataInicial"]
			Self:ajustaHoraInicial(@aCalPad)
			Self:ajustaHoraInicial(@aCalExc)
		EndIf

		//Total de horas disponíveis no calendário
		aDisp[ARRAY_MR_TEMPODI] := aCalPad[CALEND_POS_MINUTOS]
		//Inicializa horas bloqueadas, paradas, extras e horas recurso para 0
		aDisp[ARRAY_MR_TEMPOBL] := 0
		aDisp[ARRAY_MR_TEMPOPA] := 0
		aDisp[ARRAY_MR_TEMPOEX] := 0
		aDisp[ARRAY_MR_TEMPOEF] := 0
		aDisp[ARRAY_MR_TEMPOTO] := 0

		//Somente registra se existir algum horário
		If aDisp[ARRAY_MR_TEMPODI] != 0 .Or. !Empty(aCalExc) .Or. !Empty(aBloqueio) .Or. !Empty(aEfetivas)

			//Atualiza sequencia e data da disponibilidade
			If Self:lCRP
				nSequen := Self:buscaSequenciaSMR()
			Else
				nSequen++
			EndIf
			aDisp[ARRAY_MR_DISP   ] := StrZero(nSequen, Self:nTamMRDISP)
			aDisp[ARRAY_MR_DATDISP] := dData

			//Gera dados da SMK
			aTotais := Self:geraDetalheDisponibilidade(dData                 ,;
			                                           aCalPad               ,;
			                                           aCalExc               ,;
			                                           aBloqueio             ,;
			                                           aEfetivas             ,;
			                                           aDisp[ARRAY_MR_DISP]  ,;
			                                           cRecurso              ,;
			                                           .F.                   ,;
			                                           aDisp[ARRAY_MR_SITUACA])

			//Atualiza as horas extras, paradas e bloqueadas conforme o detalhamento gerado na SMK
			If aTotais[1] > 0
				aDisp[ARRAY_MR_TEMPOPA] := aTotais[1]
			EndIf
			If aTotais[2] > 0
				aDisp[ARRAY_MR_TEMPOEX] := aTotais[2]
			EndIf
			If aTotais[3] > 0
				aDisp[ARRAY_MR_TEMPOBL] := aTotais[3]
			EndIf
			If aTotais[4] > 0
				aDisp[ARRAY_MR_TEMPOEF] := aTotais[4]
			EndIf
			If aTotais[5] > 0
				aDisp[ARRAY_MR_TEMPODI] += aTotais[5]
			EndIf
			aSize(aTotais, 0)

			Self:calculaTempoTotal(@aDisp)

			aAdd(aRegs, aClone(aDisp))

			If Self:lAdicional .And. dData >= Self:oInfoAdc["dataAlocacao"]
				Self:oInfoAdc["tempoAlocacao"] -= aDisp[ARRAY_MR_TEMPOTO]
			EndIf
		EndIf

		aSize(aCalPad  , 0)
		aSize(aCalExc  , 0)
		aSize(aBloqueio, 0)

		//Verifica próxima data
		dData++

		If Self:lAdicional .And. Self:oInfoAdc["tempoAlocacao"] <= 0
			Exit
		EndIf
	End

	If Self:lAdicional
		Self:oInfoAdc["dataFinal"] := dData

		If !Self:lSimula
			Self:setFimDataDispAdicional(dData, .T.)
		EndIf
	EndIf

	//Adiciona dados na memória global
	If Self:lCRP
		nLenReg := Len(aRegs)

		If nLenReg > 0
			dDataFim := aRegs[Len(aRegs)][ARRAY_MR_DATDISP]

			// Se estiver gerando disponibilidade adicional e estiver simulando, grava apenas a flag com a última data do recurso para caso precise gerar novamente a disponibilidade adicional
			// (teve exceção/bloqueio no período gerado e não gerou disponibilidade suficiente para finalizar a alocação)
			Self:setUltimaDataRecurso(cRecurso, dDataFim, Self:lAdicional, Self:lSimula)

			If !Self:lSimula
				Self:setDispSMR(cRecurso, aRegs, Self:lAdicional)
			EndIf
		EndIf

		If !Self:lSimula
			Self:setDisponibilidadeRecurso(cRecurso, Self:aDispAloc, Self:lAdicional)
			Self:setJsonIndicesDisponibilidadeAlocacao(cRecurso, Self:oIndcAloc, Self:lAdicional)
			Self:setJsonEfetivados(cRecurso, Self:oIndcEfet, Self:lAdicional)
		EndIf

		If Self:lAdicional
			Self:oInfoAdc["criouDisp"] := nLenReg > 0 .And. dDataFim >= Self:oInfoAdc["dataAlocacao"]

			oInfoAdc      := Self:oInfoAdc
			Self:oInfoAdc := Nil
		Else
			Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 1, .T., .T.)
		EndIf

		aSize(aDisp, 0)
		aSize(aRegs, 0)
	EndIf

	aDisp := Nil
	FreeObj(Self:oExcCalend)
	FreeObj(Self:oBlockRec)

	If Self:lCRP
		FreeObj(Self:oEfetivas)
		FreeObj(Self:oProdsEfet)
	Endif

Return aRegs

/*/{Protheus.doc} gravaDados
Delega a gravação das tabelas da disponbilidade.

@author lucas.franca
@since 08/02/2023
@version P12
@return Nil
/*/
Method gravaDados() CLASS PCPA152Disponibilidade
	Local oInicio := Self:oProcesso:getStatusInicioProgramacao()

	Self:oProcesso:delegar("P152GrvDis", Self:oProcesso:retornaProgramacao(), "SMR")
	Self:oProcesso:delegar("P152GrvDis", Self:oProcesso:retornaProgramacao(), "SMK")

	If !oInicio["continuando"] .And. !oInicio["reprocessando"]
		Self:oProcesso:delegar("P152GrvDis", Self:oProcesso:retornaProgramacao(), "SMT")
	Else
		Self:oProcesso:gravaValorGlobal("REGISTROS_GRAVADOS", 1, .T., .T.)
		Self:oProcesso:gravaValorGlobal("GRAVACAO_SMT", "END")
	EndIf

	FreeObj(oInicio)
Return Nil

/*/{Protheus.doc} P152GrvDis
Realiza a gravação de uma tabela da disponibilidade em outra thread.
@type  Function
@author Lucas Fagundes
@since 06/03/2024
@version P12
@param 01 cProg  , Caracter, Código da programação.
@param 02 cTabela, Caracter, Tabela que irá realizar a gravação.
@return Nil
/*/
Function P152GrvDis(cProg, cTabela)
	Local aDados    := {}
	Local lSucesso  := .T.
	Local oSelf     := Nil
	Local oProcesso := Nil
	Local oRecXCTrb := Nil

	PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_DISP, @oSelf)
	PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso)

	BEGIN TRANSACTION
		If cTabela == "SMT"
			oRecXCTrb := JsonObject():New()

			oRecXCTrb:fromJson(oProcesso:retornaValorGlobal("JSON_RECXCTRAB"))

			lSucesso := oSelf:gravaRecursoCT(oRecXCTrb)

			FreeObj(oRecXCTrb)
		Else
			If cTabela == "SMR"
				aDados := oSelf:getDispSMR(Nil, .F.)
			ElseIf cTabela == "SMK"
				aDados := oSelf:getDispSMK(Nil, .F.)
			EndIf

			lSucesso := oSelf:gravaTabela(cTabela, aDados)

			oProcesso:limpaListaGlobal("DADOS_" + cTabela)
		EndIf
	END TRANSACTION

	oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, Iif(lSucesso, "END", "ERRO"))

Return Nil

/*/{Protheus.doc} defineParametro
Grava um parâmetro no objeto de parâmetros desta classe, para utilização
sem a classe de programação (PCPA152Process)

@author lucas.franca
@since 13/02/2023
@version P12
@param 01 cParametro, Caracter, Código do parâmetro
@param 02 xValor    , Any     , Valor do parâmetro
@return Nil
/*/
Method defineParametro(cParametro, xValor) CLASS PCPA152Disponibilidade
	Self:oParDisp[cParametro] := xValor
Return

/*/{Protheus.doc} buscaCalendario
Busca o array de calendário para um determinado dia no Json de calendários

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 dData  , Date    , Data para busca
@param 02 cCalend, Caracter, Código do calendário
@return aCalend, Array, Array com a cópia do calendário padrão
/*/
Method buscaCalendario(dData, cCalend) CLASS PCPA152Disponibilidade
	Local nDia    := Dow(dData)

Return aClone(Self:oCalend[cCalend][nDia])

/*/{Protheus.doc} buscaBloqueiosEExecao
Busca a exceção de calendário ou bloqueio de recurso para o recurso em determinada data.
Ordem para considerar os dados:
1° procura a exceção para RECURSO e CCUSTO iguais ao cRecurso e cCentCusto
2° procura a exceção para RECURSO igual a cRecurso e H9_CCUSTO em branco
3° procura a exceção para RECURSO em branco e CCUSTO igual a cCentCusto
4° procura a exceção para RECURSO em branco e CCUSTO em branco
Irá utilizar o primeiro registro que encontrar.

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 oJsData   , Object  , Json com os dados da exceção de calendário ou bloqueio de recurso
@param 02 dData     , Date    , Data para busca da exceção
@param 03 cRecurso  , Caracter, Código do recurso para busca
@param 04 cCentCusto, Caracter, Código do centro de custo do recurso
@return aDados, Array, Array com as horas que devem ser utilizadas
/*/
Method buscaBloqueiosEExecao(oJsData, dData, cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local aChaves := {}
	Local aDados  := {}
	Local cData   := DtoS(dData)
	Local nIndex  := 0
	Local nTotal  := 0

	//Monta as chaves de cada busca no array aChaves
	aAdd(aChaves, Self:chaveExcecao(cData, cRecurso, cCentCusto)) // RECURSO + CENTRO CUSTO
	aAdd(aChaves, Self:chaveExcecao(cData, cRecurso, ""        )) // SÓ RECURSO
	aAdd(aChaves, Self:chaveExcecao(cData, ""      , cCentCusto)) // SÓ CENTRO CUSTO
	aAdd(aChaves, Self:chaveExcecao(cData, ""      , ""        )) // GERAL

	nTotal := Len(aChaves)
	For nIndex := 1 To nTotal
		If oJsData:HasProperty(aChaves[nIndex])
			aDados := aClone(oJsData[aChaves[nIndex]])
			Exit
		EndIf
	Next nIndex
	aSize(aChaves, 0)

Return aDados

/*/{Protheus.doc} buscaEfetivadas
Busca o array de efetivadas para um determinado dia

@author marcelo.neumann
@since 11/10/2023
@version P12
@param  dData    , Data , Data para busca
@return aEfetivas, Array, Array com a cópia das horas efetivadas
/*/
Method buscaEfetivadas(dData) CLASS PCPA152Disponibilidade
	Local cData := DToS(dData)

Return aClone(Self:oEfetivas[cData])

/*/{Protheus.doc} estruturaTabela
Carrega a estrutura das tabelas que serão gravadas para uso durante o processo.
O array de retorno deve sempre seguir a ordem das colunas definidas nas constantes utilizadas para as tabelas.

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 cTabela, Caracter, Tabela que será carregada
@return aEstrut, Array, Array com os campos da estrutura da tabela.
/*/
Method estruturaTabela(cTabela) CLASS PCPA152Disponibilidade
	Local aEstrut := {}

	Do Case
		Case cTabela == "SMR"
			aAdd(aEstrut, {"MR_FILIAL" })
			aAdd(aEstrut, {"MR_PROG"   })
			aAdd(aEstrut, {"MR_DISP"   })
			aAdd(aEstrut, {"MR_RECURSO"})
			aAdd(aEstrut, {"MR_TIPO"   })
			aAdd(aEstrut, {"MR_CALEND" })
			aAdd(aEstrut, {"MR_DATDISP"})
			aAdd(aEstrut, {"MR_SITUACA"})
			aAdd(aEstrut, {"MR_TEMPODI"})
			aAdd(aEstrut, {"MR_TEMPOBL"})
			aAdd(aEstrut, {"MR_TEMPOPA"})
			aAdd(aEstrut, {"MR_TEMPOEX"})
			aAdd(aEstrut, {"MR_TEMPOEF"})
			aAdd(aEstrut, {"MR_TEMPOTO"})

			If GetSX3Cache("MR_ALTDISP", "X3_TAMANHO") > 0
				aAdd(aEstrut, {"MR_ALTDISP"})
				aAdd(aEstrut, {"MR_SEQFER" })
			EndIf

		Case cTabela == "SMK"
			aAdd(aEstrut, {"MK_FILIAL" })
			aAdd(aEstrut, {"MK_PROG"   })
			aAdd(aEstrut, {"MK_DISP"   })
			aAdd(aEstrut, {"MK_SEQ"    })
			aAdd(aEstrut, {"MK_DATDISP"})
			aAdd(aEstrut, {"MK_HRINI"  })
			aAdd(aEstrut, {"MK_HRFIM"  })
			aAdd(aEstrut, {"MK_TIPO"   })
			aAdd(aEstrut, {"MK_BLOQUE" })

		Case cTabela == "SMT"
			aAdd(aEstrut, {"MT_FILIAL" })
			aAdd(aEstrut, {"MT_PROG"   })
			aAdd(aEstrut, {"MT_RECURSO"})
			aAdd(aEstrut, {"MT_CTRAB"  })

	EndCase

Return aEstrut

/*/{Protheus.doc} chaveExcecao
Monta a chave padronizada para utilização no objeto Self:oExcCalend

@author lucas.franca
@since 03/02/2023
@version P12
@param 01 cData     , Caracter, Data no formato CHAR
@param 02 cRecurso  , Caracter, Código do recurso
@param 03 cCentCusto, Caracter, Código do centro de custo
@return cChave, Caracter, Chave padronizada.
/*/
Method chaveExcecao(cData, cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cChave := cData + CHR(10) + RTrim(cRecurso) + CHR(10) + RTrim(cCentCusto)
Return cChave

/*/{Protheus.doc} geraDetalheDisponibilidade
Processa os dados para geração dos detalhes da disponibilidade (SMK)

@author lucas.franca
@since 07/02/2023
@version P12
@param 01 dData    , Date    , Data da disponibilidade
@param 02 aCalPad  , Array   , Dados de horas do calendário padrão
@param 03 aCalExc  , Array   , Dados de horas do calendário de exceção
@param 04 aBloqueio, Array   , Dados de bloqueio de recursos
@param 05 aEfetivas, Array   , Dados de horas efetivadas
@param 06 cCodDisp , Caracter, Código da disponibilidade (MR_DISP)
@param 07 cRecurso , Caracter, Código do recurso que está gerando a disponibilidade
@param 08 lFerram  , Logico  , Indica se esta gerando o detalhe da disponibilidade de uma ferramenta
@param 09 cSituacao, Caracter, Situação do recurso.
@return aTotais, Array, Array com o total de horas extras e paradas.
        aTotais[1]=minutos em Paradas
        aTotais[2]=minutos em Extras
        aTotais[3]=minutos em Bloqueio
        aTotais[4]=minutos em Efetivadas
        aTotais[5]=minutos em Disponiveis
/*/
Method geraDetalheDisponibilidade(dData, aCalPad, aCalExc, aBloqueio, aEfetivas, cCodDisp, cRecurso, lFerram, cSituacao) CLASS PCPA152Disponibilidade
	Local aTotais   := {0,0,0,0,0}
	Local aDispDet  := Array(ARRAY_MK_TAMANHO)
	Local aRegs     := {}
	Local aHoras    := {}
	Local nIndex    := 0
	Local nTotal    := 0
	Default cSituacao := RECURSO_NAO_ILIMITADO
	Default lFerram   := .F.

	//Dados fixos do array aDispDet
	aDispDet[ARRAY_MK_FILIAL] := Self:cFilSMK
	aDispDet[ARRAY_MK_PROG  ] := Self:oParDisp["cProg"]
	aDispDet[ARRAY_MK_DISP  ] := cCodDisp

	If Empty(aCalExc)
		//Se não possuir exceção de calendário, irá registrar o horário do calendário padrão.
		nTotal := Len(aCalPad[CALEND_POS_HORAS])
		For nIndex := 1 To nTotal
			addTempo(aHoras,;
			         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI],;
			         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM],;
			         HORA_DISPONIVEL,;
			         .F.)
		Next nIndex
	Else
		//Se possui exceção, gera as horas já considerando a exceção + padrão.
		aHoras := Self:uneCalendarioExcecao(aCalExc, aCalPad)
	EndIf

	//Valida as horas efetivadas
	Self:validaEfetivadas(@aHoras, @aTotais, aEfetivas)

	//Valida os bloqueios de recursos
	Self:validaBloqueios(@aHoras, @aTotais, aBloqueio)

	nTotal := Len(aHoras)
	For nIndex := 1 To nTotal
		aDispDet[ARRAY_MK_DATDISP] := dData
		aDispDet[ARRAY_MK_SEQ    ] := StrZero(nIndex, Self:nTamMKSEQ)
		aDispDet[ARRAY_MK_HRINI  ] := aHoras[nIndex][1]
		aDispDet[ARRAY_MK_HRFIM  ] := aHoras[nIndex][2]
		aDispDet[ARRAY_MK_TIPO   ] := aHoras[nIndex][3]
		aDispDet[ARRAY_MK_BLOQUE ] := HORA_NAO_BLOQUEADA

		//Se existe bloqueio neste horário, registra como "Bloqueada".
		If aHoras[nIndex][4]
			aDispDet[ARRAY_MK_BLOQUE] := HORA_BLOQUEADA
		EndIf

		//Sumariza horas paradas e extras
		If aHoras[nIndex][3] == HORA_PARADA
			aTotais[1] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])

		ElseIf aHoras[nIndex][3] == HORA_EXTRA
			aTotais[2] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])

		EndIf

		If Self:lCRP .And. !lFerram .And. ((aDispDet[ARRAY_MK_TIPO] == HORA_EFETIVADA) .Or.;
		                                  ((aDispDet[ARRAY_MK_TIPO] == HORA_DISPONIVEL .Or. aDispDet[ARRAY_MK_TIPO] == HORA_EXTRA) .And. aDispDet[ARRAY_MK_BLOQUE] == HORA_NAO_BLOQUEADA))
			Self:criaDisponibilidadeParaAlocacao(aDispDet, Nil, cRecurso, cSituacao)
		EndIf

		// Salva apenas as horas bloqueadas e efetivadas das ferramentas.
		If lFerram .And. aDispDet[ARRAY_MK_TIPO] == HORA_DISPONIVEL .And. aDispDet[ARRAY_MK_BLOQUE] == HORA_NAO_BLOQUEADA
			Loop
		EndIf

		aAdd(aRegs, aClone(aDispDet))
	Next nIndex

	//Adiciona na memória global os dados da SMK
	If Self:lCRP .And. !Self:lSimula
		Self:setDispSMK(cCodDisp, aRegs, Self:lAdicional)
	EndIf

	aSize(aDispDet, 0)
	aSize(aRegs   , 0)
	aSize(aHoras  , 0)

Return aTotais

/*/{Protheus.doc} gravaTabela
Grava dados na tabela

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cTabela, Caracter, Tabela para gravar
@param 02 aDados , Array   , Array contendo os dados para gravação
@return lRet, Logic, Retorna se gravou com sucesso os dados
/*/
Method gravaTabela(cTabela, aDados) CLASS PCPA152Disponibilidade
	Local lRet      := .T.
	Local nIndChave := 1
	Local nTotChave := Len(aDados)
	Local nIndReg   := 1
	Local nTotReg   := 0
	Local nTempoIni := MicroSeconds()
	Local oBulk     := FwBulk():New(RetSqlName(cTabela))

	oBulk:SetFields(Self:estruturaTabela(cTabela))

	//Percorre as chaves para gravação
	While nIndChave <= nTotChave .And. lRet
		nIndReg := 1
		nTotReg := Len(aDados[nIndChave][2])

		//Em cada chave, percorre os registros
		While nIndReg <= nTotReg .And. lRet
			lRet := oBulk:addData(Self:converteArrayProcessamentoParaGravacao(aDados[nIndChave][2][nIndReg], cTabela))
			aSize(aDados[nIndChave][2][nIndReg], 0)
			//Próximo registro
			nIndReg++
		End

		//Limpa os arrays
		aSize(aDados[nIndChave][2], 0)
		aSize(aDados[nIndChave]   , 0)

		//Próxima chave
		nIndChave++

		Self:oProcesso:gravaValorGlobal("REGISTROS_GRAVADOS", 1, .T., .T.)

		If nIndChave > nTotChave .And. lRet
			//Final dos dados, finaliza o bulk
			lRet := oBulk:Close()
			Exit
		EndIf
	End
	lRet := lRet .And. Self:oProcesso:permiteProsseguir()

	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo gravacao da tabela " + cTabela + ": " + cValToChar(MicroSeconds() - nTempoIni)})

	//Se deu erro, grava a mensagem de erro.
	If !lRet
		DisarmTransaction()

		If !Self:oProcesso:processamentoCancelado()
			Self:oProcesso:gravaErro(CHAR_ETAPAS_GRAVACAO, I18N(STR0007, {cTabela}), oBulk:getError()) //"Erro ao gravar a tabela #1[TABELA]#"
		EndIf
	EndIf
    oBulk:Destroy()

	aSize(aDados, 0)
Return lRet

/*/{Protheus.doc} gravaRecursoCT
Processa os dados de vínculo de CT e Recurso para registrar na tabela SMT

@author lucas.franca
@since 15/06/2023
@version P12
@param 01 oRecXCTrb, JsonObject, Json com os vínculos de CT e Recurso
@return lRet, Logic, Identifica se gravou os dados.
/*/
Method gravaRecursoCT(oRecXCTrb) Class PCPA152Disponibilidade
	Local aCT       := {}
	Local aDados    := {}
	Local aInsSMT   := {}
	Local aRecursos := {}
	Local cFilMT    := xFilial("SMT")
	Local lRet      := .T.
	Local nIndCT    := 0
	Local nIndRec   := 0
	Local nTotRec   := 0
	Local nTotCT    := 0

	aRecursos := oRecXCTrb:GetNames()
	nTotRec   := Len(aRecursos)

	For nIndRec := 1 To nTotRec
		aCT    := oRecXCTrb[aRecursos[nIndRec]]:GetNames()
		nTotCT := Len(aCT)

		For nIndCT := 1 To nTotCT
			aInsSMT                   := Array(ARRAY_MT_TAMANHO)
			aInsSMT[ARRAY_MT_FILIAL ] := cFilMT
			aInsSMT[ARRAY_MT_PROG   ] := Self:oParDisp["cProg"]
			aInsSMT[ARRAY_MT_RECURSO] := aRecursos[nIndRec]
			aInsSMT[ARRAY_MT_CTRAB  ] := aCT[nIndCT]
			aAdd(aDados, aInsSMT)
		Next nIndCT

		FreeObj(oRecXCTrb[aRecursos[nIndRec]])
		aSize(aCT, 0)

	Next nIndRec
	aSize(aRecursos, 0)
	FreeObj(oRecXCTrb)

	lRet := Self:gravaTabela("SMT", {{"",aDados}})

	aSize(aInsSMT, 0)

Return lRet

/*/{Protheus.doc} totalDeMinutos
Retorna o total de minutos decorrentes entre hora inicial e hora final

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cHoraIni, Caracter, Hora inicial
@param 02 cHoraFim, Caracter, Hora final
@return nTotal, Number, Total de minutos
/*/
Method totalDeMinutos(cHoraIni, cHoraFim) CLASS PCPA152Disponibilidade
	Local nTotal  := 0
	Local nMinIni := __Hrs2Min(cHoraIni)
	Local nMinFim := __Hrs2Min(cHoraFim)

	nTotal := nMinFim - nMinIni
Return nTotal

/*/{Protheus.doc} uneCalendarioExcecao
Une os dados de calendário padrão e calendário de exceção
registrando quais horários são hora extra, parada ou disponível

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 aCalExc, Array, Array com os dados do calendário exceção
@param 02 aCalPad, Array, Array com os dados do calendário padrão
@return aHoras, Array, Array com as horas para registrar
/*/
Method uneCalendarioExcecao(aCalExc, aCalPad) CLASS PCPA152Disponibilidade
	Local aHoras   := {}
	Local cHoraIni := ""
	Local cHoraFim := ""
	Local nIndPad  := 1
	Local nTotPad  := Len(aCalPad[CALEND_POS_HORAS])
	Local nIndex   := 1
	Local nTotal   := Len(aCalExc[CALEND_POS_HORAS])

	//Verifica quais horários deve registrar como tipo extra, parada ou normal
	For nIndex := 1 To nTotal
		//Hora inicial do calendário da exeção
		cHoraIni := aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI]
		cHoraFim := aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM]

		If nIndPad > nTotPad
			//Já avaliou todos os registros do calendário padrão, adiciona todos os horários
			//da exceção como hora extra
			addTempo(aHoras, cHoraIni, cHoraFim, HORA_EXTRA, .F.)
			Loop
		EndIf

		//Hora inicial da exceção menor que hora inicial do calendário padrão = hora extra
		If cHoraIni < aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Exceção inicia e termina antes do início do calendário padrão, registra toda a exceção como hora extra
			If cHoraFim <= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
				addTempo(aHoras, cHoraIni, cHoraFim, HORA_EXTRA, .F.)

				//Vai para o próximo registro da exceção
				Loop
			Else
				//Hora final da exceção está dentro o calendário padrão.
				//Registra como extra do início da exceção até início do calendário padrão
				addTempo(aHoras, cHoraIni, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI], HORA_EXTRA, .F.)

				//Irá reprocessar esta exceção, mas considerando que o início dela é o inicio do calendário padrão
				aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] := aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]

				nIndex-- //Decrementa índice do calendário de exceção para avaliar novamente com o próximo horário do calendário padrão.
				Loop
			EndIf

		//Verifica se a hora inicial da exceção é maior que a hora inicial do calendário padrão para gerar o horário de parada
		ElseIf cHoraIni > aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Identifica a hora final para registrar a parada
			If cHoraIni >= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Exceção inicia após o término do calendário padrão, registra este horário completo do padrão como parada.
				addTempo(aHoras                                                ,;
				         aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI],;
				         aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM],;
				         HORA_PARADA                                           ,;
				         .F.                                                    )
				nIndPad++ //Incrementa índice do calendário padrão para verificar o próximo horário
				nIndex-- //Decrementa índice do calendário de exceção para avaliar novamente com o próximo horário do calendário padrão.
				Loop
			ElseIf cHoraIni < aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Hora inicial da exceção é menor que o fim do calendário.
				//Registra parada do horário início do calendário padrão até início da exceção
				addTempo(aHoras, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI], cHoraIni, HORA_PARADA, .F.)
				//Reavalia considerando como inicio do calendário padrão o horário após a parada registrada
				aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI] := cHoraIni
				nIndex-- //Decrementa índice do calendário de exceção para avaliar novamente com o próximo horário do calendário padrão.
				Loop
			EndIf

		//Hora de início da exceção é igual ao início do calendário padrão, registra como hora normal
		ElseIf cHoraIni == aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI]
			//Verifica hora fim.
			If cHoraFim <= aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Final da exceção é anterior ao final do calendário padrão, registra como hora normal até o fim do calendário exceção
				addTempo(aHoras, cHoraIni, cHoraFim, HORA_DISPONIVEL, .F.)

				//Define como hora inicial do calendário padrão o final da exceção
				aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAINI] := cHoraFim

				//Se a hora final da exceção for igual ao final do calendário padrão,
				//invrementa o índice de calendário padrão para validar o próximo horário
				If cHoraFim == aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
					nIndPad++
				EndIf

				//Processa próximo registro da exceção
				Loop
			ElseIf cHoraFim > aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]
				//Final da exceção é maior que o final do calendário padrão, registra como hora normal até o término do calendário padrão
				addTempo(aHoras, cHoraIni, aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM], HORA_DISPONIVEL, .F.)

				//Irá reprocessar esta exceção, mas considerando que o início dela é o fim do calendário padrão
				aCalExc[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] := aCalPad[CALEND_POS_HORAS][nIndPad][CALEND_POS_HORAFIM]

				nIndPad++ //Incrementa índice do calendário padrão para verificar o próximo horário
				nIndex-- //Decrementa índice do calendário de exceção para avaliar novamente com o próximo horário do calendário padrão.
				Loop
			EndIf
		EndIf

	Next nIndex

	//Percorre o restante do calendário padrão caso não tenha processado todos os horários
	For nIndex := nIndPad To nTotPad
		//Registra o tempo do calendário como parada
		addTempo(aHoras                                               ,;
		         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI],;
		         aCalPad[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM],;
		         HORA_PARADA                                          ,;
		         .F.                                                   )
	Next nIndex

Return aHoras

/*/{Protheus.doc} validaBloqueios
Valida os dados das horas geradas, se estão dentro de um bloqueio do recurso.

@author lucas.franca
@since 08/02/2023
@version P12
@param 01 aHoras   , Array, Array com as horas que serão gravadas na SMK. Retorna por referência dados atualizados.
@param 02 aTotais  , Array, Array com totais de horas extras, paradas e bloqueadas. Retorna por referência dados atualizados.
@param 03 aBloqueio, Array, Array com os horários de bloqueio
@return Nil
/*/
Method validaBloqueios(aHoras, aTotais, aBloqueio) CLASS PCPA152Disponibilidade
	Local cHoraFim := ""
	Local cHoraIni := ""
	Local lOrdena  := .F.
	Local nIndex   := 1
	Local nIndBloq := 0
	Local nTotal   := 0
	Local nTotBloq := 0

	If Empty(aBloqueio)
		Return
	EndIf

	nTotBloq := Len(aBloqueio[CALEND_POS_HORAS])
	For nIndBloq := 1 To nTotBloq

		nTotal   := Len(aHoras)
		cHoraIni := aBloqueio[CALEND_POS_HORAS][nIndBloq][CALEND_POS_HORAINI]
		cHoraFim := aBloqueio[CALEND_POS_HORAS][nIndBloq][CALEND_POS_HORAFIM]

		For nIndex := 1 To nTotal
			//Se ja é uma hora bloqueada, desconsidera
			If aHoras[nIndex][4] == .T.
				Loop
			EndIf
			//Se é uma hora efetivada, desconsidera
			If aHoras[nIndex][3] == HORA_EFETIVADA
				Loop
			EndIf

			//Se o início da hora é maior que o final do bloqueio, não precisa analisar o restante das horas
			//pois estarão todas fora do bloqueio.
			If aHoras[nIndex][1] > cHoraFim
				Exit
			EndIf

			//Hora do calendário está dentro do bloqueio, registra como hora bloqueada
			If aHoras[nIndex][1] >= cHoraIni .And. aHoras[nIndex][2] <= cHoraFim
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])
				EndIf
				aHoras[nIndex][4] := .T.
				Loop
			EndIf

			//Hora do calendário inicia antes do bloqueio, e termina durante o bloqueio. Faz a quebra do horário para registrar o bloqueio.
			If aHoras[nIndex][1] < cHoraIni .And. aHoras[nIndex][2] > cHoraIni .And. aHoras[nIndex][2] <= cHoraFim
				//Adiciona novo horário para registrar o bloqueio, da hora inicial do bloqueio até a hora final do horário
				addTempo(aHoras, cHoraIni, aHoras[nIndex][2], aHoras[nIndex][3], .T.)

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(cHoraIni, aHoras[nIndex][2])
				EndIf

				//Este horário do calendário será alterado para ter como hora final a hora de início do bloqueio
				aHoras[nIndex][2] := cHoraIni

				lOrdena := .T.
				Loop
			EndIf

			//Hora do calendário inicia durante o bloqueio e encerra após do término do bloqueio.
			If aHoras[nIndex][1] >= cHoraIni .And.;
				aHoras[nIndex][1] < cHoraFim .And.;
				aHoras[nIndex][2] > cHoraIni .And.;
				aHoras[nIndex][2] > cHoraFim

				//Gera novo horário somente com o período após o término do bloqueio
				addTempo(aHoras, cHoraFim, aHoras[nIndex][2], aHoras[nIndex][3], .F.)
				//Atualiza este horário para hora bloqueada
				aHoras[nIndex][2] := cHoraFim
				aHoras[nIndex][4] := .T.

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])
				EndIf

				lOrdena := .T.
				Loop
			EndIf

			//Hora do calendário inicia antes do bloqueio, e termina após o término do bloqueio.
			If aHoras[nIndex][1] <= cHoraIni .And. aHoras[nIndex][2] >= cHoraFim
				//Verifica se deve quebrar hora inicio para registrar o bloqueio
				If aHoras[nIndex][1] < cHoraIni
					//Horário do início do calendário até início do bloqueio será quebrado para registrar o bloqueio.
					addTempo(aHoras, aHoras[nIndex][1], cHoraIni, aHoras[nIndex][3], aHoras[nIndex][4])
				EndIf
				If aHoras[nIndex][2] > cHoraFim
					//Horário do final do bloqueio até final do calendário parão será quebrado para registrar o bloqueio
					addTempo(aHoras, cHoraFim, aHoras[nIndex][2], aHoras[nIndex][3], aHoras[nIndex][4])
				EndIf

				//Soma totais de horas bloqueadas
				If aHoras[nIndex][3] != HORA_PARADA
					aTotais[3] += Self:totalDeMinutos(cHoraIni, cHoraFim)
				EndIf

				//Marca o horário atual como bloqueado e atualiza horário
				aHoras[nIndex][1] := cHoraIni
				aHoras[nIndex][2] := cHoraFim
				aHoras[nIndex][4] := .T.

				lOrdena := .T.
				Loop
			EndIf

		Next nIndex
		If lOrdena
			//Se adicionou novos horários, ordena o array para criar os registros com a sequencia ordenada
			aSort(aHoras,,,{|x,y| x[1] < y[1]})
		EndIf
	Next nIndBloq

Return

/*/{Protheus.doc} validaEfetivadas
Adiciona as horas efetivadas e valida os dados das horas geradas, se estão dentro de uma hora efetivada.

@author marcelo.neumann
@since 10/11/2023
@version P12
@param 01 aHoras   , Array, Array com as horas que serão gravadas na SMK. Retorna por referência dados atualizados.
@param 02 aTotais  , Array, Array com totais de horas extras, paradas e bloqueadas. Retorna por referência dados atualizados.
@param 03 aEfetivas, Array, Array com os horários efetivados.
@return Nil
/*/
Method validaEfetivadas(aHoras, aTotais, aEfetivas) CLASS PCPA152Disponibilidade
	Local aRemove  := {}
	Local cHoraFim := ""
	Local cHoraIni := ""
	Local nExtra   := 0
	Local nIndEfet := 0
	Local nIndex   := 1
	Local nTotal   := 0
	Local nTotEfet := 0

	If Empty(aEfetivas)
		Return
	EndIf

	nTotEfet := Len(aEfetivas)
	For nIndEfet := 1 To nTotEfet
		nTotal   := Len(aHoras)
		cHoraIni := aEfetivas[nIndEfet][CALEND_POS_HORAINI]
		cHoraFim := aEfetivas[nIndEfet][CALEND_POS_HORAFIM]
		nExtra   := Self:totalDeMinutos(cHoraIni, cHoraFim)

		For nIndex := 1 To nTotal
			// Se ja é uma hora efetivada, desconsidera.
			If aHoras[nIndex][3] == HORA_EFETIVADA
				Loop
			EndIf

			// Hora finaliza antes do início do período efetivado ou inicia após o fim do período efetivado, desconsidera.
			If aHoras[nIndex][2] < cHoraIni .Or. aHoras[nIndex][1] > cHoraFim
				Loop
			EndIf

			// Hora com início dentro do período efetivado.
			If aHoras[nIndex][1] >= cHoraIni

				// Hora finaliza dentro do período efetivado. Remove a hora por completo.
				If aHoras[nIndex][2] <= cHoraFim
					nExtra -= Self:totalDeMinutos(aHoras[nIndex][1], aHoras[nIndex][2])

					aAdd(aRemove, nIndex)

				// Hora finaliza após o período efetivado. Ajusta para iniciar assim que o período efetivado finalizar.
				Else
					nExtra -= Self:totalDeMinutos(aHoras[nIndex][1], cHoraFim)

					aHoras[nIndex][1] := cHoraFim

				EndIf

			// Hora com início antes do período efetivado.
			Else

				// Hora finaliza após o período efetivado. Adiciona hora após o período efetivado.
				If aHoras[nIndex][2] > cHoraFim
					nExtra -= Self:totalDeMinutos(cHoraIni, cHoraFim)

					addTempo(aHoras, cHoraFim, aHoras[nIndex][2], aHoras[nIndex][3], aHoras[nIndex][4])

				// Hora finaliza dentro do período efetivado.
				Else
					nExtra -= Self:totalDeMinutos(cHoraIni, aHoras[nIndex][2])

				EndIf
				// Ajusta a hora atual, para finalizar no início do período efetivado.
				aHoras[nIndex][2] := cHoraIni

			EndIf

		Next nIndex

		addTempo(aHoras, cHoraIni, cHoraFim, HORA_EFETIVADA, .F.)
		aTotais[5] += nExtra
		aTotais[4] += Self:totalDeMinutos(cHoraIni, cHoraFim)

		nTotal := Len(aRemove)
		If nTotal > 0
			For nIndex := nTotal To 1 Step -1
				aDel(aHoras, aRemove[nIndex])
			Next nIndex

			aSize(aHoras, Len(aHoras)-nTotal)
			aSize(aRemove, 0)
		EndIf
	Next nIndEfet

	aSort(aHoras,,,{|x,y| x[1] < y[1]})
Return

/*/{Protheus.doc} carregaCalendario
Busca os dados de um calendário

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cCalend, Caracter, Código do calendário
@return Nil
/*/
Method carregaCalendario(cCalend) CLASS PCPA152Disponibilidade
	Local cAlocDia := ""
	Local nIndDia  := 0
	Local nIndCal  := 0
	Local nPosIni  := 0
	Local nTamanho := 0

	If Self:oCalend:HasProperty(cCalend)
		Return
	EndIf

	Self:oCalend[cCalend] := Array(7) //Cada posição do array será um dia da semana, iniciando no domingo.

	SH7->(dbSetOrder(1))
	If SH7->(dbSeek(xFilial("SH7") + cCalend))
		//Posição inicial do H7_ALOC para buscar as horas.
		nPosIni  := 1
		//Tamanho do H7_ALOC que representa 1 dia.
		nTamanho := Self:oParDisp["MV_PRECISA"] * 24
		//Divide o conteúdo de H7_ALOC no conteúdo de cada dia da semana.
		For nIndDia := 1 To 7
			//Valor de H7_ALOC inicia na segunda.
			//Utiliza o nIndCal para que nos dados do calendário o primeiro dia seja o Domingo.
			nIndCal := nIndDia + 1
			If nIndCal > 7
				nIndCal := 1
			EndIf
			//Extrai somente a alocação de 1 dia do campo H7_ALOC
			cAlocDia := SubStr(SH7->H7_ALOC, nPosIni, nTamanho)
			Self:oCalend[cCalend][nIndCal] := Self:converteHorasCalendario(cAlocDia)

			//Soma o tamanho na posição inicial para pegar o próximo dia de H7_ALOC
			nPosIni += nTamanho
		Next nIndDia
	EndIf

Return

/*/{Protheus.doc} carregaBloqueioRecurso
Busca os dados de bloqueios de recurso no período

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, Código do recurso
@param 02 cCentCusto, Caracter, Código do centro de custo vinculado ao recurso
@return Nil
/*/
Method carregaBloqueioRecurso(cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cAlias   := ""
	Local cDataIni := ""
	Local cDataFim := ""
	Local cData    := ""
	Local cChave   := ""
	Local cHrIni   := ""
	Local cHrFim   := ""
	Local cQuery   := ""
	Local dData    := Nil
	Local dDataFim := Nil
	Local nTotal   := 0

	Self:oBlockRec := JsonObject():New()

	If Self:oQryBlock == Nil
		cDataIni := DtoS(Self:oParDisp["dataInicial"])
		cDataFim := DtoS(Self:oParDisp["dataFinal"])

		cQuery := "SELECT SH9.H9_RECURSO, SH9.H9_CCUSTO, SH9.H9_DTINI, SH9.H9_DTFIM, SH9.H9_HRINI, SH9.H9_HRFIM"
		cQuery +=  " FROM " + RetSqlName("SH9") + " SH9"
		cQuery += " WHERE SH9.H9_FILIAL  = ?"
		cQuery +=   " AND SH9.H9_TIPO    = ?"
		cQuery +=   " AND SH9.D_E_L_E_T_ = ?"
		cQuery +=   " AND (SH9.H9_DTINI BETWEEN ? AND ?"
		cQuery +=    " OR  SH9.H9_DTFIM BETWEEN ? AND ?)"
		cQuery +=   " AND ((SH9.H9_RECURSO = ? OR SH9.H9_RECURSO = ?)"
		cQuery +=   " AND  (SH9.H9_CCUSTO  = ? OR SH9.H9_CCUSTO  = ?))"
		cQuery += " ORDER BY SH9.H9_DTINI, SH9.H9_HRINI"
		Self:oQryBlock := FwExecStatement():New(cQuery)

		Self:oQryBlock:SetFields({"H9_RECURSO"           ,;
		                          "H9_CCUSTO"            ,;
		                          {"H9_DTINI", "D", 8, 0},;
		                          {"H9_DTFIM", "D", 8, 0},;
		                          "H9_HRINI"             ,;
		                          "H9_HRFIM"             })

		Self:oQryBlock:SetString(1, xFilial("SH9")) //H9_FILIAL
		Self:oQryBlock:SetString(2, 'B') //H9_TIPO
		Self:oQryBlock:SetString(3, ' ') //D_E_L_E_T_
		Self:oQryBlock:SetString(4, cDataIni) //H9_DTINI
		Self:oQryBlock:SetString(5, cDataFim) //H9_DTINI
		Self:oQryBlock:SetString(6, cDataIni) //H9_DTFIM
		Self:oQryBlock:SetString(7, cDataFim) //H9_DTFIM
		Self:oQryBlock:SetString(8, ' ') //H9_RECURSO = ' '
		Self:oQryBlock:SetString(10, ' ') //H9_CCUSTO = ' '
	EndIf

	Self:oQryBlock:SetString(9, cRecurso) //H9_RECURSO = 'recurso'
	Self:oQryBlock:SetString(11, cCentCusto) //H9_CCUSTO = 'ccusto'

	cAlias := Self:oQryBlock:OpenAlias()
	Self:oQryBlock:doTcSetField(cAlias)

	While (cAlias)->(!Eof())

		dData    := Max(Self:oParDisp["dataInicial"], (cAlias)->(H9_DTINI))
		dDataFim := Min(Self:oParDisp["dataFinal"  ], (cAlias)->(H9_DTFIM))

		While dData <= dDataFim
			cData  := DtoS(dData)
			cChave := Self:chaveExcecao(cData, (cAlias)->(H9_RECURSO), (cAlias)->(H9_CCUSTO))

			If !Self:oBlockRec:HasProperty(cChave)
				Self:oBlockRec[cChave] := {{}, 0}
			EndIf

			cHrIni := "00:00"
			cHrFim := "24:00"

			If dData == (cAlias)->(H9_DTINI)
				cHrIni := (cAlias)->(H9_HRINI)
			EndIf
			If dData == (cAlias)->(H9_DTFIM)
				cHrFim := (cAlias)->(H9_HRFIM)
			EndIf
			nTotal := Self:totalDeMinutos(cHrIni, cHrFim)

			If nTotal > 0
				Self:oBlockRec[cChave][2] += nTotal
				aAdd(Self:oBlockRec[cChave][1], {cHrIni, cHrFim, nTotal} )
			EndIf

			dData++
		End

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} carregaExcecaoCalendario
Busca os dados de exceções de calendário no período

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cRecurso  , Caracter, Código do recurso
@param 02 cCentCusto, Caracter, Código do centro de custo vinculado ao recurso
@return Nil
/*/
Method carregaExcecaoCalendario(cRecurso, cCentCusto) CLASS PCPA152Disponibilidade
	Local cAlias   := GetNextAlias()
	Local cChave   := ""
	Local cDataIni := Self:oParDisp["dataInicial"]
	Local cDataFim := Self:oParDisp["dataFinal"]

	Self:oExcCalend := JsonObject():New()

	BeginSql Alias cAlias
		%noParser%
		SELECT SH9.H9_RECURSO, SH9.H9_CCUSTO, SH9.H9_DTINI, SH9.H9_ALOC
		  FROM %Table:SH9% SH9
		 WHERE SH9.H9_FILIAL = %xFilial:SH9%
		   AND SH9.H9_TIPO   = 'E'
		   AND SH9.H9_DTINI BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
		   AND ((SH9.H9_RECURSO = %Exp:cRecurso%   OR SH9.H9_RECURSO = ' ')
		    AND (SH9.H9_CCUSTO  = %Exp:cCentCusto% OR SH9.H9_CCUSTO  = ' ') )
		   AND SH9.%NotDel%
	EndSql

	While (cAlias)->(!Eof())

		cChave := Self:chaveExcecao((cAlias)->(H9_DTINI), (cAlias)->(H9_RECURSO), (cAlias)->(H9_CCUSTO))

		Self:oExcCalend[cChave] := Self:converteHorasCalendario((cAlias)->(H9_ALOC))

		(cAlias)->(dbSkip())
	End

	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} carregaEfetivadas
Busca as horas efetivadas de um recurso

@author marcelo.neumann
@since 10/11/2023
@version P12
@param cRecurso, Caracter, Código do recurso
@return Nil
/*/
Method carregaEfetivadas(cRecurso) CLASS PCPA152Disponibilidade
	Local cAlias   := GetNextAlias()
	Local cChave   := ""
	Local cDataFim := Self:oParDisp["dataFinal"]
	Local cDataIni := Self:oParDisp["dataInicial"]
	Local cQuery   := ""
	Local cTableOP := ""
	Local nPos     := 1

	Self:oEfetivas  := JsonObject():New()
	Self:oProdsEfet := JsonObject():New()

	cQuery += " SELECT HWF.HWF_DATA, HWF.HWF_HRINI, HWF.HWF_HRFIM, SC2.C2_PRODUTO "
	cQuery += "   FROM " + RetSqlName("HWF") + " HWF "
	cQuery += "  INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery += "     ON " + PCPQrySC2("SC2", "HWF.HWF_OP")//Compara SUBSTRING de HWF_OP com campos correspondentes da SC2.
	cQuery += "    AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
	cQuery += "    AND SC2.C2_STATUS  = 'S' "
	cQuery += "    AND SC2.C2_DATRF   = ' ' "
	cQuery += "    AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery += "     ON SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
	cQuery += "    AND SHY.HY_OP      = HWF.HWF_OP "
	cQuery += "    AND SHY.HY_OPERAC  = HWF.HWF_OPER "
	cQuery += "    AND SHY.HY_ROTEIRO = HWF.HWF_ROTEIR "
	cQuery += "    AND SHY.D_E_L_E_T_ = ' ' "
	cQuery += "   LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery += "     ON SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cQuery += "    AND SG2.G2_CODIGO  = HWF.HWF_ROTEIR "
	cQuery += "    AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery += "    AND SG2.G2_OPERAC  = HWF.HWF_OPER "
	cQuery += "    AND SG2.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE HWF.HWF_FILIAL = '" + Self:cFilHWF + "'"
	cQuery += "    AND HWF.HWF_RECURS = '" + cRecurso + "'"
	cQuery += "    AND HWF.HWF_STATUS = '" + STATUS_ATIVO + "' "
	cQuery += "    AND HWF.HWF_DATA BETWEEN '" + DTOS(cDataIni) + "' AND '"  + DTOS(cDataFim) + "'"
	cQuery += "    AND HWF.HWF_TIPO  != '" + cValToChar(VM_TIPO_REMOCAO) + "' "
	cQuery += "    AND (SHY.HY_OPERAC IS NOT NULL OR (SHY.HY_OPERAC IS NULL AND SG2.G2_OPERAC IS NOT NULL)) "
	cQuery += "    AND HWF.D_E_L_E_T_ = ' ' "

	If Self:oParDisp["replanejaSacramentadas"]
		cTableOP := RetSqlName("SMF")

		If Self:oProcesso:possuiTabelaTemporaria()
			cTableOP := Self:oProcesso:getNomeTempTable()
		EndIf

		cQuery += " AND NOT EXISTS(SELECT 1 "
		cQuery +=                  " FROM " + cTableOP + " TABLEOP "
		cQuery +=                 " WHERE TABLEOP.MF_FILIAL = '" + xFilial("SMF") + "' "
		cQuery +=                   " AND TABLEOP.MF_PROG = '" + Self:oProcesso:retornaProgramacao() + "' "
		cQuery +=                   " AND TABLEOP.MF_OP = HWF.HWF_OP "
		cQuery +=                   " AND TABLEOP.MF_OPER = HWF.HWF_OPER "
		cQuery +=                   " AND TABLEOP.D_E_L_E_T_ = ' ') "
	EndIf

	cQuery += "	ORDER BY HWF.HWF_DATA, HWF.HWF_HRINI, HWF.HWF_HRFIM "

	If "MSSQL" $ Self:cBanco
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .T.)

	While (cAlias)->(!Eof())
		If !Empty(cChave) .And. cChave == (cAlias)->HWF_DATA
			If (cAlias)->HWF_HRINI <= Self:oEfetivas[cChave][nPos][2]
				Self:oEfetivas[cChave][nPos][2] := (cAlias)->HWF_HRFIM
			Else
				aAdd(Self:oEfetivas[cChave], {(cAlias)->HWF_HRINI, (cAlias)->HWF_HRFIM})
				nPos++
			EndIf
		Else
			nPos   := 1
			cChave := (cAlias)->HWF_DATA
			Self:oEfetivas[cChave] := {}
			aAdd(Self:oEfetivas[cChave], {(cAlias)->HWF_HRINI, (cAlias)->HWF_HRFIM})

			Self:oProdsEfet[cRecurso+cChave] := {}
		EndIf
		aAdd(Self:oProdsEfet[cRecurso+cChave], {__Hrs2Min((cAlias)->HWF_HRINI), __Hrs2Min((cAlias)->HWF_HRFIM), (cAlias)->C2_PRODUTO})

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return

/*/{Protheus.doc} converteHorasCalendario
Converte as horas de um dia do calendário (SH7) em um array com as horas disponíveis

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 cAloc, Caracter, Alocação do dia cadastrado na SH7
@return aHoras, Array, Array com as horas disponíveis
/*/
Method converteHorasCalendario(cAloc) CLASS PCPA152Disponibilidade
	Local aHoras    := {}
	Local cHoraIni  := ""
	Local cHoraFim  := ""
	Local nMinutos  := 0
	Local nInicio	:= 0
	Local nFim		:= 0
	Local nInd		:= 0
	Local nHoraIni  := 0
	Local nTotal    := 0

	//Primeiro horário disponível
	nInicio	:=  AT("X", cAloc)
	//Último horário disponível
	nFim	:= RAT("X", cAloc)

	If nInicio > 0 .And. nFim > 0 //Se existe algum horário selecionado
		nHoraIni := nInicio -1
		//Percorre a string buscando horários que não estão marcados para gerar as quebras entre início/fim
		For nInd := nInicio To nFim
			If nHoraIni == -1 .And. SubStr(cAloc, nInd, 1) <> " "
				//Reinicia o nHoraIni com a seleção encontrada
				nHoraIni := nInd -1
			EndIf
			If nHoraIni <> -1 .And. (SubStr(cAloc, nInd, 1) == " " .Or. nInd == nFim)
				//Chegou no final da string ou encontrou uma pausa na seleção de horas
				//Converte as horas iniciais/finais de acordo com as posições encontradas na alocação
				cHoraIni := Self:horaPosicionada(nHoraIni)
				If nInd == nFim
					cHoraFim := Self:horaPosicionada(nFim)
				Else
					cHoraFim := Self:horaPosicionada(nInd-1)
				EndIf
				nTotal   := Self:totalDeMinutos(cHoraIni, cHoraFim)
				nMinutos += nTotal
				aAdd(aHoras, {cHoraIni, cHoraFim, nTotal})
				//Define nHoraIni = -1 para reiniciar a contagem da hora inicial após uma pausa na seleção
				nHoraIni := -1
			EndIf
		Next nInd
	EndIf

Return {aHoras, nMinutos}

/*/{Protheus.doc} horaPosicionada
Converte uma posição da alocação (SH7) em um horário

@author lucas.franca
@since 02/02/2023
@version P12
@param 01 nPosicao, Number, Posição da alocação para converter em hora
@return cHora, Caracter, Hora convertida
/*/
Method horaPosicionada(nPosicao) CLASS PCPA152Disponibilidade
	Local cHora     := ""
	Local nHora		:= 0
	Local nMinuto	:= 0
	Local nPrecisa  := Self:oParDisp["MV_PRECISA"]

	nHora	:= Int(nPosicao / nPrecisa)
	nMinuto	:= Mod(nPosicao, nPrecisa ) * (60 / nPrecisa)

	cHora := PadL( cValToChar(nHora), 2, "0" ) + ":" + PadL( cValToChar(nMinuto), 2, "0" )
Return cHora

/*/{Protheus.doc} addTempo
Adiciona no array de horas um novo horário

@type  Static Function
@author lucas.franca
@since 07/02/2023
@version P12
@param 01 aHoras    , Array   , Array para adicionar as horas
@param 02 cHoraIni  , Caracter, Hora Inicial
@param 03 cHoraFim  , Caracter, Hora final
@param 04 cTipo     , Caracter, Tipo da hora
@param 05 lBloqueado, Logico  , Identifica se a hora está dentro de um bloqueio
@return Nil
/*/
Static Function addTempo(aHoras, cHoraIni, cHoraFim, cTipo, lBloqueado)
	Local aHora := Array(4)

	aHora[1] := cHoraIni
	aHora[2] := cHoraFim
	aHora[3] := cTipo
	aHora[4] := lBloqueado

	aAdd(aHoras, aHora)
Return

/*/{Protheus.doc} buscaHorasRecurso
Busca as horas de um recurso com base no seu calendário, para o período de datas informado

@author lucas.franca
@since 13/02/2023
@version P12
@param 01 cRecurso, Caracter, Código do recurso
@param 02 dDataIni, Date    , Data inicial
@param 03 dDataFim, Date    , Data final
@return oHoras, JsonObject, Json com os dados de horas do recurso
/*/
Method buscaHorasRecurso(cRecurso, dDataIni, dDataFim) CLASS PCPA152Disponibilidade
	Local aRegs     := {}
	Local nIndex    := 0
	Local nTotal    := 0
	Local nTotHoras := 0
	Local oHoras    := JsonObject():New()
	Local oDisp     := PCPA152Disponibilidade():New()

	oHoras["datas"     ] := JsonObject():New()
	oHoras["totalHoras"] := "00:00"

	//Grava os parâmetros que serão utilizados no processamento
	oDisp:defineParametro("dataInicial", dDataIni)
	oDisp:defineParametro("dataFinal"  , dDataFim)

	SH1->(dbSetOrder(1))
	If SH1->(dbSeek(xFilial("SH1") + PadR(cRecurso, Len(SH1->H1_CODIGO))))
		aRegs  := oDisp:calculaDispRecurso(SH1->H1_CODIGO, SH1->H1_CALEND, SH1->H1_CCUSTO, SH1->H1_ILIMITA, .F., Nil)
		nTotal := Len(aRegs)

		For nIndex := 1 To nTotal
			oHoras["datas"][DtoS(aRegs[nIndex][ARRAY_MR_DATDISP])] := __Min2Hrs(aRegs[nIndex][ARRAY_MR_TEMPOTO], .T.)
			nTotHoras += aRegs[nIndex][ARRAY_MR_TEMPOTO]
		Next nIndex
		oHoras["totalHoras"] := __Min2Hrs(nTotHoras, .T.)

		aSize(aRegs, 0)
	EndIf

	oDisp:Destroy()
Return oHoras

/*/{Protheus.doc} descricaoTipoHora
Retorna a descrição do tipo de hora registrando na SMK (MK_TIPO)

@author lucas.franca
@since 01/03/2023
@version P12
@param 01 cTipo, Caracter, Valor de MK_TIPO para retornar a descrição
@return cDesc, Caracter, Descrição do conteúdo da coluna MK_TIPO
/*/
Method descricaoTipoHora(cTipo) CLASS PCPA152Disponibilidade
	Local cDesc := cTipo

	Do Case
		Case cTipo == HORA_DISPONIVEL
			cDesc := STR0089 //"Disponível"
		Case cTipo == HORA_PARADA
			cDesc := STR0090 //"Parada"
		Case cTipo == HORA_EXTRA
			cDesc := STR0091 //"Extra"
		Case cTipo == HORA_EFETIVADA
			cDesc := STR0360 //"Efetivada"

	EndCase
Return cDesc

/*/{Protheus.doc} P152CalDis
Faz o cálculo da disponibilidade para um recurso

@author marcelo.neumann
@since 02/03/2023
@version P12
@param 01 cProg     , Caracter, Número da programação
@param 02 cRecurso  , Caracter, Código do recurso
@param 03 cCalend   , Caracter, Código do calendário vinculado ao recurso
@param 04 cCentCusto, Caracter, Código do centro de custo vinculado ao recurso
@param 05 cRecIlimi , Caracter, Indicador se o recurso é ilimitado
@param 06 dDataIni  , Date    , Data inicial do cálculo da disponibilidade.
@param 07 dDataFim  , Date    , Data final do cálculo da disponibilidade.
@param 08 lAdicional, Lógico  , Indica que esta gerando disponibilidade adicional.
@return Nil
/*/
Function P152CalDis(cProg, cRecurso, cCalend, cCentCusto, cRecIlimi, dDataIni, dDataFim, lAdicional)
	Local oDisp := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_DISP, @oDisp)
		If dDataIni != Nil
			oDisp:defineParametro("dataInicial", dDataIni)
		EndIf

		If dDataFim != Nil
			oDisp:defineParametro("dataFinal", dDataFim)
		EndIf

		oDisp:calculaDispRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi, lAdicional, Nil)
	EndIf

Return

/*/{Protheus.doc} processaRecursos
Processa a disponibilidade dos recursos

@author Marcelo Neumann
@since 14/03/2023
@version P12
@param lAdicional, Lógico, Indica que deve gerar a disponibilidade adicional dos recursos.
@return lOk, Lógico, Indica se processou com sucesso a etapa
/*/
Method processaRecursos(lAdicional) Class PCPA152Disponibilidade
	Local aQuery     := Self:retornaQueryRecursos()
	Local cAlias     := GetNextAlias()
	Local cQuery     := ""
	Local cFiltroCT  := CTEmTexto(Self:oParDisp["centroTrabalho"])
	Local dDataIni   := Nil
	Local dDataFim   := Nil
	Local lOk        := .T.
	Local nIndex     := 1
	Local nPercentua := 0
	Local nQtdProc   := 0
	Local nTotRecur  := 0
	Local nTempoIni  := 0
	Local oRecXCTrb  := JsonObject():New()

	If lAdicional
		Self:cEtapa := CHAR_ETAPAS_DISP_ADICIONAL
	EndIf

	cQuery := " SELECT COUNT(cont.H1_CODIGO) TOTAL "
	cQuery +=   " FROM (SELECT " + aQuery[1]
	cQuery +=           " FROM " + aQuery[2]
	cQuery +=          " WHERE " + aQuery[3] + ") cont"

	nTempoIni := MicroSeconds()
	Self:oProcesso:oLogs:gravaLog(Self:cEtapa, {"Query count recursos: " + cQuery})

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	Self:oProcesso:oLogs:gravaLog(Self:cEtapa, {"Tempo count recursos: " + cValToChar(MicroSeconds() - nTempoIni)})

	If (cAlias)->(!Eof())
		nTotRecur := (cAlias)->TOTAL
	EndIf
	(cAlias)->(dbCloseArea())

	cQuery := " SELECT " + aQuery[1]
	cQuery +=   " FROM " + aQuery[2]
	cQuery +=  " WHERE " + aQuery[3]

	nTempoIni := MicroSeconds()
	Self:oProcesso:oLogs:gravaLog(Self:cEtapa, {"Query recursos: " + cQuery})

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	Self:oProcesso:oLogs:gravaLog(Self:cEtapa, {"Tempo query recursos: " + cValToChar(MicroSeconds() - nTempoIni)})

	Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_TOTAL"      , nTotRecur)
	Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 0)

	nIndex := 0
	While (cAlias)->(!Eof())
		If oRecXCTrb:HasProperty((cAlias)->H1_CODIGO) == .F.
			/*
				Valida a delegação do recurso no json oRecXCtrb pois a query pode
				trazer o mesmo recurso mais de uma vez para gerar a tabela de vínculo
				de centro de trabalho x recursos
			*/

			If lAdicional
				dDataIni := Self:buscaDataUltimaDisponibilidadeRecurso((cAlias)->H1_CODIGO) + 1

				If dDataFim == Nil
					dDataFim := Self:getFimDataDispAdicional(.F.)
				EndIf
			EndIf

			If (lAdicional .And. dDataIni <= dDataFim) .Or. !lAdicional
				Self:oProcesso:delegar("P152CalDis", Self:oParDisp["cProg"], (cAlias)->H1_CODIGO, (cAlias)->H1_CALEND, (cAlias)->H1_CCUSTO, (cAlias)->H1_ILIMITA, dDataIni, dDataFim, lAdicional)
			Else
				Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 1, .T., .T.)
			EndIf

			Self:setInfoRecurso((cAlias)->H1_CODIGO, (cAlias)->H1_CALEND, (cAlias)->H1_CCUSTO, (cAlias)->H1_ILIMITA)
		Else
			Self:oProcesso:gravaValorGlobal("DISPONIBILIDADE_PROCESSADOS", 1, .T., .T.)
		EndIf

		Self:registraRecursoCT(@oRecXCTrb, cFiltroCT, (cAlias)->H1_CODIGO, (cAlias)->H1_CTRAB)
		If !Empty((cAlias)->CTRAB)
			Self:registraRecursoCT(@oRecXCTrb, cFiltroCT, (cAlias)->H1_CODIGO, (cAlias)->CTRAB)
		EndIf

		If nIndex == 5
			If !Self:oProcesso:permiteProsseguir()
				lOk := .F.
				Exit
			EndIf

			If !Self:processandoRecursos(nTotRecur, @nQtdProc)
				Exit
			EndIf

			nPercentua := (nQtdProc * 100) / nTotRecur
			Self:oProcesso:gravaPercentual(Self:cEtapa, nPercentua)
			nIndex := 0
		Else
			nIndex++
		EndIf

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	Self:atualizaParametroDataDisponibilidade(lAdicional)

	//Aguarda término do processamento
	nIndex := 0
	While lOk .And. Self:processandoRecursos(nTotRecur, @nQtdProc)
		Sleep(500)

		If nIndex == 5
			nPercentua := (nQtdProc * 100) / nTotRecur
			Self:oProcesso:gravaPercentual(Self:cEtapa, nPercentua)
			nIndex := 0
		Else
			nIndex++
		EndIf

		lOk := Self:oProcesso:permiteProsseguir()
	End

	Self:oProcesso:gravaValorGlobal("JSON_RECXCTRAB", oRecXCTrb:toJson())

	If lAdicional
		Self:cEtapa := CHAR_ETAPAS_CALC_DISP
	EndIf

	aSize(aQuery, 0)
	FreeObj(oRecXCTrb)
Return lOk

/*/{Protheus.doc} processandoRecursos
Indica se ainda está processando os recursos ou se já processou todos

@author Marcelo Neumann
@since 07/03/2023
@version P12
@param 01 nTotRecur, Numérico, Total de Recursos que estão sendo processados
@param 02 nQtdProc , Numérico, Quantidade de recursos já processados
@return lInProcess, Lógico  , Indica que ainda está em processamento
/*/
Method processandoRecursos(nTotRecur, nQtdProc) Class PCPA152Disponibilidade
	Local lError     := .F.
	Local lInProcess := .T.

	nQtdProc := Self:oProcesso:retornaValorGlobal("DISPONIBILIDADE_PROCESSADOS", @lError)
	If lError .Or. nQtdProc == Nil .Or. nTotRecur == nQtdProc
		lInProcess := .F.
	EndIf

Return lInProcess

/*/{Protheus.doc} carregaDisponibilidade
Realiza a carga da disponibilidade para a memória quando processar uma programação com a disponibilidade gerada.
@author Lucas Fagundes
@since 22/03/2023
@version P12
@return Nil
/*/
Method carregaDisponibilidade() Class PCPA152Disponibilidade
	Local cAlias     := ""
	Local cCalend    := ""
	Local cCentCusto := ""
	Local cQuery     := ""
	Local cRecIlimi  := ""
	Local cRecurso   := ""
	Local dData      := Nil
	Local nTempoIni  := 0
	Local oQryBlock  := Nil

	Self:carregaProdutosEfetivados()

	cQuery := " SELECT SMR.MR_RECURSO,"
	cQuery +=        " SMK.MK_DATDISP,"
	cQuery +=        " SMK.MK_HRINI,"
	cQuery +=        " SMK.MK_HRFIM,"
	cQuery +=        " SMK.MK_DISP,"
	cQuery +=        " SMK.MK_SEQ,"
	cQuery +=        " SH1.H1_CALEND,"
	cQuery +=        " SH1.H1_CCUSTO,"
	cQuery +=        " SH1.H1_ILIMITA,"
	cQuery +=        " SMK.MK_TIPO,"
	cQuery +=        " SMR.MR_SITUACA"
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR"
	cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK"
	cQuery +=     " ON SMK.MK_PROG    = SMR.MR_PROG"
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP"
	cQuery +=    " AND SMK.MK_FILIAL  = ?"
	cQuery +=    " AND SMK.MK_BLOQUE  = ?"
	cQuery +=    " AND SMK.MK_TIPO   IN (?)"
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SH1") + " SH1"
	cQuery +=     " ON SH1.H1_FILIAL  = ?"
	cQuery +=    " AND SH1.H1_CODIGO  = SMR.MR_RECURSO"
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMR.MR_FILIAL  = ?"
	cQuery +=    " AND SMR.MR_PROG    = ?"
	cQuery +=    " AND SMR.MR_TIPO    = ?"
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' '"
	cQuery +=  " ORDER BY SMR.MR_RECURSO, SMK.MK_DATDISP, SMK.MK_HRINI"

	oQryBlock := FwExecStatement():New()
	oQryBlock:setQuery(cQuery)

	oQryBlock:SetFields({"MR_RECURSO"             ,;
	                    {"MK_DATDISP", "D", 8, 0} ,;
	                     "MK_HRINI"               ,;
	                     "MK_HRFIM"               ,;
	                     "MK_DISP"                ,;
	                     "MK_SEQ"                 })

	oQryBlock:setString(1, Self:cFilSMK      ) // MK_FILIAL
	oQryBlock:setString(2, HORA_NAO_BLOQUEADA) // MK_BLOQUE
	oQryBlock:setIn(3, {HORA_DISPONIVEL, HORA_EXTRA, HORA_EFETIVADA}) // MK_TIPO
	oQryBlock:setString(4, xFilial("SH1")        ) // H1_FILIAL
	oQryBlock:setString(5, Self:cFilSMR          ) // MR_FILIAL
	oQryBlock:setString(6, Self:oParDisp["cProg"]) // MR_PROG
	oQryBlock:setString(7, MR_TIPO_RECURSO       ) // MR_TIPO

	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_CALC_DISP, {"Query carregaDisponibilidade: " + cQuery,                               ;
	                                                      " Parametros: " + Self:cFilSMK + " " + HORA_NAO_BLOQUEADA +              ;
	                                                      " {" + HORA_DISPONIVEL + "," + HORA_EXTRA + "," + HORA_EFETIVADA + "}" + ;
	                                                      " " + xFilial("SH1") + " " + Self:cFilSMR + " " + Self:oParDisp["cProg"]})
	nTempoIni := MicroSeconds()
	cAlias    := oQryBlock:OpenAlias()
	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_CALC_DISP, {"Tempo query carregaDisponibilidade: " + cValToChar(MicroSeconds() - nTempoIni)})

	oQryBlock:doTcSetField(cAlias)

	While (cAlias)->(!EoF())
		cRecurso   := (cAlias)->MR_RECURSO
		cCalend    := (cAlias)->H1_CALEND
		cCentCusto := (cAlias)->H1_CCUSTO
		cRecIlimi  := (cAlias)->H1_ILIMITA
		dData      := (cAlias)->MK_DATDISP

		Self:criaDisponibilidadeParaAlocacao(Nil, cAlias, cRecurso, (cAlias)->MR_SITUACA)

		(cAlias)->(dbSkip())
		If (cAlias)->MR_RECURSO != cRecurso
			Self:setInfoRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi)
			Self:setUltimaDataRecurso(cRecurso, Self:oParDisp["dataFimDisponibilidade"], .F.)

			Self:setDisponibilidadeRecurso(cRecurso, Self:aDispAloc, .F.)
			Self:setJsonIndicesDisponibilidadeAlocacao(cRecurso, Self:oIndcAloc, .F.)
			Self:setJsonEfetivados(cRecurso, Self:oIndcEfet, .F.)

			FwFreeArray(Self:aDispAloc)
			FwFreeObj(Self:oIndcAloc)
			FwFreeObj(Self:oIndcEfet)

			Self:aDispAloc := {}
			Self:oIndcAloc := JsonObject():New()
			Self:oIndcEfet := JsonObject():New()
		EndIf
	End
	(cAlias)->(dbCloseArea())

	oQryBlock:Destroy()

	FwFreeObj(Self:oProdsEfet)
Return Nil

/*/{Protheus.doc} carregaProdutosEfetivados
Carrega os produtos efetivados para geração da disponibilidade.
@author Lucas Fagundes
@since 24/04/2024
@version P12
@return Nil
/*/
Method carregaProdutosEfetivados() Class PCPA152Disponibilidade
	Local cAlias    := GetNextAlias()
	Local cChave    := ""
	Local cQuery    := ""
	Local nTempoIni := 0

	Self:oProdsEfet := JsonObject():New()

	cQuery := "SELECT DISTINCT SMR.MR_RECURSO,"
	cQuery +=                " HWF.HWF_DATA,"
	cQuery +=                " HWF.HWF_HRINI,"
	cQuery +=                " HWF.HWF_HRFIM,"
	cQuery +=                " SC2.C2_PRODUTO"
	cQuery +=   " FROM " + RetSqlName("SMR") + " SMR"
	cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK"
	cQuery +=     " ON SMK.MK_FILIAL  = '" + xFilial("SMK") + "'"
	cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG"
	cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP"
	cQuery +=    " AND SMK.MK_TIPO    = '" + HORA_EFETIVADA + "'"
	cQuery +=    " AND SMK.MK_BLOQUE  = '" + HORA_NAO_BLOQUEADA + "'"
	cQuery +=    " AND SMK.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("HWF") + " HWF"
	cQuery +=     " ON HWF.HWF_FILIAL = '" + xFilial("HWF") + "'"
	cQuery +=    " AND HWF.HWF_RECURS = SMR.MR_RECURSO"
	cQuery +=    " AND HWF.HWF_DATA   = SMK.MK_DATDISP"
	cQuery +=    " AND HWF.HWF_HRFIM  = SMK.MK_HRFIM"
	cQuery +=    " AND HWF.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2"
	cQuery +=     " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "'"
	cQuery +=    " AND " + PCPQrySC2("SC2", "HWF.HWF_OP")
	cQuery +=    " AND SC2.C2_STATUS  = '" + STATUS_ORDEM_EFETIVADA + "'"
	cQuery +=    " AND SC2.C2_DATRF   = ' '"
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE SMR.MR_FILIAL  = '" + xFilial("SMR") + "'"
	cQuery +=    " AND SMR.MR_PROG    = '" + Self:oParDisp["cProg"] + "'"
	cQuery +=    " AND SMR.MR_TIPO    = '" + MR_TIPO_RECURSO        + "' "
	cQuery +=    " AND SMR.D_E_L_E_T_ = ' '"

	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_CALC_DISP, {"Query carregaProdutosEfetivados: " + cQuery})
	nTempoIni := MicroSeconds()
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)
	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_CALC_DISP, {"Tempo query carregaProdutosEfetivados: " + cValToChar(MicroSeconds() - nTempoIni)})

	While (cAlias)->(!EoF())
		cChave := (cAlias)->MR_RECURSO + (cAlias)->HWF_DATA

		If !Self:oProdsEfet:hasProperty(cChave)
			Self:oProdsEfet[cChave] := {}
		EndIf
		aAdd(Self:oProdsEfet[cChave], {__Hrs2Min((cAlias)->HWF_HRINI), __Hrs2Min((cAlias)->HWF_HRFIM), (cAlias)->C2_PRODUTO})

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return Nil

/*/{Protheus.doc} getDisponibilidadeRecurso
Retorna a disponibilidade de um recurso.
(retorna os horários em minutos, usar a função __Min2Hrs(nMinutos, lString) para converter)

@author Lucas Fagundes
@since 04/04/2023
@version P12
@param 01 cRecurso  , Caracter, Codigo do recurso que irá buscar a disponibilidade.
@param 02 lAdicional, Logico  , Indica que deve buscar na lista de disponibilidade adicional.
@return aDispRec, Array, Array com os periodos de disponibilidade do recurso, no formato: aDispRec[x][1] = Data
                                                                                          aDispRec[x][2] = Hora inicio
                                                                                          aDispRec[x][3] = Hora fim
                                                                                          aDispRec[x][4] = Tempo total do periodo
/*/
Method getDisponibilidadeRecurso(cRecurso, lAdicional) Class PCPA152Disponibilidade
	Local aDispRec := {}

	aDispRec := Self:oProcesso:retornaListaGlobal("DISPONIBILIDADE_RECURSOS" + Iif(lAdicional, "_ADICIONAL", ""), cRecurso)
	If Empty(aDispRec) .And. lAdicional
		aDispRec := Self:getDisponibilidadeRecurso(cRecurso, .F.)
	EndIf

Return aDispRec

/*/{Protheus.doc} setDisponibilidadeRecurso
Seta a disponibilidade de um recurso na memória global.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá salvar a disponibilidade.
@param 02 aDisp     , Array   , Array com a disponibilidade que será salva.
@param 03 lAdicional, Logico  , Indica que deve salvar na lista de disponibilidade adicional.
@return Nil
/*/
Method setDisponibilidadeRecurso(cRecurso, aDisp, lAdicional) Class PCPA152Disponibilidade

	Self:oProcesso:adicionaListaGlobal("DISPONIBILIDADE_RECURSOS" + Iif(lAdicional, "_ADICIONAL", ""), cRecurso, aDisp, .F.)

Return Nil

/*/{Protheus.doc} retornaQueryRecursos
Retorna as instruções SQL para a query de processamento de recursos.
@author Lucas Fagundes
@since 06/06/2023
@version P12
@return aQuery, Array, Array com os instruções SQL para query de recursos.
/*/
Method retornaQueryRecursos() Class PCPA152Disponibilidade
	Local aQuery     := Array(3)
	Local cCampos    := ""
	Local cFrom      := ""
	Local cWhere     := ""
	Local cTemp      := ""
	Local lFiltraCT  := !Empty(Self:oParDisp["centroTrabalho"])
	Local lFiltraRec := !Empty(Self:oParDisp["recursos"])
	Local lFiltraPrd := !Empty(Self:oParDisp["produto"])
	Local lFiltraGrp := !Empty(Self:oParDisp["grupoProduto"])
	Local lFiltraTpP := !Empty(Self:oParDisp["tipoProduto"])

	cTemp := Self:oProcesso:getNomeTempTable()

	cCampos := /*SELECT*/" DISTINCT "
	cCampos +=           " SH1.H1_CODIGO, "
	cCampos +=           " SH1.H1_CALEND, "
	cCampos +=           " SH1.H1_CCUSTO, "
	cCampos +=           " SH1.H1_ILIMITA, "
	cCampos +=           " SH1.H1_CTRAB, "
	cCampos +=           " AUX.CTRAB "

	cFrom += /*FROM*/RetSqlName("SH1") + " SH1 "
	cFrom += " LEFT JOIN (SELECT DISTINCT SG2.G2_RECURSO RECURSO, "
	cFrom +=                            " SG2.G2_CTRAB   CTRAB, "
	cFrom +=                            " SG2.G2_PRODUTO PRODUTO "
	cFrom +=              " FROM " + RetSqlName("SG2") + " SG2 "
	cFrom +=             " WHERE SG2.G2_FILIAL  = '" + xFilial("SG2") + "' "
	cFrom +=               " AND SG2.D_E_L_E_T_ = ' ' "

	If Self:oParDisp["utiliza_shy"]
		cFrom +=         " UNION "
		cFrom +=        " SELECT DISTINCT SHY.HY_RECURSO RECURSO, "
		cFrom +=                        " SHY.HY_CTRAB   CTRAB, "
		cFrom +=                        " SC2.C2_PRODUTO PRODUTO "
		cFrom +=          " FROM " + RetSqlName("SHY") + " SHY "
		cFrom +=         " INNER JOIN " + RetSqlName("SC2") + " SC2 "
		cFrom +=            " ON SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
		cFrom +=           " AND " + PCPQrySC2("SC2", "SHY.HY_OP") //Compara C2_NUM... com SHY.HY_OP
		cFrom +=           " AND SC2.C2_DATRF   = ' ' "
		cFrom +=           " AND SC2.D_E_L_E_T_ = ' ' "
		cFrom +=         " WHERE SHY.HY_FILIAL  = '" + xFilial("SHY") + "' "
		cFrom +=           " AND SHY.HY_TEMPAD <> 0 "
		cFrom +=           " AND SHY.D_E_L_E_T_ = ' ' "
	EndIf

	If Self:oParDisp["dicionarioAlternativo"]
		cFrom +=  " UNION  "
		cFrom += " SELECT SH3.H3_RECALTE RECURSO, "
		cFrom +=        " CASE "
		cFrom +=            " WHEN TEMP.MF_CTRAB = ' ' THEN SH1.H1_CTRAB "
		cFrom +=            " ELSE TEMP.MF_CTRAB "
		cFrom +=        " END CTRAB, "
		cFrom +=        " SH3.H3_PRODUTO PRODUTO "
		cFrom +=   " FROM " + RetSqlName("SH3") + " SH3 "
		cFrom += "  INNER JOIN (SELECT DISTINCT TEMP.MF_ROTEIRO, "
		cFrom +=                              " TEMP.MF_OPER, "
		cFrom +=                              " TEMP.MF_RECURSO, "
		cFrom +=                              " TEMP.PRODUTO, "
		cFrom +=                              " TEMP.MF_CTRAB "
		cFrom +=                " FROM " + cTemp + " TEMP) TEMP "
		cFrom +=     " ON TEMP.MF_ROTEIRO = SH3.H3_CODIGO  "
		cFrom +=    " AND TEMP.MF_OPER    = SH3.H3_OPERAC "
		cFrom +=    " AND TEMP.MF_RECURSO = SH3.H3_RECPRIN "
		cFrom +=    " AND TEMP.PRODUTO    = SH3.H3_PRODUTO "
		cFrom +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cFrom +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
		cFrom +=    " AND SH1.H1_CODIGO  = SH3.H3_RECALTE "
		cFrom +=    " AND SH1.D_E_L_E_T_ = ' ' "
		cFrom +=  " WHERE SH3.H3_FILIAL  = '" + xFilial("SH3") + "' "
		cFrom +=    " AND SH3.D_E_L_E_T_ = ' ' "
		cFrom +=  " UNION  "
		cFrom += " SELECT SH2.H2_RECALTE RECURSO, "
		cFrom +=        " CASE "
		cFrom +=            " WHEN TEMP.MF_CTRAB = ' ' THEN SH1.H1_CTRAB "
		cFrom +=            " ELSE TEMP.MF_CTRAB "
		cFrom +=        " END CTRAB, "
		cFrom +=        " TEMP.PRODUTO PRODUTO "
		cFrom +=   " FROM " + RetSqlName("SH2") + " SH2 "
		cFrom +=  " INNER JOIN (SELECT DISTINCT TEMP.MF_RECURSO, "
		cFrom +=                              " TEMP.MF_ROTEIRO, "
		cFrom +=                              " TEMP.MF_OPER, "
		cFrom +=                              " TEMP.MF_CTRAB, "
		cFrom +=                              " TEMP.PRODUTO "
		cFrom +=                " FROM " + cTemp + " TEMP) TEMP "
		cFrom +=     " ON TEMP.MF_RECURSO = SH2.H2_RECPRIN "
		cFrom +=  " INNER JOIN " + RetSqlName("SH1") + " SH1 "
		cFrom +=     " ON SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
		cFrom +=    " AND SH1.H1_CODIGO  = SH2.H2_RECALTE "
		cFrom +=    " AND SH1.D_E_L_E_T_ = ' ' "
		cFrom +=  " WHERE SH2.H2_FILIAL  = '" + xFilial("SH2") + "' "
		cFrom +=    " AND NOT EXISTS (SELECT 1  "
		cFrom +=                      " FROM " + RetSqlName("SH3") + " SH3 "
		cFrom +=                     " WHERE SH3.H3_FILIAL  = '" + xFilial("SH3") + "' "
		cFrom +=                       " AND SH3.H3_CODIGO  = TEMP.MF_ROTEIRO "
		cFrom +=                       " AND SH3.H3_OPERAC  = TEMP.MF_OPER "
		cFrom +=                       " AND SH3.H3_PRODUTO = TEMP.PRODUTO "
		cFrom +=                       " AND SH3.H3_FERRAM  = ' ' "
		cFrom +=                       " AND SH3.D_E_L_E_T_ = ' ') "
		cFrom +=    " AND SH2.D_E_L_E_T_ = ' ' "
	EndIf

	cFrom += " ) AUX "
	cFrom += " ON AUX.RECURSO = SH1.H1_CODIGO "

	If lFiltraPrd .Or. lFiltraGrp .Or. lFiltraTpP
		cFrom += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
		cFrom +=    " ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cFrom +=   " AND SB1.B1_COD = AUX.PRODUTO "
		cFrom +=   " AND SB1.D_E_L_E_T_ = ' ' "

		If lFiltraPrd
			cFrom += " AND SB1.B1_COD IN " + filInPar(Self:oParDisp["produto"])
		EndIf

		If lFiltraGrp
			cFrom += " AND SB1.B1_GRUPO IN " + filInPar(Self:oParDisp["grupoProduto"])
		EndIf

		If lFiltraTpP
			cFrom += " AND SB1.B1_TIPO IN " + filInPar(Self:oParDisp["tipoProduto"])
		EndIf
	EndIf

	cWhere := /*WHERE*/" SH1.H1_FILIAL  = '" + xFilial("SH1") + "' "
	cWhere +=      " AND SH1.D_E_L_E_T_ = ' ' "

	If lFiltraCT
		cWhere +=   " AND ( "
		cWhere +=       " (AUX.CTRAB IN " + filInPar(Self:oParDisp["centroTrabalho"]) + " AND AUX.CTRAB != ' ') OR "
		cWhere +=       " ((AUX.CTRAB IS NULL OR AUX.CTRAB = ' ') AND SH1.H1_CTRAB IN " + filInPar(Self:oParDisp["centroTrabalho"]) + " ) "
		cWhere +=   " ) "
	EndIf

	If lFiltraRec
		cWhere += " AND SH1.H1_CODIGO IN " + filInPar(Self:oParDisp["recursos"])
	EndIf

	aQuery[1] := cCampos
	aQuery[2] := cFrom
	aQuery[3] := cWhere

Return aQuery

/*/{Protheus.doc} registraRecursoCT
Registra o vínculo de um CT com um Recurso para gravação na tabela SMT

@author lucas.franca
@since 15/06/2023
@version P12
@param 01 oRecXCTrb, JsonObject, Json com o registro dos vínculos de CT x Recurso. Enviado por referência
@param 02 cFiltroCT, Caracter  , String para filtro de centro de trabalho
@param 03 cRecurso , Caracter  , Código do recurso
@param 04 cCodCT   , Caracter  , Código do centro de trabalho
@return Nil
/*/
Method registraRecursoCT(oRecXCTrb, cFiltroCT, cRecurso, cCodCT) CLASS PCPA152Disponibilidade

	If oRecXCTrb:HasProperty(cRecurso) == .F.
		oRecXCTrb[cRecurso] := JsonObject():New()
	EndIf

	If Empty(cFiltroCT) .Or. ( "|" + RTrim(cCodCT) + "|" $ cFiltroCT )
		oRecXCTrb[cRecurso][cCodCT] := .T.
	EndIf

Return Nil

/*/{Protheus.doc} filInPar
Monta a condição IN para os filtros da query.
@type  Static Function
@author Lucas Fagundes
@since 06/06/2023
@version P12
@param 01 aFiltro, Array , Array com os itens que serão adicionados na condição.
@return cFiltro, Caracter, Condição IN para a query.
/*/
Static Function filInPar(aFiltro)
	Local cFiltro := ""
	Local nIndex  := 0
	Local nTotal  := Len(aFiltro)

	cFiltro := " ("
	For nIndex := 1 To nTotal
		If Empty(aFiltro[nIndex])
			cFiltro += "' '"
		Else
			cFiltro += "'" + aFiltro[nIndex] + "'"
		EndIf

		If nIndex < nTotal
			cFiltro += ", "
		EndIf
	Next
	cFiltro += ") "

Return cFiltro

/*/{Protheus.doc} CTEmTexto
Monta uma string com os valores do array de filtro de CT
concatenados e separados por | para utilizar com a expressão advpl $

@type  Static Function
@author lucas.franca
@since 15/06/2023
@version P12
@param 01 aCT, Array , Array com os CTs para filtro
@return cFiltro, Caracter, Códigos do CT concatenados e separados por |
/*/
Static Function CTEmTexto(aCT)
	Local cFiltro := ""
	Local nIndex  := 0
	Local nTotal  := 0

	If !Empty(aCT)
		nTotal := Len(aCT)
		cFiltro := "|"
		For nIndex := 1 To nTotal
			cFiltro += RTrim(aCT[nIndex]) + "|"
		Next nIndex
	EndIf

Return cFiltro

/*/{Protheus.doc} ajustaHoraInicial
Ajusta a hora de inicio do calendario de acordo com o parâmetro de hora inicial
@author Lucas Fagundes
@since 27/06/2023
@version P12
@param aCalend, Array, Array com o calendario que irá ajustar a hora inicial
@return Nil
/*/
Method ajustaHoraInicial(aCalend) Class PCPA152Disponibilidade
	Local cHoraFim   := ""
	Local nIndex     := 1
	Local nRemovidos := 0
	Local nTotal     := 0

	If !Empty(aCalend)
		nTotal := Len(aCalend[CALEND_POS_HORAS])

		While nIndex <= nTotal
			If aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] >= Self:oParDisp["horaInicial"]
				Exit
			EndIf

			If aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM] > Self:oParDisp["horaInicial"]
				aCalend[CALEND_POS_MINUTOS] -= aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_TOTAL]

				aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI] := Self:oParDisp["horaInicial"]
				aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_TOTAL  ] := Self:totalDeMinutos(aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAINI],;
																							aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM])

				aCalend[CALEND_POS_MINUTOS] += aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_TOTAL]
				Exit
			EndIf
			cHoraFim := aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_HORAFIM]

			aCalend[CALEND_POS_MINUTOS] -= aCalend[CALEND_POS_HORAS][nIndex][CALEND_POS_TOTAL]
			aDel(aCalend[CALEND_POS_HORAS], nIndex)

			nRemovidos++
			nTotal--

			If cHoraFim == Self:oParDisp["horaInicial"]
				Exit
			EndIf
		End

		If nRemovidos > 0
			aSize(aCalend[CALEND_POS_HORAS], nTotal)
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} montaParametros
Monta json com os parâmetros para execução.
@author Lucas Fagundes
@since 04/07/2023
@version P12
@return Nil
/*/
Method montaParametros() Class PCPA152Disponibilidade
	Local cHora := ""

	Self:oParDisp := JsonObject():New()

	If Self:lCRP
		Self:oParDisp["dataInicial"             ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataInicial")),3))
		Self:oParDisp["dataFinal"               ] := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataFinal")),3))
		Self:oParDisp["MV_PRECISA"              ] := Self:oProcesso:retornaParametro("MV_PRECISA")
		Self:oParDisp["cProg"                   ] := Self:oProcesso:retornaProgramacao()
		Self:oParDisp["recursos"                ] := Self:oProcesso:retornaParametro("recursos")
		Self:oParDisp["centroTrabalho"          ] := Self:oProcesso:retornaParametro("centroTrabalho")
		Self:oParDisp["replanejaSacramentadas"  ] := Self:oProcesso:retornaParametro("replanejaSacramentadas")
		Self:oParDisp["visualizaDisponibilidade"] := Self:oProcesso:retornaParametro("visualizaDisponibilidade")
		Self:oParDisp["MV_DISPADC"              ] := Self:oProcesso:retornaParametro("MV_DISPADC")
		Self:oParDisp["utiliza_shy"             ] := Self:oProcesso:retornaParametro("utiliza_shy")
		Self:oParDisp["produto"                 ] := Self:oProcesso:retornaParametro("produto")
		Self:oParDisp["grupoProduto"            ] := Self:oProcesso:retornaParametro("grupoProduto")
		Self:oParDisp["tipoProduto"             ] := Self:oProcesso:retornaParametro("tipoProduto")
		Self:oParDisp["dicionarioAlternativo"   ] := AliasInDic("HZ7")
		Self:oParDisp["dataFimDisponibilidade"  ] := CToD(PCPConvDat((Self:oProcesso:retornaParametro("dataFimDisponibilidade")),3))

		cHora := Self:oProcesso:retornaParametro("horaInicial")
		If Empty(cHora)
			cHora := "00:00"
		EndIf
		Self:oParDisp["horaInicial"] := cHora
	Else
		Self:defineParametro("cProg"                 , "")
		Self:defineParametro("dataInicial"           , Date())
		Self:defineParametro("dataFinal"             , Date()+30)
		Self:defineParametro("horaInicial"           , "00:00")
		Self:defineParametro("MV_PRECISA"            , GetMv("MV_PRECISA"))
		Self:defineParametro("replanejaSacramentadas", .T.)
		Self:defineParametro("utiliza_shy"           , .F.)
	EndIf

Return Nil

/*/{Protheus.doc} buscaDataUltimaDisponibilidadeRecurso
Busca a ultima data que um recurso possui disponiblidade.
@author Lucas Fagundes
@since 18/12/2023
@version P12
@param cRecurso, Caracter, Recurso que irá buscar a disponibilidade.
@return dData, Date, Ultima data que o recurso possui disponibilidade.
/*/
Method buscaDataUltimaDisponibilidadeRecurso(cRecurso) Class PCPA152Disponibilidade
	Local dData    := Nil
	Local lError   := .F.
	Local dDataAdc := Nil
	Local dDataSml := Nil

	dData := Self:getUltimaDataRecurso(cRecurso, .F., @lError)
	If lError
		dData := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataFinal")),3))
	EndIf

	dDataAdc := Self:getUltimaDataRecurso(cRecurso, .T., @lError)
	If !lError .And. dDataAdc > dData
		dData := dDataAdc
	EndIf

	If Self:lSimula
		dDataSml := Self:getUltimaDataRecurso(cRecurso, .T., @lError, .T.)
		If !lError .And. dDataSml > dData
			dData := dDataSml
		EndIf
	EndIf

Return dData

/*/{Protheus.doc} efetivaDisponibilidadeAdicional
Realiza a efetivação da disponibilidade adicional de um recurso.
@author Lucas Fagundes
@since 20/12/2023
@version P12
@return Nil
/*/
Method efetivaDisponibilidadeAdicional() Class PCPA152Disponibilidade
	Local aDispRec := {}
	Local aDisps   := Self:getDispSMR(Nil, .T.)
	Local aDispSMK := {}
	Local aDispSMR := {}
	Local cRecurso := ""
	Local dUltData := Nil
	Local lError   := .F.
	Local nIndex   := 0
	Local nIndSMR  := 0
	Local nTotal   := Len(aDisps)
	Local nTotSMR  := 0
	Local oJsAloc  := Nil
	Local oJsInd   := Nil
	Local lFerramenta := .F.

	For nIndex := 1 To nTotal
		cRecurso    := aDisps[nIndex][1]
		aDispSMR    := aDisps[nIndex][2]
		nTotSMR     := Len(aDispSMR)
		lFerramenta := Right(cRecurso, 7) == IDENTIFICADOR_FERRAMENTA

		If !lFerramenta
			aDispRec := Self:getDisponibilidadeRecurso(cRecurso, .T.)
			oJsInd   := Self:getJsonIndicesDisponibilidadeAlocacao(cRecurso, .T.)
			oJsAloc  := Self:getJsonEfetivados(cRecurso, .T.)

			Self:setDisponibilidadeRecurso(cRecurso, aDispRec, .F.)
			Self:setJsonIndicesDisponibilidadeAlocacao(cRecurso, oJsInd, .F.)
			Self:setJsonEfetivados(cRecurso, oJsAloc, .F.)
			Self:setUltimaDataRecurso(cRecurso, Self:getUltimaDataRecurso(cRecurso, .T.), .F.)
		EndIf
		Self:setDispSMR(cRecurso, aDispSMR, .F.)

		For nIndSMR := 1 To nTotSMR
			aDispSMK := Self:getDispSMK(aDispSMR[nIndSMR][ARRAY_MR_DISP], .T.)

			Self:setDispSMK(aDispSMR[nIndSMR][ARRAY_MR_DISP], aDispSMK, .F.)

			aSize(aDispSMK, 0)
			aSize(aDispSMR[nIndSMR], 0)
		Next

		If !lFerramenta
			Self:limpaFlagDisponibilidadeAdicionalRecurso(cRecurso)
		EndIf

		aSize(aDispRec, 0)
		aSize(aDispSMR, 0)
		aSize(aDisps[nIndex], 0)
		FwFreeObj(oJsInd)
		FwFreeObj(oJsAloc)
	Next

	dUltData := Self:getFimDataDispAdicional(.T., @lError)
	If !lError
		Self:setFimDataDispAdicional(dUltData, .F.)
	EndIf

	Self:limpaDisponibilidadeAdicional(.F.)

	Self:oProcesso:gravaValorGlobal("GEROU_DISPONIBILIDADE_ADICIONAL", .T.)

	aSize(aDisps, 0)
Return Nil

/*/{Protheus.doc} criaPeriodoDisponibilidade
Cria o array com as informações de um periodo de disponibilidade de um recurso (usado na alocação das ordens de produção).
@author Lucas Fagundes
@since 21/12/2023
@version P12
@param 01 aDispSMK , Array   , Array com a disponibilidade (tabela SMK).
@param 02 cAlias   , Caracter, Indica que deve buscar as informações do alias consultando a SMK.
@param 03 cRecurso , Caracter, Código do recurso que irá criar o periodo.
@param 04 nIndDisp , Numérico, Indice da disponibilidade do recurso.
@param 05 cSituacao, Caracter, Situação do recurso.
@return aPeriodo, Array, Array com a disponibilidade de um recurso.
/*/
Method criaPeriodoDisponibilidade(aDispSMK, cAlias, cRecurso, nIndDisp, cSituacao) Class PCPA152Disponibilidade
	Local aPeriodo := Array(TAMANHO_ARRAY_DISP_RECURSO)
	Local lAlias   := cAlias != Nil

	If lAlias
		aPeriodo[ARRAY_DISP_RECURSO_DATA       ] := (cAlias)->MK_DATDISP
		aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO] := __Hrs2Min((cAlias)->MK_HRINI)
		aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM   ] := __Hrs2Min((cAlias)->MK_HRFIM)
		aPeriodo[ARRAY_DISP_RECURSO_TIPO       ] := (cAlias)->MK_TIPO
	Else
		aPeriodo[ARRAY_DISP_RECURSO_DATA       ] := aDispSMK[ARRAY_MK_DATDISP]
		aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO] := __Hrs2Min(aDispSMK[ARRAY_MK_HRINI])
		aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM   ] := __Hrs2Min(aDispSMK[ARRAY_MK_HRFIM])
		aPeriodo[ARRAY_DISP_RECURSO_TIPO       ] := aDispSMK[ARRAY_MK_TIPO]
	EndIf
	aPeriodo[ARRAY_DISP_RECURSO_TEMPO          ] := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM] - aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE] := {}
	aPeriodo[ARRAY_DISP_RECURSO_ILIMITADO      ] := cSituacao == RECURSO_ILIMITADO

	aPeriodo[ARRAY_DISP_RECURSO_INFOSMK] := Array(ARRAY_INFOSMK_TAMANHO)
	If lAlias
		aPeriodo[ARRAY_DISP_RECURSO_INFOSMK][ARRAY_INFOSMK_MK_ID ] := (cAlias)->MK_DISP
		aPeriodo[ARRAY_DISP_RECURSO_INFOSMK][ARRAY_INFOSMK_MK_SEQ] := (cAlias)->MK_SEQ
	Else
		aPeriodo[ARRAY_DISP_RECURSO_INFOSMK][ARRAY_INFOSMK_MK_ID ] := aDispSMK[ARRAY_MK_DISP]
		aPeriodo[ARRAY_DISP_RECURSO_INFOSMK][ARRAY_INFOSMK_MK_SEQ] := aDispSMK[ARRAY_MK_SEQ ]
	EndIf

	aAdd(aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE], Array(ARRAY_DISPONIBILIDADE_TAMANHO))
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_RECURSO               ] := cRecurso
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_DATA                  ] := aPeriodo[ARRAY_DISP_RECURSO_DATA       ]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_HORA_INICIO           ] := aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_HORA_FIM              ] := aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM   ]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_TEMPO                 ] := aPeriodo[ARRAY_DISP_RECURSO_TEMPO      ]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_TIPO                  ] := VM_TIPO_DISPONIVEL
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_INDICE_DISP           ] := nIndDisp
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ID   ] := ""
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_OPERACAO_ALOCADA_ORDEM] := ""
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_INFOSMK               ] := aPeriodo[ARRAY_DISP_RECURSO_INFOSMK]
	aPeriodo[ARRAY_DISP_RECURSO_DISPONIBILIDADE][1][ARRAY_DISPONIBILIDADE_FERRAMENTA_DISPONIVEL ] := .T.

	If aPeriodo[ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA
		aPeriodo[ARRAY_DISP_RECURSO_PRODUTOS_EFETIVADOS] := Self:buscaProdutosEfetivados(cRecurso                                ,;
		                                                                                 aPeriodo[ARRAY_DISP_RECURSO_DATA       ],;
		                                                                                 aPeriodo[ARRAY_DISP_RECURSO_HORA_INICIO],;
		                                                                                 aPeriodo[ARRAY_DISP_RECURSO_HORA_FIM   ])
	EndIf

Return aPeriodo

/*/{Protheus.doc} buscaProdutosEfetivados
Busca os produto que encerram no final de um periodo de disponibilidade efetivada.
@author Lucas Fagundes
@since 27/03/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que irá buscar os produtos.
@param 02 dData   , Date    , Data do período que irá buscar os produtos
@param 03 nHoraIni, Numeric , Hora inicial do período efetivado.
@param 04 nHoraFim, Numeric , Hora final do período efetivado.
@return aProdutos, Array, Array com os produtos efetivados.
/*/
Method buscaProdutosEfetivados(cRecurso, dData, nHoraIni, nHoraFim) Class PCPA152Disponibilidade
	Local aProdutos := {}
	Local cData     := DToS(dData)
	Local cChave    := cRecurso + cData
	Local nIndex    := 0
	Local nTotal    := 0

	If Self:oProdsEfet:hasProperty(cChave)
		nTotal := Len(Self:oProdsEfet[cChave])

		For nIndex := 1 To nTotal
			If Self:oProdsEfet[cChave][nIndex][1] >= nHoraIni .And. Self:oProdsEfet[cChave][nIndex][2] == nHoraFim
				aAdd(aProdutos, Self:oProdsEfet[cChave][nIndex][3])
			EndIf
		Next
	EndIf

Return aProdutos

/*/{Protheus.doc} buscaSequenciaSMR
Retorna a sequência da tabela SMR.
@author Lucas Fagundes
@since 11/01/2024
@version P12
@return nSequen, Numerico, Próximo registro da sequência da SMR.
/*/
Method buscaSequenciaSMR() Class PCPA152Disponibilidade
	Local nSequen := 0
	Local lError  := .F.
	Local cQuery  := ""
	Local cAlias  := ""

	If Self:lAdicional
		Self:oProcesso:retornaValorGlobal("MR_DISP_SEQUENCE", @lError)

		If lError
			cAlias := GetNextAlias()

			cQuery := " SELECT COALESCE(MAX(SMR.MR_DISP), '0') sequen "
			cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
			cQuery +=  " WHERE SMR.MR_FILIAL = '" + xFilial("SMR") + "' "
			cQuery +=    " AND SMR.MR_PROG   = '" + Self:oParDisp["cProg"] + "' "

			dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

			If (cAlias)->(!EoF())
				nSequen := Val((cAlias)->sequen)
			EndIf
			(cAlias)->(dbCloseArea())

			If nSequen > 0
				Self:oProcesso:gravaValorGlobal("MR_DISP_SEQUENCE", nSequen)
			EndIf
		EndIf
	EndIf

	Self:oProcesso:gravaValorGlobal("MR_DISP_SEQUENCE", @nSequen, .F., .T.)

Return nSequen

/*/{Protheus.doc} criaDisponibilidadeParaAlocacao
Cria o array da disponibilidade do recurso que é usado na alocação das ordens de produção e o json com o controle dos indices do array.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 aDispSMK , Array   , Array com a disponibilidade (tabela SMK).
@param 02 cAlias   , Caracter, Indica que deve buscar as informações do alias consultando a SMK.
@param 03 cRecurso , Caracetr, Código do recurso que está criando a disponibilidade.
@param 04 cSituacao, Caracter, Situação do recurso.
@return Nil
/*/
Method criaDisponibilidadeParaAlocacao(aDispSMK, cAlias, cRecurso, cSituacao) Class PCPA152Disponibilidade
	Local aDisp    := Self:criaPeriodoDisponibilidade(aDispSMK, cAlias, cRecurso, Len(Self:aDispAloc)+1, cSituacao)
	Local cData    := DToS(aDisp[ARRAY_DISP_RECURSO_DATA])
	Local nTamDisp := 0
	Local oIndcAdc := Nil
	Local oAlocAdc := Nil

	aAdd(Self:aDispAloc, aDisp)

	nTamDisp := Len(Self:aDispAloc)
	If !Self:oIndcAloc:hasProperty(cData)
		Self:oIndcAloc[cData] := Array(ARRAY_INDICE_DISP_TAMANHO)
		Self:oIndcAloc[cData][ARRAY_INDICE_DISP_START       ] := nTamDisp
		Self:oIndcAloc[cData][ARRAY_INDICE_DISP_HORA_INICIAL] := aDisp[ARRAY_DISP_RECURSO_HORA_INICIO]
		Self:oIndcAloc[cData][ARRAY_INDICE_DISP_INICIO_DATA ] := nTamDisp
		Self:oIndcAloc[cData][ARRAY_INDICE_DISP_DISPONIVEL  ] := .F.
	EndIf
	Self:oIndcAloc[cData][ARRAY_INDICE_DISP_FINISH    ] := nTamDisp
	Self:oIndcAloc[cData][ARRAY_INDICE_DISP_FIM_DATA  ] := nTamDisp
	Self:oIndcAloc[cData][ARRAY_INDICE_DISP_HORA_FINAL] := aDisp[ARRAY_DISP_RECURSO_HORA_FIM]

	// Data disponivel se....
	Self:oIndcAloc[cData][ARRAY_INDICE_DISP_DISPONIVEL] := Self:oIndcAloc[cData][ARRAY_INDICE_DISP_DISPONIVEL] .Or.; // ... alguma outra disponibilidade nesta data esta disponivel
	                                                       aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_DISPONIVEL   .Or.; // ... a disponibilidade é do tipo disponivel
	                                                       aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_EXTRA        .Or.; // ... a disponibilidade é do tipo extra
	                                                       aDisp[ARRAY_DISP_RECURSO_ILIMITADO]                       // ... o recurso é ilimitado

	If aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_EFETIVADA
		If !Self:oIndcEfet:hasProperty("indices")
			Self:oIndcEfet["indices"] := {}
		EndIf

		aAdd(Self:oIndcEfet["indices"], nTamDisp)

		Self:oIndcEfet[cValToChar(nTamDisp)] := .T.
	EndIf

	/*
		start/finish -> índices de disponibilidade do recurso que são atualizados
		conforme são realizados os consumos, para iniciar/terminar os processos
		somente até onde existem horas disponíveis
		inicioData/fimData -> índices de disponibilidade do recurso que não são
		atualizados durante o processo. Servem de referência para ter onde inicia e termina
		uma data, independente de existir disponibilidade.
	*/
	If Self:lAdicional
		oIndcAdc := Self:oInfoAdc["indices"  ]
		oAlocAdc := Self:oInfoAdc["alocacoes"]

		aAdd(Self:oInfoAdc["disponibilidade"], aClone(aDisp))

		If !oIndcAdc:hasProperty(cData)
			oIndcAdc[cData] := aClone(Self:oIndcAloc[cData])
		Else
			oIndcAdc[cData][ARRAY_INDICE_DISP_FINISH    ] := nTamDisp
			oIndcAdc[cData][ARRAY_INDICE_DISP_HORA_FINAL] := aDisp[ARRAY_DISP_RECURSO_HORA_FIM]
			oIndcAdc[cData][ARRAY_INDICE_DISP_FIM_DATA  ] := nTamDisp

			// Data disponivel se....
			oIndcAdc[cData][ARRAY_INDICE_DISP_DISPONIVEL] := oIndcAdc[cData][ARRAY_INDICE_DISP_DISPONIVEL]     .Or.; // ... alguma outra disponibilidade nesta data esta disponivel
			                                                 aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_DISPONIVEL .Or.; // ... a disponibilidade é do tipo disponivel
			                                                 aDisp[ARRAY_DISP_RECURSO_TIPO] == HORA_EXTRA      .Or.; // ... a disponibilidade é do tipo extra
			                                                 aDisp[ARRAY_DISP_RECURSO_ILIMITADO]                     // ... o recurso é ilimitado
		EndIf

		aAdd(oAlocAdc["indices"], nTamDisp)

		oAlocAdc[cValToChar(nTamDisp)] := .T.
	EndIf

Return Nil

/*/{Protheus.doc} setJsonIndicesDisponibilidadeAlocacao
Seta na global o json que controla os indices do array com a disponibilidade de um recurso.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá vincular o json.
@param 02 oJson     , Object  , Json que será gravado na global.
@param 03 lAdicional, Logico  , Indica que deve gravar na global temporaria para a disponibilidade adicional.
@return Nil
/*/
Method setJsonIndicesDisponibilidadeAlocacao(cRecurso, oJson, lAdicional) Class PCPA152Disponibilidade
	Local cJson := oJson:toJson()

	Self:oProcesso:gravaValorGlobal("JSON_INDICES_DISPONIBILIDADE_ALOCACAO_" + Iif(lAdicional, "ADICIONAL_", "") + cRecurso, cJson)

Return Nil

/*/{Protheus.doc} getJsonIndicesDisponibilidadeAlocacao
Retorna da global o json que controla os indices do array com a disponibilidade de um recurso.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar o json.
@param 02 lAdicional, Logico  , Indica que deve buscar da global temporaria criada para disponibilidade adicional.
@return oJson, Object, Json com os indices da disponibilidade do recurso.
/*/
Method getJsonIndicesDisponibilidadeAlocacao(cRecurso, lAdicional) Class PCPA152Disponibilidade
	Local oJson  := JsonObject():New()
	Local cJson  := ""
	Local lError := .F.

	cJson := Self:oProcesso:retornaValorGlobal("JSON_INDICES_DISPONIBILIDADE_ALOCACAO_" + Iif(lAdicional, "ADICIONAL_", "") + cRecurso, @lError)
	If !lError
		oJson:fromJson(cJson)
	EndIf

	If lError .And. lAdicional
		oJson := Self:getJsonIndicesDisponibilidadeAlocacao(cRecurso, .F.)
	EndIf

Return oJson

/*/{Protheus.doc} preparaGeracaoAdicional
Verifica quantos dias são necessarios gerar a disponibilidade adicional e prepara a classe para geração.
@author Lucas Fagundes
@since 12/01/2024
@version P12
@param 01 cRecurso, Caracter, Recurso que irá gerar a disponibilidade adicional.
@param 02 oInfo   , Object  , Json com as informações para geração da disponibilidade adicional.
@return lCria, Logico, Retorna se a disponibilidade pode ser gerada ou não.
/*/
Method preparaGeracaoAdicional(cRecurso, oInfo) Class PCPA152Disponibilidade
	Local dDataAloc  := oInfo["dataAlocacao"]
	Local dDataIni   := Nil
	Local dFimProg   := CtoD(PCPConvDat((Self:oProcesso:retornaParametro("dataFinal")),3))
	Local lCria      := .T.
	Local nTempoAloc := oInfo["tempoAlocacao"]

	dDataIni := Self:buscaDataUltimaDisponibilidadeRecurso(cRecurso) + 1
	If dDataIni - dFimProg > Self:oParDisp["MV_DISPADC"]
		lCria := .F.
	EndIf

	If lCria
		If dDataIni > dDataAloc
			dDataAloc := dDataIni
		EndIf

		dDataAloc--
		While nTempoAloc > 0 .And. (dDataAloc - dFimProg) <= Self:oParDisp["MV_DISPADC"]
			dDataAloc++

			aCalPad := Self:buscaCalendario(dDataAloc, oInfo["calendario"])

			nTempoAloc -= aCalPad[CALEND_POS_MINUTOS]
		End

		Self:oParDisp["dataInicial"] := dDataIni
		Self:oParDisp["dataFinal"  ] := dDataAloc

		oInfo["dataInicial"] := dDataIni
		oInfo["dataFinal"  ] := dDataAloc
	EndIf

Return lCria

/*/{Protheus.doc} limpaDisponibilidadeAdicional
Limpa as listas com a disponibilidade adicional.
@author Lucas Fagundes
@since 15/01/2024
@version P12
@param lLimpaFlag, Lógico, Indica que deve percorer os recursos e apagar as flags.
@return Nil
/*/
Method limpaDisponibilidadeAdicional(lLimpaFlag) Class PCPA152Disponibilidade
	Local aRecs  := {}
	Local nIndex := 0
	Local nTotal := 0

	If lLimpaFlag
		aRecs  := Self:getDispSMR(Nil, .T.)
		nTotal := Len(aRecs)

		For nIndex := 1 To nTotal
			Self:limpaFlagDisponibilidadeAdicionalRecurso(aRecs[nIndex][1])
		Next

		FwFreeArray(aRecs)
	EndIf

	Self:oProcesso:limpaListaGlobal("DADOS_SMR_ADICIONAL")
	Self:oProcesso:limpaListaGlobal("DADOS_SMK_ADICIONAL")
	Self:oProcesso:limpaListaGlobal("DISPONIBILIDADE_RECURSOS_ADICIONAL")

	Self:oProcesso:limpaValorGlobal("DATA_FIM_DISP_ADICIONAL_TEMP")

Return Nil

/*/{Protheus.doc} limpaFlagDisponibilidadeAdicionalRecurso
Limpa as flags de disponibilidade adicional de um recurso.
@author Lucas Fagundes
@since 25/01/2024
@version P12
@param cRecurso, Caracter, Recurso que irá limpar as flags.
@return Nil
/*/
Method limpaFlagDisponibilidadeAdicionalRecurso(cRecurso) Class PCPA152Disponibilidade

	Self:oProcesso:limpaValorGlobal("ULTIMA_DATA_" + cRecurso + "_ADICIONAL")
	Self:oProcesso:limpaValorGlobal("JSON_INDICES_DISPONIBILIDADE_ALOCACAO_" + "ADICIONAL_" + cRecurso)

Return Nil

/*/{Protheus.doc} setDispSMR
Grava na memória global a disponibilidade da tabela SMR.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso.
@param 02 aRegs     , Array   , Array com os registros da disponibilidade.
@param 03 lAdicional, Lógico  , Indica que deve salvar na lista de disponibilidade adicional.
@param 04 lFerram   , Lógico  , Indica que esta gravando a disponibilidade de uma ferramentas.
@return Nil
/*/
Method setDispSMR(cRecurso, aRegs, lAdicional, lFerram) Class PCPA152Disponibilidade
	Default lFerram := .F.

	If lFerram
		cRecurso += IDENTIFICADOR_FERRAMENTA
	EndIf

	Self:oProcesso:adicionaListaGlobal("DADOS_SMR" + Iif(lAdicional, "_ADICIONAL", ""), cRecurso, aRegs, .T., 2)

Return Nil

/*/{Protheus.doc} getDispSMR
Retorna da memória global os dados da tabela SMR.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso.
@param 02 lAdicional, Lógico  , Indica que deve buscar na lista de disponibilidade adicional.
@param 03 lFerram   , Lógico  , Indica que esta buscando a disponibilidade de uma ferramentas.
@return Array, Array com os dados salvos na memória global.
/*/
Method getDispSMR(cRecurso, lAdicional, lFerram) Class PCPA152Disponibilidade
	Default lFerram := .F.

	If lFerram
		cRecurso += IDENTIFICADOR_FERRAMENTA
	EndIf

Return Self:oProcesso:retornaListaGlobal("DADOS_SMR" + Iif(lAdicional, "_ADICIONAL", ""), cRecurso)

/*/{Protheus.doc} setDispSMK
Grava na memória global a disponibilidade da tabela SMK.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cCodDisp  , Caracter, Código da disponibilidade.
@param 02 aRegs     , Array   , Array com os registros da disponibilidade.
@param 03 lAdicional, Lógico  , Indica que deve salvar na lista de disponibilidade adicional.
@return Nil
/*/
Method setDispSMK(cCodDisp, aRegs, lAdicional) Class PCPA152Disponibilidade

	Self:oProcesso:adicionaListaGlobal("DADOS_SMK" + Iif(lAdicional, "_ADICIONAL", ""), cCodDisp, aRegs, .F.)

Return Nil

/*/{Protheus.doc} getDispSMR
Retorna da memória global os dados da tabela SMK.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cCodDisp  , Caracter, Código da disponibilidade.
@param 02 lAdicional, Lógico  , Indica que deve buscar na lista de disponibilidade adicional.
@return Array, Array com os dados salvos na memória global.
/*/
Method getDispSMK(cCodDisp, lAdicional) Class PCPA152Disponibilidade

Return Self:oProcesso:retornaListaGlobal("DADOS_SMK" + Iif(lAdicional, "_ADICIONAL", ""), cCodDisp)

/*/{Protheus.doc} setInfoRecurso
Grava as informações usada para calcular a disponibilidade do recurso.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso.
@param 02 cCalend   , Caracter, Calendário do recurso (H1_CALEND).
@param 03 cCentCusto, Caracter, Centro de custo do recurso (H1_CCUSTO).
@param 04 cRecIlimi , Caracter, Indicador se o recurso é ilimitado (H1_ILIMITA).
@return Nil
/*/
Method setInfoRecurso(cRecurso, cCalend, cCentCusto, cRecIlimi) Class PCPA152Disponibilidade
	Local oInfo := JsonObject():New()

	oInfo["H1_CALEND" ] := cCalend
	oInfo["H1_CCUSTO" ] := cCentCusto
	oInfo["H1_ILIMITA"] := cRecIlimi

	Self:oProcesso:gravaValorGlobal("INFO_RECURSO_" + cRecurso, oInfo:toJson())

	FreeObj(oInfo)
Return Nil

/*/{Protheus.doc} getInfoRecurso
Retorna as informações utilizadas para calcular a disponibilidade do recurso.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param cRecurso, Caracter, Código do recurso.
@return oInfo, Object, Json com as informações do recurso.
/*/
Method getInfoRecurso(cRecurso) Class PCPA152Disponibilidade
	Local cJson  := ""
	Local lError := .F.
	Local oInfo  := JsonObject():New()

	cJson := Self:oProcesso:retornaValorGlobal("INFO_RECURSO_" + cRecurso, @lError)
	If lError
		// Se não encontrou na memória global as informações do recurso, busca na tabela.
		// Não irá encontrar as informações do recurso quando processar em etapas e o recurso não possuir periodos disponiveis para alocação.
		SH1->(dbSetOrder(1))
		If SH1->(dbSeek(xFilial("SH1")+cRecurso))
			oInfo["H1_CALEND" ] := SH1->H1_CALEND
			oInfo["H1_CCUSTO" ] := SH1->H1_CCUSTO
			oInfo["H1_ILIMITA"] := SH1->H1_ILIMITA
		EndIf
	Else
		oInfo:fromJson(cJson)
	EndIf

Return oInfo

/*/{Protheus.doc} setUltimaDataRecurso
Grava flag com a última data que um recurso possui disponibilidade.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso.
@param 02 dData     , Date    , Data que irá setar na global.
@param 03 lAdicional, Lógico  , Indica disponibilidade adicional.
@param 03 lSimula   , Lógico  , Indica simulação na geração da disponibilidade.
@return Nil
/*/
Method setUltimaDataRecurso(cRecurso, dData, lAdicional, lSimula) Class PCPA152Disponibilidade
	Local cFlag    := "ULTIMA_DATA_" + cRecurso
	Local lError   := .F.
	Local dDataAux := Nil
	Default lSimula := .F.

	If lAdicional
		If lSimula
			cFlag += "_SIMULACAO"
		Else
			cFlag += "_ADICIONAL"
		EndIf
	EndIf

	dDataAux := Self:oProcesso:retornaValorGlobal(cFlag, @lError)
	If lError .Or. dData > dDataAux
		Self:oProcesso:gravaValorGlobal(cFlag, dData)
	EndIf

Return Nil

/*/{Protheus.doc} getUltimaDataRecurso
Retorna a última data que um recurso possui disponibilidade.

@author Lucas Fagundes
@since 23/01/2024
@version P12
@param 01 cRecurso  , Caracter, Código do recurso.
@param 02 lAdicional, Lógico  , Indica que deve verificar a disponibilidade adicional.
@param 03 lError    , Lógico  , Retorna por referência se ocorreu erro na busca.
@param 04 lSimula   , Lógico  , Indica simulação na geração da disponibilidade.
@return Date, Flag salva na váriavel global.
/*/
Method getUltimaDataRecurso(cRecurso, lAdicional, lError, lSimula) Class PCPA152Disponibilidade
	Local cFlag := "ULTIMA_DATA_" + cRecurso
	Default lSimula := .F.

	If lAdicional
		If lSimula
			cFlag += "_SIMULACAO"
		Else
			cFlag += "_ADICIONAL"
		EndIf
	EndIf

Return Self:oProcesso:retornaValorGlobal(cFlag, @lError)

/*/{Protheus.doc} limpaUltimaDataSimulada
Limpa a flag com a ultima data do recurso que teve a geração da disponibilidade adicional simulada.
@author Lucas Fagundes
@since 12/09/2024
@version P12
@param cRecurso, Caracter, Código do recurso.
@return Nil
/*/
Method limpaUltimaDataSimulada(cRecurso) Class PCPA152Disponibilidade
	Local cFlag := "ULTIMA_DATA_" + cRecurso + "_SIMULACAO"

	Self:oProcesso:limpaValorGlobal(cFlag)

Return Nil

/*/{Protheus.doc} setFimDataDispAdicional
Seta flag com a ultima data de disponibilidade adicional.
@author Lucas Fagundes
@since 30/01/2024
@version P12
@param 01 dData, Date  , Data que irá setar na flag.
@param 02 lTemp, Lógico, Indica que deve setar em uma flag temporária.
@return Nil
/*/
Method setFimDataDispAdicional(dData, lTemp) Class PCPA152Disponibilidade
	Local cDataGlb := ""
	Local lError   := .F.

	If lTemp
		cDataGlb := Self:oProcesso:retornaValorGlobal("DATA_FIM_DISP_ADICIONAL_TEMP", @lError)

		If lError .Or. dData > SToD(cDataGlb)
			Self:oProcesso:gravaValorGlobal("DATA_FIM_DISP_ADICIONAL_TEMP", DToS(dData))
		EndIf
	Else
		cDataGlb := Self:oProcesso:retornaValorGlobal("DATA_FIM_DISP_ADICIONAL", @lError)

		If lError .Or. dData > SToD(cDataGlb)
			Self:oProcesso:gravaValorGlobal("DATA_FIM_DISP_ADICIONAL", DToS(dData))
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} getFimDataDispAdicional
Retorna a ultima data de disponibilidade adicional.
@author Lucas Fagundes
@since 30/01/2024
@version P12
@param 01 lTemp, Lógico, Indica que deve buscar da flag temporaria.
@param 02 lError, Lógico, Retorna por referência a ocorrência de erros.
@return dData, Date, Data salva na flag global.
/*/
Method getFimDataDispAdicional(lTemp, lError) Class PCPA152Disponibilidade
	Local cData  := ""
	Local cFlag  := "DATA_FIM_DISP_ADICIONAL"
	Local dData  := Nil

	lError := .F.

	If lTemp
		cFlag += "_TEMP"
	EndIf

	cData := Self:oProcesso:retornaValorGlobal(cFlag, @lError)
	If !lError
		dData := SToD(cData)
	EndIf

Return dData

/*/{Protheus.doc} setJsonEfetivados
Seta na global o json que controla os indices efetivados do array de disponibilidade do recurso.
@author Lucas Fagundes
@since 16/09/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá vincular o json.
@param 02 oJson     , Object  , Json que será gravado na global.
@param 03 lAdicional, Logico  , Indica que deve gravar na global temporaria para a disponibilidade adicional.
@return Nil
/*/
Method setJsonEfetivados(cRecurso, oJson, lAdicional) Class PCPA152Disponibilidade
	Local cJson := ""

	If oJson:hasProperty("indices")
		aSort(oJson["indices"],,,{|x, y| x < y})
	Else
		oJson["indices"] := {}
	EndIf

	cJson := oJson:toJson()

	Self:oProcesso:gravaValorGlobal("JSON_INDICES_EFETIVADOS_" + Iif(lAdicional, "ADICIONAL_", "") + cRecurso, cJson)

Return Nil

/*/{Protheus.doc} getJsonEfetivados
Retorna da global o json que controla os indices efetivados do array com a disponibilidade de um recurso.

@author Lucas Fagundes
@since 16/09/2024
@version P12
@param 01 cRecurso  , Caracter, Recurso que irá buscar o json.
@param 02 lAdicional, Logico  , Indica que deve buscar da global temporaria criada para disponibilidade adicional.
@return oJson, Object, Json com os indices da disponibilidade do recurso.
/*/
Method getJsonEfetivados(cRecurso, lAdicional) Class PCPA152Disponibilidade
	Local cJson  := ""
	Local lError := .F.
	Local oJson  := JsonObject():New()

	cJson := Self:oProcesso:retornaValorGlobal("JSON_INDICES_EFETIVADOS_" + Iif(lAdicional, "ADICIONAL_", "") + cRecurso, @lError)
	If !lError
		oJson:fromJson(cJson)
	EndIf

	If lError .And. lAdicional
		oJson := Self:getJsonIndicesDisponibilidadeAlocacao(cRecurso, .F.)
	EndIf

	If !oJson:hasProperty("indices")
		oJson["indices"] := {}
	EndIf

Return oJson

/*/{Protheus.doc} atualizaParametroDataDisponibilidade
Atualiza o parâmetro com a ultima data que gerou disponibilidade para os recursos.
@author Lucas Fagundes
@since 14/01/2025
@version P12
@param lAdicional, Logico, Indica que esta gerando disponibilidade adicional.
@return Nil
/*/
Method atualizaParametroDataDisponibilidade(lAdicional) Class PCPA152Disponibilidade
	Local dData  := Self:oParDisp["dataFinal"]
	Local oParam := JsonObject():New()

	If lAdicional
		dData := Self:getFimDataDispAdicional(.F.)
	EndIf

	oParam["codigo"] := "dataFimDisponibilidade"
	oParam["valor" ] := PCPConvDat(dData, 2)

	Self:oProcesso:atualizaParametros({oParam})

	FreeObj(oParam)
Return Nil

/*/{Protheus.doc} converteArrayProcessamentoParaGravacao
Conver o array de processamento para o array que será gravado no banco de dados.
@author Lucas Fagundes
@since 30/01/2025
@version P12
@param 01 aProc  , Array   , Array utilizado no processamento.
@param 02 cTabela, Caracter, Tabela que será gravada.
@return aGrava, Array, Array que será usado na gravação.
/*/
Method converteArrayProcessamentoParaGravacao(aProc, cTabela) Class PCPA152Disponibilidade
	Local aGrava    := {}
	Local nTamGrava := 0

	If cTabela == "SMR"
		nTamGrava := ARRAY_MR_TAMANHO

		If !Self:lCampoAlt
			nTamGrava -= 2 // Retira as posicoes dos campos MR_ALTDISP e MR_SEQFER
		EndIf

		aGrava := Array(nTamGrava)
		aGrava[ARRAY_MR_FILIAL ] := aProc[ARRAY_MR_FILIAL ]
		aGrava[ARRAY_MR_PROG   ] := aProc[ARRAY_MR_PROG   ]
		aGrava[ARRAY_MR_DISP   ] := aProc[ARRAY_MR_DISP   ]
		aGrava[ARRAY_MR_RECURSO] := aProc[ARRAY_MR_RECURSO]
		aGrava[ARRAY_MR_TIPO   ] := aProc[ARRAY_MR_TIPO   ]
		aGrava[ARRAY_MR_CALEND ] := aProc[ARRAY_MR_CALEND ]
		aGrava[ARRAY_MR_DATDISP] := aProc[ARRAY_MR_DATDISP]
		aGrava[ARRAY_MR_SITUACA] := aProc[ARRAY_MR_SITUACA]
		aGrava[ARRAY_MR_TEMPODI] := aProc[ARRAY_MR_TEMPODI]
		aGrava[ARRAY_MR_TEMPOBL] := aProc[ARRAY_MR_TEMPOBL]
		aGrava[ARRAY_MR_TEMPOPA] := aProc[ARRAY_MR_TEMPOPA]
		aGrava[ARRAY_MR_TEMPOEX] := aProc[ARRAY_MR_TEMPOEX]
		aGrava[ARRAY_MR_TEMPOEF] := aProc[ARRAY_MR_TEMPOEF]
		aGrava[ARRAY_MR_TEMPOTO] := aProc[ARRAY_MR_TEMPOTO]

		If Self:lCampoAlt
			aGrava[ARRAY_MR_ALTDISP] := aProc[ARRAY_MR_ALTDISP]
			aGrava[ARRAY_MR_SEQFER ] := aProc[ARRAY_MR_SEQFER ]
		EndIf

	Else
		aGrava := aProc
	EndIf

Return aGrava

/*/{Protheus.doc} calculaTempoTotal
Calcula o tempo total da disponibilidade.
@author Lucas Fagundes
@since 24/03/2025
@version P12
@param aDisp, Array, Array com a disponibilidade da SMR.
@return Nil
/*/
Method calculaTempoTotal(aDisp) Class PCPA152Disponibilidade

	//Calcula hora do recurso MR_TEMPOTO = MR_TEMPODI + MR_TEMPOEX - ( MR_TEMPOBL +  MR_TEMPOPA + MR_TEMPOEF )
	//Converte os dados para minutos para somar/subtrair
	aDisp[ARRAY_MR_TEMPOTO] := aDisp[ARRAY_MR_TEMPODI]
	aDisp[ARRAY_MR_TEMPOTO] += aDisp[ARRAY_MR_TEMPOEX]
	aDisp[ARRAY_MR_TEMPOTO] -= aDisp[ARRAY_MR_TEMPOBL] + aDisp[ARRAY_MR_TEMPOPA] + aDisp[ARRAY_MR_TEMPOEF]

Return

/*/{Protheus.doc} criaArraySMR
Cria o array de armazenamento das informações que serão gravadas na tabela SMr.
@author Lucas Fagundes
@since 24/03/2025
@version P12
@param 01 cRecurso , Caracter, Código do recurso.
@param 02 lFerram  , Logico  , Indica se é ferramenta.
@param 03 cCalend  , Caracter, Calendário do recurso.
@param 04 cRecIlimi, Caracter, Indicador se o recurso é ilimitado.
@return aDataSMR, Array, Array com formato para gravação na tabela SMR.
/*/
Method criaArraySMR(cRecurso, lFerram, cCalend, cRecIlimi) Class PCPA152Disponibilidade
	Local aDataSMR  := Array(ARRAY_MR_TAMANHO)
	Local cSituacao := Iif(cRecIlimi == "S", RECURSO_ILIMITADO, RECURSO_NAO_ILIMITADO)
	Local cTipo     := MR_TIPO_RECURSO

	If lFerram
		cTipo     := MR_TIPO_FERRAMENTA
		cSituacao := RECURSO_NAO_ILIMITADO
	EndIf

	aDataSMR[ARRAY_MR_FILIAL ] := Self:cFilSMR
	aDataSMR[ARRAY_MR_PROG   ] := Self:oParDisp["cProg"]
	aDataSMR[ARRAY_MR_DISP   ] := ""
	aDataSMR[ARRAY_MR_RECURSO] := cRecurso
	aDataSMR[ARRAY_MR_TIPO   ] := cTipo
	aDataSMR[ARRAY_MR_CALEND ] := cCalend
	aDataSMR[ARRAY_MR_SITUACA] := cSituacao
	aDataSMR[ARRAY_MR_DATDISP] := Nil
	aDataSMR[ARRAY_MR_TEMPODI] := 0
	aDataSMR[ARRAY_MR_TEMPOBL] := 0
	aDataSMR[ARRAY_MR_TEMPOPA] := 0
	aDataSMR[ARRAY_MR_TEMPOEX] := 0
	aDataSMR[ARRAY_MR_TEMPOEF] := 0
	aDataSMR[ARRAY_MR_TEMPOTO] := 0
	aDataSMR[ARRAY_MR_ALTDISP] := NAO_ALTEROU_DISPONIBILIDADE
	aDataSMR[ARRAY_MR_SEQFER ] := ""

Return aDataSMR

/*/{Protheus.doc} setAdicional
Seta a propriedade lAdicional da classe.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@param lAdicional, Logico, Valor que sera atribuido a propriedade lAdicional.
@return Nil
/*/
Method setAdicional(lAdicional) Class PCPA152Disponibilidade

	Self:lAdicional := lAdicional

Return Nil

/*/{Protheus.doc} recursoIlimitado
Verifica se o recurso é ilimitado.
@author Lucas Fagundes
@since 24/06/2025
@version P12
@param cRecurso, Caracter, Código do recurso que será verificado se é ilimitado.
@return lIlimitado, Logico, Indica se o recurso é ilimitado ou não.
/*/
Method recursoIlimitado(cRecurso) Class PCPA152Disponibilidade
	Local lIlimitado := .F.
	Local oInfo      := Self:getInfoRecurso(cRecurso)

	lIlimitado := oInfo:hasProperty("H1_ILIMITA") .And. oInfo["H1_ILIMITA"] == "S"

Return lIlimitado

