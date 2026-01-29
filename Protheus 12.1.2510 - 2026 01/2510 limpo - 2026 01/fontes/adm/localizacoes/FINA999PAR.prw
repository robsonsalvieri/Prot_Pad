#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA999.CH'

#DEFINE SOURCEFATHER "FINA999"

/*/{Protheus.doc} FINA999PAR
	Fuente de Modelo de Datos de Orden de Pago Localizado para Paraguay
	@author 	carlos.espinoza
	@since 		15/10/2025
	@version	12.1.2310 / Superior
/*/
Function FINA999PAR()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
	Definición de Browse
	@author	 	carlos.espinoza
	@since 		15/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function BrowseDef()
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
	Define las operaciones que serán realizadas por la aplicación
	@author 	carlos.espinoza
	@since 		15/10/2025
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
	@since 		15/10/2025
	@version	12.1.2310 / Superior
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oStruDOP		:= oModel:GetModel('DOP_DETAIL'):GetStruct()
Local oMdlEvent		:= FINV999PAR():New()

	oStruDOP:AddField(STR0027	, STR0027	, 'IVA'			, 'N' , 16, 2)		// "Ret. IVA"
	oStruDOP:AddField(STR0065	, STR0065	, 'IR'			, 'N' , 16, 2)		// "Ret. IR"

	//Evento del Modelo
	oModel:InstallEvent("FINV999PAR","FINV999",oMdlEvent)
	
Return oModel

/*/{Protheus.doc} ViewDef
	Interfce del modelo de datos de Cobros Diversos para localización padrón
	@return		oView objeto del View
	@author 	carlos.espinoza
	@since 		16/05/2025
	@version	12.1.2310 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)

	oModel := oView:GetModel()

Return oView
