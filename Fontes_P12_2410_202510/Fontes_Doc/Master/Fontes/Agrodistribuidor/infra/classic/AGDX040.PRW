#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDX040.CH"

/*/{Protheus.doc} AGDX040
Rotina de Relacionamento de Pedido X Agrodistribuidor
@type function
@version 12
@author agroDistribuidor
@since 09/09/2025
/*/
Function AGDX040()

	If !FWAliasInDic("NEQ")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NEQ")
	oFWMBrowse:SetDescription(STR0001)
	oFWMBrowse:DisableDetails()
	oFWMBrowse:SetMenuDef("AGDX040")

	oFWMBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDX040"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0002 Action cAction OPERATION OP_VISUALIZAR	ACCESS nAccess
//	ADD OPTION aRotina Title STR0003 Action cAction OPERATION OP_INCLUIR	ACCESS nAccess
//	ADD OPTION aRotina Title STR0004 Action cAction OPERATION OP_ALTERAR	ACCESS nAccess
//	ADD OPTION aRotina Title STR0005 Action cAction OPERATION OP_EXCLUIR	ACCESS nAccess
	
Return aRotina

Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNEQ := FwFormStruct(1, "NEQ")
	Local oEvent     := AGDX040EVT():New()

	oModel:= MpFormModel():New("AGDX040")
	oModel:SetDescription(STR0001)
	oModel:AddFields("AGDX040_NEQ", , oStructNEQ)
	oModel:SetPrimaryKey({"NEQ_FILIAL", "NEQ_NUM"})

	oModel:InstallEvent("AGDX040EVT", /*cOwner*/, oEvent)

Return oModel

Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDX040")
	Local oStructNEQ := FwFormStruct(2, "NEQ")

	oView:SetModel(oModel)
	oStructNEQ:RemoveField("NEQ_FILIAL")
	oStructNEQ:RemoveField("NEQ_FILENG")
	oStructNEQ:RemoveField("NEQ_FILDES")
	oView:AddField("VIEW_NEQ", oStructNEQ, "AGDX040_NEQ")
	oView:EnableTitleView("VIEW_NEQ")
	oView:SetCloseOnOk({ || .T.})

Return oView
