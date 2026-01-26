#Include "Protheus.ch"
#include "TopConn.ch"
#include "TbIconn.ch" 

Static __lFIXQRY    := Nil
Static __aTipos     := Nil
Static __lCpoQryP   := Nil

/*/{Protheus.doc} FIXFATREIN
    Função responsável pela atualização do campo C6_NATREN e gravação da tabela FKW.
	Trata-se de um componente do FIXREINF.

    @type  Function
    @author Alberto Teixeira
    @since 30/09/2023
    
    @param cDataIni - Data para inicio do processamento
/*/
Function FIXFATREIN(cDataIni As Character) 

    Local aNatAux       As Array
    Local aCountNat     As Array
    Local aCountSE1     As Array
    Local aNatureza     As Array
    Local aTitulos      As Array
    Local aNota         As Array
    Local aNatRend      As Array
    Local aSE1NatRen    As Array
    Local cAliasSD2	    As Character
    Local cAliasSE1	    As Character
    Local cQryNew       As Character
    Local cQrySD2       As Character
    Local cQrySE1       As Character
    Local cQrySD2Ori    As Character
    Local cTipoQry      As Character
    Local nPosNatRen    As Numeric
    Local nNatLoop      As Numeric
    Local nI            As Numeric
    Local nX            As Numeric
    Local nZ            As Numeric
    Local oFatSD2       As Object
    Local oFatSE1       As Object

    If __lFIXQRY == Nil
        __lFIXQRY := ExistBlock( "FIXQRYR" )
    EndIf

    If __aTipos  == Nil
        __aTipos  := Strtokarr(MVABATIM, "|")
    EndIf

    aNatAux       := {}
    aCountNat     := {}
    aCountSE1     := {}
    aNatureza     := {}
    aTitulos      := {}
    aNota         := Array(2)
    aNatRend      := Array(4)
    aSE1NatRen    := Array(2)
    cAliasSD2	  := GetNextAlias()
    cAliasSE1	  := ""
    cQryNew       := ""
    cQrySD2       := ""
    cQrySE1       := ""
    cQrySD2Ori    := ""
    cTipoQry      := "P"
    nPosNatRen    := 0
    nNatLoop      := 0
    nI            := 0
    nX            := 0
    nZ            := 0
    oFatSD2       := Nil
    oFatSE1       := Nil

    If __lCpoQryP == NIL
        __lCpoQryP := REINFLOG->(ColumnPos("CQUERYP")) > 0
    EndIf

    Default cDataIni := DTOS( Date() )

    aNatRend[2] := {}
	aSE1NatRen[2] := {}

    If oFatSD2 == Nil
        cQrySD2 := "SELECT SC6.R_E_C_N_O_ AS RECSC6, F2Q.F2Q_NATREN, SD2.D2_VALIRRF, SD2.D2_BASEIRR, SD2.D2_SERIE, SD2.D2_DOC " 
        cQrySD2 += "FROM ? SC6 "
        cQrySD2 += "INNER JOIN ? F2Q "
        cQrySD2 += "ON F2Q.F2Q_FILIAL = ? "
        cQrySD2 += "AND F2Q.F2Q_PRODUT = SC6.C6_PRODUTO "
        cQrySD2 += "AND F2Q.F2Q_NATREN IS NOT NULL "
        cQrySD2 += "AND F2Q.F2Q_NATREN <> ' ' "
        cQrySD2 += "AND SC6.D_E_L_E_T_ = F2Q.D_E_L_E_T_ "
        cQrySD2 += "INNER JOIN ? SD2 " 
        cQrySD2 += "ON SD2.D2_FILIAL = ? "
        cQrySD2 += "AND SD2.D2_PEDIDO = SC6.C6_NUM "
        cQrySD2 += "AND SD2.D2_ITEMPV = SC6.C6_ITEM "
        cQrySD2 += "AND SD2.D2_BASEIRR > 0 "
        cQrySD2 += "AND SC6.D_E_L_E_T_ = SD2.D_E_L_E_T_ "
        cQrySD2 += "WHERE " 
        cQrySD2 += "SC6.C6_FILIAL = ? "
        cQrySD2 += "AND SC6.C6_NATREN IS NOT NULL "
        cQrySD2 += "AND SC6.C6_NATREN = ' ' "
        cQrySD2 += "AND SC6.D_E_L_E_T_ = ' ' "
        cQrySD2	:= ChangeQuery(cQrySD2)
        oFatSD2 := FwPreparedStatement():New(cQrySD2)
    EndIf
    
    oFatSD2:SetNumeric(1, RetSqlName("SC6"))
    oFatSD2:SetNumeric(2, RetSqlName("F2Q"))
    oFatSD2:SetString(3, FwxFilial("F2Q"))
    oFatSD2:SetNumeric(4, RetSqlName("SD2"))
    oFatSD2:SetString(5, FwxFilial("SD2"))
    oFatSD2:SetString(6, FwxFilial("SC6"))

    cQrySD2 := oFatSD2:GetFixQuery()

    If __lFIXQRY
        cQryNew := cQrySD2
        cQryNew := ExecBlock("FIXQRYR",.F.,.F.,{"05",, cQryNew})

        If ValType(cQryNew) == "C" .And. !Empty(cQryNew) .And. (AllTrim(cQrySD2) != AllTrim(cQryNew))
            cQrySD2  := cQryNew
            cTipoQry := "C"
        EndIF
    EndIf

    cQrySD2 += " ORDER BY RECSC6 "

    cAliasSD2 := MpSysOpenQuery(cQrySD2)

	While (cAliasSD2)->(!Eof())
        If Empty(aNatRend[2])
            aAdd(aNatureza, {(cAliasSD2)->RECSC6 , (cAliasSD2)->F2Q_NATREN} )

            aNota[1] := (cAliasSD2)->D2_SERIE
            aNota[2] := (cAliasSD2)->D2_DOC
            aNatRend[1] := (cAliasSD2)->D2_VALIRRF

            aAdd(aNatRend[2], {(cAliasSD2)->F2Q_NATREN, (cAliasSD2)->D2_VALIRRF, (cAliasSD2)->D2_BASEIRR})
        Else 
            aAdd(aNatureza, {(cAliasSD2)->RECSC6 , (cAliasSD2)->F2Q_NATREN} )

			aNatRend[1] += (cAliasSD2)->D2_VALIRRF
			nPosNatRen := aScan(aNatRend[2],{|x| x[1] == (cAliasSD2)->F2Q_NATREN})

			If nPosNatRen == 0
				aAdd(aNatRend[2],{(cAliasSD2)->F2Q_NATREN, (cAliasSD2)->D2_VALIRRF, (cAliasSD2)->D2_BASEIRR})
			Else
				aNatRend[2][nPosNatRen,2] += (cAliasSD2)->D2_VALIRRF
				aNatRend[2][nPosNatRen,3] += (cAliasSD2)->D2_BASEIRR
			Endif
        EndIf   

		(cAliasSD2)->(dbSkip())

        If !Empty(aNatRend[2]) .And. aNota[2] <> (cAliasSD2)->D2_DOC
            aAdd(aCountNat, aClone(aNatRend))
            aAdd(aTitulos, aCLone(aNota))

            aNatRend[2] := {}
        EndIf
    EndDo

    (cAliasSD2)->(DbCloseArea())
    
    For nZ := 1 to Len(aTitulos)

        If oFatSE1 == Nil
            cQrySE1 := " SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, "
            cQrySE1 += " SE1.E1_IRRF, SE1.E1_BASEIRF, SE1.E1_TITPAI "
            cQrySE1 += " FROM ? SE1 "
            cQrySE1 += " WHERE "
            cQrySE1 += " SE1.E1_FILIAL = ? "
            cQrySE1 += " AND SE1.E1_PREFIXO = ? "
            cQrySE1 += " AND SE1.E1_NUM = ? "
            cQrySE1 += " AND SE1.E1_TIPO NOT IN ( ? ) "
            cQrySE1 += " AND SE1.E1_EMISSAO >= ? "
            cQrySE1 += " AND SE1.E1_ORIGEM = 'MATA460' "
            cQrySE1 += " AND SE1.D_E_L_E_T_ = ' ' "

            cQrySE1	:= ChangeQuery(cQrySE1)
            oFatSE1 := FwPreparedStatement():New(cQrySE1)
        EndIf

        oFatSE1:SetNumeric(1, RetSqlName("SE1"))
        oFatSE1:SetString(2, FwxFilial("SE1"))
        oFatSE1:SetString(3, aTitulos[nZ][1])
        oFatSE1:SetString(4, aTitulos[nZ][2])
        oFatSE1:SetIn(5, __aTipos )
        oFatSE1:SetString(6, cDataIni)

        cQrySE1 := oFatSE1:GetFixQuery()
        cAliasSE1 := MpSysOpenQuery(cQrySE1)
        
        While (cAliasSE1)->(!Eof())
            If Empty(aSE1NatRen[2])
                aSE1NatRen[1] := (cAliasSE1)->E1_IRRF

                Aadd(aSE1NatRen[2], {(cAliasSE1)->E1_PREFIXO, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA,;
                                    (cAliasSE1)->E1_IRRF, (cAliasSE1)->E1_BASEIRF, (cAliasSE1)->E1_TITPAI})

                cTitulo := (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_TIPO
            Else 
                aSE1NatRen[1] += (cAliasSE1)->E1_IRRF

                Aadd(aSE1NatRen[2], {(cAliasSE1)->E1_PREFIXO, (cAliasSE1)->E1_NUM, (cAliasSE1)->E1_PARCELA, (cAliasSE1)->E1_TIPO, (cAliasSE1)->E1_CLIENTE, (cAliasSE1)->E1_LOJA,;
                                    (cAliasSE1)->E1_IRRF, (cAliasSE1)->E1_BASEIRF, (cAliasSE1)->E1_TITPAI})
            EndIf   

            DbSelectArea("REINFLOG")
            DbSetIndex('IND1')
            lRegNew := REINFLOG->(MsSeek("DS" + cTitulo ))

            If RecLock("REINFLOG",!lRegNew)
                REINFLOG->GRUPO    := cEmpAnt
                REINFLOG->EMPFIL   := cFilAnt
                REINFLOG->DATAPROC := FWTimeStamp(2, DATE(), TIME())
                REINFLOG->TIPO     := "DS"
                REINFLOG->CHAVE    := cTitulo
                REINFLOG->FATC6    := "U" //U=Update
                REINFLOG->FATFKW   := "I" //I=Insert
                If __lCpoQryP
                    REINFLOG->CQUERYP   := cTipoQry  //Indica que usuario customizou query
                EndIf

                REINFLOG->(MsUnlock())
            Endif

            (cAliasSE1)->(dbSkip())

            If !Empty(aSE1NatRen[2]) .And. cTitulo <> (cAliasSE1)->E1_PREFIXO + (cAliasSE1)->E1_NUM + (cAliasSE1)->E1_TIPO
                aAdd(aCountSE1, aClone(aSE1NatRen))  

                If nNatLoop < nZ
                    aAdd(aNatAux, aClone(aCountNat[nZ]))
                    nNatloop := nZ
                EndIf

                aSE1NatRen[2] := {}
            EndIf
        EndDo
        
        (cAliasSE1)->(DbCloseArea())
    Next nZ
    
    For nX := 1 to Len(aNatureza)
        SC6->(dbGoto(aNatureza[nX][1])) 
        
        RecLock("SC6",.F.)
        SC6->C6_NATREN	:= aNatureza[nX][2]
        SC6->(MsUnlock())
    Next nX

    aCountNat := aClone(aNatAux)
    FWFreeArray(aNatAux)

    For nI := 1 to Len(aCountNat)
        A461FKW(3,aCountNat[nI], aCountSE1[nI])
    Next nI

Return 
