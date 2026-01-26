#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R13RUS.CH"

#DEFINE ID_TIPOAFA_FOR_CALC "'0150'"

/*/
{Protheus.doc} RUHREFSP1S3DSV3Report

    Class for EFS report part 1 subsection 3 - DSV-3.

    @type Class
    @author dchizhov
    @since 16.05.2023
    @version 12.1.33
/*/
Class RUHREFSP1S3DSV3Report From LongNameClass

    Data aParameters            As Array     // Array of parameters.

    Data aPersonnelNumbers      As Array     // Array of personel numbers.
    Data oGeneralJson           As Object    // Json for report.

    Method New(aParameters, aPersonnelNumbers) Constructor

    Method AddContent(oJson)
    Method GetGeneralInfo()
    Method GetTable()
    Method GetDataForTable()

EndClass

/*/
{Protheus.doc} New(aParameters, aPersonnelNumbers)

    Default constructor.

    @type Method
    @params aParameters,       Array, Array of parameters from pergunte.
    @params aPersonnelNumbers, Array, Array of TN of emplyees.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return RUHREFSP1S3DSV3Report, Object, RUHREFSP1S3DSV3Report instance.
    @example oEFSDSVObj := RUHREFSP1S3DSV3Report():New(aParam, oEFSObject:aPersonnelNumbers)
/*/
Method New(aParameters, aPersonnelNumbers) Class RUHREFSP1S3DSV3Report

    Self:aParameters := AClone(aParameters)
    Self:aPersonnelNumbers := AClone(aPersonnelNumbers)

    Self:oGeneralJson := JsonObject():New()
    Self:oGeneralJson["content"] := {}

Return Self

/*/
{Protheus.doc} GetGeneralInfo()

    This method biuld part 1 subsection 3 for report (general information).

    @type Method
    @params 
    @author dchizhov
    @since 16.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oEFSFSSObj:AddContent(oEFSFSSObj:GetGeneralInfo())
/*/
Method GetGeneralInfo() Class RUHREFSP1S3DSV3Report

    Local oJson As Object
    Local cJson As Character
    Local cTemp As Character
    Local nMarg As Numeric

    oJson := JsonObject():New()

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
                "margin": [0, 20, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [110, 70, 20, 15, 5, 100, 15, 15, 10, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 30, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [170, 5, 15, 5, 100, 15, 15, 10, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, true], "text": "", "alignment": "center"}, {"border": [false, false, false, false], "text": ""},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 30, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [70, 100, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"},
                            {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    cTemp := CValToChar(Year(::aParameters[2]))
    nMarg := Len(::aParameters[1])
    If nMarg > 13
        oJson["content"][2]["table"]["widths"][2] := "auto"
        If nMarg > 90
            nMarg := Int((nMarg + 1) / 90) * 10
            oJson["content"][2]["table"]["widths"][2] := 452
            oJson["content"][2]["table"]["body"][1, 1]["margin"] := {0, nMarg, 0, 0}
            AEval(oJson["content"][2]["table"]["body"][1], {|X| X["margin"] := {0, nMarg, 0, 0}}, 3)
        EndIf
    EndIf
    oJson["content"][1]["text"] := CRLF + CRLF + STR0043 + CRLF + STR0044 // "Subsection 3. Information about the insured persons for whom additional insurance premiums for the funded pension are listed and paid", "employer contributions"
    oJson["content"][2]["table"]["body"][ 1, 1]["text"] := STR0045 // "Payment order No."
    oJson["content"][2]["table"]["body"][ 1, 2]["text"] := ::aParameters[1]
    oJson["content"][2]["table"]["body"][ 1, 3]["text"] := STR0046 + " " + STR0075 // "from", """
    oJson["content"][2]["table"]["body"][ 1, 4]["text"] := Day(::aParameters[2])
    oJson["content"][2]["table"]["body"][ 1, 5]["text"] := STR0076 // """
    oJson["content"][2]["table"]["body"][ 1, 6]["text"] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(::aParameters[2]))
    oJson["content"][2]["table"]["body"][ 1, 7]["text"] := STR0048 // "20"
    oJson["content"][2]["table"]["body"][ 1, 8]["text"] := SubStr(cTemp, 3, Len(cTemp) - 2) 
    oJson["content"][2]["table"]["body"][ 1, 9]["text"] := STR0049 // "y."
    cTemp := CValToChar(Year(::aParameters[3]))
    oJson["content"][3]["table"]["body"][ 1, 1]["text"] := STR0050 // "Date of execution of the payment order"
    oJson["content"][3]["table"]["body"][ 1, 2]["text"] := STR0075 // """ 
    oJson["content"][3]["table"]["body"][ 1, 3]["text"] := Day(::aParameters[3])
    oJson["content"][3]["table"]["body"][ 1, 4]["text"] := STR0076 // """
    oJson["content"][3]["table"]["body"][ 1, 5]["text"] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(::aParameters[3]))
    oJson["content"][3]["table"]["body"][ 1, 6]["text"] := STR0048 // "20"
    oJson["content"][3]["table"]["body"][ 1, 7]["text"] := SubStr(cTemp, 3, Len(cTemp) - 2) 
    oJson["content"][3]["table"]["body"][ 1, 8]["text"] := STR0049 // "y."
    oJson["content"][4]["table"]["body"][ 1, 1]["text"] := STR0051 // "Payment period"
    oJson["content"][4]["table"]["body"][ 1, 2]["text"] := ::aParameters[4]

Return oJson

/*/
{Protheus.doc} GetTable()

    This method biuld table for part 1 subsection 3 for report.

    @type Method
    @params 
    @author dchizhov
    @since 16.05.2023
    @version 12.1.33
    @return oJson, Object, Json with general info for report.
    @example oEFSDSVObj:AddContent(oEFSDSVObj:GetTable())
/*/
Method GetTable() Class RUHREFSP1S3DSV3Report

    Local oJson As Object
    Local cJson As Character
    Local aRow  As Array
    Local aData As Array
    Local oTemp As Object
    Local nTot  As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content": [
            {
                "margin": [0, 30, 0, 0],
                "style": "normal9",
                "alignment": "center",
                "table": {
                    "width": "100%",
                    "widths": [40, 350, 80, 80, 190, "*"],
                    "body": [ 
                        [
                            {"margin": [0, 25, 0, 0]}, {"margin": [0, 25, 0, 0]}, {"margin": [0, 4, 0, 0]}, {}, {"margin": [0, 20, 0, 0]}
                        ],
                        [
                            {}, {}, {}, {}, {}
                        ]
                    ]
                }
            },
            {
                "margin": [0, 30, 0, 0],
                "style": "normal9",
                "table": {
                    "width": "100%",
                    "widths": [220, 100, 80, "*"],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "alignment": "center"}, 
                            {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, false], "text": ""}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)
    oJson["content"][1]["table"]["body"][ 1, 1]["text"] := STR0052 // "No. p/p"
    oJson["content"][1]["table"]["body"][ 1, 2]["text"] := STR0053 // "FULL NAME. insured person"
    oJson["content"][1]["table"]["body"][ 1, 3]["text"] := STR0054 + " " + STR0055 + " " + STR0056 // "Insurance number of an individual", "personal account of the insured person", "(SNILS)"
    oJson["content"][1]["table"]["body"][ 1, 4]["text"] := STR0057 + " " + STR0058 // "The amount of the transferred additional insurance premiums for the funded pension", "(rub.)" 
    oJson["content"][1]["table"]["body"][ 1, 5]["text"] := STR0059 + " " + STR0060 // "Employer contributions paid", "(in case of payment) (rub.)"
    oJson["content"][1]["table"]["body"][ 2, 1]["text"] := "1"
    oJson["content"][1]["table"]["body"][ 2, 2]["text"] := "2"
    oJson["content"][1]["table"]["body"][ 2, 3]["text"] := "3"
    oJson["content"][1]["table"]["body"][ 2, 4]["text"] := "4"
    oJson["content"][1]["table"]["body"][ 2, 5]["text"] := "5"

    aData := ::GetDataForTable()
    nTot := 0
    // add data into table 
    AEval(aData, {|X| aRow := {}, AEval(X, {|Y| oTemp := JsonObject():New(), oTemp["text"] := Y, Aadd(aRow, oTemp)}), aRow[2]["alignment"] := "left", ;
    aRow[5]["alignment"] := "right", aRow[5]["text"] := Str(aRow[5]["text"], , 2), Aadd(oJson["content"][1]["table"]["body"], aRow), nTot += X[5]})

    aRow := {JsonObject():New(), JsonObject():New(), JsonObject():New(), JsonObject():New(), JsonObject():New()}
    aRow[1]["text"] := STR0061 // "TOTAL"
    aRow[2]["text"] := "-"
    aRow[3]["text"] := "-"
    aRow[4]["text"] := ""
    aRow[5]["text"] := Str(nTot, , 2)

    Aadd(oJson["content"][1]["table"]["body"], aRow)
    oJson["content"][2]["table"]["body"][ 1, 1]["text"] := STR0062 // "The total amount of transferred funds is"
    oJson["content"][2]["table"]["body"][ 1, 2]["text"] := aRow[5]["text"]
    oJson["content"][2]["table"]["body"][ 1, 3]["text"] := STR0063 // "rubles."

Return oJson

/*/
{Protheus.doc} GetDataForTable()

    This method get data for table (get sums for PT 842 - ID 0150).

    @type Method
    @params 
    @author dchizhov
    @since 17.05.2023
    @version 12.1.33
    @return aData, Array, Array with data.
    @example aData := ::GetDataForTable()
/*/
Method GetDataForTable() Class RUHREFSP1S3DSV3Report

    Local aData      As Logical
    Local oStatement As Object
    Local cQuery     As Character 
    Local cTab       As Character
    Local aArea      As Array
    Local aSRAArea   As Array
    Local aEmployee  As Array
    Local nOrder     As Numeric
    Local nIndex     As Numeric
    Local cTemp      As Character

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aEmployee := {}
    aData := {}
    nIndex := 1
    AEval(::aPersonnelNumbers, {|X| Aadd(aEmployee, X[1])})

    cQuery := " SELECT SUM(SRD.RD_VALOR) AS SUMM, SRD.RD_MAT AS MAT, SRD.RD_FILIAL AS FILIAL FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRV.RV_CODFOL = " + ID_TIPOAFA_FOR_CALC + " "
    cQuery += " AND SRD.RD_PERIODO = ? "
    cQuery += " AND SRD.RD_MAT IN (?) "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_  = ' ' "
    cQuery += " GROUP BY SRD.RD_MAT, SRD.RD_FILIAL "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, ::aParameters[4])
    oStatement:SetIn(2, aEmployee)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(EOF())
        If !Empty(Posicione("SRA", nOrder, (cTab)->MAT, "RA_MAT"))
            cTemp := AllTrim(SRA->RA_CIC)
            cTemp := Iif(Empty(cTemp), "", Transform(SRA->RA_CIC, GetSX3Cache("RA_CIC", "X3_PICTURE")))
            Aadd(aData, {CValToChar(nIndex), SRA->RA_NOMECMP, cTemp, "", (cTab)->SUMM})
            nIndex += 1
        EndIf
        (cTab)->(DBSkip())
    EndDo

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return aData

/*/
{Protheus.doc} AddContent(oJson)

    This method add elemnts from content Json object to general json in SELF.

    @type Method
    @params oJson, Object, Json object with content-item.
    @author dchizhov
    @since 16.05.2023
    @version 12.1.33
    @return lRet, Logical, .T. If success added item, .F. - Content is empty or not exist
    @example oEFSObject:AddContent(oEFSObject:GetTitleList())
/*/
Method AddContent(oJson) Class RUHREFSP1S3DSV3Report

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
