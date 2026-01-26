#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07XFUN.CH"

#DEFINE WORK_EXPERIENCE_REFTYPES {"02"}

#DEFINE NOT_WORKING_DAY "2"

#DEFINE WAGE_TYPE_PAYMENT "1"                // RV_TIPOCOD
#DEFINE DISCOUNT_TYPE_PAYMENT "2"       // RV_TIPOCOD
#DEFINE WAGE_TYPE_FOR_AVERAGES "AV"          // RV_MEDFER, RV_AVERINC, RV_MEDAVI.
#DEFINE WAGE_TYPE_FOR_FSS_CONTRIBUTION "S"   // RV_MEDFER, RV_AVERINC
#DEFINE VACATION_YES "S" // RV_REFFER = "Yes".
#DEFINE VACATION_NO "N" // RV_REFFER = "No".
#DEFINE ADVANCE_YES "S" // RV_ADIANTA = "Yes".
#DEFINE ADVANCE_NO "N" // RV_ADIANTA = "No".

#DEFINE FOREIGNER_NONRESIDENT "02|05"        // RA_CLASEST

#DEFINE S001_COLUMNS_NUMBER 10
#DEFINE S002_COLUMNS_NUMBER 21
#DEFINE S037_COLUMNS_NUMBER 21
#DEFINE S038_COLUMNS_NUMBER 22
#DEFINE S043_COLUMNS_NUMBER 31

#DEFINE NDFL_VACATION_PAYMENT_TYPE "414"
#DEFINE NDFL_PAYMENT_TYPE "413"
#DEFINE NDFL_PREVIOUS_MONTH_PAYMENT_TYPE "603"
#DEFINE MONTH_SALARY_PAYMENT "001"
#DEFINE HOURLY_SALARY_PAYMENT "002"

#DEFINE COD_PAYMENT_INDEX 1 // For example, aPd[nI][1] = "675".
#DEFINE SUM_PAYMENT_INDEX 5 // For example, aPd[nI][5] = 234.56.

#DEFINE CODE_OF_PROCESS_MONTHLY_EMPLOYMENT_CONTRACT "00001"

#DEFINE ADVANCE_SCENARIO_NAME "ADI"
#DEFINE SALARY_SCENARIO_NAME "FOL"
#DEFINE VACATION_SCENARIO_NAME "FER"
#DEFINE TERMINATION_SCENARIO_NAME "RES"

#DEFINE COD_PAYMENT_INDEX 1 // For example, aPd[nI][1] = "675".
#DEFINE SUM_PAYMENT_INDEX 5 // For example, aPd[nI][5] = 234.56.

#DEFINE ALIMONY_YES "S" // RV_PENSAO.
#DEFINE ALIMONY_NO "N" // RV_PENSAO.

#DEFINE IS_NORTHALLOW 39 // RV_NA.
#DEFINE IS_DISTRCOEFF 40 // RV_DC.
#DEFINE NORTHALLOW_YES "1" // RV_NA = "Yes".
#DEFINE DISTRCOEFF_YES "1" // RV_DC = "Yes".
#DEFINE BASE_NORTHALLOW "83" + CHR(208) // RV_COD for the base of Northern Allowance.
#DEFINE BASE_DISTRCOEFF "84" + CHR(208)// RV_CODL for the base of District Coefficients.

#DEFINE COD_FOL_FOR_CARE_CHILD_3 "1768"

#DEFINE EXPERIENCE_MAX_COLUMN 8

#DEFINE AVERAGE_COUNT_DAY_IN_MOUNTH 30.41

// Static arrays for caching SRV-related SQL queries results
Static __aSRVBTCodes
Static __aSRVAverages
Static __aSRVFSSCodes

/*/{Protheus.doc} RU07CHKRS(cMat As Char)
    Checks if the employee with transfered reg. number is a tax resident of the Russian Federation
        based on their abroad absence (table SR8).

    @type Function
    @params cMat,    Char,    Employee's registration number
    @author dtereshenko
    @since 02/19/2020
    @version 12.1.23
    @return lIsResident,    Logical,    Indicator of whether the employee is a tax resident
*/
Function RU07CHKRS(cMat As Char)
    Local lIsResident := .T.
    Local oStatement As Object
    Local cQuery As Char
    Local cCurrentYear := SubStr(DToS(dDataBase), 1, 4)
    Local cYearStart As Char
    Local cYearEnd As Char
    Local dDateStart As Date
    Local dDateEnd As Date
    Local nDaysAbroad := 0
    Local aSavedArea := GetArea()

    // Check if employee is non-resident foreigner by default SRA information (RA_CLASEST)
    If SRA->RA_CLASEST $ FOREIGNER_NONRESIDENT
        lIsResident := .F.
        Return lIsResident
    EndIf

    cQuery := "SELECT R8_DATAINI, R8_DATAFIM FROM " + RetSQLName("SR8") + " WHERE R8_FILIAL = ? AND R8_MAT = ? AND R8_ABROAD = ? AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New()

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, FWxFilial("SR8"))
    oStatement:SetString(2, cMat)
    oStatement:SetString(3, "T")

    cAbroadAbsences := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cAbroadAbsences)
    (cAbroadAbsences)->(DbGoTop())
    While !EoF()
        cYearStart := SubStr((cAbroadAbsences)->R8_DATAINI, 1, 4)
        cYearEnd := SubStr((cAbroadAbsences)->R8_DATAFIM, 1, 4)

        If cYearStart == cCurrentYear .Or. cYearEnd == cCurrentYear
            dDateStart := IIf(cYearStart == cCurrentYear, SToD((cAbroadAbsences)->R8_DATAINI), SToD(cCurrentYear + "0101"))
            dDateEnd := IIf(cYearEnd == cCurrentYear, SToD((cAbroadAbsences)->R8_DATAFIM), SToD(cCurrentYear + "1231"))
            nDaysAbroad += dDateEnd - dDateStart
        EndIf

        DBSkip()
    EndDo
    DBCloseArea()
    RestArea(aSavedArea)

    lIsResident := ( nDaysAbroad <= 183 )

Return lIsResident

/*/{Protheus.doc} fRUGetNP(cS207ID As Char)
    Function for getting the percentage value from table S207 (Northern Premium)

    @type Function
    @params cS205ID,    Char,    S207 entry code
    @author dtereshenko
    @since 02/28/2020
    @version 12.1.23
    @return nNP,    Numeric,    Value of NP percentage
*/
Function fRUGetNP(cS207ID As Char)
    Local aS207Lines := {}
    Local nNP := 0 As Numeric
    Local nI As Numeric

    fCarrTab(@aS207Lines, "S207", dDataBase, .T.)

    For nI := 1 To Len(aS207Lines)
        If aS207Lines[nI][1] == "S207"
            If RU07XFUN16_AssembleCodWithPercentNP(aS207Lines[nI][5], aS207Lines[nI][6]) == AllTrim(cS207ID)
                nNP := aS207Lines[nI][6]
            EndIf
        EndIf
    Next nI

Return nNP

/*/{Protheus.doc} RU07DataUpload()
    Function for uploading master-data required for control example of salary calculation

    @type Function
    @params
    @author dtereshenko
    @since 03/03/2020
    @version 12.1.25
    @return
*/
Function RU07DataUpload()
    Local aTablesForUpload As Array
    Local nI As Numeric
    Local aCodFol As Array

    aTablesForUpload := {"RCB", "RCC", "RCA", "SRV", "RCN", "RCM", "RC2", "RC3", "SRY", "SRM"}

    For nI := 1 To Len(aTablesForUpload)
        TCDelFile(RetSqlName(aTablesForUpload[nI]))
    Next nI

    GpIniTab()   // RCB - Parameters Configuration (gpea310)
    GpTABCRG()
    GpIniCRG()   // RCC - Parameters (gpea320)

    fCarPD()     // SRV - Budgets (gpea040)
    Fp_CodFol(aCodFol, xFilial("RCN"), .F.) // RCN - Calculation Identifiers (gpea040)

    gpea430()    // RCM - Absence Types (static fCargaRCM)
    fCarMnemo()  // RCA - Mnemonics (gpea300)
    gpea160m()   // SRY, SRM, RC2, RC3 - Calculation Procedures, Calculation Script Items, Formulas Headers, Formulas

Return

/*/{Protheus.doc} fRUGetRF(cDept As Char, cCC As Char, cRegion As Char, cState As Char, cCityCode As Char)
    Function for getting the percentage value from table S206 (Regional Factor)
    according to parts of its essential key

    @type Function
    @params cDept,        Char,       Department (RA_DEPTO)
            cCC,          Char,       Cost Center (RA_CC)
            cRegion,      Char,       Department Region (QB_REGIAO)
            cState,       Char,       State (RA_ESTADO)
            cCityCode,    Char,       City Code (RA_CODMUN)
    @return nRegFactor,   Numeric,    Value of RF percentage
    @author dtereshenko
    @since 03/17/2020
    @version 12.1.23
*/
Function fRUGetRF(cDept As Char, cCC As Char, cRegion As Char, cState As Char, cCityCode As Char)
    Local aRegFactors := {} As Array
    Local nI As Numeric
    Local nJ As Numeric
    Local nRFFilledFields As Numeric
    Local nRegFactorValue := 0 As Numeric

    Default cRegion := ""

    fCarrTab(@aRegFactors, "S206", dDataBase, .T.)

    For nI := 1 To Len(aRegFactors)
        If aRegFactors[nI][1] == "S206"

            nRFFilledFields := 0

            For nJ := 8 To 12 // S206 column numbers for Regional Factor complex ID
                If !Empty(aRegFactors[nI][nJ])
                    nRFFilledFields += 1
                EndIf
            Next nJ

            If nRFFilledFields == 1 // Regional Factor has only 1 part of ID - need to check with "Or"
                If (AllTrim(aRegFactors[nI][8]) == AllTrim(cDept) .And. !Empty(cDept)) .Or. ;
                    (AllTrim(aRegFactors[nI][9])  == AllTrim(cCC) .And. !Empty(cCC)) .Or. ;
                    (AllTrim(aRegFactors[nI][10]) == AllTrim(cRegion) .And. !Empty(cRegion)) .Or. ;
                    (AllTrim(aRegFactors[nI][11]) == AllTrim(cState) .And. !Empty(cState)) .Or. ;
                    (AllTrim(aRegFactors[nI][12]) == AllTrim(cCityCode) .And. !Empty(cCityCode))

                    nRegFactorValue := aRegFactors[nI][6]
                    Exit
                EndIf
            EndIf

            // Regional Factor has several parts of ID - need to check with "And"
            If AllTrim(aRegFactors[nI][8]) == AllTrim(cDept) .And. ;
                AllTrim(aRegFactors[nI][9])  == AllTrim(cCC) .And. ;
                AllTrim(aRegFactors[nI][10]) == AllTrim(cRegion) .And. ;
                AllTrim(aRegFactors[nI][11]) == AllTrim(cState) .And. ;
                AllTrim(aRegFactors[nI][12]) == AllTrim(cCityCode)

                nRegFactorValue := aRegFactors[nI][6]
                Exit
            EndIf
        EndIf
    Next nI

Return nRegFactorValue

/*/{Protheus.doc} fRUGetAV()
    Function for retrieving array of SRV codes required for average salary calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author dtereshenko
    @since 06/01/2020
    @version 12.1.23
*/
Function fRUGetAV()
    Local cSRVFilial := FWxFilial("SRV")
    Local aSavedArea := GetArea()
    Local aSRVAverages := {}
    Local oStatement As Object
    Local cQuery As Char
    Local cQueryResult As Char
    Local nPos  :=  0

    // Check if SRVAverages has been cached before
    // cEmpAnt - global variable, companies group code (e.g. "10")
    If __aSRVAverages != Nil
        nPos := Ascan(__aSRVAverages, {|x| x[1] == cEmpAnt + cSRVFilial})
    Else
        __aSRVAverages := {}
    EndIf

    If nPos == 0
        oStatement := FWPreparedStatement():New()
        cQuery := "SELECT RV_COD FROM " + RetSQLName("SRV") + " WHERE "
        cQuery += "RV_FILIAL = ? AND "
        cQuery += "RV_TIPOCOD = ? AND "
        cQuery += "RV_MEDFER = ? AND "
        cQuery += "D_E_L_E_T_ = ' ' "

        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, cSRVFilial)
        oStatement:SetString(2, WAGE_TYPE_PAYMENT)
        oStatement:SetString(3, WAGE_TYPE_FOR_AVERAGES)

        cQueryResult := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cQueryResult)
        DBGoTop()

        While !EoF()
            AAdd(aSRVAverages, RV_COD)
            DBSkip()
        EndDo

        DbCloseArea()
        RestArea(aSavedArea)

        // Destroy FWPreparedStatement object.
        oStatement:Destroy()
        FwFreeObj(oStatement)

        AAdd(__aSRVAverages, {cEmpAnt + cSRVFilial, aSRVAverages})
    Else
        aSRVAverages := __aSRVAverages[nPos, 2]
    EndIf

Return aSRVAverages

/*/{Protheus.doc} fRUMIDMED(aSRVAverages As Array)
    Function for retrieving sum of AV-type payments

    @type Function
    @params aSRVAverages,       Array,      Array of SRV AV-type codes
    @return nSRVAveragesSum,    Numeric,    Sum of values (RC_VALOR) with AV-type codes
    @author dtereshenko
    @since 06/01/2020
    @version 12.1.23
*/
Function fRUMIDMED(aSRVAverages As Array)
    Local nI As Numeric
    Local cSRVCodes := ""
    Local nSRVAveragesSum := 0

    Default aSRVAverages := {}

    For nI := 1 To Len(aSRVAverages)
        cSRVCodes += aSRVAverages[nI] + "|"
    Next nI

    nSRVAveragesSum := FBuscaPD(cSRVCodes)

Return nSRVAveragesSum

/*/{Protheus.doc} RU07XFUN01_WorkShiftEmptyHours(cTurno As Char)
    Checks whether transfered Work Shift doesn't contain number of working hours

    @type Function
    @params cTurno,         Char,       Work Shift ID (R6_TURNO)
    @return lHoursEmpty,    Logical,    Check result
    @author dtereshenko
    @since 2020/07/02
    @version 12.1.23
*/
Function RU07XFUN01_WorkShiftEmptyHours(cTurno As Char)
    Local lHoursEmpty As Logical

    lHoursEmpty := Empty(Posicione("SR6", 1, FWxFilial("SR6") + cTurno, "R6_HRNORMA"))

Return lHoursEmpty

/*/{Protheus.doc} fRUGetRccConteo(cCodigo As Char, cKey As Char)
    Returns RCC_CONTEU by given RCC_CODIGO and first RCC_CONTEU part

    @type Method
    @params cCodigo,    Char,    RCC_CODIGO
            cKey,       Char,    First RCC_CONTEU part
    @author dtereshenko
    @since 10/02/2019
    @version 12.1.23
    @return cRccConteo,    Char,    RCC_CONTEU
/*/
Function fRUGetRccConteo(cCodigo As Char, cKey As Char)
    Local cRccConteo := ""
    Local aSavedArea := GetArea()
    Local oStatement := FWPreparedStatement():New()
    Local cQuery As Char
    Local cRccRecord As Char

    cQuery := "SELECT RCC_CONTEU FROM " + RetSQLName("RCC") + " WHERE "
    cQuery += "RCC_FILIAL = ? AND "
    cQuery += "RCC_CODIGO = ? AND "
    If !Empty(cKey)
        cQuery += "SUBSTRING(RCC_CONTEU, 1, ?) = ? AND "
    Endif
    cQuery += "D_E_L_E_T_ = ' ' "

    //Use change query to setup SUBSTRING correctly for each DB
    cQuery := ChangeQuery2(cQuery)

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, FWxFilial("RCC"))
    oStatement:SetString(2, cCodigo)
    If !Empty(cKey)
        oStatement:SetNumeric(3, Len(cKey))
        oStatement:SetString(4, cKey)
    EndIf

    cRccRecord := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cRccRecord)
    cRccConteo := (cRccRecord)->RCC_CONTEU

    DbCloseArea()
    RestArea(aSavedArea)

    oStatement:Destroy()
    FwFreeObj(oStatement)
Return cRccConteo

/*/{Protheus.doc} fRUGetCIC(cMat As Char)
    Returns SNILS (RA_CIC) of given employee by reg. number (RA_MAT)

    @type Method
    @params cMat,   Char,   Employee's reg. number (RA_MAT)
    @return cCIC,   Char,   Employee's SNILS (RA_CIC)
    @author dtereshenko
    @since 2020/07/21
    @version 12.1.23
*/
Function fRUGetCIC(cMat As Char)
    Local cCIC := ""
    Local aSavedArea := GetArea()

    dbSelectArea("SRA")
    dbSetOrder(1) // RA_FILIAL + RA_MAT + RA_NOME
    If SRA->(dbSeek(xFilial("SRA") + cMat))
        cCIC := SRA->RA_CIC
    EndIf

    RestArea(aSavedArea)

Return cCIC

/*/{Protheus.doc} fRuDisDay
    Number of days of absence of corresponding PT not subject to FSS contributions 
    (Days excluded when calculating the average for payment of pregnancy and childbirth)

    @type  Function
    @author vselyakov
    @since 2020/07/23
    @version 12.1.23
    @param cMat,      Char, Employee personnel number
           dBaseDate, Date, Date for calculating day without Sick Leave and pregnancy and childbirth count in month.
    @return Numeric, Number of days without sick and maternity absences
    @example fRuDisDay('000019', STOD('20200305'))
*/
Function fRuDisDay(cMat As Char, dBaseDate As Date)
    Local nDays      := 0
    Local cMonth     := Substr(DTOS(dBaseDate), 1, 6)
    Local aCurArea   := GetArea()
    Local aValues    := {}
    Local cQuery       As Character
    Local cQueryResult As Character
    Local cMonStart    As Character
    Local cMonFin      As Character

    Default dBaseDate := dDataBase

    // SQL query for a list of absences for which the employee is not subject to Social Security contributions.
    cQuery := "SELECT SR8.R8_DATAINI AS DINIT, SR8.R8_DATAFIM AS DFIN, SR8.R8_DURACAO FROM " + RetSQLName("SR8") + " SR8 "
    cQuery += "INNER JOIN " +  RetSQLName("SRV") + " SRV ON SRV.RV_COD = SR8.R8_PD AND SRV.RV_INSS = 'N' AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE "
    cQuery += "SR8.R8_FILIAL = ? AND "
    cQuery += "SR8.R8_MAT = ? AND "
    AAdd(aValues, FWxFilial("SR8"))
    AAdd(aValues, cMat)

    cQuery += "SR8.D_E_L_E_T_=' ' "

    cQueryResult := GetNextAlias()
    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cQueryResult, .T., .F.)
    DBSelectArea(cQueryResult)
    DBGoTop()

    While !EoF()
        cMonStart := Substr((cQueryResult)->DINIT, 1, 6)
        cMonFin   := Substr((cQueryResult)->DFIN, 1, 6)

        If cMonth == cMonStart .And. cMonth == cMonFin
            nDays += (cQueryResult)->R8_DURACAO // (STOD((cQueryResult)->DFIN) - STOD((cQueryResult)->DINIT)) + 1
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()
    RestArea(aCurArea)

Return nDays

/*/{Protheus.doc} fRUDisShCal(cMat As Char, dBaseDate As Date, lCountAbsences As Logical, oMonths As Object)
    Returns average earnings for paying a disability sheet according to legal rules.

    @type Function
    @params cMat,           Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate       Date,       Date for calculating average earnings for the previous period (last 2 years)
            lCountAbsences  Logical,    Have we take into account employee's DS absences or not
            oMonths         Object,     Output RUMap with calendar days without absences & receiving INSS-payments per period
            lAccountMin     Logical,    Shows that there is need to compare with the minimum wage (default True).
    @return nAverDSValue,   Numeric,    Average employee earnings per day for the previous period (12 months)
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Function fRUDisShCal(cMat As Char, dBaseDate As Date, lCountAbsences As Logical, oMonths As Object, lAccountMin As Logical)
    Local cPeriod As Char
    Local nI As Numeric
    Local nJ As Numeric
    Local nMinAverDSValue As Numeric
    Local nTwoYearsDays As Numeric
    Local nDSAbsenceDays := 0 As Numeric
    Local aYearInfo As Array
    Local nAverDSValue := 0
    Local aYearsAverages := {0, 0}
    Local aYearsPeriods := {{}, {}}
    Local aPeriods := {}

    Local cRUSAvDSDaysCodFol := aCodFol[1750, 1]
    Local cRUSAvDSMoneyCodFol := aCodFol[1751, 1]

    Local aBaseYears := {CValToChar(Year(dBaseDate) - 2), CValToChar(Year(dBaseDate) - 1)} // Simple case, can be more complicated
    Local nBaseMonth := 0

    Local aFSSLimits := {GetFSSLimit(aBaseYears[1]), GetFSSLimit(aBaseYears[2])}

    Local aRef182n  As Array
    Local lRefLoaded As Logical
    Local nRegCoef As Numeric // Get regional factor coefficient.

    Default lAccountMin := .T.

    nRegCoef := fRuGetRF(SRA->RA_DEPTO, SRA->RA_CC, /*QB_REGIAO*/,SRA->RA_ESTADO, SRA->RA_CODMUN) * 0.01
    aRef182n := RU07XFUN35_Ref182n(cMat)

    lRefLoaded := Iif(len(aRef182n)>0, .T., .F.)
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
    RU07XVAC02_GetSRCAvRecords(cMat, aPeriods[Len(aPeriods)], cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

    // Check payments from closed periods
    RU07XVAC03_GetSRDAvRecords(cMat, aPeriods, cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

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
    For nI := 1 To 2
        For nJ := 1 To Len(aYearsPeriods[nI])
            aYearsAverages[nI] += aYearsPeriods[nI][nJ][2][2]
            nDSAbsenceDays += aYearsPeriods[nI][nJ][2][1]
        Next nJ

        // Load information from 182n reference
        For nJ := 1 To Len(aRef182n)
            If aBaseYears[nI] == aRef182n[nJ][1]
                aYearsAverages[nI] += aRef182n[nJ][2]
                nDSAbsenceDays += Val(aRef182n[nJ][3])
            EndIf
        Next nJ

        // Correct if year sum more than FSS limit
        If aFSSLimits[nI] != 0 .And. aYearsAverages[nI] > aFSSLimits[nI]
            aYearsAverages[nI] := aFSSLimits[nI]
        EndIf
        
        If Type("oRU07XFU01") == "O"
            oRU07XFU01:aLastYear[nI, 1] := aBaseYears[nI]
            oRU07XFU01:aLastYear[nI, 2] := aYearsAverages[nI]
        EndIf
    Next nI

    If lCountAbsences
        nTwoYearsDays := GetYearDaysNumber(aBaseYears[1]) + GetYearDaysNumber(aBaseYears[2]) - nDSAbsenceDays
    Else
        nTwoYearsDays := GetTwoYearsDays()
    EndIf

    // Calculate daily average
    nAverDSValue := (aYearsAverages[1] + aYearsAverages[2]) / nTwoYearsDays

    If Type("oRU07XFU01") == "O"
        oRU07XFU01:nCDays := nTwoYearsDays
    EndIf

    // Calculate minimal daily average
    nMinAverDSValue := GetMinimalWage(AnoMes(dBaseDate)) * 24 * (1 + nRegCoef) / GetTwoYearsDays()

    // Correct if daily average less than minimal one
    If lAccountMin .And. nAverDSValue < nMinAverDSValue
        nAverDSValue := nMinAverDSValue
    EndIf

Return nAverDSValue

/*/{Protheus.doc} GetTwoYearsDays()
    Returns average days number in two years (S208 table)

    @type Function
    @params
    @return nDays,    Numeric,    Average number of days (by government decree)
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetTwoYearsDays()
    Local nDays As Numeric

    nDays := RU07XFUN32_GetAbsenceDays()

Return nDays

/*/{Protheus.doc} GetFSSLimit()
    Returns maximum amount of FSS payments by year (S001)

    @type Function
    @params cYear,       Char,       Required year
    @return nFSSLimit,   Numeric,    Maximum amount of FSS payments
    @author dtereshenko
    @since 2020/08/13
    @version 12.1.23
*/
Function GetFSSLimit(cYear As Char)
    Local cRccConteo As Char
    Local nFSSLimit As Numeric

    cRccConteo := fRUGetRccConteo("S001", cYear)

    nFSSLimit := Val(SubStr(cRccConteo, 13, 12))

Return nFSSLimit

/*/{Protheus.doc} GetYearDaysNumber(cYear as Char)
    Returns number of days in year

    @type Function
    @params cYear,   Char,       Required year
    @return nDays,   Numeric,    Number of days
    @author dtereshenko
    @since 2020/08/13
    @version 12.1.23
*/
Static Function GetYearDaysNumber(cYear as Char)
    Local nDays As Numeric

    nDays := SToD(cYear + "1231") - SToD(cYear + "0101") + 1

Return nDays

/*/{Protheus.doc} GetMinimalWage(cPeriodCode as Char)
    Returns minimal month wage in transfered yyyymm (S004)

    @type Function
    @params cPeriodCode, Char, Required period
    @return nMinWage,   Numeric,   Minimal month wage
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetMinimalWage(cPeriodCode as Char)
    Local nMinWage As Numeric

    /*
        Table S004:
        * Column #4 - start period
        * Column #5 - end period
        * Column #6 - minimal month wage
    */
    nMinWage := fPosTab("S004", cPeriodCode, ">=", 4, cPeriodCode, "<=", 5, 6)

Return nMinWage

/*/{Protheus.doc} fAbsences(cMat As Char, cPeriod As Char)
    Calculates and pays a disability sheet payment from allocated budget

    @type Function
    @params cMat,     Char,       Employee's Reg. Number (RA_MAT)
            cPeriod   Char,       Required period (YYYYMM)
            aAbsNeed, Array,      If need calculate same absence. (first element is type calculation)
    @return
    @author dtereshenko
    @since 2020/09/02
    @version 12.1.23
*/
Function fAbsences(cMat As Char, cPeriod As Char, aAbsNeed As Array)
    Local aDSAbsenceTypes As Array
    Local aSavedArea := GetArea() As Array
    Local aAbsences := {} As Array
    Local nExpDays := 0 As Numeric
    Local nExpMonth := 0 As Numeric
    Local nExpCoef := 0 As Numeric
    Local nExpYears := 0 As Numeric
    Local nAverDSValue As Numeric
    Local nMinAverDSValue As Numeric
    Local nDSDays As Numeric
    Local nDSValue As Numeric
    Local nI As Numeric
    Local cQuery As Char
    Local cAbsences As Char
    Local aValues := {} As Array
    Local lHasRollingSickLeave As Logical
    Local SRAArrea As Array
    Local RUCalcAbType As Object
    Local cError As Character
    Local lNoExperience As Logical
    Local lNeedSimulation As Logical
    Local lNSimulation As Logical
    Local oExperience As Object
    Local aSR8Area := SR8->(GetArea()) As Array

    Default aAbsNeed := {0}

    lNSimulation := .F.

    If Type("oRU07XFU01") == "U"
        Private oRU07XFU01 := RUHRElnDataForElnItem():New("01")
        lNSimulation := .T.
    EndIf

    // Fill absences types
    aDSAbsenceTypes := {"003", "004", "006", "007", "008", "009", "010", "011", "017", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029", "052"}
    // Collect all DS-related absences within transfered period
    cQuery := "SELECT R8_TIPOAFA, R8_DATAINI, R8_DATAFIM, R8_PD, R8_SEQ, R8_CONTAFA, R8_CHILDS, R8_BALYEAR, R8_VIOLAT, R_E_C_N_O_ AS RECN FROM " + RetSQLName("SR8") + " WHERE "
    If aAbsNeed[1] == 0
        cQuery += "R8_FILIAL = ? AND "
        cQuery += "R8_MAT = ? AND "
        AAdd(aValues, FWxFilial("SR8"))
        AAdd(aValues, cMat)

        cQuery += "(SUBSTRING(R8_DATAINI, 1 , 6) = ? OR "
        cQuery += "((? BETWEEN SUBSTRING(R8_DATAINI, 1 , 6) AND SUBSTRING(R8_DATAFIM, 1 , 6)) AND "
        AAdd(aValues, cPeriod)
        AAdd(aValues, cPeriod)

        cQuery += "R8_PD IN (" + RusSetQryIn({aCodFol[Val(COD_FOL_FOR_CARE_CHILD_3), 1]}, @aValues) + "))) AND "
    ElseIf aAbsNeed[1] == 1
        cQuery += "R_E_C_N_O_ IN (" + RusSetQryIn(aAbsNeed[2], @aValues) + ") AND " 
    EndIf
    cQuery += "D_E_L_E_T_ = ' ' "
    cQuery += " AND R8_STATUS <> 'O' " // 'O' - it is canceled absence.

    cQuery := ChangeQuery2(cQuery)

    cAbsences := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAbsences, .T., .F.)

    DbSelectArea(cAbsences)
    DbGoTop()

    While !(cAbsences)->(Eof())
        SR8->(DbGoTo((cAbsences)->RECN))

        If !lDissidio
            If MesAno(SR8->R8_DATAINI) == cPeriodo .And. SR8->R8_STATUS != "T" // Status "T" - is status for retrocalculation.
                AAdd(aAbsences, {(cAbsences)->R8_TIPOAFA, SToD((cAbsences)->R8_DATAINI), SToD((cAbsences)->R8_DATAFIM), (cAbsences)->R8_PD, ;
                (cAbsences)->R8_SEQ, (cAbsences)->R8_CONTAFA, (cAbsences)->R8_BALYEAR, SToD((cAbsences)->R8_VIOLAT), (cAbsences)->RECN, (cAbsences)->R8_CHILDS})
            EndIf
        Else
            AAdd(aAbsences, {(cAbsences)->R8_TIPOAFA, SToD((cAbsences)->R8_DATAINI), SToD((cAbsences)->R8_DATAFIM), (cAbsences)->R8_PD, ;
                (cAbsences)->R8_SEQ, (cAbsences)->R8_CONTAFA, (cAbsences)->R8_BALYEAR, SToD((cAbsences)->R8_VIOLAT), (cAbsences)->RECN, (cAbsences)->R8_CHILDS})
        EndIf

        (cAbsences)->(DbSkip())
    EndDo

    (cAbsences)->(DbCloseArea())
    SR8->(RestArea(aSR8Area))
    RestArea(aSavedArea)

    // Calculate and pay from allocated budget (will be much more complicated)
    For nI := 1 To Len(aAbsences)
        nDSDays := RU07XFUN46_GetR8Dpagar(aAbsences[nI, 10]) // For develop need element 10!
        
        // Calculation work experience.
        oExperience := RUExperienceCalculation():New()
        nExpCoef := oExperience:GetCoefficientExperience(cMat, .T., Nil, aAbsences[nI, 2])

        nExpYears := oExperience:aExperienceArray[1]
        nExpMonth := oExperience:aExperienceArray[2]
        nExpDays := oExperience:aExperienceArray[3]

        FwFreeObj(oExperience)

        // A flag that indicates whether this type of absence is among those for which modeling is needed (modeling is necessary for proactive payments). 
        // The ability to model is needed for all types of absence that can be used in an electronic certificate of incapacity for work. 
        // When implementing a new type of absence, it is necessary to take into account the need to be able to simulate the calculation. 
        lNeedSimulation := RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "0041|0042|1767|0040|"  + COD_FOL_FOR_CARE_CHILD_3 // |0040|1769|"        // 0041, 0040,0042,1767,1768 ? 1769
        oRU07XFU01:SetDefEmptyVal()
        oRU07XFU01:nYExperience := nExpYears
        oRU07XFU01:nMExperience := nExpMonth
        oRU07XFU01:cSNILS := SRA->RA_CIC
        oRU07XFU01:cNome := SRA->RA_NOMECMP

        If RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "0040|0927" // Maternity
            // Calculate average DS day payment taking into account employye's absences
            nAverDSValue := fRUDisShCal(cMat, SToD(cPeriod + "01"), .T., RUMap():New())

            // If employee's work experience less than 6 months, average DS day payment is minimal
            If nExpYears < 1 .And. nExpMonth < 6
                nAverDSValue := nMinAverDSValue
            EndIf

            FGeraVerba(aCodFol[1753, 1], nExpDays) // Insurance experience in days at the time of payment

        ElseIf RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") == "1756" // Business trip
            nAverDSValue := RU07XFUN19_GetAverageForBuisnessTrips(cMat, SToD(cPeriod + "01"), RUMap():New(), aAbsences[nI][2], aAbsences[nI][3])

        ElseIf RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "0041" // "004|009|017|020" Temporary disability absences.
            If nExpYears < 1 .And. nExpMonth < 6
                lNoExperience := .T.
            Else
                lNoExperience := .F.
            EndIf

            RUCalcAbType := RUDisabilityCalculation():New(aAbsences[nI][1], nDSDays, aAbsences[nI][8], cPeriod, nExpCoef, aAbsences[nI][2], aAbsences[nI][9], lNoExperience, aAbsences[nI][6], aAbsences[nI][10])
            RUCalcAbType:Calculation()
            oRU07XFU01:dDateStart := RUCalcAbType:oAbsenceSettings:dStartDate
            oRU07XFU01:dDateFin := RUCalcAbType:oAbsenceSettings:dEndDate
            FwFreeObj(RUCalcAbType)

        Else // Temporary disability
            // Calculate average DS day payment without taking into account employye's absences
            nAverDSValue := fRUDisShCal(cMat, SToD(cPeriod + "01"), .F., RUMap():New())

            // If employee's work experience less than 6 months, average DS day payment is minimal
            If nExpYears < 1 .And. nExpMonth < 6
                nAverDSValue := nMinAverDSValue
            EndIf

            FGeraVerba(aCodFol[1753, 1], nExpDays) // Insurance experience in days at the time of payment
        EndIf

        Do Case

            Case RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "1752" 
                If nDSDays > 3
                    FGeraVerba(aCodFol[1752, 1], (nDSDays - 3) * nDSValue, nDSDays - 3)  // FSS payment
                EndIf

            Case RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") == "1756" // Business trip.
                FGeraVerba(aCodFol[1756, 1], nAverDSValue, nDSDays)

            // Payment for an industrial injury. and pergnant/childbirth and other
            Case RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "0042|1767|1769|0040|" + COD_FOL_FOR_CARE_CHILD_3
                oRU07XFU01:SetDefEmptyVal()
                oRU07XFU01:cSNILS := SRA->RA_CIC
                oRU07XFU01:cNome := SRA->RA_NOMECMP
                RUCalcAbType := RUCalcAbsenceType():New(aAbsences[nI][1], aAbsences[nI][4], , aAbsences[nI][2], aAbsences[nI][3], cPeriod, ;
                Iif(RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "1767|" + COD_FOL_FOR_CARE_CHILD_3, aAbsences, {}), nI, aAbsences[nI][7], aAbsences[nI][10])

                If RUCalcAbType:Calculation(cMat)
                    If AttIsMemberOf(RUCalcAbType, "aExperien") .And. ValType(RUCalcAbType:aExperien[1]) == "N"
                        oRU07XFU01:nYExperience := RUCalcAbType:aExperien[1]
                        oRU07XFU01:nMExperience := RUCalcAbType:aExperien[2]
                    ElseIf RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "0042|1767|1769" + COD_FOL_FOR_CARE_CHILD_3
                        oRU07XFU01:nYExperience := nExpYears
                        oRU07XFU01:nMExperience := nExpMonth
                    EndIf
                    oRU07XFU01:nRegKoeff := RUCalcAbType:nRegionalCoeff
                    oRU07XFU01:dDateStart := RUCalcAbType:dStartAbsence
                    oRU07XFU01:dDateFin := RUCalcAbType:dStartAbsence + RUCalcAbType:nDays - 1
                    FGeraVerba(RUCalcAbType:cPaymentType, RUCalcAbType:nValue, RUCalcAbType:nDays)
                Else
                    cError :=  CRLF + CRLF + RUCalcAbType:cError + CRLF + CRLF
                    FwFreeObj(RUCalcAbType)
                    UserException(cError)
                EndIf
                
                RUCalcAbType:Destroy()
                FwFreeObj(RUCalcAbType)
            // Payment for absences by average earnings.
            Case RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") $ "1770|1771|1772|1773|1774|1775|1776|1777|1778|1779|1780|1781|1782|1783"
                nAverDSValue := RU07XFUN19_GetAverageForBuisnessTrips(cMat, SToD(cPeriod + "01"), RUMap():New(), aAbsences[nI][2], aAbsences[nI][3])
                If RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL") == "1772"
                    FGeraVerba(aAbsences[nI][4], nAverDSValue * 2/3, nDSDays)
                Else
                    FGeraVerba(aAbsences[nI][4], nAverDSValue, nDSDays)
                EndIf
                

        EndCase

        If lNeedSimulation .And. (!FwIsInCallStack("GPEM020") .Or. FwIsInCallStack("GPEA580"))
            If !oRU07XFU01:Validate(.T.)
                If !IsBlind()
                    MsgInfo(STR0024 + " " + RetValSRV(aAbsences[nI][4], SRA->RA_FILIAL, "RV_CODFOL")) // "Problem with ID="
                EndIf
            EndIf
        EndIf
    Next nI
    
    lHasRollingSickLeave := RU07XFUN15_RollingSickLeave(cMat, cPeriod)

    If lNSimulation
        FwFreeObj(oRU07XFU01)
        oRU07XFU01 := Nil
    EndIf
    
    SRAArrea := SRA->(GetArea())
    DbSelectArea("SRA")
    
    If SRA->(dbSeek(SRA->RA_FILIAL + cMat ))
        lLock := RecLock("SRA",.F.,.T.)
        If lLock 
            If lHasRollingSickLeave .And. SRA->RA_SITFOLH == " "
                SRA->RA_SITFOLH := "A"
            ElseIf !lHasRollingSickLeave .And. SRA->RA_SITFOLH =="A"
                SRA->RA_SITFOLH := " "
            EndIf
            SRA->( MsUnLock() )
        EndIf
    EndIf

    RestArea(SRAArrea)
    RestArea(aSavedArea)
        
Return

/*/{Protheus.doc} fRUGetFSS()
    Function for retrieving array of SRV codes required for average disability sheet calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author dtereshenko
    @since 2020/09/03
    @version 12.1.23
*/
Function fRUGetFSS()
    Local cSRVFilial := FWxFilial("SRV")
    Local aSavedArea := GetArea()
    Local oStatement As Object
    Local cQuery As Char
    Local cQueryResult As Char
    Local nPos :=  0
    Local aSRVFSSCodes := {}

    // Check if SRVFSSCodes has been cached before
    // cEmpAnt - global variable, companies group code (e.g. "10")
    If __aSRVFSSCodes != Nil
        nPos := Ascan(__aSRVFSSCodes, {|x| x[1] == cEmpAnt + cSRVFilial})
    Else
        __aSRVFSSCodes  := {}
    EndIf

    If nPos == 0
        oStatement := FWPreparedStatement():New()
        cQuery := "SELECT RV_COD FROM " + RetSQLName("SRV") + " WHERE "
        cQuery += "RV_FILIAL = ? AND "
        cQuery += "RV_TIPOCOD = ? AND "
        cQuery += "RV_INSS = ? AND "
        cQuery += "D_E_L_E_T_ = ' ' "

        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, cSRVFilial)
        oStatement:SetString(2, WAGE_TYPE_PAYMENT)
        oStatement:SetString(3, WAGE_TYPE_FOR_FSS_CONTRIBUTION)

        cQueryResult := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cQueryResult)
        DBGoTop()

        While !EoF()
            AAdd(aSRVFSSCodes, RV_COD)
            DBSkip()
        EndDo

        DbCloseArea()
        RestArea(aSavedArea)

        // Destroy FWPreparedStatement object.
        oStatement:Destroy()
        FwFreeObj(oStatement)

        AAdd(__aSRVFSSCodes, {cEmpAnt + cSRVFilial, aSRVFSSCodes})
    Else
        aSRVFSSCodes := __aSRVFSSCodes[nPos, 2]
    EndIf

Return aSRVFSSCodes

/*/{Protheus.doc} fRUGetBT()
    Function for retrieving array of SRV codes required for average business trip calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author iprokhorenko
    @since 2020/09/08
    @version 12.1.23
*/
Function fRUGetBT()
    Local cSRVFilial := FWxFilial("SRV")
    Local aSavedArea := GetArea()
    Local oStatement As Object
    Local cQuery As Char
    Local cQueryResult As Char
    Local nPos  :=  0
    Local aSRVBTCodes := {}

    // Check if SRVBTCodes has been cached before
    // cEmpAnt - global variable, companies group code (e.g. "10")
    If __aSRVBTCodes != Nil
        nPos := Ascan(__aSRVBTCodes, {|x| x[1] == cEmpAnt + cSRVFilial})
    Else
        __aSRVBTCodes := {}
    EndIf

    If nPos == 0
        oStatement := FWPreparedStatement():New()
        cQuery := " SELECT RV_COD FROM " + RetSQLName("SRV") + " WHERE "
        cQuery += " RV_FILIAL = ? AND "
        cQuery += " RV_MEDAVI = ? AND "
        cQuery += " D_E_L_E_T_ = ' '  "

        oStatement:SetQuery(cQuery)
        oStatement:SetString(1, cSRVFilial)
        oStatement:SetString(2, WAGE_TYPE_FOR_AVERAGES)

        cQueryResult := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cQueryResult)
        DBGoTop()

        While !EoF()
            AAdd(aSRVBTCodes, RV_COD)
            DBSkip()
        EndDo

        DbCloseArea()
        RestArea(aSavedArea)

        // Destroy FWPreparedStatement object.
        oStatement:Destroy()
        FwFreeObj(oStatement)

        AAdd(__aSRVBTCodes, {cEmpAnt + cSRVFilial, aSRVBTCodes})
    Else
        aSRVBTCodes := __aSRVBTCodes[nPos, 2]
    EndIf

Return aSRVBTCodes

/*/{Protheus.doc} fRUGetBTDay
    Return in hours the number of workdays in the current period minus any workdays missing.

    @type  Function
    @author vselyakov
    @since 2020/09/07
    @version 12.1.23
    @param cMat, Character, Employee personnel number.
    @return nResult, Numeric, Working hours of employee.
    @example fRUGetBTDay("000019")
*/
Function fRUGetBTDay(cMat As Char)
    Local cMonthPaymentType    As Character // Payment type 001 (Monthly payment).
    Local cHourPaymentType     As Character // Payment type 002 (Hourly payment).
    Local nPositionPaymentType As Numeric // Payment position into aPd array.
    Local nEmpHrs              As Numeric // Working hours per day of employee.
    Local cProces              As Character // Process cod of employee.
    Local nResult              As Numeric // Hours count for employee.

    nResult  := 0
    nPositionPaymentType := 0
    cMonthPaymentType := aCodFol[0031, 1]
    cHourPaymentType  := aCodFol[0032, 1]

    // Get work hours per day and work shedule of employee.
    nEmpHrs := SRA->RA_HRSDIA
    cProces := SRA->RA_PROCES

    // Search for the type of payment for the monthly payment. This type of payment is calculated in days, so it converts to the number of hours.
    nPositionPaymentType := aScan(aPd, {|x| x[1] == cMonthPaymentType})

    If nPositionPaymentType > 0
        nResult += aPd[nPositionPaymentType][4] * nEmpHrs // aPd[i][4] - it is position of day (hour) count.
    EndIf
    
    // Search for the type of payment for the hourly payment.
    nPositionPaymentType := aScan(aPd, {|x| x[1] == cHourPaymentType})
    
    If nPositionPaymentType > 0
        nResult += aPd[nPositionPaymentType][4] // aPd[i][4] - it is position of day (hour) count.
    EndIf

Return nResult

/*/{Protheus.doc} GetExperienceCoeffs()
    Returns array with work experience coefficients for disability sheet calculation (S209)

    @type Function
    @params
    @return aExpCoeffs,   Array,   Array with work experience coefficients
    @author dtereshenko
    @since 2020/09/14
    @version 12.1.23
*/
Static Function GetExperienceCoeffs()
    Local aExpCoeffs := {}
    Local nI := 1
    Local cS209Content := fRUGetRccConteo("S209", "")
    Local nColumnCount := 0

    While nI < Len(AllTrim(cS209Content)) .And. nColumnCount < EXPERIENCE_MAX_COLUMN
        AAdd(aExpCoeffs, Val(SubStr(cS209Content, nI, 6)))
        nI += 6
        nColumnCount := nColumnCount + 1
    EndDo

Return aExpCoeffs

/*/{Protheus.doc} fGet730Days(dFirstYearDate As Date, dSecondYearDate As Date)
    Adds an extra day for each leap year in the period.
    Return days count.

    @type  Function
    @author vselyakov
    @since 2020/09/15
    @version 12.1.23
    @param dFirstYearDate,  Date, First date of period
           dSecondYearDate, Date, Second date of period
    @return nResult, Numeric, Days count.
    @example
        fGet730Days(dDataBase, dDataBase)
        fGet730Days(STOD('19000423'), STOD('20190301'))
        fGet730Days(STOD('19040423'), STOD('20160301'))
        fGet730Days(STOD('20200423'), STOD('20190301'))
*/
Function fGet730Days(dFirstYearDate As Date, dSecondYearDate As Date)
    Local nResult := 0 As Numeric

    nResult := RU07XFUN32_GetAbsenceDays(AllTrim(Str(Year(dFirstYearDate) - 1) + "01"), AllTrim(Str(Year(dSecondYearDate) - 1) + "01"))

Return nResult

/*/{Protheus.doc} fRUBTAvCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Returns average employee earnings per hour for the previous period (12 months)

    @type Function
    @params cMat,          Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate      Date,       Date for calculating average earnings for the previous period (12 months)
            oMonths        Object      Output RUMap with calendar days without absences & receiving AV-payments per period
    @return nAverValue,    Numeric,    Average employee earnings per day for the previous period (12 months)
    @author dtereshenko
    @since 2020/09/16
    @version 12.1.23
*/
Function fRUBTAvCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Local aMonths As Array
    Local aMonth As Array
    Local cMonth As Char
    Local nI As Numeric
    Local nAverValue As Numeric
    Local nAverHours := 0
    Local nAverMoney := 0

    Local cRUSAvHoursCodFol := aCodFol[1754, 1]
    Local cRUSAvMoneyCodFol  := aCodFol[1755, 1]

    // Fill aray by previous periods (months)
    aMonths := GetYearPeriods(dBaseDate, @oMonths)

    // Check payments from opened period
    RU07XVAC02_GetSRCAvRecords(cMat, aMonths[Len(aMonths)], cRUSAvHoursCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Check payments from closed periods
    RU07XVAC03_GetSRDAvRecords(cMat, aMonths, cRUSAvHoursCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Calculate average values
    oMonths:List(aMonths)
    For nI := 1 To Len(aMonths)
        cMonth := aMonths[nI][1]
        aMonth := aMonths[nI][2]

        If aMonth[1] == 0 .And. aMonth[2] == 0
            oMonths:Del(cMonth)
        Else
            nAverHours += aMonth[1]
            nAverMoney += aMonth[2]
        EndIf
    Next nI

    nAverValue := nAverMoney / nAverHours

Return nAverValue

/*/{Protheus.doc} GetYearPeriods(dBaseDate As Date, oMonths As Object)
    Returns aray, filled by previous periods (months) during the year

    @type Function
    @params dBaseDate   Date,       Date for calculating average earnings for the previous period (12 months)
            oMonths     Object      Output RUMap for collecting previous payments
    @return aMonths,    Array,      Previous periods (months) - "YYYYMM"
    @author dtereshenko
    @since 2020/09/16
    @version 12.1.23
*/
Static Function GetYearPeriods(dBaseDate As Date, oMonths As Object)
    Local nBaseYear := Year(dBaseDate) As Numeric
    Local nBaseMonth := Month(dBaseDate) As Numeric
    Local aMonths := {} As Array
    Local cMonth As Char
    Local nI As Numeric

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

Return aMonths

/*/{Protheus.doc} fRUAbsencesValidation()
    Part of R8_TIPOAFA validation (GPEA240). Clears grid line fields when absence type was changed.
    Fork of Gp240ValAfa()

    @type Function
    @params
    @return lVldResult,    Logical,      Validation result
    @author dtereshenko
    @since 2020/09/22
    @version 12.1.23
*/
Function fRUAbsencesValidation()
    Local lVldResult := .T.
    Local oModel := FWModelActivate()
    Local oGrid := oModel:GetModel("GPEA240_SR8")
    Local cField := SubStr(ReadVar(), 4)
    Local xReadVar := &(ReadVar())

    If !Empty(oGrid:GetValue("R8_DURACAO"))
        oGrid:SetValue("R8_DURACAO", 0)
        oGrid:SetValue("R8_DPAGAR", 0)
        oGrid:SetValue("R8_TIPOAT", "")
        oGrid:SetValue("R8_NMMED", "")
        oGrid:SetValue("R8_IDEOC", "")
        oGrid:SetValue("R8_CRMMED", "")
        oGrid:SetValue("R8_UFCRM", "")
        oGrid:SetValue("R8_CNPJCES", "")
        oGrid:SetValue("R8_TPCES", "")
        oGrid:SetValue("R8_CNPJSIN", "")
        oGrid:SetValue("R8_TPSIND", "")
    EndIf

    lExec := .T.

    If cField == "R8_TIPOAFA" .And. xReadVar == "024"
        MsgInfo(STR0023) // "This certificate of incapacity for work will be paid depending on the employee’s length of service. If the length of service should not be taken into account, select «Yes» in the «Experience Cancellation» field"
    EndIf

Return lVldResult

/*/{Protheus.doc} fChkDisDsRUS(cMat, dBaseDate)
    Sets absence days and lost vacation days when calculating vacation.

    @type Function
    @params
    @return
    @author vselyakov
    @since 2020/09/28
    @version 12.1.23
*/
Function fChkDisDsRUS(cMat, dBaseDate)
    Local nDays        As Numeric
    Local nDays035     As Numeric
    Local aCurArea     As Array
    Local aAbsCodes    As Array
    Local cQuery       As Character
    Local cQueryResult As Character
    Local dAdmis       As Date
    Local nDIALREMDays As Numeric
    Local nMonth       As Numeric
    Local nDayRst      As Numeric
    Local aValues      := {}

    Default dBaseDate := dDataBase

    aCurArea := GetArea()
    nDays := 0
    nDays035 := 0
    nMonth := 0
    nDIALREMDays := 0
    dAdmis := SRA->RA_ADMISSA // Get admiss date for employee.

    // Fill array of absences types.
    aAbsCodes := { '011', '012', '030', '042', '035' }

    // SQL query for the list of absences for the employee, except for the codes of absences in the aAbsCodes array.
    cQuery := " SELECT R8_TIPOAFA AS TPABS, R8_DURACAO AS DAYS, R8_DATAINI AS DINIT, R8_DATAFIM AS DFIN FROM " + RetSQLName("SR8") + " WHERE "
    cQuery += " R8_FILIAL = ? "
    cQuery += " AND R8_MAT = ? "

    AAdd(aValues, FWxFilial("SR8"))
    AAdd(aValues, cMat)

    cQuery += " AND R8_TIPOAFA IN (" + RusSetQryIn(aAbsCodes, @aValues) + ") "
    cQuery += " AND ((R8_DATAINI BETWEEN ? AND ?) OR (R8_DATAFIM BETWEEN ? AND ?)) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    AAdd(aValues, DToS(dAdmis))
    AAdd(aValues, DToS(dBaseDate))
    AAdd(aValues, DToS(dAdmis))
    AAdd(aValues, DToS(dBaseDate))

    cQueryResult := GetNextAlias()

    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cQueryResult, .T., .F.)

    DBSelectArea(cQueryResult)
    DBGoTop()

    While !EoF()
        If (cQueryResult)->TPABS != "035"
            nDays += (cQueryResult)->DAYS
        Else
            nDays035 += (cQueryResult)->DAYS
        EndIf

        DBSkip()
    EndDo

    DBCloseArea()

    // Add absence days by 035 code to total days of absence.
    nDays += IIf((nDays035 < 14), 0, (nDays035 - 14))

    M->RH_DFALTAS := nDays

    // Calculate RH_DIALREM.
    nMonth := INT(nDays / 30)
    nDayRst := nDays % 30
    If (nDayRst > 15)
        nMonth += 1
    EndIf

    nDIALREMDays := Round((nMonth * 2.33), 2)
    M->RH_DIALREM := nDIALREMDays

    RestArea(aCurArea)
Return

/*/{Protheus.doc} fRUGetBaseLimitExcess(cMat As Char, nCalcType As Numeric, cPeriod As Char, nCurrentPayment As Numeric)
    Returns the value by which the base limit (FSS or OPS) was exceeded

    @type Function
    @params cMat,               Char,      Employee's Reg. Number (RA_MAT)
            nCalcType,          Numeric,   Type of the calculation (1 - FSS contributions, 2 - OPS contributions)
            cPeriod,            Char,      Current calculation period (YYYYMM)
            nCurrentPayment,    Numeric,   Value of current contribution-related payment
    @return nExcess,    Numeric,   Value by which the the base limit (FSS or OPS) was exceeded
    @author dtereshenko
    @since 2020/09/30
    @version 12.1.23
*/
Function fRUBaseLimitExcess(cMat As Char, nCalcType As Numeric, cPeriod As Char, nCurrentPayment As Numeric)
    Local cBaseBudget As Char
    Local nBaseLimit As Numeric
    Local cQuery As Char
    local cPrevPayments As Char
    Local nPrevPaymentsSum As Numeric
    Local nExcess As Numeric

    Local cYear := Substr(cPeriod, 1, 4)
    Local aSavedArea := GetArea()
    Local aValues := {}

    If nCalcType == 1 // Temporary Disability & Maternity - FSS
        nBaseLimit := GetFSSLimit(cYear)
        cBaseBudget := aCodFol[13, 1] // RV_COD 641
    ElseIf nCalcType == 2 // Mandatory pension insurance - OPS
        nBaseLimit := fTabela("S037", 1, 18)
        cBaseBudget := aCodFol[17, 1] // RV_COD 700
    EndIf

    cQuery := "SELECT SUM(RD_VALOR) AS PAYMENTS_SUM FROM " + RetSQLName("SRD") + " WHERE "
    cQuery += "RD_FILIAL = ? "
    cQuery += "AND RD_MAT = ? "
    cQuery += "AND RD_PD = ? "
    cQuery += "AND RD_PERIODO BETWEEN ? AND ? "
    cQuery += "AND D_E_L_E_T_ = ' '"

    AAdd(aValues, FWxFilial("SRD"))
    AAdd(aValues, cMat)
    AAdd(aValues, cBaseBudget)
    AAdd(aValues, cYear + "01")
    AAdd(aValues, cPeriod)

    cPrevPayments:= GetNextAlias()

    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cPrevPayments, .T., .F.)

    DBSelectArea(cPrevPayments)
    (cPrevPayments)->(DbGoTop())
    nPrevPaymentsSum := (cPrevPayments)->PAYMENTS_SUM
    DBCloseArea()

    If nPrevPaymentsSum > nBaseLimit
        nExcess := nCurrentPayment
    ElseIf (nPrevPaymentsSum + nCurrentPayment) > nBaseLimit
        nExcess := nPrevPaymentsSum + nCurrentPayment - nBaseLimit
    ElseIf (nPrevPaymentsSum + nCurrentPayment) <= nBaseLimit
        nExcess := 0
    EndIf

    RestArea(aSavedArea)

Return nExcess

/*/{Protheus.doc} fRUFSSContribution(cMat As Char, cPeriod As Char, nCurrentPayment As Numeric)
    Returns the value of the FSS contribution in current calculation period

    @type Function
    @params cMat,               Char,      Employee's Reg. Number (RA_MAT)
            cPeriod,            Char,      Current calculation period (YYYYMM)
            nCurrentPayment,    Numeric,   Value of current contribution-related payment
    @return nFSSContribution,   Numeric,   Value of the FSS contribution in current calculation period
    @author dtereshenko
    @since 2020/09/30
    @version 12.1.23
*/
Function fRUFSSContribution(cMat As Char, cPeriod As Char, nCurrentPayment As Numeric)
    Local cS001Content := fRUGetRccConteo("S001", SubStr(cPeriod, 1, 4))
    Local nCitizenPercent := Val(SubStr(cS001Content, 27, 5)) / 100
    Local nForeignerPercent := Val(SubStr(cS001Content, 41, 4)) / 100
    Local nFSSPercent As Numeric
    Local nExcess As Numeric
    Local nFSSContribution As Numeric

    If SRA->RA_CLASEST $ "02|03|11"
        nFSSPercent := nForeignerPercent
    ElseIf SRA->RA_CLASEST == "14"
        nFSSPercent := 0
    Else
        nFSSPercent := nCitizenPercent
    EndIf

    nExcess := fRUBaseLimitExcess(cMat, 1, cPeriod, nCurrentPayment)

    If nExcess == 0
        nFSSContribution := nCurrentPayment * nFSSPercent
    ElseIf nExcess == nCurrentPayment
        nFSSContribution := 0
    Else
        nFSSContribution := (nCurrentPayment - nExcess) * nFSSPercent
    EndIf

Return nFSSContribution

/*/{Protheus.doc} fRUOPSContribution(cMat As Char, cPeriod As Char, nCurrentPayment As Numeric, lTrunca, nOperation As Numeric)
    Returns the value of the OPS contribution in current calculation period

    @type Function
    @params cMat,               Char,      Employee's Reg. Number (RA_MAT)
            cPeriod,            Char,      Current calculation period (YYYYMM)
            nCurrentPayment,    Numeric,   Value of current contribution-related payment
            lTrunca,            Boolean,   Rounding
            nOperation,         Numeric,   Operation number
    @return nOPSContribution,   Numeric,   Value of the OPS contribution in current calculation period
    @author iprokhorenko
    @since 2020/09/30
    @version 12.1.23
*/
Function fRUOPSContribution(cMat As Char, cPeriod As Char, nCurrentPayment As Numeric, lTrunca, nOperation As Numeric)
    Local nNumStr := IIf(SRA->RA_TPCONTR == '2', 2, 1)
    Local nCitizenPercent := fTabela("S037", nNumStr, 8) / 100
    Local nForeignerPercent := fTabela("S037", nNumStr, 19) / 100
    Local nOPSPercent      As Numeric
    Local nExcess          As Numeric
    Local nOPSContribution As Numeric
    Local nSumToLimit      As Numeric
    Local nSumOverLimit    As Numeric
    
    If SRA->RA_CLASEST == "14"
        nOPSPercent := 0

        nOPSContribution := 0
    Else
        nOPSPercent := nCitizenPercent

        nExcess := fRUBaseLimitExcess(SRA->RA_MAT, 2, CPERIODO, nCurrentPayment)

        If nExcess == 0
            nSumToLimit := nCurrentPayment
            nSumOverLimit := 0
        ElseIf nExcess == nCurrentPayment
            nSumToLimit := 0
            nSumOverLimit := nExcess
        Else
            nSumToLimit := nCurrentPayment - nExcess
            nSumOverLimit := nExcess
        EndIf
        
        If lTrunca
            nSumToLimit := NoRound(nSumToLimit * nCitizenPercent , 2)
            nSumOverLimit := NoRound(nSumOverLimit * nForeignerPercent , 2)
        Else
            nSumToLimit := Round(nSumToLimit * nCitizenPercent , 2)
            nSumOverLimit := Round(nSumOverLimit * nForeignerPercent , 2)
        EndIf
        
        If nOperation == 1
            nOPSContribution := nSumToLimit 
        ElseIf nOperation == 2
            nOPSContribution := nSumOverLimit 
        EndIf

    EndIf

Return nOPSContribution

/*/{Protheus.doc} S002StdVal(aCols As Array)
    The function adds default values for RESERVED columns in S002 table. The array must be passed by reference from GPEA320.

    @type Function
    @params aCols, Array, RCC string array
    @return
    @author vselyakov, dtereshenko
    @since 2020/10/23
    @version 12.1.23
    @example S002StdVal(@aCols)
*/
Function S002StdVal(aCols)
    Local nI As Numeric
    Local nJ As Numeric
    Local aS002ReservedValues := { {5, 0.01},  ; // ISENCAO
                                   {8, 0.01},  ; // DED1
                                   {11, 0.01}, ; // DED2
                                   {14, 0.01}, ; // DED3
                                   {17, 0.01}, ; // DED4
                                   {19, 99} }    // LIMDEP

    For nI := 1 To Len(aCols)
        If Len(aCols[nI]) < S002_COLUMNS_NUMBER
            ASize(aCols[nI], S002_COLUMNS_NUMBER)

            For nJ := 1 To Len(aS002ReservedValues)
                AIns(aCols[nI], aS002ReservedValues[nJ][1])
                aCols[nI][aS002ReservedValues[nJ][1]] := aS002ReservedValues[nJ][2]
            Next nJ
        Else
            For nJ := 1 To Len(aS002ReservedValues)
                aCols[nI][aS002ReservedValues[nJ][1]] := aS002ReservedValues[nJ][2]
            Next nJ
        EndIf
    Next nI
Return

/*/{Protheus.doc} RU07XFUN02_GetPeriodWorkingDays(dDateStart As Date, dDateEnd As Date)
    Returns number of working days within current calculation period between two transfered dates

    @type Function
    @params dDateStart,     Date,      First date (start)
            dDateEnd,       Date,      First date (end)
    @return nWorkingDays,   Numeric,   Number of working days
    @author dtereshenko
    @since 2020/12/04
    @version 12.1.23
*/
Function RU07XFUN02_GetPeriodWorkingDays(dDateStart As Date, dDateEnd As Date)
    Local nI As Numeric
    Local nWorkingDays := 0 As Numeric

    For nI := 1 To Len(aPeriodo[1][5])
        // Workind day between dDateStart and dDateEnd
        If dDateStart <= aPeriodo[1][5][nI][1] .And. aPeriodo[1][5][nI][1] <= dDateEnd .And. aPeriodo[1][5][nI][2] $ "1*2"
            nWorkingDays++
        EndIf
    Next nI

Return nWorkingDays

/*/{Protheus.doc} RU07XFUN04_MonthSalaryForChangeRateSalary()
    The function calculates the salary for a month,
    taking into account changes in the rate in the period and taking into account
    the days of absence of the employee in the period.

    @type Function
    @params
    @return nResult, Numeric, Salary amount per month, taking into account rate changes in the period
    @author vselyakov
    @since 2021/01/21
    @version 12.1.23
    @example RU07XFUN04_MonthSalaryForChangeRateSalary()
*/
Function RU07XFUN04_MonthSalaryForChangeRateSalary()
    Local nResult          As Numeric   // Calculated salary.
    Local cRA_MAT          As Character // Employee's personnel number.
    Local cRA_CATFUNC      As Character // Employee category code.
    Local nRA_HRSDIA       As Numeric   // Number of hours per day for an employee.
    Local nR3_VALOR        As Numeric   // New value of salary.
    Local nR3_ANTEAUM      As Numeric   // Old value of salary
    Local dR3_DATA         As Date      // Date of changes of salary.
    Local lIsChanged       As Logical   // Change of salary is exist.
    Local nAftWrkDays      As Numeric   // Amount of working days with disable days after rate the salary.
    Local nBfrWrkDays      As Numeric   // Amount of working days with disable days before rate the salary.
    Local nWrkDsMonth      As Numeric   // Amount fo working days in the period.
    Local dStartDate       As Date      // Start date calculate.
    Local nWorkHolidayDays As Numeric   // Count of working days in holiday.
    Local aWorkingHolidays As Array     // Array of dates with working holidays.
    Local nHolidayBeforeChangeRate As Numeric // Count of working days on holiday before change rate salary.
    Local nI      As Numeric
    Local nSalCh  As Numeric
    Local dBefore As Date
    Local nAllHolidayBeforeLastChange As Numeric
    Local aSalaryChange As Array

    lIsChanged := .F.
    nResult := 0
    aWorkingHolidays := {}
    nHolidayBeforeChangeRate := 0

    // Get data for calculating.
    cRA_MAT     := SRA->RA_MAT // Employee's personnel number.
    cRA_CATFUNC := SRA->RA_CATFUNC // Employee category code.
    nRA_HRSDIA  := SRA->RA_HRSDIA // Number of hours per day for an employee.
    nWrkDsMonth := RU07XFUN02_GetPeriodWorkingDays(aPeriodo[1][3], aPeriodo[1][4]) // Amount fo working days in the period.
    dStartDate  := IIF(SRA->RA_ADMISSA > aPeriodo[1][3], SRA->RA_ADMISSA, aPeriodo[1][3]) // If the employee hiring date is greater than the period start date then use RA_ADMISSA as start date.
    nWorkHolidayDays := RU07XFUN10_GetNumberWorkingDaysDuringHolidays(@aWorkingHolidays)

    // Get data for calculating with changes of the salary for a month. Checking the date of change of salary.
    // If date of change enter into calculation period then We must take into account the new rate.
    // Else - get value from SALMES mnemonic (it is calculate the salary on new value of salary without old salary).

    aSalaryChange := GetSalaryChange(cRA_MAT, aPeriodo[1][3], aPeriodo[1][4])

    If Len(aSalaryChange) > 0 .And. aSalaryChange[1][2] <> aSalaryChange[1][3]
        lIsChanged  := .T.
        dR3_DATA    := aSalaryChange[1][1] // Date of changes of salary.
        nR3_VALOR   := aSalaryChange[1][2] // New value of salary.
        nR3_ANTEAUM := aSalaryChange[1][3] // Old value of salary.
    EndIf

    If !lIsChanged
        Do Case
            Case (cRA_CATFUNC == "H") // Hourly employee.
                nResult := SRA->RA_SALARIO * (DIASTRAB * nRA_HRSDIA) // DIASTRAB - default mnemonic: number of working days without absences

            Case (cRA_CATFUNC == "M") // Employee with monthly pay.
                nResult := ((SALMES / NDIASC) * DIASTRAB) // NDIASC - default mnemonic: number of working days
        EndCase

        // Add payments for holiday work.
        AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, SALDIA, nWorkHolidayDays) // SLADIA - default mnemonic of Salary in one day.
    Else
        dBefore := dStartDate
        nResult := 0
        nAllHolidayBeforeLastChange := 0
        For nSalCh := 1 To Len(aSalaryChange)
            dR3_DATA    := aSalaryChange[nSalCh][1] // Date of changes of salary.
            nR3_VALOR   := aSalaryChange[nSalCh][2] // New value of salary.
            nR3_ANTEAUM := aSalaryChange[nSalCh][3] // Old value of salary.
            // Get work days from period before rate the salary.
            nBfrWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cRA_MAT, dBefore, dR3_DATA - 1)

            // Calculate count of working days on holiday before change rate salary (nHolidayBeforeChangeRate).
            nHolidayBeforeChangeRate := 0
            For nI := 1 To Len(aWorkingHolidays)
                If (aWorkingHolidays[nI] < dR3_DATA .And. aWorkingHolidays[nI] >= dBefore)
                    nHolidayBeforeChangeRate++
                EndIf
            Next nI
            nAllHolidayBeforeLastChange += nHolidayBeforeChangeRate

            Do Case
                Case (cRA_CATFUNC == "H") // Hourly employee.
                    nResult += (nR3_ANTEAUM * (nBfrWrkDays * nRA_HRSDIA))
                    AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, (nR3_ANTEAUM * nRA_HRSDIA), nHolidayBeforeChangeRate) // Before change rate.

                Case (cRA_CATFUNC == "M") // Employee with monthly pay.
                    nResult += ((nR3_ANTEAUM / NDIASC) * nBfrWrkDays)
                    AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, (nR3_ANTEAUM / NDIASC), nHolidayBeforeChangeRate) // Before change rate.
            EndCase

            dBefore := dR3_DATA

        Next nSalCh

        // Get work days (Subtract 1 day, since it was taken into account in the previous period) from period after rate the salary.
        nAftWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cRA_MAT, dR3_DATA, aPeriodo[1][4])
        Do Case
            Case (cRA_CATFUNC == "H") // Hourly employee.
                nResult += (nR3_VALOR * (nAftWrkDays * nRA_HRSDIA))
                AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, (nR3_VALOR * nRA_HRSDIA), nWorkHolidayDays - nAllHolidayBeforeLastChange) // After change rate.

            Case (cRA_CATFUNC == "M") // Employee with monthly pay.
                nResult += ((nR3_VALOR / NDIASC) * nAftWrkDays)
                AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, (nR3_VALOR / NDIASC), nWorkHolidayDays - nAllHolidayBeforeLastChange) // After change rate.
        EndCase

    EndIf

Return nResult

/*/{Protheus.doc} RU07XFUN03_GetPerWorkDayWithAbsence(cMat, dDateStart, dDateEnd)
    The function returns the number of working days in the specified period, taking into account the absence of an employee.

    @type Function
    @params
            cMat,       Character, Employee's personnel number.
            dDateStart, Date,      Start date of period.
            dDateEnd,   Date,      End date of period.
    @return nResult, Numeric, Number of working days in the specified period, taking into account the absence of an employee.
    @author vselyakov
    @since 2021/01/21
    @version 12.1.23
    @example RU07XFUN03_GetPerWorkDayWithAbsence(cRA_MAT, aPeriodo[1][3], dR3_DATA)
*/
Function RU07XFUN03_GetPerWorkDayWithAbsence(cMat, dDateStart, dDateEnd)
    Local aAbsences  As Array
    Local nDisDay    As Numeric
    Local nResult    As Numeric // Working days with disable days.
    Local aArea      As Array
    Local nJ         As Numeric
    Local cDateStart As Char
    Local cDateEnd   As Char
    Local cQuery     As Char
    Local cAnsences  As Char
    Local lIsCalc    As Logical
    Local aValues   := {}

    Default cMat := SRA->RA_MAT
    Default dDateStart := aPeriodo[1][3]
    Default dDateEnd   := aPeriodo[1][4]

    cDateStart := DToS(dDateStart)
    cDateEnd := DToS(dDateEnd)

    aArea := GetArea()
    nResult := 0
    aAbsences := {}
    nDisDay := 0
    lIsCalc := RU07XFUN40_CheckIsCalculation({"ADI", "FOL"})

    If dDateStart < dDateEnd
        cQuery := "SELECT R8_DATAINI, R8_DATAFIM, R8_LAWSAL, R8_INIPCHI, R8_FIMPCHI, R8_PD FROM " + RetSQLName("SR8") + " WHERE "
        cQuery += " R8_FILIAL = ? AND "
        cQuery += " R8_MAT = ? AND "
        cQuery += " ( (? >= R8_DATAINI AND ? <= R8_DATAFIM) OR "
        cQuery += " (? <= R8_DATAINI AND ? >= R8_DATAFIM) OR "
        cQuery += " (? BETWEEN R8_DATAINI AND R8_DATAFIM AND ? >= R8_DATAFIM) OR "
        cQuery += " (? BETWEEN R8_DATAINI AND R8_DATAFIM AND ? <= R8_DATAINI) ) AND "
        cQuery += " D_E_L_E_T_ = ' ' "

        AAdd(aValues, FWxFilial("SR8"))
        AAdd(aValues, cMat)
        AAdd(aValues, cDateStart)
        AAdd(aValues, cDateEnd)
        AAdd(aValues, cDateStart)
        AAdd(aValues, cDateEnd)
        AAdd(aValues, cDateStart)
        AAdd(aValues, cDateEnd)
        AAdd(aValues, cDateEnd)
        AAdd(aValues, cDateStart)

        cAnsences:= GetNextAlias()
        DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAnsences, .T., .F.)

        DbSelectArea(cAnsences)
        DbGoTop()

        While !EoF()
            If lIsCalc .And. (cAnsences)->R8_LAWSAL == "1" // .And. RetValSRV((cAnsences)->R8_PD, SRA->RA_FILIAL, "RV_CODFOL") == COD_FOL_FOR_CARE_CHILD_3
                If !Empty((cAnsences)->R8_INIPCHI) .And. (cAnsences)->R8_INIPCHI > (cAnsences)->R8_DATAINI
                    AAdd(aAbsences, { SToD((cAnsences)->R8_DATAINI), SToD((cAnsences)->R8_INIPCHI) - 1 })
                EndIf
                If !Empty((cAnsences)->R8_FIMPCHI) .And. (cAnsences)->R8_DATAFIM > (cAnsences)->R8_FIMPCHI
                    AAdd(aAbsences, { SToD((cAnsences)->R8_FIMPCHI) + 1, SToD((cAnsences)->R8_DATAFIM) })
                EndIf
            Else
                AAdd(aAbsences, { SToD((cAnsences)->R8_DATAINI), SToD((cAnsences)->R8_DATAFIM) })
            EndIf
            DBSkip()
        EndDo

        DbCloseArea()
        RestArea(aArea)

        // Calculate disable days (from SR8) between dDateStart and dDateEnd.
        For nJ := 1 To Len(aAbsences)
            If cRot == "ADI"
                nDisDay += RU07XFUN02_GetPeriodWorkingDays(aAbsences[nJ][1], Iif(dDateEnd > aAbsences[nJ][2], aAbsences[nJ][2], dDateEnd))
            Else
                nDisDay += RU07XFUN02_GetPeriodWorkingDays(aAbsences[nJ][1], aAbsences[nJ][2])
            EndIf
        Next nJ

        // Calculate working days with disable days between dDateStart and dDateEnd.
        nResult := RU07XFUN02_GetPeriodWorkingDays(dDateStart, dDateEnd) - nDisDay
    EndIf

Return nResult

/*/{Protheus.doc} RU07XFUN05_GetMonthSize(nMonth, nYear)
    The function returns the number of days in the specified month, taking into account the leap year.
    This is necessary in case the aPeriodo array is equal to Nil.

    @type Function
    @params nMonth,   Numeric, Number of month
            nYear,    Numeric, Number of year
    @return nMaxDays, Numeric, Number of days in a month
    @author vselyakov
    @since 04.05.2021
    @version 12.1.23
    @example RU07XFUN05_GetMonthSize(Month(dBaseStart), Year(dBaseStart))
*/
Function RU07XFUN05_GetMonthSize(nMonth As Numeric, nYear As Numeric)
    Local nMaxDays   As Numeric
    Local aDaysCount As Array

    Default nMonth := Month(Date())
    Default nYear := Year(Date())

    nMaxDays := 0
    aDaysCount := { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }

    nMaxDays := aDaysCount[nMonth]

    If (nMonth == 2 .And. RU07XFUN06_IsLeapYear(nYear))
        nMaxDays += 1
    EndIf

Return nMaxDays

/*/{Protheus.doc} RU07XFUN06_IsLeapYear(nYear)
    The function shows the leap year or not.
    If the specified year nYear is a leap year, then the function will return .T., otherwise - .F.

    @type Function
    @params nYear, Numeric, Number of year
    @return lYearIsLeap, Boolean, .T. - year is leap, .F. - other case
    @author vselyakov
    @since 2021/04/12
    @version 12.1.23
    @example RU07XFUN06_IsLeapYear(nYear)
             RU07XFUN06_IsLeapYear(2021)
             RU07XFUN06_IsLeapYear(2020)
*/
Function RU07XFUN06_IsLeapYear(nYear As Numeric)
    Local lYearIsLeap := .F.

    If (nYear % 4 == 0 .And. (nYear % 100 != 0 .Or. nYear % 400 == 0))
        lYearIsLeap := .T.
    EndIf

Return lYearIsLeap

/*/{Protheus.doc} RU07XFUN07_AssembleInitials()
    Function assembles short form of a full name: surname and initials of name and patronymic
    Used in triggers for fields RA_PRINOME, RA_SECNOME, RA_PRISOBR

    @type Function
    @params
    @return cInitials, Char, Short form of full name
    @author dtereshenko
    @since 2021/05/13
    @version 12.1.23
    @example RU07XFUN07_AssembleInitials()
*/
Function RU07XFUN07_AssembleInitials()
    Local cName As Char
    Local cPatronymic As Char
    Local cInitials As Char

    cName := IIf(Empty(M->RA_PRINOME), "", SubStr(M->RA_PRINOME, 1, 1) + ". ")
    cPatronymic := IIf(Empty(M->RA_SECNOME), "", SubStr(M->RA_SECNOME, 1, 1) + ".")

    cInitials := AllTrim(M->RA_PRISOBR) + " " + cName + cPatronymic

Return cInitials

/*/{Protheus.doc} RU07XFUN08_IsCategoryChange()
    Shows whether the employee had a category change.

    @type Function
    @params
    @return lIsChange, Boolean, .T. - change exist, .F. - no change.
    @author vselyakov
    @since 2021/05/20
    @version 12.1.23
    @example RU07XFUN08_IsCategoryChange()
*/
Function RU07XFUN08_IsCategoryChange()
    Local lIsChange    As Logical   // Show that category of employee is changed.
    Local cOldCatfunc  As Character // Old employee functional category.
    Local dDateOld     As Date      // Date old employee functional category.
    Local cNewCatfunc  As Character // New employee functional category.
    Local aArea        As Array
    Local lChangeInPer As Logical   // Were there any changes in the period

    aArea := GetArea()
    lIsChange := .F.
    cNewCatfunc := SRA->RA_CATFUNC // Employee category code.
    cOldCatfunc := SRA->RA_CATFUNC // Employee category code.

    dDateOld = CtoD('01/01/1001')

    // Search for a change in the functional category of an employee.
    DbSelectArea("SR7")
    DbSetOrder(1)
    If (DbSeek(FwxFilial("SR7") + SRA->RA_MAT))
        While !EoF()
            If (SR7->R7_MAT ==  SRA->RA_MAT .And. SR7->R7_DATA <= aPeriodo[1][3] .And. SR7->R7_DATA > dDateOld)
                cOldCatfunc := SR7->R7_CATFUNC
                dDateOld := SR7->R7_DATA
            ElseIf (SR7->R7_MAT ==  SRA->RA_MAT .And. SR7->R7_DATA > aPeriodo[1][3] .And. SR7->R7_DATA <= aPeriodo[1][4])
                If(cNewCatfunc != SR7->R7_CATFUNC)
                    lChangeInPer := .T.
                EndIf
                cNewCatfunc := SR7->R7_CATFUNC
            EndIf
            DbSkip()
        EndDo
    EndIf

    If cOldCatfunc != cNewCatfunc .Or. lChangeInPer
        lIsChange  := .T.
    EndIf

    RestArea(aArea)

Return lIsChange

/*/{Protheus.doc} RU07XFUN09_CalculationSalaryByChangeCatfunc()
    The function performs payroll calculation for an employee whose functional category has been changed.
    Used in the S_GRVSAL formula.
    Adds payment types for the corresponding categories to the payroll.

    @type Function
    @params
    @return Nil
    @author vselyakov
    @since 2021/05/20
    @version 12.1.23
    @example RU07XFUN09_CalculationSalaryByChangeCatfunc()
*/
Function RU07XFUN09_CalculationSalaryByChangeCatfunc()
    Local aArea        As Array
    Local nResult      As Numeric   // Calculated salary.
    Local cRA_MAT      As Character // Employee's personnel number.
    Local nRA_HRSDIA   As Numeric   // Number of hours per day for an employee.
    Local nR3_VALOR    As Numeric   // New value of salary.
    Local nR3_ANTEAUM  As Numeric   // Old value of salary
    Local dR3_DATA     As Date      // Date of changes of salary.
    Local nAftWrkDays  As Numeric   // Amount of working days with disable days after change category.
    Local nBfrWrkDays  As Numeric   // Amount of working days with disable days before change category.
    Local dStartDate   As Date      // Start date calculate.
    Local cOldCatfunc  As Character // Old employee functional category.
    Local cNewCatfunc  As Character // New employee functional category.
    Local cQuery       As Char
    Local cQueryResult As Char
    Local aValues      := {}
    Local nI           As Numeric
    Local dBefore      As Date

    aArea := GetArea()
    nResult := 0

    // Get data for calculating.
    cRA_MAT     := SRA->RA_MAT // Employee's personnel number.
    cNewCatfunc := SRA->RA_CATFUNC // Employee category code.
    cOldCatfunc := SRA->RA_CATFUNC // Employee category code.
    nRA_HRSDIA  := SRA->RA_HRSDIA // Number of hours per day for an employee.
    dStartDate  := IIF(SRA->RA_ADMISSA > aPeriodo[1][3], SRA->RA_ADMISSA, aPeriodo[1][3]) // If the employee hiring date is greater than the period start date then use RA_ADMISSA as start date.

    // Get data for calculating with changes of the salary for a month. Checking the date of change of salary.
    // If date of change enter into calculation period then We must take into account the new rate.
    // Else - get value from SALMES mnemonic (it is calculate the salary on new value of salary without old salary).

    aSalaryChange := GetSalaryChange(cRA_MAT, aPeriodo[1][3], aPeriodo[1][4])

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
    AAdd(aValues, cRA_MAT)
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
        nBfrWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cRA_MAT, dBefore, dR3_DATA - 1)

        // Calculate salary on old fuctional category.
        Do Case
            Case (cOldCatfunc == "H") // Hourly employee.
                nResult := nR3_ANTEAUM * (nBfrWrkDays * nRA_HRSDIA)
                FMatriz(ACodFol[32,1], nResult, nBfrWrkDays * nRA_HRSDIA,,,,,,,,,,,,,,,,,,NSALINT)

            Case (cOldCatfunc == "M") // Employee with monthly pay.
                nResult := ((nR3_ANTEAUM / NDIASC) * nBfrWrkDays)
                FMatriz(ACodFol[31,1], nResult, nBfrWrkDays,,,,,,,,,,,,,,,,,,NSALINT)
        EndCase

        dBefore := dR3_DATA

    Next nI
        
    nAftWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(cRA_MAT, dR3_DATA, aPeriodo[1][4])

    // Calculate salary on new fuctional category.
    Do Case
        Case (cNewCatfunc == "H") // Hourly employee.
            nResult := nR3_VALOR * (nAftWrkDays * nRA_HRSDIA)
            FMatriz(ACodFol[32,1], nResult, nAftWrkDays * nRA_HRSDIA,,,,,,,,,,,,,,,,,,NSALINT)

        Case (cNewCatfunc == "M") // Employee with monthly pay.
            nResult := ((nR3_VALOR / NDIASC) * nAftWrkDays)
            FMatriz(ACodFol[31,1], nResult, nAftWrkDays,,,,,,,,,,,,,,,,,,NSALINT)
    EndCase

    RestArea(aArea)

Return

/*/{Protheus.doc} RU07XFUN10_GetNumberWorkingDaysDuringHolidays()
    The function returns the number of working days (nHolidayDays) that the employee worked on a holiday.
    In GPEA400, the holiday calendar is set to "Not Work".
    Input parameter (optional) aHolidays - an array containing the dates of public holidays. To use it, you need to pass the array by reference.

    @type Function
    @params aHolidays,    Array,   Array containing the dates of working holidays.
    @return nHolidayDays, Numeric, Number of working days that the employee worked on a holiday.
    @author vselyakov
    @since 2021/05/31
    @version 12.1.23
    @example nDays := RU07XFUN10_GetNumberWorkingDaysDuringHolidays(@aHoliday)
             nDays := RU07XFUN10_GetNumberWorkingDaysDuringHolidays()
*/
Function RU07XFUN10_GetNumberWorkingDaysDuringHolidays(aHolidays)
    Local nHolidayDays As Numeric
    Local nI           As Numeric

    Default aHolidays := {}

    nHolidayDays := 0

    For nI := 1 To Len(aPeriodo[1][5])
        If aPeriodo[1][5][nI][2] == NOT_WORKING_DAY
            AAdd(aHolidays, aPeriodo[1][5][nI][1])
            nHolidayDays++
        EndIf
    Next nI

Return nHolidayDays

/*/{Protheus.doc} RU07XFUN10_GetNumberWorkingDaysDuringHolidays()
    A wrapper function for FMatriz (...). The function adds types of payments to the payroll if the employee worked on a holiday.
    The wage type added depends on the functional category of the employee (cCatFunc).

    @type Function
    @params cCatFunc,    Character, Functional category of the employee.
            nDaySalary,  Numeric,   Salary for one working day.
            nWorkedDays, Numeric,   Number of days worked on holidays.
    @return Nil
    @author vselyakov
    @since 2021/05/31
    @version 12.1.23
    @example AddPaymentTypeForWorkingHoliday(cRA_CATFUNC, SALDIA, nHolDays)
             AddPaymentTypeForWorkingHoliday("H", 500.00, 1)
*/
Static Function AddPaymentTypeForWorkingHoliday(cCatFunc, nDaySalary, nWorkedDays)
    // NSALINT - default mnemonic 'Wage value before proportionalization'.
    // ACodFol[1758,1] - Wage type for an employee of category M.
    // ACodFol[1759,1] - Wage type for an employee of category H.
    If Len(aCodFol) >= 1759
        If (cCatFunc == "M")
            FMatriz(ACodFol[1758,1], (nDaySalary * nWorkedDays), nWorkedDays,,,,,,,,,,,,,,,,,, NSALINT)
        Else
            FMatriz(ACodFol[1759,1], (nDaySalary * nWorkedDays), (nWorkedDays * SRA->RA_HRSDIA),,,,,,,,,,,,,,,,,, NSALINT)
        EndIf
    EndIf
Return

/*/{Protheus.doc} GetSalaryChange(cMat, dDateStart, dDateEnd)
    Returns salary change info {R3_DATA, R3_VALOR, R3_ANTEAUM} for
    transfering empoyee's registration number between two transfered dates

    @type Function
    @params cMat,       Char, Empoyee's registration number (RA_MAT)
            dDateStart, Date, First date
            dDateEnd,   Date, Seconf date
    @return Array, Salary change info {R3_DATA, R3_VALOR, R3_ANTEAUM}
    @author dtereshenko
    @since 2021/07/01
    @version 12.1.23
    @example GetSalaryChange("000013", SToD(20200101), SToD(20200201))
*/
Static Function GetSalaryChange(cMat, dDateStart, dDateEnd)
    Local aSavedArea := GetArea()
    Local cQuery As Char
    Local cSalaryChange As Char
    Local aSalaryChange := {}
    Local aValues := {}

    cQuery := "SELECT R3_DATA, R3_VALOR, R3_ANTEAUM FROM " + RetSQLName("SR3") + " WHERE "
    cQuery += "R3_FILIAL = ? AND "
    cQuery += "R3_MAT = ? AND "
    cQuery += "R3_DATA BETWEEN ? AND ? "
    cQuery += "AND D_E_L_E_T_ = ' ' "

    AAdd(aValues, FWxFilial("SR3"))
    AAdd(aValues, cMat)
    AAdd(aValues, DToS(dDateStart))
    AAdd(aValues, DToS(dDateEnd))

    cSalaryChange:= GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cSalaryChange, .T., .F.)

    DbSelectArea(cSalaryChange)
    While !Eof()
        // { Date of changes, New value, Old value }
        Aadd(aSalaryChange, { SToD((cSalaryChange)->R3_DATA), (cSalaryChange)->R3_VALOR, (cSalaryChange)->R3_ANTEAUM })

        DbSkip()
    EndDo
    
    DbCloseArea()
    RestArea(aSavedArea)

Return aSalaryChange

/*/{Protheus.doc} RusSetQryIn(aData, aValues)
    Returns string for using in SQL queries after IN operator: "?, ?, ? ..."
    Adds string representation of aData elements to aValues output array (to be used in TcGenQry2 function)

    @type Function
    @author Bruno Alejandro Sobieski Chavez
    @since 2021/07/01
    @version 12.1.23

    @params aData,   Array,  Input array with SQL query params
            aValues, Array,  Output array with string values for TcGenQry2
    @return Char, String for adding to SQL query
    @example RusSetQryIn({25, 17, "25", "17", SToD("20210716")}, @aValues)
*/
Function RusSetQryIn(aData, aValues)
    Local nX As Numeric
    Local cRet := ""

    For nX := 1 To Len(aData)
        cRet += ", ?"

        If ValType(aData[nX]) == "N"
            AAdd(aValues, AllTrim(Str(aData[nX])))
        ElseIf ValType(aData[nX]) == "D"
            AAdd(aValues, Dtos(aData[nX]))
        Else
            AAdd(aValues, aData[nX])
        EndIf
    Next nX

    If Len(cRet) > 0
        cRet := Substr(cRet, 3)
    EndIf

Return cRet

/*/{Protheus.doc} fRUOPSLimiter(nBaseSum as Numeric, nOperation as Numeric)
    Returns the OPS base value for the current billing period.

    @type Function
    @params nBaseSum,      Numeric,    Value of the current payment, for calculating the base
            nOperation,    Numeric,    Operation number
    @return nResult,       Numeric,    OPS base value in the current billing period
            If nOperation = 1, will return the OPS base to the limit
            If nOperation = 2, will return the OPS base over the limit
    @author iprokhorenko
    @since 2021/08/12
    @version 12.1.23
*/
Function fRUOPSLimiter(nBaseSum as Numeric, nOperation as Numeric)
    Local nResult       As Numeric    
    Local nSumToLimit   As Numeric
    Local nSumOverLimit As Numeric
    Local nExcess       As Numeric

    nExcess := fRUBaseLimitExcess(SRA->RA_MAT, 2, CPERIODO, nBaseSum)

    If nExcess == 0
        nSumToLimit := nBaseSum
        nSumOverLimit := 0
    ElseIf nExcess == nBaseSum
        nSumToLimit := 0
        nSumOverLimit := nExcess
    Else
        nSumToLimit := nBaseSum - nExcess
        nSumOverLimit := nExcess
    EndIf

    If nOperation == 1
        nResult := nSumToLimit 
    ElseIf nOperation == 2
        nResult := nSumOverLimit 
    EndIf

Return nResult


/*{Protheus.doc} RU07XFUN11_GetReservedColumns
    Returns array of reserved column positions
    @author alexander.ivanov
    @since 07/09/2021
    @version 12.1.23
*/
Function RU07XFUN11_GetReservedColumns(aHead as Array)
    Local aReserved := {}
    Local nColumn as Numeric

    For nColumn := 1 To Len(aHead)
        If AllTrim(aHead[nColumn][1]) == "RESERVED"
            AAdd(aReserved, nColumn)
        EndIf
    Next nColumn

Return aReserved

/*{Protheus.doc} RU07XFUN12_RemoveIndices
    Removes elements of original array on given positions
    @author alexander.ivanov
    @since 07/09/2021
    @version 12.1.23
*/
Function RU07XFUN12_RemoveIndices(aHead, aIndices)
    Local nIndice as Numeric

    For nIndice := Len(aIndices) To 1 Step - 1
        ADel(aHead, aIndices[nIndice])
    Next nIndice

    ASize(aHead, Len(aHead) - Len(aIndices))
Return

/*{Protheus.doc} RU07XFUN13_HideReservedColumns
    Removes given columns from grid header and grid data arrays (usualy named as aHeader and aCols)

    @author alexander.ivanov
    @since 07/09/2021
    @version 12.1.23
*/
Function RU07XFUN13_HideReservedColumns(aHead as Array, aColumns as Array, aReserved as Array)
    Local nRecord as Numeric

    RU07XFUN12_RemoveIndices(aHead, aReserved)

    For nRecord := 1 To Len(aColumns)
        RU07XFUN12_RemoveIndices(aColumns[nRecord], aReserved)
    Next nRecord

Return

/*/{Protheus.doc} RU07XFUN14_SnilsValitation()
    A wrapper function for RB_CIC validation. 
    The function created because into ATUSX function need 10 simbols.

    @type Function
    @params cSnilsNumber, Character, SNILS number.
    @return lValidationResult, Logical, Result of validation.
    @author vselyakov
    @since 2021/09/30
    @version 12.1.23
    @example RU07XFUN14_SnilsValitation(M->RB_CIC)
             RU07XFUN14(M->RB_CIC)
*/
Function RU07XFUN14_SnilsValitation(cSnilsNumber)
    Local lValidationResult As Logical

    Default cSnilsNumber := ""

    lValidationResult := .F.

    If Empty(cSnilsNumber)
        lValidationResult := .T.
    Else
        lValidationResult := RU99X02SNILS(cSnilsNumber)
    EndIf

Return lValidationResult

/*/{Protheus.doc} RU07XFUN15_RollingSickLeave()
    Rolling Sick Leave.

    @type Function
    @params cTN, Character, Personnel Number.
            cPeriod, Character, Period
    @return lValidationResult, Logical, Result of validation.
    @author iprokhorenko
    @since 2021/11/25
    @version 12.1.33
    @example RU07XFUN15_RollingSickLeave(M->R8_MAT)
             RU07XFUN15(M->R8_MAT)
*/
Function RU07XFUN15_RollingSickLeave(cTN, cPeriod)

    Local aDSAbsenceTypes As Array
    Local aSavedArea := GetArea() As Array
    Local cQuery As Char
    Local cAbsences As Char
    Local aValues := {}
    Local lResult As Logical
    aValues := {}
    // Collect all DS-related absences within transfered period
    aDSAbsenceTypes := {"003", "004", "006", "007", "008", "009", "010", "011", "017", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029"}

    cQuery := "SELECT R8_DATAINI, R8_DATAFIM FROM " + RetSQLName("SR8") + " WHERE  "
    cQuery += "R8_FILIAL = ? AND  "
    cQuery += "R8_MAT = ? AND  "
    AAdd(aValues, FWxFilial("SR8"))
    AAdd(aValues, cTN)

    cQuery += "R8_TIPOAFA IN (" + RusSetQryIn(aDSAbsenceTypes, @aValues) + ") AND "
    cQuery += "SUBSTRING(R8_DATAINI, 1 , 6) <= ? AND " 
    cQuery += "SUBSTRING(R8_DATAFIM, 1 , 6) > ? AND "
    cQuery += "R8_TIPOAFA IN (SELECT RCM_TIPO FROM " + RetSQLName("RCM") + " WHERE RCM_TIPOAF IN ('1','2','3')) AND  "
    cQuery += "D_E_L_E_T_ = ' ' "
    AAdd(aValues, cPeriod)
    AAdd(aValues, cPeriod)

    cQuery := ChangeQuery2(cQuery)

    cAbsences := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAbsences, .T., .F.)

    DbSelectArea(cAbsences)
    DbGoTop()

    lResult := !EoF()

    DbCloseArea()
    RestArea(aSavedArea)

Return lResult

/*/{Protheus.doc} RU07XFUN16_AssembleCodWithPercentNP(cRccConteo)
    Function for assembling a string for field "RA_RFNP" 
    from substring table S207

    @type Function
    @params cCod, Character - Cod from table S207.
    @params nPersent, Numeric - Persent from table S207.
    @return Character - Result string.
    @author dchizhov
    @since 2021/12/07
    @version 12.1.23
    @example RU07XFUN16_AssembleCodWithPercentNP(cStringCod, nPersent)
*/
Function RU07XFUN16_AssembleCodWithPercentNP(cCod, nPersent)
    
    Local cStringResult  As Character
    Local cStringPercent As Character

    cStringResult := AllTrim(cCod)
    cStringPercent := cValToChar(nPersent)

    cStringResult := cStringResult + ' ' + cStringPercent + '%'

Return cStringResult

/*/{Protheus.doc} RU07XFUN17_AssembleNP(cRccConteo)
    Function for assembling a string for field "RA_RFNP" from table S207

    @type Function
    @params cRccConteo, Character - string from table S207.
    @return Character - Result string.
    @author dchizhov
    @since 2021/12/06
    @version 12.1.23
    @example RU07XFUN17_AssembleNP(RCC->RCC_CONTEU)
*/
Function RU07XFUN17_AssembleNP(cRccConteo)
    
    Local cStringCod As Character
    Local nPercent   As Numeric

    cStringCod := AllTrim(SubStr(cRccConteo, 1, 10))
    nPercent := Val(SubStr(cRccConteo, 11, 6))

Return RU07XFUN16_AssembleCodWithPercentNP(cStringCod, nPercent)

/*/{Protheus.doc} S037StdVal(aCols As Array)
    The function adds default values for RESERVED columns in S037 table. The array must be passed by reference from GPEA320.

    @type Function
    @params aCols, Array, RCC string array
    @return
    @author vselyakov, dtereshenko
    @since 01.02.2022
    @version 12.1.33
    @example S037StdVal(@aCols)
*/
Function S037StdVal(aCols)
    Local nI As Numeric
    Local nJ As Numeric
    Local aS037ReservedValues := { {7,  0.0},                ; // RAT.
                                   {9,  "0"},                ; // RECFATUR.
                                   {10, "0"},                ; // OpSimples.
                                   {11, "0000"},             ; // CdPtoGPS.
                                   {12, 0.0},                ; // VLRMINGP.
                                   {13, Padr(" ", 13, " ")}, ; // CodFGTS.
                                   {14, 0.0},                ; // Prov13.
                                   {15, 0.0},                ; // ProvFer.
                                   {16, 0.0},                ; // ProvRes.
                                   {17, "0"}                 ; // IdCntbSub.
                                 }

    For nI := 1 To Len(aCols)
        If Len(aCols[nI]) < S037_COLUMNS_NUMBER
            ASize(aCols[nI], S037_COLUMNS_NUMBER)

            For nJ := 1 To Len(aS037ReservedValues)
                AIns(aCols[nI], aS037ReservedValues[nJ][1])
                aCols[nI][aS037ReservedValues[nJ][1]] := aS037ReservedValues[nJ][2]
            Next nJ
        Else
            For nJ := 1 To Len(aS037ReservedValues)
                aCols[nI][aS037ReservedValues[nJ][1]] := aS037ReservedValues[nJ][2]
            Next nJ
        EndIf
    Next nI
Return


/*/{Protheus.doc} S038StdVal(aCols As Array)
    The function adds default values for RESERVED columns in S038 table. The array must be passed by reference from GPEA320.

    @type Function
    @params aCols, Array, RCC string array
    @return
    @author vselyakov
    @since 01.02.2022
    @version 12.1.33
    @example S038StdVal(@aCols)
*/
Function S038StdVal(aCols)
    Local nI As Numeric
    Local nJ As Numeric
    Local aS038ReservedValues := { {6,  0.0},                ; // SalEdu.
                                   {7,  0.0},                ; // INCRA.
                                   {8,  0.0},                ; // SENAI.
                                   {9,  0.0},                ; // SESI.
                                   {10, 0.0},                ; // SENAC.
                                   {11, 0.0},                ; // SESC.
                                   {12, 0.0},                ; // SEBRAE.
                                   {13, 0.0},                ; // DPC.
                                   {14, 0.0},                ; // FAER.
                                   {15, 0.0},                ; // SENAR.
                                   {16, 0.0},                ; // SECONC.
                                   {17, 0.0},                ; // SEST.
                                   {18, 0.0},                ; // SENAT.
                                   {19, 0.0},                ; // SESCOOP.
                                   {20, 0.0}                 ; // SENAI5.
                                 }

    For nI := 1 To Len(aCols)
        If Len(aCols[nI]) < S038_COLUMNS_NUMBER
            ASize(aCols[nI], S038_COLUMNS_NUMBER)

            For nJ := 1 To Len(aS038ReservedValues)
                AIns(aCols[nI], aS038ReservedValues[nJ][1])
                aCols[nI][aS038ReservedValues[nJ][1]] := aS038ReservedValues[nJ][2]
            Next nJ
        Else
            For nJ := 1 To Len(aS038ReservedValues)
                aCols[nI][aS038ReservedValues[nJ][1]] := aS038ReservedValues[nJ][2]
            Next nJ
        EndIf
    Next nI
Return


/*/{Protheus.doc} S001StdVal(aCols As Array)
    The function adds default values for RESERVED columns in S001 table. The array must be passed by reference from GPEA320.

    @type Function
    @params aCols, Array, RCC string array
    @return
    @author iprokhorenko
    @since 15.02.2022
    @version 12.1.33
    @example S001StdVal(@aCols)
*/
Function S001StdVal(aCols)
    Local nI As Numeric
    Local nJ As Numeric
    Local aS001ReservedValues := { {7,  0.0}                ; // PERCDIR.
                                 }
 
    For nI := 1 To Len(aCols)
        If Len(aCols[nI]) < S001_COLUMNS_NUMBER
            ASize(aCols[nI], S001_COLUMNS_NUMBER)

            For nJ := 1 To Len(aS001ReservedValues)
                AIns(aCols[nI], aS001ReservedValues[nJ][1])
                aCols[nI][aS001ReservedValues[nJ][1]] := aS001ReservedValues[nJ][2]
            Next nJ
        Else
            For nJ := 1 To Len(aS001ReservedValues)
                aCols[nI][aS001ReservedValues[nJ][1]] := aS001ReservedValues[nJ][2]
            Next nJ
        EndIf
    Next nI
Return

/*/{Protheus.doc} RU07XFUN18_RoundingNDFL(aPaymentArray)
    In this function, personal income tax is rounded to an integer.

    @type Function
    @params aPaymentArray, Array, Array of payment for employee (aPd).
    @return
    @author vselyakov
    @since 11.04.2022
    @version 12.1.33
    @example RU07XFUN18_RoundingNDFL(@aPd)
*/
Function RU07XFUN18_RoundingNDFL(aPaymentArray)
    Local nI As Numeric

    For nI := 1 To Len(aPaymentArray)
        If aPaymentArray[nI][COD_PAYMENT_INDEX] == NDFL_PAYMENT_TYPE .Or. aPaymentArray[nI][COD_PAYMENT_INDEX] == NDFL_PREVIOUS_MONTH_PAYMENT_TYPE .Or. aPaymentArray[nI][COD_PAYMENT_INDEX] == NDFL_VACATION_PAYMENT_TYPE
            aPaymentArray[nI][SUM_PAYMENT_INDEX] := Round(aPaymentArray[nI][SUM_PAYMENT_INDEX], 0)
        EndIf
    Next nI
Return

/*/{Protheus.doc} RU07XFUN19_GetAverageForBuisnessTrips(cMat As Char, dBaseDate As Date, oMonths As Object, dStartTrip As Date, dEndTrip As Date)
    Calculate the average amount for buisness trips.

    @type Function
    @params cMat,       Character, Employee personnel number.
            dBaseDate,  Date,      Date for calculating average earnings for the previous period (12 months).
            oMonths,    Object,    Output RUMap with calendar days without absences & receiving AV-payments per period.
            dStartTrip, Date,      Start date of buisness trip.
            dEndTrip,   Date,      End date of buisness trip.
    @return nResult,    Numeric,   Average value for business trips per hour.
    @author vselyakov
    @since 27.04.2022
    @version 12.1.33
    @example RU07XFUN19_GetAverageForBuisnessTrips(cMat, SToD(cPeriod + "01"), RUMap():New(), aAbsences[nI][2], aAbsences[nI][3])
*/
Function RU07XFUN19_GetAverageForBuisnessTrips(cMat As Char, dBaseDate As Date, oMonths As Object, dStartTrip As Date, dEndTrip As Date)
    Local nResult              As Numeric
    Local nWorkDays            As Numeric
    Local aArea                As Array
    Local cQuery               As Character
    Local lIsCalcPrev          As Logical // Shows whether the calculation was in the period.
    Local oStatement           As Object
    Local aMonths              As Array
    Local dEndStart            As Date
    Local nAverageSum          As Numeric
    Local nTripDays            As Numeric
    Local cRUSAvHoursCodFol    As Character
    Local cRUSAvMoneyCodFol    As Character
    Local aAverPayments        As Array
    Local nI                   As Numeric
    Local nIndex               As Numeric
    Local nAccrualAmount       As Numeric

    Default cMat := SRA->RA_MAT
    Default dBaseDate := SToD(cPeriod + "01")
    Default oMonths := RUMap():New()
    Default dStartTrip := dDataBase

    aArea := GetArea()
    nResult := 0
    nWorkDays := RU07XFUN02_GetPeriodWorkingDays(SRA->RA_ADMISSA, dStartTrip - 1)
    lIsCalcPrev := .F.
    dEndStart := dBaseDate
    aMonths := GetYearPeriods(dEndStart, oMonths)
    nTripDays := dEndTrip - dStartTrip + 1
    cRUSAvHoursCodFol := aCodFol[1754, 1]
    cRUSAvMoneyCodFol  := aCodFol[1755, 1]  
    aAverPayments := fRuGetBT()
    nAccrualAmount := 0
    
    /*
     * The employee's payments are checked against the SRD table for the 
     * previous 12 months by pay types 001 and 002.
     *
     * If there were no payments, then we look at the previous 12 months.
     *
     * If there were no payments there, then the calculation is made as if the employee went 
     * on a business trip on the first working day.
    */
    cQuery := " SELECT COUNT(*) AS LNT FROM " + RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New()
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetString(2, cMat)
    oStatement:SetIn(3, {cRUSAvHoursCodFol, cRUSAvMoneyCodFol})
    oStatement:SetIn(4, aMonths)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAlias)
    DbGoTop()
    lIsCalcPrev := ((cAlias)->LNT > 0)
    DbCloseArea()
    
    // If there were no payments, then we look at the previous 12 months.
    If !lIsCalcPrev
        dEndStart := SToD(AllTrim(Str(Year(dEndStart) - 1)) + SubStr(DToS(dEndStart), 5, 4))
        aMonths := GetYearPeriods(dEndStart, oMonths)

        oStatement:SetIn(4, aMonths)
        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())
        DbSelectArea(cAlias)
        DbGoTop()
        lIsCalcPrev := ((cAlias)->LNT > 0)
        DbCloseArea()
    EndIf

    /*
     * The average is calculated for the case if the 
     * employee went on a business trip on the first working day. 
    */
    If SRA->RA_ADMISSA == dStartTrip
        If SRA->RA_CATFUNC == "M"
            nAverageSum := (SRA->RA_SALARIO / NDIASC) * nTripDays // Average sum per day.
        ElseIf SRA->RA_CATFUNC == "H"
            nAverageSum := SRA->RA_SALARIO * nTripDays * SRA->RA_HRSDIA // Average sum per day.
        EndIf
    ElseIf AnoMes(SRA->RA_ADMISSA) == AnoMes(dStartTrip)
        // Define all accrual sum.        
        For nI := 1 To Len(aAverPayments)
            nIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == aAverPayments[nI]})
            If nIndex > 0
                nAccrualAmount += aPd[nIndex][SUM_PAYMENT_INDEX]
            EndIf
        Next nI

        If SRA->RA_CATFUNC == "M"
            nAverageSum := (nAccrualAmount / RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, SRA->RA_ADMISSA)) * nWorkDays // Average sum per day.
        ElseIf SRA->RA_CATFUNC == "H"
            nAverageSum := nAccrualAmount / RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, SRA->RA_ADMISSA) // Average sum per day.
        EndIf
    ElseIf lIsCalcPrev
        nAverageSum := fRUBTAvCalc(cMat, dEndStart, RUMap():New()) * SRA->RA_HRSDIA // Average sum per day.
    ElseIf !lIsCalcPrev
        If SRA->RA_CATFUNC == "M"
            nAverageSum := (SRA->RA_SALARIO / NDIASC) * nTripDays // Average sum per day.
        ElseIf SRA->RA_CATFUNC == "H"
            nAverageSum := SRA->RA_SALARIO * nTripDays * SRA->RA_HRSDIA // Average sum per day.
        EndIf
    EndIf

    /*       CALCULATION OF BUISNESS TRIP
     * 1. SRA->RA_ADMISSA == dStartTrip - employee go to buisness trip in first work day.
     * 2. AnoMes(SRA->RA_ADMISSA) == AnoMes(dStartTrip) - employe employee go to buisness trip in
     *    first work month.
     * 3. !lIsCalcPrev - a case where an employee had no payments in the last 24 months.
     * 4. Regular calculations for buisness trip. Employee has payments in last 12 months.
    */
    If SRA->RA_ADMISSA == dStartTrip
        nResult := nAverageSum

    ElseIf AnoMes(SRA->RA_ADMISSA) == AnoMes(dStartTrip)
        If SRA->RA_CATFUNC == "M"
            nResult := (nAverageSum / nWorkDays) * nTripDays
        ElseIf SRA->RA_CATFUNC == "H"
            nResult := nAverageSum * nTripDays
        EndIf

    ElseIf !lIsCalcPrev
        /* Payments and days worked were before the billing period.
         * If there were no payments, then we consider that the employee went 
         * on a business trip on the first working day.
        */
        nResult := nAverageSum

    Else
        nResult := nAverageSum * nTripDays
    EndIf

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return nResult

/* {Protheus.doc} RU07XFUN20_CheckDateInYearOfActivePeriod(cDate)
    This function checks if the date is in the year of the active period.

    @type Function
    @params cDate, Character, The date for checking
    @params cFormat, Character, The format of date (1 - YYYY/MM, 2 - MM/YYYY)
    @params lWarn, Logical, Show warning
    @return lIsIn, Logical, The date is in the year of the active period.
    @author dchizhov
    @since 2022/06/16
    @version 12.1.23
    @example RU07XFUN20_CheckDateInYearOfActivePeriod(cDate, "1", .T.)
*/
Function RU07XFUN20_CheckDateInYearOfActivePeriod(cDate, cFormat, lWarn)

    Local lIsIn As Logical

    If cFormat == "1"
        lIsIn := Val(Substr(cDate, 1, 4)) >= Year(RU07XFUN21_GetActivePeriod_MEC())
    Else
        lIsIn := Val(Substr(cDate, 3, 4)) >= Year(RU07XFUN21_GetActivePeriod_MEC())
    End

    If !(lIsIn) .And. lWarn
        MsgAlert(OemToAnsi(STR0011), OemToAnsi(STR0010))
    End

Return lIsIn

/* {Protheus.doc} RU07XFUN21_GetActivePeriod()
    A function that returns the beginning of the current period for the process of monthly payment under an employment contract.
    Data get from RFQ table.

    @type Function
    @return dActivePeriod, Date, Date of current active period.
    @author dchizhov
    @since 2022/06/16
    @version 12.1.23
    @example dActivePeriod := RU07XFUN21_GetActivePeriod_MEC()
*/
Function RU07XFUN21_GetActivePeriod_MEC()

    Local dActivePeriod As Date
    Local aSavedArea As Array

    aSavedArea := GetArea()
    dActivePeriod := SToD("") // Default value for active period.
    
    DbSelectArea("RFQ")
    DbSetOrder(1)

    If DbSeek(FWXFilial("RFQ") + CODE_OF_PROCESS_MONTHLY_EMPLOYMENT_CONTRACT, .T.)
        While !EoF()
            If (RFQ->RFQ_STATUS == "1")
                dActivePeriod := RFQ->RFQ_DTINI
                Exit
            EndIf
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()
    RestArea(aSavedArea)

Return dActivePeriod

/*/{Protheus.doc} RU07XFUN23_GetNumberDayAbsenceByPeriod(cMat, dStartPer, dEndPer)
    Function for calculating the number of calendar days of absence in a given period for an employee

    @type Function
    @params cMat,      Character, Employee payroll number.
            dStartPer, Date,      Start date of the specified period.
            dEndPer,   Date,      End date of the specified period.
    @return nResult,   Numeric,   The number of calendar days of absence in a given period for an employee
    @author dchizhov
    @since 02.11.2022
    @version 12.1.33
    @example RU07XFUN23_GetNumberDayAbsenceByPeriod(cMat, SRA->RA_ADMISSA, dDataini - 1)
*/
Function RU07XFUN23_GetNumberDayAbsenceByPeriod(cMat, dStartPer, dEndPer)

    Local cDateStart As Character
    Local cDateEnd   As Character
    Local cQuery     As Character
    Local cQAliases  As Character
    Local aArea      As Array
    Local aValues    As Array
    Local nResult    As Numeric
    
    cDateStart := DToS(dStartPer)
    cDateEnd := DToS(dEndPer)

    aArea := GetArea()
    nResult := 0
    aAbsences := {}
    aValues := {}

    cQuery := "SELECT R8_DATAINI, R8_DATAFIM FROM " + RetSQLName("SR8") + " WHERE "
    cQuery += " R8_FILIAL = ? AND "
    cQuery += " R8_MAT = ? AND "
    cQuery += " ( (? >= R8_DATAINI AND ? <= R8_DATAFIM) OR "
    cQuery += " (? <= R8_DATAINI AND ? >= R8_DATAFIM) OR "
    cQuery += " (? BETWEEN R8_DATAINI AND R8_DATAFIM AND ? >= R8_DATAFIM) OR "
    cQuery += " (? BETWEEN R8_DATAINI AND R8_DATAFIM AND ? <= R8_DATAINI) ) AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    AAdd(aValues, FWxFilial("SR8"))
    AAdd(aValues, cMat)
    AAdd(aValues, cDateStart)
    AAdd(aValues, cDateEnd)
    AAdd(aValues, cDateStart)
    AAdd(aValues, cDateEnd)
    AAdd(aValues, cDateStart)
    AAdd(aValues, cDateEnd)
    AAdd(aValues, cDateEnd)
    AAdd(aValues, cDateStart)

    cQAliases:= GetNextAlias()
    DBUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cQAliases, .T., .F.)

    DBSelectArea(cQAliases)
    DBGoTop()

    While !EoF()
        nResult += Iif(SToD((cQAliases)->R8_DATAFIM) > dEndPer, dEndPer, SToD((cQAliases)->R8_DATAFIM)) - ;
            Iif(SToD((cQAliases)->R8_DATAINI) < dStartPer, dStartPer, SToD((cQAliases)->R8_DATAINI)) + 1
        DBSkip()
    EndDo

    DBCloseArea()
    RestArea(aArea)

Return nResult

/*/{Protheus.doc} RU07XFUN22_GetSx3Translations(cCampo, nFieldType)
    A function to get the translation of X3_TITULO and X3_DESCRIC from table XXK.
    Specify the nFieldType parameter:
        1 - X3_TITULO, Title.
        2 - X3_DESCRIC, Description.

    @type Function
    @params cCampo, Character, Filed name in SX3.
            nFieldType, Numeric, Type of value (1=X3_TITULO, 2=X3_DESCRIC).
    @return
    @author vselyakov
    @since 09.10.2022
    @version 12.1.33
    @example RU07XFUN22_GetSx3Translations("QV_GRAU")
*/
Function RU07XFUN22_GetSx3Translations(cCampo, nFieldType)
    Local aArea    As Array
    Local aAreaSX3 As Array
    Local cTitle   As Character

    Default nFieldType := 1 // X3_Titulo

    aArea := GetArea()
    aAreaSX3 := SX3->(GetArea())
    cTitle := ""

    SX3->(dbSelectArea("SX3"))
    SX3->(dbSetOrder(2))

    If ( SX3->(DbSeek(cCampo)))
        cTitle := Iif(nFieldType == 1, Alltrim(X3Titulo()), Alltrim(X3Descric()))
    EndIf

    RestArea(aAreaSX3)
    RestArea(aArea)

Return cTitle

/*/{Protheus.doc} S043StdVal(aCols As Array)
    The function adds default values for RESERVED columns in S043 table. The array must be passed by reference from GPEA320.

    @type Function
    @params aCols, Array, RCC string array
    @return
    @author vselyakov
    @since 31.10.2022
    @version 12.1.33
    @example S043StdVal(@aCols)
*/
Function S043StdVal(aCols)
    Local nI As Numeric
    Local nJ As Numeric
    Local aS043ReservedValues := { {9,   "N"},                ; // FGTSMAnt.
                                   {10,  "N"},                ; // FGTSMRes.
                                   {11,  "N"},                ; // FGTSMulta.
                                   {12,  "N"},                ; // DSRMedFe.
                                   {13,  "N"},                ; // DSRMedDT.
                                   {14,  "N"},                ; // DSRMAvP.
                                   {17,  "N "},               ; // AfastFGTS.
                                   {18,  "N "},               ; // CodigoAM.
                                   {19,  "N"},                ; // PgtContE.
                                   {20,  "N"},                ; // DesContE.
                                   {23,  "N"},                ; // ImpSacado.
                                   {28,  "   "},              ; // PgMultDet.
                                   {29,  "N"}                 ; // FERVENCIDA.
                                 }

    For nI := 1 To Len(aCols)
        If Len(aCols[nI]) < S043_COLUMNS_NUMBER
            ASize(aCols[nI], S043_COLUMNS_NUMBER)

            For nJ := 1 To Len(aS043ReservedValues)
                AIns(aCols[nI], aS043ReservedValues[nJ][1])
                aCols[nI][aS043ReservedValues[nJ][1]] := aS043ReservedValues[nJ][2]
            Next nJ
        Else
            For nJ := 1 To Len(aS043ReservedValues)
                aCols[nI][aS043ReservedValues[nJ][1]] := aS043ReservedValues[nJ][2]
            Next nJ
        EndIf
    Next nI
Return

/*/
{Protheus.doc} RU07XFUN24_GetReasonDissmiss(cFil, cMat, cSDataDem)
    Function that receives the reason for dismissal.

    @type Function
    @params cFil,      Character, Filial of the dismissed employeere.
    @params cMat,      Character, Tab.Number of the dismissed employeere.
    @params cSDataDem, Character, Date of dismissal in string format.
    @author dchizhov
    @since 27.12.2022
    @version 12.1.23
    @return aDisReason, Array, Information about reason of dismiss ({type, descr}) - expandable as needed
    @example aDisReason := RU07XFUN24_GetReasonDissmiss(cFil, cMat, cSDataDem)
/*/
Function RU07XFUN24_GetReasonDissmiss(cFil, cMat, cSDataDem)

    Local aDisReason As Array
    Local aArea      As Array
    Local aSRGArea   As Array
    Local cRCCDescr  As Character

    aDisReason := {}
    aArea := GetArea()
    aSRGArea := SRG->(GetArea())

    If Empty(cSDataDem)
        csDataDem := "99999999"
    EndIf

    DbSelectArea("SRG")
    SRG->(DbSetOrder(RetOrder("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)")))
    SRG->(DbGoTop())
    If SRG->(DbSeek(cFil + cMat + cSDatadem))
        While SRG->RG_FILIAL == cFil .And. SRG->RG_MAT == cMat .And. DTOS(SRG->RG_DATADEM) == cSDataDem
            cRCCDescr := AllTrim(FDescRCC("S043", SRG->RG_TIPORES, 1, 2, 1, 69))
            SRG->(DbSkip())
        EndDo
        If !Empty(cRCCDescr)
            Aadd(aDisReason, AllTrim(SubStr(cRCCDescr, 1, 2)))
            Aadd(aDisReason, AllTrim(SubStr(cRCCDescr, 3, 30)))
        EndIf
    EndIf
    
    SRG->(DbCloseArea())
    SRG->(RestArea(aSRGArea))
    RestArea(aArea)

Return aDisReason

/*/
{Protheus.doc} RU07XFUN25_GetComboSelected(cCampo, cVal)
    The function get selected string for combo field in selected language/

    @type Function
    @params cCampo, Character, Campo.
    @params cVal,   Character, Selected value.
    @author dchizhov
    @since 19.01.2023
    @version 12.1.23
    @return cResult, Character, selected string for combo field
    @example cSexo := RU07XFUN25_GetComboSelected("RA_SEXO", SRA->RA_SEXO)
/*/
Function RU07XFUN25_GetComboSelected(cCampo, cVal)

    Local aArea     As Array
    Local aCboxCont As Array
    Local nInd      As Numeric
    Local cResult   As Character

    aArea := GetArea()
    aCboxCont := X3CboxToArray(cCampo)

    nInd := aScan(aCboxCont[2], {|X| X == cVal})
    If nInd > 0 .And. nInd <= Len(aCboxCont[1])
        cResult := aCboxCont[1, nInd]
        cResult := SubStr(aCboxCont[1, nInd], At('-', aCboxCont[1, nInd]) + 2)
    Else
        cResult := ""
    EndIf

    RestArea(aArea)

Return cResult


/*/{Protheus.doc} RU07XFUN24_AutoFillingEmployeeName(aSRAFields, cFileString)
    This function adds SRA fields to fill in the surname, first name and patronymic of the candidate when he is made an employee.
    The field matching file is located in the appserver in the system folder: "appserver:/opt/ma3/appserver/data/system/rspdepa.txt"

    Example of using exits into RSPM001.PRW

    @type Function
    @params aSRAFields, Array, Array without filled values for emplyee from candidate.
            cFileString, Character, The line of correspondence to the filling fields from rspdepa.txt.
    @return aSRAFields, Array, Array with filled values for emplyee from candidate.
    @author vselyakov
    @since 02.02.2023
    @version 12.1.33
    @example aDePara := RU07XFUN24_AutoFillingEmployeeName(aDePara, cString)
*/
Function RU07XFUN26_AutoFillingEmployeeName(aSRAFields, cFileString)
    Local aCandidateName As Array
    Local aFields As Array
    Local nI As Numeric

    Default aSRAFields := {}
    Default cFileString := ""

    aFields := {"M->RA_PRISOBR", "M->RA_PRINOME", "M->RA_SECNOME"}
    aCandidateName := StrTokArr(&(AllTrim(Left(cFileString, 30))), " ")

    aAdd(aSRAFields, {&(AllTrim(Left(cFileString, 30))), "M->RA_NOMECMP"})

    For nI := 1 To Len(aCandidateName)
        aAdd(aSRAFields, {AllTrim(aCandidateName[nI]), aFields[nI]})
    Next nI


Return aSRAFields

/*/{Protheus.doc} RU07XFUN27_CalculationWorkDaysForAdvancePayment(aCalendarList, nPosDayType, dADIPayment)
    The function calculates the number of working days in the period for 
    the advance payment scenario (ADI) before the payment date dADIPayment.

    It is need for RULOC-4195.

    @type Function
    @params aCalendarList, Array, Array of calendar days of the period with the day type (RCG).
            nPosDayType, Numeric, Index of position type day into calendar array aCalendarList.
            dADIPayment, Date, Date of ADI scenario payment.
    @return nWorkDaysForAdvance, Numeric, Number of working days in the period before ADI scenario payment.
    @author vselyakov
    @since 21.02.2023
    @version 12.1.33
    @example nDaysADV := RU07XFUN27_CalculationWorkDaysForAdvancePayment(aAuxRCG, nPosTipDia, M->RCH_DTPAGO)
*/
Function RU07XFUN27_CalculationWorkDaysForAdvancePayment(aCalendarList, nPosDayType, dADIPayment)
    Local nWorkDaysForAdvance As Numeric
    Local aArea               As Array
    Local dADIPaymentDate     As Date
    Local nI                  As Numeric

    aArea := GetArea()
    nWorkDaysForAdvance := 0

    If aCalendarList <> Nil .And. !Empty(aCalendarList) .And. nPosDayType > 0 .And. dADIPayment <> Nil .And. !Empty(dADIPayment)
        // Get payment date for ADI scenario RCH.
        dADIPaymentDate := dADIPayment

        // Calculation work days.
        If dADIPaymentDate <> Nil
            For nI := 1 To Len(aCalendarList)
                If aCalendarList[nI, nPosDayType] $ "1*2" .And. aCalendarList[nI, 1] <= dADIPaymentDate
                    nWorkDaysForAdvance += 1
                EndIf
            Next nI
        EndIf
    Else
        Alert(STR0016)
    EndIf

    RestArea(aArea)

Return nWorkDaysForAdvance


/*/{Protheus.doc} RU07XFUN28_GetADIDaysFromRCF()
    The function returns the value of the number of working days before the advance payment date (RCF_DEUTAG) for the billing period.

    It is need for RULOC-4195.

    @type Function
    @params 
    @return nADIDays, Numeric, Number of working days before the advance payment date (RCF_DEUTAG) for the billing period.
    @author vselyakov
    @since 01.03.2023
    @version 12.1.33
    @example nDiastb := RU07XFUN28_GetADIDaysFromRCF()
*/
Function RU07XFUN28_GetADIDaysFromRCF()
    Local nADIDays As Numeric
    Local aArea    As Array
    Local aRCFArea As Array

    nADIDays := 0
    aArea := GetArea()
    aRCFArea := RCF->(GetArea())

    If !Empty(Posicione("RCF", 2, aPeriodo[1][27] + cProcesso + aPeriodo[1][15] + aPeriodo[1][16] + RCF->RCF_ROTEIR + aPeriodo[1][1] + cSemana, "RCF_DAYSAD"))
        nADIDays := RCF->RCF_DAYSAD
    EndIf

    RCF->(RestArea(aRCFArea))
    RestArea(aArea)

Return nADIDays


/*/{Protheus.doc} RU07XFUN29_CalculationADIPayment(nADIPaymentCurrent)
    The function calculate the amount of the advance payment. 
    If there were no changes in the bid, the current amount is returned. 
    Otherwise, the calculated amount, taking into account the changes in the bid

    It is need for RULOC-4195.

    @type Function
    @params nADIPaymentCurrent, Numeric, The current value of the advance payment.
    @return nADIPayment, Numeric, The amount of the advance payment.
    @author vselyakov
    @since 03.03.2023
    @version 12.1.33
    @example Val_Adto := RU07XFUN29_CalculationADIPayment(Val_Adto)
*/
Function RU07XFUN29_CalculationADIPayment(nADIPaymentCurrent)
    Local nADIPayment   As Numeric
    Local dStartDate    As Date
    Local aSalaryChange As Array
    Local lIsChanged    As Logical
    Local nR3_VALOR     As Numeric   // New value of salary.
    Local nR3_ANTEAUM   As Numeric   // Old value of salary
    Local dR3_DATA      As Date      // Date of changes of salary.
    Local nI            As Numeric
    Local dBeforeDate   As Date
    Local nBfrWrkDays   As Numeric
    Local nAftWrkDays   As Numeric

    nADIPayment := nADIPaymentCurrent
    lIsChanged := .F.
    dStartDate  := IIF((SRA->RA_ADMISSA > aPeriodo[1][3] .And. SRA->RA_ADMISSA <= RCH->RCH_DTPAGO), SRA->RA_ADMISSA, aPeriodo[1][3]) // If the employee hiring date is greater than the period start date then use RA_ADMISSA as start date.

    // Get data for calculating with changes of the salary for a month. Checking the date of change of salary.
    // If date of change enter into calculation period then We must take into account the new rate.
    // Else - get value from SALMES mnemonic (it is calculate the salary on new value of salary without old salary).
    aSalaryChange := GetSalaryChange(SRA->RA_MAT, aPeriodo[1][3], aPeriodo[1][4]) //RCH->RCH_DTPAGO)

    If Len(aSalaryChange) > 0 .And. aSalaryChange[1][2] <> aSalaryChange[1][3]
        lIsChanged  := .T.
    EndIf

    If lIsChanged // The employee have a rate change.
        dBeforeDate := dStartDate
        nADIPayment := 0

        For nI := 1 To Len(aSalaryChange)
            dR3_DATA    := aSalaryChange[nI][1] // Date of changes of salary.
            nR3_VALOR   := aSalaryChange[nI][2] // New value of salary.
            nR3_ANTEAUM := aSalaryChange[nI][3] // Old value of salary.

            // If the rate change date was made after the advance payment date, 
            // then the limit for determining working days is the advance payment date.
            If aSalaryChange[nI][1] > RCH->RCH_DTPAGO
                dR3_DATA := RCH->RCH_DTPAGO
            EndIf

            // Get work days from period before rate the salary.
            nBfrWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, dBeforeDate, dR3_DATA - 1)

            Do Case
                Case (SRA->RA_CATFUNC == "H") // Hourly employee.
                    nADIPayment += nR3_ANTEAUM * nBfrWrkDays * SRA->RA_HRSDIA

                Case (SRA->RA_CATFUNC == "M") // Employee with monthly pay.
                    nADIPayment += (nR3_ANTEAUM  * nBfrWrkDays / NDIASC)
            EndCase

            dBeforeDate := dR3_DATA
        Next nI

        nAftWrkDays := RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, dBeforeDate, RCH->RCH_DTPAGO)
        Do Case
            Case (SRA->RA_CATFUNC == "H") // Hourly employee.
                nADIPayment += nR3_VALOR * nAftWrkDays * SRA->RA_HRSDIA

            Case (SRA->RA_CATFUNC == "M") // Employee with monthly pay.
                nADIPayment += ((nR3_VALOR  * nAftWrkDays / NDIASC))
        EndCase
        
    Else // The employee did not have a rate change.
        Do Case
            Case (SRA->RA_CATFUNC == "H") // Hourly employee.
                nADIPayment := SRA->RA_SALARIO * RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, dStartDate, RCH->RCH_DTPAGO) * SRA->RA_HRSDIA

            Case (SRA->RA_CATFUNC == "M") // Employee with monthly pay.
                nADIPayment := (SRA->RA_SALARIO * RU07XFUN03_GetPerWorkDayWithAbsence(SRA->RA_MAT, dStartDate, RCH->RCH_DTPAGO)) / NDIASC
        EndCase
    EndIf

    nADIPayment := nADIPayment * (SRA->RA_PERCADT / 100)

Return nADIPayment

/*/{Protheus.doc} RU07XFUN30_CreateNewIdCode(cIdCode, cDescription, cRequired, cHelp, cVersion)
    Function create new ID code into RCN table.
    This function is needed if you need to create only a specific ID with the desired code.
    The function will return .T. if the specified ID has been added to the RCN. 
    Otherwise, it will return .F.

    @type Function
    @params cIdCode, Character, The ID code, This variable is required.
            cDescription, Character, Description of ID code.
            cRequired, Character, If ID will be required then use symbol '*', else - '-'.
            cHelp, Character, Help text.
            cVersion, Character, Version into RCN.
    @return lResult, Logical, New ID was added.
    @author vselyakov
    @since 02.05.2023
    @version 12.1.33
    @example RU07XFUN30_CreateNewIdCode("1854", "Post Term. Christmas Bonus 1st installment anticipation", "-", "", "212")
*/
Function RU07XFUN30_CreateNewIdCode(cIdCode, cDescription, cRequired, cHelp, cVersion)
    Local lResult := .F. As Logical
    Local aArea := GetArea() As Array
    Local aRCNArea := RCN->(GetArea()) As Array
    Local cRCNFilial := xFilial("RCN") As Character

    Default cDescription := "This default ID"
    Default cRequired := "-" // Optional ID.
    Default cHelp := ""
    Default cVersion := "212"

    DbSelectArea("RCN")
    DbSetOrder(1) // RCN_FILIAL+RCN_CODIGO

    If !Empty(cIdCode) .And. !RCN->(DbSeek(cRCNFilial + cIdCode))
        If RCN->(RecLock("RCN", .T.))
            RCN->(RCN_FILIAL) := cRCNFilial
            RCN->(RCN_CODIGO) := cIdCode
            RCN->(RCN_DESCRI) := cDescription
            RCN->(RCN_HELP)   := cHelp
            RCN->(RCN_OBRIGA) := If(Substr(cRequired, 4, 1) == "*", "1", "2")
            RCN->(RCN_VERSAO) := cVersion
            RCN->(MsUnlock())

            lResult := .T.
        EndIf
    EndIf

    RCN->(RestArea(aRCNArea))
    RestArea(aArea)

Return lResult

/*/{Protheus.doc} RU07XFUN31_AddNewID()
    Wrapper function for adding an ID.
    This function is called in GPEXIDC to add IDs with the specified codes.

    @type Function
    @params 
    @return 
    @author vselyakov
    @since 03.05.2023
    @version 12.1.33
    @example RU07XFUN31_AddNewID()
*/
Function RU07XFUN31_AddNewID()
    Local lResult := .F. As Logical

    // Create ID 1854.
    lResult := RU07XFUN30_CreateNewIdCode("1854", STR0017, "-", "", "212") // "Early write-off of contribution 13 RFP".

    // If something is not created, then we write a message to the user.
    If !lResult
        MsgStop(STR0018, STR0015) // "Some ID was not created. Please check that the ID code in function RU07XFUN31 is complete", "Error".
    EndIf

Return lResult

/*/{Protheus.doc} RU07XFUN32_GetAbsenceDays(cCurentPeriod, cPreviousPeriod, lIsPregnancy)
    The function obtains the value of the absence days into period or pregnancy days from the table S208 by the calculation period.
    This function is required to initialize the mnemonic NDAYAMOUNT.

    Depending on the absence type, the values from the LN or BiR column will be taken into account.

    @type Function
    @params cFirstPeriod, Character, 
            cSecondPeriod, Character, 
            lIsPregnancy, Logical, Shows which column S208 to take values from. Defaul value = .F.
    @return nKDRResult, Numeric, Value of KDR from S208 table.
    @author vselyakov
    @since 14.06.2023
    @version 12.1.33
    @example RU07XFUN32_GetAbsenceDays()
             nResult := RU07XFUN32_GetAbsenceDays(AllTrim(Str(Year(dFirstYearDate) - 1) + "01"), AllTrim(Str(Year(dSecondYearDate) - 1) + "01"), .F.)
*/
Function RU07XFUN32_GetAbsenceDays(cCurentPeriod, cPreviousPeriod, lIsPregnancy)
    Local nLinePosition := 0 As Numeric
    Local nKDRResult := 0 As Numeric // Value by default.
    Local cCurPeriod As Character // First previous period code.
    Local cPrevPeriod As Character // Second previous period code.
    Local nS208Column As Numeric

    Default cCurentPeriod := AllTrim(Str(Val(SubStr(cPeriodo, 1, 4)) - 1) + "01") // Example, "202201".
    Default cPreviousPeriod := AllTrim(Str(Val(SubStr(cPeriodo, 1, 4)) - 2) + "01") // Example, "202101".
    Default lIsPregnancy := .F.

    cCurPeriod := cCurentPeriod
    cPrevPeriod := cPreviousPeriod

    nS208Column := Iif(!lIsPregnancy, 7, 10)

    /*
        Into S208 table using next columns:
        * 4  - ANOMESI,   Character, Start period code (example, "201801")
        * 5  - ANOMESF,   Character, End period code (example, "201812")
        * 7  - RUSS20804, Numeric,   Absence days value (example, "365")
        * 10 - RUSS20807, Numeric,   Pregnancy days value (example, "365" or "366").
    */
    nLinePosition := fPosTab("S208", cCurPeriod, ">=", 4, cCurPeriod, "<=", 5)
    
    // If line in S208 does not exist for current period then using default value.
    If nLinePosition > 0
        nKDRResult += fTabela("S208", nLinePosition, nS208Column)
    EndIf

    nLinePosition := fPosTab("S208", cPrevPeriod, ">=", 4, cPrevPeriod, "<=", 5)
    
    // If line in S208 does not exist for current period then using default value.
    If nLinePosition > 0
        nKDRResult += fTabela("S208", nLinePosition, nS208Column)
    EndIf

Return nKDRResult

/*/{Protheus.doc} RU07XFUN33_GetMROTMonth(cCurentPeriod)
    The function obtains the MROT month value from the table S208 by the calculation period.

    @type Function
    @params cCurentPeriod, Character, Current calculation period.
    @return nResult, Numeric, MROT month value from S208 table.
    @author vselyakov
    @since 15.06.2023
    @version 12.1.33
    @example RU07XFUN33_GetMROTMonth(cPeriodo)
             RU07XFUN33_GetMROTMonth()
*/
Function RU07XFUN33_GetMROTMonth(cCurentPeriod)
    Local nLinePosition := 0 As Numeric
    Local nResult := 0 As Numeric

    Default cCurentPeriod := GetPeriodCalc() // This function using into S_CARGARCH for cPeriodo mnemonic.

    /*
        Into S208 table using next columns:
        * 4 - ANOMESI,   Character, Start period code (example, "201801")
        * 5 - ANOMESF,   Character, End period code (example, "201812")
        * 8 - RUSS20806, Numeric,   MROT month value (example, "24")
    */
    nLinePosition := fPosTab("S208", cCurentPeriod, ">=", 4, cCurentPeriod, "<=", 5)
    
    // If line in S208 does not exist for current period then using default value.
    If nLinePosition > 0
        nResult := fTabela("S208", nLinePosition, 8)
    EndIf

Return nResult

/*/{Protheus.doc} RU07XFUN34_GetLimitBase(nBaseSum as Numeric, nOperation as Numeric)
    Returns the OPS base value for the current billing period.

    @type Function
    @params nBaseSum,      Numeric,    Value of the current payment, for calculating the base
            nOperation,    Numeric,    Operation number
    @return nResult,       Numeric,    OPS base value in the current billing period
            If nOperation = 1, will return the OPS base to the limit
            If nOperation = 2, will return the OPS base over the limit
    @author iprokhorenko
    @since 2023/08/16
    @version 12.1.23
*/
Function RU07XFUN34_GetLimitBase(nBaseSum as Numeric, nOperation as Numeric)
    Local nResult       As Numeric    
    Local nSumToLimit   As Numeric
    Local nSumOverLimit As Numeric
    Local nExcess       As Numeric

    nExcess := fRUBaseLimitExcess(SRA->RA_MAT, 1, CPERIODO, nBaseSum)

    If nExcess == 0
        nSumToLimit := nBaseSum
        nSumOverLimit := 0
    ElseIf nExcess == nBaseSum
        nSumToLimit := 0
        nSumOverLimit := nExcess
    Else
        nSumToLimit := nBaseSum - nExcess
        nSumOverLimit := nExcess
    EndIf

    If nOperation == 1
        nResult := nSumToLimit 
    ElseIf nOperation == 2
        nResult := nSumOverLimit 
    EndIf

Return nResult

/*/{Protheus.doc} RU07XFUN35_Ref182n(cMat As Char)
    Returns the value of the Reference 182n in current calculation period

    @type Function
    @params cMat,               Char,      Employee's Reg. Number (RA_MAT)
                        
    @return aRef182n,           Array,   Value of the Reference 182n in current calculation period
    @author iprokhorenko
    @since 2023/08/16
    @version 12.1.23
*/
Function RU07XFUN35_Ref182n(cMat As Char)
    Local aRef182n
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cGroup       As Character
    Local cStructCodeF As Character

    aRef182n := {}

    aArea := GetArea()
    cGroup := cEmpAnt
    cStructCodeF := ""

    cQuery := "SELECT * FROM " + RetSQLName("F5G") + " WHERE F5G_MAT = ? AND D_E_L_E_T_ = ' ' ORDER BY F5G_YEAR DESC"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cMat)
    
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(EoF())
        aAdd(aRef182n, {(cTab)->F5G_YEAR, (cTab)->F5G_AMT, (cTab)->F5G_DAYS})
        (cTab)->(dBSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aRef182n

/*/{Protheus.doc} RU07XFUN36_StornoAlimony(cScenario)
    Storno of alimony from advance scenario in salary calculation.

    Jira-tasks: 
        * RULOC-5454
        * RULOC-5482 Added logic for Netto conditions.

    @type Function
    @params cScenario, Character, Calculation scenario.
    @return nADIAlimonySum, Numeric, Alimony sum from advance scenario.
    @author vselyakov
    @since 08.09.2023
    @version 12.1.33
    @example RU07XFUN36_StornoAlimony(cRot)
*/
Function RU07XFUN36_StornoAlimony(cScenario)
    Local aArea := GetArea() As Array
    Local aBenefits := {} As Array
    Local oStatement := FWPreparedStatement():New() As Object
    Local cQuery := "" As Character
    Local cAlias := "" As Character
    Local nI := 0 As Numeric
    Local nAlimonyIndex := 0 As Numeric
    Local nADIAlimonySum := 0 As Numeric
    Local aAlimonyValues := {} As Array
    Local nAlimonyValues := 0 As Numeric
    Local aBasesAlimony := RU07XFUN37_BaseAlimony(.T./*lWriteBase*/) As Array
    Local nTotalIndex := 0 As Numeric
    Local cTotalPayment := "" As Character
    Local cCodeDebtCurrentMonth := aCodFol[0045, 1] As Character // SRV_PD = "395".
    Local nIndexDebtPayment := 0 As Numeric
    Local nTotalAmount := 0 As Numeric
    Local nDebtAmount := 0 As Numeric

    Default cScenario := SALARY_SCENARIO_NAME

    // Set null for debt current month (payment "395") because the debt is formed before the call for reversal of alimony.
    nIndexDebtPayment := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == "395"})
    If nIndexDebtPayment > 0
        aPd[nIndexDebtPayment][SUM_PAYMENT_INDEX] := 0
    EndIf

    If cScenario == SALARY_SCENARIO_NAME
        cTotalPayment := aCodFol[0047, 1] // RV_COD = "870".
    ElseIf cScenario == ADVANCE_SCENARIO_NAME
        cTotalPayment := aCodFol[0546, 1] // RV_COD = "872".
    ElseIf cScenario == VACATION_SCENARIO_NAME
        cTotalPayment := aCodFol[0102, 1] // RV_COD = "560".
    ElseIf cScenario == TERMINATION_SCENARIO_NAME
        cTotalPayment := aCodFol[0126, 1] // RV_COD = "565".
    EndIf

    // Search payments code of alimony for scenarios for calculated employee.
    cQuery := " SELECT "
    cQuery += " RQ_ORDEM, RQ_PERCENT, RQ_VERBADT, RQ_VERBFOL, RQ_VERBFER, RQ_CALSLIQ "
    cQuery += " FROM " + RetSqlName("SRQ") + " WHERE "
    cQuery += "         RQ_FILIAL = ?    "
    cQuery += "     AND RQ_MAT = ?       "
    cQuery += "     AND RQ_SEQUENC = ?   " // Need only "01".
    cQuery += "     AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRQ"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, "01") // "01" because payments code write in first row of benefit.

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While !((cAlias)->(Eof()))
        aAdd(aBenefits, {                                  ;
                            SRA->RA_MAT,                   ; // 1.
                            (cAlias)->(RQ_ORDEM),          ; // 2. Beneficiar number.
                            (cAlias)->(RQ_PERCENT) * 0.01, ; // 3. Alimony percent.
                            (cAlias)->(RQ_VERBADT),        ; // 4. Payment code for ADI.
                            (cAlias)->(RQ_VERBFOL),        ; // 5. Payment code for FOL.
                            (cAlias)->(RQ_VERBFER),        ; // 6. Payment code for FER.
                            (cAlias)->(RQ_CALSLIQ)         ; // 7. S="Yes". Netto.
                        }                                  ;
            )

        (cAlias)->(DBSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    FWFreeObj(oStatement)

    // Calculations.
    For nI := 1 To Len(aBenefits)
        // Defenition index of alimony payment for salary.
        If cScenario == SALARY_SCENARIO_NAME
            nAlimonyIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == aBenefits[nI][5]})
            // Get alimony payment from ADI scenario.
            nADIAlimonySum := RU07NDFL05_GetPaymentValue(SRA->RA_MAT, aBenefits[nI][4], ADVANCE_SCENARIO_NAME, cPeriodo, .F.)
        ElseIf cScenario == ADVANCE_SCENARIO_NAME
            nAlimonyIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == aBenefits[nI][4]})
        ElseIf cScenario == VACATION_SCENARIO_NAME
            nAlimonyIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == aBenefits[nI][6]})
        ElseIf cScenario == TERMINATION_SCENARIO_NAME
            nAlimonyIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == aBenefits[nI][5]})
            // Get alimony payment from ADI scenario.
            nADIAlimonySum := RU07NDFL05_GetPaymentValue(SRA->RA_MAT, aBenefits[nI][4], ADVANCE_SCENARIO_NAME, cPeriodo, .F.)
        EndIf

        // Calculation alimony amount for every beneficiary.
        //                        "1"                "2"                             "3"
        //                    "Employee num."   "Benefic. numb."      " (Salary - tax) * BeneficiarPercent  "
        aAdd(aAlimonyValues, {aBenefits[nI][1], aBenefits[nI][2], aBasesAlimony[nI][3] * aBenefits[nI][3]})

        // Calculate total alimony sum.
        nAlimonyValues += aAlimonyValues[nI][3]

        // Rewrite alimony sum into mnemonic aPd.
        If nAlimonyIndex > 0
            aPd[nAlimonyIndex][SUM_PAYMENT_INDEX] := nAlimonyValues
        Else
            If cScenario == SALARY_SCENARIO_NAME .Or. cScenario == TERMINATION_SCENARIO_NAME
                FGeraVerba(aBenefits[nI][5], nAlimonyValues, DIASTRAB)
            ElseIf cScenario == ADVANCE_SCENARIO_NAME
                FGeraVerba(aBenefits[nI][4], nAlimonyValues, DIASTRAB)
            ElseIf cScenario == VACATION_SCENARIO_NAME
                FGeraVerba(aBenefits[nI][6], nAlimonyValues, DIASTRAB)
            EndIf
        EndIf

        // Storno procedure.
        If nAlimonyIndex > 0
            aPd[nAlimonyIndex][SUM_PAYMENT_INDEX] -= nADIAlimonySum

            If aPd[nAlimonyIndex][SUM_PAYMENT_INDEX] < 0
                aPd[nAlimonyIndex][SUM_PAYMENT_INDEX] := 0
            EndIf
        EndIf
    Next nI

    RestArea(aArea)

    // Recalculation total amount sum.
    // If total amount sum less null then set payment "395".
    nTotalAmount := RU07XFUN38_CalculateTotalAmount()
    nTotalIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == cTotalPayment})

    If nTotalAmount < 0
        nDebtAmount := nTotalAmount * (-1)
        nTotalAmount := 0
    EndIf

    If nIndexDebtPayment > 0 .And. nDebtAmount >= 0
        aPd[nIndexDebtPayment][SUM_PAYMENT_INDEX] := nDebtAmount
    ElseIf nIndexDebtPayment == 0 .And. nDebtAmount >= 0
        FGeraVerba(cCodeDebtCurrentMonth, nDebtAmount)
    EndIf

    If nTotalIndex > 0 .And. nTotalAmount >= 0
        aPd[nTotalIndex][SUM_PAYMENT_INDEX] := nTotalAmount
    ElseIf nTotalIndex == 0 .And. nTotalAmount >= 0
        FGeraVerba(cTotalPayment, nTotalAmount)
    EndIf

Return nADIAlimonySum

/*/{Protheus.doc} RU07XFUN37_BaseAlimony(lWriteBase)
    Calculation a alimony base sum and write this to aPd.

    Jira-tasks: 
        * RULOC-5454
        * RULOC-5482 Added logic for Netto conditions.

    @type Function
    @params lWriteBase, Logical, If true then payment code will be wrote into APD mnemonic.
    @return aBaseAlimony, Array, Alimony bases sum for every beneficiar.
    @author vselyakov
    @since 08.09.2023
    @version 12.1.33
    @example RU07XFUN37_BaseAlimony()
*/
Function RU07XFUN37_BaseAlimony(lWriteBase)
    Local aArea := GetArea() As Array
    Local aSRVArea := SRV->(GetArea()) As Array
    Local nBaseAlimony := 0 As Numeric
    Local cCodBaseAlimony := "730" As Character // Becasuse this payment without ID.
    Local nIndexBaseAlimony := 0 As Numeric
    Local oStatement := FWPreparedStatement():New() As Object
    Local cQuery := "" As Character
    Local cAlias := "" As Character
    Local aPayments := {} As Array
    Local nBenefIndex := 0 As Numeric // Index of beneficiary.
    Local nI := 0 As Numeric
    Local aBaseAlimony := {} As Array
    Local nTaxIndex := 0 As Numeric
    Local nTaxValue := 0 As Numeric
    Local cTaxCode := "" As Character
    Local nADITaxSum := 0 As Numeric

    Default lWriteBase := .F. // Do not write alimony base into aPd mnemonic.

    // For FOL scenario get from SRD values of 412 payments.
    If cRot == SALARY_SCENARIO_NAME
        cQuery := " SELECT                    "
        cQuery += "     RD_VALOR              "
        cQuery += " FROM " + RetSqlName("SRD") 
        cQuery += " WHERE                     "
        cQuery += "         RD_FILIAL = ?     "
        cQuery += "     AND RD_MAT = ?        "
        cQuery += "     AND RD_PD = ?         "
        cQuery += "     AND RD_PERIODO = ?    "
        cQuery += "     AND RD_ROTEIR = ?     "
        cQuery += "     AND D_E_L_E_T_ = ' '  "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, FWxFilial("SRD"))
        oStatement:SetString(2, SRA->RA_MAT)
        oStatement:SetString(3, aCodFol[0009][1]) // Payment "412" from SRV.
        oStatement:SetString(4, cPeriodo)
        oStatement:SetString(5, ADVANCE_SCENARIO_NAME)

        cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

        DbSelectArea(cAlias)
        (cAlias)->(DbGoTop())

        While !((cAlias)->(Eof()))
            nADITaxSum += (cAlias)->(RD_VALOR)

            (cAlias)->(DBSkip())
        EndDo
    EndIf

    // Define salary and tax codes payment and code of alimony base
    If cRot == SALARY_SCENARIO_NAME
        cTaxCode := aCodFol[0066][1] // Payment "413" from SRV.
        cCodBaseAlimony := "674"
    ElseIf cRot == ADVANCE_SCENARIO_NAME
        cTaxCode := aCodFol[0009][1] // Payment "412" from SRV.
        cCodBaseAlimony := "730"
    ElseIf cRot == VACATION_SCENARIO_NAME
        cTaxCode := aCodFol[0067][1] // Payment "414" from SRV.
        cCodBaseAlimony := "732"
    ElseIf cRot == TERMINATION_SCENARIO_NAME
        cTaxCode := aCodFol[0066][1] // Payment "413" from SRV.
        cCodBaseAlimony := "738"
    EndIf

    // nSalaryIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == cSalaryCode})
    nTaxIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == cTaxCode})

    If nTaxIndex > 0
        nTaxValue := aPd[nTaxIndex][SUM_PAYMENT_INDEX]
    EndIf

    // Get all payments for every beneficiary.RQ_CALSLIQ
    cQuery := " SELECT                    "
    cQuery += "     RQ_ORDEM              "
    cQuery += "    ,RQ_SEQUENC            "
    cQuery += "    ,RQ_VERBAS             "
    cQuery += "    ,RQ_CALSLIQ            "
    cQuery += " FROM " + RetSqlName("SRQ") 
    cQuery += " WHERE                     "
    cQuery += "         RQ_FILIAL = ?     "
    cQuery += "     AND RQ_MAT = ?        "
    cQuery += "     AND D_E_L_E_T_ = ' '  "
    cQuery += " ORDER BY RQ_SEQUENC       "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRQ"))
    oStatement:SetString(2, SRA->RA_MAT)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While !((cAlias)->(Eof()))
        nBenefIndex := aScan(aPayments, {|x| x[2] == (cAlias)->(RQ_ORDEM)}) // Search index for selected beneficiary.

        If nBenefIndex > 0
            aPayments[nBenefIndex][3] += StrTran(AllTrim((cAlias)->(RQ_VERBAS)), ",", "*")
        Else
            aAdd(aPayments, {SRA->RA_MAT, (cAlias)->(RQ_ORDEM), StrTran(AllTrim((cAlias)->(RQ_VERBAS)), ",", "*"), (cAlias)->(RQ_CALSLIQ)})
            aAdd(aBaseAlimony, {SRA->RA_MAT, (cAlias)->(RQ_ORDEM), 0})
        EndIf

        (cAlias)->(DBSkip())
    EndDo

    // Removed last symbol "*" from every lines into array.
    aEval(aPayments, {|x| x[3] := SubStr(x[3], 1, Len(x[3])-1)})

    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    FWFreeObj(oStatement)

    // Calculation a base of alimony total. Simple version. Using at moment 14.09.2023. For the one beneficiar.
    //aEval(aPd, { |x| nBaseAlimony += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES .And. x[COD_PAYMENT_INDEX] $ aPayments[1][3], x[SUM_PAYMENT_INDEX], 0) })
    If Len(aPayments) > 0
        If cRot == SALARY_SCENARIO_NAME .Or. cRot == TERMINATION_SCENARIO_NAME
            aEval(aPd, { |x| nBaseAlimony += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_NO ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_NO ;
                                                .And. x[COD_PAYMENT_INDEX] $ aPayments[1][3], ;
                                                x[SUM_PAYMENT_INDEX], 0) })
        ElseIf cRot == ADVANCE_SCENARIO_NAME
            aEval(aPd, { |x| nBaseAlimony += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_NO ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_YES ;
                                                .And. x[COD_PAYMENT_INDEX] $ aPayments[1][3], ;
                                                x[SUM_PAYMENT_INDEX], 0) })
        ElseIf cRot == VACATION_SCENARIO_NAME
            aEval(aPd, { |x| nBaseAlimony += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_YES ;
                                                .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_NO ;
                                                .And. x[COD_PAYMENT_INDEX] $ aPayments[1][3], ;
                                                x[SUM_PAYMENT_INDEX], 0) })
        EndIf
    

        // Consider "Netto" conditions.
        If !Empty(nBaseAlimony) .And. aPayments[1][4] == "S"
            nBaseAlimony -= Round(nTaxValue, 0)

            If cRot == SALARY_SCENARIO_NAME
                nBaseAlimony -= nADITaxSum
            EndIf
        EndIf

        If nBaseAlimony < 0
            nBaseAlimony := 0
        EndIf
    EndIf

    // PREPARATION FOR THE FUTURE. Calculation a base of alimony for every beneficiary. True version. For several beneficiars.
    For nI := 1 To Len(aPayments)
        If cRot == SALARY_SCENARIO_NAME .Or. cRot == TERMINATION_SCENARIO_NAME
            aEval(aPd, { |x| aBaseAlimony[nI][3] += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_NO ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_NO ;
                                                        .And. x[COD_PAYMENT_INDEX] $ aPayments[nI][3], ;
                                                            x[SUM_PAYMENT_INDEX], ;
                                                            0) })
        ElseIf cRot == ADVANCE_SCENARIO_NAME
            aEval(aPd, { |x| aBaseAlimony[nI][3] += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_NO ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_YES ;
                                                        .And. x[COD_PAYMENT_INDEX] $ aPayments[nI][3], ;
                                                            x[SUM_PAYMENT_INDEX], ;
                                                            0) })
        ElseIf cRot == VACATION_SCENARIO_NAME
            aEval(aPd, { |x| aBaseAlimony[nI][3] += Iif(RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_PENSAO") == ALIMONY_YES ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_REFFER") == VACATION_YES ;
                                                        .And. RetValSRV(x[COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_ADIANTA") == ADVANCE_NO ;
                                                        .And. x[COD_PAYMENT_INDEX] $ aPayments[nI][3], ;
                                                            x[SUM_PAYMENT_INDEX], ;
                                                            0) })
        EndIf

        // Consider "Netto" conditions.
        If !Empty(aBaseAlimony[nI][3]) .And. aPayments[nI][4] == "S"
            aBaseAlimony[nI][3] -= Round(nTaxValue, 0)

            If cRot == SALARY_SCENARIO_NAME
                aBaseAlimony[nI][3] -= nADITaxSum
            EndIf
        EndIf

        If aBaseAlimony[nI][3] < 0
            aBaseAlimony[nI][3] := 0
        EndIf
    Next nI

    // Write to APD mnemonic this payment. Simple version. Using at moment 14.09.2023. For the one beneficiar.
    If lWriteBase
        nIndexBaseAlimony := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == cCodBaseAlimony})
        If nIndexBaseAlimony > 0
            aPd[nIndexBaseAlimony][SUM_PAYMENT_INDEX] := nBaseAlimony
        Else
            FGeraVerba(cCodBaseAlimony, nBaseAlimony)
        EndIf
    EndIf

    SRV->(RestArea(aSRVArea))
    RestArea(aArea)

Return aBaseAlimony

/*/{Protheus.doc} RU07XFUN38_CalculateTotalAmount()
    Calculation a total amount from aPd data.

    Jira-tasks: 
        * RULOC-5482 Added logic for Netto conditions.

    @type Function
    @params 
    @return nTotalAmount, Numeric, Total amount.
    @author vselyakov
    @since 18.09.2023
    @version 12.1.33
    @example aPd[nTotalIndex][SUM_PAYMENT_INDEX] := RU07XFUN38_CalculateTotalAmount()
*/
Function RU07XFUN38_CalculateTotalAmount()
    Local nTotalAmount := 0 As Numeric
    Local nI := 0 As Numeric
    Local cRESTotalPayment := aCodFol[0126, 1] As Character // Payment "565".
    Local cException := cRESTotalPayment As Character

    For nI := 1 To Len(aPd)
        If RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == WAGE_TYPE_PAYMENT
            nTotalAmount += aPd[nI][SUM_PAYMENT_INDEX]
        ElseIf RetValSRV(aPd[nI][COD_PAYMENT_INDEX], SRA->RA_FILIAL, "RV_TIPOCOD") == DISCOUNT_TYPE_PAYMENT .And. !(aPd[nI][COD_PAYMENT_INDEX] $ cException)
            nTotalAmount -= aPd[nI][SUM_PAYMENT_INDEX]
        EndIf
    Next nI

Return nTotalAmount

/*/{Protheus.doc} RU07XFUN40_CheckIsCalculation(aRotLike)
    
    This function check callstack. Is it call from calculation of roteir.

    @type Function
    @params aRotLike, Array, Rot Type like.
    @return lRoteir, Logical, Is it call from roteir.
    @author dchizhov
    @since 03.10.2023
    @version 12.1.33
    @example lIsCalc := RU07XFUN40_CheckIsCalculation({"ADI", "FOL"})
*/
Function RU07XFUN40_CheckIsCalculation(aRotLike)

    Local lIsCalc  As Logical
    Local cSryFil  As Character
    Local cNameRot As Character
    Local nI       As Numeric
    Local lCheck   As Logical

    Default aRotLike := {}

    lCheck := .T.
    
    lIsCalc := .F.
    cSryFil := xFilial("SRY", SRA->RA_FILIAL)
    If Type("CROTEIRO") == "C"
        cNameRot := GetFunRot(cSryFil, Iif(Empty(CROTEIRO) .And. Type("CROT") == "C", CROT, CROTEIRO))
        For nI := 1 To Len(aRotLike)
            lCheck := .F.
            If aRotLike[nI] $ cNameRot
                lCheck := .T.
                Exit
            EndIf
        Next nI
        lIsCalc := IsInCallStack(cNameRot)
    EndIf

Return lIsCalc

/*/{Protheus.doc} RU07XFUN39_GetChildsForEmployee(cMatEmpl, cChilds)
    
    This function get list of data for childs by employee.

    @type Function
    @params cMatEmpl, Character, Tab Number.
    @params cChilds,  Character, List childs.
    @return aRes,     Array,     Array of data.
    @author dchizhov
    @since 11.10.2023
    @version 12.1.33
    @example aChilds := RU07XFUN39_GetChildsForEmployee(SRA->RA_MAT, cChilds)
*/
Function RU07XFUN39_GetChildsForEmployee(cMatEmpl, cChilds)

    Local aArea    As Array
    Local aSRBArea As Array
    Local aRes     As Array
    Local dDateP   As Date

    Default cChilds := "ALLCHILDRENS"
    aRes := {}

    aArea := GetArea()
    aSRBArea := SRB->(GetArea())
    cString := ""
    DbSelectArea("SRB")
    SRB->(DbSetOrder(RetOrdem("SRB", "RB_FILIAL+RB_MAT")))
    SRB->(DbGoTop())
    If SRB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !SRB->(EOF()) .And. SRB->RB_FILIAL == SRA->RA_FILIAL .And. SRB->RB_MAT == SRA->RA_MAT
            If SRB->RB_COD $ cChilds .Or. cChilds == "ALLCHILDRENS"
                dDateP := RU07XFUN41_AddMonthsForCareChild(SRB->RB_DTNASC)
                Aadd(aRes, {SRB->RB_COD, SRB->RB_DTNASC, dDateP, SRB->RB_GRAUPAR})
            EndIf
            SRB->(DbSkip())
        EndDo
    EndIf
    SRB->(RestArea(aSRBArea))
    RestArea(aArea)

Return aRes

/*/{Protheus.doc} RU07XFUN41_AddMonthsForCareChild(dBirthDay)
    
    This function calculates the date when the child turns one and a half years old.

    @type Function
    @params dBirthDay, Date, Date of Birthday.
    @return dBigCDate, Date, date when the child turns one and a half years old.
    @author dchizhov
    @since 25.10.2023
    @version 12.1.33
    @example dDateP := RU07XFUN41_AddMonthsForCareChild(SRB->RB_DTNASC)
*/
Function RU07XFUN41_AddMonthsForCareChild(dBirthDay)

    Local nYear     As Numeric
    Local nMonth    As Numeric
    Local nDay      As Numeric
    Local dTemp     As Date
    Local dBigCDate As Date

    nYear := Year(dBirthDay)
    nMonth := Month(dBirthDay)
    nDay := Day(dBirthDay)
    // minus year and minus 6 mounth (minus 18 mounth)
    nYear += 1
    nMonth += 6
    // if number mounth < 1 then need mounth in last year
    If nMonth > 12
        nMonth -= 12
        nYear += 1
    EndIf
    // last day in calculation mounth
    dTemp := Iif(nMonth == 12, SToD(StrZero(nYear, 4, 0) + "1231"), SToD(StrZero(nYear, 4, 0) + StrZero(nMonth + 1, 2, 0) + "01") - 1)
    // if last day < day of birthdate? then in target mount there is no day corresponding to the birthday 
    // (there are fewer days in this month), then we take the last day of the month 
    If Day(dTemp) < nDay
        dBigCDate := dTemp
    Else
        dBigCDate := SToD(StrZero(nYear, 4, 0) + StrZero(nMonth, 2, 0) + StrZero(nDay, 2, 0))
    EndIf

Return dBigCDate

/*/{Protheus.doc} RU07XFUN42_GetS219Table(dDate, nYear)
    
    This function get data from S219 table.

    @type Function
    @params dDate, Date,    Date for get data.
    @params nYear, Numeric, Year for get data.
    @return aReturn, Array, Contem of S219. ({start_date, Finish_date, type_of_abs, count_day})
    @author dchizhov
    @since 26.03.2024
    @version 12.1.23.10
    @example aRCCArea := RU07XFUN42_GetS219Table(, Year(dVFin))
*/
Function RU07XFUN42_GetS219Table(dDate, nYear)

    Local aArea    As Array
    Local aRCCArea As Array
    Local aContem  As Array
    Local aReturn  As Array
    Local nMode    As Numeric
    Local cKey     As Character
    Local cDate    As Character

    Default dDate := CToD("//")
    DeFault nYear := 0

    aArea := GetArea()
    aRCCArea := RCC->(GetArea())
    aReturn := {}
    aContem := {,,,}
    nMode := Iif(Empty(dDate), Iif(nYear > 1900, 2, 3), 1)
    cDate := Iif(nMode == 1, MesAno(dDate), Iif(nMode == 2, cValToChar(nYear), ""))
    DbSelectArea("RCC")
    RCC->(DbSetOrder(RetOrdem("RCC", "RCC_FILIAL+RCC_CODIGO")))
    cKey := xFilial("RCC") + "S219"

    If RCC->(DbSeek(cKey))
        While RCC->RCC_FILIAL + RCC->RCC_CODIGO == cKey
            aContem[1] := SubStr(RCC->RCC_CONTEU, 1, 6)
            aContem[2] := SubStr(RCC->RCC_CONTEU, 7, 6)
            aContem[3] := SubStr(RCC->RCC_CONTEU, 13, 3)
            aContem[4] := Val(SubStr(RCC->RCC_CONTEU, 91, 3))
            If nMode == 1 .And. cDate >= aContem[1] .And. cDate <= aContem[2] .Or. ;
            nMode == 2 .And. cDate >= SubStr(aContem[1], 1, 4) .And. cDate <= SubStr(aContem[2], 1, 4) .Or. nMode == 3
                Aadd(aReturn, {aContem[1], aContem[2], aContem[3], aContem[4]})
            EndIf
            RCC->(DbSkip())
        EndDo
    EndIf

    RCC->(RestArea(aRCCArea))
    RestArea(aArea)

Return aReturn

/*/{Protheus.doc} RU07XFUN43_GetAbsShrinkKNOExper(dDateStart, dDateFin, cMat, cFil, aAbsType)
    
    This function get data about absence that shrink KNO Experience in period.

    @type Function
    @params dDateStart, Date, Start date.
    @params dDateFin,   Date, Finish date.
    @params cMat,  Character, Tab num of employee.
    @params cFil,  Character, Filial of employee.
    @params aAbsType,  Array, Type of absence that shrink exp.
    @return aReturn, Array, Contem of absence
    @author dchizhov
    @since 28.03.2024
    @version 12.1.23.10
    @example aAbsArray := RU07XFUN43_GetAbsShrinkKNOExper(dDat1Calc, dDat2Calc, , , aTypeAbs)
*/
Function RU07XFUN43_GetAbsShrinkKNOExper(dDateStart, dDateFin, cMat, cFil, aAbsType)

    Local aArea    As Array
    Local aSR8Area As Array
    Local aReturn  As Array

    Default cMat := SRA->RA_MAT
    DeFault cFil := SRA->RA_FILIAL
    DeFault aAbsType := {}

    aArea := GetArea()
    aSR8Area := SR8->(GetArea())
    aReturn := {}

    DbSelectArea("SR8")
    SR8->(DbSetOrder(RetOrdem("SR8", "R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)")))

    If Len(aAbsType) > 0 .And. SR8->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !SR8->(EOF()) .And. SR8->R8_FILIAL + SR8->R8_MAT == SRA->RA_FILIAL + SRA->RA_MAT
            If AScan(aAbsType, {|X| X[3] == SR8->R8_TIPOAFA}) > 0 .And. (SR8->R8_DATAINI >= dDateStart .And. SR8->R8_DATAINI <= dDateFin .Or. ;
            SR8->R8_DATAFIM >= dDateStart .And. SR8->R8_DATAFIM <= dDateFin .Or. ;
            SR8->R8_DATAINI <= dDateStart .And. SR8->R8_DATAFIM >= dDateStart)
                Aadd(aReturn, {SR8->R8_DATAINI, SR8->R8_DATAFIM, SR8->R8_TIPOAFA})
            EndIf
            SR8->(DbSkip())
        EndDo
    EndIf

    ASort(aReturn, , , {|X, Y| X[1] < Y[1]})

    RestArea(aArea)
    SR8->(RestArea(aSR8Area))

Return aReturn

/*/{Protheus.doc} RU07XFUN44_SetDescrRCM(cRCMCode, cDescr)
    
    This function get description of type of absence.

    @type Function
    @params cRCMCode, Character, Code of type absence.
    @params cDescr,   Character, Description of type of absence.
    @return .T.
    @author dchizhov
    @since 02.04.2024
    @version 12.1.23.10
    @example RU07XFUN44(&(READVAR()), "RUSS21904")
*/
Function RU07XFUN44_SetDescrRCM(cRCMCode, cDescr)

    Local nPosic As Numeric
    Local aArea  As Array
    Local cDesc  As Character

    aArea := GetArea()
    nPosic := GdFieldPos(cDescr)
    If nPosic > 0
        cDesc  := FDesc("RCM", cRCMCode, "RCM_DESCRI", , xFilial("RCM"), 1)
        aCols[n][nPosic] := cDesc 
    EndIf
    RestArea(aArea)

Return .T.

/*/{Protheus.doc} RU07XFUN45_CalcKNO(dDateDiss)
    
    This function calculation KNO.

    @type Function
    @params dDateDiss, Date, Date of dissmissal.
    @return .T.
    @author dchizhov
    @since 02.04.2024
    @version 12.1.23.10
    @example oModel:LoadValue("GPEM040_MSRG","RG_DFERPRO", RU07XFUN45_CalcKNO(dDataDem1))
*/
Function RU07XFUN45_CalcKNO(dDateDiss)

    Local nReturn  As Numeric
    Local nPerId   As Numeric
    Local nMCount  As Numeric
    Local nDCount  As Numeric
    Local aArea    As Array
    Local aSRFArea As Array
    Local cKey     As Character
    Local cPd      As Character
    Local nPaidDay As Numeric

    aArea := GetArea()
    aSRFArea := SRF->(GetArea())
    nReturn := 0
    cKey := SRA->RA_FILIAL + SRA->RA_MAT
    cPd := fGetCodFol("0072")
    nPaidDay := 0
    DbSelectArea("SRF")
    SRF->(DbSetOrder(RetOrdem("SRF", "RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)")))
    
    If SRF->(DbSeek(cKey))
        While !SRF->(EOF()) .And. SRF->(RF_FILIAL+RF_MAT) == cKey
            If SRF->RF_PD == cPd .And. SRF->RF_DATABAS <= dDateDiss 
                If SRF->RF_DATAFIM >= dDateDiss
                    nPerId := SRF->(RecNo())
                EndIf
                nPaidDay += SRF->RF_DFERANT
            EndIf
            SRF->(DbSkip())
        EndDo
    EndIf

    If nPerId > 0
        SRF->(DbGoTo(nPerId))
        nDCount := RU07XVAC14GetDFALAATVacLast(dDateDiss, Max(SRA->RA_ADMISSA, SRF->RF_DATABAS))
        If YearSum(SRA->RA_ADMISSA, 1) >= dDateDiss .And. (nDCount - SRF->RF_DFERANT) / AVERAGE_COUNT_DAY_IN_MOUNTH > 11
            nMCount := 12 // full year
            nDCount := 0
        Else
            nMCount := Int(nDCount / AVERAGE_COUNT_DAY_IN_MOUNTH)
            nDCount -= Int(nMCount * AVERAGE_COUNT_DAY_IN_MOUNTH)
            If nDCount >= 15 // 15 - half of mounth
                nMCount += 1
            EndIf
        EndIf
        nReturn := nMCount * Round(SRF->RF_DIASDIR / 12, 2) // 12 - count mounth in year
        nReturn -= nPaidDay // SRF->RF_DFERANT

    EndIf

    RestArea(aArea)
    SRF->(RestArea(aSRFArea))

Return nReturn
/*{Protheus.doc} RU07XFUN46_GetR8Dpagar
    Return days of absence (R8_DPAGAR).

    @type Function
    @param nRecnoNumber, Numeric, Recno of absence (SR8 line)
    @return Numeric, Days of absence (R8_DPAGAR)
    @author vselyakov
    @since 27.02.2024
    @version 12.1.33
*/
Function RU07XFUN46_GetR8Dpagar(nRecnoNumber)
    Local aArea := GetArea() As Array
    Local aSR8Area := SR8->(GetArea()) As Array
    Local nDaysResult := 0 As Numeric

    If nRecnoNumber > 0
        DbSelectArea("SR8")
        SR8->(DbGoTo(nRecnoNumber))
        nDaysResult := SR8->R8_DPAGAR
    EndIf

    SR8->(RestArea(aSR8Area))
    RestArea(aArea)
Return nDaysResult


/*/{Protheus.doc} fRUNADCBase()
    Calculates NA and DC base: sum of all taxable payments within current period (SRV #83P)

    @type Function
    @params
    @return nNDFLBase, Numeric, Sum of all taxable payments 
    @author alysenko
    @since 2024/04/25
    @version 12.1.23
*/
Function fRuNADCBase(nTypeBase)
    Local nI := 0               As Numeric
    Local cSRVCode := ""        AS Char
    Local nNADCBase := 0        As Numeric
    Local nSRVIndex := 0        AS Numeric
    Local lWrNADCBase := .F.    AS Logical

    For nI := 1 To Len(aPd) // aPd - mnemonic array with all payments within current period
        cSRVCode := aPd[nI][1]
        If FIncide(cSRVCode) // FIncide(cSRVCode) - find or add SRV item to aPdv array. "False" means invalid code
            nSRVIndex := AScan(aPdv, { |x| x[1] = cSRVCode }) // aPdv - mnemonic array with wage types (SRV items)
            If nSRVIndex > 0 .And. aPdv[nSRVIndex][IS_NORTHALLOW] == NORTHALLOW_YES .AND. nTypeBase == 1
                If aPdv[nSRVIndex][27] == WAGE_TYPE_PAYMENT
                    nNADCBase += aPd[nI][SUM_PAYMENT_INDEX]
                    lWrNADCBase := .T.
                EndIf
            ElseIf nSRVIndex > 0 .And. aPdv[nSRVIndex][IS_DISTRCOEFF] == DISTRCOEFF_YES .AND. nTypeBase == 2
                If aPdv[nSRVIndex][27] == WAGE_TYPE_PAYMENT
                    nNADCBase += aPd[nI][SUM_PAYMENT_INDEX]
                    lWrNADCBase := .T.
                EndIf
            EndIf
        EndIf
    Next nI

    If lWrNADCBase
        If nTypeBase == 1
            nSRVIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == BASE_NORTHALLOW})
            If nSRVIndex > 0
                aPd[nSRVIndex][SUM_PAYMENT_INDEX] := nNADCBase
            Else
                FGeraVerba(BASE_NORTHALLOW, nNADCBase)
            EndIf
        ElseIf nTypeBase == 2
            nSRVIndex := aScan(aPd, {|x| x[COD_PAYMENT_INDEX] == BASE_DISTRCOEFF})
            If nSRVIndex > 0
                aPd[nSRVIndex][SUM_PAYMENT_INDEX] := nNADCBase
            Else
                FGeraVerba(BASE_DISTRCOEFF, nNADCBase)
            EndIf
        EndIf
        
    EndIf

Return nNADCBase
