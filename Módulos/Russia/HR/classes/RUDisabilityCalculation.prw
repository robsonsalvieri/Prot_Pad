#Include "PROTHEUS.CH"

#Define PAYMENT_DAYS_BY_COMPANY 3 // Number of days paid by employer.
#Define DAYS_AFTER_DISMISSAL 30 // During these days absence may be paid.
#Define GET_VALUE_FROM_PERCENT 0.01 // This is instead of dividing by 100.

/*/
{Protheus.doc} RUDisabilityCalculation
    Class for calculating absences of disability without Social Insurance Fund.
    Built to specification:
        * https://wiki.support.national-platform.ru/xwiki/bin/view/Main/InternalDocs/Analytics/HR/Project%20Documentation/016%20Absences/016-04%20Sick%20leave/016-04-004009017020%20Sickness/

    Jira task RULOC-4042

    @type Class
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
/*/
Class RUDisabilityCalculation From LongNameClass
    Data cCurrentYear As Character
    Data cTypeAbsenceCode As Character
    Data cPeriod As Character
    Data nExperienceCoef As Numeric // Experience coefficient of employee.
    Data lNoExperience As Date // Employee has no experience.

    Data oAbsenceTypeSettings As Object
    Data oAbsenceSettings As Object

    Method New(cTypeAbsenceCode, nDaysAbsence, nYearBalance, cPeriod, nExperienceCoef, dStartDate, dViolateDate, lNoExperience) Constructor
    Method Destroy()

    Method Calculation()
    Method CaclulationFromMinimum()
    Method CalculationWithViolation()
    Method StandartCalculation()

    Method GetAbsenceSettings() // Get absence settings form RCM table.
    Method GetAveragePayment() // Get average daily earnings without comparison with the minimum wage.
    Method GetAVStandard() // Get average daily earnings wit comparison with the minimum wage.

    Method GetRegionalFactor()
    Method GetMinimumWage()
    Method GetCountMonthDay(dInputDate)
    Method GetMaxBase()
    Method GetMinBase()
    Method GetExperienceArray()
    Method CreatePayments(nCompanyPayment, nCompanyDays, nFSSPayment, nFSSDays)
    Method GetMonthMinimumWage(dInputDate)
EndClass

/*/
{Protheus.doc} New
    Default constructor.

    @type Method
    @param cTypeAbsenceCode, Character, Type absence code
    @param nDaysAbsence, Numeric, Count of absence day
    @param nYearBalance, Numeric, Absence days count per year
    @param cPeriod, Character, Calculation period
    @param nExperienceCoef, Numeric, Experience coefficient
    @param dStartDate, Date, Start date of absence
    @param dViolateDate, Date, Date of violation
    @param lNoExperience, Logical, Employee has no experience of work
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
    @return Object, RUDisabilityCalculation instance.
/*/
Method New(cTypeAbsenceCode, nDaysAbsence, nYearBalance, cPeriod, nExperienceCoef, dStartDate, dViolateDate, lNoExperience, cParentNumber, nRecno) Class RUDisabilityCalculation
    Local aArea := GetArea() As Array
    Local aSR8Area := SR8->(GetArea()) As Array
    Local nPaidDays := 0 As Numeric

    Self:cTypeAbsenceCode := cTypeAbsenceCode

    Self:cPeriod := cPeriod
    Self:nExperienceCoef := nExperienceCoef
    Self:lNoExperience := lNoExperience
    
    Self:cCurrentYear := SubStr(cPeriod, 1, 4) // "2023".

    DbSelectArea("SR8")
    SR8->(DbGoTo(nRecno))

    nPaidDays := SR8->R8_DPAGAR

    Self:oAbsenceSettings := RUAbsenceModel():New()
    Self:oAbsenceSettings:cCodeTypeAbsence := cTypeAbsenceCode
    Self:oAbsenceSettings:nDaysAbsence := nPaidDays
    Self:oAbsenceSettings:nYearBalance := nYearBalance
    Self:oAbsenceSettings:dStartDate := dStartDate
    Self:oAbsenceSettings:dViolateDate := dViolateDate
    Self:oAbsenceSettings:cPreviousNumberAbsence := cParentNumber
    Self:oAbsenceSettings:dEndDate := Self:oAbsenceSettings:dStartDate + SR8->R8_DPAGAR - 1
    Self:oAbsenceSettings:DaysDistribution()

    If Type("oRU07XFU01") == "O"
        oRU07XFU01:cNumberOfELN := SR8->R8_OBSAFAS 
    EndIf

    SR8->(RestArea(aSR8Area))
    RestArea(aArea)

Return Self

/*/
{Protheus.doc} Destroy
    Destructor.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method Destroy() Class RUDisabilityCalculation

    Self:oAbsenceTypeSettings:Destroy()
    FwFreeObj(Self:oAbsenceTypeSettings)
    
    Self:oAbsenceSettings:Destroy()
    FwFreeObj(Self:oAbsenceSettings)

Return

/*/
{Protheus.doc} Calculation
    Calculation of absence. Main method.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method Calculation() Class RUDisabilityCalculation
    Local lCanContinue := .F. As Logical
    Local lCalcFromMinimum := .F. As Logical
    Local lCalcViolation := .F. As Logical
    Local nStdAverage := 0 As Numeric
    Local aExpCoeffs := Self:GetExperienceArray() As Array

    lCanContinue := !Empty(Self:oAbsenceSettings:cCodeTypeAbsence) .And. !Empty(Self:cPeriod) .And. !Empty(Self:oAbsenceSettings:dStartDate)

    // Create some logs.
    If ValType(Self:oAbsenceSettings:dViolateDate) <> "D"
        ConOut("Error into RUDisabilityCalculation: Variable dViolateDate is not date type!")
        lCanContinue := .F.
    EndIf

    If ValType(Self:oAbsenceSettings:dStartDate) <> "D"
        ConOut("Error into RUDisabilityCalculation: Variable dStartDate is not date type!")
        lCanContinue := .F.
    EndIf

    // Get type of absence parameters.
    If lCanContinue
        Self:oAbsenceTypeSettings := Self:GetAbsenceSettings()
        lCanContinue := Self:oAbsenceTypeSettings:lIsLoaded
    EndIf

    // Accounting for limits on days of absence.
    If lCanContinue
        If Self:oAbsenceSettings:nDaysAbsence <= 0
            Self:oAbsenceSettings:nDaysAbsence := 0
            lCanContinue := .F.
        EndIf
    EndIf

    If lCanContinue
    
        // Determination of cases of calculation from the minimum wage.
        nStdAverage := Self:GetAveragePayment()
        If Self:lNoExperience .Or. nStdAverage <= 0 .Or. (Self:oAbsenceTypeSettings:lViolation .And. !Empty(Self:oAbsenceSettings:dViolateDate) .And. Self:oAbsenceSettings:dViolateDate <= Self:oAbsenceSettings:dStartDate)
            lCalcFromMinimum := .T.
            Self:nExperienceCoef := 1
        EndIf

        // If the type of absence does not take into account length of service then the coefficient is 1.
        If !Self:oAbsenceTypeSettings:lExperience
            Self:nExperienceCoef := 1
        EndIf

        // If the absence is after dismissal then the experience is always 60%.
        If !Empty(SRA->RA_DEMISSA) .And. (Self:oAbsenceSettings:dStartDate - SRA->RA_DEMISSA + 1 <= DAYS_AFTER_DISMISSAL)
            Self:nExperienceCoef := aExpCoeffs[1] * GET_VALUE_FROM_PERCENT // 1 year - 60%.
        EndIf

        // Determination of cases of calculation with violation.
        If !lCalcFromMinimum .And. (Self:oAbsenceTypeSettings:lViolation .And. !Empty(Self:oAbsenceSettings:dViolateDate) .And. Self:oAbsenceSettings:dViolateDate > Self:oAbsenceSettings:dStartDate)
            lCalcViolation := .T.
            Self:oAbsenceSettings:lWasViolation := .T.
        EndIf

        Self:oAbsenceSettings:DaysDistribution()

        // Calculatio from minimum wage.
        If lCalcFromMinimum .And. !lCalcViolation
            Self:CaclulationFromMinimum()
        ElseIf !lCalcFromMinimum .And. lCalcViolation
            Self:CalculationWithViolation()
        Else
            Self:StandartCalculation()
        EndIf
    
    EndIf

Return

/*/
{Protheus.doc} CaclulationFromMinimum
    Calculation of absence based on the minimum wage.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method CaclulationFromMinimum() Class RUDisabilityCalculation
    Local nCompanyPayment := 0 As Numeric
    Local nFSSPayment := 0 As Numeric
    Local nI := 0 As Numeric
    Local nCompanyDays := 0 As Numeric
    Local nFSSDays := 0 As Numeric
    Local nMinTwoYears := Self:GetMinimumWage() As Numeric // Minimal wage by two years.
    Local nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dStartDate) As Numeric // Minimum wage by month.
    Local nMinSelected := 0 As Numeric

    If Self:oAbsenceSettings:lIsContinue
        nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dFatherStartDateAbsence)
    EndIf

    If nMinTwoYears * Self:nExperienceCoef >= nMinMonth
        nMinSelected := nMinTwoYears * Self:nExperienceCoef
    Else
        nMinSelected := nMinMonth
    EndIf

    For nI := 1 To Len(Self:oAbsenceSettings:aAbsenceDistribution)
        // Calculate minimum wage for date.
        Self:oAbsenceSettings:aAbsenceDistribution[nI][4] := nMinSelected

        // Calculation amounts.
        If Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "WRK"
            nCompanyPayment := nCompanyPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nCompanyDays := nCompanyDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        ElseIf Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "FSS"
            nFSSPayment := nFSSPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nFSSDays := nFSSDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        EndIf
    Next nI

    // Create payments.
    Self:CreatePayments(nCompanyPayment, nCompanyDays, nFSSPayment, nFSSDays)

Return

/*/
{Protheus.doc} CalculationWithViolation
    Calculation of absence with violation.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method CalculationWithViolation() Class RUDisabilityCalculation
    Local nMaxBase := Self:GetMaxBase() As Numeric
    Local nStdWage := Self:GetAVStandard() As Numeric
    Local nCompanyPayment := 0 As Numeric
    Local nFSSPayment := 0 As Numeric
    Local nI := 0 As Numeric
    Local nCompanyDays := 0 As Numeric
    Local nFSSDays := 0 As Numeric
    Local nTmpPay := 0 As Numeric // Temporary variable for regular payment based on length of service.
    Local nTmpMin := 0 As Numeric // Temporary variable for minimum wage as of date.
    Local nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dStartDate) As Numeric // Minimum wage by month.

    // If the standard average income is greater than the maximum, then the maximum is taken.
    If nStdWage > nMaxBase
        nStdWage := nMaxBase
    EndIf

    If Self:oAbsenceSettings:lIsContinue
        nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dFatherStartDateAbsence)
    EndIf

    // Comparison of regular payment (taking into account length of service) with the minimum wage as of the date.
    nTmpPay := nStdWage * Self:nExperienceCoef

    If nTmpPay <= nMinMonth
        nTmpPay := nMinMonth
    EndIf

    For nI := 1 To Len(Self:oAbsenceSettings:aAbsenceDistribution)

        // If the date of violation is the current date or less, then the calculation will be based on the minimum wage.
        If Self:oAbsenceSettings:dViolateDate <= Self:oAbsenceSettings:aAbsenceDistribution[nI][1]
            nTmpPay := nMinMonth
        EndIf

        // Calculate minimum wage for date.
        Self:oAbsenceSettings:aAbsenceDistribution[nI][4] := nTmpPay

        // Calculation amounts.
        If Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "WRK"
            nCompanyPayment := nCompanyPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nCompanyDays := nCompanyDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        ElseIf Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "FSS"
            nFSSPayment := nFSSPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nFSSDays := nFSSDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        EndIf
    Next nI

    Self:CreatePayments(nCompanyPayment, nCompanyDays, nFSSPayment, nFSSDays)

Return

/*/
{Protheus.doc} StandartCalculation
    Calculation of absence by standard way.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method StandartCalculation() Class RUDisabilityCalculation
    Local nMaxBase := Self:GetMaxBase() As Numeric
    Local nStdWage := Self:GetAVStandard() As Numeric
    Local nCompanyPayment := 0 As Numeric
    Local nFSSPayment := 0 As Numeric
    Local nI := 0 As Numeric
    Local nCompanyDays := 0 As Numeric
    Local nFSSDays := 0 As Numeric
    Local nTmpPay := 0 As Numeric // Temporary variable for regular payment based on length of service.
    Local nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dStartDate) As Numeric // Minimum wage by month.

    // If the standard average income is greater than the maximum, then the maximum is taken.
    If nStdWage > nMaxBase
        nStdWage := nMaxBase
    EndIf

    If Self:oAbsenceSettings:lIsContinue
        nMinMonth := Self:GetMonthMinimumWage(Self:oAbsenceSettings:dFatherStartDateAbsence)
    EndIf

    // Comparison of regular payment (taking into account length of service) with the minimum wage as of the date.
    nTmpPay := nStdWage * Self:nExperienceCoef

    If nTmpPay <= nMinMonth
        nTmpPay := nMinMonth
    EndIf

    For nI := 1 To Len(Self:oAbsenceSettings:aAbsenceDistribution)

        // If the date of violation is the current date or less, then the calculation will be based on the minimum wage.
        If !Empty(Self:oAbsenceSettings:dViolateDate) .And. Self:oAbsenceSettings:dViolateDate <= Self:oAbsenceSettings:aAbsenceDistribution[nI][1]
            nTmpPay := nMinMonth
        EndIf

        // Calculate minimum wage for date.
        Self:oAbsenceSettings:aAbsenceDistribution[nI][4] := nTmpPay

        // Calculation amounts.
        If Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "WRK"
            nCompanyPayment := nCompanyPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nCompanyDays := nCompanyDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        ElseIf Self:oAbsenceSettings:aAbsenceDistribution[nI][2] == "FSS"
            nFSSPayment := nFSSPayment + Self:oAbsenceSettings:aAbsenceDistribution[nI][4]
            nFSSDays := nFSSDays + Self:oAbsenceSettings:aAbsenceDistribution[nI][3]
        EndIf
    Next nI

    Self:CreatePayments(nCompanyPayment, nCompanyDays, nFSSPayment, nFSSDays)

Return

/*/
{Protheus.doc} GetAveragePayment
    Obtaining the average earnings without comparison with the minimum wage.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Numeric, Value of average earnings without comparison with the minimum wage.
/*/
Method GetAveragePayment(lIsContinue) Class RUDisabilityCalculation
    Local nAverage := 0 As Numeric

    Default lIsContinue := Self:oAbsenceSettings:lIsContinue

    // Get average daily earnings without comparison with the minimum wage.
    If !lIsContinue
        nAverage := fRUDisShCal(SRA->RA_MAT, SToD(Self:cPeriod + "01"), .F., RUMap():New(), .F.)
    Else
        nAverage := fRUDisShCal(SRA->RA_MAT, Self:oAbsenceSettings:dFatherStartDateAbsence, .F., RUMap():New(), .F.)
    EndIf

Return nAverage

/*/
{Protheus.doc} GetAVStandard
    Obtaining the average earnings with comparison with the minimum wage.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Numeric, Value of average earnings with comparison with the minimum wage.
/*/
Method GetAVStandard(lIsContinue) Class RUDisabilityCalculation
    Local nAverage := 0 As Numeric

    Default lIsContinue := Self:oAbsenceSettings:lIsContinue

    // Get average daily earnings wit comparison with the minimum wage.    
    If !lIsContinue
        nAverage := fRUDisShCal(SRA->RA_MAT, SToD(Self:cPeriod + "01"), .F., RUMap():New())
    Else
        nAverage := fRUDisShCal(SRA->RA_MAT, Self:oAbsenceSettings:dFatherStartDateAbsence, .F., RUMap():New())
    EndIf

Return nAverage

/*/
{Protheus.doc} GetAbsenceSettings
    Getting settings for the calculated type of absence.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Object, Object of RUAbsenceTypeModel.
/*/
Method GetAbsenceSettings() Class RUDisabilityCalculation
    Local oSettings := RUAbsenceTypeModel():New(Self:cTypeAbsenceCode) As Object
Return oSettings

/*/
{Protheus.doc} GetRegionalFactor
    Getting the regional coefficient.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Numeric, Value of regional coefficient.
/*/
Method GetRegionalFactor() Class RUDisabilityCalculation
    Local nRFValue := 0 As Numeric // Regional coefficient.

    nRFValue := fRuGetRF(SRA->RA_DEPTO, SRA->RA_CC, /*QB_REGIAO*/,SRA->RA_ESTADO, SRA->RA_CODMUN)
    nRFValue := nRFValue * GET_VALUE_FROM_PERCENT

    If Type("oRU07XFU01") == "O"
        oRU07XFU01:nRegKoeff := nRFValue + 1
    EndIf

Return nRFValue

/*/
{Protheus.doc} GetMinimumWage
    Obtaining the minimum wage amount from S004.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Numeric, Value of minimum wage amount per day.
/*/
Method GetMinimumWage(lIsContinue) Class RUDisabilityCalculation
    Local nValue := 0 As Numeric
    Local aS004Lines := {} As Array
    Local nI := 0 As Numeric

    Default lIsContinue := Self:oAbsenceSettings:lIsContinue

    // Calculation minimum wage payment by day taking into account the month of absence.
    fCarrTab(@aS004Lines, "S004")

    If !lIsContinue
        For nI := 1 To Len(aS004Lines)
            If aS004Lines[nI][1] == "S004" .And. aS004Lines[nI][5] <= AnoMes(Self:oAbsenceSettings:dStartDate) .And. aS004Lines[nI][6] >= AnoMes(Self:oAbsenceSettings:dStartDate)
                nValue := aS004Lines[nI][7] * (1 + Self:GetRegionalFactor()) / Self:GetCountMonthDay(Self:oAbsenceSettings:dStartDate)
            EndIf
        Next nI
    Else
        For nI := 1 To Len(aS004Lines)
            If aS004Lines[nI][1] == "S004" .And. aS004Lines[nI][5] <= AnoMes(Self:oAbsenceSettings:dFatherStartDateAbsence) .And. aS004Lines[nI][6] >= AnoMes(Self:oAbsenceSettings:dFatherStartDateAbsence)
                nValue := aS004Lines[nI][7] * (1 + Self:GetRegionalFactor()) / Self:GetCountMonthDay(Self:oAbsenceSettings:dFatherStartDateAbsence)
            EndIf
        Next nI
    EndIf

Return nValue

/*/
{Protheus.doc} GetCountMonthDay
    Calculate days in month on input date.

    @type Method
    @param dInputDate, Date, Start date of absence
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
    @return Numeric, Days into month.
/*/
Method GetCountMonthDay(dInputDate) Class RUDisabilityCalculation
    Local nDays := 0 As Numeric
    Local nFutureMonth := Month(dInputDate) + 1 As Numeric
    Local nFutureYear := Year(dInputDate) As Numeric

    If nFutureMonth > 12
        nFutureMonth := 1
        nFutureYear := nFutureYear + 1
    EndIf

    nDays := SToD(StrZero(nFutureYear, 4) + StrZero(nFutureMonth, 2) + "01") - SToD(StrZero(Year(dInputDate), 4) + StrZero(Month(dInputDate), 2) + "01")

Return nDays

/*/
{Protheus.doc} GetMaxBase
    Calculate maximum permissible base value.

    @type Method
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
    @return Numeric, Days into month.
/*/
Method GetMaxBase() Class RUDisabilityCalculation
    Local nMaxBase := 0 As Numeric
    Local nTwoYearsDays := RU07XFUN32_GetAbsenceDays() As Numeric

    nMaxBase := (GetFSSLimit(AllTrim(Str(Val(Self:cCurrentYear) - 1)))+ GetFSSLimit(AllTrim(Str(Val(Self:cCurrentYear) - 2)))) / nTwoYearsDays

Return nMaxBase

/*/
{Protheus.doc} GetExperienceArray
    Obtaining coefficients of experience from S209.

    @type Method
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
    @return Array, Coefficients of experience array.
/*/
Method GetExperienceArray() Class RUDisabilityCalculation
    Local aExperience := {} As Array
    Local nI := 1
    Local cS209Content := fRUGetRccConteo("S209", "") As Character

    While nI < Len(AllTrim(cS209Content))
        aAdd(aExperience, Val(SubStr(cS209Content, nI, 6)))
        nI += 6
    EndDo

Return aExperience

/*/
{Protheus.doc} CreatePayments
    Creating payment types for payslips.

    @type Method
    @param nCompanyPayment, Numeric, Total payments by Company (from standard calculation + minimum wages).
    @param nCompanyDays, Numeric, Total days by company payments.
    @param nFSSPayment, Numeric, Total payments by FSS (from standard calculation + minimum wages).
    @param nFSSDays, Numeric, Total days by FSS payments.
    @author vselyakov
    @since 2023/11/09
    @version 12.1.33
    @return Null
/*/
Method CreatePayments(nCompanyPayment, nCompanyDays, nFSSPayment, nFSSDays) Class RUDisabilityCalculation

    If nCompanyDays > 0
        FGeraVerba(aCodFol[41, 1], nCompanyPayment, nCompanyDays)
    EndIf

    If nFSSDays > 0
        FGeraVerba(aCodFol[1752, 1], nFSSPayment, nFSSDays)
    EndIf

Return

/*/{Protheus.doc} GetMonthMinimumWage
    Calculate the monthly minimum wage for input date.

    @type Method
    @param dInputDate, Date, Date of absence for which the monthly minimum wage is calculated.
    @author vselyakov
    @since 2023/12/13
    @version 12.1.33
    @return Numeric, Amount
/*/
Method GetMonthMinimumWage(dInputDate) Class RUDisabilityCalculation
    Local nValue := 0 As Numeric
    Local aS004Lines := {} As Array
    Local nI := 0 As Numeric

    Default dInputDate := CToD("//")

    If !Empty(dInputDate)
        fCarrTab(@aS004Lines, "S004") // Load data from S004.

        For nI := 1 To Len(aS004Lines)
            If aS004Lines[nI][1] == "S004" .And. aS004Lines[nI][5] <= AnoMes(dInputDate) .And. aS004Lines[nI][6] >= AnoMes(dInputDate)
                nValue := aS004Lines[nI][7] * (1 + Self:GetRegionalFactor()) / Self:GetCountMonthDay(dInputDate)
            EndIf
        Next nI
    Else
        ConOut("Error in GetMonthMinimumWage: Variable dInputDate is not defined!")
    EndIf

Return nValue
