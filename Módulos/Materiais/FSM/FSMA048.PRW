#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMPEDIDOVENDA source FSMA048 RESOURCE OBJECT FsmRestModel

    Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruSC5	:= FWFormStruct(1, "SC5")

    oModel := MPFormModel():New('FSMA048', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('SC5MASTER',/*cOwner*/,oStruSC5)

    oModel:GetModel('SC5MASTER'):SetDescription("Pedido de Venda")

    oModel:SetDescription("Pedido de Venda")

    oModel:SetPrimaryKey( { "C5_FILIAL", "C5_NUM" } )

Return oModel
