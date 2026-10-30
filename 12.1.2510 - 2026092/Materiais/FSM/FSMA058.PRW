#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMENDARMZ source FSMA058 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela SBEMASTER - Endereços Armazém
@author flavio.martins
@since 20/07/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruSBE := FWFormStruct(1,"SBE")

oModel := MPFormModel():New('FSMA058', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SBEMASTER',/*cOwner*/,oStruSBE)
oModel:SetPrimaryKey({"BE_LOCAL", "BE_LOCALIZ"})

oModel:SetDescription('Endereços Armazém - SIGAFSM')

oModel:GetModel('SBEMASTER'):SetDescription("Endereços Armazém - SIGAFSM")

Return oModel
