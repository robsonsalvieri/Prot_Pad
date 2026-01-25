#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOCX62.CH'

PUBLISH MODEL REST NAME LOCX62 

#DEFINE SOURCEFATHER "LOCXREN"
#DEFINE _ESPECIE        "RCB"
#DEFINE _TIPODOC        62

Static lChkLxProp   := FindFunction("ChkLxProp")

/*/{Protheus.doc} ModelDef
Definición de modelo de datos 
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		08/2023 
@version	12.1.2210 / Superior
/*/
Static Function ModelDef()
Local oModel        := FwLoadModel(SOURCEFATHER)

    LxSetModIn(@oModel, cPaisLoc, _TIPODOC, _ESPECIE)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "62" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "B" })

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():RemitoEntradaBeneficiamento()
    EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		08/2023 
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)
Local oModel        := FwLoadModel("LOCX62")

    oView:SetModel(oModel)

    LxSelDocIn(@oView, cPaisLoc, _TIPODOC, _ESPECIE) 

    oView:AddUserButton(STR0002, "CARGA",	{ |oView| ModRatCC(oView:getModel()) },, VK_F9,  ) //"Prorrateo"
    oView:AddUserButton(STR0003, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0001)) //"Remito Beneficiamiento"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX62VIEW")
		ExecBlock("LOCX62VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
