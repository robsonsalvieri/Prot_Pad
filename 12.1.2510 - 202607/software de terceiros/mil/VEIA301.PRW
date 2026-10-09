#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA301.CH"

Static cSiglaAMS := GetNewPar("MV_MIL0106","AMS") // Sigla da Solucao Agregada. Exemplos: AMS ou AFS ou SAG. Default: AMS

/*/{Protheus.doc} VEIA301
	Processo: Agrega (Individual)
	Tipo: Notas Fiscais
	Item: AMS

	@author Andre Luis Almeida
	@since 15/02/2023
/*/
Function VEIA301()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model

@author Andre Luis Almeida
@since 15/02/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execuções
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFM := FWFormStruct(1,"VFM") // AMS
Local oStrVFK := FWFormStruct(1,"VFK") // NFs Saida
Local oStrVFL := FWFormStruct(1,"VFL") // NFs Entrada
Local cGruVei := Padr(GetMv("MV_GRUVEI"),GetSX3Cache("B1_GRUPO","X3_TAMANHO"))

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)

oStrVFM:SetProperty('VFM_CODTES',MODEL_FIELD_OBRIGAT, .t.)

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CHASSI","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CODMAR","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_MODVEI","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_SEGMOD","VV1->VV1_SEGMOD",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CORVEI","VV1->VV1_CORVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CENCUS","SB1->B1_CC"    ,.T.,"SB1",7,"xFilial('SB1')+'"+cGruVei+"'+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CONTA" ,"SB1->B1_CONTA" ,.T.,"SB1",7,"xFilial('SB1')+'"+cGruVei+"'+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_ITEMCT","SB1->B1_ITEMCC",.T.,"SB1",7,"xFilial('SB1')+'"+cGruVei+"'+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CLVL"  ,"SB1->B1_CLVL"  ,.T.,"SB1",7,"xFilial('SB1')+'"+cGruVei+"'+FWFldGet('VFM_CHAINT')") )
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_TIPOPE",'SPACE(GetSX3Cache("VFM_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CHAINT","VFM_CODTES",'SPACE(GetSX3Cache("VFM_CODTES", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFM , FwStruTrigger("VFM_CODTES","VFM_TIPOPE",'SPACE(GetSX3Cache("VFM_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODVEN","VFK_NOMVEN",'Left(SA3->A3_NOME,GetSX3Cache("VFK_NOMVEN", "X3_TAMANHO"))',.T.,"SA3",1,"xFilial('SA3')+FWFldGet('VFK_CODVEN')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_FORPAG","VFK_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFK_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFK_FORPAG')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODTES","VFK_TIPOPE",'SPACE(GetSX3Cache("VFK_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_FORPAG","VFL_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFL_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFL_FORPAG')") )
VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_CODTES","VFL_TIPOPE",'SPACE(GetSX3Cache("VFL_TIPOPE", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA301", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFMDETAIL" , "VFJMASTER", oStrVFM , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFMDETAIL", {{'VFM_FILIAL','VFJ_FILIAL'}, {'VFM_CODEXE','VFJ_CODIGO'}}, VFM->(IndexKey(2)) )
oModel:AddGrid( "VFKDETAIL" , "VFJMASTER", oStrVFK , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFKDETAIL", {{'VFK_FILIAL','VFJ_FILIAL'}, {'VFK_CODEXE','VFJ_CODIGO'}}, VFK->(IndexKey(2)) )
oModel:AddGrid( "VFLDETAIL" , "VFJMASTER", oStrVFL , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFLDETAIL", {{'VFL_FILIAL','VFJ_FILIAL'}, {'VFL_CODEXE','VFJ_CODIGO'}}, VFL->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0001) // Agrega (Individual) com Notas Fiscais
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFMDETAIL"):SetDescription(cSiglaAMS) // AMS
oModel:GetModel("VFMDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFKDETAIL"):SetDescription(STR0003) // Notas Fiscais de Saida
oModel:GetModel("VFKDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFLDETAIL"):SetDescription(STR0004) // Notas Fiscais de Entrada
oModel:GetModel("VFLDETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel("VFMDETAIL"):SetUniqueLine({"VFM_CHAINT"}) // Somente 1 linha por CHAINT
oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0001) // Agrega (Individual) com Notas Fiscais
//oModel:InstallEvent("VEIA301LOG", /*cOwner*/, MVCLOGEV():New("VEIA301") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 15/02/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_VV1002/VFJ_MAR002/VFJ_MOD002/VFJ_CHA002/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execuções
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/" } ) // Totais
Local oStrVFM:= FWFormStruct(2,"VFM", { |cCampo| !ALLTRIM(cCampo) $ "VFM_CODIGO/VFM_CODEXE/VFM_VEIMAQ/" } ) // AMS
Local oStrVFK:= FWFormStruct(2,"VFK", { |cCampo| !ALLTRIM(cCampo) $ "VFK_CODIGO/VFK_CODEXE/" } ) // NFs Saida
Local oStrVFL:= FWFormStruct(2,"VFL", { |cCampo| !ALLTRIM(cCampo) $ "VFL_CODIGO/VFL_CODEXE/" } ) // NFs Entrada

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFM', oStrVFM, 'VFMDETAIL' ) // AMS
oView:AddGrid( 'VIEW_VFK', oStrVFK, 'VFKDETAIL' ) // NFs Saida
oView:AddGrid( 'VIEW_VFL', oStrVFL, 'VFLDETAIL' ) // NFs Entrada

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_NFS',STR0005) // Dados para geração das Notas Fiscais
oView:AddSheet('FOLDER','FOLD_VFM',cSiglaAMS) // AMS

oView:CreateHorizontalBox( 'BOXNF1', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXNF2', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXVFM',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFM')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFK' , 'BOXNF1' ) // NFs Saida
oView:SetOwnerView( 'VIEW_VFL' , 'BOXNF2' ) // NFs Entrada
oView:SetOwnerView( 'VIEW_VFM' , 'BOXVFM' ) // AMS

oView:SetNoInsertLine('VIEW_VFK') // NFs Saida - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFK') // NFs Saida - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFL') // NFs Entrada - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFL') // NFs Entrada - Nao Deletar Linhas

Return oView