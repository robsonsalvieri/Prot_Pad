#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP100.CH" 

PUBLISH MODEL REST NAME AGDP100

/*/{Protheus.doc} AGDP100
Browse do Programa de Sub-Grupos de Produto - NF8
@type function
@version 12
@author ronery.filho
@since 16/07/2026
/*/
Function AGDP100()
	Local oMBrowse := Nil

	If !FWAliasInDic("NF8")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NF8")
	oMBrowse:SetDescription(STR0001) //Sub-Grupos de Produto
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Opções do menu da rotina AGDP100
@type function
@version 12
@author ronery.filho
@since 16/07/2026
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP100"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0002   	Action cAction	OPERATION OP_VISUALIZAR ACCESS nAccess
	ADD OPTION aRotina Title STR0003   	Action cAction	OPERATION OP_INCLUIR	ACCESS nAccess
	ADD OPTION aRotina Title STR0004    Action cAction	OPERATION OP_ALTERAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0005	Action cAction	OPERATION OP_EXCLUIR	ACCESS nAccess
	
Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina AGDP100
@type function
@version 12
@author ronery.filho
@since 16/07/2026
/*/
Static Function ModelDef()
	Local oModel     := Nil
	Local oStructNF8 := FwFormStruct(1, "NF8")

	oModel:= MpFormModel():New("AGDP100")
	oModel:SetDescription(STR0001)//Sub-Grupos de Produto
	oModel:AddFields("AGDP100_NF8", , oStructNF8)
	oModel:GetModel("AGDP100_NF8"):SetDescription(STR0001) //Sub-Grupos de Produto
	oModel:SetPrimaryKey({"NF8_FILIAL", "NF8_CODIGO"})

Return oModel

/*/{Protheus.doc} ViewDef
View da rotina AGDP100
@type function
@version 12
@author ronery.filho
@since 16/07/2026
/*/
Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel("AGDP100")
	Local oStructNF8 := FwFormStruct(2, "NF8")

	oView:SetModel(oModel)
	oStructNF8:RemoveField("NF8_FILIAL")
	oView:AddField("VIEW_NF8", oStructNF8, "AGDP100_NF8")
	oView:EnableTitleView("VIEW_NF8")
	oView:SetCloseOnOk({ || .T.})

Return oView
