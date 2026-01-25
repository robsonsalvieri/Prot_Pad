#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMSX5 source FSMA017 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruSX5	:= FwFormStruct(1,"SX5")

oModel := MPFormModel():New('FSMA017', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SX5MASTER',/*cOwner*/, oStruSX5)

oModel:SetDescription('Tabela SX5')
oModel:GetModel('SX5MASTER'):SetDescription("Tabela SX5")
oModel:GetModel('SX5MASTER'):SetOnlyView(.T.)
oModel:SetPrimaryKey({})


Return oModel
