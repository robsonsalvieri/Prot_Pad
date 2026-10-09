#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BH5
Funcao para abrir a tela de cadastro de Gratuidade da Familia
@author DEV TOTVS
@since 28/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BH5(lAutomato)

	Local oBrowse
	Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BH5' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BH5 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BH5 
@author  DEV TOTVS
@version P12
@since   28/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel
	Local oStruBA3		:= FWFormStruct(1,'BA3')
	Local oStruBH5 		:= FWFormStruct(1,'BH5')
	Local oEvent   		:= PL260BH5EVDEF():New()

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BH5')

	oModel:addFields('BA3MASTER' , ,oStruBA3) 
   	oModel:AddGrid(  'BH5DETAIL' , 'BA3MASTER', oStruBH5 )
	
	oModel:GetModel( "BH5DETAIL" ):SetOptional( .T. )
	
    oStruBH5:RemoveField('BH5_NOMRES')

	oModel:SetRelation( 'BH5DETAIL', { { 'BH5_FILIAL' 	, 'xFilial( "BH5" )' },;
									{ 'BH5_CODINT'	, 'BA3_CODINT' },;
									{ 'BH5_CODEMP'	, 'BA3_CODEMP' },;
									{ 'BH5_MATRIC'	, 'BA3_MATRIC'} },;									
									BH5->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( 'BA3MASTER' ):SetDescription( 'Familia' )
    oModel:GetModel( 'BH5DETAIL' ):SetDescription( 'Gratuidade da Familia' )	

	oModel:GetModel( 'BA3MASTER' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'BA3MASTER' ):SetOnlyView(.T.)	

	oStruBH5:setProperty( 'BH5_CODINT', MODEL_FIELD_INIT, { || BA3->(BA3_CODINT)} )
	oStruBH5:setProperty( 'BH5_CODEMP', MODEL_FIELD_INIT, { || BA3->(BA3_CODEMP)} )
    oStruBH5:setProperty( 'BH5_USUARI', MODEL_FIELD_INIT, { || BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)} )
    
	oModel:SetPrimaryKey( { "BH5_FILIAL", "BH5_CODINT", "BH5_CODEMP", "BH5_MATRIC","BH5_CODGRA" } )

 
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P2
@since   28/08/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA3 := FWFormStruct(2,'BA3', { |cCampo| AllTrim(cCampo) $ 'BA3_CODINT|BA3_CODEMP|BA3_MATRIC|' } )
	Local oStruBH5 := FWFormStruct(2,'BH5')	
    Local oModel   := FWLoadModel( 'PLSA260BH5' )
	Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'BA3MASTER' )
    oView:AddGrid(  'VIEW_BH5' ,  oStruBH5,  'BH5DETAIL' )

    //Retira o campo código da tela 
    oStruBH5:RemoveField('BH5_CODINT')
    oStruBH5:RemoveField('BH5_CODEMP')
    oStruBH5:RemoveField('BH5_MATRIC')
    oStruBH5:RemoveField('BH5_USUARI')
    oStruBH5:RemoveField('BH5_NOMRES')
    oStruBH5:RemoveField('BH5_USUOPE')    
    
    oStruBA3:SetNoFolder()
   	oStruBH5:SetNoFolder()

	oView:CreateHorizontalBox( 'SUPERIOR', 20 )
	oView:CreateHorizontalBox( 'INFERIOR', 80 )
	
	oView:EnableTitleView('VIEW_BH5','Gratuidade da Familia')
	
	oView:SetOwnerView( 'VIEW_BA3', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BH5', 'INFERIOR' )
	
	oView:EnableTitleView('VIEW_BA3','Familia')
	oView:EnableTitleView('VIEW_BH5','Gratuidade da Familia')		

Return oView