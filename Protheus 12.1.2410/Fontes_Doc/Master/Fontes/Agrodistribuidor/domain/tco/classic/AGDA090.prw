#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA090.CH"

#DEFINE MODEL_NAME "AGDA090"
#DEFINE MODEL_ALIAS "NE1"
#DEFINE MODEL_ID_FORM_FIELD MODEL_NAME + "_" + MODEL_ALIAS
#DEFINE TCO_SERVICE agd.TCOservice.agdTCOservice

/*/{Protheus.doc} AGDA090
Browse de Features do módulo 54 - Agrodistribuidor (SIGAAGD) - Tabela NE1
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
/*/
Function AGDA090()
	Local oFWMBrowse := Nil

	If ! FWAliasInDic(MODEL_ALIAS)
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias(MODEL_ALIAS)
	oFWMBrowse:SetDescription(STR0001) //"Features do Agrodistribuidor"
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
@since 22/09/2025
@return object, Instancia do MpFormModel
/*/
Static Function ModelDef()
	Local oMpFmodel := MpFormModel():New(MODEL_NAME)
	Local oFormStru := FwFormStruct(1, MODEL_ALIAS)
    
	oMpFmodel:AddFields(MODEL_ID_FORM_FIELD,, oFormStru)
    oMpFmodel:SetDescription(STR0001) //"Features do Agrodistribuidor"
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

/*/{Protheus.doc} AGDA090VLD
Validação de campos
@type function
@version 12
@author jean.schulze
@since 26/09/2025
@return variant, true/false
/*/
Function AGDA090VLD()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNE1      := oModel:GetModel(MODEL_ID_FORM_FIELD)
	
	If "NE1_CODIGO" $ cReadVar

		if oModel:GetOperation() == MODEL_OPERATION_INSERT .and. ExistCpo("NE1",oNE1:GetValue("NE1_CODIGO"))
			AGDHELP( STR0006, STR0007, STR0008 )
			lRet := .F.
		endif

		/*Verifica se existe o codigo*/
		if oNE1:GetValue("NE1_CODIGO") <> "TCO" /*Default*/
			oTCOservice := TCO_SERVICE():New()	
	  		oTCOservice:getFeaturesDisponiveis(oNE1:GetValue("NE1_CODIGO"))

			if len(oTCOservice:getResponse()['items']) == 0
				AGDHELP(STR0006, STR0009, STR0010 )
				lRet := .F.
			Endif

		Endif
	Endif
	
return	lRet
