#INCLUDE "PROTHEUS.CH"

#DEFINE CYRILLIC_P CHR(208)
#DEFINE OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#DEFINE INSURANCE_PREMIUM_BASE "700"
#DEFINE OPS_FEES_ADDITIONAL_TARIFF "842"
#DEFINE OPS_BASE_LIMIT "79" + CYRILLIC_P

#DEFINE PAYMENT_TYPE_INCOME "1"

#DEFINE DEBT_CURRENT_MONTH_PAYMENT "395"
#DEFINE DEBT_PREVIOUS_MONTH_PAYMENT "446"
#DEFINE ADVANCE_ACCURED_PAYMENT "250"

/*/
{Protheus.doc} RUIPRPart3
    Class for generating a report Insurance premium report, Part 3.

    @type Class
    @author vselyakov
    @since 20.12.2021
    @version 12.1.33
/*/
Class RUIPRPart3 From LongNameClass
    // Fields.
    Data cFilter     As Character // Data from filter.
    Data aFilter     As Array // Array of personnel numbers for filter.
    Data aParameters As Array // Array of parameters from pergunte.
    Data aPeriods    As Array // All months of the selected reporting period.
    Data aLastMonth  As Array // Last 3 months of the selected reporting period.

    Data cEmployeeNumber As Character
    Data cCatfuncEmployee As Character
    Data cCategoryCodeOfInsuredPerson As Character
    Data cSignOfCancelation As Character // Line 010.
    Data aEmployeeInfo As Array // Lines 020 - 110.
    Data aAmountInfo As Array // Lines 120 - 170.
    Data aBasePremiumsByAdditionalTariff As Array // Lines 180 - 210.

    // Methods.
    Method New(aParameters, cFilter, aPeriods, aLastMonth, aFilter) Constructor
    Method MakeData() // Collecting data for the report.

    Method IPRP3010_SignCancellationInformation() // Fill line 010.
    Method IPRP3020_GetEmployeeInformation() // Fill lines 020 - 110.
    Method IPRP3140_GetInfoAmountPayments() // Fill line 140.
    Method IPRP3150_BaseForCalculatingInsurancePremiums() // Fill lines 150 - 170.
    Method IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff() // Fill lines 180 - 210.
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aPeriods, aLastMonth, aFilter)
    Default RUIPRPart2 constructor.

    @type Method
    @params aParameters,      Array,     Array of parameters from pergunte.
            cFilter,          Character, Expression for filter (from parameters).
            aPeriods,         Array,     Array of periods in format 'YYYYMM' ordered. All monthes.
            aLastMonth,       Array,     Array of periods in format 'YYYYMM' ordered. Last 3 month.
            cPersonnelNumber, Character, Personnel Number of employee from filter.
    @author vselyakov
    @since 20.12.2021
    @version 12.1.33
    @return RUIPRPart3, Object, RUIPRPart3 instance.
    @example ::oPart3 := RUIPRPart3():New(::aParameters, ::cFilter, ::aPeriods, ::aLastMonth, ::aPersonnelNumbers[nI])
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, cPersonnelNumber) Class RUIPRPart3
    Local nI As Numeric

    ::aParameters := AClone(aParameters)
    ::cFilter := cFilter
    ::aPeriods := AClone(aPeriods)
    ::aLastMonth := AClone(aLastMonth)
    ::cEmployeeNumber := cPersonnelNumber
    ::aEmployeeInfo := {}
    ::cCategoryCodeOfInsuredPerson := "HP-"

    /* 
    * The array contains lines 120 - 170 in the following structure:
    * 1 - Month (serial number). Line 120.
    * 2 - Period (format "yyyymm").
    * 3 - Insured person category code. Line 130.
    * 4 - The amount of payments and other remuneration. Line 140.
    * 5 - The basis for calculating insurance contributions for compulsory pension insurance within the limit. Line 150.
    * 6 - Including under civil law contracts. Line 160.
    * 7 - The amount of calculated insurance premiums from the base for calculating insurance premiums not exceeding the maximum value. Line 170.
    * 
    * Since this is information for each month, we initialize the values with zeros.
    */
    ::aAmountInfo := {}
    For nI := 1 To Len(aLastMonth)
        aAdd(::aAmountInfo, {nI, aLastMonth[nI], ::cCategoryCodeOfInsuredPerson, 0, 0, 0, 0})
    Next nI

    /* 
    * The array contains lines 180 - 210 in the following structure:
    * 1 - Month (serial number). Line 180.
    * 2 - Period (format "yyyymm").
    * 3 - Insured person category code. Line 190.
    * 4 - The base for calculating insurance premiums at the additional tariff. Line 200.
    * 5 - The amount of calculated insurance premiums. Line 210.
    * 
    * Since this is information for each month, we initialize the values with zeros.
    */
    ::aBasePremiumsByAdditionalTariff := {}
    For nI := 1 To Len(aLastMonth)
        aAdd(::aBasePremiumsByAdditionalTariff, {nI, aLastMonth[nI], ::cCategoryCodeOfInsuredPerson, 0, 0})
    Next nI

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the report.

    @type Method
    @params 
    @author vselyakov
    @since 20.12.2021
    @version 12.1.33
    @return 
    @example ::oPart3:MakeData()
/*/
Method MakeData() Class RUIPRPart3

    ::IPRP3010_SignCancellationInformation()
    ::IPRP3020_GetEmployeeInformation()
    ::IPRP3140_GetInfoAmountPayments()
    ::IPRP3150_BaseForCalculatingInsurancePremiums()
    ::IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff()

Return

/*/
{Protheus.doc} IPRP3010_SignCancellationInformation()
    The method calculate Sign of cancellation of information about the insured person.
    This line 010 into report.
    Do not fill this line.

    @type Method
    @params 
    @author vselyakov
    @since 20.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP3010_SignCancellationInformation()
/*/
Method IPRP3010_SignCancellationInformation() Class RUIPRPart3
    ::cSignOfCancelation := "-"
Return

/*/
{Protheus.doc} IPRP3020_GetEmployeeInformation()
    The method information about employee.
    This lines 020 - 110 into report.

    @type Method
    @params 
    @author vselyakov
    @since 20.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP3020_GetEmployeeInformation()
/*/
Method IPRP3020_GetEmployeeInformation() Class RUIPRPart3
    Local oStatement As Object
    Local cQuery     As Character
    Local aArea      As Array
    Local cTab       As Character

    aArea := GetArea()
    Self:aEmployeeInfo := Array(11) // 11- the number of fields with information about the employee.
    aFill(Self:aEmployeeInfo, "") // Fill string value "" by default.

    cQuery := " SELECT RA_PIS, RA_CIC, RA_PRISOBR, RA_PRINOME, RA_SECNOME, RA_NASC, RA_NACIONC, RA_SEXO, RA_FICHA, RA_NUMEPAS, RA_CATFUNC FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_MAT = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRA"))
    oStatement:SetString(2, ::cEmployeeNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        Self:aEmployeeInfo[1]  := (cTab)->RA_PIS
        Self:aEmployeeInfo[2]  := (cTab)->RA_CIC
        Self:aEmployeeInfo[3]  := (cTab)->RA_PRISOBR
        Self:aEmployeeInfo[4]  := (cTab)->RA_PRINOME
        Self:aEmployeeInfo[5]  := (cTab)->RA_SECNOME
        Self:aEmployeeInfo[6]  := DToC(SToD((cTab)->RA_NASC))
        Self:aEmployeeInfo[7]  := (cTab)->RA_NACIONC
        Self:aEmployeeInfo[8]  := Iif((cTab)->RA_SEXO == "M", "1", "2")
        Self:aEmployeeInfo[9]  := (cTab)->RA_FICHA
        Self:aEmployeeInfo[10] := (cTab)->RA_NUMEPAS
        Self:aEmployeeInfo[11] := (cTab)->RA_CATFUNC
        
        ::cCatfuncEmployee := (cTab)->RA_CATFUNC

        DbSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP3140_GetInfoAmountPayments()
    Information on the amount of payments and other remuneration accrued in favor of an individual.
    This line 140 into report.

    @type Method
    @params 
    @author vselyakov
    @since 23.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP3140_GetInfoAmountPayments()
/*/
Method IPRP3140_GetInfoAmountPayments() Class RUIPRPart3
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric

    aArea := GetArea()

    cQuery := " SELECT SRD.RD_PERIODO, SUM(SRD.RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " SRD "
    cQuery += " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_MAT = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' " // Only FOL scenario.
    cQuery += " AND SRV.RV_TIPOCOD = ?  "
    cQuery += " AND SRD.RD_PD NOT IN (?) "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetString(3, ::cEmployeeNumber)
    oStatement:SetString(4, PAYMENT_TYPE_INCOME)
    oStatement:SetIn(5, {DEBT_CURRENT_MONTH_PAYMENT, DEBT_PREVIOUS_MONTH_PAYMENT, ADVANCE_ACCURED_PAYMENT})

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(::aAmountInfo)
            If ::aAmountInfo[nI][2] == (cTab)->RD_PERIODO
                ::aAmountInfo[nI][4] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP3150_BaseForCalculatingInsurancePremiums()
    This method calculate next values:
    * The basis for calculating insurance contributions for compulsory pension insurance within the limit (150) for employee with RA_CATFUNC IN ("H", "M");
    * Including under civil law contracts (160) for employee with RA_CATFUNC = "A";
    * The amount of calculated insurance premiums from the base for calculating insurance premiums not exceeding the maximum value (170) for employee with RA_CATFUNC IN ("A", "H", "M").
    This lines 150 - 170 into report.

    @type Method
    @params 
    @author vselyakov
    @since 23.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP3150_BaseForCalculatingInsurancePremiums()
/*/
Method IPRP3150_BaseForCalculatingInsurancePremiums() Class RUIPRPart3
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric

    aArea := GetArea()

    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {OPS_CONTRIBUTIONS_LIMIT})
    oStatement:SetString(4, ::cEmployeeNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(::aAmountInfo)
            If ::aAmountInfo[nI][2] == (cTab)->RD_PERIODO
                
                // Fill line 170. This line contain amount of all employee category.
                ::aAmountInfo[nI][7] := (cTab)->SUMMARY

            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()

    oStatement:SetIn(3, {OPS_BASE_LIMIT})
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(::aAmountInfo)
            If ::aAmountInfo[nI][2] == (cTab)->RD_PERIODO

                ::aAmountInfo[nI][5] := (cTab)->SUMMARY // Line 150. For employee category "H", "M", "A".

                // If employee category "A" then fill line 160.
                If ::cCatfuncEmployee == "A" // Employee category (RA_CATFUNC) "A".
                    ::aAmountInfo[nI][6] := (cTab)->SUMMARY
                EndIf

            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()

    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return

/*/
{Protheus.doc} IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff()
    This method calculate next values:
    * The basis for calculating insurance premiums at the additional tariff (line 200);
    * The amount of calculated insurance premiums (line 210).

    This lines 180 - 210 into report.
    Lines 180, 190 was filled into constructor.

    @type Method
    @params 
    @author vselyakov
    @since 23.12.2021
    @version 12.1.33
    @return 
    @example ::IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff()
/*/
Method IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff() Class RUIPRPart3
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric

    aArea := GetArea()

    cQuery := " SELECT RD_PERIODO, SUM(RD_VALOR) AS SUMMARY FROM " + RetSqlName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PERIODO "
    cQuery += " ORDER BY RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {INSURANCE_PREMIUM_BASE})
    oStatement:SetString(4, ::cEmployeeNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(::aBasePremiumsByAdditionalTariff)
            If ::aBasePremiumsByAdditionalTariff[nI][2] == (cTab)->RD_PERIODO
                ::aBasePremiumsByAdditionalTariff[nI][4] := (cTab)->SUMMARY // Fill line 200.
            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()

    // Fill line 210.
    oStatement:SetIn(3, {OPS_FEES_ADDITIONAL_TARIFF})
    
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(::aBasePremiumsByAdditionalTariff)
            If ::aBasePremiumsByAdditionalTariff[nI][2] == (cTab)->RD_PERIODO
                ::aBasePremiumsByAdditionalTariff[nI][5] := (cTab)->SUMMARY // Fill line 210.
            EndIf
        Next nI
        
        DbSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return
