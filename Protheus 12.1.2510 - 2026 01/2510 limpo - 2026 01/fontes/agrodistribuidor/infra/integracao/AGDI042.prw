#INCLUDE "TOTVS.CH"
#DEFINE INSRUCAO_EMBARQUE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService

/*/{Protheus.doc} AGDI042
Remove o vinculo do pedido com a instrucao de embarque
Rotina Utilizada no MATA410
@type function
@version 12
@author jc.maldonado
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
/*/
Function AGDI042(cCodPedVen)
	Local aArea
	Local oInsEmbPed

	If !Empty(cCodPedVen) .And. (SUPERGETMV("MV_SIGAAGD", .F., .F.) .and. TableInDic('NEC'))
		aArea := FWgetArea()

		oInsEmbPed := INSRUCAO_EMBARQUE_PEDIDO_SERVICE():New("")

		If oInsEmbPed:setInstrucaoEmbarqueFromPedido(cCodPedVen)
			oInsEmbPed:removerVinculoPedido()
		EndIf

		FreeObj(oInsEmbPed)

		FwRestArea(aArea)
	EndIf
Return
