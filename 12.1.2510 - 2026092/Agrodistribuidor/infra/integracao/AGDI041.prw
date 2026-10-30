#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI041.CH"

#DEFINE INSRUCAO_EMBARQUE_PEDIDO_SERVICE totvs.protheus.agrobusiness.agd.BoardingInstructionOrderService
#DEFINE SALES_ORDER_EXTENSION_REPOSITORY totvs.protheus.agrobusiness.agd.SalesOrderExtensionRepository

/*/{Protheus.doc} AGDI041
Executa regras antes de excluir um pedido de venda
Rotina Utilizada na funcao A410Deleta() do MATA410
@type function
@version 12
@author jc.maldonado
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
@return logical, Resultado da validação para rotina A410Deleta()
/*/
Function AGDI041(cCodPedVen)
	Local aArea    := {}
	Local lRet     := .T.
	Local lIncluir := INCLUI
	Local lAlterar := ALTERA

	If ! SUPERGETMV("MV_SIGAAGD", .F., .F.);
			.Or. Empty(cCodPedVen);
			.Or. Upper(FunName()) != "MATA410"
		Return lRet
	Endif

	aArea := FWgetArea()

	//Pedido de venda com Instrução de Embarque
	ruleInsEmb(cCodPedVen, @lRet)

	// Garante que as variáveis INCLUI e ALTERA retornem ao valor inicial
	INCLUI := lIncluir
	ALTERA := lAlterar

	FWRestArea(aArea)
Return lRet

/*/{Protheus.doc} ruleInsEmb
Aplica regras para pedido de venda com instrução de embarque
-Solicita confirmação ao tentar excluir o pedido de venda
@type function
@version 12
@author jc.maldonado
@since 11/05/2026
@param cCodPedVen, character, Código do pedido de venda
@param lRet, logical, Recebido por referencia, resultado da validação para rotina A410Deleta()
/*/
Static Function ruleInsEmb(cCodPedVen, lRet)
	Local oInsEmbPed := Nil

	oInsEmbPed := INSRUCAO_EMBARQUE_PEDIDO_SERVICE():New()
	If oInsEmbPed:isPedidoInstrucEmbarque(cCodPedVen);
			.And. ! (lRet := FWAlertYesNo(STR0001, "")) //"Este pedido possui instrução de embarque vinculado do módulo 54-SIGAAGD, ao excluir o pedido, o vínculo será desfeito com a instrução. Deseja prosseguir com a exclusão?"

		AGDHELP(STR0003, STR0002)
	EndIf

	FWFreeObj(oInsEmbPed)
Return
