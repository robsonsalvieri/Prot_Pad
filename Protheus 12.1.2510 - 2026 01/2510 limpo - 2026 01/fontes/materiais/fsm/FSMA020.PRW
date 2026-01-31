#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMMOTIVOSPAUSA source FSMA020 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Motivos de Pausas
@author Alexandre Takaki
@since 09/09/2024
@version 1.0
@obs FSMA020
/*/
//------------------------------------------------------------------------
Static Function ModelDef()

    Local oModel	:= Nil
    Local oStruJNM	:= FWFormStruct(1,"JNM")
    
    oModel := MPFormModel():New('FSMA020', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('JNMMASTER',/*cOwner*/,oStruJNM)

    oModel:SetDescription('Motivos de Pausa')
    oModel:GetModel('JNMMASTER'):SetDescription("Motivos de Pausa")

Return oModel
