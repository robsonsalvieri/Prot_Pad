#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

PUBLISH MODEL REST NAME M486EP13 source M486EPART1M3 RESOURCE OBJECT FsmRestModel

#DEFINE SOURCEFATHER "M486EVENTPAR"

/*/{Protheus.doc} ModelDef
    Definición de modelo de datos - Tipo de evento: 1=Transporte - Motivo: 3=Empresa de transporte
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
    @return	oModel objeto del Modelo
/*/
Static Function ModelDef()
Local oModel := FwLoadModel(SOURCEFATHER) 

    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_TRPNOV', MODEL_FIELD_OBRIGAT, .T.)   			
    oModel:GetModel("AQA_MASTER"):GetStruct():SetProperty( 'AQA_TRPANT', MODEL_FIELD_INIT, {|a,b| MEAQAINI(a,b)})

Return oModel


/*/{Protheus.doc} ViewDef
    Interface del modelo de datos - Tipo de evento: 1=Transporte - Motivo: 3=Empresa de transporte
    @type  Static Function
    @author Rafael Parma
    @since 11/2025
    @return	oView objeto del View
/*/
Static Function ViewDef()
Local oView  := FwLoadView(SOURCEFATHER)
Local oModel := FwLoadModel("M486EPART1M3")

    oView:SetModel(oModel)
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_DEPANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_DEPNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_CIDANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_CIDNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_DISANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_DISNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_ENDANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_ENDNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_NUMANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_NUMNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_BAIANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_BAINOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_MOTANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_MOTNOV")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_VEIANT")
    oView:GetViewStruct("AQA_MASTER"):RemoveField("AQA_VEINOV")

Return oView
