#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RU16XFUN04_Pona050Vis( cAlias , nReg , nOpcx )
    Function for view the form.

    @type Function
    @params cAlias, Character, Alias for view.
    @params nReg,   Numeric, Recno for view.
    @params nOpcx,  Numeric, Option number in aRotina.
    @return nOpca,  Numeric, Result of dialog
    @author dchizhov
    @since 14.10.2022
    @version 12.1.33
    @example { STR0005 , "RU16XFUN04_Pona050Vis", 0 , 2}
*/
Function RU16XFUN04_Pona050Vis( cAlias , nReg , nOpcx )
Return( AxVisual( cAlias , nReg , nOpcx , Iif(cPaisLoc $ "RUS", RU16XFUN05_CampoForView(cAlias), NIL) ) )

/*/{Protheus.doc} RU16XFUN05_CampoForView(cAlias)
    Function for Russia. Composes an array of fields displayed on the form.

    @type Function
    @params cAlias, Character, Alias for view.
    @return aCampo, Array, Array of fields displayed on the form
    @author dchizhov
    @since 14.10.2022
    @version 12.1.33
    @example AxAltera( cAlias , nReg , nOpcx , Iif(cPaisLoc $ "RUS", RU16XFUN05_CampoForView(cAlias), NIL) , NIL , NIL , NIL , "Pona050TudOk()" )
*/
Function RU16XFUN05_CampoForView(cAlias)
    Local aCampo := {} As Array // Only for RUS
    Local aTemp        As Array // Only for RUS
    Local nI           As Numeric // Only for RUS   
    If cPaisLoc $ "RUS"
        aTemp := AClone(&(cAlias)->(dbstruct()))
        For nI := 1 To Len(aTemp)
            If aTemp[nI][1] $ "P6_MEURH|P6_ANEXMRH"
                Loop
            EndIf
            Aadd(aCampo, aTemp[nI][1])
        Next nI
    EndIf
Return aCampo
