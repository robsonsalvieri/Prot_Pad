#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA303.CH" // Utiliza o mesmo CH do VEIA303

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA307
	Processo: Desagrega (Individual)
	Tipo: Movimentações Internas
	Item: AMS

	@author Andre Luis Almeida
	@since 13/03/2023
/*/
Function VEIA307()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model

@author Andre Luis Almeida
@since 13/03/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execuções
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFP := FWFormStruct(1,"VFP") // AMS
Local oStrVFO := FWFormStruct(1,"VFO") // Movimentações Internas

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t. )

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

oModel := MPFormModel():New("VEIA307", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFPDETAIL" , "VFJMASTER", oStrVFP , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFPDETAIL", {{'VFP_FILIAL','VFJ_FILIAL'}, {'VFP_CODEXE','VFJ_CODIGO'}}, VFP->(IndexKey(2)) )
oModel:AddGrid( "VFODETAIL" , "VFJMASTER", oStrVFO , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFODETAIL", {{'VFO_FILIAL','VFJ_FILIAL'}, {'VFO_CODEXE','VFJ_CODIGO'}}, VFO->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0006) // Desagrega (Individual) com Movimentações Internas
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFPDETAIL"):SetDescription(cSiglaAMS) // AMS
oModel:GetModel("VFPDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFODETAIL"):SetDescription(STR0003) // Movimentações Internas
oModel:GetModel("VFODETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0006) // Desagrega (Individual) com Movimentações Internas
//oModel:InstallEvent("VEIA307LOG", /*cOwner*/, MVCLOGEV():New("VEIA307") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

oModel:AddRules( 'VFPDETAIL', 'VFP_MODVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_SEGMOD', 'VFPDETAIL', 'VFP_MODVEI', 3)
oModel:AddRules( 'VFPDETAIL', 'VFP_CORVEI', 'VFPDETAIL', 'VFP_CODMAR', 3)

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 13/03/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_VV1002/VFJ_MAR002/VFJ_MOD002/VFJ_CHA002/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execuções
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/" } ) // Totais
Local oStrVFP:= FWFormStruct(2,"VFP", { |cCampo| !ALLTRIM(cCampo) $ "VFP_CODIGO/VFP_CODEXE/VFP_CHAINT/VFP_TIPOPE/VFP_CODTES/VFP_REFSAI/VFP_VEIMAQ/" } ) // AMS
Local oStrVFO:= FWFormStruct(2,"VFO", { |cCampo| !ALLTRIM(cCampo) $ "VFO_CODIGO/VFO_CODEXE/" } ) // Movimentações Internas

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFP', oStrVFP, 'VFPDETAIL' ) // AMS
oView:AddGrid( 'VIEW_VFO', oStrVFO, 'VFODETAIL' ) // Movimentações Internas

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_VFO',STR0004) // Dados para geração das Movimentações Internas
oView:AddSheet('FOLDER','FOLD_VFP',cSiglaAMS) // AMS

oView:CreateHorizontalBox( 'BOXVFO',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFO')
oView:CreateHorizontalBox( 'BOXVFP',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFP')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFO' , 'BOXVFO' ) // Movimentações Internas
oView:SetOwnerView( 'VIEW_VFP' , 'BOXVFP' ) // AMS

oView:SetNoInsertLine('VIEW_VFO') // Movimentações Internas - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFO') // Movimentações Internas - Nao Deletar Linhas

Return oView