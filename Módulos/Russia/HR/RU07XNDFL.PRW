#INCLUDE "PROTHEUS.CH"

#DEFINE ADULT_AGE 18
#DEFINE STUDENT_AGE 24

#DEFINE NON_RESIDENT_TAX_RATE SuperGetMv("MV_NRNDFL")

#DEFINE SOCIAL_TAX_DEDUCTION_CODE "1"   // F5C_TYPE
#DEFINE ESTATE_TAX_DEDUCTION_CODE "3"

#DEFINE ACTIVE_TAX_DEDUCTION "1"        // F5C_LOCK, F5C_STATUS
#DEFINE INACTIVE_TAX_DEDUCTION "2"
#Define IS_CANCEL_PAYMENT "1" // F5D_CANCEL = "Yes".
#Define NO_CANCEL_PAYMENT "2" // F5D_CANCEL = "No.

#DEFINE WAGE_TYPE_PAYMENT "1"           // RV_TIPOCOD
#DEFINE DISCOUNT_TYPE_PAYMENT "2"       // RV_TIPOCOD
#DEFINE TAXABLE_PAYMENT "S"             // RV_IR
#DEFINE IS_VACATION_CALCULATE "S"      // RV_REFFER = "Yes".
#DEFINE IS_NDFL_VACATION_CALCULATE "1" // RV_INSSFER = "Yes".
#DEFINE NOT_TAXABLE_PAYMENT "N"        // RV_IR = "No"

#DEFINE COD_PAYMENT_INDEX 1 // For example, aPd[nI][1] = "675".
#DEFINE HOURS_PAYMENT_INDEX 4 // For example, aPd[nI][4] = 1.
#DEFINE SUM_PAYMENT_INDEX 5 // For example, aPd[nI][5] = 234.56.
#DEFINE DTREF_PAYMENT_INDEX 10 // For example, aPd[nI][10] = 31.08.2023.
#DEFINE DATE_PAYMENT_INDEX 18 // For example, aPd[nI][18] = 31.08.2023.
#DEFINE CONVOC_PAYMENT_INDEX 22 // For example, aPd[nI][22] = "126".
#DEFINE APDV_TAXABLE_PAYMENT_INDEX 5 // For example, aPdv[nSRVIndex][5].
#DEFINE RETRO_PERIOD_INDEX 26 // RC_DTREFCA

#DEFINE ADVANCE_SCENARIO_NAME "ADI"
#DEFINE SALARY_SCENARIO_NAME "FOL"
#DEFINE VACATION_SCENARIO_NAME "FER"
#DEFINE TERMINATION_SCENARIO_NAME "RES"

#DEFINE SCENARIO_STATUS_CLOSED "5" // RCH_STATUS = "Closed".

/*/{Protheus.doc} RU07NDFL01_CalculateNDFL()
    Calculates NDFL taking into account residence status, tax deductions and progressive tax rate

    @type Function
    @params
    @return
    @author dtereshenko
    @since 2020/11/16
    @version 12.1.23
*/
Function RU07NDFL01_CalculateNDFL()
    Local aNDFL As Array
    Local aTaxDeductions As Array
    Local aOutputTDs := {} As Array
    Local lGetDependants As Logical
    Local nI As Numeric
    Local nNDFLBase As Numeric
    Local nTDPayment As Numeric
    Local nYearPayments As Numeric
    Local oTaxDeduction As Object
    Local nLimitSocialTD := aTabIr[5,3]          // aTabIr[5,3] - base limit for social tax deductions (S002 table)
    Local cTaxDeduction := aCodFol[59,1] As Char // aCodFol[59,1] - SRV #675 - Tax Deduction
    Local cVacTaxDeduction := aCodFol[60,1] As Char // aCodFol[60,1] - SRV #676 - Vacation Tax Deduction.
    Local cNDFLBase := aCodFol[15,1] As Char     // aCodFol[15,1] - SRV #605 - NDFL Base
    Local cNDFL := aCodFol[66,1] As Char         // aCodFol[66,1] - SRV #413 - NDFL
    Local cVacNDFLBase := aCodFol[16,1] As Character // aCodFol[16,1] - SRV #606 - Vacation NDFL Base.
    Local cVacNDFL := aCodFol[67,1] As Character // aCodFol[67,1] - SRV #414 - Vacation NDFL.

    nNDFLBase := CalcNDFLBase() // Sum of all taxable payments in current period
    nYearPayments := CalcYearPayments() // Sum of all taxable payments in current year

    lGetDependants := (nYearPayments + nNDFLBase <= nLimitSocialTD)

    // Remove F5C and F5D records created in current calculation period.
    ClearTaxDeductions()

    aTaxDeductions := CollectTaxDeductions(lGetDependants)

    For nI := 1 To Len(aTaxDeductions)
        oTaxDeduction := aTaxDeductions[nI]

        oTaxDeduction:cPaymentNumber := StrZero(Val(oTaxDeduction:cPaymentNumber) + 1, 2)

        If nNDFLBase > 0
            If nNDFLBase - oTaxDeduction:nSumToPay >= 0
                nTDPayment := oTaxDeduction:nSumToPay
            Else
                nTDPayment := nNDFLBase
            EndIf

            oTaxDeduction:nSumToPay -= nTDPayment
            oTaxDeduction:nPaidSum += nTDPayment
            oTaxDeduction:nSumPayment := nTDPayment

            If cRot <> VACATION_SCENARIO_NAME
                CreatePayment(cTaxDeduction, nTDPayment, Val(cNumPag), oTaxDeduction:cDeductionCode)
            Else
                CreatePayment(cVacTaxDeduction, nTDPayment, Val(cNumPag), oTaxDeduction:cDeductionCode)
            EndIf
            nNDFLBase -= nTDPayment
        EndIf

        // By RULOC-5443. Save anyone tax deductions into F5D and F5C
        // wich paid sum in current period > 0.
        If oTaxDeduction:nSumPayment > 0
            AAdd(aOutputTDs, oTaxDeduction)
        EndIf
    Next nI

    If !(cRot $ VACATION_SCENARIO_NAME)
        CreatePayment(cNDFLBase, nNDFLBase)
    ElseIf (cRot $ VACATION_SCENARIO_NAME)
        FMatriz(cVacNDFLBase, nNDFLBase,      , , , , , , , ,.F.)
    EndIf

    aNDFL := CalcNDFL(nYearPayments, nNDFLBase)

    For nI := 1 To Len(aNDFL)
        If !(cRot $ VACATION_SCENARIO_NAME)
            CreatePayment(cNDFL, aNDFL[nI][1], aNDFL[nI][2], AllTrim(Str(aNDFL[nI][2])))
        ElseIf (cRot $ VACATION_SCENARIO_NAME)
            FMatriz(cVacNDFL, aNDFL[nI][1], aNDFL[nI][2], , , , , , , ,.F.)
        EndIf
    Next nI

    SetTDDetails(aOutputTDs)

Return

/*/{Protheus.doc} CalcNDFLBase()
    Calculates NDFL base: sum of all taxable payments within current period (SRV #605)

    @type Function
    @params
    @return nNDFLBase, Numeric, Sum of all taxable payments 
    @author dtereshenko
    @since 2020/11/16
    @version 12.1.23
*/
Static Function CalcNDFLBase()
    Local cSRVCode AS Char
    Local nI As Numeric
    Local nNDFLBase := 0 As Numeric
    Local nSRVIndex AS Numeric
    // Local cTaxDeduction := aCodFol[59,1] As Char // aCodFol[59,1] - SRV #675 - Tax Deduction

    If !(cRot $ VACATION_SCENARIO_NAME)
        For nI := 1 To Len(aPd) // aPd - mnemonic array with all payments within current period
            cSRVCode := aPd[nI][1]
            If FIncide(cSRVCode) // FIncide(cSRVCode) - find or add SRV item to aPdv array. "False" means invalid code
                nSRVIndex := AScan(aPdv, { |x| x[1] = cSRVCode }) // aPdv - mnemonic array with wage types (SRV items)
                If nSRVIndex > 0 .And. aPdv[nSRVIndex][APDV_TAXABLE_PAYMENT_INDEX] == TAXABLE_PAYMENT
                    If aPdv[nSRVIndex][27] == WAGE_TYPE_PAYMENT
                        nNDFLBase += aPd[nI][SUM_PAYMENT_INDEX]
                    EndIf

                    If aPdv[nSRVIndex][27] == DISCOUNT_TYPE_PAYMENT
                        nNDFLBase -= aPd[nI][SUM_PAYMENT_INDEX]
                    EndIf
                EndIf
            EndIf
        Next nI

        // Search ADI payment of tax deductions in current period.
        // aCodFol[59,1] - SRV #675 - Tax Deduction
        // nNDFLBase += RU07NDFL05_GetPaymentValue(SRA->RA_MAT, cTaxDeduction, ADVANCE_SCENARIO_NAME, cPeriodo)

    Else
        // Calculation NDFL base for vacations.
        For nI := 1 To Len(aPd)
            If RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == IS_VACATION_CALCULATE ;
                .And. RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_INSSFER") == IS_NDFL_VACATION_CALCULATE ;
                .And. RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_IR") == NOT_TAXABLE_PAYMENT 

                If RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT
                    nNDFLBase += aPd[nI][SUM_PAYMENT_INDEX]
                EndIf

                If RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == DISCOUNT_TYPE_PAYMENT
                    nNDFLBase -= aPd[nI][SUM_PAYMENT_INDEX]
                EndIf
            EndIf
        Next nI
    End

Return nNDFLBase

/*/{Protheus.doc} CalcNDFL(nNDFLBase As Numeric)
    Calculates NDFL: NDFL base * tax rate (SRV #413)

    @type Function
    @params nNDFLBase,        Numeric,    Current NDFL base - sum of taxable payments within a period
            nYearPayments,    Numeric,    Sum of taxable payments within a year
    @return aNDFL,            Array,      Array with tax rates and values of NDFL
    @author dtereshenko
    @since 2020/11/16
    @version 12.1.23
*/
Static Function CalcNDFL(nYearPayments As Numeric, nNDFLBase As Numeric)
    Local aCurTaxRate As Array
    Local aNDFL := {} As Array
    Local aNextTaxRate As Array
    Local aTaxRates := {} As Array
    Local nI As Numeric
    Local nNDFLBase1 As Numeric
    Local nNDFLBase2 As Numeric

    // Non-resident case
    If !RU07CHKRS(SRA->RA_MAT)
        AAdd(aNDFL, {nNDFLBase * NON_RESIDENT_TAX_RATE / 100, NON_RESIDENT_TAX_RATE})
        Return aNDFL
    EndIf

    // Zero NDFL base due to tax deductions
    If nNDFLBase == 0
        Return aNDFL
    EndIf

    // Obtaining S002 data
    For nI := 2 To Len(aTabIr) // aTabIr - mnemonic array with S002 data
        If nI != 5 // aTabIr[5] - defualt Brazilean tax deductions data
            AAdd(aTaxRates, {aTabIr[nI,1], aTabIr[nI,2]}) // {Base Limit, Tax Rate}
        EndIf
    Next nI


    For nI := 1 To Len(aTaxRates) - 1
        aCurTaxRate := aTaxRates[nI]
        aNextTaxRate := aTaxRates[nI + 1]

        // Year payments and NDFL Base less then or equal to current threshold value (e.g. 5.000.000)
        // Whole payment is taxed at the current rate (e.g. 13%)
        If nYearPayments + nNDFLBase <= aCurTaxRate[1] .And. nI == 1
            AAdd(aNDFL, {nNDFLBase * aCurTaxRate[2] / 100, aCurTaxRate[2]})
            Exit
        EndIf

        // Year payments and NDFL Base between current and next threshold value (e.g. 5.000.000 - ...)
        If nYearPayments + nNDFLBase > aCurTaxRate[1] .And. nYearPayments + nNDFLBase <= aNextTaxRate[1]

            // Year payments more than or equal to current threshold value (e.g. 5.000.000)
            // Whole payment is taxed at the next rate (e.g. 15%)
            If nYearPayments >= aCurTaxRate[1]
                AAdd(aNDFL, {nNDFLBase * aNextTaxRate[2] / 100, aNextTaxRate[2]})

            // Part of the payment is less than the threshold value, the other part is more.
            Else
                nNDFLBase1 := aCurTaxRate[1] - nYearPayments
                nNDFLBase2 := nNDFLBase - nNDFLBase1

                AAdd(aNDFL, {nNDFLBase1 * aCurTaxRate[2] / 100, aCurTaxRate[2]})
                AAdd(aNDFL, {nNDFLBase2 * aNextTaxRate[2] / 100, aNextTaxRate[2]})
            EndIf
        EndIf
    Next nI

Return aNDFL

/*/{Protheus.doc} CollectTaxDeductions()
    Calculates and collect to output array various NDFL tax deductions (SRV #675)

    @type Function
    @params lGetDependants,   Logical,   Parameter indicating whether to count dependents tax deductions
    @return aTaxDeductions,    Array,     Current tax deductions types & values
    @author dtereshenko
    @since 2020/11/16
    @version 12.1.23
*/
Static Function CollectTaxDeductions(lGetDependants As Logical)
    Local aTaxDeductions := {} As Array

    // Collect only social tax deductions on current period.
    If lGetDependants
        GetDepsTD(@aTaxDeductions)
    EndIf
    
    // Load pyaments of open social and estate tax deductions from previous periods.
    LoadHistory(@aTaxDeductions)

    // Load only estate tax deductions in current period.
    GetEstateTD(@aTaxDeductions)

Return aTaxDeductions

/*/{Protheus.doc} GetDepsTD(aTaxDeductions As Array)
    Collect to output array all dependats-related NDFL tax deductions

    @type Function
    @params aTaxDeductions,    Array,    Output array for current tax deductions codes & values
    @return aPaidTaxDeductions, Array, Already paid tax deductions.
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function GetDepsTD(aTaxDeductions As Array)
    Local aDependants := GetDependants() As Array
    Local aS210_TaxDeductionsTypes := {} As Array
    Local nI As Numeric
    Local nTaxDedIndex As Numeric
    Local oTaxDeduction As Object
    Local cQuery := "" As Character
    Local oStatement As Object
    Local aPaidTaxDeductions := {} As Array

    fCarrTab(@aS210_TaxDeductionsTypes, "S210", SToD(cPeriodo + "01"), .T.) // fCarrTab - standart function, loads given S-table to array

    For nI := 1 To Len(aDependants)
        nTaxDedIndex := AScan(aS210_TaxDeductionsTypes, { |x| x[7] == aDependants[nI] })

        If nTaxDedIndex > 0
            oTaxDeduction := RUTaxDeduction():New()

            oTaxDeduction:cFil := FWxFilial("F5D")
            oTaxDeduction:cMat := SRA->RA_MAT
            oTaxDeduction:cType := SOCIAL_TAX_DEDUCTION_CODE
            oTaxDeduction:cF5CId := "" //Iif(cRot <> VACATION_SCENARIO_NAME, "", DToS(M->RH_DATAINI) + aS210_TaxDeductionsTypes[nTaxDedIndex][7])
            oTaxDeduction:cDeductionCode := aS210_TaxDeductionsTypes[nTaxDedIndex][7]
            oTaxDeduction:cPaymentNumber := "0"
            oTaxDeduction:nPaidSum := 0
            oTaxDeduction:nSumToPay := aS210_TaxDeductionsTypes[nTaxDedIndex][9]
            oTaxDeduction:nSumPayment := 0
            oTaxDeduction:lCancelPayment := NO_CANCEL_PAYMENT

            oTaxDeduction:lFromSRB := .T.

            // Check F5C.
            cQuery := " SELECT LEFT(F5C_DTENTR, 6), F5C_COD FROM " + RetSQLName("F5C") + " WHERE "
            cQuery += "     F5C_FILIAL = ? "
            cQuery += "     AND F5C_MAT = ? "
            cQuery += "     AND F5C_TYPE = '1' "
            cQuery += "     AND F5C_LOCK = '1' "
            cQuery += "     AND F5C_STATUS = '1' "
            cQuery += "     AND LEFT(F5C_DTENTR, 6) = ? "
            cQuery += "     AND F5C_DEDCOD = ? "
            cQuery += "     AND D_E_L_E_T_ = ' ' "

            oStatement := FWPreparedStatement():New()
            oStatement:SetQuery(cQuery)
            oStatement:SetString(1, FWxFilial("F5C"))
            oStatement:SetString(2, SRA->RA_MAT)
            oStatement:SetString(3, cPeriodo)
            oStatement:SetString(4, aDependants[nI])

            cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

            DbSelectArea(cAlias)
            (cAlias)->(DbGoTop())
            While !(cAlias)->(Eof())
                oTaxDeduction:cF5CId := AllTrim((cAlias)->(F5C_COD))

                (cAlias)->(DBSkip())
            EndDo
            (cAlias)->(DbCloseArea())

            If Empty(oTaxDeduction:cF5CId)
                oTaxDeduction:cF5CId := SubStr(FWUUID("F5C"), 1, GetSX3Cache("F5C_COD", "X3_TAMANHO"))
            EndIf

            // Check F5D that this tax deduction already paid and load this information.
            cQuery := " SELECT F5D_COD, F5D_DEDCOD, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_CANCEL FROM " + RetSQLName("F5D") + " WHERE "
            cQuery += "     F5D_FILIAL = ? "
            cQuery += "     AND F5D_MAT = ? "
            cQuery += "     AND F5D_DEDCOD = ? "
            cQuery += "     AND F5D_PROCES = ? "
            cQuery += "     AND F5D_PER = ? "
            cQuery += "     AND F5D_COD = ? "
            cQuery += "     AND D_E_L_E_T_ = ' ' "

            oStatement := FWPreparedStatement():New()
            oStatement:SetQuery(cQuery)
            oStatement:SetString(1, FWxFilial("F5D"))
            oStatement:SetString(2, SRA->RA_MAT)
            oStatement:SetString(3, oTaxDeduction:cDeductionCode)
            oStatement:SetString(4, SRA->RA_PROCES)
            oStatement:SetString(5, cPeriodo)
            oStatement:SetString(6, oTaxDeduction:cF5CId)

            cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

            DbSelectArea(cAlias)
            (cAlias)->(DbGoTop())
            While !((cAlias)->(Eof()))
                oTaxDeduction:cPaymentNumber := (cAlias)->(F5D_NUMPAG)

                If (cAlias)->(F5D_CANCEL) == NO_CANCEL_PAYMENT
                    oTaxDeduction:nPaidSum += (cAlias)->(F5D_SUMPAY)
                    oTaxDeduction:nSumToPay -= (cAlias)->(F5D_SUMPAY)
                EndIf

                (cAlias)->(DBSkip())
            EndDo
            (cAlias)->(DbCloseArea())

            // If the deduction is not fully repaid, then add to the array "aTaxDeductions".
            If oTaxDeduction:nPaidSum > 0 .And. Empty(oTaxDeduction:nSumToPay)
                aAdd(aPaidTaxDeductions, oTaxDeduction)
            Else
                aAdd(aTaxDeductions, oTaxDeduction)
            EndIf

            // Destroy FWPreparedStatement object.
            oStatement:Destroy()
            FwFreeObj(oStatement)
        EndIf

    Next nI

Return aPaidTaxDeductions

/*/{Protheus.doc} GetDependants()
    Retrieves all employee's dependants affecting the calculation

    @type Function
    @params
    @return aDependants,    Array,    Employee's dependants-related tax deductions codes
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function GetDependants()
    Local aDependants := {} As Array
    Local aSavedArea := GetArea() As Array
    Local cDepsTable As Char
    Local cQuery As Char
    Local cTaxDeductionStart as Char
    Local nDepAge As Numeric
    Local oStatement As Object
    Local cEndTaxDeduction := "" As Character

    cQuery := "SELECT RB_TIPIR, RB_DTNASC, RB_DTENTRA, RB_NUMLIVR, RB_DTCLDED FROM " + RetSQLName("SRB") + " WHERE RB_FILIAL = ? AND RB_MAT = ? AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRB"))
    oStatement:SetString(2, SRA->RA_MAT)

    cDepsTable := MPSysOpenQuery(oStatement:GetFixQuery(), GetNextAlias())

    DBSelectArea(cDepsTable)
    (cDepsTable)->(DbGoTop())

    While !(EoF())
        cTaxDeductionStart := SubStr((cDepsTable)->RB_DTENTRA, 1, 6) // (YYYYMM)
        If .Not. Empty((cDepsTable)->RB_DTCLDED)
            cEndTaxDeduction := SubStr((cDepsTable)->RB_DTCLDED, 1, 6) // (YYYYMM)
        EndIf

        If !Empty(cTaxDeductionStart) .And. CPERIODO >= cTaxDeductionStart  .And. .Not. Empty((cDepsTable)->RB_NUMLIVR) .And. (Empty(cEndTaxDeduction) .Or. CPERIODO <= cEndTaxDeduction) // CPERIODO - mnemonic with current calculation period (YYYYMM)
            nDepAge := GetAge(SToD((cDepsTable)->RB_DTNASC), DDATA_PGTO) // DDATA_PGTO - mnemonic with date of the calculation

            If (cDepsTable)->RB_TIPIR == "1" .Or. ;
               ((cDepsTable)->RB_TIPIR == "2" .And. nDepAge < ADULT_AGE) .Or. ;
               ((cDepsTable)->RB_TIPIR == "3" .And. nDepAge < STUDENT_AGE)
                AAdd(aDependants, AllTrim((cDepsTable)->RB_NUMLIVR))
            EndIf
        EndIf

        DBSkip()
    EndDo

    DBCloseArea()

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aSavedArea)

Return aDependants

/*/{Protheus.doc} GetAge(dBirthdayDate As Date, dCurrentDate As Date)
    Returns person's age (based on year and month)

    @type Function
    @params dBirthdayDate,    Date,       Birthday date
            dCurrentDate,     Date,       Date for age calculation
    @return nAge,             Numeric,    Person's age
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function GetAge(dBirthdayDate As Date, dCurrentDate As Date)
    Local nAge As Numeric

    nAge := Year(dCurrentDate) - Year(dBirthdayDate)

    If Month(dBirthdayDate) >= Month(dCurrentDate)
        nAge--
    EndIf

Return nAge

/*/{Protheus.doc} Get2NDFLEarnings()
    Returns employee's past earnings according to 2-NDFL reference
    Temporary stub now (returns 0.0)

    @type Function
    @params
    @return nCurrentYearEarnings,    Numeric,    Past employee's earnings for current year
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function Get2NDFLEarnings()
Return 0

/*/{Protheus.doc} GetTaxableBudgets()
    Returns SRV codes (budgets) for taxable payments

    @type Function
    @params
    @return aSRVCodes,    Array,    SRV codes (RV_COD) for taxable payments
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function GetTaxableBudgets()
    Local aSRVCodes := {} As Array
    Local aSavedArea := GetArea() As Array
    Local cQuery As Char
    Local cSRVCodesTable As Char
    Local oStatement As Object

    cQuery := "SELECT RV_COD FROM " + RetSQLName("SRV") + " WHERE RV_FILIAL = ? AND RV_TIPOCOD = ? AND RV_IR = ? AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRV"))
    oStatement:SetString(2, WAGE_TYPE_PAYMENT)
    oStatement:SetString(3, TAXABLE_PAYMENT)

    cSRVCodesTable := MPSysOpenQuery(oStatement:GetFixQuery(), GetNextAlias())

    DBSelectArea(cSRVCodesTable)
    (cSRVCodesTable)->(DbGoTop())

    While !EoF()
        AAdd(aSRVCodes, (cSRVCodesTable)->RV_COD)
        DBSkip()
    EndDo

    DBCloseArea()

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aSavedArea)

Return aSRVCodes

/*/{Protheus.doc} CalcYearPayments()
    Returns sum of taxable payments for current year

    @type Function
    @params
    @return nYearPaymentsSum,   Numeric,   Sum of taxable payments for current year
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function CalcYearPayments()
    Local aSRVCodes := GetTaxableBudgets() As Array
    Local nYearPaymentsSum := 0 As Numeric

    If SRA->RA_ADMISSA >= SToD(SubStr(cPeriodo, 1, 4) + "0101")
        nYearPaymentsSum += Get2NDFLEarnings()
    EndIf

    // SRD Payments
    nYearPaymentsSum += GetPaymentsSum("SRD", aSRVCodes, SToD(SubStr(cPeriodo, 1, 4) + "0101"), SToD(cPeriodo + "01") - 1)

    // // SRC Payments - don't needed right now, but it may be useful in the future
    // nYearPaymentsSum += GetPaymentsSum("SRC", aSRVCodes, SToD(cPeriodo + "01"), DDATA_PGTO + 1)

Return nYearPaymentsSum

/*/{Protheus.doc} GetPaymentsSum(cPaymentsTable As Char, aSRVCodes As Array, dDateStart As Date, dDateEnd As Date)
    Returns sum of payments from transfered table for specific budgets within period between two transfered dates

    @type Function
    @params cPaymentsTable,     Char,      Payments table (SRC or SRD)
            aSRVCodes,          Array,     Array with codes of budgets (SRV items) for summation
            dDateStart,         Date,      Start of summation period
            dDateStart,         Date,      End of summation period
    @return nPaymentsSum,       Numeric,   Sum of payments
    @author dtereshenko
    @since 2020/11/17
    @version 12.1.23
*/
Static Function GetPaymentsSum(cPaymentsTable As Char, aSRVCodes As Array, dDateStart As Date, dDateEnd As Date)
    Local aSavedArea := GetArea() As Array
    Local cQuery As Char
    Local cQueryResult As Char
    Local nPaymentsSum := 0
    Local aValues := {}

    If cPaymentsTable == "SRC"
        cQuery := "SELECT SUM(RC_VALOR) AS PAYMENTS_SUM FROM " + RetSQLName("SRC") + " WHERE RC_FILIAL = ? AND RC_MAT = ? "
        AAdd(aValues, FWxFilial(cPaymentsTable))
        AAdd(aValues, SRA->RA_MAT)

        cQuery += "AND RC_PD IN (" + RusSetQryIn(aSRVCodes, @aValues) + ") AND RC_DTREF BETWEEN ? AND ? AND D_E_L_E_T_ = ' '"
        AAdd(aValues, DToS(dDateStart))
        AAdd(aValues, DToS(dDateEnd))
    ElseIf cPaymentsTable == "SRD"
        cQuery := "SELECT SUM(RD_VALOR) AS PAYMENTS_SUM FROM " + RetSQLName("SRD") + " WHERE RD_FILIAL = ? AND RD_MAT = ? "
        AAdd(aValues, FWxFilial(cPaymentsTable))
        AAdd(aValues, SRA->RA_MAT)

        cQuery += "AND RD_PD IN (" + RusSetQryIn(aSRVCodes, @aValues) + ") "
        cQuery += " AND RD_ROTEIR = '" + SALARY_SCENARIO_NAME + "' "
        cQuery += " AND RD_DTREF BETWEEN ? AND ? AND D_E_L_E_T_ = ' ' "
        AAdd(aValues, DToS(dDateStart))
        AAdd(aValues, DToS(dDateEnd))
    Else
        Return nPaymentsSum
    EndIf

    cQueryResult := GetNextAlias()
    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cQueryResult, .T., .F.)
    DBSelectArea(cQueryResult)
    (cQueryResult)->(DbGoTop())

    nPaymentsSum := (cQueryResult)->PAYMENTS_SUM

    DBCloseArea()
    RestArea(aSavedArea)

Return nPaymentsSum

/*/{Protheus.doc} GetTDDetails(lGetSocialTDs As Logical, aTaxDeductions As Array)
    Collect to output array all active NDFL tax deductions

    @type Function
    @params lGetSocialTDs,     Logical,   Is social tax deductions have to be collected
            aTaxDeductions,    Array,     Output array for current tax deductions
    @return
    @author dtereshenko
    @since 2021/03/24
    @version 12.1.23
*/
Static Function GetTDDetails(lGetSocialTDs As Logical, aTaxDeductions As Array)
    Local aSavedArea := GetArea() As Array
    Local cCurrentTDCod As Char
    Local cQuery As Char
    Local cQueryFields As Char
    Local cTDDetails As Char
    Local aValues := {}

    cQueryFields := "F5C_FILIAL, F5C_MAT, F5C_COD, F5C_TYPE, F5C_DEDCOD, F5C_INCOME, F5D_FILIAL, F5D_MAT, F5D_COD, F5D_DEDCOD, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_CANCEL"

    cQuery := "SELECT " + cQueryFields + " FROM " + RetSQLName("F5C") + " F5C LEFT JOIN " + RetSQLName("F5D") + " F5D " + ;
              "ON F5C_FILIAL = F5D_FILIAL AND F5C_MAT = F5D_MAT AND F5C_COD = F5D_COD WHERE "
    cQuery += "F5C_FILIAL = ? AND "
    cQuery += "F5C_MAT = ? AND "
    cQuery += "F5C_LOCK = ? AND "
    cQuery += "F5C_STATUS = ? AND "
    cQuery += "F5C_DTENTR < ? AND "
    cQuery += "(F5D_INCRES > 0 OR F5D_INCRES IS NULL) AND "

    If !(lGetSocialTDs)
        cQuery += "F5C_TYPE != ? AND "
    EndIf

    cQuery += "F5C.D_E_L_E_T_ = ' ' AND (F5D.D_E_L_E_T_ = ' ' OR F5D.D_E_L_E_T_ IS NULL) ORDER BY F5C_COD, F5D_COD, F5D_NUMPAG DESC"

    AAdd(aValues, FWxFilial("F5D"))
    AAdd(aValues, SRA->RA_MAT)
    AAdd(aValues, ACTIVE_TAX_DEDUCTION)
    AAdd(aValues, ACTIVE_TAX_DEDUCTION)
    AAdd(aValues, DToS(DDATA_PGTO)) // Default mnemonic - date of the calculation

    If !(lGetSocialTDs)
        AAdd(aValues,SOCIAL_TAX_DEDUCTION_CODE)
    EndIf

    cTDDetails := GetNextAlias()
    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cTDDetails, .T., .F.)

    DBSelectArea(cTDDetails)
    (cTDDetails)->(DbGoTop())

    If !EoF()
        AAdd(aTaxDeductions, RUTaxDeduction():New(cTDDetails))
        cCurrentTDCod := (cTDDetails)->F5C_COD
    EndIf

    While !EoF()
        If (cTDDetails)->F5C_COD != cCurrentTDCod
            AAdd(aTaxDeductions, RUTaxDeduction():New(cTDDetails))
            cCurrentTDCod := (cTDDetails)->F5C_COD
        EndIf
        DBSkip()
    EndDo

    DBCloseArea()
    RestArea(aSavedArea)

Return

/*/{Protheus.doc} SetTDDetails(aTaxDeductions As Array)
    Inserts new tax deductions detalisation into F5D table

    @type Function
    @params aTaxDeductions,    Array,     Array for tax deduction objects to be 
    @return
    @author dtereshenko
    @since 2021/03/19
    @version 12.1.23
*/
Static Function SetTDDetails(aTaxDeductions As Array)
    Local nI As Numeric
    Local oTaxDeduction As Object
    Local aSavedArea := GetArea() As Array

    DbSelectArea("F5D")

    Begin Transaction

        For nI := 1 To Len(aTaxDeductions)
            oTaxDeduction := aTaxDeductions[nI]

            If oTaxDeduction:lFromSRB
                CreateTDHeader(oTaxDeduction)
            EndIf

            If RecLock("F5D", .T.)
	            F5D->F5D_FILIAL := FWxFilial("F5D")
	            F5D->F5D_MAT := SRA->RA_MAT
	            F5D->F5D_COD := oTaxDeduction:cF5CId
	            F5D->F5D_DEDCODE := oTaxDeduction:cDeductionCode
	            F5D->F5D_PROCES := CPROCESSO // Default mnemonic, e.g. "00001"
	            F5D->F5D_ROTEIR := CROT // Default mnemonic, e.g. "FOL"
	            F5D->F5D_PER := CPERIODO // Default mnemonic, e.g. "202012"
	            F5D->F5D_NUMPAG := oTaxDeduction:cPaymentNumber
	            F5D->F5D_INCPER := oTaxDeduction:nPaidSum
	            F5D->F5D_INCRES := oTaxDeduction:nSumToPay
	            F5D->F5D_SUMPAY := oTaxDeduction:nSumPayment
	            F5D->F5D_CANCEL := oTaxDeduction:lCancelPayment

	            If cRot == VACATION_SCENARIO_NAME
	                F5D->F5D_DTVCPM := M->RH_DATAINI //DToS(M->RH_DATAINI)
	            EndIf

                /*
                 *  For recalculations for closed periods!
                 * When you start recalculations for closed periods, 
                 * the pergunta parameters for recalculations are available here. 
                 * MV_PAR03 is the current open period.
                 *
                 * lDissidio - this is a mnemonic indicating that recalculation is in progress.
                */
                If ValType(lDissidio) == "L"
                    If lDissidio .And. !Empty(MV_PAR03) .And. MV_PAR03 != cPeriodo
                        F5D->F5D_DTVCPM := SToD(MV_PAR03 + "01")
                    EndIf
                Else
                    ConOut("When recording a tax deduction lDissidio mnemonics do not exist. Check the mnemonics table (RCA)")
                EndIf

            	F5D->(MsUnlock())
            EndIf
        Next nI

    End Transaction

    RestArea(aSavedArea)

Return

/*/{Protheus.doc} CreateTDHeader(oTaxDeduction As Object)
    Inserts new tax deduction header into F5C table

    @type Function
    @params oTaxDeduction,    Object,     RUTaxDeduction object - F5D record
    @return
    @author dtereshenko
    @since 2021/03/25
    @version 12.1.23
*/
Static Function CreateTDHeader(oTaxDeduction As Object)
    Local aSavedArea := GetArea() As Array
    Local aF5CArea := F5C->(GetArea()) As Array
    Local aS210_TaxDeductionsTypes := {} As Array
    Local nTaxDedIndex As Numeric

    fCarrTab(@aS210_TaxDeductionsTypes, "S210", SToD(cPeriodo + "01"), .T.) // fCarrTab - standart function, loads given S-table to array
    nTaxDedIndex := AScan(aS210_TaxDeductionsTypes, { |x| x[7] == oTaxDeduction:cDeductionCode })

    DbSelectArea("F5C")
    F5C->(DBSetOrder(1)) // "F5C_FILIAL+F5C_MAT+F5C_COD".

    If !(F5C->(DBSeek(FWxFilial("F5C") + SRA->RA_MAT + oTaxDeduction:cF5CId)))
        If nTaxDedIndex > 0
            oTaxDeduction:cF5CId := SubStr(FWUUID("F5C"), 1, GetSX3Cache("F5C_COD", "X3_TAMANHO"))
        EndIf

        If RecLock("F5C", .T.)
            ConfirmSx8() // Confirm new number for the record, returned by GetSx8Num

            F5C->F5C_FILIAL := FWxFilial("F5D")
            F5C->F5C_MAT := SRA->RA_MAT
            F5C->F5C_TYPE := oTaxDeduction:cType
            F5C->F5C_COD := oTaxDeduction:cF5CId
            F5C->F5C_DTENTRA := DDATA_PGTO // Default mnemonic - date of the calculation
            F5C->F5C_LOCK := ACTIVE_TAX_DEDUCTION
            F5C->F5C_STATUS := ACTIVE_TAX_DEDUCTION
            F5C->F5C_DEDCODE := oTaxDeduction:cDeductionCode
            F5C->F5C_INCOME := oTaxDeduction:nSumToPay + oTaxDeduction:nPaidSum

            F5C->(MsUnlock())
        Else
            RollbackSx8()
        EndIf
    EndIf

    F5C->(RestArea(aF5CArea))
    RestArea(aSavedArea)

Return

/*/{Protheus.doc} CreatePayment(cBudget As Char, nSum As Numeric, nAdditionalNumber As Numeric, cConvoc As Char)
    Wrapper for FMatriz function with less params. Creates a payment during the calculation.

    @type Function
    @params cBudget               Char,       Budget (type of the payment) - RC_PD
            nSum,                 Numeric,    Sum of the payment - RC_VALOR
            nAdditionalNumber,    Numeric,    Additional number - RC_HORAS
            cConvoc,              Char,       RC_CONVOC
    @return
    @author dtereshenko
    @since 2021/03/19
    @version 12.1.23
*/
Static Function CreatePayment(cBudget As Char, nSum As Numeric, nAdditionalNumber As Numeric, cConvoc As Char)
    Default nAdditionalNumber := 1 // Hours or days value for payments list.
Return FMatriz(cBudget, nSum, nAdditionalNumber,,,,,,,,,,,,,,,,,,,, cConvoc)

/*/{Protheus.doc} RU07NDFL02_CloseRepaidTD()
    Closing repaid tax deductions at the end of an accounting period

    @type Function
    @params
    @return
    @author dtereshenko
    @since 2020/11/31
    @version 12.1.23
*/
Function RU07NDFL02_CloseRepaidTD()
    Local aSavedArea := GetArea()
    Local aRepaidTDCodes := {}
    Local aValues := {}
    Local cQuery As Char
    Local cRepaidTD As Char
    Local oStatement As Object

    cQuery := "SELECT F5C_COD FROM " + RetSQLName("F5C") + " F5C INNER JOIN " + RetSQLName("F5D") + " F5D " + ;
              "ON F5C_FILIAL = F5D_FILIAL AND F5C_MAT = F5D_MAT AND F5C_COD = F5D_COD WHERE "
    cQuery += "F5C_FILIAL = ? AND "
    cQuery += "F5C_MAT = ? AND "
    cQuery += "F5C_LOCK = ? AND "
    cQuery += "F5C_STATUS = ? AND "
    cQuery += "ROUND(F5D_INCRES, 6) = 0 AND "
    cQuery += "F5C.D_E_L_E_T_ = ' ' AND F5D.D_E_L_E_T_ = ' '"

    AAdd(aValues, FWxFilial("F5C"))
    AAdd(aValues, SRA->RA_MAT)
    AAdd(aValues, ACTIVE_TAX_DEDUCTION)
    AAdd(aValues, ACTIVE_TAX_DEDUCTION)

    cRepaidTD := GetNextAlias()
    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cRepaidTD, .T., .F.)

    DBSelectArea(cRepaidTD)
    (cRepaidTD)->(DbGoTop())

    While !EoF()
        AAdd(aRepaidTDCodes, (cRepaidTD)->F5C_COD)
        DBSkip()
    EndDo

    DBCloseArea()

    cQuery := "UPDATE " + RetSQLName("F5C") + " SET F5C_LOCK = ?, F5C_STATUS = ? WHERE "
    cQuery += "F5C_FILIAL = ? AND "
    cQuery += "F5C_MAT = ? AND "
    cQuery += "F5C_COD IN (?)"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, INACTIVE_TAX_DEDUCTION)
    oStatement:SetString(2, INACTIVE_TAX_DEDUCTION)
    oStatement:SetString(3, FWxFilial("F5C"))
    oStatement:SetString(4, SRA->RA_MAT)
    oStatement:SetIn(5, aRepaidTDCodes)

    TcSqlExec(oStatement:GetFixQuery())

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aSavedArea)

Return

/*/{Protheus.doc} ClearTaxDeductions()
    Remove F5D records created in current calculation period

    @type Function
    @params
    @return
    @author dtereshenko
    @since 2021/03/31
    @version 12.1.23
*/
Static Function ClearTaxDeductions(lDelVacation)
    Local lADIIsOpen := !IsClosePeriod(ADVANCE_SCENARIO_NAME) As Logical
    Local lFOLIsOpen := !IsClosePeriod(SALARY_SCENARIO_NAME) As Logical

    Default lDelVacation := .F.

    If lDelVacation
        CancelDeductionPayment()
    Else
        If cRot == "FER" .Or. cRot == "RES"
            // If calculation FER and ADI is open.
            If lADIIsOpen .And. lFOLIsOpen
                DeleteTDDetail(ADVANCE_SCENARIO_NAME)
                CancelDeductionPayment()
            EndIf

            // If calculation FER and ADI is closed.
            If !lADIIsOpen .And. lFOLIsOpen
                DeleteTDDetail(SALARY_SCENARIO_NAME)
                DeleteTDDetail(TERMINATION_SCENARIO_NAME)

                If cRot == "FER"
                    CancelDeductionPayment()
                EndIf
            EndIf
        Else
            // If calculate ADI or FOL then remove previous payment for this (recalculation).
            DeleteTDDetail(cRot)
        EndIf
    EndIf

    // Collect empty tax deductions (F5C and F5D) and removed this form DB.
    DeleteEmptyTaxDeductions()

Return .T.

/*/{Protheus.doc} RU07NDFL03_CalculateNDFLBaseYear()
    Calculates base of NDFL for current year

    @type Function
    @params
    @return
    @author dchizhov
    @since 2022/08/11
    @version 12.1.23
*/
Function RU07NDFL03_CalculateNDFLBaseYear()

    Local aTaxDeductions As Array
    Local lGetDependants As Logical
    Local nI             As Numeric
    Local nNDFLBase      As Numeric
    Local nTDPayment     As Numeric
    Local nYearPayments  As Numeric
    Local oTaxDeduction  As Object
    Local nLimitSocialTD  := aTabIr[5, 3]     As Numeric // aTabIr[5,3] - base limit for social tax deductions (S002 table)
    Local nLimit1         := aTabIr[2, 1]     As Numeric // aTabIr[5,3] - first limit for income (S002 table - Base to 1)
    Local cNDFLBaseYear   := aCodFol[1764, 1] As Char    // aCodFol[1764,1] - SRV #991 - NDFL Base Year
    Local cNDFLBLBaseYear := aCodFol[1765, 1] As Char    // aCodFol[1765,1] - SRV #992 - NDFL Base Year Befor limit
    Local cNDFLALBaseYear := aCodFol[1766, 1] As Char    // aCodFol[1766,1] - SRV #993 - NDFL Base Year After limit
    Local aPreviousAverageCalculated As Numeric

    nNDFLBase := CalcNDFLBase() // Sum of all taxable payments in current period
    nYearPayments := CalcYearPayments() // Sum of all taxable payments in current year
    aPreviousAverageCalculated := {0, 0, 0}

    lGetDependants := (nYearPayments + nNDFLBase <= nLimitSocialTD)

    If MONTH(APERIODO[1, 3]) > 1 .Or. DAY(APERIODO[1, 3]) > 1
        aPreviousAverageCalculated := PreviouslyNDFLBaseYear()
    EndIf

    aTaxDeductions := CollectTaxDeductions(lGetDependants)
    For nI := 1 To Len(aTaxDeductions)
        oTaxDeduction := aTaxDeductions[nI]

        If nNDFLBase > 0
            If nNDFLBase - oTaxDeduction:nSumToPay >= 0
                nTDPayment := oTaxDeduction:nSumToPay
            Else
                nTDPayment := nNDFLBase
            EndIf

            nNDFLBase -= nTDPayment

        EndIf
    Next nI

    If nNDFLBase + aPreviousAverageCalculated[2] > nLimit1
        aPreviousAverageCalculated[3] += aPreviousAverageCalculated[2] + nNDFLBase - nLimit1
        aPreviousAverageCalculated[2] := nLimit1
    Else
        aPreviousAverageCalculated[2] += nNDFLBase
    EndIf

    CreatePayment(cNDFLBaseYear, nNDFLBase + aPreviousAverageCalculated[1])
    CreatePayment(cNDFLBLBaseYear, aPreviousAverageCalculated[2])
    CreatePayment(cNDFLALBaseYear, aPreviousAverageCalculated[3])

Return

/*/{Protheus.doc} RU07NDFL03_CalculateNDFLBaseYear()
    Calculates base of NDFL for all last periods in current year

    @type Function
    @params
    @return aPrevioslyAver, Array, Base of NDFL for all last periods in current year for 3 codfol (1764, 1765, 1766)
    @author dchizhov
    @since 2022/08/12
    @version 12.1.23
*/
Static Function PreviouslyNDFLBaseYear()

    Local aPrevioslyAver As Array
    Local aArea    := GetArea() As Array
    Local aAreaRCH := RCH->(GetArea()) As Array
    Local aAreaSRD := SRD->(GetArea()) As Array
    Local cPerLast As Character
    Local lSCalcul := .T. As Logical

    aPrevioslyAver := {0, 0, 0}

    DBSelectArea("RCH")
    RCH->(DbSetOrder(4))
    RCH->(DBGoTop())
    RCH->(DBSeek(xFilial("RCH")+CPROCESSO+CROT+CPERIODO))

    cPerLast := RCH->RCH_PER

    While !RCH->(BoF())
        If cPerLast != RCH->RCH_PER .And. RCH->RCH_PROCES == CPROCESSO .And. RCH->RCH_ROTEIR == CROT ;
         .And. YEAR(RCH->RCH_DTINI) == YEAR(APERIODO[1, 3])
            cPerLast := RCH->RCH_PER
            Exit
        EndIf
        If YEAR(RCH->RCH_DTINI) < YEAR(APERIODO[1, 3]) .And. MONTH(RCH->RCH_DTINI) < 6
            lSCalcul := .F.
            Exit
        EndIf
        RCH->(DBSkip(-1))
    EndDo

    If cPerLast == CPERIODO
        lSCalcul := .F.
    EndIf

    RCH->(DBCloseArea())

    If lSCalcul
        DBSelectArea("SRD")
        SRD->(DBSetOrder(5))
        If SRD->(DBSeek(xFilial("SRD")+SRA->RA_MAT+CPROCESSO+CROT+cPerLast, .F.))
            While !SRD->(EoF()) .And. SRD->RD_MAT == SRA->RA_MAT .And. SRD->RD_PROCES == CPROCESSO .And. SRD->RD_ROTEIR == CROT ;
             .And. SRD->RD_PERIODO == cPerLast 
                If SRD->RD_PD == aCodFol[1764, 1]
                    aPrevioslyAver[1] := SRD->RD_VALOR
                ElseIf SRD->RD_PD == aCodFol[1765, 1]
                    aPrevioslyAver[2] := SRD->RD_VALOR
                ElseIf SRD->RD_PD == aCodFol[1766, 1]
                    aPrevioslyAver[3] := SRD->RD_VALOR
                EndIf
                SRD->(DBSkip())
            EndDo
        EndIf

        SRD->(DBCloseArea())
    Else
        aPrevioslyAver := {0, 0, 0}
    EndIf

    RCH->(RestArea(aAreaRCH))
    SRD->(RestArea(aAreaSRD))
    RestArea(aArea)

Return aPrevioslyAver

/*/{Protheus.doc} RU07NDFL04_CalculateDeductionPaymentsForADI(nNDFLBase, nPrevNDFLBase)
    The function calculates the amount of the tax deduction when calculating the advance.

    @type Function
    @params nNDFLBase, Numeric, NDFL base (the sum is taken from the "Calc_Ir" function).
            nPrevNDFLBase, Numeric, The amount of the personal income tax base since the beginning of the year.
    @return nSumDeduction, Numeric, Payment sum of tax deduction.
    @author vselyakov
    @since 14.04.2023
    @version 12.1.33
    @example nDedDep := RU07NDFL04_CalculateDeductionPaymentsForADI(@nBaseIni)
             nDedDep := RU07NDFL04(@nBaseIni, @nPrevNDFLBase)
*/
Function RU07NDFL04_CalculateDeductionPaymentsForADI(nNDFLBase, nPrevNDFLBase)
    Local nLimitSocialTD := aTabIr[5,3] As Numeric // aTabIr[5,3] - base limit for social tax deductions (S002 table)
    Local nSumDeduction := 0            As Numeric
    Local aTaxDeduction := {}           As Array
    Local nI := 0                       As Numeric
    Local lGetDependants := .T.         As Logical
    Local nYearPayments := 0            As Numeric
    Local cTaxDeduction := aCodFol[59,1] As Char // aCodFol[59,1] - SRV #675 - Tax Deduction
    Local aOutputTDs := {} As Array
    Local oTaxDeduction As Object

    nYearPayments := CalcYearPayments() // Sum of all taxable payments in current year

    lGetDependants := (nYearPayments + nNDFLBase <= nLimitSocialTD)

    // Remove F5C and F5D records created in current calculation period
    ClearTaxDeductions()

    // Get an array of deductions with children.
    aTaxDeduction := CollectTaxDeductions(lGetDependants)

    // Sum up all the necessary amounts.
    For nI := 1 To Len(aTaxDeduction)
        oTaxDeduction := aTaxDeductions[nI]
        oTaxDeduction:cPaymentNumber := StrZero(Val(oTaxDeduction:cPaymentNumber) + 1, 2)

        If nNDFLBase > 0
            If nNDFLBase - oTaxDeduction:nSumToPay >= 0
                nTDPayment := oTaxDeduction:nSumToPay
            Else
                nTDPayment := nNDFLBase
            EndIf

            nSumDeduction += nTDPayment
            oTaxDeduction:nSumToPay -= nTDPayment
            oTaxDeduction:nPaidSum += nTDPayment
            oTaxDeduction:nSumPayment := nTDPayment

            // Save this tax deduction.
            AAdd(aOutputTDs, oTaxDeduction)

            CreatePayment(cTaxDeduction, nTDPayment, Nil, oTaxDeduction:cDeductionCode)
            nNDFLBase -= nTDPayment
        Else
            AAdd(aOutputTDs, oTaxDeduction)
        EndIf
    Next nI

    // If there are tax deductions, then the amount of the personal income tax base is reduced.
    // nNDFLBase -= nSumDeduction
    nPrevNDFLBase := nYearPayments

    SetTDDetails(aOutputTDs)
    
Return nSumDeduction


/*/{Protheus.doc} RU07NDFL05_GetPaymentValue()
    The function finds the payout value in the SRD table according to the specified parameters and returns RD_VALOR.

    @type Function
    @params cEmplNumber, Character, Employee Number.
            cPDCode, Character, Payment code (examples, "675", "aCodFol[59,1]").
            cScenario, Character, Calculation scenario (example "ADI").
            cPeriod, Character, Calculationg period code (example "202303").
            lCheckSRR, Logical, If true then will be checked only SRR table.
    @return nPayment, Numeric, The value of payments for the specified type of payment.
    @author vselyakov
    @since 17.04.2023
    @version 12.1.33
    @example nNDFLBase += RU07NDFL05_GetPaymentValue(SRA->RA_MAT, aCodFol[59,1], ADVANCE_SCENARIO_NAME, cPeriodo)
*/
Function RU07NDFL05_GetPaymentValue(cEmplNumber, cPDCode, cScenario, cPeriod, lCheckSRR)
    Local nPayment As Numeric
    Local aArea    As Array
    Local aSRDArea As Array

    Local oStatement As Object
    Local cQuery As Character
    Local cAlias As Character

    Default lCheckSRR := .F.

    nPayment := 0
    aArea := GetArea()
    aSRDArea := SRD->(GetArea())

    If !lCheckSRR
        DBSelectArea("SRD")
        DBSetOrder(3) // 3 - "RD_FILIAL+RD_MAT+RD_PERIODO+RD_DATARQ+RD_PD+RD_SEMANA+RD_SEQ+RD_CC"

        If SRD->(DBSeek(FwXFilial("SRD") + cEmplNumber + cPeriod + cPeriod + cPDCode, .T.))
            nPayment := SRD->RD_VALOR
        EndIf
    Else
        cQuery := " SELECT RR_PD, RR_VALOR FROM " + RetSQLName("SRR") + " WHERE "
        cQuery += "     RR_FILIAL = ? "
        cQuery += "     AND RR_MAT = ? "
        cQuery += "     AND RR_PD IN (?) "
        cQuery += "     AND RR_PERIODO IN (?) "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New()
        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, FWxFilial("SRR"))
        oStatement:SetString(2, cEmplNumber)
        oStatement:SetIn(3, {cPDCode})
        oStatement:SetIn(4, {cPeriod})

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())
        While !((cAlias)->(Eof()))
            nPayment += (cAlias)->RR_VALOR
            (cAlias)->(DBSkip())
        EndDo
        (cAlias)->(DbCloseArea())

        // Destroy FWPreparedStatement object.
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    SRD->(RestArea(aSRDArea))
    RestArea(aArea)

Return nPayment

/*/{Protheus.doc} RU07NDFL06_ClearTaxDeduction()
    The function is designed to delete the saved amount of the tax deduction payment when canceling the dismissal calculation.
    This is a wrapper function because the main function is Static.
    Function made for task RULOC-4526

    @type Function
    @params 
    @return 
    @author vselyakov
    @since 22.05.2023
    @version 12.1.33
    @example RU07NDFL06_ClearTaxDeduction()
*/
Function RU07NDFL06_ClearTaxDeduction(lDelVacation)

    Default lDelVacation := .F.

Return ClearTaxDeductions(lDelVacation)

/*/{Protheus.doc} RU07NDFL07_DisassembleTaxDeduction()
    The function analyzes a single payment by type of 
    payment 676 (tax deduction on vacation) for each payment, 
    taking into account the deduction code.

    Using into "GPEXINI.PRX" on function "GravaCalc()".
    In this moment mnemonic "aPd" is exist.

    If the payment is 675 without a deduction code, then it came from layoffs ("RES").

    @type Function
    @params 
    @return 
    @Jira RULOC-5443
    @author vselyakov
    @since 30.08.2023
    @version 12.1.33
    @example RU07NDFL07_DisassembleTaxDeduction()
*/
Function RU07NDFL07_DisassembleTaxDeduction()
    Local aArea := GetArea() As Array
    Local aSingleTDPayment := {} As Array // Single payment from vacation.
    Local aRSingleTDPayment := {} As Array // Single payment from retrocalculation.
    Local aVacTDPayment := {} As Array // Array of tax deduction payments from vacation.
    Local aRetroTDPayment := {} As Array // Array of tax deduction payments from retrocalculation.
    Local nIndexTaxDeduction := 0 As Array
    Local cRPFOLDeduction := RetValSRV(aCodFol[0059, 1], SRA->RA_FILIAL, "RV_RETROAP") As Character // Retro (RV_RETROAP) for 675 payment.
    Local cRDFOLDeduction := RetValSRV(aCodFol[0059, 1], SRA->RA_FILIAL, "RV_RETROAD") As Character // Retro (RV_RETROAD) for 675 payment.
    Local cVacTaxDeduction := aCodFol[60,1] As Character // aCodFol[60,1] - SRV #676 - Vacation Tax Deduction.
    Local aF5DArea := F5D->(GetArea()) As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local aRetroPeriods := {} As Array
    Local aRetroRefDates := {} As Array
    Local nI := 0 As Numeric
    Local aDelPd := {} As Array
    Local aPdCopy := {} As Array

    // Disassemble tax deducitons from vacation.
    If Type("aPd") == "A"
        nIndexTaxDeduction := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == cVacTaxDeduction})

        If nIndexTaxDeduction > 0
            aSingleTDPayment := aClone(aPd[nIndexTaxDeduction])
            
            // Reset wage type settings.
            aSingleTDPayment[HOURS_PAYMENT_INDEX] := 1
            aSingleTDPayment[SUM_PAYMENT_INDEX] := 0
            
            // Removing an array element with Nil.
            aDel(aPd, nIndexTaxDeduction)
            aSize(aPd, Len(aPd)-1)
        EndIf

        // F5D search for all FER scenario payouts for a period. They will be generated as payment type 676.
        cQuery := " SELECT F5D_COD, F5D_DEDCOD, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_DTVCPM FROM " + RetSQLName("F5D")
        cQuery += " WHERE                    "
        cQuery += "     F5D_FILIAL     = ?   "
        cQuery += "     AND F5D_MAT    = ?   "
        cQuery += "     AND F5D_ROTEIR = ?   "
        cQuery += "     AND F5D_PER    = ?   "
        cQuery += "     AND F5D_CANCEL = ?   "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New()
        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, FWxFilial("F5D"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, VACATION_SCENARIO_NAME)
        oStatement:SetString(4, cPeriodo)
        oStatement:SetString(5, NO_CANCEL_PAYMENT)

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        // Adding to mnemonics aPd all found payouts with division by deduction code.
        While !((cAlias)->(Eof()))
            If Len(aSingleTDPayment)
                aAdd(aVacTDPayment, aClone(aSingleTDPayment))
                nIndexTaxDeduction := Len(aVacTDPayment)
            Else
                nIndexTaxDeduction := 0
            EndIf

            If nIndexTaxDeduction > 0
                aVacTDPayment[nIndexTaxDeduction][SUM_PAYMENT_INDEX] := (cAlias)->(F5D_SUMPAY)
                aVacTDPayment[nIndexTaxDeduction][DTREF_PAYMENT_INDEX] := SToD(F5D_DTVCPM)
                aVacTDPayment[nIndexTaxDeduction][DATE_PAYMENT_INDEX] := SToD(F5D_DTVCPM)
                aVacTDPayment[nIndexTaxDeduction][CONVOC_PAYMENT_INDEX] := (cAlias)->(F5D_DEDCOD)
            EndIf

            (cAlias)->(DBSkip())
        EndDo

        (cAlias)->(DbCloseArea())

        // Recording all payouts in mnemonic aPd.
        If Type("aPd") == "A" .And. ValType(aVacTDPayment) == "A" .And. Len(aVacTDPayment) > 0
            aEval(aVacTDPayment, {|x| aAdd(aPd, x) })
        EndIf
    EndIf

    // Disassemble tax deducitons from retrocalculation.
    If Type("aPd") == "A"
        aPdCopy := aClone(aPd)
        nIndexTaxDeduction := aScan(aPd, {|x| x[COD_PAYMENT_INDEX]  $ (cRPFOLDeduction + "*" + cRDFOLDeduction)})

        If nIndexTaxDeduction > 0
            aRSingleTDPayment := aClone(aPd[nIndexTaxDeduction])
            
            // Reset wage type settings.
            aRSingleTDPayment[HOURS_PAYMENT_INDEX] := 1
            aRSingleTDPayment[SUM_PAYMENT_INDEX] := 0
        EndIf
        
        // Search all periods for retorcalculations.
        For nI := 1 To Len(aPd)
            If ValType(aPd[nI]) == "A" // It is array.
                If aPd[nI, COD_PAYMENT_INDEX] $ (cRPFOLDeduction + "*" + cRDFOLDeduction)
                    // Add retro period for getting data from F5D for disassemble.
                    If aScan(aRetroPeriods, {|x| x == aPd[nI, RETRO_PERIOD_INDEX]}) <= 0
                        aAdd(aRetroPeriods, aPd[nI, RETRO_PERIOD_INDEX])
                        aAdd(aRetroRefDates, aPd[nI, DATE_PAYMENT_INDEX])
                    EndIf

                    aAdd(aDelPd, nI)
                EndIf
            EndIf
        Next nI

        // Clear mnemonic aPd and fill this excluded elements from array aDelPd.
        aPd := {}

        For nI := 1 To Len(aPdCopy)
            If aScan(aDelPd, {|x| x == nI}) <= 0
                aAdd(aPd, aClone(aPdCopy[nI]))
            EndIf
        Next nI

        // F5D search for all FOL scenario payouts by recalculations.
        cQuery := " SELECT F5D_COD, F5D_DEDCOD, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_DTVCPM, F5D_PER FROM " + RetSQLName("F5D")
        cQuery += " WHERE                                  "
        cQuery += "     F5D_FILIAL     = ?                 "
        cQuery += "     AND F5D_MAT    = ?                 "
        cQuery += "     AND F5D_ROTEIR = ?                 "
        cQuery += "     AND F5D_PER    IN (?)              "
        cQuery += "     AND F5D_CANCEL = ?                 "
        cQuery += "     AND F5D_PER <> LEFT(F5D_DTVCPM, 6) "
        cQuery += "     AND D_E_L_E_T_ = ' '               "

        oStatement := FWPreparedStatement():New()
        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, FWxFilial("F5D"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, SALARY_SCENARIO_NAME)
        oStatement:SetIn(4, aRetroPeriods)
        oStatement:SetString(5, NO_CANCEL_PAYMENT)

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        // Adding to aRetroTDPayment all found payouts with division by deduction code.
        While !((cAlias)->(Eof()))
            If Len(aRSingleTDPayment)
                aAdd(aRetroTDPayment, aClone(aRSingleTDPayment))
                nIndexTaxDeduction := Len(aRetroTDPayment)
            Else
                nIndexTaxDeduction := 0
            EndIf

            If nIndexTaxDeduction > 0
                aRetroTDPayment[nIndexTaxDeduction][SUM_PAYMENT_INDEX] := (cAlias)->(F5D_SUMPAY)
                aRetroTDPayment[nIndexTaxDeduction][DATE_PAYMENT_INDEX] := SToD(F5D_DTVCPM)
                aRetroTDPayment[nIndexTaxDeduction][CONVOC_PAYMENT_INDEX] := (cAlias)->(F5D_DEDCOD)
                aRetroTDPayment[nIndexTaxDeduction][RETRO_PERIOD_INDEX] := (cAlias)->(F5D_PER)

                nI := aScan(aRetroPeriods, {|x| x == (cAlias)->(F5D_PER)})

                If nI > 0
                    aRetroTDPayment[nIndexTaxDeduction][DATE_PAYMENT_INDEX] := aRetroRefDates[nI]
                Else
                    aRetroTDPayment[nIndexTaxDeduction][DATE_PAYMENT_INDEX] := SToD(F5D_DTVCPM)
                EndIf
            EndIf

            (cAlias)->(DBSkip())
        EndDo

        (cAlias)->(DbCloseArea())

        // Recording all payouts in mnemonic aPd.
        If Type("aPd") == "A" .And. ValType(aRetroTDPayment) == "A" .And. Len(aRetroTDPayment) > 0
            aEval(aRetroTDPayment, {|x| aAdd(aPd, x) })
        EndIf
    EndIf

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    F5D->(RestArea(aF5DArea))
    RestArea(aArea)

Return .T.

/*/{Protheus.doc} IsClosePeriod(cCodScenario)
    The function checks if the specified scenario is closed in the current period.

    @type Static Function
    @params cCodScenario, Character, Code of scenario.
    @return lScenarioClosed, Logical, .T. if scenario is closed, .F. in other case.
    @author vselyakov
    @since 04.09.2023
    @version 12.1.33
    @example IsClosePeriod("ADI")
*/
Static Function IsClosePeriod(cCodScenario)
    Local aArea := GetArea() As Array
    Local aRCHArea := RCH->(GetArea()) As Array
    Local lScenarioClosed := .F. As Logical
    Local dADIPaymentDate := CToD("//") As Date

    /*
        Define status of ADI (advance) scenario.
        RCH_STATUS - status of scenario.
        RCH_DTFECH - close date of scenario.
        RCH_DTPAGO - payment date of scenario.
    */
    DBSelectArea("RCH")
    DBSetOrder(1) // "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR".
    If RCH->(DBSeek(FwXFilial("RCH") + SRA->RA_PROCES + cPeriodo + cNumPag + cCodScenario))
        dADIPaymentDate := RCH->RCH_DTPAGO

        If RCH->RCH_STATUS == SCENARIO_STATUS_CLOSED .And. !Empty(RCH->RCH_DTFECH)
            lScenarioClosed := .T.
        EndIf
    EndIf

    RCH->(RestArea(aRCHArea))
    RestArea(aArea)

Return lScenarioClosed

/*/{Protheus.doc} DeleteTDDetail(cCodScenario)
    Delete tax deductions from F5D (details) only for salary scenario (FOL) and advance (ADI).

    * Why this need
        When clearing the results through the GPEM160 routine, only the records from F5D are cleared, 
    and the deduction header remains in F5C. In the event of a lump-sum calculation of vacation 
    before the closing of the advance, this deduction will be duplicated.

        When calculating the vacation, if the advance has not yet been closed, 
    then you need to delete the entries from F5C and F5D so that the deductions from the advance (ADI) 
    are not taken into account when calculating the vacation.

    @type Static Function
    @params cCodScenario, Character, Code of calculation scenario.
    @return 
    @author vselyakov
    @since 06.09.2023
    @version 12.1.33
    @example DeleteTDDetail(ADVANCE_SCENARIO_NAME)
*/
Static Function DeleteTDDetail(cCodScenario)
    Local cQuery := "" As Char
    Local oStatement := FWPreparedStatement():New() As Object
    Local aArea := GetArea() As Array
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, VACATION_SCENARIO_NAME)
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    cQuery := " DELETE FROM " + RetSQLName("F5D") 
    cQuery += " WHERE                   "
    cQuery += "     F5D_FILIAL = ? "
    cQuery += "     AND F5D_MAT = ? "
    cQuery += "     AND F5D_PROCES = ? "
    cQuery += "     AND F5D_ROTEIR = ? "
    cQuery += "     AND F5D_PER = ? "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, FWxFilial("F5D"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, SRA->RA_PROCES)
    oStatement:SetString(4, cCodScenario)
    oStatement:SetString(5, cPeriodCode)

    TcSqlExec(oStatement:GetFixQuery())

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aArea)
Return

/*/{Protheus.doc} CancelDeductionPayment()
    The function updates a previously created payment that was on vacation.

    * Why this need
        In order to correctly calculate the tax deduction after deleting a vacation, 
    you need to change the payment of this vacation as "Canceled".

    @type Static Function
    @params 
    @return 
    @author vselyakov
    @since 06.09.2023
    @version 12.1.33
    @example CancelDeductionPayment()
*/
Static Function CancelDeductionPayment()
    Local cQuery := "" As Char
    Local oStatement := FWPreparedStatement():New() As Object
    Local aArea := GetArea() As Array
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, "FER")
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    cQuery := " UPDATE " + RetSQLName("F5D") 
    cQuery += " SET                    "
    cQuery += "     F5D_CANCEL = ?     "
    cQuery += " WHERE                  "
    cQuery += "     F5D_FILIAL = ?     "
    cQuery += "     AND F5D_MAT = ?    "
    cQuery += "     AND F5D_PROCES = ? "
    cQuery += "     AND F5D_ROTEIR = ? "
    cQuery += "     AND F5D_DTVCPM = ? "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, IS_CANCEL_PAYMENT)
    oStatement:SetString(2, FWxFilial("F5D"))
    oStatement:SetString(3, SRA->RA_MAT)
    oStatement:SetString(4, SRA->RA_PROCES)
    oStatement:SetString(5, VACATION_SCENARIO_NAME)
    
    If cRot == "FER".Or. IsInCallStack("GPEM030") .Or. IsInCallStack("GPEM060")
        oStatement:SetString(6, Iif(Empty(M->RH_DATAINI), DToS(SRH->RH_DATAINI), DToS(M->RH_DATAINI)))
    ElseIf cRot == "RES".Or. IsInCallStack("GPEM040")
        oStatement:SetString(6, DToS(M->RG_DATADEM))
    EndIf

    TcSqlExec(oStatement:GetFixQuery())
    
    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aArea)
Return

/*/{Protheus.doc} CheckEmptyTaxDeductions()
    The function check headers of tax deduction (F5C)
    and collect F5C_COD into array for later removal.

    @type Static Function
    @params 
    @return aEmptyDeductions, Array, Array of F5C_COD for remove.
    @author vselyakov
    @since 06.09.2023
    @version 12.1.33
    @example CheckEmptyTaxDeductions()
*/
Static Function CheckEmptyTaxDeductions()
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local nI := 0 As Numeric
    Local aTDCodes := {} As Array
    Local aEmptyDeductions := {} As Array
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, VACATION_SCENARIO_NAME)
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    // Get all social tax deductions from header (F5C).
    cQuery := " SELECT F5C_COD FROM " + RetSQLName("F5C")
    cQuery += " WHERE                           "
    cQuery += "     F5C_FILIAL     = ?          "
    cQuery += "     AND F5C_MAT    = ?          "
    cQuery += "     AND F5C_TYPE   = ?          "
    cQuery += "     AND F5C_LOCK   = ?          "
    cQuery += "     AND F5C_STATUS = ?          "
    cQuery += "     AND LEFT(F5C_DTENTR, 6) = ? "
    cQuery += "     AND D_E_L_E_T_ = ' '        "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, FWxFilial("F5C"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, SOCIAL_TAX_DEDUCTION_CODE)
    oStatement:SetString(4, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(5, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(6, cPeriodCode)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

    // Adding to mnemonics aPd all found payouts with division by deduction code.
    While !((cAlias)->(Eof()))
        aAdd(aTDCodes, (cAlias)->(F5C_COD))

        (cAlias)->(DBSkip())
    EndDo

    (cAlias)->(DBCloseArea())
    oStatement:Destroy()

    // Check anyone social tax deduction on existing active payment.
    // If active payments are not exist then save this to delete headers.
    For nI := 1 To Len(aTDCodes)
        cQuery := " SELECT COUNT(F5D_COD) AS PAYMENTS FROM " + RetSQLName("F5D")
        cQuery += " WHERE                    "
        cQuery += "     F5D_FILIAL = ?       "
        cQuery += "     AND F5D_MAT = ?      "
        cQuery += "     AND F5D_COD = ?      "
        cQuery += "     AND F5D_CANCEL = ?   "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New()(cQuery)
        oStatement:SetString(1, FWxFilial("F5D"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aTDCodes[nI])
        oStatement:SetString(4, NO_CANCEL_PAYMENT)

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())

        If ((cAlias)->PAYMENTS == 0)
            aAdd(aEmptyDeductions, aTDCodes[nI])
        EndIf

        (cAlias)->(DBCloseArea())
    Next nI

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aArea)

Return aEmptyDeductions

/*/{Protheus.doc} DeleteEmptyTaxDeductions()
    Function delete form F5C and F5D tax deduction
    wich was without active payments.

    @type Static Function
    @params 
    @return aTDForRemove, Array, Array of F5C_COD wich was removed.
    @author vselyakov
    @since 06.09.2023
    @version 12.1.33
    @example DeleteEmptyTaxDeductions()
*/
Static Function DeleteEmptyTaxDeductions()
    Local aTDForRemove := CheckEmptyTaxDeductions() As Array
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local nI := 0 As Numeric
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, VACATION_SCENARIO_NAME)
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    For nI := 1 To Len(aTDForRemove)
        // Remove headers (F5C).
        cQuery := " DELETE FROM " + RetSQLName("F5C")
        cQuery += " WHERE                           "
        cQuery += "     F5C_FILIAL = ?              "
        cQuery += "     AND F5C_MAT = ?             "
        cQuery += "     AND F5C_COD = ?             "
        cQuery += "     AND LEFT(F5C_DTENTR, 6) = ? "
        cQuery += "     AND D_E_L_E_T_ = ' '        "

        oStatement := FWPreparedStatement():New()(cQuery)
        oStatement:SetString(1, FWxFilial("F5C"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aTDForRemove[nI])
        oStatement:SetString(4, cPeriodCode)

        TcSqlExec(oStatement:GetFixQuery())

        // Remove payments (F5D).
        cQuery := " DELETE FROM " + RetSQLName("F5D")
        cQuery += " WHERE                    "
        cQuery += "     F5D_FILIAL = ?       "
        cQuery += "     AND F5D_MAT = ?      "
        cQuery += "     AND F5D_COD = ?      "
        cQuery += "     AND F5D_PER = ?      "
        cQuery += "     AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New()(cQuery)
        oStatement:SetString(1, FWxFilial("F5D"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aTDForRemove[nI])
        oStatement:SetString(4, cPeriodCode)

        TcSqlExec(oStatement:GetFixQuery())
    Next nI

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aArea)

Return aTDForRemove

/*/{Protheus.doc} LoadHistory()
    Load pyaments of open social and estate tax deductions from previous periods.

    @type Static Function
    @params 
    @return aDeductions, Array, Array of RUTaxDeduction() wich need paid in current period.
    @author vselyakov
    @since 07.09.2023
    @version 12.1.33
    @example aTaxDeductions := LoadHistory()
*/
Static Function LoadHistory(aTaxDeductions)
    Local aDeductions := {} As Array
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := FWPreparedStatement():New() As Object
    Local nI := 0 As Numeric
    Local aTDCodes := {} As Array
    Local oTaxDeduction As Object
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, VACATION_SCENARIO_NAME)
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    // Get all social tax deductions from header (F5C).
    cQuery := " SELECT F5C_COD, F5C_TYPE, F5C_DEDCOD, F5C_INCOME FROM " + RetSQLName("F5C")
    cQuery += " WHERE                           "
    cQuery += "     F5C_FILIAL     = ?          "
    cQuery += "     AND F5C_MAT    = ?          "
    cQuery += "     AND F5C_LOCK   = ?          "
    cQuery += "     AND F5C_STATUS = ?          "
    cQuery += "     AND LEFT(F5C_DTENTR, 6) < ? "
    cQuery += "     AND D_E_L_E_T_ = ' '        "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("F5C"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(4, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(5, cPeriodCode)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

    // Adding to mnemonics aPd all found payouts with division by deduction code.
    While !((cAlias)->(Eof()))
        aAdd(aTDCodes, {(cAlias)->F5C_COD, (cAlias)->F5C_TYPE, (cAlias)->F5C_DEDCOD, (cAlias)->F5C_INCOME})

        (cAlias)->(DBSkip())
    EndDo

    (cAlias)->(DBCloseArea())

    // Check anyone social tax deduction on existing active payment.
    // If active payments are not exist then save this to delete headers.
    For nI := 1 To Len(aTDCodes)
        oTaxDeduction := RUTaxDeduction():New()
        oTaxDeduction:cFil := FWxFilial("F5D")
        oTaxDeduction:cMat := SRA->RA_MAT
        oTaxDeduction:cF5CId := aTDCodes[nI][1]
        oTaxDeduction:cType := aTDCodes[nI][2]
        oTaxDeduction:cDeductionCode := aTDCodes[nI][3]
        oTaxDeduction:nSumToPay := aTDCodes[nI][4]
        oTaxDeduction:lCancelPayment := NO_CANCEL_PAYMENT
        oTaxDeduction:lFromSRB := Iif(SubStr(aTDCodes[nI][3], 1, 1) == SOCIAL_TAX_DEDUCTION_CODE, .T., .F.)        
        oTaxDeduction:cPaymentNumber := "00"
        oTaxDeduction:nSumPayment := 0
        oTaxDeduction:nPaidSum := 0

        cQuery := " SELECT F5D_COD, F5D_DEDCOD, F5D_PROCES, F5D_ROTEIR, F5D_PER, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_CANCEL FROM " + RetSQLName("F5D")
        cQuery += " WHERE                    "
        cQuery += "     F5D_FILIAL = ?       "
        cQuery += "     AND F5D_MAT = ?      "
        cQuery += "     AND F5D_COD = ?      "
        cQuery += "     AND D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F5D_NUMPAG      "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, FWxFilial("F5D"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aTDCodes[nI][1])

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())

        While !((cAlias)->(Eof()))
            oTaxDeduction:nSumPayment := 0
            oTaxDeduction:cPaymentNumber := (cAlias)->F5D_NUMPAG

            If (cAlias)->F5D_CANCEL == NO_CANCEL_PAYMENT
                oTaxDeduction:nSumToPay := (cAlias)->F5D_INCRES 
                oTaxDeduction:nPaidSum := (cAlias)->F5D_INCPER
            EndIf
            

            (cAlias)->(DBSkip())
        EndDo

        (cAlias)->(DBCloseArea())

        aAdd(aTaxDeductions, oTaxDeduction)
    Next nI

    oStatement:Destroy()
    FWFreeObj(oStatement)

    RestArea(aArea)

Return aDeductions

/*/{Protheus.doc} GetEstateTD(aTaxDeductions As Array)
    Loading tax deduction for F5C_TYPE='3' in current period.

    @type Static Function
    @params aTaxDeductions, Array, Array of RUTaxDeduction().
    @return 
    @author vselyakov
    @since 07.09.2023
    @version 12.1.33
    @example GetEstateTD(@aTaxDeductions)
*/
Static Function GetEstateTD(aTaxDeductions As Array)
    Local aS210_TaxDeductionsTypes := {} As Array
    Local nI As Numeric
    Local oTaxDeduction As Object
    Local cQuery := "" As Character
    Local oStatement As Object
    Local aTDCodes := {} As Array
    Local cPeriodCode := cPeriodo As Character
    Local aCurPeriod := {} As Array

    // Define period string.
    If Empty(cPeriodo)
        fPerAtual(@aCurPeriod, VACATION_SCENARIO_NAME)
        If Len(aCurPeriod) > 0
            cPeriodCode := aCurPeriod[1]
        ElseIf Len(aPeriodo) > 0
            cPeriodCode := aPeriodo[1][1]
        EndIf
    EndIf

    fCarrTab(@aS210_TaxDeductionsTypes, "S210", SToD(cPeriodCode + "01"), .T.) // fCarrTab - standart function, loads given S-table to array.

    // Get all estate tax deductions from header (F5C).
    cQuery := " SELECT F5C_COD, F5C_TYPE, F5C_DEDCOD, F5C_INCOME FROM " + RetSQLName("F5C")
    cQuery += " WHERE                           "
    cQuery += "     F5C_FILIAL     = ?          "
    cQuery += "     AND F5C_MAT    = ?          "
    cQuery += "     AND F5C_LOCK   = ?          "
    cQuery += "     AND F5C_STATUS = ?          "
    cQuery += "     AND F5C_TYPE = ?            "
    cQuery += "     AND LEFT(F5C_DTENTR, 6) = ? "
    cQuery += "     AND D_E_L_E_T_ = ' '        "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("F5C"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(4, ACTIVE_TAX_DEDUCTION)
    oStatement:SetString(5, ESTATE_TAX_DEDUCTION_CODE)
    oStatement:SetString(6, cPeriodCode)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cAlias)
    (cAlias)->(DBGoTop())

    // Adding to mnemonics aPd all found payouts with division by deduction code.
    While !((cAlias)->(Eof()))
        aAdd(aTDCodes, {(cAlias)->F5C_COD, (cAlias)->F5C_TYPE, (cAlias)->F5C_DEDCOD, (cAlias)->F5C_INCOME})

        (cAlias)->(DBSkip())
    EndDo

    (cAlias)->(DBCloseArea())

    For nI := 1 To Len(aTDCodes)
        oTaxDeduction := RUTaxDeduction():New()
        oTaxDeduction:cFil := FWxFilial("F5D")
        oTaxDeduction:cMat := SRA->RA_MAT
        oTaxDeduction:cF5CId := aTDCodes[nI][1]
        oTaxDeduction:cType := aTDCodes[nI][2]
        oTaxDeduction:cDeductionCode := aTDCodes[nI][3]
        oTaxDeduction:nSumToPay := aTDCodes[nI][4]
        oTaxDeduction:lCancelPayment := NO_CANCEL_PAYMENT
        oTaxDeduction:lFromSRB := Iif(SubStr(aTDCodes[nI][3], 1, 1) == ESTATE_TAX_DEDUCTION_CODE, .F., .T.)
        oTaxDeduction:cPaymentNumber := "00"
        oTaxDeduction:nSumPayment := 0
        oTaxDeduction:nPaidSum := 0

        cQuery := " SELECT F5D_COD, F5D_DEDCOD, F5D_PROCES, F5D_ROTEIR, F5D_PER, F5D_NUMPAG, F5D_INCPER, F5D_INCRES, F5D_SUMPAY, F5D_CANCEL FROM " + RetSQLName("F5D")
        cQuery += " WHERE                    "
        cQuery += "     F5D_FILIAL = ?       "
        cQuery += "     AND F5D_MAT = ?      "
        cQuery += "     AND F5D_COD = ?      "
        cQuery += "     AND D_E_L_E_T_ = ' ' "
        cQuery += " ORDER BY F5D_NUMPAG      "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, FWxFilial("F5C"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aTDCodes[nI][1])

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cAlias)
        (cAlias)->(DBGoTop())

        While !((cAlias)->(Eof()))
            oTaxDeduction:nSumPayment := 0
            oTaxDeduction:cPaymentNumber := (cAlias)->F5D_NUMPAG

            If (cAlias)->F5D_CANCEL == NO_CANCEL_PAYMENT
                // oTaxDeduction:nSumToPay := (cAlias)->F5D_INCRES 
                // oTaxDeduction:nPaidSum := (cAlias)->F5D_INCPER
                oTaxDeduction:nPaidSum += (cAlias)->F5D_SUMPAY
                oTaxDeduction:nSumToPay -= (cAlias)->F5D_SUMPAY
            EndIf


            (cAlias)->(DBSkip())
        EndDo

        (cAlias)->(DBCloseArea())

        aAdd(aTaxDeductions, oTaxDeduction)
    Next nI

Return 

/*/{Protheus.doc} RU07NDFL08_CollectTaxDeduction
    Collect tax deductions and NDFL payments before writing into SRR.
    Using into GPEM690.

    @type Function
    @params aPayments, Array, Array of payments (aPd).
    @return Array, New array of payments without duplcicate payments.
    @author vselyakov
    @since 21.02.2024
    @version 12.1.33
    @example aPd := RU07NDFL08(aPd)
*/
Function RU07NDFL08_CollectTaxDeduction(aPayments)
    Local aNewPayments := {} As Array
    Local nI := 0 As Numeric
    Local nIndex676Payment := 0 As Numeric
    Local nIndex414Payment := 0 As Numeric
    Local cFilterCriteria := aCodFol[67,1] + "*" + aCodFol[60,1] As Character // Payments "414*676".

    For nI := 1 To Len(aPayments)
        If aPayments[nI, COD_PAYMENT_INDEX] $ cFilterCriteria
            If aPayments[nI, COD_PAYMENT_INDEX] == aCodFol[67,1] // Payment 414.
                If nIndex414Payment == 0
                    nIndex414Payment := nI
                    aAdd(aNewPayments, aPayments[nI])
                    Loop
                EndIf

                aNewPayments[nIndex414Payment, HOURS_PAYMENT_INDEX] += aPayments[nI, HOURS_PAYMENT_INDEX]
                aNewPayments[nIndex414Payment, SUM_PAYMENT_INDEX] += aPayments[nI, SUM_PAYMENT_INDEX]
            EndIf

            If aPayments[nI, COD_PAYMENT_INDEX] == aCodFol[60,1]  // Payment 676.
                If nIndex676Payment == 0
                    nIndex676Payment := nI
                    aAdd(aNewPayments, aPayments[nI])
                    Loop
                EndIf

                aNewPayments[nIndex676Payment, HOURS_PAYMENT_INDEX] += aPayments[nI, HOURS_PAYMENT_INDEX]
                aNewPayments[nIndex676Payment, SUM_PAYMENT_INDEX] += aPayments[nI, SUM_PAYMENT_INDEX]
            EndIf
        Else
            aAdd(aNewPayments, aPayments[nI])
        EndIf
    Next nI

Return aNewPayments

/*/{Protheus.doc} RU07NDFL09_GetSRDDeductionsSumm
    Return summ of tax deductions for employee from SRD.
    Using into GPEA020RUS.

    @type Function
    @param cBranchEmp, Character, Filial of employee.
    @param cMatEmp, Character, Number of employee.
    @param cDeductionCode, Character, Tax deduction code.
    @return Numeric, Sum of payments 675, 676 from SRD.
    @author vselyakov
    @since 18.04.2024
    @version 12.1.2310
    @example aPd := RU07NDFL08(aPd)
*/
Function RU07NDFL09_GetSRDDeductionsSumm(cBranchEmp, cMatEmp, cDeductionCode)
    Local nDeductionSum := 0 As Numeric
    Local aArea := GetArea() As Array
    Local cQuery := "" As Character
    Local oStatement := Nil As Object

    Default cBranchEmp := SRA->RA_FILIAL
    Default cMatEmp := SRA->RA_MAT
    Default cDeductionCode := ""

    If !Empty(cBranchEmp) .And. !Empty(cMatEmp) .And. !Empty(cDeductionCode)
        cQuery := " SELECT COUNT(*) AS LINECOUNT FROM " + RetSQLName("SRD")
        cQuery += " WHERE "
        cQuery += "     D_E_L_E_T_ = ' '  "
        cQuery += "     AND RD_FILIAL = ? "
        cQuery += "     AND RD_MAT = ?    "
        cQuery += "     AND RD_PD IN (?)  "
        cQuery += "     AND RD_CONVOC = ? "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cBranchEmp)
        oStatement:SetString(2, cMatEmp)
        oStatement:SetIn(3, { fGetCodFol("0059"), fGetCodFol("0060") }) // Payments (SRV) 675, 676.
        oStatement:SetString(4, cDeductionCode)

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        nDeductionSum := (cAlias)->(LINECOUNT)

        (cAlias)->(DbCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)
    Else
        ConOut("RU07NDFL09_GetSRDDeductionsSumm: Failed to load data from SRD")
    EndIf

    RestArea(aArea)
Return nDeductionSum
