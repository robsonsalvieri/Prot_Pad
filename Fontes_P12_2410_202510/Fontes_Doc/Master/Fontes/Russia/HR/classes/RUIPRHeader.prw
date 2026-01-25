#INCLUDE "PROTHEUS.CH"

#DEFINE CHAR_SPACE_CODE 32
#DEFINE CHAR_DASH_CODE 45
#DEFINE CHAR_OPEN_PARENTHESIS_CODE 40
#DEFINE CHAR_CLOSE_PARENTHESIS_CODE 41

// Reporting period codes. Table S213.
#DEFINE FIRST_QUARTER_REPORT_PERIOD_CODE "21"
#DEFINE HALF_YEAR_REPORT_PERIOD_CODE     "31"
#DEFINE NINE_MONTH_REPORT_PERIOD_CODE    "33"
#DEFINE ONE_YEAR_REPORT_PERIOD_CODE      "34"
#DEFINE REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE "51"
#DEFINE REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE     "52"
#DEFINE REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE    "53"
#DEFINE REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE      "90"

/*/
{Protheus.doc} RuIPRHeader
    Class for generating a report header Insurance premium report.

    @type Class
    @author vselyakov
    @since 2021/09/20
    @version 12.1.33
/*/
Class RuIPRHeader From LongNameClass
    // Data from filter.
    Data cFilter As Character
    Data aFilter As Array // Array of personnel numbers for filter.

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
    Data nEmployeeCount             As Character // Average headcount (people).

    Data cPageNumber                As Character // Number of page in format "XXX".
    Data cLiquidationCode           As Character
    Data cINNClosedOrganization     As Character
    Data cKPPClosedOrganization     As Character
    Data cRepresentOrganizationName As Character // Organization name of the representative.
    Data cRepresentDocument         As Character // Name and details of the representative's document.

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetCompanyInfo(cTypeCompany, cFilCode)
    Method GetRepresentativeDetails(cPersonnelNumber)
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
Method New(aParameters, cFilter, aFilter) Class RuIPRHeader

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

Return Self

/*/
{Protheus.doc} GetCompanyInfo(cTypeCompany, cFilCode)
    The method return data about selected company for the 6-NDFL report header.
    Get data from XX8 and CO and BR (SIGACFG).

    @type Method
    @params cTypeCompany, Character, Type of company (1-Company, 2-Structural unit). Select into parameters.
            cFilCode,     Character, Code of filial. Select into parameters.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.33
    @return aCompanyInfo, Array, Information about selected company.
    @example ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cFilCode)
/*/
Method GetCompanyInfo(cTypeCompany, cFilCode) Class RuIPRHeader
    Local aCompanyInfo As Array
    Local aGetCoBrRusInfo As Array
    Local aArea        As Array

    aArea := GetArea()
    aCompanyInfo := {}
    aGetCoBrRusInfo := {}

    // Get info about selected filial and company (struct. division).
    aGetCoBrRusInfo := GetCoBrRUS(cFilCode)
    
    // Get information for report.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[1][13][2])) // INN.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][5][2])) // KPP.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][6][2])) // Full name.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][8][2])) // IFNS code.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[2][22][2])) // OKTMO.
    aAdd(aCompanyInfo, ::GetClearPhone(Alltrim(aGetCoBrRusInfo[2][9][2]))) // Phone number.
    aAdd(aCompanyInfo, Alltrim(aGetCoBrRusInfo[1][27][2])) // OKVED.

    RestArea(aArea)

Return aCompanyInfo


/*/
{Protheus.doc} GetAverageHeadcount()
    Calculate of Average headcount (people).

    @type Method
    @params 
    @author vselyakov
    @since 2021/09/21
    @version 12.1.33
    @return nAverageCount, Numeric, Average headcount (people).
    @example ::nEmployeeCount := GetAverageHeadcount()
/*/
Method GetAverageHeadcount() Class RuIPRHeader
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
        Case ::cPeriod == FIRST_QUARTER_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_FIRST_QUARTER_REPORT_PERIOD_CODE
            nMonthCount := 3
        Case ::cPeriod == HALF_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_HALF_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 6
        Case ::cPeriod == NINE_MONTH_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_NINE_MONTH_REPORT_PERIOD_CODE
            nMonthCount := 9
        Case ::cPeriod == ONE_YEAR_REPORT_PERIOD_CODE .Or. ::cPeriod == REORGANIZATION_ONE_YEAR_REPORT_PERIOD_CODE
            nMonthCount := 12
        Otherwise
            nMonthCount := 3
    EndCase

    // Calculate the SDR of full-time employees by STEP 1.
    cQuery := " SELECT RA_ADMISSA, RA_DEMISSA, RA_SITFOLH, RA_MAT FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_CATFUNC IN ('M', 'H') "
    cQuery += " AND RA_MAT IN (?) "
    cQuery += " AND RA_HOPARC = '2' " // Underemployment - "No".
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRA"))
    oStatement:SetIn(2, ::aFilter)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !Eof()
        aAdd(aAllSRA, {(cTab)->RA_ADMISSA, (cTab)->RA_DEMISSA, (cTab)->RA_SITFOLH, (cTab)->RA_MAT})

        DBSkip()
    EndDo

    DBCloseArea()

    For nMonth := 1 To nMonthCount
        dCurrentDate := SToD(::cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + "01")
        cCalculationPeriod := ::cYear + PadL(AllTrim(Str(nMonth)), 2, "0")
        nMonthDayCount := RU07XFUN05_GetMonthSize(nMonth, Val(::cYear))
        dLastDateMonth := SToD(::cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + Str(nMonthDayCount, 2))
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
        cQuery := " SELECT COALESCE(SUM((CASE WHEN SRA.RA_CATFUNC = 'M' THEN SRD.RD_HORAS * SRA.RA_HRSDIA ELSE SRD.RD_HORAS END )/(SRA.RA_HRSDIA * RCF.RCF_DIATRA)), 0) AS AVERAGEHEADCOUNT FROM " + RetSqlName("SRD") + " SRD "
        cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT "
        cQuery += " LEFT JOIN " + RetSqlName("RCF") + " RCF ON RCF.RCF_TNOTRA = (CASE WHEN SRA.RA_TNOTRAB = '001' THEN '@@@' ELSE SRA.RA_TNOTRAB END ) AND RCF.RCF_PER = SRD.RD_PERIODO AND RCF.RCF_PROCES = SRD.RD_PROCES "
        cQuery += " WHERE "
        cQuery += " SRA.RA_FILIAL = ? "
        cQuery += " AND SRA.RA_HOPARC = '1' "
        cQuery += " AND SRD.RD_PD IN ('001', '002') "
        cQuery += " AND SRD.RD_PERIODO = ? "
        cQuery += " AND SRD.RD_MAT IN (?) "
        cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
        cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
        cQuery += " AND RCF.D_E_L_E_T_  = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, FWxFilial("SRA"))
        oStatement:SetString(2, cCalculationPeriod)
        oStatement:SetIn(3, ::aFilter)

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

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)
    RestArea(aArea)

Return nAverageCount

/*/
{Protheus.doc} GetRepresentativeDetails(cPersonnelNumber)
    The method returns an array with the details of the documents of the tax agent's representative.

    @type Method
    @params cPersonnelNumber, Character, Personnel number of employee.
    @author vselyakov
    @since 2021/07/09
    @version 12.1.33
    @return aDetails, Array, Array with details of employee.
            aDetails[1] - RA_NUMEPAS
            aDetails[2] - RA_UFPAS
            aDetails[3] - RA_DEMIPAS

    @example ::GetRepresentativeDetails("000001")
/*/
Method GetRepresentativeDetails(cPersonnelNumber) Class RuIPRHeader
    Local aDetails     As Array
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character

    aDetails := {}
    aArea := GetArea()

    cQuery := " SELECT "
    cQuery += " RA_NUMEPAS, RA_UFPAS, RA_DEMIPAS "
    cQuery += " FROM " + RetSqlName("SRA") + " WHERE "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_MAT = ? " 
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRA"))
    oStatement:SetString(2, cPersonnelNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    aAdd(aDetails, Alltrim((cTab)->RA_NUMEPAS))
    aAdd(aDetails, Alltrim((cTab)->RA_UFPAS))
    aAdd(aDetails, Alltrim((cTab)->RA_DEMIPAS))

    DBCloseArea()

    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aDetails

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
Method GetClearPhone(cPhone) Class RuIPRHeader
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
    @since 2021/07/06
    @version 12.1.33
    @return 
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class RuIPRHeader
    Local cTypeCompany As Character
    Local cFilCode     As Character

    cTypeCompany := AllTrim(Str(::aParameters[11]))
    cFilCode := AllTrim(::aParameters[12])

    ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cFilCode)

    // Fill properties about company.
    ::cINN          := ::aCompanyInfo[1]
    ::cKPP          := ::aCompanyInfo[2]
    ::cCompanyName  := Upper(::aCompanyInfo[3])
    ::cIFNSCode     := ::aCompanyInfo[4]
    ::cOKTMO        := ::aCompanyInfo[5]
    ::cCompanyPhone := ::aCompanyInfo[6]
    ::cOKVEDCode    := ::MakeOkvedCodeFormat(::aCompanyInfo[7])

    // Fill properties from parameters.
    ::cPeriod := AllTrim(::aParameters[1])
    ::cCalculationSubmissionCode := AllTrim(::aParameters[2])
    ::cYear := AllTrim(::aParameters[4])
    ::cCorrectionNumber := Iif(Empty(::aParameters[5]), "0", AllTrim(::aParameters[5]))
    ::nResponsiblePersonCategory := ::aParameters[6]
    ::cSigner := AllTrim(::aParameters[8])

    ::nEmployeeCount := ::GetAverageHeadcount()

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
Method MakeOkvedCodeFormat(cOkvedCode) Class RuIPRHeader
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
