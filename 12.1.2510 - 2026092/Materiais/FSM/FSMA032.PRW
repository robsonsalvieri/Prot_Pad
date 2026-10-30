#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMUNIDADEMEDIDA source FSMA032 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel    := Nil
Local oStruSAH  := FWFormStruct(1,"SAH")

oModel := MPFormModel():New('FSMA032', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SAHMASTER',/*cOwner*/, oStruSAH)

oModel:SetPrimaryKey({"AH_UNIMED"})

oModel:SetDescription('Cadastro de unidades de medida')
oModel:GetModel('SAHMASTER'):SetDescription("Cadastro de unidades de medida")


Return oModel
