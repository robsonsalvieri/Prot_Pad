#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX10AUT.CH'

PUBLISH MODEL REST NAME LOCX10AUT

#DEFINE SOURCEFATHER "LOCXNFE"
#DEFINE _ESPECIE     "NF"
#DEFINE _TIPODOC      10

Static lChkLxProp   := FindFunction("ChkLxProp")

/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		02/2024
@version	12.1.2210 / Superior
/*/
Static Function ModelDef()
Local oModel        := FwLoadModel(SOURCEFATHER)

    LxSetModIn(@oModel, cPaisLoc, _TIPODOC, _ESPECIE, .F., .T.)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "10" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "N" })
    ModFisStru(@oModel)

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():Autofactura()
    EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		05/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)
Local oModel        := FwLoadModel("LOCX10AUT")
Local lEditImp      := SuperGetMV( "MV_EDITIMP", .F., .F. )
Local lMulNatP      := SuperGetMv("MV_MULNATP", .F., .F.)

    oView:SetModel(oModel)

    LxSelDocIn(@oView, cPaisLoc, _TIPODOC, _ESPECIE, .F., .T.)   
    
    //Carga de las propiedades para el total
    LxTotView(oView)

    //Carga de propiedades para financiero
    LxFinView(@oView)

    //Carga de propiedades para fiscal
    LxFisView(@oView)

    //Carga de propiedades para los titulos
    LxDupView(@oView)

    //Creación de box y asignación de estructuras.
    LxViewInF(@oView) 

    //Carga de propiedades de caja chica.
    LxCaixaVw(@oView)

    oView:AddUserButton(STR0001, "CARGA",	{ |oView| Iif(LxModForF4(oView:getModel()),FWMsgRun( , {||CalcImpIN()}, STR0011, STR0011),)},,, {MODEL_OPERATION_INSERT } ) //"Ped. Comp." "Calculando"
    oView:AddUserButton(STR0002, "CARGA",	{ |oView| Iif(LxModForPC(oView:getModel()),FWMsgRun( , {||CalcImpIN()}, STR0011, STR0011),)},,, {MODEL_OPERATION_INSERT } ) //"Item Ped. Comp." "Calculando"
    oView:AddUserButton(STR0003, "CARGA",	{ |oView| Iif(LxSCMToREM(oView:getModel()),FWMsgRun( , {||CalcImpIN()}, STR0011, STR0011),)},,, {MODEL_OPERATION_INSERT } ) //"Remito" "Calculando" 
    oView:AddUserButton(STR0004, "CARGA",	{ |oView| Iif(LxSCMToNF(oView:getModel()),FWMsgRun( , {||CalcImpIN()}, STR0011, STR0011),)},,, {MODEL_OPERATION_INSERT } ) //"Item Remito" "Calculando"
    oView:AddUserButton(STR0006, "CARGA",	{ |oView| ModRatCC(oView:getModel()) },,VK_F9,  ) //"Prorrateo"
    If lEditImp
        oView:AddUserButton(STR0007, "CARGA",	{ |oView| LxModImp("I", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto (Item)"
        oView:AddUserButton(STR0008, "CARGA",	{ |oView| LxModImp("T", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto"
    EndIf
    If lMulNatP
        oView:AddUserButton(STR0009, "CARGA",	{ |oView| MultiNatIn(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf
    If BtnPrnfBen()
        oView:AddUserButton(STR0010, "CARGA",	{ |oView| LxaRetBen(oView:getModel()) },,, {MODEL_OPERATION_INSERT } ) //"Devolución Mej."
    EndIf
    oView:AddUserButton(STR0012, "CARGA",	{ |oView| LxF1Track(oView:getModel()) },,,{MODEL_OPERATION_VIEW}) //"Tracker"
    oView:AddUserButton(STR0013, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0005)) //"Autofacturación"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX10AUTV")
		ExecBlock("LOCX10AUTV",.F.,.F.,{@oView})
	EndIf
	
Return oView

