#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE IND_LOG_OCORRENCIAS "ocorrencias"

/*/{Protheus.doc} PCPA152Ocorrencia
Classe responsável pelo controle de ocorrências do CRP.

@author Lucas Fagundes
@since 16/10/2023
@version P12
/*/
Class PCPA152Ocorrencia From LongNameClass
	Private Data cFilialSVY as Caracter
	Private Data cProg      as Caracter
	Private Data oProcesso  as Object
	Private Data oOcorrens  as Object
	Private Data lDetalhes  as Logical

	Public Method new(oProcesso) Constructor
	Public Method destroy()

	Public Method adicionaOcorrencia(cTipoLog, cChave, cIdReg, cNumOP, cOperacao, cRecurso, cIdOrig, cCenTrab, aInfoOcorr)
	Public Method gravaOcorrencias()
	Public Method localToGlobal(lIncrement)
	Public Method globalToLocal(cChave)
	Public Method removeOcorrencia(cChave, cOrdem, cTipo, oTipos, cOperacao)
	Public Method removeOcorrenciaGlobal(cChave, cOrdem, cTipo, oTipos, cOperacao)
	Private Method converteArrayProcessamentoParaGravacao(aProc)
	Private Method getIdGravacao()
	Private Method estrutTab()

EndClass

/*/{Protheus.doc} new
Método contrutor da classe PCPA152Ocorrencia.

@author Lucas Fagundes
@since 16/10/2023
@version P12
@param oProcesso, Object, Instancia da classe de processamento do CRP.
@return Self, Object, Nova instancia da classe de ocorrências do CRP.
/*/
Method new(oProcesso) Class PCPA152Ocorrencia

	Self:oProcesso := oProcesso

	Self:cProg       := Self:oProcesso:retornaProgramacao()
	Self:cFilialSVY  := xFilial("SVY")
	Self:oOcorrens   := JsonObject():New()
	Self:lDetalhes   := GetSx3Cache("VY_DETALHE", "X3_TAMANHO") > 0

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe.
@author Lucas Fagundes
@since 18/10/2023
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Ocorrencia

	Self:cFilialSVY := Nil
	Self:cProg      := Nil
	Self:oProcesso  := Nil

	FwFreeObj(Self:oOcorrens)
	Self:oOcorrens := Nil

Return Nil

/*/{Protheus.doc} adicionaOcorrencia
Adiciona um log de ocorrência na lista local (utilizar o método localToGlobal() para enviar as ocorrências para lista global).

@author Marcelo Neumann
@since 12/10/2023
@version P12
@param 01 cTipoLog  , Caracter, Tipo do Log a ser gravado
@param 02 cChave    , Caracter, Chave do log a ser gravado
@param 03 cIdReg    , Caracter, Identificador do registro que está gerando o log.
@param 04 cNumOP    , Caracter, Número da ordem de produção
@param 05 cOperacao , Caracter, Código da operação
@param 06 cRecurso  , Caracter, Código do recurso
@param 07 cIdOrig   , Caracter, Identificador do registro que originou o Log (MF_ID)
@param 08 cCenTrab  , Caracter, Centro de trabalho
@param 09 aInfoOcorr, Array   , Informações complementares para adicionar na mensagem de Log
@return Nil
/*/
Method adicionaOcorrencia(cTipoLog, cChave, cIdReg, cNumOP, cOperacao, cRecurso, cIdOrig, cCenTrab, aInfoOcorr) Class PCPA152Ocorrencia
	Local aDadosSVY  := {}
	Local cDataAnt   := ""
	Local cDataDps   := ""
	Local cDocCompra := ""
	Local cMensagem  := ""
	Local cTipoAux   := ""
	Local oDetalhes  := JsonObject():New()
	Default cCenTrab  := ""
	Default cIdOrig   := ""
	Default cNumOP    := ""
	Default cOperacao := ""
	Default cRecurso  := ""

	Do Case
		Case cTipoLog == LOG_ORDEM_REMOVIDA
			If cIdReg == cIdOrig
				cMensagem := STR0338 // "Ordem de produção removida da alocação pois a operação #1[operação]# não foi alocada totalmente."
			Else
				cMensagem := STR0332 // "Ordem de produção removida da alocação pois a ordem de produção #1[ordemProd]# não foi alocada totalmente."
			EndIf
			cMensagem := i18n(cMensagem, { Trim(aInfoOcorr[1]) })

		Case cTipoLog == LOG_DATA_INICIO_ALTERADA
			cMensagem := STR0333 // "Data de início da ordem de produção será alterada de #1[dataAntiga]# para #2[dataNova]#."
			cMensagem := i18n(cMensagem, { PCPConvDat(DToS(aInfoOcorr[1]), 4), PCPConvDat(DToS(aInfoOcorr[2]), 4) })
			oDetalhes["numeroOP"    ] := RTrim(cNumOP)
			oDetalhes["dataOriginal"] := DToS(aInfoOcorr[1])
			oDetalhes["dataAlterada"] := DToS(aInfoOcorr[2])

		Case cTipoLog == LOG_DATA_ENTREGA_ALTERADA
			cMensagem := STR0334 // "Data de entrega da ordem de produção será alterada de #1[dataAntiga]# para #2[dataNova]#."
			cMensagem := i18n(cMensagem, { PCPConvDat(DToS(aInfoOcorr[1]), 4), PCPConvDat(DToS(aInfoOcorr[2]), 4) })
			oDetalhes["numeroOP"    ] := RTrim(cNumOP)
			oDetalhes["dataOriginal"] := DToS(aInfoOcorr[1])
			oDetalhes["dataAlterada"] := DToS(aInfoOcorr[2])

		Case cTipoLog == LOG_USOU_DISPONIBILIDADE_ADICIONAL
			cMensagem := STR0382 // "Ordem foi alocada em data posterior a data final."

		Case cTipoLog == LOG_ALOCADA_PELA_DATA_PROG
			cMensagem := STR0336 //"Ordem foi alocada pela data da programação. Não houve capacidade para alocar pela data de início/entrega da ordem."

		Case cTipoLog == LOG_ORDEM_NAO_ALOCADA
			cMensagem := STR0337 // "Ordem não alocada pois a ordem de produção #1[ordemProd]# não foi alocada totalmente."
			cMensagem := i18n(cMensagem, { Trim(aInfoOcorr[1]) })

		Case cTipoLog == LOG_OPERACAO_NAO_ALOCADA
			cMensagem :=  STR0335 // "Operação não foi alocada devido a falta de disponibilidade do recurso. Tempo total da operação: #1[tempoOperacao]#. Tempo faltante: #2[tempoFaltante]#. Última data verificada: #3[ultimaData]#."
			cMensagem := i18n(cMensagem, { __Min2Hrs(aInfoOcorr[ARRAY_OPS_PARC_TEMPO_OPER    ], .T.),;
			                               __Min2Hrs(aInfoOcorr[ARRAY_OPS_PARC_TEMPO_FALTANTE], .T.),;
			                               DToC(aInfoOcorr[ARRAY_OPS_PARC_TEMPO_ULTIMA_DATA  ]     )})

		Case cTipoLog == LOG_DESEFETIVA_ORDEM
			cMensagem := STR0415 // "Ordem será desefetivada pois não houve alocação."

		Case cTipoLog == LOG_ALOCOU_ALTERNATIVO
			cMensagem := i18n(STR0578, {aInfoOcorr[1], aInfoOcorr[2]}) // "Operação foi alocada em recurso alternativo: Recurso principal: #1[recursoPrincipal]#. Recurso alternativo: #2[recursoAlternativo]#."

		Case cTipoLog == LOG_ALOCOU_COM_SOBREPOSICAO
			cMensagem := i18n(STR0597, {cOperacao, cNumOP, aInfoOcorr[1]}) // "Operação #1[operacao]# da ordem de produção #2[ordemProducao]# alocou em sobreposição a operação anterior. Operação anterior: #3[operacaoAnterior]#."

		Case cTipoLog == LOG_ENTREGOU_JUNTO
			cMensagem := i18n(STR0598, {cOperacao, cNumOP, aInfoOcorr[1]}) // "Operação #1[operacao]# da ordem de produção #2[ordemProducao]# foi realocada para entregar junto da operação #3[operacaoAnterior]#, pois finalizava antes da operação anterior."

		Case cTipoLog == LOG_SEM_SOBREPOSICAO
			If aInfoOcorr[1] == PRIMEIRA_OPERACAO
				cMensagem := STR0615 // "Sobreposição não aplicada. Esta é a primeira operação e não é considerado sobreposição entre ordens de produção."
				cTipoAux  := PRIMEIRA_OPERACAO

			ElseIf aInfoOcorr[1] == QUEBRA_OPERACAO
				cMensagem := i18n(STR0616, {STR0460}) // 'Sobreposição não é aplicada ao ativar o parâmetro "#1[nomeParametro]#".' "Permite quebra das operações"
				cTipoAux  := QUEBRA_OPERACAO

			ElseIf aInfoOcorr[1] == MESMO_RECURSO
				cMensagem := STR0617 // "Sobreposição não pode ser aplicada entre operações que utilizam o mesmo recurso."
				cTipoAux  := MESMO_RECURSO

			ElseIf aInfoOcorr[1] == TEMPO_SOBREPOSICAO
				cMensagem := i18n(STR0618, {aInfoOcorr[2], aInfoOcorr[3], aInfoOcorr[4]}) // "Sobreposição não aplicada. O tempo de sobreposição é maior que o tempo da operação anterior. Sobreposição #1[tempoSobreposicao]#. Tempo da operação anterior: #2[tempoAnterior]#. Tempo de remoção: #3[tempoRemocao]#."
				cTipoAux  := TEMPO_SOBREPOSICAO

			ElseIf aInfoOcorr[1] == SEM_DISPONIBILIDADE
				cMensagem := STR0619 // "Sobreposição não aplicada. Não houve disponibilidade para alocar a operação."
				cTipoAux  := SEM_DISPONIBILIDADE

			EndIf

		Case cTipoLog == LOG_COMPRA_ALTERADA
			If aInfoOcorr[2] == "SC1"
				cDocCompra := i18n(STR0650, {RTrim(aInfoOcorr[1])}) // "da solicitação de compra #1[numero]#"
				cDataAnt := i18n(STR0653, {DToC(aInfoOcorr[3]), DToC(aInfoOcorr[4])}) // "Início: #1[inicio]#, Entrega: #2[entrega]#"
				cDataDps := i18n(STR0653, {DToC(aInfoOcorr[5]), DToC(aInfoOcorr[6])}) // "Início: #1[inicio]#, Entrega: #2[entrega]#"
				oDetalhes["numeroDocumento"    ] := RTrim(aInfoOcorr[1])
				oDetalhes["dataOriginalInicial"] := DToS(aInfoOcorr[3])
				oDetalhes["dataOriginalEntrega"] := DToS(aInfoOcorr[4])
				oDetalhes["dataAlteradaInicial"] := DToS(aInfoOcorr[5])
				oDetalhes["dataAlteradaEntrega"] := DToS(aInfoOcorr[6])
				oDetalhes["origem"             ] := aInfoOcorr[2]

			ElseIf aInfoOcorr[2] == "SC7"
				cDocCompra := i18n(STR0651, {RTrim(aInfoOcorr[1])}) // "da autorização de entrega #1[numero]#"
				cDataAnt := i18n(STR0653, {DToC(aInfoOcorr[3]), DToC(aInfoOcorr[4])}) // "Início: #1[inicio]#, Entrega: #2[entrega]#"
				cDataDps := i18n(STR0653, {DToC(aInfoOcorr[5]), DToC(aInfoOcorr[6])}) // "Início: #1[inicio]#, Entrega: #2[entrega]#"
				oDetalhes["numeroDocumento"    ] := RTrim(aInfoOcorr[1])
				oDetalhes["dataOriginalInicial"] := DToS(aInfoOcorr[3])
				oDetalhes["dataOriginalEntrega"] := DToS(aInfoOcorr[4])
				oDetalhes["dataAlteradaInicial"] := DToS(aInfoOcorr[5])
				oDetalhes["dataAlteradaEntrega"] := DToS(aInfoOcorr[6])
				oDetalhes["origem"             ] := aInfoOcorr[2]

			ElseIf aInfoOcorr[2] == "SC8"
				cDocCompra := i18n(STR0652, {RTrim(aInfoOcorr[1])}) // "de entrega da cotação #1[numero]#"
				cDataAnt   := DToC(aInfoOcorr[4])
				cDataDps   := DToC(aInfoOcorr[6])
				oDetalhes["numeroDocumento"    ] := RTrim(aInfoOcorr[1])
				oDetalhes["dataOriginalEntrega"] := DToS(aInfoOcorr[4])
				oDetalhes["dataAlteradaEntrega"] := DToS(aInfoOcorr[6])
				oDetalhes["origem"             ] := aInfoOcorr[2]

			EndIf

			cMensagem := i18n(STR0648, {cDocCompra, cDataAnt, cDataDps}) // "Data #1[docCompra]# foi alterada de: #2[dataAnterior]#; Para: #3[novaData]#."

		Case cTipoLog == LOG_COMPRA_ANTERIOR_DATA_BASE
			If aInfoOcorr[2] == "SC1"
				cDocCompra := i18n(STR0650, {RTrim(aInfoOcorr[1])}) // "da solicitação de compra #1[numero]#"

			ElseIf aInfoOcorr[2] == "SC7"
				cDocCompra := i18n(STR0651, {RTrim(aInfoOcorr[1])}) // "da autorização de entrega #1[numero]#"

			EndIf

			cMensagem := i18n(STR0649, {cDocCompra}) // "Data de início #1[documento]# foi alterada para antes da data base do sistema."

		Case cTipoLog == LOG_OPERACAO_NAO_VALIDADE
			cMensagem := i18n(STR0674, {cOperacao, RTrim(cNumOP), aInfoOcorr[3], aInfoOcorr[4], aInfoOcorr[1], aInfoOcorr[2]}) // "Operação #1[operacao]# da ordem de produção #2[ordemProducao]# foi alocada em data fora do prazo de validade. Validade da operação: #3[valiIni]# até #4[valiFim]#. Alocação da operação: #5[alocIni]# até #6[alocFim]#."

		Case cTipoLog == LOG_OPERACAO_FORA_PREVISTO
			If aInfoOcorr[1]
				cMensagem := i18n(STR0678, {DToC(aInfoOcorr[2]), __Min2Hrs(aInfoOcorr[3], .T.), DToC(aInfoOcorr[4]), __Min2Hrs(aInfoOcorr[5], .T.)}) // "Operação foi entregue fora da data prevista devido a capacidade do recurso/ferramental. Entrega prevista: #1[dataPrevista]# - #2[horaPrevista]#. Data de entrega: #3[dataEntrega]# - #4[horaEntrega]#."
			Else
				cMensagem := i18n(STR0679, {DToC(aInfoOcorr[2]), __Min2Hrs(aInfoOcorr[3], .T.), DToC(aInfoOcorr[4]), __Min2Hrs(aInfoOcorr[5], .T.)}) // "Operação iniciou fora da data prevista devido a capacidade do recurso/ferramental. Inicio prevista: #1[dataPrevista]# - #2[horaPrevista]#. Data de inicio: #3[dataEntrega]# - #4[horaEntrega]#."
			EndIf

	EndCase

	aDadosSVY := Array(ARRAY_VY_TAMANHO_PROC)
	aDadosSVY[ARRAY_VY_FILIAL    ] := Self:cFilialSVY
	aDadosSVY[ARRAY_VY_PROG      ] := Self:cProg
	aDadosSVY[ARRAY_VY_ID        ] := ""
	aDadosSVY[ARRAY_VY_TIPO      ] := cTipoLog
	aDadosSVY[ARRAY_VY_OP        ] := cNumOP
	aDadosSVY[ARRAY_VY_OPER      ] := cOperacao
	aDadosSVY[ARRAY_VY_RECURSO   ] := cRecurso
	aDadosSVY[ARRAY_VY_IDORIG    ] := cIdOrig
	aDadosSVY[ARRAY_VY_OCORREN   ] := cMensagem
	aDadosSVY[ARRAY_VY_CTRAB     ] := cCenTrab
	aDadosSVY[ARRAY_VY_IDREG     ] := cIdReg
	aDadosSVY[ARRAY_VY_DETALHE   ] := oDetalhes:toJson()
	aDadosSVY[ARRAY_PROC_TIPO_AUX] := cTipoAux

	If !Self:oOcorrens:hasProperty(cChave)
		Self:oOcorrens[cChave] := {}
	EndIf

	aAdd(Self:oOcorrens[cChave], aDadosSVY)

	FreeObj(oDetalhes)
Return Nil

/*/{Protheus.doc} estrutTab
Carrega o array com a estrutura das tabelas para a gravação dos dados.
@author Lucas Fagundes
@since 21/03/2023
@version P12
@return aEstrut, Array   , Array com a estrutura da tabela
/*/
Method estrutTab() Class PCPA152Ocorrencia
	Local aEstrut := {}

	aAdd(aEstrut, {"VY_FILIAL" })
	aAdd(aEstrut, {"VY_PROG"   })
	aAdd(aEstrut, {"VY_ID"     })
	aAdd(aEstrut, {"VY_TIPO"   })
	aAdd(aEstrut, {"VY_OP"     })
	aAdd(aEstrut, {"VY_OPER"   })
	aAdd(aEstrut, {"VY_RECURSO"})
	aAdd(aEstrut, {"VY_IDORIG" })
	aAdd(aEstrut, {"VY_OCORREN"})
	aAdd(aEstrut, {"VY_CTRAB"  })
	aAdd(aEstrut, {"VY_IDREG"  })
	If Self:lDetalhes
		aAdd(aEstrut, {"VY_DETALHE"})
	EndIf

Return aEstrut

/*/{Protheus.doc} gravaOcorrencias
Realiza a gravação dos logs na tabela.
@author Lucas Fagundes
@since 17/10/2023
@version P12
@return lSucesso, Logico, Indica se conseguiu gravar com sucesso os logs.
/*/
Method gravaOcorrencias() Class PCPA152Ocorrencia
	Local aAux      := {}
	Local aDados    := {}
	Local lSucesso  := .T.
	Local nId       := 0
	Local nIndChave := 1
	Local nIndDados := 1
	Local nTamVYID  := GetSX3Cache("VY_ID", "X3_TAMANHO")
	Local nTempoIni := MicroSeconds()
	Local nTotChave := 0
	Local nTotDados := 0
	Local oBulk     := FwBulk():New()

	oBulk:setTable(RetSqlName("SVY"))
	oBulk:setFields(Self:estrutTab())

	aDados    := Self:oProcesso:retornaListaGlobal(LISTA_DADOS_SVY)
	nTotChave := Len(aDados)
	nId       := Self:getIdGravacao()

	Self:oProcesso:gravaValorGlobal("GRAVACAO_SVY", "PROC")

	BEGIN TRANSACTION

	While nIndChave <= nTotChave .And. lSucesso
		aAux      := aDados[nIndChave][2]
		nTotDados := Len(aAux)
		nIndDados := 1

		While nIndDados <= nTotDados .And. lSucesso
			nId++

			aAux[nIndDados][ARRAY_VY_ID] := StrZero(nId, nTamVYID)

			Self:oProcesso:oLogs:gravaLog(IND_LOG_OCORRENCIAS, ;
			                              {"Ordem: " + aAux[nIndDados][ARRAY_VY_OP] + ;
			                               ", Recurso: " + aAux[nIndDados][ARRAY_VY_RECURSO] + ;
			                               ", Operacao: " + aAux[nIndDados][ARRAY_VY_OPER] + ;
			                               " Ocorrencia " + aAux[nIndDados][ARRAY_VY_TIPO] + " " + aAux[nIndDados][ARRAY_VY_OCORREN]},;
			                              aAux[nIndDados][ARRAY_VY_OP], aAux[nIndDados][ARRAY_VY_OPER], aAux[nIndDados][ARRAY_VY_RECURSO])

			lSucesso := oBulk:addData(Self:converteArrayProcessamentoParaGravacao(aAux[nIndDados]))
			aSize(aAux[nIndDados], 0)

			If lSucesso
				nIndDados++
				lSucesso := Self:oProcesso:permiteProsseguir()
			EndIf
		End

		aSize(aAux, 0)
		aSize(aDados[nIndChave], 0)

		Self:oProcesso:gravaValorGlobal("REGISTROS_GRAVADOS", 1, .T., .T.)

		If lSucesso
			nIndChave++
			lSucesso := Self:oProcesso:permiteProsseguir()
		EndIf
	End

	If lSucesso
		lSucesso := oBulk:close()
	EndIf

	If !lSucesso
		DisarmTransaction()

		If !Self:oProcesso:processamentoCancelado()
			Self:oProcesso:gravaErro(CHAR_ETAPAS_GRAVACAO, i18n(STR0182, {"SVY"}), oBulk:getError()) // "Erro na gravação da tabela #1[tabela]#."
		EndIf
	EndIf

	END TRANSACTION

	Self:oProcesso:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo gravacao da tabela SVY: " + cValToChar(MicroSeconds() - nTempoIni)})

	If lSucesso
		Self:oProcesso:gravaValorGlobal("GRAVACAO_SVY", "END")
	EndIf

	oBulk:destroy()
	aSize(aDados, 0)

Return lSucesso

/*/{Protheus.doc} localToGlobal
Realiza a gravação dos dados locais para memória global.
@author Lucas Fagundes
@since 26/10/2023
@version P12
@param 01 lIncrement, Lógico, identifica se os dados na global devem ser incrementados ou substituídos.
@return Nil
/*/
Method localToGlobal(lIncrement) Class PCPA152Ocorrencia
	Local aNames := Self:oOcorrens:getNames()
	Local nIndex := 0
	Local nTotal := Len(aNames)

	Default lIncrement := .T.

	For nIndex := 1 To nTotal
		Self:oProcesso:adicionaListaGlobal(LISTA_DADOS_SVY, aNames[nIndex], Self:oOcorrens[aNames[nIndex]], lIncrement, 2)

		Self:oOcorrens:delName(aNames[nIndex])
	Next

Return Nil

/*/{Protheus.doc} globalToLocal
Recupera os dados da memória global e carrega na memória local.

@author lucas.franca
@since 06/06/2024
@version P12
@param 01 cChave, Caracter, Chave da árvore para busca das ocorrências.
@return Nil
/*/
Method globalToLocal(cChave) Class PCPA152Ocorrencia

	Self:oOcorrens[cChave] := Self:oProcesso:retornaListaGlobal(LISTA_DADOS_SVY, cChave)

Return Nil

/*/{Protheus.doc} removeOcorrencia
Remove as ocorrências de uma chave.
@author Lucas Fagundes
@since 07/11/2023
@version P12
@param 01 cChave   , Caracter, Chave que foi gerada a ocorrência.
@param 02 cOrdem   , Caracter, Filtro de ordem.
@param 03 cTipo    , Caracter, Tipo de ocorrência que será removida.
@param 04 oTipos   , Object  , JSON com os tipos que serão removidos (usado para excluir vários tipos de uma única vez)
@param 05 cOperacao, Caracter, Filtro de operação.
@return Nil
/*/
Method removeOcorrencia(cChave, cOrdem, cTipo, oTipos, cOperacao) Class PCPA152Ocorrencia
	Local aOcorrens  := Nil
	Local cTipoAux   := ""
	Local lRemVarios := oTipos != Nil
	Local nPos       := 0
	Local nRemovidos := 0
	Local nTotOcor   := 0

	If !Self:oOcorrens:hasProperty(cChave)
		Return Nil
	EndIf

	aOcorrens := Self:oOcorrens[cChave]
	nTotOcor  := Len(aOcorrens)

	For nPos := nTotOcor To 1 Step -1
		cTipoAux := aOcorrens[nPos][ARRAY_VY_TIPO] + aOcorrens[nPos][ARRAY_PROC_TIPO_AUX]

		If (cOrdem    == Nil .Or. cOrdem    == aOcorrens[nPos][ARRAY_VY_OP  ]) .And.;
		   (cOperacao == Nil .Or. cOperacao == aOcorrens[nPos][ARRAY_VY_OPER]) .And.;
		   ((lRemVarios  .And. oTipos:hasProperty(cTipoAux)) .Or.;
		    (!lRemVarios .And. cTipoAux == cTipo))
			nRemovidos++
			aDel(aOcorrens, nPos)
		EndIf
	Next

	If nRemovidos > 0
		aSize(aOcorrens, (nTotOcor - nRemovidos))
	EndIf

Return Nil

/*/{Protheus.doc} PCPA152OCO
API que envia as informações para tela de ocorrências do CRP.
@type  WSCLASS
@author Lucas Fagundes
@since 10/11/2023
@version P12
/*/
WSRESTFUL PCPA152OCO DESCRIPTION "PCPA152OCO" FORMAT APPLICATION_JSON
	WSDATA programacao    AS STRING  OPTIONAL
	WSDATA ordemProducao  AS STRING  OPTIONAL
	WSDATA produto        AS STRING  OPTIONAL
	WSDATA tipo           AS STRING  OPTIONAL
	WSDATA recurso        AS STRING  OPTIONAL
	WSDATA centroTrabalho AS STRING  OPTIONAL
	WSDATA export         AS BOOLEAN OPTIONAL
	WSDATA page           AS INTEGER OPTIONAL
	WSDATA pageSize       AS INTEGER OPTIONAL

	WSMETHOD GET OCORRENCIAS;
		DESCRIPTION STR0342; // "Retorna as ocorrências de uma programação."
		WSSYNTAX "/api/pcp/v1/pcpa152oco/{programacao}";
		PATH "/api/pcp/v1/pcpa152oco/{programacao}";
		TTALK "v1"

	WSMETHOD GET ORDENS;
		DESCRIPTION STR0343; // "Retorna as ordens de produção com ocorrências."
		WSSYNTAX "/api/pcp/v1/pcpa152oco/{programacao}/ordens";
		PATH "/api/pcp/v1/pcpa152oco/{programacao}/ordens";
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET OCORRENCIAS /api/pcp/v1/pcpa152oco/{programacao}
Retorna as ocorrências de uma programação.
@type  WSMETHOD
@author Lucas Fagundes
@since 27/10/2023
@version P12
@param 01 programacao   , Caracter, Código da programação.
@param 02 page          , Numerico, Página que será carregada.
@param 03 pageSize      , Numerico, Quantidade de registros por página.
@param 04 ordemProducao , Caracter, Filtro de ordem de produção.
@param 05 produto       , Caracter, Filtro de produtos.
@param 06 tipo          , Caracter, Filtro de tipos.
@param 07 recurso       , Caracter, Filtro de recursos.
@param 08 centroTrabalho, Caracter, Filtro de centros de trabalho.
@param 09 export        , Logico  , Indica que está buscando os dados para exportação (não realiza paginação).
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET OCORRENCIAS PATHPARAM programacao QUERYPARAM page, pageSize, ordemProducao, produto, tipo, recurso, centroTrabalho, export WSSERVICE PCPA152OCO
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152OCO"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOcorren(Self:programacao, Self:page, Self:pageSize, Self:ordemProducao, Self:produto, Self:tipo, Self:recurso, Self:centroTrabalho, Self:export)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOcorren
Busca as ocorrências de uma programação para retornar na API.
@type  Static Function
@author Lucas Fagundes
@since 27/10/2023
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 nPage    , Numerico, Página que será carregada.
@param 03 nPageSize, Numerico, Quantidade de registro que será retornado.
@param 04 cOrdem   , Caracter, Filtro de ordem de produção.
@param 05 cProd    , Caracter, Filtro de produto.
@param 06 cTipo    , Caracter, Filtro de tipo.
@param 07 cRecurso , Caracter, Filtro de recurso.
@param 08 cCodCT   , Caracter, Filtro de centro de trabalho.
@param 09 lExport  , Logico  , Indica que está buscando os dados para exportação (não realiza a paginação).
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getOcorren(cProg, nPage, nPageSize, cOrdem, cProd, cTipo, cRecurso, cCodCT, lExport)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	Default lExport := .F.

	cQuery := " SELECT SB1.B1_COD, "
	cQuery +=        " SB1.B1_DESC, "
	cQuery +=        " SVY.VY_ID, "
	cQuery +=        " SVY.VY_TIPO, "
	cQuery +=        " SVY.VY_OP, "
	cQuery +=        " SVY.VY_OPER, "
	cQuery +=        " COALESCE(SHY.HY_DESCRI,SG2.G2_DESCRI) AS G2_DESCRI, "
	cQuery +=        " SVY.VY_RECURSO, "
	cQuery +=        " SVY.VY_OCORREN, "
	cQuery +=        " SVY.VY_CTRAB, "
	cQuery +=        " SH1.H1_DESCRI, "
	cQuery +=        " SHB.HB_NOME "
	cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=  " INNER JOIN " + RetSqlName("SMF") + " SMF "
	cQuery +=     " ON " + FwJoinFilial("SMF", "SVY", "SMF", "SVY", .T.)
	cQuery +=    " AND SMF.MF_PROG    = '" + cProg + "' "
	cQuery +=    " AND SMF.MF_ID      = SVY.VY_IDREG "
	cQuery +=    " AND SMF.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON " + FwJoinFilial("SC2", "SMF", "SC2", "SMF", .T.)
	cQuery +=    " AND " + PCPQrySC2("SC2", "SMF.MF_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON " + FwJoinFilial("SB1", "SC2", "SB1", "SC2", .T.)
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SH1") + " SH1 "
	cQuery +=     " ON " + FwJoinFilial("SH1", "SVY", "SH1", "SVY", .T.)
	cQuery +=    " AND SH1.H1_CODIGO  = SVY.VY_RECURSO "
	cQuery +=    " AND SH1.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHB") + " SHB "
	cQuery +=     " ON " + FwJoinFilial("SHB", "SVY", "SHB", "SVY", .T.)
	cQuery +=    " AND SHB.HB_COD     = SVY.VY_CTRAB "
	cQuery +=    " AND SHB.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SG2") + " SG2 "
	cQuery +=     " ON " + FwJoinFilial("SG2", "SMF", "SG2", "SMF", .T.)
	cQuery +=    " AND SG2.G2_CODIGO  = SMF.MF_ROTEIRO "
	cQuery +=    " AND SG2.G2_PRODUTO = SC2.C2_PRODUTO "
	cQuery +=    " AND SG2.G2_OPERAC  = SMF.MF_OPER "
	cQuery +=    " AND SG2.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("SHY") + " SHY "
	cQuery +=     " ON " + FwJoinFilial("SHY", "SMF", "SHY", "SMF", .T.)
	cQuery +=    " AND SHY.HY_ROTEIRO = SMF.MF_ROTEIRO "
	cQuery +=    " AND SHY.HY_OPERAC  = SMF.MF_OPER "
	cQuery +=    " AND SHY.HY_OP      = SMF.MF_OP "
	cQuery +=    " AND SHY.HY_TEMPAD <> 0 "
	cQuery +=    " AND SHY.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SVY.VY_FILIAL  = '" + xFilial("SVY") + "' "
	cQuery +=    " AND SVY.VY_PROG    = '" + cProg          + "' "
	cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "

	If !Empty(cOrdem)
		cQuery += " AND SVY.VY_OP IN ('" + StrTran(cOrdem, ",", "','") + "') "
	EndIf

	If !Empty(cProd)
		cQuery += " AND SB1.B1_COD IN ('" + StrTran(cProd, ",", "','") + "') "
	EndIf

	If !Empty(cTipo)
		cQuery += " AND SVY.VY_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(cRecurso)
		cQuery += " AND SVY.VY_RECURSO IN ('" + StrTran(cRecurso, ",", "','") + "') "
	EndIf

	If cCodCT != Nil
		If cCodCT == ""
			cCodCT := " "
		EndIf

		cQuery += " AND SVY.VY_CTRAB IN ('" + StrTran(cCodCT, ",", "','") + "') "
	EndIf

	cQuery += "  ORDER BY SVY.VY_OP, SVY.VY_OPER, SVY.VY_ID "

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1 .And. !lExport
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["produto"       ] := retCodDesc((cAlias)->B1_COD, (cAlias)->B1_DESC)
		oReturn["items"][nCont]["tipo"          ] := Trim((cAlias)->VY_TIPO)
		oReturn["items"][nCont]["ordemProducao" ] := (cAlias)->VY_OP
		oReturn["items"][nCont]["operacao"      ] := retCodDesc((cAlias)->VY_OPER, (cAlias)->G2_DESCRI)
		oReturn["items"][nCont]["recurso"       ] := retCodDesc((cAlias)->VY_RECURSO, (cAlias)->H1_DESCRI)
		oReturn["items"][nCont]["centroTrabalho"] := retCodDesc((cAlias)->VY_CTRAB, (cAlias)->HB_NOME)
		oReturn["items"][nCont]["ocorrencia"    ] := RTrim((cAlias)->VY_OCORREN)

		(cAlias)->(dbSkip())
		If nCont >= nPageSize .And. !lExport
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} retCodDesc
Monta o retorno composto por código + descrição.
Somente adiciona a descrição caso não seja vazia.

@type  Static Function
@author lucas.franca
@since 14/11/2023
@version P12
@param 01 cCodigo, Caracter, Código para retorno
@param 02 cDescri, Caracter, Descrição para retorno
@return cValue, Caracter, Valor de código concatenado com descrição (caso exista)
/*/
Static Function retCodDesc(cCodigo, cDescri)
	Local cValue := RTrim(cCodigo)

	If !Empty(cDescri) .And. !Empty(cCodigo)
		cValue += " - " + RTrim(cDescri)
	EndIf

Return cValue

/*/{Protheus.doc} GET ORDENS /api/pcp/v1/pcpa152oco/{programacao}/ordens
Retorna as ordens de produção com ocorrências.
@type  WSMETHOD
@author Lucas Fagundes
@since 30/10/2023
@version P12
@param 01 programacao, Caracter, Código da programação.
@param 02 page       , Numerico, Página que será carregada.
@param 03 pageSize   , Numerico, Quantidade de registros por página.
@param 04 ordemProducao , Caracter, Filtro de ordem de produção.
@param 05 produto       , Caracter, Filtro de produtos.
@param 06 tipo          , Caracter, Filtro de tipos.
@param 07 recurso       , Caracter, Filtro de recursos.
@param 08 centroTrabalho, Caracter, Filtro de centros de trabalho.
@return lReturn, Lógico, Indica se a requisição foi processada com sucesso
/*/
WSMETHOD GET ORDENS PATHPARAM programacao QUERYPARAM page, pageSize, ordemProducao, produto, tipo, recurso, centroTrabalho WSSERVICE PCPA152OCO
	Local aReturn   := {}
	Local bErrorBlk := ErrorBlock({|oError| PCPRestErr(oError, "PCPA152OCO"), Break(oError)})

	Self:SetContentType("application/json")

	BEGIN SEQUENCE
		aReturn := getOpsOco(Self:programacao, Self:page, Self:pageSize, Self:ordemProducao, Self:produto, Self:tipo, Self:recurso, Self:centroTrabalho)
	END SEQUENCE

	lReturn := PCPVldRErr(Self, aReturn, @bErrorBlk)

Return lReturn

/*/{Protheus.doc} getOpsOco
Busca e retorna as ordens com ocorrência em uma programação.
@type  Static Function
@author Lucas Fagundes
@since 30/10/2023
@version P12
@param 01 cProg    , Caracter, Código da programação.
@param 02 nPage    , Numerico, Página que será carregada.
@param 03 nPageSize, Numerico, Quantidade de registros por página.
@param 04 cOrdem   , Caracter, Filtro de ordem de produção.
@param 05 cProd    , Caracter, Filtro de produto.
@param 06 cTipo    , Caracter, Filtro de tipo.
@param 07 cRecurso , Caracter, Filtro de recurso.
@param 08 cCodCT   , Caracter, Filtro de centro de trabalho.
@return aReturn, Array, Array com as informações de retorno da API.
/*/
Static Function getOpsOco(cProg, nPage, nPageSize, cOrdem, cProd, cTipo, cRecurso, cCodCT)
	Local aReturn := Array(3)
	Local cAlias  := GetNextAlias()
	Local cQuery  := ""
	Local nCont   := 0
	Local nStart  := 0
	Local oReturn := JsonObject():New()

	cQuery := " SELECT DISTINCT SVY.VY_OP, SB1.B1_COD, SB1.B1_DESC "
	cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=  " INNER JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery +=     " ON " + FwJoinFilial("SC2", "SVY", "SC2", "SVY", .T.)
	cQuery +=    " AND " + PCPQrySC2("SC2", "SVY.VY_OP")
	cQuery +=    " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=     " ON " + FwJoinFilial("SB1", "SC2", "SB1", "SC2", .T.)
	cQuery +=    " AND SB1.B1_COD     = SC2.C2_PRODUTO "
	cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SVY.VY_FILIAL  = '" + xFilial("SVY") + "' "
	cQuery +=    " AND SVY.VY_PROG    = '" + cProg          + "' "
	cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "

	If !Empty(cOrdem)
		cQuery += " AND SVY.VY_OP IN ('" + StrTran(cOrdem, ",", "','") + "') "
	EndIf

	If !Empty(cProd)
		cQuery += " AND SB1.B1_COD IN ('" + StrTran(cProd, ",", "','") + "') "
	EndIf

	If !Empty(cTipo)
		cQuery += " AND SVY.VY_TIPO IN ('" + StrTran(cTipo, ",", "','") + "') "
	EndIf

	If !Empty(cRecurso)
		cQuery += " AND SVY.VY_RECURSO IN ('" + StrTran(cRecurso, ",", "','") + "') "
	EndIf

	If !Empty(cCodCT)
		cQuery += " AND SVY.VY_CTRAB IN ('" + StrTran(cCodCT, ",", "','") + "') "
	EndIf

	If "MSSQL" $ TcGetDb()
		cQuery := StrTran(cQuery, "||", "+")
	EndIf

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAlias)->(dbSkip(nStart))
		EndIf
	EndIf

	oReturn["items"] := {}

	While (cAlias)->(!EoF())
		nCont++

		aAdd(oReturn["items"], JsonObject():New())

		oReturn["items"][nCont]["ordemProducao"] := (cAlias)->VY_OP
		oReturn["items"][nCont]["produto"      ] := retCodDesc((cAlias)->B1_COD, (cAlias)->B1_DESC)

		(cAlias)->(dbSkip())
		If nCont >= nPageSize
			Exit
		EndIf
	End

	oReturn["hasNext"] := (cAlias)->(!EoF())
	(cAlias)->(dbCloseArea())

	aReturn[1] := .T.
	aReturn[2] := 200
	aReturn[3] := oReturn:toJson()

	FwFreeObj(oReturn)
Return aReturn

/*/{Protheus.doc} removeOcorrenciaGlobal
Remove ocorrências salvas na memória global.
@author Lucas Fagundes
@since 25/10/2024
@version P12
@param 01 cChave   , Caracter, Chave que foi gerada a ocorrência.
@param 02 cOrdem   , Caracter, Filtro de ordem.
@param 03 cTipo    , Caracter, Tipo de ocorrência que será removida.
@param 04 oTipos   , Object  , JSON com os tipos que serão removidos (usado para excluir vários tipos de uma única vez)
@param 05 cOperacao, Caracter, Filtro de operação.
@return Nil
/*/
Method removeOcorrenciaGlobal(cChave, cOrdem, cTipo, oTipos, cOperacao) Class PCPA152Ocorrencia
	Local aBkpLocal := {}
	Local lFezBkp   := .F.

	If Self:oOcorrens:hasProperty(cChave)
		aBkpLocal := aClone(Self:oOcorrens[cChave])
		lFezBkp   := .T.
	EndIf

	Self:globalToLocal(cChave)

	Self:removeOcorrencia(cChave, cOrdem, cTipo, oTipos, cOperacao)

	Self:oProcesso:adicionaListaGlobal(LISTA_DADOS_SVY, cChave, Self:oOcorrens[cChave], .F.)
	Self:oOcorrens:delName(cChave)

	If lFezBkp
		Self:oOcorrens[cChave] := aBkpLocal
		aBkpLocal := {}
	EndIf

Return Nil

/*/{Protheus.doc} converteArrayProcessamentoParaGravacao
Cria array com os dados que serão gravados na tabela SVY.
@author Lucas Fagundes
@since 18/11/2024
@version P12
@param aProc, Array, Array com as informações das ocorrências em tempo de processamento.
@return aGrava, Array, Array com as informações que serão gravadas de cada ocorrência.
/*/
Method converteArrayProcessamentoParaGravacao(aProc) Class PCPA152Ocorrencia
	Local aGrava    := {}
	Local nTamGrava := ARRAY_VY_TAMANHO_GRAVA

	If !Self:lDetalhes
		nTamGrava--
	EndIf

	aGrava := Array(nTamGrava)
	aGrava[ARRAY_VY_FILIAL ] := aProc[ARRAY_VY_FILIAL ]
	aGrava[ARRAY_VY_PROG   ] := aProc[ARRAY_VY_PROG   ]
	aGrava[ARRAY_VY_ID     ] := aProc[ARRAY_VY_ID     ]
	aGrava[ARRAY_VY_TIPO   ] := aProc[ARRAY_VY_TIPO   ]
	aGrava[ARRAY_VY_OP     ] := aProc[ARRAY_VY_OP     ]
	aGrava[ARRAY_VY_OPER   ] := aProc[ARRAY_VY_OPER   ]
	aGrava[ARRAY_VY_RECURSO] := aProc[ARRAY_VY_RECURSO]
	aGrava[ARRAY_VY_IDORIG ] := aProc[ARRAY_VY_IDORIG ]
	aGrava[ARRAY_VY_OCORREN] := aProc[ARRAY_VY_OCORREN]
	aGrava[ARRAY_VY_CTRAB  ] := aProc[ARRAY_VY_CTRAB  ]
	aGrava[ARRAY_VY_IDREG  ] := aProc[ARRAY_VY_IDREG  ]
	If Self:lDetalhes
		aGrava[ARRAY_VY_DETALHE] := aProc[ARRAY_VY_DETALHE]
	EndIf

Return aGrava

/*/{Protheus.doc} getIdGravacao
Retorna o ultimo id utilizado na gravação das ocorrências.

@author Lucas Fagundes
@since 17/12/2024
@version P12
@return nId, Numerico, Ultimo id utilizado na gravação das ocorrências.
/*/
Method getIdGravacao() Class PCPA152Ocorrencia
	Local cAlias := GetNextAlias()
	Local cQuery := ""
	Local nId    := 0

	cQuery := " SELECT MAX(SVY.VY_ID) maxId "
	cQuery +=   " FROM " + RetSqlName("SVY") + " SVY "
	cQuery +=  " WHERE SVY.VY_FILIAL  = '" + xFilial("SVY") + "' "
	cQuery +=    " AND SVY.VY_PROG    = '" + Self:cProg     + "' "
	cQuery +=    " AND SVY.D_E_L_E_T_ = ' ' "

	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .F., .F.)

	If (cAlias)->(!EoF())
		nId := Val((cAlias)->maxId)
	EndIf
	(cAlias)->(dbCloseArea())

Return nId
