#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMARMAZEMATENDENTE source FSMA037 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local oStruNNR	:= FWFormStruct(1,"NNR")
Local oStruSBE	:= FwFormStruct(1,'SBE')

oModel := MPFormModel():New('FSMA037', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('NNRMASTER',nil,oStruNNR)

oModel:AddGrid('SBEDETAIL','NNRMASTER',oStruSBE )

oModel:SetRelation('SBEDETAIL', {{'BE_FILIAL', 'xFilial("SBE")'},;
                                 {'BE_LOCAL', 'NNR_CODIGO'}},;
                                 SBE->(IndexKey(1)))

oModel:SetDescription('Armazem do atendente')

Return oModel
