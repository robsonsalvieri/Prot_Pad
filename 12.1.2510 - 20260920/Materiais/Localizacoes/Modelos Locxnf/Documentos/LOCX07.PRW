#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX07.CH'

PUBLISH MODEL REST NAME LOCX07

#DEFINE SOURCEFATHER "LOCXNCS"
#DEFINE _ESPECIE     "NCP"
#DEFINE _TIPODOC      07

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
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPODOC",MODEL_FIELD_INIT,{|| "07" })
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPO",MODEL_FIELD_INIT,{|| "D" })
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
Local oModel        := FwLoadModel("LOCX07")
Local lMulNatP      := SuperGetMv("MV_MULNATP", .F., .F.)
Local lEditImp      := SuperGetMV("MV_EDITIMP", .F., .F. )
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

    If lIntPMS
        oView:GetViewObj("SD2_DETAIL")[3]:oStructView:RemoveField( "D2_EDTPMS" )
    EndIf
    
    oView:AddUserButton(STR0002, "CARGA",	{ |oView| LXStockOut(oView:getModel(), '2', 'M->D2_QUANT')},,, {MODEL_OPERATION_INSERT } ) //Stock

    oView:AddUserButton(STR0003, "CARGA",	{ |oView| Iif(LxNFSD2F6(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0012, STR0012),)},,, {MODEL_OPERATION_INSERT } ) //"Facturas"

    oView:AddUserButton(STR0004, "CARGA",	{ |oView| Iif(LXStockOut(oView:getModel(), '2', 'M->D2_NFORI', .T.),FWMsgRun( , {||CalcImpOUT()}, STR0012, STR0012),)},,, {MODEL_OPERATION_INSERT } ) //'Doc Orig'

    oView:AddUserButton(STR0005, "CARGA",	{ |oView| Iif(LxSCMToRm2(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0012, STR0012),)},,, {MODEL_OPERATION_INSERT } ) //"Remito" "Calculando" 

    oView:AddUserButton(STR0006, "CARGA",	{ |oView| Iif(LxSCMToNF2(oView:getModel()),FWMsgRun( , {||CalcImpOUT()}, STR0012, STR0012),)},,, {MODEL_OPERATION_INSERT } ) //"Item Remito" "Calculando"

    If lEditImp
        oView:AddUserButton(STR0007, "CARGA",	{ |oView| LxModImp("I", oView:getModel(), "SF2_MASTER","SD2_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto (Item)"
        oView:AddUserButton(STR0008, "CARGA",	{ |oView| LxModImp("T", oView:getModel(), "SF2_MASTER","SD2_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto"
    EndIf

    If lMulNatP
        oView:AddUserButton(STR0009, "CARGA",	{ |oView| MultNatOut(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf

    If lIntPMS
        oView:AddUserButton(STR0010, "CARGA",	{ |oView| LXInPMSOut(oView:getModel()) },,,  ) //"Int PMS"
    EndIf

    oView:AddUserButton(STR0011, "CARGA",	{|oView|,ViewCalOUT(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular" - LxInPreCal(oView:GetModel())

    oView:SetDescription(OemtoAnsi(STR0001)) // "Nota Crédito Proveedor"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX07VIEW")
		ExecBlock("LOCX07VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
