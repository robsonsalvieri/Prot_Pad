#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME FSMSERVICO source FSMA004 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Tipos de Servicos
@author Vitor Kwon
@since 06/11/2023
@version 1.0
@obs FSMA004

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel    := NIL
Local oStRJN1   := FWFormStruct( 1, "JN1" )
Local oStRJNZ   := FWFormStruct( 1, "JNZ" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------

oStRJNZ:AddField("Descr. Grupo","Descr. Grupo","JNZ_DSCGRP","C",TamSx3('BM_DESC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oStRJNZ:SetProperty("JNZ_DSCGRP",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SBM",1,xFilial("SBM")+JNZ->JNZ_GRUPO,"BM_DESC"),"")'))

oModel:= MPFormModel():New( "FSMA004", /*Pre-Validacao*/, /*Pos-Validacao*/,,/*Commit*/,/*Cancel*/)

oModel:AddFields( "MASTERJN1", NIL, oStRJN1, /*Pre-Validacao*/, /*Pos-Validacao*/ )

oModel:AddGrid( 'JNZDETAIL', 'MASTERJN1', oStRJNZ)

oModel:SetRelation('JNZDETAIL', {{ 'JNZ_FILIAL', 'xFilial("JNZ")' }, { 'JNZ_CODJN1', 'JN1_CODIGO' } }, JNZ->(IndexKey(2)) )

oModel:SetDescription( 'Tipos de Servico' ) 

oModel:GetModel( "MASTERJN1" ):SetDescription( 'Tipos de Servico' ) 
oModel:GetModel( "JNZDETAIL" ):SetDescription( 'Grupos de Servico' ) 

oModel:SetPrimaryKey({"JN1_FILIAL","JN1_CODIGO"})

oModel:GetModel("JNZDETAIL"):SetOptional(.T.)



Return oModel
