#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMPASSO source FSMA060 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOVMASTER - Passos - Fluxo de Atendimento
@author flavio.martins
@since 11/08/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruJOV := FWFormStruct(1,"JOV")

oModel := MPFormModel():New('FSMA060', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOVMASTER',/*cOwner*/,oStruJOV)
oModel:SetPrimaryKey({"JOV_CODIGO"})

oModel:SetDescription('Passos - Fluxo de Atendimento')

oModel:GetModel('JOVMASTER'):SetDescription("Passos - Fluxo de Atendimento")

Return oModel
