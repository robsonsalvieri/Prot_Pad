#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME FSMORCAMENTO source FSMA013 RESOURCE OBJECT FsmRestModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Tipos de Servicos
@author Vitor Kwon
@since 19/01/2023
@version 1.0
@obs FSMA013

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel	:= Nil
Local oStruJN7	:= FWFormStruct(1,"JN7")
Local oStruJN9	:= FWFormStruct(1,"JN9")
Local oStruJNA	:= FWFormStruct(1,"JNA")
Local oStruJNB	:= FWFormStruct(1,"JNB")

oStruJN9:AddField("Descr.Servico","Descr.Servico","JN9_DSCJN1","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oStruJN9:SetProperty("JN9_DSCJN1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JN9->JN9_CODJN1,"JN1_DESCRI"),"")'))

oModel := MPFormModel():New('FSMA013', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('JN7MASTER',/*cOwner*/,oStruJN7)

oModel:AddGrid( 'JN9DETAIL', 'JN7MASTER', oStruJN9)

oModel:AddGrid( 'JNADETAIL', 'JN9DETAIL', oStruJNA)

oModel:AddGrid( 'JNBDETAIL', 'JN7MASTER', oStruJNB)

oModel:SetPrimaryKey({"JN7_FILIAL","JN7_CODIGO"})

oModel:SetRelation('JN9DETAIL', {{'JN9_FILIAL', 'xFilial("JN9")'};
                              ,  {'JN9_CODJN7', 'JN7_CODIGO'    }};
                              ,  JN9->(IndexKey(2)) )

oModel:SetRelation('JNADETAIL', {{'JNA_FILIAL', 'xFilial("JNA")'};
                              ,  {'JNA_CODJN9', 'JN9_CODIGO'    }};
                              ,  JNA->(IndexKey(2)) )

oModel:SetRelation('JNBDETAIL', {{'JNB_FILIAL', 'xFilial("JNB")'};
                              ,  {'JNB_CODJN7', 'JN7_CODIGO'    }};
                              ,  JNB->(IndexKey(2)) )

oModel:SetDescription('Orcamento')

oModel:GetModel('JN7MASTER'):SetDescription("Orcamento")

oModel:GetModel("JN9DETAIL"):SetDescription( 'Produtos' ) 

oModel:GetModel("JNADETAIL"):SetDescription( 'items' ) 

oModel:GetModel("JNBDETAIL"):SetDescription( 'pagamentos' ) 

oModel:GetModel("JN9DETAIL"):SetOptional(.T.)

oModel:GetModel("JNADETAIL"):SetOptional(.T.)

oModel:GetModel("JNBDETAIL"):SetOptional(.T.)

oStruJN7:SetProperty("JN7_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN7","JN7_CODIGO")'))
                   
oStruJN9:SetProperty("JN9_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JN9","JN9_CODIGO")'))

oStruJNA:SetProperty("JNA_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNA","JNA_CODIGO")'))
                     
oStruJNA:SetProperty("JNA_REQUIS",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'2'))

oStruJNB:SetProperty("JNB_CODIGO",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD, 'GetSxEnum("JNB","JNB_CODIGO")'))


Return oModel


