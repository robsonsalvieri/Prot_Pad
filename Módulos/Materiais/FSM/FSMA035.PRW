#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


PUBLISH MODEL REST NAME FSMAREPROVAORCA source FSMA035 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStruJO7	:= FWFormStruct(1,"JO7")


oModel := MPFormModel():New('FSMA035', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JO7MASTER',/*cOwner*/,oStruJO7)

oModel:getModel('JO7MASTER'):SetDescription("Reprovação do Orçamento")
                        
oModel:SetDescription("Reprovação do Orçamento")

oModel:SetPrimaryKey( { "JO7_FILIAL", "JO7_CODIGO" } )

oStruJO7:SetProperty("JO7_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO7","JO7_CODIGO")'))

Return oModel

