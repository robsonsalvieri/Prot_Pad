#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE SOURCEFATHER "M486EVENTPAR"

/*/{Protheus.doc} ModelDef
    Definición de modelo de datos - Tipo de evento: 1=Transporte - Motivo: 1=Lugar de entrega
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
    @return	oModel objeto del Modelo
/*/
Static Function ModelDef()
Local oModel := FwLoadModel(SOURCEFATHER) 

    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_DEPNOV', MODEL_FIELD_OBRIGAT, .T.)
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_CIDNOV', MODEL_FIELD_OBRIGAT, .T.)
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_ENDNOV', MODEL_FIELD_OBRIGAT, .T.)
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_NUMNOV', MODEL_FIELD_OBRIGAT, .T.)   			
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_DEPANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_CIDANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_DISANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_ENDANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_NUMANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_BAIANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})			

Return oModel


/*/{Protheus.doc} ViewDef
    Interface del modelo de datos - Tipo de evento: 1=Transporte - Motivo: 1=Lugar de entrega
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
    @return	oView objeto del View
/*/
Static Function ViewDef()
Local oView  := FwLoadView(SOURCEFATHER)
Local oModel := FwLoadModel("M486EPART1M1")

    oView:SetModel(oModel)
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_MOTANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_MOTNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_TRPANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_TRPNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_VEIANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_VEINOV")
	
Return oView
