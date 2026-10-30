#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R24RUS.CH"

#DEFINE COUNT_STR_FOR_EMPLOYEE_SIGNATURE 1

/*/
{Protheus.doc} RU07R24RUS()
    Main function of routine print form T-5.

    @type Function
    @params 
    @author alysenko
    @since 13.05.2024
    @version 12.1.2310
    @return 
    @example AAdd(aRotina, {STR0383, "RU07R24RUS", 0, 11}) //Print the order (From source code GPEA010).
/*/
Function RU07R24RUS()
    Local oDialog As Object
    Local aInputParams As Array
    Local aDataList As Array
    Local lCreateReport As Logical
    Local cPrefixNameForFile As Character

    oDialog := RuHRWordPrintForm():New("RU07R24RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog(STR0013, .T.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.
        cPrefixNameForFile := Iif(aInputParameters[6], STR0014 + "-" + STR0015 + " ", STR0008) // "T-5a" - "Group notice of transfer" "T-5"

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R2401_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6]), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameForFile)  ;
                  }, STR0006, STR0007) // "Please wait", "Formation of an transfer order".

        If lCreateReport
            MsgInfo(STR0004, STR0003) // "The order for transfer has been created!", "Done".
        Else
            MsgStop(STR0005, STR0002) // "Something went wrong when creating an transfer order", "Error".
        EndIf

    EndIf

    oDialog := Nil
    FreeObj(oDialog)

Return

/*/
{Protheus.doc} RU07R2401_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params cCodeSignature, Character, Employee post code.
    @params cNameSignature, Character, Full name of signature this print form.
    @params aSRAlList,   Array, List of selected employee numbers.
    @params lGroupPrint, Logical, Is grouping printer or not.
    @author alysenko
    @since 13.05.2024
    @version 12.1.2310
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R2401_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6])
/*/
Static Function RU07R2401_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)

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

                oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), RU07R2402_GetDataArray(cCodeSignature, AllTrim(cNameSignature)))
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
{Protheus.doc} RU07R2402_GetDataArray(cCodeSignature, cNameSignature)
    The function creates an array of variables and data according to the template.

    @type Static Function
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author alysenko
    @since 13.05.2024
    @version 12.1.2310
    @return aDataArray, Array, Array of variables and data
    @example aDataArray := RU07R2402_GetDataArray(cCodeSignature, cNameSignature)
/*/
Static Function RU07R2402_GetDataArray(cCodeSignature, cNameSignature)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cIniDeptName     As Character
    Local aIniPosInfo      As Array
    Local cFinDeptName     As Character
    Local aFinPosInfo      As Array
    Local cPostSignature   As Character
    Local cTypeBranch      As Character
    Local aSearchParRCL    As Array

    aDataArray := {}
    aDateCurrent := {Date(), , , }
    aDateCurrent[2] := Day(aDateCurrent[1])
    aDateCurrent[3] := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(aDateCurrent[1]))
    aDateCurrent[4] := SubStr(DToC(aDateCurrent[1]), 9, 2)
    aSearchParRCL := {PadR(SRE->RE_FILIALD, TamSX3("RCL_FILIAL")[1], " "), RetOrdem("RCL", "RCL_FILIAL+RCL_POSTO")}
    DBSelectArea("RCL")

    // Get information about company.
    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    // Get information about employee.
    cIniDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRE->RE_DEPTOD) // Get information about depto name.
    aIniPosInfo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, FDesc("RCL", SRE->RE_POSTOD, "RCL_CARGO", , aSearchParRCL[1], aSearchParRCL[2])) // Get information about position.
    cFinDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRE->RE_DEPTOP) // Get information about depto name.
    aFinPosInfo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, FDesc("RCL", SRE->RE_POSTOP, "RCL_CARGO", , aSearchParRCL[1], aSearchParRCL[2])) // Get information about position.
    cPostSignature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(cCodeSignature)) // Get name of post for signature

    // Creating an array of variable correspondences in printed form with data loaded into them.
    // ATTENTION: This Array and values also using for T5-a report. If any changes are made to the order of values - change the corresponding indices in the GrPrintFilter function 
    aAdd(aDataArray, {"cOrgName",        cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",       cOKPOCode})
    aAdd(aDataArray, {"cDateIniTransf",  Iif(Empty(SRE->RE_DATA), " ", DToC(SRE->RE_DATA))})
    aAdd(aDataArray, {"cDateFinTransf",  Iif(Empty(SRA->RA_DTFIMCT) .AND. (SRA->RA_TPCONTR != '2') , " ", DToC(SRA->RA_DTFIMCT))})
    aAdd(aDataArray, {"cEmpFullName",    AllTrim(SRA->RA_NOMECMP)})
    aAdd(aDataArray, {"cEmployMat",      AllTrim(SRA->RA_MAT)})
    aAdd(aDataArray, {"cEmpTypeContr",   Iif(SRA->RA_TPCONTR == "1", STR0009, STR0010)}) // "permanently", "temporarily"
    aAdd(aDataArray, {"cDStructDep",     Iif(Empty(cIniDeptName), "-", cIniDeptName)})
    aAdd(aDataArray, {"cDEmpCargo",      aIniPosInfo[1]})
    aAdd(aDataArray, {"cReasonTrans",    Iif(Empty(SRE->RE_TRFOBS), " ", AllTrim(SRE->RE_TRFOBS))})
    aAdd(aDataArray, {"cStructDep",      Iif(Empty(cFinDeptName), "-", cFinDeptName)})
    aAdd(aDataArray, {"cEmpCargo",       aFinPosInfo[1]})
    aAdd(aDataArray, {"cIntSalary",      Int(SRA->RA_SALARIO)})
    aAdd(aDataArray, {"cExtSalary",      Iif((SRA->RA_SALARIO - Int(SRA->RA_SALARIO)) == 0, "00", Str((SRA->RA_SALARIO - Int(SRA->RA_SALARIO)) * 100))})
    aAdd(aDataArray, {"cDayEmpContr",    Substr(DToC(SRA->RA_ADMISSA), 1, 2)})
    aAdd(aDataArray, {"cMonthEmpContr",  StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_ADMISSA))})
    aAdd(aDataArray, {"cYearEmpContr",   Substr(DToC(SRA->RA_ADMISSA), 9, 2)})
    aAdd(aDataArray, {"cPostSignature",  cPostSignature})
    aAdd(aDataArray, {"cNameSignature",  cNameSignature})
    aAdd(aDataArray, {"cDayCurrent",     aDateCurrent[2]})
    aAdd(aDataArray, {"cMonthCurrent",   aDateCurrent[3]})
    aAdd(aDataArray, {"cYearCurrent",    aDateCurrent[4]})
    aAdd(aDataArray, {"cEmplSignatur",   AllTrim(SRA->RA_NOME)})

    FreeObj(aSearchParRCL)

Return aDataArray

/*/
{Protheus.doc} GrPrintFilter(aSRAList, cCodeSignature)
    The function creates an RuEmployeePrintForm object and filling his data array for goup printing.

    @type Static Function
    @params aSRAList,       Array,     Array of employees for printer.
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author alysenko
    @since 13.05.2024
    @version 12.1.2310
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing
    @example oRuEmployeePrintForm := GrPrintFilter(aSRAList, cCodeSignature)
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

            aData := RU07R2402_GetDataArray(cCodeSignature, cNameSignature)

            Aadd(oRuEmployeePrintForm:aDataList, aData[1])
            Aadd(oRuEmployeePrintForm:aDataList, aData[2])
            Aadd(oRuEmployeePrintForm:aDataList, aData[3])
            Aadd(oRuEmployeePrintForm:aDataList, aData[18])
            Aadd(oRuEmployeePrintForm:aDataList, aData[19])

            dDDim := aData[3, 2]

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R2404_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData)

            EXIT

        EndIf
    Next nI

    For nI := 2 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := RU07R2402_GetDataArray(cCodeSignature, cNameSignature)

            If !Empty(dDDim) .And. dDDim != aData[3, 2]
                dDDim := NIL
                oRuEmployeePrintForm:aDataList[5, 2] := " "
            EndIf

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R2404_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, oRuEmployeePrintForm:aDataList[1, 2])

        EndIf
    Next nI

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU07R2404_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)
    Filling array for group print from aDataFrom.

    @type Function
    @params aDataPrint, Array,   Array for printing.
    @params aDataFrom,  Array,   Array whith data.
    @params nLine,      Numeric, Number of Filling line.
    @author alysenko
    @since 13.05.2024
    @version 12.1.2310
    @return lResult, Logical, Is a success.
    @example RU07R2404_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, nLine)
/*/
Static Function RU07R2404_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)

    Local lResult As Logical
    Local cSalary As Character
    
    Default nLine := 1

    cSalary := AllTrim(Str(aDataFrom[13, 2])) + "-" + AllTrim(aDataFrom[14, 2])

    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_1",  aDataFrom[5, 2]})    // RA_NOMECMP
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_2",  aDataFrom[6, 2]})    // RA_MAT
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_3",  aDataFrom[8, 2]})    // Old Department
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_4",  aDataFrom[11, 2]})   // New Department name
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_5",  aDataFrom[9, 2]})    // Old Cargo 
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_6",  aDataFrom[12, 2]})   // New Cargo
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_7",  cSalary})            // Salario
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_8",  aDataFrom[3, 2]})    // IniDate
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_9",  aDataFrom[4, 2]})    // FinDate
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_10", " "})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_11", " "})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_12", Replicate(CRLF, COUNT_STR_FOR_EMPLOYEE_SIGNATURE) + aDataFrom[23, 2]}) // Signature  

    lResult := .T.

Return lResult
