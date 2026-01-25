#INCLUDE 'protheus.ch'
#INCLUDE 'MRPDominio.ch'

#DEFINE IND_NOME_LISTA_ENTRADAS    "RASTRO_ENTRADA"
#DEFINE IND_CHAVE_GRAVAR_SME       "Registro_SME"
#DEFINE IND_CHAVE_REG_AGLUTINADO   "Aglutinado_"
#DEFINE IND_CHAVE_AGLUT_DOC_FILHO  "Relaciona_Agl_Filho_"
#DEFINE IND_CHAVE_DE_PARA_EMPENHO  "De_Para_Empenho_"
#DEFINE IND_CHAVE_DADOS_HWC        "DADOS_HWC_RAST"
#DEFINE IND_CHAVE_DOCUMENTOS_SAIDA "RAST_DEM_DOCUMENTOS_SAIDA"
#DEFINE IND_CHAVE_DOCUMENTOS_USO   "RAST_DEM_DOCUMENTOS_USO"
#DEFINE IND_CHAVE_USO_TRANF_ES     "RAST_DEM_USO_TRANF_ES"

#DEFINE AENTRADAS_POS_FILIAL            1
#DEFINE AENTRADAS_POS_TIPO_DOC_ENTRADA  2
#DEFINE AENTRADAS_POS_NUM_DOC_ENTRADA   3
#DEFINE AENTRADAS_POS_DATA              4
#DEFINE AENTRADAS_POS_PRODUTO           5
#DEFINE AENTRADAS_POS_TRT               6
#DEFINE AENTRADAS_POS_QUANTIDADE        7
#DEFINE AENTRADAS_POS_TIPO_REGISTRO     8
#DEFINE AENTRADAS_POS_TIPO_DOC_SAIDA    9
#DEFINE AENTRADAS_POS_NUM_DOC_SAIDA    10
#DEFINE AENTRADAS_POS_NIVEL            11
#DEFINE AENTRADAS_POS_DOCPAI           12
#DEFINE AENTRADAS_POS_SEQUEN           13
#DEFINE AENTRADAS_POS_OPCIONAL         14
#DEFINE AENTRADAS_POS_LOTE             15
#DEFINE AENTRADAS_POS_SUBLOTE          16
#DEFINE AENTRADAS_POS_FILIAL_DESTINO   17
#DEFINE AENTRADAS_SIZE                 17

#DEFINE ASALDOS_POS_TIPO                1
#DEFINE ASALDOS_POS_NUM_DOC_ENTRADA     2
#DEFINE ASALDOS_POS_DATA                3
#DEFINE ASALDOS_POS_QUANTIDADE          4
#DEFINE ASALDOS_POS_VENCIMENTO          5
#DEFINE ASALDOS_POS_LOTE                6
#DEFINE ASALDOS_POS_SUBLOTE             7
#DEFINE ASALDOS_SIZE                    7

#DEFINE AAGLUTINA_POS_FILIAL            1
#DEFINE AAGLUTINA_POS_TIPO_DOC_ORIGEM   2
#DEFINE AAGLUTINA_POS_NUM_DOC_ORIGEM    3
#DEFINE AAGLUTINA_POS_SEQ_ORIGEM        4
#DEFINE AAGLUTINA_POS_NECESSIDADE       5
#DEFINE AAGLUTINA_POS_SUBTITUICAO       6
#DEFINE AAGLUTINA_POS_TRT               7
#DEFINE AAGLUTINA_POS_DOC_FILHO         8
#DEFINE AAGLUTINA_POS_USA_FIL_DESTINO   9
#DEFINE AAGLUTINA_SIZE                  9

#DEFINE ADOCHWC_FILIAL                  1
#DEFINE ADOCHWC_TIPO_DOC_ENT            2
#DEFINE ADOCHWC_NUM_DOC_ENT             3
#DEFINE ADOCHWC_SEQ_QUEBRA              4
#DEFINE ADOCHWC_DATA                    5
#DEFINE ADOCHWC_PRODUTO                 6
#DEFINE ADOCHWC_TRT                     7
#DEFINE ADOCHWC_QTD_BAIXA               8
#DEFINE ADOCHWC_QTD_SUBS                9
#DEFINE ADOCHWC_QTD_EMPENHO             10
#DEFINE ADOCHWC_QTD_NECESS              11
#DEFINE ADOCHWC_TIPO_DOC_SAI            12
#DEFINE ADOCHWC_NUM_DOC_SAI             13
#DEFINE ADOCHWC_IDOPC                   14
#DEFINE ADOCHWC_LIST_HWC                15
#DEFINE ADOCHWC_POS_HWC                 16
#DEFINE ADOCHWC_SIZE                    16

Static _nSizeDEnt := Nil
Static _oDominio  := Nil
Static scTextESeg := STR0143
Static scTextPPed := STR0144
Static snTamCod   := 90


/*/{Protheus.doc} MrpDominio_RastreioEntradas
Classe de controle do rastreio das entradas do MRP
@author marcelo.neumann
@since 07/10/2020
@version 1
/*/
CLASS MrpDominio_RastreioEntradas FROM LongNameClass

	DATA aEntInclui   AS Array
	DATA lAglutinado  AS Logical //Indica se está rodando com aglutinação
	DATA lHabilitado  AS Logical //Indica se está usando o rastreio das demandas
	DATA nPosDocFilho AS Numeric
	DATA nPosFilial   AS Numeric
	DATA nPosNecOri   AS Numeric
	DATA nPosNecess   AS Numeric
	DATA nPosEst      AS Numeric
	DATA nPosCodPai   AS Numeric
	DATA nPosConEst   AS Numeric
	DATA nPosDocPai   AS Numeric
	DATA nPosIdOpc    AS Numeric
	DATA nPosPeriodo  AS Numeric
	DATA nPosProduto  AS Numeric
	DATA nPosQuebras  AS Numeric
	DATA nPosTipoPai  AS Numeric
	DATA nPosRastreio AS Numeric
	DATA nPosTrfEnt   AS Numeric
	DATA nPosTrfSai   AS Numeric
	DATA nPosComp     AS Numeric
	DATA nPosDatIni   AS Numeric
	DATA nPosDatFim   AS Numeric
	DATA nPosTRT      AS Numeric
	DATA nPosRevIni   AS Numeric
	DATA nPosRevFim   AS Numeric
	DATA nPosQtdEst   AS Numeric
	DATA nPosQtdFix   AS Numeric
	DATA nPosPotenc   AS Numeric
	DATA nPosPerda    AS Numeric
	DATA nPosQtdBas   AS Numeric
	DATA nPosFant     AS Numeric
	DATA nPosAGLDoc   AS Numeric
	DATA nPosTRTHWC   AS Numeric
	DATA oDados       AS Object
	DATA oDominio     AS Object
	DATA oNivelProd   AS Object
	DATA oDocsSaida   AS Object
	DATA oUsoDoc      AS Object
	DATA oRegSMEPos   AS Object
	DATA oDocHWC      AS Object
	DATA oEntInclui   AS Object

	METHOD new() CONSTRUCTOR

	METHOD addAglutinado(cFilAux, cDocAgl, cTipoOri, cDocOri, nSeqOri, cTRT, nNecess, nSubsti, cDocFil)
	METHOD addDocEmpenho(cIdReg, cDocumento, cDocOrigem, lAddPre)
	METHOD addDocumento(cFilAux, cTipDocEnt, cNumDocEnt, nSequen, dData, cProduto, cTRT, nBaixaEst, nSubsti, nEmpenho, nNecess, cTipDocSai, cNumDocSai, aLinha)
	METHOD addDocsSaida(cNumDocEnt, aRetorno)
	METHOD addDocHWC(cFilAux, cTipDocEnt, cNumDocEnt, nSequen, dData, cProduto, cTRT, nBaixaEst, nSubsti, nEmpenho, nNecess, cTipDocSai, cNumDocSai, cIdOpc, cList, nPosDoc)
	METHOD addEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc)
	METHOD addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc)
	METHOD addRelacionamentoDocFilho(cDocAgl, nSequen, cDocFilho)
	METHOD addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nQuant, cTipoReg, cTipDocSai, cNumDocSai, cDocPai, nSequen, lSomaQtd, cIdOpc, cLote, cSubLote, cFilDest)
	METHOD addSaldoInicial(cFilAux, dData, cProduto, nQuant, aLotVenc, cIdOpc)
	METHOD addAGLTransferencia(cNumDocEnt, cNumDocSai, cProduto, cIdOpc, aLinha)
	METHOD atualizaPercentual(oDominio, nTotProc, nTotGrav, nIndGrav)
	METHOD buscaDocsAglutinados(aLinha, nSequen)
	METHOD buscaQtdComp(cNumDocSai, nIndQuebra, cCompon, cTRT, cFilAux)
	METHOD calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, aDocSaida, nNecPai, cFilAux, nPeriodo, cIDOpc)
	METHOD carregaDocsSaida(cNumDoc)
	METHOD criaIdReg(cDocEnt, lConcatPai)
	METHOD efetivaInclusao()
	METHOD getDocEmpenho(cDocum)
	METHOD getEntradas(cChave)
	METHOD getQtdEntrada(cFilAux, cProduto, dData, cIdOpc)
	METHOD getNivel(cChave)
	METHOD montaRetorno(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nBaixaEst, cTipo, cTipDocSai, cNumDocSai, cTRT, cIdPai, cIdReg, cDocPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess, nSequenc, cFilDest)
	METHOD nivelProduto(cFilAux, cProduto)
	METHOD ordena(aEntradas)
	METHOD procDocHWC()
	METHOD quebraAglutinacaoPai(aRetorno, cFilAux, cProduto, cTRT, nBaixaEst, nDistrib, cTipDocEnt, cNumDocEnt, cTipDocSai, cNumDocSai, dData, cTipo, cDocPai, cTRTAgl, oDocsProc, cSeq, cIdPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess)
	METHOD reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nQtdNecess)
	METHOD relacionaDocTransferenciaEstoque(aLinhaHWC)
	METHOD substituiAglutinados(cOrigem, aAglutinad, lRetOPEmp)
	METHOD trataAglutinado(aRegistro)
	METHOD trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc, cFilDest)
	METHOD trataAglutTransf(aAglut)
	METHOD trataDocSaidaTransf(cNumDoc)
	METHOD trataEstoque(aRetorno, cTipo, cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
	METHOD trataRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipo, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc, cLote, cSubLote)
	METHOD trataNecessidadeTransferencia(nNecess, cTipDocSai, cNumDocEnt, aLinha)
	METHOD efetivaDocHWC()
	METHOD converteFilialMultiEmpresa(cFilAux)

ENDCLASS

/*/{Protheus.doc} MrpDominio_RastreioEntradas
Método construtor da classe MrpDominio_RastreioEntradas
@author marcelo.neumann
@since 07/10/2020
@version 1
@param oDominio, objeto, instância do objeto de domínio
@return Self, objeto, instancia desta classe
/*/
METHOD new(oDominio) CLASS MrpDominio_RastreioEntradas

	Self:aEntInclui   := {}
	Self:oDados       := oDominio:oDados:oRastreioEntradas
	Self:oDominio     := oDominio
	Self:oNivelProd   := JsonObject():New()
	Self:oDocsSaida   := JsonObject():New()
	Self:oUsoDoc      := JsonObject():New()
	Self:oRegSMEPos   := JsonObject():New()
	Self:lAglutinado  := oDominio:oAglutina:processamentoAglutinado()
	Self:lHabilitado  := oDominio:oParametros["lRastreiaEntradas"]
	Self:nPosDocFilho := oDominio:oRastreio:getPosicao("DOCFILHO")
	Self:nPosFilial   := oDominio:oRastreio:getPosicao("FILIAL")
	Self:nPosNecOri   := oDominio:oRastreio:getPosicao("NEC_ORIGINAL")
	Self:nPosNecess   := oDominio:oRastreio:getPosicao("NECESSIDADE")
	Self:nPosEst      := oDominio:oRastreio:getPosicao("QTD_ESTOQUE")
	Self:nPosConEst   := oDominio:oRastreio:getPosicao("CONSUMO_ESTOQUE")
	Self:nPosTipoPai  := oDominio:oRastreio:getPosicao("TIPOPAI")
	Self:nPosDocPai   := oDominio:oRastreio:getPosicao("DOCPAI")
	Self:nPosIdOpc    := oDominio:oRastreio:getPosicao("ID_OPCIONAL")
	Self:nPosPeriodo  := oDominio:oRastreio:getPosicao("PERIODO")
	Self:nPosProduto  := oDominio:oRastreio:getPosicao("COMPONENTE")
	Self:nPosQuebras  := oDominio:oRastreio:getPosicao("QUEBRAS_QUANTIDADE")
	Self:nPosRastreio := oDominio:oRastreio:getPosicao("RASTRO_AGLUTINACAO")
	Self:nPosTrfEnt   := oDominio:oRastreio:getPosicao("TRANSFERENCIA_ENTRADA")
	Self:nPosTrfSai   := oDominio:oRastreio:getPosicao("TRANSFERENCIA_SAIDA")
	Self:nPosAGLDoc   := oDominio:oRastreio:getPosicao("DOCUMENTO_AGLUTINADOR")
	Self:nPosTRTHWC   := oDominio:oRastreio:getPosicao("TRT")
	Self:nPosComp     := oDominio:oDados:posicaoCampo("EST_CODFIL")
	Self:nPosDatIni   := oDominio:oDados:posicaoCampo("EST_VLDINI")
	Self:nPosDatFim   := oDominio:oDados:posicaoCampo("EST_VLDFIM")
	Self:nPosTRT      := oDominio:oDados:posicaoCampo("EST_TRT")
	Self:nPosRevIni   := oDominio:oDados:posicaoCampo("EST_REVINI")
	Self:nPosRevFim   := oDominio:oDados:posicaoCampo("EST_REVFIM")
	Self:nPosQtdEst   := oDominio:oDados:posicaoCampo("EST_QTD")
	Self:nPosQtdFix   := oDominio:oDados:posicaoCampo("EST_FIXA")
	Self:nPosPotenc   := oDominio:oDados:posicaoCampo("EST_POTEN")
	Self:nPosPerda    := oDominio:oDados:posicaoCampo("EST_PERDA")
	Self:nPosQtdBas   := oDominio:oDados:posicaoCampo("EST_QTDB")
	Self:nPosFant     := oDominio:oDados:posicaoCampo("EST_FANT")
	Self:nPosCodPai   := oDominio:oDados:posicaoCampo("EST_CODPAI")
	Self:oDocHWC      := JsonObject():New()
	Self:oEntInclui   := JsonObject():New()

	If Self:lHabilitado
		If !Self:oDados:existAList(IND_NOME_LISTA_ENTRADAS)
			Self:oDados:createAList(IND_NOME_LISTA_ENTRADAS)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DADOS_HWC)
			Self:oDados:createAList(IND_CHAVE_DADOS_HWC)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DOCUMENTOS_SAIDA)
			Self:oDados:createAList(IND_CHAVE_DOCUMENTOS_SAIDA)
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_DOCUMENTOS_USO)
			Self:oDados:createAList(IND_CHAVE_DOCUMENTOS_USO)
		EndIf

		If !Self:oDados:existAList("PRODUTOS_SME")
			Self:oDados:createAList("PRODUTOS_SME")
		EndIf

		If !Self:oDados:existAList(IND_CHAVE_USO_TRANF_ES)
			Self:oDados:createAList(IND_CHAVE_USO_TRANF_ES)
		EndIf

	EndIf

Return Self

/*/{Protheus.doc} addSaldoInicial
Adiciona um registro referente a um saldo inicial de um produto
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux  , caracter, código da filial
@param 02 dData    , data    , data do registro
@param 03 cProduto , numérico, código do produto
@param 04 aInfoLote, array   , Array com informações do lote: [1][1] Quantidade
                                                              [1][2] Data de Validade
                                                              [1][3] Local
                                                              [1][4] Lote
                                                              [1][5] Sub-lote
@param 05 cIdOpc   , caracter, id do opcional
@return Nil
/*/
METHOD addSaldoInicial(cFilAux, dData, cProduto, aInfoLote, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux       := {}
	Local aSaldos    := {}
	Local cLote      := ""
	Local cSubLote   := ""
	Local cIdReg     := ""
	Local cNumDocEnt := "SaldoInicial"
	Local cTipDocEnt := "SI"
	Local lErro      := .F.
	Local lOk        := .T.
	Local nQuant     := 0

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		cFilAux := xFilial("SME")
	EndIf

	cIdOpc   := AllTrim(cIdOpc)
	aAux     := Array(ASALDOS_SIZE)
	cIdReg   := "0_" + cFilAux + cProduto + cIdOpc
	nQuant   := aInfoLote[1]
	cLote    := aInfoLote[4]
	cSubLote := aInfoLote[5]

	aSaldos := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)
	If aSaldos == Nil
		aSaldos := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := aInfoLote[2]
	aAux[ASALDOS_POS_LOTE           ] := cLote
	aAux[ASALDOS_POS_SUBLOTE        ] := cSubLote

	aAdd(aSaldos, aClone(aAux))

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldos, @lErro)

	If lErro
		lOk := .F.
	Else
		Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, , nQuant, "0", "", "", "", 1, .F., cIdOpc, cLote, cSubLote)
	EndIf

	aSize(aAux   , 0)
	aSize(aSaldos, 0)

Return lOk

/*/{Protheus.doc} addEntradaPrevista
Adiciona um registro referente a uma entrada prevista de um produto
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, código da filial
@param 02 cTipDocEnt, caracter, tipo da entrada (OP, PC, SC)
@param 03 cNumDocEnt, caracter, número do documento de entrada
@param 04 dData     , data    , data do registro
@param 05 cProduto  , caracter, código do produto
@param 06 nQuant    , numérico, quantidade do produto
@param 07 cIdOpc    , caracter, id do Opcional
@return   lOk       , lógico  , indica se foi gravado com sucesso
/*/
METHOD addEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux   := {}
	Local aSaldo := {}
	Local cIdReg := ""
	Local lErro  := .F.
	Local lOk    := .T.

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		cFilAux := xFilial("SME")
	EndIf

	cIdOpc     := AllTrim(cIdOpc)
	cNumDocEnt := "Pre_" + cNumDocEnt
	aAux       := Array(ASALDOS_SIZE)
	cIdReg     := "1_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(cIdReg)
	aSaldo := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If Empty(aSaldo) .Or. lErro
		aSaldo := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := Nil
	aAdd(aSaldo, aAux)

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldo, @lErro)
	Self:oDados:destrava(cIdReg)

	If lErro
		lOk := .F.
	Else
		Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, , nQuant, "1", "", "", "", 1, .F., cIdOpc)
	EndIf

	aSize(aAux  , 0)
	aSize(aSaldo, 0)

Return lOk

/*/{Protheus.doc} addNovoSaldo
Adiciona um registro referente a um novo saldo gerado para um produto durante o processamento (Lote Econômico, Ponto de Pedido)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, código da filial
@param 02 cTipDocEnt , caracter, tipo do documento de entrada (OP, PC, SC)
@param 03 cNumDocEnt, caracter, número do documento de entrada
@param 04 dData     , data    , data do registro
@param 05 cProduto  , caracter, código do produto
@param 06 nQuant    , numérico, quantidade do produto
@param 07 cIdOpc    , caracter, id do opcional
@return   lOk       , lógico  , indica se foi gravado com sucesso
/*/
METHOD addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nQuant, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aAux   := {}
	Local aSaldo := {}
	Local cIdReg := ""
	Local lErro  := .F.
	Local lOk    := .T.
	Default cIdOpc := ""

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		cFilAux := xFilial("SME")
	EndIf

	cIdOpc  := AllTrim(cIdOpc)
	aAux    := Array(ASALDOS_SIZE)
	cIdReg  := "3_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(cIdReg)
	aSaldo := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If Empty(aSaldo) .Or. lErro
		aSaldo := {}
	EndIf

	aAux[ASALDOS_POS_TIPO           ] := cTipDocEnt
	aAux[ASALDOS_POS_NUM_DOC_ENTRADA] := cNumDocEnt
	aAux[ASALDOS_POS_DATA           ] := dData
	aAux[ASALDOS_POS_QUANTIDADE     ] := nQuant
	aAux[ASALDOS_POS_VENCIMENTO     ] := Nil
	aAdd(aSaldo, aAux)

	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aSaldo, @lErro)
	Self:oDados:destrava(cIdReg)

	If lErro
		lOk := .F.
	EndIf

	aSize(aAux  , 0)
	aSize(aSaldo, 0)

Return lOk

/*/{Protheus.doc} addRegistroSME
Adiciona um registro para ser gravado na tabela SME
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, número do documento referente à entrada
@param 04 dData     , date    , data da entrada
@param 05 cProduto  , caracter, produto da entrada
@param 06 cTRT      , caracter, sequencial do produto
@param 07 nQuant    , numérico, quantidade da entrada
@param 08 cTipoReg  , caracter, tipo de registro
                                0 = Saldo Inicial
                                1 = Entrada Prevista
                                2 = Composição da Rastreabilidade
                                3 = Saldo gerado pela Entrada Prevista (quando por exemplo uma OP produz 10 e o empenho é de 8)
@param 09 cTipDocSai, caracter, tipo do documento de saída gerado para essa entrada
@param 10 cNumDocSai, caracter, número do documento de saída gerado para essa entrada
@param 11 cDocPai   , caracter, documento pai do registro da HWC
@param 12 nSequen   , numerico, sequência do registro da HWC
@param 13 lSomaQtd  , lógico  , indica se deve somar a quantidade caso já exista registro igual
@param 14 cIdOpc    , caracter, id do opcional
@param 15 cLote     , caracter, código do lote
@param 16 cSubLote  , caracter, código do sub-lote
@param 17 cFilDest  , caracter, código da filial de destino (transferências)
@return Nil
/*/
METHOD addRegistroSME(cFilAux   , cTipDocEnt, cNumDocEnt, dData  , cProduto, cTRT  , nQuant, cTipoReg,;
                      cTipDocSai, cNumDocSai, cDocPai   , nSequen, lSomaQtd, cIdOpc, cLote , cSubLote, cFilDest) CLASS MrpDominio_RastreioEntradas
	Local cChave     := ""
	Local cChvProd   := ""
	Local lUsaMe     := Self:oDominio:oMultiEmp:utilizaMultiEmpresa()

	Default cDocPai  := ""
	Default nSequen  := 1
	Default lSomaQtd := .F.
	Default cIdOpc   := ""
	Default cLote    := ""
	Default cSubLote := ""
	Default cFilDest := ""

	aEntrada := Array(AENTRADAS_SIZE)
	aEntrada[AENTRADAS_POS_FILIAL          ] := cFilAux
	aEntrada[AENTRADAS_POS_TIPO_DOC_ENTRADA] := GetTipoEnt(cTipDocEnt)
	aEntrada[AENTRADAS_POS_NUM_DOC_ENTRADA ] := cNumDocEnt
	aEntrada[AENTRADAS_POS_DATA            ] := dData
	aEntrada[AENTRADAS_POS_PRODUTO         ] := cProduto
	aEntrada[AENTRADAS_POS_TRT             ] := cTRT
	aEntrada[AENTRADAS_POS_QUANTIDADE      ] := nQuant
	aEntrada[AENTRADAS_POS_TIPO_REGISTRO   ] := cTipoReg
	aEntrada[AENTRADAS_POS_TIPO_DOC_SAIDA  ] := cTipDocSai
	aEntrada[AENTRADAS_POS_NUM_DOC_SAIDA   ] := cNumDocSai
	aEntrada[AENTRADAS_POS_NIVEL           ] := Self:nivelProduto(cFilAux, cProduto)
	aEntrada[AENTRADAS_POS_DOCPAI          ] := cDocPai
	aEntrada[AENTRADAS_POS_SEQUEN          ] := nSequen
	aEntrada[AENTRADAS_POS_OPCIONAL        ] := AllTrim(cIdOpc)
	aEntrada[AENTRADAS_POS_LOTE            ] := cLote
	aEntrada[AENTRADAS_POS_SUBLOTE         ] := cSubLote
	aEntrada[AENTRADAS_POS_FILIAL_DESTINO  ] := cFilDest

	cChave := RTrim(aEntrada[AENTRADAS_POS_FILIAL          ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_DOC_ENTRADA]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_NUM_DOC_ENTRADA ]) + "|"
	cChave += DtoS( aEntrada[AENTRADAS_POS_DATA            ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_PRODUTO         ]) + "|"
	cChave += Iif(aEntrada[AENTRADAS_POS_TRT]==Nil,"",RTrim(aEntrada[AENTRADAS_POS_TRT])) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_REGISTRO   ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_TIPO_DOC_SAIDA  ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_NUM_DOC_SAIDA   ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_DOCPAI          ]) + "|"
	cChave += Str(  aEntrada[AENTRADAS_POS_SEQUEN          ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_OPCIONAL        ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_LOTE            ]) + "|"
	cChave += RTrim(aEntrada[AENTRADAS_POS_SUBLOTE         ])

	cChvProd := IIf(lUsaMe, aEntrada[AENTRADAS_POS_FILIAL], "")
	cChvProd += RTrim(aEntrada[AENTRADAS_POS_PRODUTO]) + CHR(13)
	cChvProd += AllTrim(aEntrada[AENTRADAS_POS_OPCIONAL])

	If !Self:oEntInclui:HasProperty(cChvProd)
		Self:oEntInclui[cChvProd] := {}
	EndIf

	If lSomaQtd .And. Self:oRegSMEPos:HasProperty(cChave)
		Self:oEntInclui[cChvProd][Self:oRegSMEPos[cChave]][AENTRADAS_POS_QUANTIDADE] += aEntrada[AENTRADAS_POS_QUANTIDADE]
	Else
		aAdd(Self:oEntInclui[cChvProd], aEntrada)
	EndIf

	Self:oRegSMEPos[cChave] := Len(Self:oEntInclui[cChvProd])
Return

/*/{Protheus.doc} efetivaInclusao
Grava em variável global os registros de entradas contidos no array Self:aEntInclui
@author marcelo.neumann
@since 30/11/2020
@version 1
@return lOk, lógico, indica se gravou a informação em memória
/*/
METHOD efetivaInclusao() CLASS MrpDominio_RastreioEntradas
	Local aChaves := {}
	Local aNames  := Self:oEntInclui:GetNames()
	Local cChave  := ""
	Local cNivel  := ""
	Local lErro   := .F.
	Local lOk     := .T.
	Local nIndex  := 0
	Local nTotal  := 0
	Local oProds  := Nil

	nTotal := Len(aNames)

	If nTotal > 0
		oProds := JsonObject():New()
		For nIndex := 1 To nTotal
			cChave := aNames[nIndex]

			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, IND_CHAVE_GRAVAR_SME + cChave, Self:oEntInclui[cChave], @lErro,,.T., 2)
			lOk := Iif(lErro, .F., lOk)
			oProds[cChave] := Self:oEntInclui[cChave][1][AENTRADAS_POS_NIVEL]

			aSize(Self:oEntInclui[cChave], 0)
			Self:oEntInclui:delName(cChave)
		Next nIndex
		aSize(Self:aEntInclui, 0)

		aChaves := oProds:GetNames()
		nTotal  := Len(aChaves)
		For nIndex := 1 To nTotal
			cNivel := oProds[aChaves[nIndex]]
			If cNivel == Nil
				cNivel := "--"
			EndIf
			Self:oDados:setItemList("PRODUTOS_SME", aChaves[nIndex], cNivel)
		Next nIndex
		aSize(aChaves, 0)
		FreeObj(oProds)

	EndIf

Return lOk

/*/{Protheus.doc} getEntradas
Retorna o array com a rastreabilidade das entradas

@author marcelo.neumann
@since 30/11/2020
@version 1
@param cChave, Caracter, Chave do produto para buscar as entradas.
@return aEntrada, array, array com a rastreabilidade das entradas
/*/
METHOD getEntradas(cChave) CLASS MrpDominio_RastreioEntradas
	Local aEntradas := {}
	Local lErro     := .F.

	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, IND_CHAVE_GRAVAR_SME + cChave, @lErro)
	If lErro .Or. aEntradas == Nil .Or. ValType(aEntradas) <> "A"
		aEntradas := {}
	EndIf

Return aEntradas

/*/{Protheus.doc} getNivel
Busca o nível do produto a partir da chave utilizada na lista global PRODUTOS_SME.

@author lucas.franca
@since 02/12/2022
@version P12
@param cChave, Caracter, Chave do produto para buscar o nível.
@return cNivel, Caracter, Nível do produto.
/*/
METHOD getNivel(cChave) CLASS MrpDominio_RastreioEntradas
	Local aDados    := STRTOKARR( cChave, CHR(13) )
	Local cFilAux   := ""
	Local cNivel    := "99"
	Local cChavePrd := ""
	Local oMultiEmp := Self:oDominio:oMultiEmp

	If oMultiEmp:utilizaMultiEmpresa()
		cFilAux   := PadR(aDados[1], oMultiEmp:tamanhoFilial() )
		cChavePrd := SubStr(aDados[1], oMultiEmp:tamanhoFilial()+1)
	EndIf
	cChavePrd := PadR(cChavePrd, snTamCod) + Iif(Len(aDados)>1, "|"+aDados[2],"")

	cNivel := Self:nivelProduto(cFilAux, cChavePrd)
	aSize(aDados, 0)
	oMultiEmp := Nil

Return cNivel

/*/{Protheus.doc} nivelProduto
Retorna o nível do produto
@author lucas.franca
@since 17/03/2021
@version P12
@param cFilAux , Character, Código da filial
@param cProduto, Character, Código do produto
@return cNivel , Character, Nível do produto
/*/
METHOD nivelProduto(cFilAux, cProduto) CLASS MrpDominio_RastreioEntradas
	Local aAreaPRD   := {}
	Local cChaveProd := cProduto
	Local cNivel     := Nil
	Local lErrorPrd  := .F.
	Local lAtual     := .F.

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		cChaveProd := cFilAux + cProduto
	EndIf

	cNivel := Self:oNivelProd[cChaveProd]

	If cNivel == Nil
		lAtual := cChaveProd == Self:oDominio:oDados:oProdutos:cCurrentKey
		If !lAtual
			aAreaPRD := Self:oDominio:oDados:retornaArea("PRD")
		EndIf

		cNivel := Self:oDominio:oDados:retornaCampo("PRD", 1, cChaveProd, "PRD_NIVEST", @lErrorPrd, lAtual)

		If lErrorPrd .Or. Empty(cNivel)
			cNivel := "99"
		EndIf

		Self:oNivelProd[cChaveProd] := cNivel

		If !lAtual
			Self:oDominio:oDados:setaArea(aAreaPRD)
			aSize(aAreaPRD, 0)
		EndIf
	EndIf

Return cNivel

/*/{Protheus.doc} ordena
Ordena o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param aEntradas, array, array com as entradas a serem ordenadas
@return Nil
/*/
METHOD ordena(aEntradas) CLASS MrpDominio_RastreioEntradas

	If !Empty(aEntradas)
		/*
			Ordena o array aEntradas para:
			x[AENTRADAS_POS_NIVEL]                                   -> Nível do produto
			DtoS(x[AENTRADAS_POS_DATA])                              -> Data da entrada
			x[AENTRADAS_POS_PRODUTO]                                 -> Produto
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") -> Registros de estoque negativo primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "0", "1")  -> Registros de estoque de segurança primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pré-OP", "0", "1") -> Registros de empenhos primeiro.
			Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "1", "0")  -> Registros de ponto de pedido por último
			x[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      -> Documento de saída
			x[AENTRADAS_POS_TIPO_DOC_ENTRADA]                        -> Tipo do documento
			x[AENTRADAS_POS_NUM_DOC_ENTRADA]                         -> Número do documento
		*/
		aSort(aEntradas, , , {|x,y| Iif(x[AENTRADAS_POS_NIVEL]==Nil,;
		                                x[AENTRADAS_POS_NIVEL] := Self:nivelProduto(x[AENTRADAS_POS_FILIAL], x[AENTRADAS_POS_PRODUTO]),;
		                                x[AENTRADAS_POS_NIVEL])+ ;
		                            DtoS(x[AENTRADAS_POS_DATA])                              + ;
		                            x[AENTRADAS_POS_PRODUTO]                                 + ;
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") + ; //Estoque negativo
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "0", "1")  + ; //"Est.Seg."
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pré-OP", "0", "1") + ; //Empenho
		                            Iif(x[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "1", "0")  + ; //"Ponto Ped."
		                            x[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      + ;
		                            x[AENTRADAS_POS_TIPO_DOC_ENTRADA  ]                      + ;
		                            x[AENTRADAS_POS_NUM_DOC_ENTRADA   ]                        ;
		                          < ;
		                            Iif(y[AENTRADAS_POS_NIVEL]==Nil,;
		                                y[AENTRADAS_POS_NIVEL] := Self:nivelProduto(x[AENTRADAS_POS_FILIAL], y[AENTRADAS_POS_PRODUTO]),;
		                                y[AENTRADAS_POS_NIVEL])+ ;
		                            DtoS(y[AENTRADAS_POS_DATA])                              + ;
		                            y[AENTRADAS_POS_PRODUTO]                                 + ;
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]=="ESTNEG", "0", "1") + ; //Estoque negativo
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0143, "0", "1")  + ; //"Est.Seg."
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]=="Pré-OP", "0", "1") + ; //Empenho
		                            Iif(y[AENTRADAS_POS_TIPO_DOC_SAIDA]==STR0144, "1", "0")  + ; //"Ponto Ped."
		                            y[AENTRADAS_POS_NUM_DOC_SAIDA     ]                      + ;
		                            y[AENTRADAS_POS_TIPO_DOC_ENTRADA  ]                      + ;
		                            y[AENTRADAS_POS_NUM_DOC_ENTRADA   ]                       })
	EndIf

Return

/*/{Protheus.doc} addDocumento
Adiciona um documento (registro da tabela HWC)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, número do documento referente à entrada
@param 04 nSequen   , numérico, sequência do documento
@param 05 dData     , data    , data do documento
@param 06 cProduto  , caracter, código do produto
@param 07 cTRT      , caracter, TRT do produto da sequência
@param 08 nBaixaEst , numérico, quantidade baixada do estoque
@param 09 nSubsti   , numérico, quantidade substituída por um alternativo
@param 10 nEmpenho  , numérico, quantidade empenhada
@param 11 nNecess   , numérico, necessidade gerada
@param 12 cTipDocSai, caracter, tipo do documento de saída
@param 13 cNumDocSai, caracter, número do documento de saída
@param 14 aLinha    , array   , array com os dados de memória da rastreabilidade
@param 15 cIdOpc    , caracter, id do opcional
@return Nil
/*/
METHOD addDocumento(cFilAux   , cTipDocEnt, cNumDocEnt, nSequen , dData  , cProduto  , ;
                    cTRT      , nBaixaEst , nSubsti   , nEmpenho, nNecess, cTipDocSai, ;
                    cNumDocSai, aLinha    , cIdOpc) CLASS MrpDominio_RastreioEntradas

	Local aDocsEntr  := {}
	Local aAglut     := {}
	Local cDocSaiPar := cNumDocSai
	Local cDocPai    := aLinha[Self:nPosDocPai]
	Local cFilDest   := ""
	Local cIdRegAg   := ""
	Local cChaveMat  := ""
	Local lAddRel    := .F.
	Local lPossuiAgl := .F.
	Local lUsaQtdQbr := !Empty(nSequen) .And. nSequen <= Len(aLinha[Self:nPosQuebras]) .And. !Empty(aLinha[Self:nPosQuebras][nSequen][1])
	Local nBaixaOrig := nBaixaEst
	Local nIndDocEnt := 0
	Local nSobraSld  := 0
	Local nTotDocEnt := 0
	Local nTranfEnt  := 0
	Local nQtd       := 0

	cIdOpc     := AllTrim(cIdOpc)
	cTipDocSai := AllTrim(cTipDocSai)

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
		//Busca quantidade de transferência de estoque para gerar corretamente os dados de quantidade.
		If cTipDocSai == "OP"
			cChaveMat := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(aLinha[Self:nPosFilial], aLinha[Self:nPosPeriodo]))
			cChaveMat += aLinha[Self:nPosFilial] + aLinha[Self:nPosProduto] + Iif(!Empty(aLinha[Self:nPosIdOpc]),"|"+aLinha[Self:nPosIdOpc],"")
			Self:oDominio:oMultiEmp:retornaTransferenciaEstoque(cChaveMat, @nTranfEnt)
		EndIf
	Else
		cFilAux := xFilial("SME")
	EndIf

	//Verifica se este registro teve a sua necessidade aglutinada em um registro do TIPO_PAI=AGL.
	//Se sim, utiliza como DOC DE ENTRADA o documento gerado pelo registro aglutinador, e utiliza a
	//quantidade real de necessidade deste registro para os cálculos da geração do rastreio.
	If aLinha[Self:nPosRastreio][1] <> 0 .And. !Empty(aLinha[Self:nPosRastreio][2]) .And. Empty(cNumDocEnt)
		nBaixaEst  -= aLinha[Self:nPosRastreio][1]
		nNecess    += aLinha[Self:nPosRastreio][1]
		aDocsEntr  := Self:buscaDocsAglutinados(aLinha, nSequen)
		nTotDocEnt := Len(aDocsEntr)
	EndIf

	If nTotDocEnt > 0
		lPossuiAgl := .T.
	EndIf

	If cTipDocSai == "1" // PMP
		nSobraSld := nNecess
	Else
		nSobraSld := aLinha[Self:nPosNecess] - (aLinha[Self:nPosNecOri] - nBaixaEst)
	EndIf

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() .And. cTipDocSai $ STR0143 + "|" + STR0144 + "|ESTNEG" //Est.Seg|Ponto Ped.|ESTNEG
		cNumDocSai := Stuff(cNumDocSai, 1, Len(cTipDocSai), cTipDocSai + "_" + cFilAux)
	EndIf

	nNecess := Self:trataNecessidadeTransferencia(nNecess, cTipDocSai, cNumDocEnt, aLinha)

	If cTipDocSai == STR0143 .Or. cTipDocSai == "ESTNEG" //"Est.Seg."
		If Empty(cNumDocEnt)
			cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
		EndIf
		If nTotDocEnt == 0
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecess]
			EndIf
			nNecess := Self:trataNecessidadeTransferencia(nNecess, cTipDocSai, cNumDocEnt, aLinha)
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, aDocsEntr[1][1], dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			cNumDocEnt := aDocsEntr[nIndDocEnt][1]

			If Self:lAglutinado
				Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
			EndIf
		Next nIndDocEnt

		If nSobraSld > 0
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
		EndIf

	ElseIf cTipDocSai $ STR0144 //"Ponto Ped."
		If Empty(cNumDocEnt)
			cNumDocEnt := STR0144 + DToS(dData) + "_" + cValToChar(nSequen) + "_Filha"
		EndIf

		If nTotDocEnt == 0
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecOri]
			EndIf
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			Self:addNovoSaldo(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, aDocsEntr[nIndDocEnt][2], cIdOpc)

			If Self:lAglutinado
				Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
			EndIf
		Next nIndDocEnt

	ElseIf cTipDocSai == "Pré-OP"
		If !Self:lAglutinado
			cNumDocSai := Self:getDocEmpenho(cNumDocSai)[1]
		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, "OP", cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf

		If nNecess > 0
			If Empty(cNumDocEnt)
				If Self:lAglutinado
					cNumDocEnt := Trim(cDocSaiPar) + "_" + cValToChar(nSequen) + "_Filha"
				Else
					cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
				EndIf
			EndIf

			If nTotDocEnt == 0
				If lUsaQtdQbr
					nNecess := aLinha[Self:nPosQuebras][nSequen][1]
				Else
					nNecess := aLinha[Self:nPosNecOri] - nBaixaOrig
				EndIf
				aAdd(aDocsEntr, {cNumDocEnt, nNecess})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
				cNumDocEnt := aDocsEntr[nIndDocEnt][1]

				If Self:lAglutinado
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
				EndIf
			Next nIndDocEnt

			If nSobraSld > 0
				Self:addNovoSaldo(cFilAux, "OP", cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
			EndIf

		EndIf

	ElseIf cTipDocSai $ "0123459"
		If nNecess > 0

			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf

			If nTotDocEnt == 0
				If lUsaQtdQbr
					nNecess := aLinha[Self:nPosQuebras][nSequen][1]
				Else
					nNecess := aLinha[Self:nPosNecOri] - nBaixaEst
				EndIf
				aAdd(aDocsEntr, {cNumDocEnt, nNecess})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)

				If Self:lAglutinado .And. !lPossuiAgl
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
				EndIf
			Next nIndDocEnt

			If nSobraSld > 0
				Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
			EndIf

		EndIf

		If nBaixaEst > 0
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf

	ElseIf cTipDocSai == "OP"
		If nSubsti < 0
			nBaixaEst := -nSubsti

			If nNecess > 0
				If Empty(cNumDocEnt)
					cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
				Else
					If nBaixaEst > 0
						Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, cNumDocEnt)
					EndIf
				EndIf

				Self:addRegistroSME(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nNecess, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
			EndIf
		EndIf
		nQtd := nEmpenho - nBaixaEst - nTranfEnt
		If nQtd > 0
			If nTotDocEnt > 0 .Or. !Empty(cNumDocEnt)
				lAddRel := .T.
			EndIf
			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf

			If nTotDocEnt == 0
				aAdd(aDocsEntr, {cNumDocEnt, nQtd})
				nTotDocEnt := 1
			EndIf

			For nIndDocEnt := 1 To nTotDocEnt
				Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)

				If lAddRel .And. Self:lAglutinado
					Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
				EndIf
			Next nIndDocEnt
		EndIf

		If nBaixaEst > 0
			Self:addRegistroSME(cFilAux, "", "", dData, cProduto, cTRT, nBaixaEst, "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc)
		EndIf

		If nNecess > 0 .And. nEmpenho > 0 .And. nNecess > nQtd
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, (nNecess - nQtd), cIdOpc)
		ElseIf nEmpenho < 0
			//Empenho negativo adiciona como entrada de saldo
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocSai, dData, cProduto, Abs(nEmpenho), cIdOpc)
		EndIf
	ElseIf cTipDocSai == "AGL" .And. nNecess > 0
		If nTotDocEnt == 0
			If Empty(cNumDocEnt)
				cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			EndIf
			If lUsaQtdQbr
				nNecess := aLinha[Self:nPosQuebras][nSequen][1]
			Else
				nNecess := aLinha[Self:nPosNecOri]
			EndIf
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
			Self:addAGLTransferencia(aDocsEntr[nIndDocEnt][1], cNumDocSai, cProduto, cIdOpc, aLinha)
		Next nIndDocEnt

		If nSobraSld > 0
			Self:addNovoSaldo(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nSobraSld, cIdOpc)
		EndIf

	ElseIf cTipDocSai == "TRANF_PR"
		If nTotDocEnt > 0 .Or. !Empty(cNumDocEnt)
			lAddRel := .T.
		EndIf

		If nTotDocEnt == 0 .And. Empty(cNumDocEnt)
			cNumDocEnt := Trim(cNumDocSai) + "_" + cValToChar(nSequen) + "_Filha"
			lAddRel    := .T.
		EndIf

		If nTotDocEnt == 0
			aAdd(aDocsEntr, {cNumDocEnt, nNecess})
			nTotDocEnt := 1
			Self:oDominio:oMultiEmp:retornaDadosTransferenciaDocumento(Trim(cNumDocSai), @cFilDest)
		EndIf

		If Empty(cFilDest)
			cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cNumDocSai)
			aAglut   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)
			If !Empty(aAglut)
				Self:oDominio:oMultiEmp:retornaDadosTransferenciaDocumento(aAglut[1][AAGLUTINA_POS_DOC_FILHO], @cFilDest)
				aSize(aAglut, 0)
			EndIf
		EndIf

		For nIndDocEnt := 1 To nTotDocEnt
			Self:addRegistroSME(cFilAux, cTipDocEnt, aDocsEntr[nIndDocEnt][1], dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][2], "2", cTipDocSai, cNumDocSai, cDocPai, nSequen, , cIdOpc, , , cFilDest)

			If lAddRel .And. Self:lAglutinado
				Self:addRelacionamentoDocFilho(cNumDocSai, nSequen, aDocsEntr[nIndDocEnt][1])
			EndIf
		Next nIndDocEnt

	ElseIf cTipDocSai == "TRANF_ES"
		aDocsEntr  := Self:oDados:getItemAList(IND_CHAVE_USO_TRANF_ES, cDocPai)
		nTotDocEnt := Len(aDocsEntr)
		For nIndDocEnt := 1 To nTotDocEnt
			If aDocsEntr[nIndDocEnt][4] == "OP"
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(aDocsEntr[nIndDocEnt][2])
				aAglut   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)
				If !Empty(aAglut)
					aDocsEntr[nIndDocEnt][2] := aAglut[1][AAGLUTINA_POS_DOC_FILHO]
					aSize(aAglut, 0)
				EndIf
			EndIf
			Self:trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, aDocsEntr[nIndDocEnt][1], cTipDocSai, aDocsEntr[nIndDocEnt][2], aDocsEntr[nIndDocEnt][2], nSequen, cIdOpc, aDocsEntr[nIndDocEnt][3], .T.)
		Next nIndDocEnt
	EndIf

	aSize(aDocsEntr, 0)
Return

/*/{Protheus.doc} addAGLTransferencia
Verifica se um registro do tipo "AGL" foi atendido por uma
transferência de produção. Se sim, irá gerar os dados de vínculo
de aglutinação do registro "AGL" com a transferência.

@author lucas.franca
@since 27/10/2023
@version P12
@param 01 cNumDocEnt, caracter, número do documento de entrada
@param 02 cNumDocSai, caracter, número do documento de saída
@param 03 cProduto  , caracter, produto da entrada
@param 04 cIdOpc    , caracter, id do opcional
@param 05 aLinha    , array   , array com os dados de memória da rastreabilidade
@return Nil
/*/
METHOD addAGLTransferencia(cNumDocEnt, cNumDocSai, cProduto, cIdOpc, aLinha) CLASS MrpDominio_RastreioEntradas
	Local aDocsHWC := {}
	Local aRegHWC  := {}
	Local aAglut   := {}
	Local cFilDest := ""
	Local cList    := ""
	Local cIdRegAg := ""
	Local nIndHWC  := 0
	Local nIndHWG  := 0
	Local nTotHWG  := 0
	Local nTotal   := 0

	cNumDocEnt := Trim(cNumDocEnt)
	cNumDocSai := Trim(cNumDocSai)

	If Left(cNumDocEnt, 5) == "TRANF"
		Self:oDominio:oMultiEmp:retornaDadosTransferenciaDocumento(cNumDocEnt, @cFilDest)

		If !Empty(cFilDest)
			cList := cFilDest + cProduto + Iif(!Empty(cIdOpc) , "|" + cIdOpc, "") + chr(13) + cValToChar(aLinha[Self:nPosPeriodo])
			Self:oDominio:oRastreio:oDados_Rastreio:oDados:getAllAList(cList, @aDocsHWC)

			If !Empty(aDocsHWC)
				nTotal := Len(aDocsHWC)

				For nIndHWC := 1 To nTotal
					aRegHWC := aDocsHWC[nIndHWC][2]

					If aRegHWC[Self:nPosAGLDoc][1] .And. Trim(aRegHWC[Self:nPosAGLDoc][2]) == cNumDocSai
						cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(aRegHWC[Self:nPosDocPai])
						aAglut   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)
						If Empty(aAglut)
							Self:addAglutinado(cFilDest, cNumDocSai, aRegHWC[Self:nPosTipoPai], aRegHWC[Self:nPosDocPai], 1, aRegHWC[Self:nPosTRTHWC], aRegHWC[Self:nPosRastreio][1], 0, "")
						Else
							nTotHWG := Len(aAglut)
							For nIndHWG := 1 To nTotHWG
								Self:addAglutinado(aAglut[nIndHWG][AAGLUTINA_POS_FILIAL]         ,;
								                   cNumDocSai                                    ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM],;
								                   aAglut[nIndHWG][AAGLUTINA_POS_NUM_DOC_ORIGEM] ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM]     ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_TRT]            ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE]    ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_SUBTITUICAO]    ,;
								                   aAglut[nIndHWG][AAGLUTINA_POS_DOC_FILHO]       )
								aSize(aAglut[nIndHWG], 0)
							Next

							aSize(aAglut, 0)

						EndIf
					EndIf

					aSize(aRegHWC, 0)
					aSize(aDocsHWC[nIndHWC], 0)
				Next nIndHWC
				aSize(aDocsHWC, 0)

			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} trataBaixaEntradaPrevista
Busca as entradas previstas que foram utilizadas pelo documento de saída
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo do documento de entrada
@param 03 cNumDocEnt, caracter, número do documento de entrada
@param 04 dData     , date    , data da entrada
@param 05 cProduto  , caracter, produto da entrada
@param 06 cTRT      , caracter, TRT do produto na estrutura
@param 07 nBaixaEst , numérico, quantidade da entrada
@param 08 cTipDocSai, caracter, tipo do documento de saída
@param 09 cNumDocSai, caracter, número do documento de saída
@param 10 cDocPai   , caracter, documento pai do registro da HWC
@param 11 nSequen   , numérico, sequência do registro da HWC
@param 12 cIdOpc    , caracter, id do opcional
@param 13 cFilDest  , caracter, código da filial de destino (transferência)
@param 14 lBaixaEst , Lógico  , identifica se força a baixa por estoque.
@return Nil
/*/
METHOD trataBaixaEntradaPrevista(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc, cFilDest, lBaixaEst) CLASS MrpDominio_RastreioEntradas
	Local aEntAdd   := {}
	Local aEntradas := {}
	Local nIndex    := 0
	Local nLenEntr  := 0
	Local nNecec    := 0
	Local nQtdDoc   := 0

	Default cFilDest  := ""
	Default lBaixaEst := .F.

	cIdOpc  := AllTrim(cIdOpc)
	nQtdDoc := Self:getQtdEntrada(cFilAux, cProduto, dData, cIdOpc)

	If cTipDocSai == STR0143 .Or. lBaixaEst //Est.Seg
		//Quando é estoque de segurança ou quando força a baixa de estoque (transferência de estoque por exemplo), registra as baixas de estoque antes de verificar as baixas por documentos de entrada
		Self:trataEstoque(@aEntAdd  , ;
		                  "0"       , ;
		                  cFilAux   , ;
		                  "SI"      , ;
		                  ""        , ;
		                  dData     , ;
		                  cProduto  , ;
		                  cTRT      , ;
		                  nBaixaEst , ;
		                  cTipDocSai, ;
		                  cNumDocSai, ;
		                  cDocPai   , ;
		                  nSequen   , ;
		                  cIdOpc    )

		nLenEntr   := Len(aEntAdd)
		For nIndex := 1 To nLenEntr
			cNumDocSai := Self:getDocEmpenho(aEntAdd[nIndex][9])[1]

			Self:addRegistroSME(cFilAux            , ;
			                    aEntAdd[nIndex][2] , ;
			                    aEntAdd[nIndex][3] , ;
			                    dData              , ;
			                    cProduto           , ;
			                    aEntAdd[nIndex][10], ;
			                    aEntAdd[nIndex][6] , ;
			                    "2"                , ;
			                    aEntAdd[nIndex][8] , ;
			                    cNumDocSai         , ;
			                    cDocPai            , ;
			                    nSequen            , ;
			                    .T.                , ;
			                    cIdOpc             , ;
			                    /*cLote*/          , ;
			                    /*cSubLote*/       , ;
			                    cFilDest             )
			nBaixaEst -= aEntAdd[nIndex][6]
		Next nIndex
		aSize(aEntAdd, 0)
	EndIf

	//Verifica se já foi realizada a baixa completa por consumo de estoque para o estoque de segurança.
	If nBaixaEst > 0
		nNecec := nBaixaEst

		If nNecec > nQtdDoc
			nNecec := nQtdDoc
		EndIf

		//Se estiver aglutinando, deve explodir os documentos para buscar a OP correta do Empenho (usando o TRT)
		aEntradas := Self:substituiAglutinados("S", ;
		                                       {Self:montaRetorno(cFilAux     ,;
		                                                           cTipDocEnt ,;
		                                                           cNumDocEnt ,;
		                                                           dData      ,;
		                                                           cProduto   ,;
		                                                           nNecec     ,;
		                                                           "3"        ,;
		                                                           cTipDocSai ,;
		                                                           cNumDocSai ,;
		                                                           cTRT       ,;
		                                                           ""         ,;
		                                                           ""         ,;
		                                                           cDocPai    ,;
		                                                           cIdOpc     ,;
		                                                           ""         ,;
		                                                           "");
		                                       }, ;
		                                       .F.)

		//Percorre os documentos após a explosão buscando a OP que fez a baixa
		nLenEntr  := Len(aEntradas)
		For nIndex := 1 To nLenEntr
			Self:trataEstoque(@aEntAdd             , ;
			                  "1"                  , ;
			                  aEntradas[nIndex][1] , ;
			                  aEntradas[nIndex][2] , ;
			                  aEntradas[nIndex][3] , ;
			                  aEntradas[nIndex][4] , ;
			                  aEntradas[nIndex][5] , ;
			                  aEntradas[nIndex][10], ;
			                  aEntradas[nIndex][6] , ;
			                  aEntradas[nIndex][8] , ;
			                  aEntradas[nIndex][9] , ;
			                  cDocPai              , ;
			                  nSequen              , ;
			                  cIdOpc               )
		Next nIndex

		nLenEntr  := Len(aEntAdd)
		For nIndex := 1 To nLenEntr
			cNumDocSai := Self:getDocEmpenho(aEntAdd[nIndex][9])[1]

			Self:addRegistroSME(cFilAux            , ;
			                    aEntAdd[nIndex][2] , ;
			                    aEntAdd[nIndex][3] , ;
			                    dData              , ;
			                    cProduto           , ;
			                    aEntAdd[nIndex][10], ;
			                    aEntAdd[nIndex][6] , ;
			                    "3"                , ;
			                    aEntAdd[nIndex][8] , ;
			                    cNumDocSai         , ;
			                    cDocPai            , ;
			                    nSequen            , ;
			                    .T.                , ;
			                    cIdOpc             , ;
			                    /*cLote*/          , ;
			                    /*cSubLote*/       , ;
			                    cFilDest             )
			nBaixaEst -= aEntAdd[nIndex][6]
		Next nIndex
	EndIf
Return

/*/{Protheus.doc} trataRegistroSME
Faz o tratamento do registro para gravar na tabela SME. Explode a aglutinação se necessário.
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo do documento de entrada
@param 03 cNumDocEnt, caracter, número do documento de entrada
@param 04 dData     , date    , data do documento
@param 05 cProduto  , caracter, código do produto
@param 06 cTRT      , caracter, TRT do produto
@param 07 nBaixaEst , numérico, quantidade da baixa
@param 08 cTipo     , caracter, tipo do registro
@param 09 cTipDocSai, caracter, tipo do documento de saída
@param 10 cNumDocSai, caracter, número do documento de saída
@param 11 cDocPai   , caracter, número do documento pai da HWC
@param 12 nSequen   , numérico, sequência do registro da HWC
@param 13 cIdOpc    , caracter, id do opcional
@param 14 cLote     , caracter, código do lote
@param 15 cSubLote  , caracter, código do sub-lote
@param 16 cFilDest  , caracter, código da filial de destino (transferências)
@return aRetorno, array, array com o(s) registro(s) a ser(em) gravado(s) na SME
/*/
METHOD trataRegistroSME(cFilAux   , cTipDocEnt, cNumDocEnt, dData  , cProduto, cTRT , nBaixaEst, cTipo,;
                        cTipDocSai, cNumDocSai, cDocPai   , nSequen, cIdOpc  , cLote, cSubLote , cFilDest) CLASS MrpDominio_RastreioEntradas
	Local aRetorno   := {}
	Local lDemanda   := .F.
	Local nCntNewDoc := 0
	Local nIndex     := 0
	Local nQtdTotal  := 0
	Local nTotal     := 0
	Default cIdOpc   := ""
	Default cFilDest := ""

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		cFilAux := xFilial("SME")
	EndIf

	cIdOpc  := AllTrim(cIdOpc)

	//Verifica se o registro é dependente de alguma baixa de estoque
	If Empty(cTipDocEnt) .And. Empty(cNumDocEnt)
		//Trata saldo inicial
		Self:trataEstoque(@aRetorno, "0", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

		//Trata novos saldos
		If nBaixaEst > 0
			Self:trataEstoque(@aRetorno, "1", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)

			If nBaixaEst > 0
				Self:trataEstoque(@aRetorno, "3", cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, @nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc)
			EndIf
		EndIf

		Self:trataAglutinado(@aRetorno)
	Else
		aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
		                                 cTipDocEnt, ;
		                                 cNumDocEnt, ;
		                                 dData     , ;
		                                 cProduto  , ;
		                                 nBaixaEst , ;
		                                 cTipo     , ;
		                                 cTipDocSai, ;
		                                 cNumDocSai, ;
		                                 cTRT      , ;
		                                 ""        , ;
		                                 ""        , ;
		                                 cDocPai   , ;
		                                 cIdOpc    , ;
		                                 cLote     , ;
		                                 cSubLote  , ;
		                                 .F.       , ;
		                                 nBaixaEst , ;
										 nSequen) )

		Self:trataAglutinado(@aRetorno)
	EndIf

	nTotal := Len(aRetorno)
	For nIndex := 1 To nTotal

		//Grava a filial de destino caso seja necessário
		If !Empty(cFilDest) .And. aRetorno[nIndex][20] == ""
			aRetorno[nIndex][20] := cFilDest
		EndIf
		aRetorno[nIndex][12] := Self:criaIdReg(aRetorno[nIndex][3], aRetorno[nIndex][17])
		nQtdTotal            += aRetorno[nIndex][6]

		If !lDemanda
			lDemanda := "|"+aRetorno[nIndex][8]+"|" $ "|0|1|2|3|4|5|9|Pré-OP|"
		EndIf
		If Left(aRetorno[nIndex][3], 4) != "Pre_"
			nCntNewDoc++
		EndIf
	Next nIndex

	If !Empty(cNumDocEnt)
		If nCntNewDoc > 1 .And. nQtdTotal > 0 .And. Self:oDominio:oAglutina:avaliaAglutinacao("", cProduto, lDemanda)
			Self:addRelacionamentoDocFilho(cDocPai, 1, cNumDocEnt)

			If cTipDocSai == "Pré-OP"
				Self:addDocEmpenho(cDocPai, cNumDocEnt, RTrim(cNumDocSai), .F.)
			EndIf
		EndIf

		If ! cTipo $ "|0|1|"
			Self:addDocsSaida(cNumDocEnt, aRetorno)
		EndIf
	EndIf
Return aRetorno

/*/{Protheus.doc} trataEstoque
Retorna o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 aRetorno  , array   , array a ser atualizado com os registros de baixa de estoque
@param 02 cTipo     , caracter, tipo de baixa a ser tratada (0 = Saldo Inicial, 1 = Entrada Prevista, 3 = Novo Saldo)
@param 03 cFilAux   , caracter, filial do registro
@param 04 cTipDocEnt, caracter, tipo do documento de entrada
@param 05 cNumDocEnt, caracter, número do documento de entrada
@param 06 dData     , date    , data do documento
@param 07 cProduto  , caracter, código do produto
@param 08 cTRT      , caracter, TRT do produto
@param 09 nBaixaEst , numérico, quantidade da baixa
@param 10 cTipDocSai, caracter, tipo do documento de saída
@param 11 cNumDocSai, caracter, número do documento de saída
@param 12 cDocPai   , caracter, número do documento pai da HWC
@param 13 nSequen   , numérico, sequência do registro da HWC
@param 14 cIdOpc    , caracter, id do Opcional
@return Nil
/*/
METHOD trataEstoque(aRetorno, cTipo, cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, cTRT, nBaixaEst, cTipDocSai, cNumDocSai, cDocPai, nSequen, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aDelete    := {}
	Local aEntradas  := {}
	Local cIdReg     := ""
	Local cLote      := ""
	Local cSubLote   := ""
	Local dDataSaldo := Nil
	Local lNovoSaldo := cTipo == "3"
	Local nDel       := 0 
	Local nDiferen   := 0
	Local nFinish    := 0
	Local nIndex     := 0
	Local nLenEntr   := 0
	Local nStep      := 0

	Default cIdOpc   := ""

	cIdOpc := AllTrim(cIdOpc)
	cIdReg := cTipo + "_" + cFilAux + cProduto + cIdOpc

	Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)
	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)

	If !Empty(aEntradas)
		aSort(aEntradas, , , {|x,y| Iif(x[ASALDOS_POS_TIPO]=="E", "0", "1") + ;
		                            Iif(x[ASALDOS_POS_TIPO]=="P", "1", "0") + ;
		                            DtoS(x[ASALDOS_POS_DATA]) +;
		                            Iif(x[ASALDOS_POS_TIPO]=="SI", DtoS(x[ASALDOS_POS_VENCIMENTO]), "0") +;
		                            x[ASALDOS_POS_TIPO]       +;
		                            x[ASALDOS_POS_NUM_DOC_ENTRADA] ;
		                           < ;
		                            Iif(y[ASALDOS_POS_TIPO]=="E", "0", "1") + ;
		                            Iif(y[ASALDOS_POS_TIPO]=="P", "1", "0") + ;
		                            DtoS(y[ASALDOS_POS_DATA]) +;
		                            Iif(y[ASALDOS_POS_TIPO]=="SI", DtoS(y[ASALDOS_POS_VENCIMENTO]), "0") +;
		                            y[ASALDOS_POS_TIPO]       +;
		                            y[ASALDOS_POS_NUM_DOC_ENTRADA]})

		nLenEntr := Len(aEntradas)
		nIndex   := 1
		If cTipo = "0"
			nStep   := 1
			nFinish := nLenEntr
		Else
			nStep   := -1
			nFinish := 1
		EndIf

		For nIndex := nLenEntr To nFinish Step nStep
			If aEntradas[nIndex][ASALDOS_POS_DATA] > dData
				Loop
			EndIf 

			//Verifica se o saldo estava válido na data da baixa
			If !Empty(aEntradas[nIndex][ASALDOS_POS_VENCIMENTO]) .And. !Self:oDominio:oParametros["lExpiredLot"] .And. aEntradas[nIndex][ASALDOS_POS_VENCIMENTO] < dData
				Loop
			EndIf

			//Somente utiliza documentos de ponto de pedido se os documentos foram criados em períodos anteriores.
			If aEntradas[nIndex][ASALDOS_POS_TIPO] == "P" .And. aEntradas[nIndex][ASALDOS_POS_DATA] == dData
				Loop
			EndIf

			cTipDocEnt := aEntradas[nIndex][ASALDOS_POS_TIPO           ]
			cNumDocEnt := aEntradas[nIndex][ASALDOS_POS_NUM_DOC_ENTRADA]
			dDataSaldo := aEntradas[nIndex][ASALDOS_POS_DATA           ]
			cLote      := aEntradas[nIndex][ASALDOS_POS_LOTE           ]
			cSubLote   := aEntradas[nIndex][ASALDOS_POS_SUBLOTE        ]
			nDiferen   := nBaixaEst - aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]

			If nDiferen == 0
				aAdd(aDelete, nIndex)
			ElseIf nDiferen < 0
				aEntradas[nIndex][4] -= nBaixaEst
			Else
				nBaixaEst := aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]
				aAdd(aDelete, nIndex)
			EndIf

			aAdd(aRetorno, Self:montaRetorno(cFilAux                , ;
			                                 GetTipoEnt(cTipDocEnt) , ;
			                                 cNumDocEnt             , ;
			                                 dDataSaldo             , ;
			                                 cProduto               , ;
			                                 nBaixaEst              , ;
			                                 "2"                    , ;
			                                 cTipDocSai             , ;
			                                 cNumDocSai             , ;
			                                 cTRT                   , ;
			                                 ""                     , ;
			                                 ""                     , ;
			                                 cDocPai                , ;
			                                 cIdOpc                 , ;
			                                 cLote                  , ;
			                                 cSubLote               , ;
											 lNovoSaldo) )

			If nDiferen == 0
				nBaixaEst := 0
				Exit
			ElseIf nDiferen < 0
				nBaixaEst := 0
				Exit
			Else
				nBaixaEst := nDiferen
			EndIf
		Next nIndex

		aSort(aDelete, , , {|x,y|x > y})
		
		For nDel := 1 to Len(aDelete)
			aDel(aEntradas, aDelete[nDel])
		Next nDel
		aSize(aEntradas, (Len(aEntradas) - Len(aDelete)))

		If nLenEntr == 0
			Self:oDados:delItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)
		Else
			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aEntradas)
		EndIf
	EndIf

	Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aSize(aEntradas, 0)

Return

/*/{Protheus.doc} getQtdEntrada
Retorna qual é a quantidade de entradas que o produto possui.

@author lucas.franca
@since 29/10/2021
@version P12
@param 01 cFilAux , caracter, filial do registro
@param 02 cProduto, caracter, código do produto
@param 03 dData   , date    , data da avaliação
@param 04 cIdOpc  , caracter, id do opcional
@return nQtdEst, Numeric, Quantidade de saldo em estoque
/*/
METHOD getQtdEntrada(cFilAux, cProduto, dData, cIdOpc) CLASS MrpDominio_RastreioEntradas
	Local aEntradas  := {}
	Local cIdReg     := "1_" + cFilAux + cProduto + AllTrim(cIdOpc)
	Local nIndex     := 0
	Local nLenEntr   := 0
	Local nQtdEst    := 0

	aEntradas := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg)

	If !Empty(aEntradas)

		nLenEntr := Len(aEntradas)
		For nIndex := 1 To nLenEntr

			//Verifica se o saldo é posterior à data da baixa
			If aEntradas[nIndex][ASALDOS_POS_DATA] > dData
				Loop
			EndIf

			//Verifica se o saldo estava válido na data da baixa
			If !Empty(aEntradas[nIndex][ASALDOS_POS_VENCIMENTO]) .And. aEntradas[nIndex][ASALDOS_POS_VENCIMENTO] < dData
				Loop
			EndIf

			//Somente utiliza documentos de ponto de pedido se os documentos foram criados em períodos anteriores.
			If aEntradas[nIndex][ASALDOS_POS_TIPO] == "P" .And. aEntradas[nIndex][ASALDOS_POS_DATA] == dData
				Loop
			EndIf

			nQtdEst += aEntradas[nIndex][ASALDOS_POS_QUANTIDADE]
		Next nIndex

		aSize(aEntradas, 0)
	EndIf

Return nQtdEst

/*/{Protheus.doc} addAglutinado
Grava em uma variável global os documentos origem do documento de aglutinação
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cFilAux , caracter, filial do registro
@param 02 cDocAgl , caracter, número do documento Aglutinado (DEM0000000, EMP0000000, SAI0000000)
@param 03 cTipoOri, caracter, tipo do documento origem
@param 04 cDocOri , caracter, número do documento origem
@param 05 nSeqOri , numérico, sequência do documento origem
@param 06 cTRT    , caracter, sequência do produto na estrutura
@param 07 nNecess , numérico, necessidade
@param 08 nSubsti , numérico, quantidade subtituída
@param 09 cDocFil , caracter, número do documento filho
@return Nil
/*/
METHOD addAglutinado(cFilAux, cDocAgl, cTipoOri, cDocOri, nSeqOri, cTRT, nNecess, nSubsti, cDocFil) CLASS MrpDominio_RastreioEntradas
	Local aAglut    := {}
	Local aAux   	:= {}
	Local cIdReg	:= ""
	Local lErro 	:= .F.

	Default cDocFil := ""

	If Self:lAglutinado
		If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
			cFilAux := xFilial("SME")
		EndIf

		aAux    := Array(AAGLUTINA_SIZE)
		cIdReg  := IND_CHAVE_REG_AGLUTINADO + Trim(cDocAgl)

		aAux[AAGLUTINA_POS_FILIAL         ] := cFilAux
		aAux[AAGLUTINA_POS_TIPO_DOC_ORIGEM] := Trim(cTipoOri)
		aAux[AAGLUTINA_POS_NUM_DOC_ORIGEM ] := cDocOri
		aAux[AAGLUTINA_POS_SEQ_ORIGEM     ] := cValtoChar(nSeqOri)
		aAux[AAGLUTINA_POS_NECESSIDADE    ] := nNecess
		aAux[AAGLUTINA_POS_SUBTITUICAO    ] := nSubsti
		aAux[AAGLUTINA_POS_TRT            ] := cTRT
		aAux[AAGLUTINA_POS_DOC_FILHO	  ] := cDocFil
		aAux[AAGLUTINA_POS_USA_FIL_DESTINO] := .F.

		Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
		If lErro .Or. Empty(aAglut)
			aAglut := {}
		EndIf

		aAdd(aAglut, aAux)
		Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aAglut)

		Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)
	EndIf

	aSize(aAux  , 0)
	aSize(aAglut, 0)

Return

/*/{Protheus.doc} trataAglutinado
Busca e atualiza o array com os documentos aglutinados (explode a aglutinação)
@author marcelo.neumann
@since 30/11/2020
@version 1
@param aRegistro, array, registro a ser atualizado
@return Nil
/*/
METHOD trataAglutinado(aRegistro) CLASS MrpDominio_RastreioEntradas
	Local aRegAux := {}

	If Self:lAglutinado .And. !Empty(aRegistro)
		aRegAux   := Self:substituiAglutinados("E", aRegistro, .T.)
		aRegistro := Self:substituiAglutinados("S", aRegAux  , .T.)
	EndIf

Return

/*/{Protheus.doc} substituiAglutinados
Retorna o array com a rastreabilidade das entradas
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cOrigem   , caracter, indica qual o documento será subtituído/avaliado ("E" Entrada, "S" Saída)
@param 02 aAglutinad, array   , registro a ser atualizado
@param 03 lRetOPEmp , lógico  , indica se irá retornar a OP do empenho (.T.) ou a sua chave (.F.)
@return   aRetorno  , array   , registro com os o número de documento original
/*/
METHOD substituiAglutinados(cOrigem, aAglutinad, lRetOPEmp) CLASS MrpDominio_RastreioEntradas
	Local aAglut     := {}
	Local aDelAglut  := {}
	Local aRelac     := {}
	Local aRetorno   := {}
	Local cDocAux    := ""
	Local cDocPai    := ""
	Local cFilAux    := ""
	Local cFilDest   := ""
	Local cIdOpc     := ""
	Local cIdPai     := ""
	Local cIdRegAg   := ""
	Local cIdRegFi   := ""
	Local cLote      := ""
	Local cNewDoc    := ""
	Local cNumDocEnt := ""
	Local cNumDocSai := ""
	Local cProduto   := ""
	Local cSubLote   := ""
	Local cTipDocEnt := ""
	Local cTipDocSai := ""
	Local cTipo      := ""
	Local cTRT       := ""
	Local dData      := Nil
	Local lNovoSaldo := .F.
	Local nBaixaEst  := 0
	Local nIndex     := 0
	Local nIndHWG    := 0
	Local nLenHWG    := 0
	Local nLenReg    := 0
	Local nNecess    := 0
	Local nQtdComp   := 0
	Local nSequenc   := 0
	Local nTotNec    := 0
	Local oDocsProc  := JsonObject():New()

	If _nSizeDEnt == Nil
		_nSizeDEnt := GetSx3Cache("ME_NMDCENT","X3_TAMANHO")
	EndIf

	nLenReg := Len(aAglutinad)
	For nIndex := 1 To nLenReg
		cFilAux    := aAglutinad[nIndex][1]
		cTipDocEnt := aAglutinad[nIndex][2]
		cNumDocEnt := aAglutinad[nIndex][3]
		dData      := aAglutinad[nIndex][4]
		cProduto   := aAglutinad[nIndex][5]
		nBaixaEst  := aAglutinad[nIndex][6]
		cTipo      := aAglutinad[nIndex][7]
		cTipDocSai := aAglutinad[nIndex][8]
		cNumDocSai := aAglutinad[nIndex][9]
		cTRT       := aAglutinad[nIndex][10]
		cIdPai     := aAglutinad[nIndex][11]
		cDocPai    := aAglutinad[nIndex][13]
		cIdOpc     := AllTrim(aAglutinad[nIndex][14])
		cLote      := aAglutinad[nIndex][15]
		cSubLote   := aAglutinad[nIndex][16]
		lNovoSaldo := aAglutinad[nIndex][17]
		nNecess    := aAglutinad[nIndex][18]
		nSequenc   := aAglutinad[nIndex][19]

		If cTipDocSai == STR0144 .And. cOrigem == "E" //"Ponto Ped."
			cIdRegAg := ""
			aAglut   := {}
		Else
			If cOrigem == "E"
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cNumDocEnt)
			Else
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cNumDocSai)
			EndIf
		EndIf

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)

		If cOrigem == "S" .And. Empty(aAglut) .And. cTipDocSai == "TRANF_PR" .And. Left(cNumDocSai, 5) == "TRANF"
			//Se é uma transferência de produção e não encontrou aglutinação para o documento de transferência,
			//verifica se existe aglutinação no documento de origem.
			Self:oDominio:oMultiEmp:retornaDadosTransferenciaDocumento(Trim(cNumDocSai), "", @cDocAux)
			If !Empty(cDocAux)
				cIdRegAg := IND_CHAVE_REG_AGLUTINADO + Trim(cDocAux)
				aAglut   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg)
			EndIf
		EndIf

		If Empty(aAglut)

			Self:carregaDocsSaida(Trim(cNumDocSai))
			If cOrigem == "S" .And. Self:oDocsSaida[Trim(cNumDocSai)] != Nil
				Self:quebraAglutinacaoPai(@aRetorno             ,;
				                          cFilAux               ,;
				                          cProduto              ,;
				                          aAglutinad[nIndex][10],;
				                          nBaixaEst             ,;
				                          nBaixaEst             ,;
				                          cTipDocEnt            ,;
				                          cNumDocEnt            ,;
				                          cTipDocSai            ,;
				                          Trim(cNumDocSai)      ,;
				                          dData                 ,;
				                          cTipo                 ,;
				                          cDocPai               ,;
				                          aAglutinad[nIndex][10],;
				                          @oDocsProc            ,;
				                          cValtochar(nSequenc)  ,;
				                          cIdPai                ,;
				                          cIdOpc                ,;
				                          cLote                 ,;
				                          cSubLote              ,;
				                          lNovoSaldo            ,;
				                          nNecess                )
			Else
				aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
				                                 cTipDocEnt, ;
				                                 cNumDocEnt, ;
				                                 dData     , ;
				                                 cProduto  , ;
				                                 nBaixaEst , ;
				                                 cTipo     , ;
				                                 cTipDocSai, ;
				                                 cNumDocSai, ;
				                                 cTRT      , ;
				                                 cIdPai    , ;
				                                 ""        , ;
				                                 cDocPai   , ;
				                                 cIdOpc    , ;
				                                 cLote     , ;
				                                 cSubLote  , ;
				                                 lNovoSaldo, ;
				                                 nNecess   , ;
												 nSequenc   ) )
			EndIf
		Else
			If cOrigem == "S"
				Self:trataAglutTransf(@aAglut)
			EndIf
			nLenHWG := Len(aAglut)
			For nIndHWG := 1 To nLenHWG

				cFilDest := ""

				If cOrigem == "E"
					cTipDocEnt := GetTipoEnt(aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM])
					cNumDocEnt := aAglut[nIndHWG][AAGLUTINA_POS_NUM_DOC_ORIGEM]
				Else
					cTipDocSai := aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM]
					cNumDocSai := aAglut[nIndHWG][AAGLUTINA_POS_NUM_DOC_ORIGEM]
					If aAglut[nIndHWG][AAGLUTINA_POS_USA_FIL_DESTINO]
						cFilDest := aAglut[nIndHWG][AAGLUTINA_POS_FILIAL]
					EndIf
				EndIf
				cDocAux := "DOCPAI_" + Trim(cNumDocSai) + aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM]
				If (oDocsProc[Trim(cNumDocSai)] != Nil .And. cTipDocSai == STR0144) .Or. ; //Ponto Ped.
				   (oDocsProc[cDocAux] != Nil .And. oDocsProc[cDocAux])
					Loop
				EndIf

				nDiferen := nBaixaEst - aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE]
				nQtdComp := nBaixaEst

				If nDiferen > 0
					nBaixaEst := aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE]
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := 0

				ElseIf nDiferen == 0
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := 0

				Else
					aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] := -nDiferen
				EndIf

				If lRetOPEmp .And. aAglut[nIndHWG][AAGLUTINA_POS_TIPO_DOC_ORIGEM] == "Pré-OP"
					If cOrigem == "E"
						cNewDoc := Self:getDocEmpenho(cNumDocEnt)[1]
						If PadR(cNewDoc, _nSizeDEnt) <> PadR(cNumDocEnt, _nSizeDEnt)
							cNumDocEnt := cNewDoc
							cTipDocEnt := aAglutinad[nIndex][2]
						EndIf
					Else
						cNumDocSai := Self:getDocEmpenho(cNumDocSai)[1]
					EndIf
				EndIf

				If cOrigem == "S"

					If Empty(aAglut[nIndHWG][AAGLUTINA_POS_DOC_FILHO])
						cIdRegFi := IND_CHAVE_AGLUT_DOC_FILHO + aAglut[nIndHWG][AAGLUTINA_POS_SEQ_ORIGEM] + "_" + Trim(cNumDocSai)
						aRelac   := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegFi)
					Else
						aRelac	 := {aAglut[nIndHWG][AAGLUTINA_POS_DOC_FILHO]}
					Endif

					If !Empty(aRelac)
						If (cTipDocSai == "TRANF_ES" .Or. (cTipDocSai == "TRANF_PR" .And. Left(aRelac[1], 5) == "TRANF")) == .F.
							cTipDocSai := "OP"
						EndIf
						cNumDocSai := aRelac[1]
					EndIf
				EndIf

				cTRT := aAglut[nIndHWG][AAGLUTINA_POS_TRT]

				Self:carregaDocsSaida(cNumDocSai)
				If cOrigem == "S" .And. Self:oDocsSaida[cNumDocSai] != Nil

					Self:quebraAglutinacaoPai(@aRetorno             ,;
					                          cFilAux               ,;
					                          cProduto              ,;
					                          aAglutinad[nIndex][10],;
					                          nBaixaEst             ,;
					                          nQtdComp              ,;
					                          cTipDocEnt            ,;
					                          cNumDocEnt            ,;
					                          cTipDocSai            ,;
					                          cNumDocSai            ,;
					                          dData                 ,;
					                          cTipo                 ,;
					                          cDocPai               ,;
					                          cTRT                  ,;
					                          @oDocsProc            ,;
					                          cValtochar(nSequenc)  ,;
					                          cIdPai                ,;
					                          cIdOpc                ,;
					                          cLote                 ,;
					                          cSubLote              ,;
					                          lNovoSaldo            ,;
					                          nNecess               ,;
					                          cFilDest              )

				Else
					aAdd(aRetorno, Self:montaRetorno(cFilAux   , ;
					                                 cTipDocEnt, ;
					                                 cNumDocEnt, ;
					                                 dData     , ;
					                                 cProduto  , ;
					                                 nBaixaEst , ;
					                                 cTipo     , ;
					                                 cTipDocSai, ;
					                                 cNumDocSai, ;
					                                 cTRT      , ;
					                                 ""        , ;
					                                 ""        , ;
					                                 cDocPai   , ;
					                                 cIdOpc    , ;
					                                 cLote     , ;
					                                 cSubLote  , ;
					                                 lNovoSaldo, ;
					                                 nNecess   , ;
					                                 /*19*/    , ;
					                                 cFilDest  ) )
				EndIf

				oDocsProc[Trim(cNumDocSai)] := .T.

				nTotNec += nBaixaEst

				If aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] == 0 .And. nTotNec >= nNecess
					oDocsProc[cDocAux] := .T.
				EndIf

				If aAglut[nIndHWG][AAGLUTINA_POS_NECESSIDADE] == 0 .And. aAglut[nIndHWG][AAGLUTINA_POS_SUBTITUICAO] == 0
					aAdd(aDelAglut, nIndHWG)
				EndIf

				If nDiferen > 0
					nBaixaEst := nDiferen

				ElseIf nDiferen == 0
					nBaixaEst := 0
					Exit

				Else
					nBaixaEst := 0
					Exit
				Endif
			Next nIndHWG

			//Verifica a necessidade de eliminar linhas zeradas
			nLenHWG := Len(aDelAglut)
			If nLenHWG > 0
				For nIndHWG := nLenHWG To 1 Step -1
					aDel(aAglut, aDelAglut[nIndHWG])
				Next nIndHWG
				aSize(aAglut, Len(aAglut)-nLenHWG)
				aSize(aDelAglut, 0)
			EndIf

			Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdRegAg, aAglut)

		EndIf

		aSize(aAglutinad[nIndex], 0)
	Next nIndex

	aSize(aAglutinad, 0)
	aSize(aAglut    , 0)
	aSize(aRelac    , 0)
	FreeObj(oDocsProc)
	oDocsProc := Nil
Return aRetorno

/*/{Protheus.doc} trataAglutTransf
Verifica as quebras de aglutinação para transferências de produção

@author lucas.franca
@since 17/10/2023
@version P12
@param 01 aAglut, Array, Array com as aglutinações originais
@return Nil
/*/
METHOD trataAglutTransf(aAglut) CLASS MrpDominio_RastreioEntradas
	Local aTroca   := {}
	Local aAglOrig := {}
	Local cIdDoc   := ""
	Local nIndex   := 0
	Local nTotal   := Len(aAglut)
	Local nTotAdd   := 0
	Local nIndAdd   := 0
	Local nIndAux   := 0

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		Return
	EndIf

	For nIndex := 1 To nTotal
		/*
			Quando é um registro de transferência de produção, verifica no documento de origem
			qual é o documento correto para criar o vínculo.
		*/
		If aAglut[nIndex][AAGLUTINA_POS_TIPO_DOC_ORIGEM] == "TRANF_PR" .And. Left(aAglut[nIndex][AAGLUTINA_POS_DOC_FILHO], 5) == "TRANF"

			cIdDoc   := IND_CHAVE_REG_AGLUTINADO + Trim(aAglut[nIndex][AAGLUTINA_POS_NUM_DOC_ORIGEM])
			aAglOrig := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdDoc)

			If !Empty(aAglOrig)
				//Armazena o array aTroca os dados da origem para substituir no Self:oDocsSaida
				aAdd(aTroca, {nIndex, aAglOrig})
			EndIf
		EndIf

	Next nIndex

	nTotal := Len(aTroca)

	For nIndex := nTotal To 1 Step -1
		//Percorre o array aTroca e substitui os dados que estão no array aAglut
		nTotAdd := Len(aTroca[nIndex][2])

		If nTotAdd > 0
			//Ajusta o tamanho do array aAglut para receber os novos registros
			aSize(aAglut, Len(aAglut) + nTotAdd -1)

			//Remove de aAglut o registro original e adiciona os novos referente ao documento de origem da transferência
			aDel(aAglut, aTroca[nIndex][1])

			For nIndAdd := 1 To nTotAdd
				//Insere um elemento nulo na posição correta do aAglut e em seguida copia o conteudo de aTroca
				nIndAux := aTroca[nIndex][1] + nIndAdd - 1
				aIns(aAglut, nIndAux)
				aAglut[nIndAux] := aTroca[nIndex][2][nIndAdd]
				aAglut[nIndAux][AAGLUTINA_POS_USA_FIL_DESTINO] := .T.
				aTroca[nIndex][2][nIndAdd] := Nil
			Next nIndAdd
		EndIf

		aTroca[nIndex][2] := Nil
		aTroca[nIndex]    := Nil
	Next nIndex

	aSize(aTroca, 0)
Return

/*/{Protheus.doc} quebraAglutinacaoPai
Gera a quebra da aglutinação do produto pai

@author lucas.franca
@since 26/03/2021
@version P12
@param 01 aRetorno  , Array     , Array para adicionar as informações da quebra
@param 02 cFilAux   , Character , Filial para gravação
@param 03 cProduto  , Character , Código do produto
@param 04 cTRT      , Character , Sequência da estrutura
@param 05 nBaixaEst , Numeric   , Quantidade de baixa
@param 06 nDistrib  , Numeric   , Quantidade total do componente
@param 07 cTipDocEnt, Character , Tipo do documento de entrada
@param 08 cNumDocEnt, Character , Número do documento de entrada
@param 09 cTipDocSai, Character , Tipo do documento de saída
@param 10 cNumDocSai, Character , Número do documento de saída
@param 11 dData     , Date      , Data do documento
@param 12 cTipo     , Character , Tipo do documento
@param 13 cDocPai   , Character , Documento pai
@param 14 cTRTAgl   , Character , Sequência da estrutura da aglutinação
@param 15 oDocsProc , JsonObject, Objeto para controlar os documentos que já foram processados.
@param 16 cSeq      , Character , Sequência do documento pai
@param 17 cIdPai    , Character , Identificador de registro pai
@param 18 cIdOpc    , Character , Id do Opcional
@param 19 cLote     , Character , Código do lote
@param 20 cSubLote  , Character , Código do sub-lote
@param 21 lNovoSaldo, Logico    , Indica que a saida consumiu uma entrada de novo saldo.
@param 22 nNecess   , Numerico  , Necessidade do documento de saída
@param 23 cFilDest  , Caracter  , Filial de destino do registro (transferências)
@return Nil
/*/
METHOD quebraAglutinacaoPai(aRetorno, cFilAux, cProduto, cTRT, nBaixaEst, nDistrib, cTipDocEnt, cNumDocEnt, cTipDocSai, ;
                            cNumDocSai, dData, cTipo, cDocPai, cTRTAgl, oDocsProc, cSeq, cIdPai, cIdOpc, cLote, cSubLote,;
                            lNovoSaldo, nNecess, cFilDest) CLASS MrpDominio_RastreioEntradas
	Local aQtdComp   := {}
	Local cIdPaiQueb := ""
	Local cChavePai  := ""
	Local nIndQuebra := 0
	Local nIndQtd    := 0
	Local nFinish    := 0
	Local nStart     := 0
	Local nStep      := 0
	Local nQtdFilho  := 0
	Local nTotQuebra := Len(Self:oDocsSaida[cNumDocSai])
	Local nTotQtd    := 0

	Default cFilDest := ""

	cIdOpc := AllTrim(cIdOpc)

	If cTipDocEnt == "0"
		nStep   := -1
		nFinish := 1
		nStart  := nTotQuebra
	Else
		nStep   := 1
		nFinish := nTotQuebra
		nStart  := 1
	EndIf

	For nIndQuebra := nStart To nFinish Step nStep
		If oDocsProc[Trim(Self:oDocsSaida[cNumDocSai][nIndQuebra][9])] != Nil .And. ;
		   Self:oDocsSaida[cNumDocSai][nIndQuebra][8] == STR0144 //Ponto Ped.
			Loop
		Else
			oDocsProc[Trim(Self:oDocsSaida[cNumDocSai][nIndQuebra][9])] := .T.
		EndIf

		If cTipDocSai == "OP"
			aQtdComp := Self:buscaQtdComp(cNumDocSai, nIndQuebra, cProduto, cTRT, cFilAux)
		Else
			aQtdComp := {{nBaixaEst, cTRTAgl}}
		EndIf

		If cTipDocSai != "Pré-OP"
			If Empty(cIdPai)
				cIdPaiQueb := Self:oDocsSaida[cNumDocSai][nIndQuebra][12]
			Else
				cIdPaiQueb := cIdPai
			EndIf
		EndIf

		nTotQtd := Len(aQtdComp)

		For nIndQtd := 1 To nTotQtd

			cChavePai := cIdPaiQueb + ";" + RTrim(cProduto) + ";" + RTrim(aQtdComp[nIndQtd][2]) + cSeq

			Self:oUsoDoc[cChavePai] := Self:oDados:getItemList(IND_CHAVE_DOCUMENTOS_USO, cChavePai)
			If Self:oUsoDoc[cChavePai] == Nil
				Self:oUsoDoc[cChavePai] := 0
			EndIf

			If aQtdComp[nIndQtd][1] > nDistrib
				nQtdFilho := nDistrib
			Else
				nQtdFilho := aQtdComp[nIndQtd][1]
			EndIf

			If !Empty(cIdPaiQueb) .And. Empty(cIdPai) .And. Self:oDocsSaida[cNumDocSai][nIndQuebra][21] == .F. .And. cTipDocSai != "TRANF_ES"
				If Self:oUsoDoc[cChavePai] >= aQtdComp[nIndQtd][1] .And. nIndQuebra <> nFinish
					//Atingiu o limite de qtd desse pai. Passa para o próximo.
					Loop
				EndIf
				If Self:oUsoDoc[cChavePai] + nQtdFilho > aQtdComp[nIndQtd][1]
					nQtdFilho := aQtdComp[nIndQtd][1] - Self:oUsoDoc[cChavePai]
				EndIf
			EndIf

			aAdd(aRetorno, Self:montaRetorno(cFilAux             , ;
			                                 cTipDocEnt          , ;
			                                 cNumDocEnt          , ;
			                                 dData               , ;
			                                 cProduto            , ;
			                                 nQtdFilho           , ;
			                                 cTipo               , ;
			                                 cTipDocSai          , ;
			                                 cNumDocSai          , ;
			                                 aQtdComp[nIndQtd][2], ;
			                                 cIdPaiQueb          , ;
			                                 ""                  , ;
			                                 cDocPai             , ;
			                                 cIdOpc              , ;
			                                 cLote               , ;
			                                 cSubLote            , ;
			                                 lNovoSaldo          , ;
			                                 nNecess             , ;
			                                 /*19*/              , ;
			                                 cFilDest            ) )

			nDistrib -= nQtdFilho

			If !Empty(cIdPaiQueb) .And. Empty(cIdPai)
				Self:oUsoDoc[cChavePai] += nQtdFilho
			EndIf

			Self:oDados:setItemList(IND_CHAVE_DOCUMENTOS_USO, cChavePai, Self:oUsoDoc[cChavePai])

			If nDistrib <= 0
				Exit
			EndIf
		Next nIndQtd

		aSize(aQtdComp, 0)

		If nDistrib <= 0
			Exit
		EndIf
	Next nIndQuebra
Return

/*/{Protheus.doc} addRelacionamentoDocFilho
Adiciona o DE-PARA entre uma entrada aglutinada e uma saída
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cDocAgl  , caracter, documento aglutinado
@param 02 nSequen  , numérico, sequência do documento
@param 03 cDocFilho, caracter, documento filho
@return Nil
/*/
METHOD addRelacionamentoDocFilho(cDocAgl, nSequen, cDocFilho) CLASS MrpDominio_RastreioEntradas
	Local aAglut := {}
	Local cIdReg := IND_CHAVE_AGLUT_DOC_FILHO + cValToChar(nSequen) + "_" + Trim(cDocAgl)
	Local lErro  := .F.

	If Self:lAglutinado
		Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aAglut := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
		If lErro .Or. Empty(aAglut)
			aAglut := {}
		EndIf

		aAdd(aAglut, cDocFilho)
		Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aAglut)

		Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

		aSize(aAglut, 0)
	EndIf

Return

/*/{Protheus.doc} addDocEmpenho
Adiciona o DE-PARA entre o IDREG do empenho e sua OP
@author marcelo.neumann
@since 30/11/2020
@version 1
@param 01 cIdReg    , caracter, identificador do empenho
@param 02 cDocumento, caracter, número da OP
@param 03 cDocOrigem, caracter, número da OP origem do empenho
@param 04 lAddPre   , lógico  , indica se adiciona o prefixo "Pre_" no número do documento
@return Nil
/*/
METHOD addDocEmpenho(cIdReg, cDocumento, cDocOrigem, lAddPre) CLASS MrpDominio_RastreioEntradas
	Local aDocEmp  := {}
	Local lErro    := .F.

	Default lAddPre := .T.

	If lAddPre
		cDocumento := "Pre_" + cDocumento
		cDocOrigem := "Pre_" + cDocOrigem
	EndIf

	cIdReg := IND_CHAVE_DE_PARA_EMPENHO + Trim(cIdReg)

	Self:oDados:trava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aDocEmp := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If lErro .Or. Empty(aDocEmp)
		aDocEmp := {}
	EndIf

	aAdd(aDocEmp, {cDocumento, cDocOrigem})
	Self:oDados:setItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, aDocEmp)

	Self:oDados:destrava(IND_NOME_LISTA_ENTRADAS + cIdReg)

	aSize(aDocEmp, 0)

Return

/*/{Protheus.doc} getDocEmpenho
Recupera o valor da OP correspondente ao empenho
@author marcelo.neumann
@since 30/11/2020
@version 1
@param  cDocum    , caracter, identificador do empenho
@return aDocEmp[1], array   , retorna as OPs relacionadas ao empenho: [1][1] - OP do empenho
                                                                      [1][2] - OP que originou o empenho
/*/
METHOD getDocEmpenho(cDocum) CLASS MrpDominio_RastreioEntradas
	Local aDocEmp  := {}
	Local cIdReg   := IND_CHAVE_DE_PARA_EMPENHO + Trim(cDocum)
	Local lErro    := .F.

	aDocEmp := Self:oDados:getItemAList(IND_NOME_LISTA_ENTRADAS, cIdReg, @lErro)
	If lErro .Or. Empty(aDocEmp)
		Return {cDocum, " "}
	EndIf

Return aDocEmp[1]

/*/{Protheus.doc} buscaDocsAglutinados
Busca os documentos aglutinados de entrada, e qual a quantidade disponível em cada um.

@author lucas.franca
@since 07/01/2021
@version P12
@param 01 aLinha, Array, array com os dados de memória da rastreabilidade.
@param 02 nSequen, Numeric, numero da sequencia do documento gerado.
@return aDocs, Array, Array com os documentos para utilização, e qual a quantidade disponível em cada documento.
/*/
METHOD buscaDocsAglutinados(aLinha, nSequen) CLASS MrpDominio_RastreioEntradas
	Local aDocs      := {}
	Local aNecAgl    := {}
	Local cNumDocEnt := ""
	Local cPrdComOpc := aLinha[Self:nPosProduto] + Iif(!Empty(aLinha[Self:nPosIdOpc]) , "|" + aLinha[Self:nPosIdOpc], "")
	Local nNecess    := aLinha[Self:nPosRastreio][1]
	Local nQtdDisp   := 0
	Local nIndQuebra := 0
	Local nTotQuebra := 0

	aNecAgl := Self:oDominio:oRastreio:retornaRastreio(aLinha[Self:nPosFilial], cPrdComOpc, aLinha[Self:nPosPeriodo], aLinha[Self:nPosRastreio][2], "")
	If !Empty(aNecAgl)
		nTotQuebra := Len(aNecAgl[Self:nPosQuebras])

		For nIndQuebra := 1 To nTotQuebra
			//Verifica se o documento atual possui quantidade disponível
			nQtdDisp := Self:reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nNecess)
			If nQtdDisp > 0
				//Possui quantidade disponível, verifica qual é o número de documento para gerar rastreabilidade
				If !Empty(aNecAgl[Self:nPosQuebras][nIndQuebra][2])
					cNumDocEnt := aNecAgl[Self:nPosQuebras][nIndQuebra][2]
				ElseIf aNecAgl[Self:nPosTrfEnt] > 0 .And. !Empty(aNecAgl[Self:nPosDocFilho])
					cNumDocEnt := aNecAgl[Self:nPosDocFilho]
				Else
					cNumDocEnt := aLinha[Self:nPosRastreio][2] + "_" + cValToChar(nSequen) + "_Filha"
				EndIf
				//Adiciona no array para retornar, número de documento e quantidade
				aAdd(aDocs, {cNumDocEnt, nQtdDisp})
			EndIf
			//Desconta da necessidade total a quantidade já utilizada.
			nNecess -= nQtdDisp
			If nNecess <= 0
				//Se atendeu toda a necessidade, sai do FOR.
				Exit
			EndIf
		Next nIndQuebra
	EndIf
	aSize(aNecAgl, 0)
Return aDocs

/*/{Protheus.doc} reservaQtdDocEntrada
Reserva quantidade do documento de entrada para uma demanda.

@author lucas.franca
@since 07/01/2021
@version P12
@param 01 aLinha    , Array  , array com os dados de memória da rastreabilidade do registro que está sendo gerado.
@param 02 aNecAgl   , Array  , array com os dados de memória da rastreabilidade do registro com as necessidades aglutinadas.
@param 03 nIndQuebra, Numeric, índice da quebra da necessidade que deve ser avaliado.
@param 04 nQtdNecess, Numeric, Quantidade necessária
@return nQuant, Numeric, Quantidade disponível do documento.
/*/
METHOD reservaQtdDocEntrada(aLinha, aNecAgl, nIndQuebra, nQtdNecess) CLASS MrpDominio_RastreioEntradas
	Local cChave    := "RESERVAQTD" + aLinha[Self:nPosRastreio][2] + cValToChar(nIndQuebra)
	Local lError    := .F.
	Local nQuant    := 0
	Local nQtdDisp  := aNecAgl[Self:nPosQuebras][nIndQuebra][1] + aNecAgl[Self:nPosTrfEnt]
	Local nQtdUsada := 0

	//Trava a chave.
	Self:oDados:trava(cChave)

	//Verifica qual a quantidade deste documento já foi reservada
	nQtdUsada := Self:oDados:getFlag(cChave, @lError, .F.)

	//Se não encontrou a flag, toda a quantidade ainda está disponível.
	If lError
		nQtdUsada := 0
	EndIf

	//Desconta da quantidade disponível a quantidade que já foi utilizada.
	nQtdDisp -= nQtdUsada

	//Utiliza a quantidade que for necessária para atender a necessidade.
	If nQtdNecess >= nQtdDisp
		nQuant := nQtdDisp
	Else
		nQuant := nQtdNecess
	EndIf

	//Atualiza a quantidade já utilizada
	nQtdUsada += nQuant
	Self:oDados:setFlag(cChave, nQtdUsada, @lError, .F.)

	//Libera o lock
	Self:oDados:destrava(cChave)
Return nQuant

/*/{Protheus.doc} buscaQtdComp
Busca a quantidade utilizada de um componente em relação a um produto pai

@author lucas.franca
@since 17/03/2021
@version P12
@param 01 cNumDocSai, Character, Documento de saída
@param 02 nIndQuebra, Numeric  , índice do array Self:oDocsSaida[cNumDocSai][nIndQuebra] em avaliação
@param 03 cCompon   , Character, código do componente em análise
@param 04 cTRT      , Character, Sequência do componente
@param 05 cFilAux   , Character, Filial que está processando.
@return aQtdComp, Array, Array com as quantidades do componente
/*/
METHOD buscaQtdComp(cNumDocSai, nIndQuebra, cCompon, cTRT, cFilAux) CLASS MrpDominio_RastreioEntradas
	Local aRastreio  := {}
	Local aComponent := {}
	Local aQtdComp   := {}
	Local cFilCalc   := Self:converteFilialMultiEmpresa(cFilAux)
	Local cFilRas    := Self:converteFilialMultiEmpresa(Self:oDocsSaida[cNumDocSai][nIndQuebra][1])
	Local cFilEst    := ""
	Local cProdPai   := Self:oDocsSaida[cNumDocSai][nIndQuebra][5]
	Local cChaveEst  := cProdPai
	Local cDocOri    := Self:oDocsSaida[cNumDocSai][nIndQuebra][13]
	Local cIDOpc     := AllTrim(Self:oDocsSaida[cNumDocSai][nIndQuebra][14])
	Local cRevisao   := ""
	Local cTrtDocSai := ""
	Local lAglutina  := .F.
	Local nPeriodo   := 1

	lAglutina  := Self:oDominio:oAglutina:avaliaAglutinacao(cFilCalc, cCompon)
	nPeriodo   := Self:oDominio:oPeriodos:buscaPeriodoDaData(cFilCalc, Self:oDocsSaida[cNumDocSai][nIndQuebra][4], .F.)

	If !Empty(Self:oDocsSaida[cNumDocSai][nIndQuebra][10])
	   cTrtDocSai := Self:oDocsSaida[cNumDocSai][nIndQuebra][10]
	Endif

	aRastreio := Self:oDominio:oRastreio:retornaRastreio(cFilRas, cProdPai + Iif(!Empty(cIDOpc) , "|" + cIDOpc, ""), nPeriodo, cDocOri, cTrtDocSai)
	cTRT      := Trim(cTRT)

	If !Empty(aRastreio)
		If Self:oDocsSaida[cNumDocSai][nIndQuebra][21]
			cFilEst := cFilCalc
		Else
			cFilEst := cFilRas
		EndIf

		cRevisao := buscaRevisao(cFilEst, cProdPai, nPeriodo, cDocOri, aRastreio, Self)

		If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
			cChaveEst := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilEst) + cProdPai
		EndIf

		Self:oDominio:oDados:oEstruturas:getRow(1, cChaveEst,, @aComponent)

		If !Empty(aComponent)
			aQtdComp := Self:calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, Self:oDocsSaida[cNumDocSai][nIndQuebra], Self:oDocsSaida[cNumDocSai][nIndQuebra][6], cFilEst, nPeriodo, cIDOpc)

			aSize(aComponent, 0)
		EndIf
		aSize(aRastreio, 0)
	EndIf

Return aQtdComp

/*/{Protheus.doc} calculaQtdComp
Calcula a quantidade utilizada de um componente em relação a um produto pai

@author lucas.franca
@since 03/11/2021
@version P12
@param 01 aComponent, Array    , Array com a estrutura do produto
@param 02 cRevisao  , Character, Revisão do produto
@param 03 cCompon   , Character, código do componente em análise
@param 04 cTRT      , Character, Sequência do componente
@param 05 lAglutina , Logic    , Indica se o produto possui aglutinação
@param 06 aDocSaida , Array    , Array "Self:oDocsSaida[cNumDocSai][nIndQuebra]" que está sendo processado
@param 07 nNecPai   , Numeric  , Quantidade do produto pai
@param 08 cFilAux   , Character, Filial que está processando.
@param 09 nPeriodo  , Numeric  , Número do período
@param 10 cIDOpc    , Character, Id do opcional relacionado
@return aQtdComp, Array, Array com as quantidades do componente
/*/
METHOD calculaQtdComp(aComponent, cRevisao, cCompon, cTRT, lAglutina, aDocSaida, nNecPai, cFilAux, nPeriodo, cIDOpc) CLASS MrpDominio_RastreioEntradas
	Local aQtdComp    := {}
	Local aEstFant    := {}
	Local cRevFant    := ""
	Local cChaveEst   := ""
	Local cCodPai     := ""
	Local cFilEst     := ""
	Local nIndex      := 0
	Local nTotal      := Len(aComponent)
	Local nIndFant    := 0
	Local nTotFant    := 0
	Local nQtdFant    := 0
	Local lQtdFixa    := .F.
	Local lError      := .F.
	Local nQtdBasePrd := Nil


	For nIndex := 1 To nTotal

		lQtdFixa := IIf(aComponent[nIndex][Self:nPosQtdFix] == '1', .T., .F. )

		cCodPai := Self:converteFilialMultiEmpresa(cFilAux) + aComponent[nIndex][Self:nPosCodPai]
		nQtdBasePrd := ::oDominio:oDados:retornaCampo("PRD", 1, cCodPai, "PRD_QB", @lError, .F., , /*lProximo*/, , , .F. /*lVarios*/)

		If aComponent[nIndex][Self:nPosComp  ] == cCompon  .And. ;
		   aComponent[nIndex][Self:nPosRevIni] <= cRevisao .And. ;
		   aComponent[nIndex][Self:nPosRevFim] >= cRevisao .And. ;
		   (lAglutina .Or. Trim(aComponent[nIndex][Self:nPosTRT]) == cTRT)

			If !Empty(aComponent[nIndex][Self:nPosDatIni]) .Or. !Empty(aComponent[nIndex][Self:nPosDatFim])
				If aComponent[nIndex][Self:nPosDatIni] > aDocSaida[4] .Or. ;
				   aComponent[nIndex][Self:nPosDatFim] < aDocSaida[4]
					Loop
				EndIf
			EndIf

			aAdd(aQtdComp, {Self:oDominio:ajustarNecessidadeExplosao(Self:converteFilialMultiEmpresa(cFilAux), ;
			                                                         cCompon                                 , ;
			                                                         nNecPai                                 , ;
			                                                         aComponent[nIndex][Self:nPosQtdEst]     , ;
			                                                         lQtdFixa                                , ;
			                                                         Nil                                     , ;
			                                                         aComponent[nIndex][Self:nPosPotenc]     , ;
			                                                         aComponent[nIndex][Self:nPosPerda]      , ;
			                                                         Iif(nQtdBasePrd != Nil, nQtdBasePrd, aComponent[nIndex][Self:nPosQtdBas])), ;
			                                                         aComponent[nIndex][Self:nPosTRT]})

		ElseIf aComponent[nIndex][Self:nPosFant] == .T.
			cChaveEst := aComponent[nIndex][Self:nPosComp]
			cFilEst   := Self:converteFilialMultiEmpresa(cFilAux)
			If Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
				cChaveEst := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilAux) + aComponent[nIndex][Self:nPosComp]
			EndIf

			Self:oDominio:oDados:oEstruturas:getRow(1, cChaveEst,, @aEstFant)

			If Empty(aEstFant) .And. Self:oDominio:oMultiEmp:utilizaMultiEmpresa()
				//Se não encontrou a estrutura do produto fantasma
				//e utiliza multi-empresa, verifica se o fantasma possui estrutura em outra filial.
				cFilEst := Self:oDominio:oMultiEmp:buscaFilialEstrutura(cFilAux, aComponent[nIndex][Self:nPosComp], nPeriodo, cIDOpc)
				If !Empty(cFilEst)
					//Produto possui estrutura em outra filial. Busca os componentes.
					//Monta a chave da estrutura com a filial onde o produto fantasma possui estrutura e retorna os componentes.
					cChaveEst := Self:oDominio:oMultiEmp:getFilialTabela("T4N", cFilEst) + aComponent[nIndex][Self:nPosComp]
					Self:oDominio:oDados:oEstruturas:getRow(1, cChaveEst,, @aEstFant)
				EndIf
			EndIf

			If !Empty(aEstFant)
				cRevFant := Self:oDominio:revisaoProduto(Self:converteFilialMultiEmpresa(cFilAux) + aComponent[nIndex][Self:nPosComp])
				nQtdFant := Self:oDominio:ajustarNecessidadeExplosao(Self:converteFilialMultiEmpresa(cFilAux), ;
			                                                         aComponent[nIndex][Self:nPosComp]       , ;
			                                                         nNecPai                                 , ;
			                                                         aComponent[nIndex][Self:nPosQtdEst]     , ;
			                                                         lQtdFixa                                , ;
			                                                         Nil                                     , ;
			                                                         aComponent[nIndex][Self:nPosPotenc]     , ;
			                                                         aComponent[nIndex][Self:nPosPerda]      , ;
			                                                         Iif(nQtdBasePrd != Nil, nQtdBasePrd, aComponent[nIndex][Self:nPosQtdBas]))

				aQtdFant := Self:calculaQtdComp(aEstFant, cRevFant, cCompon, cTRT, lAglutina, aDocSaida, nQtdFant, cFilEst, nPeriodo, cIDOpc)
				aSize(aEstFant, 0)

				nTotFant := Len(aQtdFant)
				For nIndFant := 1 To nTotFant
					aAdd(aQtdComp, aQtdFant[nIndFant])
				Next nIndFant
				aSize(aQtdFant, 0)

			EndIf
		EndIf
	Next nIndex
Return aQtdComp

/*/{Protheus.doc} addDocsSaida
Adiciona os elementos de retorno no objeto oDocsSaida

@author lucas.franca
@since 29/03/2021
@version P12
@param 01 cNumDocEnt, Character, Documento de entrada
@param 02 aRetorno  , Array    , Array com os dados de retorno
@return Nil
/*/
METHOD addDocsSaida(cNumDocEnt, aRetorno) CLASS MrpDominio_RastreioEntradas
	Local nTotal := 0
	Local nIndex := 0

	If Self:oDocsSaida[cNumDocEnt] == Nil
		Self:oDocsSaida[cNumDocEnt] := aClone(aRetorno)
	Else
		nTotal := Len(aRetorno)
		For nIndex := 1 To nTotal
			aAdd(Self:oDocsSaida[cNumDocEnt], aClone(aRetorno[nIndex]))
		Next nIndex
	EndIf
	//Registra na memória global os dados do documento
	Self:oDados:setItemAList(IND_CHAVE_DOCUMENTOS_SAIDA, cNumDocEnt, Self:oDocsSaida[cNumDocEnt])
Return Nil

/*/{Protheus.doc} carregaDocsSaida
Carrega da memória global informações do objeto oDocsSaida

@author lucas.franca
@since 30/11/2022
@version P12
@param 01 cNumDoc, Caracter, Número do documento
@return Nil
/*/
METHOD carregaDocsSaida(cNumDoc) CLASS MrpDominio_RastreioEntradas
	Local lError := .F.

	Self:oDocsSaida[cNumDoc] := Self:oDados:getItemAList(IND_CHAVE_DOCUMENTOS_SAIDA, cNumDoc, @lError)
	If lError
		Self:oDocsSaida[cNumDoc] := Nil
	Else
		Self:trataDocSaidaTransf(cNumDoc)
	EndIf
Return

/*/{Protheus.doc} trataDocSaidaTransf
Verifica no objeto oDocsSaida se existem documentos relacionados à transferência,
e faz o de-para dos dados da necessidade com os dados de destino referentes a demanda.

@author lucas.franca
@since 11/10/2023
@version P12
@param 01 cNumDoc, Caracter, Número do documento
@return Nil
/*/
METHOD trataDocSaidaTransf(cNumDoc) CLASS MrpDominio_RastreioEntradas
	Local aTroca    := {}
	Local cIdOrigem := ""
	Local nIndex    := 0
	Local nTotal    := 0
	Local nTotAdd   := 0
	Local nIndAdd   := 0
	Local nIndAux   := 0

	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		Return
	EndIf

	nTotal := Len(Self:oDocsSaida[cNumDoc])
	For nIndex := 1 To nTotal
		/*
			Quando é um registro de transferência de produção, verifica no documento de origem
			qual é o documento correto para criar o vínculo.
		*/
		If Self:oDocsSaida[cNumDoc][nIndex][8] == "TRANF_PR" .And. Left(Self:oDocsSaida[cNumDoc][nIndex][9], 5) == "TRANF"
			Self:carregaDocsSaida(Trim(Self:oDocsSaida[cNumDoc][nIndex][9]))
			If Self:oDocsSaida[Trim(Self:oDocsSaida[cNumDoc][nIndex][9])] != Nil
				//Armazena o array aTroca os dados da origem para substituir no Self:oDocsSaida
				aAdd(aTroca, {nIndex, aClone(Self:oDocsSaida[Trim(Self:oDocsSaida[cNumDoc][nIndex][9])])})
			EndIf
		EndIf
	Next nIndex

	nTotal := Len(aTroca)

	For nIndex := nTotal To 1 Step -1
		//Percorre o array aTroca e substitui os dados que estão no array Self:oDocsSaida[cNumDoc]
		nTotAdd := Len(aTroca[nIndex][2])

		If nTotAdd > 0
			//Ajusta o tamanho do array Self:oDocsSaida[cNumDoc] para receber os novos registros
			aSize(Self:oDocsSaida[cNumDoc], Len(Self:oDocsSaida[cNumDoc]) + nTotAdd -1)

			//Armazena o ID do registro para realizar o vinculo correto entre PA->MP
			cIdOrigem := Self:oDocsSaida[cNumDoc][aTroca[nIndex][1]][12]

			//Remove de Self:oDocsSaida[cNumDoc] o registro original e adiciona os novos referente ao documento de origem da transferência
			aDel(Self:oDocsSaida[cNumDoc], aTroca[nIndex][1])

			For nIndAdd := 1 To nTotAdd
				//Insere um elemento nulo na posição correta do Self:oDocsSaida[cNumDoc] e em seguida copia o conteudo de aTroca
				nIndAux := aTroca[nIndex][1] + nIndAdd - 1
				aIns(Self:oDocsSaida[cNumDoc], nIndAux)
				Self:oDocsSaida[cNumDoc][nIndAux] := aTroca[nIndex][2][nIndAdd]
				Self:oDocsSaida[cNumDoc][nIndAux][12] := cIdOrigem
				Self:oDocsSaida[cNumDoc][nIndAux][21] := .T.
				aTroca[nIndex][2][nIndAdd] := Nil
			Next nIndAdd
		EndIf

		aTroca[nIndex][2] := Nil
		aTroca[nIndex]    := Nil
	Next nIndex

	aSize(aTroca, 0)
Return

/*/{Protheus.doc} addDocHWC
Adiciona um documento proveniente da tabela HWC para processar posteriormente.

@author lucas.franca
@since 23/11/2022
@version P12
@param 01 cFilAux   , caracter, filial do registro
@param 02 cTipDocEnt, caracter, tipo de entrada (OP, SC, PC)
@param 03 cNumDocEnt, caracter, número do documento referente à entrada
@param 04 nSequen   , numérico, sequência do documento
@param 05 dData     , data    , data do documento
@param 06 cProduto  , caracter, código do produto
@param 07 cTRT      , caracter, TRT do produto da sequência
@param 08 nBaixaEst , numérico, quantidade baixada do estoque
@param 09 nSubsti   , numérico, quantidade substituída por um alternativo
@param 10 nEmpenho  , numérico, quantidade empenhada
@param 11 nNecess   , numérico, necessidade gerada
@param 12 cTipDocSai, caracter, tipo do documento de saída
@param 13 cNumDocSai, caracter, número do documento de saída
@param 14 cIdOpc    , caracter, id do opcional
@param 15 cList     , caracter, Identificador dos dados da HWC em memória
@param 16 nPosDoc   , numero  , Índice do array de dados (ordenados) subtraído das posições de lote vencido.
@return Nil
/*/
METHOD addDocHWC(cFilAux   , cTipDocEnt, cNumDocEnt, nSequen , dData  , cProduto  ,;
                 cTRT      , nBaixaEst , nSubsti   , nEmpenho, nNecess, cTipDocSai,;
                 cNumDocSai, cIdOpc    , cList     , nPosDoc ) CLASS MrpDominio_RastreioEntradas

	Local aDados := Array(ADOCHWC_SIZE)
	Local cChave := cFilAux + RTrim(cProduto) + CHR(13) + AllTrim(cIdOpc)

	If !Self:oDocHWC:HasProperty(cChave)
		Self:oDocHWC[cChave] := {}
	EndIf

	aDados[ADOCHWC_FILIAL      ] := cFilAux
	aDados[ADOCHWC_TIPO_DOC_ENT] := cTipDocEnt
	aDados[ADOCHWC_NUM_DOC_ENT ] := cNumDocEnt
	aDados[ADOCHWC_SEQ_QUEBRA  ] := nSequen
	aDados[ADOCHWC_DATA        ] := dData
	aDados[ADOCHWC_PRODUTO     ] := cProduto
	aDados[ADOCHWC_TRT         ] := cTRT
	aDados[ADOCHWC_QTD_BAIXA   ] := nBaixaEst
	aDados[ADOCHWC_QTD_SUBS    ] := nSubsti
	aDados[ADOCHWC_QTD_EMPENHO ] := nEmpenho
	aDados[ADOCHWC_QTD_NECESS  ] := nNecess
	aDados[ADOCHWC_TIPO_DOC_SAI] := cTipDocSai
	aDados[ADOCHWC_NUM_DOC_SAI ] := cNumDocSai
	aDados[ADOCHWC_IDOPC       ] := cIdOpc
	aDados[ADOCHWC_LIST_HWC    ] := cList
	aDados[ADOCHWC_POS_HWC     ] := nPosDoc

	aAdd(Self:oDocHWC[cChave], aDados)
Return Nil

/*/{Protheus.doc} efetivaDocHWC
Salva na variável global os dados mantidos em cache local referente aos documentos da HWC (para a rastreabilidade)

@author marcelo.neumann
@since 29/05/2023
@version P12
@return Nil
/*/
METHOD efetivaDocHWC() CLASS MrpDominio_RastreioEntradas
	Local aNames := Self:oDocHWC:GetNames()
	Local nIndex := 0
	Local nTotal := Len(aNames)

	If !Empty(aNames)
		For nIndex := 1 To nTotal
			Self:oDados:setItemAList(IND_CHAVE_DADOS_HWC, aNames[nIndex], Self:oDocHWC[aNames[nIndex]], .F., .F., .T., 2)
		Next nIndex
	EndIf

	FreeObj(Self:oDocHWC)
	Self:oDocHWC:=JsonObject():New()
	aSize(aNames, 0)
Return Nil

/*/{Protheus.doc} relacionaDocTransferenciaEstoque
Relaciona documentos com as transferências de estoque (somente TRANF_ES).

@author lucas.franca
@since 28/09/2023
@version P12
@param 01 aLinhaHWC, Array, Array com os dados da HWC que estão sendo exportados.
@return Nil
/*/
METHOD relacionaDocTransferenciaEstoque(aLinhaHWC) CLASS MrpDominio_RastreioEntradas
	Local aTransf    := {}
	Local cChaveMat  := ""
	Local cChaveTran := ""
	Local lError     := .F.
	Local nTotal     := 0
	Local nIndex     := 0
	Local nQtTranEnt := aLinhaHWC[Self:nPosTrfEnt]

	If nQtTranEnt == 0
		//Não possui transferência de entrada, já encerra o processo.
		Return
	EndIf

	If Left(aLinhaHWC[Self:nPosDocFilho], 5) == "TRANF"
		//Se este registro gerou uma transferência de produção, verifica qual é a quantidade
		//de TRANF_PR gerada para relacionar somente a transferência de estoque (TRANF_ES)
		nQtTranEnt -= Self:oDominio:oMultiEmp:retornaDadosTransferenciaDocumento(aLinhaHWC[Self:nPosDocFilho])
	EndIf

	If nQtTranEnt > 0
		//Se ainda existe transferência de entrada após subtrair as transferências de produção, busca pelas quantidades de
		//transferência de estoque.
		cChaveMat := DtoS(Self:oDominio:oPeriodos:retornaDataPeriodo(aLinhaHWC[Self:nPosFilial], aLinhaHWC[Self:nPosPeriodo]))
		cChaveMat += aLinhaHWC[Self:nPosFilial] + aLinhaHWC[Self:nPosProduto] + Iif(!Empty(aLinhaHWC[Self:nPosIdOpc]),"|"+aLinhaHWC[Self:nPosIdOpc],"")

		aTransf := Self:oDominio:oMultiEmp:retornaTransferenciaEstoque(cChaveMat)
		nTotal  := Len(aTransf)
		nIndex  := 1
		While nQtTranEnt > 0 .And. nIndex <= nTotal
			//Controle para não considerar o saldo de transferência mais de uma vez.
			cChaveTran := "RASTREABILIDADE_ESTOQUE_" + aTransf[nIndex][2] + cChaveMat
			lError     := .F.
			nUsado     := Self:oDados:getFlag(cChaveTran, @lError, .F.)
			If lError
				nUsado := 0
			EndIf
			aTransf[nIndex][1] -= nUsado

			//Se o saldo desta transferência ainda não foi considerado para a rastreabilidade,
			//cria o vínculo dos documentos.
			If aTransf[nIndex][1] > 0
				nUsado := Min(aTransf[nIndex][1], nQtTranEnt)
				//Armazena flag de controle para não considerar mais o saldo desta transferência
				Self:oDados:setFlag(cChaveTran, nUsado, @lError, .F., .T., .F.)
				//Abate a qtd desta transferência do total
				nQtTranEnt -= nUsado

				Self:oDados:setItemAList(IND_CHAVE_USO_TRANF_ES, cChaveMat, {nUsado, aLinhaHWC[Self:nPosDocPai], aLinhaHWC[Self:nPosFilial], aLinhaHWC[Self:nPosTipoPai]}, .F., .F., .T., 1)
			EndIf
			nIndex++
		End
		aSize(aTransf, 0)
	EndIf

Return

/*/{Protheus.doc} procDocHWC
Processa os documentos da tabela HWC que foram salvos pelo método addDocHWC

@author lucas.franca
@since 23/11/2022
@version P12
@return Nil
/*/
METHOD procDocHWC() CLASS MrpDominio_RastreioEntradas
	Local oPCPError := Nil

	If Self:oDominio:oParametros["nThreads"] <= 1
		MrpRasPrc(Self:oDominio:oParametros["ticket"])
	Else
		oPCPError := PCPMultiThreadError():New(PCPMTERUID())

		oPCPError:startJob("MrpRasPrc", GetEnvServer(), .F., Nil, Nil, Self:oDominio:oParametros["ticket"], /*oVar02*/, /*oVar03*/, /*oVar04*/, /*oVar05*/, /*oVar06*/, /*oVar07*/, /*oVar08*/, /*oVar09*/, /*oVar10*/, /*bRecover*/, /*cRecover*/, .T.)
	EndIf
Return

/*/{Protheus.doc} buscaRevisao
Busca a revisão do produto

@type  Static Function
@author lucas.franca
@since 17/03/2021
@version P12
@param cFilAux   , Character, Filial em processamento
@param cProduto  , Character, Código do produto
@param nPeriodo  , Numeric  , Número do período
@param cDocOri   , Character, Documento origem
@param aRastreio , Array    , Array com os dados do rastreio
@param oRastroEnt, Object   , Objeto de referência da classe de RastreioEntradas
@return cRevisao, Character, Revisão do produto a ser considerada
/*/
Static Function buscaRevisao(cFilAux, cProduto, nPeriodo, cDocOri, aRastreio, oRastroEnt)
	Local aBaixaPorOP := {}
	Local aRevisoes   := {}
	Local cFilCalc    := oRastroEnt:converteFilialMultiEmpresa(cFilAux)
	Local cRevisao    := oRastroEnt:oDominio:revisaoProduto(cFilCalc + cProduto)

	aAdd(aBaixaPorOP, oRastroEnt:oDominio:oRastreio:montaBaixaPorOP(cDocOri                            ,;
	                                                                aRastreio[oRastroEnt:nPosDocPai ]  ,;
	                                                                aRastreio[oRastroEnt:nPosNecess ]  ,;
	                                                                aRastreio[oRastroEnt:nPosEst    ]  ,;
	                                                                aRastreio[oRastroEnt:nPosConEst ]  ,;
	                                                                0                                  ,;
	                                                                aRastreio[oRastroEnt:nPosQuebras]  ,;
	                                                                aRastreio[oRastroEnt:nPosTipoPai]  ,;
	                                                                aRastreio[oRastroEnt:nPosNecOri ]  ,;
	                                                                ""                                 ,;
	                                                                ""                                 ,;
	                                                                aRastreio[oRastroEnt:nPosTrfEnt  ] ,;
	                                                                aRastreio[oRastroEnt:nPosTrfSai  ] ,;
	                                                                aRastreio[oRastroEnt:nPosDocFilho] ,;
	                                                                aRastreio[oRastroEnt:nPosRastreio] ))

	aRevisoes := oRastroEnt:oDominio:agrupaRevisoes(cFilCalc, cFilCalc + cProduto, nPeriodo, @aBaixaPorOP)
	If Len(aRevisoes) > 0
		cRevisao := aRevisoes[1][1]
	EndIf
	aSize(aRevisoes  , 0)
	aSize(aBaixaPorOP, 0)
Return cRevisao

/*/{Protheus.doc} GetTipoEnt
Retorna o Tipo de Documento a ser gravado na SME
@author marcelo.neumann
@since 30/11/2020
@version 1
@param  cTipo     , caracter, tipo do documento de entrada (OP, SC, PC, SI)
                              P = A entrada é um Ponto de Pedido
                              E = A entrada é um estoque de segurança
                              0 = A entrada é um Saldo Inicial
                              1 = A entrada é uma OP
                              2 = A entrada é uma SC
                              3 = A entrada é um PC
@return cTipDocEnt, caracter, tipo da entrada (1, 2, 3, 4)
/*/
Static Function GetTipoEnt(cTipo)
	Local cTipDocEnt := ""

	If cTipo == "SI"
		cTipDocEnt := "0"

	ElseIf cTipo == "OP"
		cTipDocEnt := "1"

	ElseIf cTipo == "SC"
		cTipDocEnt := "2"

	ElseIf cTipo == "PC"
		cTipDocEnt := "3"

	ElseIf cTipo == "Pré-OP"
		cTipDocEnt := "R"
    
	ElseIf cTipo == scTextPPed
		cTipDocEnt := "P"
	
	ElseIf cTipo == scTextESeg
		cTipDocEnt := "E"

	Else
		cTipDocEnt := cTipo
	EndIf
Return cTipDocEnt

/*/{Protheus.doc} MrpRasPrc
Função para delegar o processamento dos dados de rastreabilidade da HWC.

@type  Function
@author lucas.franca
@since 24/11/2022
@version P12
@param cTicket, Caracter, Número do ticket do MRP
@return Nil
/*/
Function MrpRasPrc(cTicket)
	Local aDados     := {}
	Local lError     := .F.
	Local nTotal     := 0
	Local nIndex     := 0
	Local nDelegados := 0
	Local oDados     := Nil
	Local oRastroEnt := Nil
	Local oStatus    := Nil
	Local oSaida     := MrpDominio_Saida():New()

	PrepStatics(cTicket)

	oDados     := _oDominio:oDados:oRastreioEntradas
	oRastroEnt := _oDominio:oRastreioEntradas
	oStatus    := _oDominio:oStatus

	oStatus:preparaAmbiente(_oDominio:oDados)

	//Aguarda o término das exportações para iniciar o processamento
	oSaida:aguardaRastreio(_oDominio)
	oSaida:aguardaAglutinacao(_oDominio)

	oStatus:setStatus("rastreiaEntradasStatus", "2") //Executando

	//Recupera os dados da memória
	oDados:getAllAList(IND_CHAVE_DADOS_HWC, @aDados, @lError)
	If !lError
		nTotal := Len(aDados)
		oDados:setFlag("ADD_DOCUMENTO_FINALIZADO", 0)

		nIndex := 0
		While nIndex < nTotal .And. oStatus:getStatus("status") <> "4" //Percorre os registros e valida se o processo foi cancelado
			nIndex++

			//Delega o registro para ser processado em oura thread.
			If _oDominio:oParametros["nThreads"] <= 1
				MrpRasAdd(cTicket, aDados[nIndex][2])
			Else
				PCPIPCGO(_oDominio:oParametros["cSemaforoThreads"], .F., "MrpRasAdd", cTicket, aDados[nIndex][2])
			EndIf
			//Limpa array com os dados já delegados.
			aSize(aDados[nIndex][2], 0)
			aSize(aDados[nIndex]   , 0)

			oRastroEnt:atualizaPercentual(_oDominio, nTotal, 0, 0)

			nDelegados++
		End

		//Aguarda as threads finalizarem
		While oStatus:getStatus("status") != "4" .And. oDados:getFlag("ADD_DOCUMENTO_FINALIZADO") < nDelegados
			oRastroEnt:atualizaPercentual(_oDominio, nTotal, 0, 0)
			Sleep(500)
		End

		//Inicia o processo de gravação da SME
		If oStatus:getStatus("status") != "4"
			oSaida:exportarEntradas(_oDominio, nTotal)
		EndIf
	EndIf

	oStatus:setStatus("rastreiaEntradasStatus", "3") //Concluído

	aSize(aDados, 0)
Return Nil

/*/{Protheus.doc} atualizaPercentual
Método para atualizar o percentual de progresso do processo de rastreabilidade

@type  METHOD
@author lucas.franca
@since 28/11/2022
@version P12
@param 01 oStatus , Object , Objeto de status do MRP
@param 02 nTotProc, Numeric, Total de registros para processamento
@param 03 nTotGrav, Numeric, Total de registros para gravação
@param 04 nIndGrav, Numeric, Índice de gravação dos dados
@return Nil
/*/
METHOD atualizaPercentual(oDominio, nTotProc, nTotGrav, nIndGrav) CLASS MrpDominio_RastreioEntradas
	Local nPercent := 0
	Local nInd     := 0

	If nIndGrav > 0
		//Se está no processo de gravação, não precisa calcular o percentual do processamento pois já foi finalizado.
		nPercent := 50
	Else
		//Percentual do processamento dos dados, limitado à 50% do total
		nInd := oDominio:oDados:oRastreioEntradas:getFlag("ADD_DOCUMENTO_FINALIZADO")
		If nInd > 0
			nPercent += Round( (nInd / nTotProc) * 50 , 2)
		EndIf
	EndIf

	//Percentual da gravação dos dados, limitado à 50% do total.
	If nIndGrav > 0
		nPercent += Round( (nIndGrav / nTotGrav) * 50 , 2)
	EndIf
	oDominio:oStatus:setStatus("rastreiaEntradasPercentage", nPercent)
Return Nil

/*/{Protheus.doc} MrpRasAdd
Função para realizar o processamento dos dados de rastreabilidade da HWC.

@type  Function
@author lucas.franca
@since 25/11/2022
@version P12
@param 01 cTicket, Caracter, Número do ticket do MRP
@param 02 aDados , Array   , Array com os dados para processamento. Array é criado no método addDocHWC
@return Nil
/*/
Function MrpRasAdd(cTicket, aDados)
	Local aDataHWC   := {}
	Local cListAnt   := ""
	Local nPosHWC    := 0
	Local nIndex     := 0
	Local nTotal     := Len(aDados)
	Local oRastroEnt := Nil
	Local oDados     := Nil

	PrepStatics(cTicket)

	oRastroEnt := _oDominio:oRastreioEntradas
	oDados     := _oDominio:oDados:oRastreioEntradas

	//Ordena os dados por período.
	aDados := aSort(aDados,,, {|x,y| DtoS(x[ADOCHWC_DATA]) + "_" + StrZero(x[ADOCHWC_POS_HWC], 10) + StrZero(x[ADOCHWC_SEQ_QUEBRA], 10) <;
	                                 DtoS(y[ADOCHWC_DATA]) + "_" + StrZero(y[ADOCHWC_POS_HWC], 10) + StrZero(y[ADOCHWC_SEQ_QUEBRA], 10)})

	//Percorre os dados da HWC para realizar o processamento do addDocumento.
	For nIndex := 1 To nTotal

		If cListAnt != aDados[nIndex][ADOCHWC_LIST_HWC]
			//Recupera os dados de memória da HWC para utilizar no processo
			FwFreeArray(aDataHWC)
			_oDominio:oRastreio:oDados_Rastreio:oDados:getAllAList(aDados[nIndex][ADOCHWC_LIST_HWC], @aDataHWC)
			aDataHWC := _oDominio:oRastreio:ordenaRastreio(aDataHWC, .F.)
			cListAnt := aDados[nIndex][ADOCHWC_LIST_HWC]
		EndIf
		nPosHWC := aDados[nIndex][ADOCHWC_POS_HWC]

		oRastroEnt:addDocumento(aDados[nIndex][ADOCHWC_FILIAL      ],; //Filial
		                        aDados[nIndex][ADOCHWC_TIPO_DOC_ENT],; //Tipo Documento Entrada
		                        aDados[nIndex][ADOCHWC_NUM_DOC_ENT ],; //Número Documento Entrada
		                        aDados[nIndex][ADOCHWC_SEQ_QUEBRA  ],; //Sequência
		                        aDados[nIndex][ADOCHWC_DATA        ],; //Data
		                        aDados[nIndex][ADOCHWC_PRODUTO     ],; //Produto
		                        aDados[nIndex][ADOCHWC_TRT         ],; //TRT
		                        aDados[nIndex][ADOCHWC_QTD_BAIXA   ],; //Baixa Estoque
		                        aDados[nIndex][ADOCHWC_QTD_SUBS    ],; //Substituição
		                        aDados[nIndex][ADOCHWC_QTD_EMPENHO ],; //Empenho
		                        aDados[nIndex][ADOCHWC_QTD_NECESS  ],; //Necessidade
		                        aDados[nIndex][ADOCHWC_TIPO_DOC_SAI],; //Tipo Documento Saída
		                        aDados[nIndex][ADOCHWC_NUM_DOC_SAI ],; //Número Documento Saída
		                        aDataHWC[nPosHWC][2]                ,; //Dados da rastreabilidade
		                        aDados[nIndex][ADOCHWC_IDOPC       ])  //ID Opcional

	Next nIndex

	oRastroEnt:efetivaInclusao()

	//Incrementa contador de delegações finalizadas
	oDados:setFlag("ADD_DOCUMENTO_FINALIZADO", 1,,,,.T.)

	aSize(aDados, 0)
	FwFreeArray(aDataHWC)
Return Nil

/*/{Protheus.doc} PrepStatics
Alimenta as variáveis Static do fonte caso ainda não tenham sido alimentadas (_oDominio)

@type  Static Function
@author lucas.franca
@since 01/12/2022
@version P12
@param 01 cTicket, Caracter, Número do ticket do MRP
@return Nil
/*/
Static Function PrepStatics(cTicket)

	If _oDominio == Nil
		_oDominio := MRPPrepDom(cTicket)
	EndIf

Return

/*/{Protheus.doc} montaRetorno
Monta o array de retorno para exportação dos dados.
@author Lucas Fagundes
@since 21/12/2022
@version P12
@param 01 cFilAux   , Caracter, Código da Filial
@param 02 cTipDocEnt, Caracter, Tipo Documento Entrada
@param 03 cNumDocEnt, Caracter, Número Documento Entrada
@param 04 dData     , Date    , Data
@param 05 cProduto  , Caracter, Código do Produto
@param 06 nBaixaEst , Numerico, Quantidade
@param 07 cTipo     , Caracter, Tipo
@param 08 cTipDocSai, Caracter, Tipo Documento Saída
@param 09 cNumDocSai, Caracter, Número Documento Saída
@param 10 cTRT      , Caracter, TRT
@param 11 cIdPai    , Caracter, ID Registro pai
@param 12 cIdReg    , Caracter, IDREG do registro
@param 13 cDocPai   , Caracter, DOCPAI da HWC
@param 14 cIdOpc    , Caracter, Id Opcional
@param 15 cLote     , Caracter, Código do Lote
@param 16 cSubLote  , Caracter, Código do Sub-lote
@param 17 lNovoSaldo, Caracter, Indica utilização de novo saldo
@param 18 nNecess   , Numerico, Necessidade gerada
@param 19 nSequenc  , Numerico, Sequencia da HWC
@param 20 cFilDest  , Caracter, Filial de destino
@return aRetorno, Array, Array com as informações para exportação dos dados.
/*/
METHOD montaRetorno(cFilAux, cTipDocEnt, cNumDocEnt, dData, cProduto, nBaixaEst, cTipo, cTipDocSai, cNumDocSai,;
                    cTRT, cIdPai, cIdReg, cDocPai, cIdOpc, cLote, cSubLote, lNovoSaldo, nNecess, nSequenc, cFilDest) CLASS MrpDominio_RastreioEntradas
	Local aRetorno := Array(21)

	Default cFilDest   := ""
	Default lNovoSaldo := .F.
	Default nNecess    := 0
	Default nSequenc   := 0

	aRetorno[01] := cFilAux    //01 Filial
	aRetorno[02] := cTipDocEnt //02 Tipo Documento Entrada
	aRetorno[03] := cNumDocEnt //03 Número Documento Entrada
	aRetorno[04] := dData      //04 Data
	aRetorno[05] := cProduto   //05 Produto
	aRetorno[06] := nBaixaEst  //06 Quantidade
	aRetorno[07] := cTipo      //07 Tipo
	aRetorno[08] := cTipDocSai //08 Tipo Documento Saída
	aRetorno[09] := cNumDocSai //09 Código Documento Saída
	aRetorno[10] := cTRT       //10 TRT
	aRetorno[11] := cIdPai     //11 ID Registro pai
	aRetorno[12] := cIdReg     //12 IDREG do registro
	aRetorno[13] := cDocPai    //13 DOCPAI da HWC
	aRetorno[14] := cIdOpc     //14 Id Opcional
	aRetorno[15] := cLote      //15 Lote
	aRetorno[16] := cSubLote   //16 Sub-lote
	aRetorno[17] := lNovoSaldo //17 Novo Saldo
	aRetorno[18] := nNecess    //18 Necessidade
	aRetorno[19] := nSequenc   //19 Sequencia HWC
	aRetorno[20] := cFilDest   //20 Filial de destino (transferências) - Somente grava no processo de aglutinação. Demais processos grava em branco, e registra junto com o IDREG ao fazer o retorno.
	aRetorno[21] := .F.        //21 Identifica se é um registro de transferência, substituído pela origem no método trataDocSaidaTransf

Return aRetorno

/*/{Protheus.doc} criaIdReg
Cria o idreg do registro para a tabela SME.
@author Lucas Fagundes
@since 02/03/2023
@version P12
@param 01 cDocEnt   , Caracter, Documento de entrada da saida que irá criar o idreg.
@param 02 lConcatPai, Logico  , Indica que deve concatenar o idreg do documento recebido em cDocEnt.
@return cIdReg, Caracter, Idreg para o registro na SME.
/*/
METHOD criaIdReg(cDocEnt, lConcatPai) CLASS MrpDominio_RastreioEntradas
	Local cIdReg := ""
	Local nInc   := 1
	Local cIdRegPai := ""
	Local cChave := "IDREG_SME_DOC_" + cDocEnt

	Self:oDados:setFlag("IDREG_SME", @nInc,,,, .T.)
	cIdReg := cValToChar(nInc)

	cIdRegPai := Self:oDados:getFlag(cChave)
	If Empty(cIdRegPai)
		Self:oDados:setFlag(cChave, cIdReg)
	EndIf

	If lConcatPai .And. !Empty(cIdRegPai)
		cIdReg := cIdReg + "|" + cIdRegPai + "|"
	EndIf

Return cIdReg

/*/{Protheus.doc} converteFilialMultiEmpresa
Para os dados em memória referentes ao cálculo do MRP, o código da filial é em branco caso não use multi-empresas.
Na rastreabilidade, cFilAux sempre é preenchido.
Este método retorna o código de filial que deve ser utilizado para os dados de memória do cálculo do MRP

@author lucas.franca
@since 14/09/2023
@version P12
@param 01 cFilAux, Caracter, Código da filial em processamento na rastreabilidade
@return cFilAux, Caracter, Filial para busca dos dados na memória do MRP
/*/
METHOD converteFilialMultiEmpresa(cFilAux) CLASS MrpDominio_RastreioEntradas
	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() == .F.
		cFilAux := ""
	EndIf
Return cFilAux

/*/{Protheus.doc} trataNecessidadeTransferencia
Verifica se deve ser somada a quantidade de transferência de entrada junto da necessidade.

@author lucas.franca
@since 09/10/2023
@version P12
@param 01 nNecess   , Numeric , Quantidade original da necessidade
@param 02 cTipDocSai, Caracter, Tipo de documento de saída
@param 03 cNumDocEnt, Caracter, Número do documento de entrada
@param 04 aLinha    , Array   , Array com os dados da tabela HWC em processamento
@return nNecess, Numeric, Necessidade atualizada
/*/
METHOD trataNecessidadeTransferencia(nNecess, cTipDocSai, cNumDocEnt, aLinha) CLASS MrpDominio_RastreioEntradas
	If Self:oDominio:oMultiEmp:utilizaMultiEmpresa() .And.;
	   Left(cTipDocSai, 5) != "TRANF"                .And. ;
	   Left(cNumDocEnt, 5) == "TRANF" .And. aLinha[Self:nPosTrfEnt] > 0
		nNecess += aLinha[Self:nPosTrfEnt]
	EndIf
Return nNecess
