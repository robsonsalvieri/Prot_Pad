#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R12RUS.CH"

// Reporting period codes. Table S213.
#DEFINE FIRST_QUARTER_REPORT_PERIOD_CODE "21"
#DEFINE HALF_YEAR_REPORT_PERIOD_CODE     "31"
#DEFINE NINE_MONTH_REPORT_PERIOD_CODE    "33"
#DEFINE ONE_YEAR_REPORT_PERIOD_CODE      "34"
#DEFINE REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE "51"
#DEFINE REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE     "52"
#DEFINE REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE    "53"
#DEFINE REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE      "90"

#DEFINE NOT_REALIZED_SYMBOL "-"
#DEFINE NOT_LOCALIZED_SYMBOL_NIL "0"
#DEFINE INS_PREM_TYPE_PAYING_ID_COD_FOLS "'0149'"

/*/
{Protheus.doc} RUHREFSPart2FSSReport

    Class for EFS report part 2 - 4-FSS.

    @type Class
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
/*/
Class RUHREFSPart2FSSReport From LongNameClass

    Data aParameters            As Array     // Array of parameters.
    Data cFilter                As Character // String of filter.
    Data aFilter                As Array     // Array of filter
    Data cPeriod                As Character // Report period code (from parameters).
    Data aPeriods               As Array     // Periods for calculation

    Data aPersonnelNumbers      As Array     // Array of personel numbers.
    Data aEmplAll               As Array     // Array ofemployee, whitch in calculation
    Data cCountInvalidEmployee  As Character // Count working invalid
    Data cCountAverListEmployee As Character // Average listing employee
    Data oGeneralJson           As Object    // Json for report.
    Data nCountEmpAll           As Numeric

    Method New(aParameters, aPersonnelNumbers) Constructor

    Method AddContent(oJson)
    Method GetGeneralInfo()
    Method CalcEmployeeInfo()
    Method GetAverageListCount(aFullEmployee, aNFullEmployee)
    Method GetSubs21Table()
    Method GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid)
    Method GetSumSRD2(aPeriods)
    Method GetSubs23Table()

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New(aParameters, aPersonnelNumbers)

    Default constructor.

    @type Method
    @params aParameters,       Array, Array of parameters from pergunte.
    @params aPersonnelNumbers, Array, Array of TN of emplyees.
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
    @return RUHREFSPart2FSSReport, Object, RUHREFSPart2FSSReport instance.
    @example oEFSFSSObj := RUHREFSPart2FSSReport():New(aParam, oEFSObject:aPersonnelNumbers)
/*/
Method New(aParameters, aPersonnelNumbers) Class RUHREFSPart2FSSReport

    Self:aParameters := AClone(aParameters)
    Self:aPersonnelNumbers := AClone(aPersonnelNumbers)

    Self:oGeneralJson := JsonObject():New()
    Self:oGeneralJson["content"] := {}
    Self:cCountInvalidEmployee := "-1"
    Self:cCountAverListEmployee := "-1"

Return Self

/*/
{Protheus.doc} GetGeneralInfo()

    This method biuld part 2 for report (general information).

    @type Method
    @params 
    @author dchizhov
    @since 04.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oEFSFSSObj:AddContent(oEFSFSSObj:GetGeneralInfo())
/*/
Method GetGeneralInfo() Class RUHREFSPart2FSSReport

    Local oJson As Object
    Local cJson As Character
    Local lCalc As Logical
    Local nX    As Numeric
    Local cCode As Character

    ::cPeriod := AllTrim(::aParameters[1])
    oJson := JsonObject():New()
    Do Case
        Case ::cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            cCode := "03"
        Case ::cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            cCode := "06"
        Case ::cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            cCode := "09"
        Case ::cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            cCode := "12"
        Otherwise
            cCode := "03"
    EndCase

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "pageBreak": "before",
                "style": "title",
                "pageOrientation": "landscape"
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal9",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [100, 50, 140, 170, 30, 70, 75, 50, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"}, {"border": [false, false, false, true], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""},
                            {"border": [false, false, false, false], "text": ""}
                        ], 
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left", "colSpan": 3, "fontSize": 7}, {},
                            {}, {"border": [false, false, false, false], "text": "", "colSpan": 2, "fontSize": 7},
                            {}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal9",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [620, 120, 10, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [30, 500, 80, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := CRLF + CRLF + STR0070 + CRLF + CRLF // "Section 2. Information on the accrued insurance premiums for compulsory social insurance against accidents at work and occupational diseases"
    oJson["content"][2]["table"]["body"][ 1, 1]["text"] := STR0090 // "Adjustment number"
    oJson["content"][2]["table"]["body"][ 1, 2]["text"] := ::aParameters[3]
    oJson["content"][2]["table"]["body"][ 1, 4]["text"] := STR0092 // "Settlement (reporting) period (code)"
    oJson["content"][2]["table"]["body"][ 1, 5]["text"] := cCode
    oJson["content"][2]["table"]["body"][ 1, 7]["text"] := STR0094 // "Calendar Year"
    oJson["content"][2]["table"]["body"][ 1, 8]["text"] := ::aParameters[2]
    oJson["content"][2]["table"]["body"][ 2, 1]["text"] := STR0091 // "(000 - original, 001 - correction number)"
    oJson["content"][2]["table"]["body"][ 2, 4]["text"] := STR0093 // "(03 - 1 quarter; 06 - half a year; 09 - 9 months; 12 - year)"
    oJson["content"][3]["table"]["body"][ 1, 2]["text"] := STR0095 // "Cessation"
    oJson["content"][3]["table"]["body"][ 1, 3]["text"] := Iif(::aParameters[4] == 1, STR0105, "") // "L"
    oJson["content"][4]["table"]["body"][ 1, 2]["text"] := STR0096 // "Average number of employees"
    oJson["content"][4]["table"]["body"][ 2, 2]["text"] := STR0097 // "The number of working insured persons under compulsory social insurance against accidents at work and occupational diseases"
    oJson["content"][4]["table"]["body"][ 3, 2]["text"] := STR0098 // "Number of working disabled people"
    oJson["content"][4]["table"]["body"][ 4, 2]["text"] := STR0099 // "The number of employees employed in work with harmful and (or) hazardous production factors"
    lCalc := ::CalcEmployeeInfo()
    oJson["content"][4]["table"]["body"][ 1, 3]["text"] := Iif(lCalc, ::cCountAverListEmployee, STR0106) // "No data"
    oJson["content"][4]["table"]["body"][ 2, 3]["text"] := Iif(lCalc, CValToChar(::nCountEmpAll), STR0106) // "No data"
    oJson["content"][4]["table"]["body"][ 3, 3]["text"] := Iif(lCalc, ::cCountInvalidEmployee, STR0106) // "No data"
    oJson["content"][4]["table"]["body"][ 4, 3]["text"] := NOT_REALIZED_SYMBOL
    For nX := 1 To 4
        If Len(oJson["content"][4]["table"]["body"][nX, 2]["text"]) > 120
            oJson["content"][4]["table"]["body"][nX, 3]["margin"] := {5, 8, 0, 0}
        Else
            oJson["content"][4]["table"]["body"][nX, 3]["margin"] := {5, 0, 0, 0}
        EndIf
    Next nX

Return oJson

/*/
{Protheus.doc} CalcEmployeeInfo()

    The method receives data about emplyee for the FSS part of EFS report.

    @type Method
    @params
    @author dchizhov
    @since 05.05.2023
    @version 12.1.33
    @return lResult, Logical, Information about success receives data about emplyee by company.
    @example lCalc := ::CalcEmployeeInfo()
/*/
Method CalcEmployeeInfo() Class RUHREFSPart2FSSReport

    Local lResult := .T. As Logical
    Local aArea          As Array
    Local aSRAArea       As Array
    Local aFullEmployee  As Array
    Local aNFullEmployee As Array
    Local nI             As Numeric

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())

    aFullEmployee := {}
    aNFullEmployee := {}

    DbSelectArea("SRA")
    SRA->(DbSetOrder(RetOrdem("SRA", "RA_MAT+RA_FILIAL")))
    SRA->(DbGoTop())

    ::aEmplAll := {}
    ::nCountEmpAll := 0
    ::cCountInvalidEmployee := 0

    For nI := 1 To Len(::aPersonnelNumbers)
        If DbSeek(::aPersonnelNumbers[nI, 1] + ::aPersonnelNumbers[nI, 2])
            If SRA->RA_CATFUNC $ "MH"
                If SRA->RA_HOPARC == "2"
                    AAdd(aFullEmployee, {SRA->RA_MAT + SRA->RA_FILIAL, SRA->RA_ADMISSA, SRA->RA_DEMISSA})
                ElseIf SRA->RA_HOPARC == "1"
                    AAdd(aNFullEmployee, SRA->RA_MAT + SRA->RA_FILIAL)
                EndIf
            EndIf
            If SRA->RA_SITFOLH <> "D"
                ::nCountEmpAll += 1
                If SRA->RA_DEFIFIS == "1"
                    ::cCountInvalidEmployee += 1
                EndIf
            EndIf
            AAdd(::aEmplAll, ::aPersonnelNumbers[nI, 3])
        EndIf
    Next nI

    lResult := ::GetAverageListCount(aFullEmployee, aNFullEmployee) .And. lResult

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} GetAverageListCount(aFullEmployee, aNFullEmployee)

    Calculate of Average ListCount (people).

    @type Method
    @params aFullEmployee, Array, Array of full-time employees
    @params aFullEmployee, Array, Array of not full-time employees
    @author dchizhov
    @since 05.05.2023
    @version 12.1.33
    @return lResult, Logical, Success of calculating Average ListCount (people).
    @example ::GetAverageListCount(aFullEmployee, aNFullEmployee)
/*/
Method GetAverageListCount(aFullEmployee, aNFullEmployee) Class RUHREFSPart2FSSReport

    Local oStatement             As Object
    Local cQuery                 As Character 
    Local aArea                  As Array
    Local cTab                   As Character
    Local nAverageCount          As Numeric
    Local nMonthDayCount         As Numeric
    Local dLastDateMonth         As Date
    Local nI                     As Numeric
    Local dCurrentDate           As Date
    Local nMonth                 As Numeric
    Local aSraAverage            As Array
    Local nSumEmployee           As Numeric
    Local nFullRateEmployeeCount As Numeric // Count of employee with full rate.
    Local nPartRateEmployeeCount As Numeric // Count of employee with part rate.
    Local cCalculationPeriod     As Character
    Local cFilterFilial          As Character
    Local nMonthCount            As Numeric // Count of monthes into selected report period
    Local lResult                As Logical
    Local dStartWorkMonthPer     As Date
    Local dFinishWorkMonthPer    As Date

    aArea := GetArea()
    nAverageCount := 0
    aSraAverage := {}
    lResult := .T.
    cFilterFilial := ""

    // Determine the number of months in the selected reporting period.
    Do Case
        Case ::cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            nMonthCount := 3
        Case ::cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 6
        Case ::cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            nMonthCount := 9
        Case ::cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 12
        Otherwise
            nMonthCount := 3
    EndCase

    cFilterFilial += " (RA_FILIAL >= '" + ::aFilter[1] + "')"
    cFilterFilial += " AND (RA_FILIAL <= '" + Iif(Empty(::aFilter[2]), Replicate("Z", TamSX3("RA_FILIAL")[1]), ::aFilter[2]) + "')"

    ::aPeriods := { }

    For nMonth := 1 To nMonthCount
        dCurrentDate := SToD(::aParameters[2] + PadL(AllTrim(Str(nMonth)), 2, "0") + "01")
        cCalculationPeriod := ::aParameters[2] + PadL(AllTrim(Str(nMonth)), 2, "0")
        nMonthDayCount := RU07XFUN05_GetMonthSize(nMonth, Val(::aParameters[2]))
        dLastDateMonth := SToD(::aParameters[2] + PadL(AllTrim(Str(nMonth)), 2, "0") + Str(nMonthDayCount, 2))
        nSumEmployee := 0
        nFullRateEmployeeCount := 0
        nPartRateEmployeeCount := 0

        For nI := 1 To Len(aFullEmployee)
            dStartWorkMonthPer := Max(aFullEmployee[nI, 2], dCurrentDate)
            dFinishWorkMonthPer := Iif(Empty(aFullEmployee[nI, 3]), dLastDateMonth, Min(aFullEmployee[nI, 3], dLastDateMonth))
            If dStartWorkMonthPer <= dLastDateMonth .And. dFinishWorkMonthPer >= dCurrentDate
                nSumEmployee += dFinishWorkMonthPer - dStartWorkMonthPer + 1
            EndIf
        Next nI

        nFullRateEmployeeCount := nSumEmployee / nMonthDayCount

        AAdd(::aPeriods, cCalculationPeriod)

        // Calculate Average headcount of part rate employee in this month.
        cQuery := " SELECT COALESCE(SUM((CASE WHEN SRD.RD_PD = '001' THEN SRD.RD_HORAS * SRA.RA_HRSDIA ELSE SRD.RD_HORAS END )/(SRA.RA_HRSDIA * RCF.RCF_DIATRA)), 0) AS AVERAGEHEADCOUNT FROM " + RetSqlName("SRD") + " SRD "
        cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL "
        cQuery += " LEFT JOIN " + RetSqlName("RCF") + " RCF ON RCF.RCF_TNOTRA = (CASE WHEN SRA.RA_TNOTRAB = '001' THEN '@@@' ELSE SRA.RA_TNOTRAB END ) AND RCF.RCF_PER = SRD.RD_PERIODO AND RCF.RCF_PROCES = SRD.RD_PROCES"
        cQuery += " WHERE "
        cQuery += cFilterFilial
        cQuery += " AND SRA.RA_HOPARC = '1' "
        cQuery += " AND SRD.RD_PD IN ('001', '002') "
        cQuery += " AND SRD.RD_PERIODO = ? "
        cQuery += " AND CONCAT(SRD.RD_MAT,SRD.RD_FILIAL) IN (?) "
        cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
        cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
        cQuery += " AND RCF.D_E_L_E_T_  = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cCalculationPeriod)
        oStatement:SetIn(2, aNFullEmployee)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())
        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        nPartRateEmployeeCount := (cTab)->(AVERAGEHEADCOUNT)

        // Remember Average headcount in this month.
        AAdd(aSraAverage, { cCalculationPeriod, Round(nFullRateEmployeeCount + nPartRateEmployeeCount, 1) })

    Next nMonth

    // Calculate of Average headcount (people).
    For nI := 1 To Len(aSraAverage)
        nAverageCount += aSraAverage[nI][2]
    Next nI

    nAverageCount := Round(nAverageCount / nMonthCount, 0)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

    ::cCountAverListEmployee := CValToChar(nAverageCount)

Return lResult

/*/
{Protheus.doc} GetSubs21Table()

    This method biuld part2 subsection 1 for report.

    @type Method
    @params 
    @author dchizhov
    @since 05.05.2023
    @version 12.1.33
    @return oJson, Object, Json with part2 subsection 1 for report.
    @example oEFSFSSObj:AddContent(oEFSFSSObj:GetSubs21Table())
/*/
Method GetSubs21Table() Class RUHREFSPart2FSSReport

    Local oJson  As Object
    Local cJson  As Character
    Local nX     As Numeric
    Local nY     As Numeric
    Local aLast  As Array
    Local nCount As Numeric
    Local aValue As Array

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "style": "title"
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": ["46%", "4%", "10%", "10%", "10%", "10%", "10%"],
                    "body": [ 
                        [
                            {"rowSpan": 2}, {"rowSpan": 2},
                            {"rowSpan": 2}, {"rowSpan": 2},
                            {"colSpan": 3}, {},
                            {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {"colSpan": 5}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {"colSpan": 5}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {"colSpan": 5}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {"colSpan": 5}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := CRLF + CRLF + STR0071 + CRLF + CRLF // "Subsection 2.1. Calculation of the amounts of insurance premiums:"
    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0073 // "Name of indicator"
    oJson["content"][2]["table"]["body"][1, 2]["text"] := STR0074 // "Line code"
    oJson["content"][2]["table"]["body"][1, 3]["text"] := STR0075 // "Total since the beginning of the billing period"
    oJson["content"][2]["table"]["body"][1, 4]["text"] := STR0076 // "At the beginning of the reporting period"
    oJson["content"][2]["table"]["body"][1, 5]["text"] := STR0077 // "Including for the last three months of the reporting period"
    oJson["content"][2]["table"]["body"][2, 5]["text"] := STR0078 // "1 month"
    oJson["content"][2]["table"]["body"][2, 6]["text"] := STR0079 // "2 month"
    oJson["content"][2]["table"]["body"][2, 7]["text"] := STR0080 // "3 month"
    oJson["content"][2]["table"]["body"][1, 1]["margin"] := {0, 8, 0, 0 }
    oJson["content"][2]["table"]["body"][1, 2]["margin"] := {0, 3, 0, 0 }
    oJson["content"][2]["table"]["body"][1, 3]["margin"] := {0, 3, 0, 0 }
    oJson["content"][2]["table"]["body"][1, 4]["margin"] := {0, 3, 0, 0 }
    For nX := 1 To 7
        oJson["content"][2]["table"]["body"][3, nX]["text"] := CValToChar(nX)
    Next nX
    oJson["content"][2]["table"]["body"][ 4, 1]["text"] := STR0081 // "The amount of payments and other remuneration accrued in favor of individuals in accordance with Article 20.1 of the Federal Law of July 24, 1998 No. 125-FZ 'On Compulsory Social Insurance against Industrial Accidents and Occupational Diseases'"
    oJson["content"][2]["table"]["body"][ 5, 1]["text"] := STR0082 // "The amount not subject to insurance premiums in accordance with Article 20.2 of the Federal Law of July 24, 1998 No. 125-FZ 'On Compulsory Social Insurance against Industrial Accidents and Occupational Diseases'"
    oJson["content"][2]["table"]["body"][ 6, 1]["text"] := STR0083 // "Basis for calculating insurance premiums (str.1 - str.2)"
    oJson["content"][2]["table"]["body"][ 7, 1]["text"] := STR0084 // "of which: the amount of payments in favor of working disabled people"
    oJson["content"][2]["table"]["body"][ 8, 1]["text"] := STR0085 // "Amount of insurance rate in accordance with the class of professional risk (%)"
    oJson["content"][2]["table"]["body"][ 9, 1]["text"] := STR0086 // "Discount to the insurance rate (%)"
    oJson["content"][2]["table"]["body"][10, 1]["text"] := STR0087 // "Insurance rate surcharge (%)"
    oJson["content"][2]["table"]["body"][11, 1]["text"] := STR0088 // "The amount of the insurance rate, taking into account the discount (surcharge) (%) (filled in with three decimal places after the decimal point)"
    oJson["content"][2]["table"]["body"][12, 1]["text"] := STR0089 // "Insurance premiums calculated"
    For nX := 1 To 9
        oJson["content"][2]["table"]["body"][3 + nX, 2]["text"] := CValToChar(nX)
    Next nX
    nCount := Len(::aPeriods) - 2
    If nCount > 0
        nCount -= 1
        aLast := {}
        aValue := Array(4)
        aValue[1] := {0, 0, 0, 0, 0}
        aValue[2] := {0, 0, 0, 0, 0}
        aValue[3] := {0, 0, 0, 0, 0}
        aValue[4] := {0, 0, 0, 0, 0}
        For nX := 1 To nCount
            Aadd(aLast, ::aPeriods[nX])
        Next nX
        aValue[1, 1] := ::GetSumSRD1(, ::aPeriods)
        aValue[1, 2] := ::GetSumSRD1(, aLast)
        aValue[2, 1] := ::GetSumSRD1(2, ::aPeriods)
        aValue[2, 2] := ::GetSumSRD1(2, aLast)
        aValue[4, 1] := ::GetSumSRD1(, ::aPeriods, .T.) - ::GetSumSRD1(2, ::aPeriods, .T.)
        aValue[4, 2] := ::GetSumSRD1(, aLast, .T.) - ::GetSumSRD1(2, aLast, .T.)
        For nX := 1 To 3
            aValue[1, 2 + nX] := ::GetSumSRD1(, {::aPeriods[nCount + nX]})
            aValue[2, 2 + nX] := ::GetSumSRD1(2, {::aPeriods[nCount + nX]})
            aValue[4, 2 + nX] := ::GetSumSRD1(, {::aPeriods[nCount + nX]}, .T.) - ::GetSumSRD1(2, {::aPeriods[nCount + nX]}, .T.)
        Next nX
        For nX := 1 To 5
            aValue[3, nX] := aValue[1, nX] - aValue[2, nX]
        Next nX
        For nX := 1 To 4
            For nY := 1 To 5
                oJson["content"][2]["table"]["body"][nX + 3, nY + 2]["text"] := Str(aValue[nX, nY], , 2)
            Next nY
        Next nX
        oJson["content"][2]["table"]["body"][12, 3]["text"] := Str(::GetSumSRD2(::aPeriods), , 2)
        oJson["content"][2]["table"]["body"][12, 4]["text"] := Str(::GetSumSRD2(aLast), , 2)
        For nX := 1 To 3
            oJson["content"][2]["table"]["body"][12, 4 + nX]["text"] := Str(::GetSumSRD2({::aPeriods[nCount + nX]}), , 2)
        Next nX
    EndIf
    nCount := AllTrim(fDescRCC('S038', "1", 133, 1, 5, 8))
    oJson["content"][2]["table"]["body"][ 8, 3]["text"] := nCount
    oJson["content"][2]["table"]["body"][ 9, 3]["text"] := NOT_REALIZED_SYMBOL
    oJson["content"][2]["table"]["body"][10, 3]["text"] := NOT_REALIZED_SYMBOL
    nCount := Round(Val(nCount), 3)
    oJson["content"][2]["table"]["body"][11, 3]["text"] := Alltrim(Str(nCount, , 3))

Return oJson

/*/
{Protheus.doc} GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid)

    This method Calculation Sum for Table1 item for report by selected period.

    @type Method
    @params nCaseCalculation, Numeric, Case for calculation (1 for 1 item? 2 for 2 item).
    @params aPeriods        , Array  , Array of period by calculation.
    @params lOnlyWorkInvalid, Character, Filial code.
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
    @return nResult, Numeric, Sum for Table1 item for report by selected period.
    @example ::aValForStr[1] := ::GetSumSRD1(1 , aPeriods, .F.)
             ::aValForStr[4] := ::GetSumSRD1(1 , aPeriods, .T.) - ::GetSumSRD1(2 , aPeriods, .T.)
/*/
Method GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid) Class RUHREFSPart2FSSReport

    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cFilterFilial As Character
    Local nResult       As Numeric

    Default nCaseCalculation := 1
    Default lOnlyWorkInvalid := .F.

    nResult := 0

    aArea := GetArea()
    cFilterFilial := ""
    cFilterFilial += " (RA_FILIAL >= '" + ::aFilter[1] + "')"
    cFilterFilial += " AND (RA_FILIAL <= '" + Iif(Empty(::aFilter[2]), Replicate("Z", TamSX3("RA_FILIAL")[1]), ::aFilter[2]) + "')"

    cQuery := "SELECT SUM(SRD.RD_VALOR) AS SUMMA FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD AND SRV.RV_TIPOCOD = '1' "
    cQuery += " WHERE "
    cQuery += cFilterFilial
    cQuery += " AND CONCAT(SRD.RD_MAT,SRD.RD_FILIAL) IN (?) "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRV.RV_COD NOT IN ('395', '446') "
    If nCaseCalculation == 2
        cQuery += " AND SRV.RV_FGTS = 'N' "
    EndIf

    If lOnlyWorkInvalid
        cQuery += " AND SRA.RA_SITFOLH <> 'D' "
        cQuery += " AND SRA.RA_DEFIFIS = '1' 
    EndIf
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aEmplAll)
    oStatement:SetIn(2, aPeriods)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nResult := (cTab)->SUMMA

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return nResult

/*/
{Protheus.doc} GetSumSRD2(aPeriods)

    This method for calculating the amount of insurance premiums for a selected period.

    @type Method
    @params aPeriods, Array, Array of period by calculation.
    @author dchizhov
    @since 10.05.2023
    @version 12.1.33
    @return nResult, Numeric, Sum for Table1 item for report by selected period.
    @example ::aValForStr[1] := ::GetSumSRD1(1 , aPeriods, .F.)
             ::aValForStr[4] := ::GetSumSRD1(1 , aPeriods, .T.) - ::GetSumSRD1(2 , aPeriods, .T.)
/*/
Method GetSumSRD2(aPeriods) Class RUHREFSPart2FSSReport

    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cFilterFilial As Character
    Local nResult       As Numeric

    Default nCaseCalculation := 1
    Default lOnlyWorkInvalid := .F.

    nResult := 0

    aArea := GetArea()
    cFilterFilial := ""
    cFilterFilial += " (RA_FILIAL >= '" + ::aFilter[1] + "')"
    cFilterFilial += " AND (RA_FILIAL <= '" + Iif(Empty(::aFilter[2]), Replicate("Z", TamSX3("RA_FILIAL")[1]), ::aFilter[2]) + "')"

    cQuery := "SELECT SUM(SRD.RD_VALOR) AS SUMMA FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += cFilterFilial
    cQuery += " AND CONCAT(SRD.RD_MAT,SRD.RD_FILIAL) IN (?) "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRV.RV_CODFOL IN (" + INS_PREM_TYPE_PAYING_ID_COD_FOLS + ") "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aEmplAll)
    oStatement:SetIn(2, aPeriods)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nResult := (cTab)->SUMMA

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return nResult

/*/
{Protheus.doc} GetSubs23Table()

    This method biuld part2 subsection 3 for report.

    @type Method
    @params 
    @author dchizhov
    @since 10.05.2023
    @version 12.1.33
    @return oJson, Object, Json with part2 subsection 3 for report.
    @example oEFSFSSObj:AddContent(oEFSFSSObj:GetGeneralInfo())
/*/
Method GetSubs23Table() Class RUHREFSPart2FSSReport

    Local oJson  As Object
    Local cJson  As Character
    Local nX     As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "style": "title",
                "fontSize": 9,
                "pageBreak": "before",
                "alignment": "left",
                "pageOrientation": "landscape"
            },
            {
                "margin": [5, 18, 0, 0],
                "style": "normal9"
            },
            {
                "margin": [0, 15, 5, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": ["auto", 10, 20, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 15, 5, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": ["auto", 10, 20, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [140, 15, 60, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [110, 25, 75, 45, 30, 30, 30, 30, 30, 30, 30],
                    "body": [ 
                        [
                            {"rowSpan": 4, "margin": [0, 25, 0, 0]}, {"rowSpan": 4, "margin": [0, 20, 0, 0]},
                            {"rowSpan": 4, "margin": [0, 18, 0, 0]}, {"colSpan": 8}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {"rowSpan": 3, "margin": [0, 15, 0, 0]}, {"colSpan": 7}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {"rowSpan": 2, "margin": [0, 3, 0, 0]}, {"rowSpan": 2, "margin": [0, 3, 0, 0]}, 
                            {"colSpan": 4}, {}, {}, {}, {"rowSpan": 2, "margin": [0, 3, 0, 0]}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := CRLF + CRLF + STR0072 + CRLF + CRLF // "Subsection 2.3. Information on the results of mandatory preliminary and periodic medical examinations of employees and a special assessment of working conditions at the beginning of the year"
    oJson["content"][2]["text"] := STR0107 // "Conducting mandatory preliminary and periodic medical examinations of employees:"
    oJson["content"][3]["table"]["body"][1,  1]["text"] := STR0108 // "Total number of employees subject to mandatory preliminary and periodic medical examinations (persons)"
    oJson["content"][3]["table"]["body"][1,  3]["text"] := STR0103 + NOT_LOCALIZED_SYMBOL_NIL + STR0104 // "«", "»"
    oJson["content"][4]["table"]["body"][1,  1]["text"] := STR0109 // "Number of employees who have passed mandatory preliminary and periodic medical examinations (persons)"
    oJson["content"][4]["table"]["body"][1,  3]["text"] := STR0103 + NOT_LOCALIZED_SYMBOL_NIL + STR0104 // "«", "»"
    oJson["content"][5]["table"]["body"][1,  1]["text"] := STR0073 // "Name of indicator"
    oJson["content"][5]["table"]["body"][1,  2]["text"] := STR0074 // "Line code"
    oJson["content"][5]["table"]["body"][1,  3]["text"] := STR0110 // "Total number of jobs insured"
    oJson["content"][5]["table"]["body"][1,  4]["text"] := STR0111 // "Number of jobs for which a special assessment of working conditions was carried out"
    oJson["content"][5]["table"]["body"][2,  4]["text"] := STR0112 // "Total"
    oJson["content"][5]["table"]["body"][2,  5]["text"] := STR0113 // "including those related to classes (subclasses) of working conditions"
    oJson["content"][5]["table"]["body"][3,  5]["text"] := STR0114 + CRLF + STR0118 // "1", "class
    oJson["content"][5]["table"]["body"][3,  6]["text"] := STR0115 + CRLF + STR0119 // "2", "class
    oJson["content"][5]["table"]["body"][3,  7]["text"] := STR0116 + " " + STR0120 // "3", "class
    oJson["content"][5]["table"]["body"][3, 11]["text"] := STR0117 + CRLF + STR0121 // "4", "class
    oJson["content"][5]["table"]["body"][4,  7]["text"] := STR0122 // "3.1"
    oJson["content"][5]["table"]["body"][4,  8]["text"] := STR0123 // "3.2"
    oJson["content"][5]["table"]["body"][4,  9]["text"] := STR0124 // "3.3"
    oJson["content"][5]["table"]["body"][4, 10]["text"] := STR0125 // "3.4"
    For nX := 1 To 11
        oJson["content"][5]["table"]["body"][5, nX]["text"] := CValToChar(nX)
    Next nX
    oJson["content"][5]["table"]["body"][6, 1]["text"] := STR0126 // "Conducting a special assessment of working conditions"
    oJson["content"][5]["table"]["body"][6, 2]["text"] := "1"

Return oJson

/*/
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oEFSObject:AddContent(oEFSObject:GetTitleList())
/*/
Method AddContent(oJson) Class RUHREFSPart2FSSReport

    Local nX   As Numeric
    Local lRet As Logical

    lRet := .F.
    If !::oGeneralJson:HasProperty("content")
        ::oGeneralJson["content"] := {}
    EndIf
    If oJson:HasProperty("content")
        If ValType(oJson["content"]) == "A"
            For nX := 1 To Len(oJson["content"])
                lRet := .T.
                Aadd(::oGeneralJson["content"], oJson["content"][nX])
            Next nX
        EndIf
    EndIf

Return lRet
