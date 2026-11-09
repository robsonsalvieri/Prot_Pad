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

     If  oModel:GetModel("SF1_MASTER"):HasField("F1_VALADI")
        oModel:AddCalc("TOTCALC", "SF1_MASTER", "SD1_DETAIL", "D1_TOTAL", "F1_VALADI", 'FORMULA', /*bCondition*/, /*bInitValue*/, RetTitle('F1_VALADI') /*cTitle*/,  { |oModel| LxInGetFld( oModel, "SF1_MASTER", "F1_VALADI" ) }/*bFormula*/)
    EndIf
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

   

    oView:AddUserButton(STR0001, "CARGA",	{|oView|LxInAdian(oView)},,, {MODEL_OPERATION_INSERT }) //"Anticipo"
	
Return oView
