#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA480.CH"

Function OFIA480()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VB2')
	oBrowse:SetDescription(STR0001) //'Reserva de peças de orçamento'
	oBrowse:Activate()

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA480')

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStrVB2 := FWFormStruct(1, "VB2")

	oModel := MPFormModel():New('OFIA480',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VB2MASTER',/*cOwner*/ , oStrVB2)
	oModel:SetPrimaryKey( { "VB2_FILIAL", "VB2_CODIGO" } )
	oModel:SetDescription(STR0001) //"Reserva de peças de orçamento"
	oModel:GetModel('VB2MASTER'):SetDescription(STR0002) //"Dados de reserva de peças de orçamento"

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVB2:= FWFormStruct(2, "VB2")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VB2', 100)
	oView:AddField('VIEW_VB2', oStrVB2, 'VB2MASTER')
	oView:EnableTitleView('VIEW_VB2', STR0001) //"Reserva de peças de orçamento"
	oView:SetOwnerView('VIEW_VB2','VB2')

Return oView
