#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOCX60.CH'

PUBLISH MODEL REST NAME LOCX60

#DEFINE SOURCEFATHER    "LOCXREN"
#DEFINE _ESPECIE        "RCN"
#DEFINE _TIPODOC        60

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
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "60" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "N" })

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():RemitoEntrada()
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
Local oModel        := FwLoadModel("LOCX60")
    
    oView:SetModel(oModel)

    LxSelDocIn(@oView, cPaisLoc, _TIPODOC, _ESPECIE) 

    oView:AddUserButton(STR0002, "CARGA",	{ |oView| Iif(LxModForF4(oView:getModel(), .F.),FWMsgRun( , {||CalcImpIN()}, STR0005, STR0005),) },,, {MODEL_OPERATION_INSERT } ) //"Ped. Comp." "Calculando"
    oView:AddUserButton(STR0003, "CARGA",	{ |oView| Iif(LxModForPC(oView:getModel(), .F.),FWMsgRun( , {||CalcImpIN()}, STR0005, STR0005),) },,, {MODEL_OPERATION_INSERT } ) //"Item Ped. Comp." "Calculando"
    oView:AddUserButton(STR0004, "CARGA",	{ |oView| ModRatCC(oView:getModel()) },, VK_F9,  ) //"Prorrateo"
    If BtnPrnfBen()
        oView:AddUserButton(STR0006, "CARGA",	{ |oView| LxaRetBen(oView:getModel()) },,, {MODEL_OPERATION_INSERT } ) //"Devolución Mej."
    EndIf
    oView:AddUserButton(STR0007, "CARGA",	{ |oView| LxF1Track(oView:getModel()) },,,{MODEL_OPERATION_VIEW}) //"Tracker"
    oView:AddUserButton(STR0008, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0001))  //"Remito"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX60VIEW")
		ExecBlock("LOCX60VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
