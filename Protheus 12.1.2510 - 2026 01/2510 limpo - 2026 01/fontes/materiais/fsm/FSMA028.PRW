#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMTIPOSCANCELAMENTO source FSMA028 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil

Local oStruJNL	:= FWFormStruct(1,"JNL")


oModel := MPFormModel():New('FSMA028', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JNLMASTER',/*cOwner*/,oStruJNL)

oModel:getModel('JNLMASTER'):SetDescription("Cancelamento de deslocamento")
                        
oModel:SetDescription('Cancelamento de deslocamento')

oModel:SetPrimaryKey( { "JNL_FILIAL", "JNL_CODIGO" } )

oStruJNL:SetProperty("JNL_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNL","JNL_CODIGO")'))
                     

                  
Return oModel


    