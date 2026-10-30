#Include 'Protheus.ch'

Function TAFDMA0809(aWizard, aFiliais) //OPERAÇÕES E/S POR UF

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   := MsFCreate( cTxtSys )
	Local cStrTxt	:= ""
	Local cData 	:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Begin Sequence

		cStrTxt := FnTotalUF(cData, "0", aFiliais) //Tipo 08 - Entradas por UF
		cStrTxt += FnTotalUF(cData, "1", aFiliais) //Tipo 09 - Saídas por UF

		WrtStrTxt( nHandle, cStrTxt )

		GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO0809")

		Recover
		lFound := .F.
	End Sequence

Return

Static Function FnTotalUF(cPeriodo, cIndOper, aFiliais)

	Local cRegistro 	:= IF ((cIndOper == "0"), "08", "09")
	Local cCodUF 		:= ""
	Local cStrQuery		:= ""
	Local cNovoAlias	:= GetNextAlias()
	Local cStrTxt := ""
	Local nPos 	:= 0
	Local aArray 	:= {}
	Local lAchou 	:= .F.

	Local nValOutOpe 	:= 0
	Local nValMerc  	:= 0
	Local nValNC 		:= 0
	Local nValCont 	:= 0
	Local nValBase  	:= 0
	Local nValBaseC  	:= 0
	Local nValBasNC	:= 0
	Local nValICMSST	:= 0
	Local nValTOutOp 	:= 0
	Local nValTMerc  	:= 0
	Local nValTNC 	:= 0
	Local nValTCont 	:= 0
	Local nValTBase  	:= 0
	Local nValTBaseC 	:= 0
	Local nValTBasNC	:= 0
	Local nValTICMSS	:= 0

	Local cAnoRefer := Substr(cPeriodo,1,4)
	Local cMesRefer := Substr(cPeriodo,5,2)
	Local cFilAux	:= cFilAnt

	cFilAnt := aFiliais[1]

	cStrQuery := " SELECT "
	cStrQuery += "	C20.C20_CHVNF CHVNF, "
	cStrQuery += "	C1H.C1H_UF UF, "
	cStrQuery += "	C2F.C2F_CODTRI CODTRI, "
	cStrQuery += "	C2F.C2F_VLOPE VLOPE, "
	cStrQuery += "	SUM(C2F.C2F_BASE) BASE, "
	cStrQuery += "	SUM(C2F.C2F_VLISEN) VLISEN, "
	cStrQuery += "	SUM(C2F.C2F_VLOUTR) VLOUTR "	
	cStrQuery += "FROM " + RetSqlName('C20') + " C20 "
	cStrQuery += "	INNER JOIN " + RetSqlName('C1H') + " C1H ON C1H.C1H_FILIAL = '" + xFilial('C1H') + "' AND C1H.C1H_ID = C20.C20_CODPAR AND C1H.C1H_UF NOT IN ('000005','000009') AND C1H.D_E_L_E_T_ = '' "
	cStrQuery += "	INNER JOIN " + RetSqlName('C2F') + " C2F ON C2F.C2F_FILIAL = '" + xFilial('C2F') + "' AND C2F.C2F_CHVNF = C20.C20_CHVNF AND C2F.C2F_CODTRI = '000002' AND C2F.D_E_L_E_T_ = '' "
	cStrQuery += "WHERE C20.D_E_L_E_T_ = '' "
	cStrQuery += "	AND C20.C20_FILIAL = '" + xFilial('C20') + "' "
	cStrQuery += "	AND C20.C20_INDOPE = '" + cIndOper + "' "

	If "ORACLE" $ Upper(TcGetDB())
		cStrQuery += " AND SUBSTR(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
	Else
		cStrQuery += " AND SUBSTRING(C20.C20_DTES,1,6)  = '" + cPeriodo + "' "
	Endif

	cStrQuery += " GROUP BY C1H.C1H_UF, C2F.C2F_CODTRI, C2F.C2F_VLOPE, C20.C20_CHVNF  "
	cStrQuery += " ORDER BY C1H.C1H_UF	"

	cStrQuery := ChangeQuery(cStrQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)

	While (cNovoAlias)->(!Eof())

		If(len(aArray) = 0)
			AADD(aArray, {cRegistro, (cNovoAlias)->UF, (cNovoAlias)->CODTRI, (cNovoAlias)->VLOPE, (cNovoAlias)->BASE, (cNovoAlias)->VLISEN, (cNovoAlias)->VLOUTR})
			(cNovoAlias)->(DbSkip())
			Loop
		Endif

		For nPos := 1 To len(aArray)
			lAchou := .F.
			If(aArray[nPos,2] == (cNovoAlias)->UF .AND. aArray[nPos,3] == (cNovoAlias)->CODTRI)
				lAchou := .T.
			   	aArray[nPos,4] += (cNovoAlias)->VLOPE
			   	aArray[nPos,5] += (cNovoAlias)->BASE
				aArray[nPos,6] += (cNovoAlias)->VLISEN
				aArray[nPos,7] += (cNovoAlias)->VLOUTR
			EndIf
		Next nPos

		If(!lAchou)
			AADD(aArray, {cRegistro, (cNovoAlias)->UF, (cNovoAlias)->CODTRI, (cNovoAlias)->VLOPE, (cNovoAlias)->BASE, (cNovoAlias)->VLISEN, (cNovoAlias)->VLOUTR})
		EndIf

		(cNovoAlias)->(DbSkip())
	EndDo

	cStrTxt := ""
	For nPos := 1 To len(aArray)
		cCodUF := POSICIONE("C09",3,xFilial("C09") + aArray[nPos,2], "C09_UF")

		nValBase 	:= aArray[nPos,5]
		nValOutOpe	:= aArray[nPos,7]
		nValMerc  	:= 0
		nValNC 	:= 0
		nValCont 	:= 0
		nValBasNC	:= 0
		nValICMSST	:= 0

		cStrTxt += cRegistro
		cStrTxt += cAnoRefer //Ano de Referência
		cStrTxt += cMesRefer //Mês de Referência
		cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)

		If (cIndOper == "0")

			nValICMSST	:= FnBuscaValorCont('5',.T., cIndOper, cPeriodo, aArray[nPos,2], "000004", aFiliais)	//Valor de Outros Produtos
			nValMerc	:= aArray[nPos,4]

			cStrTxt += cCodUF          						//Código de UF
		 	cStrTxt += StrZero(nValMerc 	* 100	,12) 	//Valor Contábil
		 	cStrTxt += StrZero(nValBase   	* 100	,12)	//Valor da Base de Cálculo
	 		cStrTxt += StrZero(nValOutOpe 	* 100	,12) 	//Valor de Outras Operações
		 	cStrTxt += StrZero(0	,12) 						//Valor de Petróleo e Energia
		 	cStrTxt += StrZero(nValICMSST 	* 100	,12)   //Valor de Outros Produtos

			nValTMerc 	+= nValMerc
			nValTBase 	+= nValBase
			nValTOutOp	+= nValOutOpe
			nValTICMSS	+= nValICMSST

		Else 

			nValNC 	:= FnBuscaValorCont('1', .F., cIndOper, cPeriodo, aArray[nPos,2], aArray[nPos,3], aFiliais) 	//Valor Contábil Não Contribuinte
		 	nValCont 	:= FnBuscaValorCont('2', .T., cIndOper, cPeriodo, aArray[nPos,2], aArray[nPos,3], aFiliais) 	//Valor Contábil Contribuinte
		 	nValBasNC	:= FnBuscaValorCont('3', .F., cIndOper, cPeriodo, aArray[nPos,2], aArray[nPos,3], aFiliais) 	//Valor da Base de Cálculo Não Contribuinte
		 	nValBaseC	:= FnBuscaValorCont('4', .T., cIndOper, cPeriodo, aArray[nPos,2], aArray[nPos,3], aFiliais) 	//Valor da Base de Cálculo Contribuinte
		 	nValICMSST	:= FnBuscaValorCont('5', .T., cIndOper, cPeriodo, aArray[nPos,2], "000004"      , aFiliais)  	//Valor de Outros Produtos

		 	cStrTxt += cCodUF          						//Código de UF
		 	cStrTxt += StrZero(nValNC     * 100 ,12)		//Valor Contábil Não Contribuinte
		 	cStrTxt += StrZero(nValCont   * 100 ,12) 		//Valor Contábil Contribuinte
		 	cStrTxt += StrZero(nValBasNC  * 100 ,12) 		//Valor da Base de Cálculo Não Contribuinte
		 	cStrTxt += StrZero(nValBaseC  * 100 ,12)		//Valor da Base de Cálculo
	 		cStrTxt += StrZero(nValOutOpe * 100 ,12) 		//Valor de Outras Operações
	 		cStrTxt += StrZero(nValICMSST * 100 ,12) 		//Valor de Outros Produtos

			nValTNC 	+= nValNC
			nValTCont 	+= nValCont
			nValTBasNC	+= nValBasNC
			nValTBaseC	+= nValBaseC
			nValTOutOp	+= nValOutOpe
			nValTICMSS	+= nValICMSST

		EndIf
		cStrTxt += CRLF

	Next nPos

	If (cIndOper == "0")
		cStrTxt += cRegistro
		cStrTxt += cAnoRefer //Ano de Referência
		cStrTxt += cMesRefer //Mês de Referência
		cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
		cStrTxt += "ZZ"          						//Código de UF
		cStrTxt += StrZero(nValTMerc 	* 100	,12) 	//Valor Contábil
		cStrTxt += StrZero(nValTBase   	* 100	,12)	//Valor da Base de Cálculo
		cStrTxt += StrZero(nValTOutOp 	* 100	,12) 	//Valor de Outras Operações
		cStrTxt += StrZero(0	,12) 						//Valor de Petróleo e Energia
		cStrTxt += StrZero(nValTICMSS 	* 100	,12)   //Valor de Outros Produtos

	Else
		cStrTxt += cRegistro
		cStrTxt += cAnoRefer //Ano de Referência
		cStrTxt += cMesRefer //Mês de Referência
		cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)
		cStrTxt += "ZZ"         						//Código de UF
		cStrTxt += StrZero(nValTNC     * 100 ,12)		//Valor Contábil Não Contribuinte
		cStrTxt += StrZero(nValTCont   * 100 ,12) 		//Valor Contábil Contribuinte
		cStrTxt += StrZero(nValTBasNC  * 100 ,12) 		//Valor da Base de Cálculo Não Contribuinte
		cStrTxt += StrZero(nValTBaseC  * 100 ,12)		//Valor da Base de Cálculo
		cStrTxt += StrZero(nValTOutOp  * 100 ,12) 		//Valor de Outras Operações
		cStrTxt += StrZero(nValTICMSS  * 100 ,12) 		//Valor de Outros Produtos

	Endif
	cStrTxt += CRLF

	cFilAnt := cFilAux		

Return cStrTxt

Function FnBuscaValorCont(cTipo, lContrib, cIndOper, cPeriodo, cUF, cCODTRI, aFiliais)

	Local nValor 		:= 0
	Local cStrQuery 	:= ''
	Local cNovoAlias	:= GetNextAlias()
	Local cFilAux 		:= cFilAnt

	cFilAnt := aFiliais[1]

	// cTipo
	// 1 - //Valor Contábil Não Contribuinte
	// 2 - //Valor Contábil Contribuinte
	// 3 - //Valor da Base de Cálculo Não Contribuinte
	// 4 - //Valor da Base de Cálculo
	// 5 - //Valor de Outros Produtos ( ICMS ST)

	cStrQuery := " SELECT C20_CHVNF CHVNF, SUM(C2F_VLOPE) VLOPE, SUM(C2F_BASE) BASE, SUM(C2F_VALOR) VALOR "
	cStrQuery += "   FROM " +	RetSqlName('C20') + ' C20 ' + ', '
	cStrQuery += 				  	RetSqlName('C1H') + ' C1H ' + ', '
	cStrQuery += 			 		RetSqlName('C2F') + ' C2F '
	cStrQuery += "  WHERE C20.C20_FILIAL               	= '" + xFilial('C20') + "' "
	cStrQuery += "    AND C20.C20_INDOPE    		     	= '" + cIndOper + "' "
	cStrQuery += "    AND SUBSTRING(C20.C20_DTES,1,6) 	= '" + cPeriodo + "' "
	cStrQuery += "    AND C20.C20_CODPAR               	= C1H.C1H_ID "
	cStrQuery += "    AND C1H.C1H_FILIAL               	= '" + xFilial('C1H') + "' "
	cStrQuery += "    AND C1H_UF 			 			  	= '" + cUF     + "' "
	cStrQuery += "    AND C2F.C2F_FILIAL               	= '" + xFilial('C2F') + "' "
	cStrQuery += "    AND C2F.C2F_CHVNF                	= C20.C20_CHVNF "
	cStrQuery += "    AND C2F.C2F_CODTRI 		 		  	= '" + cCODTRI + "' "

	If (lContrib)
		cStrQuery += "    AND C1H.C1H_IE != ' ' AND C1H.C1H_IE != 'ISENTO' AND C1H.C1H_IE IS NOT NULL "
	Else //Não Contribuinte
		cStrQuery += "    AND (C1H.C1H_IE = ' ' OR C1H.C1H_IE = 'ISENTO' OR C1H.C1H_IE IS NULL) "
	EndIf

	cStrQuery += "    AND C20.D_E_L_E_T_ 	= '' "
	cStrQuery += "    AND C1H.D_E_L_E_T_ 	= '' "
	cStrQuery += "    AND C2F.D_E_L_E_T_ 	= '' "
	cStrQuery += "    GROUP BY C20_CHVNF "

	cStrQuery := ChangeQuery(cStrQuery)

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cNovoAlias,.T.,.T.)
	DbSelectArea(cNovoAlias)

	nValor := 0
	While (cNovoAlias)->(!Eof())

		If  cTipo == '1' .OR. cTipo == '2'
			nValor += (cNovoAlias)->VLOPE
		ElseIf cTipo == '5'
			nValor += (cNovoAlias)->VALOR
		Else
			nValor += (cNovoAlias)->BASE
		EndIf
		(cNovoAlias)->(DbSkip())
	EndDo

	cFilAnt := cFilAux

Return nValor
