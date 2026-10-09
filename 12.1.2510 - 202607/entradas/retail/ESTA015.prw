#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "ESTA015.CH"
#INCLUDE "FWMBROWSE.CH"

PUBLISH MODEL REST NAME ESTA015 SOURCE ESTA015

//-------------------------------------------------------------------
/*/{Protheus.doc} ESTA015
Novo complemento de produto

@type    Function
@author  Daniel Tonon - Backoffice / Squad Retail
@since   26/02/2026
@version 12
/*/
//-------------------------------------------------------------------
Function ESTA015()
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("D4Z")
	oBrowse:SetDescription(STR0001) // "Dados complementares do produto" 
	oBrowse:DisableDetails()
	//Função do Browser SMARTX 
	If hasSmartX()
		oBrowse:setSmartX()
	Endif 
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@type    Function
@author  Daniel Tonon - Backoffice / Squad Retail
@since   26/02/2026
@version 12

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina As Array

	aRotina := {}
	aAdd(aRotina, {STR0002 , "PesqBrw"        , 0, 1, 0, NIL }) // "Pesquisar"
	aAdd(aRotina, {STR0003 , "VIEWDEF.ESTA015", 0, 2, 0, NIL }) // "Visualizar"
	aAdd(aRotina, {STR0004 , "VIEWDEF.ESTA015", 0, 3, 0, NIL }) // "Incluir"
	aAdd(aRotina, {STR0005 , "VIEWDEF.ESTA015", 0, 4, 0, NIL }) // "Alterar"
	aAdd(aRotina, {STR0006 , "VIEWDEF.ESTA015", 0, 5, 0, NIL }) // "Excluir"
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do Complemento de Produto

@type    Function
@author  Daniel Tonon - Backoffice / Squad Retail
@since   26/02/2026
@version 12

@return  oModel - Modelo de dados
@obs     D4ZMASTER - Dados principais
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel   As Object
	Local oStruD4Z As Object

	oStruD4Z := FWFormStruct(1, "D4Z")

	oModel := MPFormModel():New("ESTA015")
	oModel:AddFields("D4ZMASTER", /*cOwner*/, oStruD4Z)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Complemento de Produto

@type    Function
@author  Daniel Tonon - Backoffice / Squad Retail
@since   26/02/2026
@version 12

@return oView - View de dados
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel As Object
	Local oStD4Z As Object
	Local oView  As Object

	oModel := FWLoadModel("ESTA015")
	oStD4Z := FWFormStruct(2, "D4Z")
	oView  := NIL

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("VIEW_D4Z", oStD4Z, "D4ZMASTER")

	oView:CreateHorizontalBox("TELA", 100)

	oView:EnableTitleView('VIEW_D4Z', STR0001) // "Dados complementares do produto" 

	oView:SetOwnerView("VIEW_D4Z", "TELA")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA010ESTA015
Classe para ser utilizada na rotina MATA010 (Cadastro de Produtos) 
para adicionar a amarração de complemento de produto x produtos.

@type    Class
@author  Daniel Tonon - Backoffice / Squad Retail
@since   27/02/2026
@version 12
/*/
//-------------------------------------------------------------------
CLASS MATA010ESTA015 FROM FWModelEvent

	DATA cModelProduto    As Character
	DATA lProdutoCadastro As Logical

	METHOD new(cModelMaster) CONSTRUCTOR
	METHOD VldActivate(oModel, cModelId)

	METHOD ModelDefMata010(oModel)
	METHOD ViewDefMata010(oView)
	METHOD A010CanActivate(oView)

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo de criação do objeto

@type    Method
@author  Daniel Tonon - Backoffice / Squad Retail
@since   02/03/2026
@version 12
@param   cModelMaster - Modelo Master
/*/
//-------------------------------------------------------------------
METHOD New(cModelMaster) CLASS MATA010ESTA015

	::cModelProduto := cModelMaster
	::lProdutoCadastro := "D4Z" $ SuperGetMv("MV_CADPROD",,"|SBZ|SB5|SGI|D3E|")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDefMata010
Metodo de definição do model da tabela D4X para ser adicionada 
no Model da tabela de produtos

@type    Method
@author  Daniel Tonon - Backoffice / Squad Retail
@since   02/03/2026
@version 12
@param   oModel - Objeto Model
/*/
//-------------------------------------------------------------------
METHOD ModelDefMata010(oModel) CLASS MATA010ESTA015
Local oStruD4Z As Object

	If ::lProdutoCadastro
		oStruD4Z := FWFormStruct(1, "D4Z")
		oStruD4Z:setProperty('D4Z_COD', MODEL_FIELD_OBRIGAT, .F.)

		oModel:AddFields("D4ZDETAIL", ::cModelProduto, oStruD4Z)
		oModel:SetRelation("D4ZDETAIL", {{'D4Z_FILIAL', 'xFilial("D4Z")'}, {'D4Z_COD', 'B1_COD'}}, D4Z->(IndexKey(1)))
		oModel:GetModel("D4ZDETAIL"):SetOptional(.T.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDefMata010
Definição da view da tabela D4X para ser adicionada na View da tabela de produtos

@type    Method
@author  Daniel Tonon - Backoffice / Squad Retail
@since   02/03/2026
@version 12
@param   oView - Objeto View
/*/
//-------------------------------------------------------------------
METHOD ViewDefMata010(oView) CLASS MATA010ESTA015
Local oStruD4Z As Object
Local nOpc     As Numeric

	If ::lProdutoCadastro
		nOpc := oView:GetOperation()
		oStruD4Z := FWFormStruct(2, "D4Z", {|cField| !(AllTrim(Upper(cField)) $ "D4Z_COD") })
		oStruD4Z:RemoveField("D4Z_COD")
		oView:AddField("FORMD4Z", oStruD4Z, "D4ZDETAIL")
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A010CanActivate
Metodo para ativar a view da amarração de categoria x produto

@type    Method
@author  Daniel Tonon - Backoffice / Squad Retail
@since   02/03/2026
@version 12
@param   oView - Objeto View
/*/
//-------------------------------------------------------------------
METHOD A010CanActivate(oView) CLASS MATA010ESTA015
Local nOpc := 0

	If ::lProdutoCadastro
		nOpc := oView:GetOperation()
		If MPUserHasAccess("ESTA015", nOpc) // checa se o ususario tem acesso a rotina na opcao escolhida
			oView:CreateHorizontalBox('BOXFORMD4Z', 10)
			oView:SetOwnerView("FORMD4Z", 'BOXFORMD4Z')
			oView:EnableTitleView("FORMD4Z", STR0001) // "Dados complementares do produto" 
		EndIf
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldActivate
Metodo de validação para ativar o objeto de amarração de complemento de produto x produto

@type    Method
@author  Daniel Tonon - Backoffice / Squad Retail
@since   02/03/2026
@version 12
@param   oModel   - Objeto Model
@param   cModelId - Id do Model
/*/
//-------------------------------------------------------------------
METHOD VldActivate(oModel, cModelId) CLASS MATA010ESTA015

	::ModelDefMata010(oModel)

Return .T.
