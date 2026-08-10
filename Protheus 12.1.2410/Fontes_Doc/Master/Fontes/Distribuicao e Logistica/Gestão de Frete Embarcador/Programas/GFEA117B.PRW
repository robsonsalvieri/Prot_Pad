#INCLUDE "GFEA117A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static s_CDTIPOE := SuperGetMv("MV_CDTIPOE",.F.,Space(TamSx3("GU4_CDTIPO")[1]))
/*-------------------------------------------------------------------
GFEA117B - Importação Ocorren 5.0

GWD - Ocorrências
GWL - Doc Cargas X Ocorrências

Layout:
	000
	 |-  540 [Transportadora] (max 200)
	     |- 541
	     |  |- 542 [Nota] (max 9.999)
	     |  |  |- 543
	     |     |- 544 [Item da Nota] (max 9.999)
	     |     |- 545
	     |- 549

aEmitentes
	[1]	Transp - Cod Emitente    
	[2] Transp - CNPJ
	[3] Transp - Nome
	[4]	Emissor Doc. Carga - Cod Emitente
	        

@author Israel A. Possoli
@since 10/11/2014
@version 1.0
------------------------------------------------------------------- */
Function GFEA117B()
	Private cErrosOco    := ""  // Erros acumulados para cada Ocorrência
	Private lShowCabNota := .T. // Mostra o cabeçalho por Nota
	Private lShowCabFile := .T. // Mostra o cabeçalho por arquivo
	Private cBuffer      := ""  // Conteúdo da Linha 
	Private cRegID       := ""  // Código do registro atual
	Private lTranspVld   := .F. // Transportador válido? (Faixa)
	Private cGXL_NRIMP   := ""  // Numeração sequencial da importação
	Private nCountOcoImp := 0   // Quantidade de Ocorrências Importadas
	Private nCountOco    := 0   // Quantidade de Ocorrências do Arquivo
	Private nLinha		 := 0 	// Numero da linha que esta sendo processada
	
	// Arrays com o conteúdo dos registros
	Private aEmitentes[6]
	Private aNota[34]
	
	// Parâmetros
	Private cTransIni := MV_PAR01
	Private cTransFim := MV_PAR02
	
	AddResult(Replicate('-', 50) + CHR(13) + CHR(10) + UPPER(cNomeArq) + CHR(13) + CHR(10) + Replicate('-', 50), 0)
	
	Do While !GFEFile:FEof()
		If oProcess != Nil
			oProcess:IncRegua2()
		EndIf
		cBuffer := GFEFile:Line()
		If Empty(cBuffer)
			GFEFile:FNext()
			Loop
		EndIf
		nLinha := GFEFile:nLinAtual
		cRegID := GetStr(cBuffer, 1, 3)
		// Leitura da linha corrente
		ReadReg()
		If nCountOco > 0 .And. (cRegID == "541" .Or. cRegID == "542")
			CreateReg()
		EndIf
		GFEFile:FNext()
	EndDo
Return .T.
//--------------------------------------------------------------------
// ReadReg - Leitura das linhas
//--------------------------------------------------------------------
Static Function ReadReg()
	// --- 541 [Dados Transportadora] -----------------
	If cRegID == "541"
		nCountOcoImp := 0
		nCountOco    := 0
		lTranspVld   := .F.
		cErrosOco    := ""
		cMsgPreVal   := ""
		lShowCabNota := .T.
		
		aFill(aEmitentes, "")
		aFill(aNota, "")
		Reg541()
	EndIf
	If lTranspVld
		// --- 542 [Conhecimento] -------------------------
		If cRegID == "542"
			nCountOco++
			aFill(aNota, "")
			Reg542()
		EndIf
		// --- 542 [Conhecimento] -------------------------
		If cRegID == "543"
			Reg543()
		EndIf
	EndIf
Return .T.
//--------------------------------------------------------------------
// Reg541 - Dados da Transportadora
//--------------------------------------------------------------------
Static Function Reg541()
	Local lRet      := .T.
	Local cCNPJ     := ""
	Local cAliasGU3 := GetNextAlias()
	
	cCNPJ := GetStr(cBuffer, 4, 14) // 2. CNPJ da Transportadora que emite a fatura/recebe o frete

	lTranspVld := .T.
	GFELog117:Add("> CNPJ Transportador: " + cCNPJ)

	BeginSql Alias cAliasGU3
		SELECT GU3.GU3_CDEMIT,
				GU3.GU3_NMEMIT
		FROM %Table:GU3% GU3
		WHERE GU3.GU3_FILIAL = %xFilial:GU3%
		AND GU3.GU3_IDFED = %Exp:cCNPJ%
		AND GU3.GU3_TRANSP = '1'
		AND GU3.GU3_SIT = '1'
		AND GU3.%NotDel%
	EndSql
	If (cAliasGU3)->(!Eof())
		aEmitentes[1] := AllTrim((cAliasGU3)->GU3_CDEMIT)
		aEmitentes[2] := cCNPJ
		aEmitentes[3] := AllTrim((cAliasGU3)->GU3_NMEMIT)
			
		GFELog117:Add("> Transportador: " + AllTrim((cAliasGU3)->GU3_CDEMIT) + " - " + AllTrim((cAliasGU3)->GU3_NMEMIT))
		
		If Empty(cTransIni) .AND. Empty(cTransFim)
			lTranspVld := .T.
		ElseIf !Empty((cAliasGU3)->GU3_CDEMIT) .And. (cAliasGU3)->GU3_CDEMIT >= cTransIni .And. (cAliasGU3)->GU3_CDEMIT <= cTransFim
			lTranspVld := .T.
		ElseIf !Empty((cAliasGU3)->GU3_CDEMIT)
			GFEResult:Add("** Transportador '" + aEmitentes[1] + "' fora da faixa informada.")
			GFEResult:SetWarningIcon()
			GFELog117:Add("# Transportador desconsiderado. Está fora da faixa informada.", 1)
			lTranspVld     := .F.
			lArquivoValido := .F.
		EndIf
		If lTranspVld == .T.
			AddResult("> Transportador: " + aEmitentes[1] + " - " + aEmitentes[3], 0)
		EndIf
	EndIf
	(cAliasGU3)->(dbCloseArea())
	
	If Empty(aEmitentes[1])
		GFEResult:Add("** Transportador não encontrado com o CNPJ: " + cCNPJ + ".")
		GFEResult:SetWarningIcon()
		GFELog117:Add("** Transportador não encontrado com o CNPJ: " + cCNPJ + ".", 1)
	EndIf
	GFELog117:NewLine()
Return lRet
//--------------------------------------------------------------------
// Reg542 - Ocorrência na Entrega - Dados da Nota Fiscal
// aNota
// 	[40] : Código Tipo Ocorrencia
// 	[41] : Código Motivo Ocorrencia
// 	[42] : Observação 1
// 	[43] : Observação 2
// 	[44] : Observação 3
//--------------------------------------------------------------------
Static Function Reg542()
Local cSerNF      := ""
Local nNrNF       := 0
Local cNrDocCarga := ""
Local lFindGW1    := .F.
Local nI          := 0
Local nICont      := 0
Local aVldOcor    := {}
Local aVldDtEmis  := {}
Local cData165    := ""
Local cAliasGU3   := Nil
Local cAliasGW1   := Nil
Local cAliasQry   := Nil
Local cCdOco      := ""
Local cCdTipo     := ""
Local cCdMot      := ""
Local lOcorrencia := .T.
Local nGU4_CDMOT  := TamSx3("GU4_CDMOT")[1]
Local nGU4_CDTIPO := TamSx3("GU4_CDTIPO")[1]
	
	aEmitentes[4] := ""
	aEmitentes[5] := ""
	aEmitentes[6] := ""
	
	aNota[1]  := ""                        //  1. Filial Doc. Carga
	aNota[2]  := GetStr(cBuffer,  4, 14)   //  2. CNPJ do Emissor da Nota Fiscal
	aNota[3]  := GetStr(cBuffer, 18,  3)   //  3. Série
	aNota[4]  := GetStr(cBuffer, 21,  9)   //  4. Número
	aNota[5]  := GetStr(cBuffer, 30,  3)   //  5. Código de Ocorrência na Entrega	
		
	cData165  := GetStr(cBuffer, 165,  8)    // Data da chegada no destino da NF
	
	If Empty(cData165) .OR. cData165 == "00000000"	
		aNota[6] := GetDate(cBuffer,33,8)  //  6. Data da Ocorrência
	Else
		aNota[6] := GetDate(cBuffer,165,8)
	EndIf	
	
	aNota[7]   := GetStr(cBuffer, 41,  4)   //  7. Hora da Ocorrência
	aNota[7]   := SubStr(aNota[7],1,2) + ":" + SubStr(aNota[7],3,2)
	aNota[8]   := GetInt(cBuffer, 45,  2)   //  8. Código de Observação de Ocorrência [01: Devolução Total, 02: Devolução Parcial: 03:Aceite/Entrega por acordo, 04, 05]
	aNota[9]   := GetStr(cBuffer, 47, 20)   //  9. Número Romaneio
	aNota[14]  := GetStr(cBuffer, 137, 5)  // 14. Série do Conhecimento
	aNota[15]  := GetStr(cBuffer, 142, 12) // 15. Número do Conhecimento
	aNota[16]  := GetStr(cBuffer, 154, 1)  // 16. Indicação do Tipo de Entrega

	aNota[27]  := GetStr(cBuffer, 213, 14) // 27. CNPJ do Emissor da Nota Fiscal de devolução
	aNota[28]  := GetStr(cBuffer, 227,  3) // 28. Série de devolução
	aNota[29]  := GetStr(cBuffer, 230,  9) // 29. Número de devolução
	
	GFELog117:Add("> Série: " + aNota[3] + ", Número: " + aNota[4] + ", CNPJ Emissor: " + aNota[2], 0)
	
	//Valida a Data e Hora
	aVldOcor := GFEVLDDTHR("00:00", aNota[6],,,"da ocorrência")
	If !aVldOcor[1]
		AddPreValid(aVldOcor[2], 0 )
	EndIf
	//--------------------------------------------------------
	// Localiza o Documento de Carga
	cSerNF      := PadR(AllTrim(aNota[3]), TamSX3("GW1_SERDC")[1])
	nNrNF       := Str(Val(aNota[4]))
	cNrDocCarga := AllTrim(cValToChar(nNrNF))
	
	// Garante a busca quando Protheus e Numeração Própria
	If SuperGetMV('MV_EMITMP',,'1')  == "1" .AND. SuperGetMV('MV_ERPGFE',,'1') == "2"
		GFELog117:AddDebug("> Série   DC: [" + cSerNF        + "]", 2)
		GFELog117:AddDebug("> Número  DC: [" + cNrDocCarga   + "]", 2)
		
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_CDEMIT,
					GU3.GU3_IDFED,
					GU3.GU3_SIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_IDFED = %Exp:aNota[2]%
			AND GU3.%NotDel%
			ORDER BY GU3.GU3_SIT
		EndSql
		Do While (cAliasGU3)->(!Eof()) .And. !lFindGW1
			nICont := Len(cNrDocCarga)
			For nI := nICont To 9
				cAliasGW1 := GetNextAlias()
				BeginSql Alias cAliasGW1
					SELECT GW1.GW1_FILIAL,
							GW1.GW1_SERDC,
							GW1.GW1_NRDC
					FROM %Table:GW1% GW1
					WHERE GW1.GW1_EMISDC = %Exp:(cAliasGU3)->GU3_CDEMIT%
					AND GW1.GW1_SERDC = %Exp:cSerNF%
					AND GW1.GW1_NRDC = %Exp:GFEGetNrDc(cNrDocCarga, nI)%
					AND GW1.%NotDel%
				EndSql
				If (cAliasGW1)->(!Eof())
					aNota[1] := (cAliasGW1)->GW1_FILIAL
					aNota[3] := (cAliasGW1)->GW1_SERDC
					aNota[4] := (cAliasGW1)->GW1_NRDC
					
					aEmitentes[4] := (cAliasGU3)->GU3_CDEMIT
					
					GFELog117:AddDebug("# Tamanho: " + cValToChar(nI) + ", Número: " + GFEGetNrDc(cNrDocCarga, nI) + " [Encontrado]", 2)
					GFELog117:Add("> Emissor DC: [" + aEmitentes[4] + "]", 2)
					lFindGW1 := .T.

					(cAliasGW1)->(dbCloseArea())
					Exit
				Else
					GFELog117:AddDebug("# Tamanho: " + cValToChar(nI) + ", Número: " + GFEGetNrDc(cNrDocCarga, nI), 2)
				EndIf
				(cAliasGW1)->(dbCloseArea())
			Next nI
			(cAliasGU3)->(dbSkip())
		EndDo
		(cAliasGU3)->(dbCloseArea())
	Else
		aEmitentes[4] := GetEmitCNPJ(aNota[2])
		
		GFELog117:Add("> Emissor DC: [" + aEmitentes[4] + "]", 2)
		
		nICont := Len(cNrDocCarga)
		For nI := nICont To 9
			cAliasGW1 := GetNextAlias()
			BeginSql Alias cAliasGW1
				SELECT GW1.GW1_FILIAL,
						GW1.GW1_SERDC,
						GW1.GW1_NRDC
				FROM %Table:GW1% GW1
				WHERE GW1.GW1_EMISDC = %Exp:aEmitentes[4]%
				AND GW1.GW1_SERDC = %Exp:cSerNF%
				AND GW1.GW1_NRDC = %Exp:GFEGetNrDc(cNrDocCarga, nI)%
				AND GW1.%NotDel%
			EndSql
			If (cAliasGW1)->(!Eof())

				aNota[1] := (cAliasGW1)->GW1_FILIAL
				aNota[3] := (cAliasGW1)->GW1_SERDC
				aNota[4] := (cAliasGW1)->GW1_NRDC
				  
				GFELog117:AddDebug("# Tamanho: " + cValToChar(nI) + ", Número: " + GFEGetNrDc(cNrDocCarga, nI) + " [Encontrado]", 2)
				lFindGW1 := .T.
				
				(cAliasGW1)->(dbCloseArea())
				Exit
			Else
				GFELog117:AddDebug("# Tamanho: " + cValToChar(nI) + ", Número: " + GFEGetNrDc(cNrDocCarga, nI), 2)
			EndIf
			(cAliasGW1)->(dbCloseArea())
		Next nI
	EndIf
	If Empty(aEmitentes[4])
		AddPreValid("Emissor do Documento de Carga não encontrado com o CNPJ: " + aNota[2])
		Return
	EndIf
	If !lFindGW1
		AddPreValid("Documento de carga não encontrado. Emissor: " + aEmitentes[4] + ", Série: " + cSerNF + ", Número: " + aNota[4])
	Else
		aVldDtEmis := GFEVLDDTHR("00:00", DToS(GW1->GW1_DTEMIS), aNota[7], DToS(aNota[6]), "de emissão do DC", "da ocorrência")
		If !aVldDtEmis[1]
			AddPreValid("Documento " + Alltrim(GW1->GW1_NRDC) + "/" + Alltrim(GW1->GW1_SERDC) + ": " + aVldDtEmis[2])  
		EndIf
	EndIf
	//--------------------------------------------------------
	// Código Tipo e Código Motivo da Ocorrência
	//  aNota[30] : Código Tipo
	//  aNota[31] : Código Motivo
	cCdOco  := aNota[5]
	cCdMot  := cCdOco

	If (aNota[8] == 3 .OR. aNota[5] == "001") .AND. SuperGetMv("MV_REGOCO", .F., "1") == "2"
		If Empty(s_CDTIPOE)
			// Parâmetro "Cód. Ocorrência Entrega" --> Se estiver vazio, considera o "Cód. do Tipo de Ocorrência" que consta no arquivo
			GFELog117:Add("- Ocorrência de entrega com registro. Parâmetro MV_CDTIPOE não preenchido.", 2)
			GFELog117:Add("- Buscando o Tipo de Ocorrência de Entrega através do Código de Ocorrência contido no arquivo.", 2)
		EndIf
	EndIf

	If !Empty(s_CDTIPOE) .AND. (aNota[8] == 3 .OR. aNota[5] == "001") .AND. SuperGetMv("MV_REGOCO", .F., "1") == "2"

		cCdTipo := s_CDTIPOE
		GFELog117:Add("- Ocorrência de entrega com registro. Utilizando código do parâmetro MV_CDTIPOE: " + cCdTipo, 2)

		// Verifica se o tipo de ocorrência está cadastrado e ativo
		// Caso não encontre tenta buscar com o preenchimento de zeros
		// Encotrando atribui o tipo e motivo
		For nI := 1 To 2
			If nI == 2
				cCdTipo := StrZero(Val(cCdTipo),nGU4_CDTIPO)
			EndIf
			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT GU5.GU5_CDTIPO
					, GU6.GU6_CDMOT
				FROM %Table:GU4% GU4
				LEFT JOIN %Table:GU5% GU5
				ON GU5.GU5_FILIAL = %xFilial:GU5%
				AND GU5.GU5_CDTIPO = GU4.GU4_CDTIPO
				AND GU5.%NotDel%
				LEFT JOIN %Table:GU6% GU6
				ON GU6.GU6_FILIAL = %xFilial:GU6%
				AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
				AND GU6.GU6_SIT = '1'
				AND GU6.%NotDel%
				WHERE GU4.GU4_FILIAL = %xFilial:GU4%
				AND GU4.GU4_CDTIPO = %Exp:cCdTipo%
				AND GU5.GU5_SIT = '1'
				AND GU4.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				cCdTipo := (cAliasQry)->GU5_CDTIPO
				cCdMot  := (cAliasQry)->GU6_CDMOT
				lOcorrencia := .T.
			Else
				lOcorrencia := .F.
				GFELog117:Add("** Não foi encontrado o cadastro do Tipo de Ocorrencia [" + cCdTipo + "] indicado no parâmetro MV_CDTIPOE. ", 2)
			EndIf
			(cAliasQry)->(dbCloseArea())

			If lOcorrencia
				Exit				// Encotrou a ocorrência e sairá do laço
			EndIf
		Next nI
	Else
		cCdMot := cValToChar( Val(cCdMot) )
		For nI := 1 To nGU4_CDMOT
			If nI > 1
				cCdMot := Iif(nGU4_CDMOT > Len(cCdMot), "0" + cCdMot, cCdMot)
			EndIf

			cAliasQry := GetNextAlias()
			BeginSql Alias cAliasQry
				SELECT GU5.GU5_CDTIPO,
								GU6.GU6_CDMOT
				FROM %Table:GU4% GU4
				LEFT JOIN %Table:GU5% GU5
				ON GU5.GU5_FILIAL = %xFilial:GU5%
				AND GU5.GU5_CDTIPO = GU4.GU4_CDTIPO
				AND GU5.%NotDel%
				LEFT JOIN %Table:GU6% GU6
				ON GU6.GU6_FILIAL = %xFilial:GU6%
				AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
				AND GU6.GU6_SIT = '1'
				AND GU6.%NotDel%
				WHERE GU4.GU4_FILIAL = %xFilial:GU4%
				AND GU4.GU4_CDMOT = %Exp:cCdMot%
				AND GU5.GU5_SIT = '1'
				AND GU4.%NotDel%
			EndSql
			If (cAliasQry)->(!Eof())
				cCdTipo := (cAliasQry)->GU5_CDTIPO
				cCdMot  := (cAliasQry)->GU6_CDMOT
				lOcorrencia := .T.								
			Else
				lOcorrencia := .F.
				GFELog117:Add("** Não foi encontrado o Tipo de Ocorrencia para a motivo indicado no arquivo: " + cCdMot, 2)
			EndIf
			(cAliasQry)->(dbCloseArea())
			// Encotrou a ocorrência e sairá do laço
			If lOcorrencia
				Exit
			EndIf
		Next nI
	EndIf

	aNota[30] := cCdTipo
	aNota[31] := cCdMot

	//--------------------------------------------------------
	AddResult("> Emissor: " + AllTrim(aEmitentes[4]) + ", Série: " + aNota[3] + ", Número: " + aNota[4], 2)
Return .T.
//--------------------------------------------------------------------
// Reg543 - Texto Complementar da Ocorrência
//--------------------------------------------------------------------
Static Function Reg543()
	aNota[32]  := GetStr(cBuffer,   4, 70) //  2. Texto Livre - 1
	aNota[33]  := GetStr(cBuffer,  74, 70) //  3. Texto Livre - 2
	aNota[34]  := GetStr(cBuffer, 144, 70) //  4. Texto Livre - 3
Return Nil
//--------------------------------------------------------------------
// CreateReg - Faz a criação da tabela GXL
//--------------------------------------------------------------------
Static Function CreateReg()
	If Empty(aNota[4])
		Return Nil
	EndIf

	nCountImpor++
	cGXL_NRIMP := ""
	PreValidacao()
	CreateGXL()
Return Nil
//--------------------------------------------------------------------
// PreValidacao - Faz a pré-validação antes de gravar o registro
//--------------------------------------------------------------------
Static Function PreValidacao()
	If Empty(aNota[30])
		AddPreValid("Código do Tipo da ocorrência não encontrado. Cod Ocorrência no arquivo: " + aNota[5], 0)
	Else
		GFELog117:Add("> Código do Tipo: " + aNota[30], 1)
	EndIf
	If Empty(aNota[31])
		AddPreValid("Código do Motivo da ocorrência não encontrado. Cod Ocorrência no arquivo: " + aNota[5], 0)
	Else
		GFELog117:Add("> Código do Motivo: " + aNota[31], 1)
	EndIf
	GFELog117:Save()
Return Nil
//--------------------------------------------------------------------
// CreateGXL - Faz a criação da tabela GCXL de acordo com os dados coletados
//--------------------------------------------------------------------
Static Function CreateGXL()
	Local cTamOBS	:= TamSX3("GXL_OBS")[1]
	Local cObsEDI	:= ""

	cGXL_NRIMP := GETSXENUM("GXL", "GXL_NRIMP")
	nCountOcoImp++

	If cTamOBS == 10
		cObsEDI := ""

		cObsEDI := aNota[32] + aNota[33] + aNota[34]
	Else
		cObsEDI := ""

		If !Empty(aNota[32])
			cObsEDI += aNota[32]
		EndIf

		If Empty(cObsEDI) .AND. !Empty(aNota[33])
			cObsEDI := aNota[33]
		EndIf

		If Empty(cObsEDI) .AND. !Empty(aNota[34])
			cObsEDI := aNota[34]
		EndIf
	EndIf

	RecLock("GXL", .T.)
		GXL->GXL_FILIAL := xFilial("GXL")
		GXL->GXL_MARKBR := Iif(IsBlind(), "", oBrowse117:Mark())
		GXL->GXL_NRIMP  := cGXL_NRIMP
		GXL->GXL_ALTER  := "2"
		GXL->GXL_USUIMP := cUserName
		GXL->GXL_DTIMP  := DDATABASE
		GXL->GXL_EDINRL := nLinha
		GXL->GXL_EDILIN := cBuffer
		GXL->GXL_EDIARQ := cNomeArq
		GXL->GXL_FILOCO := IIf(Empty(aNota[1]),cFilialOcor,aNota[1])
		GXL->GXL_DTOCOR := aNota[6]
		GXL->GXL_HROCOR := aNota[7]
		GXL->GXL_CDTRP  := aEmitentes[1]
		GXL->GXL_FILDC  := aNota[1]
		GXL->GXL_EMISDC := aEmitentes[4]
		GXL->GXL_SERDC  := aNota[3]
		GXL->GXL_NRDC   := aNota[4]
		GXL->GXL_CODOCO := aNota[5]
		GXL->GXL_CODOBS := aNota[8]
		GXL->GXL_CDTIPO := aNota[30]
		GXL->GXL_CDMOT  := aNota[31]
		GXL->GXL_OBS    := cObsEDI
		
		CheckErros()
		
		If Empty(cMsgPreVal)
			GXL->GXL_EDISIT := "1"
		Else
			If Len(cMsgPreVal) > 65000
				cMsgPreVal := SubStr(cMsgPreVal, 0, 65000)
			EndIf
			
			GXL->GXL_EDISIT := "2"
			GXL->GXL_EDIMSG := cMsgPreVal
			
			cMsgPreVal := ""
		EndIf
	GXL->(MsUnlock())
	GFELog117:Add("> Número do registro importado: " + cValToChar(cGXL_NRIMP))
	GFELog117:NewLine()
	
	ConfirmSX8()
Return Nil
//--------------------------------------------------------------------
// CheckErros - Verifica os erros encontrados para o registro atual
//--------------------------------------------------------------------
Static Function CheckErros()
	Local cCab := ""

	If !Empty(cErrosOco)
		If !Empty(aNota[3])
			cCab += "> Série: " + aNota[3] + ", Número: " + aNota[4]
		EndIf
		If !Empty(cCab)
			cErrosOco = cCab + CHR(13) + CHR(10) + cErrosOco
		EndIf
		AddErroResult(cErrosOco)
		cErrosOco := ""
	EndIf
Return Nil
//--------------------------------------------------------------------
// AddErroResult - Adiciona informaçÃµes de erro na tela de resultados
//--------------------------------------------------------------------
Static Function AddErroResult(cMsg, nIdent, lAddLog)
	Local cCabArquivo := ""
	
	Default nIdent    := 0
	Default lAddLog   := .F.
	
	If lShowCabFile
		cCabArquivo := Replicate('-', 50) + CHR(13) + CHR(10) + ;
				UPPER(cNomeArq) + CHR(13) + CHR(10) + ;
				Replicate('-', 50) + CHR(13) + CHR(10)
				
		lShowCabFile := .F.
	EndIf
	If lShowCabNota
		cCabArquivo += Iif(Empty(aEmitentes[1]), "", "> TRANSPORTADOR: " + aEmitentes[1] + " - " + aEmitentes[3] + CHR(13) + CHR(10))
		lShowCabNota := .F.
	EndIf
	GFEResult:AddErro(cCabArquivo + cMsg)
	
	If lAddLog
		GFELog117:Add(cMsg, nIdent)
	EndIf
Return Nil
//--------------------------------------------------------------------
// AddResult - Adiciona informaçÃµes na tela de resultados
//--------------------------------------------------------------------
Static Function AddResult(cMsg, nIdent, lAddLog)
	Default nIdent  := 2
	Default lAddLog := .F.
	
	GFEResult:Add(cMsg, nIdent)
	
	If lAddLog
		GFELog117:Add(cMsg, nIdent)
	EndIf
Return Nil
//--------------------------------------------------------------------
// AddPreValid - Inclui erros de pré-validação no registro GXL
//				 ValidaçÃµes que não impedem a importação
//		Exemplo: Data de emissão não informada
//--------------------------------------------------------------------
Static Function AddPreValid(cMsg, nIdent)
	Default nIdent := 2
	
	cMsgPreVal += "- " + cMsg + CHR(13) + CHR(10)
	cErrosOco += "    ** " + cMsg + CHR(13) + CHR(10)
	GFELog117:Add("** " + cMsg, nIdent)
Return Nil
//--------------------------------------------------------------------
// GetEmitCNPJ - Retorna o código do emitente pelo CNPJ
//	
//--------------------------------------------------------------------
Static Function GetEmitCNPJ(cCNPJ)
	Local cRet      := ""
	Local cAliasGU3 := Nil

	If !Empty(cCNPJ)
		cAliasGU3 := GetNextAlias()
		BeginSql Alias cAliasGU3
			SELECT GU3.GU3_CDEMIT
			FROM %Table:GU3% GU3
			WHERE GU3.GU3_FILIAL = %xFilial:GU3%
			AND GU3.GU3_IDFED = %Exp:cCNPJ%
			AND GU3.GU3_SIT = '1'
			AND GU3.%NotDel%
		EndSql
		If (cAliasGU3)->(!Eof())
			cRet := (cAliasGU3)->GU3_CDEMIT
		EndIf
		(cAliasGU3)->(dbCloseArea())
	EndIf
Return cRet
//--------------------------------------------------------------------
// GetStr - Extrai parte de uma String
//--------------------------------------------------------------------
Static Function GetStr(cBuffer, nPos, nTamanho)
	Local cRet := ""
	
	If nPos + nTamanho > Len(cBuffer)
		cRet := SubStr(cBuffer, nPos)
	Else
		cRet := SubStr(cBuffer, nPos, nTamanho)
	EndIf
	cRet := AllTrim(Upper(cRet))
Return cRet
//--------------------------------------------------------------------
// GetInt - Extrai parte de uma String convertendo para Inteiro
//--------------------------------------------------------------------
Static Function GetInt(cBuffer, nPos, nTamanho, nDec)
	Local nRet := 0
	Local cStr := ""

	Default nDec := 0
	
	cStr := GetStr(cBuffer, nPos, nTamanho)
	If nDec > 0
		cStr += "." + GetStr(cBuffer, nPos + nTamanho, nDec)
	EndIf
	nRet := Val(cStr)
Return nRet
//--------------------------------------------------------------------
// GetDate - Extrai parte de uma String convertendo para Data
//--------------------------------------------------------------------
Static Function GetDate(cBuffer, nPos, nTamanho)
	Local dRet := Nil
	Local cStr := ""
	
	If nTamanho == 8
		cStr := GetStr(cBuffer, nPos + 4, 4) + GetStr(cBuffer, nPos + 2, 2) + GetStr(cBuffer, nPos, 2)
	EndIf
	dRet := SToD(cStr)
Return dRet
