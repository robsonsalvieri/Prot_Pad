#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R03RUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "INKEY.CH"


#DEFINE PARAMETER_PERGUNTE "RU07R03PAR"
#DEFINE FILTER_PERGUNTE "RU7R03FIL1" // "RU07R03FIL" - this is old pergunte for filter.

#DEFINE PARAM_REPORT_YEAR_INDEX 4

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040

#DEFINE RA_SITFOLH_FIRED "D" // Terminated employee status (from SX5/31).

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"

Static cRA_MAT As Character

/*/
{Protheus.doc} RU07R03()
    Main function of Insurance premium report.
    Based on the RU07R03RUS routine.

    @type  Function
    @author vselyakov
    @since 2021/09/17
    @version 12.1.33
    @params
    @return
    @example RU07R03()
/*/
Function RU07R03()
    Local cFilter           As Array
    Local oReportButton     As Object
    Local oPergunteButton   As Object
    Local oExitButton       As Object
    Local bExitButton   := {|| oDlg:End()}
    Local bParamsButton := {|| Pergunte(PARAMETER_PERGUNTE, .T.)}
    Local bFilterButton := {|| cFilter := GetFilterData()}
    Local bReportButton := {|| MakeData(cFilter)}

    cRA_MAT := ""

    Pergunte(PARAMETER_PERGUNTE, .F.) // Load data from pergunte.

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

Return

/*/
{Protheus.doc} RU07R0301(cCode)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation, the function always returns .T. 

    @type Method
    @params cCod, Character, Employee personnel number.
    @author vselyakov
    @since 2021/09/17
    @version 12.1.33
    @return .T.
    @example RU07R0301()
             @#RU07R0301()
/*/
Function RU07R0301(cCode)
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    Default cCode := MV_PAR07

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
        MV_PAR08 := cFullName
    Else
        lResult := .F.
        // "Error", "No employee has been assigned to this position", "Indicate the position to which the employee is assigned".
        Help(,, STR0061,, STR0062, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0063})
        MV_PAR08 := ""
    EndIf

    RestArea(aArea)

Return .T.

/*/
{Protheus.doc} GetFilterData()
    Load pergunte for filter and create filter expression if user press "OK".

    @type Method
    @params lIsHideFilter, Logical, 
    @author vselyakov
    @since 02.12.2021
    @version 12.1.33
    @return cFilter, Character, Filter expression for report calculation.
    @example cFilter := GetFilterData()
/*/
Static Function GetFilterData(lIsHideFilter, cReportYear)
    Local cFilter As Character
    Local aSRANumbers As Array
    Local lCanContinue := .T. As Logical

    Default cReportYear := ""

    cFilter := ""
    aSRANumbers := {}

    // If user press button "OK" into pergunte.
    If lCanContinue .And. lIsHideFilter .Or. Pergunte(FILTER_PERGUNTE, .T., STR0002)
        // Filter for RA_FILIAL.
        cFilter += " (RA_FILIAL >= '" + FwxFilial("SRA") + "')" // Need using MV_PAR01 for client.
        cFilter += " AND (RA_FILIAL <= '" + FwxFilial("SRA") + "')" // Need using Iif(Empty(MV_PAR02), 'ZZZZZZ', MV_PAR02) for client.

        // Filter for RA_CC.
        cFilter += " AND (RA_CC >= '" + MV_PAR03 + "')"
        cFilter += " AND (RA_CC <= '" + Iif(Empty(MV_PAR04), 'ZZZZZZZZZ', MV_PAR04) + "')"

        // Filter for RA_SITFOLH. 2 - Not fired, 3 - fired.
        If (MV_PAR06 == 2)
            cFilter += " AND RA_SITFOLH != '" + RA_SITFOLH_FIRED + "'"
        ElseIf (MV_PAR06 == 3)
            cFilter += " AND RA_SITFOLH = '" + RA_SITFOLH_FIRED + "'"
        EndIf

        // Filter for RA_MAT. Commented lines - it is for olg filter pergunte.
        // cFilter += " AND (RA_MAT >= '" + MV_PAR05 + "')"
        // cFilter += " AND (RA_MAT <= '" + Iif(Empty(MV_PAR06), 'ZZZZZZ', MV_PAR06) + "')"
        // cFilter +=  " AND (RA_MAT <= '" + Iif(Empty(MV_PAR06), 'ZZZZZZ', MV_PAR06) + "')"
        If !Empty(MV_PAR05)
            MakeSqlExpr(FILTER_PERGUNTE) // Formation of parameters for an SQL query.
            cFilter += " AND " + MV_PAR05 // Add values for SQL-query selection.
        EndIf

        // We cut off employees who were dismissed in the previous year or hired next year.
        cFilter += " AND LEFT(RA_ADMISSA, 4) <= '" + cReportYear + "' "
        cFilter += " AND (LEFT(RA_DEMISSA, 4) >= '" + cReportYear + "' OR RA_DEMISSA = '') "
        cFilter += " AND D_E_L_E_T_ = ' ' "

    EndIf

Return cFilter
 
/*/
{Protheus.doc} GetParameterData()
    Load data for pergunte 'Parameters'.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/07
    @version 12.1.33
    @return aData, Array, Array of parameters data.
    @example aParameters := GetParameterData()
/*/
Static Function GetParameterData()
    Local aData As Array

    aData := {}

    Pergunte(PARAMETER_PERGUNTE, .F.) // Load data from pergunte.

    // Fill array aParameters from pergunte 'Parameters'.
    aAdd(aData, Alltrim(MV_PAR01)) // Reporting period code.
    aAdd(aData, Alltrim(MV_PAR02)) // Location code (accounting).
    aAdd(aData, MV_PAR03) // Payer rate code.
    aAdd(aData, Alltrim(MV_PAR04)) // Calendar year.
    aAdd(aData, Alltrim(MV_PAR05)) // Correction number.
    aAdd(aData, MV_PAR06) // Person Responsibility Category.
    aAdd(aData, Alltrim(MV_PAR07)) // Signature.
    aAdd(aData, Alltrim(MV_PAR08)) // Full name of the signatory.
    aAdd(aData, MV_PAR09) // Type of report (1=Log, 3=XML).

    aAdd(aData, AllTrim(MV_PAR10)) // Path to save.

    aAdd(aData, MV_PAR11) // Type of agent.
    aAdd(aData, AllTrim(MV_PAR12)) // Tax agent.

Return aData

/*/
{Protheus.doc} ValidParameters(aParams)
    Check parameters for report on filling.

    @type Method
    @params aParams, Array, Array of parameters for report.
    @author vselyakov
    @since 2021/0/20
    @version 12.1.33
    @return lValidation, Logical, Flag indicating that the parameters for generating the report are filled.
    @example ValidParameters(aParameters)
/*/
Static Function ValidParameters(aParams)
    Local lValidation As Logical

    lValidation := .T.

    // Required parameters.
    lValidation := lValidation .And. !Empty(aParams[1])
    lValidation := lValidation .And. !Empty(aParams[2])
    lValidation := lValidation .And. !Empty(aParams[3])
    lValidation := lValidation .And. !Empty(aParams[4])
    lValidation := lValidation .And. !Empty(aParams[7])
    lValidation := lValidation .And. !Empty(aParams[8])
    lValidation := lValidation .And. !Empty(aParams[12])

    // If generation in XML is selected, then the path for saving must be filled.
    If (aParams[9] == 2)
        lValidation := lValidation .And. !Empty(aParams[10])
    EndIf

Return lValidation

/*/
{Protheus.doc} MakeData(cFilterExpression)
    Assembly of pergunta and filter parameters for the report. 
    Starting the generation of the report.

    @type Method
    @params cFilterExpression, Character, Filter expression for report calculation.
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
    @return 
    @example MakeData(cFilter)
/*/
Static Function MakeData(cFilterExpression)
    Local aParameters As Array
    Local oRUInsurancePremiumReport As Object
    Local lValid      As Logical

    aParameters := GetParameterData()

    // Get filter data always.
    Pergunte(FILTER_PERGUNTE, .F.) // Load data from filter pergunte.
    cFilterExpression := GetFilterData(.T., aParameters[PARAM_REPORT_YEAR_INDEX])

    lValid := ValidParameters(aParameters)

    If lValid
        // Create class RUInsurancePremiumReportL.
        oRUInsurancePremiumReport := RUInsurancePremiumReport():New(aParameters, cFilterExpression)
        oRUInsurancePremiumReport:MakeData()

        Do Case 
            Case aParameters[9] == 1 // Log
                oRUInsurancePremiumReport:GetViewReport()
            Case aParameters[9] == 2 // XML
                oRUInsurancePremiumReport:GetXMLReport(aParameters[10])
        EndCase
        
    Else
        // "Parameter filling error", "Not all fields in the report parameters are filled", "Please fill in all the fields in the parameters and repeat the calculation".
        Help(,, STR0009,, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011})
    EndIf

Return 
