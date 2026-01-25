#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE PARAMETER_PERGUNTE "RU07R05PAR"
#DEFINE FILTER_PERGUNTE "RU7R05FIL1" // "RU07R05FIL" - this is old pergunte for filter.

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040
#DEFINE STR_TITLE_LEN 100
#DEFINE RA_SITFOLH_FIRED "D"

/*/
{Protheus.doc} RU07R05()
    Main function of routine FSS report. 

    @type  Function
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @params
    @return
    @example RU07R05()
/*/
Function RU07R05()

    Local cFilter           As Character
    Local oReportButton     As Object
    Local oPergunteButton   As Object
    Local oExitButton       As Object
    Local oFilterButton     As Object
    Local bExitButton   := {|| oDlg:End()}
    Local bParamsButton := {|| Pergunte(PARAMETER_PERGUNTE, .T.)}
    Local bFilterButton := {|| cFilter := GetFilterData()}
    Local bReportButton := {|| MsAguarde({|| MakeData(cFilter)}, STR0072, STR0073)}

    SetMVValue(FILTER_PERGUNTE, "MV_PAR01", FwXFilial("SRA"))
    SetMVValue(FILTER_PERGUNTE, "MV_PAR02", FwXFilial("SRA"))
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
        @oSize:GetDimension("CABECALHO", "LININI") + 20, oSize:GetDimension("CABECALHO", "COLINI") + 13 SAY STR0007 + CRLF + STR0008 + CRLF + STR0044 ;
            SIZE oSize:GetDimension("CABECALHO", "COLEND") * 0.49471, oSize:GetDimension("CABECALHO", "LINEND") * 0.35 Of oDlg Pixel // You can insert description of this routine.

        oFilterButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  15, STR0002, NIL, bFilterButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Filter".
        oPergunteButton := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412,  60, STR0003, NIL, bParamsButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Parameters".
        oReportButton   := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 105, STR0004, NIL, bReportButton, BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Report".
        oExitButton     := TButton():New(oSize:GetDimension("CABECALHO", "LINEND") * 0.412, 150, STR0005, NIL, bExitButton,   BUTTON_WIDTH, BUTTON_HEIGHT,,,, .T.) // "Exit".

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/
{Protheus.doc} GetFilterData()
    Load pergunte for filter and create filter expression if user press "OK".

    @type Static Function
    @params lIsHideFilter, Logical, Hide the window for user insert filter
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return cFilter, Character, Filter expression for report calculation.
    @example cFilter := GetFilterData(.F.)
/*/
Static Function GetFilterData(lIsHideFilter)

    Local cFilter    As Character
    Local cCurFilial As Character
    Local lSeeAll    As Logical

    lSeeAll := VerSenha(114) .And. VerSenha(115)

    DEFAULT lIsHideFilter := .F.

    cFilter := ""

    cCurFilial := FwXFilial("SRA")

    // If user press button "OK" into pergunte.
    If Pergunte(FILTER_PERGUNTE, !lIsHideFilter, STR0002) .Or. lIsHideFilter
        If !lSeeAll .And. (MV_PAR01 <> cCurFilial .Or. MV_PAR02 <> cCurFilial)
            MV_PAR01 := MV_PAR02 := cCurFilial
            MsgInfo(STR0143, STR0144)
            SetMVValue(FILTER_PERGUNTE, "MV_PAR01", cCurFilial)
            SetMVValue(FILTER_PERGUNTE, "MV_PAR02", cCurFilial)
        EndIf
        // Filter for RA_FILIAL.
        cFilter += " (RA_FILIAL >= '" + MV_PAR01 + "')"
        cFilter += " AND (RA_FILIAL <= '" + Iif(Empty(MV_PAR02), 'ZZZZZZ', MV_PAR02) + "')"

        // Filter for RA_CC.
        cFilter += " AND (RA_CC >= '" + MV_PAR03 + "')"
        cFilter += " AND (RA_CC <= '" + Iif(Empty(MV_PAR04), 'ZZZZZZZZZ', MV_PAR04) + "')"

        // Filter for RA_MAT.
        // old version:
        // cFilter += " AND (RA_MAT >= '" + MV_PAR05 + "')"
        // cFilter += " AND (RA_MAT <= '" + Iif(Empty(MV_PAR06), 'ZZZZZZ', MV_PAR06) + "')"
        // new version:
        If !Empty(MV_PAR05)
            MakeSqlExpr(FILTER_PERGUNTE) // Formation of parameters for an SQL query.
            cFilter += " AND " + MV_PAR05 // Add values for SQL-query selection.
        EndIf

        // Filter for RA_SITFOLH. 2 - Not fired, 3 - fired.
        If (MV_PAR06 == 2)
            cFilter += " AND RA_SITFOLH != '" + RA_SITFOLH_FIRED + "'"
        ElseIf (MV_PAR06 == 3)
            cFilter += " AND RA_SITFOLH = '" + RA_SITFOLH_FIRED + "'"
        EndIf

    EndIf

    If !lSeeAll
        SetMVValue(FILTER_PERGUNTE, "MV_PAR01", cCurFilial)
        SetMVValue(FILTER_PERGUNTE, "MV_PAR02", cCurFilial)
    EndIf

Return cFilter

/*/
{Protheus.doc} GetParameterData()
    Load data for pergunte 'Parameters'.

    @type Static Function
    @params 
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return aData, Array, Array of parameters data.
    @example aParameters := GetParameterData()
/*/
Static Function GetParameterData()
    Local aData As Array

    aData := {}

    Pergunte(PARAMETER_PERGUNTE, .F.) // Load data from pergunte.

    // Fill array aParameters from pergunte 'Parameters'.
    aAdd(aData, Alltrim(MV_PAR01)) // Reporting period code
    aAdd(aData, Alltrim(MV_PAR02)) // Location code (accounting)
    aAdd(aData, Alltrim(MV_PAR03)) // Payer rate code
    aAdd(aData, Alltrim(MV_PAR04)) // Calendar year
    aAdd(aData, Alltrim(MV_PAR05)) // Correction number
    aAdd(aData, MV_PAR06) // Person Responsibility Category
    aAdd(aData, Alltrim(MV_PAR07)) // Signature
    aAdd(aData, Alltrim(MV_PAR08)) // Full name of the signatory
    aAdd(aData, MV_PAR09) // Type of report (1=Log, 2=XML);

    aAdd(aData, AllTrim(MV_PAR10)) // Path to save
    aAdd(aData, MV_PAR11) // Agent type
    aAdd(aData, Alltrim(MV_PAR12)) // Tax agent

Return aData

/*/
{Protheus.doc} MakeData(cFilterExpression)
    Assembly of pergunta and filter parameters for the report. 
    Starting the generation of the FSS report.

    @type Static Function
    @params cFilterExpression, Character, Filter expression for report calculation.
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return lResult, Logical, The report generation has been successfully completed.
    @example MakeData(cFilter)
/*/
Static Function MakeData(cFilterExpression)

    Local aParameters    As Array
    Local oRuSIF         As Object
    Local lValid         As Logical
    Local lResult := .T. As Logical
    Local cStrParamVal   As Character

    aParameters := GetParameterData()

    // Get filter data always.
    cFilterExpression := GetFilterData(.T.)

    lValid := ValidParameters(aParameters, @cStrParamVal)

    If lValid
        // Create class RUSocialInsuranceFund.
        oRuSIF := RUSocialInsuranceFund():New(aParameters, cFilterExpression)
        MsProcTxt(STR0074)
        lResult := oRuSIF:MakeData()

        If lResult
            Do Case 
                Case aParameters[9] == 1 // Log
                    MsProcTxt(STR0075)
                    lResult := oRuSIF:GetViewReport()
                Case aParameters[9] == 2 // XML
                    lResult := oRuSIF:GetXMLReport(aParameters[12])
            EndCase
        EndIf
    Else
        cStrParamVal := STR0014 + cStrParamVal + STR0015
        // "Parameter filling error", "Please fill in all the fields in the parameters and repeat the calculation".
        Help(,, STR0016,, cStrParamVal, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0017})
    EndIf
    MsProcTxt(STR0076)

Return lResult

/*/
{Protheus.doc} RU07R0501(cCod)
    Prescribes in the 8th parameter the full name of the employee selected in the 7th parameter

    @type Function
    @params cCod, Character, Employee personnel number.
    @author dchizhov
    @since 2022/09/29
    @version 12.1.33
    @return lResult, Logical, Is the employee found in the directory
    @example RU07R0501()
/*/
Function RU07R0501(cCod)
    
    Local aArea := GetArea()
    Local aSRAArea := SRA->(GetArea())
    Local lResult := .F.

    Default cCod := MV_PAR07

    DbSelectArea("SRA")
    SRA->(DbSetOrder(RetOrder("SRA", "RA_FILIAL+RA_CARGO")))

    If SRA->(DbSeek(xFilial("SRA") + cCod))
        lResult := .T.
        MV_PAR08 := SRA->RA_NOMECMP
    Else
        lResult := .F.
        Help(,, STR0009,, STR0010, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0011} )
        MV_PAR08 := ""
    EndIf

    RestArea(aArea)
    SRA->(RestArea(aSRAArea))

Return lResult

/*/
{Protheus.doc} ValidParameters(aParams)
    Check parameters for report on filling.

    @type Method
    @params aParams, Array, Array of parameters for report.
    @params cString, Character, String with numbers of empty parameters.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return lValidation, Logical, Flag indicating that the parameters for generating the report are filled.
    @example ValidParameters(aParameters)
/*/
Static Function ValidParameters(aParams, cString)

    Local lValidation As Logical

    Default cString := ""

    lValidation := .T.
    cString := ""

    // Required parameters.
    cString += Iif(Empty(aParams[1]), " 1,", "")
    cString += Iif(Empty(aParams[2]), " 2,", "")
    cString += Iif(Empty(aParams[3]), " 3,", "")
    cString += Iif(Empty(aParams[4]), " 4,", "")
    cString += Iif(Empty(aParams[5]), " 5,", "")
    cString += Iif(Empty(aParams[7]), " 7,", "")
    cString += Iif(Empty(aParams[8]), " 8,", "")

    // If generation in XML is selected, then the path for saving must be filled.
    If (aParams[9] == 2)
        cString += Iif(Empty(aParams[10]), " 10,", "")
    EndIf

    lValidation := Empty(cString)

    If !lValidation
        cString := SubStr(cString, 1, Len(cString) - 1) + " "
    EndIf

Return lValidation

/*/
{Protheus.doc} RU07R0502_MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal)
    Changes the format of the cValue value for the report.

    @type Function
    @params cValue,         Character, Calculated value.
    @params nMaxLenWhole,   Numeric,   Number of values of integer part.
    @params nMaxLenDecimal, Numeric,   Number of values of decimal part.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return cResult, Character, Value into report format.
    @example RU07R0502_MakeDataForReport(oHeader:cINN, MAX_LEN_INN)
             RU07R0502_MakeDataForReport(Str(aPart2[nI]:nIncomeAmountTotal), 15, 2)
/*/
Function RU07R0502_MakeDataForReport(cValue, nMaxLenWhole, nMaxLenDecimal)
    Local cResult As Character
    Local cTempVar As Character
    Local nDecimalPosition As Numeric
    Local cIntPart As Character
    Local cFractPart As Character
    Local nLenDecimal As Numeric

    Default nMaxLenDecimal := 0

    cTempVar := AllTrim(cValue)
    If nMaxLenDecimal > 0
        nLenDecimal := nMaxLenDecimal + 1
        nDecimalPosition := At(".", cTempVar)

        If nDecimalPosition > 0
            cIntPart := SubStr(cTempVar, 1, nDecimalPosition - 1)
            cFractPart := SubStr(cTempVar, nDecimalPosition, Len(cTempVar) - Len(cIntPart))
        Else
            cIntPart := cTempVar
            cFractPart := "."
        EndIf

        cFractPart := PadR(cFractPart, nLenDecimal, "0")

        If Len(cIntPart) + Len(cFractPart) < nMaxLenWhole
            cResult := PadR(cIntPart, nMaxLenWhole - nLenDecimal, "-") + cFractPart
        Else
            cResult := cIntPart + cFractPart
        EndIf
    ElseIf Len(cTempVar) < nMaxLenWhole
        cResult := PadR(cTempVar, nMaxLenWhole, "-")
    Else
        cResult := cTempVar
    EndIf

Return cResult

/*/
{Protheus.doc} RU07R0503_GetColumnFromTableByNrec(cNameAlias, aColumn, aColumnName, nRec)
    Get data from table by R_E_C_N_O_.

    @type Function
    @params cNameAlias,  Character, Alias of Table.
    @params aColumnName, Array,     Columns to get.
    @params nRec,        Numeric,   R_E_C_N_O_.
    @author dchizhov
    @since 2022/11/25
    @version 12.1.33
    @return aResult, Array, Value into report format.
    @example aValue := RU07R0503_GetColumnFromTableByNrec(cNameAlias, aColumn, aColumnName, nRecNo)
/*/
Function RU07R0503_GetColumnFromTableByNrec(cNameAlias, aColumnName, nRec)

    Local aReturn As Array
    Local aArea   As Array
    Local aTabArea As Array

    aReturn := { }

    If Len(aColumnName) > 0

        aArea := GetArea()
        aTabArea := (cNameAlias)->(GetArea())

        (cNameAlias)->(DbGoTo(nRec))

        If !((cNameAlias)->(EOF()))
            AEval(aColumnName, {|X| AAdd(aReturn, (cNameAlias)->(&(X)))} )
        EndIf

        (cNameAlias)->(RestArea(aTabArea))
        RestArea(aArea)
    EndIf

Return aReturn

/*/
{Protheus.doc} RU07R0504_BuildSample(cText, cStyle)
    Function for create sample json for report.

    @type Function
    @params cText,  Character, Text.
    @params cStyle, Character, Style.
    @author dchizhov
    @since 2022/11/28
    @version 12.1.33
    @return oJson, Object, Json with data.
    @example AAdd(oTable, RU07R0504_BuildSample(cText, cStyle))
/*/
Function RU07R0504_BuildSample(cText, cStyle)

    Local oJson As Object

    Default cStyle := "normal"
    
    oJson := JsonObject():New()

    oJson["text"] := cText
    oJson["style"] := cStyle

Return oJson
