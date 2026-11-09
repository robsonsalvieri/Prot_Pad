#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMESTADOCONSERVACAO source FSMA029 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel    := Nil
Local oStruJO1  := FWFormStruct(1,"JO1")
Local bPosValid	:= {|oModel| PosValid(oModel)}

oModel := MPFormModel():New('FSMA029', /*bPreValid*/, bPosValid, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JO1MASTER',/*cOwner*/, oStruJO1)

oModel:SetPrimaryKey({"JO1_CODIGO"})

oModel:SetDescription('Cadastro de estados de conservação')
oModel:GetModel('JO1MASTER'):SetDescription("Cadastro de estados de conservação")

Return oModel

Static Function PosValid(oModel)
Local lRet 	:= .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT 

If (ExistCpo("JO1", oModel:GetModel('JO1MASTER'):GetValue("JO1_CODIGO")))
        lRet := .F.
        oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","Valida Código", "Código já cadastrado", "Informe outro código para o registro")

    EndIf

EndIf

 
Return lRet
