#INCLUDE "TOTVS.CH"
#INCLUDE "AGDI041.CH"

#DEFINE INSRUCAO_EMBARQUE_PEDIDO_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService

/*/{Protheus.doc} AGDI041
Verifica se o Pedido faz parte de uma Instrução de Embarque (SIGAAGD)
e solicita confirmação para exclusão do Pedido de Venda (SIGAFAT).
Rotina Utilizada no MATA410
@type function
@version 12
@author jc.maldonado
@since 27/02/2025
@param cCodPedVen, character, codigo do pedido de venda (SC5->C5_NUM)
@return logical, .T. or .F.
/*/
Function AGDI041(cCodPedVen)
	Local aArea
	Local oInsEmbPed
	Local lRet := .T.

	If !Empty(cCodPedVen) .And. SUPERGETMV("MV_SIGAAGD", .F., .F.)
		aArea := FWgetArea()

		oInsEmbPed := INSRUCAO_EMBARQUE_PEDIDO_SERVICE():New("")
	
		If Upper(FunName()) == "MATA410" .And. oInsEmbPed:setInstrucaoEmbarqueFromPedido(cCodPedVen)
			if ! (lRet := FWAlertYesNo(STR0001, "")) //Este pedido possui instrução de embarque vinculado do módulo 54-SIGAAGD, ao excluir o pedido, o vínculo será desfeito com a instrução. Deseja prosseguir com a exclusão?
				AGDHELP(STR0003, STR0002)
			EndIf
		EndIf
		
		FreeObj(oInsEmbPed)
		FWrestArea(aArea)
	EndIf
Return lRet
