#Include "PROTHEUS.CH"

#Define PAYMENT_DAYS_BY_COMPANY 3

/*/
{Protheus.doc} RUAbsenceModel
    Class for getting absence settings.
    Built to specification:
        * https://wiki.support.national-platform.ru/xwiki/bin/view/Main/InternalDocs/Analytics/HR/Project%20Documentation/016%20Absences/016-04%20Sick%20leave/016-04-004009017020%20Sickness/

    Jira task RULOC-4042

    @type Class
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Class RUAbsenceModel From LongNameClass

    Data cCodeTypeAbsence As Character // Code of absence type.
    Data nDaysAbsence As Numeric // Count days of absence.
    Data nYearBalance As Numeric // Count days by year of this type absence.
    Data dStartDate As Date // Start of absence.
    Data dEndDate As Date // End of absence.
    Data dViolateDate As Date // Start date of violation. From this date calculate from minimum wage.
    Data lIsContinue As Logical // This absence is continue of previously absence.
    Data lWasViolation As Logical // This show that was violation into absence.
    Data cPreviousNumberAbsence As Character // Previous absence number.
    Data cFatherNumberAbsence As Character // Number of father absence if this continue.

    Data nCompanyDays As Numeric
    Data nFSSDays As Numeric
    Data nMinCompanyDays As Numeric
    Data nMinFSSDays As Numeric

    Data dFatherStartDateAbsence As Date
    Data lIsFullFSSPayments As Logical
    Data lFullMinimumPayments As Logical
    Data nBeforeDays As Numeric

    /*
        This array will contain data for each day of absence in the following form:
        {Date of absence, Type of day, number of days, minimum wage amount on the day of calculation}

        Types of day:
            * "WRK" - payments by worker
            * "FSS" - payments by FSS

        The minimum wage amount on the day of calculation will always be 0 in this class. 
        The amount will be calculated in the RUDisabilityCalculation class in the Calculation() method.
    */
    Data aAbsenceDistribution As Array


    Method New() Constructor
    Method Destroy()

    Method DaysDistribution()
    Method ClearDaysDistribution()
    Method GetParAbsence(cAbsenceNumber) // Get parental absence.
    Method GetAbsence(cAbsenceNumber) // Get absence by code.

EndClass

/*/
{Protheus.doc} New
    Default constructor.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Object, RUAbsenceTypeModel instance.
/*/
Method New() Class RUAbsenceModel

    Self:lIsContinue := .F.
    Self:lWasViolation := .F.

    Self:nCompanyDays := 0
    Self:nMinCompanyDays := 0
    Self:nFSSDays := 0
    Self:nMinFSSDays := 0

    Self:dFatherStartDateAbsence := CToD("//")
    Self:lIsFullFSSPayments := .F.
    Self:lFullMinimumPayments := .F.
    Self:nBeforeDays := 0

    Self:aAbsenceDistribution := {}

Return Self

/*/
{Protheus.doc} Destroy
    Destructor.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method Destroy() Class RUAbsenceModel

    Self:lIsContinue := Nil
    Self:lWasViolation := Nil
    Self:cCodeTypeAbsence := Nil
    Self:dViolateDate := Nil
    Self:dStartDate := Nil
    Self:nYearBalance := Nil
    Self:nDaysAbsence := Nil

    Self:nCompanyDays := Nil
    Self:nFSSDays := Nil
    Self:nMinCompanyDays := Nil
    Self:nMinFSSDays := Nil

    Self:aAbsenceDistribution := Nil

Return

/*/
{Protheus.doc} ClearDaysDistribution
    Clear Days Distribution.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method ClearDaysDistribution() Class RUAbsenceModel
    Self:nCompanyDays := 0
    Self:nMinCompanyDays := 0
    Self:nFSSDays := 0
    Self:nMinFSSDays := 0
    Self:aAbsenceDistribution := {}
Return

/*/
{Protheus.doc} DaysDistribution
    Distribution paid days by company and FSS.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method DaysDistribution() Class RUAbsenceModel
    Local nI := 0 As Numeric
    Local dTempDate := CToD("//") As Date

    Self:cFatherNumberAbsence := Self:cPreviousNumberAbsence

    If !Empty(Self:cFatherNumberAbsence)
        Self:lIsContinue := .T.
        Self:GetParAbsence()
    EndIf

    Self:ClearDaysDistribution()

    For nI := 0 To Self:nDaysAbsence
        dTempDate := Self:dStartDate + nI

        If dTempDate <= Self:dEndDate
            aAdd(Self:aAbsenceDistribution, {dTempDate, Iif(Self:nBeforeDays + nI + 1 <= PAYMENT_DAYS_BY_COMPANY, "WRK", "FSS"), 1, 0})
        EndIf
    Next nI

Return

/*/
{Protheus.doc} GetParAbsence
    Receive and analyze all parental absences by serial number in SR8. 
    Obtaining data on the very first absence, if there was a continuation of sick leave.

    @type Method
    @author vselyakov
    @since 2023/11/13
    @version 12.1.33
    @return Object, Object of RUAbsenceModel
/*/
Method GetParAbsence() Class RUAbsenceModel
    Local lIsStop := .F. As Logical
    Local oPrevAbsence := Nil As Object
    Local nTotalDays := 0 As Numeric

    While !lIsStop
        oPrevAbsence := Self:GetAbsence(Self:cFatherNumberAbsence)
        nTotalDays := nTotalDays + oPrevAbsence:nDaysAbsence

        If !Empty(oPrevAbsence:dViolateDate)
            Self:lFullMinimumPayments := .T.
        EndIf

        If Empty(oPrevAbsence:cPreviousNumberAbsence)
            lIsStop := .T.
        EndIf
    EndDo

    Self:nBeforeDays := nTotalDays
    Self:dFatherStartDateAbsence := oPrevAbsence:dStartDate

    If nTotalDays >= PAYMENT_DAYS_BY_COMPANY
        Self:lIsFullFSSPayments := .T.
    EndIf

    FWFreeObj(oPrevAbsence)

Return 

/*/
{Protheus.doc} GetAbsence
    Obtaining parental absence by serial number in SR8.

    @type Method
    @author vselyakov
    @since 2023/11/13
    @version 12.1.33
    @return Object, Object of RUAbsenceModel
/*/
Method GetAbsence(cAbsenceNumber) Class RUAbsenceModel
    Local aArea := GetArea() As Array
    Local cAlias := "" As Character
    Local cQuery := "" As Character
    Local oStatement := Nil As Object
    Local oAbsenceObject := RUAbsenceModel():New() As Object

    cQuery := " SELECT                    "
    cQuery += "     R8_DATAINI            "
    cQuery += "    ,R8_DURACAO            "
    cQuery += "    ,R8_CONTAFA            "
    cQuery += "    ,R8_VIOLAT             "
    cQuery += " FROM " + RetSqlName("SR8") 
    cQuery += " WHERE                     "
    cQuery += "         R8_FILIAL = ?     "
    cQuery += "     AND R8_MAT = ?        "
    cQuery += "     AND R8_SEQ = ?        "
    cQuery += "     AND D_E_L_E_T_ = ' '  "


    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, FWxFilial("SR8"))
    oStatement:SetString(2, SRA->RA_MAT)
    oStatement:SetString(3, cAbsenceNumber)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cAlias)
    (cAlias)->(DbGoTop())

    While !((cAlias)->(Eof()))
        oAbsenceObject:nDaysAbsence := (cAlias)->R8_DURACAO
        oAbsenceObject:dStartDate := SToD((cAlias)->R8_DATAINI)
        oAbsenceObject:dViolateDate := SToD((cAlias)->R8_VIOLAT)
        oAbsenceObject:cPreviousNumberAbsence := (cAlias)->R8_CONTAFA

        If !Empty(oAbsenceObject:cPreviousNumberAbsence)
            Self:cFatherNumberAbsence := oAbsenceObject:cPreviousNumberAbsence
        EndIf

        (cAlias)->(DBSkip())
    EndDo

    (cAlias)->(DbCloseArea())
    oStatement:Destroy()
    FWFreeObj(oStatement)


    RestArea(aArea)

Return oAbsenceObject
