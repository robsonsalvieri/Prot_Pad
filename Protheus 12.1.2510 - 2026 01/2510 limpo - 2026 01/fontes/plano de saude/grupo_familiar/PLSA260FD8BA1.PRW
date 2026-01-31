#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD8BA1
Tela com campos para o preenchimento do Folder Dados Pessoais BA1
@author Totver
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD8BA1(lAutomato)
Local oBrowse

Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD8BA1' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD8BA1 
@author  Totver
@version P12
@since   05/08/2019
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FD8BA1 
@author  Totver
@version P12
@since   05/08/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local nNx
	Local oStruBA1 := FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Pessoais') })
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Plano') })
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC","BA1_CONEMP","BA1_VERCON","BA1_SUBCON","BA1_VERSUB"} // Campos a serem adicionado na estrutura
	
	Local aCamposBA3	:= {"BA3_TIPOUS","BA3_CODEMP","BA3_CONEMP","BA3_VERCON","BA3_SUBCON","BA3_VERSUB",;
							"BA3_DATBAS","BA3_MATRIC","BA3_FORPAG","BA3_FORCTX"} 
	local oEventBA1 := PLGFBA1Event():new() as object

	BA3->(DbSetORder(1))
	BA3->(MsSeek(xFilial("BA3") + BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC  + BA1->BA1_CONEMP + BA1->BA1_VERCON + BA1->BA1_SUBCON + BA1->BA1_VERSUB))

	For nNx := 1 To Len(aCamposBA3)
		oStruBA3 := CriaCampMVC(1,@oStruBA3,@aCamposBA3[nNx]) 
	Next
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,@oStruBA1,@aCamposBA1[nNx]) 
	Next

	oStruBA3:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)	

    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD8BA1')	
    
	oModel:addFields('BA1MASTER' , ,oStruBA1)
	oModel:addFields('BA3DETAIL', 'BA1MASTER' , oStruBA3)								
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Dados Pessoais do Beneficiario' )
	oModel:SetPrimaryKey({})

	oModel:SetRelation( 'BA3DETAIL', { { 'BA3_FILIAL' , 'xFilial( "BA3" )'},;
								{ 'BA3_CODINT'	, 'BA1_CODINT'       },;
								{ 'BA3_CODEMP'	, 'BA1_CODEMP'       },;
								{ 'BA3_MATRIC'	, 'BA1_MATRIC'       } },;									
									BA3->( IndexKey(1) ) ) 		

	oStruBA1:setProperty('BA1_CODDEP',MODEL_FIELD_VALID, { ||.T.})
	oStruBA1:setProperty('BA1_DATCAS',MODEL_FIELD_VALID, { ||.T.})

	
    oStruBA3:SetProperty( 'BA3_DESPLA' , MODEL_FIELD_INIT, { || Posicione("BI3",1,xFilial("BI3")+BA3->BA3_CODINT+BA3->BA3_CODPLA+BA3->BA3_VERSAO,"BI3_DESCRI") })
	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_VALID, { || PLSABA3MVC(oModel) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_VALID, { || EXISTCPO("BIL", RetFilPla(oModel),1) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_FORPAG',MODEL_FIELD_VALID, { || PLS260COFZ(.T.,oModel) .And. PLSA260GCMvc(oModel)})
	oStruBA3:setProperty('BA3_FORCTX',MODEL_FIELD_VALID, { || .T.})

	oModel:installEvent("PLGFBA1Event", /*cOwner*/, oEventBA1)
	oModel:installEvent("PLSA260EVDEF", /*cOwner*/, PLSA260EVDEF():new())
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   05/08/2019.
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  
Local oStruBA1 := FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA1','Pessoais') })
Local oModel   := FWLoadModel( 'PLSA260FD8BA1' )
Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'BA1MASTER' )

    oStruBA1:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:EnableTitleView('VIEW_BA1','Dados Pessoais do Beneficiario')
	
Return oView

