#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


PUBLISH MODEL REST NAME FSMREPROVACAOESTOQUE source FSMA034 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil
Local oStruJO5	:= FWFormStruct(1,"JO5")


oModel := MPFormModel():New('FSMA034', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JO5MASTER',/*cOwner*/,oStruJO5)

oModel:getModel('JO5MASTER'):SetDescription("Reprovação do Estoque")
                        
oModel:SetDescription("Reprovação do Estoque")

oModel:SetPrimaryKey( { "JO5_FILIAL", "JO5_CODIGO" } )

oStruJO5:SetProperty("JO5_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JO5","JO5_CODIGO")'))
                     

Return oModel
