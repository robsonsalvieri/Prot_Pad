#INCLUDE "PROTHEUS.CH"

#DEFINE BCC_020_CODE "182 1 02 02010 06 1010 160"
#DEFINE BCC_040_CODE "182 1 02 02101 08 1013 160"
#DEFINE BCC_060_CODE "182 1 02 02131 06 1010 160"
#DEFINE BCC_080_CODE "393 1 02 02050 07 1000 160"
#DEFINE BCC_100_CODE "182 1 02 02090 07 1010 160"

#DEFINE CYRILLIC_P CHR(208)
#DEFINE OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#DEFINE OPS_BASE_OVER_LIMIT "80" + CYRILLIC_P
#DEFINE OPS_CONTRIBUTIONS_OVER_LIMIT "81" + CYRILLIC_P // ID 1762.
#DEFINE OPS_CONTRIBUTIONS "840" // ID 0148.
#DEFINE OPS_CONTRIBUTIONS_ADDITIONAL_TARIFF "842" // ID 0150.
#DEFINE NS_AND_PZ_CONTRIBUTIONS "841" // ID 0149.
#DEFINE TEMPORARY_DISABILITY_SALARY_CONTRIBUTIONS "400" // ID 0064.


#DEFINE CHAR_SPACE_CODE 32
#DEFINE CHAR_DASH_CODE 45
#DEFINE CHAR_OPEN_PARENTHESIS_CODE 40
#DEFINE CHAR_CLOSE_PARENTHESIS_CODE 41

/*/
{Protheus.doc} RUIPRPart1
    Class for generating a report header Insurance premium report.

    @type Class
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
/*/
Class RUIPRPart1 From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.

    // Data from parameters.
    Data aParameters                As Array // Array of parameters from pergunte.
    Data aCompanyInfo               As Array
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
    Data cINN                       As Character // CO_INN
    Data cKPP                       As Character // CO_KPP
    Data cCompanyName               As Character // CO_FULLNAME
    Data cIFNSCode                  As Character // CO_LOCLTAX
    // Data cOKTMO                     As Character // 002 - CO_OKTMO
    Data cCompanyPhone              As Character // CO_PHONENU
    Data cOKVEDCode                 As Character // CO_OKVED
    Data nEmployeeCount             As Character // Average headcount (people).

    Data cPageNumber                As Character // Number of page in format "XXX".
    Data cLiquidationCode           As Character
    Data cINNClosedOrganization     As Character
    Data cKPPClosedOrganization     As Character
    Data cRepresentOrganizationName As Character // Organization name of the representative.
    Data cRepresentDocument         As Character // Name and details of the representative's document.

    // Variables for this class.
    Data cBudgetClassCode020 As Character
    Data cBudgetClassCode040 As Character
    Data cBudgetClassCode060 As Character
    Data cBudgetClassCode080 As Character
    Data cBudgetClassCode100 As Character
    Data cPayerType          As Character // 001 - Payer type (code).
    Data cOKTMO              As Character // 002 - CO_OKTMO

    // Compulsory pension insurance premiums payable.
    Data nPensionSumInsurancePremiums As Numeric // 030
    Data nPensionFirstSumInsurancePremiums As Numeric // 031 
    Data nPensionSecondSumInsurancePremiums As Numeric // 032 
    Data nPensionThirdSumInsurancePremiums As Numeric // 033 

    // Compulsory Health insurance premiums payable.
    Data nHealthSumInsurancePremiums As Numeric // 050
    Data nHealthFirstSumInsurancePremiums As Numeric // 051 
    Data nHealthSecondSumInsurancePremiums As Numeric // 052 
    Data nHealthThirdSumInsurancePremiums As Numeric // 053 

    // Compulsory pension insurance at an additional rate.
    Data nPensionAdditionalRateSumInsurancePremiums       As Numeric // 070
    Data nPensionAdditionalRateFirstSumInsurancePremiums  As Numeric // 071 
    Data nPensionAdditionalRateSecondSumInsurancePremiums As Numeric // 072 
    Data nPensionAdditionalRateThirdSumInsurancePremiums  As Numeric // 073 

    // Amounts of insurance premiums for additional social security.
    Data nSupplementarySocialProvisionSumInsurancePremiums       As Numeric // 090
    Data nFirstSupplementarySocialProvisionSumInsurancePremiums  As Numeric // 091 
    Data nSecondSupplementarySocialProvisionSumInsurancePremiums As Numeric // 092 
    Data nThirdSupplementarySocialProvisionSumInsurancePremiums  As Numeric // 093 

    // Amounts for compulsory social insurance in case of temporary disability.
    Data nTemporaryDisabilitySumInsurancePremiums       As Numeric // 110
    Data nFirstTemporaryDisabilitySumInsurancePremiums  As Numeric // 111 
    Data nSecondTemporaryDisabilitySumInsurancePremiums As Numeric // 112 
    Data nThirdTemporaryDisabilitySumInsurancePremiums  As Numeric // 113 

    // This data we do not fill at the moment. Amount of the excess by the payer of the costs of payment of insurance coverage 
    // over the calculated insurance contributions.
    Data nExcessCostsPayerIncurredSumInsurancePremiums       As Numeric // 120
    Data nFirstExcessCostsPayerIncurredySumInsurancePremiums As Numeric // 121
    Data nSecondExcessCostsPayerIncurredSumInsurancePremiums As Numeric // 122
    Data nThirdExcessCostsPayerIncurredSumInsurancePremiums  As Numeric // 123


    // Methods.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor
    Method GetClearPhone(cPhone)
    Method GetPayerType() // Defenition Payer type (code).
    Method GetCompanyInfo(cTypeCompany, cGroupCode, cStructUnitCode, cCodeCompany) // Perhaps one could just pass the code from Header.

    Method PensionInsuranceCalculation()
    Method HealthInsuranceCalculation()
    Method PensionInsuranceCalculationAtAdditionalRate()
    Method SupplementarySocialProvisionInsuranceCalculation()
    Method TemporaryDisabilityInsuranceCalculation()
    Method ExcessCostsPayerIncurred()

    Method MakeData()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RuIPRHeader constructor.

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aPeriods,    Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,  Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return RuIPRHeader, Object, RuIPRHeader instance.
    @example ::aPart1 := RUIPRPart1():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers)
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Class RUIPRPart1

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageNumber := "001"

    Self:cLiquidationCode := ""
    Self:cINNClosedOrganization := ""
    Self:cKPPClosedOrganization := ""
    Self:cRepresentOrganizationName := ""
    Self:cRepresentDocument := ""

    ::nEmployeeCount := 0
    ::aPeriods := AClone(aPeriods)
    ::aLastMonth := AClone(aLastMonth)

    ::nPensionSumInsurancePremiums := 0
    ::nPensionFirstSumInsurancePremiums := 0
    ::nPensionSecondSumInsurancePremiums := 0
    ::nPensionThirdSumInsurancePremiums := 0

    ::nHealthSumInsurancePremiums := 0
    ::nHealthFirstSumInsurancePremiums := 0
    ::nHealthSecondSumInsurancePremiums := 0
    ::nHealthThirdSumInsurancePremiums := 0

    ::nPensionAdditionalRateSumInsurancePremiums       := 0
    ::nPensionAdditionalRateFirstSumInsurancePremiums  := 0
    ::nPensionAdditionalRateSecondSumInsurancePremiums := 0
    ::nPensionAdditionalRateThirdSumInsurancePremiums  := 0

    ::nSupplementarySocialProvisionSumInsurancePremiums       := 0
    ::nFirstSupplementarySocialProvisionSumInsurancePremiums  := 0
    ::nSecondSupplementarySocialProvisionSumInsurancePremiums := 0
    ::nThirdSupplementarySocialProvisionSumInsurancePremiums  := 0

    ::nTemporaryDisabilitySumInsurancePremiums       := 0
    ::nFirstTemporaryDisabilitySumInsurancePremiums  := 0
    ::nSecondTemporaryDisabilitySumInsurancePremiums := 0
    ::nThirdTemporaryDisabilitySumInsurancePremiums  := 0

    ::nExcessCostsPayerIncurredSumInsurancePremiums       := 0
    ::nFirstExcessCostsPayerIncurredySumInsurancePremiums := 0
    ::nSecondExcessCostsPayerIncurredSumInsurancePremiums := 0
    ::nThirdExcessCostsPayerIncurredSumInsurancePremiums  := 0

Return Self

/*/
{Protheus.doc} GetPayerType()
    The method determines the Type of the payer (code). 
    If payments were made to individuals during the quarter, 
    then indicate the code "1", if not - "2".

    @type Method
    @params 
    @author vselyakov
    @since 2021/10/04
    @version 12.1.33
    @return cPayerType, Character, Type of the payer (code).
    @example ::cPayerType := ::GetPayerType()
/*/
Method GetPayerType() Class RUIPRPart1
    Local cPayerType As Character
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character

    aArea := GetArea()
    cPayerType := "1"

    cQuery := " SELECT COUNT(*) AS RESULT FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    cPayerType := If(((cTab)->RESULT > 0), "1", "2")

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return cPayerType

/*/
{Protheus.doc} GetCompanyInfo(cTypeCompany, cXX8_GRPEMP, cXX8_EMPR, cCodeCompany)
    The method return data about selected company for the 6-NDFL report header.
    Get data from XX8 and CO (SIGACFG).

    @type Method
    @params cTypeCompany,    Character, Type of company (1-Company, 2-Structural unit). Select into parameters.
            cGroupCode,      Character, XX8_GRPEMP - Company group code (for company) or structural unit code (for strct. unit).
            cStructUnitCode, Character, XX8_EMPR - Code of company (only for structural unit).
            cCodeCompany,    Character, Code of company (from std. query into parameters).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return aCompanyInfo, Array, Information about selected company.
    @example ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cGroupCode, cStructUnitCode, cCodeCompany)
/*/
Method GetCompanyInfo(cTypeCompany, cGroupCode, cStructUnitCode, cCodeCompany) Class RUIPRPart1
    Local aCompanyInfo As Array
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character

    aArea := GetArea()
    aCompanyInfo := {}

    cQuery := " SELECT "
    cQuery += " CO_INN, CO_KPP, UPPER(CO_FULLNAM) AS CO_FULLNAM, CO_LOCLTAX, CO_OKTMO, CO_PHONENU, CO_OKVED "
    cQuery += " FROM SYS_COMPANY_L_RUS WHERE "
    cQuery += " CO_TIPO = ? "
    cQuery += " AND CO_COMPGRP = ? "
    cQuery += " AND CO_COMPEMP = ? "
    cQuery += " AND CO_COMPUNI = ? "    
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cTypeCompany)
    oStatement:SetString(2, cGroupCode)
    
    If (cTypeCompany == "1")
        oStatement:SetString(3, cCodeCompany)
        oStatement:SetString(4, "")
    Else
        oStatement:SetString(3, cStructUnitCode)
        oStatement:SetString(4, cCodeCompany)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    aAdd(aCompanyInfo, Alltrim((cTab)->CO_INN))
    aAdd(aCompanyInfo, Alltrim((cTab)->CO_KPP))
    aAdd(aCompanyInfo, Alltrim((cTab)->CO_FULLNAME))
    aAdd(aCompanyInfo, Alltrim((cTab)->CO_LOCLTAX))
    aAdd(aCompanyInfo, Alltrim((cTab)->CO_OKTMO))
    aAdd(aCompanyInfo, ::GetClearPhone(Alltrim((cTab)->CO_PHONENU)))
    aAdd(aCompanyInfo, Alltrim((cTab)->CO_OKVED))

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aCompanyInfo

/*/ {Protheus.doc} PensionInsuranceCalculation()
    The method calculates the amount of mandatory pension insurance premiums payable.
    This method fill values for lines 030, 031, 032, 033 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 24.11.2021
    @version 12.1.33
    @return 
    @example ::PensionInsuranceCalculation()
/*/
Method PensionInsuranceCalculation() Class RUIPRPart1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {OPS_CONTRIBUTIONS_LIMIT, OPS_CONTRIBUTIONS_OVER_LIMIT}
    aLastPaymens := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        ::nPensionSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()

    // Round of insurance premiums: total and by month 
    ::nPensionSumInsurancePremiums       := Round(::nPensionSumInsurancePremiums, 2)
    ::nPensionFirstSumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    ::nPensionSecondSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    ::nPensionThirdSumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return

/*/ {Protheus.doc} HealthInsuranceCalculation()
    The method calculates the Compulsory health insurance premiums.
    This method fill values for lines 050, 051, 052, 053 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 24.11.2021
    @version 12.1.33
    @return 
    @example ::HealthInsuranceCalculation()
/*/
Method HealthInsuranceCalculation() Class RUIPRPart1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {OPS_CONTRIBUTIONS}
    aLastPaymens := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.
    nI := 0

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        ::nHealthSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()

    // Round of insurance premiums: total and by month 
    ::nHealthSumInsurancePremiums       := Round(::nHealthSumInsurancePremiums, 2)
    ::nHealthFirstSumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    ::nHealthSecondSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    ::nHealthThirdSumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return


/*/ {Protheus.doc} PensionInsuranceCalculationAtAdditionalRate()
    The method calculates the compulsory pension insurance at an additional rate.
    This method fill values for lines 070, 071, 072, 073 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 25.11.2021
    @version 12.1.33
    @return 
    @example ::PensionInsuranceCalculationAtAdditionalRate()
/*/
Method PensionInsuranceCalculationAtAdditionalRate() Class RUIPRPart1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {OPS_CONTRIBUTIONS_ADDITIONAL_TARIFF}
    aLastPaymens := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        ::nPensionAdditionalRateSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()

    // Round of insurance premiums: total and by month 
    ::nPensionAdditionalRateSumInsurancePremiums       := Round(::nPensionAdditionalRateSumInsurancePremiums, 2)
    ::nPensionAdditionalRateFirstSumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    ::nPensionAdditionalRateSecondSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    ::nPensionAdditionalRateThirdSumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return


/*/ {Protheus.doc} SupplementarySocialProvisionInsuranceCalculation()
    The method calculates the amount of insurance premiums for additional social security.
    This method fill values for lines 090, 091, 092, 093 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 25.11.2021
    @version 12.1.33
    @return 
    @example ::SupplementarySocialProvisionInsuranceCalculation()
/*/
Method SupplementarySocialProvisionInsuranceCalculation() Class RUIPRPart1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {NS_AND_PZ_CONTRIBUTIONS}
    aLastPaymens := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        ::nSupplementarySocialProvisionSumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()

    // Round of insurance premiums: total and by month 
    ::nSupplementarySocialProvisionSumInsurancePremiums       := Round(::nSupplementarySocialProvisionSumInsurancePremiums, 2)
    ::nFirstSupplementarySocialProvisionSumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    ::nSecondSupplementarySocialProvisionSumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    ::nThirdSupplementarySocialProvisionSumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return


/*/ {Protheus.doc} TemporaryDisabilityInsuranceCalculation()
    The method calculates the compulsory social insurance in case of temporary disability.
    This method fill values for lines 110, 111, 112, 113 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 25.11.2021
    @version 12.1.33
    @return 
    @example ::TemporaryDisabilityInsuranceCalculation()
/*/
Method TemporaryDisabilityInsuranceCalculation() Class RUIPRPart1
    Local oStatement    As Object
    Local cQuery        As Character
    Local aArea         As Array
    Local cTab          As Character
    Local aPaymentTypes As Array
    Local aLastPaymens  As Array // Payments by last 3 monthes of period.
    Local nI            As Numeric

    aArea := GetArea()
    aPaymentTypes := {TEMPORARY_DISABILITY_SALARY_CONTRIBUTIONS}
    aLastPaymens := {{::aLastMonth[1], 0}, {::aLastMonth[2], 0}, {::aLastMonth[3], 0}} // This array has next structure: {{RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}, {RD_PERIOD, SUM(RD_VALOR)}}.

    // Calculate total amount of mandatory pension insurance premiums payable.
    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMM FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, aPaymentTypes)
    oStatement:SetIn(4, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        ::nTemporaryDisabilitySumInsurancePremiums += (cTab)->SUMM
        nI := aScan(aLastPaymens, {|x| x[1] == (cTab)->RD_PERIODO})

        If (nI > 0)
            aLastPaymens[nI][2] := (cTab)->SUMM
        EndIf

        DBSkip()
    EndDo

    DbCloseArea()

    // Round of insurance premiums: total and by month 
    ::nTemporaryDisabilitySumInsurancePremiums       := Round(::nTemporaryDisabilitySumInsurancePremiums, 2)
    ::nFirstTemporaryDisabilitySumInsurancePremiums  := Round(aLastPaymens[1][2], 2)
    ::nSecondTemporaryDisabilitySumInsurancePremiums := Round(aLastPaymens[2][2], 2)
    ::nThirdTemporaryDisabilitySumInsurancePremiums  := Round(aLastPaymens[3][2], 2)

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return

/*/ {Protheus.doc} ExcessCostsPayerIncurred()
    The method calculates The amount of the excess by the payer of the costs of payment of insurance coverage 
    over the calculated insurance contributions for compulsory social insurance in case of temporary 
    disability and in connection with motherhood.

    This method fill values for lines 120, 121, 122, 123 in the report.

    @type Method
    @params 
    @author vselyakov
    @since 25.11.2021
    @version 12.1.33
    @return 
    @example ::ExcessCostsPayerIncurred()
/*/
Method ExcessCostsPayerIncurred() Class RUIPRPart1
    ::nExcessCostsPayerIncurredSumInsurancePremiums       := 0
    ::nFirstExcessCostsPayerIncurredySumInsurancePremiums := 0
    ::nSecondExcessCostsPayerIncurredSumInsurancePremiums := 0
    ::nThirdExcessCostsPayerIncurredSumInsurancePremiums  := 0
Return

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report header.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return 
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class RUIPRPart1
    Local cTypeCompany          As Character
    Local cGroupCode            As Character
    Local cStructUnitCode       As Character
    Local cCodeCompany          As Character

    // Define Budget class code.
    ::cBudgetClassCode020 := BCC_020_CODE
    ::cBudgetClassCode040 := BCC_040_CODE
    ::cBudgetClassCode060 := BCC_060_CODE
    ::cBudgetClassCode080 := "--------------------------" // BCC_080_CODE
    ::cBudgetClassCode100 := BCC_100_CODE

    ::cPayerType := ::GetPayerType() // Line 001.

    // // Perhaps one could just pass the code from Header.
    cTypeCompany    := AllTrim(Str(::aParameters[11]))
    cGroupCode      := AllTrim(SubStr(::aParameters[12], 1, 12))
    cStructUnitCode := AllTrim(SubStr(::aParameters[12], 13, 12))
    cCodeCompany    := AllTrim(SubStr(::aParameters[12], 25, 12))

    ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cGroupCode, cStructUnitCode, cCodeCompany)

    // Fill properties about company.
    ::cINN          := ::aCompanyInfo[1]
    ::cKPP          := ::aCompanyInfo[2]
    ::cCompanyName  := UPPER(::aCompanyInfo[3])
    ::cIFNSCode     := ::aCompanyInfo[4]
    ::cOKTMO        := ::aCompanyInfo[5] // Line 002.
    ::cCompanyPhone := ::aCompanyInfo[6]
    ::cOKVEDCode    := ::aCompanyInfo[7]

    // Fill properties from parameters.
    ::cPeriod := AllTrim(::aParameters[1])
    ::cCalculationSubmissionCode := AllTrim(::aParameters[2])
    ::cYear := AllTrim(::aParameters[4])
    ::cCorrectionNumber := Iif(Empty(::aParameters[5]), "0", AllTrim(::aParameters[5]))
    ::nResponsiblePersonCategory := ::aParameters[6]
    ::cSigner := AllTrim(::aParameters[8])

    // Calculates the amount of mandatory pension insurance premiums payable.
    ::PensionInsuranceCalculation()

    // Calculates the amount of mandatory Health insurance premiums payable.
    ::HealthInsuranceCalculation()

    // Calculation of insurance premiums for compulsory pension insurance at an additional rate.
    ::PensionInsuranceCalculationAtAdditionalRate()

    // The amount of insurance premiums for additional social security.
    // ::SupplementarySocialProvisionInsuranceCalculation()

    // Compulsory social insurance in case of temporary disability.
    ::TemporaryDisabilityInsuranceCalculation()

    // The amount of the excess by the payer of the costs of payment of 
    // insurance coverage over the calculated insurance contributions for 
    // compulsory social insurance in case of temporary disability and in connection with motherhood.
    ::ExcessCostsPayerIncurred()

Return

/*/
{Protheus.doc} GetClearPhone(cPhone)
    The method removes the formatting of the phone number (brackets, spaces, dashes).

    @type Method
    @params cPhone, Character, Formatted phone number ("8(495)999-99-99").
    @author vselyakov
    @since 2021/07/12
    @version 12.1.33
    @return cClearPhone, Character, Cleared phone number ("84959999999").
    @example ::oHeader:GetClearPhone(cPhoneNumber)
/*/
Method GetClearPhone(cPhone) Class RUIPRPart1
    Local cClearPhone As Character

    cClearPhone := cPhone

    cClearPhone := StrTran(cClearPhone, Chr(CHAR_OPEN_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_CLOSE_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_DASH_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_SPACE_CODE), "")

Return cClearPhone