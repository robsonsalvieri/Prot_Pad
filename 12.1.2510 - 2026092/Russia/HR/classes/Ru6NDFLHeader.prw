#INCLUDE "PROTHEUS.CH"

#Define CHAR_SPACE_CODE 32
#Define CHAR_DASH_CODE 45
#Define CHAR_OPEN_PARENTHESIS_CODE 40
#Define CHAR_CLOSE_PARENTHESIS_CODE 41

/*/
{Protheus.doc} Ru6NDFLHeader
    Class for generating a report header 6-NDFL.

    @type Class
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
/*/
Class Ru6NDFLHeader From LongNameClass
    // Data from filter.
    Data cFilter As Character

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

    Data cPageNumber                As Character // Number of page in format "XXX".
    Data cLiquidationCode           As Character
    Data cINNClosedOrganization     As Character
    Data cKPPClosedOrganization     As Character
    Data cRepresentOrganizationName As Character // Organization name of the representative.
    Data cRepresentDocument         As Character // Name and details of the representative's document.

    Method New(aParameters, cFilter) Constructor

    Method GetCompanyInfo(cTypeCompany, cFilCode)
    Method GetRepresentativeDetails(cPersonnelNumber)
    Method GetClearPhone(cPhone)

    Method MakeData()
EndClass

/*/
{Protheus.doc} New()
    Default Ru6NDFLHeader constructor, 

    @type Method
    @params aParameters, Array,     Array of parameters from pergunte.
    @author vselyakov
    @since 2021/07/06
    @version 12.1.23
    @return Ru6NDFLHeader, Object, Ru6NDFLHeader instance.
    @example ::oHeader := Ru6NDFLHeader():New(::aParameters)
/*/
Method New(aParameters, cFilter) Class Ru6NDFLHeader

    Self:aParameters := AClone(aParameters)
    Self:cFilter := cFilter

    Self:cPageNumber := "001"

    Self:cLiquidationCode := ""
    Self:cINNClosedOrganization := ""
    Self:cKPPClosedOrganization := ""
    Self:cRepresentOrganizationName := ""
    Self:cRepresentDocument := ""

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
    @version 12.1.23
    @return aCompanyInfo, Array, Information about selected company.
    @example ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cFilCode)
/*/
Method GetCompanyInfo(cTypeCompany, cFilCode) Class Ru6NDFLHeader
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

    RestArea(aArea)

Return aCompanyInfo

/*/
{Protheus.doc} GetRepresentativeDetails(cPersonnelNumber)
    The method returns an array with the details of the documents of the tax agent's representative.

    @type Method
    @params cPersonnelNumber, Character, Personnel number of employee.
    @author vselyakov
    @since 2021/07/09
    @version 12.1.23
    @return aDetails, Array, Array with details of employee.
            aDetails[1] - RA_NUMEPAS
            aDetails[2] - RA_UFPAS
            aDetails[3] - RA_DEMIPAS

    @example ::GetRepresentativeDetails("000001")
/*/
Method GetRepresentativeDetails(cPersonnelNumber) Class Ru6NDFLHeader
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
    @version 12.1.23
    @return cClearPhone, Character, Cleared phone number ("84959999999").
    @example ::oHeader:GetClearPhone(cPhoneNumber)
/*/
Method GetClearPhone(cPhone) Class Ru6NDFLHeader
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
    @version 12.1.23
    @return 
    @example ::oHeader:MakeData()
/*/
Method MakeData() Class Ru6NDFLHeader
    Local cTypeCompany    As Character
    Local cFilCode        As Character
    Local cStructUnitCode As Character
    Local cCodeCompany    As Character
    Local aRepresentCompanyInfo As Array // This info about representer company.
    Local aPersonInfo As Character // This info about representer.

    cTypeCompany    := AllTrim(Str(::aParameters[6]))
    cFilCode      := AllTrim(::aParameters[7])

    ::aCompanyInfo := ::GetCompanyInfo(cTypeCompany, cFilCode)

    // Fill properties about company.
    ::cINN          := ::aCompanyInfo[1]
    ::cKPP          := ::aCompanyInfo[2]
    ::cCompanyName  := UPPER(::aCompanyInfo[3])
    ::cIFNSCode     := ::aCompanyInfo[4]
    ::cOKTMO        := ::aCompanyInfo[5]
    ::cCompanyPhone := ::aCompanyInfo[6]

    // Fill properties from parameters.
    ::cPeriod := AllTrim(::aParameters[1])
    ::cYear := AllTrim(::aParameters[8])
    ::cCorrectionNumber := AllTrim(::aParameters[9])
    ::nResponsiblePersonCategory := ::aParameters[3]
    ::cCalculationSubmissionCode := AllTrim(::aParameters[2])
    ::cSigner := AllTrim(::aParameters[5])
    ::cLocationCode := AllTrim(::aParameters[2])

    If ::nResponsiblePersonCategory == 2
        cTypeCompany    := AllTrim(Str(::aParameters[6]))
        cGroupCode      := AllTrim(SubStr(::aParameters[13], 1, 12))
        cStructUnitCode := AllTrim(SubStr(::aParameters[13], 13, 12))
        cCodeCompany    := AllTrim(SubStr(::aParameters[13], 25, 12))

        aRepresentCompanyInfo := ::GetCompanyInfo(cTypeCompany, cGroupCode, cStructUnitCode, cCodeCompany)
        ::cRepresentOrganizationName := UPPER(::aCompanyInfo[3])

        aPersonInfo := ::GetRepresentativeDetails(::aParameters[14])
        ::cRepresentDocument := aPersonInfo[1] + " " + aPersonInfo[2] + " " + aPersonInfo[3]
    EndIf

Return