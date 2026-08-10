#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDP040.CH"

#DEFINE PROG_PAR_CALC_SERVICE agd.ProgramaParidadeCalcService.agdProgramaParidadeCalcService

PUBLISH MODEL REST NAME AGDP040

/*/{Protheus.doc} AGDP040
Browse do Programa de Paridade. Tabelas NEG e NEH.
@type function
@version 12
@author jc.maldonado
@since 27/01/2025
/*/
Function AGDP040()
	Local oFWMBrowse

	If !FWAliasInDic("NEG") .Or. !FWAliasInDic("NEH")
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NEG")
	oFWMBrowse:SetDescription(STR0001) //Programa de Paridade
	oFWMBrowse:DisableDetails()
	oFWMBrowse:SetMenuDef("AGDP040")

	//Legendas
	oFWMBrowse:AddLegend("NEG->NEG_MSBLQL == '2'", "GREEN", STR0014) //Ativo
	oFWMBrowse:AddLegend("NEG->NEG_MSBLQL == '1'", "RED"  , STR0015) //Inativo

	oFWMBrowse:Activate()
Return

Static Function MenuDef()
	Local aRotina := {}
	Local cAction := "VIEWDEF.AGDP040"
	Local nAccess := 0

	ADD OPTION aRotina Title STR0003 Action cAction OPERATION OP_VISUALIZAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0004 Action cAction OPERATION OP_INCLUIR	ACCESS nAccess
	ADD OPTION aRotina Title STR0005 Action cAction OPERATION OP_ALTERAR	ACCESS nAccess
	ADD OPTION aRotina Title STR0006 Action cAction OPERATION OP_EXCLUIR	ACCESS nAccess
Return aRotina

Static Function ModelDef()
	Local oMpFmodel  := MpFormModel():New("AGDP040")
	Local oStructNEG := FwFormStruct(1, "NEG")
	Local oStructNEH := FwFormStruct(1, "NEH")
	Local oEvent     := AGDP040EVT():New()
	Local bVldMOEDRT := {|oModel, cField, cNewValue, cOldValue| AGDX010(cNewValue) .And. AGDP040VCS(oModel, cField, cNewValue, cOldValue)}

	//Cabecario
	oStructNEG:SetProperty("NEG_MOEDRT", MODEL_FIELD_VALID, bVldMOEDRT)
	oMpFmodel:SetDescription(STR0001)
	oMpFmodel:AddFields("AGDP040_NEG", , oStructNEG)
	oMpFmodel:GetModel("AGDP040_NEG"):SetDescription(STR0007) //Dados Programa de Paridade
	oMpFmodel:SetPrimaryKey({"NEG_FILIAL", "NEG_CODIGO"})

	//Grid
	oMpFmodel:AddGrid("AGDP040_NEH", "AGDP040_NEG", oStructNEH)
	oMpFmodel:GetModel("AGDP040_NEH"):SetDescription(STR0008) //Itens Programa de Paridade
	oMpFmodel:GetModel("AGDP040_NEH"):SetUniqueLine({"NEH_CODPRO"})
	oMpFmodel:GetModel("AGDP040_NEH"):SetNoInsertLine(.T.)
	oMpFmodel:GetModel("AGDP040_NEH"):SetNoDeleteLine(.T.)
	oMpFmodel:GetModel("AGDP040_NEH"):SetOptional(.F.)

	if oMpFmodel:GetOperation() != MODEL_OPERATION_UPDATE
		oMpFmodel:GetModel("AGDP040_NEH"):SetOnlyView(.T.)
	endif

	//Relacionamento das tabelas NEG e NEH
	oMpFmodel:SetRelation("AGDP040_NEH", {{"NEH_FILIAL", "FWxFilial('NEH')"},{ "NEH_CODIGO", "NEG_CODIGO" }}, NEH->(IndexKey(1)))

	oMpFmodel:InstallEvent("AGDP040EVT", /*cOwner*/, oEvent)
Return oMpFmodel

Static Function ViewDef()
	Local oView		 := FwFormView():New()
	Local oMpFmodel	 := FwLoadModel("AGDP040")
	Local oStructNEG := FwFormStruct(2, "NEG")
	Local oStructNEH := FwFormStruct(2, "NEH")

	//Cabecario
	oView:SetModel(oMpFmodel)
	oStructNEG:RemoveField("NEG_FILIAL")
	oView:AddField("VIEW_NEG", oStructNEG, "AGDP040_NEG")
	oView:EnableTitleView("VIEW_NEG")
	oView:CreateHorizontalBox("CABEC", 40)
	oView:SetOwnerView("VIEW_NEG", "CABEC")

	//Grid
	oStructNEH:RemoveField("NEH_FILIAL")
	oStructNEH:RemoveField("NEH_CODIGO")

	oView:AddGrid("VIEW_NEH", oStructNEH, "AGDP040_NEH")
	oView:AddIncrementField("VIEW_NEH", "NEH_ITEM")
	oView:EnableTitleView("VIEW_NEH")
	oView:CreateHorizontalBox("GRID", 60)
	oView:SetOwnerView("VIEW_NEH", "GRID")

	oView:SetCloseOnOk({ || .T.})
Return oView



/*/{Protheus.doc} AGDP040LDI
Carrega a lista de produtos da tabela de preço selecionada.
Função utilizada no gatilho do campo NEG_TABPRO.
@type function
@version 12
@author jc.maldonado
@since 28/01/2025
@return logical, .T.
/*/
Function AGDP040LDI()
	Local aArea 	 := FWgetArea()
	Local oModel   	 := FwModelActive()
	Local oGridNEH 	 := oModel:GetModel("AGDP040_NEH")
	Local cAlias
	Local cTabPrcOrg := oModel:GetValue("AGDP040_NEG", "NEG_TABPRO")
	Local cMoedaRT   := oModel:GetValue("AGDP040_NEG", "NEG_MOEDRT")
	Local cCodNEG    := oModel:GetValue("AGDP040_NEG", "NEG_CODIGO")
	Local nValComm	 := oModel:GetValue("AGDP040_NEG", "NEG_COMVLR")
	Local cFilNEH    := FWxFilial("NEH")
	Local oCalcPar   := PROG_PAR_CALC_SERVICE():New("", 0, 0)
	Local nValParIt
	Local oView

	oGridNEH:ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)

	cAlias := gDA1Itens(cTabPrcOrg, cMoedaRT)

	oGridNEH:SetNoInsertLine(.F.)

	While (cAlias)->(!EOF())
		oCalcPar:setPrecoProduto((cAlias)->DA1_PRCVEN)
		oCalcPar:setValorInsumo(nValComm)

		nValParIt := oCalcPar:getValorParidade((cAlias)->DA1_PRCVEN, nValComm)

		oGridNEH:AddLine()

		oGridNEH:LoadValue("NEH_FILIAL", cFilNEH             )
		oGridNEH:LoadValue("NEH_CODIGO", cCodNEG             )
		oGridNEH:LoadValue("NEH_CODPRO", (cAlias)->DA1_CODPRO)
		oGridNEH:LoadValue("NEH_DESCPR", (cAlias)->B1_DESC   )
		oGridNEH:LoadValue("NEH_CUSTO" , 0			         )
		oGridNEH:LoadValue("NEH_PRC"   , (cAlias)->DA1_PRCVEN)
		oGridNEH:LoadValue("NEH_PARIDA", nValParIt           )

		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())

	FreeObj(oCalcPar)

	oGridNEH:SetNoInsertLine(.T.)

	oGridNEH:GoLine(1)

	oView := FwViewActive()
	oView:Refresh("AGDP040_NEH")

	FwRestArea(aArea)
Return .T.

/*/{Protheus.doc} AGDP040PAR
Atualiza os valores de paridade da lista completa de produtos.
Função utilizada no gatilho do campo NEG_COMVLR.
@type function
@version 12  
@author jc.maldonado
@since 29/01/2025
@return logical, .T.
/*/
Function AGDP040PAR()
	Local nX
	Local oModel   := FwModelActive()
	Local oGridNEH := oModel:GetModel("AGDP040_NEH")
	Local nPreco
	Local nValComm
	Local oCalcPar
	Local oView

	If INCLUI .And. ! oGridNEH:IsModified()
		return .T.
	EndIf

	oCalcPar := PROG_PAR_CALC_SERVICE():New("", 0, 0)
	nValComm := oModel:GetValue("AGDP040_NEG", "NEG_COMVLR")

	For nX := 1 To oGridNEH:Length()
		oGridNEH:GoLine(nX)

		nPreco := oGridNEH:GetValue("NEH_PRC")

		oCalcPar:setPrecoProduto(nPreco)
		oCalcPar:setValorInsumo(nValComm)

		oGridNEH:LoadValue("NEH_PARIDA", oCalcPar:getValorParidade())
	Next nX

	FreeObj(oCalcPar)

	oGridNEH:GoLine(1)

	oView := FwViewActive()
	oView:Refresh("AGDP040_NEH")
Return .T.

/*/{Protheus.doc} AGDP040TRG
A partir do preço do produto e o valor RT, retorna a paridade
Função utilizada no Trigger do campo NEH_PRC
@type function
@version 12
@author jc.maldonado
@since 29/01/2025
@param nPrc, numeric, Preco do produto
@return logical, resultado do commit
/*/
Function AGDP040TRG(nPrc)
	Local oModel   	:= FwModelActive()
	Local nValComm 	:= oModel:GetValue("AGDP040_NEG", "NEG_COMVLR")
	Local oCalcPar	:= PROG_PAR_CALC_SERVICE():New("", nPrc, nValComm)
	Local nParidade := oCalcPar:getValorParidade(nPrc, nValComm)

	FreeObj(oCalcPar)
Return nParidade


/*/{Protheus.doc} gDA1Itens
Retorna o alias com os itens da tabela de preço informada, ordenando por codigo, dataVigencia decrescente, Item
@type function
@version 12
@author jc.maldonado
@since 07/02/2025
@param cCodTab, character, codigo da tabela de preço (DA0_CODTAB)
@param cCodMoeda, character, codigo da Moeda RT
@return character, alias da consulta
/*/
Static Function gDA1Itens(cCodTab, nCodMoeda)
	Local aParams := {}
	Local cQuery
	Local cAlias

	cQuery := " SELECT"
	cQuery += " 	DA1.DA1_CODPRO,"
	cQuery += " 	SB1.B1_DESC,"
	cQuery += " 	DA1.DA1_PRCVEN"
	cQuery += " FROM ("
	cQuery += " 	SELECT"
	cQuery += " 		DA1_ITEM,"
	cQuery += " 		DA1_CODPRO,"
	cQuery += " 		DA1_PRCVEN,"
	cQuery += " 		ROW_NUMBER() OVER (PARTITION BY DA1_CODPRO"
	cQuery += " 							ORDER BY DA1_CODPRO ASC, DA1_DATVIG DESC, DA1_ITEM DESC) AS RN"
	cQuery += " 	FROM "
	cQuery += " 		" + retSQLName("DA1")
	cQuery += " 	WHERE"
	cQuery += " 		DA1_FILIAL = ?"      ; aAdd(aParams, FWxFilial("DA1"))
	cQuery += " 		AND DA1_CODTAB = ?"  ; aAdd(aParams, cCodTab)
	cQuery += " 		AND DA1_MOEDA = ?"   ; aAdd(aParams, cValToChar(nCodMoeda))
	cQuery += " 		AND D_E_L_E_T_ = ''"
	cQuery += " ) DA1"
	cQuery += " JOIN"
	cQuery += " 	" + retSQLname("SB1") + " SB1 ON SB1.B1_COD = DA1.DA1_CODPRO"
	cQuery += " WHERE"
	cQuery += " 	DA1.RN = 1"
	cQuery += " 	AND SB1.B1_FILIAL = ?"  ; aAdd(aParams, FWxFilial("SB1"))
	cQuery += " 	AND SB1.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY"
	cQuery += " 	DA1.DA1_ITEM"
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlias, .F., .T.)
return cAlias



/*/{Protheus.doc} AGDP40VNEG
Validação de campos da tabela NEG via dicionario de dados SX3
@type function
@version 12
@author jc.maldonado
@since 03/03/2025
@return logical, .t. or .f.
/*/
Function AGDP40VNEG()
	Local lRet 		:= .T.
	Local cReadVar  := ReadVar()
	Local cUmPreco

	If "NEG_CMDTY" $ cReadVar .and. !Empty(M->NEG_CMDTY)
		If !ExistCpo("SB1")
			lRet := .F. //Mensagem padrão sistema
		Else
			cUmPreco  := AGDXSB5(M->NEG_CMDTY, 'B5_UMPRC')
			If ExistCpo('SB1', M->NEG_CMDTY) .AND. Empty(cUmPreco)
				AGDHELP(STR0009, STR0020, STR0021) //"Ajuda", "Produto não possui unidade de preço informado.", "Acesse o cadastro de produtos e informe o campo referente a unidade de preço(B5_UMPRC)."
				lRet := .F.
			EndIf
		EndIf
	ElseIf "NEG_TABPRO" $ cReadVar .and. !Empty(M->NEG_TABPRO)
		lRet := vldCODTABO(M->NEG_TABPRO, M->NEG_MOEDRT)
	EndIf
Return lRet

/*/{Protheus.doc} AGDP040VCS
Verifica se houve alteracao no valor do campo NEG_MOEDRT e solicita confirmacao.
Confirmando, a lista de produtos é esvaziada e o valor do campo NEG_TABPRO limpo.
Recusando, o valor do campo NEG_MOEDRT é restaurado.
@type function
@version 12
@author jc.maldonado
@since 26/03/2025
@param oMdl, object, model
@param cField, character, campo alterado
@param cNewValue, character, novo valor do campo
@param cOldValue, character, valor antigo do campo
@return logical, resultado da validacao
/*/
Function AGDP040VCS(oModel, cField, cNewValue, cOldValue)
	Local oViewAct

	If oModel:GetOperation() == MODEL_OPERATION_INSERT ;
			.And. cField == "NEG_MOEDRT" ;
			.And. cNewValue != cOldValue

		oViewAct := FwViewActive()

		If FwAlertNoYes(STR0022, STR0023) //"Ao alterar o código da moeda, os itens da lista de produtos são removidos.", "Confirmar a alteração?"
			oModel:LoadValue("NEG_TABPRO", CriaVar("NEG_TABPRO"))

			oModel:GetModel("AGDP040"):GetModel("AGDP040_NEH"):ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)
			oViewAct:Refresh("VIEW_NEH")
		Else
			oModel:LoadValue("NEG_MOEDRT", cOldValue)
			oViewAct:GetViewObj("VIEW_NEG")[3]:getFWEditCtrl("NEG_MOEDRT"):oCtrl:oGet:Refresh() //somente refresh da view nao estava atualizando o valor em tela
		EndIf

		oViewAct:Refresh("VIEW_NEG")
	Endif
Return .T.

/*/{Protheus.doc} AGDP040CPD
Adiciona complemento ao filtro da consulta padrão DA0PAR (Tabela SXB)
Filtra tabelas de preço ativas e que possuam itens ativos e com a mesma moeda definida no programa de paridade
@type function
@version 12
@author jc.maldonado
@since 26/03/2025
@return character, complemento a consulta padrao
/*/
Function AGDP040CPD()
	Local cQuery
	Local oModel    := FwModelActive()
	Local aParams   := {}
	Local cDataBase := DTOS(DDATABASE)
	Local oStatement
	Local nX        := 0

	cQuery := "@D_E_L_E_T_ = ' ' "
	cQuery += "AND DA0_ATIVO = '1' "
	cQuery += "AND DA0_DATDE <= ?"                       ; aAdd(aParams, cDataBase)
	cQuery += "AND (DA0_DATATE = '' OR DA0_DATATE >= ?)" ; aAdd(aParams, cDataBase)
	cQuery += "AND EXISTS ("
	cQuery += "	SELECT"
	cQuery += "		1"
	cQuery += "	FROM"
	cQuery += "	" + retSqlName('DA1') + " DA1"
	cQuery += "	WHERE"
	cQuery += "		DA1.DA1_FILIAL = DA0_FILIAL"
	cQuery += "		AND DA1.DA1_CODTAB = DA0_CODTAB"
	cQuery += "		AND DA1.DA1_MOEDA = ?"               ; aAdd(aParams, cValtoChar(oModel:GetValue("AGDP040_NEG", "NEG_MOEDRT")))
	cQuery += "		AND DA1.DA1_ATIVO = '1'"
	cQuery += "		AND DA1.DA1_DATVIG <= ?"             ; aAdd(aParams, cDataBase)
	cQuery += "		AND DA1.D_E_L_E_T_ = ' '"
	cQuery += ")"

	oStatement := FWPreparedStatement():New()
	oStatement:SetQuery(cQuery)
	aEval(aParams, {|cValue| (nX++, oStatement:SetString(nX, cValue))})

	cQuery := oStatement:getFixQuery()
	FreeObj(oStatement)
Return cQuery

/*/{Protheus.doc} vldCODTABO
Faz a validacao da tabela de preco informada
@type function
@version 12
@author jc.maldonado
@since 31/03/2025
@param cCodTab, character, codigo da tabela
@param nCodMoeda, numeric, codigo da moeda
@return logical, resultado da validacao
/*/
Static Function vldCODTABO(cCodTab, nCodMoeda)
	local cQuery
	local aParams := {}
	local cDataBase := DtoS(DDATABASE)
	local cAlias
	local lTabVld

	cQuery := "SELECT"
	cQuery += "     1"
	cQuery += " FROM"
	cQuery += " " + retSQLname("DA0")
	cQuery += " WHERE"
	cQuery += " 	DA0_FILIAL = ?"         ; aAdd(aParams, FWxFilial("DA0"))
	cQuery += "     AND DA0_CODTAB = ?"     ; aAdd(aParams, cCodTab)
	cQuery += "     AND DA0_ATIVO = '1'"
	cQuery += "     AND DA0_DATDE <= ?"     ; aAdd(aParams, cDataBase)
	cQuery += "     AND ("
	cQuery += "         DA0_DATATE = ''"
	cQuery += "         OR DA0_DATATE >= ?" ; aAdd(aParams, cDataBase)
	cQuery += "     )"
	cQuery += "     AND EXISTS ("
	cQuery += "         SELECT"
	cQuery += "             1"
	cQuery += "         FROM"
	cQuery += "           " + retSQLname("DA1") + " DA1"
	cQuery += "         WHERE"
	cQuery += "             DA1.DA1_FILIAL = ?"              ; aAdd(aParams, FWxFilial("DA1"))
	cQuery += "             AND DA1.DA1_CODTAB = DA0_CODTAB"
	cQuery += "             AND DA1.DA1_MOEDA = ?"           ; aAdd(aParams, cValtoChar(nCodMoeda))
	cQuery += "             AND DA1.DA1_ATIVO = '1'"
	cQuery += "             AND DA1.DA1_DATVIG <= ?"         ; aAdd(aParams, cDataBase)
	cQuery += "             AND DA1.D_E_L_E_T_ = ''"
	cQuery += "     )"
	cQuery := ChangeQuery(cQuery)

	cAlias := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cQuery, aParams), cAlias, .F., .T.)

	lTabVld := (cAlias)->(!EOF())

	(cAlias)->(DBcloseArea())
Return lTabVld
