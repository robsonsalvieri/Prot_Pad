#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07XFUN.CH"

#DEFINE COD_TYPE_OF_EXPERIENCE_FOR_ABCENSE "02"
#DEFINE COUNT_DAY_FOR_EXPERIENCE_CALC 10
#DEFINE COUNT_MONTH_MIN_FOR_NOT_MROT 6
#DEFINE KOEFF_FOR_CALC_HOSPITAL 0.5

#DEFINE CATEGORY_MOUNTH "M"
#DEFINE CATEGORY_HOURS "H"

#DEFINE CALC_AVERAGE_FOR_SIM_REALIZE "1767|1768""

/*/
{Protheus.doc} RUInsurancePremiumReport
    Class for generating a Insurance premium report.

    @type Class
    @author dchizhov
    @since 2022/12/06
    @version 12.1.33
/*/
Class RUCalcAbsenceType From LongNameClass

    Data cTypeOfAbsence As Character // Type of absence
    Data cPaymentType   As Character // Payment type
    Data cPaymentID     As Character // ID
    Data dStartAbsence  As Date      // Date of start absence
    Data dFinishAbsence As Date      // Date of finish absence
    Data cPeriod        As Character // Calculation period
    Data cCurRot        As Character // Roteir
    Data cCurSemana     As Character // Semana
    Data nValue         As Numeric   // value of Payment
    Data cError         As Character // Message of error
    Data nDays          As Numeric   // Count days of absence
    Data nRegionalCoeff As Numeric   // egional coefficient
    Data nAverPayment   As Numeric   // Average value for calculating
    Data nWorkingDay    As Numeric   // Count of working day for period
    Data cMat           As Character // Employee's Reg. Number (for reference)
    Data cFil           As Character // Branch for Employee (for reference)
    Data cDepto         As Character // Department for Employee (for reference)
    Data cMVZ           As Character // MVZ for Employee (for reference)
    Data cCatFunc       As Character // Category of Employee (mounts/hours/gpa)
    Data cProcesEmpl    As Character // Process calculation of Employee 
    Data cTnoTrab       As Character // ?orking hours code
    Data nSalary        As Numeric   // Salary of Employee
    Data nHoursDay      As Numeric   // Count of hours in work shift of Employee
    Data cFirstPeriod   As Character // First previous calculation period
    Data cSecondPeriod  As Character // Second previous calculation period
    Data aAbsence       As Array     // Array of All absence
    Data nIndOfCurAbsen As Numeric   // Index of current absence
    Data nValueRef182N  As Numeric   // Index of current absence
    Data cChildrens     As Character // String with code of childrens
    Data aPerForAver    As Array     // Data with some information about last two years
    Data lHospita       As Logical   // Hospitality or not
    Data nRecNoAbsence  As Nymeric   // Rec number of current absence
    Data lCancelExper   As Logical   // Cancel experience for calculation
    Data dViolDate      As Date      // Date of violation
    Data nAgeLimit      As Numeric   // Limit of day, whith enter user in current abswnce
    Data nCurDpagar     As Numeric   // Dpagarof current absence 
    Data lFromMrot      As Logical   // Calculate from MROT
    Data aExperien      As Array     // Array for experience
    Data nExpCoeff      As Numeric   // Coefficient for experience
    Data nRegCoeff      As Numeric   // Regional coefficient
    Data aDayAver       As Array     // Array of days for calculation
    Data nFirstMROT     As Numeric   // MROT on start of absence
    Data oDataPrevAbs   As Object    // Data about previously absence

    Method New(cType, cPD, cID, dStart, dFinish, cPer, aAbsenc, nCurInd, cChilds, nRecNo) Constructor
    Method Calculation(cMat)
    Method GetInfoAboutEmployee(cMat)
    Method CalcSumTwoPrevYears(oMonths, nIDDay, nIDMoney)
    Method GetValSTable(cTable, cBranch)
    // Calculate Maternity benefit. Russian variant.
    Method CalcMaternityBirth()
    Method GetAverageForMaternity(cMat, cPeriod)
    Method GetCountDayForMaternity(cMat, cPeriod)
    // Calculate care for child before 3 years
    Method CalcChildCareAllowance3Year()
    Method GetStrRccForPer(cTable, cPeriod, nCol)
    // Calculate disability FSS
    Method CalcDisabFss()
    // Calculate tarif. absence due to unforeseen reasons
    Method CalcBaseRateUnforeseen()
    Method GetWorkingDayInPeriodo()

    Method CalcAverageWithExperience(lExperien)
    Method CalcFromArrayDay()
    Method GetDaysForPeriod(dSDate, dFDate)
    Method GetCountDayOfMounth(nMounth)
    Method CalcExperience(cMat, lCur, cCode, dCurDate)
    Method GetDayAbsTypeBeforeStart(cTypeAbs, cYear, cMat)
    Method GetDataAboutPrevAbs()

    Method Destroy()

EndClass

/*/
{Protheus.doc} New(cType, cPD, cID, dStart, dFinish)
    Default constructor.

    @type Method
    @params cType,   Character, Type of Absence.
    @params cPD,     Character, Payment type.
    @params cID,     Character, ID.
    @params dStart,  Date     , Date of start absence.
    @params dFinish, Date     , Date od finish absence.
    @params aAbsenc, Array    , Array of other Absence.
    @params nCurInd, Numeric  , Index of current Absence.
    @params nRecNo,  Numeric  , Rec number of current absence.
    @author dchizhov
    @since 2022/12/06
    @version 12.1.33
    @return RUCalcAbsenceType, Object, RUCalcAbsenceType instance.
    @example RUCalcAbsenceType := RUCalcAbsenceType():New(cType, cPD, cID, dStart, dFinish)
/*/
Method New(cType, cPD, cID, dStart, dFinish, cPer, aAbsenc, nCurInd, cChilds, nRecNo) Class RUCalcAbsenceType

    Local aArea    As Array
    Local aSR8Area As Array

    Default cID := RetValSRV(cPD, SRA->RA_FILIAL, "RV_CODFOL")
    Default cPer := PadR
    Default aAbsenc := {}

    aArea := GetArea()
    aSR8Area := SR8->(GetArea())
    DbSelectArea("SR8")
    Self:nRecNoAbsence := nRecNo
    SR8->(DbGoTo(nRecNo))

    Self:cTypeOfAbsence := cType
    Self:cPaymentType   := cPD
    Self:cPaymentID     := cID
    Self:dStartAbsence  := dStart
    Self:dFinishAbsence := dFinish
    Self:cPeriod        := cPer
    Self:nRegionalCoeff := 0
    Self:cError         := ""
    Self:nValue         := 0
    Self:nDays          := dFinish - dStart + 1
    Self:cFirstPeriod   := AllTrim(Str(Val(SubStr(::cPeriod, 1, 4)) - 1) + "01")
    Self:cSecondPeriod  := AllTrim(Str(Val(SubStr(::cPeriod, 1, 4)) - 2) + "01")
    Self:aAbsence       := AClone(aAbsenc)
    Self:nIndOfCurAbsen := nCurInd
    Self:nValueRef182N  := 0    
    Self:nCurDpagar     := SR8->R8_DPAGAR
    Self:cChildrens     := cChilds
    Self:lCancelExper   := SR8->R8_CKTCANC == "1"
    Self:lHospita       := SR8->R8_HOSPITA == "3" .And. !(Self:lCancelExper)
    Self:dViolDate      := SR8->R8_VIOLAT
    Self:nAgeLimit      := SR8->R8_AGELIMI

    If Type("oRU07XFU01") == "O"
        oRU07XFU01:cNumberOfELN := SR8->R8_OBSAFAS
    EndIf

    SR8->(RestArea(aSR8Area))
    RestArea(aArea)

    Self:cCurRot        := Iif(Empty(CROT), GetRotExec(), CROT)
    Self:cCurSemana     := Iif(Empty(CSEMANA), GetNumpgCalc(), CSEMANA)
    Self:aExperien      := {Nil, Nil, Nil}
    Self:oDataPrevAbs   := JsonObject():New()
    Self:oDataPrevAbs["lContinue"] := .F.

Return Self

/*/
{Protheus.doc} Calculation(cMat)
    Calculation for absence.

    @type Method
    @params cMat, Character, Employee's Reg. Number (RA_MAT)
    @author dchizhov
    @since 2022/12/06
    @version 12.1.33
    @return lReturn, Logical, Success of calculation.
    @example RUCalcAbType:Calculation(cMat)
/*/
Method Calculation(cMat) Class RUCalcAbsenceType

    Local lReturn   As Logical
    Local nValue    As Numeric
    Local nAverDays As Numeric
    Local nValSTab  As Numeric
    Local nParSTab  As Numeric
    Local aArea     As Array

    lReturn := .T.
    aArea := GetArea()
    ::GetInfoAboutEmployee(cMat)
    
    If ::cPaymentID $ "0042" // Injury at work - temporary disability
        // Calculation average payment
        nValue := ::CalcSumTwoPrevYears(RUMap():New(), 1750, 1751)[1]
        nAverDays := RU07XFUN32_GetAbsenceDays(::cSecondPeriod, ::cFirstPeriod, .F.)
        nValue := nValue / nAverDays
        If Type("oRU07XFU01") == "O"
            oRU07XFU01:nCDays := nAverDays
        EndIf
        // Calculation max value
        nValSTab := ::GetValSTable("S240", ::cFil)
        lReturn := nValSTab >= 0
        nValSTab /= RU07XVAC01_fGetMonthDays(::cPeriod)
        nValue := Min(nValue, nValSTab)
        // Calculation minimum wage
        If lReturn
            nValSTab := ::GetValSTable("S004", ::cFil)
            lReturn := lReturn .And. nValSTab > 0
        EndIf
        // Regions coefficient
        If lReturn
            nParSTab := Val(fDescRcc("S206", ::cDepto, 145, 9, 11, 6))
            If ValType(nParSTab) <> "N" .Or. nParSTab == 0
                nParSTab := Val(fDescRcc("S206", ::cMVZ, 154, 9, 11, 6))
            EndIf
            If ValType(nParSTab) <> "N" .Or. nParSTab == 0
                nParSTab := 0
            EndIf
        EndIf
        nParSTab := nParSTab / 100 + 1
        ::nRegionalCoeff := nParSTab
        nValSTab *= nParSTab
        // Count of day/mounth
        If lReturn
            nParSTab := RU07XFUN33_GetMROTMonth(::cPeriod)
            lReturn := lReturn .And. nParSTab > 0
        EndIf
        If lReturn
            nValSTab *= nParSTab
            nParSTab := RU07XFUN32_GetAbsenceDays(::cFirstPeriod, ::cSecondPeriod, .F.)
            lReturn := lReturn .And. nParSTab > 0
        Else
            ::cError := STR0014
        EndIf
        If MethIsMemberOf(Self, "CalcExperience")
            ::CalcExperience(::cMat, , , ::dStartAbsence)
        EndIf
        If lReturn
            nValSTab /= nParSTab
            // Calculate payments
            ::nValue := Round(Max(nValue, nValSTab) * ::nDays, 2)
        Else
            ::cError := STR0014
        EndIf
    ElseIf ::cPaymentID $ "1767" // Maternity benefit. Russian variant.
        ::CalcMaternityBirth()
    ElseIf ::cPaymentID $ "1768" // Child care leave up to 1.5 years
        ::CalcChildCareAllowance3Year()
    ElseIf ::cPaymentID $ "0040" // Disability FSS.
        ::CalcDisabFss()
    ElseIf ::cPaymentID $ "1769" // Base rate. (Tarif. Absence due to unforeseen reasons.)
        ::CalcBaseRateUnforeseen()
    EndIf

    RestArea(aArea)

Return lReturn

/*/
{Protheus.doc} GetInfoAboutEmployee(cMat)
    Getting information about employee.

    @type Method
    @params cMat, Character, Employee's Reg. Number (RA_MAT)
    @author dchizhov
    @since 2022/12/07
    @version 12.1.33
    @return lResult, Logical, Success get information.
    @example ::GetInfoAboutEmployee(cMat)
/*/
Method GetInfoAboutEmployee(cMat) Class RUCalcAbsenceType

    Local aArea    As Array
    Local aAreaSRA As Array
    Local lResult  As Logical

    Default cMat := ""

    lResult := .F.

    ::cMat := cMat
    ::cFil := ""
    ::cDepto := ""
    ::cMVZ := ""
    ::cCatFunc := ""
    ::nSalary := 0
    ::nHoursDay := 0
    ::cProcesEmpl := ""
    ::cTnoTrab := ""
    aArea := GetArea()
    aAreaSRA := SRA->(GetArea())

    If !Empty(cMat)
        DbSelectArea("SRA")
        SRA->(DbSetOrder(RetOrder("SRA", "RA_MAT+RA_FILIAL")))
        If SRA->(DbSeek(cMat))
            ::cFil := SRA->RA_FILIAL
            ::cDepto := SRA->RA_DEPTO
            ::cMVZ := SRA->RA_CC
            ::cCatFunc := SRA->RA_CATFUNC
            ::nSalary := SRA->RA_SALARIO
            ::nHoursDay := SRA->RA_HRSDIA
            ::cProcesEmpl := SRA->RA_PROCES
            ::cTnoTrab := SRA->RA_TNOTRAB
            lResult := .T.
        EndIf
    EndIf
    SRA->(DbCloseArea())

    SRA->(RestArea(aAreaSRA))
    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} CalcSumTwoPrevYears(oMonths, nIDDay, nIDMoney)
    Returns average earnings for paying.

    @type Method
    @params oMonths,  Object,  Output RUMap with calendar days without absences & receiving INSS-payments per period
    @params nIDDay,   Numeric, ID by the values of which days of absence are set
    @params nIDMoney, Numeric, ID for the values of which to calculate the average
    @params lByYear,  Logical, Result by year or sum
    @author dchizhov
    @since 2022/12/06
    @version 12.1.33
    @return aValue, Array, {Average value, Absence day}.
    @example nVal := ::CalcSumTwoPrevYears(oMonths, nIDDay, nIDMoney)[1]
/*/
Method CalcSumTwoPrevYears(oMonths, nIDDay, nIDMoney, lByYear) Class RUCalcAbsenceType

    Local aValue     As Array
    Local cPeriod    As Char
    Local nI         As Numeric
    Local nJ         As Numeric
    Local aPeriods   As Array
    Local aBaseYears As Array
    Local nBaseMonth As Numeric

    Local cRUSAvDSDaysCodFol  As Character
    Local cRUSAvDSMoneyCodFol As Character
    Local aYearsAverages      As Array
    Local aYearsPeriods       As Array
    Local aRef182n            As Array

    Default nIDDay   := 1750
    Default nIDMoney := 1751
    Default lByYear := .F.

    aPeriods := {}
    cRUSAvDSDaysCodFol  := aCodFol[nIDDay, 1]
    cRUSAvDSMoneyCodFol := aCodFol[nIDMoney, 1]
    aBaseYears := { cValToChar(Year(::dStartAbsence) - 2), cValToChar(Year(::dStartAbsence) - 1) } // Simple case, can be more complicated
    nBaseMonth := 0
    aYearsAverages := {0, 0}
    aYearsPeriods := {{}, {}}
    nDSAbsenceDays := 0
    aRef182n := RU07XFUN35_Ref182n(::cMat)

    // Fill aray by previous periods (months)
    For nI := 1 To 2
        nBaseMonth := 0
        For nJ := 1 To 12
            nBaseMonth += 1
            cPeriod := aBaseYears[nI] + StrZero(nBaseMonth, 2)
            AAdd(aPeriods, cPeriod)
            oMonths:Set(cPeriod, {0, 0})
        Next nJ
    Next nI

    // Check payments from opened period
    RU07XVAC02_GetSRCAvRecords(::cMat, aPeriods[Len(aPeriods)], cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

    // Check payments from closed periods
    RU07XVAC03_GetSRDAvRecords(::cMat, aPeriods, cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

    // Separate periods by years
    oMonths:List(aPeriods)
    For nI := 1 To Len(aPeriods)
        If SubStr(aPeriods[nI][1], 1, 4) == aBaseYears[1]
            AAdd(aYearsPeriods[1], aPeriods[nI])
        Else
            AAdd(aYearsPeriods[2], aPeriods[nI])
        EndIf
    Next nI

    // Calculate sum for each year
    If lByYear
        aYearsAverages := {{0, 0}, {0, 0}}
        For nI := 1 To 2
            aYearsAverages[nI, 1] := aBaseYears[nI]
            For nJ := 1 To Len(aYearsPeriods[nI])
                aYearsAverages[nI, 2] += aYearsPeriods[nI][nJ][2][2]
                nDSAbsenceDays += aYearsPeriods[nI][nJ][2][1]
            Next nJ
            For nJ := 1 To Len(aRef182n)
                If aBaseYears[nI] == aRef182n[nJ][1]
                    aYearsAverages[nI, 2] += aRef182n[nJ][2]
                    nDSAbsenceDays += Val(aRef182n[nJ][3])
                EndIf
            Next nJ
        Next nI
        If Type("oRU07XFU01") == "O"
            For nI := 1 To 2
                oRU07XFU01:aLastYear[nI, 1] := aYearsAverages[nI, 1]
                oRU07XFU01:aLastYear[nI, 2] := aYearsAverages[nI, 2]
            Next nI
        EndIf

        aValue := {aYearsAverages, nDSAbsenceDays}
    Else
        For nI := 1 To 2
            For nJ := 1 To Len(aYearsPeriods[nI])
                aYearsAverages[nI] += aYearsPeriods[nI][nJ][2][2]
                nDSAbsenceDays += aYearsPeriods[nI][nJ][2][1]
            Next nJ
            For nJ := 1 To Len(aRef182n)
                If aBaseYears[nI] == aRef182n[nJ][1]
                    aYearsAverages[nI] += aRef182n[nJ][2]
                    nDSAbsenceDays += Val(aRef182n[nJ][3])
                EndIf
            Next nJ
            If Type("oRU07XFU01") == "O"
                oRU07XFU01:aLastYear[nI, 1] := aBaseYears[nI]
                oRU07XFU01:aLastYear[nI, 2] := aYearsAverages[nI]
            EndIf
        Next nI

        aValue := {aYearsAverages[1] + aYearsAverages[2], nDSAbsenceDays}
    EndIf
    
Return aValue

/*/
{Protheus.doc} GetValSTable(cTable, cBranch)
    Returns value  from S-table.

    @type Method
    @params cTable,  Character, Name of table.
    @params cBranch, Character, Branch if we need filter for branch.
    @author dchizhov
    @since 2022/12/07
    @version 12.1.33
    @return nMax, Numeric, Value from S240.
    @example nMaximum := ::GetValSTable("S240", ::cFil)
/*/
Method GetValSTable(cTable, cBranch) Class RUCalcAbsenceType

    Local nVal     As Numeric
    Local aArea    As Array
    Local aAreaRCC As Array
    Local lExist   As Logical
    Local cFil     As Character
    Local cStart   As Character
    Local cFinish  As Character
    Local nIndVal  As Numeric
    Local nLenVal  As Numeric

    Default cBranch := ""

    aArea := GetArea()
    aAreaRCC := RCC->(GetArea())
    cFil := cBranch

    nIndVal := Iif(cTable == "S240", 17, 13)
    nLenVal := 12

    DbSelectArea("RCC")
    RCC->(DbSetOrder(1))

    lExist := RCC->(DbSeek(FWxFilial("RCC") + cTable + cFil))
    If !lExist
        cFil := ""
        lExist := RCC->(DbSeek(FWxFilial("RCC") + cTable))
    EndIf

    If lExist
        lExist := .F.
        While !RCC->(EOF()) .And. AllTrim(cFil) == AllTrim(RCC->RCC_FIL)
            cStart := SubStr(RCC->RCC_CONTEU, 1, 6)
            cStart := Iif(Empty(cStart), "000000", cStart)
            cFinish := SubStr(RCC->RCC_CONTEU, 7, 6)
            cFinish := Iif(Empty(cFinish), "999999", cFinish)
            If ::cPeriod >= cStart .And. ::cPeriod <= cFinish
                nVal := Val(SubStr(RCC->RCC_CONTEU, nIndVal, nLenVal))
                lExist := .T.
                Exit
            EndIf
            RCC->(DbSkip())
        EndDo
    EndIf

    If !lExist
        ::cError := STR0012 + " '" + cTable + "' " + STR0013 + " '" + ::cFil + "'"
        nVal := -1
    EndIf

    RCC->(DbCloseArea())
    RCC->(RestArea(aAreaRCC))
    RestArea(aArea)

Return nVal

/*/
{Protheus.doc} CalcMaternityBirth()

    Calculate abcence for pregnancy and childbirth.

    @type Method
    @params
    @author dchizhov
    @since 13.10.2023
    @version 12.1.33
    @return .T.
    @example ::CalcMaternityBirth()
/*/
Method CalcMaternityBirth() Class RUCalcAbsenceType

    Local cPerForCal As Character
    Local nK         As Numeric
    Local nTemp      As Numeric
    Local cTemp      As Character
    Local nSumm      As Numeric
    Local nI         As Numeric
    Local nMaximum   As Numeric
    Local nMinimum   As Numeric
    Local nRegCoeff  As Numeric
    Local dPrevStart As Date

    If Empty(AllTrim(::aAbsence[::nIndOfCurAbsen][6]))
        cPerForCal := SubStr(DToS(::aAbsence[::nIndOfCurAbsen][2]), 1, 6)
        dPrevStart := ::aAbsence[::nIndOfCurAbsen][2]
    Else
        nK := AScan(::aAbsence, {|X| X[5] == ::aAbsence[::nIndOfCurAbsen][6]})
        If nK < 1
            UserException(CRLF + STR0022 + " " + ::cMat + " " + STR0021 + " " + ::aAbsence[::nIndOfCurAbsen][6] + CRLF + CRLF) // "For an employee" + "no missing number detected"
        EndIf
        While !Empty(AllTrim(::aAbsence[nK][6]))
            nTemp := AScan(::aAbsence, {|X| X[5] == ::aAbsence[nK][6]})
            If nTemp < 1
                UserException(CRLF + STR0022 + " " + ::cMat + " " + STR0021 + " " + ::aAbsence[nK][6] + CRLF + CRLF) // "For an employee" + "no missing number detected"
            EndIf
            nK := nTemp
        EndDo
        cPerForCal := SubStr(DToS(::aAbsence[nK][2]), 1, 6)
        dPrevStart := ::aAbsence[nK][2]
    EndIf
    ::cFirstPeriod  := AllTrim(Str(Val(SubStr(cPerForCal, 1, 4)) - 1) + "01")
    ::cSecondPeriod := AllTrim(Str(Val(SubStr(cPerForCal, 1, 4)) - 2) + "01")
    nSumm := ::GetAverageForMaternity(::cMat, cPerForCal)
    If MethIsMemberOf(Self, "CalcExperience")
        ::CalcExperience(::cMat, , , dPrevStart)
    EndIf
    For nI := 1 To 2
        ::aPerForAver[nI, 6] := Min(::aPerForAver[nI, 6], ::aPerForAver[nI, 7])
    Next nI
    If Type("oRU07XFU01") == "O"
        oRU07XFU01:aLastYear[1, 2] := ::aPerForAver[1, 6]
        oRU07XFU01:aLastYear[2, 2] := ::aPerForAver[2, 6]
    EndIf

    nMaximum := (::aPerForAver[1, 7] + ::aPerForAver[2, 7]) / (::aPerForAver[1, 3] + ::aPerForAver[2, 3])

    nSumm := Min((::aPerForAver[1, 6] + ::aPerForAver[2, 6]) / (::aPerForAver[1, 5] + ::aPerForAver[2, 5]), nMaximum)

    cTemp := FDescRcc("S206", ::cDepto, 145, 9, 11, 6)
    If Empty(cTemp)
        cTemp := FDescRcc("S206", ::cMVZ, 154, 9, 11, 6)
    EndIf
    If Empty(cTemp)
        cTemp := "0"
    EndIf
    nRegCoeff := (Val(cTemp) / 100) + 1
    ::nRegionalCoeff := nRegCoeff
    nMinimum := ::GetStrRccForPer("S004", cPerForCal, 6) * nRegCoeff * (::aPerForAver[1, 4] + ::aPerForAver[2, 4])
    nMinimum /= ::aPerForAver[1, 3] + ::aPerForAver[2, 3]

    ::nValue := Max(nMinimum, nSumm)
    ::nValue := Round(::nValue * ::nDays, 2)

Return .T.

/*/{Protheus.doc} Method GetCountDayForMaternity(cMat, cPeriod)
    
    Calculate count day for average of maternity

    @type Method
    @params cMat       , Character, Tab num
    @params cPeriod    , Character, Period of calculation
    @return .T.
    @author dchizhov
    @since 22.09.2023
    @version 12.1.33
    @example ::GetCountDayForMaternity(cMat, cPeriod)
*/
Method GetCountDayForMaternity(cMat, cPeriod) Class RUCalcAbsenceType

    Local aArea       As Array
    Local aSRDArea    As Array
    Local cTemp       As Character
    Local cTemp2      As Character
    Local cTemp3      As Character
    Local nI          As Numeric
    Local nK          As Numeric
    Local aRef182n    As Array 

    aArea := GetArea()
    aSRDArea := SRD->(GetArea())
    ::aPerForAver := {}
    cTemp2 := ""

    For nI := 2 To 1 Step -1
        cTemp := CValToChar(Val(SubStr(cPeriod, 1, 4)) - nI)
        cTemp2 := cTemp + "12"
        cTemp3 := cTemp + SubStr(cPeriod, 5, 2)
        cTemp += "01"
        Aadd(::aPerForAver, {cTemp, cTemp2, ::GetStrRccForPer("S208", cTemp3, 7), ::GetStrRccForPer("S208", cTemp3, 9), ::GetStrRccForPer("S208", cTemp3, 10), 0})
    Next nI

    DbSelectArea("SRD")
    SRD->(DbSetOrder(RetOrdem("SRD", "RD_FILIAL+RD_MAT+RD_PERIODO")))
    For nI := 1 To Len(::aPerForAver)
        cTemp := ::aPerForAver[nI, 1]
        While cTemp <= ::aPerForAver[nI, 2]
            If SRD->(DbSeek(SRA->RA_FILIAL + cMat + cTemp))
                While !SRD->(EOF()) .And. SRD->RD_FILIAL == SRA->RA_FILIAL .And. ;
                        SRD->RD_MAT == cMat .And. SRD->RD_PERIODO == cTemp
                    If aCodFol[1750, 1] == SRD->RD_PD
                        ::aPerForAver[nI, 5] -= SRD->RD_VALOR
                    EndIf
                    SRD->(DbSkip())
                EndDo
            EndIf
            cTemp := CValToChar(Val(cTemp) + 1)
        EndDo
    Next nI
    cTemp := CValToChar(Val(SubStr(cPeriod, 1, 4)) - 2)
    cTemp2 := CValToChar(Val(SubStr(cPeriod, 1, 4)) - 1)
    aRef182n := RU07XFUN35_Ref182n(cMat)
    For nI := 1 To Len(aRef182n)
        If aRef182n[nI, 1] == cTemp
            nK := 1
        ElseIf aRef182n[nI, 1] == cTemp2
            nK := 2
        Else
            nK := -1
        EndIf
        If nK > 0
            ::aPerForAver[nK, 6] += aRef182n[nI, 2]
            ::aPerForAver[nK, 5] -= Val(aRef182n[nI, 3])
        EndIf
    Next nI

    SRD->(RestArea(aSRDArea))
    RestArea(aArea)

Return .T.

/*/{Protheus.doc} GetAverageForMaternity(cMat, cPeriod)
    
    Calculate Average for maternity

    @type Method
    @params cMat,    Character, Tab Num employee.
    @params cPeriod, Character, Period of beginnig abcence for calculation.
    @return nSumm, Numeric, Average for maternity.
    @author dchizhov
    @since 22.09.2023
    @version 12.1.33
    @example ::nValue := ::GetAverageForMaternity(::cMat, cPerForCal)
*/
Method GetAverageForMaternity(cMat, cPeriod) Class RUCalcAbsenceType

    Local aArea       As Array
    Local aSRDArea    As Array
    Local nCountDays  As Numeric
    Local cTemp       As Character
    Local nSumm       As Numeric
    Local nI          As Numeric
    Local nValRef182N As Numeric

    aArea := GetArea()
    nSumm := 0
    aSRDArea := SRD->(GetArea())
    ::GetCountDayForMaternity(cMat, cPeriod)
    nValRef182N := nCountDays := 0 
    AEval(::aPerForAver, {|X| nValRef182N += X[6], nCountDays += X[5]})

    DbSelectArea("SRD")
    SRD->(DbSetOrder(RetOrdem("SRD", "RD_FILIAL+RD_MAT+RD_PERIODO")))
    For nI := 1 To Len(::aPerForAver)
        cTemp := ::aPerForAver[nI, 1]
        While cTemp <= ::aPerForAver[nI, 2]
            If SRD->(DbSeek(SRA->RA_FILIAL + cMat + cTemp))
                While !SRD->(EOF()) .And. SRD->RD_FILIAL == SRA->RA_FILIAL .And. ;
                        SRD->RD_MAT == cMat .And. SRD->RD_PERIODO == cTemp
                    If aCodFol[1751, 1] == SRD->RD_PD
                        nSumm += SRD->RD_VALOR
                        ::aPerForAver[nI, 6] += SRD->RD_VALOR
                    EndIf
                    SRD->(DbSkip())
                EndDo
            EndIf
            cTemp := CValToChar(Val(cTemp) + 1)
        EndDo
        Aadd(::aPerForAver[nI], GetFSSLimit(SubStr(::aPerForAver[nI, 1], 1, 4)))
        If Type("oRU07XFU01") == "O" .And. nI < 3 .And. ::cPaymentID $ CALC_AVERAGE_FOR_SIM_REALIZE
            oRU07XFU01:aLastYear[nI, 1] := SubStr(::aPerForAver[nI, 1], 1, 4)
            oRU07XFU01:aLastYear[nI, 2] := ::aPerForAver[nI, 6]
        EndIf
    Next nI
    nSumm := (nSumm + nValRef182N) / nCountDays

    If Type("oRU07XFU01") == "O"
        oRU07XFU01:nCDays := nCountDays
    EndIf

    SRD->(RestArea(aSRDArea))
    RestArea(aArea)

Return nSumm

/*/{Protheus.doc} CalcChildCareAllowance3Year()
    
    This method calculates child care benefits up to 3 years old.

    @type method
    @params
    @return .T.
    @author dchizhov
    @since 03.10.2023
    @version 12.1.33
    @example CalcChildCareAllowance3Year()
*/
Method CalcChildCareAllowance3Year() Class RUCalcAbsenceType

    Local nTemp     As Numeric
    Local nMaximum  As Numeric
    Local nMinimum  As Numeric
    Local nRegCoeff As Numeric
    Local nSumm     As Numeric
    Local cTemp     As Character
    Local cPeriod   As Character
    Local cPerForCo As Character
    Local aChilds   As Array
    Local aTemp     As Array
    Local dValDate  As Date
    Local dValSDate As Date
    Local nCounDPer As Numeric
    Local nCChilds  As Numeric
    Local nI        As Numeric
    
    cPerForCo := SubStr(DToS(::dStartAbsence), 1, 6)
    nSumm := ::GetAverageForMaternity(::cMat, cPerForCo)
    If MethIsMemberOf(Self, "CalcExperience")
        ::CalcExperience(::cMat, , , ::dStartAbsence)
    EndIf
    For nI := 1 To 2
        ::aPerForAver[nI, 6] := Min(::aPerForAver[nI, 6], ::aPerForAver[nI, 7])
    Next nI
    If Type("oRU07XFU01") == "O"
        oRU07XFU01:aLastYear[1, 2] := ::aPerForAver[1, 6]
        oRU07XFU01:aLastYear[2, 2] := ::aPerForAver[2, 6]
    EndIf
    nMaximum := (::aPerForAver[1, 7] + ::aPerForAver[2, 7]) / 730
    nSumm := Min((::aPerForAver[1, 6] + ::aPerForAver[2, 6]) / (::aPerForAver[1, 5] + ::aPerForAver[2, 5]), nMaximum)
    aChilds := RU07XFUN39_GetChildsForEmployee(::cMat, ::cChildrens)
    nCChilds := 0
    dValDate := aPeriodo[1, 4]
    cPeriod := ::cPeriod
    dValSDate := SToD(cPeriod + "01")
    nCounDPer := dValDate - dValSDate + 1
    dValDate := Min(dValDate, ::dFinishAbsence)
    dValSDate := Max(dValSDate, ::dStartAbsence)
    ::nFirstMROT := ::GetStrRccForPer("S004", cPerForCo, 6)
    aTemp := {}
    AEval(aChilds, {|X| X[2] := Max(X[2], dValSDate), X[3] := Min(X[3], dValDate)})
    AEval(aChilds, {|X|, Iif(X[3] >= X[2], Aadd(aTemp, X), )})
    aChilds := aTemp
    nCChilds := Len(aTemp)

    cTemp := FDescRcc("S206", ::cDepto, 145, 9, 11, 6)
    If Empty(cTemp)
        cTemp := FDescRcc("S206", ::cMVZ, 154, 9, 11, 6)
    EndIf
    If Empty(cTemp)
        cTemp := "0"
    EndIf
    nRegCoeff := Val(cTemp) / 100 + 1
    ::nRegionalCoeff := nRegCoeff
    nMinimum := ::nFirstMROT * nRegCoeff * (24)
    nMinimum /= 730

    nSumm := Max(nMinimum, nSumm)
    nSumm *= ::GetStrRccForPer("S208", cPerForCo, 11)
    nMaximum := nSumm
    cTemp := fRUGetRccConteo("S209", "")
    nSumm *= (Val(SubStr(cTemp, 49, 6)) / 100)
    nTemp := ::GetStrRccForPer("S217", cPerForCo, 6)
    nSumm := Max(nSumm, nTemp)
    ::nDays := dValDate - dValSDate + 1
    nSumm := Min(nCChilds * nSumm, nMaximum) / Max(nCChilds, 1)
    AEval(aChilds, {|X| ::nValue += (nSumm / nCounDPer) * (X[3] - X[2] + 1)})
    ::nValue := Round(::nValue, 2)

Return .T.

/*/{Protheus.doc} GetStrRccForPer(cTable, cPeriod, nCol)
    
    This function get string from rcc for period. Working on S-tables, which have start period - 1-st column (len = 6),
    and Fin period - 2-nd column (len = 6).

    @type Function
    @params cTable,  Character, S-table.
    @params cPeriod, Character, Period for search.
    @params nCol,    Numeric,   Number of returning column.
    @return xRes,    Value,     Value of column for period.
    @author dchizhov
    @since 09.10.2023
    @version 12.1.33
    @example nTemp := ::GetStrRccForPer("S217", cPeriod, 6)
*/
Method GetStrRccForPer(cTable, cPeriod, nCol) Class RUCalcAbsenceType

    Local aArea    As Array
    Local nLinePos As Numeric
    Local xRes

    aArea := GetArea()

    nLinePos := fPosTab(cTable, cPeriod, ">=", 4, cPeriod, "<=", 5)
    
    If nLinePos > 0
        xRes := fTabela(cTable, nLinePos, nCol)
    Else 
        UserException(CRLF + STR0019 + " " + cPeriod + " " + STR0020 + " " + cTable + CRLF + CRLF) // "Period:" + "not found in table"
    EndIf

    RestArea(aArea)

Return xRes

/*/
{Protheus.doc} CalcDisabFss()

    Calculate abcence by disability. Fss payment.

    @type Method
    @author dchizhov
    @since 27.10.2023
    @version 12.1.33
    @return .T.
    @example ::CalcDisabFss()
/*/
Method CalcDisabFss() Class RUCalcAbsenceType

    Local nMROT     As Numeric
    Local nTemp     As Numeric
    Local nTemp2    As Numeric
    Local nAverSumm As Numeric
    Local nCDays    As Numeric
    Local nCountDay As Numeric
    Local nI        As Numeric
    Local dViol     As Date
    lOCAL aArea     As Array
    Local aRCMArea  As Array
    Local lExperien As Logical
    Local cTemp     As Character
    Local nCDBefore As Numeric

    aArea := GetArea()
    aRCMArea := RCM->(GetArea())
    cTemp := Posicione("RCM", 1, xFilial("RCM") + ::cTypeOfAbsence, "RCM_TIPO")
    If Empty(cTemp)
        UserException(CRLF + ::cTypeOfAbsence + STR0020 + " RCM" + CRLF + CRLF) // "Period:" + "not found in table"
    EndIf

    ::GetDataAboutPrevAbs()
    nCDBefore := 0

    ::nDays := ::dFinishAbsence - ::dStartAbsence + 1
    nCountDay := RCM->RCM_DIASEM
    If ::nAgeLimit > 0
        nCountDay := Min(::nAgeLimit, nCountDay)
    EndIf
    If ::oDataPrevAbs["lContinue"]
        nCountDay -= ::oDataPrevAbs["countDayInAllPreviously"]
        nCDBefore := ::oDataPrevAbs["countDayInAllPreviously"]
        nCountDay := Max(nCountDay, 0)
        If ::oDataPrevAbs["lViolPrevDate"]
            ::dViolDate := ::oDataPrevAbs["dViolPrevDate"]
        EndIf
        ::oDataPrevAbs["currentDateStart"] := ::dStartAbsence
        ::dStartAbsence := ::oDataPrevAbs["firstDateStart"]
    EndIf
    nCDays := Min(nCountDay, ::nDays)

    nCountDay := ::GetDayAbsTypeBeforeStart(::cTypeOfAbsence, SubStr(::cPeriod, 1, 4), ::cMat, ::dStartAbsence)
    nCountDay := Max(RCM->RCM_LIMPDL - nCountDay, 0)
    nCDays := Min(nCDays, nCountDay)
    ::nFirstMROT := ::GetStrRccForPer("S004", SubStr(DToS(::dStartAbsence), 1, 6), 6)
    ::nDays := nCDays
    ::nValue := 0
    
    If ::nDays > 0
        lExperien := Iif(::lCancelExper, .F., RCM->RCM_CTK209 == "1")
        dViol := iif(Empty(::dViolDate), ::dFinishAbsence + 1, ::dViolDate)
        nAverSumm := ::CalcAverageWithExperience(lExperien)
        ::nValue := 0
        nTemp := nAverSumm * KOEFF_FOR_CALC_HOSPITAL
        nTemp2 := nAverSumm * ::nExpCoeff

        For nI := 1 To Len(::aDayAver)
            If ::aDayAver[nI, 1] >= dViol
                ::lFromMrot := .T.
            EndIf
            nMROT := ::aDayAver[nI, 4]
            If ::lFromMrot
                ::nValue += nMROT
            Else
                If ::lHospita .And. nI > 10 - nCDBefore
                    nAverSumm := nTemp
                Else
                    nAverSumm := nTemp2
                EndIf
                ::nValue += Max(nAverSumm, nMROT)
            EndIf
        Next nI

        ::nValue := Round(::nValue, 2)
    Else
        If Type("oRU07XFU01") == "O"
            oRU07XFU01:aLastYear[1, 1] := -1
            oRU07XFU01:aLastYear[1, 2] := -1
            oRU07XFU01:aLastYear[2, 1] := -1
            oRU07XFU01:aLastYear[2, 2] := -1
            ::nRegionalCoeff := 1
            ::aExperien[1] := -1
            ::aExperien[2] := -1
        EndIf
    EndIf
    
    RCM->(RestArea(aRCMArea))
    RestArea(aArea)

Return .T.

/*/
{Protheus.doc} CalcAverageWithExperience(lExperien)

    Calculate average summ by standart sheme with experience.

    @type Method
    @params lExperien, Logical, Take into account experience.
    @author dchizhov
    @since 27.10.2023
    @version 12.1.33
    @return nAverSumm, Numeric, Average summ.
    @example nAverSumm := ::CalcAverageWithExperience(lExperien)
/*/
Method CalcAverageWithExperience(lExperien) Class RUCalcAbsenceType

    Local nMaximum  As Numeric
    Local nMROT     As Numeric
    Local nAverSumm As Numeric
    Local nCDays    As Numeric
    Local nI        As Numeric
    Local aExperien As Array
    Local aTemp     As Array
    Local cTemp     As Character

    Default lExperien := .T.

    aTemp := ::CalcSumTwoPrevYears(RUMap():New(), 1750, 1751, .T.)[1]
    nCDays := 0
    nAverSumm := 0
    nMaximum := 0
    For nI := 1 To Len(aTemp)
        nCDays += Val(FDescRcc("S208", aTemp[nI, 1] + "01" + aTemp[nI, 1] + "12", 1, 12, 18, 3))
        Aadd(aTemp[nI], GetFSSLimit(aTemp[nI, 1]))
        nAverSumm += Min(aTemp[nI, 2], aTemp[nI, 3])
        If Type("oRU07XFU01") == "O" .And. nI < 3
            oRU07XFU01:aLastYear[nI, 2] := Min(aTemp[nI, 2], aTemp[nI, 3])
        EndIf
        nMaximum += aTemp[nI, 3]
    Next nI
    If Type("oRU07XFU01") == "O"
        oRU07XFU01:nCDays := nCDays
    EndIf
    nAverSumm /= nCDays
    nMaximum /= 730
    nAverSumm := Min(nMaximum, nAverSumm)
    ::lFromMrot := nAverSumm == 0
    aExperien := ::CalcExperience(::cMat, , , ::dStartAbsence)
    ::nExpCoeff := 1
    If lExperien
        ::nExpCoeff := FTabela("S209", 1, 3 + Min(8, Max(aExperien[1], 1))) / 100
    EndIf
    ::lFromMrot := ::lFromMrot .Or. (aExperien[1] == 0 .And. aExperien[2] < COUNT_MONTH_MIN_FOR_NOT_MROT .And. lExperien)

    cTemp := FDescRcc("S206", ::cDepto, 145, 9, 11, 6)
    If Empty(cTemp)
        cTemp := FDescRcc("S206", ::cMVZ, 154, 9, 11, 6)
    EndIf
    If Empty(cTemp)
        cTemp := "0"
    EndIf
    ::nRegCoeff := (Val(cTemp) / 100) + 1
    If AttIsMemberOf(Self, "nRegionalCoeff")
        ::nRegionalCoeff := ::nRegCoeff
    EndIf

    dCurDate := Iif(::oDataPrevAbs["lContinue"], ::oDataPrevAbs["currentDateStart"], ::dStartAbsence)
    ::aDayAver := ::GetDaysForPeriod(dCurDate, dCurDate + ::nDays - 1, ::nRegCoeff)
    nMROT := ::aDayAver[1, 3] * ::nRegCoeff * 24 / 730
    ::nValue := 0
    nAverSumm := Max(nAverSumm, nMROT)

Return nAverSumm

/*/
{Protheus.doc} GetCountDayOfMounth(cData)

    Get calendar day for mounth.

    @type Method
    @params cData, Character, Data (or period) for mounth of which Calc count calendar day (in format string).
    @author dchizhov
    @since 30.11.2023
    @version 12.1.33
    @return nDay
    @example aCDMoun := {Mounth(dSDate), ::GetCountDayOfMounth(DToS(dSDate))}
/*/
Method GetCountDayOfMounth(cData) Class RUCalcAbsenceType
    
    Local nDay As Numeric
    Local cDay As Character

    cDay := CValToChar(Val(SubStr(cData, 1, 6)) + 1) + "01"

    If SubStr(cData, 5, 2) == "12"
        nDay := 31
    Else 
        nDay := Day(SToD(cDay) - 1)
    EndIf

Return nDay

/*/
{Protheus.doc} GetDaysForPeriod(dSDate, dFDate, nRegCoeff)

    Get Arrays of day for period.

    @type Method
    @params dSDate,    Data, Date start of period.
    @params dFDate,    Data, Date finish of period.
    @params nRegCoeff, Numeric, Regional coefficient.
    @author dchizhov
    @since 30.11.2023
    @version 12.1.33
    @return aDaysPer
    @example aDayAver := ::GetDaysForPeriod(::dStartAbsence, ::dStartAbsence + ::nDays, nRegCoeff)
/*/
Method GetDaysForPeriod(dSDate, dFDate, nRegCoeff) Class RUCalcAbsenceType
    
    Local dCurDate As Date
    Local nMROT    As Numeric
    Local nDays    As Numeric
    Local aDaysPer As Array
    Local aCDMoun  As Array
    Local aArea    As Array
    Local cTemp    As Character

    Default nRegCoeff := 1

    aArea := GetArea()

    aDaysPer := {}
    cTemp := DToS(dSDate)

    nMROT := ::nFirstMROT
    nDays := ::GetCountDayOfMounth(cTemp)

    aCDMoun := {Month(dSDate), ::GetCountDayOfMounth(cTemp), nMROT, nMROT * nRegCoeff / nDays}

    For dCurDate := dSDate To dFDate Step 1

        If aCDMoun[1] <> Month(dCurDate)
            cTemp := DToS(dCurDate)
            nMROT := ::nFirstMROT
            nDays := ::GetCountDayOfMounth(cTemp)
            aCDMoun := {Month(dSDate), nDays, nMROT, nMROT * nRegCoeff / nDays}
        EndIf

        Aadd(aDaysPer, {dCurDate, aCDMoun[2], aCDMoun[3], aCDMoun[4]})

    Next dCurDate

    RestArea(aArea)

Return aDaysPer

/*/
{Protheus.doc} CalcExperience(cMat, lCur, cCode, dCurDate)

    Calculate experience.

    @type Method
    @params cMat,  Character, Tab Num employee.
    @params lCur,  Logical,   Calculate current work place.
    @params cCode, Character, Code of exp which need.
    @author dchizhov
    @since 27.10.2023
    @version 12.1.33
    @return aExp Array, Experience in format {Y, M, D}.
    @example aExperien := ::CalcExperience(::cMat, , , ::dStartAbsence)
/*/
Method CalcExperience(cMat, lCur, cCode, dCurDate) Class RUCalcAbsenceType

    Local aExp    As Array
    Local oExperience As Object

    oExperience := RUExperienceCalculation():New()
    aExp := oExperience:CalcExperience(cMat, lCur, cCode, dCurDate)
    FwFreeObj(oExperience)

    ::aExperien[1] := aExp[1] 
    ::aExperien[2] := aExp[2] 
    ::aExperien[3] := aExp[3]
    
Return aExp

/*/
{Protheus.doc} GetDayAbsTypeBeforeStart(cTypeAbs, cYear, cMat)

    Calculate day of absence (paying - R8_DPAGAR) in current year by same type of absence before start current absence.

    @type Method
    @params cTypeAbs, Character, Type of absence.
    @params cYear,    Character, Current year.
    @params cMat,     Character, Tab Num employee.
    @params dCurDate, Date     , Current date.
    @author dchizhov
    @since 01.11.2023
    @version 12.1.33
    @return nDay Numeric, Count day.
    @example nCountDay := GetDayAbsTypeBeforeStart(::cTypeOfAbsence, SubStr(::cPeriod, 1, 4), ::cMat, ::dStartAbsence)
/*/
Method GetDayAbsTypeBeforeStart(cTypeAbs, cYear, cMat, dCurDate) Class RUCalcAbsenceType

    Local aArea    As Array
    Local aSR8Area As Array
    Local nDay     As Numeric
    Local cFil     As Character

    aArea := GetArea()
    aSR8Area := SR8->(GetArea())
    cFil := xFilial("SR8")
    nDay := 0
    DbSelectArea("SR8")
    SR8->(DbSetOrder(RetOrdem("SR8", "R8_FILIAL+R8_MAT+R8_PER")))
    If SR8->(DbSeek(cFil + cMat + cYear, .T.))
        While SR8->R8_FILIAL == cFil .And. SR8->R8_MAT == cMat .And. SubStr(SR8->R8_PER, 1, 4) == cYear
            If SR8->R8_TIPOAFA == cTypeAbs .And. SR8->R8_DATAINI < dCurDate
                nDay += SR8->R8_DPAGAR
            EndIf
            SR8->(DbSkip())
        EndDo
    EndIf
    RestArea(aArea)
    SR8->(RestArea(aSR8Area))
    
Return nDay

/*/{Protheus.doc} CalcBaseRateUnforeseen()
    
    Calculate paying for absence due to unforeseen reasons

    @type Method
    @return .T.
    @author dchizhov
    @since 07.11.2023
    @version 12.1.33
    @example ::CalcBaseRateUnforeseen()
*/
Method CalcBaseRateUnforeseen() Class RUCalcAbsenceType

    Local nValDay As Numeric

    If ::cCatFunc == CATEGORY_MOUNTH
        nValDay := ::nSalary / ::GetWorkingDayInPeriodo(SubStr(DToS(::dStartAbsence), 1, 6))
    ElseIf ::cCatFunc == CATEGORY_HOURS
        nValDay := ::nSalary * ::nHoursDay
    Else
        nValDay := 0
    EndIf
    
    ::nDays := ::nCurDpagar 

    If nValDay > 0
        ::nValue := Round(nValDay * ::nDays * 2 / 3, 2)
    Else
        ::nValue := 0
        ::nDays := 0
    EndIf
Return .T.

/*/{Protheus.doc} GetWorkingDayInPeriodo(cPerWork)
    
    Get working day in period

    @type Method
    @params cPerWork, Character, Period.
    @return nCDay, Numeric, Count of working day.
    @author dchizhov
    @since 07.1.2023
    @version 12.1.33
    @example nValDay := ::nSalary / ::GetWorkingDayInPeriodo(SubStr(DToS(::dStartAbsence), 1, 6))
*/
Method GetWorkingDayInPeriodo(cPerWork) Class RUCalcAbsenceType

    Local nCDay    As Numeric
    Local aArea    As Array
    Local aRCFArea As Array
    Local cFilCur  As Character
    Local cRotRcf  As Character
    Local cTurno   As Character
    Local cSemana  As Character

    nCDay := 0
    aArea := GetArea()
    aRCFArea := RCF->(GetArea())
    cFilCur := xFilial("RCF")
    cRotRcf := Space(GetSx3Cache("RCH_ROTEIR", "X3_TAMANHO"))
    cTurno := ::cTnoTrab
    cSemana := Iif(Empty(::cCurSemana), "01", ::cCurSemana)

    DbSelectArea("RCF")
    RCF->(DbSetOrder(2))

    If !(RCF->(DbSeek(cFilCur + ::cProcesEmpl + cPerWork + cRotRcf + cTurno + cSemana, .T.)))
        cTurno := "@@@"
        If !(RCF->(DbSeek(cFilCur + ::cProcesEmpl + cPerWork + cRotRcf + cTurno + cSemana, .T.)))
            UserException(CRLF + STR0019 + " " + cPerWork + "(proc - " + ::cProcesEmpl + ", semana - " + cSemana + ") " ; // "Period:"
            + STR0020 + " RCF" + CRLF + CRLF) // "not found in table"
        EndIf
    EndIf

    ::nWorkingDay := nCDay := RCF->RCF_DUTEIS

    RCF->(RestArea(aRCFArea))
    RestArea(aArea)

Return nCDay

/*/{Protheus.doc} GetDataAboutPrevAbs
    
    Get data about previosly absence

    @type Method
    @return lPreviously, Logical, Are there previous absences
    @author dchizhov
    @since 30.05.2024
    @version 12.1.33
    @example ::GetDataAboutPrevAbs
*/
Method GetDataAboutPrevAbs() Class RUCalcAbsenceType

    Local lPreviously As Logical
    Local aArea       As Array
    Local aSR8Area    As Array
    Local cSeqPar     As Character
    Local cKeySearch  As Character

    lPreviously := .F.
    aArea := GetArea()
    aSR8Area := SR8->(GetArea())

    DbSelectArea("SR8")
    SR8->(DbSetOrder(RetOrdem("SR8", "R8_FILIAL+R8_MAT+R8_SEQ")))
    SR8->(DbGoTo(::nRecNoAbsence))
    cKeySearch := SR8->R8_FILIAL + SR8->R8_MAT
    cSeqPar := AllTrim(SR8->R8_CONTAFA)
    If cSeqPar <> ""
        lPreviously := .T.
        ::oDataPrevAbs["countDayInAllPreviously"] := 0
        ::oDataPrevAbs["lViolPrevDate"] := .F.
        While cSeqPar <> "" .And. SR8->(DbSeek(cKeySearch + cSeqPar))
            ::oDataPrevAbs["countDayInAllPreviously"] += SR8->R8_DATAFIM - SR8->R8_DATAINI + 1
            If !Empty(SR8->R8_VIOLAT)
                ::oDataPrevAbs["lViolPrevDate"] := .T.
                ::oDataPrevAbs["dViolPrevDate"] := SR8->R8_VIOLAT
            EndIf
            cSeqPar := AllTrim(SR8->R8_CONTAFA)
        EndDo
        ::oDataPrevAbs["firstDateStart"] := SR8->R8_DATAINI
    EndIf

    SR8->(RestArea(aSR8Area))
    RestArea(aArea)
    ::oDataPrevAbs["lContinue"] := lPreviously

Return lPreviously

/*/{Protheus.doc} GetWorkingDayInPeriodo(cPerWork)
    
    Standart destructor

    @type Method
    @return 
    @author dchizhov
    @since 30.05.2024
    @version 12.1.23.10
    @example 
*/
Method Destroy() Class RUCalcAbsenceType

    FreeObj(::aAbsence)
    FreeObj(::aPerForAver)
    FreeObj(::aExperien)
    FreeObj(::aDayAver)
    FreeObj(::oDataPrevAbs)

    ::aAbsence := Nil
    ::aPerForAver := Nil
    ::aExperien := Nil
    ::aDayAver := Nil
    ::oDataPrevAbs := Nil

Return 
