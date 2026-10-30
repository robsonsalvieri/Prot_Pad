#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMESTOQUE source FSMA019 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruSB1	:= FwFormStruct( 1, "SB1")
Local oStruSB2  := FwFormStruct( 1, "SB2")

oModel := MPFormModel():New('FSMA019', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SB1MASTER',/*cOwner*/, oStruSB1)

oModel:AddGrid('SB2DETAIL', 'SB1MASTER', oStruSB2)

oModel:SetRelation('SB2DETAIL', {{'B2_FILIAL', 'xFilial("SB2")'},;
                                {'B2_COD', 'B1_COD'}},;
                                 SB2->(IndexKey(1)))

oModel:AddCalc('CALC_SALDO', 'SB1MASTER', 'SB2DETAIL', 'B2_QATU', 'TOT_ESTOQUE', 'SUM',{ | | .T.},,"Estoque")

oModel:SetDescription('Estoque dos produtos')
oModel:GetModel('SB1MASTER'):SetDescription("Estoque dos produtos")

//oModel:SetPrimaryKey({"B1_COD"})

oModel:GetModel("SB2DETAIL"):SetOptional(.T.)  


Return oModel
