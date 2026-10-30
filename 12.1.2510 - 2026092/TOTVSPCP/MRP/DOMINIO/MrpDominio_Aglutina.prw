#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE ADADOS_POS_ORIGEM                  1
#DEFINE ADADOS_POS_DOCUMENTO               2
#DEFINE ADADOS_POS_PRODUTO                 3
#DEFINE ADADOS_POS_ID_OPCIONAL             4
#DEFINE ADADOS_POS_TRT                     5
#DEFINE ADADOS_POS_QUANTIDADE              6
#DEFINE ADADOS_POS_PERIODO                 7
#DEFINE ADADOS_POS_ADOC_PAI                8
#DEFINE ADADOS_POS_ROTEIRO                 9
#DEFINE ADADOS_POS_OPERACAO                10
#DEFINE ADADOS_POS_AGLUTINA                11
#DEFINE ADADOS_POS_FILIAL                  12
#DEFINE ADADOS_POS_LOCAL                   13
#DEFINE ADADOS_POS_REVISAO                 14
#DEFINE ADADOS_TAMANHO                     14

//CONSTANTES REFERENTE AO ARRAY QUE SERÁ CRIADO NA POSIÇAO 08 DO ADADOS (ADADOS_POS_ADOC_PAI)
#DEFINE ADADOS_POS_ADOC_PAI_ORI            1
#DEFINE ADADOS_POS_ADOC_PAI_DOC            2
#DEFINE ADADOS_POS_ADOC_PAI_QTD            3
#DEFINE ADADOS_POS_ADOC_PAI_PRODUTO        4
#DEFINE ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA 5
#DEFINE ADADOS_POS_ADOC_PAI_TRANSF_SAIDA   6
#DEFINE ADADOS_POS_ADOC_PAI_ID_TRANSF      7
#DEFINE ADADOS_POS_ADOC_PAI_HWC_DOCFIL     8
#DEFINE ADADOS_POS_ADOC_PAI_QTD_EMPE       9
#DEFINE ADADOS_POS_ADOC_PAI_QTD_SUBS       10
#DEFINE ADADOS_POS_ADOC_PAI_TRT            11
#DEFINE ADADOS_POS_ADOC_PAI_OPERACAO       12
#DEFINE ADADOS_POS_ADOC_PAI_TAMANHO        12

/*/{Protheus.doc} MrpDominio_Aglutina
Classe de Controle da Rastreabilidade de Aglutinações de Rastreabilidade
@author    brunno.costa
@since     21/11/2019
@version   1
/*/
Class MrpDominio_Aglutina FROM LongClassName

	DATA oDados       AS Object //Instancia da classe de dados do MRP
	DATA oAglutinacao AS Object //Instancia de dados MrpDados_Global para controle das aglutinações
	DATA oAlternativo AS Object //Instancia da classe de domínio de alternativos - Matriz
	DATA cAglutinaSC  AS String
	DATA cAglutinaOP  AS String
	DATA lUsaDocFil   AS Logical
	DATA lTrtHWG      AS Logical
	DATA nIndRSubst   AS Integer
	DATA nIndrNecOr   AS Integer
	DATA nIndRegra    AS String

	//Métodos Públicos
	METHOD new() CONSTRUCTOR

	//Métodos relacionados a Carga em Memória
	METHOD aguardaCargaEstrutura()         //Aguarda Carga das Estruturas de Produtos
	METHOD aguardaProdutoCarga()           //Aguarda Carga de Produtos
	METHOD incluiRastreios(cLista, nTotal) //Processa Inclusões de Rastreabilidade Default
	METHOD prepara(cFilAux, cLista, cOrigem, aDocPai, cDocumento, cProduto, cIDOpc, cTRT, nQuantidade, nPeriodo, cRegra, lDemanda, lAglutina, lQuebra, cRoteiro, cOperacao, nQtrEnt, nQtrSai, cIdTransf) //Avalia e Prepara Registro para Inserção Aglutinada ou Não

	//Métodos relacionados ao Cálculo
	METHOD preparaEInclui(cFilAux, cLista, cOrigem, aDocPai, cDocumento, cProduto, cIDOpc, cTRT, nQuantidade, nPeriodo, cRegra, lAglutina, lQuebra, cRoteiro, cOperacao, nQtrEnt, nQtrSai, cIdTransf) //Avalia necessidade de aglutinação e inclui a rastreabilidade
	METHOD deletaAglutinado(cFilAux, cLista, cProduto, nPeriodo, aDocPai, cTrt)
	Method retornaDocAglutinado(cFilAux, nPeriodo, cProduto, aDocPai, cTrt)
	METHOD retornaEmpNegativo(cFilAux, nPeriodo, cProduto)

	//Métodos relacionados à Exportação
	METHOD ajustesExportacao(aAglutinacao, aNovasAglu)                               //Efetua ajustes de empenho e substituição nos registros da aglutinação que serão efetivados na HWG
	METHOD geraRegistrosAlternativos(cFilAux, cProduto, nPeriodo, cDocumento, cTRT, cTpDocOri, cDocOri, cProdOri, aAlteDeman, aNovasAglu, nSubstitui, oJSConAlt, cDocFilHWC) //Duplica registros referente alternativos
	METHOD retornaRastreio(cFilAux, cProduto, nPeriodo, cDocPai, cTRT, cListOrig)             //Retorna registro aRastreio relacionado
	METHOD retornaAlternativos(cFilAux, cComponente, nPeriodo)                                //Retorna registros referente alternativos aAlteDeman

	//Outros Métodos
	METHOD avaliaAglutinacao(cFilAux, cProduto, lDemanda, cOrigem) //Avalia necessidade de aglutinação
	METHOD getPosicao()                                            //Retorna a posicao do campo no array de dados
	METHOD processamentoAglutinado()                               //Indica se os parâmetros estão definidos para usar aglutinação
	METHOD novoIdAglutinacao()
	METHOD usaDocFilho()
	METHOD gravaTrtNaHWG()

	//Métodos Internos
	METHOD proximoIDAuto(cLista)   //Identifica o próximo ID Automático

EndClass

/*/{Protheus.doc} MrpDominio_Aglutina
Método construtor da classe MrpDominio_Aglutina
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - oDados , objeto, instancia da camada de dados do MRP
@return, Self, objeto, instancia desta classe
/*/
METHOD new(oDados) CLASS MrpDominio_Aglutina

	::oDados       := oDados
	::oAglutinacao := oDados:oAglutinacao
	Self:oAlternativo := oDados:oDominio:oAlternativo
	::cAglutinaSC  := oDados:oParametros["cConsolidatePurchaseRequest"]
	::cAglutinaOP  := oDados:oParametros["cConsolidateProductionOrder"]
	::nIndRSubst   := oDados:oRastreio:getPosicao("SUBSTITUICAO")
	::nIndrNecOr   := oDados:oRastreio:getPosicao("NEC_ORIGINAL")
	::nIndRegra    := oDados:oRastreio:getPosicao("REGRA_ALTERNATIVO")

Return Self

//********************************************/
/*MÉTODOS UTILIZADOS NA CARGA EM MEMÓRIA     */
//********************************************/

/*/{Protheus.doc} aguardaCargaEstrutura
Aguarda Conclusão da Carga de Estruturas em Memória
@author    brunno.costa
@since     21/11/2019
@version   1
/*/
METHOD aguardaCargaEstrutura() CLASS MrpDominio_Aglutina

	Local oStatus := MrpDados_Status():New(Self:oDados:oParametros["ticket"])

	If ::oDados:oParametros["cConsolidatePurchaseRequest"] != "2";
		.OR. ::oDados:oParametros["cConsolidateProductionOrder"] != "2"
		While ::oDados:oEstruturas:getFlag("termino_carga") != "S" .AND. oStatus:getStatus("status") != "4"
			Sleep(50)
		EndDo
	EndIf

Return Nil

/*/{Protheus.doc} aguardaProdutoCarga
Aguarda Conclusão da Carga de Estruturas em Memória
@author    brunno.costa
@since     25/03/2020
@version   12.1.30
/*/
METHOD aguardaProdutoCarga() CLASS MrpDominio_Aglutina

	Local oStatus := MrpDados_Status():New(Self:oDados:oParametros["ticket"])

	While Self:oDados:oProdutos:getFlag("termino_carga") != "S" .AND. oStatus:getStatus("status") != "4"
		Sleep(50)
	EndDo

Return Nil

/*/{Protheus.doc} incluiRastreios
Efetiva a Inclusão das Rastreabilidades Default em Memória - Utilizado na Carga em Memória
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - cLista, caracter, identificador da Lista de
/*/
METHOD incluiRastreios(cLista, nTotal) CLASS MrpDominio_Aglutina

	Local aLista    := {}
	Local lError    := .F.
	Local nIndex    := 0
	Local oRastreio := ::oDados:oDominio:oRastreio

	::oAglutinacao:getAllAList(cLista, @aLista, lError)

	If !lError
		nTotal := Len(aLista)

		For nIndex := 1 To nTotal
			oRastreio:incluiNecessidade(aLista[nIndex][2][ADADOS_POS_FILIAL     ],;
			                            aLista[nIndex][2][ADADOS_POS_ORIGEM     ],;
			                            aLista[nIndex][2][ADADOS_POS_DOCUMENTO  ],;
			                            aLista[nIndex][2][ADADOS_POS_PRODUTO    ],;
			                            aLista[nIndex][2][ADADOS_POS_ID_OPCIONAL],;
			                            aLista[nIndex][2][ADADOS_POS_TRT        ],;
			                            aLista[nIndex][2][ADADOS_POS_QUANTIDADE ],;
			                            aLista[nIndex][2][ADADOS_POS_PERIODO    ],;
			                            /*cListOrig*/, /*cRegra*/, /*cOrdSubst*/ ,;
			                            /*cRoteiro*/, /*cOperacao*/, /*nQtrEnt*/ ,;
			                            /*nQtrSai*/, /*cDocFilho*/, /*nSaldo*/   ,;
			                            /*lSubsTran*/                            ,;
			                            aLista[nIndex][2][ADADOS_POS_LOCAL      ],;
			                            aLista[nIndex][2][ADADOS_POS_REVISAO    ])
			aSize(aLista[nIndex][2], 0)
			aLista[nIndex][2] := Nil
			aSize(aLista[nIndex], 0)
			aLista[nIndex]    := Nil
		Next nIndex

		aSize(aLista, 0)
		aLista := Nil
	EndIf

Return

/*/{Protheus.doc} prepara
Prepara o Registro para Inserção Aglutinada ou Desaglutinada
@author    brunno.costa
@since     21/11/2019
@param 01 cFilAux    , caracter, código da filial para processamento
@param 02 cLista     , caracter, código da lista identificadora da tabela utilizada:
                                 1 = Carga de Demandas (PCPCargDem)
                                 2 = Carga de Empenhos
                                 3 = Carga de outras Saídas Previstas
                                 4 = Explosão da Estrutura
                                 6 = Transferências
@param 03 cOrigem    , caracter, identificador de origem do registro
@param 04 aDocPai    , array   , {Tipo do Documento Pai,
                                  Documento Pai,
                                  Produto Pai,
                                  Documento Filho do Pai}
@param 05 cDocumento , caracter, identificador do documento - retorna por referência
@param 06 cProduto   , caracter, código do produto
@param 07 cIDOpc     , caracter, código do ID do Opcional
@param 08 cTRT       , caracter, código do TRT
@param 09 nQuantidade, número  , quantidade da necessidade
@param 10 nPeriodo   , número  , período da necessidade
@param 11 cRegra     , caracter, regra de consumo dos alternativos:
                                 1 = Valida Original; Valida Alternativo; Compra Original
                                 2 = Valida Original; Valida Alternativo; Compra Alternativo
                                 3 = Valida Alternativo; Compra Alternativo
@param 12 lDemanda   , lógico  , indica se refere-se a origem de carga de demanda
@param 13 lAglutina  , lógico  , indica se deve considerar aglutinação na chave do registro
@param 14 lQuebra    , lógico  , indica origem em quebra de Lote Econômico ou Qtd. Embalagem (nIndQuebra > 1)
@param 15 cRoteiro   , caracter, código do roteiro de operações do produto Pai
@param 16 cOperacao  , caracter, código da operação deste componente no roteiro do produto Pai
@param 17 nQtrEnt    , número  , quantidade de transferência de entrada
@param 18 nQtrSai    , número  , quantidade de transferência de saída
@param 19 cIdTransf  , caracter, ID de transferência do registro origem
@param 20 cLocal     , caracter, Código do armazém
@param 21 cRevisao   , caracter, Revisão do produto
@version 1
@return aDados       , array, array com os dados para inclusão da necessidade:
                              {1 - Origem,
                               2 - Documento,
                               3 - Produto,
                               4 - TRT,
                               5 - Quantidade,
                               6 - Período,
                               7 - Array Doc Pai{Tipo Oridem Doc Pai, Documento, Quantidade},
                               8 - lAglutina relacionado}
/*/
METHOD prepara(cFilAux, cLista, cOrigem, aDocPai, cDocumento, cProduto, cIDOpc, cTRT, nQuantidade, nPeriodo,;
               cRegra, lDemanda, lAglutina, lQuebra, cRoteiro, cOperacao, nQtrEnt, nQtrSai, cIdTransf, cLocal, cRevisao) CLASS MrpDominio_Aglutina
	Local aAuxPai    := Nil
	Local aDados     := {}
	Local aListas    := {"1", "2", "3", "4"}
	Local dDataPer   := Nil
	Local cChave     := ""
	Local cChaveLog  := ""
	Local cListaBkp  := cLista
	Local lError     := .F.
	Local nIndListas := 0
	Local nPos       := 0
	Local oEventos   := ::oDados:oDominio:oEventos
	Local oRastreio  := ::oDados:oDominio:oRastreio
	Local oPeriodos  := ::oDados:oDominio:oPeriodos

	Default cIDOpc    := ""
	Default cRegra    := "1"
	Default cRoteiro  := ""
	Default cOperacao := ""
	Default cIdTransf := ""
	Default cLocal    := ""
	Default cTRT      := ""
	Default lDemanda  := .T.
	Default lAglutina := ::avaliaAglutinacao(cFilAux, cProduto, lDemanda, cOrigem)
	Default lQuebra   := .F.
	Default nQtrEnt   := 0
	Default nQtrSai   := 0
	Default cRevisao  := " "

	//Identifica a Chave do Rastreio
	If lAglutina
		//Se for aglutinação e tiver PMP, não considera a revisão
		If cLista == "1" .And. cOrigem <> "1"
			cChave := cFilAux + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "") + cRevisao
		Else
			cChave := cFilAux + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
		EndIf
	Else
		cChave := cFilAux + cOrigem + cDocumento + chr(13) + cValToChar(nPeriodo) + cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, "")
	EndIf

	If !::usaDocFilho()
		aDocPai[4] := ""
	EndIf

	//Adiciona registro no objeto aglutinador de rastreabilidade
	If lDemanda .Or. (cLista != "4" .And. cLista != "6")
		::oAglutinacao:trava(cChave)
	EndIf

	If lAglutina .Or. lDemanda .Or. lQuebra
		::oAglutinacao:getFlag(cLista + chr(13) + cChave, @lError)
		If lAglutina .And. lError .And. cLista == "5"
			For nIndListas := 1 to 3
				lError := .F.
				If aListas[nIndListas] != cLista
					::oAglutinacao:getFlag(aListas[nIndListas] + chr(13) + cChave, @lError)
					If !lError
						cLista := aListas[nIndListas]
						Exit
					EndIf
				Else
					lError := .T.
				EndIf
			Next
		EndIf

		If lError
			::oAglutinacao:setFlag(cLista + chr(13) + cChave, .T.)
			If lAglutina
				If cLista == "4"        //Explosão da Estrutura
					cDocumento := oRastreio:oDados_Rastreio:proximaOP()
					If ::oDados:oLogs:logAtivado()
						cChaveLog := ::oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
						::oDados:oLogs:gravaLog("calculo", cChaveLog, {"Criado o documento " + RTrim(cDocumento) + " para aglutinar as necessidades do produto " + RTrim(cProduto), ;
						                                               "Atualizado o documento aglutinado " + RTrim(cDocumento) + " adicionando o documento " + RTrim(aDocPai[4]) + " referente ao produto pai " + RTrim(aDocPai[3]) + " com necessidade de " + cValToChar(nQuantidade)}, .F. /*lWrite*/)
					EndIf

				ElseIf cLista == "6"
					cDocumento := ::oDados:oDominio:oMultiEmp:novoIdTransferencia()

				Else
					cDocumento := ::proximoIDAuto(cLista)
					If ::oDados:oLogs:logAtivado()
						cChaveLog := ::oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
						::oDados:oLogs:gravaLog("calculo", cChaveLog, {"Criado o documento " + RTrim(cDocumento) + " para aglutinar as necessidades do produto " + RTrim(cProduto) + " com necessidade de " + cValToChar(nQuantidade)}, .F. /*lWrite*/)
					EndIf
				EndIf
			EndIf

			aAuxPai := Array(ADADOS_POS_ADOC_PAI_TAMANHO)
			aDados  := Array(ADADOS_TAMANHO)

			aAuxPai[ADADOS_POS_ADOC_PAI_ORI           ] := aDocPai[ADADOS_POS_ADOC_PAI_ORI]
			aAuxPai[ADADOS_POS_ADOC_PAI_DOC           ] := aDocPai[ADADOS_POS_ADOC_PAI_DOC]
			aAuxPai[ADADOS_POS_ADOC_PAI_QTD           ] := nQuantidade
			aAuxPai[ADADOS_POS_ADOC_PAI_PRODUTO       ] := aDocPai[3]
			aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA] := nQtrEnt
			aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_SAIDA  ] := nQTrSai
			aAuxPai[ADADOS_POS_ADOC_PAI_ID_TRANSF     ] := cIdTransf
			aAuxPai[ADADOS_POS_ADOC_PAI_HWC_DOCFIL    ] := aDocPai[4]
			aAuxPai[ADADOS_POS_ADOC_PAI_QTD_EMPE      ] := 0
			aAuxPai[ADADOS_POS_ADOC_PAI_QTD_SUBS      ] := 0
			aAuxPai[ADADOS_POS_ADOC_PAI_TRT           ] := cTRT
			aAuxPai[ADADOS_POS_ADOC_PAI_OPERACAO      ] := cOperacao

			aDados[ADADOS_POS_ORIGEM     ] := cOrigem
			aDados[ADADOS_POS_DOCUMENTO  ] := cDocumento
			aDados[ADADOS_POS_PRODUTO    ] := cProduto
			aDados[ADADOS_POS_ID_OPCIONAL] := cIDOpc
			aDados[ADADOS_POS_TRT        ] := cTRT
			aDados[ADADOS_POS_QUANTIDADE ] := nQuantidade
			aDados[ADADOS_POS_PERIODO    ] := nPeriodo
			aDados[ADADOS_POS_ADOC_PAI   ] := {aAuxPai}
			aDados[ADADOS_POS_ROTEIRO    ] := cRoteiro
			aDados[ADADOS_POS_OPERACAO   ] := Iif(lAglutina, "", cOperacao)
			aDados[ADADOS_POS_AGLUTINA   ] := lAglutina
			aDados[ADADOS_POS_FILIAL     ] := cFilAux
			aDados[ADADOS_POS_LOCAL      ] := cLocal
			aDados[ADADOS_POS_REVISAO    ] := cRevisao
		Else
			aDados := ::oAglutinacao:getItemAList(cLista, cChave)
			aDados[ADADOS_POS_QUANTIDADE] += nQuantidade
			If Empty(cDocumento)
				cDocumento                := aDados[ADADOS_POS_DOCUMENTO]
			EndIf

			nPos := aScan(aDados[ADADOS_POS_ADOC_PAI],;
							{|x|  x[ADADOS_POS_ADOC_PAI_ORI]        == aDocPai[1];
							.And. x[ADADOS_POS_ADOC_PAI_DOC]        == aDocPai[2];
							.And. x[ADADOS_POS_ADOC_PAI_PRODUTO]    == aDocPai[3];
							.And. x[ADADOS_POS_ADOC_PAI_HWC_DOCFIL] == aDocPai[4];
							.And. (!::gravaTrtNaHWG() .Or. x[ADADOS_POS_ADOC_PAI_TRT] == cTRT)})
			If nPos == 0
				aAuxPai := Array(ADADOS_POS_ADOC_PAI_TAMANHO)

				//Se possui mais de um documento aglutinado, altera a origem para o tipo "Consolidado".
				If AllTrim(cLista) != "2" .And. AllTrim(cLista) != "4" //!Pré-OP
					aDados[ADADOS_POS_ORIGEM] := "0"

					// Se possui demandas com armazém diferente usa o armazém default.
					If Trim(aDados[ADADOS_POS_LOCAL]) != Trim(cLocal)
						aDados[ADADOS_POS_LOCAL] := ""
						dDataPer := oPeriodos:retornaDataPeriodo(cFilAux, aDados[ADADOS_POS_PERIODO])
						oEventos:loga("011", aDados[ADADOS_POS_PRODUTO], dDataPer, {aDados[ADADOS_POS_DOCUMENTO], dDataPer}, cFilAux, .T.)
					EndIf
				EndIf

				aAuxPai[ADADOS_POS_ADOC_PAI_ORI           ] := aDocPai[ADADOS_POS_ADOC_PAI_ORI]
				aAuxPai[ADADOS_POS_ADOC_PAI_DOC           ] := aDocPai[ADADOS_POS_ADOC_PAI_DOC]
				aAuxPai[ADADOS_POS_ADOC_PAI_QTD           ] := nQuantidade
				aAuxPai[ADADOS_POS_ADOC_PAI_PRODUTO       ] := aDocPai[3]
				aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA] := nQtrEnt
				aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_SAIDA  ] := nQTrSai
				aAuxPai[ADADOS_POS_ADOC_PAI_ID_TRANSF     ] := cIdTransf
				aAuxPai[ADADOS_POS_ADOC_PAI_HWC_DOCFIL    ] := aDocPai[4]
				aAuxPai[ADADOS_POS_ADOC_PAI_QTD_EMPE      ] := 0
				aAuxPai[ADADOS_POS_ADOC_PAI_QTD_SUBS      ] := 0
				aAuxPai[ADADOS_POS_ADOC_PAI_TRT           ] := cTRT
				aAuxPai[ADADOS_POS_ADOC_PAI_OPERACAO      ] := cOperacao

				//Se a revisão do registro é diferente da aglutinada, será desconsiderada a revisão e adotará a revisão atual do produto
				If aDados[ADADOS_POS_REVISAO] <> cRevisao
					If ::oDados:oLogs:logAtivado()
						cChaveLog := ::oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
						::oDados:oLogs:gravaLog("calculo", cChaveLog, {"Revisao da demanda ignorada pois esta aglutinando registros com revisoes diferentes."}, .F. /*lWrite*/)
					EndIf
					aDados[ADADOS_POS_REVISAO] := ""
				EndIf

				aAdd(aDados[ADADOS_POS_ADOC_PAI], aAuxPai)
			Else
				If nQuantidade > 0 .Or. nQtrEnt > 0 .Or. nQTrSai > 0
					aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_QTD]            += nQuantidade
					aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA] += nQtrEnt
					aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_TRANSF_SAIDA]   += nQtrSai
				Else
					aDel(aDados[ADADOS_POS_ADOC_PAI], nPos)
					aSize(aDados[ADADOS_POS_ADOC_PAI], Len(aDados[ADADOS_POS_ADOC_PAI])-1)
				EndIf
			EndIf

			If ::oDados:oLogs:logAtivado()
				cChaveLog := ::oDados:oLogs:montaChaveLog(cFilAux, cProduto, cIDOpc, nPeriodo)
				::oDados:oLogs:gravaLog("calculo", cChaveLog, {"Atualizado o documento aglutinado " + RTrim(aDados[ADADOS_POS_DOCUMENTO]) + " adicionando " + IIf(lDemanda, "a demanda", "o documento " + RTrim(aDocPai[4]) + " referente ao produto pai " + RTrim(aDocPai[3])) + " com necessidade de " + cValToChar(nQuantidade)}, .F. /*lWrite*/)
			EndIf
		EndIf
		::oAglutinacao:setItemAList(cLista, cChave, aDados)
		cLista := cListaBkp
		If lAglutina
			::oAglutinacao:setFlag(cLista + chr(13) + cChave, .T.)
			::oAglutinacao:setItemAList(cLista, cChave, aDados)
		EndIf

	Else
		aAuxPai := Array(ADADOS_POS_ADOC_PAI_TAMANHO)
		aDados  := Array(ADADOS_TAMANHO)

		aAuxPai[ADADOS_POS_ADOC_PAI_ORI           ] := aDocPai[ADADOS_POS_ADOC_PAI_ORI]
		aAuxPai[ADADOS_POS_ADOC_PAI_DOC           ] := aDocPai[ADADOS_POS_ADOC_PAI_DOC]
		aAuxPai[ADADOS_POS_ADOC_PAI_QTD           ] := nQuantidade
		aAuxPai[ADADOS_POS_ADOC_PAI_PRODUTO       ] := aDocPai[3]
		aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA] := nQtrEnt
		aAuxPai[ADADOS_POS_ADOC_PAI_TRANSF_SAIDA  ] := nQTrSai
		aAuxPai[ADADOS_POS_ADOC_PAI_ID_TRANSF     ] := cIdTransf
		aAuxPai[ADADOS_POS_ADOC_PAI_HWC_DOCFIL    ] := aDocPai[4]
		aAuxPai[ADADOS_POS_ADOC_PAI_QTD_EMPE      ] := 0
		aAuxPai[ADADOS_POS_ADOC_PAI_QTD_SUBS      ] := 0
		aAuxPai[ADADOS_POS_ADOC_PAI_TRT           ] := cTRT
		aAuxPai[ADADOS_POS_ADOC_PAI_OPERACAO      ] := cOperacao

		aDados[ADADOS_POS_ORIGEM     ] := cOrigem
		aDados[ADADOS_POS_DOCUMENTO  ] := cDocumento
		aDados[ADADOS_POS_PRODUTO    ] := cProduto
		aDados[ADADOS_POS_ID_OPCIONAL] := cIDOpc
		aDados[ADADOS_POS_TRT        ] := cTRT
		aDados[ADADOS_POS_QUANTIDADE ] := nQuantidade
		aDados[ADADOS_POS_PERIODO    ] := nPeriodo
		aDados[ADADOS_POS_ADOC_PAI   ] := {aAuxPai}
		aDados[ADADOS_POS_ROTEIRO    ] := cRoteiro
		aDados[ADADOS_POS_OPERACAO   ] := cOperacao
		aDados[ADADOS_POS_AGLUTINA   ] := lAglutina
		aDados[ADADOS_POS_FILIAL     ] := cFilAux
		aDados[ADADOS_POS_REVISAO    ] := cRevisao
	EndIf

	If lDemanda .Or. (cLista != "4" .And. cLista != "6")
		::oAglutinacao:destrava(cChave)
	EndIf

Return aDados

//********************************************************/
/*OUTROS MÉTODOS                                         */
//********************************************************/

/*/{Protheus.doc} avaliaAglutinacao
Avalia necessidade de aglutinação
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - cFilAux , caracter, código da filial para processamento
@param 02 - cProduto, caracter, código do produto para análise
@param 03 - lDemanda, lógico  , indica se a análise deve ser feita para carga de Demandas
@param 04 - cOrigem , caracter, origem da demanda
@return lAglutina, lógico, indica se deverá realizar a aglutinação
/*/
METHOD avaliaAglutinacao(cFilAux, cProduto, lDemanda, cOrigem) CLASS MrpDominio_Aglutina

	Local lAglutina := .F.

	Default lDemanda := .F.
	Default cOrigem  := ""

	If ::oDados:possuiEstrutura(cFilAux, cProduto)
		If cOrigem != "1" //Se a origem não é um Plano Mestre
			If ::cAglutinaOP == "2" .OR. (::cAglutinaOP == "3" .AND. !lDemanda)
				lAglutina := .F.
			Else
				lAglutina := .T.
			EndIf
		Else
			//Se for um PMP, irá aglutinar somente se o parâmetro estiver
			//selecionado para aglutinar tudo.
			If ::cAglutinaOP == "1"
				lAglutina := .T.
			Else
				lAglutina := .F.
			EndIf
		EndIf
	Else
		If cOrigem != "1" //Se a origem não é um Plano Mestre
			If ::cAglutinaSC == "2" .OR. (::cAglutinaSC == "3" .AND. !lDemanda)
				lAglutina := .F.
			Else
				lAglutina := .T.
			EndIf
		Else
			//Se for um PMP, irá aglutinar somente se o parâmetro estiver
			//selecionado para aglutinar tudo.
			If ::cAglutinaSC == "1"
				lAglutina := .T.
			Else
				lAglutina := .F.
			EndIf
		EndIf
	EndIf

Return lAglutina

/*/{Protheus.doc} getPosicao
Avalia necessidade de aglutinação
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - cCampo, caracter, string com o nome do campo relacionado aos dados de rastreabilidade
@Return nReturn, número, posição padrão do registro no array de dados
/*/
METHOD getPosicao(cCampo) CLASS MrpDominio_Aglutina

	Local nReturn := 0

	Do Case
		Case cCampo == "ORIGEM"
			nReturn := ADADOS_POS_ORIGEM
		Case cCampo == "DOCUMENTO"
			nReturn := ADADOS_POS_DOCUMENTO
		Case cCampo == "PRODUTO"
			nReturn := ADADOS_POS_PRODUTO
		Case cCampo == "TRT"
			nReturn := ADADOS_POS_TRT
		Case cCampo == "QUANTIDADE"
			nReturn := ADADOS_POS_QUANTIDADE
		Case cCampo == "PERIODO"
			nReturn := ADADOS_POS_PERIODO
		Case cCampo == "ADOC_PAI"
			nReturn := ADADOS_POS_ADOC_PAI
		Case cCampo == "ADOC_PAI_ORI"
			nReturn := ADADOS_POS_ADOC_PAI_ORI
		Case cCampo == "ADOC_PAI_DOC"
			nReturn := ADADOS_POS_ADOC_PAI_DOC
		Case cCampo == "ADOC_PAI_PRODUTO"
			nReturn := ADADOS_POS_ADOC_PAI_PRODUTO
		Case cCampo == "ADOC_PAI_QTD"
			nReturn := ADADOS_POS_ADOC_PAI_QTD
		Case cCampo == "ADOC_PAI_QTD_EMPE"
			nReturn := ADADOS_POS_ADOC_PAI_QTD_EMPE
		Case cCampo == "ADOC_PAI_QTD_SUBS"
			nReturn := ADADOS_POS_ADOC_PAI_QTD_SUBS
		Case cCampo == "AGLUTINA"
			nReturn := ADADOS_POS_AGLUTINA
		Case cCampo == "ROTEIRO"
			nReturn := ADADOS_POS_ROTEIRO
		Case cCampo == "OPERACAO"
			nReturn := ADADOS_POS_OPERACAO
		Case cCampo == "FILIAL"
			nReturn := ADADOS_POS_FILIAL
		Case cCampo == "TRANSF_ENTRADA"
			nReturn := ADADOS_POS_ADOC_PAI_TRANSF_ENTRADA
		Case cCampo == "TRANSF_SAIDA"
			nReturn := ADADOS_POS_ADOC_PAI_TRANSF_SAIDA
		Case cCampo == "ID_TRANSF"
			nReturn := ADADOS_POS_ADOC_PAI_ID_TRANSF
		Case cCampo == "ADOC_PAI_HWC_DOCFIL"
			nReturn := ADADOS_POS_ADOC_PAI_HWC_DOCFIL
		Case cCampo == "ADOC_PAI_TRT"
			nReturn := ADADOS_POS_ADOC_PAI_TRT
		Case cCampo == "ADOC_PAI_OPERACAO"
			nReturn := ADADOS_POS_ADOC_PAI_OPERACAO
		Case cCampo == "REVISAO"
			nReturn := ADADOS_POS_REVISAO
	EndCase

Return nReturn


//********************************************************/
/*MÉTODOS UTILIZADOS DURANTE O CALCULO DO MRP            */
//********************************************************/

/*/{Protheus.doc} preparaEInclui
Avalia necessidade de aglutinação e inclui a rastreabilidade
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - cFilAux, caracter, código da filial para processamento
@param 02 - cLista , caracter, código da lista identificadora da tabela utilizada:
                              1 = Carga de Demandas (PCPCargDem)
							  2 = Carga de Empenhos
							  3 = Carga de outras Saídas Previstas
							  4 = Explosão da Estrutura
@param 03 - cOrigem    , caracter, identificador de origem do registro
@param 04 - aDocPai    , array   , {Tipo do Documento Pai,
                                    Documento Pai,
									Produto Pai,
									Documento Filho do Pai}
@param 05 - cDocumento , caracter, identificador do documento - retorna por referência
@param 06 - cProduto   , caracter, código do produto
@param 07 - cIDOpc     , caracter, código do ID do Opcional
@param 08 - cTRT       , caracter, código do TRT
@param 09 - nQuantidade, número  , quantidade da necessidade
@param 10 - nPeriodo   , número  , período da necessidade
@param 11 - cRegra     , caracter,  regra de consumo dos alternativos:
								1- Valida Original; Valida Alternativo; Compra Original
								2- Valida Original; Valida Alternativo; Compra Alternativo
								3- Valida Alternativo; Compra Alternativo
@param 12 - lAglutina  , lógico  , indica se deve considerar aglutinação na chave do registro
@param 13 - lQuebra    , lógico  , indica origem em quebra de Lote Econômico ou Qtd. Embalagem (nIndQuebra > 1)
@param 14 - cRoteiro   , caracter, código do roteiro de operações do produto Pai
@param 15 - cOperacao  , caracter, código da operação deste componente no roteiro do produto Pai
@param 16 - nQtrEnt    , número  , quantidade de transferência de entrada
@param 17 - nQtrSai    , número  , quantidade de transferência de saída
@param 18 - cIdTransf  , caracter, ID de transferência do registro origem
@param 19 - cRevisao   , caracter, Revisão do produto
@return cList, caracter, identificador desta sessão de variáveis globais
@version   1
@return aDados, array, aDados,array com os dados para inclusão da necessidade:
                    {1 - Origem,
					 2 - Documento,
					 3 - Produto,
					 4 - TRT,
					 5 - Quantidade,
					 6 - Período,
					 7 - Array Doc Pai{Tipo Oridem Doc Pai, Documento, Quantidade},
					 8 - lAglutina relacionado}
/*/
METHOD preparaEInclui(cFilAux, cLista, cOrigem, aDocPai, cDocumento, cProduto, cIDOpc, cTRT, nQuantidade, nPeriodo, ;
                      cRegra, lAglutina, lQuebra, cRoteiro, cOperacao, nQtrEnt, nQtrSai, cIdTransf, cRevisao) CLASS MrpDominio_Aglutina

	Local aDados     := {}
	Local oRastreio  := ::oDados:oDominio:oRastreio

	Default cIDOpc   := ""
	Default nQtrEnt  := 0
	Default nQtrSai  := 0
	Default cRevisao := ""

	aDados := ::prepara(cFilAux         ,;
	                    cLista          ,;
						cOrigem         ,;
						aDocPai         ,;
						@cDocumento     ,;
						cProduto        ,;
						cIDOpc          ,;
						cTRT            ,;
						nQuantidade     ,;
						nPeriodo        ,;
						cRegra          ,;
						.F. /*lDemanda*/,;
	                    lAglutina       ,;
						lQuebra         ,;
						cRoteiro        ,;
						cOperacao       ,;
						nQtrEnt         ,;
						nQtrSai         ,;
						cIdTransf       ,;
						/*cLocal*/      ,;
						cRevisao)

	oRastreio:incluiNecessidade(cFilAux                     ,;
	                            aDados[ADADOS_POS_ORIGEM]   ,;
								aDados[ADADOS_POS_DOCUMENTO],;
								aDados[ADADOS_POS_PRODUTO]  ,;
								cIDOpc                      ,;
								aDados[ADADOS_POS_TRT]      ,;
								nQuantidade                 ,;
								aDados[ADADOS_POS_PERIODO]  ,;
								/*cListOrig*/               ,;
								cRegra                      ,;
								/*cOrdSubst*/               ,;
								cRoteiro                    ,;
								aDados[ADADOS_POS_OPERACAO] ,;
								nQtrEnt                     ,;
								nQtrSai                     ,;
								/*cDocFilho*/               ,;
								/*nSaldo*/                  ,;
								/*lSubsTran*/               ,;
								/*cLocal*/                  ,;
								cRevisao)

Return aDados

//********************************************************/
/*MÉTODOS UTILIZADOS DURANTE A EXPORTAÇÃO DO MRP         */
//********************************************************/

/*/{Protheus.doc} ajustesExportacao
Efetua ajustes de empenho e substituição nos registros da aglutinação que serão efetivados na HWG
@author    brunno.costa
@since     10/12/2019
@version   1
@param 01 - aAglutinacao, array, array com os dados da aglutinação que serão inseridos na HWG passados por referência
@param 02 - aNovasAglu  , array, array com os dados das novas aglutinações retornado por referência - alternativos
/*/
METHOD ajustesExportacao(aAglutinacao, aNovasAglu)  CLASS MrpDominio_Aglutina

	Local aAlteDeman  := {} //Códigos dos Alternativos da Substituição
	Local aRastreio   := {}
	Local cProduto    := ""
	Local nDocItem    := 0
	Local nDoctos     := Len(aAglutinacao[ADADOS_POS_ADOC_PAI])
	Local cDocumento  := ""
	Local cIDOpc      := ""
	Local cTRT        := ""
	Local cTrtHwg     := ""
	Local cFilAux     := ""
	Local nPeriodo    := 0
	Local nNecOriDoc  := 0
	Local nEmpenho    := 0
	Local nSubstitui  := 0
	Local nTotSubAux  := 0
	Local nTotalSubs  := 0
	Local oJSConAlt   := JsonObject():New()

	Default aNovasAglu := {}

	If nDoctos > 0
		aSort(aAglutinacao[ADADOS_POS_ADOC_PAI],,,{|x,y|x[ADADOS_POS_ADOC_PAI_QTD] < y[ADADOS_POS_ADOC_PAI_QTD]})
	EndIf

	cFilAux    := aAglutinacao[ADADOS_POS_FILIAL]
	cProduto   := aAglutinacao[ADADOS_POS_PRODUTO]
	nPeriodo   := aAglutinacao[ADADOS_POS_PERIODO]
	cDocumento := aAglutinacao[ADADOS_POS_DOCUMENTO]
	cTRT       := aAglutinacao[ADADOS_POS_TRT]
	cIDOpc     := aAglutinacao[ADADOS_POS_ID_OPCIONAL]
	aRastreio  := ::retornaRastreio(cFilAux, cProduto + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, cDocumento, cTRT)
	nTotSubAux := aRastreio[::nIndRSubst]
	nTotalSubs := nTotSubAux
	For nDocItem := 1 to nDoctos
		nSubstitui := 0
		nEmpenho   := 0
		nNecOriDoc := aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_QTD]
		cTrtHwg    := aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_TRT]

		If nNecOriDoc >= nTotSubAux
			nSubstitui := nTotSubAux
			nTotSubAux := 0
			nEmpenho   := nNecOriDoc - nSubstitui

		ElseIf nNecOriDoc < nTotSubAux
			If nNecOriDoc >= 0
				If nTotSubAux > 0
					nSubstitui := nNecOriDoc
					nTotSubAux -= nSubstitui
				EndIf
			EndIf
			nEmpenho   := nNecOriDoc - nSubstitui

		EndIf

		aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_QTD_EMPE] := nEmpenho
		aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_QTD_SUBS] := nSubstitui

		If nSubstitui > 0
			aAlteDeman := ::retornaAlternativos(cFilAux, cProduto, nPeriodo)
			::geraRegistrosAlternativos(cFilAux, cProduto, nPeriodo, cDocumento, cTRT                        ,;
			                            aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_ORI]    ,;
			                            aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_DOC]    ,;
			                            aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_PRODUTO],;
			                            aAlteDeman, @aNovasAglu, nSubstitui, @oJSConAlt                         ,;
			                            aAglutinacao[ADADOS_POS_ADOC_PAI][nDocItem][ADADOS_POS_ADOC_PAI_HWC_DOCFIL], cTrtHwg)
			aSize(aAlteDeman, 0)
			aAlteDeman := Nil
		EndIf
	Next
	aSize(aRastreio, 0)
	aRastreio := Nil

	FreeObj(oJSConAlt)
	oJSConAlt := Nil

Return

/*/{Protheus.doc} geraRegistrosAlternativos
Gera registros referente alternativos
@author    brunno.costa
@since     10/12/2019
@version   1
@param 01 - cFilAux   , caracter, código da filial para processamento
@param 02 - cProduto  , caracter, código do produto relacionado
@param 03 - nPeriodo  , número  , período relacionado
@param 04 - cDocumento, caracter, código do documento relacionado
@param 05 - cTRT      , caracter, código do TRT registrado na hwc.
@param 06 - cTpDocOri , caracter, tipo do documento pai relacionado
@param 07 - cDocOri   , caracter, documento pai relacionado
@param 08 - cProdOri  , caracter, código do produto pai
@param 09 - aAlteDeman, array   , array com os códigos dos alternativos
@param 10 - aNovasAglu, array   , array retornado por referência com as novas linhas de aglutinação para exportação
@param 11 - nSubstitui, número  , quantidade do produto original para substituição
@param 12 - oJSConAlt , objeto  , JSON de controle do saldo dos alternativos já consumidos
@param 13 - cDocFilHWC, caracter, documento filho do documento pai/origem relacionado
@param 14 - cTrtHwg   , caracter, código TRT que será utilizada para gerar o registro da hwg
/*/
METHOD geraRegistrosAlternativos(cFilAux, cProduto, nPeriodo, cDocumento, cTRT, cTpDocOri, cDocOri, cProdOri, aAlteDeman, aNovasAglu, nSubstitui, oJSConAlt, cDocFilHWC, cTrtHwg)  CLASS MrpDominio_Aglutina
	Local aAlternati := {}
	Local aDocPaiIt  := {}
	Local cAlternati := ""
	Local cChvJSAlt  := ""
	Local cListOrig  := ""
	Local nAlternati := Len(aAlteDeman)
	Local nEmpAltern := 0
	Local nSubstAlte := 0
	Local nIndAlt    := 0
	Local nSldAlt    := 0

	For nIndAlt := 1 to nAlternati
		nSubstitui := ::oAlternativo:aplicaProdutoFator(cFilAux, cProduto, aAlteDeman[nIndAlt][1], nSubstitui, .F.)
		If nSubstitui <= 0
			Exit
		EndIf

		aSize(aDocPaiIt, 0)
		cAlternati := aAlteDeman[nIndAlt][1]
		cListOrig  := cFilAux + cProduto + chr(13) + cValToChar(nPeriodo)
		aAlternati := ::retornaRastreio(cFilAux, cAlternati, nPeriodo, cDocumento, cTRT, cListOrig)

		If Empty(aAlternati)
			Loop
		EndIf

		cChvJSAlt := cAlternati + chr(13) + cValToChar(nPeriodo) + chr(13) + cDocumento + chr(13) + cTRT

		//Avalia Saldo Substituição do Produto Alternativo
		If oJSConAlt[cChvJSAlt] == Nil
			nSldAlt              := aAlternati[::nIndRSubst]
			oJSConAlt[cChvJSAlt] := nSldAlt
		Else
			nSldAlt := oJSConAlt[cChvJSAlt]
		EndIf

		If nSldAlt == 0
			Loop
		EndIf

		If Abs(nSldAlt) <= Abs(nSubstitui)
			nSubstAlte := nSldAlt
		Else
			nSubstAlte := -(nSubstitui)
		EndIf
		nSubstitui += nSubstAlte
		nEmpAltern := aAlternati[::nIndRNecOr] - nSubstAlte
		oJSConAlt[cChvJSAlt] += Abs(nSubstAlte)

		aAdd(aNovasAglu, ::prepara(cFilAux,;
		                           "5",;
		                           "OP",;
								   {cTpDocOri, cDocOri, cProdOri, cDocFilHWC},;
								   cDocumento,;
								   cAlternati,;
								   "",;
								   cTrtHwg,;
		                           aAlternati[::nIndRNecOr],;
								   nPeriodo,;
								   aAlternati[::nIndRegra],;
								   .F.,;
								   .F.))

		aTail(aTail(aNovasAglu)[ADADOS_POS_ADOC_PAI])[ADADOS_POS_ADOC_PAI_QTD_EMPE] := nEmpAltern
		aTail(aTail(aNovasAglu)[ADADOS_POS_ADOC_PAI])[ADADOS_POS_ADOC_PAI_QTD_SUBS] := nSubstAlte

	Next
Return

/*/{Protheus.doc} retornaRastreio
Retorna registro aRastreio relacionado
@author    brunno.costa
@since     10/12/2019
@version   1
@param 01 - cFilAux  , caracter, código da filial para processamento
@param 02 - cProduto , caracter, código do produto
@param 03 - nPeriodo , número  , número do período
@param 04 - cDocPai  , caracter, código do documento pai do registro
@param 05 - cTRT     , caracter, código do TRT do produto na estrutura
@param 06 - cListOrig, caracter, chave do registro original do Rastreio, quando alternativo
@return aRastreio, array, array com os dados do rastreio deste registro
/*/
METHOD retornaRastreio(cFilAux, cProduto, nPeriodo, cDocPai, cTRT, cListOrig)  CLASS MrpDominio_Aglutina
Return ::oDados:oDominio:oRastreio:retornaRastreio(cFilAux, cProduto, nPeriodo, cDocPai, cTRT, cListOrig)

/*/{Protheus.doc} retornaAlternativos
Retorna registros referente alternativos aAlteDeman
@author    brunno.costa
@since     10/12/2019
@version   1
@param 01 - cFilAux, caracter, código da filial para processamento
@param 02 - cProduto, caracter, código do componente relacionado
@param 03 - nPeriodo , número  , número do período
@Return aAlteDeman, array, array com os códigos dos produtos alternativos consumidos
/*/
METHOD retornaAlternativos(cFilAux, cProduto, nPeriodo)  CLASS MrpDominio_Aglutina
Return ::oDados:oDominio:oRastreio:retornaAlternativos(cFilAux + cProduto, nPeriodo)

/*/{Protheus.doc} processamentoAglutinado
Retorna se os parâmetros estão definidos para usar aglutinação
@author    marcelo.neumann
@since     30/11/2020
@version   1
@Return lAglutina, lógico, indica se está usando aglutinação
/*/
METHOD processamentoAglutinado()  CLASS MrpDominio_Aglutina
	Local lAglutina := .T.

	If ::cAglutinaSC == "2" .And. ::cAglutinaOP == "2"
		lAglutina := .F.
	EndIf

Return lAglutina


//********************************************************/
/*MÉTODOS UTILIZADOS DURANTE O PROCESSAMENTO E CONCLUSÃO */
//********************************************************/

/*/{Protheus.doc} proximoIDAuto
Identifica o próximo ID Automático
@author    brunno.costa
@since     21/11/2019
@version   1
@param 01 - cLista, caracter, código da lista identificadora da tabela utilizada:
                              1 = Carga de Demandas (PCPCargDem)
							  2 = Carga de Empenhos
@return cIDAuto, próximo ID Automático
/*/
METHOD proximoIDAuto(cLista)  CLASS MrpDominio_Aglutina

	Local cIDAuto := ""

	::oAglutinacao:trava(cLista + chr(13) + "cIDAuto" + chr(13))

	cIDAuto := ::oAglutinacao:getFlag(cLista + chr(13) + "cIDAuto" + chr(13))
	cIDAuto := Soma1(cIDAuto)
	::oAglutinacao:setFlag(cLista + chr(13) + "cIDAuto" + chr(13), cIDAuto)

	::oAglutinacao:destrava(cLista + chr(13) + "cIDAuto" + chr(13))

Return cIDAuto

/*/{Protheus.doc} deletaAglutinado
Deleta as informações de aglutinação

@author    lucas.franca
@since     16/12/2020
@version 1.0
@param 01 - cFilAux , Character, Código da filial de processamento
@param 02 - cLista  , Character, código da lista identificadora da tabela utilizada
@param 03 - cProduto, Character, Código do produto
@param 04 - nPeriodo, Numeric  , Número do período
@param 05 - aDocPai , Array    , Informações do documento pai.
                                 [1] - Tipo do documento pai
                                 [2] - Número do documento pai
                                 [3] - Produto pai
@param 06 - cTrt    , Character, Trt do produto na estrutura.
@return nQtdDel, Numeric, Quantidade que foi deletada
/*/
METHOD deletaAglutinado(cFilAux, cLista, cProduto, nPeriodo, aDocPai, cTrt) CLASS MrpDominio_Aglutina
	Local aDados     := {}
	Local cChave     := ""
	Local cChaveLog  := ""
	Local lError     := .F.
	Local lAglutina  := Self:avaliaAglutinacao(cFilAux, cProduto)
	Local nPos       := 0
	Local nQtdDel    := 0

	//Identifica a Chave do Rastreio
	If lAglutina
		cChave := cFilAux + cValToChar(nPeriodo) + cProduto
		Self:oAglutinacao:getFlag(cLista + chr(13) + cChave, @lError)

		If !lError
			Self:oAglutinacao:trava(cChave)

			aDados := Self:oAglutinacao:getItemAList(cLista, cChave)

			If Self:oDados:oLogs:logAtivado()
				cChaveLog := Self:oDados:oLogs:montaChaveLog(cFilAux, cProduto, aDados[ADADOS_POS_ID_OPCIONAL], nPeriodo)
			EndIf

			While .T.
				nPos := aScan(aDados[ADADOS_POS_ADOC_PAI], {|x|  x[ADADOS_POS_ADOC_PAI_ORI]     == aDocPai[1];
				                                           .And. (aDocPai[2] + CHR(13) $ x[ADADOS_POS_ADOC_PAI_DOC] ;
				                                            .Or.  aDocPai[2] == x[ADADOS_POS_ADOC_PAI_DOC]);
				                                           .And. x[ADADOS_POS_ADOC_PAI_PRODUTO] == aDocPai[3];
				                                           .And. (!::gravaTrtNaHWG() .Or. x[ADADOS_POS_ADOC_PAI_TRT] == cTrt)})

				If nPos == 0
					Exit
				EndIf

				If Self:oDados:oLogs:logAtivado()
					Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Atualizado o documento aglutinado " + RTrim(aDados[ADADOS_POS_DOCUMENTO]) + " removendo o documento " + RTrim(aDocPai[2]) + " referente ao produto pai " + RTrim(aDocPai[3]) + " com a quantidade de " + cValToChar(aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_QTD])}, .F. /*lWrite*/)
				EndIf

				nQtdDel                       += aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_QTD]
				aDados[ADADOS_POS_QUANTIDADE] -= aDados[ADADOS_POS_ADOC_PAI][nPos][ADADOS_POS_ADOC_PAI_QTD]
				aDados[ADADOS_POS_ADOC_PAI  ] := aDel(aDados[ADADOS_POS_ADOC_PAI], nPos)
				aSize(aDados[ADADOS_POS_ADOC_PAI], Len(aDados[ADADOS_POS_ADOC_PAI])-1)
			End

			If aDados[ADADOS_POS_QUANTIDADE] == 0 .And. Len(aDados[ADADOS_POS_ADOC_PAI]) == 0
				//Apaga as informações de aglutinação, pois tudo foi apagado.
				Self:oAglutinacao:delItemAList(cLista, cChave, @lError)
				Self:oAglutinacao:delFlag(cLista + chr(13) + cChave, @lError)

				If Self:oDados:oLogs:logAtivado()
					Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Removida a aglutinacao do produto " + RTrim(cProduto) + " na filial " + cFilAux + " e periodo " + cValToChar(nPeriodo)}, .F. /*lWrite*/)
				EndIf
			Else
				//Atualiza as informações de aglutinação, pois ainda existem dados.
				Self:oAglutinacao:setItemAList(cLista, cChave, aDados)

				If Self:oDados:oLogs:logAtivado()
					Self:oDados:oLogs:gravaLog("calculo", cChaveLog, {"Alterada a aglutinacao do produto " + RTrim(cProduto) + " na filial " + cFilAux + " e periodo " + cValToChar(nPeriodo)}, .F. /*lWrite*/)
				EndIf
			EndIf

			Self:oAglutinacao:destrava(cChave)
			aSize(aDados, 0)
		EndIf
	EndIf

Return nQtdDel

/*/{Protheus.doc} retornaDocAglutinado
Verifica se existe um documento aglutinador para o produto

@author lucas.franca
@since 12/03/2021
@version P12
@param 01 - cFilAux    , Character, Código da filial de processamento
@param 02 - nPeriodo   , Numeric  , Número do período
@param 03 - cProduto   , Character, Código do produto
@param 04 - aDocPai    , Array    , Informações do documento pai.
                                    [1] - Tipo do documento pai
                                    [2] - Número do documento pai
                                    [3] - Produto pai
@param 05 - cTrt       , Character, Trt do produto na estrutura.
@return cDocAgl, Character, Documento aglutinador
/*/
Method retornaDocAglutinado(cFilAux, nPeriodo, cProduto, aDocPai, cTrt) CLASS MrpDominio_Aglutina
	Local aDados  := {}
	Local cDocAgl := ""
	Local lError  := .F.
	Local nPos    := 0

	::oDados:oDominio:oAglutina:oAglutinacao:getFlag("4" + chr(13) + cFilAux + cValToChar(nPeriodo) + cProduto, @lError)
	If !lError
		aDados := ::oDados:oDominio:oAglutina:oAglutinacao:getItemAList("4", cFilAux + cValToChar(nPeriodo) + cProduto)
		If aDados != Nil .And. Len(aDados) > 0
			nPos := aScan(aDados[ADADOS_POS_ADOC_PAI], {|x|  x[ADADOS_POS_ADOC_PAI_ORI]     == aDocPai[1];
			                                           .And. (aDocPai[2] + CHR(13) $ x[ADADOS_POS_ADOC_PAI_DOC] ;
			                                            .Or.  aDocPai[2] == x[ADADOS_POS_ADOC_PAI_DOC]);
			                                           .And. x[ADADOS_POS_ADOC_PAI_PRODUTO] == aDocPai[3];
			                                           .And. (!::gravaTrtNaHWG() .Or. x[ADADOS_POS_ADOC_PAI_TRT] == cTrt)})

			If nPos > 0
				cDocAgl := aDados[ADADOS_POS_DOCUMENTO]
			EndIf
			aSize(aDados, 0)
		EndIf
	EndIf
Return cDocAgl

/*/{Protheus.doc} novoIdAglutinacao
Gera novo ID para registrar uma aglutinação de necessidade (TIPO_PAI=AGL)

@author    lucas.franca
@since     06/01/2021
@version 1.0
@return cNewId, Character, Identificador criado.
/*/
METHOD novoIdAglutinacao() CLASS MrpDominio_Aglutina
	Local cNewId  := ""
	Local lError  := .F.
	Local nVal    := 0

	::oAglutinacao:setFlag("IDAGL", @nVal, @lError, , .T., .T.)

	If lError .Or. nVal < 1
		cNewId := "AGL0000001"
	Else
		cNewId := "AGL" + StrZero(nVal, 7)
	EndIf

Return cNewId

/*/{Protheus.doc} retornaEmpNegativo
Retorna a quantidade negativa de um empenho aglutinado

@author lucas.franca
@since 03/11/2021
@version P12
@param 01 - cFilAux    , Character, Código da filial de processamento
@param 02 - nPeriodo   , Numeric  , Número do período
@param 03 - cProduto   , Character, Código do produto
@return nQtdNeg, Numeric, Quantidade negativa do empenho
/*/
METHOD retornaEmpNegativo(cFilAux, nPeriodo, cProduto) CLASS MrpDominio_Aglutina
	Local aDados  := {}
	Local lError  := .F.
	Local nQtdNeg := 0
	Local nIndex  := 0
	Local nTotal  := 0

	::oDados:oDominio:oAglutina:oAglutinacao:getFlag("2" + chr(13) + cFilAux + cValToChar(nPeriodo) + cProduto, @lError)
	If !lError
		aDados := ::oDados:oDominio:oAglutina:oAglutinacao:getItemAList("2", cFilAux + cValToChar(nPeriodo) + cProduto)
		If aDados != Nil .And. Len(aDados) > 0
			nTotal := Len(aDados[ADADOS_POS_ADOC_PAI])
			For nIndex := 1 To nTotal
				If aDados[ADADOS_POS_ADOC_PAI][nIndex][ADADOS_POS_ADOC_PAI_QTD] < 0
					nQtdNeg += aDados[ADADOS_POS_ADOC_PAI][nIndex][ADADOS_POS_ADOC_PAI_QTD]
				EndIf
			Next nIndex

			aSize(aDados, 0)
		EndIf
	EndIf

Return nQtdNeg

/*/{Protheus.doc} usaDocFilho
Indica se o dicionário está atualizado com a coluna HWG_DOCFIL

@author marcelo.neumann
@since 03/03/2022
@version P12
@return lUsaDocFil, Logic, Indica se existe a coluna HWG_DOCFIL no dicionário
/*/
METHOD usaDocFilho() CLASS MrpDominio_Aglutina

	If Self:lUsaDocFil == Nil
		dbSelectArea("HWG")
		Self:lUsaDocFil := (FieldPos("HWG_DOCFIL") > 0)  //Coluna criada na 12.1.37
	EndIf

Return Self:lUsaDocFil

/*/{Protheus.doc} gravaTrtNaHWG
Verifica se o dicionario está atualizado com a coluna HWG_TRT
@author Lucas Fagundes
@since 05/05/2023
@version P12
@return Self:lTrtHWG, Logico, Indica se existe a coluna HWG_TRT no dicionario
/*/
METHOD gravaTrtNaHWG() CLASS MrpDominio_Aglutina

	If Self:lTrtHWG == Nil
		dbSelectArea("HWG")
		Self:lTrtHWG := FieldPos("HWG_TRT") > 0
	EndIf

Return Self:lTrtHWG
