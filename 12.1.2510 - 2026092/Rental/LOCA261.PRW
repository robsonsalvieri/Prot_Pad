#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA261
Cadastro Grupo de Produto x Série NF
@type function
@version 25.10
@author Dennis Calabrez
@since 09/04/2026
/*/
FUNCTION LOCA261()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FH6")
oBrowse:SetDescription("Cadastro Grupo de Produto x Série NF")
oBrowse:SetMenuDef("LOCA261")
oBrowse:SetProfileID("LOCA261")
oBrowse:SetTopFun('xFilial("FH6")')
oBrowse:SetBotFun('xFilial("FH6")')
oBrowse:SetAmbiente(.F.)
oBrowse:SetWalkthru(.F.)
oBrowse:OptionReport(.F.)
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MENUDEF
Menu do Cadastro Grupo de Produto x Série NF
@type function
@version 25.10
@author Dennis Calabrez
@since 09/04/2026
@return variant, Array com as opcoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"    ACTION "VIEWDEF.LOCA261" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.LOCA261" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.LOCA261" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.LOCA261" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} MODELDEF
Definicao do modelo de Cadastro Grupo de Produto x Série NF
@type function
@version 25.10
@author Dennis Calabrez
@since 09/04/2026
@return variant, Modelo MVC do Cadastro Grupo de Produto x Série NF
/*/
STATIC FUNCTION MODELDEF()
Local oStruFH6 := FWFormStruct(1, "FH6")
Local oModel

oModel := MPFormModel():New("LOCA261", /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields("FH6MASTER", /*cOwner*/, oStruFH6, /*bPreValid*/, /*bPosValid*/, /*bCarga*/)

oModel:SetDescription("Cadastro Grupo de Produto x Série NF") 
oModel:GetModel("FH6MASTER"):SetDescription("Grupo de Produto x Série NF")
oModel:SetPrimaryKey({"FH6_FILIAL", "FH6_GRUPO"})

Return oModel

/*/{Protheus.doc} ViewDef
View do Cadastro Grupo de Produto x Série NF
@type function
@version 25.10
@author Dennis Calabrez
@since 27/03/2026
@return variant, View MVC do Cadastro Grupo de Produto x Série NF
/*/
STATIC FUNCTION ViewDef()
Local oModel   := FWLoadModel("LOCA261")
Local oStruFH6 := FWFormStruct(2, "FH6")
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FH6", oStruFH6, "FH6MASTER")

oView:CreateHorizontalBox("TELA", 100)
oView:SetOwnerView("VIEW_FH6", "TELA")

Return oView
