#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R15RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE COUNT_PARAMS_FILTER 7
#DEFINE COUNT_PARAMS_PARAM 5
#DEFINE NAME_OF_PROGRAM "RU07R15RUS"
#DEFINE NAME_OF_PROGRAM_FIL "RU07R15FIL"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R15PAR"
#DEFINE INDEX_PARAM_COMBOBOX "3"
#DEFINE INDEX_PARAM_SIGNER "4"
#DEFINE INDEX_PARAM_SRA 5
#DEFINE DEFAULT_PARAM_INDEX 3
#DEFINE DEFAULT_PARAM_VALUE 2

/*/
{Protheus.doc} RU07R15()

    Main function of routine print form of EFS-part 1 subsection 1.1 - SZV-TD.

    @type Function
    @params 
    @author dchizhov
    @since 14.06.2023
    @version 12.1.33
    @return 
    @example RU07R15()
/*/
Function RU07R15()

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
    Local bParamsButton := {|| aParameter := RU07R1501_GetParamWindow(aParameter)}
    Local bFilterButton := {|| aFilter := RU07R1302_GetFilterWindow(NAME_OF_PROGRAM_FIL)}
    Local bReportButton := {|| MsAguarde({|| RU07R1510_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    cIdUser := "U" + RetCodUsr()
    // Load default value for filter
    aFilter := StaticCall(RU07R13RUS, RU07R1304_GetStrParam, 2)
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
    aParameter := RU07R1503_GetStrParam(2)
    // Load value from database for parametr
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI < 3
                aParameter[nI] := SToD(AllTrim(aUserSettings[nI]))
            ElseIf CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                aParameter[nI] := Val(aUserSettings[nI])
                If aParameter[nI] <= 0
                    aParameter[nI] := 1
                EndIf
            Else
                aParameter[nI] := SubStr(aUserSettings[nI], 1, Len(aParameter[nI]))
            EndIf
        EndIf
    Next nI
    aParameter[DEFAULT_PARAM_INDEX] := DEFAULT_PARAM_VALUE
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
{Protheus.doc} RU07R1510_PrintReport(aFilter, aParam)

    Get data and print report.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
    @return .T.
    @example {|| MsAguarde({|| RU07R1510_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."
/*/
Static Function RU07R1510_PrintReport(aFilter, aParam)

    Local oEFSObject   As Object
    Local oEFSSZVObj   As Object
    Local oEFSSZVTDObj As Object
    Local oSubs1_1     As Object
    Local oTabs1_1     As Object
    Local nX           As Numeric
    Local nOrder       As Numeric
    Local nLenght      As Numeric
    Local cTemp        As Character
    Local aSRAArea     As Array
    Local lPageBreak   As Logical

    If RU07R1502_IsAcceptButton(aParam)
        lPageBreak := .T.
        aSRAArea := SRA->(GetArea())
        oEFSObject := RUHREFSReport():New(aParam, RU07R1311_GetFilterStr(aFilter), NAME_OF_PROGRAM)
        oEFSObject:oGeneralJson := JsonObject():New()
        If Len(oEFSObject:aPersonnelNumbers) > 0
            oEFSObject:cFilialCode := oEFSObject:aPersonnelNumbers[1, 2]
        ElseIf !Empty(AllTrim(aFilter[1]))
            oEFSObject:cFilialCode := AllTrim(aFilter[1])
        EndIf
        oEFSObject:oGeneralJson["content"] := {}
        MsProcTxt(STR0030) // "Creating a Cover Page"
        oEFSObject:cHeadTitlePage := STR0066 // "Unified form «Information for maintaining individual (personalized) records and information on accrued insurance premiums for compulsory social insurance against industrial accidents and occupational diseases (EFS-1)»"
        oEFSObject:cSignerPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aParam[4])
        oEFSObject:cSignerName := aParam[5]
        oEFSObject:cDate := DToC(Date())
        oEFSObject:AddContent(oEFSObject:GetTitleList())

        oEFSSZVObj := RUHREFSP1S12A2Report():New()
        cTemp := CValToChar(Len(oEFSObject:aPersonnelNumbers))
        nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
        nLenght := Len(cTemp)
        oEFSObject:aPersonnelNumbers := oEFSSZVObj:SortByName(oEFSObject:aPersonnelNumbers)
        oEFSSZVTDObj := RUHREFSP1S11SZVTDReport():New(aParam)
        For nX := 1 To Len(oEFSObject:aPersonnelNumbers)
            If !Empty(Posicione("SRA", nOrder, oEFSObject:aPersonnelNumbers[nX, 1], "RA_MAT"))
                MsProcTxt(STR0065 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp) // "Processed employees:"
                oEFSSZVObj:AddContent(oEFSSZVObj:GetGeneralInfo(.T.))
                oSubs1_1 := oEFSSZVTDObj:GetPart1()
                oTabs1_1 := oEFSSZVTDObj:GetTab1()
                If Len(oTabs1_1["content"][1]["table"]["body"]) > 3
                    oEFSObject:AddContent(oEFSSZVObj:oGeneralJson)
                    oEFSObject:AddContent(oSubs1_1)
                    oEFSObject:AddContent(oTabs1_1)
                EndIf                
                oEFSSZVObj:oGeneralJson["content"] := {}
                lPageBreak := .F.
            EndIf
        Next nX

        MsProcTxt(STR0031) // "Build a PDF"
        oEFSObject:GetViewReport()

        FreeObj(oEFSSZVObj)
        FreeObj(oEFSObject)
        SRA->(RestArea(aSRAArea))
    EndIf

Return .T.

// // /********** functions about parametrs *************/

/*/
{Protheus.doc} RU07R1501_GetParamWindow(aParamCur)

    Shows a window for parametr.

    @type Static Function
    @params aParamCur, Array,   Current array of parametr.
    @author dchizhov
    @since 14.06.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bParamsButton := {|| aParameter := RU07R1501_GetParamWindow(aParameter)}
/*/
Static Function RU07R1501_GetParamWindow(aParamCur)

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
    Local cChange             As Character
    Local nIndex              As Numeric
    Local aItems              As Array
    Local lCurParam           As Logical

    DEFAULT aParamCur := {}

    cIdUser := "U" + RetCodUsr()
    lCurParam := Len(aParamCur) > 0

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 
    aParamtrField[1, 2] := RU07R1503_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1503_GetStrParam(2)
    aResultDialog := RU07R1503_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1503_GetStrParam(3)
    aItems := RU07R1503_GetStrParam(4)
    If lCurParam
        aUserSettings := AClone(aParamCur)
    Else
        aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    EndIf

    For nI := 1 To COUNT_PARAMS_PARAM
        If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
            nIndex := aResultDialog[nI]
            If nIndex <= Len(aItems) .And. nIndex > 0
                aParamtrField[2, 2, nI] := aItems[nIndex]
                aParamtrField[2, 3, nI] := nIndex
            EndIf
        EndIf
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI < 3
                aParamtrField[2, 2, nI] := SToD(AllTrim(aUserSettings[nI]))
            ElseIf CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                nIndex := Iif(lCurParam, aUserSettings[nI], Val(aUserSettings[nI]))
                If nIndex <= Len(aItems) .And. nIndex > 0
                    aParamtrField[2, 2, nI] := aItems[nIndex]
                    aParamtrField[2, 3, nI] := nIndex
                EndIf
            Else
                aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            EndIf
            aResultDialog[nI] := Iif(CValToChar(nI) $ INDEX_PARAM_COMBOBOX, aParamtrField[2, 3, nI], aParamtrField[2, 2, nI])
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0012) // "Filter"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1502_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE + 50, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        If cNChar $ INDEX_PARAM_COMBOBOX
            cValidate := "{|o| aParamtrField[2, 3, " + cNChar + "] := o:nAt}"
            aParamtrField[2, 1, nI] := TComboBox():New(-10 + nI * 20, 120, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), aItems, ;
            TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, oScrollBox,, &(cValidate),,,, .T.,,,,,,,,, "aParamtrField[2, 2, " + cNChar + "]")
        Else
            cChange := "{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"
            aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 120, &(cChange), oScrollBox, TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, "@!",, ;
            0,16777215,,.F.,,.T.,,.F.,,.F.,.F., Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), CValToChar(nI - 1) $ INDEX_PARAM_SIGNER,,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)
        EndIf

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI
    aParamtrField[2, 1, Val(INDEX_PARAM_SIGNER)]:cF3 := "SQ3"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_PARAM
            If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                aUserSettings[nI] := CValToChar(aParamtrField[2, 3, nI])
                aResultDialog[nI] := aParamtrField[2, 3, nI]
            Else
                aUserSettings[nI] := aParamtrField[2, 2, nI]
                aResultDialog[nI] := aParamtrField[2, 2, nI]
            EndIf
        Next nI

        aUserSettings[1] := DToS(aUserSettings[1])
        aUserSettings[2] := DToS(aUserSettings[2])

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1502_IsAcceptButton(aUserParam)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 14.06.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example oDialog:SetValid({|| RU07R1502_IsAcceptButton(aParamtrField[2, 2])})
/*/
Static Function RU07R1502_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    DEFAULT aUs3 := aUserParam

    lResultValidation := .T. // Default value.


    If !Empty(cError)
        lResultValidation := .F.
        cError := Iif(Empty(cError), "", STR0026 + CRLF + cError) // "Parameters not filled:"
        MsgStop(cError, STR0025) // "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU07R1503_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 14.06.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1503_GetStrParam(2)
/*/
Static Function RU07R1503_GetStrParam(nMode)

    Local aArray  As Array

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[ 1] := STR0013 // "Period from"
        aArray[ 2] := STR0014 // "Period up to"
        aArray[ 3] := STR0015 // "Cancellation sign"
        aArray[ 4] := STR0018 // "Signatory"
        aArray[ 5] := STR0019 // "Full name of the signatory"
    ElseIf nMode == 2
        aArray[ 1] := CToD("//")
        aArray[ 2] := CToD("//")
        aArray[ 3] := DEFAULT_PARAM_VALUE
        aArray[ 4] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 5] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0020 // "Enter or select the start date of the period from the calendar."
        aArray[ 2] := STR0021 // "Enter or select the end date of the period from the calendar."
        aArray[ 3] := STR0022 // "Select a sign of cancellation."
        aArray[ 4] := STR0023 // "Enter or select the signer's position code."
        aArray[ 5] := STR0024 // "Name of the signatory."
    ElseIf nMode == 4
        aArray := Array(2)
        aArray[ 1] := STR0016 // "Yes"
        aArray[ 2] := STR0017 // "No"
    Else
        aArray := {}
    EndIf

Return aArray
