#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA360.CH"

/*/{Protheus.doc} MATA360RUS
Dummy file for compatibility with the protheus localization rules

@type function
@author Alexsandra Velmozhnaia
@since 01|SEP|2020
/*/
Function MATA360RUS()
	MATA360()
Return

Static Function BrowseDef()
Return FWLoadBrw("MATA360")

Static Function MenuDef()
Return FwLoadMenuDef("MATA360")

Static Function ModelDef()
Return FwLoadModel("MATA360")

Static Function ViewDef()
    Local oView    As Object
    Local oStructSE4 As Object

    oView := FWLoadView("MATA360")
    oStructSE4 := oView:GetViewStruct("VIEW_SE4")
    oStructSE4:RemoveField("E4_TPAY")

Return oView
                   
//Merge Russia R14 
                   
