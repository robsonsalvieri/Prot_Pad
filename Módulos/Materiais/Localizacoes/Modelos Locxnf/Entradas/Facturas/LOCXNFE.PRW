#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCXNFE.CH'

PUBLISH MODEL REST NAME LOCXNFE

#DEFINE SOURCEFATHER 	"LOCXIN"

/*/{Protheus.doc} LOCXNFE
Model para el documento de Facturas de Entrada
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXNFE()
Local oBrowse	:= Nil

	oBrowse := FwLoadBrw('COMA222')
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA222')
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local oModel        := FwLoadModel(SOURCEFATHER)
Local oStruSF1      := Nil

	oStruSF1 := oModel:GetModel("SF1_MASTER"):GetStruct()

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)

	oView:SetViewProperty('SD1_DETAIL', 'SETGRIDLINES', {10})
	
Return oView
