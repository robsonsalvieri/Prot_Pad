#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "VEIA301.CH" // Utiliza o mesmo CH do VEIA301

/*/{Protheus.doc} VEIA306
	Processo: Desagrega (Individual)
	Tipo: Notas Fiscais
	Item: Peças

	@author Andre Luis Almeida
	@since 01/03/2023
/*/
Function VEIA306()
Return

Static Function MenuDef()
	Local aRotina := {}
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do Model

@author Andre Luis Almeida
@since 01/03/2023
@Return oModel
/*/
Static Function ModelDef()
Local oStrVFJ := FWFormStruct(1,"VFJ") // Execuções
Local oStrTOT := FWFormStruct(1,"VFJ") // Custos Totais
Local oStrVFQ := FWFormStruct(1,"VFQ") // Peças
Local oStrVFK := FWFormStruct(1,"VFK") // NFs Saida
Local oStrVFL := FWFormStruct(1,"VFL") // NFs Entrada

oStrVFJ:SetProperty('VFJ_VV1001',MODEL_FIELD_OBRIGAT, .t.)

oStrVFQ:SetProperty('VFQ_CODTES',MODEL_FIELD_OBRIGAT, .t.)

VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MAR001","VV1->VV1_CODMAR",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_MOD001","VV1->VV1_MODVEI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )
VA3000101_Trigger( oStrVFJ , FwStruTrigger("VFJ_VV1001","VFJ_CHA001","VV1->VV1_CHASSI",.T.,"VV1",1,"xFilial('VV1')+FWFldGet('VFJ_VV1001')") )

VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CODSB1","SB1->B1_COD",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CODTES","SB1->B1_TE",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CENCUS","SB1->B1_CC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CONTA","SB1->B1_CONTA",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_ITEMCT","SB1->B1_ITEMCC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_CLVL","SB1->B1_CLVL",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_DESITE","SB1->B1_DESC",.T.,"SB1",7,"xFilial('SB1')+FWFldGet('VFQ_GRUITE')+FWFldGet('VFQ_CODITE')"))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODITE","VFQ_PESQB1",'SPACE(GetSX3Cache("VFQ_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_PESQB1",'SPACE(GetSX3Cache("VFQ_PESQB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODITE",'SPACE(GetSX3Cache("VFQ_CODITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODSB1",'SPACE(GetSX3Cache("VFQ_CODSB1", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_DESITE",'SPACE(GetSX3Cache("VFQ_DESITE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CODTES",'SPACE(GetSX3Cache("VFQ_CODTES", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CENCUS",'SPACE(GetSX3Cache("VFQ_CENCUS", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CONTA",'SPACE(GetSX3Cache("VFQ_CONTA", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_ITEMCT",'SPACE(GetSX3Cache("VFQ_ITEMCT", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_GRUITE","VFQ_CLVL",'SPACE(GetSX3Cache("VFQ_CLVL", "X3_TAMANHO"))',.F.,,,))
VA3000101_Trigger( oStrVFQ , FwStruTrigger("VFQ_CODTES","VFQ_TIPOPE",'SPACE(GetSX3Cache("VFQ_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODVEN","VFK_NOMVEN",'Left(SA3->A3_NOME,GetSX3Cache("VFK_NOMVEN", "X3_TAMANHO"))',.T.,"SA3",1,"xFilial('SA3')+FWFldGet('VFK_CODVEN')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_FORPAG","VFK_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFK_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFK_FORPAG')") )
VA3000101_Trigger( oStrVFK , FwStruTrigger("VFK_CODTES","VFK_TIPOPE",'SPACE(GetSX3Cache("VFK_TIPOPE", "X3_TAMANHO"))',.F.,,,))

VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_FORPAG","VFL_DESFPG",'Left(SE4->E4_DESCRI,GetSX3Cache("VFL_DESFPG", "X3_TAMANHO"))',.T.,"SE4",1,"xFilial('SE4')+FWFldGet('VFL_FORPAG')") )
VA3000101_Trigger( oStrVFL , FwStruTrigger("VFL_CODTES","VFL_TIPOPE",'SPACE(GetSX3Cache("VFL_TIPOPE", "X3_TAMANHO"))',.F.,,,))

oModel := MPFormModel():New("VEIA306", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:AddFields("VFJMASTER",/*cOwner*/ , oStrVFJ)
oModel:AddFields("VFJTOTAIS","VFJMASTER", oStrTOT)
oModel:SetRelation('VFJTOTAIS', { { 'VFJ_FILIAL' , 'xFilial("VFJ")' } , { 'VFJ_CODIGO' , 'VFJ_CODIGO' } }, VFJ->( IndexKey(1) ) )
oModel:AddGrid( "VFQDETAIL" , "VFJMASTER", oStrVFQ , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFQDETAIL", {{'VFQ_FILIAL','VFJ_FILIAL'}, {'VFQ_CODEXE','VFJ_CODIGO'}}, VFQ->(IndexKey(2)) )
oModel:AddGrid( "VFKDETAIL" , "VFJMASTER", oStrVFK , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFKDETAIL", {{'VFK_FILIAL','VFJ_FILIAL'}, {'VFK_CODEXE','VFJ_CODIGO'}}, VFK->(IndexKey(2)) )
oModel:AddGrid( "VFLDETAIL" , "VFJMASTER", oStrVFL , /*< bLinePre >*/ , /*< bLinePost >*/, /*< bPre >*/, /*< bLinePost >*/, /*< bLoad >*/ )
oModel:SetRelation("VFLDETAIL", {{'VFL_FILIAL','VFJ_FILIAL'}, {'VFL_CODEXE','VFJ_CODIGO'}}, VFL->(IndexKey(2)) )

oModel:GetModel("VFJMASTER"):SetDescription(STR0007) // Desagrega (Individual) com Notas Fiscais
oModel:GetModel("VFJTOTAIS"):SetDescription(STR0002) // Custos Totais
oModel:GetModel("VFQDETAIL"):SetDescription(STR0006) // Peças
oModel:GetModel("VFQDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFKDETAIL"):SetDescription(STR0003) // Notas Fiscais de Saida
oModel:GetModel("VFKDETAIL"):SetOptional(.f.) // Não deixa passar em branco
oModel:GetModel("VFLDETAIL"):SetDescription(STR0004) // Notas Fiscais de Entrada
oModel:GetModel("VFLDETAIL"):SetOptional(.f.) // Não deixa passar em branco

oModel:GetModel("VFQDETAIL"):SetUniqueLine({"VFQ_CODSB1"}) // Somente 1 linha por SB1
oModel:GetModel('VFJTOTAIS'):SetOnlyQuery( .T. ) // Comando para NÃO SALVAR
oModel:GetModel('VFJTOTAIS'):SetOptional( .T. ) // Deixar passar em branco

oModel:SetDescription(STR0007) // Desagrega (Individual) com Notas Fiscais
//oModel:InstallEvent("VEIA306LOG", /*cOwner*/, MVCLOGEV():New("VEIA306") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA300EVDEF", /*cOwner*/, VEIA300EVDEF():New() ) // Todos os eventos estão no VEIA300EVDEF

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 01/03/2023
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStrVFJ:= FWFormStruct(2,"VFJ", { |cCampo| !ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/VFJ_VV1002/VFJ_MAR002/VFJ_MOD002/VFJ_CHA002/VFJ_CUSAT2/VFJ_CUSFT2/" } ) // Execuções
Local oStrTOT:= FWFormStruct(2,"VFJ", { |cCampo|  ALLTRIM(cCampo) $ "VFJ_CUSAT1/VFJ_CUSFT1/" } ) // Totais
Local oStrVFQ:= FWFormStruct(2,"VFQ", { |cCampo| !ALLTRIM(cCampo) $ "VFQ_CODIGO/VFQ_CODEXE/VFQ_CODSB1/VFQ_REFSAI/VFQ_VEIMAQ/" } ) // Peças
Local oStrVFK:= FWFormStruct(2,"VFK", { |cCampo| !ALLTRIM(cCampo) $ "VFK_CODIGO/VFK_CODEXE/" } ) // NFs Saida
Local oStrVFL:= FWFormStruct(2,"VFL", { |cCampo| !ALLTRIM(cCampo) $ "VFL_CODIGO/VFL_CODEXE/" } ) // NFs Entrada

oStrVFQ:SetProperty( 'VFQ_CUSUNI' , MVC_VIEW_CANCHANGE, .t.)

oView := FWFormView():New()
oView:SetModel(oModel)
oView:SetCloseOnOk({||.T.})

oView:AddField('VIEW_VFJ', oStrVFJ, 'VFJMASTER' ) // Processo
oView:AddField('VIEW_TOT', oStrTOT, 'VFJTOTAIS' ) // Custos Totais
oView:AddGrid( 'VIEW_VFQ', oStrVFQ, 'VFQDETAIL' ) // Peças
oView:AddGrid( 'VIEW_VFK', oStrVFK, 'VFKDETAIL' ) // NFs Saida
oView:AddGrid( 'VIEW_VFL', oStrVFL, 'VFLDETAIL' ) // NFs Entrada

// definição de como será a tela
oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('CABEC' , 70, 'TOP')
oView:CreateVerticalBox('TOTAIS' , 30, 'TOP')
oView:CreateHorizontalBox('DETAIL', 60)

oView:CreateFolder('FOLDER','DETAIL')
oView:AddSheet('FOLDER','FOLD_NFS',STR0005) // Dados para geração das Notas Fiscais
oView:AddSheet('FOLDER','FOLD_VFQ',STR0006) // Peças

oView:CreateHorizontalBox( 'BOXNF1', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXNF2', 50, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_NFS')
oView:CreateHorizontalBox( 'BOXVFQ',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_VFQ')

oView:SetOwnerView( 'VIEW_VFJ' , 'CABEC'  ) // Processo
oView:SetOwnerView( 'VIEW_TOT' , 'TOTAIS' ) // Custos Totais
oView:SetOwnerView( 'VIEW_VFK' , 'BOXNF1' ) // NFs Saida
oView:SetOwnerView( 'VIEW_VFL' , 'BOXNF2' ) // NFs Entrada
oView:SetOwnerView( 'VIEW_VFQ' , 'BOXVFQ' ) // Peças

oView:SetNoInsertLine('VIEW_VFK') // NFs Saida - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFK') // NFs Saida - Nao Deletar Linhas

oView:SetNoInsertLine('VIEW_VFL') // NFs Entrada - Nao Inserir Linhas
oView:SetNoDeleteLine('VIEW_VFL') // NFs Entrada - Nao Deletar Linhas

Return oView