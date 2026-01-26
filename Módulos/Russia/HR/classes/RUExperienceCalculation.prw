#INCLUDE "PROTHEUS.CH"

#Define EXPERIENCE_MAX_COLUMN 8
#Define WORK_EXPERIENCE_REFTYPES "02"

/*/
{Protheus.doc} RUExperienceCalculation
    qweqwe

    @type Class
    @author vselyakov
    @since 2024/04/26
    @version 12.1.2310
/*/
Class RUExperienceCalculation From LongNameClass
    Data aS209Array As Array
    Data aExperienceArray As Array // "Year", "Month", "Day".
    Data nCoefficientExperience As Numeric

    Method New() Constructor
    Method GetS209Array()
    Method CalcExperience(cMat, lCur, cCode, dCurDate)
    Method GetCoefficientExperience()
EndClass

/*/
{Protheus.doc} New()
    Default RUExperienceCalculation constructor.

    @type Method
    @author vselyakov
    @since 2024/04/26
    @version 12.1.2310
    @return Object, RUExperienceCalculation instance
/*/
Method New() Class RUExperienceCalculation

    Self:aExperienceArray := {0, 0, 0} // "Year", "Month", "Day".
    Self:aS209Array := Self:GetS209Array()

Return Self

/*/
{Protheus.doc} GetS209Array
    Loading coefficients for work experience.
    Data is loaded from table S209.

    @type Method
    @author vselyakov
    @since 2024/04/26
    @version 12.1.2310
    @return Array, Experience coefficient array.
/*/
Method GetS209Array() Class RUExperienceCalculation
    Local aExpCoeffs := {}
    Local aS209Lines := {} As Array
    Local nIndex := 0 As Numeric

    fCarrTab(@aS209Lines, "S209") // Load data from S209.

    nIndex := aScan(aS209Lines, {|x| x[1] == "S209"}) // Search line with S209.

    If nIndex > 0
        aAdd(aExpCoeffs, aS209Lines[nIndex, 5]) // 1 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 6]) // 2 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 7]) // 3 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 8]) // 4 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 9]) // 5 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 10]) // 6 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 11]) // 7 year.
        aAdd(aExpCoeffs, aS209Lines[nIndex, 12]) // 8 year.
    EndIf

Return aExpCoeffs

/*/
{Protheus.doc} CalcExperience
    Calculation of work experience coefficient

    This is a copy of the CalcExperience method from the RUCalcAbsenceType class. 
    Author: Chizhov Danil

    @type Method
    @param cMat, Character, Employee number
    @param lCur, Logical, Accounting for current place of work
    @param cCode, Character, Experience type code
    @param dCurDate, Date, Date for which work experience needs to be calculated
    @author vselyakov
    @since 2024/04/27
    @version 12.1.2310
    @return Numeric, Experience coefficient value.
/*/
Method CalcExperience(cMat, lCur, cCode, dCurDate) Class RUExperienceCalculation
    Local cQuery  As Character
    Local aValues := {} As Array
    Local cRefer  As Character
    Local aExp := {}    As Array
    Local aTemp := {}   As Array
    Local aCur := {}    As Array
    Local aRgeCal := {} As Array

    Default lCur := .T.
    Default cCode := WORK_EXPERIENCE_REFTYPES
    Default dCurDate := Date()

    aExp := {0, 0, 0}
    aTemp := {0, 0, 0}
    aCur := {0, 0, dCurDate}
    aCur[1] := Year(aCur[3])
    aCur[2] := Month(aCur[3])
    aCur[3] := Day(aCur[3])

    cQuery := "SELECT RGE.RGE_DATAIN, RGE.RGE_DATAFI, F5H.F5H_CODE, F5H.F5H_YEARS, F5H.F5H_MONTHS, F5H.F5H_DAYS, RGE.R_E_C_N_O_ AS RGENUM FROM " + RetSQLName("RGE") + " RGE "
    cQuery += "LEFT JOIN " + RetSQLName("F5H") + " F5H ON F5H.F5H_FILIAL = RGE.RGE_FILIAL AND F5H.F5H_MAT = RGE.RGE_MAT AND F5H.F5H_DATAIN = RGE.RGE_DATAIN "
    cQuery += "AND F5H.F5H_TIPOCO = RGE.RGE_TIPOCO AND F5H.F5H_NUMID = RGE.RGE_NUMID AND F5H.D_E_L_E_T_ = ' ' WHERE "
    cQuery += "RGE.RGE_FILIAL = ? AND "
    cQuery += "RGE.RGE_MAT = ? AND "
    AAdd(aValues, FWxFilial("RGE"))
    AAdd(aValues, cMat)

    cQuery += "RGE.D_E_L_E_T_ = ' ' "

    cRefer := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cRefer, .T., .F.)

    TcSetField(cRefer, "RGE_DATAIN", "D", 8, 0)

    DbSelectArea(cRefer)
    (cRefer)->(DbGoTop())

    While !(cRefer)->(EoF())
        If Empty((cRefer)->RGE_DATAFI) .And. lCur
            If aScan(aRgeCal, {|X| X == (cRefer)->RGENUM}) < 1
                If dCurDate >= (cRefer)->RGE_DATAIN
                    aTemp := DateDiffYMD((cRefer)->RGE_DATAIN, dCurDate)
                EndIf
                
                Aadd(aRgeCal, (cRefer)->RGENUM)
            EndIf
        ElseIf ((cRefer)->F5H_CODE) == cCode
            aTemp[1] := ((cRefer)->F5H_YEARS)
            aTemp[2] := ((cRefer)->F5H_MONTHS)
            aTemp[3] := ((cRefer)->F5H_DAYS)
        EndIf

        aExp[1] += aTemp[1]
        aExp[2] += aTemp[2]
        aExp[3] += aTemp[3]
        
        aTemp[1] := 0
        aTemp[2] := 0
        aTemp[3] := 0

        If aExp[3] > 30
            aExp[2] += NoRound(aExp[3] / 30, 0)
            aExp[3] := aExp[3] - NoRound(aExp[3] / 30, 0) * 30
        EndIf

        If aExp[2] >= 12
            aExp[1] += NoRound(aExp[2] / 12, 0)
            aExp[2] := aExp[2] - NoRound(aExp[2] / 12, 0) * 12
        EndIf
        
        (cRefer)->(DbSkip())
    EndDo

    (cRefer)->(DbCloseArea())

    Self:aExperienceArray[1] := aExp[1]
    Self:aExperienceArray[2] := aExp[2]
    Self:aExperienceArray[3] := aExp[3]
Return aExp

/*/
{Protheus.doc} GetCoefficientExperience
    Formation of work experience coefficient

    @type Method
    @param cMat, Character, Employee number
    @param lCur, Logical, Accounting for current place of work
    @param cCode, Character, Experience type code
    @param dCurDate, Date, Date for which work experience needs to be calculated
    @author vselyakov
    @since 2024/04/27
    @version 12.1.2310
    @return Numeric, Experience coefficient value.
/*/
Method GetCoefficientExperience(cMat, lCur, cCode, dCurDate) Class RUExperienceCalculation
    Local nExperienceCoefficient := 0 As Numeric
    Local aExperience := Self:CalcExperience(cMat, lCur, cCode, dCurDate) As Array

    If aExperience[1] > 0 .And. aExperience[1] <= EXPERIENCE_MAX_COLUMN
        nExperienceCoefficient := Self:aS209Array[aExperience[1]]
    ElseIf aExperience[1] > 0 .And. aExperience[1] > EXPERIENCE_MAX_COLUMN
        nExperienceCoefficient := Self:aS209Array[EXPERIENCE_MAX_COLUMN]
    EndIf

    nExperienceCoefficient := nExperienceCoefficient / 100
    Self:nCoefficientExperience := nExperienceCoefficient

Return nExperienceCoefficient
