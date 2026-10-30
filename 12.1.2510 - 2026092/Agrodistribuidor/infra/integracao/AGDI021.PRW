#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDI021.CH"

#DEFINE IE_PEDIDO_SERVICE                totvs.protheus.agrobusiness.agd.BoardingInstructionOrderService
#DEFINE SOLICITACAO_RECEITA_SERVICE      totvs.protheus.agrobusiness.agd.RequestRecipeService
#DEFINE SOLICITACAO_RECEITA_REPOSITORY   totvs.protheus.agrobusiness.agd.RequestRecipeRepository
#DEFINE SALES_ORDER_EXTENSION_REPOSITORY totvs.protheus.agrobusiness.agd.SalesOrderExtensionRepository

/*/{Protheus.doc} AGDI021
Funcao executada pelo modulo de faturamento:
MATA410 - Alteracao do Pedido de Venda 
MATV410 - Rotina de validacao do tudoOk da Enchoice
@type function
@version 12
@author lindembergson.pacheco
@since 05/03/2025
@param oGetPV, object, Cabeçario do pedido de venda (MSMGET)
@param oGetd, object, Lista de produtos do pedido de venda (MSGETDADOS)
@return logical, Resultado da validação para rotina A410VldTOk() do MATV410
/*/
Function AGDI021(oGetPV, oGetd)
	Local lRet       := .T.
	Local aAreaAtu   := FWGetArea()
	Local lIncluir   := INCLUI
	Local lAlterar   := ALTERA
	Local lA410VldOk := oGetPV == Nil .And. oGetd == Nil .And. FwIsInCallStack("A410VLDTOK")

	If ! SUPERGETMV("MV_SIGAAGD", .f., .f.) .Or. ! TableInDic('NEC')
		Return lRet
	EndIf

	If lAlterar
		// Regras para pedido que possui Instrução de Embarque
		ruleInsEmb(lA410VldOk, oGetPV, oGetd, @lRet)

		// Regras para pedido com Integração Externa (NEQ_INTEXT = "1")
		ruleIntExt(lA410VldOk, oGetPV, oGetd, @lRet)

		// Regras para pedido com Solicitação de Receita Agronômica
		ruleSReAgr(lA410VldOk, lRet)
	EndIf

	// Garante que as variáveis INCLUI e ALTERA retornem ao valor inicial
	INCLUI := lIncluir
	ALTERA := lAlterar

	FWRestArea(aAreaAtu)
Return lRet

/*/{Protheus.doc} ruleInsEmb
Aplica regras quando o pedido possui instrução de embarque [Pedido - ALTERAR]
Alteração:
-Define campos como somente visualização
-Desabilita a lista de produtos do pedido
Validação:
-Verifica e restaura alteracoes em campos especificos
@type function
@version 12
@author jc.maldonado
@since 06/05/2026
@param lA410VldOk, logical, Identifica se a chamada é atraves da rotina A410VldTOk()
@param oGetPV, object, cabecario pedido de venda (MSMGET)
@param oGetd, object, lista do pedido de venda (MSGETDADOS)
@param lRet, logical, Recebida por referencia para controlar a validade do processo A410VldTOk()
/*/
Static Function ruleInsEmb(lA410VldOk, oGetPV, oGetd, lRet)
	Local oIEPedSrvc := IE_PEDIDO_SERVICE():New()

	If ! oIEPedSrvc:isPedidoInstrucEmbarque(SC5->C5_NUM)
		FwFreeObj(oIEPedSrvc)
		Return
	EndIf

	FwFreeObj(oIEPedSrvc)

	If lA410VldOk
		If ! chkAndRest("SC5",;
				{"C5_CLIENT", "C5_LOJAENT", "C5_CONDPAG", "C5_VEND1",;
				"C5_TABELA", "C5_CODSAF", "C5_TPFRETE", "C5_FRETE"})
			lRet := .F.
			AGDHELP(STR0001, STR0002) //#"Atencao" # //"Este pedido possui instrução de embarque, por este motivo o tipo de modificação feita interfere com o que foi negociado. Por favor verifique."
		EndIf
	Else
		If oGetPV != Nil
			stReadOnly(oGetPV, {"M->C5_CLIENTE", "M->C5_LOJACLI"})
		EndIf

		If oGetd != NIL
			oGetd:Disable()
		EndIf
	EndIf
Return

/*/{Protheus.doc} chkAndRest
Verifica alterações nos campos em memoria e restaura para os valores da tabela se houver alteração.
@type function
@version 12
@author jc.maldonado
@since 06/05/2026
@param cAlias, character, Alias da tabela
@param aFields, array, Lista de campos (M->campo) a serem verificados
@return logical, Retorna .F. se houver alteração em relação ao banco de dados, caso contrário .T.
/*/
Static Function chkAndRest(cAlias, aFields)
	Local nX   := 0
	Local lRet := .T.

	For nX := 1 To Len(aFields)
		If Type("M->" + aFields[nX]) != "U";
				.And. M->&(aFields[nX]) != (cAlias)->&(aFields[nX])

			M->&(aFields[nX]) := (cAlias)->&(aFields[nX])
			lRet := .F.
		EndIf
	Next nX
Return lRet

/*/{Protheus.doc} stReadOnly
Define os campos informados como somente leitura no MSMGET
@type function
@version 12
@author jc.maldonado
@since 06/05/2026
@param oMSMGET, object, Instancia do MSMGET
@param aFields, array, Lista de campos a serem definidos como somente leitura
/*/
Static Function stReadOnly(oMSMGET, aFields)
	Local nX        := 0
	Local nPosition := 0

	For nX := 1 To Len(aFields)
		nPosition := Ascan(oMSMGET:aEntryCtrls, {|x| UPPER(TRIM(x:cReadVar)) == aFields[nX]})
		If nPosition > 0
			oMSMGET:aEntryCtrls[nPosition]:lReadOnly := .T.
		EndIf
	Next nX
Return

/*/{Protheus.doc} ruleIntExt
Aplica regras quando a origem do pedido é uma integração externa [Pedido - ALTERAR]
Alteração:
-Define campos como somente visualização
-Desabilita a lista de produtos do pedido
Validação:
-Verifica e restaura alteracoes em campos especificos
@type function
@version 12
@author jc.maldonado
@since 06/05/2026
@param lA410VldOk, logical, Identifica se a chamada é atraves da rotina A410VldTOk()
@param oGetPV, object, cabecario pedido de venda (MSMGET)
@param oGetd, object, lista do pedido de venda (MSGETDADOS)
@param lRet, logical, Recebida por referencia para controlar a validade do processo A410VldTOk()
/*/
Static Function ruleIntExt(lA410VldOk, oGetPV, oGetd, lRet)
	If ! TableInDic('NEQ');
			.Or. NEQ->(FieldPos("NEQ_INTEXT")) = 0;
			.Or. ! SALES_ORDER_EXTENSION_REPOSITORY():isIntegracaoExterna(M->C5_NUM)
		Return
	EndIf

	If lA410VldOk
		If ! chkAndRest("SC5",;
				{"C5_CLIENT", "C5_LOJAENT", "C5_TIPOCLI", "C5_MOEDA", "C5_CONDPAG",;
				"C5_EMISSAO", "C5_TPFRETE", "C5_FRETE", "C5_SEGURO", "C5_PBRUTO",;
				"C5_DESC1", "C5_DESC2", "C5_DESC3", "C5_DESC4"})

			lRet := .F.
			AGDHELP(STR0001, STR0004) //"Atencao", "Este pedido possui integração externa, por este motivo o tipo de modificação feita interfere com o que foi negociado. Por favor verifique."
		EndIf
	Else
		If oGetPV != Nil
			stReadOnly(oGetPV, {"M->C5_CLIENTE", "M->C5_LOJACLI"})
		EndIf

		If oGetd != NIL
			oGetd:Disable()
		EndIf
	EndIf
Return

/*/{Protheus.doc} ruleSReAgr
Aplica regras para pedido com solicitação de Receita Agronômica [Pedido - Validação - ALTERAR]
-Atualiza Status das Solicitações de Receita Agronômica do pedido
@type function
@version P12
@author scheronlini.martins
@since 05/12/2025
@param lA410VldOk, logical, Identifica se a chamada é atraves da rotina A410VldTOk()
@param lRet, logical, Controla a validade do processo A410VldTOk()
/*/
Static Function ruleSReAgr(lA410VldOk, lRet)
	Local oSrvSolRec := Nil
	Local oRepSolRec := Nil
	Local aSolPedido := {}
	Local nX         := 0

	If ! TableInDic('NET')
		Return
	EndIf

	If lA410VldOk .And. lRet
		oSrvSolRec := SOLICITACAO_RECEITA_SERVICE():new()
		oRepSolRec := SOLICITACAO_RECEITA_REPOSITORY():new()

		aSolPedido := oRepSolRec:getSolicPedidos(SC5->C5_NUM)

		For nX := 1 To Len(aSolPedido)
			oSrvSolRec:inativarSolicitacoesAnteriores(aSolPedido[nX, 1], aSolPedido[nX, 2], aSolPedido[nX, 3])
		Next nX

		FwFreeObj(oSrvSolRec)
		FwFreeObj(oRepSolRec)
	EndIf
Return
