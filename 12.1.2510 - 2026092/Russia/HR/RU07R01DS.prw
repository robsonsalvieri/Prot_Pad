#Include "protheus.ch"
#Include "Birtdataset.ch"
#Include "TOPCONN.CH"
#Include "FileIO.CH"

Dataset RU07R01DS
    Title "2NDFL"
    Description "Print BirtTest"
    PERGUNTE "RU07R01DS"

Columns

Define Column Period TYPE Character SIZE 4 LABEL 'Period' //

Define Column NowDay TYPE Character SIZE 2 LABEL 'NowDay' //
Define Column NowMonth TYPE Character SIZE 2 LABEL 'NowMonth' //
Define Column NowYear TYPE Character SIZE 4 LABEL 'NowYear' //

Define Column CO_OKTMO TYPE Character SIZE 100 LABEL 'CO_OKTMO' //
Define Column CO_PHONENU TYPE Character SIZE 100 LABEL 'CO_PHONENU' //
Define Column CO_INN TYPE Character SIZE 100 LABEL 'CO_INN' //
Define Column CO_KPP TYPE Character SIZE 100 LABEL 'CO_KPP' //
Define Column CO_SHORTNM TYPE Character SIZE 100 LABEL 'CO_SHORTNM' //

Define Column RA_PIS TYPE Character SIZE 100 LABEL 'RA_PIS' //
Define Column RA_PRISOBR TYPE Character SIZE 100 LABEL 'RA_PRISOBR' //
Define Column RA_PRINOME TYPE Character SIZE 100 LABEL 'RA_PRINOME' //
Define Column RA_SECNOME TYPE Character SIZE 100 LABEL 'RA_SECNOME' //
Define Column RA_CLASEST TYPE Character SIZE 100 LABEL 'RA_CLASEST' //
Define Column RA_NACIONC TYPE Character SIZE 100 LABEL 'RA_NACIONC' //
Define Column RA_NUMEPAS TYPE Character SIZE 100 LABEL 'RA_NUMEPAS' //
Define Column BirthDay TYPE Character SIZE 2 LABEL 'BirthDay' //
Define Column BirthMonth TYPE Character SIZE 2 LABEL 'BirthMonth' //
Define Column BirthYear TYPE Character SIZE 4 LABEL 'BirthYear' //
Define Column Document TYPE NUMERIC SIZE 3 LABEL 'Document' //

Define Column Procent TYPE NUMERIC SIZE 2 LABEL 'Procent' //

Define Column MonthDat1 TYPE Character SIZE 2 LABEL 'MonthDat1' //
Define Column cCodeInc1 TYPE Character SIZE 4 LABEL 'cCodeInc1' //
Define Column nIncome1 TYPE Character SIZE 12 LABEL 'nIncome1' //
Define Column CodeDeduc1 TYPE Character SIZE 4 LABEL 'CodeDeduc1' //
Define Column nDeductio1 TYPE Character SIZE 12 LABEL 'nDeductio1' //

Define Column MonthDat2 TYPE Character SIZE 2 LABEL 'MonthDat2' //
Define Column cCodeInc2 TYPE Character SIZE 4 LABEL 'cCodeInc2' //
Define Column nIncome2 TYPE Character SIZE 12 LABEL 'nIncome2' //
Define Column CodeDeduc2 TYPE Character SIZE 4 LABEL 'CodeDeduc2' //
Define Column nDeductio2 TYPE Character SIZE 12 LABEL 'nDeductio2' //

Define Column DeducCode1 TYPE Character SIZE 4 LABEL 'DeducCode1' //
Define Column DeducVal1 TYPE Character SIZE 12 LABEL 'DeducVal1' //
Define Column DeducCode2 TYPE Character SIZE 4 LABEL 'DeducCode2' //
Define Column DeducVal2 TYPE Character SIZE 12 LABEL 'DeducVal2' //
Define Column DeducCode3 TYPE Character SIZE 4 LABEL 'DeducCode3' //
Define Column DeducVal3 TYPE Character SIZE 12 LABEL 'DeducVal3' //
Define Column DeducCode4 TYPE Character SIZE 4 LABEL 'DeducCode4' //
Define Column DeducVal4 TYPE Character SIZE 12 LABEL 'DeducVal4' //

Define Column ValInc1 TYPE Character SIZE 12 LABEL 'ValInc1' //
Define Column ValInc2 TYPE Character SIZE 12 LABEL 'ValInc2' //
Define Column ValInc3 TYPE Character SIZE 12 LABEL 'ValInc3' //
Define Column ValInc4 TYPE Character SIZE 12 LABEL 'ValInc4' //
Define Column ValInc5 TYPE Character SIZE 12 LABEL 'ValInc5' //
Define Column ValInc6 TYPE Character SIZE 12 LABEL 'ValInc6' //
Define Column ValInc7 TYPE Character SIZE 12 LABEL 'ValInc7' //
Define Column ValInc8 TYPE Character SIZE 12 LABEL 'ValInc8' //

Define Column EmplName TYPE Character SIZE 100 LABEL 'EmplName' //

Define query "SELECT * FROM %WTable:1% "


process dataset
    
    Local cWTabAl As Char
    Local cMvpar01 As Char         //TN
    Local cMvpar02 As Char         //Year
    
    cWTabAl := ::createWorkTable()

    cMvpar01 := alltrim(self:execParamValue( "MV_PAR01" ))  //
    cMvpar02 := alltrim(self:execParamValue( "MV_PAR02" ))  //

    Processa({|_Lend| lRet := X60NOT(cWTabAl, cMvpar01, cMvpar02) }, ::title())
        
    
Return .T.

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function X60NOT(cAliasMov, cMvpar01, cMvpar02)
    Local aArea As Array
    Local cAliasTMP As Char
    Local cAliasTM2 As Char
    Local cQuery As Char
    Local dDateNow As Date

    Local cOKTMO As Char
    Local cPHONENU As Char
    Local cINN As Char
    Local cKPP As Char
    Local cSHORTNM As Char

    Local nNumOf As Numeric

    Local cPIS As Char
    Local cPRISOBR As Char
    Local cPRINOME As Char
    Local cSECNOME As Char
    Local cCLASEST As Char
    Local cNACIONC As Char
    Local cNUMEPAS As Char
    Local cBDay As Char
    Local cBMonth As Char
    Local cBYear As Char
    Local nCount As Numeric
    Local nCount1 As Numeric

    Local Block_1 As Array
    Local Block_2 As Array
    Local Block_3 As Array
    Local Block_4 As Array
    Local Block_5 As Array
    Local o2NDFL As Object
    Local nBytes As Numeric
    
    Local cString As Char

    nBytes := 0

    Block_1 := {}
    Block_2 := {}
    Block_3 := {}
    Block_4 := {}
    Block_5 := {0, 0, 0, 0, 0, 0, 0, 0}

    nHdlCusto := FOpen("2NDFL.INI", 64)
    If nHdlCusto < 0
        Help(" ", 1, "2NDFL_error")
        Final("2NDFL.INI")
    EndIf
    nTamArq := FSeek(nHdlCusto, 0, 2)
    FSeek(nHdlCusto, 0, 0)
    xBuffer := Space(20)
    
    FREAD(nHdlCusto,@xBuffer,20)
    cString := SubStr(xBuffer,1,20)
    FClose(nHdlCusto)

    dDateNow := Date()
    cQuery := "SELECT * FROM SYS_COMPANY_L_RUS WHERE CO_TIPO = '1'"
    cQuery := ChangeQuery(cQuery)

    cAliasTMP := GetNextAlias()
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTMP, .T., .T.)
    DbSelectArea(cAliasTMP)
    
    (cAliasTMP)->(dbGotop())

    cOKTMO := Alltrim((cAliasTMP)->CO_OKTMO)
    cPHONENU := Alltrim((cAliasTMP)->CO_PHONENU)
    cINN := Alltrim((cAliasTMP)->CO_INN)
    cKPP := Alltrim((cAliasTMP)->CO_KPP)
    cSHORTNM := Alltrim((cAliasTMP)->CO_SHORTNM)

    (cAliasTMP)->(dbCloseArea())
    
    aArea := getArea()
    cQuery := "SELECT * FROM " + RetSqlName("SRA") + " WHERE RA_MAT = '" + cMvpar01 + "'"//cMvpar01
    cQuery := ChangeQuery(cQuery)

    cAliasTM2 := GetNextAlias()
    dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasTM2, .T., .T.)
    DbSelectArea(cAliasTM2)
    
    (cAliasTM2)->(dbGotop())

    cPIS := Alltrim((cAliasTM2)->RA_PIS)
    cPRISOBR := Alltrim((cAliasTM2)->RA_PRISOBR)
    cPRINOME := Alltrim((cAliasTM2)->RA_PRINOME)
    cSECNOME := Alltrim((cAliasTM2)->RA_SECNOME)
    
    cNACIONC := Alltrim((cAliasTM2)->RA_NACIONC)
    cNUMEPAS := Alltrim((cAliasTM2)->RA_NUMEPAS)
    cBDay := cValToChar(Day(STOD((cAliasTM2)->RA_NASC)))
    cBMonth := cValToChar(Month(STOD((cAliasTM2)->RA_NASC)))
    cBYear := cValToChar(Year(STOD((cAliasTM2)->RA_NASC)))
    
    (cAliasTM2)->(dbCloseArea())
    
    o2NDFL := RU2NDFL():New(cMvpar01, cMvpar02)
    o2NDFL:GetData()
    
    cCLASEST := o2NDFL:cTaxAgentStatusCode
    If cString == '30'
        Block_4 := AClone(o2NDFL:a30TaxPayments)
        Block_5 := AClone(o2NDFL:aAllSumm30)
        Block_3 := AClone(o2NDFL:aIncome30)
    ElseIf cString == '13'
        Block_4 := AClone(o2NDFL:a13TaxPayments)
        Block_5 := AClone(o2NDFL:aAllSumm13)
        Block_3 := AClone(o2NDFL:aIncome13)
    ElseIf cString == '15'
        Block_4 := AClone(o2NDFL:a15TaxPayments)
        Block_5 := AClone(o2NDFL:aAllSumm15)
        Block_3 := AClone(o2NDFL:aIncome15)
    EndIf
    nNumOf := 0

    If (Block_3 <> Nil .And. Len(Block_3) > 0)
        For nCount1 := 1 To Len(Block_3)
            RecLock(cAliasMov, .T.)
            nNumOf ++

            If nNumOf < 2 
                If Block_4 <> Nil
                    For nCount := 1 To Len(Block_4)
                        If nCount == 1
                            DeducCode1 := Block_4[nCount, 2]
                            DeducVal1 := RoundS(Block_4[nCount, 3])
                        ElseIf nCount == 2
                            DeducCode2 := Block_4[nCount, 2]
                            DeducVal2 := RoundS(Block_4[nCount, 3])
                        ElseIf nCount == 3
                            DeducCode3 := Block_4[nCount, 2]
                            DeducVal3 := RoundS(Block_4[nCount, 3])
                        ElseIf nCount == 4
                            DeducCode4 := Block_4[nCount, 2]
                            DeducVal4 := RoundS(Block_4[nCount, 3])
                        EndIf
                    Next nCount
                EndIf
                
                ValInc1 := RoundS(Block_5[1])
                ValInc2 := RoundS(Block_5[2])
                ValInc3 := cValToChar(Round(Block_5[3], 0))
                ValInc4 := RoundS(Block_5[4])
                ValInc5 := RoundS(Block_5[5])
                ValInc6 := RoundS(Block_5[6])
                ValInc7 := RoundS(Block_5[7])
                ValInc8 := RoundS(Block_5[8])

            EndIf
            NowDay := IIf(Len(cValToChar(Day(dDateNow))) == 1, "0" + cValToChar(Day(dDateNow)), cValToChar(Day(dDateNow)))
            NowMonth := IIf(Len(cValToChar(Month(dDateNow))) == 1, "0" + cValToChar(Month(dDateNow)), cValToChar(Month(dDateNow)))
            NowYear := cValToChar(Year(dDateNow))

            Period := cValToChar(Year(dDateNow))

            CO_OKTMO := cOKTMO
            CO_PHONENU := cPHONENU
            CO_INN := cINN
            CO_KPP := cKPP
            CO_SHORTNM := cSHORTNM

            RA_PIS := cPIS
            RA_PRISOBR := cPRISOBR
            RA_PRINOME := cPRINOME
            RA_SECNOME := cSECNOME
            RA_CLASEST := cCLASEST
            RA_NACIONC := cNACIONC
            RA_NUMEPAS := cNUMEPAS
            BirthDay := IIf(Len(cBDay)==1, "0" + cBDay, cBDay)
            BirthMonth := IIf(Len(cBMonth)==1, "0" + cBMonth, cBMonth)
            BirthYear := cBYear
            Document := 21//
            Procent := Val(cString)
            
            MonthDat1 := right(Alltrim(Block_3[nCount1, 1]),2)
            cCodeInc1 := Alltrim(Block_3[nCount1, 2])
            nIncome1 := RoundS(Block_3[nCount1, 3])
            CodeDeduc1 := Alltrim(Block_3[nCount1, 4])
            nDeductio1 := RoundS(Block_3[nCount1, 5])
            MsUnlock()
            
        Next nCount1
    EndIf

    RestArea(aArea)
Return .T.

Static Function RoundS(nValue)
    Local cResult As Char

    cResult := cValToChar(NoRound(nValue, 2))
    If At(',', cResult, 1) == 0 .And. At('.', cResult, 1) == 0
        If cResult <> '0'
            cResult := cResult + '.00'
        EndIf
    EndIf

Return Alltrim(cResult)