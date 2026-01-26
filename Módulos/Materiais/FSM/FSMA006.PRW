#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMFORNECEDOR source FSMA006 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local cCampos   := "A2_COD|A2_LOJA|A2_NOME|A2_NREDUZ|"
Local oStruSA2	:= FWFormStruct(1,"SA2", {|cCampo| AllTrim(cCampo)+ "|" $ cCampos})

oModel := MPFormModel():New('FSMA006', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('SA2MASTER',/*cOwner*/,oStruSA2)

oModel:SetDescription('Fornecedores')
oModel:GetModel('SA2MASTER'):SetDescription("Fornecedores")


Return oModel
