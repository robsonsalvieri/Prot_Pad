#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU05D01.CH"

/*/{Protheus.doc} RU02D01
Dummy file for compatibility with the protheus localization rules

@type function
@author Artem Kostin
@since Jun|2019
/*/
Function RU02D01RUS()
	//(31/10/19): Series of documents
	SetKey(VK_F12, {|| AcessaPerg("RU02D01",.T.)})
	RU02D01()
Return

Static Function BrowseDef()
Return FWLoadBrw("RU02D01")

Static Function MenuDef()
Return FwLoadMenuDef("RU02D01")

Static Function ModelDef()
Return FwLoadModel("RU02D01")

Static Function ViewDef()
Return FwLoadView("RU02D01")
//Merge Russia R14                   
