#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R18RUS.CH"

// Defenition of indexes.
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

// Defenition of constans.
#Define LAST_MONTH_COUNT 3

#Define NDFL_BUDGET_CODE "413"
#Define NDFL_RATE_13_PERCENT "13"
#Define NDFL_RATE_15_PERCENT "15"

// Reporting period codes. Table S213.
#Define FIRST_QUARTER_REPORT_PERIOD_CODE "21"
#Define HALF_YEAR_REPORT_PERIOD_CODE     "31"
#Define NINE_MONTH_REPORT_PERIOD_CODE    "33"
#Define ONE_YEAR_REPORT_PERIOD_CODE      "34"
#Define REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE "51"
#Define REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE     "52"
#Define REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE    "53"
#Define REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE      "90"

#Define MAX_LEN_INN 12
#Define MAX_LEN_KPP 9
#Define MAX_LEN_PAGES 3
#Define MAX_LEN_CORRECTION_NUMBER 3
#Define MAX_LEN_OKTMO_CODE 11
#Define MAX_LEN_PHONE_NUMBER 20

#Define MAX_LEN_NALOG_AGENT 160
#Define MAX_LEN_SIGNER 60
#Define MAX_LEN_SIGNER_DOCUMENTS 40

#Define MAX_LEN_LIQUIDATION_CODE 1
#Define MAX_LEN_INN_CLOSED_ORGANIZATION 10
#Define MAX_LEN_KPP_CLOSED_ORGANIZATION 9

#Define MAX_LEN_NUMERIC_VALUE 15
#Define MAX_LEN_DECIMAL_VALUE 2

#Define MAX_LEN_EMPLOYEE 6
#Define MAX_LEN_EMPLOYEE_COUNT 6
#Define MAX_LEN_OKVED 6


/*/
{Protheus.doc} RUInsurancePremiumReport
    Class for generating a Insurance premium report.

    @type Class
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
/*/
Class RUInsurancePremiumReport2023 From LongNameClass
    // Input parameters.
    Data aParameters       As Array     // Array of parameters from pergunte.
    Data cFilter           As Character // Expression for filter.
    Data lFilterOn         As Logical   // Flag of active filter.

    // Properties.
    Data cDateReport       As Date      // Report generation date.
    Data cPeriod           As Character // Code of report period (from parameters).
    Data cYear             As Character // Year entered in parameters.

    Data oHeader           As Object    // Info for report header.

    Data aPersonnelNumbers As Array     // Array of personel numbers with format: {RA_FILIAL, RA_MAT}.

    Data aPart1            As Array     // Array of objects Ru6NDFLPart1 (Part 1) (for 13% and 15%).
    Data aPart2            As Array     // Array of objects Ru6NDFLPart2 (Part 2) (for 13% and 15%).
    Data aPeriods          As Array     // All selected periods.
    Data aLastMonth        As Array     // Last 3 month from period for Part 1.
    Data lRate13           As Logical   // In selected period exist payments on 13%.
    Data lRate15           As Logical   // In selected period exist payments on 15%.
    Data cPageCount        As Character // Number of pages on which the report is drawn.
    
    Data aAttachments      As Array     // Array with 2NDFL object.

    Data oPart1Subsection1 As Object // Object for class RUIPRPart1Subsection1.
    Data oPart1Subsection2 As Object // Object for class RUIPRPart1Subsection2.
    Data oPart2            As Object // Object for class RUIPRPart2.
    Data oPart3 As Object
    Data aPart3 As Array

    // Constructor.
    Method New(aParameters, cFilterExpression) Constructor

    // Methods.
    Method GetPersonnelNumbers()
    Method GetPeriods()
    Method GetLastMonthes()
    Method MakeData()
    Method MakeDataForReport()

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New(aParameters, cFilterExpression)
    Default constructor, 

    @type Constructor
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilterExpression,     Character, Expression for filter (from parameters).
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return RUInsurancePremiumReport2023, Object, RUInsurancePremiumReport2023 instance.
    @example oRUInsurancePremiumReport := RUInsurancePremiumReport2023():New(aParameters, cFilter)
/*/
Method New(aParameters, cFilterExpression) Class RUInsurancePremiumReport2023
    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilterExpression
    Self:cPeriod := AllTrim(Self:aParameters[CODE_REPORT_PERIOD_INDEX])
    Self:cYear := AllTrim(Self:aParameters[REPORT_YEAR_INDEX])
    Self:aPersonnelNumbers := {}

    // Filtration processing. If there are conditions, then employees are loaded for sampling.
    If !Empty(Self:cFilter)
        Self:lFilterOn := .T.
        Self:aPersonnelNumbers := Self:GetPersonnelNumbers()
    Else
        Self:lFilterOn := .F.
    EndIf

    Self:cDateReport := DToC(Date())
    Self:aPart3 := {}

Return Self

/*/
{Protheus.doc} GetPersonnelNumbers()
    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example Self:aPersonnelNumbers := Self:GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RUInsurancePremiumReport2023
    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character

    aNumbers := {}
    aArea := GetArea()

    cQuery := " SELECT RA_FILIAL, RA_MAT FROM " +  RetSQLName("SRA") + " WHERE "
    cQuery += Self:cFilter
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        aAdd(aNumbers, {(cTab)->RA_FILIAL, (cTab)->RA_MAT})
        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aNumbers

/*/
{Protheus.doc} GetPeriods()
    Made periods in format '202101' by selected code report period from parameters.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return aPeriods, Array, Array of periods in format 'YYYYMM' ordered.
    @example Self:aPeriods := Self:GetPeriods()
/*/
Method GetPeriods() Class RUInsurancePremiumReport2023
    Local aPeriods := {} As Array
    Local nMaxMonth As Numeric
    Local nI        As Numeric

    Do Case
        Case Self:cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            nMaxMonth := 3
        Case Self:cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            nMaxMonth := 6
        Case Self:cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            nMaxMonth := 9
        Case Self:cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            nMaxMonth := 12
        Otherwise
            nMaxMonth := 3
    EndCase

    For nI := 1 To nMaxMonth
        aAdd(aPeriods, Self:cYear + StrZero(nI, 2, 0))
    Next nI

Return aPeriods

/*/
{Protheus.doc} GetLastMonthes()
    Return 3 last periods from all periods from GetPeriods() function in format 'YYYYMM'.

    @type Method
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return aPeriods, Array, Array of 3 last month in periods format 'YYYYMM' ordered.
    @example Self:aLastMonth := Self:GetLastMonthes()
/*/
Method GetLastMonthes() Class RUInsurancePremiumReport2023
    Local aPeriods := {} As Array
    Local nI As Numeric

    If Len(Self:aPeriods) >= LAST_MONTH_COUNT
        For nI := Len(Self:aPeriods) - 2 To Len(Self:aPeriods)
            aAdd(aPeriods, Self:aPeriods[nI])
        Next nI
    EndIf

Return aPeriods

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report.

    @type Method
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return 
    @example oRu6Ndfl:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport2023
    Local nPageNumber As Numeric
    Local nI As Numeric
    Local aArea As Array
    Local aSRAArea As Array

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    nPageNumber := 0

    // Get need data for next calculations.
    Self:aPeriods := Self:GetPeriods()
    Self:aLastMonth := Self:GetLastMonthes()

    // Create header of report.
    Self:oHeader := RUInsurancePremiumReport2023Header():New(Self:aParameters, Self:cFilter, Self:aPersonnelNumbers)
    Self:oHeader:MakeData()
    nPageNumber++
    Self:oHeader:cPageNumber := PadL(AllTrim(Str(nPageNumber)), 3, "0") //"001"

    // Create Part 1.
    Self:aPart1 := RUInsurancePremiumReport2023Part1():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers)
    Self:aPart1:MakeData()
    nPageNumber++
    Self:aPart1:cPageNumber := PadL(AllTrim(Str(nPageNumber)), 3, "0")

    // Create Part 1 Subsection 1.
    Self:oPart1Subsection1 := RUInsurancePremiumReport2023Part1Sub1():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers)
    Self:oPart1Subsection1:MakeData()
    nPageNumber++
    Self:oPart1Subsection1:cPageNumber1 := PadL(AllTrim(Str(nPageNumber)), 3, "0")
    nPageNumber++
    Self:oPart1Subsection1:cPageNumber2 := PadL(AllTrim(Str(nPageNumber)), 3, "0")

    // Create part 3.
    If !Empty(Self:aPersonnelNumbers) 

        DbSelectArea("SRA")
        DbSetOrder(1) // RA_FILIAL+RA_MAT+RA_NOME

        For nI := 1 To Len(Self:aPersonnelNumbers)
            /* If the employee's dismissal date falls in the last three months of the reporting period 
             * and the date of admission falls in the last month of the reporting period, then the data falls into section 3.
            */
            If SRA->(DbSeek(Self:aPersonnelNumbers[nI][1] + Self:aPersonnelNumbers[nI][2]))
                If (Empty(SRA->RA_DEMISSA) .Or. SubStr(DToS(SRA->RA_DEMISSA), 1, 6) >= Self:aLastMonth[1]) .And. SubStr(DToS(SRA->RA_ADMISSA), 1, 6) <= Self:aPeriods[Len(Self:aPeriods)]
                    Self:oPart3 := RUInsurancePremiumReport2023Part3():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers[nI])
                    Self:oPart3:MakeData()
                    nPageNumber++
                    Self:oPart3:cPageNumber := PadL(AllTrim(Str(nPageNumber)), 3, "0")

                    aAdd(Self:aPart3, Self:oPart3)
                EndIf
            EndIf
        Next nI
    EndIf

    SRA->(DbCloseArea())

    // Write total pages count of report.
    Self:cPageCount := PadL(AllTrim(Str(nPageNumber)), 3, "0")

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return

/*/
{Protheus.doc} MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal)
    Changes the format of the cValue value for the report.

    @type Method
    @params cValue,         Character, Calculated value.
            nMaxLenWhole,   Numeric,   Number of values of integer part.
            nMaxLenDecimal, Numeric,   Number of values of decimal part.
    @author vselyakov
    @since 2021/07/07
    @version 12.1.33
    @return cResult, Character, Value into report format.
    @example ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN)
             ::MakeDataForReport(Str(::aPart2[nI]:nIncomeAmountTotal), 15, 2)
/*/
Method MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal) Class RUInsurancePremiumReport2023
    Local cResult As Character
    Local cTempVar As Character
    Local nDecimalPosition As Numeric
    Local cIntPart As Character
    Local cFractPart As Character
    Local nLenDecimal As Numeric

    Default nMaxLenDecimal := 0

    cTempVar := AllTrim(cValue)
    If nMaxLenDecimal > 0
        nLenDecimal := nMaxLenDecimal + 1
        nDecimalPosition := At(".", cTempVar)

        If nDecimalPosition > 0
            cIntPart := SubStr(cTempVar, 1, nDecimalPosition - 1)
            cFractPart := SubStr(cTempVar, nDecimalPosition, Len(cTempVar) - Len(cIntPart))
        Else
            cIntPart := cTempVar
            cFractPart := "."
        EndIf

        cFractPart := PadR(cFractPart, nLenDecimal, "0")

        If Len(cIntPart) + Len(cFractPart) < nMaxLenWhole
            cResult := PadR(cIntPart, nMaxLenWhole - nLenDecimal, "-") + cFractPart
        Else
            cResult := cIntPart + cFractPart
        EndIf
    ElseIf Len(cTempVar) < nMaxLenWhole
        cResult := PadR(cTempVar, nMaxLenWhole, "-")
    Else
        cResult := cTempVar
    EndIf

Return cResult

/*/
{Protheus.doc} GetViewReport()
    This method generates lines for output to the log.
    This allows you to visually view the generated data on the 6-NDFL report 
    and save them in a PDF document. 

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return 
    @example ::GetViewReport()
            oRu6Ndfl:GetViewReport()
/*/
Method GetViewReport() Class RUInsurancePremiumReport2023
    Local aLogText        As Array
    Local aLogTextPart1   As Array
    Local aLogTextPart2   As Array
    Local aLogTextAttach  As Array
    Local aLogTitleHeader As Array
    Local nI As Numeric
    Local nJ As Numeric

    aLogText        := {}
    aLogTextPart1   := {}
    aLogTextPart2   := {}
    aLogTextAttach  := {}
    aLogTitleHeader := {}

    /*
    *   Insurance premium report. 
    *   Header of report.
    */
    aLogText := { {                                                                                                                          ;
                    STR0055 + " '" + Self:MakeDataForReport(Self:oHeader:cINN, MAX_LEN_INN) + "'"                                                 ,; // "INN".
                    STR0056 + " '" + Self:MakeDataForReport(Self:oHeader:cKPP, MAX_LEN_KPP) + "'"                                                 ,; // "KPP".
                    STR0057 + " '" + Self:MakeDataForReport(Self:oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                                        ,; // "P.".
                    CRLF + STR0058 + CRLF + STR0059 + CRLF                                                                                  ,; // "Form according to KND 1151111", "Calculation of insurance premiums".
                    STR0060 + " '" + Self:MakeDataForReport(Self:oHeader:cCorrectionNumber, MAX_LEN_CORRECTION_NUMBER) + "'"                      ,; // "Adjustment number".
                    STR0061 + " '" + Self:oHeader:cPeriod + "'"                                                                                ,; // "Settlement (reporting) period (code)".
                    STR0062 + " '" + Self:oHeader:cYear + "'"                                                                                  ,; // "Calendar year".
                    STR0063 + " '" + Self:MakeDataForReport(Self:oHeader:cIFNSCode, 4) + "'"                                                      ,; // "Submitted to the tax authority (code)".
                    STR0064 + " '" + Self:MakeDataForReport(Self:oHeader:cCalculationSubmissionCode, 3) + "'"                                     ,; // "At the location (accounting) (code)".
                    STR0065 + " '" + Self:MakeDataForReport(Upper(Self:oHeader:cCompanyName), MAX_LEN_NALOG_AGENT) + "'"               ,; // "Name of company".
                    STR0066 + " '" + Self:MakeDataForReport(AllTrim(Str(Self:oHeader:nEmployeeCount)), MAX_LEN_EMPLOYEE_COUNT) + "'"              ,; // "Average headcount (people)".
                    STR0067 + " '" + Self:MakeDataForReport(Self:oHeader:cOGRNIP, 15) + "'"                                                     ,; // "OKVED2 code".
                    STR0068 + " '" + Self:MakeDataForReport(Self:oHeader:cLiquidationCode, MAX_LEN_LIQUIDATION_CODE) + "'"                        ,; // "Reorganization form (liquidation) (code)".
                    STR0069 + " '" + Self:MakeDataForReport(Self:oHeader:cINNClosedOrganization, MAX_LEN_INN_CLOSED_ORGANIZATION) + " / " + ::MakeDataForReport(::oHeader:cKPPClosedOrganization, MAX_LEN_KPP_CLOSED_ORGANIZATION) + "'" ,; // "TIN / KPP of the reorganized organization / TIN / KPP of termination of powers of a (closed) separate subdivision".
                    STR0070 + " '" + Self:MakeDataForReport(Self:oHeader:cCompanyPhone, MAX_LEN_PHONE_NUMBER) + "'"                               ,; // "Contact phone number".
                    STR0071 + " '" + Self:MakeDataForReport(Self:cPageCount, MAX_LEN_PAGES) + "'" + STR0072 + " 0 " + STR0073                     ,; // "The calculation is based on " + "pages with supporting documents or their copies on" + 0 + "sheets".
                    STR0074                                                                                                                 ,; // "I confirm the accuracy and completeness of the information specified in this calculation:".
                    STR0075 + " '" + AllTrim(Str(Self:oHeader:nResponsiblePersonCategory)) + "'"                                               ,; // "1 - paying insurance premiums; 2 - representative of the payer of insurance premiums".
                    STR0076 + " '" + Self:MakeDataForReport(Upper(Self:oHeader:cSigner), MAX_LEN_SIGNER) + "'"                                    ,; // "Surname, name, patronymic in full".
                    STR0077 + " '" + Upper(Self:MakeDataForReport(Self:oHeader:cRepresentOrganizationName, MAX_LEN_NALOG_AGENT)) + "'" ,; // "Name of the organization - the representative of the payer".
                    STR0078 + " _________________   " + STR0079 + " '" + Self:cDateReport + "'"                                                ,; // "Signature". "date".
                    STR0080 + " '" + Self:MakeDataForReport(Self:oHeader:cRepresentDocument, MAX_LEN_SIGNER_DOCUMENTS) + "'"                       ; // "Name and details of the document confirming the authority of the representative".
                  }                                                                                                                          ; 
                }

    aLogTitleHeader := { STR0059 } // Add title "Calculation of insurance premiums".

    /*
    *   Insurance premium report. 
    *   Chapter 1.
    */
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                                                                   ;
                        Padr("", 10, "") + STR0055 + " '" + Self:MakeDataForReport(Self:oHeader:cINN, MAX_LEN_INN) + "'"                                                                      ,; // "INN".
                        Padr("", 10, "") + STR0056 + " '" + Self:MakeDataForReport(Self:oHeader:cKPP, MAX_LEN_KPP) + "'" + Padr("", 2, "") + STR0057 + " '" + Self:MakeDataForReport(Self:aPart1:cPageNumber, MAX_LEN_PAGES) + "'" ,; // "KPP".
                        CRLF + Padr("", 10, "") + STR0081 + CRLF                                                                                                                           ,; // "Section 1. Summary data on the obligations of the payer of insurance premiums".
                        STR0082 + " 001 '" + Self:aPart1:cPayerType + "'"                                                                                               ,; // Line 001. "Payer type (code)".
                        STR0083 + " 010 '" + Self:MakeDataForReport(Self:oHeader:cOKTMO, 11) + "'"                                                                      ,; // Line 010. "OKTMO code".
                        CRLF                                                                                                                                      ,;
                        Padr("", 10, "") + STR0084                                                                                                                    ,; // "Compulsory pension insurance premiums payable".
                        Padr("", 10, "") + STR0085                                                                                                                    ,; // "Compulsory pension insurance premiums payable".
                        Padr("", 10, "") + STR0086                                                                                                                    ,; // "Compulsory pension insurance premiums payable".
                        CRLF                                                                                                                                      ,;
                        STR0087 + " 020 " + "'" + Self:aPart1:cBudgetClassCode020 + "'"                                                                              ,; // "Budget classification code".
                        STR0088 + " 030 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionSumInsurancePremiums)), 9, 2) + "'"                            ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0089                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 031 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionFirstSumInsurancePremiums)), 9, 2) + "'"                       ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 032 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionSecondSumInsurancePremiums)), 9, 2) + "'"                      ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 033 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionThirdSumInsurancePremiums)), 9, 2) + "'"                       ,; // "third month".
                        CRLF                                                                                                                                      ,;
                        Padr("", 10, "") + STR0094                                                                                                                   ,; // "The amount of insurance premiums for compulsory pension insurance at the additional tariff payable".
                        CRLF                                                                                                                                      ,;
                        STR0087 + " 040 " + "'" + Self:aPart1:cBudgetClassCode040 + "'"                                                                              ,; // "Budget classification code".
                        STR0088 + " 050 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionAdditionalRateSumInsurancePremiums)), 9, 2) + "'"              ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0089                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 051 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionAdditionalRateFirstSumInsurancePremiums)), 9, 2) + "'"         ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 052 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionAdditionalRateSecondSumInsurancePremiums)), 9, 2) + "'"        ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 053 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nPensionAdditionalRateThirdSumInsurancePremiums)), 9, 2) + "'"         ,; // "third month".
                        CRLF                                                                                                                                      ,;
                        Padr("", 10, "") + STR0095                                                                                                                   ,; // "The amount of insurance premiums for supplementary social security payable".
                        CRLF                                                                                                                                      ,;
                        STR0087 + " 060 " + "'" + Self:aPart1:cBudgetClassCode060 + "'"                                                                              ,; // "Budget classification code".
                        STR0088 + " 070 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"       ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0089                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 071 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nFirstSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 072 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nSecondSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'" ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 073 " + "'" + Self:MakeDataForReport(AllTrim(Str(Self:aPart1:nThirdSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"   ; // "third month".
                     }

    aAdd(aLogTextPart1, STR0078 + " _________________   " + STR0079 + " '" + Self:cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)

    /*
    *   Insurance premium report. 
    *   Part 1. Subsection 1.
    */
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                               ;
                        Padr("", 10, "") + STR0055 + " '" + Self:MakeDataForReport(Self:oHeader:cINN, MAX_LEN_INN) + "'"            ,; // "INN".
                        Padr("", 10, "") + STR0056 + " '" + Self:MakeDataForReport(Self:oHeader:cKPP, MAX_LEN_KPP) + "'" + Padr("", 2, "") + STR0057 + " '" + Self:MakeDataForReport(Self:oPart1Subsection1:cPageNumber1, MAX_LEN_PAGES) + "'" ,; // "KPP".
                        CRLF                                                                                                        ,;
                        Padr("", 10, "") + STR0099                                                                                  ,; // "Compulsory pension insurance premiums payable".
                        Padr("", 10, "") + STR0100                                                                                  ,; // "Compulsory pension insurance premiums payable".
                        Padr("", 10, "") + STR0101                                                                                  ,; // "Compulsory pension insurance premiums payable".
                        CRLF                                                                                                        ,;
                        STR0102 + " 001 '" + Self:MakeDataForReport(Self:oPart1Subsection1:cPayerRateCode, 2) + "'"                 ,; // "Payer's rate code".
                        CRLF + STR0104 + " 010 "                                                                                    ,; // "Number of insured persons".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aEmployeeCount[1])), 5) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aEmployeeCount[2])), 5) + "'"        ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aEmployeeCount[3])), 5) + "'"        ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aEmployeeCount[4])), 5) + "'"        ,; // "third month".
                        CRLF + STR0105 + " 020 "                                                                                    ,; // "The number of individuals from whose payments the insurance premiums have been calculated, total (people)".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aIndividualsCount[1])), 5) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aIndividualsCount[2])), 5) + "'"     ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aIndividualsCount[3])), 5) + "'"     ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aIndividualsCount[4])), 5) + "'"     ,; // "third month".
                        CRLF + STR0106 + " 021 "                                                                                    ,; // "including in the amount exceeding the maximum base for calculating insurance contributions for compulsory pension insurance (people)".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoExceedingLimitCount[1])), 5) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoExceedingLimitCount[2])), 5) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoExceedingLimitCount[3])), 5) + "'"  ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoExceedingLimitCount[4])), 5) + "'"  ,; // "third month".
                        CRLF + STR0107 + " 022 "                                                                                    ,; // "including in the amount exceeding the maximum base for calculating insurance contributions for compulsory pension insurance (people)".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aExceedingLimitCount[1])), 5) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aExceedingLimitCount[2])), 5) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aExceedingLimitCount[3])), 5) + "'"  ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aExceedingLimitCount[4])), 5) + "'"  ,; // "third month".
                        CRLF + STR0108 + " 030 "                                                                                    ,; // "The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aAmountArticle420[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aAmountArticle420[2])), 9, 2) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aAmountArticle420[3])), 9, 2) + "'"  ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aAmountArticle420[4])), 9, 2) + "'"  ,; // "third month".
                        CRLF + STR0109 + " 040 "                                                                                    ,; // "Amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a422ArticleAmouts[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0089                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a422ArticleAmouts[2])), 9, 2) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a422ArticleAmouts[3])), 9, 2) + "'"  ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a422ArticleAmouts[4])), 9, 2) + "'"   ; // "third month".
                     }

    aAdd(aLogText, aLogTextPart1)
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                                                ;
                        Padr("", 10, "") + STR0055 + " '" + Self:MakeDataForReport(Self:oHeader:cINN, MAX_LEN_INN) + "'"                                                                      ,; // "INN".
                        Padr("", 10, "") + STR0056 + " '" + Self:MakeDataForReport(Self:oHeader:cKPP, MAX_LEN_KPP) + "'" + Padr("", 2, "") + STR0057 + " '" + Self:MakeDataForReport(Self:oPart1Subsection1:cPageNumber2, MAX_LEN_PAGES) + "'" ,; // "KPP".
                        CRLF + STR0110 + " 045 "                                                                                                     ,; // "The amount of expenses accepted for deduction in accordance with paragraph 8 of Article 421 of the Tax Code of the Russian Federation".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a421ArticleAmouts[1])), 9, 2) + "'"                   ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a421ArticleAmouts[2])), 9, 2) + "'"                   ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a421ArticleAmouts[3])), 9, 2) + "'"                   ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:a421ArticleAmouts[4])), 9, 2) + "'"                   ,; // "third month".
                        CRLF + STR0111 + " 050 "                                                                                                     ,; // "Base for calculating insurance premiums".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aBaseAmoutsInsurancePremium[1])), 9, 2) + "'"         ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aBaseAmoutsInsurancePremium[2])), 9, 2) + "'"         ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aBaseAmoutsInsurancePremium[3])), 9, 2) + "'"         ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aBaseAmoutsInsurancePremium[4])), 9, 2) + "'"         ,; // "third month".
                        CRLF + STR0112 + " 051 "                                                                                                     ,; // "including: in the amount exceeding the maximum value of the base for calculating insurance contributions for compulsory pension insurance".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoOverBaseAmoutsInsurancePremium[1])), 9, 2) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoOverBaseAmoutsInsurancePremium[2])), 9, 2) + "'"     ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoOverBaseAmoutsInsurancePremium[3])), 9, 2) + "'"     ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aNoOverBaseAmoutsInsurancePremium[4])), 9, 2) + "'"     ,; // "third month".
                        CRLF + STR0113 + " 052 "                                                                                                     ,; // "including: in the amount exceeding the maximum value of the base for calculating insurance contributions for compulsory pension insurance".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseAmoutsInsurancePremium[1])), 9, 2) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseAmoutsInsurancePremium[2])), 9, 2) + "'"     ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseAmoutsInsurancePremium[3])), 9, 2) + "'"     ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseAmoutsInsurancePremium[4])), 9, 2) + "'"      ; // "third month".
                     }
    
    aAdd(aLogText, aLogTextPart1)

    aLogTextPart1 := {}
    aLogTextPart1 := {  ;
                        CRLF + STR0114 + " 060 "                                                                                                     ,; // "Calculated insurance premiums".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aInsuracePremiumCalculated[1])), 9, 2) + "'"          ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aInsuracePremiumCalculated[2])), 9, 2) + "'"          ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aInsuracePremiumCalculated[3])), 9, 2) + "'"          ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aInsuracePremiumCalculated[4])), 9, 2) + "'"          ,; // "third month".
                        CRLF + STR0115 + " 061 "                                                                                                     ,; // "including: from a base not exceeding the maximum base size for calculating insurance contributions for compulsory pension insurance".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[1])), 9, 2) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[2])), 9, 2) + "'" ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[3])), 9, 2) + "'" ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[4])), 9, 2) + "'" ,; // "third month".
                        CRLF + STR0116 + " 062 "                                                                                                     ,; // "including: from a base exceeding the maximum base size for calculating insurance premiums for compulsory pension insurance".
                        STR0103 + " 1 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseInsuracePremiumCalculated[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        Padr("", 5, "") + STR0090 + " 2 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseInsuracePremiumCalculated[2])), 9, 2) + "'"  ,; // "first month".
                        Padr("", 5, "") + STR0091 + " 3 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseInsuracePremiumCalculated[3])), 9, 2) + "'"  ,; // "second month".
                        Padr("", 5, "") + STR0092 + " 4 '" + Self:MakeDataForReport(AllTrim(Str(Self:oPart1Subsection1:aOverBaseInsuracePremiumCalculated[4])), 9, 2) + "'"   ; // "third month".
    }
    aAdd(aLogTextPart1, STR0078 + " _________________   " + STR0079 + " '" + Self:cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)

    /*
    *   Insurance premium report. Chapter 3.
    */

    For nI := 1 To Len(Self:aPart3)
        aLogTextPart1 := {}
        aLogTextPart1 := {                                                                                                ;
                            Padr("", 10, "") + STR0055 + " '" + Self:MakeDataForReport(Self:oHeader:cINN, MAX_LEN_INN) + "'" ,; // "INN".
                            Padr("", 10, "") + STR0056 + " '" + Self:MakeDataForReport(Self:oHeader:cKPP, MAX_LEN_KPP) + "'" + Padr("", 2, "") + STR0057 + " '" + Self:MakeDataForReport(Self:aPart3[nI]:cPageNumber, MAX_LEN_PAGES) + "'" ,; // "KPP".
                            CRLF + Padr("", 10, "") + STR0117 + CRLF                                                     ,; // "Section 1. Summary data on the obligations of the payer of insurance premiums".
                            CRLF + STR0118 + " 010 '" + Self:aPart3[nI]:cSignOfCancelation + "'"                         ,; // "Sign of cancellation of information about the insured person".
                            CRLF + STR0119 + CRLF                                                                        ,; // "3.1. Information about the individual in whose favor payments and other remunerations have been accrued".
                            STR0120 + " 020 '" + Self:MakeDataForReport(Self:aPart3[nI]:cINN, MAX_LEN_INN) + "'"         ,; // "INN".
                            STR0121 + " 030 '" + Self:MakeDataForReport(Self:aPart3[nI]:cSNILS, 11) + "'"                ,; // "SNILS".
                            STR0122 + " 040 '" + Self:MakeDataForReport(Self:aPart3[nI]:cSecondName, 35) + "'"           ,; // "Surname".
                            STR0123 + " 050 '" + Self:MakeDataForReport(Self:aPart3[nI]:cFirstName, 35) + "'"            ,; // "Name".
                            STR0124 + " 060 '" + Self:MakeDataForReport(Self:aPart3[nI]:cThirdName, 35) + "'"            ,; // "Patronomic".
                            STR0125 + " 070 '" + Self:aPart3[nI]:cBirthday + "'"                                         ,; // "Date of Birth".
                            STR0126 + " 080 '" + Self:MakeDataForReport(Self:aPart3[nI]:cCountryCode, 3) + "'"           ,; // "Citizenship (country code)".
                            STR0127 + " 090 '" + Self:aPart3[nI]:cGenderCode + "'"                                       ,; // "Gender".
                            STR0128 + " 100 '" + Self:MakeDataForReport(Self:aPart3[nI]:cDocumentCode, 2) + "'"          ,; // "Code of the type of identity document".
                            STR0129 + " 110 '" + Self:MakeDataForReport(Self:aPart3[nI]:cNumberDocumnet, 20) + "'"       ,; // "Series and number".
                            CRLF + STR0130 + CRLF                                                                        ,; // "3.2. Information on the amount of payments and other benefits accrued in favor of an individual, as well as information on the calculated insurance premiums for compulsory pension insurance".
                            STR0131 + CRLF                                                                                ; // "3.2.1. Information on the amount of payments and other remuneration accrued in favor of an individual".
                        }
        
        aAdd(aLogText, aLogTextPart1)

        For nJ := 1 To Len(Self:aPart3[nI]:aAmountInfo)
            aLogTextPart1 := {}
            aLogTextPart1 := {                                                                                                               ;
                                STR0132 + " 120 '" + AllTrim(Str(Self:aPart3[nI]:aAmountInfo[nJ][1])) + "'"                                 ,; // "Month".
                                STR0133 + " 130 '" + Self:aPart3[nI]:aAmountInfo[nJ][3] + "'"                                               ,; // "Insured person category code".
                                STR0134 + " 140 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aAmountInfo[nJ][4])), 9, 2) + "'"   ,; // "Amount of payments and other remuneration".
                                STR0135 + " 150 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aAmountInfo[nJ][5])), 9, 2) + "'"   ,; // "The basis for calculating insurance premiums for compulsory pension insurance within the limit value".
                                STR0136 + " 160 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aAmountInfo[nJ][6])), 9, 2) + "'"   ,; // "including under civil law contracts".
                                STR0137 + " 170 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aAmountInfo[nJ][7])), 9, 2) + "'"   ,; // "The amount of calculated insurance premiums from the base for calculating insurance premiums not exceeding the maximum value".
                                CRLF                                                                                                         ;
                        }
            
            aAdd(aLogText, aLogTextPart1)
        Next nJ

        aAdd(aLogText, {CRLF + STR0138 + CRLF}) // "3.2.2. Information about the basis for calculating insurance premiums, on which insurance premiums are calculated at the additional tariff".
        For nJ := 1 To Len(Self:aPart3[nI]:aBasePremiumsByAdditionalTariff)
            aLogTextPart1 := {}
            aLogTextPart1 := {                                                                                                                            ;
                                STR0139 + " 180 '" + AllTrim(Str(Self:aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][1])) + "'"                             ,; // "Month".
                                STR0140 + " 190 '" + Self:aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][3] + "'"                                           ,; // "Insured person code".
                                STR0141 + " 200 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][4])), 9, 2) + "'"  ,; // "Base for calculating insurance premiums at an additional tariff".
                                STR0142 + " 210 '" + Self:MakeDataForReport(AllTrim(Str(Self:aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][5])), 9, 2) + "'"  ,; // "The amount of calculated insurance premiums".
                                CRLF                                                                                                                      ;
                        }
            
            aAdd(aLogText, aLogTextPart1)
        Next nJ

        aAdd(aLogTextPart1, STR0078 + " _________________   " + STR0079 + " '" + Self:cDateReport + "'") // "date".
    Next nI

    // Execute printing log with report data. fMakeLog - Brazilian function for print log.
    MsAguarde({|| fMakeLog(aLogText, aLogTitleHeader, Nil, Nil, FunName(), STR0053, , , , .F.)}, STR0054) // "Report generation", "Wait".

Return

/*/
{Protheus.doc} GetXMLReport()
    This method generate report in XML document.

    @type Method
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return 
    @example ::GetXMLReport(cSavePath)
/*/
Method GetXMLReport() Class RUInsurancePremiumReport2023
    // Currently, the implementation does not provide for exporting the report to XML. 
    // Therefore, a warning window is displayed.

    Help(,, STR0015,, STR0052, 1, 0) // "Error". "Not implemented".

Return
