#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA152.CH"
#INCLUDE "PCPA152DEFS.CH"

#DEFINE EH_ALTERNATIVA     "1"
#DEFINE NAO_EH_ALTERNATIVA "0"

#DEFINE AUXILIAR_CARGA_FERRAMENTA 1
#DEFINE AUXILIAR_CARGA_QUANTIDADE 2
#DEFINE AUXILIAR_CARGA_TAMANHO    2

#DEFINE ARRAY_FERRAMENTA_CODIGO     1
#DEFINE ARRAY_FERRAMENTA_QUANTIDADE 2
#DEFINE ARRAY_FERRAMENTA_UTILIZACAO 3
#DEFINE ARRAY_FERRAMENTA_TAMANHO    3

#DEFINE UTILIZACAO_TIPO_BLOQUEIO "B"
#DEFINE UTILIZACAO_TIPO_EFETIVA  "E"
#DEFINE UTILIZACAO_TIPO_ALOCACAO "A"

/*/{Protheus.doc} PCPA152Ferramenta
Classe responsavel pela controle das ferramentas do CRP.
@author Lucas Fagundes
@since 18/03/2025
@version P12
/*/
Class PCPA152Ferramenta From PCPA152Process
	Private Data aPerPends   as Array
	Private Data oCarga      as Object
	Private Data cFilHZK     as Caracter
	Private Data cBkpFerra   as Caracter
	Private Data nTamId      as Number
	Private Data nTamSeq     as Number
	Private Data nTamMRDISP  as Number
	Private Data nTamHZKSEQ  as Number
	Private Data oQryBloq    as Object
	Private Data oQryEfet    as Object
	Private Data oUtilizacao as Object
	Private Data oCargaAux   as Object
	Private Data lUsaFerram  as Logical
	Private Data oSeqData    as Object

	Public Method new(cProg) Constructor
	Public Method destroy()

	// Métodos externos - Geral
	Public Method getJsonUtilizacao()
	Public Method gravaDados()
	Public Method setJsonUtilizacao(cJson)

	// Métodos externos - Alocação/Utilização
	Public Method descartaReservaFerramentas()
	Public Method efetivaFerramentas(oSeqSVM)
	Public Method removePeriodosEfetivados(cIdOper)
	Public Method removeUtilizacaoLocal(cIdOper)
	Public Method reservaFerramentas(aFerramentas, aPeriodos)
	Public Method verificaDisponibilidadeFerramentas(aFerramentas, dData, nHoraIni, nHoraFim, lDecresce)

	// Métodos externos - Geração adicional
	Public Method efetivaUtilizacaoAdicional()
	Public Method excluiUtilizacaoAdicional()
	Public Method geraIndisponibilidadesAdicionais()
	Public Method geraUtilizacaoAdicional(aFerramentas, dDataIni, dDataFim)

	// Métodos externos - Backup
	Public Method criaBackupFerramentas()
	Public Method descartaBackupFerramentas()
	Public Method restauraBackupFerramentas()

	// Métodos externos - Carga
	Public Method carregaFerramentasOperacao(cIdOper)
	Public Method finalizaCargaFerramentas(lRecarga)
	Public Method getFerramentasOperacao(oInfo)

	// Métodos internos
	Private Method addSeqData(cData, cSeq)
	Private Method ajustaArrayPeriodos(aPeriodos)
	Private Method cargaUtilizacao(cFerram)
	Private Method carregaIndisponibilidadesFerramenta(cFerramenta, dDataIni, dDataFim, lAdicional)
	Private Method carregaUtilizacaoGlobal(cFerramenta)
	Private Method converteArrayProcessamentoParaGravacao(aProc, cTabela)
	Private Method criaJsonPeriodo(dData, nHoraIni, nHoraFim)
	Private Method criaPeriodoUtilizacao(cFerramenta, dData, nHoraIni, nHoraFim, cTipo, cIdOper, cSeqFer)
	Private Method getBloqueiosFerramenta(cFerramenta, dDataDe, dDataAte)
	Private Method getCamposGravacao(cTabela)
	Private Method getHorasEfetivadasFerramenta(cFerramenta, dDataIni, dDataFim)
	Private Method getUltimaDataFerramenta(cFerramenta, lAdicional)
	Private Method inserePeriodoUtilizacao(cFerramenta, cSeqFer, dData, nInicio, nFim, cTipo, cIdOper)
	Private Method limpaUltimaDataAdicionalFerramenta(cFerramenta)
	Private Method ordenaPeriodos(aPeriodos)
	Private Method removeOperacaoPeriodos(cFerramenta, cSeqFer, cData, cIdOper)
	Private Method setUltimaDataFerramenta(cFerramenta, dData, lAdicional)
	Private Method validaPeriodosFerramenta(cFerramenta, cSeqFer, aPeriodos)
	Public Method gravaTabela(cTabela, aDados)

EndClass

/*/{Protheus.doc} new
Método construtor da classe
@author Lucas Fagundes
@since 18/03/2025
@version P12
@param cProg, Caracter, Codigo da programação.
@return Self, Object  , Nova instancia da classe.
/*/
Method new(cProg) Class PCPA152Ferramenta

	_Super:new(cProg)

	Self:aPerPends   := {}
	Self:cBkpFerra   := ""
	Self:nTamId      := GetSx3Cache("HZJ_ID"    , "X3_TAMANHO")
	Self:nTamSeq     := GetSx3Cache("HZJ_SEQUSO", "X3_TAMANHO")
	Self:nTamMRDISP  := GetSx3Cache("MR_DISP"   , "X3_TAMANHO")
	Self:nTamHZKSEQ  := GetSx3Cache("HZK_SEQ"   , "X3_TAMANHO")
	Self:oUtilizacao := JsonObject():New()
	Self:oCargaAux   := JsonObject():New()
	Self:lUsaFerram  := _Super:retornaParametro("utilizaFerramentas") .And. GetSx3Cache("MF_TPALOFE", "X3_TAMANHO") > 0
	Self:cFilHZK     := xFilial("HZK")

Return Self

/*/{Protheus.doc} destroy
Método destrutor da classe.
@author Lucas Fagundes
@since 18/03/2025
@version P12
@return Nil
/*/
Method destroy() Class PCPA152Ferramenta

	_Super:destroy()

	If Self:oQryBloq != Nil
		Self:oQryBloq:destroy()
		Self:oQryBloq := Nil
	EndIf

	If Self:oQryEfet != Nil
		Self:oQryEfet:destroy()
		Self:oQryEfet := Nil
	EndIf

	Self:oUtilizacao := Nil
	Self:oCargaAux   := Nil

Return Nil

/*/{Protheus.doc} getFerramentasOperacao
Carrega as ferramentas de uma operação.
@author Lucas Fagundes
@since 18/03/2025
@version P12
@param oInfo, Object, Json com as informações da operação.
@return aFerram, Array, Array com as ferramentas da operação.
/*/
Method getFerramentasOperacao(oInfo) Class PCPA152Ferramenta
	Local aAuxCarga := {}
	Local aConjunto := {}
	Local aDadosHZJ := {}
	Local aFerram   := {}
	Local cAlias    := ""
	Local cConjunto := ""
	Local cFerram   := ""
	Local cId       := ""
	Local cIdOper   := oInfo["idOperacao"]
	Local cQuery    := ""
	Local cSeqUso   := ""
	Local cTemp     := ""
	Local nId       := 0
	Local nQuant    := 0
	Local nSeqUso   := -1

	If !Self:lUsaFerram
		Return aFerram
	EndIf

	If Self:oCarga == Nil
		cTemp := _Super:retornaValorGlobal("TEMP_OPERACOES")

		cQuery := " SELECT COALESCE(HZI.HZI_FERRAM, SH4.H4_CODIGO) ferramenta, "
		cQuery +=        " COALESCE(SH4b.H4_QUANT, SH4.H4_QUANT) quantidade, "
		cQuery +=        " '" + NAO_EH_ALTERNATIVA + "' alternativa, "
		cQuery +=        " TEMP.FERRAMENTA conjunto "
		cQuery +=   " FROM " + cTemp + " TEMP "
		cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
		cQuery +=     " ON SH4.H4_FILIAL  = ? "
		cQuery +=    " AND SH4.H4_CODIGO  = TEMP.FERRAMENTA "
		cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("HZI") + " HZI "
		cQuery +=     " ON HZI.HZI_FILIAL = ? "
		cQuery +=    " AND HZI.HZI_CONJUN = SH4.H4_CODIGO "
		cQuery +=    " AND SH4.H4_CONJUNT = 'T' "
		cQuery +=    " AND HZI.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SH4") + " SH4b "
		cQuery +=     " ON SH4b.H4_FILIAL  = ? "
		cQuery +=    " AND SH4b.H4_CODIGO  = HZI.HZI_FERRAM "
		cQuery +=    " AND SH4b.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE TEMP.C2_OP     = ? "
		cQuery +=    " AND TEMP.OPERACAO  = ? "
		cQuery +=    " AND COALESCE(SH4b.H4_QUANT, SH4.H4_QUANT) > 0 "
		cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
		cQuery +=  " UNION ALL "
		cQuery += " SELECT COALESCE(SH4b.H4_CODIGO, SH4.H4_CODIGO) ferramenta, "
		cQuery +=        " COALESCE(SH4b.H4_QUANT, SH4.H4_QUANT) quantidade, "
		cQuery +=        " '" + EH_ALTERNATIVA + "' alternativa, "
		cQuery +=        " SH3.H3_FERRAM conjunto "
		cQuery +=   " FROM " + cTemp + " TEMP "
		cQuery +=  " INNER JOIN " + RetSqlName("SH3") + " SH3 "
		cQuery +=     " ON SH3.H3_FILIAL   = ? "
		cQuery +=    " AND SH3.H3_PRODUTO  = TEMP.C2_PRODUTO "
		cQuery +=    " AND SH3.H3_CODIGO   = TEMP.ROTEIRO    "
		cQuery +=    " AND SH3.H3_OPERAC   = TEMP.OPERACAO   "
		cQuery +=    " AND SH3.D_E_L_E_T_  = ' ' "
		cQuery +=  " INNER JOIN " + RetSqlName("SH4") + " SH4 "
		cQuery +=     " ON SH4.H4_FILIAL  = ? "
		cQuery +=    " AND SH4.H4_CODIGO  = SH3.H3_FERRAM "
		cQuery +=    " AND SH4.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("HZI") + " HZI "
		cQuery +=     " ON HZI.HZI_FILIAL = ? "
		cQuery +=    " AND HZI.HZI_CONJUN = SH4.H4_CODIGO "
		cQuery +=    " AND SH4.H4_CONJUNT = 'T' "
		cQuery +=    " AND HZI.D_E_L_E_T_ = ' ' "
		cQuery +=   " LEFT JOIN " + RetSqlName("SH4") + " SH4b "
		cQuery +=     " ON SH4b.H4_FILIAL  = ? "
		cQuery +=    " AND SH4b.H4_CODIGO  = HZI.HZI_FERRAM "
		cQuery +=    " AND SH4b.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE TEMP.C2_OP      = ? "
		cQuery +=    " AND TEMP.OPERACAO   = ? "

		Self:oCarga := FwExecStatement():New(cQuery)
		Self:oCarga:setString(1, xFilial("SH4"))
		Self:oCarga:setString(2, xFilial("HZI"))
		Self:oCarga:setString(3, xFilial("SH4"))
		Self:oCarga:setString(6, xFilial("SH3"))
		Self:oCarga:setString(7, xFilial("SH4"))
		Self:oCarga:setString(8, xFilial("HZI"))
		Self:oCarga:setString(9, xFilial("SH4"))
	EndIf

	Self:oCarga:setString( 4, oInfo["ordemProducao"])
	Self:oCarga:setString( 5, oInfo["operacao"     ])
	Self:oCarga:setString(10, oInfo["ordemProducao"])
	Self:oCarga:setString(11, oInfo["operacao"     ])

	cAlias := Self:oCarga:openAlias()

	While (cAlias)->(!EoF())
		cFerram := (cAlias)->ferramenta
		nQuant  := (cAlias)->quantidade
		cAlt    := (cAlias)->alternativa

		If (cAlias)->conjunto != cConjunto
			cConjunto := (cAlias)->conjunto

			nSeqUso++
			cSeqUso := StrZero(nSeqUso, Self:nTamSeq)

			aConjunto := Array(ARRAY_FERRAM_TAMANHO)
			aConjunto[ARRAY_FERRAM_FERRAMENTAS] := {}
			aConjunto[ARRAY_FERRAM_SEQUENCIA  ] := cSeqUso

			aAdd(aFerram, aConjunto)
		EndIf

		_Super:gravaValorGlobal("HZJ_ID_SEQUENCE", @nId, .F., .T.)
		cId     := StrZero(nId, Self:nTamId)

		aDadosHZJ := Array(ARRAY_HZJ_TAMANHO)
		aDadosHZJ[ARRAY_HZJ_FILIAL] := xFilial("HZJ")
		aDadosHZJ[ARRAY_HZJ_PROG  ] := Self:cProg
		aDadosHZJ[ARRAY_HZJ_ID    ] := cId
		aDadosHZJ[ARRAY_HZJ_OPER  ] := cIdOper
		aDadosHZJ[ARRAY_HZJ_FERRAM] := cFerram
		aDadosHZJ[ARRAY_HZJ_QUANT ] := nQuant
		aDadosHZJ[ARRAY_HZJ_ALTERN] := cAlt
		aDadosHZJ[ARRAY_HZJ_SEQUSO] := cSeqUso

		_Super:adicionaListaGlobal(LISTA_DADOS_HZJ, cIdOper, aDadosHZJ, .T.)

		aAuxCarga := Array(AUXILIAR_CARGA_TAMANHO)
		aAuxCarga[AUXILIAR_CARGA_FERRAMENTA] := cFerram
		aAuxCarga[AUXILIAR_CARGA_QUANTIDADE] := nQuant

		_Super:adicionaListaGlobal(LISTA_FERRAMENTAS, cFerram, aAuxCarga, .F.)

		aAdd(aConjunto[ARRAY_FERRAM_FERRAMENTAS], aDadosHZJ)

		(cAlias)->(dbSkip())

		aSize(aAuxCarga, 0)
		aDadosHZJ := {}
	End
	(cAlias)->(dbCloseArea())

	aConjunto := {}
Return aFerram

/*/{Protheus.doc} gravaDados
Realiza a gravação das ferramentas na tabela.
@author Lucas Fagundes
@since 19/03/2025
@version P12
@return Nil
/*/
Method gravaDados() Class PCPA152Ferramenta
	Local lNovaProg := .F.
	Local oInicio   := _Super:getStatusInicioProgramacao()

	lNovaProg := !oInicio["reprocessando"] .And. !oInicio["continuando"]

	If lNovaProg
		_Super:delegar("P152GrvFer", Self:cProg, "HZJ")
	Else
		nRegsHZJ := Len(_Super:retornaListaGlobal(LISTA_DADOS_HZJ))

		_Super:gravaValorGlobal("REGISTROS_GRAVADOS", nRegsHZJ, .T., .T.)
		_Super:gravaValorGlobal("GRAVACAO_HZJ", "END")
	EndIf
	_Super:delegar("P152GrvFer", Self:cProg, "HZK")

	FreeObj(oInicio)
Return Nil

/*/{Protheus.doc} P152GrvFer
Realiza a gravação das ferramentas em uma nova thread.
@type  Function
@author Lucas Fagundes
@since 19/03/2025
@version P12
@param cProg  , Caracter, Codigo da programação.
@param cTabela, Caracter, Tabela que sera gravada.
@return Nil
/*/
Function P152GrvFer(cProg, cTabela)
	Local aDados    := {}
	Local cLista    := ""
	Local oFerramen := Nil
	Local oProcesso := Nil

	If PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_BASE, @oProcesso) .And. PCPA152Process():processamentoFactory(cProg, FACTORY_OPC_FERRAMENTA, @oFerramen)
		If cTabela == "HZJ"
			cLista := LISTA_DADOS_HZJ
		ElseIf cTabela == "HZK"
			cLista := LISTA_DADOS_HZK
		EndIf
		aDados := oProcesso:retornaListaGlobal(cLista)

		oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "PROC")

		If oFerramen:gravaTabela(cTabela, aDados)
			oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "END")
		Else
			oProcesso:gravaValorGlobal("GRAVACAO_" + cTabela, "ERRO")
		EndIf
	EndIf

Return Nil

/*/{Protheus.doc} gravaTabela
Realiza a gravação dos dados em uma tabela.
@author Lucas Fagundes
@since 19/03/2025
@version P12
@param 01 cTabela, Caracter, Alias da tabela que irá gravar os dados.
@param 02 aDados , Array   , Dados que irá gravar na tabela.
@return lSucesso, Logico, Retorna se a gravação foi realizada com sucesso./*/
Method gravaTabela(cTabela, aDados) Class PCPA152Ferramenta
	Local aAux      := {}
	Local cDetErro  := ""
	Local cErro     := ""
	Local lSucesso  := .T.
	Local nIndChave := 1
	Local nIndDados := 1
	Local nTempoIni := MicroSeconds()
	Local nTotChave := Len(aDados)
	Local nTotDados := 0
	Local oBulk     := FwBulk():New()

	oBulk:setTable(RetSqlName(cTabela))
	oBulk:setFields(Self:getCamposGravacao(cTabela))

	BEGIN TRANSACTION

	While nIndChave <= nTotChave .And. lSucesso
		aAux      := aDados[nIndChave][2]
		nTotDados := Len(aAux)
		nIndDados := 1

		While nIndDados <= nTotDados .And. lSucesso
			lSucesso := oBulk:addData(Self:converteArrayProcessamentoParaGravacao(aAux[nIndDados], cTabela))
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
		cErro    := i18n(STR0182, {cTabela}) //"Erro na gravação da tabela #1[tabela]#."
		cDetErro := oBulk:getError()

		DisarmTransaction()

		_Super:gravaErro(CHAR_ETAPAS_GRAVACAO, cErro, cDetErro)
	EndIf

	END TRANSACTION

	Self:oLogs:gravaLog(CHAR_ETAPAS_GRAVACAO, {"Tempo gravacao da tabela " + cTabela + ": " + cValToChar(MicroSeconds() - nTempoIni)})

	oBulk:destroy()
	aSize(aDados, 0)
Return lSucesso

/*/{Protheus.doc} getCamposGravacao
Retorna os campos que serão gravados em uma tabela.
@author Lucas Fagundes
@since 19/03/2025
@version P12
@param cTabela, Caracter, Alias da tabela.
@return aCampos, Array, Campos que serão gravados na tabela.
/*/
Method getCamposGravacao(cTabela) Class PCPA152Ferramenta
	Local aCampos := {}

	If cTabela == "HZJ"
		aAdd(aCampos, {"HZJ_FILIAL"})
		aAdd(aCampos, {"HZJ_PROG"  })
		aAdd(aCampos, {"HZJ_ID"    })
		aAdd(aCampos, {"HZJ_OPER"  })
		aAdd(aCampos, {"HZJ_FERRAM"})
		aAdd(aCampos, {"HZJ_QUANT" })
		aAdd(aCampos, {"HZJ_ALTERN"})
		aAdd(aCampos, {"HZJ_SEQUSO"})

	ElseIf cTabela == "HZK"
		aAdd(aCampos, {"HZK_FILIAL"})
		aAdd(aCampos, {"HZK_PROG"  })
		aAdd(aCampos, {"HZK_ID"    })
		aAdd(aCampos, {"HZK_SEQ"   })
		aAdd(aCampos, {"HZK_DATA"  })
		aAdd(aCampos, {"HZK_INICIO"})
		aAdd(aCampos, {"HZK_FIM"   })
		aAdd(aCampos, {"HZK_TEMPO" })
		aAdd(aCampos, {"HZK_IDOPER"})
		aAdd(aCampos, {"HZK_SEQALO"})
		aAdd(aCampos, {"HZK_SEQFER"})

	EndIf

Return aCampos

/*/{Protheus.doc} finalizaCargaFerramentas
Finaliza a carga de ferramentas criando as globais que serão usadas no processo de alocação.
@author Lucas Fagundes
@since 21/03/2025
@version P12
@param lRecarga, Logico, Indica que esta continuando/reprocessando a programação.
@return Nil
/*/
Method finalizaCargaFerramentas(lRecarga) Class PCPA152Ferramenta
	Local aAux        := {}
	Local aFerramenta := {}
	Local cFerram     := ""
	Local dDataFim    := Nil
	Local dDataIni    := Nil
	Local nIndex      := 0
	Local nQuant      := 0
	Local nTotal      := 0
	Local oUtilizacao := Nil

	If !Self:lUsaFerram
		Return Nil
	EndIf

	If lRecarga
		aFerrams := Self:oCargaAux:getNames()
		nTotal   := Len(aFerrams)
		dDataFim := SToD(PCPConvDat((_Super:retornaParametro("dataFimDisponibilidade")), 6))

		Self:oCarga:destroy()
		Self:oCarga := Nil
	Else
		aAux     := _Super:retornaListaGlobal(LISTA_FERRAMENTAS)
		nTotal   := Len(aAux)
		dDataIni := SToD(PCPConvDat((_Super:retornaParametro("dataInicial")), 6))
		dDataFim := SToD(PCPConvDat((_Super:retornaParametro("dataFinal"  )), 6))

		_Super:limpaListaGlobal(LISTA_FERRAMENTAS)
	EndIf

	For nIndex := 1 To nTotal
		If lRecarga
			cFerram := aFerrams[nIndex]
			nQuant  := Self:oCargaAux[cFerram]
			Self:oCargaAux:delName(cFerram)
		Else
			cFerram := aAux[nIndex][1]
			nQuant  := aAux[nIndex][2][AUXILIAR_CARGA_QUANTIDADE]
			aSize(aAux[nIndex], 0)
		EndIf

		Self:oUtilizacao[cFerram] := JsonObject():New()
		Self:oUtilizacao[cFerram]["quantidade"] := nQuant

		If lRecarga
			oUtilizacao := Self:cargaUtilizacao(cFerram)
		Else
			oUtilizacao := Self:carregaIndisponibilidadesFerramenta(cFerram, dDataIni, dDataFim, .F.)
		EndIf
		Self:setUltimaDataFerramenta(cFerram, dDataFim, .F.)

		aFerramenta := Array(ARRAY_FERRAMENTA_TAMANHO)
		aFerramenta[ARRAY_FERRAMENTA_CODIGO    ] := cFerram
		aFerramenta[ARRAY_FERRAMENTA_QUANTIDADE] := nQuant
		aFerramenta[ARRAY_FERRAMENTA_UTILIZACAO] := oUtilizacao:toJson()

		_Super:adicionaListaGlobal(LISTA_FERRAMENTAS, cFerram, aFerramenta, .F.)

		aSize(aFerramenta, 0)
	Next

	Self:oUtilizacao := JsonObject():New()

	FreeObj(oUtilizacao)
	aSize(aAux, 0)
Return Nil

/*/{Protheus.doc} carregaIndisponibilidadesFerramenta
Carrega as indisponibilidade da ferramenta (bloqueios e horas efetivadas).
@author Lucas Fagundes
@since 21/03/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta.
@param dDataIni   , Date    , Data inicial do período que ira realizar a busca.
@param dDataFim   , Date    , Data final do período que ira realizar a busca.
@param lAdicional , Logico  , Indica se é para carregar as indisponibilidades adicionais.
@return oUtilizacao, Object, Json com a utilização da ferramenta com as horas indisponiveis.
/*/
Method carregaIndisponibilidadesFerramenta(cFerramenta, dDataIni, dDataFim, lAdicional) Class PCPA152Ferramenta
	Local aBloqueio   := {}
	Local aCalAux     := {}
	Local aData       := {}
	Local aDatas      := {}
	Local aDetalhes   := {}
	Local aEfetivas   := {}
	Local aTotais     := {}
	Local cData       := ""
	Local cSeqDisp    := ""
	Local cSeqFerram  := ""
	Local cTipo       := ""
	Local dData       := Nil
	Local lTemBloq    := .F.
	Local lTemEfet    := .F.
	Local nHoraFim    := 0
	Local nHoraIni    := 0
	Local nIndex      := 0
	Local nIndSeq     := 0
	Local nSequen     := 0
	Local nTotal      := 0
	Local nTotSeq     := 0
	Local oBloqueios  := Nil
	Local oDisp       := Nil
	Local oEfetivada  := Nil
	Local oUtilizacao := Self:oUtilizacao[cFerramenta]

	PCPA152Process():processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
	oDisp:setAdicional(lAdicional)

	Self:oSeqData := JsonObject():New()
	oBloqueios    := Self:getBloqueiosFerramenta(cFerramenta, dDataIni, dDataFim)
	oEfetivada    := Self:getHorasEfetivadasFerramenta(cFerramenta, dDataIni, dDataFim)

	If Len(oBloqueios:getNames()) > 0 .Or. Len(oEfetivada:getNames()) > 0
		aData := oDisp:criaArraySMR(cFerramenta, .T., "", "")

		For dData := dDataIni To dDataFim
			cData := DToS(dData)

			If Self:oSeqData:hasProperty(cData)
				aCalAux := {{}, 0}
				nTotSeq := Len(Self:oSeqData[cData]["sequencias"])

				For nIndSeq := 1 To nTotSeq
					cSeqFerram := Self:oSeqData[cData]["sequencias"][nIndSeq]
					lTemBloq   := oBloqueios:hasProperty(cData) .And. oBloqueios[cData]:hasProperty(cSeqFerram)
					lTemEfet   := oEfetivada:hasProperty(cData) .And. oEfetivada[cData]:hasProperty(cSeqFerram)

					If lTemBloq .Or. lTemEfet
						aBloqueio := {}
						aEfetivas := {}
						nSequen   := oDisp:buscaSequenciaSMR()
						cSeqDisp  := StrZero(nSequen, Self:nTamMRDISP)

						aData[ARRAY_MR_DISP   ] := cSeqDisp
						aData[ARRAY_MR_DATDISP] := dData
						aData[ARRAY_MR_SEQFER ] := cSeqFerram

						If lTemBloq
							aBloqueio  := {oBloqueios[cData][cSeqFerram]["periodos"], oBloqueios[cData][cSeqFerram]["tempo"]}
							aCalAux[1] := oBloqueios[cData][cSeqFerram]["periodos"]
						EndIf

						If lTemEfet
							aEfetivas := oEfetivada[cData][cSeqFerram]
						EndIf

						aTotais := oDisp:geraDetalheDisponibilidade(dData, aCalAux, {}, aBloqueio, aEfetivas, cSeqDisp, cFerramenta, .T.)

						aData[ARRAY_MR_TEMPODI] := aTotais[5]
						aData[ARRAY_MR_TEMPOBL] := aTotais[3]
						aData[ARRAY_MR_TEMPOPA] := aTotais[1]
						aData[ARRAY_MR_TEMPOEX] := aTotais[2]
						aData[ARRAY_MR_TEMPOEF] := aTotais[4]

						oDisp:calculaTempoTotal(@aData)

						aAdd(aDatas, aClone(aData))

						aDetalhes := oDisp:getDispSMK(cSeqDisp, lAdicional)
						nTotal    := Len(aDetalhes)

						For nIndex := 1 To nTotal
							nHoraIni := __Hrs2Min(aDetalhes[nIndex][ARRAY_MK_HRINI])
							nHoraFim := __Hrs2Min(aDetalhes[nIndex][ARRAY_MK_HRFIM])
							cTipo    := UTILIZACAO_TIPO_EFETIVA

							If aDetalhes[nIndex][ARRAY_MK_BLOQUE] == HORA_BLOQUEADA
								cTipo := UTILIZACAO_TIPO_BLOQUEIO
							EndIf

							Self:inserePeriodoUtilizacao(cFerramenta, cSeqFerram, dData, nHoraIni, nHoraFim, cTipo)

							aSize(aDetalhes[nIndex], 0)
						Next

						aSize(aTotais,   0)
						aSize(aEfetivas, 0)
						aSize(aBloqueio, 0)
						aSize(aDetalhes, 0)
					EndIf

					Self:oSeqData[cData]:delName(cSeqFerram)
				Next

				Self:oSeqData:delName(cData)
			EndIf
		Next

		If Len(aDatas) > 0
			oDisp:setDispSMR(cFerramenta, aDatas, lAdicional, .T.)
		EndIf
	EndIf

	oDisp:setAdicional(.F.)
	oDisp := Nil

	aSize(aData, 0)
	aSize(aDatas, 0)
	aSize(aCalAux, 0)
	FreeObj(oBloqueios)
	FreeObj(oEfetivada)
Return oUtilizacao

/*/{Protheus.doc} getBloqueiosFerramenta
Retorna os bloqueios da ferramenta.
@author Lucas Fagundes
@since 21/03/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta.
@param dDataDe    , Date    , Data inicial do período que ira realizar a busca.
@param dDataAte   , Date    , Data final do período que ira realizar a busca.
@return oBloqs, Object, Json com os bloqueios da ferramenta.
/*/
Method getBloqueiosFerramenta(cFerramenta, dDataDe, dDataAte) Class PCPA152Ferramenta
	Local cAlias      := ""
	Local cData       := ""
	Local cQuery      := ""
	Local cSeq        := ""
	Local dData       := Nil
	Local dDataFim    := Nil
	Local nIndSeq     := 0
	Local nPOSHORAFIM := 2
	Local nPOSTEMPO   := 3
	Local nQuant      := 0
	Local nTamPer     := 0
	Local nTempo      := 0
	Local oBloqs      := JsonObject():New()

	If Self:oQryBloq == Nil
		cQuery := " SELECT SH9.H9_QUANT, "
		cQuery +=        " SH9.H9_HRINI, "
		cQuery +=        " SH9.H9_HRFIM, "
		cQuery +=        " SH9.H9_DTINI, "
		cQuery +=        " SH9.H9_DTFIM "
		cQuery +=   " FROM " + RetSqlName("SH9") + " SH9 "
		cQuery +=  " WHERE SH9.H9_FILIAL  =  ? "
		cQuery +=    " AND SH9.H9_TIPO    =  ? "
		cQuery +=    " AND SH9.H9_FERRAM  =  ? "
		cQuery +=    " AND SH9.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND (SH9.H9_DTINI BETWEEN ? AND ? "
		cQuery +=     " OR  SH9.H9_DTFIM BETWEEN ? AND ?) "
		cQuery +=  " ORDER BY SH9.H9_DTINI, SH9.H9_HRINI "

		Self:oQryBloq := FwExecStatement():New(cQuery)
		Self:oQryBloq:setFields({;
			"H9_QUANT",;
			"H9_HRINI",;
			"H9_HRFIM",;
			{"H9_DTINI", "D", 8, 0},;
			{"H9_DTFIM", "D", 8, 0} ;
		})

		Self:oQryBloq:setString(1, xFilial("SH9")) // H9_FILIAL
		Self:oQryBloq:setString(2, "F") // H9_TIPO
	EndIf

	Self:oQryBloq:setString(3, cFerramenta) // H9_FERRAM
	Self:oQryBloq:setDate(4, dDataDe) // H9_DTINI
	Self:oQryBloq:setDate(5, dDataAte) // H9_DTINI
	Self:oQryBloq:setDate(6, dDataDe) // H9_DTFIM
	Self:oQryBloq:setDate(7, dDataAte) // H9_DTFIM

	cAlias := Self:oQryBloq:openAlias()
	Self:oQryBloq:doTcSetField(cAlias)

	While (cAlias)->(!EoF())
		dData    := Max(dDataDe , (cAlias)->H9_DTINI)
		dDataFim := Min(dDataAte, (cAlias)->H9_DTFIM)
		nQuant   := (cAlias)->H9_QUANT

		While dData <= dDataFim
			cData  := DtoS(dData)

			cHrIni := "00:00"
			cHrFim := "24:00"

			If dData == (cAlias)->(H9_DTINI)
				cHrIni := (cAlias)->(H9_HRINI)
			EndIf
			If dData == (cAlias)->(H9_DTFIM)
				cHrFim := (cAlias)->(H9_HRFIM)
			EndIf

			nTempo := __Hrs2Min(cHrFim) - __Hrs2Min(cHrIni)

			If !oBloqs:hasProperty(cData)
				oBloqs[cData] := JsonObject():new()
			EndIf

			For nIndSeq := 1 To nQuant
				cSeq := cValToChar(nIndSeq)

				If !oBloqs[cData]:hasProperty(cSeq)
					oBloqs[cData][cSeq] := JsonObject():New()
					oBloqs[cData][cSeq]["periodos"] := {}
					oBloqs[cData][cSeq]["tempo"   ] := 0
				EndIf
				nTamPer := Len(oBloqs[cData][cSeq]["periodos"])

				oBloqs[cData][cSeq]["tempo"] += nTempo

				If nTamPer > 0 .And. oBloqs[cData][cSeq]["periodos"][nTamPer][nPOSHORAFIM] == cHrIni
					oBloqs[cData][cSeq]["periodos"][nTamPer][nPOSHORAFIM] := cHrFim
					oBloqs[cData][cSeq]["periodos"][nTamPer][nPOSTEMPO  ] += nTempo
				Else
					aAdd(oBloqs[cData][cSeq]["periodos"], {cHrIni, cHrFim, nTempo})
				EndIf

				Self:addSeqData(cData, cSeq)
			Next

			dData++
		End

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oBloqs

/*/{Protheus.doc} reservaFerramentas
Reserva a alocação de um conjunto de ferramentas.
@author Lucas Fagundes
@since 28/03/2025
@version P12
@param aFerramentas, Array, Ferramentas que serão alocadas.
@param aPeriodos   , Array, Array coms os periodos que devem ser reservados.
@return Nil
/*/
Method reservaFerramentas(aFerramentas, aPeriodos) Class PCPA152Ferramenta
	Local aPeriodo    := {}
	Local aInvalidos  := {}
	Local cFerramenta := ""
	Local cIdOper     := ""
	Local cSeqFer     := ""
	Local nIndFer     := 0
	Local nIndSeq     := 0
	Local nTotFer     := Len(aFerramentas)
	Local nTotSeq     := 0
	Local aAlocaveis  := {}
	Local nIndAloc    := 0
	Local nTotAloc    := 0
	Local dData       := Nil
	Local nHoraIni    := 0
	Local nHoraFim    := 0

	For nIndFer := 1 To nTotFer
		cFerramenta := aFerramentas[nIndFer][ARRAY_HZJ_FERRAM]
		cIdFerram   := aFerramentas[nIndFer][ARRAY_HZJ_ID    ]
		cIdOper     := aFerramentas[nIndFer][ARRAY_HZJ_OPER  ]
		aInvalidos  := aClone(aPeriodos)

		Self:carregaUtilizacaoGlobal(cFerramenta)
		nTotSeq := Self:oUtilizacao[cFerramenta]["quantidade"]

		For nIndSeq := 1 To nTotSeq
			cSeqFer := cValToChar(nIndSeq)

			aAlocaveis := Self:validaPeriodosFerramenta(cFerramenta, cSeqFer, @aInvalidos)

			//Se alguma data estiver inválida, tenta com a próxima sequência da ferramenta
			If !Empty(aInvalidos) .And. nTotSeq > nIndSeq
				aSize(aAlocaveis, 0)
				aInvalidos := aClone(aPeriodos)
				Loop
			EndIf

			nTotAloc := Len(aAlocaveis)

			For nIndAloc := 1 To nTotAloc
				dData    := aAlocaveis[nIndAloc]["data"      ]
				nHoraIni := aAlocaveis[nIndAloc]["horaInicio"]
				nHoraFim := aAlocaveis[nIndAloc]["horaFim"   ]

				aPeriodo := Self:inserePeriodoUtilizacao(cFerramenta, cSeqFer, dData, nHoraIni, nHoraFim, UTILIZACAO_TIPO_ALOCACAO, cIdOper)
				aPeriodo[ARRAY_HZK_ID] := cIdFerram

				aAdd(Self:aPerPends, aPeriodo)

				aAlocaveis[nIndAloc] := Nil
			Next

			aSize(aAlocaveis, 0)
			If Len(aInvalidos) == 0
				Exit
			EndIf
		Next nIndSeq

	Next nIndFer

	aPeriodo := {}
Return Nil

/*/{Protheus.doc} carregaUtilizacaoGlobal
Carrega a utilização de uma ferramenta da lista global para a memória da classe.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@param cFerramenta, Caracter, Codigo da ferramenta.
@return Nil
/*/
Method carregaUtilizacaoGlobal(cFerramenta) Class PCPA152Ferramenta
	Local oJsAux := Nil

	If !Self:oUtilizacao:hasProperty(cFerramenta)
		oJsAux := JsonObject():New()

		oJsAux:fromJson(_Super:retornaListaGlobal(LISTA_FERRAMENTAS, cFerramenta)[ARRAY_FERRAMENTA_UTILIZACAO])
		Self:oUtilizacao[cFerramenta] := oJsAux

		oJsAux := Nil
	EndIf

Return Nil

/*/{Protheus.doc} inserePeriodoUtilizacao
Insere um periodo no json de controle de utilização da ferramenta.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta.
@param cSeqFer    , Caracter, Sequência da ferramenta.
@param dData      , Date    , Data do periodo.
@param nInicio    , Numerico, Hora inicial do periodo.
@param nFim       , Numerico, Hora final do periodo.
@param cTipo      , Caracter, Tipo do periodo.
@param cIdOper    , Caracter, Id da operação alocada no periodo.
@return aPeriodo, Array, Retorna o periodo que foi inserido no json.
/*/
Method inserePeriodoUtilizacao(cFerramenta, cSeqFer, dData, nInicio, nFim, cTipo, cIdOper) Class PCPA152Ferramenta
	Local aPeriodo := {}
	Local cData    := DToS(dData)
	Default cIdOper := ""

	If !Self:oUtilizacao[cFerramenta]:hasProperty(cSeqFer)
		Self:oUtilizacao[cFerramenta][cSeqFer] := JsonObject():new()
	EndIf

	If !Self:oUtilizacao[cFerramenta][cSeqFer]:hasProperty(cData)
		Self:oUtilizacao[cFerramenta][cSeqFer][cData] := JsonObject():New()
		Self:oUtilizacao[cFerramenta][cSeqFer][cData]["periodos"] := {}
		Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMin" ] := nInicio
		Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMax" ] := nFim
	EndIf
	aPeriodo := Self:criaPeriodoUtilizacao(cFerramenta, dData, nInicio, nFim, cTipo, cIdOper, cSeqFer)

	aAdd(Self:oUtilizacao[cFerramenta][cSeqFer][cData]["periodos"], aPeriodo)

	If nInicio < Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMin"]
		Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMin"] := nInicio
	EndIf

	If nFim > Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMax"]
		Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMax"] := nFim
	EndIf

	Self:ordenaPeriodos(@Self:oUtilizacao[cFerramenta][cSeqFer][cData]["periodos"])

Return aPeriodo

/*/{Protheus.doc} criaPeriodoUtilizacao
Gera o periodo de utilização de uma ferramenta.
@author Lucas Fagundes
@since 24/03/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta.
@param dData      , Date    , Data da utilização.
@param nHoraIni   , Numerico, Hora inicial da utilização.
@param nHoraFim   , Numerico, Hora final da utilização.
@param cTipo      , Caracter, Tipo da utilização.
@param cIdOper    , Caracter, Id da operação alocada no periodo.
@param cSeqFer    , Caracter, Sequência da ferramenta.
@return aUtilizacao, Array, Array com o periodo de utilização da ferramenta.
/*/
Method criaPeriodoUtilizacao(cFerramenta, dData, nHoraIni, nHoraFim, cTipo, cIdOper, cSeqFer) Class PCPA152Ferramenta
	Local aUtilizacao := Array(ARRAY_HZK_TAMANHO_PROC)

	aUtilizacao[ARRAY_HZK_FILIAL ] := Self:cFilHZK
	aUtilizacao[ARRAY_HZK_PROG   ] := Self:cProg
	aUtilizacao[ARRAY_HZK_ID     ] := ""
	aUtilizacao[ARRAY_HZK_SEQ    ] := ""
	aUtilizacao[ARRAY_HZK_DATA   ] := DToS(dData)
	aUtilizacao[ARRAY_HZK_INICIO ] := nHoraIni
	aUtilizacao[ARRAY_HZK_FIM    ] := nHoraFim
	aUtilizacao[ARRAY_HZK_TEMPO  ] := nHoraFim - nHoraIni
	aUtilizacao[ARRAY_PROC_TIPO  ] := cTipo
	aUtilizacao[ARRAY_HZK_IDOPER ] := cIdOper
	aUtilizacao[ARRAY_PROC_FERRAM] := cFerramenta
	aUtilizacao[ARRAY_HZK_SEQFER ] := cSeqFer

Return aUtilizacao

/*/{Protheus.doc} ordenaPeriodos
Ordenas os periodos de utilização da ferramenta.
@author Lucas Fagundes
@since 23/04/2025
@version P12
@param aPeriodos, Array, Array com os periodos
@return Nil
/*/
Method ordenaPeriodos(aPeriodos) Class PCPA152Ferramenta

	aSort(aPeriodos,,,{|x,y| x[ARRAY_HZK_DATA] <  y[ARRAY_HZK_DATA]  .Or.;
	                        (x[ARRAY_HZK_DATA] == y[ARRAY_HZK_DATA] .And.;
	                         x[ARRAY_HZK_INICIO] <  y[ARRAY_HZK_INICIO])})

Return Nil

/*/{Protheus.doc} criaBackupFerramentas
Cria backup da utilizacao das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method criaBackupFerramentas() Class PCPA152Ferramenta

	Self:cBkpFerra := Self:getJsonUtilizacao()

Return Nil

/*/{Protheus.doc} restauraBackupFerramentas
Restaura o backup da utilização das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method restauraBackupFerramentas() Class PCPA152Ferramenta

	Self:setJsonUtilizacao(Self:cBkpFerra)

Return Nil

/*/{Protheus.doc} descartaBackupFerramentas
Descarta o backup de utilização das ferramentas.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@return Nil
/*/
Method descartaBackupFerramentas() Class PCPA152Ferramenta

	Self:cBkpFerra := ""

Return Nil

/*/{Protheus.doc} descartaReservaFerramentas
Descarta os periodos que foram reservados para alocação de ferramentas.
@author Lucas Fagundes
@since 11/07/2025
@version version
@return Nil
/*/
Method descartaReservaFerramentas() Class PCPA152Ferramenta

	Self:aPerPends := {}

Return Nil

/*/{Protheus.doc} efetivaFerramentas
Efetiva a alocação dos periodos que foram reservados.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@param oSeqSVM, Object, Json com as sequencias da tabela SVM.
@return Nil
/*/
Method efetivaFerramentas(oSeqSVM) Class PCPA152Ferramenta
	Local aDadosID := {}
	Local aPeriodo := {}
	Local cChave   := ""
	Local cData    := ""
	Local cHoraFim := ""
	Local cHoraIni := ""
	Local cIdAux   := ""
	Local cIdOper  := ""
	Local nIndex   := 1
	Local nSequen  := 0
	Local nTotal   := Len(Self:aPerPends)

	aSort(Self:aPerPends,,,{|x,y| x[ARRAY_HZK_ID] < y[ARRAY_HZK_ID] .Or. (x[ARRAY_HZK_ID] == y[ARRAY_HZK_ID] .And. (x[ARRAY_HZK_DATA  ] <  y[ARRAY_HZK_DATA  ] .Or.;
	                                                                                                               (x[ARRAY_HZK_DATA  ] == y[ARRAY_HZK_DATA  ] .And.;
	                                                                                                                x[ARRAY_HZK_INICIO] <  y[ARRAY_HZK_INICIO])))})

	While nIndex <= nTotal
		aPeriodo := Self:aPerPends[nIndex]
		cIdOper  := aPeriodo[ARRAY_HZK_IDOPER]
		cData    := aPeriodo[ARRAY_HZK_DATA  ]
		cHoraIni := __Min2Hrs(aPeriodo[ARRAY_HZK_INICIO], .T.)
		cHoraFim := __Min2Hrs(aPeriodo[ARRAY_HZK_FIM   ], .T.)
		cChave   := cIdOper + cData + cHoraIni + cHoraFim

		If aPeriodo[ARRAY_HZK_ID] == cIdAux
			nSequen++
		Else
			nSequen := 0
			cIdAux  := aPeriodo[ARRAY_HZK_ID]
		EndIf

		aPeriodo[ARRAY_HZK_SEQ   ] := StrZero(nSequen, Self:nTamHZKSEQ)
		aPeriodo[ARRAY_HZK_INICIO] := cHoraIni
		aPeriodo[ARRAY_HZK_FIM   ] := cHoraFim
		aPeriodo[ARRAY_HZK_SEQALO] := oSeqSVM[cChave]

		aAdd(aDadosID, aClone(aPeriodo))

		aPeriodo[ARRAY_HZK_INICIO] := __Hrs2Min(aPeriodo[ARRAY_HZK_INICIO])
		aPeriodo[ARRAY_HZK_FIM   ] := __Hrs2Min(aPeriodo[ARRAY_HZK_FIM   ])

		nIndex++

		If nIndex > nTotal .Or. Self:aPerPends[nIndex][ARRAY_HZK_IDOPER] != cIdOper
			_Super:adicionaListaGlobal(LISTA_DADOS_HZK, cIdOper, aDadosID, .F.)
			aDadosID := {}
		EndIf

		aPeriodo := {}
	End

	Self:aPerPends := {}
Return Nil

/*/{Protheus.doc} converteArrayProcessamentoParaGravacao
Converte o array de processamento para o array de gravação no banco de dados.
@author Lucas Fagundes
@since 31/03/2025
@version P12
@param aProc  , Array   , Array que será usado para gravação.
@param cTabela, Caracter, Tabela que será gravada.
@return aGrava, Array, Array que será gravado no banco de dados.
/*/
Method converteArrayProcessamentoParaGravacao(aProc, cTabela) Class PCPA152Ferramenta
	Local aGrava := {}

	If cTabela == "HZJ"
		aGrava := aProc

	ElseIf cTabela == "HZK"
		aGrava := Array(ARRAY_HZK_TAMANHO_GRAVA)

		aGrava[ARRAY_HZK_FILIAL] := aProc[ARRAY_HZK_FILIAL]
		aGrava[ARRAY_HZK_PROG  ] := aProc[ARRAY_HZK_PROG  ]
		aGrava[ARRAY_HZK_ID    ] := aProc[ARRAY_HZK_ID    ]
		aGrava[ARRAY_HZK_SEQ   ] := aProc[ARRAY_HZK_SEQ   ]
		aGrava[ARRAY_HZK_DATA  ] := aProc[ARRAY_HZK_DATA  ]
		aGrava[ARRAY_HZK_INICIO] := aProc[ARRAY_HZK_INICIO]
		aGrava[ARRAY_HZK_FIM   ] := aProc[ARRAY_HZK_FIM   ]
		aGrava[ARRAY_HZK_TEMPO ] := aProc[ARRAY_HZK_TEMPO ]
		aGrava[ARRAY_HZK_IDOPER] := aProc[ARRAY_HZK_IDOPER]
		aGrava[ARRAY_HZK_SEQALO] := aProc[ARRAY_HZK_SEQALO]
		aGrava[ARRAY_HZK_SEQFER] := aProc[ARRAY_HZK_SEQFER]
	EndIf

Return aGrava

/*/{Protheus.doc} removePeriodosEfetivados
Remove a utilização efetivada de uma operação.
(Usar em conjunto com o método removeUtilizacaoLocal() para excluir toda a alocação de uma operação.)
@author Lucas Fagundes
@since 01/04/2025
@version P12
@param cIdOper, Caracter, Id da operação que terá as alocações removidas.
@return Nil
/*/
Method removePeriodosEfetivados(cIdOper) Class PCPA152Ferramenta

Return _Super:deletaChaveListaGlobal(LISTA_DADOS_HZK, cIdOper)

/*/{Protheus.doc} removeUtilizacaoLocal
Remove a utilização das ferramentas de uma operação do json local.
(Usar em conjunto com o método removePeriodosEfetivados() para excluir toda a alocação de uma operação.)
@author Lucas Fagundes
@since 01/04/2025
@version P12
@param cIdOper, Caracter, Id da operação que terá as alocações removidas.
@return Nil
/*/
Method removeUtilizacaoLocal(cIdOper) Class PCPA152Ferramenta
	Local aGlobal     := {}
	Local cChave      := ""
	Local cData       := ""
	Local cFerramenta := ""
	Local cSeqFer     := ""
	Local lError      := .F.
	Local nIndex      := 0
	Local nTotal      := 0
	Local oChaves     := JsonObject():New()

	If !Self:lUsaFerram
		Return Nil
	EndIf

	aGlobal := _Super:retornaListaGlobal(LISTA_DADOS_HZK, cIdOper, @lError)
	If !lError
		nTotal := Len(aGlobal)

		For nIndex := 1 To nTotal
			cFerramenta := aGlobal[nIndex][ARRAY_PROC_FERRAM]
			cSeqFer     := aGlobal[nIndex][ARRAY_HZK_SEQFER ]
			cData       := aGlobal[nIndex][ARRAY_HZK_DATA   ]
			cChave      := cFerramenta + cSeqFer + cData

			If !oChaves:hasProperty(cChave)
				Self:removeOperacaoPeriodos(cFerramenta, cSeqFer, cData, cIdOper)
				oChaves[cChave] := .T.
			EndIf
		Next

	EndIf

	aSize(aGlobal, 0)
	FreeObj(oChaves)
Return Nil

/*/{Protheus.doc} removeOperacaoPeriodos
Remove as utilizações de uma operação em uma data.
@author Lucas Fagundes
@since 01/04/2025
@version P12
@param cFerramenta, Caracter, Ferramenta que terá a utilização removida.
@param cSeqFer    , Caracter, Sequência da ferramenta que terá a utilização removida.
@param cData      , Caracter, Data que sera removido a utilização.
@param cIdOper    , Caracter, Operação que terá a utilização removida.
@return Nil
/*/
Method removeOperacaoPeriodos(cFerramenta, cSeqFer, cData, cIdOper) Class PCPA152Ferramenta
	Local aPeriodo  := {}
	Local aPeriodos := {}
	Local nHrMax    := -1
	Local nHrMin    := -1
	Local nIndex    := 1
	Local nTotal    := 0

	If Self:oUtilizacao[cFerramenta][cSeqFer]:hasProperty(cData)
		aPeriodos := Self:oUtilizacao[cFerramenta][cSeqFer][cData]["periodos"]
		nTotal    := Len(aPeriodos)

		While nIndex <= nTotal
			aPeriodo := aPeriodos[nIndex]

			If aPeriodo[ARRAY_HZK_IDOPER] == cIdOper
				aDel(aPeriodos, nIndex)
				nTotal--
				Loop
			EndIf

			If nHrMin == -1 .Or. aPeriodo[ARRAY_HZK_INICIO] < nHrMin
				nHrMin := aPeriodo[ARRAY_HZK_INICIO]
			EndIf

			If nHrMax == -1 .Or. aPeriodo[ARRAY_HZK_FIM] > nHrMax
				nHrMax := aPeriodo[ARRAY_HZK_FIM]
			EndIf

			nIndex++
			aPeriodo := {}
		End

		aSize(aPeriodos, nTotal)

		If Empty(aPeriodos)
			Self:oUtilizacao[cFerramenta][cSeqFer]:delName(cData)
		Else
			Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMin"] := nHrMin
			Self:oUtilizacao[cFerramenta][cSeqFer][cData]["horaMax"] := nHrMax

			Self:ordenaPeriodos(@aPeriodos)
		EndIf

		aPeriodos := {}
	EndIf

Return Nil

/*/{Protheus.doc} getJsonUtilizacao
Retorna o json com a utilização das ferramentas.
@author Lucas Fagundes
@since 01/04/2025
@version P12
@return cJson, Caracter, Json com a utilização das ferramentas.
/*/
Method getJsonUtilizacao() Class PCPA152Ferramenta
	Local cJson := Self:oUtilizacao:toJson()

Return cJson

/*/{Protheus.doc} setJsonUtilizacao
Seta o json de utilização das ferramentas.
@author Lucas Fagundes
@since 01/04/2025
@version P12
@param cJson, Caracter, Json com a utilização das ferramentas.
@return Nil
/*/
Method setJsonUtilizacao(cJson) Class PCPA152Ferramenta

	Self:oUtilizacao := JsonObject():New()
	Self:oUtilizacao:fromJson(cJson)

Return Nil

/*/{Protheus.doc} carregaFerramentasOperacao
Carrega as ferramentas de uma operação.
@author Lucas Fagundes
@since 22/04/2025
@version P12
@param cIdOper, Caracter, Id da operação que terá as ferramentas carregadas.
@return aFerram, Array, Array com as ferramentas da operação.
/*/
Method carregaFerramentasOperacao(cIdOper) Class PCPA152Ferramenta
	Local aConjunto := {}
	Local aDadosHZJ := {}
	Local aFerram   := {}
	Local cAlias    := ""
	Local cQuery    := ""
	Local cSeqUso   := ""

	If Self:oCarga == Nil
		cQuery := " SELECT HZJ.HZJ_FILIAL, "
		cQuery +=        " HZJ.HZJ_ID, "
		cQuery +=        " HZJ.HZJ_FERRAM, "
		cQuery +=        " HZJ.HZJ_QUANT, "
		cQuery +=        " HZJ.HZJ_ALTERN, "
		cQuery +=        " HZJ.HZJ_SEQUSO "
		cQuery +=   " FROM " + RetSqlName("HZJ") + " HZJ "
		cQuery +=  " WHERE HZJ.HZJ_FILIAL =  ? "
		cQuery +=    " AND HZJ.HZJ_PROG   =  ? "
		cQuery +=    " AND HZJ.HZJ_OPER   =  ? "
		cQuery +=    " AND HZJ.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY HZJ.HZJ_SEQUSO "

		Self:oCarga := FwExecStatement():New(cQuery)
		Self:oCarga:setString(1, xFilial("HZJ")) // HZJ_FILIAL
		Self:oCarga:setString(2, Self:cProg) // HZJ_PROG
	EndIf

	Self:oCarga:setString(3, cIdOper) // HZJ_OPER

	cAlias := Self:oCarga:openAlias()

	While (cAlias)->(!EoF())

		If (cAlias)->HZJ_SEQUSO != cSeqUso
			cSeqUso := (cAlias)->HZJ_SEQUSO

			aConjunto := Array(ARRAY_FERRAM_TAMANHO)
			aConjunto[ARRAY_FERRAM_FERRAMENTAS] := {}
			aConjunto[ARRAY_FERRAM_SEQUENCIA  ] := cSeqUso

			aAdd(aFerram, aConjunto)
		EndIf

		aDadosHZJ := Array(ARRAY_HZJ_TAMANHO)
		aDadosHZJ[ARRAY_HZJ_FILIAL] := (cAlias)->HZJ_FILIAL
		aDadosHZJ[ARRAY_HZJ_PROG  ] := Self:cProg
		aDadosHZJ[ARRAY_HZJ_ID    ] := (cAlias)->HZJ_ID
		aDadosHZJ[ARRAY_HZJ_OPER  ] := cIdOper
		aDadosHZJ[ARRAY_HZJ_FERRAM] := (cAlias)->HZJ_FERRAM
		aDadosHZJ[ARRAY_HZJ_QUANT ] := (cAlias)->HZJ_QUANT
		aDadosHZJ[ARRAY_HZJ_ALTERN] := (cAlias)->HZJ_ALTERN
		aDadosHZJ[ARRAY_HZJ_SEQUSO] := (cAlias)->HZJ_SEQUSO

		_Super:adicionaListaGlobal(LISTA_DADOS_HZJ, cIdOper, aDadosHZJ, .T.)

		aAdd(aConjunto[ARRAY_FERRAM_FERRAMENTAS], aDadosHZJ)

		Self:oCargaAux[(cAlias)->HZJ_FERRAM] := (cAlias)->HZJ_QUANT

		(cAlias)->(dbSkip())

		aDadosHZJ := {}
	End
	(cAlias)->(dbCloseArea())

	aConjunto := {}
Return aFerram

/*/{Protheus.doc} cargaUtilizacao
Carrega a utilização de uma ferramenta.
@author Lucas Fagundes
@since 22/04/2025
@version P12
@param cFerram, Caracter, Ferramenta que será carregada.
@return oUtilizacao, Object, Json com a utilização da ferramenta.
/*/
Method cargaUtilizacao(cFerram) Class PCPA152Ferramenta
	Local cAlias      := ""
	Local cQuery      := ""
	Local cSeqFer     := ""
	Local cTipo       := ""
	Local dData       := Nil
	Local nHoraFim    := 0
	Local nHoraIni    := 0
	Local oUtilizacao := Self:oUtilizacao[cFerram]

	If Self:oCarga == Nil
		cQuery := " SELECT SMR.MR_DATDISP, "
		cQuery +=        " SMK.MK_HRINI, "
		cQuery +=        " SMK.MK_HRFIM, "
		cQuery +=        " SMK.MK_TIPO, "
		cQuery +=        " SMR.MR_SEQFER "
		cQuery +=   " FROM " + RetSqlName("SMR") + " SMR "
		cQuery +=  " INNER JOIN " + RetSqlName("SMK") + " SMK "
		cQuery +=     " ON SMK.MK_FILIAL  =  ? "
		cQuery +=    " AND SMK.MK_PROG    = SMR.MR_PROG "
		cQuery +=    " AND SMK.MK_DISP    = SMR.MR_DISP "
		cQuery +=    " AND SMK.D_E_L_E_T_ = ' ' "
		cQuery +=  " WHERE SMR.MR_FILIAL  =  ? "
		cQuery +=    " AND SMR.MR_PROG    =  ? "
		cQuery +=    " AND SMR.MR_RECURSO =  ? "
		cQuery +=    " AND SMR.MR_TIPO    =  ? "
		cQuery +=    " AND SMR.D_E_L_E_T_ = ' ' "
		cQuery +=  " ORDER BY SMR.MR_DATDISP, SMK.MK_HRINI "

		Self:oCarga := FwExecStatement():New(cQuery)
		Self:oCarga:setFields({;
			{"MR_DATDISP", "D", 8, 0},;
			"MK_HRINI" ,;
			"MK_HRFIM" ,;
			"MK_TIPO"  ,;
			"MK_BLOQUE",;
			"MR_SEQFER";
		})

		Self:oCarga:setString(1, xFilial("SMK")) // MK_FILIAL
		Self:oCarga:setString(2, xFilial("SMR")) // MR_FILIAL
		Self:oCarga:setString(3, Self:cProg) // MR_PROG
		Self:oCarga:setString(5, MR_TIPO_FERRAMENTA) // MR_TIPO
	EndIf

	Self:oCarga:setString(4, cFerram) // MR_RECURSO

	cAlias := Self:oCarga:openAlias()
	Self:oCarga:doTcSetField(cAlias)

	While (cAlias)->(!EoF())
		dData    := (cAlias)->MR_DATDISP
		nHoraIni := __Hrs2Min((cAlias)->MK_HRINI)
		nHoraFim := __Hrs2Min((cAlias)->MK_HRFIM)
		cSeqFer  := RTrim((cAlias)->MR_SEQFER)
		cTipo    := UTILIZACAO_TIPO_BLOQUEIO

		If (cAlias)->MK_TIPO == HORA_EFETIVADA
			cTipo := UTILIZACAO_TIPO_EFETIVA
		EndIf

		Self:inserePeriodoUtilizacao(cFerram, cSeqFer, dData, nHoraIni, nHoraFim, cTipo)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oUtilizacao

/*/{Protheus.doc} getHorasEfetivadasFerramenta
Busca as horas efetivadas de uma ferramenta em um periodo de tempo.
@author Lucas Fagundes
@since 28/04/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta.
@param dDataIni   , Date    , Data inicial da busca.
@param dDataFim   , Date    , Data final da busca.
@return oDatas, Object, Json com os periodos efetivados da ferramenta.
/*/
Method getHorasEfetivadasFerramenta(cFerramenta, dDataIni, dDataFim) Class PCPA152Ferramenta
	Local cAlias      := ""
	Local cData       := ""
	Local cHoraFim    := ""
	Local cHoraIni    := ""
	Local cQuery      := ""
	Local cTableOP    := ""
	Local nPOSHORAFIM := 2
	Local nTamSeq     := 0
	Local oDatas      := JsonObject():New()

	If Self:oQryEfet == Nil
		cQuery := " SELECT HZL.HZL_DATA, "
		cQuery +=        " HZL.HZL_INICIO, "
		cQuery +=        " HZL.HZL_FIM, "
		cQuery +=        " HZL.HZL_SEQFER "
		cQuery +=   " FROM " + RetSqlName("HZL") + " HZL "
		cQuery +=  " WHERE HZL.HZL_FILIAL  =  ? "
		cQuery +=    " AND HZL.HZL_FERRAM  =  ? "
		cQuery +=    " AND HZL.HZL_DATA   >=  ? "
		cQuery +=    " AND HZL.HZL_DATA   <=  ? "
		cQuery +=    " AND HZL.HZL_STATUS  =  ? "
		cQuery +=    " AND HZL.D_E_L_E_T_  = ' ' "

		If _Super:retornaParametro("replanejaSacramentadas")
			cTableOP := RetSqlName("SMF")

			If _Super:possuiTabelaTemporaria()
				cTableOP := _Super:getNomeTempTable()
			EndIf

			cQuery += " AND NOT EXISTS (SELECT 1 "
			cQuery +=                   " FROM " + cTableOP + " TABLEOP "
			cQuery +=                  " WHERE TABLEOP.MF_FILIAL  = '" + xFilial("SMF") + "' "
			cQuery +=                    " AND TABLEOP.MF_PROG    = '" + Self:cProg     + "' "
			cQuery +=                    " AND TABLEOP.MF_OP      = HZL.HZL_OP "
			cQuery +=                    " AND TABLEOP.MF_OPER    = HZL.HZL_OPER "
			cQuery +=                    " AND TABLEOP.D_E_L_E_T_ = ' ') "
		EndIf

		cQuery +=  " ORDER BY HZL.HZL_SEQFER, HZL.HZL_DATA, HZL.HZL_INICIO, HZL.HZL_FIM "

		Self:oQryEfet := FwExecStatement():New(cQuery)
		Self:oQryEfet:setFields({{"HZL_DATA", "D", 8, 0}, "HZL_INICIO", "HZL_FIM"})

		Self:oQryEfet:setString(1, xFilial("HZL")) // HZL_FILIAL
		Self:oQryEfet:setString(5, STATUS_ATIVO) // HZL_STATUS
	EndIf
	Self:oQryEfet:setString(2, cFerramenta) // HZL_FERRAM
	Self:oQryEfet:setDate(3, dDataIni) // HZL_DATA
	Self:oQryEfet:setDate(4, dDataFim) // HZL_DATA

	cAlias := Self:oQryEfet:openAlias()
	Self:oQryEfet:doTcSetField(cAlias)

	While (cAlias)->(!EoF())
		cData    := DToS((cAlias)->HZL_DATA)
		cHoraIni := (cAlias)->HZL_INICIO
		cHoraFim := (cAlias)->HZL_FIM
		cSeq     := RTrim((cAlias)->HZL_SEQFER)

		If !oDatas:hasProperty(cData)
			oDatas[cData] := JsonObject():New()
		EndIf

		If !oDatas[cData]:hasProperty(cSeq)
			oDatas[cData][cSeq] := {}
		EndIf

		nTamSeq := Len(oDatas[cData][cSeq])
		If nTamSeq > 0 .And. oDatas[cData][cSeq][nTamSeq][nPOSHORAFIM] == cHoraIni
			oDatas[cData][cSeq][nTamSeq][nPOSHORAFIM] := cHoraFim
		Else
			aAdd(oDatas[cData][cSeq], {cHoraIni, cHoraFim})
		EndIf

		Self:addSeqData(cData, cSeq)

		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

Return oDatas

/*/{Protheus.doc} geraUtilizacaoAdicional
Carrega utilização adicional das ferramentas.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@param aFerramentas, Array, Array com as ferramentas que terão a utilização adicional carregada.
@param dDataIni    , Date , Data inicial da carga.
@param dDataFim    , Date , Data final da carga.
@return Nil
/*/
Method geraUtilizacaoAdicional(aFerramentas, dDataIni, dDataFim) Class PCPA152Ferramenta
	Local aGlobal   := {}
	Local cData     := ""
	Local cSeqFer   := ""
	Local dData     := Nil
	Local dIniAux   := Nil
	Local lError    := .F.
	Local nIndex    := 0
	Local nIndFerra := 0
	Local nTotal    := Len(aFerramentas)
	Local nTotFerra := 0
	Local oBkpFerra := Nil
	Local oJsAux    := Nil

	For nIndex := 1 To nTotal
		cFerramenta := aFerramentas[nIndex][ARRAY_HZJ_FERRAM]

		Self:carregaUtilizacaoGlobal(cFerramenta)
		nTotFerra := Self:oUtilizacao[cFerramenta]["quantidade"]

		aGlobal := _Super:retornaListaGlobal("FERRAMENTAS_ADICIONAL", cFerramenta, @lError)
		If lError
			aGlobal := _Super:retornaListaGlobal(LISTA_FERRAMENTAS, cFerramenta)
		EndIf

		oJsAux := JsonObject():New()
		oJsAux:fromJson(aGlobal[ARRAY_FERRAMENTA_UTILIZACAO])

		oBkpFerra := Self:oUtilizacao[cFerramenta]
		Self:oUtilizacao[cFerramenta] := oJsAux

		dIniAux := Self:getUltimaDataFerramenta(cFerramenta, .T.) + 1
		If dIniAux >= dDataIni
			dDataIni := dIniAux
		EndIf

		Self:carregaIndisponibilidadesFerramenta(cFerramenta, dDataIni, dDataFim, .T.)

		For nIndFerra := 1 To nTotFerra
			cSeqFer := cValToChar(nIndFerra)

			If Self:oUtilizacao[cFerramenta]:hasProperty(cSeqFer)

				If !oBkpFerra:hasProperty(cSeqFer)
					oBkpFerra[cSeqFer] := JsonObject():New()
				EndIf

				For dData := dDataIni To dDataFim
					cData := DToS(dData)

					If Self:oUtilizacao[cFerramenta][cSeqFer]:hasProperty(cData)
						oBkpFerra[cSeqFer][cData] := Self:oUtilizacao[cFerramenta][cSeqFer][cData]
					EndIf
				Next
			EndIf
		Next

		aGlobal[ARRAY_FERRAMENTA_UTILIZACAO] := Self:oUtilizacao[cFerramenta]:toJson()
		Self:oUtilizacao[cFerramenta] := oBkpFerra

		_Super:adicionaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL, cFerramenta, aGlobal, .F.)
		Self:setUltimaDataFerramenta(cFerramenta, dDataFim, .T.)

		oJsAux    := Nil
		oBkpFerra := Nil
		aSize(aGlobal, 0)
	Next

Return Nil

/*/{Protheus.doc} setUltimaDataFerramenta
Grava a ultima data que foi carregada a utilização da ferramenta.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@param cFerramenta, Caracter, Codigo da ferramenta.
@param dData      , Date    , Data que carregou a utilização
@param lAdicional , Logico  , Indica se carregou utilização adicional.
@return Nil
/*/
Method setUltimaDataFerramenta(cFerramenta, dData, lAdicional) Class PCPA152Ferramenta
	Local cChave   := "ULTIMA_DATA_FERRAMENTA_" + cFerramenta
	Local dDataAux := Nil
	Local lError   := .F.

	If lAdicional
		cChave += "_ADICIONAL"
	EndIf

	dDataAux := _Super:retornaValorGlobal(cChave, @lError)
	If lError .Or. dData > dDataAux
		_Super:gravaValorGlobal(cChave, dData)
	EndIf

Return Nil

/*/{Protheus.doc} getUltimaDataFerramenta
Retorna a ultima data que carregou a utilização de uma ferramenta.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@param cFerramenta, Caracter, Codigo da ferramenta.
@param lAdicional , Logico  , Indica que deve verificar a flag de utilização adicional.
@return dData, Date, Ultima data que carregou a utilização.
/*/
Method getUltimaDataFerramenta(cFerramenta, lAdicional) Class PCPA152Ferramenta
	Local cChave := "ULTIMA_DATA_FERRAMENTA_" + cFerramenta
	Local dData  := Nil
	Local lError := .F.

	If lAdicional
		cChave += "_ADICIONAL"
	EndIf

	dData := _Super:retornaValorGlobal(cChave, @lError)
	If lError
		cChave := "ULTIMA_DATA_FERRAMENTA_" + cFerramenta
		lError := .F.

		dData := _Super:retornaValorGlobal(cChave, @lError)
	EndIf

Return dData

/*/{Protheus.doc} efetivaUtilizacaoAdicional
Efetiva a utilização adicional que foi carregada.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@return Nil
/*/
Method efetivaUtilizacaoAdicional() Class PCPA152Ferramenta
	Local aDados  := {}
	Local aGlobal := {}
	Local cChave  := ""
	Local nIndex  := 0
	Local nTotal  := 0

	aGlobal := _Super:retornaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL)
	nTotal  := Len(aGlobal)

	For nIndex := 1 To nTotal
		cChave := aGlobal[nIndex][1]
		aDados := aGlobal[nIndex][2]

		_Super:adicionaListaGlobal(LISTA_FERRAMENTAS, cChave, aDados, .F.)
		Self:setUltimaDataFerramenta(cChave, Self:getUltimaDataFerramenta(cChave, .T.), .F.)
		Self:limpaUltimaDataAdicionalFerramenta(cChave)

		aSize(aDados, 0)
		aSize(aGlobal[nIndex], 0)
		aGlobal[nIndex] := Nil
	Next

	_Super:limpaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL)

	aSize(aGlobal, 0)
Return Nil

/*/{Protheus.doc} limpaUltimaDataAdicionalFerramenta
Limpa a global que controla a ultima data que foi gerada utilização adicional.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@param cFerramenta, Caracter, Codigo da ferramenta que tera a global limpa.
@return Nil
/*/
Method limpaUltimaDataAdicionalFerramenta(cFerramenta) Class PCPA152Ferramenta

Return _Super:limpaValorGlobal("ULTIMA_DATA_FERRAMENTA_" + cFerramenta + "_ADICIONAL")

/*/{Protheus.doc} excluiUtilizacaoAdicional
Exclui a utilização adicional que foi gerada.
@author Lucas Fagundes
@since 29/04/2025
@version P12
@return Nil
/*/
Method excluiUtilizacaoAdicional() Class PCPA152Ferramenta
	Local aGlobal     := {}
	Local cFerramenta := ""
	Local nIndex      := 0
	Local nTotal      := 0

	aGlobal := _Super:retornaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL)
	nTotal  := Len(aGlobal)

	For nIndex := 1 To nTotal
		cFerramenta := aGlobal[nIndex][1]

		Self:limpaUltimaDataAdicionalFerramenta(cFerramenta)

		aSize(aGlobal[nIndex], 0)
	Next

	_Super:limpaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL)

	aSize(aGlobal, 0)
Return Nil

/*/{Protheus.doc} addSeqData
Adiciona um registro no json de controle de indisponibilidades oSeqData.
@author Lucas Fagundes
@since 06/05/2025
@version P12
@param cData, Caracter, Data da indisponibilidade.
@param cSeq , Caracter, Sequencia da indisponibilidade.
@return Nil
/*/
Method addSeqData(cData, cSeq) Class PCPA152Ferramenta

	If !Self:oSeqData:hasProperty(cData)
		Self:oSeqData[cData] := JsonObject():New()
		Self:oSeqData[cData]["sequencias"] := {}
	EndIf

	If !Self:oSeqData[cData]:hasProperty(cSeq)
		Self:oSeqData[cData][cSeq] := .T.
		aAdd(Self:oSeqData[cData]["sequencias"], cSeq)
	EndIf

Return Nil

/*/{Protheus.doc} geraIndisponibilidadesAdicionais
Gera indisponibilidade adicional para as ferramentas até a data que gerou disponibilidade adicional para os recursos.
@author Lucas Fagundes
@since 07/05/2025
@version P12
@return Nil
/*/
Method geraIndisponibilidadesAdicionais() Class PCPA152Ferramenta
	Local aDadosFerr   := {}
	Local aFerramentas := {}
	Local cFerramenta  := ""
	Local cSeqFer      := ""
	Local dData        := Nil
	Local dDataAux     := Nil
	Local dDataFim     := Nil
	Local dDataIni     := Nil
	Local nIndFerram   := 0
	Local nSeqFer      := 0
	Local nTotFer      := 0
	Local nTotFerram   := 0
	Local oBkpUti      := Nil
	Local oDisp        := Nil
	Local oUtilizacao  := Nil

	_Super:processamentoFactory(Self:cProg, FACTORY_OPC_DISP, @oDisp)
	dDataFim := oDisp:getFimDataDispAdicional(.F.) // Data final da disponibilidade dos recursos - sem considerar adicional
	dDataAux := oDisp:getFimDataDispAdicional(.T.) // Data final da disponibilidade dos recursos - considerando adicional

	If dDataAux != Nil .And. dDataAux > dDataFim
		dDataFim := dDataAux
	EndIf

	aFerramentas := _Super:retornaListaGlobal(LISTA_FERRAMENTAS)
	nTotFerram   := Len(aFerramentas)

	For nIndFerram := 1 To nTotFerram
		cFerramenta := aFerramentas[nIndFerram][1]
		aDadosFerr  := aFerramentas[nIndFerram][2]
		dDataIni    := Self:getUltimaDataFerramenta(cFerramenta, .T.) + 1

		If dDataIni >= dDataFim
			aSize(aDadosFerr, 0)
			aSize(aFerramentas[nIndFerram], 0)

			Loop
		EndIf

		Self:carregaUtilizacaoGlobal(cFerramenta)
		nTotFer := Self:oUtilizacao[cFerramenta]["quantidade"]

		oUtilizacao := JsonObject():New()
		oUtilizacao:fromJson(aDadosFerr[ARRAY_FERRAMENTA_UTILIZACAO])

		oBkpUti := Self:oUtilizacao[cFerramenta]
		Self:oUtilizacao[cFerramenta] := oUtilizacao

		Self:carregaIndisponibilidadesFerramenta(cFerramenta, dDataIni, dDataFim, .T.)

		aDadosFerr[ARRAY_FERRAMENTA_UTILIZACAO] := Self:oUtilizacao[cFerramenta]:toJson()

		For nSeqFer := 1 To nTotFer
			cSeqFer := cValToChar(nSeqFer)

			If Self:oUtilizacao[cFerramenta]:hasProperty(cSeqFer)

				If !oBkpUti:hasProperty(cSeqFer)
					oBkpUti[cSeqFer] := JsonObject():New()
				EndIf

				For dData := dDataIni To dDataFim
					cData := DToS(dData)

					If Self:oUtilizacao[cFerramenta][cSeqFer]:hasProperty(cData)
						oBkpUti[cSeqFer][cData] := Self:oUtilizacao[cFerramenta][cSeqFer][cData]
					EndIf
				Next
			EndIf
		Next
		Self:oUtilizacao[cFerramenta] := oBkpUti

		_Super:adicionaListaGlobal(LISTA_FERRAMENTAS_ADICIONAL, cFerramenta, aDadosFerr, .F.)
		Self:setUltimaDataFerramenta(cFerramenta, dDataFim, .T.)

		oBkpUti := Nil
		oUtilizacao := Nil
		aSize(aDadosFerr, 0)
		aSize(aFerramentas[nIndFerram], 0)
	Next

	oDisp := Nil
	aSize(aFerramentas, 0)
Return Nil

/*/{Protheus.doc} verificaDisponibilidadeFerramentas
Verifica se as ferramentas estão disponíveis para uso dentro de um intervalo de tempo.
@author Lucas Fagundes
@since 18/07/2025
@version P12
@param aFerramentas, Array, Array com as ferramentas que serão verificadas.
@param dData       , Date, Data do intervalo de tempo.
@param nHoraIni    , Numerico, Hora inicial do intervalo de tempo.
@param nHoraFim    , Numerico, Hora final do intervalo de tempo.
@param aPersDisp   , Retorna por referencia os periodos disponiveis dentro do intervalo de tempo.
@param aPersInd    , Retorna por referencia os periodos indisponiveis dentro do intervalo de tempo.
@return lDisponivel, Logico, Indica se as ferramentas estão disponíveis para uso dentro do intervalo de tempo.
/*/
Method verificaDisponibilidadeFerramentas(aFerramentas, dData, nHoraIni, nHoraFim, aPersDisp, aPersInd) Class PCPA152Ferramenta
	Local aDispon     := {}
	Local aPersInd    := {}
	Local cFerramenta := ""
	Local cSeqFerram  := ""
	Local lDisponivel := .T.
	Local lFerramDisp := .T.
	Local nIndex      := 0
	Local nIndFer     := 0
	Local nTotal      := Len(aFerramentas)
	Local nTotFer     := 0
	Local oPeriodo    := JsonObject():New()
	Local nIndPer     := 0
	Local nTotalPer   := 0

	aPersDisp := {}
	aPersInd  := {}

	oPeriodo["data"      ] := dData
	oPeriodo["horaInicio"] := nHoraIni
	oPeriodo["horaFim"   ] := nHoraFim

	For nIndex := 1 To nTotal
		aDispon     := {}
		cFerramenta := aFerramentas[nIndex][ARRAY_HZJ_FERRAM]
		lFerramDisp := .F.
		aPersInd    := {oPeriodo}

		Self:carregaUtilizacaoGlobal(cFerramenta)
		nTotFer := Self:oUtilizacao[cFerramenta]["quantidade"]

		For nIndFer := 1 To nTotFer
			cSeqFerram := cValToChar(nIndFer)

			If Self:oUtilizacao[cFerramenta]:hasProperty(cSeqFerram)
				aPersDisp   := Self:validaPeriodosFerramenta(cFerramenta, cSeqFerram, @aPersInd)
				lFerramDisp := Len(aPersInd) == 0
				nTotalPer   := Len(aPersDisp)

				For nIndPer := 1 To nTotalPer
					aAdd(aDispon, aPersDisp[nIndPer])
				Next
			Else
				lFerramDisp := .T.
				nTotalPer   := Len(aPersInd)

				For nIndPer := 1 To nTotalPer
					aAdd(aDispon, aPersInd[nIndPer])
				Next

				aSize(aPersInd, 0)
			EndIf

			If lFerramDisp
				Exit
			EndIf
		Next

		If !lFerramDisp
			lDisponivel := .F.
			Exit
		EndIf
	Next

	aPersDisp := aDispon
	aDispon   := {}

	Self:ajustaArrayPeriodos(@aPersDisp)
	Self:ajustaArrayPeriodos(@aPersInd)

	FreeObj(oPeriodo)
Return lDisponivel

/*/{Protheus.doc} validaPeriodosFerramenta
Valida se os periodos recebidos estão disponiveis para alocação de uma ferramenta.
@author Lucas Fagundes
@since 18/07/2025
@version P12
@param cFerramenta, Caracter, Código da ferramenta que será validada.
@param cSeqFer    , Caracter, Sequencia da ferramenta que será validada.
@param aValida    , Array   , Array com os periodos que serão validados (retorna por referencia os periodos que não estão disponiveis para alocação).
@return aAlocaveis, Array, Array com os periodos que estão disponíveis para alocação da ferramenta.
/*/
Method validaPeriodosFerramenta(cFerramenta, cSeqFer, aValida) Class PCPA152Ferramenta
	Local aAlocaveis := {}
	Local aInvalidos := {}
	Local aPeriodo   := {}
	Local aPeriodos  := {}
	Local cData      := ""
	Local dDataVld   := Nil
	Local nFimVld    := 0
	Local nIndex     := 0
	Local nIndexPer  := 0
	Local nIniVld    := 0
	Local nTotal     := Len(aValida)
	Local nTotalPer  := 0
	Local oDatas     := Nil

	If !Self:oUtilizacao[cFerramenta]:hasProperty(cSeqFer)
		aAlocaveis := aClone(aValida)
		aSize(aValida, 0)
		Return aAlocaveis
	EndIf
	oDatas := Self:oUtilizacao[cFerramenta][cSeqFer]

	For nIndex := 1 to nTotal
		dDataVld := aValida[nIndex]["data"      ]
		nIniVld  := aValida[nIndex]["horaInicio"]
		nFimVld  := aValida[nIndex]["horaFim"   ]
		cData    := DToS(dDataVld)

		If oDatas:hasProperty(cData)

			If nIniVld >= oDatas[cData]["horaMax"] .Or. nFimVld <= oDatas[cData]["horaMin"]
				aAdd(aAlocaveis, Self:criaJsonPeriodo(dDataVld, nIniVld, nFimVld))
			Else
				aPeriodos := oDatas[cData]["periodos"]
				nTotalPer := Len(aPeriodos)

				For nIndexPer := 1 To nTotalPer
					aPeriodo := aPeriodos[nIndexPer]

					If aPeriodo[ARRAY_HZK_INICIO] >= nFimVld
						aAdd(aAlocaveis, Self:criaJsonPeriodo(dDataVld, nIniVld, nFimVld))
						Exit
					EndIf

					If aPeriodo[ARRAY_HZK_INICIO] >= nIniVld

						If aPeriodo[ARRAY_HZK_INICIO] > nIniVld
							aAdd(aAlocaveis, Self:criaJsonPeriodo(dDataVld, nIniVld, aPeriodo[ARRAY_HZK_INICIO]))
						EndIf

						If aPeriodo[ARRAY_HZK_FIM] > nFimVld
							aAdd(aInvalidos, Self:criaJsonPeriodo(dDataVld, aPeriodo[ARRAY_HZK_INICIO], nFimVld))
							Exit
						Else
							aAdd(aInvalidos, Self:criaJsonPeriodo(dDataVld, aPeriodo[ARRAY_HZK_INICIO], aPeriodo[ARRAY_HZK_FIM]))

							If aPeriodo[ARRAY_HZK_FIM] <= nFimVld
								nIniVld := aPeriodo[ARRAY_HZK_FIM]
							EndIf
						EndIf
					Else
						If aPeriodo[ARRAY_HZK_FIM] > nIniVld
							If aPeriodo[ARRAY_HZK_FIM] >= nFimVld
								aAdd(aInvalidos, Self:criaJsonPeriodo(dDataVld, nIniVld, nFimVld))
								Exit
							Else
								aAdd(aInvalidos, Self:criaJsonPeriodo(dDataVld, nIniVld, aPeriodo[ARRAY_HZK_FIM]))
								nIniVld := aPeriodo[ARRAY_HZK_FIM]
							EndIf
						EndIf
					EndIf

					If (nFimVld - nIniVld) == 0
						Exit
					EndIf

					If nIndexPer == nTotalPer
						aAdd(aAlocaveis, Self:criaJsonPeriodo(dDataVld, nIniVld, nFimVld))
					EndIf
				Next
			EndIf
		Else
			aAdd(aAlocaveis, Self:criaJsonPeriodo(dDataVld, nIniVld, nFimVld))
		EndIf
	Next

	aSize(aValida, 0)
	nTotal := Len(aInvalidos)

	For nIndex := 1 To nTotal
		aAdd(aValida, aInvalidos[nIndex])
	Next

Return aAlocaveis

/*/{Protheus.doc} criaJsonPeriodo
Cria um JsonObject com os dados de um periodo.
@author Lucas Fagundes
@since 21/07/2025
@version P12
@param dData   , Date    , Data do periodo.
@param nHoraIni, Numerico, Hora inicial do periodo.
@param nHoraFim, Numerico, Hora final do periodo.
@return oPeriodo, Object, JsonObject com os dados do periodo.
/*/
Method criaJsonPeriodo(dData, nHoraIni, nHoraFim) Class PCPA152Ferramenta
	Local oPeriodo := JsonObject():New()

	oPeriodo["data"      ] := dData
	oPeriodo["horaInicio"] := nHoraIni
	oPeriodo["horaFim"   ] := nHoraFim

Return oPeriodo

/*/{Protheus.doc} ajustaArrayPeriodos
Ajusta o array de periodos, ordenando e unindo os periodos que estão consecutivos.
@author Lucas Fagundes
@since 22/07/2025
@version P12
@param aPeriodos, Array, Array com os periodos que serão ajustados (retorna por referencia os periodos ajustados).
@return Nil
/*/
Method ajustaArrayPeriodos(aPeriodos) Class PCPA152Ferramenta
	Local nIndex    := 2
	Local nTotal    := Len(aPeriodos)
	Local nAnterior := 0

	aSort(aPeriodos,,,{|x,y| x["data"      ] <  y["data"      ]  .Or.;
	                        (x["data"      ] == y["data"      ] .And.;
	                         x["horaInicio"] <  y["horaInicio"])})

	While nIndex <= nTotal
		nAnterior := nIndex - 1

		If aPeriodos[nAnterior]["data"   ] == aPeriodos[nIndex]["data"      ] .And.;
		   aPeriodos[nAnterior]["horaFim"] == aPeriodos[nIndex]["horaInicio"]

			aPeriodos[nAnterior]["horaFim"] := aPeriodos[nIndex]["horaFim"]
			aDel(aPeriodos, nIndex)

			nTotal--
			Loop
		EndIf

		nIndex++
	End
	aSize(aPeriodos, nTotal)

Return Nil
