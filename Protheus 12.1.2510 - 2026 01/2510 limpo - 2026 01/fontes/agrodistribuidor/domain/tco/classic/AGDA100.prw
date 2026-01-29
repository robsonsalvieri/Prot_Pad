#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA100.CH"

#DEFINE MODEL_NAME "AGDA100"
#DEFINE MODEL_ALIAS "NE2"
#DEFINE MODEL_ID_FORM_FIELD MODEL_NAME + "_" + MODEL_ALIAS
#DEFINE VIEW_ID "VIEW_" + MODEL_ALIAS

/*/{Protheus.doc} AGDA100
Browse de Complementos das Features do Agrodistribuidor - módulo 54 - Agrodistribuidor (SIGAAGD) - Tabela NE2
@type function
@version 12
@author jc.maldonado
@since 28/10/2025
/*/
Function AGDA100()
	Local oFWMBrowse := Nil

	If ! FWAliasInDic(MODEL_ALIAS)
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias(MODEL_ALIAS)
	oFWMBrowse:SetDescription(STR0001) //"Complementos das Features"
	oFWMBrowse:DisableDetails()
	oFWMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 12
@author jc.maldonado
@since 28/10/2025
@return array, opções do menu
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF." + MODEL_NAME
	Local nAccess := 0

	ADD OPTION aRotina Title STR0002 Action cAction OPERATION OP_VISUALIZAR ACCESS nAccess
	ADD OPTION aRotina Title STR0003 Action cAction OPERATION OP_INCLUIR	ACCESS nAccess
	ADD OPTION aRotina Title STR0004 Action cAction OPERATION OP_ALTERAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0005 Action cAction OPERATION OP_EXCLUIR	ACCESS nAccess
Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 12
@author jc.maldonado
@since 28/10/2025
@return object, Instancia do MpFormModel
/*/
Static Function ModelDef()
	Local oMpFmodel  := MpFormModel():New(MODEL_NAME)
	Local oFormStruc := FwFormStruct(1, MODEL_ALIAS)

	oMpFmodel:AddFields(MODEL_ID_FORM_FIELD,, oFormStruc)
	oMpFmodel:SetDescription(STR0001) //"Complementos das Features"
	oMpFmodel:SetPrimaryKey(FWSIXUtil():GetAliasIndexes(MODEL_ALIAS)[1])
Return oMpFmodel

/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 12
@author jc.maldonado
@since 28/10/2025
@return object, Instancia do FwFormView
/*/
Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel(MODEL_NAME)
	Local oFormStruc := FwFormStruct(2, MODEL_ALIAS)

	oView:SetModel(oModel)
	oView:AddField(VIEW_ID, oFormStruc, MODEL_ID_FORM_FIELD)
	oView:EnableTitleView(VIEW_ID)
	oView:SetCloseOnOk({|| .T.})
Return oView
