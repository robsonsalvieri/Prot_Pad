#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI042.CH"

#DEFINE INSRUCAO_EMBARQUE_PEDIDO_SERVICE totvs.protheus.agrobusiness.agd.BoardingInstructionOrderService
#DEFINE SALES_ORDER_EXTENSION_REPOSITORY totvs.protheus.agrobusiness.agd.SalesOrderExtensionRepository

/*/{Protheus.doc} AGDI042
Executa regras após a exclusão do pedido de venda
Rotina Utilizada na função A420Deleta() do MATA410
@type function
@version 12
@author jc.maldonado
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
/*/
Function AGDI042(cCodPedVen)
	Local aArea    := {}
	Local lIncluir := INCLUI
	Local lAlterar := ALTERA

	Default cCodPedVen := ""

	If ! SUPERGETMV("MV_SIGAAGD", .F., .F.);
			.Or. ! TableInDic('NEC');
			.Or. Empty(cCodPedVen)
		Return
	EndIf

	aArea := FWgetArea()

	//Pedido de venda com Instrução de Embarque
	ruleInsEmb(cCodPedVen)

	//Pedido de venda com Informações Adicionais para o Agrodistribuidor
	ruleIntNEQ(cCodPedVen)

	// Garante que as variáveis INCLUI e ALTERA retornem ao valor inicial
	INCLUI := lIncluir
	ALTERA := lAlterar

	FwRestArea(aArea)
Return

/*/{Protheus.doc} ruleInsEmb
Aplica regras quando o pedido possui instrução de embarque
-Remove o Vinculo do Pedido de Venda com a Instrução de Embarque
@type function
@version 12
@author jc.maldonado
@since 14/05/2026
@param cCodPedVen, character, Código do Pedido de Venda
/*/
Static Function ruleInsEmb(cCodPedVen)
	Local oInsEmbPed := INSRUCAO_EMBARQUE_PEDIDO_SERVICE():New("")

	If oInsEmbPed:isPedidoInstrucEmbarque(cCodPedVen)
		oInsEmbPed:setInstrucaoEmbarqueFromPedido(cCodPedVen)
		oInsEmbPed:removerVinculoPedido()
	EndIf

	FWFreeObj(oInsEmbPed)
Return

/*/{Protheus.doc} ruleIntNEQ
Aplica regras quando o pedido possui informações adicionais para o agrodistribuidor
-Remove o vinculo do Pedido de Venda com a tabela NEQ
@type function
@version 12
@author jc.maldonado
@since 14/05/2026
@param cCodPedVen, character, Código do Pedido de Venda
/*/
Static Function ruleIntNEQ(cCodPedVen)
	Local oRepoOrdEx := Nil
	Local cChaveId   := ""

	If ! TableInDic('NEQ');
			.Or. (DBSelectArea("NEQ"), NEQ->(FieldPos("NEQ_INTEXT")) = 0)
		Return
	EndIf

	oRepoOrdEx := SALES_ORDER_EXTENSION_REPOSITORY():new()
	cChaveId   := FWxFilial("NEQ") + cCodPedVen
	If ! oRepoOrdEx:existsById(cChaveId)
		FWFreeObj(oRepoOrdEx)
		Return
	EndIf

	oRepoOrdEx:modelDelete(cChaveId, "AGDX040")
	If ! oRepoOrdEx:isSuccess()
		AGDHELP(STR0001, oRepoOrdEx:getMessageError()) //"AJUDA"
	EndIf

	FWFreeObj(oRepoOrdEx)
Return
