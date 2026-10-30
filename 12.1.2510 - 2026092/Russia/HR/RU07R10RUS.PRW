#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R10RUS.CH"

#DEFINE CODES_OF_PAYMENT_TYPE_VACATION "121"
#DEFINE CODES_OF_COMPANY "000001"




/*/{Protheus.doc} RU07R10RUS
    Main function of routine print form Employment contract
    @type  Function
    @author iprokhorenko
    @since 23/02/2023
    @version 12.1.33
    @param 
    @return 
    @example
        AAdd(aMenuDef, {STR0094, "RU07R09RUS", 0, 11})
    /*/

Function RU07R10RUS()
    Local oDialog As Object
    Local aInputParams As Array
    Local aDataList As Array
    Local lCreateReport As Logical
    Local cPrefixNameForFile As Character

    Local cTN  As Character
    Local cTN  As Character


    oDialog := RuHRWordPrintForm():New("RU07R10RUS") // Create instance of RuHRWordPrintForm
    oDialog:SetDlgTitle(STR0001) // Set title a window.

    // Actions on close dialog.
    If oDialog:GetParamDialog(, .F.) // User press "OK".

        aInputParams := oDialog:GetInputParameters() // Get user parameters from dialog.
        cPrefixNameForFile := STR0001

        // Make a data and print this into window MsAguarde.
        MsAguarde({|| ;
                      aDataList := RU07R1001_GetAllData(aInputParams[1], aInputParams[2], aInputParams[3], aInputParams[4], "", .F.), ;
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
{Protheus.doc} RU07R1001_GetAllData(cTemplatePath, cDocSavePath, cCodeEmloyee, cNameEmployee, aSRAlList)
    Make a array with data.
    An array of Ru Employee Print Form objects is formed with data for a printed form for employees.

    @type Static Function
    @params cTemplatePath, Character, Path to document with template of print form.
            cDocSavePath, Character, Path to save document of result print form.
            cCodeEmloyee, Character, Employee post code.
            cNameEmployee, Character, Full name of signature this print form.
            aSRAlList, Array, List of selected employee numbers.
            lGroupPrint, Logical, Is grouping printer or not.
    @author iprokhorenko
    @since 25.02.2023
    @version 12.1.23
    @return aDataArray, Array, Array of RuEmployeePrintForm objects.
    @example RU07R1001_GetAllData(cPatternPath, cResultPath, cNameEmployee, cSRAlList)
/*/
Static Function RU07R1001_GetAllData(cTemplatePath, cDocSavePath, cCodeSignature, cNameSignature, aSRAlList, lGroupPrint)//cCodeSignature, cNameSignature cCodeEmloyee, cNameEmployee
    Local aDataArray As Array
    Local aDatTemp As Array
    Local aSRAList As Array
    Local aArea As Array
    Local aSRAArea As Array
    Local aAGAArea As Array
    Local nI As Numeric
    Local oRuEmployeePrintForm As Object
    Local nOrder As Numeric
    Local cCodeEmloyee As Character
    Local cFullNameEmployee As Character

    Local cOrganzationName As Character
    Local cOrgionNameShort As Character
    Local cOKPOCode As Character
    Local aGetCoBrRusInfo As Array
    Local cDeptName As Character
    Local aPositionInfo As Array
    Local cConditions As Character
    Local cMonthName As Character
    Local nTrialPeriod As Numeric
    Local cSQL As Character
    Local cTabl As Character
    Local aParam As Array
    Local aField As Array
    Local cDatIn As Character
    Local aResult As Array
    Local aSignPos As Array
    Local aCData As Array
    Local cAddrKey As Character
    Local aTMP As Array 
    Local cTypeBranch As Character
    Local cINN As Character
    Local cKPP As Character
    Local cFilEmpl As Character
    Local nLenCCompany As Numeric
    Local nLenCUnit As Numeric
    
    Default lGroupPrint := .F.

    //aArea := GetArea()
    aTMP := {}
    aSRAList := {}
    cFullNameSignature := AllTrim(cNameSignature)
    aDataArray := {}
    aDatTemp := {}
    aParam := {}
    aField := {}

    cTypeBranch := FwBranAltInf({"BR_TYPE"}, cEmpAnt, SRA->RA_FILIAL)[1][2]
    
    cFullNameEmployee := AllTrim(SRA->RA_NOMECMP)
    cCodeEmloyee := AllTrim(SRA->RA_MAT)
    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    //cOrganzationName := Alltrim(aGetCoBrRusInfo[1][5][2])
    cOrgionNameShort := "(" + Alltrim(aGetCoBrRusInfo[1][6][2]) + ")"
    //cOKPOCode := Alltrim(aGetCoBrRusInfo[1][12][2])

    cOrganzationName := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][6][2]), Alltrim(aGetCoBrRusInfo[1][5][2]))
    cOKPOCode := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][12][2]), Alltrim(aGetCoBrRusInfo[1][12][2]))

    cINN := Alltrim(aGetCoBrRusInfo[1][13][2]) //Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][13][2]), Alltrim(aGetCoBrRusInfo[1][13][2])) 
    cKPP := Iif(cTypeBranch == "2", Alltrim(aGetCoBrRusInfo[2][5][2]), Alltrim(aGetCoBrRusInfo[1][14][2])) 

    cDatIn := DToC(SRA->RA_ADMISSA)

    // Get information about employee.
    cDeptName := RU07R1003_GetDepartmentName(SRA->RA_DEPTO) // Get information about depto name.
    aPositionInfo := RU07R1004_GetPositionName(SRA->RA_CARGO) // Get information about position.
    cMonthName := RU07R1006_GetMonthName(Month(SRA->RA_ADMISSA)) // Get month name by word. Example, 12 = December.

    nTrialPeriod := Round((SRA->RA_VCTOEXP - SRA->RA_ADMISSA + 1) / 30, 1)

    aAdd(aDatTemp, {"cNumDoc", DTOS(SRA->RA_ADMISSA) + "/" + SRA->RA_MAT})
    aAdd(aDatTemp, {"cOrgName", cOrganzationName})
    aAdd(aDatTemp, {"cONS", cOrgionNameShort})
    aAdd(aDatTemp, {"cINN", cINN})
    aAdd(aDatTemp, {"cKPP", cKPP})
    aAdd(aDatTemp, {"RA_NOMECMP", SRA->RA_NOMECMP})
    aAdd(aDatTemp, {"RA_NUMEPAS", SRA->RA_NUMEPAS})
    aAdd(aDatTemp, {"RA_DCARGO", aPositionInfo[1]})
    aAdd(aDatTemp, {"cEndStr1", IIF(SRA->RA_SEXO =="M", STR0004, STR0005)})
    
    aAdd(aDatTemp, {"RA_SALARIO", SRA->RA_SALARIO})
    aAdd(aDatTemp, {"RA_CATFUNC", IIF(SRA->RA_CATFUNC == 'M', STR0006, STR0007 )})
    aAdd(aDatTemp, {"cHorMonth", IIF(SRA->RA_CATFUNC == 'M', STR0008, STR0009 )})
    aAdd(aDatTemp, {"cTime", IIF(SRA->RA_CATFUNC == 'M', SRA->RA_HRSEMAN, SRA->RA_HRSDIA )})
    aAdd(aDatTemp, {"cTimeDes", IIF(SRA->RA_CATFUNC == 'M', STR0016, STR0017 )})
    aAdd(aDatTemp, {"RA_DEMIPAS", SRA->RA_DEMIPAS})
    aAdd(aDatTemp, {"cDayPas", Substr(DToC(SRA->RA_DEMIPAS), 1, 2)}) // 23 from day of 23.12.2022
    aAdd(aDatTemp, {"cMonthPas", RU07R1006_GetMonthName(Month(SRA->RA_DEMIPAS))}) // 12 from month of 23.12.2022
    aAdd(aDatTemp, {"cYearPas", Substr(DToC(SRA->RA_DEMIPAS), 7, 4)}) // 2022 from year of 23.12.2022
    aAdd(aDatTemp, {"RA_UFPAS", SRA->RA_UFPAS})
    aAdd(aDatTemp, {"RA_ENDEREC", SRA->RA_ENDEREC})
    aAdd(aDatTemp, {"cDay", Substr(DToC(SRA->RA_ADMISSA), 1, 2)}) // 23 from day of 23.12.2022
    aAdd(aDatTemp, {"cMonth", cMonthName}) // 12 from month of 23.12.2022
    aAdd(aDatTemp, {"cYear", Substr(DToC(SRA->RA_ADMISSA), 7, 4)}) // 2022 from year of 23.12.2022
    aAdd(aDatTemp, {"cPasSer", Substr(AllTrim(SRA->RA_NUMEPAS), 1, 4)})
    aAdd(aDatTemp, {"cPasNum", Substr(AllTrim(SRA->RA_NUMEPAS), 5, 6)})
    aAdd(aDatTemp, {"RA_EMISPAS", SRA->RA_EMISPAS})
    
    cSQL := " SELECT * FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' "
    xFilial("SRA")
    cTabl := "SRA"
    aParam := {xFilial("SRA"), AllTrim(cCodeSignature)}
    aField := {'RA_MAT','RA_SEXO','RA_CARGO', 'RA_NOME'}
    RU07R1009_SelectData(cTabl, cSQL, aParam, aField, @aTMP)

    aSignPos := RU07R1004_GetPositionName(AllTrim(cCodeSignature))
    
    aAdd(aDatTemp, {"cEndStr2", IIF(aTMP[2][2] =="M", STR0002, STR0003)})
    aAdd(aDatTemp, {"NameSig", AllTrim(cFullNameSignature)})
    aAdd(aDatTemp, {"PosSig", AllTrim(aSignPos[1])})

    aTMP := {}
    
    aCData := FwComAltInf({'CO_OKPO', 'CO_FULLNAM', 'CO_COMPGRP', 'CO_COMPEMP', 'CO_TIPO', 'CO_PHONENU', 'CO_COMPUNI'})

    If !Empty(AGETCOBRRUSINFO[3][1])
        cAddrKey := FwXFilial("AGA") + 'SM0' + AGETCOBRRUSINFO[3][1][4] + '0'
        
        aAGAArea := AGA->(GetArea())
        DbSelectArea("AGA")
        DbSetOrder(1) // AGA_FILIAL+AGA_ENTIDA+AGA_CODENT+AGA_TIPO
        DbGoTop()

        If !Empty(Posicione("AGA", 1, cAddrKey , "AGA_FULL"))
            aAdd(aDatTemp, {"AGA_FULL", AllTrim(AGA->AGA_FULL)})
            aAdd(aDatTemp, {"AGA_MUNDES", AllTrim(AGA_MUNDES)})
        EndIf

        RestArea(aAGAArea)
    else
        Help(,, STR0010,, STR0030 + 'AGA', 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031})
        aAdd(aDatTemp, {"AGA_FULL", ''})
        aAdd(aDatTemp, {"AGA_MUNDES", ''})
    EndIf

    cSQL := "SELECT * FROM " + RetSQLName("SA6") + " WHERE A6_FILIAL = ? AND D_E_L_E_T_=' ' ORDER BY A6_TYPEACC ASC " 
    cTabl := "SA6"
    aParam := {xFilial("SA6")}
    aField := {'A6_NUMCON', 'A6_NOME', 'A6_AGENCIA'}
    RU07R1009_SelectData(cTabl, cSQL, aParam, aField, @aDatTemp)

    cSQL := "SELECT * FROM " + RetSQLName("SRF") + " WHERE RF_MAT = ? AND RF_DATABAS =  ? AND D_E_L_E_T_=' '  "
    cTabl := "SRF"
    aParam := {AllTrim(cCodeEmloyee), cDatIn}
    aField := {'RF_DIASDIR'}
    RU07R1009_SelectData(cTabl, cSQL, aParam, aField, @aDatTemp)

    oRuEmployeePrintForm := RuEmployeePrintForm():New(AllTrim(cCodeEmloyee), cFullNameEmployee, aDatTemp)

    Aadd(aDataArray, oRuEmployeePrintForm)

    oRuEmployeePrintForm := Nil
    FreeObj(oRuEmployeePrintForm)

Return aDataArray






/*/
{Protheus.doc} RU07R1003_GetDepartmentName(cDepartmentCode) 
    Function return name of employee department.

    @type Static Function
    @params cDepartmentCode, Character, Employee department code.
    @author iprokhorenko
    @since 25.02.2023
    @version 12.1.33
    @return cNameDept, Character, Employee department name.
    @example cDeptName := RU07R1003_GetDepartmentName(SRA->RA_DEPTO)
/*/
Static Function RU07R1003_GetDepartmentName(cDepartmentCode)
    Local cNameDept As Character
    Local aArea     As Array
    Local aSQBArea  As Array

    aArea := GetArea()
    aSQBArea := SQB->(GetArea())
    cNameDept := ""

    DBSelectArea("SQB")
    DBSetOrder(1) // QB_FILIAL+QB_DEPTO+QB_DESCRIC.

    If SQB->(DBSeek(FwXFilial("SQB") + cDepartmentCode, .T.))
        cNameDept := AllTrim(SQB->QB_DESCRIC)
    EndIf

    RestArea(aSQBArea)
    RestArea(aArea)
Return cNameDept


/*/
{Protheus.doc} RU07R1004_GetPositionName(cDepartmentCode) 
    Function return information about employee position.

    @type Static Function
    @params cPositionCode, Character, Employee position code.
    @author iprokhorenko
    @since 25.02.2023
    @version 12.1.33
    @return aPositionInformation, Array, Information about employee position
    @example aPositionInfo := RU07R1004_GetPositionName(SRA->RA_CARGO)
/*/
Static Function RU07R1004_GetPositionName(cPositionCode)
    Local aPositionInformation As Character
    Local aArea                As Array
    Local aSQ3Area             As Array

    aArea := GetArea()
    aSQ3Area := SQ3->(GetArea())
    aPositionInformation := {}

    DBSelectArea("SQ3")
    DBSetOrder(1) // // Q3_FILIAL+Q3_CARGO+Q3_CC.

    If SQ3->(DBSeek(FwXFilial("SQ3") + cPositionCode, .T.))
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
{Protheus.doc} RU07R1006_GetMonthName(nMonthNumber)
    Function return name of month.

    @type Static Function
    @params nMonthNumber, Numeric, Month number.
    @author iprokhorenko
    @since 25.02.2023
    @version 12.1.33
    @return cMonthName, Character, Description month.
    @example cMonthName := RU07R1006_GetMonthName(Month(SRA->RA_ADMISSA))
/*/
Static Function RU07R1006_GetMonthName(nMonthNumber)
    Local cMonthName As Character

    Do Case
        Case nMonthNumber == 1
            cMonthName := STR0018
        Case nMonthNumber == 2
             cMonthName := STR0019
        Case nMonthNumber == 3
             cMonthName := STR0020
        Case nMonthNumber == 4
             cMonthName := STR0021
        Case nMonthNumber == 5
             cMonthName := STR0022
        Case nMonthNumber == 6
             cMonthName := STR0023
        Case nMonthNumber == 7
             cMonthName := STR0024
        Case nMonthNumber == 8
             cMonthName := STR0025
        Case nMonthNumber == 9
             cMonthName := STR0026
        Case nMonthNumber == 10
             cMonthName := STR0027
        Case nMonthNumber == 11
             cMonthName := STR0028
        Case nMonthNumber == 12
             cMonthName := STR0029
        Otherwise
            cMonthName := ""
    EndCase
    
Return cMonthName



/*/
{Protheus.doc} RU07R1009_SelectData(cTabl, cSQL, aParam, aField, aDataList)
    Filling array for group print from aDataFrom.

    @type Function
    @params aDataList, Array, Array for data reports.
    @params aField,    Array, Array field.
    @params aParam,    Array, Array with parametrs.
    @params cSQL,      Character, Number of Filling line.
    @params cTabl,     Character, Number of Filling line.
    @author dchizhov
    @since 12.01.2023
    @version 12.1.33
    @return lResult, Logical, Is a success.
    @example RU07R1009_SelectData(cTabl, cSQL, aParam, aField, aDataList)
/*/
Static Function RU07R1009_SelectData(cTabl, cSQL, aParam, aField, aDataList)
    
    Local oStatement As Object
    Local aArea      As Array
    Local nI as Numeric
    Local cTab       As Character
    Local lResult    As Logical

    cFullName := ""
    aArea := GetArea()

    oStatement := FWPreparedStatement():New(cSQL)
   
    For nI := 1 To Len(aParam)
        oStatement:SetString(nI, aParam[nI])
    Next nI

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
        
    For nI := 1 To Len(aField)
        if aField[nI] == 'AGA_FULL'
            aAdd(aDataList, {aField[nI], ""})
        else
            aAdd(aDataList, {aField[nI], &((cTab)->(aField[nI]))})
        endif
    Next nI
        
    lResult := .T.

    DBCloseArea()

    oStatement:Destroy()
    FwFreeObj(oStatement)
    
    RestArea(aArea)

Return lResult


/*/
{Protheus.doc} RU07R0602_GetFullNameOfSignature(cCode, cNameSignature)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation.

    @type Function
    @params cCod, Character, Employee personnel number.
            cNameSignature, Character, Result Full name of signer.
    @author iprokhorenko
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
    Local aDataSign  As Array

    aDataSign := {}
    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT,RA_SEXO,RA_CARGO, RA_NOME FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        
        Aadd(aDataSign, AllTrim((cTab)->RA_NOME))
        Aadd(aDataSign, AllTrim((cTab)->RA_SEXO)) 
        Aadd(aDataSign, AllTrim((cTab)->RA_CARGO))
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
        Help(,, STR0010,, STR0030 + "SRA", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0031})
        cNameSignature := ""
    EndIf

    RestArea(aArea)

Return aDataSign



/*/
{Protheus.doc} GetStructCode(cFilialCode)
    This Function returns a company code template.

    @type Function
    @params cFilialCode, Character, Filial code.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return cStructCodeF, Character, company code template.
    @example cStructCode := GetStructCode(cFilialCode)
/*/
Static Function GetStructCode(cFilialCode) 

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cGroup       As Character
    Local cStructCodeF As Character

    aArea := GetArea()
    cGroup := cEmpAnt
    cStructCodeF := ""

    cQuery := "SELECT M0_LEIAUTE AS STRUCTURE FROM SYS_COMPANY WHERE"
    cQuery += " M0_CODIGO = ? "
    cQuery += " AND M0_CODFIL = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cGroup)
    oStatement:SetString(2, cFilialCode)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    cStructCodeF := Alltrim((cTab)->STRUCTURE)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return cStructCodeF
