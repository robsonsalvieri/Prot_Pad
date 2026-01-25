#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE AENTRADAS_POS_DOCUMENTO        1
#DEFINE AENTRADAS_POS_ITEM             2
#DEFINE AENTRADAS_POS_ALIAS            3
#DEFINE AENTRADAS_POS_PERIODO          4
#DEFINE AENTRADAS_POS_QUANTIDADE       5
#DEFINE AENTRADAS_POS_CONTROLE_QTD     6
#DEFINE AENTRADAS_POS_POSSUI_LOG       7
#DEFINE AENTRADAS_POS_PRIMEIRO_CONSUMO 8
#DEFINE AENTRADAS_POS_PRIORIDADE       9
#DEFINE AENTRADAS_POS_DATA             10

#DEFINE ACONSUMOS_POS_PERIODO       1
#DEFINE ACONSUMOS_POS_CONSUMO       2
#DEFINE ACONSUMOS_POS_CONTROLE_QTD  3
#DEFINE ACONSUMOS_POS_PPEDIDO       4
#DEFINE ACONSUMOS_TAMANHO           4       

#DEFINE iLISTA       1
#DEFINE iDADOS       2
#DEFINE iDADOS_CHAVE 1
#DEFINE iDADOS_DADOS 2

#DEFINE EVENTO_001_POS_SALDO_INICIAL 1

#DEFINE EVENTO_002_POS_DATA_ORIGINAL 1 // Data Periodo
#DEFINE EVENTO_002_POS_DOCUMENTO     2
#DEFINE EVENTO_002_POS_ITEM          3
#DEFINE EVENTO_002_POS_ALIAS         4
#DEFINE EVENTO_002_POS_DATA_DOC      5 // Data Documento
#DEFINE EVENTO_002_POS_DATA_ATRASAR  6 // Data Para Atrasar

#DEFINE EVENTO_003_POS_DATA_ORIGINAL 1 // Data Periodo
#DEFINE EVENTO_003_POS_DOCUMENTO     2
#DEFINE EVENTO_003_POS_ITEM          3
#DEFINE EVENTO_003_POS_ALIAS         4
#DEFINE EVENTO_003_POS_DATA_DOC      5 // Data Documento
#DEFINE EVENTO_003_POS_DATA_ADIANTAR 6 // Data Para Adiantar

#DEFINE EVENTO_004_POS_PRODUTO_ORIGINADOR 1
#DEFINE EVENTO_004_POS_QUANTIDADE         2
#DEFINE EVENTO_004_POS_DATA_CALCULADA     3
#DEFINE EVENTO_004_POS_DOCUMENTO          4
#DEFINE EVENTO_004_POS_ITEM               5
#DEFINE EVENTO_004_POS_ALIAS              6
#DEFINE EVENTO_004_POS_TRT                7

#DEFINE EVENTO_005_POS_PRODUTO_ORIGINADOR 1
#DEFINE EVENTO_005_POS_QUANTIDADE         2
#DEFINE EVENTO_005_POS_DATA_CALCULADA     3
#DEFINE EVENTO_005_POS_ALIAS              4
#DEFINE EVENTO_005_POS_DOCUMENTO          5

#DEFINE EVENTO_006_POS_DATA_ATRASO   1
#DEFINE EVENTO_006_POS_DOCUMENTO     2
#DEFINE EVENTO_006_POS_ITEM          3
#DEFINE EVENTO_006_POS_ALIAS         4

#DEFINE EVENTO_007_POS_DATA          1
#DEFINE EVENTO_007_POS_DOCUMENTO     2
#DEFINE EVENTO_007_POS_ITEM          3
#DEFINE EVENTO_007_POS_ALIAS         4
#DEFINE EVENTO_007_POS_DATA_DOC      5

#DEFINE EVENTO_009_POS_PONTO_PEDIDO  1
#DEFINE EVENTO_009_POS_SALDO_ESTOQUE 2
#DEFINE EVENTO_009_POS_DATA          3
#DEFINE EVENTO_009_POS_ALIAS         4

#DEFINE EVENTO_010_POS_DATA          1
#DEFINE EVENTO_010_POS_QUANT_QUEBRAS 2

#DEFINE EVENTO_011_POS_CODIGO 1
#DEFINE EVENTO_011_POS_DATA   2

#DEFINE EVENTO_013_POS_DATA          1
#DEFINE EVENTO_013_POS_QUANT_QUEBRAS 2

Static snTamCod      := 90
Static snDecQtd      := 0
Static snIntQtd      := 0
Static snStTamQTD    := 0

/*/{Protheus.doc} MrpDominio_Eventos
Regras de negócio MRP - Log de Eventos

@author    brunno.costa
@since     09/05/2019
@version   1
/*/
CLASS MrpDominio_Eventos FROM LongClassName

	DATA oDominio     AS Object  //instância da camada de domínio
	DATA oDados       AS Object  //instância da camada de dados de eventos
	DATA lHabilitado  AS Logical //Indica se o log de eventos está habilitado

	METHOD new(oDominio) CONSTRUCTOR
	METHOD loga(cEvento, cProduto, dData, aDados, cFilEvent, lForce)

	METHOD incluiEntradas(oEntradas, cAlias)
	METHOD aguardaInclusaoEntradas()
	METHOD analisaDocumentos(aPerProds)
	METHOD compoeConsumosDiarios(cChaveProd, aPerProds, aConsumos, nSldInicial)
	METHOD processaBaixas(cChaveProd, nSldInicial, aEntradas, aConsumos)
	METHOD montaDadosImpressao(cEvento, aEvento, aResultados, aLenFields)
	METHOD pegaDadosLoga(cEvento, cProduto, aEntrada, aConsumo, cFilEvent)
	METHOD possuiEventosForcados()

ENDCLASS

/*/{Protheus.doc} new
Método construtor

@author    brunno.costa
@since     09/05/2019
@version   1
@param 01 - oDominio, Object, objeto da camada de domínio
/*/
METHOD new(oDominio) CLASS MrpDominio_Eventos
	Self:oDominio    := oDominio
	Self:oDados      := oDominio:oDados:oEventos
	Self:lHabilitado := oDominio:oParametros["lEventLog"]
Return Self

/*/{Protheus.doc} incluiEntradas
Inclui as entradas de eventos de uma tabela na gloabal

@author    brunno.costa
@since     09/05/2019
@version   1
@param 01 - oEntradas, Object  , objeto Json com as entradas dos produtos oJsonObject[cChaveProd] := {cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}
@param 02 - cAlias   , Caracter, Alias da tabela que está carregando as entradas.
@return Nil
/*/
METHOD incluiEntradas(oEntradas, cAlias) CLASS MrpDominio_Eventos
	Local aNames      := oEntradas:GetNames()
	Local aDadosSet   := {}
	Local cChaveProd  := ""
	Local lError      := .F.
	Local nDocumentos := 0
	Local nIndDoc     := 0
	Local nIndProd    := 0
	Local nProdutos   := Len(aNames)

	Self:oDados:setFlag("carga_entradas_" + cAlias, .F.)

	For nIndProd := 1 to nProdutos
		lError      := .F.
		cChaveProd  := aNames[nIndProd]

		If oEntradas[cChaveProd] == Nil
			Loop
		EndIf

		nDocumentos := Len(oEntradas[cChaveProd])
		If Empty(nDocumentos)
			Loop
		EndIf

		Self:oDados:trava(cChaveProd)
		aDadosSet := Self:oDados:getItemAList("Entradas", cChaveProd, @lError, .T.)
		If lError
			//Atribui {{cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}, ...}
			aDadosSet := oEntradas[cChaveProd]
		Else
			For nIndDoc := 1 to nDocumentos
				//Adiciona {cDocumento, cItem, cAlias, nPeriodo, nQuantidade, nControle, lPossuiLog, nPriConsumo, nPrioridade, dData}
				aAdd(aDadosSet, oEntradas[cChaveProd][nIndDoc])
			Next
		Endif
		Self:oDados:setItemAList("Entradas", cChaveProd, aDadosSet)
		Self:oDados:destrava(cChaveProd)
	Next

	Self:oDados:setFlag("carga_entradas_eventos" + cAlias, .T.)
Return Nil

/*/{Protheus.doc} loga
Gera Log de Eventos do MRP em Tabela Global
@author    brunno.costa
@since     29/04/2020
@version   1
@param 01 - cEvento , caracter, Código do Evento que deve ser avaliado (Lista completa no detalhamento de aDados)
@param 02 - cProduto, caracter, Código do produto que deve ser avaliado
@param 03 - nPeriodo, numero  , indicador de período do log
@param 04 - aDados  , array   , array com os dados do evento para ser avaliado:
	Evento 001 - Saldo em estoque inicial menor que zero
		aDados[1] - Saldo inicial do Produto
	Evento 002 - Atrasar o evento
		aDados[1] - Data original
		aDados[2] - Numero do Documento
		aDados[3] - Item ou outro dado complementar do documento
		aDados[4] - Alias do documento
		aDados[5] - Data do documento
		aDados[6] - Data para atrasar
	Evento 003 - Adiantar o evento
		aDados[1] - Data original
		aDados[2] - Numero do Documento
		aDados[3] - Item ou outro dado complementar do documento
		aDados[4] - Alias do documento
		aDados[5] - Data do documento
		aDados[6] - Data para adiantar
	Evento 004 - Data de necessidade invalida - Data anterior a database
		aDados[1] - Codigo do produto que gerou a necessidade
		aDados[2] - Quantidade da necessidade
		aDados[3] - Data calculada
		aDados[4] - Documento originador
		aDados[5] - Item do documento
		aDados[6] - Alias do documento
		aDados[7] - Sequencia do componente
	Evento 005 - Data de necessidade invalida - Data posterior ao prazo maximo do MRP
		aDados[1] - Codigo do produto que gerou a necessidade
		aDados[2] - Quantidade da necessidade
		aDados[3] - Data calculada
		aDados[4] - Alias
		aDados[5] - Documento
	Evento 006 - Documento planejado em atraso
		aDados[1] - Data planejada do evento
		aDados[2] - Numero do Documento
		aDados[3] - Item ou outro dado complementar do documento
		aDados[4] - Alias do documento
	Evento 007 - Cancelar o documento
		aDados[1] - Data do documento (periodo)
		aDados[2] - Numero do Documento
		aDados[3] - Item ou outro dado complementar do documento
		aDados[4] - Alias do documento
		aDados[5] - Data do documento
	Evento 008 - Saldo em estoque maior ou igual ao estoque maximo (Desconsiderar - Por ENQUANTO, PCPA712 não utiliza estoque máximo)
		aDados[1] - Estoque maximo
		aDados[2] - Saldo em estoque
		aDados[3] - Data do periodo
		aDados[4] - Alias do documento
	Evento 009 - Saldo em estoque menor ou igual ao ponto de pedido
		aDados[1] - Ponto de pedido
		aDados[2] - Saldo em estoque
		aDados[3] - Data do periodo
		aDados[4] - Alias do documento
	Evento 010 - Limite excedido de quebra de ordem de produção
		aDados[1] - Data do periodo
		aDados[2] - Quantidade de quebras
	Evento 011 - Alteração no armazém da demanda
		aDados[1] - Código da demanda
		aDados[2] - Data da demanda
	Evento 012 - Produto ira gerar documentos com armazém que não controla MRP (evento gerado após a gravação da HWC).
	Evento 013 - Limite excedido de quebra de ordem de produção
		aDados[1] - Data do periodo
		aDados[2] - Quantidade de quebras
@param 05 - cFilEvent  , caracter  , filial na qual o evento ocorreu
@param 06 - lForce     , boolean   , força a inclusão de log

/*/
METHOD loga(cEvento, cProduto, dData, aDados, cFilEvent, lForce) CLASS MrpDominio_Eventos
	Local aDadosSet
	Local cChave
	Local lError    := .F.

	Default cFilEvent := " "
	Default lForce	  := .F.

	If Self:lHabilitado .Or. lForce
		cChave    := DtoS(dData) + cFilEvent + cProduto

		//Complementos da chave para cada evento
		Do Case
			Case cEvento == "002"
				cChave += aDados[EVENTO_002_POS_ALIAS    ]
				cChave += aDados[EVENTO_002_POS_DOCUMENTO]
				cChave += aDados[EVENTO_002_POS_ITEM     ]

			Case cEvento == "003"
				cChave += aDados[EVENTO_003_POS_ALIAS    ]
				cChave += aDados[EVENTO_003_POS_DOCUMENTO]
				cChave += aDados[EVENTO_003_POS_ITEM     ]

			Case cEvento == "004"
				cChave += aDados[EVENTO_004_POS_TRT               ]
				cChave += aDados[EVENTO_004_POS_DOCUMENTO         ]
				cChave += aDados[EVENTO_004_POS_PRODUTO_ORIGINADOR]

			Case cEvento == "005"
				cChave += aDados[EVENTO_005_POS_ALIAS    ]
				cChave += aDados[EVENTO_005_POS_DOCUMENTO]

			Case cEvento == "006"
				cChave += aDados[EVENTO_006_POS_ALIAS    ]
				cChave += aDados[EVENTO_006_POS_DOCUMENTO]
				cChave += aDados[EVENTO_006_POS_ITEM     ]

			Case cEvento == "007"
				cChave += aDados[EVENTO_007_POS_ALIAS    ]
				cChave += aDados[EVENTO_007_POS_DOCUMENTO]
				cChave += aDados[EVENTO_007_POS_ITEM     ]

		EndCase

		aDadosSet := Self:oDados:getItemAList(cEvento, cChave, @lError, .T.)
		If Empty(aDadosSet) .OR. lError
			aDadosSet := {cProduto, aDados, cFilEvent}
		Else
			If cEvento $ "|001|002|003|006|007|"
				aDadosSet := {cProduto, aDados, cFilEvent}

			ElseIf cEvento == "004"
				aDadosSet[2][EVENTO_004_POS_QUANTIDADE] += aDados[EVENTO_004_POS_QUANTIDADE]
				If !Empty(aDados[EVENTO_004_POS_PRODUTO_ORIGINADOR])
					aDadosSet[2][EVENTO_004_POS_PRODUTO_ORIGINADOR] := aDados[EVENTO_004_POS_PRODUTO_ORIGINADOR]
				EndIf

			ElseIf cEvento == "005"
				aDadosSet[2][EVENTO_005_POS_QUANTIDADE] += aDados[EVENTO_005_POS_QUANTIDADE]

			//ElseIf cEvento == "008"
			ElseIf cEvento == "009"
				aDadosSet[2][EVENTO_009_POS_SALDO_ESTOQUE] := aDados[EVENTO_009_POS_SALDO_ESTOQUE]

			EndIf
		Endif
		Self:oDados:setItemAList(cEvento, cChave, aDadosSet)

		If !Self:lHabilitado .And. lForce
			Self:oDados:setFlag("lPossuiEventoForcado", .T.)
		EndIf
	EndIf
Return

/*/{Protheus.doc} analisaDocumentos
Analisa Documentos para sugerir Replanemanentos - Thread Master

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - aPerProds, array, array com as chaves de produto que possuem movimentação no MRP
/*/
METHOD analisaDocumentos(aPerProds) CLASS MrpDominio_Eventos
	Local oStatus
	If Self:lHabilitado
		oStatus := MrpDados_Status():New(Self:oDominio:oParametros["ticket"])
		oStatus:setStatus("documentEventLogStatus" , "2") //Executando
		Self:oDominio:oEventos:oDados:setFlag("lProcessamentoConcluido", .F.)
		If Self:oDominio:oParametros["nThreads_EVT"] <= 1
			MrpEvtAnDc(aPerProds, Self:oDominio:oParametros["ticket"])
		Else
			PCPIPCGO(Self:oDominio:oParametros["cSemaforoThreads"] + "EVT", .F., "MrpEvtAnDc", aPerProds, Self:oDominio:oParametros["ticket"])
		EndIf

	EndIf
Return

/*/{Protheus.doc} aguardaInclusaoEntradas
Aguarda Inclusão dos Documentos de Entradas

@author    brunno.costa
@since     06/05/2020
@version   1
/*/
METHOD aguardaInclusaoEntradas() CLASS MrpDominio_Eventos
	Local aTabelas := {"T4T","T4Q", "T4U"}
	Local nInd     := 0
	Local nTotal   := Len(aTabelas)

	For nInd := 1 to nTotal
		oReturn := Self:oDados:getFlag("carga_entradas_eventos" + aTabelas[nInd])
		If oReturn == Nil .OR. !oReturn
			nInd := 0
			Sleep(200)
		Endif
	Next
Return

/*/{Protheus.doc} MrpEvtAnDc
Analisa Documentos para sugerir Replanemanentos - JOB

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - aPerProds, array   , array com as chaves de produto que possuem movimentação no MRP
@param 02 - cTicket  , caracter, Número do ticket de processamento do MRP
/*/
Function MrpEvtAnDc(aPerProds, cTicket)
	Local cChaveProd := ""
	Local nIndProd   := 0
	Local nProdutos  := Len(aPerProds)
	Local oDominio   := MRPPrepDom(cTicket)
	Local oStatus    := MrpDados_Status():New(oDominio:oParametros["ticket"])

	oDominio:oEventos:oDados:setFlag("nConcluidos", 0)

	oDominio:oEventos:aguardaInclusaoEntradas()

	For nIndProd := 1 to nProdutos
		cChaveProd := aPerProds[nIndProd]
		If oDominio:oParametros["nThreads_EVT"] <= 1
			MrpEvtAnPr(cChaveProd, oDominio:oParametros["ticket"])
		Else
			PCPIPCGO(oDominio:oParametros["cSemaforoThreads"] + "EVT", .F., "MrpEvtAnPr", cChaveProd, oDominio:oParametros["ticket"])
		EndIf
		nPercent := Round(((nIndProd - oDominio:oParametros["nThreads_EVT"]) / nProdutos), 2)
		If nPercent > 0
			oStatus:setStatus("documentEventLogPercentage" , nPercent)
		EndIf
	Next

	While oDominio:oEventos:oDados:getFlag("nConcluidos") != nProdutos
		Sleep(200)
	EndDo

	oDominio:oEventos:oDados:setFlag("lProcessamentoConcluido", .T.)
	oStatus:setStatus("documentEventLogStatus" , "3") //Concluído

Return

/*/{Protheus.doc} MrpEvtAnPr
Analisa Documentos para sugerir Replanemanentos - Slave Produto

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - cChaveProd, caracter, chave de código do produto no MRP
@param 02 - cTicket   , caracter, Número do ticket de processamento do MRP
/*/
Function MrpEvtAnPr(cChaveProd, cTicket)

	Local aConsumos   := {} //{nPeriodo, nConsumo   , nControleBaixa}
	Local aEntradas   := {} //{nPeriodo, nQuantidade, nControleBaixa}
	Local aPerProds   := {}
	Local lError      := .F.
	Local nSldInicial := 0
	Local oDominio    := MRPPrepDom(cTicket)
	Local oSelf       := oDominio:oEventos

	If snIntQtd == 0
		snIntQtd   := GetSx3Cache("HWC_QTNEOR","X3_TAMANHO")
		snDecQtd   := GetSx3Cache("HWC_QTNEOR","X3_DECIMAL")
		snStTamQTD := snIntQtd + snDecQtd
	EndIf

	oDominio:oDados:oMatriz:getAllList("Periodos_Produto_"+cChaveProd, @aPerProds, @lError)
	If !lError
		aPerProds := aSort(aPerProds,,, { |x, y| x[2] < y[2] } )
		oSelf:compoeConsumosDiarios(cChaveProd, aPerProds, @aConsumos, @nSldInicial)

		If !Empty(aConsumos) .AND. Len(aConsumos) > 0

			//Retorna Entradas do Produto
			aEntradas := oSelf:oDados:getItemAList("Entradas", cChaveProd, @lError, .T.)
			If Len(aEntradas) > 0
				aEntradas := aSort(aEntradas,,, { |x, y| StrZero(x[AENTRADAS_POS_PERIODO], 4) + StrZero(x[AENTRADAS_POS_PRIORIDADE], 2) + DtoS(x[AENTRADAS_POS_DATA]) + StrZero(x[AENTRADAS_POS_QUANTIDADE]*snDecQtd, snStTamQTD) + x[AENTRADAS_POS_ITEM] ;
														<;
														 StrZero(y[AENTRADAS_POS_PERIODO], 4) + StrZero(y[AENTRADAS_POS_PRIORIDADE], 2) + DtoS(y[AENTRADAS_POS_DATA]) + StrZero(y[AENTRADAS_POS_QUANTIDADE]*snDecQtd, snStTamQTD) + y[AENTRADAS_POS_ITEM] } )

				oSelf:processaBaixas(cChaveProd, nSldInicial, @aEntradas, @aConsumos)
			EndIf

		EndIf

	EndIf

	oDominio:oEventos:oDados:setFlag("nConcluidos", 1, .F., .T., .F., .T.)

Return

/*/{Protheus.doc} compoeConsumosDiarios
Compôe Consumos Diários

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - cChaveProd , caracter, chave de código do produto no MRP
@param 02 - aPerProds  , array   , array com os períodos onde há movimentação do produto no MRP
                                   aPerProds[x][1] -> Período caracter
								   aPerProds[x][2] -> Período numérico
@param 03 - aConsumos  , array   , retorna por referência array com os dados de consumo diários do produto: [x]{nPeriodo, nConsumo, nControleBaixa}
@param 04 - nSldInicial, caracter, retorna por referência o saldo inicial do produto no MRP
/*/
METHOD compoeConsumosDiarios(cChaveProd, aPerProds, aConsumos, nSldInicial) CLASS MrpDominio_Eventos

	Local aConsumo   := Array(ACONSUMOS_TAMANHO)
	Local aDados     := {}
	Local aRetAux    := {}
	Local cChave     := ""
	Local cChaveMAT  := ""
	Local cFilAux    := ""
	Local cList      := ""
	Local cProduto   := ""
	Local lConsPP    := .F.
	Local lErrorMAT  := .F.
	Local lErrorRast := .F.
	Local lEstSeg    := .F.
	Local lUsaMe     := .F.
	Local lUsouSldIn := .F.
	Local nConsumo   := 0
	Local nIndPer    := 0
	Local nPeriodo   := 0
	Local nPontoPed  := Nil
	Local nTotPeriod := 0
	Local oDadosRast := Self:oDominio:oDados:oRastreio
	Local oMultiEmp  := Nil
	Local oRastreio  := Self:oDominio:oRastreio

	oMultiEmp  := Self:oDominio:oMultiEmp
	lUsaME := oMultiEmp:utilizaMultiEmpresa()

	If lUsaMe
		cFilAux   := PadR(cChaveProd ,oMultiEmp:tamanhoFilial() )
		cProduto  := SubStr(cChaveProd, oMultiEmp:tamanhoFilial()+1 , Len(cChaveProd)   )
	Else
		cProduto := cChaveProd
	EndIf

	nTotPeriod := Len(aPerProds)
	For nIndPer := 1 to nTotPeriod
		lErrorMAT := .F.
		nPeriodo  := aPerProds[nIndPer][2]


		cChaveMAT := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo( , nPeriodo)) + cChaveProd
		aRetAux   := Self:oDominio:oDados:retornaCampo("MAT", 1, cChaveMAT,;
		                                              {"MAT_SAIPRE", "MAT_SAIEST"}, @lErrorMAT  ,;
		                                              .F. /*lAtual*/, , , , .F. /*lSort*/, .T. /*lVarios*/)
		If !lErrorMAT
			If !lUsouSldIn
				nSldInicial := Self:oDominio:oDados:retornaCampo("MAT", 1, cChaveMAT, "MAT_SLDINI", @lErrorMAT, .T. /*lAtual*/, , , , .F. /*lSort*/, .F. /*lVarios*/)
				lUsouSldIn  := .T.
			EndIf

			nConsumo := aRetAux[1] + aRetAux[2] //Saídas + Empenhos.

			If !lEstSeg
				lErrorRast := .F.
				cList := cChaveProd + chr(13) + cValToChar(nPeriodo)
				cChave := oRastreio:getChaveEstSeg(cProduto, nPeriodo, .T.)
				aDados := oDadosRast:oDados:getItemAList(cList, cChave, @lErrorRast)
				If !lErrorRast
					nConsumo    += aDados[oRastreio:getPosicao("NEC_ORIGINAL")]
					nSldInicial += aDados[oRastreio:getPosicao("NEC_ORIGINAL")]
					lEstSeg := .T.
					aSize(aDados, 0)
				EndIf
				If nSldInicial < 0
					nConsumo    += Abs(nSldInicial)
					nSldInicial := 0
				EndIf
			EndIf
            
			lConsPP := .F.
			IF Self:oDominio:oParametros["lPontoPedido"]
				If nPontoPed == Nil
					lErrorRast := .F.
					nPontoPed := Self:oDominio:oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_PPED", @lErrorRast, .F. /*lAtual*/, , , , , .F. /*lVarios*/)
					If lErrorRast 
						nPontoPed := 0
					End 
				EndIf  
				lConsPP := nPontoPed > 0 
			EndIf
            
			aConsumo[ACONSUMOS_POS_PERIODO]      := nPeriodo
			aConsumo[ACONSUMOS_POS_CONSUMO]      := nConsumo
			aConsumo[ACONSUMOS_POS_CONTROLE_QTD] := nConsumo
            aConsumo[ACONSUMOS_POS_PPEDIDO]      := 0
			
			If lConsPP
				aConsumo[ACONSUMOS_POS_PPEDIDO]      := nPontoPed
			EndIf
			
			aAdd(aConsumos, aClone(aConsumo)) 
		EndIf
	Next

Return

/*/{Protheus.doc} processaBaixas
Processa as Baixas dos Documentos de Entrada

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - cChaveProd , caracter, chave de código do produto no MRP
@param 02 - nSldInicial, caracter, retorna por referência o saldo inicial do produto no MRP
@param 03 - aEntradas  , array   , array com os dados das entradas do produto:
                                   [x]{Documento, Item, Alias, Periodo, nQuantidade, nControleBaixa, lPossuiLog, nPrimeiroConsumo, nPrioridade}
@param 04 - aConsumos  , array   , array com os dados de consumo diários do produto:
                                   [x]{nPeriodo, nConsumo, nControleBaixa}
/*/
METHOD processaBaixas(cChaveProd, nSldInicial, aEntradas, aConsumos) CLASS MrpDominio_Eventos

	Local cFilAux    := " "
	Local cProduto   := cChaveProd
	Local lUsaME     := .F.
	Local nConsumos  := Len(aConsumos)
	Local nEntradas  := Len(aEntradas)
	Local nIndCons   := 0
	Local nIndEntr   := 0
	Local nPosEntr   := 0
	Local nPosCons   := 0
	Local nPerAux    := 0
	Local nQtdPP     := 0
	Local nStatus    := 0
	Local oMultiEmp  := Nil

	oMultiEmp := Self:oDominio:oMultiEmp
	lUsaME    := oMultiEmp:utilizaMultiEmpresa()

	If lUsaMe
		cFilAux  := PadR(cChaveProd ,oMultiEmp:tamanhoFilial() )
		cProduto := SubStr( cChaveProd, oMultiEmp:tamanhoFilial()+1 , Len(cChaveProd)   )
	EndIf

	//Abate Saldo Inicial nos Documentos de Saída
	If nSldInicial > 0
		For nIndCons := 1 To nConsumos

			If nSldInicial > aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD]
				nSldInicial                                     -= aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD]
				aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] := 0
			Else
				aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] -= nSldInicial
				nSldInicial                                     := 0
				Exit
			EndIf

			If aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] > 0
				aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] := Max(0, aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] - nSldInicial)
			EndIf

		Next
	EndIf

	While nStatus <> 1

		If nPosEntr == 0
			nPosEntr := 1
		Else
			nPosEntr := aScan(aEntradas, {|x| x[AENTRADAS_POS_CONTROLE_QTD] > 0 })
		EndIf		

		//Abate Controles de Documentos Entradas x Saída
		For nIndEntr := nPosEntr To nEntradas
  
			If aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] == 0
				Loop
			EndIf

			nPosCons := aScan(aConsumos, {|x| x[ACONSUMOS_POS_CONTROLE_QTD] > 0 .Or. x[ACONSUMOS_POS_PPEDIDO] > 0})

			If nPosCons == 0
				Exit
			EndIf
  
			nPerAux := aConsumos[nPosCons][ACONSUMOS_POS_PERIODO]
  
			//Verifica se a data do primeiro consumo a abater é maior que a data da entrada.
			//Se for maior, irá verificar se existe uma entrada na mesma data do consumo para utilizar a entrada existente
			//no mesmo período do consumo.
			If nPerAux > aEntradas[nIndEntr][AENTRADAS_POS_PERIODO]  .And. ;//Data do consumo > que data da entrada
			   aScan(aEntradas, {|x| x[AENTRADAS_POS_CONTROLE_QTD] != 0 .And. ;
			                         x[AENTRADAS_POS_PERIODO] == nPerAux}, nPosCons+1) > 0 //Verifica se tem entrada no mesmo período
				Loop
			EndIf
  
			For nIndCons := nPosCons to nConsumos
				//Não possui consumo pendente válido
				If aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] <= 0 .And. aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] <= 0
					Loop
				EndIf
  
				//Atribui primeiro consumo da entrada
				If Empty(aEntradas[nIndEntr][AENTRADAS_POS_PRIMEIRO_CONSUMO])
					aEntradas[nIndEntr][AENTRADAS_POS_PRIMEIRO_CONSUMO] := aConsumos[nIndCons][ACONSUMOS_POS_PERIODO]
				EndIf

				//Baixa parcial da entrada
				If aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] > aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD]
					aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] -= aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD]
					aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] := 0

				//Baixa total da entrada
				Else
					aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] -= aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD]
					aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] := 0
				EndIf

				If aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] > 0 .And. aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] > 0
					aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] := Max(0, aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] - aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD])
				EndIf

				// Verifica adiantamento de entrada
				If !aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] .And. ;
				   aEntradas[nIndEntr][AENTRADAS_POS_PRIMEIRO_CONSUMO] < aEntradas[nIndEntr][AENTRADAS_POS_PERIODO]
					aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] := .T.
					Self:pegaDadosLoga("003", cProduto, aEntradas[nIndEntr], aConsumos[nPosCons], cFilAux)
				EndIf
  
				// Verifica atraso de entrada
				If !aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] .And. ;
				   aEntradas[nIndEntr][AENTRADAS_POS_PRIMEIRO_CONSUMO] > aEntradas[nIndEntr][AENTRADAS_POS_PERIODO]
					aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] := .T.
					Self:pegaDadosLoga("002", cProduto, aEntradas[nIndEntr], aConsumos[nPosCons], cFilAux)
				EndIf

				If aEntradas[nIndEntr][AENTRADAS_POS_CONTROLE_QTD] == 0
					//Baixou a qtd total da entrada.
					//Se o consumo não tiver sido atendido por completo, Verificar se existe uma entrada anterior que não foi processada
					//para analisar, e verificar a necessidade de atrasar para atender a necessidade.
					If aConsumos[nIndCons][ACONSUMOS_POS_CONTROLE_QTD] > 0
						nPerAux := aScan(aEntradas, {|x| x[AENTRADAS_POS_CONTROLE_QTD] > 0 .And. ;
						                                 x[AENTRADAS_POS_PERIODO] <= aConsumos[nIndCons][ACONSUMOS_POS_PERIODO] })
						If nPerAux > 0 .And. nPerAux < nIndEntr
							//Encontrou uma entrada com data anterior que pode ser avaliada.
							//Retorna o nIndEntr para processar esta entrada
							nIndEntr := nPerAux-1
						EndIf
					EndIf
					Exit
				EndIf
			Next
		Next
 
		If aScan(aEntradas, {|x| x[AENTRADAS_POS_CONTROLE_QTD] > 0}) > 0 .And. ;
		   aScan(aConsumos, {|x| x[ACONSUMOS_POS_CONTROLE_QTD] > 0}) > 0
			nStatus := 0
		Else 
			nStatus := 1
		EndIf
	EndDo 

	// Soma saldo de PP para verificar se deve impedir cancelamento das entradas
	nQtdPP := 0
	If Self:oDominio:oParametros["lPontoPedido"]
		For nIndCons := 1 To nConsumos
			If aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] > 0
				nQtdPP += aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO]	
				aConsumos[nIndCons][ACONSUMOS_POS_PPEDIDO] := 0
			EndIf
		Next
	EndIf

	// Verifica cancelamentos
	For nIndEntr := 1 To nEntradas
		If !aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] .And. aEntradas[nIndEntr][AENTRADAS_POS_PRIMEIRO_CONSUMO] == 0

			// verifica se tem saldo de ponto de pedido do item e se houver não cancelar a entrada
			If nQtdPP > 0
			   nQtdPP -= aEntradas[nIndEntr][AENTRADAS_POS_QUANTIDADE]
			   loop
			EndIf

			aEntradas[nIndEntr][AENTRADAS_POS_POSSUI_LOG] := .T.
			Self:pegaDadosLoga("007", cProduto, aEntradas[nIndEntr], Nil, cFilAux)
		EndIf
	Next

Return

/*/{Protheus.doc} pegaDadosLoga
Monta os dados a partir da entrada e do consumo recebido e faz o log de adiantamento, cancelamento ou atraso.
@author Lucas Fagundes
@since 06/04/2022
@version P12
@param 01 cEvento  , caracter, Código do evento que será logado.
@param 02 cProduto , caracter, Produto que será logado.
@param 03 aEntrada , array   , Entrada que será pegada os dados.
@param 04 aConsumo , array   , Consumo que será pegado os dados.
@param 05 cFilEvent, caracter, Filial que será logada.
@return Nil
/*/
Method pegaDadosLoga(cEvento, cProduto, aEntrada, aConsumo, cFilEvent) CLASS MrpDominio_Eventos
	Local aDados := {}
	Local dData

	dData := Self:oDominio:oPeriodos:retornaDataPeriodo( , aEntrada[AENTRADAS_POS_PERIODO])

	aSize(aDados, 0)
	aAdd(aDados, dData)
	aAdd(aDados, aEntrada[AENTRADAS_POS_DOCUMENTO])
	aAdd(aDados, aEntrada[AENTRADAS_POS_ITEM])
	aAdd(aDados, aEntrada[AENTRADAS_POS_ALIAS])
	aAdd(aDados, aEntrada[AENTRADAS_POS_DATA])

	If aConsumo != Nil
		aAdd(aDados, Self:oDominio:oPeriodos:retornaDataPeriodo( , aConsumo[ACONSUMOS_POS_PERIODO]))
	EndIf

	Self:loga(cEvento, cProduto, dData, aDados, cFilEvent)

	aSize(aDados, 0)
Return Nil

/*/{Protheus.doc} montaDadosImpressao
Monta String de Impressão do Log de Eventos

@author    brunno.costa
@since     06/05/2020
@version   1
@param 01 - cEvento    , caracter, código do evento
@param 02 - aEvento    , array   , array com os dados do evento, documentado na função loga()
@param 03 - aResultados, array   , retorna por referência os resultados para impressão:
                                   [x]{HWM_FILIAL,HWM_TICKET,HWM_PRODUT,HWM_EVENTO,HWM_LOGMRP,HWM_DOC,HWM_ITEM,HWM_ALIAS,HWM_PRDORI}
@param 04 - aLenFields , array   , tamanho dos campos de aResultados
/*/
METHOD montaDadosImpressao(cEvento, aEvento, aResultados, aLenFields) CLASS MrpDominio_Eventos
	Local aLinAux    := {}
	Local cAlias     := ""
	Local cDataDoc   := ""
	Local cDocumento := ""
	Local cItemDoc   := ""
	Local cLogMRP    := ""
	Local cProduto   := ""
	Local cProdOri   := ""
	Local cTicket    := Self:oDominio:oParametros["ticket"]
	Local cFilEvent  := aEvento[iDADOS][3]

	If snIntQtd == 0
		snIntQtd   := GetSx3Cache("HWC_QTNEOR","X3_TAMANHO")
		snDecQtd   := GetSx3Cache("HWC_QTNEOR","X3_DECIMAL")
		snStTamQTD := snIntQtd + snDecQtd
	EndIf

	If cEvento == "001" .and. aEvento[iDADOS][iDADOS_DADOS][EVENTO_001_POS_SALDO_INICIAL] < 0
		cProduto := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP  := STR0149 + cValToChar(Round(aEvento[iDADOS][iDADOS_DADOS][EVENTO_001_POS_SALDO_INICIAL], snDecQtd)) //"Saldo inicial menor do que zero: "

	ElseIf cEvento == "002" .AND. !Empty(aEvento[iDADOS]) .AND. !Empty(aEvento[iDADOS][iDADOS_DADOS])
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
		cDocumento := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_DOCUMENTO])
		cItemDoc   := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_ITEM])
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_ALIAS]
		cLogMRP    := STR0150 + cDocumento //"Atrasar o documento "
		cDataDoc   := DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_DATA_DOC])

		If !Empty(cItemDoc)
			cLogMRP += " / " + cItemDoc
		EndIf

		If !Empty(cDataDoc)
			cLogMRP += " / " + cDataDoc
		EndIf

		If cAlias == "T4T"
			cLogMRP += STR0151 //"(Solicitação de Compras)"

		ElseIf cAlias == "T4U"
			cLogMRP += STR0152 //"(Pedido de Compras)"

		ElseIf cAlias == "T4Q"
			cLogMRP += STR0153 //"(Ordem de Produção)"

		EndIf

		cLogMRP += STR0154 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_DATA_ORIGINAL]) + STR0155 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_002_POS_DATA_ATRASAR]) //" de " + " para "

	ElseIf cEvento == "003" .AND. !Empty(aEvento[iDADOS]) .AND. !Empty(aEvento[iDADOS][iDADOS_DADOS])
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
		cDocumento := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_DOCUMENTO])
		cItemDoc   := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_ITEM])
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_ALIAS]
		cLogMRP    := STR0156 + cDocumento //"Adiantar o documento "
		cDataDoc   := DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_DATA_DOC])

		If !Empty(cItemDoc)
			cLogMRP += " / " + cItemDoc
		EndIf

		If !Empty(cDataDoc)
			cLogMRP += " / " + cDataDoc
		EndIf

		If cAlias == "T4T"
			cLogMRP += STR0151 //"(Solicitação de Compras)"

		ElseIf cAlias == "T4U"
			cLogMRP += STR0152 //"(Pedido de Compras)"

		ElseIf cAlias == "T4Q"
			cLogMRP += STR0153 //"(Ordem de Produção)"

		EndIf

		cLogMRP += STR0154 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_DATA_ORIGINAL]) + STR0155 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_003_POS_DATA_ADIANTAR]) //" de " + " para "

	ElseIf cEvento == "004" .AND. aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_QUANTIDADE] != 0
		cProduto   :=aEvento[iDADOS][iDADOS_CHAVE]
		cDocumento := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_DOCUMENTO])
		cItemDoc   := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_ITEM])
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_ALIAS]

		cLogMRP  := STR0157 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_DATA_CALCULADA]) //"Necessidade inválida - Data anterior a data base do cálculo: "
		If      !Empty(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_PRODUTO_ORIGINADOR]);
		 .AND. AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_PRODUTO_ORIGINADOR]) <> AllTrim(cProduto)
			cProdOri := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_PRODUTO_ORIGINADOR])
			cLogMRP  += STR0158 + cProdOri //". Prod.Origem: "
		EndIf
		If !Empty(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_TRT])
			cLogMRP += ". " + STR0182 + RTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_TRT]) //"Seq. Comp.: "
		EndIf
		cLogMRP  += STR0159 + cValToChar(Round(aEvento[iDADOS][iDADOS_DADOS][EVENTO_004_POS_QUANTIDADE], snDecQtd)) //". Quantidade: "

	ElseIf cEvento == "005"
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP    := STR0160 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_005_POS_DATA_CALCULADA]) //"Necessidade inválida - Data posterior a data limite do cálculo: "
		cLogMRP    += STR0159 + cValToChar(Round(aEvento[iDADOS][iDADOS_DADOS][EVENTO_005_POS_QUANTIDADE], snDecQtd)) //". Quantidade: "
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_005_POS_ALIAS]
		cDocumento := aEvento[iDADOS][iDADOS_DADOS][EVENTO_005_POS_DOCUMENTO]

	ElseIf cEvento == "006"
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP    := STR0161 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_006_POS_DATA_ATRASO]) //"Documento pré-existente planejado em atraso: "
		cDocumento := aEvento[iDADOS][iDADOS_DADOS][EVENTO_006_POS_DOCUMENTO]
		cItemDoc   := aEvento[iDADOS][iDADOS_DADOS][EVENTO_006_POS_ITEM]
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_006_POS_ALIAS]

	ElseIf cEvento == "007" .AND. !Empty(aEvento[iDADOS]) .AND. !Empty(aEvento[iDADOS][iDADOS_DADOS])
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
 		cDocumento := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_007_POS_DOCUMENTO])
		cItemDoc   := AllTrim(aEvento[iDADOS][iDADOS_DADOS][EVENTO_007_POS_ITEM])
		cAlias     := aEvento[iDADOS][iDADOS_DADOS][EVENTO_007_POS_ALIAS]
		cLogMRP    := STR0162 + cDocumento //"Cancelar o documento "
		cDataDoc   := DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_007_POS_DATA_DOC])

		If !Empty(cItemDoc)
			cLogMRP += " / " + cItemDoc
		EndIf

		If !Empty(cDataDoc)
			cLogMRP += " / " + cDataDoc
		EndIf

		If cAlias == "T4T"
			cLogMRP += STR0151 //"(Solicitação de Compras)"

		ElseIf cAlias == "T4U"
			cLogMRP += STR0152 //"(Pedido de Compras)"

		ElseIf cAlias == "T4Q"
			cLogMRP += STR0153 //"(Ordem de Produção)"

		EndIf

		cLogMRP += STR0154 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_007_POS_DATA]) + STR0163 //" de " + " pois o seu saldo não será utilizado em nenhum período."

	//ElseIf cEvento == "008"
	ElseIf cEvento == "009"
		cProduto := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP  := STR0164 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_009_POS_DATA]) //"Saldo menor ou igual ao ponto de pedido em: "
		cLogMRP  += STR0165 + cValToChar(aEvento[iDADOS][iDADOS_DADOS][EVENTO_009_POS_SALDO_ESTOQUE]) //". Saldo: "
		cLogMRP  += STR0166 + cValToChar(aEvento[iDADOS][iDADOS_DADOS][EVENTO_009_POS_PONTO_PEDIDO])  //". Pont.Ped.: "
		cAlias   := aEvento[iDADOS][iDADOS_DADOS][EVENTO_009_POS_ALIAS]

	ElseIf cEvento == "010"
		cProduto := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP  := STR0193 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_010_POS_DATA])//Excedido a quantidade de quebra de ordens de produção em:
		cLogMRP  += STR0194 + cValToChar(aEvento[iDADOS][iDADOS_DADOS][EVENTO_010_POS_QUANT_QUEBRAS]) //, Total de quebras:
		cAlias   := 'T4Q'

	ElseIf cEvento == "011"
		cProduto   := aEvento[iDADOS][iDADOS_CHAVE]
		cDocumento := aEvento[iDADOS][iDADOS_DADOS][EVENTO_011_POS_CODIGO]
		cLogMRP    := I18n(STR0195, {DToC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_011_POS_DATA])}) // "Documento na data #1[data]# teve seu armazém alterado para o padrão, pois aglutina demandas com múltiplos armazéns."
		cAlias     := 'HWC'
	
	ElseIf cEvento == "013"
		cProduto := aEvento[iDADOS][iDADOS_CHAVE]
		cLogMRP  := STR0197 + DtoC(aEvento[iDADOS][iDADOS_DADOS][EVENTO_013_POS_DATA])//Excedido a quantidade de quebra de solicitações de compra em:
		cLogMRP  += STR0194 + cValToChar(aEvento[iDADOS][iDADOS_DADOS][EVENTO_013_POS_QUANT_QUEBRAS]) //, Total de quebras:
		cAlias   := 'T4T'

	EndIf

	cLogMRP  := StrTran(cLogMRP , "'", "''")
	cProduto := StrTran(cProduto, "'", "''")
	cProdOri := StrTran(cProdOri, "'", "''")


	//Adiciona campos na ordem de cCols
	aAdd(aLinAux, PadR(IIF( Empty(cFilEvent),Self:oDados:getflag("cFilial"), cFilEvent ) , aLenFields[1])) //HWM_FILIAL
	aAdd(aLinAux, PadR(cTicket                       , aLenFields[2])) //HWM_TICKET
	aAdd(aLinAux, PadR(cProduto                      , aLenFields[3])) //HWM_PRODUT
	aAdd(aLinAux, PadR(cEvento                       , aLenFields[4])) //HWM_EVENTO
	aAdd(aLinAux, PadR(cLogMRP                       , aLenFields[5])) //HWM_LOGMRP
	aAdd(aLinAux, PadR(cDocumento                    , aLenFields[6])) //HWM_DOC
	aAdd(aLinAux, PadR(cItemDoc                      , aLenFields[7])) //HWM_ITEM
	aAdd(aLinAux, PadR(cAlias                        , aLenFields[8])) //HWM_ALIAS
	aAdd(aLinAux, PadR(cProdOri                      , aLenFields[9])) //HWM_PRDORI

	If !Empty(cLogMRP)
		aAdd(aResultados, aLinAux)
	EndIf
Return

/*/{Protheus.doc} possuiEventosForcados
Verifica se tem eventos forçados para realizar a exportação.
Eventos forçados: 010, 011 e 013

@author Lucas Fagundes
@since 06/07/2023
@version P12
@return lPossui, Logico, Indica se possui eventos forçados.
/*/
METHOD possuiEventosForcados() CLASS MrpDominio_Eventos
	Local lPossui := .F.
	Local lError  := .F.

	lPossui := Self:oDados:getFlag("lPossuiEventoForcado", @lError)

	lPossui := lPossui .And. !lError

Return lPossui
