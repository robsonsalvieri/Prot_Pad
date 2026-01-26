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

#Define REORGANIZATION_YES 2

// Defenition type of payments.
#Define MONTHLY_PAYMENT "001" // SRV - RV_COD = "001".
#Define HOURLY_PAYMENT "002" // SRV - RV_COD = "002".

// Defenition employee properties.
#Define MONTHLY_CATEGORY "M"
#Define HOURLY_CATEGORY "H"
#Define YES_PARTIAL_TIME_CONTRACT "1" // RA_HOPARC = "Yes".
#Define NO_PARTIAL_TIME_CONTRACT "2" // RA_HOPARC = "No".
#Define DEFAULT_WORK_SCHEDULE "001"

#DEFINE CHAR_SPACE_CODE 32
#DEFINE CHAR_DASH_CODE 45
#DEFINE CHAR_OPEN_PARENTHESIS_CODE 40
#DEFINE CHAR_CLOSE_PARENTHESIS_CODE 41

// Reporting period codes. Table S213.
#Define FIRST_QUARTER_REPORT_PERIOD_CODE "21"
#Define HALF_YEAR_REPORT_PERIOD_CODE     "31"
#Define NINE_MONTH_REPORT_PERIOD_CODE    "33"
#Define ONE_YEAR_REPORT_PERIOD_CODE      "34"
#Define REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE "51"
#Define REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE     "52"
#Define REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE    "53"
#Define REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE      "90"

#Define AGENT_TYPE_FILIAL_INDEX 1
#Define AGENT_TYPE_BUISNESS_UNIT_INDEX 2
#Define AGENT_TYPE_COMPANY_INDEX 3
#Define AGENT_TYPE_GROUP_COMPANY_INDEX 4

/*/
{Protheus.doc} RUInsurancePremiumReport2023Header
    Class for generating a report header Insurance premium report.

    @type Class
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
/*/
Class RUInsurancePremiumReport2023Header From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.
    Data aFilials As Array // Array of filials from filters.
    Data aNumbers As Array // Array of personnel numbers from filters. 

    // Data from parameters.
    Data aParameters                As Array // Array of parameters from pergunte.
    Data aCompanyInfo               As Array

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
    Data cOKTMO                     As Character // CO_OKTMO
    Data cCompanyPhone              As Character // CO_PHONENU
    Data cOKVEDCode                 As Character // CO_OKVED
    Data cOGRNIP                    As Character // Not filled.
    Data nEmployeeCount             As Character // Average headcount (people).

    Data cPageNumber                As Character // Number of page in format "XXX".
    Data cLiquidationCode           As Character
    Data cINNClosedOrganization     As Character
    Data cKPPClosedOrganization     As Character
    Data cRepresentOrganizationName As Character // Organization name of the representative.
    Data cRepresentDocument         As Character // Name and details of the representative's document.

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetCompanyInfo(cTypeCompany, cFilCode)
    Method GetClearPhone(cPhone)
    Method GetAverageHeadcount()

    Method MakeData()
    Method MakeOkvedCodeFormat(cOkvedCode)
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aFilter)
    Default RuIPRHeader constructor, 

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
            cFilter,     Character, Expression for filter (from parameters).
            aFilter,     Array,     Array of personnel numbers for filter.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return RuIPRHeader, Object, RuIPRHeader instance.
    @example ::oHeader := RuIPRHeader():New(::aParameters, ::cFilter, ::aPersonnelNumbers)
/*/
Method New(aParameters, cFilter, aFilter) Class RUInsurancePremiumReport2023Header
    Local nI := 0 As Numeric

    Self:aFilials := {}
    Self:aNumbers := {}

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageNumber := "001"

    Self:cLiquidationCode := ""
    Self:cINNClosedOrganization := ""
    Self:cKPPClosedOrganization := ""
    Self:cRepresentOrganizationName := ""
    Self:cRepresentDocument := ""

    Self:nEmployeeCount := 0

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
{Protheus.doc} GetCompanyInfo(cTypeCompany, cFilCode)
    The method return data about selected company for the 6-NDFL report header.
    Get data from XX8 and CO and BR (SIGACFG).

    @type Method
    @params cTypeCompany, Character, Type of company (1-Company, 2-Structural unit). Select into parameters.
            cFilCode,     Character, Code of filial. Select into parameters.
    @author vselyakov
    @since 23.08.2023
    @version 12.1.33
    @return aCompanyInfo, Array, Information about selected company.
    @example Self:aCompanyInfo := Self:GetCompanyInfo(cTypeCompany, cFilCode)
/*/
Method GetCompanyInfo(cTypeCompany, cFilCode) Class RUInsurancePremiumReport2023Header
    Local aCompanyInfo As Array
    Local aGetCoBrRusInfo As Array
    Local aArea        As Array
    Local oCompanyInfo As Object

    aArea := GetArea()
    aCompanyInfo := {}
    aGetCoBrRusInfo := {}

    If cTypeCompany == AGENT_TYPE_FILIAL_INDEX
        // Get info about selected filial and company (struct. division).
        aGetCoBrRusInfo := GetCoBrRUS(cFilCode)
        
        // Get information for report.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[1][13][2])) // INN.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][5][2])) // KPP.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][6][2])) // Full name.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][8][2])) // IFNS code.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][22][2])) // OKTMO.
        aAdd(aCompanyInfo, Self:GetClearPhone(Alltrim(aGetCoBrRusInfo[2][9][2]))) // Phone number.
        aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[1][27][2])) // OKVED.
    Else
        oCompanyInfo := RUCompanyInfo():New()

        aCompanyInfo := oCompanyInfo:GetInfoAboutCompany(self:aParameters[AGENT_TYPE_INDEX], self:aParameters[PARAM_GROUP_COMPANY_INDEX], self:aParameters[PARAM_COMPANY_INDEX], self:aParameters[PARAM_BUISNESS_UNIT_INDEX])

        FwFreeObj(oCompanyInfo)
    EndIf

    RestArea(aArea)

Return aCompanyInfo

/*/
{Protheus.doc} GetAverageHeadcount()
    Calculate of Average headcount (people).

    @type Method
    @params 
    @author vselyakov
    @since 23.08.2023
    @version 12.1.33
    @return nAverageCount, Numeric, Average headcount (people).
    @example Self:nEmployeeCount := Self:GetAverageHeadcount()
/*/
Method GetAverageHeadcount() Class RUInsurancePremiumReport2023Header
    Local oStatement             As Object
    Local cQuery                 As Character 
    Local aArea                  As Array
    Local cTab                   As Character
    Local nAverageCount          As Numeric
    Local nMonthDayCount         As Numeric
    Local nCountBef              As Numeric
    Local aEmpDays               As Array
    Local dLastDateMonth         As Date
    Local nI                     As Numeric
    Local nJ                     As Numeric
    Local dCurrentDate           As Date
    Local aEmployee              As Array
    Local nTerminationCount      As Numeric // Count of terminated employee in current day.
    Local nMonth                 As Numeric
    Local aSraAverage            As Array
    Local nDayNumber             As Numeric
    Local nSumEmployee           As Numeric
    Local nFullRateEmployeeCount As Numeric // Count of employee with full rate.
    Local nPartRateEmployeeCount As Numeric // Count of employee with part rate.
    Local cCalculationPeriod     As Character
    Local nMonthCount            As Numeric // Count of monthes into selected report period
    Local aAllSRA                As Array

    aArea := GetArea()
    nAverageCount := 0
    aEmpDays := {}
    aEmployee := {}
    aAllSRA := {}
    aSraAverage := {}

    // Determine the number of months in the selected reporting period.
    Do Case
        Case Self:cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            nMonthCount := 3
        Case Self:cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 6
        Case Self:cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            nMonthCount := 9
        Case Self:cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. Self:cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 12
        Otherwise
            nMonthCount := 3
    EndCase

    // Calculate the SDR of full-time employees by STEP 1.
    cQuery := " SELECT RA_ADMISSA, RA_DEMISSA, RA_SITFOLH, RA_MAT FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL IN (?) "
    cQuery += " AND RA_CATFUNC IN (?) "
    cQuery += " AND RA_MAT IN (?) "
    cQuery += " AND RA_HOPARC = ? " // Underemployment - "No".
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, Self:aFilials)
    oStatement:SetIn(2, {MONTHLY_CATEGORY, HOURLY_CATEGORY})
    oStatement:SetIn(3, Self:aNumbers)
    oStatement:SetString(4, NO_PARTIAL_TIME_CONTRACT)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        aAdd(aAllSRA, {(cTab)->RA_ADMISSA, (cTab)->RA_DEMISSA, (cTab)->RA_SITFOLH, (cTab)->RA_MAT})

        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DBCloseArea())

    For nMonth := 1 To nMonthCount
        dCurrentDate := SToD(Self:cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + "01")
        cCalculationPeriod := Self:cYear + PadL(AllTrim(Str(nMonth)), 2, "0")
        nMonthDayCount := RU07XFUN05_GetMonthSize(nMonth, Val(::cYear))
        dLastDateMonth := SToD(Self:cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + Str(nMonthDayCount, 2))
        nCountBef := 0
        nTerminationCount := 0
        nSumEmployee := 0
        nFullRateEmployeeCount := 0
        nPartRateEmployeeCount := 0
        aEmpDays := {}

        For nI := 1 To nMonthDayCount
            For nJ := 1 To Len(aAllSRA)
                If aAllSRA[nJ][1] <= DToS(dCurrentDate) .And. (aAllSRA[nJ][2] >= DToS(dCurrentDate) .Or. Empty(aAllSRA[nJ][2]))
                    nCountBef := nCountBef + 1
                ElseIf aAllSRA[nJ][1] <= DToS(dCurrentDate) .And. aAllSRA[nJ][2] == DToS(dCurrentDate)
                    nTerminationCount := nTerminationCount + 1
                EndIf
            Next nJ

            AAdd(aEmpDays, {DToS(dCurrentDate), nCountBef}) // { Date, Employee Count }
            dCurrentDate := dCurrentDate + 1
            nCountBef := 0 - nTerminationCount
        Next nI

        // Calculation of average days in month
        For nDayNumber := 1 To Len(aEmpDays)
            nSumEmployee := nSumEmployee + aEmpDays[nDayNumber][2]
        Next nDayNumber

        nFullRateEmployeeCount := nSumEmployee / nMonthDayCount

        // Calculate Average headcount of part rate employee in this month.
        cQuery := " SELECT COALESCE(SUM((CASE WHEN SRA.RA_CATFUNC = ? THEN SRD.RD_HORAS * SRA.RA_HRSDIA ELSE SRD.RD_HORAS END )/(SRA.RA_HRSDIA * RCF.RCF_DIATRA)), 0) AS AVERAGEHEADCOUNT FROM " + RetSqlName("SRD") + " SRD "
        cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT "
        cQuery += " LEFT JOIN " + RetSqlName("RCF") + " RCF ON RCF.RCF_TNOTRA = (CASE WHEN SRA.RA_TNOTRAB = ? THEN '@@@' ELSE SRA.RA_TNOTRAB END ) AND RCF.RCF_PER = SRD.RD_PERIODO AND RCF.RCF_PROCES = SRD.RD_PROCES "
        cQuery += " WHERE "
        cQuery += " SRA.RA_FILIAL IN (?) "
        cQuery += " AND SRA.RA_HOPARC = ? "
        cQuery += " AND SRD.RD_PD IN (?) "
        cQuery += " AND SRD.RD_PERIODO = ? "
        cQuery += " AND SRD.RD_MAT IN (?) "
        cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
        cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
        cQuery += " AND RCF.D_E_L_E_T_  = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, MONTHLY_CATEGORY)
        oStatement:SetString(2, DEFAULT_WORK_SCHEDULE)
        oStatement:SetIn(3, Self:aFilials)
        oStatement:SetString(4, YES_PARTIAL_TIME_CONTRACT)
        oStatement:SetIn(5, {MONTHLY_PAYMENT, HOURLY_PAYMENT})
        oStatement:SetString(6, cCalculationPeriod)
        oStatement:SetIn(7, Self:aNumbers)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())
        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        nPartRateEmployeeCount := (cTab)->(AVERAGEHEADCOUNT)

        // Remember Average headcount in this month.
        AAdd(aSraAverage, { cCalculationPeriod, Round(nFullRateEmployeeCount + nPartRateEmployeeCount, 1) })

    Next nMonth

    // Calculate of Average headcount (people).
    For nI := 1 To Len(aSraAverage)
        nAverageCount += aSraAverage[nI][2]
    Next nI

    nAverageCount := Round(nAverageCount / nMonthCount, 0)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nAverageCount

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
Method GetClearPhone(cPhone) Class RUInsurancePremiumReport2023Header
    Local cClearPhone As Character

    cClearPhone := cPhone

    cClearPhone := StrTran(cClearPhone, Chr(CHAR_OPEN_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_CLOSE_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_DASH_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_SPACE_CODE), "")

Return cClearPhone

/*/
{Protheus.doc} MakeData()
    The method collects data for the 6-NDFL report header.

    @type Method
    @params 
    @author vselyakov
    @since 19.08.2023
    @version 12.1.33
    @return 
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class RUInsurancePremiumReport2023Header
    Local cTypeCompany As Character
    Local cFilCode     As Character

    cTypeCompany := Self:aParameters[AGENT_TYPE_INDEX]
    cFilCode := AllTrim(Self:aParameters[PARAM_COMPANY_INDEX]) + AllTrim(Self:aParameters[PARAM_BUISNESS_UNIT_INDEX]) + AllTrim(Self:aParameters[PARAM_FILIAL_INDEX])

    Self:aCompanyInfo := Self:GetCompanyInfo(cTypeCompany, cFilCode)

    // Fill properties about company.
    Self:cINN          := Self:aCompanyInfo[1]
    Self:cKPP          := Self:aCompanyInfo[2]
    Self:cCompanyName  := Upper(Self:aCompanyInfo[3])
    Self:cIFNSCode     := Self:aCompanyInfo[4]
    Self:cOKTMO        := Self:aCompanyInfo[5]
    Self:cCompanyPhone := Self:aCompanyInfo[6]
    Self:cOKVEDCode    := Self:MakeOkvedCodeFormat(Self:aCompanyInfo[7])
    Self:cOGRNIP := "" // This field not filling.

    // If reorganization is true.
    If Self:aParameters[REORGANIZATION_INDEX] == REORGANIZATION_YES
        Self:cLiquidationCode := "0"
        Self:cINNClosedOrganization := Self:aCompanyInfo[1]
        Self:cKPPClosedOrganization := Self:aCompanyInfo[2]
    EndIf

    // Fill properties from parameters.
    Self:cPeriod := AllTrim(Self:aParameters[CODE_REPORT_PERIOD_INDEX])
    Self:cCalculationSubmissionCode := AllTrim(Self:aParameters[CODE_LOCATION_INDEX])
    Self:cYear := AllTrim(Self:aParameters[REPORT_YEAR_INDEX])
    Self:cCorrectionNumber := Iif(Empty(Self:aParameters[CORRECTION_NUMBER_INDEX]), "000", AllTrim(Self:aParameters[CORRECTION_NUMBER_INDEX]))
    Self:nResponsiblePersonCategory := Self:aParameters[AGENT_TYPE_INDEX]
    Self:cSigner := AllTrim(Self:aParameters[NAME_SIGNER_INDEX])

    Self:nEmployeeCount := Self:GetAverageHeadcount()

Return

/*/
{Protheus.doc} MakeOkvedCodeFormat(cOkvedCode)
    The method formats the value of the OKVED code.

    @type Method
    @params 
    @author vselyakov
    @since 24.12.2021
    @version 12.1.33
    @return 
    @example ::MakeOkvedCodeFormat(::aCompanyInfo[7])
/*/
Method MakeOkvedCodeFormat(cOkvedCode) Class RUInsurancePremiumReport2023Header
    Local cResult As Character
    Local cTmp As Character

    cResult := ""

    If !Empty(cOkvedCode)
        cOkvedCode := Padr(cOkvedCode, 8, "")
        
        cTmp := SubStr(cOkvedCode, 1, 2)
        cResult += cTmp + "."
        cTmp := SubStr(cOkvedCode, 4, 2)
        cResult += cTmp + "."
        cTmp := SubStr(cOkvedCode, 7, 2)
        cResult += cTmp
    EndIf

Return cResult
