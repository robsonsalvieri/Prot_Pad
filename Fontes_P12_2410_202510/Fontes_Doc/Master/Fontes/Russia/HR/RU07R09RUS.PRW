#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R09RUS.CH"

#DEFINE PARAMS_PERGUNTE "RU07R09PAR"
#DEFINE CODES_OF_PAYMENT_TYPE_VACATION "121"

/*/
{Protheus.doc} RU07R09RUS()
    Main function of routine print form T-7.

    @type Function
    @params 
    @author dchizhov
    @since 30.01.2023
    @version 12.1.33
    @return 
    @example AAdd(aMenuDef, {STR0094, "RU07R09RUS", 0, 11})
/*/
Function RU07R09RUS()

    Local oDialog    As Object
    Local cCurFilial As Character
    Local lSeeAll    As Logical

    lSeeAll := VerSenha(114) .And. VerSenha(115)
    cCurFilial := FwXFilial("SRA")

    If !lSeeAll
        SetMVValue(PARAMS_PERGUNTE, "MV_PAR03", cCurFilial)
        SetMVValue(PARAMS_PERGUNTE, "MV_PAR04", cCurFilial)
    EndIf

    oDialog := tNewProcess():New( "RU07R09RUS", STR0001, {|oSelf| BuildReport(oSelf)}, STR0012, PARAMS_PERGUNTE, , .T., 20, STR0006, .F.) // "Vacation schedule", "This procedure allows you to generate a Word file with a vacation schedule according to the specified parameters.", "Please wait..."

    oDialog := Nil
    FreeObj(oDialog)

Return

/*/
{Protheus.doc} BuildReport()
    Get user setting and building report.

    @type Static Function
    @Params oProcess, Object, Process of building
    @author dchizhov
    @since 02.02.2023
    @version 12.1.33
    @return oData, Json, Array with description of fields for setting.
    @example oSettField := RU07R0901_GetJsonFieldSetting()
/*/
Static Function BuildReport(oProcess)

    Local aInputParameters As Array
    local aDataList        As Array
    Local cAlertMsg := ""  As Character
    Local cPrefixFile      As Character
    Local cCurFilial As Character
    Local lSeeAll    As Logical

    lSeeAll := VerSenha(114) .And. VerSenha(115)
    cCurFilial := FwXFilial("SRA")

    MakeSqlExpr(PARAMS_PERGUNTE)

    If !lSeeAll .And. (MV_PAR03 <> cCurFilial .Or. MV_PAR04 <> cCurFilial)
        MV_PAR03 := MV_PAR04 := cCurFilial
        MsgInfo(STR0024, STR0025)
        SetMVValue(PARAMS_PERGUNTE, "MV_PAR03", cCurFilial)
        SetMVValue(PARAMS_PERGUNTE, "MV_PAR04", cCurFilial)
    EndIf

    aInputParameters := {AllTrim(MV_PAR01), AllTrim(MV_PAR02), AllTrim(MV_PAR03), AllTrim(MV_PAR04), AllTrim(MV_PAR05), ;
        AllTrim(MV_PAR06), AllTrim(MV_PAR07), AllTrim(MV_PAR08), AllTrim(MV_PAR09), AllTrim(MV_PAR10), MV_PAR11, AllTrim(MV_PAR12), ;
        AllTrim(MV_PAR13)}

    cAlertMsg += Iif(File(aInputParameters[1]), "", STR0013 + CRLF) // "Template document was not specified."
    cAlertMsg += Iif(Empty(AllTrim(aInputParameters[5])), STR0015 + CRLF, "") // "Schedule year not specified"
    cAlertMsg += Iif(Empty(AllTrim(aInputParameters[4])), STR0022 + CRLF, "") // "Schedule year not specified"
    cAlertMsg += Iif(Empty(AllTrim(aInputParameters[7])), STR0023 + CRLF, "") // "Schedule year not specified"
    cAlertMsg += Iif(Empty(AllTrim(aInputParameters[13])) .Or. Empty(AllTrim(aInputParameters[12])), STR0016 + CRLF, "") // "Signer not specified"

    oDialog := RuHRWordPrintForm():New("RU07R09RUS")
    oDialog:lGroupReport := .T.
    oDialog:cPatternPath := aInputParameters[1]
    oDialog:cResultPath := aInputParameters[2] + " "

    If Empty(AllTrim(cAlertMsg))
        cPrefixFile := STR0008 + " " + STR0017 + " " + STR0018 + " " + aInputParameters[5] + " " + STR0019 + ". " // "T7", "vacation schedule", "by", "years"
        oProcess:IncRegua1(STR0007) // "Formation of the vacation schedule"
        aDataList := RU07R0902_GetAllData(aInputParameters)
        oProcess:IncRegua1(STR0014) // "File generation!"
        lCreateReport := oDialog:PrintReport(aDataList, cPrefixFile, .T.)
        If lCreateReport
            MsgInfo(STR0004, STR0003) // "Vacation schedule is set!", "Done".
        Else
            MsgStop(STR0005, STR0002) // "Something went wrong while scheduling vacations!", "Error".
        EndIf
    Else
        MsgAlert(cAlertMsg)
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R0901(cCod)
    Prescribes in the 11th parameter the full name of the employee selected in the 10th parameter

    @type Function
    @params cCod, Character, Employee personnel number.
    @author dchizhov
    @since 02.02.2023
    @version 12.1.33
    @return lResult, Logical, Is the employee found in the directory
    @example RU07R0901()
/*/
Function RU07R0901(cCod)
    
    Local aArea := GetArea()
    Local aSRAArea := SRA->(GetArea())
    Local lResult := .F.

    Default cCod := MV_PAR12

    DbSelectArea("SRA")
    SRA->(DbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_CARGO")))

    If SRA->(DbSeek(xFilial("SRA") + cCod))
        lResult := .T.
        MV_PAR13 := SRA->RA_NOMECMP
    Else
        lResult := .F.
        Help(,, STR0009,, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011} ) // "Error", "No employee has been assigned to the specified position", "Specify the position to which the employee is assigned"

        MV_PAR13 := ""
    EndIf

    RestArea(aArea)
    SRA->(RestArea(aSRAArea))

Return lResult

/*/
{Protheus.doc} RU07R0902_GetAllData(aParams)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 02.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example aDataList := RU07R0902_GetAllData(aInputParameters)
/*/
Static Function RU07R0902_GetAllData(aParams)

    Local aDataArray           As Array
    Local aSRAList             As Array
    Local aArea                As Array
    Local oRuEmployeePrintForm As Object

    aArea := GetArea()
    aSRAList := {}
    aDataArray := {}
    // We form an array with service numbers for printing the report.
    aSRAList := RU07R0903_GetSRAList(aParams)

    oRuEmployeePrintForm := GrPrintFilter(aSRAList, aParams)
    Aadd(aDataArray, oRuEmployeePrintForm)

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU07R0903_GetSRAList(aParams)
    The function creates an array of employee.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 02.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of employee
    @example aArraySRA := RU07R0903_GetSRAList(aParams)
/*/
Static Function RU07R0903_GetSRAList(aParams)

    Local aDataArray As Array
    Local aArea      As Array
    Local cAlias     As Character
    Local cOrder     As Character
    Local cWhere     As Character

    aArea := GetArea()
    cAlias := GetNextAlias()
    aDataArray := {}
    cOrder := Iif(Empty(aParams[11]) .Or. aParams[11] == 1, "%SRA.RA_MAT%", Iif(aParams[11] == 2, "%SRA.RA_NOMECMP%", "%SQB.QB_DESCRIC, SRA.RA_NOMECMP%"))
    cWhere := "% SRA.RA_FILIAL >= '" + aParams[3] + "'" + CRLF + ;
            "AND SRA.RA_FILIAL <= '" + aParams[4] + "'" + CRLF + ;
            "AND SRA.RA_CC >= '" + aParams[6] + "'" + CRLF + ;
            "AND SRA.RA_CC <= '" + aParams[7] + "'" + CRLF + ;
            "AND SRA.RA_DEPTO >= '" + aParams[8] + "'" + CRLF + ;
            "AND SRA.RA_DEPTO <= '" + aParams[9] + "'"
    cWhere += Iif(Empty(aParams[10]), "", CRLF + "AND " + aParams[10])
    cWhere += " %"

    BeginSql Alias cAlias
    SELECT SRA.RA_MAT MAT, SRA.RA_FILIAL FIL, SQB.QB_DESCRIC QDESC
          FROM %Table:SRA% SRA
          LEFT JOIN %Table:SQB% SQB ON SQB.QB_DEPTO = SRA.RA_DEPTO AND SQB.QB_FILIAL = %XFilial:SQB% AND SQB.%NotDel%
         WHERE %Exp:cWhere%
         AND SRA.%NotDel%
        ORDER BY %Exp:cOrder% ASC
    EndSQL

    (cAlias)->(DbGoTop())

    While !(cAlias)->(EOF())
        Aadd(aDataArray, {(cAlias)->MAT, (cAlias)->FIL, (cAlias)->QDESC})
        (cAlias)->(DbSkip())
    EndDo

    (cAlias)->(DbCloseArea())

    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} GrPrintFilter(aSRAList, aParams)
    The function creates an RuEmployeePrintForm object.

    @type Static Function
    @params aSRAList, Array, Array of employees for printer.
    @params aParams,  Array, Parameters entered by the user.
    @author dchizhov
    @since 06.02.2023
    @version 12.1.33
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing
    @example oRuEmployeePrintForm := GrPrintFilter(aSRAList, aParams)
/*/
Static Function GrPrintFilter(aSRAList, aParams)
    
    Local nOrder  As Numeric
    local nI      As Numeric
    Local cSearch As Character
    Local aData   As Array
    Local oRuEmployeePrintForm As Object

    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")

    oRuEmployeePrintForm := RuEmployeePrintForm():New("", "", Array(3))

    oRuEmployeePrintForm:aDataList[1] := {"count1_empl", 0}
    oRuEmployeePrintForm:aDataList[2] := {"count1_lines", 0}
    oRuEmployeePrintForm:aDataList[3] := {"count1_column", 10}

    If Len(aSRAList) > 0
        cSearch := Iif(nOrder > 1, aSRAList[1, 1] + aSRAList[1, 2], aSRAList[1, 2] + aSRAList[1, 1])
        Posicione("SRA", nOrder, cSearch, "RA_MAT")
    EndIf
    aData := RU07R0904_GetDataArray(aParams)
    For nI := 1 To Len(aData)
        Aadd(oRuEmployeePrintForm:aDataList, aData[nI])
    Next nI

    For nI := 1 To Len(aSRAList)

        cSearch := Iif(nOrder > 1, aSRAList[nI, 1] + aSRAList[nI, 2], aSRAList[nI, 2] + aSRAList[nI, 1])
        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch, "RA_MAT"))

            RU07R0905_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aParams)

        EndIf
    Next nI

    // if no data for a table create empty string
    If oRuEmployeePrintForm:aDataList[2, 2] == 0
        oRuEmployeePrintForm:aDataList[2, 2] := 1
        For nI := 1 To 10
            Aadd(oRuEmployeePrintForm:aDataList, {"doc_variable1_1_" + CValToChar(nI), " "})
        Next nI
    EndIf

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU07R0702_GetDataArray(aParams)
    The function creates an array of variables and general data according to the template.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 06.02.2023
    @version 12.1.33
    @return aDataArray, Array, Array of variables and data
    @example aDataArray := RU07R0702_GetDataArray(aParams)
/*/
Static Function RU07R0904_GetDataArray(aParams)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cPostSignature   As Character
    Local cTypeBranch      As Character

    aDataArray := {}

    // Get information about company.
    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    // Get information about signer.
    cPostSignature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(aParams[12])) // Get name of post for signature

    aAdd(aDataArray, {"cOrgName",       cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",      cOKPOCode})
    aAdd(aDataArray, {"cPostSignature", cPostSignature})
    aAdd(aDataArray, {"cNameSignature", aParams[13]})
    aAdd(aDataArray, {"cDateCreation",  Date()})
    aAdd(aDataArray, {"cYearSchedule",  aParams[5]})

Return aDataArray

/*/
{Protheus.doc} RU07R0704_FillDataForGroupPrint(aDataPrint, aDataFrom)
    Filling array for schedule by current employee.

    @type Function
    @params aDataPrint, Array,   Array for printing.
    @params aDataFrom,  Array,   Array whith data.
    @author dchizhov
    @since 07.02.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU07R0704_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData)
/*/
Static Function RU07R0905_FillDataForGroupPrint(aDataPrint, aParams)

    Local lResult  As Logical
    Local aArea    As Array
    Local aSRFArea As Array
    Local cDepart  As Character
    Local aPostInf As Array
    Local cName    As Character
    Local cTabNum  As Character
    Local nCDays   As Numeric
    Local cDataIni As Date
    Local cNotice  As Character
    Local aDateRep As Array
    Local aFields  As Array
    Local nI       As Numeric
    Local lNotAdd  As Logical

    aArea := GetArea()
    aSRFArea := SRF->(GetArea())
    lNotAdd := .T.
    aDateRep := {CToD("01/01/" + aParams[5]), CToD("31/12/" + aParams[5])}
    aFields := {{"RF_DFEPRO1", "RF_DFEPRO2", "RF_DFEPRO3", "RF_DFEPRO4", "RF_DFEPRO5", "RF_DFEPRO6"}, ;
                {"RF_DATAINI", "RF_DATINI2", "RF_DATINI3", "RF_DATINI4", "RF_DATINI5", "RF_DATINI6"}, ;
                {"RF_DABPRO1", "RF_DABPRO2", "RF_DABPRO3", "RF_DABPRO4", "RF_DABPRO5", "RF_DABPRO6"}}
    
    cDepart := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRA->RA_DEPTO) // Get information about depto name.
    aPostInf := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SRA->RA_CARGO) // Get information about position.
    cName := SRA->RA_NOMECMP
    cTabNum := SRA->RA_MAT

    DbSelectArea("SRF")
    STF->(DbSetOrder(RetOrdem("SRF", "RF_FILIAL+RF_MAT+DTOS(RF_DATABAS)")))

    If SRF->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While (!SRF->(EOF())) .And. SRF->RF_FILIAL == SRA->RA_FILIAL .And. SRF->RF_MAT == SRA->RA_MAT .And. ;
        SRF->RF_PD $ CODES_OF_PAYMENT_TYPE_VACATION
            For nI := 1 To 6
                nCDays := SRF->(&(aFields[1, nI]))
                cDataIni := Iif(SRF->(&(aFields[2, nI])) >= aDateRep[1] .And. SRF->(&(aFields[2, nI])) <= aDateRep[2], ;
                AllTrim(DToC(SRF->(&(aFields[2, nI])))), "")
                cNotice := Iif(SRF->(&(aFields[3, nI])) > 0, STR0020 + " " + AllTrim(CValToChar(SRF->(&(aFields[3, nI])))), "") // "including ext."
                If !Empty(cDataIni) .And. (nCDays > 0 .Or. !Empty(cNotice))
                    aDataPrint[1, 2] += Iif(lNotAdd, 1, 0)
                    aDataPrint[2, 2] += 1
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_1",  cDepart})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_2",  aPostInf[1]})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_3",  cName})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_4",  cTabNum})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_5",  nCDays})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_6",  cDataIni})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_7",  " "})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_8",  " "})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_9",  " "})
                    Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_10", cNotice})
                    cDepart := " "
                    aPostInf[1] := " "
                    cName := " "
                    cTabNum := " "
                    lNotAdd := .F.
                EndIf
            Next nI
            SRF->(DbSkip())
        EndDo
    EndIf

    If lNotAdd
        aDataPrint[1, 2] += Iif(lNotAdd, 1, 0)
        aDataPrint[2, 2] += 1
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_1",  cDepart})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_2",  aPostInf[1]})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_3",  cName})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_4",  cTabNum})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_5",  " "})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_6",  " "})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_7",  " "})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_8",  " "})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_9",  " "})
        Aadd(aDataPrint, {"doc_variable1_" + CValToChar(aDataPrint[2, 2]) + "_10", " "})
    EndIf

    SRF->(DbCloseArea())
    SRF->(RestArea(aSRFArea))
    RestArea(aArea)

    lResult := .T.

Return lResult
