#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIA521.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} OFIA521
	MVC - Escalas

	@author Francisco Carvalho	
	@since 25/08/2025
/*/
//-------------------------------------------------------------------
Function OFIA521()

	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VOE')
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Definição do Menu

	@author Francisco Carvalho	
	@since 25/08/2025
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aRotina := FWMVCMenu('OFIA521')

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do Modelo

@author Francisco Carvalho
@since 25/08/2025
@version 1.0
@Return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStrVOE := FWFormStruct(1,"VOE")

	oModel := MPFormModel():New("OFIA521", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
	oModel:AddFields("VOEMASTER",/*cOwner*/ , oStrVOE)
	oModel:SetDescription(STR0001) //"Escalas"      

	oModel:SetPrimaryKey({})

Return oModel


/*/{Protheus.doc} ViewDef
Definição da interface

@author Francisco Carvalho
@since 25/08/2025
@version 1.0
@Return oView
/*/
Static Function ViewDef()

	Local oView
	Local oModel := ModelDef() 
	Local oStrVOE:= FWFormStruct(2,"VOE")

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField('VIEW_VOE', oStrVOE, 'VOEMASTER' )

	oView:CreateHorizontalBox('TELA' ,100)
	oView:SetOwnerView('VIEW_VOE' , 'TELA')

Return oView
