#Include "loca001al.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} LOCA001AL
Alertas de Contrato e Faturamento, por item da FPA, de um unico contrato.
Agrupa os alertas por situacao (Vencimento de Contrato, Vencimento de
Aniversario, Pendencia de Faturamento) e, ao clicar em uma situacao,
exibe abaixo os itens da FPA que a geraram - reaproveita a tela padrao
de eventos/resultados ja existente em LOCA229G.PRW (funcao Loca229G()),
ao inves de recriar uma tela de grid do zero.
Chamada manual: sempre abre a tela (mesmo sem alertas, exibe aviso) -
botao nas Acoes Relacionadas de Visualizar/Alterar/Manutencao, sempre
habilitado.
Chamada automatica (lAuto=.T., disparada via MV_LOCX317 ao entrar em
Visualizar/Alterar/Manutencao do contrato): so abre a tela quando
existir ao menos um alerta.
DSERLOCA-12391
@type function
@version 25.10
@author Dennis Calabrez
@since 25/08/2026
@param cProjeto, character, Codigo do contrato/projeto (FP0_PROJET) a verificar
@param lAuto, logical, .T. quando disparado automaticamente (MV_LOCX317)
/*/
Function LOCA001AL(cProjeto, lAuto) // DSERLOCA-12391
Local aAlertas := {} // DSERLOCA-12391
Local aEventos := {} // DSERLOCA-12391
Local aTipos   := { STR0003, STR0002, STR0001 } // DSERLOCA-12391
Local aItens   := {} // DSERLOCA-12391
Local cCliente := "" // DSERLOCA-12391
Local cTitulo  := "" // DSERLOCA-12391
Local nT       := 0 // DSERLOCA-12391
Local nI       := 0 // DSERLOCA-12391

Default lAuto := .F. // DSERLOCA-12391

	aAlertas := LOCA001L2(cProjeto) // DSERLOCA-12391

	If lAuto .And. Len(aAlertas) == 0 // DSERLOCA-12391 - modo automatico so interrompe o usuario quando ha algo a alertar
		Return .T.
	EndIf

	If Len(aAlertas) > 0 // DSERLOCA-12391
		cCliente := aAlertas[1][2] // DSERLOCA-12391
	EndIf

	// Agrupa os itens de FPA por situacao/tipo de alerta // DSERLOCA-12391
	For nT := 1 To Len(aTipos) // DSERLOCA-12391
		aItens := {} // DSERLOCA-12391
		For nI := 1 To Len(aAlertas) // DSERLOCA-12391
			If aAlertas[nI][9] == aTipos[nT] // DSERLOCA-12391 - [9] = tipo de alerta (ver LOCA001L2)
				Aadd(aItens, { .F., LOCA001L1(aTipos[nT], aAlertas[nI]) }) // DSERLOCA-12391
			EndIf
		Next nI
		If Len(aItens) > 0 // DSERLOCA-12391 - so inclui a situacao quando houver ao menos um item
			Aadd(aEventos, { .F., aTipos[nT], aItens }) // DSERLOCA-12391
		EndIf
	Next nT

	If Len(aEventos) == 0 // DSERLOCA-12391
		If !lAuto // DSERLOCA-12391
			MsgAlert(STR0004, STR0005) // DSERLOCA-12391
		EndIf
		Return .T.
	EndIf

	cTitulo := STR0006 + AllTrim(cProjeto) // DSERLOCA-12391
	If !Empty(cCliente) // DSERLOCA-12391
		cTitulo += " - " + cCliente // DSERLOCA-12391
	EndIf

	// Reaproveita a tela padrao de eventos/resultados (cabecalho + item), ja usada em LOCA229G.PRW // DSERLOCA-12391
	Loca229G(cTitulo, aEventos) // DSERLOCA-12391

Return .T.

/*/{Protheus.doc} LOCA001L1    
Monta a descricao do item de FPA exibido no detalhe de uma situacao de
alerta (Obra + a data relevante para aquele tipo de alerta).
DSERLOCA-12391
@type function
@author Dennis Calabrez
@since 25/08/2026
@param cTipo, character, Tipo de alerta (mesmo texto usado no agrupamento)
@param aItem, array, Linha retornada por LOCA001L2
@return character, Descricao do item de FPA
/*/
Static Function LOCA001L1(cTipo, aItem) // DSERLOCA-12391
Local cDesc := "" // DSERLOCA-12391

	// Identificacao do item de FPA (Sequencia + Bem/Produto), para o usuario localizar qual item esta com o problema // DSERLOCA-12391
	cDesc := STR0007 + aItem[13] // DSERLOCA-12391 - FPA_SEQGRU
	cDesc += " - Produto " + aItem[10] // DSERLOCA-12391
	If !Empty(aItem[12]) // DSERLOCA-12391 - descricao do produto/bem (FPA_DESGRU)
		cDesc += " - " + aItem[12] // DSERLOCA-12391
	EndIf
	If !Empty(aItem[11]) // DSERLOCA-12391 - codigo do bem especifico (FPA_GRUA), nem todo item tem
		cDesc += STR0008 + aItem[11] + ")" // DSERLOCA-12391
	EndIf

	cDesc += STR0009 + aItem[4] // DSERLOCA-12391

	Do Case // DSERLOCA-12391
	Case cTipo == "Vencimento de Contrato" // DSERLOCA-12391
		cDesc += STR0010 + aItem[6] // DSERLOCA-12391
	Case cTipo == "Vencimento de Aniversario" // DSERLOCA-12391
		cDesc += STR0011 + aItem[7] // DSERLOCA-12391
	Case cTipo == "Pendencia de Faturamento" // DSERLOCA-12391
		cDesc += STR0012 + aItem[8] // DSERLOCA-12391
	EndCase // DSERLOCA-12391

Return cDesc

/*/{Protheus.doc} LOCA001L2
Consulta, por item da FPA, os alertas do contrato informado:
- Vencimento de Contrato    : FPA_DTENRE <= hoje + 30 dias
- Vencimento de Aniversario : FPA_NIVER  <= hoje + 30 dias
- Pendencia de Faturamento  : FPA_GERAEM < hoje, ou se em branco, FPA_DTFIM < hoje
Join reaproveitado de Fact\BAXContRental.PRW (FP0 -> FP1 -> FPA -> SA1)
DSERLOCA-12391
@type function
@version 25.10
@author Dennis Calabrez
@since 25/08/2026
@param cProjeto, character, Codigo do contrato/projeto (FP0_PROJET) a verificar
@return array, Um item por alerta identificado (item da FPA); cada linha:
        { STATUS, CLIENTE, CONTRATO, OBRA, DTINICIO, DTFIM, DTANIVER, DTPROXFAT, TIPOALERTA, PRODUTO, BEM, DESCBEM, SEQGRU }
/*/
Static Function LOCA001L2(cProjeto) // DSERLOCA-12391
Local cQuery      := "" // DSERLOCA-12391
Local aBindParam  := {} // DSERLOCA-12391
Local aRet        := {} // DSERLOCA-12391
Local cSqlHoje    := "" // DSERLOCA-12391 - "hoje", compativel Oracle e MSSQL
Local cSqlH30  := "" // DSERLOCA-12391 - "hoje + 30 dias", compativel Oracle e MSSQL
Local cLinha := ""
Local cComando := ""
	LOCACLOSE("TRBALERT")

	// Mesmo padrao de deteccao de banco ja usado em LOCA013A.PRW (TCGetDB()) // DSERLOCA-12391
	If Upper(TCGetDB()) $ "ORACLE" .Or. file("\SYSTEM\LOCA001AL.TXT")// DSERLOCA-12391
		cSqlHoje   := "SYSDATE" // DSERLOCA-12391
		cSqlH30 := "(SYSDATE + 30)" // DSERLOCA-12391
	Else // DSERLOCA-12391 - MSSQL
		cSqlHoje   := "GETDATE()" // DSERLOCA-12391
		cSqlH30 := "DATEADD(day,30,GETDATE())" // DSERLOCA-12391
	EndIf

	// Alerta 1: Vencimento de Contrato // DSERLOCA-12391
	cQuery := " SELECT FP0.FP0_PROJET AS CPROJET, FP1.FP1_OBRA AS COBRA, SA1.A1_NOME AS CCLIENTE, " // DSERLOCA-12391
	cQuery += "        FPA.FPA_DTINI AS DDTINI, FPA.FPA_DTENRE AS DDTFIM, FPA.FPA_NIVER AS DDTANIV, FPA.FPA_DTFIM AS DDTPFAT, " // DSERLOCA-12391
	cQuery += "        'Vencimento de Contrato' AS CTIPO, " // DSERLOCA-12391
	cQuery += "        FPA.FPA_PRODUT AS CPRODUT, FPA.FPA_GRUA AS CBEM, FPA.FPA_DESGRU AS CDESBEM, FPA.FPA_SEQGRU AS CSEQGRU " // DSERLOCA-12391 - Bem/Produto e Sequencia do item
	cQuery += "   FROM " + RetSqlName("FP0") + " FP0 " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FP1") + " FP1 ON FP1.FP1_FILIAL = FP0.FP0_FILIAL AND FP1.FP1_PROJET = FP0.FP0_PROJET AND FP1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FPA") + " FPA ON FPA.FPA_FILIAL = FP1.FP1_FILIAL AND FPA.FPA_PROJET = FP1.FP1_PROJET AND FPA.FPA_OBRA = FP1.FP1_OBRA AND FPA.FPA_TIPOSE <> 'S' AND FPA.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = FP0.FP0_CLI AND SA1.A1_LOJA = FP0.FP0_LOJA AND SA1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "  WHERE FP0.FP0_FILIAL = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_PROJET = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_STATUS NOT IN ('A','B') " // DSERLOCA-12391
	cQuery += "    AND FP0.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "    AND FPA.FPA_TIPOSE <> 'Z' " // DSERLOCA-12391
	cQuery += "    AND FPA.FPA_DTENRE <> ' ' " // DSERLOCA-12391 - data em branco nao e divergencia
	cLinha := "    AND FPA.FPA_DTENRE <= " + cSqlH30 + " " // DSERLOCA-12391
	cComando := 'cQuery += cLinha '
	&(cComando)
	cQuery += " UNION ALL " // DSERLOCA-12391
	// Alerta 2: Vencimento de Aniversario // DSERLOCA-12391
	cQuery += " SELECT FP0.FP0_PROJET, FP1.FP1_OBRA, SA1.A1_NOME, " // DSERLOCA-12391
	cQuery += "        FPA.FPA_DTINI, FPA.FPA_DTENRE, FPA.FPA_NIVER, FPA.FPA_DTFIM, " // DSERLOCA-12391
	cQuery += "        'Vencimento de Aniversario', " // DSERLOCA-12391
	cQuery += "        FPA.FPA_PRODUT, FPA.FPA_GRUA, FPA.FPA_DESGRU, FPA.FPA_SEQGRU " // DSERLOCA-12391 - Bem/Produto e Sequencia do item
	cQuery += "   FROM " + RetSqlName("FP0") + " FP0 " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FP1") + " FP1 ON FP1.FP1_FILIAL = FP0.FP0_FILIAL AND FP1.FP1_PROJET = FP0.FP0_PROJET AND FP1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FPA") + " FPA ON FPA.FPA_FILIAL = FP1.FP1_FILIAL AND FPA.FPA_PROJET = FP1.FP1_PROJET AND FPA.FPA_OBRA = FP1.FP1_OBRA AND FPA.FPA_TIPOSE <> 'S' AND FPA.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = FP0.FP0_CLI AND SA1.A1_LOJA = FP0.FP0_LOJA AND SA1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "  WHERE FP0.FP0_FILIAL = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_PROJET = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_STATUS NOT IN ('A','B') " // DSERLOCA-12391
	cQuery += "    AND FP0.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "    AND FPA.FPA_TIPOSE <> 'Z' " // DSERLOCA-12391
	cQuery += "    AND FPA.FPA_NIVER <> ' ' " // DSERLOCA-12391 - data em branco nao e divergencia
	cLinha := "    AND FPA.FPA_NIVER <= " + cSqlH30 + " " // DSERLOCA-12391
	cComando := 'cQuery += cLinha '
	&(cComando)
	cQuery += " UNION ALL " // DSERLOCA-12391
	// Alerta 3: Pendencia de Faturamento // DSERLOCA-12391
	cQuery += " SELECT FP0.FP0_PROJET, FP1.FP1_OBRA, SA1.A1_NOME, " // DSERLOCA-12391
	cQuery += "        FPA.FPA_DTINI, FPA.FPA_DTENRE, FPA.FPA_NIVER, FPA.FPA_DTFIM, " // DSERLOCA-12391
	cQuery += "        'Pendencia de Faturamento', " // DSERLOCA-12391
	cQuery += "        FPA.FPA_PRODUT, FPA.FPA_GRUA, FPA.FPA_DESGRU, FPA.FPA_SEQGRU " // DSERLOCA-12391 - Bem/Produto e Sequencia do item
	cQuery += "   FROM " + RetSqlName("FP0") + " FP0 " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FP1") + " FP1 ON FP1.FP1_FILIAL = FP0.FP0_FILIAL AND FP1.FP1_PROJET = FP0.FP0_PROJET AND FP1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("FPA") + " FPA ON FPA.FPA_FILIAL = FP1.FP1_FILIAL AND FPA.FPA_PROJET = FP1.FP1_PROJET AND FPA.FPA_OBRA = FP1.FP1_OBRA AND FPA.FPA_TIPOSE <> 'S' AND FPA.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = FP0.FP0_CLI AND SA1.A1_LOJA = FP0.FP0_LOJA AND SA1.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "  WHERE FP0.FP0_FILIAL = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_PROJET = ? " // DSERLOCA-12391
	cQuery += "    AND FP0.FP0_STATUS NOT IN ('A','B') " // DSERLOCA-12391
	cQuery += "    AND FP0.D_E_L_E_T_ = ' ' " // DSERLOCA-12391
	cQuery += "    AND FPA.FPA_TIPOSE <> 'Z' " // DSERLOCA-12391
	cLinha := "    AND ( (FPA.FPA_GERAEM <> ' ' AND FPA.FPA_GERAEM < " + cSqlHoje + ") " // DSERLOCA-12391 - data em branco nao e divergencia
	cComando := 'cQuery += cLinha '
	&(cComando)
	cLinha := "          OR (FPA.FPA_GERAEM = ' ' AND FPA.FPA_DTFIM <> ' ' AND FPA.FPA_DTFIM < " + cSqlHoje + ") ) " // DSERLOCA-12391 - idem para o fallback
	cComando := 'cQuery += cLinha '
	&(cComando)
	cQuery += " ORDER BY 8, 1 " // DSERLOCA-12391

	cQuery := ChangeQuery(cQuery) // DSERLOCA-12391
	aBindParam := { XFilial("FP0"), cProjeto, ; // DSERLOCA-12391
					XFilial("FP0"), cProjeto, ; // DSERLOCA-12391
					XFilial("FP0"), cProjeto } // DSERLOCA-12391
	MPSysOpenQuery(cQuery,"TRBALERT",,,aBindParam) // DSERLOCA-12391

	While TRBALERT->(!Eof()) // DSERLOCA-12391
		Aadd(aRet, { "SPS_ERROR_S", ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CCLIENTE), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CPROJET), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->COBRA), ; // DSERLOCA-12391
			LOCA001L3(TRBALERT->DDTINI), ; // DSERLOCA-12391
			LOCA001L3(TRBALERT->DDTFIM), ; // DSERLOCA-12391
			LOCA001L3(TRBALERT->DDTANIV), ; // DSERLOCA-12391
			LOCA001L3(TRBALERT->DDTPFAT), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CTIPO), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CPRODUT), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CBEM), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CDESBEM), ; // DSERLOCA-12391
			LOCA001L4(TRBALERT->CSEQGRU) } ) // DSERLOCA-12391
		TRBALERT->(DbSkip()) // DSERLOCA-12391
	EndDo // DSERLOCA-12391

	TRBALERT->(DbCloseArea()) // DSERLOCA-12391

Return aRet

/*/{Protheus.doc} LOCA001L3
Converte para character um valor de data vindo da query, aceitando tanto
colunas fisicamente Date quanto Character (formato AAAAMMDD), pois nem
todos os campos de data da FPA sao do mesmo tipo fisico nesta base.
DSERLOCA-12391
@type function
@author Dennis Calabrez
@since 25/08/2026
@param uData, variant, Valor retornado pela query (Date, Character ou Nil)
@return character, Data formatada (dd/mm/aaaa) ou "" quando vazia
/*/
Static Function LOCA001L3(dData) // DSERLOCA-12391
Local cRet := "" // DSERLOCA-12391

	If ValType(dData) == "C" // DSERLOCA-12391
		If !Empty(AllTrim(dData)) // DSERLOCA-12391
			cRet := DtoC(SToD(AllTrim(dData))) // DSERLOCA-12391
		EndIf
	EndIf

Return cRet

/*/{Protheus.doc} LOCA001L4
Converte para character de forma segura um valor vindo da query, evitando
erro de AllTrim quando o valor retornar Nil (ex: SA1.A1_NOME em contratos
apenas com prospect, sem cliente vinculado).
DSERLOCA-12391
@type function
@author Dennis Calabrez
@since 25/08/2026
@param uValor, variant, Valor retornado pela query
@return character, Valor tratado (AllTrim) ou "" quando Nil/vazio
/*/
Static Function LOCA001L4(cValor) // DSERLOCA-12391
Local cRet := "" // DSERLOCA-12391

	If ValType(cValor) == "C" // DSERLOCA-12391
		cRet := AllTrim(cValor) // DSERLOCA-12391
	EndIf

Return cRet

/*/{Protheus.doc} LOCA001ALP
Alerta de PO (Purchase Order) expirado, por item da FPA, de um unico
contrato. Verifica, para cada item do contrato que possua PO vinculado
(FPA_IDPO), se a validade do PO (FH7_DTVAL, tabela FH7) esta menor que a
data atual e, em caso positivo, exibe uma mensagem com as linhas (itens
da FPA) que estao com o PO expirado.
Reaproveita a tela padrao de eventos/resultados ja usada em LOCA001AL
(funcao Loca229G(), de LOCA229G.PRW), para manter o mesmo padrao visual
dos demais alertas de contrato e faturamento.
Funcao nova, criada para nao interferir nas funcoes ja existentes neste
fonte (LOCA001AL, LOCA001L1 a LOCA001L4).
Chamada automatica (lAuto=.T., disparada na confirmacao do contrato, em
LOCA001.PRW, funcao VALID(), apos a gravacao do projeto/FPA): so exibe a
tela quando existir ao menos um item com PO expirado.
DSERLOCA-13414
@type function
@version 25.10
@author Dennis Calabrez
@since 28/08/2026
@param cProjeto, character, Codigo do contrato/projeto (FP0_PROJET) a verificar
@param lAuto, logical, .T. quando disparado automaticamente na confirmacao do contrato
/*/
Function LOCA001ALP(cProjeto, lAuto) // DSERLOCA-13414
Local aAlertas := {} // DSERLOCA-13414
Local aEventos := {} // DSERLOCA-13414
Local aItens   := {} // DSERLOCA-13414
Local cCliente := "" // DSERLOCA-13414
Local cTitulo  := "" // DSERLOCA-13414
Local nI       := 0 // DSERLOCA-13414

Default lAuto := .F. // DSERLOCA-13414

	aAlertas := LOCA001LP2(cProjeto) // DSERLOCA-13414

	If lAuto .And. Len(aAlertas) == 0 // DSERLOCA-13414 - modo automatico so interrompe o usuario quando ha algo a alertar
		Return .T.
	EndIf

	If Len(aAlertas) > 0 // DSERLOCA-13414
		cCliente := aAlertas[1][2] // DSERLOCA-13414
	EndIf

	For nI := 1 To Len(aAlertas) // DSERLOCA-13414
		Aadd(aItens, { .F., LOCA001LP1(aAlertas[nI]) }) // DSERLOCA-13414
	Next nI

	If Len(aItens) == 0 // DSERLOCA-13414
		If !lAuto // DSERLOCA-13414
			MsgAlert(STR0014, STR0013) // DSERLOCA-13414 //"Alerta de PO Expirado" //"Não foram encontrados itens com PO expirado para este contrato."
		EndIf
		Return .T.
	EndIf

	Aadd(aEventos, { .F., STR0015, aItens }) // DSERLOCA-13414 //"PO Expirado"

	cTitulo := STR0016 + AllTrim(cProjeto) // DSERLOCA-13414 //"PO(s) Expirado(s) - Contrato "
	If !Empty(cCliente) // DSERLOCA-13414
		cTitulo += " - " + cCliente // DSERLOCA-13414
	EndIf

	// Reaproveita a tela padrao de eventos/resultados, ja usada em LOCA001AL/LOCA229G.PRW // DSERLOCA-13414
	Loca229G(cTitulo, aEventos) // DSERLOCA-13414

Return .T.

/*/{Protheus.doc} LOCA001LP1
Monta a descricao do item de FPA exibido no detalhe do alerta de PO
expirado (Obra, Bem/Produto, PO e data de validade do PO).
DSERLOCA-13414
@type function
@author Dennis Calabrez
@since 28/08/2026
@param aItem, array, Linha retornada por LOCA001LP2
@return character, Descricao do item de FPA
/*/
Static Function LOCA001LP1(aItem) // DSERLOCA-13414
Local cDesc := "" // DSERLOCA-13414

	cDesc := STR0017 + aItem[4] // DSERLOCA-13414 - FPA_OBRA (via FP1_OBRA) //"Obra "
	cDesc += STR0018 + aItem[8] // DSERLOCA-13414 - FPA_SEQGRU //" - Seq "
	cDesc += STR0019 + aItem[5] // DSERLOCA-13414 //" - Produto "
	If !Empty(aItem[7]) // DSERLOCA-13414 - descricao do produto/bem (FPA_DESGRU)
		cDesc += " - " + aItem[7] // DSERLOCA-13414
	EndIf
	If !Empty(aItem[6]) // DSERLOCA-13414 - codigo do bem especifico (FPA_GRUA), nem todo item tem
		cDesc += " (Bem " + aItem[6] + ")" // DSERLOCA-13414
	EndIf

	cDesc += STR0020 + aItem[10] // DSERLOCA-13414 - FH7_PO //" - PO "
	cDesc += STR0021 + aItem[9] // DSERLOCA-13414 - FPA_IDPO //" - IDPO "
	cDesc += STR0022 + aItem[11] // DSERLOCA-13414 - FH7_DTVAL //" - Validade "

Return cDesc

/*/{Protheus.doc} LOCA001LP2
Consulta, por item da FPA, os itens do contrato informado cujo PO
vinculado (FPA_IDPO) esteja com a validade (FH7_DTVAL, tabela FH7)
expirada, ou seja, menor que a data atual.
Join reaproveitado de LOCA001L2 (FP0 -> FP1 -> FPA -> SA1), acrescido do
join com FH7 pelo FPA_IDPO/FH7_IDPO.
DSERLOCA-13414
@type function
@version 25.10
@author Dennis Calabrez
@since 28/08/2026
@param cProjeto, character, Codigo do contrato/projeto (FP0_PROJET) a verificar
@return array, Um item por alerta identificado (item da FPA); cada linha:
        { STATUS, CLIENTE, PROJETO, OBRA, PRODUTO, BEM, DESCBEM, SEQGRU, IDPO, PO, DTVAL }
/*/
Static Function LOCA001LP2(cProjeto) // DSERLOCA-13414
Local cQuery      := "" // DSERLOCA-13414
Local aBindParam  := {} // DSERLOCA-13414
Local aRet        := {} // DSERLOCA-13414
Local cSqlHoje    := "" // DSERLOCA-13414 - "hoje", compativel Oracle e MSSQL
Local cLinha      := "" // DSERLOCA-13414
Local cComando    := "" // DSERLOCA-13414

	LOCACLOSE("TRBALEPO") // DSERLOCA-13414

	// Mesmo padrao de deteccao de banco ja usado em LOCA001L2/LOCA013A.PRW (TCGetDB()) // DSERLOCA-13414
	If Upper(TCGetDB()) $ "ORACLE" .Or. file("\SYSTEM\LOCA001AL.TXT") // DSERLOCA-13414
		cSqlHoje := "SYSDATE" // DSERLOCA-13414
	Else // DSERLOCA-13414 - MSSQL
		cSqlHoje := "GETDATE()" // DSERLOCA-13414
	EndIf

	cQuery := " SELECT FP0.FP0_PROJET AS CPROJET, FP1.FP1_OBRA AS COBRA, SA1.A1_NOME AS CCLIENTE, " // DSERLOCA-13414
	cQuery += "        FPA.FPA_PRODUT AS CPRODUT, FPA.FPA_GRUA AS CBEM, FPA.FPA_DESGRU AS CDESBEM, FPA.FPA_SEQGRU AS CSEQGRU, " // DSERLOCA-13414
	cQuery += "        FPA.FPA_IDPO AS CIDPO, FH7.FH7_PO AS CPO, FH7.FH7_DTVAL AS DDTVAL " // DSERLOCA-13414
	cQuery += "   FROM " + RetSqlName("FP0") + " FP0 " // DSERLOCA-13414
	cQuery += "   LEFT JOIN " + RetSqlName("FP1") + " FP1 ON FP1.FP1_FILIAL = FP0.FP0_FILIAL AND FP1.FP1_PROJET = FP0.FP0_PROJET AND FP1.D_E_L_E_T_ = ' ' " // DSERLOCA-13414
	cQuery += "   LEFT JOIN " + RetSqlName("FPA") + " FPA ON FPA.FPA_FILIAL = FP1.FP1_FILIAL AND FPA.FPA_PROJET = FP1.FP1_PROJET AND FPA.FPA_OBRA = FP1.FP1_OBRA AND FPA.FPA_TIPOSE <> 'S' AND FPA.D_E_L_E_T_ = ' ' " // DSERLOCA-13414
	cQuery += "   LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = FP0.FP0_CLI AND SA1.A1_LOJA = FP0.FP0_LOJA AND SA1.D_E_L_E_T_ = ' ' " // DSERLOCA-13414
	cQuery += "   INNER JOIN " + RetSqlName("FH7") + " FH7 ON FH7.FH7_FILIAL = FPA.FPA_FILIAL AND FH7.FH7_IDPO = FPA.FPA_IDPO AND FH7.D_E_L_E_T_ = ' ' " // DSERLOCA-13414 - PO vinculado ao item da FPA
	cQuery += "  WHERE FP0.FP0_FILIAL = ? " // DSERLOCA-13414
	cQuery += "    AND FP0.FP0_PROJET = ? " // DSERLOCA-13414
	cQuery += "    AND FP0.FP0_STATUS NOT IN ('A','B') " // DSERLOCA-13414
	cQuery += "    AND FP0.D_E_L_E_T_ = ' ' " // DSERLOCA-13414
	cQuery += "    AND FPA.FPA_TIPOSE <> 'Z' " // DSERLOCA-13414
	cQuery += "    AND FPA.FPA_IDPO <> ' ' " // DSERLOCA-13414 - so verifica quando o item tem PO vinculado
	cLinha := "    AND FH7.FH7_DTVAL < " + cSqlHoje + " " // DSERLOCA-13414 - PO com validade expirada
	cComando := 'cQuery += cLinha ' // DSERLOCA-13414
	&(cComando) // DSERLOCA-13414
	cQuery += " ORDER BY 1, 7 " // DSERLOCA-13414

	cQuery := ChangeQuery(cQuery) // DSERLOCA-13414
	aBindParam := { XFilial("FP0"), cProjeto } // DSERLOCA-13414
	MPSysOpenQuery(cQuery,"TRBALEPO",,,aBindParam) // DSERLOCA-13414

	While TRBALEPO->(!Eof()) // DSERLOCA-13414
		Aadd(aRet, { "SPS_ERROR_S", ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CCLIENTE), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CPROJET), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->COBRA), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CPRODUT), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CBEM), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CDESBEM), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CSEQGRU), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CIDPO), ; // DSERLOCA-13414
			LOCA001L4(TRBALEPO->CPO), ; // DSERLOCA-13414
			LOCA001L3(TRBALEPO->DDTVAL) } ) // DSERLOCA-13414
		TRBALEPO->(DbSkip()) // DSERLOCA-13414
	EndDo // DSERLOCA-13414

	TRBALEPO->(DbCloseArea()) // DSERLOCA-13414

Return aRet

/*/{Protheus.doc} LOCA001MU
Calcula e gera a Multa Contratual (Custo Extra, tabela FPG) na
finalizacao do contrato (transicao de FP0_STATUS para "8"=Faturado),
disparada por FSALVARFOL() em loca001.prw (ver MULTA_CONTRATUAL_ET.md).
Percorre cada linha (A.S.) da FPA do contrato informado, desconsiderando
FPA_TIPOSE == "S" (substituida - RN-N03), calcula o saldo de parcelas
ainda nao faturadas reaproveitando LocxItu30() (locxitu.prw - ja aplica
o filtro FPZ_EXTRA='N' e a exclusao de pedidos de pro-rata) e aplica o
percentual de FP0_MULTA sobre o valor base (FPA_VRHOR) desse saldo,
gerando um registro FPG por linha com valorMulta > 0 (RN-N04/RN-N07).
Funcao nova, criada neste fonte (LOCA001AL) para nao interferir nas
funcoes ja existentes aqui (LOCA001AL, LOCA001L1 a LOCA001L4,
LOCA001ALP, LOCA001LP1/LP2) e para nao criar funcoes em loca001.prw.
DSERLOCA-13625
@type function
@version 25.10
@author Dennis Calabrez
@since 14/09/2026
@param cProjeto, character, Codigo do contrato/projeto (FP0_PROJET) recem finalizado
@return logical, Sempre .T.
/*/
Function LOCA001MU(cProjeto) // DSERLOCA-13625
Local aAreaFP0  := FP0->(GetArea()) // DSERLOCA-13625
Local aAreaFPA  := FPA->(GetArea()) // DSERLOCA-13625
Local nPerMulta := 0 // DSERLOCA-13625
Local cProduto  := "" // DSERLOCA-13625
Local cQuery    := "" // DSERLOCA-13625
Local aBindParam := {} // DSERLOCA-13625

	If FP0->(FieldPos("FP0_MULTA")) == 0 // DSERLOCA-13625 - dicionario (ATUSX) ainda nao distribuido nesta base
		Return .T.
	EndIf

	FP0->(DbSetOrder(1)) // DSERLOCA-13625 - FP0_FILIAL+FP0_PROJET+FP0_NUM
	If !FP0->(DbSeek(xFilial("FP0") + cProjeto)) // DSERLOCA-13625
		FP0->(RestArea(aAreaFP0)) // DSERLOCA-13625
		FPA->(RestArea(aAreaFPA)) // DSERLOCA-13625
		Return .T.
	EndIf

	nPerMulta := FP0->FP0_MULTA // DSERLOCA-13625

	If Empty(nPerMulta) // DSERLOCA-13625 - RN-N02: sem percentual configurado, nao gera multa
		FP0->(RestArea(aAreaFP0)) // DSERLOCA-13625
		FPA->(RestArea(aAreaFPA)) // DSERLOCA-13625
		Return .T.
	EndIf

	cProduto := AllTrim(SuperGetMV("MV_LOCX318",,"")) // DSERLOCA-13625 - codigo do produto (SB1) da Multa Contratual, para FPG_PRODUT

	If Empty(cProduto) // DSERLOCA-13625 - produto de multa ainda nao parametrizado/cadastrado (ver MULTA_CONTRATUAL_ET.md, item 10.2)
		FWLogMsg("WARN", , "LOCA001AL", "LOCA001MU", , "01", "MV_LOCX318 (produto da Multa Contratual) nao parametrizado - multa do contrato " + AllTrim(cProjeto) + " nao gerada", 0, 0, {}) // DSERLOCA-13625
		FP0->(RestArea(aAreaFP0)) // DSERLOCA-13625
		FPA->(RestArea(aAreaFPA)) // DSERLOCA-13625
		Return .T.
	EndIf

	cQuery := "SELECT FPA_AS AS CFPAAS " // DSERLOCA-13625
	cQuery += "  FROM " + RetSqlName("FPA") + " FPA " // DSERLOCA-13625
	cQuery += " WHERE FPA_FILIAL = ? " // DSERLOCA-13625
	cQuery += "   AND FPA_PROJET = ? " // DSERLOCA-13625
	cQuery += "   AND FPA_TIPOSE <> 'S' " // DSERLOCA-13625 - RN-N03
	cQuery += "   AND FPA.D_E_L_E_T_ = ' ' " // DSERLOCA-13625
	Aadd(aBindParam, xFilial("FPA")) // DSERLOCA-13625
	Aadd(aBindParam, cProjeto) // DSERLOCA-13625
	cQuery := ChangeQuery(cQuery) // DSERLOCA-13625

	LOCACLOSE("TRBMULTA") // DSERLOCA-13625
	MPSysOpenQuery(cQuery, "TRBMULTA", , , aBindParam) // DSERLOCA-13625

	FPA->(DbSetOrder(3)) // DSERLOCA-13625 - FPA_FILIAL+FPA_AS+FPA_VIAGEM

	While TRBMULTA->(!Eof()) // DSERLOCA-13625
		If FPA->(DbSeek(xFilial("FPA") + TRBMULTA->CFPAAS)) // DSERLOCA-13625 - reposiciona a FPA real (LocxItu30 le pela alias FPA ambiente)
			LOCA001MU1(nPerMulta, cProduto) // DSERLOCA-13625
		EndIf // DSERLOCA-13625
		TRBMULTA->(DbSkip()) // DSERLOCA-13625
	EndDo // DSERLOCA-13625

	TRBMULTA->(DbCloseArea()) // DSERLOCA-13625

	FP0->(RestArea(aAreaFP0)) // DSERLOCA-13625
	FPA->(RestArea(aAreaFPA)) // DSERLOCA-13625

Return .T.

/*/{Protheus.doc} LOCA001MU1
Calcula e grava a Multa Contratual (registro FPG) para a linha da FPA
atualmente posicionada (chamada exclusivamente por LOCA001MU, apos
reposicionar a FPA na linha/A.S. a apurar). Reaproveita LocxItu30()
(locxitu.prw) para obter o saldo de parcelas ainda nao faturadas dessa
linha e aplica o percentual de multa (nPerMulta) sobre o saldo
remanescente (FPA_VRHOR * parcelas em aberto), no mesmo padrao de
geracao de FPG usado por LOCM001.PRW/GERANFPG() (loca007.prw).
DSERLOCA-13625
@type function
@author Dennis Calabrez
@since 14/09/2026
@param nPerMulta, numeric, Percentual de multa contratual (FP0_MULTA)
@param cProduto, character, Codigo do produto (SB1) da Multa Contratual (MV_LOCX318)
@return logical, Sempre .T.
/*/
Static Function LOCA001MU1(nPerMulta, cProduto) // DSERLOCA-13625
Local nParcAbe  := 0 // DSERLOCA-13625
Local nValMulta := 0 // DSERLOCA-13625

	nParcAbe := LocxItu30() // DSERLOCA-13625 - parcelas ainda nao faturadas da FPA posicionada (locxitu.prw)

	nValMulta := (nParcAbe * FPA->FPA_VRHOR) * (nPerMulta / 100) // DSERLOCA-13625

	If nValMulta <= 0 // DSERLOCA-13625 - RN-N04: nao gera FPG quando o valor apurado nao for positivo
		Return .T.
	EndIf

	If RecLock("FPG", .T.) // DSERLOCA-13625
		FPG->FPG_FILIAL := xFilial("FPG") // DSERLOCA-13625
		FPG->FPG_PROJET := FPA->FPA_PROJET // DSERLOCA-13625
		FPG->FPG_OBRA   := FPA->FPA_OBRA // DSERLOCA-13625
		FPG->FPG_NRAS   := FPA->FPA_AS // DSERLOCA-13625 - RN-N07: rastreabilidade por A.S.
		FPG->FPG_CUSTO  := FPA->FPA_CUSTO // DSERLOCA-13625
		FPG->FPG_TIPO   := "5" // DSERLOCA-13625 - Multa Contratual (validar X3_TAMANHO de FPG_TIPO em ATUSX - ver MULTA_CONTRATUAL_ET.md item 10.2)
		FPG->FPG_PRODUT := cProduto // DSERLOCA-13625 - MV_LOCX318
		FPG->FPG_DESCRI := "MULTA CONTRATUAL - CONTRATO " + AllTrim(FPA->FPA_PROJET) // DSERLOCA-13625
		FPG->FPG_QUANT  := 1 // DSERLOCA-13625
		FPG->FPG_VLUNIT := nValMulta // DSERLOCA-13625
		FPG->FPG_VALOR  := nValMulta // DSERLOCA-13625
		FPG->FPG_VALTOT := nValMulta // DSERLOCA-13625
		FPG->FPG_COBRA  := "S" // DSERLOCA-13625
		FPG->FPG_DTENT  := dDataBase // DSERLOCA-13625
		FPG->FPG_STATUS := "1" // DSERLOCA-13625
		FPG->FPG_SEQ    := GetSx8Num("FPG", "FPG_SEQ") // DSERLOCA-13625 - RN-N06, mesmo padrao de GERANFPG() (loca007.prw)
		ConfirmSx8() // DSERLOCA-13625
		FPG->(MsUnlock()) // DSERLOCA-13625
	EndIf // DSERLOCA-13625

Return .T.
