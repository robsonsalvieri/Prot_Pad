#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TECA450.CH"

Function TECA450B()
Local oBrowse       := Nil
Private cCadastro   := STR0121 //"Responsavel da O.S"
Private aRotina     := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse :SetAlias('SA1')
oBrowse :SetDescription(STR0121) //"Responsavel da O.S"
oBrowse :Activate()

Return(Nil)

Static Function MenuDef()  

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002   ACTION 'PesqBrw'			    OPERATION 1	ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003   ACTION 'VIEWDEF.TECA450B'	OPERATION 2	ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0120   ACTION 'VIEWDEF.TECA450B'	OPERATION 4	ACCESS 0 //""Vincular Responsavel""

Return (aRotina)

Static Function ModelDef()
Local oModel        := Nil
Local oStruSA1		:= FWFormStruct(1,'SA1',{|cCampo| AllTrim(cCampo)+"|" $ "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|"})
Local oStruJNW  	:= FWFormStruct(1,'JNW')

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('TECA450B',/*bPreValidacao*/,/*{|oMdl| At080IncOk(oMdl)}*/,/*bCommit*/,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields('SA1MASTER',/*cOwner*/,oStruSA1,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por grid
oModel:AddGrid( 'JNWGRID','SA1MASTER',oStruJNW,/*bPreValidacao*/,/*bLinePost*/,/*bCarga*/,/*bPost*/) // Adiciona uma Grid ao modelo

// Faz relaciomanto entre os compomentes do model
oModel:SetRelation("JNWGRID",{{"JNW_FILIAL",'xFilial("JNW")'},{"JNW_CODCLI","A1_COD"},{"JNW_LOJA","A1_LOJA"}},JNW->(IndexKey(1)))

//Chave primaria para a entidade principal do modelo de dados.
oModel:SetPrimaryKey({'JNW_FILIAL','JNW_CODCLI', 'JNW_LOJA', 'JNW_CODIGO'}) 

oModel:GetModel('SA1MASTER'):SetOnlyView(.T.)

Return oModel

Static Function ViewDef()
Local oView
Local oModel   	:= FWLoadModel('TECA450B')
Local oStruSA1 	:= FWFormStruct(2,'SA1',{|cCampo| AllTrim(cCampo)+"|" $ "A1_FILIAL|A1_COD|A1_LOJA|A1_NOME|"})
Local oStruJNW	:= FWFormStruct(2,'JNW')

oStruJNW:RemoveField("JNW_CODCLI")
oStruJNW:RemoveField("JNW_LOJA")  
oStruJNW:RemoveField("JNW_CODIGO")

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CAB',oStruSA1,'SA1MASTER')
oView:AddGrid('VIEW_GRID',oStruJNW,'JNWGRID')
oView:AddIncrementField('VIEW_GRID','JNW_ITEM')

oView:CreateHorizontalBox('SUPERIOR',30)
oView:CreateHorizontalBox('INFERIOR',70)

oView:SetOwnerView('VIEW_CAB','SUPERIOR')
oView:SetOwnerView('VIEW_GRID','INFERIOR')
oView:HideFolder("VIEW_CAB",1,1)

Return (oView)
