#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMFLUXOATD source FSMA061 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOWMASTER - Fluxo de Atendimento
@author flavio.martins
@since 14/08/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStruJOW := FWFormStruct(1,"JOW")
Local oStruJOX := FWFormStruct(1,"JOX")

oModel := MPFormModel():New('FSMA061', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oStruJOX:AddField("Descr.Passo","Descr.Passo","JOX_DSCJOV","C",TamSx3('JOV_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOX:AddField("Inicia Atend.","Inicia Atend.","JOX_INIATD","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOX:AddField("Finaliza Atend.","Finaliza Atend.","JOX_FINATD","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOX:AddField("Perm.Pausa","Permite Pausa?","JOX_PAUSA","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOX:AddField("Perm.Pendência","Permite Pendência?","JOX_PENDEN","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJOX:AddField("Perm.Retroc.","Permite Retroceder","JOX_RETROC","L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	

oStruJOX:SetProperty("JOX_DSCJOV",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_DESCRI"),"")'))
oStruJOX:SetProperty("JOX_INIATD",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_INIATD"),"")'))
oStruJOX:SetProperty("JOX_FINATD",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_FINATD"),"")'))
oStruJOX:SetProperty("JOX_PAUSA",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_PAUSA"),"")'))
oStruJOX:SetProperty("JOX_PENDEN",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_PENDEN"),"")'))
oStruJOX:SetProperty("JOX_RETROC",MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOV",1,xFilial("JOV")+JOX->JOX_CODJOV,"JOV_RETROC"),"")'))

oModel:AddFields('JOWMASTER',/*cOwner*/,oStruJOW)
oModel:AddGrid('JOXDETAIL','JOWMASTER',oStruJOX )

oModel:SetRelation('JOXDETAIL', {{'JOX_FILIAL', 'xFilial("JOX")'},;
                                 {'JOX_CODJOW', 'JOW_CODIGO'}},;
                                    JOX->(IndexKey(2)))

oModel:SetPrimaryKey({"JOW_CODIGO"})

oModel:GetModel('JOWMASTER'):SetDescription("Fluxo de Atendimento")
oModel:GetModel('JOXDETAIL'):SetDescription("Fluxo de Atendimento - Passos")

Return oModel
