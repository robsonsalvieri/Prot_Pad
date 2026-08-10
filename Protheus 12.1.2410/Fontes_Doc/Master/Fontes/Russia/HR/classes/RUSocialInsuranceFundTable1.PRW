#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"

/*/
{Protheus.doc} RUSocialInsuranceFundTable1
    Class for generating a Table 1 for report FSS.

    @type Class
    @author dchizhov
    @since 2022/11/29
    @version 12.1.33
/*/
Class RUSocialInsuranceFundTable1 From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters As Array // Array of parameters from pergunte.

    Data cPageCount  As Character // Count of page in format "XXX".

    Data aValForStr  As Array // Array of sums for Table1

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetSumSRD1()

    Method GenerTable1View()

    Method MakeData()
    Method GetViewReport()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aFilter)
    Default RUSocialInsuranceFundTable1 constructor.

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params aFilter,     Array,     Array of personnel numbers for filter.
    @author dchizhov
    @since 2022/11/29
    @version 12.1.33
    @return RUSocialInsuranceFundTable1, Object, RUSocialInsuranceFundTable1 instance.
    @example ::oTable1 := RUSocialInsuranceFundTable1():New(::aParameters, ::cFilter, ::aFilter)
/*/
Method New(aParameters, cFilter, aFilter) Class RUSocialInsuranceFundTable1

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageCount := "001"

    Self:aValForStr := { {0, 0, 0, 0}, ;
                         {0, 0, 0, 0}, ;
                         {0, 0, 0, 0}, ;
                         {0, 0, 0, 0}, ;
                         "0", "0", "0", "0", 0 }

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the FSS report Table1.

    @type Method
    @params aPeriods, Array, Array of periods for calculation
    @author dchizhov
    @since 2022/11/29
    @version 12.1.33
    @return 
    @example ::oTable1:MakeData()
/*/
Method MakeData(aPeriods) Class RUSocialInsuranceFundTable1

    Local lResult := .T. As Logical
    Local nPeriods       As Numeric
    Local nI             As Numeric

    nPeriods := Len(aPeriods) - 2

    If nPeriods > 0

        nPeriods -= 1
        ::aValForStr[1, 1] := ::GetSumSRD1( , aPeriods)
        ::aValForStr[2, 1] := ::GetSumSRD1(2 , aPeriods)
        ::aValForStr[3, 1] := ::aValForStr[1, 1] - ::aValForStr[2, 1]
        ::aValForStr[4, 1] := ::GetSumSRD1(1 , aPeriods, .T.) - ::GetSumSRD1(2 , aPeriods, .T.)

        For nI := 1 To 3
            ::aValForStr[1, 1 + nI] := ::GetSumSRD1( , { aPeriods[nPeriods + nI] })
            ::aValForStr[2, 1 + nI] := ::GetSumSRD1(2 , { aPeriods[nPeriods + nI] })
            ::aValForStr[3, 1 + nI] := ::aValForStr[1, 1 + nI] - ::aValForStr[2, 1 + nI]
            ::aValForStr[4, 1 + nI] := ::GetSumSRD1(1 , { aPeriods[nPeriods + nI] }, .T.) - ::GetSumSRD1(2 , { aPeriods[nPeriods + nI] }, .T.)
        Next nI

        ::aValForStr[5] := AllTrim(fDescRCC('S038', "1", 133, 1, 5, 8))
        ::aValForStr[9] := Val(::aValForStr[5]) - Val(::aValForStr[6]) + Val(::aValForStr[7])

    Else
        lResult := .F.
    EndIf


Return lResult

/*/
{Protheus.doc} GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid)
    This method Calculation Sum for Table1 item for report by selected period.

    @type Method
    @params nCaseCalculation, Numeric, Case for calculation (1 for 1 item? 2 for 2 item).
    @params aPeriods        , Array  , Array of period by calculation.
    @params lOnlyWorkInvalid, Character, Filial code.
    @author dchizhov
    @since 2022/11/29
    @version 12.1.33
    @return nResult, Numeric, Sum for Table1 item for report by selected period.
    @example ::aValForStr[1] := ::GetSumSRD1(1 , aPeriods, .F.)
             ::aValForStr[4] := ::GetSumSRD1(1 , aPeriods, .T.) - ::GetSumSRD1(2 , aPeriods, .T.)
/*/
Method GetSumSRD1(nCaseCalculation, aPeriods, lOnlyWorkInvalid) Class RUSocialInsuranceFundTable1

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
{Protheus.doc} GenerTable1View()
    This method generates Json object with table for Table1 reports. 

    @type Method
    @params 
    @author dchizhov
    @since 2022/11/30
    @version 12.1.33
    @return oJson, Object, Generated Json object.
    @example oJson := ::GenerTable1View()
/*/
Method GenerTable1View() Class RUSocialInsuranceFundTable1

    Local oJson As Object
    Local nI    As Numeric
    Local nJ    As Numeric

    oJson := JsonObject():New()
    oJson["width"] := "100%"
    oJson["widths"] := {"*", "auto", 50, 50, 50, 50}
    oJson["body"] := { }
    For nI := 1 To 13
        AAdd(oJson["body"], {})
        For nJ := 1 To 6
            AAdd(oJson["body"][nI], JsonObject():New())
        Next nJ
    Next nI

    oJson["body"][1, 1]["text"] := CRLF + CRLF + STR0055
    oJson["body"][1, 2]["text"] := CRLF + STR0056
    oJson["body"][1, 3]["text"] := STR0057
    oJson["body"][1, 4]["text"] := STR0058

    oJson["body"][2, 4]["text"] := STR0059
    oJson["body"][2, 5]["text"] := STR0060
    oJson["body"][2, 6]["text"] := STR0061

    For nI := 1 To 6
        oJson["body"][3, nI]["text"] := cValToChar(nI)
        oJson["body"][7, nI]["border"] := {.T., .T., .T., .F.}
        oJson["body"][8, nI]["border"] := {.T., .F., .T., .T.}
        oJson["body"][7, nI]["text"] := ""
        oJson["body"][8, nI]["text"] := ""
    Next nI

    For nI := 1 To 3
        oJson["body"][nI + 3, 2]["text"] := cValToChar(nI)
        oJson["body"][nI + 3, 1]["alignment"] := "left"
    Next nI
    oJson["body"][7, 1]["alignment"] := "left"
    For nI := 5 To 10
        oJson["body"][nI + 3, 2]["text"] := cValToChar(nI - 1)
        oJson["body"][nI + 3, 1]["alignment"] := "left"
    Next nI

    oJson["body"][4, 1]["text"] := STR0062
    oJson["body"][5, 1]["text"] := STR0063
    oJson["body"][6, 1]["text"] := STR0064
    oJson["body"][7, 1]["text"] := STR0065
    oJson["body"][8, 1]["text"] := STR0066
    oJson["body"][9, 1]["text"] := STR0067
    oJson["body"][10, 1]["text"] := STR0068
    oJson["body"][11, 1]["text"] := STR0069
    oJson["body"][12, 1]["text"] := STR0070
    oJson["body"][13, 1]["text"] := STR0071

    For nI := 4 To 7
        For nJ := 3 To 6
            oJson["body"][nI, nJ]["text"] := AllTrim(Str(::aValForStr[nI - 3, nJ - 2], , 2))
        Next nJ
    Next nI
    For nI := 9 To 12
        If nI > 9 
            oJson["body"][nI, 3]["text"] := "No data"
        Else
            oJson["body"][nI, 3]["text"] := ::aValForStr[nI - 4]
        EndIf
        oJson["body"][nI, 3]["colSpan"] := 4
    Next nI
    oJson["body"][13, 3]["text"] := AllTrim(Str(::aValForStr[9], 5, 2))
    oJson["body"][13, 3]["colSpan"] := 4

    oJson["body"][1, 1]["rowSpan"] := 2
    oJson["body"][1, 2]["rowSpan"] := 2
    oJson["body"][1, 3]["rowSpan"] := 2
    oJson["body"][1, 4]["colSpan"] := 3

Return oJson

/*/
{Protheus.doc} GetViewReport(cDateReport, oContent, oSameJson)
    This method generates Json for output.

    @type Method
    @params cDateReport, Character, Date of report.
    @params oContent, Object, Object with array of content for report.
    @params oSameJson, Object, Object Same part of Json.
    @author dchizhov
    @since 2022/11/29
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetViewReport(cDateReport, oContent, oSameJson)
            RUSocialInsuranceFundTable1:GetViewReport(cDateReport, oContent, oSameJson)
/*/
Method GetViewReport(cDateReport, oContent, oSameJson) Class RUSocialInsuranceFundTable1

    Local lResult := .T. As Logical
    Local oJson          As Object

    oJson := JsonObject():New()
    oJson["style"] := "title"
    oJson["margin"] := {5, 18, 0, 0}
    oJson["text"] := STR0045 + CRLF + CRLF
    oJson["pageBreak"] := "before"
    AAdd(oContent, oJson)
    AAdd(oContent, oSameJson)
    oJson := JsonObject():New()
    oJson["style"] := "normal"
    oJson["alignment"] := "center"
    oJson["margin"] := {5, -1, 5, 0}
    oJson["table"] := ::GenerTable1View()

    AAdd(oContent, oJson)

Return lResult
