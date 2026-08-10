#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMPARAMETRO source FSMA023 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JNU - Parâmetros SIGAFSM
@author flavio.martins
@since 03/10/2024
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrJNU   := FWFormStruct(1,"JNU")

oModel := MPFormModel():New('FSMA023', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JNUMASTER',/*cOwner*/,oStrJNU)

oModel:SetPrimaryKey({"JNU_CODPAR"})

oModel:SetDescription('Parâmetros - SIGAFSM')

oModel:GetModel('JNUMASTER'):SetDescription("Parâmetros - SIGAFSM")

Return oModel
