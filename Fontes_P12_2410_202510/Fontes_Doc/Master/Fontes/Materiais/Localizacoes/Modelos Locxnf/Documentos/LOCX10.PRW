#INCLUDE 'protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX10.CH'

PUBLISH MODEL REST NAME LOCX10

#DEFINE SOURCEFATHER "LOCXNFE"
#DEFINE _ESPECIE     "NF"
#DEFINE _TIPODOC      10

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
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPODOC",MODEL_FIELD_INIT,{|| "10" })
    oModel:GetModel("SF1_MASTER"):GetStruct():SetProperty("F1_TIPO",MODEL_FIELD_INIT,{|| "N" })
    ModFisStru(@oModel)

    If lChkLxProp
        DocumentProperty():New()
        DocumentProperty():FacturaEntrada()
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
Local oModel        := FwLoadModel("LOCX10")
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
        oView:AddUserButton(STR0013, "CARGA",	{ |oView| MultiNatIn(oView:getModel()) },,,  ) //"Multi-naturaleza"
    EndIf
    If BtnPrnfBen()
        oView:AddUserButton(STR0014, "CARGA",	{ |oView| LxaRetBen(oView:getModel()) },,, {MODEL_OPERATION_INSERT } ) //"Devolución Mej."
    EndIf
    oView:AddUserButton(STR0015, "CARGA",	{ |oView| LxF1Track(oView:getModel()) },,,{MODEL_OPERATION_VIEW}) //"Tracker"
    oView:AddUserButton(STR0016, "CARGA",	{|oView|LxInPreCal(oView:GetModel()),ViewCalcIn(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular"

    oView:SetDescription(OemtoAnsi(STR0005)) //"Factura de entrada"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX10VIEW")
		ExecBlock("LOCX10VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView

/*/{Protheus.doc} LxCaixaVw
Función utilizada para actualizar la estructura para el apartado financiero de la view
@author 	raul.medina
@since 		10/2023
@version	12.1.2210 / Superior
Parametros
    oView - - view a ser actualizada con la estructura del documento recibido, debe ser enviada como @oView.
@Return 
/*/
Function LxCaixaVw(oView)
Local aCamposSEU    := {"EU_CAIXA", "EU_VALOR", "EU_BENEF", "EU_HISTOR", "EU_NROADIA", "EU_NRREND"}
Local oStruSEU	    := FWFormStruct( 2, 'SEU',{|cCampo| FindString(AllTrim(cCampo), aCamposSEU)}, .F.)

    oStruSEU:SetProperty("EU_CAIXA", MVC_VIEW_ORDEM, "01")
    oStruSEU:AddField("EU_DSCCAIX", "02", STR0009, STR0009, Nil, "C", "@!", NIL, "", .F., NIL, NIL, NIL, NIL, NIL, .T., NIL) //"Descripción"
    oStruSEU:SetProperty("EU_VALOR", MVC_VIEW_ORDEM, "03")
    oStruSEU:SetProperty("EU_NROADIA", MVC_VIEW_ORDEM, "04")
    oStruSEU:SetProperty("EU_NRREND", MVC_VIEW_ORDEM, "05")
    oStruSEU:SetProperty("EU_BENEF", MVC_VIEW_ORDEM, "06")
    oStruSEU:SetProperty("EU_HISTOR", MVC_VIEW_ORDEM, "07")
    
    oView:AddField('oStruSEU' , oStruSEU, 'SEU_DETAIL' )

    oView:CreateFolder("FOLDERFIN","CIMAFIN")
    oView:AddSheet( 'FOLDERFIN', 'SHEET_FIN', STR0012 ) //Financiero.
    oView:CreateHorizontalBox( 'FINANCIERO', 100, , , 'FOLDERFIN', 'SHEET_FIN')

    oView:AddSheet( 'FOLDERFIN', 'SHEET_CAIXA', STR0010 ) //"Caja Chica".
    oView:CreateHorizontalBox( 'CAIXACHI', 100, , , 'FOLDERFIN', 'SHEET_CAIXA')

    oView:SetOwnerView('oStruFIN', 'FINANCIERO')
    oView:SetOwnerView('oStruSEU', 'CAIXACHI')

Return
