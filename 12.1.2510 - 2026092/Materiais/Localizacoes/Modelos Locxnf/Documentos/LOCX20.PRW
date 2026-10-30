#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX20.CH'

PUBLISH MODEL REST NAME LOCX20

#DEFINE SOURCEFATHER "LOCXNFE"
#DEFINE _ESPECIE     "NF"
#DEFINE _TIPODOC      20

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

    LxSetModIn(@oModel, cPaisLoc, _TIPODOC, _ESPECIE)
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "20" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "A" })
    ModFisStru(@oModel)

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():FacturaAnticipo()
    EndIf

Return oModel

/*/{Protheus.doc} ViewDef
Interface del modelo de datos
@return		oView objeto del View
@author 	raul.medina
@since 		02/2024
@version	12.1.2210 / Superior
/*/
Static Function ViewDef()
Local oView         := FwLoadView(SOURCEFATHER)
Local oModel        := FwLoadModel("LOCX20")
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

    If lEditImp
        oView:AddUserButton(STR0002, "CARGA",	{ |oView| LxModImp("I", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto (Item)"
        oView:AddUserButton(STR0003, "CARGA",	{ |oView| LxModImp("T", oView:getModel(), "SF1_MASTER","SD1_DETAIL") },,, {MODEL_OPERATION_INSERT } ) //"Edit. Impuesto"
    EndIf
    If lMulNatP
        oView:AddUserButton(STR0004, "CARGA",	{ |oView| MultiNatIn(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf
    oView:AddUserButton(STR0005, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0001)) //"Anticipo"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX20VIEW")
		ExecBlock("LOCX20VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
