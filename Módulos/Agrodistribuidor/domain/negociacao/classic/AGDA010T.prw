#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'AGDA010T.CH'
#DEFINE NEGOCIO_IMPOSTOS agd.negocioImpostosService.agdNegocioImpostosService

Static __AGDA010T  := {}  //armazena os valores da grid
Static __cCodNeg   := ""
Static __lConsulta := .F. //controla a necessidade de uma nova consulta

/*/{Protheus.doc} AGDA010T
Tela para consulta de impostos retidos/recolhidos da negociacao
Apenas MODEL_OPERATION_INSERT, MODEL_OPERATION_VIEW
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param nOperation, numeric, numero da operacao
@param aTaxes, array, lista de impostos
@param cCodNeg, character, codigo da negociacao
@param cCodCli, character, codigo cliente/fornecedor
@param cLojCli, character, codigo loja cliente/fornecedor
@param cMoedRT, character, codigo Moeda RT
@param nTxMoeda, numeric, valor Tx Moeda
@param cCodPro, character, codigo do produto RT
@param nVlrRT, numeric, valor do RT
@param cTes, character, codigo da TES
@param cNaturez, character, codigo da Natureza
@return array, lista de impostos
/*/
Function AGDA010T(nOperation, aTaxes, cCodNeg, cMoedRT, nTxMoeda, cCodPro, nVlrRT, cTes, cNaturez)
	Local aArea      := FWgetArea()
	Local oMdlTax    := Nil
	Local oMdlTaxCab := Nil
	Local oExecView  := Nil
	Local aRet       := {}
	Local aButtons   := {{.F.,/*Copiar*/},{.F.,/*Recortar*/},{.F.,/*Colar*/},{.F.,/*Calculadora*/},{.F.,/*Spool*/},;
		{.F.,/*Imprimir*/},{.F.,/*Confirmar*/},{.T., STR0001/*Cancelar*/},{.F.,/*WalkTrhough*/},; //Fechar
		{.F.,/*Ambiente*/},{.F.,/*Mashup*/},{.F.,/*Help*/},{.F.,/*Formulário HTML*/},{.F.,/*ECM*/}} 

	Default aTaxes := {}

	__cCodNeg := cCodNeg

	oMdlTax := FWLoadModel("AGDA010T")
	oMdlTax:SetOperation(nOperation)
	oMdlTax:Activate()

	oExecView  := FWViewExec():New()

	if nOperation == MODEL_OPERATION_VIEW
		oView := FWLoadView("AGDA010T")
		oView:aUserBoxs[aScan(oView:aUserBoxs, {|xIt| xIt:cCLientId == "CABEC"})]:nPercetual := 0
		oView:aUserBoxs[aScan(oView:aUserBoxs, {|xIt| xIt:cCLientId == "GRID"})]:nPercetual  := 85

		oExecView:setView(oView)
	else
		If empty(cCodPro)
			AGDHELP(STR0006, STR0002, STR0003)//"AJUDA, "Produto RT inválido.", "Informe um produto válido."
			return
		Endif

		if nVlrRT <= 0
			AGDHELP(STR0006, STR0004, STR0005)//"AJUDA, "Valor RT inválido.", "Informe o Valor RT"
			return
		Endif

		oMdlTaxCab := oMdlTax:GetModel("CABECARIO")
		oMdlTaxCab:LoadValue("T_CODNEG" , cCodNeg )
		oMdlTaxCab:LoadValue("T_MOEDA"  , cMoedRT )
		oMdlTaxCab:LoadValue("T_TXMOEDA", nTxMoeda)
		oMdlTaxCab:LoadValue("T_CODPRO" , cCodPro )
		oMdlTaxCab:LoadValue("T_VLRRT"  , nVlrRT  )
		oMdlTaxCab:LoadValue("T_QUANT"  , 1       )
		oMdlTaxCab:LoadValue("T_FRETE"  , 0       )
		oMdlTaxCab:LoadValue("T_DESPESA", 0       )
		oMdlTaxCab:LoadValue("T_SEGURO" , 0       )
		oMdlTaxCab:LoadValue("T_DESCONT", 0       )

		if !empty(cTes)
			oMdlTaxCab:LoadValue("T_TES", cTes)
			oMdlTaxCab:GetStruct():SetProperty("T_TES" , MODEL_FIELD_WHEN , {|| .F.})
		endif

		if !empty(cNaturez)
			oMdlTaxCab:LoadValue("T_NATURE", cNaturez)
			oMdlTaxCab:GetStruct():SetProperty("T_NATURE", MODEL_FIELD_WHEN, {|| .F.})
		endif

		if empty(aTaxes)
			AGDA10TIMP(oMdlTax:GetModel("LISTA"), .T./*carregaGrid*/)
		else
			loadAtax(aTaxes, oMdlTax:GetModel("LISTA"))
		endif

		oMdlTax:lModify := .F.
		__lConsulta := ! oMdlTax:GetModel("LISTA"):IsEmpty()
	endif

	if nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
		aButtons[7] := {.T.,} //Confirmar
	endif

	oExecView:SetTitle(oMdlTax:GetDescription())
	oExecView:setSource("AGDA010T")
	oExecView:SetModel(oMdlTax)
	oExecView:SetOperation(nOperation)
	oExecView:SetReduction(10)
	oExecView:setButtons(aButtons)
	oExecView:openView(.T.)

	aRet := aClone(__AGDA010T)
	__AGDA010T  := {}
	__cCodNeg   := ""
	__lConsulta := .F.

	FWrestArea(aArea)
Return aRet

/*/{Protheus.doc} ModelDef
Definição do modelo
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Static Function ModelDef
	Local oModel   := Nil
	Local oStruCab := fGetStruct(oModel, 1)
	Local oStruNEN := FWFormStruct(1, "NEN")

	oModel := MPFormModel():New("AGDA010T",,{|oModel| fpreVld(oModel)}, {|| .T.})

	oModel:SetDescription(FwSX2Util():GetX2Name("NEN"))

	oModel:AddFields("CABECARIO", , oStruCab, , , { || {} })
	oModel:GetModel("CABECARIO"):SetDescription(STR0007) //"Dados"

	oStruNEN:SetProperty("NEN_DESCT", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, ""))
	oStruNEN:SetProperty("NEN_DESCI", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, ""))
	oStruNEN:AddTrigger("NEN_ALIQF", "NEN_VALFIN", {|| .T.}, {|| Round((FWFldGet("T_VLRRT") / 100) * FWFldGet("NEN_ALIQF"), 2)})

	oModel:AddGrid("LISTA", "CABECARIO", oStruNEN,,,,,{|oMdl| AGDA10TIMP(oMdl, .F.)})
	oModel:GetModel("LISTA"):SetDescription(STR0008) //"Itens"
	oModel:GetModel("LISTA"):SetNoInsertLine(.T.)
	oModel:GetModel("LISTA"):SetNoDeleteLine(.T.)
	oModel:GetModel("LISTA"):SetOptional(.F.)
	oModel:GetModel("LISTA"):SetUseOldGrid(.T.)

	oModel:SetPrimaryKey(FWSIXUtil():GetAliasIndexes("NEN")[1])

	oModel:AddCalc("TOTAIS", "CABECARIO", "LISTA", 'NEN_VALFIN', 'TOTALIMP' ,'SUM',{||.t.},,STR0009,) //"Total Impostos"
	oModel:GetModel("TOTAIS"):SetDescription(STR0010) //"Total"
Return oModel

/*/{Protheus.doc} ViewDef
Definição da View
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
/*/
Static Function ViewDef
	Local oModel   := FwLoadModel("AGDA010T")
	Local oStruCab := fGetStruct(oModel, 2)
	Local oStruNEN := FwFormStruct(2, "NEN")
	Local oCalc    := FWCalcStruct(oModel:GetModel("TOTAIS"))
	Local oView    := FwFormView():New()

	oStruCab:RemoveField("T_CODNEG")
	oStruCab:RemoveField("T_VLRRT")
	oStruCab:RemoveField("T_CODPRO")
	oStruCab:RemoveField("T_QUANT")
	oStruCab:RemoveField("T_MOEDA")
	oStruCab:RemoveField("T_TXMOEDA")
	oStruCab:RemoveField("T_FRETE")
	oStruCab:RemoveField("T_SEGURO")
	oStruCab:RemoveField("T_DESCONT")
	oStruCab:RemoveField("T_DESPESA")

	oStruNEN:RemoveField("NEN_FILIAL")
	oStruNEN:RemoveField("NEN_CODNEG")
	oStruNEN:RemoveField("NEN_CODFOR")
	oStruNEN:RemoveField("NEN_LOJFOR")
	oStruNEN:RemoveField("NEN_TES")
	oStruNEN:RemoveField("NEN_NATURE")
	oStruNEN:RemoveField("NEN_DATA")
	oStruNEN:RemoveField("NEN_HORA")

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB" , oStruCab, "CABECARIO")
	oView:AddGrid("VIEW_NEN"  , oStruNEN, "LISTA")
	oView:AddField("VIEW_CALC", oCalc   , "TOTAIS")

	oView:CreateHorizontalBox("CABEC" , 15)
	oView:CreateHorizontalBox("GRID"  , 70)
	oView:CreateHorizontalBox("RODAPE", 15)

	oView:SetOwnerView("VIEW_CAB" , "CABEC")
	oView:SetOwnerView("VIEW_NEN" , "GRID")
	oView:SetOwnerView("VIEW_CALC", "RODAPE")

	oView:AddUserButton(STR0011, "", {|oView| FWMsgRun(, {|oSay| fGetTaxes(oView) }, STR0012, STR0013)}, , , {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE}, .T.) //"Consultar" "Consultando Tributos", "Aguarde..."

	oView:SetCloseOnOk({||.T.})
return oView

/*/{Protheus.doc} fGetStruct
Retorna FWFormModelStruct e FWFormViewStruct customizados
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oMdl, object, modelo
@param nOption, numeric, 1=FWFormModelStruct, 2=FWFormViewStruct
@return Object, FWFormModelStruct ou FWFormViewStruct
/*/
Static Function fGetStruct(oMdl, nOption)
	Local aTempField := {"NEN_CODNEG", "NEN_CODFOR", "NEN_LOJFOR", "NEN_TES", "NEN_NATURE","NEA_VLRRT",;
		"NEA_CODPRO", "D2_QUANT", "F2_MOEDA", "F2_TXMOEDA", "F2_FRETE", "F2_SEGURO", "F2_DESCONT", "F2_DESPESA"}

Return Iif(nOption == 1, fGStruMTmp(oMdl, aTempField), fGStruVTmp(oMdl, aTempField))

/*/{Protheus.doc} fGStruMTmp
Retorna FWFormModelStruct customizado
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oMdl, object, modelo
@param aTempField, array, lista de campos para se basear ao criar a estrutura
@return object, FWFormModelStruct
/*/
Static Function fGStruMTmp(oMdl, aTempField)
	Local nX         := 0
	Local cObriField := "NEN_CODNEG|NEN_CODFOR|NEN_LOJFOR|NEN_TES|NEA_VLRRT|F2_MOEDA|NEA_CODPRO|D2_QUANT"
	Local aStruField := {}
	Local cTmpField  := ""
	Local oStruCab   := FWFormModelStruct():New()

	For nX := 1 to Len(aTempField)
		aStruField := FWSX3Util():GetFieldStruct(aTempField[nX])
		cTmpField  := "T_" + Right(aTempField[nX], len(aTempField[nX]) - At("_", aTempField[nX]))

		oStruCab:AddField(RetTitle(aTempField[nX]),;  // cTitulo
		FWSX3Util():GetDescription(aTempField[nX]),;  // cTooltip
		cTmpField,;                                   // cIdField
		aStruField[2],;								  // cTipo
		aStruField[3],;                               // nTamanho
		aStruField[4],;				                  // nDecimais
		FwBuildFeature(STRUCT_FEATURE_VALID, ".T."),; // bValid
		FwBuildFeature(STRUCT_FEATURE_WHEN, ""),;     // bWhen
		Nil,;                                         // aValues
		aTempField[nX] $ cObriField,;                 // lObrigat
		nil) 										  // bInit
	Next nX

	oStruCab:SetProperty("T_CODFOR", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA2', FWFldGet('T_CODFOR'), 1)"))
	oStruCab:SetProperty("T_LOJFOR", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SA2', FWFldGet('T_CODFOR') + FWFldGet('T_LOJFOR'), 1)"))
	oStruCab:SetProperty("T_TES"   , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "ExistCpo('SF4', FWFldGet('T_TES'),1)"))
	oStruCab:SetProperty("T_NATURE", MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "VAZIO() .OR. ExistCpo('SED', FWFldGet('T_NATURE'), 1)"))

	oStruCab:SetProperty("T_LOJFOR", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "01"))

	oStruCab:AddTrigger("T_CODFOR", "T_LOJFOR", {|| NaoVazio()}, {|| SA2->A2_LOJA})
	oStruCab:AddTrigger("T_CODFOR", "T_CODFOR", {|| .T.}, {|| AGDA010TCL()})
	oStruCab:AddTrigger("T_TES"   , "T_TES"   , {|| .T.}, {|| AGDA010TCL()})
	oStruCab:AddTrigger("T_NATURE", "T_NATURE", {|| .T.}, {|| AGDA010TCL()})
Return oStruCab

/*/{Protheus.doc} fGStruVTmp
Retorna FWFormViewStruct customizado
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oModel, object, modelo
@param aTempOrig, array, lista de campos que a estrutura foi baseada
@return object, FWFormViewStruct
/*/
Static Function fGStruVTmp(oModel, aTempOrig)
	Local nX         := 0
	Local cOrigName  := ""
	Local aTempField := oModel:getModel("CABECARIO"):OFORMMODELSTRUCT:getFields()
	Local oStruCab   := FWFormViewStruct():New()
	Local cBloqField := "T_LOJFOR"

	For nX := 1 to Len(aTempField)
		cOrigName := aTempOrig[aScan(aTempOrig, {|xIt| strTran(aTempField[nX, 3], "T_", "") $ xIt})]

		oStruCab:AddField(aTempField[nX, 3],;                                                  // cIdField
		STRZERO(nX, 2),;                                          					           // cOrdem
		aTempField[nX, 1],;                                                                    // cTitulo
		FWSX3Util():GetDescription(cOrigName),;                                                // cDescric
		GetHlpSoluc(cOrigName),;                                                               // aHelp
		aTempField[nX, 4],;				                                                       // cType
		Alltrim(GetSx3Cache(cOrigName, "X3_PICTURE")),;                                        // cPicture
		FWBuildFeature(STRUCT_FEATURE_PICTVAR, alltrim(GetSx3Cache(cOrigName, "X3_PICTVAR"))),;// bPictVar
		Alltrim(GetSx3Cache(cOrigName, "X3_F3")),;                                             // cLookUp
		iif(aTempField[nX, 3] $ cBloqField, .F., .T.),;                                  	   // lCanChange
		nil,;                                                                                  // cFolder
		nil,;                                                                                  // cGroup
		nil,;                                                         			               // aComboValues
		nil,;                                                                                  // nMaxLenCombo
		nil,;                                										           // cIniBrow
		.T.,;                        	 											           // lVirtual
		Alltrim(GetSx3Cache(cOrigName, "X3_PICTVAR")))                                         // cPictVar
	Next nX
Return oStruCab

/*/{Protheus.doc} fGetTaxes
Função responsável por buscar os impostos e alimentar a grid
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oView, object, View
/*/
Static Function fGetTaxes(oView)
	Local aArea    := FWgetArea()
	Local aErro    := {}
	Local nX       := 0
	Local oModel   := oView:getModel()
	Local oGrid    := oModel:GetModel("LISTA")
	Local oCabec   := oModel:getModel("CABECARIO")
	Local cFilNEN  := FWxFilial("NEN")
	Local oTax     := Nil
	Local oJsonRet := Nil
	Local cTime    := ""

	if !oCabec:VldData()
		aErro := oModel:GetErrorMessage()
		AGDHELP(aErro[MODEL_MSGERR_ID], aErro[MODEL_MSGERR_MESSAGE], aErro[MODEL_MSGERR_SOLUCTION])
		Return
	EndIf

	oModel:GetModel("TOTAIS"):SetValue("TOTALIMP", 0)
	oGrid:ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)

	__lConsulta := .F.

	aValores := {;
		oCabec:getValue("T_MOEDA"),;
		oCabec:getValue("T_TXMOEDA"),;
		oCabec:getValue("T_FRETE"),;
		oCabec:getValue("T_DESPESA"),;
		oCabec:getValue("T_SEGURO"),;
		oCabec:getValue("T_DESCONT")}

	aProduto := {;
		oCabec:getValue("T_CODPRO"),;
		oCabec:getValue("T_QUANT"),;
		oCabec:getValue("T_VLRRT") ,;
		oCabec:getValue("T_NATURE"),;
		oCabec:getValue("T_TES")}

	oTax := NEGOCIO_IMPOSTOS():New(oModel:getModel("CABECARIO"):getValue("T_CODFOR"), oModel:getModel("CABECARIO"):getValue("T_LOJFOR"), oCabec:getValue("T_MOEDA"),oCabec:getValue("T_TXMOEDA"),;
									oCabec:getValue("T_CODPRO"),oCabec:getValue("T_QUANT"),oCabec:getValue("T_VLRRT"),oCabec:getValue("T_NATURE"),oCabec:getValue("T_TES"))
	If oTax:fetchTaxes()
		oJsonRet := JsonObject():New()
		oJsonRet:FromJson(oTax:getTaxes())

		oTax:destroy()

		oGrid:SetNoInsertLine(.F.)

		cTime := time()

		For nX := 1 to Len(oJsonRet['impostos'])
			oGrid:AddLine()
			oGrid:LoadValue("NEN_FILIAL", cFilNEN)
			oGrid:LoadValue("NEN_CODNEG", oModel:getModel("CABECARIO"):GetValue("T_CODNEG"))
			oGrid:LoadValue("NEN_DATA"  , dDaTaBase)
			oGrid:LoadValue("NEN_HORA"  , cTime)
			oGrid:LoadValue("NEN_CODFOR", oModel:getModel("CABECARIO"):GetValue("T_CODFOR"))
			oGrid:LoadValue("NEN_LOJFOR", oModel:getModel("CABECARIO"):GetValue("T_LOJFOR"))
			oGrid:LoadValue("NEN_TES"   , oModel:getModel("CABECARIO"):GetValue("T_TES"))
			oGrid:LoadValue("NEN_NATURE", oModel:getModel("CABECARIO"):GetValue("T_NATURE"))
			oGrid:LoadValue("NEN_IDTRIB", oJsonRet['impostos'][nX]['codigoTributo'] )
			oGrid:LoadValue("NEN_DESCT" , oJsonRet['impostos'][nX]['descricaoTributo'])
			oGrid:LoadValue("NEN_REGRA" , oJsonRet['impostos'][nX]['codigoRegra'])
			oGrid:LoadValue("NEN_DESCI" , oJsonRet['impostos'][nX]['descricaoRegra'])
			oGrid:LoadValue("NEN_ALIQS" , oJsonRet['impostos'][nX]['aliquotaTributo'])
			oGrid:LoadValue("NEN_ALIQF" , oJsonRet['impostos'][nX]['aliquotaTributo'])
			oGrid:LoadValue("NEN_VALSIS", oJsonRet['impostos'][nX]['valorTributo'])
			oGrid:LoadValue("NEN_VALFIN", oJsonRet['impostos'][nX]['valorTributo'])
		Next nX
	Else
		AGDHELP(STR0006, oTax:getMessageError()) //AJUDA
	Endif

	oTax:destroy()
	FWFreeObj(oTax)
	FWFreeObj(oJsonRet)

	oGrid:SetNoInsertLine(.T.)
	oGrid:GoLine(1)

	oView := FwViewActive()
	oView:Refresh("LISTA")

	FWrestArea(aArea)
Return

/*/{Protheus.doc} loadAtax
Funcao responsavel por carregar lista de impostos pre-definida
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param aTaxes, array, lista de impostos
@param oGrid, object, Lista
/*/
Static Function loadAtax(aTaxes, oGrid)
	Local nX := 0

	oGrid:SetNoInsertLine(.F.)
	oGrid:ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)

	For nX := 1 to Len(aTaxes[2/*aCols*/])
		oGrid:AddLine()
		oGrid:LoadValue("NEN_FILIAL", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_FILIAL"})])
		oGrid:LoadValue("NEN_CODNEG", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_CODNEG"})])
		oGrid:LoadValue("NEN_DATA"  , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_DATA"  })])
		oGrid:LoadValue("NEN_HORA"  , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_HORA"  })])
		oGrid:LoadValue("NEN_CODFOR", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_CODFOR"})])
		oGrid:LoadValue("NEN_LOJFOR", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_LOJFOR"})])
		oGrid:LoadValue("NEN_TES"   , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_TES"   })])
		oGrid:LoadValue("NEN_NATURE", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_NATURE"})])
		oGrid:LoadValue("NEN_IDTRIB", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_IDTRIB"})])
		oGrid:LoadValue("NEN_DESCT" , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_DESCT" })])
		oGrid:LoadValue("NEN_REGRA" , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_REGRA" })])
		oGrid:LoadValue("NEN_DESCI" , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_DESCI" })])
		oGrid:LoadValue("NEN_ALIQS" , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_ALIQS" })])
		oGrid:LoadValue("NEN_VALSIS", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_VALSIS"})])
		oGrid:LoadValue("NEN_ALIQF" , aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_ALIQF" })])
		oGrid:LoadValue("NEN_VALFIN", aTaxes[2, nX, aScan(aTaxes[1], {|xIt| xIt[2] == "NEN_VALFIN"})])
	Next nX

	oGrid:SetNoInsertLine(.T.)
	oGrid:GoLine(1)
Return

/*/{Protheus.doc} fConfirma
Função que valida e armazena os dados da lista
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oModel, object, modelo
@return logical, .t. or .f.
/*/
Static Function fpreVld(oModel)
	If __lConsulta
		AGDHELP(STR0006, STR0014, STR0015) //"AJUDA", "Nenhuma consulta foi realizada.", "É necessário realizar uma nova consulta." 
		return .F.
	Endif

	__AGDA010T := aClone(oModel:GetModel("LISTA"):GetOldData())
	AAdd(__AGDA010T, oModel:GetModel("TOTAIS"):getValue("TOTALIMP"))
Return .T.

/*/{Protheus.doc} AGDA10TIMP
Função que busca a ultima consulta de impostos
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@param oGrid, object, Grid Lista
@param lLoadGrid, logical, .T.=Carrega grid, .F.=Não Carrega grid
@return array, registros NEN
/*/
Function AGDA10TIMP(oGrid, lLoadGrid, lService, cCodNegoc)
	Local cQuery     := ""
	Local cTabNEN    := retSQlName("NEN")
	Local aBindQry   := {}
	Local cAlias     := GetNextAlias()
	Local aData      := {}
	Local nX         := 0
	Local nPosIDTRIB := 0
	Local nPosREGRA  := 0
	Local nPosDESCT  := 0
	Local nPosDESCI  := 0
	Local oModel     := FwModelActive()
	Local oMdlTaxCab := Nil

	Default lLoadGrid := .T.
	Default lService  := .F.
	Default cCodNegoc := " "

	If lService
		__cCodNeg := cCodNegoc
	EndIf

	cQuery += "SELECT"
	cQuery += "    A.NEN_FILIAL,"
	cQuery += "    A.NEN_CODNEG,"
	cQuery += "    A.NEN_DATA,"
	cQuery += "    A.NEN_HORA,"
	cQuery += "    A.NEN_CODFOR,"
	cQuery += "    A.NEN_LOJFOR,"
	cQuery += "    A.NEN_TES,"
	cQuery += "    A.NEN_NATURE,"
	cQuery += "    A.NEN_IDTRIB,"
	cQuery += "    A.NEN_REGRA,"
	cQuery += "    A.NEN_ALIQS,"
	cQuery += "    A.NEN_ALIQF,"
	cQuery += "    A.NEN_VALSIS,"
	cQuery += "    A.NEN_VALFIN,"
	cQuery += "    A.R_E_C_N_O_"
	cQuery += " FROM"
	cQuery += "  " + cTabNEN + " A"
	cQuery += " WHERE"
	cQuery += "    A.NEN_FILIAL = ?"     ; aAdd(aBindQry, FWxFilial("NEN"))
	cQuery += "    AND A.NEN_CODNEG = ?" ; aAdd(aBindQry, __cCodNeg)
	cQuery += "    AND A.NEN_DATA = (SELECT MAX(NEN_DATA) FROM " + cTabNEN + " WHERE NEN_FILIAL = A.NEN_FILIAL AND NEN_CODNEG = A.NEN_CODNEG AND D_E_L_E_T_ = '')"
	cQuery += "    AND A.NEN_HORA = (SELECT MAX(NEN_HORA) FROM "  + cTabNEN + " WHERE NEN_FILIAL = A.NEN_FILIAL AND NEN_CODNEG = A.NEN_CODNEG AND NEN_DATA = A.NEN_DATA AND D_E_L_E_T_ = '')"
	cQuery += "    AND A.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery(cQuery)

	cAlias := MPSysOpenQuery(cQuery,,,,aBindQry)

	TcSetField(cAlias,"NEN_DATA", "D", 8)

	if !lService
		if lLoadGrid
			If (cAlias)->(!Eof())
				oGrid:SetNoInsertLine(.F.)
				oGrid:ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)

				oMdlTaxCab := oModel:GetModel("CABECARIO")
				oMdlTaxCab:LoadValue("T_CODFOR", (cAlias)->NEN_CODFOR)
				oMdlTaxCab:LoadValue("T_LOJFOR" ,(cAlias)->NEN_LOJFOR)

				While (cAlias)->(!Eof())
					oGrid:AddLine()
					oGrid:LoadValue("NEN_FILIAL", (cAlias)->NEN_FILIAL)
					oGrid:LoadValue("NEN_CODNEG", (cAlias)->NEN_CODNEG)
					oGrid:LoadValue("NEN_DATA"  , (cAlias)->NEN_DATA)
					oGrid:LoadValue("NEN_HORA"  , (cAlias)->NEN_HORA)
					oGrid:LoadValue("NEN_CODFOR", (cAlias)->NEN_CODFOR)
					oGrid:LoadValue("NEN_LOJFOR", (cAlias)->NEN_LOJFOR)
					oGrid:LoadValue("NEN_TES"   , (cAlias)->NEN_TES)
					oGrid:LoadValue("NEN_NATURE", (cAlias)->NEN_NATURE)
					oGrid:LoadValue("NEN_IDTRIB", (cAlias)->NEN_IDTRIB)
					oGrid:LoadValue("NEN_DESCT" , Posicione("F2E", 2, FWxFilial("F2E") + (cAlias)->NEN_IDTRIB, "F2E->F2E_DESC"))
					oGrid:LoadValue("NEN_REGRA" , (cAlias)->NEN_REGRA)
					oGrid:LoadValue("NEN_DESCI" , Posicione("F2B", 1, FWxFilial("F2B") + (cAlias)->NEN_REGRA, "F2B->F2B_DESC"))
					oGrid:LoadValue("NEN_ALIQS" , (cAlias)->NEN_ALIQS)
					oGrid:LoadValue("NEN_VALSIS", (cAlias)->NEN_VALSIS)
					oGrid:LoadValue("NEN_ALIQF" , (cAlias)->NEN_ALIQF)
					oGrid:LoadValue("NEN_VALFIN", (cAlias)->NEN_VALFIN)
					(cAlias)->(dbSkip())
				EndDo

				oGrid:SetNoInsertLine(.T.)
				oGrid:GoLine(1)
			endif
		else
			aData := FwLoadByAlias(oGrid, cAlias)
			nPosIDTRIB := oGrid:GetStruct():GetFieldPos("NEN_IDTRIB")
			nPosREGRA  := oGrid:GetStruct():GetFieldPos("NEN_REGRA")
			nPosDESCT  := oGrid:GetStruct():GetFieldPos("NEN_DESCT")
			nPosDESCI  := oGrid:GetStruct():GetFieldPos("NEN_DESCI")

			for nX := 1 to len(aData)
				aData[nX, 2, nPosDESCT] := Posicione("F2E", 2, FWxFilial("F2E") + aData[nX, 2, nPosIDTRIB], "F2E->F2E_DESC")
				aData[nX, 2, nPosDESCI] := Posicione("F2B", 1, FWxFilial("F2B") + aData[nX, 2, nPosREGRA], "F2B->F2B_DESC")
			next nX
		endIf
	elseIf (cAlias)->(!Eof())
		while (cAlias)->(!Eof())
			nX++
			aAdd(aData, JsonObject():New())
			aData[nX]['filial']                := (cAlias)->NEN_FILIAL
			aData[nX]['codigonegocio']         := (cAlias)->NEN_CODNEG
			aData[nX]['data']                  := FWDateTo8601((cAlias)->NEN_DATA)
			aData[nX]['hora']                  := (cAlias)->NEN_HORA
			aData[nX]['codigofornecedor']      := (cAlias)->NEN_CODFOR
			aData[nX]['lojafornecedor']        := (cAlias)->NEN_LOJFOR
			aData[nX]['descricaofornecedor']   := RTrim(POSICIONE("SA2", 1, FWxFilial("SA2") +  (cAlias)->NEN_CODFOR + (cAlias)->NEN_LOJFOR, "SA2->A2_NOME"))
			aData[nX]['tes']                   := (cAlias)->NEN_TES
			aData[nX]['descricaotes']          := RTrim(POSICIONE("SF4", 1, FWxFilial("SF4") + (cAlias)->NEN_TES, "SF4->F4_TEXTO"))
			aData[nX]['natureza']              := (cAlias)->NEN_NATURE
			aData[nX]['descricaonatureza']     := RTrim(POSICIONE("SED", 1, FWxFilial("SED") + (cAlias)->NEN_NATURE, "SED->ED_DESCRIC"))
			aData[nX]['codigoregra']           := (cAlias)->NEN_REGRA
			aData[nX]['descricaoregra']        := RTrim(Posicione("F2B", 1, FWxFilial("F2B") + (cAlias)->NEN_REGRA, "F2B->F2B_DESC"))
			aData[nX]['codigotributo']         := (cAlias)->NEN_IDTRIB
			aData[nX]['descricaotributo']      := RTrim(Posicione("F2E", 2, FWxFilial("F2E") + (cAlias)->NEN_IDTRIB, "F2E->F2E_DESC"))
			aData[nX]['aliquotatributo']       := (cAlias)->NEN_ALIQS
			aData[nX]['valortributo']          := (cAlias)->NEN_VALSIS
			aData[nX]['aliquotatributofinal']  := (cAlias)->NEN_ALIQF
			aData[nX]['valortributofinal']     := (cAlias)->NEN_VALFIN
			(cAlias)->(dbSkip())
		endDo
	endif

	(cAlias)->(DBCloseArea())
return aData

/*/{Protheus.doc} AGDA010TCL
Limpa a grid de impostos.
Função utilizada no gatilho dos campos do cabecario
@type function
@version 12
@author jc.maldonado
@since 14/05/2025
@return logical, .T.
/*/
Function AGDA010TCL()
	Local oModel := FwModelActive()
	Local oView  := FwViewActive()
	Local oGrid  := Nil

	If valType(oModel) == 'O' .AND. oModel:GetId() == "AGDA010T"
		oGrid := oModel:GetModel("LISTA")
		oGrid:ClearData(.T. /*lInit*/, .T. /*lBlankLine*/)

		If valType(oView) == 'O' .AND. oView:GetModel():GetId() == "AGDA010T"
			oView:Refresh("VIEW_NEN")
		EndIf
	Endif
Return .T.
