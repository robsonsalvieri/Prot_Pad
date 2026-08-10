#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


PUBLISH MODEL REST NAME FSMARQUIVAORCAMENTO source FSMA036 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStruJO8	:= FWFormStruct(1,"JO8")


oModel := MPFormModel():New('FSMA036', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JO8MASTER',/*cOwner*/,oStruJO8)

oModel:getModel('JO8MASTER'):SetDescription("Arquivamento do Orçamento")
                        
oModel:SetDescription("Arquivamento do Orçamento")

oModel:SetPrimaryKey( { "JO8_FILIAL", "JO8_CODIGO" } )

oStruJO8:SetProperty("JO8_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO8","JO8_CODIGO")'))

Return oModel

