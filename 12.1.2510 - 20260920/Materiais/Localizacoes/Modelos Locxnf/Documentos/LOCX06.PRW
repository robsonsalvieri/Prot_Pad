#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX06.CH'

PUBLISH MODEL REST NAME LOCX06

#DEFINE SOURCEFATHER "LOCXNDS"
#DEFINE _ESPECIE     "NDI"
#DEFINE _TIPODOC      06


/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		07/2026
@version	12.1.2510 / Superior
/*/
Static Function ModelDef()
Local oModel        := FwLoadModel(SOURCEFATHER)

    LxStModOut(@oModel, cPaisLoc, _TIPODOC, _ESPECIE)
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPODOC",MODEL_FIELD_INIT,{|| "06" })
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPO",MODEL_FIELD_INIT,{|| "D" })
    
    If oModel:GetModel("SF2_MASTER"):HasField("F2_PV")
        oModel:GetModel("SF2_MASTER"):GetStruct():AddRules( 'SF2_MASTER', 'F2_CLIENTE', 'SF2_MASTER', 'F2_PV', 2)
        oModel:GetModel("SF2_MASTER"):GetStruct():AddRules( 'SF2_MASTER', 'F2_LOJA', 'SF2_MASTER', 'F2_PV', 2)
    EndIf
    
    ModOFisStr(@oModel)

Return oModel


/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		07/2026
@version	12.1.2510 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)
Local oModel        := FwLoadModel("LOCX06")
Local lMulNatP      := SuperGetMv("MV_MULNATP", .F., .F.)
Local lIntPMS       := IntePms()

    oView:SetModel(oModel)

    LxSlDocOut(@oView, cPaisLoc, _TIPODOC, _ESPECIE)   

    //Carga de las propiedades para el total
    LxOTotView(oView)

    //Carga de propiedades para financiero
    LxOFinView(@oView)

    //Carga de propiedades para fiscal
    LxOFisView(@oView)

    //Carga de propiedades para los titulos
    LxDupView(@oView, .T.)

    //Creación de box y asignación de estructuras.
    LxViewOutF(@oView) 

    If oView:GetViewStruct("SF2_MASTER"):HasField("F2_PV")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_PV", MVC_VIEW_ORDEM, "001")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_CLIENTE", MVC_VIEW_ORDEM, "002")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_LOJA", MVC_VIEW_ORDEM, "003")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("cNome", MVC_VIEW_ORDEM, "004")
    EndIf

    oView:AddUserButton(STR0002, "CARGA",	{ |oView| LXStockOut(oView:getModel(), '2', 'M->D2_QUANT')},,, {MODEL_OPERATION_INSERT } ) //Stock

    oView:AddUserButton(STR0003, "CARGA",	{ |oView| Iif(LxNFSD2F6(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0010, STR0010),)},,, {MODEL_OPERATION_INSERT } ) //"Facturas" "Calculando"

    oView:AddUserButton(STR0004, "CARGA",	{ |oView| Iif(LXStockOut(oView:getModel(), '2', 'M->D2_NFORI', .T.),FWMsgRun( , {||CalcImpOUT()}, STR0010, STR0010),)},,, {MODEL_OPERATION_INSERT } ) //'Doc Orig' "Calculando"

    oView:AddUserButton(STR0005, "CARGA",	{ |oView| Iif(LxSCMToRm2(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0010, STR0010),)},,, {MODEL_OPERATION_INSERT } ) //"Remito" "Calculando" 

    oView:AddUserButton(STR0006, "CARGA",	{ |oView| Iif(LxSCMToNF2(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0010, STR0010),)},,, {MODEL_OPERATION_INSERT } ) //"Item Remito" "Calculando"

    If lMulNatP
        oView:AddUserButton(STR0007, "CARGA",	{ |oView| MultNatOut(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf

    If lIntPMS
        oView:AddUserButton(STR0008, "CARGA",	{ |oView| LXInPMSOut(oView:getModel()) },,,  ) //"Int PMS"
    EndIf

    oView:AddUserButton(STR0009, "CARGA",	{|oView|ViewCalOUT(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular" - LxInPreCal(oView:GetModel())

    oView:SetDescription(OemtoAnsi(STR0001)) // "Nota Débito Interna"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX06VIEW")
		ExecBlock("LOCX06VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
