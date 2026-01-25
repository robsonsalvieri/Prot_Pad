#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R05RUS.CH"

#DEFINE CHAR_SPACE_CODE 32
#DEFINE CHAR_DASH_CODE 45
#DEFINE CHAR_OPEN_PARENTHESIS_CODE 40
#DEFINE CHAR_CLOSE_PARENTHESIS_CODE 41

#DEFINE MAX_LEN_FSS_CODE 10
#DEFINE MAX_LEN_SUBORD_CODE 5
#DEFINE MAX_LEN_CORRECTION_NUMBER 3
#DEFINE MAX_LEN_FULL_NAME 160
#DEFINE MAX_LEN_INN 12
#DEFINE MAX_LEN_KPP 9
#DEFINE MAX_LEN_OGRN 15
#DEFINE MAX_LEN_PHONE_NUMBER 20
#DEFINE MAX_LEN_OCVED 8
#DEFINE MAX_LEN_ADDRES 100
#DEFINE MAX_LEN_PAGES 3
#DEFINE MAX_LEN_RESP_PERSON 60
#DEFINE MAX_LEN_AVER_LIST_EMPLOYEE 6
#DEFINE MAX_LEN_INVALID 6
#DEFINE MAX_LEN_HARMFUL_FACTOR 6

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
{Protheus.doc} RUSocialInsuranceFundHeader
    Class for generating a report header FSS.

    @type Class
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
/*/
Class RUSocialInsuranceFundHeader From LongNameClass
    // Data from filter.
    Data cFilter  As Character
    Data aFilter  As Array // Array of personnel numbers for filter.
    Data aEmplAll As Array // Array of all employee by parametr and filter

    // Data from parameters.
    Data aParameters            As Array // Array of parameters from pergunte.

    Data cPeriod                As Character // Report period code (from parameters).
    Data cYear                  As Character // Report year (from parametes).
    Data cCorrectionNumber      As Character // Correction number in XXX format (from parametes).

    // Data about selected company.
    Data cFSSNum                As Character // CO_FSS
    Data cCodeSubord            As Character // CO_SUBORD
    Data cINN                   As Character // CO_INN
    Data cKPP                   As Character // CO_KPP
    Data cCompanyName           As Character // CO_FULLNAME
    Data cOGRN                  As Character // CO_OGRN
    Data cCompanyPhone          As Character // CO_PHONENU
    Data cOKVEDCode             As Character // CO_OKVED
    Data cAddres                As Character // Registration addres of company
    Data aAddres                As Array     // Addres by part
    Data cNameRespPerson        As Character // Name of responsible person  (from parametes)
    Data cCountInvalidEmployee  As Character // Count of invalid (disabled)
    Data cCountAverListEmployee As Character // Average listing employee
    Data cCompanyNum            As Character // Code of company (whitout filial)
    Data cCountEOnHarmFactor    As Character // Count of employee on harmful work

    Data cPageNumber            As Character // Number of page in format "XXX".
    Data cPageCount             As Character // Count of page in format "XXX".

    Data aPeriods               As Array     // Periods for calculation

    Method New(aParameters, cFilter, aFilter) Constructor

    Method GetCompanyInfo(cTypeCompany, cFilCode)
    Method GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    Method GetAddresByKey(cKeyForAddres, cDate)
    Method GetStructCode(cFilialCode)
    Method GetClearPhone(cPhone)
    Method CalcEmpoyeeInfo()
    Method GetAverageListCount()

    Method MakeData()
    Method GetViewReport()
EndClass

/*/
{Protheus.doc} New(aParameters, cFilter, aFilter)
    Default RUSocialInsuranceFundHeader constructor, 

    @type Method
    @params aParameters, Array, Array of parameters from pergunte.
    @params cFilter,     Character, Expression for filter (from parameters).
    @params aFilter,     Array,     Array of personnel numbers for filter.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return RUSocialInsuranceFundHeader, Object, RUSocialInsuranceFundHeader instance.
    @example ::oHeader := RUSocialInsuranceFundHeader():New(::aParameters, ::cFilter, ::aFilter)
/*/
Method New(aParameters, cFilter, aFilter) Class RUSocialInsuranceFundHeader

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter
    Self:aFilter := AClone(aFilter)

    Self:cPageNumber := "001"

    Self:cPageCount := "001"

Return Self

/*/
{Protheus.doc} MakeData()
    The method collects data for the FSS report header.

    @type Method
    @params 
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return 
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class RUSocialInsuranceFundHeader

    Local cTypeCompany   As Character
    Local cFilCode       As Character
    Local lResult := .T. As Logical

    cTypeCompany := AllTrim(Str(::aParameters[11]))
    cFilCode := AllTrim(::aParameters[12])

    ::cCountEOnHarmFactor := "No data"

    // Fill properties from parameters.
    ::cPeriod := AllTrim(::aParameters[1])
    ::cYear := AllTrim(::aParameters[4])
    ::cCorrectionNumber := Iif(Empty(::aParameters[5]), "0", AllTrim(::aParameters[5]))
    ::cNameRespPerson := AllTrim(::aParameters[8])

    If !::GetCompanyInfo(cTypeCompany, cFilCode) .Or. !::CalcEmpoyeeInfo()
        lResult := .F.
    EndIf

Return lResult

/*/
{Protheus.doc} GetCompanyInfo(cTypeCompany, cFilialCode)
    The method receives data about selected company for the FSS report header.
    Get data from SYS_COMPANY and SYS_COMPANY_L_RUS (SIGACFG).

    @type Method
    @params cTypeCompany, Character, Type of company (1-Company, 2-Structural unit). Select into parameters.
    @params cFilialCode,  Character, Filial code.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return lResult, Logical, Information about success get information by company.
    @example ::GetCompanyInfo(cTypeCompany, cFilialCode)
/*/
Method GetCompanyInfo(cTypeCompany, cFilialCode) Class RUSocialInsuranceFundHeader

    Local oStatement     As Object
    Local cQuery         As Character 
    Local aArea          As Array
    Local cTab           As Character
    Local cGroupCode     As Character
    Local cStructCodeF   As Character
    Local lResult := .T. As Logical
    Local nI             As Numeric
    Local cCodeCompany   As Character
    Local cCodeUnit      As Character
    Local nLenCCompany   As Numeric
    Local nLenCUnit      As Numeric
    Local lBranch := .F. As Logical
    Local aCompanyInfo   As Array
    Local aCampo         As Array
    Local cKeyForAddres  As Character

    aArea := GetArea()
    If Empty(cFilialCode)
        cFilialCode := cFilAnt
    Else
        lBranch := .T.
    EndIf
    cStructCodeF := ::GetStructCode(cFilialCode)
    cCodeCompany := ""
    cCodeUnit := ""
    cGroupCode := cEmpAnt
    nLenCCompany := 0
    nLenCUnit := 0
    aCampo := {{"CO_FSS", "CO_FSS"}, {"CO_SUBORD", "CO_SUBORD"}, {"UPPER(CO_FULLNAM) AS CO_FULLNAM", "CO_FULLNAM"}, ;
    {"CO_INN", "CO_INN"}, {"CO_KPP", "CO_KPP"}, {"CO_OGRN", "CO_OGRN"}, {"CO_PHONENU", "CO_PHONENU"}, {"CO_OKVED", "CO_OKVED"}}

    If Empty(cStructCodeF)
        // "Company not found" "Company with a branch" "not found"
        Help(,, STR0018,, STR0019 + " " + cFilialCode + " " + STR0020, 1, 0,  NIL, NIL, NIL, NIL, NIL, {})
        lResult := .F.
    Else

        For nI := 1 To Len(cStructCodeF)
            Do Case 
                Case SubStr(cStructCodeF, nI, 1) == "E"
                    nLenCCompany += 1
                Case SubStr(cStructCodeF, nI, 1) == "U"
                    nLenCUnit += 1
            EndCase
        Next nI

        cCodeCompany := SubStr(cFilialCode, 1, nLenCCompany)
        cCodeUnit := Iif(cTypeCompany == "2" .Or. lBranch, SubStr(cFilialCode, 1 + nLenCCompany, nLenCUnit), "")

        aCompanyInfo := ::GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
        ::cCompanyNum := Iif(lBranch, cFilialCode, aCompanyInfo[9] + aCompanyInfo[10])
        cKeyForAddres := aCompanyInfo[11] + Iif(aCompanyInfo[14] $ "12" .Or. lBranch, aCompanyInfo[12], "") + ;
        Iif(aCompanyInfo[14] $ "2" .Or. lBranch, aCompanyInfo[13], "")

        If lBranch

            aCompanyInfo[14] := SubStr(cFilialCode, nLenCCompany + nLenCUnit + 1)

            cQuery := " SELECT "
            cQuery += " BR_FSS, BR_SUBORD, BR_KPP, UPPER(BR_FULLNAM) AS BR_FULLNAM, BR_PHONENU, BR_OKVED"
            cQuery += " FROM SYS_BRANCH_L_RUS WHERE "
            cQuery += " BR_COMPGRP = ? "
            cQuery += " AND BR_COMPEMP = ? "
            cQuery += " AND BR_COMPUNI = ? "
            cQuery += " AND BR_BRANCH = ? "
            cQuery += " AND D_E_L_E_T_ = ' ' "

            oStatement := FWPreparedStatement():New(cQuery)
            oStatement:SetString(1, cGroupCode)
            oStatement:SetString(2, cCodeCompany)
            oStatement:SetString(3, cCodeUnit)
            oStatement:SetString(4, aCompanyInfo[14])

            cTab := MPSysOpenQuery(oStatement:GetFixQuery())

            DBSelectArea(cTab)
            (cTab)->(DbGoTop())

            ::cFSSNum       := Alltrim((cTab)->BR_FSS)
            ::cCodeSubord   := Alltrim((cTab)->BR_SUBORD)
            ::cCompanyName  := Upper(Alltrim((cTab)->BR_FULLNAME))
            ::cINN          := aCompanyInfo[4]
            ::cKPP          := Alltrim((cTab)->BR_KPP)
            ::cOGRN         := aCompanyInfo[6]
            ::cCompanyPhone := ::GetClearPhone(Alltrim((cTab)->BR_PHONENU))
            ::cOKVEDCode    := Alltrim((cTab)->BR_OKVED)

            (cTab)->(DBCloseArea())
            oStatement:Destroy()
            FwFreeObj(oStatement)

        Else
            ::cFSSNum       := aCompanyInfo[1]
            ::cCodeSubord   := aCompanyInfo[2]
            ::cCompanyName  := Upper(aCompanyInfo[3])
            ::cINN          := aCompanyInfo[4]
            ::cKPP          := aCompanyInfo[5]
            ::cOGRN         := aCompanyInfo[6]
            ::cCompanyPhone := ::GetClearPhone(aCompanyInfo[7])
            ::cOKVEDCode    := aCompanyInfo[8]
        EndIf

        cKeyForAddres := xFilial("SM0") + cKeyForAddres + aCompanyInfo[14]

        ::aAddres := ::GetAddresByKey(cKeyForAddres, ::cYear + "0101")
        ::cAddres := ::aAddres[1]

        RestArea(aArea)

    EndIf

Return lResult

/*/
{Protheus.doc} GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    The method receives data about selected company. If no data about selected company - get data abaout hight structure/
    Get data from SYS_COMPANY and SYS_COMPANY_L_RUS (SIGACFG).

    @type Method
    @params aCampo,       Array,     Array fields in CO which mast received ({{Field_From_DB, Alias_Field}...})
    @params cGroupCode,   Character, Code group of company.
    @params cCodeCompany, Character, Code company.
    @params cCodeUnit,    Character, Cod bussines unit.
    @author dchizhov
    @since 2022/11/24
    @version 12.1.33
    @return aResult, Array, Received Information.
    @example aCompanyInfo := ::GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
/*/
Method GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit) Class RUSocialInsuranceFundHeader

    Local oStatement     As Object
    Local cQuery         As Character 
    Local aArea          As Array
    Local cTab           As Character
    Local aResult := { } As Logical
    Local cCodeCompany   As Character
    Local cCodeUnit      As Character
    Local nI             As Numeric

    DEFAULT cGroupCode := cEmpAnt

    If !Empty(aCampo)

        aArea := GetArea()

        cQuery := " SELECT "
        For nI := 1 To Len(aCampo)
            cQuery += aCampo[nI, 1] + ", "
        Next nI
        cQuery += " CO_COMPGRP, CO_COMPEMP, CO_COMPUNI, CO_TIPO"
        cQuery += " FROM SYS_COMPANY_L_RUS WHERE "
        cQuery += " CO_COMPGRP = ? "
        cQuery += " AND CO_COMPEMP = ? "
        cQuery += " AND CO_COMPUNI = ? "
        cQuery += " AND D_E_L_E_T_ = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cGroupCode)
        oStatement:SetString(2, cCodeCompany)
        oStatement:SetString(3, cCodeUnit)

        cTab := MPSysOpenQuery(oStatement:GetFixQuery())

        DBSelectArea(cTab)
        (cTab)->(DbGoTop())
        If !((cTab)->(EOF()))
            For nI := 1 To Len(aCampo)
                AAdd(aResult, Alltrim((cTab)->(&(aCampo[nI, 2]))))
            Next nI
            AAdd(aResult, cCodeCompany)
            AAdd(aResult, cCodeUnit)
            AAdd(aResult, (cTab)->CO_COMPGRP)
            AAdd(aResult, (cTab)->CO_COMPEMP)
            AAdd(aResult, (cTab)->CO_COMPUNI)
            AAdd(aResult, (cTab)->CO_TIPO)
        EndIf

        (cTab)->(DBCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)

        RestArea(aArea)

        If Empty(aResult) .And. !(Empty(cCodeCompany) .And. Empty(cCodeUnit))
            If !Empty(cCodeUnit)
                aResult := GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, "")
            Else
                aResult := GetHCompanyInfo(aCampo, cGroupCode, "", "")
            EndIf
        EndIf
    EndIf

Return aResult

/*/
{Protheus.doc} RU07R0503_GetAddres(cKeyForAddres, cDate)
    Get Last addres for organization by key.
    Use table AGA 

    @type Function
    @params cKeyForAddres, Character, Key of organization.
    @params cDate,         Character, The date on which the data must be valid.
    @author dchizhov
    @since 2022/11/25
    @version 12.1.33
    @return aResult, Array, Addres.
    @example ::aAddres := ::GetAddresByKey(cKeyForAddres, cDate)
/*/
Method GetAddresByKey(cKeyForAddres, cDate) Class RUSocialInsuranceFundHeader

    Local cQuery     As Character
    Local oStatement As Object
    Local cTab       As Character
    Local aResult    As Character
    Local nRecNo     As Numeric

    nRecNo := -1

    cQuery := " SELECT "
    cQuery += " R_E_C_N_O_"
    cQuery += " FROM " + RetSqlName("AGA") + " AGA WHERE "
    cQuery += " AGA_ENTIDA = 'SM0' "
    cQuery += " AND AGA_CODENT = ? "
    cQuery += " AND AGA_FROM < ? "
    cQuery += " AND AGA_TIPO = '0' "
    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " ORDER BY AGA_FROM DESC "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cKeyForAddres)
    oStatement:SetString(2, cDate)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    If !((cTab)->(EOF()))
        nRecNo := (cTab)->R_E_C_N_O_
    EndIf

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    If nRecNo > 0
        aResult := RU07R0503_GetColumnFromTableByNrec("AGA", {"AGA_FULL", "AGA_CEP", "AGA_EST", "AGA_BAIRRO", ;
        "AGA_MUNDES", "AGA_END", "AGA_HOUSE", "AGA_BLDNG", "AGA_APARTM"}, nRecNo)
    Else
        aResult := Array(9)
        aFill(aResult, " ")
    EndIf

    aResult[3] := Posicione("SX5", 1, xFilial("SX5") + "12" + aResult[3], "x5Descri()") 
    
Return aResult

/*/
{Protheus.doc} GetStructCode(cFilialCode)
    This method returns a company code template.

    @type Method
    @params cFilialCode, Character, Filial code.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return cStructCodeF, Character, company code template.
    @example cStructCode := ::GetStructCode(cFilialCode)
/*/
Method GetStructCode(cFilialCode) Class RUSocialInsuranceFundHeader

    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local cGroup       As Character
    Local cStructCodeF As Character

    aArea := GetArea()
    cGroup := cEmpAnt
    cStructCodeF := ""

    cQuery := "SELECT M0_LEIAUTE AS STRUCTURE FROM SYS_COMPANY WHERE"
    cQuery += " M0_CODIGO = ? "
    cQuery += " AND M0_CODFIL = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cGroup)
    oStatement:SetString(2, cFilialCode)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    cStructCodeF := Alltrim((cTab)->STRUCTURE)

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return cStructCodeF

/*/
{Protheus.doc} GetClearPhone(cPhone)
    The method removes the formatting of the phone number (brackets, spaces, dashes).

    @type Method
    @params cPhone, Character, Formatted phone number ("8(495)999-99-99").
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return cClearPhone, Character, Cleared phone number ("84959999999").
    @example ::oHeader:GetClearPhone(cPhoneNumber)
/*/
Method GetClearPhone(cPhone) Class RUSocialInsuranceFundHeader
    Local cClearPhone As Character

    cClearPhone := cPhone

    cClearPhone := StrTran(cClearPhone, Chr(CHAR_OPEN_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_CLOSE_PARENTHESIS_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_DASH_CODE), "")
    cClearPhone := StrTran(cClearPhone, Chr(CHAR_SPACE_CODE), "")

Return cClearPhone

/*/
{Protheus.doc} CalcEmpoyeeInfo()
    The method receives data about emplyee for the FSS report header.

    @type Method
    @params
    @author dchizhov
    @since 2022/11/23
    @version 12.1.33
    @return lResult, Logical, Information about success receives data about emplyee by company.
    @example ::CalcEmpoyeeInfo()
/*/
Method CalcEmpoyeeInfo() Class RUSocialInsuranceFundHeader

    Local lResult := .T. As Logical
    Local nCountInvalid  As Numeric
    Local aArea          As Array
    Local aSRAArea       As Array
    Local aFullEmployee  As Array
    Local aNFullEmployee As Array
    Local nI             As Numeric

    aArea := GetArea()
    aSRAArea := SRA->(GetArea())

    nCountInvalid := 0
    aFullEmployee := {}
    aNFullEmployee := {}

    DbSelectArea("SRA")
    SRA->(DbSetOrder(13))
    SRA->(DbGoTop())

    ::aEmplAll := {}

    For nI := 1 To Len(::aFilter)
        If DbSeek(::aFilter[nI, 1] + ::aFilter[nI, 2])
            If At(::cCompanyNum, SRA->RA_FILIAL) == 1 .And. SRA->RA_CATFUNC $ "MH"
                If SRA->RA_SITFOLH <> "D" .And. SRA->RA_DEFIFIS == "1"
                    nCountInvalid += 1
                EndIf
                If SRA->RA_HOPARC == "2"
                    AAdd(aFullEmployee, {SRA->RA_MAT + SRA->RA_FILIAL, SRA->RA_ADMISSA, SRA->RA_DEMISSA})
                ElseIf SRA->RA_HOPARC == "1"
                    AAdd(aNFullEmployee, SRA->RA_MAT + SRA->RA_FILIAL)
                EndIf
                AAdd(::aEmplAll, ::aFilter[nI, 3])
            EndIf
        EndIf
    Next nI

    ::cCountInvalidEmployee := cValToChar(nCountInvalid)
    lResult := ::GetAverageListCount(aFullEmployee, aNFullEmployee) .And. lResult

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lResult

/*/
{Protheus.doc} GetAverageListCount(aFullEmployee, aNFullEmployee)
    Calculate of Average ListCount (people).

    @type Method
    @params aFullEmployee, Array, Array of full-time employees
    @params aFullEmployee, Array, Array of not full-time employees
    @author dchizhov
    @since 2022/11/24
    @version 12.1.33
    @return lResult, Logical, Success of calculating Average ListCount (people).
    @example ::GetAverageListCount(aFullEmployee, aNFullEmployee)
/*/
Method GetAverageListCount(aFullEmployee, aNFullEmployee) Class RUSocialInsuranceFundHeader
    Local oStatement             As Object
    Local cQuery                 As Character 
    Local aArea                  As Array
    Local cTab                   As Character
    Local nAverageCount          As Numeric
    Local nMonthDayCount         As Numeric
    Local dLastDateMonth         As Date
    Local nI                     As Numeric
    Local dCurrentDate           As Date
    Local nMonth                 As Numeric
    Local aSraAverage            As Array
    Local nSumEmployee           As Numeric
    Local nFullRateEmployeeCount As Numeric // Count of employee with full rate.
    Local nPartRateEmployeeCount As Numeric // Count of employee with part rate.
    Local cCalculationPeriod     As Character
    Local cFilterFilial          As Character
    Local nMonthCount            As Numeric // Count of monthes into selected report period
    Local lResult                As Logical
    Local dStartWorkMonthPer     As Date
    Local dFinishWorkMonthPer    As Date

    aArea := GetArea()
    nAverageCount := 0
    aSraAverage := {}
    lResult := .T.
    cFilterFilial := ""

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

    nI := At("RA_FILIAL", ::cFilter, 1)
    If nI > 0
        cFilterFilial += " (SRA." + SubStr(::cFilter, nI, At( ")", ::cFilter, nI + 1) - nI + 1)
    EndIf
    nI := At("RA_FILIAL", ::cFilter, nI + 1)
    If nI > 0
        If !Empty(cFilterFilial)
            cFilterFilial += " AND "
        EndIf
        cFilterFilial += " (SRA." + SubStr(::cFilter, nI, At( ") ", ::cFilter, nI + 1) - nI + 1)
    EndIf

    ::aPeriods := { }

    For nMonth := 1 To nMonthCount
        dCurrentDate := SToD(::cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + "01")
        cCalculationPeriod := ::cYear + PadL(AllTrim(Str(nMonth)), 2, "0")
        nMonthDayCount := RU07XFUN05_GetMonthSize(nMonth, Val(::cYear))
        dLastDateMonth := SToD(::cYear + PadL(AllTrim(Str(nMonth)), 2, "0") + Str(nMonthDayCount, 2))
        nSumEmployee := 0
        nFullRateEmployeeCount := 0
        nPartRateEmployeeCount := 0

        For nI := 1 To Len(aFullEmployee)
            dStartWorkMonthPer := Max(aFullEmployee[nI, 2], dCurrentDate)
            dFinishWorkMonthPer := Iif(Empty(aFullEmployee[nI, 3]), dLastDateMonth, Min(aFullEmployee[nI, 3], dLastDateMonth))
            If dStartWorkMonthPer <= dLastDateMonth .And. dFinishWorkMonthPer >= dCurrentDate
                nSumEmployee += dFinishWorkMonthPer - dStartWorkMonthPer + 1
            EndIf
        Next nI

        nFullRateEmployeeCount := nSumEmployee / nMonthDayCount

        AAdd(::aPeriods, cCalculationPeriod)

        // Calculate Average headcount of part rate employee in this month.
        cQuery := " SELECT COALESCE(SUM((CASE WHEN SRD.RD_PD = '001' THEN SRD.RD_HORAS * SRA.RA_HRSDIA ELSE SRD.RD_HORAS END )/(SRA.RA_HRSDIA * RCF.RCF_DIATRA)), 0) AS AVERAGEHEADCOUNT FROM " + RetSqlName("SRD") + " SRD "
        cQuery += " LEFT JOIN " + RetSqlName("SRA") + " SRA ON SRA.RA_MAT = SRD.RD_MAT AND SRA.RA_FILIAL = SRD.RD_FILIAL "
        cQuery += " LEFT JOIN " + RetSqlName("RCF") + " RCF ON RCF.RCF_TNOTRA = (CASE WHEN SRA.RA_TNOTRAB = '001' THEN '@@@' ELSE SRA.RA_TNOTRAB END ) AND RCF.RCF_PER = SRD.RD_PERIODO AND RCF.RCF_PROCES = SRD.RD_PROCES"
        cQuery += " WHERE "
        cQuery += cFilterFilial
        cQuery += " AND SRA.RA_HOPARC = '1' "
        cQuery += " AND SRD.RD_PD IN ('001', '002') "
        cQuery += " AND SRD.RD_PERIODO = ? "
        cQuery += " AND CONCAT(SRD.RD_MAT,SRD.RD_FILIAL) IN (?) "
        cQuery += " AND SRA.D_E_L_E_T_ = ' ' "
        cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
        cQuery += " AND RCF.D_E_L_E_T_  = ' ' "

        oStatement := FWPreparedStatement():New(cQuery)
        oStatement:SetString(1, cCalculationPeriod)
        oStatement:SetIn(2, aNFullEmployee)

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

    ::cCountAverListEmployee := CValToChar(nAverageCount)

Return lResult

/*/
{Protheus.doc} GetViewReport()
    This method generates header-lines for output to the log.
    This allows you to visually view the generated data on the FSS report 
    and save them in a PDF document. 

    @type Method
    @params cDateReport, Character, Date of report.
    @params oContent, Object, Object with array of content for report.
    @author dchizhov
    @since 2022/11/22
    @version 12.1.33
    @return lResult, Logical, The data has been successfully submitted for display.
    @example ::GetViewReport()
            RUSocialInsuranceFundHeader:GetViewReport()
/*/
Method GetViewReport(cDateReport, oContent) Class RUSocialInsuranceFundHeader

    Local lResult := .T. As Logical
    Local oJson          As Object

    oJson := JsonObject():New()
    oJson["style"] := "normal"
    oJson["margin"] := {5, 0, 5, 0}
    oJson["table"] := JsonObject():New()
    oJson["table"]["width"] := "100%"
    oJson["table"]["widths"]:= {250, "*"}
    oJson["table"]["body"] := { { RU07R0504_BuildSample(STR0023), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cFSSNum, MAX_LEN_FSS_CODE)                    + "'")} }
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0024), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cCodeSubord, MAX_LEN_SUBORD_CODE)             + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0025), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cCorrectionNumber, MAX_LEN_CORRECTION_NUMBER) + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0026), RU07R0504_BuildSample("'" + ::cPeriod                                                                   + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0027), RU07R0504_BuildSample("'" + ::cYear                                                                     + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0028), RU07R0504_BuildSample("'" + AllTrim(::cCompanyName)                                                     + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0029), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cINN, MAX_LEN_INN)                            + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0030), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cKPP, MAX_LEN_KPP)                            + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0031), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cOGRN, MAX_LEN_OGRN)                          + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0032), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cCompanyPhone, MAX_LEN_PHONE_NUMBER)          + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0033), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cOKVEDCode, MAX_LEN_OCVED)                    + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0034), RU07R0504_BuildSample("'" + ::cAddres + "':" + CRLF + STR0047 + ": '" + AllTrim(::aAddres[2]) + "'; " +        ;
            STR0048 + ": '" + AllTrim(::aAddres[3]) + "'; " + STR0049 + ": '" + AllTrim(::aAddres[4]) + "'; " + STR0050 + ": '" + AllTrim(::aAddres[5]) + "'; " +                 ;
            STR0051 + ": '" + AllTrim(::aAddres[6]) + "'; " + STR0052 + ": '" + AllTrim(::aAddres[7]) + "'; " + STR0053 + ": '" + AllTrim(::aAddres[8]) + "'; " +                 ;
            STR0054 + ": '" + AllTrim(::aAddres[9])                                                                                                                        + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0035), RU07R0504_BuildSample("'" + RU07R0502_MakeDataForReport(::cPageCount, MAX_LEN_PAGES)                    + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0038), RU07R0504_BuildSample("'" + AllTrim(::cNameRespPerson)                                                  + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0039), RU07R0504_BuildSample("'" + PadL(AllTrim(::cCountAverListEmployee), MAX_LEN_AVER_LIST_EMPLOYEE, "-")    + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0040), RU07R0504_BuildSample("'" + PadL(AllTrim(::cCountInvalidEmployee), MAX_LEN_INVALID, "-")                + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0041), RU07R0504_BuildSample("'" + AllTrim(::cCountEOnHarmFactor)                                              + "'")})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0042), RU07R0504_BuildSample("'1'"                                                                                  )})
    AAdd(oJson["table"]["body"], { RU07R0504_BuildSample(STR0043), RU07R0504_BuildSample("'" + cDateReport                                                                 + "'")})

    AAdd(oContent, oJson)

Return lResult
