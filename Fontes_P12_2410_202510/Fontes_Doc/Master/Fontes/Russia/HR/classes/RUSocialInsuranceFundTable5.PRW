#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"

#DEFINE NODATA "No data"

/*/
{Protheus.doc} RUSocialInsuranceFundTable5
    Class for generating a Table 5 for report FSS.

    @type Class
    @author dchizhov
    @since 2022/12/02
    @version 12.1.33
/*/
Class RUSocialInsuranceFundTable5 From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters As Array // Array of parameters from pergunte.

    Data cPageCount  As Character // Count of page in format "XXX".

    Data aValForStr  As Array // Array of sums for Table2.

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetSumSRA1()

    Method GenerTable5View()

    Method MakeData()
    Method GetViewReport()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aFilter, cNum, cCod)
    Default RUSocialInsuranceFundTable5 constructor.

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params aFilter,     Array,     Array of personnel numbers for filter.
    @author dchizhov
    @since 2022/12/02
    @version 12.1.33
    @return RUSocialInsuranceFundTable5, Object, RUSocialInsuranceFundTable5 instance.
    @example ::oTable2 := RUSocialInsuranceFundTable5():New(::aParameters, ::cFilter, ::aFilter)
/*/
Method New(aParameters, cFilter, aFilter) Class RUSocialInsuranceFundTable5

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageCount := "001"

    Self:aValForStr := { {0, 0, 0, 0, 0, 0},;
                         {0, 0, 0, 0, 0, 0} }

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the FSS report Table5.

    @type Method
    @params aPeriods, Array, Array of periods for calculation
    @author dchizhov
    @since 2022/12/02
    @version 12.1.33
    @return 
    @example ::oTable5:MakeData()
/*/
Method MakeData(aPeriods) Class RUSocialInsuranceFundTable5

    Local lResult := .T. As Logical

    // TODO
    // There is currently no way to get data.
    // Redo after integration with MDT

Return lResult

/*/
{Protheus.doc} GenerTable5View()
    This method generates Json object with table for Table5 reports. 

    @type Method
    @params 
    @author dchizhov
    @since 2022/12/02
    @version 12.1.33
    @return oJson, Object, Generated Json object.
    @example oJson := ::GenerTable5View()
/*/
Method GenerTable5View() Class RUSocialInsuranceFundTable5

    Local oJson As Object
    Local cJson As Character
    Local nI    As Numeric

    oJson := JsonObject():New()
    BeginContent var cJson
    {
        "width": "100%",
        "widths": [80, 30, 55, 55, 55, 55, 85, 85],
        "body":[
            [ 
                {"rowSpan": 4, "margin": [0, 60, 0, 0]}, 
                {"rowSpan": 4, "margin": [0, 60, 0, 0]}, 
                {"rowSpan": 4, "margin": [0, 50, 0, 0]}, 
                {"colSpan": 3}, {}, {}, 
                {"rowSpan": 4}, 
                {"rowSpan": 4} 
            ],
            [ 
                {}, {}, {}, 
                {"rowSpan": 3, "margin": [0, 40, 0, 0]}, 
                {"colSpan": 2}, 
                {}, {}, {} 
            ],
            [ 
                {}, {}, {}, {}, 
                {"rowSpan": 2, "margin": [0, 30, 0, 0]}, 
                {"rowSpan": 2, "margin": [0, 30, 0, 0]}, 
                {}, {} 
            ],
            [ {}, {}, {}, {}, {}, {}, {}, {} ], [ {}, {}, {}, {}, {}, {}, {}, {} ],
            [ {}, {}, 
            {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, 
            {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0] } ], 
            [ {}, {}, 
            {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, 
            {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0] } ]
        ]
    }
    EndContent
    oJson:FromJson(cJson)

    oJson["body"][1, 1]["text"] := STR0128 + CRLF + STR0129
    oJson["body"][1, 2]["text"] := STR0130
    oJson["body"][1, 3]["text"] := STR0131
    oJson["body"][1, 4]["text"] := STR0132
    oJson["body"][1, 7]["text"] := STR0133 + CRLF + STR0134
    oJson["body"][1, 8]["text"] := STR0135 + CRLF + STR0136

    oJson["body"][2, 4]["text"] := STR0137
    oJson["body"][2, 5]["text"] := STR0138

    oJson["body"][3, 5]["text"] := STR0139
    oJson["body"][3, 6]["text"] := STR0140

    For nI := 1 To 8
        oJson["body"][5, nI]["text"] := CValToChar(nI)
        oJson["body"][6, nI]["text"] := NODATA
        oJson["body"][7, nI]["text"] := "X"
    Next nI

    oJson["body"][6, 1]["text"] := STR0141
    oJson["body"][7, 1]["text"] := STR0142
    oJson["body"][6, 2]["text"] := "1"
    oJson["body"][7, 2]["text"] := "2"
    oJson["body"][6, 7]["text"] := "X"
    oJson["body"][7, 7]["text"] := NODATA
    oJson["body"][6, 8]["text"] := "X"
    oJson["body"][7, 8]["text"] := NODATA

Return oJson

/*/
{Protheus.doc} GetViewReport(cDateReport, oContent, oSameJson)
    This method generates Json for output.

    @type Method
    @params cDateReport, Character, Date of report.
    @params oContent,  Object, Object with array of content for report.
    @params oSameJson, Object, Object Same part of Json.
    @author dchizhov
    @since 2022/12/02
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetViewReport(cDateReport, oContent, oSameJson)
            RUSocialInsuranceFundTable5:GetViewReport(cDateReport, oContent, oSameJson)
/*/
Method GetViewReport(cDateReport, oContent, oSameJson) Class RUSocialInsuranceFundTable5

    Local lResult := .T. As Logical
    Local oJson          As Object

    oJson := JsonObject():New()
    oJson["style"] := "title"
    oJson["margin"] := {5, 18, 0, 0}
    oJson["text"] := STR0127 + CRLF + CRLF
    oJson["pageBreak"] := "before"
    AAdd(oContent, oJson)
    AAdd(oContent, oSameJson)
    oJson := JsonObject():New()
    oJson["style"] := "normal"
    oJson["alignment"] := "center"
    oJson["margin"] := {5, -1, 5, 0}
    oJson["table"] := ::GenerTable5View()

    AAdd(oContent, oJson)

Return lResult
