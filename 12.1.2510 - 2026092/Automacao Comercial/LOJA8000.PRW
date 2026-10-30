#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA8000.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA8000
Canais de Venda (MER)

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  31/07/2026
/*/
//-------------------------------------------------------------------
Function LOJA8000()
	Local oBrowse As Object

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("MER")
	oBrowse:SetDescription(STR0001) // Canais de Vendas
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados MVC do cadastro de Canais de Venda (MER).

Obs: Em operações de cópia de registro, o campo MER_CODIGO não será copiado

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  31/07/2026
@return object, instancia de MPFormModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     As Object
	Local oStruct    As Object
	Local oEventMain As Object

	oEventMain := LOJ8000EVDEF():New()

	oStruct := FWFormStruct(1, "MER")

	oModel := MPFormModel():New("LOJA8000M")
	oModel:AddFields("MERMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription(STR0001) // Canais de Vendas
	oModel:GetModel("MERMASTER"):SetDescription(STR0002) // Dados do Canal de Venda
	oModel:GetModel("MERMASTER"):SetFldNoCopy({"MER_CODIGO"})

	oModel:InstallEvent("LOJ8000EVDEF", /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Layout visual MVC do cadastro de Canais de Venda (MER).

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  31/07/2026
@return object, instancia de FWFormView
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oView   As Object
	Local oModel  As Object
	Local oStruct As Object

	oModel := FWLoadModel("LOJA8000")

	oStruct := FWFormStruct(2, "MER")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_MER", oStruct, "MERMASTER")
	oView:CreateHorizontalBox("BOXMER", 100)
	oView:SetOwnerView("VIEW_MER", "BOXMER")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Acoes de menu padrao do cadastro MVC de Canais de Venda (MER):
Incluir, Alterar, Excluir, Visualizar e Copiar.

@type   function
@author cruz.rafael | Squad Retail Backoffice
@since  31/07/2026
@return array, itens de menu da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aMenu As Array

	aMenu := {}

	aAdd(aMenu, {STR0003, "PesqBrw"         , 0, 1, 0, NIL}) // Pesquisar
	aAdd(aMenu, {STR0004, "VIEWDEF.LOJA8000", 0, 2, 0, Nil}) // Visualizar
	aAdd(aMenu, {STR0005, "VIEWDEF.LOJA8000", 0, 3, 0, Nil}) // Incluir
	aAdd(aMenu, {STR0006, "VIEWDEF.LOJA8000", 0, 4, 0, Nil}) // Alterar
	aAdd(aMenu, {STR0007, "VIEWDEF.LOJA8000", 0, 5, 0, Nil}) // Excluir
	aAdd(aMenu, {STR0008, "VIEWDEF.LOJA8000", 0, 9, 0, Nil}) // Copiar

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJ8000EVDEF
Eventos padrão do cadastro de Canais de Venda

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  Jorge Martins
@since   06/08/2026
/*/
//-------------------------------------------------------------------
CLASS LOJ8000EVDEF From FWModelEvent

	METHOD New() CONSTRUCTOR

	METHOD ModelPosVld()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor da classe LOJ8000EVDEF

@type    Method
@author  Jorge Martins
@since   06/08/2026
/*/
//-------------------------------------------------------------------------------------------------------------
Method New() Class LOJ8000EVDEF
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método de validação do modelo antes da gravação dos dados

@type    Method
@author  Jorge Martins
@since   06/08/2026
@param   oModel - Modelo de dados de Canais de Venda (MER)
@return  lValid - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD ModelPosVld(oModel) CLASS LOJ8000EVDEF
	Local lValid    As Logical
	Local cProblema As Character
	Local cSolucao  As Character
	Local cCliente  As Character
	Local cLoja     As Character
	Local nOpc      As Numeric

	Default oModel := Nil

	lValid := .T.

	If oModel <> Nil
		nOpc := oModel:GetOperation()
		
		If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE
			cCliente := oModel:GetValue("MERMASTER", "MER_CLIMOD")
			cLoja    := oModel:GetValue("MERMASTER", "MER_LOJMOD")
			If (Empty(cCliente) .And. !Empty(cLoja)) .Or. (Empty(cLoja) .And. !Empty(cCliente))
				cProblema := STR0009 // "Os campos 'Cliente' e 'Loja' devem ser preenchidos juntos."
				cSolucao  := STR0010 // "Preencha ambos os campos ou deixe ambos em branco."
				Help("", 1, "HELP", ProcName(0), cProblema, 1,,,,,,, {cSolucao})
				lValid := .F.
			EndIf
		EndIf
	EndIf

Return lValid
