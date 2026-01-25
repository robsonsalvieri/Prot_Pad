#INCLUDE "PROTHEUS.CH"

#Define BUDGET_CLASS_CODE_13 "18210102010011000110"
#Define BUDGET_CLASS_CODE_15 "18210102080011000110"
#Define BUDGET_CLASS_CODE_30 "18210102010011000110"

#Define PAYMENT_TYPE_13 "992"
#Define PAYMENT_TYPE_13_2 "675"
#Define PAYMENT_TYPE_15 "993"
#Define PAYMENT_TYPE_STAFF "413"
#Define NDFL_BUDGET_CODE "413"
#Define NDFL_BUDGET_CODE2 "412"
#Define TAX_DEDUCTION_BUDGET_CODE "675"
#Define BASE_NDFL_BUDGET_CODE "605"

/*/
{Protheus.doc} Ru6NDFLPart2
    Class for generating a report part 2 6-NDFL.

    @type Class
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
/*/
Class Ru6NDFLPart2 From LongNameClass
    Data aPersonnelNumbers           As Character
    Data lFilterOn                   As Logical

    Data lRate13                     As Logical   // NDFL rate is 13% 
    Data lRate15                     As Logical   // NDFL rate is 15% 
    Data lRate30                     As Logical   // NDFL rate is 30% 
    Data aPeriods                    As Array     // Array of 3 last periods from selected report period in format 'YYYYMM' orderd.
    Data aS002Lines                  As Array
    Data aArrayPeriod                As Array
    Data aRates                      As Array
    

    Data nNDFLRate                   As Numeric   // 100 - Personal income tax rate (NDFL).
    Data cBudgetClassCode            As Character // 105 - Budget classification code.
    Data nIncomeAmountTotal          As Numeric   // 110 - The amount of income accrued to individuals (total by all ToP).
    Data nAmountByDividend           As Numeric   // 111 - UNUSED - Amount of dividend income.
    Data nContractAmount             As Numeric   // 112 - The amount of income for labor contract - categories "H" and "M".
    Data nGPCAmount                  As Numeric   // 113 - The amount of income under a civil contract - categories "A".
    Data nEmployeeCount              As Numeric   // 120 - The number of individuals who received income.
    Data nDeductionAmount            As Numeric   // 130 - Amount of deductions - amount of applied deductions.
    Data nTaxAmountCalculated        As Numeric   // 140 - Calculated tax amount.
    Data nCalculatedAmountByDividend As Numeric   // 141 - UNUSED - Amount of tax calculated on dividends
    Data nFixAdvancedPayment         As Numeric   // 150 - UNUSED - The amount of a fixed advance payment.
    Data nWithheldTaxAmount          As Numeric   // 160 - The amount of tax withheld. the total amount of personal income tax withheld from the beginning of the year.
    Data nNotWithheldAmount          As Numeric   // 170 - UNUSED - Tax amount refunded by the tax agent.
    Data nUndulyWithheldAmount       As Numeric   // 180 - UNUSED - Tax amount unduly withheld by the withholding agent.
    Data nRefundedAmount             As Numeric   // 190 - UNUSED - Tax amount refunded by the tax agent.
    Data cPageNumber                 As Character // Number of page in format "XXX".

    Data aNDLFRate As Array // 100 - Personal income tax rate (NDFL).

    Method New(aPeriods, nRate, aFilter) Constructor

    Method GetData()
    Method GetTotalIncomeAmount()
    Method GetContractIncomeAmount()
    Method GetGPCIncomeAmount()
    Method GetEmployeeCountForPayment()
    Method GetDeductionAmount()
    Method GetTaxAmount()
    Method GetWithheldTaxAmount()
EndClass

/*/
{Protheus.doc} New()
    Default Ru6NDFLPart2 constructor, 

    @type Method
    @params aPeriods, Array,  Array of 3 last periods from selected report period in format 'YYYYMM' orderd.
            nRate, numeric, NDFL rate is 13% (13). 15 - in other case (15%).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return Ru6NDFLPart2, Object, Ru6NDFLPat2 instance.
    @example Ru6NDFLPart2():New(::aPeriods, 13) - for rate 13%.
             Ru6NDFLPart2():New(::aPeriods, 15) - for rate 15%.
/*/
Method New(aPeriods, nRate, lFilter, aFilter) Class Ru6NDFLPart2
    Local nI As Numeric

    ::aPeriods := AClone(aPeriods)
    Iif(nRate == 13, ::lRate13 := .T., ::lRate13 := .F.)
    Iif(nRate == 15, ::lRate15 := .T., ::lRate15 := .F.)
    Iif(nRate == 30, ::lRate30 := .T., ::lRate30 := .F.)

    // Set standart value for unused data.
    ::nAmountByDividend := 0
    ::nCalculatedAmountByDividend := 0
    ::nFixAdvancedPayment := 0
    ::nNotWithheldAmount := 0
    ::nUndulyWithheldAmount := 0
    ::nRefundedAmount := 0

    ::lFilterOn := lFilter
    ::aPersonnelNumbers := AClone(aFilter)

    ::aS002Lines := {}
    ::aRates := {} // {Summ, Rate}
    ::aNDLFRate := {13, 15}

    fCarrTab(@::aS002Lines, "S002")
    For nI := 1 To Len(::aS002Lines)
        If (SubStr(::aS002Lines[nI][5], 1, 4) == SubStr(::aPeriods[1], 1, 4))
            AAdd(::aRates, {::aS002Lines[nI][8], ::aS002Lines[nI][9]})
            AAdd(::aRates, {::aS002Lines[nI][11], ::aS002Lines[nI][12]})
        EndIf
    Next nI

Return Self

/*/
{Protheus.doc} GetData()
    General method for getting data for this report part 2.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example Ru6NDFLPart2():New(::aPeriods, .T.):GetData()
/*/
Method GetData() Class Ru6NDFLPart2

    ::nNDFLRate := Iif(::lRate13, 13, Iif(::lRate15, 15, 30))
    ::cBudgetClassCode := Iif(::lRate13, BUDGET_CLASS_CODE_13, Iif(::lRate15, BUDGET_CLASS_CODE_15, BUDGET_CLASS_CODE_30))

    ::nIncomeAmountTotal   := ::GetTotalIncomeAmount()       // Parameter # 110.
    ::nContractAmount      := ::GetContractIncomeAmount()    // Parameter # 112.
    ::nGPCAmount           := ::GetGPCIncomeAmount()         // Parameter # 113.
    ::nEmployeeCount       := ::GetEmployeeCountForPayment() // Parameter # 120.
    If ::lRate15 .Or. ::lRate30
        ::nDeductionAmount := 0                              // Parameter # 130.
    Else
        ::nDeductionAmount := ::GetDeductionAmount()         // Parameter # 130.
    EndIf
    ::nTaxAmountCalculated := ::GetTaxAmount()               // Parameter # 140.
    ::nWithheldTaxAmount   := ::GetWithheldTaxAmount()       // Parameter # 160.

Return

/*/
{Protheus.doc} GetTotalIncomeAmount()
    Calculation of The amount of income accrued to individuals (total by all ToP).
    Fill line 110 (nIncomeAmountTotal).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nTotalPayment, Numeric, The amount of income accrued to individuals (total by all ToP).
    @example ::nIncomeAmountTotal := ::GetTotalIncomeAmount()
/*/
Method GetTotalIncomeAmount() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nTotalPayment As Numeric

    aArea := GetArea()

    cQuery := " SELECT MAX(RD_PERIODO) AS PER, RD_MAT, RD_PD FROM " +  RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_ROTEIR = 'FOL' "
    cQuery += " AND RD_PERIODO in (?) "
    cQuery += " AND RD_PD in (?) "
    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PD, RD_MAT "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {PAYMENT_TYPE_13, PAYMENT_TYPE_15, PAYMENT_TYPE_STAFF})

    If ::lFilterOn
        oStatement:SetIn(4, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    ::aArrayPeriod := {}
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !(cTab)->(Eof())
        Aadd(::aArrayPeriod, PadR((cTab)->PER, GetSX3Cache("RD_PERIODO", "X3_TAMANHO"), " ") + PadR((cTab)->RD_MAT, GetSX3Cache("RD_MAT", "X3_TAMANHO"), " ") + ;
        PadR((cTab)->RD_PD, GetSX3Cache("RD_PD", "X3_TAMANHO"), " "))
        (cTab)->(DBSkip())
    EndDo
    (cTab)->(DBCloseArea())
    // Get sum of income tax amount.
    cQuery := " SELECT SUM(SRD.RD_VALOR) AS TOTAL, SRD.RD_PD, ST.STAFF FROM " + RetSQLName("SRD") + " SRD "
    cQuery += " LEFT OUTER JOIN (SELECT MAX(S.RD_HORAS) AS STAFF, S.RD_MAT AS MAT FROM " + RetSQLName("SRD")
    cQuery += " S WHERE CONCAT(S.RD_PERIODO, S.RD_MAT, S.RD_PD) IN (?) AND S.RD_PD = ? GROUP BY RD_MAT) AS ST ON ST.MAT = RD_MAT WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND (CONCAT(SRD.RD_PERIODO, SRD.RD_MAT, SRD.RD_PD) in (?) "
    cQuery += " OR (SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_PD in (?))) "
    If ::lFilterOn
        cQuery += " AND SRD.RD_MAT IN (?) "
    EndIf
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PD, ST.STAFF "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aArrayPeriod)
    oStatement:SetString(2, PAYMENT_TYPE_STAFF)
    oStatement:SetString(3, FWxFilial("SRD"))
    oStatement:SetIn(4, ::aArrayPeriod)

    oStatement:SetIn(5, ::aPeriods)
    oStatement:SetIn(6, {PAYMENT_TYPE_13_2})

    If ::lFilterOn
        oStatement:SetIn(7, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nTotalPayment := 0
    While !(cTab)->(Eof())
        If ::lRate13
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2
                nTotalPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate15
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15
                nTotalPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate30 .And. (cTab)->STAFF == 30 .And. (Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2 ;
            .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15)
            nTotalPayment += (cTab)->TOTAL
        EndIf
        (cTab)->(DBSkip())
    EndDo
    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nTotalPayment


/*/
{Protheus.doc} GetContractIncomeAmount()
    Calculate the amount of income for labor contract - categories "H" and "M".
    Fill line 112 (nContractAmount).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nPayment, Numeric, The amount of income accrued to individuals (total by all ToP).
    @example ::nContractAmount := ::GetContractIncomeAmount()
/*/
Method GetContractIncomeAmount() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nPayment      As Numeric

    aArea := GetArea()

    cQuery := " SELECT SUM(SRD.RD_VALOR) AS TOTAL, SRD.RD_PD, ST.STAFF FROM " + RetSQLName("SRD") + " SRD "
    cQuery += " LEFT OUTER JOIN (SELECT MAX(S.RD_HORAS) AS STAFF, S.RD_MAT AS MAT FROM " + RetSQLName("SRD")
    cQuery += " S WHERE CONCAT(S.RD_PERIODO, S.RD_MAT, S.RD_PD) IN (?) AND S.RD_PD = ? GROUP BY RD_MAT) AS ST ON ST.MAT = RD_MAT "
    cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA "
    cQuery += " ON SRD.RD_MAT = SRA.RA_MAT "
    cQuery += " WHERE "
    cQuery += " SRA.RA_FILIAL = ? "
    cQuery += " AND SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRA.RA_CATFUNC IN ('H', 'M') "
    cQuery += " AND (CONCAT(SRD.RD_PERIODO, SRD.RD_MAT, SRD.RD_PD) in (?) "
    cQuery += " OR (SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_PD in (?))) "
    // cQuery += Iif(::lRate13, " AND SRD.RD_CONVOC='13' ", " AND SRD.RD_CONVOC='15' ")
    If ::lFilterOn
        cQuery += " AND SRD.RD_MAT IN (?) "
    EndIf
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PD, ST.STAFF "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aArrayPeriod)
    oStatement:SetString(2, PAYMENT_TYPE_STAFF)
    oStatement:SetString(3, FWxFilial("SRA"))
    oStatement:SetString(4, FWxFilial("SRD"))
    oStatement:SetIn(5, ::aArrayPeriod)
    oStatement:SetIn(6, ::aPeriods)
    oStatement:SetIn(7, {PAYMENT_TYPE_13_2})
    
    If ::lFilterOn
        oStatement:SetIn(8, ::aPersonnelNumbers)
    EndIf
    
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nPayment := 0

    While !(cTab)->(Eof())
        If ::lRate13
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2
                nPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate15
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15
                nPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate30 .And. (cTab)->STAFF == 30 .And. (Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2 ;
            .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15)
            nPayment += (cTab)->TOTAL
        EndIf
        (cTab)->(DBSkip())
    EndDo

    nPayment := Round(nPayment, 2)

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nPayment

/*/
{Protheus.doc} GetGPCIncomeAmount()
    Calculate The amount of income under a civil contract - categories "A".
    Fill line 113 (nGPCAmount).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nPayment, Numeric, The amount of income accrued to individuals (total by all ToP).
    @example ::nGPCAmount := ::GetGPCIncomeAmount() 
/*/
Method GetGPCIncomeAmount() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nPayment As Numeric

    aArea := GetArea()

    cQuery := " SELECT SUM(SRD.RD_VALOR) AS TOTAL, SRD.RD_PD, ST.STAFF FROM " + RetSQLName("SRD") + " SRD "
    cQuery += " LEFT OUTER JOIN (SELECT MAX(S.RD_HORAS) AS STAFF, S.RD_MAT AS MAT FROM " + RetSQLName("SRD")
    cQuery += " S WHERE CONCAT(S.RD_PERIODO, S.RD_MAT, S.RD_PD) IN (?) AND S.RD_PD = ? GROUP BY RD_MAT) AS ST ON ST.MAT = RD_MAT "
    cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA "
    cQuery += " ON SRD.RD_MAT = SRA.RA_MAT "
    cQuery += " WHERE "
    cQuery += " SRA.RA_FILIAL = ? "
    cQuery += " AND SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND SRA.RA_CATFUNC IN ('A') "
    cQuery += " AND (CONCAT(SRD.RD_PERIODO, SRD.RD_MAT, SRD.RD_PD) in (?) "
    cQuery += " OR (SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_PD in (?))) "
    If ::lFilterOn
        cQuery += " AND SRD.RD_MAT IN (?) "
    EndIf
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PD, ST.STAFF "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, ::aArrayPeriod)
    oStatement:SetString(2, PAYMENT_TYPE_STAFF)
    oStatement:SetString(3, FWxFilial("SRA"))
    oStatement:SetString(4, FWxFilial("SRD"))
    oStatement:SetIn(5, ::aArrayPeriod)
    oStatement:SetIn(6, ::aPeriods)
    oStatement:SetIn(7, {PAYMENT_TYPE_13_2})
    
    If ::lFilterOn
        oStatement:SetIn(8, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nPayment := 0

    While !(cTab)->(Eof())
        If ::lRate13
            If Alltrim((cTab)->RD_PD) = PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2
                nPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate15
            If Alltrim((cTab)->RD_PD) = PAYMENT_TYPE_15
                nPayment += (cTab)->TOTAL
            EndIf
        ElseIf ::lRate30 .And. (cTab)->STAFF == 30 .And. (Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2 ;
            .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15)
            nPayment += (cTab)->TOTAL
        EndIf
        (cTab)->(DBSkip())
    EndDo

    nPayment := Round(nPayment, 2)

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return nPayment

/*/
{Protheus.doc} GetEmployeeCountForPayment()
    Calculate The number of individuals who received income.
    Fill line 120 (nEmployeeCount).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nCount, Numeric, The amount of income accrued to individuals (total by all ToP).
    @example ::nEmployeeCount := ::GetEmployeeCountForPayment()
/*/
Method GetEmployeeCountForPayment() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nCount        As Numeric

    aArea := GetArea()
    nCount := 0

    cQuery := " SELECT RD_MAT AS TOTAL FROM " + RetSqlName("SRD") 
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_ROTEIR='FOL' "
    cQuery += Iif(::lRate13, " AND RD_CONVOC='13' ", Iif(::lRate15, " AND RD_CONVOC='15' ", " AND RD_CONVOC='30' "))

    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_MAT "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)

    If ::lFilterOn
        oStatement:SetIn(3, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        nCount := nCount + 1
        DBSkip()
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)
Return nCount

/*/
{Protheus.doc} GetDeductionAmount()
    Calculate Amount of deductions - amount of applied deductions.
    Fill line 130 (nDeductionAmount).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nPaymentSum, Numeric, Amount of deductions - amount of applied deductions.
    @example ::nDeductionAmount := ::GetDeductionAmount()
/*/
Method GetDeductionAmount() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nPaymentSum   As Numeric

    aArea := GetArea()

    cQuery := " SELECT SUM(RD_VALOR) AS TOTAL FROM " + RetSqlName("SRD")  
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_ROTEIR='FOL' "
    cQuery += " AND RD_PD = ? "

    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetString(3, TAX_DEDUCTION_BUDGET_CODE)

    If ::lFilterOn
        oStatement:SetIn(4, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nPaymentSum := (cTab)->TOTAL

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nPaymentSum

/*/
{Protheus.doc} GetTaxAmount()
    Calculated tax amount.
    Fill line 140 (nTaxAmountCalculated).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nPaymentSum, Numeric, Tax amount.
    @example ::nTaxAmountCalculated := ::GetTaxAmount()
/*/
Method GetTaxAmount() Class Ru6NDFLPart2
    Local nPaymentSum   As Numeric

    nPaymentSum :=  If((::nIncomeAmountTotal - ::nDeductionAmount) < 0, 0, (::nIncomeAmountTotal - ::nDeductionAmount))
    nPaymentSum := Round(nPaymentSum * (::nNDFLRate / 100), 2)

Return nPaymentSum

/*/
{Protheus.doc} GetWithheldTaxAmount()
    Calculated The amount of tax withheld.
    Fill line 160 (nTaxAmountCalculated).

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nPaymentSum, Numeric, The amount of tax withheld.
    @example ::nWithheldTaxAmount := ::GetWithheldTaxAmount()
/*/
Method GetWithheldTaxAmount() Class Ru6NDFLPart2
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local nPaymentSum   As Numeric

    aArea := GetArea()

    cQuery := " SELECT SUM(RD_VALOR) AS TOTAL FROM " + RetSqlName("SRD")
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    // cQuery += " AND RD_ROTEIR='FOL' "
    cQuery += Iif(::lRate13, " AND RD_HORAS='13' ", Iif(::lRate15, " AND RD_HORAS='15' ", " AND RD_HORAS='30' "))
    cQuery += " AND RD_PD IN (?) "

    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {NDFL_BUDGET_CODE})

    If ::lFilterOn
        oStatement:SetIn(4, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nPaymentSum := (cTab)->TOTAL

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nPaymentSum
