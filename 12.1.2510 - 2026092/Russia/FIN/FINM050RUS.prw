#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


/*{Protheus.doc} FINM050RUS
@description
@author oleg.ivanov
@since 30/06/2021
@version 1.0
@project MA3 - Russia
*/
Function FINM050RUS()
Return Nil


/*{Protheus.doc} ModelDef
@description
@author oleg.ivanov
@since 30/06/2021
@version 1.0
@project MA3 - Russia
*/
Static Function ModelDef()
Return FwLoadModel("FINM050")                   
//Merge Russia R14 
                   
