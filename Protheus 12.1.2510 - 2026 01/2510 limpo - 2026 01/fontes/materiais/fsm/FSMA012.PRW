#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMHISTORICOBASE source FSMA012
Static Function ModelDef()

Local oModel	:= Nil
Local oStruAA3	:= FwFormStruct(1, "AA3")
Local oStruJN3  := FwFormStruct(1, "JN3")

oStruAA3:AddField("Nome Fornecedor","Nome Fornecedor","AA3_NOMFOR","C",TamSx3('A2_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruAA3:AddField("Nome Fabricante","Nome Fabricante","AA3_NOMFAB","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oModel := MPFormModel():New('FSMA012', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('AA3MASTER',/*cOwner*/, oStruAA3)
oModel:AddGrid( 'JN3DETAIL', 'AA3MASTER', oStruJN3)

oModel:SetRelation('JN3DETAIL', {{'JN3_FILIAL', 'xFilial("JN3")'},;
                                {'JN3_CODPRO', 'AA3_CODPRO'},;
                                {'JN3_NUMSER', 'AA3_NUMSER'}},;
                                 JN3->(IndexKey(2)))

oModel:SetDescription('Histórico da base de atendimento')
oModel:GetModel('AA3MASTER'):SetDescription("Base de atendimento")

oStruAA3:SetProperty("AA3_OBS",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,''))

oStruAA3:SetProperty("AA3_NOMFAB",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+AA3->AA3_CODFAB+AA3->AA3_LOJAFA,"A1_NOME"),"")'))

oStruAA3:SetProperty("AA3_NOMFOR",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA2",1,xFilial("SA2")+AA3->AA3_FORNEC+AA3->AA3_LOJAFO,"A2_NOME"),"")'))

oModel:SetPrimaryKey({"AA3_CODCLI","AA3_LOJA","AA3_CODPRO","AA3_NUMSER"})

oModel:GetModel("JN3DETAIL"):SetOptional(.T.)  


Return oModel
