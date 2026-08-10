#INCLUDE "GFEXFUNB.ch"
#include 'protheus.ch'

// Identificadores   dos elementos do array aCompCalc, usado em vários pontos da rotina
#DEFINE _CDCOMP 1 // Codigo do  componente
#DEFINE _CATVAL 2 // Categoria do componente
#DEFINE _VALOR  3 // Valor do componente
#DEFINE _QTDE   4 // Quantidade usada para calculo
#DEFINE _TOTFRE 5 // Indica se o componente soma no total do frete
#DEFINE _BASIMP 6 // Indica se o componente soma na base de calculo do ICMS/ISS
#DEFINE _BAPICO 7 // Indica se o componente soma na base de calculo do PIS/COFINS
#DEFINE _FREMIN 8 // Indica se o componente soma no valor usado para comparação com o frete mínimo
#DEFINE _NRCALC 9 // Numero da unidade de calculo
#DEFINE _VALOR_TOTAL 11 // Valor total, aplicável à taxa

Static lPEXFB02	:= ExistBlock("GFEXFB02")

Static s_TREENTR 	:= SuperGetMv('MV_TREENTR',.F.,"0")
Static s_UMPESO		:= SuperGetMv("MV_UMPESO",,"KG")

/*----------------------------------------------------------------------------
{Protheus.doc} GFECalcFrete
Calcula Frete.
Uso: GFECLCFRT

@sample GFECalcFrete()

@author Felipe Nathan Welter, Luiz Fernando Soares
@since 11/11/09
@version 1.0
----------------------------------------------------------------------------*/
Function GFECalcFrete()

	Local nX, nPos, nY, nX2 // Variavel de uso geral
	Local aComponentes // Array com os componentes de frete calculados
	Local aParamComp   // Array que resume os parametros dos componentes
	Local aTaxa        // Array criado para armazenar os componentes de fretes que são taxas
	Local aInfoTab	   // Array contendo as informações de vinculo de uma tabela de frete
	Local cCdTrpBase, cNrTabBase
	Local aValores := {}
	Local cTxtLogAux
	// Previsao de entrega
	Local dDtSaida, cHrSaida, aPreDataHR[2]
	// Frete mínimo por entrega
	Local nVlFretMin, nVlFrtM, nVlCompMin, nVlFrComMin, nVlFrtOutros
	Local aNegMin	   // Array com os dados da negociacao selecionada para tratar o frete minimo
	// Pedágio por romaneio
	Local aCompPed, cAtrComp, nQtdeCalc, nQtdeMin
	Local lPesPedIgual
	Local cPedRomAnt, cPesPedAnt
	Local cNrCalcAnt, nVlMaiorPed
	Local nMaiorPerc, nPerc := 0, nRecMaior, nTotPed, nValCompRat := 0
	Local nQtde, nPesReal, nPesoCubado, nVolume, nVlMerc, nVlFrete, nVALLIQ
	local nVlFrMinT    //       Valor do frete Minimo da tarifa
	Local nQtdPesAlt
	Local lPedRomNeg := .T.
	Local aValCalc	   // Array contendo os valores acumulados por calculo, de peso, valor mercadoria, quantidade e volume
	// Frete Minimo por Romaneio
	Local lFreMinIgual, cFreMinAnt, lTpFreMinIgual, cTpFreMin, cTpFreMinAnt
	Local aFreteSemMin, nMaiorQtMin, nQtCalcRom, nMaiorFrtComMin
	Local aMaiorTarifa := Array(17)
	Local nTotFrtSemMin, lCompFreRom, cCompFrGar
	Local nFrtVlFret, nTotVlFrt, nVlFrtFx, nQtEntregas, nMul, nAdc, nQtdComp
	// Frete Viagem
	Local cFreVia, cTipVal, cQtdCal
	Local lFreViaIgual, lTipValIgual, lQtdCalIgual
	Local cFreViaAnt, cTipValAnt, cQtdCalAnt
	Local cNrCalcSel
	Local cCalcDtPrev	:= "" // Tipo do cálculo de Previsão de Entrega. 0=
	Local aCompMaior    //Armazena os valores dos componentes de frete viagem, com maior valor. Utilizado no rateio.
	Local nValCpt := 0       //Armazena os valores dos componentes de frete viagem, com maior valor, se forem encontrados no array aCompMaior
	// Diária por Romaneio
	Local aCompDia		// Contem os componentes de diária de cada cálculo. Estrutura igual à aTaxa
	Local aCompDiaTt    // Totaliza os valores do array aCompDia
	Local aValDiaria	// Contem os maiores valores dos componentes de diária em cada trecho. [1] - Trecho, [2] - Componente, [3] - Valor
	Local aTotCalc		// Totaliza os valores do cálculo : [1] Nr. unid. calc., [2] Qtde. itens, [3] Valor merc., [4] Peso real, [5] Peso cub., [6] Vol. merc.
	Local aTotTre		// Totaliza os valores do trecho  : [1] Seq. Trecho, [2] Qtde. itens, [3] Valor merc., [4] Peso real, [5] Peso cub., [6] Vol. merc., [7] Qtde. calculos
	Local nPosCalc := 0 // Variável auxiliar com a posição do cálculo no array
	Local nPosTre		// Variável auxiliar com a posição do trecho no array
	Local aTabPrazo[14]		// Valores para o cálculo da data de previsão pela tabela de prazos
	Local aRetTabPrazo[6]	// Retorno da data de previsão pela tabela de prazos
	Local cIDVLAG   := "1"
	Local cCEPO := ""
	Local cTotFre
	Local cBASIMP
	Local cBAPICO
	Local cFREMIN
	Local cNrRom
	Local cCriRat := GetNewPar("MV_CRIRAT", "1")
	Local cAlBkp
	Local aCompSem
	Local aCdClFr := {Space(Len(GWI->GWI_CDCLFR)),Space(Len(GWI->GWI_CDTPOP))}
	Local nVlrCpo := 0
	Local lTrpTrecho := .F.
	Local lClcCfgTrb := SuperGetMv("MV_GFECLCT",.F.,.F.)

	// Indica se os valores por romaneio serão aplicados
	// No caso de simulação geral (iTipoSim == 0) os valores por romaneio não são aplicados,
	// pois a rotina considera que todas as situações geradas pela simulação fazem parte de
	// um mesmo romaneio, o que não é verdade
	Local lAplicValRom := .T.	// !(lSimulacao .AND. iTipoSim == 0) - Removido negação sobre simulação devido necessidade de calcular valores sobre romaneio em simulações
	Local lAplicViag   := .T.

	Local aDBFAgr
	Local aDBFDoc
	Local aDBFGru
	Local aDBFUnc
	Local aDBFTcf
	Local aDBFTre
	Local aDBFIte
	Local aDBFCCF
	Local aDBFENT
	Local cGWF_TPTar:= " "
	Local cGWF_TPPra:= " "
	Local aValFV  := {}
	Local aAreaCCF
	Local cTpLocEntr := s_TREENTR
	Local aCpMinClFr := {} // Array contendo os componentes mínimos aplicados por classificação de frete
	Local lRatClass := ( AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) $ "1S" .Or. AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) == ".T." )
	Local cCEPD
	Local nVlrPed := 0
	Local oGFETempTable	:= GFEXFBTempTable():New()

	Local aNrCalSel := {}
	Local aValTot	:= {}
	Local nPosMaior := 0
	Local cCdComp := ""
	Local cUnidCalc := ""
	Local aCount := {}
	
	Local aValMaior[2]

	Local cNrNeg    := ""
	Local cAliasGUC := Nil
	Local nPosRat	:= 0
	Local nPosCUn	:= 0

	Local aUnidProc	:= {}

	Local lPerc	  	:= .F.
	Local nPercOrig := 0
	
	Private lPEXFB13	:= ExistBlock("GFEXFB13")
	Private lPEXFB19	:= ExistBlock("GFEXFB19") 
	Private aDocAux		:= {}

	Default pdtCalcPed 	:= STOD("")	

	oGFETempTable:ClearData()
	oGFETempTable:setAgrupadoresCarga()
	aDBFAgr := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setDocumentoCarga()
	aDBFDoc := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setGrupoEntrega()
	aDBFGru := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setUnidadeCalculo()
	aDBFUnc := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setTabelaCalculoFrete()
	aDBFTcf := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setTrechoCarga()
	aDBFTre := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setItensCarga()
	aDBFIte := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setComponenteCalculoFrete()
	aDBFCCF := oGFETempTable:getTableStruct()

	oGFETempTable:ClearData()
	oGFETempTable:setLocalUnidadeCalculo()
	aDBFENT := oGFETempTable:getTableStruct()

	If !Empty(oGFETempTable)
		oGFETempTable:= Nil
	EndIf

	If cTpLocEntr != "1"
		cTpLocEntr := ""
	EndIf

	nQtde := nVlFretMin := nVlCompMin := nX := 0
	aTaxa        := {}
	aNegMin      := {}
	aComponentes := {}
	aValCalc     := {}
	aFreteSemMin := {}

	// TABELA TEMPORARIA DE VALORES PARA CALCULO DO PEDAGIO POR ROMANEIO
	If !lTabTemp
		aTRBPED := {}
		CTRBPED := ''
	EndIf

	//oGFEXFBFLog:setTexto(CRLF + STR0100 + CRLF)           //"4. Calculando Valores de Frete..."
	oGFEXFBFLog:setTexto(CRLF + STR0100 + CRLF)           //"4. Calculando Valores de Frete..."
	If !IsBlind() .AND. lHideProcess == .F.
		oProcess:setRegua2(Len(aAgrFrt))
	EndIf

	// Para cada agrupador
	GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
	GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
	While !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
		If GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO") != "0" .and. GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"ERRO") != "" //If (cTRBAGRU)->ERRO != "0" .and. (cTRBAGRU)->ERRO != ""
			GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
			Loop
		EndIf
		If !IsBlind() .AND. lHideProcess == .F.
			oProcess:incRegua2(OemToAnsi(STR0101+AllTrim(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")))) //"Agrupador "
		EndIf
		// Inicializa as variaveis do cálculo do pedágio para este agrupador
		lPesPedIgual := .T.
		cPedRomAnt   := cPesPedAnt   := ""
		aParamComp   := {}
		aCompMaior   := {}
		aCompPed     := {}
		aCompDia     := {}
		aCompDiaTt   := {}
		nVlFrMinT    := 0  //       Valor do frete Minimo da tarifa
		nVlFrMinTMai := 0  // Maior Valor do frete Minimo da tarifa

		// Inicializa as variáveis de frete mínimo por romaneio
		lFreMinIgual := lTpFreMinIgual := .T.
		cFreMinAnt   := cTpFreMinAnt   := ""
		lCompFreRom  := .T.
		nMaiorQtMin  := 0
		nQtCalcRom   := 0

		// Inicializa as variáveis de frete viagem
		lFreViaIgual := lTipValIgual := lQtdCalIgual := lAplicViag := .T.
		cFreViaAnt   := cTipValAnt   := cQtdCalAnt   := ""

		// Para cada unidade de calculo relacionada ao agrupador
		GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
		GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
		While  !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. ;
				GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

			aTaxa := {}
			aCpMinClFr := {}

			// Ajusta os trechos do calculo base, vinculando-os temporariamente ao calculo corrente
			If lSimulacao .AND. iTipoSim == 0
				GFEAjusTre(.T.)	// .T. - Vincula o trecho ao cálculo simulado corrente, .F. - Retorna o trecho ao calculo original
			EndIf

			// Verifica as tabelas do calculo de frete
			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

			While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

				oGFEXFBFLog:setTexto(CRLF + STR0102 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + STR0054 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0055 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF + CRLF) //"  # Processando Unid.Cálculo "###"; Class.Frete "###"; Tp.Oper. "

				// Retorna informações de vinculo da tabela de frete
				aInfoTab   := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))
				cCdTrpBase := aInfoTab[2]
				cNrTabBase := aInfoTab[3]

				cTpLota    := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_TPLOTA")
				cAtrFai    := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_ATRFAI")
				cUniFai    := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_UNIFAI")
				cUniCal    := Posicione("GV7",1,xFilial("GV7")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),"GV7_UNICAL")
				nQtdeMin   := Posicione("GV6",1,xFilial("GV6")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),"GV6_QTMIN")
				cCalcDtPrev:= Posicione("GV6",1,xFilial("GV6")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),"GV6_CONSPZ")
				cCompFrGar := Posicione("GV6",1,xFilial("GV6")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),"GV6_COMFRG")

				// Frete Viagem
				cFreVia := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_FREVIA") // Frete Viagem > 1=Sim; 2=Nao
				cTipVal := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_TIPVAL") //Tipo Valor Frete Viagem > 1=Maior calculo; 2=Maior tarifa
				cQtdCal := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_QTDCAL") //Qtde Calculo Frete Viag. > 1=Um por romaneio; 2=Um por entrega

				/************************************************/
				/*****  INI FRETE MINIMO POR ROMANEIO       *****/
				/************************************************/
				// Verifica se todas as tabelas utilizam frete minimo por romaneio
				If Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_FREROM") != cFreMinAnt .AND. cFreMinAnt != ""
					lFreMinIgual := .F.
				EndIf
				cFreMinAnt := Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_FREROM")

				lUtlFrMin := !(lFreMinIgual .AND. (cFreMinAnt == '1'))

				// Verifica a quantidade mínima da tarifa, salvando a maior
				nMaiorQtMin := MAX(nQtdeMin, nMaiorQtMin)

				nVlFrMinT    := Posicione("GV6",1,xFilial("GV6")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),"GV6_FRMIN")
				if nVlFrMinT > nVlFrMinTMai
					nVlFrMinTMai := nVlFrMinT
				EndIf
				// Verifica o tipo de frete minimo por romaneio
				If nQtdeMin   > 0 .And. nVlFrMinT == 0 .And. Empty(cCompFrGar)	// Componente Frete Garantia
					cTpFreMin := "2"	// 2-Quantidade
				Else
					cTpFreMin := "1" 	// 1-Valor
				EndIf

				If cTpFreMin != cTpFreMinAnt .AND. cTpFreMinAnt != ""
					lTpFreMinIgual := .F.
				EndIf
				cTpFreMinAnt := cTpFreMin

				/************************************************/
				/*****  FIM FRETE MINIMO POR ROMANEIO       *****/
				/************************************************/

				GVA->(dbSetOrder(01))
				GVA->(dbSeek(xFilial("GVA")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB")))

				/************************************************/
				/*****      CALCULO DOS COMPONENTES         *****/
				/************************************************/
				if GFEXFBUAT()
					// Calcula os componentes de frete usando os dados do array aTabelaFrt
					aComponentes := GFECalcTabInf(	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),; // Unidade de calculo
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),; // Classificacao de frete
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),; // Tipo de operacao
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),; // Quantidade para calculo
					@nVlFretMin, lUtlFrMin)		  // Valor do frete minimo, que sera atualizado pela função
				Else
					aComponentes := GFECalcComp(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),; // Unidade de calculo
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	// Classificacao de frete
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;	// Tipo de operacao
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;	// Código do transportador
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"),;	// Numero da tabela
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),;	// Numero da negociacao
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;	// Codigo da faixa/tipo de veiculo
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;	// Numero da rota
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;	// Código do tipo de veiculo
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),; // Quantidade para calculo
												@nVlFretMin,;		// Valor do frete minimo, que sera atualizado pela função
												@aNegMin,;           // Contem a negociacao para tratar frete minimo, será atualizada pela função
												,,;
													lUtlFrMin) 			// Verificar se está sendo utilizado Frete "Mínimo por Romaneio"
				EndIf

				If GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
					Loop
				EndIf

				/************************************************/
				/*****         PEDAGIO POR ROMANEIO         *****/
				/************************************************/
				// Atribui a forma de cálculo do pedágio usada na negociacao
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PEDROM",Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_PEDROM"))
				GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESPED",Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_PESPED"))

				// Considera apenas cálculos do transportador do romaneio
				If GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

					// Identifica se uma das negociacoes usadas considera peso para pedagio de forma diferente das demais
					If GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESPED") != cPesPedAnt .AND. cPesPedAnt != ""
						lPesPedIgual := .F.
					EndIf

					cPedRomAnt := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PEDROM")
					cPesPedAnt := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESPED")

					// Acumular valores para o cálculo do pedágio por romaneio
					if lTabTemp
						RecLock(cTRBPED,.T.)
						(cTRBPED)->NRCALC  := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
						(cTRBPED)->CDCLFR  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
						(cTRBPED)->CDTPOP  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
						(cTRBPED)->CDTRP   := cCdTrpBase
						(cTRBPED)->NRTAB   := cNrTabBase
						(cTRBPED)->NRNEG   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")
						(cTRBPED)->TPLOTA  := cTpLota
						(cTRBPED)->CDFXTV  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")
						(cTRBPED)->CDTPVC  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC")
						(cTRBPED)->ATRFAI  := cAtrFai
						(cTRBPED)->UNIFAI  := cUniFai
						(cTRBPED)->UNICAL  := cUniCal
						(cTRBPED)->NRROTA  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")
						(cTRBPED)->QTDE    := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
						(cTRBPED)->PESOR   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
						(cTRBPED)->PESCUB  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
						(cTRBPED)->QTDALT  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT")
						(cTRBPED)->VALOR   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
						(cTRBPED)->VOLUME  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
						(cTRBPED)->QTCALC  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC")
						(cTRBPED)->VALLIQ   := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ")
						(cTRBPED)->(MsUnLock())
					Else
						aAdd(aTRBPED,{	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
							cCdTrpBase,;
							cNrTabBase,;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),;
							cTpLota,;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;
							cAtrFai,;
							cUniFai,;
							cUniCal,;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
							0,;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),;
							Space(20),;
							GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ;
							})
					EndIf
				EndIf

				/************************************************/
				/*****             FRETE VIAGEM             *****/
				/************************************************/
				// Considerar somente o trecho do transportador do romaneio
				If GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))  .And.;
						GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") == "01"

					If cFreVia != cFreViaAnt .AND. cFreViaAnt != ""
						lFreViaIgual := .F.
					EndIf
					cFreViaAnt := cFreVia

					If cTipVal != cTipValAnt .AND. cTipValAnt != ""
						lTipValIgual := .F.
					EndIf
					cTipValAnt := cTipVal

					If cQtdCal != cQtdCalAnt .AND. cQtdCalAnt != ""
						lQtdCalIgual := .F.
					EndIf
					cQtdCalAnt := cQtdCal
				EndIf

				/************************************************/
				/*****       GRAVACAO DOS COMPONENTES       *****/
				/************************************************/
				For nX := 1 to len(aComponentes)

					// Gravar os componentes calculados
					if lTabTemp
						RecLock(cTRBCCF,.T.)
						(cTRBCCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
						(cTRBCCF)->CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
						(cTRBCCF)->CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
						(cTRBCCF)->SEQ    := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ")
						(cTRBCCF)->CDCOMP := aComponentes[nX,_CDCOMP]
						(cTRBCCF)->CATVAL := aComponentes[nX,_CATVAL]
						(cTRBCCF)->VALOR  := aComponentes[nX,_VALOR]
						(cTRBCCF)->QTDE   := aComponentes[nX,_QTDE]
						(cTRBCCF)->TOTFRE := aComponentes[nX,_TOTFRE]
						(cTRBCCF)->BASIMP := aComponentes[nX,_BASIMP]
						(cTRBCCF)->BAPICO := aComponentes[nX,_BAPICO]
						(cTRBCCF)->FREMIN := aComponentes[nX,_FREMIN]
						(cTRBCCF)->IDMIN  := "2"
						(cTRBCCF)->CPEMIT := aComponentes[nX,9]
						(cTRBCCF)->(MsUnLock())
					Else
						aAdd(aTRBCCF1,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
										aComponentes[nX,_CDCOMP],;
										aComponentes[nX,_CATVAL],;
										aComponentes[nX,_QTDE],;
										aComponentes[nX,_VALOR],;
										aComponentes[nX,_TOTFRE],;
										aComponentes[nX,_BASIMP],;
										aComponentes[nX,_BAPICO],;
										aComponentes[nX,_FREMIN],;
										"2",;
										0,;
										"0",;
										Space(6),;
										aComponentes[nX,9]})
					EndIf

					// Obter o componente de pedagio. Será usado posteriormente no cálculo do pedágio por romaneio
					If aComponentes[nX,_CATVAL] == "4" .AND. GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))
						GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
						GFEXFB_IBOTTOM(lTabTemp, cTRBPED, @aTRBPED, 10)
						GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP",aComponentes[nX,_CDCOMP])

						// Guarda o componente para utilizar no rateio do pedagio por romaneio
						If Empty(aCompPed)
							aCompPed := aComponentes[nX]
						EndIf
					EndIf

					// Quando Frete Mínimo por Romaneio, todos os componentes da negociação devem ser considerados no frete mínimo.
					// Exceção: componente usado para frete garantia
					If Posicione("GV9",1,xFilial("GV9")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),"GV9_FREROM") == "1" .AND. ;
							aComponentes[nX,_FREMIN] == "2" .AND.;
							aComponentes[nX,_CDCOMP] != cCompFrGar
						lCompFreRom := .F.
					EndIf

					// Adiciona o componente no array de parametros, prevalecendo os parametros ativos
					GFEParamComp({	aComponentes[nX,_CDCOMP], ;
						aComponentes[nX,_TOTFRE], ;
						aComponentes[nX,_BASIMP], ;
						aComponentes[nX,_BAPICO], ;
						aComponentes[nX,_FREMIN], ;
						GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")},@aParamComp)

				Next nX

				if !lTabTemp
					aTRBCCF2 := aClone(aTRBCCF1)
					aTRBCCF3 := aClone(aTRBCCF1)
					aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
					aSort(aTRBCCF2  ,,,{|x,y| x[01]+x[05]                  < y[01]+y[05]})
					aSort(aTRBCCF3  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
				EndIf

				/************************************************/
				/*****Busca a data\hora prevista de entrega *****/
				/************************************************/
				cCEPD := ""
				GWN->(dbSetOrder(01) )
				If GWN->(dbSeek(xFilial("GWN")+GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU")) )
					If GFEVerCmpo({"GWN_CEPO"}) .And. Empty(cCEPO)
						cCEPO := GWN->GWN_CEPO
					EndIf
					If !Empty(GWN->GWN_DTSAI) .and. !Empty(GWN->GWN_HRSAI)
						dDtSaida := GWN->GWN_DTSAI
						cHrSaida := GWN->GWN_HRSAI
					Else
						dDtSaida := DDatabase
						cHrSaida := TIME()
					EndIf
				Else
					dDtSaida := DDatabase
					cHrSaida := TIME()
				EndIf

				If !Empty(pdtCalcPed)
					dDtSaida := pdtCalcPed
				Endif

				If Empty(cCEPO)
					If GFXCP12117("GWU_NRCIDO")
						GWU->(dbSetOrder(1) )
						If GWU->(dbSeek(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CHVGWU")) )
							cCEPO := GWU->GWU_CEPO
							cCEPD := GWU->GWU_CEPD
						EndIf
					EndIf
				EndIf

				aTabPrazo[1] := ""
				aTabPrazo[2] := ""
				aTabPrazo[3] := ""
				aTabPrazo[4] := ""
				aTabPrazo[5] := ""
				aTabPrazo[6] := ""
				aTabPrazo[7] := ""
				aTabPrazo[8] := ""
				aTabPrazo[9] := ""
				aTabPrazo[10] := ""
				aTabPrazo[11] := .F.
				aTabPrazo[12] := ""
				aTabPrazo[13] := ""
				aTabPrazo[14] := ""

				// Data Previsão - Tabela de Prazos
				If cCalcDtPrev == "0"
					oGFEXFBFLog:setTexto("    # Data Previsão calculada pela Tabela de Prazos." + CRLF)
					oGFEXFBFLog:SaveLog()
					GV8->(dbSetOrder(1))
					If GV8->(dbSeek(xFilial("GV8") + cCdTrpBase + cNrTabBase + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")))
						If lSimulacao
							cNrNeg := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")						
							aTabPrazo[7] := GFEGetTPOP(cNrTabBase,cNrNeg,cCdTrpBase)
							aTabPrazo[8] := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CDTPVC")

							//Posiciona na tabela de grupos de entrega
							GFEXFB_BORDER(.F.,,03,4)
							If GFEXFB_CSEEK(.F.,, @aTRBGRB1, 4,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRGRUP")})
								GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
								If GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCarg, 1,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"), ;
										GFEXFB_5CMP(.F.     ,         , @aTRBGRB1, 4,"CDTPDC"), ;
										GFEXFB_5CMP(.F.     ,         , @aTRBGRB1, 4,"EMISDC"), ;
										GFEXFB_5CMP(.F.     ,         , @aTRBGRB1, 4,"SERDC" ) , ;
										GFEXFB_5CMP(.F.     ,         , @aTRBGRB1, 4,"NRDC"  )})
									aTabPrazo[1]:= GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDREM")
									aTabPrazo[2]:= GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"CDDEST")
								EndIf
								GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7)
								if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE2, 7,{GFEXFB_5CMP(.F.     ,        , @aTRBGRB1, 4,"CDTPDC"	), ;
										GFEXFB_5CMP(.F.     ,        , @aTRBGRB1, 4,"EMISDC"	), ;
										GFEXFB_5CMP(.F.     ,        , @aTRBGRB1, 4,"SERDC"	), ;
										GFEXFB_5CMP(.F.     ,        , @aTRBGRB1, 4,"NRDC"	), ;
										GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
									aTabPrazo[3] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"ORIGEM")
									aTabPrazo[4] := GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE2, 7,"DESTIN")
									aTabPrazo[5] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")
									aTabPrazo[6] := POSICIONE("GU3", 1, xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), "GU3_CDGRGL")
									aTabPrazo[9] := POSICIONE("GU3", 1, xFilial("GU3") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), "GU3_MODAL")
								EndIf
							EndIf
						Else
							GWU->(dbSetOrder(1))
							If GWU->(dbSeek(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CHVGWU")))
								aTabPrazo := GFEPrazoTre(GWU->GWU_FILIAL, GWU->GWU_CDTPDC, GWU->GWU_EMISDC, GWU->GWU_SERDC, GWU->GWU_NRDC, GWU->GWU_SEQ)
								If aTabPrazo[11] == .F.
									oGFEXFBFLog:setTexto("    *** Erro ao carregar dados da rota. Motivo: " + aTabPrazo[12] + CRLF)
									oGFEXFBFLog:SaveLog()
								EndIf
							Else
								oGFEXFBFLog:setTexto("    *** Rota não encontrada. Chave: " + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CHVGWU") + CRLF)
								oGFEXFBFLog:SaveLog()
							EndIf

							aTabPrazo[7]	:= GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")	// Tipo Operação

							// Se o tipo de veículo não for informado no trecho, busca do Romaneio
							If Empty(aTabPrazo[8])
								aTabPrazo[8]	:= GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC")	// Tipo Veículo
							EndIf
						EndIf

						// Classificação de Frete
						aTabPrazo[10] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")

						//////// CEP DE/ORIGEM ////////
						aTabPrazo[13] := cCEPO
						If Empty(aTabPrazo[13])
							aTabPrazo[13] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[1],"GU3_CEP")
						EndIf
						//////// CEP DE/ORIGEM ////////

						//////// CEP PARA/DESTINO ////////
						If !Empty(cCEPD)
							aTabPrazo[14] := cCEPD
						ElseIf !Empty(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CEPD"))
							aTabPrazo[14] := GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"CEPD")
						ElseIf !Empty(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTCEP"))
							aTabPrazo[14] := GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"ENTCEP")
						Else
							aTabPrazo[14] := Posicione("GU3",1,xFilial("GU3")+aTabPrazo[2],"GU3_CEP")
						EndIf
						//////// CEP PARA/DESTINO ////////

						oGFEXFBFLog:setTexto("      Informações da rota: " + CRLF)
						oGFEXFBFLog:setTexto("        > Remetente.....: " + aTabPrazo[01] + CRLF)
						oGFEXFBFLog:setTexto("        > Destinatário..: " + aTabPrazo[02] + CRLF)
						oGFEXFBFLog:setTexto("        > Cidade Origem.: " + aTabPrazo[03] + CRLF)
						oGFEXFBFLog:setTexto("        > Cidade Destino: " + aTabPrazo[04] + CRLF)
						oGFEXFBFLog:setTexto("        > Transportador.: " + aTabPrazo[05] + CRLF)
						oGFEXFBFLog:setTexto("        > Grupo. Transp.: " + aTabPrazo[06] + CRLF)
						oGFEXFBFLog:setTexto("        > Tipo Operação.: " + aTabPrazo[07] + CRLF)
						oGFEXFBFLog:setTexto("        > Tipo Veículo..: " + aTabPrazo[08] + CRLF)
						oGFEXFBFLog:setTexto("        > Modal. Transp.: " + aTabPrazo[09] + CRLF)
						oGFEXFBFLog:setTexto("        > Class. Frete..: " + aTabPrazo[10] + CRLF)
						oGFEXFBFLog:setTexto("        > CEP Origem....: " + aTabPrazo[13] + CRLF)
						oGFEXFBFLog:setTexto("        > CEP Destino...: " + aTabPrazo[14] + CRLF)
						oGFEXFBFLog:SaveLog()

						If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") > "01"
							cGWF_TPPra := "06"	// Redespacho
						Else
							cGWF_TPPra := "01"	// Normal
						Endif

						// Calcula o prazo de entrega com a tabela de prazos de acordo com o critério de aTabPrazo
						If cGWF_TPPra == "01"
							aRetTabPrazo := GFETabPrazo(aTabPrazo, dDtSaida, cHrSaida)
						ElseIf cGWF_TPPra == "06" .and. (empty(aRetTabPrazo[1])) .and. (!empty(aPreDataHR[1]))
							aRetTabPrazo := GFETabPrazo(aTabPrazo, aPreDataHR[1], cHrSaida)
							aPreDataHR[1] := nil
						ElseIf cGWF_TPPra == "06" .and. (!empty(aRetTabPrazo[1]))
							aRetTabPrazo := GFETabPrazo(aTabPrazo, aRetTabPrazo[1], cHrSaida)
						Else
							aRetTabPrazo := GFETabPrazo(aTabPrazo, dDtSaida, cHrSaida)
						EndIf

						If aRetTabPrazo[5] == .F. .And. (aTabPrazo[5] <> cCdTrpBase)
							oGFEXFBFLog:setTexto("      Não foi possível encontrar tabela de prazos " + CRLF)
							oGFEXFBFLog:setTexto("      Alterando o transportador de vínculo (" + aTabPrazo[5] + ") para o transportador base (" + cCdTrpBase + ")" + CRLF)
							
							aTabPrazo[5] := cCdTrpBase
							aTabPrazo[6] := POSICIONE("GU3", 1, xFilial("GU3") + cCdTrpBase, "GU3_CDGRGL")
							aTabPrazo[9] := POSICIONE("GU3", 1, xFilial("GU3") + cCdTrpBase, "GU3_MODAL")

							oGFEXFBFLog:setTexto("      Realizando nova busca..." + CRLF)

							// Calcula o prazo de entrega com a tabela de prazos de acordo com o critério de aTabPrazo
							If cGWF_TPPra == "01"
								aRetTabPrazo := GFETabPrazo(aTabPrazo, dDtSaida, cHrSaida)
							ElseIf cGWF_TPPra == "06" .and. (empty(aRetTabPrazo[1])) .and. (!empty(aPreDataHR[1]))
								aRetTabPrazo := GFETabPrazo(aTabPrazo, aPreDataHR[1], cHrSaida)
								aPreDataHR[1] := nil
							ElseIf cGWF_TPPra == "06" .and. (!empty(aRetTabPrazo[1]))
								aRetTabPrazo := GFETabPrazo(aTabPrazo, aRetTabPrazo[1], cHrSaida)
							Else
								aRetTabPrazo := GFETabPrazo(aTabPrazo, dDtSaida, cHrSaida)
							EndIf
						EndIf

						If aRetTabPrazo[5] == .T.
							oGFEXFBFLog:setTexto("      Tabela de Prazos escolhida.: " + cValToChar(aRetTabPrazo[3]) + CRLF)
							If !Empty(aRetTabPrazo[6])
								oGFEXFBFLog:setTexto("      *** Warning: " + cValToChar(aRetTabPrazo[6]) + CRLF)
							EndIf

							oGFEXFBFLog:setTexto("        > Data de referência.........: " + cValToChar(dDtSaida) + CRLF)
							oGFEXFBFLog:setTexto("        > Hora de referência.........: " + cValToChar(cHrSaida) + CRLF)
							oGFEXFBFLog:setTexto("      Data de Previsão de Entrega: " + cValToChar(aRetTabPrazo[1]) + CRLF)
							oGFEXFBFLog:setTexto("      Hora de Previsão de Entrega: " + cValToChar(aRetTabPrazo[2]) + CRLF)

							GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN",aRetTabPrazo[1])
							GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"HRPREN",aRetTabPrazo[2])
						Else
							oGFEXFBFLog:setTexto("    *** Erro ao calcular data de previsão pela tabela de prazos. Motivo: " + aRetTabPrazo[6] + CRLF)
						EndIf
					EndIf
				EndIf

				// Data Previsão - Tarifa
				If cCalcDtPrev == "1"
					oGFEXFBFLog:setTexto("    # Data Previsão calculada pela Tarifa." + CRLF + CRLF)

					If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"SEQTRE") > "01"
						cGWF_TPTar := "06"	// Redespacho
					Else
						cGWF_TPTar := "01"	// Normal
					Endif

					If cGWF_TPTar == "01"
						aPreDataHR := PrevDtEnt(dDtSaida, cHrSaida, cCdTrpBase, cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"))
					elseif cGWF_TPTar == "06" .and. (empty(aPreDataHR[1])) .and. (!empty( aRetTabPrazo[1]))
						aPreDataHR := PrevDtEnt(aRetTabPrazo[1], cHrSaida, cCdTrpBase, cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"))
						aRetTabPrazo[1] := nil
					ElseIf cGWF_TPTar == "06" .and. (!empty(aPreDataHR[1]))
						aPreDataHR := PrevDtEnt(aPreDataHR[1], cHrSaida, cCdTrpBase, cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"))
					Else
						aPreDataHR := PrevDtEnt(dDtSaida, cHrSaida, cCdTrpBase, cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"))
					EndIf

					If aPreDataHR[3]
						// Deve gravar a data mais distante dentre as negociacoes
						If Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN")) .OR. ;
								GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN") < aPreDataHR[1] .OR. ;
								(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN") == aPreDataHR[1] .AND. ;
								GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"HRPREN") < aPreDataHR[2]) .Or. ;
								(aPreDataHR[1] < DDATABASE .And. ;
								GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN") == aPreDataHR[1] .AND. ;
								GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"HRPREN") < aPreDataHR[2] )
							oGFEXFBFLog:setTexto("    -> Data Previsão:" + cValToChar(aPreDataHR[1]) + CRLF)
							oGFEXFBFLog:setTexto("    -> Hora Previsão:" + cValToChar(aPreDataHR[2]) + CRLF)
							GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DTPREN",aPreDataHR[1])
							GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"HRPREN",aPreDataHR[2])
						EndIf
					Else
						oGFEXFBFLog:setTexto("    * * * ATENÇÃO Não foi possivel calcular a data da fatura corretamente pois não existe calendário cadastrado após " +cValToChar(aPreDataHR[1])+"."+  CRLF +"          Para que o cálculo da data da fatura seja feito usando dias úteis, como parametrizado na tabela de frete, por favor cadastre um calendário do transportador." +  CRLF)
					EndIf
				EndIf

				// Data Previsão - Não calcular
				If cCalcDtPrev == "2"
					oGFEXFBFLog:setTexto("    # Data Previsão parametrizada para não calcular." + CRLF)
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
			EndDo // Tabelas do cálculo de frete cTRBPED
			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			nPos := aScan(aTcfQtd, {|x|x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			If nPos > 0 .And. aTcfQtd[nPos,2] == aTcfQtd[nPos,3] // tcf totais do cálculo igual a qtd de tcf com erro
				If lTabTemp
					RecLock(cTRBUNC,.F.)
					(cTRBUNC)->(dbdelete())
					(cTRBUNC)->(MsUnLock())
					GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
				Else
					aDel(aTRBUNC2,idpUNC)
					aSize(aTRBUNC2,Len(aTRBUNC2)-1)
				EndIf
				Loop
			EndIf

			if !lTabTemp
				aSort(aTRBPED  ,,,{|x,y| x[01]+x[02]+x[03]      < y[01]+y[02]+y[03]})
			EndIf

			// Registra o valor do frete sem o minimo e o valor do frete minimo, para utilizar no frete minimo por romaneio
			aValores      := GFEVlBasComp(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), aParamComp)
			aAdd(aFreteSemMin, {GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),;                              // Nr. da Unidade de cálculo
								aValores[1],; // Valor de Frete sem mínimo
								0,;                                              // Valor de frete c/ mínimo - será atualizado a seguir
								nVlFretMin,;                                     // Valor do frete mínimo
								aValores[4],;                                    // Valor que não faz parte do frete mínimo configurado na negociação
								aValores[5]})

			/***********************************************/
			/********   CALCULO DO FRETE MINIMO    *********/
			/***********************************************/
			If cFreMinAnt == "2"
				oGFEXFBFLog:setTexto(CRLF + STR0115 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + CRLF + CRLF) //"  # Verificando frete minimo da unid. calculo "
				oGFEXFBFLog:setTexto(STR0116 + cValToChar(nVlFretMin) + CRLF)     //"    Frete mínimo selecionado: "
				nVlFrtM := nVlFretMin
				If Len(aNegMin) > 0
					oGFEXFBFLog:setTexto(STR0117 + aNegMin[1] + STR0118 + aNegMin[2] + STR0068 + aNegMin[3] + CRLF) //"    Negociacao selecionada: Transp. "###"; Nr.Tab. "###"; Negoc. "

					// Percorrer todos os componentes da unidade de cálculo, somar os que são considerados no frete minimo e comparar com o frete minimo selecionado
					// Se o minimo selecionado for maior que a soma dos componentes, efetuar o tratamento conforme parametrização da negociação
					nVlCompMin := GFEVlBasComp(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),aParamComp)[4]
					If nVlCompMin >= 0 .And. nVlCompMin < nVlFretMin

						oGFEXFBFLog:setTexto(STR0119 + cValToChar(nVlFretMin) + STR0120 + cValToChar(nVlCompMin) + STR0121 + CRLF) //"    Frete minimo ("###") maior que o valor base para comparacao ("###"). Aplicando tratamento..."

						GV9->(dbSetOrder(1))
						If GV9->(dbSeek(xFilial("GV9") + aNegMin[1] + aNegMin[2] + aNegMin[3]))

							oGFEXFBFLog:setTexto(STR0123 + AllTrim(GFEFldInfo("GV9_DIFMIN",GV9->GV9_DIFMIN,2)) + STR0122 + AllTrim(GV9->GV9_COMMIN) + CRLF) //"    Gravar ### no componente ###

							nVlFrComMin  := 0
							nVlFrtOutros := 0
							nQtdComp     := 0
							GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
							GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF2, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
							While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF2, 9) .AND. ;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

								// O array aParamComp contem os componentes e seus parametros de totalizacao de frete, imposto e comparacao do frete minimo
								nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC")})

								If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP") .And. AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP"), "GV2_ATRCAL")) == "9"
									nQtdComp++
								EndIf

								// Caso o componente exista no array, verifica se o mesmo é considerado na comparacao do frete minimo
								IF nPos > 0	.AND. aParamComp[nPos,5] == "1"

									// Acumula para ratear o frete minimo entre todos os componentes correspondentes
									If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP")
										nVlFrComMin += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")
									EndIf

									oGFEXFBFLog:setTexto(Space(6) + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP")) + STR0127 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")) + CRLF) //"###" considera na comparação frete mínimo. Valor: "

									// Desconta o valor do componente do frete minimo. O saldo final será a diferença entre o frete calculado e frete minimo
									nVlFretMin -= GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")

									If lRatClass
										aCdClFr := {GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCLFR"),GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDTPOP")}
									EndIf

									If ( nPos := aScan(aCpMinClFr, {|x| x[1] == aCdClFr[1];
											.And. x[2] == aCdClFr[2]} ) ) > 0

										aCpMinClFr[nPos,3] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")
									Else
										aAdd(aCpMinClFr,{aCdClFr[1],;
											aCdClFr[2],;
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")})
									EndIf


									IF  GV9->GV9_DIFMIN == "2" .AND.; // 1-Gravar a diferença, 2-Gravar total
										GV9->GV9_COMMIN != GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP")

										// Totaliza o valor dos componentes para somar ao componente
										// que receberá o valor total do frete mínimo
										nVlFrtOutros += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")

										// Elimina os demais componentes, deixando apenas o componente que receberá o valor total
										If lTabTemp
											(cTRBCCF)->(dbDelete())
										Else
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"DELETADO","1")
										EndIf
									EndIf
								Else
									oGFEXFBFLog:setTexto(Space(6) + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP")) + STR0128 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")) + CRLF)	 //"###" NÂO considera na comparação frete mínimo. Valor: "
								EndIf
								GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
							EndDo

							If !lTabTemp
								aTRBCCF1 := {}
								For nX := 1 to len(aTRBCCF2)
									If aTRBCCF2[nX,15] == "0"
										AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
											aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
											aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
									EndIf
								Next Nx
								aTRBCCF2 := aClone(aTRBCCF1)
								aSort(aTRBCCF2  ,,,{|x,y| x[01]+x[05]                  < y[01]+y[05]})
							EndIf

							// Grava o saldo (diferenca) no componente indicado na negociação
							GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
							If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF2, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), GV9->GV9_COMMIN})

								nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC")})

								oGFEXFBFLog:setTexto(STR0129 + cValToChar(nVlFretMin) + STR0130 + AllTrim(GV9->GV9_COMMIN) + CRLF) //"    Somando frete mínimo ("###") ao componente "

								While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF2, 9) .AND. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .AND. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP") == GV9->GV9_COMMIN

									oGFEXFBFLog:setTexto(Space(6) + STR0131 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCLFR") + ;
										STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDTPOP") + CRLF) //"Class. Frete "###", Tipo Oper. "


									IF  GV9->GV9_DIFMIN == "2" // 1-Gravar a diferença, 2-Gravar total
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR",nVlFrtM)
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI",nVlFrtM)
									else
										// Acrescenta o valor dos outros componentes no componente frete mínimo
										// antes deste receber o rateio da diferença
										// Como o valor do componente foi alterado, é necessário ajustar o valor total usado para
										// rateio do frete mínimo, somando o valor dos outros componentes ao valor de frete com mínimo
										If nVlFrtOutros > 0
											If nQtdComp > 0 .And. nVlFrComMin == 0
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR",(nVlFrtOutros / nQtdComp))
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI",(nVlFretMin / nQtdComp))
											Else
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR" ,(nVlFrtOutros * (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR") / nVlFrComMin)))
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI",(nVlFretMin * (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR") / (nVlFrComMin + nVlFrtOutros))))
											EndIf
										Else
											If nQtdComp > 0 .And. nVlFrComMin == 0
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI",nVlFretMin / nQtdComp)
											Else
												/*MLOG-1816 - Inclusão da função GFEFbFrMin(). Quando o valor de frete calculado para o componente é 0, existe valor
												de frete mínimo na tarifa, o componente de frete mínimo (GV9_COMMIN) é o mesmo componente do cálculo e o componente
												recebe a diferença entre o valor calculado e o valor de frete mínimo (GV9_DIFMIN = 1), o valor calculado ficava zerado,
												pois era realizado uma multiplicação e divisão por 0. A função retorna o valor 1 caso ele seja 0, para que o resultado
												seja o próprio valor do frete mínimo.*/
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI",(nVlFretMin * GFEFbFrMin((GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR") / nVlFrComMin))))
											EndIf
										EndIf

										If aParamComp[nPos,5] == "1"
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR",(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI")))
										Else
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR",GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI"))
										EndIf
									EndIf

									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"IDMIN","1")


									oGFEXFBFLog:setTexto(Space(8) + STR0132 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR") - GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI")) + CRLF) //" Frete normal: "
									oGFEXFBFLog:setTexto(Space(8) + STR0133 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VLFRMI")) + CRLF) //" Frete mínimo: "
									oGFEXFBFLog:setTexto(Space(8) + STR0134 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"VALOR")) + CRLF) //" Frete total : "

									GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)

								EndDo
							Else

								nVlFretMin += nVlFrtOutros

								oGFEXFBFLog:setTexto(STR0135 + AllTrim(GV9->GV9_COMMIN) + STR0136 + cValToChar(nVlFretMin) + ")" + CRLF) //"    Incluindo componente "###" com o valor do frete mínimo ("

								nQtde := 0
								GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
								if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC"), ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCLFR"), ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDTPOP")})
									GV2->(dbSetOrder(01))
									GV2->(dbSeek(xFilial("GV2")+GV9->GV9_COMMIN))
									cIDVLAG := "1"
									If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
										cIDVLAG := "1"
									Else
										cIDVLAG := GV2->GV2_IDVLAG										
									EndIf
									// Retorna a quantidade para calculo do novo componente
									nQtde := GFEQtdeComp(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
										GV2->GV2_ATRCAL,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
										GV9->GV9_QTKGM3,;
										,;
										,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
										0,;
										cIDVLAG,;
										GetTpEntr( cTpLocEntr,cIDVLAG),;
										GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRLCENT"),;
										lUtlFrMin,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
										IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))
								EndIf

								cTotFre := "1"
								cBASIMP := "1"
								cBAPICO := "1"
								cFREMIN := "2"


								For nX := 1 To Len(aCpMinClFr)
									if lTabTemp
										RecLock(cTRBCCF, .T.)
										(cTRBCCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
										(cTRBCCF)->CDCOMP := GV9->GV9_COMMIN
										(cTRBCCF)->CATVAL := AllTrim(Posicione("GV2",1,xFilial("GV2")+GV9->GV9_COMMIN,"GV2_CATVAL"))
										(cTRBCCF)->VLFRMI := ( ( aCpMinClFr[nX,3] / nVlCompMin ) *  nVlFretMin ) - aCpMinClFr[nX,3]
										(cTRBCCF)->VALOR  := ( aCpMinClFr[nX,3] / nVlCompMin ) *  nVlFretMin
										(cTRBCCF)->QTDE   := nQtde
										(cTRBCCF)->TOTFRE := cTotFre
										(cTRBCCF)->BASIMP := cBASIMP
										(cTRBCCF)->BAPICO := cBAPICO
										(cTRBCCF)->FREMIN := cFREMIN
										(cTRBCCF)->IDMIN  := "1"
										(cTRBCCF)->CDCLFR := aCpMinClFr[nX,1]
										(cTRBCCF)->CDTPOP := aCpMinClFr[nX,2]
										(cTRBCCF)->(MsUnLock())
									Else //TODO Verificar o porque do campo VLFRMI ficar zerado no cálculo usando array
										aAdd(aTRBCCF2,{	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),;
											aCpMinClFr[nX,1],;
											aCpMinClFr[nX,2],;
											Space(04),;
											GV9->GV9_COMMIN,;
											AllTrim(Posicione("GV2",1,xFilial("GV2")+GV9->GV9_COMMIN,"GV2_CATVAL")),;
											nQtde,;
											( aCpMinClFr[nX,3] / nVlCompMin ) *  nVlFretMin,;
											cTOTFRE,;
											cBASIMP,;
											cBAPICO,;
											cFREMIN,;
											"1",;
											0,;
											"0",;
											Space(6),;
											Space(1)})
									EndIf
								Next nX
								// Adiciona o componente no array de parametros, prevalecendo os parametros ativos
								GFEParamComp({GV9->GV9_COMMIN,;
									cTotFre,;
									cBASIMP,;
									cBAPICO,;
									cFREMIN,;
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")},;
									@aParamComp)
							EndIf

							if !lTabTemp
								aTRBCCF1 := aClone(aTRBCCF2)
								aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
							EndIf
							/*******************************************************
							********* RECÁLCULO FRETE SOBRE VALOR DO FRETE *********
							*******************************************************/

							oGFEXFBFLog:setTexto("    # Recalculando componentes que calculam sobre o valor frete após aplicação do frete mínimo." + CRLF + CRLF) //"    # Verificando taxas da unidade de cálculo "

							nFrtVlFret := 0

							GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
							GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
							While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

								aInfoTab := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))

								GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
								GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") ,;
									GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") ,;
									GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")})
								While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .AND. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") .AND. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")


									GV9->(dbSetOrder(1) )
									If GV9->(dbSeek(xFilial("GV9") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )

										nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})

										If nPos > 0	.AND. ;
												aParamComp[nPos][2] == "1" .And. ;
												(AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_ATRCAL")) != "9" .Or. ;
												GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .And. ;
												AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_ATRCAL")) == "9")

											nFrtVlFret += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

										EndIf

									EndIf

									GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)

								EndDo

								GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)

							EndDo

							GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
							GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), Space(4), Space(10)})

							While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. ;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .AND. ;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == Space(4) .AND. ;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == Space(10)


								nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})

								If nPos > 0	.AND. aParamComp[nPos][2] == "1" .And. ;
										AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_ATRCAL")) != "9"

									nFrtVlFret += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

								EndIf

								GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)

							EndDo

							nTotVlFrt := nFrtVlFret

							oGFEXFBFLog:setTexto("      Valor Total do Frete após aplicação do frete mínimo: " + cValToChar(nTotVlFrt) + CRLF + CRLF) //"      Valor Total do Frete após aplicação do frete mínimo: "

							GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
							GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
							While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

								aInfoTab := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))

								GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
								GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") ,;
									GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") ,;
									GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")})

								While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. ;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == ;
										GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

									If AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_ATRCAL")) == "9"

										If aInfoTab[1]

											GVB->(dbSetOrder(01))
											If GVB->(dbSeek(xFilial("GVB") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))
												nMul := GVB->GVB_VLMULT
												nAdc := GVB->GVB_VLADIC
											Else
												nMul := aInfoTab[4]
												nAdc := aInfoTab[5]
											EndIf

										EndIf

										GV9->(dbSetOrder(1) )
										If GV9->(dbSeek(xFilial("GV9") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )

											// Tratamento para componente
											GV1->(dbSetOrder(1))
											If GV1->(dbSeek(xFilial("GV1")+ aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))

												If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + GFEVlComp({GV1->GV1_CDCOMP,GV1->GV1_VLFIXN,GV1->GV1_PCNORM,GV1->GV1_VLUNIN,GV1->GV1_VLFRAC,GV1->GV1_VLMINN,GV1->GV1_VLLIM,GV1->GV1_VLFIXE,GV1->GV1_PCEXTR,GV1->GV1_VLUNIE,GV1->GV1_CALCEX}, nFrtVlFret, 0, nMul, nAdc))
												Else
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",GFEVlComp({GV1->GV1_CDCOMP,GV1->GV1_VLFIXN,GV1->GV1_PCNORM,GV1->GV1_VLUNIN,GV1->GV1_VLFRAC,GV1->GV1_VLMINN,GV1->GV1_VLLIM,GV1->GV1_VLFIXE,GV1->GV1_PCEXTR,GV1->GV1_VLUNIE,GV1->GV1_CALCEX}, nFrtVlFret, 0, nMul, nAdc))
												EndIf

												oGFEXFBFLog:setTexto("      Componente " + AllTrim(GV1->GV1_CDCOMP) + " calcula sobre valor do frete, assumindo novo valor de: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF + CRLF) //"      Componente " ### " calcula sobre valor do frete, assumindo novo valor de: "

												nTotVlFrt += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

												If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
													nTotVlFrt -= nVlFretMin
												EndIf

											EndIf

											// Tratamento para Componentes Adic. Emitente
											cAliasGUC := GetNextAlias()

											BeginSql Alias cAliasGUC
												SELECT GUC.R_E_C_N_O_ AS RECNOGUC,
													   GUC_CDCOMP,
													   GUC_VLFIXN,
													   GUC_PCNORM,
													   GUC_VLUNIN,
													   GUC_VLFRAC,
													   GUC_VLMINN,
													   GUC_VLLIM,
													   GUC_VLFIXE,
													   GUC_PCEXTR,
													   GUC_VLUNIE,
													   GUC_CALCEX
												FROM %Table:GUC% GUC
												WHERE GUC_FILIAL = %xFilial:GUC%
												AND GUC_CDEMIT = %Exp:aInfoTab[2]%
												AND GUC_NRTAB = %Exp:aInfoTab[3]%
												AND GUC_NRNEG = %Exp:GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")%
												AND GUC_CDFXTV = %Exp:GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")%
												AND GUC_NRROTA = %Exp:GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")%
												AND GUC_CDCOMP = %Exp:GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")%
												AND GUC.%NotDel%
											EndSql
											If (cAliasGUC)->(!Eof())

												If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9, "VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + GFEVlComp({(cAliasGUC)->GUC_CDCOMP,(cAliasGUC)->GUC_VLFIXN,(cAliasGUC)->GUC_PCNORM,(cAliasGUC)->GUC_VLUNIN,(cAliasGUC)->GUC_VLFRAC,(cAliasGUC)->GUC_VLMINN,(cAliasGUC)->GUC_VLLIM,(cAliasGUC)->GUC_VLFIXE,(cAliasGUC)->GUC_PCEXTR,(cAliasGUC)->GUC_VLUNIE,(cAliasGUC)->GUC_CALCEX}, nFrtVlFret, 0, nMul, nAdc))
												Else
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9, "VALOR", GFEVlComp({(cAliasGUC)->GUC_CDCOMP,(cAliasGUC)->GUC_VLFIXN,(cAliasGUC)->GUC_PCNORM,(cAliasGUC)->GUC_VLUNIN,(cAliasGUC)->GUC_VLFRAC,(cAliasGUC)->GUC_VLMINN,(cAliasGUC)->GUC_VLLIM,(cAliasGUC)->GUC_VLFIXE,(cAliasGUC)->GUC_PCEXTR,(cAliasGUC)->GUC_VLUNIE,(cAliasGUC)->GUC_CALCEX}, nFrtVlFret, 0, nMul, nAdc))
												EndIf

												oGFEXFBFLog:setTexto("      Componente " + AllTrim((cAliasGUC)->GUC_CDCOMP) + " calcula sobre valor do frete, assumindo novo valor de: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF + CRLF) //"      Componente " ### " calcula sobre valor do frete, assumindo novo valor de: "

												nTotVlFrt += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

												If GV9->GV9_COMMIN == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9, "CDCOMP")
													nTotVlFrt -= nVlFretMin
												EndIf

											EndIf

											(cAliasGUC)->( DbCloseArea() )

										EndIf

									EndIf

									GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)

								EndDo

								GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)

							EndDo

							oGFEXFBFLog:setTexto("      Valor total do frete após recálculo dos componentes que calculam sobre o valor: " + cValToChar(nTotVlFrt) + CRLF + CRLF) //"      Valor total do frete após recálculo dos componentes que calculam sobre o valor:  "

							/**************************************************************
							********* RECÁLCULO TAXA POR ENTREGA DEPOIS DO MÍNIMO *********
							**************************************************************/

							GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
							GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
							While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

								nQtEntregas := GFEQtdeEntr(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"), If(!Empty(cTpLocEntr),'1',''), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRLCENT") )
								nVlFrtFx    := 0

								GUZ->(dbSetOrder(1) )
								GUZ->(dbSeek(xFilial("GUZ") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )
								While !GUZ->(EOF() ) .AND. GUZ->GUZ_FILIAL == xFilial("GUZ") .AND. GUZ->GUZ_CDEMIT == aInfoTab[2] .AND. GUZ->GUZ_NRTAB == aInfoTab[3] .AND. GUZ->GUZ_NRNEG == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")

									If nQtEntregas <= GUZ->GUZ_VLFXFI
										nVlFrtFx := (nTotVlFrt * GUZ->GUZ_PCENTR / 100) + GUZ->GUZ_VLENTR
										// Truncar ou Arredondar
										nVlFrtFx := GFETratDec(nVlFrtFx,8)
										Exit
									EndIf

									GUZ->(dbSkip() )
								EndDo

								If nVlFrtFx > 0

									oGFEXFBFLog:setTexto("    # Recalculando as taxas por entrega depois da aplicação do frete mínimo." + CRLF + CRLF) //"    # Recalculando as taxas por entrega depois da aplicação do frete mínimo."

									GV9->(dbSetOrder(1) )
									If GV9->(dbSeek(xFilial("GV9") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )
										GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
										If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") ,;
												GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") ,;
												GV9->GV9_COMFXE})

											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") := nVlFrtFx

											oGFEXFBFLog:setTexto("      Assumindo novo valor para o componente de taxa de entrega " + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")) + " : " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF + CRLF) //"      Assumindo novo valor para o componente de taxa de entrega "

										EndIf

									EndIf

								EndIf

								GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)

							EndDo

						EndIf
					Else
						If nVlCompMin == 0
							oGFEXFBFLog:setTexto(STR0137 + CRLF) //"    Nenhum componente do cálculo foi considerado para comparação com o frete minimo. Mantendo frete calculado."
						Else
							oGFEXFBFLog:setTexto(STR0138 + cValToChar(nVlFretMin) + STR0139 + cValToChar(nVlCompMin) + STR0140 + CRLF) //"    Frete mínimo ("###") menor que o valor base para comparação ("###"). Mantendo frete calculado."
						EndIf
					EndIf
				EndIf
			EndIf

			// Adiciona o valor do frete com minimo no array
			nPos := aScan(aFreteSemMin,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			If nPos > 0
				aFreteSemMin[nPos,3] := GFEVlBasComp(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), aParamComp)[1]
			EndIf

			nVlFretMin := 0

			/***********************************************/
			/**********   TRATAMENTO DE TAXAS   ************/
			/***********************************************/
			oGFEXFBFLog:setTexto(STR0103 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + CRLF + CRLF) //"    # Verificando taxas da unidade de cálculo "

			GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
				While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And.;
						(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC"))
					oGFEXFBFLog:setTexto(STR0104 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + STR0105 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") + CRLF) //"      Componente "###", Class. Frete "###", Tipo Oper. "
					GV2->(dbSetOrder(01))
					If GV2->(dbSeek(xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))

						// Grava a taxa de maior valor quando esta for um valor fixo
						// Taxas baseadas em quantidade ou valor da mercadoria são gravadas como foram calculadas

						If ((GV2->GV2_CATVAL == "3" ) .AND.; 				// Taxas ou Serviço
							(AllTrim(GV2->GV2_ATRCAL) == "8" .OR.;		//Valor Informado;
								AllTrim(GV2->GV2_ATRCAL) == "11")) .OR.; 	// Qtde.Serv
							GV2->GV2_IDVLRC == "1" 						// Aplicado por romaneio (diária)

							oGFEXFBFLog:setTexto(If(GV2->GV2_IDVLRC == "1", STR0107, STR0108) + STR0109 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //"        É aplicado por romaneio."###"        É taxa de valor informado."###" Valor atual: "

							nLin := aScan(aTaxa, {|x| x[_CDCOMP] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")})

							If nLin > 0

								If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE") == "1"
									aTaxa[nLin,_VALOR_TOTAL] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
								EndIf

								If aTaxa[nLin,_VALOR] < GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
									oGFEXFBFLog:setTexto(STR0110 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //"        Assumindo maior valor para o componente: "
									aTaxa[nLin,_VALOR] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
								Else
									oGFEXFBFLog:setTexto(STR0111 + cValToChar(aTaxa[nLin,_VALOR]) + CRLF) //"        Valor atual do componente mantido: "
								EndIf

							Else
								aAdd(aTaxa,{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"),;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CATVAL"),;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") ,;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE")  ,;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE"),;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BASIMP"),;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BAPICO"),;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"FREMIN"),;
									GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),;
									0,;
									If (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE") == "1", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"), 0 )})
									oGFEXFBFLog:setTexto(STR0112 + CRLF) //"        1a ocorrencia do componente. Registrando valor..."
								EndIf
							Else
								oGFEXFBFLog:setTexto(IF(GV2->GV2_CATVAL != "3", STR0113, STR0114 + GFEFldInfo("GV2_ATRCAL", GV2->GV2_ATRCAL, 2)) + CRLF) //"        Não é taxa."###"        É taxa calculada sobre "
							EndIf
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
					EndDo
				EndIf

				// Rateia os valores componentes do array, baseado no componente que teve o maior valor.
				// No array podem constar taxas com valor informado ou componentes de diária
				For nX := 1 TO Len(aTaxa)
					GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
					GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{aTaxa[nX,_NRCALC]}) // busca todos registros de componentes do mesmo calculo
					While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .and. ;
							GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == aTaxa[nX,_NRCALC]
						if GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") == aTaxa[nX,_CDCOMP] // filtra os componentes de acordo com o que esta gravado no array e elimina os registros
							If lRatClass
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", ( GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") / aTaxa[nX,_VALOR_TOTAL]) * aTaxa[nX,_VALOR] )
							Else
								If lTabTemp
									(cTRBCCF)->(dbDelete())
								Else
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
								EndIf
							EndIf
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
					EndDo
					If !lRatClass
						If lTabTemp
							//Cria um unico registro para cada componente que estiver no array.
							RecLock(cTRBCCF,.T.)
							(cTRBCCF)->CDCOMP := aTaxa[nX,_CDCOMP]
							(cTRBCCF)->CATVAL := aTaxa[nX,_CATVAL]
							(cTRBCCF)->VALOR  := aTaxa[nX,_VALOR]
							(cTRBCCF)->QTDE   := aTaxa[nX,_QTDE]
							(cTRBCCF)->TOTFRE := aTaxa[nX,_TOTFRE]
							(cTRBCCF)->BASIMP := aTaxa[nX,_BASIMP]
							(cTRBCCF)->BAPICO := aTaxa[nX,_BAPICO]
							(cTRBCCF)->FREMIN := aTaxa[nX,_FREMIN]
							(cTRBCCF)->NRCALC := aTaxa[nX,_NRCALC]
							(cTRBCCF)->IDMIN  := "2"
							(cTRBCCF)->(MsUnLock())
						Else
							aAdd(aTRBCCF1,{	aTaxa[nX,_NRCALC],;
								Space(04),;
								Space(10),;
								Space(04),;
								aTaxa[nX,_CDCOMP],;
								aTaxa[nX,_CATVAL],;
								IIF(Empty(aTaxa[nX,_QTDE ]),0,aTaxa[nX,_QTDE ]),;
								IIF(Empty(aTaxa[nX,_VALOR]),0,aTaxa[nX,_VALOR]),;
								aTaxa[nX,_TOTFRE],;
								aTaxa[nX,_BASIMP],;
								aTaxa[nX,_BAPICO],;
								aTaxa[nX,_FREMIN],;
								"2",;
								0,;
								"0",;
								Space(6),;
								Space(1)})
						EndIf
					EndIf
					// Se for aplicado por romaneio, coloca num array para ser usado depois, no rateio por romaneio
					If Posicione("GV2",1,xFilial("GV2")+aTaxa[nX,_CDCOMP],"GV2_IDVLRC") == "1"
						aAdd(aCompDia,aTaxa[nX])
					EndIf
				Next nX

				if !lTabTemp
					aTRBCCF2 := aClone(aTRBCCF1)
					aTRBCCF1 := {}
					For nX := 1 to len(aTRBCCF2)
						if aTRBCCF2[nX,15] == "0"
							AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
								aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
								aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
						EndIf
					Next Nx
					aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
				EndIf
				// Ajusta os trechos do calculo base, vinculando-os temporariamente ao calculo corrente
				If lSimulacao .AND. iTipoSim == 0
					GFEAjusTre(.F.)	// .T. - Vincula o trecho ao cálculo simulado corrente, .F. - Retorna o trecho ao calculo original
				EndIf
				GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
			EndDo	// Unidade de Calculo

			If !lTabTemp
				aTRBUNC1 := aClone(aTRBUNC2)
				aTRBUNC3 := aClone(aTRBUNC2)
				aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
				aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
			EndIf

			If cTpLocEntr == "1"
				oGFEXFBFLog:setTexto("  # Verificando e relacionando componentes" + CRLF)
				LocEntrg(.T.)
				aAreaCCF := GFEXFB_9GETAREA(lTabTemp, cTRBCCF, 9)
				GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
				GFEXFB_BORDER(lTabTemp,cTRBENT,1,12)
				For nX := 1 to Len(aCompDia)
					GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF2, 9,{aCompDia[nX,9],aCompDia[nX,1]})
					If !Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRLCENT"));
							.And. GFEXFB_CSEEK(lTabTemp, cTRBENT, @aTRBENT1, 12,;
							{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRLCENT"),;
							GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP" )});
							.And. GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDCOMP" ) > 0

						aCompDia[nX,10] := 1/GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDCOMP" )
						If GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,"QTDCOMP" ) > 1
							oGFEXFBFLog:setTexto("  # Componente " + aCompDia[nX,1] + " rateado entre os cálculos do local de entrega: " + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRLCENT") + CRLF)
						EndIf

					EndIf
				Next nX
				GFEXFB_ARESTAREA(lTabTemp,aAreaCCF,9)
				GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			EndIf
			oGFEXFBFLog:setTexto(CRLF + STR0141 + CRLF + CRLF) //"  # Parâmetros dos componentes das unidades de cálculo"
			oGFEXFBFLog:setTexto(STR0142 + CRLF) //"    Unid.Calc|Componente|Tot.Frete|Base.Imp|Base PIS/COFINS|Frete Min."

			For nX := 1 to Len(aParamComp)
				oGFEXFBFLog:setTexto(Space(4) + aParamComp[nX,6] + "|" + aParamComp[nX,1] + "|" + aParamComp[nX,2] + "|" + aParamComp[nX,3] + "|" + aParamComp[nX,4] + "|" + aParamComp[nX,5] + CRLF)
			Next nX

			/*****************************************************/
			/****RATEIO DE VALORES POR ROMANEIO (EX.: DIARIA)*****/
			/*****************************************************/
			oGFEXFBFLog:setTexto(CRLF + STR0143 + CRLF + CRLF) //"  # Calculando valores por romaneio..."

			If lAplicValRom
				aValDiaria := {}
				aTotTre    := {}
				aTotCalc   := {}
				aCompDiaTt := {}

				for nX:= 1 to Len(aCompDia)
					nPos := aScan(aCompDiaTt, {|x| x[1] == aCompDia[nX,_NRCALC]})
					if nPos == 0
						aAdd(aCompDiaTt,{aCompDia[nX,_NRCALC],aCompDia[nX,_VALOR]})
					Else
						aCompDiaTt[nPos,2] += aCompDia[nX,_VALOR]
					EndIf
				next

				aSort(aCompDiaTt,,,{|x,y| x[02] > y[02]})

				oGFEXFBFLog:setTexto(STR0144 + GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") + CRLF) //"    Verificando unidades de cálculo do agrupador "

				GFEXFB_BORDER(lTabTemp,cTRBUNC,03,6)
				If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC3, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
					While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC3, 6) .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

						oGFEXFBFLog:setTexto(CRLF + STR0145 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC") + STR0146 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") + CRLF)                         //"    # Acumulando valores da unidade de cálculo "###", Trecho "

						GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
						If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")})

							While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")

								oGFEXFBFLog:setTexto(STR0147 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + STR0148 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + ")" + CRLF) //"      Negociação "###" (Class. Frete "###", Tipo Oper. "

								// Acumular os valores da negociacao por trecho
								nPos := aScan(aTotTre,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") .AND. ;
									x[8] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .AND. ;
									x[9] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
								If nPos == 0
									aAdd(aTotTre,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
										0,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;
										GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
								Else
									aTotTre[nPos,2] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
									aTotTre[nPos,3] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
									aTotTre[nPos,4] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
									aTotTre[nPos,5] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
									aTotTre[nPos,6] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
								EndIf

								// Acumular os valores da negociacao por unidade de cálculo
								nPos := aScan(aTotCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC") .AND. ;
									x[7] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .AND. ;
									x[8] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
								If nPos == 0
									aAdd(aTotCalc,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC"),;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")*nClones,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")*nClones,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")*nClones,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")*nClones,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")*nClones,;
										GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;
										GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
								Else
									aTotCalc[nPos,2] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")  *nClones
									aTotCalc[nPos,3] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") *nClones
									aTotCalc[nPos,4] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") *nClones
									aTotCalc[nPos,5] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")*nClones
									aTotCalc[nPos,6] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")*nClones
								EndIf

								GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
							EndDo
						EndIf	// Tabelas da unidade de cálculo

						nPos := aScan(aTotTre,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") .AND. ;
							x[8] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .AND. ;
							x[9] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
						If nPos > 0
							aTotTre[nPos,7]++ // Quantidade de cálculos do trecho
						EndIf

						oGFEXFBFLog:setTexto(CRLF + STR0149 + CRLF) //"    # Determinando maiores valores dentre os componentes"

						GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
						GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")})
							
						aValMaior[1] := ""
						aValMaior[2] := 0
							
						If GFXCP12127("GV9_FRMCRC")
						 	oGFEXFBFLog:setTexto(CRLF + "	  Novo campo da negociação referente a forma de verificar o componente por romaneio está criado na base.")
						 	oGFEXFBFLog:setTexto(CRLF + "	  Valor do campo GV9->GV9_FRMCRC: " + GV9->GV9_FRMCRC + CRLF)
						 	
							If GV9->GV9_FRMCRC == "2"
								oGFEXFBFLog:setTexto(CRLF + "	  Campo marcado com a opção por unidade de cálculo.")
								For nX := 1 to len(aCompDiaTt)
									oGFEXFBFLog:setTexto(CRLF + "	  Executando a definição do maior valor de frete levando em consideração o valor total da Unidade de Cálculo.")
									oGFEXFBFLog:setTexto(CRLF + "	  Avaliando a unidade de cálculo " + aCompDiaTt[nX][1])
									oGFEXFBFLog:setTexto(CRLF + "	  Valor da unidade de cálculo: " + cValToChar(aCompDiaTt[nX][2]))
									oGFEXFBFLog:setTexto(CRLF + "	  Maior Valor Atual: " + cValToChar(aValMaior[2]))
									If aCompDiaTt[nX][2] > aValMaior[2]
										oGFEXFBFLog:setTexto(CRLF + "	  Atualizando o maior valor de frete")
										oGFEXFBFLog:setTexto(CRLF + "	  A unidade de cálculo " + aCompDiaTt[nX][1] + " possui o maior de frete. O novo maior valor é " + cValToChar(aCompDiaTt[nX][2]) + CRLF)
										aValMaior[1] := aCompDiaTt[nX][1]
										aValMaior[2] := aCompDiaTt[nX][2]
									Else
										oGFEXFBFLog:setTexto(CRLF + "	  Mantido o maior valor de frete")
										oGFEXFBFLog:setTexto(CRLF + "	  Maior Valor Atual: " + cValToChar(aValMaior[2]) + CRLF)
									EndIf 
								Next nX
							Else
								oGFEXFBFLog:setTexto(CRLF + "	  Campo marcado com a opção por componente." + CRLF)
								aValMaior[1] := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")
							EndIf
						Else
							oGFEXFBFLog:setTexto(CRLF + "	  Novo campo referente a forma de verificar o componente por romaneio não existe na base." + CRLF)
							aValMaior[1] := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")
						EndIf
							
						oGFEXFBFLog:setTexto(CRLF)
							
						// Determinar o maior valor de diária dentre os componentes dos cálculos do trecho
						For nX := 1 to len(aCompDia)
							If lSimulacao .And. aCompDia[nX,_NRCALC] != aValMaior[1]
								 aValMaior[1] := aCompDia[nX,_NRCALC] 
								 aValMaior[2] := aCompDia[nX,3] 
								 aValDiaria   := {}
							EndIf

							// Para os componentes da unidade de cálculo...
							If aCompDia[nX,_NRCALC] == aValMaior[1] //GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")

								For nX2 := 1 to Len(aCompDiaTt)

									If aCompDiaTt[nX2,1] == aCompDia[nX,_NRCALC]


										oGFEXFBFLog:setTexto(STR0104 + aCompDia[nX,_CDCOMP] + STR0150 + cValToChar(aCompDia[nX,_VALOR]) + CRLF) //"      Componente "###" -> Valor "
										// Verifica se o componente existe no array aValDiaria e se o valor é maior
										nPos := aScan(aValDiaria,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") .AND. ;
											x[2] == aCompDia[nX,_CDCOMP] .AND. ;
											x[4] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") .And. ;
											If(x[5] > 0, x[6] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRLCENT"),.T.) .AND. ;
												x[7] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})

											If nPos > 0 .AND. (aValDiaria[nPos,3] < aCompDia[nX,_VALOR])

												oGFEXFBFLog:setTexto(STR0151 + cValToChar(aValDiaria[nPos,3]) + STR0152 + CRLF)  //"      Valor maior que o registrado para o trecho ("###"). Atualizando..."

												// Se sim, atualiza o componente no array com o valor
												aValDiaria[nPos,3] := aCompDia[nX,_VALOR]
												aValDiaria[nPos,8] := aValDiaria[nPos,8] + 1
											Else
												// Adiciona o componente no array de maior diária
												If nPos == 0
													aAdd(aValDiaria,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE"),;
														aCompDia[nX,_CDCOMP],;
														aCompDia[nX,_VALOR],;
														GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;
														aCompDia[nX,10],;
														GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRLCENT"),;
														GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT"),;
														1})
												Else
													aValDiaria[nPos,8] := aValDiaria[nPos,8] + 1
												EndIf
											EndIf
										EndIf
									Next nX2
								EndIf
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
						EndDo
					EndIf

					If Empty(aValDiaria)
						oGFEXFBFLog:setTexto(CRLF + Space(4) + STR0538 + CRLF) //"Não há componentes com valores aplicáveis ao romaneio."
					Else
						oGFEXFBFLog:setTexto(CRLF + STR0153 + CRLF + CRLF) //"    # Rateando valores entre os cálculos dos trechos "

						//	Ratear o maior valor de diária entre os cálculos do trecho

						oGFEXFBFLog:setTexto(STR0154 + GFEDsCriRat(cCriRat) + CRLF) //"      Critério de rateio: "
						
						GFEXFB_BORDER(lTabTemp,cTRBUNC,03,6)
						If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC3, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
							While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC3, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

								oGFEXFBFLog:setTexto(STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC") + STR0146 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") + CRLF)			 //"      Unidade de cálculo "###", Trecho "

								GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
								GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")})

								nPosCalc := aScan(aTotCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC") .AND. ;
									x[7] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .AND. ;
									x[8] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
								nPosTre  := aScan(aTotTre ,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") .AND. ;
									x[8] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .AND. ;
									x[9] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})

								If nPosCalc != 0 .AND. nPosTre != 0
									GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
									If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")})
										aUnidProc := {}
										
										Do While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
											  	  GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")

											cUnidCalc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")
											cCdComp   := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")

											nPosUnid := aScan(aUnidProc, {|x| x[1] == cUnidCalc .And. x[2] == cCdComp})

											If nPosUnid > 0
												aUnidProc[nPosUnid][3]++
											Else
												Aadd(aUnidProc, {cUnidCalc, cCdComp,1,0})
											EndIf

											GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
										EndDo
									EndIf
									GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
									If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")})
										While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")
											
											nPos := aScan(aValDiaria,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"SEQTRE") .AND. ;
																		  x[2] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. ;
																		  x[4] == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")  .And. ;
																		  If(x[5] > 0, x[6] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRLCENT"),.T.) .AND. ;
																		  x[7] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"GRURAT")})
												If nPos > 0

													If aValDiaria[nPos,8] == 1
														oGFEXFBFLog:setTexto("Apenas um registro de componente rateado por romaneio, não necessita realizar o rateio." + CRLF) //"      Componente "###"        Valor a ratear "
													Else
														cUnidCalc := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC")
														cCdComp   := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")
														lPerc	  := .F.
														nPercOrig := 0

														oGFEXFBFLog:setTexto(STR0104 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF + STR0156 + cValToChar(aValDiaria[nPos,3]) + CRLF) //"      Componente "###"        Valor a ratear "

														Do Case
														Case aValDiaria[nPos,5] > 0
															nPerc := aValDiaria[nPos,5]
															cDsCriRat := "1/"+ cValToChar(1/nPerc) // Critério de rateio de locais de entrega
														Case cCriRat == "1" .Or. !(cCriRat $ "2;3;4") // Peso
															// Verifica se peso real é maior que o cubado. Usa o que for maior
															If aTotTre[nPosTre,4] > aTotTre[nPosTre,5]
																aPerc := GFEVlrPerc(4,aParamComp,aTotCalc,cCdComp,cUnidCalc,aTRBUNC3)
																nPerc := aPerc[1]
																cDsCriRat := aPerc[2]
															Else
																aPerc := GFEVlrPerc(5,aParamComp,aTotCalc,cCdComp,cUnidCalc,aTRBUNC3)
																nPerc := aPerc[1]
																cDsCriRat := aPerc[2]
															EndIf
														Case cCriRat == "2" // Valor
															aPerc := GFEVlrPerc(3,aParamComp,aTotCalc,cCdComp,cUnidCalc,aTRBUNC3)
															nPerc := aPerc[1]
															cDsCriRat := aPerc[2]
														Case cCriRat == "3" // Volume
															aPerc := GFEVlrPerc(6,aParamComp,aTotCalc,cCdComp,cUnidCalc,aTRBUNC3)
															nPerc := aPerc[1]
															cDsCriRat := aPerc[2]
														Case cCriRat == "4" // Qtde
															aPerc := GFEVlrPerc(2,aParamComp,aTotCalc,cCdComp,cUnidCalc,aTRBUNC3)
															nPerc := aPerc[1]
															cDsCriRat := aPerc[2]
														EndCase

														If nPerc == 0
															nPerc := 1 / aPerc[3]
															cDsCriRat := aPerc[2]
														EndIf

														nPosUnid := aScan(aUnidProc, {|x| x[1] == cUnidCalc .And. x[2] == cCdComp})

														If nPosUnid > 0 .And. aUnidProc[nPosUnid][3] > 1 
															nPercOrig := nPerc
															IF GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE") == 0
																nPerc := nPerc / aUnidProc[nPosUnid][3]
															Else
																nPerc := nPerc * (GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE") / aPerc[4])
															EndIf
															lPerc 	  := .T.
															aUnidProc[nPosUnid][4]++
														EndIf

														oGFEXFBFLog:setTexto(STR0157 + '(' + cDsCriRat + ') = ' + cValToChar(nPerc) + CRLF) //"        Fator de rateio "

														If lRatClass
															// Atualiza a participação do componente que calcula sobre romaneio
															nY := aScan(aCompDia,{|x| x[_NRCALC] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC3, 6,"NRCALC");
																.And. x[_CDCOMP] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP");
																.And. GV9->GV9_FRMCRC == "2"})

															If nY > 0 .And. aCompDia[nY,_VALOR] != 0
																nPerc := nPerc * (aValDiaria[nPos,3] / aCompDia[nY,_VALOR])
															EndIf

															If nY > 0 .And. aValDiaria[nPos,3] != aCompDia[nY,_VALOR]
																oGFEXFBFLog:setTexto("        Novo Fator de rateio / componente valor menor: " + cValToChar(nPerc) + CRLF)
																nVlrCpo := aCompDia[nY,_VALOR]
															Else
																nVlrCpo := aValDiaria[nPos,3]
															EndIf
														Else
															nVlrCpo := aValDiaria[nPos,3]
														EndIf

														nPosRat := Ascan(aCount, {|x| x[1] == nPos .And. x[2] == aValDiaria[nPos,2]})
														If nPosRat == 0  .And. aValDiaria[nPos,3] != 0
															Aadd(aCount, {nPos, aValDiaria[nPos,2], 1, 0, {cUnidCalc}})

															nPosRat := Ascan(aCount, {|x| x[1] == nPos .And. x[2] == aValDiaria[nPos,2]})
														Else
															nPosCmp := Ascan(aCount, {|x| x[1] == nPos .And. x[2] == cCdComp})
															If nPosCmp > 0
																nPosCUn := Ascan(aCount[nPosCmp][5], {|x| x == cUnidCalc})
																If nPosCUn == 0 .And. aValDiaria[nPos,3] != 0
																	Aadd(aCount[nPosRat, 5], cUnidCalc)
																	aCount[nPosRat,3] += 1
																EndIf
															EndIf
														EndIf

														If lPerc
															If nPos == aCount[nPosRat,1] .And. aValDiaria[nPos,8] == aCount[nPosRat,3] .And. nVlrCpo != 0 .And. aUnidProc[nPosUnid][4] == aUnidProc[nPosUnid][3]
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nVlrCpo - aCount[nPosRat,4])
															ElseIf nPos == aCount[nPosRat,1] .And. aValDiaria[nPos,8] == aCount[nPosRat,3] .And. nVlrCpo != 0 .And. aUnidProc[nPosUnid][4] != aUnidProc[nPosUnid][3]
																nValCompRat := (ROUND(nVlrCpo * nPerc,2))
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",nValCompRat)
																aCount[nPosRat,4] += nValCompRat
															Else
																nValCompRat := (ROUND(nVlrCpo * nPerc,2))
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nValCompRat)
																aCount[nPosRat,4] += nValCompRat
															EndIf
														ElseIf aValDiaria[nPos,3] != 0
															//Verifica se é o ultimo rateio do componente para realizar o arredondamento do valor
															If nPos == aCount[nPosRat,1] .And. aValDiaria[nPos,8] == aCount[nPosRat,3] .And. nVlrCpo != 0 .And. aUnidProc[nPosUnid][4] == aUnidProc[nPosUnid][3]
																If Alltrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")) == Alltrim(aValDiaria[nPos,2]) .And. nVlrCpo != aValDiaria[nPos,3]
																	nVlrCpo := aValDiaria[nPos,3]
																EndIf
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nVlrCpo - aCount[nPosRat,4])
															ElseIf nPos == aCount[nPosRat,1] .And. aValDiaria[nPos,8] == aCount[nPosRat,3] .And. nVlrCpo != 0 .And. aUnidProc[nPosUnid][4] != aUnidProc[nPosUnid][3]
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nVlrCpo - aCount[nPosRat,4])
															Else
																nValCompRat := ROUND(nVlrCpo * nPerc, 2)
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nValCompRat)
																aCount[nPosRat,4] += nValCompRat
															EndIf
														EndIf

														If aValDiaria[nPos,5] > 0 // Exibe a quantidade final do rateio
															GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE",aValDiaria[nPos,5])
														EndIf
														oGFEXFBFLog:setTexto(STR0158 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //"        Novo valor "
													EndIf
												EndIf
												GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
											EndDo
										EndIF
									EndIf

									GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
								EndDo
							EndIf
						EndIf
					Else
						oGFEXFBFLog:setTexto(CRLF + Space(4) + STR0539 + CRLF) //"Valores de componentes por romaneio não foram aplicados aos cálculos."
					EndIf

					/***********************************************/
					/**** CALCULO DO FRETE MINIMO POR ROMANEIO *****/
					/***********************************************/
					// TODO: Considerar para cada trecho o frete minimo por romaneio!!!
					oGFEXFBFLog:setTexto(CRLF + STR0159 + CRLF + CRLF) //"  # Verificando frete mínimo por romaneio..."

					If lAplicValRom .And. lCalcServ == .F.
						If lFreMinIgual .AND. cFreMinAnt == "1" //.AND. lCompFreRom	// Frete minimo por romaneio

							If lTpFreMinIgual .AND. cTpFreMinAnt == "2"	// Por quantidade de mercadoria

								oGFEXFBFLog:setTexto(STR0160 + CRLF) //"    Calculando frete mínimo por romaneio considerando quantidade da mercadoria..."

								// Verificar a diferença entre a maior quantidade mínima e a quantidade total do romaneio
								If len(aFreteSemMin) > 0
									nQtCalcRom	:= 0
									nValFrete	:= 0
									for nX:= 1 to Len(aFreteSemMin)
										nQtCalcRom += aFreteSemMin[nX,6]
										nValFrete += aFreteSemMin[nX,2]
									next

									oGFEXFBFLog:setTexto(STR0161 + cValToChar(nMaiorQtMin) + STR0162 + cValToChar(nQtCalcRom) + "): " + cValToChar(nMaiorQtMin - nQtCalcRom) + CRLF) //"    Diferença entre maior quantidade mínima ("###") e quantidade total do agrupador ("

									If (nMaiorQtMin - nQtCalcRom) > 0
										oGFEXFBFLog:setTexto(STR0163 + CRLF) //"    Obtendo tarifa de maior valor baseada na diferença..."

										aMaiorTarifa := GFEMaiorTarifa(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),nMaiorQtMin - nQtCalcRom)

										oGFEXFBFLog:setTexto(STR0164 + cValToChar(aMaiorTarifa[1]) + CRLF) //"    Tarifa obtida: "

										If Empty(aMaiorTarifa[2])
											oGFEXFBFLog:setTexto(" ***Não foi encontrado componente 'Frete Unidade' para considerar a maior tarifa para o frete mínimo por quantidade de mercadoria!!!" + CRLF) //" ***Não foi encontrado componente 'Frete Unidade' para considerar a maior tarifa!!!"
											GFEXFBAEC("GEN", 9)
											lError := .T.
										Else
											// Ratear o valor de frete obtido entre as unidades de cálculo, proporcional ao valor de frete de cada uma
											GFERaVlFr(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"), aMaiorTarifa[1], aFreteSemMin, @aParamComp,aTotCalc,aTotTre,(aMaiorTarifa[1] + nValFrete))

										EndIf
									Else
										oGFEXFBFLog:setTexto(STR0171 + CRLF) //"    Mantendo frete mínimo por entrega: total dos fretes, sem mínimo, é maior ou igual ao maior frete mínimo do romaneio."
									EndIf

								ElseIf len(aFreteSemMin) > 0
									oGFEXFBFLog:setTexto(STR0165 + CRLF)								 //"    Mantendo frete mínimo por entrega: quantidade total do romaneio é maior ou igual à maior quantidade mínima do romaneio."
								EndIf
							Else	// 1- por valor da mercadoria
								If len(aFreteSemMin) > 0

									nMaiorFrtComMin := 0
									nTotFrtSemMin   := 0
									For nX := 1 to len(aFreteSemMin)
										// ACUMULA O VALOR DO COMPONENTE CONFIGURADO COMO BASE DO FRETE MÍNIMO
										nTotFrtSemMin += aFreteSemMin[nX,5]
									Next nX

									oGFEXFBFLog:setTexto(STR0168 + cValToChar(nTotFrtSemMin) + CRLF) //"    Total dos fretes sem mínimo: "
									If (nVlFrMinTMai - nTotFrtSemMin) > 0

										oGFEXFBFLog:setTexto(STR0169 + cValToChar(nVlFrMinTMai) + STR0170 + cValToChar(nTotFrtSemMin) + "): " + cValToChar(nVlFrMinTMai - nTotFrtSemMin) + CRLF) //"    Diferença entre maior frete com mínimo ("###") e total dos fretes sem mínimo ("

										// Ratear a diferença de frete entre as unidades de cálculo, proporcional ao valor de frete de cada uma
										GFERaVlFr(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"), nVlFrMinTMai - nTotFrtSemMin, aFreteSemMin, @aParamComp,aTotCalc,aTotTre,nVlFrMinTMai)

									Else
										oGFEXFBFLog:setTexto(STR0171 + CRLF) //"    Mantendo frete mínimo por entrega: total dos fretes, sem mínimo, é maior ou igual ao maior frete mínimo do romaneio."
									EndIf
								EndIf
							EndIf
						Else
							oGFEXFBFLog:setTexto(STR0172 + CRLF) //"    Mantendo frete mínimo por entrega: nem todas as negociações da tabela (ou seus componentes) estão configuradas para cálculo do frete mínimo por romaneio."
						EndIf
					Else
						If lCalcServ == .F.
							oGFEXFBFLog:setTexto(Space(4) + STR0540 + CRLF) //"Frete mínimo por romaneio não foi aplicado aos cálculos."
						Else
							oGFEXFBFLog:setTexto(Space(4) + STR0540 + CRLF + Space(3) + " Devido a ser cálculo de serviço." + CRLF) //"Frete mínimo por romaneio não foi aplicado aos cálculos."
						EndIf
					EndIf

					/***********************************************/
					/****                FIM                   *****/
					/**** CALCULO DO FRETE MINIMO POR ROMANEIO *****/
					/***********************************************/

					/***********************************************/
					/******* CALCULO DO PEDAGIO POR ROMANEIO********/
					/***********************************************/
					oGFEXFBFLog:setTexto(CRLF + STR0173 + CRLF + CRLF) //"  # Verificando pedágio por romaneio..."

					If lAplicValRom .And. lCalcServ == .F.
						If cPedRomAnt == "2" // Pedagio por romaneio

							// Se o peso for do calculo ...
							If lPesPedIgual .AND. cPesPedAnt == "2"	// Peso do Calculo

								oGFEXFBFLog:setTexto(STR0174 + CRLF + CRLF) //"    Totalizando valores por unidade de cálculo."

								nQtde   := nVlMerc := nPesoCubado := nPesReal := nVolume := nQtdPesAlt := nVALLIQ := 0
								GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
								GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)

								cNrCalcAnt := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")
								while !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)
									If cNrCalcAnt != GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")
										// Registrar os valores acumulados por cálculo no array
										aAdd(aValCalc,{cNrCalcAnt,nQtde,nVlMerc,nPesoCubado,nPesReal,nVolume,nQtdPesAlt, nVALLIQ})
										nQtde := nVlMerc := nPesoCubado := nPesReal := nVolume := nQtdPesAlt := nVALLIQ := 0
									EndIf

									// acumular os valores das negociações
									nQtde      += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE")
									nVlMerc    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR")
									nPesoCubado    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESCUB")
									nPesReal   += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR")
									nVolume    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME")
									nQtdPesAlt += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDALT")
									cNrCalcAnt := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")
									nVALLIQ    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALLIQ")

									GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
								EndDo
								aAdd(aValCalc,{cNrCalcAnt,nQtde,nVlMerc,nPesoCubado,nPesReal,nVolume,nQtdPesAlt,nVALLIQ})

								oGFEXFBFLog:setTexto(STR0175 + CRLF) //"    # Verificando faixas de cálculo para as negociações..."

								// Pesquisa da faixa da tabela baseando-se nas quantidades acumuladas por calculo
								GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
								GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
								while !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)

									oGFEXFBFLog:setTexto(CRLF + STR0176 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP") + STR0177 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB") + STR0178+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG") + STR0092 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV") + STR0069 +;
										GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA") + ")" + CRLF) //"      Verificando Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "

									nPos := aScan(aValCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")})
									If nPos > 0 .AND. GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"TPLOTA") == "1" // Carga Fracionada

										oGFEXFBFLog:setTexto(STR0179 + CRLF) //"      Determinando nova faixa para a tarifa..."
										oGFEXFBFLog:setTexto(STR0180 + GFEFldInfo("GV2_ATRCAL",IIf(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")=="10","8",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")),2)) //"      Atributo Faixa : "

										GV2->(dbSetOrder(01))
										GV2->(dbSeek(xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")))
										cIDVLAG := "1"
										If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
											cIDVLAG := "1"
										Else
											cIDVLAG := GV2->GV2_IDVLAG											
										EndIf
										nQtdeFaixa := GFEQtdeComp(	GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),;
											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC") ,;
											""                ,;
											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI") ,;
											aValCalc[nPos,2]  ,;
											aValCalc[nPos,5]  ,;
											aValCalc[nPos,3]  ,;
											aValCalc[nPos,8]  ,; //VALLIQ
										aValCalc[nPos,6]  ,;
											Posicione("GV9",1,xFilial("GV9")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG"),"GV9_QTKGM3"),;
											0                 ,;
											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"UNIFAI") ,;
											aValCalc[nPos,7],;
											0,;
											cIDVLAG,;
											GetTpEntr( cTpLocEntr,cIDVLAG),;
											GFEXFBLOCE( GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC") ),;
											lUtlFrMin ,;
											,,;
											IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))

										oGFEXFBFLog:setTexto(STR0181 + cValToChar(nQtdeFaixa) + CRLF) //" - Qtde. "

										// Verifica se houve mudança de faixa e ajusta a negociacao
										GV7->(dbSetOrder(01))
										GV7->(dbSeek(xFilial("GV7")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG"),.T.))
										While !GV7->(Eof()) .And. ;
												GV7->GV7_FILIAL == xFilial("GV7")   .And. ;
												GV7->GV7_CDEMIT == GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP") .And. ;
												GV7->GV7_NRTAB  == GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB") .And. ;
												GV7->GV7_NRNEG  == GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")

											If nQtdeFaixa <= GV7->GV7_QTFXFI
												oGFEXFBFLog:setTexto(STR0182 + GV7->GV7_CDFXTV + STR0183 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV") + STR0184 + GV7->GV7_UNICAL + CRLF) //"      Faixa Encontrada "###"; Faixa Atual "###"; Unid. Calc. "

												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV", GV7->GV7_CDFXTV)
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC", nQtdeFaixa)
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"UNICAL", GV7->GV7_UNICAL)
												Exit
											EndIf

											GV7->(dbSkip())
										EndDo
									EndIf
									GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
								EndDo
							Else
								oGFEXFBFLog:setTexto(STR0185 + CRLF) //"    Considerando valores por negociação."
							EndIf

							//Se for por negociação
							If lPesPedIgual .AND. cPesPedAnt == "1"
								GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
								GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
								While !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)

									nQtde := 0
									// Obter os dados para calculo do componente
									GV1->(dbSetOrder(01))
									If GV1->(dbSeek(xFilial("GV1")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")))

										oGFEXFBFLog:setTexto(CRLF + STR0186 + CRLF + CRLF) //"    # Calculando valor de pedágio..."
										oGFEXFBFLog:setTexto(STR0187 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP") + STR0177 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB") + STR0178 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG") + STR0092 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV") +;
											STR0069 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA") + ")" + CRLF) //"      Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
										oGFEXFBFLog:setTexto(STR0104 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP") + CRLF) //"      Componente "

										GV2->(dbSetOrder(01))
										GV2->(dbSeek(xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")))
										cIDVLAG := "2"

										cAtrComp := GV2->GV2_ATRCAL
										cUnitiliz := IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,'')

										// Quantidade minima da tarifa
										nQtdeMin  := Posicione("GV6",1,xFilial("GV6")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA"),"GV6_QTMIN")

										oGFEXFBFLog:setTexto(STR0188 + GFEFldInfo("GV9_TPLOTA",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"TPLOTA"),2) +;
											STR0189 + GFEFldInfo("GV2_ATRCAL",IIf(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")=="10","8",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")),2) + CRLF) //"      Tipo Lotação: "###"; Atributo Faixa: "

										// Verifica se há valores acumulados por unidade de cálculo. Se não houver, utiliza os valores da tabela
										IF Empty(aValCalc)
											oGFEXFBFLog:setTexto(STR0195) //"      Obtendo qtde. por negociação..."
											nQtde  := GFEQtdeComp(	GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR"),;
												cAtrComp,;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALLIQ"),;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME"),;
												Posicione("GV9",1,xFilial("GV9")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG"),"GV9_QTKGM3"),;
												,;
												,;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDALT"),;
												0,;
												cIDVLAG,;
												If(!Empty( cTpLocEntr),'1',''),; //Valor é sempre por romaneio e não por entrega(IDVLAG)
												,;
													lUtlFrMin,;
													,,;
													cUnitiliz)
											EndIf

											oGFEXFBFLog:setTexto(CRLF + STR0197 + GFEFldInfo("GV2_ATRCAL", GV2->GV2_ATRCAL, 2) + STR0198 + cValToChar(nQtde) + CRLF) //"      Atributo Componente: "###" - Qtde. cálculo: "

											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED",GFEVlComp({GV1->GV1_CDCOMP,GV1->GV1_VLFIXN,GV1->GV1_PCNORM,GV1->GV1_VLUNIN,GV1->GV1_VLFRAC,GV1->GV1_VLMINN,GV1->GV1_VLLIM,GV1->GV1_VLFIXE,GV1->GV1_PCEXTR,GV1->GV1_VLUNIE,GV1->GV1_CALCEX},nQtde,0))
											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC",nQtde)
											oGFEXFBFLog:setTexto(STR0199 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")) + CRLF) //"      Valor de pedágio: "
										EndIf
										GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
									EndDo

									lPedRomNeg := .F.

								EndIf

								If lPedRomNeg
									//Nao executa se entrou no pedagio por negociacao
									// Calcular o pedagio para cada negociacao
									GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
									GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
									While !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)

										nQtde := 0
										// Obter os dados para calculo do componente
										GV1->(dbSetOrder(01))
										If GV1->(dbSeek(xFilial("GV1")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA")+;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")))

											oGFEXFBFLog:setTexto(CRLF + STR0186 + CRLF + CRLF) //"    # Calculando valor de pedágio..."
											oGFEXFBFLog:setTexto(	STR0187 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")  + ;
												STR0177 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")  + ;
												STR0178 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")  + ;
												STR0092 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV") + ;
												STR0069 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA") + ")" + CRLF) //"      Tarifa (Transp. "###"; Tab. "###"; Neg. "###"; Faixa "###"; Rota "
											oGFEXFBFLog:setTexto(STR0104 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP") + CRLF) //"      Componente "

											GV2->(dbSetOrder(01))
											GV2->(dbSeek(xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")))
											cIDVLAG := "1"
											If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
												cIDVLAG := "1"
											Else
												cIDVLAG := GV2->GV2_IDVLAG												
											EndIf
											cAtrComp := GV2->GV2_ATRCAL
											cUnitiliz := IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,'')

											// Quantidade minima da tarifa
											nQtdeMin  := Posicione("GV6",1,xFilial("GV6")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRROTA"),"GV6_QTMIN")

											oGFEXFBFLog:setTexto(STR0188 + GFEFldInfo("GV9_TPLOTA",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"TPLOTA"),2) +;
												STR0189 + GFEFldInfo("GV2_ATRCAL",IIf(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")=="10","8",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI")),2) + CRLF) //"      Tipo Lotação: "###"; Atributo Faixa: "

											If GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"TPLOTA") == "1" .AND. GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"ATRFAI") == cAtrComp

												nQtdeCalc := GFEConvUM(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"UNIFAI"),GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"UNICAL"),GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC"))
												nQtde     := IF(nQtdeMin < nQtdeCalc, nQtdeCalc, nQtdeMin)

												oGFEXFBFLog:setTexto(STR0191 + cValToChar(nQtdeCalc) + STR0192 + cValToChar(nQtdeMin) + CRLF) //"      Qtde. atual: "###"; Qtde. Mínima: "
												oGFEXFBFLog:setTexto(IF(nQtdeMin < nQtdeCalc, STR0193 + cValToChar(nQtdeCalc), STR0194 + cValToChar(nQtdeMin)) + CRLF) //"      Usando qtde. atual: "###"      Usando qtde. mínima: "
											Else
												// Verifica se há valores acumulados por unidade de cálculo. Se não houver, utiliza os valores da tabela
												IF Empty(aValCalc)
													oGFEXFBFLog:setTexto(STR0195) //"      Obtendo qtde. por negociação..."
													nQtde  := GFEQtdeComp(	GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR"),;
														cAtrComp,;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALLIQ"),;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME"),;
														Posicione("GV9",1,xFilial("GV9")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG"),"GV9_QTKGM3"),;
														,;
														,;
														GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDALT"),;
														0,;
														cIDVLAG,;
														GetTpEntr( cTpLocEntr,cIDVLAG),;
														GFEXFBLOCE( GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC") ),;
														lUtlFrMin,;
														,,;
														cUnitiliz)
												Else
													// Obtem a quantidade para cálculo com os valores acumulados por cálculo
													nPos := aScan(aValCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")})
													if nPos > 0
														oGFEXFBFLog:setTexto(STR0196) //"      Obtendo qtde. por unidade de cálculo..."
														nQtde  := GFEQtdeComp(	GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"),;
															GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC"),;
															"",;
															cAtrComp,;
															aValCalc[nPos,2],; // Quantidade
														aValCalc[nPos,5],; // Peso Real
														aValCalc[nPos,3],; // Valor da mercadoria
														aValCalc[nPos,8],; // VALLIQ
														aValCalc[nPos,6],; // Volume ocupado
														Posicione("GV9",1,xFilial("GV9")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTRP")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRTAB")+GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRNEG"),"GV9_QTKGM3"),;
															,;
															,;
															aValCalc[nPos,7],;
															0,;
															cIDVLAG,;
															GetTpEntr( cTpLocEntr,cIDVLAG),;
															GFEXFBLOCE( GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC") ),;
															lUtlFrMin,;
															,,;
															cUnitiliz)
													EndIf
												EndIf
											EndIf

											oGFEXFBFLog:setTexto(CRLF + STR0197 + GFEFldInfo("GV2_ATRCAL", GV2->GV2_ATRCAL, 2) + STR0198 + cValToChar(nQtde) + CRLF) //"      Atributo Componente: "###" - Qtde. cálculo: "

											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED",GFEVlComp({GV1->GV1_CDCOMP,GV1->GV1_VLFIXN,GV1->GV1_PCNORM,GV1->GV1_VLUNIN,GV1->GV1_VLFRAC,GV1->GV1_VLMINN,GV1->GV1_VLLIM,GV1->GV1_VLFIXE,GV1->GV1_PCEXTR,GV1->GV1_VLUNIE,GV1->GV1_CALCEX},nQtde,0))
											GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC",nQtde)
											oGFEXFBFLog:setTexto(STR0199 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")) + CRLF) //"      Valor de pedágio: "
										EndIf
										GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
									EndDo

								EndIf

								// Selecionar o maior valor de pedágio
								nVlMaiorPed := nQtde := nPesReal := nPesoCubado := nVlMerc := nVolume := 0
								GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
								GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
								While !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)
									If nVlMaiorPed < GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")
										nVlMaiorPed := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")
									EndIf

									// Acumula os valores
									nQtde      += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE")
									nPesReal   += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR")
									nPesoCubado    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESCUB")
									nVlMerc    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR")
									nVolume    += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME")
									GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
								EndDo

								// Ratear entre os cálculos
								If nVlMaiorPed > 0

									oGFEXFBFLog:setTexto(CRLF + STR0200 + cValToChar(nVlMaiorPed) + CRLF) //"    # Rateando maior valor de pedágio: "

									// Obtem o criterio de rateio do sistema
									nMaiorPerc := nTotPed := 0

									oGFEXFBFLog:setTexto(STR0154 + GFEDsCriRat(cCriRat) + CRLF) //"      Critério de rateio: "

									GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
									GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
									While !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)
										Do Case
										Case cCriRat == "1"	// Peso
											If nPesReal > nPesoCubado
												oGFEXFBFLog:setTexto(STR0201 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR")) + STR0202 + cValToChar(nPesReal)) //"      Peso Real Negoc.: "###"; Peso Real Total: "
												nPerc := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESOR") / nPesReal
											Else
												oGFEXFBFLog:setTexto(STR0203 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESCUB")) + STR0204 + cValToChar(nPesoCubado)) //"      Peso Cub. Negoc.: "###"; Peso Cub. Total: "
												nPerc := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"PESCUB") / nPesoCubado
											EndIf
										Case cCriRat == "2" // Valor Mercadoria
											oGFEXFBFLog:setTexto(STR0205 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR")) + STR0206 + cValToChar(nVlMerc)) //"      Valor Merc. Negoc.: "###"; Valor Merc. Total: "
											nPerc := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VALOR") / nVlMerc
										Case cCriRat == "3" // Volume(M3)
											oGFEXFBFLog:setTexto(STR0207 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME")) + STR0208 + cValToChar(nVolume)) //"      Volume Negoc.: "###"; Volume Total: "
											nPerc := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VOLUME") / nVolume
										Case cCriRat == "4" // Qtde
											oGFEXFBFLog:setTexto(STR0209 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE")) + STR0210 + cValToChar(nQtde)) //"      Qtde. Negoc.: "###"; Qtde. Total: "
											nPerc := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTDE") / nQtde
										EndCase

										// Atualiza o valor do pedagio com o valor rateado
										GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED",Round(nVlMaiorPed * nPerc,2))
										nTotPed += GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")

										if nPerc >= nMaiorPerc
											nMaiorPerc := nPerc
											nRecMaior  := GFEXFB_GRECNO(lTabTemp, cTRBPED, 10)
										EndIf

										oGFEXFBFLog:setTexto(STR0211 + cValToChar(nPerc*100) + STR0212 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")) + CRLF) //"; Percentual: "###"; Valor pedágio: "
										GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
									EndDo

									//Acerto das diferencas de arredondamento: soma a diferenca na parcela de maior valor
									IF nVlMaiorPed <> nTotPed
										GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
										GFEXFB_HGOTO(lTabTemp, cTRBPED, 10, nRecMaior)
										GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED") + (nVlMaiorPed - nTotPed))
									EndIf

									// Aplicação do novo valor nos cálculos
									// Tratar situacoes onde não ha o componente pedagio na negociacao: utilizar o primeiro encontrado
									oGFEXFBFLog:setTexto(CRLF + STR0213 + CRLF) //"    # Aplicando valores de pedágio nas unidades de cálculo..."
									GFEXFB_BORDER(lTabTemp,cTRBPED,01,10)
									GFEXFB_2TOP(lTabTemp, cTRBPED, @aTRBPED, 10)
									While !GFEXFB_3EOF(lTabTemp, cTRBPED, @aTRBPED, 10)

										oGFEXFBFLog:setTexto(STR0214 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC") + STR0054 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR") + STR0215 + GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTPOP") + CRLF) //"      Unid. Calc. "###"; Class.Frete "###"; Tipo Oper. "
										GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
										If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC"), ;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR"), ;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTPOP"), ;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")})
											oGFEXFBFLog:setTexto(STR0216 + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCOMP")) + STR0217 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")) + CRLF) //"      Atualizando componente "###" -> Valor: "
											GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED"))
										Else
											// Criar um componente no calculo para receber o valor de pedagio rateado
											// O array aCompPed foi atribuido com o primeiro componente de pedagio identificado
											oGFEXFBFLog:setTexto(STR0218 + AllTrim(aCompPed[_CDCOMP]) + STR0217 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")) + CRLF) //"      Criando novo componente "###" -> Valor: "
											IF lTabTemp
												RecLock(cTRBCCF,.T.)
												(cTRBCCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")
												(cTRBCCF)->CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR")
												(cTRBCCF)->CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTPOP")
												(cTRBCCF)->CDCOMP := aCompPed[_CDCOMP]
												(cTRBCCF)->CATVAL := aCompPed[_CATVAL]
												(cTRBCCF)->VALOR  := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED")   // Usa o valor calculado na rotina
												(cTRBCCF)->QTDE   := GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC")	// Usa a quantidade obtida na rotina
												(cTRBCCF)->TOTFRE := aCompPed[_TOTFRE]
												(cTRBCCF)->BASIMP := aCompPed[_BASIMP]
												(cTRBCCF)->BAPICO := aCompPed[_BAPICO]
												(cTRBCCF)->FREMIN := aCompPed[_FREMIN]
												(cTRBCCF)->IDMIN  := "2"
												(cTRBCCF)->(MsUnLock())
											Else
												aAdd(aTRBCCF1,{	GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC"),;
													GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDCLFR"),;
													GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"CDTPOP"),;
													Space(04),;
													aCompPed[_CDCOMP],;
													aCompPed[_CATVAL],;
													GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"QTCALC"),;
													GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"VLPED"),;
													aCompPed[_TOTFRE],;
													aCompPed[_BASIMP],;
													aCompPed[_BAPICO],;
													aCompPed[_FREMIN],;
													"2",;
													0,;
													"0",;
													Space(6),;
													Space(1)})
											EndIf

											// Adiciona o componente no array de parametros, prevalecendo os parametros ativos
											GFEParamComp({aCompPed[_CDCOMP],;
												aCompPed[_TOTFRE], ;
												aCompPed[_BASIMP], ;
												aCompPed[_BAPICO], ;
												aCompPed[_FREMIN], ;
												GFEXFB_5CMP(lTabTemp, cTRBPED, @aTRBPED, 10,"NRCALC")},;
												@aParamComp)
										EndIf
										GFEXFB_8SKIP(lTabTemp, cTRBPED, 10)
									EndDo
								Else
									oGFEXFBFLog:setTexto(STR0219 + CRLF) //"    Não há valor de pedágio a ratear para o romaneio."
								EndIf
							Else
								oGFEXFBFLog:setTexto("    Pedágio por romaneio não habilitado." + CRLF) //"    Pedágio por romaneio não habilitado."
							EndIf
						Else
							If lCalcServ == .F.
								oGFEXFBFLog:setTexto(Space(4) + STR0541 + CRLF) //"Pedágio por romaneio não foi aplicado aos cálculos."
							Else
								oGFEXFBFLog:setTexto(Space(4) + STR0541 + CRLF + Space(3) + " Devido a ser cálculo de serviço." + CRLF) //"Pedágio por romaneio não foi aplicado aos cálculos."
							EndIf
						EndIf

						// elimina os registros do arquivo temporario de pedagio
						If lTabTemp
							GFEDelTbData(cTRBPED) //Deleção da tabela temporária
						Else
							IIF(aTRBPED==NIL,,aSize(aTRBPED,0))
							aTRBPED := {}
						EndIf

						If !lAplicValRom
							GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
							GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
							While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
								GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
								If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

									If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SEQ") == "01"

										If Empty(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTRP"))
											lAplicViag := .F.
										EndIf

										Exit
									EndIf

								EndIf
								GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
							EndDo

						EndIf

						/***********************************************/
						/********   CALCULO DO FRETE VIAGEM     ********/
						/***********************************************/
						// Verificar se todas as tabelas calculam frete viagem
						oGFEXFBFLog:setTexto(CRLF + STR0221 + CRLF + CRLF) //"  # Verificando frete viagem..."
						If (lAplicValRom .Or. lAplicViag) .And. !lCalcServ

							If lFreViaIgual .AND. cFreViaAnt == "1"

								oGFEXFBFLog:setTexto(STR0222 + CRLF) //"    Frete Viagem selecionado. Verificando tipo de geração e quantidade de cálculos..."

								// Verificar o tipo de valor para cálculo e a quantidade de cálculos
								If lTipValIgual .AND. lQtdCalIgual

									oGFEXFBFLog:setTexto(STR0223 + GFEFldInfo("GV9_TIPVAL",cTipValAnt,2) + CRLF) //"    Tipo de geração.: "
									oGFEXFBFLog:setTexto(STR0224 + GFEFldInfo("GV9_QTDCAL",cQtdCalAnt,2) + CRLF) //"    Qtde de cálculos: "

									If cTipValAnt == "1" // Maior calculo

										// Escolhe a unidade de cálculo de maior valor.
										nMaiorValor := nRecnoMaior := 0
										nQtde       := nVlMerc     := nPesoCubado := nPesReal := nVolume := 0
										aValCalc    := {}
										aNrCalSel 	:= {}

										oGFEXFBFLog:setTexto(CRLF + STR0225 + CRLF) //"    # Selecionando unidade de cálculo de maior valor..."
										GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
										If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})

											While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

												oGFEXFBFLog:setTexto(CRLF + STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0226 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") + CRLF) //"      Unidade de cálculo "###", Agrupador "

												// Transportador do trecho é igual ao transportador do romaneio
												lTrpTrecho := GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

												// Transportadores do trecho diferente do romaneio não são considerados
												// ou Transportador igual ao trecho desde que não seja o primeiro trecho
												If !lTrpTrecho .OR. (lTrpTrecho .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != "01" )
													oGFEXFBFLog:setTexto(STR0227 + CRLF) //"        Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
													Loop
												EndIf

												nVlFrete := 0

												//Posicoes do array: [1] Nr Calculo, [2] Qtde, [3] VlMerc, [4] Peso Cub, [5] Peso Real, [6] Volume, [7] Valor de Frete, [8] Val Liq
												aAdd(aValCalc,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),0,0,0,0,0,0,0,GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})

												// Identifica o maior valor de frete
												GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
												If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

													// Agrupando o valor total de cada unidade
													nPos := 0
													aUnidAux := {}
													For nX := 1 to Len(aTRBCCF1)
														nPos := aScan(aUnidAux, {|x| x[1] == aTRBCCF1[nX][1]} )
														If nPos > 0
															aUnidAux[nPos][2] += aTRBCCF1[nX][8]
															aUnidAux[nPos][3] += 1
														Else
															aadd(aUnidAux,{aTRBCCF1[nX][1], aTRBCCF1[nX][8], 1})
														EndIf
													Next

													aSort(aUnidAux,,, { |x,y| x[2] < y[2] })

													//Somatória do valor dos componentes das unidade de cálculo
													nPos := 0
													While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

														nVlFrete += IF(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE")=="1",GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"),0)
														nPos := aScan(aCompMaior, {|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .And. x[3] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")} )
														If nPos > 0
															If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") > aCompMaior[nPos,2]
																aCompMaior[nPos,2] := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
															EndIf
														Else
															aAdd(aCompMaior,{GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
														EndIf

														GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
													EndDo

													nPos:= 0
													nPos := aScan(aValCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
													If nPos > 0
														aValCalc[nPos,7] := nVlFrete
													EndIf
												EndIf

												oGFEXFBFLog:setTexto("		Trecho do Cálculo de Frete : " + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") + CRLF)
												oGFEXFBFLog:setTexto(STR0228 + cValToChar(nVlFrete) + CRLF) //"        Valor de frete corrente    : "

												nPos := 0
												nPos := aScan(aNrCalSel,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
												If nPos > 0
													oGFEXFBFLog:setTexto(STR0229 + cValToChar(aNrCalSel[nPos][3]) + CRLF) 						 //"        Maior valor atual          : "

													If nVlFrete > aNrCalSel[nPos][3]
														aNrCalSel[nPos][2] := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
														aNrCalSel[nPos][3] := nVlFrete
													EndIf

													oGFEXFBFLog:setTexto(STR0230 + cValToChar(aNrCalSel[nPos][3]) + CRLF) //"        Maior valor após comparação: "
													oGFEXFBFLog:setTexto(STR0231 + aNrCalSel[nPos][2] + CRLF) //"        Unid. cálculo maior valor  : "
												Else
													aAdd(aNrCalSel,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),nVlFrete})
													oGFEXFBFLog:setTexto(STR0230 + cValToChar(nVlFrete) + CRLF) //"        Maior valor após comparação: "
													oGFEXFBFLog:setTexto(STR0231 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + CRLF) //"        Unid. cálculo maior valor  : "
												EndIf

												// Acumula os valores das unidades de cálculo, para utilizar no rateio, se necessario
												GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
												if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
													While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
														nPos := aScan(aValTot,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
														If nPos > 0
															aValTot[nPos][2] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
															aValTot[nPos][3] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
															aValTot[nPos][4] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
															aValTot[nPos][5] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
															aValTot[nPos][6] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
														Else
															Aadd(aValTot, {GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE"),;
																GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
																GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
																GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
																GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
																GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")})
														EndIf

														nPos := aScan(aValCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
														If nPos > 0
															aValCalc[nPos,2] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
															aValCalc[nPos,3] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
															aValCalc[nPos,4] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
															aValCalc[nPos,5] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
															aValCalc[nPos,6] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
														EndIf

														GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
													EndDo
												EndIf

												GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
											EndDo
										EndIf

										If cQtdCalAnt == "1" 	// Um cálculo por romaneio
											GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
											If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
												While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

													// Transportador do trecho é igual ao transportador do romaneio
													lTrpTrecho := GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

													// Considera apenas as unidades de cálculo do transportador do romaneio
													If !lTrpTrecho .OR. (lTrpTrecho .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != "01" )
														oGFEXFBFLog:setTexto(STR0227 + CRLF) //"        Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													nPos := 0
													nPos := aScan(aNrCalSel,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
													If nPos > 0
														oGFEXFBFLog:setTexto(CRLF + STR0232 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + "..." + CRLF) //"    # Consolidando as unidades de cálculo do agrupador na unidade de cálculo "

														If aNrCalSel[nPos][2] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
															oGFEXFBFLog:setTexto("		Unidade de cálculo consolida frete viagem" + CRLF)

															GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"IDFRVI","1")	// Unidade de calculo consolida frete viagem
														Else
															oGFEXFBFLog:setTexto(STR0233 + aNrCalSel[nPos][2] + CRLF) //"        Vinculando documentos de carga à unidade de cálculo "
															GFETratUniCal(GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6),aNrCalSel[nPos][2],.F.)

															// Unidade de calculo será eliminada pois foi vinculada a outra
															GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"IDFRVI","3")
														EndIf
													EndIf

													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
												EndDo
											EndIf
										ElseIf cQtdCalAnt == "2" // um cálculo por entrega

											oGFEXFBFLog:setTexto(CRLF + STR0234 + CRLF + CRLF) //"    # Rateando maior valor de frete entre as unidades de cálculo do agrupador."

											// O valor será rateado entre as todas as unidades de cálculo do romaneio, de acordo com critério definido no sistema (MV_CRIRAT).
											oGFEXFBFLog:setTexto(STR0235 + GFEDsCriRat(cCriRat) + CRLF) //"      Critério de rateio      : "

											// Identifica o maior valor de frete
											For nX := 1 to Len( aTRBCCF1 )
												If aTRBCCF1[nX][1] == aTail(aUnidAux)[1]
													nPos := aScan(aCompMaior, {|x| x[1] == aTRBCCF1[nX][5]} )
													If nPos > 0
														aCompMaior[nPos][2] := aTRBCCF1[nX][8]
													EndIf
												EndIf
											Next

											GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
											if GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
												While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU") //;

													oGFEXFBFLog:setTexto(CRLF + STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0226 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") + CRLF) //"      Unidade de cálculo "###", Agrupador "

													// Considera apenas as unidades de cálculo do transportador do romaneio
													If !GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))
														oGFEXFBFLog:setTexto(STR0237 + CRLF) //"          Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													If (nPos := aScan(aValCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})) > 0
														nPosMaior := 0
														nPosMaior := aScan(aValTot,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
														If nPosMaior > 0

															Do Case
															Case cCriRat == "1"	// Peso
																If aValTot[nPosMaior][5] > aValTot[nPosMaior][4]
																	nPerc := aValCalc[nPos,5] / aValTot[nPosMaior][5]
																Else
																	nPerc := aValCalc[nPos,4] / aValTot[nPosMaior][4]
																EndIf
															Case cCriRat == "2" // Valor Mercadoria
																nPerc := aValCalc[nPos,3] / aValTot[nPosMaior][3]
															Case cCriRat == "3" // Volume(M3)
																nPerc := aValCalc[nPos,6] / aValTot[nPosMaior][6]
															Case cCriRat == "4" // Qtde
																nPerc := aValCalc[nPos,2] / aValTot[nPosMaior][2]
															EndCase

															nPosCalc := 0
															nPosCalc := aScan(aNrCalSel,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
															If nPosCalc > 0
																nVlFrete := ROUND(aNrCalSel[nPosCalc][3] * nPerc,2)
																oGFEXFBFLog:setTexto(STR0239 + cValTochar(nPerc * 100) + CRLF) //"        Percentual de rateio   : "
																oGFEXFBFLog:setTexto(STR0240 + cValToChar(nVlFrete) + CRLF + CRLF) //"        Novo valor de frete    : "
															EndIf
														EndIf

														// Definindo o valor da parcela de cada cálculo, este deve ser distribuido proporcionamente entre os componentes da unidade de cálculo.
														oGFEXFBFLog:setTexto(STR0241 + CRLF + CRLF) //"        Aplicando novo valor de frete aos componentes da unid. cálculo, proporcional ao valor original ..."
														GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
														if GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
															nAuxComp   := 1
															nAuxValCpt := 0
															While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
																	GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

																cAuxNrCalc := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")
																nPos := aScan(aCompMaior, {|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .And. x[3] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")} )
																If nPos > 0
																	nValCpt  := aCompMaior[nPos,2]
																	nPosCalc := aScan(aNrCalSel,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})
																	If nPosCalc > 0


																		nPos := aScan(aUnidAux, {|x| x[1] == cAuxNrCalc} )
																		If nPos > 0 .And. aUnidAux[nPos][3] == 1
																			oGFEXFBFLog:setTexto(STR0242 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ": " + cValToChar(nVlFrete) + " * ( " + cValToChar(aNrCalSel[nPosCalc][3]) + " / " + cValToChar(aNrCalSel[nPosCalc][3]) + " ) = ") //"        Componente "
																			GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",(nVlFrete * (aNrCalSel[nPosCalc][3] / aNrCalSel[nPosCalc][3])))
																		ElseIf nPos > 0 .And. aUnidAux[nPos][3] > 1
																			oGFEXFBFLog:setTexto(STR0242 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ": " + cValToChar(nVlFrete) + " * ( " + cValToChar(nValCpt) + " / " + cValToChar(aNrCalSel[nPosCalc][3]) + " ) = ") //"        Componente "
																			If nAuxComp == aUnidAux[nPos][3]
																				//oGFEXFBFLog:setTexto(STR0242 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ": " + cValToChar(nVlFrete) + " - " + cValToChar(nAuxValCpt) + " = ") //"        Componente "
																				GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",(nVlFrete - nAuxValCpt))
																			Else
																				GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",(nVlFrete * (nValCpt / aNrCalSel[nPosCalc][3])))
																				nAuxValCpt += (nVlFrete * (nValCpt / aNrCalSel[nPosCalc][3]))
																			EndIf
																		EndIf
																		oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF)
																	EndIf

																	nAuxComp += 1
																	GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
																EndIf
															EndDo
														EndIf
													EndIf

													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
												EndDo
											EndIf
										EndIf
									ElseIf cTipValAnt == "2" // Maior Tarifa

										oGFEXFBFLog:setTexto(CRLF + STR0243 + CRLF + CRLF) //"    # Selecionando maior tarifa baseado nos componentes de categoria Frete Unidade..."

										// Escolhe a tarifa cujo componente "Frete Unidade" dê o maior resultado com a mesma quantidade.
										aInfoTarifa := GFEMaiorTarifa(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU"), 1 /* Qtde. referencia */,.T.)
										cNrCalcSel  := ""

										If Empty(aInfoTarifa[2])
											oGFEXFBFLog:setTexto(" ***Não foi encontrado componente 'Frete Unidade' para considerar a maior tarifa!!!" + CRLF) //" ***Não foi encontrado componente 'Frete Unidade' para considerar a maior tarifa!!!"
											GFEXFBAEC("GEN", 10)
											lError := .T.
										ElseIf cQtdCalAnt == "1" //Um cálculo por Romaneio

											oGFEXFBFLog:setTexto("    # Um cálculo por Romaneio, somando todos valores do cálculo para aplicar na maior tarifa." + CRLF)  //    # Um cálculo por Romaneio, somando todos valores do cálculo para aplicar na maior tarifa.
											// Soma todos os valores dos cálculo para ser calculado o valor dos componentes da maior tarifa
											GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
											if GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
												While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

													oGFEXFBFLog:setTexto(CRLF + STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0226 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") + CRLF) //"      Unidade de cálculo "###", Agrupador "

													// Transportador do trecho é igual ao transportador do romaneio
													lTrpTrecho := GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

													// Transportadores do trecho diferente do romaneio não são considerados
													// ou Transportador igual ao trecho desde que não seja o primeiro trecho
													If !lTrpTrecho .OR. (lTrpTrecho .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != "01" )
														oGFEXFBFLog:setTexto(STR0227 + CRLF) //"        Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
													If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
														While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

															oGFEXFBFLog:setTexto( CRLF + STR0245 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") +;
																STR0067 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") +;
																STR0246 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") +;
																STR0069 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") +;
																STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + ") " + CRLF)
															//"        Tarifa corrente    (Transp. "###"; Tabela "###"; Negoc "###"; Rota "###"; Faixa "

															aInfoTab := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))

															GV9->(dbSetOrder(1) )
															If GV9->(dbSeek(xFilial("GV9") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )

																GV7->(dbSetOrder(1) )
																If GV7->(dbSeek(xFilial("GV7") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")) )

																	If Empty(aValFV)
																		aValFV := {	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
																			GV9->GV9_QTKGM3,;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB"),;
																			GV7->GV7_UNICAL,;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),;
																			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),;
																			}
																	Else
																		aValFV[1]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
																		aValFV[2]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
																		aValFV[3]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
																		aValFV[4]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
																		aValFV[6]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
																		aValFV[8]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT")
																		aValFV[9]  += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC")
																		aValFV[10] += GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ")
																	EndIf
																EndIf

															EndIf

															GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
														EndDo
													EndIf

													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
												EndDo
											EndIf

											// Posiciona a tabela TRBTCF na tarifa selecionada pela função GFEMaiorTarifa
											GFEXFB_HGOTO(lTabTemp, cTRBTCF, 5, aInfoTarifa[2])

											cNrCalcSel := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
											GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
											GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNrCalcSel})

											oGFEXFBFLog:setTexto( STR0247 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") +;
												STR0067 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") +;
												STR0246 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") +;
												STR0069 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") +;
												STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + ") " + CRLF)
											//"        Tarifa selecionada (Transp. "###"; Tabela "###"; Negoc "###"; Rota "###"; Faixa "

											oGFEXFBFLog:setTexto(STR0248 + cValToChar(nQtde) + CRLF + CRLF) //"        Quantidade p/ cálculo : "

											// Guarda o log até aqui
											cTxtLogAux := cTxtLog

											// Calcula os componentes considerando a tarifa da função GFEMaiorTarifa com a quantidade da tarifa corrente
											aComponentes := GFECalcComp(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;  // Unidade de calculo
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	 // Classificacao de frete
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;	 // Tipo de operacao
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;	 // Código do transportador
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"),;	 // Numero da tabela
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),;	 // Numero da negociacao
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;	 // Codigo da faixa/tipo de veiculo
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;	 // Numero da rota
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;	 // Código do tipo de veiculo
											aValFV[9],,,aValFV,,lUtlFrMin)      // Quantidade para calculo (tarifa corrente)

											// Restaura o Log a partir do ponto salvo, ignorando as mensagens geradas na função GFECalcComp
											cTxtLog := cTxtLogAux + STR0249 + CRLF + CRLF //"        Componentes calculados com a tarifa selecionada."

											// Substituir os componentes atuais da unidade de cálculo pelos novos componentes.
											//1. apagar componentes atuais
											oGFEXFBFLog:setTexto(STR0250 + CRLF) //"        Eliminando componentes da tarifa corrente..."
											GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
											If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
												While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9);
														.And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC");
														.And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") == "01"

													oGFEXFBFLog:setTexto(STR0251 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + STR0105 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "

													// elimina o componente do array de parametros
													nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})
													if nPos > 0
														aDel(aParamComp,nPos)
														aSize(aParamComp,len(aParamComp)-1)
													EndIf

													if lTabTemp
														(cTRBCCF)->(dbDelete())
													Else
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
													EndIf
													GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
												EndDo
											EndIf

											//2. criar novos componentes
											oGFEXFBFLog:setTexto(CRLF + STR0252 + CRLF) //"        Vinculando os componentes calculados à tarifa corrente..."
											For nX := 1 to len(aComponentes)

												oGFEXFBFLog:setTexto(STR0251 + aComponentes[nX,_CDCOMP] + STR0105 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + STR0046 + cValToChar(aComponentes[nX,_VALOR]) + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "###", Valor "

												IF lTabTemp
													RecLock(cTRBCCF,.T.)
													(cTRBCCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
													(cTRBCCF)->CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
													(cTRBCCF)->CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
													(cTRBCCF)->CDCOMP := aComponentes[nX,_CDCOMP]
													(cTRBCCF)->CATVAL := aComponentes[nX,_CATVAL]
													(cTRBCCF)->VALOR  := aComponentes[nX,_VALOR]
													(cTRBCCF)->QTDE   := aComponentes[nX,_QTDE]
													(cTRBCCF)->TOTFRE := aComponentes[nX,_TOTFRE]
													(cTRBCCF)->BASIMP := aComponentes[nX,_BASIMP]
													(cTRBCCF)->BAPICO := aComponentes[nX,_BAPICO]
													(cTRBCCF)->FREMIN := aComponentes[nX,_FREMIN]
													(cTRBCCF)->IDMIN  := "2"
													(cTRBCCF)->CPEMIT := aComponentes[nX,9]
													(cTRBCCF)->(MsUnLock())
												Else
													aAdd(aTRBCCF1,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
														GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
														GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
														Space(04),;
														aComponentes[nX,_CDCOMP],;
														aComponentes[nX,_CATVAL],;
														aComponentes[nX,_QTDE],;
														aComponentes[nX,_VALOR],;
														aComponentes[nX,_TOTFRE],;
														aComponentes[nX,_BASIMP],;
														aComponentes[nX,_BAPICO],;
														aComponentes[nX,_FREMIN],;
														"2",;
														0,;
														"0",;
														Space(6),;
														aComponentes[nX,9]})
												EndIf

												// Atualizar os parâmetros dos componentes
												GFEParamComp({	aComponentes[nX,_CDCOMP],;
													aComponentes[nX,_TOTFRE],;
													aComponentes[nX,_BASIMP],;
													aComponentes[nX,_BAPICO],;
													aComponentes[nX,_FREMIN],;
													GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")},;
													@aParamComp)
											Next nX

											// Eliminar componentes sem classificação de frete e tipo de operação
											oGFEXFBFLog:setTexto(CRLF + STR0253 + CRLF) //"        Eliminando os componentes restantes da tarifa corrente..."
											GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
											If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"),;
													PadR("",4),;
													PadR("",10)})
												While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == PadR("",4) .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == PadR("",10) .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CPEMIT") == "0"
													oGFEXFBFLog:setTexto(STR0251 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ;
														STR0105 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + ;
														STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") + ;
														STR0046 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "###", Valor "
													IF lTabTemp
														(cTRBCCF)->(dbDelete())
													Else
														GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
													EndIf
													GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
												EndDo
											EndIf

											if !lTabTemp
												aTRBCCF2 := aClone(aTRBCCF1)
												aTRBCCF1 := {}
												For nX := 1 to len(aTRBCCF2)
													if aTRBCCF2[nX,15] == "0"
														AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
															aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
															aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
													EndIf
												Next Nx
												aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
											EndIf

											// Seleciona a unidade de calculo para consolidar as demais
											GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
											If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNrCalcSel})
												GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"IDFRVI","1")	// Unidade de calculo consolida frete viagem
												If !lTabTemp
													// como houve alteração nas informações, é necessário ajustar todos os outros arrays com indices diferentes.
													aTRBUNC2 := aClone(aTRBUNC1)
													aTRBUNC3 := aClone(aTRBUNC1)
													aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
													aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
												EndIf
											EndIf

											oGFEXFBFLog:setTexto(CRLF + STR0254 + cNrCalcSel + CRLF)  //"    # Consolidando cálculos do agrupador na unidade de cálculo "

											GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
											if GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
												While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

													If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") == cNrCalcSel
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													oGFEXFBFLog:setTexto(CRLF + STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0226 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") + CRLF) //"      Unidade de cálculo "###", Agrupador "

													// Transportador do trecho é igual ao transportador do romaneio
													lTrpTrecho := GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

													// Considera apenas as unidades de cálculo do transportador do romaneio
													If !lTrpTrecho .OR. (lTrpTrecho .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != "01" )
														If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") != cNrCalcSel
															oGFEXFBFLog:setTexto(STR0227 + CRLF) //"        Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
														EndIf
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													// Vincula os documentos de carga e os componentes da unidade de cálculo corrente
													// à unidade de cálculo informada
													oGFEXFBFLog:setTexto(STR0255 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0256 + cNrCalcSel + CRLF) //"        Vinculando documentos de carga e componentes da unid. calculo "###" a unid. calculo "
													GFETratUniCal(GFEXFB_GRECNO(lTabTemp, cTRBUNC, 6),cNrCalcSel,.T.,aParamComp)

													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
												EndDo
											EndIf

										Else  //Um cálculo por entrega

											oGFEXFBFLog:setTexto(STR0244 + CRLF)  //"    # Aplicando a maior tarifa nas unidades de cálculo do agrupador..."
											// Aplica esta tarifa para todas as unidades de cálculo.
											GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
											If GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
												While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. ;
														GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

													oGFEXFBFLog:setTexto(CRLF + STR0155 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + STR0226 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") + CRLF) //"      Unidade de cálculo "###", Agrupador "

													// Transportador do trecho é igual ao transportador do romaneio
													lTrpTrecho := GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))

													// Transportadores do trecho diferente do romaneio não são considerados
													// ou Transportador igual ao trecho desde que não seja o primeiro trecho
													If !lTrpTrecho .OR. (lTrpTrecho .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != "01" )
														oGFEXFBFLog:setTexto(STR0227 + CRLF) //"        Transportador da unid. cálculo difere do transportador do agrupador. Passando à próxima unidade de cálculo..."
														GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
														Loop
													EndIf

													If Empty(cNrCalcSel)
														cNrCalcSel := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
													EndIf

													GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
													If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
														While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

															oGFEXFBFLog:setTexto( CRLF + STR0245 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") +;
																STR0067 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") +;
																STR0246 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") +;
																STR0069 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") +;
																STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + ") " + CRLF)
															//"        Tarifa corrente    (Transp. "###"; Tabela "###"; Negoc "###"; Rota "###"; Faixa "

															aInfoTab := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))

															// Busca a quantidade de cálculo
															GV9->(dbSetOrder(1) )
															If GV9->(dbSeek(xFilial("GV9") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")) )

																GV7->(dbSetOrder(1) )
																If GV7->(dbSeek(xFilial("GV7") + aInfoTab[2] + aInfoTab[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")) )

																	aValFV := {	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
																		GV9->GV9_QTKGM3,;
																		nPesoCubado,;
																		GV7->GV7_UNICAL,;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTCALC"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ") ;
																		}
																EndIf

															EndIf

															// Salva a posicao do registro da tarifa corrente
															aAreaTCF := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5)

															// Posiciona a tabela TRBTCF na tarifa selecionada pela função GFEMaiorTarifa
															GFEXFB_HGOTO(lTabTemp, cTRBTCF, 5, aInfoTarifa[2])

															oGFEXFBFLog:setTexto( STR0247 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") +;
																STR0067 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") +;
																STR0246 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG") +;
																STR0069 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA") +;
																STR0092 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV") + ") " + CRLF)
															//"        Tarifa selecionada (Transp. "###"; Tabela "###"; Negoc "###"; Rota "###"; Faixa "

															oGFEXFBFLog:setTexto(STR0248 + cValToChar(nQtde) + CRLF + CRLF) //"        Quantidade p/ cálculo : "

															// Guarda o log até aqui
															cTxtLogAux := cTxtLog

															// Calcula os componentes considerando a tarifa da função GFEMaiorTarifa com a quantidade da tarifa corrente
															aComponentes := GFECalcComp(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;  // Unidade de calculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;	 // Classificacao de frete
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;	 // Tipo de operacao
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),;	 // Código do transportador
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"),;	 // Numero da tabela
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"),;	 // Numero da negociacao
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV"),;	 // Codigo da faixa/tipo de veiculo
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA"),;	 // Numero da rota
															GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC"),;	 // Código do tipo de veiculo
															aValFV[9],,,aValFV,, lUtlFrMin) // Quantidade para calculo (tarifa corrente)

															// Restaura a posicao do registro para a tarifa corrente
															GFEXFB_ARESTAREA(lTabTemp,aAreaTCF,5) //RestArea(aAreaTCF)

															// Restaura o Log a partir do ponto salvo, ignorando as mensagens geradas na função GFECalcComp
															cTxtLog := cTxtLogAux + STR0249 + CRLF + CRLF //"        Componentes calculados com a tarifa selecionada."

															// Substituir os componentes atuais da unidade de cálculo pelos novos componentes.
															//1. apagar componentes atuais
															oGFEXFBFLog:setTexto(STR0250 + CRLF) //"        Eliminando componentes da tarifa corrente..."
															GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
															If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), ;
																	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")})
																While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
																		GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .AND. ;
																		GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") .AND. ;
																		GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

																	oGFEXFBFLog:setTexto(STR0251 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ;
																		STR0105 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + ;
																		STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "

																	// elimina o componente do array de parametros
																	nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. ;
																		x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})
																	if nPos > 0
																		aDel(aParamComp,nPos)
																		aSize(aParamComp,len(aParamComp)-1)
																	EndIf

																	IF lTabTemp
																		(cTRBCCF)->(dbDelete())
																	Else
																		GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
																	EndIf
																	GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
																EndDo
															EndIf

															//2. criar novos componentes
															oGFEXFBFLog:setTexto(CRLF + STR0252 + CRLF) //"        Vinculando os componentes calculados à tarifa corrente..."
															For nX := 1 to len(aComponentes)

																oGFEXFBFLog:setTexto(STR0251 + aComponentes[nX,_CDCOMP] + STR0105 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + STR0106 + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + STR0046 + cValToChar(aComponentes[nX,_VALOR]) + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "###", Valor "
																if lTabTemp
																	RecLock(cTRBCCF,.T.)
																	(cTRBCCF)->NRCALC := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")
																	(cTRBCCF)->CDCLFR := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
																	(cTRBCCF)->CDTPOP := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
																	(cTRBCCF)->CDCOMP := aComponentes[nX,_CDCOMP]
																	(cTRBCCF)->CATVAL := aComponentes[nX,_CATVAL]
																	(cTRBCCF)->VALOR  := aComponentes[nX,_VALOR]
																	(cTRBCCF)->QTDE   := aComponentes[nX,_QTDE]
																	(cTRBCCF)->TOTFRE := aComponentes[nX,_TOTFRE]
																	(cTRBCCF)->BASIMP := aComponentes[nX,_BASIMP]
																	(cTRBCCF)->BAPICO := aComponentes[nX,_BAPICO]
																	(cTRBCCF)->FREMIN := aComponentes[nX,_FREMIN]
																	(cTRBCCF)->IDMIN  := "2"
																	(cTRBCCF)->CPEMIT := aComponentes[nX,9]
																	(cTRBCCF)->(MsUnLock())
																Else
																	aAdd(aTRBCCF1,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
																		GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
																		Space(04),;
																		aComponentes[nX,_CDCOMP],;
																		aComponentes[nX,_CATVAL],;
																		aComponentes[nX,_QTDE],;
																		aComponentes[nX,_VALOR],;
																		aComponentes[nX,_TOTFRE],;
																		aComponentes[nX,_BASIMP],;
																		aComponentes[nX,_BAPICO],;
																		aComponentes[nX,_FREMIN],;
																		"2",;
																		0,;
																		"0",;
																		Space(6),;
																		aComponentes[nX,9]})
																EndIf

																// Atualizar os parâmetros dos componentes
																GFEParamComp({aComponentes[nX,_CDCOMP],;
																	aComponentes[nX,_TOTFRE],;
																	aComponentes[nX,_BASIMP],;
																	aComponentes[nX,_BAPICO],;
																	aComponentes[nX,_FREMIN],;
																	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")},;
																	@aParamComp)
															Next nX
															GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
														EndDo
													EndIf

													// Eliminar componentes sem classificação de frete e tipo de operação
													oGFEXFBFLog:setTexto(CRLF + STR0253 + CRLF) //"        Eliminando os componentes restantes da tarifa corrente..."
													GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
													If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), PadR("",4), PadR("",10)})
														While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") .AND. ;
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == PadR("",4) .AND. ;
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == PadR("",10) .AND. ;
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CPEMIT") == "0"

															oGFEXFBFLog:setTexto(STR0251 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ;
																STR0105 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") + ;
																STR0106 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") + ;
																STR0046 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //"          Componente "###", Class. Frete "###", Tipo Oper. "###", Valor "

															if lTabTemp
																(cTRBCCF)->(dbDelete())
															Else
																GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
															EndIf
															GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
														EndDo
													EndIf

													if !lTabTemp
														aTRBCCF2 := aClone(aTRBCCF1)
														aTRBCCF1 := {}
														For nX := 1 to len(aTRBCCF2)
															if aTRBCCF2[nX,15] == "0"
																AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
																	aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
																	aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
															EndIf
														Next Nx
														aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
													EndIf

													GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
												EndDo
											EndIf
										EndIf

										If !lTabTemp
											aTRBUNC1 := {}
											For nX := 1 to len(aTRBUNC2)
												if aTRBUNC2[nX,25] == "0"
													AADD(aTRBUNC1, {aTRBUNC2[nx,01], aTRBUNC2[nx,02], aTRBUNC2[nx,03], aTRBUNC2[nx,04], aTRBUNC2[nx,05], aTRBUNC2[nx,06], aTRBUNC2[nx,07],;
														aTRBUNC2[nx,08], aTRBUNC2[nx,09], aTRBUNC2[nx,10], aTRBUNC2[nx,11], aTRBUNC2[nx,12], aTRBUNC2[nx,13], aTRBUNC2[nx,14],;
														aTRBUNC2[nx,15], aTRBUNC2[nx,16], aTRBUNC2[nx,17], aTRBUNC2[nx,18], aTRBUNC2[nx,19], aTRBUNC2[nx,20], aTRBUNC2[nx,21],;
														aTRBUNC2[nx,22], aTRBUNC2[nx,23], aTRBUNC2[nx,24], aTRBUNC2[nx,25], aTRBUNC2[nx,26], aTRBUNC2[nx,27], aTRBUNC2[nx,28],;
														aTRBUNC2[nx,29], aTRBUNC2[nx,30], aTRBUNC2[nx,31], aTRBUNC2[nx,32], aTRBUNC2[nx,33], aTRBUNC2[nx,34]})
												EndIf
											Next Nx
											aTRBUNC2 := aClone(aTRBUNC1)
											aTRBUNC3 := aClone(aTRBUNC1)
											aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
											aSort(aTRBUNC2  ,,,{|x,y| x[19]+x[01]       < y[19]+y[01]})
											aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
										EndIf

									EndIf
								Else
									oGFEXFBFLog:setTexto(STR0257 + CRLF) //"    Frete Viagem não calculado. Tipo de geração ou quantidade de cálculos não são iguais entre as tabelas."
								EndIf
							Else
								oGFEXFBFLog:setTexto(STR0258 + CRLF) //"    Frete Viagem não habilitado. Nem todas as tabelas calculam frete desta forma."
							EndIf
						Else
							If lCalcServ
								oGFEXFBFLog:setTexto(Space(4) + STR0542 + CRLF + Space(3) +  " Devido a ser cálculo de serviço." + CRLF) //"Frete Viagem não foi aplicado aos cálculos."
							Else
								oGFEXFBFLog:setTexto(Space(4) + STR0542 + CRLF) //"Frete Viagem não foi aplicado aos cálculos."
							EndIf
						EndIf


						If !lTabTemp
							aTRBTRE2 := aClone(aTRBTRE1)
							aTRBTRE3 := aClone(aTRBTRE1)
							aTRBTRE4 := aClone(aTRBTRE1)
							aSort(aTRBTRE1,,,{|x,y| x[18]                         < y[18]})
							aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
							aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
							aSort(aTRBTRE4,,,{|x,y| x[17]+x[03]+x[05]+x[15]+x[16] < y[17]+y[03]+y[05]+y[15]+y[16]})
						EndIf

						//
						//			Calculo de carga compartilhada.
						//
						GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
						GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})

						If !lSimulacao

							If Empty(cNrRom)
								cNrRom := Padr(aAgrFrt[1][1],Len(GWN->GWN_NRROM))
							EndIf

							If !Empty(cNrRom) .And. ( (GWN->GWN_FILIAL == xFilial('GWN') .And. GWN->GWN_NRROM == cNrRom) .Or. GWN->(msSeek(xFilial('GWN') + cNrRom))) .And. ;
									TemCrgComp(.F.)
								oGFEXFBFLog:setTexto("Realizando ajuste da carga compartilhada" + CRLF)
								While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")

									If GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") != '01'
										GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
										Loop
									EndIf

									oGFEXFBFLog:setTexto("Nr. Calc. " + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + CRLF)
									GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
									GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
									aCompSem := {}
									While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
										GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
										If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")})

											oGFEXFBFLog:setTexto(" Clas. Frete. " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + " Tp. Oper. " + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") + CRLF)
											While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")

												If ! ((GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") .Or. Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR"))) .AND. ;
														(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP") .Or. Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP"))))
													GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
													Loop
												EndIf

												If aScan(aValDiaria,{|x| x[1] == '01' .And. AllTrim(x[2]) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")) .And. AllTrim(x[4]) == AllTrim(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP")) } ) > 0
													If aScan(aCompSem,{|x|x == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")}) > 0
														GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
														Loop
													Endif
													aAdd(aCompSem,GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"))
												EndIf

												cAlBkp := Alias()
												GV2->(dbSetOrder(01))
												GV2->(msSeek(xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") ))

												If !Empty(cAlBkp)
													dbSelectArea(cAlBkp)
												EndIf

												oGFEXFBFLog:setTexto("Componente " + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + ' - atributo ' + GFEFldInfo("GV2_ATRCAL", GV2->GV2_ATRCAL, 2) + CRLF)

												If GFXCP1212410("GV2_RTCCOM")
													nPerc := ClcPercRed(GV2->GV2_ATRCAL, GV2->GV2_RTCCOM)// retornar o percentual de redução do componente posicionado conforme o atributo do cálculo
												Else
													nPerc := ClcPercRed(GV2->GV2_ATRCAL)// retornar o percentual de redução do componente posicionado conforme o atributo do cálculo
												EndIf

												oGFEXFBFLog:setTexto("Redução de " + cValToChar(nPerc*100) + "% sobre " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + ' = ' + cValToChar(ABS(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") * (1 - nPerc))) + CRLF)

												If Empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE"))
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE",ABS(1 - nPerc))
												Else
													GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE",ABS(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE") * (1 - nPerc)))
												EndIf

												GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", ABS(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") * (1 - nPerc)))
												GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
											EndDo
										EndIf
										GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
									EndDo
									GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
								EndDo

							EndIf

						EndIf

						//
						//			Fim Calculo de carga compartilhada.
						//

						If lPEXFB13 // P.E. calcular taxa de entrega // Jacson - 08/08/2017
							aRetPE  := ExecBlock("GFEXFB13")
						endif

						/***********************************************/
						/*****    CALCULO DE RATEIO DE PEDÁGIO     *****/
						/***********************************************/
						If GFXCP12117("GV9_DESPED")
							oGFEXFBFLog:setTexto(CRLF + "  # Verificando rateio de desconto de pedágio..." + CRLF) //"  # Verificando rateio de desconto de pedágio..."
							If !lCalcServ
								GWN->(dbSetOrder(1) )
								If GWN->(dbSeek(xFilial("GWN") + aAgrFrt[1][1]) )
									nVlrPed := GWN->GWN_VPVAL
								EndIf

								lError := CalcRatPed(@aParamComp, nVlrPed, GWN->GWN_NRROM)

							Else
								oGFEXFBFLog:setTexto(CRLF + "  # Sistema não parametrizado para rateio de desconto de pedágio." + CRLF) //"    Pedágio por romaneio não habilitado."
							EndIf
							
							If lPEXFB19 
								lError  := ExecBlock("GFEXFB19",.f.,.f.,{ @aParamComp, lSimulacao })			
							endif									
							
						EndIf

						/***********************************************/
						/********      CALCULO DE IMPOSTOS     *********/
						/***********************************************/
						// É feito neste ponto em função das mudanças que podem ocorrer
						// por conta do pedagio por romaneio e do frete minimo por romaneio

						GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC2, 6)
						GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")})
						While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,"NRAGRU")
							oGFEXFBFLog:setTexto(CRLF + STR0259 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") + CRLF + CRLF) //"  # Calculando impostos da unid. cálculo "

							// Ajusta os trechos do calculo base, vinculando-os temporariamente ao calculo corrente
							If lSimulacao .AND. iTipoSim == 0
								GFEAjusTre(.T.)	// .T. - Vincula o trecho ao cálculo simulado corrente, .F. - Retorna o trecho ao calculo original
							EndIf

							If cvaltochar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")) == ""
								GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC2, 6)
							EndIf

							// Calcula o imposto para cada negociacao/tcf da unidade de calculo
							GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
							If GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
								While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5);
										.And. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC")

									// Caso a tabela da negociacao seja de vinculo, retorna os dados da tabela base
									aInfoTab   := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))
									cCdTrpBase := aInfoTab[2]
									cNrTabBase := aInfoTab[3]

									If lRatClass
										aCdClFr := {GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")}
									EndIf
									
									If lClcCfgTrb
										GFEClcImpCT(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), aParamComp, aCdClFr[1],aCdClFr[2], cCdTrpBase)
									Else
										GFECalcImp(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"), cNrTabBase, GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG"), aParamComp, aCdClFr[1],aCdClFr[2], cCdTrpBase)
									EndIf

									GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
									If !lRatClass
										Exit
									Else
										oGFEXFBFLog:setTexto(CRLF)
									EndIf
								EndDo
							EndIf

							// Ajusta os trechos do calculo base, vinculando-os temporariamente ao calculo corrente
							If lSimulacao .AND. iTipoSim == 0
								GFEAjusTre(.F.)	// .T. - Vincula o trecho ao cálculo simulado corrente, .F. - Retorna o trecho ao calculo original
							EndIf
							GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
						EndDo
						GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
					EndDo	// Agrupador de Carga (romaneio)

					If !lTabTemp
						// como houve alteração nas informações, é necessário ajustar todos os outros arrays com indices diferentes.
						aTRBUNC1 := aClone(aTRBUNC2)
						aTRBUNC3 := aClone(aTRBUNC2)
						aSort(aTRBUNC1  ,,,{|x,y| x[01]             < y[01]})
						aSort(aTRBUNC3  ,,,{|x,y| x[19]+x[21]+x[01] < y[19]+y[21]+y[01]})
					EndIf

					// Elimina o arquivo temporário de pedagio
					If lTabTemp
						GFEDelTbData(cTRBPED) //Deleção da tabela temporária				
					EndIf

					/***************************************************
					FIM DO CALCULO DE FRETE PROPRIAMENTE DITO
					****************************************************/

					oGFEXFBFLog:setTexto(CRLF + STR0260 + CRLF + CRLF) //"# Valor de frete total por unidade de cálculo"

					aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})

					GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
					GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
					while !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
						nVlFrete := 0
						GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
						if GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")})
							While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC")

								nVlFrete += IF(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE")=="1",GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"),0)
								
								// Se for "NÃO" em todas as opções, não há porque gravar o componente no cálculo
								if  GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"TOTFRE") == "2" .AND.;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BASIMP") == "2" .AND.;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"BAPICO") == "2" .AND.;
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"FREMIN") == "2"

									if lTabTemp
										(cTRBCCF)->(dbDelete())
									Else
										GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
									EndIf
								EndIf
								GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
							EndDo
						EndIf

						oGFEXFBFLog:setTexto(STR0261 + GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC") + STR0262 + cValToChar(nVlFrete) + CRLF) //"  Unid.Cálculo: "###" -> Valor Frete: "

						If nVlFrete == 0 .And. !lSimulacao .And. !IsInCallStack("GFEA032CA") .And. !lCalcServ
							GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRCALC"), 25)
							lError := .T.
						EndIf
						GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
					EndDo

					if !lTabTemp
						aTRBCCF2 := aClone(aTRBCCF1)
						aTRBCCF1 := {}
						For nX := 1 to len(aTRBCCF2)
							if aTRBCCF2[nX,15] == "0"
								AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
									aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
									aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
							EndIf
						Next Nx
						aTRBCCF3 := aClone(aTRBCCF1)
						aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
						aSort(aTRBCCF3  ,,,{|x,y| x[01]+x[02]+x[03]+x[04]      < y[01]+y[02]+y[03]+y[04]})
					Endif

					IF lSaveLog
						// Listar no Log o conteudo das tabelas temporárias geradas
						oGFEXFBFLog:setTexto(CRLF + STR0263 + CRLF) //"# Dados gerados nos arquivos temporários..."

						oGFEXFBFLog:setTexto(CRLF + STR0264 + '- aDBFAGR ' + CRLF) //"  > Agrupadores de Carga"
						for nX := 1 to len(aDBFAGR)
							oGFEXFBFLog:setTexto(cValToChar(aDBFAGR[nX,1]) + IF(nX < Len(aDBFAGR), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBAGRU, 1,0)
						GFEXFB_2TOP(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
						while !GFEXFB_3EOF(lTabTemp, cTRBAGRU, @aAgrFrt, 0)
							For nX := 1 To Len(aDBFAGR)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBAGRU, @aAgrFrt, 0,aDBFAGR[nX,1])) + IF(nX < Len(aDBFAGR), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBAGRU, 0)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0265 + '- aDBFDOC ' + CRLF) //"  > Documentos de Carga"
						for nX := 1 to len(aDBFDOC)
							oGFEXFBFLog:setTexto(cValToChar(aDBFDOC[nX,1]) + IF(nX < Len(aDBFDOC), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1)
						GFEXFB_2TOP(lTabTemp, cTRBDOC, @aDocCarg, 1)
						while !GFEXFB_3EOF(lTabTemp, cTRBDOC, @aDocCarg, 1)
							For nX := 1 To Len(aDBFDOC)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,aDBFDOC[nX,1])) + IF(nX < Len(aDBFDOC), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBDOC, 1)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0266 + '- aDBFTRE '+ CRLF) //"  > Trechos do Documento de Carga"
						for nX := 1 to len(aDBFTRE)
							oGFEXFBFLog:setTexto(cValToChar(aDBFTRE[nX,1]) + IF(nX < Len(aDBFTRE), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
						GFEXFB_2TOP(lTabTemp, cTRBTRE, @aTRBTRE1, 7)
						while !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7)
							For nX := 1 To Len(aDBFTRE)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,aDBFTRE[nX,1])) + IF(nX < Len(aDBFTRE), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0267 + '- aDBFITE ' + CRLF) //"  > Itens do Documento de Carga"
						for nX := 1 to len(aDBFITE)
							oGFEXFBFLog:setTexto(cValToChar(aDBFITE[nX,1]) + IF(nX < Len(aDBFITE), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
						GFEXFB_2TOP(lTabTemp, cTRBITE, @aTRBITE1, 8)
						while !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8)
							For nX := 1 To Len(aDBFITE)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,(aDBFITE[nX,1]))) + IF(nX < Len(aDBFITE), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBITE, 8)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0268 + '- aDBFGRU ' + CRLF) //"  > Agrupamentos de Entrega"
						for nX := 1 to len(aDBFGRU)
							oGFEXFBFLog:setTexto(cValToChar(aDBFGRU[nX,1]) + IF(nX < Len(aDBFGRU), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(.F.,,01,4)
						GFEXFB_2TOP(.F., , @aTRBGRB1, 4)
						while !GFEXFB_3EOF(.F.,, @aTRBGRB1, 4)
							For nX := 1 To Len(aDBFGRU)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(.F.,, @aTRBGRB1, 4,(aDBFGRU[nX,1]))) + IF(nX < Len(aDBFGRU), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(.F.,, 4)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0269 + '- aDBFUNC ' + CRLF) //"  > Unidades de Cálculo"
						for nX := 1 to len(aDBFUNC)
							oGFEXFBFLog:setTexto(cValToChar(aDBFUnc[nX,1]) + IF(nX < Len(aDBFUnc), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
						GFEXFB_2TOP(lTabTemp, cTRBUNC, @aTRBUNC1, 6)
						while !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC1, 6) //
							For nX := 1 To Len(aDBFUnc)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,(aDBFUnc[nX,1]))) + IF(nX < Len(aDBFUnc), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0270 + '- aDBFTCF ' + CRLF) //"  > Tabelas da Unidade de Cálculo"
						for nX := 1 to len(aDBFTCF)
							oGFEXFBFLog:setTexto(cValToChar(aDBFTCF[nX,1]) + IF(nX < Len(aDBFTCF), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
						GFEXFB_2TOP(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
						while !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5)
							For nX := 1 To Len(aDBFTCF)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,(aDBFTCF[nX,1]))) + IF(nX < Len(aDBFTCF), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
						enddo

						oGFEXFBFLog:setTexto(CRLF + STR0271 + '- aDBFCCF ' + CRLF) //"  > Componentes da Unidade de Cálculo"
						for nX := 1 to len(aDBFCCF)
							oGFEXFBFLog:setTexto(cValToChar(aDBFCCF[nX,1]) + IF(nX < Len(aDBFCCF), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
						GFEXFB_2TOP(lTabTemp, cTRBCCF, @aTRBCCF1, 9)
						while !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9)
							For nX := 1 To Len(aDBFCCF)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,(aDBFCCF[nX,1]))) + IF(nX < Len(aDBFCCF), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
						enddo

						oGFEXFBFLog:setTexto(CRLF + "Locais de entrega - aDBFENT" + CRLF) //"  > LOCAIS da Unidade de Cálculo"
						for nX := 1 to len(aDBFENT)
							oGFEXFBFLog:setTexto(cValToChar(aDBFENT[nX,1]) + IF(nX < Len(aDBFENT), "|", CRLF),,.F.)
						next nX
						GFEXFB_BORDER(lTabTemp,cTRBENT,01,12)
						GFEXFB_2TOP(lTabTemp, cTRBENT, @aTRBENT1, 12)
						while !GFEXFB_3EOF(lTabTemp, cTRBENT, @aTRBENT1, 12)
							For nX := 1 To Len(aDBFENT)
								oGFEXFBFLog:setTexto(cValToChar(GFEXFB_5CMP(lTabTemp, cTRBENT, @aTRBENT1, 12,(aDBFENT[nX,1]))) + IF(nX < Len(aDBFENT), "|", CRLF),,.F.)
							Next nX
							GFEXFB_8SKIP(lTabTemp, cTRBENT, 12)
						enddo

					ENDIF
					Return nil	//FIM GFECalcFrete()


/*----------------------------------------------------------------------------
Calcula os impostos incidentes no calculo de frete
----------------------------------------------------------------------------*/
Static Function GFECalcImp(cNrCalc, cCdTrp, cNrTab, cNrNeg, aParamComp, cCdclfr, cCdtpop, cCdTrpBase)

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
			If !IsInCallStack("GFEA032CA")
				oGFEXFBFLog:setTexto("    # Cálculo de serviço para romaneio com imposto de ISS. Tipo de imposto ISS (Definido no cadastro de tipo de ocorrência): " + cServTpImp + " [1:ICMS ou ISS, conforme cidade origem x destino, 2: Cidade origem, 3: Cidade destino]" + CRLF + CRLF)
			Else
				oGFEXFBFLog:setTexto("    # Cálculo de serviço para ocorrência com imposto de ISS. Tipo de imposto ISS (Definido no cadastro de tipo de ocorrência): " + cServTpImp + " [1:ICMS ou ISS, conforme cidade origem x destino, 2: Cidade origem, 3: Cidade destino]" + CRLF + CRLF)
			EndIf
			cTpImposto := "2"
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

					aRetICMS := GFEFnIcms(cTmpTrp, ; // Código do transportador
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

Return // fim GFECalcImp


/*----------------------------------------------------------------------------
{Protheus.doc} GFEVlBasComp
Retorna array com os valores que serão usados para total do frete, base para imposto por classificação/tipo de operação, base para PIS/COFINS por classificação/tipo de operação
e comparação com o frete minimo

Uso: GFEVlBasComp(cNrCalc, aParComp)

@param  cNrCalc     Número da unidade de calculo
@param  aParComp    Array com os componentes e seus parametros de calculo de frete minimo

O 2o parametro é um array de 5 posições, cada qual armazenando os seguintes valores:
1 - Codigo do componente
2 - Se componente soma no total do frete
3 - Se componente é base para imposto (ISS/ICMS)
4 - Se componente é base para PIS/COFINS
5 - Se componente é considerado na comparação do frete minimo
6 - Numero da unidade de calculo

@sample GFEVlBasComp(cNrCalc,aParComp)

@author Luciano de Araujo
@since 19/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEVlBasComp(cNrCalc, aParComp, cCdclfr, cCdtpop)

	Local aValor := {0,0,0,0,0}
	Local nPos   := 0

	Default cCdclfr := ""
	Default cCdtpop := ""

	GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
	GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{cNrCalc})
	while !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .And. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == cNrCalc

		nPos := aScan(aParComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC")})
		// Componente do cálculo existe no array de parametros ou informado classificação de frete/tipo de operação
		IF nPos > 0  .And. ( Empty(cCdclfr) .Or. cCdclfr == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") );
				.And. ( Empty(cCdtpop) .Or. cCdtpop == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") )

			If aParComp[nPos,2] == "1" // Considera componente no total do frete
				aValor[1] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

				If aParComp[nPos,3] == "1" // Considera componente na base de ICMS/ISS
					aValor[2] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
				EndIf

				If aParComp[nPos,4] == "1" // Considera componente na base de PIS/COFINS
					aValor[3] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
				EndIf
			EndIf

			If aParComp[nPos,5] == "1" // Considera componente na comparação do frete minimo
				aValor[4] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
				If AllTrim(Posicione("GV2", 1, xFilial("GV2") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"), "GV2_ATRCAL")) $ "1;4;5;10;"
					//AQUI
					aValor[5] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE")
				EndIf
			EndIf
		EndIf
		GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
	EndDo

Return aValor


/*----------------------------------------------------------------------------
{Protheus.doc} GFEPISCOF
Função que verifica quais itens fazem parte para a soma dos valores do PIS/COFINS

Uso: GFEPISCOF(cNrCalc)

@param  cNrCalc      Numero do Calculo

@sample GFEPISCOF("00000001")

@author Luiz Fernando Soares
@since 25/03/2010
@version 1.0
----------------------------------------------------------------------------*/
Function GFEPISCOF(cNRCalc)

	Local nPerPisCof := 0
	Local nPesPisCof := 0, nValPisCof := 0, nM3PisCof := 0, nQtdPisCof := 0
	Local nPesoTotal := 0, nValorTotal := 0, nM3Total := 0, nQtdTotal := 0
	Local cMV_CRIRAT := IIf(Empty(SuperGetMv("MV_CRIRAT",,"1")), "1", SuperGetMv("MV_CRIRAT",,"1"))
	Local cCredPCTF := GetNewPar("MV_PICOTR", "1", cFilAnt)
	Local lTribPC := .F.

	oGFEXFBFLog:setTexto("      Calculando percentual dos itens que fazem parte do PIS/COFINS. " + CRLF)
	oGFEXFBFLog:setTexto("      Critério utilizado: " + {"Peso","Valor","M3","Quantidade"}[Val(cMV_CRIRAT)] + CRLF)

	If Empty(cCredPCTF)
		cCredPCTF := "2"
	EndIf

	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
	GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNRCalc})

	GFEXFB_BORDER(lTabTemp,cTRBDOC,01,1) //	(cTRBDOC)->(dbSetOrder(2) )
	GFEXFB_CSEEK(lTabTemp, cTRBDOC, @aDocCarg, 1,{GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC"), ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC"), ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC") , ;
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC") })
	If GFEXFB_5CMP(lTabTemp, cTRBDOC, @aDocCarg, 1,"USO") == "1" .And. cCredPCTF == "1" .And. GWF->GWF_FINCAL != "3"
		lTribPC := .T.
	EndIf

	While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .And. cNRCalc == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC")
		//Identifica o documento origem e percorre seus itens
		GFEXFB_BORDER(lTabTemp,cTRBITE,01,8)
		GFEXFB_CSEEK(lTabTemp, cTRBITE, @aTRBITE1, 8,{	GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") , ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") , ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  , ;
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")})
		While !GFEXFB_3EOF(lTabTemp, cTRBITE, @aTRBITE1, 8) .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"CDTPDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"EMISDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"SERDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")   .And. ;
				GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"NRDC") == GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")

			If GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"TRIBP") == "1" .Or. lTribPC //verifica se credita PIS/COFINS
				nPesPisCof += IIf(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR") > GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC"), GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR"), GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC"))
				nValPisCof += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR")
				nM3PisCof  += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")
				nQtdPisCof += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE")
			EndIf

			nPesoTotal  += IIf(GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR") > GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC"), GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOR"), GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"PESOC"))
			nValorTotal += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VALOR")
			nM3Total    += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"VOLUME")
			nQtdTotal   += GFEXFB_5CMP(lTabTemp, cTRBITE, @aTRBITE1, 8,"QTDE")

			GFEXFB_8SKIP(lTabTemp, cTRBITE, 8)
		EndDo

		GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
	EndDo

	Do Case
	Case cMV_CRIRAT == "1" //peso
		oGFEXFBFLog:setTexto("      Total do Peso : " + AllTrim(Str(nPesoTotal)) + CRLF)
		oGFEXFBFLog:setTexto("      Total do Pis/Cofins : " + AllTrim(Str(nPesPisCof)) + CRLF)
		oGFEXFBFLog:setTexto("      Percentual dos itens: " + AllTrim(Str(nPesPisCof / nPesoTotal)) + " X 100 = " + AllTrim(Str(nPesPisCof / nPesoTotal * 100)) + "%" + CRLF)
		nPerPisCof := (nPesPisCof / nPesoTotal)
	Case cMV_CRIRAT == "2" //Valor
		oGFEXFBFLog:setTexto("      Total do Peso : " + AllTrim(Str(nValorTotal)) + CRLF)
		oGFEXFBFLog:setTexto("      Total do Pis/Cofins : " + AllTrim(Str(nValPisCof)) + CRLF)
		oGFEXFBFLog:setTexto("      Percentual dos itens: " + AllTrim(Str(nValPisCof / nValorTotal)) + " X 100 = " + AllTrim(Str(nValPisCof / nValorTotal * 100)) + "%" + CRLF)
		nPerPisCof := (nValPisCof / nValorTotal)
	Case cMV_CRIRAT == "3" //M3
		oGFEXFBFLog:setTexto("      Total do Peso : " + AllTrim(Str(nM3Total)) + CRLF)
		oGFEXFBFLog:setTexto("      Total do Pis/Cofins : " + AllTrim(Str(nM3PisCof)) + CRLF)
		oGFEXFBFLog:setTexto("      Percentual dos itens: " + AllTrim(Str(nM3PisCof / nM3Total)) + " X 100 = " + AllTrim(Str(nM3PisCof / nM3Total * 100)) + "%" + CRLF)
		nPerPisCof := (nM3PisCof / nM3Total)
	Case cMV_CRIRAT == "4" //Quantidade
		oGFEXFBFLog:setTexto("      Total do Peso : " + AllTrim(Str(nQtdTotal)) + CRLF)
		oGFEXFBFLog:setTexto("      Total do Pis/Cofins : " + AllTrim(Str(nQtdPisCof)) + CRLF)
		oGFEXFBFLog:setTexto("      Percentual dos itens: " + AllTrim(Str(nQtdPisCof / nQtdTotal)) + " X 100 = " + AllTrim(Str(nQtdPisCof / nQtdTotal * 100)) + "%" + CRLF)
		nPerPisCof := (nQtdPisCof / nQtdTotal)
	EndCase

	oGFEXFBFLog:setTexto(CRLF)

Return nPerPisCof

/*----------------------------------------------------------------------------
Grava o imposto no componente informado
----------------------------------------------------------------------------*/
Function GFEGrvComImp(cNrCalc, cCdComImp, nVlImposto, cTotFre, cBasImp, cBaPiCo, cFreMin, cIdMin, nVlFrMi, cCdclfr, cCdTpOp)
	Local aSeek
	Default cCdclfr := ""
	Default cCdTpOp := ""
	oGFEXFBFLog:setTexto("      Gravando o valor " + cValToChar(nVlImposto) + " como componente..." + CRLF)

	If Empty(cCdclfr)
		GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
		aSeek := {cNrCalc, cCdComImp}
	Else
		GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
		aSeek := {cNrCalc, cCdclfr, cCdTpOp, cCdComImp}
	EndIf

	If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9, aSeek) //NRCALC+CDCLFR+CDTPOP+CDCOMP
		GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + nVLImposto)
		oGFEXFBFLog:setTexto(STR0470 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + STR0471 + AllTrim(STR(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"))) + CRLF) //"      Componente Imposto encontrado: "###"; Valor: "
	Else
		//senao encontrou um componente entao cria um novo com o valor informado na negociação
		if lTabTemp
			RecLock(cTRBCCF,.T.)
			(cTRBCCF)->NRCALC := cNrCalc
			(cTRBCCF)->CDCOMP := cCdComImp
			(cTRBCCF)->CATVAL := Posicione("GV2",1,xFilial("GV2")+cCdComImp,"GV2_CATVAL")
			(cTRBCCF)->VALOR  := nVLImposto
			(cTRBCCF)->VLFRMI := nVlFrMi
			(cTRBCCF)->QTDE   := 0
			(cTRBCCF)->TOTFRE := cTotFre
			(cTRBCCF)->BASIMP := cBasImp
			(cTRBCCF)->BAPICO := cBaPiCo
			(cTRBCCF)->FREMIN := cFreMin
			(cTRBCCF)->IDMIN  := cIdMin //"2"
			(cTRBCCF)->CDCLFR := cCdclfr
			(cTRBCCF)->CDTPOP := cCdTpOp
			(cTRBCCF)->(MsUnLock())
		Else
			aAdd(aTRBCCF1,{	cNrCalc,;
				cCdclfr,;
				cCdTpOp,;
				Space(04),;
				cCdComImp,;
				Posicione("GV2",1,xFilial("GV2")+cCdComImp,"GV2_CATVAL"),;
				0,;
				nVLImposto,;
				cTotFre,;
				cBasImp,;
				cBaPiCo,;
				cFreMin,;
				cIdMin,;
				nVlFrMi,;
				"0",;
				Space(6),;
				Space(1)})
		EndIf
	EndIf
	oGFEXFBFLog:setTexto("      Novo componente: " + cCdComImp + STR0471 + AllTrim(STR(nVLImposto)) + CRLF)

Return

					/*----------------------------------------------------------------------------
					{Protheus.doc} GFECalcTabInf
					Calcula o valor dos componentes com base nos dados informados no array aTabelaFrt
					O array aTabelaFrt contem as seguintes informações:
					[01]	Transportador
					[02]	Numero da Tabela
					[03]	Tipo Lotação
					[04]	Atributo Faixa
					[05]	Tipo Veiculo
					[06]	Unid Medida
					[07]	Kg/M3
					[08]	Qtde Minima
					[09]	Frete Mínimo
					[10]	Comp Garantia
					[11]	Considera Prazo?
					[12]	Tipo de Prazo
					[13]	Qtde Prazo
					[14]	Contagem Prazo
					[15]	Adiciona ISS?
					[16]	Adiciona ICMS?
					[17]	Rateia imposto
					[18]	Componente Imposto
					[19]	[N]	[01]	Código do Componente
					[02]	Vl Fixo Normal
					[03]	% Normal
					[04]	Vl Unit Normal
					[05]	Vl Fração
					[06]	Vl Minimo Normal
					[07]	Vl Limite
					[08]	Vl Fixo Extra
					[09]	% Extra
					[10]	Vl Unit Extra
					[11]	Forma de cálculo do excedente
					[12]	Considera no total do frete?
					[13]	Considera na base do imposto?
					[14]	Considera na base do PIS/COFINS?
					[15]	Considera no frete mínimo?
					[16]   Indica Componente Tarifa("0") ou Emitente("1")
					[20]	Numero da negociação

					Uso: GFECalcTabInf(cNrCalc, cCdClFr, cCdTpOp, nQtCalc, @nVlFretMin)

					@param  cNrCalc		Numero da unidade de calculo
					@param	cCdClFr		Código da classificacao de frete
					@param	cCdTpOp		Código do tipo de operacao
					@param  nQtCalc     Quantidade para calculo
					@param  nVlFretMin	Valor de referencia para frete minimo que será atualizado pela função

					@sample GFECalcTabInf("00000001","1","",100,@nValFretMin)

					@author Luciano de Araujo
					@since 11/11/2010
					@version 1.0
					----------------------------------------------------------------------------*/
				Static Function GFECalcTabInf(cNrCalc, cCdClFr, cCdTpOp, nQtCalc, nVlFretMin, lUtlFrMin)

					Local cCatVal
					Local nX, nY, nQtde, nQtdePed, nQtdeFai
					Local nValCpn, nValor, nVlFretTot, nVlFrete
					Local nPos        := 0
					Local aCompCalc   := {}  // Array com os componentes calculados, que serao retornados pela funcao
					Local aComps      := {}  // Array com os componentes a serem calculados, combinando os componentes da tarifa com os componentes por emitente
					Local aCompVlFr   := {}  // Array com os componentes que são calculados sobre o valor do frete
					Local aAreaTRBTCF := GFEXFB_9GETAREA(lTabTemp, cTRBTCF, 5)
					Local cNrAgru
					Local cTpLocEntr := s_TREENTR

					Default nVlFretMin := 0
					Default lUtlFrMin  := .T.

					If cTpLocEntr != "1"
						cTpLocEntr := ""
					EndIf

					GFEXFB_BORDER(lTabTemp,cTRBUNC,01,6)
					GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC1, 6,{cNrCalc})
					cNrAgru     := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC1, 6,"NRAGRU")

					GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
					GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{cNrCalc, cCdClFr, cCdTpOp})

					While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .And. cNrCalc+cCdClFr+cCdTpOp == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

						oGFEXFBFLog:setTexto(STR0543 + CRLF) //"    Faixas -> Usando dados de tabela de frete informados pelo usuário."

						nQtdePed := 0
						nQtdeFai := IF(aTabelaFrt[3]=="1",GFEConvUM(s_UMPESO,aTabelaFrt[6],nQtCalc),nQtCalc)

						oGFEXFBFLog:setTexto(STR0340 + cValToChar(aTabelaFrt[9]) + STR0341 + cValToChar(nVlFretMin) + CRLF) //"      *** Frete mínimo da faixa: "###" x Frete mínimo selecionado: "
						If nVlFretMin < aTabelaFrt[9]
							nVlFretMin := aTabelaFrt[9]
						EndIf

						// Verifica a quantidade minima de calculo para a tarifa. Já está na unidade de medida da tarifa (GV7_UNICAL)
						IF nQtdeFai < aTabelaFrt[8]
							nQtdeFai := aTabelaFrt[8]
							nQtCalc  := GFEConvUM(aTabelaFrt[6],s_UMPESO,aTabelaFrt[8])	// Converte a qtde minima para a unidade da faixa
							oGFEXFBFLog:setTexto(STR0342 + cValToChar(nQtdeFai) + CRLF) //"      *** Usando qtde. mínima da faixa: "
						EndIf

						// Acumula a quantidade original para utilizar no cálculo do pedágio
						nQtdePed += nQtCalc

						oGFEXFBFLog:setTexto(CRLF + STR0347 + CRLF + CRLF) //"    # Calculando valores dos componentes para as faixas encontradas..."

						aComps := {}	// Cada faixa pode ter um conjunto diferente de componentes

						oGFEXFBFLog:setTexto(STR0544 + CRLF)	 //"        Componentes gerais da tarifa na faixa "				 //"        Componentes informados:"

						For nX := 1 to len(aTabelaFrt[19])
							// Só adiciona se nao existir no array aComps
							If aScan(aComps,{|aComp| aComp[1] == aTabelaFrt[19,nX,1]}) == 0
								oGFEXFBFLog:setTexto("        " + aTabelaFrt[19,nX,1] + CRLF)
								aAdd(aComps,{aTabelaFrt[19,nX,1],;	// Código do componente
								aTabelaFrt[19,nX,2],;	// Valor fixo normal
								aTabelaFrt[19,nX,3],;	// Percentual normal
								aTabelaFrt[19,nX,4],;  // Valor unitario normal
								aTabelaFrt[19,nX,5],;	// Valor fração normal
								aTabelaFrt[19,nX,6],;	// Valor mínimo normal
								aTabelaFrt[19,nX,7],;	// Valor limite
								aTabelaFrt[19,nX,8],;	// Valor fixo extra
								aTabelaFrt[19,nX,9],;	// Percentual extra
								aTabelaFrt[19,nX,10],;	// Valor unitário extra
								aTabelaFrt[19,nX,11],;	// Forma de cálculo do excedente
								aTabelaFrt[19,nX,12],;
									aTabelaFrt[19,nX,13],;
									aTabelaFrt[19,nX,14],;
									aTabelaFrt[19,nX,15],;
									aTabelaFrt[19,nX,16]})
							EndIf
						Next nX

						oGFEXFBFLog:setTexto(CRLF)

						if lCalcServ .and. Len(aComps) == 0 .And. !lSimulFrt
							oGFEXFBFLog:setTexto(CRLF + "Componente de Serviço não encontrado" + CRLF)
							GFEXFBAEC(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), 11)
							lError := .T.
						Endif

						For nY := 1 to len(aComps)

							nValor := nQtde := 0

							GV2->(dbSetOrder(01))
							If GV2->(dbSeek(xFilial("GV2")+aComps[nY,_CDCOMP]))

								oGFEXFBFLog:setTexto(STR0353 + aComps[nY,_CDCOMP] + " - " + Posicione("GV2", 1, xFilial("GV2")+aComps[nY,_CDCOMP], "GV2_DSCOMP") + CRLF) //"        Calculando componente: "

								oGFEXFBFLog:setTexto(STR0355 + GFEFldInfo("GV2_ATRCAL", GV2->GV2_ATRCAL, 2)) //"          Atributo: "
								nValCpn := 0

								// Quando carga fracionada e atributo de calculo da faixa e do componente são igual, assume a quantidade da faixa para cálculo
								If aTabelaFrt[3] == "1" .AND. AllTrim(GV2->GV2_ATRCAL) == AllTrim(aTabelaFrt[4]) // Atributo da Faixa

									If GV2->GV2_ATRCAL == '5 ' .And. GFXCP12117("GV2_UNIT") .And. !Empty(GV2->GV2_UNIT)
										cIDVLAG := "1"
										If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
											cIDVLAG := "1"
										Else
											cIDVLAG := GV2->GV2_IDVLAG											
										EndIf
										nValCpn := GFEQtdeComp( cNrAgru,;
											cNrCalc,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
											GV2->GV2_ATRCAL,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
											aTabelaFrt[7],;
											,;
											,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),; // Qtde Kg/M3
										0,;
											cIDVLAG,;
											GetTpEntr( cTpLocEntr,cIDVLAG),;
											GFEXFBLOCE( cNrCalc ),;
											lUtlFrMin,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
											IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))
									Else
										// Quando categoria do componente for Pedagio, utiliza a quantidade total e não a quantidade da faixa
										nValCpn := IF(GV2->GV2_CATVAL == "4",GFEConvUM(s_UMPESO,aTabelaFrt[6] /*Unidade Calculo*/,nQtdePed), nQtCalc)
										oGFEXFBFLog:setTexto(STR0356) //" (Atributo Componente igual Atributo Faixa)"
									EndIf
								Else
									// Quando carga fechada ou atributos de cálculo da faixa e do componentes são diferentes, é necessário determinar a quantidade para cálculo
									oGFEXFBFLog:setTexto(IF(aTabelaFrt[3] == "1", STR0357, "")) //" (Atributo Componente diferente do Atributo Faixa)"

									If AllTrim(GV2->GV2_ATRCAL) != "9"	// Valor do Frete

										cIDVLAG := "1"
										If (GV2->GV2_CATVAL == "4") .OR. (GV2->GV2_IDVLRC == "2")
											cIDVLAG := "1"
										Else
											cIDVLAG := GV2->GV2_IDVLAG											
										EndIf
										nValCpn := GFEQtdeComp( cNrAgru,;
											cNrCalc,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"),;
											GV2->GV2_ATRCAL,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALLIQ"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME"),;
											aTabelaFrt[7],;
											,;
											,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT"),; // Qtde Kg/M3
										0,;
											cIDVLAG,;
											GetTpEntr( cTpLocEntr,cIDVLAG),;
											GFEXFBLOCE( cNrCalc ),;
											lUtlFrMin,;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP"),;
											GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"SEQ"),;
											IIF(GFXCP12117("GV2_UNIT"),GV2->GV2_UNIT,''))
									Else
										// O ULTIMO A SER CALCULADO, SOMATORIA DO VALOR TOTAL DO FRETE (TODOS OS COMPONENTES JA CALCULADOS)
										// Gravar o componente no array para calcular posteriormente
										aAdd(aCompVlFr,aComps[nY])
										oGFEXFBFLog:setTexto(STR0358 + CRLF + CRLF) //" - Cálculo postergado!"
										Loop	// Passa para o proximo componente
									EndIf
								EndIf

								If lPEXFB02
									nValCpn := ExecBlock("GFEXFB02",.f.,.f.,{ nValCpn })
								EndIf

								oGFEXFBFLog:setTexto(STR0198 + cValToChar(nValCpn) + CRLF) //" - Qtde. Cálculo: "

								// Calculo do valor do componente
								nValor := GFEVlComp(aComps[nY],nValCpn,@nQtde)

								// Gravacao do componente na lista de componentes calculados
								nPos := aScan(aCompCalc,{|x| x[1] == aComps[nY,_CDCOMP]})	// Componente já consta na lista?
								If nPos > 0
									oGFEXFBFLog:setTexto(STR0361 + cValToChar(nValor) + " (+" + AllTrim(STR(aCompCalc[nPos,_VALOR])) + STR0362 + cValToChar(nQtde) +;
										"(+" + AllTrim(STR(aCompCalc[nPos,_QTDE])) + ")" + CRLF + CRLF) //"          Somando com faixa anterior: Valor: "###"); Qtde.: "
									aCompCalc[nPos,_VALOR] += nValor
									aCompCalc[nPos,_QTDE]  += nQtde
								Else
									nPos := aScan(aTabelaFrt[19],{|x| x[1] == aComps[nY,_CDCOMP] })
									if nPos > 0

										// Verificando se componente é usado para frete garantia
										If aTabelaFrt[10] == aComps[nY,1]
											oGFEXFBFLog:setTexto(STR0363 + cValToChar(nValor) + STR0364 + cValToChar(nVlFretMin) + ")" + CRLF) //"          Componente é usado para FRETE GARANTIA. Comparando valor ("###") com o frete mínimo atual ("
											If nValor > nVlFretMin
												nVlFretMin := nValor
												oGFEXFBFLog:setTexto(STR0365 + cValToChar(nValor) + STR0366 + CRLF) //"          Assumindo valor do componente ("###") como frete mínimo."
											Else
												oGFEXFBFLog:setTexto(STR0367 + cValToChar(nVlFretMin) + ")." + CRLF) //"          Mantendo valor de frete mínimo ("
											EndIf

											/*Identificacao dos elementos no array aCompCalc: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
											aAdd(aCompCalc,{aComps[nY,_CDCOMP],GV2->GV2_CATVAL,nValor,nQtde,"2","2","2","2",aComps[nY,16]})
										Else
											/*Identificacao dos elementos no array aCompCalc: 1-Componente, 2-Categoria, 3-Valor, 4-Qtde., 5-Total Frete ,6-Base Imposto ,7-Base Pis/Cof, 8-Frete Min*/
											aAdd(aCompCalc,{aComps[nY,_CDCOMP],GV2->GV2_CATVAL,nValor,nQtde,aTabelaFrt[19,nPos,12],aTabelaFrt[19,nPos,13],aTabelaFrt[19,nPos,14],aTabelaFrt[19,nPos,15],aComps[nY,16]})
										EndIf
										oGFEXFBFLog:setTexto(STR0368 + AllTrim(STR(nValor)) + STR0369 + AllTrim(Str(nQtde)) + STR0370 + GFEFldInfo("GV2_CATVAL",GV2->GV2_CATVAL,2) + CRLF + CRLF) //"          Calculado para esta faixa: Valor: "###"; Qtde.: "###"; Categoria: "
									EndIf
								EndIf
							Else
								oGFEXFBFLog:setTexto(CRLF + STR0371 + AllTrim(aComps[nY,_CDCOMP]) + STR0372 + CRLF) //"          ERRO!!! Componente "###" não está cadastrado!!!"
								GFEXFBAEC(cNrCalc, 11)
								lError := .T.
							EndIf	// Componente existe na GV2?
						Next nY // array de componentes da tarifa + componentes do emitente

						/************************************************/
						/*****      FRETE SOBRE O VALOR DO FRETE    *****/
						/************************************************/
						oGFEXFBFLog:setTexto(STR0373 + CRLF) //"      # Calculando componentes cujo atributo de cálculo é Valor do Frete..."

						// Obtem o valor total do frete calculado ate aqui
						nVlFrete := 0
						For nX := 1 to len(aCompCalc)
							IF aCompCalc[nX,_TOTFRE] == "1" // Componente soma no total do frete
								nVlFrete += aCompCalc[nX,_VALOR]
							EndIf
						Next nX

						nVlFretTot := nVlFrete

						If Empty(aCompVlFr)
							oGFEXFBFLog:setTexto(CRLF + STR0374 + CRLF) //"        Não há componentes para cálculo sobre o valor do frete."
						EndIf

						For nX := 1 to len(aCompVlFr)

							oGFEXFBFLog:setTexto(CRLF + STR0353 + aCompVlFr[nX,_CDCOMP] + " - " + Posicione("GV2",1,xFilial("GV2")+aCompVlFr[nX,_CDCOMP],"GV2_DSCOMP") + CRLF) //"        Calculando componente: "
							oGFEXFBFLog:setTexto(STR0375 + cValToChar(nVlFrete) + CRLF) //"          Valor de frete atual: "

							cCatVal := Posicione("GV2",1,xFilial("GV2")+aCompVlFr[nX,_CDCOMP],"GV2_CATVAL")
							nValor  := GFEVlComp(aCompVlFr[nX],nVlFrete,0)

							// Adicionar o valor de cada componente ao valor final de frete
							nVlFretTot += nValor

							nPos := aScan(aTabelaFrt[19],{|x| x[1] == aCompVlFr[nX,_CDCOMP]})

							if nPos > 0

								// Adiciona o componente na lista de componentes calculados
								aAdd(aCompCalc,{aCompVlFr[nX,_CDCOMP],cCatVal,nValor,nVlFrete,aTabelaFrt[19,nPos,12],aTabelaFrt[19,nPos,13],aTabelaFrt[19,nPos,14],aTabelaFrt[19,nPos,15], "0"})

								oGFEXFBFLog:setTexto(STR0378 + AllTrim(STR(nValor)) + STR0369 + AllTrim(Str(nVlFrete)) + STR0370 + GFEFldInfo("GV2_CATVAL",cCatVal,2) + CRLF) //"        Componente calculado. Valor: "###"; Qtde.: "###"; Categoria: "
							End
						Next nX

						oGFEXFBFLog:setTexto(CRLF + STR0390 + cValToChar(nVlFretTot) + CRLF + CRLF) //"    -> Valor de Frete para esta tarifa: "

						GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)

						//limpando o Array
						aComps    := {}  // Array com os componentes a serem calculados, combinando os componentes da tarifa com os componentes por emitente
						aCompVlFr := {}
					EndDo
					GFEXFB_ARESTAREA(lTabTemp,aAreaTRBTCF,5) //RestArea(aAreaTRBTCF)

					Return aCompCalc // FIM GFECalcTabInf()

					/*----------------------------------------------------------------------------
					Função usada na simulação para permitir utilizar os trechos fornecidos sem que
					seja preciso duplicá-los.
					Recebe o parâmetro:
					lAltera: indica o sentido da troca dos trechos
					.T. = CALBAS -> NRCALC
					.F. = NRCALC -> CALBAS
					----------------------------------------------------------------------------*/
				Static Function GFEAjusTre(lAltera)

					Local cNrCalc   := if(lAltera,GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))
					Local cNrCalc2  := if(lAltera,GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"),GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS"))

					// No caso do calculo ser o proprio calculo base, não terá o campo CALBAS preenchido
					// Tambem impede a função de "zerar" os número de cálculo dos trechos quando chamada com .F.
					if Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"CALBAS")) .OR. Empty(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"))
						Return NIL
					EndIf

					// Obtém os trechos do calculo de origem
					GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
					GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{cNrCalc})
					While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .AND. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == cNrCalc
						GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC",cNrCalc2)
						GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
					EndDo


					If !lTabTemp
						aTRBTRE2 := aClone(aTRBTRE1)
						aTRBTRE3 := aClone(aTRBTRE1)
						aTRBTRE4 := aClone(aTRBTRE1)
						aSort(aTRBTRE1,,,{|x,y| x[18]                         < y[18]})
						aSort(aTRBTRE2,,,{|x,y| x[04]+x[01]+x[02]+x[03]+x[05] < y[04]+y[01]+y[02]+y[03]+y[05]})
						aSort(aTRBTRE3,,,{|x,y| x[17]+x[05]+x[15]+x[16]       < y[17]+y[05]+y[15]+y[16]})
						aSort(aTRBTRE4,,,{|x,y| x[17]+x[03]+x[05]+x[15]+x[16] < y[17]+y[03]+y[05]+y[15]+y[16]})
					EndIf

					Return NIL	// FIM GFEAjusTre()


					/*----------------------------------------------------------------------------
					{Protheus.doc} GFERatImp
					Função para ratear o imposto entre os componentes, recebe os parametros necessários
					para encontrar os componentes e fazer o rateio

					Uso: GFERatImp(cNrCalcImp, aParamComp, nVlFrete, nVlImposto)

					@param cNrCalcImp - Numero do Calc para achar o Componente
					@param aParamComp - Array com informações sobre os componentes (se totaliza no frete, se é base para imposto, etc.)
					@param nVlFrete   - Valor de frete somado para todos os componentes
					@param nVLImposto - Valor do Imposto a ser rateado

					@sample GFERatImp("0000001","1","1","1",1000,200)

					@author Luiz Fernando Soares
					@since 27/01/10
					@version 1.0
					----------------------------------------------------------------------------*/
Function GFERatImp (cNrCalcImp, aParamComp, nVlFrete, nVLImposto,cCdclfr,cCdtpop)

					Local nVlImpComp := 0 // Valor de imposto do componente
					Local lUsaArray  := GFEXFBUAT()
					Local cTotFrete  := "1"
					Local cTotImp    := "1"
					Local nPos       := 0
					Local aSeek 	 := {}

					// Variáveis para compensação do rateio
					Local nTotImpComp := 0
					Local nMaiorValor := 0
					Local nRecnoMaior := 0

					Default cCdclfr := ""
					Default cCdtpop := ""

					If Empty(cCdclfr)
						aSeek := {cNrCalcImp}
					Else
						aSeek := {cNrCalcImp,cCdclfr,cCdtpop}
					EndIf

					//Buscar os componentes//
					GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
					GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,aSeek)
					While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
							GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == cNrCalcImp .And. ;
							( Empty(cCdclfr) .Or. cCdclfr == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") ) .And. ;
							( Empty(cCdtpop) .Or. cCdtpop == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") )
						if lUsaArray
							nPos := aScan(aTabelaFrt[19],{|x| x[1]==GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")})
							if nPos > 0
								cTotFrete := aTabelaFrt[19,nPos,12]	// Totaliza no valor de frete?
								cTotImp   := aTabelaFrt[19,nPos,13] // Totaliza no valor de base do imposto?
							EndIf
						Else
							nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") .AND. x[6] == cNrCalcImp })
							If nPos > 0
								cTotFrete := aParamComp[nPos,2]
								cTotImp   := aParamComp[nPos,3]
							EndIf
						EndIf

						oGFEXFBFLog:setTexto(CRLF + STR0272 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF) //"        Verificando componente "
						if cTotFrete == "1" /* SIM */ .and. cTotImp == "1" /* SIM */
							oGFEXFBFLog:setTexto(STR0273 + CRLF) //"        Considera no total do frete e é base para imposto. Efetuando rateio..."
							oGFEXFBFLog:setTexto(STR0274 + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + ") ") //"        Valor Componente ("

							nVlImpComp := NoRound((GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") / nVlFrete) * nVLImposto, 2)
							nTotImpComp += nVlImpComp

							if nVlImpComp > nMaiorValor
								nMaiorValor := nVlImpComp
								nRecnoMaior := GFEXFB_GRECNO(lTabTemp, cTRBCCF, 9)
							EndIf

							GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + nVlImpComp)
							oGFEXFBFLog:setTexto(STR0275 + cValToChar(nVlImpComp) + ") = " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")) + CRLF) //" + Imposto ("
						else
							oGFEXFBFLog:setTexto(STR0276 + CRLF) //"        Não considera no rateio. Não soma no total do frete OU não é base para imposto."
						endif
						GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
					enddo

					// Compensação de diferenças devido ao rateio
					If nVlImposto <> nTotImpComp
						GFEXFB_HGOTO(lTabTemp, cTRBCCF, 9, nRecnoMaior)
						If !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9)

							If !empty(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR"))
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + (nVlImposto - nTotImpComp))
							EndIf							
							oGFEXFBFLog:setTexto(CRLF + Space(8) + STR0621 + AllTrim(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")) + STR0622 + cValToChar(nVlImposto - nTotImpComp) + CRLF) //"Compensando diferença de rateio no componente " ### " somando "
						EndIf
					EndIf

					Return	//FIM GFERatImp()


/*----------------------------------------------------------------------------
Rateia o valor recebido entre os cálculos do romaneio, proporcional ao valor de frete
de cada calculo.
cNrAgrup	Número do agrupador de frete (romaneio)
nVlFrtRat	Valor de frete a ratear entre os cálculos do agrupador
aVlFrtCalc	Array contendo os valores de frete para cada cálculo do agrupador
[1] - Número da unidade de cálculo
[2] - Valor de frete considerando frete mínimo
[3] - Valor de frete desconsiderando frete mínimo
[4] - Valor do frete mínimo
----------------------------------------------------------------------------*/
/***********************************************/
/***** RATEIO DO FRETE MINIMO POR ROMANEIO *****/
/***********************************************/
Static Function GFERaVlFr(cNrAgrup,nVlFrtRat,aVlFrtCalc,aParamComp,aTotCalc,aTotTre,nVlFrtMn)

	Local nFrtComMinTot := 0
	Local nPos      := 0
	Local nValor    := 0
	Local nVlFrMin  := 0
	Local cCompImp  := ""
	Local nVlComp   := 0
	Local cDifMin   := ""
	Local nPerc     := 0
	Local nVlRatea  := 0
	Local nCount    := 0
	Local nValorTT  := 0
	Local lFindComp := .F.   							//Indica se encontrou o componente para gravar a diferença do frete mínimo
	Local cCriRat   := GetNewPar("MV_CRIRAT2", "1") 	//"1=Valor do Frete","2=Peso Carga","3=Valor Carga","4=Quantidade Itens","5=Volume Carga"
	/* 1=Diferença          - Utiliza o valor da subtação entre o valor calculado do valor do frete mínimo para realizar o rateio
	2=Total Frete Mínimo - Quando a rotina assume o valor do frete mínimo, rateia o valor total do frete mínimo ignorando o frete já calculado. */
	Local cCriRat3  := GetNewPar("MV_CRIRAT3", "1")
	Local nX
	Local aCpMinClFr := {}
	Local nValorPrt := 0 //Valor dos componentes que participam do minimo de um calculo
	Local lRatClass := ( AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) $ "1S" .Or. AllTrim(UPPER(SuperGetMv("MV_GFERCF",.F.,"2"))) == ".T." )
	Local aCdClFr := {Space(Len(GWI->GWI_CDCLFR)),Space(Len(GWI->GWI_CDTPOP))}

	oGFEXFBFLog:setTexto(CRLF+"    Critério de Rateio do Frete Mínimo Por Romaneio -> " )
	Do Case
		Case cCriRat == "1"; oGFEXFBFLog:setTexto("1=Valor do Frete"   + CRLF)
		Case cCriRat == "2"; oGFEXFBFLog:setTexto("2=Peso Carga"       + CRLF)
		Case cCriRat == "3"; oGFEXFBFLog:setTexto("3=Valor Carga"      + CRLF)
		Case cCriRat == "4"; oGFEXFBFLog:setTexto("4=Quantidade Itens" + CRLF)
		Case cCriRat == "5"; oGFEXFBFLog:setTexto("5=Volume Carga"     + CRLF)
	EndCase
	oGFEXFBFLog:setTexto(CRLF+"    Critério do valor que será Rateado -> " )
	If cCriRat3 == "1"
		oGFEXFBFLog:setTexto("1=Diferença"   + CRLF)
		oGFEXFBFLog:setTexto("                                          Subtrai o valor da soma dos componente que fazem parte "   + CRLF)
		oGFEXFBFLog:setTexto("                                          do Frete Mínimo do valor do frete mínimo assumindo da negociação "   + CRLF)
		oGFEXFBFLog:setTexto("    Rateando valor do frete mínimo (" + cValToChar(nVlFrtRat) + ") entre os cálculos do agrupador " + cNrAgrup + CRLF)
		nVlRatea := nVlFrtRat
	Else
		oGFEXFBFLog:setTexto("1=Valor do Frete"   + CRLF)
		oGFEXFBFLog:setTexto("                                          Utiliza o valor do Frete Mínimo assumindo da negociação "   + CRLF)
		oGFEXFBFLog:setTexto("    Rateando valor do frete mínimo (" + cValToChar(nVlFrtMn) +") Agrupador:"+ cNrAgrup + CRLF)
		nVlRatea := nVlFrtMn
	EndIf

	// Obtem o valor total de frete do romaneio
	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgrup})
	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == cNrAgrup

		// para cada calculo do romaneio, verifica se tem valor de frete
		nPos := aScan(aVlFrtCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		If nPos > 0
			nCount++
			nFrtComMinTot += aVlFrtCalc[nPos,5]
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo

	oGFEXFBFLog:setTexto(STR0483 + cValToChar(nFrtComMinTot) + CRLF) //"    Valor total do agrupador: "

	// Efetua o rateio do valor de frete recebido entre os cálculos do romaneio
	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgrup})
	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == cNrAgrup

		nPos := aScan(aVlFrtCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		If nPos > 0
			aCpMinClFr := {}
			nValorPrt := 0

			lFindComp := .F.

			// Calcula a parcela do valor de frete correspondente ao valor do cálculo de frete
			nPosCalc := aScan(aTotCalc,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			nPosTre  := aScan(aTotTre ,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE")})

			Do Case
			Case cCriRat == "1" // Valor do frete
				nPerc := aVlFrtCalc[nPos,5] / nFrtComMinTot
				oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aVlFrtCalc[nPos,5]) + ' / ' + cValToChar(nFrtComMinTot)+' = '+ cValToChar(nPerc) + CRLF)

			Case cCriRat == "2"	// Peso
				If aTotTre[nPosTre,4] > aTotTre[nPosTre,5]				// Verifica se peso real é maior que o cubado. Usa o que for maior
					nPerc := aTotCalc[nPosCalc,4] / aTotTre[nPosTre,4]
					oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aTotCalc[nPosCalc,4]) + ' / ' + cValToChar(aTotTre[nPosTre,4])+' = '+ cValToChar(nPerc) + CRLF)
				Else
					nPerc := aTotCalc[nPosCalc,5] / aTotTre[nPosTre,5]
					oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aTotCalc[nPosCalc,5]) + ' / ' + cValToChar(aTotTre[nPosTre,5])+' = '+ cValToChar(nPerc) + CRLF)
				EndIf

			Case cCriRat == "3" // Valor Carga
				nPerc := aTotCalc[nPosCalc,3] / aTotTre[nPosTre,3]
				oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aTotCalc[nPosCalc,3]) + ' / ' + cValToChar(aTotTre[nPosTre,3])+' = '+ cValToChar(nPerc) + CRLF)

			Case cCriRat == "4" // Quantidade
				nPerc := aTotCalc[nPosCalc,2] / aTotTre[nPosTre,2]
				oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aTotCalc[nPosCalc,2]) + ' / ' + cValToChar(aTotTre[nPosTre,2])+' = '+ cValToChar(nPerc) + CRLF)

			Case cCriRat == "5" // Volume Carga
				nPerc := aTotCalc[nPosCalc,6] / aTotTre[nPosTre,6]
				oGFEXFBFLog:setTexto(CRLF+"    Fator de rateio-> " + cValToChar(aTotCalc[nPosCalc,6]) + ' / ' + cValToChar(aTotTre[nPosTre,6])+' = '+ cValToChar(nPerc) + CRLF)
			EndCase

			nValor := ROUND(nVlRatea * nPerc,2)

			// TRATAMENTO PARA AJUSTE DE ARREDONDAMENTO DE 0,01. DEVIDO AO ARREDONDAMENTO, PODE GERAR DIFERENÇA DE 0,01
			// QUANDO FOR O ULTIMO VALOR, SUBTRAI O VALOR TOTAL DO VALOR JÁ RATEADO ANTERIORMENTE.
			nCount--
			If nCount = 0
				nValor := nVlRatea - nValorTT
			EndIf
			// TRATAMENTO PARA AJUSTE DE ARREDONDAMENTO DE 0,01. DEVIDO AO ARREDONDAMENTO, PODE GERAR DIFERENÇA DE 0,01

			nValorTT := nValorTT + nValor

			oGFEXFBFLog:setTexto("      Novo valor: " + cValToChar(nValor) + CRLF)

			nVlFrMin := nValor

			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

			GV9->(dbSetOrder(01))
			If !GV9->(dbSeek(xFilial("GV9") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB") + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")))
				aTabInfo := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))	// Verificação para caso nao encontrou negociação com o transp inicial, busca no transp da tabela de vinculo
				If !Empty(aTabInfo)
					GV9->(dbSeek(xFilial("GV9") + aTabInfo[2] + aTabInfo[3] + GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")))
				EndIf
			EndIf

			cCompImp := GV9->GV9_COMMIN
			cDifMin  := GV9->GV9_DIFMIN
			nVlComp  := 0

			GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
			If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
				While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")
					If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"FREMIN") == '1'

						nValorPrt += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")

						If GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") == cCompImp

							lFindComp := .T.

							oGFEXFBFLog:setTexto("    Atualizando valor de frete mínimo no componente: " + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF)
							oGFEXFBFLog:setTexto("    Valor atual: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) + CRLF)


							// Quando configurado 1=Diferença - Soma o valor calculado ao valor do frete ja existente/calculado
							If cCriRat3 == "1"
								nVlComp += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")					// Tem que pegar o valor antes de alterar. Importante que esteja abaixo do RecLock
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") - GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI"))		// Desconta o valor de frete minimo adicionado anteriormente
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI",nValor)
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR") + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) 		// Adiciona o novo valor de frete mínimo
							Else
								// 2=Total Frete Mínimo - Assume o valor total calculado
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI",nValor)
								GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR", nValor)    				// Adiciona o novo valor de frete mínimo
							EndIf
							oGFEXFBFLog:setTexto("    Novo valor: " + cValToChar(GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI")) + CRLF) //"    Novo valor: "
						Else
							If cDifMin == "2" .OR.; // 1-Gravar a diferença, 2-Gravar total
								cCriRat3 == "2"      // 2=Total Frete Mínimo - Assume o valor total calculado
								If lTabTemp
									(cTRBCCF)->(dbDelete())
								Else
									GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
								EndIf
								If cDifMin == "2"
									nVlComp += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
								EndIf

								If lRatClass
									aCdClFr := {GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR"),GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP")}
								EndIf

								If ( nPos := aScan(aCpMinClFr, {|x| x[1] == aCdClFr[1] .And. x[2] ==  aCdClFr[2]} ) ) > 0

									aCpMinClFr[nPos,3] += GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
								Else
									aAdd(aCpMinClFr, {aCdClFr[1],;
													  aCdClFr[2],;
													  GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")})
								EndIf
							EndIf
						EndIf
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
				EndDo
			Endif
			if !lTabTemp
				aTRBCCF2 := aClone(aTRBCCF1)
				aTRBCCF1 := {}
				For nX := 1 to len(aTRBCCF2)
					If aTRBCCF2[nX,15] == "0"
						AADD(aTRBCCF1, {aTRBCCF2[nx,01], aTRBCCF2[nx,02], aTRBCCF2[nx,03], aTRBCCF2[nx,04], aTRBCCF2[nx,05], aTRBCCF2[nx,06], ;
							aTRBCCF2[nx,07], aTRBCCF2[nx,08], aTRBCCF2[nx,09], aTRBCCF2[nx,10], aTRBCCF2[nx,11], aTRBCCF2[nx,12], ;
							aTRBCCF2[nx,13], aTRBCCF2[nx,14], aTRBCCF2[nx,15], aTRBCCF2[nx,16], aTRBCCF2[nx,17]})
					EndIf
				Next Nx
				aSort(aTRBCCF1  ,,,{|x,y| x[01]+x[02]+x[03]+x[05]      < y[01]+y[02]+y[03]+y[05]})
			EndIf
			IF cDifMin == "2" // 1-Gravar a diferença, 2-Gravar total
				nValor += nVlComp
			EndIf

			If !lFindComp
				oGFEXFBFLog:setTexto("      Inclusão de novo componente com a diferença do frete mínimo" + CRLF)
				For nX := 1 To Len(aCpMinClFr)
					oGFEXFBFLog:setTexto("      Componente: " + cCompImp + CRLF)
					oGFEXFBFLog:setTexto("      Valor: " + cValToChar(( aCpMinClFr[nX,3]  / nValorPrt ) * nValor) + CRLF)
					GFEGrvComImp(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), cCompImp, ( aCpMinClFr[nX,3]  / nValorPrt ) * nValor, "1", "1", "1", "1","1",nVlFrMin, aCpMinClFr[nX,1], aCpMinClFr[nX,2])
				Next nX
				GFEParamComp({cCompImp,"1","1","1","1",GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")},@aParamComp)
			Else
				If cDifMin == "2" // 1-Gravar a diferença, 2-Gravar total
					GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"), cCompImp})
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR",nValor)
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VLFRMI",nVlFrMin)
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"IDMIN","1")
					EndIf
				EndIf
			EndIf
		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo

Return

/*----------------------------------------------------------------------------
Obter a tarifa de maior valor dentre as negociacoes dos calculos de um agrupador
cNrAgrupador  Numero do agrupador
nQtde	        Quantidade usada para o cálculo das tarifas
----------------------------------------------------------------------------*/
Static Function GFEMaiorTarifa(cNrAgrupador, nQtde, lValPriTrecho)

	Local aInfoTab, cCdTrpBase, cNrTabBase, nMaiorTarifa, nValTarifa
	Local nRecNoTarifa, nRecno
	Local aRetInfTar[18]
	Local lOk := .T.
	Default lValPriTrecho := .F.

	/*nMaiorTarifa[1] -> Retorna o Valor da Maior Tarifa
	nRecNoTarifa[2] -> Retorna o Recno da Tarifa*/

	nMaiorTarifa := nRecnoTarifa := nRecno := 0
	aInfoTab     := {}

	GFEXFB_BORDER(lTabTemp,cTRBUNC,02,6)
	GFEXFB_CSEEK(lTabTemp, cTRBUNC, @aTRBUNC2, 6,{cNrAgrupador})
	While !GFEXFB_3EOF(lTabTemp, cTRBUNC, @aTRBUNC2, 6) .AND. GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU") == cNrAgrupador
		If lValPriTrecho
			lOk := GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"SEQTRE") == "01"
		EndIf
		If GFETrpTrecho(GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRAGRU"), GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC"));
				.And. lOk

			GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
			GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
			While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

				nValTarifa := 0

				GFEXFB_BORDER(lTabTemp,cTRBCCF,01,9)
				GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{	GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC"), ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR"), ;
					GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")})
				While  !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCLFR") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR") .AND. ;
						GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDTPOP") == GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")

					If AllTrim(Posicione("GV2",1,xFilial("GV2")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP"),"GV2_ATRCAL")) == "1" // Frete Unidade

						// Caso seja uma tabela de vinculo, retorna os dados da tabela base
						aInfoTab   := GFEInfoTab(GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTRP"),GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRTAB"))
						cCdTrpBase := aInfoTab[2]
						cNrTabBase := aInfoTab[3]

						GV1->(dbSetOrder(1))
						If GV1->(dbSeek(xFilial("GV1")+cCdTrpBase+cNrTabBase+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")+GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")+GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")))

							oGFEXFBFLog:setTexto(STR0493 + GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP") + CRLF) //"    Calculando tarifa usando componente "

							// Calcula o valor da tarifa
							nValTarifa := GFEVlComp({GV1->GV1_CDCOMP,;
								GV1->GV1_VLFIXN,;
								GV1->GV1_PCNORM,;
								GV1->GV1_VLUNIN,;
								GV1->GV1_VLFRAC,;
								GV1->GV1_VLMINN,;
								GV1->GV1_VLLIM,;
								GV1->GV1_VLFIXE,;
								GV1->GV1_PCEXTR,;
								GV1->GV1_VLUNIE,;
								GV1->GV1_CALCEX},nQtde,0)
							oGFEXFBFLog:setTexto(CRLF)

							If nValTarifa > 0
								nRecno         := GFEXFB_GRECNO(lTabTemp, cTRBTCF, 5)
								Exit
							EndIf
						EndIf
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
				EndDo

				If nValTarifa > nMaiorTarifa
					nMaiorTarifa  := nValTarifa
					aRetInfTar[1] := nValTarifa
					aRetInfTar[2] := nRecno
					aRetInfTar[3]  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDCLFR")
					aRetInfTar[4]  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPOP")
					aRetInfTar[5]  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DTVIGE")
					aRetInfTar[6]  := cCdTrpBase
					aRetInfTar[7]  := cNrTabBase
					aRetInfTar[8]  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRNEG")
					aRetInfTar[9]  := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDFXTV")
					aRetInfTar[10] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"CDTPVC")
					aRetInfTar[11] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRROTA")
					aRetInfTar[12] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
					aRetInfTar[13] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
					aRetInfTar[14] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESCUB")
					aRetInfTar[15] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
					aRetInfTar[16] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
					aRetInfTar[17] := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDALT")
					aRetInfTar[18] := GV1->GV1_VLUNIN
				EndIf

				GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
			EndDo

		EndIf

		GFEXFB_8SKIP(lTabTemp, cTRBUNC, 6)
	EndDo

Return aRetInfTar

/*----------------------------------------------------------------------------
Ajusta a unidade de calculo corrente, vinculando os documentos de carga e os
componentes na unidade de calculo recebida. Ao final, a unidade de cálculo
corrente é eliminada.
----------------------------------------------------------------------------*/
Static Function GFETratUniCal(nRecNoCalc,cNrCalc,lSomaComp,aParamComp)

	Local aChave   := {}
	Local nValor   := 0
	Local lExiste  := .F.
	Local aAreaCCF := {}
	Local aAreaTRE := {}
	Local nX       := 0
	Local aAux     := {}
	Local aAuxTre  := {}
	Local nQtdCalc := 0

	Default aParamComp := {}

	// Posiciona na unidade de calculo corrente
	GFEXFB_HGOTO(lTabTemp, cTRBUNC, 6, nRecNoCalc)

	// Vincula todos os documentos de carga na unidade de cálculo informada
	GFEXFB_BORDER(lTabTemp,cTRBTRE,01,7)
	If GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE1, 7,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE1, 7) .AND. GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

			aAreaTRE := GFEXFB_9GETAREA(lTabTemp, cTRBTRE, 7) //getArea()
			aChave   := {GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") , ;
						 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") , ;
						 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  , ;
						 GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")}
			lExiste  := .F.

			// Verifica se o documento de carga já está na unidade de cálculo informada
			GFEXFB_BORDER(lTabTemp,cTRBTRE,02,7)
			if GFEXFB_CSEEK(lTabTemp, cTRBTRE, @aTRBTRE2, 7,aChave)
				While !GFEXFB_3EOF(lTabTemp, cTRBTRE, @aTRBTRE2, 7) .AND. ;
					   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"CDTPDC") == aChave[1] .AND. ;
					   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"EMISDC") == aChave[2] .AND. ;
					   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"SERDC")  == aChave[3] .AND. ;
					   GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRDC")   == aChave[4]

					If GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC") == cNrCalc
						lExiste := .T.
					EndIf
					GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
				EndDo
			EndIf

			// Reposiciona no documento de frete da unidade de calculo corrente
			GFEXFB_ARESTAREA(lTabTemp,aAreaTRE,7) //RestArea(aAreaTRE)

			If !lExiste
				aAdd(aAuxTre,GFEXFB_GRECNO(lTabTemp, cTRBTRE, 7))
			Endif

			GFEXFB_8SKIP(lTabTemp, cTRBTRE, 7)
		EndDo

		For nX := 1 to len(aAuxTre)
			GFEXFB_HGOTO(lTabTemp, cTRBTRE, 7, aAuxTre[nX])
			GFEXFB_5CMP(lTabTemp, cTRBTRE, @aTRBTRE1, 7,"NRCALC",cNrCalc)
		Next nX
	EndIf

	// Vincula os componentes na unidade de cálculo informada
	GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
	If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})

		While !GFEXFB_3EOF(lTabTemp, cTRBCCF, @aTRBCCF1, 9) .AND. ;
				GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

			if lSomaComp	// Indica se os componentes da unidade de cálculo corrente serão somados a unidade de cálculo informada
				nValor   := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"VALOR")
				nQtdCalc := GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"QTDE")
				aChave   := {cNrCalc, GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"CDCOMP")}

				nPos := aScan(aParamComp,{|x| x[1] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"CDCOMP") .AND. x[6] == GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF2, 9,"NRCALC")})
				If nPos > 0
					aParamComp[nPos][6] := cNrCalc

					// Guarda o registro corrente de componente para reposicionar em outro registro da mesma tabela.
					aAreaCCF := GFEXFB_9GETAREA(lTabTemp, cTRBCCF, 9) //GetArea()

					GFEXFB_BORDER(lTabTemp,cTRBCCF,02,9)
					// Procura o componente na unidade de cálculo informada
					If GFEXFB_CSEEK(lTabTemp, cTRBCCF, @aTRBCCF1, 9,aChave)

						// Reposiciona no componente da unidade da cálculo corrente
						GFEXFB_ARESTAREA(lTabTemp,aAreaCCF,9) //RestArea(aAreaCCF)

						// Elimina o componente da unidade de cálculo corrente
						if lTabTemp
							(cTRBCCF)->(dbDelete())
						Else
							GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
						EndIf
					Else
						// Reposiciona no componente da unidade de cálculo corrente
						GFEXFB_ARESTAREA(lTabTemp,aAreaCCF,9) //RestArea(aAreaCCF)

						// Componente não existe na unidade de cálculo recebida
						// Guarda o registro num array para alterar o número da unidade de cálculo depois
						aAdd(aAux, GFEXFB_GRECNO(lTabTemp, cTRBCCF, 9))
					EndIf
				EndIf

			Else
				// Elimina os componentes da unidade de cálculo corrente
				GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"DELETADO","1")
			EndIf

			GFEXFB_8SKIP(lTabTemp, cTRBCCF, 9)
		EndDo

		// Vincula os componentes do array à unidade de cálculo recebida
		For nX := 1 to len(aAux)
			GFEXFB_HGOTO(lTabTemp, cTRBCCF, 9, aAux[nX])
			GFEXFB_5CMP(lTabTemp, cTRBCCF, @aTRBCCF1, 9,"NRCALC", cNrCalc)
		Next nX
	EndIf

	// Elimina as tabelas da unidade de cálculo corrente, pois serão consideradas as da unidade de cálculo recebida como parâmetro
	GFEXFB_BORDER(lTabTemp,cTRBTCF,01,5)
	if GFEXFB_CSEEK(lTabTemp, cTRBTCF, @aTRBTCF1, 5,{GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")})
		While !GFEXFB_3EOF(lTabTemp, cTRBTCF, @aTRBTCF1, 5) .AND. GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"NRCALC") == GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"NRCALC")

			GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"DELETADO","1")
			GFEXFB_8SKIP(lTabTemp, cTRBTCF, 5)
		EndDo
	EndIf

	// Elimina a unidade de cálculo corrente

	GFEXFB_5CMP(lTabTemp, cTRBUNC, @aTRBUNC2, 6,"DELETADO","1")
Return //GFETratUniCal

//para retornar o percentual, a tcf deve estar posicionada
Static Function ClcPercRed(cAtrCal, cRtCCom)
	Local nPerc := 0

	Default cRtCCom := "3"

	cAtrCal := Val(AllTrim(cAtrCal))

	Do Case 
		Case cRtCCom == "1"
			nPerc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PERCOUT")
		Case cRtCCom == "2"
			Do Case
				Case cAtrCal == 1
					nPerc := (GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR") - GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESORORG")) / GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PESOR")
				Case cAtrCal == 2
					nPerc := (GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR") - GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALORORG")) / GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VALOR")
				Case cAtrCal == 3
					nPerc := (GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE") - GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDEORG")) / GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"QTDE")
				Case cAtrCal == 4
					nPerc := (GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME") - GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUMEORG")) / GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"VOLUME")
				OtherWise
					nPerc := 0
			EndCase
		OtherWise
			If cAtrCal == 7 .Or. cAtrCal == 10 .Or. cAtrCal == 11 // 7=Qt Entregas; 10=Peso.Liq; 11=Qt.Serv
				nPerc := 0
			Else
				nPerc := GFEXFB_5CMP(lTabTemp, cTRBTCF, @aTRBTCF1, 5,"PERCOUT")
			EndIf
	EndCase

Return nPerc

/*Função que retorna o valor 1 caso o valor recebido pela função seja 0.
  Criada para atender ao problema da issue MLOG-1816*/
Static Function GFEFbFrMin(nValor)

	If nValor == 0
		nValor := 1
	EndIf

Return nValor

/*----------------------------------------------------------------------------
{Protheus.doc} GFEVlrPerc
Valor rateado do percurso por componente de frete.

@sample GFEVlrPerc()

@author Leonardo Ribas Jimenez Hernandez
@since 25/06/19
@version 1.0
----------------------------------------------------------------------------*/
Static Function GFEVlrPerc(nPosicao,aParamComp,aTotCalc,cCdComp,cUnidCalc,aUnidades)
	Local nY 				:= 1
	Local nX 				:= 1
	Local nPos 		   		:= 0
	Local nPos2		   		:= 0
	Local nValor 			:= 0
	Local nContComp    		:= 0
	Local nTamUnidades 		:= 0
	Local nTotalComponente  := 0
	Local aValor 	   		:= {}
	Local cDESC 	   		:= " " 
	Local cTrechoUn    		:= " "
	Local lPassou 	   		:= .F.
	Local lTrecho 	   		:= .F.
	Local nPosIni			:= 0
	Local nPosFim			:= 0
	Local nQtde				:= 0

	nPos2 := ASCAN(aUnidades,{|x|x[1] == cUnidCalc})
	If nPos2 > 0
		cTrechoUn := SubStr(aUnidades[nPos2][24], Len(aUnidades[nPos2][24]) - 1, 2)
	EndIf

	/*
	nPosicao == 2 o critério de rateio por QUANTIDADE
	nPosicao == 3 o critério de rateio por VALOR
	nPosicao == 4 ou 5 o critério de rateio por PESO
	nPosicao == 6 o critério de rateio por VOLUME
	*/ 
	nPosIni := TamSx3("GW1_FILIAL")[1] + TamSx3("GW1_CDTPDC")[1] + TamSx3("GW1_EMISDC")[1] + TamSx3("GW1_SERDC")[1]
	nPosFim := TamSx3("GW1_NRDC")[1]

	nTamUnidades := Len(aUnidades)
	If Empty(aDocAux)
		For nX := 1 To nTamUnidades	
			nPos2 := ASCAN(aDocAux,{|x|x[1] == SubStr(aUnidades[nX][24], nPosIni, nPosFim)})
			If nPos2 == 0
				aAdd(aDocAux, { SubStr(aUnidades[nX][24], nPosIni, nPosFim),;
								0,;
								{aUnidades[nX][1]}})
			Else
				aAdd(aTail(aDocAux[nPos2]),aUnidades[nX][1])
			EndIf	
		Next nX
	EndIf

	nDocs := Len(aDocAux)
	For nX := 1 To nDocs
		nTamUnid := Len(aTail(aDocAux[nx]))
		For nY := 1 To nTamUnid
			// Verifico se essa unidade de calculo usada no documento posicionado (aDocAux[nx]), possui o mesmo trecho
			// da unidade de calculo em processamento (cUnidCalc). Se for o mesmo
			nPos2 := ASCAN(aUnidades,{|x|x[1] == aDocAux[nX][3][nY]})
			If nPos2 > 0
				If SubStr(aUnidades[nPos2][24], Len(aUnidades[nPos2][24]) - 1, 2) == cTrechoUn
					lTrecho := .T.
				Else
					lTrecho := .F.
				EndIf
			EndIf

			nPos := AScan(aParamComp, {|x| x[1] == cCdComp .And. x[6] == aDocAux[nX][3][nY]})
			If nPos > 0 .And. lTrecho
				nPosD := ASCAN(aTotCalc,{|x|x[1] == aDocAux[nX][3][nY]})

				nTotalComponente += aTotCalc[nPosD][nPosicao]
				aDocAux[nX][2] := aTotCalc[nPosD][nPosicao]
				nContComp++
				Exit
			EndIf
		Next nY
	Next nX

	For nX := 1 To Len(aDocAux)
		For nY := 1 To Len(aTail(aDocAux[nx]))
			If aDocAux[nX][3][nY] == cUnidCalc
				If aDocAux[nX][2] > 0 .And. nTotalComponente > 0
					nValor 	:= aDocAux[nX][2] / nTotalComponente
					cDesc 	:= cValToChar(aDocAux[nX][2]) + "/" + cValToChar(nTotalComponente)
					nQtde	:= aDocAux[nX][2]
					lPassou := .T.
				Else
					cDesc 	:= "1" + "/" + cValToChar(nContComp)
				EndIf
				Exit
			EndIf	
		Next nY

		If lPassou
			Exit
		EndIf
	Next nX

	aAdd(aValor, nValor)
	aAdd(aValor, cDesc)
	aAdd(aValor, nContComp)
	aAdd(aValor, nQtde)

Return aValor

/*----------------------------------------------------------------------------
{Protheus.doc} GFEGetTPOP
Busca o Código Tipo de Operação da negociação de frete. 

@sample GFEGetTPOP("01","001","123")

@param  cNrTab    Número da tabela de frete
@param  cNrNeg    Número da negociação de frete

@author Leonardo Ribas Jimenez Hernandez
@since 29/10/19
@version 1.0
----------------------------------------------------------------------------*/
Function GFEGetTPOP(cNrTab,cNrNeg,cTransp)

Local cAliasQry := Nil
Local cCDTPOP	:= ""
	
	cAliasQry := GetNextAlias()
	BeginSql Alias cAliasQry
		SELECT GV9.GV9_CDTPOP
		FROM %Table:GV9% GV9
		WHERE GV9.GV9_FILIAL = %xFilial:GV9%
		AND GV9.GV9_CDEMIT = %Exp:cTransp%
		AND GV9.GV9_NRTAB = %Exp:cNrTab%
		AND GV9.GV9_NRNEG = %Exp:cNrNeg%
		AND GV9.%NotDel%
	EndSql
	
	If (cAliasQry)->(!EOf())
		cCDTPOP := (cAliasQry)->GV9_CDTPOP
	EndIf

	(cAliasQry)->(DbCloseArea())
Return cCDTPOP
