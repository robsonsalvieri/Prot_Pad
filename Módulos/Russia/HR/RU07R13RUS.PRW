#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R13RUS.CH"

#DEFINE CHAR_SPACE_CODE 32
#DEFINE CHAR_DASH_CODE 45
#DEFINE CHAR_OPEN_PARENTHESIS_CODE 40
#DEFINE CHAR_CLOSE_PARENTHESIS_CODE 41

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

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE COUNT_PARAMS_FILTER 7
#DEFINE COUNT_PARAMS_PARAM 6
#DEFINE NAME_OF_PROGRAM "RU07R13RUS"
#DEFINE NAME_OF_PROGRAM_FIL "RU07R13FIL"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R13PAR"
#DEFINE INDEX_PARAM_SRA 5
#DEFINE INDEX_PARAM_SIGNER "5"


/*/
{Protheus.doc} RU07R13()

    Main function of routine print form of EFS-part 1 subsection 3 - DSV-3.

    @type Function
    @params 
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return 
    @example RU07R13()
/*/
Function RU07R13()

    Local oReportButton     As Object
    Local oPergunteButton   As Object
    Local oExitButton       As Object
    Local oFilterButton     As Object
    Local aFilter           As Array
    Local aParameter        As Array
    Local aUserSettings     As Array
    Local nI                As Numeric
    Local cIdUser           As Character
    Local lSeeAll           As Logical
    Local bExitButton   := {|| oDlg:End()}
    Local bParamsButton := {|| aParameter := RU07R1301_GetParamWindow()}
    Local bFilterButton := {|| aFilter := RU07R1302_GetFilterWindow()}
    Local bReportButton := {|| MsAguarde({|| RU07R1310_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    cIdUser := "U" + RetCodUsr()
    // Load default value for filter
    aFilter := RU07R1304_GetStrParam(2)
    // Load value from database for filter
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, NAME_OF_PROGRAM_FIL)
    For nI := 1 To COUNT_PARAMS_FILTER
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aFilter[nI] := SubStr(aUserSettings[nI], 1, Len(aFilter[nI]))
        EndIf
    Next nI
    If !lSeeAll
        aFilter[1] := aFilter[2] := xFilial("SRA")
    EndIf
    aFilter[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilter[INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    // Load default value for parametr
    aParameter := RU07R1304_GetStrParam(5)
    // Load value from database for parametr
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI > 1 .And. nI < 4
                aParameter[nI] := SToD(AllTrim(aUserSettings[nI]))
            Else
                aParameter[nI] := SubStr(aUserSettings[nI], 1, Len(aParameter[nI]))
            EndIf
        EndIf
    Next nI
    // Assemble the Dimensions of Objects.
    oSize := FwDefSize():New(.F.)
    oSize:AddObject("CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4), .F., .F.) // Not scalable.
    oSize:aMargins := {0, 0, 0, 0} // Space beside 0 objects, among them 3.
    oSize:lProp := .F. // Proportional.
    oSize:Process() // Trigger the calculations.

    DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
    DEFINE MSDIALOG oDlg TITLE STR0001 From 0,0 TO (oSize:aWindSize[3] * 0.4), (oSize:aWindSize[3] * 1.1) OF oMainWnd PIXEL // "EFS part 2 (4-fss)"

        @oSize:GetDimension("CABECALHO", "LININI") + 3, oSize:GetDimension("CABECALHO","COLINI") + 3 GROUP oGroup To oSize:GetDimension("CABECALHO", "LINEND") * 0.49471, oSize:GetDimension("CABECALHO", "COLEND") * 0.5  LABEL STR0006 OF oDlg PIXEL // "Description".
        oGroup:oFont:=oFont
        @oSize:GetDimension("CABECALHO", "LININI") + 20, oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY STR0007 + CRLF + STR0008 + CRLF + STR0009 ; // "Report", "Information on the accrued insurance premiums for compulsory social insurance", "from industrial accidents and occupational diseases"
            SIZE oSize:GetDimension("CABECALHO", "COLEND") * 0.49471, oSize:GetDimension("CABECALHO", "LINEND") * 0.35 Of oDlg Pixel // You can insert description of this routine.

        oFilterButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  15, STR0002, NIL, bFilterButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Filter".
        oPergunteButton := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  60, STR0003, NIL, bParamsButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Parameters".
        oReportButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 105, STR0004, NIL, bReportButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Report".
        oExitButton     := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 150, STR0005, NIL, bExitButton,   BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Exit".

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
{Protheus.doc} RU07R1310_PrintReport(aFilter, aParam)

    Get data and print report.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return .T.
    @example {|| MsAguarde({|| RU07R1310_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."
/*/
Static Function RU07R1310_PrintReport(aFilter, aParam)

    Local oEFSObject As Object
    Local oEFSDSVObj As Object

    If RU07R1303_IsAcceptButton(aParam, 2)
        aParam[1] := AllTrim(aParam[1])
        oEFSObject := RUHREFSReport():New(aParam, RU07R1311_GetFilterStr(aFilter), NAME_OF_PROGRAM)
        oEFSObject:oGeneralJson := JsonObject():New()
        If Len(oEFSObject:aPersonnelNumbers) > 0
            oEFSObject:cFilialCode := oEFSObject:aPersonnelNumbers[1, 2]
        ElseIf !Empty(AllTrim(aFilter[1]))
            oEFSObject:cFilialCode := AllTrim(aFilter[1])
        EndIf
        oEFSObject:oGeneralJson["content"] := {}
        MsProcTxt(STR0069) // "Creating a Cover Page"
        oEFSObject:cHeadTitlePage := STR0070 // "Unified form «Information for maintaining individual (personalized) records and information on accrued insurance premiums for compulsory social insurance against industrial accidents and occupational diseases (EFS-1)»"
        oEFSObject:cSignerPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aParam[5])
        oEFSObject:cSignerName := aParam[6]
        oEFSObject:cDate := DToC(Date())
        oEFSObject:AddContent(oEFSObject:GetTitleList())

        oEFSDSVObj := RUHREFSP1S3DSV3Report():New(aParam, oEFSObject:aPersonnelNumbers)
        MsProcTxt(STR0073) // "Filling in general information"
        oEFSDSVObj:AddContent(oEFSDSVObj:GetGeneralInfo())
        MsProcTxt(STR0074) // "Filling the table"
        oEFSDSVObj:AddContent(oEFSDSVObj:GetTable())

        oEFSObject:AddContent(oEFSDSVObj:oGeneralJson)

        MsProcTxt(STR0068) // "Build PDF"
        oEFSObject:GetViewReport()

        FreeObj(oEFSDSVObj)
        FreeObj(oEFSObject)
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R1311_GetFilterStr(aFilter)

    Get string for sql-query by filter.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return cFilter, Character, Filter str for SQL-request
    @example RUHREFSReport():New(aParam, RU07R1311_GetFilterStr(aFilter))
/*/
Function RU07R1311_GetFilterStr(aFilter)

    Local cFilter As Character
    Local nCount  As Numeric
    Local nX      As Numeric

    nCount := Len(aFilter[INDEX_PARAM_SRA])
    cFilter := ""
    
    cFilter += " (RA_FILIAL >= '" + aFilter[1] + "')"
    cFilter += " AND (RA_FILIAL <= '" + Iif(Empty(aFilter[2]), Replicate("Z", TamSX3("RA_FILIAL")[1]), aFilter[2]) + "')"

    cFilter += " AND (RA_CC >= '" + aFilter[3] + "')"
    cFilter += " AND (RA_CC <= '" + Iif(Empty(aFilter[4]), Replicate("Z", TamSX3("RA_CC")[1]), aFilter[4]) + "')"

    If nCount > 0
        cFilter += " AND RA_MAT IN ("
        For nX := 1 To nCount
            cFilter += "'" + aFilter[5, nX] + "'" + Iif(nX < nCount, ", ", ")")
        Next nX
    EndIf

    cFilter += " AND (RA_PROCES >= '" + aFilter[6] + "')"
    cFilter += " AND (RA_PROCES <= '" + Iif(Empty(aFilter[7]), Replicate("Z", TamSX3("RA_PROCES")[1]), aFilter[7]) + "')"

Return cFilter

// /********** functions about parametrs *************/

/*/
{Protheus.doc} RU07R1301_GetParamWindow()

    Shows a window for parametr.

    @type Static Function
    @params 
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bParamsButton := {|| aParameter := RU07R1301_GetParamWindow()}
/*/
Static Function RU07R1301_GetParamWindow()

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
    Local cValidate           As Character

    cIdUser := "U" + RetCodUsr()

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1304_GetStrParam(4)
    aParamtrField[2, 2] := RU07R1304_GetStrParam(5)
    aResultDialog := RU07R1304_GetStrParam(5)

    aParamtrField[1, 3] := RU07R1304_GetStrParam(6)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)

    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI > 1 .And. nI < 4
                aParamtrField[2, 2, nI] := SToD(AllTrim(aUserSettings[nI]))
            Else
                aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            EndIf
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0012) // "Filter"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1303_IsAcceptButton(aParamtrField[2, 2], 2)})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
        If nI > 1 .And. nI < 5
            cValidate := "{|| RU07R1306_CheckYear(aParamtrField[2, 2, " + CNChar + "], " + CValToChar(nI - 1) + ")}"
        EndIf

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE + 50, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 120, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, "@!", Iif(nI > 1 .And. nI < 5, &(cValidate), Nil), 0,16777215,,.F.,,.T.,,.F.,,.F.,.F., ;
        Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), CValToChar(nI - 1) $ INDEX_PARAM_SIGNER,,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI
    // aParamtrField[2, 1, 4]:cF3 := "RCH10" // historical str
    aParamtrField[2, 1, Val(INDEX_PARAM_SIGNER)]:cF3 := "SQ3"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_PARAM
            aResultDialog[nI] := aParamtrField[2, 2, nI]
            aUserSettings[nI] := aParamtrField[2, 2, nI]
        Next nI

        aUserSettings[2] := DToS(aUserSettings[2])
        aUserSettings[3] := DToS(aUserSettings[3])

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1302_GetFilterWindow(cNameFil)

    Shows a window for filter.

    @type Static Function
    @params cNameFil, Character, Name of programm filter
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bFilterButton := {|| aFilter := RU07R1302_GetFilterWindow()}
/*/
Function RU07R1302_GetFilterWindow(cNameFil)

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

    Default cNameFil := NAME_OF_PROGRAM_FIL

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS_FILTER), , }, {Array(COUNT_PARAMS_FILTER), }} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1304_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1304_GetStrParam(2)
    aResultDialog := RU07R1304_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1304_GetStrParam(3)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil)

    For nI := 1 To COUNT_PARAMS_FILTER
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI
    aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    If !lSeeAll
        aResultDialog[1] := aResultDialog[2] := aParamtrField[2, 2, 1] := aParamtrField[2, 2, 2] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0012) // "Filter"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1303_IsAcceptButton(aParamtrField[2, 2], 1)})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_FILTER

        cNChar := CValToChar(nI)

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
        TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,, Iif(nI < 3, !lSeeAll, .F.),,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)


        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    oButtonSRAList := TButton():New(90, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 5] := Padr(RU16R0104_GetSraList(aParamtrField[2, 2, 5]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    If lSeeAll
        aParamtrField[2, 1, 1]:cF3 := "XM0"
        aParamtrField[2, 1, 2]:cF3 := "XM0"
    EndIf
    aParamtrField[2, 1, 3]:cF3 := "CTT"
    aParamtrField[2, 1, 4]:cF3 := "CTT"
    aParamtrField[2, 1, 6]:cF3 := "RCJ"
    aParamtrField[2, 1, 7]:cF3 := "RCJ"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_FILTER
            aResultDialog[nI] := aParamtrField[2, 2, nI]
            aUserSettings[nI] := aParamtrField[2, 2, nI]
        Next nI

        aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1303_IsAcceptButton(aUserParam)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example oDialog:SetValid({|| RU07R1303_IsAcceptButton(aParamtrField[2, 2], 2)})
/*/
Static Function RU07R1303_IsAcceptButton(aUserParam, nModo)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    lResultValidation := .T. // Default value.

    If nModo == 2
        cError += Iif(Empty(aUserParam[2]), CRLF + "'" + STR0029 + "'", "") // "Date p/p"
        cError += Iif(Empty(aUserParam[3]), CRLF + "'" + STR0030 + "'", "") // "Execution date p/p"
        cError += Iif(Empty(AllTrim(aUserParam[4])), CRLF + "'" + STR0031 + "'", "") // "Period"
    EndIf

    If !Empty(cError)
        lResultValidation := .F.
        cError := STR0067 + CRLF + cError // "Parameters not filled:"
        MsgStop(cError, STR0064) // "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU07R1304_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1304_GetStrParam(2)
/*/
Static Function RU07R1304_GetStrParam(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(Iif(nMode < 4, COUNT_PARAMS_FILTER, COUNT_PARAMS_PARAM))

    If nMode == 1
        aArray[ 1] := STR0014 // "Filial from"
        aArray[ 2] := STR0015 // "Filial to"
        aArray[ 3] := STR0016 // "Cost center from"
        aArray[ 4] := STR0017 // "Cost center to"
        aArray[ 5] := STR0018 // "Tab Number"
        aArray[ 6] := STR0019 // "Process code from"
        aArray[ 7] := STR0020 // "Process code to"
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        If lSeeAll
            aArray[ 1] := Space(TamSX3("RA_FILIAL")[1])
            aArray[ 2] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[ 1] := aArray[2] := xFilial("SRA")
        EndIf
        aArray[ 3] := Space(TamSX3("RA_CC")[1])
        aArray[ 4] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 5] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 6] := Space(TamSX3("RA_PROCES")[1])
        aArray[ 7] := Replicate("Z", TamSX3("RA_PROCES")[1])
    ElseIf nMode == 3
        aArray[ 1] := STR0021 // "Enter or select the branch start code to filter data."
        aArray[ 2] := STR0022 // "Enter or select the final branch code to filter data."
        aArray[ 3] := STR0023 // "Enter or select cost center start code to filter data."
        aArray[ 4] := STR0024 // "Enter or select a final cost center code to filter data."
        aArray[ 5] := STR0025 // "Enter or select personnel numbers of employees to filter data. You can enter multiple numbers separated by ';' or you can enter employee intervals separated by '-'."
        aArray[ 6] := STR0026 // "Enter or select a process start ID to filter data."
        aArray[ 7] := STR0027 // "Enter or select the final process ID for data filtering."
    ElseIf nMode == 4
        aArray[ 1] := STR0028 // "No. p/p"
        aArray[ 2] := STR0029 // "Date p/p"
        aArray[ 3] := STR0030 // "Execution date p/p"
        aArray[ 4] := STR0031 // "Period"
        aArray[ 5] := STR0032 // "Signer"
        aArray[ 6] := STR0033 // "Name of the signatory"
    ElseIf nMode == 5
        aArray[ 1] := Space(TEXTBOX_MAX_LENGTH) // Space(3)
        aArray[ 2] := CToD("//")
        aArray[ 3] := CToD("//")
        aArray[ 4] := Space(TamSX3("RCH_PER")[1])
        aArray[ 5] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 6] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 6
        aArray[ 1] := STR0034 // "Enter the number of the payment order."
        aArray[ 2] := STR0035 // "Enter the date of the payment order."
        aArray[ 3] := STR0036 // "Enter the payment order execution date."
        aArray[ 4] := STR0037 // "Enter or select a billing period."
        aArray[ 5] := STR0038 // "Enter or select the signer's position code."
        aArray[ 6] := STR0039 // "Name of the signatory."
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R1305_GetFullNameOfSignature(cCode, cNameSignature)

    Forms the full name (NOMECMP) of the signatory person.

    @type Function
    @params cCod,           Character, Employee personnel number.
            cNameSignature, Character, Result Full name of signer.
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return lResult, Logical, Indicates that an employee is attached to the position.
    @example RU07R1305_GetFullNameOfSignature(cCodeSignature, @cNameSignature)
/*/
Function RU07R1305_GetFullNameOfSignature(cCode, cNameSignature)

    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOMECMP FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOMECMP

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    // Write result to pergunte.
    If !Empty(cFullName)
        lResult := .T.
        cNameSignature := cFullName
    Else
        lResult := .F.
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0064,, STR0065, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0066})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} RU07R1306_CheckYear(xValue, nModo)

    Check value for Year >= 2023.

    @type Function
    @params xValue, Date or Character, Checked value.
            nModo, Numeric, Modo (1 - date of payment order, 2 - date of payment execution, 3 - period (Character)).
    @author dchizhov
    @since 15.05.2023
    @version 12.1.33
    @return lResult, Logical, Year of value >= 2023.
    @example RU07R1306_CheckYear(xValue, nModo)
/*/
Function RU07R1306_CheckYear(xValue, nModo)

    Local lResult As Logical

    DEFAULT nModo = 1
    DEFAULT xValue = CToD("//")

    lResult := .F.

    If nModo == 1 .And. ValType(xValue) == "D"
        If Year(xValue) < 2023
            MsgStop(STR0040, STR0064) // "The date of the payment order must be greater than or equal to 01.01.2023", "Error"
        ElseIf xValue > Date()
            MsgStop(STR0071, STR0064) // "The date of the payment order cannot exceed the current one", "Error"
        Else
            lResult := .T.
        EndIf
    ElseIf nModo == 2 .And. ValType(xValue) == "D"
        If Year(xValue) < 2023
            MsgStop(STR0041, STR0064) // "The payment order execution date must be greater than or equal to 01.01.2023", "Error"
        ElseIf xValue > Date()
            MsgStop(STR0072, STR0064) // "The payment order execution date cannot exceed the current one", "Error"
        Else
            lResult := .T.
        EndIf
    ElseIf nModo == 3 .And. ValType(xValue) == "C" .And. Len(AllTrim(xValue)) > 3
        If Val(SubStr(xValue, 1, 4)) < 2023
            MsgStop(STR0042, STR0064) // "Period year must be greater than or equal to 2023", "Error"
        Else
            lResult := .T.
        EndIf
    EndIf

Return lResult
