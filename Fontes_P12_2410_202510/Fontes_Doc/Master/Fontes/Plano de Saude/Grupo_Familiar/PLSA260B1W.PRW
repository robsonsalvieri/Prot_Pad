#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260B1W
Browse de Grupo de Rol de Procedimentos
@author Robson Nayland Benjamim
@since  06/07/2023
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260B1W(lAutomato)

// Declaração de Variáveis
Local oBrowse
Default lAutomato := .F.

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA260B1W' )
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo de dados de Situações Adversas
@author  Robson Nayland Benjamim
@since   10/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

// Declaração de Variáveis
Local oModel	
Local oStruBA1 		:= FWFormStruct(1,'BA1')
Local oStruB1W		:= FWFormStruct(1,'B1W')

Local aCamposBA1	:= {'BA1_CODINT','BA1_CODEMP','BA1_MATRIC'} // Campos a serem adicionado na estrutura
Local nNx

// Cria o objeto do Modelo de Dados	 
oModel := MPFormModel():New('PLSA260B1W')

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx])
Next

// Adiciona as estruturas no modelo
oModel:addFields('BA1MASTER' ,NIL,oStruBA1) 
oModel:AddGrid('B1WDETAIL','BA1MASTER',oStruB1W)

// Permissão de grid sem dados
oModel:GetModel('B1WDETAIL'):SetOptional(.T.)

// Relacionamento entre as tabelas
oModel:SetRelation( 'B1WDETAIL', {  { 'B1W_FILIAL'  , 'xFilial( "B1W" )'},;
								    { 'B1W_CODINT'	, 'BA1_CODINT' } ,;
                                    { 'B1W_CODEMP'	, 'BA1_CODEMP' } ,;
                                    { 'B1W_MATRIC'	, 'BA1_MATRIC' }} ,;
								B1W->( IndexKey( ) ) ) 				
	
oModel:SetDescription( FunDesc() )	// Descrição do Modelo de dados

oModel:GetModel('B1WDETAIL'):SetUniqueLine({'B1W_TIPREG'}) 

// Descrição de cada modelo usado
oModel:GetModel('BA1MASTER'):SetDescription('Beneficiário' )
oModel:GetModel('B1WDETAIL'):SetDescription('Grupo de Rol de Procedimentos')	

// Não permite alteração ou inclusão no modelo
oModel:GetModel('BA1MASTER'):SetOnlyQuery(.T.)
oModel:GetModel('BA1MASTER'):SetOnlyView(.T.)


oStruB1W:setProperty( 'B1W_TIPREG', MODEL_FIELD_INIT,  { || BA1->BA1_TIPREG })

//Validação de linha duplicada
oModel:GetModel( 'B1WDETAIL' ):SetUniqueLine( { 'B1W_TIPREG', 'B1W_CODGRU' , 'B1W_MESAGR',  'B1W_UNAGR '} )


oModel:SetPrimaryKey( { 'B1W_FILIAL', 'B1W_CODINT', 'B1W_CODEMP', 'B1W_MATRIC' } )

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View Grupo de Rol de Procedimentos
@author  Robson Nayland Benjamim
@since   06/07/2023
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

// Declaração de Variáveis
Local oStruBA1      := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR' } )
Local oStruB1W      := FWFormStruct(2,'B1W')	
Local oModel        := FWLoadModel( 'PLSA260B1W') // Carrega o modelo
Local oView
Local aCamposBA1    := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

oView := FWFormView():New() // Cria o Objeto View

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
	oStruBA1 := CriaCampMVC(2,oStruBA1,aCamposBA1[nNx],StrZero(nNx,2))
Next

oView:SetModel( oModel )


oView:AddField( 'VIEW_BA1' , oStruBA1, 'BA1MASTER' )
oView:AddGrid(  'VIEW_B1W' , oStruB1W, 'B1WDETAIL' )

oStruBA1:SetNoFolder() // Retirando as pastas de uma estrutura

oView:CreateHorizontalBox( 'SUPERIOR', 35) 
oView:CreateHorizontalBox( 'INFERIOR', 65) 

oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
oView:SetOwnerView('VIEW_B1W', 'INFERIOR')	


oView:EnableTitleView('VIEW_BA1','Beneficiário')
oView:EnableTitleView('VIEW_B1W','Grupo de Rol de Procedimentos')

Return oView      

