#include "totvs.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"
#include "JURA321.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA321
Rotina MVC para cadastro de Regras de auditoria de casos (Tabela OIF)
@type   function
@author Abner Fogaça de Oliveira
@since  14/08/2026
/*/
//-------------------------------------------------------------------
Function JURA321()
    Local oBrowse := Nil

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("OIF")
    oBrowse:SetDescription(STR0006) //"Regras de auditoria de casos"
    oBrowse:SetLocate()
    oBrowse:SetMenuDef("JURA321")
    oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao das acoes do menu da rotina

@type   staticfunction
@author Abner Fogaça de Oliveira
@since  14/08/2026
@return Array com as opcoes de menu
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    aAdd( aRotina, { STR0001, "VIEWDEF.JURA321", 0, 2, 0, NIL } ) //"Visualizar"
    aAdd( aRotina, { STR0002, "VIEWDEF.JURA321", 0, 3, 0, NIL } ) //"Incluir"
    aAdd( aRotina, { STR0003, "VIEWDEF.JURA321", 0, 4, 0, NIL } ) //"Alterar"
    aAdd( aRotina, { STR0004, "VIEWDEF.JURA321", 0, 5, 0, NIL } ) //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do Modelo de Dados (Regras de Negocio)

@type   staticfunction
@author Abner Fogaça de Oliveira
@since  14/08/2026
@return Object oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
    // Estrutura de dados baseada no Dicionario de Dados (SX3)
    Local oStruct := FWFormStruct(1, "OIF")
    Local oModel  := Nil

    // Instancia o modelo
    oModel := MPFormModel():New("JURA321")
    
    // Adiciona os campos da estrutura ao modelo
    oModel:AddFields("OIFMASTER", /*cOwner*/, oStruct)
    
    // Configuracoes de descricao
    oModel:SetDescription(STR0005) // "Regras adicionais para auditoria dos casos"
    oModel:GetModel("OIFMASTER"):SetDescription(STR0007) // "Dados da Regra"
    
    // Definicao da chave primaria (Conforme solicitacao: OIF_FILIAL + OIF_CODIGO)
    oModel:SetPrimaryKey({ "OIF_FILIAL", "OIF_CODIGO" })

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da Interface Visual (Layout)

@type   function
@author Abner Fogaça de Oliveira
@since  14/08/2026
@return Object oView
/*/
//-------------------------------------------------------------------
Function ViewDef()
    Local oModel  := FWLoadModel("JURA321")
    Local oStruct := FWFormStruct(2, "OIF")
    Local oView   := Nil

    // Instancia a view
    oView := FWFormView():New()
    
    // Relaciona a View ao Model
    oView:SetModel(oModel)
    
    // Adiciona a estrutura visual dos campos
    oView:AddField("VIEW_OIF", oStruct, "OIFMASTER")
    
    // Cria uma caixa horizontal ocupando 100% da tela
    oView:CreateHorizontalBox("TELA", 100)
    
    // Associa o componente visual (VIEW_OIF) a caixa de layout (TELA)
    oView:SetOwnerView("VIEW_OIF", "TELA")

Return oView
