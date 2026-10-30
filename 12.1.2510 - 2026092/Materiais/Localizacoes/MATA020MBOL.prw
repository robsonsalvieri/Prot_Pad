#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'MATA020.ch'

#DEFINE SOURCEFATHER "MATA020"

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MATA020MBOL
Registro de Proveedores localizado para BOLIVIA.

El fuente contiene browse, menú, modelo y su propia vista, todos heredados de MATA020.
Cualquier regla que se aplique solamente para BOLIVIA debe ser definida aquí.

Las validaciones e integraciones realizadas después/durante la grabación están definidas en los eventos del modelo,
en la clase MATA020EVBOL.

@type function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
//-------------------------------------------------------------------------------------------------------------
Function MATA020MBOL()
Local oBrowse := BrowseDef()
	
	oBrowse:Activate()
	
	//Limpa a tecla de atalho do F12
	A020F12End()
Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Define el browse estándar para el registro de proveedores de BOLIVIA.

@type function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse := FwLoadBrw(SOURCEFATHER) 
Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define el modelo estándar para el registro de proveedores de BOLIVIA, instalando el
evento MATA020EVBOL responsable de las reglas específicas del país.

@type function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel := FWLoadModel(SOURCEFATHER)
Local oEvent := MATA020EVBOL():New()
	
	oModel:InstallEvent("BOLIVIA",,oEvent)	
	
Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define la view estándar para el registro de proveedores de BOLIVIA.

@type function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView := FWLoadView(SOURCEFATHER)
Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Define el menú estándar para el registro de proveedores de BOLIVIA.

@type function
@author Gilberto Frohlich
@since 03/07/2026
@version 2510
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := FWLoadMenuDef(SOURCEFATHER)	
Return aRotina
