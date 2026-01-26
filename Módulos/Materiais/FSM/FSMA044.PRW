#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCONTCONTABIL source FSMA044 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruCT1	:= FWFormStruct(1, "CT1")

    oModel := MPFormModel():New('FSMA044', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('CT1MASTER',/*cOwner*/,oStruCT1)

    oModel:GetModel('CT1MASTER'):SetDescription("Conta contábil")

    oModel:SetDescription("Conta contábil")

    oModel:SetPrimaryKey( { "CT1_FILIAL", "CT1_CONTA" } )

Return oModel
