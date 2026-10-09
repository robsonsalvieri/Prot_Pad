#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R07RUS.CH"

#DEFINE TPCONTR_FOR_DISMISS "2"

#DEFINE COUNT_STR_FOR_EMPLOYEE_SIGNATURE 1

/*/
{Protheus.doc} RU07R07RUS()
    Main function of routine print form T-8.

    @type Function
    @params 
    @author dchizhov
    @since 26.12.2022
    @version 12.1.23
    @return 
    @example AAdd(aRotina, {STR0383, "RU07R07RUS", 0, 11}) 
/*/
Function RU07R07RUS()

    Local oDialog As Object
    Local aInputParams As Array
    Local aDataList As Array
    Local lCreateReport As Logical
    Local cPrefixNameForFile As Character

    oDialog := RuHRWordPrintForm():New("RU07R07RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog(STR0013, .T.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.

        cPrefixNameForFile := Iif(aInputParameters[6], STR0014 + "-" + STR0015 + " ", STR0008)

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R0701_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6]), ;
                      lCreateReport := oDialog:PrintReport(aDataList, cPrefixNameForFile)  ;
                  }, STR0006, STR0007) // "Please wait", "Formation of an admission order".

        If lCreateReport
            MsgInfo(STR0004, STR0003) // "The order for admission has been created!", "Done".
        Else
            MsgStop(STR0005, STR0002) // "Something went wrong when creating an admission order", "Error".
        EndIf

    EndIf

    oDialog := Nil
    FreeObj(oDialog)

Return

/*/
{Protheus.doc} RU07R0701_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params cCodeSignature, Character, Employee post code.
    @params cNameSignature, Character, Full name of signature this print form.
    @params aSRAlList,   Array, List of selected employee numbers.
    @params lGroupPrint, Logical, Is grouping printer or not.
    @author dchizhov
    @since 26.12.2022
    @version 12.1.23
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R0701_GetAllData(aInputParams[3], aInputParams[4], aInputParams[5], aInputParams[6])
/*/
Static Function RU07R0701_GetAllData(cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)

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

                oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), RU07R0702_GetDataArray(cCodeSignature, AllTrim(cNameSignature)))
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
{Protheus.doc} RU07R0702_GetDataArray(cCodeSignature, cNameSignature)
    The function creates an array of variables and data according to the template.

    @type Static Function
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author dchizhov
    @since 26.12.2022
    @version 12.1.23
    @return aDataArray, Array, Array of variables and data
    @example aDataArray := RU07R0702_GetDataArray(cCodeSignature, cNameSignature)
/*/
Static Function RU07R0702_GetDataArray(cCodeSignature, cNameSignature)

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cDeptName        As Character
    Local aPositionInfo    As Array
    Local aDisReason       As Array
    Local cPostSignature   As Character
    Local cDayDemissa      As Numeric
    Local cMonthDemissa    As Numeric
    Local cYearDemissa     As Numeric
    Local cTypeBranch      As Character

    aDataArray := {}

    // Get information about company.
    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    // Get information about employee.
    cDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRA->RA_DEPTO) // Get information about depto name.
    aPositionInfo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SRA->RA_CARGO) // Get information about position.
    aDisReason := RU07XFUN24_GetReasonDissmiss(SRA->RA_FILIAL, SRA->RA_MAT, DToS(SRA->RA_DEMISSA)) // Get information about reason for dismissal
    cPostSignature := StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, AllTrim(cCodeSignature)) // Get name of post for signature
    cDayDemissa   := Substr(DToC(SRA->RA_DEMISSA), 1, 2) // Day of demissa
    cMonthDemissa := StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_DEMISSA)) // Month of demissa
    cYearDemissa  := Substr(DToC(SRA->RA_DEMISSA), 9, 2) // Year of demissa

    // Creating an array of variable correspondences in printed form with data loaded into them.
    // ATTENTION: This Array and values also using for T1-a report. If any changes are made to the order of values - change the corresponding indices in the GrPrintFilter function 
    aAdd(aDataArray, {"cOrgName",       cOrganzationName})
    aAdd(aDataArray, {"cOKPOCode",      cOKPOCode})
    aAdd(aDataArray, {"cDateCreation",  Iif(Empty(SRA->RA_DEMISSA), " ", DToC(SRA->RA_DEMISSA))})
    aAdd(aDataArray, {"cDayEmpContr",   Substr(DToC(SRA->RA_ADMISSA), 1, 2)})
    aAdd(aDataArray, {"cMonthEmpContr", StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_ADMISSA))})
    aAdd(aDataArray, {"cYearEmpContr",  Substr(DToC(SRA->RA_ADMISSA), 9, 2)})
    aAdd(aDataArray, {"cDayEmpDis",     cDayDemissa})
    aAdd(aDataArray, {"cMonthEmpDis",   cMonthDemissa})
    aAdd(aDataArray, {"cYearEmpDis",    cYearDemissa})
    aAdd(aDataArray, {"cDisEmpName",    AllTrim(SRA->RA_NOMECMP)})
    aAdd(aDataArray, {"cDisEmpMat",     AllTrim(SRA->RA_MAT)})
    aAdd(aDataArray, {"cDisEmpDepart",  Iif(Empty(cDeptName), "-", cDeptName)})
    aAdd(aDataArray, {"cDisEmpPost",    aPositionInfo[1]})
    aAdd(aDataArray, {"cDisEmpClass",   Iif(Empty(aPositionInfo[2]), "", aPositionInfo[2] + " " + STR0009)})
    aAdd(aDataArray, {"cDisEmpCateg",   Iif(Empty(aPositionInfo[3]), "", aPositionInfo[3] + " " + STR0010)})
    aAdd(aDataArray, {"cDisEmpReason",  Iif(Len(aDisReason) > 1, aDisReason[2], "")})
    aAdd(aDataArray, {"cDisEmpGrounds", ""}) // RU07R0703_GroundsForDismissal()
    aAdd(aDataArray, {"cPostSignature", cPostSignature})
    aAdd(aDataArray, {"cNameSignature", cNameSignature})
    aAdd(aDataArray, {"cDayAcquaint",   cDayDemissa})
    aAdd(aDataArray, {"cMonthAcquaint", cMonthDemissa})
    aAdd(aDataArray, {"cYearAcquaint",  cYearDemissa})

Return aDataArray

/*/
{Protheus.doc} GrPrintFilter(aSRAList, cCodeSignature)
    The function creates an RuEmployeePrintForm object and filling his data array for goup printing.

    @type Static Function
    @params aSRAList,       Array,     Array of employees for printer.
    @params cCodeSignature, Character, Selected post code of signature.
    @params cNameSignature, Character, Selected name of signature.
    @author dchizhov
    @since 17.01.2023
    @version 12.1.23
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
    oRuEmployeePrintForm:aDataList[2] := {"count_column", 10}

    For nI := 1 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := RU07R0702_GetDataArray(cCodeSignature, cNameSignature)

            Aadd(oRuEmployeePrintForm:aDataList, aData[1])
            Aadd(oRuEmployeePrintForm:aDataList, aData[2])
            Aadd(oRuEmployeePrintForm:aDataList, aData[3])
            Aadd(oRuEmployeePrintForm:aDataList, aData[18])
            Aadd(oRuEmployeePrintForm:aDataList, aData[19])

            dDDim := aData[3, 2]

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R0704_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData)

            EXIT

        EndIf
    Next nI

    For nI := 2 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            aData := RU07R0702_GetDataArray(cCodeSignature, cNameSignature)

            If !Empty(dDDim) .And. dDDim != aData[3, 2]
                dDDim := NIL
                oRuEmployeePrintForm:aDataList[5, 2] := " "
            EndIf

            oRuEmployeePrintForm:aDataList[1, 2] += 1
            RU07R0704_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, oRuEmployeePrintForm:aDataList[1, 2])

        EndIf
    Next nI

Return oRuEmployeePrintForm

/*/
{Protheus.doc} RU07R0703_GroundsForDismissal()
    The function get grounds for dismissal.

    @type Static Function
    @params 
    @author dchizhov
    @since 28.12.2022
    @version 12.1.23
    @return cGroundForDis, Character, Grounds for dismissal
    @example cGrForDismiss := RU07R0703_GroundsForDismissal
/*/
Static Function RU07R0703_GroundsForDismissal()

    Local cGroundForDis As Character
    Local aArea         As Array
    Local aSRGArea      As Array
    Local nOrder        As Numeric
    Local cKeySeek      As Character

    aArea := GetArea()
    aSRGArea := SRG->(GetArea())

    cKeySeek := SRA->RA_FILIAL + SRA->RA_MAT + DToS(SRA->RA_DEMISSA)

    DbSelectArea("SRG")

    nOrder := RetOrder("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)")

    SRG->(DbSetOrder(nOrder))

    If SRG->(DbSeek(cKeySeek))
        While SRG->RG_FILIAL + SRG->RG_MAT + DTOS(SRG->RG_DATADEM) == cKeySeek
            cGroundForDis := fDescRCC("S043", Iif(Type("cTipRes")=="C" .And. !Empty(cTipRes), cTipRes, SRG->RG_TIPORES), 1, 2, 3, 30)
            SRG->(DbSkip())
        EndDo
    EndIf

    // Primal logic (old variant)
    // cGroundForDis := STR0012
    // If SRA->RA_TPCONTR == TPCONTR_FOR_DISMISS .And. !Empty(SRA->RA_DTFIMCT)
    //     cGroundForDis := STR0011
    // EndIf

    SRG->(RestArea(aSRGArea))
    RestArea(aArea)

Return cGroundForDis

/*/
{Protheus.doc} RU07R0704_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)
    Filling array for group print from aDataFrom.

    @type Function
    @params aDataPrint, Array,   Array for printing.
    @params aDataFrom,  Array,   Array whith data.
    @params nLine,      Numeric, Number of Filling line.
    @author dchizhov
    @since 12.01.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU07R0704_FillDataForGroupPrint(oRuEmployeePrintForm:aDataList, aData, nLine)
/*/
Static Function RU07R0704_FillDataForGroupPrint(aDataPrint, aDataFrom, nLine)

    Local cQualif As Character
    Local lResult As Logical
    Local cDAdmis As Character

    Default nLine := 1
    
    cQualif := aDataFrom[14, 2] + Iif(Empty(aDataFrom[14, 2]) .Or. Empty(aDataFrom[15, 2]), "", ", ") + aDataFrom[15, 2]
    cQualif := aDataFrom[13, 2] + Iif(!Empty(cQualif), ", ", "") + cQualif

    cDAdmis := DToC(SRA->RA_ADMISSA)

    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_1",  aDataFrom[10, 2]}) // RA_NOMECMP
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_2",  aDataFrom[11, 2]}) // RA_MAT
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_3",  aDataFrom[12, 2]}) // Department name
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_4",  cQualif}) // Post + razryad + qualification
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_5",  " "}) 
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_6",  cDAdmis}) // RA_ADMISSA
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_7",  aDataFrom[3, 2]}) // RA_DEMISSA
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_8",  RU07R0703_GroundsForDismissal()}) // RG_DESCTPR
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_9",  " "})
    Aadd(aDataPrint, {"doc_variable_" + cValToChar(nLine) + "_10", Replicate(CRLF, COUNT_STR_FOR_EMPLOYEE_SIGNATURE) + aDataFrom[3, 2]}) //    aDataFrom[12, 2]})

    lResult := .T.

Return lResult
