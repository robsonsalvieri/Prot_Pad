#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMLAUDO source FSMA025 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@Laudo da OS
@since 15/12/2024
@version 1.0
@obs FSMA025
/*/
//------------------------------------------------------------------------
Static Function ModelDef()


    Local oModel	:= Nil
    Local oStruJNY	:= FWFormStruct(1,"JNY")

    oModel := MPFormModel():New('FSMA025', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('JNYMASTER',/*cOwner*/,oStruJNY)

    oModel:SetDescription('Laudo')
    oModel:GetModel('JNYMASTER'):SetDescription("Laudo")

    oStruJNY:SetProperty("JNY_CODIGO",MODEL_FIELD_INIT,;
            FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNY","JNY_CODIGO")'))
            

Return oModel
