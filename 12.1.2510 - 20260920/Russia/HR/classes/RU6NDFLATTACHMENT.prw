#INCLUDE "PROTHEUS.CH"

#DEFINE PAYMENT_TYPE_13 "992"
#DEFINE PAYMENT_TYPE_13_2 "675"
#DEFINE PAYMENT_TYPE_15 "993"
#DEFINE PAYMENT_TYPE_STAFF "413"


#DEFINE TAX_DEDUCTION_BUDGET_CODE "675"
#DEFINE NDFL_BUDGET_CODE "413"
#DEFINE NDFL_BUDGET_CODE_ADVANCE "412"

#DEFINE INCOME_PAYMENT_TYPE "1"
#DEFINE NDFL_INCOME_TAX_CALCULATION "S"

#DEFINE NDFL_RATE_13 0.13 // 13%
#DEFINE NDFL_RATE_15 0.15 // 15%
#DEFINE NDFL_RATE_30 0.30 // 30%

// 1. Header
#DEFINE MAX_LEN_REFERENCE_NUMBER 7
#DEFINE MAX_LEN_CORRECTION_NUMBER 2

// 2. Part 1.
#DEFINE MAX_LEN_INN 12
#DEFINE MAX_LEN_NAME 35
#DEFINE MAX_LEN_TAX_AGENT_CODE 1
#DEFINE MAX_LEN_CITIZENSHIP_CODE 3
#DEFINE MAX_LEN_DOCUMENT_TYPE_CODE 2
#DEFINE MAX_LEN_SERIES_AND_NUMBER_DOC 20

#DEFINE COMPANY_INFO_ARRAY_LENGTH 7
#DEFINE COMPANY_INFO_ARRAY_MIN_LENGTH 1
#DEFINE COMPANY_INFO_ARRAY_MAX_LENGTH 3

#DEFINE CO_INDEX_COMPANY 1
#DEFINE COMPANY_CO_INN_INDEX 13 // aGetCoBrRusInfo[1][13][2]
#DEFINE COMPANY_BR_KPP_INDEX 5
#DEFINE COMPANY_BR_FULLNAM_INDEX 6
#DEFINE COMPANY_BR_LOCLTAX_INDEX 8 // IFNS code.
#DEFINE COMPANY_BR_PHONENU_INDEX 9
#DEFINE COMPANY_BR_SHORTNM_INDEX 14
#DEFINE COMPANY_BR_OKTMO_INDEX 22

/*/
{Protheus.doc} RU6NDFLAttachment
    Class for generating a attachment for 6-NDFL report.

    @type Class
    @author vselyakov
    @since 07.07.2023
    @version 12.1.33
/*/
Class RU6NDFLAttachment From LongNameClass
    Data cReferenceNumber         As Character // Reference number.
    Data cCorrectionNumber        As Character // Correction number (specified in the report parameters). Required for 6-NDFL.
    Data cReportYear              As Character // Year (in YYYY format) for which you want to make the report.
    Data cPersonnelNumber         As Character // Personnel number of employee.
    Data cFil                     As Character // Filial.
    Data aPeriods                 As Array // Months of the selected reporting period.

    // Flags for Tax rates.
    Data lRate13                  As Logical   // Is NDFL rate is 13%  - .T.
    Data lRate15                  As Logical   // Is NDFL rate is 15%  - .T.
    Data lRate30                  As Logical   // Is NDFL rate is 30%  - .T.

    // Employee information.
    Data cINN                     As Character // INN of employee.
    Data cSurename                As Character
    Data cName                    As Character
    Data cMiddleName              As Character
    Data cTaxAgentStatusCode      As Character
    Data cBirthday                As Character
    Data cCitizenshipCode         As Character
    Data cDocumentTypeCode        As Character
    Data cSeriesAndNumberDocument As Character

    // Income and taxes.
    Data Block_3                  As Array
    Data Block_4                  As Array
    Data Block_5                  As Array
    Data aIncome13                As Array
    Data aIncome15                As Array
    Data aIncome30                As Array
    Data aAllSumm13               As Array
    Data aAllSumm15               As Array
    Data aAllSumm30               As Array
    Data aAllF6Su13               As Array
    Data aAllF6Su15               As Array
    Data aAllF6Su30               As Array
    Data cDate15                  As Character // RD_PERIODO, where the tax rate goes from 13% to 15%.

    // Tax deductions.
    Data aAllTaxDeductions        As Array // {'RD_PERIODO', 'RD_CONVOC', 'RD_VALOR'}
    Data a13TaxPayments           As Array // {'RD_PERIODO', 'RD_CONVOC', 'RD_VALOR'}
    Data a15TaxPayments           As Array // {'RD_PERIODO', 'RD_CONVOC', 'RD_VALOR'}
    Data a30TaxPayments           As Array // {'RD_PERIODO', 'RD_CONVOC', 'RD_VALOR'}
    Data a13TaxInfo               As Array // {'F5C_DEDCOD', 'F5C_TYPE', 'F5C_DATAIN', 'F5C_CARTOR', 'F5C_LOCLTA'}
    Data a15TaxInfo               As Array // {'F5C_DEDCOD', 'F5C_TYPE', 'F5C_DATAIN', 'F5C_CARTOR', 'F5C_LOCLTA'}
    Data a30TaxInfo               As Array // {'F5C_DEDCOD', 'F5C_TYPE', 'F5C_DATAIN', 'F5C_CARTOR', 'F5C_LOCLTA'}

    // Data for NDFL limits and rates.
    Data aS002Condent As Array
    Data nLimit13 As Numeric


    // Methods.
    Method New(cPersonnelNumber, cReportYear, cCorrectionNumber, cReferenceNumber, aPeriods) Constructor

    Method GetData()
    Method GetHeaderInfo()
    Method GetEmployeeInfo(cFil, cPersonnelNumber)
    Method GetIncome(cFil, cPersonnelNumber, cReportYear)
    Method GetTaxDeductionInfo(cFil, cPersonnelNumber, cReportYear)
    Method GetAllSum(cFil, cPersonnelNumber, cReportYear)
    Method DefineNdflRates(aPeriod)
    Method CollapseIncomeSum(aIncomePayments)

    Method GetSumForNDFL6(cFil, cPersonnelNumber, aPeriod)

EndClass

/*/
{Protheus.doc} New()
    Default RU6NDFLAttachment constructor, 

    @type Method
    @params cPersonnelNumber,  Character, Personnel number of employee.
            cReportYear,       Character, Year for which the report is generated (XXXX, specified in the parameters).
            cCorrectionNumber, Character, Correction number (specified in the report parameters). Required for 6-NDFL.
            cReferenceNumber,  Character, Automatic generation of continuous numbering from 001.
            aPeriods,          Array,     Array of 3 last periods from selected report period in format 'YYYYMM' orderd.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return RU6NDFLAttachment, Object, RU6NDFLAttachment instance.
    @example RU6NDFLAttachment():New("000013")
             RU6NDFLAttachment():New("000013", "2021", ::oHeader:cCorrectionNumber)
/*/
Method New(cPersonnelNumber, cReportYear, cCorrectionNumber, cReferenceNumber, aPeriods) Class RU6NDFLAttachment

    Default cReportYear := SubStr(DToS(Date()), 1, 4)
    Default cCorrectionNumber := "1"

    ::cFil := FwXFilial("SRA") // "102030"
    ::cPersonnelNumber := cPersonnelNumber
    ::cReportYear := cReportYear
    ::cCorrectionNumber := cCorrectionNumber
    ::cReferenceNumber := cReferenceNumber

    ::lRate13 := .F.
    ::lRate15 := .F.
    ::lRate30 := .F.

    ::aPeriods := AClone(aPeriods)

Return Self

/*/
{Protheus.doc} GetData()
    General method for getting data for report.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return 
    @example o2NDFL:GetData()
/*/
Method GetData() Class RU6NDFLAttachment
    Local nI As Numeric

    // Define NDFL limits and rates.
    fCarrTab(@Self:aS002Condent, "S002") // Load data from S002.

    If ValType(Self:aS002Condent) == "A"
        For nI := 1 To Len(Self:aS002Condent)
            If SubStr(Self:aS002Condent[nI][5], 1, 4) == Self:cReportYear .And. SubStr(Self:aS002Condent[nI][6], 1, 4) == Self:cReportYear
                Self:nLimit13 := Self:aS002Condent[nI][8]
            EndIf
        Next nI
    EndIf

    ::DefineNdflRates(::aPeriods) // Check exist payments by rates 13% and 15% into periods.
    ::GetHeaderInfo() // Info about attachment.
    ::GetEmployeeInfo(::cFil, ::cPersonnelNumber) // Info about employee.
    ::GetIncome(::cFil, ::cPersonnelNumber, ::cReportYear) // Calculation of income at a rate.
    ::GetTaxDeductionInfo(::cFil, ::cPersonnelNumber, ::cReportYear) // Calculation of tax deduction.
    ::GetAllSum(::cFil, ::cPersonnelNumber, ::cReportYear) // Total income and tax amounts.
    ::GetSumForNDFL6(::cFil, ::cPersonnelNumber) // Get sums for NDFL6

Return

/*/
{Protheus.doc} GetHeaderInfo()
    The method fills in the "Reference number" and "Information correction number" data.

    @type Method
    @params 
    @author vselyakov
    @since 2021/07/13
    @version 12.1.23
    @return 
    @example ::GetHeaderInfo()
/*/
Method GetHeaderInfo() Class RU6NDFLAttachment
    ::cReferenceNumber := Padl(::cReferenceNumber, MAX_LEN_REFERENCE_NUMBER, "0")
    ::cCorrectionNumber := Padr(AllTrim(::cCorrectionNumber), MAX_LEN_CORRECTION_NUMBER, "-")
Return

/*/
{Protheus.doc} GetEmployeeInfo(cFil, cPersonnelNumber)
    The method collects information about the specified employee.

    @type Method
    @params cFil,             Character, Filial code of employee.
            cPersonnelNumber, Character, Employee personnel number.
    @author vselyakov
    @since 2021/07/13
    @version 12.1.23
    @return 
    @example ::GetEmployeeInfo(::cFil, ::cPersonnelNumber)
/*/
Method GetEmployeeInfo(cFil, cPersonnelNumber) Class RU6NDFLAttachment
    Local oStatement    As Object
    Local cQuery        As Character 
    Local aArea         As Array
    Local cTab          As Character
    Local cRA_CLASEST   As Character

    Default cFil := ::cFil
    Default cPersonnelNumber := ::cPersonnelNumber
    
    aArea := GetArea()

    cQuery := " SELECT RA_PIS, RA_PRISOBR, RA_PRINOME, RA_SECNOME, RA_CLASEST, RA_NASC, RA_NACIONC, RA_FICHA, RA_NUMEPAS FROM " + RetSqlName("SRA")
    cQuery += " WHERE  "
    cQuery += " RA_FILIAL = ? "
    cQuery += " AND RA_MAT = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    If FwIsInCallStack("RU07R04")
        ::cINN := AlLTrim((cTab)->RA_PIS)
        ::cSurename := AllTrim(Upper((cTab)->RA_PRISOBR))
        ::cName := AllTrim(Upper((cTab)->RA_PRINOME))
        ::cMiddleName :=AllTrim(Upper((cTab)->RA_SECNOME))
    Else
        ::cINN := Padr(AlLTrim((cTab)->RA_PIS), MAX_LEN_INN, "-")
        ::cSurename := Padr(AllTrim(Upper((cTab)->RA_PRISOBR)), MAX_LEN_NAME, "-")
        ::cName := Padr(AllTrim(Upper((cTab)->RA_PRINOME)), MAX_LEN_NAME, "-")
        ::cMiddleName := Padr(AllTrim(Upper((cTab)->RA_SECNOME)), MAX_LEN_NAME, "-")
    EndIf

    cRA_CLASEST := AllTrim((cTab)->RA_CLASEST)

    If FwIsInCallStack("RU07R04")
        ::cCitizenshipCode := AllTrim((cTab)->RA_NACIONC)
        ::cDocumentTypeCode := AllTrim((cTab)->RA_FICHA)
        ::cSeriesAndNumberDocument := AllTrim((cTab)->RA_NUMEPAS)
    Else
        ::cCitizenshipCode := Padr(AllTrim((cTab)->RA_NACIONC), MAX_LEN_CITIZENSHIP_CODE, "-")
        ::cDocumentTypeCode := Padr(AllTrim((cTab)->RA_FICHA), MAX_LEN_DOCUMENT_TYPE_CODE, "-")
        ::cSeriesAndNumberDocument := Padr(AllTrim((cTab)->RA_NUMEPAS), MAX_LEN_SERIES_AND_NUMBER_DOC, "-")
    EndIf

    ::cBirthday := (cTab)->RA_NASC

    // Tax Agent Status Code.
    If Empty(cRA_CLASEST) .Or. cRA_CLASEST $ "01*02*05*06"
        ::cTaxAgentStatusCode := "1"
    ElseIf cRA_CLASEST $ "08*09*10"
        ::cTaxAgentStatusCode := "3"
    ElseIf cRA_CLASEST $ "03*04"
        ::cTaxAgentStatusCode := "5"
    ElseIf cRA_CLASEST == '07'
        ::cTaxAgentStatusCode := "6"
    Else
        ::cTaxAgentStatusCode := ""
    EndIf

    // If not a resident, then the rate is only 30%.
    If cRA_CLASEST == "05" .Or. cRA_CLASEST == "02"
        ::lRate30 := .T.
        ::lRate13 := .F.
        ::lRate15 := .F.
    Endif

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return

/*/
{Protheus.doc} GetIncome(cFil, cPersonnelNumber, cReportYear)
    The method collects income data for different rates.

    @type Method
    @params cFil,             Character, Filial code of employee.
            cPersonnelNumber, Character, Employee personnel number.
            cReportYear,      Character, Year (in YYYY format) for which you want to make the report.
    @author iprokhorenko
    @since 2021/07/13
    @version 12.1.23
    @return 
    @example ::GetIncome(::cFil, ::cPersonnelNumber, ::cReportYear)
/*/
Method GetIncome(cFil, cPersonnelNumber, cReportYear) Class RU6NDFLAttachment
    Local oStatement As Object
    Local cQuery     As Character 
    Local aArea      As Array
    Local cTab       As Character
    Local aIncome    As Array
    Local cAliasTM3  As Char 
    Local nCount     As Numeric
    Local aTmp1      As Array
    Local aTmp2      As Array
    Local nAllSum    As Numeric

    Default cFil := ::cFil
    Default cPersonnelNumber := ::cPersonnelNumber
    Default cReportYear := ::cReportYear

    aArea := GetArea()

    cQuery := " SELECT B.RV_INCIRF, A.RD_CONVOC, C.CODE, B.RV_COD, B.RV_NATUREZ, A.RD_VALOR, A.RD_PERIODO, D.DCODE, "
    cQuery += " (CASE WHEN D.DCODE <> '' THEN A.RD_VALOR * 1 ELSE 0 END) AS COL_NAME FROM " + RetSqlName("SRD") + " A "
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SRV") + " B ON A.RD_PD = B.RV_COD "
    cQuery += " LEFT OUTER JOIN (SELECT RIGHT(LEFT(RCC_CONTEU,15),3) AS CODE FROM " + RetSqlName("RCC") + " WHERE RCC_CODIGO ='S210') C ON C.CODE = TRIM(A.RD_CONVOC) "
    cQuery += " LEFT OUTER JOIN (SELECT RIGHT(LEFT(RCC_CONTEU,15),3) AS DCODE FROM " + RetSqlName("RCC") + "  WHERE RCC_CODIGO ='S210') D ON D.DCODE = TRIM(B.RV_INCIRF) "
    cQuery += " WHERE "
    cQuery += " A.RD_FILIAL = ? "
    cQuery += " AND A.RD_MAT = ? "
    cQuery += " AND A.RD_PERIODO IN (?) "
    cQuery += " AND B.D_E_L_E_T_ = ' ' "
    cQuery += " AND A.RD_ROTEIR = 'FOL' "
	cQuery += " AND B.RV_TIPOCOD = '1' "
    cQuery += " AND A.RD_CONVOC <> '' "
    cQuery += " GROUP BY B.RV_INCIRF, A.RD_CONVOC, C.CODE, B.RV_COD, B.RV_NATUREZ, A.RD_VALOR, A.RD_PERIODO, D.DCODE "
    cQuery += " ORDER BY A.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)
    oStatement:SetIn(3, ::aPeriods)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    ::Block_3 := {}
    aIncome :={}

    (cTab)->(dbGotop())
    While (cTab)->(!EOF())
        AAdd(aIncome, {Alltrim((cTab)->RV_INCIRF), ;
                       Alltrim((cTab)->RD_CONVOC), ;
                       Alltrim((cTab)->CODE), ;
                       Alltrim((cTab)->RV_COD), ;
                       Alltrim((cTab)->RD_PERIODO), ;
                       Alltrim((cTab)->RV_NATUREZ), ;
                       (cTab)->RD_VALOR, ;
                       Alltrim((cTab)->DCODE), ;
                       (cTab)->COL_NAME};
         )
        (cTab)->(dbSkip())
    EndDo

    ::Block_3 := AClone(aIncome)

    If !::lRate30
        For nCount := 1 To Len(aIncome)
            
            // aIncome[nCount, 2] - RD_CONVOC, Determines the personal income tax rate (13% or 15%).
            If aIncome[nCount, 2] == "13" // Personal income tax rate - 13%.
                ::lRate13 := .T.
            EndIf

            If aIncome[nCount, 2] == "15" // Personal income tax rate - 15%.
                ::lRate15 := .T.
                ::cDate15 := aIncome[nCount, 5]
                Exit // If we find a first rate change we ending search.
            EndIf
            
        Next nCount
    Endif
    
    aIncome := {}

    cQuery := " SELECT B.RV_NATUREZ, (A.RD_VALOR) AS RD_VALOR, A.RD_PERIODO, D.DCODE "
    cQuery += " , CASE WHEN D.DCODE <> '' THEN A.RD_VALOR * 1 ELSE 0 END AS COL_NAME FROM " 
    cQuery += RetSqlName("SRD") + " A"
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SRV") + " B ON A.RD_PD = B.RV_COD "
    cQuery += " LEFT OUTER JOIN (SELECT RIGHT(LEFT(RCC_CONTEU,15),3) AS CODE FROM " + RetSqlName("RCC") + " WHERE RCC_CODIGO ='S210') C ON C.CODE = TRIM(A.RD_CONVOC) "
    cQuery += " LEFT OUTER JOIN (SELECT RIGHT(LEFT(RCC_CONTEU,15),3) AS DCODE FROM " + RetSqlName("RCC") + " WHERE RCC_CODIGO ='S210') D ON D.DCODE = TRIM(B.RV_INCIRF) "
    cQuery += " WHERE "
    cQuery += " A.RD_FILIAL = ? "
    cQuery += " AND A.RD_MAT = ? "
    cQuery += " AND A.RD_PERIODO IN (?) "
    cQuery += " AND B.D_E_L_E_T_ = ' ' "
    cQuery += " AND C.CODE IS NULL "
    cQuery += " AND B.RV_NATUREZ <> '    ' "
    cQuery += " AND A.RD_CONVOC <> '      ' "
    cQuery += " AND B.RV_IR = ? "
    cQuery += " AND B.RV_TIPOCOD = ? "
    cQuery += " AND A.RD_ROTEIR = 'FOL' "
    cQuery += " GROUP BY B.RV_NATUREZ, A.RD_PERIODO, A.RD_VALOR, A.RD_PERIODO, D.DCODE, A.RD_CONVOC "
    cQuery += " ORDER BY A.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)
    oStatement:SetIn(3, ::aPeriods)
    
    oStatement:SetString(4, NDFL_INCOME_TAX_CALCULATION)
    oStatement:SetString(5, INCOME_PAYMENT_TYPE)

    cAliasTM3 := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cAliasTM3)
    (cAliasTM3)->(dbGotop())

    While (cAliasTM3)->(!EOF())
        AAdd(aIncome, {Alltrim((cAliasTM3)->RD_PERIODO), Alltrim((cAliasTM3)->RV_NATUREZ),;
            (cAliasTM3)->RD_VALOR, Alltrim((cAliasTM3)->DCODE), (cAliasTM3)->COL_NAME};
        )
        (cAliasTM3)->(dbSkip())
    EndDo
    
    If ::lRate13 .And. ::lRate15
        aTmp1 := {}
        aTmp2 := {}
        nAllSum := 0

        For nCount := 1 To Len(aIncome)
            
            If aIncome[nCount, 1] == ::cDate15
                If nAllSum + aIncome[nCount, 3] > Self:nLimit13
                    nAllSum := nAllSum + aIncome[nCount, 3] - Self:nLimit13
                    aIncome[nCount, 3] := aIncome[nCount, 3] - nAllSum
                    AAdd(aTmp1, aIncome[nCount])
                    ::aIncome13 := AClone(aTmp1)
                    aIncome[nCount, 3] := nAllSum
                    aIncome[nCount, 4] := ''
                    aIncome[nCount, 5] := 0
                    
                    aTmp1 := {}
                    AAdd(aTmp1, aIncome[nCount])
                Else
                    AAdd(aTmp1, aIncome[nCount])
                Endif
            Else
                AAdd(aTmp1, aIncome[nCount])
            EndIf
            nAllSum += aIncome[nCount, 3]
        Next nCount
        ::aIncome15 := AClone(aTmp1)
    Else
        If ::lRate30
            ::aIncome30 := AClone(aIncome)
        Elseif ::lRate13
            ::aIncome13 := AClone(aIncome)
        Elseif ::lRate15
            ::aIncome15 := AClone(aIncome)
        EndIf
    EndIf

    // Collapsing the amounts for one revenue code for Self:aIncome13.
    If Self:aIncome13 <> Nil
        Self:aIncome13 := Self:CollapseIncomeSum(Self:aIncome13) // Collapsing the amounts for one revenue code for Self:aIncome13.
    EndIf

    If Self:aIncome15 <> Nil
        Self:aIncome15 := Self:CollapseIncomeSum(Self:aIncome15) // Collapsing the amounts for one revenue code for Self:aIncome15.
    EndIf

    If Self:aIncome30 <> Nil
        Self:aIncome30 := Self:CollapseIncomeSum(Self:aIncome30) // Collapsing the amounts for one revenue code for Self:aIncome30.
    EndIf


    RestArea(aArea)

Return

/*/
{Protheus.doc} GetTaxDeductionInfo(cFil, cPersonnelNumber, cReportYear)
    The method fills in the necessary data on tax deductions 
    for the specified employee in the 2-NDFL and 6-NDFL certificates.

    For 6-NDFL, it also records information about tax deductions.

    @type Method
    @params cFil,             Character, Filial code of employee.
            cPersonnelNumber, Character, Employee personnel number.
            cReportYear,      Character, Year (in YYYY format) for which you want to make the report.
    @author vselyakov
    @since 2021/07/16
    @version 12.1.23
    @return 
    @example ::GetTaxDeductionInfo(::cFil, ::cPersonnelNumber)
/*/
Method GetTaxDeductionInfo(cFil, cPersonnelNumber, cReportYear) Class RU6NDFLAttachment
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local nPostion     As Numeric
    Local nHalfPayment As Numeric
    Local cRD_PERIODO  As Character
    Local cRD_CONVOC   As Character
    Local nRD_VALOR    As Numeric
    Local aF5C_DEDCOD  As Array

    Default cFil := ::cFil
    Default cPersonnelNumber := ::cPersonnelNumber
    Default cReportYear := ::cReportYear

    aArea := GetArea()

    ::aAllTaxDeductions := {}
    ::a30TaxPayments := {}
    ::a15TaxPayments := {}
    ::a13TaxPayments := {}
    ::a13TaxInfo := {}
    ::a15TaxInfo := {}
    ::a30TaxInfo := {}
    aF5C_DEDCOD := {}

    cQuery := " SELECT A.RD_PERIODO, A.RD_CONVOC, A.RD_VALOR FROM " + RetSqlName("SRD") + " A "
    cQuery += " LEFT OUTER JOIN " + RetSqlName("SRV") + " B ON A.RD_PD = B.RV_COD "
    cQuery += " LEFT OUTER JOIN (SELECT RIGHT(LEFT(RCC_CONTEU,15),3) AS CODE FROM " + RetSqlName("RCC") + " WHERE RCC_CODIGO ='S210') C ON C.CODE = TRIM(A.RD_CONVOC) "
    cQuery += " WHERE "
    cQuery += " A.RD_FILIAL = ? "
    cQuery += " AND A.RD_MAT = ? "
    cQuery += " AND A.RD_PERIODO IN (?) "
    cQuery += " AND A.RD_CONVOC <> '      ' "
    cQuery += " AND A.D_E_L_E_T_ = ' ' "
    cQuery += " AND B.D_E_L_E_T_ = ' ' "
    cQuery += " AND C.CODE IS NOT NULL "
    cQuery += " GROUP BY A.RD_PERIODO, A.RD_CONVOC, A.RD_VALOR, A.RD_MAT, A.RD_PD "
    cQuery += " ORDER BY A.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)
    oStatement:SetIn(3, ::aPeriods)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        cRD_PERIODO := AllTrim((cTab)->RD_PERIODO)
        cRD_CONVOC := AllTrim((cTab)->RD_CONVOC)
        nRD_VALOR := (cTab)->RD_VALOR

        aAdd(::aAllTaxDeductions, { cRD_PERIODO, cRD_CONVOC, nRD_VALOR })
        aAdd(aF5C_DEDCOD, cRD_CONVOC)

        
        nPostion := Iif(Len(::a13TaxPayments) > 0, aScan(::a13TaxPayments, {|x| x[2] == cRD_CONVOC }), 0)

        If (nPostion > 0)
            ::a13TaxPayments[nPostion][3] += (cTab)->RD_VALOR
        Else
            aAdd(::a13TaxPayments, { cRD_PERIODO, cRD_CONVOC, nRD_VALOR })
        EndIf

        (cTab)->(DBSkip())
    EndDo

    // Get information about tax deductions from report period.
    cQuery := " SELECT F5C.F5C_DEDCOD, F5C.F5C_TYPE, F5C.F5C_DATAIN, F5C.F5C_CARTOR, F5C.F5C_LOCLTA FROM " + RetSqlName("F5D") + " F5D "
    cQuery += " LEFT JOIN " + RetSqlName("F5C") + " F5C ON F5C.F5C_COD = F5D.F5D_COD "
    cQuery += " WHERE "
    cQuery += " F5D.F5D_FILIAL = ? "
    cQuery += " AND F5D.F5D_MAT = ? "
    cQuery += " AND F5D.F5D_DEDCOD IN (?) "
    cQuery += " AND F5D.F5D_PER IN (?) "
    cQuery += " AND F5D.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY F5C.F5C_DEDCOD, F5D.F5D_COD, F5C.F5C_TYPE, F5C.F5C_DATAIN, F5C.F5C_CARTOR, F5C.F5C_LOCLTA "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FwXFilial("F5D"))
    oStatement:SetString(2, ::cPersonnelNumber)
    oStatement:SetIn(3, aF5C_DEDCOD)
    oStatement:SetIn(4, ::aPeriods)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !(cTab)->(Eof())
        
        aAdd(::a13TaxInfo, { (cTab)->F5C_DEDCOD, (cTab)->F5C_TYPE, SToD((cTab)->F5C_DATAIN), AllTrim((cTab)->F5C_CARTOR), AllTrim((cTab)->F5C_LOCLTA) })

        (cTab)->(DBSkip())
    EndDo

    DBCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return 

/*/
{Protheus.doc} GetAllSum(cFil, cPersonnelNumber, cReportYear)
    Calculation Total income and tax amounts.

    @type Method
    @params cFil,             Character, Filial code of employee.
            cPersonnelNumber, Character, Employee personnel number.
            cReportYear,      Character, Year (in YYYY format) for which you want to make the report.
    @author iprokhorenko
    @since 2021/07/16
    @version 12.1.23
    @return 
    @example ::GetAllSum(::cFil, ::cPersonnelNumber, ::cReportYear)
/*/
Method GetAllSum(cFil, cPersonnelNumber, cReportYear) Class RU6NDFLAttachment
    Local oStatement As Object
    Local aTmp       As Array
    Local aTmp1      As Array
    Local aTmp2      As Array
    Local nCount     As Numeric
    Local cQuery     As Character
    Local cAliasTM5  As Character
    Local aArea      As Array
    Local nAllSum    As Numeric

    Default cFil := ::cFil
    Default cPersonnelNumber := ::cPersonnelNumber
    Default cReportYear := ::cReportYear

    aArea := GetArea()

    aTmp := {}
    aTmp1 := {}
    aTmp2 := {}

    For nCount := 1 To 8
        AAdd(aTmp1, 0)
    Next nCount

    aTmp2 := aClone(aTmp1)

    cQuery := " SELECT RD_PERIODO, RD_VALOR AS SUMM, RD_HORAS FROM " + RetSqlName("SRD")
    cQuery += " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND RD_PERIODO IN (?) "
    cQuery += " AND RD_PD IN (?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cFil)
    oStatement:SetString(2, cPersonnelNumber)
    
    oStatement:SetIn(3, ::aPeriods)

    // Changed by RULOC-5114. Added advance NDFL code.
    oStatement:SetIn(4, {NDFL_BUDGET_CODE, NDFL_BUDGET_CODE_ADVANCE})

    cAliasTM5 := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cAliasTM5)
    (cAliasTM5)->(DbGoTop())

    While (cAliasTM5)->(!EOF())
        AAdd(aTmp, {Alltrim((cAliasTM5)->RD_PERIODO), (cAliasTM5)->SUMM, AllTrim(CValToChar((cAliasTM5)->RD_HORAS))})

        (cAliasTM5)->(dbSkip())
    EndDo

    (cAliasTM5)->(dbCloseArea())

    If ::lRate30
        For nCount := 1 To Len(aTmp)
            aTmp1[3] += aTmp[nCount, 2]
            aTmp1[5] += aTmp[nCount, 2]
            aTmp1[6] += aTmp[nCount, 2]
        Next nCount

        If (::aIncome30 <> Nil)
            For nCount := 1 To Len(::aIncome30)
                aTmp1[1] += ::aIncome30[nCount, 3]
                aTmp1[2] += ::aIncome30[nCount, 3] - ::aIncome30[nCount, 5]
            Next nCount
        EndIf

        If (::a30TaxPayments <> Nil)
            For nCount := 1 To Len(::a30TaxPayments)
                aTmp1[2] := aTmp1[2] - ::a30TaxPayments[nCount, 3]
            Next nCount
        EndIf

        ::aAllSumm30 := aClone(aTmp1)
        ::aAllSumm30[3] := ::aAllSumm30[2] * NDFL_RATE_30
        ::aAllSumm30[7] := ::aAllSumm30[5] - ::aAllSumm30[3]
    Else
        If (::aIncome13 <> Nil)
            For nCount := 1 To Len(::aIncome13)
                aTmp1[1] += ::aIncome13[nCount, 3]
                aTmp1[2] += ::aIncome13[nCount, 3] - ::aIncome13[nCount, 5]
            Next nCount
        EndIf

        If (::a13TaxPayments <> Nil)
            For nCount := 1 To Len(::a13TaxPayments)
                aTmp1[2] := aTmp1[2] - ::a13TaxPayments[nCount, 3]
            Next nCount
        EndIf
        
        If (::aIncome15 <> Nil)
            For nCount := 1 To Len(::aIncome15)
                aTmp2[1] += ::aIncome15[nCount, 3]
                aTmp2[2] += ::aIncome15[nCount, 3] - ::aIncome15[nCount, 5]
            Next nCount
        EndIf

        If (::a15TaxPayments <> Nil)
            For nCount := 1 To Len(::a15TaxPayments)
                aTmp2[2] := aTmp2[2] - ::a15TaxPayments[nCount, 3]
            Next nCount
        EndIf

        nAllSum := 0

        If ::lRate13 .And. ::lRate15
            
            For nCount := 1 To Len(aTmp)
                // aTmp[nCount, 3] - RD_CONVOC, Determines the personal income tax rate (13% or 15%).
                If aTmp[nCount, 3] == "13" // Personal income tax rate - 13%.
                    nAllSum += aTmp[nCount, 2]
                    aTmp1[3] := aTmp1[3] + aTmp[nCount, 2]
                    aTmp1[5] := aTmp1[5] + aTmp[nCount, 2]
                    aTmp1[6] := aTmp1[6] + aTmp[nCount, 2]
                    ::aAllSumm13 := AClone(aTmp1)
                    ::aAllSumm13[3] := ::aAllSumm13[2] * NDFL_RATE_13
                Else
                     // Personal income tax rate - 15%.
                    nAllSum += aTmp[nCount, 2]
                    aTmp2[3] := aTmp2[3] + aTmp[nCount, 2]
                    aTmp2[5] := aTmp2[5] + aTmp[nCount, 2]
                    aTmp2[6] := aTmp2[6] + aTmp[nCount, 2]
                    ::aAllSumm15 := AClone(aTmp2)
                    ::aAllSumm15[3] := ::aAllSumm15[2] * NDFL_RATE_15
                EndIf

                /* WARNING!!!
                 * The commented out piece of code should be left in case 
                 * the current changes cause errors in other places in the reports.
                 *
                 * TODO: When 
                */
                // if aTmp[nCount, 1] == ::cDate15
                //     nAllSum := nAllSum + aTmp[nCount, 2] / 2
                //     aTmp1[3] := nAllSum
                //     aTmp1[5] := nAllSum
                //     aTmp1[6] := nAllSum
                //     ::aAllSumm13 := AClone(aTmp1)
                //     ::aAllSumm13[3] := ::aAllSumm13[2] * NDFL_RATE_13
                //     nAllSum := aTmp[nCount, 2]
                // else
                //     nAllSum += aTmp[nCount, 2]
                // endif
                // aTmp2[3] := nAllSum
                // aTmp2[5] := nAllSum
                // aTmp2[6] := nAllSum
                // ::aAllSumm15 := AClone(aTmp2)
                // ::aAllSumm15[3] := ::aAllSumm15[2] * NDFL_RATE_15
            Next nCount

        ElseIf ::lRate13
            For nCount := 1 To Len(aTmp)
                aTmp1[3] += aTmp[nCount, 2]
                aTmp1[5] += aTmp[nCount, 2]
                aTmp1[6] += aTmp[nCount, 2]
            Next nCount
            ::aAllSumm13 := AClone(aTmp1)
            ::aAllSumm13[3] := ::aAllSumm13[2] * NDFL_RATE_13
            ::aAllSumm13[7] := ::aAllSumm13[5] - ::aAllSumm13[3]
        ElseIf ::lRate15
            For nCount := 1 To Len(aTmp)
                aTmp2[3] += aTmp[nCount, 2]
                aTmp2[5] += aTmp[nCount, 2]
                aTmp2[6] += aTmp[nCount, 2]
            Next nCount
            ::aAllSumm15 := AClone(aTmp2)
            ::aAllSumm15[3] := ::aAllSumm15[2] * NDFL_RATE_15
            ::aAllSumm15[7] := ::aAllSumm15[5] - ::aAllSumm15[3]
        EndIf
    EndIf

    RestArea(aArea)

Return

/*/
{Protheus.doc} GetSumForNDFL6(cFil, cPersonnelNumber)
    Calculation summ for NDFL6.

    @type Method
    @params cFil,             Character, Filial code of employee.
            cPersonnelNumber, Character, Employee personnel number.
    @author dchizhov
    @since 2023/06/05
    @version 12.1.33
    @return 
    @example ::GetSumForNDFL6(::cFil, ::cPersonnelNumber)
/*/
Method GetSumForNDFL6(cFil, cPersonnelNumber) Class RU6NDFLAttachment
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character
    Local aArrayPeriod As Array
    Local aArea        As Array

    Default cFil := ::cFil
    Default cPersonnelNumber := ::cPersonnelNumber
    ::aAllF6Su13 := Array(2)
    ::aAllF6Su15 := Array(2)
    ::aAllF6Su30 := Array(2)
    AFill(::aAllF6Su13, 0)
    AFill(::aAllF6Su15, 0)
    AFill(::aAllF6Su30, 0)
    aArea := GetArea()

    cQuery := " SELECT MAX(RD_PERIODO) AS PER, RD_MAT, RD_PD FROM " +  RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_ROTEIR = 'FOL' "
    cQuery += " AND RD_PERIODO in (?) "
    cQuery += " AND RD_PD in (?) "
    cQuery += " AND RD_MAT = ? "

    cQuery += " AND D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY RD_PD, RD_MAT, RD_PD "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, ::aPeriods)
    oStatement:SetIn(3, {PAYMENT_TYPE_13, PAYMENT_TYPE_15, PAYMENT_TYPE_STAFF})
    oStatement:SetString(4, cPersonnelNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())
    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    aArrayPeriod := {}
    While !(cTab)->(Eof())
        Aadd(aArrayPeriod, PadR((cTab)->PER, GetSX3Cache("RD_PERIODO", "X3_TAMANHO"), " ") + PadR((cTab)->RD_MAT, GetSX3Cache("RD_MAT", "X3_TAMANHO"), " ") + ;
        PadR((cTab)->RD_PD, GetSX3Cache("RD_PD", "X3_TAMANHO"), " "))
        (cTab)->(DBSkip())
    EndDo
    (cTab)->(DBCloseArea())
    // Get sum of income tax amount.
    cQuery := " SELECT SUM(SRD.RD_VALOR) AS TOTAL, SRD.RD_PD, ST.STAFF FROM " +  RetSQLName("SRD") + " SRD "
    cQuery += " LEFT OUTER JOIN (SELECT MAX(S.RD_HORAS) AS STAFF, S.RD_MAT AS MAT FROM " + RetSQLName("SRD")
    cQuery += " S WHERE CONCAT(S.RD_PERIODO, S.RD_MAT, S.RD_PD) IN (?) AND S.RD_PD = ? GROUP BY RD_MAT) AS ST ON ST.MAT = RD_MAT WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' "
    cQuery += " AND (CONCAT(SRD.RD_PERIODO, SRD.RD_MAT, SRD.RD_PD) in (?) "
    cQuery += " OR (SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRD.RD_PD in (?))) "
    cQuery += " AND SRD.RD_MAT = ? "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PD, ST.STAFF "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetIn(1, aArrayPeriod)
    oStatement:SetString(2, PAYMENT_TYPE_STAFF)
    oStatement:SetString(3, FWxFilial("SRD"))
    oStatement:SetIn(4, aArrayPeriod)
    oStatement:SetIn(5, ::aPeriods)
    oStatement:SetIn(6, {PAYMENT_TYPE_13_2})
    oStatement:SetString(7, cPersonnelNumber)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())

    nTotalPayment := 0

    While !(cTab)->(Eof())
        If ::lRate13
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2
                ::aAllF6Su13[1] += (cTab)->TOTAL
            EndIf
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13
                ::aAllF6Su13[2] += (cTab)->TOTAL
            EndIf
        EndIf
        If ::lRate15
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15
                ::aAllF6Su15[1] += (cTab)->TOTAL
                ::aAllF6Su15[2] += (cTab)->TOTAL
            EndIf
        EndIf
        If ::lRate30 .And. (cTab)->STAFF == 30 .And. (Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13_2 ;
            .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15)
            ::aAllF6Su30[1] += (cTab)->TOTAL
            If Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_13 .Or. Alltrim((cTab)->RD_PD) == PAYMENT_TYPE_15
                ::aAllF6Su30[2] += (cTab)->TOTAL
            EndIf
        EndIf
        (cTab)->(DBSkip())
    EndDo

    (cTab)->(DBCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    If ::lRate13
        If Empty(::aAllSumm13)
            ::aAllSumm13 := {0, 0, 0, 0, 0, 0, 0, 0}
        EndIf
        ::aAllSumm13[3] := ::aAllF6Su13[2] * NDFL_RATE_13
        ::aAllSumm13[7] := ::aAllSumm13[5] - ::aAllSumm13[3]
    EndIf
    If ::lRate15
        If Empty(::aAllSumm15)
            ::aAllSumm15 := {0, 0, 0, 0, 0, 0, 0, 0}
        EndIf
        ::aAllSumm15[3] := ::aAllF6Su15[2] * NDFL_RATE_15
        ::aAllSumm15[7] := ::aAllSumm15[5] - ::aAllSumm15[3]
    EndIf
    If ::lRate30 
        If Empty(::aAllSumm30)
            ::aAllSumm30 := {0, 0, 0, 0, 0, 0, 0, 0}
        EndIf
        ::aAllSumm30[3] := ::aAllF6Su30[2] * NDFL_RATE_30
        ::aAllSumm30[7] := ::aAllSumm30[5] - ::aAllSumm30[3]
    EndIf

    RestArea(aArea)

Return

/*/
{Protheus.doc} DefineNdflRates(aPeriod)
    Fill ::lRate13 and ::lRate15 from SRD by input periods array.

    Function execute SQL-query into SRD table on input periods 
    and looking for availability of payments for personal income tax at 13% and 15%.


    @type Method
    @params aPeriod, Array, Array of periods in format 'YYYYMM' ordered.
    @author vselyakov
    @since 24.02.2022
    @version 12.1.33
    @return 
    @example ::DefineNdflRates(::aLastMonth)
             ::DefineNdflRates(::aPeriods)
/*/
Method DefineNdflRates(aPeriod) Class RU6NDFLAttachment
    Local oStatement   As Object
    Local cQuery       As Character 
    Local aArea        As Array
    Local cTab         As Character
    Local aS002Lines   As Array
    Local nNdflLimit   As Numeric
    Local nI           As Numeric
    Local nTotalSum    As Numeric

    aArea := GetArea()
    aFirstParts := {}
    ::lRate13 := .F.
    ::lRate15 := .F.
    aS002Lines := {}
    nNdflLimit := 0
    nTotalSum := 0

    // Get data from S002 and define limit summ for 13% rate.
    fCarrTab(@aS002Lines, "S002")
    For nI := 1 To Len(aS002Lines)
        If (SubStr(aS002Lines[nI][5], 1, 4) == ::cReportYear)
            nNdflLimit := aS002Lines[nI][8]
        EndIf
    Next nI

    // Get payd sum from SRD to define rates.
    cQuery := " SELECT SRD.RD_PERIODO AS SRDPERIOD, SUM(SRD.RD_VALOR) AS TOTALSUM  FROM " +  RetSQLName("SRD") + " SRD "
    cQuery += " LEFT JOIN " + RetSqlName("SRV") + " SRV ON SRV.RV_COD = SRD.RD_PD "
    cQuery += " WHERE "
    cQuery += " SRD.RD_FILIAL = ? "
    cQuery += " AND SRD.RD_PERIODO IN (?) "
    cQuery += " AND SRV.RV_IR = 'S' " // These types of payments are subject to NDFL.
    cQuery += " AND SRD.RD_MAT = ? "
    cQuery += " AND SRD.RD_ROTEIR = 'FOL' " // Payment only FOL scenario.
    cQuery += " AND SRV.RV_TIPOCOD = ? "
    cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
    cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY SRD.RD_PERIODO "
    cQuery += " ORDER BY SRD.RD_PERIODO "

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SRD"))
    oStatement:SetIn(2, Self:aPeriods)
    oStatement:SetString(3, ::cPersonnelNumber)
    oStatement:SetString(4, INCOME_PAYMENT_TYPE)

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    // Define NDFL rates.
    While (cTab)->(!Eof())
        nTotalSum := nTotalSum + (cTab)->TOTALSUM

        If nTotalSum > nNdflLimit
            Self:lRate13 := .T.
            Self:lRate15 := .T.
            Self:cDate15 := (cTab)->SRDPERIOD

            Exit
        Else
            Self:lRate13 := .T.
        EndIf

        (cTab)->(DbSkip())
    EndDo

    DbCloseArea()
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)
Return

/*/
{Protheus.doc} CollapseIncomeSum(aIncomePayments)
    The method combines the amounts of income by period by income code

    @type Method
    @params aIncomePayments, Array, Array income payments.
    @author vselyakov
    @since 21.03.2023
    @version 12.1.33
    @return aTmpIncome, Array, Collapsed income payments.
    @example Self:aIncome13 := Self:CollapseIncomeSum(Self:aIncome13
/*/
Method CollapseIncomeSum(aIncomePayments) Class RU6NDFLAttachment
    Local nI As Numeric
    Local nJ As Numeric
    Local aTmpIncome As Array
    Local lIsUpdated As Logical

    aTmpIncome := {}

    // Collapsing the amounts for one revenue code for aIncomePayments.
    For nI := 1 To Len(aIncomePayments)
        lIsUpdated := .F.
        
        If Len(aTmpIncome) > 0
            For nJ := 1 To Len(aTmpIncome)
                If aIncomePayments[nI][1] == aTmpIncome[nJ][1] .And. aIncomePayments[nI][2] == aTmpIncome[nJ][2] .And. aIncomePayments[nI][4] == aTmpIncome[nJ][4]
                    aTmpIncome[nJ][3] := aTmpIncome[nJ][3] + aIncomePayments[nI][3]
                    aTmpIncome[nJ][5] := aTmpIncome[nJ][5] + aIncomePayments[nI][5]
                    lIsUpdated := .T.
                EndIf
            Next nJ

            If !lIsUpdated
                aAdd(aTmpIncome, aIncomePayments[nI])
            EndIf
        Else
            aAdd(aTmpIncome, aIncomePayments[nI])
        EndIf
    Next nI

Return aTmpIncome
