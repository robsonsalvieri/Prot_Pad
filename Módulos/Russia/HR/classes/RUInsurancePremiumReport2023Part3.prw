#INCLUDE "PROTHEUS.CH"

// Defenition of parameter indexes.
#Define CODE_REPORT_PERIOD_INDEX 1
#Define CODE_LOCATION_INDEX 2
#Define CODE_PAYER_TARIF_INDEX 3
#Define REPORT_YEAR_INDEX 4
#Define CORRECTION_NUMBER_INDEX 5
#Define AGENT_TYPE_INDEX 6
#Define AGENT_CODE_INDEX 7
#Define REORGANIZATION_INDEX 8
#Define TYPE_SIGNER_INDEX 9
#Define CODE_SIGNER_INDEX 10
#Define NAME_SIGNER_INDEX 11

// Defenition Employee properties.
#Define INSURED_PERSON_CATEGORY_CODE "HP-"
#Define SEX_MALE "M" // RA_SEXO.
#Define REPORT_SEX_MALE "1"
#Define REPORT_SEX_FEMALE "2"
#Define GPH_CATEGORY "A" // RA_CATFUNC.
#Define HOURLY_CATEGORY "H" // RA_CATFUNC.
#Define MONTHLY_CATEGORY "A" // RA_CATFUNC.

// Defenition S-Table indexes.
#Define S37_FILIAL_INDEX 2
#Define S37_YEAR_INDEX 3
#Define S37_TYPE_INDEX 5
#Define S37_OPS_INDEX 9
#Define S37_OMS_INDEX 6
#Define S37_PREV_OPS_INDEX 20
#Define S001_FILIAL_INDEX 2
#Define S001_YEAR_INDEX 5
#Define S001_VNIM_INDEX 8

#Define S037_TYPE_YES "1"
#Define S037_TYPE_NO "2"

// Defenition type of payments.
#Define PAYMENT_TYPE_INCOME "1"

#Define CYRILLIC_P CHR(208)
#Define OPS_CONTRIBUTIONS_LIMIT "82" + CYRILLIC_P
#Define INSURANCE_PREMIUM_BASE "700"
#Define OPS_FEES_ADDITIONAL_TARIFF "842"
#Define OPS_BASE_LIMIT "79" + CYRILLIC_P
#Define DEBT_CURRENT_MONTH_PAYMENT "395"
#Define DEBT_PREVIOUS_MONTH_PAYMENT "446"
#Define ADVANCE_ACCURED_PAYMENT "250"

/*/
{Protheus.doc} RUInsurancePremiumReport2023Part3
    Class for generating a report Insurance premium report 2023, Part 3.

    @type Class
    @author vselyakov
    @since 22.08.2023
    @version 12.1.33
/*/
Class RUInsurancePremiumReport2023Part3 From LongNameClass
    Data cPageNumber As Character // Number of page in format "XXX".

    // Fields.
    Data cFilter     As Character // Data from filter.
    Data aFilter     As Array // Array of personnel numbers for filter.
    Data aParameters As Array // Array of parameters from pergunte.
    Data aPeriods    As Array // All months of the selected reporting period.
    Data aLastMonth  As Array // Last 3 months of the selected reporting period.

    // Properties for employee.
    Data cINN As Character
    Data cSNILS As Character
    Data cFirstName As Character
    Data cSecondName As Character
    Data cThirdName As Character
    Data cBirthday As Character
    Data cCountryCode As Character
    Data cGenderCode As Character
    Data cDocumentCode As Character
    Data cNumberDocumnet As Character

    // Data cEmployeeNumber As Character
    Data aEmployeeNumber As Array
    Data cCatfuncEmployee As Character
    Data cCategoryCodeOfInsuredPerson As Character
    Data cSignOfCancelation As Character // Line 010.
    // Data aEmployeeInfo As Array // Lines 020 - 110.
    Data aAmountInfo As Array // Lines 120 - 170.
    Data aBasePremiumsByAdditionalTariff As Array // Lines 180 - 210.

    Data aS037Data As Array // All data from S037.
    Data aS001Data As Array // All data from S001.

    Data lLine210Exist As Logical // Show that Part 3.2.2 will be filled.

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
    @since 22.08.2023
    @version 12.1.33
    @return RUInsurancePremiumReport2023Part3, Object, RUInsurancePremiumReport2023Part3 instance.
    @example Self:oPart3 := RUInsurancePremiumReport2023Part3():New(Self:aParameters, Self:cFilter, Self:aPeriods, Self:aLastMonth, Self:aPersonnelNumbers[nI])
/*/
Method New(aParameters, cFilter, aPeriods, aLastMonth, aPersonnelNumber) Class RUInsurancePremiumReport2023Part3
    Local nI As Numeric

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aPeriods := AClone(aPeriods)
    Self:aLastMonth := AClone(aLastMonth)
    // Self:cEmployeeNumber := cPersonnelNumber
    Self:aEmployeeNumber := aPersonnelNumber
    // Self:aEmployeeInfo := {}
    Self:cCategoryCodeOfInsuredPerson := INSURED_PERSON_CATEGORY_CODE

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
    Self:aAmountInfo := {}
    For nI := 1 To Len(aLastMonth)
        aAdd(Self:aAmountInfo, {nI, aLastMonth[nI], Self:cCategoryCodeOfInsuredPerson, 0, 0, 0, 0})
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
    Self:aBasePremiumsByAdditionalTariff := {}
    For nI := 1 To Len(aLastMonth)
        aAdd(Self:aBasePremiumsByAdditionalTariff, {nI, aLastMonth[nI], Self:cCategoryCodeOfInsuredPerson, 0, 0})
    Next nI

    // Loading data from S-tables.
    Self:aS037Data := {}
    fCarrTab(@Self:aS037Data, "S037")
    Self:aS001Data := {}
    fCarrTab(@Self:aS001Data, "S001")

    Self:lLine210Exist := .F. // By default Part 3.2.2 will be not filled.

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the report.

    @type Method
    @params 
    @author vselyakov
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example Self:oPart3:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport2023Part3

    Self:IPRP3010_SignCancellationInformation()
    Self:IPRP3020_GetEmployeeInformation()
    Self:IPRP3140_GetInfoAmountPayments()
    Self:IPRP3150_BaseForCalculatingInsurancePremiums()
    Self:IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff()

Return

/*/
{Protheus.doc} IPRP3010_SignCancellationInformation()
    The method calculate Sign of cancellation of information about the insured person.
    This line 010 into report.
    Do not fill this line.

    @type Method
    @params 
    @author vselyakov
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example ::IPRP3010_SignCancellationInformation()
/*/
Method IPRP3010_SignCancellationInformation() Class RUInsurancePremiumReport2023Part3
    ::cSignOfCancelation := "-"
Return

/*/
{Protheus.doc} IPRP3020_GetEmployeeInformation()
    The method information about employee.
    This lines 020 - 110 into report.

    @type Method
    @params 
    @author vselyakov
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example ::IPRP3020_GetEmployeeInformation()
/*/
Method IPRP3020_GetEmployeeInformation() Class RUInsurancePremiumReport2023Part3
    Local oStatement As Object
    Local cQuery     As Character
    Local aArea      As Array
    Local cTab       As Character

    aArea := GetArea()

    cQuery := " SELECT RA_PIS, RA_CIC, RA_PRISOBR, RA_PRINOME, RA_SECNOME, RA_NASC, RA_NACIONC, RA_SEXO, RA_FICHA, RA_NUMEPAS, RA_CATFUNC FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_MAT = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, Self:aEmployeeNumber[1])
    oStatement:SetString(2, Self:aEmployeeNumber[2])

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        // Data for report view.
        Self:cINN := (cTab)->RA_PIS
        Self:cSNILS := (cTab)->RA_CIC
        Self:cFirstName := (cTab)->RA_PRINOME
        Self:cSecondName := (cTab)->RA_PRISOBR
        Self:cThirdName := (cTab)->RA_SECNOME
        Self:cBirthday := DToC(SToD((cTab)->RA_NASC))
        Self:cCountryCode := (cTab)->RA_NACIONC
        Self:cGenderCode := Iif((cTab)->RA_SEXO == SEX_MALE, REPORT_SEX_MALE, REPORT_SEX_FEMALE)
        Self:cDocumentCode := (cTab)->RA_FICHA
        Self:cNumberDocumnet := (cTab)->RA_NUMEPAS

        // Other required information.
        Self:cCatfuncEmployee := (cTab)->RA_CATFUNC

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
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
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP3140_GetInfoAmountPayments()
/*/
Method IPRP3140_GetInfoAmountPayments() Class RUInsurancePremiumReport2023Part3
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
    oStatement:SetString(1, Self:aEmployeeNumber[1])
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetString(3, Self:aEmployeeNumber[2])
    oStatement:SetString(4, PAYMENT_TYPE_INCOME)
    oStatement:SetIn(5, {DEBT_CURRENT_MONTH_PAYMENT, DEBT_PREVIOUS_MONTH_PAYMENT, ADVANCE_ACCURED_PAYMENT})

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(Self:aAmountInfo)
            If Self:aAmountInfo[nI][2] == (cTab)->RD_PERIODO
                Self:aAmountInfo[nI][4] := (cTab)->SUMMARY
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
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
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP3150_BaseForCalculatingInsurancePremiums()
/*/
Method IPRP3150_BaseForCalculatingInsurancePremiums() Class RUInsurancePremiumReport2023Part3
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local nI         As Numeric
    Local nS037PercentSum := 0 As Numeric
    Local nS001PercentSum := 0 As Numeric

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
    oStatement:SetString(1, Self:aEmployeeNumber[1])
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, {OPS_BASE_LIMIT})
    oStatement:SetString(4, Self:aEmployeeNumber[2])

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(Self:aAmountInfo)
            If Self:aAmountInfo[nI][2] == (cTab)->RD_PERIODO

                Self:aAmountInfo[nI][5] := (cTab)->SUMMARY // Line 150. For employee category "H", "M", "A".

                // If employee category "A" then fill line 160.
                If Self:cCatfuncEmployee == GPH_CATEGORY // Employee category (RA_CATFUNC) "A".
                    Self:aAmountInfo[nI][6] := (cTab)->SUMMARY
                EndIf

            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    /*
        Calculating line 170.
    */
    // Search data for S037 table.
    For nI := 1 To Len(Self:aS037Data)
        If Self:aS037Data[nI][S37_FILIAL_INDEX] == FwXFilial("SRA") .Or. Empty(Self:aS037Data[nI][S37_FILIAL_INDEX])
            If Self:aParameters[REPORT_YEAR_INDEX] == Substr(Self:aS037Data[nI][S37_YEAR_INDEX], 1, 4) .And. Self:aS037Data[nI][S37_TYPE_INDEX] == S037_TYPE_YES
                nS037PercentSum := Self:aS037Data[nI][S37_OPS_INDEX] + Self:aS037Data[nI][S37_OMS_INDEX]
            EndIf
        EndIf
    Next nI

    // Search data for S001 table.
    For nI := 1 To Len(Self:aS001Data)
        If Self:aS001Data[nI][S001_FILIAL_INDEX] == FwXFilial("SRA") .Or. Empty(Self:aS001Data[nI][S001_FILIAL_INDEX])
            If Self:aParameters[REPORT_YEAR_INDEX] == Substr(Self:aS001Data[nI][S001_YEAR_INDEX], 1, 4) 
                nS001PercentSum := Self:aS001Data[nI][S001_VNIM_INDEX]
            EndIf
        EndIf
    Next nI

    // Filling line 170 for every month.
    For nI := 1 To Len(Self:aAmountInfo)
        Self:aAmountInfo[nI][7] := Self:aAmountInfo[nI][5] * ((nS037PercentSum + nS001PercentSum) / 100)
    Next nI

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
    @since 22.08.2023
    @version 12.1.33
    @return 
    @example Self:IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff()
/*/
Method IPRP3180_InfoAboutBaseCalculatingPremiumsByAdditionalTariff() Class RUInsurancePremiumReport2023Part3
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
    oStatement:SetString(1, Self:aEmployeeNumber[1])
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetIn(3, {INSURANCE_PREMIUM_BASE}) // Payment "700".
    oStatement:SetString(4, Self:aEmployeeNumber[2])

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(Self:aBasePremiumsByAdditionalTariff)
            If Self:aBasePremiumsByAdditionalTariff[nI][2] == (cTab)->RD_PERIODO
                Self:aBasePremiumsByAdditionalTariff[nI][4] := (cTab)->SUMMARY // Fill line 200.
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    // Fill line 210.
    oStatement:SetIn(3, {OPS_FEES_ADDITIONAL_TARIFF}) // Payment "842".
    
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        For nI := 1 To Len(Self:aBasePremiumsByAdditionalTariff)
            If Self:aBasePremiumsByAdditionalTariff[nI][2] == (cTab)->RD_PERIODO
                Self:aBasePremiumsByAdditionalTariff[nI][5] := (cTab)->SUMMARY // Fill line 210.
                Self:lLine210Exist := .T. // Part 3.2.2 will be filled.
            EndIf
        Next nI
        
        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    // If Part 3.2.2 will be not filled that set data line null.
    If !Self:lLine210Exist
        For nI := 1 To Len(Self:aBasePremiumsByAdditionalTariff)
            Self:aBasePremiumsByAdditionalTariff[nI][4] := 0 // Fill line 200.
            Self:aBasePremiumsByAdditionalTariff[nI][5] := 0 // Fill line 210.
        Next nI
    EndIf

    RestArea(aArea)
Return
