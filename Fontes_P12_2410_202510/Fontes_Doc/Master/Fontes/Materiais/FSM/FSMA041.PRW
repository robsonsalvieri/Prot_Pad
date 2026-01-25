#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMNATFIN source FSMA041 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruSED	:= FWFormStruct(1, "SED")

    oModel := MPFormModel():New('FSMA041', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('SEDMASTER',/*cOwner*/,oStruSED)

    oModel:GetModel('SEDMASTER'):SetDescription("Natureza financeira")

    oModel:SetDescription("Natureza financeira")

    oModel:SetPrimaryKey( { "ED_FILIAL", "ED_CODIGO" } )

Return oModel
