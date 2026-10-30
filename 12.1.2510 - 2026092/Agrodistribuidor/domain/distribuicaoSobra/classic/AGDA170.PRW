#Include "TOTVS.CH"
#Include "FWMVCDEF.CH"
#Include "AGDA170.CH"

/*/{Protheus.doc} AGDA170
Cadastro de Origens de Sobras da cooperativa, permitindo parametrizar
a origem, os vínculos com operações fiscais (TES) e grupos de produtos.
@type function
@version 12
@author rodrigo.nsoledade
@since 27/08/2026
/*/
Function AGDA170()
	Local oMBrowse := Nil

	If !FWAliasInDic("NFB") .Or. !FWAliasInDic("NFC") .Or. !FWAliasInDic("NFD")
		MsgNextRel() // É necessário atualizar o sistema para a expedição mais recente.
		Return Nil
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NFB")
	oMBrowse:SetDescription(FwSX2Util():GetX2Name("NFB"))
	oMBrowse:DisableDetails()

	If hasSmartX()
		oMBrowse:SetSmartX()
	EndIf
	oMBrowse:Activate()
Return Nil

/*/{Protheus.doc} MenuDef
Define as opções disponíveis no cadastro de Origens de Sobras.
@type function
@version 12
@author rodrigo.nsoledade
@since 27/08/2026
@return array, opções da rotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.AGDA170" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.AGDA170" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.AGDA170" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.AGDA170" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Define o modelo MVC do cadastro de Origens de Sobras.
NFB: Cabeçalho da Origem de Sobras.
NFC: Vínculos com Operações Fiscais (TES).
NFD: Vínculos com Grupos de Produtos.
@type function
@version 12
@author rodrigo.nsoledade
@since 27/08/2026
@return object, modelo MVC
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNFB := FWFormStruct(1,"NFB")
	Local oStructNFC := FWFormStruct(1,"NFC")
	Local oStructNFD := FWFormStruct(1,"NFD")

	// Os campos abaixo são preenchidos pelo relacionamento pai x filho.
	oStructNFC:RemoveField("NFC_CODORI")
	oStructNFD:RemoveField("NFD_CODORI")

	oModel := MPFormModel():New("AGDA170")
	oModel:SetDescription(FwSX2Util():GetX2Name("NFB"))

	// Cabeçalho - Origem de Sobras.
	oModel:AddFields("AGDA170_NFB",Nil,oStructNFB)
	oModel:GetModel("AGDA170_NFB"):SetDescription(FwSX2Util():GetX2Name("NFB"))

	oModel:SetPrimaryKey({"NFB_FILIAL","NFB_CODIGO"})

	// Grid - Operações Fiscais (TES).
	oModel:AddGrid("AGDA170_NFC","AGDA170_NFB",oStructNFC)
	oModel:GetModel("AGDA170_NFC"):SetDescription(FwSX2Util():GetX2Name("NFC"))
	oModel:GetModel("AGDA170_NFC"):SetOptional(.T.)
	oModel:GetModel("AGDA170_NFC"):SetUniqueLine({"NFC_CODTES"})
	oModel:GetModel("AGDA170_NFC"):SetUseOldGrid(.T.)

	// Grid - Grupos de Produtos.
	oModel:AddGrid("AGDA170_NFD","AGDA170_NFB",oStructNFD)
	oModel:GetModel("AGDA170_NFD"):SetDescription(FwSX2Util():GetX2Name("NFD"))
	oModel:GetModel("AGDA170_NFD"):SetOptional(.T.)
	oModel:GetModel("AGDA170_NFD"):SetUniqueLine({"NFD_GRUPO"})
	oModel:GetModel("AGDA170_NFD"):SetUseOldGrid(.T.)

	// Relacionamento NFB x NFC.
	oModel:SetRelation("AGDA170_NFC",{{"NFC_FILIAL",'xFilial("NFC")'},{"NFC_CODORI","NFB_CODIGO"}},NFC->(IndexKey(1)))

	// Relacionamento NFB x NFD.
	oModel:SetRelation("AGDA170_NFD",{{"NFD_FILIAL",'xFilial("NFD")'},{"NFD_CODORI","NFB_CODIGO"}},NFD->(IndexKey(1)))

Return oModel

/*/{Protheus.doc} ViewDef
Define a interface MVC do cadastro de Origens de Sobras.
A tela é composta pelo cabeçalho da NFB e duas grids na parte inferior.
@type function
@version 12
@author rodrigo.nsoledade
@since 27/08/2026
@return object, view MVC
/*/
Static Function ViewDef()
	Local oModel     := FWLoadModel("AGDA170")
	Local oStructNFB := FWFormStruct(2,"NFB")
	Local oStructNFC := FWFormStruct(2,"NFC")
	Local oStructNFD := FWFormStruct(2,"NFD")
	Local oView      := FWFormView():New()

	// Campos relacionados ao cabeçalho não precisam ser exibidos nas grids.
	oStructNFC:RemoveField("NFC_CODORI")
	oStructNFD:RemoveField("NFD_CODORI")

	oView:SetModel(oModel)

	// Cabeçalho.
	oView:AddField("VIEW_NFB",oStructNFB,"AGDA170_NFB")

	// Grids.
	oView:AddGrid("VIEW_NFC",oStructNFC,"AGDA170_NFC")
	oView:AddGrid("VIEW_NFD",oStructNFD,"AGDA170_NFD")

	// Numeração automática dos itens das grids.
	oView:AddIncrementField("VIEW_NFC","NFC_ITEM")
	oView:AddIncrementField("VIEW_NFD","NFD_ITEM")

	// Cabeçalho na parte superior e grids na parte inferior.
	oView:CreateHorizontalBox("CABECALHO",40)
	oView:CreateHorizontalBox("GRADES",60)

	oView:CreateFolder("FOLDERS","GRADES")
	oView:AddSheet("FOLDERS","FOLDER_NFC", STR0005) //"Vínculo com Operações Fiscais (TES)"
	oView:AddSheet("FOLDERS","FOLDER_NFD", STR0006) //"Vínculo com Grupos de Produtos"

	oView:CreateHorizontalBox("BOX_NFC",100,,,"FOLDERS","FOLDER_NFC")
	oView:CreateHorizontalBox("BOX_NFD",100,,,"FOLDERS","FOLDER_NFD")

	oView:SetOwnerView("VIEW_NFB","CABECALHO")
	oView:SetOwnerView("VIEW_NFC","BOX_NFC")
	oView:SetOwnerView("VIEW_NFD","BOX_NFD")

	oView:EnableTitleView("VIEW_NFB")
	oView:EnableTitleView("VIEW_NFC")
	oView:EnableTitleView("VIEW_NFD")

	oView:SetCloseOnOk({|| .T.})
Return oView
