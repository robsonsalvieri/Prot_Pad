#Include 'Protheus.ch'

Function TAFDMA12(aWizard, aFiliais)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""

	Local nValTrib 	:= 0
	Local nValIsen 	:= 0
	Local nValOutr 	:= 0
	Local nValTotal 	:= 0
	Local aNatur := {}

	Local nMes := VAL(Substr(aWizard[1][2],1,2))
	Local nAno := VAL(Substr(aWizard[1][2],4,4))
	Local nPos := 0

	Local cDataIni	:= ""
	Local cDataFim	:= ""
	Local cData		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	If nMes == 1
	   nMes := 12
	   nAno--
	Else
		nMes--
	EndIf

	cDataIni	:= Dtos(Lastday(CTOD("01/" + cValToChar(nMes) + cValToChar(nAno)) ,0))
	cDataFim	:= Dtos(Lastday(CTOD("01/" + aWizard[1][2]),0))

	//Natureza
	AADD(aNatur, {1, "1"})
	AADD(aNatur, {2, "2"})
	AADD(aNatur, {3, "3"})
	AADD(aNatur, {4, "4"})
	AADD(aNatur, {5, "5"})
	AADD(aNatur, {6, "6"})
	AADD(aNatur, {7, "7"})
	AADD(aNatur, {8, "99"})

	//fnDMAReg12 1 - Tipo da natureza
	//fnDMAReg12 2 - Considerar ou não
	//fnDMAReg12 3 - CST
	//fnDMAReg12 4 - Data Inicial/Final
	//fnDMAReg12 5 - Filial

	Begin Sequence

		For nPos := 1 to len(aNatur)
			//Inicial
			nValTrib 	:= fnDMAReg12(aNatur[nPos, 2], "NOT IN", "'40', '41', '90'", cDataIni, aFiliais)
			nValIsen 	:= fnDMAReg12(aNatur[nPos, 2], "IN", "'40', '41'", cDataIni, aFiliais)
			nValOutr 	:= fnDMAReg12(aNatur[nPos, 2], "IN", "'90'", cDataIni, aFiliais)

			nValTotal 	:= nValTrib + nValIsen + nValOutr

			If (nValTotal > 0)
				cStrTxt += "12"                          			// 	Tipo
				cStrTxt += Substr(cData,1,4) 		 				// 	Ano de Referência
				cStrTxt += Substr(cData,5,2) 		 				// 	Mês de Referência
				cStrTxt += StrZero(VAL(aFiliais[5]),9,0)  		// 	Inscrição Estadual
				cStrTxt += "I" 										//	Status de Estoque Inicial/Final
				cStrTxt += StrZero(VAL(aNatur[nPos, 2]), 2, 0) 	//	Tabela de Estoque
				cStrTxt += StrZero(nValTrib  * 100, 12) 			//	Valor Tributadas
				cStrTxt += StrZero(nValIsen  * 100, 12) 			//	Valor Isentas ou Não Tributadas
				cStrTxt += StrZero(nValOutr  * 100, 12) 			//	Valor Outras
				cStrTxt += StrZero(nValTotal * 100, 12)	 		//	Valor Total do Estoque
				cStrTxt += CRLF
			EndIf

			//Final
			nValTrib 	:= fnDMAReg12(aNatur[nPos, 2], "NOT IN", "'40', '41', '90'", cDataFim, aFiliais)
			nValIsen 	:= fnDMAReg12(aNatur[nPos, 2], "IN", "'40', '41'", cDataFim, aFiliais)
			nValOutr 	:= fnDMAReg12(aNatur[nPos, 2], "IN", "'90'", cDataFim, aFiliais)

			nValTotal 	:= nValTrib + nValIsen + nValOutr

			If (nValTotal > 0)
				cStrTxt += "12"                          			// 	Tipo
				cStrTxt += Substr(cData,1,4) 		 				// 	Ano de Referência
				cStrTxt += Substr(cData,5,2) 		 				// 	Mês de Referência
				cStrTxt += StrZero(VAL(aFiliais[5]),9,0)  		// 	Inscrição Estadual
				cStrTxt += "F" 										//	Status de Estoque Inicial/Final
				cStrTxt += StrZero(VAL(aNatur[nPos, 2]), 2, 0)	//	Tabela de Estoque
				cStrTxt += StrZero(nValTrib  * 100, 12) 			//	Valor Tributadas
				cStrTxt += StrZero(nValIsen  * 100, 12) 			//	Valor Isentas ou Não Tributadas
				cStrTxt += StrZero(nValOutr  * 100, 12) 			//	Valor Outras
				cStrTxt += StrZero(nValTotal * 100, 12)	 		//	Valor Total do Estoque
				cStrTxt += CRLF
			EndIf
		Next

		If cStrTxt != ""
			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO12")
		EndIf
		Recover
		lFound := .F.
	End Sequence

Return

Static Function fnDMAReg12(cNatRes, cUtil, cCst, cData, aFiliais)

Local cStrQuery	:= ""
Local cAlias1	:= GetNextAlias()
Local nValor 	:= 0
Local aArray 	:= {}

	cStrQuery := 	"  SELECT C5C.C5C_NATRES, SUM(C5C_VICMS) VICMS "
	cStrQuery +=	"	 FROM " +	RetSqlName('C5A') + ' C5A, '
	cStrQuery +=			     	RetSqlName('C5C') + ' C5C, '
	cStrQuery +=			     	RetSqlName('C14') + ' C14 '
	cStrQuery +=	"	WHERE C5A.C5A_FILIAL  = '" + aFiliais[1] + "' "
	cStrQuery +=	"	  AND C5A.C5A_DTINV   = '" + cData + "' "
	cStrQuery +=	"	  AND C5C.C5C_FILIAL  = C5A.C5A_FILIAL "
	cStrQuery +=	"	  AND C5C.C5C_ID      = C5A.C5A_ID "
	cStrQuery +=	"	  AND C5C.C5C_NATRES  = '" + cNatRes + "' "

	cStrQuery += 	" 	  AND C14.C14_ID      = C5C.C5C_CSTICM "
	cStrQuery += 	" 	  AND C14.C14_CODIGO	 " + cUtil + " (" + cCst  + ") "

	cStrQuery +=	"	  AND C5A.D_E_L_E_T_  = '' "
	cStrQuery +=	"	  AND C5C.D_E_L_E_T_  = '' "
	cStrQuery +=	"	  AND C14.D_E_L_E_T_  = '' "
	cStrQuery +=	"	GROUP BY C5C.C5C_NATRES"

	cStrQuery := ChangeQuery(cStrQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias1,.T.,.T.)
	DbSelectArea(cAlias1)

	If ((cAlias1)->VICMS > 0)
		nValor := (cAlias1)->VICMS
	EndIf

	(cAlias1)->(DbCloseArea())

Return nValor

