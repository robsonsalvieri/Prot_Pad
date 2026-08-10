#Include 'totvs.ch'

Function CENVLDFI1()
    Local lRetorno	:= .F.
    Local aContas	:= {'35134'}

    lRetorno	:= CENQRYBAL(aContas,1)

Return lRetorno

Function CENVLDFI2()
    Local lRetorno	:= .F.
    Local aContas	:= {'12211902','12212902','12213901','12221902','12222902','12223901','13111902','13112902','13113901','13121902','13122902','13123901'}

    lRetorno	:= CENQRYBAL(aContas,5)

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

        cSql := " SELECT B6Z_VLRTAQ CAMPO01,"
        cSql += "        B6Z_VLRTAF CAMPO03,"
        cSql += "        B6Z_VLRTAI CAMPO05 "
        cSql += "	FROM " + RetSqlName("B6Z")
        cSql += "	WHERE B6Z_FILIAL = '" + xFilial("B6Z") + "' "
        cSql += "			AND B6Z_CODOPE = '" + cCodOpe + "' "
        cSql += "			AND B6Z_CODOBR = '" + cCodObr + "' "
        cSql += "			AND B6Z_ANOCMP = '" + cAnoCmp + "' "
        cSql += "			AND B6Z_CDCOMP = '" + cCdComp + "' "
        cSql += " 			AND D_E_L_E_T_ = ' ' "

        cSql := ChangeQuery(cSql)
        dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nAlia1,.F.,.T.)

        If !(nAlia1)->(Eof())
            If nCp == 1
                nSldCob	:= (nAlia1)->( CAMPO01 )
            Else
                nSldCob	:= (nAlia1)->( CAMPO05 )
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

                IF nCp = 1
                    lRet := (nSldCob = (nAlia2)->VALCTB)
                ElseIf nCp = 5
                    nSumCta:=(nAlia1)->( CAMPO01) + (nAlia1)->( CAMPO03)
                    lRet := ( nSldCob = (nAlia2)->VALCTB) .And. nSumCta = nSldCob
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