#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTA090.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} MDTA090RUS 
Establish Positions Register File (Russia)

@author A. Lysenko
@since 06/02/2023
@version 12.1.33
@project
*/
//-------------------------------------------------------------------
Function MDTA090RUS()	
Return MDTA090()

//-------------------------------------------------------------------
/*{Protheus.doc} BrowseDef
Browse definition.
@author A. Lysenko
@since 06/02/2023
@version 12.1.33
@project
*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Return FWLoadBrw("MDTA090") 

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu definition.
@author A. Lysenko
@since 06/02/2023
@version 12.1.33
@project
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWLoadMenuDef("MDTA090")

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Model defenition.
@author A. Lysenko
@since 06/02/2023
@version 12.1.33
@project
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel('MDTA090')

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
View defenition.
@author A. Lysenko
@since 06/02/2023
@version 12.1.33
@project
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return FWLoadView("MDTA090")
