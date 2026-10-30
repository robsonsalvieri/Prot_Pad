#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RU69T01RUS.CH"

Function RU69T01()
Return

Static Function MenuDef()
    Local aRotina as ARRAY
    aRotina := FWMVCMenu("RU69T01")
Return aRotina

Static Function ModelDef()
    Local oModel	as object	 
    Local oStruHead	as object
    Local oStruDet	as object
    Local oModelEvent as object

    oStruHead	:= FWFormStruct(1,"F5Q")
    oStruDet    := FWFormStruct(1,"F5R") 

    oModel		:= MPFormModel():New("RU69T01", /* Pre-valid */, /* Pos-Valid */, /* Commit */)
    oModel:AddFields("F5QMASTER", /*cOwner*/, oStruHead)
    oModel:AddFields("F5RDETAIL", "F5QMASTER", oStruDet, /* bLinePre */, /* bLinePost */, /* bPre */, /* bLinePost */, /* bLoadGrid */)

    oModel:GetModel("F5QMASTER"):SetDescription(STR0007) 
    oModel:GetModel("F5RDETAIL"):SetDescription(STR0008) 
    oModel:SetDescription(STR0009) 
    oModel:SetRelation("F5RDETAIL", {{"F5R_FILIAL","XFILIAL('F5R')"},{"F5R_UIDF5Q","F5Q_UID"}}, F5R->(IndexKey(3)))
    oModelEvent 	:= RU69T01EventRUS():New()
    oModel:InstallEvent("oModelEvent"	,/*cOwner*/,oModelEvent)

Return oModel

Static Function ViewDef()
    Local oView		as object
    oView := FWFormView():New()
Return oView

Static Function BrowseDef()
    Local oBrowse as OBJECT
    oBrowse := FWMBrowse():New()
    oBrowse:AddLegend("F5Q_STATUS=='1'", "GREEN", STR0025)	// Open
    oBrowse:AddLegend("F5Q_STATUS<>'1'", "RED", STR0026)	// Closed
    oBrowse:SetAlias("F5Q")
    oBrowse:SetDescription(STR0001)
    oBrowse:SetMenuDef("RU69T01")
Return oBrowse
                   
//Merge Russia R14 
                   
