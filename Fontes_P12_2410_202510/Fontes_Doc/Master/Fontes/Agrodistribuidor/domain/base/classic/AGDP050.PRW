#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP050.CH"

/*/{Protheus.doc} AGDP050
Cadatros de Features dos módulo agroDistribuidor
@type function
@version 12
@author agroDistribuidor
@since 22/09/2025
/*/
Function AGDP050()

	If !FWAliasInDic("NE1")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NE1")
	oFWMBrowse:SetDescription(STR0001)
	oFWMBrowse:DisableDetails()
	oFWMBrowse:SetMenuDef("AGDP050")

	oFWMBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP050"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0002 Action cAction OPERATION OP_VISUALIZAR	ACCESS nAccess
	
Return aRotina

Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNE1 := FwFormStruct(1, "NE1")
	Local oEvent     := AGDP050EVT():New()

	oModel:= MpFormModel():New("AGDP050")
	oModel:SetDescription(STR0001)
	oModel:AddFields("AGDP050_NE1", , oStructNE1)
	oModel:SetPrimaryKey({"NE1_FILIAL", "NE1_CODIGO"})

	oModel:InstallEvent("AGDP050EVT", /*cOwner*/, oEvent)

Return oModel

Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDP050")
	Local oStructNE1 := FwFormStruct(2, "NE1")

	oView:SetModel(oModel)
	oStructNE1:RemoveField("NE1_FILIAL")
	oView:AddField("VIEW_NE1", oStructNE1, "AGDP050_NE1")
	oView:EnableTitleView("VIEW_NE1")
	oView:SetCloseOnOk({ || .T.})

Return oView
