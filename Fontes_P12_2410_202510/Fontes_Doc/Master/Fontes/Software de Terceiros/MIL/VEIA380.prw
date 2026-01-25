#Include "PROTHEUS.CH"
#Include "VEIA380.CH"


/*/{Protheus.doc} VEIA380

	@type Function
	@author Francisco Carvalho
	@since 30/04/2025
/*/
Function VEIA380()

	Local oTProces
	Local bProcess

	Private lSchedule := FWGetRunSchedule()

	bProcess := { |oSelf| VA380001D_Processa(oSelf) }

	If lSchedule
		conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		conout("~~~~~~~~~~~~ ENVIANDO ARQUIVO MARKSOLD PARA O CIFT ~~~~~~~~~~~~")
		conout("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		VA380001D_Processa()
	Else
		oTProces := tNewProcess():New(;
		/* 01 */				"VEIA380",;
		/* 02 */				STR0001,; //Envio de Arquivo Marcado Vendido (MarkedSold)
		/* 03 */				bProcess,;
		/* 04 */				STR0002,; //Esta rotina tem por objetivo efetuar o envio das informações Marcado Vendido - JD
		/* 05 */				"VEIA380" ,;
		/* 06 */				/*aInfoCustom*/ ,;
		/* 07 */				.t. /* lPanelAux */ ,;
		/* 08 */				5 /* nSizePanelAux */ ,;
		/* 09 */				/* cDescriAux */ ,;
		/* 10 */				.t. /* lViewExecute */ ,;
		/* 11 */				.t. /* lOneMeter */ )
	Endif

Return


/*/{Protheus.doc} SchedDef

	@type Static Function
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Static Function SchedDef()

	Local aParam := {"P","VEIA380","","",""}

Return aParam


/*/{Protheus.doc} VA380001D_Processa

	@type Function
	@author Francisco Carvalho
	@since 30/04/2025
/*/
Function VA380001D_Processa(oProcess)

	Local nCont      := 0
	Local cQuery     := " "
	Local cQryFin    := " "
	Local cQryBank   := " "
	Local cQryAux    := " "
	Local cQAlSQL    := "MRCVEN"
	Local cQAlFIN    := "MRCFIN"
	Local cBankName  := " "
	Local cProcNum   := " "
	Local cNfSerie   := " "
	Local cCargaIni  := MV_PAR03
	Local cDealerAcc := SuperGetMV("MV_MIL0005", .f., "")
	Local cFilBkp    := cFilAnt
	Local dData      := Date()
	Local cTime      := Time()
	Local cNomeArq   := Lower("DLR2JD_MARKSOLD_" + cDealerAcc + "_" + DtoS(dData) + "_" + SUBS(cTime,1,2) + SUBS(cTime,4,2) + SUBS(cTime,7,2) + ".json")
	Local aBody      := {}
	Local aFilis     := {}
	Local aAuxRec    := {}
	Local lEnvCft    := VV9->(FieldPos("VV9_ENVCFT")) > 0
	Local oFil       := OFJDRpmConfig():New()
	Local oCli, oChave, oFin, oAtend, oAux, oResult := Nil

	aFilis := oFil:GetFiliais()

	For nCont := 1 to Len(aFilis)
		cFilAnt := aFilis[nCont,1]

		//Caso MV_PAR03 apontar Carga Inicial, será realizada uma limpeza no campo VV9_ENVCFT para que seja possível realizar do Zero (Apenas para execução Manual)
		If !lSchedule .and. cCargaIni == 2 
			VA380006D_LimpaFlagEnvio()
		Endif

		cQryAux := " "

		cQryAux := "SELECT COUNT(VV9_ENVCFT)"
		cQryAux += "  FROM " + RetSQLName("VV9")
		cQryAux += " WHERE VV9_FILIAL = '" + xFilial("VV9") + "'"
		cQryAux += "   AND VV9_ENVCFT = '1'"
		cQryAux += "   AND D_E_L_E_T_ = ' ' "

		If lEnvCft .and. FM_SQL(cQryAux) == 0 //Primeira Carga
			VA380005D_PrimeiraCarga()
		Endif

		cQuery := "SELECT VV1.VV1_CHAINT"
		cQuery += "  ,VV1.VV1_CHASSI"
		cQuery += "  ,VQ0.VQ0_DATVEN"
		cQuery += "  ,VJR.VJR_ORDNUM"
		cQuery += "  ,SA1.A1_CGC"
		cQuery += "  ,SA1.A1_NOME"
		cQuery += "  ,SA1.A1_NREDUZ"
		cQuery += "  ,SA1.A1_END"
		cQuery += "  ,SA1.A1_BAIRRO"
		cQuery += "  ,SA1.A1_EST"
		cQuery += "  ,SA1.A1_CEP"
		cQuery += "  ,SA1.A1_MUN"
		cQuery += "  ,SA1.A1_TEL"
		cQuery += "  ,SA1.A1_DDI"
		cQuery += "  ,SA1.A1_DDD"
		cQuery += "  ,SA1.A1_EMAIL"
		cQuery += "  ,SYA.YA_DESCR"
		cQuery += "  ,VVA.VVA_NUMTRA"
		cQuery += "  ,VV0.VV0_CFFINA"
		cQuery += "  ,VV0.VV0_CLFINA"
		cQuery += "  ,VV0.VV0_LJFINA"
		cQuery += "  ,VV0.VV0_NFINAM"
		cQuery += "  ,VV0.VV0_NUMNFI"
		cQuery += "  ,VV0.VV0_SERNFI"
		cQuery += "  ,VV9.VV9_STATUS"
		cQuery += "  ,CASE"
		cQuery += "         WHEN VV9.VV9_STATUS = 'A' THEN '" + STR0009 + "'" //Em Aberto
		cQuery += "         WHEN VV9.VV9_STATUS = 'P' THEN '" + STR0010 + "'" //Pend.Aprovacao
		cQuery += "         WHEN VV9.VV9_STATUS = 'O' THEN '" + STR0011 + "'" //Pre-Aprovado
		cQuery += "         WHEN VV9.VV9_STATUS = 'L' THEN '" + STR0012 + "'" //Aprovado
		cQuery += "         WHEN VV9.VV9_STATUS = 'R' THEN '" + STR0013 + "'" //Reprovado
		cQuery += "         WHEN VV9.VV9_STATUS = 'F' THEN '" + STR0014 + "'" //Finalizado
		cQuery += "         WHEN VV9.VV9_STATUS = 'C' THEN '" + STR0015 + "'" //Cancelado
		cQuery += "    END Status_Atend"                                 
		cQuery += "  ,VV9.R_E_C_N_O_ RECVV9"
		cQuery += "  ,VAI.VAI_FABUSR"
		cQuery += "  ,VAI.VAI_NOMTEC"
		cQuery += "  ,SF2.F2_EMISSAO"
		cQuery += "  FROM " + RetSQLName("VVA") + " VVA"
		cQuery += " INNER JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = '" + xFilial('VV0') + "'"
		cQuery += "										    AND VV0.VV0_NUMTRA = VVA.VVA_NUMTRA"
		cQuery += "										    AND VV0.VV0_TIPFAT <> '2'" 
		cQuery += "										    AND VV0.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSQLName("VQ0") + " VQ0 ON VQ0.VQ0_FILIAL = '" + xFilial('VQ0') + "'" 
		cQuery += "										    AND VQ0.VQ0_CHAINT = VVA.VVA_CHAINT"
		cQuery += "										    AND VQ0.VQ0_STATUS <> '3'" 
		cQuery += "										    AND VQ0.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSQLName("VJR") + " VJR ON VJR.VJR_FILIAL = '" + xFilial('VJR') + "'" 
		cQuery += "										    AND VJR.VJR_CODVQ0 = VQ0.VQ0_CODIGO" 
		cQuery += "										    AND VJR.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSQLName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial('VV1') + "'" 
		cQuery += "										    AND VV1.VV1_CHAINT = VVA.VVA_CHAINT" 
		cQuery += "										    AND VV1.VV1_ESTVEI = '0'" 
		cQuery += "										    AND VV1.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSQLName("VE1") + " VE1 ON VE1.VE1_FILIAL = '" + xFilial('VE1') + "'"
		cQuery += "       								    AND VE1.VE1_CODMAR = VV1.VV1_CODMAR" 
		cQuery += "										    AND VE1.VE1_MARFAB IN ('JD','GRS','PLA','JDC','HCM')" 
		cQuery += "										    AND VE1.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSQLName("VV9") + " VV9 ON VV9.VV9_FILIAL = '" + xFilial('VV9') + "'" 
		cQuery += "										    AND VV9.VV9_NUMATE = VVA.VVA_NUMTRA" 
		cQuery += "										    AND VV9.D_E_L_E_T_ = ' '"
		If lEnvCft
			cQuery += " AND VV9.VV9_ENVCFT = '0'"
		Endif
		cQuery += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON SA1.A1_FILIAL = '" + xFilial('SA1') + "'" 
		cQuery += "										    AND SA1.A1_COD = VV9.VV9_CODCLI" 
		cQuery += "										    AND SA1.A1_LOJA = VV9.VV9_LOJA" 
		cQuery += "										    AND SA1.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSQLName("SYA") + " SYA ON SYA.YA_FILIAL = '" + xFilial('SYA') + "'" 
		cQuery += "											AND SYA.YA_CODGI = SA1.A1_PAIS" 
		cQuery += "											AND SYA.D_E_L_E_T_ = ' '"
		cQuery += " INNER JOIN " + RetSQLName("VAI") + " VAI ON VAI.VAI_FILIAL = '" + xFilial('VAI') + "'" 
		cQuery += "											AND VAI.VAI_CODVEN = VV0.VV0_CODVEN" 
		cQuery += "											AND VAI.D_E_L_E_T_ = ' '"
		cQuery += "  LEFT JOIN " + RetSQLName("SF2") + " SF2 ON SF2.F2_FILIAL = '" + xFilial('SF2') + "'" 
		cQuery += "											AND SF2.F2_DOC = VV0.VV0_NUMNFI" 
		cQuery += "											AND SF2.F2_SERIE = VV0.VV0_SERNFI" 
		cQuery += "											AND SF2.F2_CLIENTE = VV0.VV0_CODCLI" 
		cQuery += "											AND SF2.F2_LOJA = VV0.VV0_LOJA" 
		cQuery += "											AND SF2.D_E_L_E_T_ = ' '"
		cQuery += " 	 WHERE VVA.VVA_FILIAL = '" + xFilial('VVA') + "'"
		cQuery += "        AND VVA.D_E_L_E_T_ = ' '"

		dbUseArea(.t., "TOPCONN", TcGenQry( ,, cQuery ), cQAlSQL , .f., .t.)

		If ! lSchedule
			oProcess:SetRegua1((cQAlSQL)->(RecCount()))
		Endif

		While !(cQAlSQL)->(Eof())
			If !Empty((cQAlSQL)->VV1_CHASSI) .or. !Empty((cQAlSQL)->VJR_ORDNUM)
				oChave   := JsonObject():new()
				oCli     := JsonObject():new()
				oAtend   := JsonObject():new()
				oAux     := JsonObject():new()
				oResult  := JsonObject():new()

				cQryFin  := " "
				cNfSerie := " "

				oAux["Financeiro"] := {}

				If ! lSchedule
					oProcess:IncRegua1(Alltrim((cQAlSQL)->VV1_CHASSI))
				Endif

				oChave["DEALER"]        := Alltrim(aFilis[nCont,2])
				oChave["DATETIME"]      := FWTimeStamp(2, dData, cTime)
				oChave["COMAR_NUMBER"]  := Alltrim((cQAlSQL)->VJR_ORDNUM)
				oChave["SERIAL_NUMBER"] := Alltrim((cQAlSQL)->VV1_CHASSI)
				oChave["PRESOLD_DATE"]  := StoD((cQAlSQL)->VQ0_DATVEN)

				cNfSerie := Alltrim((cQAlSQL)->VV0_NUMNFI) + " " + Alltrim((cQAlSQL)->VV0_SERNFI)

				If !Empty(cNfSerie) .and. (cQAlSQL)->VV9_STATUS <> 'C' 
					oChave["NF_SERIE"] := cNfSerie
					oChave["NF_DATE"]  := StoD((cQAlSQL)->F2_EMISSAO)
				Else
					oChave["NF_SERIE"] := ""
					oChave["NF_DATE"]  := ""
				Endif

				oAtend["ID_ATENDIMENTO"] := Alltrim((cQAlSQL)->VVA_NUMTRA)
				oAtend["STATUS"]         := Alltrim((cQAlSQL)->Status_Atend)	
				oAtend["NOME_VENDEDOR"]  := Alltrim((cQAlSQL)->VAI_NOMTEC)  
				oAtend["USUARIO_X"]      := Alltrim((cQAlSQL)->VAI_FABUSR)	

				If ((cQAlSQL)->VV9_STATUS <> 'C' )
					oCli["TAX_ID_CPF_CNPJ"] := Alltrim((cQAlSQL)->A1_CGC)
					oCli["CUSTOMER_NAME"]   := Alltrim((cQAlSQL)->A1_NOME)
					oCli["ADDRESS"]         := Alltrim((cQAlSQL)->A1_END)
					oCli["CITY"]            := Alltrim((cQAlSQL)->A1_MUN)
					oCli["STATE"]           := Alltrim((cQAlSQL)->A1_EST)
					oCli["COUNTRY"]         := Alltrim((cQAlSQL)->YA_DESCR)
					oCli["POSTAL_CODE"]     := Alltrim((cQAlSQL)->A1_CEP)
					oCli["PHONE"]           := "+" + Alltrim((cQAlSQL)->A1_DDI) + " (" + Alltrim((cQAlSQL)->A1_DDD) + ") " + Alltrim((cQAlSQL)->A1_TEL)
					oCli["EMAIL"]           := Alltrim((cQAlSQL)->A1_EMAIL)
				Else
					oCli["TAX_ID_CPF_CNPJ"] := ""
					oCli["CUSTOMER_NAME"]   := ""
					oCli["ADDRESS"]         := ""
					oCli["CITY"]            := ""
					oCli["STATE"]           := ""
					oCli["COUNTRY"]         := ""
					oCli["POSTAL_CODE"]     := ""
					oCli["PHONE"]           := ""
					oCli["EMAIL"]           := ""
				Endif	

				oAux["Chave"]           := oChave
				oAux["Atendimento"]     := oAtend
				oAux["Cliente"]         := oCli

				cQryFin := "SELECT CASE"
				cQryFin += "             WHEN VSA.VSA_TIPO = '1' THEN '" + STR0016 + "'" //Financiamento / Leasing
				cQryFin += "             WHEN VSA.VSA_TIPO = '2' THEN '" + STR0017 + "'" //Financiamento Proprio
				cQryFin += "             WHEN VSA.VSA_TIPO = '3' THEN '" + STR0018 + "'" //Consorcio
				cQryFin += "             WHEN VSA.VSA_TIPO = '4' THEN '" + STR0019 + "'" //Veiculo Usado (Avaliacoes)
				cQryFin += "             WHEN VSA.VSA_TIPO = '5' THEN '" + STR0020 + "'" //Entradas
				cQryFin += "             WHEN VSA.VSA_TIPO = '6' THEN '" + STR0021 + "'" //Finame
				cQryFin += "        END Tipo_Fin"
				cQryFin += "  ,VSA.VSA_TIPO "
				cQryFin += "  ,VSA.VSA_CODCLI "
				cQryFin += "  ,VSA.VSA_LOJA "
				cQryFin += "  FROM " + RetSQLName("VS9") + " VS9 "
				cQryFin += " INNER JOIN " +  RetSQLName("VSA") + " VSA ON ( VSA.VSA_FILIAL = '" + xFilial("VSA") + "' AND VSA.VSA_TIPPAG = VS9.VS9_TIPPAG AND VSA.D_E_L_E_T_ = ' ' ) "
				cQryFin += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
				cQryFin += "   AND VS9.VS9_NUMIDE = '" + Alltrim((cQAlSQL)->VVA_NUMTRA) + "'"
				cQryFin += "   AND VS9.VS9_TIPOPE = 'V'"
				cQryFin += "   AND VS9.D_E_L_E_T_ = ' '"
				cQryFin += " GROUP BY CASE"
				cQryFin += "             WHEN VSA.VSA_TIPO = '1' THEN '" + STR0016 + "'" //Financiamento / Leasing
				cQryFin += "             WHEN VSA.VSA_TIPO = '2' THEN '" + STR0017 + "'" //Financiamento Proprio
				cQryFin += "             WHEN VSA.VSA_TIPO = '3' THEN '" + STR0018 + "'" //Consorcio
				cQryFin += "             WHEN VSA.VSA_TIPO = '4' THEN '" + STR0019 + "'" //Veiculo Usado (Avaliacoes)
				cQryFin += "             WHEN VSA.VSA_TIPO = '5' THEN '" + STR0020 + "'" //Entradas
				cQryFin += "             WHEN VSA.VSA_TIPO = '6' THEN '" + STR0021 + "'" //Finame
				cQryFin += "        END"
				cQryFin += "  ,VSA.VSA_TIPO "
				cQryFin += "  ,VSA.VSA_CODCLI "
				cQryFin += "  ,VSA.VSA_LOJA "

				dbUseArea(.t., "TOPCONN", TcGenQry( ,, cQryFin ), cQAlFIN , .f., .t.)

				While !(cQAlFIN)->(Eof())
					oFin      := JsonObject():new()
					cQryBank  := " "
					cBankName := " "
					cProcNum  := " "

					oFin["FINANCING_TYPE"] := Alltrim((cQAlFIN)->Tipo_Fin)

					If (cQAlFIN)->VSA_TIPO == '1' //Financiamento / Leasing
						cQryBank := "SELECT A1_NREDUZ"
						cQryBank += "  FROM " + RetSQLName("SA1")
						cQryBank += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
						cQryBank += "   AND A1_COD = '" + (cQAlFIN)->VSA_CODCLI + "'"
						cQryBank += "   AND A1_LOJA = '" + (cQAlFIN)->VSA_LOJA + "'"
						cQryBank += "   AND D_E_L_E_T_ = ' ' "

						cBankName := Alltrim(FM_SQL(cQryBank))
					Elseif (cQAlFIN)->VSA_TIPO == '6' //Finame
						cProcNum := (cQAlSQL)->VV0_NFINAM //FINANCING_PROCESS_NUMBER (PAC) será preenchido apenas quando Finame.
						
						cQryBank := "SELECT A1_NREDUZ"
						cQryBank += "  FROM " + RetSQLName("SA1")
						cQryBank += " WHERE A1_FILIAL = '" + xFilial("SA1") + "'"
						cQryBank += "   AND A1_COD = '" + (cQAlSQL)->VV0_CLFINA + "'"
						cQryBank += "   AND A1_LOJA = '" + (cQAlSQL)->VV0_LJFINA + "'"
						cQryBank += "   AND D_E_L_E_T_ = ' ' "

						cBankName := Alltrim(FM_SQL(cQryBank))
					Else //Demais Tipos o Cliente/Banco é o do Atendimento
						cBankName := Alltrim((cQAlSQL)->A1_NREDUZ)
					Endif

					oFin["BANK_NAME"]                := Alltrim(cBankName)
					oFin["FINANCING_PROCESS_NUMBER"] := Alltrim(cProcNum)

					aAdd(oAux["Financeiro"], oFin)

					FreeObj(oCli)

					(cQAlFIN)->(DbSkip())
				EndDo
				(cQAlFIN)->(DbCloseArea())

				oResult["Chave"]         := oAux["Chave"]
				oResult["Atendimento"]   := oAux["Atendimento"]
				oResult["Cliente"]       := oAux["Cliente"]
				oResult["Financiamento"] := oAux["Financeiro"]

				aAdd(aBody, oResult)

				If ((cQAlSQL)->VV9_STATUS == 'C' .or. (cQAlSQL)->VV9_STATUS == 'F') .and. lEnvCft
					aAdd(aAuxRec,(cQAlSQL)->RECVV9)
				Endif

				FreeObj(oResult)
				FreeObj(oAux)
				FreeObj(oChave)
				FreeObj(oAtend)
				FreeObj(oCli)
			Endif
			(cQAlSQL)->(DbSkip())
		EndDo
		(cQAlSQL)->(DbCloseArea())
	Next nCont

	cFilAnt := cFilBkp

	If Len(aBody) > 0
		If VA380002D_GeraArquivo(cNomeArq, aBody) .and. Len(aAuxRec) > 0
			VA380004D_AtualizaFlag(aAuxRec, "1")
		Endif
	Endif

	VA380003D_LevantaDados()

Return


/*/{Protheus.doc} VA380002D_GeraArquivo

	@type Static Function
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Static Function VA380002D_GeraArquivo(cNomeArq, aBody)

	Local cDir       := Lower(Alltrim(MV_PAR01))
	Local oBody      := JsonObject():new()
	Local oOFCIFTLog := OFDMSRequest():New()
	Local oWriter    := Nil
	Local lRet       := .t.

	Default cNomeArq := ""
	Default aBody    := {}

	If !ExistDir(cDir)
		MakeDir(cDir)
	Endif

	oWriter := FwFileWriter():New(cDir + cNomeArq, .t.)

	oBody:Set(aBody)

	If !oWriter:Create()
		oOFCIFTLog:SetTypeCIFT()
		oOFCIFTLog:SetOriginDBS()

		oOFCIFTLog:Set("VK5_MESSAG", "26")
		oOFCIFTLog:Set("VK5_ORIKEY", FunName())
		oOFCIFTLog:Set("VK5_RESBOD", STR0003) //Não foi possível criar o arquivo.
		oOFCIFTLog:Set("VK5_RESHEA", cDir + cNomeArq)
		oOFCIFTLog:Save()

		lRet := .f.
	Else
		oWriter:Write(oBody:toJson())
		oWriter:Close()
	Endif

Return lRet


/*/{Protheus.doc} VA380003D_LevantaDados

	@type Static Function
	@author Francisco Carvalho
	@since 22/04/2025
/*/
Static Function VA380003D_LevantaDados()

	Local nArq       := 0
	Local cDir       := Lower(Alltrim(MV_PAR01))
	Local cImport    := Lower(Alltrim(MV_PAR02))
	Local cStr       := ""
	Local cArquivo   := ""
	Local aVetArq    := {}
	Local lDel       := .f.
	Local oClasse    := OFJDCIFT():New()
	Local oOFCIFTLog := OFDMSRequest():New()

	aVetArq := Directory(cDir + "DLR2JD_MARKSOLD_*.json")

	If !ExistDir(cDir + Alltrim(cImport))
		MakeDir(cDir + Alltrim(cImport))
	Endif

	If len(aVetArq) == 0
		oOFCIFTLog:SetTypeCIFT()
		oOFCIFTLog:SetOriginDBS()

		oOFCIFTLog:Set("VK5_MESSAG", "27")
		oOFCIFTLog:Set("VK5_ORIKEY", FunName())
		oOFCIFTLog:Set("VK5_RESBOD", STR0004) //Não existe arquivo compatível no diretório especificado.
		oOFCIFTLog:Set("VK5_RESHEA", cDir)
		oOFCIFTLog:Save()
		Return
	Endif

	aSort(aVetArq,,,{|x,y| DtoS(x[3])+x[4] < DtoS(y[3])+y[4] })

	For nArq := 1 to Len(aVetArq)
		cArquivo := Lower(Alltrim(cDir + aVetArq[nArq,1]))
		cMoveArq := Lower(cDir + ALLTRIM(cImport + "/ ") + aVetArq[nArq,1])

		oFile := FWFileReader():New(cArquivo)

		If (oFile:Open())
			While (oFile:hasLine())

				cStr := oFile:GetLine()

				oFile:Close()

				If oClasse:EnviaMensagem(cStr, aVetArq[nArq,1])
					lDel := __CopyFile(cArquivo, cMoveArq,,,.f.)
				Endif

				If !IsSrvUnix()
					CHMOD(cArquivo , 2,,.f.)
				Endif

				If lDel
					FERASE(cArquivo)
				Endif

			EndDo
		Else
			oOFCIFTLog:SetTypeCIFT()
			oOFCIFTLog:SetOriginDBS()

			oOFCIFTLog:Set("VK5_MESSAG", "27")
			oOFCIFTLog:Set("VK5_ORIKEY", FunName())
			oOFCIFTLog:Set("VK5_RESBOD", STR0005) //Não foi possível abrir o arquivo.
			oOFCIFTLog:Set("VK5_RESHEA", cArquivo)
			oOFCIFTLog:Save()
		Endif
	Next

Return


/*/{Protheus.doc} VA380004D_AtualizaFlag

	@type Function
	@author Francisco Carvalho
	@since 23/06/2025
/*/
Function VA380004D_AtualizaFlag(aRecVV9, cFlgEnv)

	Local aArea := GetArea()
	Local nI    := 0

	Default aRecVV9 := {}
	Default cFlgEnv := " "
	
	If VV9->(FieldPos("VV9_ENVCFT")) > 0
		If Len(aRecVV9) > 0
			For nI := 1 to Len(aRecVV9)
				VV9->(dbGoTo(aRecVV9[nI]))	//Posiciona no atendimento	
				RecLock("VV9",.f.)
				VV9->VV9_ENVCFT := cFlgEnv //Altera a FLAG que faz o controle dos registros que devem ser Enviados para o CIFT.
				MsUnLock()
			Next nI
		Endif
	Endif

	RestArea(aArea)

Return


/*/{Protheus.doc} VA380005D_PrimeiraCarga

	@type Static Function
	@author Francisco Carvalho
	@since 03/07/2025
/*/
Static Function VA380005D_PrimeiraCarga()

	Local cQryFat := " "
	Local cQryAbe := " "
	Local cQAlFat := "LEVFAT"
	Local cQAlAbe := "LEVABE"
	Local aAuxFat := {}
	Local aAuxAbe := {}
	Local cDtCort := DtoS(Date() - 15)

	//Levanta os atendimentos faturados nos ultimos 15 dias
	cQryFat := " SELECT VV9.R_E_C_N_O_"
	cQryFat += "   FROM " + RetSQLName("VV9") + " VV9"
	cQryFat += "  INNER JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = '" + xFilial('VV0') + "' AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0_DATMOV > '" + cDtCort + "' AND VV0.D_E_L_E_T_ = ' '"
	cQryFat += "  WHERE VV9.VV9_FILIAL = '" + xFilial("VV9") + "'"
	cQryFat += "    AND VV9.VV9_STATUS = 'F'"
	cQryFat += "    AND VV9.D_E_L_E_T_ = ' '"

	dbUseArea(.t., "TOPCONN", TcGenQry( ,, cQryFat ), cQAlFat , .f., .t.)

	While !(cQAlFat)->(Eof())
		aAdd(aAuxFat, (cQAlFat)->R_E_C_N_O_)
		(cQAlFat)->(DbSkip())
	EndDo
	(cQAlFat)->(DbCloseArea())

	//Caso houver registros para ajustar, chama a função que atualiza o Flag que controla o envio ao CIFT
	If !Empty(aAuxFat)
		VA380004D_AtualizaFlag(aAuxFat, "0")
	Endif

	//Levanta TODOS os atendimentos em aberto
	cQryAbe := " SELECT R_E_C_N_O_"
	cQryAbe += "   FROM " + RetSQLName("VV9")
	cQryAbe += "  WHERE VV9_FILIAL = '" + xFilial("VV9") + "'"
	cQryAbe += "    AND VV9_STATUS NOT IN ('F','C')"
	cQryAbe += "    AND D_E_L_E_T_ = ' '"

	dbUseArea(.t., "TOPCONN", TcGenQry( ,, cQryAbe ), cQAlAbe , .f., .t.)

	While !(cQAlAbe)->(Eof())
		aAdd(aAuxAbe, (cQAlAbe)->R_E_C_N_O_)
		(cQAlAbe)->(DbSkip())
	EndDo
	(cQAlAbe)->(DbCloseArea())

	//Caso houver registros para ajustar, chama a função que atualiza o Flag que controla o envio ao CIFT
	If !Empty(aAuxAbe)
		VA380004D_AtualizaFlag(aAuxAbe, "0")
	Endif

Return


/*/{Protheus.doc} VA380006D_LimpaFlagEnvio

	@type Static Function
	@author Francisco Carvalho
	@since 18/09/2025
/*/
Static Function VA380006D_LimpaFlagEnvio()

	Local cQry    := " "
	Local cQAlFlg := "LEVFLG"
	Local aAux    := {}

	If VV9->(FieldPos("VV9_ENVCFT")) > 0
		//Levanta os registros com VV9_ENVCFT preenchidos
		cQry := " SELECT R_E_C_N_O_"
		cQry += "   FROM " + RetSQLName("VV9")
		cQry += "  WHERE VV9_FILIAL = '" + xFilial("VV9") + "'"
		cQry += "    AND VV9_ENVCFT <> ' '"
		cQry += "    AND D_E_L_E_T_ = ' '"

		dbUseArea(.t., "TOPCONN", TcGenQry( ,, cQry ), cQAlFlg , .f., .t.)

		While !(cQAlFlg)->(Eof())
			aAdd(aAux, (cQAlFlg)->R_E_C_N_O_)
			(cQAlFlg)->(DbSkip())
		EndDo
		(cQAlFlg)->(DbCloseArea())

		//Caso houver registros para ajustar, chama a função que atualiza o Flag que controla o envio ao CIFT
		If !Empty(aAux)
			VA380004D_AtualizaFlag(aAux)
		Endif
	Endif

Return