#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07R16RUS.CH"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040

#DEFINE AVERAGE_MONTH_DAYS 29.3

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE CMARK_CHAR_FOR_BROWSE "1"
#DEFINE TIPOAFA_FOR_RCM_FILTER "4"
#DEFINE COUNT_PARAMS_PARAM 10
#DEFINE NAME_OF_PROGRAM "RU07R16RUS"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R16PAR"
// #DEFINE INDEX_PARAM_COMBOBOX "3"
// #DEFINE INDEX_PARAM_SIGNER "4"
#DEFINE INDEX_PARAM_SRA 7
#DEFINE INDEX_PARAM_TA 10
#DEFINE SRA_STR_MAX_LENGHT 250
// #DEFINE DEFAULT_PARAM_INDEX 3
// #DEFINE DEFAULT_PARAM_VALUE 2

// #DEFINE MAX_LENGHT_NAME_FILE 255

#DEFINE AV_BASE_FOR_MONTH "71" + CHR(208)

/*/
{Protheus.doc} RU07R16()

    Main function of report by average payment for holiday.

    @type Function
    @params 
    @author dchizhov
    @since 25.07.2023
    @version 12.1.2210
    @return 
    @example RU07R16()
/*/
Function RU07R16()

    Local aParameter As Array
 
    aParameter := RU07R1601_GetParamWindow(NAME_OF_PROGRAM_PAR)

    If Len(aParameter) > 0
        aParameter[2] := Iif(AllTrim(aParameter[2]) == "", Replicate("Z", TamSX3("RA_FILIAL")[1]), aParameter[2])
        aParameter[4] := Iif(AllTrim(aParameter[4]) == "", Replicate("Z", TamSX3("RA_CC")[1]), aParameter[4])
        aParameter[6] := Iif(AllTrim(aParameter[6]) == "", Replicate("Z", TamSX3("RA_DEPTO")[1]), aParameter[6])
        MsAguarde({|| RU07R1610_PrintReport(aParameter)}, STR0009, STR0010) // "Please, wait", "Preparatory Processes: Gathering Filter and Parameter Data..."
    EndIf

Return 

///TODO
/*/
{Protheus.doc} RU07R1610_PrintReport(aParam)

    Get data and print report.

    @type Static Function
    @params aParams, Array, Parameters entered by the user.
    @author dchizhov
    @since 25.07.2023
    @version 12.1.2210
    @return .T.
    @example {|| MsAguarde({|| RU07R1610_PrintReport(aParameter)}, STR0009, STR0010)} // "Please wait!", "Preparatory Processes: Gathering Filter and Parameter Data..."
/*/
Static Function RU07R1610_PrintReport(aParam)

    Local oReport      As Object
    Local oEFSSZVTDObj As Object
    Local oSubs1_1     As Object
    Local oTabs1_1     As Object
    Local nX           As Numeric
    Local nOrder       As Numeric
    Local nLenght      As Numeric
    Local cTemp        As Character
    Local aSRAArea     As Array
    Local aSRAList     As Array
    Local aDataEmp     As Array
    Local lPageBreak   As Logical
    Local aPersonNumb  As Array

    If RU07R1602_IsAcceptButton(aParam)
        aSRAArea := SRA->(GetArea()) /// it is need
        aSRAList := RU07R1612_GetPersonnelNumbers(RU07R1611_GetFilterStr(aParam))
        aDataEmp := RU07R1613_GetData(aSRAList)
        MsProcTxt(STR0094) // "Printing a report in PDF"
        If Len(aDataEmp) == 0
            MsgInfo(STR0121) // "No data to print"
        Else
            RU07R1614_Print(aDataEmp)
        EndIf
        SRA->(RestArea(aSRAArea)) /// it is need
        FreeObj(oReport)
    EndIf

Return .T.

/*/
{Protheus.doc} RU07R1611_GetFilterStr(aFilter)

    Get string for sql-query by filter.

    @type Function
    @params aFilter, Array, Filter entered by the user.
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return cFilter, Character, Filter str for SQL-request
    @example aSRAList := RU07R1612_GetPersonnelNumbers(RU07R1611_GetFilterStr(aFilter))
/*/
Function RU07R1611_GetFilterStr(aFilter)

    Local cFilter As Character
    Local nCount  As Numeric
    Local nX      As Numeric

    nCount := Len(aFilter[INDEX_PARAM_SRA])
    cFilter := ""
    
    cFilter += " (RA_FILIAL >= '" + aFilter[1] + "')"
    cFilter += " AND (RA_FILIAL <= '" + Iif(Empty(aFilter[2]), Replicate("Z", TamSX3("RA_FILIAL")[1]), aFilter[2]) + "')"

    cFilter += " AND (RA_CC >= '" + aFilter[3] + "')"
    cFilter += " AND (RA_CC <= '" + Iif(Empty(aFilter[4]), Replicate("Z", TamSX3("RA_CC")[1]), aFilter[4]) + "')"
    
    cFilter += " AND (RA_DEPTO >= '" + aFilter[5] + "')"
    cFilter += " AND (RA_DEPTO <= '" + Iif(Empty(aFilter[6]), Replicate("Z", TamSX3("RA_DEPTO")[1]), aFilter[6]) + "')"

    If nCount > 0
        cFilter += " AND RA_MAT IN ("
        For nX := 1 To nCount
            cFilter += "'" + aFilter[7, nX] + "'" + Iif(nX < nCount, ", ", ")")
        Next nX
    EndIf
    nCount := Len(aFilter[INDEX_PARAM_TA])

    cFilter += " AND (R8_PER >= '" + aFilter[8] + "')"
    cFilter += " AND (R8_PER <= '" + aFilter[9] + "')"

    If nCount > 0
        cFilter += " AND R8_TIPOAFA IN ("
        For nX := 1 To nCount
            cFilter += "'" + aFilter[10, nX] + "'" + Iif(nX < nCount, ", ", ")")
        Next nX
    Else
        cFilter += " AND RCM_TIPOAF = '" + TIPOAFA_FOR_RCM_FILTER +"'"
    EndIf

Return cFilter

/*/
{Protheus.doc} RU07R1612_GetPersonnelNumbers(cFilter)

    This function build an array with personnel numbers of employees who meet the conditions in the filter.

    @type Function
    @params cFilter, Array, Array with value for filtering data.
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return aNumbers, Array, Array of employees.
    @example aSRAList := RU07R1612_GetPersonnelNumbers(RU07R1611_GetFilterStr(aFilter))
/*/
Function RU07R1612_GetPersonnelNumbers(cFilter)

    Local aNumbers     As Array
    Local aArea        As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cTab         As Character
    Local lRCMNeed     As Logical

    aNumbers := {}
    aArea := GetArea()
    lRCMNeed := At(" RCM_TIPOAF ", cFilter) > 0

    cQuery := " SELECT RA_MAT AS EMPLOYNUM, RA_FILIAL AS FILIAL, R8_DATAINI AS DATAINI, R8_DATAFIM AS DATAFIM, R8_DURACAO AS DURACAO, R8_PER AS PERIOD, R8_PD AS PD, "
    cQuery += " R8_NUMPAGO AS NUMPAGO, RCM_DESCRI AS DESCRI, RA_PROCES AS PROCES, R8_TIPOAFA  AS TIPOAFA "
    cQuery += " FROM " +  RetSQLName("SRA") + " SRA "
    cQuery += " INNER JOIN " +  RetSQLName("SR8") + " SR8 ON SR8.R8_MAT = SRA.RA_MAT AND SR8.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " +  RetSQLName("RCM") + " RCM ON RCM.RCM_TIPO = SR8.R8_TIPOAFA AND RCM.D_E_L_E_T_ = ' ' "
    
    cQuery += " WHERE "
    cQuery += cFilter
    cQuery += " AND "
    cQuery += " SRA.D_E_L_E_T_ = ' ' "

    oStatement := FWPreparedStatement():New(cQuery)
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DbSelectArea(cTab)
    (cTab)->(DbGoTop())

    While !((cTab)->(Eof()))
        Aadd(aNumbers, {(cTab)->EMPLOYNUM, (cTab)->FILIAL, (cTab)->EMPLOYNUM + (cTab)->FILIAL, DToC(SToD((cTab)->DATAINI)), DToC(SToD((cTab)->DATAFIM)), (cTab)->DURACAO, (cTab)->PERIOD, (cTab)->PD, (cTab)->NUMPAGO, ; // 12 items
        (cTab)->DESCRI, (cTab)->PROCES, (cTab)->TIPOAFA})
        (cTab)->(DbSkip())
    EndDo

    aSort(aNumbers, , , {|X, Y| X[1] < Y[1] .Or. (X[1] == Y[1] .And. X[2] < Y[2])})

    (cTab)->(DbCloseArea())
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aArea)

Return aNumbers

/*/
{Protheus.doc} RU07R1613_GetData(lProc)

    This function get data for report. 

    @type Static Function
    @params aSRAList, Array, List of emplyee.
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return aData, Array, Array with data for report.
    @example aDataEmp := RU07R1613_GetData(aSRAList)
/*/
Static Function RU07R1613_GetData(aSRAList)

    Local nX       As Numeric
    Local aSRAArea As Array
    Local aSRHArea As Array
    Local aArea    As Array
    Local nLenght  As Numeric
    Local nOrder   As Numeric
    Local aTemp    As Array
    Local nY       As Numeric
    Local aData    As Array
    Local aDataP   As Array
    Local aDataAv  As Array
    Private RH_DATAINI As Date
    Private oMonths  As Object

    Default lProc := .F.
    aData := {}
    aSRAArea := SRA->(GetArea())
    // aSRHArea := SRH->(GetArea())
    aArea := GetArea()
    cTemp := CValToChar(Len(aSRAList))
    nOrder := RetOrder("SRA", "RA_MAT+RA_FILIAL")
    nLenght := Len(cTemp)

    For nX := 1 To Len(aSRAList)
        If !Empty(Posicione("SRA", nOrder, aSRAList[nX, 1], "RA_MAT"))
            MsProcTxt(STR0093 + " " + PadL(CValToChar(nX), nLenght, "0") + "/" + cTemp) // "Processed employees:"
                // DbSelectArea("SRH")
                // SRH->(DbSetorder(RetOrdem("SRH", "RH_FILIAL+RH_MAT+DTOS(RH_DATAINI)")))
                // SRH->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + DToS(CToD(aSRAList[nX, 4]))))
            aTemp := {}
            Aadd(aTemp, AllTrim(FDesc("SQB", SRA->RA_DEPTO, "QB_DESCRIC")))
            Aadd(aTemp, StaticCall(RU07R06RUS, RU07R0607_GetPostNameSignature, SRA->RA_CARGO))
            Aadd(aTemp, SRA->RA_NOMECMP)
            Aadd(aTemp, SRA->RA_MAT)
            Aadd(aTemp, SRA->RA_PIS)
            Aadd(aTemp, SRA->RA_CIC)
            Aadd(aTemp, aSRAList[nX, 10])
            Aadd(aTemp, aSRAList[nX, 4])
            Aadd(aTemp, aSRAList[nX, 5])
            Aadd(aTemp, aSRAList[nX, 6])
            aDataP := RU07R1616_GetDataTPA(aSRAList[nX])
            Aadd(aTemp, aDataP[1])
            Aadd(aTemp, aDataP[2])            
            Aadd(aTemp, aSRAList[nX, 12])                   // Type of absence code
            Aadd(aTemp, aSRAList[nX, 8]) 
            aDataAv := RU07R1617_GetDataAverCalc(aSRAList[nX])
            Aadd(aTemp, aDataAv)           
            For nY := 1 To Len(aTemp)
                If aTemp[nY] == Nil
                    aTemp[nY] := ""
                EndIf
            Next nY
            Aadd(aData, aTemp)
            FreeObj(aDataP)
            FreeObj(oMonths)
            Sleep(1)
        EndIf
    Next nX

    ASort(aData, , , {|X, Y| X[3] < Y[3] .Or.(X[3] == Y[3] .And. CToD(X[8]) <= CToD(Y[8]))})

    SRA->(RestArea(aSRAArea))
    // SRH->(RestArea(aSRHArea))
    RestArea(aArea)

Return aData

/*/
{Protheus.doc} RU07R1616_GetDataTPA(aData)

    This function get data for payng from SRC and SRD. 

    @type Static Function
    @params aData, Array, Array with Data about absence.
    @author dchizhov
    @since 08.08.2023
    @version 12.1.2210
    @return aDataP, Array, Array with data about calculation.
    @example aDataP := RU07R1616_GetDataTPA(aSRAList[nX])
/*/
Function RU07R1616_GetDataTPA(aData)

    Local aDataP   As Array
    Local aArea    As Array
    Local aSRCArea As Array
    Local aSRDArea As Array
    Local dDatPGT  As Date
    Local nRecFind As Numeric

    aArea := GetArea()
    aSRCArea := SRC->(GetArea())
    aSRDArea := SRD->(GetArea())
    dDatPGT := CToD("//")
    nRecFind := 0

    aDataP := { "", 0.00}

    DbSelectArea("SRC")
    SRC->(DbSetOrder(RetOrdem("SRC", "RC_FILIAL+RC_PD+RC_PROCES+RC_PERIODO+RC_ROTEIR+RC_MAT")))
    If SRC->(DbSeek(aData[2] + aData[8] + aData[11] + aData[7] + "FOL" + aData[1]))
        While SRC->RC_FILIAL == aData[2] .And. SRC->RC_PD == aData[8] .And. SRC->RC_PROCES == aData[11] .And. SRC->RC_PERIODO == aData[7] ;
        .And. SRC->RC_ROTEIR == "FOL" .And. SRC->RC_MAT == aData[1]
            If SRC->RC_DATA > dDatPGT
                dDatPGT := SRC->RC_DATA
                nRecFind := SRC->(RecNo())
            EndIf
            SRC->(DbSkip())
        EndDo
        SRC->(DbGoTo(nRecFind))
        aDataP[1] := DToC(SRC->RC_DATA)
        aDataP[2] := (SRC->RC_VALOR)
    Else
        DbSelectArea("SRD")
        SRD->(DbSetOrder(RetOrdem("SRD", "RD_FILIAL+RD_MAT+RD_PROCES+RD_ROTEIR+RD_PERIODO+RD_SEMANA+RD_PD")))
        If SRD->(DbSeek(aData[2] + aData[1] + aData[11] + "FOL" + aData[7]))
            While SRD->RD_FILIAL == aData[2] .And. SRD->RD_PROCES == aData[11] .And. SRD->RD_PERIODO == aData[7] ;
            .And. SRD->RD_ROTEIR == "FOL" .And. SRD->RD_MAT == aData[1]
                If SRD->RD_PD == aData[8]
                    If SRD->RD_DATPGT > dDatPGT
                        dDatPGT := SRD->RD_DATPGT
                        nRecFind := SRD->(RecNo())
                    EndIf
                EndIf
                SRD->(DbSkip())
            EndDo
            SRD->(DbGoTo(nRecFind))
            aDataP[1] := DToC(SRD->RD_DATPGT)
            aDataP[2] := (SRD->RD_VALOR)
        EndIf
    EndIf

    RestArea(aArea)
    SRC->(RestArea(aSRCArea))
    SRD->(RestArea(aSRDArea))

Return aDataP

/*/
{Protheus.doc} RU07R1617_GetDataAverCalc(aSRAList)

    This function get data for payng from SRC and SRD. 

    @type Static Function
    @params aSRAList, Array, Array with Data about absence.
    @author dchizhov
    @since 09.08.2023
    @version 12.1.2210
    @return aData, Array, Array with data about average calculation.
    @example aDataAv := RU07R1617_GetDataAverCalc(aSRAList[nX])
/*/
Function RU07R1617_GetDataAverCalc(aSRAList)

    Local oRpoForm    As Object
    Local aGetTreeFrm As Array
    Local aData       As Array
    Local aArea       As Array
    Local aPerForCal  As Array
    Local cQuery      As Character
    Local aValues     As Array
    Local cAlias      As Character
    Local lIsCalcPrev As Logical
    Local nX          As Numeric
    Local aPerMounth  As Array
    Local nDayAbsence As Numeric
    Local nDTrab      As Numeric
    Local aDAfas      As Array
    Local aTemp       As Array
    Local cTemp       As Cherecter
    Local lStandart   As Logical
    Local cPrevYearStart As Character
    Local cMatNum     As Character
    Local cMatFil     As Character 

    Private RH_DATAINI As Date
    Private oMonths    As Object

    Private lUlSem As Logical
    Private nPosit As Numeric
    Private aDetAfas

    aData := {}
    aArea := GetArea()
    lIsCalcPrev := .F.
    lStandart := .F.
    aValues := {}
    aDAfas := {}

    SetMnemonicos(NIL,NIL,.T.)
    cRot := "FER"
    cPeriodo := aSRAList[7]
    cNumPag := aSRAList[9]
    cMatNum := aSRAList[1]
    cMatFil := aSRAList[2]

    SetRotExec(cRot)
    SetPeriodCalc(cPeriodo)
    SetNumPgCalc(cNumPag)
    
    GetTreeFrm(@aGetTreeFrm, cFilAnt, NIL, NIL, .T., @oRpoForm, .T.)
    S_CARRCHFE()
    S_LTABELAS()
    S_HRSCALC()
    S_RESIDEXT()
    S_HOJORVA()
    S_SALMES()
    S_SALHORA()
    S_SALDIA()
    cTipoRot := "3"
    oMonths := RuMap():New()
    RH_DATAINI := CToD(aSRAList[4])
    RU07XVAC06_CalculationVacantion(SRA->RA_MAT, RH_DATAINI, oMonths)
    oMonths:List(aPerForCal)
    ASort(aPerForCal, , , {|X, Y| X[1] < Y[1]})

    // Closing additional RPO
    LeaveExecRot()
    RpoFormInit(NIL, .T.)

    cPrevYearStart := CValToChar((Year(RH_DATAINI) - 1)) + Substr(DToS(RH_DATAINI), 5, 4)
    // We look at 71R per year. If there is, then the calculation is standard.
    // Look this into SRD table.
    cQuery := " SELECT COUNT(*) AS LNT FROM " + RetSQLName("SRD") + " WHERE "
    cQuery += " RD_FILIAL = ? "
    cQuery += " AND RD_MAT = ? "
    cQuery += " AND RD_PD = ? "
    cQuery += " AND (RD_DATARQ BETWEEN ? AND ?) "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    AAdd(aValues, SRA->RA_FILIAL)
    AAdd(aValues, SRA->RA_MAT)
    AAdd(aValues, AV_BASE_FOR_MONTH)
    AAdd(aValues, cPrevYearStart)
    AAdd(aValues, DToS(RH_DATAINI))

    cAlias := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAlias, .T., .F.)
    DbSelectArea(cAlias)
    DbGoTop()
    lIsCalcPrev := ((cAlias)->LNT > 0)

    DbCloseArea()

    If (SRA->RA_ADMISSA == RH_DATAINI)
        Aadd(aData, {Year(RH_DATAINI) + Month(RH_DATAINI), "", 0, aPeriodo[1][6], AVERAGE_MONTH_DAYS, "", ""})
    ElseIf ((Year(SRA->RA_ADMISSA) == Year(RH_DATAINI)) .And. (Month(SRA->RA_ADMISSA) == Month(RH_DATAINI)))
        Aadd(aData, {Year(RH_DATAINI) + Month(RH_DATAINI), "", ;
        RU07XFUN23_GetNumberDayAbsenceByPeriod(SRA->RA_MAT, SRA->RA_ADMISSA, RH_DATAINI - 1), ;
        RU07XFUN03_GetPerWorkDayWithAbsence(cMat, SRA->RA_ADMISSA, RH_DATAINI - 1) , AVERAGE_MONTH_DAYS, "", ""})
    ElseIf !lIsCalcPrev
        AEval(aPerForCal, {|X| Aadd(aData, {X[1], "", "", "", "", "", ""})})
        lStandart := .T.
    Else
        AEval(aPerForCal, {|X| Aadd(aData, {X[1], "", "", "", "", "", ""})}) 
        lStandart := .T.
    EndIf
    aTemp := aPeriodo
    cTemp := cPeriodo
    For nX := 1 To Len(aPerForCal)
        FCarPeriodo(aPerForCal[nX, 1], "FOL", @aPerMounth, @lUlSem, @nPosit) // we need calendar day from mounth, which calc in FOL
        aData[nX, 2] := Iif(aPerMounth[nPosit, 16]=="02" .And. P_PGSALFEV .And. (!Empty(CSITFOLH) .Or. (Day(SRA->RA_ADMISSA) > 01 .And. (Month(SRA->RA_ADMISSA)== 2 .And. Year(SRA->RA_ADMISSA) == Val(aPerMounth[nPosit, 15])))), aPerMounth[nPosit, 20], aPerMounth[nPosit,18])
        nDTrab := nDiasC

        If Year(SRA->RA_ADMISSA) == Year(aPerMounth[nPosit, 4]) .And. Month(SRA->RA_ADMISSA) == Month(aPerMounth[nPosit, 4]) .And. Day(SRA->RA_ADMISSA) # 1
            nDTrab := RU07XFUN02_GetPeriodWorkingDays(SRA->RA_ADMISSA, aPerMounth[nPosit, 4])
		EndIf
        aPeriodo := aPerMounth

        /* nDiasAfas, DiasTrab, dDtPesq, lSemanal, cPgMater, cListAfas, aDetAfast, lExit, lShowMsg */
        FDiasAfast(@nDayAbsence, @nDTrab, CToD(""), , cPgSalMat, , @aDAfas)

        aData[nX, 3] := IIf(lStandart, nDayAbsence, aData[nX, 3])
        aData[nX, 4] := Iif(lStandart, aData[nX, 2] - aData[nX, 3], aData[nX, 4])
        aData[nX, 5] := Iif(lStandart, RU07XVAC04_fGetAvMonthDays(), aData[nX, 5])
        // Average day in month correction by days of absence
        if aData[nx, 3] != 0
            aData[nX, 5] := ROUND((aData[nX, 5] * aData[nX, 4])/aData[nX, 2], 2)
        endif 

        aData[nX, 6] := Iif(lStandart, aPerForCal[nX, 2, 2], aData[nX, 6])
        if aData[nx, 3] != 0
            aData[nX, 7] := GetIntrDesc(cMatFil, cMatNum, aPerForCal[nX, 1])  // "Date interval" 
        else
            aData[nX, 7] := "-"
        endif

        aData[nX, 2] := CValToChar(aData[nX, 2])
        aData[nX, 3] := CValToChar(aData[nX, 3])
        aData[nX, 4] := CValToChar(aData[nX, 4])
        aData[nX, 5] := CValToChar(aData[nX, 5])
        aData[nX, 6] := Str(aData[nX, 6], , 2)

    Next nX
    aPeriodo := aTemp
    cPeriodo := cTemp
    FreeObj(oMonths)
    RestArea(aArea)

Return aData

/*/
{Protheus.doc} RU07R1614_Print(aData)

    This function get JSON for PDF-maker. 

    @type Static Function
    @params aData, Array, Array with Data
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return oJson, Object, Json for PDF-maker.
    @example RU07R1614_Print(aData)
/*/
Static Function RU07R1614_Print(aData)

    Local lResult := .T. As Logical
    Local oJson          As Object
    Local oOptions       As Object
    Local cJson          As Character
    Local cOptions       As Character

    oJson := GetTemplatate()

    oOptions := Ru99x50_01_GetOptionsTemplate()
    oOptions['showSidebarButton'] := .F.

    RU07R1615_FillData(oJson["content"], aData)

    cJson := oJson:ToJson()
    cOptions := oOptions:ToJson()

    ru99x50_pdfmakeForm(cJson, 'windows-1251', cOptions, 'RU07R16')
    FreeObj(oJson)
    FreeObj(oOptions)

Return lResult

/*/
{Protheus.doc} RU07R1615_FillData(aData)

    This function get JSON for PDF-maker. 

    @type Static Function
    @params aData, Array, Array with Data
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return oJson, Object, Json for PDF-maker.
    @example RU07R1615_FillData(oJson["content"], aData)
/*/
Static Function RU07R1615_FillData(aContent, aData)

    Local lResult := .T. As Logical
    Local oJson          As Object
    Local oJsonTemp      As Object
    Local cJson          As Character
    Local nI             As Numeric
    Local nX             As Numeric
    Local cTemp          As Character
    Local nLenght        As Numeric
    Local kX             As Numeric
    Local Total20        As Numeric
    Local Total21        As Numeric
    Local Tot19.2        As Numeric
    Local Tot19.3        As Numeric
    Local Tot19.4        As Numeric
    Local Tot19.5        As Numeric
    Local Tot19.6        As Numeric
    
    cTemp := CValToChar(Len(aData))
    nLenght := Len(cTemp)

    For nI := 1 To Len(aData)
        MsProcTxt(STR0094 + " " + PadL(CValToChar(nI), nLenght, "0") + "/" + cTemp) // "Print report to PDF"
        oJson := JsonObject():New()
        
        BeginContent var cJson
        {
            "content":[
                {
                    "margin": [2, 9, 0, 0],
                    "style": "normal",
                    "table": {
                        "width": "100%",
                        "widths": [25, 33, 70, 40, 240, 35, 70],
                        "body": [ 
                            [
                                {"border": [false, false, false, false], "text": "", "colSpan": 7, "bold": true}, {}, {}, {}, {}, {}, {}
                            ],
                            [
                                {"border": [false, false, false, false], "text": "", "colSpan": 2}, {},
                                {"border": [false, false, false, true], "text": "", "colSpan": 5}, {}, {}, {}, {}
                            ],
                            [
                                {"border": [false, false, false, false], "text": "", "colSpan": 2}, {},
                                {"border": [false, false, false, true], "text": "", "colSpan": 5}, {}, {}, {}, {}
                            ],
                            [
                                {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "colSpan": 4}, {}, {}, {},
                                {"border": [false, false, false, true], "text": "", "alignment": "right"}, {"border": [false, false, false, true], "text": ""}
                            ],
                            [
                                {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "colSpan": 2}, {},
                                {"border": [false, false, false, true], "text": "", "alignment": "right"}, 
                                {"border": [false, false, false, true], "text": "", "colSpan": 3}, {}, {}
                            ]
                        ]
                    }
                },
                {
                    "margin": [2, 0, 0, 0],
                    "style": "normal",
                    "table": {
                        "width": "100%",
                        "widths": [65, 208, 5, 50, 10, 50, 95, 20],
                        "body": [ 
                            [
                                {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, true], "text": ""}, 
                                {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, true], "text": ""}, 
                                {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, true], "text": ""}, {"border": [false, false, false, true], "text": ""}
                            ],
                            [
                                {"border": [false, false, false, false], "text": ""}, {"border": [false, false, false, true], "text": "", "colSpan": 7},
                                {}, {}, {}, {}, {}, {}
                            ]
                        ]
                    }
                },
                {
                    "margin": [2, 14, 0, 0],
                    "style": "normal",
                    "alignment": "center",
                    "table": {
                        "width": "100%",
                        "widths": [65, 55, 55, 45, 85, 105, 115],
                        "body": [ 
                            [
                                {}, {}, {}, {}, {}, {}, {}
                            ]
                        ]
                    }
                },
                {
                    "margin": [2, 14, 0, 0],
                    "style": "normal",
                    "alignment": "center",
                    "table":{
                        "width": "100%",
                        "widths": [20, 36, 55, 55, 45, 85, 105],
                        "body": [
                            [
                               {"border":[false, false, false, false], "text": ""},
                               {"border":[false, false, false, false], "text": ""},{},{},{},{},{}
                            ]
                        ]
                    }
                },
                {
                    "margin": [2, 28, 0, 0],
                    "style": "normal",
                    "alignment": "center",
                    "table":{
                        "width": "100%",
                        "widths": [85, 85, 85],
						"heights": 20,
                        "body": [
                            [
                                {"text": ""}, 
                                {"text": ""},
                                {"text": ""}
                            ],
                            [
                                {"margin": [ 10, 20, 10, 20 ], "text": "Value 20"}, 
                                {"margin": [ 10, 20, 10, 20 ], "text": "Value 21"},
                                {"margin": [ 10, 20, 10, 20 ], "text": "Value 22"}
                            ]
                            
                        ]
                    }
                },
                {
                    "margin": [2, 48, 0, 0],
                    "style": "normal",
                    "alignment": "center",
                    "table":{
                        "width": "100%",
                        "widths": [340, 230],
                        "body": [
                            [
                                {"border":[false, false, false, true], "text": "", "alignment": "left"}, 
                                {"text": ""}
                            ]
                            
                        ]
                    }
                },
                {
                    "margin": [2, 0, 0, 0],
                    "style": "normal7",
                    "alignment": "center",
                    "table":{
                        "width": "100%",
                        "widths": [60, 40, 40, 82, 82, 100, 121],
                        "body": [
                            [
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""},
                                {"border":[true, false, true, true], "text": ""}
                            ],
                            [
                                {"border":[true, false, true, true], "text": "23"},
                                {"border":[true, false, true, true], "text": "24"},
                                {"border":[true, false, true, true], "text": "25"},
                                {"border":[true, false, true, true], "text": "26"},
                                {"border":[true, false, true, true], "text": "27"},
                                {"border":[true, false, true, true], "text": "28"},
                                {"border":[true, false, true, true], "text": "29"}
                            ]
                            
                        ]
                    }
                }
            ]
        }
        EndContent
        
        oJson:FromJson(cJson)
        If nI > 1
            oJson["content"][1]["pageBreak"] := "before"
        EndIf

        oJson["content"][1]["table"]["body"][1, 1]["text"] := STR0016 // "Calculation of average earnings"
        oJson["content"][1]["table"]["body"][2, 1]["text"] := STR0017 // "Subdivision"
        oJson["content"][1]["table"]["body"][2, 3]["text"] := aData[nI, 1]
        oJson["content"][1]["table"]["body"][3, 1]["text"] := STR0018 // "Job title"
        oJson["content"][1]["table"]["body"][3, 3]["text"] := aData[nI, 2]
        oJson["content"][1]["table"]["body"][4, 1]["text"] := STR0019 // "Full name"
        oJson["content"][1]["table"]["body"][4, 2]["text"] := aData[nI, 3]
        oJson["content"][1]["table"]["body"][4, 6]["text"] := STR0020 // "Tab ?"
        oJson["content"][1]["table"]["body"][4, 7]["text"] := aData[nI, 4]
        oJson["content"][1]["table"]["body"][5, 1]["text"] := STR0021 // "INN"
        oJson["content"][1]["table"]["body"][5, 2]["text"] := aData[nI, 5]
        oJson["content"][1]["table"]["body"][5, 4]["text"] := STR0022 // "SNILS"
        oJson["content"][1]["table"]["body"][5, 5]["text"] := FmtSNILS(aData[nI, 6])
        
        oJson["content"][2]["table"]["body"][1, 1]["text"] := STR0023 // "Type of absence"
        oJson["content"][2]["table"]["body"][1, 2]["text"] := aData[nI, 7]
        oJson["content"][2]["table"]["body"][1, 3]["text"] := STR0024 // "Start"
        oJson["content"][2]["table"]["body"][1, 4]["text"] := aData[nI, 8]
        oJson["content"][2]["table"]["body"][1, 5]["text"] := STR0025 // "End"
        oJson["content"][2]["table"]["body"][1, 6]["text"] := aData[nI, 9]
        oJson["content"][2]["table"]["body"][1, 7]["text"] := STR0026 // "Settlement days/hours"
        oJson["content"][2]["table"]["body"][1, 8]["text"] := aData[nI, 10]
        oJson["content"][2]["table"]["body"][2, 1]["text"] := STR0027 // "Calculation month"
        oJson["content"][2]["table"]["body"][2, 2]["text"] := aData[nI, 11]

        oJson["content"][3]["table"]["body"][1, 1]["text"] := STR0029 // "Per month"
        oJson["content"][3]["table"]["body"][1, 2]["text"] := STR0030 // "Cal. days in a month"
        oJson["content"][3]["table"]["body"][1, 3]["text"] := STR0031 // "Absences"
        oJson["content"][3]["table"]["body"][1, 4]["text"] := STR0032 + STR0033// "Cal. days, adj.", "for work time"
        oJson["content"][3]["table"]["body"][1, 5]["text"] := STR0042 + STR0043// "Medium", "months number of calories days"
        oJson["content"][3]["table"]["body"][1, 6]["text"] := STR0044 // "Accrued for hours worked, rub."
        oJson["content"][3]["table"]["body"][1, 7]["text"] := STR0046 // "Notes"

        Total20 := 0.00
        Total21 := 0.00
        Tot19.2 := 0.00
        Tot19.3 := 0.00
        Tot19.4 := 0.00
        Tot19.5 := 0.00
        Tot19.6 := 0.00

        For nX := 1 To Len(aData[nI, 15])
            Aadd(oJson["content"][3]["table"]["body"], {})    
            For kX := 1 To Len(aData[nI, 15, nX])
                oJsonTemp := JsonObject():New()
                if kX == 1                    
                    oJsonTemp["text"] := NtoMWD(Val(Right(aData[nI, 15, nX, kX],2))) + " " + Left(aData[nI, 15, nX, kX], 4)
                    //oJson["content"][3]["table"]["body"][nX + 1, kX]["text"] := NtoMWD(Val(Right(aData[nI, 13, nX, kX],2)))
                elseif kX == 6
                     Tot19.6 += Val(aData[nI, 15, nX, 6])
                    // Total STR0056
                    Total20 += Val(aData[nI, 15, nX, 6])
                    oJsonTemp["text"] := FmtNumD(ALLTRIM(aData[nI, 15, nX, 6]))
                else
                    if kX == 2
                        Tot19.2 += Val(aData[nI, 15, nX, 2])
                    elseif kX == 3
                        Tot19.3 += Val(aData[nI, 15, nX, 3])
                    elseif kX == 4
                        Tot19.4 += Val(aData[nI, 15, nX, 4])
                    elseif kX == 5
                        Tot19.5 += Val(aData[nI, 15, nX, 5])
                        // Total STR0057
                        Total21 += Val(aData[nI, 15, nX, 5])
                    end if
                    oJsonTemp["text"] := aData[nI, 15, nX, kX]                   
                Endif
                Aadd(oJson["content"][3]["table"]["body"][nX + 1], oJsonTemp)
            Next kX
            //Aadd(oJson["content"][3]["table"]["body"][nX + 1], oJsonTemp)
            //AEval(aData[nI, 12, nX], {|X| oJsonTemp := JsonObject():New(), oJsonTemp["text"] := X, ;
            //    Aadd(oJson["content"][3]["table"]["body"][nX + 1], oJsonTemp)})
        Next nX

        oJson["content"][4]["table"]["body"][1, 2]["text"] := STR0084 // "Total 19"
        oJson["content"][4]["table"]["body"][1, 3]["text"] := cValToChar(Tot19.2)
        oJson["content"][4]["table"]["body"][1, 4]["text"] := cValToChar(Tot19.3)
        oJson["content"][4]["table"]["body"][1, 5]["text"] := cValToChar(Tot19.4)
        oJson["content"][4]["table"]["body"][1, 6]["text"] := cValToChar(Tot19.5)
        oJson["content"][4]["table"]["body"][1, 7]["text"] := FmtNumD(cValToChar(ROUND(Tot19.6, 2)))

        oJson["content"][5]["table"]["body"][1, 1]["text"] := STR0056 // "Total earnings for the calculation of SDZ/SCHZ"
        oJson["content"][5]["table"]["body"][2, 1]["text"] := FmtNumD(cValToChar(ROUND(Total20, 2)))
        oJson["content"][5]["table"]["body"][1, 2]["text"] := STR0057 // "Average monthly number of calories days"
        oJson["content"][5]["table"]["body"][2, 2]["text"] := cValToChar(Total21)
        oJson["content"][5]["table"]["body"][1, 3]["text"] := STR0059 // "Average daily/average hourly earnings"
        oJson["content"][5]["table"]["body"][2, 3]["text"] := FmtNumD(cValToChar(ROUND(Total20/Total21, 2)))

        oJson["content"][6]["table"]["body"][1, 1]["text"] := STR0061 // "Absence calculation by month"
        oJson["content"][6]["table"]["body"][1, 2]["text"] := STR0064 // "Final calculation"

        oJson["content"][7]["table"]["body"][1, 1]["text"] := STR0065 // "Type of absence (code)"
        oJson["content"][7]["table"]["body"][2, 1]["text"] := aData[nI, 13]
        oJson["content"][7]["table"]["body"][1, 2]["text"] := STR0066 // "From"
        oJson["content"][7]["table"]["body"][2, 2]["text"] := aData[nI, 8]
        oJson["content"][7]["table"]["body"][1, 3]["text"] := STR0067 // "To"
        oJson["content"][7]["table"]["body"][2, 3]["text"] := aData[nI, 9]
        oJson["content"][7]["table"]["body"][1, 4]["text"] := STR0068 // "Per month"
        oJson["content"][7]["table"]["body"][2, 4]["text"] := aData[nI, 11]
        oJson["content"][7]["table"]["body"][1, 5]["text"] := STR0069 // "Payment type"
        oJson["content"][7]["table"]["body"][2, 5]["text"] := aData[nI, 14]
        oJson["content"][7]["table"]["body"][1, 6]["text"] := STR0070 // "Days"
        oJson["content"][7]["table"]["body"][2, 6]["text"] := aData[nI, 10]
        oJson["content"][7]["table"]["body"][1, 7]["text"] := STR0071 // "Sum"
        oJson["content"][7]["table"]["body"][2, 7]["text"] := FmtNumD(cValToChar(ROUND(aData[nI, 12],2)))

        // Aadd(aContent, oJson)
        AEval(oJson["content"], {|X| Aadd(aContent, X)})
        sleep(1)

    Next nI

Return lResult

/*/
{Protheus.doc} GetTemplatate()

    This method biuld empty templatate for report and Json without content.

    @type Static Function
    @params 
    @author dchizhov
    @since 31.07.2023
    @version 12.1.2210
    @return oJson, Object, Json for report.
    @example oData := ::GetTemplatate()
/*/
Static Function GetTemplatate()

    Local oJson As Object
    Local cJson As Character

    oJson := JsonObject():New()

    BeginContent var cJson
    {
        "pageSize": "A4",
        "pageMargins": [0, 0, 0, 0],
        "styles": {
            "title": {
                "fontSize": 11,
                "bold": true,
                "font": "Arial",
                "alignment": "center"
            },
            "normal": {
            "font": "Arial",
                "fontSize": 9,
                "bold": false
            },
            "normal7": {
            "font": "Arial",
                "fontSize": 7,
                "bold": false
            }
        },
        "content": [
        ]
    }
    EndContent
    oJson:FromJson(cJson)

Return oJson


// // /********** functions about parametrs *************/

/*/
{Protheus.doc} RU07R1601_GetParamWindow(cNamePar)

    Shows a window for parametr.

    @type Static Function
    @params cNamePar, Character, Name of programm parametr
    @author dchizhov
    @since 25.07.2023
    @version 12.1.2210
    @return aResultDialog, Array, Array of current parametr.
    @example bParamsButton := {|| aParameter := RU07R1601_GetParamWindow(aParameter)}
/*/
Static Function RU07R1601_GetParamWindow(cNamePar)

    Local aResultDialog       As Array
    Local oDialog             As Object
    Local aParamtrField       As Array
    Local aUserSettings := {} As Array
    Local cNChar              As Character
    Local oGridLayout         As Object
    Local oPanelBottom        As Object
    Local oScrollBox          As Object
    Local oButtonSRAList      As Object
    Local oButtonTAList       As Object
    Local nI                  As Numeric
    Local cIdUser             As Character
    Local oHelp               As Object
    Local cHelp               As Character
    Local lSeeAll             As Logical

    Default cNamePar := NAME_OF_PROGRAM_PAR

    cIdUser := "U" + RetCodUsr()
    lSeeAll := VerSenha(114) .And. VerSenha(115)

    aParamtrField := {{Array(COUNT_PARAMS_PARAM), , }, {Array(COUNT_PARAMS_PARAM), , Array(COUNT_PARAMS_PARAM)}} // fields and Title for it. 

    aParamtrField[1, 2] := RU07R1603_GetStrParam(1)
    aParamtrField[2, 2] := RU07R1603_GetStrParam(2)
    aResultDialog := RU07R1603_GetStrParam(2)
    aParamtrField[1, 3] := RU07R1603_GetStrParam(3)

    aUserSettings := RU70R0101_GetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar)

    For nI := 1 To COUNT_PARAMS_PARAM
        If !(ValType(aUserSettings[nI]) $ "A|U")
            aParamtrField[2, 2, nI] := SubStr(aUserSettings[nI], 1, Len(aParamtrField[2, 2, nI]))
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        EndIf
    Next nI
    aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
    If !lSeeAll
        aResultDialog[1] := aResultDialog[2] := aParamtrField[2, 2, 1] := aParamtrField[2, 2, 2] := xFilial("SRA")
    EndIf

    oDialog := FWDialogModal():New()
    oDialog:SetEscClose(.F.)
    oDialog:SetCloseButton(.F.)
    oDialog:SetTitle(STR0001) // "Help-calculation of average earnings"
    oDialog:SetSize(WINDOW_HEIGHT_SIZE, WINDOW_WIDTH_SIZE)
    oDialog:CreateDialog()
    oDialog:AddYesNoButton()
    oDialog:SetValid({|| RU07R1602_IsAcceptButton(aParamtrField[2, 2])})

    oGridLayout := TPanel():New( ,,, oDialog:getPanelMain())
    oGridLayout:Align := CONTROL_ALIGN_ALLCLIENT

    oScrollBox := TScrollBox():New(oGridLayout, , , , , .T., .F., .T.)
    oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT

    oPanelBottom := TPanel():New( ,,, oDialog:getPanelMain(), , , , , , WINDOW_WIDTH_SIZE, 45)
    oPanelBottom:Align := CONTROL_ALIGN_BOTTOM

    For nI := 1 To COUNT_PARAMS_PARAM

        cNChar := CValToChar(nI)
        If cNChar $ "89"
            cValidate := "{|| Iif(Len(AllTrim(aParamtrField[2, 2, " + CNChar + "])) < 6, (MsgInfo('" + STR0099 + "'), .F.), .T.)}" // "Enter the period in the format YYYYMM (required)"
        EndIf
        // Make lines for parametr
        aParamtrField[1, 1, nI] := TSay():New(-10 + nI * 20, 5, &("{|| aParamtrField[1, 2, " + CNChar + "]}"), oScrollBox,,,,,,.T.,,,LABEL_WIDTH_SIZE, LABEL_HEIGHT_SIZE)
        aParamtrField[1, 1, nI]:lWordWrap := .F.

        aParamtrField[2, 1, nI] := TGet():New(-10 + nI * 20, 70, &("{|u| If( PCount() == 0, aParamtrField[2, 2, " + CNChar + "], aParamtrField[2, 2, " + CNChar + "] := u)}"), oScrollBox, ;
        TEXTBOX_WIDTH_SIZE, TEXTBOX_HEIGHT_SIZE, "@!",Iif(cNChar $ "89", &(cValidate), Nil), 0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,, Iif(cNChar $ "1|2", !lSeeAll, .F.),,, "aParamtrField[2, 2, " + cNChar + "]",,,, .T., .F.)

        aParamtrField[2, 1, nI]:bHelp := &("{|| ShowHelpCpo('CustomField', {aParamtrField[1, 3, " + CNChar + "]}, 1, {aParamtrField[1, 3, " + CNChar + "]}, 1)}")
        aParamtrField[2, 1, nI]:bGotFocus:= &("{|o|  cHelp := aParamtrField[1, 3, " + CNChar + "], oHelp:Refresh()}")

    Next nI

    oButtonSRAList := TButton():New(130, 250, "...", oScrollBox, {|| aParamtrField[2, 2, 7] := Padr(RU16R0104_GetSraList(aParamtrField[2, 2, 7]), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)
    oButtonTAList := TButton():New(190, 250, "...", oScrollBox, {|| aParamtrField[2, 2,10] := Padr(RU07R1604_GetRCMList(aParamtrField[2, 2, 10], "RCM_TIPOAF == '" + TIPOAFA_FOR_RCM_FILTER + "'"), SRA_STR_MAX_LENGHT, Space(1))}, 10, 10, , , .F., .T., .F., , .F., , , .F.)

    If lSeeAll
        aParamtrField[2, 1, 1]:cF3 := "XM0"
        aParamtrField[2, 1, 2]:cF3 := "XM0"
    EndIf
    aParamtrField[2, 1, 3]:cF3 := "CTT"
    aParamtrField[2, 1, 4]:cF3 := "CTT"
    aParamtrField[2, 1, 5]:cF3 := "SQB"
    aParamtrField[2, 1, 6]:cF3 := "SQB"

    @ 05,05 GET oHelp VAR cHelp OF oPanelBottom MULTILINE SIZE WINDOW_WIDTH_SIZE - 10, 035 PIXEL READONLY WHEN .T. NO VSCROLL
    oHelp:lCanGotFocus := .F.

    oDialog:bInit := {|| aParamtrField[2, 1, 1]:Setfocus(), oHelp:Refresh() }
    oDialog:Activate()

    lResultDialog := (oDialog:getButtonSelected() == 1)

    If lResultDialog // User press "OK".

        For nI := 1 To COUNT_PARAMS_PARAM
            aUserSettings[nI] := aParamtrField[2, 2, nI]
            aResultDialog[nI] := aParamtrField[2, 2, nI]
        Next nI

        aResultDialog[INDEX_PARAM_SRA] := RU16R0105_TransformArrayWithInterval(StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_SRA]), SEPARATOR_ARRAY_VALUES_SYMBOL))
        aResultDialog[INDEX_PARAM_TA] := StrTokArr(AllTrim(aParamtrField[2, 2, INDEX_PARAM_TA]), SEPARATOR_ARRAY_VALUES_SYMBOL)

        RU70R0102_SetUserSettings(cIdUser, COUNT_PARAMS_PARAM, cNamePar, aUserSettings)
    Else
        aResultDialog := {}
    EndIf
    
Return aResultDialog

/*/
{Protheus.doc} RU07R1602_IsAcceptButton(aUserParam)

    Checking that the fields are filled.

    @type Static Function
    @params aUserParam, Array, Array of user-entered parameters.
    @author dchizhov
    @since 25.07.2023
    @version 12.1.2210
    @return lResultValidation, Logical, Flag show that need parameters are filled.
    @example oDialog:SetValid({|| RU07R1602_IsAcceptButton(aParamtrField[2, 2])})
/*/
Static Function RU07R1602_IsAcceptButton(aUserParam)

    Local lResultValidation As Logical
    Local cError := ""      As Character

    lResultValidation := .T. // Default value.

    cError += Iif(Len(AllTrim(aUserParam[8])) < 6, STR0012 + CRLF, "") // "Period from"
    cError += Iif(Len(AllTrim(aUserParam[9])) < 6, STR0013 + CRLF, "") // "Period up to"

    If !Empty(cError)
        lResultValidation := .F.
        cError := Iif(Empty(cError), "", STR0091 + CRLF + cError) // "Parameters not filled:"
        MsgStop(cError, STR0090) // "Error"
    EndIf

Return lResultValidation

/*/
{Protheus.doc} RU07R1603_GetStrParam(nMode)

    Create Array by str constant for title, for empty val, for helps in filter-window.

    @type Static Function
    @params nMode, Numeric, 1 (default) - title for params; 2 - empty params; 3 - Array of help; 4 - val for combobox.
    @author dchizhov
    @since 25.07.2023
    @version 12.1.2210
    @return aAraay, Array, Array of empty params or title for params.
    @example aParamtrField[2, 2] := RU07R1603_GetStrParam(2)
/*/
Static Function RU07R1603_GetStrParam(nMode)

    Local aArray  As Array
    Local lSeeAll As Logical

    DEFAULT nMode := 1

    aArray := Array(COUNT_PARAMS_PARAM)

    If nMode == 1
        aArray[ 1] := STR0103 // "Branch from"
        aArray[ 2] := STR0104 // "Branch before"
        aArray[ 3] := STR0105 // "Cost center from"
        aArray[ 4] := STR0106 // "cost center to"
        aArray[ 5] := STR0107 // "Division from"
        aArray[ 6] := STR0108 // "Division before"
        aArray[ 7] := STR0109 // "TN"
        aArray[ 8] := STR0012 // "Period from"
        aArray[ 9] := STR0013 // "Period up to"
        aArray[10] := STR0110 // "by type of absence"
    ElseIf nMode == 2
        lSeeAll := VerSenha(114) .And. VerSenha(115)
        If lSeeAll
            aArray[ 1] := Space(TamSX3("RA_FILIAL")[1])
            aArray[ 2] := Replicate("Z", TamSX3("RA_FILIAL")[1])
        Else
            aArray[ 1] := aArray[ 2] := xFilial("SRA")
        EndIf
        aArray[ 3] := Space(TamSX3("RA_CC")[1])
        aArray[ 4] := Replicate("Z", TamSX3("RA_CC")[1])
        aArray[ 5] := Space(TamSX3("RA_DEPTO")[1])
        aArray[ 6] := Replicate("Z", TamSX3("RA_DEPTO")[1])
        aArray[ 7] := Space(TEXTBOX_MAX_LENGTH)
        aArray[ 8] := Space(6) // CToD("//")
        aArray[ 9] := Space(6) // CToD("//")
        aArray[10] := Space(TEXTBOX_MAX_LENGTH)
    ElseIf nMode == 3
        aArray[ 1] := STR0111 // "Enter or select branch start code to filter data"
        aArray[ 2] := STR0112 // "Enter or select the final branch code to filter data"
        aArray[ 3] := STR0113 // "Enter or select cost center start code to filter data"
        aArray[ 4] := STR0114 // "Enter or select a final cost center code to filter data"
        aArray[ 5] := STR0115 // "Enter or select the starting department to filter data"
        aArray[ 6] := STR0116 // "Enter or select the final department to filter data"
        aArray[ 7] := STR0117 // "Enter or select an employee registration code to filter the data. You can specify multiple values through the ';' character. To specify consecutive data ranges, use a hyphen (1-3), to specify non-consecutive data, use a semicolon (3;5;1)."
        aArray[ 8] := STR0118 // "Enter the start month for data filtering in YYYYMM format"
        aArray[ 9] := STR0119 // "Enter final month to filter data in YYYYMM format"
        aArray[10] := STR0120 // "Enter or select the type of absence for calculating average earnings. You can specify multiple values through the symbol ';' (use semicolon (3;5;1))."
    Else
        aArray := {}
    EndIf

Return aArray

/*/
{Protheus.doc} RU07R1603_GetStrParam(nMode)

    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting type of absence
    into processing bar MsAguarde.

    @type Static Function
    @params cRCMList, Character, Last list of selected types of absence.
    @params cFiltr, Character, filter for view of type absence.
    @author dchizhov
    @since 07.08.2023
    @version 12.1.2210
    @return cTAList, Character, List of type absence.
    @example RU07R1604_GetRCMList(aParamtrField[2, 2, 10], "RCM_TIPOAF = '4'")
/*/
Static Function RU07R1604_GetRCMList(cRCMList, cFiltr)

    Local aTAList      As Array
    Local cTAList      As Character
    Local aTempNumber  As Array
    Local aArea        As Array
    Local lOk          As Logical

    aTAList := {}
    aArea := GetArea()
    aTAList := StrTokArr(AllTrim(cRCMList), SEPARATOR_ARRAY_VALUES_SYMBOL)
    aTempNumber := {}

    MsAguarde({|| lOk := RU07R1605_MakeDialogTemporaryTableRCM(aTAList, @aTempNumber, cFiltr)}, STR0009, STR0100) // "Please wait", "Formation of a data table".

    If lOk
        cTAList := ArrTokStr(aTempNumber, SEPARATOR_ARRAY_VALUES_SYMBOL)
    Else
        cTAList := cRCMList
    EndIf

    RestArea(aArea)

Return cTAList

/*/
{Protheus.doc} RU07R1605_MakeDialogTemporaryTableRCM(aTAList, aRetList, cFiltr)
    The function starts the process of creating a temporary table and 
    displaying information in the form of FWMarkBrowse for selecting type of absence.

    @type Function
    @params cSraList, Array,   Last list of selected employee numbers.
    @params aRetList, Array,   List of selected into window employee numbers.
    @params cFiltr, Character, Filter for view data.
    @author dchizhov
    @since 07.08.2023
    @version 12.1.2210
    @return lOk, Logical, Ok or cancell.
    @example MsAguarde({|| lOk := RU07R1605_MakeDialogTemporaryTableRCM(aTAList, @aTempNumber, cFiltr)}, STR0009, STR0100) // "Please wait", "Formation of a data table".
/*/
Function RU07R1605_MakeDialogTemporaryTableRCM(aTAList, aRetList, cFiltr)

    Local cAlias        As Character
    Local aFields       As Array
    Local aColumns      As Array
    Local oMark         As Object
    Local oDlg          As Object
    Local aTypesList    As Array
    Local oTempTable    As Object
    Local cQuery        As Character
    Local aRCMArea      As Array
    Local aRCMTempData  As Array
    Local aCurArea      As Array
    Local nRCMCount     As Numeric
    Local nI            As Numeric
    Local nSqlStatus    As Numeric
    Local oColumn       As Object
    Local aSeekFields   As Array
    Local aFilterFields As Array
    Local cCurrentFil   As Chaarcter
    Local lOk := .F.    As Logical
    
    aCurArea := GetArea()
    aRCMArea := RCM->(GetArea())
    aRCMTempData := {}
    aTypesList := {}
    aSeekFields := {}
    aFilterFields := {}
    cCurrentFil := FwXFilial("RCM")

    // Defenition fields of temporary table.
    aFields := {}
    aAdd(aFields, {"RCM_OK"    , "C", 1                      , 00})
    aAdd(aFields, {"RCM_TIPO"  , "C", TamSX3("RCM_TIPO")[1]  , 00})
    aAdd(aFields, {"RCM_DESCRI", "C", TamSX3("RCM_DESCRI")[1], 00})
    aAdd(aFields, {"RCM_PD"    , "C", TamSX3("RCM_PD")[1]    , 00})
    aAdd(aFields, {"RCM_CODHOM", "C", TamSX3("RCM_CODHOM")[1], 00})

    // Defenition fields for search.
    /*  Fields array     Title                                 X3_TIPO                          X3_TAMANHO                  X3_DECIMAL          X3_CAMPO         X3_PICTURE             Index #   IsUse */
    aAdd(aSeekFields, {FWX3Titulo("RCM_TIPO")  , {{"", GetSx3Cache("RCM_TIPO"  , "X3_TIPO"), TamSX3("RCM_TIPO")[1]  , TamSX3("RCM_TIPO")[2]  , "RCM_TIPO"  , X3Picture("RCM_TIPO")   }},   1,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RCM_DESCRI"), {{"", GetSx3Cache("RCM_DESCRI", "X3_TIPO"), TamSX3("RCM_DESCRI")[1], TamSX3("RCM_DESCRI")[2], "RCM_DESCRI", X3Picture("RCM_DESCRI") }},   2,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RCM_PD")    , {{"", GetSx3Cache("RCM_PD"    , "X3_TIPO"), TamSX3("RCM_PD")[1]    , TamSX3("RCM_PD")[2]    , "RCM_PD"    , X3Picture("RCM_PD")     }},   3,     .T.   })
    aAdd(aSeekFields, {FWX3Titulo("RCM_CODHOM"), {{"", GetSx3Cache("RCM_CODHOM", "X3_TIPO"), TamSX3("RCM_CODHOM")[1], TamSX3("RCM_CODHOM")[2], "RCM_CODHOM", X3Picture("RCM_CODHOM") }},   4,     .T.   })

    // Defenition fields for filter.
    /*    Fields array     Field          Title                          Type                              X3_TAMANHO                 X3_DECIMAL             X3_PICTURE          */
    aAdd(aFilterFields, {"RCM_TIPO"  , FWX3Titulo("RCM_TIPO")  , GetSx3Cache("RCM_TIPO"  , "X3_TIPO"), TamSX3("RCM_TIPO")[1]  , TamSX3("RCM_TIPO")[2]  , X3Picture("RCM_TIPO")   })
    aAdd(aFilterFields, {"RCM_DESCRI", FWX3Titulo("RCM_DESCRI"), GetSx3Cache("RCM_DESCRI", "X3_TIPO"), TamSX3("RCM_DESCRI")[1], TamSX3("RCM_DESCRI")[2], X3Picture("RCM_DESCRI") })
    aAdd(aFilterFields, {"RCM_PD"    , FWX3Titulo("RCM_PD")    , GetSx3Cache("RCM_PD"    , "X3_TIPO"), TamSX3("RCM_PD")[1]    , TamSX3("RCM_PD")[2]    , X3Picture("RCM_PD")     })
    aAdd(aFilterFields, {"RCM_CODHOM", FWX3Titulo("RCM_CODHOM"), GetSx3Cache("RCM_CODHOM", "X3_TIPO"), TamSX3("RCM_CODHOM")[1], TamSX3("RCM_CODHOM")[2], X3Picture("RCM_CODHOM") })

    cAlias := CriaTrab(Nil, .F.) // Get new alias of your temporary table.
    oTempTable := FWTemporaryTable():New(cAlias) // Create temporary table.
    oTemptable:SetFields(aFields) // Set columns.

    // Create indexes.
    oTempTable:AddIndex(cAlias + "01", {"RCM_TIPO"  }) // Set index 01.
    oTempTable:AddIndex(cAlias + "02", {"RCM_DESCRI"}) // Set index 02.
    oTempTable:AddIndex(cAlias + "03", {"RCM_PD"    }) // Set index 03.
    oTempTable:AddIndex(cAlias + "04", {"RCM_CODHOM"}) // Set index 04.
    
    oTempTable:Create() // Create table.

    // Get type of absence number from RCM table and write it into array aRCMTempData.
    DbSelectArea("RCM")
    RCM->(DbSetOrder(1)) // RCM_FILIAL+RCM_TIPO
    RCM->(DbGoTop())
    RCM->(DbSeek(cCurrentFil))

    While !(RCM->(Eof())) .And. RCM->RCM_FILIAL == cCurrentFil
        If &cFiltr
            aAdd(aRCMTempData, {"0", RCM->RCM_TIPO, RCM->RCM_DESCRI, RCM->RCM_PD, RCM->RCM_CODHOM})
        EndIf

        RCM->(DBSkip())
    EndDo

    nRCMCount := Len(aRCMTempData)

    // Insert employee array into temporary table.
    For nI := 1 To nRCMCount
        cQuery := "INSERT INTO " + oTempTable:GetRealName()
        cQuery += " ( "
        cQuery += "     RCM_OK, "
        cQuery += "     RCM_TIPO, "
        cQuery += "     RCM_DESCRI, "
        cQuery += "     RCM_PD, "
        cQuery += "     RCM_CODHOM "
        cQuery += " ) "
        cQuery += " VALUES "
        cQuery += " ( " 
        cQuery += "   '" + aRCMTempData[nI][1] + "' , " // RCM_OK
        cQuery += "   '" + aRCMTempData[nI][2] + "' , " // RCM_TIPO
        cQuery += "   '" + AllTrim(aRCMTempData[nI][3]) + "' , " // RCM_DESCRI
        cQuery += "   '" + aRCMTempData[nI][4] + "' , " // RCM_PD
        cQuery += "   '" + AllTrim(aRCMTempData[nI][5]) + "' " // RCM_CODHOM
        cQuery += " ) "

        nSqlStatus := TCSqlExec(cQuery)
        If nSqlStatus < 0
            MsgStop(STR0101, STR0090) // "An error occurred when creating a temporary table", "Error"
            Exit
        EndIf

    Next nI

    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    
    // Create array with columns for browse.
    aColumns := {}
    
    For nI := 1 To Len(aFields)
        If (aFields[nI][1] == "RCM_OK")
            Loop
        EndIf

        oColumn := FWBrwColumn():New() // Create a column object.
        oColumn:SetTitle(RetTitle(aFields[nI][1])) // Set title column.
        oColumn:SetData(&("{ || " + aFields[nI][1] + " }")) // Set data column.
        oColumn:SetID(aFields[nI]) // Set id of column.

        // Set size of columns.
        Do Case
            Case aFields[nI][1] == "RCM_TIPO"
                oColumn:SetSize(TamSX3("RCM_TIPO")[1])
                oColumn:SetAlign(CONTROL_ALIGN_CENTER)
            Case aFields[nI][1] == "RCM_DESCRI"
                oColumn:SetSize(TamSX3("RCM_DESCRI")[1])
            Case aFields[nI][1] == "RCM_PD"
                oColumn:SetSize(TamSX3("RCM_PD")[1])
            Case aFields[nI][1] == "RCM_CODHOM"
                oColumn:SetSize(TamSX3("RCM_CODHOM")[1])
            Otherwise
                oColumn:SetSize(20)
        EndCase

        aAdd(aColumns, oColumn) // Add column to array.
    Next nI

    If !Empty(aTAList)

        DbSelectArea(cAlias)
        (cAlias)->(DbGotop())
        While !((cAlias)->(Eof()))

            If aScan(aTAList, (cAlias)->RCM_TIPO) > 0
                (cAlias)->RCM_OK := CMARK_CHAR_FOR_BROWSE
            EndIf

            (cAlias)->(DbSkip())
        EndDo
    EndIf

    // Define dialog for browse.
    DEFINE MSDIALOG oDlg TITLE STR0102 FROM 00,00 TO 500, 800 OF oMainWnd PIXEL // "Select Absence Types"
    
    oMark := FWMarkBrowse():New()
    oMark:SetMark(CMARK_CHAR_FOR_BROWSE, cAlias, "RCM_OK")
    oMark:SetFieldMark('RCM_OK')
    oMark:SetDescription(STR0102) // "Select Absence Types"
    oMark:SetColumns(aColumns)
    oMark:SetAlias(cAlias)
    oMark:DisableReport()
    oMark:SetMenuDef('')
    oMark:SetIgnoreARotina(.T.)
    oMark:SetSeek(.T., aSeekFields)
    oMark:SetTemporary(.T.)
    oMark:SetLocate()
    oMark:SetUseFilter(.T.)
    oMark:SetFilterDefault("")
    oMark:SetFieldFilter(aFilterFields)
    oMark:DisableDetails()
    oMark:SetOwner(oDlg)
    oMark:bAllMark := {|| RU07R1606_MarkAll(oMark, cAlias, "RCM_OK", CMARK_CHAR_FOR_BROWSE, "0")}
    oMark:Refresh()
    oMark:Activate()

    ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| (lOk:=.T.), (oDlg:End())}, {|| oDlg:End()}, , /*aButEnc*/)

    // Defenition selected employee.
    DbSelectArea(cAlias)
    (cAlias)->(DbGotop())
    While !((cAlias)->(Eof()))

        If ((cAlias)->RCM_OK == CMARK_CHAR_FOR_BROWSE)
            Aadd(aTypesList, (cAlias)->RCM_TIPO)
        EndIf

        (cAlias)->(DbSkip())
    EndDo
    aRetList := aTypesList

    // Delete temporary table.
    If oTempTable <> Nil
        oTempTable:Delete()
        oTempTable := Nil
    Endif

    RestArea(aRCMArea)
    RestArea(aCurArea)

Return lOk

/*/
{Protheus.doc} RU07R1606_MarkAll(oBrowsePut, cTempTbl, cFildMark, cMark, cUnMark)
    Mark all records into temporary table.

    @type Function
    @params oBrowsePut, Object, Object of class FWMarkBrowse.
    @params cTempTbl, Character, Alias of temporary table.
    @params cFildMark, Character, Field for mark.
    @params cMark, Character, Symbol of marking.
    @params cUnMark, Character, Symbol of unmarking.
    @author dchizhov
    @since 07.08.2023
    @version 12.1.2210
    @return .T.
    @example oMark:bAllMark := {|| RU07R1606_MarkAll(oMark, cAlias, "RCM_OK", CMARK_CHAR_FOR_BROWSE, "0")}
/*/
Function RU07R1606_MarkAll(oBrowsePut, cTempTbl, cFildMark, cMark, cUnMark)

    Local nRecOri As Numeric
    Local cMarker As Character

    Default cUnMark := "0"

    cMarker := cUnMark
    nRecOri := (cTempTbl)->(RecNo())

    DbSelectArea(cTempTbl)
    (cTempTbl)->(DbGoTop())

    Do While !(cTempTbl)->(Eof())
        If (cTempTbl)->(&cFildMark) <> cMark
            cMarker := cMark
            Exit
        EndIf

        (cTempTbl)->(DbSkip())
    EndDo

    (cTempTbl)->(DbEval({|| (cTempTbl)->(&cFildMark) := cMarker},{|| .T. }))

    oBrowsePut:GoTo(nRecOri, .T.)

Return .T.

/*/
{Protheus.doc} NtoMWD(nMonth)
    Return month in word by given number.
    @type Function
    @params nMonth, Month number. (e.g. 1, 2, 3, 4 ... 12)
    @author konstantin konovalov
    @since 25.08.2023
    @version 12.1.2210
    @return month in word
    @example NtoMWD(1) 
/*/
Function NtoMWD (nMonth)
   Local cResult as Character
 
    Do CASE
        Case nMonth == 1
            cResult:=STR0122
        Case nMonth == 2
            cResult:=STR0123
        Case nMonth == 3
            cResult:=STR0124
        Case nMonth == 4
            cResult:=STR0125
        Case nMonth == 5
            cResult:=STR0126
        Case nMonth == 6
            cResult:=STR0127    
        Case nMonth == 7
            cResult:=STR0128
        Case nMonth == 8
            cResult:=STR0129
        Case nMonth == 9
            cResult:=STR0130
        Case nMonth == 10
            cResult:=STR0131
        Case nMonth == 11
            cResult:=STR0132
        Case nMonth == 12
            cResult:=STR0133
        OTHERWISE
            cResult:=""
    ENDCASE
Return cResult
     
/*/
{Protheus.doc} FmtSNILS(cSNILS)
    Formatting the SNILS number.
    @type Function
    @params cSNILS number.
    @author konstantin konovalov
    @since 28.08.2023
    @version 12.1.2210
    @return formatted SNILS number
    @example 01234567890 -> 012-345-678 90 
/*/
Function FmtSNILS(cSNILS)
    Local cResult As Chaarcter
    Local nI      As Numeric

    cResult := ""
    for nI:= 1 To Len(cSNILS)
        cResult += SubStr(cSNILS, nI, 1)
        if(nI == 3 .Or. nI == 6)
            cResult += "-"
        elseif (nI == 9)
            cResult += " "
        End if
    Next nI

Return cResult

/*/
{Protheus.doc} FmtNumD(cNumber)
    Formatting amount of money.
    @type Function
    @params cNumber amount.
    @author konstantin konovalov
    @since 30.08.2023
    @version 12.1.2210
    @return formatted money 
    @example from 22870990.00 -> 22'870'990.00 
    negative amounts are supported
/*/
Function FmtNumD(cNumber)
    Local cResult As Character
    Local nI      As Numeric
    Local nSign   As Numeric
    Local nRemd   As Numeric
    Local lIntN   As Logical

    // Decimal position:
    nDec := AT('.', cNumber) 
    if nDec == 0
        //number without decimal part
        nDec := Len(cNumber)
        lIntN:=.T.
    else
        lIntN := .F.
        nDec := nDec - 1        
    Endif
     // Sign correction
    nSign := 0
    if Val(cNumber) < 0
        nSign := 1
    endif

    if (nDec - nSign) > 3
        cResult := ""
        nRemd := (nDec - nSign) % 3       
        //Main work here:
        for nI:= 1 To nDec
            cResult += SubStr(cNumber, nI, 1)
            if ((nI - nSign) > 0 .And. ((nI + nSign) == nRemd  .Or. ((nI - nSign) % 3) == nRemd) .And. nI < nDec)
                cResult += "'"
            End if
        Next nI
        //final construct (add decimal part if exist):
        if !lIntN
            cResult+= SubStr(cNumber, nDec+1, Len(cNumber)- (nDec+1) +1)
        Endif
    else
       cResult := cNumber 
    endif
Return cResult

/*/
{Protheus.doc} GetIntrDesc(cMatFil, cMatNum, cPrd)
    Get the 'SR8_DATAINI - SR8_DATAFIM' as string description for given r8_filial, r8_mat and r8_per
    @type Function
    @params cMatFil - filial, cMatNum - service number, cPrd - calculation period.
    @author konstantin konovalov
    @since 30.08.2023
    @version 12.1.2210
    @return formatted money 
    @example
/*/
Function GetIntrDesc(cMatFil, cMatNum, cPrd)
    Local aSaveArea As Array
    Local cQuery    As Character
    Local cAlias    As Character
    Local cResult   As Character
    Local nCount    As Numeric
    Local aValues   As Array    
    
    cResult := ""
    nCount := 1
    aValues := {}
    aSaveArea := GetArea()

    cQuery := " SELECT R8_DATAINI DATAINI, R8_DATAFIM DATAFIM, R8_DURACAO DURACAO FROM " + RetSQLName("SR8") + " WHERE "
    cQuery += " R8_FILIAL = ? "
    cQuery += " AND R8_MAT = ? "
    cQuery += " AND R8_PER = ? "
    cQuery += " AND D_E_L_E_T_ = ' ' "

    AAdd(aValues, cMatFil)
    AAdd(aValues, cMatNum)
    AAdd(aValues, cPrd)
   
    cAlias := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TcGenQry2(,, cQuery, aValues), cAlias, .T., .F.)
    DbSelectArea(cAlias)
    DbGoTop()

    While !((cAlias)->(Eof()))
        if nCount > 1
            cResult += "; "
        endif
        cResult += (DToC(SToD((cAlias)->DATAINI)) + "-" + DToC(SToD((cAlias)->DATAFIM))) 
        nCount ++ 
        (cAlias)->(DbSkip())
    EndDo

    DBCloseArea()
    RestArea(aSaveArea)
Return cResult
