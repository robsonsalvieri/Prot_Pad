#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07XVAC.CH"

#DEFINE AVERAGE_MONTH_DAYS 29.3
#DEFINE AV_BASE_FOR_MONTH "71" + CHR(208)
#DEFINE STD_VAC_DAYS_YEAR 28
#DEFINE STD_VAC_DAYS_MONTH 2.33

#DEFINE VACATION_TYPE_PAYMENT "121"

#DEFINE COD_PAYMENT_INDEX 1 // For example, aPd[nI][1] = "675".
#DEFINE SUM_PAYMENT_INDEX 5 // For example, aPd[nI][5] = 234.56.

#DEFINE WAGE_TYPE_PAYMENT "1"          // RV_TIPOCOD = "Yes".
#DEFINE IS_VACATION_CALCULATE "S"      // RV_REFFER = "Yes".
#DEFINE IS_NDFL_VACATION_CALCULATE "1" // RV_INSSFER = "Yes".
#DEFINE NOT_TAXABLE_PAYMENT "N"        // RV_IR = "No"

#DEFINE COUNT_DAY_FOR_CALC_MOUNTH 15
#DEFINE COUNT_ALL_MOUNTH_FOR_CALC_KNO 12

/*/{Protheus.doc} RU07XVAC01_fGetMonthDays(cMonth As Char)
    Returns number of days per period (month)

    @type Function
    @params cMonth,    Char,       Required period (YYYYMM)
    @return nDays,     Numeric,    Number of days
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Function RU07XVAC01_fGetMonthDays(cMonth As Char)
    Local nDays As Numeric

    DbSelectArea("RCH")
    DbSetOrder(9) // RCH_FILIAL + RCH_PER + RCH_NUMPAG + RCH_PROCES + RCH_ROTEIR + RCH_PERSEL

    If MsSeek(FWXFilial("RCH") + cMonth)
        nDays := Day(RCH->RCH_DTFIM) - Day(RCH->RCH_DTINI) + 1
    EndIf

Return nDays

/*/{Protheus.doc} RU07XVAC02_GetSRCAvRecords(cMat As Char, cLastPeriod As Char, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, @oMonths As Object)
    Fills transfered oMonths hashmap with information from SRC (opened period) table about average days and average payments.

    @type Function
    @params cMat,             Char,     Employee's Reg. Number (RA_MAT)
    @params cLastPeriod,      Char,     Last payment period required for vacation calculation ("YYYYMM")
    @params cAvDaysCodFol,    Char,     Budget (RV_COD) for average days count
    @params cAvMoneyCodFol,   Char,     Budget (RV_COD) for average money count
    @params oMonths,          Object,   RUMap instance to be filled with payments information
    @return
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Function RU07XVAC02_GetSRCAvRecords(cMat As Char, cLastPeriod As Char, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, oMonths As Object)
    Local aSavedArea := GetArea()
    Local aValues := {}
    Local cQuery As Char
    Local cAlias As Char

    cQuery := " SELECT RC_PD, RC_VALOR, RC_PERIODO FROM " + RetSQLName("SRC") + " WHERE "
    cQuery += " RC_FILIAL = ? "
    AAdd(aValues, FWxFilial("SRC"))
    cQuery += " AND RC_MAT = ? "
    AAdd(aValues, cMat)
    cQuery += " AND RC_PD IN (?, ?) "
    AAdd(aValues, cAvDaysCodFol)
    AAdd(aValues, cAvMoneyCodFol)
    cQuery += " AND RC_PERIODO = ? "
    AAdd(aValues, cLastPeriod)
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cAlias := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAlias, .T., .F.)

    DbSelectArea(cAlias)
    While !EoF() 
        If (cAlias)->RC_PD == cAvDaysCodFol
            oMonths:GetValue((cAlias)->RC_PERIODO)[1] := (cAlias)->RC_VALOR
        ElseIf (cAlias)->RC_PD == cAvMoneyCodFol
            oMonths:GetValue((cAlias)->RC_PERIODO)[2] := (cAlias)->RC_VALOR
        EndIf
        DbSkip()
    EndDo

    DbCloseArea()
    RestArea(aSavedArea)

Return

/*/{Protheus.doc} RU07XVAC03_GetSRDAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, @oMonths As Object)
    Fills transfered oMonths hashmap with information from SRD (closed periods) table about average days and average payments.

    @type Function
    @params cMat,             Char,     Employee's Reg. Number (RA_MAT)
    @params aPeriods,         Array,    Payments periods ("YYYYMM")
    @params cAvDaysCodFol,    Char,     Budget (RV_COD) for average days count
    @params cAvMoneyCodFol,   Char,     Budget (RV_COD) for average money count
    @params oMonths,          Object,   RUMap instance to be filled with payments information
    @return
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Function RU07XVAC03_GetSRDAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, oMonths As Object)
    Local aSavedArea := GetArea()
    Local aValues := {}
    Local cQuery As Char
    Local cAlias As Char

    cQuery := " SELECT RD_VALOR, RD_PD, RD_PERIODO FROM " + RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND RD_PD IN (?, ?) "

    AAdd(aValues, FWxFilial("SRD"))
    AAdd(aValues, cMat)
    AAdd(aValues, cAvDaysCodFol)
    AAdd(aValues, cAvMoneyCodFol)

    cQuery += " AND RD_PERIODO IN (" + RusSetQryIn(aPeriods, @aValues) + ") "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    cAlias := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAlias, .T., .F.)

    DbSelectArea(cAlias)
    While !EoF() 
        If (cAlias)->RD_PD == cAvDaysCodFol
            oMonths:GetValue((cAlias)->RD_PERIODO)[1] := (cAlias)->RD_VALOR
        ElseIf (cAlias)->RD_PD == cAvMoneyCodFol
            oMonths:GetValue((cAlias)->RD_PERIODO)[2] := (cAlias)->RD_VALOR
        EndIf
        DbSkip()
    EndDo

    DbCloseArea()
    RestArea(aSavedArea)

Return

/*/{Protheus.doc} RU07XVAC04_fGetAvMonthDays()
    Returns average monthly number of calendar days per year (S208 table)

    @type Function
    @params
    @return nDays,    Numeric,    Average number of days (by government decree)
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Function RU07XVAC04_fGetAvMonthDays()
    Local nDays := 0 As Numeric
    Local nLinePosition := 0 As Numeric
    Local cPeriod := "" As Character

    If Empty(cPeriodo)
        cPeriod := GetPeriodCalc() // This function using into S_CARGARCH for cPeriodo mnemonic.
    Else
        cPeriod := cPeriodo
    EndIf

    /*
        Into S208 table using next columns:
        * 4 - ANOMESI, Character, Start period code (example, "201801")
        * 5 - ANOMESF, Character, End period code (example, "201812")
        * 6 - RUSS20803, Numeric, Value of vacation day (example, "29.3")
    */
    nDays := 29.3 // Set default value.
    nLinePosition := fPosTab("S208", cPeriod, ">=", 4, cPeriod, "<=", 5)
    
    // If line in S208 does not exist for current period then using default value.
    If nLinePosition > 0
        nDays := fTabela("S208", nLinePosition, 6) // Get value of vacation days.
    EndIf

Return nDays

/*/{Protheus.doc} RU07XVAC05_fRUAverCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Returns average employee earnings per day for the previous period (12 months)

    @type Function
    @params cMat,          Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate      Date,       Date for calculating average earnings for the previous period (12 months)
            oMonths        Object      Output RUMap with calendar days without absences & receiving AV-payments per period
    @return nAverValue,    Numeric,    Average employee earnings per day for the previous period (12 months)
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Function RU07XVAC05_fRUAverCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Local aMonth As Array
    Local cMonth As Char
    Local nI As Numeric
    Local nAverValue As Numeric
    Local nAverMonthDays As Numeric
    Local nAverDays := 0
    Local nAverMoney := 0
    Local aMonths := {}

    Local cRUSAvDaysCodFol := aCodFol[1748, 1]
    Local cRUSAvMoneyCodFol  := aCodFol[1749, 1]

    Local nBaseYear := Year(dBaseDate)
    Local nBaseMonth := Month(dBaseDate)

    nAverMonthDays := RU07XVAC04_fGetAvMonthDays()

    // Fill aray by previous periods (months)
    For nI := 1 To 12
        nBaseMonth -= 1

        If nBaseMonth == 0
            nBaseMonth := 12
            nBaseYear -= 1
        EndIf

        cMonth := Str(nBaseYear, 4) + StrZero(nBaseMonth, 2)

        AAdd(aMonths, cMonth)
        oMonths:Set(cMonth, {0, 0})
    Next nI

    // Check payments from opened period
    RU07XVAC02_GetSRCAvRecords(cMat, aMonths[1], cRUSAvDaysCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Check payments from closed periods
    RU07XVAC03_GetSRDAvRecords(cMat, aMonths, cRUSAvDaysCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Calculate average values
    oMonths:List(aMonths)
    For nI := 1 To Len(aMonths)
        cMonth := aMonths[nI][1]
        aMonth := aMonths[nI][2]

        If aMonth[1] == 0 .And. aMonth[2] == 0
            oMonths:Del(cMonth)
        Else
            nAverDays += nAverMonthDays * aMonth[1] / RU07XVAC01_fGetMonthDays(cMonth)
            nAverMoney += aMonth[2]
        EndIf
    Next nI

    nAverValue := nAverMoney / nAverDays

Return nAverValue

/*/{Protheus.doc} RU07XVAC06_CalculationVacantion(cMat, dDateStart, oMonths)
    The function calculates the average salary per day for the specified employee (cMat)
    taking into account the presence (or absence) of hours worked / accrued wages.
    Used to calculate vacation.

    @type Function
    @params cMat,        Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate,   Date,       Date for calculating average earnings for the previous period (12 months)
            oMonths,     Object      Output RUMap with calendar days without absences & receiving AV-payments per period
    @return nAverSalary, Numeric,    Average employee earnings per day.
    @author vselyakov
    @since 2021/04/12
    @version 12.1.23
    @example RU07XVAC06_CalculationVacantion(SRA->RA_MAT, GetMemVar("RH_DATAINI"), RUMap():New())
*/
Function RU07XVAC06_CalculationVacantion(cMat As Char, dBaseDate As Date, oMonths As Object)
    Local nAverSalary    As Numeric // Average employee earnings per day.
    Local nAbsenceDays   As Numeric // Count of absence days.
    Local nSumSalary     As Numeric // Salary for worked days.
    Local cQuery         As Character
    Local lIsCalcPrev    As Logical // Shows whether the calculation was in the period.
    Local cPrevYearStart As Character // Date of (dBaseDate - 1 year) in format "YYYYMMDD".
    Local aArea          As Array
    Local aValues        As Array
    Local dDataini       As Date // If function call in calculation dismiss == dBaseDate

    aArea := GetArea()
    aValues := {}
    nAverSalary := 0
    lIsCalcPrev := .F.
    cPrevYearStart := CValToChar((Year(dBaseDate) - 1)) + Substr(DToS(dBaseDate), 5, 4)

    dDataini := Iif(IsInCallStack("S_CFERPROP"), dBaseDate, M->RH_DATAINI)

    // We look at 71R per year. If there is, then the calculation is standard.
    // Look this into SRD table.
    cQuery := " SELECT COUNT(*) AS LNT FROM " + RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND RD_PD = ? "
    cQuery += " AND (RD_DATARQ BETWEEN ? AND ?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    AAdd(aValues, FWxFilial("SRD"))
    AAdd(aValues, cMat)
    AAdd(aValues, AV_BASE_FOR_MONTH)
    AAdd(aValues, cPrevYearStart)
    AAdd(aValues, DToS(dBaseDate))

    cAlias := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAlias, .T., .F.)

    DbSelectArea(cAlias)
    DbGoTop()
    lIsCalcPrev := ((cAlias)->LNT > 0)

    DbCloseArea()

    If (SRA->RA_ADMISSA == dDataini)
        // There were no recorded payments and days worked at all.
        If SRA->RA_CATFUNC == "H"
            nAverSalary := (SALDIA * aPeriodo[1][6] / AVERAGE_MONTH_DAYS)
        Else
            nAverSalary := (SRA->RA_SALARIO / AVERAGE_MONTH_DAYS)
        EndIf
    ElseIf ((Year(SRA->RA_ADMISSA) == Year(dDataini)) .And. (Month(SRA->RA_ADMISSA) == Month(dDataini)))
        // Payments and days worked were in the month of the start of the vacation.
        nSumSalary := RU07XVAC12_CalculationSalaryByPer(cMat, SRA->RA_ADMISSA, dDataini - 1)
        nAbsenceDays := RU07XFUN23_GetNumberDayAbsenceByPeriod(cMat, SRA->RA_ADMISSA, dDataini - 1)
        nAverSalary := nSumSalary / ((AVERAGE_MONTH_DAYS / aPeriodo[1][18]) * (dDataini - SRA->RA_ADMISSA - nAbsenceDays))
    ElseIf !lIsCalcPrev
        // Payments and days worked were before the billing period.
        nAverSalary := RU07XVAC05_fRUAverCalc(cMat, STOD(cPrevYearStart), oMonths)
    Else
        // Standart calculation.
        nAverSalary := RU07XVAC05_fRUAverCalc(cMat, dBaseDate, oMonths)
    EndIf

    RestArea(aArea)

Return nAverSalary

/*/{Protheus.doc} RU07XVAC07_CalculationVacationDay(dBaseStart, dBaseEnd)
    The function calculates the number of accumulated vacation days for the specified period.

    @type Function
    @params dBaseStart,   Date, Period start date.
            dBaseEnd,     Date, Period end date.
            nCountDay, Numeric, Count all day for proporcional.
    @return nVacDays, Numeric, Count of vactions day.
    @author vselyakov
    @since 05.05.2021
    @version 12.1.23
    @example RU07XVAC07_CalculationVacationDay(SRA->RA_ADMISSA, SRF->RF_DATAFIM)
*/
Function RU07XVAC07_CalculationVacationDay(dBaseStart As Date, dBaseEnd As Date, nCountDay As Numeric)
    Local nVacDays       As Numeric
    Local nMonthCount    As Numeric
    Local dFinalDayMonth As Date
    Local nCountD        As Numeric

    Default nCountDay := -1

    nVacDays := 0
    dFinalDayMonth := SToD(AnoMes(dBaseStart) + StrZero(RU07XFUN05_GetMonthSize(Month(dBaseStart), Year(dBaseStart)), 2))
    nCountD := Iif(nCountDay >= 0, nCountDay, STD_VAC_DAYS_YEAR)

    If (SubStr(DToC(dBaseStart), 1, 5) == "01.01" .And. SubStr(DToC(dBaseEnd), 1, 5) == "31.12" .And. Year(dBaseStart) == Year(dBaseEnd))
        nVacDays := nCountD
    Else
        nMonthCount := Month(dBaseEnd) - Month(dBaseStart)

        // The rule of 15 days.
        If (dFinalDayMonth - dBaseStart >= 15)
            nMonthCount += 1 // Add one month.
        EndIf

        nVacDays := nCountD * nMonthCount / 12
    EndIf

    // Rounding down because the employee hasn't worked a full day yet.
    // If nMonthCount = 12 (according to the rule of 15 days) then round up.
    If (nMonthCount == 12)
        nVacDays := Round(nVacDays, 0)
    Else
        nVacDays := NoRound(nVacDays, 0)
    EndIf

Return nVacDays

/*/{Protheus.doc} RU07XVAC08_CalculationPaymentsDay()
    Calculation of the number of paid vacation days. 
    Writes data to a vacation schedule in a field RF_DFERANT.

    @type Function
    @params nOperation, Numeric, Type of operation (Update, Delete).
    @return
    @author vselyakov
    @since 13.10.2021
    @version 12.1.33
    @example RU07XVAC08_CalculationPaymentsDay(nOperacao)
             RU07XVAC08_CalculationPaymentsDay(MODEL_OPERATION_DELETE)
*/
Function RU07XVAC08_CalculationPaymentsDay(nOperation)
    Local nDays          As Numeric
    Local aArea          As Array

    aArea := GetArea()
    nDays := 0

    DbSelectArea("SRF")
    SRF->(DbSetOrder(1)) // RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD

    If nOperation == MODEL_OPERATION_UPDATE // Vacation calculation.

        // Write nDays to RF_DFERANT
        If SRF->(DbSeek(FwXFilial("SRF") + SRH->RH_MAT + DToS(SRH->RH_DATABAS)))
            RecLock("SRF",.F.,.T.)
            SRF->RF_DFERANT := SRF->RF_DFERANT + SRH->RH_DFERIAS + SRH->RH_DABONPE
            SRF->RF_DVENPEN := SRF->RF_DFERVAT - SRF->RF_DFERANT
            SRF->(MsUnLock())
        EndIf

    ElseIf nOperation == MODEL_OPERATION_DELETE // Cancellation of vacation calculation.

        If SRF->(DbSeek(FwXFilial("SRF") + SRH->RH_MAT + DToS(SRH->RH_DATABAS)))
            RecLock("SRF",.F.,.T.)
            SRF->RF_DFERANT := SRF->RF_DFERANT - SRH->RH_DFERIAS - SRH->RH_DABONPE
            SRF->RF_DVENPEN := SRF->RF_DFERVAT - SRF->RF_DFERANT
            SRF->(MsUnLock())
        EndIf

    EndIf

    RestArea(aArea)

Return

/*/{Protheus.doc} RU07XVAC09_VacationHasBeenCalculated()
    Shows whether vacation has already been calculated.

    @type Function
    @params cNumberEmployee, Character, Employee number.
            dStartVacation, Date, Date of start vacation.
    @return lIsCalculated, Logical, .T. - vacation is calculated.
    @author vselyakov
    @since 10.11.2021
    @version 12.1.33
    @example !RU07XVAC09_VacationHasBeenCalculated(RF_MAT, SRF->RF_DATAINI)
*/
Function RU07XVAC09_VacationHasBeenCalculated(cNumberEmployee, dStartVacation)
    Local lIsCalculated As Logical
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character

    aArea := GetArea()
    lIsCalculated := .F.

    cQuery := " SELECT COUNT(*) AS ISEXIST FROM " + RetSqlName("SRR")
    cQuery += " WHERE "
    cQuery += " RR_FILIAL = ? "
    cQuery += " AND RR_MAT = ? "
    cQuery += " AND RR_PD = ? "
    cQuery += " AND RR_DATA = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRR"))
    oStatement:SetString(2, cNumberEmployee)
    oStatement:SetString(3, VACATION_TYPE_PAYMENT)
    oStatement:SetString(4, DToS(dStartVacation))

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    lIsCalculated := (cTab)->ISEXIST > 0

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return lIsCalculated

/*/{Protheus.doc} RU07XVAC10_IsNewFieldSRFExist()
    Checking for the existence of new fields in SRF:
    RF_DATINI4
    RF_DATINI5
    RF_DATINI6
        
    @type Function
    @params cFieldName, Character, Name of field.
    @return lIsExist, Logical, .T. - field is exist.
    @author vselyakov
    @since 12.11.2021
    @version 12.1.33
    @example RU07XVAC10_IsNewFieldSRFExist("RF_DATINI4")

*/
Function RU07XVAC10_IsNewFieldSRFExist(cFieldName)

    Local lIsExist As Logical
    Local aArea    As Array

    Default cFieldName := "RF_DATINI4"

    aArea := GetArea()

    lIsExist := .F.

    lIsExist := ChkFile('SRF') .And. SRF->(ColumnPos(cFieldName)) > 0

    RestArea(aArea)

Return lIsExist

/*/{Protheus.doc} RU07XVAC11_AvailableVacationDays(cBranch, cMat, cPd)
    
    Counts the available vacation days accumulated from active periods
        
    @type Function
    @params cBranch, Character, Branch
    @params cMat,    Character, Employee's registration number
    @params cPd,     Character, Line Item Code
    @return nCounAvailableVacDays, Numeric, Count available vacation days.
    @author dchizhov
    @since 05.03.2022
    @version 12.1.33
    @example RU07XVAC11_AvailableVacationDays("102030", "000013", "121")

*/
Function RU07XVAC11_AvailableVacationDays(cBranch, cMat, cPd)

    Local nCountAvailableVacDays := 0                As Numeric
    Local aArea                  := GetArea()        As Array
    Local aAreaSRF               := SRF->(GetArea()) As Array
    Local cSRFSeek                                   As Character
    Local nCurrentYear           := Year(Date())     As Numeric

    cSRFSeek := cBranch + cMat + cPD

    DbSelectArea('SRF')
    DbSetOrder(2)
    If(DbSeek(cSRFSeek))
        While SRF->(!Eof() .And. RF_FILIAL + RF_MAT + RF_PD == cSRFSeek )
            If SRF->RF_STATUS == "1" .And. Year(SRF->RF_DATABAS) <= nCurrentYear
                nCountAvailableVacDays += SRF->RF_DVENPEN
            EndIf
            DbSkip()
        EndDo
    EndIf
    DbCloseArea()

    SRF->(RestArea(aAreaSRF))
    RestArea(aArea)

Return nCountAvailableVacDays

/*/{Protheus.doc} RU07XVAC12_CalculationSalaryByPer(cMat, dStartDate, dEndDate)
    A function that calculates the salary for an employee for a period, taking into account 
    the history of the salary and changes in the functional category

    @type Function
    @params cMat, Character, Tab number
    @params dStartDate, Date, The beginning of the period for which the average is calculated
    @params dEndDate,   Date, The end of the period for which the average is calculated
    @return Nil
    @author dchizhov
    @since 2022/10/17
    @version 12.1.23
    @example RU07XVAC12_CalculationSalaryByPer(cMat, SRA->RA_ADMISSA, dDataini - 1)
*/
Function RU07XVAC12_CalculationSalaryByPer(cMat, dStartDate, dEndDate)
    Local aArea        As Array
    Local nResult := 0 As Numeric   // Calculated salary.
    Local nRA_HRSDIA   As Numeric   // Number of hours per day for an employee.
    Local nR3_VALOR    As Numeric   // New value of salary.
    Local nR3_ANTEAUM  As Numeric   // Old value of salary
    Local dR3_DATA     As Date      // Date of changes of salary.
    Local nAftWrkDays  As Numeric   // Amount of working days with disable days after change category.
    Local nBfrWrkDays  As Numeric   // Amount of working days with disable days before change category.
    Local cOldCatfunc  As Character // Old employee functional category.
    Local cNewCatfunc  As Character // New employee functional category.
    Local cQuery       As Char
    Local cQueryResult As Char
    Local aValues      := {}
    Local nI           As Numeric
    Local dBefore      As Date

    aArea := GetArea()
    nResult := 0

    dR3_DATA := dStartDate
    nR3_VALOR := SRA->RA_SALARIO

    // Get data for calculating.
    cNewCatfunc := SRA->RA_CATFUNC // Employee category code.
    cOldCatfunc := SRA->RA_CATFUNC // Employee category code.
    nRA_HRSDIA  := SRA->RA_HRSDIA // Number of hours per day for an employee.

    // Get data for calculating with changes of the salary for a month. Checking the date of change of salary.
    // If date of change enter into calculation period then We must take into account the new rate.
    // Else - get value from SALMES mnemonic (it is calculate the salary on new value of salary without old salary).

    aSalaryChange := StaticCall(RU07XFUN, GetSalaryChange, cMat, dStartDate, dEndDate)

    If Len(aSalaryChange) > 0
        lIsChanged  := .T.
        dR3_DATA    := aSalaryChange[1][1] // Date of changes of salary.
        nR3_VALOR   := aSalaryChange[1][2] // New value of salary.
        nR3_ANTEAUM := aSalaryChange[1][3] // Old value of salary.
    EndIf

    // Search for a change in the functional category of an employee and remember old category.
    cQuery := "SELECT R7_CATFUNC FROM " + RetSQLName("SR7") + " WHERE "
    cQuery += "R7_FILIAL = ? AND "
    cQuery += "R7_MAT = ? AND "
    cQuery += "R7_DATA < ? AND "
    cQuery += "D_E_L_E_T_ = ' ' "
    cQuery += "ORDER BY R7_DATA DESC "

    AAdd(aValues, FWxFilial("SR7"))
    AAdd(aValues, cMat)
    AAdd(aValues, DtoS(dR3_DATA))

    dBefore := dStartDate

    For nI := 1 To Len(aSalaryChange)
        dR3_DATA    := aSalaryChange[nI][1] // Date of changes of salary.
        nR3_VALOR   := aSalaryChange[nI][2] // New value of salary.
        nR3_ANTEAUM := aSalaryChange[nI][3] // Old value of salary.
        If dStartDate == dR3_DATA
            dBefore := dR3_DATA
            Loop
        EndIf

        aValues[3] := DtoS(dR3_DATA)
        cQueryResult := GetNextAlias()
        DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cQueryResult, .T., .F.)

        DBSelectArea(cQueryResult)
        If !EoF()
            cOldCatfunc := (cQueryResult)->R7_CATFUNC
        EndIf
        DbCloseArea()

        // Calculating the number of days worked by category.
        nBfrWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cMat, dBefore, dR3_DATA - 1)

        // Calculate salary on old fuctional category.
        Do Case
            Case (cOldCatfunc == "H") // Hourly employee.
                nResult += nR3_ANTEAUM * (nBfrWrkDays * nRA_HRSDIA)
            Case (cOldCatfunc == "M") // Employee with monthly pay.
                nResult += ((nR3_ANTEAUM / aPeriodo[1][6]) * nBfrWrkDays)
        EndCase

        dBefore := dR3_DATA

    Next nI
        
    nAftWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cMat, dR3_DATA, dEndDate)

    // Calculate salary on new fuctional category.
    Do Case
        Case (cNewCatfunc == "H") // Hourly employee.
            nResult += nR3_VALOR * (nAftWrkDays * nRA_HRSDIA)
        Case (cNewCatfunc == "M") // Employee with monthly pay.
            nResult += ((nR3_VALOR / aPeriodo[1][6]) * nAftWrkDays)
    EndCase

    RestArea(aArea)

Return nResult

/*/{Protheus.doc} RU07XVAC13_CalculationNDFLVacation()
    Function for vacation NDFL calculation.

    @type Function
    @params cNumberEmployee, Character, Employee number.
            dStartVacation, Date, Date of start vacation.
    @return lIsCalculate, Logical, .T. - NDFL vacation is calculated.
    @author vselyakov
    @since 17.08.2023
    @version 12.1.33
    @example RU07XVAC13_CalculationNDFLVacation()
*/
Function RU07XVAC13_CalculationNDFLVacation()
    Local nI := 0 As Numeric
    Local lIsCalculate := .F. As Logical

    /* If into aPd there are payments with next conditions:
     *      RV_REFFER = 'S' 
     *      RV_INSSFER = 'S' 
     *      RV_TIPOCOD = '1'
     *      RV_IR = 'N'
     *      Payment value > 0
     * then we calculation NDFL for vacations. In other case - not calculating.
     *
     * May be need one more condition:
     * .And. aPd[nI][SUM_PAYMENT_INDEX] > 0
    */
    For nI := 1 To Len(aPd)
       If RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == IS_VACATION_CALCULATE ;
            .And. RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_INSSFER") == IS_NDFL_VACATION_CALCULATE ;
            .And. RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
            .And. RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_IR") == NOT_TAXABLE_PAYMENT;

            lIsCalculate := .T.
       EndIf
    Next nI

    /*
     * If personal income tax is calculated (lIsCalculate == true), 
     * then the function for calculating personal income tax for wages is called.
    */
    If lIsCalculate
        RU07NDFL01_CalculateNDFL() // Function in source "RU07XNDFL".
    EndIf

Return lIsCalculate

/*/{Protheus.doc} RU07XVAC14GetDFALAATVacLast(dDateFin, dDateStart)

    Function for get value RF_DFALAAT of last period.

    @type Function
    @params dDateFin,   Date, Finish current vac period.
    @params dDateStart, Date, Start current vac period.
    @return nCountDay, Numeric, Last period value.
    @author dchizhov
    @since 25.03.2024
    @version 12.1.23.10
    @example SRF->RF_DFALAAT := RU07XVAC14GetDFALAATVacLast(Min(dDataAte, SRF->RF_DATAFIM), Max(SRA->RA_ADMISSA, SRF->RF_DATABAS))
*/
Function RU07XVAC14GetDFALAATVacLast(dDateFin, dDateStart)

    Local nCountDay As Numeric
    Local nCountShr As Numeric
    Local aArea     As Array
    Local aSRFArea  As Array
    Local cKey      As Character
    Local cPD       As Character

    aArea := GetArea()

    nCountDay := 0
    nCountShr := SRF->RF_DFALVAT

    If SRA->RA_ADMISSA < SRF->RF_DATABAS
        aSRFArea := SRF->(GetArea())
        cKey := SRF->RF_FILIAL + SRF->RF_MAT 
        cPd  := SRF->RF_PD
        DbSelectArea("SRF")
        SRF->(DbSetOrder(RetOrdem("SRF", "RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)+RF_PD")))
        SRF->(DbSkip(-1))
        If cKey == SRF->RF_FILIAL + SRF->RF_MAT  .And. cPd == SRF->RF_PD .And. SRF->RF_DATABAS >= SRA->RA_ADMISSA
            nCountDay := SRF->RF_DFALAAT
        EndIf
        SRF->(RestArea(aSRFArea))
    EndIf 

    RestArea(aArea)
    nCountDay += Iif(dDateFin > dDateStart, dDateFin - dDateStart, 0) + 1
    nCountDay -= nCountShr

Return nCountDay

/*/{Protheus.doc} RU07XVAC14GetDFERAATLastPer(dDataFin)

    Function for calculating allotted vacation days in the current year.

    @type Function
    @params dDataPFin, Date, Date of end vacation period vac period.
    @params nDiasD, Numeric, Count of all allotted day in vacation period.
    @return nCountDay, Numeric, .T. - NDFL vacation is calculated.
    @author dchizhov
    @since 25.03.2024
    @version 12.1.23.10
    @example RU07XVAC13_CalculationNDFLVacation()
*/
Function RU07XVAC15GetDFERAATVacPer(dDataPFin, nDiasD, dVIni, dVFin)

    Local nCountM   As Numeric
    Local nCountDay As Numeric
    Local nCountAbs As Numeric
    Local nCountDAb As Numeric
    Local nItemAbsT As Numeric
    Local nItemAbsD As Numeric
    Local nDayInPer As Numeric
    Local nItem     As Numeric
    Local nX        As Numeric
    Local dDat1Calc As Date
    Local dDat2Calc As Date
    Local dDatIterS As Date
    Local aPerForCh As Array
    Local aArea     As Array
    Local aAbsArray As Array
    Local aTypeAbs  As Array
    Local aNTypeAbs As Array
    Local cPerIter  As Character
    Local cPerMax   As Character
    Local lIgnorPer As Logical

    Default dVIni := SRF->RF_DATABAS
    Default dVFin := SRF->RF_DATAFIM

    lIgnorPer := .F.

    aArea := GetArea()
    dDat1Calc := Max(SRA->RA_ADMISSA, dVIni)
    dDat2Calc := Min(dVFin, dDataPFin)
    // aTypeAbs := RU07XFUN42_GetS219Table(, Year(dVFin))

    cPerIter := AnoMes(dDat1Calc)
    cPerMax := AnoMes(dDat2Calc)
    // aAbsArray := RU07XFUN43_GetAbsShrinkKNOExper(dDat1Calc, dDat2Calc, , , aTypeAbs)

    nCountM := 0

    While cPerIter <= cPerMax
        If Val(SubStr(cPerIter, 5, 2)) > 12
            cPerIter := Soma1(SubStr(cPerIter, 1, 4)) + "01"
            Loop
        EndIf
        fCarPeriodo(cPerIter, cRoteiro, @aPerForCh, .T., 1, , xFilial("RCH", SRA->RA_FILIAL))
        If Len(aPerForCh) == 0
            If !IsBlind()
                If MsgYesNo(STR0001 + " '" + cPerIter + "' " + STR0002 + " '" + cRoteiro + "' " + STR0006 + " '" + SRA->RA_PROCES + "'. " + STR0003) // "It was not possible to obtain information for the period:", "scenario:", "process:", "Should ignore this period when calculating the value for RF_DFERAAT?"
                    lIgnorPer := .T.
                Else
                    lIgnorPer := .F.
                EndIf
            Else
                lIgnorPer := .F.
            EndIf
            If lIgnorPer
                lIgnorPer := .F.
                cPerIter := Soma1(cPerIter)
                Loop
            Else
                UserException(STR0001 + " '" + cPerIter + "' " + STR0002 + " '" + cRoteiro + "' " + STR0007 + " '" + SRA->RA_MAT + "'.") // "There is no information for the period:",  "for scenario:", "for employee:"
            EndIf
        EndIf
        dDatIterS := Max(aPerForCh[1, 3], SRA->RA_ADMISSA)
        nDayInPer := aPerForCh[1, 4] - dDatIterS + 1
        aNTypeAbs := RU07XFUN42_GetS219Table(dDatIterS)
        For nX := 1 To Len(aNTypeAbs)
            nItem := aScan(aTypeAbs, {|X| X[1] == aNTypeAbs[nX, 1] .And. X[2] == aNTypeAbs[nX, 2] .And. X[3] == aNTypeAbs[nX, 3]})
            If nItem > 0
                aNTypeAbs[nX, 4] := aTypeAbs[nItem, 4]
            EndIf 
        Next nX

        aTypeAbs := aNTypeAbs
        aAbsArray := RU07XFUN43_GetAbsShrinkKNOExper(dDatIterS, aPerForCh[1, 4], , , aTypeAbs)
        nItemAbsT := AScan(aAbsArray, {|X| X[2] >= dDatIterS .And. X[2] <= aPerForCh[1, 4] .Or. X[1] >= dDatIterS .And. X[1] <= aPerForCh[1, 4] .Or. X[1] <= dDatIterS .And. X[2] >= aPerForCh[1, 4]})
        nCountAbs := 0
        If nItemAbsT > 0
            While aAbsArray[nItemAbsT, 2] >= dDatIterS .And. aAbsArray[nItemAbsT, 2] <= aPerForCh[1, 4] .Or. ;
            aAbsArray[nItemAbsT, 1] >= dDatIterS .And. aAbsArray[nItemAbsT, 1] <= aPerForCh[1, 4] .Or. ;
            aAbsArray[nItemAbsT, 1] <= dDatIterS .And. aAbsArray[nItemAbsT, 2] >= aPerForCh[1, 4]
                nItemAbsD := AScan(aTypeAbs, {|X| X[1] <= cPerIter .And. X[2] >= cPerIter .And. X[3] == aAbsArray[nItemAbsT, 3]})
                If nItemAbsD > 0
                    nCountDAb := Min(aPerForCh[1, 4], aAbsArray[nItemAbsT, 2]) - Max(dDatIterS, aAbsArray[nItemAbsT, 1]) + 1
                    If nCountDAb > aTypeAbs[nItemAbsD, 4]
                        nCountDAb -= aTypeAbs[nItemAbsD, 4]
                        aTypeAbs[nItemAbsD, 4] := 0
                    Else
                        aTypeAbs[nItemAbsD, 4] -= nCountDAb
                        nCountDAb := 0
                    EndIf
                    nCountAbs += nCountDAb
                EndIf
                nItemAbsT += 1
                If nItemAbsT > Len(aAbsArray)
                    Exit
                EndIf
            EndDo
        EndIf
        nDayInPer -= nCountAbs
        nCountM += Iif(nDayInPer >= COUNT_DAY_FOR_CALC_MOUNTH, 1, 0)
        cPerIter := Soma1(cPerIter)
    EndDo

    nCountDay := (nDiasD / COUNT_ALL_MOUNTH_FOR_CALC_KNO) * nCountM
    RestArea(aArea)

Return nCountDay

/*/{Protheus.doc} RU07XVAC16GetDFERVATDVENPENFromGrid(cMode)

    Function for calculating value for dfervat and dvenpen from modelgrid.

    @type Function
    @params cMode, Character, Type of value which need (default = "1").
    @return nCount, Numeric, Value for dferant or dvenpen.
    @author dchizhov
    @since 13.05.2024
    @version 12.1.23.10
    @example RU07XVAC16()
*/
Function RU07XVAC16GetDFERVATDVENPENFromGrid(cMode)

    Local nCount As Numeric
    Local xTemp1
    Local xTemp2

    Default cMode := "1"

    nCount := 0

    If cMode == "1"
        xTemp1 := FwFldGet("RF_DATABAS")
        xTemp2 := FwFldGet("RF_DATAFIM")
        If !Empty(xTemp1) .And. !Empty(xTemp2)
            nCount := RU07XVAC07_CalculationVacationDay(xTemp1, xTemp2, FwFldGet("RF_DIASDIR"))
        EndIf
    ElseIf cMode == "2"
        xTemp1 := FwFldGet("RF_DATABAS")
        xTemp2 := FwFldGet("RF_DATAFIM")
        If !Empty(xTemp1) .And. !Empty(xTemp2)
            nCount := FwFldGet("RF_DFERVAT") - FwFldGet("RF_DFERANT")
        EndIf
    EndIf

return nCount
