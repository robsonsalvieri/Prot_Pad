#Include 'totvs.ch'

Function CENVLCDO01()
    Local lRetorno	:= .F.

    lRetorno	:= LEN(ALLTRIM(B6X->B6X_OPECRD))==6

Return lRetorno

Function CENVLCDO02()
    Local lRetorno	:= .F.
    Local aContas	:= {'1234'}

    lRetorno	:= CENQRYBAL(aContas,2)

Return lRetorno

Function CENVLCDO03()
    Local lRetorno	:= .F.
    Local aContas	:= {'12411902','12412902'}

    lRetorno	:= CENQRYBAL(aContas,3)

Return lRetorno

Function CENVLCDO04()
    Local lRetorno	:= .F.
    Local aContas	:= {'123911082','123912082','123921082','123922082'}

    lRetorno	:= CENQRYBAL(aContas,4)

Return lRetorno

Function CENVLCDO05()
    Local lRetorno	:= .F.
    Local aContas	:= {'123911089','123912089','123921089','123922089'}

    lRetorno	:= CENQRYBAL(aContas,5)

Return lRetorno

Function CENVLCDO06()
    Local lRetorno	:= .F.
    Local aContas	:= {'124119082','124129082'}

    lRetorno	:= CENQRYBAL(aContas,6)

Return lRetorno

Function CENVLCDO07()
    Local lRetorno	:= .F.
    Local aContas	:= {'124119089','124129089'}

    lRetorno	:= CENQRYBAL(aContas,7)

Return lRetorno

Function CENVLCDO08()
    Local lRetorno	:= .F.
    Local aContas	:= {'2135'}

    lRetorno	:= CENQRYBAL(aContas,8)

Return lRetorno

Function CENVLCDO09()
    Local lRetorno	:= .F.
    Local aContas	:= {'211111033','211112033','211121033','211122033','231111033','231112033','231121033','231122033'}

    lRetorno	:= CENQRYBAL(aContas,9)

Return lRetorno

Function CENVLCDO10()
    Local lRetorno	:= .F.
    Local aContas	:= {'214889082'}

    lRetorno	:= CENQRYBAL(aContas,10)

Return lRetorno

Static Function CENQRYBAL(aConta,nCp)
    Local lRet      := .T.
    Local cSql 	    := ""
    Local cCodOpe   := ""
    Local cCodObr   := ""
    Local cAnoCmp   := ""
    Local cCdComp   := ""
    Local cConta    := ""
    Local nSldCob	:= 0
    Local nVez	    := 0
    Local nLen	    := 0
    Local nAlia1	:= GetNextAlias()
    Local nAlia2	:= GetNextAlias()
    Default nCp     := 0
    Default aConta	:= {}

    lRet := !Empty(aConta)
    If lRet
        nLen := Len(aConta)
        cCodOpe := AllTrim(B3D->B3D_CODOPE)
        cCodObr := AllTrim(B3D->B3D_CDOBRI)
        cAnoCmp := AllTrim(B3D->B3D_ANO)
        cCdComp := AllTrim(B3D->B3D_CODIGO)

        cSql := " SELECT SUM(B6X_VLRCOS) CAMPO02,"
        cSql += "        SUM(B6X_VLRIAR) CAMPO03,"
        cSql += "        SUM(B6X_VLROCO) CAMPO04,"
        cSql += "        SUM(B6X_VLRPPS) CAMPO05,"
        cSql += "        SUM(B6X_VLROCP) CAMPO06, "
        cSql += "        SUM(B6X_VLRPPC) CAMPO07, "
        cSql += "        SUM(B6X_VLRDOA) CAMPO08, "
        cSql += "        SUM(B6X_VLRPES) CAMPO09, "
        cSql += "        SUM(B6X_VLRODN) CAMPO10 "
        cSql += "	FROM " + RetSqlName("B6X")
        cSql += "	WHERE B6X_FILIAL = '" + xFilial("B6X") + "' "
        cSql += "			AND B6X_CODOPE = '" + cCodOpe + "' "
        cSql += "			AND B6X_CODOBR = '" + cCodObr + "' "
        cSql += "			AND B6X_ANOCMP = '" + cAnoCmp + "' "
        cSql += "			AND B6X_CDCOMP = '" + cCdComp + "' "
        cSql += " 			AND D_E_L_E_T_ = ' ' "

        cSql := ChangeQuery(cSql)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nAlia1,.F.,.T.)

        If !(nAlia1)->(Eof())
            If nCp == 2
                nSldCob	:= (nAlia1)->( CAMPO02 )
            ElseIf nCp == 3
                nSldCob	:= (nAlia1)->( CAMPO03 )
            ElseIf nCp == 4
                nSldCob	:= (nAlia1)->( CAMPO04 )
            ElseIf nCp == 5
                nSldCob	:= (nAlia1)->( CAMPO05 )
            ElseIf nCp == 6
                nSldCob	:= (nAlia1)->( CAMPO06 )
            ElseIf nCp == 7
                nSldCob	:= (nAlia1)->( CAMPO07 )
            ElseIf nCp == 8
                nSldCob	:= (nAlia1)->( CAMPO08 )
            ElseIf nCp == 9
                nSldCob	:= (nAlia1)->( CAMPO09 )
            ElseIf nCp == 10
                nSldCob	:= (nAlia1)->( CAMPO10 )
            Endif

            For nVez := 1 to nLen
                cConta += aConta[nVez]+IIf(nVez<>nLen,',','')
            Next
            cConta := FormatIn(cConta,",")

            cSql := " SELECT SUM(B8A_SALFIN) AS VALCTB "
            cSql += "	FROM " + RetSqlName("B8A")
            cSql += "	WHERE B8A_FILIAL = '" + xFilial("B8A") + "' "
            cSql += "			AND B8A_CODOPE = '" + cCodOpe + "' "
            cSql += "			AND B8A_CODOBR = '" + cCodObr + "' "
            cSql += "			AND B8A_ANOCMP = '" + cAnoCmp + "' "
            cSql += "			AND B8A_CDCOMP = '" + cCdComp + "' "
            cSql += "			AND B8A_CONTA  IN " + cConta + " "
            cSql += " 			AND D_E_L_E_T_ = ' ' "

            cSql := ChangeQuery(cSql)
            dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nAlia2,.F.,.T.)

            If !(nAlia2)->(Eof())

                IF (nCp > 1 .And. nCp <= 3) .Or. nCp >= 8
                    lRet := ( nSldCob = (nAlia2)->VALCTB)
                ElseIf nCp = 4 .Or. nCp = 6
                    lRet := ( nSldCob <= (nAlia2)->VALCTB)
                ElseIf nCp = 5
                    lRet := ( nSldCob <= (nAlia2)->VALCTB .And. nSldCob <= (nAlia1)->( CAMPO04))
                ElseIf nCp = 7
                    lRet := ( nSldCob <= (nAlia2)->VALCTB .And. nSldCob <= (nAlia1)->( CAMPO06))
                Endif

            Else
                lRet	:= .F.
            EndIf
            (nAlia2)->(dbCloseArea())
        Else
            lRet := .T.
        EndIf
        (nAlia1)->(dbCloseArea())
    EndIf

Return lRet