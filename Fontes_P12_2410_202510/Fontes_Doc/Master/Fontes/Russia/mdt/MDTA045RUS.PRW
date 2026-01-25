#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MDTA045.ch"

//-------------------------------------------------------------------
/*{Protheus.doc} GPEA030RUS 
    Establish Positions Register File (Russia)

    @author dchizhov
    @since 08.02.2023
    @version 12.1.33
    @project DMA3 - Russia
*/
//-------------------------------------------------------------------
Function MDTA045RUS()	
Return MDTA045()

//-------------------------------------------------------------------
/*{Protheus.doc} BrowseDef
    Browse definition.

    @author dchizhov
    @since 08.02.2023
    @version 12.1.33
    @project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Return FWLoadBrw("MDTA045") 

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
    Menu definition.

    @author dchizhov
    @since 08.02.2023
    @version 12.1.33
    @project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return FWLoadMenuDef("MDTA045")

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
    Model defenition.

    @author dchizhov
    @since 08.02.2023
    @version 12.1.33
    @project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Return FwLoadModel("MDTA045")

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
    View defenition.

    @author dchizhov
    @since 08.02.2023
    @version 12.1.33
    @project DMA3 - Russia
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Return FWLoadView("MDTA045")
