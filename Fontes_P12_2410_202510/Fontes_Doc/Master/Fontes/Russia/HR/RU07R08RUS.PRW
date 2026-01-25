#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R08RUS.CH"

#DEFINE CODE_COMMON_EXPERIANCE "01"

#DEFINE CODEFOL_FOR_VACATION "0072"

/*/
{Protheus.doc} RU07R08RUS()
    Main function of routine print form T-2.

    @type Function
    @params 
    @author dchizhov
    @since 19.01.2023
    @version 12.1.23
    @return 
    @example AAdd(aRotina, {STR0496, "RU07R08RUS", 0, 11}) 
/*/
Function RU07R08RUS()

    Local oDialog       As Object
    Local aInputParams  As Array
    Local aDataList     As Array
    Local lCreateReport As Logical
    Local cCrText       As character
    Local cCrEText      As character
    local cErrText      As Character

    oDialog := RuHRWordPrintForm():New("RU07R08RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog( , , .F.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.

        If Len(aInputParams[5]) > 1
            cCrText := STR0010 // Formation of personal cards of employees
            cCrEText := STR0005 // Personal employee cards have been created!
            cErrText := STR0007 // Something went wrong while creating employee personal cards
        Else
            cCrText := STR0009 // Creation of an employee's personal card
            cCrEText := STR0004 // The employee's personal card has been created!
            cErrText := STR0006 // Something went wrong while creating an employee's personal card
        EndIf

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R0801_GetAllData(aInputParams[5]), ;
                      lCreateReport := oDialog:PrintReport(aDataList, STR0011 + "-" + STR0001, .T.)  ;
                  }, STR0008, cCrText) // "Please wait"

        If lCreateReport
            MsgInfo(cCrEText, STR0003) // "The order for admission has been created!", "Done".
        Else
            MsgStop(cErrText, STR0002) // "Something went wrong when creating an admission order", "Error".
        EndIf

    EndIf

    oDialog := Nil
    FreeObj(oDialog)

Return

/*/
{Protheus.doc} RU07R0801_GetAllData(aSRAlList)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params aSRAlList, Array, List of selected employee numbers.
    @author dchizhov
    @since 19.01.2023
    @version 12.1.23
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R0801_GetAllData(aInputParams[5])
/*/
Static Function RU07R0801_GetAllData(aSRAlList)

    Local aDataArray As Array
    Local aSRAList As Array
    Local aArea As Array
    Local aSRAArea As Array
    Local nI As Numeric
    Local oRuEmployeePrintForm As Object
    Local nOrder As Numeric
    Local cSearch As Character

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

    For nI := 1 To Len(aSRAList)

        // We are positioning ourselves on an employee with the specified TN. If the result is empty, then we do not execute further.
        If !Empty(Posicione("SRA", nOrder, cSearch + aSRAList[nI], "RA_MAT"))

            oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), RU07R0802_GetDataArray())
            aAdd(aDataArray, oRuEmployeePrintForm)
        
        EndIf
    Next nI

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

    RestArea(aSRAArea) // Restore SRA area.
    RestArea(aArea)

Return aDataArray

/*/
{Protheus.doc} RU07R0802_GetDataArray()
    The function creates an array of variables and data according to the template.

    @type Static Function
    @author dchizhov
    @since 26.12.2022
    @version 12.1.23
    @return aDataArray, Array, Array of variables and data
    @example oRuEmployeePrintForm := RuEmployeePrintForm():New(SRA->RA_MAT, AllTrim(SRA->RA_NOMECMP), RU07R0802_GetDataArray())
/*/
Static Function RU07R0802_GetDataArray()

    Local aDataArray       As Array
    Local cOrganzationName As Character
    Local cOKPOCode        As Character
    Local aGetCoBrRusInfo  As Array
    Local cDeptName        As Character
    Local aPositionInfo    As Array
    Local cEmpAdmissa      As Character
    Local aDateCurrent     As Array
    Local aExperiance      As Array
    Local aDimensionTable  As Array
    Local cAddress         As Character
    Local cPlaceOfBirth    As Character
    Local cTempStr         As Character
    Local cTelephone       As Character
    Local aHistory         As Array
    Local cTypeBranch      As Character

    aDataArray := {}
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
    cEmpAdmissa := DToC(SRA->RA_ADMISSA)
    aExperiance := RU07R0804_GetExpDetail()
    cAddress := AllTrim(SRA->RA_ENDEREC) + Iif(Len(AllTrim(SRA->RA_ENDEREC + SRA->RA_NUMENDE)) > 0, ",", "") + " " + Iif(Empty(AllTrim(SRA->RA_NUMENDE)), "", STR0018) + SRA->RA_NUMENDE
    cDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, SRA->RA_DEPTO) // Get information about depto name.
    aPositionInfo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SRA->RA_CARGO) // Get information about position.
    cPlaceOfBirth := Iif(Empty(SRA->RA_NATURAL), "", STR0019 + " '" + AllTrim(RU07R0803_GetTabValueForKeyOrder("SX5", "12" + SRA->RA_NATURAL, ;
                     , "X5Descri()")) + "'")
    cTempStr := Iif(Empty(SRA->RA_CODMUNN), "", STR0020 + " '" + AllTrim(RU07R0803_GetTabValueForKeyOrder("CC2", SRA->RA_CODMUNN, ;
                     "CC2_FILIAL+CC2_CODMUN", "CC2_MUN")) + "'")
    cPlaceOfBirth := cPlaceOfBirth + Iif(Len(cPlaceOfBirth) > 0 .And. Len(cTempStr) > 0, ", ", "") + cTempStr
    cTelephone := AllTrim(AllTrim(SRA->RA_DDDFONE) + " " + AllTrim(SRA->RA_TELEFON))
    cTempStr := AllTrim(AllTrim(SRA->RA_DDDCELU) + " " + AllTrim(SRA->RA_NUMCELU))
    cTelephone := cTelephone + Iif(Len(cTelephone) > 0 .And. Len(cTempStr) > 0, ", ", "") + cTempStr
    aHistory := RU07R0810_GetTransfTipoPosValor(SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_ADMISSA, aPositionInfo[1], Int(SRA->RA_SALARIO), .T.)

    // Creating an array of variable correspondences in printed form with data loaded into them.

        // heading
            aAdd(aDataArray, {"cOrgName",       cOrganzationName})
            aAdd(aDataArray, {"cOKPOCode",      cOKPOCode})
            aAdd(aDataArray, {"cDateCreation",  cEmpAdmissa})
            aAdd(aDataArray, {"cEmpMat",        AllTrim(SRA->RA_MAT)})
            aAdd(aDataArray, {"cEmpPis",        AllTrim(SRA->RA_PIS)})
            aAdd(aDataArray, {"cEmpCic",        Transform(AllTrim(SRA->RA_CIC), GetSX3Cache("RA_CIC", "X3_PICTURE"))})
            aAdd(aDataArray, {"cEmpAlphabet",   SubStr(AllTrim(SRA->RA_PRISOBR), 1, 1)})
            aAdd(aDataArray, {"cEmpTpContr",    Iif(SRA->RA_TPCONTR == "1", STR0012, STR0013)})
            aAdd(aDataArray, {"cEmpTpWork",     STR0014})
            aAdd(aDataArray, {"cEmpSex",        Lower(RU07XFUN25_GetComboSelected("RA_SEXO", SRA->RA_SEXO))})

        // 1 section
            aAdd(aDataArray, {"cEmpAdmissa",    cEmpAdmissa})
            aAdd(aDataArray, {"cEmpSurname",    SRA->RA_PRISOBR})
            aAdd(aDataArray, {"cEmpName",       SRA->RA_PRINOME})
            aAdd(aDataArray, {"cEmpPatronymic", SRA->RA_SECNOME})
            aAdd(aDataArray, {"cEmpBirthDay",   CValToChar(Day(SRA->RA_NASC)) + " " + StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_NASC)) ;
                                                 + " " + CValToChar(Year(SRA->RA_NASC)) + " " + STR0015})
            aAdd(aDataArray, {"cEmpRANasc",     DToC(SRA->RA_NASC)})
            aAdd(aDataArray, {"cEmpBirthCity",  cPlaceOfBirth})
            aAdd(aDataArray, {"cEmpNaciona",    RU07R0803_GetTabValueForKeyOrder("SYA", SRA->RA_NACIONC, , "YA_DESCR", SRA->RA_FILIAL)})
            aAdd(aDataArray, {"cEmpEducation",  RU07R0803_GetTabValueForKeyOrder("SX5", "26" + SRA->RA_GRINRAI, , "X5Descri()")})
            aAdd(aDataArray, {"cEmpExpDToDay",  aDateCurrent[2]})
            aAdd(aDataArray, {"cEmpExpDToMon",  aDateCurrent[3]})
            aAdd(aDataArray, {"cEmpExpDToYear", aDateCurrent[4]})
            aAdd(aDataArray, {"cEmpExpComDay",  aExperiance[1]})
            aAdd(aDataArray, {"cEmpExpComMon",  aExperiance[2]})
            aAdd(aDataArray, {"cEmpExpComYear", aExperiance[3]})
            aAdd(aDataArray, {"cEmpFamilyPos",  RU07R0803_GetTabValueForKeyOrder("SX5", "33" + SRA->RA_ESTCIVI, , "X5Descri()")})
            aDimensionTable := {0, 3}
            RU07R0808_SetFamilyMember(aDataArray, aDimensionTable)
            aAdd(aDataArray, {"cEmpPassSeria",  SubStr(SRA->RA_NUMEPAS, 1, 4)})
            aAdd(aDataArray, {"cEmpPassNumb",   SubStr(SRA->RA_NUMEPAS, 5, 6)})
            aAdd(aDataArray, {"cEmpPassDateD",  Day(SRA->RA_DEMIPAS)})
            aAdd(aDataArray, {"cEmpPassDateM",  StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_DEMIPAS))})
            aAdd(aDataArray, {"cEmpPassDateY",  Year(SRA->RA_DEMIPAS)})
            aAdd(aDataArray, {"cEmpPassWhoGiv", SRA->RA_EMISPAS})
            aAdd(aDataArray, {"cEmpPassAddrI",  SRA->RA_CEP})
            aAdd(aDataArray, {"cEmpPassAddrL",  cAddress})
            aAdd(aDataArray, {"cEmpFactAddrL",  SRA->RA_LOGRDSC})
            aAdd(aDataArray, {"cEmpPhoneNumb",  cTelephone})
        
        // 2 section
            // not relized, do not fill out

        // 3 section
            aDimensionTable := {0, 6}
            aDimensionTable[1] += 1
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_1", SRA->RA_ADMISSA})
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_2", cDeptName})
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_3", aHistory[1]})
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_4", aHistory[2]})
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_5", " "})
            aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_6", " "})
            RU07R0809_SetTransfEmployee(aDataArray, aDimensionTable, aPositionInfo[1], Int(SRA->RA_SALARIO), SRA->RA_ADMISSA)

        // 4 section
            // not relized, do not fill out

        // 5 section
            aDimensionTable := {0, 8}
            RU07R0805_SetCursoDetail(aDataArray, aDimensionTable)

        // 6 section
            // not relized, do not fill out

        // 7 section
            // not relized, do not fill out

        // 8 section
            aDimensionTable := {0, 7}
            RU07R0806_SetVacationList(aDataArray, aDimensionTable)

        // 9 section
            // not relized, do not fill out

        // 10 section
            // not relized, do not fill out

        // 11 section
            aAdd(aDataArray, {"cEmpReasonDem",  RU07R0807_ReasonForDismissal()})
            aAdd(aDataArray, {"cEmpDemDay",     Iif(Empty(SRA->RA_DEMISSA), "", Day(SRA->RA_DEMISSA))})
            aAdd(aDataArray, {"cEmpDemMonth",   StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_DEMISSA))})
            aAdd(aDataArray, {"cEmpDemYear",    SubStr(DToC(SRA->RA_DEMISSA), 9, 2)})
            aAdd(aDataArray, {"cEmpDemOrDay",   Iif(Empty(SRA->RA_DEMISSA), "", Day(SRA->RA_DEMISSA))})
            aAdd(aDataArray, {"cEmpDemOrMonth", StaticCall(RU07R06RUS, RU07R0606_GetMonthName, Month(SRA->RA_DEMISSA))})
            aAdd(aDataArray, {"cEmpDemOrYear",  SubStr(DToC(SRA->RA_DEMISSA), 9, 2)})

Return aDataArray

/*/
{Protheus.doc} RU07R0803_GetTabValueForKeyOrder(cAlias, cKey, cOrder, cNameFieldValue, cFilial)
    The function get element of dictionary

    @type Static Function
    @params cAlias,          Character, Alias of dictionary
    @params cKey,            Character, Key for search
    @params cOrder,          Character, Order for search
    @params cNameFieldValue, Character, Name of field for value
    @params cFilial,         Character, Filial for search
    @author dchizhov
    @since 19.01.2023
    @version 12.1.23
    @return cValue, Character, Value of dictionary
    @example aAdd(aDataArray, {"cEmpBirthCity",  RU07R0803_GetTabValueForKeyOrder("CC2", SRA->RA_CODMUNN, "CC2_FILIAL+CC2_CODMUN", "CC2_MUN")})
/*/
Static Function RU07R0803_GetTabValueForKeyOrder(cAlias, cKey, cOrder, cNameFieldValue, cFil)

    Local aArea As Array
    local aTableArea As Array
    Local cValue As Character
    Local nOrder As Numeric

    Default cOrder := ""

    aArea := GetArea()
    aTableArea := &(cAlias)->(GetArea())

    nOrder := Iif(Empty(cOrder), Nil, RetOrder(cAlias, cOrder))

    cValue := FDesc(cAlias, cKey, cNameFieldValue, , cFil, nOrder) 

    &(cAlias)->(RestArea(aTableArea))
    RestArea(aArea)

Return cValue

/*/
{Protheus.doc} RU07R0804_GetExpDetail(cAlias, cKey, cOrder, cNameFieldValue, cFilial)
    The function get detail about experiance

    @type Static Function
    @author dchizhov
    @since 23.01.2023
    @version 12.1.23
    @return aReturn, Array, Array with detail about experiance
    @example aExperiance := RU07R0804_GetExpDetail()
/*/
Static Function RU07R0804_GetExpDetail()

    Local aArea      As Array
    local aReturn    As Array
    Local oStatement As Object
    Local cTab       As Character

    aArea := GetArea()

    oStatement := FWPreparedStatement():New(" SELECT SUM(F5H_YEARS) AS YEARS, SUM(F5H_MONTHS) AS MONTHS, SUM(F5H_DAYS) AS DAYS FROM " ;
    + RetSQLName("F5H") + " FH WHERE F5H_FILIAL = ? AND F5H_MAT = ? AND F5H_CODE = ? AND D_E_L_E_T_ = ' ' ")
    oStatement:SetString(1, SRA->RA_FILIAL)
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, CODE_COMMON_EXPERIANCE)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    aReturn := {(cTab)->DAYS, (cTab)->MONTHS, (cTab)->YEARS }

    (cTab)->(DBCloseArea())

    oStatement:Destroy()
    FwFreeObj(oStatement)

    While aReturn[1] >= 30
        aReturn[2] += 1
        aReturn[1] -= 30
    EndDo

    While aReturn[2] >= 12
        aReturn[3] += 1
        aReturn[2] -= 12
    EndDo

    RestArea(aArea)

Return aReturn

/*/
{Protheus.doc} RU07R0805_SetCursoDetail(aDataArray, aDimensionTable)
    The function set detail about curso into date array 

    @type Static Function
    @params aDataArray,      Array, Date array
    @params aDimensionTable, Array, Dimension array for writing table
    @author dchizhov
    @since 24.01.2023
    @version 12.1.23
    @return lReturn, Logical, Is success
    @example RU07R0805_SetCursoDetail(aDataArray, aDimensionTable)
/*/
Static Function RU07R0805_SetCursoDetail(aDataArray, aDimensionTable)

    Local aArea      As Array
    local lReturn    As Logical
    Local aRA4Area   As Array

    aArea := GetArea()
    aRA4Area := RA4->(GetArea())

    DbSelectArea("RA4")
    RA4->(DbSetOrder(RetOrdem("RA4", "RA4_FILIAL+RA4_MAT")))

    If RA4->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !(RA4->(EOF())) .And. RA4->RA4_FILIAL == SRA->RA_FILIAL .And. RA4->RA4_MAT == SRA->RA_MAT
            aDimensionTable[1] += 1
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_1", DToC(RA4->RA4_DATAIN)})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_2", DToC(RA4->RA4_DATAFI)})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_3", RU07R0803_GetTabValueForKeyOrder("RA1", RA4->RA4_CURSO, , "RA1->RA1_DESC")})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_4", RU07R0803_GetTabValueForKeyOrder("RA0", RA4->RA4_ENTIDA, , "RA0->RA0_DESC")})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_5", " "})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_6", " "})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_7", " "})
            Aadd(aDataArray, {"doc_variable3_" + CValToChar(aDimensionTable[1]) + "_8", " "})
            RA4->(DbSkip())
        EndDo
    EndIf

    aAdd(aDataArray, {"count3_lines",   aDimensionTable[1]})
    aAdd(aDataArray, {"count3_column",  aDimensionTable[2]})

    RA4->(DbCloseArea())
    RA4->(RestArea(aRA4Area))
    RestArea(aArea)

    lReturn := .T.

Return lReturn

/*/
{Protheus.doc} RU07R0806_SetVacationList(aDataArray, aDimensionTable)
    The function set detail about curso into date array 

    @type Static Function
    @params aDataArray,      Array, Date array
    @params aDimensionTable, Array, Dimension array for writing table
    @author dchizhov
    @since 25.01.2023
    @version 12.1.23
    @return lReturn, Logical, Is success
    @example RU07R0806_SetVacationList(aDataArray, aDimensionTable)
/*/
Static Function RU07R0806_SetVacationList(aDataArray, aDimensionTable)

    Local aArea     As Array
    local lReturn   As Logical
    Local aSRHArea  As Array
    Local cCodeFol  As Array
    Local cNameType As Character

    cCodeFol := fGetCodFol(CODEFOL_FOR_VACATION, .F.)
    cNameType := RU07R0803_GetTabValueForKeyOrder("RCM", cCodeFol, "RCM_FILIAL+RCM_PD", "RCM_DESCRI", SRA->RA_FILIAL)

    aArea := GetArea()
    aSRHArea := SRH->(GetArea())

    DbSelectArea("SRH")
    SRH->(DbSetOrder(RetOrdem("SRH", "RH_FILIAL+RH_MAT")))

    If SRH->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !(SRH->(EOF())) .And. SRH->RH_FILIAL == SRA->RA_FILIAL .And. SRH->RH_MAT == SRA->RA_MAT
            aDimensionTable[1] += 1
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_1", cNameType})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_2", DToC(SRH->RH_DATABAS)})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_3", DToC(SRH->RH_DBASEAT)})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_4", SRH->RH_DFERIAS})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_5", DToC(SRH->RH_DATAINI)})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_6", DToC(SRH->RH_DATAFIM)})
            Aadd(aDataArray, {"doc_variable4_" + CValToChar(aDimensionTable[1]) + "_7", " "})
            SRH->(DbSkip())
        EndDo
    EndIf

    aAdd(aDataArray, {"count4_lines",   aDimensionTable[1]})
    aAdd(aDataArray, {"count4_column",  aDimensionTable[2]})

    SRH->(DbCloseArea())
    SRH->(RestArea(aSRHArea))
    RestArea(aArea)

    lReturn := .T.

Return lReturn

/*/
{Protheus.doc} RU07R0807_ReasonForDismissal()
    The function get reason for dismissal.

    @type Static Function
    @params 
    @author dchizhov
    @since 25.01.2023
    @version 12.1.23
    @return cReasonForDis, Character, Reason for dismissal
    @example aAdd(aDataArray, {"cEmpReasonDem",  RU07R0807_ReasonForDismissal()})
/*/
Static Function RU07R0807_ReasonForDismissal()

    Local cReasonForDis As Character
    Local aArea         As Array
    Local aSRGArea      As Array

    aArea := GetArea()
    aSRGArea := SRG->(GetArea())
    cReasonForDis := ""

    DbSelectArea("SRG")
    SRG->(DbSetOrder(RetOrdem("SRG", "RG_FILIAL+RG_MAT+DTOS(RG_DATADEM)")))

    If SRG->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !(SRG->(EOF())) .And. SRG->RG_FILIAL == SRA->RA_FILIAL .And. SRG->RG_MAT == SRA->RA_MAT

            If SRG->RG_DATADEM == SRA->RA_DEMISSA
                cReasonForDis := FDescRCC("S043", SRG->RG_TIPORES, 1, 2, 3, 30)
            EndIf

            SRG->(DbSkip())
        EndDo
    EndIf

    SRG->(DbCloseArea())
    SRG->(RestArea(aSRGArea))
    RestArea(aArea)

Return cReasonForDis

/*/
{Protheus.doc} RU07R0808_SetFamilyMember(aDataArray, aDimensionTable)
    The function set family member into date array 

    @type Static Function
    @params aDataArray,      Array, Date array
    @params aDimensionTable, Array, Dimension array for writing table
    @author dchizhov
    @since 30.01.2023
    @version 12.1.33
    @return lReturn, Logical, Is success
    @example RU07R0808_SetFamilyMember(aDataArray, aDimensionTable)
/*/
Static Function RU07R0808_SetFamilyMember(aDataArray, aDimensionTable)

    Local aArea     As Array
    local lReturn   As Logical
    Local aSRBArea  As Array

    If Len(AllTrim(SRA->RA_MAE)) > 0
        aDimensionTable[1] += 1
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_1", STR0016})
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_2", AllTrim(SRA->RA_MAE)})
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_3", " "})
    EndIf
    If Len(AllTrim(SRA->RA_PAI)) > 0
        aDimensionTable[1] += 1
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_1", STR0017})
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_2", AllTrim(SRA->RA_PAI)})
        aAdd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_3", " "})
    EndIf

    aArea := GetArea()
    aSRBArea := SRB->(GetArea())

    DbSelectArea("SRB")
    SRB->(DbSetOrder(RetOrdem("SRB", "RB_FILIAL+RB_MAT")))

    If SRB->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT))
        While !(SRB->(EOF())) .And. SRB->RB_FILIAL == SRA->RA_FILIAL .And. SRB->RB_MAT == SRA->RA_MAT
            aDimensionTable[1] += 1
            Aadd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_1", RU07XFUN25_GetComboSelected("RB_GRAUPAR", SRB->RB_GRAUPAR)})
            Aadd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_2", AllTrim(SRB->RB_NOME)})
            Aadd(aDataArray, {"doc_variable1_" + CValToChar(aDimensionTable[1]) + "_3", Year(SRB->RB_DTNASC)})
            SRB->(DbSkip())
        EndDo
    EndIf

    aAdd(aDataArray, {"count1_lines",   aDimensionTable[1]})
    aAdd(aDataArray, {"count1_column",  aDimensionTable[2]})

    SRB->(DbCloseArea())
    SRB->(RestArea(aSRBArea))
    RestArea(aArea)

    lReturn := .T.

Return lReturn

/*/
{Protheus.doc} RU07R0809_SetTransfEmployee(aDataArray, aDimensionTable, cPos, cSalario, dAdmissa)
    The function set transfer of employee into date array 

    @type Static Function
    @params aDataArray,      Array,     Date array
    @params aDimensionTable, Array,     Dimension array for writing table
    @params cPos,            Character, Current post
    @params nSalario,        Numeric,   Current salario
    @params dAdmissa,        Date,      RA_ADMISSA
    @author dchizhov
    @since 31.01.2023
    @version 12.1.33
    @return lReturn, Logical, Is success
    @example RU07R0809_SetTransfEmployee(aDataArray, aDimensionTable, aPositionInfo[1], Int(SRA->RA_SALARIO), SRA->RA_ADMISSA)
/*/
Static Function RU07R0809_SetTransfEmployee(aDataArray, aDimensionTable, cPos, nSalario, dAdmissa)

    Local aArea     As Array
    local lReturn   As Logical
    Local aTransf   As Array
    Local nX        As Numeric
    Local cDeptName As Character
    Local aHistory  As Array
    Local lNTranDep As Logical
    Local nIndex    As Numeric

    aArea := GetArea()

    lNTranDep := .T.
    nIndex := Len(aDataArray) - 4
    aTransf := {}
    fTransfAll(@aTransf)

    For nX = 1 To Len(aTransf)
        aDimensionTable[1] += 1
        cDeptName := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, aTransf[nX, 17]) // Get information about depto name.
        aHistory := RU07R0810_GetTransfTipoPosValor(aTransf[nX, 10], aTransf[nX, 11], aTransf[nX, 7], cPos, nSalario)
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_1", aTransf[nX, 7]})
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_2", cDeptName})
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_3", aHistory[1]})
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_4", aHistory[2]})
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_5", aHistory[3]})
        aAdd(aDataArray, {"doc_variable2_" + CValToChar(aDimensionTable[1]) + "_6", " "})

        If (lNTranDep .And. dAdmissa <= aTransf[nX, 7]) .Or. (dAdmissa == aTransf[nX, 7] .And. !Empty(dAdmissa))
            aDataArray[nIndex, 2] := StaticCall(RU07R06RUS, RU07R0603_GetDepartmentName, aTransf[nX, 16])
            lNTranDep := .F.
        EndIf
    Next nX

    aAdd(aDataArray, {"count2_lines",   aDimensionTable[1]})
    aAdd(aDataArray, {"count2_column",  aDimensionTable[2]})

    RestArea(aArea)

    lReturn := .T.

Return lReturn

/*/
{Protheus.doc} RU07R0810_GetTransfTipoPosValor(cFilEmp, cMatEmp, dDateT, cPos, nSalario, lStart)
    The function get post, valor and type of changes from hiztopry of paymant

    @type Static Function
    @params cFilEmp,  Character, Filial Employee
    @params cMatEmp,  Character, Tab number empoyee
    @params dDateT,   Date,      Date on which need information
    @params cPos,     Character, Current post
    @params nSalario, Numeric,   Current salario
    @params lStart,   Logical,   Starting salary
    @author dchizhov
    @since 01.02.2023
    @version 12.1.33
    @return aReturn, Array, Data array
    @example aHistory := RU07R0810_GetTransfTipoPosValor(aTransf[nX, 10], aTransf[nX, 11], aTransf[nX, 7], cPos, nSalario)
/*/
Static Function RU07R0810_GetTransfTipoPosValor(cFilEmp, cMatEmp, dDateT, cPos, nSalario, lStart)

    Local aArea     As Array
    Local aSR3Area  AS Array
    Local aSR7Area  AS Array
    local aReturn   As Array
    Local cCargo    As Character
    Local cTipo     As Character
    Local cValor    As Character
    Local lSR7More  As Logical

    Default lStart := .F.

    aArea := GetArea()
    aSR3Area := SR3->(GetArea())
    aSR7Area := SR7->(GetArea())
    aReturn := {" ", " ", " "}

    DbSelectArea("SR7")
    SR7->(DbSetOrder(RetOrdem("SR7", "R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ")))
    DbSelectArea("SR3")
    SR3->(DbSetOrder(RetOrdem("SR3", "R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_TIPO+R3_PD")))

    If SR7->(DbSeek(cFilEmp + cMatEmp))
        lSR7More := .F.
        If lStart
            SR7->(DbSeek(cFilEmp + cMatEmp + DToS(dDateT)))
        Else
            While !(SR7->(EOF())) .And. SR7->R7_FILIAL == cFilEmp .And. SR7->R7_MAT == cMatEmp .And. SR7->R7_DATA <= dDateT
                SR7->(DbSkip())
                lSR7More := .T.
            EndDo
            If lSR7More
                SR7->(DbSkip(-1))
            EndIf
        EndIf
        If SR7->(EOF()) .Or. SR7->R7_FILIAL <> cFilEmp .Or. SR7->R7_MAT <> cMatEmp
            cCargo := cPos
            cValor := AllTrim(CValToChar(nSalario))
            cTipo := " "
        Else
            cCargo := StaticCall(RU07R06RUS, RU07R0604_GetPositionName, SR7->R7_CARGO)[1]
            cTipo := R7DescTipInit()
            If SR3->(DbSeek(cFilEmp + cMatEmp + DToS(SR7->R7_DATA) + SR7->R7_TIPO))
                If SR7->R7_DATA > dDateT
                    cValor := AllTrim(CValToChar(Int(SR3->R3_ANTEAUM)))
                Else
                    cValor := AllTrim(CValToChar(Int(SR3->R3_VALOR)))
                EndIf
            Else
                cValor := " "
            EndIf
        EndIf

        aReturn[1] := cCargo
        aReturn[2] := cValor
        aReturn[3] := cTipo
    Else
        aReturn[1] := cPos
        aReturn[2] := AllTrim(CValToChar(nSalario))
        aReturn[3] := " "
    EndIf

    SR3->(DbCloseArea())
    SR7->(DbCloseArea())
    SR3->(RestArea(aSR3Area))
    SR7->(RestArea(aSR7Area))
    RestArea(aArea)

Return aReturn
