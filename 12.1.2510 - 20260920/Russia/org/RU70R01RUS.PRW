#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU70R01RUS.CH"

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

#DEFINE SYMB_HOURLY_RATE "H"
#DEFINE SYMB_GPC_AGREEMENT "A"

#DEFINE COUNT_PARAMS 15
#DEFINE NAME_OF_PROGRAM "RU70R01RUS"

/*/
{Protheus.doc} RU70R01RUS()
    Main function of routine print form T-3.

    @type Function
    @params 
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return 
    @example Aadd(aRotina, {STR0026, "RU70R01RUS", 0, 11})
/*/
Function RU70R01RUS()

    Local aInputParameters As Array
    Local oDialog          As Object
    Local aDataList        As Array
    Local lCreateReport    As Logical
    Local cPrefixNameFile  As Character

    aInputParameters := RU70R0103_GetDialogWindow(STR0001) // "Printing staffing"
    
    If aInputParameters[1]
        oDialog := RuHRWordPrintForm():New("RU70R01RUS")
        oDialog:cPatternPath := aInputParameters[2]
        oDialog:cResultPath := aInputParameters[3] + " "
        cPrefixNameFile := STR0033 + STR0034 // "T3-", "Staffing"

        MsAguarde({|| ;
                      aDataList := RU70R0107_GetAllData(aInputParameters), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameFile, .T., .T.)  ;
                  }, STR0031, STR0032) // "Please wait", "Formation of an admission order".

        If lCreateReport
            MsgInfo(STR0029, STR0028) // "The staffing file has been created!", "Done".
        Else
            MsgStop(STR0030, STR0015) // "Something went wrong while creating the file", "Error".
        EndIf

        FreeObj(oDialog)
        oDialog := Nil

    EndIf

Return .T.

/*/
{Protheus.doc} RU70R0107_GetAllData(aParams)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example aDataList := RU70R0107_GetAllData(aInputParameters)
/*/
Static Function RU70R0107_GetAllData(aParams)

    Local aDataArray           As Array
    Local aRCLList             As Array
    Local aArea                As Array
    Local oRuEmployeePrintForm As Object

    aArea := GetArea()
    aRCLList := {}
    aDataArray := {}
    // We form an array with structural subdivisions for printing the report.
    aRCLList := RU70R0108_GetRCLList(aParams)

    oRuEmployeePrintForm := RU70R0109_GrPrintFilter(aRCLList, aParams)
    Aadd(aDataArray, oRuEmployeePrintForm)

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU70R0108_GetRCLList(aParams)
    The function creates an array of structural subdivisions.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of structural subdivisions
    @example aRCLList := RU70R0108_GetRCLList(aParams)
/*/
Static Function RU70R0108_GetRCLList(aParams)

    Local aDataArray As Array
    Local aArea      As Array
    Local cAlias     As Character
    Local cOrder     As Character
    Local cWhere     As Character
    Local cDateFil   As Character
    Local aIncludSTR As Array
    Local cItem      As Character
    Local nIndexItem As Numeric

    aArea := GetArea()
    cAlias := GetNextAlias()
    cDateFil := DToS(aParams[16])
    aDataArray := {}
    aIncludSTR := {}
    cOrder := "%RCL.RCL_DEPTO, RCL.RCL_POSTO%"
    cWhere := "% RCL.RCL_FILIAL >= '" + aParams[4] + "'" + CRLF + ;
            "AND RCL.RCL_FILIAL <= '" + aParams[5] + "'" + CRLF + ;
            "AND RCL.RCL_CC >= '" + aParams[6] + "'" + CRLF + ;
            "AND RCL.RCL_CC <= '" + aParams[7] + "'" + CRLF + ;
            "AND RCL.RCL_DEPTO >= '" + aParams[8] + "'" + CRLF + ;
            "AND RCL.RCL_DEPTO <= '" + aParams[9] + "'" + CRLF + ;
            "AND RCL.RCL_PROCES >= '" + aParams[10] + "'" + CRLF + ;
            "AND RCL.RCL_PROCES <= '" + aParams[11] + "'" + CRLF + ;
            "AND RCL.RCL_DTINI <= '" + cDateFil + "'" + CRLF + ;
            "AND (RCL.RCL_DTFIM >= '" + cDateFil + "' OR RCL.RCL_DTFIM = '')"
    cWhere += " %"

    BeginSql Alias cAlias
    SELECT RCL.RCL_FILIAL FILIAL, RCL.RCL_POSTO POSTO, RCL_NPOSTO NPOSTO,
            RCL_DEPTO DEPTO, RCL_PROCES PROCES, RCL_CARGO CARGO, RCL_FUNCAO FUNCAO, RCL_CC CC, 
            RCL_TABSAL TABSAL, RCL_NIVEL NIVEL, RCL_FAIXSA FAIXSA, RCL_SALAR SALAR, RCL_BENEF BENEF, RCL_TPCONT TPCONT
          FROM %Table:RCL% RCL
         WHERE %Exp:cWhere%
         AND RCL.RCL_STATUS <> '4'
         AND RCL.%NotDel%
        ORDER BY %Exp:cOrder% ASC
    EndSQL

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        cItem := AllTrim((cAlias)->DEPTO) + AllTrim((cAlias)->PROCES) + AllTrim((cAlias)->CARGO) + AllTrim((cAlias)->FUNCAO) + ;
        AllTrim((cAlias)->CC) + AllTrim((cAlias)->TABSAL) + AllTrim((cAlias)->NIVEL) + AllTrim((cAlias)->FAIXSA) + ;
        AllTrim(CValToChar((cAlias)->SALAR)) + AllTrim(CValToChar((cAlias)->BENEF)) + AllTrim((cAlias)->TPCONT)

        nIndexItem := AScan(aIncludSTR, {|x| x == cItem})
        If nIndexItem > 0
            aDataArray[nIndexItem, 3] += (cAlias)->NPOSTO
        Else
            Aadd(aDataArray, {(cAlias)->FILIAL, (cAlias)->POSTO, (cAlias)->NPOSTO, (cAlias)->DEPTO})
            Aadd(aIncludSTR, cItem)
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU70R0109_GrPrintFilter(aRCLList, aParams)
    The function creates an RuEmployeePrintForm object.

    @type Static Function
    @params aRCLList, Array, Array of structural subdivisions for printer.
    @params aParams,  Array, Parameters entered by the user.
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing
    @example oRuEmployeePrintForm := RU70R0109_GrPrintFilter(aRCLList, aParams)
/*/
Static Function RU70R0109_GrPrintFilter(aRCLList, aParams)
    
    Local nOrder  As Numeric
    local nI      As Numeric
    Local cSearch As Character
    Local aData   As Array
    Local cDepto  As Character
    Local oRuEmployeePrintForm As Object

    nOrder := RetOrder("RCL", "RCL_FILIAL+RCL_POSTO")

    oRuEmployeePrintForm := RuEmployeePrintForm():New("", "", Array(2))

    oRuEmployeePrintForm:aDataList[1] := {"count1_lines", 0}
    oRuEmployeePrintForm:aDataList[2] := {"count1_column", 10}
    Aadd(oRuEmployeePrintForm:aDataList, {"count2_lines", 1})
    Aadd(oRuEmployeePrintForm:aDataList, {"count2_column", 6})

    Aadd(oRuEmployeePrintForm:aDataList, {"staff_count", 0})

    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_1",  0})
    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_2",  0})
    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_3",  0})
    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_4",  0})
    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_5",  0})
    Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable2_1_6",  0})

    aData := RU70R0110_GetDataArray(aParams, Iif(Len(aRCLList) > 0, aRCLList[1, 1], ""))
    For nI := 1 To Len(aData)
        Aadd(oRuEmployeePrintForm:aDataList, aData[nI])
    Next nI

    cDepto := ""

    For nI := 1 To Len(aRCLList)

        cSearch := aRCLList[nI, 1] + aRCLList[nI, 2]
        // We are positioning ourselves on an structural subdivisions with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("RCL", nOrder, cSearch, "RCL_POSTO"))

            RU70R0111_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aRCLList[nI, 3], Empty(cDepto) .Or. cDepto <> aRCLList[nI, 4])
            cDepto := aRCLList[nI, 4]

        EndIf
    Next nI

    // if no data for a table create empty string
    If oRuEmployeePrintForm:aDataList[1, 2] == 0
        oRuEmployeePrintForm:aDataList[1, 2] := 1
        For nI := 1 To 10
            Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable1_1_" + CValToChar(nI), " "})
        Next nI
    EndIf

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU70R0110_GetDataArray(aParams, cFil)
    The function creates an array of variables and general data according to the template.

    @type Static Function
    @params aParams, Array,  Parameters entered by the user.
    @params cFil, Character, Filial first RCL
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of variables and data
    @example aData := RU70R0110_GetDataArray(aParams, Iif(Len(aRCLList) > 0, aRCLList[1, 1], ""))
/*/
Static Function RU70R0110_GetDataArray(aParams, cFil)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cPost1Signature  As Character
    Local cPost2Signature  As Character
    Local cTypeBranch      As Character

    aDataArray := {}

    // Get information about company.
    aGetCoBrRusInfo := {}
    If Empty(AllTrim(cFil))
        cFil := cFilAnt
    EndIf
    If !Empty(AllTrim(cFil))
        cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, cFil)[1][2]
        aGetCoBrRusInfo := GetCoBrRUS(cFil)
    EndIf
    If Len(aGetCoBrRusInfo) > 0
        cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
        cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))
    Else
        cOrganzationName := ""
        cOKPOCode := ""
    EndIf

    // Get information about signer.
    cPost1Signature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParams[12])) // Get name of post for signature
    cPost2Signature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParams[14])) // Get name of post for signature

    aAdd(aDataArray, {"cOrgName",       cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",      cOKPOCode})
    aAdd(aDataArray, {"cDateCreation",  DToC(aParams[16])})
    aAdd(aDataArray, {"cDayCreation",   Day(aParams[16])})
    aAdd(aDataArray, {"cMonthCreation", StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aParams[16]))})
    aAdd(aDataArray, {"cYearCreation",  Year(aParams[16]) % 100})
    aAdd(aDataArray, {"cSigner1",       cPost1Signature})
    aAdd(aDataArray, {"cNameSigner1",   aParams[13]})
    aAdd(aDataArray, {"cSigner2",       cPost2Signature})
    aAdd(aDataArray, {"cNameSigner2",   aParams[15]})

Return aDataArray

/*/
{Protheus.doc} RU70R0111_FillDataForGroupPrint(aDataPrint, nPosto, lPrDep)
    Filling array for schedule by current employee.

    @type Static Function
    @params aDataPrint, Array,   Array for printing.
    @params nPosto,     Numeric, NPOSTO from RCL (agreg).
    @params lPrDep,     Logical, Print Name of department (flag)
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU70R0111_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aRCLList[nI, 3], Empty(cDepto) .Or. cDepto <> aRCLList[nI, 4])
/*/
Static Function RU70R0111_FillDataForGroupPrint(aDataPrint, nPosto, lPrDep)

    Local lResult As Logical
    Local aPosto  As Array
    Local cPosto  As Character
    Local nCol4   As Numeric
    Local cType   As Character

    aPosto := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, RCL->RCL_CARGO) // Get information about position.
    cPosto := aPosto[1] + Iif(Empty(aPosto[1]) .Or. Empty(aPosto[2]), "", ", ") + aPosto[2] + Iif(Empty(aPosto[2]), "", " " + STR0019)
    cPosto += Iif(Empty(cPosto) .Or. Empty(aPosto[3]), "", ", ") + aPosto[3] + Iif(Empty(aPosto[3]), "", " " + STR0020)
    nCol4 := (RCL->RCL_SALAR + RCL->RCL_BENEF) * nPosto
    cType := Iif(AllTrim(RCL->RCL_WRATE) $ SYMB_HOURLY_RATE, "H", Iif(AllTrim(RCL->RCL_WRATE) $ SYMB_GPC_AGREEMENT, "A", "M"))
    
    aDataPrint[1, 2] += 1
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_1",  Iif(lPrDep, StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, RCL->RCL_DEPTO), " ")})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_2",  RCL->RCL_DEPTO})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_3",  cPosto})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_4",  nPosto})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_5",  RCL->RCL_SALAR})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_6",  Iif(RCL->RCL_BENEF > 0, RCL->RCL_BENEF, " ")})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_7",  " "}) // (not realized)
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_8",  " "}) // (not realized)
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_9",  Iif(cType $ "AH", " ", nCol4)})
    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[1, 2]) + "_10", Iif(cType == "A", STR0038, Iif(cType == "H", STR0037, " "))}) // "GPC agreement", "paid by the hourly rate"

    aDataPrint[5, 2]  += nPosto         // Sum 4 columns (count staffs item)
    aDataPrint[6, 2]  += nPosto         // Sum 4 columns (Itogo)
    aDataPrint[7, 2]  += RCL->RCL_SALAR // Sum 5 columns (Itogo)
    aDataPrint[8, 2]  += RCL->RCL_BENEF // Sum 6 columns (Itogo)
    aDataPrint[9, 2]  += 0              // Sum 7 columns (Itogo) (column not realized)
    aDataPrint[10, 2] += 0              // Sum 8 columns (Itogo) (column not realized)
    aDataPrint[11, 2] += Iif(cType $ "AH", 0, nCol4)          // Sum 9 columns (Itogo)

    lResult := .T.

Return lResult

/********** functions about parametrs *************/

/*/
{Protheus.doc} RU70R0101_GetUserSettings(cIdUser, nNumSetting, cProgrammName)
    Restore user settings.
    The data is stored in the SXK table

    @type Function
    @params cIdUser,       Character, Id current user
    @params nNumSetting,   Numeric,   Count Settings
    @params cProgrammName, Character, Name of Programm
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return aSettings, Array, Array with user settings for current program.
    @example aUserSettings := RU70R0101_GetUserSettings(cIdUser, 11, "RU70R01RUS")
/*/
Function RU70R0101_GetUserSettings(cIdUser, nNumSetting, cProgrammName)

    Local oStatement As Object
    Local cQuery     As Character
    Local aArea      As Array
    Local aSXKArea   As Array
    Local cAlias     As Character
    Local aSettings  As Array

    aSettings := {}
    aArea := GetArea()
    aSXKArea := SXK->(GetArea())

    cQuery := " SELECT XK_IDUSER, XK_GRUPO, XK_SEQ, XK_CONTEUD FROM " + RetSqlName("SXK")
    cQuery += " WHERE "
    cQuery += "    XK_IDUSER = ? "
    cQuery += "    AND XK_GRUPO = ? "
    cQuery += "    AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY XK_SEQ "

    oStatement := FWPreparedStatement():New()
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cIdUser)
    oStatement:SetString(2, cProgrammName)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    aSettings := Array(nNumSetting)
    Afill(aSettings, {"", Space(TEXTBOX_MAX_LENGTH)})

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While !(cAlias)->(Eof())
        If Val((cAlias)->XK_SEQ) <= nNumSetting
            aSettings[Val((cAlias)->XK_SEQ)] := (cAlias)->XK_CONTEUD
        EndIf
        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->(DbCloseArea())

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    SXK->(RestArea(aSXKArea))
    RestArea(aArea)

Return aSettings

/*/
{Protheus.doc} RU70R0102_SetUserSettings(cIdUser, nNumSetting, cProgrammName, aUserSettings)
    Save user settings.
    The data is stored in the SXK table

    @type Function
    @params cIdUser,       Character, Id current user
    @params nNumSetting,   Numeric,   Count Settings
    @params cProgrammName, Character, Name of Programm
    @params aUserSettings, Array,     Array of settings
    @author dchizhov
    @since 23.02.2023
    @version 12.1.33
    @return lIsOk, Logical, Is success.
    @example RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM, aUserSettings)
/*/
Function RU70R0102_SetUserSettings(cIdUser, nNumSetting, cProgrammName, aUserSettings)

    Local aArea    As Array
    Local aSXKArea As Array
    Local nI       As Numeric
    Local lIsOk    As Logical

    aArea := GetArea()
    aSXKArea := SXK->(GetArea())
    lIsOk := .F.

    DbSelectArea("SXK")
    SXK->(DbSetOrder(2)) // XK_IDUSER + XK_GRUPO + XK_SEQ.
    SXK->(DbGoTop())

    BeginTran() // Start a transaction.

    For nI := 1 To nNumSetting
        lIsOk := .F.
        If SXK->(DbSeek(cIdUser + cProgrammName + PadL(CValToChar(nI), 2, "0")))
            If SXK->(RecLock("SXK", .F.))
                SXK->XK_CONTEUD := aUserSettings[nI]
                SXK->(MsUnlock())

                lIsOk := .T.
            EndIf
        Else
            If SXK->(RecLock("SXK", .T.))
                SXK->XK_IDUSER := cIdUser
                SXK->XK_GRUPO := cProgrammName
                SXK->XK_SEQ := PadL(CValToChar(nI), 2, "0")
                SXK->XK_CONTEUD := aUserSettings[nI]
                SXK->(MsUnlock())

                lIsOk := .T.
            EndIf
        EndIf
    Next nI

    SXK->(MsUnlockAll()) // Unlock all anyway.

    // End transaction or rollback changes.
    If !lIsOk
        DisarmTransaction()
    EndIf
    
    EndTran()

    SXK->(RestArea(aSXKArea))
    RestArea(aArea)

Return lIsOk

/*/
{Protheus.doc} RU70R0103_GetDialogWindow(cNamesOfReport)
    Shows a window for user input 

    @type Static Function
    @params cNamesOfReport, Character, Title for window
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example aInputParameters := RU70R0103_GetDialogWindow(STR0001) // "Printing staffing"
/*/
Static Function RU70R0103_GetDialogWindow(cNamesOfReport)
    Local aResultDialog       As Array
    Local oDialog             As Object
    Local oButtonTemplatePath As Object
    Local oButtonResultPath   As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local oGridLayout         As Object
    Local oScrollBox          As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local lSeeAll             As Logical

    cIdUser := "U" + RetCodUsr()
    aResultDialog := {.F.}
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS), }, {Array(COUNT_PARAMS), }} // fields and Title for it. 

    aParamtrField[1, 2] := RU70R0106_GetEmptyValParam(.T.)
    aParamtrField[2, 2] := RU70R0106_GetEmptyValParam(.F.)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM)
    If !lSeeAll
        aUserSettings[3] := aUserSettings[4] := FwXFilial("RCL")
    EndIf

    For nI := 1 To COUNT_PARAMS - 1
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
        EndIf
    Next nI
    If !Empty(AllTrim(aUserSettings[15]))
        aParamtrField[2, 2, 15] := SToD(aUserSettings[15])
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(cNamesOfReporte)
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU70R0105_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    For nI := 1 To COUNT_PARAMS

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CValToChar(nI) + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CValToChar(nI) + "], aParamtrField[2, 2, " + CValToChar(nI) + "] := u)}"), oScrollBox, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, Iif(nI == 15, "@d","@!"),, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F., ;
        Iif(nI == 11 .Or. nI == 13, &("{|| Iif(!RU70R0104_GetFullNameOfSignature(aParamtrField[2, 2, " + CValToChar(nI) + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "]), aParamtrField[2, 2, " + CValToChar(nI + 1) + "] := '', Nil)}"), Nil), Iif(nI > 2 .And. nI < 5, !lSeeAll, nI == 12 .Or. nI == 14),,, "aParamtrField[2, 2, " + cValToChar(nI) + "]",,,, .T., .F.)

    Next nI

    oButtonTemplatePath := TButton():New(10, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 1] := PadR(cGetFile(STR0024 + "|*.dot|" + STR0025 +"|*.*", STR0021, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonResultPath := TButton():New(30, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 2] := PadR(cGetFile(STR0023 + "|*.doc|" + STR0025 +"|*.*", STR0022, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    If lSeeAll
        aParamtrField[2, 1, 3]:cF3 := "XM0"
        aParamtrField[2, 1, 4]:cF3 := "XM0"
    EndIf
    aParamtrField[2, 1, 5]:cF3 := "CTT"
    aParamtrField[2, 1, 6]:cF3 := "CTT"
    aParamtrField[2, 1, 7]:cF3 := "SQB"
    aParamtrField[2, 1, 8]:cF3 := "SQB"
    aParamtrField[2, 1, 9]:cF3 := "RCJ"
    aParamtrField[2, 1, 10]:cF3 := "RCJ"
    aParamtrField[2, 1, 11]:cF3 := "SQ3"
    aParamtrField[2, 1, 13]:cF3 := "SQ3"

    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        aResultDialog[1] := .T.

        For nI := 1 To COUNT_PARAMS - 1
            Aadd(aResultDialog, aParamtrField[2, 2, nI])
            aUserSettings[nI] := aParamtrField[2, 2, nI]
        Next nI

        Aadd(aResultDialog, aParamtrField[2, 2, 15])
        aUserSettings[15] := DToS(aParamtrField[2, 2, 15])

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU70R0104_GetFullNameOfSignature(cCode, cNameSignature)
    Forms the full name of the signatory person.

    @type Function
    @params cCod,           Character, Employee personnel number.
            cNameSignature, Character, Result Full name of signer.
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return lResult, Logical, Indicates that an employee is attached to the position.
    @example RU70R0104_GetFullNameOfSignature(cCodeSignature, @cNameSignature)
/*/
Function RU70R0104_GetFullNameOfSignature(cCode, cNameSignature)
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOME FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOME

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
        Help(,, STR0015,, STR0026, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} RU70R0105_IsAcceptButton(aUserParam)
    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example 
/*/
Static Function RU70R0105_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    lResultValidation := .T. // Default value.

    cError += Iif(Empty(AllTrim(aUserParam[1])), CRLF + "'" + STR0002 + "'", "") // "Path to pattern .dot"
    cError += Iif(Empty(AllTrim(aUserParam[2])), CRLF + "'" + STR0003 + "'", "") // "Path to save"
    cError += Iif(Empty(AllTrim(aUserParam[11]))  .Or. Empty(AllTrim(aUserParam[12])), CRLF + "'" + STR0010 + "'", "") // "Signer 1"
    cError += Iif(Empty(AllTrim(aUserParam[13])) .Or. Empty(AllTrim(aUserParam[14])), CRLF + "'" + STR0012 + "'", "") // "Signer 2"
    cError += Iif(Empty(aUserParam[15]), CRLF + "'" + STR0014 + "'", "") // "Formation date"

    If !Empty(cError)
        lResultValidation := .F.
        cError := STR0016 + CRLF + cError // "Parameters not filled:"
        MsgStop(cError, STR0015) // "Error"
    EndIf

    If lResultValidation .And. !File(aUserParam[1])
        lResultValidation := .F.
        MsgStop(STR0017, STR0015) // "Specify a valid (.dot) template", "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU70R0106_GetEmptyValParam(lTitle)
    Create Array for params or Title params

    @type Static Function
    @params lTitle, Logical, .T. - title for params; .F. - empty params
    @author dchizhov
    @since 22.02.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU70R0106_GetEmptyValParam(.F.)
/*/
Static Function RU70R0106_GetEmptyValParam(lTitle)

    Local aArray As Array

    aArray := Array(COUNT_PARAMS)

    If lTitle
        aArray[ 1] := STR0002 // "Path to pattern .dot"
        aArray[ 2] := STR0003 // "Path to save"
        aArray[ 3] := STR0004 // "Filial from"
        aArray[ 4] := STR0005 // "Filial to"
        aArray[ 5] := STR0006 // "Cost center from"
        aArray[ 6] := STR0007 // "Cost center to"
        aArray[ 7] := STR0008 // "Department from"
        aArray[ 8] := STR0009 // "Department to"
        aArray[ 9] := STR0035 // "Process code from"
        aArray[10] := STR0036 // "Process code to"
        aArray[11] := STR0010 // "Signer 1"
        aArray[12] := STR0011 // "Full name 1"
        aArray[13] := STR0012 // "Signer 2"
        aArray[14] := STR0013 // "Full name 2"
        aArray[15] := STR0014 // "Formation date"
    Else
        aArray[ 1] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 3] := Space(TamSX3("RCL_FILIAL")[1])
        aArray[ 4] := Replicate("Z", TamSX3("RCL_FILIAL")[1])
        aArray[ 5] := Space(TamSX3("RCL_CC")[1])
        aArray[ 6] := Replicate("Z", TamSX3("RCL_CC")[1])
        aArray[ 7] := Space(TamSX3("RCL_DEPTO")[1])
        aArray[ 8] := Replicate("Z", TamSX3("RCL_DEPTO")[1])
        aArray[ 9] := Space(TamSX3("RCL_PROCES")[1])
        aArray[10] := Replicate("Z", TamSX3("RCL_PROCES")[1])
        aArray[11] := Space(TamSX3("RA_CARGO")[1])
        aArray[12] := Space(TEXTBOX_MAX_LENGTH)
        aArray[13] := Space(TamSX3("RA_CARGO")[1])
        aArray[14] := Space(TEXTBOX_MAX_LENGTH)
        aArray[15] := CToD("//")
    EndIf
Return aArray
