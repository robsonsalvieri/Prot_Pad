#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R12RUS.CH"

/*/
{Protheus.doc} RUHREFSReport
    Class for EFS report.

    @type Class
    @author dchizhov
    @since 02.05.2023
    @version 12.1.33
/*/
Class RUHREFSReport From LongNameClass

    Data aParameters       As Array     // Array of parameters.
    Data cFilter           As Character // String of filter.
    Data lFilterOn         As Logical   // Flag of active filter.

    Data cSignerPost       As Character
    Data cSignerName       As Character
    Data cFilialCode       As Character 
    Data cGroupCode        As Character 
    Data cDate             As Character

    Data cNameReport       As Character
    Data cHeadTitlePage    As Character

    Data aPersonnelNumbers As Array     // Array of personel numbers.
    Data oGeneralJson      As Object    // Json for report.

    Method New(aParameters, cFilterExpression, cNameReport) Constructor

    Method GetPersonnelNumbers()
    Method GetTitleList()
    Method AddContent(oJson)
    Method GetDataTitleList()

    //PDFMaker.
    Method GetTemplatate()

    // Reports.
    Method GetViewReport()
    Method GetXMLReport(cDocSavePath)

EndClass

/*/
{Protheus.doc} New(aParameters, cFilterExpression, cNameReport)

    Default constructor.

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params cNameReport, Character, Name of report.
    @author dchizhov
    @since 02.05.2023
    @version 12.1.33
    @return RUHREFSReport, Object, RUHREFSReport instance.
    @example oEFSObject := RUHREFSReport():New(aParam, cFilter)
/*/
Method New(aParameters, cFilterExpression, cNameReport) Class RUHREFSReport

    DEFAULT cNameReport := "RU07R12RUS"

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilterExpression
    Self:cNameReport := cNameReport
    Self:cFilialCode := cFilAnt
    Self:cGroupCode := cEmpAnt
    Self:cHeadTitlePage := ""

    If !Empty(::cFilter)
        ::lFilterOn := .T.
        ::aPersonnelNumbers := ::GetPersonnelNumbers()
    Else
        ::lFilterOn := .F.
        ::aPersonnelNumbers := {}
    EndIf

Return Self

/*/
{Protheus.doc} GetPersonnelNumbers()

    Forms an array with personnel numbers of employees who meet the conditions in the filter.

    @type Method
    @params 
    @author dchizhov
    @since 02.05.2023
    @version 12.1.33
    @return aNumbers, Array, Array of periods in format 'YYYYMM' ordered.
    @example ::aPersonnelNumbers := ::GetPersonnelNumbers()
/*/
Method GetPersonnelNumbers() Class RUHREFSReport

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

    This method get Json for All report and send it to prf-maker. 

    @type Method
    @params 
    @author dchizhov
    @since 02.05.2023
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example oEFSObject:GetViewReport()
/*/
Method GetViewReport() Class RUHREFSReport

    Local lResult := .T.  As Logical
    Local cJson           As Character
    Local cOptions        As Character
    Local oData           As Object
    Local oOptions        As Object


    oData := ::GetTemplatate()

    MsProcTxt(STR0046) // "Collect full Json"

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
        Help(,,STR0048,, STR0049 + CRLF + '"' + STR0047 + '"', 1, 0)
    EndIf

    FwFreeObj(oData)

Return lResult

/*/
{Protheus.doc} GetTitleList()

    This method biuld title-list for report.

    @type Method
    @params 
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
    @return oJson, Object, Json for title-list report.
    @example oEFSObject:AddContent(oEFSObject:GetTitleList())
/*/
Method GetTitleList() Class RUHREFSReport

    Local oJson As Object
    Local cJson As Character
    Local aData As Array
    Local dDate As Date

    oJson := JsonObject():New()
    aData := ::GetDataTitleList()
    dDate := CToD(::cDate)

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [0, 0, 5, 0],
                "style": "normal",
                "fontSize": 10,
                "alignment": "left",
                "table": {
                    "width": "100%",
                    "widths": [410, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false]}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "FontSize": 5},
                            {"border": [false, false, false, false], "text": "", "FontSize": 5}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false]}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false]}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false]}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "FontSize": 5},
                            {"border": [false, false, false, false], "text": "", "FontSize": 5}
                        ],
                        [
                            {"border": [false, false, false, false]},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 18, 0, 0],
                "style": "title"
            },
            {
                "margin": [5, 18, 0, 0],
                "style": "normal",
                "fontSize": 9,
                "bold": true
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal",
                "fontSize": 9,
                "table": {
                    "width": "100%",
                    "widths": [150, 200, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}, {"border": [false, false, false, true]}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal",
                "fontSize": 9,
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": ["*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, true]}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 0, 0, 20],
                "style": "normal",
                "fontSize": 6,
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": ["*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 20],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [25, 200, 50, 150, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "alignment": "right"}, {"border": [false, false, false, true]},
                            {"border": [false, false, false, false], "alignment": "right"}, {"border": [false, false, false, true]}, 
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 20],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [25, 25, 50, 70, 50, 70, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "alignment": "right"}, {"border": [false, false, false, true]},
                            {"border": [false, false, false, false], "alignment": "right"}, {"border": [false, false, false, true]}, 
                            {"border": [false, false, false, false], "alignment": "right"}, {"border": [false, false, false, true]}, 
                            {"border": [false, false, false, false], "text": ""}
                         ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 20],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [60, 70, 60, 80, 110, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false]},
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false]}, 
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false], "text": ""}
                         ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 70],
                "columnGap": 10,
                "columns": [
                    {
                        "width": 80,
                        "style": "normal", 
                        "alignment": "right"
                    },
                    {
                        "style": "normal",
                        "table": {
                            "width": "100%",
                            "widths": [110, 120, "*"],
                            "body": [ 
                                [
                                    {"border": [false, false, false, true]}, 
                                    {"border": [false, false, false, false]}, 
                                    {"border": [false, false, false, true]}
                                ]
                            ]
                        }
                    }
                ]
            },
            {
                "margin": [5, 60, 5, 5],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [200, 50, 50, 30, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, true]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true]}
                        ],
                        [
                           {"border": [false, false, false, false], "colSpan": 2, "alignment": "left"}, {},
                           {"border": [false, false, false, false]}, {"border": [false, false, false, false], "text": ""},
                           {"border": [false, false, false, false]}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 0, 5, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [3, 10, 3, 30, 1, 30, 5, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}, {"border": [false, false, false, true]},
                            {"border": [false, false, false, false]}, {"border": [false, false, false, true]},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true]},
                            {"border": [false, false, false, false]}, {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                           {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                           {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": "", "alignment": "center"},
                           {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                           {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][ 1]["table"]["body"][1, 2]["text"] := STR0127 // "Annex 1"
    oJson["content"][ 1]["table"]["body"][3, 2]["text"] := STR0128 // "Approved"
    oJson["content"][ 1]["table"]["body"][4, 2]["text"] := STR0129 // "Resolution of the Board of the Pension Fund of the Russian Federation"
    oJson["content"][ 1]["table"]["body"][5, 2]["text"] := STR0130 // "dated October 31, 2022 N 245p"
    oJson["content"][ 1]["table"]["body"][7, 1]["text"] := STR0131 // "Form EFS-1"
    oJson["content"][ 2]["text"] := CRLF + CRLF + ::cHeadTitlePage + CRLF + CRLF + CRLF
    oJson["content"][ 3]["text"] := STR0100 + CRLF + CRLF + CRLF // "Insured information:"
    oJson["content"][ 4]["table"]["body"][1, 1]["text"] := STR0052 // "Insured registration number"
    oJson["content"][ 4]["table"]["body"][1, 2]["text"] := AllTrim(aData[1, 2])
    oJson["content"][ 5]["table"]["body"][1, 1]["text"] := AllTrim(aData[2, 2])
    oJson["content"][ 6]["table"]["body"][1, 1]["text"] := STR0053 // "Full name"
    oJson["content"][ 7]["table"]["body"][1, 1]["text"] := STR0054 // "INN"
    oJson["content"][ 7]["table"]["body"][1, 3]["text"] := STR0055 // "KPP"
    oJson["content"][ 7]["table"]["body"][1, 2]["text"] := AllTrim(aData[3, 2])
    oJson["content"][ 7]["table"]["body"][1, 4]["text"] := AllTrim(aData[4, 2])
    oJson["content"][ 8]["table"]["body"][1, 1]["text"] := STR0056 // "OKFS"
    oJson["content"][ 8]["table"]["body"][1, 3]["text"] := STR0057 // "OKOGU"
    oJson["content"][ 8]["table"]["body"][1, 5]["text"] := STR0058 // "OKPO"
    oJson["content"][ 8]["table"]["body"][1, 2]["text"] := AllTrim(aData[5, 2])
    oJson["content"][ 8]["table"]["body"][1, 4]["text"] := AllTrim(aData[6, 2])
    oJson["content"][ 8]["table"]["body"][1, 6]["text"] := AllTrim(aData[7, 2])
    oJson["content"][ 9]["table"]["body"][1, 2]["text"] := STR0059 // "OKVED code"
    oJson["content"][ 9]["table"]["body"][1, 4]["text"] := STR0060 // "OGRN (OGRNIP)"
    oJson["content"][ 9]["table"]["body"][1, 3]["text"] := AllTrim(aData[8, 2])
    oJson["content"][ 9]["table"]["body"][1, 5]["text"] := AllTrim(aData[9, 2])
    oJson["content"][10]["columns"][1]["text"] := STR0061 // "Contact phone number"
    oJson["content"][10]["columns"][2]["table"]["body"][ 1, 2]["text"] := STR0062 // "E-mail address"
    oJson["content"][10]["columns"][2]["table"]["body"][ 1, 1]["text"] := RU07R1212_GetClearPhone(aData[10, 2])
    oJson["content"][10]["columns"][2]["table"]["body"][ 1, 3]["text"] := AllTrim(aData[11, 2])
    oJson["content"][11]["table"]["body"][1, 1]["text"] := AllTrim(::cSignerPost)
    oJson["content"][11]["table"]["body"][1, 5]["text"] := AllTrim(::cSignerName)
    oJson["content"][11]["table"]["body"][2, 1]["text"] := STR0063 // "Name of the position of the signatory"
    oJson["content"][11]["table"]["body"][2, 3]["text"] := STR0101 // "signature"
    oJson["content"][11]["table"]["body"][2, 5]["text"] := STR0064 // "Full name of the signatory"
    oJson["content"][12]["table"]["body"][1, 1]["text"] := STR0103 // "«"
    oJson["content"][12]["table"]["body"][1, 2]["text"] := CValToChar(Day(dDate))
    oJson["content"][12]["table"]["body"][1, 3]["text"] := STR0104 // "»"
    oJson["content"][12]["table"]["body"][1, 4]["text"] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(dDate))
    oJson["content"][12]["table"]["body"][1, 6]["text"] := CValToChar(Year(dDate))
    oJson["content"][12]["table"]["body"][1, 7]["text"] := STR0102 // "y."
    oJson["content"][12]["table"]["body"][2, 4]["text"] := STR0065 // "Date"

Return oJson

/*/
{Protheus.doc} GetDataTitleList()

    This method get data for title-list for report.

    @type Method
    @params 
    @author dchizhov
    @since 03.05.2023
    @version 12.1.33
    @return aData, Array, data for title-list.
    @example oEFSObject:AddContent(oEFSObject:GetTitleList())
/*/
Method GetDataTitleList() Class RUHREFSReport

    Local aData As Array
    Local aInfo As Array
    Local nX    As Numeric
    Local nY    As Numeric
    Local cBran As Character

    aData := {}
    cBran := ""

    If ::lFilterOn
        nX := 1
        While cBran == ""
            nX := At("RA_FILIAL", ::cFilter, nX)
            If nX <= 0
                Exit
            EndIf
            nY := Max(At("<", ::cFilter, nX), 0)
            nX := Max(At(">", ::cFilter, nX), 0)
            If nY < nX
                nX := nY + 1
                Loop
            EndIf
            If nX == 0
                Exit
            EndIf
            nX := At("'", ::cFilter, nX)
            If nX <= 0
                Exit
            EndIf
            nX += 1
            nY := At("'", ::cFilter, nX)
            cBran := SubStr(::cFilter, nX, nY - nX)
        EndDo
    EndIf
    If ExistBlock("MA300015") .And. AllTrim(cBran) <> ""
        aData := ExecBlock("MA300015", .F., .F., {::cGroupCode, ::cFilialCode, cBran})
    Else
        aInfo := FwComAltInf({"CO_COMPGRP", "CO_COMPEMP", "CO_COMPUNI", "CO_TIPO", "CO_PFRREG", "CO_FULLNAM", "CO_INN", ;
        "CO_KPP", "CO_OKFS", "CO_OKOGU", "CO_OKPO", "CO_OKVED", "CO_OGRN", "CO_PHONENU", "CO_EMAIL"}, ::cGroupCode, ::cFilialCode)

        For nX := 5 To Len(aInfo)
            aAdd(aData, aInfo[nX])
        Next nX
    EndIf

Return aData

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
Method AddContent(oJson) Class RUHREFSReport

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
{Protheus.doc} GetTemplatate()

    This method biuld empty templatate for report and Json without content.

    @type Method
    @params 
    @author dchizhov
    @since 02.05.2023
    @version 12.1.33
    @return oJson, Object, Json for report.
    @example oData := ::GetTemplatate()
/*/
Method GetTemplatate() Class RUHREFSReport

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageMargins": [0, 0, 0, 0],
        "styles": {
            "title": {
                "fontSize": 11,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 8,
                "bold": false
            },
            "normal9": {
            "font": "Arial",
                "fontSize": 9,
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

Return oJson
