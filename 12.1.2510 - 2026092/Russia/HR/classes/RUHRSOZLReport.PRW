#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R22RUS.CH"

#DEFINE SEPARATOR_LINE_ARRAY {" ", "!", "?"}
#DEFINE NUMBER_OF_CELLS 10


/*/
{Protheus.doc} RuRHSOZLForm

    Class for the print-form "Information about the insured person" (SOZL).

    @type Class
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
/*/
Class RuRHSOZLForm From LongNameClass

    Data aFilter            As Array     // Array of Filter.
    Data oGeneralJson       As Object    // Json for report.
    Data cFilter            As Character // String of filter.
    Data lFilterOn          As Logical   // Flag of active filter.
    Data cSignerPost        As Character // String of position of the signatory
    Data cSignerName        As Character // String of the signer's fullname
    Data cFilialCode        As Character // String of branch code
    Data cGroupCode         As Character // String of group code
    Data cDate              As Character // String of date
    Data cNameReport        As Character // String of the name of the printed form
    Data cHeadTitlePage     As Character // String of the name of the printed form
    Data aPersonnelNumbers  As Array     // Array of personel numbers.
    Data nTypeEmp           As Numeric   // Agent type.

    Method New(aFilter, cFilterExpression, cNameReport) Constructor
    Method AddContent(oJson)
    Method GetTemplatate()
    Method GetViewReport()
    Method SortByName(aDataSRA)
    Method GetPersNumbers()
    Method GetAdress(cMat)

    Method GetTitle(lPageBreak)
    Method GetInTable()
    Method GetFromTable()
    Method Get1Part()
    Method Get2Part()
    Method Get3Part()
    Method Get4Part()
    Method Get5Part()
    Method Get6Part()
    Method Get71Part()
    Method Get72Part()
    Method Get73Part()

EndClass


/*/
{Protheus.doc} SortByName(aDataSRA)

    This method sorted array of TN by name of employees and by filters.

    @type Method
    @params aDataSRA, Array, Array of employee data.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return aResult, Array, Sorted and filtered employee data array
    @example oSOZLObject:aPersonnelNumbers := oSOZLObject:SortByName(oSOZLObject:aPersonnelNumbers)
/*/
Method SortByName(aDataSRA) Class RuRHSOZLForm

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object
    Local aResult    As Array
    Local aEmployee  As Array
    Local aArea      As Array

    DEFAULT cRot := NIL
    DEFAULT cProc := NIL

    aArea := GetArea()

    aResult := {}
    aEmployee := {}
    aEval(aDataSRA, {|X| Aadd(aEmployee, X[3])})

    cQuery := " SELECT SRA.RA_MAT, SRA.RA_FILIAL FROM " + RetSqlName("SRA") + " SRA " 
    cQuery += " WHERE "
    cQuery += " CONCAT(SRA.RA_MAT, SRA.RA_FILIAL) IN (?) "
    cQuery += " AND SRA.D_E_L_E_T_ = '' "
    cQuery += " ORDER BY SRA.RA_NOMECMP "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, aEmployee)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        Aadd(aResult, {(cTab)->RA_MAT, (cTab)->RA_FILIAL, (cTab)->RA_MAT + (cTab)->RA_FILIAL})
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())
    RestArea(aArea)

Return aResult


/*/
{Protheus.doc} GetTitle(lPageBreak)

    This method builds rows on top of a sheet with information about the application.

    @type Method
    @params lPageBreak, Logical, Page break befor or not.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the application.
    @example oSOZLObject:AddContent(oSOZLObject:GetTitle(lPageBreak))
/*/
Method GetTitle(lPageBreak) Class RuRHSOZLForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "margin": [0, 0, 15, 0],
                "alignment": "right"
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    If lPageBreak
        oJson["content"][1]["pageBreak"] := "before"
    EndIf
    oJson["content"][1]["text"] := STR0001 + CRLF + STR0002 + CRLF + STR0003 + CRLF + CRLF + STR0004 + CRLF + CRLF// "Appendix No. 1" 
                        // + "to the Order of the Social Insurance Fund of the Russian Federation"
                        // + "No. 119 dated April 8, 2022"
                        // "Form"

Return oJson


/*/
{Protheus.doc} GetInTable()

    This method creates the introductory part and the first table of SOZL.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oTabsIn_1)
/*/
Method GetInTable() Class RuRHSOZLForm

    Local nY := 2           As Numeric
    Local nX := 1           As Numeric
    Local oJson             As Object
    Local oData             As Object
    Local cJson             As Character
    Local lEndName := .T.   As Logical

    oJson := JsonObject():New()
    oData := RuRHSTDRForm():New(NIL, ::aFilter, ::cFilter, ::cNameReport)
    aData := oData:GetDataEmployer()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [10, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5],
                    "heights": [11, 11, 11, 11, 11, 11, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "colSpan": 38, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    cFullName := UPPER(AllTrim(aData[2, 2]))
    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"] := STR0005 // "In"
    While nX <= 5 .AND. lEndName == .T.
        For nY := 2 To 41
            oJson["content"][1]["table"]["body"][nX,  nY]["text"] := Substr(cFullName, 1, 1)
            If Len(cFullName) > 1
                cFullName := IIF( nY == 41 .AND. " " $ Substr(cFullName, 2, 1), Substr(cFullName, 3, Len(cFullName)), Substr(cFullName, 2, Len(cFullName)) )
            Else
                lEndName := .F.
                Exit
            EndIf
        Next nY
        nX++
    EndDo
    oJson["content"][1]["table"]["body"][6, 3]["text"] := STR0006 + CRLF + CRLF

Return oJson


/*/
{Protheus.doc} GetFromTable()

    This method creates a part with a second table of SOZL, where the data is filled in "From".

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oTabsFrom_1)
/*/
Method GetFromTable() Class RuRHSOZLForm

    Local nY:= 2            As Numeric
    Local nX:= 1            As Numeric
    Local oJson             As Object
    Local cJson             As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [10, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5, 4.5],
                    "heights": [11, 11, 11, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "alignment": "left"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "colSpan": 38, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    cFullName := UPPER(AllTrim(SRA->RA_NOMECMP))
    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"] := STR0007 // "From"
    While nX <= 3
        While nY != 42 .AND. !(Substr(cFullName, 1, 1) $ " ") .AND.  Len(cFullName) > 0
            oJson["content"][1]["table"]["body"][nX,  nY]["text"] := Substr(cFullName, 1, 1)
            cFullName := IIF( Len(cFullName) != 0, Substr(cFullName, 2, Len(cFullName)), "" )
            nY++
        EndDo
        If (Substr(cFullName, 1, 1) $ " ") .AND. Len(cFullName) > 1
            cFullName := Substr(cFullName, 2, Len(cFullName))
            nX++
            nY := 2
        ElseIf Len(cFullName) == 0
            nX := 4
        EndIf
    EndDo
    oJson["content"][1]["table"]["body"][4, 3]["text"] := STR0008

Return oJson


/*/
{Protheus.doc} Get1Part()

    This method builds the part I of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart1Form_1)
/*/
Method Get1Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    Local nI                As Numeric
    Local nJ                As Numeric
    Local nD                As Numeric
    Local nN := 4           As Numeric
    Local aFullName         As Array
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
                    "heights": [10, 9, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}, 
                            {"border": [false, false, false, false], "bold": true, "colSpan": 37, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "bold": true, "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 14, "text": "", "alignment": "right"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "right"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 26, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 28, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    aFullName := {UPPER(AllTrim(SRA->RA_PRISOBR)), UPPER(AllTrim(SRA->RA_PRINOME)), UPPER(AllTrim(SRA->RA_SECNOME))}

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 3]["text"]   := STR0009
    oJson["content"][1]["table"]["body"][2, 1]["text"]   := STR0010
    oJson["content"][1]["table"]["body"][3, 1]["text"]   := STR0011
    oJson["content"][1]["table"]["body"][5, 1]["text"]   := STR0012
    oJson["content"][1]["table"]["body"][7, 1]["text"]   := STR0013
    oJson["content"][1]["table"]["body"][9, 1]["text"]   := STR0014
    oJson["content"][1]["table"]["body"][10, 11]["text"] := STR0015
    oJson["content"][1]["table"]["body"][10, 25]["text"] := STR0016
    oJson["content"][1]["table"]["body"][10, 27]["text"] := STR0017
    oJson["content"][1]["table"]["body"][11, 1]["text"]  := STR0018
    oJson["content"][1]["table"]["body"][13, 1]["text"]  := STR0019
    oJson["content"][1]["table"]["body"][10, 3]["text"]  := oJson["content"][1]["table"]["body"][10, 6]["text"] := ;
    oJson["content"][1]["table"]["body"][12, 4]["text"]  := oJson["content"][1]["table"]["body"][12, 8]["text"] := ' - '

    For nD := 1 To 12
        If nD != 3 .AND. nD != 6 .AND. nD < 11
            oJson["content"][1]["table"]["body"][10, nD]["text"] := Substr(CValToChar(SRA->RA_NASC), nD, 1)
        EndIf

        If nD < 4
            oJson["content"][1]["table"]["body"][12, nD]["text"] := Substr(CValToChar(SRA->RA_CIC), nD, 1)
        ElseIf nD >= 4 .AND. nD < 7
            oJson["content"][1]["table"]["body"][12, nD+1]["text"] := Substr(CValToChar(SRA->RA_CIC), nD, 1)
        ElseIf nD >= 7 .AND. nD < 10
            oJson["content"][1]["table"]["body"][12, nD+2]["text"] := Substr(CValToChar(SRA->RA_CIC), nD, 1)
        ElseIf nD >= 10
            oJson["content"][1]["table"]["body"][12, nD+3]["text"] := Substr(CValToChar(SRA->RA_CIC), nD, 1)
        EndIf

        oJson["content"][1]["table"]["body"][14, nD]["text"] := Substr(CValToChar(SRA->RA_PIS), nD, 1)
    Next nD

    Do case
        case SRA->RA_SEXO == "M"
            oJson["content"][1]["table"]["body"][10, 26]["text"] := "V"
        case SRA->RA_SEXO == "F"
            oJson["content"][1]["table"]["body"][10, 28]["text"] := "V"
    Endcase

    For nJ := 1 To Len(aFullName)
        For nI := 1 To Len(aFullName[nJ])
            oJson["content"][1]["table"]["body"][Nn,  nI]["text"] := Substr(aFullName[nJ], 1, 1)
            If Len(aFullName[nJ]) > 1
                aFullName[nJ] := Substr(aFullName[nJ], 2, Len(aFullName[nJ]))
            Else
                Exit
            EndIf
        Next nI
        nN += 2
    Next nJ

Return oJson


/*/
{Protheus.doc} Get2Part()

    This method builds the part II of SOZL print form..

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart2Form_2)
/*/
Method Get2Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    Local nP                As Numeric
    Local nX := 1           As Numeric
    Local nY                As Numeric
    Local lEndStr := .T.    As Logical
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
                    "heights": [11, 11, 11, 11, 11, 11, 11, 11, 3, 11, 3, 11, 3, 11, 3, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 40,"bold": true, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "left"}, {}, {}, {}, {}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "right"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "right"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 14, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 30, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 10, "text": "", "alignment": "right"}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 7, "text": ""}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 18, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 10, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "right"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "right"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "left"}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 18, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]   := STR0020 + " " + STR0021
    oJson["content"][1]["table"]["body"][2, 1]["text"]   := STR0022
    oJson["content"][1]["table"]["body"][2, 7]["text"]   := oJson["content"][1]["table"]["body"][14, 12]["text"] := STR0023
    oJson["content"][1]["table"]["body"][2, 16]["text"]  := oJson["content"][1]["table"]["body"][10, 14]["text"]  := oJson["content"][1]["table"]["body"][14, 21]["text"] := STR0024
    oJson["content"][1]["table"]["body"][3, 1]["text"]   := STR0025
    oJson["content"][1]["table"]["body"][5, 1]["text"]   := STR0026
    oJson["content"][1]["table"]["body"][10, 1]["text"]  := STR0027
    oJson["content"][1]["table"]["body"][14, 1]["text"]  := STR0030
    oJson["content"][1]["table"]["body"][12, 1]["text"]  := oJson["content"][1]["table"]["body"][16, 1]["text"]  := STR0029
    oJson["content"][1]["table"]["body"][4, 3]["text"]  := oJson["content"][1]["table"]["body"][4, 6]["text"]  := ;
    oJson["content"][1]["table"]["body"][12, 15]["text"] := oJson["content"][1]["table"]["body"][12, 18]["text"] := ;
    oJson["content"][1]["table"]["body"][16, 15]["text"] := oJson["content"][1]["table"]["body"][16, 18]["text"] := ' - '

    Do case
        case SRA->RA_FICHA == "21"
            oJson["content"][1]["table"]["body"][2, 6]["text"] := "V"
            For nP := 1 To 10
                If nP <= 4
                    oJson["content"][1]["table"]["body"][2, 11+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                ElseIf nP > 4
                    oJson["content"][1]["table"]["body"][2, 16+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                EndIf
                If nP != 3 .AND. nP != 6
                    oJson["content"][1]["table"]["body"][4, nP]["text"] :=  Substr(CValToChar(SRA->RA_DEMIPAS), nP, 1)
                EndIf
            Next nP
            
            cWhoIssued := UPPER(AllTrim(SRA->RA_EMISPAS))
            While nX <= 3 .AND. lEndStr == .T.
                For nY := 1 To 40
                    oJson["content"][1]["table"]["body"][5+nX,  nY]["text"] := Substr(cWhoIssued, 1, 1)
                    If Len(cWhoIssued) > 1
                        cWhoIssued := IIF( nY == 40 .AND. " " $ Substr(cWhoIssued, 2, 1), Substr(cWhoIssued, 3, Len(cWhoIssued)), Substr(cWhoIssued, 2, Len(cWhoIssued)) )
                    Else
                        lEndStr := .F.
                        Exit
                    EndIf
                Next nY
                nX++
            EndDo
        case SRA->RA_FICHA == "14"
            oJson["content"][1]["table"]["body"][10, 13]["text"] := "V"
            For nP := 1 To 10
                If nP <= Len(CValToChar(SRA->RA_NUMEPAS))
                    oJson["content"][1]["table"]["body"][10, 23+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                EndIf
                If nP != 3 .AND. nP != 6
                    oJson["content"][1]["table"]["body"][12, 12+nP]["text"] :=  Substr(CValToChar(SRA->RA_DVALPAS), nP, 1)
                EndIf
            Next nP
        case SRA->RA_FICHA == "91"
            oJson["content"][1]["table"]["body"][14, 11]["text"] := "V"
            For nP := 1 To 10
                If nP <= Len(CValToChar(SRA->RA_NUMEPAS))
                    oJson["content"][1]["table"]["body"][14, 25+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                EndIf
                If nP != 3 .AND. nP != 6
                    oJson["content"][1]["table"]["body"][16, 12+nP]["text"] :=  Substr(CValToChar(SRA->RA_DVALPAS), nP, 1)
                EndIf
            Next nP
    Endcase

Return oJson


/*/
{Protheus.doc} Get3Part()

    This method builds the part III of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart3Form_3)
/*/
Method Get3Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    Local nP                As Numeric
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                    "heights": [11, 11, 3, 11, 3, 11, 3, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 33,"bold": true, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "right"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "right"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 33, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 11, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"margin": [0, 0, 0, 0], "border": [false, false, false, false], "colSpan": 33, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"margin": [0, 0, 0, 0], "border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "text": "", "alignment": "right"}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "text": "", "alignment": "right"}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 33, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 11, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]   := STR0034 + " " + STR0035
    oJson["content"][1]["table"]["body"][2, 1]["text"]   := STR0036
    oJson["content"][1]["table"]["body"][4, 1]["text"]   := oJson["content"][1]["table"]["body"][8, 1]["text"] := STR0025
    oJson["content"][1]["table"]["body"][5, 1]["text"]   := Substr(STR0040, 1, 23)
    oJson["content"][1]["table"]["body"][6, 1]["text"]   := Substr(STR0040, 25, Len(STR0040))
    oJson["content"][1]["table"]["body"][4, 15]["text"] := oJson["content"][1]["table"]["body"][4, 18]["text"]   := ;
    oJson["content"][1]["table"]["body"][8, 15]["text"] := oJson["content"][1]["table"]["body"][8, 18]["text"]   := ' - '
    oJson["content"][1]["table"]["body"][2, 14]["text"]   := oJson["content"][1]["table"]["body"][6, 14]["text"] := STR0023
    oJson["content"][1]["table"]["body"][2, 22]["text"]  := oJson["content"][1]["table"]["body"][6, 21]["text"]  := STR0024

    For nP := 1 To 10
        Do case
            case SRA->RA_FICHA == "12"
                oJson["content"][1]["table"]["body"][2, 13]["text"] := "V"
                If nP <= 2
                    oJson["content"][1]["table"]["body"][2, 17+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                ElseIf nP > 2 .AND. nP <= 9
                    oJson["content"][1]["table"]["body"][2, 23+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                EndIf
                If nP != 3 .AND. nP != 6
                    oJson["content"][1]["table"]["body"][4, 12+nP]["text"] :=  Substr(CValToChar(SRA->RA_DEMIPAS), nP, 1)
                EndIf
            case SRA->RA_FICHA == "15"
                oJson["content"][1]["table"]["body"][6, 13]["text"] := "V"
                If nP <= Len(CValToChar(SRA->RA_NUMEPAS))
                    oJson["content"][1]["table"]["body"][6, 23+nP]["text"] := Substr(CValToChar(SRA->RA_NUMEPAS), nP, 1)
                EndIf
                If nP != 3 .AND. nP != 6
                    oJson["content"][1]["table"]["body"][8, 12+nP]["text"] :=  Substr(CValToChar(SRA->RA_DEMIPAS), nP, 1)
                EndIf
        Endcase
    Next nP

Return oJson


/*/
{Protheus.doc} Get4Part()

    This method builds the part IV of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart4Form_4)
/*/
Method Get4Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
                    "heights": [11, 11, 1, 11, 1, 11, 1, 11, 1, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 40,"bold": true, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 15, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 15, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 8, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 15, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 15, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 8, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 16, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 23, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 10, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "left"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "left"}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 17, "text": "", "alignment": "left"}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 40, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},  {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 10, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 29, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]   := STR0044 + " " + STR0045
    oJson["content"][1]["table"]["body"][2, 2]["text"]   := STR0046
    oJson["content"][1]["table"]["body"][4, 2]["text"]   := STR0047
    oJson["content"][1]["table"]["body"][2, 18]["text"]  := STR0048
    oJson["content"][1]["table"]["body"][4, 18]["text"]  := STR0049
    oJson["content"][1]["table"]["body"][6, 18]["text"]  := STR0050
    oJson["content"][1]["table"]["body"][8, 1]["text"]   := STR0051
    oJson["content"][1]["table"]["body"][8, 12]["text"]  := STR0052
    oJson["content"][1]["table"]["body"][8, 18]["text"]  := STR0053
    oJson["content"][1]["table"]["body"][8, 24]["text"]  := STR0054
    oJson["content"][1]["table"]["body"][10, 12]["text"] := STR0055

Return oJson


/*/
{Protheus.doc} Get5Part()

    This method builds the part V of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart5Form_5)
/*/
Method Get5Part() Class RuRHSOZLForm

    Local oJson              As Object
    Local cJson              As Character
    Local aAdress := {}      As Array
    Local nX                 As Numeric
    Local cCodmune, cLogrnum As Character
    Local cCep, cEstado, cMunicip, cNumende As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12],
                    "heights": [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 3, 11, 3, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 24,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 18, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "left"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "right"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "text": "", "alignment": "right"}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 13, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]     := STR0056 + " " + STR0057
    oJson["content"][1]["table"]["body"][2, 1]["text"]     := STR0058
    oJson["content"][1]["table"]["body"][4, 1]["text"]     := STR0059
    oJson["content"][1]["table"]["body"][6, 1]["text"]     := STR0060
    oJson["content"][1]["table"]["body"][8, 1]["text"]     := STR0061
    oJson["content"][1]["table"]["body"][10, 1]["text"]    := STR0062
    oJson["content"][1]["table"]["body"][13, 1]["text"]    := STR0063
    oJson["content"][1]["table"]["body"][13, 12]["text"]   := STR0064
    oJson["content"][1]["table"]["body"][13, 19]["text"]   := STR0065
    oJson["content"][1]["table"]["body"][15, 1]["text"]    := STR0066

    cCep      := UPPER(AllTrim(SRA->RA_CEP))
    cEstado   := UPPER(AllTrim(StaticCall(RU07R08RUS, RU07R0803_GetTabValueForKeyOrder, "SX5", "12" + SRA->RA_ESTADO,, "X5Descri()")))
    cMunicip  := UPPER(AllTrim(SRA->RA_MUNICIP))
    aAdress   := ::GetAdress(SRA->RA_MAT)
    cCodmune  := UPPER(AllTrim(fDesc("CC2", aAdress[1], "CC2_MUN",,,3)))
    cLogrnum  := UPPER(AllTrim(aAdress[2]))
    cNumende  := UPPER(AllTrim(SRA->RA_NUMENDE))

    For nX := 1 To 24

            If cCep != NIL
                oJson["content"][1]["table"]["body"][3, nX]["text"] := Substr(cCep, 1, 1)
                cCep := IIF( Len(cCep) >= 1, Substr(cCep, 2, Len(cCep)), NIL )
            EndIf
            If cEstado != NIL
                oJson["content"][1]["table"]["body"][5, nX]["text"] := Substr(cEstado, 1, 1)
                cEstado := IIF( Len(cEstado) >= 1, Substr(cEstado, 2, Len(cEstado)), NIL )
            EndIf
            If cMunicip != NIL
                oJson["content"][1]["table"]["body"][7, nX]["text"] := Substr(cMunicip, 1, 1)
                cMunicip := IIF( Len(cMunicip) >= 1, Substr(cMunicip, 2, Len(cMunicip)), NIL )
            EndIf
            If cCodmune != NIL
                oJson["content"][1]["table"]["body"][9, nX]["text"] := Substr(cCodmune, 1, 1)
                cCodmune := IIF( Len(cCodmune) >= 1, Substr(cCodmune, 2, Len(cCodmune)), NIL )
            EndIf
            If cLogrnum != NIL
                oJson["content"][1]["table"]["body"][11, nX]["text"] := Substr(cLogrnum, 1, 1)
                cLogrnum := IIF( Len(cLogrnum) >= 1, Substr(cLogrnum, 2, Len(cLogrnum)), NIL )
            EndIf
            If cNumende != NIL
                oJson["content"][1]["table"]["body"][15, 6+nX]["text"] := Substr(cNumende, 1, 1)
                cNumende := IIF( Len(cNumende) >= 1, Substr(cNumende, 2, Len(cNumende)), NIL )
            EndIf

    Next nX

Return oJson


/*/
{Protheus.doc} Get6Part()

    This method builds the part VI of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart6Form_6)
/*/
Method Get6Part() Class RuRHSOZLForm

    Local oJson              As Object
    Local cJson              As Character
    Local Nx                 As Numeric
    Local aAdress := {}      As Array
    Local cCodmune, cLogrnum As Character
    Local cCep, cEstado, cMunicip, cNumende As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12],
                    "heights": [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 3, 11, 3, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 24,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 18, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "left"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "right"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "text": "", "alignment": "right"}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 13, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]     := STR0067 + " " + STR0068
    oJson["content"][1]["table"]["body"][2, 1]["text"]     := STR0069
    oJson["content"][1]["table"]["body"][4, 1]["text"]     := STR0070
    oJson["content"][1]["table"]["body"][6, 1]["text"]     := STR0071
    oJson["content"][1]["table"]["body"][8, 1]["text"]     := STR0072
    oJson["content"][1]["table"]["body"][10, 1]["text"]    := STR0073
    oJson["content"][1]["table"]["body"][13, 1]["text"]    := STR0074
    oJson["content"][1]["table"]["body"][13, 12]["text"]   := STR0075
    oJson["content"][1]["table"]["body"][13, 19]["text"]   := STR0076
    oJson["content"][1]["table"]["body"][15, 1]["text"]    := STR0077
    
    cCep      := UPPER(AllTrim(SRA->RA_CEP))
    cEstado   := UPPER(AllTrim(StaticCall(RU07R08RUS, RU07R0803_GetTabValueForKeyOrder, "SX5", "12" + SRA->RA_ESTADO,, "X5Descri()")))
    cMunicip  := UPPER(AllTrim(SRA->RA_MUNICIP))
    aAdress   := ::GetAdress(SRA->RA_MAT)
    cCodmune  := UPPER(AllTrim(fDesc("CC2", aAdress[1], "CC2_MUN",,,3)))
    cLogrnum  := UPPER(AllTrim(aAdress[2]))
    cNumende  := UPPER(AllTrim(SRA->RA_NUMENDE))

    If AllTrim(SRA->RA_TPCTSAL) != "1"
        For nX := 1 To 24

            If cCep != NIL
                oJson["content"][1]["table"]["body"][3, nX]["text"] := Substr(cCep, 1, 1)
                cCep := IIF( Len(cCep) >= 1, Substr(cCep, 2, Len(cCep)), NIL )
            EndIf
            If cEstado != NIL
                oJson["content"][1]["table"]["body"][5, nX]["text"] := Substr(cEstado, 1, 1)
                cEstado := IIF( Len(cEstado) >= 1, Substr(cEstado, 2, Len(cEstado)), NIL )
            EndIf
            If cMunicip != NIL
                oJson["content"][1]["table"]["body"][7, nX]["text"] := Substr(cMunicip, 1, 1)
                cMunicip := IIF( Len(cMunicip) >= 1, Substr(cMunicip, 2, Len(cMunicip)), NIL )
            EndIf
            If cCodmune != NIL
                oJson["content"][1]["table"]["body"][9, nX]["text"] := Substr(cCodmune, 1, 1)
                cCodmune := IIF( Len(cCodmune) >= 1, Substr(cCodmune, 2, Len(cCodmune)), NIL )
            EndIf
            If cLogrnum != NIL
                oJson["content"][1]["table"]["body"][11, nX]["text"] := Substr(cLogrnum, 1, 1)
                cLogrnum := IIF( Len(cLogrnum) >= 1, Substr(cLogrnum, 2, Len(cLogrnum)), NIL )
            EndIf
            If cNumende != NIL
                oJson["content"][1]["table"]["body"][15, 6+nX]["text"] := Substr(cNumende, 1, 1)
                cNumende := IIF( Len(cNumende) >= 1, Substr(cNumende, 2, Len(cNumende)), NIL )
            EndIf

        Next nX
    EndIf

Return oJson


/*/
{Protheus.doc} Get71Part()

    This method builds the part VII of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart71Form_71)
/*/
Method Get71Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    Local aDatTemp := {}    As Array
    Local nX := 1           As Numeric
    Local nY                As Numeric
    Local nZ := 1           As Numeric
    Local cNameBank         As Character
    Local cAccount          As Character
    Local cBIK              As Character
    Local lEndStr := .T.    As Logical
    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 30],
                    "heights": [11, 11, 3, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 25,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 16, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},  {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 16, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]     := STR0078 + " " + STR0079
    oJson["content"][1]["table"]["body"][2, 2]["text"]     := STR0080
    oJson["content"][1]["table"]["body"][2, 10]["text"]    := STR0082
    oJson["content"][1]["table"]["body"][4, 2]["text"]     := STR0081
    oJson["content"][1]["table"]["body"][5, 1]["text"]     := STR0083
    oJson["content"][1]["table"]["body"][6, 1]["text"]     := STR0084
    oJson["content"][1]["table"]["body"][10, 1]["text"]    := STR0085
    oJson["content"][1]["table"]["body"][11, 6]["text"]    := oJson["content"][1]["table"]["body"][11, 12]["text"] := oJson["content"][1]["table"]["body"][11, 18]["text"] := " - "
    oJson["content"][1]["table"]["body"][12, 1]["text"]    := STR0086

    If AllTrim(SRA->RA_TPCTSAL) == "1"
        oJson["content"][1]["table"]["body"][2, 1]["text"]     := "V"
    ElseIf AllTrim(SRA->RA_TPCTSAL) != "1"
        oJson["content"][1]["table"]["body"][4, 1]["text"]     := "V"
    EndIf

    cSQL := "SELECT * FROM " + RetSQLName("SA6") + " WHERE A6_FILIAL = ? AND A6_COD = '" + Substr(AllTrim(SRA->RA_BCDEPSA), 1, 3) + "' AND A6_AGENCIA = '" + Substr(AllTrim(SRA->RA_BCDEPSA), 4, Len(AllTrim(SRA->RA_BCDEPSA))) + "' AND D_E_L_E_T_=' ' ORDER BY A6_TYPEACC ASC " 
    cTabl := "SA6"
    aParam := {xFilial("SA6")}
    aField := {'A6_NOME', 'A6_AGENCIA'}
    StaticCall(RU07R10RUS, RU07R1009_SelectData, cTabl, cSQL, aParam, aField, @aDatTemp)

    cNameBank := UPPER(AllTrim(aDatTemp[1, 2]))
    cAccount  := AllTrim(SRA->RA_CTDEPSA)
    cBIK      := AllTrim(aDatTemp[2, 2])

    While nZ <= 3 .AND. AllTrim(SRA->RA_TPCTSAL) == "1" .AND. lEndStr == .T.
        For nY := 1 To 25
            oJson["content"][1]["table"]["body"][6+nZ, nY]["text"] := Substr(cNameBank, 1, 1)
            If Len(cNameBank) > 1
                cNameBank := IIF( nY == 25 .AND. " " $ Substr(cNameBank, 2, 1), Substr(cNameBank, 3, Len(cNameBank)), Substr(cNameBank, 2, Len(cNameBank)) )
            Else
                lEndStr := .F.
                Exit
            EndIf
        Next nY
        nZ++
    EndDo

    While nX <= 25 .AND. AllTrim(SRA->RA_TPCTSAL) == "1"
        If cAccount != NIL .AND. nX != 6 .AND. nX != 12 .AND. nX != 18
            oJson["content"][1]["table"]["body"][11, nX]["text"] := Substr(cAccount, 1, 1)
            cAccount := IIF( Len(cAccount) >= 1, Substr(cAccount, 2, Len(cAccount)), NIL )
        EndIf
        If cBIK != NIL
            oJson["content"][1]["table"]["body"][13, nX]["text"] := Substr(cBIK, 1, 1)
            cBIK := IIF( Len(cBIK) >= 1, Substr(cBIK, 2, Len(cBIK)), NIL )
        EndIf
        nX++
    EndDo

Return oJson


/*/
{Protheus.doc} Get72Part()

    This method builds the part VII of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart72Form_72)
/*/
Method Get72Part() Class RuRHSOZLForm

    Local oJson             As Object
    Local cJson             As Character
    Local nX := 1           As Numeric
    Local cSRAPhone         As Character
    Local aAdress := {}     As Array
    Local cCodmune, cLogrnum As Character
    Local cCep, cEstado, cMunicip, cNumende As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 30],
                    "heights": [11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 3, 11, 3, 11, 11, 11],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 25,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 19, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "colSpan": 8, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "left"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 4, "text": "", "alignment": "right"}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "text": "", "alignment": "right"}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 14, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 25, "bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 3, "bold": true, "text": ""}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["pageBreak"] := "before"
    oJson["content"][1]["table"]["body"][1, 1]["text"]     := STR0087
    oJson["content"][1]["table"]["body"][2, 1]["text"]     := STR0088
    oJson["content"][1]["table"]["body"][4, 1]["text"]     := STR0089
    oJson["content"][1]["table"]["body"][5, 1]["text"]     := STR0090
    oJson["content"][1]["table"]["body"][13, 1]["text"]    := STR0093
    oJson["content"][1]["table"]["body"][14, 1]["text"]    := STR0094
    oJson["content"][1]["table"]["body"][16, 1]["text"]    := STR0095
    oJson["content"][1]["table"]["body"][18, 1]["text"]    := STR0096
    oJson["content"][1]["table"]["body"][20, 1]["text"]    := STR0097
    oJson["content"][1]["table"]["body"][22, 1]["text"]    := STR0098
    oJson["content"][1]["table"]["body"][25, 1]["text"]    := STR0099
    oJson["content"][1]["table"]["body"][25, 12]["text"]   := STR0100
    oJson["content"][1]["table"]["body"][25, 19]["text"]   := STR0101
    oJson["content"][1]["table"]["body"][27, 1]["text"]    := STR0102
    oJson["content"][1]["table"]["body"][28, 1]["text"]    := STR0103
    oJson["content"][1]["table"]["body"][29, 9]["text"]    := oJson["content"][1]["table"]["body"][29, 13]["text"] := ;
    oJson["content"][1]["table"]["body"][29, 17]["text"]   := oJson["content"][1]["table"]["body"][29, 20]["text"] := " - "

    cSRAPhone := IIF( AllTrim(SRA->RA_DDDFONE) != "" .AND. AllTrim(SRA->RA_TELEFON) != "", AllTrim(SRA->RA_DDDFONE) + AllTrim(SRA->RA_TELEFON), AllTrim(SRA->RA_DDDCELU) + AllTrim(SRA->RA_NUMCELU) )
    cSRAPhone := StrTran(StrTran(StrTran(cSRAPhone, "-", ""), "(", ""), ")", "") //PHONE
    cCep      := UPPER(AllTrim(SRA->RA_CEP))
    cEstado   := UPPER(AllTrim(StaticCall(RU07R08RUS, RU07R0803_GetTabValueForKeyOrder, "SX5", "12" + SRA->RA_ESTADO,, "X5Descri()")))
    cMunicip  := UPPER(AllTrim(SRA->RA_MUNICIP))
    aAdress   := ::GetAdress(SRA->RA_MAT)
    cCodmune  := UPPER(AllTrim(fDesc("CC2", aAdress[1], "CC2_MUN",,,3)))
    cLogrnum  := UPPER(AllTrim(aAdress[2]))
    cNumende  := UPPER(AllTrim(SRA->RA_NUMENDE))

    While nX <= 22
        If nX != 9 .AND. nX != 13 .AND. nX != 17 .AND. nX != 20 .AND. cSRAPhone != NIL
            oJson["content"][1]["table"]["body"][29,  nX]["text"] := Substr(cSRAPhone, 1, 1)
            cSRAPhone := IIF( Len(cSRAPhone) >= 1, Substr(cSRAPhone, 2, Len(cSRAPhone)), NIL )
        EndIf
        If AllTrim(SRA->RA_TPCTSAL) != "1"
            If cCep != NIL
                oJson["content"][1]["table"]["body"][15, nX]["text"] := Substr(cCep, 1, 1)
                cCep := IIF( Len(cCep) >= 1, Substr(cCep, 2, Len(cCep)), NIL )
            EndIf
            If cEstado != NIL
                oJson["content"][1]["table"]["body"][17, nX]["text"] := Substr(cEstado, 1, 1)
                cEstado := IIF( Len(cEstado) >= 1, Substr(cEstado, 2, Len(cEstado)), NIL )
            EndIf
            If cMunicip != NIL
                oJson["content"][1]["table"]["body"][19, nX]["text"] := Substr(cMunicip, 1, 1)
                cMunicip := IIF( Len(cMunicip) >= 1, Substr(cMunicip, 2, Len(cMunicip)), NIL )
            EndIf
            If cCodmune != NIL
                oJson["content"][1]["table"]["body"][21, nX]["text"] := Substr(cCodmune, 1, 1)
                cCodmune := IIF( Len(cCodmune) >= 1, Substr(cCodmune, 2, Len(cCodmune)), NIL )
            EndIf
            If cLogrnum != NIL
                oJson["content"][1]["table"]["body"][23, nX]["text"] := Substr(cLogrnum, 1, 1)
                cLogrnum := IIF( Len(cLogrnum) >= 1, Substr(cLogrnum, 2, Len(cLogrnum)), NIL )
            EndIf
            If cNumende != NIL
                oJson["content"][1]["table"]["body"][27, 6+nX]["text"] := Substr(cNumende, 1, 1)
                cNumende := IIF( Len(cNumende) >= 1, Substr(cNumende, 2, Len(cNumende)), NIL )
            EndIf
        EndIf
        nX++
    EndDo

Return oJson


/*/
{Protheus.doc} Get73Part()

    This method builds the part VII of SOZL print form.

    @type Method
    @params
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json with information about the submission of applications and their filing date.
    @example oSOZLObject:AddContent(oPart73Form_73)
/*/
Method Get73Part() Class RuRHSOZLForm

    Local oJson                     As Object
    Local cJson                     As Character
    Local cSubord, cPhone, cEmail   As Character
    Local nX := 1                   As Numeric
    Local nD                        As Numeric

    oJson := JsonObject():New()
    oData := RuRHSTDRForm():New(NIL, ::aFilter, ::cFilter, ::cNameReport)
    aData := oData:GetDataEmployer()

    BeginContent var cJson
    {
        "content": [
            {
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12],
                    "heights": [11, 11, 2, 11, 11, 11, 11, 11, 11, 11, 11, 2, 9, 11, 11, 11, 9, 9],
                    "body": [
                        [
                            {"border": [false, false, false, false], "colSpan": 24,"bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "colSpan": 12, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 9, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 5, "text": "", "alignment": "center"}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, true], "colSpan": 24, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "center"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, true],  "colSpan": 9, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 2, "text": "", "alignment": "center"}, {},
                            {"border": [false, false, false, true],  "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 9, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 2, "text": "", "alignment": "center"}, {},
                            {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "colSpan": 6, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 2, "bold": true, "text": ""}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"margin": [0, 0, 20, 0], "border": [false, false, false, false], "colSpan": 9, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "colSpan": 15, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 24, "bold": true, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"margin": [0, 0, 0, 0], "border": [false, false, false, false], "colSpan": 24, "text": "", "alignment": "left"},
                            {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, true], "colSpan": 8, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, true], "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, true], "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 8, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {},
                            {"border": [false, false, false, false], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 7, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 12, "text": "", "alignment": "left"}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [true, true, true, true], "text": "", "alignment": "center"}, {"border": [true, true, true, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "colSpan": 8, "text": "", "alignment": "center"}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1, 1]["text"]     := CRLF + STR0104
    oJson["content"][1]["table"]["body"][2, 1]["text"]     := STR0105
    oJson["content"][1]["table"]["body"][4, 1]["text"]     := STR0106
    oJson["content"][1]["table"]["body"][4, 12]["text"]    := oJson["content"][1]["table"]["body"][4, 15]["text"] := ;
    oJson["content"][1]["table"]["body"][11, 9]["text"]    := oJson["content"][1]["table"]["body"][11, 13]["text"] := ;
    oJson["content"][1]["table"]["body"][11, 17]["text"]   := oJson["content"][1]["table"]["body"][11, 20]["text"] := " - "
    oJson["content"][1]["table"]["body"][5, 1]["text"]     := STR0107
    oJson["content"][1]["table"]["body"][7, 1]["text"]     := STR0108
    oJson["content"][1]["table"]["body"][9, 1]["text"]     := STR0109
    oJson["content"][1]["table"]["body"][9, 12]["text"]    := STR0110
    oJson["content"][1]["table"]["body"][8, 19]["text"]    := STR0111
    oJson["content"][1]["table"]["body"][9, 19]["text"]    := STR0112
    oJson["content"][1]["table"]["body"][10, 1]["text"]    := STR0113
    oJson["content"][1]["table"]["body"][13, 1]["text"]    := STR0114
    oJson["content"][1]["table"]["body"][14, 1]["text"]    := STR0115
    oJson["content"][1]["table"]["body"][15, 1]["text"]    := STR0116
    oJson["content"][1]["table"]["body"][17, 1]["text"]    := STR0117 + CRLF + STR0118
    oJson["content"][1]["table"]["body"][17, 10]["text"]   := STR0119
    oJson["content"][1]["table"]["body"][17, 18]["text"]   := STR0120
    oJson["content"][1]["table"]["body"][18, 1]["text"]    := STR0121

    cPhone  := StrTran(StrTran(StrTran(AllTrim(aData[5, 2]), "-", ""), "(", ""), ")", "") // PHONE
    cEmail  := AllTrim(aData[6, 2]) // EMAIL
    cSubord := UPPER(AllTrim(aData[7, 2])) // SUBORD
    
    For nD := 1 To 10
        If nD != 3 .AND. nD != 6
            oJson["content"][1]["table"]["body"][4, 9+nD]["text"] :=  Substr(CValToChar(Date()), nD, 1)
        EndIf
    Next nD
    
    oJson["content"][1]["table"]["body"][6, 1]["text"]     := ::cSignerPost + " " + ::cSignerName // RA_DCARGO and RA_NOMECMP
    oJson["content"][1]["table"]["body"][8, 12]["text"]    := CValToChar(Date())
    oJson["content"][1]["table"]["body"][13, 10]["text"]   := cEmail

    While nX <= 22
        If nX != 9 .AND. nX != 13 .AND. nX != 17 .AND. nX != 20 .AND. cPhone != NIL
            oJson["content"][1]["table"]["body"][11,  nX]["text"] := Substr(cPhone, 1, 1)
            cPhone := IIF( Len(cPhone) >= 1, Substr(cPhone, 2, Len(cPhone)), NIL )
        EndIf

        If nX <= 4
            oJson["content"][1]["table"]["body"][18,  12+nX]["text"] := Substr(cSubord, nX, 1)
        Endif
        nX++
    EndDo

Return oJson


/*/
{Protheus.doc} New(cFilterExpression, cNameReport)

    Default constructor.

    @type Method
    @params aFilter,     Array,     Array of filter.
    @params cFilter,     Character, Expression for filter.
    @params cNameReport, Character, Name of report.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return RuRHSOZLForm, Object, RuRHSOZLForm instance.
    @example oSOZLObject := RuRHSOZLForm():New(aFilter, StaticCall(RU07R20RUS, RU07R2006_GetFilterStr, aFilter), NAME_OF_PROGRAM)
/*/
Method New(aFilter, cFilterExpression, cNameReport) Class RuRHSOZLForm

    DEFAULT cNameReport := "RU07R22RUS"

    Self:aFilter := AClone(aFilter)
    Self:cFilter := cFilterExpression
    Self:cNameReport := cNameReport
    Self:cFilialCode := cFilAnt
    Self:cGroupCode := cEmpAnt
    Self:cHeadTitlePage := ""

    If !Empty(::cFilter)
        ::lFilterOn := .T.
        ::aPersonnelNumbers := ::GetPersNumbers()
    Else
        ::lFilterOn := .F.
        ::aPersonnelNumbers := {}
    EndIf

Return Self


/*/
{Protheus.doc} GetPersNumbers()

    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersNumbers()
/*/
Method GetPersNumbers() Class RuRHSOZLForm

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
{Protheus.doc} GetAdress(cMat)

    This method helps to get information about the address by the employee's service number.

    @type Method
    @params cMat, Character, Employee's service number.
    @author alysenko
    @since 11.12.2023
    @version 12.1.33
    @return aResult, Array, Array with address data
    @example aAdress   := ::GetAdress(SRA->RA_MAT)
/*/
Method GetAdress(cMat) Class RuRHSOZLForm

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object
    Local aResult    As Array
    Local aArea      As Array

    aArea := GetArea()

    aResult := {}
    cQuery := " SELECT SRA.RA_CODMUN, SRA.RA_LOGRNUM FROM " + RetSqlName("SRA") + " SRA " 
    cQuery += " WHERE "
    cQuery += " SRA.RA_MAT = ? "
    cQuery += " AND SRA.D_E_L_E_T_ = '' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cMat)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        Aadd(aResult, (cTab)->RA_CODMUN)
        Aadd(aResult, (cTab)->RA_LOGRNUM)
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())
    RestArea(aArea)

Return aResult

/*/
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example  oSOZLObject:AddContent(oTabsIn_1)
/*/
Method AddContent(oJson) Class RuRHSOZLForm

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


/*/
{Protheus.doc} GetViewReport()

    This method get Json for All report and send it to pdf-maker. 

    @type Method
    @params 
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example oSOZLObject:GetViewReport()
/*/
Method GetViewReport() Class RuRHSOZLForm

    Local lResult := .T.  As Logical
    Local cJson           As Character
    Local cOptions        As Character
    Local oData           As Object
    Local oOptions        As Object

    oData := ::GetTemplatate()
    oData["content"] := Iif(ValType(::oGeneralJson) != 'U', ::oGeneralJson["content"], {})

    If lResult
        oOptions := Ru99x50_01_GetOptionsTemplate()
        oOptions['showSidebarButton'] := .F.

        cJson := oData:ToJson()
        cOptions := oOptions:ToJson()

        //Calls library with FWCALLAPP
        ru99x50_pdfmakeForm(cJson,'windows-1251', cOptions, ::cNameReport)
    Else
    // "Error generating JSON" "Could not generate Json for output. Stage:" "Send to PDF-Maker"
        Help(,,STR0085,, STR0086 + CRLF + '"' + STR0084 + '"', 1, 0)
    EndIf

    FwFreeObj(oData)

Return lResult


/*/
{Protheus.doc} GetTemplatate()

    This method biuld empty templatate for report and Json without content.

    @type Method
    @params 
    @author alysenko
    @since 05.12.2023
    @version 12.1.33
    @return oJson, Object, Json for report.
    @example oData := ::GetTemplatate()
/*/
Method GetTemplatate() Class RuRHSOZLForm

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageOrientation": "portrait",
        "pageMargins": [10, 10, 10, 10],
        "styles": {
            "title": {
                "fontSize": 10,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 9,
                "bold": false
            },
            "normal9": {
            "font": "Arial",
                "fontSize": 9,
                "bold": true
            }
        },
        "content": [
            {
                "margin": [10, 10, 10, 10],
                "style": "title"
            }
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson
