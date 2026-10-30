#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM040A.CH"
#INCLUDE "vkey.ch"

/*/{Protheus.doc} GPEM040
File needs for compatibility with the protheus localization rules

@type function
@author Dmitry Borisov
@since 23.05.2023
/*/
Function GPEM040RUS()
	GPEM040()
Return

Static Function MenuDef()
Return FwLoadMenuDef("GPEM040")

Static Function ModelDef()
Return FwLoadModel("GPEM040")

Static Function ViewDef()
Return FwLoadView("GPEM040")
