#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} COMA222EQU
Browse para el documento de Facturas de Entrada (NF)
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Function COMA222EQU()
Local oBrowse	:= Nil

Private cTipo      := ""

	If FindFunction("MxChkPE")
		MxChkPE("COMA222")
	EndIf

	oBrowse := BrowseDef()
	oBrowse:Activate()
	
Return Nil

/*/{Protheus.doc} BrowseDef
Definición de Browse
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Static Function BrowseDef()
Local oBrowse := Nil

	oBrowse := FwLoadBrw('COMA222')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA222')
	
Return aRotina
