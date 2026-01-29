#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FIND101LOAD.CH"

Static _ObjFJV    As Object
Static _ObjFIV    As Object
Static _lIntTOP   := GetMv("MV_INTPMS") == 'S' .AND. !Empty(GetMv("MV_RMCOLIG")) As Logical //Variavel utilizada na integração RM X TOP
Static _nClassSz As Numeric

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LGrfD
Retorna valores para a monttagem dos gráficos DIARIO

@author		francisco.oliveira
@since		26/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LGrfD(oJson As Json, cCarteira As Character, ctpSaldo As Character, aCab As Array, lIntTOP As Logical, cSldbase As Character) AS Array

    Local cFilQuery     As Character
    Local cMoeda        As Character
    Local cDataIni      As Character
    Local cDataFim     As Character
    Local dDataAux      As Date
    Local aRetChart     As Array
    Local nY            As Numeric
    Local nMoeda        As Numeric
    Local nValorNat     As Numeric

    cFilQuery   := ""
    cDataIni    := ""  
    cDataFim   := ""  
    aRetChart   := {}
    nY          := 0
    cMoeda      := subStr(oJson['moedas'],1,2)
    nMoeda      := RecMoeda(Date(), cMoeda )
    nValorNat   := 0

    dDataAux  := StoD(StrTran(oJson['dateIni'],"-","")   )

    cFilQuery := FD101LFil(oJson, "FJV")

    For nY := 1 To Len(aCab)
        nValorNat   := 0
        cDataIni    := DtoS(dDataAux)
        cDataFim    := DtoS(dDataAux)

        If !lIntTOP
            nValorNat := FD101LQuer(oJson, cFilQuery, cDataIni, cDataFim, cCarteira, ctpSaldo )
        Else
            nValorNat := FD101LFJ0(oJson, cDataIni, cDataFim, cSldbase, "", "")
        Endif

        If nMoeda > 0 .And. cMoeda > '01'
            nVlrAux := xMoeda(nValorNat, 1, Val(cMoeda), date(), 2)
            AAdd(aRetChart, nVlrAux )
        Else
            AAdd(aRetChart, nValorNat )
        Endif

        dDataAux++

    Next nY

Return aRetChart

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LGSMA
Retorna valores para a montagem dos gráficos SEMANAL/MENSAL/ANUAL

@author		francisco.oliveira
@since		26/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LGSMA(oJson As Json, cCarteira As Character, ctpSaldo As Character, aCab As Array, cPeriodo As Character, lIntTOP As Logical, cSldbase As Character) AS Array

    Local cFilQuery     As Character
    Local cMoeda        As Character
    Local cDataIni      As Character
    Local cDataFim      As Character
    Local cDtAuIni      As Character
    Local cDtAuFim      As Character
    Local dDataIni      As Date
    Local dDataFim      As Date
    Local dDataAux      As Date
    Local aRetChart     As Array
    Local aCabAux       As Array
    Local nY            As Numeric
    Local nMoeda        As Numeric
    Local nValorNat     As Numeric

    dDataIni  := StoD(StrTran(oJson['dateIni'],"-",""))
    dDataFim  := StoD(StrTran(oJson['dateFim'],"-",""))

    cFilQuery   := ""
    cDtAuIni    := ""
    cDtAuFim    := ""
    cDataIni    := StrTran(oJson['dateIni'],"-", "")
    cDataFim    := StrTran(oJson['dateFim'],"-", "")   
    aRetChart   := {}
    aCabAux     := {}
    nY          := 0
    cMoeda      := subStr(oJson['moedas'],1,2)
    nMoeda      := RecMoeda(Date(), cMoeda )
    nValorNat   := 0

    dDataAux := dDataIni

    If cPeriodo == "2" // SEMANAL
        For nY := 1 To Len(aCab)
            Aadd(aCabAux, {FD101LSem(dDataAux, dDataIni, dDataFim )})
            dDataAux := dDataAux + 7
        Next nY
    ElseIf cPeriodo == "3" // MENSAL
        For nY := 1 To Len(aCab)
            cDtAuIni    := ""
            cDtAuFim    := ""
            If !SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataFim))
                cDtAuIni  := DtoS(Firstday(StoD(cDataFim)))
            ElseIf !SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataFim))
                cDtAuIni  := DtoS(CtoD("01/" + aCab[nY][1]))
                cDtAuFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + aCab[nY][1]))) + "/" + aCab[nY][1]))
            ElseIf SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(aCab[nY][1], 1, 2) == Month2Str(StoD(cDataFim))
                cDtAuFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + aCab[nY][1]))) + "/" + aCab[nY][1]))
            Endif

            If Empty(cDtAuIni)
                cDtAuIni    := cDataIni
            Endif

            If Empty(cDtAuFim)
                cDtAuFim    := cDataFim
            Endif

            Aadd(aCabAux, {cDtAuIni + "/" + cDtAuFim})
        Next nY
    ElseIf cPeriodo == "4" // ANUAL
        For nY := 1 To Len(aCab)
            cDtAuIni    := ""
            cDtAuFim    := ""
            If !aCab[nY][1] $ cDataIni .And. aCab[nY][1] $ cDataFim
                cDtAuIni  := aCab[nY][1] + "0101"
            ElseIf !aCab[nY][1] $ cDataIni .And. !aCab[nY][1] $ cDataFim
                cDtAuIni  := aCab[nY][1] + "0101"
                cDtAuFim  := aCab[nY][1] + "1231"
            ElseIf aCab[nY][1] $ cDataIni .And. !aCab[nY][1] $ cDataFim
                cDtAuFim  := aCab[nY][1] + "1231"
            Endif 

            If Empty(cDtAuIni)
                cDtAuIni    := cDataIni
            Endif

            If Empty(cDtAuFim)
                cDtAuFim    := cDataFim
            Endif

            Aadd(aCabAux, {cDtAuIni + "/" + cDtAuFim})
        Next nY
    Endif

    cFilQuery := FD101LFil(oJson, "FJV")

    For nY := 1 To Len(aCabAux)
        nValorNat   := 0
        cDataIni    := SubStr(aCabAux[nY][1],  1, 8)
        cDataFim    := SubStr(aCabAux[nY][1], 10, 8)

        If !lIntTOP
            nValorNat := FD101LQuer(oJson, cFilQuery, cDataIni, cDataFim, cCarteira, ctpSaldo )
        Else
            nValorNat := FD101LFJ0(oJson, cDataIni, cDataFim, cSldbase, "", "")
        Endif

        If nMoeda > 0 .And. cMoeda > '01'
            nVlrAux := xMoeda(nValorNat, 1, Val(cMoeda), date(), 2)
            AAdd(aRetChart, nVlrAux )
        Else
            AAdd(aRetChart, nValorNat )
        Endif

    Next nY

Return aRetChart

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LGNUM
Retorna valores para a montagem dos gráficos SEMANAL/MENSAL/ANUAL

@author		francisco.oliveira
@since		26/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LGNUM(oJson As Json, cCarteira As Character, ctpSaldo As Character, aCab As Array, cPeriodo As Character, lIntTOP As Logical, cSldbase As Character) AS Array

    Local cFilQuery     As Character
    Local cMoeda        As Character
    Local cDataIni      As Character
    Local cDataFim      As Character
    Local aRetChart     As Array
    Local nMoeda        As Numeric
    Local nValorNat     As Numeric
    Local oDate         As Json

    cFilQuery   := ""
    cDataIni    := StrTran(oJson['dateIni'],"-", "")
    cDataFim    := StrTran(oJson['dateFim'],"-", "")  
    aRetChart   := {}
    cMoeda      := subStr(oJson['moedas'],1,2)
    nMoeda      := RecMoeda(Date(), cMoeda )
    nValorNat   := 0

    If cPeriodo == "1" // Diario
        cDataIni    := DtoS(CtoD(aCab[1]))
        cDataFim    := DtoS(CtoD(aCab[1]))
    ElseIf cPeriodo == "2" // SEMANAL
        oDate := FD101Dates(cPeriodo, aCab[1])
        cDataIni := oDate['sqlStartDate']
        cDataFim := oDate['sqlEndDate']
    ElseIf cPeriodo == "3" // MENSAL
        If !SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
            cDataIni  := DtoS(Firstday(StoD(cDataFim)))
        ElseIf !SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
            cDataIni  := DtoS(CtoD("01/" + oJson['level'][1]['label'][1]))
            cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJson['level'][1]['label'][1]))) + "/" + oJson['level'][1]['label'][1]))
        ElseIf SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataIni)) .And. !SubStr(oJson['level'][1]['label'][1], 1, 2) == Month2Str(StoD(cDataFim))
            cDataFim  := DtoS(CtoD(cValToChar(Last_Day(CtoD("01/" + oJson['level'][1]['label'][1]))) + "/" + oJson['level'][1]['label'][1]))
        Endif
    ElseIf cPeriodo == "4" // ANUAL
        If !oJson['level'][1]['label'][1] $ cDataIni .And. oJson['level'][1]['label'][1] $ cDataFim
            cDataIni  := oJson['level'][1]['label'][1] + "0101"
        ElseIf !oJson['level'][1]['label'][1] $ cDataIni .And. !oJson['level'][1]['label'][1] $ cDataFim
            cDataIni  := oJson['level'][1]['label'][1] + "0101"
            cDataFim  := oJson['level'][1]['label'][1] + "1231"
        ElseIf oJson['level'][1]['label'][1] $ cDataIni .And. !oJson['level'][1]['label'][1] $ cDataFim
            cDataFim  := oJson['level'][1]['label'][1] + "1231"
        Endif 
    Endif

    cFilQuery := FD101LFil(oJson, "FJV")

    If !lIntTOP
        nValorNat := FD101LQuer(oJson, cFilQuery, cDataIni, cDataFim, cCarteira, ctpSaldo )
    Else
        nValorNat := FD101LFJ0(oJson, cDataIni, cDataFim, cSldbase, "", "")
    Endif

    If nMoeda > 0 .And. cMoeda > '01'
        nVlrAux := xMoeda(nValorNat, 1, Val(cMoeda), date(), 2)
        AAdd(aRetChart, nVlrAux )
    Else
        AAdd(aRetChart, nValorNat )
    Endif

Return aRetChart
//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LSem
Retorna a mensagem de erro da validação do Perido X Datas

FD101LSem(dData, dDtIni, dDtFin)
dData  -> Data a ser considerada
dDtFin -> Data inicial do periodo (data minima)
dDtFin -> Data final do periodo (data maxima) 

@author		francisco.oliveira
@since		22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101LSem(dDataAux, dDtIni, dDtFin)

    Local cSemana As Character
    Local nSemana As Numeric
    Local nInicio As Numeric
    Local nFim    As Numeric
    Local nDias   As Numeric
    Local nAux    As Numeric

    cSemana := ""
    nSemana := 0
    nInicio := 0
    nFim    := 0
    nDias   := 0
    nAux    := 0

    nDias   := Day(dDataAux) + (Dow(Firstday(dDataAux)-1))

    If (nDias % 7) > 0
        nAux    := 1
    Endif

    nSemana := NoRound( nDias / 7, 0) + nAux

    nInicio := Dow(dDataAux)
    nFim    := (7-Dow(dDataAux))

    cSemana := DtoS(Max(dDtIni, dDataAux - nInicio + 1)) + "/" + DtoS(Min(dDtFin, dDataAux + nFim))

Return cSemana 

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LQuer
Retorna o valor da natureza com valores diarios

@author		francisco.oliveira
@since		22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LQuer(oJson As Json, cFilQuery As Character, cDataIni As Character, cDataFim As Character, cCarteira As Character, ctpSaldo As Character) As Numeric

    Local cQuery        As Character
    Local cNatureza     As Character
    Local cNatIni       As Character
    Local cNatFim       As Character
    Local cFilIni       As Character
    Local cFilFim       As Character
    Local cQryFil       As Character
    Local nValorNat     As Numeric
    Local aNatureza     As Array

    cQuery      := ""
    cFilIni     := ""
    cFilFim     := ""
    cQryFil     := ""
    cNatureza   := FD101LSEDC(oJson)
    aNatureza   := {}
    nValorNat   := 0

    If Empty(cNatureza)
        cNatIni := Space(TamSX3("ED_CODIGO")[1])
        cNatFim := Replicate("Z", TamSX3("ED_CODIGO")[1])
    Else
        aNatureza   := &("{" + cNatureza + "}")
    Endif

    If Empty(cFilQuery)
        cFilIni := Space(TamSX3("FJV_FILIAL")[1])
        cFilFim := Replicate("Z", TamSX3("FJV_FILIAL")[1])
    Endif

    cQuery += "SELECT "
    cQuery += " SUM(FJV_VALOR) VALORFJV "
    cQuery += " FROM "  + RetSqlName("FJV") + " FJV "
    cQuery += " WHERE "

    cQryFil += "     FJV.FJV_FILIAL >= '" + cFilIni + "' "
    cQryFil += " AND FJV.FJV_FILIAL <= '" + cFilFim + "' "

    If !(Len(Alltrim(xFilial("FJV"))) > 0)
        cQryFil := " FJV.FJV_FILIAL  IN ( '" + Space(TamSX3("FJV_FILIAL")[1]) + "' ) "
        cFilQuery := "" //Limpo o filtro que foi enviado pois esta totalmente compartilhada 
    Endif

    If !Empty(cFilQuery)
        cQuery += " FJV.FJV_FILIAL  IN ( " + cFilQuery + " ) "
    Else
        cQuery += cQryFil
    Endif

    cQuery += " AND FJV.D_E_L_E_T_ = ' ' "

    cQueryAux   := FD101LDive(oJson)

    If !Empty(cQueryAux)
        cQuery  += cQueryAux
    Endif

    If Empty(cNatureza)
        cQuery += " AND FJV_NATUR >= ?  "
        cQuery += " AND FJV_NATUR <= ?  "
    Else
        cQuery += " AND FJV_NATUR IN (?) "
    EndIf

    cQuery += " AND FJV_NATUR != ' '  "
    cQuery += " AND FJV_DATA  >= ?    " 
    cQuery += " AND FJV_DATA  <= ?    " 
    cQuery += " AND FJV_CARTEI = ?    "
    cQuery += " AND FJV_TPSALD = ?    " 
    cQuery += " AND FJV_MOEDA  = '01' "

    _ObjFJV := FWPreparedStatement():New(cQuery)

    If Empty(cNatureza)
        _ObjFJV:SetString(1, cNatIni)
        _ObjFJV:SetString(2, cNatFim)
        _ObjFJV:SetString(3, cDataIni)
        _ObjFJV:SetString(4, cDataFim)
        _ObjFJV:SetString(5, cCarteira)
        _ObjFJV:SetString(6, ctpSaldo)
    Else
        _ObjFJV:SetIn(1, aNatureza)
        _ObjFJV:SetString(2, cDataIni)
        _ObjFJV:SetString(3, cDataFim)
        _ObjFJV:SetString(4, cCarteira)
        _ObjFJV:SetString(5, ctpSaldo)
    Endif

    cQuery := _ObjFJV:GetFixQuery()
    nValorNat := MpSysExecScalar(cQuery, "VALORFJV")

Return nValorNat

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LFil
Retorna a string com a Filial do compartilhamento da FJV

@author		francisco.oliveira
@since		22/09/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LFil(oJson As Json, cFilAtiva As Character) As Character

    Local nY        As Numeric
    Local nTamFil   As Numeric
    Local cFilQuery As Character
    
    nY        := 0
    nTamFil   := Len(Alltrim(xFilial(cFilAtiva)))
    cFilQuery := ""

    If Len(oJson['considFil']) > 0
        If !aScan(oJson['considFil'], {|x| SubStr(x, 1, 1) == "1"})
            For nY := 1 To Len(oJson['considFil'])
                If nY == Len(oJson['considFil'])
                    If nTamFil > 0
                        cFilQuery += " '" + SubStr(oJson['considFil'][nY], 1, nTamFil) + "' "
                    Endif
                Else
                    If nTamFil > 0
                        cFilQuery += " '" + SubStr(oJson['considFil'][nY], 1, nTamFil) + "', "
                    Endif
                Endif
            Next nY
        Endif
    Endif

Return cFilQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LSEDC
Retorna a Array com as Naturezas

@author		francisco.oliveira
@since		05/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LSEDC(oJson As Json)

    Local cRetSED   As Character
    Local nY        As Numeric

    cRetSED := ""
    nY      := 0

    If Len(oJson['natureza']) > 0
        If !(aScan(oJson['natureza'], {|x| x == "Todas"}) > 0)
            For nY := 1 To Len(oJson['natureza'])
                If nY == Len(oJson['natureza'])
                    cRetSED += " '" + oJson['natureza'][nY] + "' "
                Else
                    cRetSED += " '" + oJson['natureza'][nY] + "', "
                Endif
            Next nY
        Endif
    Endif

Return cRetSED

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LSNat
Monta query com retorno das Naturezas e seus movimentos

@author		francisco.oliveira
@since		06/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LSNat(oJsonFilter As Json, cDtAuxIni As Character,cDtAuxFim As Character, cPeriodo As Character, aItems As Array, aItemsAux As Array, aGrvTtl As Array, aGrvSldIn As Array) As Character

    Local cSelect    As Character
    Local cAliasFIV  As Character
    Local cFilQuery  As Character
    Local cFilFJ0Qy  As Character
    Local cTempTable As Character
    Local cNatureza  As Character
    Local cDataIni   As Character
    Local cDataFim   As Character
    Local cMoeda     As Character
    Local cNatIni    As Character
    Local cNatFim    As Character
    Local cFilIni    As Character
    Local cFilFim    As Character
    Local cCustos    As Character
    Local oDashFIV   AS Object
    Local aEstruct   AS Array
    Local aGrvAux    As Array
    Local aBancos    As Array
    Local aGrvEnd    As Array
    Local aBcoAux    As Array
    Local nVlrAux    AS Numeric
    Local nAuxPrev   AS Numeric
    Local nAuxReal   AS Numeric
    Local nAuxOrca   As Numeric
    Local nCount     AS Numeric
    Local nY         AS Numeric
    Local nScan      As Numeric
    Local nPeriodo   As Numeric
    Local nPerAnt    As Numeric
    Local nPerOrc    As Numeric
    Local nFor       As Numeric
    Local lBcoCons   As Logical

    cSelect     := ""
    cFilQuery   := ""
    cFilFJ0Qy   := ""
    cNatIni     := ""
    cNatFim     := ""
    cFilIni     := ""
    cFilFim     := ""
    cMoeda      := SubStr(oJsonFilter['moedas'], 1, 2)
    cDataIni    := cDtAuxIni
    cDataFim    := cDtAuxFim
    cAliasFIV   := GetNextAlias()
    cTempTable  := GetNextAlias()
    aEstruct    := {}
    aBancos     := {}
    aGrvEnd     := {}
    aBcoAux     := {}
    aGrvAux     := aClone(aGrvTtl)
    nVlrAux     := 0
    nAuxPrev    := 0
    nAuxReal    := 0
    nAuxOrca    := 0
    nCount      := 0
    nY          := 0
    nScan       := 0
    nPeriodo    := 0
    nPerOrc     := 0
    lBcoCons    := .T.

    cNatureza   := FD101LSEDC(oJsonFilter)

    If Empty(cNatureza)
        cNatIni := Space(TamSX3("ED_CODIGO")[1])
        cNatFim := Replicate("Z", TamSX3("ED_CODIGO")[1])
    Endif

    If Len(oJsonFilter['conBancos']) > 0
        If aScan(oJsonFilter['conBancos'], {|x| SubStr(x, 1, 1) == "2" }) > 0 // Não COnsidera
            lBcoCons    := .F.
        ElseIf aScan(oJsonFilter['conBancos'], {|x| SubStr(x, 1, 1) == "1" }) > 0 // Todos
            AAdd(aBancos, {.F.} )
        Else // Bancos Marcados
            AAdd(aBancos, {.T., "", ""} )
            For nY := 1 To Len(oJsonFilter['conBancos'])
                aBcoAux := StrToArray(oJsonFilter['conBancos'][nY], " - ")
                AAdd(aBancos, {aBcoAux[2], aBcoAux[3], aBcoAux[4]})
            Next nY
        Endif
    Endif

    cFilQuery := FD101LFil(oJsonFilter, "FIV")

    If Empty(cFilQuery)
        cFilIni := Space(TamSX3("FJV_FILIAL")[1])
        cFilFim := Replicate("Z", TamSX3("FJV_FILIAL")[1])
    Endif

    If cPeriodo == "1" .or. cPeriodo == "2"
        nPeriodo    := 1

        If _lIntTOP
            nPerOrc := 8
            nPerAnt := 4
            nFor    := 5
        Else
            nPerOrc := 4
            nPerAnt := 2
            nFor    := 3
        Endif
    Else
        nPeriodo    := 2

        If _lIntTOP
            nPerOrc := 9
            nPerAnt := 4
            nFor    := 5
        Else
            nPerOrc := 5
            nPerAnt := 2
            nFor    := 3
        Endif
    Endif

    cSelect += " SELECT "
    cSelect += " DISTINCT FIV.FIV_FILIAL, FIV.FIV_NATUR, SED.ED_DESCRIC "
    cSelect += " FROM "       + RetSqlName("FIV") + " FIV "
    cSelect += " INNER JOIN " + RetSqlName("SED") + " SED "
    cSelect += " ON  FIV.FIV_NATUR  = SED.ED_CODIGO "

    cSelect += " AND " + totvs.protheus.backoffice.ngf.util.BranchRelation( {"SED","ED_FILIAL","SED"}, {"FIV","FIV_FILIAL","FIV"} )  + " "

    cSelect += " WHERE "

    If !Empty(cFilQuery)
        cSelect += " FIV.FIV_FILIAL  IN ( " + cFilQuery + " ) "
    Else
        cSelect += "     FIV.FIV_FILIAL  >= '" + cFilIni + "' "
        cSelect += " AND FIV.FIV_FILIAL  <= '" + cFilFim + "' "
    Endif

    cSelect += " AND FIV.D_E_L_E_T_ = ' ' "
    cSelect += " AND SED.D_E_L_E_T_ = ' ' "

    cSelect += " AND FIV.FIV_NATUR != ' '  "

    If Empty(cNatureza)
        cSelect += " AND FIV.FIV_NATUR  >=   '" + cNatIni  + "' " 
        cSelect += " AND FIV.FIV_NATUR  <=   '" + cNatFim  + "' "
    Else
        cSelect += " AND FIV.FIV_NATUR IN ( "  + cNatureza + " ) "
    Endif
    
    cSelect += " AND FIV.FIV_DATA  >=   '" + cDataIni  + "' " 
    cSelect += " AND FIV.FIV_DATA  <=   '" + cDataFim  + "' " 
    cSelect += " AND FIV.FIV_CARTEI IN ('R', 'P')    "

    If cPeriodo == "1" .Or. cPeriodo == "2"
        cSelect += " AND FIV.FIV_TPSALD IN ('2', '3')    "
    ElseIf cPeriodo == "3" .Or. cPeriodo == "4"
        cSelect += " AND FIV.FIV_TPSALD IN ('1', '2', '3')    "
    Endif
    
    cSelect += " AND FIV.FIV_MOEDA  = '01' "

    If !_lIntTOP
        cSelect += " ORDER BY FIV_FILIAL, FIV_NATUR "
    Else
        cCustos     := FD101LCTTC(oJsonFilter)
        cFilFJ0Qy   := FD101LFil(oJsonFilter, "FJ0")

        cSelect += " UNION "

        cSelect += " SELECT DISTINCT "
        cSelect += " FJ0.FJ0_FILIAL, FJ0.FJ0_NATURE, SED.ED_DESCRIC "
        cSelect += " FROM "       + RetSqlName("FJ0") + " FJ0 "
        cSelect += " INNER JOIN " + RetSqlName("SED") + " SED "
        cSelect += " ON "
        cSelect += "     FJ0.FJ0_NATURE = SED.ED_CODIGO "

        cSelect += " AND " + totvs.protheus.backoffice.ngf.util.BranchRelation( {"SED","ED_FILIAL","SED"}, {"FJ0","FJ0_FILIAL","FJ0"} )  + " "

        cSelect += " WHERE "

        If !Empty(cFilFJ0Qy)
            cSelect += " FJ0.FJ0_FILIAL  IN ( " + cFilFJ0Qy + " ) "
        Else
            cSelect += "     FJ0.FJ0_FILIAL  >= '" + cFilIni + "' "
            cSelect += " AND FJ0.FJ0_FILIAL  <= '" + cFilFim + "' "
        Endif

        cSelect += " AND FJ0.D_E_L_E_T_     = ' ' "
        cSelect += " AND SED.D_E_L_E_T_     = ' ' "
        cSelect += " AND FJ0.FJ0_NATURE    != ' ' "

        If cCustos == '1'
            cSelect += " AND FJ0.FJ0_CCUSTO >= '" + Space(TamSX3("FJ0_CCUSTO")[1]) + "' "
            cSelect += " AND FJ0.FJ0_CCUSTO <= '" + Replicate("Z", TamSX3("FJ0_CCUSTO")[1]) + "' "
        ElseIf !Empty(cCustos) .And. cCustos != '2'
            cSelect += " AND FJ0.FJ0_CCUSTO IN (" + cCustos + ")
        Endif

        If Empty(cNatureza)
            cSelect += " AND FJ0.FJ0_NATURE  >=   '" + cNatIni  + "' " 
            cSelect += " AND FJ0.FJ0_NATURE  <=   '" + cNatFim  + "' "
        Else
            cSelect += " AND FJ0.FJ0_NATURE IN ( "  + cNatureza + " ) "
        Endif

        cSelect += " AND FJ0.FJ0_DATA  >=   '" + cDataIni  + "' " 
        cSelect += " AND FJ0.FJ0_DATA  <=   '" + cDataFim  + "' " 

        cSelect += " ORDER BY FIV_FILIAL, FIV_NATUR
    Endif

    cSelect	:= ChangeQuery(cSelect)

    MPSysOpenQuery( cSelect, cAliasFIV )

    (cAliasFIV)->(DbGoTop())

    aEstruct := FD101LStru(aItems)

    oDashFIV := FWTemporaryTable():New( cTempTable )
    oDashFIV:SetFields(aEstruct)

    oDashFIV:Create()

    (cTempTable)->(RecLock((cTempTable), .T.))
    (cTempTable)->NATUREZA  := STR0004 // "Saldos Iniciais"
    If lBcoCons
        nVlrAux := SldInicial(oJsonFilter, aBancos, cPeriodo, cNatureza)
        (cTempTable)->&(Upper(aItemsAux[1][4])) := nVlrAux
        (cTempTable)->&(Upper(aItemsAux[1][5])) := nVlrAux
    Endif
    (cTempTable)->(MsUnlock())

    nVlrAux := 0

    While (cAliasFIV)->(!Eof()) // Roda as naturezas para valores de RECEITA
        nCount     := 0
        nAuxPrev   := 0
        nAuxReal   := 0
        nAuxOrca   := 0
        (cTempTable)->(RecLock((cTempTable), .T.))
            For nY  := 1 To Len(aEstruct)
                If nY == 1
                    (cTempTable)->&(Upper(aEstruct[nY][1])) := (cAliasFIV)->FIV_NATUR + " - " + (cAliasFIV)->ED_DESCRIC
                ElseIf nY < (Len(aEstruct) - nPeriodo)
                    nCount++
                    If nCount <= Len(aItemsAux)
                        If _lIntTOP .And. (SubStr(aEstruct[nY][1], 1, 4) == 'pbas' .Or. SubStr(aEstruct[nY][1], 1, 4) == 'psld')
                            If SubStr(aEstruct[nY][1], 1, 4) == 'pbas'
                                nVlrAux := FD101LFJ0(oJsonFilter, aItemsAux[nCount][2], aItemsAux[nCount][3], "B", "R", (cAliasFIV)->FIV_NATUR)
                            ElseIf SubStr(aEstruct[nY][1], 1, 4) == 'psld'
                                nVlrAux := FD101LFJ0(oJsonFilter, aItemsAux[nCount][2], aItemsAux[nCount][3], "S", "R", (cAliasFIV)->FIV_NATUR)
                            Endif
                        Else
                            nVlrAux := getVlrAux((cAliasFIV)->FIV_FILIAL, (cAliasFIV)->FIV_NATUR, aItemsAux[nCount][2], aItemsAux[nCount][3], aItemsAux[nCount][1], "R", cMoeda, oJsonFilter)
                        Endif

                        (cTempTable)->&(Upper(aEstruct[nY][1]))  := nVlrAux
                        If aItemsAux[nCount][1] == "2"
                            nAuxPrev += nVlrAux
                        ElseIf aItemsAux[nCount][1] == "3"
                            nAuxReal += nVlrAux
                        ElseIf aItemsAux[nCount][1] == "1"
                            nAuxOrca += nVlrAux
                        Endif
                    Endif
                Endif

                nScan  := aScan(aGrvAux, {|x| Upper(x[1]) == Upper(aEstruct[nY][1]) } )

                If nScan > 0
                    aGrvAux[nScan][2] += nVlrAux
                Endif
            next nY

            If nAuxPrev > 0
                (cTempTable)->PREVTTL   := nAuxPrev
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "prevttl"} )][2] += nAuxPrev
            Endif
            
            If nAuxReal > 0
                (cTempTable)->REALTTL   := nAuxReal
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "realttl"} )][2] += nAuxReal
            Endif

            If cPeriodo == "3" .Or. cPeriodo == "4"
                (cTempTable)->ORCATTL   := nAuxOrca
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "orcattl"} )][2] += nAuxOrca
            Endif

        (cTempTable)->(MsUnlock())

        (cAliasFIV)->(dbSkip())
    EndDo

    (cTempTable)->(RecLock((cTempTable), .T.))
        (cTempTable)->NATUREZA  := STR0005 // "Total de Entradas"
        For nY := 1 To Len(aGrvAux)
            (cTempTable)->&(aGrvAux[nY][1]) := aGrvAux[nY][2]
        Next nY
    (cTempTable)->(MsUnlock())

    (cAliasFIV)->(DbGoTop())

    (cTempTable)->(dbGotop()) 
        nVlrAux := (cTempTable)->&((Upper(aGrvAux[1][1]))) // Pega valor Saldo Inicial Primeiro coluna PREVISTO
    (cTempTable)->(DbGoBottom())

    For nY := 1 To Len(aGrvSldIn) // Grava Array com valores para saldo inicial
        If !(aGrvSldIn[nY][1] $ "prevttl" .Or. aGrvSldIn[nY][1] $ "realttl")
            nScan   := aScan(aGrvAux, { |x| Upper(x[1]) == Upper(aGrvSldIn[nY][1]) })
            If nScan > 0
                If nY <= 2
                    aGrvSldIn[nY][2] += nVlrAux
                ElseIf (nY == 3 .Or. nY == 4) .And. (SubStr(aGrvSldIn[nY][1], 1, 4) == "pbas" .Or. SubStr(aGrvSldIn[nY][1], 1, 4) == "psld")
                    aGrvSldIn[nY][2] := 0
                Else
                    aGrvSldIn[nY][2] := aGrvSldIn[nY - nPerAnt][2] + aGrvAux[nScan - nPerOrc][2]
                Endif
            Endif
        Endif
    Next nY

    aGrvEnd := aClone(aGrvAux)

    For nY := 1 To Len(aGrvAux) // Grava Array com valores da linha Saldo Operacional - Adiciona Valor - Receita
        If SubStr(aGrvAux[nY][1],1, 4) == "prev"
            nScan := aScan(aGrvAux, {|x| x[1] == "operP" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] += aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "real"
            nScan := aScan(aGrvAux, {|x| x[1] == "operR" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] += aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "pbas"
            nScan := aScan(aGrvAux, {|x| x[1] == "operB" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] += aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "psld"
            nScan := aScan(aGrvAux, {|x| x[1] == "operS" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] += aGrvAux[nY][2]
            Endif
        Endif
    Next nY
    nVlrAux := 0
    aGrvAux := {}
    aGrvAux := aClone(aGrvTtl)

    While (cAliasFIV)->(!Eof()) // Roda as naturezas para valores de DESPESA
        nCount   := 0
        nAuxPrev := 0
        nAuxReal := 0
        nAuxOrca := 0
        (cTempTable)->(RecLock((cTempTable), .T.))
            For nY  := 1 To Len(aEstruct)
                If nY == 1
                    (cTempTable)->&(Upper(aEstruct[nY][1]))  := (cAliasFIV)->FIV_NATUR + " - " + (cAliasFIV)->ED_DESCRIC
                ElseIf nY < (Len(aEstruct) - nPeriodo)
                    nCount++
                    If nCount <= Len(aItemsAux)
                        If _lIntTOP .And. (SubStr(aEstruct[nY][1], 1, 4) == 'pbas' .Or. SubStr(aEstruct[nY][1], 1, 4) == 'psld')
                            If SubStr(aEstruct[nY][1], 1, 4) == 'pbas'
                                nVlrAux := FD101LFJ0(oJsonFilter, aItemsAux[nCount][2], aItemsAux[nCount][3], "B", "D", (cAliasFIV)->FIV_NATUR)
                            ElseIf SubStr(aEstruct[nY][1], 1, 4) == 'psld'
                                nVlrAux := FD101LFJ0(oJsonFilter, aItemsAux[nCount][2], aItemsAux[nCount][3], "S", "D", (cAliasFIV)->FIV_NATUR)
                            Endif
                        Else
                            nVlrAux := getVlrAux((cAliasFIV)->FIV_FILIAL, (cAliasFIV)->FIV_NATUR, aItemsAux[nCount][2], aItemsAux[nCount][3], aItemsAux[nCount][1], "P", cMoeda, oJsonFilter)
                        Endif

                        (cTempTable)->&(Upper(aEstruct[nY][1]))  := nVlrAux
                        If aItemsAux[nCount][1] == "2"
                            nAuxPrev += nVlrAux
                        ElseIf aItemsAux[nCount][1] == "3"
                            nAuxReal += nVlrAux
                        ElseIf aItemsAux[nCount][1] == "1"
                            nAuxOrca += nVlrAux
                        Endif
                    Endif
                Endif

                nScan  := aScan(aGrvAux, {|x| Upper(x[1]) == Upper(aEstruct[nY][1]) } )

                If nScan > 0
                    aGrvAux[nScan][2] += nVlrAux
                Endif
            next nY

            If nAuxPrev > 0
                (cTempTable)->PREVTTL   := nAuxPrev
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "prevttl"} )][2] += nAuxPrev
            Endif

            If nAuxReal > 0
                (cTempTable)->REALTTL   := nAuxReal
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "realttl"} )][2] += nAuxReal
            Endif

            If cPeriodo == "3" .Or. cPeriodo == "4"
                (cTempTable)->ORCATTL   := nAuxOrca
                aGrvAux[aScan(aGrvAux, {|x| x[1] == "orcattl"} )][2] += nAuxOrca
            Endif

        (cTempTable)->(MsUnlock())

        (cAliasFIV)->(dbSkip())
    EndDo

    (cTempTable)->(RecLock((cTempTable), .T.))
        (cTempTable)->NATUREZA  := STR0006 // "Total de Saídas"
        For nY := 1 To Len(aGrvAux)
            (cTempTable)->&(aGrvAux[nY][1]) := aGrvAux[nY][2]
        Next nY
    (cTempTable)->(MsUnlock())

    For nY := 1 To Len(aGrvAux) // Grava Array com valores da linha Saldo Operacional - Subtrai Valor - Despesa
        If SubStr(aGrvAux[nY][1],1, 4) == "prev"
            nScan := aScan(aGrvAux, {|x| x[1] == "operP" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] -= aGrvAux[nY][2]
            Endif
            If !(SubStr(aGrvEnd[nY][1], 1, 4) == 'oper')
                aGrvEnd[nY][2] -= aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "real"
            nScan := aScan(aGrvAux, {|x| x[1] == "operR" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] -= aGrvAux[nY][2]
            Endif
            If !(SubStr(aGrvEnd[nY][1], 1, 4) == 'oper')
                aGrvEnd[nY][2] -= aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "pbas"
            nScan := aScan(aGrvAux, {|x| x[1] == "operB" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] -= aGrvAux[nY][2]
            Endif
            If !(SubStr(aGrvEnd[nY][1], 1, 4) == 'oper')
                aGrvEnd[nY][2] -= aGrvAux[nY][2]
            Endif
        ElseIf SubStr(aGrvAux[nY][1],1, 4) == "psld"
            nScan := aScan(aGrvAux, {|x| x[1] == "operS" + SubStr(aGrvAux[nY][1], 5, 4)})
            If nScan > 0
                aGrvEnd[nScan][2] -= aGrvAux[nY][2]
            Endif
            If !(SubStr(aGrvEnd[nY][1], 1, 4) == 'oper')
                aGrvEnd[nY][2] -= aGrvAux[nY][2]
            Endif
        Endif
    Next nY

    (cTempTable)->(dbGotop())

    For nY := nFor To Len(aGrvSldIn)
        If !(aGrvSldIn[nY][1] $ "prevttl" .Or. aGrvSldIn[nY][1] $ "realttl" .Or. aGrvSldIn[nY][1] $ "orcattl")
            nScan   := aScan(aGrvEnd, { |x| Upper(x[1]) == Upper(aGrvSldIn[nY - nPerAnt][1]) })
            If nScan > 0   
                aGrvSldIn[nY][2] := aGrvSldIn[nY - nPerAnt][2] + aGrvEnd[nScan][2] 
            Endif
        Endif
    Next nY

    // Grava Saldos Iniciais na Temporaria
    (cTempTable)->(RecLock((cTempTable), .F.))
        For nY := nFor To Len(aGrvSldIn)
            If !(aGrvSldIn[nY][1] $ "prevttl" .Or. aGrvSldIn[nY][1] $ "realttl" .Or. aGrvSldIn[nY][1] $ "orcattl")
                nScan   := aScan(aGrvAux, { |x| Upper(x[1]) == Upper(aGrvSldIn[nY][1]) })
                If nScan > 0
                    (cTempTable)->&(Upper(aGrvAux[nScan][1])) := aGrvSldIn[nY][2]
                Endif
            Else
                If !(aGrvSldIn[nY][1] $ "orcattl") .And. ("realttl" $ aGrvSldIn[nY][1] .Or. "prevttl" $ aGrvSldIn[nY][1])
                    (cTempTable)->&(Upper(aGrvSldIn[nY][1])) := (cTempTable)->&(Upper(aGrvSldIn[1][1]))
                Endif
            Endif
        Next nY
    (cTempTable)->(MsUnlock())

    (cTempTable)->(DbGoBottom())

    (cTempTable)->(RecLock((cTempTable), .T.))
        (cTempTable)->NATUREZA  := STR0007 // "Saldo Operaciomal"
        For nY := 1 To Len(aGrvEnd)
            If SubStr(aGrvEnd[nY][1], 1, 5) == "operP"
                (cTempTable)->&("PREV" + SubStr(aGrvEnd[nY][1], 6, 4)) := aGrvEnd[nY][2]
            ElseIf  SubStr(aGrvEnd[nY][1], 1, 5) == "operR"
                (cTempTable)->&("REAL" + SubStr(aGrvEnd[nY][1], 6, 4)) := aGrvEnd[nY][2]
            ElseIf  SubStr(aGrvEnd[nY][1], 1, 5) == "operB"
                (cTempTable)->&("PBAS" + SubStr(aGrvEnd[nY][1], 6, 4)) := aGrvEnd[nY][2]
            ElseIf  SubStr(aGrvEnd[nY][1], 1, 5) == "operS"
                (cTempTable)->&("PSLD" + SubStr(aGrvEnd[nY][1], 6, 4)) := aGrvEnd[nY][2]
            Endif
        Next nY
    (cTempTable)->(MsUnlock())

    // Grava Saldo Final
    (cTempTable)->(RecLock((cTempTable), .T.))
        (cTempTable)->NATUREZA  := STR0008 // "Saldo Final"
        For nY := 1 To Len(aGrvSldIn)
            nScan   := aScan(aGrvEnd, { |x| Upper(x[1]) == Upper(aGrvSldIn[nY][1]) })
            If nScan > 0
                (cTempTable)->&(Upper(aGrvEnd[nScan][1])) := aGrvSldIn[nY][2] + aGrvEnd[nScan][2]
            Endif
        Next nY
    (cTempTable)->(MsUnlock())

    (cTempTable)->(DbGoTop())

    (cAliasFIV)->(DBCloseArea())

Return cTempTable

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LHedN
Monta o cabeçalho (headers) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		06/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LHedN(cMoeda As Character, aCab As Array, cPeriodo As Character) AS Array

    Local aHeader   AS Array
    Local cSimbMoe  As Character
    Local cDesLink  As Character
    Local cSizeCol  As Character
    Local cLinkAux  As Character
    Local nMoeda    AS Numeric
    Local nY        As Numeric
    Local oDate     As Json

    Default cMoeda   := ""

    aHeader   := {}
    cSimbMoe  := SuperGetMV("MV_SIMB1")
    cSizeCol  := '200px'
    cLinkAux  := STR0004 + "|" + STR0005 + "|" + STR0006  + "|" + STR0007  + "|" + STR0008
    cDesLink  := "(row) => '" + cLinkAux + "'.includes(row.natureza)"

    //Exemplo de como deve ser a expressão para o correto tratamento pelo front.
    //cDesLink := "(row) => 'Saldos Iniciais|Total de Entradas|Total de Saídas|Saldo Operacional|Saldo Final'.includes(row.natureza)"

    nY        := 0

    nMoeda    := RecMoeda(Date(), cMoeda )

    If nMoeda > 0
        cSimbMoe := SuperGetMV("MV_SIMB" + Alltrim(Str(Val(cMoeda))))
    Endif

    // Monta Header para apresentação do aglutinado de naturezas FIV

    AAdd(aHeader, {"natureza", STR0001, "link", , , .T., , cSizeCol, cDesLink }) // "Naturezas"
    If cPeriodo == "1" // Por DIA
        For nY := 1 To Len(aCab)
            AAdd(aHeader, {"prev" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")  , STR0011 + SubStr(aCab[nY][1], 1, 5), "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Previsto "  + aCab[ny][1]"
            AAdd(aHeader, {"real" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")  , STR0012 + SubStr(aCab[nY][1], 1, 5), "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado " + aCab[ny][1]"

            If _lIntTOP
                AAdd(aHeader, {"pbas" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","") , STR0026 + SubStr(aCab[nY][1], 1, 5), "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Linha Base " + aCab[ny][1]"
                AAdd(aHeader, {"psld" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","") , STR0027 + SubStr(aCab[nY][1], 1, 5), "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Saldo " + aCab[ny][1]"
            Endif
        Next nY
    ElseIf cPeriodo == "2" // Por SEMANA
        For nY := 1 To Len(aCab)
            oDate := FD101Dates(cPeriodo, aCab[nY][1])
            AAdd(aHeader, {"prev" + oDate['sufix'], STR0011 + oDate['label'], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // STR0011 = "Previsto "
            AAdd(aHeader, {"real" + oDate['sufix'], STR0012 + oDate['label'], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // STR0012 = "Realizado "

            If _lIntTOP
                AAdd(aHeader, {"pbas"  + oDate['sufix'], STR0026 + oDate['label'], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // STR0026 = "Projeto - Linha Base "
                AAdd(aHeader, {"psld"  + oDate['sufix'], STR0027 + oDate['label'], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // STR0027 = "Projeto - Saldo "
            Endif
        Next nY
    ElseIf cPeriodo == "3" // Por Mes
        For nY := 1 To Len(aCab)
            AAdd(aHeader, {"prev" + StrTran(aCab[nY][1], "/",""), STR0011 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Previsto "
            AAdd(aHeader, {"real" + StrTran(aCab[nY][1], "/",""), STR0012 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado "
            AAdd(aHeader, {"orca" + StrTran(aCab[nY][1], "/",""), STR0013 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Orçado "

            If _lIntTOP
                AAdd(aHeader, {"pbas"  + StrTran(aCab[nY][1], "/",""), STR0026 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Linha Base "
                AAdd(aHeader, {"psld"  + StrTran(aCab[nY][1], "/",""), STR0027 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Saldo "     
            Endif
        Next nY
    ElseIf cPeriodo == "4" // Por Ano
        For nY := 1 To Len(aCab)
            AAdd(aHeader, {"prev" + aCab[nY][1], STR0011 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Previsto "
            AAdd(aHeader, {"real" + aCab[nY][1], STR0012 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado "
            AAdd(aHeader, {"orca" + aCab[nY][1], STR0013 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado "

            If _lIntTOP
                AAdd(aHeader, {"pbas" + aCab[nY][1], STR0026 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Linha Base "
                AAdd(aHeader, {"psld" + aCab[nY][1], STR0027 + aCab[nY][1], "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Projeto - Saldo "     
            Endif
        Next nY
    Endif

    If cPeriodo == "1" .Or. cPeriodo == "2"
        AAdd(aHeader, {"prevttl" , STR0009, "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Previsto Total"
        AAdd(aHeader, {"realttl" , STR0010, "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado Total"
    ElseIf cPeriodo == "3" .Or. cPeriodo == "4"
        AAdd(aHeader, {"prevttl" , STR0009, "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Previsto Total"
        AAdd(aHeader, {"realttl" , STR0010, "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Realizado Total"
        AAdd(aHeader, {"orcattl" , STR0014, "currency",cSimbMoe + "  ",.F., .T., , cSizeCol }) // "Orçado Total"
    Endif

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LHedD
Monta o cabeçalho (headers) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		14/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LHedD(cMoeda As Character) AS Array

    Local aHeader   AS Array
    Local cSimbMoe  As Character
    Local nMoeda    AS Numeric

    Default cMoeda   := ""

    aHeader   := {}
    cSimbMoe  := SuperGetMV("MV_SIMB1")

    nMoeda    := RecMoeda(Date(), cMoeda )

    If nMoeda > 0
        cMoeda := SuperGetMV("MV_SIMB" + Alltrim(Str(Val(cMoeda))))
    Endif

    // Monta Header para apresentação dos detalhes das naturezas FJV
    AAdd(aHeader, {"natureza" , STR0001, , , .F., .T.                         }) // "Naturezas"
    AAdd(aHeader, {"moeda"    , STR0015, , , .F., .T.                         }) // "Moeda"
    AAdd(aHeader, {"carteira" , STR0016, , , .F., .T., FD100GLabe(1)          }) // "Carteira"
    AAdd(aHeader, {"tpsaldo"  , STR0017, , , .F., .T., FD100GLabe(3)          }) // "Tipo de Saldo"
    AAdd(aHeader, {"datamov"  , STR0018, , , .F., .T.                         }) // "Data"
    AAdd(aHeader, {"valor"    , STR0019, "currency",cSimbMoe + "  ", .F., .T. }) // "Valor"
    AAdd(aHeader, {"movimento", STR0020, , , .F., .T., FD100GLabe(4)          }) // "Movimentos"
    AAdd(aHeader, {"origem"   , STR0021, , , .F., .T.                         }) // "Origem do Movimento"

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LIteN
Monta os detalhes (items) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		09/11/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LIteN(aCab As Array, cPeriodo As Character, aItemsAux As Array, aGrvTtl As Array, cDataIni As Character, cDataFim As Character, aGrvSldIn As Array ) AS Array

    Local aItems    As Array
    Local nY        As Numeric
    Local cDtAuxIni As Character
    Local cDtAuxFim As Character
    Local cPrevPer  As Character
    Local cRealPer  As Character
    Local cOrcaPer  As Character
    Local cProjBas  As Character
    Local cProjSld  As Character
    Local oDate     As Json

    aItems    := {}
    nY        := 0
    cDtAuxIni := ""
    cDtAuxFim := ""
    cPrevPer  := ""
    cRealPer  := ""
    cOrcaPer  := ""
    cProjBas  := ""
    cProjSld  := ""

    AAdd(aItems, {"natureza" , "natureza" })
    If cPeriodo == "1" // Por DIA
        For nY := 1 To Len(aCab)
            cPrevPer    := "prev" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")
            cRealPer    := "real" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")
            AAdd(aItems, { cPrevPer, cPrevPer }) // "Previsto"
            AAdd(aItems, { cRealPer, cRealPer }) // "Realizado"

            Aadd(aGrvSldIn, {cPrevPer, 0 })
            Aadd(aGrvSldIn, {cRealPer, 0 })

            Aadd(aItemsAux, {"2", DtoS(CtoD(aCab[nY][1])), DtoS(CtoD(aCab[nY][1])), cPrevPer, cRealPer })
            Aadd(aItemsAux, {"3", DtoS(CtoD(aCab[nY][1])), DtoS(CtoD(aCab[nY][1])), cPrevPer, cRealPer })

            Aadd(aGrvTtl, {"prev"  + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
            Aadd(aGrvTtl, {"real"  + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
            Aadd(aGrvTtl, {"operR" + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
            Aadd(aGrvTtl, {"operP" + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })

            If _lIntTOP
                cProjBas    := "pbas" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")
                cProjSld    := "psld" + StrTran(SubStr(aCab[nY][1], 1, 5), "/","")
                AAdd(aItems,    { cProjBas, cProjBas }) // "Projeto - Linha Base "
                AAdd(aItems,    { cProjSld, cProjSld }) // "Projeto - Saldo "     
                Aadd(aGrvSldIn, {cProjBas, 0 })
                Aadd(aGrvSldIn, {cProjSld, 0 })
                Aadd(aItemsAux, {"B", DtoS(CtoD(aCab[nY][1])), DtoS(CtoD(aCab[nY][1])), cProjBas, cProjSld })
                Aadd(aItemsAux, {"S", DtoS(CtoD(aCab[nY][1])), DtoS(CtoD(aCab[nY][1])), cProjBas, cProjSld })
                Aadd(aGrvTtl,   {"pbas"  + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
                Aadd(aGrvTtl,   {"psld"  + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
                Aadd(aGrvTtl,   {"operB" + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
                Aadd(aGrvTtl,   {"operS" + StrTran(SubStr(aCab[nY][1], 1, 5), "/",""), 0 })
            Endif
        Next nY
    ElseIf cPeriodo == "2" // Por SEMANA
        For nY := 1 To Len(aCab)
            oDate := FD101Dates(cPeriodo, aCab[nY][1])

            cPrevPer    := "prev" + oDate['sufix']
            cRealPer    := "real" + oDate['sufix']
            AAdd(aItems, { cPrevPer, cPrevPer }) // "Previsto"  + aCab[ny][1]"
            AAdd(aItems, { cRealPer, cRealPer }) // "Realizado" + aCab[ny][1]"

            Aadd(aGrvSldIn, {cPrevPer, 0 })
            Aadd(aGrvSldIn, {cRealPer, 0 })

            Aadd(aItemsAux, {"2", oDate['sqlStartDate'], oDate['sqlEndDate'], cPrevPer, cRealPer })
            Aadd(aItemsAux, {"3", oDate['sqlStartDate'], oDate['sqlEndDate'], cPrevPer, cRealPer })

            Aadd(aGrvTtl, {"prev"  + oDate['sufix'], 0 })
            Aadd(aGrvTtl, {"real"  + oDate['sufix'], 0 })
            Aadd(aGrvTtl, {"operP" + oDate['sufix'], 0 })
            Aadd(aGrvTtl, {"operR" + oDate['sufix'], 0 })

            If _lIntTOP
                cProjBas    := "pbas" + oDate['sufix']
                cProjSld    := "psld" + oDate['sufix']
                AAdd(aItems, { cProjBas, cProjBas }) // "Projeto - Linha Base "
                AAdd(aItems, { cProjSld, cProjSld }) // "Projeto - Saldo "     
                Aadd(aGrvSldIn, {cProjBas, 0 })
                Aadd(aGrvSldIn, {cProjSld, 0 })
                Aadd(aItemsAux, {"B", oDate['sqlStartDate'], oDate['sqlEndDate'], cProjBas, cProjSld })
                Aadd(aItemsAux, {"S", oDate['sqlStartDate'], oDate['sqlEndDate'], cProjBas, cProjSld })
                Aadd(aGrvTtl, {"pbas"  + oDate['sufix'], 0 })
                Aadd(aGrvTtl, {"psld"  + oDate['sufix'], 0 })
                Aadd(aGrvTtl, {"operB" + oDate['sufix'], 0 })
                Aadd(aGrvTtl, {"operS" + oDate['sufix'], 0 })
            Endif
        Next nY
    ElseIf cPeriodo == "3" // Por Mes
        For nY := 1 To Len(aCab)
            cPrevPer    := "prev" + StrTran(aCab[nY][1], "/","")
            cRealPer    := "real" + StrTran(aCab[nY][1], "/","")
            cOrcaPer    := "orca" + StrTran(aCab[nY][1], "/","")
            AAdd(aItems, { cPrevPer, cPrevPer }) // "Previsto"  + aCab[ny][1]"
            AAdd(aItems, { cRealPer, cRealPer }) // "Realizado" + aCab[ny][1]"
            AAdd(aItems, { cOrcaPer, cOrcaPer }) // "Previsto"  + aCab[ny][1]"

            If _lIntTOP
                cProjBas    := "pbas" + StrTran(aCab[nY][1], "/","")
                cProjSld    := "psld" + StrTran(aCab[nY][1], "/","")
                AAdd(aItems, { cProjBas, cProjBas }) // "Projeto - Linha Base "
                AAdd(aItems, { cProjSld, cProjSld }) // "Projeto - Saldo "     
            Endif

            If nY == 1 .And. nY == Len(aCab)
                cDtAuxIni   := cDataIni
                cDtAuxFim   := cDataFim
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY == 1 .And. nY < Len(aCab)
                cDtAuxIni   := cDataIni
                cDtAuxFim   := Dtos(CtoD(cValToChar(Last_Day(Ctod(SubStr(cDataIni, 7, 2) + "/" + SubStr(aCab[nY][1], 1, 8)))) + "/" + SubStr(aCab[nY][1], 1, 8)))
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY > 1 .And. nY < Len(aCab)
                cDtAuxIni   := DtoS(CtoD("01/" + SubStr(aCab[nY][1], 1, 8)))
                cDtAuxFim   := Dtos(CtoD(cValToChar(Last_Day(Ctod("01/" + SubStr(aCab[nY][1], 1, 8)))) + "/" + SubStr(aCab[nY][1], 1, 8)))
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY > 1 .And. nY == Len(aCab)
                cDtAuxIni   := DtoS(CtoD("01/" + SubStr(aCab[nY][1], 1, 8)))
                cDtAuxFim   := cDataFim
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            Endif
            Aadd(aGrvTtl, {"prev" + StrTran(aCab[nY][1], "/",""), 0 })
            Aadd(aGrvTtl, {"real" + StrTran(aCab[nY][1], "/",""), 0 })
            Aadd(aGrvTtl, {"orca" + StrTran(aCab[nY][1], "/",""), 0 })
            Aadd(aGrvTtl, {"operP" + StrTran(aCab[nY][1], "/",""), 0 })
            Aadd(aGrvTtl, {"operR" + StrTran(aCab[nY][1], "/",""), 0 })

            If _lIntTOP
                Aadd(aGrvTtl, {"pbas"  + StrTran(aCab[nY][1], "/",""), 0 })
                Aadd(aGrvTtl, {"psld"  + StrTran(aCab[nY][1], "/",""), 0 })
                Aadd(aGrvTtl, {"operB" + StrTran(aCab[nY][1], "/",""), 0 })
                Aadd(aGrvTtl, {"operS" + StrTran(aCab[nY][1], "/",""), 0 })
            Endif
        Next nY
    ElseIf cPeriodo == "4" // Por Ano
        For nY := 1 To Len(aCab)
            cPrevPer    := "prev" + aCab[nY][1]
            cRealPer    := "real" + aCab[nY][1]
            cOrcaPer    := "orca" + aCab[nY][1]
            AAdd(aItems, { cPrevPer, cPrevPer }) // "Previsto"  + aCab[ny][1]"
            AAdd(aItems, { cRealPer, cRealPer }) // "Realizado" + aCab[ny][1]"
            AAdd(aItems, { cOrcaPer, cOrcaPer }) // "Previsto"  + aCab[ny][1]"

            If _lIntTOP
                cProjBas    := "pbas"  + aCab[nY][1]
                cProjSld    := "psld"  + aCab[nY][1]
                AAdd(aItems, { cProjBas, cProjBas }) // "Projeto - Linha Base "
                AAdd(aItems, { cProjSld, cProjSld }) // "Projeto - Saldo "     
            Endif

            If nY == 1 .And. nY == Len(aCab)
                cDtAuxIni   := cDataIni
                cDtAuxFim   := cDataFim
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY == 1 .And. nY < Len(aCab)
                cDtAuxIni   := cDataIni
                cDtAuxFim   := SubStr(aCab[nY][1], 1, 8) + "1231"
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY > 1 .And. nY < Len(aCab)
                cDtAuxIni   := aCab[nY][1] + "0101"
                cDtAuxFim   := aCab[nY][1] + "1231"
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            ElseIf nY > 1 .And. nY == Len(aCab)
                cDtAuxIni   := aCab[nY][1] + "0101"
                cDtAuxFim   := cDataFim
                Aadd(aGrvSldIn, {cPrevPer, 0 })
                Aadd(aGrvSldIn, {cRealPer, 0 })

                Aadd(aItemsAux, {"2", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"3", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })
                Aadd(aItemsAux, {"1", cDtAuxIni, cDtAuxFim, cPrevPer, cRealPer, cOrcaPer })

                If _lIntTOP
                    Aadd(aGrvSldIn, {cProjBas, 0 })
                    Aadd(aGrvSldIn, {cProjSld, 0 })
                    Aadd(aItemsAux, {"B", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                    Aadd(aItemsAux, {"S", cDtAuxIni, cDtAuxFim, cProjBas, cProjSld })
                Endif
            Endif
            Aadd(aGrvTtl, {"prev" + aCab[nY][1], 0 })
            Aadd(aGrvTtl, {"real" + aCab[nY][1], 0 })
            Aadd(aGrvTtl, {"orca" + aCab[nY][1], 0 })
            Aadd(aGrvTtl, {"operP" + aCab[nY][1], 0 })
            Aadd(aGrvTtl, {"operR" + aCab[nY][1], 0 })

            If _lIntTOP
                Aadd(aGrvTtl, {"pbas"  + aCab[nY][1], 0 })
                Aadd(aGrvTtl, {"psld"  + aCab[nY][1], 0 })
                Aadd(aGrvTtl, {"operB" + aCab[nY][1], 0 })
                Aadd(aGrvTtl, {"operS" + aCab[nY][1], 0 })
            Endif
        Next nY
    Endif

    If cPeriodo == "1" .Or. cPeriodo == "2"
        AAdd(aItems,  {"prevttl" , "prevttl" }) // "Previsto Total" 
        AAdd(aItems,  {"realttl" , "realttl" }) // "Realizado Total"
        Aadd(aGrvTtl, {"prevttl" ,  0 } )
        Aadd(aGrvTtl, {"realttl" ,  0 } )
        Aadd(aGrvTtl, {"operPttl",  0 } )
        Aadd(aGrvTtl, {"operRttl",  0 } )

        Aadd(aGrvSldIn, {"prevttl", 0 })
        Aadd(aGrvSldIn, {"realttl", 0 })

        If _lIntTOP
            Aadd(aGrvTtl, {"operBttl",  0 } )
            Aadd(aGrvTtl, {"operSttl",  0 } )
        Endif
    ElseIf cPeriodo == "3" .Or. cPeriodo == "4"
        AAdd(aItems,  {"prevttl" , "prevttl" }) // "Previsto Total" 
        AAdd(aItems,  {"realttl" , "realttl" }) // "Realizado Total"
        AAdd(aItems,  {"orcattl" , "orcattl" }) // "Previsto Total" 
        Aadd(aGrvTtl, {"prevttl" , 0 } )
        Aadd(aGrvTtl, {"realttl" , 0 } )
        Aadd(aGrvTtl, {"orcattl" , 0 } )
        Aadd(aGrvTtl, {"operPttl", 0 } )
        Aadd(aGrvTtl, {"operRttl", 0 } )

        Aadd(aGrvSldIn, {"prevttl" , 0 } )
        Aadd(aGrvSldIn, {"realttl" , 0 } )
        Aadd(aGrvSldIn, {"orcattl" , 0 } )

        If _lIntTOP
            Aadd(aGrvTtl, {"operBttl", 0 } )
            Aadd(aGrvTtl, {"operSttl", 0 } )
        Endif
    Endif

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LIteD
Monta os detalhes (items) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		09/11/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LIteD() AS Array

    Local aItems    AS Array

    aItems    := {}

    AAdd(aItems, {"natureza" , "natureza"  }) // "Natureza"
    AAdd(aItems, {"moeda"    , "moeda"     }) // "Moeda"
    AAdd(aItems, {"carteira" , "carteira"  }) // "Carteira"
    AAdd(aItems, {"tpsaldo"  , "tpsaldo"   }) // "Tipo de Saldo"
    AAdd(aItems, {"datamov"  , "FJV_DATA"  }) // "Data"
    AAdd(aItems, {"valor"    , "valor"     }) // "Valor"
    AAdd(aItems, {"movimento", "movimento" }) // "Movimentos"
    AAdd(aItems, {"origem"   , "origem"    }) // "Origem do Movimento"

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LStru
Retorna array com a estrutura da tabela de naturezas FIV

@author		francisco.oliveira
@since		09/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101LStru(aItems As Array) AS Array

    Local aEstruct  AS Array
    Local nY        As Numeric

    aEstruct  := {}
    nY        := 0

    For nY := 1 To Len(aItems)
        If Alltrim(Upper(aItems[nY][1])) == "NATUREZA"
            AAdd(aEstruct,{aItems[nY][1] , "C", getClassSz(), 0 }  )
        Else
            AAdd(aEstruct,{aItems[nY][1] , "N", 16, 2 }  )
        EndIf
    Next nY

Return aEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} getVlrAux
Retorna valor da movimentação das naturezas tabela FIV

@author		francisco.oliveira
@since		11/10/20220
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function getVlrAux(cFilAux As Character, cNatureza As Character, cDataIni As Character, cDataFim As Character, cTpSaldo As Character, cCarteira As Character, cMoeda As Character, oJson As Json) As Numeric

    Local cQuery        As Character
    Local cQueryAux     As Character
    Local nMoeda        As Numeric
    Local nValorNat     As Numeric
    Local cFilQuery     As Character
    Local nParam        As Numeric

    cQuery      := ""
    cQueryAux   := ""
    nMoeda      := RecMoeda(Date(), cMoeda )
    nValorNat   := 0
    nParam      := 1
    cQueryAux   := FD101LDive(oJson)
    cFilQuery   := FD101LFil(oJson, "FIV")

    cQuery += "SELECT SUM(VALOR) VALORFJV FROM ( "
    cQuery += "  SELECT DISTINCT "
    cQuery += "    FJV.R_E_C_N_O_ AS RECNO_FJV, "
    cQuery += "    FJV.FJV_VALOR AS VALOR "
    cQuery += "  FROM " + RetSqlName("FIV") + " FIV "
    cQuery += "  INNER JOIN " + RetSqlName("FJV") + " FJV "
    cQuery += "    ON " + totvs.protheus.backoffice.ngf.util.BranchRelation({"FJV","FJV_FILIAL","FJV"}, {"FIV","FIV_FILIAL","FIV"})
    cQuery += "    AND FIV.FIV_NATUR  = FJV.FJV_NATUR "
    cQuery += "    AND FIV.FIV_TPSALD = FJV.FJV_TPSALD "
    cQuery += "    AND FIV.FIV_CARTEI = FJV.FJV_CARTEI "
    cQuery += "    AND FIV.FIV_DATA   = FJV.FJV_DATA "
    cQuery += "  WHERE FIV.D_E_L_E_T_ = ? "
    cQuery += "    AND FJV.D_E_L_E_T_ = ? "

    If !Empty(cFilQuery)
        cQuery += " AND FIV.FIV_FILIAL IN (?) "
    Else
        cQuery += " AND FIV.FIV_FILIAL >= ? "
        cQuery += " AND FIV.FIV_FILIAL <= ? "
    EndIf

    cQuery += " AND FIV_NATUR   = ? "
    cQuery += " AND FIV_DATA   >= ? "
    cQuery += " AND FIV_DATA   <= ? "
    cQuery += " AND FIV_CARTEI  = ? "
    cQuery += " AND FIV_TPSALD  = ? "
    cQuery += " AND FIV_MOEDA   = ? "

    If !Empty(cQueryAux)
        cQuery += cQueryAux
    Endif

    cQuery += ") VALORFIL "

    _ObjFIV := FwExecStatement():new(ChangeQuery(cQuery))

    _ObjFIV:SetString(nParam++, ' ')
    _ObjFIV:SetString(nParam++, ' ')

    If !Empty(cFilQuery)
        _ObjFIV:setUnSafe(nParam++, cFilQuery)
    Else
        _ObjFIV:SetString(nParam++, Space(TamSX3("FJV_FILIAL")[1]))
        _ObjFIV:SetString(nParam++, Replicate("Z", TamSX3("FJV_FILIAL")[1]))
    EndIf

    _ObjFIV:SetString(nParam++, cNatureza)
    _ObjFIV:SetString(nParam++, cDataIni)
    _ObjFIV:SetString(nParam++, cDataFim)
    _ObjFIV:SetString(nParam++, cCarteira)
    _ObjFIV:SetString(nParam++, cTpSaldo)
    _ObjFIV:SetString(nParam++, '01')

    nValorNat := _ObjFIV:ExecScalar("VALORFJV")

    If nMoeda > 0 .And. cMoeda > '01'
        nValorNat := xMoeda(nValorNat, 1, Val(cMoeda), date(), 2)
    Endif

Return nValorNat

//-------------------------------------------------------------------
/*/{Protheus.doc} SldInicial
Retorna Saldo Bancario Inicial 

@author		francisco.oliveira
@since		11/10/20220
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function SldInicial(oJsonFilter As Json, aBancos as Array, cPeriodo As Character, cNatureza As Character) As Numeric

    Local cFilAux	As Character
    Local cTemp     As Character
    Local cQuery    As Character
    Local cBcoAux   As Character
    Local cAgeAux   As Character
    Local cCtaAux   As Character
    Local cDataIni  As Character
    Local cMoeda    As Character
    Local nVlrTtl   As Numeric
    Local nVlrAtu   As Numeric
    Local nVlrCon   As Numeric
    Local nFilSA6   As Numeric
    Local nY        As Numeric
    Local nMoeda    As Numeric
    Local lChkBco   As Logical
    Local lChkFil   As Logical

    nVlrTtl  := 0
    nVlrAtu  := 0
    nVlrCon  := 0
    nY       := 0
    cQuery   := ""
    cBcoAux  := ""
    cAgeAux  := ""
    cCtaAux  := ""
    cFilAux  := ""
    cDataIni := Dtos(STod(StrTran(oJsonFilter['dateIni'], "-", "")) - 1 )
    cTemp    := GetNextAlias()
    lChkBco  := .F.
    lChkFil  := .F.

    cMoeda      := SubStr(oJsonFilter['moedas'], 1, 2)
    nMoeda      := RecMoeda(Date(), cMoeda )

    nFilSA6 := Len(Alltrim(xFilial("SA6")))

    If aBancos[1][1]
        For nY := 2 To Len(aBancos)
            If nY == 2
                cBcoAux += " '" + aBancos[nY][1] + "' "
                cAgeAux += " '" + aBancos[nY][2] + "' "
                cCtaAux += " '" + aBancos[nY][3] + "' "
            Else 
                cBcoAux += " ,'" + aBancos[nY][1] + "' "
                cAgeAux += " ,'" + aBancos[nY][2] + "' "
                cCtaAux += " ,'" + aBancos[nY][3] + "' "
            Endif
        Next nY
        lChkBco := .T.
    Endif

    If !SubStr(oJsonFilter['considFil'][1], 1, 1) == "1"
        For nY := 1 To Len(oJsonFilter['considFil'])
            If nY == 1
                cFilAux += " '"  + SubStr(oJsonFilter['considFil'][nY], 1, nFilSA6) + "' "
            Else
                cFilAux += " ,'" + SubStr(oJsonFilter['considFil'][nY], 1, nFilSA6) + "' "
            Endif
        Next nY
        lChkFil := .T.
    EndIf

    cQuery  := " SELECT "
    cQuery  += " SUM(E8_SALATUA) SALDOATU, SUM(E8_SALRECO) SALDOCONC "
    cQuery  += " FROM "       + RetSqlName("SA6") + " SA6 " 
    cQuery  += " INNER JOIN " + RetSqlName("SE8") + " SE8 " 
    cQuery  += " ON "
    cQuery  += "     SE8.E8_BANCO    = SA6.A6_COD "
    cQuery  += " AND SE8.E8_AGENCIA  = SA6.A6_AGENCIA "
    cQuery  += " AND SE8.E8_CONTA    = SA6.A6_NUMCON "
    cQuery  += " WHERE "
    cQuery  += "     SA6.D_E_L_E_T_  = ' ' "
    cQuery  += " AND SE8.D_E_L_E_T_  = ' ' "
    
    If lChkFil
        cQuery  += " AND SA6.A6_FILIAL  IN ( "  + cFilAux + " ) "
    Else
        cQuery  += " AND SA6.A6_FILIAL  >= '" + Space(nFilSA6) + "' "
        cQuery  += " AND SA6.A6_FILIAL  <= '" + Replicate("Z", nFilSA6) + "' "
    Endif
    
    If lChkBco 
        cQuery  += " AND SA6.A6_COD     IN ( "  + cBcoAux + " ) "
        cQuery  += " AND SA6.A6_AGENCIA IN ( "  + cAgeAux + " ) "
        cQuery  += " AND SA6.A6_NUMCON  IN ( "  + cCtaAux + " ) "
    Else
        cQuery  += " AND SA6.A6_COD     >= '" + Space(TamSX3("A6_COD")[1]) + "' "
        cQuery  += " AND SA6.A6_COD     <= '" + Replicate("Z", TamSX3("A6_COD")[1]) + "' "
        cQuery  += " AND SA6.A6_AGENCIA >= '" + Space(TamSX3("A6_AGENCIA")[1]) + "' "
        cQuery  += " AND SA6.A6_AGENCIA <= '" + Replicate("Z", TamSX3("A6_AGENCIA")[1]) + "' "
        cQuery  += " AND SA6.A6_NUMCON  >= '" + Space(TamSX3("A6_NUMCON")[1])  + "' "
        cQuery  += " AND SA6.A6_NUMCON  <= '" + Replicate("Z", TamSX3("A6_NUMCON")[1])  + "' "
    Endif
    cQuery  += " AND SA6.A6_FLUXCAI IN('S', ' ') "
    cQuery  += " AND " + totvs.protheus.backoffice.ngf.util.BranchRelation( {"SA6","A6_FILIAL","SA6"}, {"SE8","E8_FILIAL","SE8"} )  + " "

    cQuery  += " AND (SA6.A6_BLOCKED != '1' "
    cQuery  += " OR (SA6.A6_BLOCKED = '1' AND SA6.A6_DTBLOQ > '" + DtoS(dDataBase) + "')) "

    If SA6->(FieldPos( "A6_MSBLQL")) > 0
        cQuery  += " AND SA6.A6_MSBLQL != '1' "
    EndIf

    cQuery  += " AND SE8.E8_DTSALAT  = "
    cQuery  += " ( SELECT MAX(TMP.E8_DTSALAT) "
    cQuery  += " FROM "
    cQuery  += " "  + RetSqlName("SE8") + " TMP " 
    cQuery  += " WHERE "
    cQuery  += "     TMP.E8_FILIAL   = SE8.E8_FILIAL "
    cQuery  += " AND TMP.E8_BANCO    = SA6.A6_COD "
    cQuery  += " AND TMP.E8_AGENCIA  = SA6.A6_AGENCIA "
    cQuery  += " AND TMP.E8_CONTA    = SA6.A6_NUMCON "
    cQuery  += " AND TMP.E8_DTSALAT <= '" + cDataIni + "' "
    cQuery  += " AND TMP.D_E_L_E_T_  = ' ' )

    cQuery	:= ChangeQuery(cQuery)

    MPSysOpenQuery( cQuery, cTemp )

    While (cTemp)->(!Eof())
        nVlrAtu += (cTemp)->SALDOATU
        nVlrCon += (cTemp)->SALDOCONC
        (cTemp)->(dbSkip())
    EndDo

    If SubStr(oJsonFilter['tpSaldo'], 1, 1) == "1"
        nVlrTtl := nVlrAtu
    ElseIf SubStr(oJsonFilter['tpSaldo'], 1, 1) == "2"
        nVlrTtl := nVlrCon
    ElseIf SubStr(oJsonFilter['tpSaldo'], 1, 1) == "3"
        nVlrTtl := nVlrAtu - nVlrCon
    Endif

    (cTemp)->(DBCloseArea())

    If nMoeda > 0 .And. cMoeda > '01'
        nVlrTtl := xMoeda(nVlrTtl, 1, Val(cMoeda), date(), 2)
    Endif

Return nVlrTtl

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LQryD
Retorna Query com as movimentações detalhadas das Naturezas - FJV

@author		francisco.oliveira
@since		11/10/20220
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LQryD(cNatJson As Character, cDataIni As Character, cDataFim As Character, cMoeda As Character, oJsonFilter as Json) As Character

    Local cQuery     As Character
    Local cTemp      As Character
    Local cTempTable As Character
    Local aEstruct   As Character
    Local cNatureza  As Character
    Local cNameCart  As Character 
    Local cNameTpSl  As Character
    Local cNameTpMo  As Character
    Local oDashFJV   AS Object
    Local nMoeda     As Numeric
    Local nVlrMov    As Numeric
    Local cFilQuery  As Character
    Local cFilIni    As Character
    Local cFilFim    As Character
    Local nParam     As Numeric
    Local oQryFJV    As Object

    Default oJsonFilter := JsonObject():New()

    cQuery      := ""
    cNameCart   := ""
    cNameTpSl   := ""
    cNameTpMo   := ""
    cFilQuery   := ""
    cNatureza   := SubStr(cNatJson, 1, TamSx3("FJV_NATUR")[1])
    cTemp       := ""
    cTempTable  := GetNextAlias()
    nMoeda      := RecMoeda(Date(), cMoeda )
    nVlrMov     := 0
    nParam      := 1
    oQryFJV     := Nil

    If oJsonFilter:HasProperty("considFil")
        cFilQuery   := FD101LFil(oJsonFilter, "FJV")
    EndIf

    If Empty(cFilQuery)
        cFilIni := Space(TamSX3("FJV_FILIAL")[1])
        cFilFim := Replicate("Z", TamSX3("FJV_FILIAL")[1])
    Endif

    cQuery  := " SELECT "
    cQuery  += " SUM(FJV_VALOR) VLRMOV, FJV.FJV_NATUR, FJV.FJV_DATA, FJV.FJV_TPSALD, "
    cQuery  += " FJV.FJV_CLORIG, FJV.FJV_MOEDA, FJV.FJV_CARTEI, FJV.FJV_TPMOV "
    cQuery  += " FROM "  + RetSqlName("FJV") + " FJV "
    cQuery  += " WHERE "
    cQuery  += " D_E_L_E_T_ = ? "

    If !Empty(cFilQuery)
        cQuery += " AND FJV.FJV_FILIAL IN (?) "
    Else
        cQuery += " AND FJV.FJV_FILIAL  >= ? "
        cQuery += " AND FJV.FJV_FILIAL  <= ? "
    Endif

    cQuery  += " AND FJV.FJV_NATUR  <> ? "
    cQuery  += " AND FJV.FJV_NATUR   = ? "
    cQuery  += " AND FJV.FJV_CARTEI IN (?) "
    cQuery  += " AND FJV.FJV_TPSALD IN (?) "
    cQuery  += " AND FJV.FJV_DATA   >= ? "
    cQuery  += " AND FJV.FJV_DATA   <= ? "
    cQuery  += " GROUP BY FJV_NATUR, FJV_DATA, FJV_TPSALD, FJV_CLORIG, FJV_MOEDA, FJV_CARTEI, FJV_TPMOV "
    cQuery  += " ORDER BY FJV_TPSALD "

    oQryFJV := FWExecStatement():new(ChangeQuery(cQuery))

    oQryFJV:SetString(nParam++, ' ')
    If !Empty(cFilQuery)
        oQryFJV:setUnSafe(nParam++, cFilQuery)
    Else
        oQryFJV:SetString(nParam++, cFilIni)
        oQryFJV:SetString(nParam++, cFilFim)
    EndIf
    oQryFJV:SetString(nParam++, ' ')
    oQryFJV:SetString(nParam++, cNatureza)
    oQryFJV:setIn(nParam++, {"P", "R"})
    oQryFJV:setIn(nParam++, {"1", "2", "3"})
    oQryFJV:SetString(nParam++, cDataIni)
    oQryFJV:SetString(nParam++, cDataFim)

    cTemp := oQryFJV:openAlias()

    aEstruct := FD101LStrD()

    oDashFJV := FWTemporaryTable():New( cTempTable )
    oDashFJV:SetFields(aEstruct)

    oDashFJV:Create()

    While (cTemp)->(!Eof())
        If nMoeda > 0 .And. cMoeda > '01'
            nVlrMov := xMoeda((cTemp)->VLRMOV, 1, Val(cMoeda), date(), 2)
        Else
            nVlrMov := (cTemp)->VLRMOV
        Endif

        If (cTemp)->FJV_TPMOV == "1"
            cNameTpMo   := STR0022 // "Somar"
        Else
            cNameTpMo   := STR0023 // "Subtrair"
        Endif

        If (cTemp)->FJV_CARTEI == "R"
            cNameCart   := STR0024 // "Receita"
        Else
            cNameCart   := STR0025 // "Despesa"
        Endif

        If (cTemp)->FJV_TPSALD == "1"
            cNameTpSl   := STR0013 // "Orçado"
        ElseIf (cTemp)->FJV_TPSALD == "2"
            cNameTpSl   := STR0011 // "Previsto"
        Else
            cNameTpSl   := STR0012 // "Realizado"
        Endif
        (cTempTable)->(RecLock((cTempTable), .T.))
            (cTempTable)->NATUREZA  := Upper(cNatJson)
            (cTempTable)->MOEDA     := (cTemp)->FJV_MOEDA
            (cTempTable)->CARTEIRA  := cNameCart
            (cTempTable)->TPSALDO   := cNameTpSl
            (cTempTable)->FJV_DATA  := (cTemp)->FJV_DATA
            (cTempTable)->VALOR     := nVlrMov
            (cTempTable)->MOVIMENTO := cNameTpMo
            (cTempTable)->ORIGEM    := (cTemp)->FJV_CLORIG
        (cTempTable)->(MsUnlock())
        (cTemp)->(dbSkip())
    Enddo

    (cTemp)->(DBCloseArea())

    (cTempTable)->(DbGoTop())

Return cTempTable

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LStrD
Retorna array com a estrutura da tabela de naturezas FJV

@author		francisco.oliveira
@since		14/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function FD101LStrD() AS Array

    Local aStruct  AS Array
    aStruct  := {}

    AAdd(aStruct, {"natureza" , "C", getClassSz(), 0 }) // "Natureza"
    AAdd(aStruct, getStruct("FJV_MOEDA", "moeda")) // "Moeda"
    AAdd(aStruct, {"carteira" , "C", 10, 0 }) // "Carteira"
    AAdd(aStruct, {"tpsaldo"  , "C", 10, 0 }) // "Tipo de Saldo"
    AAdd(aStruct, {"FJV_DATA" , "C", 08, 0 }) // "Data"
    AAdd(aStruct, getStruct("FJV_VALOR", "valor")) // "Valor"
    AAdd(aStruct, {"movimento", "C", 10, 0 }) // "Movimentos"
    AAdd(aStruct, getStruct("FJV_ORIGEM", "origem")) // "Origem do Movimento"

Return aStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LDive
Retorna String como filtro para a query da tabela FJV
// "Não Considera"
// "Considera Comissão de Venda"
// "Considera Títulos a Receber"
// "Considera Titulos a Pagar"  
@author		francisco.oliveira
@since		19/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD101LDive(oJsonFilter As Json) AS Character

    Local cQueryAux AS Character
    Local cCtrlStr  As Character
    Local nY        As Numeric 

    cQueryAux  := ""
    cCtrlStr   := ""

    If oJsonFilter['diversos'] == NIL
        oJsonFilter['diversos'] := {}
    Endif

    If Len(oJsonFilter['diversos']) > 0 .And. Len(oJsonFilter['diversos']) < 3
        For nY := 1 To Len(oJsonFilter['diversos'])
            cCtrlStr += SubStr(oJsonFilter['diversos'][nY], 1, 1 )
        Next nY

        If cCtrlStr == "1"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITR' " // "Considera Títulos a Receber"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITP' " // "Considera Titulos a Pagar"  
        ElseIf cCtrlStr == "2"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITP' " // "Considera Titulos a Pagar"  
            cQueryAux += " AND FJV.FJV_CLORIG <> 'COMV' " // "Considera Comissão de Venda"
        ElseIf cCtrlStr == "3"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'COMV' " // "Considera Comissão de Venda"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITR' " // "Considera Títulos a Receber"
        ElseIf cCtrlStr == "12"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITP' " // "Considera Titulos a Pagar"  
        ElseIf cCtrlStr == "13"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'TITR' " // "Considera Títulos a Receber"
        ElseIf cCtrlStr == "23"
            cQueryAux += " AND FJV.FJV_CLORIG <> 'COMV' " // "Considera Comissão de Venda"
        Endif
    ElseIf Len(oJsonFilter['diversos']) == 0 // .And. Len(oJsonFilter['diversos']) == 3
        cQueryAux += " AND FJV.FJV_CLORIG <> 'TITP' " // "Considera Titulos a Pagar"  
        cQueryAux += " AND FJV.FJV_CLORIG <> 'TITR' " // "Considera Títulos a Receber"
        cQueryAux += " AND FJV.FJV_CLORIG <> 'COMV' " // "Considera Comissão de Venda"
    Endif

Return cQueryAux

//-------------------------------------------------------------------
/*/{Protheus.doc} FD101LCTTC
Retorna a Array com as Naturezas

@author		francisco.oliveira
@since		05/10/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD101LCTTC(oJson As Json) As Character

    Local cRetCTT   As Character
    Local cTodos    As Character
    Local cConsid   As Character
    Local nY        As Numeric

    cTodos  :=  "1 - " + STR0002 + " " // "Todos"
    cConsid :=  "2 - " + STR0003 + " " // "Não Considera"
    cRetCTT := ""
    nY      := 0 

    If oJson:HasProperty('ccusto')
        If Len(oJson['ccusto']) > 0
            If !(aScan(oJson['ccusto'], {|x| x == cTodos }) > 0)
                If !(aScan(oJson['ccusto'], {|x| x == cConsid }) > 0)
                    For nY := 1 To Len(oJson['ccusto'])
                        If nY == Len(oJson['ccusto'])
                            cRetCTT += " '" + SubStr(oJson['ccusto'][nY], 1, TamSX3("CTT_CUSTO")[1]) + "' "
                        Else
                            cRetCTT += " '" + SubStr(oJson['ccusto'][nY], 1, TamSX3("CTT_CUSTO")[1]) + "', "
                        Endif
                    Next nY
                Else
                    cRetCTT := "2"
                Endif
            Else
                cRetCTT := "1"
            Endif
        Endif
    Else
        cRetCTT := "2"
    Endif

Return cRetCTT

/*/{Protheus.doc} FD101LFJ0
Realiza Totalização dos Valores na FJ0 - RM - TOP
@author Francisco Oliveira
@param  aPerguntes  Array com os parametros para o filtro.
@since  06/03/2014
@version 12
/*/
Function FD101LFJ0(oJson As Json, cDataIni As Character, cDataFim As Character, cSldbase As Character, cRecDesp As Character, cNatureza As Character) As Numeric

    Local cQuery    As Character
    Local cAliasFJ0 As Character
    Local cFilIni   As Character
    Local cFilFim   As Character
    Local cQryFil   As Character
    Local cFilFJ0Qy As Character
    Local cNatIni   As Character
    Local cNatFim   As Character
    Local cCustos   As Character
    Local nVlrRet   As Numeric

    cQuery      := ''
    cFilIni     := ''
    cFilFim     := ''
    cQryFil     := ''
    cFilFJ0Qy   := ''
    cNatIni     := ''
    cNatFim     := ''
    nVlrRet     := 0
    cCustos     := FD101LCTTC(oJson)
    cAliasFJ0   := GetNextAlias()

    If Empty(cNatureza)
        cNatureza   := FD101LSEDC(oJson)

        If Empty(cNatureza)
            cNatIni := Space(TamSX3("ED_CODIGO")[1])
            cNatFim := Replicate("Z", TamSX3("ED_CODIGO")[1])
        Endif
    Else
        cNatureza := "'" + cNatureza + "'"
    Endif

    cFilFJ0Qy   := FD101LFil(oJson, "FJ0")

    If Empty(cFilFJ0Qy)
        cFilIni := Space(TamSX3("FJ0_FILIAL")[1])
        cFilFim := Replicate("Z", TamSX3("FJ0_FILIAL")[1])
    Endif

    cQuery := " SELECT SUM(FJ0_VALOR) VALOR, FJ0_CLASSI, FJ0_DATA, FJ0_NATURE, ED_DESCRIC, ED_PAI, ED_COND "
    cQuery += " FROM " 	    + RetSQLName('FJ0') + " FJ0 "
    cQuery += " LEFT JOIN " + RetSQLName('SED') + " SED "
    cQuery += " ON SED.ED_CODIGO = FJ0.FJ0_NATURE " 

    cQuery  += " AND " + totvs.protheus.backoffice.ngf.util.BranchRelation( {"SED","ED_FILIAL","SED"}, {"FJ0","FJ0_FILIAL","FJ0"} )  + " "

    cQuery += " WHERE "

    cQryFil += "     FJ0.FJ0_FILIAL >= '" + cFilIni + "' "
    cQryFil += " AND FJ0.FJ0_FILIAL <= '" + cFilFim + "' "

    If !(Len(Alltrim(xFilial("FJ0"))) > 0)
        cQryFil     := " FJ0.FJ0_FILIAL  IN ( '" + Space(TamSX3("FJ0_FILIAL")[1]) + "' ) "
        cFilFJ0Qy   := "" //Limpo o filtro que foi enviado pois esta totalmente compartilhada 
    Endif

    If !Empty(cFilFJ0Qy)
        cQuery += " FJ0.FJ0_FILIAL  IN ( " + cFilFJ0Qy + " ) "
    Else
        cQuery += cQryFil
    Endif

    cQuery += " AND FJ0.FJ0_DATA   >= '" + cDataIni + "' "
    cQuery += " AND FJ0.FJ0_DATA   <= '" + cDatafIM + "' "

    If Empty(cNatureza)
        cQuery += " AND FJ0.FJ0_NATURE  >=   '" + cNatIni  + "' " 
        cQuery += " AND FJ0.FJ0_NATURE  <=   '" + cNatFim  + "' "
    Else
        cQuery += " AND FJ0.FJ0_NATURE IN ( "  + cNatureza + " ) "
    Endif

    If cCustos == '1'
        cQuery += " AND FJ0_CCUSTO >= '" + Space(TamSX3("FJ0_CCUSTO")[1]) + "' "
        cQuery += " AND FJ0_CCUSTO <= '" + Replicate("Z", TamSX3("FJ0_CCUSTO")[1]) + "' "
    ElseIf !Empty(cCustos) .And. cCustos != '2'
        cQuery += " AND FJ0_CCUSTO IN (" + cCustos + ")
    Endif

    If cSldbase == "B"
        cQuery += " AND FJ0_CLASSI = '1' "
    Else
        cQuery += " AND FJ0_CLASSI = '2' "
    Endif

    If !Empty(cRecDesp)
        cQuery += " AND SED.ED_COND =   '" + cRecDesp  + "' "
    Endif

    cQuery += " AND FJ0.D_E_L_E_T_ = ' ' "
    cQuery += " AND SED.D_E_L_E_T_ = ' ' "
    cQuery += " GROUP BY FJ0_DATA, FJ0_CLASSI, FJ0_NATURE, FJ0_VALOR, ED_DESCRIC, ED_PAI, ED_COND "

    cQuery := ChangeQuery(cQuery)

    MPSysOpenQuery( cQuery, cAliasFJ0 )

    (cAliasFJ0)->(DbGoTop())

    While !(cAliasFJ0)->(Eof()) 
        nVlrRet += (cAliasFJ0)->VALOR
        (cAliasFJ0)->(dbSkip())
    Enddo

    (cAliasFJ0)->(DbCloseArea())

Return nVlrRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getClassSz
    @description Retorna o tamanho do campo de natureza das tabelas temporárias, 
    considerando código, descrição e hífen.
    @author		guilherme.sordi
    @since		11/07/2024
    @version    12.1.2310
/*/
//-------------------------------------------------------------------
Static function getClassSz() as numeric
    default _nClassSz := TamSx3("ED_CODIGO")[1] + len(" - ") + TamSX3("ED_DESCRIC")[1] 
return _nClassSz

//-------------------------------------------------------------------
/*/{Protheus.doc} getStruct
    @description Retorna array de estrutura de campo do dicionário de dados substituindo o nome do 
    campo por um apelido quando necessário. Usado para definir a estrutura da tabela
    temporária respeitando o tamanho dos campos no dicionário.
    @author		guilherme.sordi
    @since		11/07/2024
    @version    12.1.2310
/*/
//-------------------------------------------------------------------
Static Function getStruct(cFieldName as Character, cNickName as Character) as array
    local aStruct as array

    default cNickName := cFieldName

    aStruct := {}

    aStruct := FWSX3Util():GetFieldStruct( cFieldName )
    aStruct[1] := cNickName

Return aStruct


//-------------------------------------------------------------------
/*/{Protheus.doc} FD101Dates
    @description Centraliza a identificação do período a ser consultado.
    Recebe o texto conforme definição da API e devolve um json com o texto que será usado 
    para identificar o período em questão no sufixo do nome da coluna/propriedade, rótulo e filtro 
    SQL.
    Inicialmente usada para SEMANA, mas no futuro poderão ser implementados os 
    outros tipos de período.
    @author		guilherme.sordi
    @since		11/07/2024
    @version    12.1.2410
/*/
//-------------------------------------------------------------------
function FD101Dates(cPeriod as character, cValue as character) as json    
    local cLabel as Character
    local cSufix as Character
    local cPreposit as Character //Preposição
    local jDates as json
    local dStart as Date
    local dEnd as Date

    cPreposit := STR0028 // "a"
    cLabel := ""
    cSufix := ""
    jDates := JsonObject():new()
    dStart := cToD("  /  /    ")
    dEnd := cToD("  /  /    ")

    if cPeriod == "2"
        cSufix := StrTran(SubStr(cValue, 1, 5), "/","")
        cLabel := SubStr(cValue, 1, 5) + " " + cPreposit + " " + SubStr(cValue, 14, 5) //Exemplo "01/10 a 07/10"
        dStart := CtoD(SubStr(cValue,  1, 10))
        dEnd := CtoD(SubStr(cValue, 14, 10))
    endIf

    jDates['sufix'] := cSufix
    jDates['label'] := cLabel
    jDates['sqlStartDate'] := DtoS(dStart)
    jDates['sqlEndDate'] := DtoS(dEnd)
return jDates
