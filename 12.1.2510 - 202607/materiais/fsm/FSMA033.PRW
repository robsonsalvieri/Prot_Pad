#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


PUBLISH MODEL REST NAME FSMREJEICAOESTOQUE source FSMA033 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStruJO6	:= FWFormStruct(1,"JO6")


oModel := MPFormModel():New('FSMA033', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JO6MASTER',/*cOwner*/,oStruJO6)

oModel:getModel('JO6MASTER'):SetDescription("Motivos de Rejeição dp Estoque")
                        
oModel:SetDescription("Motivos de Rejeição do Estoque")

oModel:SetPrimaryKey( { "JO6_FILIAL", "JO6_CODIGO" } )

oStruJO6:SetProperty("JO6_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO6","JO6_CODIGO")'))
                     

Return oModel
