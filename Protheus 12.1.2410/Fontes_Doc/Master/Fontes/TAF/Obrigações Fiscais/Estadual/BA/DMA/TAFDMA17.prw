#Include 'Protheus.ch'

Function TAFDMA17(aWizard as array, aFiliais as array, aArrayCpl as array)

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)

	Local nEmprg		:= 0
	Local nKWHConsum	:= 0
	Local nValCofins	:= 0
	Local nX 			:= 0

	Local cDataIni	:= ""
	Local cDataFim	:= ""

	IF (Len(aArrayCpl) == 0)
		Return
	EndIf

	cDataIni	:= Dtos(Lastday(CTOD("01/" + Substr(aWizard[1][2],1,2) + Substr(aWizard[1][2],3,5)) ,0))
	cDataFim	:= Dtos(Lastday(CTOD("01/" + aWizard[1][2]),0))

	//fnDMAReg17 1 - Código UF
	//fnDMAReg17 2 - Aliquota ICMS
	//fnDMAReg17 3 - CFOP
	//fnDMAReg17 4 - Período
	//fnDMAReg17 5 - Filial

	Begin Sequence
		IF aArrayCpl[1,1] != ""
		
			IMCSAlq7	:= fnDMAReg17("'000008','000012','000019','000020','000024','000025','000027'", "7", "'2551', '2552'", cDataIni, cDataFim, aFiliais)
			IMCSAlq12	:= fnDMAReg17("'000002','000003','000004','000006','000007','000010','000011','000013','000014','000015','000016','000017','000018','000021','000022','000023','000026','000028'", "12", "'2551', '2552'", cDataIni, cDataFim, aFiliais)
			IMCSAlq17	:= fnDMAReg17("", "17", "'1551','1552','3551'", cDataIni, cDataFim, aFiliais)
			IMCSCred7	:= fnDMAReg17("'000008','000012', '000019','000020','000024','000025','000027'", "7", "'2407','2556','2557'", cDataIni, cDataFim, aFiliais)
			IMCSCred12	:= fnDMAReg17("'000002','000003','000004','000006','000007','000010','000011','000013','000014','000015','000016','000017','000018','000021','000022','000023','000026','000028'", "12", "'2407','2556','2557'", cDataIni, cDataFim, aFiliais)

			For nX := 1 to Len(aArrayCpl)
				If  aArrayCpl[nX,1] == aFiliais[1]
					nEmprg 	 	:= VAL(aArrayCpl[nX,2])
					nValCofins	:= VAL(aArrayCpl[nX,3])
				EndIf
			Next

			nKWHConsum	 := fnDMAKHW(cDataIni, cDataFim, aFiliais)

			cStrTxt += "17"                          	// 	Tipo
			cStrTxt += Substr(cData,1,4) 		 		// 	Ano de Referência
			cStrTxt += Substr(cData,5,2) 		 		// 	Mês de Referência
			cStrTxt += StrZero(VAL( SubStr(AllTrim(aFiliais[5]),1,9)) ,9,0) //inscrição estadual BA (9c)

			cStrTxt += StrZero(nEmprg, 6)		//	Número de Empregados no último dia do mês
			cStrTxt += StrZero(nKWHConsum, 7)	//	KWH Consumidos no Período

			cStrTxt += StrZero(nValCofins	 * 100, 11)	//	Valor Recolhido a COFINS
			cStrTxt += StrZero(IMCSAlq7	   	 * 100, 12)	//	Valor ICMS creditado na compra e/ou transferência para o ativo procedente do Sul/sudeste alíquota 7 %
			cStrTxt += StrZero(IMCSAlq12   	 * 100, 12)	//	Valor ICMS creditado na compra e/ou transferência para o ativo procedente do norte/ne/c. oeste alíquota 12 %
			cStrTxt += StrZero(IMCSAlq17   	 * 100, 12)	//	Valor ICMS creditado na compra e/ou transferência para o ativo procedente do estado e exterior alíquota 17 %
			cStrTxt += StrZero(IMCSCred7   	 * 100, 12)	//	Valor ICMS creditado na compra e/ou transferência de material para uso ou consumo procedente do    sul/sudeste alíquota 7 %
			cStrTxt += StrZero(IMCSCred12  	 * 100, 12)	//	Valor ICMS creditado na compra e/ou transferência de material para uso ou consumo procedente do norte/ne/c. oeste alíquota 12 %
			cStrTxt += CRLF

			WrtStrTxt( nHandle, cStrTxt )
			GerTxtDMA( nHandle, cTxtSys, aFiliais[1] + "_TIPO17")
		EndIF

		Recover
		lFound := .F.
	End Sequence

Return

Static Function fnDMAReg17(cUF as char, cValAliq as char, cCfop as char, cDataIni as char, cDataFim as char, aFiliais as array)

Local cStrQuery	:= ""
Local cAlias1		:= GetNextAlias()
Local nRet := 0

	cStrQuery += " SELECT SUM(C2F_VALOR) VALOR  "
	cStrQuery += "   FROM " + 	RetSqlName('C20') + ' C20, '
	cStrQuery +=  		     	RetSqlName('C2F') + ' C2F, '
	cStrQuery +=  		     	RetSqlName('C1H') + ' C1H, '
	cStrQuery += 				RetSqlName('C0Y') + ' C0Y '
	cStrQuery += "  WHERE C20.C20_FILIAL  = '" + aFiliais[1] + "' "
	cStrQuery += "    AND C1H.C1H_FILIAL  = C20.C20_FILIAL "
	cStrQuery += "    AND C1H.C1H_ID      = C20.C20_CODPAR "

	If(cUF != "")
		cStrQuery += "    AND C1H.C1H_UF IN (" + cUF + ") "
	EndIf

	cStrQuery +=   "  AND C20.C20_DTES  BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"

	cStrQuery += "    AND C2F.C2F_FILIAL  = C20.C20_FILIAL "
	cStrQuery += "    AND C2F.C2F_CHVNF   = C20.C20_CHVNF  "
	cStrQuery += "    AND C2F.C2F_CODTRI  = '000002' "
	cStrQuery += "    AND C2F.C2F_ALIQ    = " + cValAliq

	cStrQuery += "    AND C0Y.C0Y_ID      = C2F.C2F_CFOP "
	cStrQuery += "    AND C0Y.C0Y_CODIGO  IN (" + cCfop + ") "

	cStrQuery += "    AND C20.D_E_L_E_T_  = '' "
	cStrQuery += "    AND C2F.D_E_L_E_T_  = '' "
	cStrQuery += "    AND C0Y.D_E_L_E_T_  = '' "
	cStrQuery += "    AND C1H.D_E_L_E_T_  = '' "

	cStrQuery := ChangeQuery(cStrQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias1,.T.,.T.)
	DbSelectArea(cAlias1)

	nRet := (cAlias1)->VALOR

	(cAlias1)->(DbCloseArea())

Return nRet

Static Function fnDMAKHW(cDataIni as char, cDataFim as char , aFiliais as array)

Local cStrQuery	:= ""
Local cAlias1		:= GetNextAlias()
Local nRet := 0

	cStrQuery += " SELECT SUM(C2E_CONS) CONSUM  "
	cStrQuery += "   FROM " + RetSqlName('C20') + ' C20, '
	cStrQuery +=  		      RetSqlName('C2E') + ' C2E '
	cStrQuery += "  WHERE C20.C20_FILIAL  			    = '" + aFiliais[1] + "' "
	cStrQuery += "    AND C20.C20_DTES  BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"

	cStrQuery += "    AND C2E.C2E_FILIAL  = C20.C20_FILIAL "
	cStrQuery += "    AND C2E.C2E_CHVNF   = C20.C20_CHVNF  "

	cStrQuery += "    AND C20.D_E_L_E_T_  = '' "
	cStrQuery += "    AND C2E.D_E_L_E_T_  = '' "

	cStrQuery := ChangeQuery(cStrQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cStrQuery),cAlias1,.T.,.T.)
	DbSelectArea(cAlias1)

	nRet := (cAlias1)->CONSUM

	(cAlias1)->(DbCloseArea())

Return nRet