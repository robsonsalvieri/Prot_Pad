#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "GFEA117C.CH"

#Define GFEA117C01 "GFEA117C01"
#Define GFEA117C02 "GFEA117C02"
#Define GFEA117C03 "GFEA117C03"
#Define GFEA117C04 "GFEA117C04"
#Define GFEA117C05 "GFEA117C05"
#Define GFEA117C06 "GFEA117C06"
#Define GFEA117C07 "GFEA117C07"
#Define GFEA117C08 "GFEA117C08"
#Define GFEA117C09 "GFEA117C09"
#Define GFEA117C10 "GFEA117C10"
#Define GFEA117C11 "GFEA117C11"
#Define GFEA117C12 "GFEA117C12"

Static __nTamNrDC  := TamSX3("GW1_NRDC")[1]
Static s_VLCNPJ := SuperGetMV("MV_VLCNPJ",,"1")

Function GFEA117C()
Local lTrecho     := .F.
Local lEncTipo    := .T.
Local lEncDoc     := .F.
Local aOcorTOTVS[28]
Local aRet[2]
Local cMarca      := IIf(!IsBlind(), oBrowse117:Mark(), "")
Local cFilOcor    := MV_PAR03
Local cAliasGW1   := Nil
Local cAliasGU3   := Nil
Local cAliasGU5   := Nil
Local cAliasGU6   := Nil
Local cMsgPreVal  := ""
Local cFilDc      := ""
Local cCdTpDc     := ""
Local cEmisDc     := ""
Local cSerDc      := ""
Local cNrDC       := ""
Local cCdTrp      := ""
Local cCdTipo     := ""
Local cCdMot      := ""
Local cCdRec      := ""
Local cEvenTr     := ""
Local cNmCont     := ""
Local cPrestServ  := ""
Local cIdFedRaiz  := ""
Local cListEmit   := ""
Local cSeqGWU     := ""
Local cNRIMP      := ""
Local cHorOcor    := ""
Local nPesoEnt    := 0
Local nQtdVol     := 0
Local nQtdServ    := 0
Local nValInd     := 0
Local nContLinhas := 0
Local nI          := 0
Local nContDc     := 0
Local dDatOcor    := Date()
Local cMensagem   := ""

	Do While !GFEFile:FEof()
		cBuffer    := GFEFile:Line()
		lTrecho    := .F.
		cMsgPreVal := ""
		cNrDC      := ""
		lEncDoc    := .F.

		nContLinhas++
		cNRIMP     := GETSXENUM("GXL", "GXL_NRIMP")
		aOcorTOTVS := GFEStrToArr(cBuffer, ";")
		/*
		aOcorTOTVS[1]  // Identificador de Layout
		aOcorTOTVS[2]  // Identificador de registro
		aOcorTOTVS[3]  // Versão do Layout
		aOcorTOTVS[4]  // CNPJ Embarcador
		aOcorTOTVS[5]  // CNPJ Transportador
		aOcorTOTVS[6]  // Chave NF-e
		aOcorTOTVS[7]  // CNPJ Emissor NF
		aOcorTOTVS[8]  // Serie NF
		aOcorTOTVS[9]  // Numero NF
		aOcorTOTVS[10] // Data Emissão NF
		aOcorTOTVS[11] // Trecho
		aOcorTOTVS[12] // Evento
		aOcorTOTVS[13] // Data Ocorrência
		aOcorTOTVS[14] // Hora Ocorrência
		aOcorTOTVS[15] // Código Tipo Ocorrência
		aOcorTOTVS[16] // Código Motivo Ocorrência
		aOcorTOTVS[17] // Peso Entrega em KG
		aOcorTOTVS[18] // Quantidade Entrega
		aOcorTOTVS[19] // CNPJ Prestador Serviço
		aOcorTOTVS[20] // Quantidade Servico
		aOcorTOTVS[21] // Valor Total Adicional - (Campos que não têm correspondente na tabela Ocorrências)
		aOcorTOTVS[22] // Valor Indenização
		aOcorTOTVS[23] // Descrição Breve
		aOcorTOTVS[24] // Descrição Longa
		aOcorTOTVS[25] // Nome Contato
		aOcorTOTVS[26] // CNPJ/CPF/RG Recebedor
		aOcorTOTVS[27] // Nome Recebedor - (Campos que não têm correspondente na tabela Ocorrências)
		aOcorTOTVS[28] // Link de evidencia de entrega realizada
		*/
		If Len(aOcorTOTVS) < 14
			cMensagem := GFEMsgFmt(STR0001,{{"[VAR01]",cNomeArq}}) // Arquivo [VAR01] inválido.
			aRet[1] := .F.
			aRet[2] := cMensagem
			GFEResult:AddErro(cMensagem)
			GFELog117:NewLine()
			GFELog117:Save()
			lArquivoValido := .F.
		EndIf
		If lArquivoValido
			aOcorTOTVS[1]  := AllTrim(aOcorTOTVS[1])  // Identificador de Layout
			aOcorTOTVS[2]  := AllTrim(aOcorTOTVS[2])  // Identificador de registro
			aOcorTOTVS[3]  := AllTrim(aOcorTOTVS[3])  // Versão do Layout
			aOcorTOTVS[4]  := AllTrim(aOcorTOTVS[4])  // CNPJ Embarcador
			aOcorTOTVS[5]  := AllTrim(aOcorTOTVS[5])  // CNPJ Transportador
			aOcorTOTVS[6]  := AllTrim(aOcorTOTVS[6])  // Chave NF-e
			aOcorTOTVS[7]  := AllTrim(aOcorTOTVS[7])  // CNPJ Emissor NF
			aOcorTOTVS[8]  := AllTrim(aOcorTOTVS[8])  // Serie NF
			aOcorTOTVS[9]  := AllTrim(aOcorTOTVS[9])  // Numero NF
			aOcorTOTVS[10] := AllTrim(aOcorTOTVS[10]) // Data Emissão NF
			aOcorTOTVS[11] := AllTrim(aOcorTOTVS[11]) // Trecho
			aOcorTOTVS[12] := AllTrim(aOcorTOTVS[12]) // Evento
			aOcorTOTVS[13] := AllTrim(aOcorTOTVS[13]) // Data Ocorrência
			aOcorTOTVS[14] := AllTrim(aOcorTOTVS[14]) // Hora Ocorrência
			For nI := 1 To (30 - Len(aOcorTOTVS))
				aAdd(aOcorTOTVS, "")
			Next nI
			aOcorTOTVS[19] := AllTrim(aOcorTOTVS[19]) // CNPJ Prestador de Serviço
			aOcorTOTVS[23] := AllTrim(aOcorTOTVS[23]) // Descrição Breve
			aOcorTOTVS[25] := AllTrim(aOcorTOTVS[25]) // Nome do contato
			
			If aOcorTOTVS[2] != '01' .Or. aOcorTOTVS[3] != '100'
				cMensagem := GFEMsgFmt(STR0001,{{"[VAR01]",cNomeArq}}) // Arquivo [VAR01] inválido.
				aRet[1] := .F.
				aRet[2] := cMensagem
				GFEResult:AddErro(cMensagem)
				GFELog117:NewLine()
				GFELog117:Save()
				lArquivoValido := .F.
			EndIf
		EndIf
		If lArquivoValido
			//Remove a formatação do CNPJ, caso venha formatado.
			If SubStr(aOcorTOTVS[4], 3, 1) == "."
				aOcorTOTVS[4] := SubStr(aOcorTOTVS[4], 1, 2) + SubStr(aOcorTOTVS[4], 4, 3) + SubStr(aOcorTOTVS[4], 8, 3) + SubStr(aOcorTOTVS[4], 12, 4) + SubStr(aOcorTOTVS[4], 17, 2)
			EndIf
			
			If SubStr(aOcorTOTVS[5], 3, 1) == "."
				aOcorTOTVS[5] := SubStr(aOcorTOTVS[5], 1, 2) + SubStr(aOcorTOTVS[5], 4, 3) + SubStr(aOcorTOTVS[5], 8, 3) + SubStr(aOcorTOTVS[5], 12, 4) + SubStr(aOcorTOTVS[5], 17, 2)
			EndIf
			
			If SubStr(aOcorTOTVS[7], 3, 1) == "."
				aOcorTOTVS[7] := SubStr(aOcorTOTVS[7], 1, 2) + SubStr(aOcorTOTVS[7], 4, 3) + SubStr(aOcorTOTVS[7], 8, 3) + SubStr(aOcorTOTVS[7], 12, 4) + SubStr(aOcorTOTVS[7], 17, 2)
			EndIf
			
			If SubStr(aOcorTOTVS[19], 3, 1) == "."
				aOcorTOTVS[19] := SubStr(aOcorTOTVS[19], 1, 2) + SubStr(aOcorTOTVS[19], 4, 3) + SubStr(aOcorTOTVS[19], 8, 3) + SubStr(aOcorTOTVS[19], 12, 4) + SubStr(aOcorTOTVS[19], 17, 2)
			EndIf

			If SubStr(aOcorTOTVS[26], 3, 1) == "."
				aOcorTOTVS[26] := SubStr(aOcorTOTVS[26], 1, 2) + SubStr(aOcorTOTVS[26], 4, 3) + SubStr(aOcorTOTVS[26], 8, 3) + SubStr(aOcorTOTVS[26], 12, 4) + SubStr(aOcorTOTVS[26], 17, 2)
			EndIf

			If Len(aOcorTOTVS[12]) == 2
				aOcorTOTVS[12] := SubStr(aOcorTOTVS[12], 2, 1)
			EndIf
			
			//Remove a formatação da data, caso venha formatada. Ajusta para o padrão AAAAMMDD. Ajusta o ano caso venha com 2 posições apenas.
			If SubStr(aOcorTOTVS[13], 3, 1) == "/" .Or. SubStr(aOcorTOTVS[13], 3, 1) == "-"
				aOcorTOTVS[13] := If( Len(SubStr(aOcorTOTVS[13], 7)) == 2, "20" + SubStr(aOcorTOTVS[13], 7), SubStr(aOcorTOTVS[13], 7) ) + SubStr(aOcorTOTVS[13], 4, 2) +  SubStr(aOcorTOTVS[13], 1, 2)
			Else
				If Len(aOcorTOTVS[13]) > 6 .And. !(Val(SubStr(aOcorTOTVS[13], 3, 2)) > 12)
					aOcorTOTVS[13] := SubStr(aOcorTOTVS[13], 5) + SubStr(aOcorTOTVS[13], 3, 2) +  SubStr(aOcorTOTVS[13], 1, 2)
				EndIf
			EndIf
			//Formata o valor da hora.
			If (SubStr(aOcorTOTVS[14], 3, 1) <> ":")
				aOcorTOTVS[14] := SubStr(aOcorTOTVS[14], 1, 2) + ":"+SubStr(aOcorTOTVS[14], 3, 2)
			EndIf
			// Inicializa variáveis
			dDatOcor    := STOD(aOcorTOTVS[13])
			cHorOcor    := aOcorTOTVS[14]
			cObs        := aOcorTOTVS[23]
			cNmCont     := aOcorTOTVS[25]
			nQtdVol     := Val(aOcorTOTVS[18])
			nQtdServ    := Val(aOcorTOTVS[20])
			nValInd     := Val(aOcorTOTVS[22])
			cPrestServ  := ""
			// Atribui sequencia do trecho
			cSeqGWU := "0"+AllTrim(aOcorTOTVS[11])
			If !Empty(aOcorTOTVS[19])
				cAliasGU3 := GetNextAlias()
				BeginSql Alias cAliasGU3
					SELECT GU3.GU3_CDEMIT
					FROM %Table:GU3% GU3
					WHERE GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_IDFED = %Exp:aOcorTOTVS[19]% //CNPJ Prestador de Serviço
					AND GU3.%NotDel%
				EndSql
				If (cAliasGU3)->(!Eof())
					cPrestServ := (cAliasGU3)->GU3_CDEMIT
				EndIf
				(cAliasGU3)->(dbCloseArea())
			EndIf
			// Atribui dados da NF
			If Empty(aOcorTOTVS[6])
				GFELog117:Add("- "+ STR0002, 1) // Busca o documento de carga e efetua tentativa de busca do número com zeros à esquerda.
				lEncDoc := .F.
				cNrDC := AllTrim(Str(Val(aOcorTOTVS[9])))
				// Regra para buscar o número da nota fiscal no GFE:
				// Inicia a busca a partir do número sem zeros à esquerda e enquanto
				// não encontrar vai adicionando os zeros até o limite (tam. campo GW1_NRDC)
				nContDc := Len(cNrDC) + 1
				If !Empty(cNrDC)
					For nI := nContDc To __nTamNrDC
						cAliasGW1 := GetNextAlias()
						BeginSql Alias cAliasGW1
							SELECT GW1.GW1_FILIAL,
									GW1.GW1_CDTPDC,
									GW1.GW1_EMISDC,
									GW1.GW1_SERDC,
									GW1.GW1_NRDC,
									GU3.GU3_CDEMIT
							FROM %Table:GW1% GW1
							INNER JOIN %Table:GU3% GU3
							ON GU3.GU3_FILIAL = %xFilial:GU3%
							AND GU3.GU3_IDFED = %Exp:aOcorTOTVS[7]%
							AND GU3.GU3_CDEMIT = GW1.GW1_EMISDC
							AND GU3.%NotDel%
							WHERE GW1.GW1_SERDC = %Exp:aOcorTOTVS[8]%
							AND GW1.GW1_NRDC = %Exp:cNrDC%
							AND GW1.%NotDel%
						EndSql
						If (cAliasGW1)->(!Eof())
							cFilDc  := (cAliasGW1)->GW1_FILIAL
							cCdTpDc := (cAliasGW1)->GW1_CDTPDC
							cEmisDc := (cAliasGW1)->GU3_CDEMIT //CNPJ Emissor NF
							cSerDc  := aOcorTOTVS[8]           //Serie NF
							lEncDoc := .T.
						EndIf
						(cAliasGW1)->(dbCloseArea())
						GFELog117:Add("> " + GFEMsgFmt(STR0003,{{"[VAR01]",AllTrim(cNrDC)},{"[VAR02]",IIf(lEncDoc," [" + STR0004 + "]"," [" + STR0005 + "]")}}), 1) // Número.: [VAR01][VAR02].
						If lEncDoc
							Exit
						EndIf
						cNrDC := PadL(cNrDC, Len(cNrDC) + 1, "0")
					Next nI
				EndIf

				If !lEncDoc
					cEmisDc := ""
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3.GU3_CDEMIT
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_IDFED = %Exp:aOcorTOTVS[7]% //CNPJ Emissor NF
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cEmisDc := (cAliasGU3)->GU3_CDEMIT
					EndIf
					(cAliasGU3)->(dbCloseArea())

					cSerDc    := aOcorTOTVS[8]  //Serie NF
					cNrDc     := aOcorTOTVS[9]  //Numero NF

					cMensagem := GFEMsgFmt(STR0006,{{"[VAR01]",AllTrim(aOcorTOTVS[8])},{"[VAR02]",AllTrim(aOcorTOTVS[9])}}) + " "+ STR0007
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** "+ cMensagem,1)
					cMsgPreVal += "[" + GFEA117C01 + "] " + cMensagem + CRLF
				EndIf
			Else
				cAliasGW1 := GetNextAlias()
				BeginSql Alias cAliasGW1
					SELECT GW1.GW1_FILIAL,
							GW1.GW1_CDTPDC,
							GW1.GW1_EMISDC,
							GW1.GW1_SERDC,
							GW1.GW1_NRDC
					FROM %Table:GW1% GW1
					WHERE GW1.GW1_DANFE = %Exp:aOcorTOTVS[6]%
					AND GW1.%NotDel%
				EndSql
				If (cAliasGW1)->(!Eof())
					cFilDc  := (cAliasGW1)->GW1_FILIAL
					cCdTpDc := (cAliasGW1)->GW1_CDTPDC
					cEmisDc := (cAliasGW1)->GW1_EMISDC
					cSerDc  := (cAliasGW1)->GW1_SERDC
					cNrDc   := (cAliasGW1)->GW1_NRDC
				Else
					cMensagem := GFEMsgFmt(STR0008,{{"[VAR01]",AllTrim(aOcorTOTVS[6])}}) + " "+ STR0007
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem,1)
					cMsgPreVal += "[" + GFEA117C02 + "] " + cMensagem + CRLF
				EndIf
				(cAliasGW1)->(dbCloseArea())
			EndIf
			// Atribui o transportador
			If !Empty(aOcorTOTVS[5]) .And. (Empty(aOcorTOTVS[11]) .Or. aOcorTOTVS[11] $ '0;9')
				cIdFedRaiz := IIf(s_VLCNPJ == "2","%'"+SubStr(aOcorTOTVS[5],1,8)+"%'%",aOcorTOTVS[5])
				cAliasGU3 := GetNextAlias()
				BeginSql Alias cAliasGU3
					SELECT GU3.GU3_CDEMIT
					FROM %Table:GU3% GU3
					WHERE GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_IDFED LIKE %Exp:cIdFedRaiz%
					AND GU3.%NotDel%
				EndSql
				If (cAliasGU3)->(!Eof())
					cListEmit :=  IIf(s_VLCNPJ == "2",GFEGetEmRz((cAliasGU3)->GU3_CDEMIT),(cAliasGU3)->GU3_CDEMIT)
					cAliasGWU := GetNextAlias()
					BeginSql Alias cAliasGWU
						SELECT GWU.GWU_CDTRP
						FROM %Table:GWU% GWU
						WHERE GWU.GWU_FILIAL = %Exp:cFilDc%
						AND GWU.GWU_CDTPDC = %Exp:cCdTpDc%
						AND GWU.GWU_EMISDC = %Exp:cEmisDc%
						AND GWU.GWU_SERDC = %Exp:cSerDc%
						AND GWU.GWU_NRDC = %Exp:cNrDc%
						AND GWU.GWU_CDTRP IN (%Exp:cListEmit%)
						AND GWU.%NotDel%
					EndSql
					If (cAliasGWU)->(!Eof())
						cCdTrp := (cAliasGWU)->GWU_CDTRP
					Else
						cMensagem := GFEMsgFmt(STR0009,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0010
						aRet[1] := .F.
						aRet[2] := cMensagem
						GFELog117:Add("  ** " + cMensagem,1)
						cMsgPreVal += "[" + GFEA117C03 + "] " +cMensagem + CRLF
					EndIf
					(cAliasGWU)->(dbCloseArea())
				Else
					cMensagem := GFEMsgFmt(STR0009,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0010
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem,1)
					cMsgPreVal += "[" + GFEA117C04 + "] " +cMensagem + CRLF
				EndIf
				(cAliasGU3)->(dbCloseArea())
			ElseIf Empty(aOcorTOTVS[5]) .And. !Empty(aOcorTOTVS[11])
				cAliasGWU := GetNextAlias()
				BeginSql Alias cAliasGWU
					SELECT GWU.GWU_CDTRP
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_FILIAL = %Exp:cFilDc%
					AND GWU.GWU_CDTPDC = %Exp:cCdTpDc%
					AND GWU.GWU_EMISDC = %Exp:cEmisDc%
					AND GWU.GWU_SERDC = %Exp:cSerDc%
					AND GWU.GWU_NRDC = %Exp:cNrDc%
					AND GWU.GWU_SEQ = %Exp:cSeqGWU%
					AND GWU.%NotDel%
				EndSql
				If (cAliasGWU)->(!Eof())
					cCdTrp := (cAliasGWU)->GWU_CDTRP
				Else
					cMensagem := GFEMsgFmt(STR0009,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0011
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem,1)
					cMsgPreVal += "[" + GFEA117C05 + "] " + cMensagem + CRLF
				EndIf
				(cAliasGWU)->(dbCloseArea())
			ElseIf !Empty(aOcorTOTVS[5]) .And. !Empty(aOcorTOTVS[11])
				//Valida o trecho informado com o CNPJ do transportador. Se nao corresponder retornar erro.
				//Raiz CNPJ.
				cIdFedRaiz := IIf(s_VLCNPJ == "2","%'"+SubStr(aOcorTOTVS[5],1,8)+"%'%",aOcorTOTVS[5])
				cAliasGU3 := GetNextAlias()
				BeginSql Alias cAliasGU3
					SELECT GU3.GU3_CDEMIT
					FROM %Table:GU3% GU3
					WHERE GU3.GU3_FILIAL = %xFilial:GU3%
					AND GU3.GU3_IDFED LIKE %Exp:cIdFedRaiz%
					AND GU3.%NotDel%
				EndSql
				If (cAliasGU3)->(!Eof())
					cListEmit :=  IIf(s_VLCNPJ == "2",GFEGetEmRz((cAliasGU3)->GU3_CDEMIT),(cAliasGU3)->GU3_CDEMIT)
					cAliasGWU := GetNextAlias()
					BeginSql Alias cAliasGWU
						SELECT GWU.GWU_CDTRP
						FROM %Table:GWU% GWU
						WHERE GWU.GWU_FILIAL = %Exp:cFilDc%
						AND GWU.GWU_CDTPDC = %Exp:cCdTpDc%
						AND GWU.GWU_EMISDC = %Exp:cEmisDc%
						AND GWU.GWU_SERDC = %Exp:cSerDc%
						AND GWU.GWU_NRDC = %Exp:cNrDc%
						AND GWU.GWU_SEQ = %Exp:cSeqGWU%
						AND GWU.GWU_CDTRP IN (%Exp:cListEmit%)
						AND GWU.%NotDel%
					EndSql
					If (cAliasGWU)->(!Eof())
						cCdTrp := (cAliasGWU)->GWU_CDTRP
					Else
						cMensagem := GFEMsgFmt(STR0012,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0013
						aRet[1] := .F.
						aRet[2] := cMensagem
						GFELog117:Add("  ** " + cMensagem,1)
						cMsgPreVal += "[" + GFEA117C06 + "] " + cMensagem + CRLF
					EndIf
					(cAliasGWU)->(dbCloseArea())
				Else
					cMensagem := GFEMsgFmt(STR0012,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0013
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem,1)
					cMsgPreVal += "[" + GFEA117C07 + "] " + cMensagem + CRLF
				EndIf
				(cAliasGU3)->(dbCloseArea())
			ElseIf Empty(aOcorTOTVS[5]) .And. Empty(aOcorTOTVS[11])
				//Localiza o trecho e se for trecho único atribui o CNPJ do transportador.
				cAliasGWU := GetNextAlias()
				BeginSql Alias cAliasGWU
					SELECT 1
					FROM %Table:GWU% GWU
					WHERE GWU.GWU_FILIAL = %Exp:cFilDc%
					AND GWU.GWU_CDTPDC = %Exp:cCdTpDc%
					AND GWU.GWU_EMISDC = %Exp:cEmisDc%
					AND GWU.GWU_SERDC = %Exp:cSerDc%
					AND GWU.GWU_NRDC = %Exp:cNrDc%
					AND GWU.%NotDel%
				EndSql
				If (cAliasGWU)->(!Eof())
					lTrecho := .T.
				EndIf
				(cAliasGWU)->(dbCloseArea())
				If lTrecho
					cAliasGWU := GetNextAlias()
					BeginSql Alias cAliasGWU
						SELECT GWU.GWU_CDTRP
						FROM %Table:GWU% GWU
						WHERE GWU.GWU_FILIAL = %Exp:cFilDc%
						AND GWU.GWU_CDTPDC = %Exp:cCdTpDc%
						AND GWU.GWU_EMISDC = %Exp:cEmisDc%
						AND GWU.GWU_SERDC = %Exp:cSerDc%
						AND GWU.GWU_NRDC = %Exp:cNrDc%
						AND NOT EXISTS (SELECT 1
										FROM %Table:GWU% GWU1
										WHERE GWU1.GWU_FILIAL = GWU.GWU_FILIAL
										AND GWU1.GWU_CDTPDC = GWU.GWU_CDTPDC
										AND GWU1.GWU_EMISDC = GWU.GWU_EMISDC
										AND GWU1.GWU_SERDC = GWU.GWU_SERDC
										AND GWU1.GWU_NRDC = GWU.GWU_NRDC
										AND GWU1.GWU_SEQ > '01'
										AND GWU1.%NotDel%)
						AND GWU.%NotDel%
					EndSql
					If (cAliasGWU)->(!Eof())
						cCdTrp := (cAliasGWU)->GWU_CDTRP
					Else
						cMensagem := GFEMsgFmt(STR0009,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0011
						aRet[1] := .F.
						aRet[2] := cMensagem
						GFELog117:Add("  ** " + cMensagem,1)
						cMsgPreVal += "[" + GFEA117C08 + "] " + cMensagem + CRLF
					EndIf
					(cAliasGWU)->(dbCloseArea())
				Else
					cMensagem := GFEMsgFmt(STR0009,{{"[VAR01]",AllTrim(cSerDc)},{"[VAR02]",AllTrim(cNrDc)}}) + " " + STR0014
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem,1)
					cMsgPreVal += "[" + GFEA117C09 + "] " + cMensagem + CRLF
				EndIf
			EndIf
			// Atribui tipo de ocorrência e motivo
			If Empty(aOcorTOTVS[12]) .And. !Empty(aOcorTOTVS[15])
				cCdTipo := aOcorTOTVS[15]
				If Empty(aOcorTOTVS[16])
					cAliasGU6 := GetNextAlias()
					BeginSql Alias cAliasGU6
						SELECT GU6.GU6_CDMOT
						FROM %Table:GU4% GU4
						INNER JOIN %Table:GU6% GU6
						ON GU6.GU6_FILIAL = %xFilial:GU6%
						AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
						AND GU6.GU6_SIT = '1'
						AND GU6.%NotDel%
						WHERE GU4.GU4_FILIAL = %xFilial:GU4%
						AND GU4.GU4_CDTIPO = %Exp:aOcorTOTVS[15]%
						AND GU4.%NotDel%
					EndSql
					If (cAliasGU6)->(!Eof())
						cCdMot := (cAliasGU6)->GU6_CDMOT
					EndIf
					(cAliasGU6)->(dbCloseArea())
				Else
					cCdMot := aOcorTOTVS[16]
				EndIf
			ElseIf !Empty(aOcorTOTVS[12]) .And. !Empty(aOcorTOTVS[15]) //Se veio evento e tipo preenchidos.
				cAliasGU5 := GetNextAlias()
				BeginSql Alias cAliasGU5
					SELECT GU5.GU5_EVENTO
					FROM %Table:GU5% GU5
					WHERE GU5.GU5_FILIAL = %xFilial:GU5%
					AND GU5.GU5_CDTIPO = %Exp:aOcorTOTVS[15]%
					AND GU5.%NotDel%
				EndSql
				If (cAliasGU5)->(!Eof())
					If aOcorTOTVS[12] <> (cAliasGU5)->GU5_EVENTO
						cMensagem := GFEMsgFmt(STR0015,{{"[VAR01]",AllTrim(aOcorTOTVS[15])},{"[VAR02]",AllTrim(aOcorTOTVS[12])},{"[VAR03]",AllTrim((cAliasGU5)->GU5_EVENTO)}}) + " " + STR0016
						aRet[1] := .F.
						aRet[2] := cMensagem
						GFELog117:Add("  ** " + cMensagem,1)
						cMsgPreVal += "[" + GFEA117C10 + "] " + cMensagem + CRLF
						lEncTipo := .F.
					EndIf
				Else
					cMensagem := STR0017 + " " + STR0018
					aRet[1] := .F.
					aRet[2] := cMensagem
					GFELog117:Add("  ** " + cMensagem)
					cMsgPreVal += "[" + GFEA117C11 + "] " + cMensagem + CRLF
					lEncTipo := .F.
				EndIf
				(cAliasGU5)->(dbCloseArea())
				If lEncTipo
					cCdTipo := aOcorTOTVS[15]
					cCdMot  := aOcorTOTVS[16]
				EndIf
			ElseIf !Empty(aOcorTOTVS[12]) .And. Empty(aOcorTOTVS[15]) //Evento
				cAliasGU5 := GetNextAlias()
				BeginSql Alias cAliasGU5
					SELECT GU5.GU5_CDTIPO,
							GU6.GU6_CDMOT
					FROM %Table:GU5% GU5
					INNER JOIN %Table:GU4% GU4
					ON GU4.GU4_FILIAL = %xFilial:GU4%
					AND GU4.GU4_CDTIPO = GU5.GU5_CDTIPO
					AND GU4.%NotDel%
					INNER JOIN %Table:GU6% GU6
					ON GU6.GU6_FILIAL = %xFilial:GU6%
					AND GU6.GU6_CDMOT = GU4.GU4_CDMOT
					AND GU6.GU6_SIT = '1'
					AND GU6.%NotDel%
					WHERE GU5.GU5_FILIAL = %xFilial:GU5%
					AND GU5.GU5_EVENTO = %Exp:aOcorTOTVS[12]%
					AND GU5.GU5_SIT = '1'
					AND GU5.%NotDel%
				EndSql
				If (cAliasGU5)->(!Eof())
					cCdTipo := (cAliasGU5)->GU5_CDTIPO
					cCdMot  := (cAliasGU5)->GU6_CDMOT
				EndIf
				(cAliasGU5)->(dbCloseArea())
			Else
				cMensagem := STR0019 + " " + STR0020
				aRet[1] := .F.
				aRet[2] := cMensagem
				GFELog117:Add("  ** " + cMensagem,1)
				cMsgPreVal += "[" + GFEA117C12 + "] " + cMensagem + CRLF
			EndIf

			// Valida tipo de operação usado para saber se será repassado os valores para a importação
			nPesoEnt := 0
			If GFXCP12121("GXL_PESO")
				nPesoEnt   := VldTpOcor(cCdTipo, "4", Val(aOcorTOTVS[17])) 	// Atribui Peso Entrega em KG
			EndIf

			If GFXCP12121("GXL_QTDVOL")
				nQtdVol    := VldTpOcor(cCdTipo, "4", Val(aOcorTOTVS[18]))	// Atribui Quantidade Entrega
			EndIf

			If GFXCP12121("GXL_PRESTS")
				cPrestServ := VldTpOcor(cCdTipo, "1", cPrestServ)			// Atribui CNPJ Prestador Serviço
			EndIf

			If GFXCP12121("GXL_QTPERN")
				nQtdServ   := VldTpOcor(cCdTipo, "1", Val(aOcorTOTVS[20]))	// Atribui Quantidade Servico
			EndIf

			// Atribui o Recebedor
			If GFXCP12121("GXL_CDREC")
				cCdRec := ""
				If !Empty(aOcorTOTVS[26])
					cAliasGU3 := GetNextAlias()
					BeginSql Alias cAliasGU3
						SELECT GU3.GU3_CDEMIT
						FROM %Table:GU3% GU3
						WHERE GU3.GU3_FILIAL = %xFilial:GU3%
						AND GU3.GU3_IDFED = %Exp:aOcorTOTVS[26]%
						AND EXISTS (SELECT 1
									FROM %Table:GU5% GU5
									WHERE GU5.GU5_FILIAL = %xFilial:GU5%
									AND GU5.GU5_CDTIPO = %Exp:cCdTipo%
									AND GU5.GU5_EVENTO = '4'
									AND GU5.%NotDel%)
						AND GU3.%NotDel%
					EndSql
					If (cAliasGU3)->(!Eof())
						cCdRec := (cAliasGU3)->GU3_CDEMIT
					EndIf
					(cAliasGU3)->(dbCloseArea())
				EndIf
			EndIf
			// Atribui comprovamente de entrega
			cEvenTr := Alltrim(aOcorTOTVS[28])
			// Atribui situação do EDI
			cSitEdi := '1'
			If !Empty(cMsgPreVal)
				cSitEdi := '2'
				lImpErr := .T.
			EndIf
			// Grava Dados
			RecLock("GXL", .T.)
				GXL->GXL_FILIAL := xFilial("GXL")
				GXL->GXL_MARKBR := cMarca
				GXL->GXL_NRIMP	:= cNRIMP
				GXL->GXL_EDINRL	:= nContLinhas
				GXL->GXL_EDILIN	:= cBuffer
				GXL->GXL_EDIARQ := cNomeArq
				GXL->GXL_DTIMP	:= Date()
				GXL->GXL_ALTER	:= "2"
				GXL->GXL_EDIMSG := cMsgPreVal
				GXL->GXL_EDISIT := cSitEdi
				GXL->GXL_USUIMP	:= cUserName
				GXL->GXL_FILOCO := IIf(Empty(cFilDc),cFilOcor,cFilDc)
				GXL->GXL_DTOCOR := dDatOcor       // Data Ocorrência
				GXL->GXL_HROCOR := cHorOcor       // Hora Ocorrência
				//GXL->GXL_CODOBS
				GXL->GXL_OBS    := cObs           // Descrição Breve
				GXL->GXL_FILDC  := cFilDc         // Filial NF
				GXL->GXL_EMISDC := cEmisDc        // CNPJ Emissor NF
				GXL->GXL_SERDC  := cSerDc         // Serie NF
				GXL->GXL_NRDC   := cNrDC          // Numero NF
				GXL->GXL_CDTRP  := cCdTrp         // Transportador
				GXL->GXL_CDTIPO := cCdTipo        // Código Tipo Ocorrência
				GXL->GXL_CDMOT  := cCdMot         // Código Motivo Ocorrência
				GXL->GXL_PESO   := nPesoEnt       // Peso Entrega em KG
				GXL->GXL_CDREC  := cCdRec         // Recebedor
				If GFXCP12130("GXL_EVENTR")
					GXL->GXL_EVENTR := cEvenTr    // Evidencia de comprovante de entrega
				EndIf
				If GFXCP12130("GXL_NMCONT")
					GXL->GXL_NMCONT := cNmCont    // Nome do contato
				EndIf
				If GFXCP12130("GXL_PRESTS")
					GXL->GXL_PRESTS := cPrestServ // Prestador de Serviço
				EndIf
				If GFXCP12130("GXL_QTDVOL")
					GXL->GXL_QTDVOL := nQtdVol    // Quantidade volume
				EndIf
				If GFXCP12130("GXL_QTPERN")
					GXL->GXL_QTPERN := nQtdServ   // Quantidade de Serviços
				EndIf
				If GFXCP12130("GXL_VALIND")
					GXL->GXL_VALIND := nValInd // Valor Indenização
				EndIf
			GXL->(MsUnlock())
		EndIf

		ConfirmSX8()
		GFEFile:FNext()
	EndDo
Return aRet

Static Function GFEStrToArr(cString,cSeparador)
	Local aArray := {}
	Local nX     := 0
	Local nF     := 0
	Local nPosIn := 1
	Local nQtdC  := 0

	If !Empty(cSeparador)
		nF := Len(cString)
		For nX := 1 To nF
			nQtdC++
			If SubStr(cString,nX,1) == cSeparador
				aAdd(aArray, SubStr(cString, nPosIn, nQtdC - 1))
				nPosIn := nX + 1
				nQtdC  := 0
			EndIf	
		Next nX
		aAdd(aArray, SubStr(cString, nPosIn, nQtdC))
	EndIf
Return aArray

Static Function VldTpOcor(cCdTipo, cEvento, xCont)
	Local cWhere    := " "
	Local xRetCont  := IIF(Valtype(xCont)=="N", 0, "")
	Local cAliasGU5 := GetNextAlias()

	If Alltrim(cEvento) = "1"
		cWhere := " AND GU5.GU5_TPCALC = '3'"
	EndIf
	cWhere := "% GU5.D_E_L_E_T_ = ' '" + cWhere + "%"

	BeginSql Alias cAliasGU5
		SELECT R_E_C_N_O_ AS RECNUM
		FROM %Table:GU5% GU5
		WHERE GU5.GU5_FILIAL = %xFilial:GU5%
		AND GU5.GU5_CDTIPO = %Exp:cCdTipo%
		AND GU5.GU5_EVENTO = %Exp:cEvento%
		AND %Exp:cWhere%
	EndSql
	If (cAliasGU5)->(!Eof())
		xRetCont := xCont
	EndIf

	(cAliasGU5)->(dbCloseArea())
Return xRetCont
