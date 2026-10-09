#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOCXNCE.CH'

PUBLISH MODEL REST NAME LOCXNCE

#DEFINE SOURCEFATHER "LOCXIN"

/*/{Protheus.doc} LOCXNCE
Model para el documento de Nota de crédito de entradas
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXNCE()
Local oBrowse	:= Nil

	oBrowse := FwLoadBrw('COMA224')
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA224')

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

	If oView:GetViewStruct("SD1_DETAIL"):HasField("D1_ITEMPC") .AND. oView:GetViewStruct("SD1_DETAIL"):HasField("D1_PEDIDO") 
		oView:GetViewObj("SD1_DETAIL")[3]:oStructView:RemoveField( "D1_ITEMPC" )
		oView:GetViewObj("SD1_DETAIL")[3]:oStructView:RemoveField( "D1_PEDIDO" )
	Endif
	
Return oView
