#Include 'Protheus.ch'

Function TAFGIM11(aWizard, cJobAux)

 	//21o Registro – Detalhamentos dos Débitos e Créditos

	Local cTxtSys  	:= CriaTrab( , .F. ) + ".TXT"
	Local nHandle   	:= MsFCreate( cTxtSys )
	Local cStrTxt		:= ""
	Local cData 		:= Substr(aWizard[1][2],4,4) + Substr(aWizard[1][2],1,2)
	Local oError		:= ErrorBlock( { |Obj| Alert( "Mensagem de Erro: " + Chr( 10 )+ Obj:Description ) } )

	Local cReg as char
	Local cDes as char

	Local aRegistro as array
	Local nPos      as numeric

	aRegistro := {}

	Begin Sequence

		DbSelectArea("C2S")
		DbSelectArea("C2T")
		DbSelectArea("CHY")

		C2S->(DbSetOrder(2))
		If C2S->(DbSeek(xFilial("C2S")))
		 	While C2S->(!EOF()) .AND. xFilial("C2S") == C2S->C2S_FILIAL

		 		If (!(Substr(DtoS(C2S->C2S_DTINI),1,6) == cData .AND. Substr(DtoS(C2S->C2S_DTFIN),1,6) == cData))
	 				C2S->(dbSkip())
		 			Loop
		 		Endif

				C2T->(DbSetOrder(1))
				If C2T->(DbSeek(xFilial("C2T") + C2S->C2S_ID))
					While C2T->(!EOF()) .AND. xFilial("C2T") == C2T->C2T_FILIAL .AND. C2T->C2T_ID == C2S->C2S_ID

						CHY->(DbSetOrder(1))
						If CHY->(DbSeek(xFilial("CHY") + C2T->C2T_IDSUBI))
							cReg := ""
							Do Case
								Case CHY->CHY_CODIGO  == "00143"
									cReg := "43"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00144"
									cReg := "44"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00158"
									cReg := "58"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00159"
									cReg := "59"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00148"
									cReg := "48"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00149"
									cReg := "49"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00150"
									cReg := "50"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00163"
									cReg := "63"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00168"
									cReg := "68"
									cDes := CHY->CHY_DESCRI
								Case CHY->CHY_CODIGO  == "00169"
									cReg := "69"
									cDes := CHY->CHY_DESCRI
								Otherwise
									C2T->(dbSkip())
									Loop
							EndCase

							nPos := aScan(aRegistro,{|aVal| aVal[1] == cReg})

							If (cDes != "")
								If nPos == 0
									AADD( aRegistro, {cReg, cDes, C2T->C2T_VLRAJU })
								Else
									aRegistro[nPos,3] += C2T->C2T_VLRAJU
								EndIf
							Endif
						EndIf

						C2T->(dbSkip())
					EndDo
				Endif
				C2S->(dbSkip())
			EndDo
		EndIf

		If len(aRegistro) > 0

			aSort(aRegistro, , , {|x,y| x[1] <= y[1]})

			For nPos := 1 to len(aRegistro)
				cStrTxt += aRegistro[nPos,1]
			 	cStrTxt += padR(Upper(OemToAnsi(FwNoAccent(aRegistro[nPos,2]))),30)
				cStrTxt += padL(cValToChar(aRegistro[nPos,3] * 100),14)
				cStrTxt += CRLF
			Next
		EndIf

	 	WrtStrTxt( nHandle, cStrTxt )
		GerTxtGIM( nHandle, cTxtSys, "11")

		Recover
		lFound := .F.
	End Sequence

	//Tratamento para ocorrência de erros durante o processamento
	ErrorBlock( oError )

	If !lFound
		//Status 9 - Indica ocorrência de erro no processamento
		PutGlbValue( cJobAux , "11" )
		GlbUnlock()

	Else
		//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
		PutGlbValue( cJobAux , "1" )
		GlbUnlock()

	EndIf

Return


