#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "VEIA147.CH"

Static cCpoCabVBS := "VBS_CODIGO/VBS_CREDNT"

/*/{Protheus.doc} VEIA147()
Histórico de Negociação de Incentivo de Bônus

@author Renato Vinicius
@since 10/04/2024
@version 1.0
@return NIL
/*/

Function VEIA147()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VBS')
oBrowse:SetDescription(STR0001) //Histórico de Negociação na NF Credito
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA147')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStruVBSCab := FWFormStruct( 1, 'VBS', { |cCampo| ALLTRIM(cCampo) $ cCpoCabVBS } )
Local oStrVBS     := FWFormStruct( 1, 'VBS')

oModel := MPFormModel():New('VEIA147',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields( 'VBSMASTER', /*cOwner*/, oStruVBSCab, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ )
oModel:AddGrid(   'VBSDETAIL','VBSMASTER', oStrVBS    , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /**/)

oModel:SetRelation('VBSDETAIL', { { 'VBS_FILIAL' , 'xFilial("VBS")' } , { 'VBS_CODIGO' , 'VBS_CODIGO' } } , 'VBS_FILIAL+VBS_CODIGO' )

oModel:SetPrimaryKey( { "VBS_FILIAL", "VBS_CODIGO", "VBS_SEQUEN" } )

oModel:SetDescription(STR0001) //Histórico de Negociação na NF Credito
oModel:GetModel('VBSMASTER'):SetDescription(STR0002) //Dados do histórico de Negociação na NF Credito


Return oModel

Static Function ViewDef()

Local oView
Local oModel      := ModelDef()

Local oStruVBSCab := FWFormStruct( 2, "VBS" , { |cCampo| ALLTRIM(cCampo) $ cCpoCabVBS } )
Local oStrVBS     := FWFormStruct( 2, "VBS" , { |cCampo| !(ALLTRIM(cCampo) $ cCpoCabVBS) })

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VBSCAB', 10)
oView:CreateHorizontalBox( 'VBSDET', 90)

oView:AddField( 'VIEW_VBSCAB', oStruVBSCab, 'VBSMASTER' )
oView:AddGrid(  'VIEW_VBS'   , oStrVBS    , 'VBSDETAIL' )

oView:SetOwnerView('VIEW_VBSCAB','VBSCAB')
oView:EnableTitleView('VIEW_VBSCAB', STR0003 ) //"Negociação"

oView:SetOwnerView('VIEW_VBS','VBSDET')
oView:EnableTitleView('VIEW_VBS', STR0004) //"Detalhes da Negociação"

Return oView
