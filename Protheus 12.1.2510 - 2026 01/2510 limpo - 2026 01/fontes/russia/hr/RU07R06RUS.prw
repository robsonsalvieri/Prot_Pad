#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R06RUS.CH"

/*/
{Protheus.doc} RU07R06RUS()
    Main function of routine print form T-1.

    @type Function
    @params 
    @author vselyakov
    @since 30.11.2022
    @version 12.1.23
    @return 
    @example AAdd(aRotina, {STR0383, "RU07R06RUS", 0, 11}) //Print the order (From source code GPEA010).
/*/
Function RU07R06RUS()
    Local oDialog As Object
    Local aInputParams As Array
    Local aDataList As Array
    Local lCreateReport As Logical
    Local cPrefixNameForFile As Character

    oDialog := RuHRWordPrintForm():New("RU07R06RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog(, .T.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.
        cPrefixNameForFile := Iif(aInputParameters[6], STR0051 + "-" + STR0052 + " ", STR0045)

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R0601_GetAllData(aInputParams[1], aInputParams[2], aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6]), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameForFile)  ;
                  }, STR0014, STR0015) // "Please wait", "Formation of an admission order".

        If lCreateReport
            MsgInfo(STR0012, STR0011) // "The order for admission has been created!", "Done".
        Else
            MsgStop(STR0013, STR0010) // "Something went wrong when creating an admission order", "Error".
        EndIf

    EndIf

    oDialog := Nil
    FreeObj(oDialog)

Return


/*/
{Protheus.doc} RU07R0601_GetAllData(cTemplatePath, cDocSavePath, cCodeSignature, cNameSignature, aSRAlList)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params cTemplatePath, Character, Path to document with template of print form.
            cDocSavePath, Character, Path to save document of result print form.
            cCodeSignature, Character, Employee post code.
            cNameSignature, Character, Full name of signature this print form.
            aSRAlList, Array, List of selected employee numbers.
            lGroupPrint, Logical, Is grouping printer or not.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.23
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R0601_GetAllData(cPatternPath, cResultPath, cNameSignature, cSRAlList)
/*/
Static Function RU07R0601_GetAllData(cTemplatePath, cDocSavePath, cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)
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
    cFullNameSignature := AllTrim(cNameSignature)
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
    DbSelectArea("SRA")
    DbSetOrder(1) // RA_FILIAL+RA_MAT+RA_NOME.
    DbGoTop()

    If lGroupPrint

        oRuEmployeePrintForm := GrPrintFilter(aSRAList, cCodeSignature)

        Aadd(aDataArray, oRuEmployeePrintForm)
    Else
        For nI := 1 To Len(aSRAList)

            // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
            If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

                oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), GetDataArray(cCodeSignature))

                Aadd(aDataArray, oRuEmployeePrintForm)

            EndIf
        Next nI
    EndIf

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aSRAArea) // Restore SRA area.
    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} GetDataArray(cCodeSignature)
     The function creates an array of variables and data according to the template.

    @type Static Function
    @params cCodeSignature, Character, Selected post code of signature.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.23
    @return 
    @example aDataArray := GetDataArray()
/*/
Static Function GetDataArray(cCodeSignature)
    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cDeptName        As Character
    Local aPositionInfo    As Array
    Local cConditions      As Character
    Local cMonthName       As Character
    Local nTrialPeriod     As Numeric
    Local cTypeBranch      As Character

    aDataArray := {}

    // Get information about company.
    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    // Get information about employee.
    cDeptName := RU07R0603_GetDepartmentName(SRA->RA_DEPTO) // Get information about depto name.
    aPositionInfo := RU07R0604_GetPositionName(SRA->RA_CARGO) // Get information about position.
    cConditions := RU07R0605_GetConditions(SRA->RA_TPCONTR) // Get information about employee conditions of work.
    cMonthName := RU07R0606_GetMonthName(Month(SRA->RA_ADMISSA)) // Get month name by word. Example, 12 = December.
    cPostSignature := RU07R0607_GetPostNameSignature(AllTrim(cCodeSignature))

    nTrialPeriod := Round((SRA->RA_VCTOEXP - SRA->RA_ADMISSA + 1) / 30, 1)

    // Creating an array of variable correspondences in printed form with data loaded into them.
    // ATTENTION: This Array and values also using for T1-a report. If any changes are made to the order of values - change the corresponding indices in the GrPrintFilter function 
    aAdd(aDataArray, {"cOrgName",     cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",    cOKPOCode})
    aAdd(aDataArray, {"RA_ADMISSA",   DToC(SRA->RA_ADMISSA)})
    aAdd(aDataArray, {"RA_DTFIMCT",   Iif(SRA->RA_TPCONTR $ "2", DToC(SRA->RA_DTFIMCT), "")})
    aAdd(aDataArray, {"RA_NOMECMP",   SRA->RA_NOMECMP})
    aAdd(aDataArray, {"RA_MAT",       SRA->RA_MAT})
    aAdd(aDataArray, {"RA_DDEPTO",    cDeptName})
    aAdd(aDataArray, {"RA_DCARGO",    aPositionInfo[1]})
    aAdd(aDataArray, {"Q3_RGWGPR",    Iif(Empty(aPositionInfo[2]), "", aPositionInfo[2] + " " + STR0037)})
    aAdd(aDataArray, {"Q3_CTGCD",     Iif(Empty(aPositionInfo[3]), "", aPositionInfo[3] + " " + STR0038)})
    aAdd(aDataArray, {"cConditions",  cConditions}) // Conditions of work.
    aAdd(aDataArray, {"cTrialPeriod", Iif(SRA->RA_VCTOEXP < SRA->RA_ADMISSA, "0", nTrialPeriod)}) // Trial period. {((SRA->RA_VCTOEXP - SRA->RA_ADMISSA + 1) % 365)/ 30}
    aAdd(aDataArray, {"cDay",         Substr(DToC(SRA->RA_ADMISSA), 1, 2)}) // 23 from day of 23.12.2022
    aAdd(aDataArray, {"cMonth",       cMonthName}) // 12 from month of 23.12.2022
    aAdd(aDataArray, {"cYear",        Substr(DToC(SRA->RA_ADMISSA), 9, 2)}) // 22 from year of 23.12.2022
    aAdd(aDataArray, {"cIntSalary",   Int(SRA->RA_SALARIO)})
    aAdd(aDataArray, {"cExtSalary",   (SRA->RA_SALARIO - Int(SRA->RA_SALARIO)) * 100})
    aAdd(aDataArray, {"cSignPost",    cPostSignature})
    aAdd(aDataArray, {"cSignature",   cFullNameSignature})

Return aDataArray

/*/
{Protheus.doc} GrPrintFilter(aSRAList, cCodeSignature)
    The function creates an RuEmployeePrintForm object and filling his data array for goup printing.

    @type Static Function
    @params aSRAList,       Array,     Array of employees for printer.
    @params cCodeSignature, Character, Selected post code of signature.
    @author dchizhov
    @since 12.01.2023
    @version 12.1.23
    @return oRuEmployeePrintForm, Object, RuEmployeePrintForm object for a printing
    @example oRuEmployeePrintForm := GrPrintFilter(aSRAList, cCodeSignature)
/*/
Static Function GrPrintFilter(aSRAList, cCodeSignature)
    
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
    oRuEmployeePrintForm:aDataList[2] := {"count_column", 11}

    For nI := 1 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := GetDataArray(cCodeSignature)

            Aadd(oRuEmployeePrintForm:aDataList, aData[1])
            Aadd(oRuEmployeePrintForm:aDataList, aData[2])
            Aadd(oRuEmployeePrintForm:aDataList, aData[3])
            Aadd(oRuEmployeePrintForm:aDataList, aData[18])
            Aadd(oRuEmployeePrintForm:aDataList, aData[19])

            dDDim := aData[3, 2]

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R0608_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData)

            EXIT

        EndIf
    Next nI

    For nI := 2 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := GetDataArray(cCodeSignature)

            If !Empty(dDDim) .And. dDDim != aData[3, 2]
                dDDim := NIL
                oRuEmployeePrintForm:aDataList[5, 2] := " "
            EndIf

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R0608_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, oRuEmployeePrintForm:aDataList[1, 2])

        EndIf
    Next nI

Return oRuEmployeePrintForm


/*/
{Protheus.doc} RU07R0602_GetFullNameOfSignature(cCode, cNameSignature)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation.

    @type Function
    @params cCod, Character, Employee personnel number.
            cNameSignature, Character, Result Full name of signer.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return lResult, Logical, Indicates that an employee is attached to the position.
    @example RU07R0602_GetFullNameOfSignature(cCodeSignature, @cNameSignature)
/*/
Static Function RU07R0602_GetFullNameOfSignature(cCode, cNameSignature)
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

        DBCloseArea()

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
        Help(,, STR0010,, STR0023, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0024})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return lResult


/*/
{Protheus.doc} RU07R0603_GetDepartmentName(cDepartmentCode) 
    Function return name of employee department.

    @type Static Function
    @params cDepartmentCode, Character, Employee department code.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return cNameDept, Character, Employee department name.
    @example cDeptName := RU07R0603_GetDepartmentName(SRA->RA_DEPTO)
/*/
Static Function RU07R0603_GetDepartmentName(cDepartmentCode)
    Local cNameDept As Character
    Local aArea     As Array
    Local aSQBArea  As Array

    aArea := GetArea()
    aSQBArea := SQB->(GetArea())
    cNameDept := ""

    DBSelectArea("SQB")
    DBSetOrder(1) // QB_FILIAL+QB_DEPTO+QB_DESCRIC.

    If DBSeek(FwXFilial("SQB") + cDepartmentCode, .T.)
        cNameDept := AllTrim(SQB->QB_DESCRIC)
    EndIf

    RestArea(aSQBArea)
    RestArea(aArea)
Return cNameDept


/*/
{Protheus.doc} RU07R0603_GetDepartmentName(cDepartmentCode) 
    Function return information about employee position.

    @type Static Function
    @params cPositionCode, Character, Employee position code.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return aPositionInformation, Array, Information about employee position
    @example aPositionInfo := RU07R0604_GetPositionName(SRA->RA_CARGO)
/*/
Static Function RU07R0604_GetPositionName(cPositionCode)
    Local aPositionInformation As Character
    Local aArea                As Array
    Local aSQ3Area             As Array

    aArea := GetArea()
    aSQ3Area := SQ3->(GetArea())
    aPositionInformation := {}

    DBSelectArea("SQ3")
    DBSetOrder(1) // // Q3_FILIAL+Q3_CARGO+Q3_CC.

    If DBSeek(FwXFilial("SQ3") + cPositionCode, .T.)
        Aadd(aPositionInformation, AllTrim(SQ3->Q3_DESCSUM)) // Position name.
        Aadd(aPositionInformation, AllTrim(SQ3->Q3_RGWGRP)) // Class.
        Aadd(aPositionInformation, AllTrim(SQ3->Q3_CTGCD)) // Category.
    Else
        Aadd(aPositionInformation, "") // Position name.
        Aadd(aPositionInformation, "") // Class.
        Aadd(aPositionInformation, "") // Category.
    EndIf

    RestArea(aSQ3Area)
    RestArea(aArea)
Return aPositionInformation


/*/
{Protheus.doc} RU07R0605_GetConditions(cTpContr)
    Function return work condition for employee.

    @type Static Function
    @params cTpContr, Character, Type contract for employee.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return cConditions, Character, Work conditions
    @example cConditions := RU07R0605_GetConditions(SRA->RA_TPCONTR)
/*/
Static Function RU07R0605_GetConditions(cTpContr)
    Local aArea       As Array
    Local aCboxTpCont As Array
    Local nInd        As Numeric
    Local cConditions As Character

    aArea := GetArea()
    aCboxTpCont := X3CboxToArray("RA_TPCONTR")

    nInd := aScan(aCboxTpCont[2], {|X| X == cTpContr})
    If nInd > 0 .And. nInd <= Len(aCboxTpCont[1])
        cConditions := aCboxTpCont[1, nInd]
        cConditions := SubStr(aCboxTpCont[1, nInd], At('-', aCboxTpCont[1, nInd]) + 2)
    Else
        cConditions := " "
    EndIf

    RestArea(aArea)
Return cConditions


/*/
{Protheus.doc} RU07R0606_GetMonthName(nMonthNumber)
    Function return name of month.

    @type Static Function
    @params nMonthNumber, Numeric, Month number.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return cMonthName, Character, Description month.
    @example cMonthName := RU07R0606_GetMonthName(Month(SRA->RA_ADMISSA))
/*/
Static Function RU07R0606_GetMonthName(nMonthNumber)
    Local cMonthName As Character

    Do Case
        Case nMonthNumber == 1
            cMonthName := STR0025
        Case nMonthNumber == 2
             cMonthName := STR0026
        Case nMonthNumber == 3
             cMonthName := STR0027
        Case nMonthNumber == 4
             cMonthName := STR0028
        Case nMonthNumber == 5
             cMonthName := STR0029
        Case nMonthNumber == 6
             cMonthName := STR0030
        Case nMonthNumber == 7
             cMonthName := STR0031
        Case nMonthNumber == 8
             cMonthName := STR0032
        Case nMonthNumber == 9
             cMonthName := STR0033
        Case nMonthNumber == 10
             cMonthName := STR0034
        Case nMonthNumber == 11
             cMonthName := STR0035
        Case nMonthNumber == 12
             cMonthName := STR0036
        Otherwise
            cMonthName := ""
    EndCase
    
Return cMonthName


/*/
{Protheus.doc} RU07R0607_GetPostNameSignature(cCodePostSigner)
    Get post name of signer.

    @type Function
    @params cCodePostSigner, Character, Signer post code.
    @author vselyakov
    @since 30.11.2022
    @version 12.1.33
    @return cNamePostSigner, Character, Post name of signer.
    @example cPostSignature := RU07R0607_GetPostNameSignature(AllTrim(cCodeSignature))
/*/
Static Function RU07R0607_GetPostNameSignature(cCodePostSigner)
    Local cFullName  As Character
    Local aArea      As Array
    Local aAreaSQ3   As Array
    Local cNamePostSigner As Character

    cFullName := ""
    aArea := GetArea()
    aAreaSQ3 := SQ3->(GetArea())

    If !Empty(cCodePostSigner)

        // Find name post of signature.
        DBSelectArea("SQ3")
        DBSetOrder(1) // Q3_FILIAL+Q3_CARGO+Q3_CC.

        If DBSeek(FwXFilial("SQ3") + AllTrim(cCodePostSigner), .T.)
            cNamePostSigner := AllTrim(SQ3->Q3_DESCSUM)
        EndIf

    EndIf

    RestArea(aAreaSQ3)
    RestArea(aArea)

Return cNamePostSigner


/*/
{Protheus.doc} RU07R0608_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)
    Filling array for group print from aDataFrom.

    @type Function
    @params aDataPrint, Array,   Array for printing.
    @params aDataFrom,  Array,   Array whith data.
    @params nLine,      Numeric, Number of Filling line.
    @author dchizhov
    @since 12.01.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU07R0608_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, nLine)
/*/
Static Function RU07R0608_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)

    Local cQualif As Character
    Local lResult As Logical

    Default nLine := 1
    
    cQualif := aDataFrom[9, 2] + Iif(Empty(aDataFrom[9, 2]) .Or. Empty(aDataFrom[10, 2]), "", ", ") + aDataFrom[10, 2]
    cQualif := aDataFrom[8, 2] + Iif(!Empty(cQualif), ", ", "") + cQualif

    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_1", aDataFrom[5, 2]}) // RA_NOMECMP
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_2", aDataFrom[6, 2]}) // RA_MAT
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_3", aDataFrom[7, 2]}) // RA_DDEPTO
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_4", cQualif})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_5", SRA->RA_SALARIO})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_6", "-"})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_7", aDataFrom[3, 2]}) // RA_ADMISSA
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_8", aDataFrom[3, 2]}) // RA_ADMISSA
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_9", Iif(Empty(aDataFrom[4, 2]), "-", aDataFrom[4, 2])}) // RA_DTFIMCT
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_10", aDataFrom[12, 2]})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_11", CRLF + aDataFrom[3, 2]}) // RA_ADMISSA

    lResult := .T.

Return lResult
