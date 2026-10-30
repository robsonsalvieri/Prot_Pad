#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R15RUS.CH"

#DEFINE SEPARATOR_LINE_ARRAY {" ", "!", "?"}

/*/
{Protheus.doc} RUHREFSP1S12A2Report

    Class for EFS report part 1 subsection 1.1 - SZV-TD.

    @type Class
    @author dchizhov
    @since 15.06.2023
    @version 12.1.33
/*/
Class RUHREFSP1S11SZVTDReport From LongNameClass

    Data aParameters  As Array     // Array of parameters.
    Data oGeneralJson As Object    // Json for report.

    Method New(aParameters) Constructor

    Method AddContent(oJson)

    Method GetPart1()
    Method GetTab1()
    Method GetData()
    Method GetWork(aRow)
    Method GetHistMoving(aData)
    Method CalcLineCount(cString, nLen)

EndClass

/*/
{Protheus.doc} New(aParameters)

    Default constructor.

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
    @return RUHREFSP1S12A2Report, Object, RUHREFSP1S12A2Report instance.
    @example oEFSSZVTDObj := RUHREFSP1S11SZVTDReport():New(aParam)
/*/
Method New(aParameters) Class RUHREFSP1S11SZVTDReport

    Self:aParameters := AClone(aParameters)

    Self:oGeneralJson := JsonObject():New()
    Self:oGeneralJson["content"] := {}

Return Self

/*/
{Protheus.doc} GetGeneralInfo(lPageBreak)

    This method biuld part of subsection 1.1 before table.

    @type Method
    @params lPageBreak, Logical, Page break befor or not.
    @author dchizhov
    @since 15.06.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oSubs1_1 := oEFSSZVTDObj:GetPart1()
/*/
Method GetPart1(lPageBreak) Class RUHREFSP1S11SZVTDReport

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [20, 10, 0, 0],
                "style": "title",
                "fontSize": 10,
                "alignment": "left"
            },
            {
                "margin": [2, 9, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [290, 50, 100, 60, 65, 8],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": "", "fontSize": 2}, {"border": [false, false, false, false], "text": "", "fontSize": 2},
                            {"border": [false, false, false, false], "text": "", "fontSize": 2}, {"border": [false, false, false, false], "text": "", "fontSize": 2},
                            {"border": [false, false, false, false], "text": "", "fontSize": 2}, {"border": [false, false, false, false], "text": "", "fontSize": 2}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [true, true, true, true], "text": "", "alignment": "center"}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    If lPageBreak
        oJson["content"][1]["pageBreak"] := "before"
        oJson["content"][1]["pageOrientation"] := "landscape"
    EndIf
    oJson["content"][1]["text"] := STR0032 // "Subsection 1.1. Information about labor (other) activity"
    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0033 // "An application has been submitted for the continuation of the work book"
    oJson["content"][2]["table"]["body"][1, 2]["text"] := STR0034 // "date of application"
    oJson["content"][2]["table"]["body"][1, 5]["text"] := STR0035 // "Cancellation sign"
    oJson["content"][2]["table"]["body"][3, 1]["text"] := STR0036 // "An application for the provision of information about labor activity has been submitted"
    oJson["content"][2]["table"]["body"][3, 2]["text"] := STR0037 // "date of application"
    oJson["content"][2]["table"]["body"][3, 5]["text"] := STR0038 // "Cancellation sign"

Return oJson

/*/
{Protheus.doc} GetTab1()

    This method biuld table for subsection 1.1 of part 1 for report.

    @type Method
    @params 
    @author dchizhov
    @since 15.06.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oTabs1_1 := oEFSSZVTDObj:GetTab1()
/*/
Method GetTab1() Class RUHREFSP1S11SZVTDReport

    Local oJson As Object
    Local aRow  As Array
    Local cJson As Character
    Local nX    As Numeric
    Local nY    As Numeric
    Local aData As Array
    Local nMarg As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [0, 3, 0, 0],
                "style": "normal",
                "fontSize": 7,
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [15, 80, 60, 90, 95, 60, 140, 60, 45, 55, 40],
                    "body": [ 
                        [
                            {"rowSpan": 2, "text": "", "margin": [0, 20, 0, 0]}, 
                            {"rowSpan": 2, "text": "", "margin": [0, 3, 0, 0]},
                            {"rowSpan": 2, "text": ""}, 
                            {"rowSpan": 2, "text": "", "margin": [0, 6, 0, 0]},
                            {"rowSpan": 2, "text": "", "margin": [0, 3, 0, 0]}, 
                            {"rowSpan": 2, "text": "", "margin": [0, 15, 0, 0]},
                            {"rowSpan": 2, "text": "", "margin": [0, 15, 0, 0]}, 
                            {"colSpan": 3, "text": ""},
                            {}, {}, {"rowSpan": 2, "text": "", "margin": [0, 15, 0, 0]}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {},
                            {"text": "", "margin": [0, 13, 0, 0]}, {"text": "", "margin": [0, 20, 0, 0]}, 
                            {"text": "", "margin": [0, 13, 0, 0]}, {}
                        ],
                        [
                            {}, {}, {}, {},
                            {}, {}, {}, {},
                            {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][1,  1]["text"] := STR0039 // "No. p / p"
    oJson["content"][1]["table"]["body"][1,  2]["text"] := STR0040 + CRLF + STR0041 + CRLF + STR0042 // "Date (day, month, year) of acceptance, transfer, dismissal, start of the GPC agreement,", "end of contract", "GPC"
    oJson["content"][1]["table"]["body"][1,  3]["text"] := STR0043 // "Information about the admission, transfer, dismissal, the beginning of the GPC agreement, the end of the GPC agreement"
    oJson["content"][1]["table"]["body"][1,  4]["text"] := STR0044 // "Work in the regions of the Far North / work in areas equivalent to the regions of the Far North"
    oJson["content"][1]["table"]["body"][1,  5]["text"] := STR0045 + CRLF + STR0046 + CRLF + STR0047 + CRLF + STR0048 + CRLF + STR0049 // "Labor function (position,", "profession, profession,", "qualification, specific", "type of assigned work)", "structural subdivision"
    oJson["content"][1]["table"]["body"][1,  6]["text"] := STR0050 + CRLF + STR0051 + CRLF + STR0052 // "Code", "performed", "functions"
    oJson["content"][1]["table"]["body"][1,  7]["text"] := STR0053 + CRLF + STR0054 + CRLF + STR0055 // "Reasons for dismissal, paragraph, part of the article,", "article of the Labor Code of the Russian", "Federation, federal law"
    oJson["content"][1]["table"]["body"][1,  8]["text"] := STR0056 // "Base"
    oJson["content"][1]["table"]["body"][1, 11]["text"] := STR0057 + CRLF + STR0058 + CRLF + STR0059 // "records", "sign", "cancellation"
    oJson["content"][1]["table"]["body"][2,  8]["text"] := STR0060 + CRLF + STR0061 // "Name", "document"
    oJson["content"][1]["table"]["body"][2,  9]["text"] := STR0062 // "date"
    oJson["content"][1]["table"]["body"][2, 10]["text"] := STR0063 + CRLF + STR0064// "Number", "document"

    For nX := 1 To 11
        oJson["content"][1]["table"]["body"][3,  nX]["text"] := CValToChar(nX)
    Next nX

    aData := ::GetData()

    For nX := 1 To Len(aData)
        aRow := Array(11)
        For nY := 1 To Len(aRow)
            aRow[nY] := JsonObject():New()
        Next nY

        aRow[1]["text"] := CValToChar(nX)
        For nY := 1 To Len(aData[nX]) - 1
            aRow[1 + nY]["text"] := aData[nX, nY]
        Next nY
        aRow[11]["text"] := Iif(::aParameters[3] == 1, "X", "")
        If Len(aRow) > 10
            nMarg := Iif(aData[nX, 11] > 0, (aData[nX, 11] - 1) * (oJson["content"][1]["fontSize"] + 1) / 2, 0)
            aRow[1]["margin"] := {0, nMarg, 0, 0}
            aRow[2]["margin"] := {0, nMarg, 0, 0}
            aRow[3]["margin"] := {0, nMarg, 0, 0}
            aRow[4]["margin"] := {0, nMarg, 0, 0}
            aRow[6]["margin"] := {0, nMarg, 0, 0}
            aRow[7]["margin"] := {0, nMarg, 0, 0}
            aRow[11]["margin"] := {0, nMarg, 0, 0}
        EndIf
        aRow[5]["alignment"] := "left"
        Aadd(oJson["content"][1]["table"]["body"], aRow)
    Next nX

Return oJson

/*/
{Protheus.doc} GetData()

    This method get data for table.

    @type Method
    @params
    @author dchizhov
    @since 15.06.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example aData := ::GetData()
/*/
Method GetData() Class RUHREFSP1S11SZVTDReport

    Local aData    As Array
    Local aRow     As Character
    Local cTemp    As Character
    Local cEtal    As Character
    Local cRFNP    As Character

    aData := {}
    cRFNP := ""
    cTemp := AllTrim(SubStr(SRA->RA_RFNP, 1, RAt(" ", SRA->RA_RFNP) - 1))
    cEtal := Chr(202) + Chr(209) // "KS"
    If cTemp == Chr(208) + cEtal .Or. cTemp == Chr(204) + cEtal // "R", "M"
        cRFNP := cTemp
    EndIf    
    If ::aParameters[1] <= SRA->RA_ADMISSA .And. SRA->RA_ADMISSA <= ::aParameters[2]
        aRow := Array(11)
        AFill(aRow, "")
        aRow[11] := 0
        aRow[1] := DToC(SRA->RA_ADMISSA)
        aRow[2] := Iif(SRA->RA_CATFUNC == "A", "9", Iif(SRA->RA_CATFUNC $ "MH", "1", ""))
        aRow[3] := cRFNP
        aRow := ::GetWork(aRow)
        Aadd(aData, aRow)
    EndIf

    aData := ::GetHistMoving(aData)

    If ::aParameters[1] <= SRA->RA_DEMISSA .And. SRA->RA_DEMISSA <= ::aParameters[2]
        aRow := Array(11)
        AFill(aRow, "")
        aRow[11] := 0
        aRow[1] := DToC(SRA->RA_DEMISSA)
        aRow[2] := Iif(SRA->RA_CATFUNC == "A", "10", Iif(SRA->RA_CATFUNC $ "MH", "5", ""))
        aRow[3] := cRFNP
        aRow := ::GetWork(aRow)
        cTemp := FDesc("SRG", SRA->RA_MAT + DToS(SRA->RA_DEMISSA), "RG_TIPORES",, xFilial("SRG"), RetOrdem("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)"))
        cTemp := Iif(Empty(cTemp), "", FDescRCC("S043", cTemp, 1, 2, 70, 20))
        aRow[6] := Iif(Empty(cTemp), "", cTemp)
        Aadd(aData, aRow)
    EndIf

Return aData

/*/
{Protheus.doc} GetWork(aRow)

    This method get data for 5 and 6 column.

    @type Method
    @params aRow, Array, Current data-row
    @author dchizhov
    @since 16.06.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example aRow := ::GetWork(aRow)
/*/
Method GetWork(aRow) Class RUHREFSP1S11SZVTDReport

    Local lMHEmpl  As Character
    Local aSQ3Area As Array
    Local cTemp    As Character
    Local nLenStr  As Numeric
    Local lSeek    As Logical
    Local cBrFil   As Character

    aSQ3Area := SQ3->(GetArea())
    nLenStr := 24
    lMHEmpl := SRA->RA_CATFUNC $ "MH"
    lSeek := .F.
    cBrFil := xFilial("SQ3")
    If !Empty(AllTrim(SRA->RA_CARGO)) .And. !Empty(AllTrim(SRA->RA_CC))
        cTemp := Iif(lMHEmpl, STR0067 + " " + AllTrim(DesCarCC()), "") // "Job title:"
        aRow[4] := cTemp
        aRow[11] += ::CalcLineCount(cTemp, nLenStr)
        DBSelectArea("SQ3")
        SQ3->(DBSetOrder(RetOrdem("SQ3", "Q3_FILIAL+Q3_CARGO+Q3_CC")))
        lSeek := SQ3->(DBSeek(cBrFil + SRA->RA_CARGO + SRA->RA_CC))
        If lSeek .Or. SQ3->(DBSeek(cBrFil + SRA->RA_CARGO))
            If lMHEmpl .And. !Empty(AllTrim(SQ3->Q3_RGWGRP + SQ3->Q3_CTGCD))
                cTemp := CRLF + STR0068 + " " + AllTrim(SQ3->Q3_RGWGRP) + "," + AllTrim(SQ3->Q3_CTGCD) // "category:
                aRow[4] += cTemp
                aRow[11] += ::CalcLineCount(SubStr(cTemp, 3), nLenStr)
            EndIf
            If "|" + aRow[2] + "|" $ "|1|2|5|9|10|"
                aRow[5] := Iif(lMHEmpl, SQ3->Q3_OKZ, STR0071) // "DHPC"
            EndIf
        EndIf
        If lMHEmpl
            cTemp := CRLF + STR0069 + " " + AllTrim(FDesc("SRJ", SRA->RA_CODFUNC, "RJ_DESC", TamSX3("RJ_DESC"), SRA->RA_FILIAL)) // "Labor function:"
            aRow[4] += cTemp
            aRow[11] += ::CalcLineCount(SubStr(cTemp, 3), nLenStr)
            cTemp := CRLF + STR0070 + " " + AllTrim(FDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC")) // "Structural subdivision:"
            aRow[4] += cTemp
            aRow[11] += ::CalcLineCount(AllTrim(FDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC")), nLenStr) + 1
        EndIf
        SQ3->(DBCloseArea())
    EndIf

    SQ3->(RestArea(aSQ3Area))

Return aRow

/*/
{Protheus.doc} CalcLineCount(cString, nLen)

    This method calculate count of lines in string.

    @type Method
    @params cString, Character, String witch calculated.
    @params nLen,    Numeric,   Lenght of line.
    @author dchizhov
    @since 21.06.2023
    @version 12.1.33
    @return nCount, Numeric, Count of lines.
    @example aRow[11] += ::CalcLineCount(cTemp, nLenStr)
/*/
Method CalcLineCount(cString, nLen) Class RUHREFSP1S11SZVTDReport

    Local nCount As Numeric
    Local cTemp  As Character
    Local cChar  As Character
    Local nI     As Numeric
    Local nIndex As Numeric
    Local nSize  As Numeric
    Local nCode  As Numeric
    Local nCutt  As Numeric

    nCount := 0
    nIndex := 0
    nI := 0
    nSize := 0
    cTemp := cString
    nCutt := RAt(" ", SubStr(cString, 1, nLen))
    nCutt := Iif(nCutt == 0, nLen, nCutt)
    For nIndex := 1 To Len(cTemp)
        cChar := SubStr(cTemp, nIndex, 1)
        If IsUpper(cChar) .Or. ((nCode := Asc(cChar)) <= 223 .And.  nCode >= 192) .Or. cChar == " "
            nI += 1
        EndIf
        If nIndex == nCutt
            nCutt := RAt(" ", SubStr(cString, nCutt + 1, nLen))
            If nCutt == 0
                nCutt := nLen
            Else
                nCutt := Iif(Len(cString) - nIndex > nLen, nCutt, Len(cString) - nIndex)
            EndIf
            nCutt += nIndex
            nSize := Max(nSize, nI)
            nI := 0
        EndIf
    Next nIndex

    // Magic rule derived from experiments
    If nSize > 9
        nSize := nLen - Int((nSize + 2) / 6) - 1
    ElseIf nI > 0
        nSize := nLen - Int(nSize / 5) - 1
    Else
        nSize := nLen
    EndIf

    nCount := MLCount(cString, nSize, , .T.)
    
Return nCount

/*/
{Protheus.doc} GetHistMoving(aData)

    This method get data from gpea180 (SRE) for report.

    @type Method
    @params aData, Array, Current data-array.
    @author dchizhov
    @since 20.06.2023
    @version 12.1.33
    @return aData, Array, Array of data.
    @example aData := ::GetHistMoving(aData)
/*/
Method GetHistMoving(aData) Class RUHREFSP1S11SZVTDReport

    Local aArea      As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object

    aArea := GetArea()
    cQuery := " SELECT SRE.RE_DATA FROM " + RetSqlName("SRE") + " SRE " 
    cQuery += " WHERE "
    cQuery += " SRE.RE_MATP = ? "
    cQuery += " AND SRE.RE_DATA BETWEEN ? AND ? "
    cQuery += " AND SRE.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, SRA->RA_MAT)
    oStatement:SetString(2, DToS(::aParameters[1]))
    oStatement:SetString(3, DToS(::aParameters[2]))

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        Aadd(aData, ::GetWork({SToD((cTab)->RE_DATA), "2", "", "", "", "", "", "", "", "", 0}))
        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DbCloseArea())
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aData

/*/
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author dchizhov
    @since 15.06.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oEFSObject:AddContent(oSubs1_1)
/*/
Method AddContent(oJson) Class RUHREFSP1S11SZVTDReport

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
