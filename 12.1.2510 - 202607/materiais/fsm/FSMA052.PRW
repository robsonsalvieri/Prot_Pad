#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PARMTYPE.CH"

PUBLISH MODEL REST NAME FSMTIPOOCORRENCIA source FSMA052 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo da tabela JOK - Tipos de Ocorrência
@author flavio.martins
@since 19/01/2026
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStrJOK   := FWFormStruct(1,"JOK")

oStrJOK:AddField("Descr. Atend.","Descr. Atend.","JOK_DSCJOJ","C",TamSx3('JOJ_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)
oStrJOK:AddField("Cor Leg.","Cor Leg.","JOK_CORLEG","C",TamSx3('JOJ_CORLEG')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)

oStrJOK:SetProperty("JOK_DSCJOJ",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOJ",1,xFilial("JOJ")+JOK->JOK_CODJOJ,"JOJ_DESCRI"),"")'))
oStrJOK:SetProperty("JOK_CORLEG",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JOJ",1,xFilial("JOJ")+JOK->JOK_CODJOJ,"JOJ_CORLEG"),"")'))

oModel := MPFormModel():New('FSMA052', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JOKMASTER',/*cOwner*/,oStrJOK)
oModel:SetPrimaryKey({"JOK_CODIGO"})

oModel:SetDescription('Tipos de Ocorrência - SIGAFSM')

oModel:GetModel('JOKMASTER'):SetDescription("Tipos de Ocorrência - SIGAFSM")

Return oModel
