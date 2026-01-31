#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOCX10PER.CH'

PUBLISH MODEL REST NAME LOCX10PER

#DEFINE SOURCEFATHER 	"LOCX10"

Function LOCX10PER()
	
Return Nil

/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	laura.medina
@return		oModel objeto del Modelo
@since 		09/2024
@version	12.1.2210 / Superior
/*/

Static Function ModelDef()
Local oModel		:= FwLoadModel(SOURCEFATHER)

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		09/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)

    If oView:GetModel("SF1_MASTER"):HasField("F1_VALADI")
        oView:GetViewStruct("oStruTot"):AddField("F1_VALADI" ,"999" ,AllTrim(FwX3Titulo("F1_VALADI")) ,AllTrim(FwX3Titulo("F1_VALADI")), {""}, "N", GetSx3Cache("F1_VALADI", "X3_PICTURE"), NIL, "", .F., NIL, NIL, {}, NIL, NIL, .F.)
    EndIf

    oView:AddUserButton(STR0001, "CARGA",	{|oView|LxInAdian(oView)},,, {MODEL_OPERATION_INSERT }) //"Anticipo"
	
Return oView
