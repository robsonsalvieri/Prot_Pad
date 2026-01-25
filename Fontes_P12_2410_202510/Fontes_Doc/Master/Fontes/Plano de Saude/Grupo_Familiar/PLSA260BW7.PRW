#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BW7
Funcao para abrir a tela de Cobertura da Familia - Grupos de Quantidades
@author Totver
@since 10/09/19
@version P12
/*/
//-----------------------------------------------------------------------
Function PLSA260BW7(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BW7' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BW7 
@author  Totver
@version P12
@since   10/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BW7 
@author  Totver
@version P12
@since   10/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA3 		:= FWFormStruct(1,"BA3")
	Local oStruBW7 		:= FWFormStruct(1,"BW7")
	Local aCamposBW7	:= {"BW7_CODINT","BW7_CODEMP","BW7_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
		
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BW7')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBW7)
		oStruBW7 := CriaCampMVC(1,oStruBW7,aCamposBW7[nNx]) 
	Next
    
	oModel:addFields("BA3MASTER" , ,oStruBA3) 
   	oModel:AddGrid(  "BW7DETAIL" , "BA3MASTER", oStruBW7)
	
	oModel:GetModel( "BW7DETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BW7DETAIL', { { "BW7_FILIAL" 	, "xFilial( 'BW7' )" },;
									{"BW7_CODINT" , "BA3_CODINT" },;
									{"BW7_CODEMP" , "BA3_CODEMP" },;
									{"BW7_MATRIC" , "BA3_MATRIC"} },;									
									BW7->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( "BA3MASTER" ):SetDescription( "Familia" )
    oModel:GetModel( "BW7DETAIL" ):SetDescription( "Grupo de Quantidades" )

	oModel:GetModel( "BA3MASTER" ):SetOnlyQuery(.T.)
    oModel:GetModel( "BA3MASTER" ):SetOnlyView(.T.)	
	    
    oModel:SetPrimaryKey( { "BW7_FILIAL", "BW7_CODINT", "BW7_CODEMP", "BW7_MATRIC","BW7_CODGRU" } )
    oStruBW7:setProperty("BW7_CODGRU", MODEL_FIELD_VALID ,{ || ExistCpo("BW2",BA3->BA3_CODINT+oModel:GetValue("BW7DETAIL", "BW7_CODGRU"),1) })

    // .And. PLSVldGD()
	
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   10/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA3 := FWFormStruct(2,"BA3", { |cCampo| AllTrim(cCampo) $ "BA3_CODINT|BA3_CODEMP|BA3_MATRIC|"})
	Local oStruBW7 := FWFormStruct(2,"BW7")
    Local oModel   := FWLoadModel("PLSA260BW7")
	Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
	
    oView:AddField( "VIEW_BA3" , oStruBA3, "BA3MASTER")
    oView:AddGrid(  "VIEW_BW7" , oStruBW7, "BW7DETAIL")        
    
    oStruBA3:SetNoFolder()
   	oStruBW7:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 25)
	oView:CreateHorizontalBox("INFERIOR", 75)
	
	oView:EnableTitleView("VIEW_BW7","Grupo de Quantidades")
	
	oView:SetOwnerView( "VIEW_BA3", "SUPERIOR")
	oView:SetOwnerView( "VIEW_BW7", "INFERIOR")
	
	oView:EnableTitleView("VIEW_BA3","Familia")
	oView:EnableTitleView("VIEW_BW7","Grupo de Quantidades")

Return oView