#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGDA070.CH"

#DEFINE TIPO_RECEITURARIO '1'
#DEFINE TIPO_GUIATRANSPOR '2'

/*/{Protheus.doc} AGDA070
Browse Dados Guia/Receituário - tabela NES 
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
/*/
Function AGDA070()
	Local oFWMBrowse := Nil

	If ! FWAliasInDic("NCR");
			.OR. ! FWAliasInDic("NES");
			.OR. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) <= 0;
			.OR. NCR->(FieldPos("NCR_EMGUIA")) <= 0
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		Return
	Endif

	oFWMBrowse := FWMBrowse():New()
	oFWMBrowse:SetAlias("NES")
	oFWMBrowse:SetDescription(STR0001) //"Dados Guia/Receituário"
	oFWMBrowse:DisableDetails()
	oFWMBrowse:Activate()
Return

/*/{Protheus.doc} MenuDef
Menu Def
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'AGDA070VI()' OPERATION 2 ACCESS 0 //"Visualizar"
Return aRotina

/*/{Protheus.doc} ModelDef
Model Def
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return object, Instancia do MPFormModel
/*/
Static Function ModelDef()
	Local oModel	  := Nil
	Local oStruSF2    := gSF2struc()
	Local oStruNESrec := FwFormStruct(1, "NES")
	Local oStruNESgui := FwFormStruct(1, "NES")
	Local oStruProdR  := getMdlStrc()
	local oStruProdG  := getMdlStrc()

	oModel := MpFormModel():New("AGDA070",/*bPre*/, /*bPos*/)
	oModel:addFields("AGDA070_SF2", /*cOwner*/, oStruSF2)
	oModel:SetDescription(STR0001) //"Dados Guia/Receituário"

	oStruNESrec:SetProperty("NES_TPVINC", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, TIPO_RECEITURARIO))
	oModel:AddGrid("NES_RECE", "AGDA070_SF2", oStruNESrec)
	oModel:GetModel("NES_RECE"):SetDescription(STR0003) //"Receituário"
	oModel:GetModel("NES_RECE"):SetForceLoad(.T.)
	oModel:GetModel("NES_RECE"):SetOptional(.T.)
	if ! IsdocGRec(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, TIPO_RECEITURARIO)
		oModel:GetModel("NES_RECE"):SetOnlyView(.T.)
		oModel:GetModel("NES_RECE"):SetNoUpdateLine(.T.)
	EndIf
	oModel:SetRelation("NES_RECE",{{"NES_FILIAL","F2_FILIAL"},{"NES_DOC","F2_DOC"},{"NES_SERIE","F2_SERIE"},{"NES_CLIENT","F2_CLIENTE"},{"NES_LOJA","F2_LOJA"},{"NES_TPVINC","'" + TIPO_RECEITURARIO + "'"}}, NES->(IndexKey(1)))

	oStruProdR:SetProperty('*', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oModel:addGrid("PROD_RECE", "AGDA070_SF2", oStruProdR, /*bLinePre*/, /*bLinePost*/, /*bLinePre */, /*bPost*/, {|oMdl| getProds(oMdl, TIPO_RECEITURARIO)})
	oModel:GetModel("PROD_RECE"):SetDescription(STR0006) //"Produtos que precisam de Receituário"
	oModel:GetModel("PROD_RECE"):SetOptional(.T.)
	oModel:GetModel("PROD_RECE"):SetOnlyView(.T.)
	oModel:GetModel("PROD_RECE"):SetOnlyQuery(.T.)

	oStruNESgui:SetProperty("NES_TPVINC", MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, TIPO_GUIATRANSPOR))
	oModel:AddGrid("NES_GUIA", "AGDA070_SF2", oStruNESgui)
	oModel:GetModel("NES_GUIA"):SetDescription(STR0004) //"Guia de Transporte"
	oModel:GetModel("NES_GUIA"):SetForceLoad(.T.)
	oModel:GetModel("NES_GUIA"):SetOptional(.T.)
	If ! IsdocGRec(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA, TIPO_GUIATRANSPOR)
		oModel:GetModel("NES_GUIA"):SetOnlyView(.T.)
		oModel:GetModel("NES_GUIA"):SetNoUpdateLine(.T.)
	EndIf
	oModel:SetRelation("NES_GUIA",{{"NES_FILIAL","F2_FILIAL"},{"NES_DOC","F2_DOC"},{"NES_SERIE","F2_SERIE"},{"NES_CLIENT","F2_CLIENTE"},{"NES_LOJA","F2_LOJA"},{"NES_TPVINC","'" + TIPO_GUIATRANSPOR + "'"}}, NES->(IndexKey(1)))

	oStruProdG:SetProperty('*', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oModel:addGrid("PROD_GUIA", "AGDA070_SF2", oStruProdG, /*bLinePre*/, /*bLinePost*/, /*bLinePre */, /*bPost*/, {|oMdl| getProds(oMdl, TIPO_GUIATRANSPOR)})
	oModel:GetModel("PROD_GUIA"):SetDescription(STR0005) //"Produtos que precisam de Guia de Transporte"
	oModel:GetModel("PROD_GUIA"):SetOptional(.T.)
	oModel:GetModel("PROD_GUIA"):SetOnlyView(.T.)
	oModel:GetModel("PROD_GUIA"):SetOnlyQuery(.T.)

	oModel:SetPrimaryKey({"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE", "F2_LOJA"})
Return oModel

/*/{Protheus.doc} ViewDef
View Def
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return variant, Instancia da FWFormView
/*/
Static Function ViewDef()
	Local oModel	  := FwLoadModel("AGDA070")
	Local oView		  := FwFormView():New()
	Local oStruSF2	  := FWFormStruct(2, 'SF2', {|xIt| aScan({"F2_FILIAL", "F2_DOC", "F2_SERIE", "F2_CLIENTE","F2_LOJA"}, Alltrim(xIt)) > 0})
	Local oStruNESrec := FWFormStruct(2, 'NES', {|xIt| aScan({"NES_ITEM", "NES_CGC", "NES_NUMREC"}, Alltrim(xIt)) > 0})
	Local oStruNESgui := FWFormStruct(2, 'NES', {|xIt| aScan({"NES_ITEM", "NES_UF", "NES_SERGUI", "NES_NUMGUI", "NES_TPGUIA"}, Alltrim(xIt)) > 0})
	Local oStruProdR  := gViewStrc()
	Local oStruProdG  := gViewStrc()

	oView:SetModel(oModel)
	oStruSF2:RemoveField("F2_CLIENT")
	oView:AddField('VIEW_HEADER', oStruSF2, 'AGDA070_SF2')

	oView:CreateHorizontalBox('HBOX_HEADER', 10)
	oView:CreateHorizontalBox('HBOX_BODY', 90)

	oView:CreateFolder("FOLDERS", "HBOX_BODY")
	oView:AddSheet("FOLDERS", "FOLDER_RECE", STR0003) //"Receituário"
	oView:AddSheet("FOLDERS", "FOLDER_GUIA", STR0004) //"Guia de Transporte"

	oView:CreateHorizontalBox("FLDB_RECE_1", 40,,, "FOLDERS", "FOLDER_RECE")
	oView:AddGrid('VIEW_RECE_1', oStruNESrec, 'NES_RECE')
	oView:AddIncrementField("VIEW_RECE_1", "NES_ITEM")
	oView:CreateHorizontalBox("FLDB_RECE_2", 60,,, "FOLDERS", "FOLDER_RECE")
	oView:AddGrid('VIEW_RECE_2', oStruProdR, 'PROD_RECE')
	oView:EnableTitleView('VIEW_RECE_2', oModel:GetModel("PROD_RECE"):GetDescription())

	oView:CreateHorizontalBox("FLDB_GUIA_1", 40,,, "FOLDERS", "FOLDER_GUIA")
	oView:AddGrid('VIEW_GUIA_1', oStruNESgui, 'NES_GUIA')
	oView:AddIncrementField("VIEW_GUIA_1", "NES_ITEM")
	oView:CreateHorizontalBox("FLDB_GUIA_2", 60,,, "FOLDERS", "FOLDER_GUIA")
	oView:AddGrid('VIEW_GUIA_2', oStruProdG, 'PROD_GUIA')
	oView:EnableTitleView('VIEW_GUIA_2', oModel:GetModel("PROD_GUIA"):GetDescription())

	oView:SetOwnerView('VIEW_HEADER',	'HBOX_HEADER')

	oView:SetOwnerView('VIEW_RECE_1', 'FLDB_RECE_1')
	oView:SetOwnerView('VIEW_RECE_2', 'FLDB_RECE_2')

	oView:SetOwnerView('VIEW_GUIA_1', 'FLDB_GUIA_1')
	oView:SetOwnerView('VIEW_GUIA_2', 'FLDB_GUIA_2')

	oView:SetCloseOnOk({||.T.})
Return oView

/*/{Protheus.doc} AGDA070VI
Visualizar Dados Guia/Receituário - tabela NES 
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
/*/
Function AGDA070VI()
	Local aArea := FWgetArea()

	DBSelectArea("SF2")
	SF2->(DBSetOrder(1))
	SF2->(DBGoTop())
	If SF2->(!DBSeek(NES->NES_FILIAL + NES->NES_DOC + NES->NES_SERIE + NES->NES_CLIENT + NES->NES_LOJA))
		AGDHELP(STR0007, STR0012) //"Atenção!", "Registro da SF2 indisponível."
		Return
	EndIf

	FWExecView(STR0002, "VIEWDEF.AGDA070", MODEL_OPERATION_VIEW, ,{|| .T.}) //"Visualizar"

	FWrestArea(aArea)
return

/*/{Protheus.doc} gSF2struc
obtem o model Struct da SF2
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return object, Instancia do FWFormModelStruct
/*/
static function gSF2struc()
	local oStruSF2 := FwFormStruct(1, "SF2")

	oStruSF2:SetProperty('*'         , MODEL_FIELD_OBRIGAT, .F.)
	oStruSF2:SetProperty('F2_FILIAL' , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStruSF2:SetProperty('F2_DOC'    , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStruSF2:SetProperty('F2_SERIE'  , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStruSF2:SetProperty('F2_CLIENTE', MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
	oStruSF2:SetProperty('F2_LOJA'   , MODEL_FIELD_WHEN   , FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
return oStruSF2

/*/{Protheus.doc} getMdlStrc
obtem o model Struct da grid de produtos da nota ficasl de saída que possuem necessidade de guia de transporte ou receituário
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return object, Instancia do FWFormModelStruct
/*/
Static Function getMdlStrc()
	Local aFields    := {"D2_ITEM", "D2_COD", "B1_DESC", "D2_UM", "D2_QUANT"}
	Local nX         := 0
	Local aStruField := {}
	Local oStruMdl   := FWFormModelStruct():New()

	For nX := 1 To Len(aFields)
		aStruField := FWSX3Util():GetFieldStruct(aFields[nX])

		oStruMdl:AddField(RetTitle(aFields[nX]),;     // cTitulo
		FWSX3Util():GetDescription(aFields[nX]),;     // cTooltip
		aFields[nX],;                                 // cIdField
		aStruField[2],;								  // cTipo
		aStruField[3],;                               // nTamanho
		aStruField[4],;				                  // nDecimais
		FwBuildFeature(STRUCT_FEATURE_VALID, ".T."),; // bValid
		FwBuildFeature(STRUCT_FEATURE_WHEN, ".F."),;  // bWhen
		Nil,;                                         // aValues
		.F.,;                                         // lObrigat
		Nil,;                                         // bInit
		.T.,;                                         // lKey
		.T.) 										  // lNoUpd
	Next nX
return oStruMdl

/*/{Protheus.doc} gViewStrc
Obtem o objeto View Struct da grid de produtos da nota ficasl de saída que possuem necessidade de guia de transporte ou receituário
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@return object, Instancia do FWFormViewStruct
/*/
Static Function gViewStrc()
	Local nX         := 0
	Local aFields    := {"D2_ITEM", "D2_COD", "B1_DESC", "D2_UM", "D2_QUANT"}
	Local aStruField := {}
	Local oStruView  := FWFormViewStruct():New()

	For nX := 1 to Len(aFields)
		aStruField := FWSX3Util():GetFieldStruct(aFields[nX])

		oStruView:AddField(aFields[nX],;                                                          // cIdField
		STRZERO(nX, 2),;                                          					              // cOrdem
		RetTitle(aFields[nX]),;                                                                   // cTitulo
		FWSX3Util():GetDescription(aFields[nX]),;                                                 // cDescric
		GetHlpSoluc(aFields[nX]),;                                                                // aHelp
		aStruField[2],;				                                                              // cType
		Alltrim(GetSx3Cache(aFields[nX], "X3_PICTURE")),;                                         // cPicture
		FWBuildFeature(STRUCT_FEATURE_PICTVAR, alltrim(GetSx3Cache(aFields[nX], "X3_PICTVAR"))),; // bPictVar
		Alltrim(GetSx3Cache(aFields[nX], "X3_F3")),;                                              // cLookUp
		.F.,;                                                                                     // lCanChange
		Nil,;                                                                                     // cFolder
		Nil,;                                                                                     // cGroup
		Nil,;                                                         			                  // aComboValues
		Nil,;                                                                                     // nMaxLenCombo
		Nil,;                                										              // cIniBrow
		.T.,;                        	 											              // lVirtual
		Alltrim(GetSx3Cache(aFields[nX], "X3_PICTVAR")))                                          // cPictVar
	Next nX
Return oStruView

/*/{Protheus.doc} getProds
Retorna os produtos da nota de saída que possuem necessidade de guia de transporte ou receituário
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@param oModel, object, model
@param cTipo, character, 1=receituário, 2=guia de transporte
@return array, Produtos da nota de saída que possuem necessidade de guia de transporte ou receituário
/*/
static function getProds(oModel, cTipo)
	Local cSQL    := ""
	Local aParams := {}
	Local cAlias  := GetNextAlias()
	Local aData   := {}

	cSQL += " SELECT"
	cSQL += "	SD2.D2_FILIAL,"
	cSQL += "	SD2.D2_ITEM,"
	cSQL += "	SD2.D2_COD,"
	cSQL += "	SB1.B1_DESC,"
	cSQL += "	SD2.D2_UM,"
	cSQL += "	SD2.D2_QUANT,"
	cSQL += "	SD2.R_E_C_N_O_ RECNO"
	cSQL += " FROM"
	cSQL += "	" + RetSqlName("SD2") + " SD2 "
	cSQL += " JOIN " + RetSqlName("NCR") + " NCR ON"
	cSQL += "	NCR.NCR_PROD = SD2.D2_COD"
	cSQL += " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON"
	cSQL += "	SB1.B1_COD = SD2.D2_COD"
	cSQL += " WHERE"
	cSQL += "	SD2.D2_FILIAL = ?"       ;aAdd(aParams, SF2->F2_FILIAL)
	cSQL += "	AND SD2.D2_DOC = ?"      ;aAdd(aParams, SF2->F2_DOC)
	cSQL += "	AND SD2.D2_SERIE = ?"    ;aAdd(aParams, SF2->F2_SERIE)
	cSQL += "	AND SD2.D2_CLIENTE = ?"  ;aAdd(aParams, SF2->F2_CLIENTE)
	cSQL += "	AND SD2.D2_LOJA = ?"     ;aAdd(aParams, SF2->F2_LOJA)
	cSQL += "	AND SD2.D_E_L_E_T_ = ''"
	cSQL += "	AND SB1.B1_FILIAL = ?"   ;aAdd(aParams, FWxFilial("SB1"))
	cSQL += "	AND SB1.D_E_L_E_T_ = ''"
	cSQL += "	AND NCR.NCR_FILIAL = ?"  ;aAdd(aParams, FWxFilial("NCR"))
	If cTipo == TIPO_RECEITURARIO
		cSQL += "	AND NCR.NCR_EMREC = '1'"
	Else
		cSQL += "	AND NCR.NCR_EMGUIA = '1'"
	EndIf
	cSQL += "	AND NCR.D_E_L_E_T_ = ''"
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cSQL, aParams), cAlias, .F., .T.)

	aData := FwLoadByAlias(oModel, cAlias, "SD2"/*cAliasReal*/, "RECNO", /*lCopy*/, .T.)
	(cAlias)->(DBCloseArea())
return aData

/*/{Protheus.doc} IsdocGRec
Verifique se os itens da nota informada possuem alguma necessidade de guia de transporte ou guia de receituário
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
@param cFil, character, código da filial
@param cDoc, character, código do documento de sáida
@param cSerie, character, série do documento de sáida
@param cCliente, character, código do cliente do documento de sáida
@param cLoja, character, códigoo da loja do cliente do documento de sáida
@param cTipo, character, ""=Todos os tipos, "1"=Receituário, "2"=Guia de Transporte
@return logical, verdadeiro se possúi necessidade
/*/
Static Function IsdocGRec(cFil, cDoc, cSerie, cCliente, cLoja, cTipo)
	Local cSQL    := ""
	Local aParams := {}
	Local cAlias  := GetNextAlias()
	Local lExist  := .F.

	Default cTipo := ""

	cSQL += " SELECT"
	cSQL += "	 1"
	cSQL += " FROM"
	cSQL += "	" + RetSqlName("SD2") + " SD2 "
	cSQL += " JOIN " + RetSqlName("NCR") + " NCR ON"
	cSQL += "	NCR.NCR_PROD = SD2.D2_COD"
	cSQL += " WHERE"
	cSQL += "	SD2.D2_FILIAL = ?"       ;aAdd(aParams, cFil)
	cSQL += "	AND SD2.D2_DOC = ?"      ;aAdd(aParams, cDoc)
	cSQL += "	AND SD2.D2_SERIE = ?"    ;aAdd(aParams, cSerie)
	cSQL += "	AND SD2.D2_CLIENTE = ?"  ;aAdd(aParams, cCliente)
	cSQL += "	AND SD2.D2_LOJA = ?"     ;aAdd(aParams, cLoja)
	cSQL += "	AND SD2.D_E_L_E_T_ = ''"
	cSQL += "	AND NCR.NCR_FILIAL = ?"  ;aAdd(aParams, FWxFilial("NCR"))
	if Empty(cTipo)
		cSQL += "	AND (NCR.NCR_EMREC = '1' OR NCR.NCR_EMGUIA = '1')"
	else
		If cTipo == TIPO_RECEITURARIO
			cSQL += "	AND NCR.NCR_EMREC = '1'"
		Else
			cSQL += "	AND NCR.NCR_EMGUIA = '1'"
		EndIf
	EndIf
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T., "TOPCONN", TcGenQry2(,,cSQL, aParams), cAlias, .F., .T.)

	lExist := (cAlias)->(!Eof())
	(cAlias)->(DBCloseArea())
return lExist

/*/{Protheus.doc} AGDA070TSS
Rotina utilizada no menu do MATA460A para informar Dados Guia/Receituário da nota de saída
@type function
@version 12
@author jc.maldonado
@since 09/09/2025
/*/
Function AGDA070TSS()
	Local aArea       := FWgetArea()
	Local cFunNameOld := ""
	Local cCadasOld   := ""

	If ! FWAliasInDic("NCR");
			.OR. ! FWAliasInDic("NES");
			.OR. (DBSelectArea("NCR"), NCR->(FieldPos("NCR_EMREC"))) <= 0;
			.OR. NCR->(FieldPos("NCR_EMGUIA")) <= 0
		MsgNextRel() //É necessário a atualização do sistema para a expedição mais recente
		FWrestArea(aArea)
		Return
	EndIf

	If ! FWisInCallStack("MATA460A")
		AGDHELP(STR0007, STR0008) //"Atenção!", "Rotina válida apenas para a MATA460A"
		return
	endIf

	If SELECT("SC9") <= 0 .Or. Empty(SC9->C9_NFISCAL)
		AGDHELP(STR0007, STR0009) //"Atenção!", "Não possui nota fiscal."
		Return
	EndIf

	DbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	SF2->(DbGoTop())
	If ! SF2->(dbSeek(SC9->C9_FILIAL + SC9->C9_NFISCAL + SC9->C9_SERIENF + SC9->C9_CLIENTE + SC9->C9_LOJA))
		AGDHELP(STR0007, STR0012) //"Atenção!", "Registro da SF2 indisponível."
		FWrestArea(aArea)
		Return
	EndIf

	If ! IsdocGRec(SC9->C9_FILIAL, SC9->C9_NFISCAL, SC9->C9_SERIENF, SC9->C9_CLIENTE, SC9->C9_LOJA)
		AGDHELP(STR0007, STR0010) //"Atenção!", "Nenhum produto possuí necessidade de Guia de Transporte ou Receituário."
		FWrestArea(aArea)
		Return
	EndIf

	DBSelectArea("NES")
	NES->(dbSetOrder(1))

	cCadasOld   := cCadastro
	cFunNameOld := FunName()
	SetFunName("AGDA070")

	FWExecView(STR0011, "VIEWDEF.AGDA070", MODEL_OPERATION_UPDATE, ,{|| .T.}) //"Alterar"

	cCadastro := cCadasOld
	SetFunName(cFunNameOld)
	FWrestArea(aArea)
Return
