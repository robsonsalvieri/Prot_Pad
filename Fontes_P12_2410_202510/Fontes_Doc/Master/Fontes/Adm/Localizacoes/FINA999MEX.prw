#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA999.CH'

#DEFINE SOURCEFATHER "FINA999"

/*/{Protheus.doc} FINA999MEX
	Fuente de Modelo de Datos de Orden de Pago Localizado para México
	@author 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Function FINA999MEX()
Local oBrowse	:= Nil

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
	Definición de Browse
	@author	 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function BrowseDef()
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
	Define las operaciones que serán realizadas por la aplicación
	@author 	arodriguez
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function MenuDef()
Local aRotina := {}
	
aRotina := FWLoadMenuDef(SOURCEFATHER)

Return aRotina

/*/{Protheus.doc} ModelDef
	Definição do modelo de Dados
	@author 	arodriguez
	@return		oModel objeto del Modelo
	@since 		29/06/2025
	@version	12.1.2310 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oStruDOP		:= oModel:GetModel('DOP_DETAIL'):GetStruct()
Local oMdlEvent		:= FINV999MEX():New()

	oStruDOP:AddField(STR0039	, STR0039	, 'DCONCEP'	, 'C' , 255, 0) // "Desc. Conc."

	//Evento del Modelo
	oModel:InstallEvent("FINV999MEX","FINV999",oMdlEvent)

Return oModel

/*/{Protheus.doc} ViewDef
	Interfce del modelo de datos de Cobros Diversos para localización padrón
	@return		oView objeto del View
	@author 	arodriguez
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)

	oModel := oView:GetModel()

Return oView
