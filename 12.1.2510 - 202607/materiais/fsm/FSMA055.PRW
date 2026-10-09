#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMTES source FSMA055 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   as object
    Local oStruSF4 as object

    oModel   := Nil
    oStruSF4 := FWFormStruct(1, "SF4")

    oModel := MPFormModel():New('FSMA055', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('SF4MASTER',/*cOwner*/,oStruSF4)

    oModel:GetModel('SF4MASTER'):SetDescription("Tipos de Entrada e Saida")

    oModel:SetDescription("Tipos de Entrada e Saida")

Return oModel
