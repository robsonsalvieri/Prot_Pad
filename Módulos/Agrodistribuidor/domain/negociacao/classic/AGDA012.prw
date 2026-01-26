#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA012.CH"

/*/{Protheus.doc} AGDA012
Browse tabela NEN - Consulta de Impostos Retidos/Recolhidos da Negociação
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Function AGDA012()
	Local oFWMBrowse := Nil

	If .Not. TableInDic("NEN")
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NEN")
	oFWMBrowse:SetDescription(STR0001) //"Impostos Retidos/Recolhidos"
	oFWMBrowse:DisableDetails()
	oFWMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Menu
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDA012"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0003 Action cAction OPERATION OP_VISUALIZAR	ACCESS nAccess
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Modelo
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Static Function ModelDef()
	Local oModel    := Nil
	Local oStrField := Nil
	Local oStrGrid  := Nil

	oStrField := FWFormModelStruct():New()
	oStrField:AddTable("", {"T_CODNEG","T_DATA","T_HORA" ,"T_CODFOR","T_LOJFOR"}, "HIDE", {|| ""})
	oStrField:AddField("T_CODNEG", RetTitle("NEN_CODNEG"), "T_CODNEG", "C", TamSX3("NEN_CODNEG")[1])
	oStrField:AddField("T_DATA"  , RetTitle("NEN_DATA")  , "T_DATA"  , "D", TamSX3("NEN_DATA")[1])
	oStrField:AddField("T_HORA"  , RetTitle("NEN_HORA")  , "T_HORA"  , "C", TamSX3("NEN_HORA")[1])
	oStrField:AddField("T_CODFOR", RetTitle("NEN_CODFOR"), "T_CODFOR", "C", TamSX3("NEN_CODFOR")[1])
	oStrField:AddField("T_LOJFOR", RetTitle("NEN_LOJFOR"), "T_LOJFOR", "C", TamSX3("NEN_LOJFOR")[1])
	oStrField:AddField("T_TES"   , RetTitle("NEN_TES")   , "T_TES"   , "C", TamSX3("NEN_TES")[1])
	oStrField:AddField("T_NATURE", RetTitle("NEN_NATURE"), "T_NATURE", "C", TamSX3("NEN_NATURE")[1])

	oStrField:SetProperty("T_CODNEG", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('NEA', FWFldGet('T_CODNEG'), 1)"))
	oStrField:SetProperty("T_CODFOR", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA2', FWFldGet('T_CODFOR'), 1)"))
	oStrField:SetProperty("T_LOJFOR", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA2', FWFldGet('T_CODFOR') + FWFldGet('T_LOJFOR'), 1)"))
	oStrField:SetProperty("T_TES"   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SF4', FWFldGet('T_TES'),1)"))
	oStrField:SetProperty("T_NATURE", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "VAZIO() .OR. ExistCpo('SED', FWFldGet('T_NATURE'), 1)"))

	oStrGrid := FWFormStruct(1, "NEN")
	oStrGrid:SetProperty('NEN_FILIAL', MODEL_FIELD_INIT, {|| FWxFilial("NEN")})
	oStrGrid:SetProperty('NEN_CODNEG', MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_CODNEG") != Nil, FWFldGet("T_CODNEG"), "")})
	oStrGrid:SetProperty('NEN_DATA'  , MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_DATA")   != Nil, FWFldGet("T_DATA")  , "")})
	oStrGrid:SetProperty('NEN_HORA'  , MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_HORA")   != Nil, FWFldGet("T_HORA")  , "")})
	oStrGrid:SetProperty('NEN_CODFOR', MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_CODFOR") != Nil, FWFldGet("T_CODFOR"), "")})
	oStrGrid:SetProperty('NEN_LOJFOR', MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_LOJFOR") != Nil, FWFldGet("T_LOJFOR"), "")})
	oStrGrid:SetProperty('NEN_TES'   , MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_TES")    != Nil, FWFldGet("T_TES")   , "")})
	oStrGrid:SetProperty('NEN_NATURE', MODEL_FIELD_INIT, {|| Iif(FWFldGet("T_NATURE") != Nil, FWFldGet("T_NATURE"), "")})

	oModel := MPFormModel():New("AGDA012",,, {|oModel| fCommit(oModel)})

	oModel:AddFields("CABEC", , oStrField, , , { || {} })
	oModel:AddGrid("GRID", "CABEC", oStrGrid,,,,)
	oModel:GetModel("GRID"):SetUseOldGrid(.T.)
	oModel:GetModel("GRID"):SetUniqueLine({"NEN_FILIAL", "NEN_CODNEG", "NEN_DATA", "NEN_HORA", "NEN_REGRA", "NEN_IDTRIB"})
	oModel:GetModel("GRID"):SetOptional(.F.)

	oModel:SetPrimaryKey(FWSIXUtil():GetAliasIndexes("NEN")[1])
Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Static Function ViewDef()
	Local oView    := Nil
	Local oModel   := Nil
	Local oStrCab  := Nil
	Local oStrGrid := Nil

	oStrCab := FWFormViewStruct():New()
	oStrCab:AddField("T_CODNEG", "01", RetTitle("NEN_CODNEG"), RetTitle("NEN_CODNEG"),, "C")
	oStrCab:AddField("T_DATA"  , "02", RetTitle("NEN_DATA")  , RetTitle("NEN_DATA")  ,, "C")
	oStrCab:AddField("T_HORA"  , "03", RetTitle("NEN_HORA")  , RetTitle("NEN_HORA")  ,, "C")
	oStrCab:AddField("T_CODFOR", "04", RetTitle("NEN_CODFOR"), RetTitle("NEN_CODFOR"),, "C")
	oStrCab:AddField("T_LOJFOR", "05", RetTitle("NEN_LOJFOR"), RetTitle("NEN_LOJFOR"),, "C")
	oStrCab:AddField("T_TES"   , "06", RetTitle("NEN_TES")   , RetTitle("NEN_TES")   ,, "C")
	oStrCab:AddField("T_NATURE", "07", RetTitle("NEN_NATURE"), RetTitle("NEN_NATURE"),, "C")

	oStrGrid := FWFormStruct(2, "NEN")
	oStrGrid:RemoveField("NEN_CODNEG")
	oStrGrid:RemoveField("NEN_DATA")
	oStrGrid:RemoveField("NEN_HORA")
	oStrGrid:RemoveField("NEN_CODFOR")
	oStrGrid:RemoveField("NEN_LOJFOR")
	oStrGrid:RemoveField("NEN_TES")
	oStrGrid:RemoveField("NEN_NATURE")

	oModel := FWLoadModel("AGDA012")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStrCab, "CABEC")
	oView:AddGrid("VIEW_GRID", oStrGrid, "GRID")

	oView:CreateHorizontalBox("TOHID", 0)
	oView:CreateHorizontalBox("TOSHOW", 100)

	oView:SetOwnerView("VIEW_CAB", "TOHID")
	oView:SetOwnerView("VIEW_GRID", "TOSHOW")
	oView:enableTitleView("VIEW_GRID", STR0002) //"Itens"
	oView:SetCloseOnOk({ || .T.})
Return oView

/*/{Protheus.doc} fCommit
Função responsavel por incluir e remover registros
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oModel, object, modelo
@return logical, resultado da oprecao
/*/
Static Function fCommit(oModel)
	Local nOperation := oModel:getOperation()

	DbSelectArea("NEN")
	NEN->(DbSetOrder(1))
	NEN->(DbGoTop())

	If nOperation == MODEL_OPERATION_INSERT
		fInsert(oModel:GetModel("GRID"))

	ElseIf nOperation == MODEL_OPERATION_DELETE

		fDelete()
	Endif
Return .T.

/*/{Protheus.doc} fDelete
Remove os registros da NEN a apartir do NEA->NEA_CODIGO posicionado
@type function
@version 12
@author jc.maldonado
@since 15/05/2025
@param cCodNeg, character, codigo da negociacao
/*/
Static Function fDelete()
	Local cFilNEN := FWxFilial("NEN")

	DbSelectArea("NEN")
	NEN->(DbSetOrder(1))
	NEN->(DbGoTop())

	If !empty((cCodNeg :=  NEA->NEA_CODIGO));
			.And. NEN->(DBSeek(cFilNEN + cCodNeg))

		Begin Transaction
			While NEN->NEN_FILIAL == cFilNEN;
					.And. NEN->NEN_CODNEG == cCodNeg;
					.And. NEN->(!EOF())

				NEN->(RecLock("NEN", .F.))
				NEN->(DbDelete())
				NEN->(MsUnLock())

				NEN->(dbSkip())
			EndDo
		End Transaction
	EndIf
Return

/*/{Protheus.doc} fInsert
Insere registros na tabela NEN a partir da Grid
@type function
@version 12
@author jc.maldonado
@since 15/05/2025
@param oGrid, object, Grid
/*/
Static Function fInsert(oGrid)
	Local nX      := 0
	Local nY      := 0
	Local aCampos := FWSX3Util():GetAllFields("NEN", .F.)

	DbSelectArea("NEN")

	Begin Transaction
		For nX := 1 to oGrid:Length()
			oGrid:GoLine(nX)

			If !oGrid:IsDeleted()
				NEN->(RecLock("NEN", .T.))
				For nY := 1 to Len(aCampos)
					FieldPut(FieldPos(aCampos[nY]), oGrid:GetValue(aCampos[nY]))
				Next nY
				NEN->(MSUnlock())
			endif
		Next nX
	End Transaction
Return
