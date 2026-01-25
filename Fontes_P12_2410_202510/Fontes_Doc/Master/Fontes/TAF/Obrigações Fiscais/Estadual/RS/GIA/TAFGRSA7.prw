#include 'protheus.ch'

Function TAFGRSA7(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

	Local nHandle    as Numeric
	Local cTxtSys    as Char
	Local cStrTxt  	 as Char
	Local cTxtOutCre as Char
	Local cTxtOutDeb as Char

	Local nOutrosCre as Numeric
	Local nOutrosDeb as Numeric
	Local nCrEntrad  as Numeric
	Local nDbSaida   as Numeric
	Local nPos 		 as Numeric

	Local iQtdVIIa as Numeric
	Local iQtdVIIb as Numeric
	Local nQtdInic as Numeric

	Local aAnexoVIIa	as array
	Local aAnexoVIIb	as array
	Local aValOutr 		as array

	//*****************************
	// *** INICIALIZA VARIAVEIS ***
	//*****************************
	cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	nHandle   	:= MsFCreate( cTxtSys )
	cStrTxt 	:= ""

	nOutrosCre := 0
	nOutrosDeb := 0
	nCrEntrad  := 0
	nDbSaida   := 0

	iQtdVIIa := 0
	iQtdVIIb := 0
	nQtdInic := 0

	cTxtOutCre := ""
	cTxtOutDeb := ""

	aAnexoVIIa	:= {}
	aAnexoVIIb	:= {}
	aValOutr 	:= {}

	Begin Sequence
		//==================Outros Créditos Anexo VII
		aValOutr := OutAnexVII(aFilial[1], aFilial[7], cDatIni, cDatFim, " NOT IN ('000009')", "00701")

		If (len(aValOutr) > 0)
			nOutrosCre += aValOutr[1,1]
			cTxtOutCre += aValOutr[1,2]

			If len(cTxtOutCre) > 60
				cTxtOutCre := Substr(cTxtOutCre, 1, 60)
			Endif
		EndIf
		//==========================================

		//==================Outros Débitos Anexo VII
		aValOutr := OutAnexVII(aFilial[1], aFilial[7], cDatIni, cDatFim, " IN ('000009', '000024') ", "00201")

		If (len(aValOutr) > 0)
			nOutrosDeb += aValOutr[1,1]
			cTxtOutDeb += aValOutr[1,2]

			If len(cTxtOutDeb) > 60
				cTxtOutDeb := Substr(cTxtOutDeb, 1, 60)
			Endif

		EndIf
		//==========================================

		//Retorna Array para AnexoVIIa
		aAnexoVIIa :=  AnexoVII(aFilial[1], cDatIni, cDatFim, "NOT IN ('EX')", "E")
		iQtdVIIa   :=  len(aAnexoVIIa)
		If (len(aAnexoVIIa) > 0)
			For nPos := 1 To len(aAnexoVIIa)
				nCrEntrad += aAnexoVIIa[nPos, 3]
			Next nPos
		EndIf

		//Retorna Array para AnexoVIIb
		aAnexoVIIb :=  AnexoVII(aFilial[1], cDatIni, cDatFim, " IN ('EX', 'RS')", "S")
		iQtdVIIa   :=  len(aAnexoVIIb)
		If (len(aAnexoVIIb) > 0)
			For nPos := 1 To len(aAnexoVIIb)
				nDbSaida += aAnexoVIIb[nPos, 3]
			Next nPos
		EndIf

		nSeqGiaRS++

        If ((len(aAnexoVIIa) .Or. len(aAnexoVIIb) > 0 .Or. nOutrosCre > 0 .Or. nOutrosDeb > 0))
			cStrTxt += cCabecalho						             //Cabeçalho
			cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
			cStrTxt += "X07 "							             //Identificador do Registro - FIXO X05A
			cStrTxt += "01" 								         //Qtd Linha
			cStrTxt += StrZero( nCrEntrad  * 100, 13 )                //CR ENTRADAS rf. Subst.Tribut.
			cStrTxt += StrZero( nOutrosCre * 100, 13 )               //Outros Créditos
			cStrTxt += padL(AllTrim(cTxtOutCre), 60) 			 	 //Texto Outros créditos
			cStrTxt += StrZero( (nCrEntrad + nOutrosCre) * 100, 13 ) //Total dos Créditos
			cStrTxt += StrZero( nDbSaida   * 100, 13 ) 				 //DB SAÍDAS rf. Subst.Tribut.
			cStrTxt += StrZero( nOutrosDeb * 100, 13 ) 				 //Outros Débitos
			cStrTxt += padR(AllTrim(cTxtOutDeb), 60) 			 			 //Texto Outros Débitos
			cStrTxt += StrZero( (nDbSaida + nOutrosDeb) * 100, 13 )  //Total dos Débitos
			cStrTxt += CRLF

			aADD(aTotAnexo, {"qtdAnexoVII", 1})

			nLinha := 1
			If (len(aAnexoVIIa) > 0)

				nSeqGiaRS++
				nQtdInic := (If ((len(aAnexoVIIa) > 28), 28, len(aAnexoVIIa)))

				cStrTxt += cCabecalho						             //Cabeçalho
				cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
				cStrTxt += "X07A"							             //Identificador do Registro - FIXO X07A
				cStrTxt += StrZero(nQtdInic, 2) //Qtd Linha

				For nPos := 1 To len(aAnexoVIIa)

					cStrTxt += aAnexoVIIa[nPos,1]
					cStrTxt += StrZero( aAnexoVIIa[nPos,2] * 100, 13 )
					cStrTxt += StrZero( aAnexoVIIa[nPos,3] * 100, 13 )

					If (nPos % 28 == 0)
						nSeqGiaRS++
						nLinha++
						cStrTxt += CRLF
						cStrTxt += cCabecalho						             //Cabeçalho
						cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
						cStrTxt += "X07A"							             //Identificador do Registro - FIXO X07A
						cStrTxt += (If ((len(aAnexoVIIa) - (28 * nLinha) > 0), "28", StrZero(len(aAnexoVIIa) - nPos, 2))) //Qtd Linha
					EndIf

				Next nPos
				cStrTxt += CRLF
			EndIf

			nLinha := 1
			If (len(aAnexoVIIb) > 0)

				nSeqGiaRS++
				nQtdInic := (If ((len(aAnexoVIIb) > 28), 28, len(aAnexoVIIb)))

				cStrTxt += cCabecalho						             //Cabeçalho
				cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
				cStrTxt += "X07B"							             //Identificador do Registro - FIXO X07B
				cStrTxt += StrZero(nQtdInic, 2) //Qtd Linha

				For nPos := 1 To len(aAnexoVIIb)

					cStrTxt += aAnexoVIIb[nPos,1]
					cStrTxt += StrZero( aAnexoVIIb[nPos,2] * 100, 13 )
					cStrTxt += StrZero( aAnexoVIIb[nPos,3] * 100, 13 )

					If (nPos % 28 == 0)
						nSeqGiaRS++
						nLinha++
						cStrTxt += CRLF
						cStrTxt += cCabecalho						             //Cabeçalho
						cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
						cStrTxt += "X07B"							             //Identificador do Registro - FIXO X05A
						cStrTxt += (If ((len(aAnexoVIIb) - (28 * nLinha) > 0), "28", StrZero(len(aAnexoVIIb) - nPos, 2))) //Qtd Linha
					EndIf
				Next nPos
				cStrTxt += CRLF
			EndIf
		EndIf

		aADD(aTotAnexo, {"AnexoVII_TotDeb", (nDbSaida + nOutrosDeb)})
		aADD(aTotAnexo, {"AnexoVII_TotCred", (nCrEntrad + nOutrosCre)})
		aADD(aTotAnexo, {"qtdAnexoVIIa", len(aAnexoVIIa)})
		aAdd(aTotAnexo, {"qtdAnexoVIIb", len(aAnexoVIIb)})

		If cStrTxt != ''
    		WrtStrTxt( nHandle, cStrTxt)
    		GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_X07")
    	EndIf

		Recover

		lFound := .F.

	End Sequence

Return


Static Function OutAnexVII(pFilial as Char, pUF as Char, cDatIni as char, cDatFim as char, cCondicao as char, cSubItem as char)

Local cSelect	 as Char
Local cFrom		 as Char
Local cWhere	 as Char

Local aArray     as array
Local cAliasQry	 := GetNextAlias()

	aArray := {}

	cSelect   := " C3K_VLRAJU VLRAJU, C3K.R_E_C_N_O_ "

	cFrom 	  := RetSqlName("C3J") + " C3J, "
	cFrom 	  += RetSqlName("C3K") + " C3K, "
	cFrom 	  += RetSqlName("CHY") + " CHY  "

	cWhere    := " 	   C3J.C3J_FILIAL = '" + pFilial + "' " //CÓDIGO
	cWhere    += " AND C3J.C3J_DTINI >= '" + cDatIni + "' "
    cWhere    += " AND C3J.C3J_DTFIN <= '" + cDatFim + "' "
    cWhere    += " AND C3J.C3J_UF 	     " + cCondicao

    cWhere    += " AND C3K.C3K_FILIAL = C3J.C3J_FILIAL "
    cWhere    += " AND C3K.C3K_ID	  = C3J.C3J_ID "

    cWhere    += " AND CHY.CHY_FILIAL	  = '" + xFilial("CHY") + "' "
    cWhere    += " AND CHY.CHY_ID	  = C3K.C3K_IDSUBI "
    cWhere    += " AND CHY.CHY_CODIGO = '" + cSubItem + "' "
    cWhere    += " AND CHY.CHY_IDUF   = '" + pUF + "' " //IDUF

	cSelect      := "%" + cSelect     + "%"
	cFrom        := "%" + cFrom       + "%"
	cWhere       := "%" + cWhere      + "%"

	BeginSql Alias cAliasQry

	    SELECT
	    	%Exp:cSelect%
	    FROM
	        %Exp:cFrom%
	    WHERE
	        %Exp:cWhere% AND
	        C3J.%NotDel% AND
	        C3K.%NotDel% AND
	        CHY.%NotDel%
	EndSql

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	DbSelectArea("C3K")
	While (cAliasQry)->(!EOF())

		C3K->(dbGoTo((cAliasQry)->R_E_C_N_O_))

		Aadd(aArray, {(cAliasQry)->VLRAJU, C3K->C3K_AJUCOM })

		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())

Return aArray

Static Function AnexoVII(pFilial as char, cDatIni as char, cDatFim as char, cCondicao as char, cTpOper as char)

	Local cSelect	 as Char
	Local cFrom		 as Char
	Local cWhere	 as Char
	Local cGroupBy 	 as Char

	Local cAliasQry	:= GetNextAlias()
	Local aArray 	as array

	aArray := {}

	cSelect   := " C0Y.C0Y_CODIGO, "
	cSelect   += " SUM(C7A.C7A_BASE)    AS C7A_BASE,
	cSelect   += " SUM(C7A.C7A_IMPCRD)  AS C7A_IMPCRD "

	cFrom 	  := RetSqlName("C3J") + " C3J, "
	cFrom 	  += RetSqlName("C7A") + " C7A, "
	cFrom 	  += RetSqlName("C0Y") + " C0Y,  "
	cFrom 	  += RetSqlName("C09") + " C09  "

	cWhere    := "     C3J.C3J_FILIAL = '" + pFilial + "' "
	cWhere    += " AND C3J.C3J_DTINI >= '" + cDatIni + "' "
    cWhere    += " AND C3J.C3J_DTFIN <= '" + cDatFim + "' "
    cWhere    += " AND C09.C09_FILIAL = '" + xFilial("C09") + "' "
    cWhere    += " AND C09.C09_ID 	  = C3J.C3J_UF "
    cWhere    += " AND C09.C09_UF " +  cCondicao
    cWhere    += " AND C7A.C7A_FILIAL = C3J.C3J_FILIAL "
    cWhere    += " AND C7A.C7A_ID     = C3J.C3J_ID "
    cWhere    += " AND C7A.C7A_ESTADO = C3J.C3J_UF "

    cWhere    += " AND C0Y_FILIAL = '" + xFilial("C0Y") + "' "
    cWhere	  += " AND C0Y.C0Y_ID = C7A.C7A_CFOP "

    If(cTpOper = "E")
    	cWhere	  += " AND C0Y.C0Y_CODIGO BETWEEN '1101' AND '2949'
    Else
    	cWhere	  += " AND (C0Y.C0Y_CODIGO BETWEEN '5101' AND '5949' OR C0Y.C0Y_CODIGO BETWEEN '7101' AND '7949')
    EndIf

	cGroupBy  := " C0Y.C0Y_CODIGO"

	cSelect      := "%" + cSelect     + "%"
	cFrom        := "%" + cFrom       + "%"
	cWhere       := "%" + cWhere      + "%"
	cGroupBy     := "%" + cGroupBy    + "%"

	BeginSql Alias cAliasQry

	    SELECT
	    	%Exp:cSelect%
	    FROM
	        %Exp:cFrom%
	    WHERE
	        %Exp:cWhere% AND
	        C3J.%NotDel% AND
	        C7A.%NotDel% AND
	        C0Y.%NotDel% AND
	        C09.%NotDel%
        GROUP BY
	        %Exp:cGroupBy%
	EndSql

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	While (cAliasQry)->(!EOF())

		aAdd(aArray, { (cAliasQry)->C0Y_CODIGO, (cAliasQry)->C7A_BASE, (cAliasQry)->C7A_IMPCRD})

		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())

Return aArray
