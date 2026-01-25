#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R14RUS.CH"

#DEFINE STR_PZIG "01"
#DEFINE STR_VZIG "03|04|05"
#DEFINE STR_VPIG "02"
#DEFINE STR_VKS  "09"

/*/
{Protheus.doc} RUHREFSP1S12A2Report

    Class for EFS report part 1 subsection 1.2 - SZV and 2 - ODV-1.

    @type Class
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
/*/
Class RUHREFSP1S12A2Report From LongNameClass

    Data aParameters       As Array     // Array of parameters.
    Data oGeneralJson      As Object    // Json for report.
    Data dDataIni          As Date
    Data dDataFin          As Date
    Data aPersSpecCond     As Array
    Data nCurrIndCond      As Numeric

    Method New(aParameters) Constructor

    Method SortByName(aDataSRA)
    Method AddContent(oJson)
    Method GetGeneralInfo(lPageBreak)

    // subsection 1.2
    Method GetSubs12()
    Method GetDatTab1()
    Method GetHistAbcense()
    Method CheckNorhCond(dDataIni, dDataFin)
    Method CheckSpecialityCond(dDataIni, dDataFin)
    Method CheckLongHoliday(aData, nK)
    Method CheckSRDPer(cPer)
    Method MergPeriods(aPer)

    // subsection 2
    Method GetSubs2(lPageBreak)  
    Method GetDatTab2()
    Method SeekSpecialCondCurrent()

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
    @example oEFSDSVObj := RUHREFSP1S12A2Report():New(aParam)
/*/
Method New(aParameters) Class RUHREFSP1S12A2Report

    Self:aParameters := AClone(aParameters)
    Self:aPersSpecCond := {}

    Self:oGeneralJson := JsonObject():New()
    Self:oGeneralJson["content"] := {}
    Self:nCurrIndCond := 0

Return Self

/*/
{Protheus.doc} GetGeneralInfo(lPageBreak)

    This method biuld part 1 subsection 1 for report (general information).

    @type Method
    @params lPageBreak, Logical, Page break befor or not.
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oEFSFSSObj:AddContent(oEFSFSSObj:GetGeneralInfo())
/*/
Method GetGeneralInfo(lPageBreak) Class RUHREFSP1S12A2Report

    Local oJson As Object
    Local cJson As Character
    Local cTemp As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "style": "title",
                "fontSize": 10
            },
            {
                "margin": [5, 9, 0, 0],
                "style": "title",
                "fontSize": 10
            },
            {
                "margin": [0, 9, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [35, 140, 90, 80, 120],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}, 
                            {"border": [false, false, false, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 0, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [90, 140],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 0, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [60, 5, 15, 5, 50, 2, 30, 10, 110, 40, 50, 10, 110, 30],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"}
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
    Else
        oJson["content"][1]["margin"][2] := 150
    EndIf
    oJson["content"][1]["text"] := STR0043 // "Section 1. Information on labor (other) activities, length of service, wages and additional insurance contributions to the funded pension"
    oJson["content"][2]["text"] := STR0044 // "Subsection 1. Information on labor (other) activities, insurance period, salary of a registered person (SP)"
    oJson["content"][3]["table"]["body"][ 1,  1]["text"] := STR0045 // "SNILS"
    cTemp := AllTrim(SRA->RA_CIC)
    oJson["content"][3]["table"]["body"][ 1,  2]["text"] := Iif(Empty(cTemp), "", Transform(SRA->RA_CIC, GetSX3Cache("RA_CIC", "X3_PICTURE")))
    oJson["content"][3]["table"]["body"][ 1,  4]["text"] := STR0046 // "TIN (if available)"
    oJson["content"][3]["table"]["body"][ 1,  5]["text"] := Iif(Empty(AllTrim(SRA->RA_PIS)), "", SRA->RA_PIS)
    oJson["content"][3]["table"]["body"][ 2,  1]["text"] := STR0047 // "Surname"
    oJson["content"][3]["table"]["body"][ 2,  2]["text"] := SRA->RA_PRISOBR
    oJson["content"][3]["table"]["body"][ 3,  1]["text"] := STR0048 // "Name"
    oJson["content"][3]["table"]["body"][ 3,  2]["text"] := SRA->RA_PRINOME
    oJson["content"][4]["table"]["body"][ 1,  1]["text"] := STR0049 // "Middle name (if any)"
    oJson["content"][4]["table"]["body"][ 1,  2]["text"] := SRA->RA_SECNOME
    oJson["content"][5]["table"]["body"][ 1,  1]["text"] := STR0050 // "Date of Birth"
    oJson["content"][5]["table"]["body"][ 1,  2]["text"] := STR0094 // "«"
    oJson["content"][5]["table"]["body"][ 1,  3]["text"] := Day(SRA->RA_NASC)
    oJson["content"][5]["table"]["body"][ 1,  4]["text"] := STR0095 // "»"
    oJson["content"][5]["table"]["body"][ 1,  5]["text"] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_NASC))
    oJson["content"][5]["table"]["body"][ 1,  7]["text"] := Year(SRA->RA_NASC)
    oJson["content"][5]["table"]["body"][ 1,  8]["text"] := STR0051 // "G."
    oJson["content"][5]["table"]["body"][ 1, 10]["text"] := STR0052 // "AP status"
    Do Case
        Case Empty(AllTrim(SRA->RA_CLASEST))
            cTemp := STR0097 // "GRF"
        Case SRA->RA_CLASEST $ STR_PZIG
            cTemp := STR0098 // "PZHIG"
        Case SRA->RA_CLASEST $ STR_VZIG
            cTemp := STR0099 // "VZHIG"
        Case SRA->RA_CLASEST $ STR_VPIG
            cTemp := STR0100 // "VPIG""
        Case SRA->RA_CLASEST $ STR_VKS
            cTemp := STR0101 // "VKS"
    Otherwise
        cTemp := "----"
    EndCase
    oJson["content"][5]["table"]["body"][ 1, 11]["text"] := cTemp
    oJson["content"][5]["table"]["body"][ 1, 13]["text"] := STR0053 // "Citizenship (country code)"
    oJson["content"][5]["table"]["body"][ 1, 14]["text"] := SRA->RA_NACIONC

Return oJson

/*/
{Protheus.doc} GetSubs12()

    This method biuld part 1 subsection 1.2 for report (insurance experience).

    @type Method
    @params 
    @author dchizhov
    @since 22.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oSubs12 := oEFSSZVObj:GetSubs12()
/*/
Method GetSubs12() Class RUHREFSP1S12A2Report

    Local oJson As Object
    Local aRow  As Array
    Local cJson As Character
    Local nX    As Numeric
    Local nY    As Numeric
    Local aData As Array

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 15, 0, 0],
                "style": "normal9",
                "bold": true
            },
            {
                "margin": [0, 9, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [80, 40, 20],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "bold": true}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 9, 0, 0],
                "style": "normal",
                "table": {
                    "width": "100%",
                    "widths": [80, 40, 10, 5, 75, 10, 5, 70, 10, 5, 60, 10, 15, 160, 40, 20],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "bold": true}, {"border": [false, false, false, false], "text": ""},
                            {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, 
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, 
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 9, 0, 0],
                "style": "normal",
                "alignment": "center",
                "fontSize": 7,
                "table": {
                    "width": "100%",
                    "widths": [10, 50, 50, 50, 50, 70, 70, 60, 60, 50, 80, 80],
                    "body": [ 
                        [
                            {"rowSpan": 2, "margin": [0, 6, 0, 0]}, {"colSpan": 2}, {}, 
                            {"colSpan": 2}, {}, {"colSpan": 2}, {},
                            {"colSpan": 3}, {}, {}, {"colSpan": 2}, {}
                        ],
                        [
                            {}, {"margin": [0, 3, 0, 0]}, {"margin": [0, 3, 0, 0]}, {"margin": [0, 3, 0, 0]}, 
                            {}, {"margin": [0, 3, 0, 0]}, {}, {}, 
                            {"margin": [0, 3, 0, 0]}, {"margin": [0, 3, 0, 0]}, {}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {},
                            {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["text"] := STR0054 // "Subsection 1.2. Information about the insurance experience"
    oJson["content"][2]["table"]["body"][ 1,  1]["text"] := STR0055 // "Reporting period:"
    oJson["content"][2]["table"]["body"][ 1,  2]["text"] := ::aParameters[1]
    oJson["content"][2]["table"]["body"][ 1,  3]["text"] := STR0056 // "year"
    oJson["content"][3]["table"]["body"][ 1,  1]["text"] := STR0057 // "Information type:"
    oJson["content"][3]["table"]["body"][ 1,  2]["text"] := STR0058 // "Initial"
    oJson["content"][3]["table"]["body"][ 1,  5]["text"] := STR0059 // "Appointment of a pension"
    oJson["content"][3]["table"]["body"][ 1,  8]["text"] := STR0060 // "Corrective"
    oJson["content"][3]["table"]["body"][ 1, 11]["text"] := STR0061 // "canceling"
    oJson["content"][3]["table"]["body"][ 1, 14]["text"] := STR0062 // "Adjustable (cancellable) period"
    oJson["content"][3]["table"]["body"][ 1, 15]["text"] := Iif(::aParameters[2] > 2, ::aParameters[3], "")
    oJson["content"][3]["table"]["body"][ 1, 16]["text"] := STR0063 // "year"

    oJson["content"][3]["table"]["body"][ 1,  3 * ::aParameters[2]]["text"] := "X"

    oJson["content"][4]["table"]["body"][ 1,  1]["text"] := STR0064 // "No. p / p"
    oJson["content"][4]["table"]["body"][ 1,  2]["text"] := STR0065 // "Work period"
    oJson["content"][4]["table"]["body"][ 1,  4]["text"] := STR0066 // "Territorial conditions"
    oJson["content"][4]["table"]["body"][ 1,  6]["text"] := STR0067 // "Features of calculating the insurance period"
    oJson["content"][4]["table"]["body"][ 1,  8]["text"] := STR0068 // "Conditions for the early appointment of an insurance pension"
    oJson["content"][4]["table"]["body"][ 1, 11]["text"] := STR0069 // "The result of a special assessment of working conditions"
    oJson["content"][4]["table"]["body"][ 2,  2]["text"] := STR0070 // "with dd.mm.yyyy"
    oJson["content"][4]["table"]["body"][ 2,  3]["text"] := STR0071 // "by dd.mm.yyyy"
    oJson["content"][4]["table"]["body"][ 2,  4]["text"] := STR0072 // "Code"
    oJson["content"][4]["table"]["body"][ 2,  5]["text"] := STR0073 // "District coefficient"
    oJson["content"][4]["table"]["body"][ 2,  6]["text"] := STR0074 // "Base (code)"
    oJson["content"][4]["table"]["body"][ 2,  7]["text"] := STR0075 // "additional information"
    oJson["content"][4]["table"]["body"][ 2,  8]["text"] := STR0076 // "Special working conditions (code)"
    oJson["content"][4]["table"]["body"][ 2,  9]["text"] := STR0077 // "Base (code)"
    oJson["content"][4]["table"]["body"][ 2, 10]["text"] := STR0078 // "Employment"
    oJson["content"][4]["table"]["body"][ 2, 11]["text"] := STR0079 // "Individual workplace number"
    oJson["content"][4]["table"]["body"][ 2, 12]["text"] := STR0080 // "Class (subclass) of working conditions"
    For nX := 1 To 12
        oJson["content"][4]["table"]["body"][ 3,  nX]["text"] := CValToChar(nX)
    Next nX

    aData := ::GetDatTab1()

    For nX := 1 To Len(aData)
        aRow := Array(12)
        For nY := 1 To Len(aRow)
            aRow[nY] := JsonObject():New()
        Next nY

        aRow[1]["text"] := CValToChar(nX)
        For nY := 1 To Len(aData[nX])
            aRow[1 + nY]["text"] := aData[nX, nY]
        Next nY
        Aadd(oJson["content"][4]["table"]["body"], aRow)
    Next nX

Return oJson

/*/
{Protheus.doc} GetDatTab1()

    This method get data for table in subsection 1.2.

    @type Method
    @params 
    @author dchizhov
    @since 24.05.2023
    @version 12.1.33
    @return aDataTable, Array, Array with data.
    @example aData := ::GetDatTab1()
/*/
Method GetDatTab1() Class RUHREFSP1S12A2Report

    Local aDataTable As Array
    Local xTempStr   As Character
    Local aTemp      As Array
    Local aSpecCond  As Array
    
    aDataTable := {}
    aSpecCond := {}
    Aadd(aDataTable, {Max(SRA->RA_ADMISSA, SToD(::aParameters[1] + "0101"))})
    xTempStr := IiF(Empty(SRA->RA_DEMISSA) .Or. SRA->RA_DEMISSA < aDataTable[1, 1], Date() + 366, SRA->RA_DEMISSA)
    If ::aParameters[2] == 2
        Aadd(aDataTable[1], Min(xTempStr, ::aParameters[4] - 1))
    Else
        Aadd(aDataTable[1], Min(xTempStr, SToD(::aParameters[1] + "1231")))
    EndIf
    aTemp := ::CheckNorhCond(aDataTable[1, 1], aDataTable[1, 2])
    Aadd(aDataTable[1], aTemp[1])
    Aadd(aDataTable[1], aTemp[2])
    Aadd(aDataTable[1], "")
    Aadd(aDataTable[1], "")
    Aadd(aDataTable[1], Iif(SRA->RA_CATFUNC == "A", "", ::CheckSpecialityCond(aDataTable[1, 1], aDataTable[1, 2])[1]))
    Aadd(aDataTable[1], "")
    Aadd(aDataTable[1], "")
    Aadd(aDataTable[1], "")
    Aadd(aDataTable[1], "")

    ::dDataIni := aDataTable[1, 1]
    ::dDataFin := aDataTable[1, 2]

    If ::aParameters[2] <> 2 .And. Empty(aDataTable[1, 3]) .And. Empty(aDataTable[1, 4]) .And. Empty(aDataTable[1, 7])
        aDataTable := {}
    EndIf
    aTemp := ::GetHistAbcense()

    AEval(aTemp, {|X| Iif(Len(X) > 0, Aadd(aDataTable, X), )})

    AEval(aDataTable, {|X| Iif(Len(AllTrim(X[7])) > 0, Aadd(aSpecCond, {X[1], X[2], X[7]}), Nil), X[1] := DToC(X[1]), X[2] := DToC(X[2])})
    If Len(aSpecCond) > 0
        Aadd(::aPersSpecCond, {SRA->RA_MAT, aSpecCond})
    EndIf

Return aDataTable

/*/
{Protheus.doc} GetHistAbcense()

    This method get history of abcense for table in subsection 1.2.

    @type Method
    @params 
    @author dchizhov
    @since 25.05.2023
    @version 12.1.33
    @return aDataTable, Array, Array with data.
    @example aTemp := ::GetHistAbcense()
/*/
Method GetHistAbcense() Class RUHREFSP1S12A2Report

    Local aDataTable As Array
    Local aData      As Array
    Local aAbcenseT1 As Array
    Local cQuery     As Character
    Local cTab       As Character
    Local dStartDate As Date
    Local dFinDate   As Date
    Local oStatement As Object
    Local nX         As Numeric
    Local nK         As Numeric
    Local cState     As Character
    Local aArea      As Array

    aArea := GetArea()
    If SRA->RA_CATFUNC == "A"
      
        cQuery := " SELECT RCH.RCH_PER, RCH.RCH_DTINI, RCH.RCH_DTFIM, RCH.RCH_ROTEIR, RCH.RCH_PROCES FROM " + RetSqlName("RCH") + " RCH " 
        cQuery += " WHERE "
        cQuery += " RCH.RCH_DTINI <= ? "
        cQuery += " AND RCH.RCH_DTFIM >= ? "
        cQuery += " AND RCH.RCH_ROTEIR = 'FOL' "
        cQuery += " AND RCH.D_E_L_E_T_ = '' "
        cQuery += " ORDER BY RCH_DTINI, RCH_DTFIM "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, DToS(::dDataFin))
        oStatement:SetString(2, DToS(::dDataIni))

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())
        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        aData := {}
        While !(cTab)->(EOF())
            dStartDate := SToD((cTab)->RCH_DTINI)
            dFinDate := SToD((cTab)->RCH_DTFIM)
            Aadd(aData, {AllTrim((cTab)->RCH_PER), Max(dStartDate, ::dDataini), Min(dFinDate, ::dDataFin), (cTab)->RCH_ROTEIR, (cTab)->RCH_PROCES})
            (cTab)->(DBSkip())
        EndDo

        (cTab)->(DbCloseArea())
        aDataTable := {}
        nK := 0
        aData := ::MergPeriods(aData)
        For nX := 1 To Len(aData)
            cState := Iif(aData[nX, 3], STR0110, STR0111) // "???????", "????????"
            Aadd(aData[nX], ::CheckNorhCond(aData[nX, 1], aData[nX, 2]))
            Aadd(aDataTable, {aData[nX, 1], aData[nX, 2], "", "", "", cState, "", "", "", "", ""})
            nK += 1
            If "|" + aData[nX, 4, 1] + "|" $ STR0108 .Or. ("|" + aData[nX, 4, 1] + "|" $ STR0106 .And. "|" + cState + "|" $ STR0107) // "|???|???|????|????|???-????|?31|?33|?34|?35|?36|", "|????|", "|????|????????|???????|"
                aDataTable[nK, 3] := aData[nX, 4, 1]
                aDataTable[nK, 4] := aData[nX, 4, 2]
            EndIf
        Next nX
    Else
        aAbcenseT1 := StrTokArr(STR0102, "|") // "|????|??????|???????|????????|????????|?????|?????|?????|????????|????????|??????|??????|???????|???????|????????|?????????|????????|????????|??????|????|???|????|???|???|??????|????|?????|???????|??????|"
        
        cQuery := " SELECT RCM.RCM_CODHOM, SR8.R8_DATAINI, SR8.R8_DATAFIM FROM " + RetSqlName("SR8") + " SR8 "
        cQuery += " INNER JOIN " + RetSqlName("RCM") + " RCM ON RCM.RCM_TIPO = SR8.R8_TIPOAFA "
        cQuery += " WHERE SR8.R8_MAT = ? "
        cQuery += " AND RCM.RCM_CODHOM in (?) "
        cQuery += " AND SR8.R8_DATAINI <= ? "
        cQuery += " AND SR8.R8_DATAFIM >= ? "
        cQuery += " AND RCM.D_E_L_E_T_ = '' "
        cQuery += " AND SR8.D_E_L_E_T_ = '' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, SRA->RA_MAT)
        oStatement:SetIn(2, aAbcenseT1)
        oStatement:SetString(3, DToS(::dDataFin))
        oStatement:SetString(4, DToS(::dDataIni))

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())
        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        aDataTable := {}
        While !(cTab)->(EOF())
            dStartDate := SToD((cTab)->R8_DATAINI)
            dFinDate := SToD((cTab)->R8_DATAFIM)
            Aadd(aDataTable, {Max(dStartDate, ::dDataini), Min(dFinDate, ::dDataFin), AllTrim((cTab)->RCM_CODHOM), "", "", (cTab)->RCM_CODHOM, "", "", "", "", ""})
            (cTab)->(DBSkip())
        EndDo
        
        (cTab)->(DbCloseArea())
        ASort(aDataTable, , , {|X, Y| X[1] < Y[1] .Or. (X[1] == Y[1] .And. X[2] > Y[2])})

        For nX := 1 To Len(aDataTable)
            If aDataTable[nX, 3] <> STR0104 .Or. ::CheckLongHoliday(aDataTable, nX) // "????????"
                aDataTable[nX, 4] := ::CheckNorhCond(aDataTable[nX, 1], aDataTable[nX, 2])
                If "|" + aDataTable[nX, 3] + "|" $ STR0105 .And. !("|" + aDataTable[nX, 3] + "|" $ STR0107 .And. "|" + aDataTable[nX, 4, 1] + "|" $ STR0106) // "|????|?????|????????|??????|??????|???????|???????|????????|??????|???????|????|??????|?????|??????|", "|????|????????|???????|", "|????|"
                    aDataTable[nX, 3] := ""
                    aDataTable[nX, 4] := ""
                Else
                    aDataTable[nX, 3] := aDataTable[nX, 4, 1]
                    aDataTable[nX, 4] := aDataTable[nX, 4, 2]
                    aDataTable[nX, 7] := ::CheckSpecialityCond(aDataTable[nX, 1], aDataTable[nX, 2])[1]
                EndIf
            Else
                aDataTable[nX] := {}
            EndIf
        Next nX
    EndIf
    RestArea(aArea)

Return aDataTable

/*/
{Protheus.doc} CheckNorhCond(dDataIni, dDataFin)

    This method get North condition for current employee by some period (now in current time because not history).

    @type Method
    @params dDataIni, Date, Start of checking period.
    @params dDataFin, Date, End of checking period.
    @author dchizhov
    @since 25.05.2023
    @version 12.1.33
    @return aData, Array, Array with data.
    @example aTemp := ::CheckNorhCond(aDataTable[1, 1], aDataTable[1, 2])
/*/
Method CheckNorhCond(dDataIni, dDataFin) Class RUHREFSP1S12A2Report

    Local aData As Array

    aData := {AllTrim(SRA->RA_RFNP), ""}
    aData[1] := SubStr(aData[1], 1, RAt(" ", aData[1]) - 1)
    If !Empty(aData[1])
        aData[2] := CValToChar(Val(FDescRcc("S207", aData[1], 1, 10, 11, 6))) + "%"
    EndIf

Return aData

/*/
{Protheus.doc} CheckSpecialityCond(dDataIni, dDataFin)

    This method get specialy condition for current employee by some period (now in current time because not history).

    @type Method
    @params dDataIni, Date, Start of checking period.
    @params dDataFin, Date, End of checking period.
    @author dchizhov
    @since 25.05.2023
    @version 12.1.33
    @return aData, Array, Array with data.
    @example aDataTable[nX, 7] := ::CheckSpecialityCond(aDataTable[nX, 1], aDataTable[nX, 2])[1]
/*/
Method CheckSpecialityCond(dDataIni, dDataFin) Class RUHREFSP1S12A2Report

    Local aData As Array

    aData := {AllTrim(SRA->RA_CODCBO)}

Return aData

/*/
{Protheus.doc} CheckLongHoliday(aData, nK)

    This method check need element for long holiday.

    @type Method
    @params aData, Array,   Array with all abcwnce in period.
    @params nK,    Numeric, Checking element long holiday.
    @author dchizhov
    @since 25.05.2023
    @version 12.1.33
    @return lResult, Logical, need write this long holiday.
    @example If aDataTable[nX, 3] == STR0104 .And. CheckLongHoliday(aDataTable, nX) // "????????"
/*/
Method CheckLongHoliday(aData, nK) Class RUHREFSP1S12A2Report

    Local lResult As Array
    Local nIndex  As Numeric
    Local dStart  As Date
    Local dFinish As Date

    dStart := aData[nK, 1]
    dFinish := aData[nK, 2]

    nIndex := AScan(aData, {|X| Len(X) > 0 .And. X[1] <= dStart .And. X[2] >= dFinish .And. "|" + AllTrim(X[6]) + "|" $ STR0103}) // "|????|???|????|???|???|"

    lResult := nIndex > 0

Return lResult

/*/
{Protheus.doc} CheckSRDPer(cPer, cRot, cProc)

    This method check exist record in srd by per for current employee.

    @type Method
    @params cPer,  Character, Period.
    @params cRot,  Character, Roteir.
    @params cProc, Character, Process.
    @author dchizhov
    @since 26.05.2023
    @version 12.1.33
    @return lResult, Logical, Exist record in SRD.
    @example AEval(aTempPer, {|X| X[4] := ::CheckSRDPer(X[1], X[5], X[6])})
/*/
Method CheckSRDPer(cPer, cRot, cProc) Class RUHREFSP1S12A2Report

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object
    Local lResult    As Logical
    Local aArea      As Array

    DEFAULT cRot := Nil
    DEFAULT cProc := Nil

    aArea := GetArea()

    lResult := .F.
      
    cQuery := " SELECT SUM(RD_VALOR) AS VALOR FROM " + RetSqlName("SRD") + " SRD " 
    cQuery += " WHERE "
    cQuery += " SRD.RD_MAT = ? "
    cQuery += " AND SRD.RD_PERIODO = ? "
    cQuery += Iif(cRot == Nil, "", " AND SRD.RD_ROTEIR = '" + cRot + "' ")
    cQuery += Iif(cProc == Nil, "", " AND SRD.RD_PROCES = '" + cProc + "' ")
    cQuery += " AND SRD.D_E_L_E_T_ = '' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, SRA->RA_MAT)
    oStatement:SetString(2, cPer)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        If (cTab)->VALOR > 0
            lResult := .T.
        EndIf
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DbCloseArea())    
    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} MergPeriods(aPer)

    This method check periods and merges adjacent periods.

    @type Method
    @params ?Per, Array, Periods.
    @author dchizhov
    @since 29.05.2023
    @version 12.1.33
    @return aPeriods, Array, Results array.
    @example aData := ::MergPeriods(aData)
/*/
Method MergPeriods(aPer) Class RUHREFSP1S12A2Report

    Local aPeriods As Array
    Local aTempPer As Array
    Local dStart   As Date
    Local dFinish  As Date
    Local nX       As Numeric
    Local nCur     As Numeric

    aPeriods := {}
    aTempPer := {}
    If Len(aPer) > 0
        dStart := aPer[1, 2]
        dFinish := aPer[1, 3]

        For nX := 1 To Len(aPer)
            If AScan(aTempPer, {|X| X[1] == aPer[nX, 1] .And. X[2] == aPer[nX, 2] .And. X[3] == aPer[nX, 3] .And. X[5] == aPer[nX, 4] .And. X[6] == aPer[nX, 5]}) < 1
                Aadd(aTempPer, {aPer[nX, 1], aPer[nX, 2], aPer[nX, 3], .F., aPer[nX, 4], aPer[nX, 5]})
            EndIf
            dStart := Min(dStart, aPer[nX, 2])
            dFinish := Max(dFinish, aPer[nX, 3])
        Next nX
        AEval(aTempPer, {|X| X[4] := ::CheckSRDPer(X[1], X[5], X[6])})
        ASort(aTempPer, , , {|X, Y| X[2] < Y[2] .Or. (X[2] == Y[2] .And. X[3] < Y[3])})
        For nX := 1 To Len(aTempPer)
            If aTempPer[nX, 4]
                nCur := Len(aPeriods)
                If nCur == 0
                    Aadd(aPeriods, {aTempPer[nX, 2], aTempPer[nX, 3], .T.})
                Else
                    If aPeriods[nCur, 1] <= aTempPer[nX, 2] .And. aTempPer[nX, 2] <= aPeriods[nCur, 2] + 1
                        aPeriods[nCur, 2] := aTempPer[nX, 3]
                    Else
                        Aadd(aPeriods, {aTempPer[nX, 2], aTempPer[nX, 3], .T.})
                    EndIf
                EndIf
            EndIf
        Next nX
        aTempPer := aPeriods
        aPeriods := {}
        If Len(aTempPer) > 0
            If aTempPer[1, 1] > dStart
                Aadd(aPeriods, {dStart, aTempPer[1, 1], .F.})
            EndIf
            Aadd(aPeriods, {aTempPer[1, 1], aTempPer[1, 2], .T.})
            For nX := 2 To Len(aTempPer)
                Aadd(aPeriods, {aTempPer[nX - 1, 2], aTempPer[nX, 1], .F.})
                Aadd(aPeriods, {aTempPer[nX, 1], aTempPer[nX, 2], .T.})
            Next nX
            If aTempPer[Len(aTempPer), 2] < dFinish
                Aadd(aPeriods, {aTempPer[Len(aTempPer), 2], dFinish, .F.})
            EndIf
        Else
            Aadd(aPeriods, {dStart, dFinish, .F.})
        EndIf
    EndIf

Return aPeriods

/*/
{Protheus.doc} GetSubs2(lPageBreak)

    This method biuld part 1 subsection 2 for report (general information).

    @type Method
    @params lPageBreak, Logical, Page break befor or not.
    @author dchizhov
    @since 30.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oSubs2 := oEFSSZVObj:GetSubs2(.F.)
/*/
Method GetSubs2(lPageBreak) Class RUHREFSP1S12A2Report

    Local oJson As Object
    Local cJson As Character
    Local aData As Array
    Local aRow  As Array
    Local nX    As Numeric
    Local nY    As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [5, 18, 0, 0],
                "style": "title",
                "fontSize": 10
            },
            {
                "margin": [25, 9, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [90, 40, 30],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "bold": true, "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [25, 9, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [80, 45, 10, 25, 75, 10, 25, 60, 10, 15, 180, 40, 20],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "bold": true}, {"border": [false, false, false, false], "text": ""},
                            {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}, {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}, 
                            {"border": [true, true, true, true], "text": "", "alignment": "center", "margin": [0, 1, 0, 0]}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": "", "bold": true}, {"border": [false, false, false, true], "text": "", "alignment": "center"}, 
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 9, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [15, 100, 100, 80, 80, 100, 100, 90, 90],
                    "body": [ 
                        [
                            {"margin": [0, 12, 0, 0]}, {"margin": [0, 4, 0, 0]}, {"margin": [0, 9, 0, 0]}, {"margin": [0, 9, 0, 0]}, {"margin": [0, 9, 0, 0]}, 
                            {"margin": [0, 4, 0, 0]}, {}, {"margin": [0, 9, 0, 0]}, {"margin": [0, 9, 0, 0]}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}, {}, {}, {}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 18, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [275, 70],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 18, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [260, 70],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}
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
    Else
        oJson["content"][1]["margin"][2] := 10
    EndIf
    oJson["content"][1]["text"] := STR0082 // "Subsection 2. The basis for reflecting data on the periods of work of the insured person in conditions giving the right to early appointment of a pension in accordance with part 1 of article 30 and article 31 of the Federal Law of December 28, 2013 No. 400-FZ «On insurance pensions»"
    oJson["content"][2]["table"]["body"][ 1,  1]["text"] := STR0112 // "Reporting period:"
    oJson["content"][2]["table"]["body"][ 1,  2]["text"] := ::aParameters[1]
    oJson["content"][2]["table"]["body"][ 1,  3]["text"] := STR0113 // "year"
    oJson["content"][3]["table"]["body"][ 1,  1]["text"] := STR0114 // "Information type:"
    oJson["content"][3]["table"]["body"][ 1,  2]["text"] := STR0115 // "Initial"
    oJson["content"][3]["table"]["body"][ 1,  5]["text"] := STR0116 // "Corrective"
    oJson["content"][3]["table"]["body"][ 1,  8]["text"] := STR0117 // "canceling"
    oJson["content"][3]["table"]["body"][ 1, 11]["text"] := STR0118 // "Adjustable (cancellable) period"
    oJson["content"][3]["table"]["body"][ 1, 12]["text"] := Iif(::aParameters[2] > 2, ::aParameters[3], "")
    oJson["content"][3]["table"]["body"][ 1, 13]["text"] := STR0119 // "year"
    If ::aParameters[2] == 1
        oJson["content"][3]["table"]["body"][ 1,  3]["text"] := "X"
    ElseIf ::aParameters[2] == 3
        oJson["content"][3]["table"]["body"][ 1,  6]["text"] := "X"
    Else
        oJson["content"][3]["table"]["body"][ 1,  9]["text"] := "X"
    EndIf
    oJson["content"][4]["table"]["body"][ 1, 1]["text"] := STR0120 // "No. p / p"
    oJson["content"][4]["table"]["body"][ 1, 2]["text"] := STR0084 // "Name of the structural unit according to the staffing table"
    oJson["content"][4]["table"]["body"][ 1, 3]["text"] := STR0085 // "Name of the profession (position) according to the staffing table"
    oJson["content"][4]["table"]["body"][ 1, 4]["text"] := STR0086 // "Number of staff positions"
    oJson["content"][4]["table"]["body"][ 1, 5]["text"] := STR0087 // "Number of actually employed"
    oJson["content"][4]["table"]["body"][ 1, 6]["text"] := STR0088 // "The nature of the actual work performed and additional working conditions"
    oJson["content"][4]["table"]["body"][ 1, 7]["text"] := STR0089 // "Name of primary documents confirming employment in special working conditions"
    oJson["content"][4]["table"]["body"][ 1, 8]["text"] := STR0090 // "Code of special working conditions / length of service according to the Classifier"
    oJson["content"][4]["table"]["body"][ 1, 9]["text"] := STR0091 // "Item code of Lists No. 1 and 2, «small» list"
    For nX := 1 To 9
        oJson["content"][4]["table"]["body"][ 2, nX]["text"] := CValToChar(nX)
    Next nX
    aData := ::GetDatTab2()
    For nX := 1 To Len(aData)
        aRow := Array(9)
        For nY := 1 To Len(aRow)
            aRow[nY] := JsonObject():New()
        Next nY

        aRow[1]["text"] := CValToChar(nX)
        For nY := 1 To Len(aData[nX])
            aRow[1 + nY]["text"] := aData[nX, nY]
        Next nY
        Aadd(oJson["content"][4]["table"]["body"], aRow)
    Next nX
    oJson["content"][5]["table"]["body"][ 1, 1]["text"] := STR0092 // "Total number of jobs in special working conditions by state"
    oJson["content"][6]["table"]["body"][ 1, 1]["text"] := STR0093 // "Number of people actually working in special working conditions"

Return oJson

/*/
{Protheus.doc} GetDatTab2()

    This method get data for table in subsection 2.
    This method requires subsection 1.2 to be built earlier in this instance of the class

    @type Method
    @params 
    @author dchizhov
    @since 31.05.2023
    @version 12.1.33
    @return aDataTable, Array, Array with data.
    @example aData := ::GetDatTab2()
/*/
Method GetDatTab2() Class RUHREFSP1S12A2Report

    Local aDataTable As Array
    Local nIndData   As Numeric
    Local aArea      As Array
    Local aRCLArea   As Array

    aDataTable := {}
    aArea := GetArea()
    aRCLArea := RCL->(GetArea())
    nIndData := AScan(::aPersSpecCond, {|X|})
    DbSelectArea("RCL")
    RCL->(DbSetOrder(RetOrdem("RCL", "RCL_FILIAL+RCL_POSTO")))
    If RCL->(DbSeek(SRA->RA_FILIAL + SRA->RA_POSTO))
        AAdd(aDataTable, Array(8))
        AFill(aDataTable[1], "")
        aDataTable[1, 1] := RCLDDeptoIni()
        aDataTable[1, 2] := RCLDCargIni()
        aDataTable[1, 3] := CValToChar(RCL->RCL_NPOSTO)
        aDataTable[1, 4] := CValToChar(RCL->RCL_OPOSTO)
        aDataTable[1, 7] := ::aPersSpecCond[::nCurrIndCond, 2, 1, 3]
    EndIf

    RCL->(RestArea(aRCLArea))
    RestArea(aArea)

Return aDataTable

/*/
{Protheus.doc} SeekSpecialCondCurrent()

    This method get index special cond person in array.

    @type Method
    @params 
    @author dchizhov
    @since 01.06.2023
    @version 12.1.33
    @return nIndex, Numeric, Index in array.
    @example If aParam[2] <> 2 .And. oEFSSZVObj:SeekSpecialCondCurrent() > 0
/*/
Method SeekSpecialCondCurrent() Class RUHREFSP1S12A2Report

    Local nIndex As Numeric

    nIndex := 0
    nIndex := AScan(::aPersSpecCond, {|X| X[1] == SRA->RA_MAT})
    ::nCurrIndCond := nIndex

Return nIndex

/*/
{Protheus.doc} AddContent(oJson)

    This method sorted array of TN by name of employee.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author dchizhov
    @since 13.06.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oEFSSZVObj:AddContent(oSubs12)
/*/
Method SortByName(aDataSRA) Class RUHREFSP1S12A2Report

    Local cQuery     As Character
    Local cTab       As Character
    Local oStatement As Object
    Local aResult    As Array
    Local aEmployee  As Array
    Local aArea      As Array

    DEFAULT cRot := Nil
    DEFAULT cProc := Nil

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
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oEFSSZVObj:AddContent(oSubs12)
/*/
Method AddContent(oJson) Class RUHREFSP1S12A2Report

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
