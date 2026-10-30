#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "OFIA543.CH"

Function OFIA543()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VW8')
	oBrowse:SetDescription(STR0001) //"Reserva de peças de atendimento modelo 2"
	oBrowse:Activate() 

Return

Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA543')

Return aRotina

Static Function ModelDef()
	Local oModel
	Local oStrVW8 := FWFormStruct(1, "VW8")

	oModel := MPFormModel():New('OFIA543',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oModel:AddFields('VW8MASTER',/*cOwner*/ , oStrVW8)
	oModel:SetPrimaryKey( { "VW8_FILIAL", "VW8_CODIGO" } )
	oModel:SetDescription(STR0001) //"Reserva de peças de atendimento modelo 2"
	oModel:GetModel('VW8MASTER'):SetDescription(STR0002) //"Dados de reserva de peças no atendimento modelo 2"

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVW8:= FWFormStruct(2, "VW8")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'VW8', 100)
	oView:AddField('VIEW_VW8', oStrVW8, 'VW8MASTER')
	oView:EnableTitleView('VIEW_VW8', STR0001) //"Reserva de peças de atendimento modelo 2"
	oView:SetOwnerView('VIEW_VW8','VW8')

Return oView
