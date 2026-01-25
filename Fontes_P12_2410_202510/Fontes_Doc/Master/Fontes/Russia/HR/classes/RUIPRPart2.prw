#INCLUDE "PROTHEUS.CH"

#DEFINE PARAM_YEAR_INDEX 4

#DEFINE FIRED_EMPLOYEE_STATUS "D"
#DEFINE HOURLY_EMPLOYEE_CATEGORY "H"
#DEFINE MONTH_EMPLOYEE_CATEGORY "M"
#DEFINE CIVIL_LAW_EMPLOYEE_CATEGORY "A" // GPH.

#DEFINE CYRILLIC_P CHR(208)
#DEFINE OPS_BASE_OVER_LIMIT "80" + CYRILLIC_P

#DEFINE VNIM_CONTRIBUTION_SALARY "400"
#DEFINE VNIM_CONTRIBUTION_VACATION "401"
#DEFINE VNIM_CONTRIBUTION_VACATION_NEXT_MONTH "405"
#DEFINE BASE_OVER_VNIM_LIMIT "642"
#DEFINE BASE_VNIM_LIMIT "641"
#DEFINE DEBT_CURRENT_MONTH_PAYMENT "395"
#DEFINE DEBT_PREVIOUS_MONTH "446"

#DEFINE PAYMENT_TYPE_INCOME "1"
#DEFINE FSS_PAYMENT_NO "N"
#DEFINE FSS_PAYMENT_YES "S"

#DEFINE SCENARIO_NAME_SALARY "FOL" // SRD.RD_ROTEIR = 'FOL'
#DEFINE SALARY_PROCESS "00001"

/*/
{Protheus.doc} RUIPRPart1Subsection2
    Class for generating a report Insurance premium report, Part 2.

    @type Class
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
/*/
Class RUIPRPart2 From LongNameClass
    Data cFilter As Character // Data from filter.
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters As Array // Array of parameters from pergunte.
    Data aPeriods    As Array
    Data aLastMonth  As Array

    // Data for report.
    Data cPayerRateCode              As Character // Line 001.
    Data cPayoutAttribute            As Character // Line 002.

    Data aEmployeeCount              As Array // Line 010. {Total amount, First month, Second month, Third month}.
    Data aIndividualsCount           As Array // Line 015. {Total amount, First month, Second month, Third month}.
    Data aAmountArticle420           As Array // Line 020. Amount under article 420.
    Data a422ArticleAmouts           As Array // Line 030. Amount under article 422. {Total amount, First month, Second month, Third month}.

    Data aOverBaseAmountInsurancePremium As Array // Line 040.
    Data aBaseAmountInsurancePremium As Array // Line 050.
    Data aAmountAccruedForeign As Array // Line 055.
    Data aInsuracePremiumCalculated  As Array // Line 060.
    Data aInsuranceCoverageCosts As Array // Line 070.
    Data aReimbursedSIFExpenses As Array // Line 080.
    Data aPayableAmountInsuracePremium As Array // Line 090.

    // Methods.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor

    Method MakeData()

    Method IPRP2010_InsuredPersonsNumber() // Line 010.
    Method IPRP2015_NumberIndividualsWhosePaymentsPremiumsCalculated() // Line 015.
    Method IPRP2020_AmountPaymentsByArticle420() // Line 020.
    Method IPRP2030_PaymentsUnderArticle422() // Line 030.
    Method IPRP2040_AmountOverBaseInsurancePremium() // Line 040.
    Method IPRP2050_AmountBaseInsurancePremium() // Line 050.
    Method IPRP2055_AmountAccruedInFavorOfForeignCitizens() // Line 055.
    Method IPRP2060_InsurancePremiumsCalculated() // Line 060.
    Method IPRP2070_CostsIncurredForPaymentInsuranceCoverage() // Line 070.
    Method IPRP2080_ReimbursedSIFExpenses() // Line 080.
    Method IPRP2090_PayableAmountInsuracePremium() // Line 090.

    Method AmountSqlQueryExecute(aPaymentTypes, nTotal)
    Method ArticleSqlQueryExecute(lIsFSS, cPaymentType, nTotal, aExcludePayment)
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RUIPRPart2 constructor.

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aPeriods,    Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,  Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return RUIPRPart2, Object, RUIPRPart2 instance.
    @example ::oPart2 := RUIPRPart2():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Class RUIPRPart2

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    ::aPeriods := AClone(aPeriods)
    ::aLastMonth := AClone(aLastMonth)

    ::aEmployeeCount := {}
    ::aIndividualsCount := {}
    ::aAmountArticle420 := {}
    ::a422ArticleAmouts := {}
    ::aInsuracePremiumCalculated := {}
    ::aOverBaseAmountInsurancePremium := {}
    ::aBaseAmountInsurancePremium := {}
    ::aAmountAccruedForeign := {}
    ::aInsuranceCoverageCosts := {}
    ::aReimbursedSIFExpenses := {}
    ::aPayableAmountInsuracePremium := {}

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the report.

    @type Method
    @params 
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return 
    @example ::oPart2:MakeData()
/*/
Method MakeData() Class RUIPRPart2

    ::cPayerRateCode := PadL(AllTrim(::aParameters[3]), 2, "0")
    ::cPayoutAttribute := "1"

    ::IPRP2010_InsuredPersonsNumber()
    ::IPRP2015_NumberIndividualsWhosePaymentsPremiumsCalculated()
    ::IPRP2020_AmountPaymentsByArticle420()
    ::IPRP2030_PaymentsUnderArticle422()
    ::IPRP2040_AmountOverBaseInsurancePremium()
    ::IPRP2050_AmountBaseInsurancePremium()
    ::IPRP2055_AmountAccruedInFavorOfForeignCitizens()
    ::IPRP2060_InsurancePremiumsCalculated()
    ::IPRP2070_CostsIncurredForPaymentInsuranceCoverage()
    ::IPRP2080_ReimbursedSIFExpenses()
    ::IPRP2090_PayableAmountInsuracePremium()

Return

/*/
{Protheus.doc} IPRP2010_InsuredPersonsNumber()
    The method calculate number of insured persons.
    This line 010 into report.

    @type Method
    @params 
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2010_InsuredPersonsNumber()
/*/
Method IPRP2010_InsuredPersonsNumber() Class RUIPRPart2
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
{Protheus.doc} IPRP2015_NumberIndividualsWhosePaymentsPremiumsCalculated()
    The method calculate The number of individuals from whose payments the insurance premiums have been calculated.
    This line 015 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2015_NumberIndividualsWhosePaymentsPremiumsCalculated()
/*/
Method IPRP2015_NumberIndividualsWhosePaymentsPremiumsCalculated() Class RUIPRPart2
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

    cQuery := " SELECT RD_PERIODO, COUNT(RD_MAT) AS SUMMARY FROM " + RetSqlName("SRD") + " WHERE "
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
    oStatement:SetIn(3, {VNIM_CONTRIBUTION_SALARY})
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    // Add emplyee count by periods and calculate total employees.
    While !Eof()
        nSumCount := Max((cTab)->SUMMARY, nSumCount)

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

    aAdd(::aIndividualsCount, nSumCount)
    aAdd(::aIndividualsCount, aDetails[1][2])
    aAdd(::aIndividualsCount, aDetails[2][2])
    aAdd(::aIndividualsCount, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP2020_AmountPaymentsByArticle420()
    The method calculate the amount of payments and other remuneration accrued 
    in favor of individuals in accordance with Article 420 of the 
    Tax Code of the Russian Federation.
    This line 020 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2020_AmountPaymentsByArticle420()
/*/
Method IPRP2020_AmountPaymentsByArticle420() Class RUIPRPart2
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
    cQuery += " WHERE SRD.RD_FILIAL = ? "
    cQuery += " AND SRV.RV_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_MAT IN (?) "
    cQuery += " AND SRV.RV_TIPOCOD = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRD.RD_PD NOT IN (?) "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetString(2, FWxFilial("SRV"))
    oStatement:SetIn(3, ::aPeriods)
    oStatement:SetIn(4, ::aFilter)
    oStatement:SetString(5, PAYMENT_TYPE_INCOME)
    oStatement:SetIn(6, {DEBT_CURRENT_MONTH_PAYMENT, DEBT_PREVIOUS_MONTH})

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

    aAdd(::aAmountArticle420, nSumCount)
    aAdd(::aAmountArticle420, aDetails[1][2])
    aAdd(::aAmountArticle420, aDetails[2][2])
    aAdd(::aAmountArticle420, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP2030_PaymentsUnderArticle422()
    The method calculate amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties.
    This line 030 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2030_PaymentsUnderArticle422()
/*/
Method IPRP2030_PaymentsUnderArticle422() Class RUIPRPart2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::ArticleSqlQueryExecute(.F., PAYMENT_TYPE_INCOME, @nSumCount, {DEBT_CURRENT_MONTH_PAYMENT, DEBT_PREVIOUS_MONTH})

    aAdd(::a422ArticleAmouts, nSumCount)
    aAdd(::a422ArticleAmouts, aDetails[1][2])
    aAdd(::a422ArticleAmouts, aDetails[2][2])
    aAdd(::a422ArticleAmouts, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP2040_AmountOverBaseInsurancePremium()
    The method calculate amount in excess of the maximum base for calculating insurance premiums.
    This line 040 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2040_AmountOverBaseInsurancePremium()
/*/
Method IPRP2040_AmountOverBaseInsurancePremium() Class RUIPRPart2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::AmountSqlQueryExecute({BASE_OVER_VNIM_LIMIT}, @nSumCount)

    aAdd(::aOverBaseAmountInsurancePremium, nSumCount)
    aAdd(::aOverBaseAmountInsurancePremium, aDetails[1][2])
    aAdd(::aOverBaseAmountInsurancePremium, aDetails[2][2])
    aAdd(::aOverBaseAmountInsurancePremium, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP2050_AmountBaseInsurancePremium()
    The method calculate base for calculating insurance premiums.
    This line 050 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2050_AmountBaseInsurancePremium()
/*/
Method IPRP2050_AmountBaseInsurancePremium() Class RUIPRPart2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::AmountSqlQueryExecute({BASE_VNIM_LIMIT}, @nSumCount)

    aAdd(::aBaseAmountInsurancePremium, nSumCount)
    aAdd(::aBaseAmountInsurancePremium, aDetails[1][2])
    aAdd(::aBaseAmountInsurancePremium, aDetails[2][2])
    aAdd(::aBaseAmountInsurancePremium, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP2055_AmountAccruedInFavorOfForeignCitizens()
    The method calculate the amount of payments and other remuneration accrued in favor 
    of foreign citizens and stateless persons temporarily staying in the 
    Russian Federation, except for persons who are citizens of the 
    member states of the Eurasian Economic Union.
    This line 055 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2055_AmountAccruedInFavorOfForeignCitizens()
/*/
Method IPRP2055_AmountAccruedInFavorOfForeignCitizens() Class RUIPRPart2
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

    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT "
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_MAT IN (?) "
    cQuery += " AND SRD.RD_PD = ? "
    cQuery += " AND SRA.RA_CLASEST IN ('02', '03', '11') " // Classification codes for foreigners. Can be viewed in RA_CLASEST.
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, ::aFilter)
    oStatement:SetString(4, BASE_VNIM_LIMIT)

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

    aAdd(::aAmountAccruedForeign, nSumCount)
    aAdd(::aAmountAccruedForeign, aDetails[1][2])
    aAdd(::aAmountAccruedForeign, aDetails[2][2])
    aAdd(::aAmountAccruedForeign, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP2060_InsurancePremiumsCalculated()
    This method calculate Insurance premiums calculated.
    This line 060 into report.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2060_InsurancePremiumsCalculated()
/*/
Method IPRP2060_InsurancePremiumsCalculated() Class RUIPRPart2
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := ::AmountSqlQueryExecute({VNIM_CONTRIBUTION_SALARY, VNIM_CONTRIBUTION_VACATION, VNIM_CONTRIBUTION_VACATION_NEXT_MONTH}, @nSumCount)

    aAdd(::aInsuracePremiumCalculated, nSumCount)
    aAdd(::aInsuracePremiumCalculated, aDetails[1][2])
    aAdd(::aInsuracePremiumCalculated, aDetails[2][2])
    aAdd(::aInsuracePremiumCalculated, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP2070_CostsIncurredForPaymentInsuranceCoverage()
    The method calculate costs incurred for payment of insurance coverage.
    This line 070 into report.
    We do not fill this part.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2070_CostsIncurredForPaymentInsuranceCoverage()
/*/
Method IPRP2070_CostsIncurredForPaymentInsuranceCoverage() Class RUIPRPart2

    // Write result.
    aAdd(::aInsuranceCoverageCosts, 0)
    aAdd(::aInsuranceCoverageCosts, 0)
    aAdd(::aInsuranceCoverageCosts, 0)
    aAdd(::aInsuranceCoverageCosts, 0)

Return

/*/
{Protheus.doc} IPRP2080_ReimbursedSIFExpenses()
    The method calculate the FSS reimbursed the costs of payment of insurance coverage.
    This line 080 into report.
    We do not fill this part.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2080_ReimbursedSIFExpenses()
/*/
Method IPRP2080_ReimbursedSIFExpenses() Class RUIPRPart2

    // Write result.
    aAdd(::aReimbursedSIFExpenses, 0)
    aAdd(::aReimbursedSIFExpenses, 0)
    aAdd(::aReimbursedSIFExpenses, 0)
    aAdd(::aReimbursedSIFExpenses, 0)

Return

/*/
{Protheus.doc} IPRP2090_PayableAmountInsuracePremium()
    The method calculate .
    This line 090 into report.
    This line equals to line 060.

    @type Method
    @params 
    @author vselyakov
    @since 17.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP2090_PayableAmountInsuracePremium()
/*/
Method IPRP2090_PayableAmountInsuracePremium() Class RUIPRPart2

    // Since this line is equal to the results from line 060, we will copy the array.
    ::aPayableAmountInsuracePremium := AClone(::aInsuracePremiumCalculated)

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
Method AmountSqlQueryExecute(aPaymentTypes, nTotal) Class RUIPRPart2
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
{Protheus.doc} ArticleSqlQueryExecute(lIsFSS, cPaymentType, nTotal, aExcludePayment)
    Executes an SQL query to display the amounts taking into account RV_INSS = 'N' or 'S'.

    @type Method
    @params lIsFSS,       Logical,   If .T. - RV_INSS = 'S', .F. - RV_INSS = 'N'.
            cPaymentType, Character, Type of payment type (RV_TIPOCOD).
            nTotal,       Numeric,   Variable for recording the total amount for the period.
            aExcludePayment, Array, An array with payment types that should not be included in the query result.
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return aDetails, Array, Array of amount for last three month of selected period.
    @example aDetails := ::ArticleSqlQueryExecute(.F., PAYMENT_TYPE_INCOME, @nSumCount) // RV_INSS = 'N'.
             aDetails := ::ArticleSqlQueryExecute(.F., PAYMENT_TYPE_INCOME, @nSumCount, {DEBT_CURRENT_MONTH_PAYMENT, DEBT_PREVIOUS_MONTH})
/*/
Method ArticleSqlQueryExecute(lIsFSS, cPaymentType, nTotal, aExcludePayment) Class RUIPRPart2
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric

    Default aExcludePayment := {}

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
    cQuery += " AND SRV.RV_TIPOCOD = ?  "
    cQuery += " AND SRV.RV_INSS = ? "

    If !Empty(aExcludePayment)
        cQuery += " AND SRD.RD_PD NOT IN (?) "
    EndIf

    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, ::aFilter)
    oStatement:SetString(4, PAYMENT_TYPE_INCOME)
    oStatement:SetString(5, Iif(lIsFSS, FSS_PAYMENT_YES, FSS_PAYMENT_NO))

    If !Empty(aExcludePayment)
        oStatement:SetIn(6, aExcludePayment)
    EndIf

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
