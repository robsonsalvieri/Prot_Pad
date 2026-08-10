#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "LOCXOUT"

/*/{Protheus.doc} LOCXNCS
Model para el documento de Nota de crédito de salidas
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Function LOCXNCS()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function BrowseDef()
Local oBrowse	:= Nil

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('SF2')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	raul.medina
@since 		03/2023
@version	12.1.2210 / Superior
/*/

Static Function MenuDef()
Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.LOCXNCS' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.LOCXNCS' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE 'Alterar' ACTION 'VIEWDEF.LOCXNCS' OPERATION 4 ACCESS 0 // 'Alterar'
	
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
Local oModel        := FwLoadModel(SOURCEFATHER)

    oView:SetModel(oModel)
	
Return oView
