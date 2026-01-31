#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMTIPODESPESA source FSMA040 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruJOD	:= FWFormStruct(1,"JOD")

    oModel := MPFormModel():New('FSMA040', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('JODMASTER',/*cOwner*/,oStruJOD)

    oModel:GetModel('JODMASTER'):SetDescription("Tipo de despesa")

    oModel:SetDescription("Tipo de despesa")

    oModel:SetPrimaryKey( { "JOD_FILIAL", "JOD_CODIGO" } )

    oStruJOD:SetProperty("JOD_CODIGO", MODEL_FIELD_INIT,;
        FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOD","JOD_CODIGO")'))

Return oModel
