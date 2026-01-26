//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
#Include "GPCA005.ch"

//Variveis Estaticas
Static cAliasMVC := "A6Z"

/*/{Protheus.doc} User Function GPCA005
Cadastro de Produtos ANP (i-SIMP)
@author Duofy	
@since 01/08/2025
@version 1.0
@type function
/*/

Function GPCA005()

	Local oBrowse

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(STR0001)

	//Ativa a Browse
	oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao GPCA005
@author Stephen Noel
@since 30/07/2025
@version 1.0
@type function
/*/

Static Function MenuDef()

	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GPCA005" OPERATION 1 ACCESS 0 //Visualizar
	ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GPCA005" OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.GPCA005" OPERATION 4 ACCESS 0 //Alterar
	ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.GPCA005" OPERATION 5 ACCESS 0 //Excluir
	ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.GPCA005" OPERATION 9 ACCESS 0 //Copiar

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao GPCA005
@author Stephen Noel
@since 30/07/2025
@version 1.0
@type function
/*/

Static Function ModelDef()

	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCancel := Nil

	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("GPCA005", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("A6ZMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription(STR0003)
	oModel:GetModel("A6ZMASTER"):SetDescription( STR0002 )
	oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao GPCA005
@author Stephen Noel
@since 30/07/2025
@version 1.0
@type function
/*/

Static Function ViewDef()

	Local oModel := FWLoadModel("GPCA005")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_A6Z", oStruct, "A6ZMASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetOwnerView("VIEW_A6Z", "TELA")

Return oView
