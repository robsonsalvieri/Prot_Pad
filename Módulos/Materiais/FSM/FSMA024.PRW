#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMAPONTAMENTOHORAS source FSMA024 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Motivos de Pausas
@author Alexandre Takaki
@since 22/10/2024
@version 1.0
@obs FSMA024
/*/
//------------------------------------------------------------------------
Static Function ModelDef()


    Local oModel	:= Nil
    Local oStruJNV	:= FWFormStruct(1,"JNV")

    
    oModel := MPFormModel():New('FSMA024', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('JNVMASTER',/*cOwner*/,oStruJNV)

    oModel:SetDescription('Apontamento de Horas')
    oModel:GetModel('JNVMASTER'):SetDescription("Apontamento de Horas")

    oStruJNV:SetProperty("JNV_CODIGO",MODEL_FIELD_INIT,;
            FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNV","JNV_CODIGO")'))
            

Return oModel
