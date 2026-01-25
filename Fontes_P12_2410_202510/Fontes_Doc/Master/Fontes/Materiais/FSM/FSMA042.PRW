#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMPRODFAT source FSMA042 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruSB1	:= FWFormStruct(1, "SB1")

    oModel := MPFormModel():New('FSMA042', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('SB1MASTER',/*cOwner*/,oStruSB1)

    oModel:GetModel('SB1MASTER'):SetDescription("Produto do faturamento")

    oModel:SetDescription("Produto do faturamento")

    oModel:SetPrimaryKey( { "B1_FILIAL", "B1_COD" } )

Return oModel
