#Include "agdp090.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE MODEL_NAME "AGDP090"
#DEFINE MODEL_ALIAS "NE3"
#DEFINE MODEL_ALIAS_SON "NE4"
#DEFINE MODEL_ID_FORM_FIELD MODEL_NAME + "_" + MODEL_ALIAS
#DEFINE MODEL_ID_FORM_FIELD_SON MODEL_NAME + "_" + MODEL_ALIAS_SON
#DEFINE FIELD_RELATION "TOOL" //NE4_TOOL

/*/{Protheus.doc} AGDP090
Browse de Features do módulo 54 - Agrodistribuidor (SIGAAGD) - Tabela NE1
@type function
@version 12
@author jc.maldonado
@since 22/09/2025
/*/
Function AGDP090()
	Local oFWMBrowse := Nil

	If ! FWAliasInDic(MODEL_ALIAS)
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias(MODEL_ALIAS)
	oFWMBrowse:SetDescription(STR0001)  //"Tools do DTA"
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
    Local oFormSon := FwFormStruct(1, MODEL_ALIAS_SON)

	oMpFmodel:AddFields(MODEL_ID_FORM_FIELD,, oFormStru)
    oMpFmodel:SetDescription(STR0001)  //"Tools do DTA"
	oMpFmodel:SetPrimaryKey(FWSIXUtil():GetAliasIndexes(MODEL_ALIAS)[1])
	
	oMpFmodel:AddGrid(MODEL_ID_FORM_FIELD_SON, MODEL_ID_FORM_FIELD, oFormSon)
	oMpFmodel:GetModel(MODEL_ID_FORM_FIELD_SON ):SetDescription( STR0006 ) //#"Itens Solicitação de Receita" //"Complementos"

	//Atribui um relacionamento de Pai X Filho
	oMpFmodel:SetRelation(MODEL_ID_FORM_FIELD_SON, {{MODEL_ALIAS_SON+'_FILIAL', 'xFilial("'+MODEL_ALIAS_SON+'")'},{ MODEL_ALIAS_SON+"_"+FIELD_RELATION, MODEL_ALIAS+"_"+FIELD_RELATION }}, &(MODEL_ALIAS_SON+"->(IndexKey( 1 ))") )
	oMpFmodel:GetModel( MODEL_ID_FORM_FIELD_SON ):SetOptional( .T. )
	oMpFmodel:GetModel( MODEL_ID_FORM_FIELD_SON ):SetUniqueLine( { MODEL_ALIAS_SON +'_ITEM' } )
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
	Local oView		 := FwFormView():New()
	Local oModel	 := FwLoadModel(MODEL_NAME)
	Local oFormStru  := FwFormStruct(2, MODEL_ALIAS)
	Local oFormSon   := FwFormStruct(2, MODEL_ALIAS_SON)
    Local cViewID    := "VIEW_" + MODEL_ALIAS
	Local cViewSonID := "VIEW_" + MODEL_ALIAS_SON

	oFormSon:RemoveField( MODEL_ALIAS_SON+"_"+FIELD_RELATION)

	oView:SetModel(oModel)
	oView:AddField(cViewID, oFormStru, MODEL_ID_FORM_FIELD)

	oView:AddGrid( cViewSonID, oFormSon, MODEL_ID_FORM_FIELD_SON )
	
	oView:CreateHorizontalBox( 'CABEC', 50 )
	oView:CreateHorizontalBox( 'GRID', 50 )

	oView:SetOwnerView( cViewID, 'CABEC' )
	oView:SetOwnerView( cViewSonID, 'GRID' )

	oView:EnableTitleView(cViewSonID)
	oView:EnableTitleView(cViewID)
	oView:SetCloseOnOk({|| .T.})
Return oView

/*/{Protheus.doc} AGDP090VLD
Validação do campo de Tool
@type function
@version 12
@author jean.schulze
@since 21/11/2025
@return variant, true/false
/*/
Function AGDP090VLD()
	Local lRet 		:= .T.
	Local nX        := 0
	Local cReadVar  := ReadVar()
	Local oModel    := FwModelActive()
	Local oNE3      := oModel:GetModel(MODEL_ID_FORM_FIELD)
	Local oNE4      := oModel:GetModel(MODEL_ID_FORM_FIELD_SON)
	Local nSeq      := 0

	If "NE3_TOOL" $ cReadVar

		if oModel:GetOperation() == MODEL_OPERATION_INSERT .and. ExistCpo("NE3",oNE3:GetValue("NE3_TOOL"))
			AGDHELP( STR0009, STR0008, STR0007 ) //"Para ajustar a tool utilize a opção de atualizar." //"Tool já informada" //"Ajuda"
			lRet := .F.
		endif

		//retorna a tool
		aTool := agdDTAToolsEnum():getById(oNE3:GetValue("NE3_TOOL"))

		if len(aTool) > 0
			cDadosTool := &(aTool+":getSetup()")

			oNE3:setValue("NE3_DESCRI", cDadosTool['description'])	
			oNE3:setValue("NE3_DESSHT", cDadosTool['shortDescription'])				
			oNE3:setValue("NE3_REGRAS", cDadosTool['rules'])	
			oNE3:setValue("NE3_PARAM",  cDadosTool['parameters']:toJSON())

			//remove todas as linhas	
			oNE4:DelAllLine()

			For nX:= 1 to Len(cDadosTool["glossary"] )
				nSeq++
				oNE4:addLine()
				oNE4:setValue("NE4_ITEM", PadL(nSeq, TamSX3( "NE4_ITEM" )[1], "0"))	
				oNE4:setValue("NE4_TIPO", "G")	
				oNE4:setValue("NE4_CHAVE", cDadosTool['glossary'][nX]['property'])	
				oNE4:setValue("NE4_VALOR", cDadosTool['glossary'][nX]['description'])	
			Next

			For nX:= 1 to Len(cDadosTool["examples"] )
				nSeq++
				oNE4:addLine()
				oNE4:setValue("NE4_ITEM", PadL(nSeq, TamSX3( "NE4_ITEM" )[1], "0"))	
				oNE4:setValue("NE4_TIPO", "E")	
				oNE4:setValue("NE4_CHAVE", cDadosTool['examples'][nX]['sequence'])	
				oNE4:setValue("NE4_VALOR", cDadosTool['examples'][nX]['description'])	
			Next

		else
			AGDHELP(STR0009,STR0011, STR0010 ) //"Informe uma tool válida." //"Tool informada Inválida" //"Ajuda"
			lRet := .F.
		Endif
		
	Endif
return lRet

