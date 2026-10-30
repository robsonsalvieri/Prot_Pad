#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "GPCA004.ch"

/*/{Protheus.doc} GPCA004
Cadastro de concentradoras utilizando MVC

@author Duofy
@since 01/08/2025
@version 1.0
@type function
/*/

Function GPCA004()

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'A61' )
	oBrowse:SetDescription( STR0001 )

	// adiciona legenda no Browser
	oBrowse:AddLegend( "A61_STATUS == '1'", "GREEN", STR0010)
	oBrowse:AddLegend( "A61_STATUS == '2'", "RED"  , STR0011)

	oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title STR0003   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title STR0004  			Action 'VIEWDEF.GPCA004' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title STR0005     		Action 'VIEWDEF.GPCA004' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title STR0006     		Action 'VIEWDEF.GPCA004' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title STR0007     		Action 'VIEWDEF.GPCA004' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title STR0008    		Action 'VIEWDEF.GPCA004' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title STR0009     		Action 'VIEWDEF.GPCA004' 	OPERATION 09 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruA61 := FWFormStruct( 1, 'A61', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'GPCA004', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'A61MASTER', /*cOwner*/, oStruA61 )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "A61_FILIAL" , "A61_CODCON" })

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'A61MASTER' ):SetDescription( STR0002 )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oStruA61 := FWFormStruct( 2, 'A61' )

	// Cria a estrutura a ser usada na View
	Local oModel   := FWLoadModel( 'GPCA004' )

	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_A61', oStruA61, 'A61MASTER' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TOTAL', 100 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_A61', 'TOTAL' )

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_A61',STR0002)

	// Define fechamento da tela
	oView:SetCloseOnOk( {||.T.} )

Return oView
