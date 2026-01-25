#INCLUDE "PROTHEUS.CH"

// Defenition of parameter indexes.
#Define CODE_REPORT_PERIOD_INDEX 1
#Define CODE_LOCATION_INDEX 2
#Define CODE_PAYER_TARIF_INDEX 3
#Define REPORT_YEAR_INDEX 4
#Define CORRECTION_NUMBER_INDEX 5
#Define AGENT_TYPE_INDEX 6
#Define PARAM_GROUP_COMPANY_INDEX 7
#Define PARAM_COMPANY_INDEX 8
#Define PARAM_BUISNESS_UNIT_INDEX 9
#Define PARAM_FILIAL_INDEX 10
#Define REORGANIZATION_INDEX 11
#Define TYPE_SIGNER_INDEX 12
#Define CODE_SIGNER_INDEX 13
#Define NAME_SIGNER_INDEX 14

// Defenition payer type.
#Define EXIST_PAYMENTS "1"
#Define NOT_EXIST_PAYMENTS "2"

// Defenitions Budget classification code.
#Define BCC_020_CODE "18210201000011000160"
#Define BCC_040_CODE "18210204010011010160"
#Define BCC_060_CODE "--------------------------"

// Defenition type payments codes.
#Define CYRILLIC_P CHR(208)
#Define OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#Define OPS_BASE_OVER_LIMIT "80" + CYRILLIC_P
#Define OPS_CONTRIBUTIONS_OVER_LIMIT "81" + CYRILLIC_P // ID 1762.
#Define OPS_CONTRIBUTIONS "840" // ID 0148.
#Define OPS_CONTRIBUTIONS_ADDITIONAL_TARIFF "842" // ID 0150.
#Define NS_AND_PZ_CONTRIBUTIONS "841" // ID 0149.
#Define TEMPORARY_DISABILITY_SALARY_CONTRIBUTIONS "400" // ID 0064.

/*/
{Protheus.doc} RUInsurancePremiumReport2023Part1
    Class for generating a report header Insurance premium report 2023.

    @type Class
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
/*/
Class RUInsurancePremiumReport2023Part1 From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.
    Data aFilials As Array // Array of filials from filters.
    Data aNumbers As Array // Array of personnel numbers from filters. 

    // Data from parameters.
    Data aParameters                As Array // Array of parameters from pergunte.
    Data aPeriods As Array
    Data aLastMonth As Array

    Data cPeriod                    As Character // Report period code (from parameters).
    Data cSigner                    As Character // Full name of the signatory (from parameters).
    Data cYear                      As Character // Report year (from parametes).
    Data cCorrectionNumber          As Character // Correction number in XXX format (from parametes).
    Data nResponsiblePersonCategory As Numeric   // Category of the responsible person.
    Data cCalculationSubmissionCode As Character // Location codes (accounting) (from parametes).
    Data cLocationCode              As Character // Location code (accounting).

    // Data about selected company.
    Data nEmployeeCount             As Character // Average headcount (people).
    Data cPageNumber                As Character // Number of page in format "XXX".

    // Variables for this class.
    Data cBudgetClassCode020 As Character // Line 020.
    Data cBudgetClassCode040 As Character // Line 040.
    Data cBudgetClassCode060 As Character // Line 060.

    Data cPayerType          As Character // 001 - Payer type (code).
    Data cOKTMO              As Character // 010 - CO_OKTMO. Defenition on RUInsurancePremiumReport2023Header class.

    // Lines 030. Compulsory pension insurance premiums payable.
    Data nPensionSumInsurancePremiums As Numeric // 030.
    Data nPensionFirstSumInsurancePremiums As Numeric // 031.
    Data nPensionSecondSumInsurancePremiums As Numeric // 032.
    Data nPensionThirdSumInsurancePremiums As Numeric // 033.

    // Lines 050. Compulsory pension insurance at an additional rate.
    Data nPensionAdditionalRateSumInsurancePremiums       As Numeric // 050.
    Data nPensionAdditionalRateFirstSumInsurancePremiums  As Numeric // 051.
    Data nPensionAdditionalRateSecondSumInsurancePremiums As Numeric // 052.
    Data nPensionAdditionalRateThirdSumInsurancePremiums  As Numeric // 053.

    // Lines 070. Amounts of insurance premiums for additional social security.
    Data nSupplementarySocialProvisionSumInsurancePremiums       As Numeric // 070.
    Data nFirstSupplementarySocialProvisionSumInsurancePremiums  As Numeric // 071.
    Data nSecondSupplementarySocialProvisionSumInsurancePremiums As Numeric // 072.
    Data nThirdSupplementarySocialProvisionSumInsurancePremiums  As Numeric // 073.


    // Constructors.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor

    // Methods.
    Method GetPayerType() // Line 001. Defenition Payer type (code).
    Method PensionInsuranceCalculation() // Line 030, 031, 032, 033.
    Method PensionInsuranceCalculationAtAdditionalRate() // Lines 050, 051, 052, 053.
    Method SupplementarySocialProvisionInsuranceCalculation() // Lines  070, 071, 072, 073.
    Method MakeData()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RUInsurancePremiumReport2023Part1 constructor.

    @type Method, Constructor
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aPeriods,    Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,  Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return RUInsurancePremiumReport2023Part1, Object, RUInsurancePremiumReport2023Part1 instance.
    @example Self:aPart1 := RUInsurancePremiumReport2023Part1():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers)
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Class RUInsurancePremiumReport2023Part1
    Local nI := 0 As Numeric

    Self:aFilials := {}
    Self:aNumbers := {}

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageNumber := "000"

    Self:nEmployeeCount := 0
    Self:aPeriods := AClone(aPeriods)
    Self:aLastMonth := AClone(aLastMonth)

    Self:nPensionSumInsurancePremiums := 0
    Self:nPensionFirstSumInsurancePremiums := 0
    Self:nPensionSecondSumInsurancePremiums := 0
    Self:nPensionThirdSumInsurancePremiums := 0

    Self:nPensionAdditionalRateSumInsurancePremiums       := 0
    Self:nPensionAdditionalRateFirstSumInsurancePremiums  := 0
    Self:nPensionAdditionalRateSecondSumInsurancePremiums := 0
    Self:nPensionAdditionalRateThirdSumInsurancePremiums  := 0

    Self:nSupplementarySocialProvisionSumInsurancePremiums       := 0
    Self:nFirstSupplementarySocialProvisionSumInsurancePremiums  := 0
    Self:nSecondSupplementarySocialProvisionSumInsurancePremiums := 0
    Self:nThirdSupplementarySocialProvisionSumInsurancePremiums  := 0

    // Grouping filials and personnel numbers.    
    For nI := 1 To Len(Self:aFilter)
        // Only filials.
        If aScan(Self:aFilials, {|x| x == Self:aFilter[nI][1]}) < 1
            aAdd(Self:aFilials, Self:aFilter[nI][1])
        EndIf

        // Only personnel numbers.
        If aScan(Self:aNumbers, {|x| x == Self:aFilter[nI][2]}) < 1
            aAdd(Self:aNumbers, Self:aFilter[nI][2])
        EndIf
    Next nI

Return Self

/*/
{Protheus.doc} GetPayerType()
    The method determines the Type of the payer (code). 
    If payments were made to individuals during the quarter, 
    then indicate the code "1", if not - "2".

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return cPayerType, Character, Type of the payer (code).
    @example Self:cPayerType := Self:GetPayerType()
/*/
Method GetPayerType() Class RUInsurancePremiumReport2023Part1
    Local cPayerType As Character
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character

    aArea := GetArea()

    cQuery := " SELECT COUNT(*) AS RESULT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    cPayerType := If(((cTab)->RESULT > 0), EXIST_PAYMENTS, NOT_EXIST_PAYMENTS)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return cPayerType

/*/ {Protheus.doc} PensionInsuranceCalculation()
    The method calculates the amount of mandatory pension insurance premiums payable.
    This method fill values for lines 030, 031, 032, 033 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:PensionInsuranceCalculation()
/*/
Method PensionInsuranceCalculation() Class RUInsurancePremiumReport2023Part1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {OPS_CONTRIBUTIONS_LIMIT, OPS_CONTRIBUTIONS_OVER_LIMIT, TEMPORARY_DISABILITY_SALARY_CONTRIBUTIONS, OPS_CONTRIBUTIONS}
    aLastPaymens := {{Self:aLastMonth[1], 0}, {Self:aLastMonth[2], 0}, {Self:aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        Self:nPensionSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

       (cTab)->(DBSkip())
    EndDo

    (cTab)->(DbCloseArea())

    // Round of insurance premiums: total and by month 
    Self:nPensionSumInsurancePremiums := Round(Self:nPensionSumInsurancePremiums, 2)
    Self:nPensionFirstSumInsurancePremiums := Round(aLastPaymens[1][2], 2)
    Self:nPensionSecondSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    Self:nPensionThirdSumInsurancePremiums := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return


/*/ {Protheus.doc} PensionInsuranceCalculationAtAdditionalRate()
    The method calculates the compulsory pension insurance at an additional rate.
    This method fill values for lines 050, 051, 052, 053 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 25.11.2021
    @version 12.1.33
    @return 
    @example Self:PensionInsuranceCalculationAtAdditionalRate()
/*/
Method PensionInsuranceCalculationAtAdditionalRate() Class RUInsurancePremiumReport2023Part1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {OPS_CONTRIBUTIONS_ADDITIONAL_TARIFF}
    aLastPaymens := {{Self:aLastMonth[1], 0}, {Self:aLastMonth[2], 0}, {Self:aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL IN (?) "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, Self:aNumbers)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        Self:nPensionAdditionalRateSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DbCloseArea())

    // Round of insurance premiums: total and by month 
    Self:nPensionAdditionalRateSumInsurancePremiums       := Round(Self:nPensionAdditionalRateSumInsurancePremiums, 2)
    Self:nPensionAdditionalRateFirstSumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    Self:nPensionAdditionalRateSecondSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    Self:nPensionAdditionalRateThirdSumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return


/*/ {Protheus.doc} SupplementarySocialProvisionInsuranceCalculation()
    The method calculates the amount of insurance premiums for additional social security.
    This method fill values for lines 070, 071, 072, 073 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:SupplementarySocialProvisionInsuranceCalculation()
/*/
Method SupplementarySocialProvisionInsuranceCalculation() Class RUInsurancePremiumReport2023Part1

    /*
        By a specification this part not fill.
    */
    // Round of insurance premiums: total and by month 
    Self:nSupplementarySocialProvisionSumInsurancePremiums       := 0
    Self:nFirstSupplementarySocialProvisionSumInsurancePremiums  := 0
    Self:nSecondSupplementarySocialProvisionSumInsurancePremiums := 0
    Self:nThirdSupplementarySocialProvisionSumInsurancePremiums  := 0

Return

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report header.

    @type Method
    @params 
    @author vselyakov
    @since 21.08.2023
    @version 12.1.33
    @return 
    @example Self:aPart1:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport2023Part1

    Self:cPayerType := Self:GetPayerType() // Line 001.

    // Fill properties from parameters.
    Self:cPeriod := AllTrim(Self:aParameters[CODE_REPORT_PERIOD_INDEX])
    Self:cCalculationSubmissionCode := AllTrim(Self:aParameters[CODE_LOCATION_INDEX])
    Self:cYear := AllTrim(Self:aParameters[REPORT_YEAR_INDEX])
    Self:cCorrectionNumber := Iif(Empty(Self:aParameters[CORRECTION_NUMBER_INDEX]), "000", AllTrim(Self:aParameters[CORRECTION_NUMBER_INDEX]))
    Self:nResponsiblePersonCategory := Self:aParameters[TYPE_SIGNER_INDEX]
    Self:cSigner := AllTrim(Self:aParameters[NAME_SIGNER_INDEX])

    // Lines 020, 030, 031, 032, 033. Calculates the amount of mandatory pension insurance premiums payable.
    Self:cBudgetClassCode020 := BCC_020_CODE
    Self:PensionInsuranceCalculation()

    // Lines 040, 050, 051, 052, 053. Calculation of insurance premiums for compulsory pension insurance at an additional rate.
    Self:cBudgetClassCode040 := BCC_040_CODE
    Self:PensionInsuranceCalculationAtAdditionalRate()

    // Lines 060, 070, 071, 072, 073. The amount of insurance premiums for additional social security.
    Self:cBudgetClassCode060 := BCC_060_CODE
    Self:SupplementarySocialProvisionInsuranceCalculation()

Return
