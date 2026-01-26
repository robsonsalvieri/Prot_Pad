#INCLUDE 'protheus.ch'
#INCLUDE 'MrpDominio.ch'

#DEFINE ARRAY_FILIAIS_FILIAL              1
#DEFINE ARRAY_FILIAIS_PRIORIDADE          2
#DEFINE ARRAY_FILIAIS_TAMANHO             2

#DEFINE TRANF_POS_FILIAL_DESTINO          1
#DEFINE TRANF_POS_FILIAL_ORIGEM           2
#DEFINE TRANF_POS_PRODUTO                 3
#DEFINE TRANF_POS_DATA                    4
#DEFINE TRANF_POS_QUANTIDADE              5
#DEFINE TRANF_POS_DOCUMENTO               6
#DEFINE TRANF_POS_DATA_RECEBIMENTO        7
#DEFINE TRANF_POS_DOCUM_ORIGEM            8
#DEFINE TRANF_TAMANHO                     8

#DEFINE ABAIXA_POS_CHAVE                  1
#DEFINE ABAIXA_POS_DOCPAI                 2
#DEFINE ABAIXA_POS_NECESSIDADE            3
#DEFINE ABAIXA_POS_QTD_ESTOQUE            4
#DEFINE ABAIXA_POS_CONSUMO_ESTOQUE        5
#DEFINE ABAIXA_POS_QTD_SUBSTITUICAO       6
#DEFINE ABAIXA_POS_QUEBRAS_QUANTIDADE     7
#DEFINE ABAIXA_POS_TIPO_PAI               8
#DEFINE ABAIXA_POS_NEC_ORIG               9
#DEFINE ABAIXA_POS_REGRA_ALT             10
#DEFINE ABAIXA_POS_CHAVE_SUBST           11
#DEFINE ABAIXA_POS_TRANSFERENCIA_ENTRADA 12
#DEFINE ABAIXA_POS_TRANSFERENCIA_SAIDA   13
#DEFINE ABAIXA_POS_DOCFILHO              14
#DEFINE ABAIXA_POS_RASTRO_AGLUTINACAO    15
#DEFINE ABAIXA_SIZE                      15

Static snTamCod := 90

/*/{Protheus.doc} MrpDominio_MultiEmpresa
Processamentos do Multi-empresa

@author    lucas.franca
@since     11/09/2020
@version   P12
/*/
CLASS MrpDominio_MultiEmpresa FROM LongNameClass

	DATA aFiliais         AS ARRAY
	DATA lUsaMultiEmpresa AS LOGICAL
	DATA nTotalFiliais    AS NUMERIC
	DATA nTamanhoFilial   AS NUMERIC
	DATA oDados           AS OBJECT
	DATA oDominio         AS OBJECT //Instância da classe de domínio (MRPDOMINIO)
	DATA oParametros      AS OBJECT //Instância dos parâmetros
	DATA oCachexFilial    AS OBJECT

	METHOD new(oDominio) CONSTRUCTOR
	METHOD alternativosMultiEmpresa(cFilAux, cProduto, nPeriodo, cIDOpc, aBaixaPorOP, nQtdNec, lWait, aMinMaxAlt)
	METHOD buscaFilialEstrutura(cFilAux, cProduto, nPeridodo, cIDOpc)
	METHOD carregaArrayFiliais()
	METHOD carregaCacheFiliais()
	METHOD consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, nSaldo, lWait, nQtTotTran, lTransfere, lSemTran, lPrdAlt, aTransf)
	METHOD desfazSaidaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aBaixaPorOP, nQtrSai, nSaldo, lForcaTran)
	METHOD desfazEntradaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aDados, cChvCheck, lEfetiva, cPrdLoop)
	METHOD filialPorIndice(nIndex)
	METHOD getFilialTabela(cTabela, cFilAux)
	METHOD gravaDadosTransferencia(cFilDes, cFilOri, cProduto, cPeriodo, cDocumento, nQtdTran, lProducao, cRecebTran, cDocOrigem)
	METHOD novoIdTransferencia()
	METHOD processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,aBaixaPorOP,nQtdNec,nQtdTran)
	METHOD queryFilial(cTable, cField, lAddTable, cAlias)
	METHOD retornaFiliais()
	METHOD retornaDadosTransferenciaDocumento(cDocumento, cFilDest, cDocOrigem)
	METHOD retornaTransferenciaEstoque(cChaveMat, nTotalTran)
	METHOD tamanhoFilial()
	METHOD totalDeFiliais()
	METHOD utilizaMultiEmpresa()
ENDCLASS

/*/{Protheus.doc} new
Metodo construtor

@author lucas.franca
@since 11/09/2020
@version P12
Return Self, objeto, instancia desta classe
/*/
METHOD new(oDominio) CLASS MrpDominio_MultiEmpresa
	Self:aFiliais         := Nil
	Self:lUsaMultiEmpresa := Nil
	Self:nTotalFiliais    := 0
	Self:nTamanhoFilial   := -1
	Self:oDominio         := oDominio
	Self:oParametros      := oDominio:oParametros
	Self:oDados           := oDominio:oDados
	Self:oCachexFilial    := Nil
Return Self

/*/{Protheus.doc} carregaArrayFiliais
Carrega o array de filiais para processamento.
Filial com prioridade 0 é a filial centralizadora. As demais filiais serão as filiais centralizadas.

@author lucas.franca
@since 11/09/2020
@version P12
/*/
METHOD carregaArrayFiliais() CLASS MrpDominio_MultiEmpresa
	Local aFilCent := {}
	Local nIndex   := 0
	Local nTotal   := 0
	Local nSizeFil := 0

	If Self:aFiliais == Nil
		Self:aFiliais := {}

		If Self:oParametros["branchCentralizing"] != Nil .And. Self:oParametros["centralizedBranches"] != Nil
			aFilCent := StrToKArr(Self:oParametros["centralizedBranches"], "|")
			nTotal   := Len(aFilCent)

			If nTotal > 0
				nSizeFil            := FwSizeFilial()
				Self:nTamanhoFilial := nSizeFil

				aAdd(Self:aFiliais, {PadR(Self:oParametros["branchCentralizing"], nSizeFil), 0})
			Else
				Self:nTamanhoFilial := 0
			EndIf
			For nIndex := 1 To nTotal
				aAdd(Self:aFiliais, {PadR(aFilCent[nIndex], nSizeFil), nIndex})
			Next nIndex

			aSize(aFilCent, 0)
		EndIf
	EndIf
Return

/*/{Protheus.doc} carregaCacheFiliais
Carrega cache de filiais (xFilial) para utilização em buscas nas tabelas do cálculo.

@author lucas.franca
@since 14/10/2020
@version P12
/*/
METHOD carregaCacheFiliais() CLASS MrpDominio_MultiEmpresa
	Local cFil   := ""
	Local nIndex := 0

	If Self:oCachexFilial == Nil .And. Self:utilizaMultiEmpresa()
		Self:oCachexFilial := JsonObject():New()

		For nIndex := 1 To Self:totalDeFiliais()
			cFil := Self:filialPorIndice(nIndex)
			Self:oCachexFilial["T4N" + cFil] := xFilial("T4N", cFil)
		Next nIndex
	EndIf
Return

/*/{Protheus.doc} getFilialTabela
Recupera a filial para utilização em busca da tabela

@author lucas.franca
@since 14/10/2020
@version P12
@param cTabela, character, Tabela utilizada
@param cFilAux, character, Código da filial utilizada.
/*/
METHOD getFilialTabela(cTabela, cFilAux) CLASS MrpDominio_MultiEmpresa
	Local cFilRet := cFilAux

	If Self:oCachexFilial[cTabela + cFilAux] != Nil
		cFilRet := Self:oCachexFilial[cTabela + cFilAux]
	EndIf

Return cFilRet

/*/{Protheus.doc} totalDeFiliais
Retorna a quantidade total de filiais para processar

@author lucas.franca
@since 06/10/2020
@version P12
@return nTotal, Numeric, Total de filiais
/*/
METHOD totalDeFiliais() CLASS MrpDominio_MultiEmpresa
	If Self:lUsaMultiEmpresa == Nil
		Self:utilizaMultiEmpresa()
	EndIf
Return Self:nTotalFiliais

/*/{Protheus.doc} filialPorIndice
Retorna o código da filial de processamento por índice

@author lucas.franca
@since 06/10/2020
@version P12
@return cFilIdx, Character, Filial correspondente ao índice
/*/
METHOD filialPorIndice(nIndex) CLASS MrpDominio_MultiEmpresa
	Local cFilIdx := Nil

	If Self:lUsaMultiEmpresa == Nil
		Self:utilizaMultiEmpresa()
	EndIf
	If nIndex <= Self:nTotalFiliais
		cFilIdx := Self:aFiliais[nIndex][ARRAY_FILIAIS_FILIAL]
	EndIf
Return cFilIdx

/*/{Protheus.doc} retornaFiliais
Retorna as filiais que devem ser consideradas no processamento do MRP

@author lucas.franca
@since 11/09/2020
@version P12
@return aFiliais, Array, Array com as filiais para processamento.
/*/
METHOD retornaFiliais() CLASS MrpDominio_MultiEmpresa
	Local aFiliais := {}

	If Self:utilizaMultiEmpresa()
		aFiliais := Self:aFiliais
	EndIf

Return aFiliais

/*/{Protheus.doc} utilizaMultiEmpresa
Verifica se o MRP está parametrizado para execução com multi-empresas

@author lucas.franca
@since 11/09/2020
@version P12
@return lUsaME, Logic, Indica se o Multi-empresa está habilitado ou não.
/*/
METHOD utilizaMultiEmpresa() CLASS MrpDominio_MultiEmpresa
	Local lUsaME := .F.

	If Self:lUsaMultiEmpresa == Nil
		Self:lUsaMultiEmpresa := .F.
		//Se existirem os parâmetros de filial centralizada/filiais centralizadoras, verifica se é multi-empresa.
		If Self:oParametros["branchCentralizing"] != Nil .And. Self:oParametros["centralizedBranches"] != Nil .And. FwAliasInDic("SMB", .F.)
			//Carrega o array de filiais de acordo com os parâmetros recebidos.
			Self:carregaArrayFiliais()

			//Se existir mais de uma filial para processamento, considera que o MRP é Multi-empresa.
			Self:nTotalFiliais := Len(Self:aFiliais)
			If Self:nTotalFiliais > 1
				Self:lUsaMultiEmpresa := .T.
			EndIf
		EndIf

		If Self:lUsaMultiEmpresa
			Self:carregaCacheFiliais()
		EndIf

	EndIf
	lUsaME := Self:lUsaMultiEmpresa

Return lUsaME

/*/{Protheus.doc} consumirEstoqueME
Verifica e consome o estoque das outras filiais conforme prioridade

@author ricardo.prandi
@since 11/11/2020
@version P12
@param 01 cFilAux   , Character, Filial que está sendo processada
@param 02 cProduto  , Character, Código do produto que está sendo processado
@param 03 nPeriodo  , Numeric  , Número do período que está sendo processado
@param 04 cIDOpc    , Character, Id do opcional relacionado
@param 05 nSaldo    , Numeric  , Saldo a ser verifica nas outras filiais
@param 06 lWait     , Logic    , Retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 07 nQtTotTran, Numeric  , Retorna a quantidade total de transferÊncia efetuada
@param 08 lTransfere, Logic    , Identifica se deve transferir, ou somente verificar se existe saldo a transferir.
@param 09 lSemTran  , Logic    , Identifica que as tentativas de buscar saldo deste produto em outras filiais se esgotaram, e não deve ser
                                 realizada nova tentativa de consumo de estoque neste cálculo (retorna por referência)
@param 10 lPrdAlt   , Logic    , Indica que está fazendo transferências para a regra de produtos alternativos
@param 11 aTransf   , Array    , Retorna por referência informações de filial e quantidade transferida
@param 12 cForcTrFil, Character, Indica a filial que deve ser transferido o saldo independente do lote mínimo de transferência
@return nSaldo, Numeric, Retorna a quantidade restante de necessidade do produto
/*/
METHOD consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, nSaldo, lWait,;
                         nQtTotTran, lTransfere, lSemTran, lPrdAlt, aTransf, cForcTrFil) CLASS MrpDominio_MultiEmpresa
	Local aRetAux     := {}
	Local aAreaPRD    := Self:oDados:retornaArea("PRD")
	Local cChaveLog   := ""
	Local cChaveMAT   := ""
	Local cChaveOrig  := cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
	Local cChaveProd  := ""
	Local cMatrizOri  := ""
	Local cDtTrans    := ""
	Local dDtTrans    := ""
	Local cChaveWait  := ""
	Local cChaveAlt   := ""
	Local lCalculado  := .F.
	Local lErrorMat   := .F.
	Local lErrorPrd   := .F.
	Local lEncerra    := .F.
	Local lError      := .F.
	Local lPermTrans  := .T.
	Local nIndFil     := 1
	Local nLotMinTrf  := 0
	Local nPerAux     := 1
	Local nPerTran    := nPeriodo
	Local nQtdTran    := 0
	Local nSaldoFil   := 0
	Local nSobra      := 0
	Local nSaldoNec   := 0
	Local nTentativa  := 0
	Local nThrPrd     := 0
	Local nPerCal     := 0
	Local oTranfDisp  := Nil

	Default lWait      := .F.
	Default lSemTran   := .F.
	Default lTransfere := .T.
	Default lPrdAlt    := .F.

	nSaldo  := nSaldo * -1
	nSobra  := nSaldo
	aTransf := {}

	dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
	Self:oDominio:oLeadTime:aplicar(cFilAux, cProduto, cIDOpc, @nPerTran, @dDtTrans, .T. /*lTransfer*/, /*dLTReal*/)

	If lPrdAlt
		//Transferência realizada para substituição de alternativos
		//Utiliza o oTranfDisp para identificar quantidades de transferências
		//que já foram realizadas e reutiliza essas transferências.
		oTranfDisp := Self:oDominio:oAlternativo:oTranfDisp
	EndIf

	nLotMinTrf := Self:oDados:retornaCampo("PRD", 1, cFilAux + cProduto, "PRD_LMTRAN", @lErrorPrd)
	If lErrorPrd .Or. nLotMinTrf < 1
		nLotMinTrf := 0
	Else
		If Self:oDados:oLogs:logAtivado() .And. Empty(cForcTrFil)
			cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
			Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Produto com lote minimo de transferencia para a filial " + cFilAux + " de " + cValToChar(nLotMinTrf) + " (HZ8)"}, .F. /*lWrite*/)
		EndIf
	EndIf

	//Percorre o array de filiais para buscar os estoques
	For nIndFil := 1 To Self:nTotalFiliais
		//Se for a mesma filial da origem, vai para a próxima filial
		If Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] == cFilAux
			Loop
		Endif

		If !Empty(cForcTrFil) .And. cForcTrFil <> Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL]
			Loop
		EndIf

		lPermTrans := Self:oDados:retornaCampo("PRD", 1, Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto, "PRD_TRANSF", @lErrorPrd) == "1"
		If !lErrorPrd .And. !lPermTrans
			If Self:oDados:oLogs:logAtivado()
				cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
				Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Ignorada a filial " + cValToChar(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL]) + " pois esta parametrizada para nao transferir este produto (HZ8)"}, .F. /*lWrite*/)
			EndIf
			Loop
		EndIf

		If lPrdAlt
			cChaveAlt := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + RTrim(cProduto)
			If oTranfDisp:HasProperty(cChaveAlt) .And. oTranfDisp[cChaveAlt] > 0
				//Se for produto alternativo e existir dados em Self:oDominio:oAlternativo:oTranfDisp,
				//indica que já existem transferências realizadas. Não é necessário criar uma nova.
				nSaldoFil  := oTranfDisp[cChaveAlt]
				nSobra     := nSaldo - nSaldoFil
				nSobra     := If(nSobra < 0, 0, nSobra)
				nQtdTran   := nSaldo-nSobra
				nQtTotTran += nQtdTran
				nSaldo     := nSobra

				If lTransfere
					oTranfDisp[cChaveAlt] -= nQtdTran
				EndIf
			EndIf
		EndIf

		If nSaldo > 0
			cChaveProd := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")

			nPerTran := Self:oDominio:oPeriodos:buscaPeriodoDaData(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] , dDtTrans, .T.)
			dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] , nPerTran)
			cDtTrans := DtoS(dDtTrans)

			//Percorre período até achar saldo
			For nPerAux := nPerTran to 1 step -1
				cChaveMAT  := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nPerAux)) + cChaveProd
				lErrorMat  := .F.
				Self:oDados:retornaCampo("MAT" , 1, cChaveMAT, "MAT_SALDO", @lErrorMat)

				If !lErrorMat
					lCalculado := Self:oDados:foiCalculado(cChaveProd, nPerAux, /*lAvMinimo*/, @nPerCal)
					If !lCalculado
						nThrPrd := Self:oDados:oProdutos:getflag("PROD_THREAD_PER_CAL" + RTrim(cChaveProd), .F., .F.)
						If !Empty(nThrPrd) .And. nThrPrd == ThreadID() .And. nPerCal+1 == nPerAux
							lCalculado := .T.
						EndIf
					EndIf
					If lCalculado
						If Self:oDados:reservaProduto(cChaveProd)

							aRetAux   := ::oDados:retornaCampo("MAT", 1, cChaveMAT, {"MAT_NECESS","MAT_SALDO"}, @lErrorMat, , , , , , .T. /*lVarios*/)
							If nPerAux == nPeriodo
								//Período atual, considera o saldo final do período.
								nSaldoFil := aRetAux[2]
								nSaldoFil -= Self:oDominio:oRastreio:necPPed_ES(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux)
								nSaldoNec := 0
							Else
								//Período anterior, considera o saldo que será gerado para o próximo período.
								nSaldoFil := aRetAux[2]
								nSaldoFil += aRetAux[1]
								nSaldoFil -= Self:oDominio:oRastreio:necPPed_ES(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux)
								nSaldoNec := nSaldoFil - aRetAux[2]
							EndIf

							aSize(aRetAux, 0)

							If nSaldoFil > 0
								nSobra := nSaldo - nSaldoFil
								nSobra := If(nSobra < 0, 0, nSobra)

								nQtdTran := nSaldo-nSobra

								If nLotMinTrf > 1
									//Verifica se deverá considerar o lote mínimo ou transferir o que tiver (caso tenha saldo menor que o lote)
									If Empty(cForcTrFil)
										//Precisará transferir o lote mínimo, mas não possui esse saldo na filial
										If nLotMinTrf > nSaldoFil
											nQtdTran := 0
											nSobra   := nSaldo - nQtdTran

											If Self:oDados:oLogs:logAtivado()
												cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
												Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Nao sera transferido o saldo em estoque de " + cValToChar(nSaldoFil) + " da filial " + Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + " (lote minimo de transferencia)"}, .F. /*lWrite*/)
											EndIf

											Self:oDados:liberaProduto(cChaveProd)
											Exit

										//Possui saldo suficiente para transferir toda a quantidade, mas o lote mínimo é maior que a necessidade
										ElseIf nLotMinTrf > nQtdTran
											nQtdTran := nLotMinTrf

											If Self:oDados:oLogs:logAtivado()
												cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
												Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Sera feita a transferencia de estoque de " + cValToChar(nQtdTran) + " da filial " + Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + " (lote minimo de transferencia)"}, .F. /*lWrite*/)
											EndIf
										EndIf

										nSobra := nSaldo - nQtdTran
									Else
										If Self:oDados:oLogs:logAtivado()
											cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
											Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Sera transferido o saldo em estoque de " + cValToChar(nSaldoFil) + " da filial " + cForcTrFil + ". O restante sera produzido."}, .F. /*lWrite*/)
										EndIf
									EndIf
								EndIf
								nQtTotTran += nQtdTran

								If lTransfere
									//Grava Matriz do produto a ser transferido
									cChaveMAT  := cDtTrans + cChaveProd
									cMatrizOri := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cChaveOrig

									Self:oDados:oMatriz:trava(cChaveMAT)
									Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdTran, -nQtdTran}, .F., .T., /*08*/, .T.)

									If Empty(cIdOpc)
										Self:oDominio:oOpcionais:separaIdChaveProduto(@cProduto, @cIdOpc)
									EndIf

									If Self:oDados:oLogs:logAtivado()
										cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
										Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Transferido " + cValToChar(nQtdTran) + " da filial " + Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + " (onde o produto possui saldo)"}, .F. /*lWrite*/)

										cChaveLog := Self:oDados:oLogs:montaChaveLog(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, cIDOpc, nPerTran)
										Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Transferido " + cValToChar(nQtdTran) + " para a filial " + cFilAux + " (pois possui saldo em estoque)"}, .F. /*lWrite*/)
									EndIf

									Self:oDominio:oRastreio:incluiNecessidade(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL],;
									                                          "TRANF_ES"                                  ,;
									                                          cMatrizOri                                  ,;
									                                          cProduto                                    ,;
									                                          cIDOpc                                      ,;
									                                          /*cTRT*/                                    ,;
									                                          0                                           ,;
									                                          nPerTran                                    ,;
									                                          /*cListOrig*/                               ,;
									                                          /*cRegra*/                                  ,;
									                                          /*cOrdSubst*/                               ,;
									                                          /*cRoteiro*/                                ,;
									                                          /*cOperacao*/                               ,;
									                                          /*nQtrEnt*/                                 ,;
									                                          nQtdTran                                    ,;
									                                          /*cDocFilho*/                               ,;
									                                          nSaldoFil                                    )

									If nSaldoNec > 0
										//Quando utiliza um saldo que sobrou de uma necessidade, não é necessário
										//recalcular o período atual do produto, apenas os próximos.
										Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran+1)
										If !Self:oDados:oMatriz:existList("Periodos_Produto_" + cChaveProd)
											Self:oDados:oMatriz:createList("Periodos_Produto_" + cChaveProd)
										EndIf
										If nPeriodo+1 < nPerTran
											Self:oDados:oMatriz:setItemList("Periodos_Produto_" + cChaveProd, cValToChar(nPerTran+1), nPerTran+1)
										EndIf
									Else
										Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran)
									EndIf
									Self:oDados:oMatriz:destrava(cChaveMAT)
									Self:oDados:decrementaTotalizador(cChaveProd)

									//Grava Matriz do produto origem
									Self:oDados:gravaCampo("MAT", 1, cMatrizOri, {"MAT_QTRENT", "MAT_SALDO"}, {nQtdTran, nQtdTran}, .F., .T., /*08*/, .T.)

									Self:gravaDadosTransferencia(cFilAux, Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, cDtTrans, cMatrizOri, nQtdTran, .F., DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)))

									//Grava array de transferências realizadas para gravar os dados na global
									//e reutilizar no objeto oTranfDisp dos produtos alternativos.
									aAdd(aTransf, {Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nQtdTran})
								EndIf
							EndIf

							Self:oDados:liberaProduto(cChaveProd)
							Exit
						Else
							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf
							lWait := .T.
							Exit
						EndIf
					Else
						cChaveWait := Self:oDados:oProdutos:getFlag("|WaitRecalculo|"+cChaveOrig+"|", @lError)
						If !lError .And. cChaveWait == cChaveProd
							Self:oDados:oProdutos:setFlag("|WaitRecalculoCount|"+cChaveOrig+"|", @nTentativa,,,,.T.)

							If nTentativa >= 10
								lEncerra := .T.
							EndIf
						EndIf

						If !lEncerra
							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf

							Self:oDados:oProdutos:setFlag("|WaitRecalculo|"+cChaveOrig+"|", cChaveProd, @lError)

							lWait := .T.
						EndIf

						Exit
					EndIf
				Else
					nSaldoFil := Self:oDominio:saldoInicial(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc)
					If nSaldoFil > 0
						If !Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc) .And. Self:oDados:oMatriz:trava(cChaveMAT)

							//Decrementa totalizador relacionado ao oDominio:loopNiveis
							If !Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, , , , cIDOpc) .or. !Self:oDados:possuiPendencia(cChaveProd, .T.)
								Self:oDados:decrementaTotalizador(cChaveProd)
							EndIf

							//"Inclui novo registro na Matriz: " + " - Periodo: " + " - nNecessidade: "
							Self:oDados:atualizaMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], Self:oDominio:oPeriodos:retornaDataPeriodo(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], nPerAux), cProduto, Nil, {"MAT_SLDINI", "MAT_SALDO"}, {nSaldoFil, nSaldoFil},,,,.F.)
							Self:oDados:gravaPeriodosProd(cChaveProd, nPerAux)
							Self:oDados:oMatriz:destrava(cChaveMAT)
							lWait := .T.

							If Self:oDominio:oParametros["nThreads"] > 1
								Self:oDados:oLiveLock:setResult(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto , 1, .F., .T., .T.)
							EndIf

							Exit
						ElseIf Self:oDados:existeMatriz(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPerAux, , cIDOpc)
							nPerAux++
							Loop
						EndIf
					Else
						Loop
					EndIf
				EndIf
			Next nPerAux
		EndIf

		nSaldo := nSobra

		If lWait .Or. nSobra <= 0 .Or. lEncerra
			Exit
		EndIf
	Next nIndFil

	If !lWait
		Self:oDados:oProdutos:setFlag("|WaitRecalculo|"+cChaveOrig+"|", "", @lError)
		Self:oDados:oProdutos:setFlag("|WaitRecalculoCount|"+cChaveOrig+"|", 0, @lError)
	EndIf

	If lEncerra
		//Se lEncerra = .T., indica que as tentativas de buscar saldo deste produto
		//em outra filial se esgotaram. Portanto, lSemTran := .T. irá indicar que neste cálculo
		//do MRP não deve ser executada nova chamada do consumirEstoqueME.
		lSemTran := .T.
	Else
		//Se lEncerra = .F., indica que ainda podem ser realizadas tentativas de buscar
		//o saldo deste produto em outras filiais.
		lSemTran := .F.
	EndIf

	Self:oDados:setaArea(aAreaPRD)
	aSize(aAreaPRD, 0)

	nSaldo := nSaldo * -1

Return nSaldo

/*/{Protheus.doc} gravaDadosTransferencia
Verifica e consome o estoque das outras filiais conforme prioridade

@author ricardo.prandi
@since 11/11/2020
@version P12
@param 01 cFilDes   , Character, Filial destino da transferência
@param 02 cFilOri   , Character, Filial origem da transferência
@param 03 cProduto  , Character, Produto que está sendo transferido
@param 04 cPeriodo  , Character, Data da transferência
@param 05 cDocumento, Character, Documento usado na trasferência
@param 06 nQtdTran  , Numeric  , Quantidade transferida
@param 07 lProducao , Logic    , Indica que é uma transferência do tipo TRANF_PR.
@param 08 cRecebTran, Character, Data de recebimento da transferência na filial destino
@param 09 cDocOrigem, Character, Código do documento de origem que está gerando a transferência de produção
@return nil
/*/
METHOD gravaDadosTransferencia(cFilDes, cFilOri, cProduto, cPeriodo, cDocumento, nQtdTran, lProducao, cRecebTran, cDocOrigem) CLASS MrpDominio_MultiEmpresa
	Local aDados    := {}
	Local aTransf   := {}
	Local cChave  	:= cProduto + cFilDes + cFilOri + cPeriodo + cDocumento
	Local lError    := .F.
	Local oTransf 	:= Self:oDados:oTransferencia

	Default cDocOrigem := ""

	If oTransf:getRow(1, cChave, Nil, @aDados, .F., .T.)
		aDados[TRANF_POS_QUANTIDADE] += nQtdTran

		oTransf:updRow(1, cChave, Nil, aDados, .F., .T.)
	Else
		aDados := Array(TRANF_TAMANHO)

		aDados[TRANF_POS_FILIAL_DESTINO  ] := cFilDes
		aDados[TRANF_POS_FILIAL_ORIGEM   ] := cFilOri
		aDados[TRANF_POS_PRODUTO         ] := cProduto
		aDados[TRANF_POS_DATA            ] := cPeriodo
		aDados[TRANF_POS_QUANTIDADE      ] := nQtdTran
		aDados[TRANF_POS_DOCUMENTO       ] := cDocumento
		aDados[TRANF_POS_DATA_RECEBIMENTO] := cRecebTran
		aDados[TRANF_POS_DOCUM_ORIGEM    ] := cDocOrigem

		oTransf:addRow(cChave, aDados)
	EndIf

	If lProducao
		oTransf:setFlag("TRF_DOCS" + CHR(13) + cDocumento, cChave, @lError)
	Else
		aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cDocumento, @lError)
		If lError
			aTransf := {cChave}
			lError  := .F.
		Else
			aAdd(aTransf, cChave)
		EndIf
		oTransf:setItemAList("TRANSF_ESTOQUE", cDocumento, aTransf, @lError, .F., .F.)
		aSize(aTransf, 0)
	EndIf

	aSize(aDados, 0)

Return Nil

/*/{Protheus.doc} queryFilial
Monta filtro de filial para query de acordo com as filiais utilizadas no cálculo.

@author lucas.franca
@since 06/10/2020
@version P12
@param 01 cTable   , Character, Tabela que será feita o filtro de filial.
@param 02 cField   , Character, Coluna de filial utilizada para filtro.
@param 03 lAddTable, Logic    , Identifica se deve adicionar o nome da tabela como Alias.
@param 04 cAlias   , Character, Alias para utilizar na tabela.
@return cQuery  , Character, Query formatada para filtro das filiais.
/*/
METHOD queryFilial(cTable, cField, lAddTable, cAlias) CLASS MrpDominio_MultiEmpresa
	Local cQuery := cField
	Local nIndex := 0
	Local nTotal := 0

	Default cAlias := cTable

	If Self:utilizaMultiEmpresa()
		cQuery += " IN ("
		nTotal := Len(Self:aFiliais)
		For nIndex := 1 To nTotal
			If nIndex > 1
				cQuery += ","
			EndIf
			cQuery += "'" + xFilial(cTable, Self:aFiliais[nIndex][ARRAY_FILIAIS_FILIAL]) + "'"
		Next nIndex
		cQuery += ")"
	Else
		cQuery += " = '" + xFilial(cTable) + "' "
	EndIf

	If lAddTable
		cQuery := cAlias + "." + cQuery
	EndIf
Return cQuery

/*/{Protheus.doc} tamanhoFilial
Retorna o tamanho que deve ser considerado para a informação da filial

@author lucas.franca
@since 08/10/2020
@version P12
@return Self:nTamanhoFilial
/*/
METHOD tamanhoFilial() CLASS MrpDominio_MultiEmpresa

	If Self:nTamanhoFilial == -1
		If Self:utilizaMultiEmpresa()
			Self:nTamanhoFilial := Len(Self:aFiliais[1][ARRAY_FILIAIS_FILIAL])
		Else
			Self:nTamanhoFilial := 0
		EndIf
	EndIf
Return Self:nTamanhoFilial

/*/{Protheus.doc} processaEstruturaMultiempresa
Busca se o produto possui estrutura em outra filial e gera as informação na MATRIZ e RASTREIO para o processamento

@author ricardo.prandi
@since 04/02/2021
@version P12
@param 01 cFilAux    , Character, Filial que está sendo processada
@param 02 cProduto   , Character, Código do produto que está sendo processado
@param 03 cIDOpc     , Character, Id do opcional relacionado
@param 04 nPeriodo   , Numeric  , Número do período que está sendo processado
@param 05 aBaixaPorOP, Array    , Informações da tabela de rastreio do produto que está sendo processado
@param 06 nQtdNec    , Numeric  , Quantidade da necessidade restante para ser processada
@param 07 nQtdTran   , Numeric  , Retorna a quatidade transferida
@return nQtdNec, Numeric, Retorna a quantidade restante de necessidade do produto
/*/
METHOD processaEstruturaMultiempresa(cFilAux,cProduto,cIDOpc,nPeriodo,aBaixaPorOP,nQtdNec,nQtdTran) CLASS MrpDominio_MultiEmpresa
	Local cChaveLog  := ""
	Local cChaveMAT  := ""
	Local cChaveProd := ""
	Local cFilOrigem := ""
	Local cProxId    := ""
	Local cDtTrans   := ""
	Local dDtTrans   := ""
	Local nPerTran   := nPeriodo
	Local nQtdTransf := 0
	Local nQtdNecOri := nQtdNec
	Local lEstrutura := .F.
	Local lError     := .F.
	Local lTemFilCom := .F.
	Local lWait      := .F.

 	nQtdTran   := 0
	//Primeiro verifica se o produto possui estrutura e em seguida se possui estrutura para o período
	lEstrutura := Self:oDados:oProdutos:getFlag("|PossuiEstrutura|" + cProduto + "|", @lError)

	If !lError .And. lEstrutura
		lEstrutura := Self:oDados:oProdutos:getFlag("|PossuiEstruturaPer|" + cProduto + CValToChar(nPeriodo) + cIDOpc + "|", @lError)
	EndIf

	//Possui estrutura em outra filial
	If !lError .And. lEstrutura
		cFilOrigem := Self:buscaFilialEstrutura(cFilAux, cProduto, nPeriodo, cIDOpc) 
	EndIf

	If Empty(cFilOrigem)
		lError     := .F.
		cFilOrigem := Self:oDados:retornaCampo("PRD", 1, cFilAux + cProduto, "PRD_FILCOM", @lError)

		//Possui filial de compra cadastrada para o produto
		If !lError .And. !Empty(cFilOrigem)
			If cFilOrigem <> cFilAux
				lTemFilCom := .T.
				If Self:oDados:oLogs:logAtivado()
					cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
					Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Produto com filial de compra cadastrada (HZ8)", ;
					                                                  "A compra sera realizada na filial " + AllTrim(cFilOrigem) + " e sera feita a transferencia de " + cValToChar(nQtdNec) + " para a filial " + AllTrim(cFilAux)}, .F. /*lWrite*/)
				EndIf
			Else
				cFilOrigem := ""
			EndIf
		EndIf
	EndIf

	lError     := .F.
	nLotMinTrf := Self:oDados:retornaCampo("PRD", 1, cFilAux + cProduto, "PRD_LMTRAN", @lError)
	If !lError .And. nLotMinTrf > 1
		If nLotMinTrf > nQtdNec
			nQtdNec := nLotMinTrf

			If Self:oDados:oLogs:logAtivado()
				cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
				Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Produto com lote minimo de transferencia de " + cValToChar(nLotMinTrf) + " (HZ8). Sera feita a transferencia de " + cValToChar(nQtdNec)}, .F. /*lWrite*/)
			EndIf
		EndIf
	EndIf

	If Empty(cFilOrigem)
		nQtdNec := nQtdNecOri - nQtdTransf
	Else
		nQtdNec    := Self:oDominio:oMultiEmp:consumirEstoqueME(cFilAux, cProduto, nPeriodo, cIDOpc, -nQtdNec, @lWait, @nQtdTransf, .T. /*lTransfere*/, /*lSemTran*/, /*lPrdAlt*/, /*aTransf*/, cFilOrigem) * -1
		nQtdTransf += nQtdNec

		dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)
		Self:oDominio:oLeadTime:aplicar(cFilAux, cProduto, cIDOpc, nPerTran, @dDtTrans, .T. /*lTransfer*/, /*dLTReal*/)
		nPerTran := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilOrigem, dDtTrans, .T.)
		dDtTrans := Self:oDominio:oPeriodos:retornaDataPeriodo(cFilOrigem, nPerTran)
		cDtTrans := DtoS(dDtTrans)
		If "|TRANF" $ "|"+aBaixaPorOP[ABAIXA_POS_DOCFILHO]
			cProxId := aBaixaPorOP[ABAIXA_POS_DOCFILHO]
		Else
			cProxId := Self:novoIdTransferencia()
			aBaixaPorOP[ABAIXA_POS_DOCFILHO] := cProxId
		EndIf
		aBaixaPorOP[ABAIXA_POS_TRANSFERENCIA_ENTRADA] += nQtdTransf

		//Grava filial destino
		cChaveMAT := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)) + cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
		Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRENT", "MAT_SALDO"}, {nQtdNec, nQtdNec}, .F., .T., /*08*/, .T.)
		cChaveProd := cFilOrigem + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
		cChaveMAT  := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilOrigem, nPerTran)) + cChaveProd

		If Self:oDados:oLogs:logAtivado()
			cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
			Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Transferido " + cValToChar(nQtdNec) + " da filial " + cFilOrigem + " (onde o produto sera " + IIf(lTemFilCom, "comprado", "produzido") + ")"}, .F. /*lWrite*/)
			cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilOrigem, cProduto, cIDOpc, nPerTran)
			Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Transferido " + cValToChar(nQtdNec) + " para a filial " + cFilAux + " (sem estoque, o produto sera " + IIf(lTemFilCom, "comprado", "produzido") + ")"}, .F. /*lWrite*/)
		EndIf

		//Grava filial origem
		Self:oDominio:oAglutina:preparaEInclui(cFilOrigem, "6", "TRANF_PR"                 , ;
		                                       {                                             ;
		                                        aBaixaPorOP[ABAIXA_POS_TIPO_PAI]           , ;
		                                        aBaixaPorOP[ABAIXA_POS_DOCPAI]             , ;
		                                        cProduto                                   , ;
		                                        aBaixaPorOP[ABAIXA_POS_DOCFILHO]             ;
		                                       }                                           , ;
		                                       cProxId, cProduto, cIDOpc, "", 0, nPerTran  , ;
		                                       /*cRegra*/, /*lAglutina*/, .F., /*cRoteiro*/, ;
		                                       /*cOperacao*/, /*nQtrEnt*/, nQtdNec, cProxId)

		If Self:oDados:oMatriz:trava(cChaveMAT)
			If Self:oDados:existeMatriz(cFilOrigem, cProduto, nPerTran, @cChaveMAT, cIDOpc)
				Self:oDados:gravaCampo("MAT", 1, cChaveMAT, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdNec, -nQtdNec}, .F., .T., /*08*/, .T.)
				If !Self:oDados:possuiPendencia(cFilOrigem+cProduto, .T., cIDOpc)
					Self:oDados:decrementaTotalizador(cChaveProd)
				EndIf
			Else
				Self:oDados:atualizaMatriz(cFilOrigem, Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerTran), cProduto, cIDOpc, {"MAT_QTRSAI", "MAT_SALDO"}, {nQtdTransf, -nQtdTransf})
			Endif
			Self:oDados:gravaPeriodosProd(cChaveProd, nPerTran)
			Self:oDados:oMatriz:destrava(cChaveMAT)
		EndIf
		Self:gravaDadosTransferencia(cFilAux, cFilOrigem, cProduto, cDtTrans, cProxId, nQtdNec, .T., DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo)), aBaixaPorOP[ABAIXA_POS_DOCPAI])
		nQtdTran := nQtdTransf
		nQtdNec  := 0
	EndIf

Return nQtdNec

/*/{Protheus.doc} buscaFilialEstrutura
Retorna a filial na qual o produto possui estrutura

@author ricardo.prandi
@since 04/02/2021
@version P12
@param 01 cFilAux    , Character, Filial que está sendo processada
@param 02 cProduto   , Character, Código do produto que está sendo processado
@param 03 nPeriodo   , Numeric  , Número do Período
@param 04 cIDOpc     , Character, Id do opcional relacionado
@return cFilEst, Character, Retorna a filial na qual o produto possui estrutura
/*/
METHOD buscaFilialEstrutura(cFilAux, cProduto, nPeriodo, cIDOpc) CLASS MrpDominio_MultiEmpresa
	Local aAreaPRD   := {}
	Local aDadosPRD  := {}
	Local lPermTrans := .T.
	Local cFilEst    := ""
	Local lEntraMRP  := .F.
	Local lError     := .F.
	Local lErrorPrd  := .F.
	Local nIndFil    := 0

	Default cIDOpc   := ""
    
	//Verifica se possui estrutura em outra filial para o período
	cFilEst := Self:oDados:oProdutos:getFlag("|FilialEstruturaPer|"+ cProduto + CValToChar(nPeriodo) + cIDOpc + "|", @lError)

	If lError .Or. Empty(cFilEst)
		aAreaPRD := Self:oDados:retornaArea("PRD")
		For nIndFil := 1 To Self:nTotalFiliais
			If Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] == cFilAux
				Loop
			Endif

			lErrorPrd := .F.
			aDadosPRD := ::oDados:retornaCampo("PRD", 1, Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL] + cProduto, {"PRD_TRANSF", "PRD_MRP"}, @lErrorPrd, .F., , /*lProximo*/, , , .T. /*lVarios*/)
			If !lErrorPrd
				lPermTrans := (aDadosPRD[1] == "1")
				lEntraMRP  := (aDadosPRD[2] $ " 1")
				aSize(aDadosPRD, 0)
			EndIf

			If lErrorPrd .Or. !lPermTrans .Or. !lEntraMRP
				Loop
			EndIf

			If Self:oDados:possuiEstrutura(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto)
				//Efetua validação para verificar se existe algum componente válido na estrutura do produto para o período
				lCompVld := CompValid(Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL], cProduto, nPeriodo, cIDOpc, Self:oDados, Self:oDominio) 
				If lCompVld
					cFilEst := Self:aFiliais[nIndFil][ARRAY_FILIAIS_FILIAL]
					Self:oDados:oProdutos:setFlag("|FilialEstruturaPer|"+ cProduto + CValToChar(nPeriodo) + cIDOpc + "|", cFilEst)
					Exit
				EndIf	
			EndIf
		Next nIndfil

		Self:oDados:setaArea(aAreaPRD)
		aSize(aAreaPRD, 0)

		If Empty(cFilEst)
			//Não encontrou estrutura válida em nenhuma filial, limpa a flag indicadora de produto com estrutura no período.
			Self:oDados:oProdutos:setFlag("|PossuiEstruturaPer|"+ cProduto + CValToChar(nPeriodo) + cIDOpc + "|", .F.)			
		EndIf
	Endif

Return cFilEst

/*/{Protheus.doc} novoIdTransferencia
Identifica o próximo código de transferência
@author    ricardo.prandi
@since     04/02/2020
@version   1
@return cProxId, caracter, próximo número de ordem de produção
/*/
METHOD novoIdTransferencia() CLASS MrpDominio_MultiEmpresa

	Local cProxId := ""
	Local lError  := .F.
	Local nVal    := 0

	Self:oDados:oTransferencia:setFlag("ProximoIdTransferencia", @nVal, @lError, , .T., .T.)

	If lError .Or. nVal < 1
		cProxId := "TRANF000001"
	Else
		cProxId := "TRANF" + strZero(nVal, 6)
	EndIf

Return cProxId

/*/{Protheus.doc} desfazSaidaTransferencias
Desfaz as transferências de saída já criadas para novo cálculo do produto
@author    ricardo.prandi
@since     19/02/2020
@version   1
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 cChaveOrig , Character, Chave da matriz do registro em processamento
@param 06 aBaixaPorOP, Array    , Array de rastreio com os dados do produto atual
@param 07 nQtrSai    , Numeric  , Quantidade de transferência de saída do produto atual. Retorna atualizado por referência.
@param 08 nSaldo     , Numeric  , Saldo do produto atual. Retorna atualizado por referência.
@param 09 lForcaTran , Logic    , Indica que a transferência de estoque deve ser desfeita sempre.
@return Nil
/*/
METHOD desfazSaidaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aBaixaPorOP, nQtrSai, nSaldo, lForcaTran) CLASS MrpDominio_MultiEmpresa
	Local aDocsPais  := {}
	Local aDadosChvs := {}
	Local aDadosTrf  := {}
	Local aIndBxAtu  := {}
	Local aRastreio  := {}
	Local aTransf    := {}
	Local aTranDisp  := {}
	Local cChave  	 := ""
	Local cChaveMat  := ""
	Local cChaveProd := ""
	Local cKey       := ""
	Local cList      := ""
	Local cFilDest   := ""
	Local lError     := .F.
	Local lTranfPR   := .F.
	Local lAglutina  := Self:oDominio:oAglutina:avaliaAglutinacao(cFilAux, cProduto)
	Local nIndex     := 0
	Local nIndRastro := 0
	Local nDesfez    := 0
	Local nQtdTran   := 0
	Local nQtdTrSaid := 0
	Local nIndPais   := 0
	Local nTotal     := Len(aBaixaPorOP)
	Local nTotTransf := 0
	Local nTotPais   := 0
	Local nTotRastro := 0
	Local nPos       := 0
	Local nPerDest   := nPeriodo
	Local nPosDocFil := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("DOCFILHO")
	Local nPosTrfEnt := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Local nPosChvSub := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("CHAVE_SUBSTITUICAO")
	Local nPosPeriod := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("PERIODO")
	Local nPosCompon := Self:oDominio:oRastreio:oDados_Rastreio:getPosicao("COMPONENTE")
	Local oTransf 	 := Self:oDados:oTransferencia
	Local oDadosRast := Self:oDominio:oRastreio:oDados_Rastreio

	/*
		lForcaTran indica que houve alteração no saldo inicial do período.
		Irá desfazer todas as transferências de saída existentes neste produto.
	*/
	If !lForcaTran
		For nIndex := 1 To nTotal
			If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR"
				nQtdTrSaid += aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			EndIf
			If aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_ES" .And. ;
			   aBaixaPorOP[nIndex][ABAIXA_POS_QTD_ESTOQUE] < aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
				nQtdTrSaid -= aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			EndIf
		Next nIndex
		If nQtdTrSaid > 0 .And. nSaldo + nQtdTrSaid >= 0
			Return
		EndIf
	EndIf

	For nIndex := 1 To nTotal
		//Se for transferência de estoque, irá desfazer.
		If aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] > 0 .And. ;
		   (aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_ES" .Or. ;
		    (aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR" .And. lForcaTran))

			lTranfPR := aBaixaPorOP[nIndex][ABAIXA_POS_TIPO_PAI] == "TRANF_PR"

			//Remove a transferência de saída do registro atual.
			nQtdTran   := aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA]
			aBaixaPorOP[nIndex][ABAIXA_POS_TRANSFERENCIA_SAIDA] := 0

			//Adiciona array de controle de atualização da global do aBaixaPorOP
			aAdd(aIndBxAtu, nIndex)

			//Busca os documentos pais para desfazer as transferências.
			aDocsPais := getDocsPai(cFilAux, nPeriodo, cProduto, cIDOpc, Self:oDominio:oAglutina, aBaixaPorOP[nIndex][ABAIXA_POS_DOCPAI], nQtdTran, lTranfPR, lAglutina)

			nTotPais := Len(aDocsPais)
			For nIndPais := 1 To nTotPais

				nTotTransf += aDocsPais[nIndPais][2]
				nQtdTran   := aDocsPais[nIndPais][2]
				//Elimina o registro de transferência (SMA)
				//Chave = Produto + filial destino + filial origem + data + documento
				If lTranfPR
					lError    := .F.
					cChave    := oTransf:getFlag("TRF_DOCS" + CHR(13) + aDocsPais[nIndPais][1], @lError)
					cFilDest  := SubStr(cChave, Len(cProduto)+1, Self:tamanhoFilial())
				Else
					cFilDest := SubStr(aDocsPais[nIndPais][1], 9, Self:tamanhoFilial())

					cChave := cProduto
					cChave += cFilDest
					cChave += cFilAux
					cChave += DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPeriodo))
					cChave += aDocsPais[nIndPais][1]

					cChaveMat := aDocsPais[nIndPais][1]
				EndIf

				//Antes de excluir a transferência, recuperar a data de recebimento da transferência
				//na filial destino, para considerar a data correta ao desfazer a Rastreabilidade (HWC).
				lError := .F.
				oTransf:getRow(1, cChave, Nil, @aDadosTrf, lError, .F.)
				If !lError
					nPerDest := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, StoD(aDadosTrf[TRANF_POS_DATA_RECEBIMENTO]), .F.)
					lError := .F.
					oTransf:delRow(1, cChave, @lError)
					aSize(aDadosTrf, 0)
				Else
					nPerDest := nPeriodo
				EndIf

				If lTranfPR
					cChaveMat := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(cFilAux, nPerDest)) + cFilDest + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
					oTransf:delFlag("TRF_DOCS" + CHR(13) + aDocsPais[nIndPais][1], @lError)
				Else
					lError  := .F.
					aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveMat, @lError)
					If !lError
						nPos := aScan(aTransf, {|x| x == cChave})
						If nPos > 0
							aDel(aTransf, nPos)
							aSize(aTransf, Len(aTransf)-1)
							oTransf:setItemAList("TRANSF_ESTOQUE", cChaveMat, aTransf, @lError, .F., .F.)
						EndIf

						aSize(aTransf, 0)
					EndIf
				EndIf

				//Busca o registro que recebeu o saldo de transferência para desfazer a entrada.
				//Remove da MATRIZ a transferência de entrada. (HWB)
				Self:oDados:gravaCampo("MAT", 1, cChaveMat, {"MAT_QTRENT", "MAT_SALDO"}, {-nQtdTran, -nQtdTran}, .F., .T., /*08*/, .T.)

				//Remove do RASTREIO a transferência de entrada. (HWC)
				aDadosChvs := buscaRastreio(cFilDest, cProduto, cIDOpc, nPerDest, Self:oDominio:oRastreio, @cList, .T.)

				nTotRastro := Len(aDadosChvs)

				For nIndRastro := 1 to nTotRastro
					cChave    := aDadosChvs[nIndRastro][1]
					aRastreio := aDadosChvs[nIndRastro][2]

					If !lTranfPR .Or. ;
					   (lTranfPR .And. aRastreio[nPosDocFil] == aDocsPais[nIndPais][1])

						nDesfez := aRastreio[nPosTrfEnt]
						If aRastreio[nPosTrfEnt] > 0
							If aRastreio[nPosTrfEnt] > nQtdTran
								aRastreio[nPosTrfEnt] -= nQtdTran
								nQtdTran := 0
							Else
								nQtdTran -= aRastreio[nPosTrfEnt]
								aRastreio[nPosTrfEnt] := 0
							EndIf
						EndIf

						nDesfez := nDesfez - aRastreio[nPosTrfEnt]

						If !Empty(aRastreio[nPosChvSub])
							//Possui transferência com substituição. Verifica necessidade de limpar informações de transferências disponíveis.
							cKey      := "KEY_" + RTrim(SubStr(aRastreio[nPosChvSub], 1, Self:tamanhoFilial() + snTamCod)) + "_" + cValToChar(aRastreio[nPosPeriod])
							aTranDisp := Self:oDados:oAlternativos:getItemAList("transferencias_alternativos", cKey)
							If !Empty(aTranDisp)
								nPos := aScan(aTranDisp, {|x| x[1] == aRastreio[nPosCompon]})
								If nPos > 0 .And. aTranDisp[nPos][2]:HasProperty(cFilAux)
									aTranDisp[nPos][2][cFilAux] -= nDesfez
									Self:oDados:oAlternativos:setItemAList("transferencias_alternativos", cKey, aTranDisp, .F., .T., .F.)
								EndIf
								FwFreeArray(aTranDisp)
							EndIf
						EndIf

						oDadosRast:oDados:setItemAList(cList, cChave, aRastreio)
					EndIf

					aSize(aRastreio, 0)

					If nQtdTran == 0
						Exit
					EndIf
				Next nIndRastro

				aSize(aDadosChvs, 0)

				//Atualiza flag de recalcular o produto na filial que recebeu a transferência.
				cChaveProd := cFilDest + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
				Self:oDados:gravaPeriodosProd(cChaveProd, nPerDest)
				Self:oDados:decrementaTotalizador(cChaveProd)
			Next nIndPais

		EndIf
		aSize(aDocsPais, 0)
	Next nIndex

	nSaldo  += nTotTransf
	nQtrSai -= nTotTransf

	If nTotTransf > 0
		//Remove da MATRIZ a transferência de saída. (HWB)
		Self:oDados:gravaCampo("MAT", 1, cChaveOrig, "MAT_QTRSAI", -nTotTransf, .F., .T.)
	EndIf

	If Len(aIndBxAtu) > 0
		//Grava as informações de controle para as quebras de produção/compra
		//no arquivo de rastreabilidade.
		cChaveProd := cFilAux + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
		Self:oDominio:oRastreio:atualizaRastreio(cFilAux, cChaveProd, nPeriodo, @aBaixaPorOP, aIndBxAtu, cProduto)
	EndIf

Return

/*/{Protheus.doc} desfazEntradaTransferencias
Desfaz as transferências de entrada já criadas para novo cálculo do produto
@author    ricardo.prandi
@since     19/02/2020
@version   1
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 cChaveOrig , Character, Chave da matriz do registro em processamento
@param 06 aDados     , Array    , Array com os dados da global de rastreabilidade
@param 07 cChvCheck  , Character, Chave do produto que iniciou o processo de desfazer o cálculo para avaliação de loop
@param 08 lEfetiva   , Logic    , indica se deverá efetivar as exclusões de transferência, ou se está apenas validando recursividade.
@param 09 cPrdLoop   , Character, string com os códigos de produtos concatenados. Utilizado para msg de erro em caso de recursividade.
@return Nil
/*/
METHOD desfazEntradaTransferencias(cFilAux, cProduto, nPeriodo, cIDOpc, cChaveOrig, aDados, cChvCheck, lEfetiva, cPrdLoop) CLASS MrpDominio_MultiEmpresa
	Local aChaves    := {}
	Local aDadosTran := {}
	Local aDadosChvs := {}
	Local aTransf    := {}
	Local aRastreio  := {}
	Local cChave     := ""
	Local cChaveLog  := ""
	Local cChaveMat  := ""
	Local cChaveRast := ""
	Local cChaveProd := ""
	Local cDocFilho  := ""
	Local cList      := ""
	Local lError     := .F.
	Local lPossuiPR  := .F.
	Local nPos       := 0
	Local nPosQtrEnt := Self:oDominio:oRastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Local nPosQtrSai := Self:oDominio:oRastreio:getPosicao("TRANSFERENCIA_SAIDA")
	Local nPosDocFil := Self:oDominio:oRastreio:getPosicao("DOCFILHO")
	Local nPosTipPai := Self:oDominio:oRastreio:getPosicao("TIPOPAI")
	Local nPosDocPai := Self:oDominio:oRastreio:getPosicao("DOCPAI")
	Local nPerOrigem := nPeriodo
	Local nIndex     := 0
	Local nIndRastro := 0
	Local nTotal     := 0
	Local nTotRastro := 0
	Local nQuant     := 0
	Local nDesfazRas := 0
	Local nTotDesfaz := 0
	Local oDadosRast := Self:oDominio:oRastreio:oDados_Rastreio
	Local oTransf    := Self:oDados:oTransferencia

	//Remover da HWB, na filial do registro recebido em aDados, a quantidade de transferência de entrada.
	If lEfetiva
		Self:oDados:gravaCampo("MAT", 1, cChaveOrig, {"MAT_QTRENT", "MAT_SALDO"}, {-aDados[nPosQtrEnt], -aDados[nPosQtrEnt]}, .F., .T., /*08*/, .T.)

		If Self:oDados:oLogs:logAtivado()
			cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
			Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Desfazendo a entrada de transferencia de quantidade " + cValToChar(aDados[nPosQtrEnt]) + " "}, .F. /*lWrite*/)
		EndIf
	EndIf

	//Identificar nas transferências, todas as transferências de saída que compõem a entrada existente no aDados.
	If !Empty(aDados[nPosDocFil])
		cChave := oTransf:getFlag("TRF_DOCS" + CHR(13) + aDados[nPosDocFil], @lError)
		If !lError
			aAdd(aChaves, {cChave, .T.})
			lPossuiPR := .T.
		EndIf
	EndIf
	lError  := .F.
	aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveOrig, @lError)
	If !lError
		nTotal := Len(aTransf)
		For nIndex := 1 To nTotal
			aAdd(aChaves, {aTransf[nIndex], .F.})
		Next nIndex

		aSize(aTransf, 0)
	EndIf

	nTotal := Len(aChaves)
	For nIndex := 1 To nTotal
		If oTransf:getRow(1, aChaves[nIndex][1], Nil, @aDadosTran, .F., .T.)
			nQuant := 0

			nPerOrigem := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, StoD(aDadosTran[TRANF_POS_DATA]), .F.)

			If aDados[nPosQtrEnt] <= aDadosTran[TRANF_POS_QUANTIDADE]
				nQuant := aDados[nPosQtrEnt]
			Else
				nQuant := aDadosTran[TRANF_POS_QUANTIDADE]
			EndIf

			If nQuant <= 0
				Loop
			EndIf

			cDocFilho := getDocAgl(aDadosTran[TRANF_POS_FILIAL_ORIGEM], nPerOrigem, cProduto, cIDOpc, Self:oDominio:oAglutina, aDados[nPosDocFil], nQuant, lPossuiPR, lEfetiva)

			//Para cada transferência de saída:
			//   1: Eliminar a quantidade de transferência correspondente da tabela HWB.
			cChaveMat := aDadosTran[TRANF_POS_DATA] + aDadosTran[TRANF_POS_FILIAL_ORIGEM] + aDadosTran[TRANF_POS_PRODUTO] + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
			If lEfetiva
				Self:oDados:gravaCampo("MAT", 1, cChaveMat, {"MAT_QTRSAI", "MAT_SALDO"}, {-nQuant, nQuant}, .F., .T., /*08*/, .T.)
				If Self:oDados:oLogs:logAtivado()
					cChaveLog := Self:oDados:oLogs:montaChaveLog(aDadosTran[TRANF_POS_FILIAL_ORIGEM], cProduto, cIDOpc, Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilAux, StoD(aDadosTran[TRANF_POS_DATA]), .F.))
					Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Atualizada a quantidade de transferencia de saida, diminuindo " + cValToChar(nQuant)}, .F. /*lWrite*/)
				EndIf
			EndIf

			//   2: Eliminar a transferência da tabela HWC.
			aDadosChvs := buscaRastreio(aDadosTran[TRANF_POS_FILIAL_ORIGEM], cProduto, cIDOpc, nPerOrigem, Self:oDominio:oRastreio, @cList, .F.)
			nTotRastro := Len(aDadosChvs)

			aSort(aDadosChvs, , , {|x,y| Iif( x[2][nPosTipPai] == "TRANF_PR" .And. lPossuiPR, "0", "1") +;
			                             Iif( x[2][nPosTipPai] == "TRANF_ES"                , "0", "1")  ;
			                            < ;
			                             Iif( y[2][nPosTipPai] == "TRANF_PR" .And. lPossuiPR, "0", "1") +;
			                             Iif( y[2][nPosTipPai] == "TRANF_ES"                , "0", "1") } )

			nDesfazRas := 0

			For nIndRastro := 1 to nTotRastro
				cChaveRast := aDadosChvs[nIndRastro][1]
				aRastreio  := aDadosChvs[nIndRastro][2]

				If (aRastreio[nPosTipPai] == "TRANF_PR" .And. ;
				    (Empty(cDocFilho)                     .Or.  ;
				     cDocFilho != aRastreio[nPosDocPai])) .Or. ;
				   (aRastreio[nPosTipPai] == "TRANF_ES" .And. ;
				    aRastreio[nPosDocPai] != cChaveOrig) .Or. ;
				   (aRastreio[nPosTipPai] != "TRANF_ES" .And. aRastreio[nPosTipPai] != "TRANF_PR")
					Loop
				EndIf

				If aRastreio[nPosQtrSai] <= 0
					Loop
				EndIf

				If aRastreio[nPosQtrSai] <= (nQuant-nDesfazRas)
					nTotDesfaz            += aRastreio[nPosQtrSai]
					nDesfazRas            += aRastreio[nPosQtrSai]
					aRastreio[nPosQtrSai] := 0
				Else
					nTotDesfaz            += (nQuant-nDesfazRas)
					aRastreio[nPosQtrSai] -= (nQuant-nDesfazRas)
					nDesfazRas            += (nQuant-nDesfazRas)
				EndIf

				If lEfetiva
					oDadosRast:oDados:setItemAList(cList, cChaveRast, aRastreio)
				EndIf

				//Chama o método de desfazer o cálculo deste produto somente para avaliação
				//se existe recursividade nas estruturas. Não irá desfazer nada, somente verificar.
				Self:oDominio:oRastreio:desfazExplosoes(aDadosTran[TRANF_POS_FILIAL_ORIGEM], cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPerOrigem, cChvCheck, cPrdLoop)

				aSize(aRastreio, 0)

				If nTotDesfaz >= nQuant
					Exit
				EndIf

			Next nIndRastro
			aSize(aDadosChvs, 0)

			//   3: Excluir a tabela de transferência (SMA)
			lError := .F.
			If lEfetiva
				If aDadosTran[TRANF_POS_QUANTIDADE] <= nTotDesfaz
					oTransf:delRow(1, aChaves[nIndex][1], @lError)

					If aChaves[nIndex][2]
						oTransf:delFlag("TRF_DOCS" + CHR(13) + aDados[nPosDocFil], @lError)
					Else
						lError  := .F.
						aTransf := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveOrig, @lError)
						If !lError
							nPos := aScan(aTransf, {|x| x == aChaves[nIndex][1]})
							If nPos > 0
								aDel(aTransf, nPos)
								aSize(aTransf, Len(aTransf)-1)
								oTransf:setItemAList("TRANSF_ESTOQUE", cChaveOrig, aTransf, @lError, .F., .F.)
							EndIf

							aSize(aTransf, 0)
						EndIf
					EndIf

				Else
					aDadosTran[TRANF_POS_QUANTIDADE] -= nTotDesfaz
					oTransf:updRow(1, aChaves[nIndex][1], Nil, aDadosTran, .F., .T.)
				EndIf

				//   4: Setar o produto para ser recalculado
				cChaveProd := aDadosTran[TRANF_POS_FILIAL_ORIGEM] + cProduto + Iif(!Empty(cIDOpc),"|"+cIDOpc,"")
				Self:oDados:gravaPeriodosProd(cChaveProd, nPerOrigem)
				Self:oDados:decrementaTotalizador(cChaveProd)
			EndIf

			aSize(aDadosTran, 0)
		EndIf

		If nTotDesfaz >= aDados[nPosQtrEnt]
			Exit
		EndIf
	Next nIndex

	aSize(aChaves, 0)
Return

/*/{Protheus.doc} alternativosMultiEmpresa
Verifica a necessidade de utilizar produtos alternativos com saldo em outras filiais.

@author    lucas.franca
@since     13/04/2021
@version   P12
@param 01 cFilAux    , Character, Filial atual de processamento
@param 02 cProduto   , Character, Produto atual de processamento
@param 03 nPeriodo   , Numeric  , Período atual de processamento
@param 04 cIDOpc     , Character, ID de Opcional do registro atual
@param 05 aBaixaPorOP, Array    , Array de rastreio do registro que está sendo processado.
@param 07 nQtdNec    , Numeric  , Quantidade da necessidade
@param 08 lWait      , Logic    , Retorna por referencia indicando se existe na Matriz de Calculo, mas nao foi calculado. Interrompe o consumo.
@param 09 aMinMaxAlt , Array    , Array com o nMin e nMax de sequência do alternativo
@return nSubstitui, Numeric, Quantidade do produto original que foi substituída.
/*/
METHOD alternativosMultiEmpresa(cFilAux, cProduto, nPeriodo, cIDOpc, aBaixaPorOP, nQtdNec, lWait, aMinMaxAlt) CLASS MrpDominio_MultiEmpresa
	Local aAuxAlt    := {}
	Local aBaixa     := {}
	Local cChaveProd := cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	Local nSaldo     := 0
	Local nSubstitui := 0
	Local nTotAlt    := 0
	Local nIndAlt    := 0

	aAdd(aBaixa, aClone(aBaixaPorOP))

	nSaldo := Self:oDominio:oAlternativo:consumirAlternativos(cFilAux, cProduto, -nQtdNec, nPeriodo, "", @lWait, cIDOpc, nQtdNec, aBaixa, aMinMaxAlt, .T.)

	If !lWait
		nSubstitui := nQtdNec - Abs(nSaldo)
	EndIf

	If nSubstitui <> 0
		Self:oDominio:oRastreio:atualizaSubstituicao(cFilAux, cChaveProd, nPeriodo, @aBaixa, .F., .T., nSubstitui + aBaixa[1][ABAIXA_POS_QTD_SUBSTITUICAO], .T.)

		nTotAlt     := Len(Self:oDominio:oAlternativo:aPeriodos_Alternativos)
		For nIndAlt := 1 to nTotAlt
			aAuxAlt := Self:oDominio:oAlternativo:aPeriodos_Alternativos[nIndAlt]

			Self:oDados:gravaPeriodosProd(cFilAux + aAuxAlt[1], aAuxAlt[2])
		Next
		aSize(Self:oDominio:oAlternativo:aPeriodos_Alternativos, 0)
		aSize(aAuxAlt, 0)
		aBaixaPorOP := aClone(aBaixa[1])
	EndIf

	//Limpa o array com os dados de transferências de alternativos realizadas
	//após a utilização para gravar os dados de substituição no método atualizaSubstituicao
	If !Empty(Self:oDominio:oAlternativo:aSubsTranf)
		aSize(Self:oDominio:oAlternativo:aSubsTranf, 0)
	EndIf

	aSize(aBaixa, 0)

Return nSubstitui

/*/{Protheus.doc} retornaDadosTransferenciaDocumento
Busca os dados de transferência (SMA) com base em um número de documento de transferência (TRANF0000001)
e retorna os dados da transferência

@author    lucas.franca
@since     28/09/2023
@version   P12
@param 01 cDocumento, Caracter, Número de documento (TRANF00000001) utilizado para a busca.
@param 02 cFilDest  , Caracter, Retorna por referência o código da filial de destino
@param 03 cDocOrigem, Caracter, Retorna por referência o código do documento que originou a transferência de produção
@return nQtdTran, Numeric, Quantidade da transferência
/*/
METHOD retornaDadosTransferenciaDocumento(cDocumento, cFilDest, cDocOrigem) CLASS MrpDominio_MultiEmpresa
	Local aDados   := {}
	Local cChave   := ""
	Local lError   := .F.
	Local nQtdTran := 0
	Local oTransf  := Self:oDados:oTransferencia

	cChave := oTransf:getFlag("TRF_DOCS" + CHR(13) + cDocumento, @lError)
	If lError == .F.
		oTransf:getRow(1, cChave, Nil, @aDados, .F., .T.)
		If !Empty(aDados)
			nQtdTran   := aDados[TRANF_POS_QUANTIDADE    ]
			cFilDest   := aDados[TRANF_POS_FILIAL_DESTINO]
			cDocOrigem := aDados[TRANF_POS_DOCUM_ORIGEM  ]
			aSize(aDados, 0)
		EndIf
	EndIf

Return nQtdTran

/*/{Protheus.doc} retornaTransferenciaEstoque
Busca os dados de transferência (SMA) com base na chave da matriz de destino,
retornando as transferências realizadas para este destino.

@author    lucas.franca
@since     28/09/2023
@version   P12
@param 01 cChaveMat , Character, Chave da matriz de destino
@param 02 nTotalTran, Numeric  , Retorna por referência a quantidade total da transferência de estoque.
@return aTransf, Array, Dados com a filial origem e quantidade
/*/
METHOD retornaTransferenciaEstoque(cChaveMat, nTotalTran) CLASS MrpDominio_MultiEmpresa
	Local aDadosTran := {}
	Local aChaves    := {}
	Local aTransf    := {}
	Local lError     := .F.
	Local nTotal     := 0
	Local nIndex     := 0
	Local oTransf    := Self:oDados:oTransferencia

	nTotalTran := 0
	aChaves    := oTransf:getItemAList("TRANSF_ESTOQUE", cChaveMat, @lError)
	If !lError
		nTotal := Len(aChaves)
		For nIndex := 1 To nTotal
			If oTransf:getRow(1, aChaves[nIndex], Nil, @aDadosTran, .F., .T.)
				nTotalTran += aDadosTran[TRANF_POS_QUANTIDADE]
				aAdd(aTransf, {aDadosTran[TRANF_POS_QUANTIDADE], aDadosTran[TRANF_POS_FILIAL_ORIGEM]})
				aSize(aDadosTran, 0)
			EndIf
		Next nIndex

		aSize(aChaves, 0)
	EndIf
Return aTransf

/*/{Protheus.doc} getDocsPai
Busca os documentos pais que devem ter as transferências de estoque desfeitas.

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilAux  , Character, Código da filial
@param 02 nPeriodo , Numeric  , Número do período
@param 03 cProduto , Character, Código do produto
@param 04 cIDOpc   , Character, ID de opcional
@param 05 oAglutina, Object   , Referência da classe de aglutinação
@param 06 cDocPai  , Character, Documento pai do registro
@param 07 nQtdTran , Numeric  , Quantidade de transferência
@param 08 lTranfPR , Logic    , Indica que o processo é para desfazer transferência de produção
@param 09 lAglutina, Logic    , Parâmetro de aglutinação do produto
@return aDocsPais, Array, Array com os documentos pais que devem ter as transferências desfeitas
/*/
Static Function getDocsPai(cFilAux, nPeriodo, cProduto, cIDOpc, oAglutina, cDocPai, nQtdTran, lTranfPR, lAglutina)
	Local aDocsPais  := {}
	Local aDadosAgl  := {}
	Local cChaveAgl  := ""
	Local lError     := .F.
	Local nIndex     := 0
	Local nTotal     := 0
	Local nPosPais   := oAglutina:getPosicao("ADOC_PAI")
	Local nPosIdTran := oAglutina:getPosicao("ID_TRANSF")
	Local nPosQtran  := oAglutina:getPosicao("TRANSF_SAIDA")

	If lTranfPR .And. lAglutina
		//Transferência de produção com aglutinação. Verifica os documentos na HWG.
		cChaveAgl := cFilAux + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
		oAglutina:oAglutinacao:getFlag("6" + chr(13) + cChaveAgl, @lError)
		If !lError
			aDadosAgl := oAglutina:oAglutinacao:getItemAList("6", cChaveAgl)
			nTotal := Len(aDadosAgl[nPosPais])
			For nIndex := 1 To nTotal
				aAdd(aDocsPais, {aDadosAgl[nPosPais][nIndex][nPosIdTran], aDadosAgl[nPosPais][nIndex][nPosQtran]})
			Next nIndex

			oAglutina:oAglutinacao:delItemAList("6", cChaveAgl, @lError)
			oAglutina:oAglutinacao:delFlag("6" + chr(13) + cChaveAgl, @lError)

			aSize(aDadosAgl, 0)
		Else
			aDocsPais := {{cDocPai, nQtdTran}}
		EndIf
	Else
		aDocsPais := {{cDocPai, nQtdTran}}
	EndIf
Return aDocsPais

/*/{Protheus.doc} getDocAgl
Busca o número do documento aglutinador quando o produto possui aglutinação

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilOri  , Character, Código da filial da origem da transferência
@param 02 nPeriodo , Numeric  , Número do período
@param 03 cProduto , Character, Código do produto
@param 04 cIDOpc   , Character, ID de opcional
@param 05 oAglutina, Object   , Referência da classe de aglutinação
@param 06 cDocFilho, Character, Documento filho do registro atual
@param 07 nQuant   , Numeric  , Quantidade de transferência
@param 08 lPossuiPR, Logic    , Indica que existe registro de transferência de produção (TRANF_PR)
@param 09 lEfetiva   , Logic    , indica se deverá efetivar as exclusões de transferência, ou se está apenas validando recursividade.
@return cDocAgl    , Character, Documento aglutinador se existir, caso contrário mesmo conteúdo de cDocFilho
/*/
Static Function getDocAgl(cFilOri, nPeriodo, cProduto, cIDOpc, oAglutina, cDocFilho, nQuant, lPossuiPR, lEfetiva)
	Local aDadosAgl  := {}
	Local cChaveAgl  := ""
	Local cDocAgl    := cDocFilho
	Local lError     := .F.
	Local nPos       := 0
	Local nPosDocAgl := oAglutina:getPosicao("DOCUMENTO")
	Local nPosIdTran := oAglutina:getPosicao("ID_TRANSF")
	Local nPosPais   := oAglutina:getPosicao("ADOC_PAI")
	Local nPosTrfSai := oAglutina:getPosicao("TRANSF_SAIDA")

	If lPossuiPR .And. oAglutina:avaliaAglutinacao(cFilOri, cProduto) .And. !Empty(cDocFilho)
		cChaveAgl := cFilOri + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
		oAglutina:oAglutinacao:getFlag("6" + chr(13) + cChaveAgl, @lError)
		If !lError
			aDadosAgl := oAglutina:oAglutinacao:getItemAList("6", cChaveAgl)
			nPos := aScan(aDadosAgl[nPosPais], {|x| x[nPosIdTran] == cDocFilho })

			If nPos > 0
				cDocAgl := aDadosAgl[nPosDocAgl]
				If lEfetiva
					aDadosAgl[nPosPais][nPos][nPosTrfSai] -= nQuant
					If aDadosAgl[nPosPais][nPos][nPosTrfSai] <= 0
						aDel(aDadosAgl[nPosPais], nPos)
						aSize(aDadosAgl[nPosPais], Len(aDadosAgl[nPosPais])-1)
					EndIf
					If Len(aDadosAgl[nPosPais]) == 0
						oAglutina:oAglutinacao:delItemAList("6", cChaveAgl, @lError)
						oAglutina:oAglutinacao:delFlag("6" + chr(13) + cChaveAgl, @lError)
					Else
						oAglutina:oAglutinacao:setItemAList("6", cChaveAgl, aDadosAgl)
					EndIf
				EndIf
			EndIf

			aSize(aDadosAgl, 0)
		EndIf
	EndIf
Return cDocAgl

/*/{Protheus.doc} buscaRastreio
Busca os dados de rastreio para desfazer as transferências.

@type  Static Function
@author ricardo.prandi
@since 23/02/2021
@version P12
@param 01 cFilDest , Character, Código da filial
@param 02 cProduto , Character, Código do produto
@param 03 cIDOpc   , Character, ID de opcional
@param 04 nPeriodo , Numeric  , Número do período
@param 05 oRastreio, Object   , Referência da classe de domínio da rastreabilidade
@param 06 cList    , Character, Retorna por referência o código da lista
@param 07 lOrdena  , Logic    , Indica se deve ordenar o array de retorno
@return aDadosChvs, Array, Array com as informações de rastreio
/*/
Static Function buscaRastreio(cFilDest, cProduto, cIDOpc, nPeriodo, oRastreio, cList, lOrdena)
	Local aChaves    := {}
	Local aDados     := {}
	Local aDadosChvs := {}
	Local cChave     := ""
	Local lError     := .F.
	Local nContador  := 0
	Local nIndex     := 0
	Local nTotal     := 0
	Local oDadosRast := oRastreio:oDados_Rastreio

	cList   := cFilDest + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + chr(13) + cValToChar(nPeriodo)
	aChaves := oDadosRast:getDocsComponente(cList)
	nTotal  := Len(aChaves)

	//Recupera registros de rastreabilidade dos chaves
	For nIndex := 1 to nTotal
		lError    := .F.
		aDados    := {}
		cChave    := aChaves[nIndex]
		aDados    := oDadosRast:oDados:getItemAList(cList, cChave, @lError)
		If !lError
			nContador++
            aAdd(aDadosChvs, {cChave, aDados, StrZero(nContador, 5)})
		EndIf
	Next nIndex
	aSize(aChaves, 0)

	nTotal := Len(aDadosChvs)
	If nTotal > 0 .And. lOrdena
		aDadosChvs := oRastreio:ordenaRastreio(aDadosChvs, .T.)
	EndIf

Return aDadosChvs

/*/{Protheus.doc} CompValid
Verifica se existe componente válido na estrutura do produto para o período.

@type  Static Function
@author vivian.beatriz
@since 10/07/2025
@version P12
@param 01 cFilDest , Character, Código da filial
@param 02 cProduto , Character, Código do produto
@param 03 nPeriodo , Numeric  , Número do período
@param 04 cIDOpc   , Character, ID de opcional
@param 05 oDados   , Objetic  , Instância do objeto de dados
@param 06 oDominio , Objetic  , Instância do objeto de domínio
@return lEstVal    , Logiic   , Indica se o produto possui estrutura válida para filial / período / IDOpc
/*/
Static Function CompValid(cFilDest, cProduto, nPeriodo, cIDOpc, oDados, oDominio)
	Local aComponentes := {}
	Local cChaveEst    := ""
	Local cOpcGrp      := ""
	Local cOpcItem     := ""
	Local dData        := ""
	Local dDtFimCmp    := Nil
	Local dDtIniCmp    := Nil
	Local lEstVld      := .F.
	Local nInd         := 0
	Local nTotComp     := 0
    
	dData := oDominio:oPeriodos:retornaDataPeriodo(cFilDest, nPeriodo)
	cChaveEst := cFilDest + cProduto

	//Retorna array com os componentes da estrutura
	oDados:oEstruturas:getRow(1, cChaveEst,, @aComponentes)

	nTotComp := Len(aComponentes)
    
	For nInd := 1 to nTotComp
			
		//Desconsidera opcionais desselecionados
		cOpcGrp  := aComponentes[nInd][oDados:posicaoCampo("EST_GRPOPC")]
		cOpcItem := aComponentes[nInd][oDados:posicaoCampo("EST_ITEOPC")]
		
		If !Empty(cOpcGrp) .AND. !oDominio:oOpcionais:selecionado(cIDOpc, cOpcGrp, cOpcItem)
			Loop
		EndIf
		
		dDtIniCmp := aComponentes[nInd][oDados:posicaoCampo("EST_VLDINI")]
		dDtFimCmp := aComponentes[nInd][oDados:posicaoCampo("EST_VLDFIM")]

		If !Empty(dDtIniCmp) .Or. !Empty(dDtFimCmp)
		
			If dDtIniCmp <= dData .And. dDtFimCmp >= dData
				lEstVld := .T.
				Exit
			EndIf
		EndIf					

	Next

Return lEstVld
