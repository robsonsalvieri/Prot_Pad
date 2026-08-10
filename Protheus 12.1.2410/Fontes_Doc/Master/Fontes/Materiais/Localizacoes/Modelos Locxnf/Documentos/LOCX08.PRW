#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX08.CH'

PUBLISH MODEL REST NAME LOCX08 

#DEFINE SOURCEFATHER "LOCXNCE"
#DEFINE _ESPECIE     "NCI"
#DEFINE _TIPODOC      08

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
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "08" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "C" })
    ModFisStru(@oModel)

    If oModel:GetModel("SF1_MASTER"):HasField("F1_PV")
        oModel:GetModel("SF1_MASTER"):GetStruct():AddRules( 'SF1_MASTER', 'F1_FORNECE', 'SF1_MASTER', 'F1_PV', 2)
        oModel:GetModel("SF1_MASTER"):GetStruct():AddRules( 'SF1_MASTER', 'F1_LOJA', 'SF1_MASTER', 'F1_PV', 2)
    EndIf

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():NotaCreditoInterna()
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
Local oModel        := FwLoadModel("LOCX08")
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

    If oView:GetViewStruct("SF1_MASTER"):HasField("F1_PV")
        oView:GetViewStruct("SF1_MASTER"):SetProperty("F1_PV", MVC_VIEW_ORDEM, "001")
        oView:GetViewStruct("SF1_MASTER"):SetProperty("F1_FORNECE", MVC_VIEW_ORDEM, "002")
        oView:GetViewStruct("SF1_MASTER"):SetProperty("F1_LOJA", MVC_VIEW_ORDEM, "003")
        oView:GetViewStruct("SF1_MASTER"):SetProperty("cNome", MVC_VIEW_ORDEM, "004")
    EndIf

    If oView:GetViewStruct("SD1_DETAIL"):HasField("D1_REMITO")
        oView:GetViewStruct("SD1_DETAIL"):SetProperty("D1_REMITO",MVC_VIEW_TITULO,OemtoAnsi(oView:GetViewStruct("SD1_DETAIL"):GetProperty("D1_REMITO", MVC_VIEW_TITULO )))
    Endif  

    oView:AddUserButton(STR0001, "CARGA",	{ |oView| LxNFForF6(oView:getModel())},,, {MODEL_OPERATION_INSERT } ) //"Facturas"
    oView:AddUserButton(STR0002, "CARGA",	{ |oView| ModRatCC(oView:getModel()) },,VK_F9,  ) //"Prorrateo"
    If lMulNatP
        oView:AddUserButton(STR0003, "CARGA",	{ |oView| MultiNatIn(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf
    oView:AddUserButton(STR0005, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0004)) //"Nota Crédito Interna"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX08VIEW")
		ExecBlock("LOCX08VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
