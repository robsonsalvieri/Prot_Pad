#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA309.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA309
	Processo: Transferência
	Tipo: Notas Fiscais
	Item: AMS

	@author Andre Luis Almeida
	@since 03/04/2023
/*/
Function VEIA309()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model

@author Andre Luis Almeida
@since 03/04/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execuções
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFP := FWFormStruct(1,"VFP") // AMS De
Local oStrVFM := FWFormStruct(1,"VFM") // AMS Para
Local oStrVFK := FWFormStruct(1,"VFK") // NFs Saida
Local oStrVFL := FWFormStruct(1,"VFL") // NFs Entrada

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
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('TVFP')"),; // bInit
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
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('TVFM')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFK:AddField(;
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
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('VFK')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFL:AddField(;
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
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA3000121_CorEvento('VFL')"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)
oStrVFJ:SetProperty('VFJ_VV1002',MODEL_FIELD_OBRIGAT, .t.)

oStrVFP:SetProperty('VFP_CHAINT',MODEL_FIELD_OBRIGAT, .f.)
oStrVFP:SetProperty('VFP_VEIMAQ',MODEL_FIELD_WHEN,{|| .f. })
oStrVFP:SetProperty('VFP_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"1"))

oStrVFM:SetProperty('VFM_CHAINT',MODEL_FIELD_OBRIGAT, .f.)
oStrVFM:SetProperty('VFM_VEIMAQ',MODEL_FIELD_WHEN,{|| .f. })
oStrVFM:SetProperty('VFM_VEIMAQ',MODEL_FIELD_INIT,FwBuildFeature(STRUCT_FEATURE_INIPAD,"2"))

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

VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODVEN","VFK_NOMVEN",'Left(SA3->A3_NOME,GetSX3Cache("VFK_NOMVEN", "X3_TAMANHO"))',.T.,"SA3",1,"xFilial('SA3')+FWFldGet('VFK_CODVEN')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_FORPAG","VFK_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFK_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFK_FORPAG')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODTES","VFK_TIPOPE",'SPACE(GetSX3Cache("VFK_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_FORPAG","VFL_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFL_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFL_FORPAG')") )
VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_CODTES","VFL_TIPOPE",'SPACE(GetSX3Cache("VFL_TIPOPE", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA309", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFPDETAIL" , "VFJMASTER", oStrVFP , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFPDETAIL", {{'VFP_FILIAL','VFJ_FILIAL'}, {'VFP_CODEXE','VFJ_CODIGO'}}, VFP->(IndexKey(2)) )
oModel:AddGrid( "VFMDETAIL" , "VFJMASTER", oStrVFM , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFMDETAIL", {{'VFM_FILIAL','VFJ_FILIAL'}, {'VFM_CODEXE','VFJ_CODIGO'}}, VFM->(IndexKey(2)) )
oModel:AddGrid( "VFKDETAIL" , "VFJMASTER", oStrVFK , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFKDETAIL", {{'VFK_FILIAL','VFJ_FILIAL'}, {'VFK_CODEXE','VFJ_CODIGO'}}, VFK->(IndexKey(2)) )
oModel:AddGrid( "VFLDETAIL" , "VFJMASTER", oStrVFL , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFLDETAIL", {{'VFL_FILIAL','VFJ_FILIAL'}, {'VFL_CODEXE','VFJ_CODIGO'}}, VFL->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0001) // Transferência com Notas Fiscais
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFPDETAIL"):SetDescription(cSiglaAMS+" - "+STR0003) // AMS / Desagrega
oModel:GetModel("VFPDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFMDETAIL"):SetDescription(cSiglaAMS+" - "+STR0004) // AMS / Agrega
oModel:GetModel("VFMDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFKDETAIL"):SetDescription(STR0005) // Notas Fiscais de Saida
oModel:GetModel("VFKDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFLDETAIL"):SetDescription(STR0006) // Notas Fiscais de Entrada
oModel:GetModel("VFLDETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0001) // Transferência com Notas Fiscais
//oModel:InstallEvent("VEIA309LOG", /*cOwner*/, MVCLOGEV():New("VEIA309") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

oModel:AddRules( 'VFPDETAIL', 'VFP_MODVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_SEGMOD', 'VFPDETAIL', 'VFP_MODVEI', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_CORVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 03/04/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execuções
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Totais
Local oStrVFP:= FWFormStruct(2,"VFP", { |cCampo| !ALLTRIM(cCampo) $ "VFP_CODIGO/VFP_CODEXE/VFP_CHAINT/VFP_REFSAI/" } ) // AMS De
Local oStrVFM:= FWFormStruct(2,"VFM", { |cCampo| !ALLTRIM(cCampo) $ "VFM_CODIGO/VFM_CODEXE/VFM_CHAINT/" } ) // AMS Para
Local oStrVFK:= FWFormStruct(2,"VFK", { |cCampo| !ALLTRIM(cCampo) $ "VFK_CODIGO/VFK_CODEXE/" } ) // NFs Saida
Local oStrVFL:= FWFormStruct(2,"VFL", { |cCampo| !ALLTRIM(cCampo) $ "VFL_CODIGO/VFL_CODEXE/" } ) // NFs Entrada

oStrVFP:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFM:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFK:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  
oStrVFL:AddField( 'EVENTO','01',' ','',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )  

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFP', oStrVFP, 'VFPDETAIL' ) // AMS De
oView:AddGrid( 'VIEW_VFM', oStrVFM, 'VFMDETAIL' ) // AMS Para
oView:AddGrid( 'VIEW_VFK', oStrVFK, 'VFKDETAIL' ) // NFs Saida
oView:AddGrid( 'VIEW_VFL', oStrVFL, 'VFLDETAIL' ) // NFs Entrada

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_NFS',STR0007) // Dados para geração das Notas Fiscais
oView:AddSheet('FOLDER','FOLD_VFP',cSiglaAMS+" - "+STR0003) // AMS / Desagrega
oView:AddSheet('FOLDER','FOLD_VFM',cSiglaAMS+" - "+STR0004) // AMS / Agrega

oView:CreateHorizontalBox( 'BOXNF1', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXNF2', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXVFP',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFP')
oView:CreateHorizontalBox( 'BOXVFM',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFM')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFK' , 'BOXNF1' ) // NFs Saida
oView:SetOwnerView( 'VIEW_VFL' , 'BOXNF2' ) // NFs Entrada
oView:SetOwnerView( 'VIEW_VFP' , 'BOXVFP' ) // AMS De
oView:SetOwnerView( 'VIEW_VFM' , 'BOXVFM' ) // AMS Para

oView:SetNoInsertLine('VIEW_VFM') // AMS Para - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFM') // AMS Para - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFK') // NFs Saida - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFK') // NFs Saida - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFL') // NFs Entrada - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFL') // NFs Entrada - Nao Deletar Linhas

oView:AddUserButton(STR0008,'CLIPS',{ |oView| VA3000131_LegendaEvento("3") }) // Legenda Eventos

Return oView