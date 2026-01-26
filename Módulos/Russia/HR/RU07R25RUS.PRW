#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R25RUS.CH"

#DEFINE COUNT_STR_FOR_EMPLOYEE_SIGNATURE 1
#DEFINE CODES_OF_PAYMENT_TYPE_VACATION "121"

/*/
{Protheus.doc} RU07R25RUS()
    Main function of routine print form T-6.

    @type Function
    @params 
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return 
    @example AAdd(aRotina, {STR0383, "RU07R25RUS", 0, 11}) //Print the order
/*/
Function RU07R25RUS()
    Local oDialog As Object
    Local aInputParams As Array
    Local aDataList As Array
    Local lCreateReport As Logical
    Local cPrefixNameForFile As Character

    oDialog := RuHRWordPrintForm():New("RU07R25RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog(STR0013, .T.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.
        cPrefixNameForFile := Iif(aInputParameters[6], STR0014 + "-" + STR0015 + " ", STR0008) // "T-6a" - "Group notice of transfer" "T-6"

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R2501_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6]), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameForFile)  ;
                  }, STR0006, STR0007) // "Please wait", "Formation of vacation order".

        If lCreateReport
            MsgInfo(STR0004, STR0003) // "The order for vacation has been created!", "Done".
        Else
            MsgStop(STR0005, STR0002) // "Something went wrong when creating vacation order", "Error".
        EndIf

    EndIf

    oDialog := Nil
    FreeObj(oDialog)

Return

/*/
{Protheus.doc} RU07R2501_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params cCodeSignature, Character, Employee post code.
    @params cNameSignature, Character, Full name of signature this print form.
    @params aSRAlList,   Array, List of selected employee numbers.
    @params lGroupPrint, Logical, Is grouping printer or not.
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R2501_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6])
/*/
Static Function RU07R2501_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)

    Local aDataArray As Array
    Local aSRAList As Array
    Local aArea As Array
    Local aSRAArea As Array
    Local nI As Numeric
    Local oRuEmployeePrintForm As Object
    Local nOrder As Numeric
    Local cSearch As Character

    Default lGroupPrint := .F.

    aArea := GetArea()
    aSRAList := {}
    aDataArray := {}

    // We form an array with service numbers for printing the report.
    If !Empty(aSRAlList)
        aSRAList := aSRAlList
    Else
        aAdd(aSRAList, SRA->RA_MAT)
    EndIf

    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
    cSearch := Iif(nOrder > 1, "", FwXFilial("SRA"))

    aSRAArea := SRA->(GetArea())

    If lGroupPrint

        oRuEmployeePrintForm := GrPrintFilter(aSRAList, cCodeSignature, cNameSignature)

        Aadd(aDataArray, oRuEmployeePrintForm)
    Else
        For nI := 1 To Len(aSRAList)

            // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
            If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

                oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), RU07R2502_GetDataArray(cCodeSignature, AllTrim(cNameSignature)))
                aAdd(aDataArray, oRuEmployeePrintForm)
        
            EndIf
        Next nI
    EndIf

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aSRAArea) // Restore SRA area.
    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU07R2502_GetDataArray(cCodeSignature, cNameSignature)
    The function creates an array of variables and data according to the template.

    @type Static Function
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return aDataArray, Array, Array of variables and data
    @example aDataArray := RU07R2502_GetDataArray(cCodeSignature, cNameSignature)
/*/
Static Function RU07R2502_GetDataArray(cCodeSignature, cNameSignature)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cDeptName        As Character
    Local aPosInfo         As Array
    Local aVacInfo         As Array
    Local cPostSignature   As Character
    Local cTypeBranch      As Character
    Local cSeekSRF		:= ""

    aDataArray := {}
    aVacInfo := {}
    aDateCurrent := {Date(), , , }
    aDateCurrent[2] := Day(aDateCurrent[1])
    aDateCurrent[3] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aDateCurrent[1]))
    aDateCurrent[4] := SubStr(DToC(aDateCurrent[1]), 9, 2)

    // Get information about company.
    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    // Get information about employee.
    cDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRA->RA_DEPTO) // Get information about depto name.
    aPosInfo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SRA->RA_CARGO) // Get information about position.
    cPostSignature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(cCodeSignature)) // Get name of post for signature

    // Get information about vacation
    cSeekSRF := SRA->RA_FILIAL + AllTrim(SRA->RA_MAT)
    aVacInfo := RU07R2503_GetVacation(cSeekSRF)

    // Creating an array of variable correspondences in printed form with data loaded into them.
    // ATTENTION: This Array and values also using for T6-a report. If any changes are made to the order of values - change the corresponding indices in the GrPrintFilter function 
    aAdd(aDataArray, {"cOrgName",        cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",       cOKPOCode})
    aAdd(aDataArray, {"cDateOrder",      Date()})
    // Data about the employee
    aAdd(aDataArray, {"cEmpFullName",    AllTrim(SRA->RA_NOMECMP)})
    aAdd(aDataArray, {"cEmployMat",      AllTrim(SRA->RA_MAT)})
    aAdd(aDataArray, {"cStructDep",      Iif(Empty(cDeptName), "-", cDeptName)})
    // Information about the employee's main vacation
    If len(aVacInfo) > 0
        aAdd(aDataArray, {"cEmpCargo",       aPosInfo[1]})
        aAdd(aDataArray, {"cDate1IniVac",    Day(aVacInfo[1][2])})
        aAdd(aDataArray, {"cDate1FinVac",    Day(aVacInfo[2][2])})
        aAdd(aDataArray, {"cDate2IniVac",    StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aVacInfo[1][2]))})
        aAdd(aDataArray, {"cDate2FinVac",    StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aVacInfo[2][2]))})
        aAdd(aDataArray, {"cDate3IniVac",    SubStr(DToC(aVacInfo[1][2]), 9, 2)})
        aAdd(aDataArray, {"cDate3FinVac",    SubStr(DToC(aVacInfo[2][2]), 9, 2)})
        aAdd(aDataArray, {"cCountDayVac",    aVacInfo[3][2]})
        aAdd(aDataArray, {"cFact1DateVac",   Iif(aVacInfo[3][2]>0,Day(aVacInfo[7][2]),"")})
        aAdd(aDataArray, {"cFact2DateVac",   Iif(aVacInfo[3][2]>0,Day(DaySum(aVacInfo[7][2], aVacInfo[3][2]-1)),"")})
        aAdd(aDataArray, {"cFact3DateVac",   StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aVacInfo[7][2]))})
        aAdd(aDataArray, {"cFact4DateVac",   StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(DaySum(aVacInfo[7][2], aVacInfo[3][2])))})
        aAdd(aDataArray, {"cFact5DateVac",   SubStr(DToC(aVacInfo[7][2]), 9, 2)})
        aAdd(aDataArray, {"cFact6DateVac",   SubStr(DToC(DaySum(aVacInfo[7][2], aVacInfo[3][2])), 9, 2)})
        aAdd(aDataArray, {"cCntFactVacan",   aVacInfo[3][2]})
        aAdd(aDataArray, {"cAdditCntVac",    aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]})
        // Information about the employee's additional leave
        If aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2] > 0
            aAdd(aDataArray, {"cAddIni1FinVac",   Day(aVacInfo[7][2])})
            aAdd(aDataArray, {"cAddIni2FinVac",   StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aVacInfo[7][2]))})
            aAdd(aDataArray, {"cAddIni3FinVac",   SubStr(DToC(aVacInfo[7][2]), 9, 2)})
            aAdd(aDataArray, {"cAddit1FinVac",    Day(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]-1))})
            aAdd(aDataArray, {"cAddit2FinVac",    StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2])))})
            aAdd(aDataArray, {"cAddit3FinVac",    SubStr(DToC(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2])), 9, 2)})
        Else
            aAdd(aDataArray, {"cAddIni1FinVac", " "})
            aAdd(aDataArray, {"cAddIni2FinVac", " "})
            aAdd(aDataArray, {"cAddIni3FinVac", " "})
            aAdd(aDataArray, {"cAddit1FinVac",  " "})
            aAdd(aDataArray, {"cAddit2FinVac",  " "})
            aAdd(aDataArray, {"cAddit3FinVac",  " "})
        EndIf
        // Information about all employee vacations
        aAdd(aDataArray, {"cCntAllDayVac",  aVacInfo[3][2]+aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]})
        If DaySum(aVacInfo[7][2], aVacInfo[3][2]) > DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2])
            aAdd(aDataArray, {"cAll4DateVac",    Iif(aVacInfo[3][2]+aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]>0, Day(DaySum(aVacInfo[7][2], aVacInfo[3][2]-1)), " ")})
            aAdd(aDataArray, {"cAll5DateVac",    StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(DaySum(aVacInfo[7][2], aVacInfo[3][2])))})
            aAdd(aDataArray, {"cAll6DateVac",    SubStr(DToC(DaySum(aVacInfo[7][2], aVacInfo[3][2])), 9, 2)})
        Else
            aAdd(aDataArray, {"cAll4DateVac",    Iif(aVacInfo[3][2]+aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]>0, Day(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2]-1)), " ")})
            aAdd(aDataArray, {"cAll5DateVac",    StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2])))})
            aAdd(aDataArray, {"cAll6DateVac",    SubStr(DToC(DaySum(aVacInfo[7][2], aVacInfo[11][2]+aVacInfo[12][2]+aVacInfo[13][2]+aVacInfo[14][2])), 9, 2)})
        EndIf
    Else
        aAdd(aDataArray, {"cEmpCargo",     ""})
        aAdd(aDataArray, {"cDate1IniVac",  ""})
        aAdd(aDataArray, {"cDate1FinVac",  ""})
        aAdd(aDataArray, {"cDate2IniVac",  ""})
        aAdd(aDataArray, {"cDate2FinVac",  ""})
        aAdd(aDataArray, {"cDate3IniVac",  ""})
        aAdd(aDataArray, {"cDate3FinVac",  ""})
        aAdd(aDataArray, {"cCountDayVac",  ""})
        aAdd(aDataArray, {"cFact1DateVac", ""})
        aAdd(aDataArray, {"cFact2DateVac", ""})
        aAdd(aDataArray, {"cFact3DateVac", ""})
        aAdd(aDataArray, {"cFact4DateVac", ""})
        aAdd(aDataArray, {"cFact5DateVac", ""})
        aAdd(aDataArray, {"cFact6DateVac", ""})
        aAdd(aDataArray, {"cCntFactVacan", ""})
        aAdd(aDataArray, {"cAdditCntVac",  ""})
        aAdd(aDataArray, {"cAddIni1FinVac", ""})
        aAdd(aDataArray, {"cAddIni2FinVac", ""})
        aAdd(aDataArray, {"cAddIni3FinVac", ""})
        aAdd(aDataArray, {"cAddit1FinVac",  ""})
        aAdd(aDataArray, {"cAddit2FinVac",  ""})
        aAdd(aDataArray, {"cAddit3FinVac",  ""})
        aAdd(aDataArray, {"cCntAllDayVac",  ""})
        aAdd(aDataArray, {"cAll4DateVac",   ""})
        aAdd(aDataArray, {"cAll5DateVac",   ""})
        aAdd(aDataArray, {"cAll6DateVac",   ""})
    EndIf
    // Data about the signatory
    aAdd(aDataArray, {"cPostSignature",  cPostSignature})
    aAdd(aDataArray, {"cNameSignature",  cNameSignature})
    // The current date of the order formation
    aAdd(aDataArray, {"cDayCurrent",     aDateCurrent[2]})
    aAdd(aDataArray, {"cMonthCurrent",   aDateCurrent[3]})
    aAdd(aDataArray, {"cYearCurrent",    aDateCurrent[4]})
    //Employee's signature
    aAdd(aDataArray, {"cNomeEmploy",     AllTrim(SRA->RA_NOME)})

Return aDataArray


/*/
{Protheus.doc} RU07R2503_GetVacation(cSeekSRF)
    The function returns information about the employee's vacations.

    @type Static Function
    @params cSeekSRF, Character, Value of the key that will be found.
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return aDataVac, Array, Array with data about an employee's vacation
    @example aVacInfo := RU07R2503_GetVacation(cSeekSRF)
/*/
Static Function RU07R2503_GetVacation(cSeekSRF)

    Local aArea     As Array
    Local aSRFArea  As Array
    Local aDataVac  As Array

    aArea := GetArea()
    aSRFArea := SRF->(GetArea())
    aDataVac := {}

    DBSelectArea("SRF")
    DBSetOrder(1)

    If SRF->(DBSeek(cSeekSRF))
        While !SRF->(EOF()) .AND. len(aDataVac) == 0 .AND. SRF->RF_MAT $ cSeekSRF
            If SRF->RF_STATUS == "1"
                aAdd(aDataVac,{"cDATABAS", SRF->RF_DATABAS})
                aAdd(aDataVac,{"cDATAFIM", SRF->RF_DATAFIM})
                aAdd(aDataVac,{"cDFEPRO1", SRF->RF_DFEPRO1})
                aAdd(aDataVac,{"cDFEPRO2", SRF->RF_DFEPRO2})
                aAdd(aDataVac,{"cDFEPRO3", SRF->RF_DFEPRO3})
                aAdd(aDataVac,{"cDFEPRO4", SRF->RF_DFEPRO4})
                aAdd(aDataVac,{"cDATAINI", SRF->RF_DATAINI})
                aAdd(aDataVac,{"cDATINI2", SRF->RF_DATINI2})
                aAdd(aDataVac,{"cDATINI3", SRF->RF_DATINI3})
                aAdd(aDataVac,{"cDATINI4", SRF->RF_DATINI4})
                aAdd(aDataVac,{"cDABPRO1", SRF->RF_DABPRO1})
                aAdd(aDataVac,{"cDABPRO2", SRF->RF_DABPRO2})
                aAdd(aDataVac,{"cDABPRO3", SRF->RF_DABPRO3})
                aAdd(aDataVac,{"cDABPRO4", SRF->RF_DABPRO4})
                aAdd(aDataVac,{"cDFERANT", SRF->RF_DFERANT})
            Else
                SRF->(DbSkip())
            EndIf
        EndDo
    EndIf

    SRF->(DbCloseArea())
    SRF->(RestArea(aSRFArea))
    RestArea(aArea)

Return aDataVac

/*/
{Protheus.doc} GrPrintFilter(aSRAList, cCodeSignature)
    The function creates an RuEmployeePrintForm object and filling his data array for goup printing.

    @type Static Function
    @params aSRAList,       Array,     Array of employees for printer.
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing
    @example oRuEmployeePrintForm := GrPrintFilter(aSRAList, cCodeSignature, cNameSignature)
/*/
Static Function GrPrintFilter(aSRAList, cCodeSignature, cNameSignature)
    
    Local nOrder  As Numeric
    local nI      As Numeric
    Local cSearch As Character
    Local aData   As Array
    Local oRuEmployeePrintForm As Object
    Local dDDim   As Date

    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
    cSearch := Iif(nOrder > 1, "", FwXFilial("SRA"))

    oRuEmployeePrintForm := RuEmployeePrintForm():New("", "", Array(2))

    oRuEmployeePrintForm:aDataList[1] := {"count_lines", 0}
    oRuEmployeePrintForm:aDataList[2] := {"count_column", 12}

    For nI := 1 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := RU07R2502_GetDataArray(cCodeSignature, cNameSignature)

            Aadd(oRuEmployeePrintForm:aDataList, aData[1])  // cOrgName
            Aadd(oRuEmployeePrintForm:aDataList, aData[2])  // cOKPOCode
            Aadd(oRuEmployeePrintForm:aDataList, aData[3])  // cDateOrder
            Aadd(oRuEmployeePrintForm:aDataList, aData[33]) // cPostSignature
            Aadd(oRuEmployeePrintForm:aDataList, aData[34]) // cNameSignature

            dDDim := aData[3, 2]

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R2504_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData)

            EXIT

        EndIf
    Next nI

    For nI := 2 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := RU07R2502_GetDataArray(cCodeSignature, cNameSignature)

            If !Empty(dDDim) .And. dDDim != aData[3, 2]
                dDDim := NIL
                oRuEmployeePrintForm:aDataList[5, 2] := " "
            EndIf

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R2504_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, oRuEmployeePrintForm:aDataList[1, 2])

        EndIf
    Next nI

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU07R2504_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)
    Filling array for group print from aDataFrom.

    @type Function
    @params aDataPrint, Array,   Array for printing.
    @params aDataFrom,  Array,   Array whith data.
    @params nLine,      Numeric, Number of Filling line.
    @author alysenko
    @since 22.05.2024
    @version 12.1.2310
    @return lResult, Logical, Is a success.
    @example RU07R2504_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, nLine)
/*/
Static Function RU07R2504_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)

    Local lResult             As Logical
    Local cWorkIniPer := " "  As Character
    Local cWorkFinPer := " "  As Character
    Local cVacIniPer  := " "  As Character
    Local cVacFinPer  := " "  As Character

    Default nLine := 1

    cWorkIniPer := AllTrim(cValToChar(aDataFrom[8, 2]))  + " " + aDataFrom[10, 2] + " 20" + AllTrim(cValToChar(aDataFrom[12, 2]))
    cWorkFinPer := AllTrim(cValToChar(aDataFrom[9, 2]))  + " " + aDataFrom[11, 2] + " 20" + AllTrim(cValToChar(aDataFrom[13, 2]))
    // checking the availability of additional leave from an employee
    If cValToChar(aDataFrom[15, 2]) != "" .AND. cValToChar(aDataFrom[31, 2]) != ""
        cVacIniPer  := AllTrim(cValToChar(aDataFrom[15, 2])) + " " + aDataFrom[17, 2] + " 20" + AllTrim(cValToChar(aDataFrom[19, 2]))
        cVacFinPer  := AllTrim(cValToChar(aDataFrom[30, 2])) + " " + aDataFrom[31, 2] + " 20" + AllTrim(cValToChar(aDataFrom[32, 2]))
    EndIf

    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_1",  aDataFrom[4, 2]})    // RA_NOMECMP
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_2",  aDataFrom[5, 2]})    // RA_MAT
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_3",  aDataFrom[6, 2]})    // Department
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_4",  aDataFrom[7, 2]})    // Cargo
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_5",  aDataFrom[14, 2]})   // Count Day Main Vacation
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_6",  aDataFrom[22, 2]})   // Count Day Additional Vacation
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_7",  cWorkIniPer})        // Ini Period of work
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_8",  cWorkFinPer})        // Fin Period of work
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_9",  aDataFrom[29, 2]})   // Count Day All Vacation
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_10", cVacIniPer})         // Ini Period of Vacation
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_11", cVacFinPer})         // Fin Period of Vacation
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_12", Replicate(CRLF, COUNT_STR_FOR_EMPLOYEE_SIGNATURE) + aDataFrom[38, 2]}) // Signature

    lResult := .T.

Return lResult
