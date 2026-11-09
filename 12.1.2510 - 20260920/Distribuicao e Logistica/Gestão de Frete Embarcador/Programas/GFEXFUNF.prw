#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

// Critério de Rateio
#DEFINE R_PESO 			'1'
#DEFINE R_VALOR			'2'
#DEFINE R_VOLUME 		'3'
#DEFINE R_QUANTIDADE 	'4'

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFECalcRatItem()
Realiza o rateio do valor do frete pelos items do documento de carga

@sample
GFECalcRatItem(nOrigem, aChave, cCriterio, lLog)
nOrigem: Origem do valor do cálculo
	1: Calculo de Frete
	2: Documento de Frete
	3: Contrato
	
aChave: Array com a chave de acordo com a origem
	Origem = 1: GWF_FILIAL + GWF_NRCALC
	Origem = 2: GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF + GW3_DTEMIS
	Origem = 3: GW2_FILIAL + GW2_NRCONT
	
cCriterio: Critério de rateio (Opcional) Default: MV_CRIRAT
	"1" : Fator por Peso
	"2" : Fator por Valor
	"3" : Fator por Volume(m3)
	"4" : Fator por Quantidade

lLog: Geração de arquivo de log (Opcional) Default: Falso

@return
Retorna um array de duas dimensões (linhas x colunas) com todos os items que fazem parte da composição do valor do frete com os valores rateados
[linha, 1]  (GW8_FILIAL) Filial do Item
[linha, 2]  (GW8_CDTPDC) Código do tipo de Documento
[linha, 3]  (GW8_EMISDC) Emissor do Documento
[linha, 4]  (GW8_SERDC)  Série do Documento
[linha, 5]  (GW8_NRDC)   Número do Documento de Carga 
[linha, 6]  (GW8_SEQ)    Sequência 
[linha, 7]  (GW8_ITEM)   Item 
[linha, 8]  (GW8_RATEIO) Faz parte do Rateio?
[linha, 9]  Valor do critério do rateio (Fator)
[linha, 10] Percentual em relação ao fator total (Soma de todos os valores do critério do rateio)
[linha, 11] Valor do Frete Rateado
[linha, 12] ICMS Rateado
[linha, 13] PIS Rateado
[linha, 14] COFINS Rateado
[linha, 15] ISS Rateado
[linha, 16] INSS AUTON Rateado
[linha, 17] INSS Emb Rateado
[linha, 18] IRRF Rateado
[linha, 19] SEST/SENAT Rateado

@author Israel Alcantara Possoli
@since 23/12/2011
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFECalcRatItem(nOrigem, aChave, cCriterio, lLog)
	Local aAreaGWF    := GWF->(getArea())
	Local aAreaGWH    := GWH->(getArea())
	Local aAreaGW1    := GW1->(getArea())
	Local aAreaGW8    := GW8->(getArea())
	Local aAreaGW3    := GW3->(getArea())
	Local aAreaGW4    := GW4->(getArea())
		
	/* aItens - Array de duas dimensões contendo os itens relacionado ao valor do frete
		[n, 1]  (GW8_FILIAL) Filial do Item
		[n, 2]  (GW8_CDTPDC) Código do tipo de Documento
		[n, 3]  (GW8_EMISDC) Emissor do Documento
		[n, 4]  (GW8_SERDC)  Série do Documento
		[n, 5]  (GW8_NRDC)   Número do Documento de Carga 
		[n, 6]  (GW8_SEQ)    Sequência 
		[n, 7]  (GW8_ITEM)   Item 
		[n, 8]  (GW8_RATEIO) Faz parte do Rateio?
		[n, 9]  Valor do critério do rateio (Fator)
		[n, 10] Percentual em relação ao fator total (Soma de todos os valores do critério do rateio)
		[n, 11] Valor do Frete Rateado
		[n, 12] ICMS Rateado
		[n, 13] PIS Rateado
		[n, 14] COFINS Rateado
		[n, 15] ISS Rateado
		[n, 16] INSS AUTON Rateado
		[n, 17] INSS Emb Rateado
		[n, 18] IRRF Rateado
		[n, 19] SEST/SENAT Rateado */
	Local aItens      := {}			// Agrupamento de Items 
	
	/* aValores - Total dos valores que serão rateados
	   [1] Valor do Frete
	   [2] ICMS
	   [3] PIS
	   [4] COFINS
	   [5] ISS
	   [6] INSS AUTON
	   [7] INSS Emb
	   [8] IRRF
	   [9] SEST/SENAT */
	Local aValores[9]				
	
	Local nItemFatorMaior[2] 		// Item com maior fator - [1] ID, [2] Valor. Item (aItens) com o maior fator para distribuir os centavos e % extras
	Local nItemPercentTotal := 0	// Somatória do percentual rateado dos itens para comparação com o total (100%)
	Local nFatorTotalItem  := 0 	// Somatório do valor fator dos itens (critério de rateio)
	
	/* aItemValorTotal - Possui a mesma estrutura de aValores
	   Somatório dos valores rateados dos itens para comparação ao valor origem (aValores) para reajuste do resto do cálculo do rateio*/
	Local aItemValorTotal[9]
	Local nI
	Local lRateio     := .T.			// Flag de controle para a execução do rateio e evitar dar return antes da execução dos RestArea
	Local cNrDoc      := ""
	Private lGerarLog := .F.
	Private cArquivoLog := "RateioItens_%ORIGEM%_%DOC%"
	Private cTituloLog := "Rateio de Itens"
	Private GFELogRat
	
	Default cCriterio := SuperGetMv("MV_CRIRAT",,"1")
	Default lLog := .F.
	
	lGerarLog := lLog
	
	// Verifica se será gerado log de rateio dos itens
	If SuperGetMv("MV_LOGCONT",, "1") == "1"
		lGerarLog := .T.
	Else
		lGerarLog := .F.
	EndIf

	// Inicia vetores
	aFill(aItemValorTotal, 0) // Inicia o vetor com todos os 9 itens com o valor 0
	aFill(aValores, 0)
	
	Do Case
		Case nOrigem == 1
			cNrDoc := aChave[2]
			GFEInitLog(nOrigem, cNrDoc, "Rateio por Cálculo de Frete")
			GFELogRat:Add("Filial: " + ALLTRIM(aChave[1]) + ", Cálculo Nr: " + ALLTRIM(aChave[2]))
			
		Case nOrigem == 2 //GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF
			cNrDoc := aChave[5]
			GFEInitLog(nOrigem, cNrDoc, "Rateio por Documento de Frete")
			GFELogRat:Add("Filial: " + ALLTRIM(aChave[1]) + ", Espécie: " + ALLTRIM(aChave[2]) + ", Emissor: " + ALLTRIM(aChave[3]) + ", Série: " + ALLTRIM(aChave[4]) + ", Número: " + ALLTRIM(aChave[5]) + ", Data Emissão: " + DToC(aChave[6]))
			
		Case nOrigem == 3
			cNrDoc := aChave[2]
			GFEInitLog(nOrigem, cNrDoc, "Rateio por Contrato")
			GFELogRat:Add("Filial: " + ALLTRIM(aChave[1]) + ", Contrato Nr: " + ALLTRIM(aChave[2]))
	EndCase
	
	
	// ----------------------------------------------------------------
	// Busca o valor do frete
	// ----------------------------------------------------------------
	aValores := GFEVlrFrete(nOrigem, aChave)
	
	If aValores == Nil
		GFELogRat:Add(" ** Não foi possível obter o valor do frete para o rateio.")
		lRateio := .F.
	EndIf
	
	DO CASE	
		CASE cCriterio == "1" //peso
			GFELogRat:Add("Critério de Rateio: Peso")
		CASE cCriterio == "2" //Valor
			GFELogRat:Add("Critério de Rateio: Valor")
		CASE cCriterio == "3" //Volume (M3)
			GFELogRat:Add("Critério de Rateio: Volume(m3)")
		CASE cCriterio == "4" //Quantidade
			GFELogRat:Add("Critério de Rateio: Quantidade")
	EndCase
	
	// ----------------------------------------------------------------
	// Busca dos itens
	// ----------------------------------------------------------------
	
	GFELogRat:Add("")
	GFELogRat:Add("Documentos: ")
	// Busca os itens através do cálculo de frete ---------------------
	If nOrigem == 1 .AND. lRateio
		dbSelectArea("GWH")
		dbsetorder(1)
		If dbseek(aChave[1] + aChave[2])	// FILIAL + NRCALC
			While !GWH->(EOF()) .AND. GWH->GWH_NRCALC == aChave[2]
			
				GFELogRat:Add("> Série: " + AllTrim(GWH->GWH_SERDC) + ", Doc. Carga: " + ALLTRIM(GWH->GWH_NRDC), 1)
				CriaItemRat(@aItens, @nFatorTotalItem, cCriterio, {GWH->GWH_FILIAL, GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC})
				GWH->(dbSkip())
			EndDo
		Else
			GFELogRat:Add("** Cálculo não encontrado")
			lRateio := .F.
		EndIf
	EndIf
	
	// Busca os itens através do documento de frete -------------------
	If nOrigem == 2 .AND. lRateio
		dbSelectArea("GW3")
		dbSetOrder(1)
		If dbSeek(aChave[1] + aChave[2] + aChave[3] + aChave[4] + aChave[5] + DToS(aChave[6])) // FILIAL + CDESP + EMISDF + SERDF + NRDF + DTEMIS
			dbSelectArea("GW4")
			dbSetOrder(1)
			If dbSeek(GW3->GW3_FILIAL+GW3->GW3_EMISDF+GW3->GW3_CDESP+GW3->GW3_SERDF+GW3->GW3_NRDF)
				While !GW4->(EOF()) .AND. ;
					   GW4->GW4_FILIAL = GW3->GW3_FILIAL .AND.;
					   GW4->GW4_EMISDF = GW3->GW3_EMISDF .AND.;
					   GW4->GW4_CDESP  = GW3->GW3_CDESP  .AND.;
					   GW4->GW4_SERDF  = GW3->GW3_SERDF  .AND.;
					   GW4->GW4_NRDF   = GW3->GW3_NRDF
					   
					GFELogRat:Add("> Série: " + AllTrim(GW4->GW4_SERDF) + ", Doc. Carga: " + ALLTRIM(GW4->GW4_NRDC), 1)
					CriaItemRat(@aItens, @nFatorTotalItem, cCriterio, {GW4->GW4_FILIAL, GW4->GW4_TPDC, GW4->GW4_EMISDC, GW4->GW4_SERDC, GW4->GW4_NRDC})
					GW4->( dbSkip() )
				EndDo
			EndIf
		Else
			GFELogRat:Add("** Documento de Frete não encontrado")
			lRateio := .F.
		EndIf
	EndIf
	
	// Busca os itens através do documento de frete -------------------
	If nOrigem == 3 .AND. lRateio
		dbSelectArea("GWF")
		dbSetOrder(2)
		If dbSeek(aChave[1] + aChave[2])
			While !GWF->( EOF() ) .AND. GWF->GWF_FILIAL == aChave[1] .AND. GWF->GWF_NRCONT == aChave[2]
				GFELogRat:Add("> Cálculo: " + ALLTRIM(GWF->GWF_NRCALC), 1)
				
				dbSelectArea("GWH")
				dbsetorder(1)
				dbSeek(GWF->GWF_FILIAL + GWF->GWF_NRCALC)
				While !GWH->(EOF()) .AND. GWH->GWH_NRCALC == GWF->GWF_NRCALC
					CriaItemRat(@aItens, @nFatorTotalItem, cCriterio, {GWH->GWH_FILIAL, GWH->GWH_CDTPDC, GWH->GWH_EMISDC, GWH->GWH_SERDC, GWH->GWH_NRDC})
					GWH->(dbSkip())
				EndDo
				GWF->(dbSkip())
			EndDo
		EndIf
	EndIf
	
	If LEN(aItens) == 0
		GFELogRat:Add("** Nenhum item encontrado, cancelando rateio.")
		lRateio := .F.
	EndIf
	
	If lRateio
		GFELogRat:Add("")
		GFELogRat:Add("---[ TOTAIS ]----------------------------------")
		GFELogRat:Add("Total de Itens.....: " + ALLTRIM(STR(LEN(aItens))), 2)
		GFELogRat:Add("Fator Total do Item: " + ALLTRIM(STR(nFatorTotalItem)), 2)
		GFELogRat:Add("Valor do Frete.....: " + ALLTRIM(STR(aValores[1])), 2)
		GFELogRat:Add("ICMS...............: " + ALLTRIM(STR(aValores[2])), 2)
		GFELogRat:Add("PIS................: " + ALLTRIM(STR(aValores[3])), 2)
		GFELogRat:Add("COFINS.............: " + ALLTRIM(STR(aValores[4])), 2)
		GFELogRat:Add("ISS................: " + ALLTRIM(STR(aValores[5])), 2)
		GFELogRat:Add("ISS AUTON..........: " + ALLTRIM(STR(aValores[6])), 2)
		GFELogRat:Add("ISS EMB............: " + ALLTRIM(STR(aValores[7])), 2)
		GFELogRat:Add("IRRF...............: " + ALLTRIM(STR(aValores[8])), 2)
		GFELogRat:Add("SEST/SENAT.........: " + ALLTRIM(STR(aValores[9])), 2)
		GFELogRat:Add("-----------------------------------------------")
	EndIf
		
	// ----------------------------------------------------------------
	// Realiza o Rateio
	// ----------------------------------------------------------------
	nItemFatorMaior[1] := 0
	nItemFatorMaior[2] := 0
	nItemPercentTotal  := 0
	
	
	GFELogRat:Add("")
	GFELogRat:Add("|---[ ITENS RATEADOS ]--------------------------------------------------------------------------|")
	GFELogRat:Add("| #  | Item                     |   %   | Valor       | ICMS        | PIS         | COFINS      |")
	GFELogRat:Add("|----|--------------------------|-------|-------------|-------------|-------------|-------------|")
	
	For nI := 1 To Len(aItens)
		// Verifica se o item fará parte do rateio
		If aItens[nI][8] == "2"
			GFELogRat:Add("|" + PadL(cValToChar(nI), 4) + "| " + Padr(aItens[nI][8], 25) + "| Item não faz parte do rateio" + Space(31) + "|")
			Loop
		EndIf	

		// Armazena o Item com o maior fator
		If aItens[nI][9] > nItemFatorMaior[2]
			nItemFatorMaior[1] := nI
			nItemFatorMaior[2] := aItens[nI][9]
		EndIf

		// Percentual = Fator Item x 100 / Fator Total Item
		aItens[nI][10] :=  Round(CalculaRateio(aItens[nI][9], 100, nFatorTotalItem),2)
		nItemPercentTotal += aItens[nI][10]

		// Valor do Frete = Fator Item X Valor Frete / Fator Total Item
		aItens[nI][11] :=  NoRound(CalculaRateio(aItens[nI][9], aValores[1], nFatorTotalItem))
		aItemValorTotal[1] += aItens[nI][11]
		
		// ICMS = Fator Item X ICMS / Fator Total Item
		aItens[nI][12] :=  Round(CalculaRateio(aItens[nI][9], aValores[2], nFatorTotalItem),2)
		aItemValorTotal[2] += aItens[nI][12]
		
		// PIS = Fator Item X PIS / Fator Total Item
		aItens[nI][13] :=  NoRound(CalculaRateio(aItens[nI][9], aValores[3], nFatorTotalItem))
		aItemValorTotal[3] += aItens[nI][13]
		
		// COFINS = Fator Item X COFINS / Fator Total Item
		aItens[nI][14] :=  NoRound(CalculaRateio(aItens[nI][9], aValores[4], nFatorTotalItem))
		aItemValorTotal[4] += aItens[nI][14]
		
		// ISS = Fator Item X ISS / Fator Total Item
		aItens[nI][15] :=  Round(CalculaRateio(aItens[nI][9], aValores[5], nFatorTotalItem),2)
		aItemValorTotal[5] += aItens[nI][15]
		
		// INSS AUTON = Fator Item X ISS AUTON / Fator Total Item
		aItens[nI][16] :=  Round(CalculaRateio(aItens[nI][9], aValores[6], nFatorTotalItem),2)
		aItemValorTotal[6] += aItens[nI][16]
		
		// INSS EMB = Fator Item X INSS EMB / Fator Total Item
		aItens[nI][17] :=  Round(CalculaRateio(aItens[nI][9], aValores[7], nFatorTotalItem),2)
		aItemValorTotal[7] += aItens[nI][17]
		
		// IRRF = Fator Item X IRFF / Fator Total Item
		aItens[nI][18] :=  Round(CalculaRateio(aItens[nI][9], aValores[8], nFatorTotalItem),2)
		aItemValorTotal[8] += aItens[nI][18]
		
		// SEST/SENAT = Fator Item X SEST/SENAT / Fator Total Item
		aItens[nI][19] :=  Round(CalculaRateio(aItens[nI][9], aValores[9], nFatorTotalItem),2)
		aItemValorTotal[9] += aItens[nI][19]
		
		GFELogRat:Add("|"  + PadL(cValToChar(nI), 4) 				+ 		;
					  "| " + PadR(aItens[nI][8], 25)  				+ 		;
					  "|"  + PadL(cValToChar(aItens[nI][10]), 6) 	+ " " + ;
					  "|"  + PadL(cValToChar(aItens[nI][11]), 12)	+ " " + ;
					  "|"  + PadL(cValToChar(aItens[nI][12]), 12)	+ " " + ;
					  "|"  + PadL(cValToChar(aItens[nI][13]), 12)	+ " " + ;
					  "|"  + PadL(cValToChar(aItens[nI][14]), 12)	+ " |")
	Next
	
	GFELogRat:Add("|-----------------------------------------------------------------------------------------------|")
	
	If lGerarLog
		GFELogRat:Save()
	EndIf

	// ----------------------------------------------------------------
	// Realiza o reajuste dos valores
	// ----------------------------------------------------------------
	If lRateio
		ReajusteValores(@aItens, nItemPercentTotal, aItemValorTotal, aValores, nItemFatorMaior[1])
	EndIf
	
	GFELogRat:EndLog()
	GFELogRat:= Nil


	RestArea(aAreaGWF)
	RestArea(aAreaGWH)
	RestArea(aAreaGW3)
	RestArea(aAreaGW4)
	RestArea(aAreaGW1)
	RestArea(aAreaGW8)
	
	aSize(nItemFatorMaior, 0)
	nItemFatorMaior := Nil
	
	aSize(aItemValorTotal, 0)
	aItemValorTotal := Nil
	
	If aValores != Nil
		aSize(aValores, 0)
		aValores := Nil
	EndIf
	
Return (aItens)



//---------------------------------------------------------------------------------------------------
/* CalculaRateio()
Calcula o valor rateado com base no fator e valor origem

nFator			Valor do critério do rateio (valor fator do item)
nValorOrigem    Valor que está sendo rateado
nFatorTotal		Valor fator total de todos os itens
nCasasDecimais	Casas decimais do arredondamento (Default = 2)


@author Israel Alcantara Possoli
@since 04/01/2012
@version 1.0
/*///------------------------------------------------------------------------------------------------

Static Function CalculaRateio(nFator, nValorOrigem, nFatorTotal)
	Local nRet := 0
	
	If nValorOrigem == NIL .OR. nFatorTotal == NIL .OR. nValorOrigem == 0 .OR. nFatorTotal == 0
		Return 0
	EndIf
	
	nRet := nFator * nValorOrigem / nFatorTotal	
Return (nRet)

//---------------------------------------------------------------------------------------------------
/* ReajusteValores()
Realiza o reajusate dos valores caso a soma do valor total do rateio seja diferente do valor origem.

Ao realizar o rateio, na divisão dos valores entre os itens, pode ocorrer de um valor ser menor que as casas decimais
de moeda (duas casas após a vírgula) ou menor que uma unidade de porcentagem, dando diferença de um centavo ou um porcento.
Esta função distribui os valores restantes para mais ou para menos no item com maior valor do critério até igualar
ao valor origem.

aItens				Array de itens passado como referência, grava em cada campo dos valores, o valor rateado
nItemPercentTotal	Somatório do percetual total dos itens
aItemValorTotal		Array com a somatório dos valores de todos os itens (passado como referência)
aValores			Valores de origem do rateio
idItemMaiorFator	Id do item com o maior fator

@return
Retorna a posição que o item foi criado

@author Israel Alcantara Possoli
@since 05/01/2012
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function ReajusteValores(aItens, nItemPercentTotal, aItemValorTotal, aValores, idItemMaiorFator)
	If idItemMaiorFator == NIL .OR. idItemMaiorFator == 0
		GFELogRat:Add(" ** Nenhum item encontrado com maior valor. Cancelando reajuste.")
		Return
	EndIf

	// Percentual
	If nItemPercentTotal != 100
		aItens[idItemMaiorFator][10] := aItens[idItemMaiorFator][10] + (100 - nItemPercentTotal)
		GFELogRat:Add("Ajuste do percentual para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Percentual ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][10])))
	EndIf
	
	// Valor do Frete
	If aItemValorTotal[1] != aValores[1]
		aItens[idItemMaiorFator][11] := aItens[idItemMaiorFator][11] + (aValores[1] - aItemValorTotal[1])
		GFELogRat:Add("Ajuste do valor do frete para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][11])))
	EndIf

	// ICMS
	If aItemValorTotal[2] != aValores[2]
		aItens[idItemMaiorFator][12] := aItens[idItemMaiorFator][12] + (aValores[2] - aItemValorTotal[2])
		GFELogRat:Add("Ajuste do valor do ICMS para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][12])))
	EndIf

	// PIS
	If aItemValorTotal[3] != aValores[3]
		aItens[idItemMaiorFator][13] := aItens[idItemMaiorFator][13] + (aValores[3] - aItemValorTotal[3])
		GFELogRat:Add("Ajuste do valor do PIS para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][13])))
	EndIf

	// COFINS
	If aItemValorTotal[4] != aValores[4]
		aItens[idItemMaiorFator][14] := aItens[idItemMaiorFator][14] + (aValores[4] - aItemValorTotal[4])
		GFELogRat:Add("Ajuste do valor do COFINS para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][14])))
	EndIf

	// ISS
	If aItemValorTotal[5] != aValores[5]
		aItens[idItemMaiorFator][15] := aItens[idItemMaiorFator][15] + (aValores[5] - aItemValorTotal[5])
		GFELogRat:Add("Ajuste do valor do ISS para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][15])))
	EndIf

	// INSS Auton
	If aItemValorTotal[6] != aValores[6]
		aItens[idItemMaiorFator][16] := aItens[idItemMaiorFator][16] + (aValores[6] - aItemValorTotal[6])
		GFELogRat:Add("Ajuste do valor do INSS Auton para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][16])))
	EndIf

	// INSS Emb
	If aItemValorTotal[7] != aValores[7]
		aItens[idItemMaiorFator][17] := aItens[idItemMaiorFator][17] + (aValores[7] - aItemValorTotal[7])
		GFELogRat:Add("Ajuste do valor do INSS Emb para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][17])))
	EndIf
	
	// IRRF
	If aItemValorTotal[8] != aValores[8]
		aItens[idItemMaiorFator][18] := aItens[idItemMaiorFator][18] + (aValores[8] - aItemValorTotal[8])
		GFELogRat:Add("Ajuste do valor do IRRF para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][18])))
	EndIf

	// SEST/SENAT
	If aItemValorTotal[9] != aValores[9]
		aItens[idItemMaiorFator][19] := aItens[idItemMaiorFator][19] + (aValores[9] - aItemValorTotal[9])
		GFELogRat:Add("Ajuste do valor do SEST/SENAT para o item com maior fator. ID: " + ALLTRIM(STR(idItemMaiorFator)) + ". Valor ajustado: " + ALLTRIM(STR(aItens[idItemMaiorFator][19])))
	EndIf

	
Return




//---------------------------------------------------------------------------------------------------
/* CriaItem()
Busca o documento de carga e adiciona os itens no array aItens

aItens			Array de itens passado como referência
nFatorTotalItem   Fator acumulativo passado como referência
cCriterio		Criterio do rateio
cChaveGW1		Chave do Documento de Carga

@return
Retorna a posição que o item foi criado

@author Israel Alcantara Possoli
@since 04/01/2012
@version 1.0
/*///------------------------------------------------------------------------------------------------
Static Function CriaItemRat(aItens, nFatorTotalItem, cCriterio, aChaveGW1)
	/* aItem - Dados do item
	   [1] FILIAL
	   [2] CDTPDC
	   [3] EMISDC
	   [4] SERDC
	   [5] NRDC
	   [6] SEQ
	   [7] ITEM
	   [8] Rateio?
	   [9] VALOR FATOR
	   [10] Percentual
	   [11] Valor do Frete Rateado
	   [12] ICMS Reateado
	   [13] PIS Reateado
	   [14] COFINS Reateado
	   [15] ISS Reateado
	   [16] INSS AUTON Reateado
	   [17] INSS Emb Reateado
	   [18] IRRF Reateado
	   [19] SEST/SENAT */
	Local aItem[20] // O tamanho do array é redefinido a cada item (matriz dentro de matriz é tratada como referência se não limpada da memória)
	
	Local nFatorItem := 0
	
	dbSelectArea("GW1")
	dbsetorder(1)
	If dbseek(aChaveGW1[1] + aChaveGW1[2] + aChaveGW1[3] + aChaveGW1[4] + aChaveGW1[5])
		While !GW1->(EOF()) .AND.;
		       GW1->GW1_FILIAL = aChaveGW1[1] .AND.;
			   GW1->GW1_CDTPDC = aChaveGW1[2] .AND.;
			   GW1->GW1_EMISDC = aChaveGW1[3] .AND.;
			   GW1->GW1_SERDC  = aChaveGW1[4] .AND.;
			   GW1->GW1_NRDC   = aChaveGW1[5]
			   
				dbSelectArea("GW8")
				dbsetorder(1)
				dbseek(GW1->GW1_FILIAL + GW1->GW1_CDTPDC + GW1->GW1_EMISDC + GW1->GW1_SERDC + GW1->GW1_NRDC)
				While !GW8->(EOF()) .AND.;
				       GW8->GW8_FILIAL = GW1->GW1_FILIAL .AND.;
					   GW8->GW8_CDTPDC = GW1->GW1_CDTPDC .AND.;
					   GW8->GW8_EMISDC = GW1->GW1_EMISDC .AND.;
					   GW8->GW8_SERDC  = GW1->GW1_SERDC  .AND.;
					   GW8->GW8_NRDC   = GW1->GW1_NRDC
					   
					   	aItem := Array(20)
					   
						aItem[1]  := GW8->GW8_FILIAL
						aItem[2]  := GW8->GW8_CDTPDC
						aItem[3]  := GW8->GW8_EMISDC
						aItem[4]  := GW8->GW8_SERDC
						aItem[5]  := GW8->GW8_NRDC
						aItem[6]  := GW8->GW8_SEQ
						aItem[7]  := GW8->GW8_ITEM
						aItem[8]  := GW8->GW8_RATEIO
						aItem[20] := GW1->GW1_DTEMIS
						
						nFatorItem  := 0
						DO CASE
							CASE cCriterio == "1" //peso
								nFatorItem  := GW8->GW8_PESOR 
							CASE cCriterio == "2" //Valor
								nFatorItem  := GW8->GW8_VALOR
							CASE cCriterio == "3" //Volume (M3)
								nFatorItem  := GW8->GW8_VOLUME
							CASE cCriterio == "4" //Quantidade
								nFatorItem  := GW8->GW8_QTDE
						EndCase
						
						aItem[9] := nFatorItem
						
						aADD(aItens, aItem)
						If GW8->GW8_RATEIO == "1"
							nFatorTotalItem += aItem[9]
						EndIf
						dbSelectArea("GW8")
						GW8->(dbSkip())
				EndDo
			dbSelectArea("GW1")
			GW1->(dbSkip())
		EndDo
	EndIf
Return


//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GFEVlrFrete()
Retorna o valor do frete apartir de um cálculo de frete, documento de frete, contrato ou documento de carga

@sample
GFEVlrFrete(1, {"  ", "00000024"})


nOrigem:
	Origem de como o cálculo será buscado:
		1- Calculo de Frete
		2- Documento de Frete
		3- Contrato
		4- Documento de Carga
	
aChave:
	Array com a chave de acordo com a origem
	Origem 1: GWF_FILIAL + GWF_NRCALC
	Origem 2: GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF + GW3_DTEMIS
	Origem 3: GW2_FILIAL + GW2_NRCONT
	Origem 4: GW1_FILIAL + GW1_CDTPDC + GW1_EMISDC + GW1_SERDC + GW1_NRDC


@return
Retorna o valor do frete

@author Israel Alcantara Possoli
@since 23/12/2011
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Function GFEVlrFrete(nOrigem, aChave)
	Local aAreaGWF    := GWF->(getArea())
	Local aAreaGWI    := GWI->(getArea())
	Local aAreaGW2    := GW2->(getArea())
	Local aAreaGW3    := GW3->(getArea())
	
	/* [1] Valor do Frete
	   [2] ICMS
	   [3] PIS
	   [4] COFINS
	   [5] ISS
	   [6] INSS AUTON
	   [7] INSS Emb
	   [8] IRRF
	   [9] SEST/SENAT */	
	Local aRet := Array(9)
	
	aFill(aRet, 0)
	
	DO CASE
		// Cálculo de Frete
		CASE nOrigem == 1
			dbSelectArea("GWF")
			dbSetOrder(1)
			//        GWF_FILIAL + GWF_NRCALC
			If dbSeek(aChave[1] + aChave[2])
				
				//Valor do Frete
				aRet[1] := VLTOTFRET(GWF->GWF_NRCALC)
				// ICMS
				aRet[2] := GWF->GWF_VLICMS
				// PIS
				aRet[3] := GWF->GWF_VLPIS
				// COFINS
				aRet[4] := GWF->GWF_VLCOFI
				// ISS
				aRet[5] := GWF->GWF_VLISS
				
			Else
				aRet := Nil
			EndIf
			
		// Documento de Frete
		CASE nOrigem == 2
			// Verifica se o Documento de Frete existe
			
			dbSelectArea("GW3")
			dbSetOrder(1)
			//        FILIAL      CDESP       EMISDF      SERDF       NRDF        DTEMIS
			If dbSeek(aChave[1] + aChave[2] + aChave[3] + aChave[4] + aChave[5] + DToS(aChave[6]))
				
				//Valor do Frete
				aRet[1] := GW3->GW3_VLDF
				// ICMS ou ISS
				dbSelectArea("GVT")
				GVT->( dbSetOrder(1) )
				If GVT->( dbSeek(xFilial("GVT") + GW3->GW3_CDESP) )
					If GVT->GVT_TPIMP == "1"
						aRet[2] := GW3->GW3_VLIMP //ICMS
					Else
						aRet[5] := GW3->GW3_VLIMP //ISS
					EndIf		
				EndIf			
				// PIS
				aRet[3] := GW3->GW3_VLPIS
				// COFINS
				aRet[4] := GW3->GW3_VLCOF
				
			Else
				GFELogRat:Add("** Documento de frete não encontrado. Filial: " + aChave[1] + ", Esp: " + aChave[2] + ", Emissor: " + aChave[3] + ", Serie: " + aChave[4] + ", Nr: " + aChave[5] + ", Data: " + DToS(aChave[6]))
				aRet := Nil
			EndIf
			
		// Contrato
		CASE nOrigem == 3
			dbSelectArea("GW2")
			dbSetOrder(1)
			If dbSeek(aChave[1] + aChave[2])
				If GW2->GW2_SITCON == "2" .OR. GW2->GW2_SITCON == "3"
					// Valor do Frete (Líquido)
					aRet[1] := GW2->GW2_VLLIQ
					// ISS
					aRet[5] += GW2->GW2_VLISS
					// INSS AUTON
					aRet[6] := GW2->GW2_VLINSS
					// INSS EMB
					aRet[7] := GW2->GW2_VLINEM
					// IRRF
					aRet[8] := GW2->GW2_VLIRRF
					// SEST/SENAT
					aRet[9] := GW2->GW2_VLSEST
				Else
					aRet := Nil
				EndIF
			Else
				aRet := Nil
			EndIf
	EndCase
	
	RestArea(aAreaGWF)
	RestArea(aAreaGWI)
	RestArea(aAreaGW2)
	RestArea(aAreaGW3)
	
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GFEInitLog
Inicializa a classe de geração de log
Uso Interno

@sample GFEInitLog()

@author Israel A Possoli
@since 24/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GFEInitLog(nOrigem, cDocumento, cTitulo)
	Local cOrigem := ""
	
	Do Case
		Case nOrigem == 1
			cOrigem 	:= "CLC"
			cTituloLog 	:= "Rateio por cálculo de frete"
		Case nOrigem == 2
			cOrigem 	:= "DF"
			cTituloLog 	:= "Rateio por documento de frete"
		Case nOrigem == 3
			cOrigem 	:= "CON"
			cTituloLog 	:= "Rateio por contrato"
	EndCase
	
	cArquivoLog := StrTran(cArquivoLog, "%ORIGEM%", ALLTRIM(cOrigem))
	cArquivoLog := StrTran(cArquivoLog, "%DOC%",    ALLTRIM(cDocumento))
	
	GFELogRat := GFELog():New(cArquivoLog, cTitulo, If(lGerarLog, "2", "1"))
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GFERatDocCarga
Retorna o valor to frete rateado para um determinado Documento de Carga 
da tabela GWM.
Uso: GFERatDocCarga

@sample GFERatDocCarga()

@author Hercilio Henning Neto
@since 16/01/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function GFERatDocCarga(aChaveGW1, aChaveGWF, cCriterio, clayout)
	Local nValRat 		:= 0
	Local nValISS 		:= 0
	Local nValICMS 		:= 0
	Local cGWU_CDTRP	:= ""
	
	If clayout == 2
		cGWU_CDTRP	:= (cAliasSQL)->GWU_CDTRP
	Else
		cGWU_CDTRP	:= (cAliasQry)->GWU_CDTRP	 
	EndIf

	//Soma a GWM para o Documento de Carga passado no parâmetro
	GWM->( dbSetOrder(2) )
	GWM->( dbSeek(aChaveGW1[1]+aChaveGW1[2]+aChaveGW1[3]+aChaveGW1[4]+aChaveGW1[5]) )
	While !GWM->( Eof() ) .And. aChaveGW1[1] == GWM->GWM_FILIAL ;
			.And. aChaveGW1[2] == GWM->GWM_CDTPDC ;
			.And. aChaveGW1[3] == GWM->GWM_EMISDC ;
			.And. aChaveGW1[4] == GWM->GWM_SERDC ;
			.And. aChaveGW1[5] == GWM->GWM_NRDC
		
		If GWM->GWM_TPDOC == '1' .And. cGWU_CDTRP == GWM->GWM_CDTRP ;
		   .And. alltrim(GWM->GWM_NRDOC) == alltrim(aChaveGWF[2])
		
			Do Case 
				Case cCriterio == "1" 
					nValRat += GWM->GWM_VLFRET
					nValISS += GWM->GWM_VLISS
					nValICMS += GWM->GWM_VLICMS
				Case cCriterio == "2"
					nValRat += GWM->GWM_VLFRE1
					nValISS += GWM->GWM_VLISS1
					nValICMS += GWM->GWM_VLICM1
				Case cCriterio == "3"
					nValRat += GWM->GWM_VLFRE3
					nValISS += GWM->GWM_VLISS3
					nValICMS += GWM->GWM_VLICM3
				Case cCriterio == "4"
					nValRat += GWM->GWM_VLFRE2
					nValISS += GWM->GWM_VLISS2
					nValICMS += GWM->GWM_VLICM2
			EndCase
		EndIF
	
		GWM->( dbSkip() )
	EndDo

Return {nValRat,nValISS,nValICMS}

//---------------------------------------------------------------------------------------------------
/* GFERatDFSimp()
Função para realizar o rateio simplificado do valor do documento de frete entre os itens do documentos de carga.
Esta função substitui a função de rateio da GFEXFUNC em situações que necessitam de performance.
OBS: Esta função não serve para contabilização, pois não escolhe as contas para os itens.

	
aChave: Array com a chave do documento de frete:
	Origem = 2: GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF + GW3_DTEMIS

@author Israel Alcantara Possoli
@since 23/03/2015
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function GFERatDFSimp(aChave)
	Local cQuery
	Local aItens
	Local aItensPes
	Local aItensVal
	Local aItensVol
	Local aItensQtd
	Local nI
	Local cCriterio  := SuperGetMv("MV_CRIRAT" ,,"1")

	/*
		[linha, 1]  (GW8_FILIAL) Filial do Item
		[linha, 2]  (GW8_CDTPDC) Código do tipo de Documento
		[linha, 3]  (GW8_EMISDC) Emissor do Documento
		[linha, 4]  (GW8_SERDC)  Série do Documento
		[linha, 5]  (GW8_NRDC)   Número do Documento de Carga 
		[linha, 6]  (GW8_SEQ)    Sequência 
		[linha, 7]  (GW8_ITEM)   Item 
		[linha, 8]  (GW8_RATEIO) Faz parte do Rateio?
		[linha, 9]  Valor do critério do rateio (Fator)
		[linha, 10] Percentual em relação ao fator total (Soma de todos os valores do critério do rateio)
		[linha, 11] Valor do Frete Rateado
		[linha, 12] ICMS Rateado
		[linha, 13] PIS Rateado
		[linha, 14] COFINS Rateado
		[linha, 15] ISS Rateado
		[linha, 16] INSS AUTON Rateado
		[linha, 17] INSS Emb Rateado
		[linha, 18] IRRF Rateado
		[linha, 19] SEST/SENAT Rateado	
	*/

	// Calcula o rateio para todos os critérios de rateio
	aItensPes := GFECalcRatItem(2, aChave, R_PESO, .T.)
	aItensVal := GFECalcRatItem(2, aChave, R_VALOR, .T.)
	aItensVol := GFECalcRatItem(2, aChave, R_VOLUME, .T.)
	aItensQtd := GFECalcRatItem(2, aChave, R_QUANTIDADE, .T.)

	// O campo GWM_PCRAT (Percentual de Rateio) é único (não existe um para cada tipo de rateio)
	// Então considera o critério de rateio definido em MV_CRIRAT como determinante
	DO CASE
		CASE cCriterio == "1" //Peso
			aItens := AClone(aItensPes)
		CASE cCriterio == "2" //Valor				
			aItens := AClone(aItensVal)				
		CASE cCriterio == "3" //Volume (M3)
			aItens := AClone(aItensVol)						
		CASE cCriterio == "4" //Quantidade
			aItens := AClone(aItensQtd)									
	ENDCASE		

	cQuery := "DELETE FROM " + RetSqlName('GWM')
	cQuery += " WHERE GWM_FILIAL = '"+ aChave[1] +"'"
	cQuery +=   " AND GWM_TPDOC  = '2'"
	cQuery +=   " AND GWM_CDESP  = '"+ aChave[2] +"'"
	cQuery +=   " AND GWM_CDTRP  = '"+ aChave[3] +"'"
	cQuery +=   " AND GWM_SERDOC = '"+ aChave[4] +"'"
	cQuery +=   " AND GWM_NRDOC  = '"+ aChave[5] +"'"
	TCSQLExec(cQuery)
	
	// GW3_FILIAL + GW3_CDESP + GW3_EMISDF + GW3_SERDF + GW3_NRDF

	For nI := 1 To Len(aItens)

		dbSelectArea("GWM")
		RecLock("GWM", .T.)
			GWM->GWM_FILIAL := aChave[1]
			GWM->GWM_TPDOC	:= "2"
			GWM->GWM_CDESP	:= aChave[2]
			GWM->GWM_CDTRP	:= aChave[3]
			GWM->GWM_SERDOC := aChave[4]
			GWM->GWM_NRDOC	:= aChave[5]
			GWM->GWM_DTEMIS := aChave[6]
			
			GWM->GWM_CDTPDC := aItens[nI, 2]
			GWM->GWM_EMISDC := aItens[nI, 3]
			GWM->GWM_SERDC  := aItens[nI, 4]
			GWM->GWM_NRDC  	:= aItens[nI, 5]
			GWM->GWM_DTEMDC := aItens[nI, 20]
			
			GWM->GWM_SEQGW8 := aItens[nI, 6]
			GWM->GWM_ITEM   := aItens[nI, 7]
			
			GWM->GWM_PCRAT	:= aItens[nI, 10]
			
			// Peso
			GWM->GWM_VLFRET := aItensPes[nI, 11]
			GWM->GWM_VLICMS := aItensPes[nI, 12]
			GWM->GWM_VLPIS  := aItensPes[nI, 13]
			GWM->GWM_VLCOFI := aItensPes[nI, 14]
			GWM->GWM_VLISS  := aItensPes[nI, 15]
			GWM->GWM_VLINAU := aItensPes[nI, 16]
			GWM->GWM_VLINEM := aItensPes[nI, 17]
			GWM->GWM_VLIRRF := aItensPes[nI, 18]
			GWM->GWM_VLSEST := aItensPes[nI, 19]				
			
			// Valor				
			GWM->GWM_VLFRE1 := aItensVal[nI, 11]
			GWM->GWM_VLICM1 := aItensVal[nI, 12]
			GWM->GWM_VLPIS1 := aItensVal[nI, 13]
			GWM->GWM_VLCOF1 := aItensVal[nI, 14]
			GWM->GWM_VLISS1 := aItensVal[nI, 15]
			GWM->GWM_VLINA1 := aItensVal[nI, 16]
			GWM->GWM_VLINE1 := aItensVal[nI, 17]
			GWM->GWM_VLIRR1 := aItensVal[nI, 18]
			GWM->GWM_VLSES1 := aItensVal[nI, 19]
			
			//Volume (M3)
			GWM->GWM_VLFRE3 := aItensVol[nI, 11]
			GWM->GWM_VLICM3 := aItensVol[nI, 12]
			GWM->GWM_VLPIS3 := aItensVol[nI, 13]
			GWM->GWM_VLCOF3 := aItensVol[nI, 14]
			GWM->GWM_VLISS3 := aItensVol[nI, 15]
			GWM->GWM_VLINA3 := aItensVol[nI, 16]
			GWM->GWM_VLINE3 := aItensVol[nI, 17]
			GWM->GWM_VLIRR3 := aItensVol[nI, 18]
			GWM->GWM_VLSES3 := aItensVol[nI, 19]		
			
			// Quantidade
			GWM->GWM_VLFRE2 := aItensQtd[nI, 11]
			GWM->GWM_VLICM2 := aItensQtd[nI, 12]
			GWM->GWM_VLPIS2 := aItensQtd[nI, 13]
			GWM->GWM_VLCOF2 := aItensQtd[nI, 14]
			GWM->GWM_VLISS2 := aItensQtd[nI, 15]
			GWM->GWM_VLINA2 := aItensQtd[nI, 16]
			GWM->GWM_VLINE2 := aItensQtd[nI, 17]
			GWM->GWM_VLIRR2 := aItensQtd[nI, 18]
			GWM->GWM_VLSES2 := aItensQtd[nI, 19]	

		MsUnlock()
	Next
	
	aSize(aItens, 0)
	aItens := Nil

	aSize(aItensPes, 0)
	aItensPes := Nil
	
	aSize(aItensVal, 0)
	aItensVal := Nil
	
	aSize(aItensVol, 0)
	aItensVol := Nil
	
	aSize(aItensQtd, 0)
	aItensQtd := Nil
Return
