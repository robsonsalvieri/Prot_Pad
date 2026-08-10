#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU16R01RUS.CH"

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

#DEFINE COUNT_PARAMS 16
#DEFINE NAME_OF_PROGRAM "RU16R01RUS"

#DEFINE HOURS_SALARY_ID "0032"
#DEFINE DAYS_SALARY_ID "0031"
#DEFINE CMARK_CHAR_FOR_BROWSE "1"
#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE SEPARATOR_ARRAY_INTERVAL_SYMBOL "-"

#DEFINE COD_OF_VACATION_ABCENCE "001"
#DEFINE COD_OF_SICK_ABCENCE "004"
#DEFINE COD_OF_SUMM_HOURS "001"
#DEFINE COD_OF_SUMM_RV_HOURS "055|455"

#DEFINE COD_TYPE_PAYMANT_YA "2000"
#DEFINE COD_TYPE_PAYMANT__B "2300"
#DEFINE COD_TYPE_PAYMANT_OT "2012"

/*/
{Protheus.doc} RU16R01RUS()
    Main function of routine print form T-13.

    @type Function
    @params 
    @author dchizhov
    @since 27.02.2023
    @version 12.1.33
    @return 
    @example Aadd(aRotina, {STR0217, "RU16R01RUS", 0, 11}) // "Timesheet"
/*/
Function RU16R01RUS()

    Local aInputParameters As Array
    Local oDialog          As Object
    Local aDataList        As Array
    Local lCreateReport    As Logical
    Local cPrefixNameFile  As Character

    aInputParameters := RU16R0101_GetDialogWindow(STR0001) // "Printing a time sheet"
    
    If aInputParameters[1]
        oDialog := RuHRWordPrintForm():New(NAME_OF_PROGRAM)
        oDialog:cPatternPath := aInputParameters[2]
        oDialog:cResultPath := aInputParameters[3] + " "
        cPrefixNameFile := STR0027 + "_" + STR0028 // "T13-", "Staffing"

        MsAguarde({|| ;
                      aDataList := RU16R0109_GetAllData(aInputParameters), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameFile, .T., .T.)  ;
                  }, STR0025, STR0026) // "Please wait", "Creating a timesheet file".

        If lCreateReport
            MsgInfo(STR0023, STR0022) // "Time sheet file created", "Done".
        Else
            MsgStop(STR0024, STR0014) // "Something went wrong while creating the file", "Error".
        EndIf

        FreeObj(oDialog)
        oDialog := Nil

    EndIf

Return .T.

/*/
{Protheus.doc} RU16R0109_GetAllData(aParams)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 28.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example aDataList := RU16R0109_GetAllData(aInputParameters)
/*/
Static Function RU16R0109_GetAllData(aParams)

    Local aDataArray           As Array
    Local aSRAList             As Array
    Local aArea                As Array
    Local oRuEmployeePrintForm As Object

    aArea := GetArea()
    aSRAList := {}
    aDataArray := {}
    // We form an array with structural subdivisions for printing the report.
    aSRAList := RU16R0110_GetSRAList(aParams)

    oRuEmployeePrintForm := RU16R0111_GrPrintFilter(aSRAList, aParams)
    Aadd(aDataArray, oRuEmployeePrintForm)

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU16R0110_GetSRAList(aParams)
    The function creates an array of employee.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 28.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of employee.
    @example aSRAList := RU16R0110_GetSRAList(aParams)
/*/
Static Function RU16R0110_GetSRAList(aParams)

    Local aDataArray As Array
    Local aArea      As Array
    Local cAlias     As Character
    Local cWhere     As Character
    Local aTempArr   As Array
    Local nI         As Numeric

    aArea := GetArea()
    cAlias := GetNextAlias()
    aDataArray := {}
    cWhere := "% SRA.RA_FILIAL >= '" + aParams[4] + "'" + CRLF + ;
            "AND SRA.RA_FILIAL <= '" + aParams[5] + "'" + CRLF + ;
            "AND SRA.RA_CC >= '" + aParams[6] + "'" + CRLF + ;
            "AND SRA.RA_CC <= '" + aParams[7] + "'" + CRLF + ;
            "AND SRA.RA_DEPTO = '" + aParams[8] + "'"
    If !Empty(AllTrim(aParams[9]))
        aTempArr := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParams[9]), SEPARATOR_ARRAY_VALUES_SYMBOL))
        cWhere += CRLF + "AND SRA.RA_MAT IN ('" + aTempArr[1]
        For nI := 2 To Len(aTempArr)
            cWhere += "', '" + aTempArr[nI]
        Next nI
        cWhere += "')"
    EndIf
    cWhere += CRLF + "AND '" + aParams[10] + "' LIKE CONCAT('%', RA_SITFOLH, '%')"
    cWhere += CRLF + "AND '" + aParams[11] + "' LIKE CONCAT('%', RA_CATFUNC, '%')"
    cWhere += " %"

    BeginSql Alias cAlias
    SELECT SRA.RA_MAT MAT, SRA.RA_FILIAL FIL, SQB.QB_DESCRIC QDESC, SRA.RA_ADMISSA ADMISSA, SRA.RA_DEMISSA DEMISSA
          FROM %Table:SRA% SRA
          LEFT JOIN %Table:SQB% SQB ON SQB.QB_DEPTO = SRA.RA_DEPTO AND SQB.QB_FILIAL = %XFilial:SQB% AND SQB.%NotDel%
         WHERE %Exp:cWhere%
         AND SRA.%NotDel%
        ORDER BY SRA.RA_NOMECMP, SRA.RA_MAT ASC
    EndSQL

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        If SToD((cAlias)->ADMISSA) <= aParams[13] .And. (Empty(AllTrim((cAlias)->DEMISSA)) .Or. SToD((cAlias)->DEMISSA) >= aParams[12]) ;
            .Or. RU16R0114_CheckEmplInSRDSRCForDate((cAlias)->MAT, (cAlias)->FIL, aParams[12], aParams[13])
            Aadd(aDataArray, {(cAlias)->MAT, (cAlias)->FIL, (cAlias)->QDESC})
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU16R0111_GrPrintFilter(aSRAList, aParams)
    The function creates an RuEmployeePrintForm object.

    @type Static Function
    @params aSRAList, Array, Array of emplyees for printer.
    @params aParams,  Array, Parameters entered by the user.
    @author dchizhov
    @since 28.02.2023
    @version 12.1.33
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing.
    @example oRuEmployeePrintForm := RU16R0111_GrPrintFilter(aSRAList, aParams)
/*/
Static Function RU16R0111_GrPrintFilter(aSRAList, aParams)
    
    Local nOrder   As Numeric
    local nI       As Numeric
    Local cSearch  As Character
    Local aData    As Array
    Local cDepto   As Character
    Local aArea    As Array
    Local aSRAArea As Array
    Local oRuEmployeePrintForm As Object

    nOrder := RetOrder("SRA", Iif(VerSenha(114) .And. VerSenha(115), "RA_MAT+RA_FILIAL", "RA_FILIAL+RA_MAT"))
    aArea := GetArea()
    aSRAArea := SRA->(GetArea())

    oRuEmployeePrintForm := RuEmployeePrintForm():New("", "", Array(3))

    oRuEmployeePrintForm:aDataList[1] := {"count1_empl", 0}
    oRuEmployeePrintForm:aDataList[2] := {"count1_lines", 0}
    oRuEmployeePrintForm:aDataList[3] := {"count1_column", 31}

    aData := RU16R0112_GetDataArray(aParams, Iif(Len(aSRAList) > 0, aSraList[1, 2], ""))
    For nI := 1 To Len(aData)
        Aadd(oRuEmployeePrintForm:aDataList, aData[nI])
    Next nI

    cDepto := ""

    For nI := 1 To Len(aSRAList)

        cSearch := Iif(nOrder > 1, aSRAList[nI, 1] + aSRAList[nI, 2], aSRAList[nI, 2] + aSRAList[nI, 1])
        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch, "RA_MAT"))

            RU16R0113_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aParams)

        EndIf
    Next nI

    // if no data for a table create empty string
    If oRuEmployeePrintForm:aDataList[1, 2] == 0
        oRuEmployeePrintForm:aDataList[1, 2] := 1
        oRuEmployeePrintForm:aDataList[2, 2] := 1
        For nI := 1 To 31
            Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable1_1_" + CValToChar(nI), " "})
        Next nI
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU16R0112_GetDataArray(aParams, cFil)
    The function creates an array of variables and general data according to the template.

    @type Static Function
    @params aParams, Array,  Parameters entered by the user.
    @params cFil, Character, Filial first employee SRALIST.
    @author dchizhov
    @since 28.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of variables and data.
    @example aData := RU16R0112_GetDataArray(aParams, Iif(Len(aSRAList) > 0, aSraList[1, 2], ""))
/*/
Static Function RU16R0112_GetDataArray(aParams, cFil)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local cDepartment      As Character
    Local cMounthSign      As Character
    Local aGetCoBrRusInfo  As Array
    Local cPostSign        As Character
    Local cChiefName := "" As Character
    Local cChiefPost := "" As Character
    Local cChiefTabNum     As Character
    Local cChiefFilial     As Character
    Local aSQBArea         As Array
    Local aArea            As Array
    Local cFilialForParam  As Character
    Local cTypeBranch      As Character

    aDataArray := {}
    aArea := GetArea()
    aSQBArea := SQB->(GetArea())
    cFilialForParam := ""
    If !Empty(AllTrim(Posicione("SQB", RetOrder("SQB", "QB_FILIAL+QB_DEPTO"), FwXFilial("SQB") + aParams[8], "QB_DEPTO")))

        cFilialForParam := Iif(Empty(AllTrim(SQB->QB_FILIAL)), Iif(Empty(AllTrim(cFil)), cFilAnt, cFil) , SQB->QB_FILIAL)
        // Get information about company.
        If Len(cFilialForParam) > 0
            cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, cFilialForParam)[1][2]
            aGetCoBrRusInfo := GetCoBrRUS(cFilialForParam)
            cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
            cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

            cDepartment := SQB->QB_DESCRIC
            cChiefTabNum := SQB->QB_MATRESP
            cChiefFilial := SQB->QB_FILRESP
        Else
            cOrganzationName := ""
            cOKPOCode := ""
            cDepartment := ""
            cChiefTabNum := ""
            cChiefFilial := ""
        EndIf
    EndIf

    // Get information about signer.
    cPostSign := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParams[14])) // Get name of post for signature
    cMounthSign := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aParams[17]))
    If !Empty(AllTrim(cChiefTabNum))
        cChiefName := FDesc("SRA", cChiefTabNum, "RA_NOMECMP", , cChiefFilial, RetOrder("SRA", "RA_FILIAL+RA_MAT"))
        cChiefPost := FDesc("SRA", cChiefTabNum, "RA_CARGO", , cChiefFilial, RetOrder("SRA", "RA_FILIAL+RA_MAT"))
        cChiefPost := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, cChiefPost)
    EndIf

    aAdd(aDataArray, {"cOrgName",    cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",   cOKPOCode})
    aAdd(aDataArray, {"cDepartment", cDepartment})
    aAdd(aDataArray, {"cCreateDate", DToC(aParams[17])})
    aAdd(aDataArray, {"cStartDate",  DToC(aParams[12])})
    aAdd(aDataArray, {"cFinishDate", DToC(aParams[13])})
    aAdd(aDataArray, {"cRespPost",   cPostSign})
    aAdd(aDataArray, {"cRespPerson", aParams[16]})
    aAdd(aDataArray, {"cChiefPost",  cChiefPost})
    aAdd(aDataArray, {"cChiefName",  cChiefName})
    aAdd(aDataArray, {"cDaySign1",   Day(aParams[17])})
    aAdd(aDataArray, {"cMonthSign1", cMounthSign})
    aAdd(aDataArray, {"cYearSign1",  Year(aParams[17]) % 100})
    aAdd(aDataArray, {"cPersServP",  cPostSign})
    aAdd(aDataArray, {"cPersServN",  aParams[16]})
    aAdd(aDataArray, {"cDaySign2",   Day(aParams[17])})
    aAdd(aDataArray, {"cMonthSign2", cMounthSign})
    aAdd(aDataArray, {"cYearSign2",  Year(aParams[17]) % 100})

    SQB->(RestArea(aSQBArea))
    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU16R0113_FillDataForGroupPrint(aDataPrint, aDataFrom)
    Filling array for schedule by current employee.

    @type Static Function
    @params aDataPrint, Array, Array for printing.
    @params aParams,    Array, Parameters entered by the user.
    @author dchizhov
    @since 28.02.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU16R0113_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aParams)
/*/
Static Function RU16R0113_FillDataForGroupPrint(aDataPrint, aParams)

    Local lResult   As Logical
    Local aDataArea As Array
    Local nI        As Numeric
    Local nK        As Numeric
    Local cName     As Character
    Local cDCargo   As Character
    Private aCols    As Array

    cName := AllTrim(SRA->RA_NOMECMP)
    cDCargo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SRA->RA_CARGO)[1]
    cName += Iif(Empty(AllTrim(cDCargo)), "", ", ") + cDCargo

    lResult := .T.
    aDataArea := {}

    If RU16R0117_CheckPERSPO(SRA->RA_FILIAL, aParams[12], aParams[13])
        lResult := RU16R0119_GetDataAsPONA240(@aDataArea, aParams, cName)
    Else
        lResult := RU16R0118_GetDataAsPONA280(@aDataArea, aParams, cName)
    EndIf

    If lResult .And. Len(aDataArea) > 0
        aDataPrint[1, 2] += 1
        aDataArea[1, 1] := aDataPrint[1, 2]
        For nI := 1 To 4
            aDataPrint[2, 2] += 1
            For nK := 1 To 31
                Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_" + CValToChar(nK),  aDataArea[nI, nK]})
            Next nK
        Next nI
    Else
        aDataPrint[1, 2] += 1
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2] + 1) + "_" + CValToChar(1),  aDataPrint[1, 2]})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2] + 1) + "_" + CValToChar(2),  cName})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2] + 1) + "_" + CValToChar(3),  SRA->RA_MAT})
        For nI := 1 To 4
            aDataPrint[2, 2] += 1
            For nK := Iif(nI == 1, 4, 1) To 31
                If nK == 20 .Or. (nK == 21 .And. nI % 2 == 1)
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_" + cValToChar(nK),  0})
                ElseIf (nK == 19 .And. nI < 3) .Or. (nI > 2 .And. nK + 12 > Day(LastDay(aParams[12])) .And. nK < 21)
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_" + cValToChar(nK),  STR0049}) // "X"
                Else
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_" + cValToChar(nK),  " "})
                EndIf
            Next nK
        Next nI
    EndIf

Return lResult

/*/
{Protheus.doc} RU16R0114_CheckEmplInSRDSRCForDate(cMat, cFil, dStartDate, dEndDate)
    Check exist employee in SRD or SRC between some date with salary PT.

    @type Function
    @params cMat,       Character, TN of emplpoyee.
    @params cFil,       Character, Filial of emplpoyee.
    @params dStartDate, Date,      Start date for check.
    @params dEndDate,   Date,      End date for check.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return lExist, Logical, Exist or not.
    @example RU16R0114_CheckEmplInSRDSRCForDate((cAlias)->MAT, (cAlias)->FIL, aParams[12], aParams[13])
/*/
Function RU16R0114_CheckEmplInSRDSRCForDate(cMat, cFil, dStartDate, dEndDate)

    Local lExist   As Logical
    Local aArea    As Array
    Local aRCHArea As Array
    Local nOrder   As Numeric
    Local cStart   As Character
    Local cFinish  As Character
    Local cFilCH   As Chatacter
    Local cYear    As Character
    Local cMounth  As Character
    Local cTempPer As Character

    lExist := .F.
    cYear := CValToChar(Year(dEndDate))
    cMounth := PadL(CValToChar(Month(dEndDate)), 2, "0")
    aArea := GetArea()
    aRCHArea := RCH->(GetArea())
    cFilCH := FwXFilial("RCH")
    cFilCH := PadR(SubStr(cFil, 1, Len(AllTrim(cFilCH))), TamSX3("RCH_FILIAL")[1], Space(1))
    nOrder := RetOrder("RCH", "RCH_FILIAL+RCH_ANO+RCH_MES")
    cStart  := ""
    cFinish := ""
    DbSelectArea("RCH")
    RCH->(DbSetOrder(nOrder))

    If RCH->(DbSeek(cFilCH + cYear + cMounth))
        While !RCH->(EOF()) .And. RCH->RCH_FILIAL == cFilCH .And. RCH->RCH_ANO == cYear .And. RCH->RCH_MES == cMounth
            If dEndDate >= RCH->RCH_DTINI .And. dEndDate <= RCH->RCH_DTFIM
                cFinish := RCH->RCH_PER
                Exit
            EndIf
            RCH->(DbSkip())
        EndDo
    EndIf

    cYear := CValToChar(Year(dStartDate))
    cMounth := PadL(CValToChar(Month(dStartDate)), 2, "0")

    If !Empty(AllTrim(cFinish))
        If RCH->(DbSeek(cFilCH + cYear + cMounth))
            While !RCH->(EOF()) .And. RCH->RCH_FILIAL == cFilCH .And. RCH->RCH_ANO == cYear .And. RCH->RCH_MES == cMounth
                If dStartDate >= RCH->RCH_DTINI .And. dStartDate <= RCH->RCH_DTFIM
                    cStart := RCH->RCH_PER
                    Exit
                EndIf
                RCH->(DbSkip())
            EndDo
            If !Empty(AllTrim(cStart))
                cTempPer := ""
                While !RCH->(EOF()) .And. RCH->RCH_PER <= cFinish
                    If cTempPer == RCH->RCH_PER
                        RCH->(DbSkip())
                        Loop
                    EndIf
                    cTempPer := RCH->RCH_PER
                    lExist := RU16R0115_CheckEmplInSRDSRC(cMat, cFil, cTempPer)
                    If lExist
                        Exit
                    EndIf
                    RCH->(DbSkip())
                EndDo
            EndIf
        EndIf
    EndIf

    RCH->(DbCloseArea())
    RCH->(RestArea(aRCHArea))
    RestArea(aArea)
    
Return lExist

/*/
{Protheus.doc} RU16R0115_CheckEmplInSRDSRC(cMat, cFil, cPeriod)
    Check exist employee in SRD or SRC by period with salary PT.

    @type Function
    @params cMat,    Character, TN of emplpoyee.
    @params cFil,    Character, Filial of emplpoyee.
    @params cPeriod, Character, Period for check.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return lExist, Logical, Exist or not.
    @example lExist := RU16R0115_CheckEmplInSRDSRC(cMat, cFil, cTempPer)
/*/
Function RU16R0115_CheckEmplInSRDSRC(cMat, cFil, cPeriod)

    Local lExist   As Logical
    Local aArea    As Array
    Local aSRCArea As Array
    Local aSRDArea As Array
    Local nOrder   As Numeric
    Local cPTDay   As Character
    Local cPTHour  As Character
    Local cFilSRV  As Character

    lExist := .F.
    aArea := GetArea()
    aSRCArea := SRC->(GetArea())
    aSRDArea := SRD->(GetArea())
    nOrder := RetOrder("SRV", "RV_FILIAL+RV_CODFOL")
    cFilSRV := FwXFilial("SRV")
    cPTDay := FDesc("SRV", DAYS_SALARY_ID, "RV_COD", , cFilSRV, nOrder)
    cPTHour := FDesc("SRV", HOURS_SALARY_ID, "RV_COD", , cFilSRV, nOrder)
    DbSelectArea("SRC")
    SRC->(DbSetOrder(RetOrder("SRC", "RC_FILIAL+RC_MAT+RC_PERIODO")))

    If SRC->(DbSeek(cFil + cMat + cPeriod))
        While !SRC->(EOF()) .And. SRC->RC_FILIAL == cFil .And. SRC->RC_MAT == cMat .And. SRC->RC_PERIODO == cPeriod
            If SRC->RC_PD == cPTDay .Or. SRC->RC_PD == cPTHour
                lExist := .T.
                Exit
            EndIf
            SRC->(DbSkip())
        EndDo
    EndIf
    SRC->(DbCloseArea())

    If !lExist
        DbSelectArea("SRD")
        SRD->(DbSetOrder(RetOrder("SRD", "RD_FILIAL+RD_MAT+RD_PERIODO")))

        If SRD->(DbSeek(cFil + cMat + cPeriod))
            While !SRD->(EOF()) .And. SRD->RD_FILIAL == cFil .And. SRD->RD_MAT == cMat .And. SRD->RD_PERIODO == cPeriod
                If SRD->RD_PD == cPTDay .Or. SRD->RD_PD == cPTHour
                    lExist := .T.
                    Exit
                EndIf
                SRD->(DbSkip())
            EndDo
        EndIf
        SRD->(DbCloseArea())    
    EndIf

    SRC->(RestArea(aSRCArea))
    SRD->(RestArea(aSRDArea))
    RestArea(aArea)

Return lExist

/*/
{Protheus.doc} RU16R0116_CheckEmplInSR8(cFil, cMat, dDate, cTipoAfa)
    Check Date for some tipoafa by employee.

    @type Function
    @params cFul,     Character, Filial of emplpoyee.
    @params cMat,     Character, TN of emplpoyee.
    @params dDate,    Date,      Date For checking.
    @params cTipoAfa, Character, Type of abcence.
    @author dchizhov
    @since 06.03.2023
    @version 12.1.33
    @return lExist, Logical, Exist or not.
    @example If RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListSint[nI, 2], COD_OF_VACATION_ABCENCE)
/*/
Function RU16R0116_CheckEmplInSR8(cFil, cMat, dDate, cTipoAfa)

    Local lExist     As Logical
    Local aArea      As Array
    Local cAlias     As Character
    Local cDate      As Character
    Local cFilter    As Character

    Default cTipoAfa := ""

    aArea := GetArea()
    cAlias := GetNextAlias()
    cDate := DToS(dDate)
    lExist := .F.
    cFilter := Iif(Empty(AllTrim(cTipoAfa)), "%%", "%AND SR8.R8_TIPOAFA = '" + cTipoAfa + "'%")

    BeginSql Alias cAlias
    SELECT SR8.R8_DURACAO DUR
          FROM %Table:SR8% SR8
         WHERE SR8.R8_FILIAL = %Exp:cFil%
         AND SR8.R8_MAT = %Exp:cMat%
         AND %Exp:cDate% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM
         AND SR8.%NotDel%
         %Exp:cFilter%
    EndSQL

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        If (cAlias)->DUR > 0
            lExist := .T.
            Exit
        EndIf
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)
    
Return lExist

/*/
{Protheus.doc} RU16R0117_CheckPerSPO(cFil, dDateIni, dDateFin)
    Check exist period in SPO (PONQ290).

    @type Function
    @params cFil, Character, Filial of emplpoyee.
    @params dDateIni, Date,  Start date of period.
    @params dDateFin, Date,  End date of period.
    @author dchizhov
    @since 10.03.2023
    @version 12.1.33
    @return lRes, Logical, Exist or not.
    @example If RU16R0117_CheckPERSPO(SRA->RA_FILIAL, aParams[12], aParams[13])
/*/
Function RU16R0117_CheckPerSPO(cFil, dDateIni, dDateFin)

    Local lRes     As Logical
    Local aArea    As Array
    Local aSPOArea As Character

    aArea := GetArea()
    aSPOArea := SPO->(GetArea())
    lRes := .F.

    SPO->(DbSetOrder(RetOrder("SPO", "PO_FILIAL+DTOS(PO_DATAINI)")))

    If SPO->(DbSeek(cFil + DToS(dDateIni)))
        lRes := dDateFin == SPO->PO_DATAFIM
    EndIf

    SPO->(DbCloseArea())
    SPO->(RestArea(aSPOArea))
    RestArea(aArea)
    
Return lRes

/*/
{Protheus.doc} RU16R0118_GetDataAsPONA280(aDataArea, aParams, cName)
    Get data about employee by logic PONA280.

    @type Function
    @params aDataArea, Area,  Area for data.
    @params aParams,   Area,  Parameters entered by the user.
    @params cName, Character, Full name of employee.
    @author dchizhov
    @since 10.03.2023
    @version 12.1.33
    @return lRes, Logical, Success or not.
    @example lResult := RU16R0118_GetDataAsPONA280(@aDataArea, aParams, cName)
/*/
Function RU16R0118_GetDataAsPONA280(aDataArea, aParams, cName)

    Local lRes       As Logical
    Local aArea      As Array
    Local nI         As Numeric
    Local nK         As Numeric
    Local aTabPadrao As Array
    Local aTabCalend As Array
    Local nIndex     As Numeric
    Local nX         As Numeric
    Local nY         As Numeric
    Local aArrayHour As Array
    Local aListBox   As Array
    Local aListSint  As Array
    Local aAdicLeg   As Array
    Local aMarcacoes As Array
    Local aHeader    As Array
    Local nSvUsado   As Numeric
    Local lHour      As Logical
    Local nPosData   As Numeric
    Local nPosFlag   As Numeric
    Local nPosCod    As Numeric
    Local nPosQuant  As Numeric
    Local nSummHours As Numeric
    Local nOrdcAlias As Numeric
    Local bSeekFor   As Block
    Local aDaysHour  As Array
    Local lRVHours   As Logical

    aArea := GetArea()
    lRes := .F.
    aAdicLeg := { {"BPMSEDT1A", OemToAnsi(STR0041)} ,; // "Pending Devergency"
                  {"BPMSEDT3A", OemToAnsi(STR0042)} ;  // "Divergene Analized "
    }
    aListBox := {}
    aListSint := {}
    aMarcacoes := {}
    aHeader := {}
    nOrdcAlias := RetOrder("SPC" , "PC_FILIAL+PC_MAT+PC_PD+PC_DATA+PC_TPMARCA+PC_CC")
    bSeekFor := {||    SPC->(PC_FILIAL + PC_MAT) == SRA->RA_FILIAL + SRA->RA_MAT .AND. SPC->(!EMPTY(PC_DATA) .AND. PC_DATA >= aParams[12] .AND. PC_DATA <= aParams[13]) }
    
    If CriaCalend(aParams[12]  ,;    // 01 -> First period
               aParams[13]     ,;    // 02 -> Final Period
               SRA->RA_TNOTRAB ,;    // 03 -> Work shift
               SRA->RA_SEQTURN ,;    // 04 -> Shift Sequence
               @aTabPadrao     ,;    // 05 -> Standard Time Table
               @aTabCalend     ,;    // 06 -> Appointment calendar
               SRA->RA_FILIAL  ,;    // 07 -> Branch
               SRA->RA_MAT     ,;    // 08 -> Registration
               SRA->RA_CC      ,;    // 09 -> Cost center
               NIL             ,;    // 10 -> Array with Shift Swaps
               NIL             ,;    // 11 -> Array with All Period Exceptions
               NIL             ,;    // 12 -> A Query is executed to assemble the Standard Table
                .T.             ;     // 13 -> The calendar synchronization function is executed
               )
        GetCalendListBox( @aListBox, aTabCalend, @aListSint, , aAdicLeg, .T.)
        lRes := GetMarcacoes(@aMarcacoes    ,;    // 01 -> Employee Marks
                    @aTabCalend             ,;    // 02 -> Appointment Calendar (Can be Modified in fDiasFolga()
                    @aTabPadrao             ,;    // 03 -> Standard Table
                    NIL                     ,;    // 04 -> Work shifts
                    aParams[12]             ,;    // 05 -> First period
                    aParams[13]             ,;    // 06 -> Final Period
                    SRA->RA_FILIAL          ,;    // 07 -> Branch
                    SRA->RA_MAT             ,;    // 08 -> Registration
                    SRA->RA_TNOTRAB         ,;    // 09 -> Shift
                    SRA->RA_SEQTURN         ,;    // 10 -> Shift Sequence
                    SRA->RA_CC              ,;    // 11 -> Cost center
                    "SP8"                   ,;    // 12 -> Alias for Load Tags
                    .T.                     ,;    // 13 -> Recno is loaded in aMarcacoes
                    .T.                     ,;    // 14 -> Considered Ordered Only
                    NIL                     ,;    // 15 -> Check Auto Clearances
                    NIL                     ,;    // 16 -> Previous Month Day Off Event Recorded
                    /*lGetMarcAuto*/        ,;    // 17 -> Automatic Markup Loads
                    /*@aRecsMarcAutDele*/    ;    // 18 -> Automatic Tag Records that should be Deleted
                    )
        lRes := lRes .And. (!Empty(aListBox))
        aCols := {}
        FillGetDados(2                ,; // 1-nOpcx - number corresponding to the operation to be performed, example: 3 - inclusion, 4 alteration, etc.;
                     "SPC"            ,; // 2-cAlias - area to be used;
                     nOrdcAlias       ,; // 3-nOrder - order corresponding to the index key to fill the acols;
                     SRA->RA_FILIAL + SRA->RA_MAT     ,; // 4-cSeekKey - key used in positioning the area to fill in the acol;
                     {||SPC->PC_FILIAL + SPC->PC_MAT} ,; // 5-bSeekWhile - block containing the expression to be compared with cSeekKey in the While condition.
                     bSeekFor              ,; // 6-uSeekFor - can be used in two ways: 1- code-block, condition to be used to execute the While Loop; 2nd - two-dimensional array containing N.. conditions, in which the 1st element is the conditional block, the 2nd is block to be executed if true and the 3rd is block to be executed if false, example {{bCondition1, bTrue1, bFalse1}, {bCondition2, bTrue2, bFalse2}.. bConditionN, bTrueN, bFalseN};
                     {"PC_MAT", "PC_NOME"} ,; // 7-aNoFields - array containing fields that will not be in aHeader;
                     NIL                   ,; // 8-aYesFields - array containing only the fields that will be in aHeader;
                     NIL                   ,; // 9-lOnlyYes - if true, display only user fields;
                     NIL                   ,; // 10-cQuery - query to be executed to fill in the acols(Note. There can't be a MEMO);
                     NIL                   ,; // 11-bMontCols - block containing specific function to fill aCols; Example:{|| MountAcols(cAlias)}
                     .F.                   ,; // 12-lEmpty
                     aHeader               ,; // 13-aHeaderAux
                     NIL                   ,; // 14-aColAux
                     NIL                    ; // 15-bAfterCols - Code block to be executed after adding a line to Acols
        )
        nPosData := AScan(aHeader, {|X| AllTrim(X[2]) == "PC_DATA"})
        nPosFlag := AScan(aHeader, {|X| AllTrim(X[2]) == "PC_FLAG"})
        nPosCod := AScan(aHeader, {|X| AllTrim(X[2]) == "PC_PD"})
        nPosQuant := AScan(aHeader, {|X| AllTrim(X[2]) == "PC_QUANTC"})
        nSvUsado := Len(aHeader) + 1
        aArrayHour := AClone(aCols)
        aSort(aArrayHour, , , {|X, Y| DtoS(X[1]) + X[2] + X[4] < DtoS(Y[1]) + Y[2] + Y[4]})
    Else
        lRes := .F.
    EndIf
    
    If lRes
        ASort(aMarcacoes, , , {|X, Y| X[3] < Y[3]})
        aDataArea := {Array(31), Array(31), Array(31), Array(31)}
        For nI := 1 To 4
            AFill(aDataArea[nI], " ")
        Next nI
        aDataArea[1, 2] := cName
        aDataArea[1, 3] := SRA->RA_MAT
        aDataArea[1, 20] := aDataArea[2, 20] := aDataArea[3, 20] := aDataArea[4, 20] := 0
        aDataArea[1, 21] := aDataArea[3, 21] := 0
        aDaysHour := {0, 0, 0} // B-count, OT-count, PR-count
        For nI := 1 To Len(aListSint)
            lHour := .F.
            lRVHours := .F.
            nSummHours := 0
            If nI < 16
                nX := 1
                nY := nI + 3
            Else
                nX := 3
                nY := nI - 12
            EndIf
            nIndex := AScan(aMarcacoes, {|X| X[2] > 0 .And. X[3] == PadL(CValToChar(nI), 2, "0")})
            If aListSint[nI, 1]:CNAME == "BR_VERDE" .Or. aListSint[nI, 1]:CNAME == "LIGHTBLU" // Green OR Blue square
                If nIndex > 0
                    aDataArea[nX, nY] := STR0043 // YA
                    lHour := .T.
                Else
                    aDataArea[nX, nY] := STR0044 // PR
                    aDaysHour[3] += 1
                EndIf
            ElseIf aListSint[nI, 1]:CNAME == "BR_PRETO" // Gray
                If RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListSint[nI, 2], COD_OF_VACATION_ABCENCE)
                    aDataArea[nX, nY] := STR0047 // "OT"
                    aDaysHour[2] += 1
                ElseIf RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListSint[nI, 2], COD_OF_SICK_ABCENCE)
                    aDataArea[nX, nY] := STR0048 // "B"
                    aDaysHour[1] += 1
                ElseIf !RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListSint[nI, 2])
                    If nIndex > 0
                        aDataArea[nX, nY] := STR0046 // "RV"
                        lHour := .T.
                        lRVHours := .T.
                    Else
                        aDataArea[nX, nY] := STR0045 // "V"
                    EndIf
                EndIf
            EndIf
            If lHour
                nIndex := AScan(aArrayHour, {|X| X[nPosData] == aListSint[nI, 2]})
                If nIndex > 0
                    While nIndex <= Len(aArrayHour) .And. aArrayHour[nIndex, nPosData] == aListSint[nI, 2]
                        If (!aArrayHour[nIndex, nSvUsado] .Or. (aArrayHour[nIndex, nSvUsado] .And. "I" <> aArrayHour[nIndex, nPosFlag])) ;
                            .And. (!lRVHours .And. aArrayHour[nIndex, nPosCod] == COD_OF_SUMM_HOURS .Or. lRVHours .And. aArrayHour[nIndex, nPosCod] $ COD_OF_SUMM_RV_HOURS)
                            nSummHours += aArrayHour[nIndex, nPosQuant]
                        EndIf
                        nIndex += 1
                    EndDo
                EndIf
                aDataArea[nX + 1, nY] := nSummHours
                aDataArea[nX, 20] += 1
                aDataArea[nX + 1, 20] += nSummHours
            EndIf
        Next nI
        aDataArea[1, 21] := aDataArea[1, 20] + aDataArea[3, 20]
        aDataArea[3, 21] := aDataArea[2, 20] + aDataArea[4, 20]
        aDataArea[1, 19] := aDataArea[2, 19] := STR0049 // "X"

        For nI := Len(aListSint) + 1 To 31
            nX := 3
            nY := nI - 12
            aDataArea[nX, nY] := aDataArea[nX + 1, nY] := STR0049 // "X"
        Next nI

        nI := 1
        nK := 1
        If aDataArea[1, 21] > 0
            aDataArea[nI, 22] := COD_TYPE_PAYMANT_YA
            aDataArea[nI, 23] := "23"
            aDataArea[nI, 24] := AllTrim(CValToChar(aDataArea[1, 21])) + " (" + AllTrim(CValToChar(aDataArea[3, 21])) + ")"
            nI += 1
        EndIf
        If aDaysHour[1] > 0 // Exist B-marks
            aDataArea[nI, 22] := COD_TYPE_PAYMANT__B
            aDataArea[nI, 23] := "69"
            aDataArea[nI, 24] := aDaysHour[1]
            aDataArea[nK, 28] := STR0048 // "B"
            aDataArea[nK, 29] := aDaysHour[1]
            nI += 1
            nK += 1
        EndIf
        If aDaysHour[2] > 0 // Exist OT-marks
            aDataArea[nI, 22] := COD_TYPE_PAYMANT_OT
            aDataArea[nI, 23] := "23"
            aDataArea[nI, 24] := aDaysHour[2]
            aDataArea[nK, 28] := STR0047 // "OT"
            aDataArea[nK, 29] := aDaysHour[2]
            nI += 1
            nK += 1
        EndIf
        If aDaysHour[3] > 0 // Exist PR-marks
            aDataArea[nI, 22] := " "
            aDataArea[nI, 23] := " "
            aDataArea[nI, 24] := aDaysHour[3]
            nI += 1
        EndIf

    EndIf

    RestArea(aArea)

Return lRes

/*/
{Protheus.doc} RU16R0119_GetDataAsPONA240(aDataArea, aParams, cName)
    Get data about employee by logic PONA240.

    @type Function
    @params aDataArea, Area,  Area for data.
    @params aParams,   Area,  Parameters entered by the user.
    @params cName, Character, Full name of employee.
    @author dchizhov
    @since 13.03.2023
    @version 12.1.33
    @return lRes, Logical, Success or not.
    @example lResult := RU16R0119_GetDataAsPONA240(@aDataArea, aParams, cName)
/*/
Function RU16R0119_GetDataAsPONA240(aDataArea, aParams, cName)

    Local lRes       As Logical
    Local aArea      As Array
    Local nI         As Numeric
    Local nK         As Numeric
    Local nIndex     As Numeric
    Local nX         As Numeric
    Local nY         As Numeric
    Local cColor     As Character
    Local aTabPadrao As Array
    Local aTabCalend As Array
    Local aLastApo   As Array
    Local aListBox   As Array
    Local aMarcacoes As Array
    Local lHour      As Logical
    Local nSummHours As Numeric
    Local aDaysHour  As Array
    Local dCurDate   As Date

    aArea := GetArea()
    lRes := .F.
    
    If GetMarcacoes(@aMarcacoes           ,; // 01 -> Employee Marks
                    @aTabCalend           ,; // 02 -> Appointment Calendar (Can be Modified in fDiasFolga()
                    @aTabPadrao           ,; // 03 -> Standard Table
                    NIL                   ,; // 04 -> Work shifts
                    aParams[12]           ,; // 05 -> First period
                    aParams[13]           ,; // 06 -> Final Period
                    SRA->RA_FILIAL        ,; // 07 -> Branch
                    SRA->RA_MAT           ,; // 08 -> Registration
                    SRA->RA_TNOTRAB       ,; // 09 -> Shift
                    SRA->RA_SEQTURN       ,; // 10 -> Shift Sequence
                    SRA->RA_CC            ,; // 11 -> Cost center
                    "SPG"                 ,; // 12 -> Alias for Load Tags
                    .T.                   ,; // 13 -> Recno is loaded in aMarcacoes
                    .T.                   ,; // 14 -> Considered Ordered Only
                    NIL                   ,; // 15 -> Check Auto Clearances
                    NIL                   ,; // 16 -> Previous Month Day Off Event Recorded
                    /*.T.*/               ,; // 17 -> Automatic Markup Loads
                    /*@aRecsMarcAutDele*/  ; // 18 -> Automatic Tag Records that should be Deleted
                          )
        GetCalendListBox(@aListBox, aTabCalend)
        aLastApo := GetLastApo(aParams[12], aParams[13], "SPH")
        lRes := !Empty(aListBox) .And. (Len(aLastApo) > 0 .Or. Len(aMarcacoes) > 0)
    Else
        lRes := .F.
    EndIf
    
    If lRes
        ASort(aListBox, , , {|X, Y| X[2] < Y[2] .Or. (X[2] == Y[2] .And. ValType(X[1]) == "O")})
        aDataArea := {Array(31), Array(31), Array(31), Array(31)}
        For nI := 1 To 4
            AFill(aDataArea[nI], " ")
        Next nI
        aDataArea[1, 2] := cName
        aDataArea[1, 3] := SRA->RA_MAT
        aDataArea[1, 20] := aDataArea[2, 20] := aDataArea[3, 20] := aDataArea[4, 20] := 0
        aDataArea[1, 21] := aDataArea[3, 21] := 0
        aDaysHour := {0, 0, 0} // B-count, OT-count, PR-count
        For nI := 1 To aParams[13] - aParams[12] + 1
            lHour := .F.
            nSummHours := 0
            dCurDate := aParams[12] + nI - 1
            If nI < 16
                nX := 1
                nY := nI + 3
            Else
                nX := 3
                nY := nI - 12
            EndIf
            nIndex := AScan(aListBox, {|X| X[2] == dCurDate .And. ValType(X[1]) == "O"})
            If nIndex == 0
                cColor := ""
            Else
                cColor := aListBox[nIndex, 1]:CNAME
            EndIf
            If cColor == "BR_VERDE" .Or. cColor == "LIGHTBLU" // Green OR Blue square
                If aListBox[nIndex, 4] > "00.00"
                    aDataArea[nX, nY] := STR0043 // YA
                    lHour := .T.
                Else
                    aDataArea[nX, nY] := STR0044 // PR
                    aDaysHour[3] += 1
                EndIf
            ElseIf cColor == "BR_PRETO" // Gray
                If RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListBox[nIndex, 2], COD_OF_VACATION_ABCENCE)
                    aDataArea[nX, nY] := STR0047 // "OT"
                    aDaysHour[2] += 1
                ElseIf RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListBox[nIndex, 2], COD_OF_SICK_ABCENCE)
                    aDataArea[nX, nY] := STR0048 // "B"
                    aDaysHour[1] += 1
                ElseIf !RU16R0116_CheckEmplInSR8(SRA->RA_FILIAL, SRA->RA_MAT, aListBox[nIndex, 2])
                    If aListBox[nIndex, 4] > "00.00"
                        aDataArea[nX, nY] := STR0046 // "RV"
                        lHour := .T.
                    Else
                        aDataArea[nX, nY] := STR0045 // "V"
                    EndIf
                EndIf
            EndIf
            If lHour
                If nIndex > 0
                    While aListBox[nIndex, 2] == dCurDate .And. nIndex < Len(aListBox)
                        nSummHours += Val(aListBox[nIndex, 13])
                        nIndex += 1
                    EndDo
                EndIf
                aDataArea[nX + 1, nY] := nSummHours
                aDataArea[nX, 20] += 1
                aDataArea[nX + 1, 20] += nSummHours
            EndIf
        Next nI
        aDataArea[1, 21] := aDataArea[1, 20] + aDataArea[3, 20]
        aDataArea[3, 21] := aDataArea[2, 20] + aDataArea[4, 20]
        aDataArea[1, 19] := aDataArea[2, 19] := STR0049 // "X"

        For nI := aParams[13] - aParams[12] + 2 To 31
            nX := 3
            nY := nI - 12
            aDataArea[nX, nY] := aDataArea[nX + 1, nY] := STR0049 // "X"
        Next nI

        nI := 1
        nK := 1
        If aDataArea[1, 21] > 0
            aDataArea[nI, 22] := COD_TYPE_PAYMANT_YA
            aDataArea[nI, 23] := "23"
            aDataArea[nI, 24] := AllTrim(CValToChar(aDataArea[1, 21])) + " (" + AllTrim(CValToChar(aDataArea[3, 21])) + ")"
            nI += 1
        EndIf
        If aDaysHour[1] > 0 // Exist B-marks
            aDataArea[nI, 22] := COD_TYPE_PAYMANT__B
            aDataArea[nI, 23] := "69"
            aDataArea[nI, 24] := aDaysHour[1]
            aDataArea[nK, 28] := STR0048 // "B"
            aDataArea[nK, 29] := aDaysHour[1]
            nI += 1
            nK += 1
        EndIf
        If aDaysHour[2] > 0 // Exist OT-marks
            aDataArea[nI, 22] := COD_TYPE_PAYMANT_OT
            aDataArea[nI, 23] := "23"
            aDataArea[nI, 24] := aDaysHour[2]
            aDataArea[nK, 28] := STR0047 // "OT"
            aDataArea[nK, 29] := aDaysHour[2]
            nI += 1
            nK += 1
        EndIf
        If aDaysHour[3] > 0 // Exist PR-marks
            aDataArea[nI, 22] := " "
            aDataArea[nI, 23] := " "
            aDataArea[nI, 24] := aDaysHour[3]
            nI += 1
        EndIf

    EndIf

    RestArea(aArea)

Return lRes

// /********** functions about parametrs *************/

/*/
{Protheus.doc} RU16R0101_GetDialogWindow(cNamesOfReport)
    Shows a window for user input.

    @type Static Function
    @params cNamesOfReport, Character, Title for window.
    @author dchizhov
    @since 27.02.2023
    @version 12.1.33
    @return aResultDialog, Array, Array of current parametr.
    @example aInputParameters := RU16R0101_GetDialogWindow(STR0001) // "Printing a time sheet"
/*/
Static Function RU16R0101_GetDialogWindow(cNamesOfReport)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local oButtonTemplatePath As Object
    Local oButtonResultPath   As Object
    Local oScrollBox          As Object
    Local aUserSettings := {} As Array
    Local oGridLayout         As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local cValidPer           As Character
    Local cChangeExec         As Character
    Local lSeeAll             As Logical
    Private aParamtrField     As Array

    cIdUser := "U" + RetCodUsr()
    aResultDialog := {.F.}
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS), }, {Array(COUNT_PARAMS), }} // fields and Title for it. 

    aParamtrField[1, 2] := RU16R0103_GetEmptyValParam(.T.)
    aParamtrField[2, 2] := RU16R0103_GetEmptyValParam(.F.)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM)
    If !lSeeAll
        aUserSettings[3] := aUserSettings[4] := FwXFilial("SRA")
    EndIf

    For nI := 1 To COUNT_PARAMS
        If !(ValType(aUserSettings[nI]) $ "A|U")
            Do Case
                Case nI == 11
                    aParamtrField[2, 2, nI] := SToD(aUserSettings[nI])
                Case nI == 12
                    aParamtrField[2, 2, nI] := SToD(aUserSettings[nI])
                Case nI == 16
                    aParamtrField[2, 2, nI] := SToD(aUserSettings[nI])
                Otherwise
                    aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            EndCase
        EndIf
    Next nI

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(cNamesOfReporte)
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU16R0102_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    For nI := 1 To COUNT_PARAMS
        cValidPer := Iif(nI == 9, "{|| fSituacao()}", Iif(nI == 10, "{|| fCategoria()}", Nil))
        cChangeExec := Iif(nI == 13, "{|| RU16R0120_GetDataAboutSigner(aParamtrField[2, 2, " + CValToChar(nI) + "], @aParamtrField[2, 2, " + CValToChar(nI + 1) + "], " + ;
        "@aParamtrField[2, 2, " + CValToChar(nI + 2) + "], '1'), aParamtrField[2, 1, " + CValToChar(nI + 2) + "]:CtrlRefresh(), aParamtrField[2, 1, " + CValToChar(nI + 1) + "]:CtrlRefresh() }", ;
        Iif(nI == 14, "{|| RU16R0120_GetDataAboutSigner(@aParamtrField[2, 2, " + CValToChar(nI - 1) + "], aParamtrField[2, 2, " + CValToChar(nI) + "], " + ;
        "@aParamtrField[2, 2, " + CValToChar(nI + 1) + "], '2'), aParamtrField[2, 1, " + CValToChar(nI + 1) + "]:CtrlRefresh(), aParamtrField[2, 1, " + CValToChar(nI - 1) + "]:CtrlRefresh()}", Nil))

        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CValToChar(nI) + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CValToChar(nI) + "], aParamtrField[2, 2, " + CValToChar(nI) + "] := u)}"), oScrollBox, TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, Iif(nI == 11, "@d","@!"),Iif(nI == 9 .Or. nI == 10, &(cValidPer), Nil), 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F., ;
        Iif(nI == 13 .Or. nI == 14, &(cChangeExec), Nil), Iif(nI == 3 .Or. nI == 4, !lSeeAll, nI == 15),,, "aParamtrField[2, 2, " + cValToChar(nI) + "]",,,, .T., .F.)

    Next nI

    oButtonTemplatePath := TButton():New(10, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 1] := Padr(cGetFile(STR0020 + "|*.dot|" + STR0021 +"|*.*", STR0017, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonResultPath := TButton():New(30, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 2] := Padr(cGetFile(STR0019 + "|*.doc|" + STR0021 +"|*.*", STR0018, 1, 'C:\', .T., GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE, .T.), TEXTBOX_MAX_LENGTH, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonSRAList := TButton():New(150, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 8] := Padr(RU16R0104_GetSraList(aParamtrField[2, 2, 8]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    aParamtrField[2, 1, 14]:cF3 := "SRA"
    If lSeeAll
        aParamtrField[2, 1, 3]:cF3 := "XM0"
        aParamtrField[2, 1, 4]:cF3 := "XM0"
        aParamtrField[2, 1, 14]:cF3 := "SRA02"
    EndIf
    aParamtrField[2, 1, 5]:cF3 := "CTT"
    aParamtrField[2, 1, 6]:cF3 := "CTT"
    aParamtrField[2, 1, 7]:cF3 := "SQB"

    aParamtrField[2, 1, 13]:cF3 := "SQ3"

    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        aResultDialog[1] := .T.

        For nI := 1 To COUNT_PARAMS
            Aadd(aResultDialog, aParamtrField[2, 2, nI])
            aUserSettings[nI] := Iif(nI == 11 .Or. nI == 12 .Or. nI == 16, DToS(aParamtrField[2, 2, nI]), aParamtrField[2, 2, nI])
        Next nI

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS, NAME_OF_PROGRAM, aUserSettings)

    EndIf

Return aResultDialog

/*/
{Protheus.doc} RU16R0102_IsAcceptButton(aUserParam)
    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 27.02.2023
    @version 12.1.33
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example 
/*/
Static Function RU16R0102_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    lResultValidation := .T. // Default value.

    cError += Iif(Empty(AllTrim(aUserParam[1])), CRLF + "'" + STR0002 + "'", "") // "Path to pattern .dot"
    cError += Iif(Empty(AllTrim(aUserParam[2])), CRLF + "'" + STR0003 + "'", "") // "Path to save"
    cError += Iif(Empty(AllTrim(aUserParam[7])), CRLF + "'" + STR0008 + "'", "") // "Department"
    cError += Iif(Empty(aUserParam[11]), CRLF + "'" + STR0034 + "'", "") // "Start date"
    cError += Iif(Empty(aUserParam[12]), CRLF + "'" + STR0035 + "'", "") // "Final date"
    cError += Iif(Empty(AllTrim(aUserParam[13])) .Or. Empty(AllTrim(aUserParam[14])) .Or. Empty(AllTrim(aUserParam[15])), CRLF + "'" + STR0011 + "'", "") // "Signer"
    cError += Iif(Empty(aUserParam[16]), CRLF + "'" + STR0013 + "'", "") // "Formation date"

    If !Empty(cError)
        lResultValidation := .F.
        cError := STR0015 + CRLF + cError // "Parameters not filled:"
        MsgStop(cError, STR0014) // "Error"
    EndIf

    If lResultValidation .And. !File(aUserParam[1])
        lResultValidation := .F.
        MsgStop(STR0016, STR0014) // "Specify a valid (.dot) template", "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU16R0103_GetEmptyValParam(lTitle)
    Create Array for params or Title params.

    @type Static Function
    @params lTitle, Logical, .T. - title for params; .F. - empty params.
    @author dchizhov
    @since 27.02.2023
    @version 12.1.33
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU16R0103_GetEmptyValParam(.F.)
/*/
Static Function RU16R0103_GetEmptyValParam(lTitle)

    Local aArray As Array

    aArray := Array(COUNT_PARAMS)

    If lTitle
        aArray[ 1] := STR0002 // "Path to pattern .dot"
        aArray[ 2] := STR0003 // "Path to save"
        aArray[ 3] := STR0004 // "Filial from"
        aArray[ 4] := STR0005 // "Filial to"
        aArray[ 5] := STR0006 // "Cost center from"
        aArray[ 6] := STR0007 // "Cost center to"
        aArray[ 7] := STR0008 // "Department"
        aArray[ 8] := STR0031 // "TN"
        aArray[ 9] := STR0032 // "State"
        aArray[10] := STR0033 // "Type"
        aArray[11] := STR0034 // "Start date"
        aArray[12] := STR0035 // "Final date"
        aArray[13] := STR0011 // "Signer"
        aArray[14] := STR0050 // "TN signer"
        aArray[15] := STR0012 // "Full name"
        aArray[16] := STR0013 // "Formation date"
    Else
        aArray[ 1] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 2] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 3] := Space(TamSX3("RA_FILIAL")[1])
        aArray[ 4] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        aArray[ 5] := Space(TamSX3("RA_CC")[1])
        aArray[ 6] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 7] := Space(TamSX3("RA_DEPTO")[1])
        aArray[ 8] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 9] := Space(5)
        aArray[10] := Space(15)
        aArray[11] := CToD("//")
        aArray[12] := CToD("//")
        aArray[13] := Space(TamSX3("RA_CARGO")[1])
        aArray[14] := Space(TamSX3("RA_MAT")[1])
        aArray[15] := Space(TEXTBOX_MAX_LENGTH)
        aArray[16] := CToD("//")
    EndIf

Return aArray

/*/
{Protheus.doc} RU16R0104_GetSraList(cSRAList)
    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting employees
    into processing bar MsAguarde.

    @type Function
    @params cSRAList, Character, Last list of selected employee numbers.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return cNumbersList, Character, New list of selected employee numbers.
    @example cSRAlList := ::GetSRAList(cSRAlList)
/*/
Function RU16R0104_GetSraList(cSRAList)

    Local aSRAList     As Array
    Local cNumbersList As Character
    Local aTempNumber  As Array
    Local aArea        As Array
    Local lOk          As Logical

    aSRAList := {}
    aArea := GetArea()
    aSRAList := StrTokArr(AllTrim(cSRAList), SEPARATOR_ARRAY_VALUES_SYMBOL)
    aSRAList := RU16R0105_TransformArrayWithInterval(aSRAList)
    aTempNumber := {}

    MsAguarde({|| lOk := RU16R0107_MakeDialogTemporaryTableSRA(aSRAList, @aTempNumber)}, STR0038, STR0039) // "Please wait", "Formation of a data table".

    If lOk
        cNumbersList := RU16R0106_TransformArrayToSTR(aTempNumber)
    Else
        cNumbersList := cSRAList
    EndIf

    RestArea(aArea)

Return cNumbersList

/*/
{Protheus.doc} RU16R0105_TransformArrayWithInterval(aSRAList)
    Transform array of employee with interval of TN into array without.

    @type Function
    @params aSRAList, Array, Input array.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return aTNList, Array, Array without interval.
    @example aSRAList := RU16R0105_TransformArrayWithInterval(aSRAList)
/*/
Function RU16R0105_TransformArrayWithInterval(aSRAList)

    Local cTempNumber As Character
    Local cAlias      As Character
    Local cLenTNumber As Character
    Local aTempNumber As Array
    Local aTNList     As Array
    Local nI          As Numeric
    Local aArea       As Array

    aTNList := {}
    aArea := GetArea()

    For nI := 1 To Len(aSRAList)
        cTempNumber := AllTrim(aSRAList[nI])
        aTempNumber := StrTokArr(cTempNumber, SEPARATOR_ARRAY_INTERVAL_SYMBOL)
        cTempNumber := aTempNumber[1]
        If Len(aTempNumber) > 1
            cLenTNumber := aTempNumber[Len(aTempNumber)]
            cAlias := GetNextAlias()
            BeginSql Alias cAlias
                SELECT SRA.RA_MAT MAT
                FROM %Table:SRA% SRA
                WHERE SRA.RA_MAT BETWEEN %Exp:cTempNumber% AND %Exp:cLenTNumber%
                AND SRA.%NotDel%
            EndSQL

            (cAlias)->(DbGoTop())

            While !(cAlias)->(EOF())
                Aadd(aTNList, (cAlias)->MAT)
                (cAlias)->(DbSkip())
            EndDo
            (cAlias)->(DbCloseArea())
        Else
            Aadd(aTNList, cTempNumber)
        EndIf
    Next nI
    
    RestArea(aArea)
    
Return aTNList

/*/
{Protheus.doc} RU16R0106_TransformArrayToSTR(aSRAList, lInterval)
    Transform array of employee without interval into str.

    @type Function
    @params aSRAList , Array,   Input array.
    @params lInterval, Logical, Transform into interval. (Nil - Ask user)
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return cSRAList, Character, String of employee list.
    @example cNumbersList := RU16R0106_TransformArrayToSTR(aTempNumber)
/*/
Function RU16R0106_TransformArrayToSTR(aSRAList, lInterval)

    Local cSRAList As Character
    Local aArea    As Array
    Local aSRAArea As Array
    Local aTemp    As Array
    Local nOrder   As Numeric
    Local lSeeAll  As Logical
    Local cKey     As Character
    Local nI       As Numeric
    Local cSTR1T   As Character
    Local cSTR2T   As Character
    Local lInterv  As Logical

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    If lSeeAll
        nOrder := RetOrder("SRA", "RA_MAT")
        cKey := ""
    Else
        nOrder := RetOrder("SRA", "RA_FILIAL+RA_MAT")
        cKey := FwXFilial("SRA")
    EndIf
    aTemp := AClone(aSRAList)
    ASort(aTemp)
    cSRAList := ""
    If lInterval == Nil
        lInterv := MsgYesNo(STR0040)
    Else
        lInterv := lInterval
    EndIf
    If lInterv

        DbSelectarea("SRA")
        SRA->(DbSetOrder(nOrder))
        For nI := 1 To Len(aTemp)
            cSTR1T := ""
            cSTR2T := ""
            If SRA->(DbSeek(cKey + aTemp[nI]))
                cSTR1T := aTemp[nI]
                While !SRA->(EOF()) .And. SRA->RA_MAT == aTemp[nI]
                    cSTR2T := aTemp[nI]
                    nI += 1
                    SRA->(DbSkip())
                    If nI > Len(aTemp)
                        Exit
                    EndIf
                EndDo
                If cSTR1T <> cSTR2T
                    cSTR1T += SEPARATOR_ARRAY_INTERVAL_SYMBOL + cSTR2T + SEPARATOR_ARRAY_VALUES_SYMBOL
                Else
                    cSTR1T += SEPARATOR_ARRAY_VALUES_SYMBOL
                EndIf
                nI -= 1
            Else
                cSTR1T := aTemp[nI] + SEPARATOR_ARRAY_VALUES_SYMBOL
            EndIf
            If Len(cSRAList + cSTR1T) <= SRA_STR_MAX_LENGHT
                cSRAList += cSTR1T
            Else
                Exit
            EndIf
        Next nI
        SRA->(DbCloseArea())
    Else
        For nI := 1 To Len(aTemp)
            If Len(cSRAList + aTemp[nI] + SEPARATOR_ARRAY_VALUES_SYMBOL) <= SRA_STR_MAX_LENGHT
                cSRAList += aTemp[nI] + SEPARATOR_ARRAY_VALUES_SYMBOL
            Else
                Exit
            EndIf
        Next nI
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return cSRAList

/*/
{Protheus.doc} RU16R0107_MakeDialogTemporaryTableSRA(cSRAlList)
    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting employees.

    @type Function
    @params cSraList, Array, Last list of selected employee numbers.
    @params aRetList, Array, List of selected into window employee numbers.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return lOk, Logical, Ok or cancell.
    @example MsAguarde({|| aSRAList := RU16R0107_MakeDialogTemporaryTableSRA(aSRAList, @aTempNumber)}, STR0038, STR0039)
/*/
Function RU16R0107_MakeDialogTemporaryTableSRA(aSRAlList, aRetList)

    Local cAlias        As Character
    Local aFields       As Array
    Local aColumns      As Array
    Local oMark         As Object
    Local oDlg          As Object
    Local aNumbersList  As Array
    Local oTempTable    As Object
    Local cQuery        As Character
    Local aSRAArea      As Array
    Local aSraTempData  As Array
    Local nSraCount     As Numeric
    Local nI            As Numeric
    Local nSqlStatus    As Numeric
    Local oColumn       As Object
    Local aSeekFields   As Array
    Local aFilterFields As Array
    Local lSeeAll       As Logical
    Local cCurrentFil   As Chaarcter
    Local lOk := .F.    As Logical
    
    aCurArea := GetArea()
    aSRAArea := SRA->(GetArea())
    aSraTempData := {}
    aNumbersList := {}
    aSeekFields := {}
    aFilterFields := {}
    lSeeAll := VerSenha(114) .And. VerSenha(115)
    cCurrentFil := FwXFilial("SRA")

    // Defenition fields of temporary table.
    aFields := {}
    aAdd(aFields, {"RA_OK"     , "C", 1                      , 00})
    aAdd(aFields, {"RA_MAT"    , "C", TamSX3("RA_MAT")[1]    , 00})
    aAdd(aFields, {"RA_NOMECMP", "C", TamSX3("RA_NOMECMP")[1], 00})
    aAdd(aFields, {"RA_ADMISSA", "D", TamSX3("RA_ADMISSA")[1], 00})
    aAdd(aFields, {"RA_CIC"    , "C", TamSX3("RA_CIC")[1]    , 00})

    // Defenition fields for search.
    /*  Fields array     Title                                 X3_TIPO                          X3_TAMANHO                  X3_DECIMAL          X3_CAMPO         X3_PICTURE             Index #   IsUse */
    aAdd(aSeekFields, {FWX3Titulo("RA_MAT")    , {{"", GetSx3Cache("RA_MAT"    , "X3_TIPO"), TamSX3("RA_MAT")[1]    , TamSX3("RA_MAT")[2]    , "RA_MAT"    , X3Picture("RA_MAT")     }},   1,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_NOMECMP"), {{"", GetSx3Cache("RA_NOMECMP", "X3_TIPO"), TamSX3("RA_NOMECMP")[1], TamSX3("RA_NOMECMP")[2], "RA_NOMECMP", X3Picture("RA_NOMECMP") }},   2,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_ADMISSA"), {{"", GetSx3Cache("RA_ADMISSA", "X3_TIPO"), TamSX3("RA_ADMISSA")[1], TamSX3("RA_ADMISSA")[2], "RA_ADMISSA", X3Picture("RA_ADMISSA") }},   3,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RA_CIC")    , {{"", GetSx3Cache("RA_CIC"    , "X3_TIPO"), TamSX3("RA_CIC")[1]    , TamSX3("RA_CIC")[2]    , "RA_CIC"    , X3Picture("RA_CIC")     }},   4,     .T.   })

    // Defenition fields for filter.
    /*    Fields array     Field          Title                          Type                              X3_TAMANHO                 X3_DECIMAL             X3_PICTURE          */
    aAdd(aFilterFields, {"RA_MAT"    , FWX3Titulo("RA_MAT")    , GetSx3Cache("RA_MAT"    , "X3_TIPO"), TamSX3("RA_MAT")[1]    , TamSX3("RA_MAT")[2]    , X3Picture("RA_MAT")     })
    aAdd(aFilterFields, {"RA_NOMECMP", FWX3Titulo("RA_NOMECMP"), GetSx3Cache("RA_NOMECMP", "X3_TIPO"), TamSX3("RA_NOMECMP")[1], TamSX3("RA_NOMECMP")[2], X3Picture("RA_NOMECMP") })
    aAdd(aFilterFields, {"RA_ADMISSA", FWX3Titulo("RA_ADMISSA"), GetSx3Cache("RA_ADMISSA", "X3_TIPO"), TamSX3("RA_ADMISSA")[1], TamSX3("RA_ADMISSA")[2], X3Picture("RA_ADMISSA") })
    aAdd(aFilterFields, {"RA_CIC"    , FWX3Titulo("RA_CIC")    , GetSx3Cache("RA_CIC"    , "X3_TIPO"), TamSX3("RA_CIC")[1]    , TamSX3("RA_CIC")[2]    , X3Picture("RA_CIC")     })

    cAlias := CriaTrab(Nil, .F.) // Get new alias of your temporary table.
    oTempTable := FWTemporaryTable():New(cAlias) // Create temporary table.
    oTemptable:SetFields(aFields) // Set columns.

    // Create indexes.
    oTempTable:AddIndex(cAlias + "01", {"RA_MAT"    }) // Set index 01.
    oTempTable:AddIndex(cAlias + "02", {"RA_NOMECMP"}) // Set index 02.
    oTempTable:AddIndex(cAlias + "03", {"RA_ADMISSA"}) // Set index 03.
    oTempTable:AddIndex(cAlias + "04", {"RA_CIC"    }) // Set index 04.
    
    oTempTable:Create() // Create table.

    // Get employee number from SRA table and write it into array aSraTempData.
    DbSelectArea("SRA")
    SRA->(DbSetOrder(1)) // RA_FILIAL+RA_MAT+RA_NOME
    SRA->(DbGoTop())
    If !lSeeAll
        SRA->(DbSeek(cCurrentFil))
    EndIf

    While !(SRA->(Eof())) .And. (lSeeAll .Or. SRA->RA_FILIAL == cCurrentFil)
        aAdd(aSraTempData, {"0", SRA->RA_MAT, SRA->RA_NOMECMP, SRA->RA_ADMISSA, SRA->RA_CIC})

        SRA->(DBSkip())
    EndDo

    nSraCount := Len(aSraTempData)

    // Insert employee array into temporary table.
    For nI := 1 To nSraCount
        cQuery := "INSERT INTO " + oTempTable:GetRealName()
        cQuery += " ( "
        cQuery += "     RA_OK, "
        cQuery += "     RA_MAT, "
        cQuery += "     RA_NOMECMP, "
        cQuery += "     RA_ADMISSA, "
        cQuery += "     RA_CIC "
        cQuery += " ) "
        cQuery += " VALUES "
        cQuery += " ( " 
        cQuery += "   '" + aSraTempData[nI][1] + "' , " // RA_OK
        cQuery += "   '" + aSraTempData[nI][2] + "' , " // RA_MAT
        cQuery += "   '" + aSraTempData[nI][3] + "' , " // RA_NOMECMP
        cQuery += "   '" + DToS(aSraTempData[nI][4]) + "', " // RA_ADMISSA
        cQuery += "   '" + AllTrim(aSraTempData[nI][5]) + "' " // RA_CIC
        cQuery += " ) "

        nSqlStatus := TCSqlExec(cQuery)
        If nSqlStatus < 0
            MsgStop(STR0036, STR0014) // "An error occurred when creating a temporary table", "Error"
            Exit
        EndIf

    Next nI

    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    
    // Create array with columns for browse.
    aColumns := {}
    
    For nI := 1 To Len(aFields)
        If (aFields[nI][1] == "RA_OK")
            Loop
        EndIf

        oColumn := FWBrwColumn():New() // Create a column object.
        oColumn:SetTitle(RetTitle(aFields[nI][1])) // Set title column.
        oColumn:SetData(&("{ || " + aFields[nI][1] + " }")) // Set data column.
        oColumn:SetID(aFields[nI]) // Set id of column.

        // Set size of columns.
        Do Case
            Case aFields[nI][1] == "RA_MAT"
                oColumn:SetSize(TamSX3("RA_MAT")[1])
                oColumn:SetAlign(CONTROL_ALIGN_CENTER)
            Case aFields[nI][1] == "RA_NOMECMP"
                oColumn:SetSize(TamSX3("RA_NOMECMP")[1])
            Case aFields[nI][1] == "RA_ADMISSA"
                oColumn:SetSize(TamSX3("RA_ADMISSA")[1])
            Case aFields[nI][1] == "RA_CIC"
                oColumn:SetSize(TamSX3("RA_CIC")[1])
            Otherwise
                oColumn:SetSize(20)
        EndCase

        // Set picture for RA_CIC column.
        If aFields[nI][1] == "RA_CIC"
            oColumn:SetPicture(X3Picture("RA_CIC"))
        EndIf

        aAdd(aColumns, oColumn) // Add column to array.
    Next nI

    

    If !Empty(aSRAlList)

        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())
        While !((cAlias)->(Eof()))

            If aScan(aSRAlList, (cAlias)->RA_MAT) > 0
                (cAlias)->RA_OK := CMARK_CHAR_FOR_BROWSE
            EndIf

            (cAlias)->(DbSkip())
        EndDo
    EndIf

    // Define dialog for browse.
    DEFINE MSDIALOG oDlg TITLE STR0037 FROM 00,00 TO 500, 800 OF oMainWnd PIXEL // "Select employee"
    
    oMark := FWMarkBrowse():New()
    oMark:SetMark(CMARK_CHAR_FOR_BROWSE, cAlias, "RA_OK")
    oMark:SetFieldMark('RA_OK')
    oMark:SetDescription(STR0037) // "Select employee"
    oMark:SetColumns(aColumns)
    oMark:SetAlias(cAlias)
    oMark:DisableReport()
    oMark:SetMenuDef('')
    oMark:SetIgnoreARotina(.T.)
    oMark:SetSeek(.T., aSeekFields)
    oMark:SetTemporary(.T.)
    oMark:SetLocate()
    oMark:SetUseFilter(.T.)
    oMark:SetFilterDefault("")
    oMark:SetFieldFilter(aFilterFields)
    oMark:DisableDetails()
    oMark:SetOwner(oDlg)
    oMark:bAllMark := {|| RU16R0108_MarkAll(oMark, cAlias, CMARK_CHAR_FOR_BROWSE)}
    oMark:Refresh()
    oMark:Activate()

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (lOk:=.T.), (oDlg:End())}, {|| oDlg:End()}, , /*aButEnc*/)

    // Defenition selected employee.
    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    While !((cAlias)->(Eof()))

        If ((cAlias)->RA_OK == CMARK_CHAR_FOR_BROWSE)
            Aadd(aNumbersList, (cAlias)->RA_MAT)
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    aRetList := aNumbersList

    // Delete temporary table.
    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif

    RestArea(aSRAArea)
    RestArea(aCurArea)

Return lOk

/*/
{Protheus.doc} RU16R0108_MarkAll(oBrowsePut, cTempTbl, cMark)
    Mark all records into temporary table.

    @type Function
    @params oBrowsePut, Object, Object of class FWMarkBrowse.
    @params cTempTbl, Character, Alias of temporary table.
    @params cMark, Character, Symbol of marking.
    @author dchizhov
    @since 02.03.2023
    @version 12.1.33
    @return .T.
    @example oMark:bAllMark := {|| MarkAll(oMark, cAlias, cMarkChar)}
/*/
Function RU16R0108_MarkAll(oBrowsePut, cTempTbl, cMark)

    Local nRecOri As Numeric
    Local cMarker As Character

    cMarker := "0"
    nRecOri := (cTempTbl)->(RecNo())

    DbSelectArea(cTempTbl)
    (cTempTbl)->(DbGoTop())

    Do While !(cTempTbl)->(Eof())
        If (cTempTbl)->RA_OK <> cMark
            cMarker := cMark
            Exit
        EndIf

        (cTempTbl)->(DbSkip())
    EndDo

    (cTempTbl)->(DbEval({|| (cTempTbl)->RA_OK := cMarker},{|| .T. }))

    oBrowsePut:GoTo(nRecOri, .T.)

Return .T.

/*/
{Protheus.doc} RU16R0120_GetDataAboutSigner(cCode, cMat, cNameSignature, cMode)
    Get data about signer. If Mode = "1" - return mat and name. If Mode = "2" - return code of cargo and name. 

    @type Function
    @params cCod,           Character, Employee personnel number.
    @params cMat,           Character, TN of signer.
    @params cNameSignature, Character, Result Full name of signer.
    @params cMode,          Character,  Mode of function (what is results).
    @author dchizhov
    @since 24.03.2023
    @version 12.1.33
    @return lRes, Logical, Success or not.
    @example lResult := RU16R0120_GetDataAboutSigner(cCodeSignature, @cMat, @cNameSignature, "1")
/*/
Function RU16R0120_GetDataAboutSigner(cCode, cMat, cNameSignature, cMode)

    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical
    Local cCodeRet   As Character
    Local cMatRet    As Character
    Local cVar       As Character
    Local cExist     As Character
    Local lSeeAll    As Logical

    Default cMat  := ""
    Default cCode := ""

    cFullName := ""
    cCodeRet := ""
    cMatRet := ""
    lSeeAll := VerSenha(114) .And. VerSenha(115)
    aArea := GetArea()

    If cMode == "2"
        cVar := cMat
        cExist := "RA_MAT"
    Else
        cVar := cCode
        cExist := "RA_CARGO"
    EndIf

    If !Empty(cVar) .And. !Empty(cExist)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOMECMP, RA_CARGO FROM " + RetSQLName("SRA") + " WHERE " + Iif(cMode <> "2" .Or. !lSeeAll, "RA_FILIAL = ? AND ", "") + cExist + " = ? AND D_E_L_E_T_=' ' ")
        If cMode <> "2"  .Or. !lSeeAll
            oStatement:SetString(1, xFilial("SRA"))
            oStatement:SetString(2, cVar)
        Else
            oStatement:SetString(1, cVar)
        EndIf
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOMECMP
        cCodeRet := (cTab)->RA_CARGO
        cMatRet := (cTab)->RA_MAT

        (cTab)->(DBCloseArea())

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    // Write result to pergunte.
    If !Empty(cFullName)
        lResult := .T.
        cNameSignature := cFullName
        cCode := cCodeRet
        cMat := cMatRet
    ElseIf cMode <> "2"
        lResult := .F.
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0015,, STR0026, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027})
        cNameSignature := ""
    Else
        lResult := .F.
        cNameSignature := ""
        cCode := ""
    EndIf

    RestArea(aArea)

Return lResult
