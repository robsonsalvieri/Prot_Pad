#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA999.CH'

#DEFINE SOURCEFATHER "FINA999"

/*/{Protheus.doc} FINA999PER
	Fuente de Modelo de Datos de Orden de Pago Localizado para Perú
	@author 	carlos.espinoza
	@since 		07/10/2025
	@version	12.1.2310 / Superior
/*/
Function FINA999PER()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
	Definición de Browse
	@author	 	carlos.espinoza
	@since 		07/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function BrowseDef()
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
	Define las operaciones que serán realizadas por la aplicación
	@author 	carlos.espinoza
	@since 		07/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function MenuDef()
Local aRotina := {}
	
aRotina := FWLoadMenuDef(SOURCEFATHER)

Return aRotina

/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados
	@author 	carlos.espinoza
	@return		oModel objeto del Modelo
	@since 		07/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oMdlEvent		:= FINV999PER():New()

	//Evento del Modelo
	oModel:InstallEvent("FINV999PER","FINV999",oMdlEvent)

Return oModel

/*/{Protheus.doc} ViewDef
	Interface del modelo de datos de Orden de Pago
	@return		oView objeto del View
	@author 	carlos.espinoza
	@since 		07/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)

	oModel := oView:GetModel()

Return oView
