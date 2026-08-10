#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"

#DEFINE MAX_LEN_FSS_CODE 10
#DEFINE MAX_LEN_SUBORD_CODE 5

/*/
{Protheus.doc} RUInsurancePremiumReport
    Class for generating a Insurance premium report.

    @type Class
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
/*/
Class RUSocialInsuranceFund From LongNameClass

    Data aParameters       As Array     // Array of parameters from pergunte.
    Data cFilter           As Character // Expression for filter.
    Data lFilterOn         As Logical   // Flag of active filter.

    Data cPeriod           As Character // Code of report period (from parameters).
    Data oHeader           As Object    // Info for report header.
    Data oTable1           As Object    // Info for report Table1
    Data oTable2           As Object    // Info for report Table2
    Data oTable5           As Object    // Info for report Table5

    Data aPersonnelNumbers As Array     // Array of personel numbers.
    Data cYear             As Character // Year entered in parameters.

    Data cPageCount        As Character // Number of pages on which the report is drawn.
    Data cDateReport       As Date      // Report generation date.

    Data oData             As Object    // Object with report in Json-format

    Method New(aParameters, cFilterExpression) Constructor

    Method GetPersonnelNumbers()
    Method MakeData()
    Method CalcContPages()

    //PDFMaker.
    Method GetTemplatate()
    Method GetTempTable125(cPageNum)

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New(aParameters, cFilterExpression)
    Default constructor, 

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return RUSocialInsuranceFund, Object, RUSocialInsuranceFund instance.
    @example RUSocialInsuranceFund := RUSocialInsuranceFund():New(aParameters, cFilterExpression)
/*/
Method New(aParameters, cFilterExpression) Class RUSocialInsuranceFund

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilterExpression

    If !Empty(::cFilter)
        ::lFilterOn := .T.
        ::aPersonnelNumbers := ::GetPersonnelNumbers()
    Else
        ::lFilterOn := .F.
        ::aPersonnelNumbers := {}
    EndIf

    Self:cPeriod := ::aParameters[1]
    Self:cYear := ::aParameters[4]

    ::cDateReport := DToC(Date())

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the FSS report.

    @type Method
    @params 
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return lResult, Logical, Data collection completed successfully.
    @example oRu6Ndfl:MakeData()
/*/
Method MakeData() Class RUSocialInsuranceFund
    Local nPageNumber As Numeric
    // Local nI As Numeric
    Local lResult := .T. As Logical

    nPageNumber := 1

    MsProcTxt(STR0077)
    ::oHeader := RUSocialInsuranceFundHeader():New(::aParameters, ::cFilter, ::aPersonnelNumbers)
    lResult := ::oHeader:MakeData()

    If lResult
        MsProcTxt(STR0078)
        ::oTable1 := RUSocialInsuranceFundTable1():New(::aParameters, ::cFilter, ::oHeader:aEmplAll)
        lResult := ::oTable1:MakeData(::oHeader:aPeriods)
    EndIf
    
    If lResult
        MsProcTxt(STR0079)
        ::oTable2 := RUSocialInsuranceFundTable2():New(::aParameters, ::cFilter, ::oHeader:aEmplAll)
        lResult := ::oTable2:MakeData(::oHeader:aPeriods)
    EndIf

    If lResult
        MsProcTxt(STR0080)
        ::oTable5 := RUSocialInsuranceFundTable5():New(::aParameters, ::cFilter, ::oHeader:aEmplAll)
        lResult := ::oTable5:MakeData(::oHeader:aPeriods)
    EndIf

Return lResult

/*/
{Protheus.doc} GetPersonnelNumbers()
    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RUSocialInsuranceFund

    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character

    aNumbers := {}
    aArea := GetArea()

    cQuery := " SELECT RA_MAT AS EMPLOYNUM, RA_FILIAL AS FILIAL FROM " +  RetSQLName("SRA") + " WHERE "
    If ::lFilterOn
        cQuery += ::cFilter
        cQuery += " AND "
    EndIf
    cQuery += " D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        aAdd(aNumbers, {(cTab)->EMPLOYNUM, (cTab)->FILIAL, (cTab)->EMPLOYNUM + (cTab)->FILIAL})
        (cTab)->(DbSkip())
    EndDo

    aSort(aNumbers, , , {|X, Y| X[1] < Y[1] .Or. (X[1] == Y[1] .And. X[2] < Y[2])})

    (cTab)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aNumbers

/*/
{Protheus.doc} GetViewReport()
    This method generates lines for output to the log.
    This allows you to visually view the generated data on the FSS report 
    and save them in a PDF document. 

    @type Method
    @params 
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetViewReport()
            RUSocialInsuranceFund:GetViewReport()
/*/
Method GetViewReport() Class RUSocialInsuranceFund

    Local aLogText        As Array
    Local aLogTitleHeader As Array
    Local lResult := .T.  As Logical
    Local cJson           As Character
    Local cOptions        As Character
    Local oData           As Object
    Local oOptions        As Object

    aLogText        := {}
    aLogTitleHeader := {}

    // Create header for report.
    ::CalcContPages()

    oData := ::GetTemplatate()

    MsProcTxt(STR0081)
    lResult := ::oHeader:GetViewReport(::cDateReport, oData["content"])

    If lResult

        MsProcTxt(STR0082)
        lResult := ::oTable1:GetViewReport(::cDateReport, oData["content"], ::GetTempTable125("002"))
    Else
    // "Error creating json" "Failed to create json for output. Stage:"
        Help(,,STR0036,, STR0037 + CRLF + '"' + STR0021 + CRLF + STR0022 + '"', 1, 0)
    EndIf

    If lResult

        MsProcTxt(STR0083)
        lResult := ::oTable2:GetViewReport(::cDateReport, oData["content"], ::GetTempTable125("003"))
    Else
    // "Error creating json" "Failed to create json for output. Stage:"
        Help(,,STR0036,, STR0037 + CRLF + '"' + STR0045 + '"', 1, 0)
    EndIf

    If lResult

        MsProcTxt(STR0084)
        lResult := ::oTable5:GetViewReport(::cDateReport, oData["content"], ::GetTempTable125("004"))

        oOptions := Ru99x50_01_GetOptionsTemplate()
        oOptions['showSidebarButton'] := .F.

        cJson := oData:ToJson()
        cOptions := oOptions:ToJson()

    Else
    // "Error creating json" "Failed to create json for output. Stage:"
        Help(,,STR0036,, STR0037 + CRLF + '"' + STR0126 + '"', 1, 0)
    EndIf

    FwFreeObj(oData)

    If lResult
        //Calls library with FWCALLAPP
        ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions,'RU07R05')
    Else
    // "Error creating array" "Failed to create json for output. Stage:"
        Help(,,STR0036,, STR0037 + CRLF + '"' + STR0127 + '"', 1, 0)
    EndIf

Return lResult

/*/
{Protheus.doc} CalcContPages()
    This method calculate and write count of pages.

    @type Method
    @params 
    @author dchizhov
    @since 2022/11/23
    @version 12.1.33
    @return lResult, Logical, The data has been successfully calculate and write count of pages.
    @example ::CalcContPages()
/*/
Method CalcContPages() Class RUSocialInsuranceFund

    Local nCount         As Numeric
    Local lResult := .T. As Logical

    nCount := 1 + Val(::oTable1:cPageCount) + Val(::oTable2:cPageCount) + Val(::oTable5:cPageCount)
    
    ::oHeader:cPageCount := StrZero(nCount, 3)

    lResult := .F.

Return lResult

/*/
{Protheus.doc} GetTemplatate()
    This method biuld default value for report and Json without content.

    @type Method
    @params 
    @author dchizhov
    @since 2022/11/28
    @version 12.1.33
    @return oJson, Object, Json for report.
    @example oData := ::GetTemplatate()
/*/
Method GetTemplatate() Class RUSocialInsuranceFund

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageMargins": [0, 0, 0, 0],
        "styles": {
            "title": {
                "fontSize": 10.5,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 8.5,
                "bold": false
            }
        },
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "style": "title"
            }
        ]
    }
    EndContent
    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := STR0021 + CRLF + STR0022 + CRLF + CRLF

Return oJson

/*/
{Protheus.doc} GetTempTable125(cPageNum)
    Function for create same part for table.

    @type Function
    @params cPageNum, Character, Number of page.
    @author dchizhov
    @since 2022/12/01
    @version 12.1.33
    @return oJson, Object, Json with data.
    @example oJson := GetTempTable125(cPageNum)
/*/
Method GetTempTable125(cPageNum) Class RUSocialInsuranceFund

    Local oJson As Object
    
    oJson := JsonObject():New()

    oJson["style"] := "normal"
    oJson["margin"] := {5, 0, 5, 0}
    oJson["table"] := JsonObject():New()
    oJson["table"]["width"] := "100%"
    oJson["table"]["widths"]:= {250, "*"}
    oJson["table"]["body"] := { { RU07R0504_BuildSample(STR0023), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::oHeader:cFSSNum, MAX_LEN_FSS_CODE)                    + "'")} }
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0024), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::oHeader:cCodeSubord, MAX_LEN_SUBORD_CODE)             + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0046), RU07R0504_BuildSample("'" + cPageNum + "'"                                                                   )})

Return oJson

/*/
{Protheus.doc} GetXMLReport(cDocSavePath)
    This method generate report in XML document.

    @type Method
    @params cDocSavePath, Character, Path to save result document into XML format.
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetXMLReport(cSavePath)
            RUSocialInsuranceFund:GetXMLReport()
/*/
Method GetXMLReport(cDocSavePath) Class RUSocialInsuranceFund

    Local lResult := .T. As Logical
    
    Help(,,"Error",, "implementation of this functionality is expected in future versions", 1, 0)

    lResult := .F.

Return lResult
