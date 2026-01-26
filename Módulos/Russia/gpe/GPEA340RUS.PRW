#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA340.CH"
#INCLUDE "FWMVCDEF.CH"

/*/ {Protheus.doc} GPEA340RUS
    Registration of Unions in MVC (Russia).

    @author alysenko
    @since 15.08.2023
    @project RULOC - Russia Localization
    @version 12.1.33
    @return Object of function GPEA340.
/*/
Function GPEA340RUS()
Return GPEA340()


/*/ {Protheus.doc} BrowseDef
    Defenition of Browse routine.

    @author alysenko
    @since 15.08.2023
    @project RULOC - Russia Localization
    @version 12.1.33
    @return Browse of GPEA340 routine.
/*/
Static Function BrowseDef()
Return FWLoadBrw("GPEA340")


/*/ {Protheus.doc} MenuDef
    Defenition of menu for routine.

    @author alysenko
    @since 15.08.2023
    @project RULOC - Russia Localization
    @version 12.1.33
    @return Menu of GPEA340 routine.
/*/
Static Function MenuDef()
Return FWLoadMenuDef("GPEA340")


/*/ {Protheus.doc} ModelDef
    Defenition of model for routine.

    @author alysenko
    @since 15.08.2023
    @project RULOC - Russia Localization
    @version 12.1.33
    @return ModelDef of GPEA340 routine (table RCE).
/*/
Static Function ModelDef()
Return FwLoadModel("GPEA340")


/*/ {Protheus.doc} ViewDef
    Defenition of view for routine.

    @author alysenko
    @since 15.08.2023
    @project RULOC - Russia Localization
    @version 12.1.33
    @return ViewDef of GPEA340 routine.
/*/
Static Function ViewDef()
Return FwLoadView("GPEA340")
