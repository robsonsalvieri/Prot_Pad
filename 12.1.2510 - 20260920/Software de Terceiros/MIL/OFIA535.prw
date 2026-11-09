#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "OFIA535.CH"

Function OFIA535()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001 ) // "Programa Promocional - Plus Cliente"
	oBrowse:SetAlias('VBZ')
	oBrowse:Activate()

Return


Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA535')

Return aRotina


Static Function ModelDef()

	Local oModel
	Local oStrVBZ := FWFormStruct(1, "VBZ")

	oModel := MPFormModel():New('OFIA535',;
	/*Pré-Validacao*/,;
	/*Pós-Validacao*/,;
	/*Confirmacao da Gravação*/,;
	/*Cancelamento da Operação*/)

	oStrVBZ:SetProperty("VBZ_TIPO" , MODEL_FIELD_WHEN, {|| Empty(FWFldGet('VBZ_CLIENT')) } )

	oStrVBZ:SetProperty("VBZ_CLIENT" , MODEL_FIELD_WHEN, {|| Empty(FWFldGet('VBZ_TIPO')) } )
	oStrVBZ:SetProperty("VBZ_LOJA"   , MODEL_FIELD_WHEN, {|| Empty(FWFldGet('VBZ_TIPO')) } )

	oModel:AddFields('VBZMASTER',/*cOwner*/ 	, oStrVBZ)

	oModel:SetPrimaryKey( { "VBZ_FILIAL", "VBZ_CODIGO" } )
	oModel:SetDescription( STR0001 ) // Programa Promocional - Plus Cliente
	oModel:GetModel('VBZMASTER'):SetDescription( STR0002 ) // "Informações do Programa Promocional - Plus Cliente"

	oModel:InstallEvent("OFIA535EVDEF", /*cOwner*/, OFIA535EVDEF():New("OFIA535"))

Return oModel


Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVBZ:= FWFormStruct(2, "VBZ")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVBZ', 45)
	oView:AddField('VIEW_VBZ', oStrVBZ, 'VBZMASTER')
	oView:EnableTitleView('VIEW_VBZ', STR0001 ) // Plano de Promoção - Plus Cliente
	oView:SetOwnerView('VIEW_VBZ','BOXVBZ')

Return oView