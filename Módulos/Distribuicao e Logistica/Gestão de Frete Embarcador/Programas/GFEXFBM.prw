#INCLUDE "TOTVS.ch"
#INCLUDE 'PROTHEUS.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GFEXFUNB.ch"


/*----------------------------------------------------------------------------
{Protheus.doc} GFEClcImpCT
Calcula impostos do calculo de frete atraves do configurador de tributos.
Uso: GFECLCFRT

@author 
@since 
@version 1.0
----------------------------------------------------------------------------*/
Function GFEClcImpCT(cNrCalc, cCdTrp, cNrTab, cNrNeg, aParamComp, cCdclfr, cCdtpop, cCdTrpBase)
	Local aValores      := {}
	Local nVlFretImp    := 0
	Local nVlFretPISCOF := 0
	Local nBaseImp      := 0
	Local nVLImp        := 0
	Local nBasePISCOF   := 0
	Local cUsoCarga     := ""
	Local cTpItens      := ""
	Local cTpClass      := ""
	Local cTribIcms     := ""
	Local aRetICMS      := {0," "}
	Local nAliqIss      := 0
	Local aRetPisCof    := {0,0}
	Local nVlPis        := 0
	Local nVlCofins     := 0
	Local lUsaArray     := GFEXFBUAT()
	Local cAdicIcms     := "1"	// 1-Adiciona imposto (ICMS) no frete
	Local cAdicIss      := "1"  // 1-Adiciona imposto (ISS) no frete
	Local cRatImp       := "1"	// 1-Rateia imposto entre os componentes
	Local cCompImp      := ""
	Local cTotFre       := "1"
	Local cBasImp       := "1"
	Local cBaPiCo       := "1"
	Local cFreMin       := "1"
	Local nPos          := 0
	Local nFatRed       := 1
	Local cTpTrib		:= ""
	Local nPisComIcm    := 0
	Local nPisSemIcm    := 0
	Local nVlImpRet		:= 0
	Local cTmpTrp       := ''
	Local cTpImposto	:= ""	// 1=ICMS, 2=ISS
	Local cGU3_PCISS	:= ""
	Local aScan			:= {}
	Local lGFXFBH1		:= ExistBlock("GFEXFBH1")
	Local cCidOri		:= ""
	Local cCidDest		:= GWU->GWU_NRCIDD
	Local cTpOpDoc 		:= ""
	Local cCidTransp    := GU3->GU3_NRCID

	Local cICMSPT		:= SuperGetMV("MV_ICMSPA",.F.,"2")
	Local nImpPaut		:= 0
	Local nBaseAux		:= 0
	Local nI			:= 0

	Local nPISDIF   	:= SuperGetMv("MV_PISDIF",.F.,0)
	Local nCOFDIF   	:= SuperGetMv("MV_COFIDIF",.F.,0)
	Local nMVPCPIS  	:= SuperGetMv("MV_PCPIS",.F.,1.65)
	Local nMVPCCOFI 	:= SuperGetMv("MV_PCCOFI",.F.,7.6)
	Local nICMBAPI		:= SuperGetMV('MV_ICMBAPI',,'2')

	Local nX		:= 0
	Local aRetCT    := Nil
	Local cCliFor   := Nil
	Local cLoja     := Nil
	Local cIdTrib   := Nil
	Local cQuery    := Nil
	Local cAliasGW8 := Nil
	Local aCFOPs    := {}
	Local cPrdFrete := SuperGetMv("MV_PRITDF",.F.,"")
	Local lLogDebug := SuperGetMV('MV_GFEEDIL',,'1') == "3"
	Local cErpCfg   := SuperGetMv("MV_ERPGFE",.F.,"2")
	Local oCTProcessing := Nil
	Local cTpCliFor := "C"
	Local cTipoNF   := "N"
	Local cAliasSX5 := Nil


	Default cCdclfr 	:= ""
	Default cCdtpop 	:= ""

	If !lUsaArray
		oGFEXFBFLog:setTexto(STR0429 + cCdTrp + STR0067 + cNrTab + STR0068 + cNrNeg + ")" + CRLF) //"    Usando negociação (Transp. "###"; Tabela "###"; Negoc. "
	EndIf

	If Empty(cCdClFr)
		aScan := {cNrCalc}
	Else
		aScan := {cNrCalc,cCdclfr,cCdtpop}
	EndIf
	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
	If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc})

		aValores      := GFEVlBasComp(cNrCalc, aParamComp, cCdclfr, cCdtpop)
		nVlFretImp    := aValores[2] // Valor da soma dos componentes do cálculo que estão marcados como sim para ICMS/ISS na Negociação
		nVlFretPISCOF := aValores[3] // Valor da soma dos componentes do cálculo que estão marcados como sim para PIS/COFINS na Negociação
		GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
		GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,aScan)
		While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == cNrCalc;
				.And. ( Empty(cCdclfr) .Or. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == cCdclfr );
				.And. ( Empty(cCdtpop) .Or. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == cCdtpop )

			nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})
			If nPos > 0  // Componente do cálculo existe no array de parametros
				If aParamComp[nPos,2] == "1" // Considera componente no total do frete
					If aParamComp[nPos,3] == "1" .And. aParamComp[nPos,4] == "2"// Considera componente na base de ICMS/ISS
						nPisComIcm += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
					EndIf

					If aParamComp[nPos,3] == "2" .And. aParamComp[nPos,4] == "2" // Considera componente na base de PIS/COFINS
						nPisSemIcm += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
					EndIf
				EndIf
			EndIf
			GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
		EndDo

		oGFEXFBFLog:setTexto(STR0430 + AllTrim(STR(nVlFretImp)) + CRLF) //"    Valor Base Imposto "

		//Se a cidade de origem e Destino for diferente o calculo é de ICMS, senão é ISS
		oGFEXFBFLog:setTexto(STR0431 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM") + ;
			STR0432 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + ;
			STR0433 + IF(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM") <> GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),"ICMS","ISS") + CRLF + CRLF) //"    Cidade Origem "###"; Cidade Destino "###" -> Imposto "

		if lUsaArray // Indica que serão usados os dados de tabela de frete informados pelo usuário
			if GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM") <> GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")
				cAdicIcms := aTabelaFrt[16]	// Adiciona ICMS ao Frete?
			Else
				cAdicIss := aTabelaFrt[15]	// Adiciona ISS ao Frete?
			EndIf

			cRatImp  := aTabelaFrt[17]  // Rateia imposto?
			cCompImp := aTabelaFrt[18]	// Componente para receber o imposto adicionado
			nPos     := aScan(aTabelaFrt[19],{|x| x[1]==cCompImp})

			if nPos > 0
				cTotFre := aTabelaFrt[19,nPos,12]
				cBasImp := aTabelaFrt[19,nPos,13]
				cBaPiCo := aTabelaFrt[19,nPos,14]
				cFreMin := aTabelaFrt[19,nPos,15]
			EndIf
		Else
			cAdicIcms := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTab+cNrNeg,"GV9_ADICMS") // Adiciona ICMS ao Frete?
			cAdicIss  := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTab+cNrNeg,"GV9_ADISS") // Adiciona ISS ao Frete?
			cRatImp   := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTab+cNrNeg,"GV9_RATIMP") // Rateia imposto pelos componentes?
			cCompImp  := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTab+cNrNeg,"GV9_COMIMP")
			cTotFre   := Posicione("GUY",1,xFilial("GUY")+cCdTrpBase+cNrTab+cNrNeg+cCompImp,"GUY_TOTFRE")
			cBasImp   := Posicione("GUY",1,xFilial("GUY")+cCdTrpBase+cNrTab+cNrNeg+cCompImp,"GUY_BASIMP")
			cBaPiCo   := Posicione("GUY",1,xFilial("GUY")+cCdTrpBase+cNrTab+cNrNeg+cCompImp,"GUY_BAPICO")
			cFreMin    := Posicione("GUY",1,xFilial("GUY")+cCdTrpBase+cNrTab+cNrNeg+cCompImp,"GUY_FREMIN")
		EndIf

		cTmpTrp := cCdTrp
		cCidOri	:= GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"ORIGEM")
		If cCidOri <> GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") .AND. POSICIONE("GU3",1,XFILIAL("GU3")+cTmpTrp,"GU3_TRANSP") == '1' .And. POSICIONE("GU3",1,XFILIAL("GU3")+cTmpTrp,"GU3_AUTON") <> '1'
			cTpImposto := "1"
		Else
			cTpImposto := "2"
		EndIf

		// Quando for cálculo de serviço para ocorrência e o tipo de imposto for ISS (Cidade Origem ou Destino)
		// Força o cálculo de ISS
		If lCalcServ .AND. (cServTpImp == "2" .OR. cServTpImp == "3")
			oGFEXFBFLog:setTexto("    # Cálculo de serviço para ocorrência com imposto de ISS. Tipo de imposto ISS (Definido no cadastro de tipo de ocorrência): " + cServTpImp + " [1:ICMS ou ISS, conforme cidade origem x destino, 2: Cidade origem, 3: Cidade destino]" + CRLF + CRLF)
			cTpImposto := "2"
		EndIf
		
		GU3->(dbSetOrder(1))	// GU3_FILIAL+GU3_CDEMIT
		If GU3->(dbSeek(xFilial('GU3') + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST")))
			cTpCliFor := iif(Alltrim(Posicione("GV5", 1, xFilial("GV5") + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), "GV5_SENTID")) == '2', 'C', 'F')

			If cErpCfg == "1" // Se integração ativa com ERP Datasul
				If cTpCliFor == "C"
					cCliFor := "CLIGFE"
				Else
					cCliFor := "FORGFE"
				EndIf
				cLoja   := "99"
			Else
				cCliFor := Alltrim(GU3->GU3_CDERP)
				cLoja   := Alltrim(GU3->GU3_CDCERP)
			EndIf


			cAliasSX5 := GetNextAlias()
			cQuery := "SELECT SX5.X5_CHAVE AS CHAVE"
			cQuery += " FROM " + RetSqlName("SX5") + " SX5"
			cQuery += " WHERE SX5.X5_FILIAL = ?"
			cQuery += " AND SX5.X5_DESCRI = ?"
			cQuery += "	AND SX5.D_E_L_E_T_ = ''"
			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery)

			oQry:SetString(1, xFilial("SX5"))
			oQry:SetString(2, GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"))

			cAliasSX5 := oQry:OpenAlias()

			If (cAliasSX5)->(!EoF())
				cTipoNF := Alltrim((cAliasSX5)->CHAVE) // "N","D","B","C","P","I")
			EndIf
			(cAliasSX5)->(dbCloseArea())
		EndIf

		If !Empty(cCidOri)
			cUFRem := Posicione("GU7", 1, xFilial("GU7") + cCidOri, "GU7_CDUF")
		EndIf

		/*******************************/
		/************  ICMS  ***********/
		/*******************************/
		If cTpImposto == "1"
			oGFEXFBFLog:setTexto(STR0434 + CRLF + CRLF) //"    # Calculando ICMS..."
			GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1)
			if GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})
				GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
				if GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDTPDC"), ;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"EMISDC")  , ;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"SERDC")   , ;
						GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRDC")})

					cUsoCarga := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"USO")
					cTpItens  := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"TPITEM")
					cTpClass  := GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR")
					cTribICMS := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"ICMSDC")

					oGFEXFBFLog:setTexto(Space(6) + STR0435 + CRLF) //"Obtendo alíquota e tributação..."
					oGFEXFBFLog:setTexto(Space(8) + STR0436 + cTmpTrp  + CRLF +; // Transportador :
					Space(8) + STR0437 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDREM")  + CRLF +; // Remetente     :
					Space(8) + STR0438 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST") + CRLF +; // Destinatario  :
					Space(8) + STR0439 + cCidOri + CRLF +; // Cidade Origem :
					Space(8) + STR0440 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + CRLF +; // Cidade Destino:
					Space(8) + STR0443 + GFEFldInfo("GW1_USO",cUsoCarga,2) + CRLF +; // Uso da Carga  :
					Space(8) + STR0444 + cTpItens          + CRLF +; // Tipo de Item  :
					Space(8) + STR0557 + cTpClass          + CRLF +; // Class. Frete  : //"Class. Frete  : "
					Space(8) + STR0445 + GFEFldInfo("GW1_ICMSDC",cTribIcms,2) + CRLF)   // ICMS na Merc. :
					
					GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
					GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
					GFEXFB_CSEEK(lTabTemp, cTRBAGRU, @aAgrFrt, 0,{GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRAGRU")})

					cTpOpDoc := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPOP")

					aRetICMS := GFEFnIcms(  cTmpTrp, ; // Código do transportador
											GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDREM"), ; // Código do remetente
											GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST"),; // Código do destinatario
											cCidOri,; // Número da cidade de origem
											GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),; // Número da cidade de destino
											cUsoCarga,; // Forma de utilização da mercadoria
											cTpItens, ; // Tipo de item
											cTpClass, ; // Classificação de frete
											cTribIcms, ; // Mercadoria é tributada de ICMS?
											IIF(!Empty(cTpOpDoc),cTpOpDoc,GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPOP")),; //Posicione(cTRBAGRU,1,GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"NRAGRU"),"CDTPOP"),; //Tipo de Operação do Agrupador do Documento de Carga
											xFilial("GWF"); // Filial do cálculo - Usado no parâmetro MV_GFECRIC para as exceções das filiais que não tem direito a crédito
										) 

					oGFEXFBFLog:setTexto(Space(8) + STR0446 + cValToChar(aRetICMs[1]) + CRLF +; // Aliquota      :
					Space(8) + STR0447 + AllTrim(GFEFldInfo("GUT_TREC", aRetICMS[2], 2)) + CRLF +; // Tributação    :
					Space(8) + STR0441 + cValToChar(aRetIcms[3]) + CRLF +; // % Redução Base:
					Space(8) + STR0442 + cValToChar(aRetIcms[4]) + CRLF)   // % Crédito ICMS:

					If cICMSPT == "1"
						nImpPaut := GFEICMPAUT(cTmpTrp,;
											   GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDREM"), ; // Código do remetente
											   GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST"),; // Código do destinatario
											   cCidOri,;
											   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),; // Número da cidade de destino
											   cTpClass,; // Classificação de frete
											   GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPOP"))
					EndIf

					nBaseImp := nVlFretImp

					If !lTabTemp
						For nI := 1 To Len(aTRBCCF1)
							Aadd(aCompLiq, {aTRBCCF1[nI][1], aTRBCCF1[nI][4], aTRBCCF1[nI][5], aTRBCCF1[nI][8]})
						Next nI
					EndIf

					If aRetICMS[2] $ "13567" // Tipo tributacao: 1-Normal, 3-Subst. Tributaria, 5 - Reduzido, 6 - Outros, 7 - Presumido
						If cAdicIcms == "1"  // 1-Adiciona ICMS ao Frete

							oGFEXFBFLog:setTexto(STR0448 + CRLF) //"      Adicionando ICMS ao frete"

							If aRetICMS[2] == "5"
								oGFEXFBFLog:setTexto(Space(8) + STR0558 + cValToChar(aRetICMS[3]) + STR0559 + CRLF) //"Com redução da base em "###" %"

								nFatRed := 1 - aRetICMS[3]/100
							EndIf

							nVlFretPISCOF -= nBaseImp

							nBaseImp   := nVlFretImp / (1-((aRetICMs[1]/100) * nFatRed))

							nBaseAux	:= 0
							
							If cICMSPT == "1"
								oGFEXFBFLog:setTexto("    # Valores Base ICMS " + CRLF + CRLF) 
								oGFEXFBFLog:setTexto("        Original: " + cValToChar(nBaseImp) + CRLF) 
								oGFEXFBFLog:setTexto("        ICMS Pauta: " + cValToChar(nImpPaut) + CRLF + CRLF) 

								If nImpPaut > nBaseImp
									oGFEXFBFLog:setTexto("        Utilizado valor de ICMS Pauta! " + CRLF + CRLF)

									nBaseImp := nImpPaut

									nBaseAux := nBaseImp / (1-((aRetICMs[1]/100) * nFatRed))
								Else
									oGFEXFBFLog:setTexto("        Mantido valor original de base ICMS! " + CRLF + CRLF)
								EndIf	
							EndIf
							
							nPisComIcm := nPisComIcm / (1-((aRetICMs[1]/100) * nFatRed))
							oGFEXFBFLog:setTexto(STR0449 + cValToChar(nBaseImp) + CRLF) //"      Nova base de cálculo "

							// Tratar truncamento/arredondamento do valor do imposto
							nBaseImp := GFETratDec(nBaseImp,6)
							nPisComIcm := GFETratDec(nPisComIcm,6)

							If nBaseAux > 0
								nVLImp := nBaseAux - nBaseImp
							Else
								nVLImp := nBaseImp - nVlFretImp
							EndIf

							oGFEXFBFLog:setTexto(STR0450 + cValTochar(nVlImp) + CRLF)  //"      Valor do Imposto "

							// Como o imposto foi adicionado ao frete, também deve ser adicionado a base de calculo do PIS/COFINS
					  		nVlFretPISCOF += nBaseImp

							// Tratar truncamento/arredondamento do valor do imposto
							nVlImp := GFETratDec(nVlImp,6)

							// Ponto de Entrada SLC - Valor base de Imposto
							If lGFXFBH1
								nNewVlImp := ExecBlock("GFEXFBH1",.F.,.F.,{ nBaseImp, nVLImp, aRetICMs[1], xFilial("GWU"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"CDTPDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"EMISDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"SERDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"NRDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"SEQ") })

								If ValType(nNewVlImp) == "N"
									oGFEXFBFLog:setTexto(Space(8) + "Valor ICMS alterado de: " + cValToChar(nVLImp) + " para: " + cValToChar(nNewVlImp) + " pelo Ponto de Entrada GFEXFBH1" + CRLF)
									nVLImp	 	:= nNewVlImp
								EndIf
							EndIf

							/*Chamado: TIFRU8. Ao ratear o valor de ICMS ou jogar em um componente específico,
							verificar se o cálculo tem valor de ICMS retido maior que zero E
							o valor do ICMS retido é diferente do valor do ICMS.
							Nesta situação, o valor a ser rateado/gravado em componente a parte, não será
							mais o total do ICMS e sim, o valor do ICMS descontando o valor do ICMS retido.*/

							//Copia o valor do imposto para outra variável
							nVlImpST := nVlImp
							nVlImpRet := nVlImp * (1 - (aRetIcms[4] / 100))

							If SuperGetMv("MV_DIMRET", .F., "2") == "2"

								If nVlImpRet > 0 .And. nVlImpRet != nVlImp
									nVlImpST := nVlImp - nVlImpRet
									oGFEXFBFLog:setTexto("	Descontando valor do ICMS Retido do ICMS. " + cValToChar(nVlImp) + " (Valor Imposto) - " + cValToChar(nVlImpRet) + " (Valor do Imposto Retido)" + CRLF )
									oGFEXFBFLog:setTexto("	Novo valor de ICMS do frete: " + cValToChar(nVlImpST) + "." + CRLF)
									nVlImpST := GFETratDec(nVlImpST,6)
								EndIf
							EndIf

							/*-------------------------------------------*/

							If cRatImp == "1"
								//Ratear o imposto entre os componentes
								oGFEXFBFLog:setTexto(CRLF + STR0451 + cValToChar(nVlImpST) + STR0452 + CRLF) //"      # Rateando valor do imposto ("###") entre os componentes..."
								GFERatImp(cNrCalc, aParamComp, nVlFretImp, nVlImpST, cCdclfr,cCdtpop)
							Else
								/*Verifica em que componente deve gravar o valor do imposto, se encontrar soma imposto ao valor do componente*/
								GFEGrvComImp(cNrCalc, cCompImp, nVlImpST, cTotFre, cBasImp, cBaPiCo, cFreMin,"2",0,cCdclfr,cCdtpop)
							EndIf
						Else
							If cICMSPT == "1"
								oGFEXFBFLog:setTexto("    # Valores Base ICMS " + CRLF + CRLF) 
								oGFEXFBFLog:setTexto("        Original: " + cValToChar(nVlFretImp) + CRLF) 
								oGFEXFBFLog:setTexto("        ICMS Pauta: " + cValToChar(nImpPaut) + CRLF + CRLF) 

								If nImpPaut > nBaseImp
									oGFEXFBFLog:setTexto("        Utilizado valor de ICMS Pauta! " + CRLF + CRLF)

									nBaseImp := nImpPaut
								Else
									oGFEXFBFLog:setTexto("        Mantido valor original de base ICMS! " + CRLF + CRLF)
								EndIf	
							EndIf

							If aRetICMS[2] == "5"
								oGFEXFBFLog:setTexto(Space(8) + STR0558 + cValToChar(aRetICMS[3]) + STR0559 + CRLF) //"Com redução da base em "###" %"
								nFatRed  := 1 - aRetICMS[3]/100
								nBaseImp := nBaseImp * nFatRed
							EndIf

							//2-apenas calcula o imposto de acordo com a Aliquota
							nVLImp := nBaseImp * (aRetICMs[1]/100)
							oGFEXFBFLog:setTexto(STR0453 + AllTrim(STR(nVlImp)) + CRLF) //"      Destacando ICMS do frete "

							// Tratar truncamento/arredondamento do valor do imposto
							nVlImp := GFETratDec(nVlImp,6)

							// Ponto de Entrada SLC - Valor base de Imposto
							If lGFXFBH1
								nNewVlImp := ExecBlock("GFEXFBH1",.F.,.F.,{ nBaseImp, nVLImp, aRetICMs[1], xFilial("GWU"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"CDTPDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"EMISDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"SERDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"NRDC"),;
									GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1,  7,"SEQ") })

								If ValType(nNewVlImp) == "N"
									oGFEXFBFLog:setTexto(Space(8) + "Valor ICMS alterado de: " + cValToChar(nVLImp) + " para: " + cValToChar(nNewVlImp) + " pelo Ponto de Entrada GFEXFBH1" + CRLF)
									nVLImp	 	:= nNewVlImp
								EndIf
							EndIf

						EndIf
					Else
						oGFEXFBFLog:setTexto(Space(6) + STR0560 + AllTrim(GFEFldInfo("GUT_TREC",aRetIcms[2],2)) + STR0561 + CRLF) //"Tipo de tributação "###" não gera valor de imposto."
					EndIf

					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLICMS",GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLICMS") + nVLImp)
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ICMRET",GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ICMRET") + if(aRetICMS[2] == "7" /*Presumido*/, nVlImp * (1 - (aRetIcms[4] / 100)), 0))
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"PCICMS",aRetIcms[1])
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASICM",GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASICM") + nBaseImp)
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"TPTRIB",aRetIcms[2])
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"PCREIC",aRetIcms[3])
					GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ADICIS",cAdicIcms)
					if aRetIcms[2] == "7"
						oGFEXFBFLog:setTexto(CRLF + Space(6) + STR0562 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ICMRET")) + CRLF) //"Valor do ICMS retido: "
					EndIf

				EndIf
			EndIf

		ElseIf POSICIONE("GU3",1,XFILIAL("GU3")+cTmpTrp,"GU3_AUTON") <> '1'

			oGFEXFBFLog:setTexto(STR0454 + CRLF + CRLF) //"    # Calculando ISS..."

			/*******************************/
			/************  ISS   ***********/
			/*******************************/
			cGU3_PCISS := POSICIONE("GU3", 1, xFilial("GU3") + cTmpTrp, "GU3_PCISS")

			If !ChkFile("GXM") .Or. Type("cTpOcor") == "U"
				If (cServTpImp != "2" .AND. cServTpImp != "3") .OR. !Empty(cGU3_PCISS)
					If Empty(cGU3_PCISS)
						nAliqISS := Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
					Else
						nAliqISS := cGU3_PCISS
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base no cadastro do transportador: " + cTmpTrp + CRLF)
					EndIf
				Else
					// Cálculo de serviço para ocorrência, com tipo de imposto ISS (Cidade Origem ou Destino)
					If cServTpImp == "2"
						// ISS: Cidade Origem
						nAliqISS := Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
					ElseIf cServTpImp == "3"
						// ISS: Cidade Destino
						nAliqISS := Posicione("GU7",1,xFilial("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de destino: " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + CRLF)
					EndIf
				EndIf
			Else
				GXM->(dbSetOrder(01))
				If (cServTpImp != "2" .AND. cServTpImp != "3") .OR. !Empty(cGU3_PCISS)
					If GXM->(dbSeek(xFilial("GXM")+cCidOri+cTpOcor))
						nAliqISS := GXM->GXM_PCISS
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
						oGFEXFBFLog:setTexto("      # Percentual de ISS por tipo de ocorrência encontrado! Sobrepondo percentual anterior " + CRLF)
						oGFEXFBFLog:setTexto("      # Percentual antigo: " + cValToChar(Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")) + ". Novo percentual: " + cValToChar(GXM->GXM_PCISS) + ". " + CRLF)
					ElseIf Empty(cGU3_PCISS)
						nAliqISS := Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
					Else
						nAliqISS := cGU3_PCISS
						oGFEXFBFLog:setTexto("      # Alíquota de ISS com base no cadastro do transportador: " + cTmpTrp + CRLF)
					EndIf
				Else
					//Cálculo de serviço para ocorrência, com tipo de imposto ISS (Cidade Origem ou Destino)
					//Chamado TROMFP

					If cServTpImp == "2"
						If GXM->(dbSeek(xFilial("GXM")+cCidOri+cTpOcor))
							nAliqISS := GXM->GXM_PCISS
							oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
							oGFEXFBFLog:setTexto("      # Percentual de ISS por tipo de ocorrência encontrado! Sobrepondo percentual anterior " + CRLF)
							oGFEXFBFLog:setTexto("      # Percentual antigo: " + cValToChar(Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")) + ". Novo percentual: " + cValToChar(GXM->GXM_PCISS) + ". " + CRLF)
						Else
							// ISS: Cidade Origem
							nAliqISS := Posicione("GU7",1,xFilial("GU7")+cCidOri,"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
							oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de origem: " + cCidOri + CRLF)
						EndIf
					ElseIf cServTpImp == "3"
						If GXM->(dbSeek(xFilial("GXM")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN")+cTpOcor))
							nAliqISS := GXM->GXM_PCISS
							oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de destino: " + cCidOri + CRLF)
							oGFEXFBFLog:setTexto("      # Percentual de ISS por tipo de ocorrência encontrado! Sobrepondo percentual anterior " + CRLF)
							oGFEXFBFLog:setTexto("      # Percentual antigo: " + cValToChar(Posicione("GU7",1,xFilial("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),"GU7_PCISS")) + ". Novo percentual: " + cValToChar(GXM->GXM_PCISS) + ". " + CRLF)
						Else
							// ISS: Cidade Destino
							nAliqISS := Posicione("GU7",1,xFilial("GU7")+GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN"),"GU7_PCISS")	 // Busca a aliquota no cadastro de cidades
							oGFEXFBFLog:setTexto("      # Alíquota de ISS com base na cidade de destino: " + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + CRLF)
						EndIf
					EndIf
				EndIf
			EndIf

			nBaseImp := nVlFretImp
			oGFEXFBFLog:setTexto(STR0455 + cValToChar(nAliqISS) + CRLF)

			GU3->(dbSetOrder(1) )
			GU3->(dbSeek(xFilial("GU3")+cTmpTrp) )

			If lSimulacao .and. Empty(GU3->GU3_CONISS)
				GU3->(dbSeek(xFilial("GU3") + cCdTrp))
			Endif

			If GU3->GU3_CONISS == "1"

				If cAdicIss == "1" //1-Adiciona ISS ao Frete

					oGFEXFBFLog:setTexto(STR0456 + CRLF) //"      Adicionando ISS ao frete"

					nVlFretPISCOF -= nBaseImp

					nBaseImp := nVlFretImp / (1-(nAliqISS/100))
					nPisComIcm := nPisComIcm / (1-(nAliqISS/100))
					oGFEXFBFLog:setTexto(STR0449 + cValToChar(nBaseImp) + CRLF) //"      Nova base de cálculo "

					// Tratar truncamento/arredondamento da base do imposto
					nBaseImp := GFETratDec(nBaseImp,6)
					nPisComIcm := GFETratDec(nPisComIcm,6)

					nVLImp  := nBaseImp - nVlFretImp
					oGFEXFBFLog:setTexto(STR0450 + cValToChar(nVlImp) + CRLF)  //"      Valor do Imposto "

					// Tratar truncamento/arredondamento do valor do imposto
					nVlImp := GFETratDec(nVlImp,6)

					// Como o imposto foi adicionado ao frete, também deve ser adicionado a base de calculo do PIS/COFINS
					nVlFretPISCOF += nBaseImp

					If cRatImp == "1"
						// Ratear o imposto entre os componentes
						oGFEXFBFLog:setTexto(CRLF + STR0451 + cValToChar(nVlImp) + STR0452 + CRLF)					 //"      # Rateando valor do imposto ("###") entre os componentes..."
						GFERatImp(cNrCalc, aParamComp, nVlFretImp, nVLImp, cCdclfr,cCdtpop)
					Else
						// Gravar o valor do imposto em um componente da tabela
						GFEGrvComImp(cNrCalc, /*GV9->GV9_COMIMP*/ cCompImp, nVlImp, cTotFre, cBasImp, cBaPiCo, cFreMin,"2", 0, cCdclfr,cCdtpop)
					EndIf
				Else
					//2-apenas calcula o imposto de acordo com a Aliquota
					nVLImp := nVlFretImp * (nAliqISS/100)
					oGFEXFBFLog:setTexto(STR0457 + AllTrim(STR(nVlImp)) + CRLF)	   //"      Destacando ISS do frete "

					// Tratar truncamento/arredondamento do valor do imposto
					nVlImp := GFETratDec(nVlImp,6)
				EndIf
					If nVLImp > 0
						If GFXCP1212410("GU3_APISSO") .AND. cCidTransp != cCidOri .AND. cCidTransp != cCidDest
							If GU3->GU3_APISSO == "1"
								cTpTrib := "1"
							ElseIf GU3->GU3_APISSO == "2"
								cTpTrib := "3"
							EndIf
						Else
							If GU3->GU3_APUISS == "1"
								cTpTrib := "1"
							ElseIf GU3->GU3_APUISS == "2"
								cTpTrib := "3"
							EndIf 
						EndIf			
					Else
						cTpTrib := "2"
					EndIf
			Else
				cTpTrib  := "2"
				nVLImp   := 0
				nAliqISS := 0
			EndIf

			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLISS" ,GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLISS") + nVLImp)
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASISS",GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASISS") + nBaseImp)
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"PCISS" ,nAliqISS)
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"TPTRIB",cTpTrib) //IF(nAliqISS > 0,"1","2") // 1-Tributado, 2-Nao Tributado
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ADICIS",cAdicIss)

		ElseIf Posicione("GU3", 1, xFilial("GU3") + cTmpTrp, "GU3_AUTON") == '1'

			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"TPTRIB","6")
		EndIf


		//------------------------------------------------------------------------------------------
		// Tratamento para IBS
		//------------------------------------------------------------------------------------------
		If FindClass("totvs.protheus.backoffice.fiscal.tciclass.TCIProcessing")
			// Identificando CFOPs dos Documentos
			For nX := 1 To Len(aDocCar2)
				cAliasGW8 := GetNextAlias()

				cQuery := "SELECT DISTINCT GW8.GW8_CFOP AS CFOP"
				cQuery += " FROM " + RetSqlName("GW8") + " GW8"
				cQuery += " WHERE GW8.GW8_FILIAL = ?"
				cQuery += " AND GW8.GW8_CDTPDC = ?"
				cQuery += " AND GW8.GW8_EMISDC = ?"
				cQuery += " AND GW8.GW8_SERDC = ?"
				cQuery += " AND GW8.GW8_NRDC = ?"
				cQuery += "	AND GW8.D_E_L_E_T_ = ''"

				cQuery := ChangeQuery(cQuery)
				oQry := FWExecStatement():New(cQuery)

				oQry:SetString(1, aDocCar2[nX][19])
				oQry:SetString(2, aDocCar2[nX][4])
				oQry:SetString(3, aDocCar2[nX][1])
				oQry:SetString(4, aDocCar2[nX][2])
				oQry:SetString(5, aDocCar2[nX][3])

				cAliasGW8 := oQry:OpenAlias()
				If (cAliasGW8)->(!EoF())
					//Count To nRecCount		// Quantidade de registros
					Do While !((cAliasGW8)->(EoF()))

						If aScan(aCFOPs, {|x| Alltrim(x) == Alltrim((cAliasGW8)->CFOP) }) == 0
							Aadd(aCFOPs, Alltrim((cAliasGW8)->CFOP))
						EndIf

						(cAliasGW8)->(dbSkip())
					EndDo
				EndIf
				(cAliasGW8)->(dbCloseArea())
			Next


			oGFEXFBFLog:setTexto(CRLF + "    # Calculando IBS/CBS..." + CRLF + CRLF)
			GFEXFB_BORDER(lTabTemp,cTRBDOC,02,1)

			If Empty(aCFOPs)
				oGFEXFBFLog:setTexto(CRLF + "    - Não foi identificado CFOP dos itens para cálculo dos tributos..." + CRLF + CRLF)
			Else
				// Inicialização do MatXFis e classe TCIProcessing
				MaFisSave()
				MaFisEnd()
				MaFisIni(cCliFor,;	// 1-Codigo Cliente/Fornecedor
						cLoja,;		// 2-Loja do Cliente/Fornecedor
						cTpCliFor,;	// 3-C:Cliente , F:Fornecedor
						cTipoNF,;	// 4-Tp NF( "N","D","B","C","P","I" )
						Nil,;		// 5-Tipo do Cliente/Fornecedor
						Nil,;		// 06 - Relacao de Impostos que suportados no arquivo
						,;			// 07
						.F.,;		// 08
						,;			// 09
						,;			// 10
						,;			// 11
						,;			// 12
						,;			// 13
						,;			// 14
						,;			// 15
						,;			// 16
						,;			// 17
						,;			// 18
						,;			// 19
						,;			// 20
						,;			// 21
						,;			// 22
						,;			// 23
						,;			// 24
						,;			// 25
						,;			// 26
						,;			// 27
						,;			// 28
						,;			// 29
						,;			// 30
						,;			// 31
						,;			// 32
						.T.,;		// 33
						,;
						,;
						,.T. )

				For nX := 1 To Len(aCFOPs)
					//-- Agrega os itens para a funcao fiscal.
					SB1->(MsSeek(FWxFilial("SB1") + cPrdFrete))

					MaFisAdd(SB1->B1_COD,;  // 1-Codigo do Produto ( Obrigatorio )
							,;   			// 2-Codigo do TES ( Opcional )
							1,;  			// 3-Quantidade ( Obrigatorio )
							nVlFretImp,;	// 4-Preco Unitario ( Obrigatorio )
							0,;	 			// 5-Valor do Desconto ( Opcional )
							"",;	   		// 6-Numero da NF Original ( Devolucao/Benef )
							"",;			// 7-Serie da NF Original ( Devolucao/Benef )
							0,;				// 8-RecNo da NF Original no arq SD1/SD2
							0,;				// 9-Valor do Frete do Item ( Opcional )
							0,;				// 10-Valor da Despesa do item ( Opcional )
							0,;				// 11-Valor do Seguro do item ( Opcional )
							0,;				// 12-Valor do Frete Autonomo ( Opcional )
							nVlFretImp,;	// 13-Valor da Mercadoria ( Obrigatorio )
							,,,,,,;         // parâmetros opcionais que não serão utilizados por enquanto
							aCFOPs[nX],;           // 20-CFOP ( Obrigatorio se não passou TES )
							,,,,,,,SB1->B1_ORIGEM; // 28-Classificação Fiscal
							)
					
					MaFisAlt("IT_CF", aCFOPs[nX], 1)
				Next

				oCTProcessing := GFEConfigTributosProcessing():New()
				oCTProcessing:getDataItemProcessing()
				aRetCT := oCTProcessing:processResponseSearchList()
				If !Empty(aRetCT) .And. !Empty(aRetCT[1][1])
					If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCar2, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC"), GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})
						GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
						If GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{	GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDTPDC"), ;
																			GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"EMISDC") , ;
																			GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"SERDC") , ;
																			GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"NRDC")})

							oGFEXFBFLog:setTexto(Space(6) + STR0435 + CRLF) // "Obtendo alíquota e tributação..."
							oGFEXFBFLog:setTexto(Space(8) + STR0436 + cTmpTrp  + CRLF +; 																	// Transportador :
												 Space(8) + STR0437 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDREM")  + CRLF +; 						// Remetente     :
												 Space(8) + STR0438 + GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"CDDEST") + CRLF +; 						// Destinatario  :
												 Space(8) + "Cliente/Loja  : " + Alltrim(cCliFor) + "/" + Alltrim(cLoja) + CRLF +; 							// Cliente/Loja  :
												 Space(8) + STR0439 + cCidOri + CRLF +; 																	// Cidade Origem :
												 Space(8) + STR0440 + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"DESTIN") + CRLF +; 						// Cidade Destino:
												 Space(8) + STR0443 + GFEFldInfo("GW1_USO", GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCar2, 1,"USO"), 2) + CRLF +;// Uso da Carga  :
												 Space(8) + STR0444 + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"TPITEM") + CRLF +; 						// Tipo de Item  :
												 Space(8) + STR0557 + GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDCLFR") + CRLF + CRLF)					// Class. Frete  :

							// Tabela F2C | 000060 IBS ESTADUAL - Imposto sobre Bens e Serviços
							// Tabela F2C | 000061 IBS MUNICIPAL - Imposto sobre Bens e Serviços
							// {cCodigoRegra, cDescricaoRegra, cIdentTributo, cBaseTributo, cAliquotaTributo, cValorTributo, cCodigoCst, cMsg}
							For nX := 1 To Len(aRetCT)
								If Alltrim(aRetCT[nX][3]) $ '000060;000061' .And. !Empty(aRetCT[nX][1])
									oGFEXFBFLog:setTexto(Space(8) + "# Valores Base IBS " + CRLF) 
									oGFEXFBFLog:setTexto(Space(12) + "Base Cálculo : " + cValToChar(aRetCT[nX][4]) + CRLF) 
									oGFEXFBFLog:setTexto(Space(12) + "Aliquota     : " + cValToChar(aRetCT[nX][5]) + CRLF)
									oGFEXFBFLog:setTexto(Space(12) + "Valor Imposto: " + cValToChar(aRetCT[nX][6]) )

									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "BASIBS", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASIBS") + aRetCT[nX][4])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "PCIBS", aRetCT[nX][5])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "VLRIBS", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLRIBS") + aRetCT[nX][6])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "IDTRIB", cIdTrib)

								ElseIf Alltrim(aRetCT[nX][3]) $ '000062' .And. !Empty(aRetCT[nX][1])
									oGFEXFBFLog:setTexto(Space(8) + "# Valores Base CBS " + CRLF) 
									oGFEXFBFLog:setTexto(Space(12) + "Base Cálculo : " + cValToChar(aRetCT[nX][4]) + CRLF) 
									oGFEXFBFLog:setTexto(Space(12) + "Aliquota     : " + cValToChar(aRetCT[nX][5]) + CRLF)
									oGFEXFBFLog:setTexto(Space(12) + "Valor Imposto: " + cValToChar(aRetCT[nX][6]) )

									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "BASCBS", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BASCBS") + aRetCT[nX][4])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "PCCBS", aRetCT[nX][5])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "VLRCBS", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLRCBS") + aRetCT[nX][6])
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6, "IDTRIB", cIdTrib)
								Else
									oGFEXFBFLog:setTexto(Alltrim(aRetCT[nX][8]) + CRLF)
								EndIf
							Next
						EndIf
					EndIf
				Else
					oGFEXFBFLog:setTexto("    Não foi identificado impostos calculados pelo Configurador de Tributos. Verifique os dados abaixo e realize o teste pelo Simulador de Operação." + CRLF)
					If lLogDebug
						oGFEXFBFLog:setTexto(Space(8) + STR0436 + cTmpTrp  + CRLF +; 																	// Transportador :
											Space(8) + "Tipo Destinatário:   " + Alltrim(cTpCliFor) + CRLF +; 	
											Space(8) + iif(Alltrim(cTpCliFor)=="C", "Cliente/Loja       : ", "Fornecedor/Loja    : ") + Alltrim(cCliFor) + "/" + Alltrim(cLoja) + CRLF +;
											Space(8) + "Tipo NF            : " + Alltrim(cTipoNF) + CRLF +; 											// Cliente/Fornecedor  :
											Space(8) + "Produto (MV_PRITDF): " + Alltrim(cPrdFrete) + CRLF )
					EndIf
				EndIf

				MaFisEnd()
			EndIf
		EndIf
		

		/**************************/
		/********PIS/COFINS********/
		/**************************/
		If Posicione("GU3", 1, xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"), "GU3_AUTON") <> "1"

			oGFEXFBFLog:setTexto(CRLF + STR0458 + CRLF + CRLF) //" # Calculando PIS/COFINS..."

			nBasePISCOF := nVlFretPISCOF

			If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLISS") > 0
				If SuperGetMV('MV_ISSBAPI',,'2') $ "2N" // RETORNA O VALOR SE CALCULA PIS COM BASE NO ISS
					oGFEXFBFLog:setTexto("      Subtraindo ISS (" + cValToChar(nVlImp) + ") da base de cálculo de PIS/COFINS." + CRLF) //"      Somando ISS ("###") na base de PIS ("

					nBasePISCOF -= nVlImp

					If nBasePISCOF < 0
						nBasePISCOF := 0
					EndIf

					// Tratar truncamento/arredondamento da base do imposto
					nBasePISCOF := GFETratDec(nBasePISCOF,6)
				EndIf
			EndIf

			oGFEXFBFLog:setTexto("      Base de PIS/COFINS antes da retirada de ICMS: " + cValToChar(nBasePISCOF) + CRLF + CRLF)

			oGFEXFBFLog:setTexto("      Verificando a retirada de ICMS da Base de PIS/COFINS." + CRLF)
			oGFEXFBFLog:setTexto("      Valor do parâmetro MV_ICMBAPI (Opções: 1- Manter; 2- Retira ICMS Retido; 3- Retira ICMS Total): " + nICMBAPI + CRLF + CRLF) // Opção do parâmetro MV_ICMBAPI

			If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLICMS") > 0 //VERIFICA SE E ICMS
				If nICMBAPI $ "2N" // RETORNA O VALOR SE CALCULA PIS COM BASE NO ICMS
					oGFEXFBFLog:setTexto("      Subtraindo ICMS Retido (" + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ICMRET")) + ") da base de cálculo de PIS/COFINS." + CRLF) //"      Subtraindo ICMS ("###") na base de PIS ("

					nBasePISCOF -= GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"ICMRET")
				ElseIf nICMBAPI $ "3"
					oGFEXFBFLog:setTexto("      Subtraindo ICMS Total (" + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLICMS")) + ") da base de cálculo de PIS/COFINS." + CRLF) //"      Subtraindo ICMS ("###") na base de PIS ("

					nBasePISCOF -= GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLICMS")
				Else
					oGFEXFBFLog:setTexto("      Não houve retirada de ICMS da base de PIS/COFINS" + CRLF)
				EndIf

				If nBasePISCOF < 0
					nBasePISCOF := 0
				EndIf

				oGFEXFBFLog:setTexto("      Base de PIS/COFINS atualizada após a retirada de ICMS: " + cValToChar(nBasePISCOF) + CRLF)
				// Tratar truncamento/arredondamento da base do imposto
				nBasePISCOF := GFETratDec(nBasePISCOF,6)
			EndIf

			//Chama a função, para retornar o percentual do PIS\COFINS de acordo com os itens dos documentos de carga {[1] PIS, [2] COFINS}
			aRetPisCof := GFEPISCOF(cNrCalc)

			oGFEXFBFLog:setTexto(STR0459 + ":" + AllTrim(STR(aRetPisCof)) + " X " + AllTrim(STR(nBasePISCOF)) + " = " + AllTrim(STR(aRetPisCof * nBasePISCOF)) + CRLF) //" Valor Base PIS/COFINS "

			cGU3TPTrib := Posicione("GU3", 1, xFilial("GU3") + cTmpTrp, "GU3_TPTRIB")
			If cGU3TPTrib == "2".AND. nPISDIF <> 0 
				nPcPis := nPISDIF
			Else
				nPcPis := nMVPCPIS
			EndIf
			nVlPIS := GFETratDec((aRetPisCof * nBasePISCOF) * (nPCPIS/100),0,.T.)

			oGFEXFBFLog:setTexto(CRLF)
			oGFEXFBFLog:setTexto(STR0463 + cValToChar(nPcPis) + CRLF) //"      Alíquota PIS "
			oGFEXFBFLog:setTexto(STR0465 + cValToChar(nPcPis) + "/100) X " + cValToChar(aRetPisCof * nBasePISCOF) + " = " + cValToChar(nVlPis) + CRLF) //"      Valor de PIS -> ("

			// Tratar truncamento/arredondamento do valor do imposto
			nVlPis := GFETratDec(nVlPis,6,.T.)

			oGFEXFBFLog:setTexto(CRLF)

			If cGU3TPTrib == "2" .AND. nCOFDIF <> 0 
				nPcCofins := nCOFDIF
			Else
				nPcCofins := nMVPCCOFI
			EndIf
			nVlCofins := (aRetPisCof * nBasePISCOF) * (nPCCofins/100)

			oGFEXFBFLog:setTexto(STR0466 + cValToChar(nPcCofins) + CRLF) //"      Alíquota Cofins "
			oGFEXFBFLog:setTexto(STR0467 + cValToChar(nPcCofins) + "/100) X " + cValToChar(aRetPisCof * nBasePISCOF) + " = " + AllTrim(STR(nVlCofins)) + CRLF) //"      Valor de Cofins -> ("

			// Tratar truncamento/arredondamento do valor do imposto
			nVlCofins := GFETratDec(nVlCofins,6,.T.)

			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLCOFI", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLCOFI") + nVlCofins)
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLPIS" , GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"VLPIS") + nVLPIS)
			GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BAPICO", GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"BAPICO") + aRetPisCof * nBasePISCOF)
		EndIf

	EndIf // Existe trecho da unidade de calculo

Return

Function GFEXFBMCI(cMsg)
	Local nI   := 0
	Local aAux := Nil
	Local aMsg := StrTokArr(cMsg, (Chr(13) + Chr(10)))
	
	Local cErpCfg := SuperGetMv("MV_ERPGFE",.F.,"2")

	If cErpCfg == "1" .And. MsgYesNo("Deseja criar os cadastros genéricos Cliente, Fornecedor e Produto para uso no GFE?")// Somente gera cadastro para integração ativa com ERP Datasul
		If !Empty(aMsg) .And. "SUCESSO" $ Upper(aMsg[1])
			// Perfil de Participantes: TPPXXX - Precisa ter os cadastros de cliente/fornecedor que serão enviado para as funções fiscais executarem o calculo dos tributos.
			/*cAliasGU7 := GetNextAlias()
	
			cQuery := "SELECT GU7.R_E_C_N_O_ AS RECNUM"
			cQuery += " FROM " + RetSqlName("GU7") + " GU7"
			cQuery += " WHERE GU7.GU7_FILIAL = ?"
			cQuery += " AND GU7.GU7_SIT = '1'"
			cQuery += "	AND GU7.D_E_L_E_T_ = ''"

			cQuery := ChangeQuery(cQuery)
			oQry := FWExecStatement():New(cQuery)

			oQry:SetString(1, xFilial("GU7"))

			cAliasGU7 := oQry:OpenAlias()
			If (cAliasGU7)->(!EoF())
				While (cAliasGU7)->(!EoF())
					GU7->(dbGoTo((cAliasGU7)->RECNUM))

					GFEFBMCLI() // Criando cadastros de clientes
					
					GFEFBMFOR() // Criando cadatros de Fornecedores
				EndDo
			EndIf
			(cAliasGU7)->(dbCloseArea())*/

			For nI := 1 To Len(aMsg)
				aAux := StrTokArr(aMsg[nI], ":")
				If "Perfil de Participante" $ aAux[1]
					GFEFBMCLI("CLIGFE") // Criando cadastros de clientes

					GFEFBMFOR("FORGFE") // Criando cadastros de fornecedor

				ElseIf "Perfil de Produto" $ aAux[1]
					GFEFBMPROD("PRODGFE01")
				EndIf
			Next
		//Else
			//MsgInfo("Não foram gerados cadastros para de carga do configurador de tributos!","Aviso")
		EndIf
	EndIf
Return

Static Function GFEFBMCLI(cCodPart)
	Local cCodNatur := "NATGFE1"
	Local aMsgErr   := Nil
	Local aCab		:= {}
	Local nOper     := MODEL_OPERATION_INSERT
	Local oModel    := FwLoadModel ("CRMA980")
	Local cCodMun   := iif(!Empty(cCodPart), "50308", SubStr(Alltrim(GU7->GU7_NRCID),3,5))
	Local cNomeMun  := iif(!Empty(cCodPart), "SAO PAULO", Alltrim(GU7->GU7_NMCID))
	Local cCodUF    := iif(!Empty(cCodPart), "SP", Alltrim(GU7->GU7_CDUF))
	
	Private lMsErroAuto := .F.

	cCodPart := iif(!Empty(cCodPart), cCodPart, SubStr(Alltrim(GU7->GU7_NRCID),3,5))

	ChkFile("SED")
	ChkFile("SA1")

	// Incluindo Natureza Financiera generica necessaria para integração do cliente com o gfe
	SED->( DbSetOrder( 1 ) )
	If !SED->( DbSeek( xFilial( "SED" ) + cCodNatur ) )
		Aadd(aCab,{"ED_FILIAL" , xFilial("SED")		  , Nil})
		Aadd(aCab,{"ED_CODIGO" , cCodNatur   		  , Nil })
		Aadd(aCab,{"ED_DESCRIC", "Nat. Generica GFE 1", Nil})
		Aadd(aCab,{"ED_TIPO"   , "1"				  , Nil})
		Aadd(aCab,{"ED_COND"   , "D"				  , Nil})
		Aadd(aCab,{"ED_MSBLQL" , "2"				  , Nil})

		MSExecAuto({|x, y| FINA010(x, y)}, aCab, 3)
	EndIf

	dbSelectArea( "SA1" )
	SA1->( dbSetOrder(1) )
	If !SA1->( dbSeek( xFilial("SA1") + iif(!Empty(cCodPart), cCodPart, SubStr(Alltrim(GU7->GU7_NRCID),3,5)) + "99") )
		oModel:SetOperation(nOper)
		oModel:Activate()
		oModel:LoadValue("SA1MASTER", "A1_COD"    , cCodPart)
		oModel:LoadValue("SA1MASTER", "A1_LOJA"   , "99")
		oModel:SetValue("SA1MASTER" , "A1_NOME"   , "CLIENTE GFE " + cCodPart)
		oModel:SetValue("SA1MASTER" , "A1_NREDUZ" , iif(!Empty(cCodPart), "CLIE GFE "+cCodPart, Alltrim(GU7->GU7_NMCID)))
		oModel:SetValue("SA1MASTER" , "A1_CGC"    , "40855434000198")
		oModel:SetValue("SA1MASTER" , "A1_NATUREZ", cCodNatur)
		oModel:SetValue("SA1MASTER" , "A1_END"    , "ENDEREÇO PRINCIPAL")
		oModel:SetValue("SA1MASTER" , "A1_PESSOA" , "J")
		oModel:SetValue("SA1MASTER" , "A1_TIPO"   , "F")
		oModel:SetValue("SA1MASTER" , "A1_EST"    , cCodUF)
		oModel:LoadValue("SA1MASTER", "A1_COD_MUN", cCodMun)
		oModel:LoadValue("SA1MASTER", "A1_MUN"    , cNomeMun)

		If oModel:VldData()
			oModel:CommitData()
		//Else
			//aMsgErr := oModel:GetErrorMessage()
			//MsgInfo( AllToChar(aMsgErr[6]) + CRLF + AllToChar(aMsgErr[7]) + CRLF + CRLF + "Campo: " + AllToChar(aMsgErr[2]) + CRLF + "Valor: " + AllToChar(aMsgErr[9]))
		EndIf
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL
Return

Static Function GFEFBMFOR(cCodPart)
	Local aMsgErr:= Nil
	Local nOper  := MODEL_OPERATION_INSERT
	Local oModel := FwLoadModel ("MATA020")
	Local cCodMun  := iif(!Empty(cCodPart), "50308", SubStr(Alltrim(GU7->GU7_NRCID),3,5))
	Local cNomeMun := iif(!Empty(cCodPart), "SAO PAULO", Alltrim(GU7->GU7_NMCID))
	Local cCodUF   := iif(!Empty(cCodPart), "SP", Alltrim(GU7->GU7_CDUF))

	cCodPart := iif(!Empty(cCodPart), cCodPart, SubStr(Alltrim(GU7->GU7_NRCID),3,5))

	ChkFile("SA2")

	dbSelectArea( "SA2" )
	SA2->( dbSetOrder(1) )
	If !SA2->( dbSeek( xFilial("SA2") + iif(!Empty(cCodPart), cCodPart, SubStr(Alltrim(GU7->GU7_NRCID),3,5)) + "99") )
		oModel:SetOperation(nOper)
		oModel:Activate()
		oModel:LoadValue("SA2MASTER", "A2_COD"    , cCodPart)
		oModel:LoadValue("SA2MASTER", "A2_LOJA"   , "99")
		oModel:SetValue("SA2MASTER" , "A2_NOME"   , "FORNECEDOR GFE " + iif(!Empty(cCodPart), cCodPart, Alltrim(GU7->GU7_NMCID)))
		oModel:SetValue("SA2MASTER" , "A2_NREDUZ" , iif(!Empty(cCodPart), "FORN GFE "+cCodPart, Alltrim(GU7->GU7_NMCID)))
		oModel:SetValue("SA2MASTER" , "A2_CGC"    , "40855434000198")
		oModel:SetValue("SA2MASTER" , "A2_END"    , "ENDEREÇO PRINCIPAL")
		oModel:SetValue("SA2MASTER" , "A2_TIPO"   , "F")
		oModel:SetValue("SA2MASTER" , "A2_EST"    , cCodUF)
		oModel:SetValue("SA2MASTER" , "A2_COD_MUN", cCodMun)
		oModel:SetValue("SA2MASTER" , "A2_MUN"    , cNomeMun)

		If oModel:VldData()
			oModel:CommitData()
		//Else
			//aMsgErr := oModel:GetErrorMessage()
			//MsgInfo( AllToChar(aMsgErr[6]) + CRLF + AllToChar(aMsgErr[7]) + CRLF + CRLF + "Campo: " + AllToChar(aMsgErr[2]) + CRLF + "Valor: " + AllToChar(aMsgErr[9]))
		EndIf
	EndIf

	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL
Return

Static Function GFEFBMPROD(cCodProd)
	Local aMsgErr:= Nil
	Local oModel := FwLoadModel ("MATA010")
	
	ChkFile("NNR")
	ChkFile("SB1")

	dbSelectArea( "SB1" )
	SB1->( dbSetOrder(1) )
	If !SB1->( dbSeek(xFilial("SB1") + cCodProd) )
		If !(NNR->(dbSeek(xFilial("NNR") + "99")))		// Faz inclusão de armazem padrão 99 para o produto
			RecLock("NNR",.T.)
			NNR->NNR_FILIAL	:= xFilial("NNR")
			NNR->NNR_CODIGO	:= "99"
			NNR->NNR_TIPO	:= "1"
			NNR->NNR_DESCRI	:= "Armazém Padrão"
			MsUnlock()
		EndIf

		oModel:SetOperation(MODEL_OPERATION_INSERT)
		oModel:Activate()
		oModel:SetValue("SB1MASTER", "B1_COD"    , Alltrim(cCodProd))
		oModel:SetValue("SB1MASTER", "B1_DESC"   , "PRODUTO FRETE GFE")
		oModel:SetValue("SB1MASTER", "B1_TIPO"   , "ME")
		oModel:SetValue("SB1MASTER", "B1_UM"     , "UN")
		oModel:SetValue("SB1MASTER", "B1_LOCPAD" , "99")
		oModel:SetValue("SB1MASTER", "B1_LOCALIZ", "N")
		
		If oModel:VldData()
			oModel:CommitData()

			If Empty(SuperGetMv("MV_PRITDF",.F.,""))
				PutMV("MV_PRITDF", Alltrim(cCodProd))
			EndIf
		//Else
			//aMsgErr := oModel:GetErrorMessage()
			//MsgInfo( "Cadastro de Produto!" + CRLF + AllToChar(aMsgErr[6]) + CRLF + AllToChar(aMsgErr[7]) + CRLF + CRLF + "Campo: " + AllToChar(aMsgErr[2]) + CRLF + "Valor: " + AllToChar(aMsgErr[9]))
		EndIf
	EndIf
		
	oModel:DeActivate()
	oModel:Destroy()
	oModel := NIL
Return Nil

