#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} COMA224EQU
Browse para el documento de Notas de Crédito Internas (NCI)
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Function COMA224EQU()
Local oBrowse	:= Nil

Private bGdRefresh := {||}
Private cA100For   := ""
Private cLoja      := ""
Private cNFiscal   := ""
Private cSerie     := ""
Private cTipo      := ""

	If FindFunction("MxChkPE")
		MxChkPE("COMA224")
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

	oBrowse := FwLoadBrw('COMA224')

Return oBrowse

/*/{Protheus.doc} MenuDef
Define las operaciones que serán realizadas por la aplicación
@author 	luis.samaniego
@since 		12/2024
@version	12.1.2210 / Superior
@type       Function
/*/

Static Function MenuDef()
Local aRotina := FWLoadMenuDef('COMA224')
	
Return aRotina
