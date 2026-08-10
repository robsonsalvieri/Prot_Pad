#include 'protheus.ch'

Function TAFGRSA2(aFilial as Array, cDatIni as Char, cDatFim as Char, cCabecalho as Char)

	Local cTxtSys  	as char
	Local cStrTxt   as char

	Local nHandle   as numeric
	Local nLinha    as numeric
	Local nPos 		as numeric
	local nQtdInic  as numeric
	Local nTotal    as numeric

	Local aAnexo as array

	Begin Sequence

		cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
		nHandle   	:= MsFCreate( cTxtSys )
		cStrTxt		:= ""

		aAnexo := {}
		aAnexo := VlAjuApGRS(2, aFilial[1], aFilial[7], cDatIni, cDatFim, "00803")

		AADD(aTotAnexo, {"qtdAnexoII", len(aAnexo)})

		nTotal := 0

		If (len(aAnexo) > 0)

			nLinha := 1
			nSeqGiaRS++
			nQtdInic := (If ((len(aAnexo) > 32), 32, len(aAnexo)))

			cStrTxt += cCabecalho			//Cabeçalho
			cStrTxt += StrZero(nSeqGiaRS,4)	//Contador de Linha do Arquivo
			cStrTxt += "X02 "				//Identificador do Registro - FIXO X02
			cStrTxt += StrZero(nQtdInic, 2) //Qtd Linha

			For nPos := 1 To len(aAnexo)

				cStrTxt += StrZero( VAL(TAFRemCharEsp(aAnexo[nPos,1])), 10  )
				cStrTxt += StrZero( VAL(aAnexo[nPos,2]), 3   )
				cStrTxt += StrZero( aAnexo[nPos,3] * 100, 13 )

				nTotal += aAnexo[nPos,3]

				If (nPos % 32 == 0)
					nSeqGiaRS++
					nLinha++
					cStrTxt += CRLF
					cStrTxt += cCabecalho						             //Cabeçalho
					cStrTxt += StrZero(nSeqGiaRS,4)				             //Contador de Linha do Arquivo
					cStrTxt += "X02 "							             //Identificador do Registro - FIXO X02
					cStrTxt += (If ((len(aAnexo) - (32 * nLinha) > 0), "32", StrZero(len(aAnexo) - nPos, 2))) //Qtd Linha
				EndIf

			Next nPos
			cStrTxt += CRLF
		EndIf

		AADD(aTotAnexo, {"AnexoII_Transf", nTotal})

		//======================A N E X O  III ================================

		aAnexo := {}
		aAnexo := VlAjuApGRS(3, aFilial[1], aFilial[7], cDatIni, cDatFim, "00804")

		AADD(aTotAnexo, {"qtdAnexoIII", len(aAnexo)})

		nTotal := 0
		If (len(aAnexo) > 0)

			nLinha := 1
			nSeqGiaRS++
			nQtdInic := (If ((len(aAnexo) > 30), 30, len(aAnexo)))

			cStrTxt += cCabecalho			//Cabeçalho
			cStrTxt += StrZero(nSeqGiaRS,4)	//Contador de Linha do Arquivo
			cStrTxt += "X03 "				//Identificador do Registro - FIXO X03
			cStrTxt += StrZero(nQtdInic, 2) //Qtd Linha

			For nPos := 1 To len(aAnexo)

				cStrTxt += StrZero( VAL(aAnexo[nPos,1]), 3  )
				cStrTxt += StrZero( aAnexo[nPos,2] * 100, 13   )
				cStrTxt += (If ((len(aAnexo[nPos,3]) > 12), Substr(aAnexo[nPos,3], 1, 12), PADL(aAnexo[nPos,3], 12,"0") ))

				nTotal += aAnexo[nPos,2]

				If (nPos % 30 == 0)
					nSeqGiaRS++
					nLinha++
					cStrTxt += CRLF
					cStrTxt += cCabecalho						             //Cabeçalho
					cStrTxt += StrZero(nSeqGiaRS, 4)				         //Contador de Linha do Arquivo
					cStrTxt += "X03 "			 				             //Identificador do Registro - FIXO X03
					cStrTxt += (If ((len(aAnexo) - (30 * nLinha) > 0), "30", StrZero(len(aAnexo) - nPos, 2))) //Qtd Linha
				EndIf

			Next nPos
			cStrTxt += CRLF
		EndIf

		AADD(aTotAnexo, {"AnexoIII_Presum", nTotal})

    	If  cStrTxt != ''
    		WrtStrTxt( nHandle, cStrTxt)
    		GerTxtGRS( nHandle, cTxtSys, aFilial[1] + "_X02_X03")
    	EndIf

	    Recover
		lFound := .F.

	End Sequence

Return

Function VlAjuApGRS(nAnexo as numeric, pFilial as Char, pUF as Char, cDatIni as char, cDatFim as char, cSubItem as char)

	Local cSelect	 as Char
	Local cFrom		 as Char
	Local cWhere	 as Char
	Local cGroupBy   as Char

	Local aArray     as array
	Local cAliasQry	 := GetNextAlias()

	aArray := {}

	cSelect := " T0V.T0V_CODIGO T0V_CODIGO, "

    If (nAnexo == 2 .Or. nAnexo == 6)
   		cSelect += " C1H.C1H_IE C1H_IE "
    Else
		cSelect += " C2D.R_E_C_N_O_"
    Endif

    cSelect += ", SUM (C2D.C2D_VLICM) C2D_VLICM"

    cFrom := RetSqlName('C20') + " C20, "

    If (nAnexo == 2 .Or. nAnexo == 6)
    	cFrom += RetSqlName('C1H') + " C1H, "
    Endif

    cFrom += RetSqlName('C2D') + " C2D, "
    cFrom += RetSqlName('CHY') + " CHY,  "
    cFrom += RetSqlName('T0V') + " T0V  "

    cWhere := "      C20.C20_FILIAL = '" + pFilial + "' "
    cWhere += "  AND C20.C20_DTDOC  BETWEEN '" + cDatIni + "' AND '" + cDatFim + "'"
    cWhere += "  AND C20.C20_INDOPE = " + IIF(nAnexo == 6,"'1'","'0'")
    cWhere += "  AND C20.C20_CODSIT NOT IN('000003','000005','000006') "  //CANCELADA, INUTILIZADA E DENEGADA

    If (nAnexo == 2 .Or. nAnexo == 6)
 	    cWhere += "  AND C1H.C1H_FILIAL = C20.C20_FILIAL "
 	   	cWhere += "  AND C1H.C1H_ID 	= C20.C20_CODPAR "
    EndIf

    cWhere += "  AND C20.C20_FILIAL = C2D.C2D_FILIAL "
    cWhere += "  AND C20.C20_CHVNF  = C2D.C2D_CHVNF "

    cWhere += "  AND CHY.CHY_FILIAL = '" + xFilial("CHY") + "' "
    cWhere += "  AND CHY.CHY_ID     = C2D.C2D_IDSUBI "
    cWhere += "  AND CHY.CHY_CODIGO = '" + cSubItem + "' "
    cWhere += "  AND CHY.CHY_IDUF   = '" + pUF + "' "

    cWhere += "  AND T0V.T0V_FILIAL = '" + xFilial("T0V") + "' "
    cWhere += "  AND T0V.T0V_ID     = C2D.C2D_IDTMOT "
    cWhere += "  AND T0V.T0V_IDUF   = '" + pUF + "' "

    cGroupBy := " T0V.T0V_CODIGO"

    If (nAnexo == 2 .Or. nAnexo == 6)
    	cGroupBy += ", C1H.C1H_IE "
    Else
		cGroupBy += ", C2D.R_E_C_N_O_"
    Endif

	cSelect      := "%" + cSelect     + "%"
	cFrom        := "%" + cFrom       + "%"
	cWhere       := "%" + cWhere      + "%"
	cGroupBy     := "%" + cGroupBy    + "%"

	If (nAnexo == 2 .Or. nAnexo == 6)
		BeginSql Alias cAliasQry

		    SELECT
		    	%Exp:cSelect%
		    FROM
		        %Exp:cFrom%
		    WHERE
		        %Exp:cWhere% AND
		        C20.%NotDel% AND
		        C1H.%NotDel% AND
		        C2D.%NotDel% AND
		        CHY.%NotDel% AND
		        T0V.%NotDel%
	        GROUP BY
		        %Exp:cGroupBy%
		EndSql
	Else
		BeginSql Alias cAliasQry

		    SELECT
		    	%Exp:cSelect%
		    FROM
		        %Exp:cFrom%
		    WHERE
		        %Exp:cWhere% AND
		        C20.%NotDel% AND
		        C2D.%NotDel% AND
		        CHY.%NotDel% AND
		        T0V.%NotDel%
	        GROUP BY
		        %Exp:cGroupBy%
		EndSql
	Endif

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	DbSelectArea("C2D")
	While (cAliasQry)->(!EOF())

		If (nAnexo == 2 .Or. nAnexo == 6)
			aAdd(aArray, { (cAliasQry)->C1H_IE, (cAliasQry)->T0V_CODIGO, (cAliasQry)->C2D_VLICM})
		Else
			C2D->(dbGoTo((cAliasQry)->R_E_C_N_O_))
			aAdd(aArray, { Substr((cAliasQry)->T0V_CODIGO, 3, 3), (cAliasQry)->C2D_VLICM, C2D->C2D_DESCRI })
		EndIf

		(cAliasQry)->( DbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())

Return aArray
