#Include "loca260.ch"
#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} LOCA260
Cadastro de Bens Temporarios - Mapeamento de Produtos para geracao automatica de BEM.
Exclusivo por empresa (Filial). Utilizado para mapear produtos que exigem
geracao automatica de BEM vinculado ao contrato.
@type function
@version 25.10
@author Dennis Calabrez
@since 03/03/2026
/*/
FUNCTION LOCA260()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("FH3")
oBrowse:SetDescription(STR0001) //"Cadastro de Bens Temporarios"
oBrowse:SetMenuDef("LOCA260")
oBrowse:SetProfileID("LOCA260")
oBrowse:SetTopFun('xFilial("FH3")')
oBrowse:SetBotFun('xFilial("FH3")')
oBrowse:SetAmbiente(.F.)
oBrowse:SetWalkthru(.F.)
oBrowse:OptionReport(.F.)
oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MENUDEF
Menu do Cadastro de Bens Temporarios
@type function
@version 25.10
@author Dennis Calabrez
@since 03/03/2026
@return variant, Array com as opcoes do menu
/*/
STATIC FUNCTION MENUDEF()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.LOCA260" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003    ACTION "VIEWDEF.LOCA260" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004    ACTION "VIEWDEF.LOCA260" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005    ACTION "VIEWDEF.LOCA260" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} MODELDEF
Definicao do modelo de Bens Temporarios
@type function
@version 25.10
@author Dennis Calabrez
@since 03/03/2026
@return variant, Modelo MVC do Cadastro de Bens Temporarios
/*/
STATIC FUNCTION MODELDEF()
Local oStruFH3 := FWFormStruct(1, "FH3")
Local oModel

// Gatilho: Produto -> preenche descricao do produto via SB1
oStruFH3:AddTrigger("FH3_PROD"  , "FH3_DESCPR", {|| .T.}, {|| Posicione("SB1", 1, xFilial("SB1") + FWFldGet("FH3_PROD")  , "B1_DESC"   ) })

// Gatilho: Familia -> preenche descricao da familia
// ATENCAO: Ajuste a tabela/campo conforme seu ambiente (ex: SBM.BM_DESC, ou SX5 tabela "43")
oStruFH3:AddTrigger("FH3_FAMIL" , "FH3_DESCFA", {|| .T.}, {|| Posicione("SBM", 1, xFilial("SBM") + FWFldGet("FH3_FAMIL") , "BM_DESC"   ) })

// Gatilho: Modelo -> preenche descricao do modelo
// ATENCAO: Ajuste a tabela/campo conforme seu ambiente
oStruFH3:AddTrigger("FH3_MODEL" , "FH3_DESCMO", {|| .T.}, {|| Posicione("ACU", 1, xFilial("ACU") + FWFldGet("FH3_MODEL") , "ACU_DESCRI") })

// Gatilho: Fabricante -> preenche descricao do fabricante
// ATENCAO: Ajuste a tabela/campo conforme seu ambiente
oStruFH3:AddTrigger("FH3_FABRIC", "FH3_DESCFB", {|| .T.}, {|| Posicione("ST7", 1, xFilial("ST7") + FWFldGet("FH3_FABRIC"), "T7_NOME") })

// Gatilho: Turno -> preenche descricao do turno
// ATENCAO: Ajuste a tabela/chave SX5 conforme seu ambiente (ex: tabela "T3" ou outra)
oStruFH3:AddTrigger("FH3_TURNO" , "FH3_DESCTU", {|| .T.}, {|| Posicione("SH7", 1, xFilial("SH7") + FWFldGet("FH3_TURNO"), "H7_DESCRI") })

// Gatilho: Centro de Custo -> preenche descricao via CTT
oStruFH3:AddTrigger("FH3_CC"    , "FH3_DESCCC", {|| .T.}, {|| Posicione("CTT", 1, xFilial("CTT") + FWFldGet("FH3_CC")    , "CTT_DESC01") })

oModel := MPFormModel():New("LOCA260", /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields("FH3MASTER", /*cOwner*/, oStruFH3, /*bPreValid*/, /*bPosValid*/, /*bCarga*/)

oModel:SetDescription(STR0001) //"Cadastro de Bens Temporarios"
oModel:GetModel("FH3MASTER"):SetDescription(STR0006) //"Bens Temporarios"
oModel:SetPrimaryKey({"FH3_FILIAL", "FH3_COD"})

Return oModel

/*/{Protheus.doc} ViewDef
View do Cadastro de Bens Temporarios
@type function
@version 25.10
@author Dennis Calabrez
@since 03/03/2026
@return variant, View MVC do Cadastro de Bens Temporarios
/*/
STATIC FUNCTION ViewDef()
Local oModel   := FWLoadModel("LOCA260")
Local oStruFH3 := FWFormStruct(2, "FH3")
Local oView

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_FH3", oStruFH3, "FH3MASTER")

oView:CreateHorizontalBox("TELA", 100)
oView:SetOwnerView("VIEW_FH3", "TELA")

Return oView
