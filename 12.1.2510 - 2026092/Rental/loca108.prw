#Include "Totvs.ch"
#Include "TopConn.ch"
#Include "LOCA108.ch"

/*
LOCA108.PRW - Funções para a gestão do processo de títulos provisórios
@author Frank Zwarg Fuga
@since 19/03/2026
*/

/*/{Protheus.doc} LOCA10805 - loca01318
Rotina para geração do titulo provisorio
@type function
@version v1 
@author Frank Zwarg Fuga
@since 29/01/2026
/*/
Function LOCA10805
	LOCA10801()
Return

/*/{Protheus.doc} LOCA10804 - antigo LOCA01315
Rotina para funcionamento com outras funções do Rental (títulos provisórios)
@type function
@version v1 
@author Frank Zwarg Fuga
/*/
Function LOCA10804(aProvisorio, lMens)
Private oSay
Default aProvisorio := {}
Default lMens := .F.

	If len(aProvisorio) == 0
		Return .T.
	EndIf

	If lMens
		FWMsgRun(, {|oSay| LOCA10803(oSay, aProvisorio, lMens) }, STR0001, STR0002) //"Títulos provisórios"###"Gerando a movimentação financeira."
	Else
		LOCA10803(oSay, aProvisorio, lMens)
	EndIF

Return .T.

/*/{Protheus.doc} LOCA10801 antiga função gerprx
ITUP Business - TOTVS RENTAL
Geração dos títulos provisórios
@type Function
@author Frank Zwarg Fuga
@since 19/03/2026
/*/
Function LOCA10801(lMens) 
Local aRet := {}
Private oSay
Default lMens := .F.

	If lMens
		FWMsgRun(, {|oSay| aRet := LOCA10803(oSay,,lMens) }, STR0001, STR0002) //"Títulos provisórios"###"Gerando a movimentação financeira."
	Else
		aRet := LOCA10803(oSay,,lMens)
	EndIf

Return aRet

/*/{Protheus.doc} LOCA10803 - GerPRx2
Geração dos títulos provisórios
@type function
@version v1 
@author Frank Zwarg Fuga
@since 29/01/2026
/*/
Function LOCA10803(oSay, aProvisorio, lMens, cAs, lForcaUlt)
Local cTipoGer 		:= "1" // por default manteremos sempre como geração por ciclo
Local aGerar        := {}
Local nX
Local aPgto 		:= {}
Local nY
Local cQuery
Local aArea := GetArea() // DSERLOCA-8021 - Frank em 09/02/26
Local aAreaFP0 := FP0->(GetArea()) // DSERLOCA-8021 - Frank em 09/02/26
Local aAreaFP1 := FP1->(GetArea()) // DSERLOCA-8021 - Frank em 09/02/26
Local aAreaFPA := FPA->(GetArea()) // DSERLOCA-8021 - Frank em 09/02/26
Local nContaPer := 0 // DSERLOCA-8021 - Frank em 09/02/26
Local dTemp // DSERLOCA-8021 - Frank em 09/02/26
Local dIni // DSERLOCA-8021 - Frank em 09/02/26
Local dFim // DSERLOCA-8021 - Frank em 09/02/26
Local dFat // DSERLOCA-8021 - Frank em 09/02/26
Local cFil // DSERLOCA-8021 - Frank em 09/02/26
Local cProj	:= FP0->FP0_PROJET // DSERLOCA-8021 - Frank em 09/02/26
Local nMes // DSERLOCA-8021 - Frank em 09/02/26
Local aPeriodos := {} // DSERLOCA-8021 - Frank em 09/02/26
Local dVenc // DSERLOCA-8021 - Frank em 09/02/26
Local dNewData // DSERLOCA-8021 - Frank em 09/02/26
Local dPeriodo // DSERLOCA-8021 - Frank em 09/02/26
Local aTempDB
Local lPermite
Local dPrimeira // uso para a rotina de reprocessamento dos provisorios

Private lMsErroAuto
Private dDtFimX // DSERLOCA-8021 - Frank em 09/02/26
Private dDtUltX // DSERLOCA-8021 - Frank em 09/02/26

Default aProvisorio := {}
Default lMens := .F.
Default cAs := ""
Default lForcaUlt := .F. // uso para a rotina de reprocessamento dos provisorios

	If lMens
		ProcessMessages()
	EndIF

	// DSERLOCA-8021 - Frank em 09/02/26
	// O tratamento dos ciclos agora é pelo campo FPA_QTDPRC
	If FPA->(FieldPos("FPA_QTDPRC")) == 0 .or. file("\SYSTEM\L013E4.TXT")
		Return .F.
	EndIf

	// DSERLOCA-6564 - Frank em 04/07/2025
    // Tratamento da geração do título provisório pelo campo FP0_PROV
    If FP0->(FieldPos("FP0_PROV")) > 0
        If FP0->FP0_PROV == "2"
            cTipoGer := "2"
        EndIf
    EndIf

	// DSERLOCA-10808 - Frank em 11/02/2026
	// Gerar provisórios somente para orçamentos diferente de medição.
	If FP0->FP0_TIPFAT == "M"
		Return .F.
	EndIf

	FPA->(dbSetOrder(1))
	FPA->(dbSeek(xFilial("FPA") + cProj))

	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0") + cProj))
	FP1->(dbSetOrder(1))
	FP1->(dbSeek(xFilial("FP0") + cProj + FPA->FPA_OBRA))

	aTempDB := FP1->(GetArea())

	While !FPA->(eof()) .and. FPA->FPA_PROJET == cProj .and. FPA->FPA_FILIAL == xFilial("FPA")

		If lMens
			ProcessMessages()
		EndIF

		If !empty(cAs)
			If FPA->FPA_AS <> cAs
				FPA->(dbSkip())
				Loop
			EndIf
		EndIf
		
		If FPA->FPA_QUANT > 0 .and. !empty(FPA->FPA_AS) .and. FPA->FPA_VRHOR > 0 .and. empty(FPA->FPA_NFRET)
			dIni  := FPA->FPA_DTINI
			dFim  := FPA->FPA_DTENRE
			dFat  := FPA->FPA_DTFIM
			cFil  := xFilial("FPA") //FPA->FPA_FILEMI ISSUE DSERLOCA-10816 - Frank Zwarg Fuga em 11/02/2026
			//If empty(FPA->FPA_GERAEM)
				dTemp := FPA->FPA_DTFIM      //_dTemp := FPA->FPA_DTINI
			//Else
			//	dTemp := FPA->FPA_GERAEM
			//EndIf
			nMes  := 0

			// Passo 1 - Verificar os ciclos de faturamento que podem existir neste período
			nContaPer := 0
			dPeriodo := ctod("")

			dDtFimX := FPA->FPA_DTFIM
			
			If lForcaUlt .or. file("\SYSTEM\L108E1.TXT") // Tratamento para a rotina de reGeneração dos provisorios
				dDtUltX := ctod("")
				// Pesquisar na FPZ o primeiro faturamento para identificar o FPA_DTFIM
				dPrimeira := ctod("")
				FPY->(dbSetOrder(1))
				FPZ->(dbSetOrder(2))
				FPZ->(dbSeek(xFilial("FQZ")+FPA->FPA_AS))
				While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FQZ")+FPA->FPA_AS
					If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
						If FPY->FPY_TIPFAT == "P" .and. FPZ->FPZ_EXTRA <> "S"
							dPrimeira := ctod(substr(FPZ->FPZ_PERLOC,14,10))
							exit
						EndIf
					EndIf
					FPZ->(dbSkip())
				EndDo
				If !empty(dPrimeira)
					dDtFimX := dPrimeira
					dFat := dPrimeira
					dTemp := dPrimeira
				EndIf
			Else
				dDtUltX := FPA->FPA_ULTFAT
			EndIF

			While dTemp <= dFim
				if month(dTemp) <> nMes

					nContaPer ++

					If nContaPer <= FPA->FPA_QTDPRC

						nMes := month(dTemp)
						//Seleciona Cliente de acordo MULTPLUS FATURAMENTO NO CONTRATO - SIGALOC94-282
						If FPA->(ColumnPos("FPA_CLIFAT")) > 0 .And. !Empty(FPA->FPA_CLIFAT)
							cCliFat := FPA->FPA_CLIFAT
							cLojFat := FPA->FPA_LOJFAT
						ElseIf !Empty(FP1->FP1_CLIDES)
							cCliFat := FP1->FP1_CLIDES
							cLojFat := FP1->FP1_LOJDES
						Else
							cCliFat := FP0->FP0_CLI
							cLojFat := FP0->FP0_LOJA
						EndIf

						// Encontrar o período
						FP1->(RestArea(aTempDB))
						dPeriodo := LOCA10808(dPeriodo)

						lPermite := .T.
						FQB->(dbSetOrder(2))
						If FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET+FPA->FPA_AS))
							lPermite := .F.
						EndIf

						If (dPeriodo > FPA->FPA_ULTFAT .or. lForcaUlt) .and. lPermite
							aadd(aPeriodos,{dPeriodo, .T., cCliFat, cLojFat, FPA->FPA_AS, FPA->FPA_VRHOR, FPA->(Recno()), FPA->FPA_OBRA, FPA->FPA_SEQGRU, FPA->FPA_CUSTO, FPA->FPA_CONPAG, dPeriodo, FPA->FPA_DTINI, ctod(""), ctod(""), FPA->FPA_DTENRE, FPA->FPA_ULTFAT, FPA->FPA_GERAEM, FPA->FPA_CONPAG, FPA->FPA_QTDPRC }) // antes era dTemp
						EndIf

						// Tratamento para cobrança única
						// Gerar apenas o primeiro ciclo.
						If FPA->FPA_TIPOSE == "Z"
							Exit
						EndIf
					EndIf
				endif
				dTemp ++
			EndDo

			For nX := 1 to len(aPeriodos) // deixar todos os registros com o dia do próximo faturamento
				FPA->(dbSetOrder(3))
				FPA->(dbSeek(xFilial("FPA")+aPeriodos[nX,5]))
				FP1->(dbSetOrder(1))
				FP1->(dbSeek(xFilial("FP1")+FPA->FPA_PROJET+FPA->FPA_OBRA))
				If FP1->FP1_TPMES <> "1"	
					If day(lastday(ctod("01/"+str(month(aPeriodos[nX,1]))+"/"+str(year(aPeriodos[nX,1]))))) < day(dFat) .or. file("\SYSTEM\L013E5.TXT")
						aPeriodos[nX,1] := lastday(ctod("01/"+str(month(aPeriodos[nX,1]))+"/"+str(year(aPeriodos[nX,1]))))
					Else
						aPeriodos[nX,1] := ctod(str(day(dFat))+"/"+str(month(aPeriodos[nX,1]))+"/"+str(year(aPeriodos[nX,1])))
					EndIF
				EndIf
			Next

			aBindParam := {}

			// Passo 2 - Verificar para cada ciclo se já foram emitidos faturamento
			cQuery := " SELECT R_E_C_N_O_ REG "
			cQuery += " FROM " + RETSQLNAME("FPZ") + " FPZ "
			cQuery += " WHERE FPZ.FPZ_FILIAL = ? AND "
			aadd(aBindParam,cFil)
			cQuery += " FPZ.FPZ_AS = ? AND "
			aadd(aBindParam,FPA->FPA_AS)
			cQuery += " FPZ.D_E_L_E_T_ = ' ' "

			cQuery := changequery(cQuery)

			LOCACLOSE("TRBVLD")

			MPSysOpenQuery(cQuery,"TRBVLD",,,aBindParam)

			While !TRBVLD->(Eof())

				FPZ->(dbGoto(TRBVLD->REG))

				FPY->(dbSetOrder(1))
				If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))

					lPassa := .F.
					If (FWIsInCallStack("LOCA24817") .or. FWIsInCallStack("LOCA048") .or. FWIsInCallStack("LOCA013")) .and. !file("\SYSTEM\L013E7.TXT")
						lPassa := .T.
					Else
						If alltrim(FPY->FPY_STATUS) <> '2' .and. FPY->FPY_TIPFAT <> "R"
							lPassa := .T.
						EndIf
					EndIf
					
					If lPassa
						For nX := 1 to len(aPeriodos)
							If (aPeriodos[nX,12] < FPA->FPA_DTFIM .or. file("\SYSTEM\L013E8.TXT")) .and. !lForcaUlt
								aPeriodos[nX,2] := .F.	
							EndIf
						Next
					EndIf

				EndIf

				TRBVLD->(dbSkip())
			EndDo

			TRBVLD->(DBCLOSEAREA())

		EndIF
		FPA->(dbSkip())
	EndDo

	If len(aPeriodos) > 0

		// Incluir os provisorios

		/* DSERLOCA-6564 - Frank em 04/07/2025	
		Estrutura do _aPeriodos
		1  = dTemp, 
		2  = .T., 
		3  = cCliFat, 
		4  = cLojFat, 
		5  = FPA->FPA_AS, 
		6  = FPA->FPA_VRHOR, 
		7  = FPA->(Recno()), 
		8  = FPA->FPA_OBRA, 
		9  = FPA->FPA_SEQGRU, 
		10 = FPA->FPA_CUSTO
		11 = FPA->FPA_CONPAG
		12 = Data de emissao
 		13 = FPA->FPA_DTINI
		14 = proximo faturamento 
		15 = data fim
		16 = FPA->FPA_DTENRE
		17 = ultimo faturamento 
		18 = FPA->FPA_GERAEM
		19 = FPA->FPA_CONPAG
		20 = FPA->FPA_QTDPRC
		*/
		aGerar := {}
		If len(aPeriodos) > 0
			For nX := 1 to len(aPeriodos)
				
				If !aPeriodos[nX,2] .or. file("\SYSTEM\L013ED.TXT")
					Loop
				EndIf

				If cTipoGer == "1" // Gerar por ciclo
					aadd(aGerar,{aPeriodos[nX,1],;
								 aPeriodos[nX,2],;
								 aPeriodos[nX,3],;
								 aPeriodos[nX,4],;
								 aPeriodos[nX,5],;
								 aPeriodos[nX,6],;
								 aPeriodos[nX,7],;
								 aPeriodos[nX,8],;
								 aPeriodos[nX,9],;
								 aPeriodos[nX,10],;
								 aPeriodos[nX,11],;
								 aPeriodos[nX,12],;
								 aPeriodos[nX,13],;
								 aPeriodos[nX,14],;
								 aPeriodos[nX,15],;
								 aPeriodos[nX,16],;
								 aPeriodos[nX,17],;
								 aPeriodos[nX,18],;
								 aPeriodos[nX,19],;
								 aPeriodos[nX,20] })
				Else // Gerar por ciclo + condição de pagamento
					dVenc := aPeriodos[nX,1]
					dNewData := dVenc //DataValida(dVenc, .T.)
					aPgto := Condicao(aPeriodos[nX,6],aPeriodos[nX,11],,dNewData)
					For nY := 1 to len(aPgto)
						aadd(aGerar,{aPgto[nY,1],;
									 aPeriodos[nX,2],;
									 aPeriodos[nX,3],;
									 aPeriodos[nX,4],;
									 aPeriodos[nX,5],;
									 aPgto[nY,2],;
									 aPeriodos[nX,7],;
									 aPeriodos[nX,8],;
									 aPeriodos[nX,9],;
									 aPeriodos[nX,10],;
									 aPeriodos[nX,11],;
									 aPeriodos[nX,12],;
									 aPeriodos[nX,13],;
									 aPeriodos[nX,14],;
									 aPeriodos[nX,15],;
									 aPeriodos[nX,16],;
									 aPeriodos[nX,17],;
									 aPeriodos[nX,18],;
									 aPeriodos[nX,19],;
									 aPeriodos[nX,20] })
					Next

				EndIf

			Next

		EndIf

	EndIf
		
	FP0->(RestArea(aAreaFP0)) // DSERLOCA-8021 - Frank em 09/02/26
	FP1->(RestArea(aAreaFP1)) // DSERLOCA-8021 - Frank em 09/02/26
	FPA->(RestArea(aAreaFPA)) // DSERLOCA-8021 - Frank em 09/02/26
	RestArea(aArea)

Return aGerar

/*/{Protheus.doc} LOCA10802 - antigo LOCA13PRV
Gravação dos títulos provisórios
@type function
@version v1 
@author Frank Zwarg Fuga
@since 12/02/2026
/*/
Function LOCA10802(aParcial, cModelo, cAs, lMens)
Local lRet := .T.
Private oSay

Default cModelo := "A" // A=Aglutina, N=Não aglutina
Default cAs := "" // Gerar provisório para uma AS em particular
Default lMens := .F.
	
	If lMens
		FWMsgRun(, {|oSay| LOCA10807(oSay, aParcial, cModelo, cAs, lMens) }, STR0001, STR0002) //"Títulos provisórios"###"Gerando a movimentação financeira."
	Else
		LOCA10807(oSay, aParcial, cModelo, cAs, lMens)
	EndIf

Return lRet

/*/{Protheus.doc} LOCA10807 - antigo LOCA13PRV1
Gravação dos títulos provisórios aglutinados
@type function
@version v1 
@author Frank Zwarg Fuga
@since 12/02/2026
/*/
Function LOCA10807(oSay, aParcial, cModelo, cAs, lMens)
Local lRet := .F.
Local aSE1 := {}
Local aFQB := {}
Local nX
Local nY
Local nZ
Local lAglutina := .F.
Local nParc := 0
Local cQuery
Local cNumTit
Local cNatureza := SUPERGETMV("MV_LOCX065" ,.T.,"" )
Local lLc13Prv := EXISTBLOCK("LC13PRV")
Local cTitu
Local cPref
Local cParc
Local nValo
Local nMV_MOEDA	:= 1
Local cHist
Local cTipoGer := "2"
Local dEmissao

Private lMsErroAuto

Default cModelo := "A" // indica que não será utilizado o formato de aglutinação
Default cAs := "" // No caso de ser o modelo antigo, possibilitar gerar o provisório de uma AS específica
Default lMens := .F.

	If len(aParcial) > 0

		// Excluir os provisorios
		For nX := 1 to len(aParcial)

			If !aParcial[nX,2]
				Loop
			EndIf

			If !empty(cAs)
				If alltrim(aParcial[nX,5]) <> alltrim(cAs)
					Loop
				EndIF
			EndIf

			// Verificar se existem outras moedas envolvidas.
			// Frank - 26/08/21
			dVenc := aParcial[nX,1]
			dNewData := DataValida(dVenc, .T.)
			lBloqx := .F.
			
			If FP0->FP0_MOEDA <> nMV_MOEDA .or. file("\SYSTEM\L108E2.TXT")
				SM2->(dbSetOrder(1))
				If SM2->(dbSeek(dtos(dNewData))) 
					cMoedaX := "SM2->M2_MOEDA"+alltrim(str(FP0->FP0_MOEDA))
					If &(cMoedaX) == 0 .or. file("\SYSTEM\L108E3.TXT")
						lBloqX := .T.
					EndIF
				Else
					lBloqX := .T.
				EndIF
			EndIF

			If lBloqX
				//MsgAlert(STR0121+dtoc(dNewData),STR0122) //"Atenção não foi localizado no cadastro de moeda a cotação do dia: "###"Título provisório não criado."
				//RestArea(aArea)
				Return .F.
			EndIF

			// Deleta os títulos provisórios
			//FWMsgRun(, {|oSay| aRet := LOCA10806(2, FP0->FP0_PROJET, aParcial[nX,5],,,.T.) }, STR0001, STR0003) //"Títulos provisórios"###"Estornando a movimentação financeira."
			aRet := LOCA10806(2, FP0->FP0_PROJET, aParcial[nX,5],,,.T.)

		Next
	EndIF

	/*
	Estrutura do aParcial - cada elemento é um array contendo:
	1  = dTemp, 
	2  = .T., 
	3  = cCliFat, 
	4  = cLojFat, 
	5  = FPA->FPA_AS, 
	6  = FPA->FPA_VRHOR, 
	7  = FPA->(Recno()), 
	8  = FPA->FPA_OBRA, 
	9  = FPA->FPA_SEQGRU, 
	10 = FPA->FPA_CUSTO
	11 = FPA->FPA_CONPAG
	12 = Data de emissao
	13 = FPA->FPA_DTINI
	14 = proximo faturamento 
	15 = data fim
	16 = FPA->FPA_DTENRE
	17 = ultimo faturamento 
	18 = FPA->FPA_GERAEM
	19 = FPA->FPA_CONPAG
	20 = FPA->FPA_QTDPRC
	*/

	// Aglutinando os movimentos
	// Separar por cliente, obra e vencimento
	For nX := 1 to len(aParcial)

		If aParcial[nX,2] .and. aParcial[nX,6] > 0 

			If !empty(cAs)
				If alltrim(aParcial[nX][5]) <> alltrim(cAs) .or. file("\SYSTEM\L108E6.TXT")
					Loop
				EndIF
			EndIF

			aadd( aFQB, { aParcial[nX,1],;
						  aParcial[nX,2],;
						  aParcial[nX,3],;
						  aParcial[nX,4],;
						  aParcial[nX,5],;
						  aParcial[nX,6],;
						  aParcial[nX,7],;
						  aParcial[nX,8],;
						  aParcial[nX,9],;
						  aParcial[nX,10],;
						  aParcial[nX,11],;
						  aParcial[nX,12],;
						  aParcial[nX,13],;
						  aParcial[nX,14],;
						  aParcial[nX,15],;
						  aParcial[nX,16],;
						  aParcial[nX,17],;
						  aParcial[nX,18],;
						  aParcial[nX,19],;
						  aParcial[nX,20],;
						  nX,;
						} )

			If cModelo <> "N" // por aglutinação

				lAglutina := .F.
				For nZ := 1 to len(aSE1)
					// Avaliação do cliente
					If aSE1[nZ][3]+aSE1[nZ][4] == aParcial[nX][3]+aParcial[nX][4]
						// Avaliação da obra
						If aSE1[nZ][8] == aParcial[nX][8]
							// Avaliação do vencimento
							If aSE1[nZ][1] == aParcial[nX][1]
								lAglutina := .T.
								Exit
							EndIf
						EndIf
					EndIf
				Next

				If !lAglutina
					aadd( aSE1, { aParcial[nX,1],; 
								aParcial[nX,2],;
								aParcial[nX,3],;
								aParcial[nX,4],;
								aParcial[nX,5],;
								aParcial[nX,6],;
								aParcial[nX,7],;
								aParcial[nX,8],;
								aParcial[nX,9],;
								aParcial[nX,10],;
								aParcial[nX,11],;
								aParcial[nX,12],; //dEmiss
								{nX},;
								"",;
								"",;
								"",;
								} )
				Else
					aSE1[nZ][6] += aParcial[nX][6]
					aadd( aSE1[nZ][13], nX )
				EndIf
			EndIF

		EndIf
	Next

	If len(aSE1) > 0

		cQuery := " SELECT MAX(E1_NUM) REG "
		cQuery += " FROM " + RETSQLNAME("SE1") + " SE1 "
		cQuery += " WHERE SE1.E1_FILIAL = ? "
		cQuery += " AND SE1.E1_PREFIXO = 'REN' "
		//cQuery += " AND SE1.D_E_L_E_T_ = ' ' "
		//Foi retirado o delet pois não é para reutilizar numerações já feitas no passado e que estão deletadas.

		LOCACLOSE("TRBVLD")

		cQuery := CHANGEQUERY(cQuery)
		aBindParam := {xFilial("SE1")}
		MPSysOpenQuery(cQuery,"TRBVLD",,,aBindParam)

		cNumTit := TRBVLD->REG
		If empty(cNumTit)
			cNumTit := "000000001"
		Else
			cNumTit := soma1(cNumTit)
		EndIF
		TRBVLD->(dbCloseArea())

		// Gravação da SE1 -> aglutinado
		For nX := 1 to len(aSE1)
			
			nParc    := StrZero( nX, tamsx3("E1_PARCELA")[1] ) 
			
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+aSE1[nX,3]+aSE1[nX,4]))

			aVetSE1 := {}
			aAdd(aVetSE1, {"E1_FILIAL",  xFilial("SE1"), Nil})
			aAdd(aVetSE1, {"E1_NUM",     cNumTit,        Nil})
			aAdd(aVetSE1, {"E1_PREFIXO", "REN",          Nil})
			aAdd(aVetSE1, {"E1_PARCELA", nParc, 		 Nil})
			aAdd(aVetSE1, {"E1_TIPO",    "PR",           Nil})
			aAdd(aVetSE1, {"E1_NATUREZ", cNatureza,      Nil})
			aAdd(aVetSE1, {"E1_CLIENTE", aSE1[nX,3],     Nil})
			aAdd(aVetSE1, {"E1_LOJA",    aSE1[nX,4],     Nil})
			aAdd(aVetSE1, {"E1_NOMCLI",  SA1->A1_NREDUZ, Nil})

			dEmissao := dDataBase
			If cTipoGer == "1" .or. file("\SYSTEM\L108E7.TXT")
				dVenc := aSE1[nX,1]
				// Tentar encontrar a data valida dentro do mês levando dias a mais
				dNewData := DataValida(dVenc, .T.)

				// Tentar encontrar a data valida dentro do mês levando dias a menos
				If (dVenc <> dNewData .and. month(dNewData) <> month(dVenc)) .or. file("\SYSTEM\L108E7.TXT")
					dNewData := DataValida(dVenc, .F.)
				EndIF
			Else
				dNewData := aSE1[nX,1]
			EndIf
			If dNewData < dEmissao
				dEmissao := dNewData
			EndIf

			aAdd(aVetSE1, {"E1_EMISSAO", dEmissao, 				Nil})
			aAdd(aVetSE1, {"E1_VENCTO",  dNewData,              Nil})
			aAdd(aVetSE1, {"E1_VENCREA", dNewData,              Nil})
			aAdd(aVetSE1, {"E1_VALOR",   aSE1[nX,6],            Nil})
			aAdd(aVetSE1, {"E1_HIST",    "RENTAL: "+aSE1[nX,5], Nil})
			aAdd(aVetSE1, {"E1_MOEDA",   FP0->FP0_MOEDA,        Nil})
			aAdd(aVetSE1, {"E1_CCUSTO",  aSE1[nX,10],           Nil})

			If FP0->FP0_MOEDA <> nMV_MOEDA .or. file("\SYSTEM\L108E4.TXT")
				SM2->(dbSetOrder(1))
				SM2->(dbSeek(dtos(dNewData)))
				cCampo := "SM2->M2_TXMOED"+alltrim(str(FP0->FP0_MOEDA))
				aAdd(aVetSE1, {"E1_TXMOEDA", &(cCampo), Nil})
			EndIF

			If lLc13Prv 
				aVetSE1 := EXECBLOCK("LC13PRV", .T., .T., {aVetSE1})
			EndIf

			SED->(dbSetOrder(1))
			SED->(dbSeek(xFilial("SED")+cNatureza))

			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)

			If lMsErroAuto 
				SE1->(DbSetOrder(1))
				If !SE1->(DbSeek(xFilial("SE1")+"REN"+cNumTit+nParc+"PR")) 
					MostraErro()
					DisarmTransaction()
					lErroExec := .t.
				EndIF
			Else
				aSE1[nX][14] := SE1->E1_NUM
				aSE1[nX][15] := SE1->E1_PREFIXO
				aSE1[nX][16] := SE1->E1_PARCELA
			EndIf

		Next

		// Gravação da FQB -> sem aglutinar
		For nX := 1 to len(aFQB)

			cTitu := ""
			cPref := ""
			cParc := ""
			nValo := 0

			For nY := 1 to len(aSE1)
				For nZ := 1 to len(aSE1[nY][13])
					If aSE1[nY][13][nZ] == aFQB[nX][21]
						cTitu := aSE1[nY][14]
						cPref := aSE1[nY][15]
						cParc := aSE1[nY][16]
						nValo := aSE1[nY][6]
					EndIf
				NExt
			Next

			If !empty(cTitu)
				FQB->(RecLock("FQB",.T.))
				FQB->FQB_FILIAL := xFilial("FQB")
				FQB->FQB_PROJET := FP0->FP0_PROJET
				FQB->FQB_OBRA   := aFQB[nX,8]
				FQB->FQB_SEQGRU := aFQB[nX,9]
				FQB->FQB_AS     := aFQB[nX,5]
				FQB->FQB_PR     := cTitu
				FQB->FQB_PREF   := cPref
				FQB->FQB_PARC   := cParc
				FQB->FQB_PERIOD := aFQB[nX,12]
				If cModelo == "A" .and. !file("\SYSTEM\L108E5.TXT")
					FQB->FQB_TIPO	:= "1"
				Else
					FQB->FQB_TIPO	:= "2"
				EndIf
				FQB->FQB_VLRORI := aFQB[nX,6]
				FQB->FQB_SALDO  := aFQB[nX,6] //nValo
				FQB->FQB_MEDICA := ""
				FQB->FQB_MEDSEQ := ""
				FQB->FQB_CODCLI := aFQB[nX,3]
				FQB->FQB_LOJA   := aFQB[nX,4]
				FQB->FQB_TPSE1  := "PR"
				FQB->FQB_SEQ    := strzero(nX,6,0)
				
				lRet := .T.

				cHist := ""

				FQB->FQB_RASTRO := cHist

				FQB->(MsUnlock())
				
			EndIf

		Next

	EndIf

Return lRet


/*/{Protheus.doc} LOCA10808 - antigo LOCA013PER
Calcular o período do próximo faturamento
@type function
@version V1
@author Frank Zwarg Fuga
@since 19/02/2026
/*/
Function LOCA10808(dTemp)
Local dDtIni := stod("")
Local dDtFim := stod("")
Local nDiasTrb := 0
Local dUltFat
Local dProxFat
Local nDiasX := 0
Local dParam := ctod("")
Local lForca := .F.
Local dRetorno := ctod("")

	do case
	case FPA->FPA_TPBASE == "M"
		nDiasTrb := 30
	case FPA->FPA_TPBASE == "Q"
		nDiasTrb := 15
	case FPA->FPA_TPBASE == "S"
		nDiasTrb :=  7
	otherwise
		do case
		case FPA->( fieldpos("FPA_LOCDIA") ) > 0
			nDiasTrb := FPA->FPA_LOCDIA
		case FPA->( fieldpos("FPA_PREDIA") ) > 0
			nDiasTrb := FPA->FPA_PREDIA
		otherwise
			nDiasTrb := FPA->FPA_DTENRE - FPA->FPA_DTINI + 1
		endcase
	endcase

	If empty(dTemp)
		dParam := dDtFimX
		lForca := .T.
	Else
		dParam := dTemp
	EndIF

	dUltFat	 := dParam
	dProxFat := (dParam + nDiasTrb + 1)

	If empty(dDtUltX)
		dDtIni := FPA->FPA_DTINI
	Else
		dDtIni := dDtUltX + 1
	EndIf

	IF FP1->FP1_TPMES == "0"				// MES FECHADO
		nDiasTrb := 30 // quantidade de dias do mês fechado que foi usado
		nDiasX := 30 // quantidade de dias do fator do periodo

		dDtFim := dParam

		dUltFat  := dDtFim
		dProxFat := MONTHSUM(dUltFat,1)

		// somente se o dia for 30 e proximo mes 31
		// se for 29 de janeiro validar o maior dia de fevereiro
		// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
		If day(dProxFat) == 30 .or. (month(dUltFat) == 1 .and. day(dUltFat) == 28)  .or. (month(dUltFat) == 2 .and. (day(dUltFat) == 28.or.day(dUltFat) == 29))
			nMes := month(dproxfat)
			while nMes == month(dproxfat)
				dProxFat ++
			EndDo
			dproxfat := dproxfat - 1
		EndIf

		// Frank em 20/07/22 - somente quando for segundo faturamento em diante
		// considerar os dias corretos para o calculo
		If !empty(dDtUltX)
			nDiasTrb := dDtFim - dDtIni + 1
		EndIf
		If empty(dDtUltX) 
			nDiasTrb := dDtFim - dDtIni + 1
		EndIf

		If !empty(FPA->FPA_DTSCRT)
			If FPA->FPA_DTSCRT < dDtFim
				nDiasTrb := FPA->FPA_DTSCRT - dDtIni + 1
				dDtFim  := FPA->FPA_DTSCRT

				// Frank 21/09/23 - tratamento quanto for 1.fat
				If empty(dDtUltX)
					nDiasTrb := FPA->FPA_DTSCRT - dDtIni + 1
				EndIf
			EndIf
		EndIf
	ElseIf FP1->FP1_TPMES == "1" // MES ABERTO
		IF empty(FPA->FPA_DTSCRT)
			dDtFim := dDtIni + FPA->FPA_LOCDIA - 1
		Else
			If dDtIni + FPA->FPA_LOCDIA - 1 < FPA->FPA_DTSCRT
				dDtFim := dDtIni + FPA->FPA_LOCDIA - 1
			Else
				dDtFim := FPA->FPA_DTSCRT
			EndIf
		EndIf

		// Frank em 23/03/26 - por questão de estar em branco o primeiro faturamento
		If empty(dDtFim) .or. file("\SYSTEM\L108E9.TXT")
			dDtFim := dUltFat + FPA->FPA_LOCDIA
		EndIf

		dUltFat  := dDtFim
		dProxFat := dUltFat + FPA->FPA_LOCDIA

	Else // mes fixo
		dDtFim := dParam
		dUltFat := dDtFim
		dProxFat := monthsum(dUltFat,1)

		// somente se o dia for 30 e proximo mes 31
		// se for 29 de janeiro validar o maior dia de fevereiro
		// frank em 20/07/22 - ajuste do ultimo dia do mes fechado
		If day(dProxFat) == 30 .or. (month(dUltfat) == 1 .and. day(dultfat) == 28)  .or. (month(dUltfat) == 2 .and. (day(dultfat) == 28.or.day(dultfat) == 29))
			nMes := month(dproxfat)
			while nMes == month(dproxfat)
				dProxFat ++
			EndDo
			dproxfat := dproxfat - 1
		EndIf

		If !EMPTY(FPA->FPA_DTSCRT)
			If FPA->FPA_DTSCRT < dDtFim
				dDtFim := FPA->FPA_DTSCRT
			EndIf
		EndIf

		nDias :=  dDtFim - dDtIni + 1

		If month(dDtIni) == 2 .and. month(dDtFim) > 2
			If nDias == 28 .or. nDias == 29
				nDias := 30
			EndIf
		Else
			If month(dDtIni) == 2 .and. month(dDtFim) == 2
				If nDias == 28 .or. nDias == 29
					nDias := 30
				EndIf
			EndIf
		EndIf

		If empty(FPA->FPA_DTSCRT) .and. !empty(dDtUltX)
			nDias := 30
		EndIF

		if (!empty(FPA->FPA_DTSCRT) .or. empty(dDtUltX)) .and. nDias > 30
			nDias := 30
		endif

	EndIf

	dDtFimX := dDtFim
	dDtUltX := dUltFat

	If FP1->FP1_TPMES == "1"
		dRetorno := dDtUltX 
	ElseIf FP1->FP1_TPMES == "0" .or. FP1->FP1_TPMES == "2"
		If lForca
			dRetorno := dDtFim
		Else
			dRetorno := dproxfat
		EndIf
	EndIf

Return dRetorno

/*/{Protheus.doc} LOCA013D2
estorno do provisorio no faturamento automático
@type function
@version v1  
@author Frank Zwarg Fuga
@since 20/02/2026
/*/
Function LOCA013D2(cTipo, cProjeto, cAs, lPeriodo)
Local aAreaFQB := FQB->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local aAreaFP0 := FP0->(GetArea())
Local cExecuta
Local nValor := 0
Local lAltera
Local aFQBDel
Local cProj
Local cPrefixo
Local cParcela
Local cCliente
Local cLoja	
Local cProv
Local nCalculo

Private lMsErroAuto 
Private lErroExec

	FQB->(dbSetOrder(2))
	FQB->(dbSeek(xFilial("FQB")+cProjeto+cAs)) 
	cExecuta := "FQB->(FQB_PROJET+FQB_AS) == cProjeto+cAs"

	While !FQB->(Eof()) .and. &(cExecuta) 
			
		If lPeriodo
			If FQB->FQB_PERIOD > FPA->FPA_ULTFAT
				FQB->(dbSkip())
				Loop
			EndIf
		EndIf

		nValor := FQB->FQB_VLRORI

		lAltera := .T.
		SE1->(dbSetOrder(1))
		SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
		While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
			If SE1->E1_PARCELA == FQB->FQB_PARC
				If SE1->E1_VALOR > nValor
					aVetSE1 := {}
					nCalculo := SE1->E1_VALOR - nValor
					aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL			, Nil})
					aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM			, Nil})
					aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO		, Nil})
					aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA		, Nil})
					aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO			, Nil})
					aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ		, Nil})
					aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE		, Nil})
					aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA			, Nil})
					aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI			, Nil})
					aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO		, Nil})
					aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO			, Nil})
					aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA		, Nil})
					aAdd(aVetSE1, {"E1_VALOR",   nCalculo				, Nil})
					aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA         	, Nil})
					aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO        	, Nil})
					lMsErroAuto := .F.
					lErroExec := .F.
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4)
					//If lMsErroAuto 
					//	lErroExec := .T.
					//EndIf
					lAltera := .T.

					// Função que valida se o movimento foi processado no SE1
					If SE1->E1_VALOR <> nCalculo
						LOCA108E(nCalculo)
					EndIF

				Else
					aVetSE1 := {}
					aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
					aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
					aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
					aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
					aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
					aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
					aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
					aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
					aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
					aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
					aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
					aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
					aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
					aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
					aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
					lMsErroAuto := .F.
					lErroExec := .F.
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)
					If lMsErroAuto 
						lErroExec := .T.
					EndIf
					lAltera := .F.
				EndIf
				If !lErroExec
					If lAltera
						FQB->(RecLock("FQB",.F.))
						FQB->FQB_SALDO := FQB->FQB_SALDO - nValor
						FQB->(MsUnlock())
					Else
						// quando zerar deletar todos os provisorios do movimento em questão
						aFQBDel := FQB->(GetArea())
						cProj := FQB->FQB_PROJET
						cPrefixo := FQB->FQB_PREF
						cProv := FQB->FQB_PR
						cParcela := FQB->FQB_PARC
						cCliente := FQB->FQB_CODCLI
						cLoja := FQB->FQB_LOJA
						FQB->(dbSetOrder(2))
						FQB->(dbSeek(xFilial("FQB")+cProj))
						While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET) == xFilial("FQB")+cProj
							If FQB->FQB_PREF == cPrefixo .and. FQB->FQB_PR == cProv .and. FQB->FQB_PARC == cParcela
								If FQB->FQB_CODCLI == cCliente .and. FQB->FQB_LOJA == cLoja
									FQB->(RecLock("FQB",.F.))
									FQB->(dbDelete())
									FQB->(MsUnlock())
								EndIf
							EndIf
							FQB->(dbSkip())
						EndDo
						FQB->(RestArea(aFQBDel))
					EndIf
				EndIf
			EndIf
			SE1->(dbSkip())
		EndDo

		FQB->(dbSkip())
	EndDo

	FPA->(RestArea(aAreaFPA))
	FQB->(RestArea(aAreaFQB))
	FP0->(RestArea(aAreaFP0))
Return .T.

/*/{Protheus.doc} LOCA10806 - LOCA013DEL
Deleta os títulos provisórios
@type function
@author Frank Zwarg Fuga
@since 07/07/2025
cTipo = 1 chave simples apenas pelo código do projeto
cTipo = 2 chave complexa projeto + as
/*/
Function LOCA10806(cTipo, cProjeto, cAs, lPeriodo, cPedido, lMens, lEntrada)
Local aAreaFQB := FQB->(GetArea())
Local aAreaFPA := FPA->(GetArea())
Local aAreaFP0 := FP0->(GetArea())
Local aVetSE1  := {}
Local lProc    := .F.
Local cExecuta := ""
Local cRastro  := ""
Local aDeleta  := {}
Local nX
Local nY
Local aSE1Atu := {}
Local nAntes := 0
Local nDepois := 0
Local nCalculo

Default lPeriodo := .F.
Default cPedido  := ""
Default lMens    := .F.
Default lEntrada := .F.

	// Só executar se o faturamento automático for de locação
	If !empty(cPedido)
		FPY->(dbSetOrder(1))
		If FPY->(dbSeek(xFilial("FPY")+cPedido+cProjeto))
			If FPY->FPY_TIPFAT <> "P"
				Return .T.
			EndIf
		Else
			Return .T.
		EndIf
	EndIf

	// DSERLOCA-10808 - Frank em 11/02/2026
	FP0->(dbSetOrder(1))
	FP0->(dbSeek(xFilial("FP0")+cProjeto))
	If FP0->FP0_TIPFAT <> "M"
	
		FQB->(dbSetOrder(2))
		If cTipo == 2
			FQB->(dbSeek(xFilial("FQB")+cProjeto+cAs)) // Projeto + AS
			If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET+FQB_AS) == cProjeto+cAs
				lProc := .T.
			EndIf
		Else
			FQB->(dbSeek(xFilial("FQB")+cProjeto)) // Projeto
			If !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->(FQB_PROJET) == cProjeto
				lProc := .T.
			EndIf
		EndIf

		If cTipo == 1
			cExecuta := "FQB->(FQB_PROJET) == cProjeto"
		Else
			cExecuta := "FQB->(FQB_PROJET+FQB_AS) == cProjeto+cAs"
		EndIf

		While !FQB->(Eof()) .and. &(cExecuta) .and. lProc

			If lMens
				ProcessMessages()
			EndIf
			
			If lPeriodo
				If FPA->FPA_ULTFAT <> FQB->FQB_PERIOD
					FQB->(dbSkip())
					Loop
				EndIf
			EndIf

			If empty(cPedido)
				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
				While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
					If SE1->E1_PARCELA == FQB->FQB_PARC
						If SE1->E1_VALOR > FQB->FQB_SALDO
							aVetSE1 := {}
							nCalculo := SE1->E1_VALOR - FQB->FQB_SALDO
							aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL			, Nil})
							aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM			, Nil})
							aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO		, Nil})
							aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA		, Nil})
							aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO			, Nil})
							aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ		, Nil})
							aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE		, Nil})
							aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA			, Nil})
							aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI			, Nil})
							aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO		, Nil})
							aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO			, Nil})
							aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA		, Nil})
							aAdd(aVetSE1, {"E1_VALOR",   nCalculo				, Nil})
							aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA         	, Nil})
							aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO        	, Nil})
							MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4)

							// Função que valida se o movimento foi processado no SE1
							If SE1->E1_VALOR <> nCalculo
								LOCA108E(nCalculo)
							EndIF							

						Else
							aVetSE1 := {}
							aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
							aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
							aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
							aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
							aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
							aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
							aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
							aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
							aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
							aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
							aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
							aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
							aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
							aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
							aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
							MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)
						EndIf
					EndIf

					SE1->(dbSkip())
				EndDo

				FQB->(RecLock("FQB",.F.))

				// Se for nota de entrada armazenaremos o número da mesma
				If lEntrada
					cRastro := ""
					cRastro := FQB->FQB_RASTRO
					cRastro += chr(13) + chr(10)
					cRastro += "<nfe>"
					cRastro += alltrim(SF1->F1_DOC)+"-"
					cRastro += alltrim(SF1->F1_SERIE)+"-"
					cRastro += alltrim(SF1->F1_FORNECE)+"-"
					cRastro += alltrim(SF1->F1_LOJA)+"-"
					cRastro += alltrim(SF1->F1_FORMUL)
					cRastro += "</nfe>"
					FQB->FQB_RASTRO := cRastro + "<saldo>"+alltrim(str(FQB->FQB_SALDO))+"</saldo>"
					FQB->FQB_SALDO := 0
				Else

					FQB->(dbDelete())
					FQB->(MsUnlock())

				EndIf

			Else // Se vier do faturamento automático

				aadd(aDeleta,{FQB->FQB_PR, FQB->FQB_PARC, FQB->FQB_CODCLI, FQB->FQB_LOJA, FQB->FQB_TPSE1, FQB->FQB_PREF, FQB->(Recno()), FQB->FQB_VLRORI, alltrim(FQB->FQB_AS)})
			
			EndIf
					
			FQB->(dbSkip())
		EndDo
	EndIf

	// Trecho exclusivo para quando processado pelo faturamento automático.
	If len(aDeleta) > 0 .and. !empty(cPedido)
		
		For nX := 1 to len(aDeleta)
			FQB->(dbGoto(aDeleta[nX,7]))
			cRastro := ""
			cRastro := FQB->FQB_RASTRO
			cRastro += chr(13) + chr(10)
			cRastro += "<pv>"+alltrim(cPedido)+"</pv>"
			nAntes := FQB->FQB_SALDO
			FQB->(RecLock("FQB",.F.))
			FQB->FQB_SALDO := FQB->FQB_SALDO - aDeleta[nX,8]
			FQB->FQB_RASTRO := cRastro
			FQB->(MsUnlock())
			nDepois := FQB->FQB_SALDO

			lExisteSe1 := .F.
			For nY := 1 to len(aSE1Atu)
				If aSE1Atu[nY,1] == FQB->FQB_PREF .and. aSE1Atu[nY,2] == FQB->FQB_PR .and. aSE1Atu[nY,3] == FQB->FQB_PARC
					lExisteSE1 := .T.
					Exit
				EndIf
			Next

			If !lExisteSe1
				aadd(aSE1Atu,{FQB->FQB_PREF, FQB->FQB_PR, FQB->FQB_PARC, nAntes - nDepois, FQB->FQB_CODCLI, FQB->FQB_LOJA, FQB->FQB_TPSE1 })
			Else
				aSE1Atu[nY,4] += nAntes - nDepois
			EndIf

		Next

		For nX := 1 to len(aSE1Atu)
			SE1->(dbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(dbSeek(xFilial("SE1")+aSE1Atu[nX,5]+aSE1Atu[nX,6]+aSE1Atu[nX,1]+aSE1Atu[nX,2]+aSE1Atu[nX,3]+aSE1Atu[nX,7]))
				If SE1->E1_VALOR - aSE1Atu[nX,4] <= 0
					// deletar
					aVetSE1 := {}
					aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,   Nil})
					aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
					aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
					aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA,  Nil})
					aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
					aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
					aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
					aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,     Nil})
					aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
					aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
					aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,   Nil})
					aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA,  Nil})
					aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
					aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
					aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
					lMsErroAuto := .F.
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5) // Deleta
				Else
					// abater
					aVetSE1 := {}
					nCalculo := SE1->E1_VALOR - aSE1Atu[nX,4]
					aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
					aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
					aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
					aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
					aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
					aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
					aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
					aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
					aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
					aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
					aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
					aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
					aAdd(aVetSE1, {"E1_VALOR",   nCalculo,  Nil})
					aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
					aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
					lMsErroAuto := .F.
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4) // Altera

					// Função que valida se o movimento foi processado no SE1
					If SE1->E1_VALOR <> nCalculo
						LOCA108E(nCalculo)
					EndIF

				EndIf
			EndIf
		Next		

	EndIf

	FPA->(RestArea(aAreaFPA))
	FQB->(RestArea(aAreaFQB))
	FP0->(RestArea(aAreaFP0))
Return

/*/{Protheus.doc} LOCA10809
Tratamento para o cancelamento do pedido de vendas
@type function
@version v1 
@author Frank Zwarg Fuga
@since 25/03/2026
/*/
Function LOCA10809(cPedido,cProjeto)
Local cQuery
Local aBindParam := {}
Local cFiltro := ""
Local nValor := 0
Local aAreaSC6 := SC6->(GetArea())
Local aAreaFPZ := FPZ->(GetArea())
Local aAreaFQB := FQB->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local aAreaFQZ := FQZ->(GetArea())
Local aRetorno := {}
Local nX
Local aAlterado := {}
Local cQuery2
Local aBind2 := {}
Local nCalculo

Default cPedido := ""
Default cProjeto := ""

	If empty(cPedido) .or. empty(cProjeto)
		Return .T.
	EndIf

	FPZ->(dbSetOrder(1))
	FPZ->(dbSeek(xFilial("FPZ")+cPedido))
	While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_PEDVEN) == xFilial("FPZ")+cPedido

		nValor := 0

		aBindParam := {}
		// Intencional não validar o registro deletado
		cQuery := " SELECT SC6.C6_VALOR VLR "
		cQuery += " FROM " + RETSQLNAME("SC6") + " SC6 "
		cQuery += " WHERE "
		cQuery += " SC6.C6_FILIAL = ? AND "
		aadd(aBindParam,xFilial("SC6"))
		cQuery += " SC6.C6_NUM = ? "
		aadd(aBindParam, FPZ->FPZ_PEDVEN  )
		cQuery += " AND SC6.C6_ITEM = ? "
		aadd(aBindParam, FPZ->FPZ_ITEM )
		cQuery := CHANGEQUERY(cQuery)
		MPSysOpenQuery(cQuery,"TRBSC6",,,aBindParam)

		If !TRBSC6->(Eof())
			nValor := TRBSC6->VLR
		EndIF

		aadd(aRetorno, {FPZ->FPZ_PROJET, FPZ->FPZ_AS, nValor})

		FPZ->(dbSkip())
	EndDo

	For nX := 1 to len(aRetorno)

		aBindParam := {}
		cQuery := " SELECT FQB_PROJET, FQB_AS, FQB_PR, FQB_PREF, FQB_PARC, FQB_PERIOD, FQB_RASTRO, FQB_VLRORI, "
		cQuery += " FQB_CODCLI, FQB_LOJA, FQB_TPSE1, R_E_C_N_O_ REG "
		cQuery += " FROM " + RETSQLNAME("FQB") + " FQB "
		cQuery += " WHERE "
		cQuery += " FQB.FQB_FILIAL = ? AND "
		aadd(aBindParam,xFilial("FQB"))
		cQuery += " FQB.FQB_RASTRO LIKE ? "
		cFiltro := "%<pv>"+alltrim(cPedido)+"</pv>%"	
		aadd(aBindParam, cFiltro  )
		cQuery += " AND FQB.FQB_AS = ? "
		aadd(aBindParam, aRetorno[nX,2] )
		cQuery := CHANGEQUERY(cQuery)

		MPSysOpenQuery(cQuery,"TRBFQB",,,aBindParam)

		While !TRBFQB->(Eof())

			FQB->(dbGoto(TRBFQB->REG))

			FQB->(RecLock("FQB",.F.))
			FQB->FQB_SALDO += aRetorno[nX,3]
			FQB->(MsUnlock())

			// Registrar quem foi alterado
			// Registro da FQB e valor que foi retornado com o estorno do pedido
			aadd(aAlterado,{FQB->(Recno()), aRetorno[nX,3] })

			TRBFQB->(dbSkip())
		
		EndDo

	Next

	For nX := 1 to len(aAlterado)
		// Pesquisar o titulo
		FQB->(dbGoto(aAlterado[nX,1]))
		
		SE1->(dbSetOrder(2)) // E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		SE1->(dbSeek(xFilial("SE1")+FQB->(FQB_CODCLI+FQB_LOJA+FQB_PREF+FQB_PR+FQB_PARC+FQB_TPSE1)))
				
		// Se encontrar acrescer o valor
		If !SE1->(Eof())
			aVetSE1 := {}
			nCalculo := SE1->E1_VALOR + aAlterado[nX,2]
			aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
			aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
			aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
			aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
			aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
			aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
			aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
			aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
			aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
			aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
			aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
			aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
			aAdd(aVetSE1, {"E1_VALOR",   nCalculo, 			Nil})
			aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
			aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4) // Altera

			// Função que valida se o movimento foi processado no SE1
			If SE1->E1_VALOR <> nCalculo
				LOCA108E(nCalculo)
			EndIF

		EndIF

		// Se não encontrar, localizar o registro deletado, voltar ele a alterar o valor com o valor original da FQB
		If SE1->(Eof())
			aBind2 := {}
			cQuery2 := " SELECT MAX(SE1.R_E_C_N_O_) REG "
			cQuery2 += " FROM " + RETSQLNAME("SE1") + " SE1 "
			cQuery2 += " WHERE SE1.D_E_L_E_T_ = '*' AND " // buscar o item deletado
			cQuery2 += " SE1.E1_FILIAL = ? AND "
			aadd(aBind2,xFilial("SE1"))
			cQuery2 += " SE1.E1_CLIENTE = ? AND "			
			aadd(aBind2,FQB->FQB_CODCLI)
			cQuery2 += " SE1.E1_LOJA = ? AND "			
			aadd(aBind2,FQB->FQB_LOJA)
			cQuery2 += " SE1.E1_PREFIXO = ? AND "			
			aadd(aBind2,FQB->FQB_PREF)
			cQuery2 += " SE1.E1_NUM = ? AND "			
			aadd(aBind2,FQB->FQB_PR)
			cQuery2 += " SE1.E1_PARCELA = ? AND "			
			aadd(aBind2,FQB->FQB_PARC)
			cQuery2 += " SE1.E1_TIPO = ? "			
			aadd(aBind2,FQB->FQB_TPSE1)

			cQuery2 := CHANGEQUERY(cQuery2)

			MPSysOpenQuery(cQuery2,"TRBSE1",,,aBind2)

			// Recuperar a SE1
			SE1->(dbGoto(TRBSE1->REG))
			SE1->(RecLock("SE1",.F.))
			SE1->(dbRecall())
			SE1->(MsUnlock())

			aVetSE1 := {}
			aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
			aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
			aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
			aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
			aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
			aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
			aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
			aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
			aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
			aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
			aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
			aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
			aAdd(aVetSE1, {"E1_VALOR",   FQB->FQB_SALDO, Nil})
			aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
			aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4) // Altera

			// Ajustado em 17/07/2026 por questão da contabilização
			If SE1->E1_VALOR <> FQB->FQB_SALDO
				LOCA108E(FQB->FQB_SALDO)
			EndIf

		EndIf
	Next

	SC6->(RestArea(aAreaSC6))
	FPZ->(RestArea(aAreaFPZ))
	FQB->(RestArea(aAreaFQB))
	SE1->(RestArea(aAreaSE1))
	FQZ->(RestArea(aAreaFQZ))

Return


/*/{Protheus.doc} LOCA1080A
Tratamento para o cancelamento da nota fiscal de entrada
@type function
@version v1 
@author Frank Zwarg Fuga
@since 27/03/2026
/*/
Function LOCA1080A()
Local cQuery
Local cQuery2
Local aBindParam := {}
Local cFiltro := ""
Local aVetSE1 := {}
Local aBind2 := {}
Local nSaldo := 0
Local nCalculo

	// intensional o filtro por deletados
	aBindParam := {}

	cQuery := " SELECT FQB_PROJET, FQB_AS, FQB_PR, FQB_PREF, FQB_PARC, FQB_PERIOD, FQB_RASTRO, FQB_VLRORI, "
	cQuery += " FQB_CODCLI, FQB_LOJA, FQB_TPSE1, R_E_C_N_O_ REG "
	cQuery += " FROM " + RETSQLNAME("FQB") + " FQB "
	cQuery += " WHERE FQB.D_E_L_E_T_ = ' ' AND "
	cQuery += " FQB.FQB_FILIAL = ? AND "
	aadd(aBindParam,xFilial("FQB"))
	cQuery += " FQB.FQB_RASTRO LIKE ? "
	
	cFiltro := "%<nfe>"
	cFiltro += alltrim(SF1->F1_DOC)+"-"
	cFiltro += alltrim(SF1->F1_SERIE)+"-"
	cFiltro += alltrim(SF1->F1_FORNECE)+"-"
	cFiltro += alltrim(SF1->F1_LOJA)+"-"
	cFiltro += alltrim(SF1->F1_FORMUL)
	cFiltro += "</nfe>%"

	aadd(aBindParam, cFiltro  )

	cQuery := CHANGEQUERY(cQuery)

	MPSysOpenQuery(cQuery,"TRBFQB",,,aBindParam)

	While !TRBFQB->(Eof())

		FQB->(dbGoto(TRBFQB->REG))

		SE1->(dbSetOrder(2))
		SE1->(dbSeek(xFilial("SE1")+TRBFQB->(FQB_CODCLI+FQB_LOJA+FQB_PREF+FQB_PR+FQB_PARC+FQB_TPSE1)))

		// Se o SE1 existe devemos acrescer o valor
		If !SE1->(Eof())
			aVetSE1 := {}
			nCalculo := SE1->E1_VALOR + TRBFQB->FQB_VLRORI
			aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL, Nil})
			aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM, Nil})
			aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO, Nil})
			aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, Nil})
			aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO, Nil})
			aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ, Nil})
			aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE, Nil})
			aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA, Nil})
			aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI, Nil})
			aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO, Nil})
			aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO, Nil})
			aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, Nil})
			aAdd(aVetSE1, {"E1_VALOR",   nCalculo, Nil})
			aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA, Nil})
			aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO, Nil})
			lMsErroAuto := .F.
			MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4) // Altera

			// Função que valida se o movimento foi processado no SE1
			If SE1->E1_VALOR <> nCalculo
				LOCA108E(nCalculo)
			EndIF

		EndIf

		// Se o SE1 não existe mais voltaremos com ele
		If SE1->(Eof())

			aBind2 := {}
			cQuery2 := " SELECT SE1.R_E_C_N_O_ REG "
			cQuery2 += " FROM " + RETSQLNAME("SE1") + " SE1 "
			cQuery2 += " WHERE SE1.D_E_L_E_T_ = '*' AND " // buscar o item deletado
			cQuery2 += " SE1.E1_FILIAL = ? AND "
			aadd(aBind2,xFilial("SE1"))
			cQuery2 += " SE1.E1_CLIENTE = ? AND "			
			aadd(aBind2,TRBFQB->FQB_CODCLI)
			cQuery2 += " SE1.E1_LOJA = ? AND "			
			aadd(aBind2,TRBFQB->FQB_LOJA)
			cQuery2 += " SE1.E1_PREFIXO = ? AND "			
			aadd(aBind2,TRBFQB->FQB_PREF)
			cQuery2 += " SE1.E1_NUM = ? AND "			
			aadd(aBind2,TRBFQB->FQB_PR)
			cQuery2 += " SE1.E1_PARCELA = ? AND "			
			aadd(aBind2,TRBFQB->FQB_PARC)
			cQuery2 += " SE1.E1_TIPO = ? "			
			aadd(aBind2,TRBFQB->FQB_TPSE1)

			cQuery2 := CHANGEQUERY(cQuery2)

			MPSysOpenQuery(cQuery2,"TRBSE1",,,aBind2)

			// Recuperar a SE1
			SE1->(dbGoto(TRBSE1->REG))
			SE1->(RecLock("SE1",.F.))
			SE1->(dbRecall())
			SE1->(MsUnlock())

		EndIf

		// Recuperar a FQB
		FQB->(RecLock("FQB",.F.))
		//FQB->(dbRecall())   <saldo>   </saldo>
		nSaldo := substr(FQB->FQB_RASTRO,at("<saldo>",FQB->FQB_RASTRO)+7,at("</saldo>",FQB->FQB_RASTRO)-at("<saldo>",FQB->FQB_RASTRO)-7)
		FQB->FQB_SALDO := val(nSaldo)
		FQB->(MsUnlock())
		TRBFQB->(dbSkip())
	
	EndDo

Return


/*/{Protheus.doc} LOCA1080B
Tratamento para o conflito de títulos provisórios no modelo antigo
É obrigatório estar posicionado na FP0
@type function
@version v1 
@author Frank Zwarg Fuga
@since 30/03/2026
/*/
Function LOCA1080B(lMens)
Local lMV_LOC278 := .F.
Local lRet := .T.
Local lErro := .F.

Default lMens := .T.

	If FP0->(FieldPos("FP0_PROV")) > 0
		If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
			lMV_LOC278 := .T.
		Else
			lMV_LOC278 := .F.
		EndIf
	EndIf
	If lMV_LOC278

		If FQB->(fieldpos("FQB_RASTRO")) == 0
			Return .F.
		EndIf

		FQB->(dbSetOrder(2))		
		FQB->(dbSeek(xFilial("FQB")+FP0->FP0_PROJET))
		While !FQB->(Eof()) .and. FQB->FQB_FILIAL == xFilial("FQB") .and. FQB->FQB_PROJET == FP0->FP0_PROJET
			If FQB->FQB_TIPO <> "1"
				lErro := .T.
				Exit
			EndIf
			FQB->(dbSkip())
		EndDo
	EndIf

	If lErro
		PROCESSA({|| LOCA108C1(FP0->FP0_PROJET, FP0->FP0_PROJET)}, STR0010,STR0011) //"Processando"###"Gerando os títulos provisórios"
	EndIf
	
Return lRet


/*/{Protheus.doc} LOCA108C
ReGeração dos títulos provisórios
@type function
@version v1 
@author Frank Zwarg Fuga
@since 30/03/2026
/*/
Function LOCA108C()
Local aPergs := {}
Local aRet   := {}

	aAdd( aPergs ,{1, STR0006, space(TamSx3("FPA_PROJET")[1]), "@!", "", "FP0", ".T.", 50, .F.}) // "Projeto de ?"
	aAdd( aPergs ,{1, STR0007, Replicate("Z",TamSx3("FPA_PROJET")[1]), "@!", "", "FP0", ".T.", 50, .T.}) // "Projeto até ?"
	
	If ParamBox(aPergs , STR0008,@aRet,,,,,,,,.F.) //"Seleção para geração dos provisórios"
		If MsgYesNo(STR0009,STR0005) //"Confirma a geração dos provisórios?"###"Atenção!"
			PROCESSA({|| LOCA108C1(aRet[1], aRet[2])}, STR0010,STR0011) //"Processando"###"Gerando os títulos provisórios"
		EndIf
	EndIf
	
Return .T.

/*/{Protheus.doc} LOCA108C1
Geração em lote dos títulos provisórios
@type function
@version v1 
@author Frank Zwarg Fuga
@since 31/03/2026
/*/
Function LOCA108C1(cProjd, cproja)
Local nReg := 0
Local cQuery
Local aBindParam := {}
Local aParcial := {}
Local cRastro := ""
Local aSE1 := {}
Local nX
Local nY
Local aVetSE1 := {}
Local dDataOld := dDataBase
Local aRegistros := {}
Local aErros := {}
Local lErro := .F.
Local cErro := ""
Local nCalculo
Local aParcTmp1 := {}
Local aParcTmp2 := {}
	
	aBindParam := {}
	Aadd(aBindParam, cProjd)
	Aadd(aBindParam, cProja)

	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery += " FROM "+RetSQLName("FP0")+" FP0"
	cQuery += " WHERE FP0.FP0_FILIAL = '"+xFilial("FP0")+"'"
	cQuery += " AND FP0.FP0_PROJET >= ? "
	cQuery += " AND FP0.FP0_PROJET <= ? "
	cQuery += " AND FP0.D_E_L_E_T_ = ' ' "
	cQuery := CHANGEQUERY(cQuery)
	MPSysOpenQuery(cQuery,"TRBFP0",,,aBindParam)

	nTotReg := TRBFP0->TOTAL

	ProcRegua(nTotReg)

	aBindParam := {}
	Aadd(aBindParam, cProjd)
	Aadd(aBindParam, cProja)

	cQuery := " SELECT FP0.R_E_C_N_O_ REG "
	cQuery += " FROM "+RetSQLName("FP0")+" FP0"
	cQuery += " WHERE FP0.FP0_FILIAL = '"+xFilial("FP0")+"'"
	cQuery += " AND FP0.FP0_PROJET >= ? "
	cQuery += " AND FP0.FP0_PROJET <= ? "
	cQuery += " AND FP0.D_E_L_E_T_ = ' ' "
	cQuery := CHANGEQUERY(cQuery)
	MPSysOpenQuery(cQuery,"TRBFP0",,,aBindParam)

	While !TRBFP0->(Eof()) 

		nReg ++

		FP0->(dbGoto(TRBFP0->REG))

		IncProc(STR0023 + cValToChar(nReg) + " " + STR0013 + cValToChar(nTotReg) + " " + STR0024 + " " + alltrim(FP0->FP0_PROJET) )
		SysRefresh()
		
		// 1. Orçamento válido
		If FP0->FP0_STATUS $ ("4,6,7,8,A,B,C,2")
			TRBFP0->(dbSkip())
			Loop
		EndIf

		// 2. Que na capa do projeto indique que haverá a geração de títulos provisórios
		If FP0->FP0_PROV <> "1" .and. FP0->FP0_PROV <> "2"
			TRBFP0->(dbSkip())
			Loop
		EndIf
		
		// 7. Com base nos faturamentos feitos abater o valor da FQB
		// 8. Com o saldo da FQB gerar os SE1 aglutinados

		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))

		aRegistros := {}

		While !FPA->(Eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == FP0->FP0_PROJET

			// 3. Orçamento com AS gerada
			If empty(FPA->FPA_AS)
				FPA->(dbSkip())
				Loop
			EndIf

			// 4. AS sem devolução total
			If !empty(FPA->FPA_NFRET)
				FPA->(dbSkip())
				Loop
			EndIf

			// 6. Não é para gerar os movimentos para o tipo medição
			If FP0->FP0_TIPFAT == "M"
				FPA->(dbSkip())
				Loop
			EndIf

			// 7. Controle no preenchimento dos campos obrigatórios
			If FPA->FPA_QUANT == 0  .or. FPA->FPA_VRHOR == 0 
				FPA->(dbSkip())
				Loop
			EndIf

			// 8. Controle no preenchimento da FPA_QTDPRC
			If FPA->FPA_QTDPRC == 0
				FPA->(dbSkip())
				Loop
			EndIF

			aadd(aRegistros,FPA->(Recno()))

			FPA->(dbSkip())

		EndDo

		For nX := 1 to len(aRegistros)

			FPA->(dbGoto(aRegistros[nX]))

			// Deletar os movimentos existentes
			FQB->(dbSetOrder(2))
			FQB->(dbSeek(xFilial("FQB")+FPA->FPA_PROJET))
			While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET) == xFilial("FQB")+FPA->FPA_PROJET

				If FQB->FQB_AS <> FPA->FPA_AS
					FQB->(dbSkip())
					Loop
				EndIf

				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR))
				While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR
					aVetSE1 := {}
					aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
					aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
					aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
					aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
					aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
					aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
					aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
					aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
					aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
					aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
					aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
					aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
					aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
					aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
					aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
					MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)
					SE1->(dbSkip())
				EndDo

				SE1->(dbSetOrder(1))
				If !SE1->(dbSeek(xFilial("SE1")+FQB->FQB_PREF+FQB->FQB_PR)) .and. !file("\system\loc108err2.txt")
					FQB->(RecLock("FQB",.F.))
					FQB->FQB_RASTRO := ""
					FQB->(dbDelete())
					FQB->(MsUnlock())
				Else
					aadd(aErros,{FQB->(Recno()),FQB->FQB_AS,FQB->FQB_PROJET})
				EndIf

				FQB->(dbSkip())
			EndDo

		Next

		// 2. Passo recriar os movimentos
		For nX := 1 to len(aRegistros)

			FPA->(dbGoto(aRegistros[nX]))

			lErro := .F.
			For nY :=1 to len(aErros)
				If aErros[nY,2] == FPA->FPA_AS
					lErro := .T.
					Exit
				EndIf
			Next

			If lErro
				Loop
			EndIf

			aSe1 := {}
	
			dDataBase := FPA->FPA_DTINI

			// Identificar os períodos válidos para a AS posicionada
			// o 5 parâmetro força a data do ultimo faturamento com em branco
			aParcTmp1 := LOCA10803( , , .F., FPA->FPA_AS, .T.)

			If len(aParcTmp1) > 0
				aadd(aParcTmp2, aParcTmp1)
			endIf
		
		Next

		For nX := 1 to len(aParcTmp2)
			For nY := 1 to len(aParcTmp2[nX])
				aadd(aParcial, { aParcTmp2[nX][nY][1],;
					aParcTmp2[nX][nY][2],;
					aParcTmp2[nX][nY][3],;
					aParcTmp2[nX][nY][4],;
					aParcTmp2[nX][nY][5],;
					aParcTmp2[nX][nY][6],;
					aParcTmp2[nX][nY][7],;
					aParcTmp2[nX][nY][8],;
					aParcTmp2[nX][nY][9],;
					aParcTmp2[nX][nY][10],;
					aParcTmp2[nX][nY][11],;
					aParcTmp2[nX][nY][12],;
					aParcTmp2[nX][nY][13],;
					aParcTmp2[nX][nY][14],;
					aParcTmp2[nX][nY][15],;
					aParcTmp2[nX][nY][16],;
					aParcTmp2[nX][nY][17],;
					aParcTmp2[nX][nY][18],;
					aParcTmp2[nX][nY][19],;
					aParcTmp2[nX][nY][20] } )
			Next
		Next
		
		aSe1 := {}
		If len(aParcial) > 0
			LOCA10802(aParcial, "A", "", .F.)

			For nX := 1 to len(aRegistros)

				FPA->(dbGoto(aRegistros[nX]))
				
				// Neste momento foi criado a FQB e o SE1.
				// Agora precisamos abater da FQB e do SE1 os itens que foram faturados.
				FPZ->(dbSetOrder(2))
				FPZ->(dbSeek(xFilial("FPZ")+FPA->FPA_AS))
				While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FPA->FPA_AS

					If FPZ->FPZ_EXTRA == "S" .or. empty(FPZ->FPZ_DTFIM)
						FPZ->(dbskip())
						Loop
					EndIf
					FPY->(dbSetOrder(1))
					FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
					If FPY->FPY_TIPFAT == "P"
						FQB->(dbSetOrder(2))
						FQB->(dbSeek(xFilial("FQB")+FPA->(FPA_PROJET+FPA_AS)))
						While !FQB->(Eof()) .and. FQB->(FQB_FILIAL+FQB_PROJET+FQB_AS) == xFilial("FQB")+FPA->(FPA_PROJET+FPA_AS)
							If FQB->FQB_PERIOD == FPZ->FPZ_DTFIM
								cRastro := ""
								cRastro := FQB->FQB_RASTRO
								cRastro += chr(13) + chr(10)
								cRastro += "<pv>"+alltrim(FPZ->FPZ_PEDVEN)+"</pv>"
								FQB->(RecLock("FQB",.F.))
								If FQB->FQB_SALDO - FPZ->FPZ_TOTAL < 0
									FQB->FQB_SALDO := 0
								Else
									FQB->FQB_SALDO := FQB->FQB_SALDO - FPZ->FPZ_TOTAL
								EndIf
								FQB->FQB_RASTRO := cRastro
								FQB->(MsUnlock())
								aadd(aSE1,{FQB->FQB_PREF,FQB->FQB_PR,FQB->FQB_PARC,FQB->FQB_CODCLI,FQB->FQB_LOJA,FQB->FQB_TPSE1,FPZ->FPZ_TOTAL})
							EndIF
							FQB->(dbSkip())
						EndDo
					EndIF
					FPZ->(dbSkip())
				EndDo
			Next
		EndIf

		If len(aSE1) > 0

			For nX := 1 to len(aSE1)

				SE1->(dbSetOrder(1))
				SE1->(dbSeek(xFilial("SE1")+aSE1[nX,1]+aSE1[nX,2]))
				While !SE1->(Eof()) .and. SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM) == xFilial("SE1")+aSE1[nX,1]+aSE1[nX,2]

					If SE1->E1_PARCELA == aSE1[nX,3] .and. SE1->(E1_CLIENTE+E1_LOJA) == aSE1[nX,4]+aSE1[nX,5]
						If SE1->E1_VALOR > aSE1[nX,7]
							aVetSE1 := {}
							nCalculo := SE1->E1_VALOR - aSE1[nX,7]
							aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL			, Nil})
							aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM			, Nil})
							aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO		, Nil})
							aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA		, Nil})
							aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO			, Nil})
							aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ		, Nil})
							aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE		, Nil})
							aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA			, Nil})
							aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI			, Nil})
							aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO		, Nil})
							aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO			, Nil})
							aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA		, Nil})
							aAdd(aVetSE1, {"E1_VALOR",   nCalculo				, Nil})
							aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA         	, Nil})
							aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO        	, Nil})
							MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 4)

							// Função que valida se o movimento foi processado no SE1
							If SE1->E1_VALOR <> nCalculo
								LOCA108E(nCalculo)
							EndIF

						Else
							aVetSE1 := {}
							aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,  	Nil})
							aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,      Nil})
							aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,  Nil})
							aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA, 	Nil})
							aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,     Nil})
							aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  Nil})
							aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  Nil})
							aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
							aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   Nil})
							aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  Nil})
							aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
							aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
							aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    Nil})
							aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    Nil})
							aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   Nil})
							MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)
						EndIf
					EndIf
					SE1->(dbSkip())
				EndDo
			Next
		EndIf
		
		TRBFP0->(dbSkip())
	EndDo

	dDataBase := dDataOld

	cErro := ""
	For nX := 1 to len(aErros)
		If len(cErro) > 0 .or. file("\system\loc108err1.txt")
			cErro := "; "
		EndIf
		cErro += aErros[nX,3]	
	Next
	If len(cErro) > 0
		Help(Nil,	Nil,STR0015+alltrim(upper(Procname())),; //"RENTAL: "
			Nil,STR0016,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
			{STR0022 + cErro})  //"Não foi possível recriar os registros provisórios, providencie a deleção manual no contas a receber e execute novamente esta rotina, para os seguintes contratos: "
	EndIf

Return

/*/{Protheus.doc} LOCA108D
Validação quanto a alteração para casos de titulos provisórios
Uso em valids da tabela FPA
Neste caso a FP0 já estará posicionada
@type function
@version v1
@author Frank Zwarg Fuga
@since 01/07/2026
/*/
Function LOCA108D(cCampo)
Local lRet := .T.
Local lMV_LOC278 := .F.
Local nPos := ascan(oDlgPla:aHeader,{|X|alltrim(X[2])==alltrim(cCampo)})
Local nPos1 := ascan(oDlgPla:aHeader,{|X|alltrim(X[2])==alltrim("FPA_AS")})
Local lValida := .F.
Local cDesc := ""

	If FQB->(fieldpos("FQB_RASTRO")) == 0
		Return .T.
	EndIf

	If Readvar() $ ("M->FPA_DTINI,M->FPA_DTFIM,M->FPA_QTDPRC") .and. FP0->FP0_TIPFAT <> "M" .and. !empty(oDlgPla:aCols[oDlgPla:nAt][nPos1])
		lValida := .T.
	EndIf

	If lValida

		If Readvar() == "M->FPA_DTINI"
			cDesc := "data inicial"
		ElseIf Readvar() == "M->FPA_DTFIM"
			cDesc := "prox.faturamento"
		ElseIf Readvar() == "M->FPA_QTDPRC"
			cDesc := "qtd.parcelas"
		EndIf
		
		If FP0->(FieldPos("FP0_PROV")) > 0
			If FP0->FP0_PROV == "1" .or. FP0->FP0_PROV == "2"
				lMV_LOC278 := .T.
			Else
				lMV_LOC278 := .F.
			EndIf
		EndIf

		If lMV_LOC278
			If oDlgPla:aCols[oDlgPla:nAt][nPos] <> &(ReadVar(cCampo))
				If !MsgYesNo(STR0018+" "+cDesc+" "+STR0019+" "+alltrim(str(oDlgPla:nAt))+" "+STR0020+" "+STR0021,STR0005) //###"Atenção!"
					// O campo xxx do item yyy do contrato foi alterado. Essa alteração pode tornar os registros provisórios divergentes em relação aos dados atuais do contrato. Recomenda-se executar a rotina Recálculo do Provisório para atualizá-los. Você tem certeza de que deseja confirmar essa alteração? 
					lRet := .F.
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} LOCA108E
Rotina para exclusão e recriação do contas a receber
@type function
@version v1  
@author Frank Zwarg Fuga
@since 15/07/2026
/*/
Function LOCA108E(nCalculo)
Local aVetSE1 := {}
Local lRet := .T.
Local cFilx
Local cNumx
Local cPrex
Local cParx
Local cTipx
Local cNatx
Local cClix
Local cLojx
Local cNomx
Local dEmix
Local dVenx
Local dVerx
Local cMoex
Local cCusx
	
	cFilx := SE1->E1_FILIAL
	cNumx := SE1->E1_NUM
	cPrex := SE1->E1_PREFIXO
	cParx := SE1->E1_PARCELA
	cTipx := SE1->E1_TIPO
	cNatx := SE1->E1_NATUREZ
	cClix := SE1->E1_CLIENTE
	cLojx := SE1->E1_LOJA
	cNomx := SE1->E1_NOMCLI
	dEmix := SE1->E1_EMISSAO
	dVenx := SE1->E1_VENCTO
	dVerx := SE1->E1_VENCREA
	cMoex := SE1->E1_MOEDA
	cCusx := SE1->E1_CCUSTO

	// 1. Passo deletar o registro atual
	aVetSE1 := {}
	aAdd(aVetSE1, {"E1_FILIAL",  SE1->E1_FILIAL,	Nil})
	aAdd(aVetSE1, {"E1_NUM",     SE1->E1_NUM,		Nil})
	aAdd(aVetSE1, {"E1_PREFIXO", SE1->E1_PREFIXO,	Nil})
	aAdd(aVetSE1, {"E1_PARCELA", SE1->E1_PARCELA,	Nil})
	aAdd(aVetSE1, {"E1_TIPO",    SE1->E1_TIPO,		Nil})
	aAdd(aVetSE1, {"E1_NATUREZ", SE1->E1_NATUREZ,  	Nil})
	aAdd(aVetSE1, {"E1_CLIENTE", SE1->E1_CLIENTE,  	Nil})
	aAdd(aVetSE1, {"E1_LOJA",    SE1->E1_LOJA,    	Nil})
	aAdd(aVetSE1, {"E1_NOMCLI",  SE1->E1_NOMCLI,   	Nil})
	aAdd(aVetSE1, {"E1_EMISSAO", SE1->E1_EMISSAO,  	Nil})
	aAdd(aVetSE1, {"E1_VENCTO",  SE1->E1_VENCTO,  	Nil})
	aAdd(aVetSE1, {"E1_VENCREA", SE1->E1_VENCREA, 	Nil})
	aAdd(aVetSE1, {"E1_VALOR",   SE1->E1_VALOR,    	Nil})
	aAdd(aVetSE1, {"E1_MOEDA",   SE1->E1_MOEDA,    	Nil})
	aAdd(aVetSE1, {"E1_CCUSTO",  SE1->E1_CCUSTO,   	Nil})
	MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 5)

	// 2. Passo recriar o registro com a alteração do valor
	SE1->(dbSetOrder(1))
	If !SE1->(dbSeek(xFilial("SE1")+cPrex+cNumx+cParx))
		aVetSE1 := {}
		aAdd(aVetSE1, {"E1_FILIAL",  cFilx,		Nil})
		aAdd(aVetSE1, {"E1_NUM",     cNumx,		Nil})
		aAdd(aVetSE1, {"E1_PREFIXO", cPrex,		Nil})
		aAdd(aVetSE1, {"E1_PARCELA", cParx,		Nil})
		aAdd(aVetSE1, {"E1_TIPO",    cTipx,		Nil})
		aAdd(aVetSE1, {"E1_NATUREZ", cNatx,  	Nil})
		aAdd(aVetSE1, {"E1_CLIENTE", cClix,  	Nil})
		aAdd(aVetSE1, {"E1_LOJA",    cLojx,    	Nil})
		aAdd(aVetSE1, {"E1_NOMCLI",  cNomx,   	Nil})
		aAdd(aVetSE1, {"E1_EMISSAO", dEmix,  	Nil})
		aAdd(aVetSE1, {"E1_VENCTO",  dVenx,  	Nil})
		aAdd(aVetSE1, {"E1_VENCREA", dVerx, 	Nil})
		aAdd(aVetSE1, {"E1_VALOR",   nCalculo, 	Nil})
		aAdd(aVetSE1, {"E1_MOEDA",   cMoex,    	Nil})
		aAdd(aVetSE1, {"E1_CCUSTO",  cCusx,   	Nil})
		MSExecAuto({|x,y| FINA040(x,y)}, aVetSE1, 3)
	EndIF

Return lRet


/*/{Protheus.doc} LOCA108F
Valida o uso dos títulos provisórios
@type function
@version v1  
@author Frank Zwarg Fuga
@since 20/07/2026
/*/
Function LOCA108F
Local lRet := .T.
	If FQB->(FIELDPOS("FQB_VLRORI")) == 0 .or. FQB->(FIELDPOS("FQB_SALDO")) == 0 .or. FQB->(FIELDPOS("FQB_RASTRO")) == 0
		Help(Nil,	Nil,STR0015+alltrim(upper(Procname())),; //"RENTAL: "
					Nil,STR0016,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
					{STR0029}) //"Para utilizar os títulos provisórios, é necessário atualizar o dicionário de dados por meio da rotina UPDDISTR."
		lRet := .F.
	EndIf
Return lRet

// Passagem de advpr
Function LOCA108ADV
Local lRet := .T.
Return lRet
