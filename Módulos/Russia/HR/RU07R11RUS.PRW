#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R11RUS.CH"

#DEFINE LAYOUT_ALIGN_LEFT     1
#DEFINE LAYOUT_ALIGN_RIGHT    2
#DEFINE LAYOUT_ALIGN_HCENTER  4
#DEFINE LAYOUT_ALIGN_TOP      32
#DEFINE LAYOUT_ALIGN_BOTTOM   64
#DEFINE LAYOUT_ALIGN_VCENTER  128

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE BUTTON_HEIGHT_SIZE 15
#DEFINE BUTTON_WIDTH_SIZE 30

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250
#DEFINE SRA_STR_MAX_LENGHT 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE COUNT_PARAMS 8
#DEFINE NAME_OF_PROGRAM "RU07R11RUS"
#DEFINE INDEX_PARAM_COMBOBOX "2"
#DEFINE INDEX_PARAM_SIGNER "3|5|7"

/*/
{Protheus.doc} RU07R11RUS()

    Main function of routine print form of list payment statemant.

    @type Function
    @params 
    @author dchizhov
    @since 17.04.2023
    @version 12.1.33
    @return 
    @example Aadd(aRotina, {STR0026, "RU70R01RUS", 0, 11})
/*/
Function RU07R11RUS()

    Local aInputParameters As Array
    Local lCreateReport    As Logical

    aInputParameters := RU07R1101_GetDialogWindow(STR0001) // "Print sheet"

    If aInputParameters[1]

        MsAguarde({|| ;
                      lCreateReport := RU07R1105_PrintReport(aInputParameters)  ;
                  }, STR0019, STR0020) // "Please wait", "Formation of the list of salaries transferred to the bank".

        If !lCreateReport
            MsgStop(STR0022, STR0017) // "Something went wrong while compiling the list of salaries transferred to the bank", "Error".
        EndIf

    EndIf

Return .T.

/*/
{Protheus.doc} RU07R1104_GetAllData(aPayingType)

    Make a array with data for table part.

    @type Static Function
    @params aPayingType, Array, Types of payments (SRV) for search.
    @author dchizhov
    @since 19.04.2023
    @version 12.1.33
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example aDataList := RU07R1104_GetAllData(aPayingType)
/*/
Static Function RU07R1104_GetAllData(aPayingType)

    Local aDataArray           As Array
    Local aArea                As Array
    Local cTable               As Character
    Local cAlias               As Character
    Local cFields              As Character
    Local cWhere               As Character
    Local cGroupCond           As Character
    Local nX                   As Numeric

    aArea := GetArea()
    aDataArray := {}
    cTable := RC0->RC0_ALIAS
    cFields := PrefixoCpo(cTable) + "_"

    cWhere := "% SRT." + cFields + "FILIAL = '" + RC1->RC1_FILTIT + "'" + CRLF
    cWhere += Iif(Empty(AllTrim(RC1->RC1_CC)), "", "AND SRT." + cFields + "CC = '" + RC1->RC1_CC + "'" + CRLF)
    cWhere += Iif(Empty(AllTrim(RC1->RC1_DEPTO)), "", "AND SRT." + cFields + "DEPTO = '" + RC1->RC1_DEPTO + "'" + CRLF)
    cWhere += Iif(Empty(AllTrim(RC1->RC1_MAT)), "", "AND SRT." + cFields + "MAT = '" + RC1->RC1_MAT + "'" + CRLF)
    cWhere += "AND " + "SRT." + cFields + Iif(cTable == "SRR", "DATAPAG", Iif(cTable == "SRD", "DATPGT", "DATA")) + " = '" + DToS(RC1->RC1_EMISSA) + "'" + CRLF

    cWhere += "AND SRT." + cFields + "PD IN ("
    For nX := 1 To Len(aPayingType)
        cWhere += Iif(nX > 1, ", '", "'") + aPayingType[nX] + "'"
    Next nX
    cWhere += ")"

    cWhere += " %"

    cGroupCond := "% SRT." + cFields + "FILIAL" + ", SRT." + cFields + "MAT %"
    cFields := "% SUM(SRT." + cFields + "VALOR) VALOR" + ", SRT." + cFields + "FILIAL FILIAL" + ", SRT." + cFields + "MAT MAT %"
    
    cTable := "%" + RetSqlName(cTable) + "%"

    cAlias := GetNextAlias()
    
    BeginSql Alias cAlias
    SELECT %Exp:cFields%
        FROM %Exp:cTable% SRT
        WHERE %Exp:cWhere%
            AND SRT.%NotDel%
        GROUP BY %Exp:cGroupCond%
    EndSQL

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        Aadd(aDataArray, {(cAlias)->MAT, (cAlias)->FILIAL, (cAlias)->VALOR})
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU07R1105_PrintReport(aParam)

    Get data/ Get Json and send this for a print report.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 19.04.2023
    @version 12.1.33
    @return .T.
    @example lCreateReport := RU07R1105_PrintReport(aInputParameters)
/*/
Static Function RU07R1105_PrintReport(aParam)

    Local oJson    As Object
    Local oOptions As Object
    Local cJson    As Character
    Local cOptions As Character

    oJson := RU07R1110_GetTemplatate()
    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    RU07R1106_FillData(oJson["content"], aParam)

    cJson := oJson:ToJson()
    cOptions := oOptions:ToJson()

    ru99x50_pdfmakeForm(cJson, 'windows-1251', cOptions, 'RU07R11')

Return .T.

/*/
{Protheus.doc} RU07R1106_FillData(aArray, aParam)

    Fill data array for Json.

    @type Static Function
    @params aArray, Array, Array of content Json.
    @params aParam, Array, Parametr which enter the user.
    @author dchizhov
    @since 26.04.2023
    @version 12.1.33
    @return 
    @example RU07R1106_FillData(oJson["content"], aParam)
/*/
Static Function RU07R1106_FillData(aArray, aParam)

    Local aGetCoBrRusInfo As Array
    Local aArea           As Array
    Local aRC0Area        As Array
    Local aRC1Area        As Array
    Local aSA6Area        As Array
    Local cTempChar       As Character
    Local nX              As Numeric
    Local nIter           As Numeric
    Local aPayingType     As Array
    Local aDataList       As Array
    Local cJson           As Character
    Local oJson           As Object
    Local nItog           As Numeric
    Local nMargin         As Numeric
    Local aLen            As Array
    Local lNotBank        As Logical
    Local xItemFill

    aRC0Area := RC0->(GetArea())
    aRC1Area := RC1->(GetArea())
    aSA6Area := SA6->(GetArea())
    aSRAArea := SRA->(GetArea())
    aArea := GetArea()
    lNotBank := .F.
    aPayingType := {}

    xItemFill := aArray[4]["table"]["body"]
    aGetCoBrRusInfo := GetCoBrRUS(RC1->RC1_FILTIT)

    If Empty(AllTrim(aGetCoBrRusInfo[2, 6, 2]))
        xItemFill[1, 3]["text"] := aGetCoBrRusInfo[1, 5, 2]
    Else
        xItemFill[1, 3]["text"] := aGetCoBrRusInfo[2, 6, 2]
    EndIf

    Posicione("RC0", RetOrdem("RC0", "RC0_FILIAL+RC0_CODTIT"), xFilial("RC0") + RC1->RC1_CODTIT, "RC0_VERBAS")
    If Empty(AllTrim(aParam[2]))
        lNotBank := .T.
        xItemFill[4, 3]["text"] := ""
    Else
        Posicione("SA6", RetOrdem("SA6", "A6_FILIAL+A6_COD"), xFilial("SA6") + aParam[2], "A6_NOME")
        xItemFill[4, 3]["text"] := AllTrim(SA6->A6_NOME)
    EndIf

    If RC0->RC0_CODTIT == RC1->RC1_CODTIT
        cTempChar := AllTrim(RC0->RC0_VERBAS)
        For nX := 1 To Len(cTempChar) Step 4
            Aadd(aPayingType, SubStr(cTempChar, nX, 3))
        Next nX
    EndIf

    xItemFill[2, 3]["text"] := CValToChar(aParam[3])

    xItemFill[3, 3]["text"] := STR0064

    aDataList := RU07R1104_GetAllData(aPayingType)
    xItemFill := aArray[6]["table"]["body"]

    nIter := 1
    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
    nItog := 0
    For nX := 1 To Len(aDataList)
        If !Empty(Posicione("SRA", nOrder, aDataList[nX, 1], "RA_MAT"))
            If (lNotBank .And. Empty(AllTrim(SRA->RA_BCDEPSA))) .Or. (!lNotBank .And. AllTrim(SA6->A6_COD + SA6->A6_AGENCIA) == AllTrim(SRA->RA_BCDEPSA))
                BeginContent var cJson
                {
                    "tblrow": [
                        {"border": [true, true, true, true], "text": "", "style": "tabledata1", "margin": [0, 0, 0, 0]}, 
                        {"border": [true, true, true, true], "text": "", "style": "tabledata1", "margin": [0, 0, 0, 0]}, 
                        {"border": [true, true, true, true], "text": "", "style": "tabledata1", "margin": [0, 0, 0, 0]}, 
                        {"border": [true, true, true, true], "text": "", "style": "tabledata1", "margin": [0, 0, 0, 0]}, 
                        {"border": [true, true, true, true], "text": "", "style": "tabledata1", "margin": [0, 0, 0, 0]}, 
                        {"border": [true, true, true, true], "text": "", "style": "tabledata2", "margin": [0, 0, 0, 0]},
                        {"border": [true, true, true, true], "text": "", "style": "tabledata2", "margin": [0, 0, 0, 0]},
                        {"border": [true, true, true, true], "text": "", "style": "tabledata2", "margin": [0, 0, 0, 0]}
                    ]
                }
                EndContent
                oJson := JsonObject():New()
                oJson:FromJson(cJson)
                oJson["tblrow"][1]["text"] := CValToChar(nIter)
                oJson["tblrow"][2]["text"] := AllTrim(SRA->RA_CTDEPSA)
                oJson["tblrow"][3]["text"] := AllTrim(SRA->RA_PRISOBR)
                oJson["tblrow"][4]["text"] := AllTrim(SRA->RA_PRINOME)
                oJson["tblrow"][5]["text"] := AllTrim(SRA->RA_SECNOME)
                oJson["tblrow"][6]["text"] := DToC(SRA->RA_NASC)
                oJson["tblrow"][7]["text"] := Str(aDataList[nX, 3], , 2)
                Aadd(xItemFill, oJson["tblrow"])
                nItog += aDataList[nX, 3]
                nIter += 1
            EndIf
        EndIf
    Next nX

    BeginContent var cJson
    {
        "rowitog": [
            {"border": [false, false, false, false], "text": "", "style": "tablehead", "fontSize": 10, "colSpan": 6, "alignment": "right"}, {}, {}, {}, {}, {},
            {"border": [true, true, true, true], "text": "", "style": "tabledata2"},
            {"border": [true, true, true, true], "text": "", "style": "tabledata2"}
        ]
    }
    EndContent
    oJson := JsonObject():New()
    oJson:FromJson(cJson)
    oJson["rowitog"][1]["text"] := STR0054 // "Total by sheet:"
    oJson["rowitog"][7]["text"] := Str(nItog, , 2)
    Aadd(xItemFill, oJson["rowitog"])
    xItemFill := aArray[8]["table"]["body"]
    nMargin := 0
    xItemFill[1, 2]["text"] := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParam[4])) // Get name of post for signature
    xItemFill[1, 6]["text"] := AllTrim(aParam[5])
    If !Empty(AllTrim(aParam[6]))
        xItemFill[4, 2]["text"] := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParam[6])) // Get name of post for signature
        xItemFill[4, 6]["text"] := AllTrim(aParam[7])
    EndIf
    If !Empty(AllTrim(aParam[8]))
        xItemFill[7, 2]["text"] := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParam[8])) // Get name of post for signature
        xItemFill[7, 6]["text"] := AllTrim(aParam[9])
    EndIf
    For nX := 1 To 7 Step 3
        aLen := {Int((Len(xItemFill[nX, 2]["text"]) - 1) / 47), Int((Len(xItemFill[nX, 6]["text"]) - 1) / 50)} // 47 and 50 - magic number (depends on cell width and font)
        nMargin := Max(aLen[1], aLen[2])
        xItemFill[nX, 1]["margin"] := {0, (nMargin) * 9, 0, 0} // 9 - magic number (depends font)
        xItemFill[nX, 2]["margin"] := {0, (nMargin - aLen[1]) * 9, 0, 0} // 9 - magic number (depends font)
        xItemFill[nX, 6]["margin"] := {0, (nMargin - aLen[2]) * 9, 0, 0} // 9 - magic number (depends font)
    Next nX
    xItemFill[10, 6]["text"] := DToC(RC1->RC1_EMISSA)

    RC0->(RestArea(aRC0Area))
    RC1->(RestArea(aRC1Area))
    SA6->(RestArea(aSA6Area))
    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return .T.

/*/
{Protheus.doc} RU07R1110_GetTemplatate()

    Create Json for report without data (some header and STR fill in json).

    @type Static Function
    @params 
    @author dchizhov
    @since 20.04.2023
    @version 12.1.33
    @return oJson, Object, Json for report.
    @example oJson := RU07R1110_GetTemplatate()
/*/
Static Function RU07R1110_GetTemplatate()

    Local oJson  As Object
    Local oJsonI As Object
    Local cJson  As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageOrientation": "landscape",
        "pageMargins": [0, 0, 0, 0],
        "styles": {},
        "content": [
            {
                "margin": [5, 18, 5, 0],
                "style": "title"
            },
            {
                "margin": [5, 18, 5, 0],
                "table": {
                    "width": "100%",
                    "widths": [150, 90, 75, 60, 80, 100],
                    "body": [
                        [   
                            {"border": [false, false, false, false], "text": ""}, 
                            { 
                                "style": "title",
                                "alignment": "right",
                                "border": [false, false, false, false]
                            }, 
                            {"border": [false, false, false, true], "text": "", "style": "title2"}, {"style": "title", "border": [false, false, false, false]}, 
                            {"border": [false, false, false, true], "text": "", "style": "title2"}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 18, 5, 0],
                "style": "title"
            },
            {
                "margin": [5, 18, 5, 0],
                "table": {
                    "width": "100%",
                    "widths": [25, 100, "*"],
                    "body":[]
                }
            },
            {
                "margin": [5, 18, 5, 0],
                "style": "title"
            },
            {
                "margin": [5, 18, 5, 0],
                "table": {
                    "width": "100%",
                    "widths": [25, 135, 145, 145, 150, 60, 60, "*"],
                    "body":[
                        [   
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"},
                            {"margin": [0, 5, 0, 5], "border": [true, true, true, true], "text": "", "style": "tablehead"}
                        ]
                    ]
                }
            },
            {
                "margin": [5, 18, 5, 0],
                "style": "title"
            },
            {
                "margin": [5, 18, 5, 0],
                "table": {
                    "width": "100%",
                    "widths": [115, 210, 70, 100, 60, 60, 155]
                }
            }
        ]

    }
    EndContent
    oJson:FromJson(cJson)
    oJson["styles"] := RU07R1113_CreateStyles()["styles"]
    oJson["content"][1]["text"] := STR0039 + CRLF
    oJson["content"][2]["table"]["body"][1, 2]["text"] := STR0040 // "N"
    oJson["content"][2]["table"]["body"][1, 3]["text"] := RC1->RC1_NUMTIT
    oJson["content"][2]["table"]["body"][1, 4]["text"] := STR0041 // "from"
    oJson["content"][2]["table"]["body"][1, 5]["text"] := DToC(RC1->RC1_EMISSA)
    oJson["content"][3]["text"] := ""
    Aadd(oJson["content"][4]["table"]["body"], RU07R1111_HeadTempl()["EmptStrs"])
    Aadd(oJson["content"][4]["table"]["body"], RU07R1111_HeadTempl()["EmptStrs"])
    Aadd(oJson["content"][4]["table"]["body"], RU07R1111_HeadTempl()["EmptStrs"])
    Aadd(oJson["content"][4]["table"]["body"], RU07R1111_HeadTempl()["EmptStrs"])
    oJson["content"][4]["table"]["body"][1, 2]["text"] := STR0042 // "Organization:"
    oJson["content"][4]["table"]["body"][2, 2]["text"] := STR0043 // "Income type code:"
    oJson["content"][4]["table"]["body"][3, 2]["text"] := STR0044 // "Unit of measurement:"
    oJson["content"][4]["table"]["body"][4, 2]["text"] := STR0045 // "Bank"
    oJson["content"][5]["text"] := ""
    oJson["content"][6]["table"]["body"][1, 1]["text"] := STR0046 // "N p/p"
    oJson["content"][6]["table"]["body"][1, 2]["text"] := STR0047 // "Personal account"
    oJson["content"][6]["table"]["body"][1, 3]["text"] := STR0048 // "Surname"
    oJson["content"][6]["table"]["body"][1, 4]["text"] := STR0049 // "Name"
    oJson["content"][6]["table"]["body"][1, 5]["text"] := STR0050 // "Surname"
    oJson["content"][6]["table"]["body"][1, 6]["text"] := STR0051 // "Date of Birth."
    oJson["content"][6]["table"]["body"][1, 7]["text"] := STR0052 // "Sum"
    oJson["content"][6]["table"]["body"][1, 8]["text"] := STR0053 // "Recovered"
    oJson["content"][7]["text"] := CRLF
    oJsonI := RU07R1112_CreateFooter()
    oJson["content"][8]["table"]["body"] := oJsonI["footer"]

Return oJson

/*/
{Protheus.doc} RU07R1111_HeadTempl()

    Make a array with empty str header for Json.

    @type Static Function
    @params 
    @author dchizhov
    @since 21.04.2023
    @version 12.1.33
    @return oJson, Object, Json with array of header.
    @example Aadd(oJson["content"][4]["table"]["body"], RU07R1111_HeadTempl()["EmptStrs"])
/*/
Static Function RU07R1111_HeadTempl()

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "EmptStrs": [
            {"border": [false, false, false, false], "text": ""}, 
            { 
                "style": "headtext",
                "border": [false, false, false, false]
            }, 
            {"border": [false, false, false, true], "style": "headtext2", "text": ""}
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson

/*/
{Protheus.doc} RU07R1112_CreateFooter()

    Make a array with footer for Json (eithout data).

    @type Static Function
    @params 
    @author dchizhov
    @since 24.04.2023
    @version 12.1.33
    @return oJson, Object, Json with array of footer.
    @example oJson["content"][8]["table"]["body"] := RU07R1112_CreateFooter()["footer"]
/*/
Static Function RU07R1112_CreateFooter()

    Local oJson As Object
    Local oJsoI As Object
    Local cJson As Character

    oJson := JsonObject():New()
    oJsoI := JsonObject():New()

    BeginContent var cJson
    {
        "footer": [
            [
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, true], "text": "", "style": "footer2"},
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, true], "text": "", "style": "footer2"},
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, true], "text": "", "style": "footer2", "colSpan": 2}, {}
            ],
            [
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, false], "text": "", "style": "footer3"},
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, false], "text": "", "style": "footer3"},
                {"border": [false, false, false, false], "text": "", "style": "footer1"},
                {"border": [false, false, false, false], "text": "", "style": "footer3", "colSpan": 2}, {}
            ],
            [
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""}
            ]
        ]
    }
    EndContent
    oJson:FromJson(cJson)
    oJsoI:FromJson(cJson)
    Aadd(oJson["footer"], oJsoI["footer"][1])
    Aadd(oJson["footer"], oJsoI["footer"][2])
    Aadd(oJson["footer"], oJsoI["footer"][3])
    oJsoI:FromJson(cJson)
    Aadd(oJson["footer"], oJsoI["footer"][1])
    Aadd(oJson["footer"], oJsoI["footer"][2])
    Aadd(oJson["footer"], oJsoI["footer"][3])
    BeginContent var cJson
    {
        "footer": [
            [
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, false], "text": ""},
                {"border": [false, false, false, true], "text": "", "style": "footer2", "alignment": "left"},
                {"border": [false, false, false, false], "text": "", "style": "footer2", "alignment": "left"}
            ]
        ]
    }
    EndContent
    oJsoI:FromJson(cJson)
    Aadd(oJson["footer"], oJsoI["footer"][1])
    oJson["footer"][ 1, 1]["text"] := STR0055 // "Supervisor"
    oJson["footer"][ 2, 1]["text"] := STR0056 // "organizations"
    oJson["footer"][ 4, 1]["text"] := STR0057 // "Main"
    oJson["footer"][ 5, 1]["text"] := STR0058 // "accountant"
    oJson["footer"][ 7, 1]["text"] := STR0059 // "Accountant"
    oJson["footer"][ 2, 2]["text"] := STR0060 // "job title"
    oJson["footer"][ 2, 4]["text"] := STR0061 // "signature"
    oJson["footer"][ 2, 6]["text"] := STR0062 // "full name"
    oJson["footer"][ 5, 2]["text"] := STR0060 // "job title"
    oJson["footer"][ 5, 4]["text"] := STR0061 // "signature"
    oJson["footer"][ 5, 6]["text"] := STR0062 // "full name"
    oJson["footer"][ 8, 2]["text"] := STR0060 // "job title"
    oJson["footer"][ 8, 4]["text"] := STR0061 // "signature"
    oJson["footer"][ 8, 6]["text"] := STR0062 // "full name"
    oJson["footer"][10, 7]["text"] := STR0063 // "y."

Return oJson

/*/
{Protheus.doc} RU07R1113_CreateStyles()

    Make a array with styles for Json.

    @type Static Function
    @params 
    @author dchizhov
    @since 24.04.2023
    @version 12.1.33
    @return oJson, Object, Json with array of styles.
    @example oJson["styles"] := RU07R1113_CreateStyles()["styles"]
/*/
Static Function RU07R1113_CreateStyles()

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "styles": {
            "title": {
                "fontSize": 12,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "title2": {
                "fontSize": 12,
                "bold": false,
                "italics": true,
                "font": "Arial",
                "alignment": "center"
            },
            "headtext": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial",
                "alignment": "left"
            },
            "headtext2": {
                "fontSize": 10,
                "bold": false,
                "italics": true,
                "font": "Arial",
                "alignment": "left"
            },
            "tablehead": {
                "fontSize": 8,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "tabledata1": {
                "fontSize": 11,
                "bold": false,
                "italics": true,
                "font": "Arial",
                "alignment": "left"
            },
            "tabledata2": {
                "fontSize": 11,
                "bold": false,
                "italics": true,
                "font": "Arial",
                "alignment": "right"
            },
            "footer1": {
                "fontSize": 9,
                "bold": true,
                "font": "Arial",
                "alignment": "left"
            },
            "footer2": {
                "fontSize": 8,
                "bold": false,
                "italics": true,
                "font": "Arial",
                "alignment": "center"
            },
            "footer3": {
                "fontSize": 6,
                "bold": false,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
                "fontSize": 10,
                "bold": false,
                "font": "Arial",
                "alignment": "left"
            }
        }
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson

/********** functions about parametrs *************/

/*/
{Protheus.doc} RU07R1101_GetDialogWindow(cNamesOfReport)

    Shows a window for user input.

    @type Static Function
    @params cNamesOfReport, Character, Title for window.
    @author dchizhov
    @since 17.04.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example aInputParameters := RU07R1101_GetDialogWindow(STR0001) // "Print sheet"
/*/
Static Function RU07R1101_GetDialogWindow(cNamesOfReport)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local aItems              As Array
    Local cNChar              As Character
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local nIndex              As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character

    cIdUser := "U" + RetCodUsr()
    aResultDialog := {.F.}

    aParamtrField := {{Array(COUNT_PARAMS), , }, {Array(COUNT_PARAMS), , Array(COUNT_PARAMS)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1103_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1103_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1103_GetStrParam(3)
    aItems := RU07R1103_GetStrParam(4)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM)

    For nI := 1 To COUNT_PARAMS
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                nIndex := Val(aUserSettings[nI])
                If nIndex <= Len(aItems) .And. nIndex > 0
                    aParamtrField[2, 2, nI] := aItems[nIndex]
                    aParamtrField[2, 3, nI] := nIndex
                EndIf
            Else
                aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            EndIf
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(cNamesOfReport)
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1102_IsAcceptButton(aParamtrField[2, 2])})

    //oPanelMain := oDialog:getPanelMain()
    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS

        cNChar := CValToChar(nI)

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        If cNChar $ INDEX_PARAM_COMBOBOX
            aParamtrField[2, 1, nI] := TComboBox():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), aItems,  TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, oScrollBox,,;
            &("{|o| aParamtrField[2, 3, " + cNChar + "] := o:nAt}"),,,, .T.,,,,,,,,, "aParamtrField[2, 2, " + cNChar + "]")
        Else
            aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F., ;
            Iif(cNChar $ INDEX_PARAM_SIGNER, &("{|| Iif(!RU70R0104_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"), Nil), CValToChar(nI - 1) $ INDEX_PARAM_SIGNER,,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)
        EndIf

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    aParamtrField[2, 1, 1]:cF3 := "BCO"
    aParamtrField[2, 1, 3]:cF3 := "SQ3"
    aParamtrField[2, 1, 5]:cF3 := "SQ3"
    aParamtrField[2, 1, 7]:cF3 := "SQ3"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. /*FONT oMemoFont*/ NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        aResultDialog[1] := .T.

        For nI := 1 To COUNT_PARAMS
            If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                Aadd(aResultDialog, aParamtrField[2, 3, nI])
                aUserSettings[nI] := CValToChar(aParamtrField[2, 3, nI])
            Else
                Aadd(aResultDialog, aParamtrField[2, 2, nI])
                aUserSettings[nI] := aParamtrField[2, 2, nI]
            EndIf
        Next nI

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1102_IsAcceptButton(aUserParam)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 17.04.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example oDialog:SetValid({|| RU07R1102_IsAcceptButton(aParamtrField[2, 2])})
/*/
Static Function RU07R1102_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    lResultValidation := .T. // Default value.

    // cError += Iif(Empty(AllTrim(aUserParam[1])), CRLF + "'" + STR0012 + "'", "") // "Bank"
    cError += Iif(Empty(AllTrim(aUserParam[2])), CRLF + "'" + STR0013 + "'", "") // "Income Code"
    cError += Iif(Empty(AllTrim(aUserParam[3])) .Or. Empty(AllTrim(aUserParam[4])), CRLF + "'" + STR0014 + "'", "") // "Signer 1"

    If !Empty(cError)
        lResultValidation := .F.
        cError := STR0025 + CRLF + cError // "Parameters not filled:"
        MsgStop(cError, STR0017) // "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU07R1103_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps or for combobox param.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 17.04.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1103_GetStrParam(2)
/*/
Static Function RU07R1103_GetStrParam(nMode)

    Local aArray As Array

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS)

    If nMode == 1
        aArray[ 1] := STR0012 // "Bank"
        aArray[ 2] := STR0013 // "Income Code"
        aArray[ 3] := STR0014 // "Signer 1"
        aArray[ 4] := STR0034 // "Name 1"
        aArray[ 5] := STR0015 // "Signer 2"
        aArray[ 6] := STR0035 // "Name 2"
        aArray[ 7] := STR0016 // "Signer 3"
        aArray[ 8] := STR0036 // "Name 3"
    ElseIf nMode == 2
        aArray[ 1] := Space(TamSX3("A6_COD")[1])
        aArray[ 2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 3] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 4] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 5] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 6] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 7] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 8] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0002 // "Choose payroll project"
        aArray[ 2] := STR0003 // "Select if income collection is possible"
        aArray[ 3] := STR0009 // "Select from the directory the position of the signatory - Head"
        aArray[ 4] := STR0034 // "Name 1
        aArray[ 5] := STR0010 // "Select from the directory the position of the signatory - Chief Accountant"
        aArray[ 6] := STR0035 // "Name 2"
        aArray[ 7] := STR0011 // "Select from the directory the position of the signatory - Accountant"
        aArray[ 8] := STR0036 // "Name 3"
    ElseIf nMode == 4
        aArray := Array(5)
        aArray[ 1] := STR0004 // "allowed with restriction"
        aArray[ 2] := STR0005 // "prohibited without reservation (periodic payments)"
        aArray[ 3] := STR0006 // "prohibited except for alimony (periodic payments)"
        aArray[ 4] := STR0007 // "prohibited without reservation (one-time payments)"
        aArray[ 5] := STR0008 // "prohibited except for alimony (one-time payments)"
    Else
        aArray := {}
    EndIf

Return aArray
