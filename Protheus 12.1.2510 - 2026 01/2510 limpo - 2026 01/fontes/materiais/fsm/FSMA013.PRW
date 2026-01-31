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
Local oStruJNB	:= FWFormStruct(1,"JNB", {|cCpo| !(AllTrim(cCpo))$ "JNB_DSCPAG|" })

oStruJN7:AddField("Nome", "Nome", "JN7_CLINOM","C",TamSx3('A1_NOME')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("Nome Reduz.", "Nome Reduz.", "JN7_NREDUZ","C",TamSx3('A1_NREDUZ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("Doc. Cliente", "Doc.Cliente", "JN7_CLIDOC","C",TamSx3('A1_CGC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("Nome Contato", "Nome Contato", "JN7_CLICNT","C",TamSx3('A1_CONTATO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("DDD Cliente", "DDD Cliente", "JN7_CLIDDD","C",TamSx3('A1_DDD')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("Tel. Cliente", "Tel. Cliente", "JN7_CLITEL","C",TamSx3('A1_TEL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN7:AddField("Email Cliente", "Email Cliente", "JN7_CLIEML","C",TamSx3('A1_EMAIL')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	
oStruJN9:AddField("Descr.Servico","Descr.Servico","JN9_DSCJN1","C",TamSx3('JN1_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						
oStruJNB:AddField("Descr. C.Pagto","Descr. C.Pagto","JNB_DSCSE4","C",TamSx3('E4_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)						

oStruJN7:SetProperty("JN7_NREDUZ",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_NREDUZ"),"")'))

oStruJN7:SetProperty("JN7_CLINOM",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_NOME"),"")'))

oStruJN7:SetProperty("JN7_CLIDOC",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_CGC"),"")'))

oStruJN7:SetProperty("JN7_CLICNT",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_CONTATO"),"")'))

oStruJN7:SetProperty("JN7_CLIDDD",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_DDD"),"")'))

oStruJN7:SetProperty("JN7_CLITEL",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_TEL"),"")'))

oStruJN7:SetProperty("JN7_CLIEML",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SA1",1,xFilial("SA1")+JN7->JN7_CLIENT+JN7->JN7_LOJA,"A1_EMAIL"),"")'))

oStruJN7:SetProperty("JN7_DESEST",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'FSM13RetUF()'))

oStruJN7:SetProperty("JN7_DESCID",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'FSM13RetCid()'))

oStruJN9:SetProperty("JN9_DSCJN1",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("JN1",1,xFilial("JN1")+JN9->JN9_CODJN1,"JN1_DESCRI"),"")'))

oStruJNB:SetProperty("JNB_DSCSE4",MODEL_FIELD_INIT,;
                     FwBuildFeature(STRUCT_FEATURE_INIPAD,'If(!INCLUI,Posicione("SE4",1,xFilial("SE4")+JNB->JNB_CONPAG,"E4_DESCRI"),"")'))

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

Function FSM13RetUF()
Local cEstado := ''

SA1->(dbSetOrder(1))

If SA1->(dbSeek(xFilial('SA1')+JN7->JN7_CLIENT+JN7->JN7_LOJA))

    If !Empty(SA1->A1_EST)

        cEstado := POSICIONE('SX5',1,XFILIAL('SX5')+'12'+SA1->A1_EST,'X5_DESCRI')

    Endif

Endif

Return cEstado

Function FSM13RetCid()
Local cCidade := ''

SA1->(dbSetOrder(1))

If SA1->(dbSeek(xFilial('SA1')+JN7->JN7_CLIENT+JN7->JN7_LOJA))

    If !Empty(SA1->A1_COD_MUN)

        cCidade := POSICIONE("CC2",1,XFILIAL("CC2")+SA1->A1_EST+SA1->A1_COD_MUN, "CC2_MUN")                                                                     

    Endif

Endif

Return cCidade
