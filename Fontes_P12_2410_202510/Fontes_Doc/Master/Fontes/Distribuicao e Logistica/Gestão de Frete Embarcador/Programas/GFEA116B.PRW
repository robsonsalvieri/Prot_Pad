#INCLUDE "GFEA116A.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} GFEA116B - Importação DocCob 5.0

GXI - Fatura de Frete
GXJ - Doc Cargas X Fatura de Frete

Layout:
	000*
	 |- 550*
	 |   |- 551* [Transportadora]
	 |   |   |- 552* [Fatura] (max 500)
	 |   |   |   |- 553 [Impostos]
	 |   |   |   |- 555* [Conhecimentos] (max 5.000)
	 |   |   |   |- 556 [Notas Fiscais] (max 9.999)   
	 |   |- 559* [Totalizador]
	 

@author Israel A. Possoli
@since 20/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function GFEA116B()
	Private cErrosFat				// Erros acumulados para cada Fatura
	Private lShowCabFat	:= .T.		// Mostra o cabeçalho por Fatura
	Private lShowCabFile := .T.		// Mostra o cabeçalho por arquivo
	Private cBuffer					// Conteúdo da Linha 
	Private cRegID					// Código do registro atual
	Private lTranspVld := .F.
	Private cGXI_NRIMP
	Private nCountFat	:= 0
	
	// Arrays com o conteúdo dos registros
	Private aEmitentes[3]
	Private aFatura[30]
	Private aImposto[11]
	Private aCTRCFatura
	
	AddResult(Replicate('-', 50) + CHR(13) + CHR(10) + UPPER(cNomeArq) + CHR(13) + CHR(10) + Replicate('-', 50), 0)
	
	While !GFEFile:FEof()
		If oProcess != Nil
			oProcess:IncRegua2()
		EndIf
		
		cBuffer := FwNoAccent(GFEFile:Line())
		
		If Empty(cBuffer)
			GFEFile:FNext()
			Loop
		EndIf
		
		cRegID := GetStr(cBuffer, 1, 3)
		
		// Leitura da linha corrente
		ReadReg()
		
		GFEFile:FNext()
	EndDo
	
	If nCountFat > 0
		CreateReg()
	EndIf
	
Return .T.


//--------------------------------------------------------------------
// ReadReg - Leitura das linhas
//--------------------------------------------------------------------
Static Function ReadReg()
	// --- 551 [Dados Transportadora] -----------------
	If cRegID == "551"
		If nCountFat > 0
			CreateReg()
		EndIf
		
		nCountFat	 := 0
		lTranspVld 	 := .F.
		cErrosFat 	 := ""
		cMsgPreVal 	 := ""
		lShowCabFat	 := .T.
		
		aFill(aEmitentes, "")
		aFill(aFatura, "")
		aFill(aImposto, "")
		aCTRCFatura := {}
		aSize(aCTRCFatura, 0)
		
		Reg551()
	EndIf

	If lTranspVld
		// --- 552 [Fatura] -------------------------
		If cRegID == "552"
			If nCountFat > 0
				CreateReg()
			EndIf
			
			nCountFat++
			lShowCabFat	 := .T.
			
			aFill(aFatura, "")
			aFill(aImposto, "")
			aCTRCFatura := {}
			aSize(aCTRCFatura, 0)
			
			
			Reg552()
		EndIf
		
		// --- 553 [Impostos] -------------------------
		If cRegID == "553"
			Reg553()
		EndIf
		
		// --- 555 [CTRC] -------------------------
		If cRegID == "555"
			Reg555()
		EndIf
	EndIf

Return .T.


//--------------------------------------------------------------------
// CreateReg - Faz a criação da tabela GXI e GXJ
//--------------------------------------------------------------------
Static Function CreateReg()
	nCountImpor++
	cGXI_NRIMP := ""
	
	PreValidacao()
	
	BuscaGW3()
	
	CreateGXI()
	CreateGXJ()
Return


//--------------------------------------------------------------------
// BuscaGW3 - Busca os conhecimentos importados no registro 555
//--------------------------------------------------------------------
Static Function BuscaGW3()
	Local nI, nNr
	Local lDocFind := .F.
	Local cEmisDf := ""
	Local cNrDf
	Local cNrDFBase
	Local s_EMITMP := SuperGetMV('MV_EMITMP',,'1')
	Local s_ERPGFE := SuperGetMV('MV_ERPGFE',,'1')
	
	GFELog116:Add("- CONHECIMENTOS:", 1)
	For nI := 1 To Len(aCTRCFatura)
		lDocFind := .F.
		cEmisDf  := ""
		
		GFELog116:Add("> Série: " + aCTRCFatura[nI, 3] + ", Número: " + aCTRCFatura[nI, 4] + ", CNPJ Emissor: " + aCTRCFatura[nI, 9], 2)
		
		cNrDFBase := GFEZapZero(aCTRCFatura[nI, 4])
		
		If s_EMITMP == "1" .AND. s_ERPGFE == "2"
			GFELog116:AddDebug("- Busca pelo CNPJ do Emissor, Série e Número.", 3)
			For nNr := Len(cNrDFBase) To TamSX3("GW3_NRDF")[1]
				cNrDf := PadL(cNrDFBase, nNr, "0")
				lDocFind := PosValGW3(aCTRCFatura[nI, 3], cNrDf, aCTRCFatura[nI, 9])
				
				If lDocFind
					cEmisDf := GW3->GW3_EMISDF
					GFELog116:AddDebug("# Tamanho: " + cValToChar(nNr) + ", Número: " + cNrDf + " [Encontrado]", 4)
					Exit
				Else
					GFELog116:AddDebug("# Tamanho: " + cValToChar(nNr) + ", Número: " + cNrDf, 4)
				EndIf
			Next		
		Else
			GFELog116:AddDebug("- Busca pelo Código do Emissor, Série e Número.", 3)
			
			IF !Empty(aCTRCFatura[nI, 9])
				dbSelectArea("GU3")
				dbSetOrder(11)
				If dbSeek(xFilial("GU3") + aCTRCFatura[nI, 9])
					cEmisDf := GU3->GU3_CDEMIT
				Else
					AddPreValid("Transportador não encontrado com o CNPJ (" + aCTRCFatura[nI, 9] + ") do emissor do conhecimento", 3)
				EndIf
			EndIF
					
			
			If !Empty(cEmisDf)
				GFELog116:Add("> Código do Emissor: " + cEmisDf, 4)
				GFELog116:AddDebug("> Busca do número do Documento de Frete:", 4)
				For nNr := Len(cNrDFBase) To TamSX3("GW3_NRDF")[1]
					cNrDf := PadL(cNrDFBase, nNr, "0")
					lDocFind := PosValGW3(aCTRCFatura[nI, 3], cNrDf, , cEmisDf)
								
					If lDocFind
						GFELog116:AddDebug("# Tamanho: " + cValToChar(nNr) + ", Número: " + cNrDf + " [Encontrado]", 6)
						Exit
					Else
						GFELog116:AddDebug("# Tamanho: " + cValToChar(nNr) + ", Número: " + cNrDf, 6)
					EndIf
				Next
			EndIf
		EndIf
		
		If lDocFind
			GFELog116:Add("> Filial.....: " + GW3->GW3_FILIAL, 4)
			GFELog116:Add("> Espécie....: " + GW3->GW3_CDESP, 4)
			GFELog116:Add("> Emissor....: " + GW3->GW3_EMISDF, 4)
			GFELog116:Add("> Série......: " + GW3->GW3_SERDF, 4)
			GFELog116:Add("> Número.....: " + GW3->GW3_NRDF, 4)
			GFELog116:Add("> Emissão....: " + DToC(GW3->GW3_DTEMIS), 4)
			
			aCTRCFatura[nI, 10] := GW3->GW3_FILIAL
			aCTRCFatura[nI, 11] := GW3->GW3_CDESP
			aCTRCFatura[nI, 12] := GW3->GW3_EMISDF
			aCTRCFatura[nI, 13] := GW3->GW3_SERDF
			aCTRCFatura[nI, 14] := GW3->GW3_NRDF
			aCTRCFatura[nI, 15] := GW3->GW3_DTEMIS
			
			If GW3->GW3_FILIAL != cFilialFat
				AddPreValid("Filial da fatura "+AllTrim(aFatura[5])+" é diferente da filial do documento de frete número/série "+AllTrim(GW3->GW3_NRDF)+"/"+AllTrim(GW3->GW3_SERDF)+".", 2)
			EndIf
		
			// Imposto retido
			If !Empty(GW3->GW3_IMPRET)
				GFELog116:Add("- Imposto Retido:", 4)
				aFatura[8] += GW3->GW3_IMPRET
				
				If Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '1'
					GFELog116:Add("> Tp. Imposto: ICMS", 4)
					aFatura[27] += GW3->GW3_IMPRET
				ElseIf Posicione("GVT", 1, xFilial('GVT') + GW3->GW3_CDESP, "GVT_TPIMP") == '2'
					GFELog116:Add("> Tp. Imposto: ISS", 4)
					aFatura[28] += GW3->GW3_IMPRET
				Else
					
				EndIf
				
				GFELog116:Add("> Imp. Retido: " + cValToChar(GW3->GW3_IMPRET), 4)
			EndIf
		Else
			aCTRCFatura[nI, 10] := ""
			aCTRCFatura[nI, 11] := ""
			aCTRCFatura[nI, 12] := cEmisDf
			aCTRCFatura[nI, 13] := aCTRCFatura[nI, 3]
			aCTRCFatura[nI, 14] := aCTRCFatura[nI, 4]
			aCTRCFatura[nI, 15] := Nil
			AddPreValid("Documento de frete não encontrado. Série: " + aCTRCFatura[nI, 3] + ", Número: " + aCTRCFatura[nI, 4], 4)
		EndIf
	Next
	
	If !Empty(aFatura[27]) .OR. !Empty(aFatura[28])
		GFELog116:Add("> Valor da fatura corrigido: " + cValToChar(aFatura[8]) + " (com imposto retido)", 2)
	EndIf
Return

//--------------------------------------------------------------------
// PosValGW3 - Valida e posiciona na GW3
//--------------------------------------------------------------------
Static Function PosValGW3(cSerie, cNumero, cCNPJ, cEmisDf)
	Local lRet := .F.

	cSerie  := PadR(cSerie,TamSX3("GW3_SERDF")[1])
	cNumero := PadR(cNumero, TamSX3("GW3_NRDF")[1])
	
	If !Empty(cCNPJ)
		dbSelectArea("GW3")
		GW3->(dbSetOrder(13))
		If GW3->(dbSeek(cSerie + cNumero))
			While GW3->(!Eof()) 			.AND. ;
			      GW3->GW3_SERDF == cSerie  .AND. ;
			      GW3->GW3_NRDF  == cNumero
			      
					If AllTrim(Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_IDFED")) == AllTrim(cCNPJ) .OR. ;
				       AllTrim(Posicione("GU3",1,xFilial("GU3")+Posicione("GU3",1,xFilial("GU3")+GW3->GW3_EMISDF,"GU3_CDEMFT"),"GU3_IDFED")) == AllTrim(cCNPJ)
						lRet := .T.
						Exit
					EndIf
				GW3->(dbSkip())
			EndDo
		EndIf
	ElseIf !Empty(cEmisDf)
		dbSelectArea("GW3")
		GW3->(dbSetOrder(12)) // GW3_EMISDF + GW3_SERDF + GW3_NRDF
		If GW3->(dbSeek(cEmisDf + cSerie + cNumero))
			lRet := .T.
		EndIf
	EndIf
Return lRet


//--------------------------------------------------------------------
// PreValidacao - Faz a pré-validação antes de gravar o registro
//--------------------------------------------------------------------
Static Function PreValidacao()
	If aFatura[20] != "I" .AND. !Empty(aFatura[20])
		AddPreValid("Ação do documento não suportada. (Exclusão)", 1)
	EndIf
	
	If Empty(aFatura[8])
		AddPreValid("Valor da fatura não informado.", 1)
	EndIf

	GFELog116:Add("> Valor........: " + cValToChar(aFatura[8]), 2)	
	GFELog116:Add("> Juros........: " + cValToChar(aFatura[11]), 2)
	GFELog116:Add("> Desconto.....: " + cValToChar(aFatura[13]), 2)
	
	If Empty(aImposto[1])
		AddPreValid("Registro 553 (impostos do documento de cobrança) não encontrado.", 1)
	Else
		GFELog116:Add("> ICMS.........: " + cValToChar(aImposto[2]), 2)
		GFELog116:Add("> % ICMS.......: " + cValToChar(aImposto[3]), 2)
		GFELog116:Add("> Base ICMS....: " + cValToChar(aImposto[4]), 2)
	EndIf
	
Return


//--------------------------------------------------------------------
// CheckErros - Verifica os erros encontrados para o registro atual
//--------------------------------------------------------------------
Static Function CheckErros()
	Local cCab := ""
	If !Empty(cErrosFat)
		If !Empty(aFatura[4])
			cCab += "> Série: " + aFatura[3] + ", Número: " + aFatura[4]
		EndIf
		
		If !Empty(cCab)
			cErrosFat = cCab + CHR(13) + CHR(10) + cErrosFat
		EndIf
		
		AddErroResult(cErrosFat)
		cErrosFat := ""
	EndIf
Return


//--------------------------------------------------------------------
// CreateGXI - Faz a criação da tabela GCXL de acordo com os dados coletados
//--------------------------------------------------------------------
Static Function CreateGXI()
	Local s_GFE116A2 := ExistBlock("GFE116A2")
	Local dDtVenc    := Nil
	Local dDtRetorno := Nil

	cGXI_NRIMP := GETSXENUM("GXI", "GXI_NRIMP")

	dDtVenc := aFatura[7]
	
	If s_GFE116A2
		dDtRetorno := ExecBlock("GFE116A2",.F.,.F.,{cFilialFat,aEmitentes[1],aFatura[4],GFEZapZero(aFatura[5],.T.),aFatura[6]})
		If Valtype(dDtRetorno) = "D"
			dDtVenc := dDtRetorno
		EndIf
	EndIf					

	RecLock("GXI", .T.)
		GXI->GXI_FILIAL	:= xFilial("GXI")
		GXI->GXI_MARKBR := Iif(IsBlind(), "", oBrowse116:Mark())
		GXI->GXI_NRIMP  := cGXI_NRIMP
		
		GXI->GXI_EDINRL := aFatura[29]
		GXI->GXI_EDILIN := aFatura[30]
		GXI->GXI_EDIARQ := cNomeArq
		
		GXI->GXI_ALTER  := "2"
		GXI->GXI_USUIMP := cUserName
		GXI->GXI_DTIMP  := DDATABASE
		
		
		GXI->GXI_FILFAT := cFilialFat
		GXI->GXI_EMIFAT := aEmitentes[1]
		GXI->GXI_SERFAT := aFatura[4]
		GXI->GXI_NRFAT  := GFEZapZero(aFatura[5],.T.)
		GXI->GXI_DTEMIS := aFatura[6]
		GXI->GXI_DTVENC := dDtVenc
		
		
		GXI->GXI_VLFATU := SetField(aFatura[8],  "GXI_VLFATU")
		GXI->GXI_VLJURO := SetField(aFatura[11], "GXI_VLJURO")
		GXI->GXI_VLDESC := SetField(aFatura[13], "GXI_VLDESC")
		
		GXI->GXI_VLICMS := SetField(aImposto[2], "GXI_VLICMS")
		
		GXI->GXI_IMPRET := aFatura[27]
		GXI->GXI_ISSRET := aFatura[28]
	
		CheckErros()
		
		If Empty(cMsgPreVal)
			GXI->GXI_EDISIT		:= "1"
		Else
			If Len(cMsgPreVal) > 65000
				cMsgPreVal := SubStr(cMsgPreVal, 0, 65000)
			EndIf
			
			GXI->GXI_EDISIT	:= "2"
			GXI->GXI_EDIMSG		:= cMsgPreVal
			
			cMsgPreVal 	 := ""
		EndIf
	MsUnlock()
	
	GFELog116:Add("> Número do registro importado: " + cValToChar(cGXI_NRIMP))
	GFELog116:NewLine()
	
	ConfirmSX8()
Return		



//--------------------------------------------------------------------
// CreateGXJ - Faz a criação da tabela GXJ
//--------------------------------------------------------------------
Static Function CreateGXJ()
	Local nI
	
	For nI := 1 To Len(aCTRCFatura)
		If !Empty(aCTRCFatura[nI, 14])
			RecLock("GXJ", .T.)
				GXJ->GXJ_FILIAL := xFilial("GXJ")
				GXJ->GXJ_NRIMP  := cGXI_NRIMP
				GXJ->GXJ_SEQ    := StrZero(nI, 5)
				
				// GW3_FILIAL+GW3_CDESP+GW3_EMISDF+GW3_SERDF+GW3_NRDF+DTOS(GW3_DTEMIS)
				GXJ->GXJ_FILDF  := aCTRCFatura[nI, 10]
				GXJ->GXJ_CDESP  := aCTRCFatura[nI, 11]
				GXJ->GXJ_EMISDF := aCTRCFatura[nI, 12]
				GXJ->GXJ_SERDF  := aCTRCFatura[nI, 13]
				GXJ->GXJ_NRDF   := aCTRCFatura[nI, 14]
				If !Empty(aCTRCFatura[nI, 15])
					GXJ->GXJ_DTEMIS := aCTRCFatura[nI, 15]
				EndIf
			MsUnlock()
		EndIf
	Next
Return



//--------------------------------------------------------------------
// Reg551 - Dados da Transportadora
//--------------------------------------------------------------------
Static Function Reg551()
	Local cCNPJ
	
	cCNPJ := GetStr(cBuffer, 4, 14)		// 2. CNPJ da Transportadora que emite a fatura/recebe o frete

	lTranspVld := .T.
	
	GFELog116:Add("> CNPJ Transportador: " + cCNPJ)
	
	dbSelectArea("GU3")
	dbSetOrder(11)
	If dbSeek(xFilial("GU3") + cCNPJ)
		While !GU3->(Eof()) 					 .AND. ;
			   GU3->GU3_FILIAL == xFilial("GU3") .AND. ;
		       AllTrim(GU3->GU3_IDFED) == AllTrim(cCNPJ)
	
			If GU3->GU3_TRANSP == "1"
				aEmitentes[1] := AllTrim(GU3->GU3_CDEMIT)
				aEmitentes[2] := cCNPJ
				aEmitentes[3] := AllTrim(GU3->GU3_NMEMIT)
					
				GFELog116:Add("> Transportador.....: " + AllTrim(GU3->GU3_CDEMIT) + " - " + AllTrim(GU3->GU3_NMEMIT))
				
				If GU3->GU3_CDEMIT < cTransIni .OR.GU3->GU3_CDEMIT > cTransFim
					GFEResult:Add('** Transportador "' + aEmitentes[1] + ' - ' + aEmitentes[3] + '" fora da faixa informada.')
					GFEResult:SetWarningIcon()
					GFELog116:Add("# Transportador desconsiderado. Está fora da faixa informada.")
					lTranspVld := .F.
					lArquivoImportado := .F.
				Else
					AddResult("> Transportador: " + aEmitentes[1] + " - " + aEmitentes[3], 0, .T.)
				EndIf
				
				Exit
			EndIf
				
			GU3->(dbSkip())
		EndDo
	EndIf

	If Empty(aEmitentes[1])
		GFEResult:Add("** Transportador não encontrado com o CNPJ: " + cCNPJ + ".")
		GFEResult:SetWarningIcon()
		GFELog116:Add("** Transportador não encontrado com o CNPJ: " + cCNPJ + ".")
		lTranspVld := .F.
		lArquivoImportado := .F.
	EndIf
	
	GFELog116:NewLine()
Return .T.


//--------------------------------------------------------------------
// Reg552 - Documento de Cobrança
// aFatura
//  [27] ICMS Retido
//  [28] ISS Retido
//	[29] Linha do arquivo
//	[30] Conteúdo da Linha
//--------------------------------------------------------------------
Static Function Reg552()
	
	aFatura[1]  := ""									//  1. Filial Doc. Carga 
	aFatura[2]  := GetStr(cBuffer,   4, 10)				//  2. Filial Emissora do Documento *
	aFatura[3]  := GetStr(cBuffer,  14,  1)				//  3. Tipo do Documento de Cobrança *
	aFatura[4]  := GetStr(cBuffer,  15,  3)				//  4. Série do Documento de Cobrança
	aFatura[5]  := GetStr(cBuffer,  18, 10)				//  5. Número do Documento de Cobrança *
	aFatura[6]  := GetDate(cBuffer, 28,  8)				//  6. Data de Emissão da Fatura *
	aFatura[7]  := GetDate(cBuffer, 36,  8)				//  7. Data de Vencimento da Fatura *
	aFatura[8]  := GetInt(cBuffer,  44, 13, 2)			//  8. Valor total do Documento de Cobrança *
	aFatura[9]  := GetStr(cBuffer,  59, 3)				//  9. Tipo de Cobrança [BCO: Cobrança Bancária, CAR: Carteira] *
	aFatura[10] := GetInt(cBuffer,  62, 2, 2)			// 10. Percentual da multa por atraso
	aFatura[11] := GetInt(cBuffer,  66, 13, 2)			// 11. Valor - Juros por dia de atraso
	aFatura[13] := GetInt(cBuffer,  89, 13, 2)			// 13. Valor do Desconto
	aFatura[20] := GetStr(cBuffer, 156,  1)				// 20. Ação do Documento
	
	aFatura[27] := 0
	aFatura[28] := 0
	
	aFatura[29] := GFEFile:nLinAtual
	aFatura[30] := cBuffer
	
	
	AddResult("> Fatura: " + aFatura[5] + ", Série: " + aFatura[4], 0, .T.)
	
Return


//--------------------------------------------------------------------
// Reg553 - Impostos do Documento de Cobrança
//--------------------------------------------------------------------
Static Function Reg553()
	aImposto[1]	 := "OK"
	aImposto[2]  := GetInt(cBuffer,  4, 13, 2)			//  2. Valor Total do ICMS
	aImposto[3]  := GetInt(cBuffer, 19,  3, 2)			//  3. Aliquota ICMS
	aImposto[4]  := GetInt(cBuffer, 24, 13, 2)			//  4. Base ICMS
	aImposto[5]  := GetInt(cBuffer, 39, 13, 2)			//  5. Valor Total ISS
	aImposto[6]  := GetInt(cBuffer, 54,  3, 2)			//  6. Aliquota ISS
	aImposto[7]  := GetInt(cBuffer, 59, 13, 2)			//  7. Base Cálculo ISS
	aImposto[8]  := GetInt(cBuffer, 74, 13, 2)			//  8. Valor Total do ICMS - Substituição Tributária
	aImposto[9]  := GetInt(cBuffer, 89,  3, 2)			// 10. Aliquota ICMS - Substituição Tributária
	aImposto[10] := GetInt(cBuffer, 94, 13, 2)			// 10. Base ICMS - Substituição Tributária
Return


//--------------------------------------------------------------------
// Reg555 - CTRC
// aCTRC
//	[10] GW3_FILIAL
//	[11] GW3_CDESP
//	[12] GW3_EMISDF
//	[13] GW3_SERDF
//	[14] GW3_NRDF
//--------------------------------------------------------------------
Static Function Reg555()
	Local aCTRC[15]
	
	aFill(aCTRC, "")
	
	aCTRC[1]  := "OK"
	aCTRC[2]  := GetStr(cBuffer,  4, 10)			//  2. Filial Emissora do Documento
	aCTRC[3]  := GetStr(cBuffer, 14,  5)			//  3. Serie do CTRC
	aCTRC[4]  := GetStr(cBuffer, 19, 12)			//  4. Número do CTRC
	aCTRC[5]  := GetInt(cBuffer, 31, 13, 2)			//  5. Valor do Frete
	aCTRC[9]  := GetStr(cBuffer, 82, 14)			//  9. CNPJ do Emitente
	
	aADD(aCTRCFatura, aCTRC)
	
	aCTRC := {}
	aSize(aCTRC, 0)
Return


//--------------------------------------------------------------------
// AddPreValid - Inclui erros de pré-validação
//				 Validações que não impedem a importação
//--------------------------------------------------------------------
Static Function AddPreValid(cMsg, nIdent)
	Default nIdent := 2
	
	cMsgPreVal += "- " + cMsg + CHR(13) + CHR(10)
	
	cErrosFat += "    ** " + cMsg + CHR(13) + CHR(10)
	
	GFELog116:Add("** " + cMsg, nIdent)
Return



//--------------------------------------------------------------------
// AddResult - Adiciona informações na tela de resultados
//--------------------------------------------------------------------
Static Function AddResult(cMsg, nIdent, lAddLog)
	Default nIdent := 2
	Default lAddLog := .F.
	
	GFEResult:Add(cMsg, nIdent)
	
	If lAddLog
		GFELog116:Add(cMsg, nIdent)
	EndIf
Return


//--------------------------------------------------------------------
// AddErroResult - Adiciona informações de erro na tela de resultados
//--------------------------------------------------------------------
Static Function AddErroResult(cMsg, nIdent, lAddLog)
	Local cCabArquivo := ""
	Default nIdent := 0
	Default lAddLog := .F.
	
	If lShowCabFile
		cCabArquivo := Replicate('-', 50) + CHR(13) + CHR(10) + ;
				UPPER(cNomeArq) + CHR(13) + CHR(10) + ;
				Replicate('-', 50) + CHR(13) + CHR(10)
				
		cCabArquivo += Iif(Empty(aEmitentes[1]), "", "> TRANSPORTADOR: " + aEmitentes[1] + " - " + aEmitentes[3] + CHR(13) + CHR(10))
				
		lShowCabFile := .F.
	EndIf
	
	If lShowCabFat .AND. !Empty(aFatura[5])
		cCabArquivo += "> FATURA: " + aFatura[5] + ", SÉRIE:" + aFatura[4] + CHR(13) + CHR(10)
		lShowCabFat := .F.
	EndIf
	
	GFEResult:AddErro(cCabArquivo + cMsg)
	
	If lAddLog
		GFELog116:Add(cMsg, nIdent)
	EndIf
Return


//--------------------------------------------------------------------
// GetStr - Extrai parte de uma String
//--------------------------------------------------------------------
Static Function GetStr(cBuffer, nPos, nTamanho)
	Local cRet
	
	If nPos + nTamanho > Len(cBuffer)
		cRet := SubStr(cBuffer, nPos)
	Else
		cRet := SubStr(cBuffer, nPos, nTamanho)
	EndIf
	
	cRet := AllTrim(Upper(cRet))

Return(cRet)


//--------------------------------------------------------------------
// GetInt - Extrai parte de uma String convertendo para Inteiro
//--------------------------------------------------------------------
Static Function GetInt(cBuffer, nPos, nTamanho, nDec)
	Local nRet
	Local cStr
	Default nDec := 0
	
	cStr := GetStr(cBuffer, nPos, nTamanho)
	
	If nDec > 0
		cStr += "." + GetStr(cBuffer, nPos + nTamanho, nDec)
	EndIf
	
	nRet := Val(cStr)
Return(nRet)


//--------------------------------------------------------------------
// GetDate - Extrai parte de uma String convertendo para Data
//--------------------------------------------------------------------
Static Function GetDate(cBuffer, nPos, nTamanho)
	Local dRet	
	Local cStr
	
	If nTamanho == 8
		cStr := GetStr(cBuffer, nPos + 4, 4) + GetStr(cBuffer, nPos + 2, 2) + GetStr(cBuffer, nPos, 2)
	EndIf
	
	dRet := SToD(cStr)
	
Return(dRet)



//--------------------------------------------------------------------
// SetField - Formata um campo de acordo com sua Picture
//--------------------------------------------------------------------
Static Function SetField(nValor, cCampo, lValid)
	Local cValor
	Local nRet
	Local aTamSX3 := TamSX3(cCampo)
	Default lValid := .T.
	
	If Empty(nValor)
		Return(0)
	EndIf
	
	cValor := cValToChar(Round(nValor, 0))
	cValor := StrTran(cValor, ".", "")
	cValor := StrTran(cValor, ",", "")
	
	If aTamSX3[2] > 0
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1]) + "." + Replicate("9", aTamSX3[2])))
	Else
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1])))
	EndIf
	
	If Len(cValor) > aTamSX3[1]
		If lValid
			AddPreValid("Erro no campo: " + cCampo + ". Valor '" + cValToChar(nValor) + "' com formato inválido ou não suportado.")
		EndIf
		GFELog116:Add("# Campo: " + cCampo + ", Tamanho: " + cValToChar(aTamSX3[1]) + "." + cValToChar(aTamSX3[2]) + ", Valor: " + cValToChar(nValor), 1)
		
		Return(0)
	EndIf	
	
	nRet   := Val(cValor)
Return(nRet)


//-------------------------------------------------------------------
// GFEZapZero
// Formata numeração, retirando espaços e zeros a esquerda
//-------------------------------------------------------------------
Static Function GFEZapZero(cStr,lFatura)
  	Local nI
  	Local nPos 			:= 2
  	Local cGXI_NRFAT 	:= TamSx3("GXI_NRFAT")[1]
	Default lFatura 	:= .F.

	// Se não possui zeros à esquerda
	If SubStr(cStr, 1, 1) != "0"
		Return cStr
	EndIf

	// Se é para deixar os zeros à esquerda
	If MV_PAR07 == 1 .and. lFatura
		// Se a string for maior que o tamanho do campo preciso remover os zeros para os valores à direita não serem cortados.
		While Len(cStr) > cGXI_NRFAT .And. SubStr(cStr, 1, 1) == "0"
			cStr := Right( cStr, Len(cStr)-1 )
			Loop
		EndDO
		Return cStr
	EndIf	
	
	// Se não é para deixar os zeros à esquerda
	For nI := 2 To Len(cStr)
		If SubStr(cStr, nI, 1) == "0"
			nPos++
		Else
			Exit
		EndIf
	Next

Return SubStr(cStr, nPos)
