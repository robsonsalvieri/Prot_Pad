#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA313.CH" // Utiliza o mesmo CH do VEIA313

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA315
	Processo: Troca
	Tipo: Movimentações Internas
	Item: AMS

	@author Andre Luis Almeida
	@since 17/04/2023
/*/
Function VEIA315()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model

@author Andre Luis Almeida
@since 17/04/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execuções
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFP := FWFormStruct(1,"VFP") // AMS De
Local oStrVFM := FWFormStruct(1,"VFM") // AMS Para
Local oStrVFO := FWFormStruct(1,"VFO") // Movimentações Internas

oStrVFP:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		,; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFM:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		,; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFO:AddField(;
		"",; // cTitulo
		'',; // cTooltip
		'EVENTO',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('VFO')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)
oStrVFJ:SetProperty('VFJ_VV1002',MODEL_FIELD_OBRIGAT, .t.)

oStrVFP:SetProperty('VFP_CHAINT',MODEL_FIELD_OBRIGAT, .f.)
oStrVFP:SetProperty('VFP_VEIMAQ',MODEL_FIELD_WHEN,{|| FWFldGet('VFP_CUSUNI') == 0 })
oStrVFP:SetProperty('VFP_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD," "))

oStrVFM:SetProperty('VFM_CHAINT',MODEL_FIELD_OBRIGAT, .f.)
oStrVFM:SetProperty('VFM_VEIMAQ',MODEL_FIELD_WHEN,{|| .f. })
oStrVFM:SetProperty('VFM_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD," "))

oStrVFO:SetProperty('VFO_TIPREG',MODEL_FIELD_WHEN,{|| .f. })
oStrVFO:SetProperty('VFO_TIPMOV',MODEL_FIELD_WHEN,{|| .f. })

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_MAR002","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_MOD002","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1002","VFJ_CHA002","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1002')") )

VA3000101_Trigger( oStrVFP , FwStruTrigger("VFP_CHASSI","VFP_TIPOPE",'SPACE(GetSX3Cache("VFP_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFP , FwStruTrigger("VFP_CHASSI","VFP_CODTES",'SPACE(GetSX3Cache("VFP_CODTES", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFP , FwStruTrigger("VFP_CODTES","VFP_TIPOPE",'SPACE(GetSX3Cache("VFP_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CODTES","VFM_TIPOPE",'SPACE(GetSX3Cache("VFM_TIPOPE", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA315", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFPDETAIL" , "VFJMASTER", oStrVFP , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFPDETAIL", {{'VFP_FILIAL','VFJ_FILIAL'}, {'VFP_CODEXE','VFJ_CODIGO'}}, VFP->(IndexKey(2)) )
oModel:AddGrid( "VFMDETAIL" , "VFJMASTER", oStrVFM , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFMDETAIL", {{'VFM_FILIAL','VFJ_FILIAL'}, {'VFM_CODEXE','VFJ_CODIGO'}}, VFM->(IndexKey(2)) )
oModel:AddGrid( "VFODETAIL" , "VFJMASTER", oStrVFO , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFODETAIL", {{'VFO_FILIAL','VFJ_FILIAL'}, {'VFO_CODEXE','VFJ_CODIGO'}}, VFO->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0010) // Troca com Movimentações Internas
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFPDETAIL"):SetDescription(cSiglaAMS+" - "+STR0003) // AMS / Desagrega
oModel:GetModel("VFPDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFMDETAIL"):SetDescription(cSiglaAMS+" - "+STR0004) // AMS / Agrega
oModel:GetModel("VFMDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFODETAIL"):SetDescription(STR0011) // Movimentações Internas
oModel:GetModel("VFODETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0010) // Troca com Movimentações Internas
//oModel:InstallEvent("VEIA315LOG", /*cOwner*/, MVCLOGEV():New("VEIA315") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

oModel:AddRules( 'VFPDETAIL', 'VFP_MODVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_SEGMOD', 'VFPDETAIL', 'VFP_MODVEI', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_CORVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 17/04/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execuções
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Totais
Local oStrVFP:= FWFormStruct(2,"VFP", { |cCampo| !ALLTRIM(cCampo) $ "VFP_CODIGO/VFP_CODEXE/VFP_CHAINT/VFP_REFSAI/VFP_TIPOPE/VFP_CODTES" } ) // AMS De
Local oStrVFM:= FWFormStruct(2,"VFM", { |cCampo| !ALLTRIM(cCampo) $ "VFM_CODIGO/VFM_CODEXE/VFM_CHAINT/VFM_TIPOPE/VFM_CODTES/" } ) // AMS Para
Local oStrVFO:= FWFormStruct(2,"VFO", { |cCampo| !ALLTRIM(cCampo) $ "VFO_CODIGO/VFO_CODEXE/" } ) // Movimentações Internas

oStrVFP:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFM:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFO:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFP', oStrVFP, 'VFPDETAIL' ) // AMS De
oView:AddGrid( 'VIEW_VFM', oStrVFM, 'VFMDETAIL' ) // AMS Para
oView:AddGrid( 'VIEW_VFO', oStrVFO, 'VFODETAIL' ) // Movimentações Internas

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 35)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 65)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_VFO',STR0012) // Dados para geração das Movimentações Internas
oView:AddSheet('FOLDER','FOLD_VFP',cSiglaAMS+" - "+STR0003) // AMS / Desagrega
oView:AddSheet('FOLDER','FOLD_VFM',cSiglaAMS+" - "+STR0004) // AMS / Agrega

oView:CreateHorizontalBox( 'BOXVFO',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFO')
oView:CreateHorizontalBox( 'BOXVFP',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFP')
oView:CreateHorizontalBox( 'BOXVFM',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFM')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFO' , 'BOXVFO' ) // Movimentações Internas
oView:SetOwnerView( 'VIEW_VFP' , 'BOXVFP' ) // AMS De
oView:SetOwnerView( 'VIEW_VFM' , 'BOXVFM' ) // AMS Para

oView:SetNoInsertLine('VIEW_VFM') // AMS Para - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFM') // AMS Para - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFO') // Movimentações Internas - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFO') // Movimentações Internas - Nao Deletar Linhas

oView:AddUserButton(STR0008,'CLIPS',{ |oView| VA3000131_LegendaEvento("4") }) // Legenda Eventos

Return oView