#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FIND100LOAD.CH"

Static __oConsQry As Object
Static __oConsMov As Object
Static __cConsNat As Character
Static __cBDname  AS Character
Static __cSrvType AS Character

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LNatu
Retorna o tipo de movimento por Natureza

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

//SUBIDA PARA O D-1 EM 08/06/2021

Function FD100LNatu(dMesIni As Character, dAnoIni As Character, dAnoFim As Character, nPeriodo AS Numeric, cCarteira As Character, cMoeda As Character, ctpSaldo As Character, cConsTit As Character) AS Array

Local aVlrNat   AS Array
Local cQuery    As Character
Local cTemp     As Character
Local cAuxAno   As Character
Local cStrDB    As Character
Local nY        AS Numeric
Local nPerData  AS Numeric
Local nTtlPR    AS Numeric
Local nMoeda    AS Numeric
Local nVlrAux   AS Numeric
Local lInfoOrac AS Logical
Local lPostGre  AS Logical
Local oStatement As Object
Local nValorNat As Numeric

Default dMesIni     := ""
Default dAnoIni     := ""
Default dAnoFim     := ""
Default nPeriodo    := 0
Default cCarteira   := ""
Default cMoeda      := ""
Default ctpSaldo    := ""
Default cConsTit    := ""

aVlrNat   := {}
cQuery    := ""
cTemp     := GetNextAlias()
cAuxAno   := ""
nY        := 0
nTtlPR    := 0
nPerData  := Val(dMesIni)
nMoeda    := RecMoeda(Date(), cMoeda )
nVlrAux   := 0
__cBDname := Upper( TCGetDB() )
__cSrvType:= TcSrvType()
lInfoOrac := .F.
lPostGre  := .F.
oStatement := NIL
nValorNat := 0

cAuxAno   := dAnoIni

If __cBDname $ "INFORMIX*ORACLE"
    cStrDB    := "NVL"
    lInfoOrac := .T.
ElseIf  __cBDname $ "DB2*POSTGRES" .OR. ( __cBDname == "DB2/400" .And. Upper(cSrvType) == "ISERIES" )
    cStrDB   := "COALESCE"
    lPostGre := .T.
Else
    cStrDB := "ISNULL"
EndIf

For nY := 1 To nPeriodo

    cMes  := MesExtenso(nPerData)

    If oStatement == NIL
        cQuery += "SELECT "
        cQuery += cStrDB
        cQuery += "(SUM(FIW_VALOR),0) VLNAT "
        cQuery += " FROM "  + RetSqlName("FIW") + " FIW "
        cQuery += " WHERE "
        cQuery += " FIW.FIW_FILIAL  =  '" + xFilial("FIW") + "' "
        cQuery += " AND FIW.D_E_L_E_T_ = ' ' "
        cQuery += " AND FIW_NATUR != ' ' "
        cQuery += " AND FIW_DATA  >= ? " 
        cQuery += " AND FIW_DATA  <= ? " 
        cQuery += " AND FIW_CARTEI = ? "
        cQuery += " AND FIW_MOEDA  = '01' "
        cQuery += " AND FIW_TPSALD = ? " 

        oStatement := FWPreparedStatement():New(cQuery)
    Endif

    oStatement:SetString(1, cAuxAno + StrZero(nPerData,2) + "01")
    oStatement:SetString(2, cAuxAno + StrZero(nPerData,2) + "31")
    oStatement:SetString(3, cCarteira)
    oStatement:SetString(4, ctpSaldo)

    cQuery := oStatement:GetFixQuery()
    nValorNat := MpSysExecScalar(cQuery, "VLNAT")

    If !Empty(cConsTit)
        nTtlPR := FD100LCons(nPerData, cAuxAno, cCarteira, cConsTit )
    Endif

    If nMoeda > 0 .And. cMoeda > '01'
        nVlrAux := xMoeda(nValorNat - nTtlPR, 1, Val(cMoeda), date(), 2)
        AAdd(aVlrNat, ( nVlrAux ) )
    Else
        AAdd(aVlrNat, nValorNat - nTtlPR )
    Endif

    nPerData++
    If nPerData > 12
        cAuxAno := Alltrim(Str(Val(cAuxAno) + 1))
        nPerData := 1
    Endif

Next nY

Return aVlrNat

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LPgRe
Define função para valores do títulos Pagar/Receber

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LPgRe(cDtIni As Character, cDtFim As Character, cTpMov As Character, cRealiz As Character, cMoeda  As Character, cTpSaldo As Character, cPagRec As Character) AS Array

Local cQuery    As Character
Local cTemp     As Character
Local aRecTtl   AS Array
Local nTtlVlr   AS Numeric
Local nMoeda    AS Numeric
Local cTable    As Character
Local cCart     As Character
Local nParam    As Numeric
Local cDtFilter As Character
Local oQrVlTit  As Object

Default cDtIni      := ""
Default cDtFim      := ""
Default cTpMov      := ""
Default cRealiz     := ""
Default cMoeda      := ""
Default cTpSaldo    := ""
Default cPagRec     := ""

cQuery      := ""
cTable      := "SE1"
cCart       := "R"
cDtFilter   := cDtIni
aRecTtl     := {}
nTtlVlr     := 0
nParam      := 1
oQrVlTit    := Nil
nMoeda      := RecMoeda(Date(), cMoeda)

If cPagRec == "Rec"
    cQuery := FD100LRece(cTpMov, cRealiz)
Else
    cQuery := FD100LPaga(cTpMov, cRealiz)
    cTable := "SE2"
    cCart  := "P"
Endif

cQuery := ChangeQuery(cQuery)
oQrVlTit := FwExecStatement():new(cQuery)
oQrVlTit:SetString(nParam++, " ")                 //FI7.D_E_L_E_T_ | FI8.D_E_L_E_T_
oQrVlTit:SetString(nParam++, xFilial(cTable))     //E1_FILIAL | E2_FILIAL 
If cTpMov == "A"
    cDtFilter := DtoS(Date())
EndIf
oQrVlTit:SetString(nParam++, cDtFilter)           //E1_VENCREA >= | E2_VENCREA >=
oQrVlTit:SetString(nParam++, cDtFim)              //E1_VENCREA <= | E2_VENCREA <=
If cTpMov == "V"
    oQrVlTit:SetString(nParam++, DtoS(Date()))    //E1_VENCREA < | E2_VENCREA <
EndIf
oQrVlTit:SetString(nParam++, " ")                 //SE1.D_E_L_E_T_ | E2.D_E_L_E_T_ =

oQrVlTit:SetString(nParam++, xFilial('FIW'))      //FIW_FILIAL
oQrVlTit:SetString(nParam++, cCart)               //FIW_CARTEI =
oQrVlTit:SetString(nParam++, "01")                //FIW_MOEDA  =
oQrVlTit:SetString(nParam++, cTpSaldo)            //FIW_TPSALD =
oQrVlTit:SetString(nParam++, cDtIni)              //FIW_DATA  >=
oQrVlTit:SetString(nParam++, cDtFim)              //FIW_DATA  <=
oQrVlTit:SetString(nParam++, " ")                 //FIW.D_E_L_E_T_ =

cTemp := oQrVlTit:OpenAlias()

While (cTemp)->(!Eof())

    If nMoeda > 0 .And. cMoeda > "01"
        nTtlVlr += xMoeda((cTemp)->TOTAL, (cTemp)->MOEDA, Val(cMoeda), date(), 2)
    ElseIf (cTemp)->MOEDA != 1
        nTtlVlr += xMoeda((cTemp)->TOTAL, (cTemp)->MOEDA, Val(cMoeda), date(), 2)
    Else
        nTtlVlr += (cTemp)->TOTAL
    Endif

    (cTemp)->(dbSkip())
EndDo

AAdd(aRecTtl, nTtlVlr)

(cTemp)->(DBCloseArea())

Return aRecTtl

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LRece
Retorna valores do Contas a Receber

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100LRece(cTpMov As Character, cRealiz As Character) AS Array
    Local cQuery  As Character

    Default cTpMov      := ""
    Default cRealiz     := ""

    cQuery := " SELECT "

    If Empty(cRealiz)
        cQuery += " SUM("
        cQuery +=   " CASE WHEN SE1.E1_TIPO IN " + FormatIn(MVABATIM, "|") + " THEN (SE1.E1_VALOR * -1) ELSE SE1.E1_VALOR END "
        cQuery += " ) TOTAL, E1_MOEDA MOEDA "
    Else
        cQuery += " (SUM(E1_VALOR) - SUM(E1_SALDO)) TOTAL, "
        cQuery += " E1_MOEDA MOEDA "
    Endif

    cQuery += " FROM "  + RetSqlName("SE1") + " SE1 "
    cQuery += " INNER JOIN " + RetSqlName("FIW") + " FIW "
    cQuery += " ON "
    cQuery += totvs.protheus.backoffice.ngf.util.BranchRelation( {"SE1","E1_FILIAL","SE1"}, {"FIW","FIW_FILIAL","FIW"}  ) 
    cQuery += " AND SE1.E1_NATUREZ = FIW.FIW_NATUR "
    cQuery += " LEFT JOIN  " + RetSqlName("FI7") + " FI7 "
    cQuery += " ON "
    cQuery +=   " FI7.FI7_FILIAL = SE1.E1_FILIAL "
    cQuery +=   " AND FI7.FI7_PRFORI = SE1.E1_PREFIXO "
    cQuery +=   " AND FI7.FI7_NUMORI = SE1.E1_NUM "
    cQuery +=   " AND FI7.FI7_PARORI = SE1.E1_PARCELA "
    cQuery +=   " AND FI7.FI7_TIPORI = SE1.E1_TIPO "
    cQuery +=   " AND FI7.FI7_CLIORI = SE1.E1_CLIENTE "
    cQuery +=   " AND FI7.FI7_LOJORI = SE1.E1_LOJA "
    cQuery +=   " AND FI7.D_E_L_E_T_ = ? "
    cQuery += " WHERE "
    cQuery +=   " SE1.E1_FILIAL = ? "
    cQuery +=   " AND SE1.E1_VENCREA >= ? "
    cQuery +=   " AND SE1.E1_VENCREA <= ? "
    If cTpMov == "V"
        cQuery += " AND SE1.E1_VENCREA < ? "
    Endif
    cQuery +=   " AND SE1.D_E_L_E_T_ = ? "

    cQuery +=   " AND FIW.FIW_FILIAL = ? "
    cQuery +=   " AND FIW.FIW_CARTEI = ? "
    cQuery +=   " AND FIW.FIW_MOEDA  = ? "
    cQuery +=   " AND FIW.FIW_TPSALD = ? "
    cQuery +=   " AND FIW.FIW_DATA  >= ? "
    cQuery +=   " AND FIW.FIW_DATA  <= ? "
    cQuery +=   " AND FIW.D_E_L_E_T_ = ? "
    cQuery +=   " AND FI7.FI7_NUMORI IS NULL "

    If !Empty(cRealiz)
        cQuery += " GROUP BY E1_SALDO, E1_VALOR, E1_MOEDA "
    Else
        cQuery += " GROUP BY E1_MOEDA "
    Endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LPaga
Retorna valores do Contas a Pagar

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100LPaga(cTpMov As Character, cRealiz As Character) AS Array
    Local cQuery  As Character

    Default cTpMov      := ""
    Default cRealiz     := ""

    cQuery := " SELECT "

    If Empty(cRealiz)
        cQuery += " SUM(E2_VALOR) TOTAL, E2_MOEDA MOEDA "
    Else
        cQuery += " (SUM(E2_VALOR) - SUM(E2_SALDO)) TOTAL, "
        cQuery += " E2_MOEDA MOEDA "
    Endif

    cQuery += " FROM "  + RetSqlName("SE2") + " SE2 "
    cQuery += " INNER JOIN " + RetSqlName("FIW") + " FIW "
    cQuery += " ON "
    cQuery +=   totvs.protheus.backoffice.ngf.util.BranchRelation( {"SE2","E2_FILIAL","SE2"}, {"FIW","FIW_FILIAL","FIW"}  )
    cQuery +=   " AND SE2.E2_NATUREZ = FIW.FIW_NATUR "
    cQuery += " LEFT JOIN  " + RetSqlName("FI8") + " FI8 "
    cQuery += " ON "
    cQuery +=   " FI8.FI8_FILIAL = SE2.E2_FILIAL "
    cQuery +=   " AND FI8.FI8_PRFORI = SE2.E2_PREFIXO "
    cQuery +=   " AND FI8.FI8_NUMORI = SE2.E2_NUM "
    cQuery +=   " AND FI8.FI8_PARORI = SE2.E2_PARCELA "
    cQuery +=   " AND FI8.FI8_TIPORI = SE2.E2_TIPO "
    cQuery +=   " AND FI8.FI8_FORORI = SE2.E2_FORNECE "
    cQuery +=   " AND FI8.FI8_LOJORI = SE2.E2_LOJA "
    cQuery +=   " AND FI8.D_E_L_E_T_ = ? "
    cQuery += " WHERE "
    cQuery +=   " SE2.E2_FILIAL  = ? "
    cQuery +=   " AND SE2.E2_VENCREA >= ? "
    cQuery +=   " AND SE2.E2_VENCREA <= ? "

    If cTpMov == "V"
        cQuery += " AND SE2.E2_VENCREA < ? "
    Endif
    cQuery +=   " AND SE2.D_E_L_E_T_ = ? "
    
    cQuery +=   " AND FIW.FIW_FILIAL = ? "
    cQuery +=   " AND FIW.FIW_CARTEI = ? "
    cQuery +=   " AND FIW.FIW_MOEDA  = ? "
    cQuery +=   " AND FIW.FIW_TPSALD = ? "
    cQuery +=   " AND FIW.FIW_DATA  >= ? "
    cQuery +=   " AND FIW.FIW_DATA  <= ? "
    cQuery +=   " AND FIW.D_E_L_E_T_ = ? "
    cQuery +=   " AND FI8.FI8_NUMORI IS NULL "

    cQuery += " GROUP BY E2_VALOR, E2_SALDO, E2_MOEDA "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LSNat
Monta query com retorno das Naturezas e seus movimentos

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LSNat(cDataIni As Character, cDataFim As Character, cTipo As Character, cExibNat As Character, aRetTipo AS Array, cMoeda As Character, aFilter AS Array, ctpSaldo As Character) AS Array

Local cSelect   As Character
Local cEDCond   As Character
Local cFIWCart  As Character
Local cAliasFIW As Character
Local cTemp     As Character
Local cCarteir  As Character
Local cRecPrE1  As Character
Local cPagPrE2  As Character
Local cRecReE1  As Character
Local cPagReE2  As Character
Local cTpSldIN  As Character
Local lRealiz   AS Logical
Local lMovim    AS Logical
Local oDashFIW  AS Object
Local aEstruct  AS Array
Local nPrev     AS Numeric
Local nReal     AS Numeric
Local nOrca     AS Numeric
Local nConsid   AS Numeric
Local nMoeda    AS Numeric
Local nY        AS Numeric

cSelect     := ""
cEDCond     := ""
cFIWCart    := ""
cCarteir    := ""
cRecPrE1    := ""
cPagPrE2    := ""
cRecReE1    := ""
cPagReE2    := ""
cTpSldIN    := ""
cAliasFIW   := GetNextAlias()
cTemp       := GetNextAlias()
lRealiz     := .F.
lMovim      := .F.
aEstruct    := {}
nPrev       := 0
nReal       := 0
nOrca       := 0
nConsid     := 0
nMoeda      := RecMoeda(Date(), cMoeda)
nY          := 0

Default cDataIni := ""
Default cDataFim := ""
Default cExibNat := ""
Default cMoeda   := ""
Default cTipo    := ""
Default ctpSaldo := ""
Default aRetTipo := {}
Default aFilter  := {}

If cTipo = "Orçado Receita" .Or. cTipo = "Orçado Despesa"
    cTpSldIN := "'1'"
Else
    cTpSldIN := ctpSaldo
Endif

If cTipo = "Previsto Receita" .Or. cTipo = "Orçado Receita"
    cEDCond := "'R'"
    cFIWCart:= "'R'"
ElseIf cTipo = "Previsto Despesas" .Or. cTipo = "Orçado Despesa"
    cEDCond := "'D'"
    cFIWCart:= "'P'"
ElseIf cTipo = "Realizado Receita" .Or. cTipo = "Realizado Despesas"
    lRealiz := .T.
    lMovim  := .T.
    cEDCond := "'D','R'"
    cFIWCart:= "'P','R'"
Else
    cEDCond := "'D','R'"
    cFIWCart:= "'P','R'"
Endif

cSelect := " SELECT SED.ED_PAI, SED.ED_CODIGO, SED.ED_DESCRIC, SUM(FIW.FIW_VALOR) AS TOTAL,
cSelect += " SED.ED_CONTA, SED.ED_DEBITO, SED.ED_CCD, SED.ED_ITEMD, SED.ED_CLVLDB,
cSelect += " SED.ED_CREDIT, SED.ED_CCC, SED.ED_ITEMC, SED.ED_CLVLCR,  "
cSelect += " CASE "
cSelect += " WHEN FIW.FIW_CARTEI = 'R' THEN 'Receita' "
cSelect += " WHEN FIW.FIW_CARTEI = 'P' THEN 'Despesa' "
cSelect += " END AS MOVIMENTO "

cSelect += " FROM "       + RetSqlName("SED") + " SED "
cSelect += " INNER JOIN " + RetSqlName("FIW") + " FIW "

cSelect += " ON SED.ED_CODIGO = FIW.FIW_NATUR "

cSelect += " WHERE "

If Len(aFilter) > 0
    For nY := 1 To Len(aFilter)
        cSelect += aFilter[nY][1] + " AND "
    Next nY
Endif

cSelect += " SED.D_E_L_E_T_ = ' ' "
cSelect += " AND SED.ED_FILIAL   = '"  + xFilial("SED") + "' "
cSelect += " AND SED.ED_COND    IN ("  + cEDCond + ") "
cSelect += " AND FIW.D_E_L_E_T_  = ' ' "
cSelect += " AND FIW.FIW_FILIAL  = '"  + xFilial("FIW") + "' "
cSelect += " AND FIW.FIW_CARTEI IN ("  + cFIWCart + ") "
cSelect += " AND FIW.FIW_DATA   >= '"  + cDataIni + "' "
cSelect += " AND FIW.FIW_DATA   <= '"  + cDataFim + "' "
cSelect += " AND FIW.FIW_MOEDA = '01' "

If !Empty(cTpSldIN)
    cSelect += " AND FIW.FIW_TPSALD IN ("  + cTpSldIN + ") "
Endif

If lRealiz .And. lMovim
    cSelect += " AND FIW.FIW_TPSALD = '3' AND "
    cSelect += " ( EXISTS (SELECT E1_FILIAL "
    cSelect += " FROM " + RetSqlName("SE1") + " SE1 "
    cSelect += " WHERE "
    cSelect += " E1_FILIAL   = FIW_FILIAL AND "
    cSelect += " E1_NATUREZ  = FIW_NATUR  AND "
    cSelect += " E1_VENCREA >= '"  + cDataIni + "' AND "
    cSelect += " E1_VENCREA <= '"  + cDataFim + "' AND "
    cSelect += " D_E_L_E_T_ = ' ' ) "

    cSelect += " OR  EXISTS (SELECT E2_FILIAL "
    cSelect += " FROM " + RetSqlName("SE2") + " SE2 "
    cSelect += " WHERE "
    cSelect += " E2_FILIAL  = FIW_FILIAL AND "
    cSelect += " E2_NATUREZ = FIW_NATUR  AND "
    cSelect += " E2_VENCREA >= '"  + cDataIni + "' AND "
    cSelect += " E2_VENCREA >= '"  + cDataIni + "' AND "
    cSelect += " D_E_L_E_T_ = ' ' )) "
Endif

cSelect += " GROUP BY ED_PAI, ED_CODIGO, ED_DESCRIC, ED_CONTA, ED_DEBITO, ED_CCD, ED_ITEMD, ED_CLVLDB, ED_CREDIT, ED_CCC, ED_ITEMC, ED_CLVLCR, ED_COND, FIW_CARTEI "

cSelect += " ORDER BY ED_PAI, ED_CODIGO "

cSelect	:= ChangeQuery(cSelect)

MPSysOpenQuery( cSelect, cTemp )

(cTemp)->(DbGoTop())

//Deleta a tabela temporária no banco de dados, caso já exista
If oDashFIW <> Nil
	oDashFIW:Delete()
	oDashFIW := Nil
Endif

aEstruct := FD100LStru(cExibNat, "SED")

oDashFIW := FWTemporaryTable():New( cAliasFIW )
oDashFIW:SetFields(aEstruct)

If cExibNat = "1"
    oDashFIW:AddIndex("1", {"ED_PAI","ED_CODIGO"})
Else
    oDashFIW:AddIndex("1", {"ED_CODIGO"})
Endif

oDashFIW:Create()

If Len(aRetTipo) > 0
    cRecPrE1 := Iif(Len(aRetTipo) >= 1, aRetTipo[1], "")
    cPagPrE2 := Iif(Len(aRetTipo) >= 2, aRetTipo[2], "")
    cRecReE1 := Iif(Len(aRetTipo) >= 3, aRetTipo[3], "")
    cPagReE2 := Iif(Len(aRetTipo) >= 4, aRetTipo[4], "")
Endif

While (cTemp)->(!Eof())
    If (cTemp)->MOVIMENTO == 'Receita'
        cCarteir = 'R'
    Else
        cCarteir = 'P'
    Endif

    nConsid  := 0
    cConsTit := Iif(cCarteir = "R", cRecPrE1, cPagPrE2 )
    If !Empty(cConsTit)
        nConsid  := FD100LCons(, , cCarteir, cConsTit, {cDataIni, cDataFim}, (cTemp)->ED_CODIGO )
    Endif

    nPrev := (FD100LMovi("2", cDataIni, cDataFim, cCarteir, (cTemp)->ED_CODIGO) - nConsid)

    nConsid  := 0
    cConsTit := Iif(cCarteir = "R", cRecReE1, cPagReE2 )
    If !Empty(cConsTit)
        nConsid  := FD100LCons(, , cCarteir, cConsTit, {cDataIni, cDataFim}, (cTemp)->ED_CODIGO )
    Endif

    nReal := (FD100LMovi("3", cDataIni, cDataFim, cCarteir, (cTemp)->ED_CODIGO) - nConsid)

    nOrca := FD100LMovi("1", cDataIni, cDataFim, cCarteir, (cTemp)->ED_CODIGO)

    If cMoeda > '01' .And. nMoeda > 0
        nPrev := xMoeda(nPrev, 1, Val(cMoeda), Date(), 2)
        nReal := xMoeda(nReal, 1, Val(cMoeda), Date(), 2)
        nOrca := xMoeda(nOrca, 1, Val(cMoeda), Date(), 2)
    Endif

    If nPrev > 0 .Or. nReal > 0 .Or. nOrca > 0
        If !(cAliasFIW)->(DBSeek((cTemp)->ED_PAI))
            If cExibNat = "1"
                If !Empty((cTemp)->ED_PAI)
                    (cAliasFIW)->(RecLock((cAliasFIW), .T.))
                    (cAliasFIW)->ED_PAI     := (cTemp)->ED_PAI
                    (cAliasFIW)->ED_DESCRIC := Posicione("SED", 1, xFilial("SED") + (cTemp)->ED_PAI, "ED_DESCRIC") //(cTemp)->ED_DESCRIC
                    (cAliasFIW)->PREVISTO   += nPrev
                    (cAliasFIW)->REALIZADO  += nReal
                    (cAliasFIW)->ORCADO     += nOrca
                    (cAliasFIW)->MOVIMENTO  := Iif(Posicione("SED", 1, xFilial("SED") + (cTemp)->ED_PAI, "ED_COND") = "R", 'Receita', 'Despesa')
                    (cAliasFIW)->(MsUnLock())
                Endif
            Endif

            (cAliasFIW)->(RecLock((cAliasFIW), .T.))

            If cExibNat = "1"
                (cAliasFIW)->ED_PAI     := (cTemp)->ED_PAI
            Endif

            (cAliasFIW)->ED_CODIGO  := (cTemp)->ED_CODIGO
            (cAliasFIW)->ED_DESCRIC := (cTemp)->ED_DESCRIC
            (cAliasFIW)->PREVISTO   := nPrev
            (cAliasFIW)->REALIZADO  := nReal
            (cAliasFIW)->ORCADO     := nOrca
            (cAliasFIW)->TOTAL      := (cTemp)->TOTAL
            (cAliasFIW)->MOVIMENTO  := (cTemp)->MOVIMENTO
            (cAliasFIW)->ED_CONTA   := (cTemp)->ED_CONTA
            (cAliasFIW)->ED_DEBITO  := (cTemp)->ED_DEBITO
            (cAliasFIW)->ED_CCD     := (cTemp)->ED_CCD
            (cAliasFIW)->ED_ITEMD   := (cTemp)->ED_ITEMD
            (cAliasFIW)->ED_CLVLDB  := (cTemp)->ED_CLVLDB
            (cAliasFIW)->ED_CREDIT  := (cTemp)->ED_CREDIT
            (cAliasFIW)->ED_CCC     := (cTemp)->ED_CCC
            (cAliasFIW)->ED_ITEMC   := (cTemp)->ED_ITEMC
            (cAliasFIW)->ED_CLVLCR  := (cTemp)->ED_CLVLCR

            (cAliasFIW)->(MsUnLock())
        Else
            If cExibNat = "1"
                If !Empty((cTemp)->ED_PAI)
                    (cAliasFIW)->(RecLock((cAliasFIW), .F.))
                    (cAliasFIW)->PREVISTO   += nPrev
                    (cAliasFIW)->REALIZADO  += nReal
                    (cAliasFIW)->ORCADO     += nOrca
                    (cAliasFIW)->(MsUnLock())
                Endif
            Endif

            (cAliasFIW)->(RecLock((cAliasFIW), .T.))

            If  cExibNat = "1"
                (cAliasFIW)->ED_PAI     := (cTemp)->ED_PAI
            Endif

            (cAliasFIW)->ED_CODIGO  := (cTemp)->ED_CODIGO
            (cAliasFIW)->ED_DESCRIC := (cTemp)->ED_DESCRIC
            (cAliasFIW)->PREVISTO   := nPrev
            (cAliasFIW)->REALIZADO  := nReal
            (cAliasFIW)->ORCADO     := nOrca
            (cAliasFIW)->TOTAL      := (cTemp)->TOTAL
            (cAliasFIW)->MOVIMENTO  := (cTemp)->MOVIMENTO
            (cAliasFIW)->ED_CONTA   := (cTemp)->ED_CONTA
            (cAliasFIW)->ED_DEBITO  := (cTemp)->ED_DEBITO
            (cAliasFIW)->ED_CCD     := (cTemp)->ED_CCD
            (cAliasFIW)->ED_ITEMD   := (cTemp)->ED_ITEMD
            (cAliasFIW)->ED_CLVLDB  := (cTemp)->ED_CLVLDB
            (cAliasFIW)->ED_CREDIT  := (cTemp)->ED_CREDIT
            (cAliasFIW)->ED_CCC     := (cTemp)->ED_CCC
            (cAliasFIW)->ED_ITEMC   := (cTemp)->ED_ITEMC
            (cAliasFIW)->ED_CLVLCR  := (cTemp)->ED_CLVLCR

            (cAliasFIW)->(MsUnLock())

        Endif
    Endif

    (cTemp)->(dbSkip())
EndDo

(cAliasFIW)->(DbGoTop())

(cTemp)->(DBCloseArea())

Return cAliasFIW

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LStru
Retorna array com a estrutura da tabela de naturezas SED

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100LStru(cExibNat As Character, cAliasAux As Character) AS Array

Local aEstruct  AS Array

Default cExibNat  := ""
Default cAliasAux := "SED"

aEstruct  := {}

If cAliasAux = "SED"

    If cExibNat = "1"
        AAdd(aEstruct, getStruct("ED_PAI") )
    Endif

    AAdd(aEstruct, getStruct("ED_CODIGO") )
    AAdd(aEstruct, getStruct("ED_DESCRIC") )
    AAdd(aEstruct,{"PREVISTO"  , "N", 16, 2 }  )
    AAdd(aEstruct,{"REALIZADO" , "N", 16, 2 }  )
    AAdd(aEstruct,{"ORCADO"    , "N", 16, 2 }  )
    AAdd(aEstruct,{"TOTAL"     , "N", 16, 2 }  )
    AAdd(aEstruct,{"MOVIMENTO" , "C", 10, 0 }  ) //"Despesa" ou "Receita"
    AAdd(aEstruct, getStruct("ED_CONTA") )
    AAdd(aEstruct, getStruct("ED_DEBITO") )
    AAdd(aEstruct, getStruct("ED_CCD") )
    AAdd(aEstruct, getStruct("ED_ITEMD") )
    AAdd(aEstruct, getStruct("ED_CLVLDB") )
    AAdd(aEstruct, getStruct("ED_CREDIT") )
    AAdd(aEstruct, getStruct("ED_CCC") )
    AAdd(aEstruct, getStruct("ED_ITEMC") )
    AAdd(aEstruct, getStruct("ED_CLVLCR") )
ElseIf cAliasAux = "SE1" .Or. cAliasAux = "SE2"
    cAliasAux := SubStr(cAliasAux, 2, 2)
    AAdd(aEstruct, getStruct(cAliasAux + "_PREFIXO") )
    AAdd(aEstruct, getStruct(cAliasAux + "_NUM") )
    AAdd(aEstruct, getStruct(cAliasAux + "_PARCELA") )
    AAdd(aEstruct, getStruct(cAliasAux + "_TIPO") )
    AAdd(aEstruct,{cAliasAux + "_EMISSAO", "C", 10, 0 }  )
    AAdd(aEstruct,{cAliasAux + "_VENCTO" , "C", 08, 0 }  )
    AAdd(aEstruct,{cAliasAux + "_VENCREA", "C", 08, 0 }  )

    If cAliasAux = "E1"
        AAdd(aEstruct, getStruct("E1_NOMCLI") )
        AAdd(aEstruct, getStruct("E1_CLIENTE", "CODIGO") )
    Else
        AAdd(aEstruct, getStruct("E2_NOMFOR") )
        AAdd(aEstruct, getStruct("E2_FORNECE", "CODIGO") )
    Endif

    AAdd(aEstruct, getStruct(cAliasAux + "_NATUREZ", "NATUREZ") )
    AAdd(aEstruct, getStruct(cAliasAux + "_LOJA", "LOJA") )
    AAdd(aEstruct,{"TOTAL"               , "C", 24, 0 }  ) //cSimbMoed + " " + Alltrim(Transform((cAlsTMP)->TOTAL, "@E 999,999,999,999.99"))
    AAdd(aEstruct,{"SALDO"               , "C", 24, 0 }  ) //cSimbMoed + " " + Alltrim(Transform((cAlsTMP)->SALDO, "@E 999,999,999,999.99"))
    AAdd(aEstruct, getStruct("FRV_DESCRI", "SITUACAO") )
    AAdd(aEstruct, getStruct(cAliasAux + "_MOEDA", "MOEDA") )
    AAdd(aEstruct,{"ORIGEM"              , "C", 08, 0 }  )//"Despesa" ou "Receita"
    AAdd(aEstruct,{"STATUS"              , "C", 10, 0 }  ) //"VENCIDO", "A VENCER", "BAIXADO"
Endif

Return aEstruct

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LMovi
Retorna total dos tipos de saldo da FIW por natureza

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100LMovi(cTpSaldo As Character, cDataIni As Character, cDataFim As Character, cCarteir As Character, cNatur As Character) AS Numeric

Local nValor AS Numeric
Local cQuery As Character
Local cTemp  As Character

Default cTpSaldo    := ""
Default cDataIni    := ""
Default cDataFim    := ""
Default cCarteir    := ""
Default cNatur      := ""

nValor  := 0
cQuery  := ""
cTemp   := GetNextAlias()

If __oConsMov == NIl

    cQuery := " SELECT SUM(FIW.FIW_VALOR) AS TOTAL "
    cQuery += " FROM "  + RetSqlName("FIW") + " FIW "
    cQuery += " WHERE FIW_FILIAL  = '"  + xFilial("FIW") + "' AND "
    cQuery += " FIW_NATUR  = ? AND "
    cQuery += " FIW_CARTEI = ? AND "
    cQuery += " FIW_TPSALD = ? AND "
    cQuery += " FIW_DATA  >= ? AND "
    cQuery += " FIW_DATA  <= ? AND "
    cQuery += " FIW.FIW_MOEDA = ? AND "
    cQuery += " D_E_L_E_T_  = ? "

    cQuery	:= ChangeQuery(cQuery)
    __oConsMov := FwExecStatement():New(cQuery)
EndIf

__oConsMov:SetString(1,cNatur)
__oConsMov:SetString(2,cCarteir)
__oConsMov:SetString(3,cTpSaldo)
__oConsMov:SetDate(4,StoD(cDataIni))
__oConsMov:SetDate(5,StoD(cDataFim))
__oConsMov:SetString(6,'01')
__oConsMov:SetString(7,' ')

cTemp := __oConsMov:openAlias()

While (cTemp)->(!Eof())
    nValor  := (cTemp)->TOTAL
    (cTemp)->(dbSkip())
EndDo

(cTemp)->(DBCloseArea())

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LCons
Retorna valor para ser desconsiderado no total do saldo por natureza

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Static Function FD100LCons(nPerData As Numeric, cAuxAno As Character, cCarteira As Character, cConsTit As Character, aPeriodo AS array, cNatur As Character ) AS Numeric

Local nValor AS Numeric
Local cQuery As Character
Local cTemp  As Character
Local cAlias As Character
Local dDtIni As Character
Local dDtFim As Character

Default nPerData    := ""
Default cAuxAno     := ""
Default cCarteira   := ""
Default cConsTit    := ""
Default aPeriodo := {}
Default cNatur   := ""

nValor  := 0
cQuery  := ""
cTemp   := GetNextAlias()
cAlias  := Iif(cCarteira = "R", "SE1", "SE2")

If Len(aPeriodo) > 0
    dDtIni  := aPeriodo[1]
    dDtFim  := aPeriodo[2]
Else
    dDtIni  := cAuxAno + Alltrim(StrZero(nPerData, 2)) + "01"
    dDtFim  := cAuxAno + Alltrim(StrZero(nPerData, 2)) + "31"
Endif

If __cConsNat == NIL
    __cConsNat := ""
EndIf

If __oConsQry == NIl .or. __cConsNat != cNatur
    If __oConsQry <> Nil
		__oConsQry:Destroy()
		__oConsQry := Nil
	Endif

    cQuery := " SELECT SUM(?_SALDO) AS VALOR "
    cQuery += " FROM ? "
    cQuery += " WHERE "
    cQuery += " D_E_L_E_T_ = ' '  AND "
    cQuery += " ?_TIPO IN ( ? ) AND "
    cQuery += " ?_SALDO   > 0    AND "
    cQuery += " ?_VENCREA >= ? AND "
    cQuery += " ?_VENCREA <= ? "

    If !Empty(cNatur)
        cQuery += " AND ?_NATUREZ = '"  + cNatur + "' "
    Endif
    __cConsNat := cNatur
    cQuery	:= ChangeQuery(cQuery)
    __oConsQry := FWPreparedStatement():New(cQuery)
EndIf

__oConsQry:SetNumeric(1,SubStr(cAlias, 2,2))
__oConsQry:SetNumeric(2,RetSqlName(cAlias))
__oConsQry:SetNumeric(3,SubStr(cAlias, 2,2))
__oConsQry:SetNumeric(4,cConsTit)
__oConsQry:SetNumeric(5,SubStr(cAlias, 2,2))
__oConsQry:SetNumeric(6,SubStr(cAlias, 2,2))
__oConsQry:SetDate(7,StoD(dDtIni))
__oConsQry:SetNumeric(8,SubStr(cAlias, 2,2))
__oConsQry:SetDate(9,LastDate(StoD(SubStr(dDtFim,1,6) + '01')))

If !Empty(cNatur)
    __oConsQry:SetNumeric(10,SubStr(cAlias, 2,2))
EndIf
cQuery := __oConsQry:GetFixQuery()

MPSysOpenQuery( cQuery, cTemp )

While (cTemp)->(!Eof())
    nValor := (cTemp)->VALOR
    (cTemp)->(dbSkip())
EndDo

(cTemp)->(DBCloseArea())

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LHePR
Monta o cabeçalho (headers) com dados dos titulos a receber e a pagar

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LHePR() AS Array

Local aHeader AS Array

aHeader := {}

AAdd(aHeader, {"prefixo"  , STR0001, , , .T. , .T. }) // "Prefixo"
AAdd(aHeader, {"titulo"	  , STR0002, , , .T. , .T. }) // "Num Tí­tulo"
AAdd(aHeader, {"parcela"  , STR0003, , , .T. , .T. }) // "Parcela"
AAdd(aHeader, {"tipo"	  , STR0004, , , .T. , .T. }) // "Tipo"
AAdd(aHeader, {"natureza" , STR0005                }) // "Natureza"
AAdd(aHeader, {"codClFor" , STR0037, , , ,.F.      }) // "Codigo"
AAdd(aHeader, {"lojClFor" , STR0038, , , ,.F.      }) // "Loja"
AAdd(aHeader, {"clifor"   , STR0006, , , .F. , .T. }) // "Cliente / Fornecedor"
AAdd(aHeader, {"emissao"  , STR0007                }) // "Emissão"
AAdd(aHeader, {"vencto"   , STR0008                }) // "Vencimento"
AAdd(aHeader, {"vencrea"  , STR0009                }) // "Vencimento Real"
AAdd(aHeader, {"total"    , STR0010, , ,.F.        }) // "Valor"
AAdd(aHeader, {"saldo"    , STR0011, , ,.F.        }) // "Saldo"
AAdd(aHeader, {"situaca"  , STR0012, , , ,.F.      }) // "Situação"
AAdd(aHeader, {"moeda"    , STR0035, , , ,.F.      }) // "Moeda"
AAdd(aHeader, {"origem"   , STR0013, , , , , FD100GLabe(1) }) // "Origem"
AAdd(aHeader, {"status"   , STR0014, , , , , FD100GLabe(2) }) // "Status"

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LItPR
Monta os detalhes (items) com dados dos titulos a receber e a pagar

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LItPR(cAlias As Character) AS Array

Local aItems    AS Array
Local cCliFor   As Character
Local cEmiss    As Character
Local cVencto   As Character
Local cVenRea   As Character
Local cPrefix   As Character
Local cNum      As Character
Local cParc     As Character
Local cTipo     As Character

Default cAlias := "SE1"

aItems  := {}
cCliFor := Iif(cAlias = "SE1", "E1_NOMCLI" , "E2_NOMFOR")
cEmiss  := Iif(cAlias = "SE1", "E1_EMISSAO", "E2_EMISSAO")
cVencto := Iif(cAlias = "SE1", "E1_VENCTO" , "E2_VENCTO")
cVenRea := Iif(cAlias = "SE1", "E1_VENCREA", "E2_VENCREA")
cPrefix := Iif(cAlias = "SE1", "E1_PREFIXO", "E2_PREFIXO")
cNum    := Iif(cAlias = "SE1", "E1_NUM"    , "E2_NUM")
cParc   := Iif(cAlias = "SE1", "E1_PARCELA", "E2_PARCELA")
cTipo   := Iif(cAlias = "SE1", "E1_TIPO"   , "E2_TIPO")

AAdd(aItems, {"prefixo" , cPrefix    })
AAdd(aItems, {"titulo"	, cNum       })
AAdd(aItems, {"parcela"	, cParc      })
AAdd(aItems, {"tipo"	, cTipo      })
AAdd(aItems, {"natureza", "NATUREZ"  })
AAdd(aItems, {"codClFor", "CODIGO"  })
AAdd(aItems, {"lojClFor", "LOJA"  })
AAdd(aItems, {"clifor"  , cCliFor    })
AAdd(aItems, {"emissao" , cEmiss     })
AAdd(aItems, {"vencto"  , cVencto    })
AAdd(aItems, {"vencrea" , cVenRea    })
AAdd(aItems, {"total"   , "TOTAL"    })
AAdd(aItems, {"saldo"   , "SALDO"    })
AAdd(aItems, {"situaca" , "SITUACAO" })
AAdd(aItems, {"moeda"   , "MOEDA"    })
AAdd(aItems, {"origem"  , "ORIGEM"   })
AAdd(aItems, {"status"  , "STATUS"   })

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LHeNa
Monta o cabeçalho (headers) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LHeNa(cExibNat As Character, cMoeda As Character) AS Array

Local lSEDComp  As Character
Local aHeader   AS Array
Local nMoeda    AS Numeric

Default cMoeda   := ""
Default cExibNat := ""

lSEDComp  := FWModeAccess("SED",3) == "C" // Verifica se SED é compartilhada
aHeader   := {}

nMoeda    := RecMoeda(Date(), cMoeda )

If nMoeda > 0
    cMoeda := SuperGetMV("MV_SIMB" + Alltrim(Str(Val(cMoeda))))
Else
    cMoeda := SuperGetMV("MV_SIMB1")
Endif

If lSEDComp
    AAdd(aHeader, {"filial", "Filial"})
Endif

If cExibNat == "1"
    AAdd(aHeader, {"codnatpai" , STR0036, , ,     , .T. }) // "Natureza Superior"
Endif

AAdd(aHeader, {"codnatur"  , STR0015, "link", ,     , .T. }) // "Código da Natureza"
AAdd(aHeader, {"descnatur" , STR0016,       , , .F. , .T. }) // "Descrição da Natureza"
AAdd(aHeader, {"vlrprev"   , STR0017, "currency",cMoeda + "  ",.F., .T.}) // "Total Previsto"
AAdd(aHeader, {"vlrreal"   , STR0018, "currency",cMoeda + "  ",.F., .T.}) // "Total Realizado"
AAdd(aHeader, {"vlrorca"   , STR0019, "currency",cMoeda + "  ",.F., .T.}) // "Total Orçado"
AAdd(aHeader, {"tpmovto"   , STR0020, , , .F. , .T., FD100GLabe(1)  }) // "Movimento"
AAdd(aHeader, {"ctactb"	   , STR0021, , , .F. , .T. }) // "Conta Contábil"
AAdd(aHeader, {"debito"	   , STR0022, , ,     , .F. }) // "Conta Débito"
AAdd(aHeader, {"ccdebito"  , STR0023, , ,     , .F. }) // "C. Custo Débito"
AAdd(aHeader, {"itemdeb"   , STR0024, , ,     , .F. }) // "Item Conta Débito"
AAdd(aHeader, {"clvldeb"   , STR0025, , ,     , .F. }) // "Classe Valor Débito"
AAdd(aHeader, {"credito"   , STR0026, , ,     , .F. }) // "Conta Crédito"
AAdd(aHeader, {"cccredito" , STR0027, , ,     , .F. }) // "C. Custo Crédito"
AAdd(aHeader, {"itemcre"   , STR0028, , ,     , .F. }) // "Item Cont. Crédito"
AAdd(aHeader, {"clvlcre"   , STR0029, , ,     , .F. }) // "Classe Vlr Crédito"

Return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LItNa
Monta os detalhes (items) com dados das Naturezas movimentadas

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LItNa(cExibNat As Character) AS Array

Local lSEDComp  As Character
Local aItems    AS Array

Default cExibNat := ""

lSEDComp  := FWModeAccess("SED",3) == "C" // Verifica se SED é compartilhada
aItems    := {}

If lSEDComp
    AAdd(aItems, {"filial", "SED.ED_FILIAL"})
Endif

If cExibNat = "1"
    AAdd(aItems, {"codnatpai" , "SED.ED_PAI"    })
Endif

AAdd(aItems, {"codnatur"  , "SED.ED_CODIGO" })
AAdd(aItems, {"descnatur" , "SED.ED_DESCRIC"})
AAdd(aItems, {"vlrprev"   , "PREVISTO"      })
AAdd(aItems, {"vlrreal"   , "REALIZADO"     })
AAdd(aItems, {"vlrorca"   , "ORCADO"        })
AAdd(aItems, {"tpmovto"	  , "MOVIMENTO"     })
AAdd(aItems, {"ctactb"	  , "SED.ED_CONTA"  })
AAdd(aItems, {"debito"	  , "SED.ED_DEBITO" })
AAdd(aItems, {"ccdebito"  , "SED.ED_CCD"    })
AAdd(aItems, {"itemdeb"	  , "SED.ED_ITEMD"  })
AAdd(aItems, {"clvldeb"	  , "SED.ED_CLVLDB" })
AAdd(aItems, {"credito"	  , "SED.ED_CREDIT" })
AAdd(aItems, {"cccredito" , "SED.ED_CCC"    })
AAdd(aItems, {"itemcre"	  , "SED.ED_ITEMC"  })
AAdd(aItems, {"clvlcre"	  , "SED.ED_CLVLCR" })

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100GLabe
Retorna Labels com cores especifica por descrição

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100GLabe(nPos AS Numeric) AS Array

    Local aLabels AS Array
    Local aItems  AS Array
    Local aItem   AS Array
    Local nY      AS Numeric

    Default nPos    := 1

    aLabels := {}
    aItems  := {}
    aItem   := {}
    nY      := 0

    If nPos == 1
        AAdd(aLabels,{'Receita'  ,'color-10', STR0030 }) // 'Receita'
        AAdd(aLabels,{'Despesa'  ,'color-07', STR0031 }) // 'Despesa'
    ElseIf nPos == 2
        AAdd(aLabels,{'VENCIDO'  ,'color-07', STR0032 }) // 'Vencido'
        AAdd(aLabels,{'BAIXADO'  ,'color-11', STR0033 }) // 'Baixado'
        AAdd(aLabels,{'A VENCER' ,'color-08', STR0034 }) // 'A Vencer'
    ElseIf nPos == 3
        AAdd(aLabels,{'Orçado'   ,'color-07', STR0039 }) // 'Orçado'
        AAdd(aLabels,{'Previsto' ,'color-11', STR0040 }) // 'Previsto'
        AAdd(aLabels,{'Realizado','color-08', STR0041 }) // 'Realizado'
    ElseIf nPos == 4
        AAdd(aLabels,{'Somar'    ,'color-07', STR0042 }) // 'Somar'
        AAdd(aLabels,{'Subtrair' ,'color-11', STR0043 }) // 'Subtrair'
    Endif

    For nY := 1 To Len(aLabels)
        aItem   := JsonObject():New()
        aItem['value'] := aLabels[nY, 1]
        aItem['color'] := aLabels[nY, 2]
        aItem['label'] := aLabels[nY, 3]

        AAdd(aItems,aItem)
    Next nY

Return aItems

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LQyPR
Monta query com retorno dos titulos a pagar e a receber

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LQyPR(cOrigem As Character, cNatur As Character, cDataIni As Character, cDataFim As Character, aFilter AS Array, nPosPage AS Numeric, nPageSize AS Numeric ) AS Array

Local cWhere    As Character
Local cGroup    As Character
Local cSelect   As Character
Local cAliasTab As Character
Local cAlsTMP   As Character
Local cAlsAux   As Character
Local cStrDB    As Character
Local nY        AS Numeric
Local nCountTmp AS Numeric
Local aEstruct  AS Array
Local oDashTMP  AS Object
Local lInfoOrac AS Logical
Local lPostGre  AS Logical
Local cDate     AS Character

Default cDataIni := ""
Default cDataFim := ""
Default cNatur   := ""
Default cOrigem  := ""
Default aFilter  := {}
Default nPosPage := 1
Default nPageSize:= 10

cWhere      := ""
cGroup      := ""
cSelect     := ""
cAliasTab   := GetNextAlias()
cAlsTMP     := GetNextAlias()
cAlsAux     := ""
nY          := 0
nCountTmp   := 0
aEstruct    := {}
__cBDname   := Upper( TCGetDB() )
__cSrvType  := TcSrvType()
lInfoOrac   := .F.
lPostGre    := .F.
cDate       := DtoS(Date())

If __cBDname $ "INFORMIX*ORACLE"
    cStrDB    := "NVL"
    lInfoOrac := .T.
ElseIf  __cBDname $ "DB2*POSTGRES" .OR. ( __cBDname == "DB2/400" .And. Upper(cSrvType) == "ISERIES" )
    cStrDB   := "COALESCE"
    lPostGre := .T.
Else
    cStrDB := "ISNULL"
EndIf

If cOrigem = "Receita"
    cOrigem := "CR"
Else
    cOrigem := "CP"
Endif

If cOrigem == "CR"
    cSelect := " SELECT E1_PREFIXO AS E1_PREFIXO, E1_NUM AS E1_NUM, E1_PARCELA AS E1_PARCELA, E1_TIPO AS E1_TIPO, "
    cSelect += " E1_NATUREZ AS NATUREZ, FRV_DESCRI AS SITUACAO, E1_NOMCLI AS E1_NOMCLI, E1_MOEDA AS MOEDA, "
    cSelect += " E1_EMISSAO AS E1_EMISSAO, E1_VENCREA AS E1_VENCREA, E1_VENCTO AS E1_VENCTO, E1_VALOR AS TOTAL, "
    cSelect += " E1_CLIENTE AS CODIGO, E1_LOJA AS LOJA, "
    cSelect += " E1_SALDO AS SALDO, ('Receita') AS ORIGEM, "
    cSelect += " CASE "

    If lInfoOrac
        cSelect += " WHEN (E1_VENCREA <  SYSDATE AND E1_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E1_VENCREA >= SYSDATE AND E1_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E1_VENCREA <  SYSDATE AND E1_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E1_VENCREA >= SYSDATE AND E1_SALDO = 0) THEN 'BAIXADO' "
    ElseIf lPostGre
        cSelect += " WHEN (E1_VENCREA <  '" + cDate + "' AND E1_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E1_VENCREA >= '" + cDate + "' AND E1_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E1_VENCREA <  '" + cDate + "' AND E1_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E1_VENCREA >= '" + cDate + "' AND E1_SALDO = 0) THEN 'BAIXADO' "
    Else
        cSelect += " WHEN (E1_VENCREA <  GETDATE() AND E1_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E1_VENCREA >= GETDATE() AND E1_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E1_VENCREA <  GETDATE() AND E1_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E1_VENCREA >= GETDATE() AND E1_SALDO = 0) THEN 'BAIXADO' "
    Endif

    cSelect += " END AS STATUS "

    cSelect += " FROM " + RetSqlName("SE1") + " SE1 "

    cSelect += " INNER JOIN " + RetSqlName("FRV") + " FRV "
    cSelect += " ON FRV_CODIGO = E1_SITUACA "

    cSelect += " WHERE "

    If Len(aFilter) > 0
        For nY := 1 To Len(aFilter)
            If SubStr(aFilter[nY][1], 2, 10) != "E1_VENCREA"
                cSelect += aFilter[nY][1] + " AND "
            Endif
        Next nY
    Endif

    cSelect += " SE1.D_E_L_E_T_ = ' ' "
    cSelect += " AND SE1.E1_NATUREZ = '" + cNatur + "' "
    cSelect += " AND SE1.E1_VENCREA >= '" + cDataIni + "' "
    cSelect += " AND SE1.E1_VENCREA <= '" + cDataFim + "' "
Else
    cSelect := " SELECT E2_PREFIXO AS E2_PREFIXO, E2_NUM AS E2_NUM, E2_PARCELA AS E2_PARCELA, E2_TIPO AS E2_TIPO, E2_NATUREZ AS NATUREZ, E2_MOEDA AS MOEDA,
    cSelect += " E2_NOMFOR AS E2_NOMFOR, E2_EMISSAO AS E2_EMISSAO, E2_VENCREA AS E2_VENCREA, E2_VENCTO AS E2_VENCTO, E2_VALOR AS TOTAL,
    cSelect += " E2_SALDO AS SALDO, ('Despesa') AS ORIGEM, "
    cSelect += " E2_FORNECE AS CODIGO, E2_LOJA AS LOJA, "
    cSelect += " CASE "

    If lInfoOrac
        cSelect += " WHEN (E2_VENCREA <  SYSDATE AND E2_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E2_VENCREA >= SYSDATE AND E2_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E2_VENCREA <  SYSDATE AND E2_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E2_VENCREA >= SYSDATE AND E2_SALDO = 0) THEN 'BAIXADO' "
    ElseIf lPostGre
        cSelect += " WHEN (E2_VENCREA <  '" + cDate + "' AND E2_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E2_VENCREA >= '" + cDate + "' AND E2_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E2_VENCREA <  '" + cDate + "' AND E2_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E2_VENCREA >= '" + cDate + "' AND E2_SALDO = 0) THEN 'BAIXADO' "
    Else
        cSelect += " WHEN (E2_VENCREA <  GETDATE() AND E2_SALDO > 0) THEN 'VENCIDO' "
        cSelect += " WHEN (E2_VENCREA >= GETDATE() AND E2_SALDO > 0) THEN 'A VENCER' "
        cSelect += " WHEN (E2_VENCREA <  GETDATE() AND E2_SALDO = 0) THEN 'BAIXADO' "
        cSelect += " WHEN (E2_VENCREA >= GETDATE() AND E2_SALDO = 0) THEN 'BAIXADO' "
    Endif

    cSelect += " END AS STATUS "

    cSelect += " FROM " + RetSqlName("SE2") + " SE2 "

    cSelect += " WHERE "

    If Len(aFilter) > 0
        For nY := 1 To Len(aFilter)
            If !(SubStr(aFilter[nY][1], 2, 10) = "E2_VENCREA") .And. SubStr(aFilter[nY][1], 2, 10) != "E1_VENCREA"
                cSelect += aFilter[nY][1] + " AND "
            Endif
        Next nY
    Endif

    cSelect += " SE2.D_E_L_E_T_ = ' ' "
    cSelect += " AND SE2.E2_NATUREZ = '" + cNatur + "'
    cSelect += " AND SE2.E2_VENCREA >= '" + cDataIni + "' "
    cSelect += " AND SE2.E2_VENCREA <= '" + cDataFim + "' "

    cSelect += " AND NOT EXISTS (SELECT FI8_FILIAL "
    cSelect += " FROM "  + RetSqlName("FI8") + " FI8 "
    cSelect += " WHERE "
    cSelect += " FI8_FILIAL = E2_FILIAL  AND "
    cSelect += " FI8_PRFORI = E2_PREFIXO AND "
    cSelect += " FI8_NUMORI = E2_NUM     AND "
    cSelect += " FI8_PARORI = E2_PARCELA AND "
    cSelect += " FI8_TIPORI = E2_TIPO    AND "
    cSelect += " FI8_FORORI = E2_FORNECE AND "
    cSelect += " FI8_LOJORI = E2_LOJA AND "
    cSelect += " D_E_L_E_T_ = ' ' ) "
Endif

cSelect := ChangeQuery(cSelect)

MPSysOpenQuery( cSelect, cAlsTMP )

If oDashTMP <> Nil
	oDashTMP:Delete()
	oDashTMP := Nil
Endif

aEstruct := FD100LStru( , cAlsAux := Iif(cOrigem = "CR", "SE1", "SE2"))

oDashTMP := FWTemporaryTable():New( cAliasTab )
oDashTMP:SetFields(aEstruct)

If cAlsAux = "SE1"
    oDashTMP:AddIndex("1", {"E1_PREFIXO", "E1_NUM", "E1_PARCELA"})
Else
    oDashTMP:AddIndex("1", {"E2_PREFIXO", "E2_NUM", "E2_PARCELA"})
Endif

oDashTMP:Create()

(cAlsTMP)->(DbGoTop())

While !(cAlsTMP)->(EOF())
    nCountTmp++
    cSimbMoed := DescMoeda((cAlsTMP)->MOEDA)
    (cAliasTab)->(RecLock(cAliasTab, .T.))
        If cAlsAux = "SE1"
            (cAliasTab)->E1_PREFIXO := (cAlsTMP)->E1_PREFIXO
            (cAliasTab)->E1_NUM     := (cAlsTMP)->E1_NUM
            (cAliasTab)->E1_PARCELA := (cAlsTMP)->E1_PARCELA
            (cAliasTab)->E1_TIPO    := (cAlsTMP)->E1_TIPO
            (cAliasTab)->E1_NOMCLI  := (cAlsTMP)->E1_NOMCLI
            (cAliasTab)->E1_EMISSAO := (cAlsTMP)->E1_EMISSAO
            (cAliasTab)->E1_VENCTO  := (cAlsTMP)->E1_VENCTO
            (cAliasTab)->E1_VENCREA := (cAlsTMP)->E1_VENCREA
        Else
            (cAliasTab)->E2_PREFIXO := (cAlsTMP)->E2_PREFIXO
            (cAliasTab)->E2_NUM     := (cAlsTMP)->E2_NUM
            (cAliasTab)->E2_PARCELA := (cAlsTMP)->E2_PARCELA
            (cAliasTab)->E2_TIPO    := (cAlsTMP)->E2_TIPO
            (cAliasTab)->E2_NOMFOR  := (cAlsTMP)->E2_NOMFOR
            (cAliasTab)->E2_EMISSAO := (cAlsTMP)->E2_EMISSAO
            (cAliasTab)->E2_VENCTO  := (cAlsTMP)->E2_VENCTO
            (cAliasTab)->E2_VENCREA := (cAlsTMP)->E2_VENCREA
        Endif

        (cAliasTab)->NATUREZ    := (cAlsTMP)->NATUREZ
        (cAliasTab)->CODIGO     := (cAlsTMP)->CODIGO
        (cAliasTab)->LOJA       := (cAlsTMP)->LOJA
        (cAliasTab)->TOTAL      := cSimbMoed + " " + Alltrim(Transform((cAlsTMP)->TOTAL, "@E 999,999,999,999.99"))
        (cAliasTab)->SALDO      := cSimbMoed + " " + Alltrim(Transform((cAlsTMP)->SALDO, "@E 999,999,999,999.99"))
        (cAliasTab)->SITUACAO   := Iif(cAlsAux = "SE1", (cAlsTMP)->SITUACAO, "")
        (cAliasTab)->MOEDA      := (cAlsTMP)->MOEDA
        (cAliasTab)->ORIGEM     := (cAlsTMP)->ORIGEM
        (cAliasTab)->STATUS     := (cAlsTMP)->STATUS
    (cAliasTab)->(MsUnLock())

    (cAlsTMP)->(DBSkip())

    If nPosPage = 0
        If nCountTmp == 30
            Exit
        Endif
    ElseIf nCountTmp == ((nPosPage * nPageSize) + 10)
        Exit
    Endif

Enddo

(cAliasTab)->(DbGoTop())

Return cAliasTab

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LCard
Monta query com retorno dos titulos a pagar e a receber

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LCard(dDataIni As Character, dDataFim As Character, cTpSaldo As Character, aFilter AS Array, lOrderBy As Logical) AS Array

Local cWhere   As Character
Local cGroup   As Character
Local cSelect  As Character
Local cNameCpo As Character
Local nY       AS Numeric

Default dDataIni := ""
Default dDataFim := ""
Default cTpSaldo := ""
Default aFilter  := {}
Default lOrderBy := .T.

cWhere   := ""
cGroup   := ""
cSelect  := ""
cNameCpo := Iif(cTpSaldo = "2", "PREVISTO", "REALIZADO")
nY       := 0

cSelect := " SELECT SED.ED_PAI, SED.ED_CODIGO, SED.ED_DESCRIC, SUM(FIW.FIW_VALOR) AS " + cNameCpo + ", SED.ED_CONTA, SED.ED_DEBITO, "
cSelect += " SED.ED_CCD, SED.ED_ITEMD, SED.ED_CLVLDB, SED.ED_CREDIT, SED.ED_CCC, SED.ED_ITEMC, SED.ED_CLVLCR, "
cSelect += " CASE "
cSelect += " WHEN FIW.FIW_CARTEI = 'R' THEN 'Receita' "
cSelect += " WHEN FIW.FIW_CARTEI = 'P' THEN 'Despesa' "
cSelect += " END AS MOVIMENTO "
cSelect += " FROM "       + RetSqlName("SED") + " SED "
cSelect += " INNER JOIN " + RetSqlName("FIW") + " FIW "
cSelect += " ON SED.ED_CODIGO = FIW.FIW_NATUR "
cSelect += " WHERE "

If Len(aFilter) > 0
    For nY := 1 To Len(aFilter)
        If SubStr(aFilter[nY][1], 2, 13) = "SED.ED_CODIGO"
            cSelect +=  aFilter[nY][1] + " AND "
        Endif
    Next nY
Endif

cSelect += " SED.D_E_L_E_T_ = ' ' "
cSelect += " AND SED.ED_FILIAL   = '"  + xFilial("SED") + "' "
cSelect += " AND SED.ED_COND IN ( 'D', 'R' ) "
cSelect += " AND FIW.D_E_L_E_T_ = ' ' "
cSelect += " AND FIW.FIW_FILIAL   = '"  + xFilial("FIW") + "' "
cSelect += " AND FIW.FIW_CARTEI IN ( 'P', 'R' ) "
cSelect += " AND FIW.FIW_DATA  >= '" + dDataIni + "' "
cSelect += " AND FIW.FIW_DATA  <= '" + dDataFim + "' "
cSelect += " AND FIW.FIW_TPSALD = '" + cTpSaldo + "' "
cSelect += " GROUP  BY ED_PAI, ED_CODIGO, ED_DESCRIC, ED_CONTA, ED_DEBITO, ED_CCD, ED_ITEMD, ED_CLVLDB, ED_CREDIT, ED_CCC, ED_ITEMC, ED_CLVLCR, ED_COND, FIW_CARTEI

If lOrderBy
  cSelect += " ORDER BY ED_PAI, ED_CODIGO
Endif

Return {cSelect, cWhere, cGroup}

//-------------------------------------------------------------------
/*/{Protheus.doc} FD100LTpSl
Monta query com retorno dos titulos a pagar e a receber

@author		francisco.oliveira
@since		09/11/2020
@version Protheus 12
/*/
//-------------------------------------------------------------------

Function FD100LTpSl(aTpSaldo As Character) As Character

Local ctpSaldo  As Character
Local nY        AS Numeric

Default aTpSaldo := {}

ctpSaldo    := ""
nY          := 0

If Len(aTpSaldo) > 1
    For nY := 1 To Len(aTpSaldo)
        ctpSaldo  += "'" + subStr(aTpSaldo[nY],1,1) + "'"
        If nY < Len(aTpSaldo)
            ctpSaldo  += ','
        Endif
    Next nY
ElseIf Len(aTpSaldo) == 1
    ctpSaldo  := subStr(aTpSaldo[1],1,1)
    If ctpSaldo = "0"
        ctpSaldo := "'1','2','3'"
    Else
        ctpSaldo := " '" + ctpSaldo + "' "
    Endif
Endif

Return ctpSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} DescMoeda
Função que retorna o simbolo da moeda conforme parametros MV_SIMB

@author Vitor Duca
@since 25/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DescMoeda( nMoeda As Numeric ) As Character
	Local cDescMoe As Character

	cDescMoe := ''

	If nMoeda > 0
		cDescMoe := SuperGetMv( "MV_SIMB" + AllTrim( Str( nMoeda, 2 ) ) )
	EndIf

Return cDescMoe


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
