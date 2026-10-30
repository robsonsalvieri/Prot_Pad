#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R18RUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "INKEY.CH"

// Define pergunte names for program.
#Define FILTER_PERGUNTE    "RU07R18FLT" // Filter.
#Define PARAMETER_PERGUNTE "RU07R18PAR" // Parameters.
#Define AGENT_FILIAL 1 // Agent type = "Filial".
#Define AGENT_BUISNESS_UNIT 2 // Agent type = "Buisness unit".
#Define AGENT_COMPANY 3 // Agent type = "Company".
#Define AGENT_COMPANY_GROUP 4 // Agent type = "Company group".

// Define window dialog and buttons parameters.
#Define BUTTON_HEIGHT 012
#Define BUTTON_WIDTH 040

// Default parameters for report.
#Define DEFAULT_REPORT_YEAR "2023" // Because this report new for 2023 year.
#Define DEFAULT_CORRECTION_NUMBER "000"
#Define REPORT_YEAR_INDEX 4 // Index of report year from parameters.

// Define perameters for defenition filter and parameters of report.
#Define SEPARATOR_ARRAY_VALUES_SYMBOL ";"

// Defenition STATIC variables.
Static cRA_MAT As Character
Static lParamOpen As Logical

/*/
{Protheus.doc} RU07R18RUS()
    Main function of Insurance premium report 2023.
    JIRA task: RULOC-5389.

    @type Main Function
    @author vselyakov
    @since 18.08.2023
    @version 12.1.33
    @params
    @return
    @example RU07R18RUS()
/*/
Function RU07R18RUS()
    // Local cFilter := "" As Character
    Local aParams := {} As Array
    Local lShowParams := .T. As Logical
    Local oReportButton As Object
    Local oPergunteButton As Object
    Local oExitButton As Object
    Local bExitButton   := {|| oDlg:End()}
    Local bParamsButton := {|| aParams := GetParamsData(lShowParams)}
    Local bFilterButton := {|| Pergunte(FILTER_PERGUNTE, lShowParams, STR0002)} // cFilter := GetFilterData(lShowParams)
    Local bReportButton := {|| MakeData()}

    cRA_MAT := ""
    lParamOpen := .F.

    // Assemble the Dimensions of Objects.
    oSize := FwDefSize():New(.F.)
    oSize:AddObject("CABECALHO", (oSize:aWindSize[3] * 1.1), (oSize:aWindSize[3] * 0.4), .F., .F.) // Not scalable.
    oSize:aMargins := {0, 0, 0, 0} // Space beside 0 objects, among them 3.
    oSize:lProp := .F. // Proportional.
    oSize:Process() // Trigger the calculations.

    DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
    DEFINE MSDIALOG oDlg TITLE STR0001 From 0,0 TO (oSize:aWindSize[3] * 0.4), (oSize:aWindSize[3] * 1.1) OF oMainWnd PIXEL

        @oSize:GetDimension("CABECALHO", "LININI") + 3, oSize:GetDimension("CABECALHO","COLINI") + 3 GROUP oGroup To oSize:GetDimension("CABECALHO", "LINEND") * 0.49471, oSize:GetDimension("CABECALHO", "COLEND") * 0.5  LABEL STR0006 OF oDlg PIXEL
        oGroup:oFont:=oFont
        @oSize:GetDimension("CABECALHO", "LININI") + 20, oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY STR0007 + CRLF + STR0008 Of oDlg Pixel // You can insert description of this routine.

        bFilterButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  15, STR0002, NIL, bFilterButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Filter".
        oPergunteButton := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  60, STR0003, NIL, bParamsButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Parameters".
        oReportButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 105, STR0004, NIL, bReportButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Report".
        oExitButton     := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 150, STR0005, NIL, bExitButton,   BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Exit".

    ACTIVATE MSDIALOG oDlg CENTERED

    lParamOpen := Nil
    cRA_MAT := Nil

Return

/*/
{Protheus.doc} GetFilterData(lShowParams, cReportYear)
    Load pergunte for filter and create filter expression if user press "OK".

    @type Static Function
    @params lShowParams, Logical, Show window parameters or not.
            cReportYear, Character, Report year for filtering employers.
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return cFilter, Character, Filter expression for report calculation.
    @example cFilter := GetFilterData()
/*/
Static Function GetFilterData(lShowParams, cReportYear, aSelectFilials, lErrorFilter)
    Local cFilter := "" As Character
    Local nI := 0 As Numeric
    Local nBranchFromIndex := 0 As Numeric
    Local nBranchToIndex := 0 As Numeric
    Local aBranches := FWLoadSM0() As Array // All info about branches with access current user to filials.
    Local aFilials := {} As Array

    Default lShowParams := .F.
    Default cReportYear := DEFAULT_REPORT_YEAR
    Default aSelectFilials := {}
    Default lErrorFilter := .F.

    // If user press button "OK" into pergunte.
    If Pergunte(FILTER_PERGUNTE, lShowParams, STR0002) .Or. lShowParams == .F.
        MakeSqlExpr(FILTER_PERGUNTE) // Formation of parameters for an SQL query.

        // Filter for process code.
        If (!Empty(MV_PAR01))
            cFilter += MV_PAR01
        EndIf
        
        // Filter for RA_FILIAL.
        If !Empty(cFilter)
            cFilter += " AND "
        EndIf

        // Forming an array of branches for filtering.
        If !Empty(AllTrim(MV_PAR02)) .And. (!Empty(AllTrim(MV_PAR03)) .Or. Upper(AllTrim(MV_PAR03)) $ "ZZ")
            nBranchFromIndex := aScan(aBranches, {|x| x[2] == AllTrim(MV_PAR02)})
            nBranchToIndex := aScan(aBranches, {|x| x[2] == AllTrim(MV_PAR03)})

            If nBranchFromIndex > 0 .And. nBranchToIndex > 0
                For nI := nBranchFromIndex To nBranchToIndex
                    If aScan(aSelectFilials, {|x| x == aBranches[nI][2]})
                        aAdd(aFilials, aBranches[nI][2])
                    EndIf
                Next nI
            EndIf

            If Len(aFilials) < 1
                MsgStop(STR0151, STR0011)
                lErrorFilter := .T.
            EndIf
        Else
            For nI := 1 To Len(aSelectFilials)
                aAdd(aFilials, aSelectFilials[nI])
            Next nI
        EndIf

        // Adding an array of branches to a filter row.
        cFilter += " RA_FILIAL IN ( "

        If Len(aFilials) > 0
            For nI := 1 To Len(aFilials)
                If nI != Len(aFilials)
                    cFilter += " '" + aFilials[nI] + "', "
                Else
                    cFilter += " '" + aFilials[nI] + "' "
                EndIf
            Next nI
        Else
            cFilter += " '' "
        EndIf
        
        cFilter += " ) "

        // Filter for RA_CC.
        cFilter += " AND (RA_CC >= '" + MV_PAR04 + "')"
        cFilter += " AND (RA_CC <= '" + Iif(Empty(MV_PAR05), 'ZZZZZZZZZ', MV_PAR05) + "')"

        // Filter for employee number.
        If !Empty(MV_PAR06)
            cFilter += " AND " + MV_PAR06 // Add values for SQL-query selection.
        EndIf

        // Cut off employees who were dismissed in the previous year or hired next year.
        cFilter += " AND LEFT(RA_ADMISSA, 4) <= '" + cReportYear + "' "
        cFilter += " AND (LEFT(RA_DEMISSA, 4) >= '" + cReportYear + "' OR RA_DEMISSA = '') "
        cFilter += " AND D_E_L_E_T_ = ' ' "

    EndIf

Return cFilter

/*/
{Protheus.doc} GetParamsData(lShowParams)
    Load pergunte for parameters and create create array if user press "OK".

    @type Static Function
    @params lShowParams, Logical, Show window parameters or not.
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return aParamsArray, Array, Parameters for report calculation.
    @example cFilter := GetFilterData()
/*/
Static Function GetParamsData(lShowParams)
    Local aParamsArray := {} As Array
    Local lValidParams := .F. As Logical

    Default lShowParams := .F.

    lParamOpen := .F. // Window with parameters not open yet.

    If Pergunte(PARAMETER_PERGUNTE, lShowParams, STR0003) .Or. lShowParams == .F.
        aAdd(aParamsArray, AllTrim(MV_PAR01)) // Code report period.
        aAdd(aParamsArray, AllTrim(MV_PAR02)) // Location code (accounting).
        aAdd(aParamsArray, AllTrim(MV_PAR03)) // Payer's tariff code.
        aAdd(aParamsArray, AllTrim(MV_PAR04)) // Calendar year.
        aAdd(aParamsArray, Iif(!Empty(AllTrim(MV_PAR05)), AllTrim(MV_PAR05), DEFAULT_CORRECTION_NUMBER)) // Correction number.
        aAdd(aParamsArray, MV_PAR06) // Type of agent.
        
        aAdd(aParamsArray, AllTrim(MV_PAR07))
        aAdd(aParamsArray, AllTrim(MV_PAR08))
        aAdd(aParamsArray, AllTrim(MV_PAR09))
        aAdd(aParamsArray, AllTrim(MV_PAR10))
        
        aAdd(aParamsArray, MV_PAR11) // Reorganization: Yes/No.
        aAdd(aParamsArray, MV_PAR12) // Responsible person category code.
        aAdd(aParamsArray, AllTrim(MV_PAR13)) // Signer.
        aAdd(aParamsArray, AllTrim(MV_PAR14)) // Signer name.
        aAdd(aParamsArray, MV_PAR15) // Type of report.

        lValidParams := ValidParameters(aParamsArray)

        While !lValidParams
            lShowParams := .T.
            If !Pergunte(PARAMETER_PERGUNTE, lShowParams, STR0003)
                lValidParams := .T. // If user pressed button "Cancel".
            Else
                lValidParams := ValidParameters(aParamsArray)
            EndIf
        EndDo

        lParamOpen := .F.
    EndIf

Return aParamsArray

/*/
{Protheus.doc} ValidParameters(aParams)
    Check parameters for report on filling.

    @type Method
    @params aParams, Array, Array of parameters for report.
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return lValidation, Logical, Flag indicating that the parameters for generating the report are filled.
    @example ValidParameters(aParameters)
/*/
Static Function ValidParameters(aParams)
    Local lIsValid := .T. As Logical
    Local aRequireFileds := {} As Array
    Local nI := 0 As Numeric
    Local cErrorMessage := (STR0018 + CRLF) As Character

    /*
        List of require parameters for make a report:
            * MV_PAR01 - Code report period.
            * MV_PAR02 - Location code (accounting).
            * MV_PAR03 - Payer's tariff code.
            * MV_PAR04 - Calendar year.
            * MV_PAR07 - Selected agent code. Now it is only filial code!
            * MV_PAR14 - Signer.
    */
    aRequireFileds := { ;
        {1,  STR0016}, ; // MV_PAR01
        {2,  STR0047}, ; // MV_PAR02
        {3,  STR0048}, ; // MV_PAR03
        {4,  STR0017}, ; // MV_PAR04
        {7,  STR0049}, ; // MV_PAR07
        {14, STR0050}  ; // MV_PAR14
    }

    // Required parameters.
    For nI := 1 To Len(aRequireFileds)
        If Empty(aParams[aRequireFileds[nI][1]])
            lIsValid := .F.
            cErrorMessage += aRequireFileds[nI][2] + CRLF
        EndIf
    Next nI
    
    If !lIsValid
        // "Parameter filling error", List of error parameters, "Please fill in all the fields in the parameters and repeat the calculation".
        Help(,, STR0009,, cErrorMessage, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
    EndIf

Return lIsValid

/*/
{Protheus.doc} MakeData()
    Assembly of pergunta and filter parameters for the report. 
    Starting the generation of the report.

    @type Static Function
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return 
    @example MakeData()
/*/
Static Function MakeData()
    Local cFilter := "" As Character
    Local aParameters := {} As Array
    Local lShowParams := .F. As Logical
    Local oRUInsurancePremiumReport := Nil As Object
    Local lValidParams := .T. As Logical
    Local aFilials := {}
    Local lErrorFilter := .F. As Logical

    aParameters := GetParamsData(lShowParams) // Get parameters data.
    aFilials := CollectFilials(aParameters[6], aParameters[7], aParameters[8], aParameters[9], aParameters[10]) // Collect filials with user access.
    cFilter := GetFilterData(lShowParams, aParameters[REPORT_YEAR_INDEX], aFilials, @lErrorFilter) // Get filter data.

    /*
        Filter may be empty. Check parameters array.
    */
    lValidParams := ValidParameters(aParameters)

    lParamOpen := .F.

    If lValidParams .And. !lErrorFilter
        // Create class RUInsurancePremiumReportL.
        oRUInsurancePremiumReport := RUInsurancePremiumReport2023():New(aParameters, cFilter)
        oRUInsurancePremiumReport:MakeData()

        Do Case 
            Case aParameters[15] == 1 // Log
                oRUInsurancePremiumReport:GetViewReport()
            Case aParameters[15] == 2 // XML
                oRUInsurancePremiumReport:GetXMLReport()
        EndCase
        
        FwFreeObj(oRUInsurancePremiumReport)
    Else
        // "Parameter filling error", "Not all fields in the report parameters are filled", "Please fill in all the fields in the parameters and repeat the calculation".
        Help(,, STR0009,, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
    EndIf

Return

/*/{Protheus.doc} CollectFilials
    Generates a list of branches available to the user depending on the specified agent type.

    @type function
    @version 12.1.33
    @author vselyakov
    @since 2023/09/25
    @param nAgentType, Numeric, Type of agent.
    @param cGroup, Character, Code of company group.
    @param cCompany, Character, Code of company.
    @param cBusinessUnit, Character, Code of buisness unit.
    @param cBranch, Character, Code of filial.
    @return Array, List of available branches
/*/
Static Function CollectFilials(nAgentType, cGroup, cCompany, cBusinessUnit, cBranch)
    Local aEnableFilials := {} As Array
    Local aBranches := FWLoadSM0() As Array // All info about branches with access current user to filials.
    Local nI := 0 As Numeric
    Local nFilAccessIndex := 11 As Numeric // SM0_USEROK, The user is allowed to use the Company/Filial.

    If MV_PAR06 == AGENT_FILIAL // Select "Filial".
        For nI := 1 To Len(aBranches)
            If aBranches[nI][1] == cGroup .And. aBranches[nI][3] == cCompany .And. aBranches[nI][4] == cBusinessUnit .And. aBranches[nI][5] == cBranch .And. aBranches[nI][nFilAccessIndex] == .T.
                aAdd(aEnableFilials, aBranches[nI][2])
            EndIf
        Next nI

        // Check count selected filials.
        If Len(aEnableFilials) < 1
            MsgStop(STR0144, STR0011)
            lRet := .F.
        EndIf

    ElseIf MV_PAR06 == AGENT_BUISNESS_UNIT // Select "Buisness unit".
        For nI := 1 To Len(aBranches)
            If aBranches[nI][1] == cGroup .And. aBranches[nI][3] == cCompany .And. aBranches[nI][4] == cBusinessUnit .And. aBranches[nI][nFilAccessIndex] == .T.
                aAdd(aEnableFilials, aBranches[nI][2])
            EndIf
        Next nI

        // Check count selected filials.
        If Len(aEnableFilials) < 1
            MsgStop(STR0144, STR0011)
            lRet := .F.
        EndIf

    ElseIf MV_PAR06 == AGENT_COMPANY_GROUP // Select "Company group".
        For nI := 1 To Len(aBranches)
            If aBranches[nI][1] == cGroup .And. aBranches[nI][nFilAccessIndex] == .T.
                aAdd(aEnableFilials, aBranches[nI][2])
            EndIf
        Next nI

        // Check count selected filials.
        If Len(aEnableFilials) < 1
            MsgStop(STR0144, STR0011)
            lRet := .F.
        EndIf
    ElseIf MV_PAR06 == AGENT_COMPANY // Select "Company".
        For nI := 1 To Len(aBranches)
            If aBranches[nI][1] == cGroup .And. aBranches[nI][3] == cCompany .And. aBranches[nI][nFilAccessIndex] == .T.
                aAdd(aEnableFilials, aBranches[nI][2])
            EndIf
        Next nI

        // Check count selected filials.
        If Len(aEnableFilials) < 1
            MsgStop(STR0144, STR0011)
            lRet := .F.
        EndIf
    EndIf


Return aEnableFilials

// ************************************************
// * Functions for validations                    * 
// ************************************************

/*/
{Protheus.doc} RU07R18001(cCode)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation, the function always returns .T. 

    @type Function
    @params cCod, Character, Employee personnel number.
    @author vselyakov
    @since 2021/09/17
    @version 12.1.33
    @return .T.
    @example RU07R0301()
             @#RU07R0301()
/*/
Function RU07R18001(cCode)
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    Default cCode := MV_PAR13

    cFullName := ""
    aArea := GetArea()

    If !Empty(cCode)
        oStatement := FWPreparedStatement():New(" SELECT RA_MAT, RA_NOMECMP FROM " + RetSQLName("SRA") + " WHERE RA_FILIAL = ? AND RA_CARGO = ? AND D_E_L_E_T_=' ' ")
        oStatement:SetString(1, xFilial("SRA"))
        oStatement:SetString(2, cCode)
        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        cFullName := (cTab)->RA_NOMECMP
        cRA_MAT := (cTab)->RA_MAT

        DBCloseArea()

        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    // Write result to pergunte.
    If !Empty(cFullName)
        lResult := .T.
        MV_PAR14 := cFullName
    Else
        lResult := .F.
        MV_PAR14 := ""
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0011,, STR0012, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0013})
    EndIf

    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} RU07R18002(cReportYear)
    Function of validation filed "Report year" for parameter pergunte.
    Year nedd equal or greater than 2023.

    @type Function
    @params cReportYear, Character, Report year.
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return lValidResult, Logical, Result of validation report year.
    @example "NaoVazio() .And. RU07R18002(MV_PAR04)"
/*/
Function RU07R18002(cReportYear)
    Local lValidResult := .F. As Logical
    
    Default cReportYear := DEFAULT_REPORT_YEAR

    If Empty(cReportYear)
        MsgStop(STR0046, STR0011) // "The field 'Calendar year' must be filled", "Error".
    Else
        If cReportYear >= DEFAULT_REPORT_YEAR
            lValidResult := .T.
        Else
            // "Error", "The year of the reporting period cannot be less than 2023", "Enter the year for which the report is being generated. The value must be at least 2023.".
            Help(,, STR0011,, STR0019, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0041})
        EndIf
    EndIf

Return lValidResult

/*/
{Protheus.doc} RU07R18003(cFilCode)
    Function to check user access to the selected branch.

    @type Function
    @params cReportYear, Character, Report year.
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return lValidResult, Logical, Result of validation report year.
    @example "RU07R18003(MV_PAR02)"
/*/
Function RU07R18003(cFilCode, lShowMsg)
    Local lIsAccess := .F. AS Logical
    // Local cUsrCode := RetCodUsr() As Character // User code from configurator.
    Local aBranches := FWLoadSM0() As Array // All info about branches with access current user to filials.
    Local nFilCodeIndex := 2 As Numeric // SM0_CODFIL, Branch code containing all levels (Company/Business Unit/Branch).
    Local nFilAccessIndex := 11 As Numeric // SM0_USEROK, The user is allowed to use the Company/Filial.
    Local nSelectFilialIndex := 0 As Numeric

    Default lShowMsg := .T.

    nSelectFilialIndex := aScan(aBranches, {|x| x[nFilCodeIndex] == AllTrim(cFilCode)})

    If !Empty(cFilCode) .And. !(At("Z", cFilCode) > 0) .And. nSelectFilialIndex > 0
        lIsAccess := aBranches[nSelectFilialIndex][nFilAccessIndex]
    ElseIf Empty(cFilCode) .Or. (At("Z", cFilCode) > 0)
        lIsAccess := .T.
    EndIf

    If !lIsAccess .And. lShowMsg
        MsgStop(STR0143, STR0011)
    EndIf


Return lIsAccess

/*/{Protheus.doc} RU07R18004
    Function for validation of field "Agent type".

    Based on function "F3XX8ADREMP()" from source "CRMA680RUS.prw".

    @type Function
    @param cReportYear, Character, Report year.
    @author vselyakov
    @since 2023/08/19
    @version 12.1.33
    @return Logical, Result of validation report year.
    @example "RU07R18004(MV_PAR06)"
/*/
Function RU07R18004(cMVParamCode)
    Local aArea	:= GetArea() As Array
    Local aXX8Area := XX8->(GetArea()) As Array
    Local aData := {} As Array // Array with the data.
    Local lRet := .T. As Logical // Return array of the selected option.
    Local oDlgF3 As Object // Window Object.
    Local oLbx As Object // Objeto List box.
    Local aRet := {} As Array
    Local cfilter := "1" As Character
    Local cFilCode := "" As Character
    Local aBranches := FWLoadSM0() As Array // All info about branches with access current user to filials.
    Local nI := 0 As Numeric
    Local nFilAccessIndex := 11 As Numeric // SM0_USEROK, The user is allowed to use the Company/Filial.
    Local lStructAccess := .F.

    /*
        When user pressed button "Parameters" even before opening the parameters window, 
        validation is triggered on the field. To disable the call at this point, a static variable "lParamOpen" is created.
        
        When the user clicks the "OK" button in the pergunt, the window closes and lParamOpen becomes false.
        This action is handled in the "GetParamsData" function.
    */
    If lParamOpen
        aEnableFilials := {}

        DbSelectArea("XX8")
        XX8->(dbSetOrder(1))
        XX8->(dbGoTop())

        If cMVParamCode == 4 
            cfilter := "0" // Group of company.
        ElseIf cMVParamCode == 2
            cfilter := "2" // Buisness unit.
        ElseIf cMVParamCode == 3
            cfilter := "1" // Company.
        ElseIf cMVParamCode == 1
            cfilter := "3" // Branch.
        EndIf

        // 
        While !XX8->(Eof())
        
            If XX8_TIPO == cfilter
                
                If cMVParamCode == 4
                    aAdd( aData, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
                ElseIf cMVParamCode == 2
                    aAdd( aData, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
                ElseIf cMVParamCode == 3
                    aAdd( aData, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_TIPO, XX8->XX8_DESCRI } )
                ElseIf cMVParamCode == 1
                    aAdd( aData, { XX8->XX8_GRPEMP, XX8->XX8_CODIGO, XX8->XX8_EMPR, XX8->XX8_UNID, XX8->XX8_DESCRI } )
                EndIf
            EndIf
            
            XX8->(DbSkip())
        
        EndDo

        If Len( aData ) > 0
            
            DEFINE MSDIALOG oDlgf3 TITLE STR0145 FROM 0,0 TO 240,500 PIXEL
            
            @ 10,10 LISTBOX oLbx FIELDS HEADER STR0146, STR0147, STR0148, STR0149, STR0150  SIZE 230,95 OF oDlgf3 PIXEL	
            
            oLbx:SetArray( aData )
            oLbx:bLine     := {|| {aData[oLbx:nAt,1], aData[oLbx:nAt,2], aData[oLbx:nAt,3], aData[oLbx:nAt,4], aData[oLbx:nAt,5]}}
            oLbx:bLDblClick := {|| {oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]}}} 	                   

            DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgF3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3],oLbx:aArray[oLbx:nAt,4],oLbx:aArray[oLbx:nAt,5]})  ENABLE OF oDlgF3
            ACTIVATE MSDIALOG oDlgF3 CENTER
                
        EndIf

        XX8->(RestArea(aXX8Area))
        RestArea(aArea)

        // Write result to field.
        If lRet .And. Len(aRet) > 0

            // Valiadation for filial.
            If MV_PAR06 == AGENT_FILIAL // Select "Filial".
                /*
                    aRet[1] - Group company.
                    aRet[2] - Filial.
                    aRet[3] - Company
                    aRet[4] - Buisness unit.
                */
                If aScan(aBranches, {|x| x[5] == AllTrim(aRet[2])}) > 0
                    cFilCode := aBranches[aScan(aBranches, {|x| x[5] == AllTrim(aRet[2])})][2] // Return full filial code.
                    lRet := RU07R18003(cFilCode)

                    If lRet
                        MV_PAR07 := AllTrim(aRet[1])
                        MV_PAR08 := AllTrim(aRet[3])
                        MV_PAR09 := AllTrim(aRet[4])
                        MV_PAR10 := AllTrim(aRet[2])
                    Else
                        MV_PAR07 := ""
                        MV_PAR08 := ""
                        MV_PAR09 := ""
                        MV_PAR10 := ""
                    EndIf
                Else
                    lRet := .F.
                EndIf
            ElseIf MV_PAR06 == AGENT_BUISNESS_UNIT // Select "Buisness unit".
                /*
                    aRet[1] - Group company.
                    aRet[2] - Buisness unit.
                    aRet[3] - Company.
                */
                For nI := 1 To Len(aBranches)
                    If aBranches[nI][1] == AllTrim(aRet[1]) .And. aBranches[nI][3] == AllTrim(aRet[3]) .And. aBranches[nI][4] == AllTrim(aRet[2]) .And. aBranches[nI][nFilAccessIndex] == .T.
                        lStructAccess := .T.
                    EndIf
                Next nI

                // Check count selected filials.
                If !lStructAccess
                    MsgStop(STR0144, STR0011)
                    lRet := .F.
                EndIf

                If lStructAccess
                    MV_PAR07 := AllTrim(aRet[1])
                    MV_PAR08 := AllTrim(aRet[3])
                    MV_PAR09 := AllTrim(aRet[2])
                Else
                    MV_PAR07 := " "
                    MV_PAR08 := " "
                    MV_PAR09 := " "
                EndIf
                MV_PAR10 := " "

            ElseIf MV_PAR06 == AGENT_COMPANY_GROUP // Select "Company group".
                /*
                    aRet[1] - Empty.
                    aRet[2] - Group company.
                */
                For nI := 1 To Len(aBranches)
                    If aBranches[nI][1] == AllTrim(aRet[2]) .And. aBranches[nI][nFilAccessIndex] == .T.
                        lStructAccess := .T.
                    EndIf
                Next nI

                If lStructAccess
                    MV_PAR07 := AllTrim(aRet[2])
                Else
                    MV_PAR07 := ""
                EndIf

                MV_PAR08 := ""
                MV_PAR09 := ""
                MV_PAR10 := ""
            
            ElseIf MV_PAR06 == AGENT_COMPANY // Select "Company".
                /*
                    aRet[1] - Group company.
                    aRet[2] - Company.
                */
                For nI := 1 To Len(aBranches)
                    If aBranches[nI][1] == AllTrim(aRet[1]) .And. aBranches[nI][3] == AllTrim(aRet[2]) .And. aBranches[nI][nFilAccessIndex] == .T.
                        lStructAccess := .T.
                    EndIf
                Next nI

                If lStructAccess
                    MV_PAR07 := AllTrim(aRet[1])
                    MV_PAR08 := AllTrim(aRet[2])
                Else
                    MV_PAR07 := ""
                    MV_PAR08 := ""
                    
                EndIf

                MV_PAR09 := ""
                MV_PAR10 := ""
            EndIf
        Else
            // "Error", "There are no registered structures for the selected agent type", "Select a different agent type".
            Help(,, STR0011,, STR0152, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0153})
            lRet := .F.
        EndIf

    Else
        lParamOpen := .T.
    EndIf

Return lRet

/*/{Protheus.doc} RU07R18005_ValidationCostCenter
    Function for validation of field "Cost Center".

    @type Function
    @param cCostCenter, Character, Cost Center.
    @author vselyakov
    @since 2023/10/10
    @version 12.1.33
    @return Logical, Result of validation.
    @example "RU07R18005(MV_PAR04)"
/*/
Function RU07R18005_ValidationCostCenter(cCostCenter)
    Local lValid := .F. As Logical
    Local cRusILower := Chr(255) + Chr(255) As Character // Russian letter ii.
    Local cRusIUpper := Chr(223) + Chr(223) As Character // Russian letter II.

    If Empty(cCostCenter) .Or. At(cRusILower, cCostCenter) > 0 .Or. At(cRusIUpper, cCostCenter) > 0 .Or. At("ZZ", cCostCenter) > 0 .Or. At("zz", cCostCenter) > 0
        lValid := .T.
    Else
        lValid := ExistCpo("CTT", cCostCenter)
    EndIf

Return lValid

/*/{Protheus.doc} RU07R18006_ValidationProcesCode
    Function for validation of field "Process Code".

    @type Function
    @param cProcCode, Character, Process Code like "00001;00002-00004;".
    @author vselyakov
    @since 2023/10/10
    @version 12.1.33
    @return Logical, Result of validation.
    @example "RU07R18006(MV_PAR01)"
/*/
Function RU07R18006_ValidationProcesCode(cProcCode)
    Local lValid := .F. As Logical
    Local aProcCodes := {} As Array
    Local nI := 0 As Numeric

    aProcCodes := StrToKArr(cProcCode, ";*-")

    If Empty(cProcCode)
        lValid := .T.
    Else
        For nI := 1 To Len(aProcCodes)
            If !Empty(aProcCodes[nI])
                lValid := ExistCpo("RCJ", aProcCodes[nI])
            EndIf
        Next nI
    EndIf

Return lValid

/*/{Protheus.doc} RU07R18007_ValidationEmployeeNumbers
    Function for validation of field "Personnel Numbers".

    @type Function
    @param cEmpNumbers, Character, Personnel Numbers like "000299;000300-000302;".
    @author vselyakov
    @since 2023/10/10
    @version 12.1.33
    @return Logical, Result of validation.
    @example "RU07R18007(MV_PAR06)"
/*/
Function RU07R18007_ValidationEmployeeNumbers(cEmpNumbers)
    Local lValid := .F. As Logical
    Local aEmpNumbers := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array

    aEmpNumbers := StrToKArr(cEmpNumbers, ";*-")

    If Empty(cEmpNumbers)
        lValid := .T.
    Else
        DbSelectArea("SRA")
        SRA->(DbSetOrder(RetOrdem("SRA", "RA_MAT")))

        For nI := 1 To Len(aEmpNumbers)
            If !Empty(aEmpNumbers[nI])
                SRA->(DbGoTop())
                lValid := SRA->(DbSeek(aEmpNumbers[nI]))

                If !lValid
                    Help("", 1, "A014REGNF")
                EndIf
            EndIf
        Next nI

        SRA->(DbCloseArea())
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lValid
