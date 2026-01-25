#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R21RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE COUNT_PARAMS_PARAM 8
#DEFINE NAME_OF_PROGRAM "RU07R21RUS"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R21PAR"

#DEFINE TYPE_SAL_EMPLOYEE "2"

/*/
{Protheus.doc} RU07R21()

    Main function of report by T-53 form.

    @type Function
    @params 
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return 
    @example RU07R21()
/*/
Function RU07R21()

    Local aParameter As Array

    aParameter := RU07R2102_GetParametr(NAME_OF_PROGRAM_PAR)

    If Len(aParameter) > 0
        MsAguarde({|| RU07R2105_PrintReport(aParameter)}, STR0018, STR0015) // "Please, wait", "Data collection"
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R2102_GetParametr(cNamePar)

    Shows a window for parametr.

    @type Function
    @params cNamePar, Character, Name of programm parametr
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return aResultDialog, Array, Array of current parametr.
    @example aParameter := RU07R2102_GetParametr(NAME_OF_PROGRAM_PAR)
/*/
Function RU07R2102_GetParametr(cNamePar)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local cNChar              As Character
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character
    Local lSeeAll             As Logical

    Default cNamePar := NAME_OF_PROGRAM_PAR

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R2104_GetStrParam(1)
    aParamtrField[2, 2] := RU07R2104_GetStrParam(2)
    aResultDialog := RU07R2104_GetStrParam(2)
    aParamtrField[1, 3] := RU07R2104_GetStrParam(3)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar)

    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0001) // "Report T-53"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R2103_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        If cNChar $ "1357"
            cValidate := "{|| Iif(!RU70R0104_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
        EndIf
        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
        TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",Iif(cNChar $ "1", &(cValidate), Nil), 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,Iif(cNChar $ "1357", &(cValidate), Nil), cNChar $ "2468",,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    aParamtrField[2, 1, 1]:cF3 := aParamtrField[2, 1, 3]:cF3 := aParamtrField[2, 1, 5]:cF3 := aParamtrField[2, 1, 7]:cF3 := "SQ3"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_PARAM
            aUserSettings[nI] := aParamtrField[2, 2, nI]
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        Next nI

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar, aUserSettings)
    Else
        aResultDialog := {}
    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R2103_IsAcceptButton(aParam)

    Check parameter.

    @type Function
    @params aParam, Array, Array of parameter wich entering the user.
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return lResult, Logical, Param valid or no valid.
    @example oDialog:SetValid({|| RU07R2103_IsAcceptButton(aParamtrField[2, 2])})
/*/
Function RU07R2103_IsAcceptButton(aParam)

    Local lResult As Logical
    Local cError  As Character
    Local cNotFil As Character

    lResult := .T.
    cError := ""
    cNotFil := ""
    cNotFil := Iif(AllTrim(aParam[1]) == "" .Or. AllTrim(aParam[2]) == "", STR0002, "") // "Supervisor"
    cNotFil := Iif(AllTrim(aParam[3]) == "" .Or. AllTrim(aParam[4]) == "", STR0004, "") // "Chief accountant"
    cError += Iif(AllTrim(cNotFil) <> "", STR0016 + CRLF + cNotFil, "") // "Parameters not filled:"
    If Len(cError) > 0
        lResult := .F.
        MsgStop(cError, STR0014) // "Error"
    EndIf

Return lResult

/*/
{Protheus.doc} RU07R2104_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help.
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R2104_GetStrParam(2)
/*/
Static Function RU07R2104_GetStrParam(nMode)

    Local aArray  As Array

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[1] := STR0002 // "Supervisor"
        aArray[2] := STR0003 // "Full name of the head"
        aArray[3] := STR0004 // "Chief accountant"
        aArray[4] := STR0005 // "Full name Chief accountant"
        aArray[5] := STR0006 // "Paid (cashier)"
        aArray[6] := STR0007 // "Full name Cashier"
        aArray[7] := STR0008 // "Checked (accountant)"
        aArray[8] := STR0009 // "Full name of the accountant"
    ElseIf nMode == 2
        aArray[1] := Space(TamSX3("RA_CARGO")[1])
        aArray[2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[3] := Space(TamSX3("RA_CARGO")[1])
        aArray[4] := Space(TEXTBOX_MAX_LENGTH)
        aArray[5] := Space(TamSX3("RA_CARGO")[1])
        aArray[6] := Space(TEXTBOX_MAX_LENGTH)
        aArray[7] := Space(TamSX3("RA_CARGO")[1])
        aArray[8] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[1] := STR0010 // "Select from the directory the position of the signatory - Head"
        aArray[2] := ""
        aArray[3] := STR0011 // "Select from the directory the position of the signatory - Chief Accountant"
        aArray[4] := ""
        aArray[5] := STR0012 // "Select from the directory the position of the signatory - Cashier"
        aArray[6] := ""
        aArray[7] := STR0013 // "Select from the directory the position of the signatory - Accountant"
        aArray[8] := ""
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R2105_PrintReport(aParameter)

    This function run getting data and print data into pdf.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return 
    @example MsAguarde({|| RU07R2105_PrintReport(aParameter)}, STR0018, STR0015) // "Please, wait", "Data collection"
/*/
Static Function RU07R2105_PrintReport(aParameter)

    Local oJson       As Object
    Local oJsonTemp   As Object
    Local oOptions    As Object
    Local cJson       As Character
    Local cOptions    As Character
    Local aData       As Array

    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.
    oJson := GetTemplatate()
    aData := RU07R2106_GetData(aParameter)

    MsProcTxt(STR0017) // "Sending to PDF Maker"
    oJsonTemp := RU07R2110_CreateCoverPage(aData)
    AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})
    oJsonTemp := Nil
    oJsonTemp := RU07R2111_CreateTablePage(aData)
    AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})

    cJson := oJson:ToJson()
    cOptions := oOptions:ToJson()

    ru99x50_pdfmakeForm(cJson, 'windows-1251', cOptions, 'RU07R21')
    FreeObj(oJson)
    FreeObj(oOptions)

Return .T.

/*/
{Protheus.doc} RU07R2106_GetData(aParameter)

    This function get data for title list.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @author dchizhov
    @since 04.09.2023
    @version 12.1.2210
    @return aData, Array, Data for Title list
    @example aData := RU07R2106_GetData(aParameter)
/*/
Static Function RU07R2106_GetData(aParameter)

    Local aData As Array
    Local aTemp As Array
    Local aArea As Array
    Local nValI As Numeric
    Local nValD As Numeric
    Local cFil  As Character

    aArea := GetArea()

    If Len(AllTrim(RC1->RC1_FILTIT)) == TamSX3("RA_FILIAL")[1]
        cFil := RC1->RC1_FILTIT
    Else
        cFil := cFilAnt
    EndIf

    aData := FwBranAltInf({"BR_FULLNAM", "BR_OKPO"}, cEmpAnt, cFil)
    aTemp := FwComAltInf({"CO_FULLNAM", "CO_OKPO"}, cEmpAnt, cFil)
    aData := {aData[1, 2], aData[2, 2]}

    If Empty(AllTrim(aData[1]))
        aData[1] := aTemp[1, 2]
    EndIf
    If Empty(AllTrim(aData[2]))
        aData[2] := aTemp[2, 2]
    EndIf
    nValI := Int(RC1->RC1_VALOR)
    nValD := Round((RC1->RC1_VALOR - nValI) * 100, 0)
    aAdd(aData, RC1->RC1_CC + " " + FDesc("CTT", RC1->RC1_CC, "CTT_DESC01", , xFilial("CTT"), RetOrder("CTT", "CTT_FILIAL+CTT_CUSTO")))
    aAdd(aData, Day(RC1->RC1_EMISSA))
    aAdd(aData, Lower(RU07R1980_GetMonthName(Month(RC1->RC1_EMISSA), 2)))
    aAdd(aData, Year(RC1->RC1_EMISSA) % 100)
    aAdd(aData, Day(RC1->RC1_VENCTO))
    aAdd(aData, Lower(RU07R1980_GetMonthName(Month(RC1->RC1_VENCTO), 2)))
    aAdd(aData, Year(RC1->RC1_VENCTO) % 100)
    aAdd(aData, Lower(RU99X01(nValI, .F., "1")))
    aAdd(aData, Lower(RU99X01(nValD, .F., "2")))
    aAdd(aData, CValToChar(nValI))
    aAdd(aData, CValToChar(nValD))
    aAdd(aData, StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParameter[1])))
    aAdd(aData, aParameter[2])
    aAdd(aData, StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParameter[3])))
    aAdd(aData, aParameter[4])
    aAdd(aData, RC1->RC1_NUMTIT)
    aAdd(aData, DToC(RC1->RC1_EMISSA))
    aAdd(aData, DToC(RC1->RC1_DTBUSI))
    aAdd(aData, DToC(RC1->RC1_DTBUSF))
    aAdd(aData, RU07R2107_GetAllData())
    aAdd(aData, StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParameter[5])))
    aAdd(aData, aParameter[6])
    aAdd(aData, StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParameter[7])))
    aAdd(aData, aParameter[8])

    RestArea(aArea)

Return aData

/*/
{Protheus.doc} RU07R1907_GetStructCodeF(cEmpAnalyze)

    This function get data for table from bills.

    @type Function
    @params 
    @author dchizhov
    @since 12.09.2023
    @version 12.1.2210
    @return aDataArray, Array, array with data for table.
    @example aAdd(aData, RU07R2107_GetAllData())
/*/
Static Function RU07R2107_GetAllData()

    Local aDataArray           As Array
    Local cTempChar            As Character
    Local aPayingType          As Array
    Local aArea                As Array
    Local aRC0Area                As Array
    Local aSRAArea              As Array
    Local cTable               As Character
    Local cDateField               As Character
    Local cAlias               As Character
    Local cFields              As Character
    Local cWhere               As Character
    Local cGroupCond           As Character
    Local nX                   As Numeric

    aArea := GetArea()
    aRC0Area := RC0->(GetArea())
    aSRAArea := SRA->(GetArea())
    Posicione("RC0", RetOrdem("RC0", "RC0_FILIAL+RC0_CODTIT"), xFilial("RC0") + RC1->RC1_CODTIT, "RC0_VERBAS")
    aPayingType := {}

    If RC0->RC0_CODTIT == RC1->RC1_CODTIT
        cTempChar := AllTrim(RC0->RC0_VERBAS)
        For nX := 1 To Len(cTempChar) Step 4
            Aadd(aPayingType, SubStr(cTempChar, nX, 3))
        Next nX
    EndIf

    aDataArray := {}
    cTable := RC0->RC0_ALIAS
    cDateField := RC0->RC0_FILTRD
    cFields := PrefixoCpo(cTable) + "_"

    cWhere := "% SRT." + cFields + "FILIAL = '" + RC1->RC1_FILTIT + "'" + CRLF
    cWhere += Iif(Empty(AllTrim(RC1->RC1_CC)), "", "AND SRT." + cFields + "CC = '" + RC1->RC1_CC + "'" + CRLF)
    cWhere += Iif(Empty(AllTrim(RC1->RC1_DEPTO)), "", "AND SRT." + cFields + "DEPTO = '" + RC1->RC1_DEPTO + "'" + CRLF)
    cWhere += Iif(Empty(AllTrim(RC1->RC1_MAT)), "", "AND SRT." + cFields + "MAT = '" + RC1->RC1_MAT + "'" + CRLF)
    cWhere += "AND " + "SRT." + cDateField + " = '" + DToS(RC1->RC1_EMISSA) + "'" + CRLF

    cWhere += "AND SRT." + cFields + "PD IN ("
    For nX := 1 To Len(aPayingType)
        cWhere += Iif(nX > 1, ", '", "'") + aPayingType[nX] + "'"
    Next nX
    cWhere += ")"

    cWhere += " %"

    cGroupCond := "% SRT." + cFields + "FILIAL" + ", SRT." + cFields + "MAT, SRT." + cDateField + " %"
    cFields := "% SUM(SRT." + cFields + "VALOR) VALOR" + ", SRT." + cFields + "FILIAL FILIAL" + ", SRT." + cFields + "MAT MAT, " + cDateField + " DAT %"
    // cFields := "% SRT." + cFields + "VALOR VALOR" + ", SRT." + cFields + "FILIAL FILIAL" + ", SRT." + cFields + "MAT MAT, " + cDateField + " DAT %"
    
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
    nX := 1
    While !(cAlias)->(EOF())
        If !Empty(Posicione("SRA", RetOrder("SRA", "RA_MAT+RA_FILIAL"), (cAlias)->MAT, "RA_MAT"))
            If SRA->RA_TPCTSAL $ TYPE_SAL_EMPLOYEE
                Aadd(aDataArray, {CValToChar(nX), (cAlias)->MAT, AllTrim(SRA->RA_PRISOBR), AllTrim(SRA->RA_PRINOME), AllTrim(SRA->RA_SECNOME), ;
                DToC(SRA->RA_NASC), (cAlias)->VALOR, "", ""})
                nX += 1
            EndIf
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RC0->(RestArea(aRC0Area))
    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU07R2110_CreateCoverPage(aData)

    This function create Json with Cover Page.

    @type Static Function
    @params aData, Array, Array with data for Json
    @author dchizhov
    @since 05.09.2023
    @version 12.1.2210
    @return oJson, Object, Json for pdf-maker.
    @example oJson := RU07R2110_CreateCoverPage(aData)
/*/
Static Function RU07R2110_CreateCoverPage(aData)

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content":[
            
            {
                "margin": [390, 50, 0, 0],
                "style": "small",
                "alignment": "left",
                "text": ["", "", "" ]
            },
            {
                "margin": [50, 7, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [285, 70, 40, 70],
                    "body": [ 
                        [
                            {"border": [false, false, false, false], "text": "", "colSpan": 3}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 3, "alignment": "right"}, {}, {}, {}
                        ],
                        [
                            {"border": [false, false, false, true], "colSpan": 2}, {}, {"border": [false, false, false, true]}, {}
                        ],
                        [
                            {"border": [false, false, false, false], "colSpan": 2, "style": "small7"}, {}, {"border": [false, false, false, false], "text": ""}, 
                            {"border": [true, true, true, false], "text": ""}
                        ],
                        [
                            {"border": [false, false, false, true], "colSpan": 3}, {}, {}, 
                            {"border": [true, false, true, true], "text": ""}
                        ],
                        [
                            {"margin":[80, 0, 0, 0], "border": [false, true, false, false], "style": "small7"}, {"border": [false, true, true, false], "colSpan": 2}, {}, {}
                        ]
                    ]
                }
            },
            {
                "bold": true,
                "style": "normal",
                "margin": [50, 17, 0, 0]
            },
            {
                "margin": [50, 7, 0, 0],
                "style": "normal",
                "alignment": "center",
                "bold": true,
                "table": {
                    "widths": [5, 5, 15, 10, 50, 15, 13, 20, 5, 13, 10, 50, 15, 15, 15],
                    "body": [ 
                        [
                            {}, {}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]},
                            {}, {"border": [false, false, false, true]}, {}, {}, {"border": [false, false, false, true]},
                            {}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [50, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [30, 390],
                    "body": [ 
                        [
                            {"border": [false, false, false, false]}, {"border": [false, false, false, true]}
                        ],
                        [
                            {"text": "", "border": [false, false, false, false], "style": "small7"}, 
                            {"border": [false, false, false, false], "style": "small7"}
                        ]
                    ]
                }
            },
            {
                "margin": [53, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [170, 20, 35, 25, 60, 20, 20, 20],
                    "body": [ 
                        [
                            {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]},
                            {}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]}, {}
                        ],
                        [
                            {"colSpan": 4, "text": ""}, {}, {}, {}, {"style": "small7"}, {"colSpan": 3, "text": ""}, {}, {} 
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [53, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [130, 90, 3, 50, 3, 130],
                    "body": [ 
                        [
                            {"bold": true}, {"border": [false, false, false, true]}, {},
                            {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true]}
                        ],
                        [
                            {}, {"style": "small6"}, {}, {"style": "small6"}, {}, {"style": "small6"}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [53, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [90, 90, 3, 150],
                    "body": [ 
                        [
                            {"bold": true}, {"border": [false, false, false, true]}, {},
                            {"border": [false, false, false, true], "text": ""}
                        ],
                        [
                            {}, {"style": "small6"}, {}, {"style": "small6"}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [173, 0, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [5, 15, 5, 60, 20, 20, 20],
                    "body": [ 
                        [
                            {}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]}, {},
                            {"border": [false, false, false, true]}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [135, 10, 0, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [100, 70, 70, 5, 60, 60],
                    "body": [ 
                        [
                            {"margin": [0, 6, 0, 0], "bold": true, "fontSize": 13, "rowSpan":2, "border": [false, false, false, false]}, {"margin": [0, 2, 0, 0], "rowSpan": 2}, 
                            {"margin": [0, 2, 0, 0], "rowSpan": 2}, 
                            {"rowSpan": 3, "border": [false, false, false, false], "text": ""}, {"colSpan": 2}, {}
                        ],
                        [
                            {}, {}, {}, {}, {}, {}
                        ],
                        [
                            {"bold": true, "fontSize": 13, "border": [false, false, false, false]}, {"margin": [0, 2, 0, 0]}, 
                            {"margin": [0, 2, 0, 0]}, {}, {"margin": [0, 2, 0, 0]}, {"margin": [0, 2, 0, 0]}
                        ]
                    ]
                }
            }
        ]
    }
    EndContent

    oJson:FromJson(cJson)

    oJson["content"][1]["text"][1] := STR0019 + CRLF // "Unified form No. T-53"
    oJson["content"][1]["text"][2] := STR0020 + CRLF // "Approved by the Decree of the State Statistics Committee"
    oJson["content"][1]["text"][3] := STR0021 // "Russia dated 05.01.2004 No. 1"

    oJson["content"][2]["table"]["body"][1, 4]["text"] := STR0022 // "Code"
    oJson["content"][2]["table"]["body"][2, 1]["text"] := STR0023 // "OKUD form"
    oJson["content"][2]["table"]["body"][2, 4]["text"] := STR0024 // "301011"
    oJson["content"][2]["table"]["body"][3, 1]["text"] := aData[1]
    oJson["content"][2]["table"]["body"][3, 3]["text"] := STR0025 // "according to OKPO"
    oJson["content"][2]["table"]["body"][3, 4]["text"] := aData[2]
    oJson["content"][2]["table"]["body"][4, 1]["text"] := STR0026 // "(name of company)"
    oJson["content"][2]["table"]["body"][5, 1]["text"] := aData[3]
    oJson["content"][2]["table"]["body"][6, 1]["text"] := STR0027 // "(structural subdivision)"
    oJson["content"][2]["table"]["body"][6, 2]["text"] := STR0028 // "Corresponding account"
    oJson["content"][3]["text"] := STR0029 // "To the cashier for payment on time"

    oJson["content"][4]["table"]["body"][1, 1]["text"] := STR0030 // "With"
    oJson["content"][4]["table"]["body"][1, 2]["text"] := STR0031 // '"'
    oJson["content"][4]["table"]["body"][1, 3]["text"] := aData[4]
    oJson["content"][4]["table"]["body"][1, 4]["text"] := STR0031 // '"'
    oJson["content"][4]["table"]["body"][1, 5]["text"] := aData[5]
    oJson["content"][4]["table"]["body"][1, 6]["text"] := STR0032 // "20"
    oJson["content"][4]["table"]["body"][1, 7]["text"] := aData[6]
    oJson["content"][4]["table"]["body"][1, 8]["text"] := STR0033 // "by"
    oJson["content"][4]["table"]["body"][1, 9]["text"] := STR0031 // '"'
    oJson["content"][4]["table"]["body"][1,10]["text"] := aData[7]
    oJson["content"][4]["table"]["body"][1,11]["text"] := STR0031 // '"'
    oJson["content"][4]["table"]["body"][1,12]["text"] := aData[8]
    oJson["content"][4]["table"]["body"][1,13]["text"] := STR0032 // "20"
    oJson["content"][4]["table"]["body"][1,14]["text"] := aData[9]
    oJson["content"][4]["table"]["body"][1,15]["text"] := STR0034 // "G."
    oJson["content"][5]["table"]["body"][1, 1]["text"] := STR0035 // "Sum"
    oJson["content"][5]["table"]["body"][1, 2]["text"] := SubStr(aData[10], 1, 86)
    oJson["content"][5]["table"]["body"][2, 2]["text"] := STR0036 // "(in words)"
    oJson["content"][6]["table"]["body"][1, 1]["text"] := SubStr(aData[10], 86)
    oJson["content"][6]["table"]["body"][1, 2]["text"] := STR0037 // "rub."
    oJson["content"][6]["table"]["body"][1, 3]["text"] := aData[11]
    oJson["content"][6]["table"]["body"][1, 4]["text"] := STR0038 // "cop. ("
    oJson["content"][6]["table"]["body"][1, 5]["text"] := aData[12]
    oJson["content"][6]["table"]["body"][1, 6]["text"] := STR0039 // "rub."
    oJson["content"][6]["table"]["body"][1, 7]["text"] := aData[13]
    oJson["content"][6]["table"]["body"][1, 8]["text"] := STR0040 // "cop.)"
    oJson["content"][6]["table"]["body"][2, 5]["text"] := STR0041 // "(in numbers)"
    oJson["content"][7]["table"]["body"][1, 1]["text"] := STR0042 // "Head of the organization"
    oJson["content"][7]["table"]["body"][1, 2]["text"] := aData[14]
    oJson["content"][7]["table"]["body"][1, 6]["text"] := aData[15]
    oJson["content"][7]["table"]["body"][2, 2]["text"] := STR0043 // "(job title)"
    oJson["content"][7]["table"]["body"][2, 4]["text"] := STR0044 // "(personal signature)"
    oJson["content"][7]["table"]["body"][2, 6]["text"] := STR0045 // "(full name)"
    oJson["content"][8]["table"]["body"][1, 1]["text"] := STR0046 // "Chief Accountant"
    oJson["content"][8]["table"]["body"][1, 2]["text"] := aData[16]
    oJson["content"][8]["table"]["body"][1, 4]["text"] := aData[17]
    oJson["content"][8]["table"]["body"][2, 2]["text"] := STR0047 // "(personal signature)"
    oJson["content"][8]["table"]["body"][2, 4]["text"] := STR0048 // "(full name)"
    oJson["content"][9]["table"]["body"][1, 1]["text"] := STR0031 // '"'
    oJson["content"][9]["table"]["body"][1, 2]["text"] := ""
    oJson["content"][9]["table"]["body"][1, 3]["text"] := STR0031 // '"'
    oJson["content"][9]["table"]["body"][1, 4]["text"] := ""
    oJson["content"][9]["table"]["body"][1, 5]["text"] := STR0032 // "20"
    oJson["content"][9]["table"]["body"][1, 6]["text"] := ""
    oJson["content"][9]["table"]["body"][1, 7]["text"] := STR0034 // "G."
    
    oJson["content"][10]["table"]["body"][1, 1]["text"] := STR0049 // "PAYMENT"
    oJson["content"][10]["table"]["body"][1, 2]["text"] := STR0051 // "Document Number"
    oJson["content"][10]["table"]["body"][1, 3]["text"] := STR0052 // "Date of preparation"
    oJson["content"][10]["table"]["body"][1, 5]["text"] := STR0053 // "Billing period"
    oJson["content"][10]["table"]["body"][2, 5]["text"] := STR0054 // "With"
    oJson["content"][10]["table"]["body"][2, 6]["text"] := STR0055 // "By"
    oJson["content"][10]["table"]["body"][3, 1]["text"] := STR0050 // "STATEMENT"
    oJson["content"][10]["table"]["body"][3, 2]["text"] := aData[18]
    oJson["content"][10]["table"]["body"][3, 3]["text"] := aData[19]
    oJson["content"][10]["table"]["body"][3, 5]["text"] := aData[20]
    oJson["content"][10]["table"]["body"][3, 6]["text"] := aData[21]

Return oJson

/*/
{Protheus.doc} RU07R2111_CreateTablePage(aData)

    This function create Json with Page.

    @type Static Function
    @params aData, Array, Array with data for Json
    @author dchizhov
    @since 08.09.2023
    @version 12.1.2210
    @return oJson, Object, Json for pdf-maker.
    @example oJsonTemp := RU07R2111_CreateTablePage(aData)
/*/
Static Function RU07R2111_CreateTablePage(aData)

    Local oJson As Object
    Local oTemp As Object
    Local aJRow As Array
    Local cJson As Character
    Local nX    As Numeric
    Local nI    As Numeric
    Local nSumm As Numeric

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "content":[
            {
                "margin":[0, 50, 40, 0],
                "pageBreak": "before",
                "style": "small7",
                "alignment": "right"
            },
            {
                "margin": [50, 10, 60, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [15, 45, 43, 43, 43, 49, 60, 67, 54],
                    "body": [ 
                        [
                            {"margin": [0, 15, 0, 0]}, {"margin": [0, 15, 0, 0]}, {"margin": [0, 20, 0, 0]}, {"margin": [0, 20, 0, 0]}, {"margin": [0, 20, 0, 0]}, 
                            {"margin": [0, 15, 0, 0]}, {"margin": [0, 15, 0, 0]}, {}, {"margin": [0, 15, 0, 0]}
                        ], 
                        [
                            {"text": "1"}, {"text": "2"}, {"text": "3"}, {"text": "4"}, {"text": "5"}, 
                            {"text": "6"}, {"text": "7"}, {"text": "8"}, {"text": "9"}
                        ]
                    ]
                }
            },
            {
                "margin": [50, 10, 60, 0],
                "style": "normal", 
                "alignment": "left",
                "text": ["", ""]
            },
            {
                "margin": [50, 0, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": ["*", 20, 50, 25, 60, 25, 25, 25],
                    "body": [ 
                        [
                            {"fontSize": 6, "colSpan": 8, "margin": [20, 0, 0, 0]}, {}, {}, {}, {}, {}, {}, {}
                        ], 
                        [
                            {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true], "text": ""}, {},
                            {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true]}, {}
                        ], 
                        [
                            {}, {}, {}, {},
                            {"fontSize": 6}, {}, {}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [50, 2, 60, 0],
                "style": "normal", 
                "alignment": "center",
                "text": [
                    "",
                    {"style": "small6", "text": "", "margin": [20, 0, 0, 0]}
                ]
            },
            {
                "margin": [50, 0, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": ["*", 20, 50, 25, 60, 25, 25, 25],
                    "body": [ 
                        [
                            {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true], "text": ""}, {},
                            {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true], "text": ""}, {}
                        ], 
                        [
                            {}, {}, {}, {},
                            {"fontSize": 6}, {}, {}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [48, 0, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [88, 70, 1, 70, 1, 120],
                    "body": [ 
                        [
                            {"bold": true, "alignment": "left"}, {"border": [false, false, false, true]}, {}, {"border": [false, false, false, true], "text": ""}, {},
                            {"border": [false, false, false, true]}
                        ],
                        [
                            {}, {"fontSize": 6}, {}, {"fontSize": 6}, {}, {"fontSize": 6}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [48, 0, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [130, 50, 20, 25, 5, 70, 20, 15, 15],
                    "body": [ 
                        [
                            {"alignment": "left"}, {"border": [false, false, false, true], "text": ""}, {}, 
                            {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true], "text": ""}, {},
                            {"border": [false, false, false, true], "text": ""}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [48, 6, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [90, 80, 2, 130],
                    "body": [ 
                        [
                            {"alignment": "left"}, {"border": [false, false, false, true], "text": ""}, {}, 
                            {"border": [false, false, false, true]}
                        ],
                        [
                            {}, {"fontSize": 6}, {}, {"fontSize": 6}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            },
            {
                "margin": [148, 0, 52, 0],
                "style": "normal",
                "alignment": "center",
                "table": {
                    "widths": [5, 25, 5, 70, 20, 15, 15],
                    "body": [ 
                        [
                            {}, {"border": [false, false, false, true], "text": ""}, {}, {"border": [false, false, false, true], "text": ""}, {},
                            {"border": [false, false, false, true], "text": ""}, {}
                        ]
                    ]
                },
                "layout": {
                    "defaultBorder": false
                }
            }
        ]
    }
    EndContent
    

    oJson:FromJson(cJson)

    oJson["content"][1]["text"] := STR0056 // "2nd page of form No. T-53"

    oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0057 + CRLF + STR0058 // "No.", "p/p"
    oJson["content"][2]["table"]["body"][1, 2]["text"] := STR0059 // "Personnel Number"
    oJson["content"][2]["table"]["body"][1, 3]["text"] := STR0060 // "Surname"
    oJson["content"][2]["table"]["body"][1, 4]["text"] := STR0061 // "Name"
    oJson["content"][2]["table"]["body"][1, 5]["text"] := STR0062 // "Surname"
    oJson["content"][2]["table"]["body"][1, 6]["text"] := STR0063 // "Date of birth"
    oJson["content"][2]["table"]["body"][1, 7]["text"] := STR0064 + CRLF + STR0065 // "Sum,", "rub."
    oJson["content"][2]["table"]["body"][1, 8]["text"] := STR0066 // "Signature in receipt of money (record of deposit of amount)"
    oJson["content"][2]["table"]["body"][1, 9]["text"] := STR0067 // "Note"

    nSumm := 0
    For nX := 1 To Len(aData[22])
        aJRow := {}
        For nI := 1 To 9
            oTemp := JsonObject():New()
            oTemp["text"] := aData[22, nX, nI]
            aAdd(aJRow, oTemp)
        Next nI
        nSumm += aJRow[7]["text"]
        aJRow[7]["text"] := AllTrim(Str(aJRow[7]["text"], , 2))
        aAdd(oJson["content"][2]["table"]["body"], aJRow)
    Next nX

    oJson["content"][3]["text"][1] := STR0068 + CRLF // "According to this payroll"
    oJson["content"][3]["text"][2] := STR0069 + Replicate(Chr(95), 82) // "amount paid"
    oJson["content"][4]["table"]["body"][1, 1]["text"] := STR0070 // "(in words)"
    oJson["content"][4]["table"]["body"][2, 2]["text"] := STR0071 // "rub."
    oJson["content"][4]["table"]["body"][2, 4]["text"] := STR0072 // "cop. ("
    oJson["content"][4]["table"]["body"][2, 5]["text"] := Int(nSumm)
    oJson["content"][4]["table"]["body"][2, 6]["text"] := STR0073 // "rub."
    oJson["content"][4]["table"]["body"][2, 7]["text"] := Round((nSumm % 1) * 100, 0)
    oJson["content"][4]["table"]["body"][2, 8]["text"] := STR0074 // "cop.)"
    oJson["content"][4]["table"]["body"][3, 5]["text"] := STR0075 // "(in numbers)"
    oJson["content"][5]["text"][1] := STR0076 + Replicate(Chr(95), 77) + CRLF // "and deposited amount"
    oJson["content"][5]["text"][2]["text"] := STR0070 + CRLF // "(in words)"
    oJson["content"][6]["table"]["body"][1, 2]["text"] := STR0071 // "rub."
    oJson["content"][6]["table"]["body"][1, 4]["text"] := STR0072 // "cop. ("
    oJson["content"][6]["table"]["body"][1, 6]["text"] := STR0073 // "rub."
    oJson["content"][6]["table"]["body"][1, 8]["text"] := STR0074 // "cop.)"
    oJson["content"][6]["table"]["body"][2, 5]["text"] := STR0075 // "(in numbers)"
    oJson["content"][7]["table"]["body"][1, 1]["text"] := STR0077 // "The payment was made"
    oJson["content"][7]["table"]["body"][1, 2]["text"] := aData[23]
    oJson["content"][7]["table"]["body"][1, 6]["text"] := aData[24]
    oJson["content"][7]["table"]["body"][2, 2]["text"] := STR0078 // "(job title)"
    oJson["content"][7]["table"]["body"][2, 4]["text"] := STR0079 // "(personal signature)"
    oJson["content"][7]["table"]["body"][2, 6]["text"] := STR0080 // "(full name)"
    oJson["content"][8]["table"]["body"][1, 1]["text"] := STR0081 // "Expenditure cash order No."
    oJson["content"][8]["table"]["body"][1, 3]["text"] := STR0082 + " " + STR0031 // "from", '"'
    oJson["content"][8]["table"]["body"][1, 5]["text"] := STR0031 // '"'
    oJson["content"][8]["table"]["body"][1, 7]["text"] := STR0032 // "20"
    oJson["content"][8]["table"]["body"][1, 9]["text"] := STR0034 // "G."
    oJson["content"][9]["table"]["body"][1, 1]["text"] := STR0083 // "Checked accountant"
    oJson["content"][9]["table"]["body"][1, 4]["text"] := aData[26]
    oJson["content"][9]["table"]["body"][2, 2]["text"] := STR0084 // "(personal signature)"
    oJson["content"][9]["table"]["body"][2, 4]["text"] := STR0085 // "(full name)"

    oJson["content"][10]["table"]["body"][1, 1]["text"] := STR0031 // '"'
    oJson["content"][10]["table"]["body"][1, 2]["text"] := aData[4]
    oJson["content"][10]["table"]["body"][1, 3]["text"] := STR0031 // '"'
    oJson["content"][10]["table"]["body"][1, 4]["text"] := aData[5]
    oJson["content"][10]["table"]["body"][1, 5]["text"] := STR0032 // "20"
    oJson["content"][10]["table"]["body"][1, 6]["text"] := aData[6]
    oJson["content"][10]["table"]["body"][1, 7]["text"] := STR0034 // "G."

Return oJson

/*/
{Protheus.doc} GetTemplatate()

    This function biuld empty templatate for report and Json without content.

    @type Static Function
    @params 
    @author dchizhov
    @since 29.08.2023
    @version 12.1.2210
    @return oJson, Object, Json for report.
    @example oJson := GetTemplatate()
/*/
Static Function GetTemplatate()

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
                "fontSize": 9,
                "bold": false
            },
            "small": {
            "font": "Arial",
                "fontSize": 8,
                "bold": false
            },
            "small7": {
            "font": "Arial",
                "fontSize": 7,
                "bold": false
            },
            "small6": {
            "font": "Arial",
                "fontSize": 6,
                "bold": false
            }
        },
        "content": [
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson
