#INCLUDE "PROTHEUS.CH"

#DEFINE PARAM_YEAR_INDEX 4

#DEFINE FIRED_EMPLOYEE_STATUS "D"
#DEFINE HOURLY_EMPLOYEE_CATEGORY "H"
#DEFINE MONTH_EMPLOYEE_CATEGORY "M"
#DEFINE CIVIL_LAW_EMPLOYEE_CATEGORY "A" // GPH.

#DEFINE CYRILLIC_P CHR(208)
#DEFINE OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#DEFINE OPS_BASE_OVER_LIMIT "80" + CYRILLIC_P
#DEFINE OPS_BASE_INSURANCE_PREMIUM "700"

#DEFINE OMS_CONTRIBUTIONS_PAYMENT "840"

#DEFINE INCOME_TYPE_OF_PAYMENT "1" // SRV.RV_TIPOCOD = '1'.
#DEFINE OPS_TIPOCOD_NON_CONTRIBUTION_INCOME "1"
#DEFINE CURRENT_MONTH_DEBT "395"
#DEFINE PREVIOUS_MONTH_DEBT "446"

#DEFINE SCENARIO_NAME_SALARY "FOL" // SRD.RD_ROTEIR = 'FOL'
#DEFINE SALARY_PROCESS "00001"


/*/
{Protheus.doc} RUIPRPart1Subsection2
    Class for generating a report Insurance premium report, Part 1, Subsection 2.

    @type Class
    @author vselyakov
    @since 10.12.2021
    @version 12.1.33
/*/
Class RUIPRPart1Subsection2 From LongNameClass
    Data cFilter As Character // Data from filter.
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters As Array // Array of parameters from pergunte.
    Data aPeriods    As Array
    Data aLastMonth  As Array

    // Data for report.
    Data cPayerRateCode              As Character // Line 001.
    Data aEmployeeCount              As Array // Line 010. {Total amount, First month, Second month, Third month}.
    Data aIndividualsCount           As Array // Line 020. {Total amount, First month, Second month, Third month}.
    Data aAmountArticle420           As Array // Line 030. Amount under article 420.
    Data a422ArticleAmouts           As Array // Line 040. Amount under article 422. {Total amount, First month, Second month, Third month}.
    Data a421ArticleAmouts           As Array // Line 045. Amount under article 421. {Total amount, First month, Second month, Third month}.
    Data aBaseAmoutsInsurancePremium As Array // Line 050. The base for calculating insurance premiums.
    Data aInsuracePremiumCalculated  As Array // Line 060. Insurance premiums calculated.

    // Methods.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor

    Method MakeData()

    Method IPRP1S2010_InsuredPersonsNumber() // Line 010.
    Method IPRP1S2020_NumberIndividualsWhosePaymentsPremiumsCalculated() // Line 020.
    Method IPRP1S2030_PaymentsUnderArticle420() // Line 030.
    Method IPRP1S2040_PaymentsNotUnderArticle422() // Line 040.
    Method IPRP1S2045_PaymentsUnderArticle421() // Line 045.
    Method IPRP1S2050_CalculatingBaseInsurancePremiums() // Line 050.
    Method IPRP1S2060_InsuracePremiumCalculated() // Line 060.

    Method AmountSqlQueryExecute(aPaymentTypes, nTotal)
    Method ArticleSqlQueryExecute(lIsFGTS, nTotal)
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RUIPRPart1Subsection2 constructor.

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aPeriods,    Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,  Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 10.12.2021
    @version 12.1.33
    @return RUIPRPart1Subsection2, Object, RUIPRPart1Subsection2 instance.
    @example ::oPart1Subsection2 := RUIPRPart1Subsection2():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth)
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Class RUIPRPart1Subsection2

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    ::aPeriods := AClone(aPeriods)
    ::aLastMonth := AClone(aLastMonth)

    ::aEmployeeCount := {}
    ::aIndividualsCount := {}
    ::aAmountArticle420 := {}
    ::a422ArticleAmouts := {}
    ::a421ArticleAmouts := {}
    ::aBaseAmoutsInsurancePremium := {}
    ::aInsuracePremiumCalculated := {}

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the report.

    @type Method
    @params 
    @author vselyakov
    @since 10.12.2021
    @version 12.1.33
    @return 
    @example ::oPart1Subsection2:MakeData()
/*/
Method MakeData() Class RUIPRPart1Subsection2

    ::cPayerRateCode := PadL(AllTrim(::aParameters[3]), 2, "0")

    ::IPRP1S2010_InsuredPersonsNumber()
    ::IPRP1S2020_NumberIndividualsWhosePaymentsPremiumsCalculated()    
    ::IPRP1S2030_PaymentsUnderArticle420()
    ::IPRP1S2040_PaymentsNotUnderArticle422()
    ::IPRP1S2045_PaymentsUnderArticle421()
    ::IPRP1S2050_CalculatingBaseInsurancePremiums()
    ::IPRP1S2060_InsuracePremiumCalculated()

Return

/*/
{Protheus.doc} IPRP1S1010_InsuredPersonsNumber()
    The method calculate number of insured persons.
    This line 010 into report.

    @type Method
    @params 
    @author vselyakov
    @since 07.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S1010_InsuredPersonsNumber()
/*/
Method IPRP1S2010_InsuredPersonsNumber() Class RUIPRPart1Subsection2
    Local oStatement          As Object
    Local cQuery              As Character 
    Local aArea               As Array
    Local cTab                As Character
    Local nI                  As Numeric
    Local aLastEmployeeCount  As Numeric
    Local nTotalEmployeeCount As Numeric
    Local cCurrentPeriod      As Character
    Local cSemana             As Character
    Local cYearMonth          As Character

    aArea := GetArea()
    aLastEmployeeCount := {}
    nTotalEmployeeCount := 0

    // Get current open period (GPEA400).
    fGetLastPer(@cCurrentPeriod, @cSemana, SALARY_PROCESS, SCENARIO_NAME_SALARY, .T., .F., @cYearMonth)

    // Initialization of last 3 month of report period.
    For nI := 1 To Len(::aLastMonth)
        aAdd(aLastEmployeeCount, {::aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT RA_MAT, RA_ADMISSA, RA_DEMISSA FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_CATFUNC IN (?) "
    cQuery += " AND (LEFT(RA_ADMISSA, 6) <= ? AND (RA_DEMISSA = '        ' OR LEFT(RA_DEMISSA, 4) >= ? )) "
    cQuery += " AND RA_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRA"))
    oStatement:SetIn(2, {HOURLY_EMPLOYEE_CATEGORY, MONTH_EMPLOYEE_CATEGORY, CIVIL_LAW_EMPLOYEE_CATEGORY})
    oStatement:SetString(3, Self:aPeriods[Len(Self:aPeriods)])
    oStatement:SetString(4, Self:aParameters[PARAM_YEAR_INDEX])
    oStatement:SetIn(5, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    // Add emplyee count by periods and calculate total employees.
    While !((cTab)->(Eof()))
        nTotalEmployeeCount += 1

        For nI := 1 To Len(aLastEmployeeCount)

            If AnoMes(SToD((cTab)->(RA_ADMISSA))) <= Self:aLastMonth[nI] ;
               .And. Iif( Empty((cTab)->(RA_DEMISSA)), .T., AnoMes(SToD((cTab)->(RA_DEMISSA))) >= Self:aLastMonth[nI] ) ;
               .And. aLastEmployeeCount[nI][1] <> cCurrentPeriod

                aLastEmployeeCount[nI][2] += 1
            EndIf

        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    
    aAdd(::aEmployeeCount, nTotalEmployeeCount)
    aAdd(::aEmployeeCount, aLastEmployeeCount[1][2])
    aAdd(::aEmployeeCount, aLastEmployeeCount[2][2])
    aAdd(::aEmployeeCount, aLastEmployeeCount[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated()
    The method calculate The number of individuals from whose payments the insurance premiums have been calculated.
    This line 020 into report.

    @type Method
    @params 
    @author vselyakov
    @since 10.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated()
/*/
Method IPRP1S2020_NumberIndividualsWhosePaymentsPremiumsCalculated() Class RUIPRPart1Subsection2
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric
    Local nTotalResult As Numeric

    aArea := GetArea()
    aDetails := {}
    nSumCount := 0
    nTotalResult := 0

    // We determine the number of employees for the entire period.
    cQuery := " SELECT RD_MAT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_MAT "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {OMS_CONTRIBUTIONS_PAYMENT})
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        nTotalResult += 1

        DbSkip()
    EndDo

    // We determine the number of employees for the last 3 months.
    For nI := 1 To Len(::aLastMonth)
        nSumCount := 0
        
        cQuery := " SELECT RD_MAT FROM " + RetSqlName("SRD") + " WHERE "
        cQuery += " RD_FILIAL = ? "
        cQuery += " AND RD_PERIODO IN (?) "
        cQuery += " AND RD_PD = ? "
        cQuery += " AND RD_MAT IN (?) "
        cQuery += " AND D_E_L_E_T_ = ' ' "
        cQuery += " GROUP BY RD_MAT "
        
        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, FWxFilial("SRD"))
        oStatement:SetString(2, ::aLastMonth[nI])
        oStatement:SetIn(3, {OMS_CONTRIBUTIONS_PAYMENT})
        oStatement:SetIn(4, ::aFilter)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())
        DBSelectArea(cTab)
        (cTab)->(DbGoTop())

        While !(cTab)->(Eof())
            nSumCount += 1

            DbSkip()
        EndDo
        
        aAdd(aDetails, {::aLastMonth[nI], nSumCount})
    Next nI

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    aAdd(::aIndividualsCount, nTotalResult)
    aAdd(::aIndividualsCount, aDetails[1][2])
    aAdd(::aIndividualsCount, aDetails[2][2])
    aAdd(::aIndividualsCount, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S2030_PaymentsUnderArticle420()
    The method calculate The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation.
    This line 030 into report.

    @type Method
    @params 
    @author vselyakov
    @since 13.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S2030_PaymentsUnderArticle420()
/*/
Method IPRP1S2030_PaymentsUnderArticle420() Class RUIPRPart1Subsection2
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric

    aArea := GetArea()
    aDetails := {}
    nSumCount := 0

    // Initialization array aDetails by TOTAL and last 3 month.
    aDetails := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}}

    // Create SQL-query text.
    cQuery := " SELECT SRD.RD_PERIODO, SUM(SRD.RD_VALOR) AS SUMMARY "
    cQuery += " FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON "
    cQuery += "     SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += "     SRD.RD_FILIAL = ? "
    cQuery += "     AND SRD.RD_PERIODO IN (?) "
    cQuery += "     AND SRD.RD_MAT IN (?) "
    cQuery += "     AND SRD.RD_ROTEIR = ? "
    cQuery += "     AND NOT (SRV.RV_COD IN (?)) "
    cQuery += "     AND SRV.RV_TIPOCOD = ? "
    cQuery += "     AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += "     AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    // Create object with SQL-query.
    oStatement := FWPreparedStatement():New(cQuery)

    // Set variables into SQL-query object.
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, Self:aFilter)
    oStatement:SetString(4, SCENARIO_NAME_SALARY) // Only FOL scenario.
    oStatement:SetIn(5, {CURRENT_MONTH_DEBT, PREVIOUS_MONTH_DEBT}) // "395", "446".
    oStatement:SetString(6, OPS_TIPOCOD_NON_CONTRIBUTION_INCOME) // SRV.RV_TIPOCOD = '1'.

    // Execute ready SQL-query.
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        nSumCount += (cTab)->SUMMARY // Calculate summary summ.
        nI := aScan(aDetails, {|x| x[1] == (cTab)->RD_PERIODO}) // Find position for period.

        If (nI > 0)
            aDetails[nI][2] := (cTab)->SUMMARY // Write summ by period position.
        EndIf
        
        (cTab)->(DbSkip())
    EndDo

    aAdd(::aAmountArticle420, nSumCount)
    aAdd(::aAmountArticle420, aDetails[1][2])
    aAdd(::aAmountArticle420, aDetails[2][2])
    aAdd(::aAmountArticle420, aDetails[3][2])

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S2040_PaymentsNotUnderArticle422()
    The method calculate Amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties.
    This line 040 into report.

    @type Method
    @params 
    @author vselyakov
    @since 13.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S2040_PaymentsNotUnderArticle422()
/*/
Method IPRP1S2040_PaymentsNotUnderArticle422() Class RUIPRPart1Subsection2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::ArticleSqlQueryExecute(.F., @nSumCount)

    // Write result.
    aAdd(::a422ArticleAmouts, nSumCount)
    aAdd(::a422ArticleAmouts, aDetails[1][2])
    aAdd(::a422ArticleAmouts, aDetails[2][2])
    aAdd(::a422ArticleAmouts, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP1S2045_PaymentsUnderArticle421()
    The method calculate The amount of expenses accepted for deduction in accordance with paragraph 8 of Article 421 of the Tax Code of the Russian Federation.
    This line 045 into report.
    We do not fill this part.

    @type Method
    @params 
    @author vselyakov
    @since 13.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S2045_PaymentsUnderArticle421()
/*/
Method IPRP1S2045_PaymentsUnderArticle421() Class RUIPRPart1Subsection2

    // Write result.
    aAdd(::a421ArticleAmouts, 0)
    aAdd(::a421ArticleAmouts, 0)
    aAdd(::a421ArticleAmouts, 0)
    aAdd(::a421ArticleAmouts, 0)

Return

/*/
{Protheus.doc} IPRP1S2050_CalculatingBaseInsurancePremiums()
    The method calculate The base for calculating insurance premiums.
    This line 050 into report.

    @type Method
    @params 
    @author vselyakov
    @since 13.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S2050_CalculatingBaseInsurancePremiums()
/*/
Method IPRP1S2050_CalculatingBaseInsurancePremiums() Class RUIPRPart1Subsection2
    Local aDetails   As Array
    Local nSumCount  As Numeric

    // Execute sql query for this line of report.
    aDetails := ::AmountSqlQueryExecute({OPS_BASE_INSURANCE_PREMIUM}, @nSumCount)

    // Write result.
    aAdd(::aBaseAmoutsInsurancePremium, nSumCount)
    aAdd(::aBaseAmoutsInsurancePremium, aDetails[1][2])
    aAdd(::aBaseAmoutsInsurancePremium, aDetails[2][2])
    aAdd(::aBaseAmoutsInsurancePremium, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP1S2060_InsuracePremiumCalculated()
    The method calculate Insurance premiums calculated.
    This line 060 into report.

    @type Method
    @params 
    @author vselyakov
    @since 13.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S2060_InsuracePremiumCalculated()
/*/
Method IPRP1S2060_InsuracePremiumCalculated() Class RUIPRPart1Subsection2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::AmountSqlQueryExecute({OMS_CONTRIBUTIONS_PAYMENT}, @nSumCount)

    // Write result.
    aAdd(::aInsuracePremiumCalculated, nSumCount)
    aAdd(::aInsuracePremiumCalculated, aDetails[1][2])
    aAdd(::aInsuracePremiumCalculated, aDetails[2][2])
    aAdd(::aInsuracePremiumCalculated, aDetails[3][2])
Return

/*/
{Protheus.doc} AmountSqlQueryExecute(aPaymentTypes, nTotal)
    Executes an SQL query to display the amounts for the specified wage type by period.

    @type Method
    @params aPaymentTypes, Array, Array of payments for Sql query.
            nTotal, Numeric, Variable for recording the total amount for the period.
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return aDetails, Array, Array of amount for last three month of selected period.
    @example aDetails := ::AmountSqlQueryExecute({OPS_BASE_OVER_LIMIT}, @nSumCount)
/*/
Method AmountSqlQueryExecute(aPaymentTypes, nTotal) Class RUIPRPart1Subsection2
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric

    aArea := GetArea()
    aDetails := {}
    nSumCount := 0

    For nI := 1 To Len(::aLastMonth)
        aAdd(aDetails, {::aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        nSumCount += (cTab)->SUMMARY

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

    nTotal := nSumCount

Return aDetails

/*/
{Protheus.doc} ArticleSqlQueryExecute(lIsFGTS, nTotal)
    Executes an SQL query to display the amounts taking into account RV_FGTS = "S" or not.

    @type Method
    @params lIsFGTS, Logical, If .T. - RV_FGTS = 'S', .F. - RV_FGTS = 'N'.
            nTotal, Numeric, Variable for recording the total amount for the period.
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return aDetails, Array, Array of amount for last three month of selected period.
    @example aDetails := ::ArticleSqlQueryExecute(.T., @nSumCount) // RV_FGTS = 'S'.
             aDetails := ::ArticleSqlQueryExecute(.F., @nSumCount) // RV_FGTS = 'N'.
/*/
Method ArticleSqlQueryExecute(lIsFGTS, nTotal) Class RUIPRPart1Subsection2
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric

    aArea := GetArea()
    aDetails := {}
    nSumCount := 0

    For nI := 1 To Len(::aLastMonth)
        aAdd(aDetails, {::aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT SRD.RD_PERIODO, SUM(SRD.RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_MAT IN (?) "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' " // Only FOL scenario.
    cQuery += " AND SRV.RV_FGTS = ? " // The type of payment will (will not) be taken into account in the calculation base of PFR insurance premiums.
    cQuery += " AND SRV.RV_TIPOCOD = ? " 
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, ::aFilter)
    oStatement:SetString(4, Iif(lIsFGTS, "S", "N"))
    oStatement:SetString(5, INCOME_TYPE_OF_PAYMENT)    

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        nSumCount += (cTab)->SUMMARY

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

    nTotal := nSumCount

Return aDetails
