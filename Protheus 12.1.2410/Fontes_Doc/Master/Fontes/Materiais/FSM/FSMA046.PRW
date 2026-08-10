#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCLASEE source FSMA046 RESOURCE OBJECT FsmRestModel

    Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruCTH	:= FWFormStruct(1, "CTH")

    oModel := MPFormModel():New('FSMA046', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('CTHMASTER',/*cOwner*/,oStruCTH)

    oModel:GetModel('CTHMASTER'):SetDescription("Classe")

    oModel:SetDescription("Classe")

    oModel:SetPrimaryKey( { "CTH_FILIAL", "CTH_CLVL" } )

Return oModel
