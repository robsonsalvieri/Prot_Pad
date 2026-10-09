#Include "PROTHEUS.CH"

#Define RCM_CTK209_YES "1"
#Define RCM_VIOLAT_YES "1"

/*/
{Protheus.doc} RUAbsenceTypeModel
    Class for getting absence type settings.
    Built to specification:
        * https://wiki.support.national-platform.ru/xwiki/bin/view/Main/InternalDocs/Analytics/HR/Project%20Documentation/016%20Absences/016-04%20Sick%20leave/016-04-004009017020%20Sickness/

    Jira task RULOC-4042

    @type Class
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Class RUAbsenceTypeModel From LongNameClass

    Data lIsLoaded As Logical // Show that data was loaded.
    Data cCodeTypeAbsence As Character // Code of absence type (RCM_TIPO).
    Data nDaysPerOneAbsence As Numeric // Available days of absence per one absence (RCM_DIASEM).
    Data nDaysPerYearAbsence As Numeric // Available days of absence per year (RCM_LIMPDL).
    Data lExperience As Logical // Accounting of experience (RCM_CTK209).
    Data lViolation As Logical // Accounting of violation (RCM_VIOLAT).

    Method New(cTypeAbsenceCode) Constructor
    Method Destroy()
    Method GetSettings()

EndClass

/*/
{Protheus.doc} New
    Default constructor.

    @type Method
    @param cTypeAbsenceCode, Character, Type absence code
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Object, RUAbsenceTypeModel instance.
/*/
Method New(cTypeAbsenceCode) Class RUAbsenceTypeModel

    Self:cCodeTypeAbsence := cTypeAbsenceCode

    Self:lIsLoaded := Self:GetSettings()

    If !Self:lIsLoaded
        ConOut("Error on RUAbsenceTypeModel: Settings for absence type did not load")
    EndIf

Return Self

/*/
{Protheus.doc} Destroy
    Destructor.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
/*/
Method Destroy() Class RUAbsenceTypeModel

    Self:lIsLoaded := Nil
    Self:cCodeTypeAbsence := Nil
    Self:nDaysPerOneAbsence := Nil
    Self:nDaysPerYearAbsence := Nil
    Self:lExperience := Nil
    Self:lViolation := Nil

Return

/*/
{Protheus.doc} GetSettings
    Getting absence type settings.

    @type Method
    @author vselyakov
    @since 2023/11/10
    @version 12.1.33
    @return Logical, Show that data was loaded.
/*/
Method GetSettings() Class RUAbsenceTypeModel
    Local lIsLoaded := .F. As Logical
    Local aArea := GetArea() As Array
    Local aRCMArea := RCM->(GetArea()) As Array
    
    /*
     * Get type of absence parameters.
    */
    If !Empty(Self:cCodeTypeAbsence)
        DbSelectArea("RCM")
        RCM->(DbSetOrder(1)) // "RCM_FILIAL+RCM_TIPO".
        RCM->(DbGoTop())

        If RCM->(DbSeek(FwXFilial("RCM") + Self:cCodeTypeAbsence, .T.))
            Self:nDaysPerOneAbsence := RCM->(RCM_DIASEM)
            Self:nDaysPerYearAbsence := RCM->(RCM_LIMPDL)
            Self:lExperience := Iif(RCM->(RCM_CTK209) == RCM_CTK209_YES, .T., .F.)
            Self:lViolation := Iif(RCM->(RCM_VIOLAT) == RCM_VIOLAT_YES, .T., .F.)

            lIsLoaded := .T.
        EndIf

        RCM->(DbCloseArea())
    EndIf

    RCM->(RestArea(aRCMArea))
    RestArea(aArea)

Return lIsLoaded
