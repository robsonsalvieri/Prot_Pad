#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA481.CH"

Function OFIA481()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('VB3')
oBrowse:SetDescription(STR0001)
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('OFIA481')

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVB3 := FWFormStruct(1, "VB3")

oModel := MPFormModel():New('OFIA481',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VB3MASTER',/*cOwner*/ , oStrVB3)
oModel:SetPrimaryKey( { "VB3_FILIAL", "VB3_CODIGO" } )
oModel:SetDescription(STR0001) //"Reserva de peças de oficina"
oModel:GetModel('VB3MASTER'):SetDescription(STR0002) //"Dados de reserva de peças de oficina"

Return oModel

Static Function ViewDef()

Local oView
Local oModel := ModelDef()
Local oStrVB3:= FWFormStruct(2, "VB3")

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'VB3', 100)
oView:AddField('VIEW_VB3', oStrVB3, 'VB3MASTER')
oView:EnableTitleView('VIEW_VB3', STR0001) //"Reserva de peças de oficina"
oView:SetOwnerView('VIEW_VB3','VB3')

Return oView
