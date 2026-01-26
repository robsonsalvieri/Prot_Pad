#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"

#DEFINE NODATA "No data"

/*/
{Protheus.doc} RUSocialInsuranceFundTable2
    Class for generating a Table 2 for report FSS.

    @type Class
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
/*/
Class RUSocialInsuranceFundTable2 From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters As Array // Array of parameters from pergunte.

    Data cPageCount  As Character // Count of page in format "XXX".

    Data aValForStr  As Array // Array of sums for Table2.

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetSumSRD1()

    Method GenerTable2View()

    Method MakeData()
    Method GetViewReport()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aFilter, cNum, cCod)
    Default RUSocialInsuranceFundTable2 constructor.

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params aFilter,     Array,     Array of personnel numbers for filter.
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return RUSocialInsuranceFundTable2, Object, RUSocialInsuranceFundTable2 instance.
    @example ::oTable2 := RUSocialInsuranceFundTable2():New(::aParameters, ::cFilter, ::aFilter)
/*/
Method New(aParameters, cFilter, aFilter) Class RUSocialInsuranceFundTable2

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageCount := "001"

    Self:aValForStr := Array(20)
    aFill(Self:aValForStr, 0)

    Self:aValForStr[1] := {0, 0}
    Self:aValForStr[2] := {0, 0, 0, 0, 0, 0}
    Self:aValForStr[14] := {0, 0}
    Self:aValForStr[15] := {0, 0, 0, 0, 0, 0}
    Self:aValForStr[16] := {0, 0, 0, 0, 0, 0}

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the FSS report Table2.

    @type Method
    @params aPeriods, Array, Array of periods for calculation
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return 
    @example ::oTable2:MakeData()
/*/
Method MakeData(aPeriods) Class RUSocialInsuranceFundTable2

    Local lResult := .T. As Logical
    Local nPeriods       As Numeric
    Local nI             As Numeric

    nPeriods := Len(aPeriods) - 2

    If nPeriods > 0

        nPeriods -= 1
        ::aValForStr[2, 1] := ::GetSumSRD1(aPeriods)

        For nI := 1 To 3
            ::aValForStr[2, 3 + nI] := ::GetSumSRD1({ aPeriods[nPeriods + nI] })
        Next nI

        ::aValForStr[2, 3] := ::aValForStr[2, 4] + ::aValForStr[2, 5] + ::aValForStr[2, 6]

        ::aValForStr[16] := AClone(::aValForStr[2])

        ::aValForStr[8] := ::aValForStr[1, 1] + ::aValForStr[1, 2] + ::aValForStr[2, 1] + ::aValForStr[3] + ;
        ::aValForStr[4] + ::aValForStr[5] + ::aValForStr[6] + ::aValForStr[7] 

        ::aValForStr[18] := ::aValForStr[12] + ::aValForStr[14, 2] + ::aValForStr[15, 1] + ::aValForStr[16, 1] + ::aValForStr[17]

    Else
        lResult := .F.
    EndIf

Return lResult

/*/
{Protheus.doc} GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid)
    This method Calculation Sum for Table2 item for report by selected period.

    @type Method
    @params aPeriods, Array  , Array of period by calculation.
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return nResult, Numeric, Sum for Table2 item for report by selected period.
    @example ::aValForStr[3] := ::GetSumSRD1(aPeriods)
/*/
Method GetSumSRD1(aPeriods) Class RUSocialInsuranceFundTable2

    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local nI            As Numeric
    Local cFilterFilial As Character
    Local nResult       As Character

    Default nCaseCalculation := 1
    Default lOnlyWorkInvalid := .F.

    aArea := GetArea()
    cFilterFilial := ""
    nI := At("RA_FILIAL", ::cFilter, 1)
    If nI > 0
        cFilterFilial += " (SRA." + SubStr(::cFilter, nI, At( ")", ::cFilter, nI + 1) - nI + 1)
    EndIf
    nI := At("RA_FILIAL", ::cFilter, nI + 1)
    If nI > 0
        If !Empty(cFilterFilial)
            cFilterFilial += " AND "
        EndIf
        cFilterFilial += " (SRA." + SubStr(::cFilter, nI, At( ") ", ::cFilter, nI + 1) - nI + 1)
    EndIf

    cQuery := "SELECT SUM(SRD.RD_VALOR) AS SUMMA FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL "
    cQuery += " WHERE "
    cQuery += cFilterFilial
    cQuery += " AND CONCAT(SRD.RD_MAT,SRD.RD_FILIAL) IN (?) "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRV.RV_COD = '841' "
    cQuery += " AND SRV.RV_CODFOL = '0149' "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aFilter)
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
{Protheus.doc} GenerTable2View()
    This method generates Json object with table for Table2 reports. 

    @type Method
    @params 
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return oJson, Object, Generated Json object.
    @example oJson := ::GenerTable2View()
/*/
Method GenerTable2View() Class RUSocialInsuranceFundTable2

    Local oJson As Object
    Local nI    As Numeric
    Local nJ    As Numeric

    oJson := JsonObject():New()
    oJson["width"] := "100%"
    oJson["widths"] := {30, "*", 40, "auto", 40, 3, 30, "*", 40, "auto", 40}
    oJson["body"] := { }
    For nI := 1 To 25
        AAdd(oJson["body"], {})
        For nJ := 1 To 11
            AAdd(oJson["body"][nI], JsonObject():New())
        Next nJ
        oJson["body"][nI, 6]["text"] := ""
        oJson["body"][nI, 6]["border"] := {.T., .F., .T., .F.}
    Next nI

    oJson["body"][24, 6]["colSpan"] := 6
    oJson["body"][24, 6]["rowSpan"] := 2
    oJson["body"][24, 6]["border"] := {.F., .F., .F., .F.}

    // string 1
        oJson["body"][1, 1]["colSpan"] := 3
        oJson["body"][1, 1]["text"] := STR0085
        oJson["body"][1, 1]["margin"] := {0, 4, 0, 0}
        oJson["body"][1, 4]["text"] := STR0086
        oJson["body"][1, 5]["text"] := STR0087
        oJson["body"][1, 5]["margin"] := {0, 4, 0, 0}
        oJson["body"][1, 7]["colSpan"] := 3
        oJson["body"][1, 7]["text"] := STR0085
        oJson["body"][1, 7]["margin"] := {0, 4, 0, 0}
        oJson["body"][1, 10]["text"] := STR0086
        oJson["body"][1, 11]["text"] := STR0087
        oJson["body"][1, 11]["margin"] := {0, 4, 0, 0}

    // string 2
        oJson["body"][2, 1]["colSpan"] := 3
        oJson["body"][2, 1]["text"] := "1"
        oJson["body"][2, 4]["text"] := "2"
        oJson["body"][2, 5]["text"] := "3"
        oJson["body"][2, 7]["colSpan"] := 3
        oJson["body"][2, 7]["text"] := "1"
        oJson["body"][2, 10]["text"] := "2"
        oJson["body"][2, 11]["text"] := "3"

    // string 3
        oJson["body"][3, 1]["colSpan"] := 3
        oJson["body"][3, 1]["rowSpan"] := 3
        oJson["body"][3, 1]["text"] := STR0088
        oJson["body"][3, 1]["alignment"] := "left"
        oJson["body"][3, 4]["rowSpan"] := 3
        oJson["body"][3, 4]["text"] := "1"
        oJson["body"][3, 5]["rowSpan"] := 3
        oJson["body"][3, 5]["text"] := AllTrim(Str(::aValForStr[1, 1], , 2))
        oJson["body"][3, 7]["colSpan"] := 3
        oJson["body"][3, 7]["text"] := STR0106
        oJson["body"][3, 7]["alignment"] := "left"
        oJson["body"][3, 10]["text"] := "12"
        oJson["body"][3, 11]["text"] := NODATA

    // string 4
        oJson["body"][4, 7]["rowSpan"] := 2
        oJson["body"][4, 7]["text"] := STR0107
        oJson["body"][4, 7]["alignment"] := "left"
        oJson["body"][4, 8]["colSpan"] := 2
        oJson["body"][4, 8]["text"] := STR0108
        oJson["body"][4, 8]["alignment"] := "left"
        oJson["body"][4, 10]["text"] := "13"
        oJson["body"][4, 11]["text"] := NODATA

    // string 5
        oJson["body"][5, 8]["colSpan"] := 2
        oJson["body"][5, 8]["text"] := STR0109
        oJson["body"][5, 8]["alignment"] := "left"
        oJson["body"][5, 10]["text"] := "14"
        oJson["body"][5, 11]["text"] := NODATA

    // string 6
        oJson["body"][6, 1]["colSpan"] := 3
        oJson["body"][6, 1]["text"] := STR0089
        oJson["body"][6, 1]["alignment"] := "left"
        oJson["body"][6, 4]["text"] := "1.1"
        oJson["body"][6, 5]["text"] := NODATA
        oJson["body"][6, 7]["colSpan"] := 3
        oJson["body"][6, 7]["text"] := STR0110
        oJson["body"][6, 7]["alignment"] := "left"
        oJson["body"][6, 10]["text"] := "14.1"
        oJson["body"][6, 11]["text"] := NODATA

    // string 7
        oJson["body"][7, 1]["colSpan"] := 3
        oJson["body"][7, 1]["text"] := STR0090
        oJson["body"][7, 1]["alignment"] := "left"
        oJson["body"][7, 4]["text"] := "2"
        oJson["body"][7, 4]["rowSpan"] := 6
        oJson["body"][7, 5]["text"] := AllTrim(Str(::aValForStr[2, 1], , 2))
        oJson["body"][7, 5]["rowSpan"] := 6
        oJson["body"][7, 7]["colSpan"] := 3
        oJson["body"][7, 7]["text"] := STR0111
        oJson["body"][7, 7]["alignment"] := "left"
        oJson["body"][7, 10]["text"] := "15"
        oJson["body"][7, 10]["rowSpan"] := 6
        oJson["body"][7, 11]["text"] := NODATA
        oJson["body"][7, 11]["rowSpan"] := 6

    // string 8
        oJson["body"][8, 1]["colSpan"] := 2
        oJson["body"][8, 1]["text"] := STR0091
        oJson["body"][8, 1]["alignment"] := "left"
        oJson["body"][8, 3]["text"] := AllTrim(Str(::aValForStr[2, 2], , 2))
        oJson["body"][8, 7]["colSpan"] := 2
        oJson["body"][8, 7]["text"] := STR0112
        oJson["body"][8, 7]["alignment"] := "left"
        oJson["body"][8, 9]["text"] := NODATA

    // string 9
        oJson["body"][9, 1]["colSpan"] := 2
        oJson["body"][9, 1]["text"] := STR0092
        oJson["body"][9, 1]["alignment"] := "left"
        oJson["body"][9, 3]["text"] := AllTrim(Str(::aValForStr[2, 3], , 2))
        oJson["body"][9, 7]["colSpan"] := 2
        oJson["body"][9, 7]["text"] := STR0113
        oJson["body"][9, 7]["alignment"] := "left"
        oJson["body"][9, 9]["text"] := NODATA

    // string 10
        oJson["body"][10, 1]["colSpan"] := 2
        oJson["body"][10, 1]["text"] := STR0093
        oJson["body"][10, 1]["alignment"] := "left"
        oJson["body"][10, 3]["text"] := AllTrim(Str(::aValForStr[2, 4], , 2))
        oJson["body"][10, 7]["colSpan"] := 2
        oJson["body"][10, 7]["text"] := STR0114
        oJson["body"][10, 7]["alignment"] := "left"
        oJson["body"][10, 9]["text"] := NODATA
    
    // string 11
        oJson["body"][11, 1]["colSpan"] := 2
        oJson["body"][11, 1]["text"] := STR0094
        oJson["body"][11, 1]["alignment"] := "left"
        oJson["body"][11, 3]["text"] := AllTrim(Str(::aValForStr[2, 5], , 2))
        oJson["body"][11, 7]["colSpan"] := 2
        oJson["body"][11, 7]["text"] := STR0115
        oJson["body"][11, 7]["alignment"] := "left"
        oJson["body"][11, 9]["text"] := NODATA
    
    // string 12
        oJson["body"][12, 1]["colSpan"] := 2
        oJson["body"][12, 1]["text"] := STR0095
        oJson["body"][12, 1]["alignment"] := "left"
        oJson["body"][12, 3]["text"] := AllTrim(Str(::aValForStr[2, 6], , 2))
        oJson["body"][12, 7]["colSpan"] := 2
        oJson["body"][12, 7]["text"] := STR0116
        oJson["body"][12, 7]["alignment"] := "left"
        oJson["body"][12, 9]["text"] := NODATA

    // string 13
        oJson["body"][13, 1]["colSpan"] := 3
        oJson["body"][13, 1]["text"] := STR0096
        oJson["body"][13, 1]["alignment"] := "left"
        oJson["body"][13, 4]["text"] := "3"
        oJson["body"][13, 5]["text"] := NODATA
        oJson["body"][13, 7]["colSpan"] := 3
        oJson["body"][13, 7]["text"] := STR0117
        oJson["body"][13, 7]["alignment"] := "left"
        oJson["body"][13, 10]["text"] := "16"
        oJson["body"][13, 10]["rowSpan"] := 7
        oJson["body"][13, 11]["text"] := AllTrim(Str(::aValForStr[16, 1], , 2))
        oJson["body"][13, 11]["rowSpan"] := 7

    // string 14
        oJson["body"][14, 1]["colSpan"] := 3
        oJson["body"][14, 1]["text"] := STR0097
        oJson["body"][14, 1]["alignment"] := "left"
        oJson["body"][14, 4]["text"] := "4"
        oJson["body"][14, 5]["text"] := NODATA
        oJson["body"][14, 7]["colSpan"] := 2
        oJson["body"][14, 7]["text"] := STR0118
        oJson["body"][14, 7]["alignment"] := "left"
        oJson["body"][14, 9]["text"] := AllTrim(Str(::aValForStr[16, 2], , 2))

    // string 15
        oJson["body"][15, 1]["colSpan"] := 3
        oJson["body"][15, 1]["rowSpan"] := 3
        oJson["body"][15, 1]["text"] := STR0098
        oJson["body"][15, 1]["alignment"] := "left"
        oJson["body"][15, 4]["rowSpan"] := 3
        oJson["body"][15, 4]["text"] := "5"
        oJson["body"][15, 5]["rowSpan"] := 3
        oJson["body"][15, 5]["text"] := NODATA
        oJson["body"][15, 7]["colSpan"] := 2
        oJson["body"][15, 7]["text"] := STR0119
        oJson["body"][15, 7]["border"] := {.T., .T., .T., .F.}
        oJson["body"][15, 7]["alignment"] := "left"
        oJson["body"][15, 9]["rowSpan"] := 2
        oJson["body"][15, 9]["text"] := AllTrim(Str(::aValForStr[16, 3], , 2))

    // string 16
        oJson["body"][16, 7]["colSpan"] := 2
        oJson["body"][16, 7]["text"] := STR0120
        oJson["body"][16, 7]["border"] := {.T., .F., .T., .T.}
        oJson["body"][16, 7]["alignment"] := "left"

    // string 17
        oJson["body"][17, 7]["colSpan"] := 2
        oJson["body"][17, 7]["text"] := ""
        oJson["body"][17, 7]["alignment"] := "left"
        oJson["body"][17, 9]["text"] := AllTrim(Str(::aValForStr[16, 4], , 2))

    // string 18
        oJson["body"][18, 1]["colSpan"] := 3
        oJson["body"][18, 1]["rowSpan"] := 3
        oJson["body"][18, 1]["text"] := STR0099
        oJson["body"][18, 1]["alignment"] := "left"
        oJson["body"][18, 4]["rowSpan"] := 3
        oJson["body"][18, 4]["text"] := "6"
        oJson["body"][18, 5]["rowSpan"] := 3
        oJson["body"][18, 5]["text"] := NODATA
        oJson["body"][18, 7]["colSpan"] := 2
        oJson["body"][18, 7]["text"] := ""
        oJson["body"][18, 7]["alignment"] := "left"
        oJson["body"][18, 9]["text"] := AllTrim(Str(::aValForStr[16, 5], , 2))

    // string 19
        oJson["body"][19, 7]["colSpan"] := 2
        oJson["body"][19, 7]["text"] := ""
        oJson["body"][19, 7]["alignment"] := "left"
        oJson["body"][19, 9]["text"] := AllTrim(Str(::aValForStr[16, 6], , 2))

    // string 20
        oJson["body"][20, 7]["colSpan"] := 3
        oJson["body"][20, 7]["text"] := STR0121
        oJson["body"][20, 7]["alignment"] := "left"
        oJson["body"][20, 10]["text"] := "17"
        oJson["body"][20, 11]["text"] := NODATA

    // string 21
        oJson["body"][21, 1]["colSpan"] := 3
        oJson["body"][21, 1]["text"] := STR0100
        oJson["body"][21, 1]["alignment"] := "left"
        oJson["body"][21, 4]["text"] := "7"
        oJson["body"][21, 5]["text"] := NODATA
        oJson["body"][21, 7]["colSpan"] := 3
        oJson["body"][21, 7]["text"] := STR0122
        oJson["body"][21, 7]["alignment"] := "left"
        oJson["body"][21, 10]["text"] := "18"
        oJson["body"][21, 11]["text"] := AllTrim(Str(::aValForStr[18], , 2))

    // string 22
        oJson["body"][22, 1]["colSpan"] := 3
        oJson["body"][22, 1]["text"] := STR0101
        oJson["body"][22, 1]["alignment"] := "left"
        oJson["body"][22, 4]["text"] := "8"
        oJson["body"][22, 5]["text"] := AllTrim(Str(::aValForStr[8], , 2))
        oJson["body"][22, 7]["colSpan"] := 3
        oJson["body"][22, 7]["text"] := STR0123
        oJson["body"][22, 7]["alignment"] := "left"
        oJson["body"][22, 10]["text"] := "19"
        oJson["body"][22, 11]["text"] := AllTrim(Str(::aValForStr[19], , 2))

    // string 23
        oJson["body"][23, 1]["colSpan"] := 3
        oJson["body"][23, 1]["text"] := STR0102
        oJson["body"][23, 1]["alignment"] := "left"
        oJson["body"][23, 4]["text"] := "9"
        oJson["body"][23, 5]["text"] := NODATA
        oJson["body"][23, 7]["colSpan"] := 3
        oJson["body"][23, 7]["text"] := STR0124 + CRLF + STR0125
        oJson["body"][23, 7]["alignment"] := "left"
        oJson["body"][23, 10]["text"] := "20"
        oJson["body"][23, 11]["text"] := NODATA

    // string 24
        oJson["body"][24, 1]["rowSpan"] := 2
        oJson["body"][24, 1]["text"] := STR0103
        oJson["body"][24, 1]["alignment"] := "left"
        oJson["body"][24, 2]["colSpan"] := 2
        oJson["body"][24, 2]["text"] := STR0104
        oJson["body"][24, 2]["alignment"] := "left"
        oJson["body"][24, 4]["text"] := "10"
        oJson["body"][24, 5]["text"] := NODATA

    // string 25
        oJson["body"][25, 2]["colSpan"] := 2
        oJson["body"][25, 2]["text"] := STR0105
        oJson["body"][25, 2]["alignment"] := "left"
        oJson["body"][25, 4]["text"] := "11"
        oJson["body"][25, 5]["text"] := NODATA

Return oJson

/*/
{Protheus.doc} GetViewReport(cDateReport, oContent, oSameJson)
    This method generates Json for output.

    @type Method
    @params cDateReport, Character, Date of report.
    @params oContent,  Object, Object with array of content for report.
    @params oSameJson, Object, Object Same part of Json.
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetViewReport(cDateReport, oContent, oSameJson)
            RUSocialInsuranceFundTable2:GetViewReport(cDateReport, oContent, oSameJson)
/*/
Method GetViewReport(cDateReport, oContent, oSameJson) Class RUSocialInsuranceFundTable2

    Local lResult := .T. As Logical
    Local oJson          As Object

    oJson := JsonObject():New()
    oJson["style"] := "title"
    oJson["margin"] := {5, 18, 0, 0}
    oJson["text"] := STR0126 + CRLF + CRLF
    oJson["pageBreak"] := "before"
    AAdd(oContent, oJson)
    AAdd(oContent, oSameJson)
    oJson := JsonObject():New()
    oJson["style"] := "normal"
    oJson["fontSize"] := 8
    oJson["alignment"] := "center"
    oJson["margin"] := {5, -1, 5, 0}
    oJson["table"] := ::GenerTable2View()

    AAdd(oContent, oJson)

Return lResult
