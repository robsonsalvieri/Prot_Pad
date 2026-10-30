#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//----------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFJ
Funcao para abrir a tela de Cobertura da Familia - Classe de carência
@author DEV TOTVS
@since 10/09/19
@version P12
/*/
//-----------------------------------------------------------------------
Function PLSA260BFJ(lAutomato)

	Local oBrowse
	Default lAutomato := .F.
	
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFJ' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFJ 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFJ 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()		

	Local oModel
	Local oStruBA3 		:= FWFormStruct(1,"BA3")
	Local oStruBFJ 		:= FWFormStruct(1,"BFJ")
	Local aCamposBFJ	:= {"BFJ_CODINT","BFJ_CODEMP","BFJ_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BFJ')

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBFJ)
		oStruBFJ := CriaCampMVC(1,oStruBFJ,aCamposBFJ[nNx]) 
	Next
    
	oModel:addFields("BA3MASTER" , ,oStruBA3) 
   	oModel:AddGrid(  "BFJDETAIL" , "BA3MASTER", oStruBFJ)
	
	oModel:GetModel( "BFJDETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BFJDETAIL', { { "BFJ_FILIAL" 	, "xFilial( 'BFJ' )" },;
									{"BFJ_CODINT" , "BA3_CODINT" },;
									{"BFJ_CODEMP" , "BA3_CODEMP" },;
									{"BFJ_MATRIC" , "BA3_MATRIC"} },;									
									BFJ->( IndexKey(  ) ) ) 
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( "BA3MASTER" ):SetDescription( "Familia" )
    oModel:GetModel( "BFJDETAIL" ):SetDescription( "Classe de Carência" )

	oModel:GetModel( "BA3MASTER" ):SetOnlyQuery(.T.)
    oModel:GetModel( "BA3MASTER" ):SetOnlyView(.T.)	

	oModel:GetModel( 'BFJDETAIL' ):SetUniqueLine( { 'BFJ_CLACAR' } )
	    
    oModel:SetPrimaryKey( { "BFJ_FILIAL", "BFJ_CODINT", "BFJ_CODEMP", "BFJ_MATRIC","BFJ_CLACAR" } )

    oStruBFJ:setProperty("BFJ_CLACAR", MODEL_FIELD_VALID ,{ || BFJValid("BFJ_CLACAR")})
	
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef() 

	Local oStruBA3 := FWFormStruct(2,"BA3", { |cCampo| AllTrim(cCampo) $ "BA3_CODINT|BA3_CODEMP|BA3_MATRIC|"})
	Local oStruBFJ := FWFormStruct(2,"BFJ")
    Local oModel   := FWLoadModel("PLSA260BFJ")
	Local oView

	oView := FWFormView():New()


	oView:SetModel( oModel )
	
    oView:AddField("VIEW_BA3" , oStruBA3, "BA3MASTER")
    oView:AddGrid( "VIEW_BFJ" , oStruBFJ, "BFJDETAIL")        
    
    oStruBA3:SetNoFolder()
   	oStruBFJ:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 20)
	oView:CreateHorizontalBox("INFERIOR", 80)
	
	oView:EnableTitleView("VIEW_BFJ","Classe de Carência")
	
	oView:SetOwnerView( "VIEW_BA3", "SUPERIOR")
	oView:SetOwnerView( "VIEW_BFJ", "INFERIOR")
	
	oView:EnableTitleView("VIEW_BA3","Familia")
	oView:EnableTitleView("VIEW_BFJ","Classe de Carência")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} BFJValid
X3_VALID dos campos da tabela BFJ
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------

Static Function BFJValid(cCampo)
	
	Local lRet 		:= .F.
	Local oModel	:= FWModelActive() // Carrega o Modelo Ativo

	If cCampo == "BFJ_CLACAR"
		lRet := BDL->(ExistCpo("BDL",PLSINTPAD()+oModel:GetValue("BFJDETAIL","BFJ_CLACAR"),1))
	EndIf
	
Return lRet