#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP010.CH"

/*/{Protheus.doc} AGDP010
Browse do Programa de Descarte de Embalagem - NEO
@type function
@version 12
@author gilson.venturi
@since 15/08/2025
/*/
Function AGDP010()
	Local oMBrowse := Nil

	If !FWAliasInDic("NEO")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NEO")
	oMBrowse:SetDescription(STR0001) //Programa de Descarte
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP010"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0003 Action cAction     OPERATION OP_VISUALIZAR ACCESS nAccess
	ADD OPTION aRotina Title STR0004 Action cAction     OPERATION OP_INCLUIR	ACCESS nAccess
	ADD OPTION aRotina Title STR0005 Action cAction     OPERATION OP_ALTERAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0006 Action cAction     OPERATION OP_EXCLUIR	ACCESS nAccess
	
Return aRotina

Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNEO := FwFormStruct(1, "NEO")
	Local oEvent     := AGDP010EVT():New()

	oModel:= MpFormModel():New("AGDP010")
	oModel:SetDescription(STR0001)
	oModel:AddFields("AGDP010_NEO", , oStructNEO)
	oModel:GetModel("AGDP010_NEO"):SetDescription(STR0007) //Dados Descarte Embalagem
	oModel:SetPrimaryKey({"NEO_FILIAL", "NEO_CODIGO"})

	oModel:InstallEvent("AGDP010EVT", /*cOwner*/, oEvent)

Return oModel

Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDP010")
	Local oStructNEO := FwFormStruct(2, "NEO")

	oView:SetModel(oModel)
	oStructNEO:RemoveField("NEO_FILIAL")
	oView:AddField("VIEW_NEO", oStructNEO, "AGDP010_NEO")
	oView:EnableTitleView("VIEW_NEO")
	oView:SetCloseOnOk({ || .T.})

Return oView
