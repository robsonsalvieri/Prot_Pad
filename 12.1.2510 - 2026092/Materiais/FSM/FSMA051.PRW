#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMTIPOATENDIMENTO source FSMA051 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOJ - Tipos de Atendimento
@author flavio.martins
@since 09/01/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrJOJ   := FWFormStruct(1,"JOJ")

oModel := MPFormModel():New('FSMA051', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOJMASTER',/*cOwner*/,oStrJOJ)

oModel:SetPrimaryKey({"JOJ_CODIGO"})

oModel:SetDescription('Tipos de Atendimento - SIGAFSM')

oModel:GetModel('JOJMASTER'):SetDescription("Tipos de Atendimento - SIGAFSM")

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} OpcCBoxCor()
Opcões para Combo Box de Cores campo JOJ_CORLEG
@author flavio.martins
@since 06/02/2026
@version 1.0
*/
//-------------------------------------------------------------------
Function OpcCBoxCor()
Local cCombo := ""
 
cCombo += "01=Cor 01;"
cCombo += "02=Cor 02;"
cCombo += "03=Cor 03;"
cCombo += "04=Cor 04;"
cCombo += "05=Cor 05;"
cCombo += "06=Cor 06;"
cCombo += "07=Cor 07;"
cCombo += "09=Cor 08;"
cCombo += "10=Cor 09;"
cCombo += "11=Cor 10;"
cCombo += "12=Cor 11;"
cCombo += "13=Cor 12;"

Return cCombo
