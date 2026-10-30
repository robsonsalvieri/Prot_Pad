#INCLUDE 'totvs.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'LOCX61.CH'

PUBLISH MODEL REST NAME LOCX61

#DEFINE SOURCEFATHER "LOCXRES"
#DEFINE _ESPECIE     "RCD"
#DEFINE _TIPODOC      61

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
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPODOC",MODEL_FIELD_INIT,{|| "61" })
    oModel:GetModel("SF2_MASTER"):GetStruct():SetProperty("F2_TIPO",MODEL_FIELD_INIT,{|| "D" })

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
Local oModel        := FwLoadModel("LOCX61")
Local lIntPMS       := IntePms()

    oView:SetModel(oModel)

    LxSlDocOut(@oView, cPaisLoc, _TIPODOC, _ESPECIE)   

    If oView:GetViewStruct("SF2_MASTER"):HasField("F2_PV")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_PV", MVC_VIEW_ORDEM, "001")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_CLIENTE", MVC_VIEW_ORDEM, "002")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("F2_LOJA", MVC_VIEW_ORDEM, "003")
        oView:GetViewStruct("SF2_MASTER"):SetProperty("cNome", MVC_VIEW_ORDEM, "004")
    EndIf

    oView:GetViewObj("SD2_DETAIL")[3]:oStructView:RemoveField( "D2_REMITO" )
    oView:GetViewObj("SD2_DETAIL")[3]:oStructView:RemoveField( "D2_ITEMREM" )
    oView:GetViewObj("SD2_DETAIL")[3]:oStructView:RemoveField( "D2_SERIREM" )

    oView:AddUserButton(STR0002, "CARGA",	{ |oView| LXStockOut(oView:getModel(), '2', 'M->D2_QUANT')},,, {MODEL_OPERATION_INSERT } ) //Stock

    oView:AddUserButton(STR0003, "CARGA",	{ |oView| Iif(LXStockOut(oView:getModel(), '2', 'M->D2_NFORI', .T.),FWMsgRun( , {||CalcImpOUT()}, STR0006, STR0006),)},,, {MODEL_OPERATION_INSERT } ) //'Doc Orig'

    If lIntPMS
        oView:AddUserButton(STR0004, "CARGA",	{ |oView| LXInPMSOut(oView:getModel()) },,,  ) //"Int PMS"
    EndIf

    oView:AddUserButton(STR0005, "CARGA",	{|oView|,CalcImpOUT(oView)},,K_CTRL_I, {MODEL_OPERATION_INSERT }) //"Calcular" - LxInPreCal(oView:GetModel())

    oView:SetDescription(OemtoAnsi(STR0001)) // "Remito Devolución"

    //-- Punto de entrada para alterar la view
	If ExistBlock("LOCX61VIEW")
		ExecBlock("LOCX61VIEW",.F.,.F.,{@oView})
	EndIf
	
Return oView
