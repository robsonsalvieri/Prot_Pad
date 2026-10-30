#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMMTVREPROV source FSMA049 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

    Local oModel   as object
    Local oStruJOG as object

    oModel   := Nil
    oStruJOG := FWFormStruct(1, "JOG")

    oModel := MPFormModel():New('FSMA049', /*bPreValid*/, /*bPosValid*/,, /*bCancel*/)
    oModel:AddFields('JOGMASTER',/*cOwner*/,oStruJOG)

    oModel:GetModel('JOGMASTER'):SetDescription("Motivo de Reprovação")

    oModel:SetDescription("Motivo de Reprovação")

    oStruJOG:SetProperty("JOG_CODIGO", MODEL_FIELD_INIT,;
        FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JOG","JOG_CODIGO")'))

Return oModel
