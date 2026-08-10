#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R03RUS.CH"

#DEFINE NDFL_BUDGET_CODE "413"
#DEFINE NDFL_RATE_13_PERCENT "13"
#DEFINE NDFL_RATE_15_PERCENT "15"

// Reporting period codes. Table S213.
#DEFINE FIRST_QUARTER_REPORT_PERIOD_CODE "21"
#DEFINE HALF_YEAR_REPORT_PERIOD_CODE     "31"
#DEFINE NINE_MONTH_REPORT_PERIOD_CODE    "33"
#DEFINE ONE_YEAR_REPORT_PERIOD_CODE      "34"
#DEFINE REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE "51"
#DEFINE REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE     "52"
#DEFINE REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE    "53"
#DEFINE REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE      "90"

#DEFINE MAX_LEN_INN 12
#DEFINE MAX_LEN_KPP 9
#DEFINE MAX_LEN_PAGES 3
#DEFINE MAX_LEN_CORRECTION_NUMBER 3
#DEFINE MAX_LEN_OKTMO_CODE 11
#DEFINE MAX_LEN_PHONE_NUMBER 20

#DEFINE MAX_LEN_NALOG_AGENT 160
#DEFINE MAX_LEN_SIGNER 60
#DEFINE MAX_LEN_SIGNER_DOCUMENTS 40

#DEFINE MAX_LEN_LIQUIDATION_CODE 1
#DEFINE MAX_LEN_INN_CLOSED_ORGANIZATION 10
#DEFINE MAX_LEN_KPP_CLOSED_ORGANIZATION 9

#DEFINE MAX_LEN_NUMERIC_VALUE 15
#DEFINE MAX_LEN_DECIMAL_VALUE 2

#DEFINE MAX_LEN_EMPLOYEE 6
#DEFINE MAX_LEN_EMPLOYEE_COUNT 6
#DEFINE MAX_LEN_OKVED 6


/*/
{Protheus.doc} RUInsurancePremiumReport
    Class for generating a Insurance premium report.

    @type Class
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
/*/
Class RUInsurancePremiumReport From LongNameClass
    Data aParameters       As Array     // Array of parameters from pergunte.
    Data cFilter           As Character // Expression for filter.
    Data lFilterOn         As Logical   // Flag of active filter.

    Data cPeriod           As Character // Code of report period (from parameters).
    Data oHeader           As Object    // Info for report header.

    Data aPersonnelNumbers As Array     // Array of personel numbers.
    Data cYear             As Character // Year entered in parameters.
        
    
    Data aPart1            As Array     // Array of objects Ru6NDFLPart1 (Part 1) (for 13% and 15%).
    Data aPart2            As Array     // Array of objects Ru6NDFLPart2 (Part 2) (for 13% and 15%).
    Data aPeriods          As Array     // All selected periods.
    Data aLastMonth        As Array     // Last 3 month from period for Part 1.
    Data lRate13           As Logical   // In selected period exist payments on 13%.
    Data lRate15           As Logical   // In selected period exist payments on 15%.
    Data cPageCount        As Character // Number of pages on which the report is drawn.
    Data cDateReport       As Date      // Report generation date.
    Data aAttachments      As Array     // Array with 2NDFL object.

    Data oPart1Subsection1 As Object // Object for class RUIPRPart1Subsection1.
    Data oPart1Subsection2 As Object // Object for class RUIPRPart1Subsection2.
    Data oPart2            As Object // Object for class RUIPRPart2.
    Data oPart3 As Object
    Data aPart3 As Array

    Method New(aParameters, cFilterExpression) Constructor

    Method GetPersonnelNumbers()
    Method GetPeriods()
    Method GetLastMonthes()
    Method DefineNdflRates(aPeriod)
    Method MakeData()
    Method GetPageCount()

    Method MakeDataForReport()

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New(aParameters, cFilterExpression)
    Default constructor, 

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
    @return RUInsurancePremiumReport, Object, RUInsurancePremiumReport instance.
    @example oRUInsurancePremiumReport := RUInsurancePremiumReport():New(aParameters, cFilterExpression)
/*/
Method New(aParameters, cFilterExpression) Class RUInsurancePremiumReport
    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilterExpression

    If !Empty(::cFilter)
        ::lFilterOn := .T.
        ::aPersonnelNumbers := ::GetPersonnelNumbers()
    Else
        ::lFilterOn := .F.
        ::aPersonnelNumbers := {}
    EndIf

    Self:cPeriod := AllTrim(::aParameters[1])
    Self:cYear := AllTrim(::aParameters[4])

    ::cDateReport := DToC(Date())
    ::aPart3 := {}

Return Self

/*/
{Protheus.doc} GetPersonnelNumbers()
    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RUInsurancePremiumReport
    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character

    aNumbers := {}
    aArea := GetArea()

    cQuery := " SELECT RA_MAT AS EMPLOYNUM FROM " +  RetSQLName("SRA") + " WHERE "
    cQuery += ::cFilter
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        aAdd(aNumbers, (cTab)->EMPLOYNUM)
        DBSkip()
    EndDo

    aSort(aNumbers)

    DBCloseArea()
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
    @example ::aPeriods := ::GetPeriods()
/*/
Method GetPeriods() Class RUInsurancePremiumReport
    Local aPeriods  As Array
    Local nMaxMonth As Numeric
    Local nI        As Numeric

    aPeriods := {}

    Do Case
        Case ::cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            nMaxMonth := 3
        Case ::cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            nMaxMonth := 6
        Case ::cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            nMaxMonth := 9
        Case ::cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            nMaxMonth := 12
        Otherwise
            nMaxMonth := 3
    EndCase

    For nI := 1 To nMaxMonth
        aAdd(aPeriods, ::cYear + StrZero(nI, 2, 0))
    Next nI

Return aPeriods

/*/
{Protheus.doc} GetLastMonthes()
    Return 3 last periods from all periods from GetPeriods() function in format 'YYYYMM'.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return aPeriods, Array, Array of 3 last month in periods format 'YYYYMM' ordered.
    @example ::aLastMonth := ::GetLastMonthes()
/*/
Method GetLastMonthes() Class RUInsurancePremiumReport
    Local aPeriods  As Array
    Local nI        As Numeric

    aPeriods := {}

    If Len(::aPeriods) >= 3
        For nI := Len(::aPeriods) - 2 To Len(::aPeriods)
            aAdd(aPeriods, ::aPeriods[nI])
        Next nI
    EndIf

Return aPeriods

/*/
{Protheus.doc} DefineNdflRates(aPeriod)
    Fill ::lRate13 and ::lRate15 from SRD by input periods array.

    Function execute SQL-query into SRD table on input periods 
    and looking for availability of payments for personal income tax at 13% and 15%.


    @type Method
    @params aPeriod, Array, Array of periods in format 'YYYYMM' ordered.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return 
    @example ::DefineNdflRates(::aLastMonth)
             ::DefineNdflRates(::aPeriods)
/*/
Method DefineNdflRates(aPeriod) Class RUInsurancePremiumReport
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character

    aArea := GetArea()
    aFirstParts := {}
    ::lRate13 := .F.
    ::lRate15 := .F.

    cQuery := " SELECT COUNT(*) AS RESULT FROM " +  RetSQLName("SRD")
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD = ? "
    cQuery += " AND RD_CONVOC = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, aPeriod)
    oStatement:SetString(3, NDFL_BUDGET_CODE)

    // Determination of the existence of payments at a personal income tax rate of 13%.
    oStatement:SetString(4, NDFL_RATE_13_PERCENT)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    ::lRate13 := (cTab)->RESULT > 0

    // Determination of the existence of payments at a personal income tax rate of 15%.
    oStatement:SetString(4, NDFL_RATE_15_PERCENT)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    ::lRate15 := (cTab)->RESULT > 0

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return 
    @example oRu6Ndfl:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport
    Local nPageNumber As Numeric
    Local nI As Numeric
    Local aArea As Array
    Local aSRAArea As Array

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    nPageNumber := 1

    // Get need data for next calculations.
    ::aPeriods := ::GetPeriods()
    ::aLastMonth := ::GetLastMonthes()

    // Create header of report.
    ::oHeader := RuIPRHeader():New(::aParameters, ::cFilter, ::aPersonnelNumbers)
    ::oHeader:MakeData()

    // Create Part 1.
    ::aPart1 := RUIPRPart1():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
    ::aPart1:MakeData()

    // Create Part 1 Subsection 1.
    ::oPart1Subsection1 := RUIPRPart1Subsection1():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
    ::oPart1Subsection1:MakeData()

    // Create Part 1 Subsection 2.
    ::oPart1Subsection2 := RUIPRPart1Subsection2():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
    ::oPart1Subsection2:MakeData()

    // Create Part 2.
    ::oPart2 := RUIPRPart2():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
    ::oPart2:MakeData()

    // Create part 3.
    If !Empty(::aPersonnelNumbers) 

        DbSelectArea("SRA")
        DbSetOrder(1) // RA_FILIAL+RA_MAT+RA_NOME

        For nI := 1 To Len(::aPersonnelNumbers)
            /* If the employee's dismissal date falls in the last three months of the reporting period 
             * and the date of admission falls in the last month of the reporting period, then the data falls into section 3.
            */
            If DbSeek(FwxFilial("SRA") + Self:aPersonnelNumbers[nI], .T.)
                If (Empty(SRA->RA_DEMISSA) .Or. SubStr(DToS(SRA->RA_DEMISSA), 1, 6) >= Self:aLastMonth[1]) .And. SubStr(DToS(SRA->RA_ADMISSA), 1, 6) <= Self:aPeriods[Len(Self:aPeriods)]
                    ::oPart3 := RUIPRPart3():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers[nI])
                    ::oPart3:MakeData()

                    aAdd(::aPart3, ::oPart3)
                EndIf
            EndIf
        Next nI
    EndIf

    RestArea(aSRAArea)
    RestArea(aArea)

Return

/*/
{Protheus.doc} GetPageCount()
    Calculate count of report pages.
    Make format as "000".

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/07
    @version 12.1.33
    @return cPages, Character, Count of report pages in format "000".
    @example ::cPageCount := GetPageCount()
/*/
Method GetPageCount() Class RUInsurancePremiumReport
    Local nPages As Numeric
    Local cPages As Character

    nPages := 1 // Because object Header exists always.

    nPages += Len(::aPart1)
    nPages += Len(::aPart2)

    cPages := AllTrim(Str(nPages))

Return cPages

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
Method MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal) Class RUInsurancePremiumReport
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
Method GetViewReport() Class RUInsurancePremiumReport
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
                    STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                                 ,; // "INN".
                    STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                                 ,; // "KPP".
                    STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                                        ,; // "P.".
                    CRLF + STR0020 + CRLF + STR0021 + CRLF                                                                                  ,; // "Form according to KND 1151111", "Calculation of insurance premiums".
                    STR0022 + " '" + ::MakeDataForReport(::oHeader:cCorrectionNumber, MAX_LEN_CORRECTION_NUMBER) + "'"                      ,; // "Adjustment number".
                    STR0023 + " '" + ::oHeader:cPeriod + "'"                                                                                ,; // "Settlement (reporting) period (code)".
                    STR0024 + " '" + ::oHeader:cYear + "'"                                                                                  ,; // "Calendar year".
                    STR0025 + " '" + ::MakeDataForReport(::oHeader:cIFNSCode, 4) + "'"                                                      ,; // "Submitted to the tax authority (code)".
                    STR0026 + " '" + ::MakeDataForReport(::oHeader:cCalculationSubmissionCode, 3) + "'"                                     ,; // "At the location (accounting) (code)".
                    STR0027 + " '" + ::MakeDataForReport(Upper(OemToAnsi(::oHeader:cCompanyName)), MAX_LEN_NALOG_AGENT) + "'"               ,; // "Name of company".
                    STR0028 + " '" + ::MakeDataForReport(AllTrim(Str(::oHeader:nEmployeeCount)), MAX_LEN_EMPLOYEE_COUNT) + "'"              ,; // "Average headcount (people)".
                    STR0029 + " '" + ::MakeDataForReport(::oHeader:cOKVEDCode, 8) + "'"                                                     ,; // "OKVED2 code".
                    STR0030 + " '" + ::MakeDataForReport(::oHeader:cLiquidationCode, MAX_LEN_LIQUIDATION_CODE) + "'"                        ,; // "Reorganization form (liquidation) (code)".
                    STR0031 + " '" + ::MakeDataForReport(::oHeader:cINNClosedOrganization, MAX_LEN_INN_CLOSED_ORGANIZATION) + " / " + ::MakeDataForReport(::oHeader:cKPPClosedOrganization, MAX_LEN_KPP_CLOSED_ORGANIZATION) + "'" ,; // "TIN / KPP of the reorganized organization / TIN / KPP of termination of powers of a (closed) separate subdivision".
                    STR0032 + " '" + ::MakeDataForReport(::oHeader:cCompanyPhone, MAX_LEN_PHONE_NUMBER) + "'"                               ,; // "Contact phone number".
                    STR0033 + " '" + ::MakeDataForReport(::cPageCount, MAX_LEN_PAGES) + "'" + STR0034 + " 0 " + STR0035                     ,; // "The calculation is based on " + "pages with supporting documents or their copies on" + 0 + "sheets".
                    STR0036                                                                                                                 ,; // "I confirm the accuracy and completeness of the information specified in this calculation:".
                    STR0037 + " '" + AllTrim(Str(::oHeader:nResponsiblePersonCategory)) + "'"                                               ,; // "1 - paying insurance premiums; 2 - representative of the payer of insurance premiums".
                    STR0038 + " '" + ::MakeDataForReport(Upper(::oHeader:cSigner), MAX_LEN_SIGNER) + "'"                                    ,; // "Surname, name, patronymic in full".
                    STR0039 + " '" + Upper(OemToAnsi(::MakeDataForReport(::oHeader:cRepresentOrganizationName, MAX_LEN_NALOG_AGENT))) + "'" ,; // "Name of the organization - the representative of the payer".
                    STR0040 + " _________________   " + STR0041 + " '" + ::cDateReport + "'"                                                ,; // "Signature". "date".
                    STR0042 + " '" + ::MakeDataForReport(::oHeader:cRepresentDocument, MAX_LEN_SIGNER_DOCUMENTS) + "'"                       ; // "Name and details of the document confirming the authority of the representative".
                  }                                                                                                                          ; 
                }

    aLogTitleHeader := { STR0021 } // Add title "Calculation of insurance premiums".

    /*
    *   Insurance premium report. 
    *   Chapter 1.
    */
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                                                             ;
                        STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                                                   ,; // "INN".
                        STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                                                   ,; // "KPP".
                        STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                                                          ,; // "P.".
                        CRLF + STR0043 + CRLF                                                                                                                     ,; // "Section 1. Summary data on the obligations of the payer of insurance premiums".
                        STR0044 + " 001 '" + ::aPart1:cPayerType + "'"                                                                                            ,; // "Payer type (code)".
                        STR0045 + " 002 '" + ::MakeDataForReport(::oHeader:cOKTMO, 11) + "'"                                                                      ,; // "OKTMO code".
                        CRLF                                                                                                                                      ,;
                        "***" + STR0046 + "***"                                                                                                                   ,; // "Compulsory pension insurance premiums payable".
                        STR0047 + " 020 " + "'" + ::aPart1:cBudgetClassCode020 + "'"                                                                              ,; // "Budget classification code".
                        STR0048 + " 030 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionSumInsurancePremiums)), 9, 2) + "'"                            ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0049                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 031 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionFirstSumInsurancePremiums)), 9, 2) + "'"                       ,; // "first month".
                        STR0051 + " 032 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionSecondSumInsurancePremiums)), 9, 2) + "'"                      ,; // "second month".
                        STR0052 + " 033 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionThirdSumInsurancePremiums)), 9, 2) + "'"                       ,; // "third month".
                        CRLF                                                                                                                                      ,;
                        "***" + STR0053 + "***"                                                                                                                   ,; // "Compulsory health insurance premiums payable".
                        STR0047 + " 040 " + "'" + ::aPart1:cBudgetClassCode040 + "'"                                                                              ,; // "Budget classification code".
                        STR0048 + " 050 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nHealthSumInsurancePremiums)), 9, 2) + "'"                             ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0049                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 051 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nHealthFirstSumInsurancePremiums)), 9, 2) + "'"                        ,; // "first month".
                        STR0051 + " 052 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nHealthSecondSumInsurancePremiums)), 9, 2) + "'"                       ,; // "second month".
                        STR0052 + " 053 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nHealthThirdSumInsurancePremiums)), 9, 2) + "'"                        ,; // "third month".
                        CRLF                                                                                                                                      ,;
                        "***" + STR0054 + "***"                                                                                                                   ,; // "The amount of insurance premiums for compulsory pension insurance at the additional tariff payable".
                        STR0047 + " 060 " + "'" + ::aPart1:cBudgetClassCode060 + "'"                                                                              ,; // "Budget classification code".
                        STR0048 + " 070 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionAdditionalRateSumInsurancePremiums)), 9, 2) + "'"              ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0049                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 071 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionAdditionalRateFirstSumInsurancePremiums)), 9, 2) + "'"         ,; // "first month".
                        STR0051 + " 072 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionAdditionalRateSecondSumInsurancePremiums)), 9, 2) + "'"        ,; // "second month".
                        STR0052 + " 073 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nPensionAdditionalRateThirdSumInsurancePremiums)), 9, 2) + "'"         ,; // "third month".
                        CRLF                                                                                                                                      ,;
                        "***" + STR0055 + "***"                                                                                                                   ,; // "The amount of insurance premiums for supplementary social security payable".
                        STR0047 + " 080 " + "'" + ::aPart1:cBudgetClassCode080 + "'"                                                                              ,; // "Budget classification code".
                        STR0048 + " 090 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"       ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0049                                                                                                                                   ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 091 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nFirstSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"  ,; // "first month".
                        STR0051 + " 092 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nSecondSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 093 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nThirdSupplementarySocialProvisionSumInsurancePremiums)), 9, 2) + "'"   ; // "third month".
                     }
    aAdd(aLogText, aLogTextPart1)
    aLogTextPart1 := {}
    aLogTextPart1 := {                                                                                                                                         ;
                        CRLF                                                                                                                                  ,;
                        STR0047 + " 100 " + "'" + ::aPart1:cBudgetClassCode100 + "'"                                                                          ,; // "Budget classification code".
                        CRLF                                                                                                                                  ,;
                        "***" + STR0056 + "***"                                                                                                               ,; // "The amount of insurance contributions for compulsory social insurance in case of temporary disability and in connection with maternity payable".
                        STR0048 + " 110 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nTemporaryDisabilitySumInsurancePremiums)), 9, 2) + "'"            ,; // "The amount of insurance premiums payable for the billing (reporting) period".
                        STR0049                                                                                                                               ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 111 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nFirstTemporaryDisabilitySumInsurancePremiums)), 9, 2) + "'"       ,; // "first month".
                        STR0051 + " 112 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nSecondTemporaryDisabilitySumInsurancePremiums)), 9, 2) + "'"      ,; // "second month".
                        STR0052 + " 113 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nThirdTemporaryDisabilitySumInsurancePremiums)), 9, 2) + "'"       ,; // "third month".
                        CRLF                                                                                                                                  ,;
                        "***" + STR0057 + "***"                                                                                                               ,; // "The amount of the excess by the payer of the costs of payment of insurance coverage over the calculated insurance contributions for compulsory social insurance in case of temporary disability and in connection with motherhood".
                        STR0058 + " 120 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nExcessCostsPayerIncurredSumInsurancePremiums)), 9, 2) + "'"       ,; // "The amount of excess expenses over calculated insurance premiums for the settlement (reporting) period".
                        STR0049                                                                                                                               ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 121 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nFirstExcessCostsPayerIncurredySumInsurancePremiums)), 9, 2) + "'" ,; // "first month".
                        STR0051 + " 122 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nSecondExcessCostsPayerIncurredSumInsurancePremiums)), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 123 " + "'" + ::MakeDataForReport(AllTrim(Str(::aPart1:nThirdExcessCostsPayerIncurredSumInsurancePremiums)), 9, 2) + "'"   ; // "third month".
                     }

    aAdd(aLogTextPart1, STR0041 + " '" + ::cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)

    /*
    *   Insurance premium report. 
    *   Chapter 1. Application 2. Subsection 1.
    */
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                               ;
                        STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                     ,; // "INN".
                        STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                     ,; // "KPP".
                        STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                            ,; // "P.".
                        CRLF + STR0064 + CRLF                                                                                       ,; // "Appendix 1 Calculation of the amounts of insurance contributions for compulsory pension insurance and compulsory health insurance to section 1".
                        STR0065 + " 001 '" + ::MakeDataForReport(::oPart1Subsection1:cPayerRateCode, 2) + "'"                       ,; // "Payer's rate code".
                        CRLF + STR0066 + CRLF                                                                                       ,; // "Subsection 1.1 Calculation of the amounts of insurance contributions for compulsory pension insuranc".
                        CRLF + STR0068 + " 010 "                                                                                    ,; // "Number of insured persons".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aEmployeeCount[1])), 5) + "'"        ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aEmployeeCount[2])), 5) + "'"        ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aEmployeeCount[3])), 5) + "'"        ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aEmployeeCount[4])), 5) + "'"        ,; // "third month".
                        CRLF + STR0069 + " 020 "                                                                                    ,; // "The number of individuals from whose payments the insurance premiums have been calculated, total (people)".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aIndividualsCount[1])), 5) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aIndividualsCount[2])), 5) + "'"     ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aIndividualsCount[3])), 5) + "'"     ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aIndividualsCount[4])), 5) + "'"     ,; // "third month".
                        CRLF + STR0070 + " 021 "                                                                                    ,; // "including in the amount exceeding the maximum base for calculating insurance contributions for compulsory pension insurance (people)".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aExceedingLimitCount[1])), 5) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aExceedingLimitCount[2])), 5) + "'"  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aExceedingLimitCount[3])), 5) + "'"  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aExceedingLimitCount[4])), 5) + "'"  ,; // "third month".
                        CRLF + STR0071 + " 030 "                                                                                    ,; // "The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aAmountArticle420[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aAmountArticle420[2])), 9, 2) + "'"  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aAmountArticle420[3])), 9, 2) + "'"  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aAmountArticle420[4])), 9, 2) + "'"  ,; // "third month".
                        CRLF + STR0072 + " 040 "                                                                                    ,; // "Amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a422ArticleAmouts[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a422ArticleAmouts[2])), 9, 2) + "'"  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a422ArticleAmouts[3])), 9, 2) + "'"  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a422ArticleAmouts[4])), 9, 2) + "'"   ; // "third month".
                     }

    aAdd(aLogText, aLogTextPart1)
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                                                ;
                        CRLF + STR0073 + " 045 "                                                                                                     ,; // "The amount of expenses accepted for deduction in accordance with paragraph 8 of Article 421 of the Tax Code of the Russian Federation".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a421ArticleAmouts[1])), 9, 2) + "'"                   ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a421ArticleAmouts[2])), 9, 2) + "'"                   ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a421ArticleAmouts[3])), 9, 2) + "'"                   ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:a421ArticleAmouts[4])), 9, 2) + "'"                   ,; // "third month".
                        CRLF + STR0074 + " 050 "                                                                                                     ,; // "Base for calculating insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aBaseAmoutsInsurancePremium[1])), 9, 2) + "'"         ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aBaseAmoutsInsurancePremium[2])), 9, 2) + "'"         ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aBaseAmoutsInsurancePremium[3])), 9, 2) + "'"         ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aBaseAmoutsInsurancePremium[4])), 9, 2) + "'"         ,; // "third month".
                        CRLF + STR0075 + " 051 "                                                                                                     ,; // "including: in the amount exceeding the maximum value of the base for calculating insurance contributions for compulsory pension insurance".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseAmoutsInsurancePremium[1])), 9, 2) + "'"     ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseAmoutsInsurancePremium[2])), 9, 2) + "'"     ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseAmoutsInsurancePremium[3])), 9, 2) + "'"     ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseAmoutsInsurancePremium[4])), 9, 2) + "'"     ,; // "third month".
                        CRLF + STR0076 + " 060 "                                                                                                     ,; // "Calculated insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aInsuracePremiumCalculated[1])), 9, 2) + "'"          ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aInsuracePremiumCalculated[2])), 9, 2) + "'"          ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aInsuracePremiumCalculated[3])), 9, 2) + "'"          ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aInsuracePremiumCalculated[4])), 9, 2) + "'"          ,; // "third month".
                        CRLF + STR0077 + " 061 "                                                                                                     ,; // "including: from a base not exceeding the maximum base size for calculating insurance contributions for compulsory pension insurance".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[1])), 9, 2) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[2])), 9, 2) + "'" ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[3])), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aUnderBaseInsuracePremiumCalculated[4])), 9, 2) + "'" ,; // "third month".
                        CRLF + STR0078 + " 062 "                                                                                                     ,; // "including: from a base exceeding the maximum base size for calculating insurance premiums for compulsory pension insurance".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseInsuracePremiumCalculated[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                                      ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseInsuracePremiumCalculated[2])), 9, 2) + "'"  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseInsuracePremiumCalculated[3])), 9, 2) + "'"  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection1:aOverBaseInsuracePremiumCalculated[4])), 9, 2) + "'"   ; // "third month".
                     }


    aAdd(aLogTextPart1, STR0041 + " '" + ::cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)

    /*
    *   Insurance premium report. 
    *   Chapter 1. Application 2. Subsection 2.
    */
    aLogTextPart1 := {}

    aLogTextPart1 := {                                                                                                           ;
                        STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                 ,; // "INN".
                        STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                 ,; // "KPP".
                        STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                        ,; // "P.".                        
                        CRLF + STR0079 + CRLF                                                                                   ,; // "Subsection 1.2 Calculation of the amounts of insurance premiums for compulsory health insurance".
                        CRLF + STR0068 + " 010 "                                                                                ,; // "Number of insured persons".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aEmployeeCount[1])), 5) + "'"    ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                 ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aEmployeeCount[2])), 5) + "'"    ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aEmployeeCount[3])), 5) + "'"    ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aEmployeeCount[4])), 5) + "'"    ,; // "third month".     
                        CRLF + STR0069 + " 020 "                                                                                ,; // "The number of individuals from whose payments the insurance premiums have been calculated, total (people)".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aIndividualsCount[1])), 5) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                 ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aIndividualsCount[2])), 5) + "'" ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aIndividualsCount[3])), 5) + "'" ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aIndividualsCount[4])), 5) + "'"  ; // "third month"
                     }
    
    aAdd(aLogText, aLogTextPart1)
    aLogTextPart1 := {}
    aLogTextPart1 := {                                                                                                                        ;
                        CRLF + STR0071 + " 030 "                                                                                             ,; // "The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aAmountArticle420[1])), 9, 2) + "'"           ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                              ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aAmountArticle420[2])), 9, 2) + "'"           ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aAmountArticle420[3])), 9, 2) + "'"           ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aAmountArticle420[4])), 9, 2) + "'"           ,; // "third month".
                        CRLF + STR0072 + " 040 "                                                                                             ,; // "Amount not subject to insurance premiums in accordance with Article 422 of the Tax Code of the Russian Federation and international treaties".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a422ArticleAmouts[1])), 9, 2) + "'"           ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                              ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a422ArticleAmouts[2])), 9, 2) + "'"           ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a422ArticleAmouts[3])), 9, 2) + "'"           ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a422ArticleAmouts[4])), 9, 2) + "'"           ,; // "third month".
                        CRLF + STR0073 + " 045 "                                                                                             ,; // "The amount of expenses accepted for deduction in accordance with paragraph 8 of Article 421 of the Tax Code of the Russian Federation".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a421ArticleAmouts[1])), 9, 2) + "'"           ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                              ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a421ArticleAmouts[2])), 9, 2) + "'"           ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a421ArticleAmouts[3])), 9, 2) + "'"           ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:a421ArticleAmouts[4])), 9, 2) + "'"           ,; // "third month".
                        CRLF + STR0074 + " 050 "                                                                                             ,; // "Base for calculating insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aBaseAmoutsInsurancePremium[1])), 9, 2) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                              ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aBaseAmoutsInsurancePremium[2])), 9, 2) + "'" ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aBaseAmoutsInsurancePremium[3])), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aBaseAmoutsInsurancePremium[4])), 9, 2) + "'" ,; // "third month".
                        CRLF + STR0076 + " 060 "                                                                                             ,; // "Calculated insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aInsuracePremiumCalculated[1])), 9, 2) + "'"  ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                              ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aInsuracePremiumCalculated[2])), 9, 2) + "'"  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aInsuracePremiumCalculated[3])), 9, 2) + "'"  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart1Subsection2:aInsuracePremiumCalculated[4])), 9, 2) + "'"   ; // "third month".
    }

    aAdd(aLogTextPart1, STR0041 + " '" + ::cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)


    /*
    *   Insurance premium report. 
    *   Chapter 1. Application 2.
    */
    aLogTextPart1 := {}
    aLogTextPart1 := {                                                                                                                 ;
                        STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                       ,; // "INN".
                        STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                       ,; // "KPP".
                        STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                              ,; // "P.".
                        CRLF + STR0080 + CRLF                                                                                         ,; // "Appendix 2 Calculation of the amounts of insurance contributions for compulsory social insurance in case of temporary disability and in connection with maternity to section 1".
                        STR0081 + " 001 '" + ::MakeDataForReport(::oPart2:cPayerRateCode, 2) + "'"                                    ,; // "Payers rate code".
                        STR0082 + " 002 '" + ::MakeDataForReport(::oPart2:cPayoutAttribute, 1) + "'"                                  ,; // "Sign of payments".
                        CRLF + STR0083 + " 010 "                                                                                      ,; // "Number of insured persons".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aEmployeeCount[1])), 5) + "'"                     ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                       ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aEmployeeCount[2])), 5) + "'"                     ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aEmployeeCount[3])), 5) + "'"                     ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aEmployeeCount[4])), 5) + "'"                     ,; // "third month".
                        CRLF + STR0084 + " 015 "                                                                                      ,; // "The number of individuals from whose payments the insurance premiums have been calculated, total (people)".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aIndividualsCount[1])), 5) + "'"                  ,; // "TThe number of individuals from whose payments the insurance premiums have been calculated".
                        STR0049                                                                                                       ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aIndividualsCount[2])), 5) + "'"                  ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aIndividualsCount[3])), 5) + "'"                  ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aIndividualsCount[4])), 5) + "'"                  ,; // "third month".
                        CRLF + STR0085 + " 020 "                                                                                      ,; // "The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 420 of the Tax Code of the Russian Federation".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountArticle420[1])), 9, 2) + "'"               ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                       ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountArticle420[2])), 9, 2) + "'"               ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountArticle420[3])), 9, 2) + "'"               ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountArticle420[4])), 9, 2) + "'"               ,; // "third month".
                        CRLF + STR0086 + " 030 "                                                                                      ,; // "Amount not subject to insurance premiums in accordance with Article 422 of the Tax".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:a422ArticleAmouts[1])), 9, 2) + "'"               ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                       ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:a422ArticleAmouts[2])), 9, 2) + "'"               ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:a422ArticleAmouts[3])), 9, 2) + "'"               ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:a422ArticleAmouts[4])), 9, 2) + "'"               ,; // "third month".
                        CRLF + STR0087 + " 040 "                                                                                      ,; // "Amount in excess of the maximum base for calculating insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aOverBaseAmountInsurancePremium[1])), 9, 2) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                       ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aOverBaseAmountInsurancePremium[2])), 9, 2) + "'" ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aOverBaseAmountInsurancePremium[3])), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aOverBaseAmountInsurancePremium[4])), 9, 2) + "'"  ; // "third month".
                     }

    aAdd(aLogText, aLogTextPart1)
    aLogTextPart1 := {}
    aLogTextPart1 := {                                                                                                               ;
                        CRLF + STR0088 + " 050 "                                                                                    ,; // "Base for calculating insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aBaseAmountInsurancePremium[1])), 9, 2) + "'"   ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aBaseAmountInsurancePremium[2])), 9, 2) + "'"   ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aBaseAmountInsurancePremium[3])), 9, 2) + "'"   ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aBaseAmountInsurancePremium[4])), 9, 2) + "'"   ,; // "third month".
                        CRLF + Subs(STR0089, 1, 163) + CRLF + Subs(STR0089, 164, 73) + " 055 "                                      ,; // "Of these, the amount of payments and other remuneration accrued in favor of foreign citizens and stateless persons temporarily staying in the Russian Federation, except for persons who are citizens of the member states of the Eurasian Economic Union".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountAccruedForeign[1])), 9, 2) + "'"         ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountAccruedForeign[2])), 9, 2) + "'"         ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountAccruedForeign[3])), 9, 2) + "'"         ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aAmountAccruedForeign[4])), 9, 2) + "'"         ,; // "third month".
                        CRLF + STR0090 + " 060 "                                                                                    ,; // "Calculated insurance premiums".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuracePremiumCalculated[1])), 9, 2) + "'"    ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuracePremiumCalculated[2])), 9, 2) + "'"    ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuracePremiumCalculated[3])), 9, 2) + "'"    ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuracePremiumCalculated[4])), 9, 2) + "'"    ,; // "third month".
                        CRLF + STR0091 + " 070 "                                                                                    ,; // "Costs incurred for payment of insurance coverage".
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuranceCoverageCosts[1])), 9, 2) + "'"       ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuranceCoverageCosts[2])), 9, 2) + "'"       ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuranceCoverageCosts[3])), 9, 2) + "'"       ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aInsuranceCoverageCosts[4])), 9, 2) + "'"       ,; // "third month".
                        CRLF + STR0092 + " 080 "                                                                                    ,; // "FSS reimbursed the costs of paying insurance coverage."
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aReimbursedSIFExpenses[1])), 9, 2) + "'"        ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aReimbursedSIFExpenses[2])), 9, 2) + "'"        ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aReimbursedSIFExpenses[3])), 9, 2) + "'"        ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aReimbursedSIFExpenses[4])), 9, 2) + "'"        ,; // "third month".
                        CRLF + STR0093 + " 090 "                                                                                    ,; // "The amount of insurance premiums payable (the amount of excess of the expenses incurred over the calculated insurance premiums)."
                        STR0067 + " 1 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aPayableAmountInsuracePremium[1])), 9, 2) + "'" ,; // "Total since the beginning of the billing period".
                        STR0049                                                                                                     ,; // "including for the last three months of the billing (reporting) period:".
                        STR0050 + " 2 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aPayableAmountInsuracePremium[2])), 9, 2) + "'" ,; // "first month".
                        STR0051 + " 3 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aPayableAmountInsuracePremium[3])), 9, 2) + "'" ,; // "second month".
                        STR0052 + " 4 '" + ::MakeDataForReport(AllTrim(Str(::oPart2:aPayableAmountInsuracePremium[4])), 9, 2) + "'"  ; // "third month".
                     }

    aAdd(aLogTextPart1, STR0041 + " '" + ::cDateReport + "'") // "date".
    aAdd(aLogText, aLogTextPart1)

    /*
    *   Insurance premium report. Chapter 3.
    */

    // Add title of Prat 3.
    aLogTextPart1 := {CRLF + STR0094 + CRLF} // // "Section 3. Personalized information about the insured persons".
    aAdd(aLogText, aLogTextPart1)

    For nI := 1 To Len(::aPart3)
        aLogTextPart1 := {}
        aLogTextPart1 := {                                                                                                ;
                            STR0017 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                      ,; // "INN".
                            STR0018 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                      ,; // "KPP".
                            STR0019 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"             ,; // "P.".
                            CRLF + STR0095 + " 010 '" + ::aPart3[nI]:cSignOfCancelation + "'"                            ,; // "Sign of cancellation of information about the insured person".
                            CRLF + STR0096 + CRLF                                                                        ,; // "3.1. Information about the individual in whose favor payments and other remunerations have been accrued".
                            STR0097 + " 020 '" + ::MakeDataForReport(::aPart3[nI]:aEmployeeInfo[1], MAX_LEN_INN) + "'"   ,; // "INN".
                            STR0098 + " 030 '" + ::MakeDataForReport(::aPart3[nI]:aEmployeeInfo[2], 11) + "'"            ,; // "SNILS".
                            STR0099 + " 040 '" + ::aPart3[nI]:aEmployeeInfo[3] + "'"                                     ,; // "Surname".
                            STR0100 + " 050 '" + ::aPart3[nI]:aEmployeeInfo[4] + "'"                                     ,; // "Name".
                            STR0101 + " 060 '" + ::aPart3[nI]:aEmployeeInfo[5] + "'"                                     ,; // "Patronomic".
                            STR0102 + " 070 '" + ::aPart3[nI]:aEmployeeInfo[6] + "'"                                     ,; // "Date of Birth".
                            STR0103 + " 080 '" + ::MakeDataForReport(::aPart3[nI]:aEmployeeInfo[7], 3) + "'"             ,; // "Citizenship (country code)".
                            STR0104 + " 090 '" + ::aPart3[nI]:aEmployeeInfo[8] + "'"                                     ,; // "Gender".
                            STR0105 + " 100 '" + ::MakeDataForReport(::aPart3[nI]:aEmployeeInfo[9], 2) + "'"             ,; // "Code of the type of identity document".
                            STR0106 + " 110 '" + ::MakeDataForReport(::aPart3[nI]:aEmployeeInfo[10], 20) + "'"           ,; // "Series and number".
                            CRLF + STR0107 + CRLF                                                                        ,; // "3.2. Information on the amount of payments and other benefits accrued in favor of an individual, as well as information on the calculated insurance premiums for compulsory pension insurance".
                            STR0108 + CRLF                                                                                ; // "3.2.1. Information on the amount of payments and other remuneration accrued in favor of an individual".
                        }
        
        aAdd(aLogText, aLogTextPart1)

        For nJ := 1 To Len(::aPart3[nI]:aAmountInfo)
            aLogTextPart1 := {}
            aLogTextPart1 := {                                                                                                         ;
                                STR0109 + " 120 '" + AllTrim(Str(::aPart3[nI]:aAmountInfo[nJ][1])) + "'"                              ,; // "Month".
                                STR0110 + " 130 '" + ::aPart3[nI]:aAmountInfo[nJ][3] + "'"                                            ,; // "Insured person category code".
                                STR0111 + " 140 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aAmountInfo[nJ][4])), 9, 2) + "'"   ,; // "Amount of payments and other remuneration".
                                STR0112 + " 150 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aAmountInfo[nJ][5])), 9, 2) + "'"   ,; // "The basis for calculating insurance premiums for compulsory pension insurance within the limit value".
                                STR0113 + " 160 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aAmountInfo[nJ][6])), 9, 2) + "'"   ,; // "including under civil law contracts".
                                STR0114 + " 170 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aAmountInfo[nJ][7])), 9, 2) + "'"   ,; // "The amount of calculated insurance premiums from the base for calculating insurance premiums not exceeding the maximum value".
                                CRLF                                                                                                   ;
                        }
            
            aAdd(aLogText, aLogTextPart1)
        Next nJ

        aAdd(aLogText, {CRLF + STR0115 + CRLF}) // "3.2.2. Information about the basis for calculating insurance premiums, on which insurance premiums are calculated at the additional tariff".
        For nJ := 1 To Len(::aPart3[nI]:aBasePremiumsByAdditionalTariff)
            aLogTextPart1 := {}
            aLogTextPart1 := {                                                                                                                            ;
                                STR0116 + " 180 '" + AllTrim(Str(::aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][1])) + "'"                             ,; // "Month".
                                STR0117 + " 190 '" + ::aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][3] + "'"                                           ,; // "Insured person code".
                                STR0118 + " 200 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][4])), 9, 2) + "'"  ,; // "Base for calculating insurance premiums at an additional tariff".
                                STR0119 + " 210 '" + ::MakeDataForReport(AllTrim(Str(::aPart3[nI]:aBasePremiumsByAdditionalTariff[nJ][5])), 9, 2) + "'"  ,; // "The amount of calculated insurance premiums".
                                CRLF                                                                                                                      ;
                        }
            
            aAdd(aLogText, aLogTextPart1)
        Next nJ

        aAdd(aLogTextPart1, STR0041 + " '" + ::cDateReport + "'") // "date".
    Next nI

    // Execute printing log with report data. fMakeLog - Brazilian function for print log.
    MsAguarde({|| fMakeLog(aLogText, aLogTitleHeader, Nil, Nil, FunName(), STR0059, , , , .F.)}, STR0060) // "Report generation", "Wait".

Return

/*/
{Protheus.doc} GetXMLReport(cDocSavePath)
    This method generate report in XML document.

    @type Method
    @params cDocSavePath,  Character, Path to save result document into XML format.
    @author vselyakov
    @since 2021/07/09
    @version 12.1.33
    @return 
    @example ::GetXMLReport(cSavePath)
/*/
Method GetXMLReport(cDocSavePath) Class RUInsurancePremiumReport
    // Currently, the implementation does not provide for exporting the report to XML. 
    // Therefore, a warning window is displayed.

    Help(,, STR0015,, STR0016, 1, 0) // "Error". "Not implemented".

Return
