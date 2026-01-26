#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCOBERTURAS source FSMA007 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruAAA	:= FWFormStruct(1,"AAA")

oModel := MPFormModel():New('FSMA007', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('AAAMASTER',/*cOwner*/,oStruAAA)

oModel:SetDescription('Coberturas')
oModel:GetModel('AAAMASTER'):SetDescription("Coberturas")


Return oModel
