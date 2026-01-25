#INCLUDE "PROTHEUS.CH"

/*
{Protheus.doc} Ref182n
    Class (successor from RUHRReference class) for 182N reference

    @type Class
    @author vselyakov, dtereshenko
    @since 08/07/2020
    @version 12.1.23
*/
Class Ref182n From RUHRReference
    Method New(cMat) Constructor

    Method Ask()
    Method GetByYear(dBaseDate)
EndClass


/*
{Protheus.doc} New(cMat)
    Default constructor for Ref182nDays class.

    @type Method
    @params cMat,    Char,      Employee personnel number
    @author vselyakov
    @since 08/07/2020
    @version 12.1.23
*/
Method New(cMat) Class Ref182n
    _Super:New("182" + CHR(237))
    _Super:LoadLastUnique(cMat)
Return Self

/*
{Protheus.doc} Ask()
    Call RUHRReference:Ask(cQuestion) with transfering RUREF182N pergunte ID

    @type Method
    @params
    @author dtereshenko
    @since 2020/09/10
    @version 12.1.23
*/
Method Ask() Class Ref182n
    _Super:Ask("RUREF182N")
Return

/*
{Protheus.doc} GetByYear(dBaseDate As Date)
    Get information about required year from RUHRReference:oQuestionMap

    @type Method
    @params dBaseDate   Date    Date in required year
    @return aYearInfo   Array   Array with sum of year payments and number of days missed on sick leave
    @author dtereshenko
    @since 2020/09/10
    @version 12.1.23
*/
Method GetByYear(dBaseDate) Class Ref182n
    Local cContent As Char
    Local aSplittedContent As Array

    Local cBaseYear := AllTrim(Str(Year(dBaseDate)))
    Local aYearInfo := {0, 0}

    cContent := _Super:GetField("F6H_CONTEN")
    aSplittedContent := StrTokArr(cContent, "|")

    nYearIndex := AScan(aSplittedContent, { |x| cBaseYear $ x })

    If nYearIndex != 0
        aYearInfo := {StrTokArr(aSplittedContent[nYearIndex + 1], "=")[2], StrTokArr(aSplittedContent[nYearIndex + 2], "=")[2]}
    EndIf

Return aYearInfo
