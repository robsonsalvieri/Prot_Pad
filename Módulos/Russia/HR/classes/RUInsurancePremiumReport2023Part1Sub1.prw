#INCLUDE "PROTHEUS.CH"

// Defenition of parameter indexes.
#Define CODE_REPORT_PERIOD_INDEX 1
#Define CODE_LOCATION_INDEX 2
#Define CODE_PAYER_TARIF_INDEX 3
#Define REPORT_YEAR_INDEX 4
#Define CORRECTION_NUMBER_INDEX 5
#Define AGENT_TYPE_INDEX 6
#Define AGENT_CODE_INDEX 7
#Define REORGANIZATION_INDEX 8
#Define TYPE_SIGNER_INDEX 9
#Define CODE_SIGNER_INDEX 10
#Define NAME_SIGNER_INDEX 11

// Defenition S-Table indexes.
#Define S37_FILIAL_INDEX 2
#Define S37_YEAR_INDEX 3
#Define S37_TYPE_INDEX 5
#Define S37_OPS_INDEX 9
#Define S37_OMS_INDEX 6
#Define S37_PREV_OPS_INDEX 20
#Define S001_FILIAL_INDEX 2
#Define S001_YEAR_INDEX 5
#Define S001_VNIM_INDEX 8

#Define S037_TYPE_YES "1"
#Define S037_TYPE_NO "2"

// Defenition of employee category (RA_CATEG).
#Define FIRED_EMPLOYEE_STATUS "D"
#Define HOURLY_EMPLOYEE_CATEGORY "H"
#Define MONTH_EMPLOYEE_CATEGORY "M"
#Define CIVIL_LAW_EMPLOYEE_CATEGORY "A" // GPH.

#Define PARAM_YEAR_INDEX 4

// Defenition type payments codes.
#Define CYRILLIC_P CHR(208)
#Define OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#Define OPS_BASE_NO_OVER_LIMIT "79" + CYRILLIC_P
#Define OPS_BASE_OVER_LIMIT "80" + CYRILLIC_P
#Define OPS_CONTRIBUTIONS_OVER_LIMIT "81" + CYRILLIC_P // ID 1762.
#Define OPS_BASE_INSURANCE_PREMIUM "700"
#Define VNIM_CONTRIBUTIONS_RFP "400"
#Define OMS_CONTRIBUTIONS "840"

#Define OPS_EXCLUSION_NON_CONTRIBUTION_INCOME "250"
#Define OPS_ID_EXCLUSION_NON_CONTRIBUTION_INCOME "0006"
#Define OPS_TIPOCOD_NON_CONTRIBUTION_INCOME "1"
#Define FGTS_YES "S" // RV_FGTS = "Yes".
#Define FGTS_NO "N" // RV_FGTS = "No".

#Define CURRENT_MONTH_DEBT "395"
#Define PREVIOUS_MONTH_DEBT "446"

#Define SCENARIO_NAME_SALARY "FOL" // SRD.RD_ROTEIR = 'FOL'
#Define SALARY_PROCESS "00001"


/*/
{Protheus.doc} RUInsurancePremiumReport2023Part1Sub1
    Class for generating a report Insurance premium report, Part 1, Subsection 1.

    @type Class
    @author vselyakov
    @since 07.12.2021
    @version 12.1.33
/*/
Class RUInsurancePremiumReport2023Part1Sub1 From LongNameClass
    Data cPageNumber1 As Character // Number of page in format "XXX".
    Data cPageNumber2 As Character // Number of page in format "XXX".
    Data cFilter As Character // Data from filter.
    Data aFilter As Array // Array of filials and personnel numbers for filter.
    Data aFilials As Array // Array of filials from filters.
    Data aNumbers As Array // Array of personnel numbers from filters. 

    // Data from parameters.
    Data aParameters  As Array // Array of parameters from pergunte.
    Data aPeriods     As Array
    Data aLastMonth   As Array

    // Data for report.
    Data cPayerRateCode              As Character // Line 001.
    Data aEmployeeCount              As Array // Line 010. {Total amount, First month, Second month, Third month}.
    Data aIndividualsCount           As Array // Line 020. {Total amount, First month, Second month, Third month}.
    Data aNoExceedingLimitCount      As Array // Line 021. {Total amount, First month, Second month, Third month}.
    Data aExceedingLimitCount        As Array // Line 022. {Total amount, First month, Second month, Third month}.
    Data aAmountArticle420           As Array // Line 030. Amount under article 420.
    Data a422ArticleAmouts           As Array // Line 040. Amount under article 422. {Total amount, First month, Second month, Third month}.
    Data a421ArticleAmouts           As Array // Line 045. Amount under article 421. {Total amount, First month, Second month, Third month}.
    Data aBaseAmoutsInsurancePremium As Array // Line 050. The base for calculating insurance premiums.

    // The basis for calculating insurance contributions, including: in an amount exceeding the maximum base for calculating insurance contributions for compulsory pension insurance.
    Data aNoOverBaseAmoutsInsurancePremium As Array // Line 051. {Total amount, First month, Second month, Third month}.
    Data aOverBaseAmoutsInsurancePremium As Array // Line 052. {Total amount, First month, Second month, Third month}.

    // Insurance premiums calculated?
    Data aInsuracePremiumCalculated As Array // Line 060.
    Data aUnderBaseInsuracePremiumCalculated As Array // Line 061.
    Data aOverBaseInsuracePremiumCalculated As Array // Line 062.

    Data aS037Data As Array // All data from S037.
    Data aS001Data As Array // All data from S001.

    Data cCurrentPeriod As Character // Current open period
    Data cEndPeriod  As Character // Last period in array of period

    // Needed to split rows by filials.
    Data aLine051 As Array
    Data aLine052 As Array

    // Constructors.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor

    // Methods.
    Method MakeData()

    Method IPRP1S1010_InsuredPersonsNumber() // Line 010.

    Method IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated() // Line 020.
    Method IPRP1S1021_NotExceedingLimitBaseValue() // Line 021.
    Method IPRP1S1022_ExceedingLimitBaseValue() // Line 022.
    Method IPRP1S1030_PaymentsUnderArticle420() // Line 030.
    Method IPRP1S1040_PaymentsUnderArticle422() // Line 040.
    Method IPRP1S1045_PaymentsUnderArticle421() // Line 045.
    Method IPRP1S1050_CalculatingBaseInsurancePremiums() // Line 050.
    Method IPRP1S1051_NoBaseInAmountExceedingLimitValue() // Line 051.
    Method IPRP1S1052_BaseInAmountExceedingLimitValue() // Line 052.
    Method IPRP1S1060_InsuracePremiumCalculated() // Line 060.
    Method IPRP1S1061_UnderBaseInsuracePremiumCalculated() // Line 061.
    Method IPRP1S1062_OverBaseInsuracePremiumCalculated() // Line 062.

    Method AmountSqlQueryExecute(aPaymentTypes, nTotal, cBranch)
    Method ArticleSqlQueryExecute(lIsFGTS, nTotal)
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RUInsurancePremiumReport2023Part1Sub1 constructor.

    @type Method, Consttructor
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aPeriods,    Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,  Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 07.12.2021
    @version 12.1.33
    @return RUInsurancePremiumReport2023Part1Sub1, Object, RUInsurancePremiumReport2023Part1Sub1 instance.
    @example Self:oPart1Subsection1 := RUInsurancePremiumReport2023Part1Sub1():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers)
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Class RUInsurancePremiumReport2023Part1Sub1
    Local nI := 0 As Numeric

    Self:aFilials := {}
    Self:aNumbers := {}

    Self:aLine051 := {}
    Self:aLine052 := {}

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:aPeriods := AClone(aPeriods)
    Self:aLastMonth := AClone(aLastMonth)

    Self:aEmployeeCount := {}
    Self:aIndividualsCount := {}
    Self:aNoExceedingLimitCount := {}
    Self:aExceedingLimitCount := {}
    Self:aAmountArticle420 := {}
    Self:a422ArticleAmouts := {}
    Self:a421ArticleAmouts := {}
    Self:aBaseAmoutsInsurancePremium := {}
    Self:aNoOverBaseAmoutsInsurancePremium := {}
    Self:aOverBaseAmoutsInsurancePremium := {}
    Self:aInsuracePremiumCalculated := {}
    Self:aUnderBaseInsuracePremiumCalculated := {}
    Self:aOverBaseInsuracePremiumCalculated := {}

    Self:cEndPeriod  := ::aPeriods[Len(Self:aPeriods)]
    Self:cCurrentPeriod := Iif(GetCurOpenPeriod(@Self:cCurrentPeriod), Self:cCurrentPeriod, Self:cEndPeriod)

    // Loading data from S-tables.
    Self:aS037Data := {}
    fCarrTab(@Self:aS037Data, "S037")
    Self:aS001Data := {}
    fCarrTab(@Self:aS001Data, "S001")

    // Grouping filials and personnel numbers.    
    For nI := 1 To Len(Self:aFilter)
        // Only filials.
        If aScan(Self:aFilials, {|x| x == Self:aFilter[nI][1]}) < 1
            aAdd(Self:aFilials, Self:aFilter[nI][1])
        EndIf

        // Only personnel numbers.
        If aScan(Self:aNumbers, {|x| x == Self:aFilter[nI][2]}) < 1
            aAdd(Self:aNumbers, Self:aFilter[nI][2])
        EndIf
    Next nI

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:RUInsurancePremiumReport2023Part1Sub1:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport2023Part1Sub1

    Self:cPayerRateCode := PadL(AllTrim(Self:aParameters[3]), 2, "0")

    Self:IPRP1S1010_InsuredPersonsNumber()
    Self:IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated()
    Self:IPRP1S1021_NotExceedingLimitBaseValue()
    Self:IPRP1S1022_ExceedingLimitBaseValue()
    Self:IPRP1S1030_PaymentsUnderArticle420()
    Self:IPRP1S1040_PaymentsUnderArticle422()
    Self:IPRP1S1045_PaymentsUnderArticle421()
    Self:IPRP1S1050_CalculatingBaseInsurancePremiums()
    Self:IPRP1S1051_NoBaseInAmountExceedingLimitValue()
    Self:IPRP1S1052_BaseInAmountExceedingLimitValue()
    Self:IPRP1S1060_InsuracePremiumCalculated()
    Self:IPRP1S1061_UnderBaseInsuracePremiumCalculated()
    Self:IPRP1S1062_OverBaseInsuracePremiumCalculated()

Return

/*/
{Protheus.doc} IPRP1S1010_InsuredPersonsNumber()
    The method calculate number of insured persons.
    This line 010 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1010_InsuredPersonsNumber()
/*/
Method IPRP1S1010_InsuredPersonsNumber() Class RUInsurancePremiumReport2023Part1Sub1
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
    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aLastEmployeeCount, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT RA_MAT, RA_ADMISSA, RA_DEMISSA FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL IN (?) "
    cQuery += " AND RA_CATFUNC IN (?) "
    cQuery += " AND (LEFT(RA_ADMISSA, 6) <= ? AND (RA_DEMISSA = '        ' OR LEFT(RA_DEMISSA, 4) >= ? )) "
    cQuery += " AND RA_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, {HOURLY_EMPLOYEE_CATEGORY, MONTH_EMPLOYEE_CATEGORY, CIVIL_LAW_EMPLOYEE_CATEGORY})
    oStatement:SetString(3, Self:aPeriods[Len(Self:aPeriods)])
    oStatement:SetString(4, Self:aParameters[PARAM_YEAR_INDEX])
    oStatement:SetIn(5, Self:aNumbers)

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
    
    aAdd(Self:aEmployeeCount, nTotalEmployeeCount)
    aAdd(Self:aEmployeeCount, aLastEmployeeCount[1][2])
    aAdd(Self:aEmployeeCount, aLastEmployeeCount[2][2])
    aAdd(Self:aEmployeeCount, aLastEmployeeCount[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated()
    The method calculate The number of individuals from whose payments the insurance premiums have been calculated.
    This line 020 into report.

    @type Method
    @params 
    @author vselyakov
    @since 08.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated()
/*/
Method IPRP1S1020_NumberIndividualsWhosePaymentsPremiumsCalculated() Class RUInsurancePremiumReport2023Part1Sub1
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local aEmployee  As Array

    aArea := GetArea()
    aDetails := {}
    aEmployee := {} 

    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aDetails, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT DISTINCT RD_PERIODO, RD_MAT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND RD_VALOR > 0 "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, {OPS_CONTRIBUTIONS_LIMIT, OPS_CONTRIBUTIONS_OVER_LIMIT, VNIM_CONTRIBUTIONS_RFP, OMS_CONTRIBUTIONS})
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    // Add emplyee count by periods and calculate total employees.
    While !(cTab)->(Eof())
        If Ascan(aEmployee, (cTab)->RD_MAT) == 0
            Aadd(aEmployee, (cTab)->RD_MAT)
        EndIf

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] ++
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    aAdd(Self:aIndividualsCount, Len(aEmployee))
    aAdd(Self:aIndividualsCount, aDetails[1][2])
    aAdd(Self:aIndividualsCount, aDetails[2][2])
    aAdd(Self:aIndividualsCount, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S1021_NotExceedingLimitBaseValue()
    The method calculate The value not exceeding the maximum value of the base for calculating insurance premiums for compulsory pension insurance (people).
    This line 021 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1021_NotExceedingLimitBaseValue()
/*/
Method IPRP1S1021_NotExceedingLimitBaseValue() Class RUInsurancePremiumReport2023Part1Sub1
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local aEmployee  As Array

    aArea := GetArea()
    aDetails := {}
    aEmployee := {}

    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aDetails, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT DISTINCT RD_PERIODO, RD_MAT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND RD_VALOR > 0 "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, {OPS_CONTRIBUTIONS_LIMIT, VNIM_CONTRIBUTIONS_RFP, OMS_CONTRIBUTIONS})
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        If Ascan(aEmployee, (cTab)->RD_MAT) == 0
            Aadd(aEmployee, (cTab)->RD_MAT)
        EndIf

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] ++
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    aAdd(Self:aNoExceedingLimitCount, Len(aEmployee))
    aAdd(Self:aNoExceedingLimitCount, aDetails[1][2])
    aAdd(Self:aNoExceedingLimitCount, aDetails[2][2])
    aAdd(Self:aNoExceedingLimitCount, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S1022_ExceedingLimitBaseValue()
    The method calculate The value exceeding the maximum value of the base for calculating insurance premiums for compulsory pension insurance (people).
    This line 022 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1022_ExceedingLimitBaseValue()
/*/
Method IPRP1S1022_ExceedingLimitBaseValue() Class RUInsurancePremiumReport2023Part1Sub1
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local aEmployee  As Array

    aArea := GetArea()
    aDetails := {}
    aEmployee := {}

    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aDetails, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT DISTINCT RD_PERIODO, RD_MAT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND RD_VALOR > 0 "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, {OPS_CONTRIBUTIONS_OVER_LIMIT})
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        If Ascan(aEmployee, (cTab)->RD_MAT) == 0
            Aadd(aEmployee, (cTab)->RD_MAT)
        EndIf

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] ++
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    aAdd(Self:aExceedingLimitCount, Len(aEmployee))
    aAdd(Self:aExceedingLimitCount, aDetails[1][2])
    aAdd(Self:aExceedingLimitCount, aDetails[2][2])
    aAdd(Self:aExceedingLimitCount, aDetails[3][2])

    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP1S1030_PaymentsUnderArticle420()
    The method calculate The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation.
    This line 030 into report.

    @type Method
    @params 
    @author vselyakov
    @since 09.12.2021
    @version 12.1.33
    @return 
    @example Self:IPRP1S1030_PaymentsUnderArticle420()
/*/
Method IPRP1S1030_PaymentsUnderArticle420() Class RUInsurancePremiumReport2023Part1Sub1
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
    aDetails := {{Self:aLastMonth[1], 0}, {Self:aLastMonth[2], 0}, {Self:aLastMonth[3], 0}}

    // Create SQL-query text.
    cQuery := " SELECT SRD.RD_PERIODO, SUM(SRD.RD_VALOR) AS SUMMARY "
    cQuery += " FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON "
    cQuery += "     SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += "     SRD.RD_FILIAL IN (?) "
    cQuery += "     AND SRD.RD_PERIODO IN (?) "
    cQuery += "     AND SRD.RD_MAT IN (?) "
    cQuery += "     AND SRD.RD_ROTEIR = ? "
    cQuery += "     AND SRV.RV_FGTS = ? "
    cQuery += "     AND SRV.RV_TIPOCOD = ? "
    cQuery += "     AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += "     AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    // Create object with SQL-query.
    oStatement := FWPreparedStatement():New(cQuery)

    // Set variables into SQL-query object.
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, Self:aNumbers)
    oStatement:SetString(4, SCENARIO_NAME_SALARY) // Only FOL scenario.
    oStatement:SetString(5, FGTS_YES) // RV_FGTS = "Yes".
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

    aAdd(Self:aAmountArticle420, nSumCount)
    aAdd(Self:aAmountArticle420, aDetails[1][2])
    aAdd(Self:aAmountArticle420, aDetails[2][2])
    aAdd(Self:aAmountArticle420, aDetails[3][2])

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return

/*/
{Protheus.doc} IPRP1S1040_PaymentsUnderArticle422()
    The method calculate Amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties.
    This line 040 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1040_PaymentsUnderArticle422()
/*/
Method IPRP1S1040_PaymentsUnderArticle422() Class RUInsurancePremiumReport2023Part1Sub1
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := Self:ArticleSqlQueryExecute(.F., @nSumCount)

    // Write result.
    aAdd(Self:a422ArticleAmouts, nSumCount)
    aAdd(Self:a422ArticleAmouts, aDetails[1][2])
    aAdd(Self:a422ArticleAmouts, aDetails[2][2])
    aAdd(Self:a422ArticleAmouts, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP1S1045_PaymentsUnderArticle421()
    The method calculate The amount of expenses accepted for deduction in accordance with paragraph 8 of Article 421 of the Tax Code of the Russian Federation.
    This line 045 into report.
    We do not fill this part.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1045_PaymentsUnderArticle421()
/*/
Method IPRP1S1045_PaymentsUnderArticle421() Class RUInsurancePremiumReport2023Part1Sub1

    // Write result.
    aAdd(Self:a421ArticleAmouts, 0)
    aAdd(Self:a421ArticleAmouts, 0)
    aAdd(Self:a421ArticleAmouts, 0)
    aAdd(Self:a421ArticleAmouts, 0)

Return

/*/
{Protheus.doc} IPRP1S1050_CalculatingBaseInsurancePremiums()
    The method calculate The base for calculating insurance premiums.
    This line 050 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1050_CalculatingBaseInsurancePremiums()
/*/
Method IPRP1S1050_CalculatingBaseInsurancePremiums() Class RUInsurancePremiumReport2023Part1Sub1
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := Self:AmountSqlQueryExecute({OPS_BASE_INSURANCE_PREMIUM}, @nSumCount)

    // Write result.
    aAdd(Self:aBaseAmoutsInsurancePremium, nSumCount)
    aAdd(Self:aBaseAmoutsInsurancePremium, aDetails[1][2])
    aAdd(Self:aBaseAmoutsInsurancePremium, aDetails[2][2])
    aAdd(Self:aBaseAmoutsInsurancePremium, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP1S1051_BaseInAmountNoExceedingLimitValue()
    The method calculate The basis for calculating insurance contributions, 
    including: in an amount no exceeding the maximum base for calculating insurance contributions for compulsory pension insurance.
    This line 051 into report.

    @type Method
    @params 
    @author vselyakov
    @since 09.12.2021
    @version 12.1.33
    @return 
    @example Self:IPRP1S1051_BaseInAmountNoExceedingLimitValue()
/*/
Method IPRP1S1051_NoBaseInAmountExceedingLimitValue() Class RUInsurancePremiumReport2023Part1Sub1
    Local aDetails := {} As Array
    Local nSumCount := 0 As Numeric
    Local nSumTotal := 0 As Numeric
    Local nFirstSum := 0 As Numeric // First month.
    Local nSecondSum := 0 As Numeric // Second month.
    Local nThirdSum := 0 As Numeric // Third month.
    Local nI := 0 As Numeric

    For nI := 1 To Len(Self:aFilials)

        // Execute sql query for this line of report.
        aDetails := Self:AmountSqlQueryExecute({OPS_BASE_NO_OVER_LIMIT}, @nSumCount, Self:aFilials[nI])

        // Add data for specific filial.
        aAdd(Self:aLine051, {Self:aFilials[nI], nSumCount, aDetails[1][2], aDetails[2][2], aDetails[3][2]})

    Next nI

    // Summation of data by filials.
    For nI := 1 To Len(Self:aLine051)
        nSumTotal += Self:aLine051[nI][2]
        nFirstSum += Self:aLine051[nI][3]
        nSecondSum += Self:aLine051[nI][4]
        nThirdSum += Self:aLine051[nI][5]
    Next nI

    // Write result.
    aAdd(Self:aNoOverBaseAmoutsInsurancePremium, nSumTotal)
    aAdd(Self:aNoOverBaseAmoutsInsurancePremium, nFirstSum)
    aAdd(Self:aNoOverBaseAmoutsInsurancePremium, nSecondSum)
    aAdd(Self:aNoOverBaseAmoutsInsurancePremium, nThirdSum)
Return

/*/
{Protheus.doc} IPRP1S1052_BaseInAmountExceedingLimitValue()
    The method calculate The basis for calculating insurance contributions, 
    including: in an amount exceeding the maximum base for calculating insurance contributions for compulsory pension insurance.
    This line 052 into report.

    @type Method
    @params 
    @author vselyakov
    @since 09.12.2021
    @version 12.1.33
    @return 
    @example Self:IPRP1S1052_BaseInAmountExceedingLimitValue()
/*/
Method IPRP1S1052_BaseInAmountExceedingLimitValue() Class RUInsurancePremiumReport2023Part1Sub1
    Local aDetails := {} As Array
    Local nSumCount := 0 As Numeric
    Local nSumTotal := 0 As Numeric
    Local nFirstSum := 0 As Numeric // First month.
    Local nSecondSum := 0 As Numeric // Second month.
    Local nThirdSum := 0 As Numeric // Third month.
    Local nI := 0 As Numeric

    For nI := 1 To Len(Self:aFilials)

        // Execute sql query for this line of report.
        aDetails := Self:AmountSqlQueryExecute({OPS_BASE_OVER_LIMIT}, @nSumCount, Self:aFilials[nI])

        // Add data for specific filial.
        aAdd(Self:aLine052, {Self:aFilials[nI], nSumCount, aDetails[1][2], aDetails[2][2], aDetails[3][2]})

    Next nI

    // Summation of data by filials.
    For nI := 1 To Len(Self:aLine052)
        nSumTotal += Self:aLine052[nI][2]
        nFirstSum += Self:aLine052[nI][3]
        nSecondSum += Self:aLine052[nI][4]
        nThirdSum += Self:aLine052[nI][5]
    Next nI

    // Write result.
    aAdd(Self:aOverBaseAmoutsInsurancePremium, nSumTotal)
    aAdd(Self:aOverBaseAmoutsInsurancePremium, nFirstSum)
    aAdd(Self:aOverBaseAmoutsInsurancePremium, nSecondSum)
    aAdd(Self:aOverBaseAmoutsInsurancePremium, nThirdSum)
Return

/*/
{Protheus.doc} IPRP1S1060_InsuracePremiumCalculated()
    The method calculate Insurance premiums calculated.
    This line 060 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1060_InsuracePremiumCalculated()
/*/
Method IPRP1S1060_InsuracePremiumCalculated() Class RUInsurancePremiumReport2023Part1Sub1
    Local aDetails  As Array
    Local nSumCount As Numeric

    // Execute sql query for this line of report.
    aDetails := Self:AmountSqlQueryExecute({OPS_CONTRIBUTIONS_LIMIT, OPS_CONTRIBUTIONS_OVER_LIMIT, VNIM_CONTRIBUTIONS_RFP, OMS_CONTRIBUTIONS}, @nSumCount)

    // Write result.
    aAdd(Self:aInsuracePremiumCalculated, nSumCount)
    aAdd(Self:aInsuracePremiumCalculated, aDetails[1][2])
    aAdd(Self:aInsuracePremiumCalculated, aDetails[2][2])
    aAdd(Self:aInsuracePremiumCalculated, aDetails[3][2])
Return

/*/
{Protheus.doc} IPRP1S1061_UnderBaseInsuracePremiumCalculated()
    The method calculate Insurance contributions are calculated, 
    including: from a base not exceeding the maximum base size for calculating insurance contributions for compulsory pension insurance.
    This line 061 into report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP1S1061_UnderBaseInsuracePremiumCalculated()
/*/
Method IPRP1S1061_UnderBaseInsuracePremiumCalculated() Class RUInsurancePremiumReport2023Part1Sub1
    Local nS037PercentSum := 0 As Numeric
    Local nS001PercentSum := 0 As Numeric
    Local nI := 0 As Numeric
    Local nJ := 0 As Numeric
    Local nSumTotal := 0 As Numeric
    Local nFirstSum := 0 As Numeric // First month.
    Local nSecondSum := 0 As Numeric // Second month.
    Local nThirdSum := 0 As Numeric // Third month.
    Local nIndexFilial := 0 As Numeric

    For nI := 1 To Len(Self:aFilials)
        nIndexFilial := 0

        // Search data for S037 table.
        For nJ := 1 To Len(Self:aS037Data)
            If Self:aS037Data[nJ][S37_FILIAL_INDEX] == Self:aFilials[nI] .Or. Empty(Self:aS037Data[nJ][S37_FILIAL_INDEX])
                If Self:aParameters[REPORT_YEAR_INDEX] == Substr(Self:aS037Data[nJ][S37_YEAR_INDEX], 1, 4) .And. Self:aS037Data[nJ][S37_TYPE_INDEX] == S037_TYPE_YES
                    nS037PercentSum := Self:aS037Data[nJ][S37_OPS_INDEX] + Self:aS037Data[nJ][S37_OMS_INDEX]
                EndIf
            EndIf
        Next nJ

        // Search data for S001 table.
        For nJ := 1 To Len(Self:aS001Data)
            If Self:aS001Data[nJ][S001_FILIAL_INDEX] == Self:aFilials[nI] .Or. Empty(Self:aS001Data[nJ][S001_FILIAL_INDEX])
                If Self:aParameters[REPORT_YEAR_INDEX] == Substr(Self:aS001Data[nJ][S001_YEAR_INDEX], 1, 4) 
                    nS001PercentSum := Self:aS001Data[nJ][S001_VNIM_INDEX]
                EndIf
            EndIf
        Next nJ

        nIndexFilial := aScan(Self:aLine051, {|x| x[1] == Self:aFilials[nI]})

        If nIndexFilial > 0
            nSumTotal  += Self:aLine051[nIndexFilial][2] * ((nS037PercentSum + nS001PercentSum) / 100)
            nFirstSum  += Self:aLine051[nIndexFilial][3] * ((nS037PercentSum + nS001PercentSum) / 100)
            nSecondSum += Self:aLine051[nIndexFilial][4] * ((nS037PercentSum + nS001PercentSum) / 100)
            nThirdSum  += Self:aLine051[nIndexFilial][5] * ((nS037PercentSum + nS001PercentSum) / 100)
        EndIf

    Next nI

    // Write result.
    aAdd(Self:aUnderBaseInsuracePremiumCalculated, Round(nSumTotal, 2))
    aAdd(Self:aUnderBaseInsuracePremiumCalculated, Round(nFirstSum, 2))
    aAdd(Self:aUnderBaseInsuracePremiumCalculated, Round(nSecondSum, 2))
    aAdd(Self:aUnderBaseInsuracePremiumCalculated, Round(nThirdSum, 2))
Return

/*/
{Protheus.doc} IPRP1S1062_OverBaseInsuracePremiumCalculated()
    The method calculate Calculated insurance contributions, 
    including: from a base exceeding the maximum base value for calculating insurance contributions for compulsory pension insurance.
    This line 062 into report.

    @type Method
    @params 
    @author vselyakov
    @since 09.12.2021
    @version 12.1.33
    @return 
    @example Self:IPRP1S1062_OverBaseInsuracePremiumCalculated()
/*/
Method IPRP1S1062_OverBaseInsuracePremiumCalculated() Class RUInsurancePremiumReport2023Part1Sub1
    Local nS037PercentSum := 0 As Numeric
    Local nI := 0 As Numeric
    Local nJ := 0 As Numeric
    Local nSumTotal := 0 As Numeric
    Local nFirstSum := 0 As Numeric // First month.
    Local nSecondSum := 0 As Numeric // Second month.
    Local nThirdSum := 0 As Numeric // Third month.
    Local nIndexFilial := 0 As Numeric

    For nI := 1 To Len(Self:aFilials)
        nIndexFilial := 0

        // Search data for S037 table.
        For nJ := 1 To Len(Self:aS037Data)
            If Self:aS037Data[nJ][S37_FILIAL_INDEX] == Self:aFilials[nI] .Or. Empty(Self:aS037Data[nJ][S37_FILIAL_INDEX])
                If Self:aParameters[REPORT_YEAR_INDEX] == Substr(Self:aS037Data[nJ][S37_YEAR_INDEX], 1, 4) .And. Self:aS037Data[nJ][S37_TYPE_INDEX] == S037_TYPE_YES
                    nS037PercentSum := Self:aS037Data[nJ][S37_PREV_OPS_INDEX] + Self:aS037Data[nJ][S37_OMS_INDEX]
                EndIf
            EndIf
        Next nJ

        nIndexFilial := aScan(Self:aLine052, {|x| x[1] == Self:aFilials[nI]})

        If nIndexFilial > 0
            nSumTotal  += Self:aLine052[nIndexFilial][2] * (nS037PercentSum / 100)
            nFirstSum  += Self:aLine052[nIndexFilial][3] * (nS037PercentSum / 100)
            nSecondSum += Self:aLine052[nIndexFilial][4] * (nS037PercentSum / 100)
            nThirdSum  += Self:aLine052[nIndexFilial][5] * (nS037PercentSum / 100)
        EndIf

    Next nI

    // Write result.
    aAdd(Self:aOverBaseInsuracePremiumCalculated, Round(nSumTotal, 2))
    aAdd(Self:aOverBaseInsuracePremiumCalculated, Round(nFirstSum, 2))
    aAdd(Self:aOverBaseInsuracePremiumCalculated, Round(nSecondSum, 2))
    aAdd(Self:aOverBaseInsuracePremiumCalculated, Round(nThirdSum, 2))
Return

/*/
{Protheus.doc} AmountSqlQueryExecute(aPaymentTypes, nTotal, cBranch)
    Executes an SQL query to display the amounts for the specified wage type by period.

    @type Method
    @params aPaymentTypes, Array, Array of payments for Sql query.
            nTotal, Numeric, Variable for recording the total amount for the period.
            cBranch, Character, Optional parameter. Specified if you need to make a selection for a specific filial.
    @author vselyakov
    @since 16.12.2021
    @version 12.1.33
    @return aDetails, Array, Array of amount for last three month of selected period.
    @example aDetails := Self:AmountSqlQueryExecute({OPS_BASE_OVER_LIMIT}, @nSumCount)
/*/
Method AmountSqlQueryExecute(aPaymentTypes, nTotal, cBranch) Class RUInsurancePremiumReport2023Part1Sub1
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local aDetails   As Array
    Local nSumCount  As Numeric

    Default cBranch := ""

    aArea := GetArea()
    aDetails := {}
    nSumCount := 0

    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aDetails, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    If ValType(cBranch) <> "U" .And. !Empty(cBranch)
        oStatement:SetIn(1, {cBranch})
    Else
        oStatement:SetIn(1, Self:aFilials)
    EndIf
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        nSumCount += (cTab)->SUMMARY

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
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
Method ArticleSqlQueryExecute(lIsFGTS, nTotal) Class RUInsurancePremiumReport2023Part1Sub1
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

    For nI := 1 To Len(Self:aLastMonth)
        aAdd(aDetails, {Self:aLastMonth[nI], 0})
    Next nI

    cQuery := " SELECT SRD.RD_PERIODO, SUM(SRD.RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD " + Iif(lIsFGTS, "", " AND NOT (SRV.RV_COD = ? AND SRV.RV_CODFOL = ?) AND SRV.RV_TIPOCOD = ?")
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL IN (?) "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_MAT IN (?) "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' " // Only FOL scenario.
    cQuery += " AND SRV.RV_FGTS = ? " // The type of payment will (will not) be taken into account in the calculation base of PFR insurance premiums.
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    If lIsFGTS
        oStatement:SetIn(1, Self:aFilials)
        oStatement:SetIn(2, Self:aPeriods)
        oStatement:SetIn(3, Self:aNumbers)
        oStatement:SetString(4, FGTS_YES)
    Else
        oStatement:SetString(1, OPS_EXCLUSION_NON_CONTRIBUTION_INCOME)
        oStatement:SetString(2, OPS_ID_EXCLUSION_NON_CONTRIBUTION_INCOME)
        oStatement:SetString(3, OPS_TIPOCOD_NON_CONTRIBUTION_INCOME)
        oStatement:SetIn(4, Self:aFilials)
        oStatement:SetIn(5, Self:aPeriods)
        oStatement:SetIn(6, Self:aNumbers)
        oStatement:SetString(7, FGTS_NO)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        nSumCount += (cTab)->SUMMARY

        For nI := 1 To Len(aDetails)
            If aDetails[nI][1] == (cTab)->RD_PERIODO
                aDetails[nI][2] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

    nTotal := nSumCount

Return aDetails

/*/
{Protheus.doc} GetCurOpenPeriod(cPeriod)
    Write current open period in cPeriod and return success about get them.

    @type Static Function
    @params cPeriod, Character, parameter in which the period will be recorded
    @author dchizhov
    @since 01.04.2022
    @version 12.1.33
    @return lSuccess, Logical, Success about getting current open period
    @example cCurrentPeriod := Iif(GetCurOpenPeriod(@cCurrentPeriod), cCurrentPeriod, DefaultValue)
/*/
Static Function GetCurOpenPeriod(cPeriod)

    Local lSuccess := .F. As Logical
    Local cProcesso       As Character
    Local cRot            As Character
    Local cSemana         As Character
    Local cAnoMes         As Character

    cPeriod   := ""
    cProcesso := "00001"
    cRot := fGetCalcRot("1")
    
    fGetLastPer(@cPeriod, @cSemana, cProcesso, cRot, .T., .F., @cAnoMes)

    lSuccess := Len(AllTrim(cPeriod)) > 0
    
Return lSuccess
