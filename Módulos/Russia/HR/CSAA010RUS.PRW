#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CSAA010.CH"

Function CSAA010RUS()
Return CSAA010()

Static Function MenuDef()
Return FWLoadMenuDef("CSAA010")

Static Function ModelDef()
Return FwLoadModel("CSAA010")

Static Function ViewDef()
Return FWLoadView("CSAA010")    
