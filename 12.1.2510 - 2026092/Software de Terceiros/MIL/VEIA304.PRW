#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA303.CH" // Utiliza o mesmo CH do VEIA303

/*/{Protheus.doc} VEIA304
	Processo: Agrega (Individual)
	Tipo: Movimentações Internas
	Item: Peças

	@author Andre Luis Almeida
	@since 13/03/2023
/*/
Function VEIA304()
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
Local oStrVFN := FWFormStruct(1,"VFN") // Peças
Local oStrVFO := FWFormStruct(1,"VFO") // Movimentações Internas

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_CODSB1","SB1->B1_COD",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')") )
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_CENCUS","SB1->B1_CC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_CONTA","SB1->B1_CONTA",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_ITEMCT","SB1->B1_ITEMCC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_CLVL","SB1->B1_CLVL",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_DESITE","SB1->B1_DESC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFN_GRUITE')+FWFldGet('VFN_CODITE')"))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_CODITE","VFN_PESQB1",'SPACE(GetSX3Cache("VFN_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_PESQB1",'SPACE(GetSX3Cache("VFN_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_CODITE",'SPACE(GetSX3Cache("VFN_CODITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_CODSB1",'SPACE(GetSX3Cache("VFN_CODSB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_DESITE",'SPACE(GetSX3Cache("VFN_DESITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_CENCUS",'SPACE(GetSX3Cache("VFN_CENCUS", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_CONTA",'SPACE(GetSX3Cache("VFN_CONTA", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_ITEMCT",'SPACE(GetSX3Cache("VFN_ITEMCT", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFN , FwStruTrigger("VFN_GRUITE","VFN_CLVL",'SPACE(GetSX3Cache("VFN_CLVL", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA304", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFNDETAIL" , "VFJMASTER", oStrVFN , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFNDETAIL", {{'VFN_FILIAL','VFJ_FILIAL'}, {'VFN_CODEXE','VFJ_CODIGO'}}, VFN->(IndexKey(2)) )
oModel:AddGrid( "VFODETAIL" , "VFJMASTER", oStrVFO , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFODETAIL", {{'VFO_FILIAL','VFJ_FILIAL'}, {'VFO_CODEXE','VFJ_CODIGO'}}, VFO->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0001) // Agrega (Individual) com Movimentações Internas
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFNDETAIL"):SetDescription(STR0005) // Peças
oModel:GetModel("VFNDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFODETAIL"):SetDescription(STR0003) // Movimentações Internas
oModel:GetModel("VFODETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel("VFNDETAIL"):SetUniqueLine({"VFN_CODSB1"}) // Somente 1 linha por SB1
oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0001) // Agrega (Individual) com Movimentações Internas
//oModel:InstallEvent("VEIA304LOG", /*cOwner*/, MVCLOGEV():New("VEIA304") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

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
Local oStrVFN:= FWFormStruct(2,"VFN", { |cCampo| !ALLTRIM(cCampo) $ "VFN_CODIGO/VFN_CODEXE/VFN_CODSB1/VFN_TIPOPE/VFN_CODTES/VFN_VEIMAQ/" } ) // Peças
Local oStrVFO:= FWFormStruct(2,"VFO", { |cCampo| !ALLTRIM(cCampo) $ "VFO_CODIGO/VFO_CODEXE/" } ) // Movimentações Internas

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFN', oStrVFN, 'VFNDETAIL' ) // Peças
oView:AddGrid( 'VIEW_VFO', oStrVFO, 'VFODETAIL' ) // Movimentações Internas

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_VFO',STR0004) // Dados para geração das Movimentações Internas
oView:AddSheet('FOLDER','FOLD_VFN',STR0005) // Peças

oView:CreateHorizontalBox( 'BOXVFO',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFO')
oView:CreateHorizontalBox( 'BOXVFN',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFN')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFO' , 'BOXVFO' ) // Movimentações Internas
oView:SetOwnerView( 'VIEW_VFN' , 'BOXVFN' ) // Peças

oView:SetNoInsertLine('VIEW_VFO') // Movimentações Internas - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFO') // Movimentações Internas - Nao Deletar Linhas

Return oView