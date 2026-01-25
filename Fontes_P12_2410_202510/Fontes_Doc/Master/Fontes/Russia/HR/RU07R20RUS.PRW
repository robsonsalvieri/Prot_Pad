#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R20RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

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
#DEFINE COUNT_PARAMS_PARAM 3
#DEFINE NAME_OF_PROGRAM "RU07R20RUS"
#DEFINE NAME_OF_PROGRAM_FIL "RU07R20FIL"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R20PAR"
#DEFINE INDEX_PARAM_COMBOBOX "1"
#DEFINE INDEX_PARAM_SIGNER "2"
#DEFINE INDEX_PARAM_SRA 7

/*/
{Protheus.doc} RU07R20RUS()

    Main function of routine print form of STD-R.

    @type Function
    @params 
    @author alysenko
    @since 14.06.2023
    @version 12.1.33
    @return 
    @example RU07R20RUS()
/*/
Function RU07R20RUS()

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
    Local bParamsButton := {|| aParameter := RU07R2001_GetParamWindow(aParameter)}
    Local bFilterButton := {|| aFilter := RU07R2005_GetFilterWindow(NAME_OF_PROGRAM_FIL)}
    Local bReportButton := {|| MsAguarde({|| RU07R2010_PrintReport(aFilter, aParameter)}, STR0007, STR0008)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    cIdUser := "U" + RetCodUsr()
    // Load default value for filter
    aFilter := RU07R2004_GetStrFilter(2)
    // Load value from database for filter
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, NAME_OF_PROGRAM_FIL)
    For nI := 1 To COUNT_PARAMS_FILTER
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aFilter[nI] := SubStr(aUserSettings[nI], 1, Len(aFilter[nI]))
        EndIf
    Next nI
    If !lSeeAll
        aFilter[3] := xFilial("SRA")
    EndIf
    aFilter[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilter[INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    // Load default value for parametr
    aParameter := RU07R2003_GetStrParam(2)
    // Load value from database for parametr
    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI == 1
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
    DEFINE MSDIALOG oDlg TITLE STR0001 From 0,0 TO (oSize:aWindSize[3] * 0.4), (oSize:aWindSize[3] * 1.1) OF oMainWnd PIXEL // "Information about the work activity provided to the employee by the employer"

        @oSize:GetDimension("CABECALHO", "LININI") + 3, oSize:GetDimension("CABECALHO","COLINI") + 3 GROUP oGroup To oSize:GetDimension("CABECALHO", "LINEND") * 0.49471, oSize:GetDimension("CABECALHO", "COLEND") * 0.5  LABEL STR0006 OF oDlg PIXEL // "Description".
        oGroup:oFont:=oFont
        @oSize:GetDimension("CABECALHO", "LININI") + 20, oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY STR0004 + CRLF + STR0001 ; // "Report", "Information about the work activity provided to the employee by the employer"
            SIZE oSize:GetDimension("CABECALHO", "COLEND") * 0.49471, oSize:GetDimension("CABECALHO", "LINEND") * 0.35 Of oDlg Pixel

        oFilterButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  15, STR0002, NIL, bFilterButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Filter".
        oPergunteButton := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  60, STR0003, NIL, bParamsButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Parameters".
        oReportButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 105, STR0004, NIL, bReportButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Report".
        oExitButton     := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 320, STR0005, NIL, bExitButton,   BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Exit".

    ACTIVATE MSDIALOG oDlg CENTERED

Return


/*/
{Protheus.doc} RU07R2010_PrintReport(aFilter, aParam)

    Get data and print report.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @params aParams, Array, Parameters entered by the user.
    @author alysenko
    @since 19.05.2023
    @version 12.1.33
    @return .T.
    @example {|| MsAguarde({|| RU07R2010_PrintReport(aFilter, aParameter)}, STR0010, STR0011)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."
/*/
Static Function RU07R2010_PrintReport(aFilter, aParam)

    Local oSTDRObject   As Object
    Local oSubs1_1     As Object
    Local nX           As Numeric
    Local nOrder       As Numeric
    Local nLenght      As Numeric
    Local cTemp        As Character
    Local aSRAArea     As Array
    Local lPageBreak   As Logical

    If RU07R2002_IsAcceptButton(aParam)
        lPageBreak := .T.
        aSRAArea := SRA->(GetArea())
        oSTDRObject := RuRHSTDRForm():New(aParam, aFilter, RU07R2006_GetFilterStr(aFilter), NAME_OF_PROGRAM)
        oSTDRObject:oGeneralJson := JsonObject():New()
        If Len(oSTDRObject:aPersonnelNumbers) > 0
            oSTDRObject:cFilialCode := oSTDRObject:aPersonnelNumbers[1, 2]
        ElseIf !Empty(AllTrim(aFilter[1]))
            oSTDRObject:cFilialCode := AllTrim(aFilter[1])
        EndIf
        oSTDRObject:oGeneralJson["content"] := {}
        oSTDRObject:cHeadTitlePage := STR0001 // "Information about the work activity provided to the employee by the employer"
        oSTDRObject:cSignerPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, aParam[2])
        oSTDRObject:cSignerName := aParam[3]
        oSTDRObject:cDate := DToC(aParam[1])

        cTemp := CValToChar(Len(oSTDRObject:aPersonnelNumbers))
        nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
        nLenght := Len(cTemp)
        oSTDRObject:aPersonnelNumbers := oSTDRObject:SortByName(oSTDRObject:aPersonnelNumbers)
        For nX := 1 To Len(oSTDRObject:aPersonnelNumbers)
            lPageBreak := Iif( nX == 1, .F., .T. )
            If !Empty(Posicione("SRA", nOrder, oSTDRObject:aPersonnelNumbers[nX, 1], "RA_MAT"))
                MsProcTxt(STR0092 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp) // "Processed employees:"
                oTitle   := oSTDRObject:GetTitle()
                oSubs1_1 := oSTDRObject:Get1Part()
                oTabs1_1 := oSTDRObject:Get1Tab()
                oSubs2_1 := oSTDRObject:Get2Part()
                oSubs2_2 := oSTDRObject:Get2Data()

                If Len(oTabs1_1["content"][1]["table"]["body"]) > 3
                    oSTDRObject:AddContent(oSTDRObject:GetTitle(lPageBreak))
                    oSTDRObject:AddContent(oSTDRObject:GetWorkerInfo())
                    oSTDRObject:AddContent(oSTDRObject:GetEmployerInfo())
                    oSTDRObject:AddContent(oSubs1_1)
                    oSTDRObject:AddContent(oTabs1_1)
                    oSTDRObject:AddContent(oSubs2_1)
                    oSTDRObject:AddContent(oSubs2_2)
                EndIf
            EndIf
        Next nX

        MsProcTxt(STR0093) // "Build a PDF"
        oSTDRObject:GetViewReport()
        FreeObj(oSTDRObject)
        SRA->(RestArea(aSRAArea))
    EndIf

Return .T.


/*/
{Protheus.doc} RU07R2001_GetParamWindow(aParamCur)

    Shows a window for parametr.

    @type Static Function
    @params aParamCur, Array,   Current array of parametr.
    @author alysenko
    @since 14.06.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bParamsButton := {|| aParameter := RU07R2001_GetParamWindow(aParameter)}
/*/
Static Function RU07R2001_GetParamWindow(aParamCur)

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
    Local lCurParam           As Logical

    DEFAULT aParamCur := {}

    cIdUser := "U" + RetCodUsr()
    lCurParam := Len(aParamCur) > 0

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 
    aParamtrField[1, 2] := RU07R2003_GetStrParam(1)
    aParamtrField[2, 2] := RU07R2003_GetStrParam(2)
    aResultDialog := RU07R2003_GetStrParam(2)
    aParamtrField[1, 3] := RU07R2003_GetStrParam(3)
    If lCurParam
        aUserSettings := AClone(aParamCur)
    Else
        aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR)
    EndIf

    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            If nI == 1
                aParamtrField[2, 2, nI] := aUserSettings[nI]
            Else
                aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            EndIf
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0003) // "Parametrs"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R2002_IsAcceptButton(aParamtrField[2, 2])})

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

        cChange := "{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"
        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 120, &(cChange), oScrollBox, TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, "@!",, ;
        0,16777215,,.F.,,.T.,,.F.,,.F.,.F., Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), CValToChar(nI - 1) $ INDEX_PARAM_SIGNER,,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)

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
            aUserSettings[nI] := aParamtrField[2, 2, nI]
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        Next nI

        aUserSettings[1] := DToS(aUserSettings[1])

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, NAME_OF_PROGRAM_PAR, aUserSettings)

    EndIf

Return aResultDialog


/*/
{Protheus.doc} RU07R2002_IsAcceptButton(aUserParam)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author alysenko
    @since 14.06.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag  that need parameters are filled.
    @example oDialog:SetValid({|| RU07R2002_IsAcceptButton(aParamtrField[2, 2])})
/*/
Static Function RU07R2002_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    DEFAULT aUs3 := aUserParam
    lResultValidation := .T. // Default value.

    If !Empty(cError)
        lResultValidation := .F.
        cError := Iif(Empty(cError), "", STR0091 + CRLF + cError) // "Parameters not filled:"
        MsgStop(cError, STR0090) // "Error"
    EndIf

Return lResultValidation


/*/
{Protheus.doc} RU07R2003_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in parameters-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help.
    @author alysenko
    @since 14.06.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R2003_GetStrParam(2)
/*/
Static Function RU07R2003_GetStrParam(nMode)

    Local aArray  As Array

    DEFAULT nMode := 1
    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[ 1] := STR0023 // "Statement from"
        aArray[ 2] := STR0024 // "Signatory"
        aArray[ 3] := STR0025 // "Full name of the signatory"
    ElseIf nMode == 2
        aArray[ 1] := CToD("//")
        aArray[ 2] := Space(TamSX3("RCH_PER")[1])
        aArray[ 3] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0033 // "Enter the date of the statement."
        aArray[ 2] := STR0034 // "Enter the signer."
        aArray[ 3] := STR0035 // "Surname First Name Patronymic of the signatory."
    Else
        aArray := {}
    EndIf

Return aArray


/*/
{Protheus.doc} RU07R2004_GetStrFilter(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for Filters; 2 - empty Filters; 3 - Array of help.
    @author alysenko
    @since 15.05.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty Filters or title for Filters.
    @example aParamtrField[2, 2] := RU07R2004_GetStrFilter(2)
/*/
Static Function RU07R2004_GetStrFilter(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_FILTER)

    If nMode == 1
        aArray[ 1] := STR0016 // "Structure layer"
        aArray[ 2] := STR0017 // "Employer"
        aArray[ 3] := STR0018 // "Branch from"
        aArray[ 4] := STR0019 // "Branch before"
        aArray[ 5] := STR0020 // "Department from"
        aArray[ 6] := STR0021 // "Department before"
        aArray[ 7] := STR0022 // "TN"
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        If lSeeAll
            aArray[ 3] := aArray[ 4] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[ 3] := xFilial("SRA")
            aArray[ 4] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        EndIf
        aArray[ 1] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 5] := Space(TamSX3("RA_CC")[1])
        aArray[ 6] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 7] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0026 // "Select the structure layer."
        aArray[ 2] := STR0027 // "Select an employer."
        aArray[ 3] := STR0028 // "Select the start branch."
        aArray[ 4] := STR0029 // "Select the final branch."
        aArray[ 5] := STR0030 // "Select the start department."
        aArray[ 6] := STR0031 // "Select the final department."
        aArray[ 7] := STR0032 // "Select the employee's registration number."
    Else
        aArray := {}
    EndIf

Return aArray


/*/
{Protheus.doc} F3XX8StrCompany(nMode)

    This function of selecting the level of the structure and the employer in the filters to the report.

    @type Static Function
    @params nMode, Numeric, 1 - Level of Structure; 2 - Employer.
    @author alysenko
    @since 15.05.2023
    @version 12.1.33
    @return cRet, Character, Character selected by the user in one of two fields.
    @example oButtonXX8Empl := TButton():New(30, 250, "...", oScrollBox, {|| aFilterField[2, 2, 2] := F3XX8StrCompany(2)}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
/*/
Function F3XX8StrCompany(nMode)

Local aArea	:= GetArea() As Array 
Local cTitle := Iif(IsInCallStack("RU07R20RUS"), STR0017, StaticCall(RU07R22RUS, RU07R2202_StrSOZLPrint, 123))// Employer / Policyholder
Local aCpos     := {}    As Array    // Array with data
Local lRet      := .T. 	 As Logical	 // Return Array of the selected option
Local oDlgF3             As Object   // Window Object
Local oLbx               As Object   // List box object
Local aRet		:= {}    As Array
Local aStrXXG	:= {STR0041, STR0042, STR0043, STR0044} As Array
Local cRet		:= ""    As Character
Local cfilter := "1"	 As Character

DEFAULT nMode := 1

DbSelectArea("XX8")
XX8->(dbSetOrder(1))
XX8->(dbGoTop())

// Selecting the structure level
Pergunte("CR680ADR", nMode == 1, STR0016)

If mv_par01 == 1
    cfilter := "0"
ElseIf mv_par01 == 2
    cfilter := "1"
ElseIf mv_par01 == 3
    cfilter := "2"
ElseIf mv_par01 == 4
    cfilter := "3"
EndIf

// Filling in the array of employers (Groups of companies, Companies, Business units, Branches)
// depending on the choice of the level of the structure.
While !XX8->(Eof())
    If XX8_TIPO == cfilter
        aAdd( aCpos, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
    EndIf
    XX8->(DbSkip())
Enddo

//Employer Selection Window
If Len( aCpos ) > 0 .AND. nMode == 2
	
	DEFINE MSDIALOG oDlgf3 TITLE cTitle FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0036, STR0037, STR0038, STR0039, STR0040 SIZE 230,95 OF oDlgf3 PIXEL	
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3], aCpos[oLbx:nAt,4], aCpos[oLbx:nAt,5]}}
	   oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]})  ENABLE OF oDlgF3
	ACTIVATE MSDIALOG oDlgF3 CENTER
		
EndIf

// The return depends on the gender (Level of Structure or employer) of the value selected by the user.
If lRet .AND. (!Empty(aCpos) .OR. !Empty(aRet))
    If nMode == 1 .AND. !Empty(aCpos)
	    cRet := aStrXXG[mv_par01]
    ElseIf nMode == 2 .AND. !Empty(aRet)
        cRet := aRet[5]
    EndIf
ElseIf lRet .AND. (Empty(aCpos) .AND. Empty(aRet))
    cRet := ''
EndIf

RestArea(aArea)

Return cRet


/*/
{Protheus.doc} RU07R1302_GetFilterWindow(cNameFil)

    Shows a window for filter.

    @type Static Function
    @params cNameFil, Character, Name of programm filter
    @author alysenko
    @since 15.05.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example bFilterButton := {|| aFilter := RU07R1302_GetFilterWindow()}
/*/
Function RU07R2005_GetFilterWindow(cNameFil)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aFilterField        As Array
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

    aFilterField := {{Array(COUNT_PARAMS_FILTER), , }, {Array(COUNT_PARAMS_FILTER), }} // fields and Title for it. 

    aFilterField[1, 2] := RU07R2004_GetStrFilter(1)
    aFilterField[2, 2] := RU07R2004_GetStrFilter(2)
    aResultDialog := RU07R2004_GetStrFilter(2)
    aFilterField[1, 3] := RU07R2004_GetStrFilter(3)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil)

    For nI := 1 To COUNT_PARAMS_FILTER
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aFilterField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aFilterField[2, 2, nI]))
            aResultDialog[nI] := aFilterField[2, 2, nI]
        EndIf
    Next nI
    aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilterField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    If !lSeeAll
        aResultDialog[1] := aFilterField[2, 2, 3] := xFilial("SRA")
        aResultDialog[2] := aFilterField[2, 2, 4] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0002) // "Filter"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({||RU07R2002_IsAcceptButton(aFilterField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_FILTER

        cNChar := CValToChar(nI)

        // Make lines for parametr
        aFilterField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aFilterField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aFilterField[1, 1, nI]:lWordWrap := .F.

        aFilterField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aFilterField[2, 2, " + CNChar + "], aFilterField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
        TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,, Iif(nI < 3, !lSeeAll, .F.),,, "aFilterField[2, 2, " + cNChar + "]",,,, .T., .F.)


        aFilterField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aFilterField[1, 3, " + CNChar + "]}, 1, {aFilterField[1, 3, " + CNChar + "]}, 1)}")
        aFilterField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aFilterField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    oButtonSRAList := TButton():New(130, 250, "...", oScrollBox, {|| aFilterField[2, 2, 7] := Padr(RU16R0104_GetSraList(aFilterField[2, 2, 7]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonXX8Type := TButton():New(10,  250, "...", oScrollBox, {|| aFilterField[2, 2, 1] := F3XX8StrCompany(1), MsgAlert(STR0094, STR0002), aFilterField[2, 2, 2] := F3XX8StrCompany(2)}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonXX8Empl := TButton():New(30,  250, "...", oScrollBox, {|| aFilterField[2, 2, 2] := F3XX8StrCompany(2)}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    aFilterField[2, 1, 3]:cF3 := "XM0"
    aFilterField[2, 1, 4]:cF3 := "XM0"
    aFilterField[2, 1, 5]:cF3 := "CTT"
    aFilterField[2, 1, 6]:cF3 := "CTT"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aFilterField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_FILTER
            aResultDialog[nI] := aFilterField[2, 2, nI]
            aUserSettings[nI] := aFilterField[2, 2, nI]
        Next nI

        aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aFilterField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_FILTER, cNameFil, aUserSettings)

    EndIf

Return aResultDialog


/*/
{Protheus.doc} RU07R2006_GetFilterStr(aFilter)

    Get string for sql-query by filter.

    @type Static Function
    @params aFilter, Array, Filter entered by the user.
    @author alysenko
    @since 15.05.2023
    @version 12.1.33
    @return cFilter, Character, Filter str for SQL-request
    @example oSTDRObject := RuRHSTDRForm():New(aParam, aFilter, RU07R2006_GetFilterStr(aFilter), NAME_OF_PROGRAM)
/*/
Function RU07R2006_GetFilterStr(aFilter)

    Local cFilter As Character
    Local nCount  As Numeric
    Local nX      As Numeric

    nCount := Len(aFilter[INDEX_PARAM_SRA])
    cFilter := ""
    
    cFilter += " (RA_FILIAL >= '" + aFilter[3] + "')"
    cFilter += " AND (RA_FILIAL <= '" + Iif(Empty(aFilter[4]), Replicate("Z", TamSX3("RA_FILIAL")[1]), aFilter[4]) + "')"
    cFilter += " AND RA_CATFUNC != 'A' "
    cFilter += " AND (RA_CC >= '" + aFilter[5] + "')"
    cFilter += " AND (RA_CC <= '" + Iif(Empty(aFilter[6]), Replicate("Z", TamSX3("RA_CC")[1]), aFilter[6]) + "')"

    If nCount > 0
        cFilter += " AND RA_MAT IN ("
        For nX := 1 To nCount
            cFilter += "'" + aFilter[7, nX] + "'" + Iif(nX < nCount, ", ", ")")
        Next nX
    EndIf

Return cFilter
