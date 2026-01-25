#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R02RUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "INKEY.CH"


#Define PARAMETER_PERGUNTE "RU07R02PAR"
#Define FILTER_PERGUNTE "RU07R02FIL"

#Define BUTTON_HEIGHT 012
#Define BUTTON_WIDTH 040

#Define RA_SITFOLH_FIRED "D" // Terminated employee status (from SX5/31).

Static cRA_MAT As Character

/*/
{Protheus.doc} RU07R02()
    Main function of routine 6-NDFL report. 
    Based on the GPEM060 routine.

    @type  Function
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @params
    @return
    @example RU07R02()
/*/
Function RU07R02()
    Local cFilter           As Array
    Local oReportButton     As Object
    Local oPergunteButton   As Object
    Local oExitButton       As Object
    Local bExitButton   := {|| oDlg:End()}
    Local bParamsButton := {|| Pergunte(PARAMETER_PERGUNTE, .T.)}
    Local bFilterButton := {|| cFilter := GetFilterData()}
    Local bReportButton := {|| MakeData(cFilter)}

    Local cCurFilial As Character
    Local lSeeAll    As Logical

    lSeeAll := VerSenha(114) .And. VerSenha(115)
    cCurFilial := FwXFilial("SRA")

    If !lSeeAll
        SetMVValue(FILTER_PERGUNTE, "MV_PAR01", cCurFilial)
        SetMVValue(FILTER_PERGUNTE, "MV_PAR02", cCurFilial)
    EndIf

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
{Protheus.doc} RU07R0201(cCode)
    Forms the full name of the signatory person.
    Since the function is used in pergunt (SX1) in validation, the function always returns .T. 

    @type Method
    @params cCod, Character, Employee personnel number.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return .T.
    @example RU07R0201()
             @#RU07R0201()
/*/
Function RU07R0201(cCode)
    Local cFullName  As Character
    Local oStatement As Object
    Local aArea      As Array
    Local cTab       As Character
    Local lResult    As Logical

    Default cCode := MV_PAR04

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
        MV_PAR05 := cFullName
    Else
        lResult := .F.
        Help(,, STR0080,, STR0078, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0079} )
        MV_PAR05 := ""
    EndIf

    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} RU07R0202_Filter()
    Make filter expression for standart query 'SYSCOM'.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return cFilter, Character, Filter expression for standart query 'SYSCOM'.
    @example RU07R0202_Filter()
             @#RU07R0202_Filter()
/*/
Function RU07R0202_Filter()
    Local cFilter As Character

    cFilter := "@#XX8_TIPO = '" + AllTrim(Str(MV_PAR06)) + "'@#"

Return cFilter

/*/
{Protheus.doc} GetFilterData()
    Load pergunte for filter and create filter expression if user press "OK".

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/07
    @version 12.1.23
    @return cFilter, Character, Filter expression for report calculation.
    @example cFilter := GetFilterData()
/*/
Static Function GetFilterData(lIsHideFilter)
    Local cFilter As Character
    Local cCurFilial As Character
    Local lSeeAll    As Logical

    lSeeAll := VerSenha(114) .And. VerSenha(115)
    cCurFilial := FwXFilial("SRA")

    MakeSqlExpr(FILTER_PERGUNTE)

    If !lSeeAll .And. (MV_PAR01 <> cCurFilial .Or. MV_PAR02 <> cCurFilial)
        MV_PAR01 := MV_PAR02 := cCurFilial
        MsgInfo(STR0087, STR0088)
        SetMVValue(FILTER_PERGUNTE, "MV_PAR01", cCurFilial)
        SetMVValue(FILTER_PERGUNTE, "MV_PAR02", cCurFilial)
    EndIf

    cFilter := ""

    // If user press button "OK" into pergunte.
    If lIsHideFilter .Or. Pergunte(FILTER_PERGUNTE, .T., STR0002)
        // Filter for RA_FILIAL.
        cFilter += " (RA_FILIAL >= '" + MV_PAR01 + "')"
        cFilter += " AND (RA_FILIAL <= '" +  MV_PAR02 + "')"//AND (RA_FILIAL <= '" + Iif(Empty(MV_PAR02), 'ZZZZZZ', MV_PAR02) + "')"

        // Filter for RA_CC.
        cFilter += " AND (RA_CC >= '" + MV_PAR03 + "')"
        cFilter += " AND (RA_CC <= '" + Iif(Empty(MV_PAR04), 'ZZZZZZZZZ', MV_PAR04) + "')"

        // Filter for RA_MAT.
        cFilter += " AND (RA_MAT >= '" + MV_PAR05 + "')"
        cFilter += " AND (RA_MAT <= '" + Iif(Empty(MV_PAR06), 'ZZZZZZ', MV_PAR06) + "')"

        // Filter for RA_SITFOLH. 2 - Not fired, 3 - fired.
        If (MV_PAR07 == 2)
            cFilter += " AND RA_SITFOLH != '" + RA_SITFOLH_FIRED + "'"
        ElseIf (MV_PAR07 == 3)
            cFilter += " AND RA_SITFOLH = '" + RA_SITFOLH_FIRED + "'"
        EndIf

    EndIf

Return cFilter

/*/
{Protheus.doc} GetParameterData()
    Load data for pergunte 'Parameters'.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/07
    @version 12.1.23
    @return aData, Array, Array of parameters data.
    @example aParameters := GetParameterData()
/*/
Static Function GetParameterData()
    Local aData As Array

    aData := {}

    Pergunte(PARAMETER_PERGUNTE, .F.) // Load data from pergunte.

    // Fill array aParameters from pergunte 'Parameters'.
    aAdd(aData, Alltrim(MV_PAR01))
    aAdd(aData, Alltrim(MV_PAR02))
    aAdd(aData, MV_PAR03) // Responsible person category.
    aAdd(aData, Alltrim(MV_PAR04))
    aAdd(aData, Alltrim(MV_PAR05))
    aAdd(aData, MV_PAR06)
    aAdd(aData, Alltrim(MV_PAR07))
    aAdd(aData, Alltrim(MV_PAR08))
    aAdd(aData, Alltrim(MV_PAR09))

    aAdd(aData, MV_PAR10) // Type of report (1=Log, 2=Word, 3=XML);
    aAdd(aData, Alltrim(MV_PAR11)) // Path to template ".dot" (only for Word type).
    aAdd(aData, Alltrim(MV_PAR12)) // Path to save report.

    aAdd(aData, Alltrim(MV_PAR13)) // Agent Representative Company.

    aAdd(aData, cRA_MAT) // THIS PARAM 14. THIS IS MAGIC RUSSO DICHAO!!!

Return aData

/*/
{Protheus.doc} ValidParameters(aParams)
    Check parameters for report on filling.

    @type Method
    @params aParams, Array, Array of parameters for report.
    @author vselyakov
    @since 2021/07/07
    @version 12.1.23
    @return lValidation, Logical, Flag indicating that the parameters for generating the report are filled.
    @example ValidParameters(aParameters)
/*/
Static Function ValidParameters(aParams)
    Local lValidation As Logical
    Local nI          As Numeric

    lValidation := .T.

    // Why from 8 only? Because the number of parameters that must be filled in is 8.
    For nI := 1 To 8
        lValidation := lValidation .And. !Empty(aParams[nI])
    Next nI

Return lValidation

/*/
{Protheus.doc} MakeData(cFilterExpression)
    Assembly of pergunta and filter parameters for the report. 
    Starting the generation of the 6-NDFL report.

    @type Method
    @params cFilterExpression, Character, Filter expression for report calculation.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example MakeData(cFilter)
/*/
Static Function MakeData(cFilterExpression)
    Local aParameters As Array
    Local oRu6Ndfl    As Object
    Local lValid      As Logical
    Local lResult     As Logical

    lResult := .T.
    aParameters := GetParameterData()

    // Get filter data always.
    Pergunte(FILTER_PERGUNTE, .F.) // Load data from pergunte.
    cFilterExpression := GetFilterData(.T.)

    lValid := ValidParameters(aParameters)

    If lValid
        // Create class 6NDFL.
        oRu6Ndfl := RU6NDFL():New(aParameters, cFilterExpression)
        oRu6Ndfl:MakeData()

        Do Case 
            Case aParameters[10] == 1 // Log
                oRu6Ndfl:GetViewReport()
            Case aParameters[10] == 2 // XML
                oRu6Ndfl:GetXMLReport(aParameters[12])
        EndCase
        
    Else
        lResult := .F.
        Help(,,STR0030,, STR0031, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0032} )
    EndIf

Return lResult
