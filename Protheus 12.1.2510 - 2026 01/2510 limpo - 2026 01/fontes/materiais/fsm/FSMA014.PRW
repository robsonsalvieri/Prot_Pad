#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMFUNCOES source FSMA014 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruSRJ	:= FwFormStruct(1, "SRJ")

oModel := MPFormModel():New('FSMA014', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SRJMASTER',/*cOwner*/, oStruSRJ)

oModel:SetDescription('Cadastro de Funções')
oModel:GetModel('SRJMASTER'):SetDescription("Cadastro de Funções")


Return oModel
