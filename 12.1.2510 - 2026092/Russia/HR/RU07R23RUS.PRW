#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RU07R23RUS.CH"

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE SEPARATOR_ARRAY_INTERVAL_SYMBOL "-"

#DEFINE WINDOW_HEIGHT_SIZE 250
#DEFINE WINDOW_WIDTH_SIZE 300

#DEFINE TEXTBOX_WIDTH_SIZE 180
#DEFINE TEXTBOX_HEIGHT_SIZE 10
#DEFINE TEXTBOX_MAX_LENGTH 250

#DEFINE LABEL_WIDTH_SIZE 60
#DEFINE LABEL_HEIGHT_SIZE 15

#DEFINE BUTTON_HEIGHT 012
#DEFINE BUTTON_WIDTH 040

#DEFINE SEPARATOR_ARRAY_VALUES_SYMBOL ";"
#DEFINE SRA_STR_MAX_LENGHT 250
#DEFINE COUNT_PARAMS_PARAM 14
#DEFINE NAME_OF_PROGRAM "RU07R23RUS"
#DEFINE NAME_OF_PROGRAM_PAR "RU07R23PAR"
#DEFINE INDEX_PARAM_COMBOBOX "1"
#DEFINE INDEX_PARAM_SIGNER "3"
#DEFINE INDEX_PARAM_SRA 13

#DEFINE TAXABLE_INCOME "991"
#DEFINE NDFL_ADI "412"
#DEFINE NDFL_FOL "413"
#DEFINE NDFL_DEDUCTION "675"
#DEFINE FOR_ME "501|502|503|504|505|506|507|508|509|510"
#DEFINE FOR_CHILD "126|127|128|129|130|131|132|133|134|135|136|137|138|139|140|141|142|143|144|145|146|147|148|149"
#DEFINE FOR_PROPERTY "311|312"
#DEFINE FOR_SOCIAL "320|321|324|325|326"

#DEFINE PREPAID_EXPENSE "872"
#DEFINE DEBT "395"
#DEFINE GRAND_TOTAL "870"
#DEFINE ADVANCE_WITHHELD "410"
#DEFINE DEBT_PRE_MONTH "446"
#DEFINE CODE_PREPAYMENT "250"

#DEFINE INDEX_PARAM_REVENUE "1"
#DEFINE INDEX_PARAM_DISCOUNT "2"

#DEFINE CRLF Chr(13)+Chr(10)

/*/
{Protheus.doc} RU07R23()

    Main function of report by average payment for holiday.

    @type Function
    @params 
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return 
    @example RU07R23()
/*/
Function RU07R23()

    Local aParameter As Array
    Local lRet          As Logical
    Local aData      As Array
    Local cNotIni       As Character 
    Local cNotFil       As Character    
 
    aParameter := {}
    lRet    :=  Pergunte("RU07R23P", .T.)
    If(lRet)
        aAdd(aParameter, MV_PAR01)
        aAdd(aParameter, MV_PAR02)
        aAdd(aParameter, MV_PAR03)
        aAdd(aParameter, MV_PAR04)
        aAdd(aParameter, MV_PAR05)
        aAdd(aParameter, MV_PAR06)
        aAdd(aParameter, MV_PAR07)
        aAdd(aParameter, MV_PAR08)
        aAdd(aParameter, MV_PAR09)

        If (!Empty(aParameter[8]) .And. !Empty(aParameter[9])) .And. ;
               (Empty(aParameter[1]) .And. Empty(aParameter[2]) .And. Empty(aParameter[3]) .And. Empty(aParameter[4]) .And. Empty(aParameter[5]) .And. Empty(aParameter[6]) .And. Empty(aParameter[7]))
            
            aParameter[7] := SRA->RA_MAT
            aData := RU07R2301_GetData(aParameter)
            If len(aData) > 0
                RU07R23Frm(aData)
            EndIf
        Else
            aData := RU07R2301_GetData(aParameter)
            If len(aData) > 0
                RU07R23Frm(aData)
            EndIf
        EndIf
        
    EndIf

Return .T.


/*/
{Protheus.doc} RU07R2301_GetData(aParameter)

    Check parameter.

    @type Function
    @params aParam, Array, Array of parameter wich entering the user.
    @author dchizhov
    @since 02.08.2023
    @version 12.1.2210
    @return lResult, Logical, Param valid or no valid.
    @example aData := RU07R2301_GetData(aParameter)
/*/
Function RU07R2301_GetData(aParameter)

    Local oStatement      As Object
    Local cQuery          As Character 
    Local aArea           As Array
    Local cTab            As Character
    Local aResult         As Array
    Local aTemp           As Array
    Local aGetCoBrRusInfo As Array
    Local nI              as Numeric
    Local nCount          as Numeric
    Local aCData          as Array
    Local aTemp2          As Array
    Local aTemp3          As Array
    Local aTemp4          As Array
    Local nNDFL           as Numeric
    Local nX              as Numeric
    Local nFulPay         as Numeric
    Local nSum1           as Numeric
    Local nSum2           as Numeric
    Local nOldPay         as Numeric
    Local nDebt1          as Numeric
    Local nDebt2          as Numeric
    Local nDebtCom1       as Numeric
    Local nDebtCom2       as Numeric
    Local cUnic           as Character
    Local aTransfArr      as Array
    Local aOldPayArr      as Array
    Local nAllSumm        as Numeric
    Local cTab2           As Character
    Local cStructCodeF    As Character
    Local cHeder          As Character

    aResult := {}
    aOldPayArr := {}
    aTemp := {}
    aTemp3 := {}
    aTemp4 := {}
    aTemp2 := {0, 0, 0, 0}
    nFulPay := 0
    nSum1 := 0
    nSum2 := 0
    nNDFL := 0
    nOldPay := 0
    nDebt1 := 0
    nDebt2 := 0
    nDebtCom1 := 0
    nDebtCom2 := 0
    nAllSumm := 0

    aGetCoBrRusInfo := GetCoBrRUS(SRA->RA_FILIAL)
    aCData := FwComAltInf({'CO_OKPO', 'CO_FULLNAM', 'CO_COMPGRP', 'CO_COMPEMP', 'CO_TIPO', 'CO_PHONENU', 'CO_COMPUNI'})

    aArea := GetArea()
    
    cQuery := "SELECT A.RD_MAT || C.RA_CARGO || A.RD_DEPTO || A.RD_CC || A.RD_PERIODO AS SD,A.RD_MAT AS CMAT, C.RA_NOMECMP AS CNOMECMP, "
    cQuery += " A.RD_DEPTO AS CDEPTO, A.RD_CC AS CCC, E.QB_DESCRIC AS CDEPDESC, F.CTT_DESC01 AS CCCDESC, B.RV_HE, "
    cQuery += " A.RD_PD AS CCODVO, B.RV_DESC AS CNAMECOD,  A.RD_VALOR AS NVALOR, A.RD_PROCES AS CPROCES, B.RV_DESC AS CPDDESC, "
    cQuery += " A.RD_ROTEIR AS CROTEIR, A.RD_HORAS AS NHORAS, A.RD_PERIODO AS CPERIOD, B.RV_COD AS CRVCOD, A.RD_CONVOC AS CCONVOC, B.RV_TIPOCOD AS CTIPOCOD, "
    cQuery += " C.RA_CARGO AS CCARGO, D.Q3_DESCSUM AS CCARGODESC, C.RA_SALARIO AS NSALARIO, A.RD_DATPGT AS CDATPAY, A.RD_FILIAL AS CFILIAL FROM " + RetSQLName("SRD") + " A "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SRA") + " C ON  A.RD_MAT = C.RA_MAT "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SRV") + " B ON  A.RD_PD = B.RV_COD "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SQ3") + " D ON D.Q3_CARGO = C.RA_CARGO "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SQB") + " E ON A.RD_DEPTO = E.QB_DEPTO "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("CTT") + " F ON A.RD_CC = F.CTT_CUSTO AND A.RD_FILIAL = F.CTT_FILIAL "

    cQuery += "WHERE "
    if ALLTRIM(APARAMETER[1]) <> "" .And. ALLTRIM(APARAMETER[2]) <> ""
        cQuery += " (A.RD_FILIAL BETWEEN '" + aParameter[1] + "' AND '" + aParameter[2] + "') AND "
    Endif
    
    if ALLTRIM(APARAMETER[3]) <> "" .And. ALLTRIM(APARAMETER[4]) <> ""
        cQuery += " (A.RD_CC BETWEEN '" + aParameter[3] + "' AND '" + aParameter[4] + "') AND "
    Endif

    if ALLTRIM(APARAMETER[5]) <> "" .And. ALLTRIM(APARAMETER[6]) <> ""
        cQuery += " (A.RD_DEPTO BETWEEN '" + aParameter[5] + "' AND '" + aParameter[6] + "') AND "
    Endif

    if ALLTRIM(APARAMETER[8]) <> "" .And. ALLTRIM(APARAMETER[9]) <> ""
        cQuery += " (A.RD_PERIODO BETWEEN '" + DateOld(aParameter[8]) + "' AND '" + aParameter[9] + "') AND "
    Endif

    If !Empty(APARAMETER[7]) 
        aTransfArr := StrTokArr(APARAMETER[7], SEPARATOR_ARRAY_VALUES_SYMBOL)
        cFiltrFil := RU07R2306_TransformArray(aTransfArr, 1)
    Else
        cFiltrFil := ""
    EndIf
    cQuery += cFiltrFil + " A.D_E_L_E_T_ = ' ' "
    
    cQuery += "UNION ALL SELECT A.RC_MAT || C.RA_CARGO || A.RC_DEPTO || A.RC_CC || A.RC_PERIODO AS SD,A.RC_MAT AS CMAT, C.RA_NOMECMP AS CNOMECMP, "
    cQuery += " A.RC_DEPTO AS CDEPTO, A.RC_CC AS CCC, E.QB_DESCRIC AS CDEPDESC, F.CTT_DESC01 AS CCCDESC, B.RV_HE, "
    cQuery += " A.RC_PD AS CCODVO, B.RV_DESC AS CNAMECOD,  A.RC_VALOR AS NVALOR, A.RC_PROCES AS CPROCES, B.RV_DESC AS CPDDESC, "
    cQuery += " A.RC_ROTEIR AS CROTEIR, A.RC_HORAS AS NHORAS, A.RC_PERIODO AS CPERIOD, B.RV_COD AS CRVCOD, A.RC_CONVOC AS CCONVOC, B.RV_TIPOCOD AS CTIPOCOD, "
    cQuery += " C.RA_CARGO AS CCARGO, D.Q3_DESCSUM AS CCARGODESC, C.RA_SALARIO AS NSALARIO, A.RC_DATA AS CDATPAY, A.RC_FILIAL AS CFILIAL FROM " + RetSQLName("SRC") + " A "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SRA") + " C ON  A.RC_MAT = C.RA_MAT "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SRV") + " B ON  A.RC_PD = B.RV_COD "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SQ3") + " D ON D.Q3_CARGO = C.RA_CARGO "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SQB") + " E ON A.RC_DEPTO = E.QB_DEPTO "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("CTT") + " F ON A.RC_CC = F.CTT_CUSTO AND A.RC_FILIAL = F.CTT_FILIAL  "

    cQuery += "WHERE  "

    if ALLTRIM(APARAMETER[1]) <> "" .And. ALLTRIM(APARAMETER[2]) <> ""
        cQuery += " (A.RC_FILIAL BETWEEN '" + aParameter[1] + "' AND '" + aParameter[2] + "') AND "
    Endif
    
    if ALLTRIM(APARAMETER[3]) <> "" .And. ALLTRIM(APARAMETER[4]) <> ""
        cQuery += " (A.RC_CC BETWEEN '" + aParameter[3] + "' AND '" + aParameter[4] + "') AND "
    Endif

    if ALLTRIM(APARAMETER[5]) <> "" .And. ALLTRIM(APARAMETER[6]) <> ""
        cQuery += " (A.RC_DEPTO BETWEEN '" + aParameter[5] + "' AND '" + aParameter[6] + "') AND "
    Endif

    if ALLTRIM(APARAMETER[8]) <> "" .And. ALLTRIM(APARAMETER[9]) <> ""
        cQuery += " (A.RC_PERIODO BETWEEN '" + DateOld(aParameter[8]) + "' AND '" + aParameter[9] + "') AND "
    Endif
    
    If !Empty(APARAMETER[7]) 
        aTransfArr := StrTokArr(APARAMETER[7], SEPARATOR_ARRAY_VALUES_SYMBOL)
        cFiltrFil := RU07R2306_TransformArray(aTransfArr, 2)
    Else
        cFiltrFil := ""
    EndIf
    cQuery += cFiltrFil + " A.D_E_L_E_T_ = ' ' "
    
    cQuery += "ORDER BY  "
    cQuery += "CNOMECMP, CPERIOD, CPERIOD, CCC, CDEPTO "

    oStatement := FWPreparedStatement():New(cQuery)
    
    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
        
    cUnic := ''
    If !((cTab)->(EOF()))
        While !((cTab)->(EOF()))
            If CCODVO == '870'
                Aadd(aOldPayArr, {(cTab)->SD, (cTab)->CDATPAY, (cTab)->NVALOR})
            EndIf
            
            If val((cTab)->CPERIOD) >= val(aParameter[8])
                If len(aTemp) == 0 
                    aCompanyInfo := RU07R2309_GetBranchInfo(ALLTRIM((cTab)->CFILIAL))
                    Aadd(aTemp, STR0003 + " " + RU07R2307_GetMonthName(VAL(RIGHT( (cTab)->CPERIOD, 2 ))) + " " + left((cTab)->CPERIOD, 4) + " " + STR0004)  // Monthly payslip MMMM YYYY year
                    Aadd(aTemp, STR0005 + " " + aCompanyInfo[3])                                                                                            // Organization:
                    Aadd(aTemp, STR0006 + " " + ALLTRIM((cTab)->CNOMECMP))                                                                                  // FULL NAME. employee:
                    Aadd(aTemp, STR0007 + " " + ALLTRIM((cTab)->CMAT))                                                                                      // Personnel Number:
                    Aadd(aTemp, STR0008 + " " + RIGHT( (cTab)->CPERIOD, 2 ) + "/" + left((cTab)->CPERIOD, 4))                                               // Accrual period:
                    Aadd(aTemp, STR0009 + " " + ALLTRIM((cTab)->CDEPDESC))                                                                                  // Subdivision:
                    Aadd(aTemp, STR0010 + " " + ALLTRIM((cTab)->CCARGODESC))                                                                                // Job title:
                    Aadd(aTemp, STR0011 + " " + CVALTOCHAR(Transform((cTab)->NSALARIO, GetSx3Cache( "RC_VALOR", "X3_PICTURE" ))))                           // Position salary:
                    Aadd(aTemp, STR0012 + " " + DToC(Date()))                                                                                               // The payslip was handed over to the employee:
                    cUnic := SD
                EndIf

                If cUnic != SD
                    Aadd(aTemp, Transform(nFulPay, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nSum1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nSum2 + nNDFL + nOldPay, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nNDFL, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nOldPay, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nDebt1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nDebt2, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nDebtCom1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nDebtCom2, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
                    Aadd(aTemp, Transform(nAllSumm, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))

                    AAdd(aResult, {ACLONE(aTemp), ACLONE(aTemp2), ACLONE(aTemp3),ACLONE(aTemp4)})

                    aTemp := {}
                    aTemp3 := {}
                    aTemp4 := {}
                    aTemp2 := {0, 0, 0, 0}

                    nFulPay := 0
                    nSum1 := 0
                    nSum2 := 0
                    nNDFL := 0
                    nOldPay := 0
                    nDebt1 := 0
                    nDebt2 := 0
                    nDebtCom1 := 0
                    nDebtCom2 := 0
                    nAllSumm := 0
                EndIf

                If CCODVO $ NDFL_DEDUCTION .AND. ALLTRIM( CROTEIR ) == 'FOL'
                    if ALLTRIM(CCONVOC) $ FOR_ME
                        aTemp2[1] += (cTab)->NVALOR
                    elseif ALLTRIM(CCONVOC) $ FOR_CHILD
                        aTemp2[2] += (cTab)->NVALOR
                    elseif ALLTRIM(CCONVOC) $ FOR_PROPERTY
                        aTemp2[3] += (cTab)->NVALOR
                    elseif ALLTRIM(CCONVOC) $ FOR_SOCIAL
                        aTemp2[4] += (cTab)->NVALOR
                    EndIf
                EndIf

                If CCODVO $ GRAND_TOTAL
                    nFulPay := (cTab)->NVALOR
                    If left(CDATPAY, 6) != CPERIOD
                        nDebtCom1 := (cTab)->NVALOR
                    EndIf
                    nX := 0
                    nX :=  Ascan(aOldPayArr,{|x| x[1]==CMAT + CCARGO + CDEPTO + CCC + DateOld(CPERIOD) })
                    If nX > 0
                        If DateOld(CPERIOD) != left(aOldPayArr[nX][2],6)
                            nDebtCom1 := aOldPayArr[nX][3]
                        EndIf
                    EndIf
                ElseIf CCODVO $ TAXABLE_INCOME
                    nAllSumm := (cTab)->NVALOR
                ElseIf !(CCODVO $ DEBT ) .AND. (cTab)->CTIPOCOD == INDEX_PARAM_REVENUE .AND. ALLTRIM( CROTEIR ) == 'FOL'
                    Aadd(aTemp3, {(cTab)->CNAMECOD, (cTab)->CCODVO, (cTab)->NHORAS, Transform((cTab)->NVALOR, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) } )
                    nSum1 += (cTab)->NVALOR
                ElseIf !(CCODVO $ NDFL_ADI .OR. CCODVO $ NDFL_FOL .OR. CCODVO $ ADVANCE_WITHHELD .OR. CCODVO $ DEBT_PRE_MONTH ) .AND. (cTab)->CTIPOCOD == INDEX_PARAM_DISCOUNT  .AND. ALLTRIM( CROTEIR ) == 'FOL'
                    Aadd(aTemp4, {(cTab)->CNAMECOD, (cTab)->CCODVO, Transform((cTab)->NVALOR, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )) } )
                    nSum2 += (cTab)->NVALOR
                ElseIf (CCODVO $ NDFL_ADI .OR. CCODVO $ NDFL_FOL)
                    nNDFL += (cTab)->NVALOR
                ElseIf CCODVO $ PREPAID_EXPENSE .AND. ALLTRIM( CROTEIR ) == 'ADI'
                    nOldPay += (cTab)->NVALOR
                ElseIf CCODVO $ DEBT_PRE_MONTH  
                    nDebt1 += (cTab)->NVALOR
                ElseIf CCODVO $ DEBT
                    nDebt2 += (cTab)->NVALOR
                EndIf
                
            EndIf
            (cTab)->(DbSkip())
        EndDo
        
        Aadd(aTemp, Transform(nFulPay, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nSum1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nSum2, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nNDFL, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nOldPay, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nDebt1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nDebt2, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nDebtCom1, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nDebtCom2, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))
        Aadd(aTemp, Transform(nAllSumm, GetSx3Cache( "RC_VALOR", "X3_PICTURE" )))

        if len(aTemp) >= 19
            AAdd(aResult, {ACLONE(aTemp), ACLONE(aTemp2), ACLONE(aTemp3),ACLONE(aTemp4)})
        Endif

        aTemp := {}
        aTemp3 := {}
        aTemp4 := {}
        aTemp2 := {0, 0, 0, 0}
        
        (cTab)->(DBCloseArea())
        oStatement:Destroy()
        FwFreeObj(oStatement)
        
    Else
        MsgInfo("", STR0002)
        aResult := {}
    ENDIF

    RestArea(aArea)




Return aResult



/*/
{Protheus.doc} RU07R2308_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
    The function receives data about selected company. If no data about selected company - get data abaout hight structure/
    Get data from SYS_COMPANY and SYS_COMPANY_L_RUS (SIGACFG).

    @type Function
    @params aCampo,       Array,     Array fields in CO which mast received ({{Field_From_DB, Alias_Field}...})
    @params cGroupCode,   Character, Code group of company.
    @params cCodeCompany, Character, Code company.
    @params cCodeUnit,    Character, Cod bussines unit.
    @author dchizhov
    @since 03.08.2023
    @version 12.1.2210
    @return aResult, Array, Received Information.
    @example aCompanyInfo := GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)
/*/
Function RU07R2308_GetHCompanyInfo(aCampo, cGroupCode, cCodeCompany, cCodeUnit)

    Local oStatement     As Object
    Local cQuery         As Character 
    Local aArea          As Array
    Local cTab           As Character
    Local aResult := { } As Logical
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
                AAdd(aResult, {aCampo[nI, 2], Alltrim((cTab)->(&(aCampo[nI, 2])))})
            Next nI
            AAdd(aResult, {"cCodeCompany", cCodeCompany})
            AAdd(aResult, {"cCodeUnit", cCodeUnit})
            AAdd(aResult, {"CO_COMPGRP", (cTab)->CO_COMPGRP})
            AAdd(aResult, {"CO_COMPEMP", (cTab)->CO_COMPEMP})
            AAdd(aResult, {"CO_COMPUNI", (cTab)->CO_COMPUNI})
            AAdd(aResult, {"CO_TIPO", (cTab)->CO_TIPO})
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





/*/{Protheus.doc} AddRowArray(aArr as array)
    Adds a string to an array with a specific pattern

    @type  Static Function
    @author iprokhorenko
    @since 24/08/2023
    @version 12.1.2210
    @param aArr, array, array pattern
    @return aRes, array, array data
    @example aAdd(aResult, aclone(AddRowArray(aArr )))
    
/*/
Static Function AddRowArray(aArr as array)
    Local aRes as array
    Local nI as Numeric
    
    aRes := {}
    For nI := 1 to Len(aArr)
        If aArr[nI] == "C"
            aAdd(aRes, "")
        ElseIf aArr[nI] == "N"
            aAdd(aRes, 0)
        EndIf
    Next 

Return aRes




/*/
{Protheus.doc} RU07R2307_GetMonthName(nMonthNumber)
    Function return name of month.

    @type Static Function
    @params nMonthNumber, Numeric, Month number.
    @author iprokhorenko
    @since 25.02.2023
    @version 12.1.33
    @return cMonthName, Character, Description month.
    @example cMonthName := RU07R2307_GetMonthName(Month(SRA->RA_ADMISSA))
/*/
Static Function RU07R2307_GetMonthName(nMonthNumber)
    Local cMonthName As Character

    Do Case
        Case nMonthNumber == 1
            cMonthName := STR0018       // January
        Case nMonthNumber == 2
             cMonthName := STR0019      // February
        Case nMonthNumber == 3
             cMonthName := STR0020      // March
        Case nMonthNumber == 4
             cMonthName := STR0021      // April
        Case nMonthNumber == 5
             cMonthName := STR0022      // May
        Case nMonthNumber == 6
             cMonthName := STR0023      // June
        Case nMonthNumber == 7
             cMonthName := STR0024      // July
        Case nMonthNumber == 8
             cMonthName := STR0025      // August
        Case nMonthNumber == 9
             cMonthName := STR0026      // September
        Case nMonthNumber == 10
             cMonthName := STR0027      // October
        Case nMonthNumber == 11
             cMonthName := STR0028      // November
        Case nMonthNumber == 12
             cMonthName := STR0029      // December
        Otherwise
            cMonthName := ""
    EndCase
    
Return cMonthName

/*/
{Protheus.doc} RU07R2306_TransformArray()
    Create sql filter	
	@type Function
    @params 
		aTransfArr, Array, array to be converted
		nCodeOp, Numeric, operation number
		[1] - Create sql filter for F54_CLIENT
		[2] - Create sql filter for F54_CLIBRA
		
    @author eprokhorenko
    @since 9/10/2023
    @version 
    @return cFilter, Character, filter for sql query
    @example RU07R2306_TransformArray(aTransfArr, cCodeOp)
/*/


Static Function RU07R2306_TransformArray(aTransfArr, nCodeOp)
    Local aTempArray 		As Array
    Local aInterList		As Array
    Local aList			As Array
    Local nI				As Numeric

    aInterList := {}
    aList		:= {}
    
    For nI := 1 To Len(aTransfArr)
        aTempArray := StrTokArr(aTransfArr[nI], SEPARATOR_ARRAY_INTERVAL_SYMBOL)
        If Len(aTempArray) > 1
            Aadd(aInterList, aTempArray[1])
            Aadd(aInterList, aTempArray[2])
        Else
            If !Empty(aTempArray[1])
                Aadd(aList, aTempArray[1])
            EndIf
        EndIf
    Next

    If !Empty(aList)
        If nCodeOp == 1
            cFilter := " (A.RD_MAT IN ("
        ElseIf nCodeOp == 2
            cFilter := " (A.RC_MAT IN ("
        EndIf

        For nI := 1 To Len(aList)
            cFilter += "'" + aList[nI] + "'"
            If nI != Len(aList)
                cFilter += ", "
            Else 
                cFilter += ") "
            EndIf
        Next
    EndIf

	For nI := 1 To Len(aInterList) Step 2
		If Empty(aList) .AND. nI == 1
			If nCodeOp == 1
				cFilter += " (A.RD_MAT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " (A.RC_MAT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			EndIf
		Else
			If nCodeOp == 1
				cFilter += " OR A.RD_MAT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			ElseIf nCodeOp == 2
				cFilter := " OR A.RC_MAT BETWEEN " + "'" + aInterList[nI] + "' AND '" + aInterList[nI+1] + "'"
			EndIf
		EndIf
	Next
	cFilter += ") AND "	
Return cFilter



/*/{Protheus.doc} DateOld(cDate)
    Adds a string to an array with a specific pattern

    @type  Static Function
    @author iprokhorenko
    @since 24/08/2023
    @version 12.1.2210
    @param aArr, array, array pattern
    @return aRes, array, array data
    @example aAdd(aResult, DateOld(cDate)))
    
/*/
Static Function DateOld(cDate)
    Local cYear as Character
    Local cMonth as Character
    Local cDateOld as Character

    Local nYear as Numeric
    Local nMonth as Numeric
    
    nYear := VAL(Left(cDate, 4))
    nMonth := VAL(Right(cDate, 2))

    If nMonth == 1
        cYear := CVALTOCHAR(nYear - 1)
        cMonth := CVALTOCHAR(12)
    Else
        cMonth := CVALTOCHAR(nMonth - 1)
        cYear := CVALTOCHAR(nYear)
    EndIf
    
    If len(cMonth) == 1
        cMonth := "0" + cMonth
    EndIf

    cDateOld := cYear + cMonth
    
Return cDateOld



/*/
{Protheus.doc} RU07R2309_GetBranchInfo()
    Get information about filial(branch)
    @type Function
    @params cTN  , Character, Employ

    @author iprokhorenko
    @since 2024/01/09
    @version 
    @return aBranchInfo
            aBranchInfo[1] - BR_TYPE // Type of filial
            aBranchInfo[2] - BR_KPP // KPP. 
            aBranchInfo[3] - BR_FULLNAM // Full name of the branch
    @example RU07R2309_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/
Static Function RU07R2309_GetBranchInfo(cTN)
    Local cQuery := "" As Character
    Local oStatement := Nil As Object
    Local aArea := GetArea() As Array
    Local aBranchInfo := {} As Array
    Local cGroupCode As Character
    Local cCompanyCode As Character
    Local cBusUnitCode As Character
    Local cFilialCode As Character
    
    cGroupCode := FWGrpCompany()
    cCompanyCode := Left( cTN, 2 )
    cBusUnitCode := SUBSTR( cTN, 3, 2)
    cFilialCode := Right( cTN, 2 )

    // Make SQL query.
    cQuery := " SELECT BR_BRANCH, BR_TYPE, BR_FULLNAM, BR_KPP "
    cQuery += " FROM SYS_BRANCH_L_RUS " 
    cQuery += " WHERE "
    cQuery += "     BR_COMPGRP = ? "
    cQuery += " AND BR_COMPEMP = ? "
    cQuery += " AND BR_COMPUNI = ? "
    cQuery += " AND BR_BRANCH  = ? "
    cQuery += " AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New(cQuery)
    oStatement:SetString(1, cGroupCode  )
    oStatement:SetString(2, cCompanyCode)
    oStatement:SetString(3, cBusUnitCode)
    oStatement:SetString(4, cFilialCode )

    cTab := MPSysOpenQuery(oStatement:GetFixQuery())

    DBSelectArea(cTab)
    (cTab)->(DbGoTop())
    
    While !(cTab)->(Eof())
        
        aAdd(aBranchInfo, Alltrim((cTab)->BR_TYPE)) // Type of filial.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_KPP )) // KPP.
        aAdd(aBranchInfo, Alltrim((cTab)->BR_FULLNAM))// Full name of the branch

        (cTab)->(DbSkip())
    EndDo

    (cTab)->(DBCloseArea())

    If Type("oStatement") <> "U"
        oStatement:Destroy()
        FwFreeObj(oStatement)
    EndIf

    RestArea(aArea)

Return aBranchInfo




/*/
{Protheus.doc} RU07R23010()
    Check data in field TN
    @type Function

    @author iprokhorenko
    @since 2024/03/09
    @version 
    @return lRes
    @example RU07R2309_GetBranchInfo(cGroupCode, cCompanyCode, cBusUnitCode, cFilialCode)
/*/

Function RU07R23010()
    Local lValid := .F. As Logical
    Local aEmpNumbers := {} As Array
    Local nI := 0 As Numeric
    Local aArea := GetArea() As Array
    Local aSRAArea := SRA->(GetArea()) As Array

    Local cEmpNumbers := ""

    cEmpNumbers := AllTrim(MV_PAR07)
    aEmpNumbers := StrToKArr(cEmpNumbers, ";*-")

    If Empty(cEmpNumbers)
        lValid := .T.
    Else
        DbSelectArea("SRA")
        SRA->(DbSetOrder(1)) // "RA_FILIAL+RA_MAT+RA_NOME".

        For nI := 1 To Len(aEmpNumbers)
            If !Empty(aEmpNumbers[nI])
                SRA->(DbGoTop())
                lValid := SRA->(DbSeek(FwXFilial("SRA") + PadR(aEmpNumbers[nI], TamSX3("RA_MAT")[1])))

                If !lValid
                    // "Error", "Error in the field", "TN", "Not found a record", "Select existed record"
                    Help( ,, STR0048,, STR0049 + " " + STR0050 + CRLF + STR0051 + ": " + aEmpNumbers[nI], 1,,,,,,, {STR0052})
                    Exit
                EndIf
            EndIf
        Next nI

        SRA->(DbCloseArea())
    EndIf

    SRA->(RestArea(aSRAArea))
    RestArea(aArea)

Return lValid
