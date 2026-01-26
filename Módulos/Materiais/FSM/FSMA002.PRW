#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMCLIENTES source FSMA002 RESOURCE OBJECT FsmRestModel
Static Function ModelDef()

Local oModel	:= Nil
Local cCampos   := "A1_FILIAL|A1_COD|A1_LOJA|A1_TIPO|A1_PESSOA|A1_CGC|A1_INSCR|A1_MSBLQL|A1_NREDUZ|A1_NOME|A1_TEL|A1_FAX|" +;
                   "A1_EMAIL|A1_CONTATO|A1_CEP|A1_END|A1_COMPLEN|A1_BAIRRO|A1_EST|A1_COD_MUN|A1_CEPC|" +;
                   "A1_ENDCOB|A1_BAIRROC|A1_ESTC|A1_MUNC|A1_COMPLEM|A1_DDD|"
Local oStruSA1	:= FWFormStruct(1,"SA1", {|cCampo| AllTrim(cCampo)+ "|" $ cCampos})
Local oStruJN0	:= FwFormStruct(1,'JN0')

oModel := MPFormModel():New('FSMA002', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)
//oModel:SetVldActivate({|oModel| G460VldAct(oModel)})


oModel:AddFields('SA1MASTER',/*cOwner*/,oStruSA1)
oModel:AddGrid('JN0DETAIL','SA1MASTER',oStruJN0, /*bLinePre*/, /*blinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )

oModel:SetRelation('JN0DETAIL', {{'JN0_FILIAL', 'xFilial("JN0")'},;
                                 {'JN0_CLIENT', 'A1_COD'},;
                                 {'JN0_LOJA', 'A1_LOJA'}},;
                                 JN0->(IndexKey(1)))

oModel:SetDescription('Endereços FSM')
oModel:GetModel('SA1MASTER'):SetDescription("Clientes")

oModel:SetPrimaryKey({"A1_COD", "A1_LOJA"})

		
Return oModel
