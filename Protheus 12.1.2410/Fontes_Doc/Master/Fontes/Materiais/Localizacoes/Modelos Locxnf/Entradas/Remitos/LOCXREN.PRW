#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCXREN.CH'

PUBLISH MODEL REST NAME LOCXREN

#DEFINE SOURCEFATHER "LOCXIN"

/*/{Protheus.doc} LOCXREN
Model para el documento de Remitos de Entrada
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXREN()
Local oBrowse	:= Nil

	oBrowse := FwLoadBrw('COMA221')
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA221')

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

	//Carga de las propiedades para el total
    LxTotView(@oView)
	LxInViewIn(@oView)
	oView:SetOwnerView('oStruSF1', 'CIMA')
	oView:SetOwnerView('oStruSD1', 'MEDIO')
	oView:SetOwnerView('oStruTot', 'BAIXO')

	//Campos retirados del grid por ser remitos.
    oView:GetViewObj("SD1_DETAIL")[3]:oStructView:RemoveField( "D1_REMITO" )
    oView:GetViewObj("SD1_DETAIL")[3]:oStructView:RemoveField( "D1_ITEMREM" )
	oView:GetViewObj("SD1_DETAIL")[3]:oStructView:RemoveField( "D1_SERIREM" )

    oView:SetViewProperty("SF1_MASTER", "SETCOLUMNSEPARATOR", {10})

    oView:SetViewProperty('SD1_DETAIL', 'SETGRIDLINES', {10})
	
Return oView
