#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SOURCEFATHER "FINA887"

/*/{Protheus.doc} FINA887BOL
Fonte de cobros diversos (Bolivia)
@type 		Function
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Function FINA887BOL()
Local oBrowse := Nil
	
	oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
Return nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@type 		Function
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Static Function BrowseDef() 
Local oBrowse := Nil

	oBrowse := FwLoadBrw(SOURCEFATHER)

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@type 		Function
@author 	luis.aboytes
@version	12.1.33 / Superior
@since		08/06/2022
/*/
Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)
Local oEvtTit		:= F887FINBOL():New()

	oModel:InstallEvent("F887FINBOL", "F887FIN", oEvtTit)

Return oModel

/*/{Protheus.doc} ViewDef
Interfce del modelo de datos de Cobros Diversos para localización Bolivia
@return		oView objeto del View
@author 	raul.medina
@since 		12/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView		:= FWLoadView(SOURCEFATHER)

	oView:GetViewObj("VIEW_SEL")[3]:oStructView:RemoveField( "EL_TIPO" )
	
Return oView
