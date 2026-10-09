#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME TFSMAGENDAS source FSMA027 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()
Local oModel	:= Nil

Local oStruJN6	:= FWFormStruct(1,"JN6")

oModel := MPFormModel():New('FSMA027', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)

oModel:AddFields('JN6MASTER',/*cOwner*/,oStruJN6)

oModel:getModel('JN6MASTER'):SetDescription("Agendas")
                        
oModel:SetDescription('Agendas dos atendentes')

oStruJN6:SetProperty("JN6_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN6","JN6_CODIGO")'))
                     
                  
Return oModel

