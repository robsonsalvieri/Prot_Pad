#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMPENDENCIASCLI source FSMA009 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Pendencias do cliente
@author Alexandre Takaki
@since 24/09/2024
@version 1.0
@obs FSMA009
/*/
//------------------------------------------------------------------------
Static Function ModelDef()
    Local oModel	:= Nil
    Local oStruJNS	:= FWFormStruct(1,"JNS")

    oModel := MPFormModel():New('FSMA009', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

    oModel:AddFields('JNSMASTER',/*cOwner*/,oStruJNS)

    oModel:SetDescription('Pendencias do Cliente')
    oModel:GetModel('JNSMASTER'):SetDescription("Pendencias do Cliente")
        oModel:SetPrimaryKey( { "JNS_FILIAL", "JNS_CODIGO" } )

Return oModel
