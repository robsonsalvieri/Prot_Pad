#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMOSCHECK source FSMA022 RESOURCE OBJECT FsmRestModel

Static Function ModelDef()

Local oModel	:= Nil
Local oStrJNR   := FWFormStruct(1,"JNR")

oStrJNR:AddField("Descr.Checklist","Descr.Checklist","JNR_DSCJND","C",TamSx3('JND_TITULO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStrJNR:AddField("Chave Unica","Chave Unica","JNR_JNNPK","C",100,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oStrJNR:SetProperty("JNR_DSCJND",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JND",1,xFilial("JND")+JNR->JNR_CODJND+JNR->JNR_VERSAO,"JND_TITULO"),"")'))
oStrJNR:SetProperty("JNR_JNNPK", MODEL_FIELD_INIT, {|| Encode64(JNR->JNR_FILIAL+JNR->JNR_CODJNN)})


oModel := MPFormModel():New('FSMA022', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JNRMASTER',/*cOwner*/,oStrJNR)

oModel:SetPrimaryKey({"JNR_CODIGO"})

oModel:SetDescription('Checklist da Ordem de Serviço')

oModel:GetModel('JNRMASTER'):SetDescription("Checklist da Ordem de Serviço")

Return oModel
