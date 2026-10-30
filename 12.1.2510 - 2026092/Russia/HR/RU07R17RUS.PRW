#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RU07R17RUS.CH"

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
#DEFINE SRA_STR_MAX_LENGHT 250
#DEFINE COUNT_PARAMS_PARAM 14
#DEFINE NAME_OF_PROGRAM "RU07R17RUS"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R17PAR"
#DEFINE INDEX_PARAM_COMBOBOX "1"
#DEFINE INDEX_PARAM_SIGNER "3"
#DEFINE INDEX_PARAM_SRA 13

#DEFINE EXCLUDE_FROM_PAYMENT "395"
#DEFINE NDFL_ADI "412"
#DEFINE NDFL_FOL "413"
#DEFINE PREPAID_EXPENSE "872"
#DEFINE DEBT "395"
#DEFINE GRAND_TOTAL "870"
#DEFINE ADVANCE_WITHHELD "410"
#DEFINE DEBT_PRE_MONTH "446"
#DEFINE CODE_PREPAYMENT "250"

#DEFINE INDEX_PARAM_REVENUE "1"
#DEFINE INDEX_PARAM_DISCOUNT "2"



/*/
{Protheus.doc} RU07R17()

    Main function of report by average payment for holiday.

    @type Function
    @params 
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return 
    @example RU07R17()
/*/
Function RU07R17()

    Local aParameter As Array

    // ToExcelFile()
    aParameter := RU07R1702_GetParametr(NAME_OF_PROGRAM_PAR)

    If Len(aParameter) > 0
        aParameter[ 6] := Iif(AllTrim(aParameter[ 6]) == "", Replicate("Z", TamSX3("RA_FILIAL")[1]), aParameter[ 6])
        aParameter[ 8] := Iif(AllTrim(aParameter[ 8]) == "", Replicate("Z", TamSX3("RA_CC")[1]), aParameter[ 8])
        aParameter[10] := Iif(AllTrim(aParameter[10]) == "", Replicate("Z", TamSX3("RA_DEPTO")[1]), aParameter[10])
        aParameter[12] := Iif(AllTrim(aParameter[10]) == "", Replicate("Z", TamSX3("RCJ_CODIGO")[1]), aParameter[12])
        MsAguarde({|| RU07R1705_PrintReport(aParameter)}, STR0073, STR0074) // "Please, wait", "Data collection"
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R1702_GetParametr(cNamePar)

    Shows a window for parametr.

    @type Function
    @params cNamePar, Character, Name of programm parametr
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return aResultDialog, Array, Array of current parametr.
    @example aParameter := RU07R1702_GetParametr(NAME_OF_PROGRAM_PAR)
/*/
Function RU07R1702_GetParametr(cNamePar)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local aItems := {}        As Array
    Local cNChar              As Character
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character
    Local lSeeAll             As Logical
    Local oGetPath As Object

    Default cNamePar := NAME_OF_PROGRAM_PAR

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1704_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1704_GetStrParam(2)
    aResultDialog := RU07R1704_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1704_GetStrParam(3)
    aItems := RU07R1704_GetStrParam(4)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar)

    For nI := 1 To COUNT_PARAMS_PARAM
        If CValToChar(nI) $ INDEX_PARAM_COMBOBOX
            nIndex := aResultDialog[nI]
            If nIndex <= Len(aItems) .And. nIndex > 0
                aParamtrField[2, 2, nI] := aItems[nIndex]
                aParamtrField[2, 3, nI] := nIndex
            EndIf
        EndIf
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
            aResultDialog[nI] := Iif(CValToChar(nI) $ INDEX_PARAM_COMBOBOX, aParamtrField[2, 3, nI], aParamtrField[2, 2, nI])
        EndIf
    Next nI
    aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    If !lSeeAll
        aResultDialog[5] := aResultDialog[6] := aParamtrField[2, 2, 5] := aParamtrField[2, 2, 6] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0001) // "Form T-51. Payslip"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1703_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    //Self:lExecMacro := .T.
        // Make line to type of report. (Base or group (a-type))
        //oGroupReport := TCheckBox():New(10, 70, cTyepesOfReport, {|u| If(PCount() == 0, lGroupReport, lGroupReport := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE,, {|| ::UpdateParam(oGetTemplate, oGetPath, oGetSignature, oGetFullNameSignature, oGetSRAList, lGroupReport)},, /*{|| MsgInfo("2", "2")}*/,,,,.T.,,, /*{|| MsgInfo("3", "3")}*/)

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        If cNChar $ INDEX_PARAM_SIGNER
            cValidate := "{|| Iif(!RU07R1305_GetFullNameOfSignature(aParamtrField[2, 2, " + CNChar + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), &('aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := Space(1), .F.'), .T.)}"
        ElseIf cNChar $ "2"
            cValidate := "{|| Iif(Len(AllTrim(aParamtrField[2, 2, " + CNChar + "])) < 6, (MsgInfo('" + STR0028 + "'), .F.), .T.)}" // "Set Period"
        EndIf
        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        If cNChar $ INDEX_PARAM_COMBOBOX
            cValidate := "{|o| aParamtrField[2, 3, " + cNChar + "] := o:nAt}"
            aParamtrField[2, 1, nI] := TComboBox():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), aItems, ;
            TEXTBOX_WIDTH_SIZE - 50, TEXTBOX_HEIGHT_SIZE, oScrollBox,, &(cValidate),,,, .T.,,,,,,,,, "aParamtrField[2, 2, " + cNChar + "]")
        Else
            aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
            TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",Iif(cNChar $ "2", &(cValidate), Nil), 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,Iif(cNChar $ INDEX_PARAM_SIGNER, &(cValidate), Nil), Iif(cNChar $ "56", !lSeeAll, cNChar $ "4"),,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)
        EndIf

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    oButtonSRAList := TButton():New(250, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 13] := Padr(RU16R0104_GetSraList(aParamtrField[2, 2, 13]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    //oButtonResultPath := TButton():New(30 + nShiftY, 260, "...", oGridLayout, {|| cResultPath := Padr(cGetFile(STR0004 + "|*.doc|" + STR0006 +"|*.*", STR0003, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonPath := TButton():New(270, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 14] := Padr(cGetFile(STR0094 + "|*.*", STR0003, 1, 'C:\', .T., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), 250, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    
    //oGetPath := TGet():New(30 + nShiftY, 70, {|u| If( PCount() == 0, cResultPath, cResultPath := u)}, oGridLayout, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,, "cResultPath",,,,.F.)
    //oButtonResultPath := TButton():New(30 + nShiftY, 260, "...", oGridLayout, {|| cResultPath := Padr(cGetFile(STR0004 + "|*.doc|" + STR0006 +"|*.*", STR0003, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    
    If lSeeAll
        aParamtrField[2, 1, 5]:cF3 := "XM0"
        aParamtrField[2, 1, 6]:cF3 := "XM0"
    EndIf
    aParamtrField[2, 1, Val(INDEX_PARAM_SIGNER)]:cF3 := "SQ3"
    aParamtrField[2, 1, 7]:cF3 := "CTT"
    aParamtrField[2, 1, 8]:cF3 := "CTT"
    aParamtrField[2, 1,  9]:cF3 := "SQB"
    aParamtrField[2, 1, 10]:cF3 := "SQB"
    aParamtrField[2, 1, 11]:cF3 := "RCJ"
    aParamtrField[2, 1, 12]:cF3 := "RCJ"

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

        aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar, aUserSettings)
    Else
        aResultDialog := {}
    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU07R1703_IsAcceptButton(aParam)

    Check parameter.

    @type Function
    @params aParam, Array, Array of parameter wich entering the user.
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return lResult, Logical, Param valid or no valid.
    @example aParameter := RU07R1703_IsAcceptButton(NAME_OF_PROGRAM_PAR)
/*/
Function RU07R1703_IsAcceptButton(aParam)

    Local lResult As Logical
    Local cError  As Character

    lResult := .T.
    cError := ""
    cError := Iif(AllTrim(aParam[2]) == "", STR0028, "") // "Set Period"
    If Len(cError) > 0
        lResult := .F.
        MsgStop(cError, STR0029) // "Error"
    EndIf

Return lResult

/*/
{Protheus.doc} RU07R1704_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1704_GetStrParam(2)
/*/
Static Function RU07R1704_GetStrParam(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[ 1] := STR0002 // "Sorting"
        aArray[ 2] := STR0007 // "Reporting period"
        aArray[ 3] := STR0008 // "Signatory"
        aArray[ 4] := STR0009 // "Full name of the signatory"
        aArray[ 5] := STR0010 // "Branch from"
        aArray[ 6] := STR0011 // "Branch before"
        aArray[ 7] := STR0012 // "Cost center from"
        aArray[ 8] := STR0013 // "cost center to"
        aArray[ 9] := STR0014 // "Division from"
        aArray[10] := STR0015 // "Division before"
        aArray[11] := STR0075 // "Process code from"
        aArray[12] := STR0076 // "Process code to"
        aArray[13] := STR0016 // "TN"
        aArray[14] := STR0094 // "Path
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        aArray[ 1] := 1
        aArray[ 2] := Space(6)
        aArray[ 3] := Space(TamSX3("RA_CARGO")[1])
        aArray[ 4] := Space(TEXTBOX_MAX_LENGTH)
        If lSeeAll
            aArray[ 5] := Space(TamSX3("RA_FILIAL")[1])
            aArray[ 6] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[ 5] := aArray[ 6] := xFilial("SRA")
        EndIf
        aArray[ 7] := Space(TamSX3("RA_CC")[1])
        aArray[ 8] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 9] := Space(TamSX3("RA_DEPTO")[1])
        aArray[10] := Replicate("Z", TamSX3("RA_DEPTO")[1])
        aArray[11] := Space(TamSX3("RCJ_CODIGO")[1])
        aArray[12] := Replicate("Z", TamSX3("RCJ_CODIGO")[1])
        aArray[13] := Space(TEXTBOX_MAX_LENGTH)
        aArray[14] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0017 // "Choose how to sort data"
        aArray[ 2] := STR0018 // "Enter the data generation period"
        aArray[ 3] := STR0019 // "Select the position of the signer from the directory"
        aArray[ 4] := STR0020 // "Full name of the signatory"
        aArray[ 5] := STR0021 // "Enter or select branch start code to filter data"
        aArray[ 6] := STR0022 // "Enter or select the final branch code to filter data"
        aArray[ 7] := STR0023 // "Enter or select cost center start code to filter data"
        aArray[ 8] := STR0024 // "Enter or select a final cost center code to filter data"
        aArray[ 9] := STR0025 // "Enter or select the starting department to filter data"
        aArray[10] := STR0026 // "Enter or select the final department to filter data"
        aArray[11] := STR0077 // "Enter or select a process start ID to filter data"
        aArray[12] := STR0078 // "Enter or select the final process ID to filter data"
        aArray[13] := STR0027 // "Enter or select an employee registration code to filter the data. You can specify multiple values separated by ';'. To specify sequential data ranges, use a hyphen (1-3); to specify non-consecutive data, use a semicolon (3;5;1)."
        aArray[14] := STR0099 // "Enter or select a path to save the report" 
    ElseIf nMode == 4
        aArray := Array(4)
        aArray[ 1] := STR0003 // "Full name"
        aArray[ 2] := STR0004 // "TN"
        aArray[ 3] := STR0005 // "Department"
        aArray[ 4] := STR0006 // "cost center"
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R1705_PrintReport(aParameter)

    This function run getting data and print data into pdf.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return 
    @example MsAguarde({|| RU07R1705_PrintReport(aParameter)}, STR0073, STR0074) // "Please, wait", "Data collection"
/*/
Static Function RU07R1705_PrintReport(aParameter)

    Local oJson       As Object
    Local oJsonTemp   As Object
    Local oOptions    As Object
    Local cJson       As Character
    Local cOptions    As Character
    Local aDataForTit As Array
    Local aDataForTab As Array

    aDataForTit := RU07R1706_GetDataForTitle(aParameter)

    aDataForTab := RU07R1710_GetDataSRD(aParameter)


    // oOptions := Ru99x50_01_GetOptionsTemplate()
    // oOptions['showSidebarButton'] := .F.
    // oJson := GetTemplatate()
    
    // MsProcTxt(STR0033) // "Create a cover page"
    // oJsonTemp := RU07R1709_CreateCoverPage(aDataForTit)
    // AEval(oJsonTemp["content"], {|X| Aadd(oJson["content"], X)})
    // oJsonTemp := Nil
    // MsProcTxt(STR0034) // "Building a PDF"
    // MsProcTxt(STR0032) // "Sending to PDF Maker"

    // cJson := oJson:ToJson()
    // cOptions := oOptions:ToJson()

    // ru99x50_pdfmakeForm(cJson, 'windows-1251', cOptions, 'RU07R17')
    // FreeObj(oJson)
    // FreeObj(oOptions)

Return .T.

/*/
{Protheus.doc} RU07R1706_GetStrParam(aParameter)

    This function get data for title list.

    @type Static Function
    @params aParameter, Array, Array with parametr wich entering by user.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return aData, Array, Data for Title list
    @example aDataForTit := RU07R1706_GetDataForTitle(aParameter)
/*/
Static Function RU07R1706_GetDataForTitle(aParameter)

    Local aData As Array
    Local aGCBR As Array
    Local aGBBR As Array
    Local aArea As Array
    Local aSM0a As Array
    Local aRFQa As Array
    Local aRCJa As Array
    Local cFil1 As Character
    Local cFil2 As Character
    Local cStrF As Character
    Local cDept As Chaarcter
    Local cCode As Character
    Local nI    As Numeric
    Local cAliasQ      As Character
    Local nLenShare    As Numeric
    Local nLenCUnit    As Numeric
    Local nLenCCompany As Numeric

    aArea := GetArea()
    aSM0a := SM0->(GetArea())
    aRFQa := RFQ->(GetArea())
    aRCJa := RCJ->(GetArea())
    cFil1 := Replicate("Z", TamSX3("RA_FILIAL")[1])
    cFil2 := Space(TamSX3("RA_FILIAL")[1])
    nLenShare := 0
    nLenCUnit := 0
    nLenCCompany := 0
    cDept := ""
    aGBBR := {{"BR_FULLNAM", ""}, {"BR_OKPO", ""}}
    DbSelectArea("SM0")
    SM0->(DbGoTop())
    While !(SM0->(EOF()))
        If cFil1 > SM0->M0_CODFIL .And. SM0->M0_CODFIL > aParameter[5]
            cFil1 := SM0->M0_CODFIL
        ElseIf cFil2 < SM0->M0_CODFIL .And. SM0->M0_CODFIL < aParameter[6]
            cFil2 := SM0->M0_CODFIL
        EndIf
        SM0->(DbSkip())
    EndDo
    If cFil1 <> cFil2
        cStrF := RU07R1707_GetStructVodeF(cEmpAnt) 
        For nI := 1 To Len(cStrF)
            Do Case 
                Case SubStr(cStrF, nI, 1) == "E"
                    nLenCCompany += 1
                Case SubStr(cStrF, nI, 1) == "U"
                    nLenCUnit += 1
            EndCase
        Next nI
        nLenShare := 0
        For nI := 1 To Len(cFil1)
            If SubStr(cFil1, nI, 1) == SubStr(cFil2, nI, 1)
                nLenShare += 1
            Else
                Exit
            EndIf
        Next nI
        cCodeCompany := SubStr(cFil1, 1, Min(nLenCCompany, nLenShare))
        cCodeUnit := SubStr(cFil1, 1 + nLenCCompany, Min(nLenCUnit, nLenShare - Min(nLenCCompany, nLenShare)))
        aGCBR := RU07R1708_GetHCompanyInfo({{"CO_FULLNAM", "CO_FULLNAM"}, {"CO_OKPO", "CO_OKPO"}}, cEmpAnt, cCodeCompany, cCodeUnit)
    Else
        aGCBR := FwComAltInf({"CO_FULLNAM", "CO_OKPO"}, cEmpAnt, cFilAnt)
        aGBBR := FwBranAltInf({"BR_FULLNAM", "BR_OKPO"}, cEmpAnt, cFilAnt)
    EndIf

    If Len(AllTrim(aGBBR[1, 2])) > 0
        aData := {aGBBR[1, 2], aGBBR[2, 2]}
    Else
        aData := {aGCBR[1, 2], aGCBR[2, 2]}
    EndIf
    cAliasQ := GetNextAlias()
    BeginSQL Alias cAliasQ 
        SELECT SQB.QB_DEPTO QB_DEPTO, SQB.QB_DESCRIC DESC
          FROM %Table:SQB% SQB
         WHERE SQB.QB_DEPTO <= %Exp:aParameter[10]%
           AND SQB.QB_DEPTO >= %Exp:aParameter[9]%
           AND SQB.%NotDel%
        ORDER BY SQB.QB_DEPTO
    EndSQL
    Aadd(aData, "")
    If !((cAliasQ)->(EOF()))
        cDept := AllTrim((cAliasQ)->DESC)
        cCode := (cAliasQ)->QB_DEPTO
        While !((cAliasQ)->(EOF()))
            If cCode <> (cAliasQ)->QB_DEPTO .Or. cDept <> AllTrim((cAliasQ)->DESC)
                cDept := ""
            EndIf
            (cAliasQ)->(DbSkip())
        EndDo
        aData[3] := cDept
    EndIf

    (cAliasQ)->(DbCloseArea())
    Aadd(aData, "")
    Aadd(aData, DToC(Date()))
    Aadd(aData, "")
    Aadd(aData, "")

    DbSelectArea("RFQ")
    DbSelectArea("RCJ")
    RCJ->(DbGoTop())
    While !(RCJ->(EOF()))
        If RFQ->(DbSeek(xFilial("RFQ") + RCJ->RCJ_CODIGO + aParameter[2]))
            aData[4] := RFQ->RFQ_PERIOD
            aData[6] := DToC(RFQ->RFQ_DTINI)
            aData[7] := DToC(RFQ->RFQ_DTFIM)
        EndIf
        RCJ->(DbSkip())
    EndDo

    SM0->(RestArea(aSM0a))
    RFQ->(RestArea(aRFQa))
    RCJ->(RestArea(aRCJa))
    RestArea(aArea)

Return aData

/*/
{Protheus.doc} RU07R1706_GetStrParam(aParameter)

    This function get struct code for group of company.

    @type Function
    @params cEmpAnalyze, Character, Group of company.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return cStructCodeF, Character, Struct code filial for Group of company
    @example cStrF := RU07R1707_GetStructVodeF(cEmpAnt) 
/*/
Function RU07R1707_GetStructVodeF(cEmpAnalyze)

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cStructCodeF As Character

    aArea := GetArea()
    cStructCodeF := ""

    cQuery := "SELECT M0_LEIAUTE AS STRUCTURE FROM SYS_COMPANY WHERE"
    cQuery += " M0_CODIGO = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cEmpAnalyze)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    cStructCodeF := Alltrim((cTab)->STRUCTURE)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return cStructCodeF

/*/
{Protheus.doc} RU07R1708_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    The function receives data about selected company. If no data about selected company - get data abaout hight structure/
    Get data from SYS_COMPANY and SYS_COMPANY_L_RUS (SIGACFG).

    @type Function
    @params aCampo,       Array,     Array fields in CO which mast received ({{Field_From_DB, Alias_Field}...})
    @params cGroupCode,   Character, Code group of company.
    @params cCodeCompany, Character, Code company.
    @params cCodeUnit,    Character, Cod bussines unit.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return aResult, Array, Received Information.
    @example aCompanyInfo := GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
/*/
Function RU07R1708_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)

    Local oStatement     As Object
    Local cQuery         As Character 
    Local aArea          As Array
    Local cTab           As Character
    Local aResult := { } As Logical
    Local nI             As Numeric

    DEFAULT cGroupCode := cEmpAnt

    If !Empty(aCampo)

        aArea := GetArea()

        cQuery := " SELECT "
        For nI := 1 To Len(aCampo)
            cQuery += aCampo[nI, 1] + ", "
        Next nI
        cQuery += " CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_TIPO"
        cQuery += " FROM SYS_COMPANY_L_RUS WHERE "
        cQuery += " CO_COMPGRP = ? "
        cQuery += " AND CO_COMPEMP = ? "
        cQuery += " AND CO_COMPUNI = ? "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cGroupCode)
        oStatement:SetString(2, cCodeCompany)
        oStatement:SetString(3, cCodeUnit)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        If !((cTab)->(EOF()))
            For nI := 1 To Len(aCampo)
                AAdd(aResult, {aCampo[nI, 2], Alltrim((cTab)->(&(aCampo[nI, 2])))})
            Next nI
            AAdd(aResult, {"cCodeCompany", cCodeCompany})
            AAdd(aResult, {"cCodeUnit", cCodeUnit})
            AAdd(aResult, {"CO_COMPGRP", (cTab)->CO_COMPGRP})
            AAdd(aResult, {"CO_COMPEMP", (cTab)->CO_COMPEMP})
            AAdd(aResult, {"CO_COMPUNI", (cTab)->CO_COMPUNI})
            AAdd(aResult, {"CO_TIPO", (cTab)->CO_TIPO})
        EndIf

        (cTab)->(DBCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        RestArea(aArea)

        If Empty(aResult) .And. !(Empty(cCodeCompany) .And. Empty(cCodeUnit))
            If !Empty(cCodeUnit)
                aResult := GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, "")
            Else
                aResult := GetHCompanyInfo(aCampo, cGroupCode, "", "")
            EndIf
        EndIf
    EndIf

Return aResult



/*/
{Protheus.doc} RU07R1711_ToExcelFile(aResult,aHederRes,aParam)
    Populate data from an array in excel.

    @type Function
    @params aResult,       Array,   Array Data 
            aHederRes,     Array,   Code heder infi
            aParam,        Array,   Code company.
            
    @author iprokhorenko
    @since 28.08.2023
    @version 12.1.2210
    @return 
    @example aCompanyInfo := RU07R1711_ToExcelFile(aResult,aHederRes,aParam)
/*/
Function RU07R1711_ToExcelFile(aResult,aHederRes,aParam)
    
    Local oPrtXlsx := FwPrinterXlsx():New(.T.)
    Local cCaminho as Character
    Local cReportName   := "T-51_" + aParam[2] + "_" + FwTimeStamp(1)
    Local cDirectory := "\spool\"
    local cPath :=  aParam[14] //"C:\zzz\"  // /spool/ para uma geração no server
    local cArquivo := ALLTRIM( cPath ) + cReportName + ".xml"//"xls_class_rel.rel"
    Local nPos as Numeric
    local nI as Numeric
    Local nJ as Numeric
    Local oExcel := FWMsExcel():New()
    Local aCData as array

    aCData := FwComAltInf({'CO_OKPO', 'CO_FULLNAM', 'CO_COMPGRP', 'CO_COMPEMP', 'CO_TIPO', 'CO_PHONENU', 'CO_COMPUNI'})

    oExcel:AddworkSheet(STR0092) //"Conciliação Contábil"
    
    oExcel:AddTable(STR0092,"" )
    for nPos := 1 to 4
        oExcel:AddColumn(STR0092,"","         ", 1, 1)
    next
    oExcel:AddRow(STR0092,"",{"","","",STR0035})
    oExcel:AddRow(STR0092,"",{"","","",STR0036})
    oExcel:AddRow(STR0092,"",{"","","",STR0037})
    oExcel:AddRow(STR0092,"",{"","","",""})
    oExcel:AddRow(STR0092,"",{"","","",""})
    oExcel:AddRow(STR0092,"",{"","","",""})
    oExcel:AddRow(STR0092,"",{"",STR0048,"",""})
    oExcel:AddRow(STR0092,"",{"","",STR0044,STR0045})
    oExcel:AddRow(STR0092,"",{"","",aParam[2],stod(left(FwTimeStamp(1),8))})

    oExcel:AddworkSheet(STR0093) //"Conciliação Contábil"
    oExcel:AddTable(STR0093,STR0049 )   //"Conciliação Contábil"
    for nPos := 1 to Len(aHederRes[5][2]) 
        oExcel:AddColumn(STR0093,STR0049,aHederRes[5][2][nPos], Iif(aHederRes[6][2][nPos] == "C", 1, 2), Iif(aHederRes[6][2][nPos] == "C", 1, 2))
    next
    
    for nPos := 1 to Len(aResult)
        aResult[nPos][Len(aResult[nPos])] := ""
        oExcel:AddRow(STR0093,STR0049,aResult[nPos])
    next
    

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)

Return .T.


/*/
{Protheus.doc} RU07R1706_GetStrParam(aParameter)

    This function get struct code for group of company.

    @type Function
    @params cEmpAnalyze, Character, Group of company.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return cStructCodeF, Character, Struct code filial for Group of company
    @example cStrF := RU07R1707_GetStructVodeF(cEmpAnt) 
/*/
Function RU07R1710_GetDataSRD(aParameter)

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cTab2        As Character
    Local cStructCodeF As Character
    Local cHeder       As Character
    Local nPos         as Numeric
    Local aResult      As Array
    Local aTemp        As Array
    Local aTemp2       As Array
    Local aSRCARDHeder as ARRAY
    Local aHederRes    as Array
    Local cHederRes    as Character
    Local cHederRes2   as Character
    Local nI           as Numeric
    Local nJ           as Numeric
    Local nK           as Numeric
    Local nRowPos      as Numeric
    Local nCount       as Numeric
    aResult := {}
    aTemp := {}
    aTemp2 := {}
    aSRCARDHeder := {"CMAT","CNOMECMP","CDEPTO","CCC","CDEPDESC","CCCDESC","CCODVO","CRCM_PD","NVALOR","CPROCES","CPDDESC","CROTEIR","NHORAS","CPERIOD",;
                     "CRVCOD","CTIPOCOD","CCARGO","CCARGODESC","NSALARIO"}
    cHederRes := ""
    cHederRes2 := ""
    
    aHederRes := {{"NameColRevenue",{}},{"TypeColRevenue",{}},{"NameColDiscount",{}},{"TypeColDiscount",{}},{"NameColRes",{}},{"TypeColRes",{}},{"NameColResFindVO",{}}}
    cStructCodeF := ""

    aArea := GetArea()
    nCount := len(aParameter[13])

    cQuery := "SELECT A.RD_MAT || C.RA_CARGO || A.RD_DEPTO || A.RD_CC AS SD,A.RD_MAT AS CMAT, C.RA_NOMECMP AS CNOMECMP, "
    cQuery += " A.RD_DEPTO AS CDEPTO, A.RD_CC AS CCC, E.QB_DESCRIC AS CDEPDESC, F.CTT_DESC01 AS CCCDESC, B.RV_HE, "
    cQuery += " A.RD_PD AS CCODVO, G.RCM_PD AS CRCM_PD, A.RD_VALOR AS NVALOR, A.RD_PROCES AS CPROCES, B.RV_DESC AS CPDDESC, "
    cQuery += " A.RD_ROTEIR AS CROTEIR, A.RD_HORAS AS NHORAS, A.RD_PERIODO AS CPERIOD, B.RV_COD AS CRVCOD, B.RV_TIPOCOD AS CTIPOCOD, "
    cQuery += " C.RA_CARGO AS CCARGO, D.Q3_DESCSUM AS CCARGODESC, C.RA_SALARIO AS NSALARIO FROM  " + RetSQLName("SRD") + " A "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SRV") + " B ON A.RD_PD = B.RV_COD "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SRA") + " C ON A.RD_MAT = C.RA_MAT "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SQ3") + " D ON D.Q3_CARGO = C.RA_CARGO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SQB") + " E ON A.RD_DEPTO = E.QB_DEPTO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("CTT") + " F ON A.RD_CC = F.CTT_CUSTO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("RCM") + " G ON A.RD_PD = G.RCM_PD "
    cQuery += " WHERE (B.RV_TIPOCOD IN ('1', '2') OR B.RV_COD = '870' OR B.RV_COD = '872') AND "
    if APARAMETER[5] <> "  " .And. APARAMETER[6] <> "  "
        cQuery += " (A.RD_FILIAL BETWEEN '" + aParameter[5] + "' AND '" + aParameter[6] + "') AND "
    Endif
    if APARAMETER[7] <> "  " .And. APARAMETER[8] <> "  "
        cQuery += " (A.RD_DEPTO BETWEEN '" + aParameter[7] + "' AND '" + aParameter[8] + "') AND "
    Endif
    if APARAMETER[9] <> "  " .And. APARAMETER[10] <> "  "
        cQuery += " (A.RD_CC BETWEEN '" + aParameter[9] + "' AND '" + aParameter[10] + "') AND "
    Endif
    if APARAMETER[11] <> "  " .And. APARAMETER[12] <> "  "
        cQuery += " (A.RD_PROCES BETWEEN '" + aParameter[11] + "' AND '" + aParameter[12] + "') AND "
    Endif
    If len(APARAMETER[13]) > 0
        cQuery += " A.RD_MAT IN ("
        For nI := 1 To nCount
            cQuery += "'" + aParameter[13, nI] + "'" + Iif(nI < nCount, ", ", ") AND ")
        Next nI
    EndIf

    cQuery += " A.RD_PERIODO = '" + aParameter[2] + "' AND A.D_E_L_E_T_ = ' ' AND C.D_E_L_E_T_ = ' '  "
    
    cQuery += " UNION ALL SELECT A.RC_MAT || C.RA_CARGO || A.RC_DEPTO || A.RC_CC AS SD,A.RC_MAT AS CMAT, C.RA_NOMECMP AS CNOMECMP, "
    cQuery += " A.RC_DEPTO AS CDEPTO, A.RC_CC AS CCC, E.QB_DESCRIC AS CDEPDESC, F.CTT_DESC01 AS CCCDESC, B.RV_HE, "
    cQuery += " A.RC_PD AS CCODVO, G.RCM_PD AS CRCM_PD, A.RC_VALOR AS NVALOR, A.RC_PROCES AS CPROCES, B.RV_DESC AS CPDDESC, "
    cQuery += " A.RC_ROTEIR AS CROTEIR, A.RC_HORAS AS NHORAS, A.RC_PERIODO AS CPERIOD, B.RV_COD AS CRVCOD, B.RV_TIPOCOD AS CTIPOCOD, "
    cQuery += " C.RA_CARGO AS CCARGO, D.Q3_DESCSUM AS CCARGODESC, C.RA_SALARIO AS NSALARIO FROM " + RetSQLName("SRC") + " A "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SRV") + " B ON A.RC_PD = B.RV_COD "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SRA") + " C ON A.RC_MAT = C.RA_MAT "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SQ3") + " D ON D.Q3_CARGO = C.RA_CARGO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("SQB") + " E ON A.RC_DEPTO = E.QB_DEPTO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("CTT") + " F ON A.RC_CC = F.CTT_CUSTO "
    cQuery += " LEFT OUTER JOIN " + RetSQLName("RCM") + " G ON A.RC_PD = G.RCM_PD "
    cQuery += " WHERE (B.RV_TIPOCOD IN ('1', '2') OR B.RV_COD = '870' OR B.RV_COD = '872') AND "
    if APARAMETER[5] <> "  " .And. APARAMETER[6] <> "  "
        cQuery += " (A.RC_FILIAL BETWEEN '" + aParameter[5] + "' AND '" + aParameter[6] + "') AND "
    Endif
    if APARAMETER[7] <> "  " .And. APARAMETER[8] <> "  "
        cQuery += " (A.RC_DEPTO BETWEEN '" + aParameter[7] + "' AND '" + aParameter[8] + "') AND "
    Endif
    if APARAMETER[9] <> "  " .And. APARAMETER[10] <> "  "
        cQuery += " (A.RC_CC BETWEEN '" + aParameter[9] + "' AND '" + aParameter[10] + "') AND "
    Endif
    if APARAMETER[11] <> "  " .And. APARAMETER[12] <> "  "
        cQuery += " (A.RC_PROCES BETWEEN '" + aParameter[11] + "' AND '" + aParameter[12] + "') AND "
    Endif
    if len(APARAMETER[13]) > 0
        cQuery += " A.RC_MAT IN ("
        For nI := 1 To nCount
            cQuery += "'" + aParameter[13, nI] + "'" + Iif(nI < nCount, ", ", ") AND ")
        Next nI
    EndIf
    cQuery += "  A.RC_PERIODO = '" + aParameter[2] + "' AND A.D_E_L_E_T_ = ' '  AND C.D_E_L_E_T_ = ' ' "
    If aParameter[1] == 1
        cQuery += " ORDER BY CNOMECMP , SD  "
    ElseIf aParameter[1] == 2
        cQuery += " ORDER BY CMAT , SD "
    ElseIf aParameter[1] == 3
        cQuery += " ORDER BY CDEPTO, CMAT , SD "
    ElseIf aParameter[1] == 4
        cQuery += " ORDER BY CCC, CMAT , SD "
    EndIf
    

    oStatement := FWPreparedStatement():New(cQuery)
    //oStatement:SetString(1, cEmpAnalyze)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
        
    If !((cTab)->(EOF()))
        While !((cTab)->(EOF()))
            //nPos := aScan(aValores, {|x| x[1] == (cTab)->RD_MAT })
            aAdd(aTemp,{ALLTRIM((cTab)->SD), ;                  //  1
                        (cTab)->CMAT, ;                         //  2
                        ALLTRIM((cTab)->CNOMECMP), ;            //  3
                        ALLTRIM((cTab)->CDEPTO), ;              //  4
                        ALLTRIM((cTab)->CCC), ;                 //  5
                        ALLTRIM((cTab)->CDEPDESC), ;            //  6
                        ALLTRIM((cTab)->CCCDESC), ;             //  7
                        (cTab)->RV_HE, ;                        //  8
                        (cTab)->CCODVO, ;                       //  9
                        ALLTRIM((cTab)->CRCM_PD), ;             //  10
                        (cTab)->NVALOR, ;                       //  11
                        (cTab)->CPROCES, ;                      //  12
                        ALLTRIM((cTab)->CPDDESC), ;             //  13
                        (cTab)->CROTEIR, ;                      //  14
                        (cTab)->NHORAS, ;                       //  15
                        (cTab)->CPERIOD, ;                      //  16
                        (cTab)->CRVCOD, ;                       //  17
                        (cTab)->CTIPOCOD, ;                     //  18
                        (cTab)->CCARGO, ;                       //  19
                        ALLTRIM((cTab)->CCARGODESC), ;          //  20
                        (cTab)->NSALARIO })                     //  21
            
            If !((cTab)->CCODVO $ cHederRes) .And. (cTab)->CTIPOCOD == INDEX_PARAM_REVENUE .And. (cTab)->CCODVO <> EXCLUDE_FROM_PAYMENT //.And. (cTab)->RV_HE == NIL
                cHederRes += (cTab)->CCODVO + "|"
                aAdd(aHederRes[1][2], (cTab)->CCODVO + " " + ALLTRIM((cTab)->CPDDESC))
                aAdd(aHederRes[2][2], "N")
            EndIf

            If !((cTab)->CCODVO $ cHederRes2) .And. (cTab)->CTIPOCOD == INDEX_PARAM_DISCOUNT .And. (cTab)->CCODVO <> NDFL_ADI .And. ;
            (cTab)->CCODVO <> NDFL_FOL .And. (cTab)->CCODVO <> ADVANCE_WITHHELD .And. (cTab)->CCODVO <> DEBT_PRE_MONTH
                    cHederRes2 += (cTab)->CCODVO + "|"
                    aAdd(aHederRes[3][2], (cTab)->CCODVO + " " + ALLTRIM((cTab)->CPDDESC))
                    aAdd(aHederRes[4][2], "N")
            EndIf

            (cTab)->(DbSkip())

        EndDo
        
        (cTab)->(DBCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        aAdd(aHederRes[5][2], STR0050)
        aAdd(aHederRes[5][2], STR0051)
        aAdd(aHederRes[5][2], STR0052)
        aAdd(aHederRes[5][2], STR0053)
        If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4  //aParameter
            aAdd(aHederRes[5][2], STR0083)
            //aAdd(aHederRes[5][2], STR0083)
            aAdd(aHederRes[5][2], STR0084)
            //aAdd(aHederRes[5][2], STR0084)
        EndIf
        aAdd(aHederRes[5][2], STR0054)
        aAdd(aHederRes[5][2], STR0055)
        aAdd(aHederRes[5][2], STR0062)
        
        aAdd(aHederRes[7][2], STR0050)
        aAdd(aHederRes[7][2], STR0051)
        aAdd(aHederRes[7][2], STR0052)
        aAdd(aHederRes[7][2], STR0053)
        If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4
            aAdd(aHederRes[7][2], STR0083)
            //aAdd(aHederRes[7][2], STR0083)
            aAdd(aHederRes[7][2], STR0084)
            //aAdd(aHederRes[7][2], STR0084)
        EndIf
        aAdd(aHederRes[7][2], STR0054)
        aAdd(aHederRes[7][2], STR0055)
        aAdd(aHederRes[7][2], STR0062)
        
        aAdd(aHederRes[6][2], "C")
        aAdd(aHederRes[6][2], "C")
        aAdd(aHederRes[6][2], "C")
        aAdd(aHederRes[6][2], "C")
        If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4
            aAdd(aHederRes[6][2], "C")
            aAdd(aHederRes[6][2], "C")

        EndIf
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")

        For nI := 1 to Len(aHederRes[1][2])
            aAdd(aHederRes[5][2], aHederRes[1][2][nI])
            aAdd(aHederRes[6][2], aHederRes[2][2][nI])
            aAdd(aHederRes[7][2], Left(aHederRes[1][2][nI], 3))
            //aAdd(aHederRes[7][2], aHederRes[1][2][nI])
        Next nI

        aAdd(aHederRes[5][2], STR0089)
        aAdd(aHederRes[5][2], STR0090)
        aAdd(aHederRes[5][2], STR0091)

        aAdd(aHederRes[7][2], STR0089)
        aAdd(aHederRes[7][2], NDFL_ADI + "|" + NDFL_FOL)
        aAdd(aHederRes[7][2], PREPAID_EXPENSE)

        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")

        For nI := 1 to Len(aHederRes[3][2])
            aAdd(aHederRes[5][2], aHederRes[3][2][nI])
            aAdd(aHederRes[6][2], aHederRes[4][2][nI])
            aAdd(aHederRes[7][2], Left(aHederRes[3][2][nI], 3))
            //aAdd(aHederRes[7][2], aHederRes[3][2][nI])
        Next nI

        aAdd(aHederRes[5][2], STR0085)
        aAdd(aHederRes[5][2], STR0086)
        aAdd(aHederRes[5][2], STR0087)
        aAdd(aHederRes[5][2], STR0088)
        aAdd(aHederRes[5][2], "")

        aAdd(aHederRes[7][2], STR0085)
        aAdd(aHederRes[7][2], "")
        aAdd(aHederRes[7][2], EXCLUDE_FROM_PAYMENT)
        aAdd(aHederRes[7][2], GRAND_TOTAL)
        aAdd(aHederRes[7][2], "")

        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "N")
        aAdd(aHederRes[6][2], "C")

        //If cSotr $ "mat|tn"
        nRowPos := 0
        For nI := 1 to len(aTemp)

            If len(aResult) < 1 
                aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                nRowPos += 1
                aResult[nRowPos][Len(aResult[nRowPos])] := aTemp[nI][1]
            EndIf
            If nRowPos > 0 
                If aTemp[nI][1] <> aResult[nRowPos][Len(aResult[nRowPos])]
                    nPos := 0
                    nPos := aScan(aHederRes[7][2], {|x| NDFL_FOL $ x })
                    nPos2 := 0
                    nPos2 := aScan(aHederRes[7][2], {|x| STR0055 $ x })//STR0055
                    If nPos > 0 .And. nPos2 > 0
                        For nJ := nPos2 + 1 to nPos - 2
                            If !(CODE_PREPAYMENT $ aHederRes[7][2][nJ])
                                aResult[nRowPos][nPos-1] += aResult[nRowPos][nJ]
                            EndIf
                        Next nJ
                    EndIf

                    nPos := 0
                    nPos := aScan(aHederRes[7][2], {|x| STR0085 $ x })
                    nPos2 := 0
                    nPos2 := aScan(aHederRes[7][2], {|x| STR0089 $ x })//STR0055
                    If nPos > 0 .And. nPos2 > 0
                        For nJ := nPos2 + 1 to nPos - 1
                            aResult[nRowPos][nPos] += aResult[nRowPos][nJ]
                        Next nJ
                    EndIf

                    If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4
                        nPos := 0
                        nPos := aScan(aHederRes[7][2], {|x| STR0083 $ x })
                        nPos2 := 0
                        nPos2 := aScan(aHederRes[7][2], {|x| STR0084 $ x })
                        
                        If ( aTemp[nI][6] <> aResult[nRowPos][nPos] .And. APARAMETER[1] == 3)
                            aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                            nRowPos += 1
                            For nJ := nRowPos - 1 to 1 step -1
                                If aResult[nRowPos - 1][nPos] <> aResult[nJ][nPos]
                                    Exit
                                EndIf
                                for nK := aScan(aHederRes[7][2], {|x| STR0055 $ x }) + 1 to len(aHederRes[7][2]) - 1
                                    aResult[nRowPos][nK] += aResult[nJ][nK]
                                next nK
                            Next nJ
                            aResult[nRowPos][nPos] := aResult[nRowPos - 1][nPos]
                            aResult[nRowPos][3] := STR0095
                            aResult[nRowPos][1] := nRowPos
                        EndIf

                        If ( aTemp[nI][7] <> aResult[nRowPos][nPos2] .And. APARAMETER[1] == 4)
                            aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                            nRowPos += 1
                            For nJ := nRowPos - 1 to 1 step - 1
                                If aResult[nRowPos - 1][nPos2] <> aResult[nJ][nPos2]
                                    Exit
                                EndIf
                                for nK := aScan(aHederRes[7][2], {|x| STR0055 $ x }) + 1 to len(aHederRes[7][2]) - 1
                                    aResult[nRowPos][nK] += aResult[nJ][nK]
                                next nK
                            Next nJ
                            aResult[nRowPos][nPos2] := aResult[nRowPos - 1][nPos2]
                            aResult[nRowPos][3] := STR0096
                            aResult[nRowPos][1] := nRowPos
                        EndIf
                    EndIf

                    aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                    nRowPos += 1
                    aResult[nRowPos][Len(aResult[nRowPos])] := aTemp[nI][1]
                EndIf
            EndIf
            If aResult[nRowPos][2] == ""
                aResult[nRowPos][1] := nRowPos
                aResult[nRowPos][2] := aTemp[nI][2]
                aResult[nRowPos][3] := aTemp[nI][3]
                aResult[nRowPos][4] := aTemp[nI][20]
                
                If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4
                    aResult[nRowPos][5] := aTemp[nI][6]
                    aResult[nRowPos][6] := aTemp[nI][7]
                    aResult[nRowPos][7] := aTemp[nI][21]
                    
                Else
                    aResult[nRowPos][5] := aTemp[nI][21]
                    //aResult[nRowPos][6] := aTemp[nI][21]
                EndIf
            EndIf

            nPos := 0
            nPos := aScan(aHederRes[7][2], {|x| x == aTemp[nI][9] })
            If nPos > 0
                aResult[nRowPos][nPos] := aTemp[nI][11]
                If aTemp[nI][18] == "1" .And. aTemp[nI][8] == "N" .And. aTemp[nI][15] <> 0 .And. aTemp[nI][10] == ""
                    aResult[nRowPos][aScan(aHederRes[7][2], {|x| STR0055 $ x })] := aTemp[nI][15]
                EndIf
                If aTemp[nI][18] == "1" .And. aTemp[nI][8] == "S" .And. aTemp[nI][15] <> 0
                    aResult[nRowPos][aScan(aHederRes[7][2], {|x| STR0062 $ x })] := aTemp[nI][15]
                EndIf
            EndIf 

            If aTemp[nI][9] == NDFL_ADI .Or. aTemp[nI][9] == NDFL_FOL
                nPos := 0
                nPos := aScan(aHederRes[7][2], {|x| aTemp[nI][9] $ x })
                If nPos > 0
                    aResult[nRowPos][nPos] += aTemp[nI][11]
                EndIf 
            EndIf

            If nI == len(aTemp) 
                nPos := 0
                nPos := aScan(aHederRes[7][2], {|x| NDFL_FOL $ x })
                nPos2 := 0
                nPos2 := aScan(aHederRes[7][2], {|x| STR0055 $ x })//STR0055
                If nPos > 0 .And. nPos2 > 0
                    For nJ := nPos2 + 1 to nPos - 2
                        If !(CODE_PREPAYMENT $ aHederRes[7][2][nJ])
                            aResult[nRowPos][nPos-1] += aResult[nRowPos][nJ]
                        EndIf
                    Next nJ
                EndIf

                nPos := 0
                nPos := aScan(aHederRes[7][2], {|x| STR0085 $ x })
                nPos2 := 0
                nPos2 := aScan(aHederRes[7][2], {|x| STR0089 $ x })//STR0055
                If nPos > 0 .And. nPos2 > 0
                    For nJ := nPos2 + 1 to nPos - 1
                        aResult[nRowPos][nPos] += aResult[nRowPos][nJ]
                    Next nJ
                EndIf
                If APARAMETER[1] == 3 .Or. APARAMETER[1] == 4
                    nPos := 0
                    nPos := aScan(aHederRes[7][2], {|x| STR0083 $ x })
                    nPos2 := 0
                    nPos2 := aScan(aHederRes[7][2], {|x| STR0084 $ x })
                    If nRowPos - 1 == 0 .or. APARAMETER[1] == 3
                        aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                        nRowPos += 1
                        For nJ := nRowPos - 1 to 1 step -1
                            If aResult[nRowPos - 1][nPos] <> aResult[nJ][nPos]
                                Exit
                            EndIf
                            for nK := aScan(aHederRes[7][2], {|x| STR0055 $ x }) + 1 to len(aHederRes[7][2]) - 1
                                aResult[nRowPos][nK] += aResult[nJ][nK]
                            next nK
                        Next nJ
                        aResult[nRowPos][nPos] := aResult[nRowPos - 1][nPos]
                        aResult[nRowPos][3] := STR0095
                        aResult[nRowPos][1] := nRowPos
                    EndIf
                    If nRowPos - 1 == 0 .or. APARAMETER[1] == 4
                        aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                        nRowPos += 1
                        For nJ := nRowPos - 1 to 1 step - 1
                            If aResult[nRowPos - 1][nPos2] <> aResult[nJ][nPos2]
                                Exit
                            EndIf
                            for nK := aScan(aHederRes[7][2], {|x| STR0055 $ x }) + 1 to len(aHederRes[7][2]) - 1
                                aResult[nRowPos][nK] += aResult[nJ][nK]
                            next nK
                        Next nJ
                        aResult[nRowPos][nPos2] := aResult[nRowPos - 1][nPos2]
                        aResult[nRowPos][3] := STR0096
                        aResult[nRowPos][1] := nRowPos
                        
                    EndIf

                    aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                    nPos := aScan(aHederRes[7][2], {|x| STR0055 $ x })
                    nRowPos += 1
                    For nJ := nRowPos - 1 to 1 step - 1
                        If aResult[nJ][2] == ""
                            for nK := nPos + 2 to len(aHederRes[7][2]) - 1
                                aResult[nRowPos][nK] += aResult[nJ][nK]
                            next nK
                        EndIf
                    Next nJ
                    //aResult[nRowPos][nPos2] := aResult[nRowPos - 1][nPos2]
                    aResult[nRowPos][3] := STR0101
                    aResult[nRowPos][1] := nRowPos

                ElseIf  APARAMETER[1] == 1 .Or. APARAMETER[1] == 2
                    nPos := 0
                    nPos := aScan(aHederRes[7][2], {|x| STR0055 $ x })
                    aAdd(aResult, aClone(AddRowArray(aHederRes[6][2])))
                    nRowPos += 1
                    For nJ := nRowPos - 1 to 1 step - 1
                        for nK := nPos + 2 to len(aHederRes[7][2]) - 1
                            aResult[nRowPos][nK] += aResult[nJ][nK]
                        next nK
                    Next nJ
                    //aResult[nRowPos][nPos2] := aResult[nRowPos - 1][nPos2]
                    aResult[nRowPos][3] := STR0100
                    aResult[nRowPos][1] := nRowPos
                EndIf
            endif
            
        Next nI


        RU07R1711_ToExcelFile(aResult, aHederRes, aParameter)
        MsgInfo("", STR0097)
    else
        MsgInfo("", STR0098)
    ENDIF

    RestArea(aArea)

Return aResult


/*/{Protheus.doc} AddRowArray(aArr as array)
    Adds a string to an array with a specific pattern

    @type  Static Function
    @author iprokhorenko
    @since 24/08/2023
    @version 12.1.2210
    @param aArr, array, array pattern
    @return aRes, array, array data
    @example aAdd(aResult, aclone(AddRowArray(aArr )))
    
/*/
Static Function AddRowArray(aArr as array)
    Local aRes as array
    Local nI as Numeric
    
    aRes := {}
    For nI := 1 to Len(aArr)
        If aArr[nI] == "C"
            aAdd(aRes, "")
        ElseIf aArr[nI] == "N"
            aAdd(aRes, 0)
        EndIf
    Next 

Return aRes

//-------------------------------------------------------------------
/*/{Protheus.doc} stCellForm(oPrtXlsx, cTpConteud, cRowTipo)
Estilização por Celula da Planilha

@param oPrtXlsx   - Classe do Printer
@param cTpConteud - Tipo do Conteudo. Utilizado para definir mascara
@param cRowTipo   - Tipo da Linha 

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function stCellForm(oPrtXlsx, cTpConteud, cRowTipo)
    Local lRet := .T.
    Local cFormat      := ""
    Local oCellHorAl   := FwXlsxCellAlignment():Horizontal()
    Local oCellVerAl   := FwXlsxCellAlignment():Vertical()
    Local cHorAlign    := oCellHorAl:Left()
    Local cVertAlign   := oCellVerAl:Center()
    Local cTextColor   := "000000" /*preto*/
    Local cBgColor     := "FFFFFF"/*branco*/
    Local lTextWrap    := .F.

    Default cTpConteud := ""
    Default cRowTipo   := ""

    Do Case
        Case cTpConteud == "D"
            cFormat := "dd/mm/yyyy"
        Case cTpConteud == "N"
            cFormat := "#,##0.00"
            cHorAlign := oCellHorAl:Right()
        Otherwise
            cFormat := ""
    EndCase

    Do Case 
        Case cRowTipo == "TITULO"
            cTextColor := "000000"/*branco*/
            cBgColor   := "FFFFFF"/*azul*/
            cHorAlign  := oCellHorAl:Center()
        Case cRowTipo == "FOOTER"
            cHorAlign  := oCellHorAl:Right()
        Otherwise
    EndCase

    lRet := oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, lTextWrap, 0, cTextColor, cBgColor, cFormat)
Return lRet


