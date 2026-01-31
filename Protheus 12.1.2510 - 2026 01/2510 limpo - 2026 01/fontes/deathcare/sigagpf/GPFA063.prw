#include "totvs.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GPFA063.ch"

/*/{Protheus.doc} GPFA063
Cadastro de Medico
(Antigo UFUNA007)
@type function
@author g.sampaio
@since 11/11/2022
/*/
Function GPFA063()
	
	Local oBrowse   := Nil

	Private aRotina := {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("A40")
	oBrowse:SetDescription(STR0001) // Cadastro de Médico

	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
Função que cria os menus			
@author Raphael Martins
@since 09/04/2019
@param Nao recebe parametros            
@return nulo
/*/
Static Function MenuDef()

	Local aRotina 	:= {}

	ADD OPTION aRotina Title STR0002   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0 // Pesquisar
	ADD OPTION aRotina Title STR0003 	Action 'VIEWDEF.GPFA063' 	OPERATION 02 ACCESS 0 // Visualizar
	ADD OPTION aRotina Title STR0004    Action 'VIEWDEF.GPFA063' 	OPERATION 03 ACCESS 0 // Incluir
	ADD OPTION aRotina Title STR0005    Action 'VIEWDEF.GPFA063' 	OPERATION 04 ACCESS 0 // Alterar
	ADD OPTION aRotina Title STR0006    Action 'VIEWDEF.GPFA063' 	OPERATION 05 ACCESS 0 // Excluir
	ADD OPTION aRotina Title STR0007    Action 'VIEWDEF.GPFA063' 	OPERATION 08 ACCESS 0 // Imprimir	

Return aRotina


/*/{Protheus.doc} ModelDef
Função que cria o objeto model			
@author Raphael Martins
@since 09/04/2019
@param Nao recebe parametros            
@return nulo
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruA40 := FWFormStruct(1,"A40",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel as object

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("GPFA063",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("A40MASTER",/*cOwner*/,oStruA40)

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"A40_FILIAL","A40_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("A40MASTER"):SetDescription(STR0008) // Cadastro de Médicos

Return(oModel)

/*/{Protheus.doc} ModelDef
Função que cria o objeto View			
@author Raphael Martins
@since 09/04/2019
@param Nao recebe parametros            
@return nulo
/*/
Static Function ViewDef()

// Cria a estrutura a ser usada na View
	Local oStruA40 := FWFormStruct(2,"A40")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("GPFA063")
	Local oView	   as object

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_A40",oStruA40,"A40MASTER")

// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_A40","PAINEL_CABEC")

// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_A40",STR0008) // Cadastro de Médicos

// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

Return(oView)
