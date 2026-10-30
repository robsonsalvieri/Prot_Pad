#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'

PUBLISH MODEL REST NAME L10AUPAR source LOCX10AUTPAR RESOURCE OBJECT FsmRestModel

#DEFINE SOURCEFATHER 	"LOCX10AUT"

Function LOCX10AUTPAR()
	
Return Nil

/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	cleber.denisp
@return		oModel objeto del Modelo
@since 		28/01/2026
@version	12.1.2210 / Superior
/*/
Static Function ModelDef()
Local oModel     := FwLoadModel(SOURCEFATHER)
Local oEvent     := COMA222EVPAR():New()

    oModel:InstallEvent("COMA222EVPAR",,oEvent)

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	cleber.denisp
@since 		28/01/2026
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView      := FwLoadView(SOURCEFATHER)
Local oModel     := oView:GetModel()

    oView:SetModel(oModel)

Return oView
