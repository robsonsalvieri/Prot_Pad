#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMEVENTOS source FSMA018 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Eventos
@author Alexandre Takaki
@since 11/09/2024
@version 1.0
@obs FSMA018
/*/
//------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel	:= Nil
    Local oStruJNK	:= FWFormStruct(1,"JNK")

    oModel := MPFormModel():New('FSMA018', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('JNKMASTER',/*cOwner*/,oStruJNK)

    oModel:SetDescription('Eventos')
    oModel:GetModel('JNKMASTER'):SetDescription("Eventos")

Return oModel
