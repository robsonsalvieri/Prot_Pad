#INCLUDE "PROTHEUS.CH"
// u_WMSUsaCalc()
User Function WMSUsaCalc()
Local oProcess := Nil

	If !SuperGetMV("MV_WMSNEW",.F.,.F.)
		WmsMessage("Update exclusivo para o Novo WMS!")
		Return Nil
	EndIf

	If D13->(FieldPos("D13_USACAL")) <= 0
		WmsMessage("Não existe o campo D13_USACAL para realizar o ajuste das movimentações, aplique a atualização!")
		Return Nil
	EndIf

	If WmsQuestion("Esta rotina irá, em uma primeira etapa, deletar registros da tabela DCR que estão duplicados e também separar as movimentações do Kardex " + ;
		"D13 dos documentos que foram aglutinados e estornados. Em uma segunda etapa, a rotina irá preencher o campo D13_USACAL das movimentações estornadas " + ;
		"que não possuem o documento origem (SD1,SD2,SD3) com valor '2=Não'. " + ;
		"Exemplo: Entradas SD1 que foram excluídas. As movimentações do kardex não devem ser consideradas no cálculo do saldo por endereço." + CRLF + CRLF + ;
		"Serão processados também as movimentações SD3 de desmontagem que estão com o valor do campo D3_CHAVE inconsistentes para o cálculo do custo médio," + ;
		" bem como atribuir devidamente o valor do campo D3_NUMSEQ para este tipo de documento." + CRLF + CRLF + ;
		"Serão processadas as movimentações por mês, maiores que o último fechamento: " + DTOC(GetMv("MV_ULMES")))
		oProcess := MsNewProcess():New( { || ProcMovs(oProcess)  }, "Processando movimentos", "Aguarde...", .F. ) // Distribuição // Aguarde, distribuindo...
		oProcess:Activate()
	EndIf
Return Nil

Static Function ProcMovs(oProcess)
Local aAreaAnt := GetArea()
Local aRelacao := {}
Local aTamSx3 := TamSx3("DCR_QUANT")
Local cQuery := ""
Local cAliasQ1 := ""
Local cAliasQ2 := ""
Local cIdDCFAnt := ""
Local cIdOri := ""
Local cIdDCF := ""
Local cIdMov := ""
Local nQuant := ""
Local cIdOper := ""
Local cMovAnt := ""
Local cDoc := ""
Local cSDoc := ""
Local cSerie := ""
Local cCliFor := ""
Local cLoja := ""
Local cNumSeq := ""
Local cTmOri := ""
Local cLocOri := ""
Local cEndOri := ""
Local cTmDes := ""
Local cLocDes := ""
Local cEndDes := ""
Local nRecMov := 0
Local nRecM := 0
Local nCountD13 := 0
Local nCountSD3 := 0
Local nMes := 0
Local nAno := 0
Local nI := 0
Local nY := 0
Local nPos := 0
Local nRecnoDCR := 0
Local nMovimento := 0
Local nTime := 0
Local cDateIni := Date()
Local cTimeIni := Time()
Local dDtIniProc := Nil
Local dDtFimProc := Nil
Local lFim := .F.
Local lRet := .T.
Local cUlMes := DtoS(GetMv("MV_ULMES"))

	/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 Busca todas as movimentações que tem o kardex diferente da movimentação 
	 D12 com origem SD1, caracterizando uma aglutinação que houve estorno
	------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
	cQuery := " SELECT D12.D12_IDDCF,"
	cQuery +=        " D12.D12_IDMOV,"
	cQuery +=        " D12.D12_IDOPER,"
	cQuery +=        " D12.D12_QTDMOV,"
	cQuery +=        " D13.D13_QTDEST,"
	cQuery +=        " D13.R_E_C_N_O_ RECNOD13,"
	cQuery +=        " D13B.R_E_C_N_O_ RECNOD13B"
	cQuery +=   " FROM "+RetSqlName("D12")+" D12"
	cQuery +=  " INNER JOIN "+RetSqlName("D13")+" D13"
	cQuery +=     " ON D13.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=    " AND D13.D13_IDDCF = D12.D12_IDDCF"
	cQuery +=    " AND D13.D13_IDMOV = D12.D12_IDMOV"
	cQuery +=    " AND D13.D13_IDOPER = D12.D12_IDOPER"
	cQuery +=    " AND D13.D13_LOCAL = D12.D12_LOCORI"
	cQuery +=    " AND D13.D13_ENDER = D12.D12_ENDORI"
	cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
	cQuery +=  " INNER JOIN "+RetSqlName("D13")+" D13B"
	cQuery +=     " ON D13B.D13_FILIAL = '"+xFilial("D13")+"'"
	cQuery +=    " AND D13B.D13_IDDCF = D12.D12_IDDCF"
	cQuery +=    " AND D13B.D13_IDMOV = D12.D12_IDMOV"
	cQuery +=    " AND D13B.D13_IDOPER = D12.D12_IDOPER"
	cQuery +=    " AND D13B.D13_LOCAL = D12.D12_LOCDES"
	cQuery +=    " AND D13B.D13_ENDER = D12.D12_ENDDES"
	cQuery +=    " AND D13B.D_E_L_E_T_ = ' '"
	cQuery +=  " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
	cQuery +=    " AND D12.D12_QTDMOV < D13.D13_QTDEST"
	cQuery +=    " AND D12.D12_DTGERA >= '"+cUlMes+"'"
	cQuery +=    " AND D12.D12_ORIGEM <> 'SC9'"
	cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasQ1 := GetNextAlias()
	dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

	nRecMov := 0
	nRecM := 0
	(cAliasQ1)->(dbEval({|| nRecMov++ }))
	oProcess:SetRegua1(nRecMov)

	(cAliasQ1)->(dbGoTop())

	Do While (cAliasQ1)->(!Eof())
		nRecM++
		oProcess:IncRegua1( "Ajuste DCR e D13: " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )

		oProcess:SetRegua2(4)
		oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

		Begin Transaction

		// Busca todas as DCR do movimento para deletar os registro duplicados
		cQuery := " SELECT DCR.DCR_IDORI,"
		cQuery +=        " DCR.DCR_IDDCF,"
		cQuery +=        " DCR.DCR_IDMOV,"
		cQuery +=        " DCR.DCR_QUANT,"
		cQuery +=        " DCR.DCR_IDOPER,"
		cQuery +=        " DCR.R_E_C_N_O_ RECNODCR,"
		cQuery +=        " D12.D12_DOC,"
		cQuery +=        " D12.D12_SDOC,"
		cQuery +=        " D12.D12_SERIE,"
		cQuery +=        " D12.D12_CLIFOR,"
		cQuery +=        " D12.D12_LOJA,"
		cQuery +=        " D12.D12_NUMSEQ"
		cQuery +=   " FROM "+RetSqlName("DCR")+" DCR"
		cQuery +=  " INNER JOIN "+RetSqlName("D12")+" D12"
		cQuery +=     " ON D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=    " AND D12.D12_IDDCF = DCR.DCR_IDORI"
		cQuery +=    " AND D12.D12_IDMOV = DCR.DCR_IDMOV"
		cQuery +=    " AND D12.D12_IDOPER = DCR.DCR_IDOPER"
		cQuery +=    " AND D12.D12_SEQUEN = DCR.DCR_SEQUEN"
		cQuery +=    " AND D12.D12_ATUEST = '1'"
		cQuery +=    " AND D12.D_E_L_E_T_ = ' '"
		cQuery +=  " WHERE DCR.DCR_FILIAL = '"+xFilial("DCR")+"'"
		cQuery +=    " AND DCR.DCR_IDMOV = '"+(cAliasQ1)->D12_IDMOV+"'"
		cQuery +=    " AND DCR.D_E_L_E_T_ = ' '"
		cQuery +=  " ORDER BY DCR.R_E_C_N_O_ DESC"
		cQuery := ChangeQuery(cQuery)
		cAliasQ2 := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",tcGenQry(,,cQuery),cAliasQ2,.F.,.T.)
		TCSetField(cAliasQ2,"DCR_QUANT","N",aTamSx3[1],aTamSx3[2])

		If (cAliasQ2)->(!Eof())
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
			aRelacao := {}
			nTime := 0
			(cAliasQ2)->(dbEval({|| aAdd(aRelacao,{DCR_IDORI,DCR_IDDCF,DCR_IDMOV,DCR_QUANT,DCR_IDOPER,RECNODCR,D12_DOC,D12_SDOC,D12_SERIE,D12_CLIFOR,D12_LOJA,D12_NUMSEQ}) }))
			(cAliasQ2)->(dbCloseArea())

			For nI := 1 To Len(aRelacao)
				If nI > Len(aRelacao)
					Exit
				EndIf
				cIdDCF := aRelacao[nI][2]
				cIdMov := aRelacao[nI][3]
				nQuant := aRelacao[nI][4]
				cIdOper:= aRelacao[nI][5]

				If (nPos := aScan(aRelacao,{|x| x[2]+x[3]+cValToChar(x[4]) == cIdDCF+cIdMov+cValToChar(nQuant) .And. x[5] != cIdOper})) > 0
					nRecnoDCR := aRelacao[nPos][6]

					DCR->(dbGoTo(nRecnoDCR))
					RecLock("DCR",.F.)
					DCR->(dbDelete())
					DCR->(MsUnlock())

					// Deleta o registro duplicado
					aDel(aRelacao,nPos)
					aSize(aRelacao,Len(aRelacao)-1)
				Else
					// Retira do array o registro que está certo, para permanecer apenas os que devem ter sua própria D13
					aDel(aRelacao,nI)
					aSize(aRelacao,Len(aRelacao)-1)
					// Sempre que retira o mesmo registro volta uma casa para processar os outros corretamente
					nI--
					Loop
				EndIf
			Next nI

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			// Atualiza o registro originalmente aglutinado com a quantidade correta
			D13->(dbGoTo( (cAliasQ1)->RECNOD13 ))
			RecLock("D13",.F.)
			D13->D13_QTDEST := (cAliasQ1)->D12_QTDMOV
			D13->D13_QTDES2 := ConvUm(D13->D13_PRODUT,D13->D13_QTDEST,0,2)
			cTmOri  := D13->D13_TM
			cLocOri := D13->D13_LOCAL
			cEndOri := D13->D13_ENDER
			D13->(MsUnlock())

			// Atualiza o registro originalmente aglutinado com a quantidade correta
			D13->(dbGoTo( (cAliasQ1)->RECNOD13B ))
			RecLock("D13",.F.)
			D13->D13_QTDEST := (cAliasQ1)->D12_QTDMOV
			D13->D13_QTDES2 := ConvUm(D13->D13_PRODUT,D13->D13_QTDEST,0,2)
			cTmDes  := D13->D13_TM
			cLocDes := D13->D13_LOCAL
			cEndDes := D13->D13_ENDER
			D13->(MsUnlock())

			// Copia o registro D13 original para gerar registro dos documentos/produtos estornados
			For nI := 1 To Len(aRelacao)
				cIdDCF := aRelacao[nI][2]
				nQuant := aRelacao[nI][4]
				cIdOper:= aRelacao[nI][5]
				cDoc   := aRelacao[nI][7]
				cSDoc  := aRelacao[nI][8]
				cSerie := aRelacao[nI][9]
				cCliFor:= aRelacao[nI][10]
				cLoja  := aRelacao[nI][11]
				cNumSeq:= aRelacao[nI][12]

				For nY := 1 To 2
					WmsCopyReg("D13")
					D13->D13_TM     := Iif(nY==1,cTmOri,cTmDes)
					D13->D13_LOCAL  := Iif(nY==1,cLocOri,cLocDes)
					D13->D13_ENDER  := Iif(nY==1,cEndOri,cEndDes)
					D13->D13_QTDEST := nQuant
					D13->D13_QTDES2 := ConvUm(D13->D13_PRODUT,D13->D13_QTDEST,0,2)
					D13->D13_IDDCF  := cIdDCF
					D13->D13_IDOPER := cIdOper
					D13->D13_DOC    := cDoc
					D13->D13_SDOC   := cSDoc
					D13->D13_SERIE  := cSerie
					D13->D13_CLIFOR := cCliFor
					D13->D13_LOJA   := cLoja
					D13->D13_NUMSEQ := cNumSeq
					D13->(MsUnlock())
				Next nY
			Next nI
		EndIf

		End Transaction

		oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

		(cAliasQ1)->(dbSkip())
	EndDo
	(cAliasQ1)->(dbCloseArea())

	// Inicio do processamento da tabela D13
	Do While !lFim
		If dDtIniProc == Nil
			dDtIniProc := cUlMes
			nAno := Year(dDtIniProc)
		Else
			dDtIniProc := dDtFimProc
		EndIf

		If (Month(dDtIniProc) + 1) > 12
			nMes := 1
			nAno++
		Else
			nMes := Month(dDtIniProc) + 1
		EndIf

		dDtFimProc := LastDay( CTOD("10/"+cValtoChar(nMes)+"/"+cValtoChar(nAno)) )

		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
		 Busca movimentações estornadas de entrada SD1. Movimentações D13 que não
		 existe o documento origem vinculado e seta o campo D13_USACAL para '2=Não'
		 para não serem consideradas no cálculo do fechamento e também no CalcEstWms()
		------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		cQuery := " SELECT D13.D13_IDDCF,"
		cQuery +=        " D13.R_E_C_N_O_ RECNOD13"
		cQuery +=   " FROM "+RetSqlName("D13")+" D13"
		cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=    " AND D13.D13_ORIGEM = 'SD1'"
		cQuery +=    " AND D13.D13_DTESTO  > '"+DTOS(dDtIniProc)+"'" //'20170131'
		cQuery +=    " AND D13.D13_DTESTO <= '"+DTOS(dDtFimProc)+"'" //'20170228'
		cQuery +=    " AND D13.D13_USACAL <> '2'"
		cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
		cQuery +=    " AND NOT EXISTS ( SELECT 1"
		cQuery +=                      " FROM "+RetSqlName("SD1")+" SD1"
		cQuery +=                     " WHERE SD1.D1_FILIAL = '"+xFilial("SD1")+"'"
		cQuery +=                       " AND SD1.D1_NUMSEQ = D13.D13_NUMSEQ"
		cQuery +=                       " AND SD1.D_E_L_E_T_ = ' ' )"
		cQuery +=    " AND NOT EXISTS (SELECT 1"
		cQuery +=                      " FROM "+RetSqlName("D12")+" D12"
		cQuery +=                     " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=                       " AND D12.D12_IDDCF = D13.D13_IDDCF"
		cQuery +=                       " AND D12.D12_IDMOV = D13.D13_IDMOV"
		cQuery +=                       " AND D12.D12_IDOPER = D13.D13_IDOPER"
		cQuery +=                       " AND D12.D12_AGLUTI = '1'"
		cQuery +=                       " AND D12.D_E_L_E_T_ = ' ' )"
		cQuery +=  " ORDER BY D13.D13_IDDCF"
		cQuery := ChangeQuery(cQuery)
		cAliasQ1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

		nRecMov := 0
		nRecM := 0
		cIdDCFAnt := ""
		(cAliasQ1)->(dbEval({|| nRecMov++ }))

		oProcess:SetRegua1(nRecMov)
		nCountD13 += nRecMov

		(cAliasQ1)->(dbGoTop())

		Do While (cAliasQ1)->(!Eof())
			nRecM++
			oProcess:IncRegua1( "Movimentações SD1-"+cMonth(dDtFimProc)+": " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )

			oProcess:SetRegua2(3)
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			Begin Transaction

			D13->(dbGoto((cAliasQ1)->RECNOD13))
			If (D13->D13_USACAL != "2")
				RecLock("D13",.F.)
				D13->D13_USACAL := "2" // Não considera no cálculo
				D13->(MsUnlock())
			EndIf

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
			If !(cIdDCFAnt == (cAliasQ1)->D13_IDDCF)
				cIdDCFAnt := (cAliasQ1)->D13_IDDCF
				/*-------------------------------------------------------
				 Busca a movimentação de estorno que foi gerada pelo WMS
				-------------------------------------------------------*/
				cQuery := " SELECT DCF.DCF_ID"
				cQuery +=   " FROM "+RetSqlName("DCF")+" DCF"
				cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=    " AND DCF.DCF_IDORI  = '"+(cAliasQ1)->D13_IDDCF+"'"
				cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasQ2 := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ2,.F.,.T.)
				Do While lRet .And. (cAliasQ2)->(!Eof())
					cQuery := " UPDATE "+RetSqlName("D13")
					cQuery +=    " SET D13_USACAL = '2'"
					cQuery +=  " WHERE D13_FILIAL = '"+xFilial("D13")+"'"
					cQuery +=    " AND D13_IDDCF  = '"+(cAliasQ2)->DCF_ID+"'"
					cQuery +=    " AND D13_ORIGEM = 'DCF'"
					cQuery +=    " AND D13_USACAL <> '2'"
					cQuery +=    " AND D_E_L_E_T_ = ' '"
					If !(lRet := (TcSQLExec(cQuery) >= 0))
						WmsMessage("Problema ao realizar o UPDATE das movimentações de estorno.")
					EndIf

					(cAliasQ2)->(dbSkip())
				EndDo
				(cAliasQ2)->(dbCloseArea())
			EndIf

			If !lRet
				Disarmtransaction()
			EndIf

			End Transaction

			If !lRet
				Exit
			EndIf

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			(cAliasQ1)->(dbSkip())
		EndDo
		(cAliasQ1)->(dbCloseArea())

		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
		 Busca movimentações estornadas interna DH1 de DEVOLUÇÃO. Movimentações D13 que
		 não existe o documento origem vinculado e seta o campo D13_USACAL para '2=Não'
		 para não serem consideradas no cálculo do fechamento e também no CalcEstWms()
		------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		cQuery := " SELECT D13.D13_IDDCF,"
		cQuery +=        " D13.R_E_C_N_O_ RECNOD13"
		cQuery +=   " FROM "+RetSqlName("D13")+" D13"
		cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=    " AND D13.D13_ORIGEM = 'DH1'"
		cQuery +=    " AND D13.D13_DTESTO  > '"+DTOS(dDtIniProc)+"'" //'20170131'
		cQuery +=    " AND D13.D13_DTESTO <= '"+DTOS(dDtFimProc)+"'" //'20170228'
		cQuery +=    " AND D13.D13_USACAL <> '2'"
		cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
		cQuery +=    " AND NOT EXISTS ( SELECT 1"
		cQuery +=                       " FROM "+RetSqlName("SD3")+" SD3"
		cQuery +=                      " WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
		cQuery +=                        " AND SD3.D3_NUMSEQ = D13.D13_NUMSEQ"
		cQuery +=                        " AND SD3.D3_ESTORNO = ' '"
		cQuery +=                        " AND SD3.D_E_L_E_T_ = ' ' )"
		cQuery +=    " AND NOT EXISTS (SELECT 1"
		cQuery +=                      " FROM "+RetSqlName("D12")+" D12"
		cQuery +=                     " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
		cQuery +=                       " AND D12.D12_IDDCF = D13.D13_IDDCF"
		cQuery +=                       " AND D12.D12_IDMOV = D13.D13_IDMOV"
		cQuery +=                       " AND D12.D12_IDOPER = D13.D13_IDOPER"
		cQuery +=                       " AND D12.D12_AGLUTI = '1'"
		cQuery +=                       " AND D12.D_E_L_E_T_ = ' ' )"
		cQuery +=    " AND EXISTS (SELECT 1"
		cQuery +=                  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery +=                 " INNER JOIN "+RetSqlName("DC5")+" DC5"
		cQuery +=                    " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
		cQuery +=                   " AND DC5.DC5_SERVIC = DCF.DCF_SERVIC"
		cQuery +=                   " AND DC5.DC5_OPERAC IN ('1','2')" // Endereçamento/Endereçamento Crossdocking
		cQuery +=                   " AND DC5.D_E_L_E_T_ = ' '"
		cQuery +=                 " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=                   " AND DCF.DCF_ID = D13.D13_IDDCF"
		cQuery +=                   " AND DCF.D_E_L_E_T_ = ' ')"
		cQuery +=  " ORDER BY D13.D13_IDDCF"
		cQuery := ChangeQuery(cQuery)
		cAliasQ1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

		nRecMov := 0
		nRecM := 0
		cIdDCFAnt := ""
		(cAliasQ1)->(dbEval({|| nRecMov++ }))

		oProcess:SetRegua1(nRecMov)
		nCountD13 += nRecMov

		(cAliasQ1)->(dbGoTop())

		Do While (cAliasQ1)->(!Eof())
			nRecM++
			oProcess:IncRegua1( "Movimentações Dev SD3-"+cMonth(dDtFimProc)+": " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )

			oProcess:SetRegua2(3)
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			Begin Transaction

			D13->(dbGoto((cAliasQ1)->RECNOD13))
			RecLock("D13",.F.)
			D13->D13_USACAL := "2" // Não considera no cálculo
			D13->(MsUnlock())
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			If !(cIdDCFAnt == (cAliasQ1)->D13_IDDCF)
				cIdDCFAnt := (cAliasQ1)->D13_IDDCF
				/*-------------------------------------------------------
				 Busca a movimentação de estorno que foi gerada pelo WMS
				-------------------------------------------------------*/
				cQuery := " SELECT DCF.DCF_ID"
				cQuery +=   " FROM "+RetSqlName("DCF")+" DCF"
				cQuery +=  " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
				cQuery +=    " AND DCF.DCF_IDORI  = '"+(cAliasQ1)->D13_IDDCF+"'"
				cQuery +=    " AND DCF.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				cAliasQ2 := GetNextAlias()
				dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ2,.F.,.T.)
				Do While lRet .And. (cAliasQ2)->(!Eof())
					cQuery := " UPDATE "+RetSqlName("D13")
					cQuery +=    " SET D13_USACAL = '2'"
					cQuery +=  " WHERE D13_FILIAL = '"+xFilial("D13")+"'"
					cQuery +=    " AND D13_IDDCF  = '"+(cAliasQ2)->DCF_ID+"'"
					cQuery +=    " AND D13_ORIGEM = 'DCF'"
					cQuery +=    " AND D13_USACAL <> '2'"
					cQuery +=    " AND D_E_L_E_T_ = ' '"
					If !(lRet := (TcSQLExec(cQuery) >= 0))
						WmsMessage("Problema ao realizar o UPDATE das movimentações de estorno.")
					EndIf

					(cAliasQ2)->(dbSkip())
				EndDo
				(cAliasQ2)->(dbCloseArea())
			EndIf

			If !lRet
				Disarmtransaction()
			EndIf

			End Transaction

			If !lRet
				Exit
			EndIf

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			(cAliasQ1)->(dbSkip())
		EndDo
		(cAliasQ1)->(dbCloseArea())

		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
		 Busca movimentações estornadas interna DH1 de REQUISIÇÃO. Movimentações D13 que
		 não existe o documento origem vinculado e seta o campo D13_USACAL para '2=Não'
		 para não serem consideradas no cálculo do fechamento e também no CalcEstWms()
		------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		cQuery := " SELECT D13.D13_IDDCF,"
		cQuery +=        " D13.R_E_C_N_O_ RECNOD13"
		cQuery +=   " FROM "+RetSqlName("D13")+" D13"
		cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=    " AND D13.D13_ORIGEM = 'DH1'"
		cQuery +=    " AND D13.D13_DTESTO > '"+DTOS(dDtIniProc)+"'" //'20170131'
		cQuery +=    " AND D13.D13_DTESTO <= '"+DTOS(dDtFimProc)+"'" //'20170228'
		cQuery +=    " AND D13.D13_USACAL <> '2'"
		cQuery +=    " AND D13.D13_IDMOV = ' '"
		cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
		cQuery +=    " AND NOT EXISTS ( SELECT 1"
		cQuery +=                       " FROM "+RetSqlName("SD3")+" SD3"
		cQuery +=                      " WHERE SD3.D3_FILIAL = '"+xFilial("SD3")+"'"
		cQuery +=                        " AND SD3.D3_NUMSEQ = D13.D13_NUMSEQ"
		cQuery +=                        " AND SD3.D3_ESTORNO = ' '"
		cQuery +=                        " AND SD3.D_E_L_E_T_ = ' ' )"
		cQuery +=    " AND EXISTS (SELECT 1"
		cQuery +=                  " FROM "+RetSqlName("DCF")+" DCF"
		cQuery +=                 " INNER JOIN "+RetSqlName("DC5")+" DC5"
		cQuery +=                    " ON DC5.DC5_FILIAL = '"+xFilial("DC5")+"'"
		cQuery +=                   " AND DC5.DC5_SERVIC = DCF.DCF_SERVIC"
		cQuery +=                   " AND DC5.DC5_OPERAC IN ('3','4')" // Separação/Separação Crossdocking
		cQuery +=                   " AND DC5.D_E_L_E_T_ = ' '"
		cQuery +=                 " WHERE DCF.DCF_FILIAL = '"+xFilial("DCF")+"'"
		cQuery +=                   " AND DCF.DCF_ID = D13.D13_IDDCF"
		cQuery +=                   " AND DCF.D_E_L_E_T_ = ' ')"
		cQuery +=  " ORDER BY D13.D13_IDDCF"
		cQuery := ChangeQuery(cQuery)
		cAliasQ1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

		nRecMov := 0
		nRecM := 0
		(cAliasQ1)->(dbEval({|| nRecMov++ }))

		oProcess:SetRegua1(nRecMov)
		oProcess:SetRegua2(2)
		nCountD13 += nRecMov

		(cAliasQ1)->(dbGoTop())

		Do While (cAliasQ1)->(!Eof())
			nRecM++
			oProcess:IncRegua1( "Movimentações Req SD3-"+cMonth(dDtFimProc)+": " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )

			Begin Transaction

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
			D13->(dbGoto((cAliasQ1)->RECNOD13))
			RecLock("D13",.F.)
			D13->D13_USACAL := "2" // Não considera no cálculo
			D13->(MsUnlock())
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			End Transaction

			(cAliasQ1)->(dbSkip())
		EndDo
		(cAliasQ1)->(dbCloseArea())

		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
		 Busca movimentações estornadas de faturamento SD2. Movimentações D13 que não
		 existe o documento origem vinculado e seta o campo D13_USACAL para '2=Não'
		 para não serem consideradas no cálculo do fechamento e também no CalcEstWms()
		------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		cQuery := " SELECT D13.R_E_C_N_O_ RECNOD13"
		cQuery +=   " FROM "+RetSqlName("D13")+" D13"
		cQuery +=  " WHERE D13.D13_FILIAL = '"+xFilial("D13")+"'"
		cQuery +=    " AND D13.D13_ORIGEM = 'SC9'"
		cQuery +=    " AND D13.D13_IDMOV = ' '"
		cQuery +=    " AND D13.D13_DTESTO  > '"+DTOS(dDtIniProc)+"'" //'20170131'
		cQuery +=    " AND D13.D13_DTESTO <= '"+DTOS(dDtFimProc)+"'" //'20170228'
		cQuery +=    " AND D13.D13_USACAL <> '2'"
		cQuery +=    " AND D13.D_E_L_E_T_ = ' '"
		cQuery +=    " AND NOT EXISTS ( SELECT 1"
		cQuery +=                       " FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SC9")+" SC9"
		cQuery +=                      " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"'"
		cQuery +=                        " AND SD2.D2_DOC = D13.D13_DOC"
		cQuery +=                        " AND SD2.D2_CLIENTE = D13.D13_CLIFOR"
		cQuery +=                        " AND SD2.D2_LOJA = D13.D13_LOJA"
		cQuery +=                        " AND SD2.D2_COD = D13.D13_PRDORI"
		cQuery +=                        " AND SD2.D2_LOCAL = D13.D13_LOCAL"
		cQuery +=                        " AND SD2.D_E_L_E_T_ = ' '"
		cQuery +=                        " AND SC9.C9_FILIAL = '"+xFilial("SC9")+"'"
		cQuery +=                        " AND SC9.C9_PRODUTO = SD2.D2_COD"
		cQuery +=                        " AND SC9.C9_LOCAL = SD2.D2_LOCAL"
		cQuery +=                        " AND SC9.C9_NUMSEQ = SD2.D2_NUMSEQ"
		cQuery +=                        " AND SC9.C9_IDDCF = D13.D13_IDDCF"
		cQuery +=                        " AND SC9.D_E_L_E_T_ = ' ')"
		cQuery := ChangeQuery(cQuery)
		cAliasQ1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

		nRecMov := 0
		nRecM := 0
		(cAliasQ1)->(dbEval({|| nRecMov++ }))

		oProcess:SetRegua1(nRecMov)
		oProcess:SetRegua2(2)
		nCountD13 += nRecMov

		(cAliasQ1)->(dbGoTop())
		Do While (cAliasQ1)->(!Eof())
			nRecM++
			oProcess:IncRegua1( "Movimentações SD2-"+cMonth(dDtFimProc)+": " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )

			Begin Transaction

			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
			D13->(dbGoto((cAliasQ1)->RECNOD13))
			RecLock("D13",.F.)
			D13->D13_USACAL := "2" // Não considera no cálculo
			D13->(MsUnlock())
			oProcess:IncRegua2(CalcTime(cTimeIni,Time()))

			End Transaction

			(cAliasQ1)->(dbSkip())
		EndDo
		(cAliasQ1)->(dbCloseArea())

		/*------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Busca as movimentações de desmontagem automáticas geradas a partir do inventário
		-------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
		cQuery := " SELECT SD3.D3_CF,"
		cQuery +=        " SD3.D3_CHAVE,"
		cQuery +=        " SD3.D3_NUMSEQ,"
		cQuery +=        " SD3.R_E_C_N_O_ RECNOSD3"
		cQuery +=   " FROM "+RetSqlName("SD3")+" SD3"
		cQuery +=  " WHERE SD3.D3_FILIAL   = '"+xFilial("SD3")+"'"
		cQuery +=    " AND SD3.D3_DOC      = 'DESMONTAG'"
		cQuery +=    " AND SD3.D3_EMISSAO  > '"+DTOS(dDtIniProc)+"'" //'20170131'
		cQuery +=    " AND SD3.D3_EMISSAO <= '"+DTOS(dDtFimProc)+"'" //'20170228'
		cQuery +=    " AND SD3.D_E_L_E_T_ = ' '"
		cQuery +=  " ORDER BY SD3.R_E_C_N_O_"
		cQuery := ChangeQuery(cQuery)
		cAliasQ1 := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',tcGenQry(,,cQuery),cAliasQ1,.F.,.T.)

		nRecMov := 0
		nRecM := 0
		cNumSeq := ""
		(cAliasQ1)->(dbEval({|| nRecMov++ }))

		If nRecMov == 0
			oProcess:SetRegua1(1)
			oProcess:IncRegua1( "Movimentações SD3 - "+cMonth(dDtFimProc)+" "+cValtoChar(nAno)+" : 0/0" )
		Else
			oProcess:SetRegua1(nRecMov)
			nCountSD3 += nRecMov

			(cAliasQ1)->(dbGoTop())
	
			Do While (cAliasQ1)->(!Eof())
				nRecM++
				oProcess:IncRegua1( "Movimentações SD3 - "+cMonth(dDtFimProc)+": " + cValtoChar(nRecM)+"/"+cValtoChar(nRecMov) )
	
				oProcess:SetRegua2(2)
				oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
	
				Begin Transaction
	
				If (cAliasQ1)->D3_CF == "RE7"
					cNumSeq := (cAliasQ1)->D3_NUMSEQ // Armazena o NumSeq do primeiro registro da movimentação de desmontagem
					If !((cAliasQ1)->D3_CHAVE == "E0")
						SD3->(dbGoTo( (cAliasQ1)->RECNOSD3 ))
						RecLock("SD3",.F.)
						SD3->D3_CHAVE := "E0"
						SD3->(MsUnlock())
					Else
						nCountSD3--
					EndIf
				ElseIf (cAliasQ1)->D3_CF == "DE7"
					If !((cAliasQ1)->D3_NUMSEQ == cNumSeq) .Or. !((cAliasQ1)->D3_CHAVE == "E9")
						SD3->(dbGoTo( (cAliasQ1)->RECNOSD3 ))
						RecLock("SD3",.F.)
						SD3->D3_NUMSEQ := cNumSeq // Atualiza o NumSeq, para toda movimentação de desmontagem possuir o mesmo
						SD3->D3_CHAVE  := "E9"
						SD3->(MsUnlock())
					Else
						nCountSD3--
					EndIf
				EndIf
	
				End Transaction
				
				oProcess:IncRegua2(CalcTime(cTimeIni,Time()))
	
				(cAliasQ1)->(dbSkip())
			EndDo
		EndIf
		
		(cAliasQ1)->(dbCloseArea())

		If dDataBase <= dDtFimProc
			lFim := .T.
		EndIf
	EndDo

	WmsMessage("Processamento finalizado." + CRLF + ;
				"Qtd. registros D13 alterados: " + cValtoChar(nCountD13) + CRLF + ;
				"Qtd. registros SD3 alterados: " + cValtoChar(nCountSD3) + CRLF + ;
				"Inicio: " + DTOC(cDateIni) + " " + cTimeIni + CRLF + ;
				"Fim: " + DTOC(Date()) + " " + Time() + CRLF + ;
				"Tempo: " + CalcTime(cTimeIni,Time()))

RestArea(aAreaAnt)
Return Nil

Static Function CalcTime(cInicioPar,cFimPar)
Local cInicio := cInicioPar
Local cFim := cFimPar
Local nMilIni := Val(SubStr(cInicio,11,3))
Local nMilFim := Val(SubStr(cFim,11,3))
Local nMiles := 0
Local cElap := ""

	cInicio := StrTran(cInicio,"[","")
	cInicio := StrTran(cInicio,"]","")
	cFim := StrTran(cFim,"]","")
	cFim := StrTran(cFim,"[","")
	nMiles := 1000 - nMilIni
	nMiles += nMilFim
	cElap := ElapTime(SubStr(cInicio,1,8),SubStr(cFim,1,8))

Return cElap
