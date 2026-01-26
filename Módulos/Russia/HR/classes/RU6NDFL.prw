#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R02RUS.CH"

#Define NDFL_BUDGET_CODE "413"

#Define STATUS_CLOSED_SALARY_PERIOD "5"

#Define TYPE_OF_PAYMENT_INCOME "1"

#Define MAX_LEN_INN 12
#Define MAX_LEN_KPP 9
#Define MAX_LEN_PAGES 3
#Define MAX_LEN_CORRECTION_NUMBER 3
#Define MAX_LEN_OKTMO_CODE 11
#Define MAX_LEN_PHONE_NUMBER 20

#Define MAX_LEN_NALOG_AGENT 160
#Define MAX_LEN_SIGNER 60
#Define MAX_LEN_SIGNER_DOCUMENTS 40

#DEFINE MAX_LEN_LIQUIDATION_CODE 1
#DEFINE MAX_LEN_INN_CLOSED_ORGANIZATION 10
#DEFINE MAX_LEN_KPP_CLOSED_ORGANIZATION 9

#Define MAX_LEN_NUMERIC_VALUE 15
#Define MAX_LEN_DECIMAL_VALUE 2

#Define MAX_LEN_EMPLOYEE 6

#Define YEAR_PERIODS "34|90"

#Define TAXABLE_PERIOD { {"21", "0101-0122", "0123-0222", "0223-0322", "000000000"},;
                         {"31", "0323-0422", "0423-0522", "0523-0622", "000000000"},;
                         {"33", "0623-0722", "0723-0822", "0823-0922", "000000000"},;
                         {"34", "0923-1022", "1023-1122", "1123-1222", "1223-1231"},;
                         {"51", "0101-0122", "0123-0222", "0223-0322", "000000000"},;
                         {"52", "0323-0422", "0423-0522", "0523-0622", "000000000"},;
                         {"53", "0623-0722", "0723-0822", "0823-0922", "000000000"},;
                         {"90", "0923-1022", "1023-1122", "1123-1222", "1223-1231"}}

/*/
{Protheus.doc} RU6NDFL
    Class for generating a report 6-NDFL.

    @type Class
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
/*/
Class RU6NDFL From LongNameClass
    Data aParameters       As Array     // Array of parameters from pergunte.
    Data cFilter           As Character // Expression for filter.
    Data lFilterOn         As Logical   // Flag of active filter.
    Data aPersonnelNumbers As Array     // Array of personel numbers.
    Data cYear             As Character // Year entered in parameters.
    Data cPeriod           As Character // Code of report period (from parameters).    
    Data oHeader           As Object    // Info for report header.
    Data aPart1            As Array     // Array of objects Ru6NDFLPart1 (Part 1) (for 13% and 15%).
    Data aPart2            As Array     // Array of objects Ru6NDFLPart2 (Part 2) (for 13% and 15%).
    Data aPeriods          As Array     // All selected periods.
    Data aLastMonth        As Array     // Last 3 month from period for Part 1.
    Data lRate13           As Logical   // In selected period exist payments on 13%.
    Data lRate15           As Logical   // In selected period exist payments on 15%.
    Data cPageCount        As Character // Number of pages on which the report is drawn.
    Data cDateReport       As Date      // Report generation date.
    Data aAttachments      As Array     // Array with 2NDFL object.

    Method New(aParameters, cFilterExpression) Constructor

    Method GetPersonnelNumbers()
    Method GetPeriods()
    Method GetLastMonthes()
    Method DefineNdflRates(aPeriod)
    Method CreatePart_1()
    Method CreatePart_2()
    Method MakeData()
    Method GetPageCount()

    Method MakeDataForReport()

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New()
    Default RU6NDFL constructor, 

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return RU6NDFL, Object, RU6NDFL instance.
    @example oRu6Ndfl := RU6NDFL():New(aParameters, cFilter)
/*/
Method New(aParameters, cFilterExpression) Class RU6NDFL
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
    Self:cYear := AllTrim(::aParameters[8])

    ::lRate13 := .F.
    ::lRate15 := .F.

    ::cDateReport := DToC(Date())

    ::aAttachments := {}

Return Self

/*/
{Protheus.doc} GetPersonnelNumbers()
    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RU6NDFL
    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character

    aNumbers := {}
    aArea := GetArea()

    cQuery := " SELECT RA_MAT AS EMPLOYNUM FROM " +  RetSQLName("SRA") + " WHERE "
    If ::lFilterOn
        cQuery += ::cFilter
        cQuery += " AND "
    EndIf
    cQuery += " D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        aAdd(aNumbers, (cTab)->EMPLOYNUM)
        DbSkip()
    EndDo

    aSort(aNumbers)

    DbCloseArea()
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
    @version 12.1.23
    @return aPeriods, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPeriods := ::GetPeriods()
/*/
Method GetPeriods() Class RU6NDFL
    Local aPeriods  As Array
    Local nMaxMonth As Numeric
    Local nI        As Numeric

    aPeriods := {}

    Do Case
        Case ::cPeriod == "21" .Or. ::cPeriod == "51"
            nMaxMonth := 3
        Case ::cPeriod == "31" .Or. ::cPeriod == "52"
            nMaxMonth := 6
        Case ::cPeriod == "33" .Or. ::cPeriod == "53"
            nMaxMonth := 9
        Case ::cPeriod == "34" .Or. ::cPeriod == "90"
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
    @version 12.1.23
    @return aPeriods, Array, Array of 3 last month in periods format 'YYYYMM' ordered.
    @example ::aLastMonth := ::GetLastMonthes()
/*/
Method GetLastMonthes() Class RU6NDFL
    Local aPeriods   As Array
    Local nI         As Numeric
    Local aArea      As Array
    Local oStatement As Object
    Local cQuery     As Character
    Local cTab       As Character

    aArea := GetArea()
    aPeriods := {}

    DbSelectArea("RCH")
    DbSetOrder(1) // RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR

    If Len(::aPeriods) >= 3
        For nI := Len(::aPeriods) - 2 To Len(::aPeriods)
            cQuery := " SELECT RCH_STATUS FROM " +  RetSQLName("RCH")
            cQuery += " WHERE "
            cQuery += " RCH_FILIAL = ? "
            cQuery += " AND RCH_PER = ? "
            cQuery += " AND RCH_ROTEIR = 'FOL' "
            cQuery += " AND D_E_L_E_T_ = ' ' "

            oStatement := FWPreparedStatement():New(cQuery)
            oStatement:SetString(1, FWxFilial("RCH"))
            oStatement:SetString(2, ::aPeriods[nI])

            cTab := MPSysOpenQuery(oStatement:GetFixQuery())

            DbSelectArea(cTab)
            (cTab)->(DbGoTop())

            If (cTab)->RCH_STATUS == STATUS_CLOSED_SALARY_PERIOD
                aAdd(aPeriods, ::aPeriods[nI])
            EndIf
        Next nI
    EndIf

    RestArea(aArea)

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
    @version 12.1.23
    @return 
    @example ::DefineNdflRates(::aLastMonth)
             ::DefineNdflRates(::aPeriods)
/*/
Method DefineNdflRates(aPeriod) Class RU6NDFL
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local aS002Lines   As Array
    Local nNdflLimit   As Numeric
    Local nI           As Numeric

    aArea := GetArea()
    aFirstParts := {}
    ::lRate13 := .T.
    ::lRate15 := .F.
    aS002Lines := {}
    nNdflLimit := 0

    // Get data from S002 and define limit summ for 13% rate.
    fCarrTab(@aS002Lines, "S002")
    For nI := 1 To Len(aS002Lines)
        If (SubStr(aS002Lines[nI][5], 1, 4) == ::cYear)
            nNdflLimit := aS002Lines[nI][8]
        EndIf
    Next nI

    // Get payd sum from SRD to define rates.
    cQuery := " SELECT SUM(SRD.RD_VALOR) AS TOTALSUMM FROM " +  RetSQLName("SRD") + " SRD "
    cQuery += " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRV.RV_IR = 'S' " // These types of payments are subject to NDFL.

    If ::lFilterOn
        cQuery += " AND SRD.RD_MAT IN (?) "
    EndIf

    cQuery += " AND SRV.RV_TIPOCOD = ? "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, aPeriod)

    If ::lFilterOn
        oStatement:SetIn(3, ::aPersonnelNumbers)
    EndIf

    oStatement:SetString(4, TYPE_OF_PAYMENT_INCOME)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    // Define NDFL rates.
    If (cTab)->TOTALSUMM <= nNdflLimit
        ::lRate13 := .T.
    Else
        ::lRate13 := .T.
        ::lRate15 := .T.
    EndIf

    DbCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return

/*/
{Protheus.doc} CreatePart_1()
    Fill array ::aPart1 - it is first part of report.
    The array is filled with objects of the Ru6NDFLPart1 class.
    If in the specified period (the last 3 months of the reporting period) into SRD 
    there are payments of 13% and 15%, then two objects will be created and, accordingly, 2 "section 1". 

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example ::CreatePart_1()
/*/
Method CreatePart_1(nPageNumber) Class RU6NDFL
    Local nI As Numeric
    
    ::aPart1 := {}

    // Check exist payments by rates 13% and 15% into periods.
    ::DefineNdflRates(::aLastMonth)

    // Fill Budget classification code for rate 13%.
    aAdd(::aPart1, Ru6NDFLPart1():New(::aLastMonth, 13, ::lFilterOn, ::aPersonnelNumbers))

    // Fill Budget classification code for rate 15%.
    aAdd(::aPart1, Ru6NDFLPart1():New(::aLastMonth, 15, ::lFilterOn, ::aPersonnelNumbers))

    // Fill Budget classification code for rate 30%.
    aAdd(::aPart1, Ru6NDFLPart1():New(::aLastMonth, 30, ::lFilterOn, ::aPersonnelNumbers))

    // Get data for created Part 1.
    For nI := 1 To Len(::aPart1)
        nPageNumber += 1
        ::aPart1[nI]:MakeData()
        ::aPart1[nI]:cPageNumber := StrZero(nPageNumber, 3, 0)
    Next nI

Return

/*/
{Protheus.doc} CreatePart_2()
    Fill array ::aPart2 - it is second part of report.
    The array is filled with objects of the Ru6NDFLPart2 class.
    If in the specified period (all months of the reporting period) into SRD 
    there are payments of 13% and 15%, then two objects will be created and, accordingly, 2 "section 2". 

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example ::CreatePart_2()
/*/
Method CreatePart_2(nPageNumber) Class RU6NDFL
    Local nI As Numeric
    Local nTempAmount As Numeric
    
    ::aPart2 := {}
    nTempAmount := 0

    // Check exist payments by rates 13% and 15% into periods.
    ::DefineNdflRates(::aPeriods)

    // Fill Budget classification code for rate 13%.
    aAdd(::aPart2, Ru6NDFLPart2():New(::aPeriods, 13, ::lFilterOn, ::aPersonnelNumbers))

    // Fill Budget classification code for rate 15%.
    aAdd(::aPart2, Ru6NDFLPart2():New(::aPeriods, 15, ::lFilterOn, ::aPersonnelNumbers))

    // Fill Budget classification code for rate 30%.
    aAdd(::aPart2, Ru6NDFLPart2():New(::aPeriods, 30, ::lFilterOn, ::aPersonnelNumbers))

    // Get data for created Part 1.
    For nI := 1 To Len(::aPart2)
        nPageNumber += 1
        ::aPart2[nI]:GetData()
        ::aPart2[nI]:cPageNumber := StrZero(nPageNumber, 3, 0)
    Next nI

    // it used to be like this
    // // While there is no division of tax deductions into 13 and 15%, we divide in half.
    // If (::lRate13 .And. !::lRate15)
    //     ::aPart2[2]:nDeductionAmount := 0
    // ElseIf (!::lRate13 .And. ::lRate15)
    //     ::aPart2[1]:nDeductionAmount := 0
    // Else
    //     ::aPart2[1]:nDeductionAmount := ::aPart2[1]:nDeductionAmount / 2
    //     ::aPart2[2]:nDeductionAmount := ::aPart2[2]:nDeductionAmount / 2
    // EndIf

    // Filled only for 13%

Return 0


/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example oRu6Ndfl:MakeData()
/*/
Method MakeData() Class RU6NDFL
    Local nPageNumber As Numeric
    Local nI As Numeric

    nPageNumber := 1

    // Get need data for next calculations.
    ::aPeriods := ::GetPeriods()
    ::aLastMonth := ::GetLastMonthes()

    // Create header of report.
    ::oHeader := Ru6NDFLHeader():New(::aParameters)
    ::oHeader:MakeData()

    // Create Part 1.
    ::CreatePart_1(@nPageNumber)

    // Create Part 2.
    ::CreatePart_2(@nPageNumber)

    // Get count of report pages.
    ::cPageCount := ::GetPageCount()

    If ::cPeriod $ YEAR_PERIODS
        // Include 2-NDFL for report.
        For nI := 1 To Len(::aPersonnelNumbers)
            aAdd(::aAttachments, RU6NDFLAttachment():New(::aPersonnelNumbers[nI], ::cYear, ::oHeader:cCorrectionNumber, AllTrim(Str(nI)), ::aPeriods))
            ::aAttachments[nI]:GetData()
        Next nI
    EndIf

Return

/*/
{Protheus.doc} GetPageCount()
    Calculate count of report pages.
    Make format as "000".

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/07
    @version 12.1.23
    @return cPages, Character, Count of report pages in format "000".
    @example ::cPageCount := GetPageCount()
/*/
Method GetPageCount() Class RU6NDFL
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
    @version 12.1.23
    @return cResult, Character, Value into report format.
    @example ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN)
             ::MakeDataForReport(Str(::aPart2[nI]:nIncomeAmountTotal), 15, 2)
/*/
Method MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal) Class RU6NDFL
    Local cResult As Character
    Local cTempVar As Character
    Local nDecimalPosition As Numeric

    Default nMaxLenDecimal := 0

    cTempVar := AllTrim(cValue)

    If (Len(cTempVar) < nMaxLenWhole .And. nMaxLenDecimal == 0)
        cResult := Padr(cTempVar, nMaxLenWhole, "-")
    ElseIf (Len(cTempVar) < nMaxLenWhole .And. nMaxLenDecimal > 0)
        nDecimalPosition := At(".", cTempVar)
        If (nDecimalPosition > 0)
            cResult := Padr(SubStr(cTempVar, 1, nDecimalPosition - 1), (nMaxLenWhole - nMaxLenDecimal - 1), "-") + SubStr(cTempVar, nDecimalPosition, 3)
        Else
            cResult := Padr(cTempVar, (nMaxLenWhole - nMaxLenDecimal - 1), "-") + ".--"
        EndIf
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
    @version 12.1.23
    @return 
    @example ::GetViewReport()
            oRu6Ndfl:GetViewReport()
/*/
Method GetViewReport() Class RU6NDFL
    Local aLogText        As Array
    Local aLogTextPart1   As Array
    Local aLogTextPart2   As Array
    Local aLogTextAttach  As Array
    Local aLogTitleHeader As Array
    Local nI              As Numeric
    Local nJ              As Numeric
    Local nItemArray      As Numeric

    aLogText        := {}
    aLogTextPart1   := {}
    aLogTextPart2   := {}
    aLogTextAttach  := {}
    aLogTitleHeader := {}

    // Create header for report.
    aLogText := { {                                                                                                                          ;
                    STR0010 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                                 ,;
                    STR0011 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                                 ,;
                    STR0039 + " '" + ::MakeDataForReport(::oHeader:cPageNumber, MAX_LEN_PAGES) + "'"                                        ,;
                    STR0012 + " '" + ::MakeDataForReport(::oHeader:cCorrectionNumber, MAX_LEN_CORRECTION_NUMBER) + "'"                      ,;
                    STR0013 + " '" + ::oHeader:cPeriod + "'"                                                                                ,;
                    STR0014 + " '" + ::oHeader:cYear + "'"                                                                                  ,;
                    STR0015 + " '" + ::oHeader:cIFNSCode + "'"                                                                              ,;
                    STR0016 + " '" + ::oHeader:cCalculationSubmissionCode + "'"                                                             ,;
                    STR0017 + " '" + ::MakeDataForReport(Upper(OemToAnsi(::oHeader:cCompanyName)), MAX_LEN_NALOG_AGENT) + "'"               ,;
                    STR0034 + " '" + ::MakeDataForReport(::oHeader:cLiquidationCode, MAX_LEN_LIQUIDATION_CODE) + "'"                        ,;
                    STR0035 + " '" + ::MakeDataForReport(::oHeader:cINNClosedOrganization, MAX_LEN_INN_CLOSED_ORGANIZATION) +                ;
                             " / " + ::MakeDataForReport(::oHeader:cKPPClosedOrganization, MAX_LEN_KPP_CLOSED_ORGANIZATION) + "'"           ,;
                    STR0018 + " '" + ::MakeDataForReport(::oHeader:cOKTMO, MAX_LEN_OKTMO_CODE) + "'"                                        ,;
                    STR0019 + " '" + ::MakeDataForReport(::oHeader:cCompanyPhone, MAX_LEN_PHONE_NUMBER) + "'"                               ,;
                    STR0020 + " '" + ::MakeDataForReport(::cPageCount, MAX_LEN_PAGES) + "'" + STR0033                                       ,;
                    STR0021                                                                                                                 ,;
                    STR0022 + " '" + AllTrim(Str(::oHeader:nResponsiblePersonCategory)) + "'"                                               ,;
                    STR0023 + " '" + ::MakeDataForReport(UPPER(::oHeader:cSigner), MAX_LEN_SIGNER) + "'"                                    ,;
                    STR0024 + " '" + UPPER(OemToAnsi(::MakeDataForReport(::oHeader:cRepresentOrganizationName, MAX_LEN_NALOG_AGENT))) + "'" ,;
                    STR0037 + " '" + ::cDateReport + "'"                                                                                    ,;
                    STR0038 + " '" + ::MakeDataForReport(::oHeader:cRepresentDocument, MAX_LEN_SIGNER_DOCUMENTS) + "'"                       ;
                  }                                                                                                                          ; 
                }

    aLogTitleHeader := { STR0007 } // Add title.

    aPart1Data := ::aPart1[1]:GetDataAmount(::oHeader:cYear)
    // Create part 1 for report.
    For nI := 1 To Len(::aPart1)
        aValData := fValPart(aPart1Data, Iif(nI == 1, '13', Iif(nI == 2, '15', '30')))
        If ::aPart1[nI]:nIncomeTaxAmount == 0 .And. AScan(aValData, {|X| X > 0}) < 1 ;
                 .And. AScan(Self:aPart1[nI]:aTaxRefund, {|X| X[2] > 0}) < 1
            Loop
        EndIf
        aLogTextPart1 := {}

        aLogTextPart1 := {                                                                                                 ;
                            STR0010 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                       ,;
                            STR0011 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                       ,;
                            STR0039 + " '" + ::MakeDataForReport(::aPart1[nI]:cPageNumber, MAX_LEN_PAGES) + "'"           ,;
                            "010 '" + ::aPart1[nI]:cBudgetClassCode + "'"                                                 ;
                            ;// "020 '" + ::MakeDataForReport(Str(Round(::aPart1[nI]:nIncomeTaxAmount, 0)), MAX_LEN_NUMERIC_VALUE) + "'" ; // history
                         }

        // For nItemArray := 1 To Len(::aPart1[nI]:aNDFLPaymens)
        //     aAdd(aLogTextPart1, "021 '" + ::aPart1[nI]:aNDFLPaymens[nItemArray][1] + "'  022 '" + ::MakeDataForReport(Str(Round(::aPart1[nI]:aNDFLPaymens[nItemArray][2], 0)), MAX_LEN_NUMERIC_VALUE) + "'")
        // Next nItemArray

        aAdd(aLogTextPart1, "020 '" + cValToChar(aValData[1] + aValData[2] + aValData[3] + aValData[4]) + "'")
        aAdd(aLogTextPart1, "021 '" + cValToChar(aValData[1]) + "'")
        aAdd(aLogTextPart1, "022 '" + cValToChar(aValData[2]) + "'")
        aAdd(aLogTextPart1, "023 '" + cValToChar(aValData[3]) + "'")
        aAdd(aLogTextPart1, "024 '" + cValToChar(aValData[4]) + "'")

        aAdd(aLogTextPart1, "030 '" + "0" + "'")

        For nItemArray := 1 To Len(::aPart1[nI]:aTaxRefund)
            aAdd(aLogTextPart1, "031 '" + ::aPart1[nI]:aTaxRefund[nItemArray][1] + "'  032 '" + ::MakeDataForReport(Str(::aPart1[nI]:aTaxRefund[nItemArray][2]), MAX_LEN_NUMERIC_VALUE) + "'")
        Next nItemArray

        aAdd(aLogTextPart1, STR0037 + " '" + ::cDateReport + "'")

        aAdd(aLogText, aLogTextPart1)
        aAdd(aLogTitleHeader, STR0025)
    Next nI

    // Create part 2 for report.
    For nI := 1 To Len(::aPart2)
        If ::aPart2[nI]:nIncomeAmountTotal == 0 .And. ::aPart2[nI]:nEmployeeCount == 0 ;
                .And. ::aPart2[nI]:nTaxAmountCalculated == 0 .And. ::aPart2[nI]:nFixAdvancedPayment == 0 ;
                .And. ::aPart2[nI]:nWithheldTaxAmount == 0 .And. ::aPart2[nI]:nNotWithheldAmount == 0 ;
                .And. ::aPart2[nI]:nUndulyWithheldAmount == 0 .And. ::aPart2[nI]:nRefundedAmount == 0
            Loop
        EndIf
        aLogTextPart2 := {}

        aLogTextPart2 := {                                                                                                                           ;
                            STR0010 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"                                                 ,;
                            STR0011 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"                                                 ,;
                            STR0039 + " '" + ::MakeDataForReport(::aPart2[nI]:cPageNumber, MAX_LEN_PAGES) + "'"                                     ,;
                            "100 '" + AllTrim(Str(::aPart2[nI]:nNDFLRate)) + "'"                                                                    ,;
                            "105 '" + ::aPart2[nI]:cBudgetClassCode + "'"                                                                           ,;
                            "110 '" + ::MakeDataForReport(Str(::aPart2[nI]:nIncomeAmountTotal), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'" ,; // In attachment in there is a line that is considered according to the same logic. function in RU6NDFLAttachment
                            "111 '" + ::MakeDataForReport(Str(::aPart2[nI]:nAmountByDividend), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"  ,;
                            "112 '" + ::MakeDataForReport(Str(::aPart2[nI]:nContractAmount), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"    ,;
                            "113 '" + ::MakeDataForReport(Str(::aPart2[nI]:nGPCAmount), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"         ,;
                            "115 '" + ::MakeDataForReport(Str(0), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"                               ,; // not localized
                            "120 '" + ::MakeDataForReport(Str(::aPart2[nI]:nEmployeeCount), MAX_LEN_EMPLOYEE) + "'"                                 ,;
                            "121 '" + ::MakeDataForReport(Str(0), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"                               ,; // not localized
                            "130 '" + ::MakeDataForReport(Str(::aPart2[nI]:nDeductionAmount), MAX_LEN_NUMERIC_VALUE, MAX_LEN_DECIMAL_VALUE) + "'"   ,;
                            "140 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nTaxAmountCalculated, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                      ,;
                            "141 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nCalculatedAmountByDividend, 0)), MAX_LEN_NUMERIC_VALUE) + "'"               ,;
                            "142 '" + ::MakeDataForReport(Str(0), MAX_LEN_NUMERIC_VALUE) + "'"                                                                ,; // not localized
                            "150 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nFixAdvancedPayment, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                       ,;
                            "155 '" + ::MakeDataForReport(Str(0), MAX_LEN_NUMERIC_VALUE) + "'"                                                                ,; // not localized
                            "160 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nWithheldTaxAmount, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                        ,;
                            "170 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nNotWithheldAmount, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                        ,;
                            "180 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nUndulyWithheldAmount, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                     ,;
                            "190 '" + ::MakeDataForReport(Str(Round(::aPart2[nI]:nRefundedAmount, 0)), MAX_LEN_NUMERIC_VALUE) + "'"                            ;
                        }

        aAdd(aLogTextPart2, STR0037 + " '" + ::cDateReport + "'")

        aAdd(aLogText, aLogTextPart2)
        aAdd(aLogTitleHeader, STR0026)
    Next nI

    // Create attachments.
    If Len(::aAttachments) > 0
        For nI := 1 To Len(::aAttachments)
            aLogTextAttach := {}

            aLogTextAttach := { ;
                                STR0010 + " '" + ::MakeDataForReport(::oHeader:cINN, MAX_LEN_INN) + "'"   ,;
                                STR0011 + " '" + ::MakeDataForReport(::oHeader:cKPP, MAX_LEN_KPP) + "'"   ,;
                                STR0039 + " '" + ::MakeDataForReport("001", MAX_LEN_PAGES) + "'"          ,;
                                CRLF + STR0081 + CRLF                                                     ,;
                                STR0040 + " '" + ::aAttachments[nI]:cReferenceNumber + "'"                ,;
                                STR0012 + " '" + ::aAttachments[nI]:cCorrectionNumber + "'"               ,;
                                CRLF + STR0041 + CRLF                                                     ,;
                                STR0010 + " '" + ::aAttachments[nI]:cINN + "'"                            ,;
                                STR0042 + " '" + ::aAttachments[nI]:cSurename + "'"                       ,;
                                STR0043 + " '" + ::aAttachments[nI]:cName + "'"                           ,;
                                STR0044 + " '" + ::aAttachments[nI]:cMiddleName + "'"                     ,;
                                STR0045 + " '" + ::aAttachments[nI]:cTaxAgentStatusCode + "'"             ,;
                                STR0046 + " '" + DToC(SToD(::aAttachments[nI]:cBirthday)) + "'"                 ,;
                                STR0047 + " '" + ::aAttachments[nI]:cCitizenshipCode + "'"               ,;
                                STR0048 + " '" + ::aAttachments[nI]:cDocumentTypeCode + "'"       ,;
                                STR0049 + " '" + ::aAttachments[nI]:cSeriesAndNumberDocument + "'"  ;
            }
                                //
                                
            If (::aAttachments[nI]:lRate30 .And. !Empty(::aAttachments[nI]:aAllSumm30) .And. !Empty(::aAttachments[nI]:aAllF6Su30) .And. !::aAttachments[nI]:lRate15 .And. !::aAttachments[nI]:lRate13)
                aAdd(aLogTextAttach, CRLF + STR0050 + "     " + STR0051 + " '30'" + CRLF)
                aAdd(aLogTextAttach, STR0089 + " '" + ::aPart2[3]:cBudgetClassCode + "'")
                aAdd(aLogTextAttach, STR0052 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su30[1])) + "'")
                aAdd(aLogTextAttach, STR0053 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su30[2])) + "'")
                aAdd(aLogTextAttach, STR0054 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm30[3], 0))), 11) + "'")
                aAdd(aLogTextAttach, STR0055 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm30[4], 0))), 11) + "'")
                aAdd(aLogTextAttach, STR0057 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm30[6], 0))), 11) + "'")
                aAdd(aLogTextAttach, STR0056 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm30[5], 0))), 11) + "'")
                aAdd(aLogTextAttach, STR0090 + " '" + ::MakeDataForReport("0", 11) + "'")
                aAdd(aLogTextAttach, STR0058 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm30[7], 0))), 11) + "'")
            Else
                If (::aAttachments[nI]:lRate13 .And. !Empty(::aAttachments[nI]:aAllSumm13) .And. !Empty(::aAttachments[nI]:aAllF6Su13))
                    aAdd(aLogTextAttach, CRLF + STR0050 + "     " + STR0051 + " '13'" + CRLF)
                    aAdd(aLogTextAttach, STR0089 + " '" + ::aPart2[1]:cBudgetClassCode + "'")
                    aAdd(aLogTextAttach, STR0052 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su13[1])) + "'")
                    aAdd(aLogTextAttach, STR0053 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su13[2])) + "'")
                    aAdd(aLogTextAttach, STR0054 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm13[3], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0055 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm13[4], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0057 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm13[6], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0056 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm13[5], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0090 + " '" + ::MakeDataForReport("0", 11) + "'")
                    aAdd(aLogTextAttach, STR0058 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm13[7], 0))), 11) + "'")
                EndIf

                If (::aAttachments[nI]:lRate15 .And. !Empty(::aAttachments[nI]:aAllSumm15) .And. !Empty(::aAttachments[nI]:aAllF6Su15))
                    aAdd(aLogTextAttach, CRLF + STR0050 + "     " + STR0051 + " '15'" + CRLF)
                    aAdd(aLogTextAttach, STR0089 + " '" + ::aPart2[2]:cBudgetClassCode + "'")
                    aAdd(aLogTextAttach, STR0052 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su15[1])) + "'")
                    aAdd(aLogTextAttach, STR0053 + " '" + AllTrim(Str(::aAttachments[nI]:aAllF6Su15[2])) + "'")
                    aAdd(aLogTextAttach, STR0054 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm15[3], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0055 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm15[4], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0057 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm15[6], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0056 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm15[5], 0))), 11) + "'")
                    aAdd(aLogTextAttach, STR0090 + " '" + ::MakeDataForReport("0", 11) + "'")
                    aAdd(aLogTextAttach, STR0058 + " '" + ::MakeDataForReport(AllTrim(Str(Round(::aAttachments[nI]:aAllSumm15[7], 0))), 11) + "'")
                EndIf
            EndIf

            aAdd(aLogTextAttach, CRLF + STR0059 + CRLF)

            If !Empty(::aAttachments[nI]:a13TaxPayments)
                For nJ := 1 To Len(::aAttachments[nI]:a13TaxPayments)
                    aAdd(aLogTextAttach, STR0060 + " '" + ::aAttachments[nI]:a13TaxPayments[nJ][2] + "' " +  STR0061 + " '" + AllTrim(Str(::aAttachments[nI]:a13TaxPayments[nJ][3])) + "'")
                Next nJ

                If !Empty(::aAttachments[nI]:a13TaxInfo)
                    For nJ := 1 To Len(::aAttachments[nI]:a13TaxInfo)
                        aAdd(aLogTextAttach, STR0062 + " '" + ::aAttachments[nI]:a13TaxInfo[nJ][2] + "'")
                        aAdd(aLogTextAttach, STR0063 + " '" + DToC(::aAttachments[nI]:a13TaxInfo[nJ][3]) + "'")
                        aAdd(aLogTextAttach, STR0064 + " '" + ::aAttachments[nI]:a13TaxInfo[nJ][4] + "'")
                        aAdd(aLogTextAttach, STR0065 + " '" + ::aAttachments[nI]:a13TaxInfo[nJ][5] + "'")
                    Next nJ
                EndIf
            EndIf

            aAdd(aLogTextAttach, CRLF + STR0066 + CRLF)
            aAdd(aLogTextAttach, STR0067 + " '---------------.--'")
            aAdd(aLogTextAttach, STR0068 + " '---------------'")

            
            aAdd(aLogTextAttach, CRLF + STR0069 + CRLF)
            If (::aAttachments[nI]:lRate30 .And. !Empty(::aAttachments[nI]:aIncome30) .And. !::aAttachments[nI]:lRate15 .And. !::aAttachments[nI]:lRate13)
                aAdd(aLogTextAttach, STR0070 + " '" + ::aAttachments[nI]:cReferenceNumber + "' " + STR0071 + " '30'")
                aAdd(aLogTextAttach, STR0091 + " '" + ::aPart2[3]:cBudgetClassCode + "'")

                For nJ := 1 To Len(::aAttachments[nI]:aIncome30)
                    aAdd(aLogTextAttach, STR0072 + " '" + SubStr(::aAttachments[nI]:aIncome30[nJ][1], 5, 2) + "'")
                    aAdd(aLogTextAttach, STR0073 + " '" + ::aAttachments[nI]:aIncome30[nJ][2] + "' " + STR0074 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome30[nJ][3])) + "'")
                    aAdd(aLogTextAttach, STR0075 + " '" + ::aAttachments[nI]:aIncome30[nJ][4] + "' " + STR0076 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome30[nJ][5])) + "'")
                Next nJ
            
            Else
                If (::aAttachments[nI]:lRate13 .And. !Empty(::aAttachments[nI]:aIncome13))
                    aAdd(aLogTextAttach, STR0070 + " '" + ::aAttachments[nI]:cReferenceNumber + "' " + STR0071 + " '13'")
                    aAdd(aLogTextAttach, STR0091 + " '" + ::aPart2[1]:cBudgetClassCode + "'")

                    For nJ := 1 To Len(::aAttachments[nI]:aIncome13)
                        aAdd(aLogTextAttach, STR0072 + " '" + SubStr(::aAttachments[nI]:aIncome13[nJ][1], 5, 2) + "'")
                        aAdd(aLogTextAttach, STR0073 + " '" + ::aAttachments[nI]:aIncome13[nJ][2] + "' " + STR0074 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome13[nJ][3])) + "'")
                        aAdd(aLogTextAttach, STR0075 + " '" + ::aAttachments[nI]:aIncome13[nJ][4] + "' " + STR0076 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome13[nJ][5])) + "'")
                    Next nJ

                    aAdd(aLogTextAttach, CRLF)
                EndIf

                If (::aAttachments[nI]:lRate15 .And. !Empty(::aAttachments[nI]:aIncome15))
                    aAdd(aLogTextAttach, STR0070 + " '" + ::aAttachments[nI]:cReferenceNumber + "' " + STR0071 + " '15'")
                    aAdd(aLogTextAttach, STR0091 + " '" + ::aPart2[2]:cBudgetClassCode + "'")

                    For nJ := 1 To Len(::aAttachments[nI]:aIncome15)
                        aAdd(aLogTextAttach, STR0072 + " '" + SubStr(::aAttachments[nI]:aIncome15[nJ][1], 5, 2) + "'")
                        aAdd(aLogTextAttach, STR0073 + " '" + ::aAttachments[nI]:aIncome15[nJ][2] + "' " + STR0074 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome15[nJ][3])) + "'")
                        aAdd(aLogTextAttach, STR0075 + " '" + ::aAttachments[nI]:aIncome15[nJ][4] + "' " + STR0076 + " '" + AllTrim(Str(::aAttachments[nI]:aIncome15[nJ][5])) + "'")
                    Next nJ
                EndIf
            EndIf

            aAdd(aLogTextAttach, STR0037 + " '" + ::cDateReport + "'")

            aAdd(aLogText, aLogTextAttach)
            aAdd(aLogTitleHeader, STR0077)
        Next nI
    EndIf

    // Execute printing log with report data. fMakeLog - Brazilian function for print log.
    MsAguarde({|| fMakeLog(aLogText, aLogTitleHeader, Nil, Nil, FunName(), STR0028, , , , .F.)}, STR0029)

Return

/*/
{Protheus.doc} GetXMLReport(cDocSavePath)
    This method generate report in XML document.

    @type Method
    @params cDocSavePath,  Character, Path to save result document into XML format.
    @author vselyakov
    @since 2021/07/09
    @version 12.1.23
    @return 
    @example ::GetXMLReport(cSavePath)
            oRu6Ndfl:GetXMLReport()
/*/
Method GetXMLReport(cDocSavePath) Class RU6NDFL
    
    Help(,,"Error",, STR0036, 1, 0)

Return


/*/{Protheus.doc} fValPart(aData , cRate)
        Selection of deduction amounts
    @type  Static Function
    @author iprokhorenko
    @since 25/04/2023
    @version 12.1.23
    @param aData, array, data array
           cRate, Character, tax rate
    @return aRes, array, data array
    @example
        aTax := fValPart(aData , cRate )
/*/
Static Function fValPart(aData as array, cRate as Character)
    
    Local aRes As Array 
    Local cPer := "RU07R02PAR"
    Local cTypeP as Character
    Local nI as Numeric 
    Local nPos as Numeric

    Pergunte(cPer, .F.)

    aRes :={0,0,0,0}

    cTypeP := MV_PAR01

    aPer := aClone(TAXABLE_PERIOD)
    nPos :=  AScan(TAXABLE_PERIOD,{|x| x[1]==Alltrim(cTypeP)})

    For nI := 1 To len(aData)
        if nI == 19 
            cTypeP := cTypeP
        endif
        If Val(cRate) == aData[nI][3]
            Do Case 
                Case StoD(aData[nI][2])>=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][2],1,4)) .And. ;
                     StoD(aData[nI][2])<=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][2],6,4))
                        aRes[1] += aData[nI][1]
                Case StoD(aData[nI][2])>=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][3],1,4)) .And. ;
                     StoD(aData[nI][2])<=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][3],6,4))
                        aRes[2] += aData[nI][1]
                Case StoD(aData[nI][2])>=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][4],1,4)) .And. ;
                     StoD(aData[nI][2])<=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][4],6,4))
                        aRes[3] += aData[nI][1]
                Case StoD(aData[nI][2])>=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][5],1,4)) .And. ;
                     StoD(aData[nI][2])<=StoD(SubStr(aData[nI][2],1,4)+SubStr(aPer[nPos][5],6,4))
                        aRes[4] += aData[nI][1]
            EndCase
        EndIf
    Next nI


Return aRes
