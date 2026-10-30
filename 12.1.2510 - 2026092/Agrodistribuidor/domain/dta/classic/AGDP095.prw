#Include "agdp095.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"


#DEFINE MODEL_NAME "AGDP095"
#DEFINE MODEL_ALIAS "NE5"
#DEFINE MODEL_ID_FORM_FIELD MODEL_NAME + "_" + MODEL_ALIAS

/*/{Protheus.doc} AGDP095
Browse de Features do módulo 54 - Agrodistribuidor (SIGAAGD) - Tabela NE1
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
/*/
Function AGDP095()
	Local oFWMBrowse := Nil

	If ! FWAliasInDic(MODEL_ALIAS)
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias(MODEL_ALIAS)
	oFWMBrowse:SetDescription(STR0001)  //"Permissionamento das Tools do DTA"
	oFWMBrowse:DisableDetails()
	oFWMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
@return array, opções do menu
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF." + MODEL_NAME
	Local nAccess := 0

	ADD OPTION aRotina Title STR0002 Action cAction OPERATION OP_VISUALIZAR ACCESS nAccess //"Visualizar"
	ADD OPTION aRotina Title STR0003 Action cAction OPERATION OP_INCLUIR	ACCESS nAccess //"Incluir"
	ADD OPTION aRotina Title STR0004 Action cAction OPERATION OP_ALTERAR	ACCESS nAccess //"Alterar"
	ADD OPTION aRotina Title STR0005 Action cAction OPERATION OP_EXCLUIR	ACCESS nAccess //"Excluir"
Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
@return object, Instancia do MpFormModel
/*/
Static Function ModelDef()
	Local oMpFmodel := MpFormModel():New(MODEL_NAME)
	Local oFormStru := FwFormStruct(1, MODEL_ALIAS)
    
	oMpFmodel:AddFields(MODEL_ID_FORM_FIELD,, oFormStru)
    oMpFmodel:SetDescription(STR0001)  //"Permissionamento das Tools do DTA"
	oMpFmodel:SetPrimaryKey(FWSIXUtil():GetAliasIndexes(MODEL_ALIAS)[1])
Return oMpFmodel

/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
@return object, Instancia do FwFormView
/*/
Static Function ViewDef()
	Local oView		:= FwFormView():New()
	Local oModel	:= FwLoadModel(MODEL_NAME)
	Local oFormStru := FwFormStruct(2, MODEL_ALIAS)
    Local cViewID   := "VIEW_" + MODEL_ALIAS

	oView:SetModel(oModel)
	oView:AddField(cViewID, oFormStru, MODEL_ID_FORM_FIELD)
	oView:EnableTitleView(cViewID)
	oView:SetCloseOnOk({|| .T.})
Return oView

/*/{Protheus.doc} AGDP095VLD
Validação de Grupo/Usuário do permissionamento.
@type function
@version 12
@author jean.schulze
@since 21/11/2025
@return variant, true/false
/*/
Function AGDP095VLD()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNE4      := oModel:GetModel(MODEL_ID_FORM_FIELD)


	If "NE5_GRUPO" $ cReadVar

		if !Empty(oNE4:getValue("NE5_GRUPO")) .and. Empty(GrpRetName(oNE4:getValue("NE5_GRUPO")))
			AGDHELP(STR0008, STR0007, STR0006 ) //"Informe um grupo válido." //"Grupo de Usuário Inválido." //"Ajuda"
			lRet := .F.
		Endif
		
	ElseIf "NE5_CODUSU" $ cReadVar

		if !Empty(oNE4:getValue("NE5_CODUSU")) .and. !UsrExist(oNE4:getValue("NE5_CODUSU"))                
			lRet := .F.
		Endif
		
	Endif

	
return lRet




