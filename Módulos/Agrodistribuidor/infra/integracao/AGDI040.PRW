#INCLUDE "TOTVS.ch" 
#DEFINE IE_SERVICE agd.instrucaoEmbarquePedidoService.agdInstrucaoEmbarquePedidoService
#INCLUDE "AGDI040.ch"

/*/{Protheus.doc} AGDI040
Função executada pelo módulo de faturamento ao liberar um pedido de venda
Valida a liberação de pedidos vinculados ao SIGAAGD com instrução de embarque
@type function
@version 12
@author rodrigo.nsoledade
@since 27/02/2025
@return variant, nil
/*/
Function AGDI040()
    Local aAreaAtu   := GetArea()
    Local cNumPed    := SC5->C5_NUM
    Local oIEService := Nil
    Local lRet := .T.
    
    // Verifica se a configuração do SIGAAGD está habilitada
    If SUPERGETMV("MV_SIGAAGD", .F., .F.)

        If Type("aHeader") == "A" .And. Type("aCols") == "A"
            // Criar instância do serviço de instrução de embarque
            oIEService := IE_SERVICE():New()

            // Chamar a validação antes de liberar o pedido
            If !oIEService:validLiberacaoPedido(cNumPed,aHeader,aCols)
                AGDHELP(STR0001, oIEService:getMessageError()) //"Atenção"
                lRet := .F. // Impede a liberação se for parcial
            EndIf

            FreeObj(oIEService)
        EndIf
    EndIf

    RestArea(aAreaAtu)
Return lRet
