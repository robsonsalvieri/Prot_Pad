#INCLUDE "PROTHEUS.CH"
#INCLUDE "FIVEWIN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PercReint ºAutor  ³Cecilia Carvalho    º Data ³ 21/05/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PER/DCOMP - geracao dos registros para Reintegra            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³PER/DCOMP                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PerdReint(aTRBs, aFilsCalc)
Local cAliasSFT	 := ""
Local cArqSft	 := ""
Local cExpDir	 := "7101/7105/7106/7127/7251/7301/7358/7551/7651/7654/7667/7504/7501"
Local cNCM		 := ""
Local cChave	 := ""
Local aArea		 := GetArea ()
Local aDev		 := {}
Local lHaReint	 := .F.
Local lIntECC	 := GetNewPar("MV_EECFAT",.F.)	//Integracao com SIGAEEC - EXPORTACAO
Local nPereint	 := SuperGetMV("MV_PEREINT",.T.,3)
Local cCnpjEmi	 := ""
Local cAnoMes	 := ""
Local cChvNFE	 := ""
Local cSerNF	 := ""
Local cRelNcm	 := ""
Local nForFilial := 0
Local cFilOri	 := cFilAnt
Local cTemp		 := GetNextAlias()		// Pega o proximo Alias Disponivel
Local dDtTrimIni := CToD("  /  /  ")
Local dDtTrimFim := CToD("  /  /  ")
Local cOrigNg	 := SuperGetMV('MV_ORIGNG',.F.,'3')
Local lComplem   := .F.
Local aNCM		 := {}
Local nAno		 := 0	
Local lDueavr 	 := EEC->(FieldPos("EEC_DUEAVR")) > 0
Local nX		 := 0
Local aStruSFT	 := {}
Local aBind      := {}
Local oPrepare   := nil
Local cQuery     := ""
Local nPos	     := 0
Local nPos2	     := 0

Default aTRBs := {}
Default aFilsCalc:= { { .T., cFilAnt } }

If !(Pergunte("PERDREINT",.T.))
	Return (.F.)
EndIf

If lAutomato
	MV_PAR01 := aWizAuto[1][1]
	MV_PAR03 := aWizAuto[1][3]
	MV_PAR04 := aWizAuto[1][4]
EndIf

nAno := MV_PAR03

aTRBs := PerdReiArq()

//Retorna os NCMs conforme informado no parametro MV_NCMNG
cRelNcm := NcmNoCon()

If mv_par04 == 1
	dDtTrimIni := cToD("01/01/"+Alltrim(STR(nAno)))
	dDtTrimFim := cToD("31/03/"+Alltrim(STR(nAno)))
ElseIf mv_par04 == 2
	dDtTrimIni := cToD("01/04/"+Alltrim(STR(nAno)))
	dDtTrimFim := cToD("30/06/"+Alltrim(STR(nAno)))
ElseIf mv_par04 == 3
	dDtTrimIni := cToD("01/07/"+Alltrim(STR(nAno)))
	dDtTrimFim := cToD("30/09/"+Alltrim(STR(nAno)))
Else
	dDtTrimIni := cToD("01/10/"+Alltrim(STR(nAno)))
	dDtTrimFim := cToD("31/12/"+Alltrim(STR(nAno)))
EndIf

For nForFilial := 1 to Len(aFilsCalc)
	If aFilsCalc[nForFilial, 1]
		cQuery := " "
		aBind  := {}
		aDev   := {}
		aNCM   := {}
		
		cFilAnt := aFilsCalc[ nForFilial, 2 ]
		ProcRegua(LastRec())

		aStruSFT  := SFT->(dbStruct())

		cQuery := "SELECT     "
		cQuery += "FT_TIPO,   "
		cQuery += "FT_FILIAL, "
		cQuery += "FT_NFISCAL,"
		cQuery += "FT_SERIE,  "
		cQuery += "FT_POSIPI, "
		cQuery += "FT_EMISSAO,"
		cQuery += "FT_CHVNFE, "
		cQuery += "FT_PRODUTO,"
		cQuery += "FT_CLIEFOR,"
		cQuery += "FT_LOJA,   "
		cQuery += "FT_CLASFIS,"
		cQuery += "FT_BSREIN, "
		cQuery += "FT_VREINT, "
		cQuery += "FT_CFOP,   "
		cQuery += "FT_ITEM,   "
		cQuery += "FT_DTCANC, "
		cQuery += "FT_ENTRADA,"

		//INTEGRAÇÃO COM O SIGAEEC
		If lIntECC
			If lDueavr
				cQuery += "EEC_PREEMB,"
				cQuery += "EEC_DUEAVR,"
				cQuery += "EEC_NRODUE,"
			EndIf
			
			cQuery += "EXL_DSE,   " 
			cQuery += "EE9_DTAVRB," 
			cQuery += "EE9_PREEMB,"
			cQuery += "EE9_RE,    "
			cQuery += "EE9_NRSD   "

			cQuery += "FROM " + RetSqlName("SD2") + " SD2"

			cQuery += " INNER JOIN " + RetSqlName("SFT") + " SFT "
			cQuery += " ON SFT.FT_FILIAL = ? "
			aAdd(aBind, xFilial("SFT"))
			cQuery += " AND SFT.FT_NFISCAL = SD2.D2_DOC "
			cQuery += " AND SFT.FT_SERIE = SD2.D2_SERIE "
			cQuery += " AND SFT.FT_CLIEFOR = SD2.D2_CLIENTE "
			cQuery += " AND SFT.FT_LOJA = SD2.D2_LOJA "
			cQuery += " AND SFT.FT_VREINT > ? "
			aAdd(aBind, 0)
			cQuery += " AND SFT.FT_DTCANC = ? "
			aAdd(aBind, Space(1))
			cQuery += " AND SFT.FT_PRODUTO = SD2.D2_COD "
			cQuery += " AND SFT.FT_ITEM = SD2.D2_ITEM " 
			cQuery += " AND SFT.D_E_L_E_T_ = ? "
			aAdd(aBind, Space(1))

			cQuery += " INNER JOIN " + RetSqlName("EE9") + " EE9 " 
			cQuery += " ON EE9.EE9_FILIAL = ? "
			aAdd(aBind, xFilial("EE9"))
			cQuery += " AND EE9.EE9_PREEMB = SD2.D2_PREEMB "
			cQuery += " AND EE9.EE9_NF = SD2.D2_DOC "
			cQuery += " AND EE9.EE9_SERIE = SD2.D2_SERIE "
			cQuery += " AND EE9.D_E_L_E_T_= ? "
			aAdd(aBind, Space(1))

			cQuery += " INNER JOIN " + RetSqlName("EE8") + " EE8 " 
			cQuery += " ON EE8.EE8_FILIAL = ? "
			aAdd(aBind, xFilial("EE8"))
			cQuery += " AND EE8.EE8_PEDIDO = EE9.EE9_PEDIDO "
			cQuery += " AND EE8.EE8_SEQUEN = EE9.EE9_SEQUEN "
			cQuery += " AND EE8.EE8_FATIT = SD2.D2_ITEMPV "
			cQuery += " AND EE8.D_E_L_E_T_= ? "
			aAdd(aBind, Space(1))

			cQuery += " LEFT JOIN " + RetSqlName("EXL") + " EXL "
			cQuery += " ON EXL.EXL_FILIAL = ? "
			aAdd(aBind, xFilial("EXL"))
			cQuery += " AND EXL.EXL_PREEMB = SD2.D2_PREEMB "
			cQuery += " AND EXL.D_E_L_E_T_= ? "
			aAdd(aBind, Space(1))

			If lDueavr
				cQuery += " LEFT JOIN "  + RetSqlName("EEC") + " EEC "
				cQuery += " ON EEC.EEC_FILIAL = ? "
				aAdd(aBind, xFilial("EEC"))
				cQuery += " AND SD2.D2_PREEMB = EEC.EEC_PREEMB "
				cQuery +=" AND EEC.D_E_L_E_T_ = ? "
				aAdd(aBind, Space(1))
			Endif

			cQuery += " WHERE SD2.D2_FILIAL= ? "
			aAdd(aBind, xFilial("SD2"))
			cQuery += " AND SD2.D2_CF IN (?) "
			aAdd(aBind, {'5501','5502','6501','6502','7101','7105','7106','7127','7251','7301','7358','7551','7651','7654','7667','7504','7501'})
			cQuery += " AND SD2.D2_PREEMB <> ? "
			aAdd(aBind, Space(1))
			cQuery += " AND SD2.D_E_L_E_T_ = ? "
			aAdd(aBind, Space(1))

		Else
			cQuery += " CDL_DOC,   "
			cQuery += " CDL_SERIE, "
			cQuery += " CDL_FILIAL," 
			cQuery += " CDL_DTAVB, "
			cQuery += " CDL_NRREG, "
			cQuery += " CDL_NUMDE, "
			cQuery += " CDL_INDDOC,"
			cQuery += " CDL_NATEXP "

			cQuery += "FROM " + RetSqlName("CDL") + " CDL"

			cQuery += " INNER JOIN "  + RetSqlName("SFT") + " SFT " 
			cQuery += " ON SFT.FT_FILIAL = ? "
			aAdd(aBind, xFilial("SFT"))
			cQuery += " AND SFT.FT_NFISCAL = CDL.CDL_DOC "
		    cQuery += " AND SFT.FT_SERIE = CDL.CDL_SERIE " 
			cQuery += " AND CDL.CDL_CLIENT = SFT.FT_CLIEFOR " 
			cQuery += " AND SFT.FT_LOJA = CDL.CDL_LOJA " 
			cQuery += " AND SFT.FT_ITEM = CDL.CDL_ITEMNF " 
			cQuery += " AND SFT.D_E_L_E_T_ = ? "
			aAdd(aBind, Space(1))	
			cQuery += " AND SFT.FT_CFOP IN (?) "
			aAdd(aBind, {'5501','5502','6501','6502','7101','7105','7106','7127','7251','7301','7358','7551','7651','7654','7667','7504','7501'})
			cQuery += " AND SFT.FT_VREINT > ? "
			aAdd(aBind, 0)
			cQuery += " AND SFT.FT_DTCANC = ? "
			aAdd(aBind, Space(1))

			cQuery += " WHERE CDL.CDL_FILIAL= ? "
			aAdd(aBind, xFilial("CDL"))
			cQuery += " AND CDL.D_E_L_E_T_ = ? "
			aAdd(aBind, Space(1))

		EndIf

		cQuery += " AND (SFT.FT_ENTRADA >= ? "
		aAdd(aBind, DTOS(dDtTrimIni))
		cQuery += " AND SFT.FT_ENTRADA <= ?) "
		aAdd(aBind, DTOS(dDtTrimFim))

		cQuery += " ORDER BY " + SqlOrder(SFT->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		PrepQry(cQuery, aBind , @cAliasSFT, oPrepare)

		For nX := 1 To len(aStruSFT)
			If aStruSFT[nX][2] <> "C"
				TcSetField(cAliasSFT,aStruSFT[nX][1],aStruSFT[nX][2],aStruSFT[nX][3],aStruSFT[nX][4])
			EndIf
		Next nX

		cQuery := " "
		aBind  := {}

		cQuery += " SELECT "
		cQuery += " SD1.D1_TIPO, "
		cQuery += " SD1.D1_NFORI, "
		cQuery += " SD1.D1_SERIORI "
		
		cQuery += " FROM " + RetSqlName("SD1") + " SD1"
		
		cQuery += " WHERE SD1.D1_FILIAL= ? "
		aAdd(aBind, xFilial("SD1"))
		cQuery += " AND SD1.D1_EMISSAO >= ? "
		aAdd(aBind, DTOS(dDtTrimIni))
		cQuery += " AND SD1.D1_EMISSAO <= ? "
		aAdd(aBind, DTOS(dDtTrimFim))
		cQuery += " AND SD1.D1_TIPO = ? "
		aAdd(aBind, 'D')
		cQuery += " AND SD1.D_E_L_E_T_ = ? "
		aAdd(aBind, Space(1))
		
		cQuery += " ORDER BY D1_FILIAL"
		
		cQuery := ChangeQuery(cQuery)

		PrepQry(cQuery, aBind , @cTemp, oPrepare)

		While !(cTemp)->(Eof ())
			aAdd(aDev,{(cTemp)->D1_TIPO, (cTemp)->D1_NFORI, (cTemp)->D1_SERIORI})
			(cTemp)->(dbSkip())
		EndDo
		(cTemp)->(DbCloseArea())

		SB1->(DbSetOrder(1))
		SA1->(DbSetOrder(1))
		SF2->(DbSetOrder(2))

		If !(cAliasSFT)->(Eof())
			cCnpjEmi := PerdReiCNPJ((cAliasSFT)->FT_FILIAL)
		EndIf

		While !(cAliasSFT)->(Eof())
			nPos	:=	aScan (aDev, {|x| x[2]==(cAliasSFT)->FT_NFISCAL .And. x[3]==(cAliasSFT)->FT_SERIE})
			nPos2	:=	aScan (aNCM, {|x| x[1]==(cAliasSFT)->FT_NFISCAL .And. x[2]==(cAliasSFT)->FT_SERIE .And. x[3]==(cAliasSFT)->FT_POSIPI})

			//Conforme parecer este registro não deve ser gerado para nota de complemento de Preço por não conter DE e RE # MSERV-3694
			lComplem := (cAliasSFT)->FT_TIPO $ 'C'

			If nPos2 == 0
				aAdd(aNCM,{(cAliasSFT)->FT_NFISCAL, (cAliasSFT)->FT_SERIE, (cAliasSFT)->FT_POSIPI})
			EndIf

			If npos==0
				cAnoMes	:= Substr(StrZero(Year((cAliasSFT)->FT_EMISSAO),4),3,2) + StrZero(Month((cAliasSFT)->FT_EMISSAO),2)
				cChvNFE	:= Replicate("0",44-Len(AllTrim((cAliasSFT)->FT_CHVNFE)))+AllTrim((cAliasSFT)->FT_CHVNFE)
				cSerNF		:= Replicate("0",3-Len(AllTrim((cAliasSFT)->FT_SERIE)))+AllTrim((cAliasSFT)->FT_SERIE)
				cNCM		:= ""

				//-- Valor Reintegra
				If (cAliasSFT)->FT_VREINT <= 0
					(cAliasSFT)->(dbSkip())
					Loop
				EndIf

				SB1->(MsSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
				SA1->(MsSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
				If !Empty((cAliasSFT)->FT_POSIPI)
					cNCM := (cAliasSFT)->FT_POSIPI
				Else
					If !Empty(SB1->B1_POSIPI)
						cNCM := SB1->B1_POSIPI
					EndIf
				EndIf
				//Verifica o NCM se deve ou não considerar no arquivo
				If Empty(cNCM) .Or. Alltrim(cNCM)$cRelNcm .Or. SubStr((cAliasSFT)->FT_CLASFIS,1,1) $ cOrigNg
					(cAliasSFT)->(dbSkip())
					Loop
				Endif

					//gravação do S28-Bens de Exportação
				If !lComplem	
					If !S28->(MsSeek(cNCM))
						lHaReint := .T.
								RecLock("S28",.T.)
								S28->CNPJDEC	:= MV_PAR01
								S28->CNPJSUC	:= MV_PAR02
								S28->ANOCRED	:= Alltrim(STR(MV_PAR03))
								S28->TRICRED	:= Alltrim(STR(MV_PAR04))
								S28->NCM		:= cNCM
								S28->BSREINT	:= (cAliasSFT)->FT_BSREIN
								S28->VLREINT	:= (cAliasSFT)->FT_VREINT			
					Else
						RecLock("S28",.F.)
						S28->BSREINT	+= (cAliasSFT)->FT_BSREIN
						S28->VLREINT	+= (cAliasSFT)->FT_VREINT
					EndIf
					MsUnlock()
           		EndIf
				cChave := cCnpjEmi + Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9) + Right(Strzero(Val((cAliasSFT)->FT_SERIE)),3)

			    If Alltrim((cAliasSFT)->FT_CFOP)$cExpDir
					//gravação do S29-Exportação Direta
					S29->(dbSetOrder(1))
					If !S29->(MsSeek(cChave))
							if !lComplem
								RecLock("S29",.T.)
								S29->CNPJDEC	:= MV_PAR01
								S29->CNPJSUC	:= MV_PAR02
								S29->CHVNFE	:= cChvNFE
								S29->CNPJEMI	:= cCnpjEmi
								S29->SERIE		:= cSerNF
								S29->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S29->ANOMES	:= cAnoMes
								S29->RESERVA	:= Space(12)
								S29->BSCALC	:= (cAliasSFT)->FT_BSREIN
								If SF2->(MsSeek(xFilial("SF2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))
									S29->VLTOTAL	:= SF2->F2_VALBRUT
								EndIf
							endif
					Else
						RecLock("S29",.F.)
						S29->BSCALC		+= (cAliasSFT)->FT_BSREIN
					EndIf
					MsUnlock()

					If lIntECC
						GeraTmpEEC(cAliasSFT,cChave,"30",lDueavr)
					Else
						If (cAliasSFT)->CDL_INDDOC=="0"
							//gravação do S30-declaração de exportação
							If !(S30->(MsSeek(cChave+ Substr(Alltrim((cAliasSFT)->CDL_NUMDE),1,11) + Strzero(VAL((cAliasSFT)->CDL_NRREG),12) ) ) ) .And. nPos2 == 0 .and. !lComplem
								RecLock("S30",.T.)
								S30->CNPJDEC	:= MV_PAR01
								S30->CNPJSUC	:= MV_PAR02
								S30->CHVNFE		:= cChvNFE
								S30->CNPJEMI	:= cCnpjEmi
								S30->SERIE		:= cSerNF
								S30->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S30->ANOMES		:= cAnoMes
								S30->REGEXP		:= Strzero(VAL(Alltrim((cAliasSFT)->CDL_NRREG)),12)
								S30->DECEXP		:= Substr(Alltrim((cAliasSFT)->CDL_NUMDE),1,11)
								MsUnlock()
							EndIf
						ElseIf (cAliasSFT)->CDL_INDDOC=="1"
							//gravação do S31-declaração simplificada de exportação
							If !S31->(MsSeek(cChave))
								RecLock("S31",.T.)
								S31->CNPJDEC	:= MV_PAR01
								S31->CNPJSUC	:= MV_PAR02
								S31->CHVNFE		:= cChvNFE
								S31->CNPJEMI	:= cCnpjEmi
								S31->SERIE		:= cSerNF
								S31->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S31->ANOMES		:= cAnoMes
								S31->RESERVA	:= Space(12)
								S31->DECSEXP	:= Substr(Alltrim((cAliasSFT)->CDL_NUMDE),1,11)
								MsUnlock()
							EndIf
						EndIf
					Endif
				Else
					//gravação do S32-Venda a Comercial Exportadora
					If lIntECC
						GeraTmpEEC(cAliasSFT,cChave,"32",lDueavr)
					Else					
						S32->(dbSetOrder(1))
						If !S32->(MsSeek(cChave))
							RecLock("S32",.T.)
							S32->CNPJDEC	:= MV_PAR01
							S32->CNPJSUC	:= MV_PAR02
							S32->CHVNFE		:= cChvNFE
							S32->CNPJEMI	:= cCnpjEmi
							S32->SERIE		:= cSerNF
							S32->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
							S32->ANOMES		:= cAnoMes
							S32->CNPJECE	:= SA1->A1_CGC
							S32->BSCALC		:= (cAliasSFT)->FT_BSREIN
							If SF2->(MsSeek(xFilial("SF2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))
								S32->VLTOTAL	:= SF2->F2_VALBRUT
							EndIf
						Else
							RecLock("S32",.F.)
							S32->BSCALC		:= (cAliasSFT)->FT_BSREIN
						EndIf
						MsUnlock()
					Endif

					If lIntECC
						GeraTmpEEC(cAliasSFT,cChave,"33",lDueavr)
					Else
						If (cAliasSFT)->CDL_INDDOC=="0"
							//gravação do S33-declaração de exportação
							If !S33->(MsSeek(cChave+Strzero(Val(Substr((cAliasSFT)->CDL_NUMDE,1,11)), 11)))
								RecLock("S33",.T.)
								S33->CNPJDEC	:= MV_PAR01
								S33->CNPJSUC	:= MV_PAR02
								S33->CHVNFE		:= cChvNFE
								S33->CNPJEMI	:= cCnpjEmi
								S33->SERIE		:= cSerNF
								S33->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S33->ANOMES		:= cAnoMes
								S33->REGEXP		:= Strzero(Val((cAliasSFT)->CDL_NRREG),12)
								S33->DECEXP		:= Strzero(Val(Substr((cAliasSFT)->CDL_NUMDE,1,11)), 11)
								MsUnlock()
							EndIf
						ElseIf (cAliasSFT)->CDL_INDDOC=="1"
							//gravação do S34-declaração simplificada de exportação
							If !S34->(MsSeek(cChave))
								RecLock("S34",.T.)
								S34->CNPJDEC	:= MV_PAR01
								S34->CNPJSUC	:= MV_PAR02
								S34->CHVNFE		:= cChvNFE
								S34->CNPJEMI	:= cCnpjEmi
								S34->SERIE		:= cSerNF
								S34->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S34->ANOMES		:= cAnoMes
								S34->RESERVA	:= Space(12)
								S34->DECSEXP	:= Strzero(Val(Substr((cAliasSFT)->CDL_NUMDE,1,11)), 11)
								MsUnlock()
							EndIf
						EndIf
					Endif
				EndIf

				If Alltrim((cAliasSFT)->FT_CFOP)$cExpDir	
					If lIntECC
						GeraTmpEEC(cAliasSFT,cChave,"39",lDueavr)
					Else
					//gravação do S39 - Declaração Única de Exportação - DUE
						If !S39->(MsSeek(cChave)) .and. !lComplem
							If (cAliasSFT)->CDL_NATEXP == "0" .and. (cAliasSFT)->CDL_INDDOC == "2" 
								RecLock("S39",.T.)
								S39->CNPJDEC	:= MV_PAR01
								S39->CNPJSUC	:= MV_PAR02
								S39->CHVNFE	    := cChvNFE
								S39->CNPJEMI	:= cCnpjEmi
								S39->SERIE		:= cSerNF
								S39->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S39->ANOMES	    := cAnoMes
								S39->RESERVA	:= Space(12)
								S39->DECEXP	    := (cAliasSFT)->CDL_NUMDE
								MsUnlock()	
							EndIf
						EndIf			
					Endif	
				Else
					If lIntECC
						GeraTmpEEC(cAliasSFT,cChave,"40",lDueavr)
					Else
						If (cAliasSFT)->CDL_NATEXP == "1" //gravação do S40 - Declaração Única de Exportação da ECE - DU-E/ECE
							If !S40->(MsSeek(cChave)) .and. !lComplem
								RecLock("S40",.T.)
								S40->CNPJDEC	:= MV_PAR01
								S40->CNPJSUC	:= MV_PAR02
								S40->CHVNFE	:= cChvNFE
								S40->CNPJEMI	:= cCnpjEmi
								S40->SERIE		:= cSerNF
								S40->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
								S40->ANOMES	:= cAnoMes
								S40->RESERVA	:= Space(12)
								S40->DECEXP	:= (cAliasSFT)->CDL_NUMDE
								MsUnlock()
							EndIf
						EndIf	
					Endif	
				EndIf
			EndIf	
			(cAliasSFT)->(dbSkip())
		Enddo
		(cAliasSFT)->(DbCloseArea ())

		dbSelectArea("S28")
		S28->(DbGoTop())
		Do While !S28->(Eof())
			RecLock("S28",.F.)
			S28->VLREINT	:= NoRound((S28->BSREINT * (nPereint/100)), 2)
			MsUnlock()
			S28->(DbSkip())
		EndDo

		RetIndex ("SFT")
		Ferase (cArqSft+SFT->(OrdBagExt ()))
		SFT->(DbClearFilter ())
	EndIf
Next

cFilAnt := cFilOri
RestArea (aArea)

Return(lHaReint)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PerdReiArq ³ Autor ³ Cecilia Carvalho     ³ Data ³ 21.05.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera arquivos temporarios                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function PerdReiArq()
Local aTRBs		:= {} 
Local aStruS28	:= {}	
Local aStruS29	:= {}  
Local aStruS30	:= {}
Local aStruS31	:= {}
Local aStruS32	:= {}
Local aStruS33	:= {}                     
Local aStruS34	:= {}   
Local aStruS39	:= {}
Local aStruS40	:= {}
Local cArqS28	:= ""
Local cArqS29	:= ""
Local cArqS30	:= ""
Local cArqS31	:= ""
Local cArqS32	:= ""
Local cArqS33	:= ""
Local cArqS34	:= ""
Local cArqS39	:= ""
Local cArqS40	:= ""
Local cArqInd	:= ""

//Bens Exportados - Registro S28     
AADD(aStruS28,{"CNPJDEC","C",014,0})
AADD(aStruS28,{"CNPJSUC","C",014,0})
AADD(aStruS28,{"ANOCRED","C",004,0})
AADD(aStruS28,{"TRICRED","C",001,0})                        
AADD(aStruS28,{"NCM"   	,"C",008,0})
AADD(aStruS28,{"BSREINT","N",014,2})
AADD(aStruS28,{"VLREINT","N",014,2})
cArqS28	:=	CriaTrab(aStruS28)
dbUseArea(.T.,,cArqS28,"S28",.T.,.F.)  
cArqInd  := CriaTrab(NIL,.F.)
IndRegua("S28",cArqS28,"NCM")
aAdd(aTRBs,{cArqS28,"S28"})

//NF de Exportação Direta    
AADD(aStruS29,{"CNPJDEC","C",014,0})
AADD(aStruS29,{"CNPJSUC","C",014,0})
AADD(aStruS29,{"CHVNFE","C",044,0})
AADD(aStruS29,{"CNPJEMI","C",014,0})
AADD(aStruS29,{"SERIE"	,"C",003,0})
AADD(aStruS29,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS29,{"ANOMES","C",004,0})
AADD(aStruS29,{"RESERVA","C",014,0})
AADD(aStruS29,{"VLTOTAL","N",014,2})
AADD(aStruS29,{"BSCALC"	,"N",014,2})
cArqS29	:=	CriaTrab(aStruS29)
dbUseArea(.T.,,cArqS29,"S29",.T.,.F.)     
cArqInd  := CriaTrab(NIL,.F.)
IndRegua("S29",cArqS29,"CNPJEMI+NFISCAL+SERIE") 
aAdd(aTRBs,{cArqS29,"S29"})

//Declaração de Exportação Direta - DE
AADD(aStruS30,{"CNPJDEC","C",014,0})
AADD(aStruS30,{"CNPJSUC","C",014,0})
AADD(aStruS30,{"CHVNFE","C",044,0})
AADD(aStruS30,{"CNPJEMI","C",014,0})
AADD(aStruS30,{"SERIE"	,"C",003,0})
AADD(aStruS30,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS30,{"ANOMES","C",004,0})
AADD(aStruS30,{"REGEXP","C",012,0})
AADD(aStruS30,{"DECEXP","C",011,0})
cArqS30	:=	CriaTrab(aStruS30)
dbUseArea(.T.,__LocalDriver,cArqS30,"S30")
IndRegua("S30",cArqS30,"CNPJEMI+NFISCAL+SERIE+DECEXP+REGEXP") 
aAdd(aTRBs,{cArqS30,"S30"})                       

//Declaração Simplificada de Exportação Direta - DSE
AADD(aStruS31,{"CNPJDEC","C",014,0})
AADD(aStruS31,{"CNPJSUC","C",014,0})
AADD(aStruS31,{"CHVNFE","C",044,0})
AADD(aStruS31,{"CNPJEMI","C",014,0})
AADD(aStruS31,{"SERIE"	,"C",003,0})
AADD(aStruS31,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS31,{"ANOMES","C",004,0})
AADD(aStruS31,{"RESERVA","C",012,0})
AADD(aStruS31,{"DECSEXP","C",011,0})
cArqS31	:=	CriaTrab(aStruS31)
dbUseArea(.T.,__LocalDriver,cArqS31,"S31")
IndRegua("S31",cArqS31,"CNPJEMI+NFISCAL+SERIE") 
aAdd(aTRBs,{cArqS31,"S31"})                   
                                      
//NF de Venda a Empresa Comercial Exportadora
AADD(aStruS32,{"CNPJDEC","C",014,0})
AADD(aStruS32,{"CNPJSUC","C",014,0})
AADD(aStruS32,{"CHVNFE","C",044,0})
AADD(aStruS32,{"CNPJEMI","C",014,0})
AADD(aStruS32,{"SERIE"	,"C",003,0})
AADD(aStruS32,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS32,{"ANOMES","C",004,0})
AADD(aStruS32,{"CNPJECE","C",014,0})
AADD(aStruS32,{"VLTOTAL","N",014,2})
AADD(aStruS32,{"BSCALC"	,"N",014,2})
cArqS32	:=	CriaTrab(aStruS32)
dbUseArea(.T.,__LocalDriver,cArqS32,"S32")
IndRegua("S32",cArqS32,"CNPJEMI+NFISCAL+SERIE") 
aAdd(aTRBs,{cArqS32,"S32"})

//Declaração de Exportação da ECE
AADD(aStruS33,{"CNPJDEC","C",014,0})
AADD(aStruS33,{"CNPJSUC","C",014,0})
AADD(aStruS33,{"CHVNFE","C",044,0})
AADD(aStruS33,{"CNPJEMI","C",014,0})
AADD(aStruS33,{"SERIE"	,"C",003,0})
AADD(aStruS33,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS33,{"ANOMES","C",004,0})
AADD(aStruS33,{"REGEXP","C",012,0})
AADD(aStruS33,{"DECEXP","C",011,0})
cArqS33	:=	CriaTrab(aStruS33)
dbUseArea(.T.,__LocalDriver,cArqS33,"S33")
IndRegua("S33",cArqS33,"CNPJEMI+NFISCAL+SERIE+DECEXP") 
aAdd(aTRBs,{cArqS33,"S33"})

//Declaração Simplificada de Exportação da ECE   
AADD(aStruS34,{"CNPJDEC","C",014,0})
AADD(aStruS34,{"CNPJSUC","C",014,0})
AADD(aStruS34,{"CHVNFE","C",044,0})
AADD(aStruS34,{"CNPJEMI","C",014,0})
AADD(aStruS34,{"SERIE"	,"C",003,0})
AADD(aStruS34,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS34,{"ANOMES","C",004,0})
AADD(aStruS34,{"RESERVA","C",012,0})
AADD(aStruS34,{"DECSEXP","C",011,0})
cArqS34	:=	CriaTrab(aStruS34)
dbUseArea(.T.,__LocalDriver,cArqS34,"S34")
IndRegua("S34",cArqS34,"CNPJEMI+NFISCAL+SERIE") 
aAdd(aTRBs,{cArqS34,"S34"})       


//Declaração Única de Exportação - DUE   
AADD(aStruS39,{"CNPJDEC","C",014,0})
AADD(aStruS39,{"CNPJSUC","C",014,0})
AADD(aStruS39,{"CHVNFE","C",044,0})
AADD(aStruS39,{"CNPJEMI","C",014,0})
AADD(aStruS39,{"SERIE"	,"C",003,0})
AADD(aStruS39,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS39,{"ANOMES","C",004,0})
AADD(aStruS39,{"RESERVA","C",012,0})
AADD(aStruS39,{"DECEXP","C",014,0})
cArqS39	:=	CriaTrab(aStruS39)
dbUseArea(.T.,__LocalDriver,cArqS39,"S39")
IndRegua("S39",cArqS39,"CNPJEMI+NFISCAL+SERIE+DECEXP") 
aAdd(aTRBs,{cArqS39,"S39"})      

//Declaração Única de Exportação da ECE - DU-E/ECE 
AADD(aStruS40,{"CNPJDEC","C",014,0})
AADD(aStruS40,{"CNPJSUC","C",014,0})
AADD(aStruS40,{"CHVNFE","C",044,0})
AADD(aStruS40,{"CNPJEMI","C",014,0})
AADD(aStruS40,{"SERIE"	,"C",003,0})
AADD(aStruS40,{"NFISCAL","C",TamSX3("FT_NFISCAL")[1],0})
AADD(aStruS40,{"ANOMES","C",004,0})
AADD(aStruS40,{"RESERVA","C",012,0})
AADD(aStruS40,{"DECEXP","C",014,0})
cArqS40	:=	CriaTrab(aStruS40)
dbUseArea(.T.,__LocalDriver,cArqS40,"S40")
IndRegua("S40",cArqS40,"CNPJEMI+NFISCAL+SERIE") 
aAdd(aTRBs,{cArqS40,"S40"})   

Return(aTRBs)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³PerdReiDel ºAutor  ³ Cecilia Carvalho   º Data ³ 21/05/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³Apaga os arquivos temporarios criados para a rotina.         º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³PER/DCOMP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PerdReiDel(aDelArqs)
Local aAreaDel	:= GetArea()
Local nI 		:= 0

For nI:= 1 To Len(aDelArqs)
	If File(aDelArqs[ni,1]+GetDBExtension())
		dbSelectArea(aDelArqs[ni,2])
		dbCloseArea()
		Ferase(aDelArqs[ni,1]+GetDBExtension())
		Ferase(aDelArqs[ni,1]+OrdBagExt())
	Endif	
Next
RestArea(aAreaDel)
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³RetorData ³ Autor ³ Cecilia Carvalho      ³ Data ³ 24.05.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna data no formato DDMMAAAAA                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function RetorData(cData)
Local cDtRet := ""      
                   
cData := Dtos(cData)
cDtRet := Substr(cData,7,2)+Substr(cData,5,2)+Substr(cData,1,4)                     
Return (cDtRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraTmpECC³ Autor ³ Mauro A. Gonçalves    ³ Data ³ 16.09.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera a tabela temporaria dos registros S30, S31, S33 e S34  ³±±
±±³			 ³de operações realizadas no SIGAEEC                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function GeraTmpEEC(cAliasSFT,cChave,cTipReg,lDueav)
Local cNroRE		:=	""
Local cNroDE		:=	""
Local cNroDSE		:=	""
Local cNroDUE		:=  ""
Local nPos			:= 0
Local cCnpjEmi		:= ""
Local cAnoMes		:= ""
Local cChvNFE   	:= ""
Local cSerNF		:= ""

If lDueav
	If !Empty((cAliasSFT)->EEC_NRODUE)
		cNroDUE := (cAliasSFT)->EEC_NRODUE  //Declaração Única de Exportação
	Else
		cNroRE		:= (cAliasSFT)->EE9_RE  	//Registro de Exportacao
		cNroDE		:= (cAliasSFT)->EE9_NRSD 	//Declaracao de Exportacao
		If (nPos := AT("/",cNroDE)) > 0
			cNroDE := Left(Alltrim(Substr(cNroDE,1,nPos-1)+Substr(cNroDE,nPos+1,Len(cNroDE))),11)
		Endif
	Endif
Else
	cNroRE		:= (cAliasSFT)->EE9_RE  	//Registro de Exportacao
	cNroDE		:= (cAliasSFT)->EE9_NRSD 	//Declaracao de Exportacao
	If (nPos := AT("/",cNroDE)) > 0
		cNroDE := Left(Alltrim(Substr(cNroDE,1,nPos-1)+Substr(cNroDE,nPos+1,Len(cNroDE))),11)
	Endif
Endif
cAnoMes	:= Substr(StrZero(Year((cAliasSFT)->FT_EMISSAO),4),3,2) + StrZero(Month((cAliasSFT)->FT_EMISSAO),2)
cChvNFE 	:= Replicate("0",44-Len(AllTrim((cAliasSFT)->FT_CHVNFE)))+AllTrim((cAliasSFT)->FT_CHVNFE)
cSerNF		:= Replicate("0",3-Len(AllTrim((cAliasSFT)->FT_SERIE)))+AllTrim((cAliasSFT)->FT_SERIE)
cCnpjEmi	:= PerdReiCNPJ((cAliasSFT)->FT_FILIAL)
		
cNroDSE := Left(Alltrim((cAliasSFT)->EXL_DSE),11)		//Declaracao simplificada de Exportacao
//Grava temporaria
If cTipReg=="30" //gravação do S30-declaração de exportação
	If !Empty(cNroRE)
		If !S30->(MsSeek(cChave+Right(Strzero(Val(cNroDE)),11)+Right(Strzero(Val(cNroRE)),12)))
			RecLock("S30",.T.)
			S30->CNPJDEC	:= MV_PAR01
			S30->CNPJSUC	:= MV_PAR02
			S30->CHVNFE		:= cChvNFE
			S30->CNPJEMI	:= cCnpjEmi
			S30->SERIE		:= cSerNF
			S30->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S30->ANOMES		:= cAnoMes
			S30->REGEXP		:= Right(Strzero(Val(cNroRE)),12)
			S30->DECEXP		:= Right(Strzero(Val(cNroDE)),11)
			MsUnlock()
		EndIf  
	EndIf  
	If !Empty(cNroDSE) //gravação do S31-declaração simplificada de exportação
		If !S31->(MsSeek(cChave))
			RecLock("S31",.T.)
			S31->CNPJDEC	:= MV_PAR01
			S31->CNPJSUC	:= MV_PAR02
			S31->CHVNFE		:= cChvNFE
			S31->CNPJEMI	:= cCnpjEmi
			S31->SERIE		:= cSerNF
			S31->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S31->ANOMES		:= cAnoMes
			S31->RESERVA	:= Space(12)
			S31->DECSEXP	:= Right(Strzero(Val(cNroDSE)),11)
			MsUnlock()
		EndIf
	EndIf
ElseIf cTipReg=="33"	//gravação do S33-declaração de exportação
	If !Empty(cNroRE)
		If !S33->(MsSeek(cChave))
			RecLock("S33",.T.)
			S33->CNPJDEC	:= MV_PAR01
			S33->CNPJSUC	:= MV_PAR02
			S33->CHVNFE		:= cChvNFE
			S33->CNPJEMI	:= cCnpjEmi
			S33->SERIE		:= cSerNF
			S33->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S33->ANOMES		:= cAnoMes
			S33->REGEXP		:= Right(Strzero(Val(cNroRE)),12)
			S33->DECEXP		:= Right(Strzero(Val(cNroDE)),11)
			MsUnlock()
		EndIf
	EndIf
	If !Empty(cNroDSE) //gravação do S34-declaração simplificada de exportação						
		If !S34->(MsSeek(cChave))
			RecLock("S34",.T.)
			S34->CNPJDEC	:= MV_PAR01
			S34->CNPJSUC	:= MV_PAR02
			S34->CHVNFE		:= cChvNFE
			S34->CNPJEMI 	 := cCnpjEmi
			S34->SERIE		:= cSerNF
			S34->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S34->ANOMES		:= cAnoMes
			S34->RESERVA	:= Space(12)
			S34->DECSEXP	:= Right(Strzero(Val(cNroDSE)),11)
			MsUnlock()
		EndIf
	EndIf
EndIf	
	
If cTipReg=="32" //Ficha Notas Fiscais de Venda a Empresa Comercial Exportadora	
	If !S32->(MsSeek(cChave))
		RecLock("S32",.T.)
		S32->CNPJDEC	:= MV_PAR01
		S32->CNPJSUC	:= MV_PAR02
		S32->CHVNFE		:= cChvNFE
		S32->CNPJEMI	:= cCnpjEmi
		S32->SERIE		:= cSerNF
		S32->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
		S32->ANOMES		:= cAnoMes
		S32->CNPJECE	:= SA1->A1_CGC
		S32->BSCALC		:= (cAliasSFT)->FT_BSREIN
		If SF2->(MsSeek(xFilial("SF2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE))
			S32->VLTOTAL	:= SF2->F2_VALBRUT
		EndIf
	Else
		RecLock("S32",.F.)
		S32->BSCALC		:= (cAliasSFT)->FT_BSREIN
	EndIf
	MsUnlock()
EndIf
		
If cTipReg=="39" //gravação do S39 - Declaração Única de Exportação - DUE
	If !Empty(cNroDUE)
		If !S39->(MsSeek(cChave))
			RecLock("S39",.T.)
			S39->CNPJDEC	:= MV_PAR01
			S39->CNPJSUC	:= MV_PAR02
			S39->CHVNFE		:= cChvNFE
			S39->CNPJEMI 	:= cCnpjEmi
			S39->SERIE		:= cSerNF
			S39->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S39->ANOMES		:= cAnoMes
			S39->RESERVA	:= Space(12)
			S39->DECEXP		:= cNroDUE
			MsUnlock()
		EndIF
	EndIf
Elseif cTipReg=="40" //gravação do S40 - Declaração Única de Exportação da ECE - DU-E/ECE	
	If !Empty(cNroDUE)
		If !S40->(MsSeek(cChave))
			RecLock("S40",.T.)
			S40->CNPJDEC	:= MV_PAR01
			S40->CNPJSUC	:= MV_PAR02
			S40->CHVNFE		:= cChvNFE
			S40->CNPJEMI 	:= cCnpjEmi
			S40->SERIE		:= cSerNF
			S40->NFISCAL	:= Right(Strzero(Val((cAliasSFT)->FT_NFISCAL)),9)
			S40->ANOMES		:= cAnoMes
			S40->RESERVA	:= Space(12)
			S40->DECEXP		:= cNroDUE
			MsUnlock()
		EndIF
	EndIf	
EndIf	



Return .T.

Static Function PerdReiCNPJ(cxFilial)

Local cCNPJ	 := ""
Local aArea 	 := GetArea()
Local aAreaSM0:= SM0->(GetArea())

//Posicionando empresa para inicio do processamento
dbSelectArea( "SM0" )
If Alltrim(cxFilial) == ""
	cxFilial := FWCodFil()
EndIF
If MsSeek( cEmpAnt + cxFilial)
	cCNPJ := SM0->M0_CGC
EndIf

RestArea(aAreaSM0)
RestArea(aArea)

Return(cCNPJ)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³NcmNoCon³ Autor ³  Jorge Souza   ³ Data ³ 20.04.2015 ³      ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Permite a criação de mais patrametros utilizando a raiz     ³±±
±±³			   ³MV_NCMNG                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function NcmNoCon()

Local cNcms := ""
Local cPar 	 := "MV_NCMNG"

//Leitura exclusiva 
If SX6->(DbSeek (cFilAnt+cPar)) 
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. (cFilAnt==SX6->X6_FIL) 
		If !Empty(SX6->X6_CONTEUD) 
			cNcms += "/"+AllTrim (SX6->X6_CONTEUD) 
		EndIf 
	SX6->(DbSkip ()) 
	EndDo 
EndIf 

//Leitura Compartilhada 
If SX6->(DbSeek (PadR("",FWGETTAMFILIAL)+cPar)) 
	Do While !SX6->(Eof ()) .And. (cPar$SX6->X6_VAR) .And. Empty(SX6->X6_FIL) 
		If !Empty(SX6->X6_CONTEUD) 
			cNcms += "/"+AllTrim (SX6->X6_CONTEUD) 
		EndIf 
	SX6->(DbSkip ()) 
	EndDo 
EndIf

Return cNcms

//-----------------------------------------------------------------
/*/{Protheus.doc} PrepQry
Função responsavel por preparar a query com o FwExecStatement

@param cQuery 	- Query pré-preparada com os "?" ja inclusos na query.
@param Array  	- Array com os valores para substituição na query.
@param cAlias 	- Alias para criação
@param oPrepare - Objeto FwExecStatement para preparação da query

@Return Nil
@author Wesley Matos
@since 08/10/2025
@version 1.0
/*/
//------------------------------------------------------------------
Static Function PrepQry(cQuery, aBind, cAlias, oPrepare)
Local nI		 := 0
Local cTypeBind  := ''

oPrepare  := FwExecStatement():New( cQuery )

For nI := 1 To Len(aBind)
	cTypeBind := Valtype(aBind[nI])
	If cTypeBind == 'C'
		oPrepare:setString( nI, aBind[nI] )
	ElseIf cTypeBind == 'N'
		oPrepare:setNumeric( nI, aBind[nI] )
	ElseIf cTypeBind == 'A'
		oPrepare:setIn( nI, aBind[nI] )
	Endif
Next nI

cAlias := oPrepare:OpenAlias()

If oPrepare != Nil
	oPrepare:Destroy()
	freeObj(oPrepare)
	oPrepare := Nil
EndIf

Return
