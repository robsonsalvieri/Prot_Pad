#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R14RUS.CH"

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
#DEFINE COUNT_PARAMS_PARAM 6
#DEFINE NAME_OF_PROGRAM "RU07R14RUS"
#DEFINE NAME_OF_PROGRAM_FIL "RU07R14FIL"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R14PAR"
#DEFINE INDEX_PARAM_COMBOBOX "2"
#DEFINE INDEX_PARAM_SIGNER "5"
#DEFINE INDEX_PARAM_SRA 5

/*/
{Protheus.doc} RU07R14()

    Main function of routine print form of EFS-part 1 subsection 1.2 - SZV-EXPERIENCE and subsection 2 - ODV-1.

    @type Function
    @params 
    @author dchizhov
    @since 18.05.2023
    @version 12.1.33
    @return 
    @example RU07R14()
/*/
Function RU07R14()

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
    Local bParamsButton := {|| aParameter := RU07R1401_GetParamWindow()}
    Local bFilterButton := {|| aFilter := RU07R1302_GetFilterWindow(NAME_OF_PROGRAM_FIL)}
    Local bReportButton := {|| MsAguarde({|| RU07R1410_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."

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
    aParameter := RU07R1404_GetStrParam(2)
    // Load value from database for parametr
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI == 4
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
{Protheus.doc} RU07R1410_PrintReport(aFilter, aParam)

    Get data and print report.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 19.05.2023
    @version 12.1.33
    @return .T.
    @example {|| MsAguarde({|| RU07R1410_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."
/*/
Static Function RU07R1410_PrintReport(aFilter, aParam)

    Local oEFSObject As Object
    Local oEFSSZVObj As Object
    Local oSubs12    As Object
    Local oSubs2     As Object
    Local nX         As Numeric
    Local nOrder     As Numeric
    Local nLenght    As Numeric
    Local nYearPer   As Numeric
    Local cTemp      As Character
    Local aSRAArea   As Array
    Local lPageBreak As Logical

    If RU07R1402_IsAcceptButton(aParam)
        lPageBreak := .T.
        aSRAArea := SRA->(GetArea())
        aParam[1] := AllTrim(aParam[1])
        oEFSObject := RUHREFSReport():New(aParam, RU07R1311_GetFilterStr(aFilter), NAME_OF_PROGRAM)
        oEFSObject:oGeneralJson := JsonObject():New()
        If Len(oEFSObject:aPersonnelNumbers) > 0
            oEFSObject:cFilialCode := oEFSObject:aPersonnelNumbers[1, 2]
        ElseIf !Empty(AllTrim(aFilter[1]))
            oEFSObject:cFilialCode := AllTrim(aFilter[1])
        EndIf
        oEFSObject:oGeneralJson["content"] := {}
        MsProcTxt(STR0036) // "Creating a Cover Page"
        oEFSObject:cHeadTitlePage := STR0039 // "Unified form «Information for maintaining individual (personalized) records and information on accrued insurance premiums for compulsory social insurance against industrial accidents and occupational diseases (EFS-1)»"
        oEFSObject:cSignerPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aParam[5])
        oEFSObject:cSignerName := aParam[6]
        oEFSObject:cDate := DToC(Date())
        oEFSObject:AddContent(oEFSObject:GetTitleList())

        oEFSSZVObj := RUHREFSP1S12A2Report():New(aParam)
        cTemp := CValToChar(Len(oEFSObject:aPersonnelNumbers))
        nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
        nLenght := Len(cTemp)
        nYearPer := Val(aParam[1])
        oEFSObject:aPersonnelNumbers := oEFSSZVObj:SortByName(oEFSObject:aPersonnelNumbers)
        For nX := 1 To Len(oEFSObject:aPersonnelNumbers)
            If !Empty(Posicione("SRA", nOrder, oEFSObject:aPersonnelNumbers[nX, 1], "RA_MAT"))
                MsProcTxt(STR0096 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp) // "Filling in general information", "Processed employees:"
                oEFSSZVObj:AddContent(oEFSSZVObj:GetGeneralInfo(.T.))
                If Year(SRA->RA_ADMISSA) <= nYearPer .And. (Empty(SRA->RA_DEMISSA) .Or. Year(SRA->RA_DEMISSA) >= nYearPer .Or. SRA->RA_DEMISSA < SRA->RA_ADMISSA) .And. (aParam[2] <> 2 .Or. SRA->RA_ADMISSA < aParam[4])
                    oSubs12 := oEFSSZVObj:GetSubs12()
                    oEFSSZVObj:AddContent(oSubs12)
                    If aParam[2] <> 2 .And. oEFSSZVObj:SeekSpecialCondCurrent() > 0
                        oSubs2 := oEFSSZVObj:GetSubs2(.F.)
                        oEFSSZVObj:AddContent(oSubs2)
                    EndIf
                    If Len(oSubs12["content"][4]["table"]["body"]) > 3
                        oEFSObject:AddContent(oEFSSZVObj:oGeneralJson)
                    EndIf
                EndIf
                oEFSSZVObj:oGeneralJson["content"] := {}
                lPageBreak := .F.
            EndIf
        Next nX

        MsProcTxt(STR0037) // "Build a PDF"
        oEFSObject:GetViewReport()

        FreeObj(oEFSSZVObj)
        FreeObj(oEFSObject)
        SRA->(RestArea(aSRAArea))
    EndIf

Return .T.

// /********** functions about parametrs *************/

/*/
{Protheus.doc} RU07R1401_GetParamWindow()

    Shows a window for parametr.

    @type Static Function
    @params 
    @author dchizhov
    @since 18.05.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bParamsButton := {|| aParameter := RU07R1401_GetParamWindow()}
/*/
Static Function RU07R1401_GetParamWindow()

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
    Local cWhenField          As Character
    Local nIndex              As Numeric
    Local aItems              As Array
    Local lDateField          As Logical

    cIdUser := "U" + RetCodUsr()

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 
    aParamtrField[1, 2] := RU07R1404_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1404_GetStrParam(2)
    aResultDialog := RU07R1404_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1404_GetStrParam(3)
    aItems := RU07R1404_GetStrParam(4)
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)

    For nI := 1 To COUNT_PARAMS_PARAM
        If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
            nIndex := aResultDialog[nI]
            If nIndex <= Len(aItems) .And. nIndex > 0
                aParamtrField[2, 2, nI] := aItems[nIndex]
                aParamtrField[2, 3, nI] := nIndex
            EndIf
        EndIf
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI == 4
                aParamtrField[2, 2, nI] := SToD(AllTrim(aUserSettings[nI]))
            ElseIf CValToChar(nI) $ INDEX_PARAM_COMBOBOX
                nIndex := Val(aUserSettings[nI])
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
    oDialog:SetValid({|| RU07R1402_IsAcceptButton(aParamtrField[2, 2], aParamtrField[2, 3])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        lDateField := nI == 1 .Or. nI == 3 .Or. nI == 4
        cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
        If lDateField
            cValidate := "{|| RU07R1405_CheckYear(aParamtrField[2, 2, " + CNChar + "], " + CValToChar(nI - Iif(nI > 1, 1, 0)) + Iif(nI == 4, ", aParamtrField[2, 2, 1]", "") + ")}"
        EndIf

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE + 50, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        If cNChar $ INDEX_PARAM_COMBOBOX
            cValidate := "{|o| aParamtrField[2, 3, " + cNChar + "] := o:nAt}"
            aParamtrField[2, 1, nI] := TComboBox():New(-10 + nI * 20, 120, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), aItems, ;
            TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, oScrollBox,, &(cValidate),,,, .T.,,,,,,,,, "aParamtrField[2, 2, " + cNChar + "]")
        Else
            cChange := "{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"
            cWhenField := "{|| (aParamtrField[2, 3, " + INDEX_PARAM_COMBOBOX + "] == 2 .And. " + CNChar + " == 4) .Or. (aParamtrField[2, 3, " + INDEX_PARAM_COMBOBOX + "] > 2 .And. " + CNChar + " == 3)}"
            aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 120, &(cChange), oScrollBox, TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, "@!", Iif(lDateField, &(cValidate), Nil), ;
            0,16777215,,.F.,,.T.,,.F.,Iif(nI == 3 .Or. nI == 4, &(cWhenField), Nil),.F.,.F., Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), CValToChar(nI - 1) $ INDEX_PARAM_SIGNER,,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)
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

        aUserSettings[4] := DToS(aUserSettings[4])

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1402_IsAcceptButton(aUserParam, aUs3)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @params aUs3,       Array, Array of user-entered parameters part for combobox.
    @author dchizhov
    @since 18.05.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example oDialog:SetValid({|| RU07R1402_IsAcceptButton(aParamtrField[2, 2], aParamtrField[2, 3])})
/*/
Static Function RU07R1402_IsAcceptButton(aUserParam, aUs3)

    Local lResultValidation As Logical
    Local cError := ""      As Character
    Local cErrDate := ""    As Character
    Local cMessage := ""    As Character

    DEFAULT aUs3 := aUserParam

    lResultValidation := .T. // Default value.

    cMessage += RU07R1405_CheckYear(aUserParam[1], 1, , .F.)
    cErrDate += Iif(Empty(cMessage), "", cMessage + CRLF)
    cMessage := ""
    If aUs3[2] == 2
        cMessage += RU07R1405_CheckYear(aUserParam[4], 3, aUserParam[1], .F.)
    ElseIf aUs3[2] > 2
        cMessage += RU07R1405_CheckYear(aUserParam[3], 2, , .F.)
    EndIf
    cErrDate += Iif(Empty(cMessage), "", cMessage + CRLF)

    If !Empty(cError) .Or. !Empty(cErrDate)
        lResultValidation := .F.
        cError := cErrDate + Iif(Empty(cError), "", STR0032 + CRLF + cError) // "Parameters not filled:"
        MsgStop(cError, STR0031) // "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU07R1404_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 18.05.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1404_GetStrParam(2)
/*/
Static Function RU07R1404_GetStrParam(nMode)

    Local aArray  As Array

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[ 1] := STR0013 // "Reporting year"
        aArray[ 2] := STR0014 // "Information type"
        aArray[ 3] := STR0015 // "Adjustable (cancellable) period"
        aArray[ 4] := STR0016 // "Retirement date"
        aArray[ 5] := STR0017 // "Signatory"
        aArray[ 6] := STR0018 // "Full name of the signatory"
    ElseIf nMode == 2
        aArray[ 1] := Space(4)
        aArray[ 2] := 1
        aArray[ 3] := Space(4)
        aArray[ 4] := CToD("//")
        aArray[ 5] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 6] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0019 // "Enter the reporting year in YYYY format."
        aArray[ 2] := STR0020 // "Select the type of information. If the type is Corrective or Cancel, enter the period to be corrected/cancelled. If the type is Assignment of pension - enter the date of retirement."
        aArray[ 3] := STR0021 // "Enter the corrected (cancelled) period. Entered only when an appropriate value is selected in the 'Detail Type' parameter."
        aArray[ 4] := STR0022 // "Enter your retirement date. Entered only when an appropriate value is selected in the 'Detail Type' parameter."
        aArray[ 5] := STR0023 // "Enter or select the signer's position code."
        aArray[ 6] := STR0024 // "Name of the signatory."
    ElseIf nMode == 4
        aArray := Array(4)
        aArray[ 1] := STR0025 // "Initial"
        aArray[ 2] := STR0026 // "Appointment of a pension"
        aArray[ 3] := STR0027 // "Corrective"
        aArray[ 4] := STR0028 // "Canceling"
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R1405_CheckYear(xValue, nModo, cValue, lView)

    Check value for Year >= 2023.

    @type Function
    @params xValue, Date or Character, Checked value.
    @params nModo,  Numeric,   Modo (1 - Reporting year, 2 - Adjustable (cancellable) period, 3 - Retirement date.
    @params cValue, Character, Value For a compared.
    @params lView,  Logical,   Show error-message.
    @author dchizhov
    @since 18.05.2023
    @version 12.1.33
    @return xResult, Logical or Character, Result of verification.
    @example RU07R1405_CheckYear(xValue, nModo)
/*/
Function RU07R1405_CheckYear(xValue, nModo, cValue, lView)

    Local xResult

    DEFAULT nModo = 1
    DEFAULT xValue = CToD("//")
    DEFAULT cValue := ""
    DEFAULT lView := .T.

    xResult := .F.

    If nModo == 1 .And. ValType(xValue) == "C"
        If Val(xValue) < 2023 .And. !Empty(AllTrim(xValue))
            If lView
                MsgStop(STR0038, STR0031) // "Reporting year cannot be less than 2023", "Error"
            Else
                xResult := STR0038 // "Reporting year cannot be less than 2023"
            EndIf
        Else
            xResult := .T.
        EndIf
    ElseIf nModo == 2 .And. ValType(xValue) == "C"
        If Val(xValue) < 2023 .And. !Empty(AllTrim(xValue))
            If lView
                MsgStop(STR0029, STR0031) // "Period must be at least 2023", "Error"
            Else
                xResult := STR0029 // "Period must be at least 2023"
            EndIf
        Else
            xResult := .T.
        EndIf
    ElseIf nModo == 3 .And. ValType(xValue) == "D"
        If Year(xValue) <> Val(cValue) .And. !Empty(xValue) .And. !Empty(AllTrim(cValue))
            If lView
                MsgStop(STR0030, STR0031) // "The date must not be outside the reporting year", "Error"
            Else
                xResult := STR0030 // "The date must not be outside the reporting year"
            EndIf
        Else
            xResult := .T.
        EndIf
    EndIf

    If !lView .And. ValType(xResult) == "L"
        xResult := ""
    EndIf

Return xResult
