#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCONDPAGTO source FSMA047 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruSE4	:= FWFormStruct(1,"SE4")

oModel := MPFormModel():New('FSMA047', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SE4MASTER',/*cOwner*/,oStruSE4)

oModel:SetDescription('Condição de Pagamento')
oModel:GetModel('SE4MASTER'):SetDescription("Condição de Pagamento")


Return oModel
