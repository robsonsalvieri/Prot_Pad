#Include 'Protheus.ch'
#Include 'TopConn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "TBICONN.CH"

#Define Moeda "@E 9,999,999,999,999.99"

STATIC oFnt10C 		:= TFont():New("Arial",12,12,,.f., , , , .t., .f.)
STATIC oFnt10N 		:= TFont():New("Arial",12,12,,.T., , , , .t., .f.)
STATIC oFnt12L 		:= TFont():New("Arial",09,09,,.F., , , , .t., .f.)
STATIC oFnt12N 		:= TFont():New("Arial",14,14,,.T., , , , .t., .f.)
STATIC oFnt14N		:= TFont():New("Arial",18,18,,.t., , , , .t., .f.)
STATIC oFnt10L      := TFont():New("MS LineDraw Regular",10,10,,.F., , , , .t., .f.)
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENRCRDEOP

Relatório do Quadro Agrupamento de Contratos

@author José Paulo
@since 22/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CENRCRDEOP(lTodosQuadros,lAuto,lImpPg)

    Local aSays           := {}
    Local aButtons        := {}
    Local cCadastro       :=  "                                              Capital Baseado em Riscos - Risco de Crédito - Parcela 1"//"Créditos e Débitos com Operadoras p/ Apuração do Capital Referente ao Risco de Crédito (Parcela 1.1)"
    Local aResult         := {}
    Local cDesc1          := FunDesc()
    Local cDesc2          := ""
    Local cDesc3          := ""
    Local cAlias          := "B6X"
    Local cPerg           := "DIOPSIMPRE"
    Local cRel            := "CENRCRDEOP"
    Local aOrdens         := { "Operadora+Obrigação+Ano+Código Compromisso+Referência", "Operadora+Obrigação+Ano+Código Compromisso+Referência" }
    Local lDicion         := .F.
    Local lCompres        := .F.
    Local lCrystal        := .F.
    Local lFiltro         := .T.
    Default lTodosQuadros := .F.
    Default lAuto         := .F.
    Default lImpPg        :=.F.
    If !lTodosQuadros

        Private cPerg     := "DIOPSIMPRE"
        Private cTitulo   := cCadastro
        Private oReport   := nil
        Private cRelName := "DIOPS_Cred_Deb_Operadora_"+CriaTrab(NIL,.F.)
        Private nPagina   := 0		// Já declarada PRIVATE na chamada de todos os quadros
        Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }

        oReport := FWMSPrinter():New(cRelName,IMP_PDF,.F.,nil,.T.,nil,@oReport,nil,lAuto,.F.,.F.,!lAuto)
        oReport:setDevice(IMP_PDF)
        oReport:setResolution(72)
        oReport:SetLandscape(.T.)
        oReport:SetPaperSize(9)
        oReport:setMargin(10,10,10,10)

        cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,,{},lFiltro,lCrystal)

        IIf (!lAuto,Pergunte(cPerg,.F.),"")

        If lAuto
            If lImpPg
                mv_par01:=1
            Else
                mv_par01:=2
            Endif
        Endif

        If lAuto
            oReport:CFILENAME  := cRelName
            oReport:CFILEPRINT := oReport:CPATHPRINT + oReport:CFILENAME
        Else
            oReport:Setup()  //Tela de configurações
			If oReport:nModalResult == 2 //Verifica se foi Cancelada a Impressão
				Return ()
			EndIf

        EndIf
    EndIf

    Processa( {|| aResult := CENCRDEOP() }, cCadastro)

    // Se não há dados a apresentar
    If !aResult[1]
        IIf (!lAuto,MsgAlert('Não há dados a apresentar referente a Agrupamento de Contratos'),conout('Não há dados a apresentar referente a Agrupamento de Contratos'))
        Return
    EndIf

    lRet := PRINTCDOP(aResult[2]) //Recebe Resultado da Query e Monta Relatório

    If !lTodosQuadros .and. lRet
        oReport:EndPage()
        oReport:Print()
    EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} PRINTAGCIN
@description Imprime Agrupamento de Contratos
@author José Paulo
@since 01/04/201
/*/
//------------------------------------------------------------------
Static Function PRINTCDOP(aValores)

    Local lRet		:= .T.
    Local nSom		:= 0
    Local nI		:= 0
    Local nTotReg   := Len(aValores)
    Local nPagina   := 0
    Local aAuxVal   := {}
    Local nj        := 0
    Local lImCaPg   :=.F.

    If Valtype(MV_PAR01)=="N" .And. MV_PAR01==1
        lImCaPg:=.T.
    Endif

    If lImCaPg
        ImComDet(aValores)

    Else
        PriDsQdo()

        nOp:=405
        nLin := 100
        nSom := 100

        If nTotReg > 4 .And. nPagina <= 1
            nTotReg := 4
        EndIf
        //imprime os nomes Operadora..1..2..3...etc. E OS VALORES
        For nI:=1 to nTotReg
            If nTotReg > 2
                nOp += 2
            EndIf
            oReport:Say(115, nOp , "Operadora "+cValtoChar(nI)+"", oFnt10N)
            nOp+=100
        Next nI

        //imprime os VALORES
        nOp:=390
        nCompl:=0
        For nI:=1 to Len(aValores)
            If nI > 2
                nOp +=10
            Endif
            oReport:Say(140, nOp+30 , cValToChar(aValores[nI,1])    , oFnt10L)                          //Campo 1
            oReport:Say(180, nOp   , PadL(Transform(aValores[nI,2] ,Moeda),20), oFnt10L)              //Campo 2
            oReport:Say(214, nOp   , PadL(Transform(aValores[nI,3] ,Moeda),20), oFnt10L)              //Campo 3
            oReport:Say(255, nOp   , PadL(Transform(aValores[nI,4] ,Moeda),20), oFnt10L)              //Campo 4
            oReport:Say(310, nOp   , PadL(Transform(aValores[nI,5] ,Moeda),20), oFnt10L)              //Campo 5
            oReport:Say(367, nOp   , PadL(Transform(aValores[nI,6] ,Moeda),20), oFnt10L)              //Campo 6
            oReport:Say(430, nOp   , PadL(Transform(aValores[nI,7] ,Moeda),20), oFnt10L)              //Campo 7
            oReport:Say(475, nOp   , PadL(Transform(aValores[nI,8] ,Moeda),20), oFnt10L)              //Campo 8
            oReport:Say(525, nOp   , PadL(Transform(aValores[nI,9] ,Moeda),20), oFnt10L)              //Campo 9
            oReport:Say(575, nOp   , PadL(Transform(aValores[nI,10],Moeda),20), oFnt10L)              //Campo 10
            nOp+=100
            If nTotReg == nI
                exit
            EndIf
        Next nI
        nTotReg:= nTotReg + 3
        //Controla colunas
        For nI := 1 to 5
            If nSom <= 801
                oReport:Line(nLin, nSom, nLin+495, nSom)
                If nSom==100
                    nSom += 280
                elseIf nSom >= 280
                    nSom +=106
                EndIf
            EndIf
        Next nI
    Endif

    If Len(aValores) > 4 .And. !lImCaPg

        For nI := 5 TO Len(aValores)
            AADD(aAuxVal,aValores[nI])
        Next nI

        aValores:=AClone(aAuxVal)

        PriDsQdo1(aValores)

    EndIf
Return lRet

Static Function CENCRDEOP()
    Local nCount   := 0
    Local aRetCdOp := {}
    Local cSql 	   := ""

    cSql := " SELECT B6X_OPECRD,B6X_VLRCOS,B6X_VLRIAR,B6X_VLROCO,B6X_VLRPPS,B6X_VLROCP,B6X_VLRPPC,B6X_VLRDOA,B6X_VLRPES,B6X_VLRODN "
    cSql += " FROM " + RetSqlName("B6X")
    cSql += " WHERE B6X_FILIAL = '" + xFilial("B6X") + "' "
    cSql += " AND B6X_CODOPE = '" + B3D->B3D_CODOPE + "' "
    cSql += " AND B6X_CODOBR = '" + B3D->B3D_CDOBRI + "' "
    cSql += " AND B6X_ANOCMP = '" + B3D->B3D_ANO + "' "
    cSql += " AND B6X_CDCOMP = '" + B3D->B3D_CODIGO + "' "
    cSql += " AND D_E_L_E_T_ = ' ' "
    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCDO",.F.,.T.)

    If !TRBCDO->(Eof())
        Do While !TRBCDO->(Eof())
            AADD(aRetCdOp,{TRBCDO->B6X_OPECRD,TRBCDO->B6X_VLRCOS,TRBCDO->B6X_VLRIAR,TRBCDO->B6X_VLROCO,TRBCDO->B6X_VLRPPS,TRBCDO->B6X_VLROCP,TRBCDO->B6X_VLRPPC,TRBCDO->B6X_VLRDOA,;
                TRBCDO->B6X_VLRPES,TRBCDO->B6X_VLRODN})
            nCount++
            TRBCDO->(DbSkip())
        EndDo
    EndIf
    TRBCDO->(DbCloseArea())

Return( { nCount > 0 , aRetCdOp } )

Function PriDsQdo()
    Local cTitulo	:= "                                              Capital Baseado em Riscos - Risco de Crédito - Parcela 1"//"Créditos e Débitos com Operadoras p/ Apuração do Capital Referente ao Risco de Crédito (Parcela 1.1)"
    Local nLinha	:= 100

    PlsRDCab(cTitulo,160)

    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25
    oReport:Say(nLinha-10, 023 , "Código Campo", oFnt10N)
    oReport:Say(nLinha-10, 180 , "Descrição", oFnt10N)

    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25

    oReport:Say(nLinha-10, 032 , "Campo1", oFnt10N)
    oReport:Say(nLinha-10, 110 , "Código de registro da Operadora Credora/Devedora na ANS", oFnt12L)
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=25

    oReport:Say(nLinha-2, 032 , "Campo2", oFnt10N)
    oReport:Say(nLinha-7 , 110 , "Créditos de operações de assistência à saúde com outras operadoras", oFnt12L)
    oReport:Say(nLinha+6, 110 , "(incluindo Contraprestação Corresponsabilidade Assumida, Cosseguro", oFnt12L)
    oReport:Say(nLinha+19, 110 , "Aceito e Outros Créditos Operacionais)", oFnt12L)
    nLinha+=25

    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=15
    oReport:Say(nLinha, 032 , "Campo3", oFnt10N)
    oReport:Say(nLinha, 110 , "Intercâmbio a Receber - Atendimento Eventual", oFnt12L)

    nLinha+=10
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=15
    oReport:Say(nLinha+8, 032 , "Campo4", oFnt10N)
    oReport:Say(nLinha, 110 , "Outros Créditos de Operações de Assistência Médico-Hospitalar ", oFnt12L)
    oReport:Say(nLinha+13, 110 , "Créditos em Programas ou Fundos para Custeio de Despesas de", oFnt12L)
    oReport:Say(nLinha+26, 110 , "Assistência Médico-Hospitalar", oFnt12L)

    nLinha+=35
    oReport:box(nLinha, 020, nLinha+70, 805)
    nLinha+=15
    oReport:Say(nLinha+12, 032 , "Campo5", oFnt10N)
    oReport:Say(nLinha, 110 , "(-) Provisão para Perdas Sobre Créditos - Outros Créditos de Operações de", oFnt12L)
    oReport:Say(nLinha+13, 110 , "Assistência Médico-Hospitalar - Créditos em Programas ou Fundos para", oFnt12L)
    oReport:Say(nLinha+26, 110 , "Custeio de Despesas de Assistência Médico-Hospitalar. ", oFnt12L)
    //oReport:Say(nLinha+39, 110 , "Odontológica.", oFnt12L)

    nLinha+=50
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=15
    oReport:Say(nLinha+12, 032 , "Campo6", oFnt10N)
    oReport:Say(nLinha, 110 , "Outros Créditos Operacionais de Prestação de Serviço Médico-Hospitalar - Créditos", oFnt12L)
    oReport:Say(nLinha+13, 110 , "com Administração de Programas ou Fundos de Custeio de Despesas ", oFnt12L)
    oReport:Say(nLinha+26, 110 , "Médico-Hospitalar", oFnt12L)

    nLinha+=35
    oReport:box(nLinha, 020, nLinha+70, 805)
    nLinha+=15
    oReport:Say(nLinha+12, 032 , "Campo7", oFnt10N)
    oReport:Say(nLinha, 110 , "(-) Provisão para Perdas Sobre Créditos - Outros Créditos Operacionais de", oFnt12L)
    oReport:Say(nLinha+13, 110 , "Prestação de Serviço Médico-Hospitalar - Créditos com Administração de", oFnt12L)
    oReport:Say(nLinha+26, 110 , "Programas ou Fundos de Custeio de Despesas Médico-Hospitalar", oFnt12L)
    //oReport:Say(nLinha+39, 110 , "Médico-Hospitalar", oFnt12L)

    nLinha+=50
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=15
    oReport:Say(nLinha+8, 032 , "Campo8", oFnt10N)
    oReport:Say(nLinha, 110 , "Débitos de operações de assistência à saúde (incluindo Intercâmbio a Pagar", oFnt12L)
    oReport:Say(nLinha+13, 110 , "de Corresponsabilidade Cedida e Cosseguro Cedido / Aceito)", oFnt12L)

    nLinha+=30
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=15
    oReport:Say(nLinha+8, 032 , "Campo9", oFnt10N)
    oReport:Say(nLinha, 110 , "Provisão de Eventos/Sinistros a Liquidar para Outros Prestadores", oFnt12L)
    oReport:Say(nLinha+13, 110 , "de Serviços Assistenciais relativas a eventos com Intercâmbio", oFnt12L)

    nLinha+=30
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=15
    oReport:Say(nLinha+12, 032 , "Campo10", oFnt10N)
    oReport:Say(nLinha, 110 , "Outros Débitos não Relacionados com Planos de Saúde da Operadora - Débitos", oFnt12L)
    oReport:Say(nLinha+13, 110 , "com Administração de Programas ou Fundos de Custeio de Despesas de", oFnt12L)
    oReport:Say(nLinha+26, 110 , "Assistência à Saúde", oFnt12L)

Return

Function PriDsQdo1(aValores)
    Local nOp       := 0
    Local nSay      := 115
    Local nI        := 0

    //imprime os VALORES
    nOp:=030
    nSay:=140
    nCol:= 0

    For nI:=1 to Len(aValores)
        If StrZero(nI,3) $ "001/008/015/022/029/036/043/050/057/064/071/078/085/092/099/106/113/120/127/134/141/148/155/162/169/176/183/190"
            oReport:EndPage()
            EscrLay(nI)
            EscrOpe(nI,aValores)
            //oReport:EndPage()
            nCol:=0
        Endif

        oReport:Say(nSay, nOp+25+nCol , cValToChar(aValores[nI,1])   , oFnt10L)                        //Campo 1
        nSay+=40
        oReport:Say(nSay, nOp+nCol , PadL(Transform(aValores[nI,2]   ,Moeda),20), oFnt10L)              //Campo 2
        nSay+=40
        oReport:Say(nSay-3, nOp+nCol , PadL(Transform(aValores[nI,3] ,Moeda),20), oFnt10L)              //Campo 3
        nSay+=40
        oReport:Say(nSay-6, nOp+nCol , PadL(Transform(aValores[nI,4] ,Moeda),20), oFnt10L)              //Campo 4
        nSay+=40
        oReport:Say(nSay+8, nOp+nCol , PadL(Transform(aValores[nI,5] ,Moeda),20), oFnt10L)              //Campo 5
        nSay+=40
        oReport:Say(nSay+26, nOp+nCol , PadL(Transform(aValores[nI,6],Moeda),20), oFnt10L)              //Campo 6
        nSay+=40
        oReport:Say(nSay+42, nOp+nCol , PadL(Transform(aValores[nI,7],Moeda),20), oFnt10L)              //Campo 7
        nSay+=60
        oReport:Say(nSay+42, nOp+nCol , PadL(Transform(aValores[nI,8],Moeda),20), oFnt10L)              //Campo 8
        nSay+=50
        oReport:Say(nSay+38, nOp+nCol , PadL(Transform(aValores[nI,9],Moeda),20), oFnt10L)              //Campo 9
        nSay+=50
        oReport:Say(nSay+35, nOp+nCol, PadL(Transform(aValores[nI,10],Moeda),20), oFnt10L)              //Campo 10
        nSay:=140
        nCol+=113

    Next nI

Return

Function EscrLay()
    Local nSom		:= 0
    Local nI		:= 0
    Local cTitulo	:= "                                              Capital Baseado em Riscos - Risco de Crédito - Parcela 1"//"Créditos e Débitos com Operadoras p/ Apuração do Capital Referente ao Risco de Crédito (Parcela 1.1)"
    Local nLinha	:= 100

    PlsRDCab(cTitulo,160)
    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25
    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=50
    oReport:box(nLinha, 020, nLinha+25, 805)
    nLinha+=25
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=50
    oReport:box(nLinha, 020, nLinha+70, 805)
    nLinha+=65
    oReport:box(nLinha, 020, nLinha+55, 805)
    nLinha+=50
    oReport:box(nLinha, 020, nLinha+70, 805)
    nLinha+=65
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=45
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=45
    oReport:box(nLinha, 020, nLinha+50, 805)
    nLinha+=15

    nSom:=130
    nLin:=100
    For nI := 1 to 6
        If nSom >= 0
            oReport:Line(nLin, nSom, nLin+495, nSom)
            nSom+=112
        EndIf
    Next nI

return

function EscrOpe(nDe,aValores)
    Local nSay1      := 115
    Local nOp1       := 045
    Local nC         := 0
    Local nTo        := 0
    Local nCont      := 0
    Local nTotVal    := Len(aValores)
    Default nDe      := 1

    nTo:= nDe + 6

    For nC:=nDe to nTo
        oReport:Say(nSay1, nOp1 , "Operadora "+cValtoChar(nC+4)+"", oFnt10N)
        nCont++
        If nCont <= 2
            nOp1+=115
        elseIf nCont <= 3
            nOp1+=110
        elseIf nCont <= 4
            nOp1+=108
        elseIf nCont <= 5
            nOp1+=110
        elseIf nCont <= 6
            nOp1+=110
        Endif

        If nC == nTotVal
            exit
        EndIf
    Next nC

Return

Function ImComDet(aValores)
    Local nSom		:= 0
    Local nI		:= 0
    Local nj        := 0
    Local nOp       :=390
    Local cNumero   :=""
    Local nH        := 0
    Local nY        := 0
    Local cNum      := ""

    PriDsQdo()

    nOpera:=407

    For nH:=1 to Len(aValores) step 4
        If nH > 1
            cNumero+="/"+cValtoChar(strzero(nH,3))+""
        Endif
    next

    For nY:=3 to Len(aValores) step 4
        cNum+="/"+cValtoChar(strzero(nY,3))+""
        cNum+="/"+cValtoChar(strzero(nY+1,3))+""
    next

    For nJ:=1 To Len(aValores)

        If strzero(nJ,3) $ cNumero
            oReport:EndPage()
            PriDsQdo()
            nCol:=0
            nOp:=390
            nOpera:=407
        Endif

        If strzero(nJ,3) $ cNum
            If nJ <> 1
                nOp+=10
                nOpera+=10
            Endif
        Endif

        //imprime os nomes Operadora..1..2..3...etc. E OS VALORES
        oReport:Say(115, nOpera , "Operadora "+cValtoChar(nJ)+"", oFnt10N)
        nOpera+=100

        //imprime os VALORES
        oReport:Say(140, nOp+30, cValToChar(aValores[nj,1])    , oFnt10L)                          //Campo 1
        oReport:Say(180, nOp   , PadL(Transform(aValores[nJ,2] ,Moeda),20), oFnt10L)              //Campo 2
        oReport:Say(214, nOp   , PadL(Transform(aValores[nJ,3] ,Moeda),20), oFnt10L)              //Campo 3
        oReport:Say(255, nOp   , PadL(Transform(aValores[nJ,4] ,Moeda),20), oFnt10L)              //Campo 4
        oReport:Say(310, nOp   , PadL(Transform(aValores[nJ,5] ,Moeda),20), oFnt10L)              //Campo 5
        oReport:Say(367, nOp   , PadL(Transform(aValores[nJ,6] ,Moeda),20), oFnt10L)              //Campo 6
        oReport:Say(430, nOp   , PadL(Transform(aValores[nJ,7] ,Moeda),20), oFnt10L)              //Campo 7
        oReport:Say(475, nOp   , PadL(Transform(aValores[nJ,8] ,Moeda),20), oFnt10L)              //Campo 8
        oReport:Say(525, nOp   , PadL(Transform(aValores[nJ,9] ,Moeda),20), oFnt10L)              //Campo 9
        oReport:Say(575, nOp   , PadL(Transform(aValores[nJ,10],Moeda),20), oFnt10L)              //Campo 10
        nOp+=100

        nLinFor := 100
        nSomFor := 100

        For nI := 1 to 5
            If nSomFor <= 801
                oReport:Line(nLinFor, nSomFor, nLinFor+495, nSomFor)
                If nSomFor==100
                    nSomFor += 280
                elseIf nSomFor >= 280
                    nSomFor +=106
                EndIf
            EndIf
        Next nI

    next nI

Return
