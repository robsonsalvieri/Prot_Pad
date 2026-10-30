#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} COMA223EQU
Browse para el documento de Nota de Débito (NDP)
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Function COMA223EQU()
Local oBrowse	:= Nil

Private bGdRefresh := {||}
Private cA100For   := ""
Private cLoja      := ""
Private cNFiscal   := ""
Private cSerie     := ""
Private cTipo      := ""

	If FindFunction("MxChkPE")
		MxChkPE("COMA223")
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

	oBrowse := FwLoadBrw('COMA223')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA223')
	
Return aRotina
