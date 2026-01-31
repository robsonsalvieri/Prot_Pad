#INCLUDE "PROTHEUS.CH"

#Define BUDGET_CLASS_CODE_13 "18210102010011000110"
#Define BUDGET_CLASS_CODE_15 "18210102080011000110"
#Define BUDGET_CLASS_CODE_30 "18210102010011000110"

#Define NDFL_BUDGET_CODE "413"

#Define NDFL_PAYMENT_FIELD_COUNT 16
#Define TAX_REFUND_FIELD_COUNT 4

/*/
{Protheus.doc} Ru6NDFLPart1
    Class for generating a report part 1 6-NDFL.

    @type Class
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
/*/
Class Ru6NDFLPart1 From LongNameClass
    Data aPersonnelNumbers As Array
    Data lFilterOn         As Logical

    Data lRate13           As Logical   // NDFL rate is 13% 
    Data lRate15           As Logical   // NDFL rate is 15% 
    Data lRate30           As Logical   // NDFL rate is 30% 
    Data aPeriods          As Array     // Array of 3 last periods from selected report period in format 'YYYYMM' orderd.
    Data cBudgetClassCode  As Character // 010. Budget classification code.
    Data nIncomeTaxAmount  As Numeric   // 020. Personal income tax amount.
    Data aNDFLPaymens      As Array     // 021 and 022. Array with the date of payment and the amount to be paid.

    Data nTaxAmount        As Numeric   // 030. The amount of personal income tax returned in the last 3 months of the reporting period.
    Data aTaxRefund        As Array     // 031, 032. { 'Tax refund date', 'tax amount' }

    Data cPageNumber       As Character // Number of page in format "XXX".

    Method New(aPeriods, nRate, aFilter) Constructor

    Method GetBudgetClassificationCode()         // 010
    Method GetIncomeTaxAmount(aPeriod)           // 020
    Method GetDateClosePeriodWithAmount(aPeriod) // 021
    Method GetDataAmount(aPeriod)

    Method MakeData()
EndClass

/*/
{Protheus.doc} New()
    Default Ru6NDFLPart1 constructor, 

    @type Method
    @params aPeriods, Array,  Array of 3 last periods from selected report period in format 'YYYYMM' orderd.
            nRate, Numeric, NDFL rate is 13% (.T.). .F. - in other case (15%).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return Ru6NDFLPart1, Object, Ru6NDFLPart1 instance.
    @example Ru6NDFLPart1():New(::aLastMonth, .T.) - for rate 13%.
             Ru6NDFLPart1():New(::aLastMonth, .F.) - for rate 15%.
/*/
Method New(aPeriods, nRate, lFilter, aFilter) Class Ru6NDFLPart1
    Local nI As Numeric

    ::nIncomeTaxAmount := 0
    Iif(nRate == 13, ::lRate13 := .T., ::lRate13 := .F.)
    Iif(nRate == 15, ::lRate15 := .T., ::lRate15 := .F.)
    Iif(nRate == 30, ::lRate30 := .T., ::lRate30 := .F.)
    ::aPeriods := aPeriods
    ::aNDFLPaymens := {}
    ::lFilterOn := lFilter
    ::aPersonnelNumbers := AClone(aFilter)

    ::nTaxAmount := 0

    ::aTaxRefund := {}
    For nI := 1 To TAX_REFUND_FIELD_COUNT
        aAdd(::aTaxRefund, {"--.--.----", 0})
    Next nI

Return Self

/*/
{Protheus.doc} GetBudgetClassificationCode()
    Determination of Budget classification code (::cBudgetClassCode).
    Also return Budget classification code.
    In the report is Line 010.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return cBudgetCode, Character, Budget classification code.
    @example ::cBudgetClassCode := ::GetBudgetClassificationCode()
/*/
Method GetBudgetClassificationCode() Class Ru6NDFLPart1
    Local cBudgetCode As Character

    If ::lRate13
        cBudgetCode := BUDGET_CLASS_CODE_13
    ElseIf ::lRate15
        cBudgetCode := BUDGET_CLASS_CODE_15
    ElseIf ::lRate30
        cBudgetCode := BUDGET_CLASS_CODE_30
    EndIf

Return cBudgetCode

/*/
{Protheus.doc} GetIncomeTaxAmount(aPeriod)
    Determination of Personal income tax amount (::nIncomeTaxAmount).
    Also return Personal income tax amount.

    In the report is Line 020.

    @type Method
    @params aPeriod, Array, Type of company (from parameters).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return nIncomeTaxAmount, Numeric, Amount of Personal income tax amount.
    @example ::nIncomeTaxAmount := ::GetIncomeTaxAmount(::aPeriods)
/*/
Method GetIncomeTaxAmount(aPeriod) Class Ru6NDFLPart1
    Local oStatement       As Object
    Local cQuery           As Character 
    Local aArea            As Array
    Local cTab             As Character
    Local nIncomeTaxAmount As Numeric

    aArea := GetArea()

    // Get sum of income tax amount.
    cQuery := " SELECT SUM(RD_VALOR) AS TAXAMOUNT FROM " +  RetSQLName("SRD")
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD = ? "
    cQuery += Iif(::lRate13, " AND RD_CONVOC='13' ", Iif(::lRate15, " AND RD_CONVOC='15' ", " AND RD_CONVOC='30'"))
    
    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, aPeriod)
    oStatement:SetString(3, NDFL_BUDGET_CODE)

    If ::lFilterOn
        oStatement:SetIn(4, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    nIncomeTaxAmount := (cTab)->TAXAMOUNT

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return nIncomeTaxAmount

/*/
{Protheus.doc} GetDateClosePeriodWithAmount(aPeriod)
    An array is formed with the Date no later than which personal income tax must be paid to the budget 
    and the Total amount of personal income tax that must be paid to the budget on this date.

    In the report is Line 021 and 022.

    @type Method
    @params aPeriod, Array, Type of company (from parameters).
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return aPayments, Array, Array with the date of payment and the amount to be paid.
    @example ::aNDFLPaymens := ::GetDateClosePeriod(::aPeriods)
/*/
Method GetDateClosePeriodWithAmount(aPeriod) Class Ru6NDFLPart1
    Local aPayments    As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character
    Local nI           As Numeric

    aPayments := {}
    aArea := GetArea()

    cQuery := " SELECT RCH_DTPAGO AS CLOSEDATE FROM " +  RetSQLName("RCH")
    cQuery += " WHERE "
    cQuery += " RCH_FILIAL = ? "
    cQuery += " AND RCH_PER IN (?) "
    cQuery += " AND RCH_ROTEIR = 'FOL' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY RCH_PER "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("RCH"))
    oStatement:SetIn(2, aPeriod)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    While !Eof()        
        If !Empty((cTab)->CLOSEDATE)
            aAdd(aPayments, { DToC(SToD((cTab)->CLOSEDATE) + 1), 0})
        Else
            aAdd(aPayments, {"--.--.----", 0})
        EndIf

        DBSkip()
    EndDo

    // Filling empty fields.
    For nI := Len(aPayments) To NDFL_PAYMENT_FIELD_COUNT - 1
        aAdd(aPayments, {"--.--.----", 0})
    Next nI

    For nI := 1 To Len(aPeriod)
        aPayments[nI][2] := ::GetIncomeTaxAmount({aPeriod[nI]})
    Next nI

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return aPayments

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report part 1.
    Fill ::cBudgetClassCode, ::nIncomeTaxAmount, ::aNDFLPaymens.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return Ru6NDFLPart1():New(::aLastMonth, .F.):MakeData()
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class Ru6NDFLPart1

    ::cBudgetClassCode := ::GetBudgetClassificationCode()  // Line 010.
    ::nIncomeTaxAmount := ::GetIncomeTaxAmount(::aPeriods) // Line 020.
    ::aNDFLPaymens     := ::GetDateClosePeriodWithAmount(::aPeriods) // Line 021.

    //::aNDFLPaymens     := ::GetDataAmount(::aPeriods) // Line 021.022.023.024

Return

/*/
{Protheus.doc} GetDataAmount()
    The method get data for the 6-NDFL report part 1.
    Fill ::cBudgetClassCode, ::nIncomeTaxAmount, ::aNDFLPaymens.

    @type Method
    @params 
    @author iprokhorenko
    @since 2023/05/02
    @version 12.1.23
    @return aRes
    @example ::oHeader:GetDataAmount(cPeriod)
/*/
Method GetDataAmount(cPeriod) Class Ru6NDFLPart1
    
    Local oStatement       As Object
    Local cQuery           As Character 
    Local aArea            As Array
    Local cTab             As Character

    Local aRes             As Array

    
    aArea := GetArea()

    aRes := {}
    // Get sum of income tax amount.
    cQuery := " SELECT SUM(RD_VALOR) AS TOTALSUMM , RD_DATPGT ,  RD_HORAS  FROM  " +  RetSQLName("SRD")
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND LEFT(RD_DATPGT,4) = ? "
    cQuery += " AND RD_PD IN ('412', '413') "

    If ::lFilterOn
        cQuery += " AND RD_MAT IN (?) "
    EndIf

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_DATPGT, RD_HORAS"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetString(2, cPeriod )
    //oStatement:SetString(3, NDFL_BUDGET_CODE)

    If ::lFilterOn
        oStatement:SetIn(3, ::aPersonnelNumbers)
    EndIf

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        aAdd(aRes, {(cTab)->TOTALSUMM , (cTab)->RD_DATPGT, (cTab)->RD_HORAS }) //nCount := nCount + 1
        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aRes

