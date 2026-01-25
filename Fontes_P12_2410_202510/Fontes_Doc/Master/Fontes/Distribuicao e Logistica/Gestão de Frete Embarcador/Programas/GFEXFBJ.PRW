#INCLUDE 'PROTHEUS.CH'
#INCLUDE "GFEXFUNB.CH"

/*----------------------------------------------------------------------------
{Protheus.doc} GravaFrete
Grava Frete.
Uso: GFECLCFRT

Obs: Transferida a função GravaFrete para o fonte GFEXFBJ no projeto de refatoração
Data: 09/05/2018

@param nTabProv	Indica se deve ser usada a tabela de provisão
@sample GravaFrete(.T.)

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function GFEGravaFrete(nTabProv,cOriCalc)
	Local nY
	Local nSeq
	Local aStru
	Local cCredPC
	Local cFilCalc
	Local cCompImp
	Local aAreaTRE
	Local lLotaVeic
	Local cCredPCTF
	Local nF 		 := 0
	Local nX 		 := 1
	Local nPos		 := 0
	Local nRecGWI	 := 0
	Local nQtCalc    := 0
	Local cFilCod    := ""
	Local cMsg       := ""
	Local cAgruPC    := ""
	Local cFinCalc, cTpTransp, cEmiRed, cTpCalculo, lTemUsoCons := .F.
	Local aCalcDocs   	:= {}	// Array para os calculos existente a serem verificados
	Local aDoctoCarga 	:= {}	// Array para os documentos de carga que estão sendo calculados
	Local lGravaCalc  	:= .T.	// Indica se o calculo ao qual o documento de carga esta vinculado pode ser gravado
	Local lDesfazCalc 	:= .F.	// indica se o calculo deve ser desfeito porque uma das validações excedeu os limites dos parametros
	Local cRetVlrMax  	:= "0" 	// Indica as ações a serem tomadas se algum valor exceder os limites dos parametros
	Local aErrSrv       := {}
	Local aCalcNum      := {}
	Local aMultFil      := {}
	Local lCrdSim       := .F.
	Local lCrdPcItem    := .F.
	Local cUserFrete    := cUserName
	Local cRomFil       := cFilAnt
	Local lPEXFB09	    := ExistBlock("GFEXFB09")
	Local lExiSITFRE    := GFXCP12117("GW1_SITFRE")
	Local cCredIcms     := GetNewPar("MV_GFECRIC", "1")
	Local cFormCredICMS := GetNewPar("MV_CRDPAR", "1")
	Local lCalcPc       := SuperGetMv("MV_GFEOPC",.F.,"0") == "1" // Calcula o peso cubado
	Local cAcGrRat      := SuperGetMv("MV_ACGRRAT",.F.,"1")
	Local cIcmsSt       := SuperGetMv("MV_ICMSST",,"1")
	Local s_INTFRE	    := SuperGetMV('MV_INTFRE',.F.,'1')
	Local cNrDC			:= ""
	Local cNrRom		:= ""
	Local cGW1Alias
	
	Default cOriCalc := "2"

	dbSelectarea("GWN")
	lLotaVeic := GFEVerCmpo({"GWN_FECHAM"})
	If Empty(cUserFrete)
		cUserFrete := "INTEGRACAO"
	EndIf

	// Carregando array auxiliar para identificar filiais de geração dos registros de calculo para uso de calculo com DC de multiplas filiais
	For nX := 1 To Len(aTRBTRE1)
		nPos := aScan(aMultFil, {|x| x[1] == aTRBTRE1[nX][20]})
		If nPos == 0
			aadd(aMultFil, {aTRBTRE1[nX][20], '', {}})
			aadd(aTail(aMultFil)[3], {aTRBTRE1[nX][1], aTRBTRE1[nX][2], aTRBTRE1[nX][3], aTRBTRE1[nX][4], aTRBTRE1[nX][5], {}})
		Else
			aadd(aMultFil[nPos][3], {aTRBTRE1[nX][1], aTRBTRE1[nX][2], aTRBTRE1[nX][3], aTRBTRE1[nX][4], aTRBTRE1[nX][5], {}})
		EndIf
	Next

	oGFEXFBFLog:setTexto(CRLF + STR0277 + CRLF + CRLF) //"5. Gravando cálculos de frete..."

	// Verifica se os documentos de carga possuem calculos de frete na base
	oGFEXFBFLog:setTexto(STR0278 + CRLF + CRLF) //"  Procurando cálculos de frete para os documentos de carga..."

	GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1) 
	GFEXFB_2TOP(lTabTemp, cTRBDOC, @aDocCarg, 1) 
	While !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1) 

		// Adiciona o documento de carga no array, que será usado na validação mais abaixo
		aAdd(aDoctoCarga,GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC"))

		nQtCalc := len(aCalcDocs)

		GWH->(dbSetOrder(02))
		GWH->(dbSeek(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"FILIAL")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC")))
		While !GWH->(Eof()) .AND. GWH->GWH_FILIAL == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"FILIAL") .AND. GWH->GWH_EMISDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC") .AND. GWH->GWH_SERDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC") .AND. GWH->GWH_NRDC == GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC")
			GWF->(dbSetOrder(01))
			If GWF->(dbSeek(GWH->GWH_FILIAL + GWH->GWH_NRCALC))
				If aScan(aCalcDocs,{|cNrCalc| cNrCalc[2] == GWH->GWH_NRCALC}) == 0 .and. (GWF->GWF_TPCALC $ If(!lCalcServ,"1568","7")) // 1-Normal, 5-Devolução, 6-Redespacho, 8-Provisao
					aAdd(aCalcDocs, {GWH->GWH_FILIAL, GWH->GWH_NRCALC})

					oGFEXFBFLog:setTexto(STR0279 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC") + STR0280 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC") + STR0024 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC") + STR0281 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC") + ; //"  Doc.Carga (Tp.Doc "###"; Emissor "###"; Série "###"; Nr.Doc "
					STR0282 + GWH->GWH_NRCALC + STR0283 + GFEFldInfo("GWF_TPCALC",GWF->GWF_TPCALC,2) + ")" + CRLF) //") está relacionado ao cálculo de frete ("###", tipo "
					If lCalcServ .And. GFXCP12117("GWF_CDTPSE") .And. !Empty(GWF->GWF_CDTPSE) .And. ((IsInCallStack("GFE050CALC") .And. !Empty(GWF->GWF_NROCO)) .Or. (!IsInCallStack("GFE050CALC") .And. Empty(GWF->GWF_NROCO)))
						GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) 
						GFEXFB_2TOP(lTabTemp, cTRBCCF, aTRBCCF1, 9)
						While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9)
							If Posicione("GV2",1,xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_CDTPSE") == GWF->GWF_CDTPSE .And. ;
							   Posicione("GVU",1,xFilial("GVU")+GWF->GWF_CDTPSE,"GVU_RECOR") == "2"
							
								oGFEXFBFLog:setTexto("Conforme a validação do tipo de serviço, não é possível inserir uma recorrência." + CRLF +;
								 		 "Documento de carga possui outro cálculo do tipo " + AllTrim(Posicione("GVU",1,xFilial("GVU")+GWF->GWF_CDTPSE,"GVU_DSTPSE")) + CRLF) //<tipo de serviço>
								If aScan(aErrSrv,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") .And. x[2] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .And. x[3] == Posicione("GVU",1,xFilial("GVU")+GWF->GWF_CDTPSE,"GVU_DSTPSE")}) == 0
									aAdd(aErrSrv,{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC"),GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"),Posicione("GVU",1,xFilial("GVU")+GWF->GWF_CDTPSE,"GVU_DSTPSE")} ) 
									GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC"), 29,{GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU"),"GWN"},{AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")),AllTrim(Posicione("GVU",1,xFilial("GVU")+GWF->GWF_CDTPSE,"GVU_DSTPSE"))})
								EndIf
								lGravaCalc := .f.
							EndIf
							GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) 
						EndDo
					EndIf
				EndIf
			EndIf

			GWH->(dbSkip())
		EndDo

		// Nenhum calculo foi adicionado a lista
		If len(aCalcDocs) == nQtCalc
			oGFEXFBFLog:setTexto(STR0279 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDTPDC") + STR0280 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"EMISDC") + STR0024 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"SERDC") + STR0281 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRDC") + ; //"  Doc.Carga (Tp.Doc "###"; Emissor "###"; Série "###"; Nr.Doc "
			STR0284 + CRLF) //") não possui vinculo com cálculo de frete"
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1) 
	EndDo

	If lGravaCalc
		// Verifica se todos os documentos de carga dos cálculos encontrados estão sendo considerados na rotina
		For nX := 1 To Len(aCalcDocs)
			lGravaCalc := .T.
	
			// Quando realizando cálculo de serviço não elimina outros cálculos
			If lCalcServ .And. IsInCallStack("GFEA032CA")
				Exit
			EndIf
	
			If nTabProv != 0
				// Validações para quando o cálculo é de Provisão/Estimativa
				If Posicione("GWF", 1, aCalcDocs[nX][1] + aCalcDocs[nX][2], "GWF_TPCALC") == "8"
					GFEDelCalc(aCalcDocs[nX][2], aCalcDocs[nX][1])
					oGFEXFBFLog:setTexto(STR0297 + aCalcDocs[nX][2] + STR0298 + CRLF) //"  Cálculo de frete "###" eliminado."
				EndIf
			Else
				// Verifica se os documentos de carga dos cálculos de frete	encontrados acima estão sendo considerados neste processo de cálculo
				// Se algum documento de carga estiver fora do processo e o calculo não for de provisão, não permite apagar o cálculo
				If !GFEVldDocCalc(aCalcDocs[nX][2], aDoctoCarga, aCalcDocs[nX][1]) .AND. Posicione("GWF",1,aCalcDocs[nX][1]+aCalcDocs[nX][2],"GWF_TPCALC") != "8" .And. aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0 // Provisao
					lGravaCalc := .F.
					oGFEXFBFLog:setTexto(STR0285 + aCalcDocs[nX][2] + STR0286 + CRLF) //"  Um dos documentos de carga do cálculo "###" não foi considerado nesta execução de cálculo de frete."
				EndIf
	
				// Valida o calculo de frete existente em relacao aos documentos de frete
				If !GFEVldDocFrete(aCalcDocs[nX][2], .F., aCalcDocs[nX][1]) .And. aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0
					lGravaCalc := .F.
					oGFEXFBFLog:setTexto(STR0285 + aCalcDocs[nX][2] + STR0287 + CRLF) //"  Um dos documentos de carga do cálculo "###" está vinculado a documento de frete."
				EndIf
	
				// Valida o calculo de frete existente em relacao a pre-fatura
				If !GFEVldPreFat(aCalcDocs[nX][2], aCalcDocs[nX][1]) .And. aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0
					lGravaCalc := .F.
					oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + STR0289 + CRLF) //"  Cálculo "###" está associado a pré-fatura de frete."
				EndIf
	
				// Valida o calculo de frete existente em relacao a Lote de provisão
				If !GFEVldLotProvisao(aCalcDocs[nX][2], aCalcDocs[nX][1]) .And. aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0
					lGravaCalc := .F.
					oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + "está associado a lote de provisão" + CRLF) //"  Cálculo "###" está associado a pré-fatura de frete."
				EndIf

				If !GFEVldContr(aCalcDocs[nX][2], aCalcDocs[nX][1]) .And. aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0
					lGravaCalc := .F.
					oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + STR0290 + CRLF) //"  Cálculo "###" está associado a contrato com autônomo."
				EndIf
				
				If aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) > 0
					oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + STR0291 + CRLF) //"  Cálculo "###" não pode ser eliminado."
				EndIf
	 
				If !lGravaCalc
					oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + STR0291 + CRLF) //"  Cálculo "###" não pode ser eliminado."
					GFEXFBAEC("GEN", 12, {aCalcDocs[nX][2], "GWF", aCalcDocs[nX][1]})
				Else
					// Valida o calculo quanto a movimentos contabeis integrados no ERP
					If !GFEVldMovCtb(aCalcDocs[nX][2], aCalcDocs[nX][1])
						oGFEXFBFLog:setTexto(STR0288 + aCalcDocs[nX][2] + STR0292 + CRLF) //"  Cálculo "###" possui movimentos contábeis enviados ou atualizados no ERP."
	
						// Estorna o movimento contábil gerado para o cálculo, caso este seja de provisao
						cTpCalc := Posicione("GWF",1,xFilial("GWF")+aCalcDocs[nX][2],"GWF_TPCALC")
						If cTpCalc == "1"	// Normal
							oGFEXFBFLog:setTexto(STR0294 + aCalcDocs[nX][2] + STR0295 + CRLF) //"  Alterando tipo do cálculo "###" para Provisão..."
							GWF->(dbSetOrder(01))
							If GWF->(dbSeek(xFilial("GWF")+aCalcDocs[nX][2]))
								RecLock("GWF",.F.)
									GWF->GWF_TPCALC := "8"	// Provisão
								GWF->(MsUnLock())
							EndIf
						EndIf
					Else
						// Não exclui cálculos de estimativa
						// Não exclui cálculos simulados
						If Posicione("GWF",1, aCalcDocs[nX][1] + aCalcDocs[nX][2], "GWF_TPCALC") != "8" .And. ;
						   Posicione("GWF",1, aCalcDocs[nX][1] + aCalcDocs[nX][2], "GWF_ORIGEM") != "4" .And. ;
						   aScan(paNoCalc,{|x|AllTrim(x) == AllTrim(aCalcDocs[nX][2])}) == 0

							// Apaga o calculo de frete e seus relacionamentos, incluindo movimentos contábeis
							GFEDelCalc(aCalcDocs[nX][2], aCalcDocs[nX][1],,,cOriCalc)

							oGFEXFBFLog:setTexto(STR0297 + aCalcDocs[nX][2] + STR0298 + CRLF) //"  Cálculo de frete "###" eliminado."
						EndIf
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf

	cNewCod := " "

	// Verifica se deverá ser tomado alguma ação em relação ao cálculo e romaneio
	If lGravaCalc .And. !lSimulacao
		If (cRetVlrMax:= GFEVlrMaxVld()) != "0" // verifica, valida valores, adiciona no array de erro e adiciona no log
			If "5" $ cRetVlrMax .Or. "6" $ cRetVlrMax .Or. "7" $ cRetVlrMax .Or. "8" $ cRetVlrMax // Desfazer cálculo
				lDesfazCalc :=.T.
			EndIf
		EndIf
	EndIf

	If lDesfazCalc ==.T. //se desfaz o cálculo por parametrização do sistema
		lError := .T.
		lGravaCalc :=.F.
	ElseIf lGravaCalc ==.F. .And. lDesfazCalc ==.F. //se nao grava o calculo por outros motivos
		lError := .T.
	EndIf

	oGFEXFBFLog:setTexto(CRLF + STR0299 + CRLF + CRLF) //"# Gravando unidades de cálculo..."

	If lGravaCalc
		For nF := 1 To Len(aMultFil)
			If aMultFil[nF][1] <> cFilAnt
				cFilAnt := aMultFil[nF][1]
			EndIf

			//Adicionando as tcf para gravar na GWG quando a rota/faixa possui componentes que se aplicam a todas.
			If lTabTemp	
				aStru := (cTRBTCF)->(dbStruct())
			EndIf
			
			If Len(aTcfTodas) > 0
				nPospriori := Len(aTcfTodas[1])-1
				nPosprifai := Len(aTcfTodas[1])
				aSort(aTcfTodas,,,{|x,y| x[1] + x[7] + x[8] + x[9] + STRZERO(x[nPospriori],6)  + STRZERO(x[nPosprifai],6) + x[12] < y[1] + y[7] + y[8] + y[9] + STRZERO(y[nPospriori],6) + STRZERO(y[nPosprifai],6) + y[12]})
			EndIf
			For nX := 1 To Len(aTcfTodas)
				If lTabTemp
					RecLock(cTRBTCF,.T.)
					For nY := 1 To Len(aStru)
						(cTRBTCF)->(FieldPut(nY,aTcfTodas[nX,nY]))
					Next nY
					(cTRBTCF)->SEQ := STRZERO((cTRBTCF)->(RecCount()) +1,4)
					(cTRBTCF)->(MsUnlock())
				Else
					aAdd(aTRBTCF1,aClone(aTcfTodas[nX]))
					idpTCF := Len(aTRBTCF1)
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"  , STRZERO(Len(aTRBTCF1)+1,4))
				EndIf
			Next nX
			If !lTabTemp .And. Len(aTcfTodas) > 0
				aSort(aTRBTCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
			EndIf
			GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6) 
			GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6) 
			If !IsBlind() .AND. lHideProcess == .F.
				oProcess:setRegua2(Len(aTRBUNC1))
			EndIf

			//para cada unidade de calculo
			While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
				If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"IDFRVI") == "3"
					GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
					Loop
				EndIf

				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
				If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
					nPos := aScan(aMultFil[nF][3], {|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") .And.;
														x[2] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") .And.;
														x[3] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC") .And.;
														x[4] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") .And.;
														x[5] == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ") })
					If nPos == 0
						GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
						Loop
					EndIf
				EndIf
			
				lTemUsoCons := .F.
				If !IsBlind() .AND. lHideProcess == .F.
					oProcess:incRegua2(OemToAnsi(STR0052 + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")))) //"Unidade de cálculo "
				EndIf
				If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VALTAB") == .F.
					oGFEXFBFLog:setTexto(STR0300 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") + STR0301 + CRLF) //"  Unidade de cálculo "###" não foi gravada. Verifique o log acima para mais informações."
					GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
					Loop
				EndIf

				// Grava  o EMIRED de acordo com o transportador do trecho seguinte
				// cria a sequencia do registro corrente e acrescenta 1 para verificar
				// se tem um trecho seguinte
				nSeq := 0 //variavel para armazenar a sequencia
				cEmiRed := ""
				cTpCalculo := ""
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
				GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 

				While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .AND. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
					nSeq := VAL(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ")) // grava a sequencia do trecho corrente
					nSeq++             //acrescenta mais um na sequencia

					aAreaTRE  := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) 
					GFEXFB_BORDER(lTabTemp,cTRBTRE,04,7) 

					If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE4, 7,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE4, 7,"NRGRUP") , ;
																	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE4, 7,"NRDC")   , ;
																	STRZERO(nSeq,2)})// verifica se existe um trecho seguinte e então grava o cEmiRed
						cEmiRed := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE4, 7,"CDTRP") // variavel sera gravada para atualizar o campo GWF_EMIRED
					EndIf

					GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7) //RestArea(aAreaTRE)
					GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) //
					GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
				EndDo
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
				If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
					GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1) 
					If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")}) .And. GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"USO") == "2"
						lTemUsoCons := .T.
					EndIf
				EndIf

				//posiciona trecho com mesmo Numero Calculo
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
				GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 

				//posiciona Grupo de Entrega com mesmo Numero Grupo
				GFEXFB_BORDER(.F.,,03,4)
				cGrupo := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP")
				GFEXFB_CSEEK(.F.,, @aTRBGRB1, 4,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRGRUP")}) 

				// Verifica a finalidade do calculo
				cTpTransp := POSICIONE("GU3",1,XFILIAL("GU3")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"),"GU3_AUTON")
				If cTpTransp == "1"
					cFinCalc := "3"	// Contrato com Autonomo
				Else
					If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM") <> GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
						cFinCalc := "1"	// Conhecimento de Carga (CTRC)
					Else
						cFinCalc := "2"	// Nota Fiscal de Servico (NFS)
					Endif
				Endif

				If nTabProv != 0
					cTpCalculo := "8"   // Cálculo de provisão
				Else
					// verifica o tipo de calculo se for a partir do 2 trecho deve gravar redespacho//
					If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") > "01"
						cTpCalculo := "6"	// Redespacho
					Else
						cTpCalculo := "1"	// Normal
					Endif
				Endif

				If lCalcServ
					cTpCalculo := "7"
				Endif

				/* Verifica o tipo de frete para definir o pagador,
				se for cif ou cif com redes e o remetente
				se for fob ou fob com redes e o destinatario */
				If GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"TPFRET") == "1" .or. GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"TPFRET") == "2"
					If lPEXFB09 //Ponto de entrada Vicunha 
						cPagador := ExecBlock("GFEXFB09",.f.,.f.,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"CDTPDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"EMISDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"SERDC"),GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"NRDC")}) 
					Else
						cPagador := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"CDREM")
					EndIf
				Else
					cPagador := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"CDDEST")
				EndIf


				cNewCod := GETSXENUM("GWF","GWF_NRCALC")

				If lLotaVeic .And. !Empty(GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")) .And. !lSimulacao
					GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
					If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
						GWN->(dbSetOrder(1))
						If GWN->(dbSeek(cRomFil + GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")))
							
							GV9->(dbSetOrder(1))
							GVA->(dbSetOrder(01))
							GVA->(dbSeek(xFilial("GVA")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")))
											
							If (GVA->GVA_TPTAB == "1") //Tabela de Normal
								cCDTRPF := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")	
								cNRTABF := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")	
							Else 	
								cCDTRPF := GVA->GVA_EMIVIN
								cNRTABF := GVA->GVA_TABVIN
							Endif 			
							RecLock("GWN",.F.)
							If GV9->(dbSeek(xFilial("GV9") + cCDTRPF + cNRTABF + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"))) .And. GV9->GV9_TPLOTA == "3"
								If cTpCalculo == "6" // Redespacho
									GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 20,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},,.T.)
									oGFEXFBFLog:setTexto(CRLF +"  Alerta: Unidade de calculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")) +" possuí redespacho e foi utilizado uma tabela de negociação para Veículo Dedicado" + CRLF )
									GWN->GWN_FECHAM := "1"
								Else
									GWN->GWN_FECHAM := "2"
								EndIf
							Else
								GWN->GWN_FECHAM := "1"
							EndIf
							GWN->(MsUnlock())
						EndIf
					EndIf
				EndIf

				//GRAVA AS INFORMACOES DE TODAS AS TABELAS REFERENTES AO CALCULO
				GWF->(dbSetOrder(01))

				aAdd(aCalcNum,{GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRCALC"),cNewCod})

				RecLock("GWF",.T.)
				GWF->GWF_FILIAL := aMultFil[nF][1]
				GWF->GWF_NRCALC := cNewCod
				GWF->GWF_EMIREM := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"CDREM")
				GWF->GWF_EMIDES := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"CDDEST")
				GWF->GWF_EMIRED := cEmiRed
				GWF->GWF_EMIPAG := cPagador
				GWF->GWF_BASICM := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"BASICM")
				GWF->GWF_BAPICO := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"BAPICO")
				GWF->GWF_TRANSP := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP")
				GWF->GWF_ORIGEM := "1"
				GWF->GWF_TPCALC := cTpCalculo
				GWF->GWF_TPFRET := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"TPFRET")
				GWF->GWF_FINCAL := cFinCalc
				GWF->GWF_TPTRIB := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"TPTRIB")
				GWF->GWF_CIDORI := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM")
				GWF->GWF_CIDDES := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")

				If lCalcServ .And. IsInCallStack("GFEA032CA")
					GWF->GWF_NROCO := cNrOcor
				EndIf

				// Quando calculo de estimativa/provisão, grava a data de emissão do documetno de carga como data de "criação" do cálculo
				If cTpCalculo == "8"
					GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
					GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE1, 7) 
					GWF->GWF_DTCRIA := Posicione("GW1",1,GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"FILIAL") + ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") + ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") + ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  + ;
														GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC"),"GW1_DTEMIS")
				Else
					If lCalcDataBase
						GWF->GWF_DTCRIA := DDATABASE
					Else
						GWF->GWF_DTCRIA := Date()
					EndIf
				EndIf

				GWF->GWF_HRCRIA := SubStr(TIME(), 1, 5)
				GWF->GWF_IDFRVI := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"IDFRVI")
				GWF->GWF_CARREG := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"CARREG")
				GWF->GWF_CIDENT := GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"ENTNRC")

				If GFXCP1212210('GW1_FILROM')
					GWF->GWF_FILROM := cRomFil
				EndIf

				If (!empty(GW1->GW1_NRROM)) .and. (AllTrim(GWF->GWF_NROCO) == AllTrim(GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")))
					GWF->GWF_NRROM  := GW1->GW1_NRROM
					cNrRom := GWF->GWF_NRROM 
				Else
					GWF->GWF_NRROM  := if(AllTrim(GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU")) == "99999999", "", GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,"NRAGRU"))
					cNrRom := GWF->GWF_NRROM 
					If cTpCalculo == '8'
						RecLock('GW1', .F.)
        				GW1->GW1_NRROM := GWF->GWF_NRROM
						GW1->(MsUnlock())
						cNrDC := AllTrim(GW1->GW1_NRDC)
					Endif
				Endif
				
				GWF->GWF_PCICMS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"PCICMS")
				GWF->GWF_PCREIC := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"PCREIC")
				GWF->GWF_VLCOFI := GFETratDec(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLCOFI"),0,.T.)
				GWF->GWF_VLICMS := GFETratDec(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLICMS"),0,.T.)
				GWF->GWF_ICMRET := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"ICMRET")
				GWF->GWF_VLPIS  := GFETratDec(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLPIS"),0,.T.)
				GWF->GWF_BASISS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"BASISS")
				GWF->GWF_PCISS  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"PCISS")
				GWF->GWF_VLISS  := GFETratDec(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLISS"),0,.T.)
				GWF->GWF_DTPREN := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"DTPREN")
				GWF->GWF_HRPREN := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"HRPREN")
				GWF->GWF_AGRUP  := "2"
				GWF->GWF_USUCRI := cUserFrete
				GWF->GWF_SEQTRE := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE")
				GWF->GWF_ADICIS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"ADICIS")

				If GFXCP2510('GWF_BASIBS')
					GWF->GWF_BASIBS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"BASIBS")
				EndIf
				If GFXCP2510('GWF_PCIBS')
					GWF->GWF_PCIBS  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"PCIBS")
				EndIf
				If GFXCP2510('GWF_VLRIBS')
					GWF->GWF_VLRIBS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLRIBS")
				EndIf
				If GFXCP2510('GWF_BASCBS')
					GWF->GWF_BASCBS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"BASCBS")
				EndIf
				If GFXCP2510('GWF_PCCBS')
					GWF->GWF_PCCBS  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"PCCBS")
				EndIf
				If GFXCP2510('GWF_VLRCBS')
					GWF->GWF_VLRCBS := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"VLRCBS")
				EndIf
				If GFXCP2510('GWF_IDTRIB')
					GWF->GWF_IDTRIB := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"IDTRIB")
				EndIf

				// Cálculo de serviço para ocorrência e tipo de imposto ISS (Cidade Origem ou Destino)
				If lCalcServ .AND. (cServTpImp == "2" .OR. cServTpImp == "3")
					GWF->GWF_IMPOST := "2"
					If !IsInCallStack("GFEA032CA")	
						GWF->GWF_OBS 	:= "Imposto de ISS com base na cidade de " + If(cServTpImp == "2", "origem", "destino") + " conforme tipo de imposto cadastrado na tabela de romaneio."
					Else
						GWF->GWF_OBS 	:= "Imposto de ISS com base na cidade de " + If(cServTpImp == "2", "origem", "destino") + " conforme tipo de imposto cadastrado no tipo de ocorrência."
					EndIf	
				Else
					If GWF->GWF_CIDORI == GWF->GWF_CIDDES
						GWF->GWF_IMPOST := "2"
					Else
						GWF->GWF_IMPOST := "1"
					Endif
				EndIf

				If lCalcPc .And. cTpCalculo == "1" .And. !(cAgruPC $ "'" + GWF->GWF_NRROM + "'") // Somente o transportador do cálculo normal pode gravar o
					If !Empty(cAgruPC)
						cAgruPC += ","
					EndIf
					cAgruPC += "'" + GWF->GWF_NRROM + "'" // Agrupador para auxiliar nos filtros SQL
				EndIf

				/* Definição Credito ICMS */
				// Definindo o campo CRDICM para os tipos de tributação
				If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"TPTRIB") $ "3;4;7"
					// Quando o tipo de tributação for "Substituição Tributária", "Diferida" ou "Presumida"
					// é verificado o parâmetro "ICMS ST", sendo 1 igual a tributado e 2 igual a não
					If cIcmsSt == "1"
						GWF->GWF_CRDICM := "1"
					Else
						GWF->GWF_CRDICM := "2"
					EndIf
				ElseIf GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"TPTRIB") $ "2;6"
					// Quando o tipo for "Isento" ou "Outros", o documento não será tributado
					GWF->GWF_CRDICM := "2"
				Else
					// O else é referente aos valores "Tributado" ou "Reduzido", nesse caso o documento será tributado
					GWF->GWF_CRDICM := "1"
				EndIf 
				// Finalizada a definição do crédito de ICMS conforme tipo de tributação

				// Após definir o Crédito de ICMS pelo tipo de tributação, caso esse seja Sim é validado o parâmetro da Forma de Crédito de ICMS
				If GWF->GWF_CRDICM == "1"
					If cCredIcms == "1" //Tributado
						// Parâmetro que indica se o Crédito ICMS é pela Regra Sistema(Crédito Total)
						// ou se é Conforme Itens Nota(Crédito Parcial), respectivamente igual a 1 e 2
						If alltrim(cFormCredICMS) == alltrim("2")
							// Opção referente ao Crédito de ICMS Conforme Itens Nota(Crédito Parcial)
							GW1->(dbSetOrder(9))
							If GW1->(dbSeek(xFilial("GW1")+GWF->GWF_NRROM))
								// Percorre todos os relacionamentos documentos de carga com o cálculo
								While !GW1->(EoF()) .And. GW1->GW1_FILIAL+GW1->GW1_NRROM == xFilial("GW1")+GWF->GWF_NRROM
									GW8->(dbSetOrder(2))
									If GW8->(dbSeek(xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
										// Percorre todos os itens do documento de carga relacionado ao cálculo
										// Obs: Está sendo utilizada a tabela teporária visto que a GWH ainda nõ foi criada para este cálculo
										While !GW8->(EoF()) .And. GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC == ;
										xFilial("GW8")+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
											// Verifica se o item possui a informação de credita ICMS como Sim
											// Caso possua atribui verdadeiro a variável que indica se existe algum item que credita ICMS
											// Senão passa ao próximo item deste documento de carga e depois ao próximo documento de carga relacionado ao cálculo
											If GW8->GW8_CRDICM == "1"
												// Atribui verdadeiro a variável que indica se existe algum item que credita ICMS
												lCrdSim := .T.
												EXIT // Encerra o While dos itens do documento de carga, pois já existe um que credita ICMS
											EndIf
											GW8->(dbSkip())
										EndDo
									EndIf
									If lCrdSim
										EXIT // Encerra o While dos documentos de carga, pois já existe um item que credita ICMS
									EndIf
									GW1->(dbSkip())
								EndDo
							EndIf
							// Verifica a variável que indica se existe algum item que possua o Crédito de ICMS como Sim
							// Caso exista o documento de frete credita ICMS, senão o documento não credita ICMS
							If lCrdSim == .F.
								// Credita como Não
								GWF->GWF_CRDICM := "2"
							EndIf
						Else
							// Opção referente ao Crédito de ICMS Regra Sistema(Crédito Total)
							// Verifica se o cálculo possui documentos relacionados que sejam Uso e Consumo
							If lTemUsoCons
								GW1->(dbSetOrder(9))
								GW1->(dbSeek(xFilial("GW1") + GWF->GWF_NRROM))
								// Verificação do sentido da nota fiscal, sendo 1 igual a Entrada
								If(Posicione("GV5", 1, xFilial("GV5") + GW1->GW1_CDTPDC, "GV5_SENTID") == "1")
									// Credita como Não
									GWF->GWF_CRDICM := "2"
								EndIf
							EndIf
						EndIf
					Else
						// Credita como Não
						GWF->GWF_CRDICM := "2" 
					EndIf
				EndIf
				/* Fim Definição Credito ICMS */

				/* Crédito PIS/COFINS */
				cCredPC := GetNewPar("MV_GFEPC", "1", GWF->GWF_FILIAL)
				cCredPCTF := GetNewPar("MV_PICOTR", "2", GWF->GWF_FILIAL)

				If Empty(cCredPC)
					cCredPC := "1"
				EndIf

				If Empty(cCredPCTF)
					cCredPCTF := "2"
				EndIf

				If cCredPC == "2" .Or. GWF->GWF_FINCAL == "3" .Or. lTemUsoCons
					GWF->GWF_CRDPC := "2"
				ElseIf (Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_EMIREM, "GU3->GU3_EMFIL") == "1" .And. ;
						Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_EMIDES, "GU3->GU3_EMFIL") == "1") .And. ;
						SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_EMIREM, "GU3->GU3_IDFED"), 1, 8) == SubStr(Posicione("GU3", 1, xFilial("GU3") + GWF->GWF_EMIDES, "GU3->GU3_IDFED"), 1, 8) .And. ;
						cCredPCTF == "2"
					GWF->GWF_CRDPC := "2"
				Else
					GWF->GWF_CRDPC := "1"
				EndIf

				IF GWF->GWF_CRDPC == "1" .AND. Round(GWF->GWF_BAPICO,2) == 0
					GWF->GWF_CRDPC := "2"
				EndIf

				lCrdPcItem := .F.

				If GWF->GWF_CRDPC == "1"
					cFilCod := Iif(GFXCP1212210('GW1_FILROM'), GWF->GWF_FILIAL, xFilial("GW1")) 

					GW1->(dbSetOrder(9)) 

					If GW1->( dbSeek(cFilCod + cNrRom))
						While !GW1->(EoF()) .And. GW1->GW1_FILIAL == cFilCod .And. GW1->GW1_NRROM == cNrRom	
							GW8->(dbSetOrder(2))
							If GW8->(dbSeek(GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC))
								While !GW8->(EoF()) .And. GW8->GW8_FILIAL+GW8->GW8_CDTPDC+GW8->GW8_EMISDC+GW8->GW8_SERDC+GW8->GW8_NRDC == ;
														  GW1->GW1_FILIAL+GW1->GW1_CDTPDC+GW1->GW1_EMISDC+GW1->GW1_SERDC+GW1->GW1_NRDC
									If GW8->GW8_TRIBP == "1"
										lCrdPcItem := .T.
									EndIf
									
									GW8->(dbSkip())
								EndDo
							EndIf				
							GW1->(dbSkip())
						EndDo
					EndIf
				EndIf
				
				If !lCrdPcItem
					GWF->GWF_CRDPC := "2"
				EndIf

				If cTpCalculo == '8'
					cGW1Alias := GetNextAlias()

					cQuery := "SELECT GW1_FILIAL, GW1_NRDC, GW1_NRROM, GW1_EMISDC, R_E_C_N_O_ as RECNUM"
					cQuery += " FROM " + RetSqlName("GW1") + " GW1"
					cQuery += " WHERE GW1.GW1_FILIAL = ?"
					cQuery += " AND GW1.GW1_NRDC = ?"
					cQuery += " AND GW1.GW1_NRROM = ?"
					cQuery += " AND GW1.D_E_L_E_T_ = ' '"

					cQuery := ChangeQuery(cQuery)
					oQry := FWExecStatement():New(cQuery)
					
					oQry:SetString(1,xFilial("GWF"))
					oQry:SetString(2,cNrDC) 
					oQry:SetString(3,cNrRom)

					cGW1Alias := oQry:OpenAlias()

					If (cGW1Alias)->(!EOF())
    					GW1->(dbGoto((cGW1Alias)->RECNUM))
							RecLock('GW1', .F.)
							GW1->GW1_NRROM := " "
							GW1->(MsUnlock())
    					(cGW1Alias)->(dbSkip())
					EndIf
					(cGW1Alias)->(dbCloseArea())
				EndIf


				GWF->(MsUnLock())
				oGFEXFBFLog:setTexto(STR0302 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") + STR0303 + GWF->GWF_NRCALC + CRLF) //"  Unidade de calculo "###" gravada com número "
				ConfirmSX8()
				aMultFil[nF][2] := GWF->GWF_NRCALC

				lPrimeira := .T.

				//percorre tabelas do calculos de frete relacionadas
				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
				GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
				While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
					oGFEXFBFLog:setTexto("   > FILIAL: " + GWF->GWF_FILIAL)
					oGFEXFBFLog:setTexto(", CDCLFR: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"))
					oGFEXFBFLog:setTexto(", CDTPOP: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"))
					oGFEXFBFLog:setTexto(", NRTAB: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))
					oGFEXFBFLog:setTexto(", NRNEG: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"))
					oGFEXFBFLog:setTexto(", CDFXTV: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"))
					oGFEXFBFLog:setTexto(", NRROTA: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"))
					oGFEXFBFLog:setTexto(", CDTPVC: " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC") + CRLF)
					oGFEXFBFLog:SaveLog()

					RecLock("GWG",.T.)
					GWG->GWG_FILIAL := GWF->GWF_FILIAL
					GWG->GWG_NRCALC := GWF->GWF_NRCALC
					GWG->GWG_CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
					GWG->GWG_CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
					GWG->GWG_DTVALI := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE")
					GWG->GWG_CDEMIT := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")
					GWG->GWG_NRTAB  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")
					GWG->GWG_NRNEG  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")
					GWG->GWG_CDFXTV := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")
					GWG->GWG_CDTPVC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC")
					GWG->GWG_NRROTA := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")

					If GWN->(FieldPos('GWN_CPESO')) > 0
						
						If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUMEORG") > 0
							GWG->GWG_QTM3   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUMEORG")
						Else
							GWG->GWG_QTM3   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
						EndIf
						
						If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESORORG") > 0
							GWG->GWG_QTPESO := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESORORG")
						Else
							GWG->GWG_QTPESO := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") 
						EndIf
						
						If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG") > 0
							GWG->GWG_PESCUB := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUBORG")
						Else
							GWG->GWG_PESCUB := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
						EndIf
						
						If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDEORG") > 0
							GWG->GWG_QTITEM := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDEORG")
						Else
							GWG->GWG_QTITEM := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE") 
						EndIf
						
						If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALORORG") > 0
							GWG->GWG_VLMERC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALORORG")
						Else
							GWG->GWG_VLMERC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") 
						EndIf

					Else
						GWG->GWG_QTM3   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
						GWG->GWG_QTPESO := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") 
						GWG->GWG_PESCUB := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
						GWG->GWG_QTITEM := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE") 
						GWG->GWG_VLMERC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") 
					EndIf
					
					GWG->(MsUnLock())
					If lPrimeira
						lPrimeira := .F.
						nRecGWG := GWG->(RecNo())
					EndIf 
					GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
				EndDo

				//percorre os trechos do calculo de frete relacionado
				GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7) 
				GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
				While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .and. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")
					
					GWH->(dbSetOrder(1))
					If !(GWH->(DbSeek(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"FILIAL")+GWF->GWF_NRCALC+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC"))))
						RecLock("GWH",.T.)
						GWH->GWH_FILIAL := GWF->GWF_FILIAL
						GWH->GWH_NRCALC := GWF->GWF_NRCALC
						GWH->GWH_CDTPDC := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC")
						GWH->GWH_EMISDC := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC")
						GWH->GWH_SERDC  := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")
						GWH->GWH_NRDC   := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")
						GWH->GWH_TRECHO := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ")
						If GWH->(FieldPos("GWH_SDOCDC")) > 0
							GWH->GWH_SDOCDC := Posicione("GW1",1,GWH->GWH_FILIAL + GWH->GWH_CDTPDC + GWH->GWH_EMISDC + GWH->GWH_SERDC + GWH->GWH_NRDC,"GW1_SDOC")
						EndIf
						GWH->(MsUnLock())
					EndIf
					
					If lExiSITFRE .And. s_INTFRE == '2'
						GW1->(dbSetOrder(1))
						If GW1->(dbSeek(GWH->GWH_FILIAL+GWH->GWH_CDTPDC+GWH->GWH_EMISDC+GWH->GWH_SERDC+GWH->GWH_NRDC))
							If GW1->GW1_ORIGEM == "2" .And. GW1->GW1_SITFRE != '6' 
								RecLock("GW1", .F.)
									GW1->GW1_SITFRE := "2"
									GW1->GW1_MOTFRE := "GFEXFUNB - Cálculo de Frete"
									GW1->GW1_DTFRE  := Date()
								GW1->(MsUnLock())
							EndIf
						EndIf
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7) 
				EndDo

				lPrimeira := .T.
				//percorre os componentes do calculo de frete relacionada
				GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9) 
				GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")}) 
				While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")

					RecLock("GWI",.T.)
					GWI->GWI_FILIAL := GWF->GWF_FILIAL //xFilial("GWI")
					GWI->GWI_NRCALC := GWF->GWF_NRCALC
					GWI->GWI_CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR")
					GWI->GWI_CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP")
					GWI->GWI_CDCOMP := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
					GWI->GWI_VLFRET := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
					GWI->GWI_QTCALC := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE")
					GWI->GWI_IDMIN  := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN")
					GWI->GWI_TOTFRE := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE")
					If (cTpCalculo == "1" .OR. cTpCalculo == "6" .OR. cTpCalculo = "7") .And. GFXCP12130("GWI_VLLIQ")
						nPos := AScan(aCompLiq, {|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") .And.;
													x[2] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"SEQ") .And.;
													x[3] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")})

						If nPos != 0
							GWI->GWI_VLLIQ  := aCompLiq[nPos][4]
						EndIf
					EndIf
					GWI->(MsUnLock())

					If lPrimeira
						lPrimeira := .F.
						nRecGWI := GWI->(RecNo())
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9) 
				EndDo

				If lCalcServ .And. cTpCalculo = "7" .And. GFXCP12117("GWF_CDTPSE")
					GWG->(dbGoTo(nRecGWG))
					dbSelectArea("GV9")
					If Posicione("GV9",1,xFilial('GV9')+GWG->(GWG_CDEMIT+GWG_NRTAB+GWG_NRNEG),"GV9_AGRSE") $ '13 '
						GWI->(dbGoTo(nRecGWI))
						If IsInCallStack("GFE050CALC")
							RecLock("GWF",.F.)
							GWF->GWF_CDTPSE := Posicione("GV2",1,xFilial('GV2')+GWI->GWI_CDCOMP,"GV2_CDTPSE")
							GWF->(msUnlock())
						Else //Para cálculos de serviço por ocorrencia, tenta encontrar tipos similares entre os componentes. Utilizado para ajudar a diferenciar documentos de frete do tipo serviço. 
							aServAgr := {}
							cFilCod := Iif(GFXCP1212210('GW1_FILROM'), GWF->GWF_FILROM, xFilial("GWI"))
							While !GWI->(Eof()) .And. GWI->GWI_FILIAL == cFilCod .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
								cCompImp := Posicione("GV9",1,xFilial('GV9')+GWG->(GWG_CDEMIT+GWG_NRTAB+GWG_NRNEG),"GV9_COMIMP")
								
								If Alltrim(cCompImp) != Alltrim(GWI->GWI_CDCOMP)
									cCdTpSe := Posicione("GV2",1,xFilial('GV2')+GWI->GWI_CDCOMP,"GV2_CDTPSE")
									
									If aScan(aServAgr,cCdTpSe) == 0
										aAdd(aServAgr,cCdTpSe)
									EndIf
								EndIf
								GWI->(dbSkip())
							EndDo
							If Len(aServAgr) == 1//O Cálculo de frete só aceita um de tipo de serviço. 
								RecLock("GWF",.F.)
									GWF->GWF_CDTPSE := cCdTpSe
								GWF->(msUnlock())
							EndIF
						EndIf
					ElseIf GV9->(FieldPos("GV9_CDTPSE")) > 0
						RecLock("GWF",.F.)
							GWF->GWF_CDTPSE := GV9->GV9_CDTPSE
						GWF->(msUnlock())
					Else
						aServAgr := {}
						GWI->(dbGoTo(nRecGWI))
						While !GWI->(Eof()) .And. GWI->GWI_FILIAL == xFilial("GWI") .And. GWI->GWI_NRCALC == GWF->GWF_NRCALC
							cCdTpSe := Posicione("GV2",1,xFilial('GV2')+GWI->GWI_CDCOMP,"GV2_CDTPSE")
							If aScan(aServAgr,cCdTpSe) == 0
								aAdd(aServAgr,cCdTpSe)
							EndIf
							GWI->(dbSkip())
						EndDo
						If Len(aServAgr) == 1//O Cálculo de frete só aceita um de tipo de serviço. 
							RecLock("GWF",.F.)
								GWF->GWF_CDTPSE := cCdTpSe
							GWF->(msUnlock())
						EndIF
					EndIf
				EndIf

				If !IsBlind() .AND. lHideProcess == .F.
					oProcess:IncRegua1("Contabilizando")
					oProcess:SetRegua2(0)
					oProcess:IncRegua2("Gerando grade contábil")
				EndIf

				aRetRateio := GFERatCal(nTabProv != 0, GWF->GWF_NRCALC, oProcess, GWF->GWF_FILIAL)
				If aRetRateio[1] == .F. .Or. !Empty(aRetRateio[2])
					If !IsInCallStack("GFEA088") .And. cAcGrRat == "1" .And. !aRetRateio[1]
						Alert(STR0304 + GWF->GWF_NRCALC) //"Não foi possível gerar movimentos contábeis para o cálculo: "
					EndIf
					
					If cAcGrRat == "1"
						oGFEXFBFLog:setTexto(STR0305 + GWF->GWF_NRCALC + CRLF) //"  Não foi possível gerar movimentos contábeis para o cálculo: "
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRCALC"), 28,{GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRAGRU"),"GWN"},,.T.)
					ElseIf cAcGrRat == "2"
						oGFEXFBFLog:setTexto(STR0305 + GWF->GWF_NRCALC + ".Cálculo Desfeito." + CRLF) //"  Não foi possível gerar movimentos contábeis para o cálculo: "
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRCALC"), 28,{GFEXFB_5CMP(lTabTemp, cTrbUNC, @aTrbUNC1, 6,"NRAGRU"),"GWN"},,.F.)
						lError := .T.
						lGravaCalc := .F.
					EndIf
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 
			EndDo

			If cFilAnt <> cRomFil
				cFilAnt := cRomFil
			EndIf
		Next

		If !Empty(cAgruPC) .And. !lError
			cMsg := GfeAtuPesC(cAgruPC) // Atualiza o peso cubado dos itens somente dos romaneios envolvidos
			If Empty(cMsg)
				oGFEXFBFLog:setTexto("Conforme o parâmetro MV_GFEOPC, foi gravado nos itens dos documentos de carga o seu respectivo Peso Cubado." + CRLF)
			Else
				oGFEXFBFLog:setTexto("Ocorreu o seguinte erro durante a atualização do peso cubado nos itens:" + cMsg + CRLF)
			EndIf
		EndIf
	Else
		oGFEXFBFLog:setTexto(STR0306 + CRLF) //"  Não foi possível gravar as unidades de calculo geradas!!!"
		oGFEXFBFLog:setTexto(STR0307 + CRLF) //"  Um ou mais cálculos existentes para os documentos de carga não puderam ser eliminados."
		oGFEXFBFLog:setTexto(STR0308 + CRLF) //"  Verifique o log acima para mais informações."
	EndIf
		
	If lGravaCalc
		//Atualiza os alertas, se existirem
		For nY := 1 to Len(aCalcNum)
			For nX := 1 To Len (aErroCalc)
				If AllTrim(aErroCalc[nX][3]) == AllTrim(aCalcNum[nY][1]) .And. aErroCalc[nX][5] == .T. .And. aErroCalc[nX][1] == aCalcNum[nY][2]
					aErroCalc[nX][1] := aCalcNum[nY][3]
				EndIf
			Next nX
		Next nY	
	Else
		cFilCalc := xFilial("GWF")
		For nY := 1 to Len(aCalcNum)
			GFEDelCalc(aCalcNum[nY][3],cFilCalc)
		Next nY
	EndIf

	aSize(aCalcNum,0)

Return // FIM GravaFrete()

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVlrMaxVld
Verifica se os valores dos cálculos ultrapassam os valores limite
dos parâmetros de auditoria antecipada

Uso: GFEVlrMaxVld()

@sample GFEVlrMaxVld()
@return // O retorno é concatenado, se tiver um alerta pelo peso e um desfazer pelo total do calcul: "35" ou desafazer pelo calculo, carga e peso : "567"
"0" //tudo certo ou sem verificação
"1" // Alerta pelo valor total do calculo
"2" // Alerta pelo valor do frete pela carga
"3" // Alerta pelo valor do frete pelo peso
"4" // Alerta pelo valor total do romaneio
"5" // Desfazer pelo valor total do calculo
"6" // Desfazer pelo valor do frete pela carga
"7" // Desfazer pelo valor do frete pelo peso
"8" // Desfazer pelo valor total do romaneio

@author Siegklenes.Beulke
@since 28/08/2013
@version 1.0
----------------------------------------------------------------------------*/
Static Function GFEVlrMaxVld()
	Local nVlrCalc 	 := 0
	Local nVlrTes		 := 0
	Local cRetorno 	 := ""
	Local nTotValCrg := 0
	Local nTotPesCrg := 0
	Local nTotRom 	 := 0
	Local aAreaTCF 	 := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5) 
	Local aAreaUNC	 := GFEXFB_9GETAREA(lTabTemp, cTRBUNC, 6) 
	Local aAreaAGR	 := GFEXFB_9GETAREA(lTabTemp, cTRBAGRU, 0) 
	Local lDesfazer  := .F.
	Local cNrCt := ""
	
	Local s_GFELAC1	:= SuperGetMv("MV_GFELAC1",.F.,"0")
	Local s_GFELIM1	:= SuperGetMv("MV_GFELIM1",.F.,999999.99)
	Local s_GFELAC2	:= SuperGetMv("MV_GFELAC2",.F.,"0")
	Local s_GFELIM2	:= SuperGetMv("MV_GFELIM2",.F.,999999.99)
	Local s_GFELAC3	:= SuperGetMv("MV_GFELAC3",.F.,"0")
	Local s_GFELIM3	:= SuperGetMv("MV_GFELIM3",.F.,9999.99)
	Local s_GFELAC4	:= SuperGetMv("MV_GFELAC4",.F.,"0")
	Local s_GFELIM4	:= SuperGetMv("MV_GFELIM4",.F.,9999.999)
	Local s_GFELAC5	:= SuperGetMv("MV_GFELAC5",.F.,"0")
	
	GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0) 
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 
	oGFEXFBFLog:setTexto(CRLF +"# Verificação dos limites de cálculo " + CRLF)
	If s_GFELAC1 $ "12" .Or. s_GFELAC2 $ "12";
	.Or. s_GFELAC3 $ "12" .Or. s_GFELAC4 $ "12" .or. s_GFELAC5 $ "12"

		While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0) 
			oGFEXFBFLog:setTexto(CRLF +"## Verificando " + IIf(lSimulacao,"agrupador ", "romaneio ") + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"))  + CRLF)
			nTotRom := 0

			GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6) 
			GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")}) 

			While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

				nVlrCalc := GFETotFret(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))
					
				If GFXCP12127("GVW_NRCT")			
					GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
					If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")}) 
						
						GVW->( dbSetOrder(1) )	
						If GVW->(dbSeek(xfilial("GVW") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")))
						
							GXT->( dbSetOrder(1) )	
							If GXT->(dbSeek(xFilial("GXT")+GVW->GVW_NRCT))
	
								cNrCt := GXT->GXT_NRCT	
								
								If GXT->GXT_VLLIM < (GXT->GXT_VLPREV + GXT->GXT_VLREAL + nVlrCalc)
								
									Do Case
										Case s_GFELAC5 == "1"
											cRetorno += "4"
											GFEXFBAEC("", 31,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(GXT->GXT_VLLIM,"@E 999,999.99"))})										
											oGFEXFBFLog:setTexto(CRLF +"  Alerta: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF)
										Case s_GFELAC5 == "2"
											cRetorno += "8"
											lDesfazer := .T.
											GFEXFBAEC("", 31,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(GXT->GXT_VLLIM,"@E 999,999.99"))})										
											oGFEXFBFLog:setTexto(CRLF +"  Erro: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF)
										Case s_GFELAC5 == "0"	
											oGFEXFBFLog:setTexto(CRLF +"  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF + "  Nenhuma ação foi tomada..." + CRLF )								
									EndCase														
														
								Endif															
							Endif
						Else	
											
							GVA->( dbSetOrder(1) )	
							IF GVA->( dbSeek(xFilial("GVA") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") ) )
								
								IF GVA->GVA_TPTAB == '2' // Tabela Vínculo
								
									GVW->( dbSetOrder(1) )
									GVW->( dbSeek(xFilial("GVW") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )
									While !Eof() .And. xFilial("GVW") + GVW->GVW_CDEMIT + GVW->GVW_NRTAB + GVW->GVW_NRNEG == xFilial("GVW") + GVA->GVA_EMIVIN + GVA->GVA_TABVIN + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")				
										
										GXT->( dbSetOrder(1) )	
										If GXT->(dbSeek(xFilial("GXT")+GVW->GVW_NRCT))
				
											cNrCt := GXT->GXT_NRCT	
											
											If GXT->GXT_VLLIM < (GXT->GXT_VLPREV + GXT->GXT_VLREAL + nVlrCalc)
											
												Do Case
													Case s_GFELAC5 == "1"
														cRetorno += "4"
														GFEXFBAEC("", 31,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(GXT->GXT_VLLIM,"@E 999,999.99"))})										
														oGFEXFBFLog:setTexto(CRLF +"  Alerta: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF)
													Case s_GFELAC5 == "2"
														cRetorno += "8"
														lDesfazer := .T.
														GFEXFBAEC("", 31,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(GXT->GXT_VLLIM,"@E 999,999.99"))})										
														oGFEXFBFLog:setTexto(CRLF +"  Erro: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF)
													Case s_GFELAC5 == "0"	
														oGFEXFBFLog:setTexto(CRLF +"  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite do contrato " + cNrCt + CRLF + "  Nenhuma ação foi tomada..." + CRLF )								
												EndCase														
																	
											Endif															
										Endif										
																			
										GVW->(DbSkip())
									ENDDO							
									
								Endif
							Endif								
							
						Endif										
					EndIf	
				Endif						
				
				If s_GFELAC2 $ "12";
				.And. nVlrCalc > 0  .And. nVlrCalc > s_GFELIM2

					If s_GFELAC2 == "1"
						cRetorno += "1"
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 16,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(s_GFELIM2,"@E 999,999.99"))},.T.)
						oGFEXFBFLog:setTexto(CRLF +"  Alerta: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM2,"@E 999,999.99")) + CRLF)
					Else
						cRetorno += "5"
						lDesfazer := .T.
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 16,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrCalc,"@E 999,999.99")),AllTrim(Transform(s_GFELIM2,"@E 999,999.99"))},.F.)
						oGFEXFBFLog:setTexto( CRLF +"  Erro: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM2,"@E 999,999.99")) + CRLF + "  Cálculo Desfeito..." + CRLF )
					EndIf
				ElseIf s_GFELAC2 == "0" .And. nVlrCalc > 0  .And. nVlrCalc > s_GFELIM2
					oGFEXFBFLog:setTexto(CRLF + "  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM2,"@E 999,999.99")) + CRLF + "  Nenhuma ação foi tomada..." + CRLF )
				Else
					oGFEXFBFLog:setTexto(CRLF +"  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor " + AllTrim(Transform(nVlrCalc,"@E 999,999.99")) + " dentro do limite parametrizado " + AllTrim(Transform(s_GFELIM2,"@E 999,999.99")) +  CRLF)
				EndIf

				GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5) 
				GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")}) 

				While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") ==GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
					nTotValCrg += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
					nTotPesCrg += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
					GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5) 
				EndDo

				If s_GFELAC3 $ "12" ;
				.And. nTotValCrg > 0  .And. (nVlrTes:=(nVlrCalc/nTotValCrg)*100) > s_GFELIM3

					If s_GFELAC3 == "1"
						cRetorno += "2"
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 18,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrTes,"@E 9,999.99")),AllTrim(Transform(s_GFELIM3,"@E 9,999.99"))},.T.)
						oGFEXFBFLog:setTexto(CRLF +"  Alerta: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de percentual valor frete/valor carga " + AllTrim(Transform(nVlrTes,"@E 9,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM3,"@E 9,999.99")) + CRLF )
					Else
						cRetorno += "6"
						lDesfazer := .T.
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 18,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrTes,"@E 9,999.99")),AllTrim(Transform(s_GFELIM3,"@E 9,999.99"))})
						oGFEXFBFLog:setTexto( CRLF +"  Erro: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de percentual valor frete/valor carga " + AllTrim(Transform(nVlrTes,"@E 9,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM3,"@E 9,999.99")) + CRLF + "  Cálculo Desfeito..." + CRLF )
					EndIf
				ElseIf 	s_GFELAC3 == "0" .And. nTotValCrg > 0  .And. (nVlrTes:=(nVlrCalc/nTotValCrg)*100) > s_GFELIM3
					oGFEXFBFLog:setTexto(CRLF + "  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de percentual valor frete/valor carga " + AllTrim(Transform(nVlrTes,"@E 9,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM3,"@E 9,999.99")) + CRLF + "  Nenhuma ação foi tomada..." + CRLF )
				Else
					oGFEXFBFLog:setTexto(CRLF + "  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de percentual valor frete/valor carga " + AllTrim(Transform(nVlrTes,"@E 9,999.99")) + " dentro do limite parametrizado " + AllTrim(Transform(s_GFELIM3,"@E 9,999.99")) + CRLF)
				EndIf
				nTotValCrg := 0
				If s_GFELAC4 $ "12" ;
				.And. nTotPesCrg >0 .And. (nVlrTes:=(nVlrCalc/(nTotPesCrg/1000))) > s_GFELIM4

					If s_GFELAC4 == "1"
						cRetorno += "3"
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 19,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrTes,"@E 9,999.999")),AllTrim(Transform(s_GFELIM4,"@E 9,999.999"))},.T.)
						oGFEXFBFLog:setTexto(CRLF +"  Alerta: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor frete/peso(ton) " + AllTrim(Transform(nVlrTes,"@E 9,999.999")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM4,"@E 9,999.999")) + CRLF )
					Else
						cRetorno += "7"
						lDesfazer := .T.
						GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), 19,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nVlrTes,"@E 9,999.999")),AllTrim(Transform(s_GFELIM4,"@E 9,999.999"))})
						oGFEXFBFLog:setTexto(CRLF + "  Erro: Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor frete/peso(ton) " + AllTrim(Transform(nVlrTes,"@E 9,999.999")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM4,"@E 9,999.999")) + CRLF + "  Cálculo Desfeito..." + CRLF )
					EndIf
				ElseIf s_GFELAC4 == "0" .And. nTotPesCrg >0 .And. (nVlrTes:=(nVlrCalc/(nTotPesCrg/1000))) > s_GFELIM4
					oGFEXFBFLog:setTexto(CRLF +"  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor frete/peso(ton) " + AllTrim(Transform(nVlrTes,"@E 9,999.999")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM4,"@E 9,999.999")) + CRLF + "  Nenhuma ação foi tomada..." + CRLF )
				Else
					oGFEXFBFLog:setTexto(CRLF +"  Cálculo " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) +" de valor frete/peso(ton) " + AllTrim(Transform(nVlrTes,"@E 9,999.999")) + " dentro do limite parametrizado " + AllTrim(Transform(s_GFELIM4,"@E 9,999.999")) + CRLF )
				EndIf
				nTotPesCrg := 0
				nTotRom += nVlrCalc
				
				GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6) 

			EndDo

			If s_GFELAC1 $ "12" ;
			.And. nTotRom > 0 .And. nTotRom > s_GFELIM1
				If s_GFELAC1 == "1"
					cRetorno += "4"
					GFEXFBAEC("", 17,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nTotRom,"@E 999,999.99")),AllTrim(Transform(s_GFELIM1,"@E 999,999.99"))},.T.)
					oGFEXFBFLog:setTexto(CRLF +"  Alerta: " + IIf(lSimulacao,"Agrupador ", "Romaneio ") + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) +" de valor frete " + AllTrim(Transform(nTotRom,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM1,"@E 999,999.99")) + CRLF )
				Else
					cRetorno += "8"
					lDesfazer := .T.
					GFEXFBAEC("", 17,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),"GWN"},{AllTrim(Transform(nTotRom,"@E 999,999.99")),AllTrim(Transform(s_GFELIM1,"@E 999,999.99"))})
					oGFEXFBFLog:setTexto( CRLF +"  Erro: " + IIf(lSimulacao,"Agrupador ", "Romaneio ") + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) +" de valor frete " + AllTrim(Transform(nTotRom,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM1,"@E 999,999.99")) + CRLF + "  Cálculo Desfeito..." + CRLF )
				EndIf
			ElseIf s_GFELAC1 == "0" .And. nTotRom > 0 .And. nTotRom > s_GFELIM1
				oGFEXFBFLog:setTexto(CRLF + IIf(lSimulacao,"  Agrupador ", "  Romaneio ") + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) +" de valor frete " + AllTrim(Transform(nTotRom,"@E 999,999.99")) + " acima do limite parametrizado " + AllTrim(Transform(s_GFELIM1,"@E 999,999.99")) + CRLF + "  Nenhuma ação foi tomada..." + CRLF )
			Else
				oGFEXFBFLog:setTexto(CRLF +IIf(lSimulacao,"  Agrupador ", "  Romaneio ") + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")) +" de valor frete " + AllTrim(Transform(nTotRom,"@E 999,999.99")) + " dentro do limite parametrizado " + AllTrim(Transform(s_GFELIM1,"@E 999,999.99")) + CRLF )
			EndIf

			GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0) 
		EndDo
	Else
		oGFEXFBFLog:setTexto(CRLF +" Nenhuma ação identificada, verificação ignorada..." + CRLF)
	EndIf

	If cRetorno == ""
		cRetorno:= "0"
	EndIf
	
	oGFEXFBFLog:setTexto(CRLF +"# Fim da Verificação dos limites de cálculo " + CRLF)

	GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5) //RestArea(aAreaTCF)
	GFEXFB_ARESTAREA(lTabTemp,aAreaUNC,6) //RestArea(aAreaUNC)
	GFEXFB_ARESTAREA(lTabTemp,aAreaAGR,0) //RestArea(aAreaAGR)
Return cRetorno //fim GFEVlrMaxVld
