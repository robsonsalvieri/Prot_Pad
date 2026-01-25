/*
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA
*/
Function RUP_PCP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local iSFC     := 0

	#IFDEF TOP
		If cVersion >= "12"

			// Executa quando migrar para a 27 ou superior.
			// Não existe limite, pois após a 2410 não será mais atualizado pelo RUP
			If cRelFinish >= "027" .And. cMode == "1" //1=Por grupo de empresas
				TratNewPcp() // NEWPCP - Tratamento de Campos novos
				foldersSVK() // Apaga os folder e agrupamentos da tabela SVK - Descontinuação do RFID
			EndIf

			// Executa quando migrar da release 27 ou inferior para a release 27 ou superior
			// A partir da 033 não executa mais esse ajuste
			If cRelStart <= "027" .And. cRelFinish >= "027" .And. cMode == "2"
				// Atualiza motivos de parada e refugo da tabela SX5
				UPDMotiPar()
				UPDMotiRef()
			EndIf

			// A partir da 2210 não executa mais esse ajuste
			If cRelStart <= "033" .And. cRelFinish >= "033" .And. cMode == "1" //1=Por grupo de empresas
				//AJUSTE 1
				//Forçar ajustes na ordenação de campos SGI(Produto Alternativo)
				If SX3->(DbSeek("GI_DESC"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "05"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_TIPOCON"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "06"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_FATOR"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "07"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_MRP"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "08"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_DATA"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "09"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_ESTOQUE"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "10"
					SX3->(MsUnlock())
				EndIf

				//AJUSTE 2
				//Ajustar campo de quantidade para aumentar os decimais
				//Campo criado incorretamente no SFC 
				//O SFC deve seguir as configurações dos campos do PCP
				iSFC := SFCIntegra()

				If iSFC == 1
					dbSelectArea("SX3")
					SX3->(dbSetOrder(2))
					If SX3->(DbSeek("G2_TEMPEND"))
						nDecimal := SX3->X3_DECIMAL
					
						If nDecimal > 0
							dbSelectArea("SX3")
							SX3->(dbSetOrder(2))
							If SX3->(DbSeek("CYD_QTTETS"))					
								nTamCYD := SX3->X3_TAMANHO
								cPicture := ' '

								If nDecimal == 2 .And. nTamCYD == 10
									cPicture := '@E 9,999,999.99'
								Else
									CriaPicRUP(nDecimal,nTamCYD, @cPicture)
								EndIf
				
								RecLock("SX3",.F.)
									SX3->X3_DECIMAL := nDecimal
									SX3->X3_PICTURE := cPicture
								SX3->(MsUnlock())
							EndIf
						EndIf						
					EndIf
				EndIf
			EndIf
		EndIf
	#Endif

Return Nil

//----------------------------------------------------------------------
// Tratamento de Campos incluídos do projeto NewPCP
//----------------------------------------------------------------------
Static Function TratNewPcp()

	Local cNextAlias := GetNextAlias()
	Local cQuery     := ""

	dbSelectArea("SGI")
	If SGI->(FieldPos("GI_ESTOQUE")) > 0
		BeginSQL Alias cNextAlias
			SELECT 1 FROM %Table:SGI% SGI
			 WHERE SGI.GI_ESTOQUE IS NULL OR SGI.GI_ESTOQUE = %Exp:' '%
		EndSQL

		If !(cNextAlias)->(Eof())
			cQuery := "UPDATE " + RetSqlName("SGI")
			cQuery +=   " SET GI_ESTOQUE = '1'"
			cQuery += " WHERE GI_ESTOQUE IS NULL OR GI_ESTOQUE = ' '"
			TCSQLExec(cQuery)
		EndIf

		(cNextAlias)->(DbCloseArea())
	EndIf

	dbSelectArea("SG1")
	If SG1->(FieldPos("G1_USAALT")) > 0
		BeginSQL Alias cNextAlias
			SELECT 1 FROM %Table:SG1% SG1
			 WHERE SG1.G1_USAALT IS NULL OR SG1.G1_USAALT = %Exp:' '%
		EndSQL

		If !(cNextAlias)->(Eof())
			cQuery := "UPDATE " + RetSqlName("SG1")
			cQuery +=   " SET G1_USAALT = '1'"
			cQuery += " WHERE G1_USAALT IS NULL OR G1_USAALT = ' '"
			TCSQLExec(cQuery)
		EndIf

		(cNextAlias)->(DbCloseArea())
	EndIf

	AtualizDic()
Return

//----------------------------------------------------------------------
// Atualiza dicionário comparando campos/compartilhamento de
// tabelas do MRP com as respectivas tabelas do ERP
//----------------------------------------------------------------------
Static Function AtualizDic()

	Local aInconsCp   := {}
	Local aInconsCo   := {}
	Local aTabUpd     := {}
	Local nIndIncons  := 0

	If FindFunction("VCpMRPxERP")
		aInconsCp := VCpMRPxERP()

		If Len(aInconsCp)
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))

			For nIndIncons := 1 To Len(aInconsCp)
				If SX3->(dbSeek(aInconsCp[nIndIncons][2]))
					If RecLock("SX3",.F.)
						SX3->X3_TAMANHO := aInconsCp[nIndIncons][3]
						SX3->X3_DECIMAL := aInconsCp[nIndIncons][4]
						SX3->X3_PICTURE := aInconsCp[nIndIncons][5]
						SX3->(MsUnlock())
					Endif

					If aScan(aTabUpd, aInconsCp[nIndIncons][1]) < 1
						aAdd(aTabUpd, aInconsCp[nIndIncons][1])
					EndIf
				Endif
			Next nIndIncons
		EndIf
	EndIf

	If FindFunction("VCoMRPxERP")
		aInconsCo := VCoMRPxERP()

		If Len(aInconsCo)
			For nIndIncons := 1 To Len(aInconsCo)
				If ChkFile(aInconsCo[nIndIncons][2][1])
					DbSelectArea(aInconsCo[nIndIncons][2][1])
					(aInconsCo[nIndIncons][2][1])->(DbGoTop())

					If (aInconsCo[nIndIncons][2][1])->(Eof())
						DbSelectArea("SX2")
						SX2->(DbSetOrder(1))
						If SX2->(DbSeek(aInconsCo[nIndIncons][2][1]))
							If RecLock("SX2", .F.)
								SX2->X2_MODOEMP := aInconsCo[nIndIncons][1][2]
								SX2->X2_MODOUN  := aInconsCo[nIndIncons][1][3]
								SX2->X2_MODO    := aInconsCo[nIndIncons][1][4]
								SX2->(MsUnlock())
							EndIf

							If aScan(aTabUpd, aInconsCo[nIndIncons][2][1]) < 1
								aAdd(aTabUpd, aInconsCo[nIndIncons][2][1])
							EndIf
						EndIf
					EndIf
					(aInconsCo[nIndIncons][2][1])->(DbCloseArea())
				EndIf
			Next nIndIncons
		EndIf
	EndIf

	For nIndIncons := 1 To Len(aTabUpd)
		If !Empty(aTabUpd[nIndIncons])
			__SetX31Mode(.F.)
			
			If Select(aTabUpd[nIndIncons]) > 0
				DbSelectArea(aTabUpd[nIndIncons])
				DbCloseArea()
			EndIf
				
			X31UpdTable(aTabUpd[nIndIncons])
		EndIf
	Next nIndIncons
Return

//----------------------------------------------------------------------
// Cria PICTURE conforme tamanho do campo númerico
//----------------------------------------------------------------------
Static Function CriaPicRUP(nDecimal,nTamCYD, cPicture)
 
  Local nI := 0

	If nDecimal > 0
		cMasc := '@E '
		cPicDec := '.'
		cPicT1 := ''
		cPicT2 := ''

		//Gera formatação do decimal
		For nI = 1 to nDecimal
			cPicDec += '9'
		Next

		//Gera formatação do tamanho
		nQtd    := (nTamCYD - nDecimal - 1)
		nInt    := Int(nQtd / 3)

		If nInt > 1
			nQtd1 := nQtd - (nInt*3)		
		
			If nQtd1 > 0
				For nI := 1 to (nQtd1)
					cPicT1 +='9'
				Next
				cPicT1 += ','
			EndIf

			For nI := 1 to (nInt)
				If nI < nInt
					cPicT2 += '999,'
				Else
					cPicT2 += '999'
				EndIf
			Next			
		Else			
			For nI := 1 to (nQtd)
				cPicT1 +='9'
			Next
		EndIf

		cPicture := cValToChar(cMasc) + cValToChar(cPicT1) + cValToChar(cPicT2) + cValToChar(cPicDec)	
	EndIf

Return 

/*/{Protheus.doc} foldersSVK
Apaga os folders e agrupamentos da tabela SVK.
@type  Static Function
@author Lucas Fagundes
@since 23/08/2022
@version P12
@return Nil
/*/
Static Function foldersSVK()
	DbSelectArea("SXA")
	
	SXA->(DbSetOrder(1))
	If SXA->(DbSeek("SVK"))
		While SXA->(!EoF()) .And. SXA->XA_ALIAS == "SVK"
			If RecLock('SXA',.F.)
				SXA->(dbDelete())
				SXA->(MsUnlock())
			EndIf
			SXA->(dbSkip())
		End
	EndIf

Return Nil
