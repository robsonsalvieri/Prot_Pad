#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM1030.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GPEM030RUS
    Vacations on MVC (Russia).

    @type Function
    @version 12.1.33
    @author vselyakov
    @since 16/11/2023
    @return Object, Object of function GPEM030.
/*/
Function GPEM030RUS()
Return GPEM030()


/*/{Protheus.doc} BrowseDef
    Defenition of Browse routine.

    @type Function
    @version 12.1.33
    @author vselyakov
    @since 16/11/2023
    @return Object, Browse of GPEA340 routine.
/*/
Static Function BrowseDef()
Return FWLoadBrw("GPEM030")


/*/{Protheus.doc} MenuDef
    Defenition of menu for routine.

    @type Function
    @version 12.1.33
    @author vselyakov
    @since 16/11/2023
    @return Object, Menu of GPEA340 routine.
/*/
Static Function MenuDef()
Return FWLoadMenuDef("GPEM030")


/*/{Protheus.doc} ModelDef
    Defenition of model for routine.

    @type Function
    @version 12.1.33
    @author vselyakov
    @since 16/11/2023
    @return Object, ModelDef of GPEM030 routine.
/*/
Static Function ModelDef()
Return FwLoadModel("GPEM030")


/*/{Protheus.doc} ViewDef
    Defenition of view for routine.

    @type Function
    @version 12.1.33
    @author vselyakov
    @since 16/11/2023
    @return Object, ViewDef of GPEM030 routine.
/*/
Static Function ViewDef()
Return FwLoadView("GPEM030")

/*/{Protheus.doc} RUGPM03001_ValidData()

    Validation for data in SRH table

    @type Function
    @return lResult, Logical, Is valid
    @author dchizhov
    @since 2024.02.26
    @version 12.1.23.10
    @example RUGPM03001()
*/
Function RUGPM03001_ValidData()

    Local lResult As Logical

    lResult := M->RH_DATAINI < SRA->RA_ADMISSA

    If !IsBlind() .And. lResult
        Help( , , STR0088, , STR0216, 1, 0, , , , , , {STR0217} ) // "Attention", "The start date of leave cannot be less than the date of hire", "Enter a valid date"
    EndIf

    lResult := !lResult

Return lResult
