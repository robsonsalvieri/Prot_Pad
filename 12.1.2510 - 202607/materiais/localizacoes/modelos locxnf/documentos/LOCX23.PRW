#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX23.CH'

PUBLISH MODEL REST NAME LOCX23

#DEFINE SOURCEFATHER "LOCXNDE"
#DEFINE _ESPECIE     "NDP"
#DEFINE _TIPODOC      23

Static lChkLxProp   := FindFunction("ChkLxProp")

/*/{Protheus.doc} ModelDef
Definición de modelo de datos
@author 	raul.medina
@return		oModel objeto del Modelo
@since 		11/2023
@version	12.1.2210 / Superior
/*/
Static Function ModelDef()
Local oModel        := FwLoadModel(SOURCEFATHER)

    LxSetModIn(@oModel, cPaisLoc, _TIPODOC, _ESPECIE)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "23" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "C" })
    ModFisStru(@oModel)

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():NotaDebitoAjuste()
    EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		11/2023
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)
Local oModel        := FwLoadModel("LOCX23")
Local lEditImp      := SuperGetMV( "MV_EDITIMP", .F., .F. )
Local lMulNatP      := SuperGetMv("MV_MULNATP", .F., .F.)

    oView:SetModel(oModel)

    LxSelDocIn(@oView, cPaisLoc, _TIPODOC, _ESPECIE)   
    
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

    oView:AddUserButton(STR0001, "CARGA",	{ |oView| LxNFForF6(oView:getModel())},,, {MODEL_OPERATION_INSERT } ) //"Facturas"
    oView:AddUserButton(STR0002, "CARGA",	{ |oView| ModRatCC(oView:getModel()) },,VK_F9,  ) //"Prorrateo"
    If lEditImp
        oView:AddUserButton(STR0003, "CARGA",	{ |oView| LxModImp("I", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto (Item)"
        oView:AddUserButton(STR0004, "CARGA",	{ |oView| LxModImp("T", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto"
    EndIf
    If lMulNatP
        oView:AddUserButton(STR0005, "CARGA",	{ |oView| MultiNatIn(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf
    oView:AddUserButton(STR0007, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0006)) //"Nota de Débito - Nota Ajuste"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX23VIEW")
		ExecBlock("LOCX23VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
